const { BlobServiceClient } = require("@azure/storage-blob");
const sharp = require("sharp");

const {
    APPSETTING_AZURE_STORAGE_CONNECTION_STRING,
    APPSETTING_PROFILE_IMAGES_CONTAINER,
    APPSETTING_THUMBNAILS_CONTAINER,
} = process.env;

module.exports = async function (context, eventGridEvent) {
    context.log(
        "Processing blob \n Blob:",
        eventGridEvent.subject,
        "\n Blob Size:",
        eventGridEvent.data.contentLength,
        "Bytes"
    );

    try {
        const blobServiceClient = BlobServiceClient.fromConnectionString(
            APPSETTING_AZURE_STORAGE_CONNECTION_STRING
        );

        const profileImagesContainerClient = blobServiceClient.getContainerClient(
            APPSETTING_PROFILE_IMAGES_CONTAINER
        );

        const imageKey = eventGridEvent.subject.split("/").slice(-2).join("/");

        context.log("Image Key:", imageKey);

        const blobClient = profileImagesContainerClient.getBlobClient(imageKey);

        const downloadBlobClientResponse = await blobClient.download(0);
        
        const blobContent = await streamToBuffer(downloadBlobClientResponse.readableStreamBody);

        context.log("Original image:", blobContent, blobContent.length);
        
        const compressedImage = await sharp(blobContent)
            .resize(200, 200)
            .jpeg()
            .toBuffer();
        
        context.log("Compressed image:", compressedImage, compressedImage.length);
        
        const thumbnailsContainerClient = blobServiceClient.getContainerClient(
            APPSETTING_THUMBNAILS_CONTAINER
        );

        const blockBlobClient = thumbnailsContainerClient.getBlockBlobClient(imageKey);

        const uploadBlockBlobClientResponse = await blockBlobClient.upload(
            compressedImage,
            compressedImage.length
        );

        context.log("Blob uploaded response:", uploadBlockBlobClientResponse);
    } catch (err) {
        context.log("ERROR:", err);
    }
};

// Helper function to read a readable stream into a buffer
async function streamToBuffer(readableStream) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        readableStream.on("data", (data) => {
            chunks.push(data);
        });
        readableStream.on("end", () => {
            resolve(Buffer.concat(chunks));
        });
        readableStream.on("error", reject);
    });
}

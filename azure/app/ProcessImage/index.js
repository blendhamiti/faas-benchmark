const { BlobServiceClient } = require("@azure/storage-blob");
const sharp = require("sharp");

const {
    APPSETTING_AZURE_STORAGE_CONNECTION_STRING,
    APPSETTING_THUMBNAILS_CONTAINER,
} = process.env;

module.exports = async function (context, myBlob) {
    context.log(
        "Processing blob \n Blob:",
        context.bindingData.blobTrigger,
        "\n Blob Size:",
        myBlob.length,
        "Bytes"
    );

    context.log("Binding data:", context.bindingData);

    try {
        const compressedImage = await sharp(myBlob)
            .resize(200, 200)
            .jpeg()
            .toBuffer();

        context.log("Compressed image:", compressedImage, compressedImage.length);

        const imageKey = context.bindingData.blobTrigger.split("/").slice(1, 3).join("/");

        context.log("Image Key:", imageKey);

        const blobServiceClient = BlobServiceClient.fromConnectionString(
            APPSETTING_AZURE_STORAGE_CONNECTION_STRING
        );

        const containerClient = blobServiceClient.getContainerClient(
            APPSETTING_THUMBNAILS_CONTAINER
        );

        const blockBlobClient = containerClient.getBlockBlobClient(imageKey);

        const uploadBlobResponse = await blockBlobClient.upload(
            compressedImage,
            compressedImage.length
        );

        context.log("Blob uploaded response:", uploadBlobResponse);
    } catch (err) {
        context.log("ERROR:", err);
    }
};

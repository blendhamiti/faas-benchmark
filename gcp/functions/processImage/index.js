const { Storage } = require("@google-cloud/storage");
const sharp = require("sharp");

const { THUMBNAIL_BUCKET } = process.env;

const storage = new Storage();

exports.processImage = async (file, context) => {
  console.log("FILE:", JSON.stringify(file));

  // Get the object from the event, compress it, and put it in other bucket
  try {
    const bucket = storage.bucket(file.bucket);

    const image = (await bucket.file(file.name).download())[0];

    const compressedImage = await sharp(image).resize(200, 200).jpeg().toBuffer();

    const thumbnailBucket = storage.bucket(THUMBNAIL_BUCKET);

    await thumbnailBucket.file(file.name).save(compressedImage);

    console.log("Uploaded compressed image to:", `${THUMBNAIL_BUCKET} ${file.name}`);
  } catch (err) {
    console.log("ERROR:", err);
  }
};


const aws = require("aws-sdk");
const sharp = require("sharp");

console.log("PROCESS:", process);

const { THUMBNAIL_BUCKET } = process.env;

const s3 = new aws.S3({ apiVersion: "2006-03-01" });

exports.handler = async (event, context) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  // Get the object from the event, compress it, and put it in other bucket
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " ")
  );
  const getParams = {
    Bucket: bucket,
    Key: key,
  };

  try {
    const { Body: image, ContentType } = await s3.getObject(getParams).promise();
    console.log("CONTENT TYPE:", ContentType);

    const compressedImage = await sharp(image).resize(200, 200).jpeg().toBuffer();

    const putParams = {
      Bucket: THUMBNAIL_BUCKET,
      Key: getParams.Key,
      Body: compressedImage,
    };

    await s3.putObject(putParams).promise();

    console.log("S3 PutObject with params:", putParams);

    return ContentType;
  } catch (err) {
    console.log(err);
    const message = `Error getting object ${key} from bucket ${bucket}. Make sure they exist and your bucket is in the same region as this function.`;
    console.log(message);
    throw new Error(message);
  }
};

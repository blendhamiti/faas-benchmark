const { BlobServiceClient } = require("@azure/storage-blob");
const formParser = require("lambda-multipart-parser");
const Database = require("../util/Database");

const bcrypt = require('bcrypt');
const passwordHashSalt = "$2b$10$CibOCynf5wIN3x3eQEovw.";

const {
  APPSETTING_DB_HOST,
  APPSETTING_DB_NAME,
  APPSETTING_DB_USER,
  APPSETTING_DB_PASSWORD,
  APPSETTING_AZURE_STORAGE_CONNECTION_STRING,
  APPSETTING_PROFILE_IMAGES_CONTAINER,
} = process.env;

const database = new Database({
  host: APPSETTING_DB_HOST,
  user: APPSETTING_DB_USER,
  password: APPSETTING_DB_PASSWORD,
  database: APPSETTING_DB_NAME,
});

module.exports = async function (context, req) {
  let responseMessage = "User created";

  try {
    // parse form data
    const form = await formParser.parse(req);

    context.log("FORM:", form);

    const { name, email, password, files } = form;

    // hash user password
    const passwordHash = bcrypt.hashSync(password, passwordHashSalt);

    // add user to db
    const insertResult = await database.query(
      `INSERT INTO users (name, email, password) VALUES ('${name}', '${email}', '${passwordHash}')`
    );

    context.log("MySQL Result:", insertResult);

    const userID = insertResult.insertId;

    // upload profile image
    const profileImage = files.find(
      (file) => file.fieldname === "profileImage"
    );

    if (profileImage) {
      const { content } = profileImage;

      const key = `user-${userID}/profile-image.jpg`;

      const blobServiceClient = BlobServiceClient.fromConnectionString(
        APPSETTING_AZURE_STORAGE_CONNECTION_STRING
      );

      const containerClient = blobServiceClient.getContainerClient(
        APPSETTING_PROFILE_IMAGES_CONTAINER
      );

      const blockBlobClient = containerClient.getBlockBlobClient(key);

      const uploadBlobResponse = await blockBlobClient.upload(
        content,
        content.length
      );

      context.log("Blob uploaded response:", uploadBlobResponse);
    }
  } catch (error) {
    context.log("ERROR:", error);

    responseMessage = "User NOT created";
  }

  context.res = {
    status: 200,
    body: responseMessage,
  };
};

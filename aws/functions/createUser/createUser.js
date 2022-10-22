const aws = require("aws-sdk");
const formParser = require("lambda-multipart-parser");
const Database = require("./Database");

const bcrypt = require('bcrypt');
const passwordHashSalt = "$2b$10$CibOCynf5wIN3x3eQEovw.";

console.log("PROCESS:", process);

const { PROFILE_IMAGE_BUCKET, DB_HOST, DB_NAME, DB_USER, DB_PASSWORD } =
  process.env;

const s3 = new aws.S3({ apiVersion: "2006-03-01" });

const database = new Database({
  host: DB_HOST,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
});

exports.handler = async (event, context) => {
  console.log("EVENT:", event);

  try {
    // parse form data
    const form = await formParser.parse(event);

    console.log("FORM:", form);

    const { name, email, password, files } = form;

    // hash user password
    const passwordHash = bcrypt.hashSync(password, passwordHashSalt);

    // add user to db
    const insertResult = await database.query(
      `INSERT INTO users (name, email, password) VALUES ('${name}', '${email}', '${passwordHash}')`
    );

    console.log("MySQL Result:", insertResult);

    const userID = insertResult.insertId;

    // upload profile image
    const profileImage = files.find(
      (file) => file.fieldname === "profileImage"
    );

    if (profileImage) {
      const { content } = profileImage;

      const params = {
        Bucket: PROFILE_IMAGE_BUCKET,
        Key: `user-${userID}/profile-image.jpg`,
        Body: content,
      };

      await s3.putObject(params).promise();

      console.log("S3 PutObject with params:", params);
    }
  } catch (error) {
    console.log("ERROR:", error);

    const responseMessage = "User NOT created";

    return {
      statusCode: 400,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: responseMessage,
      }),
    };
  }

  const responseMessage = "User created";

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: responseMessage,
    }),
  };
};

const functions = require("@google-cloud/functions-framework");
const { Storage } = require("@google-cloud/storage");
const formParser = require("lambda-multipart-parser");
const Database = require("./Database");

const bcrypt = require('bcrypt');
const passwordHashSalt = "$2b$10$CibOCynf5wIN3x3eQEovw.";

const { PROFILE_IMAGE_BUCKET, DB_HOST, DB_NAME, DB_USER, DB_PASSWORD } =
  process.env;

const database = new Database({
  host: DB_HOST,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
});

const storage = new Storage();

exports.createUser = functions.http("createUser", async (req, res) => {
  try {
    // parse form data
    const form = await formParser.parse(req);

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

      const fileName = `user-${userID}/profile-image.jpg`;

      const bucket = storage.bucket(PROFILE_IMAGE_BUCKET);

      await bucket.file(fileName).save(content);

      console.log("Uploaded image to:", `${PROFILE_IMAGE_BUCKET} ${fileName}`);
    }
  } catch (error) {
    console.log("ERROR:", error);

    res.setHeader("Content-Type", "application/json");
    res.status(400);
    res.send(
      JSON.stringify({
        message: "User NOT created",
      })
    );
  }

  res.setHeader("Content-Type", "application/json");
  res.status(200);
  res.send(
    JSON.stringify({
      message: "User created",
    })
  );
});

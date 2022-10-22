### Steps:
- Create '.env' from '.example.env' and run `source .env`
- Run `npm install` in all '/functions/{functionName}'
- Run `terraform ...` (init, login, plan, apply)?

### DB Schema

CREATE DATABASE seeu_db;

CREATE TABLE `seeu_db`.`users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(90) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
);
### Steps:
- Create '.env' from '.example.env' and run `source .env`
- Create 'terraform.auto.tfvars' from 'terraform.auto.tfvars.example'
- In '/app', run `npm install` & create `local.settings.json` to inject env variables when testing locally
- In '/app', run `npm install --platform=win32 --arch=ia32 sharp` and `npm install bcrypt --target_arch=ia32 --target_platform=win32` to install the correct version of the libraries for the deployment environment
- Run `terraform ...`

### DB Schema

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(90) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
);

TODOs:
- DB in VPN
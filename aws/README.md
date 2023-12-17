### Steps:
- Create '.env' from '.example.env' and run `source .env`
- Run `npm install` in all '/functions/{functionName}'
  - Use `npm install --platform=linux --arch=x64 sharp` and `npm install bcrypt --target_arch=x64 --target_platform=linux --target_libc=glibc` to install the correct version of the libraries for the deployment environment
  - For `bcrypt`, if that fails, go to `node_modules/bcrypt` and run `node-pre-gyp install --target_arch=x64 --target_platform=linux --update-binary --target_libc=glibc`
  - For `sharp`, if that fails, run `npm install -f @img/sharp-linux-x64` and `npm install -f @img/sharp-libvips-linux-x64`
- Run `terraform ...` (init, login, plan, apply)

### DB Schema

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(90) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
);
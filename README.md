# faas-benchmark

There are three directories for each CSP:
- `/aws`
- `/azure`
- `/gcp`

## Deploying

From each directory, do:
1. Run ` npm install --cpu=<arch> --os=<platform> -f` in all '/functions/{functionName}' to install the correct version of the function dependencies for each deployment environment.
    - For `bcrypt`, if that fails, go to `node_modules/bcrypt` and run `node-pre-gyp install --target_arch=<arch> --target_platform=<platform> --update-binary (--target_libc=<libc>)`
    - For `sharp`, if that fails, run `npm install -f @img/sharp-<platform>-<arch>` and `npm install -f @img/sharp-libvips-<platform>-<arch>`
1. Create '.env' from '.example.env' and run `source .env`
1. If applicable, create 'terraform.auto.tfvars' from 'terraform.auto.tfvars.example'
1. Run `terraform <init/login/plan/apply>` 

#### Prepare DB

At the moment, the DB schema is not created by the script. Hence, you have to execute the query below manually after somehow accessing the DB instance.
> Credentials to login to the DB can be found somewhere in the tf resource declarations for each CSP.

```
CREATE TABLE `seeu_db`.`users` (
  `user_id`   int(11)      NOT     NULL AUTO_INCREMENT,
  `email`     varchar(90)  NOT     NULL               ,
  `password`  varchar(255) NOT     NULL               ,
  `name`      varchar(45)  DEFAULT NULL               ,
  PRIMARY KEY                (`user_id`)              ,
  UNIQUE KEY  `email_UNIQUE` (`email`)
);
```

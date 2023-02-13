CREATE TABLE basic_auth."users" (
    "id" serial NOT NULL PRIMARY KEY,
    "pass" varchar(128) NOT NULL,
    "username" varchar(150) NOT NULL UNIQUE,
    "first_name" varchar(150) NOT NULL,
    "last_name" varchar(150) NOT NULL,
    "email" varchar(254) NOT NULL UNIQUE check ( email ~* '^.+@.+\..+$' ),
    "national_code" varchar(11) NOT NULL UNIQUE,
    "shareholder_code" varchar(9) NOT NULL UNIQUE,
    "birthday" date NULL,
    "address" text NULL,
    "accountBalance" bigint NOT NULL DEFAULT 0 CHECK ("accountBalance" >= 0),
    "phone" varchar(11) NOT NULL,
     role  name not null check (length(role) < 512)
);
----------------------------------------------------------------------------------------

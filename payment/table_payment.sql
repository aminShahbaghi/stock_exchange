CREATE TABLE payment."payment_action" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(10) NOT NULL
    
);
--------------------------------------------------------------------------------------

CREATE TABLE payment."payment" (
    "id" serial NOT NULL PRIMARY KEY,
    "amount" bigint NOT NULL CHECK ("amount" >= 0),
    "created_at" timestamp  NOT NULL,
    "user_id" bigint NOT NULL ,
    "action" int2 NOT NULL,

    FOREIGN KEY (user_id) REFERENCES basic_auth.users (id),
    FOREIGN KEY ("action") REFERENCES mydata."payment_action" (id)
    
);
--------------------------------------------------------------------------------------
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
    "action" payment.payment_action_enum NOT NULL,

    FOREIGN KEY (user_id) REFERENCES basic_auth.users (id)
    
);
--------------------------------------------------------------------------------------
CREATE TABLE payment."payment_slip_image" (
	"id" serial NOT NULL PRIMARY KEY,
	"file" bytea NOT NULL,
	"type" text NULL,
	"name" text NULL
);
--------------------------------------------------------------------------------------
CREATE TABLE payment."payment_slip" (
    "pk_fk_payment_id" int NOT NULL PRIMARY KEY,
    "account_number" varchar(16) NOT NULL,--شماره حساب 
    "payment_code" varchar(17) NULL,-- شناسه پرداخت
    "shaba_number" varchar(24)  NULL,--شماره شبا
    "image_id" int not null,
	
    FOREIGN KEY (pk_fk_payment_id) REFERENCES payment.payment (id),
    FOREIGN KEY (image_id) REFERENCES payment.payment_slip_image (id) 
);
--------------------------------------------------------------------------------------
CREATE TABLE payment."payment_gateway" (
    "pk_fk_payment_id" int NOT NULL PRIMARY KEY,
    "card_number" varchar(16) NOT NULL,--شماره کارت  
    "receiver_number" varchar(15)  NOT NULL,-- شماره پذیرنده
    "terminal_number" varchar(9)  NOT NULL,--شماره ترمینال
    "reference_number" varchar(15)  NOT NULL,--شماره مرجع
    "tracking_number" varchar(15)  NOT NULL,--شماره پیگیری
    "gateway_payment_code" varchar(15)  NOT NULL,--کد درگاه پرداخت
	
    FOREIGN KEY (pk_fk_payment_id) REFERENCES payment.payment (id)
    
);
--------------------------------------------------------------------------------------
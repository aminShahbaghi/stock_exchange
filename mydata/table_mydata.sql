CREATE TABLE mydata."order_action" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(10) NOT NULL
    
);
--------------------------------------------------------------------------------------
CREATE TABLE mydata."order_status" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(15) NOT NULL
    
);
--------------------------------------------------------------------------------------
CREATE TABLE mydata."payment_action" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(10) NOT NULL
    
);
--------------------------------------------------------------------------------------

CREATE TABLE mydata."orders" (
    "id" serial NOT NULL PRIMARY KEY,
    "price" integer NOT NULL CHECK ("price" >= 0),
    "quantity" smallint NOT NULL CHECK ("quantity" >= 0),
    "created_at" timestamp  NOT NULL,
    "action" int2 NOT NULL,
    "status" int2 NOT NULL,
    "sub_order_id" bigint NULL,
    "symbol_id" bigint NOT NULL,
    "user_id_from" bigint NOT NULL,
    "user_id_to" bigint NULL,

    FOREIGN KEY (symbol_id) REFERENCES mydata.symbol (id),
    FOREIGN KEY (sub_order_id) REFERENCES mydata.orders (id),
    FOREIGN KEY (user_id_from) REFERENCES basic_auth.users (id),
    FOREIGN KEY (user_id_to) REFERENCES basic_auth.users (id),
    FOREIGN KEY ("action") REFERENCES mydata.order_action(id),
    FOREIGN KEY (status) REFERENCES mydata.order_status(id)
    
);
--------------------------------------------------------------------------------------

CREATE TABLE mydata."payment" (
    "id" serial NOT NULL PRIMARY KEY,
    "amount" bigint NOT NULL CHECK ("amount" >= 0),
    "created_at" timestamp  NOT NULL,
    "user_id" bigint NOT NULL ,
    "action" int2 NOT NULL,

    FOREIGN KEY (user_id) REFERENCES basic_auth.users (id),
    FOREIGN KEY ("action") REFERENCES mydata."payment_action" (id)
    
);
--------------------------------------------------------------------------------------

CREATE TABLE mydata."symbol" (
    "id" serial NOT NULL PRIMARY KEY,
    "full_name" varchar(100) NOT NULL,
    "price" integer NOT NULL CHECK ("price" >= 0),
    "volume" integer NOT NULL CHECK ("volume" >= 0),
    "numberOfAllAvailableSymbol" integer NOT NULL CHECK ("numberOfAllAvailableSymbol" >= 0),
    "symbolName" varchar(10) NOT NULL UNIQUE
);

--------------------------------------------------------------------------------------
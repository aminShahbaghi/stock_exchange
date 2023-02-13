CREATE TABLE exchange."symbol" (
    "id" serial NOT NULL PRIMARY KEY,
    "full_name" varchar(100) NOT NULL,
    "price" integer NOT NULL CHECK ("price" >= 0),
    "volume" integer NOT NULL CHECK ("volume" >= 0),
    "numberOfAllAvailableSymbol" integer NOT NULL CHECK ("numberOfAllAvailableSymbol" >= 0),
    "symbolName" varchar(10) NOT NULL UNIQUE
);

CREATE TABLE exchange."order_action" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(10) NOT NULL
    
);

CREATE TABLE exchange."order_status" (
  "id" serial NOT NULL PRIMARY KEY,
  "title" varchar(15) NOT NULL
    
);

CREATE TABLE exchange."orders" (
    "id" serial NOT NULL PRIMARY KEY,
    "price" integer NOT NULL CHECK ("price" >= 0),
    "quantity" smallint NOT NULL CHECK ("quantity" >= 0),
    "created_at" timestamp  NOT NULL,
    "action" exchange.order_action_enum NOT NULL,
	  status exchange.order_status_enum NOT NULL,
    "sub_order_id" bigint NULL,
    "symbol_id" bigint NOT NULL,
    "user_id_from" bigint NOT NULL,
    "user_id_to" bigint NULL,

    FOREIGN KEY (symbol_id) REFERENCES exchange.symbol (id),
    FOREIGN KEY (sub_order_id) REFERENCES exchange.orders (id),
    FOREIGN KEY (user_id_from) REFERENCES basic_auth.users (id),
    FOREIGN KEY (user_id_to) REFERENCES basic_auth.users (id)
);
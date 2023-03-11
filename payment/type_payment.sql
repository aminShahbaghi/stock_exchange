CREATE TYPE payment.payment_action_enum AS ENUM ('DEPOSIT', 'WITHDRAWAL');

----------------------------------------------------------------------------------------------------------------------

ALTER TABLE payment.payment ADD status payment."payment_status_enum" DEFAULT 'PENDING'::payment."payment_status_enum";

CREATE TYPE payment."payment_status_enum" AS ENUM (
	'ACCEPT',
	'REJECT',
	'PENDING');
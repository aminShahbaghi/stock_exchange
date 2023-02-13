ALTER TABLE payment.payment DROP CONSTRAINT payment_action_fkey;
ALTER TABLE payment.payment ALTER COLUMN "action" TYPE text USING "action"::text;

UPDATE payment.payment  
	SET  "action" =  CASE  
                        WHEN "action" = '1' THEN 'DEPOSIT' 
                        WHEN "action" = '2' THEN 'WITHDRAWAL' 
                        ELSE "action"
                    END

ALTER TABLE payment.payment ALTER COLUMN "action" TYPE payment.payment_action_enum USING "action"::payment.payment_action_enum;  
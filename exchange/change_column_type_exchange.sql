ALTER TABLE exchange.orders DROP CONSTRAINT orders_action_fkey;  
ALTER TABLE exchange.orders ALTER COLUMN "action" TYPE text USING "action"::text;

UPDATE exchange.orders  
	SET  "action" =  CASE  
                        WHEN "action" = '1' THEN 'BUY' 
                        WHEN "action" = '2' THEN 'SELL' 
                        ELSE "action"
                    END

ALTER TABLE exchange.orders ALTER COLUMN "action" TYPE exchange.order_action_enum USING "action"::order_action_enum; 
----------------------------------------------------------------------------------------------------------------------

ALTER TABLE exchange.orders DROP CONSTRAINT orders_status_fkey;  
ALTER TABLE exchange.orders ALTER COLUMN status TYPE text USING status::text;

UPDATE exchange.orders  
	SET  status =  CASE  
                        WHEN status = '1' THEN 'BUY_FINISH' 
                        WHEN status = '2' THEN 'SELL_FINISH' 
                        WHEN status = '3' THEN 'BUY_PENDING'
                        WHEN status = '4' THEN 'SELL_PENDING' 
                        WHEN status = '5' THEN 'SELL_FIN_SUB' 
                        WHEN status = '6' THEN 'BUY_FIN_SUB' 
                        ELSE status
                    END

ALTER TABLE exchange.orders ALTER COLUMN status TYPE exchange.order_status_enum USING status::order_status_enum;
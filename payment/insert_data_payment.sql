INSERT INTO payment.payment (amount,created_at,user_id,"action")
	SELECT p.amount,p.created_at,p.user_id,p."action" FROM mydata.payment p;

insert into payment.payment_action
	select * from mydata.payment_action ;
	
SELECT setval(pg_get_serial_sequence('payment.payment', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   payment.payment;

SELECT setval(pg_get_serial_sequence('payment.payment_action', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   payment.payment_action;
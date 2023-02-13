INSERT INTO payment.payment (amount,created_at,user_id,"action")
	SELECT p.amount,p.created_at,p.user_id,p."action" FROM mydata.payment p;

insert into payment.payment_action
	select * from mydata.payment_action ;
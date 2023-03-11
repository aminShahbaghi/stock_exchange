alter table payment.payment  enable row level security;

create policy own_payment on payment.payment 
	using (payment.user_id = basic_auth.return_user_id(current_user::text) or current_user::text = 'op_admin');

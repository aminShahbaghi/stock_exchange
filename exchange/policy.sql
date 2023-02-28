alter table exchange.orders enable row level security;

create policy own_trade on exchange.orders
	using (orders.user_id_from = basic_auth.return_user_id(current_user::text));
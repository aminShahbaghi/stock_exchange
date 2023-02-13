
CREATE OR REPLACE FUNCTION api.login(username text, pass text)
 RETURNS basic_auth.jwt_token
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check username and password
  select basic_auth.user_role(username, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select custom_jwt.sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    from (
      select login.username as role,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;
  return result;
end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.customer_create_acount(pass text, username text, first_name text, last_name text, email text, national_code text, birthday date, phone text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
cmdtext text; rowcount int; role_ text;sh_code text;
begin
	role_='customer';
	sh_code = basic_auth.create_shareholder_code(last_name);

	cmdtext = 'create role '||username||' nologin in role '||role_;-- grant role_ to username
	execute cmdtext;
  
	cmdtext = 'grant '||username||' to authenticator';
	execute cmdtext;

	insert into basic_auth.users("pass","username","first_name","last_name","email","national_code","shareholder_code","birthday","phone","role") values(pass,username,first_name,last_name,email,national_code,sh_code,birthday,phone,role_);
	
	GET DIAGNOSTICS rowcount = ROW_COUNT;
	if(rowcount<1) then
		return json_build_object('msg','Data Not Found');
	else
		return json_build_object('msg','ok');
	end if;

return json_build_object('msg','fail! customer_create_acount()');
end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.create_symbol(full_name text, price integer, volume integer, "numberOfAllAvailableSymbol" integer, "symbolName" text)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
	
	insert into exchange.symbol ("full_name","price","volume","numberOfAllAvailableSymbol","symbolName")
		values (create_symbol.full_name,create_symbol.price,create_symbol.volume,create_symbol."numberOfAllAvailableSymbol",create_symbol."symbolName");
		
	return json_build_object('msg','symbol registered successfully.');
end;
$function$
;
----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.orders(symbol integer, price integer, quantity integer, action_ integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 declare
 	user_id int;
 	uname text;
	res json;
	define_status int2;
	order_ json;
 begin
	 
 	if current_setting('request.jwt.claims', true)::json->>'role' = 'web_anon' then 
		return json_build_object('msg','token required!');
	end if;

	uname := current_setting('request.jwt.claims', true)::json->>'role';


	select id into user_id from basic_auth.users u where u.username = uname;
	if user_id is null then
		return json_build_object ('msg', 'fail!');
	end if;

	res = exchange.validation_order(orders.symbol, orders.price, orders.quantity, orders.action_, user_id );

	if res is not null then 
		return res;
	end if;

	--define status to insert in orders
	if action_=1 then -- 1:BUY
		define_status = 3; --'BUY_PENDING'
	elseif action_=2 then -- 2:SELL
		define_status=4;
	end if;

    with x as(
    insert into exchange.orders("price","quantity","created_at","action","status","symbol_id","user_id_from")
   		values (orders.price,orders.quantity,now(),orders.action_,define_status,symbol,user_id)
   		returning *
	)
	select row_to_json(x.*) into order_ from x;

    res = exchange.find_match_order(order_);
  return res;
 end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.register_payment(amount integer, action_ integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 DECLARE
	uname text;
	user_id int;
	rowcount int;
 begin
	if current_setting('request.jwt.claims', true)::json->>'role' = 'web_anon' then 
		return json_build_object('msg','token required!');
	end if;

	uname := current_setting('request.jwt.claims', true)::json->>'role';

	if uname is null then 
		return json_build_object('msg','fail!');
	end if;
	
 select u.id into user_id from basic_auth.users u where u."username" = uname;
 insert into payment.payment ("amount","created_at","user_id","action") values (register_payment.amount,now(),user_id,register_payment.action_);
 update basic_auth.users set "accountBalance" =  "accountBalance" + register_payment.amount where username = uname ;
 
 GET DIAGNOSTICS rowcount = ROW_COUNT;
	if(rowcount<1) then
		return json_build_object('msg','Data Not Found');
	else
		return json_build_object('msg','ok');
	end if;
	return sh_code;
 end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.retrive_orders(action_ integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 DECLARE
	res json;
 begin
	 --return json_build_object('msg',current_setting('request.method', true));
	if current_setting('request.jwt.claims', true)::json->>'role' = 'web_anon' then 
		return json_build_object('msg','token required!');
	end if;

	
 select array_to_json(array_agg(row_to_json(o.*))) into res from mydata.orders o where o."action" = retrive_orders.action_ ;

 if res is null then 
 	return json_build_object('msg','there is no order!');
 end if;

return res;
 end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION api.show_symbol(id integer DEFAULT '-1'::integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 DECLARE
	res json;

 begin
	
	if id = -1 then 
		select array_to_json(array_agg(row_to_json(s.*))) into res  from mydata.symbol s;
	else 
		select row_to_json(s.*) into res  from mydata.symbol s where s.id = show_symbol.id;
	end if;
	
	if res is null then 
		return json_build_object('msg','symbol not found');
	end if;
	return res;
 end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------

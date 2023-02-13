CREATE OR REPLACE FUNCTION exchange.check_quantity_for_deal(order_sell json, order_buy json)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 declare
	amount int8;
	difference_quantity int;
	define_status int2;
 begin
 	 if CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER) = CAST(check_quantity_for_deal.order_buy->>'quantity' AS INTEGER) then
 	 	
 	 
 	 	update mydata.orders set status = 2 where id=CAST(check_quantity_for_deal.order_sell->>'id' AS INTEGER); -- 2:SELL_FINISH 
 	 	update mydata.orders set status = 1 where id=CAST(check_quantity_for_deal.order_buy->>'id' AS INTEGER); -- 1:BUY_FINISH 
 	 	
 	 	amount = CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER) * CAST(check_quantity_for_deal.order_sell->>'price' AS INTEGER);
 	 
 	 	update basic_auth.users set "accountBalance"="accountBalance"+amount where id=CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER);
 	 	update basic_auth.users set "accountBalance"="accountBalance"-amount where id=CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER);
 	 	
 	 	return json_build_object ('msg', 'transaction done =');
 	 
	elseif CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER) > CAST(check_quantity_for_deal.order_buy->>'quantity' AS INTEGER) then
	
		difference_quantity = CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER) - CAST(check_quantity_for_deal.order_buy->>'quantity' AS INTEGER);
        amount = difference_quantity * CAST(check_quantity_for_deal.order_sell->>'price' AS INTEGER);

        update mydata.orders set status = 5,user_id_to = CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER) where id=CAST(check_quantity_for_deal.order_sell->>'id' AS INTEGER); -- 5:SELL_FIN_SUB
        update mydata.orders set status = 1,user_id_to = CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER) where id=CAST(check_quantity_for_deal.order_buy->>'id' AS INTEGER); -- 1:BUY_FINISH
    
        update basic_auth.users set "accountBalance"="accountBalance" + amount where id=CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER);
 	 	update basic_auth.users set "accountBalance"="accountBalance" - amount where id=CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER);
		
        --4:SELL_PENDING
 	 	--create sub order
        insert into mydata.orders("price","quantity","created_at","action","status","sub_order_id","symbol_id","user_id_from")
   			values (CAST(check_quantity_for_deal.order_sell->>'price' AS INTEGER),difference_quantity,now(),
   					CAST(check_quantity_for_deal.order_sell->>'action' AS INTEGER),4,CAST(check_quantity_for_deal.order_sell->>'id' AS INTEGER),
   					CAST(check_quantity_for_deal.order_sell->>'symbol_id' AS INTEGER),CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER));

        return json_build_object ('msg', 'transaction done >');
     	elseif CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER) < CAST(check_quantity_for_deal.order_buy->>'quantity' AS INTEGER) then
	
		difference_quantity = CAST(check_quantity_for_deal.order_buy->>'quantity' AS INTEGER) - CAST(check_quantity_for_deal.order_sell->>'quantity' AS INTEGER);
        amount = difference_quantity * CAST(check_quantity_for_deal.order_sell->>'price' AS INTEGER);

        update mydata.orders set status = 2,user_id_to = CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER) where id=CAST(check_quantity_for_deal.order_sell->>'id' AS INTEGER); -- 2:SELL_FINISH
        update mydata.orders set status = 6,user_id_to = CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER) where id=CAST(check_quantity_for_deal.order_buy->>'id' AS INTEGER); -- 6:BUY_FIN_SUB
    
        update basic_auth.users set "accountBalance"="accountBalance" + amount where id=CAST(check_quantity_for_deal.order_sell->>'user_id_from' AS INTEGER);
 	 	update basic_auth.users set "accountBalance"="accountBalance" - amount where id=CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER);
		
        --3:BUY_PENDING
 	 	--create sub order
        insert into mydata.orders("price","quantity","created_at","action","status","sub_order_id","symbol_id","user_id_from")
   			values (CAST(check_quantity_for_deal.order_buy->>'price' AS INTEGER),difference_quantity,now(),
   					CAST(check_quantity_for_deal.order_buy->>'action' AS INTEGER),3,CAST(check_quantity_for_deal.order_buy->>'id' AS INTEGER),
   					CAST(check_quantity_for_deal.order_buy->>'symbol_id' AS INTEGER),CAST(check_quantity_for_deal.order_buy->>'user_id_from' AS INTEGER));

        return json_build_object ('msg', 'transaction done <');
 	 end if;
	 return json_build_object ('msg', 'fail! check_quantity_for_deal');

 end;
$function$
;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION exchange.find_match_order(order_ json)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 declare
	order_list json[];
	cnt int2;
	order_buy json;
	order_sell json;
 begin
	  
	 if CAST(find_match_order.order_->>'action' AS INTEGER)=2 then -- 2:SELL     
	    -- status=3:BUY_PENDING
	 	cnt=0;
	 	select count(*) into cnt from mydata.orders o
			    where o.symbol_id=CAST(find_match_order.order_->>'symbol_id' AS INTEGER) and
			   			o.status=3 and o.price=CAST(find_match_order.order_->>'price' AS INTEGER);
		if cnt=0 then 
			return json_build_object ('msg', 'buy pending list is empty');
		end if;
	
	 	select (row_to_json(o.*)) into order_buy from mydata.orders o
	    where o.symbol_id=CAST(find_match_order.order_->>'symbol_id' AS INTEGER) and
	   			o.status=3 and o.price=CAST(find_match_order.order_->>'price' AS INTEGER)
	   	limit 1;
	 
	    return exchange.check_quantity_for_deal(find_match_order.order_, order_buy);

	       
	 elseif  CAST(find_match_order.order_->>'action' AS INTEGER)=1 then -- 1:BUY
	 -- status=4:SELL_PENDING
	 	cnt=0;
	 	select count(*) into cnt from mydata.orders o
			    where o.symbol_id=CAST(find_match_order.order_->>'symbol_id' AS INTEGER) and
			   			o.status=4 and o.price=CAST(find_match_order.order_->>'price' AS INTEGER);
		if cnt=0 then 
			return json_build_object ('msg', 'sell pending list is empty');
		end if;
	
	 	select (row_to_json(o.*)) into order_sell from mydata.orders o
	    where o.symbol_id=CAST(find_match_order.order_->>'symbol_id' AS INTEGER) and
	   			o.status=4 and o.price=CAST(find_match_order.order_->>'price' AS INTEGER)
	   	limit 1;
	 
        return exchange.check_quantity_for_deal(order_sell,find_match_order.order_);
 
	 end if;

 	

  return order_list;
 end;
$function$
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION exchange.validation_order(symbol_id integer, price integer, quantity integer, action_ integer, user_id integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
 declare
 	accountBal int8;
    toatl_quantity_symbol_user int;
   	quantity_symbol_user_sell_pending int;
 begin

	-- validation befor buy 
	if validation_order.action_ = 1 then -- 1:BUY
		select u."accountBalance" into accountBal from basic_auth.users u where u.id = validation_order.user_id;
	  if accountBal < quantity * price then
	     return json_build_object('msg','account_balance is not enough');
 	
	  end if;
	end if;
 
	-- validation before sell
	if validation_order.action_ = 2 then -- 2:SELL
	     select coalesce(sum(o.quantity),0) into toatl_quantity_symbol_user from mydata.orders o
			where o.user_id_from = user_id and o.symbol_id = validation_order.symbol_id and o.status = 1; -- 1:BUY_FINISH
	    if toatl_quantity_symbol_user < validation_order.quantity  then
	        return json_build_object('msg','The number of symbol shares is not enough for sell. you have '||toatl_quantity_symbol_user::text||' shares');
		end if;
	
		select coalesce(sum(o.quantity),0) into quantity_symbol_user_sell_pending from mydata.orders o
			where o.user_id_from = user_id and o.symbol_id = validation_order.symbol_id and o.status = 4; -- 4:SELL_PENDING
		if toatl_quantity_symbol_user < quantity_symbol_user_sell_pending + validation_order.quantity then
		    return json_build_object('msg','some of order in sell queue & enter quantity should be less than '||toatl_quantity_symbol_user::text);
		end if;
	end if;
	
return null;
 end;
$function$
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION exchange.ipo(symbol_name text, number_of_user integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
 DECLARE
	user_list integer [];
	random_user integer [];
	count_of_user integer;
	numberOfAllAvailableSymbol int4;
	price int4;
	number_of_shares integer;
    extra_shares integer;
    user_id integer;
    symbol_id integer;
	money_need bigint;
	extra_money_need bigint;
	i int;
 begin
	
	select ARRAY(select id from basic_auth.users where users."role" = 'customer' order by id) into user_list;

	select array_remove(user_list, 23) into user_list;

    count_of_user = array_length(user_list,1);

    if number_of_user > count_of_user then
        raise exception 'numberOfUser must be smaller than %', count_of_user + 1;
    end if;
	select s."numberOfAllAvailableSymbol",s.price,id into numberOfAllAvailableSymbol,price,symbol_id 
		from mydata.symbol s where s."symbolName" = ipo.symbol_name;
	
    if  numberOfAllAvailableSymbol = 0 then
        raise exception 'IPO is closed';
    end if;
   --select (user_list::text::int[])[1];  --SELECT ('{1,2,5}'::int[])[1];
   --raise exception 'count_of_user %',count_of_user;
    select (user_list::text::int[])[:floor(random() * count_of_user + 1)] into random_user;
    
    --raise exception 'user_list % , random_user %',user_list,random_user; --dateval := '{2015-4-12, 2015-4-19}'::date[];
    
    number_of_shares = numberOfAllAvailableSymbol / array_length(random_user,1);
    extra_shares = numberOfAllAvailableSymbol % array_length(random_user,1);
--raise exception 'number_of_shares % , extra_shares %, numberOfAllAvailableSymbol %, count_of_user%',number_of_shares,extra_shares,numberOfAllAvailableSymbol,count_of_user;
    money_need = number_of_shares * price;
    --raise exception 'money_need % , number_of_shares %, price %',money_need,number_of_shares,price;
    if extra_shares != 0 then
        extra_money_need = extra_shares * price;
    end if;
    --increase accountBalance in user model
   i=0;
    FOREACH user_id in array random_user loop
        --TODO using bulk insert
    	
        if extra_shares != 0 and user_id = random_user[array_length(random_user,1)] then
            money_need = money_need + extra_money_need;
            number_of_shares = number_of_shares + extra_shares;
        end if;
		
		insert into mydata.payment("amount", "created_at", "user_id", "action") values (money_need,NOW(),user_id,1); -- 1 refer to DEPOSIT in mydata.payment_action

		insert into mydata.orders("price","quantity","created_at","action","status","symbol_id","user_id_from","user_id_to")
			values (price,number_of_shares,NOW(),1,1,symbol_id,user_id,23);
        
        insert into mydata.payment("amount", "created_at", "user_id", "action") values (money_need,NOW(),user_id,2); -- 1 refer to WITHDRAWAL in mydata.payment_action
        numberOfAllAvailableSymbol = numberOfAllAvailableSymbol - number_of_shares;	
        update  mydata.symbol set "numberOfAllAvailableSymbol" = numberOfAllAvailableSymbol where id = symbol_id ;
		i = i+1;
	 end loop;
	 return i;
 end;
$function$
;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


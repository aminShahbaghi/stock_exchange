insert into exchange.order_action
	select * from mydata.order_action ;
--ALTER SEQUENCE <tablename>_<id>_seq RESTART WITH 1

SELECT setval(pg_get_serial_sequence('exchange.order_action', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   exchange.order_action;

insert into exchange.order_status
	select * from mydata.order_status ;

SELECT setval(pg_get_serial_sequence('exchange.order_status', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   exchange.order_status;


insert into exchange.orders
	select * from mydata.orders ;

SELECT setval(pg_get_serial_sequence('exchange.orders', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   exchange.orders;

insert into exchange.symbol
	select * from mydata.symbol ;

SELECT setval(pg_get_serial_sequence('exchange.symbol', 'id')
            , COALESCE(max(id) + 1, 1)
            , false)
FROM   exchange.symbol;
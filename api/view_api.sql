CREATE OR REPLACE VIEW api.trade
WITH(security_invoker=on)
AS SELECT o.id,
    o.price,
    o.quantity,
    o.created_at,
    o.action,
    o.status,
    s."symbolName"
   FROM exchange.orders o
     JOIN exchange.symbol s ON o.symbol_id = s.id
   WHERE o.status not in('BUY_PENDING','SELL_PENDING');
----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW api.info_payment_slip
WITH(security_invoker=on)
AS SELECT p.id,
    p.amount,
    p.created_at,
    p.user_id,
    p.action,
    p.status,
    ps.pk_fk_payment_id,
    ps.account_number,
    ps.payment_code,
    ps.shaba_number,
    ps.image_id
   FROM payment.payment p
     JOIN payment.payment_slip ps ON p.id = ps.pk_fk_payment_id;
----------------------------------------------------------------------------------------------------------------------------------------------------------


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
--https://github.com/michelp/pgjwt/blob/master/pgjwt--0.1.1.sql
------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION custom_jwt.algorithm_sign(signables text, secret text, algorithm text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)  -- hmac throws error
SELECT custom_jwt.url_encode(pgcrypto.hmac(signables, secret, alg.id)) FROM alg;
$function$
;

-----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION custom_jwt.sign(payload json, secret text, algorithm text DEFAULT 'HS256'::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
WITH
  header AS (
    SELECT custom_jwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT custom_jwt.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    custom_jwt.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$function$
;

-----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION custom_jwt.url_decode(data text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$function$
;

-----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION custom_jwt.url_encode(data bytea)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$function$
;

-----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION custom_jwt.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text)
 RETURNS TABLE(header json, payload json, valid boolean)
 LANGUAGE sql
 IMMUTABLE
AS $function$
  SELECT
    convert_from(custom_jwt.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(custom_jwt.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = custom_jwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$function$
;

-----------------------------------------------------------------------------------------------------------
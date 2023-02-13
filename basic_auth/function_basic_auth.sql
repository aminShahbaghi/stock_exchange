

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION basic_auth.check_role_exists()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$function$
;
----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION basic_auth.check_token_expire(tok text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
 DECLARE
	jwt_verify JSON;
	jwt_expire BIGINT;
 begin
	select row_to_json(t.*) into jwt_verify  from custom_jwt.verify(tok, 'secret') t;--current_setting('app.jwt_secret')
	if cast(jwt_verify->'valid' as text)::boolean != true then 
		return false ;-- token is not valid
	end if;
	jwt_expire := cast(jwt_verify->'payload'->>'exp' as integer);
 IF jwt_expire > EXTRACT(EPOCH FROM NOW()) THEN
	RETURN true;
 ELSE
	RETURN false ; --token has expired 
 END IF;
 END;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION basic_auth.create_shareholder_code(last_name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
 DECLARE
	sh_code text;
	is_sh_code_exist boolean;
	
 begin
	
	is_sh_code_exist = false;
	select CONCAT (SUBSTR(last_name,1,'3'),floor(random() * 90000 + 10000)::int::text) into sh_code;--floor(random()* (high-low + 1) + low);::int;
	select true into is_sh_code_exist from basic_auth.users where shareholder_code = sh_code;

	while not is_sh_code_exist loop
		select CONCAT (SUBSTR(last_name,1,'3'),floor(random() * 90000 + 10000)::int::text) into sh_code;
		select true into is_sh_code_exist from basic_auth.users where shareholder_code = sh_code;
	end loop;

	return sh_code;
 end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION basic_auth.drop_role_before_del()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
	cmdtext text;
BEGIN
	cmdtext = 'drop role '||old.username;-- grant role_ to username
	execute cmdtext;

	RETURN NULL;
END;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION basic_auth.encrypt_pass()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = pgcrypto.crypt(new.pass, pgcrypto.gen_salt('bf'));
  end if;
  return new;
end
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION basic_auth.user_role(username text, pass text)
 RETURNS name
 LANGUAGE plpgsql
AS $function$
begin
  return (
  select role from basic_auth.users
   where users.username = user_role.username
     and users.pass = pgcrypto.crypt(user_role.pass, users.pass)
  );
end;
$function$
;

----------------------------------------------------------------------------------------------------------------------------------------------------------

drop trigger if exists ensure_user_role_exists on basic_auth.users;
create constraint trigger ensure_user_role_exists
  after insert or update on basic_auth.users
  for each row
  execute procedure basic_auth.check_role_exists();

--------------------------------------------------------------------------

drop trigger if exists encrypt_pass on basic_auth.users;
create trigger encrypt_pass
  before insert or update on basic_auth.users
  for each row
  execute procedure basic_auth.encrypt_pass();
  
---------------------------------------------------------------------------

create trigger role_delete_trigger before
delete
    on
    basic_auth.users for each row
	execute function basic_auth.drop_role_before_del()
--------------------------------------------------------------------------

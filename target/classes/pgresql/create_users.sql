/* code block start */
do $$
declare
    _dbname text := current_database();
begin
    if _dbname != 'any' then
        raise exception 'not in "any" database';
    end if;

/* 0000.02 */
raise notice 'creating user "navetl"';
if exists (select * from pg_catalog.pg_roles as a where a.rolname = 'navetl') then
    raise notice '"navetl" user already exists';
else
    create user navetl with encrypted password '<removed>';
    raise notice '"navetl" user created';
end if;

raise notice 'update rigths for user "navetl"';
grant connect on database any to navetl;
grant usage on schema nav to navetl;
grant select, insert, update, delete, truncate, references, trigger on all tables in schema nav to navetl;
grant execute on all functions in schema nav to navetl;
grant usage, select, update on all sequences in schema nav to navetl;
alter default privileges for user navetl in schema nav grant select, insert, update, delete, truncate, references, trigger on tables to navetl;
alter default privileges for user navetl in schema nav grant execute on functions to navetl;
alter default privileges for user navetl in schema nav grant usage, select, update on sequences to navetl;
alter default privileges for user navetl in schema nav grant usage on types to navetl;
raise notice '************************************';

/* code block ending*/
end;
$$ language plpgsql;
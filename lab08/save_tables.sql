drop function if exists save_tables();
create function save_tables()
returns void
as $$
declare
   v_suffix      varchar(50);
   v_create_cmd  varchar(100);
   c  cursor for select table_name
                 from information_schema.tables
                 where table_schema = current_schema()
                   and table_name not like '%' || v_suffix;
begin
  select '_save_' || to_char(current_date, 'YYMMDD')
  into v_suffix;
  for fetched_row in c
  loop
    v_create_cmd := 'create table ' || fetched_row.table_name || v_suffix
                    || ' as select * from ' || fetched_row.table_name;
    execute v_create_cmd;
  end loop;
end;
$$ language plpgsql;

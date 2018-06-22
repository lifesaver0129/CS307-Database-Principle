
declare
    c cursor for select * from people;
    existence int; 
begin
    select case 
                when exists(select 1 from people
                            where peopleid = pid1)
                    and 
                    exists(select 1 from people
                            where peopleid = pid2)
                then 1
                else 0
            end into existence
    from people;
    if existence = 0 
    then
        raise exception 'pid doesn''t exist';
    end if;
    if pid1 = pid2
    then
        raise exception 'two pid is equal';
    end if;
end;

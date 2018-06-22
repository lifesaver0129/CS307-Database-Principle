create function arrival_time(depar_time varchar, flight_time int, time_zone_d int)
    returns varchar
    as $$
    declare
    hour int;
    hour_re varchar;
    minute int;
    minute_re varchar;
    flag int;
    return_value varchar;
    begin
    hour := cast(substring (depar_time, 1,2)as int);
    minute := cast(substring (depar_time, 4,5)as int) + flight_time + time_zone_d;
    if minute >60 then hour := hour + trunc(minute /60);
    minute := minute - 60 * trunc(minute/60);
    end if;
    if hour >48 then flag := 2;
    hour :=hour-48;
    elsif hour >24 then flag := 1;
    hour :=hour-24;
    elsif hour <0 then flag := -1;
    hour :=hour+24;
    elsif hour <10 then flag := 0;
    end if;
    if hour <10 then hour_re ='0'||hour;
    else hour_re = hour;
    end if;
    if minute <10 then minute_re = '0'||minute;
    else minute_re:=minute;
    end if;
    if flag = 2 then return_value := hour_re||':'||minute_re||'+2';
    elsif flag = 1 then return_value := hour_re||':'||minute_re||'+1';
    elsif flag = -1 then return_value := hour_re||':'||minute_re||'-1';
    else return_value :=hour_re||':'||minute_re;
    end if;
    return return_value;
    end; 
    $$ language plpgsql
    ;;
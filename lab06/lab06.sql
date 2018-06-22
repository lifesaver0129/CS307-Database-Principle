create table if not exists fix(peopleid    int not null,
                 ok_peopleid int not null,
                 first_name  varchar(30),
                 surname     varchar(30) not null);
       
insert into fix(peopleid, ok_peopleid, first_name, surname)
select p.peopleid, x.ok_peopleid, p.first_name, p.surname
from (select max(peopleid) as ok_peopleid,
             trim(coalesce(first_name, ' ')) as first_name,
             trim(surname) as surname,born
      from people
      group by trim(coalesce(first_name, ' ')),trim(surname)
      having count(*) > 1) x
     join people p
       on trim(coalesce(p.first_name, ' ')) = x.first_name
      and  trim(p.surname) = x.surname
      and p.peopleid <> x.ok_peopleid
      and p.born = x.born;

create table if not exists fix2(movieid2 int not null,peopleid2 int not null,credited_as  char(1) not null);
INSERT INTO fix2 SELECT * FROM credits;

update fix2 set peopleid2 = (select fix.ok_peopleid  from fix where peopleid2 = fix.peopleid)
where peopleid2 in (select fix.peopleid from fix );

delete from credits;
INSERT INTO credits SELECT distinct *  FROM fix2;

delete from people where peopleid in (select fix.peopleid from fix);
update people set first_name = trim(coalesce(first_name, ' ')), surname = trim(surname)
where peopleid in (select fix.ok_peopleid from fix);

drop table fix;
drop table fix2;

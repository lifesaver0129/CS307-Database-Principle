-- Create a work table to identify what has to be fixed
create table fix(peopleid    int not null,
                 ok_peopleid int not null,
                 first_name  varchar(30),
                 surname     varchar(30) not null);
-- Populate it
insert into fix(peopleid, ok_peopleid, first_name, surname)
select p.peopleid, x.ok_peopleid, p.first_name, p.surname
from (select max(peopleid) as ok_peopleid,
             trim(coalesce(first_name, ' ')) as first_name,
             trim(surname) as surname
      from people
      group by trim(coalesce(first_name, ' ')),trim(surname)
      having count(*) > 1) x
     join people p
       on trim(coalesce(p.first_name, ' ')) = x.first_name
      and  trim(p.surname) = x.surname
      and p.peopleid <> x.ok_peopleid
;       
-- We may find two versions of the same guy associated
-- with a single film
--
-- It would be easier to store the "rowid" (row address) of
-- rows to delete but I haven't talked about it.
--
create table multiple_credits (movieid, peopleid, credited_as)
;
-- Populate it
insert into multiple_credits(movieid, peopleid, credited_as)
select c.movieid, c.peopleid, c.credited_as
from credits c
     join fix f
       on f.peopleid = c.peopleid
where exists (select null
              from credits c2
              where c2.movieid = c.movieid
                and c2.credited_as = c.credited_as
                and c2.peopleid = f.ok_peopleid)
; 
delete from credits
where (movieid, peopleid, credited_as) in
     (select movieid, peopleid, credited_as
      from multiple_credits)
;
-- Done with that
drop table multiple_credits
;
-- Should no longer violate any constraint
update credits
set peopleid = (select ok_peopleid
                from fix
                where fix.peopleid = credits.peopleid)
where peopleid in -- Important!
      (select peopleid from fix)
; 
-- Now we can delete those people
delete from people where peopleid in (select peopleid from fix)
;
-- ... and we can fix names (not sure that the one we deleted were
-- the ones with spaces)
update people set first_name = trim(first_name),
       surname = trim(surname)
-- No "where" condition, we may have a wrong first name and no
-- people to merge
;
-- '' and NULL is the same only with Oracle (they can't know that)
-- May have been messed up by previous operations.
update people set first_name = null
where length(first_name) = 0
;
-- Cleanup
drop table fix
;

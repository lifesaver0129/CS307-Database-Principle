--
-- Procedures used for importing my film database
-- Lists of people, separated by ;
--
--  Usage:
--    select add_movie('Hong Gao Liang', 'cn', 1987, 'Zhang,Yimou',
--                     'Teng,Rujun;Gong,Li;Jiang,Wen');
--
drop function if exists add_movie();
drop function if exists add_credits();
--
--
-- Procedures for inserting new movies
--
create or replace function add_credits
          (p_movieid    int,
           p_name_list  varchar,
           p_role       char)
returns void
as $$
declare
  n_count     int;
  n_rowcount  int;
begin
  if length(trim(coalesce(p_name_list, ''))) > 0
  then
    --
    --  Count how many names we have in the list by counting
    --  the number of semi-colons and adding one
    --
    n_count := 1 + length(p_name_list)
                 - length(replace(p_name_list, ';', ''));
    --
    insert into credits(movieid, peopleid, credited_as)
    select p_movieid, candidate.peopleid, p_role
    from (select p1.peopleid,
                 count(*)
                     over (partition by provided.surname,
                                        coalesce(provided.first_name, '')) cnt
          from people p1
               inner join
                 (select case array_length(full_name, 1)
                           when 1 then null
                           else full_name[2]
                         end first_name,
                         full_name[1] surname
                  from (select string_to_array(people, ',') full_name
                        from (select unnest(string_to_array(p_name_list, ';'))
                                                 people) x) y) provided
                  on provided.surname = p1.surname
                 and ((provided.first_name is null
                      and not exists (select null
                                      from people p2
                                      where p2.surname = provided.surname
                                      and p2.first_name is null))
                      or (p1.first_name is null
                          and provided.first_name is null)
                      or p1.first_name like provided.first_name || '%')
          where provided.first_name is null
             or not exists
                -- We accept an approximate match on the first name only if
                -- there is no exact match
                -- UNLESS the first name that is provided is null AND
                -- there is somebody without first name that matches
                (select null
                 from people p2
                 where p2.surname = provided.surname
                   and p2.first_name = provided.first_name
                   and p2.first_name <> p1.first_name)) candidate
    where candidate.cnt = 1; -- Only if we find a single match (no ambiguity)
    --
    get diagnostics n_rowcount = ROW_COUNT;
    if n_rowcount <> n_count
    then
      --
      -- We haven't inserted the number of persons expected.
      -- Either some person wasn't found, or the name
      -- was ambiguous.
      --
      -- We could run queries (as complicated as the one above)
      -- to determine what happened exactly (in fact, we can even
      -- have both cases) but it would be much trouble for little
      -- result.
      --
      -- Let's return a generic error
      --
      raise exception 'Failure to insert credits';
    end if;
  end if;
  return;
end;
$$ language plpgsql;
--
create or replace function add_movie
           (p_title        varchar,
            p_country      char(2),
            p_year         int,
            p_directed_by  varchar,
            p_starring     varchar)
returns void
as $$
declare
  n_movieid   int;
begin
  --
  insert into movies(title, country, year_released)
  values (p_title, lower(p_country), p_year);
  n_movieid := lastval();
  if p_directed_by is not null
  then
    perform add_credits(n_movieid, p_directed_by, 'D');
  end if;
  if p_starring is not null
  then
    perform add_credits(n_movieid, p_starring, 'A');
  end if;
  return;
end;
$$ language plpgsql;

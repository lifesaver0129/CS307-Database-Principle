create or replace function movie_registration
           (p_title        varchar,
            p_country_name varchar,
            p_year         int,
            p_director_fn  varchar,
            p_director_sn  varchar,
            p_actor1_fn    varchar,
            p_actor1_sn    varchar,
            p_actor2_fn    varchar,
            p_actor2_sn    varchar)
returns void
as $$
declare
  n_rowcount  int;
  n_movieid   int;
  n_people    int;
begin
  insert into movies(title, country, year_released)
  select p_title, country_code, p_year
  from countries
  where country_name = p_country_name;
  get diagnostics n_rowcount = ROW_COUNT;
  if n_rowcount = 0
  then
    raise exception 'country not found in table COUNTRIES';
  end if;
  n_movieid := lastval();
  select count(surname)
  into n_people
  from (select p_director_sn as surname
        union all
        select p_actor1_sn as surname
        union all
        select p_actor2_sn as surname) specified_people
  where surname is not null;
  --
  -- Get people identifiers and insert into table credits 
  --
  insert into credits(movieid, peopleid, credited_as)
  select n_movieid, people.peopleid, provided.credited_as
  from (select coalesce(p_director_fn, '*') as first_name,
               p_director_sn as surname,
               'D' as credited_as
        union all
        select coalesce(p_actor1_fn, '*') as first_name,
               p_actor1_sn as surname,
               'A' as credited_as
        union all
        select coalesce(p_actor2_fn, '*') as first_name,
               p_actor2_sn as surname,
               'A' as credited_as) provided
       inner join people
         on people.surname = provided.surname
        and coalesce(people.first_name, '*') = provided.first_name
  where provided.surname is not null;
  get diagnostics n_rowcount = ROW_COUNT;
  if n_rowcount != n_people
  then
    raise exception 'Some people couldn''t be found';
  end if;
end;
$$ language plpgsql;
//
insert into people
select * from public.people where surname in ('Chaplin','Goddard') 
//
select movie_registration('Modern Times',
                          'United States', 1936,
                          'Charlie', 'Chaplin',
                          'Charlie', 'Chaplin',
                          'Paulette', 'Goddard');

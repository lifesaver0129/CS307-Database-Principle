 select p.first_name, p.surname
 from (select  c.movieid       
    from people p            
    join credits c  on c.peopleid = p.peopleid  
    where c.credited_as = 'D'         
    and p.first_name = 'Alfred'
    and p.surname = 'Hitchcock') ow_films 
join credits c on c.movieid = ow_films.movieid       
and c.credited_as = 'A' 
join people p  on p.peopleid = c.peopleid
group by p.peopleid
order by count(*) desc
limit 1
     
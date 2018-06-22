select p.first_name, p.surname, m.title, m.year_released
from (select peopleid
from credits 
where credited_as = 'A'
group by peopleid
) sele
join credits c on c.peopleid = sele.peopleid
join people p on p.peopleid =c.peopleid
join movies m on m.movieid = c.movieid
where c.credited_as = 'D' 
group by c.peopleid
having count (c.movieid)=1
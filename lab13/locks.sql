select l.locktype,
       t.relname table_name,
       case l.locktype
         when 'page' then cast(l.page as text)
         when 'tuple' then cast(l.tuple as text)
         when 'transactionid' then cast(l.transactionid as text)
         else null
        end as id,
        a.usename username,
        a.pid,
        current_timestamp - a.xact_start as duration,
        case 
          when l.granted then 'HOLDING '|| l.mode
          else '   WAITING ' || l.mode
        end as status
from pg_locks l
     join (select pl.pid
           from pg_locks pl
           where pl.transactionid
              in (select transactionid 
                  from pg_locks 
                   where not granted)) pb
       on pb.pid = l.pid
     join pg_stat_activity a
       on a.pid = l.pid
     left join pg_class t
       on t.oid = l.relation
where (coalesce(l.database,0) = 0
       or l.database = (select oid
                        from pg_database
                        where datname = current_database()))
  and coalesce(t.relkind, 'r') = 'r'
  and l.locktype in ('relation', 'page', 'tuple', 'transactionid') 
 order by locktype, id, case when l.granted then 1 else 2 end
;

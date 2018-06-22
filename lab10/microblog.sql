drop view if exists public.following;
drop view if exists public.my_thoughts;
drop view if exists public.microblog;
drop table if exists thoughts;
drop table if exists followers;
create sequence thought_id;
grant usage on thought_id to public;
create table thoughts(id       int primary key
                               default nextval('thought_id'),
                      thought  varchar(200) not null,
                      author   varchar(50) not null
                               default current_user,
                      posted   timestamp
                               default current_timestamp);
create index thoughts_idx on thoughts(author);
create table followers(username  varchar(50) not null default current_user,
                       follows   varchar(50) not null,
                       constraint followers_pk
                                  primary key (username, follows));
create view public.microblog
as select author, thought, posted
from thoughts
where author = current_user
   or author in (select follows
                 from followers
                 where username = current_user)
;
grant select on public.microblog to public;
create view public.my_thoughts
as select id, thought, posted
   from thoughts
   where author = current_user;
grant select, insert, update, delete on public.my_thoughts to public; 
create view public.following
as select follows as username
   from followers
   where username = current_user;
grant select, insert, delete on public.following to public; 

                        

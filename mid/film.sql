    CREATE TABLE alt_titles 
    (titleid integer not null primary key, movieid int, title varchar(250) not null, 
        unique(movieid, title), foreign key (movieid) references movies(movieid) on delete cascade)

    CREATE TABLE countries
    (country_code char(2) not null constraint "country code length" check(length(country_code)<=2), 
        country_name varchar(50) not null constraint "country name length" check(length(country_name)<=50), 
        continent varchar(20) not null constraint "continent length" check(length(continent)<=20), 
        primary key(country_code), unique(country_name))

    CREATE TABLE credits
    (movieid int not null, 
        peopleid int not null, 
        credited_as char(1) not null constraint "credited_as length" check(length(credited_as)=1), 
        primary key(movieid, peopleid, credited_as), 
        foreign key(movieid) references movies(movieid), 
        foreign key(peopleid) references people(peopleid))

    CREATE TABLE films_francais 
    (titre varchar(100) not null, 
        annee int not null, 
        primary key(titre, annee))

    CREATE TABLE forum_members 
    (memberid int not null primary key, 
        name varchar(30) not null, 
        registered date not null, 
        unique(name))

    CREATE TABLE forum_posts 
    (topicid int not null, 
        postid int not null, 
        post_date datetime not null, 
        memberid int not null, 
        ancestry varchar(1000), 
        message text not null, 
        primary key (postid), 
        foreign key (memberid) references forum_members(memberid), 
        foreign key (topicid) references forum_topics(topicid))

    CREATE TABLE forum_topics 
    (topicid int not null primary key, 
        post_date datetime not null, 
        memberid int not null, 
        message text not null, 
        foreign key (memberid) 
        references forum_members(memberid))

    CREATE TABLE movie_title_ft_index2 
    (title_word varchar(50) not null, 
        movieid int not null, 
        titleid int default 1 not null, 
        primary key(title_word, movieid, titleid), 
        foreign key (movieid) references movies(movieid) on delete cascade, 
        foreign key(titleid) references alt_titles(titleid))

    CREATE TABLE movies
    (movieid integer not null primary key, 
        title varchar(100) not null constraint "title length" check(length(title)<=100), 
        country char(2) not null constraint "country length" check(length(country)<=2), 
        year_released int not null constraint "year_released numerical" check(year_released+0=year_released), 
        unique(title, country, year_released), 
        foreign key(country) references countries(country_code))

    CREATE TABLE people
    (peopleid integer not null primary key, 
        first_name varchar(30) null constraint "first_name length" check(length(first_name)<=30), 
        surname varchar(30) not null constraint "surname length" check(length(surname)<=30), 
        born int not null constraint "born numerical" check(born+0=born), 
        died int null constraint "died numerical" check(died+0=died), 
        unique(surname, first_name))






DECLARE people_rowcount INT;
BEGIN

  --check if pid1 = pid2
  IF pid1 = pid2
  THEN
    RAISE EXCEPTION 'pid1 can not equals pid2';
  END IF;

  -- check pid1 exit
  CREATE VIEW check_pid1 AS
    SELECT *
    FROM people;
    --WHERE people.peopleid = pid1;
  GET DIAGNOSTICS people_rowcount = ROW_COUNT;
  IF people_rowcount = 0
  THEN RAISE EXCEPTION 'pid1 not exist';
  END IF;

  -- check pid2 exist
  CREATE VIEW check_pid2 AS
    SELECT *
    FROM people
    WHERE people.peopleid = pid2;
  GET DIAGNOSTICS people_rowcount = ROW_COUNT;
  IF people_rowcount = 0
  THEN RAISE EXCEPTION 'pid2 not exist';
  END IF;


  CREATE VIEW insert_credits AS
    SELECT DISTINCT
      movieid,
      CASE peopleid
      WHEN pid2
        THEN pid1 END AS peopleid,
      credited_as
    FROM credits
    WHERE peopleid = pid2 OR peopleid = pid1;

  DELETE FROM credits
  WHERE peopleid = pid1
        OR peopleid = pid2;

  INSERT INTO credits (movieid, peopleid, credited_as) SELECT *
                                                       FROM insert_credits;

  DELETE FROM people
  WHERE peopleid = pid2;

  DROP VIEW insert_credits;
  DROP VIEW check_pid1;
  DROP VIEW check_pid2;

END;

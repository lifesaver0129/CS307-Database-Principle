DROP FUNCTION IF EXISTS merge_people(pid1 INT, pid2 INT );
CREATE FUNCTION merge_people(pid1 INT, pid2 INT)
  RETURNS VOID
AS $$
BEGIN
  IF pid1 = pid2
  THEN RAISE EXCEPTION 'pids are equal';
  END IF;
  IF NOT exists(SELECT NULL
                FROM people_save_171129
                WHERE peopleid = pid1)
  THEN RAISE EXCEPTION 'pid1 not existed';
  END IF;
  IF NOT exists(SELECT NULL
                FROM people_save_171129
                WHERE peopleid = pid2)
  THEN RAISE EXCEPTION 'pid2 not existed';
  END IF;
  CREATE TABLE fix (
    movieid     INT,
    peopleid    INT,
    credited_as VARCHAR(2)
  );
  INSERT INTO fix (movieid, peopleid, credited_as)
    SELECT
      movieid,
      peopleid,
      credited_as
    FROM credits_save_171129
    WHERE pid2 = peopleid;
  DELETE FROM credits_save_171129
  WHERE (movieid, peopleid, credited_as) IN
        (SELECT
           movieid,
           peopleid,
           credited_as
         FROM fix);
  UPDATE credits_save_171129
  SET peopleid = pid1
  WHERE peopleid = pid2;
  DELETE FROM people_save_171129
  WHERE peopleid = pid2;
  DROP TABLE fix;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS people_trg ON people;
DROP TABLE if EXISTS people_audit;
CREATE TABLE people_audit (
  auditid        SERIAL,
  peopleid       INT NOT NULL,
  type_of_change CHAR(1),
  changes        JSON,
  changed_by     VARCHAR(100),
  time_changed   TIMESTAMP
);
CREATE OR REPLACE FUNCTION people_audit_fn()
  RETURNS TRIGGER
AS
$$
BEGIN
  IF tg_op = 'UPDATE'
  THEN
    INSERT INTO people_audit (peopleid ,
                              type_of_change,
                              changes,
                              changed_by,
                              time_changed)
      SELECT
        peopleid,
        'U',
        cast('{' || string_agg('"' || column_name || '":[' || old_value || ',' || new_value || ']', ',') || '}' AS
             JSON),
        current_user || '@'
        || coalesce(cast(inet_client_addr() AS VARCHAR),
                    'localhost'),
        current_timestamp
      FROM (SELECT
              old.peopleid,
              'first_name'                          column_name,
              CASE WHEN
                old.first_name IS NULL
                THEN 'null'
              ELSE '"' || old.first_name || '"' END old_value,
              CASE WHEN
                new.first_name IS NULL
                THEN 'null'
              ELSE '"' || new.first_name || '"' END new_value
            WHERE coalesce(old.first_name, '*') <> coalesce(new.first_name, '*')
            UNION ALL
            SELECT
              old.peopleid,
              'surname'   column_name,
              '"'||old.surname||'"' old_value,
              '"'||new.surname||'"' new_value
            WHERE old.surname <> new.surname
            UNION ALL
            SELECT
              old.peopleid,
              'born'                    column_name,
              cast(old.born AS VARCHAR) old_value,
              cast(new.born AS VARCHAR) new_value
            WHERE old.born <> new.born
            UNION ALL
            SELECT
              old.peopleid,
              'died'                             column_name,
              CASE WHEN
                old.died IS NULL
                THEN 'null'
              ELSE cast(old.died AS VARCHAR) END old_value,
              CASE WHEN
                new.died IS NULL
                THEN 'null'
              ELSE cast(new.died AS VARCHAR) END new_value
            WHERE coalesce(old.died, -1) <> coalesce(new.died, -1)) modified
    GROUP BY peopleid;
  ELSIF tg_op = 'INSERT'
    THEN
      INSERT INTO people_audit (peopleid,
                                type_of_change,
                                changes,
                                changed_by,
                                time_changed)
        SELECT
          peopleid,
          'I',
          cast('{' || string_agg('"' || column_name || '":[' || new_value || ']', ',') || '}' AS
               JSON),
          current_user || '@'
          || coalesce(cast(inet_client_addr() AS VARCHAR),
                      'localhost'),
          current_timestamp
        FROM (SELECT
                new.peopleid,
                'first_name'                          column_name,
                CASE WHEN
                  new.first_name IS NULL
                  THEN 'null'
                ELSE '"' || new.first_name || '"' END new_value
              UNION ALL
              SELECT
                new.peopleid,
                'surname'   column_name,
                '"'||new.surname||'"' new_value
              UNION ALL
              SELECT
                new.peopleid,
                'born'                    column_name,
                cast(new.born AS VARCHAR) new_value
              UNION ALL
              SELECT
                new.peopleid,
                'died'                             column_name,

                CASE WHEN
                  new.died IS NULL
                  THEN 'null'
                ELSE cast(new.died AS VARCHAR) END new_value) inserted
      GROUP BY peopleid;
  ELSE
    INSERT INTO people_audit (peopleid,
                              type_of_change,
                              changes,
                              changed_by,
                              time_changed)
      SELECT
        peopleid,
        'D',
        cast('{' || string_agg('"' || column_name || '":[' || old_value || ']', ',') || '}' AS
             JSON),
        current_user || '@'
        || coalesce(cast(inet_client_addr() AS VARCHAR),
                    'localhost'),
        current_timestamp
      FROM (SELECT
              old.peopleid,
              'first_name'   column_name,
              CASE WHEN
                old.first_name IS NULL
                THEN 'null'
              ELSE '"' || old.first_name || '"' END old_value
            UNION ALL
            SELECT
              old.peopleid,
              'surname'   column_name,
              '"'||old.surname||'"' old_value
            UNION ALL
            SELECT
              old.peopleid,
              'born'                    column_name,
              cast(old.born AS VARCHAR) old_value
            UNION ALL
            SELECT
              old.peopleid,
              'died'                    column_name,
              CASE WHEN
                old.died IS NULL
                THEN 'null'
              ELSE cast(old.died AS VARCHAR) END old_value) deleted
    GROUP BY peopleid;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER people_trg
AFTER INSERT OR UPDATE OR DELETE ON people
FOR EACH ROW
EXECUTE PROCEDURE people_audit_fn();
--
INSERT INTO people (first_name, surname, born)
VALUES ('Ryan', 'Gosling', 1980);
INSERT INTO people (first_name, surname, born)
VALUES ('George', 'Clooney', 1961);
INSERT INTO people (first_name, surname, born)
VALUES ('Frank', 'Capra', 1897);
UPDATE people
SET died = 1991
WHERE first_name = 'Frank'
      AND surname = 'Capra';
DELETE FROM people
WHERE first_name = 'Ryan'
      AND surname = 'Gosling';
SELECT *
FROM people_audit;
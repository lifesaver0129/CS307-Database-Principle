SELECT CASE ordinal_position
       WHEN 1
         THEN 'create table' || table_name || '('
       ELSE '    '
       END || column_name || ' ' || CASE data_type
                                    WHEN 'integer'
                                      THEN CASE is_identity
                                           WHEN 'YES'
                                             THEN 'integer primary key'
                                           ELSE 'int' || CASE is_nullable
                                                         WHEN 'NO'
                                                           THEN 'not null'
                                                         ELSE '' END ||
                                                CASE coalesce(length(column_default), 0)
                                                WHEN 0
                                                  THEN ''
                                                ELSE ' defalt' || column_default
                                                END || 'constraint' || table_name || '_' || column_name
                                                || '_num check(' || column_name || '-' || column_name || '+0)'
                                           END
                                    WHEN 'character'
                                      THEN
                                        'char(' || cast(character_maximum_length AS VARCHAR) || ')' || CASE is_nullable
                                                                                                       WHEN 'NO'
                                                                                                         THEN ' not null'
                                                                                                       ELSE ' '
                                                                                                       END ||
                                        CASE coalesce(length(column_default), 0)
                                        WHEN 0
                                          THEN ''
                                        ELSE ' default ' || column_default || '' END ||
                                        'constraint' || table_name || '_' || column_name || '_char check (length(' ||
                                        column_name || ')<=' || cast(character_maximum_length AS VARCHAR) || ')'
                                    WHEN 'character varying'
                                      THEN 'varchar(' || cast(character_maximum_length AS VARCHAR) || ')' ||
                                           CASE is_nullable
                                           WHEN 'NO'
                                             THEN 'not null'
                                           ELSE '' END || CASE coalesce(length(column_default), 0)
                                                          WHEN 0
                                                            THEN ''
                                                          ELSE 'default ''' || column_default || '''' END ||
                                           'constraint ' || table_name || '_' || column_name ||
                                           '_varchar check (length(' || column_name || ')<=' ||
                                           cast(character_maximum_length AS VARCHAR) || ')'
                                    ELSE data_type
                                    END || CASE WHEN ordinal_position = col_cnt
  THEN ');'
                                           ELSE ',' END AS sql
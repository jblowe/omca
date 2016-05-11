-- nb: this query assume it will take a timestamp and output a string
SELECT DISTINCT cc.id AS id, STRING_AGG(to_char(grp.FIELD, 'YYYY-MM-DD'), '␥') AS FIELD_ss
FROM XTABLE cc
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')
JOIN hierarchy h ON (h.parentid=cc.id AND h.primarytype='FIELDGroup')
JOIN FIELDgroup grp ON (grp.id=h.id)
WHERE grp.FIELD IS NOT NULL
GROUP BY cc.id

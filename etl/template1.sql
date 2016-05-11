-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, STRING_AGG(regexp_replace(regexp_replace(grp.FIELD, '^.*\)''(.*)''$', '\1'), E'[\\t\\n\\r]+', ' ', 'g'), '␥') AS FIELD_ss
FROM XTABLE cc
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')
JOIN hierarchy h ON (h.parentid=cc.id AND h.primarytype='FIELDGroup')
JOIN FIELDgroup grp ON (grp.id=h.id)
WHERE grp.FIELD IS NOT NULL
GROUP BY cc.id

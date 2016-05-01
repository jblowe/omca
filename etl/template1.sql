SELECT DISTINCT cc.id AS id, STRING_AGG(regexp_replace(grp.FIELD, '^.*\)''(.*)''$', '\1'), '␥') AS FIELD_ss
FROM XTABLE cc
JOIN hierarchy h ON (h.parentid=cc.id AND h.primarytype='FIELDGroup')
JOIN FIELDgroup grp ON (grp.id=h.id)
WHERE grp.FIELD IS NOT NULL
GROUP BY cc.id

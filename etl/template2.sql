SELECT DISTINCT cc.id AS id, STRING_AGG(regexp_replace(x.item, '^.*\)''(.*)''$', '\1'), '␥') AS FIELD_ss
FROM XTABLE cc
JOIN XTABLE_FIELD x ON (x.id=cc.id)
WHERE x.item IS NOT NULL
GROUP BY cc.id

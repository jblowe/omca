-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, STRING_AGG(regexp_replace(regexp_replace(x.item, '^.*\)''(.*)''$', '\1'), E'[\\t\\n\\r]+', ' ', 'g'), '␥') AS FIELD_ss
FROM XTABLE cc
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')
JOIN XTABLE_FIELD x ON (x.id=cc.id)
WHERE x.item IS NOT NULL
GROUP BY cc.id

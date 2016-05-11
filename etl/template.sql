-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, regexp_replace(STRING_AGG(regexp_replace(grp.FIELD, '^.*\)''(.*)''$', '\1'), E'[\\t\\n\\r]+', ' ', 'g'), '␥') AS FIELD_ss
FROM collectionobjects_common cc
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')
JOIN hierarchy h ON (h.parentid=cc.id AND h.primarytype='FIELDGroup')
JOIN FIELDgroup grp ON (grp.id=h.id)
WHERE grp.FIELD IS NOT NULL
GROUP BY cc.id

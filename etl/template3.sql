SELECT cc.id AS id, regexp_replace(x.FIELD, '^.*\)''(.*)''$', '\1') AS FIELD_s
FROM collectionobjects_common cc
JOIN XTABLE x ON (x.id=cc.id)
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')

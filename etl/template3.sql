SELECT cc.id AS id, STRING_AGG(DISTINCT regexp_replace(x.FIELD, '^.*\)''(.*)''$', '\1'), '␥') AS FIELD_ss
FROM XTABLE_common x 
  JOIN misc m on (m.id = x.id AND m.lifecyclestate <> 'deleted')
  JOIN hierarchy h1 ON (x.id = h1.id)
  --JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'XTABLE')
  JOIN relations_common rc ON (h1.name = rc.subjectcsid)
  JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
  LEFT OUTER JOIN collectionobjects_common cc ON (h2.id=cc.id)
  JOIN misc m2 on (m2.id = cc.id AND m2.lifecyclestate <> 'deleted')
GROUP BY cc.id

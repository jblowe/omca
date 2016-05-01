SELECT
  cc.id,
  STRING_AGG(DISTINCT x.FIELD, '␥') AS FIELD_ss
FROM collectionobjects_common cc
  JOIN hierarchy h1 ON (cc.id = h1.id)
  JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'XTABLE')
  JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
  LEFT OUTER JOIN XTABLE_common x ON (h2.id = x.id)
  JOIN misc m ON (x.id=m.id AND m.lifecyclestate <> 'deleted')

GROUP BY cc.id

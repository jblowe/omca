-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, 
STRING_AGG(regexp_replace(cco.condition, '^.*\)''(.*)''$', '\1'), '␥') AS condition_ss,
STRING_AGG(to_char(cco.conditiondate + interval '8 hours', 'YYYY-MM-DD'), '␥') AS conditiondate_ss,
STRING_AGG(regexp_replace(ccc.conditioncheckrefnumber, '^.*\)''(.*)''$', '\1'), '␥') AS conditioncheckrefnumber_ss

FROM collectionobjects_common cc

  JOIN hierarchy h1 ON (cc.id = h1.id)
  JOIN relations_common rc ON (h1.name = rc.subjectcsid)
  -- JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'ConditionCheck')
  JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
  LEFT OUTER JOIN conditionchecks_omca cco ON (h2.id = cco.id)
  LEFT OUTER JOIN conditionchecks_common ccc ON (h2.id = ccc.id)
  JOIN misc m ON (cco.id=m.id AND m.lifecyclestate <> 'deleted')

WHERE cco.condition IS NOT NULL AND cco.condition != ''
GROUP BY cc.id


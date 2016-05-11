SELECT
  cc.id,
  li.creditline AS "creditline_s"
FROM collectionobjects_common cc

  JOIN hierarchy h1 ON (cc.id = h1.id)
  JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'LoansIn')
  JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
  LEFT OUTER JOIN loansin_omca li ON (h2.id = li.id)
  JOIN misc m ON (li.id=m.id AND m.lifecyclestate <> 'deleted')


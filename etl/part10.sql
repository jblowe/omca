-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, STRING_AGG(regexp_replace(regexp_replace(grp.loanstatus, '^.*\)''(.*)''$', '\1'), E'[\\t\\n\\r]+', ' ', 'g'), '␥') AS loaninstatus_ss
FROM loansin_common lc
JOIN misc m on (m.id = lc.id AND m.lifecyclestate <> 'deleted')
JOIN hierarchy h ON (h.parentid=lc.id AND h.primarytype = 'loanStatusGroup')
JOIN loanstatusgroup grp ON (grp.id=h.id)

JOIN hierarchy h1 ON (lc.id = h1.id)
JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'CollectionObject')
JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
LEFT OUTER JOIN collectionobjects_common cc ON (h2.id = cc.id)
JOIN misc m2 ON (cc.id=m2.id AND m2.lifecyclestate <> 'deleted')

WHERE grp.loanstatus IS NOT NULL
GROUP BY cc.id

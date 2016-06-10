-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id, 
STRING_AGG(regexp_replace(grp.status, '^.*\)''(.*)''$', '\1'), '␥') AS conservationstatus_ss,
STRING_AGG(to_char(grp.statusdate + interval '8 hours', 'YYYY-MM-DD'), '␥') AS conservationstatusdate_ss
FROM conservation_common lc
JOIN misc m on (m.id = lc.id AND m.lifecyclestate <> 'deleted')
JOIN hierarchy h ON (h.parentid=lc.id AND h.primarytype = 'conservationStatusGroup')
JOIN conservationstatusgroup grp ON (grp.id=h.id)

JOIN hierarchy h1 ON (lc.id = h1.id)
JOIN relations_common rc ON (h1.name = rc.subjectcsid AND rc.objectdocumenttype = 'CollectionObject')
JOIN hierarchy h2 ON (rc.objectcsid = h2.name)
LEFT OUTER JOIN collectionobjects_common cc ON (h2.id = cc.id)
JOIN misc m2 ON (cc.id=m2.id AND m2.lifecyclestate <> 'deleted')

WHERE grp.status IS NOT NULL
GROUP BY cc.id

-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT cc.id AS id,
  STRING_AGG(sdg.datedisplaydate, '␥')                              AS objectproductiondate_ss,
  STRING_AGG(to_char(sdg.dateearliestscalarvalue + interval '8 hours', 'YYYY-MM-DD'), '␥') AS objectproductionscalardate_ss

FROM collectionobjects_common cc
JOIN misc m on (m.id = cc.id AND m.lifecyclestate <> 'deleted')
LEFT OUTER JOIN hierarchy h ON (cc.id = h.parentid AND h.primarytype = 'structuredDateGroup')
-- AND h.name = 'collectionobjects_common:objectproductionDateGroup')
LEFT OUTER JOIN structureddategroup sdg ON (sdg.id = h.id)

WHERE sdg.datedisplaydate IS NOT NULL
GROUP BY cc.id

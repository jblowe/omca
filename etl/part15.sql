-- nb: this query assume it will take a variety of field content: refnames, messy free text, and output something "clean"
SELECT DISTINCT coom.id AS id, 
STRING_AGG(DISTINCT fcd.datedisplaydate, '␥')                              AS fieldcollectiondate_ss

FROM collectionobjects_omca coom
  left outer join collectionobjects_common coc on (coom.id=coc.id)
  JOIN misc ON (coc.id = misc.id AND misc.lifecyclestate <> 'deleted')
  LEFT OUTER JOIN hierarchy h24 ON (h24.parentid = coc.id AND h24.name='collectionobjects_common:fieldCollectionDateGroup')
  LEFT OUTER JOIN structureddategroup fcd ON (h24.id = fcd.id)

WHERE fcd.datedisplaydate IS NOT NULL AND fcd.datedisplaydate != ''
GROUP BY coom.id


SELECT
  coc.id AS id,
  onm.numbervalue AS othernumber_s

FROM collectionobjects_common coc
  JOIN hierarchy h1 ON (h1.id = coc.id)
  JOIN collectionobjects_omca coom ON (coom.id = coc.id)
  JOIN misc ON (coc.id = misc.id AND misc.lifecyclestate <> 'deleted')

  LEFT OUTER JOIN hierarchy h18 ON (h18.parentid = coc.id AND h18.name='collectionobjects_common:otherNumberList' AND h18.pos=0)
  LEFT OUTER JOIN othernumber onm ON (h18.id = onm.id)

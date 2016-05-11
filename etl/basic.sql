SELECT
  coc.id AS id,
  h1.name AS csid_s,

  regexp_replace(ong.objectname, '^.*\)''(.*)''$', '\1') AS objectname_s,

  coc.objectnumber AS objectnumber_s,
  coc.numberofobjects AS numberofobjects_s,
  coc.computedcurrentlocation AS computedcurrentlocationrefname_s,
  regexp_replace(dethistg.dhname, '^.*\)''(.*)''$', '\1') AS dhname_s,
  coom.sortableobjectnumber AS sortableobjectnumber_s,
  coom.art AS art_s,
  coom.history AS history_s,
  coom.science AS science_s,
  coom.donotpublishonweb AS donotpublishonweb_s,
  coom.computedcurrentlocationdisplay AS computedcurrentlocation_s,
  regexp_replace(coc.recordstatus, '^.*\)''(.*)''$', '\1') AS recordstatus_s,
  regexp_replace(coc.physicaldescription, E'[\\t\\n\\r]+', ' ', 'g') AS physicaldescription_s,
  regexp_replace(coc.contentdescription, E'[\\t\\n\\r]+', ' ', 'g') AS contentdescription_s,
  regexp_replace(coc.contentnote, E'[\\t\\n\\r]+', ' ', 'g') AS contentnote_s,
  regexp_replace(coc.fieldcollectionplace, '^.*\)''(.*)''$', '\1') AS fieldcollectionplace_s,
  regexp_replace(coc.collection, '^.*\)''(.*)''$', '\1') AS collection_s,
  regexp_replace(coom.ipaudit, '^.*\)''(.*)''$', '\1') AS ipaudit_s,
  regexp_replace(coom.argusremarks, E'[\\t\\n\\r]+', ' ', 'g') AS argusremarks_s,
  regexp_replace(coom.argusdescription, E'[\\t\\n\\r]+', ' ', 'g') AS argusdescription_s

FROM collectionobjects_common coc
  JOIN hierarchy h1 ON (h1.id = coc.id)
  JOIN collectionobjects_omca coom ON (coom.id = coc.id)
  JOIN misc ON (coc.id = misc.id AND misc.lifecyclestate <> 'deleted')

  LEFT OUTER JOIN hierarchy h2 ON (coc.id=h2.parentid AND h2.name='collectionobjects_common:objectNameList' AND h2.pos=0)
  LEFT OUTER JOIN objectnamegroup ong ON (ong.id=h2.id)

  LEFT OUTER JOIN hierarchy h9 ON (h9.parentid = coc.id AND h9.name='collectionobjects_omca:determinationHistoryGroupList' AND h9.pos=0)
  LEFT OUTER JOIN determinationhistorygroup dethistg ON (h9.id = dethistg.id)


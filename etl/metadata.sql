SELECT
  h1.name AS csid_s,
  coc.id AS objectcsid_s,

  regexp_replace(ong.objectname, '^.*\)''(.*)''$', '\1') AS objectname_s,

  coc.objectnumber AS objectnumber_s,
  regexp_replace(coc.recordstatus, '^.*\)''(.*)''$', '\1') AS recordstatus_s,
  coc_comments.item AS comments_s,
  regexp_replace(coc_styles.item, '^.*\)''(.*)''$', '\1') AS styles_s,
  regexp_replace(coc_colors.item, '^.*\)''(.*)''$', '\1') AS colors_s,
  coc.physicaldescription AS physicaldescription_s,
  coc.contentdescription AS contentdescription_s,
  regexp_replace(cocc_concepts.item, '^.*\)''(.*)''$', '\1') AS contentconcept_s,
  regexp_replace(cocc_places.item, '^.*\)''(.*)''$', '\1') AS contentplace_s,
  regexp_replace(cocc_persons.item, '^.*\)''(.*)''$', '\1') AS contentperson_s,
  regexp_replace(cocc_organizations.item, '^.*\)''(.*)''$', '\1') AS contentorganization_s,
  coc.contentnote AS contentnote_s,
  regexp_replace(coc.fieldcollectionplace, '^.*\)''(.*)''$', '\1') AS fieldcollectionplace_s,
  regexp_replace(coc.collection, '^.*\)''(.*)''$', '\1') AS collection_s,
  coc.numberofobjects AS numberofobjects_s,
  coc.computedcurrentlocation AS computedcurrentlocationrefname_s,

  coom.sortableobjectnumber AS sortableobjectnumber_s,
  coom.art AS art_s,
  coom.history AS history_s,
  coom.science AS science_s,
  regexp_replace(coom.ipaudit, '^.*\)''(.*)''$', '\1') AS ipaudit_s,
  coom.computedcurrentlocationdisplay AS computedcurrentlocation_s,
  coom.argusremarks AS argusremarks_s,

  exhobjg.exhibitionobjectnumber AS exhibitionobjectnumber_s,
  exhobjomcag.exhibitionobjectnumberomca AS exhibitionobjectnumberomca_s,
  gc.title AS grouptitle_s,
  titleg.title AS title_s,
  gc.responsibledepartment AS responsibledepartment_s,
  mpg.dimensionsummary AS dimensionsummary_s,
  mpg.measuredpart AS mmeasuredpart_s,
  regexp_replace(dethistg.dhname, '^.*\)''(.*)''$', '\1') AS dhname_s,
  matg.materialsource AS materials_s,
  objcmpg.objectcomponentname AS objectcomponentname_s,
  objcmpg.objectcomponentinformation AS objectcomponentinformation_s,
  dimsubg.dimension AS dimension_s,
  regexp_replace(objprdpg.objectproductionperson, '^.*\)''(.*)''$', '\1') AS objectproductionperson_s,
  regexp_replace(objprdorgg.objectproductionorganization, '^.*\)''(.*)''$', '\1') AS objectproductionorganization_s,
  regexp_replace(objprdplaceg.objectproductionplace, '^.*\)''(.*)''$', '\1') AS objectproductionplace_s,
  objprdplaceg.objectproductionplacerole AS objectproductionplacerole_s,
  regexp_replace(apg.assocperson, '^.*\)''(.*)''$', '\1') AS assocperson_s,
  regexp_replace(aorgg.assocorganization, '^.*\)''(.*)''$', '\1') AS assocorganization_s,
  regexp_replace(aplaceg.assocplace, '^.*\)''(.*)''$', '\1') AS assocplace_s,
  accg.assocculturalcontext AS assocculturalcontext_s,

  lic.loaninnumber loaninnumber_s,
  regexp_replace(lg.lender, '^.*\)''(.*)''$', '\1') AS lender_s,

  loc.loanoutnumber loanoutnumber_s,
  regexp_replace(loc.borrower, '^.*\)''(.*)''$', '\1') AS borrower_s,

  lsg.loanstatusnote AS loanstatusnote_s,
  lsg.loanstatus AS loanstatus_s,
  lsg.loanstatusdate AS loanstatusdate_s,
  ccg.condition AS condition_s,
  ccg.conditiondate AS conditiondate_s,
  hazardg.hazardnote AS hazardnote_s,
  hazardg.hazard AS hazard_s,
  hazardg.hazarddate AS hazarddate_s,
  csg.status AS conservationstatus_s,
  csg.statusdate AS conservationstatusdate_s

FROM collectionobjects_common coc
  JOIN hierarchy h1 ON (h1.id = coc.id)
  JOIN collectionobjects_omca coom ON (coom.id = coc.id)
  JOIN misc ON (coc.id = misc.id AND misc.lifecyclestate <> 'deleted')

  LEFT OUTER JOIN hierarchy h2 ON (coc.id=h2.parentid AND h2.name='collectionobjects_common:objectNameList' AND h2.pos=0)
  LEFT OUTER JOIN objectnamegroup ong ON (ong.id=h2.id)
  LEFT OUTER JOIN hierarchy h3 ON (h3.parentid = coc.id AND h3.name='collectionobjects_common:assocCulturalContextGroupList' AND h3.pos=0)
  LEFT OUTER JOIN assocculturalcontextgroup accg ON (h3.id = accg.id)
  LEFT OUTER JOIN hierarchy h4 ON (h4.parentid = coc.id AND h4.name='collectionobjects_common:assocOrganizationGroupList' AND h4.pos=0)
  LEFT OUTER JOIN assocorganizationgroup aorgg ON (h4.id = aorgg.id)
  LEFT OUTER JOIN hierarchy h5 ON (h5.parentid = coc.id AND h5.name='collectionobjects_common:assocPersonGroupList' AND h5.pos=0)
  LEFT OUTER JOIN assocpersongroup apg ON (h5.id = apg.id)
  LEFT OUTER JOIN hierarchy h6 ON (h6.parentid = coc.id AND h6.name='collectionobjects_common:assocPlaceGroupList' AND h6.pos=0)
  LEFT OUTER JOIN assocplacegroup aplaceg ON (h6.id = aplaceg.id)
  LEFT OUTER JOIN hierarchy h7 ON (h7.parentid = coc.id AND h7.name='conditionchecks_common:conditioncheckGroupList' AND h7.pos=0)
  LEFT OUTER JOIN conditioncheckgroup ccg ON (h7.id = ccg.id)
  LEFT OUTER JOIN hierarchy h8 ON (h8.parentid = coc.id AND h8.name='collectionobjects_common:conservationstatusGroupList' AND h8.pos=0)
  LEFT OUTER JOIN conservationstatusgroup csg ON (h8.id = csg.id)
  LEFT OUTER JOIN hierarchy h9 ON (h9.parentid = coc.id AND h9.name='collectionobjects_omca:determinationHistoryGroupList' AND h9.pos=0)
  LEFT OUTER JOIN determinationhistorygroup dethistg ON (h9.id = dethistg.id)
  LEFT OUTER JOIN hierarchy h10 ON (h10.parentid = coc.id AND h10.name='collectionobjects_common:dimensionsubGroupList' AND h10.pos=0)
  LEFT OUTER JOIN dimensionsubgroup dimsubg ON (h10.id = dimsubg.id)
  LEFT OUTER JOIN hierarchy h11 ON (h11.parentid = coc.id AND h11.name='collectionobjects_common:exhibitionobjectGroupList' AND h11.pos=0)
  LEFT OUTER JOIN exhibitionobjectgroup exhobjg ON (h11.id = exhobjg.id)
  LEFT OUTER JOIN hierarchy h12 ON (h12.parentid = coc.id AND h12.name='exhibitions_omca:exhibitionObjectOMCAGroupList' AND h12.pos=0)
  LEFT OUTER JOIN exhibitionobjectomcagroup exhobjomcag ON (h12.id = exhobjomcag.id)
  LEFT OUTER JOIN hierarchy h13 ON (h13.parentid = coc.id AND h13.name='collectionobjects_common:Groups_CommonList' AND h13.pos=0)
  LEFT OUTER JOIN groups_common gc ON (h13.id = gc.id)
  LEFT OUTER JOIN hierarchy h14 ON (h14.parentid = coc.id AND h14.name='conditionchecks_common:hazardGroupList' AND h14.pos=0)
  LEFT OUTER JOIN hazardgroup hazardg ON (h14.id = hazardg.id)

  JOIN relations_common rc1 ON h1.name=rc1.objectcsid
  JOIN hierarchy hr2 ON rc1.subjectcsid=hr2.name
  JOIN loansin_common lic ON hr2.id=lic.id
  LEFT OUTER JOIN hierarchy h15 ON (h15.parentid = lic.id AND h15.name='loansin_common:lenderGroupList' AND h15.pos=0)
  LEFT OUTER JOIN lendergroup lg ON (h15.id = lg.id)

  JOIN relations_common rc2 ON h1.name=rc2.objectcsid
  JOIN hierarchy hr3 ON rc2.subjectcsid=hr3.name
  JOIN loansout_common loc ON hr3.id=lic.id
  LEFT OUTER JOIN hierarchy h16 ON (h16.parentid = loc.id AND h16.name='loansout_common:loanStatusGroupList' AND h16.pos=0)
  LEFT OUTER JOIN loanstatusgroup lsg ON (h16.id = lsg.id)

  LEFT OUTER JOIN hierarchy h17 ON (h17.parentid = coc.id AND h17.name='collectionobjects_common:materialGroupList' AND h17.pos=0)
  LEFT OUTER JOIN materialgroup matg ON (h17.id = matg.id)
  LEFT OUTER JOIN hierarchy h18 ON (h18.parentid = coc.id AND h18.name='collectionobjects_common:measuredPartGroupList' AND h18.pos=0)
  LEFT OUTER JOIN measuredpartgroup mpg ON (h18.id = mpg.id)
  LEFT OUTER JOIN hierarchy h19 ON (h19.parentid = coc.id AND h19.name='collectionobjects_common:objectComponentGroupList' AND h19.pos=0)
  LEFT OUTER JOIN objectcomponentgroup objcmpg ON (h19.id = objcmpg.id)
  LEFT OUTER JOIN hierarchy h21 ON (h21.parentid = coc.id AND h21.name='collectionobjects_common:objectProductionOrganizationGroupList' AND h21.pos=0)
  LEFT OUTER JOIN objectproductionorganizationgroup objprdorgg ON (h21.id = objprdorgg.id)
  LEFT OUTER JOIN hierarchy h22 ON (h22.parentid = coc.id AND h22.name='collectionobjects_common:objectProductionPersonGroupList' AND h22.pos=0)
  LEFT OUTER JOIN objectproductionpersongroup objprdpg ON (h22.id = objprdpg.id)
  LEFT OUTER JOIN hierarchy h23 ON (h23.parentid = coc.id AND h23.name='collectionobjects_common:objectProductionPlaceGroupList' AND h23.pos=0)
  LEFT OUTER JOIN objectproductionplacegroup objprdplaceg ON (h23.id = objprdplaceg.id)
  LEFT OUTER JOIN hierarchy h24 ON (h24.parentid = coc.id AND h24.name='collectionobjects_common:titleGroupList' AND h24.pos=0)
  LEFT OUTER JOIN titlegroup titleg ON (h24.id = titleg.id)

  LEFT OUTER JOIN collectionobjects_common_comments coc_comments ON (coc.id = coc_comments.id AND coc_comments.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_styles coc_styles ON (coc.id = coc_styles.id AND coc_styles.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_colors coc_colors ON (coc.id = coc_colors.id AND coc_colors.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_contentconcepts cocc_concepts ON (coc.id = cocc_concepts.id AND cocc_concepts.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_contentplaces cocc_places ON (coc.id = cocc_places.id AND cocc_places.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_contentpersons cocc_persons ON (coc.id = cocc_persons.id AND cocc_persons.pos = 0)
  LEFT OUTER JOIN collectionobjects_common_contentorganizations cocc_organizations ON (coc.id = cocc_organizations.id AND cocc_organizations.pos = 0)

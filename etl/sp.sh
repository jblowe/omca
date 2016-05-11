#!/bin/bash -x
date
##############################################################################
# copy the current set of extracts to temp (thereby saving the previous run, just in case)
##############################################################################
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
TENANT=$1
SERVER="localhost sslmode=prefer password=nuxeo"
USERNAME="nuxeo_$TENANT"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE"
##############################################################################
for core in public internal 
do
  # check that all rows have the same number of fields as the header
  export NUMCOLS=`grep csid ${core}.csv | awk '{ FS = "\t" ; print NF}'`
  time awk -v NUMCOLS=$NUMCOLS '{ FS = "\t" ; if (NF == 0+NUMCOLS) print }' ${core}.csv | perl -pe 's/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;' > 4solr.$TENANT.base.${core}.csv &
  time awk -v NUMCOLS=$NUMCOLS '{ FS = "\t" ; if (NF != 0+NUMCOLS) print }' ${core}.csv | perl -pe 's/\\/\//g' > errors.${core}.csv &
  wait
  # merge media and metadata files (done in perl ... very complicated to do in SQL)
  time perl mergeObjectsAndMedia.pl 4solr.$TENANT.media.csv 4solr.$TENANT.base.${core}.csv > d6.csv
  # recover the solr header and put it back at the top of the file
  grep csid d6.csv > header4Solr.csv
  perl -i -pe 's/$/blob_ss/;' header4Solr.csv
  grep -v csid d6.csv > d8.csv
  cat header4Solr.csv d8.csv | perl -pe 's/␥/|/g' > 4solr.$TENANT.${core}.csv
  # clean up some outstanding sins perpetuated by earlier scripts
  perl -i -pe 's/\r//g;s/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;s/\"\"/"/g' 4solr.$TENANT.${core}.csv
  ##############################################################################
  # ok, now let's load this into solr...
  # clear out the existing data
  ##############################################################################
  curl -S -s "http://localhost:8983/solr/${TENANT}-${core}/update" --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'
  curl -S -s "http://localhost:8983/solr/${TENANT}-${core}/update" --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
  ##############################################################################
  # this POSTs the csv to the Solr / update endpoint
  # note, among other things, the overriding of the encapsulator with \
  ##############################################################################
  time curl -S -s "http://localhost:8983/solr/${TENANT}-${core}/update/csv?commit=true&header=true&separator=%09&f.assocculturalcontext_ss.split=true&f.assocculturalcontext_ss.separator=%7C&f.assocorganization_ss.split=true&f.assocorganization_ss.separator=%7C&f.assocperson_ss.split=true&f.assocperson_ss.separator=%7C&f.assocplace_ss.split=true&f.assocplace_ss.separator=%7C&f.material_ss.split=true&f.material_ss.separator=%7C&f.measuredpart_ss.split=true&f.measuredpart_ss.separator=%7C&f.objectproductionorganization_ss.split=true&f.objectproductionorganization_ss.separator=%7C&f.objectproductionperson_ss.split=true&f.objectproductionperson_ss.separator=%7C&f.objectproductionplace_ss.split=true&f.objectproductionplace_ss.separator=%7C&f.title_ss.split=true&f.title_ss.separator=%7C&f.loanstatus_ss.split=true&f.loanstatus_ss.separator=%7C&f.lender_ss.split=true&f.lender_ss.separator=%7C&f.comments_ss.split=true&f.comments_ss.separator=%7C&f.styles_ss.split=true&f.styles_ss.separator=%7C&f.colors_ss.split=true&f.colors_ss.separator=%7C&f.contentconcepts_ss.split=true&f.contentconcepts_ss.separator=%7C&f.contentplaces_ss.split=true&f.contentplaces_ss.separator=%7C&f.contentpersons_ss.split=true&f.contentpersons_ss.separator=%7C&f.contentorganizations_ss.split=true&f.contentorganizations_ss.separator=%7C&f.exhibitionhistories_ss.split=true&f.exhibitionhistories_ss.separator=%7C&f.loanoutnumber_ss.split=true&f.loanoutnumber_ss.separator=%7C&f.borrower_ss.split=true&f.borrower_ss.separator=%7C&f.loaninnumber_ss.split=true&f.loaninnumber_ss.separator=%7C&f.blob_ss.split=true&f.blob_ss.separator=,&encapsulator=\\" --data-binary @4solr.$TENANT.${core}.csv -H 'Content-type:text/plain; charset=utf-8'
  time ./evaluate.sh 4solr.$TENANT.${core}.csv > 4solr.fields.$TENANT.${core}.csv
done
##############################################################################
# wrap things up: make a gzipped version of what was loaded
##############################################################################
# get rid of intermediate files
#rm d?.csv d6a.csv m?.csv part*.csv basic.csv
# zip up .csvs, save a bit of space on backups
#gzip -f *.csv
date

#!/bin/bash -x
date
##############################################################################
# move the current set of extracts to temp (thereby saving the previous run, just in case)
##############################################################################
cp 4solr.*.csv.gz /tmp
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
TENANT=$1
# host=localhost dbname=omca_domain_omca user=nuxeo_omca password=nuxeo sslmode=prefer
SERVER="localhost sslmode=prefer password=nuxeo"
USERNAME="nuxeo_$TENANT"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE"
##############################################################################
# extract metadata and media info from CSpace
##############################################################################
# run the "media query"
# cleanup newlines and crlf in data, then switch record separator.
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f media.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > 4solr.$TENANT.media.csv
# cleanup newlines and crlf in data, then switch record separator.
##############################################################################
# start the stitching process: extract the "basic" data
##############################################################################
time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f basic.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > public.csv
##############################################################################
# stitch this together with the results of the rest of the "subqueries"
##############################################################################
for var in `cat type1.txt`
do
    XTABLE=`echo $var | cut -d ',' -f 1`
    FIELD=`echo $var | cut -d ',' -f 2`
    perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" template1.sql > temp1.sql
    time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f temp1.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > temp1.csv
    time python join.py public.csv temp1.csv > temp.csv
    cp temp.csv public.csv
    cp temp1.csv t1.${var}.csv
done
#
for var in `cat type2.txt`
do
    XTABLE=`echo $var | cut -d ',' -f 1`
    FIELD=`echo $var | cut -d ',' -f 2`
    perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" template2.sql > temp2.sql
    time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f temp2.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > temp2.csv
    time python join.py public.csv temp2.csv > temp.csv
    cp temp.csv public.csv
    cp temp2.csv t2.${var}.csv
done
#
for var in `cat type3.txt`
do
    XTABLE=`echo $var | cut -d ',' -f 1`
    FIELD=`echo $var | cut -d ',' -f 2`
    perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" template3.sql > temp3.sql
    time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f temp3.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > temp3.csv
    time python join.py public.csv temp3.csv > temp.csv
    cp temp.csv public.csv
    cp temp3.csv t3.${var}.csv
done
rm temp?.csv
# check latlongs 
##############################################################################
#perl -ne '@y=split /\t/;@x=split ",",$y[34];print if     ((abs($x[0])<90 && abs($x[1])<180 && $y[34]!~/[^0-9\, \.\-]/) || $y[34]=~/_p/);' public.csv > d6.csv
#perl -ne '@y=split /\t/;@x=split ",",$y[34];print unless ((abs($x[0])<90 && abs($x[1])<180 && $y[34]!~/[^0-9\, \.\-]/) || $y[34]=~/_p/);' public.csv > errors_in_latlong.csv
#mv d6.csv public.csv
##############################################################################
# these queries are for the internal datastore
##############################################################################
cp public.csv internal.csv
for i in {0..0}
do
 time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f part$i.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > part$i.csv
 time python join.py internal.csv part$i.csv > temp.csv
 cp temp.csv internal.csv
done
rm temp.csv
##############################################################################
#  compute a boolean: hascoords = yes/no
##############################################################################
# perl setCoords.pl 34 < d6.csv > d6a.csv
##############################################################################
#  Obfuscate the lat-longs of sensitive sites
##############################################################################
# time python obfuscateUSArchaeologySites.py d6a.csv d7.csv
##############################################################################
# add the blob and other media flags to the rest of the metadata
# and we want to recover and use our "special" solr-friendly header, which got buried
##############################################################################
for core in public internal 
do
  # check that all rows have the same number of fields as the header
  export NUMCOLS=`grep csid ${core}.csv | awk '{ FS = "\t" ; print NF}'`
  time awk -v NUMCOLS=$NUMCOLS '{ FS = "\t" ; if (NF == 0+NUMCOLS) print }' ${core}.csv | perl -pe 's/\\/\//g;s/\t"/\t/g;s/"\t/\t/g;' > 4solr.$TENANT.base.${core}.csv &
  time awk -v NUMCOLS=$NUMCOLS '{ FS = "\t" ; if (NF != 0+NUMCOLS) print }' ${core}.csv | perl -pe 's/\\/\//g' > errors.${core}.csv &
  wait
  time perl mergeObjectsAndMedia.pl 4solr.$TENANT.media.csv 4solr.$TENANT.base.${core}.csv > d6.csv
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
  time ./evaluate.sh @4solr.$TENANT.${core}.csv > 4solr.fields.$TENANT.${core}.csv
done
##############################################################################
# wrap things up: make a gzipped version of what was loaded
##############################################################################
# get rid of intermediate files
#rm d?.csv d6a.csv m?.csv part*.csv basic.csv
# zip up .csvs, save a bit of space on backups
#gzip -f *.csv
date

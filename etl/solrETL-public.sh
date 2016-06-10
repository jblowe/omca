#!/bin/bash -x
date
##############################################################################
# copy the current set of extracts to temp (thereby saving the previous run, just in case)
##############################################################################
cp 4solr.*.csv.gz /tmp
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
TENANT=$1
SERVER="localhost sslmode=prefer password=xxxxx"
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
# there are 3 query patterns which based on a couple of parameters
# will pull out multivalued fields, aggregate them, and spit them out with
# the top level object csid
#
# the patterns are in the template*.sql files
# the parameters are in the type*.txt files
##############################################################################
for TYPE in 1 2 3 4 5
do
  for var in `cat type${TYPE}.txt`
  do
      XTABLE=`echo $var | cut -d ',' -f 1`
      FIELD=`echo $var | cut -d ',' -f 2`
      perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" template${TYPE}.sql > temp.sql
      time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f temp.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > temp1.csv
      time python join.py public.csv temp1.csv > temp2.csv
      cp temp2.csv public.csv
      cp temp1.csv t${TYPE}.${var}.csv
  done
done
rm temp1.csv temp2.csv temp.sql
# check latlongs 
##############################################################################
#perl -ne '@y=split /\t/;@x=split ",",$y[34];print if     ((abs($x[0])<90 && abs($x[1])<180 && $y[34]!~/[^0-9\, \.\-]/) || $y[34]=~/_p/);' public.csv > d6.csv
#perl -ne '@y=split /\t/;@x=split ",",$y[34];print unless ((abs($x[0])<90 && abs($x[1])<180 && $y[34]!~/[^0-9\, \.\-]/) || $y[34]=~/_p/);' public.csv > errors_in_latlong.csv
#mv d6.csv public.csv
##############################################################################
# these queries are special, the dont fit the patterns above
##############################################################################
cp public.csv internal.csv
for i in {1..15}
do
 if [ -f part$i.sql ]; then
   time psql -F $'\t' -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f part$i.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > part$i.csv
   time python join.py internal.csv part$i.csv > temp.csv
   cp temp.csv internal.csv
 fi
done
#rm temp.csv
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
  # merge media and metadata files (done in perl ... very complicated to do in SQL)
  time perl mergeObjectsAndMedia.pl 4solr.$TENANT.media.csv 4solr.$TENANT.base.${core}.csv > d6.csv
  # recover the solr header and put it back at the top of the file
  grep csid d6.csv > header4Solr.csv
  perl -i -pe 's/$/blob_ss/;' header4Solr.csv
  # generate solr schema <copyField> elements, just in case. 
  # also generate parameters for POST to solr (to split _ss fields properly)
  ./genschema.sh ${core}
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
  ss_string=`cat uploadparms.${core}.txt`
  time curl -S -s "http://localhost:8983/solr/${TENANT}-${core}/update/csv?commit=true&header=true&separator=%09&${ss_string}f.blob_ss.split=true&f.blob_ss.separator=,&encapsulator=\\" --data-binary @4solr.$TENANT.${core}.csv -H 'Content-type:text/plain; charset=utf-8'
  time bash evaluate.sh 4solr.$TENANT.${core}.csv > 4solr.fields.$TENANT.${core}.csv
done
##############################################################################
# wrap things up: make a gzipped version of what was loaded
##############################################################################
# get rid of intermediate files
#rm d?.csv d6a.csv m?.csv part*.csv basic.csv
# zip up .csvs, save a bit of space on backups
#gzip -f *.csv
date

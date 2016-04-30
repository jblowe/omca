#!/bin/bash -x
date
##############################################################################
# while most of this script is already tenant specific, many of the specific commands
# are shared between the different scripts; having them be as similar as possible
# eases maintainance. ergo, the TENANT parameter
##############################################################################
TENANT=$1
SERVER="localhost sslmode=prefer password=xxxx"
USERNAME="nuxeo_$TENANT"
DATABASE="${TENANT}_domain_${TENANT}"
CONNECTSTRING="host=$SERVER dbname=$DATABASE"
export NUMCOLS=57
##############################################################################
# extract metadata and media info from CSpace
##############################################################################
# NB: unlike the other ETL processes, we're still using the default | delimiter here
##############################################################################
time psql -R"@@" -A -U $USERNAME -d "$CONNECTSTRING"  -f metadata.sql -o d1.csv
# some fix up required, alas: data from cspace is dirty: contain csv delimiters, newlines, etc. that's why we used @@ as temporary record separator
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1.csv > d3.csv 
time perl -ne " \$x = \$_ ;s/[^\|]//g; if     (length eq \$ENV{NUMCOLS}) { print \$x;}" d3.csv > metadata.csv
time perl -ne " \$x = \$_ ;s/[^\|]//g; unless (length eq \$ENV{NUMCOLS}) { print \$x;}" d3.csv > errors.csv &
gunzip -f media.csv.gz
#time psql -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f media.sql -o m1.csv
#time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' m1.csv > media.csv 
#time psql -R"@@" -A -U $USERNAME -d "$CONNECTSTRING" -f blobs.sql -o b1.csv
#time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' b1.csv > blobs.csv
# make the header
head -1 d3.csv > header4Solr.csv
# add the blob field name to the header (the header already ends with a tab); rewrite objectcsid_s to id (for solr id...)
#perl -i -pe 's/\|/_s\|/g;s/objectcsid_s/id/;s/$/_s|blob_ss/' header4Solr.csv
##############################################################################
# name the first column 'id'; add the blob field name to the header.
##############################################################################
perl -i -pe 's/^/id\|/;s/$/\|blob_ss/;' header4Solr.csv
# add the blobcsids to the rest of the data
time perl mergeObjectsAndMedia.pl > d6.csv
##############################################################################
# make a unique sequence number for id
##############################################################################
perl -i -pe '$i++;print $i . "\|"' d6.csv
# we want to use our "special" solr-friendly header.
tail -n +2 d6.csv > d7.csv
cat header4Solr.csv d7.csv > 4solr.$TENANT.internal.csv
perl -i -pe 's/\\/\\\\/g' 4solr.omca.internal.csv
wc -l *.csv
# clear out the existing data
curl -S -s "http://localhost:8983/solr/${TENANT}-internal/update" --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'
curl -S -s "http://localhost:8983/solr/${TENANT}-internal/update" --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
time curl -S -s "http://localhost:8983/solr/${TENANT}-internal/update/csv?commit=true&header=true&trim=true&separator=%7C&f.othernumbers_ss.split=true&f.othernumbers_ss.separator=;&f.blob_ss.split=true&f.blob_ss.separator=,&encapsulator=\\" --data-binary @4solr.$TENANT.internal.csv -H 'Content-type:text/plain; charset=utf-8'
# get rid of intermediate files
rm d?.csv m?.csv b?.csv media.csv metadata.csv
# zip up .csvs, save a bit of space on backups
gzip -f *.csv
#
date

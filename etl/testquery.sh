#!/bin/bash -x
for var in `cat $1`
do
    XTABLE=`echo $var | cut -d ',' -f 1`
    FIELD=`echo $var | cut -d ',' -f 2`
    perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" $2 > txmp.sql
    time psql -F $'\t' -R@@ -A -U nuxeo_omca -d 'host=localhost sslmode=prefer password=nuxeo dbname=omca_domain_omca' -f txmp.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > txmp.csv
    cp txmp.csv tx.$2.${var}.csv
    echo
    wc -l tx.$2.${var}.csv
done

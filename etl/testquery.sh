#!/bin/bash -x
for var in `cat $1`
do
    XTABLE=`echo $var | cut -d ',' -f 1`
    FIELD=`echo $var | cut -d ',' -f 2`
    perl -pe "s/XTABLE/${XTABLE}/g;s/FIELD/${FIELD}/g" template$2.sql > txmp$2.sql
    time psql -F $'\t' -R@@ -A -U nuxeo_omca -d 'host=localhost sslmode=prefer password=nuxeo dbname=omca_domain_omca' -f txmp$2.sql | perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' > txmp$2.csv
    cp txmp$2.csv t$2.${var}.csv
    echo
    wc -l t$2.${var}.csv
done

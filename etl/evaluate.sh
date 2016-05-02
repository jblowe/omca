for w in `head -1 $1 | perl -pe "s/\|/\n/g" | sort`
do
  ((i++))
  cut -f${i} $1 | perl -ne 'print unless /^$/' > tmp
  types=`sort -u tmp | wc -l`
  ((types--))
  tokens=`cat tmp | wc -l`
  ((tokens--))
  echo "${i}	${w}	${types}	${tokens}"
done
rm tmp

for w in `head -1 $1 | perl -pe "s/\|/\n/g"`
do
  ((i++))
  count=`cut -d"|" -f${i} $1 | sort -u | wc -l`
  ((count--))
  echo "${i} ${w} ${count-1}"
done


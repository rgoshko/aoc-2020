#!/bin/bash

PASSWORD="password.dat"
goodCount=0

for line in $( awk 'BEGIN {FS=" ";}{print $1 "," $2 "," $3}' < "${PASSWORD}" )
do

    readarray -d "," -t lineParts<<<"${line}"
    #echo ${lineParts[*]}
    readarray -d "-" -t limit<<<"${lineParts[0]}"
    min=${limit[0]}
    max=${limit[1]}
    char=`echo -n ${lineParts[1]} | sed s/://`
    password=${lineParts[2]}
    echo ${min} ${max} ${char} ${password}

    size=`echo -n ${password} | wc -c`
    checkSize=`echo -n ${password} | sed s/"${char}"//g | wc -c`
    count=$(( ${size} - ${checkSize} ))

    echo " \ ${size} - ${checkSize} = ${count}"
    if [ ${count} -ge ${min} -a ${count} -le ${max} ]; then
#    if [ ${count} -ge ${min} ]; then
        let "goodCount+=1"
        echo " | Good"
    else
        echo " | Bad"
    fi
    echo ""

done

echo "Good count: ${goodCount}"

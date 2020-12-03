#!/bin/bash

PASSWORD="password.dat"

#readarray -t lines < ${PASSWORD}

#echo "lines read: ${#lines[@]}"

lineCount=0
goodCount=0

#while [ ${lineCount} -lt ${#lines[@]} ]; do
#
#    readarray -d " " -t lineParts<<<"${lines[${lineCount}]}"

for line in $( awk 'BEGIN {FS=" ";}{print $1 "," $2 "," $3}' < "${PASSWORD}" )
do

    let "lineCount+=1"

    readarray -d "," -t lineParts<<<"${line}"
    #echo ${lineParts[*]}
    readarray -d "-" -t limit<<<"${lineParts[0]}"
    #echo ${limit[*]}
    pos1=$(( ${limit[0]} - 1 ))
    pos2=$(( ${limit[1]} - 1 ))
    char=`echo -n ${lineParts[1]} | sed s/://`
    password=`echo -n ${lineParts[2]}`

    if [ ${pos1} -lt ${#password} ]; then
        charPos1="${password:${pos1}:1}"
    else
        charPos1=" "
    fi
    if [ ${pos2} -lt $(( ${#password} - 1 )) ]; then
        charPos2="${password:${pos2}:1}"
    else
        charPos2="_"
    fi

#    echo "${pos1}/(${charPos1}) ${pos2}/(${charPos2}) ${char} ${password}"
#    echo "${char} ${password}"
#    echo "${pos1}/(${charPos1})"
#    echo "${pos2}/(${charPos2})"

    if [ ${char} = ${charPos1} -o ${char} = ${charPos2} ]; then
        if [ ${char} = ${charPos1} -a ${char} = ${charPos2} ]; then
            echo " - Bad (${lineCount})"
        else
            let "goodCount+=1"
            echo " + Good (${lineCount})"
        fi
    else
        echo " - Bad (${lineCount})"
    fi

done

echo "Good Count: ${goodCount}"
echo "Line Count: ${lineCount}"

#!/bin/bash

echo "digraph {"

declare -a OUTPUTLINES=()

while read -r line ; do
    FROM=`echo $line | sed -e 's/FROM //ig' | sed -e 's/ AS.*//ig'`
    if [[ "${line,,}" == *" as "* ]]; then
    	TO=`echo $line | sed -e 's/.*as //ig'`
    else
    	TO="final"
    fi

    output="\"$FROM\" -> \"$TO\";"
    OUTPUTLINES+=("$output")
done <<<$(grep -i "from" $1 | grep -vi "from=" | sed -e 's/FROM //ig' | cat)


CURRENT_STAGE=0
while read -r line ; do
    if [[ "${line,,}" == *" as "* ]]; then
    	CURRENT_STAGE=`echo $line | sed -e 's/.*as //ig'`
    elif [[ "${line,,}" == *"from "* ]]; then
	CURRENT_STAGE="final"
    fi

    if [[ "${line,,}" == *"copy --from="* ]]; then
	FROM=`echo $line | sed -e 's/COPY --from=//ig' | sed -e 's/ .*//ig'`
	OUTPUTLINES+=("\"$FROM\" -> \"$CURRENT_STAGE\";")
    fi
done <<<$(cat $1)

printf '%s\n' "${OUTPUTLINES[@]}" | sort -u

echo "}"


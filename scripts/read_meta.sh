#!/bin/bash

api=http://localhost:8000/now_playing
pipe=/Users/ryankolak/src/shairport/metadata/now_playing
datafile=$pipe.json

stringify() {
  a=${1%%=*}
  b=${1##*=}
  echo "\"$a\": \"$b\""
}

exec 4< $pipe
while read -ru 4 line ; do
  if [[ $line == artist* ]]; then
    echo '{' > $datafile
  elif [ -z "$line" ]; then
    echo '}' >> $datafile
    curl -H "Accept: application/json" -H "Content-type: application/json" -X POST --data @$datafile $api
    continue
  fi

  # jsonify the string
  data=$(stringify "$line")

  # for logging
  echo $line

  # pretty print the JSON
  # comment is the last line of the output
  if [[ $line == comment* ]]; then
    echo "  $data" >> $datafile
  else
    echo "  $data," >> $datafile
  fi
done

exec 4<&-
echo Exiting




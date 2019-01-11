#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR="$DIR/out"
TEMPLATE="$WORKDIR/Dockerfile"

mkdir -p  "$WORKDIR"
rm    -rf "$TEMPLATE"   
touch     "$TEMPLATE"

add-text() { echo $1 >> "$TEMPLATE"; }
add-curl() {
  URL="https://raw.githubusercontent.com/$1/Dockerfile"
  add-text "#### $URL start (skip $2 first, $3 last lines)"
  curl -sSL "$URL" | tail --lines +"$2" - | head --lines -"$3" - >> "$TEMPLATE"
  add-text "#### $URL end"
}
add-file() {
  FILE="$1/Dockerfile"
  add-text "#### $FILE start"
  cat      "$FILE" >> "$TEMPLATE";
  add-text "#### $FILE end"
}
add-from() {
  add-text "#### $1 start"
  add-text "FROM $1"
  add-text "#### $1 end"
}

# create Dockerfile aggregating our changes and jupyter official recipies
add-text "#### $(LC_ALL=en_DB.utf8 date)"
add-text
add-from 'jupyter/all-spark-notebook:latest'
add-text
add-text 'LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"'
add-text
add-curl 'jupyter/docker-stacks/master/datascience-notebook' 8 0
add-text
add-curl 'jupyter/docker-stacks/master/tensorflow-notebook' 8 0
add-text
add-curl 'jupyter/docker-stacks/master/r-notebook' 8 0
add-text
add-curl 'vatlab/SoS/master/development/docker-notebook' 14 10
add-text
add-file "$DIR"
add-text
add-text 'USER $NB_UID'

perl -i -p0e 's/ && \\\n    fix-permissions/\nUSER root\nRUN fix-permissions/igs' "$TEMPLATE"

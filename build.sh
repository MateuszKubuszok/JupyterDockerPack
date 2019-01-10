#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR="$DIR/.tmp"
TEMPLATE="$WORKDIR/Dockerfile"

mkdir -p "$WORKDIR"

# create Dockerfile aggregating our changes and jupyter official recipies
echo      '# jupyter/all-spark-notebook:latest start'                                                                          >  "$TEMPLATE"
echo      'FROM jupyter/all-spark-notebook:latest'                                                                             >> "$TEMPLATE"
echo      '# jupyter/all-spark-notebook:latest end'                                                                            >> "$TEMPLATE"
echo                                                                                                                           >> "$TEMPLATE"
echo      'LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"'                                                   >> "$TEMPLATE"
echo                                                                                                                           >> "$TEMPLATE"
echo      '# jupyter/datascience-notebook:latest start'                                                                        >> "$TEMPLATE"
curl -sSL 'https://raw.githubusercontent.com/jupyter/docker-stacks/master/datascience-notebook/Dockerfile' | tail --lines +8 - >> "$TEMPLATE"
echo      '# jupyter/datascience-notebook:latest end'                                                                          >> "$TEMPLATE"
echo                                                                                                                           >> "$TEMPLATE"
echo      '# jupyter/tensorflow-notebook:latest start'                                                                         >> "$TEMPLATE"
curl -sSL 'https://raw.githubusercontent.com/jupyter/docker-stacks/master/tensorflow-notebook/Dockerfile'  | tail --lines +8 - >> "$TEMPLATE"
echo      '# jupyter/tensorflow-notebook:latest end'                                                                           >> "$TEMPLATE"
echo                                                                                                                           >> "$TEMPLATE"
echo      '# jupyter/r-notebook:latest start'                                                                                  >> "$TEMPLATE"
curl -sSL 'https://raw.githubusercontent.com/jupyter/docker-stacks/master/r-notebook/Dockerfile'           | tail --lines +8 - >> "$TEMPLATE"
echo      '# jupyter/r-notebook:latest end'                                                                                    >> "$TEMPLATE"
echo                                                                                                                           >> "$TEMPLATE"
echo      "# $DIR/Dockerfile start"                                                                                            >> "$TEMPLATE"
cat       "$DIR/Dockerfile"                                                                                                    >> "$TEMPLATE"
echo      "# $DIR/Dockerfile end"                                                                                              >> "$TEMPLATE"

docker build -t kubuszok/jupyter-pack:local --rm --force-rm "$WORKDIR"

#!/bin/bash

set -Eeo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR="$DIR/out"
TEMPLATE="$WORKDIR/Dockerfile"

# reset to an empty file
mkdir -p  "$WORKDIR"
rm    -rf "$TEMPLATE"   
touch     "$TEMPLATE"

# utils
add-text() { echo "$1" >> "$TEMPLATE"; }
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
fix-file() {
  perl -i -p0e "s/$1/$2/igs" "$TEMPLATE"
}

# create Dockerfile aggregating our changes and jupyter official recipies
add-text "#### Generated at $(LC_ALL=en_DB.utf8 date)"
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

# patch for unifiyng style
fix-file 'RUN     ' 'RUN '
fix-file 'USER    ' 'USER '
# patch for fix-permissions: operation not permitted
fix-file ' && \\\n    fix-permissions' '\nUSER root\nRUN fix-permissions'
fix-file 'USER jovyan' 'RUN fix-permissions \$CONDA_DIR\nRUN fix-permissions \/home\/\$NB_USER\nUSER \$NB_UID'
fix-file 'python -m ((\S| )+)' 'python -m $1\nUSER root\nRUN fix-permissions \/home\/\$NB_USER\nUSER \$NB_UID'
fix-file 'RUN conda install -y feather-format -c conda-forge' 'USER root\nRUN fix-permissions \$CONDA_DIR\nRUN fix-permissions \/home\/\$NB_USER\nUSER \$NB_USER\nRUN conda install -y feather-format -c conda-forge'
# patches SoS outdated image
fix-file 'apt-get purge --auto-remove nodejs npm node' 'apt-get purge --auto-remove nodejs npm'
fix-file 'apt-get install -y nodejs-legacy npm' 'apt-get install -y nodejs npm'
fix-file 'RUN add-apt-repository -y ppa:staticfloat\/juliareleases' '#RUN -apt-repository -y ppa:staticfloat\/juliareleases'
fix-file 'RUN apt-get install -y julia' '#RUN -get install -y julia'
fix-file 'RUN pip install sklearn' '#RUN pip install sklearn'
fix-file 'pip install' 'pip install --no-cache-dir'
fix-file 'RUN julia -e "ENV' '#RUN julia -e "ENV'
fix-file "RUN julia -e 'Pkg" "#RUN julia -e 'Pkg"
# remove useless args
fix-file 'DUMMY=\$\{DUMMY\} pip' 'pip'

# TODO
# ls -la $HOME/.local/share/jupyter/*
# mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
#     chmod -R go+rx $CONDA_DIR/share/jupyter && \
#     rm -rf $HOME/.local
# same with css


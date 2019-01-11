#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR="$DIR/out"
TEMPLATE="$WORKDIR/Dockerfile"

docker build -t kubuszok/jupyter-pack:local --rm --force-rm --build-arg DUMMY=`date +%s` "$WORKDIR"

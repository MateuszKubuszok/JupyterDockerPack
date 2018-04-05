#!/bin/bash
if [ ! -z $1 ]; then
	docker tag kubuszok/jupyter-pack:local kubuszok/jupyter-pack:$1
  docker push kubuszok/jupyter-pack:$1
else
	echo "Add missing tag like 'latest'"
fi

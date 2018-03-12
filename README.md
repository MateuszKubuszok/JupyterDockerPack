# Jupyter Docker Pack

Based on/copy-pasted from:

 * https://github.com/jupyter/docker-stacks - taken `all-spark-notebook` and added `tensorflow` and `datascience` `Dockerfile`s' content, Ruby taken from an open PR
 * https://github.com/saagie/jupyter-haskell-notebook - Haskell support
 * https://github.com/3Dcube/docker-jupyter-cling - C++ support
 * https://github.com/dting/docker-jupyter-go-js - JavaScript support

This image has no contribution from me, but since Docker do not allow combining layers and I wanted all-in-one package...

Personally, I run it like:

    docker run -d -v ~:/home/jovyan -p 8888:8888 kubuszok/jupyter-pack start.sh jupyter-lab

For advanced usage consult https://github.com/jupyter/docker-stacks as I haven't changed how it works.


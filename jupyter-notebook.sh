#!/bin/bash
docker run -it -p 8888:8888 kubuszok/jupyter-pack:latest jupyter-notebook --ip=0.0.0.0

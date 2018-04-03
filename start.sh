#!/bin/sh
if [ ! -z $JAVA_VERSION ]; then
  sudo archlinux-java set $JAVA_VERSION
fi
jupyter-lab --ip=0.0.0.0

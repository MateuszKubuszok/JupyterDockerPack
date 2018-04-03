# Jupyter Docker Pack

Docker image containing a few kernels preinstalled:

 * C++
 * Clojure
 * Haskell
 * Java - appears to only work in Jupyter Notebook, not Jupyter Lab
 * JavaScript
 * Python 2
 * Python 3
 * ~~Spark~~ - not idea why it is not working

(No, it does not contain Tensorflow and the likes).

## Usage

You can run it with:

    docker run -ti -p 8888:8888 kubuszok/jupyter-pack

if you need to use Jupyter Notebook instead (e.g. Java kernel does not work with Jupyter Lab) use:

    docker run -ti -p 8888:8888 kubuszok/jupyter-pack jupyter-notebook --ip=0.0.0.0

By default it uses Java 8. If you want to run it with Java 9 (for Java notebook only, as the rest of
kernels works poorly with JRE 9) use:

    docker run -ti -p 8888:8888 -e JAVA_VERSION=java-9-openjdk kubuszok/jupyter-pack

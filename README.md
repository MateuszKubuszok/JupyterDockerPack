# Jupyter Docker Pack

Docker image containing a few kernels preinstalled:

 * C++
 * Clojure
 * Haskell
 * Java - appears to only work in Jupyter Notebook, not Jupyter Lab
 * JavaScript
 * Python 2
 * Python 3
 * Ruby
 * Scala (via Apache Toree)

(No, it does not contain Tensorflow and the likes).

## Usage

You can run it with:

    docker run -ti -p 8888:8888 kubuszok/jupyter-pack:latest

if you need to use Jupyter Notebook instead (e.g. Java kernel does not work with Jupyter Lab) use:

    docker run -ti -p 8888:8888 -e LEGACY=1 kubuszok/jupyter-pack:latest

Out of the box it uses Java 8. If you want to switch to Java 9 (for Java notebook only, as the rest of
kernels works poorly with JRE 9) use:

    docker run -ti -p 8888:8888 -e JAVA=java-9-openjdk kubuszok/jupyter-pack:latest

This change is preserved between runs. To restore Java 8 (required by e.g. Scala):

    docker run -ti -p 8888:8888 -e JAVA=java-8-openjdk kubuszok/jupyter-pack:latest

## Notice

Some kernels (esp. Haskell) might take a while to start the first time you use them.

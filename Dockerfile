FROM jupyter/all-spark-notebook

LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"

USER root

## Add Tensorflow

# Install Tensorflow
RUN conda install --quiet --yes \
    'tensorflow=1.3*' \
    'keras=2.0*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

## Add R and Julia

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=0.6.2

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "dc6ec0b13551ce78083a5849268b20684421d46a7ec46b17ec1fab88a5078580 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda config --system --append channels r && \
    conda install --quiet --yes \
    'rpy2=2.8*' \
    'r-base=3.3.2' \
    'r-irkernel=0.7*' \
    'r-plyr=1.8*' \
    'r-devtools=1.12*' \
    'r-tidyverse=1.0*' \
    'r-shiny=0.14*' \
    'r-rmarkdown=1.2*' \
    'r-forecast=7.3*' \
    'r-rsqlite=1.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.2*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Add Julia packages
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'Pkg.init()' && \
    julia -e 'Pkg.update()' && \
    julia -e 'Pkg.add("HDF5")' && \
    julia -e 'Pkg.add("Gadfly")' && \
    julia -e 'Pkg.add("RDatasets")' && \
    julia -e 'Pkg.add("IJulia")' && \
    # Precompile Julia packages \
    julia -e 'using HDF5' && \
    julia -e 'using Gadfly' && \
    julia -e 'using RDatasets' && \
    julia -e 'using IJulia' && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter

## Add Haskell

USER root

# Add IHaskell kernel
RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
    libzmq3-dev \
    libncurses-dev \
    pkg-config

# Install Haskell
RUN wget -qO- https://get.haskellstack.org/ | sh

# Create default workdir (useful if no volume mounted)
RUN mkdir /notebooks-dir && chown 1000:100 /notebooks-dir

USER $NB_USER
RUN stack --install-ghc --resolver lts-9.20 install ghc-parser ipython-kernel ihaskell && ~/.local/bin/ihaskell install

ENV PATH=${PATH}:/home/jovyan/.local/bin:/home/jovyan/.stack/programs/x86_64-linux/ghc-8.0.2/bin/

## Add Ruby

USER root

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
      libtool \
      automake \
      autoconf \
      pkg-config \
      libffi-dev \
      libzmq3-dev \
      libczmq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install czmq based on https://github.com/SciRuby/iruby
# CZTop requires CZMQ >= 4.0.0 and ZMQ >= 4.2.0
RUN git clone https://github.com/zeromq/czmq /root/czmq && \
    cd /root/czmq && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    rm -rf /root/czmq

ENV RUBY_VERSION 2.4.2
ENV ZEROMQ_VERSION 4.2.1

RUN conda config --add channels conda-forge
RUN conda install -y \
      ruby="$RUBY_VERSION" \
      zeromq="$ZEROMQ_VERSION"

# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> ~/.gemrc

# install iruby & register to jupyter kernelspec
RUN gem install cztop
RUN gem install iruby
RUN iruby register --force
RUN jupyter kernelspec install .ipython/kernels/ruby

RUN chown -R $NB_USER .local

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER

## Add C++

# Install cling dependencies
USER root
RUN apt-get update && \
    apt-get install -yq --no-install-recommends git g++ debhelper devscripts gnupg

# Create cling folder
RUN mkdir /cling
RUN chown -R $NB_USER:users /cling
WORKDIR /cling

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN chown -R $NB_USER:users /etc/jupyter/
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/start-notebook.sh /usr/local/bin/start-singleuser.sh 

# Download cling from https://root.cern.ch/download/cling/
USER $NB_USER
COPY download_cling.py download_cling.py
RUN python download_cling.py

# install cling kernel
WORKDIR /cling/share/cling/Jupyter/kernel
RUN pip install -e .
RUN jupyter-kernelspec install --user cling-cpp11

WORKDIR $HOME

## Add Clojure

ENV CLOJUPYTER_PATH $HOME/clojupyter
ENV LEIN_ROOT=1

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xb8d7f7791716c8a4
RUN echo "deb http://ppa.launchpad.net/mikegedelman/leiningen-git-stable/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/mikegedelman/leiningen-git-stable/ubuntu trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -yq python-setuptools \
        python-dev \
        build-essential \
        curl \
        default-jre \
        leiningen

RUN lein self-install

# Install clojupyter
RUN mkdir $CLOJUPYTER_PATH
COPY clojupyter $CLOJUPYTER_PATH
WORKDIR $CLOJUPYTER_PATH
RUN make
RUN make install

## Add JavaScript

RUN apt-get update
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs libzmq3-dev build-essential && npm install -g ijavascript
RUN ijs --ijs-install-kernel


# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER


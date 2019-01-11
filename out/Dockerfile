#### Fri Jan 11 02:09:17 CET 2019

#### jupyter/all-spark-notebook:latest start
FROM jupyter/all-spark-notebook:latest
#### jupyter/all-spark-notebook:latest end

LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"

#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/datascience-notebook/Dockerfile start (skip 8 first, 0 last lines)
# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.0

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "bea4570d7358016d8ed29d2c15787dbefaea3e746c570763e7ad6040f17831f3 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR
USER root
RUN fix-permissions $JULIA_PKGDIR

USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    'rpy2=2.9*' \
    'r-base=3.5.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.2*' \
    'r-shiny=1.2*' \
    'r-rmarkdown=1.11*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=1.0*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.9*' \
    'r-htmlwidgets=1.2*' \
    'r-hexbin=1.27*' && \
    conda clean -tipsy
USER root
RUN fix-permissions $CONDA_DIR
USER root
RUN fix-permissions /home/$NB_USER

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    julia -e 'import Pkg; Pkg.add("Gadfly")' && \
    julia -e 'import Pkg; Pkg.add("RDatasets")' && \
    julia -e 'import Pkg; Pkg.add("IJulia")' && \
    # Precompile Julia packages \
    julia -e 'using IJulia' && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local
USER root
RUN fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter
#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/datascience-notebook/Dockerfile end

#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/tensorflow-notebook/Dockerfile start (skip 8 first, 0 last lines)
# Install Tensorflow
RUN conda install --quiet --yes \
    'tensorflow=1.12*' \
    'keras=2.2*' && \
    conda clean -tipsy
USER root
RUN fix-permissions $CONDA_DIR
USER root
RUN fix-permissions /home/$NB_USER
#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/tensorflow-notebook/Dockerfile end

#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/r-notebook/Dockerfile start (skip 8 first, 0 last lines)
USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# R packages
RUN conda install --quiet --yes \
    'r-base=3.5.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.2*' \
    'r-shiny=1.2*' \
    'r-rmarkdown=1.11*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=1.0*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.9*' \
    'r-htmlwidgets=1.2*' \
    'r-hexbin=1.27*' && \
    conda clean -tipsy
USER root
RUN fix-permissions $CONDA_DIR
#### https://raw.githubusercontent.com/jupyter/docker-stacks/master/r-notebook/Dockerfile end

#### https://raw.githubusercontent.com/vatlab/SoS/master/development/docker-notebook/Dockerfile start (skip 14 first, 10 last lines)
USER    root

#       Tools
RUN     apt-get update
RUN     apt-get install -y graphviz
RUN     apt-get install -y texlive-xetex texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended

RUN     apt-get install -y octave
#RUN     octave --eval 'pkg install -forge dataframe'

RUN     apt-get purge --auto-remove nodejs npm node
RUN     rm -rf ~/.nvm 
RUN     apt-get install -y nodejs-legacy npm

RUN     apt-get install -y libgmp3-dev
RUN     apt-get install -y software-properties-common
RUN     add-apt-repository -y ppa:staticfloat/juliareleases
#RUN     add-apt-repository -y ppa:staticfloat/julia-deps
RUN     apt-get update
RUN     apt-get install -y julia

# Install some packages for our examples
#RUN     R --slave -e 'install.packages(c("package1", "package2"), lib="/usr/local/lib/R/site-library")'
RUN     R --slave -e 'source("https://bioconductor.org/biocLite.R"); biocLite("biomaRt")'
RUN     R --slave -e 'install.packages("glmnet", repos="http://cran.us.r-project.org")'
RUN     pip install sklearn

USER    jovyan

#       Bash
RUN     pip install bash_kernel
RUN     python -m bash_kernel.install --user

#       Octave
RUN     pip install octave_kernel
RUN     python -m octave_kernel install --user

#       JavaScript
RUN     npm rebuild
RUN     npm install -g ijavascript
RUN     ijsinstall --spec-path=full

#       SPARQL kernel for testing
RUN     cd /tmp && git clone https://github.com/asanchez75/sparql-kernel.git && cd /tmp/sparql-kernel && python setup.py install
RUN     jupyter sparqlkernel install --user

#        Julia
RUN     julia -e "ENV[\"JUPYTER\"]=\"$(which jupyter)\";Pkg.add(\"IJulia\")"
RUN     julia -e 'Pkg.add("Feather")'
RUN     julia -e 'Pkg.add("DataFrames")'
RUN     julia -e 'Pkg.add("NamedArrays")'

#       Python 2
RUN     conda create -n ipykernel_py2 python=2 ipykernel
RUN     /bin/bash -c "source activate ipykernel_py2; python -m ipykernel install --user; source deactivate"

#       Markdown kernel
RUN     pip install markdown-kernel
RUN     python -m markdown_kernel.install

# Bioinfo
RUN     pip install pysam

# for testing
RUN     pip install xlsx2csv bs4

# SOS
RUN     pip install pip --upgrade
RUN     pip install xlrd docker
RUN     pip install markdown wand graphviz imageio pillow 


RUN     conda install -y feather-format -c conda-forge
RUN     pip install nbformat --upgrade
## trigger rerun for sos updates
ARG	    DUMMY=unknown
RUN     DUMMY=${DUMMY} pip install sos sos-notebook sos-r sos-julia sos-python sos-matlab sos-javascript sos-bash sos-bioinfo --upgrade
RUN     python -m sos_notebook.install
RUN     pip install jupyterlab
RUN     jupyter labextension install jupyterlab-sos

#### https://raw.githubusercontent.com/vatlab/SoS/master/development/docker-notebook/Dockerfile end

#### /home/dev/Workspaces/MateuszKubuszok/JupyterDockerPack/Dockerfile start
# Install Cling (C++)
USER $NB_UID
RUN conda install --quiet --yes xeus-cling -c QuantStack -c conda-forge && \
    conda clean -tipsy
USER root
RUN fix-permissions $CONDA_DIR
USER root
RUN fix-permissions /home/$NB_USER

# Install Haskell
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends python3-pip git libtinfo-dev libzmq3-dev libcairo2-dev libpango1.0-dev libmagic-dev libblas-dev liblapack-dev && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID
RUN curl -sSL https://get.haskellstack.org/ | sh && \
    git clone https://github.com/gibiansky/IHaskell && \
    pushd IHaskell && \
    pip3 install -r requirements.txt && \
    stack install --fast && \
    ihaskell install --stack && \
    popd && \
    rm -rf IHaskell
USER root
RUN fix-permissions /home/$NB_USER

# Install Java and Clojure
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends leiningen openjdk-11-jdk unzip && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-11-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

USER $NB_UID
RUN mkdir -p /tmp/ijava && \
    curl -sSL https://github.com/SpencerPark/IJava/releases/download/v1.2.0/ijava-1.2.0.zip -o /tmp/ijava.zip && \
    unzip /tmp/ijava.zip -d /tmp/ijava && \
    pushd /tmp/ijava && \
    python install.py --user && \
    popd && \
    git clone https://github.com/clojupyter/clojupyter /tmp/clojupyter && \
    pushd /tmp/clojupyter && \
    make && \
    as-user make install && \
    popd && \
    rm -rf /tmp/ijava /tmp/ijava.zip
USER root
RUN fix-permissions /home/$NB_USER

# Install Ruby
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends libtool libffi-dev ruby ruby-dev make libzmq3-dev libczmq-dev && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g ijavascript

USER $NB_UID
RUN gem install cztop iruby && \
    iruby register --force
#### /home/dev/Workspaces/MateuszKubuszok/JupyterDockerPack/Dockerfile end

USER $NB_UID

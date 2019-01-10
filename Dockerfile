# Cling (C++)
USER $NB_UID
RUN conda install --quiet --yes xeus-cling -c QuantStack -c conda-forge && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# Haskell
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
    rm -rf IHaskell && \
    fix-permissions /home/$NB_USER


# Java and Clojure
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
    rm -rf /tmp/ijava /tmp/ijava.zip && \
    fix-permissions /home/$NB_USER


# Ruby
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends libtool libffi-dev ruby ruby-dev make libzmq3-dev libczmq-dev && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g ijavascript

USER $NB_UID
RUN gem install cztop iruby && \
    iruby register --force


# ensure user is $NB_UID
USER $NB_UID

# Install Cling (C++)
USER $NB_UID
RUN conda install --quiet --yes xeus-cling -c QuantStack -c conda-forge && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install Haskell
ENV PATH=$PATH:/home/$NB_USER/.local/bin

#   figure out if something from /opt/ihaskell could be deleted
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-pip git python3-setuptools libtinfo-dev libzmq3-dev libcairo2-dev libpango1.0-dev libmagic-dev libblas-dev liblapack-dev && \
    curl -sSL https://get.haskellstack.org/ | sh && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    git clone https://github.com/gibiansky/IHaskell /opt/ihaskell && \
    cd /opt/ihaskell && \
    pip3 install -r requirements.txt && \
    stack install --fast && \
    ln -s /opt/conda/lib/libtinfo.so.6.1 /lib/x86_64-linux-gnu/libtinfo.so.6 && \
    cd /home/$NB_USER && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /opt/ihaskell && \
    fix-permissions /home/$NB_USER

USER $NB_UID
RUN ihaskell install --stack && \
    echo jupyter notebook only for now # jupyter labextension install ihaskell_jupyterlab

# Install Java and Clojure
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends leiningen openjdk-11-jdk unzip && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

ENV JAVA_HOME /usr/lib/jvm/java-11-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

USER $NB_UID
RUN mkdir -p "/tmp/ijava" && \
    curl -sSL https://github.com/SpencerPark/IJava/releases/download/v1.2.0/ijava-1.2.0.zip -o /tmp/ijava.zip && \
    unzip /tmp/ijava.zip -d /tmp/ijava && \
    cd /tmp/ijava && \
    python install.py --user && \
    cd .. && \
    git clone https://github.com/clojupyter/clojupyter /tmp/clojupyter && \
    cd /tmp/clojupyter && \
    make && \
    make install && \
    cd .. && \
    rm -rf /tmp/ijava /tmp/ijava.zip && \
    fix-permissions /home/$NB_USER /usr/local/bin

# Install Ruby
USER root
RUN apt-get update && \
    apt-get install -y -y --no-install-recommends libtool libffi-dev ruby ruby-dev make libzmq3-dev libczmq-dev && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions /var/lib/gems/ 

USER $NB_UID
RUN gem install cztop iruby && \
    iruby register --force

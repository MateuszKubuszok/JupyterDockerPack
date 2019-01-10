FROM antergos/makepkg:latest

LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"

# Basic preparations (jupyter user and aliases)
USER root
RUN pacman -Syyuu --noconfirm && \
    pacman -Sy --noconfirm yaourt && \
    pacman -Sy --noconfirm sudo && \
    chmod 640 /etc/sudoers && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && chmod 440 /etc/sudoers && useradd -m -p123123 -G wheel jupyter
WORKDIR /tmp
ENV NB_USER jupyter
ENV NB_HOME /home/$NB_USER
COPY aliases/* /usr/local/bin/

# Jupyter Lab
RUN yaourt-install \
        npm \
        yarn && \
    chown -R jupyter /home/jupyter && \
    yaourt-install \
        npm \
        yarn \
        ipython \
        ipython2 \
        python-ipykernel \
        python-matplotlib \
        python-numpy \
        python-scipy \
        python2-ipykernel \
        python2-numpy \
        python2-scipy \
        jupyterlab-git && \
    as-user python -m ipykernel install --user && \
    as-user python2 -m ipykernel install --user && \
    yaourt-clean

# Spark and Apache Toree (Scala)
ENV APACHE_SPARK_VERSION 2.4.0
ENV HADOOP_VERSION 2.7
ENV SPARK_HADOOP_SHA 5F4184E0FE7E5C8AE67F5E6BC5DEEE881051CC712E9FF8AEDDF3529724C00E402C94BB75561DD9517A372F06C1FCB78DC7AE65DCBD4C156B3BA4D8E267EC2936
RUN yaourt-install \
        jdk8-openjdk \
        jdk11-openjdk \
        clang \
        python-pip && \
    pip install --upgrade pip && \
    wget -q http://apache.claz.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    echo "${SPARK_HADOOP_SHA} *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt --owner root --group root --no-same-owner && \
    ln -s /opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    yaourt-clean spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
# Workaround for broken mesos AUR
RUN archlinux-java set java-8-openjdk && \
    as-user gpg --recv-keys D10295D0D6EF55AD && \
    as-user git clone https://aur.archlinux.org/mesos.git /tmp/mesos && \
    pushd /tmp/mesos && \
    sed -i 's/pkgver=1.5.0/pkgver=1.5.1/' /tmp/mesos/PKGBUILD && \
    sed -i 's/PYTHON=python${_python2_ver_major} \\/export PYTHON=python${_python2_ver_major} CXX=clang++ CC=clang CXXFLAGS="-fno-strict-aliasing -Wno-enum-compare-switch" CPPFLAGS="-fno-strict-aliasing -Wno-enum-compare-switch"/' /tmp/mesos/PKGBUILD && \
    sed -i 's/--with-network-isolator/--with-network-isolator --disable-werror/' /tmp/mesos/PKGBUILD && \
    as-user makepkg -siL --noconfirm && \
    popd && \
    yaourt-clean $NB_HOME/.m2 /tmp/mesos
ENV SPARK_HOME /opt/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN pip install --no-cache-dir https://dist.apache.org/repos/dist/release/incubator/toree/0.3.0-incubating/toree-pip/toree-0.3.0.tar.gz && \
    jupyter toree install --spark_home=/opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} && \
    yaourt-clean

# Cling (C++)
RUN yaourt-install \
        cling-jupyter-git && \
    yaourt-clean

# Haskell
RUN yaourt-install \
      blas \
      cairo \
      lapack \
      pango \
      zeromq && \
    curl -sSL https://get.haskellstack.org/ | as-user sh && \
    as-user git clone https://github.com/gibiansky/IHaskell $NB_HOME/IHaskell && \
    pushd $NB_HOME/IHaskell && \
    as-user pip3 install --user -r requirements.txt && \
    as-user stack install gtk2hs-buildtools && \
    as-user stack install --fast && \
    as-user $NB_HOME/.local/bin/ihaskell install --stack && \
    popd && \
    yaourt-clean $NB_HOME/.stack/{indices,programs} $NB_HOME/IHaskell

# Java and Clojure
RUN yaourt-install \
        leiningen \
        unzip && \
    archlinux-java set java-11-openjdk && \
    as-user mkdir -p /tmp/ijava && \
    as-user curl -sSL https://github.com/SpencerPark/IJava/releases/download/v1.2.0/ijava-1.2.0.zip -o /tmp/ijava.zip && \
    as-user unzip /tmp/ijava.zip -d /tmp/ijava && \
    pushd /tmp/ijava && \
    as-user python install.py --user && \
    popd && \
    archlinux-java set java-8-openjdk && \
    git clone https://github.com/clojupyter/clojupyter /tmp/clojupyter && \
    cd /tmp/clojupyter && \
    make && \
    as-user make install && \
    yaourt-clean $NB_HOME/.m2 /tmp/ijava /tmp/ijava.zip

# JavaScript
RUN yaourt-install \
        node \
        npm && \
    npm install -g ijavascript && \
    as-user ijsinstall && \
    yaourt-clean $NB_HOME/{.node-gyp,.npm}

# Ruby
RUN yaourt-install \
        ruby-iruby && \
    as-user iruby register --force && \
    yaourt-clean

# Prepare image for running
USER jupyter
WORKDIR $NB_HOME
COPY jupyter-run /usr/local/bin/jupyter-run

EXPOSE 8888
CMD jupyter-run

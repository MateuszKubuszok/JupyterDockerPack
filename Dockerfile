FROM antergos/makepkg:latest

LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"

# basic preparations
USER root
RUN pacman -Sy --noconfirm yaourt && \
    pacman -Sy --noconfirm sudo && \
    chmod 640 /etc/sudoers && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && chmod 440 /etc/sudoers && useradd -m -p123123 -G wheel jupyter
WORKDIR /tmp
ENV NB_USER=jupyter

# Jupyter Lab
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            ipython \
            ipython2 \
            python-ipykernel \
            python-matplotlib \
            python-numpy \
            python2-ipykernel \
            python2-numpy \
            python2-scipy \
            jupyterlab-git && \
    sudo -u $NB_USER python -m ipykernel install --user && \
    sudo -u $NB_USER python2 -m ipykernel install --user

# C++
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            cling-jupyter-git

# Haskell
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            cairo \
            ghc \
            happy \
            haskell-gtk2hs-buildtools  \
            pango \
            stack && \
    git clone https://aur.archlinux.org/ihaskell-git.git /opt/ihaskell-git && \
    chown $NB_USER /opt/ihaskell-git -R && \
    cd /opt/ihaskell-git && \
    sudo -u $NB_USER makepkg && \
    sudo -u $NB_USER /home/$NB_USER/.local/bin/ihaskell install --stack

# Java and Clojure
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            jdk9-openjdk \
            leiningen && \
    archlinux-java set java-9-openjdk && \
    sudo -u $NB_USER yaourt -Sy --noconfirm \
            ijava-git && \
    git clone https://github.com/clojupyter/clojupyter /tmp/clojupyter && \
    cd /tmp/clojupyter && \
    make && \
    sudo -u $NB_USER make install && \
    rm /tmp/clojupyter -rf

# JavaScript
RUN cd /home/$NB_USER && \
    sudo -u $NB_USER yaourt -Sy --noconfirm \
            ijavascript

# Ruby
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            ruby-iruby && \
    sudo -u $NB_USER iruby register --force

# Spark
ENV APACHE_SPARK_VERSION 2.3.0
ENV HADOOP_VERSION 2.7
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            python-pip && \
    pip install --upgrade pip && \
    wget -q http://apache.claz.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    echo "258683885383480BA01485D6C6F7DC7CFD559C1584D6CEB7A3BBCF484287F7F57272278568F16227BE46B4F92591768BA3D164420D87014A136BF66280508B46 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt --owner root --group root --no-same-owner && \
    ln -s /opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            jdk8-openjdk && \
    archlinux-java set java-8-openjdk && \
    sudo -u $NB_USER gpg --recv-keys D10295D0D6EF55AD && \
    sudo -u $NB_USER yaourt -Sy --noconfirm \
           mesos && \
    archlinux-java set java-9-openjdk
ENV SPARK_HOME /opt/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.6-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN pip install --no-cache-dir https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0-incubating-rc3/toree-pip/toree-0.2.0.tar.gz && \
    jupyter toree install --spark_home=/opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

# Prepare image for running
RUN rm /tmp/* -rf
RUN archlinux-java set java-8-openjdk
USER jupyter
WORKDIR /home/$NB_USER
RUN rm /home/$NB_USER/* -rf
COPY start.sh /usr/local/bin/start.sh

ENV PORT 8888
EXPOSE 8888
CMD start.sh

FROM antergos/makepkg:latest

# basic preparations
USER root
RUN pacman -Sy --noconfirm yaourt && \
    pacman -Sy --noconfirm sudo && \
    chmod 640 /etc/sudoers && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && chmod 440 /etc/sudoers && useradd -m -p123123 -G wheel jupyter
WORKDIR /tmp
ENV NB_USER=jupyter

# Jupyter lab
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
            pango \
            stack
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            ghc \
            happy \
            haskell-gtk2hs-buildtools && \
    git clone https://aur.archlinux.org/ihaskell-git.git /opt/ihaskell-git && \
    chown $NB_USER /opt/ihaskell-git -R && \
    cd /opt/ihaskell-git && \
    sudo -u $NB_USER makepkg
RUN sudo -u $NB_USER /home/$NB_USER/.local/bin/ihaskell --install stack

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
            ijavascript && \
    sudo -u $NB_USER ijsinstall

# Ruby
RUN sudo -u $NB_USER yaourt -Sy --noconfirm \
            ruby-iruby && \
    sudo -u $NB_USER iruby register --force

# Scala
RUN wget -q -O - https://raw.githubusercontent.com/alexarchambault/jupyter-scala/master/jupyter-scala | sed -e 's|2.11.11|2.12.2|' | sudo -u $NB_USER bash

# Prepare image for running
RUN rm /tmp/* -rf
USER jupyter
WORKDIR /home/$NB_USER
RUN rm /home/$NB_USER/* -rf

EXPOSE 8888:8888
CMD jupyterlab --ip=0.0.0.0

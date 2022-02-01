FROM seebaktec/pyenv

ARG VERSION=0.0.0
ARG NODEJS_VERSION=setup_16.x
ARG PYTHON3_VERSION=3.9.9

LABEL "Version" = $VERSION
LABEL "Name" = "devtools-nvim"

USER root

# Adding NodeSource repository before install packages
RUN curl -sL https://deb.nodesource.com/$NODEJS_VERSION | sudo -E bash - \
    && apt-get install -y -q --allow-unauthenticated \
    autoconf \
    automake \
    fish \
    g++ \
    libtool \
    libtool-bin \
    lua5.3 \
    ninja-build \
    nodejs \
    openssh-server \
    pkg-config \
    silversearcher-ag \
    unzip \
    xclip \
    xfonts-utils \
    xauth \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* 

# Configuation ssh
RUN mkdir /run/sshd \
    && echo "X11UseLocalhost no">>/etc/ssh/sshd_config

# Installing neovim
RUN cd /usr/src                                                   \
    && git clone https://github.com/neovim/neovim.git             \
    && cd neovim                                                  \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo                       \
            CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local" \
    && make install                                               \
    && rm -r /usr/src/neovim

USER admin

ENV HOME=/home/admin \
    PYENV_ROOT=$HOME/.pyenv \
    PATH=/home/admin/.pyenv/shims:/home/admin/.pyenv/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:.  \
    PYTHON3_HOST_PROG=/home/admin/.pyenv/versions/neovim3/bin/python \
    PYENV_VIRTUALENV_DISABLE_PROMPT=1

WORKDIR $HOME

COPY --chown=admin zshrc ./.zshrc

# Installing Spacevim
RUN pyenv install $PYTHON3_VERSION \
    && pyenv global $PYTHON3_VERSION \
    && pyenv rehash \
    && pyenv virtualenv $PYTHON3_VERSION neovim3 \
    && eval "$(pyenv init -)" \
    && eval "$(pyenv virtualenv-init -)" \
    && pyenv activate neovim3 \
    && pip install --upgrade pip \
    && pip install neovim \
    && mkdir -p $HOME/.config $HOME/.SpaceVim.d \
    && curl -sLf https://spacevim.org/install.sh | bash -s -- --install neovim \
    && sudo npm install -g neovim \
    && sudo chmod 707 $HOME/.cache/nvim

COPY --chown=admin myspacevim.vim $HOME/.SpaceVim.d/autoload/myspacevim.vim 

COPY --chown=admin init.toml $HOME/.SpaceVim.d/init.toml

# Library compilation and touch to update the date of the init.toml
RUN touch $HOME/.SpaceVim.d/init.toml \
    && make -C $HOME/.SpaceVim/bundle/vimproc.vim \
    && nvim --headless +'UpdateRemotePlugins' +"q!"  

COPY --chown=admin rplugin.vim /home/admin/.local/share/nvim/rplugin.vim

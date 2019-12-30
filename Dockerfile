FROM heichblatt/archlinux-yaourt

ARG REPO=https://github.com/loochao/walnut-i3.git 

# Fix package-query
USER root
RUN pacman --noconfirm -R yaourt package-query \
    && pacman --noconfirm -Syu

# yaourt reinstallation
USER user
RUN cd /tmp && git clone https://aur.archlinux.org/package-query.git \
    && cd /tmp/package-query && makepkg --noconfirm -si \
    && cd /tmp && git clone https://aur.archlinux.org/yaourt.git \
    && cd /tmp/yaourt && makepkg --noconfirm -si

# Update AUR packages
RUN yaourt --noconfirm -Sua

# System configuration
USER root
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen

# Install some graphical packages
USER user
RUN yaourt --noconfirm -S xorg-server xorg-apps xorg-xinit xterm pulseaudio pulseaudio-ctl \
    && yaourt --noconfirm -S openssh zsh

# Python
# RUN yaourt --noconfirm -S python-pip python-virtualenvwrapper  \
#    && yaourt --noconfirm -S npm

USER root
# Clone user dotfiles
RUN cd /etc/skel && git clone $REPO 

USER user
RUN /etc/skel/docker-dotfiles/commons/user/.bin/install_bootstrap
RUN /etc/skel/docker-dotfiles/commons/user/.bin/install_commons


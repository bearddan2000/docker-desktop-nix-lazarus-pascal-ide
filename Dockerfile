FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV DISPLAY :0

# nixpkgs-unstable
ENV NIX_CHANNEL nixpkgs

# https://nixos.org/channels/nixpkgs-unstable
ENV NIX_CHANNEL_URL https://nixos.org/channels/nixos-22.05

ENV NIX_PKG lazarus

ENV NIX_PKG_EXEC lazarus-ide

ENV USERNAME developer

WORKDIR /app

RUN apt update

RUN apt-get install -y --no-install-recommends \
    apt-transport-https \
    software-properties-common \
    fpc make nix sudo

RUN nix-channel --add $NIX_CHANNEL_URL $NIX_CHANNEL \
    && nix-channel --update \
    && nix-env -iA $NIX_CHANNEL.$NIX_PKG \
    && nix-build "<${NIX_CHANNEL}>" -A $NIX_PKG \
    && ln -s /app/result/bin/$NIX_PKG_EXEC /bin/$NIX_PKG_EXEC

# create and switch to a user
RUN echo "backus ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd --no-log-init --home-dir /home/$USERNAME --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo

USER $USERNAME

WORKDIR /home/$USERNAME

CMD $NIX_PKG_EXEC
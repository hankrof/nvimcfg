#!/usr/bin/env bash

set -Eeuo pipefail

readonly UBUNTU_IMAGE="${UBUNTU_IMAGE:-ubuntu:24.04}"
readonly ARCH_IMAGE="${ARCH_IMAGE:-archlinux:latest}"

readonly -a UBUNTU_PACKAGES=(
    nodejs
    npm
    yarnpkg
    cmake
    universal-ctags
    git
    luarocks
    clang
    curl
    neovim
)

readonly -a ARCH_PACKAGES=(
    nodejs
    npm
    yarn
    cmake
    ctags
    git
    luarocks
    lua51
    clang
    curl
    neovim
)

command -v docker > /dev/null 2>&1 || {
    echo "docker is required" >&2
    exit 1
}

echo "Testing package installation on Ubuntu ($UBUNTU_IMAGE) ..."
docker run --rm "$UBUNTU_IMAGE" \
    bash -c '
        set -Eeuo pipefail
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
        nvim --headless --clean -n -i NONE "+qall"
    ' bash "${UBUNTU_PACKAGES[@]}"

echo "Testing package installation on Arch Linux ($ARCH_IMAGE) ..."
docker run --rm "$ARCH_IMAGE" \
    bash -c '
        set -Eeuo pipefail
        pacman -Syu --needed --noconfirm "$@"
        nvim --headless --clean -n -i NONE "+qall"
    ' bash "${ARCH_PACKAGES[@]}"

echo "All package installation and Neovim execution tests passed."

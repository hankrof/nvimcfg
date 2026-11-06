#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
install_path="$HOME/.config/nvim"
module_path="$HOME/.local/share/nvim/lazy"
cd -- "$repo_root"
export PATH="$HOME/.local/bin:$PATH"

as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

if command -v pacman >/dev/null; then
    arch_packages=(base-devel git cmake ninja python clang lld neovim nodejs npm yarn
        ctags luarocks lua51 curl bear rust unzip python-pynvim)
    if ! pacman -Q -- "${arch_packages[@]}" >/dev/null 2>&1; then
        as_root pacman -Syu --needed --noconfirm "${arch_packages[@]}"
    fi
elif command -v apt-get >/dev/null; then
    as_root apt-get update
    as_root apt-get install -y build-essential git cmake ninja-build python3 \
        clang clangd lld neovim nodejs npm yarnpkg universal-ctags luarocks \
        lua5.1 liblua5.1-0-dev curl bear cargo pkg-config libssl-dev unzip python3-pynvim
else
    echo 'Supported package managers: pacman and apt-get' >&2
    exit 1
fi

if ! command -v codex >/dev/null; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
fi

echo 'Installing Clang/P2996 ...'
bash "$repo_root/scripts/build-clang-p2996.sh"

# Check the same server configuration Neovim will use, without relying on a
# demo project or an existing compilation database.
prefix=${P2996_PREFIX:-"${P2996_WORK_DIR:-$repo_root/.reflection}/install"}
probe=$(mktemp --suffix=.cpp)
trap 'rm -f -- "$probe"' EXIT
printf '%s\n' '#include <meta>' 'struct Point { int x; };' \
    'using Reflected = [: ^^Point :];' \
    'static_assert(std::meta::identifier_of(^^Point) == "Point");' > "$probe"
"$repo_root/scripts/clangd-reflection.sh" "--reflection-prefix=$prefix" "--check=$probe"

# Preserve an existing configuration and keep plugins on repeated installation.
mkdir -p -- "$(dirname -- "$install_path")"
if [[ $(readlink -f -- "$install_path" 2>/dev/null || true) != "$repo_root" ]]; then
    if [[ -e $install_path || -L $install_path ]]; then
        backup="$install_path.backup.$(date +%Y%m%d%H%M%S).$$"
        mv -- "$install_path" "$backup"
        printf 'Previous Neovim configuration saved to %s\n' "$backup"
    fi
    ln -sfn -- "$repo_root" "$install_path"
fi
ln -sfn -- "$module_path" "$repo_root/modules"
nvim --headless -n -i NONE '+Lazy! sync' +qa
coc_extension="${XDG_CONFIG_HOME:-$HOME/.config}/coc/extensions/node_modules/coc-clangd/package.json"
if [[ ! -f $coc_extension ]]; then
    nvim --headless -n -i NONE \
        "+lua require('lazy').load({plugins={'coc.nvim'}})" \
        '+CocInstall -sync coc-clangd' +qa
    if [[ ! -f $coc_extension ]]; then
        echo 'coc-clangd installation failed; rerun install.sh after checking network access.' >&2
        exit 1
    fi
fi
echo 'Done! Restart Neovim to use the installed reflection toolchain.'

#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
prefix=${NVIM_CLANG_REFLECTION_PREFIX:-"$repo_root/.reflection/install"}
if [[ ${1:-} == --reflection-prefix=* ]]; then
    prefix=${1#--reflection-prefix=}
    shift
fi
config_home="$repo_root/.reflection/clangd-config"
user_config="${XDG_CONFIG_HOME:-$HOME/.config}/clangd/config.yaml"

# Give this server C++ reflection defaults without modifying the user's global
# clangd configuration or changing compilation flags for C source files.
node - "$prefix" "$config_home" "$user_config" <<'JS'
const fs = require('node:fs');
const path = require('node:path');
const [prefix, directory, original] = process.argv.slice(2);
const target = path.join(directory, 'clangd/config.yaml');
const inherited = fs.existsSync(original) ? fs.readFileSync(original, 'utf8') : '';
const config = {
    If: { PathMatch: '.*\\.(cc|cp|cpp|cxx|c\\+\\+|C|hh|hpp|hxx|h\\+\\+|H|cppm|ixx)' },
    CompileFlags: {
        Remove: ['-std=*', '-stdlib=*'],
        Add: ['-std=c++26', '-freflection-latest', '-stdlib=libc++',
            '-nostdinc++', '-isystem', path.join(prefix, 'include/c++/v1')],
    },
};
fs.mkdirSync(path.dirname(target), { recursive: true });
const temporary = `${target}.${process.pid}.tmp`;
fs.writeFileSync(temporary, (inherited.trim() ? inherited + '\n---\n' : '') + JSON.stringify(config, null, 2) + '\n');
fs.renameSync(temporary, target);
JS

export XDG_CONFIG_HOME="$config_home"
exec "$prefix/bin/clangd" --enable-config "$@"

#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
work_dir=${P2996_WORK_DIR:-"$repo_root/.reflection"}
prefix=${P2996_PREFIX:-"$work_dir/install"}
ref=${P2996_REF:-p2996}
jobs=${P2996_JOBS:-2}

if [[ ${1:-} == --help ]]; then
    printf '%s\n' \
        'Build experimental Clang/P2996, matching clangd, libc++ and libc++abi.' \
        'Usage: scripts/build-clang-p2996.sh' \
        'P2996_WORK_DIR: source/build directory (default: <nvimcfg>/.reflection)' \
        'P2996_PREFIX: installation directory (default: <work directory>/install)' \
        'P2996_REF: branch or tag for the initial clone (default: p2996)' \
        'P2996_JOBS: parallel compilation jobs (default: 2; one linker job)'
    exit 0
fi
if [[ $# -ne 0 || ! $jobs =~ ^[1-9][0-9]*$ ]]; then
    echo 'Expected no arguments and a positive integer P2996_JOBS; use --help.' >&2
    exit 1
fi
for tool in git cmake ninja python3; do
    command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done

mkdir -p -- "$work_dir" "$prefix"
work_dir=$(cd -- "$work_dir" && pwd -P)
prefix=$(cd -- "$prefix" && pwd -P)
source_dir="$work_dir/source"
compiler_build="$work_dir/compiler-build"
runtime_build="$work_dir/runtime-build"

if [[ ! -e $source_dir ]]; then
    git clone --depth 1 --single-branch --branch "$ref" \
        https://github.com/bloomberg/clang-p2996.git "$source_dir"
elif [[ ! -d $source_dir/.git || ! -f $source_dir/P2996.md ]]; then
    echo "Not a Clang/P2996 checkout: $source_dir" >&2
    exit 1
fi
# Re-running resumes the existing checkout; it never pulls or resets local work.
revision=$(git -C "$source_dir" rev-parse HEAD)
printf 'Building Clang/P2996 revision %s into %s\n' "$revision" "$prefix"
linker_options=()
if command -v ld.lld >/dev/null; then
    linker_options+=(-DLLVM_USE_LINKER=lld)
fi

cmake -S "$source_dir/llvm" -B "$compiler_build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    '-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra' \
    -DLLVM_TOOL_LLVM_DRIVER_BUILD=OFF \
    -DLLVM_TARGETS_TO_BUILD=Native \
    -DLLVM_PARALLEL_LINK_JOBS=1 \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_TOOLS_EXTRA_INCLUDE_TESTS=OFF \
    "${linker_options[@]}"
cmake --build "$compiler_build" --parallel "$jobs" \
    --target install-clang install-clang-resource-headers install-clangd

# Build the fork's standard library with the compiler just installed. Flatten
# runtime directories so projects can consistently use <prefix>/lib.
cmake -S "$source_dir/runtimes" -B "$runtime_build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    -DCMAKE_INSTALL_RPATH="$prefix/lib" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_C_COMPILER="$prefix/bin/clang" \
    -DCMAKE_CXX_COMPILER="$prefix/bin/clang++" \
    '-DLLVM_ENABLE_RUNTIMES=libcxx;libcxxabi' \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLIBCXX_INCLUDE_TESTS=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXXABI_INCLUDE_TESTS=OFF \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF
cmake --build "$runtime_build" --parallel "$jobs"
cmake --install "$runtime_build"

"$prefix/bin/clang++" --version
"$prefix/bin/clangd" --version
printf '\nClang/P2996 toolchain installed in %s\n' "$prefix"

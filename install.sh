#!/bin/bash

#code from junegunn/fzf

version="v1.0.2"

download(){
    if [[ ! -d ~/.sman/ ]]; then
        if command -v git > /dev/null; then
            git clone https://github.com/ickc/sman.git ~/.sman/
        else
            binary_error="git not found"
            return
        fi
    fi
    [[ -d ~/.local/bin ]] || mkdir ~/.local/bin
    cd ~/.local/bin
    local url=https://github.com/ickc/sman/releases/download/$version/${1}.tgz
    echo "$url"
    if command -v curl > /dev/null; then
        curl -fL "$url" | tar -xz
    elif command -v wget > /dev/null; then
        wget -O - "$url" | tar -xz
    else
        binary_error="curl or wget not found"
        return
    fi

    if [ ! -f "$1" ]; then
        binary_error="Failed to download ${url}"
        return
    fi

    mv "$1" sman
    chmod +x sman
}

# Try to download binary executable
archi=$(uname -sm)
binary_available=1
binary_error=""
case "$archi" in
    Darwin\ x86_64)     download "sman-darwin-amd64-$version"   ;;
    Darwin\ arm64)      download "sman-darwin-arm64-$version"   ;;
    Linux\ x86_64)      download "sman-linux-amd64-$version"    ;;
    Linux\ i*86)        download "sman-linux-386-$version"      ;;
    Linux\ arm*)        download "sman-linux-arm-$version"      ;;
    Linux\ aarch64)     download "sman-linux-arm64-$version"    ;;
    Linux\ ppc64)       download "sman-linux-ppc64-$version"    ;;
    Linux\ ppc64le)     download "sman-linux-ppc64le-$version"  ;;
    FreeBSD\ i386)      download "sman-freebsd-386-$version"    ;;
    FreeBSD\ amd64)     download "sman-freebsd-amd64-$version"  ;;
    FreeBSD\ arm)       download "sman-freebsd-arm-$version"    ;;
    FreeBSD\ arm64)     download "sman-freebsd-arm64-$version"  ;;
    NetBSD\ i386)       download "sman-netbsd-386-$version"     ;;
    NetBSD\ amd64)      download "sman-netbsd-amd64-$version"   ;;
    NetBSD\ arm)        download "sman-netbsd-arm-$version"     ;;
    NetBSD\ arm64)      download "sman-netbsd-arm64-$version"   ;;
    OpenBSD\ i386)      download "sman-openbsd-386-$version"    ;;
    OpenBSD\ amd64)     download "sman-openbsd-amd64-$version"  ;;
    OpenBSD\ arm)       download "sman-openbsd-arm-$version"    ;;
    OpenBSD\ arm64)     download "sman-openbsd-arm64-$version"  ;;
    SunOS\ i86pc)       download "sman-solaris-amd64-$version"  ;;
    Linux\ mips)        download "sman-linux-mips-$version"     ;;
    Linux\ mips64)      download "sman-linux-mips64-$version"   ;;
    Linux\ mips64le)    download "sman-linux-mips64le-$version" ;;
    Linux\ mipsle)      download "sman-linux-mipsle-$version"   ;;
    Linux\ riscv64)     download "sman-linux-riscv64-$version"  ;;
    Linux\ s390x)       download "sman-linux-s390x-$version"    ;;
    *)                  binary_available=0 binary_error=1       ;;
esac

if [[ -n "$binary_error" ]]; then
    if [[ $binary_available -eq 0 ]]; then
        echo "No prebuilt binary for $archi ..."
    fi
    echo "  - $binary_error !!!"
    exit 1
fi

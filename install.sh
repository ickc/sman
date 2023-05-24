#!/bin/bash

#code from junegunn/fzf

version="v1.0.1"

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

ask(){
    # If stdin is a tty, we are "interactive".
    # non-interactive shell: wait for a linefeed
    #     interactive shell: continue after a single keypress
    read_n=$([[ -t 0 ]] && echo "-n 1")

    read -p "$1 ([y]/n) " $read_n -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]]
}

append_line(){
    set -e

    local update line file pat lno
    update="$1"
    line="$2"
    file="$3"
    pat="${4:-}"

    echo "Update $file:"
    echo "  - $line"
    [[ -f "$file" ]] || touch "$file"
    if [[ $# -lt 4 ]]; then
        lno=$(\grep -nF "$line" "$file" | sed 's/:.*//' | tr '\n' ' ')
    else
        lno=$(\grep -nF "$pat" "$file" | sed 's/:.*//' | tr '\n' ' ')
    fi
    if [[ -n "$lno" ]]; then
        echo "    - Already exists: line #$lno"
    else
        if [[ $update -eq 1 ]]; then
            echo >> "$file"
            echo "$line" >> "$file"
            echo "    + Added"
        else
            echo "    ~ Skipped"
        fi
    fi
    echo
    set +e
}

# Try to download binary executable
archi=$(uname -sm)
binary_available=1
binary_error=""
case "$archi" in
   Darwin\ x86_64) download "sman-darwin-amd64-$version"  ;;
   Darwin\ arm64)  download "sman-darwin-amd64-$version"  ;;  # TODO
   Linux\ x86_64)  download "sman-linux-amd64-$version"   ;;
   Linux\ i*86)    download "sman-linux-386-$version"     ;;
   Linux\ arm*)    download "sman-linux-arm-$version"     ;;
   Linux\ aarch64) download "sman-linux-arm64-$version"   ;;
   Linux\ ppc64)   download "sman-linux-ppc64-$version"   ;;
   Linux\ ppc64le) download "sman-linux-ppc64le-$version" ;;
   FreeBSD\ i386)  download "sman-freebsd-386-$version"   ;;
   FreeBSD\ amd64) download "sman-freebsd-amd64-$version" ;;
  *)               binary_available=0 binary_error=1      ;;
esac

if [[ -n "$binary_error" ]]; then
    if [[ $binary_available -eq 0 ]]; then
        echo "No prebuilt binary for $archi ..."
    fi
    echo "  - $binary_error !!!"
    exit 1
fi

# Append sman.rc to rc
echo
ask "Do you want to update your shell configuration files?"
update_config=$?
has_zsh=$(command -v zsh > /dev/null && echo 1 || echo 0)
shells=$([[ $has_zsh -eq 1 ]] && echo "bash zsh" || echo "bash")
for shell in $shells; do
    [[ $shell = zsh ]] && dest=${ZDOTDIR:-~}/.zshrc || dest=~/.bashrc
    append_line $update_config "[[ -f ~/.sman/sman.rc ]] && source ~/.sman/sman.rc" "$dest" "$HOME/.sman/sman.rc"
    append_line $update_config 'export SMAN_SNIPPET_DIR=~/.sman/snippets' "$dest" "$HOME/.sman/snippets"
done

echo "Done. Logout or reload your rc"

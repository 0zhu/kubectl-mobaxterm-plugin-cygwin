#!/bin/sh
# based on https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows

# amd64 for 64-bit / 386 for 32-bit
KBIT=386
KEXE=/bin/kubectl
KPLUGIN=kubectl.mxt3
KBAK="$KEXE".bakmxtbuild

set -e

hash curl zip

if [ -f "$KEXE" ]; then
    KEXIST=1
    mv "$KEXE" "$KBAK"
    echo "$KEXE" exists, renamed to "$KBAK" during plugin build
fi

KLATEST=$( curl -skL https://storage.googleapis.com/kubernetes-release/release/stable.txt )
echo Latest kubectl release: "$KLATEST"
curl -kLo "$KEXE" https://storage.googleapis.com/kubernetes-release/release/"$KLATEST"/bin/windows/"$KBIT"/kubectl.exe

# https://kubernetes.io/docs/tasks/tools/install-kubectl/#enable-kubectl-autocompletion
KCOMP=/usr/share/bash-completion/completions
mkdir -p "$KCOMP"
"$KEXE" completion bash > "$KCOMP"/kubectl

zip "$KPLUGIN" "$KEXE" "$KCOMP"/kubectl
echo Plugin file: $( realpath "$KPLUGIN" )

if [ "$KEXIST" ]; then
    mv -f "$KBAK" "$KEXE"
    echo "$KBAK" renamed back to "$KEXE"
else
    echo Deleting "$KEXE" used for plugin build...
    rm -f "$KEXE" 
fi

echo Done.
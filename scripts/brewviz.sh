#!/bin/bash

set -e -u -o pipefail

{
  echo 'digraph G {'

  brew list | while read -r cask; do
    printf '"%s";\n' "$cask"
    brew deps "$cask" | while read -r dep; do
      printf '"%s" -> "%s";\n' "$cask" "$dep"
    done
  done

  echo '}'
} > brew_deps.dot

dot -T png -o brew_deps.png brew_deps.dot

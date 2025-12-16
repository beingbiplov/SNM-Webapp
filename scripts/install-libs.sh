#!/usr/bin/env bash
set -e

echo "Installing Shark / ASAP libraries into local Maven repo..."

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIB_DIR="$BASE_DIR/libs"

install_jar() {
  local jar=$1
  local groupId=$2
  local artifactId=$3
  local version=$4

  echo "→ Installing $artifactId:$version"

  mvn install:install-file \
    -Dfile="$LIB_DIR/$jar" \
    -DgroupId="$groupId" \
    -DartifactId="$artifactId" \
    -Dversion="$version" \
    -Dpackaging=jar
}

install_jar ASAPHub.jar            net.sharksystem asaphub          0.1
install_jar ASAPJava.jar           net.sharksystem asapjava         0.1
install_jar SharkPKI.jar           net.sharksystem sharkpki         0.1
install_jar SharkPeer.jar          net.sharksystem sharkpeer        0.1

echo "✔ Shark libraries installed successfully"

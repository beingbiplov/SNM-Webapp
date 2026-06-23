#!/usr/bin/env bash
set -e

if [ -n "$CATALINA_HOME" ]; then
  TOMCAT_HOME="$CATALINA_HOME"
elif [ -d "/opt/homebrew/opt/tomcat/libexec" ]; then
  TOMCAT_HOME="/opt/homebrew/opt/tomcat/libexec"
elif [ -d "/opt/homebrew/opt/tomcat@9/libexec" ]; then
  TOMCAT_HOME="/opt/homebrew/opt/tomcat@9/libexec"
elif [ -d "/opt/tomcat" ]; then
  TOMCAT_HOME="/opt/tomcat"
elif command -v catalina.sh &>/dev/null; then
  TOMCAT_HOME="$(dirname $(dirname $(which catalina.sh)))"
else
  echo "✖ Tomcat not found. Set CATALINA_HOME environment variable."
  exit 1
fi

echo "Stopping SharkNet Web App (Tomcat)..."

if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
  "$TOMCAT_HOME/bin/shutdown.sh"
  echo "✔ Tomcat shutdown signal sent"
else
  echo "✖ Tomcat shutdown script not found"
fi

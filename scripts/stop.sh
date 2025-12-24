#!/usr/bin/env bash
set -e

TOMCAT_HOME="/opt/tomcat"

echo "Stopping SharkNet Web App (Tomcat)..."

if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
  "$TOMCAT_HOME/bin/shutdown.sh"
  echo "✔ Tomcat shutdown signal sent"
else
  echo "✖ Tomcat shutdown script not found"
fi

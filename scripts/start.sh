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

WAR="snm-webapp.war"

echo "Starting SharkNet Web App..."

./scripts/build.sh

if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
  echo "Stopping Tomcat..."
  "$TOMCAT_HOME/bin/shutdown.sh" || true
  sleep 2
fi

echo "Deploying WAR..."
cp target/$WAR "$TOMCAT_HOME/webapps/"

echo "Starting Tomcat..."
"$TOMCAT_HOME/bin/startup.sh"

echo "✔ SharkNet Web App is starting"
echo "→ http://localhost:8080/snm-webapp/"

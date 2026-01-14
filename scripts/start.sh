#!/usr/bin/env bash
set -e

TOMCAT_HOME="/opt/homebrew/opt/tomcat/libexec"
WAR="snm-webapp.war"

echo "Starting SharkNet Web App..."

# Build app
./scripts/build.sh

# Stop Tomcat if running
if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
  echo "Stopping Tomcat..."
  "$TOMCAT_HOME/bin/shutdown.sh" || true
  sleep 2
fi

# Deploy WAR
echo "Deploying WAR..."
cp target/$WAR "$TOMCAT_HOME/webapps/"

# Start Tomcat
echo "Starting Tomcat..."
"$TOMCAT_HOME/bin/startup.sh"

echo "✔ SharkNet Web App is starting"
echo "→ http://localhost:8080/snm-webapp/"

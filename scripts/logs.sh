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

echo "📜 Tailing Tomcat logs..."
echo "Press Ctrl+C to stop"

LOG=$(ls -t "$TOMCAT_HOME/logs"/catalina.*.log 2>/dev/null | head -1)
if [ -z "$LOG" ]; then
  LOG="$TOMCAT_HOME/logs/catalina.out"
fi

tail -f "$LOG"

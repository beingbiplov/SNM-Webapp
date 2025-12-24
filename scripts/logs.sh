#!/usr/bin/env bash
set -e

TOMCAT_HOME="/opt/tomcat"

echo "📜 Tailing Tomcat logs..."
echo "Press Ctrl+C to stop"

tail -f \
  "$TOMCAT_HOME/logs/catalina.out"

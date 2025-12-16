#!/usr/bin/env bash
set -e

echo "Building SharkNet Web App..."

mvn clean package

echo "✔ Build completed"

#!/bin/bash
set -e

if [ -z "$CHART_FOLDER" ]; then
  echo "CHART_FOLDER is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_URL" ]; then
  echo "CHARTMUSEUM_URL is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_USER" ]; then
  echo "CHARTMUSEUM_USER is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_PASSWORD" ]; then
  echo "CHARTMUSEUM_PASSWORD is not set. Quitting."
  exit 1
fi

if [ -z "$SOURCE_DIR" ]; then
  SOURCE_DIR="."
fi

if [ -z "$FORCE" ]; then
  FORCE=""
elif [ "$FORCE" == "1" ] || [ "$FORCE" == "True" ] || [ "$FORCE" == "TRUE" ]; then
  FORCE="-f"
fi



cd ${SOURCE_DIR}/${CHART_FOLDER}

helm version -c

helm inspect chart .

helm repo add marketcircle ${CHARTMUSEUM_URL} --username ${CHARTMUSEUM_USER} --password ${CHARTMUSEUM_PASSWORD}

helm dependency update .

helm package .

CHART_NAME=$(helm inspect chart . | tail -4 | head -n 1 | awk '{print $2}')
CHART_VERSION=$(helm inspect chart . | tail -2 | tr -d "\n" | awk '{print $2}')

helm push ${CHART_NAME}-${CHART_VERSION}.tgz ${CHARTMUSEUM_URL} -u ${CHARTMUSEUM_USER} -p ${CHARTMUSEUM_PASSWORD} ${FORCE}

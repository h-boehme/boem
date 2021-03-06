#!/bin/bash
### Necessary ENV variables ###
# BINTRAY_USER=
# BINTRAY_API_KEY=
# BINTRAY_OWNER=
# BINTRAY_REPO=
### Usage
# Sample Usage: pushToBintray.sh package version pathToP2Repo

API=https://api.bintray.com
PCK_NAME=$1
PCK_VERSION=$2
PATH_TO_REPOSITORY=$3

function main() {
deploy_updatesite
}

function deploy_updatesite() {
echo "==Infos"
echo "BINTRAY_USER=${BINTRAY_USER}"
echo "BINTRAY_API_KEY=${BINTRAY_API_KEY}"
echo "BINTRAY_OWNER=${BINTRAY_OWNER}"
echo "BINTRAY_REPO=${BINTRAY_REPO}"
echo "PCK_NAME=${PCK_NAME}"
echo "PCK_VERSION=${PCK_VERSION}"
echo "PATH_TO_REPOSITORY=${PATH_TO_REPOSITORY}"
echo "==End Infos"

if [ ! -z "$PATH_TO_REPOSITORY" ]; then
   cd $PATH_TO_REPOSITORY
   if [ $? -ne 0 ]; then
     #directory does not exist
     echo $PATH_TO_REPOSITORY " does not exist"
     exit 1
   fi
fi

FILES=./*
BINARYDIR=./binary/*
PLUGINDIR=./plugins/*
FEATUREDIR=./features/*

for f in $FILES;
do
if [ ! -d $f ]; then
  echo "Processing $f file..."
  if [[ "$f" == *content.jar ]] || [[ "$f" == *artifacts.jar ]] || [[ "$f" == *artifacts.xml.xz ]] || [[ "$f" == *content.xml.xz ]] || [[ "$f" == *p2.index ]]
  then
    echo "Uploading p2 metadata file directly to the repository"
    curl -X PUT -T $f -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/$f;publish=0
  else 
    curl -X PUT -T $f -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$f;publish=0
  fi
  echo ""
fi
done

echo "Processing features dir $FEATUREDIR file..."
for f in $FEATUREDIR;
do
  echo "Processing feature: $f file..."
  curl -X PUT -T $f -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$f;publish=0
  echo ""
done

echo "Processing plugin dir $PLUGINDIR file..."

for f in $PLUGINDIR;
do
   # take action on each file. $f store current file name
  echo "Processing plugin: $f file..."
  curl -X PUT -T $f -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$f;publish=0
  echo ""
done

echo "Processing binary dir $BINARYDIR file..."
if [ -d "$(dirname $BINARYDIR)" ]; then
for f in $BINARYDIR;
do
   # take action on each file. $f store current file name
  echo "Processing binary: $f file..."
  curl -X PUT -T $f -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/$f;publish=0
  echo ""
done
fi

echo "Publishing the new version"
curl -X POST -u ${BINTRAY_USER}:${BINTRAY_API_KEY} https://api.bintray.com/content/${BINTRAY_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${PCK_VERSION}/publish -d "{ \"discard\": \"false\" }"
}

main "$@"
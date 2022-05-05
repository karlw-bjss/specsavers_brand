#!/bin/sh

# Branch both
for REPO in brand frontend; do (
  cd $REPO
  git checkout develop
  git pull
  git checkout -b $RELEASE_BRANCH
  git push --set-upstream origin $RELEASE_BRANCH
); done

# Tag and release beta
TAG_NAME=$BETA_TAG SOURCE_REF=$RELEASE_BRANCH /bin/bash $(dirname "$0")/tag_release.sh

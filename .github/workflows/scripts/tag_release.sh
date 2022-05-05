#!/bin/bash

if [[ -z "$SOURCE_REF" ]]; then
  echo "::error::Source ref invalid"
  exit 1
fi

if [[ -z "$TAG_NAME" ]]; then
  echo "::error::Tag invalid"
  exit 2
fi

# Check pre-release
GH_RELEASE_OPS="--title \"$TAG_NAME\""
if echo "$TAG_NAME" | grep '.*-.*' &>/dev/null; then
  GH_RELEASE_OPTS="$GH_RELEASE_OPTS --prerelease"
fi

# Tag and release
for REPO in brand frontend; do
  if cd $REPO \
    && git pull \
    && git checkout "$SOURCE_REF" \
    && git tag -a -m "Tagging $TAG_NAME from $SOURCE_REF" $TAG_NAME \
    && git push --tags \
    && gh release create $GH_RELEASE_OPTS $TAG_NAME \
    && cd ..
  then
    echo "::notice::Tagged $TAG_NAME from $SOURCE_REF on $REPO"
  else
    echo "::error::Tagging $REPO failed"
    exit 3
  fi
done

# TODO: composer installs and any other common build stuff

# Create asset
tar czf ${TAG_NAME}.tar.gz ./brand ./frontend

# Upload asset
cd brand
gh release upload $TAG_NAME "../${TAG_NAME}.tar.gz#Combined assets for release ${TAG_NAME}"

#!/bin/bash

NAME="Automation"
EMAIL="noreply@specsavers.com"

if [[ ! -z "$ACTOR" ]]; then
  NAME="$NAME by $ACTOR"
fi

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

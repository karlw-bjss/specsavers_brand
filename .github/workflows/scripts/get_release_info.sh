#!/bin/bash

is_numeric () {
  [[ "$1" -eq "$1" ]] && [[ ! -z "$1" ]]
}

not_numeric () {
  ! is_numeric "$1"
}

error () {
  echo "::error::$*"
  exit 255
}

output () {
  echo "::set-output name=$1::$2"
}

if not_numeric "$RELEASE_YEAR" || [[ "$RELEASE_YEAR" -lt 22 ]]; then
  error "RELEASE_YEAR not valid"
fi

if not_numeric "$RELEASE_MONTH" || [[ "$RELEASE_MONTH" -lt 1 ]] || [[ "$RELEASE_MONTH" -gt 12 ]]; then
  error "RELEASE_MONTH not valid"
fi

if not_numeric "$RELEASE_YEAR" || [[ "$RELEASE_YEAR" -lt 22 ]]; then
  error "RELEASE_MINOR not valid"
fi

RELEASE_MAIN="$( printf '%02d.%02d' $RELEASE_YEAR $RELEASE_MONTH )"
RELEASE_FULL="${RELEASE_MAIN}.${RELEASE_MINOR}"
RELEASE_BRANCH="release-${RELEASE_MAIN}"

# Check for release branch
for REPO in brand frontend; do
  cd $REPO
  
  if [[ -z "$( git ls-remote --heads origin $RELEASE_BRANCH )" ]]; then
    eval "RB_EXISTS_${REPO}=F"
  else
    eval "RB_EXISTS_${REPO}=T"
  fi
  
  cd ..
done

if [[ $RB_EXISTS_brand != $RB_EXISTS_frontend ]]; then
  error "Release branch exists in one repo but not the other"
fi

RELEASE_BRANCH_EXISTS=$RB_EXISTS_brand

# Check releases
cd brand
NEXT_beta=1
NEXT_rc=1
CURRENT_beta=NONE
CURRENT_rc=NONE

FULL_RELEASE_EXISTS=F

# If no release branch, don't bother checking
if [[ "$RELEASE_BRANCH_EXISTS" == "T" ]]; then
  # Find current and next
  for TYPE in beta rc; do
    NEXT_T=NEXT_$TYPE
    while gh release view ${RELEASE_FULL}-${TYPE}${!NEXT_T} &>/dev/null; do
      eval "${NEXT_T}=$(( ${!NEXT_T} + 1 ))"
    done
    
    if [[ ${!NEXT_T} -gt 1 ]]; then
      CURRENT_T=CURRENT_$TYPE
      eval "$CURRENT_T=$(( ${!NEXT_T} - 1 ))"
    fi
  done
  
  if gh release view ${RELEASE_FULL} &>/dev/null; then
    FULL_RELEASE_EXISTS=T
  fi
fi

# Output details
output release_main $RELEASE_MAIN
output release_full $RELEASE_FULL
output release_branch $RELEASE_BRANCH
output release_branch_exists $RELEASE_BRANCH_EXISTS
output full_release_exists $FULL_RELEASE_EXISTS

for TYPE in beta rc; do
  NEXT_T=NEXT_$TYPE
  CURRENT_T=CURRENT_$TYPE
  output next_$TYPE ${RELEASE_FULL}-${TYPE}${!NEXT_T}
  
  if [[ "${!CURRENT_T}" == "NONE" ]]; then
    output current_$TYPE NONE
  else
    output current_$TYPE ${RELEASE_FULL}-${TYPE}${!CURRENT_T}
  fi
done

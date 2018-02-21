#!/bin/bash

ERROR_CODE_NO_CI=1
ERROR_CODE_NO_BASE_TAG=2

SEMVER_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"

if [[ -z "${GITLAB_CI}" ]] && [[ -z "${CI}" ]]; then
    echo "${0} is meant to run inside gitlab-ci"
    exit "${ERROR_CODE_NO_CI}"
fi

parse_version () {
  local version=$1
  if [[ "$version" =~ $SEMVER_REGEX ]]; then
    # if a second argument is passed, store the result in var named by $2
    if [ "$#" -eq "2" ]; then
      local major=${BASH_REMATCH[1]}
      local minor=${BASH_REMATCH[2]}
      local patch=${BASH_REMATCH[3]}
      local prere=${BASH_REMATCH[4]}
      local build=${BASH_REMATCH[5]}
      eval "$2=(\"$major\" \"$minor\" \"$patch\" \"$prere\" \"$build\")"
    else
      echo "$version"
    fi
  else
    error "version $version does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information."
  fi
}

# NOTE(kornicameister) need to figure out how to retrieve
# stable/X if we do release installer for stable/X branch
BASE_BRANCH="${1:-''}"

# BASE_TAG - should differ between stable/branches
BASE_TAG="${2:-''}"

echo "Running with tag=${BASE_TAG} for branch=${BASE_BRANCH}"

# scripts/verify_sync ensures that all the modules are in sync
# with monasca-installer therefore we can safely tag the installer here

# Workflow operation
# 1) check the case of not_having_base_tag_at_all - stable/branch must be tagged
#    manually to select the start-point of tagging operation
# 2) if base tag is found, we need to actually locate the latest tag starting
#    with the major of the BASE_TAG sth like `git tag | grep base_tag.major`
#    and select the latest one (highest one)
# 3) select next tag number by incrementing the patch [0-Inf] range
#    We cannot update major as new major is only for the new stable branches

if [[ "$BASE_TAG" != "$(git tag -l $BASE_TAG)" ]]; then
  echo "Did not found the base tag ${BASE_TAG} for ${BASE_BRANCH}"
  exit "${ERROR_CODE_NO_BASE_TAG}"
fi

parse_version "${BASE_TAG}" parts
major="${parts[0]}"
minor="${parts[1]}"

latest_tag=$(git tag -l "${major}.${minor}.*" | tail -n 1)
parse_version "${latest_tag}" parts
major="${parts[0]}"
minor="${parts[1]}"
patch="${parts[2]}"

next_tag="${major}.${minor}.$((patch + 1))"

echo "Tagging branch=${BASE_BRANCH}/${BASE_TAG} with next tag=${next_tag}"

git tag "${next_tag}" "${BASE_TAG}"
git push --tags

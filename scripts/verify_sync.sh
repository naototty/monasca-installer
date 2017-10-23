#!/bin/bash

SUCCESS_CODE=0
ERROR_CODE_NO_CI=1
ERROR_CODE_OUT_OF_SYNC=2

if [[ -z "${GITLAB_CI}" ]] && [[ -z "${CI}" ]]; then
    echo "${0} is meant to run inside gitlab-ci"
    exit "${ERROR_CODE_NO_CI}"
fi

# NOTE(kornicameister) need to figure out how to retrieve
# stable/X if we do release installer for stable/X branch
SUBMODULE_BRANCH="${1:-master}"

echo "Validating sync at ${SUBMODULE_BRANCH}"

# download all submodules
# and fetch recent changes

git submodule foreach git fetch --all --quiet && \
    echo "Fetched recent submodules changes"
git submodule foreach git checkout "${SUBMODULE_BRANCH}" && \
    echo "Checkout submodules ${SUBMODULE_BRANCH} branches"

# verify that master is in sync with recent changes
OUT_OF_SYNC_MODULES=$(git submodule status | grep + | awk '{print $2}' | tr '\n' ',' | sed 's/.$//g')
if [[ -n "${OUT_OF_SYNC_MODULES}" ]]; then
    echo "${OUT_OF_SYNC_MODULES} is out of sync at ${SUBMODULE_BRANCH}"
    exit "${ERROR_CODE_OUT_OF_SYNC}"
else
    echo "All modules are in sync at ${SUBMODULE_BRANCH}"
    exit "${SUCCESS_CODE}"
fi

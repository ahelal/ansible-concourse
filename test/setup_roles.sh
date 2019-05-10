#!/bin/bash
set -e
MY_PATH="$(dirname "${0}")"
DIR="$(cd "${MY_PATH}" && pwd)" # absolutized and normalized
ROLES_DIR=$(cd "${DIR}/helper_roles" && pwd)

ansible-galaxy install -r "${ROLES_DIR}/roles_requirements.yml" --force -p "${ROLES_DIR}"

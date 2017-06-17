#!/bin/sh
set -e

MY_PATH="$(dirname "$0")"          # relative
DIR="$( cd "$MY_PATH" && pwd )"  # absolutized and normalized
export PYTHONPATH="$( cd "${DIR}/../../library" && pwd )"
echo ${PYTHONPATH}
NOSE_PATH=${NOSE_PATH-""}
$(NOSE_PATH)nosetests  -v

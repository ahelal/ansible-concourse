#!/bin/bash
set -e

AVM_VERSION="v1.0.0"

export ANSIBLE_VERSIONS_1="2.6.17"
export INSTALL_TYPE_1="pip"
export ANSIBLE_LABEL_1="vOne"

export ANSIBLE_VERSIONS_2="2.7.11"
export INSTALL_TYPE_2="pip"
export ANSIBLE_LABEL_2="vTwo"

export ANSIBLE_VERSIONS_3="2.8.1"
export INSTALL_TYPE_3="pip"
export ANSIBLE_LABEL_3="vThree"

# Whats the default version
export ANSIBLE_DEFAULT_VERSION="vOne"

echo "* Setting up ansible "
echo "* ANSIBLE_LABEL_1=${ANSIBLE_LABEL_1} ANSIBLE_VERSIONS_1=${ANSIBLE_VERSIONS_1}"
echo "* ANSIBLE_LABEL_2=${ANSIBLE_LABEL_2} ANSIBLE_VERSIONS_2=${ANSIBLE_VERSIONS_2}"
echo "* ANSIBLE_LABEL_3=${ANSIBLE_LABEL_3} ANSIBLE_VERSIONS_3=${ANSIBLE_VERSIONS_3}"

## Create a temp dir to download avm
avm_dir="$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')"
git clone https://github.com/ahelal/avm.git "${avm_dir}" >/dev/null 2>&1
cd "${avm_dir}"
git checkout ${AVM_VERSION}
/bin/sh "${avm_dir}"/setup.sh

exit 0

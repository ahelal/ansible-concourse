#!/bin/bash
set -e

AVM_VERSION="v1.0.0-rc.8"
export ANSIBLE_VERSIONS_0="2.0.2.0"
export INSTALL_TYPE_0="pip"
export ANSIBLE_LABEL_0="v2.0"

export ANSIBLE_VERSIONS_1="2.2.1.0"
export INSTALL_TYPE_1="pip"
export ANSIBLE_LABEL_1="v2.2"

export ANSIBLE_VERSIONS_2="2.3.1.0"
export INSTALL_TYPE_2="pip"
export ANSIBLE_LABEL_2="v2.3"

# Whats the default version
export ANSIBLE_DEFAULT_VERSION="v2.0"

## Create a temp dir to download avm
avm_dir="$(mktemp -d 2> /dev/null || mktemp -d -t 'mytmpdir')"
git clone https://github.com/ahelal/avm.git "${avm_dir}" > /dev/null 2>&1
git checkout ${AVM_VERSION}
/bin/sh "${avm_dir}"/setup.sh

exit 0

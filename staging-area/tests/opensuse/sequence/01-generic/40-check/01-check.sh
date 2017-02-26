#!/bin/bash

#Bash disables history in noninteractive shells by default, but we turn it on here.
HISTFILE=~/.bash_history
set -o history

#current script native directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR=$( dirname "${SELF_DIR}" )
SEQUENCE_DIR=$( dirname "${PARENT_DIR}" )

if [ ! -f ${SEQUENCE_DIR}/SKIP_MAKECHECK ]; then
    cd /opt/QA/sources/suricata/ && \
    make distcheck -j2
fi

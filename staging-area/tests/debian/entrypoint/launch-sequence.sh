#!/bin/bash

#docker - make sure we always start clean
rm -rf /opt/QA/results/logs

mkdir -p /opt/QA/results/logs
cd /opt/QA/sources/suricata/ 

#current script native directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR=$( dirname "${SELF_DIR}" )

echo "Executed scripts:" > /opt/QA/results/logs/scripts
SCRIPTS=$(find ${PARENT_DIR}/sequence/ -type f -name \*.sh | sort)
for script in ${SCRIPTS}; do
    
    echo ${script} >> /opt/QA/results/logs/scripts
    full_path_script=$(echo ${script} | tr '/' '_')
    ${script} >> /opt/QA/results/logs/${full_path_script}-log_file 2>&1
    RESULT=$?
    if [ ${RESULT} -ne 0 ]; then
      echo "ERROR on runing ${script}" | tee -a /opt/QA/results/logs/ERROR
      echo ${script}  >> /opt/QA/results/logs/ERROR
      exit 1
    fi
    
done

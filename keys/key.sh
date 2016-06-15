#!/bin/sh
set -e

# Workers to generate
read -p "How many workers do you want to generate keys for ? : " workers

MY_PATH="`dirname \"$0\"`"          # relative
DIR="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
OUTPUT_DIR="${DIR}/vars"
mkdir -p ${OUTPUT_DIR}
temp_dir=$(mktemp -d)
worker_yaml_output="${OUTPUT_DIR}/workers_ssh.yml"
web_yaml_output="${OUTPUT_DIR}/web_ssh.yml"

# Script to indent
python_ident='''import sys
for line in sys.stdin:
    sys.stdout.write("\t\t\t\t\t\t\t\t\t%s" % line)
print ""
'''

cd ${temp_dir}
# Remove previous file
rm -rf ${worker_yaml_output}
rm -rf ${web_yaml_output}
echo "concourseci_worker_keys\t\t\t:" > ${worker_yaml_output}
for i in $(seq 1 $workers); do 
    ssh-keygen -b 4096 -f id_${i}_rsa -N ""
    public="$(cat id_${i}_rsa.pub)"
    private="$(cat id_${i}_rsa)"
    echo "\t\t\t\t\t\t- public : ${public}" >> ${worker_yaml_output}
    echo "\t\t\t\t\t\t  private: |" >> ${worker_yaml_output}
    echo "${private}" | python -c "${python_ident}" >> ${worker_yaml_output}
done

ssh-keygen -b 4096 -f id_session_rsa -N ""
public="$(cat id_session_rsa.pub)"
private="$(cat id_session_rsa)"
echo "concourseci_key_session_public  : ${public}" >> ${web_yaml_output}
echo "concourseci_key_session_private : |" >> ${web_yaml_output}
echo "${private}" | python -c "${python_ident}" >> ${web_yaml_output}

ssh-keygen -b 4096 -f id_web_rsa -N ""
public="$(cat id_web_rsa.pub)"
private="$(cat id_web_rsa)"
echo "concourseci_key_tsa_public      : ${public}" >> ${web_yaml_output}
echo "cconcourseci_key_tsa_private    : |" >> ${web_yaml_output}
echo "${private}" | python -c "${python_ident}" >> ${web_yaml_output}

rm -rf ${temp_dir}
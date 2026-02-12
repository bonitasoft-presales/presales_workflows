#!/usr/bin/env sh

set -ev

PROJECT_FOLDER="${PWD}/../.."
WORK_FOLDER="${PWD}/target"
#AWS_PUBLIC_DNS_HOSTNAME="ec2-34-244-46-115.eu-west-1.compute.amazonaws.com"
#UIB_FOLDER=${PWD}/temp_uib

#echo "AWS_PUBLIC_DNS_HOSTNAME: [${AWS_PUBLIC_DNS_HOSTNAME}]"
#echo "UIB_FOLDER: [${UIB_FOLDER}]"
echo "PROJECT_FOLDER: [${PROJECT_FOLDER}]"

bonitaAwsVersion="1.8"
keyName="presale-ci-eu-west-1"

rm -rf ${WORK_FOLDER}
mkdir -p ${WORK_FOLDER}


# get aws presales lib
mvn --batch-mode \
--no-transfer-progress \
dependency:copy \
-Dartifact=com.bonitasoft.presales.aws:bonita-aws:${bonitaAwsVersion}:jar:jar-with-dependencies \
-DoutputDirectory=${WORK_FOLDER}

cd ${WORK_FOLDER}

#java -jar bonita-aws-${bonitaAwsVersion}-jar-with-dependencies.jar \
#-c list \
#--key-name ${keyName} \
#--security-group ${securityGroup} \

java -jar bonita-aws-${bonitaAwsVersion}-jar-with-dependencies.jar \
-c status \
--key-name ${keyName} \
--stack-id demo_stelogy_master
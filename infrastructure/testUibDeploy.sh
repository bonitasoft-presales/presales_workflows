#!/usr/bin/env sh

set -ev

PROJECT_FOLDER="${PWD}/.."
AWS_PUBLIC_DNS_HOSTNAME="ec2-34-244-46-115.eu-west-1.compute.amazonaws.com"
UIB_FOLDER=${PWD}/temp_uib

echo "AWS_PUBLIC_DNS_HOSTNAME: [${AWS_PUBLIC_DNS_HOSTNAME}]"
echo "UIB_FOLDER: [${UIB_FOLDER}]"
echo "PROJECT_FOLDER: [${PROJECT_FOLDER}]"

# deploy  UIB applications
# prepare zip
rm -rf ${UIB_FOLDER}
mkdir -p ${UIB_FOLDER}
ls -ltr "${PROJECT_FOLDER}/uib"
find "${PROJECT_FOLDER}/uib" -type f -name "*.json" -exec zip "${UIB_FOLDER}/uib_applications.zip" -j {} +
unzip -l "${UIB_FOLDER}/uib_applications.zip"

BONITA_URL="http://${AWS_PUBLIC_DNS_HOSTNAME}/bonita/loginservice"
UIB_URL="http://${AWS_PUBLIC_DNS_HOSTNAME}/uib/api/v1"

# Generate cookie file
#login to set cookies

curl -v -c "${UIB_FOLDER}/saved_cookies.txt" \
--url ${BONITA_URL} \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'username=install' \
--data-urlencode 'password=install' \
--data-urlencode 'redirect=false' \
--data-urlencode 'redirectURL='

echo "connected"
ls -ltr ${UIB_FOLDER}

#cleanup apps
echo "clean all applications"
curl -b "${UIB_FOLDER}/saved_cookies.txt" -X DELETE "${UIB_URL}/applications/all" \
--header 'x-requested-by: Appsmith' \


ZIP_FILE="${UIB_FOLDER}/uib_applications.zip"
echo "deploy zip applications: ${ZIP_FILE}"

# deploy all
#curl -b "${UIB_FOLDER}/saved_cookies.txt" -X POST "${UIB_URL}/applications/import-bulk" \
#--header 'x-requested-by: Appsmith' \
#--form 'file=@${ZIP_FILE}'

# deploy all
curl -b "${UIB_FOLDER}/saved_cookies.txt" -X POST "${UIB_URL}/applications/import-bulk" \
--header 'x-requested-by: Appsmith' \
--form "file=@${ZIP_FILE}"


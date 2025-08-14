#!/usr/bin/env sh



AWS_PUBLIC_DNS_HOSTNAME="ec2-3-255-139-245.eu-west-1.compute.amazonaws.com"

echo "AWS_PUBLIC_DNS_HOSTNAME: [${AWS_PUBLIC_DNS_HOSTNAME}]"

ssh -o StrictHostKeyChecking=no -i ~/.ssh/presale-ci-eu-west-1.pem ubuntu@${AWS_PUBLIC_DNS_HOSTNAME} <<EOF
sudo docker ps
sudo docker logs bonita-ui
EOF

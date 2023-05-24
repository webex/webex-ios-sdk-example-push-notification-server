#!/bin/sh

set -e

cd ./HandleWebhook
npm install #installs dependencies

cd ../DeviceRegistration
npm install

cd ../terraform
terraform apply
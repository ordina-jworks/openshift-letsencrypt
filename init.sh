#!/bin/bash
set -e

# clean up
oc delete all -l "app=letsencrypt"

if [ -z "$LETSENCRYPT_CONTACT_EMAIL" ]; then
    echo "Need to set LETSENCRYPT_CONTACT_EMAIL"
    exit 1
fi 

# STAGING
# LETSENCRYPT_CA="https://acme-staging.api.letsencrypt.org/directory"
# LIVE
LETSENCRYPT_CA="https://acme-v01.api.letsencrypt.org/directory"

PROJECT=`oc project -q`
echo $PROJECT

oc process -f template.yaml \
	-p LETSENCRYPT_CONTACT_EMAIL=${LETSENCRYPT_CONTACT_EMAIL} \
	-p LETSENCRYPT_CA=${LETSENCRYPT_CA} \
	-p PROJECT=${PROJECT} \
	| oc create -f -

oc adm policy add-role-to-user edit -z letsencrypt

# Create clusterrole letsencrypt (if not existing)
oc get clusterrole letsencrypt > /dev/null 2>&1
    if ! [ "$?" -eq 0 ]; then
		oc create -f letsencrypt-clusterrole.yaml
		oc adm policy add-cluster-role-to-user letsencrypt system:serviceaccount:`oc project -q`:letsencrypt
	fi

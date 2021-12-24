#!/bin/bash

BACKUP_NAME=cacerts-GA-backup.original
SYS_TRUSTED_CA="${JRE_SECURITY_FOLDER}/${TRUSTED_CA}"

cp -v $SYS_TRUSTED_CA 			"${JRE_SECURITY_FOLDER}/${BACKUP_NAME}"
cp -v $SYS_TRUSTED_CA			"../${JRE_VERSION}/GA/lib/security/cacerts.GA"
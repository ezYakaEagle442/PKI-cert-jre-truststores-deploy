#!/bin/bash

cp $SYS_TRUSTED_CA 			$JRE_SECURITY_FOLDER
cp $SYS_TRUSTED_SITE_CA 	$JRE_SECURITY_FOLDER

cp $SYS_TRUSTED_CERT 		$JRE_SECURITY_FOLDER
cp $SYS_TRUSTED_SITE_CERT 	$JRE_SECURITY_FOLDER
#cp $SYS_CLIENT_AUTH_CERT	$JRE_SECURITY_FOLDER

# cp $SYS_TRUSTED_SITE_CERT $SYSTEM_SECURITY_FOLDER
# cp $SYS_TRUSTED_CERT 		$SYSTEM_SECURITY_FOLDER
# cp $SYS_CLIENT_AUTH_CERT%	$SYSTEM_SECURITY_FOLDER

# cp $SYS_TRUSTED_SITE_CERT $USR_TRUSTED_SITE_CERTIFICATES
# cp $SYS_TRUSTED_CERT 		$USR_TRUSTED_CERTIFICATES
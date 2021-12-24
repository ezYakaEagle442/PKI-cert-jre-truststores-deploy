#!/bin/bash

echo listing entries for SYS_TRUSTED_CERT $SYS_TRUSTED_CERT 
keytool -list -storepass $SYS_STOREPASS -keystore $SYS_TRUSTED_CERT -v > ./tmp/trusted.certs_entries.txt

echo listing entries for SYS_TRUSTED_SITE_CERT $SYS_TRUSTED_SITE_CERT 
keytool -list -storepass $SYS_STOREPASS -keystore $SYS_TRUSTED_SITE_CERT -v > ./tmp/trusted.jssecerts_entries.txt

#echo listing entries for SYS_CLIENT_AUTH_CERT $SYS_CLIENT_AUTH_CERT
#keytool -list -storepass $SYS_STOREPASS -keystore $SYS_CLIENT_AUTH_CERT -v > ./tmp/trusted.clientcerts_entries.txt
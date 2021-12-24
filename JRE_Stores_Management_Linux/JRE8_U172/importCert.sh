#!/bin/bash

########################
# Certificates import  #
########################

keytool -J-Duser.language=en -keystore $SYS_TRUSTED_CA -storepass:file store-pass.txt -storetype $STORE_TYPE -importcert -file ../Certificates/MyCompany/Corporate-PKI/RootCA.cer -alias root-ca -noprompt -v
keytool -J-Duser.language=en -keystore $SYS_TRUSTED_CA -storepass:file store-pass.txt -storetype $STORE_TYPE -importcert -file ../Certificates/MyCompany/Corporate-PKI/IssuingCA.cer -alias issuing-ca -noprompt -v

keytool -J-Duser.language=en -keystore $SYS_TRUSTED_SITE_CA-storepass:file store-pass.txt -storetype $STORE_TYPE -importcert -file ../Certificates/MyCompany/Corporate-PKI/RootCA.cer -alias root-ca -noprompt -v
keytool -J-Duser.language=en -keystore $SYS_TRUSTED_SITE_CA-storepass:file store-pass.txt -storetype $STORE_TYPE -importcert -file ../Certificates/MyCompany/Corporate-PKI/IssuingCA.cer -alias issuing-ca -noprompt -v

keytool -J-Duser.language=en -keystore $SYS_TRUSTED_SITE_CERT -storepass:file store-pass.txt -storetype $STORE_TYPE -importcert -file ../Certificates/MyCompany/Corporate-PKI/my-cert.cer -alias my-cert.cer -noprompt -v

#!/bin/bash

SAN=fake-cert-to-delete-mycompany.com 
DN="CN=${SAN},OU=IT,O=MyCompany,L=Paris,ST=IDF,C=FR,emailAddress=no-reply@groland.grd"

keytool -genkeypair -alias fake-cert-to-delete -keystore ./tmp/empty-TrustStore.jks -dname $DN -ext SAN=dns:$SAN -storepass $SYS_STOREPASS -keypass $SYS_STOREPASS -storetype $STORE_TYPE -keyalg RSA -keysize 2048 -validity 1  -v 
keytool -delete -alias fake-cert-to-delete -keystore ./tmp/empty-TrustStore.jks -storepass $SYS_STOREPASS

cp ./tmp/empty-TrustStore.jks $SYS_TRUSTED_CERT
cp ./tmp/empty-TrustStore.jks $SYS_TRUSTED_SITE_CERT
cp ./tmp/empty-TrustStore.jks $SYS_CLIENT_AUTH_CERT

#  Default keystore type is set in property keystore.type=jks at  /usr/lib/jvm/jdk-1.8.0-openjdk.x86_64/lib/security/java.security & keystore.type=pkcs12 in /usr/lib/jvm/jdk-9.0-openjdk.x86_64/conf/security/java.security
#  ==> it is jks in Java 8 and PKCS12 in Java 9, with PKCS12, -keypass argument is useless
#  https://docs.oracle.com/javase/9/security/java-pki-programmers-guide.htm
#  https://docs.oracle.com/javase/9/tools/keytool.htm#JSWOR-GUID-5990A2E4-78E3-47B7-AE75-6D1826259549
#  "As of JDK 9, the default keystore implementation is PKCS12. This is a cross platform keystore based on the RSA PKCS12 Personal Information Exchange Syntax Standard.
#  This standard is primarily meant for storing or transporting a user's private keys, certificates, and miscellaneous secrets. There is another built-in implementation, provided by Oracle. 
#  It implements the keystore as a file with a proprietary keystore type (format) named JKS. It protects each private key with its individual password, and also protects the integrity of the entire keystore with a (possibly different) password."
#  https://tools.ietf.org/html/rfc5280

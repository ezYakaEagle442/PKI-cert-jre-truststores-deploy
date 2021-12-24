#!/bin/bash

# https://docs.oracle.com/javase/8/docs/technotes/guides/deploy/jcp.html#sthref338


# Trusted Certificates - Certificates for signed RIAs that are trusted.
# Secure Site - Certificates for secure sites.
# Signer CA - Certificates of Certificate Authorities (CAs) who issue the certificates to the signers of trusted certificates.
# Secure Site CA - Certificates of CAs who issue the certificates for secure sites.
# Client Authentication - Certificates used by a client to authenticate itself to a server.


# "20.4.5.2 System-Level Certificates
# You can export and view the details of system-level certificates using the buttons provided in the Certificates dialog. 
# System-level certificates CAN NOT BE IMPORTED OR REMOVED  by an end user.
# Trusted, Secure Site, and Client Authentication certificate keystore files do not exist by default. The following table shows the default location for the Signer CA keystore file.

# Default Location for the Signer CA Keystore : $JAVA_HOME\lib\security\cacerts
# Default Location for the Secure Site CA Keystore : $JAVA_HOME\lib\security\jssecacerts

echo Here is the SYSTEM-LEVEL Certificate Authorities you do TRUST (RootCA, PublishingCA and Certificates) for signed Applications (Java *.jar files)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore $SYS_TRUSTED_CA -v | more

echo Here is the SYSTEM-LEVEL Signer Certificate you do TRUST for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore $SYS_TRUSTED_SITE_CA -v | more 
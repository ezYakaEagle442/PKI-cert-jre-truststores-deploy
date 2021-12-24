REM # https://docs.oracle.com/javase/8/docs/technotes/guides/deploy/jcp.html#sthref338


REM # Trusted Certificates - Certificates for signed RIAs that are trusted.
REM # Secure Site - Certificates for secure sites.
REM # Signer CA - Certificates of Certificate Authorities (CAs) who issue the certificates to the signers of trusted certificates.
REM # Secure Site CA - Certificates of CAs who issue the certificates for secure sites.
REM # Client Authentication - Certificates used by a client to authenticate itself to a server.


REM # "20.4.5.2 System-Level Certificates
REM # You can export and view the details of system-level certificates using the buttons provided in the Certificates dialog. 
REM # System-level certificates CAN NOT BE IMPORTED OR REMOVED  by an end user.
REM # Trusted, Secure Site, and Client Authentication certificate keystore files do not exist by default. The following table shows the default location for the Signer CA keystore file.

REM # Default Location for the Signer CA Keystore : $JAVA_HOME\lib\security\cacerts
REM # Default Location for the Secure Site CA Keystore : $JAVA_HOME\lib\security\jssecacerts

echo Here is the SYSTEM-LEVEL Certificate Authorities you do TRUST (RootCA, PublishingCA and Certificates) for signed Applications (Java *.jar files)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_CA% -v | more

echo Here is the SYSTEM-LEVEL Signer Certificate you do TRUST for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_SITE_CA% -v | more
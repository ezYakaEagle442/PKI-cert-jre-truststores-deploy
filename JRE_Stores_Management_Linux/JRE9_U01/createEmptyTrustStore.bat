set SAN=fake-cert-to-delete-test.apps.company.com 
set DN="CN=%SAN%,OU=IT,O=Company,L=Paris,ST=IDF,C=FR,emailAddress=no-reply@company.com"

keytool -genkeypair -alias AL-fake-cert-to-delete -keystore .\tmp\empty-TrustStore.p12 -dname %DN% -ext SAN=dns:%SAN% -storepass %SYS_STOREPASS% -storetype %STORE_TYPE% -keyalg EC -keysize 256 -validity 1  -v 
keytool -delete -alias AL-fake-cert-to-delete -keystore .\tmp\empty-TrustStore.p12 -storepass %SYS_STOREPASS%

copy .\tmp\empty-TrustStore.p12 %SYS_TRUSTED_CERT%
copy .\tmp\empty-TrustStore.p12 %SYS_TRUSTED_SITE_CERT%
copy .\tmp\empty-TrustStore.p12 %SYS_CLIENT_AUTH_CERT%

REM  Default keystore type is set in property  keystore.type=pkcs12 in C:\Program Files\Java\jdk-9.0.1\conf\security\java.security & keystore.type=jks at  C:\Program Files (x86)\Java\jre1.8.0_131\lib\security\java.security
REM  ==> it is jks in Java 8 and PKCS12 in Java 9, with PKCS12, -keypass argument is useless

REM  https://docs.oracle.com/javase/9/security/java-pki-programmers-guide.htm
REM  https://docs.oracle.com/javase/9/tools/keytool.htm#JSWOR-GUID-5990A2E4-78E3-47B7-AE75-6D1826259549
REM  "As of JDK 9, the default keystore implementation is PKCS12. This is a cross platform keystore based on the RSA PKCS12 Personal Information Exchange Syntax Standard.
REM  This standard is primarily meant for storing or transporting a user's private keys, certificates, and miscellaneous secrets. There is another built-in implementation, provided by Oracle. 
REM  It implements the keystore as a file with a proprietary keystore type (format) named JKS. It protects each private key with its individual password, and also protects the integrity of the entire keystore with a (possibly different) password."
REM  https://tools.ietf.org/html/rfc5280
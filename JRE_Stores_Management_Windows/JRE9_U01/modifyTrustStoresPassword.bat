REM https://bugs.openjdk.java.net/browse/JDK-8193046
echo About to modify password of SYSTEM-LEVEL CA TrustStore  for signed Applications (Java *.jar files)
keytool -J-Duser.language=en -storepasswd -storepass %SYS_STOREPASS_OLD% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CA% -storetype %STORE_TYPE% -v

echo About to modify password of SYSTEM-LEVEL CA TrustStore for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -J-Duser.language=en -storepasswd -storepass %SYS_STOREPASS_OLD% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CA% -storetype %STORE_TYPE% -v

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates  for signed Applications (Java *.jar files)
keytool -J-Duser.language=en -storepasswd -storepass %SYS_STOREPASS_OLD% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CERT% -storetype %STORE_TYPE% -v 

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -J-Duser.language=en -storepasswd -storepass %SYS_STOREPASS_OLD% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CERT% -storetype %STORE_TYPE% -v 

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates for CLIENT authentication
keytool -J-Duser.language=en -storepasswd -storepass %SYS_STOREPASS_OLD% -new %SYS_STOREPASS_NEW% -keystore %SYS_CLIENT_AUTH_CERT% -storetype %STORE_TYPE% -v

REM test
REM keytool -J-Duser.language=en -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CA%
REM keytool -J-Duser.language=en -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CA% 

REM keytool -J-Duser.language=en -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CERT% 
REM keytool -J-Duser.language=en -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CERT% 
REM keytool -J-Duser.language=en -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_CLIENT_AUTH_CERT% 
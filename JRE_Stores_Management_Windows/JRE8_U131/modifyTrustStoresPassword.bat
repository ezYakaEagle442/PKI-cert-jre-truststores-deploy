echo About to modify password of SYSTEM-LEVEL CA TrustStore  for signed Applications (Java *.jar files)
keytool -storepasswd -storepass %SYS_STOREPASS% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CA% -storetype %STORE_TYPE% -v

echo About to modify password of SYSTEM-LEVEL CA TrustStore for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -storepasswd -storepass %SYS_STOREPASS% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CA% -storetype %STORE_TYPE% -v

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates  for signed Applications (Java *.jar files)
keytool -storepasswd -storepass %SYS_STOREPASS% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CERT% -storetype %STORE_TYPE% -v 

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -storepasswd -storepass %SYS_STOREPASS% -new %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CERT% -storetype %STORE_TYPE% -v 

echo About to modify password of SYSTEM-LEVEL TRUSTED certificates for CLIENT authentication
keytool -storepasswd -storepass %SYS_STOREPASS% -new %SYS_STOREPASS_NEW% -keystore %SYS_CLIENT_AUTH_CERT% -storetype %STORE_TYPE% -v

REM test
REM keytool -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CA%
REM keytool -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CA% 

REM keytool -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_CERT% 
REM keytool -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_TRUSTED_SITE_CERT% 
REM keytool -list -storepass %SYS_STOREPASS_NEW% -keystore %SYS_CLIENT_AUTH_CERT% 
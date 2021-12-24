REM ########################
REM # Certificates import  #
REM ########################

keytool -J-Duser.language=en -keystore %SYS_TRUSTED_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\MyCompany\Corporate-PKI\root-ca.cer -alias root-ca -noprompt -v
keytool -J-Duser.language=en -keystore %SYS_TRUSTED_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\MyCompany\Corporate-PKI\issuing-ca.cer -alias issuing-ca -noprompt -v

keytool -J-Duser.language=en -keystore %SYS_TRUSTED_SITE_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\MyCompany\Corporate-PKI\root-ca.cer -alias root-ca -noprompt -v
keytool -J-Duser.language=en -keystore %SYS_TRUSTED_SITE_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\MyCompany\Corporate-PKI\issuing-ca.cer -alias issuing-ca -noprompt -v

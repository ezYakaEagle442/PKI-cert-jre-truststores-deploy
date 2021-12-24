REM ########################
REM # Certificates import  #
REM ########################

keytool -J-Duser.language=en -keystore %SYS_TRUSTED_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\ALIT\GIO-PKI\AL_RootCA.cer -alias al-root-ca -noprompt -v
keytool -J-Duser.language=en -keystore %SYS_TRUSTED_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\ALIT\GIO-PKI\AL_SA_IssuingCA.cer -alias al-sa-issuing-ca -noprompt -v

keytool -J-Duser.language=en -keystore %SYS_TRUSTED_SITE_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\ALIT\GIO-PKI\AL_RootCA.cer -alias al-root-ca -noprompt -v
keytool -J-Duser.language=en -keystore %SYS_TRUSTED_SITE_CA% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\ALIT\GIO-PKI\AL_SA_IssuingCA.cer -alias al-sa-issuing-ca -noprompt -v

keytool -J-Duser.language=en -keystore %SYS_TRUSTED_SITE_CERT% -storepass:file store-pass.txt -storetype %STORE_TYPE% -importcert -file ..\Certificates\ALIT\GIO-PKI\gitlab-pprd.cer -alias gitlab-pprd -noprompt -v
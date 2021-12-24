@echo on
set /p var=Have you read carefully the README file ?[Y/N]: 
if %var%== Y goto :automation
if not %var%== Y goto :end
:automation

set PATH=C:\Program Files\Java\jdk-9.0.1\bin;%PATH%

set JRE_VERSION=jre1.8.0_131
set JRE_HOME="C:\Program Files (x86)\Java\"%JRE_VERSION%
set JRE_BIN=%JRE_HOME%\bin

set JRE_SECURITY_FOLDER=%JRE_HOME%\lib\security
set SYSTEM_SECURITY_FOLDER=C:\Windows\Sun\Java\Deployment\security
set USR_SECURITY_FOLDER=C:\Users\%USERNAME%\AppData\LocalLow\Sun\Java\Deployment\security

set STORE_TYPE=JKS
set SYS_STOREPASS=changeit
REM Modify SYS_STOREPASS_NEW value to the content of file store-pass.txt
set SYS_STOREPASS_NEW=KEY#KiP@ss131--

set TRUSTED_CA=cacerts
set TRUSTED_SITE_CA=jssecacerts
set TRUSTED_CERT=trusted.certs
set TRUSTED_SITE_CERT=trusted.jssecerts
set CLIENT_AUTH_CERT=trusted.clientcerts

set SYS_TRUSTED_CA=.\out\%TRUSTED_CA%
set SYS_TRUSTED_SITE_CA=.\out\%TRUSTED_SITE_CA%

set SYS_TRUSTED_CERT=.\out\%TRUSTED_CERT%
set SYS_TRUSTED_SITE_CERT=.\out\%TRUSTED_SITE_CERT%
set SYS_CLIENT_AUTH_CERT=.\out\%CLIENT_AUTH_CERT%

set USR_TRUSTED_CA=%USR_SECURITY_FOLDER%\trusted.cacerts
set USR_TRUSTED_SITE_CA=%USR_SECURITY_FOLDER%\trusted.jssecacerts

set USR_TRUSTED_CERTIFICATES=%USR_SECURITY_FOLDER%\%TRUSTED_CERT%
set USR_TRUSTED_SITE_CERTIFICATES=%USR_SECURITY_FOLDER%\%TRUSTED_SITE_CERT%


REM mkdir %SYSTEM_SECURITY_FOLDER%

CALL clean.bat
CALL createRootTrustStores.bat
CALL createEmptyTrustStore.bat
CALL checkEmptyKeyStores.bat
CALL modifyTrustStoresPassword.bat
CALL importCert.bat
REM CALL list-CACerts.bat
REM CALL list-Certs.bat
CALL checkSystemStores.bat
CALL copyStoresToJRE.bat
CALL run-JCP.bat 

:end
echo This is the end !
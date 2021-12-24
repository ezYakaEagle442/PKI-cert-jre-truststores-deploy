echo Here is the SYSTEM-LEVEL Certificate Authorities you do TRUST (RootCA, PublishingCA and Certificates) for signed Applications (Java *.jar files)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_CA% -v | more

echo Here is the SYSTEM-LEVEL Signer Certificate you do TRUST for web servers configured with SSL and providing its certificate (*.cer, *.pem)
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_SITE_CA% -v | more
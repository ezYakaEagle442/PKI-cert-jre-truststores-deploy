echo listing entries for SYS_TRUSTED_CA %SYS_TRUSTED_CA%: 
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_CA% -v > .\tmp\cacerts_entries.txt

echo listing entries for SYS_TRUSTED_SITE_CA %SYS_TRUSTED_SITE_CA% 
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_SITE_CA% -v > .\tmp\jssecacerts_entries.txt

echo listing entries for SYS_TRUSTED_CERT %SYS_TRUSTED_CERT% 
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_CERT% -v > .\tmp\trusted.certs_entries.txt

echo listing entries for SYS_TRUSTED_SITE_CERT %SYS_TRUSTED_SITE_CERT% 
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_TRUSTED_SITE_CERT% -v > .\tmp\trusted.jssecerts_entries.txt

echo listing entries for SYS_CLIENT_AUTH_CERT %SYS_CLIENT_AUTH_CERT% 
keytool -J-Duser.language=en -list -storepass:file store-pass.txt -keystore %SYS_CLIENT_AUTH_CERT% -v > .\tmp\trusted.clientcerts_entries.txt
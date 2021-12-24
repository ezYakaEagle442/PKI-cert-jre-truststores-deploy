Note: By default JRE is installed only with one CA TrustStore at C:\Program Files (x86)\Java\jreXXX\lib\security\cacerts

https://docs.oracle.com/javase/9/tools/keytool.htm
https://docs.oracle.com/javase/9/deploy/java-control-panel.htm#JSDPG778

/!\ IMPORTANT 

I. run once and only once backup-GA-cacerts.bat
==> Copy GA cacerts from  JRE installed on workstation,ex:
"C:\Program Files\Java\jdk-9.0.1\lib\security\cacerts" to \JRE_Stores_Management\jre-9.0.1\GA\lib\security\cacerts
"C:\Program Files (x86)\Java\jre1.8.0_xxx\lib\security\cacerts" to \JRE_Stores_Management\jre1.8.0_xxx\GA\lib\security\cacerts


II. before running modifyTrustStoresPassword.bat, modify run automation_run_as_admin.bat set SYS_STOREPASS_NEW value to the content of file store-pass.txt

/!\ BUG  during importCert.bat : keytool : java.util.IllegalFormatConversionException: d != java.lang.String
see also https://stackoverflow.com/questions/47134165/keytool-import-certificate-java-util-illegalformatconversionexception-in-linux/47181882
 problem on last java versions occurs only for some languages. 
 Hence it is enough to force the output language of keytool in english to solve the problem by adding the parameter -J-Duser.language=en

III.After you can run CMD AS ADMIN with CyberArk Endpoint Privilege Manager Agent : sudo_run_as_admin_init_launcher.bat
IV. Then run automation_run_as_admin.bat, this will perform the following steps:

set PATH=C:\Program Files\Java\jdk-9.0.1\bin;%PATH%

1. createRootTrustStores.bat
2. createEmptyTrustStore.bat
3. checkEmptyKeyStores.bat

4. (manual check :Check the keystores are really empty, reading files below :)
.\tmp\trusted.certs_entries.txt
.\tmp\trusted.clientcerts_entries.txt
.\tmp\trusted.jssecerts_entries.txt

5. modifyTrustStoresPassword.bat 
   ==> there is a bug in keytool -storepasswd when providing the -new arg it fails, workaround is to remove  the -new arg and provide the new password in interactive mode
	
6. importCert.bat
7. (list-CACerts.bat + list-Certs.bat)
8. checkSystemStores.bat
9. copyStoresToJRE.bat
10. run-JCP.bat  
(Final  manual check : Check with Java Control Pannel : C:\Program Files\Java\jre-9.0.1\bin\javacpl.exe)
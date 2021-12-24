# ==============================================================================================
# 
# 
# 
# NAME: automation_run_as_admin.ps1
# 
# AUTHOR: Steve PINCAUD
# DATE   : 01/06/2018 (DD/MM/YYYY)
# VERSION: 1.0.0
#
# USAGE: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "%~dp0automation_run_as_admin.ps1" -RunAllAutomation
#
# Pre-Requisites: SecretManager i supported in CLI > v1.15, run aws --version to check your current version
#
# 
# 1. Install AWS CLI for .Net / PowerShell : https://s3.amazonaws.com/aws-cli/AWSCLI64.msi
# (https://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi is stuck to aws CLI v1.12 and fails to upgrade then)
# ==> It will install it at C:\Program Files (x86)\AWS Tools
# ==> It will need to install NuGet also at : C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208
#
# 2. Upgrade CLI : pip --proxy http://gateway.yourproxycompany.zscaler.net:80  install awscli --upgrade --user
#
# COMMENT: Next release will use AWS Secrets Management to manage Store-Pass
#
# See AWS Secrets Management: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html
# See PowserShell CLI 		: https://aws.amazon.com/powershell/?nc1=h_ls | https://docs.aws.amazon.com/powershell/latest/userguide/pstools-welcome.html
# See also Best Practices:    https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html 
#
# Source files : https://www.nuget.org/packages/AWSSDK.SecretsManager/ | https://github.com/aws/aws-sdk-net
# PowserShell Install instructions: https://github.com/PowerShell/PowerShell/blob/master/docs/installation/windows.md
#
# Test :you can run as admin : 
#   C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#	C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#		==> then run ISE
#		==> run Get-ExecutionPolicy to check the "Bypass" is enabled
#
#	"C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\" ==> C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& Initialize-AWSDefaultConfiguration"
#	"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" 
# 	"C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell"
# 	"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Amazon Web Services"
# ==============================================================================================

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-6
param(
    [Parameter(position=0, Mandatory=$true, HelpMessage="/!\ IMPORTANT perform a backup")]
    [switch]$backup,
	[Parameter(position=0, Mandatory=$false)]
    [switch]$clean,
    [Parameter(position=0, Mandatory=$false)]
    [switch]$traceVar,	
    [Parameter(position=0)]
	[switch]$createRootTrustStores,	
    [Parameter(position=0)]
	[switch]$createEmptyTrustStore,	
    [Parameter(position=0)]
	[switch]$checkEmptyKeyStores,	
	[Parameter(position=0)]
    [switch]$modifyTrustStoresPassword,	
	[Parameter(position=0, Mandatory=$true)]
    [switch]$importCert,
    [Parameter(position=2)]	
	[switch]$listCACerts,	
	[switch]$listCerts,	
    [Parameter(position=2)]
	[switch]$checkSystemStores,	
	[switch]$copyStoresToJRE,	
	[switch]$runJCP,
    [Parameter(Mandatory=$false)]
	[switch]$display_logo,
    [switch]$runAllAutomation,
    [switch]$getSecretKeyPass,
    [switch]$getSecretStorePass,
    [switch]$createSecretStorePass
)

################################################################################################
# Declare variables
################################################################################################

$STORE_TYPE="JKS"
$SYS_STOREPASS="changeit"
# Modify SYS_STOREPASS_NEW value to the content of file store-pass.txt
$SYS_STOREPASS_NEW="KEY_KiP@ss131--"

$WORK_DIR="V:\Workspaces\JRE_TrustStores_Management\src\JRE_Stores_Management_Windows\JRE8_U131"
$WORK_DIR_TMP="$WORK_DIR\tmp"
$WORK_DIR_OUT="$WORK_DIR\out"

#$LogPath = "$env:windir\temp\JRE_TrustStoreManagement_Automation"
$LogPath = "V:\Workspaces\JRE_TrustStores_Management\src\JRE_Stores_Management_Windows\JRE8_U131"
$LogFile = "$LogPath\JRE_TrustStoreManagement_Automation.log"

#Script Variables
$ScriptName = $MyInvocation.MyCommand.Name
$ScriptPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent

#Return codes
$ReturnCodes = @{"OK" = 0;
				"MISSING_ARG" = 1;
				"CREATE_FOLDER_ERROR" = 1603;
				"COPY_FILE_ERROR" = 1603;
				"FILE_NOT_FOUND" = 1603;
                "README_NOT_READ"= 1603;
				}
				
$USERNAME="$env:USERNAME"
#$USERNAME="WHOAMI"
$HOSTNAME=HOSTNAME

$JRE_VERSION="jre1.8.0_131"
$JRE_HOME="C:\Program Files (x86)\Java\$JRE_VERSION"
$JRE_BIN="$JRE_HOME\bin"

### Modify system environment variable ###
#[Environment]::SetEnvironmentVariable
#     ( "Path", "C:\Program Files\Java\jdk-9.0.1\bin;", $env:Path, [System.EnvironmentVariableTarget]::Machine )
$Env:Path="C:\Program Files\Java\jdk-9.0.1\bin;" + $Env:Path

$JRE_SECURITY_FOLDER="$JRE_HOME\lib\security"
$SYSTEM_SECURITY_FOLDER="$env:windir\Sun\Java\Deployment\security"
$USR_SECURITY_FOLDER="C:\Users\$USERNAME\AppData\LocalLow\Sun\Java\Deployment\security"

$TRUSTED_CA="cacerts"
$TRUSTED_SITE_CA="jssecacerts"
$TRUSTED_CERT="trusted.certs"
$TRUSTED_SITE_CERT="trusted.jssecerts"
$CLIENT_AUTH_CERT="trusted.clientcerts"

$SYS_TRUSTED_CA="$WORK_DIR_OUT\$TRUSTED_CA"
$SYS_TRUSTED_SITE_CA="$WORK_DIR_OUT\$TRUSTED_SITE_CA"

$SYS_TRUSTED_CERT="$WORK_DIR_OUT\$TRUSTED_CERT"
$SYS_TRUSTED_SITE_CERT="$WORK_DIR_OUT\$TRUSTED_SITE_CERT"
$SYS_CLIENT_AUTH_CERT="$WORK_DIR_OUT\$CLIENT_AUTH_CERT"

$USR_TRUSTED_CA="$USR_SECURITY_FOLDER\trusted.cacerts"
$USR_TRUSTED_SITE_CA="$USR_SECURITY_FOLDER\trusted.jssecacerts"

$USR_TRUSTED_CERTIFICATES="$USR_SECURITY_FOLDER\$TRUSTED_CERT"
$USR_TRUSTED_SITE_CERTIFICATES="$USR_SECURITY_FOLDER\$TRUSTED_SITE_CERT"


################################################################################################
# Functions
################################################################################################

Function Log {
	Param ([string]$logMsg)
	Add-content $LogFile -value $logMsg
	Write-Host $logMsg
}

Function Log-Step {
	Param ([string]$logMsg)
	$Separator = "#" * ($logstring.length + 22)
	Log $Separator
	Log "$(Get-Date -Format G) - $logMsg"
	Log $Separator
}

Function Log-Sub-Step {
	Param ([string]$logMsg)
	$Separator = "-" * ($logMsg.length + 22)
	Log $Separator
	Log "$(Get-Date -Format G) - $logMsg"
	Log $Separator
}

Function Start-Script {
	Log "`r`n"
	Log "`r`n"
	$logMsg = "Starting execution of ""$ScriptName"" script"
	$Separator = "_" * ($logMsg.length + 26)
	Log $Separator
	$Separator = "|"
	$Separator = $Separator + " " * ($logMsg.length + 24)
	$Separator = $Separator + "|"
	Log $Separator
	Log "| $(Get-Date -Format G) - $logMsg |"
	$Separator = "|"
	$Separator = $Separator + "_" * ($logMsg.length + 24)
	$Separator = $Separator + "|"
	Log $Separator
}

Function Terminate-Script {
	Param ([string]$ReturnCode)
	Log-Step "Ending execution of ""$ScriptName"" script"
	Log "Return code: $($ReturnCodes[$ReturnCode])"
	Log "Return status: $ReturnCode"
	Exit $ReturnCodes[$ReturnCode]
}

#Display Logo & SCCM Advertisement ID
Function Display-Logo() {
	for($i=1; $i -le 10; $i++){Log "`r`n"}
	$Separator = "#" * 99
	Log $Separator
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"
	Log "# JRE TrustStoreManagement Automation	 $(Get-Date -Format G)                                     #"
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"
	Log "#       ###########     ###########     ###########                                               #"
	Log "#       #         #     #               #                                                         #"
	Log "#       #         #     #               #                                                         #"
	Log "#       #         #     ###########     ###########                                               #"
	Log "#       #         #               #               #                                               #"
	Log "#       #         #               #               #                                               #"
	Log "#       ###########     ###########     ###########                                               #"
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"
	Log "#                                                                                                 #"

	Log $Separator
	$CcmExecutionRequestEx = Get-WmiObject -class CCM_ExecutionRequestex -NameSpace "root\ccm\softmgmtagent"
	$FoundRunningAdv = $false
	Foreach ($job in $CcmExecutionRequestEx){
		If ($job.RunningState -eq 'Running'){
			Log "Found the following running advertisement ID: $($job.AdvertID)"
			$FoundRunningAdv = $true
		}
	}
	if (!($FoundRunningAdv)){
		Log "No running advertisement found"
	}
	Log "`r`n"
	# Exit
}



################################################################################################
# Back-Up
################################################################################################
Function Back-Up {
	Log "+++ Back-Up  BEGIN"
	Try {

        $BACKUP_NAME="cacerts-GA-backup.original"
        
        if ((Test-Path -Path "$JRE_SECURITY_FOLDER\$TRUSTED_CA") -eq $true) {
            
            Log "$SYS_TRUSTED_CA file found"
		    Log-Sub-Step "Copying `"$JRE_SECURITY_FOLDER\$TRUSTED_CA`" file to `"..\$JRE_VERSION\GA\lib\security\cacerts.GA`" folder..."
		    Copy-Item -LiteralPath "$JRE_SECURITY_FOLDER\$TRUSTED_CA" -Destination "..\$JRE_VERSION\GA\lib\security\cacerts.GA" -errorAction SilentlyContinue

		    Log-Sub-Step "Copying `"$JRE_SECURITY_FOLDER\$TRUSTED_CA`" file to `"${JRE_SECURITY_FOLDER}\${BACKUP_NAME}`" folder..."
		    Copy-Item -LiteralPath "$JRE_SECURITY_FOLDER\$TRUSTED_CA"  -Destination "${JRE_SECURITY_FOLDER}\${BACKUP_NAME}" -errorAction SilentlyContinue

		    if (!$?) {
			    Log "ERROR: failed to copy the $SYS_TRUSTED_CA file. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
			    Terminate-Script "COPY_FILE_ERROR"
		    }
		    else {
			    Log "File `"$JRE_SECURITY_FOLDER\$TRUSTED_CA`" successfully copied!"
		    }
	    }
	    else {
		    Log "ERROR: `"$JRE_SECURITY_FOLDER\$TRUSTED_CA`" file not found."
	    }
    }
    Catch {
		Log "ERROR: failed to BackUp the JRE GA TrustStore"
		Log "Error message: $($_.Exception.Message)"
		Log "Exception type: $($_.Exception.GetType().FullName)"
	}	
	Log "+++ Back-Up END"
	
}


################################################################################################
# Clean
################################################################################################
Function Clean {
	Log "+++ Clean  BEGIN"
	Try {
		Remove-Item -Path "$WORK_DIR_TMP\*" -Force
		Remove-Item -Path "$WORK_DIR_OUT\*" -Force
		
			
		Remove-Item -Path "$JRE_SECURITY_FOLDER\$TRUSTED_CA" -Force
		Remove-Item -Path "$JRE_SECURITY_FOLDER\$TRUSTED_SITE_CA" -Force
			
		Remove-Item -Path "$JRE_SECURITY_FOLDER\$TRUSTED_CERT" -Force
		Remove-Item -Path "$JRE_SECURITY_FOLDER\$TRUSTED_SITE_CERT" -Force
		Remove-Item -Path "$JRE_SECURITY_FOLDER\$CLIENT_AUTH_CERT" -Force
		
		Remove-Item -Path "$SYSTEM_SECURITY_FOLDER\$TRUSTED_CERT" -Force
		Remove-Item -Path "$SYSTEM_SECURITY_FOLDER\$TRUSTED_SITE_CERT" -Force
		Remove-Item -Path "$SYSTEM_SECURITY_FOLDER\$CLIENT_AUTH_CERT" -Force
		
		Remove-Item -Path "$USR_SECURITY_FOLDER\$TRUSTED_CERT" -Force
		Remove-Item -Path "$USR_SECURITY_FOLDER\$TRUSTED_SITE_CERT" -Force
		Remove-Item -Path "$USR_SECURITY_FOLDER\$CLIENT_AUTH_CERT" -Force
	}
    Catch {
		Log "ERROR: failed to remove the file."
		Log "Error message: $($_.Exception.Message)"
		Log "Exception type: $($_.Exception.GetType().FullName)"
	}	
	Log "+++ Clean END"
	
}

################################################################################################
# Create-Root-Trust-Stores
################################################################################################
Function Create-Root-Trust-Stores {
	Log "+++ CreateRootTrustStores BEGIN"
	
	Copy-Item -LiteralPath  "..\$JRE_VERSION\GA\lib\security\cacerts.GA" -Destination "$SYS_TRUSTED_CA" -errorAction SilentlyContinue
	Copy-Item -LiteralPath  "..\$JRE_VERSION\GA\lib\security\cacerts.GA" -Destination "$SYS_TRUSTED_SITE_CA" -errorAction SilentlyContinue	
	
	Log "+++ CreateRootTrustStores END"
	
}

################################################################################################
# 
#  Default keystore type is set in property keystore.type=jks at  /usr/lib/jvm/jdk-1.8.0-openjdk.x86_64/lib/security/java.security & keystore.type=pkcs12 in /usr/lib/jvm/jdk-9.0-openjdk.x86_64/conf/security/java.security
#  ==> it is jks in Java 8 and PKCS12 in Java 9, with PKCS12, -keypass argument is useless
#  https://docs.oracle.com/javase/9/security/java-pki-programmers-guide.htm
#  https://docs.oracle.com/javase/9/tools/keytool.htm#JSWOR-GUID-5990A2E4-78E3-47B7-AE75-6D1826259549
#  "As of JDK 9, the default keystore implementation is PKCS12. This is a cross platform keystore based on the RSA PKCS12 Personal Information Exchange Syntax Standard.
#  This standard is primarily meant for storing or transporting a user's private keys, certificates, and miscellaneous secrets. There is another built-in implementation, provided by Oracle. 
#  It implements the keystore as a file with a proprietary keystore type (format) named JKS. It protects each private key with its individual password, and also protects the integrity of the entire keystore with a (possibly different) password."
#  https://tools.ietf.org/html/rfc5280
#
################################################################################################
Function Create-Empty-Trust-Store {
	Log "+++ Create-Empty-Trust-Store BEGIN"
	
	$SAN="fake-cert-to-delete-mycompany.com"
	$DN="CN=$SAN, OU=IT, O=My Company, L=Paris, ST=IDF, C=FR, emailAddress=no-reply@groland.grd"
	
    Log "SAN=$SAN"
    Log "DN=$DN"

	Invoke-Expression "keytool `"-J-Duser.language=en`"  -genkeypair -alias fake-cert-to-delete -keystore `"$WORK_DIR_TMP\empty-TrustStore.jks`" -dname `"$DN`" -ext SAN=dns:`"$SAN`" -storepass $SYS_STOREPASS -keypass $SYS_STOREPASS -storetype $STORE_TYPE -keyalg RSA -keysize 2048 -validity 1  -v"
	Invoke-Expression "keytool `"-J-Duser.language=en`"  -delete -alias fake-cert-to-delete -keystore `"$WORK_DIR_TMP\empty-TrustStore.jks`" -storepass $SYS_STOREPASS"
	
	Copy-Item -LiteralPath  "$WORK_DIR_TMP\empty-TrustStore.jks" -Destination $SYS_TRUSTED_CERT -errorAction SilentlyContinue
	Copy-Item -LiteralPath  "$WORK_DIR_TMP\empty-TrustStore.jks" -Destination $SYS_TRUSTED_SITE_CERT -errorAction SilentlyContinue
	Copy-Item -LiteralPath  "$WORK_DIR_TMP\empty-TrustStore.jks" -Destination $SYS_CLIENT_AUTH_CERT -errorAction SilentlyContinue

	Log "+++ Create-Empty-Trust-Store END"
	
}

################################################################################################
#  Check-Empty-Key-Stores
################################################################################################
Function Check-Empty-Key-Stores {
	Log "+++  Check-Empty-Key-Stores BEGIN"
	
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file?view=powershell-6
	Log "listing entries for SYS_TRUSTED_CERT $SYS_TRUSTED_CERT "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass $SYS_STOREPASS -keystore `"$SYS_TRUSTED_CERT`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.certs_entries.txt"
	
	Log "listing entries for SYS_TRUSTED_SITE_CERT $SYS_TRUSTED_SITE_CERT "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass $SYS_STOREPASS -keystore `"$SYS_TRUSTED_SITE_CERT`" -v" |  Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.jssecerts_entries.txt"
	
	Log "listing entries for SYS_CLIENT_AUTH_CERT $SYS_CLIENT_AUTH_CERT"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass $SYS_STOREPASS -keystore `"$SYS_CLIENT_AUTH_CERT`" -v" |  Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.clientcerts_entries.txt"
	
	Log "+++  Check-Empty-Key-Stores END"
	
}

################################################################################################
#  Modify-Trust-Stores-Password
################################################################################################
Function Modify-Trust-Stores-Password {
	Log "+++ Modify-Trust-Stores-Password BEGIN"

	Log "About to modify password of SYSTEM-LEVEL CA TrustStore  for signed Applications (Java *.jar files)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -storepasswd -storepass $SYS_STOREPASS -new $SYS_STOREPASS_NEW -keystore `"$SYS_TRUSTED_CA`" -storetype $STORE_TYPE -v"
	
	Log "About to modify password of SYSTEM-LEVEL CA TrustStore for web servers configured with SSL and providing its certificate (*.cer, *.pem)"
	Invoke-Expression "keytool `"-J-Duser.language=en`"-storepasswd -storepass $SYS_STOREPASS -new $SYS_STOREPASS_NEW -keystore `"$SYS_TRUSTED_SITE_CA`" -storetype $STORE_TYPE -v"
	
	Log "About to modify password of SYSTEM-LEVEL TRUSTED certificates  for signed Applications (Java *.jar files)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -storepasswd -storepass $SYS_STOREPASS -new $SYS_STOREPASS_NEW -keystore `"$SYS_TRUSTED_CERT`" -storetype $STORE_TYPE -v" 
	
	Log "About to modify password of SYSTEM-LEVEL TRUSTED certificates for web servers configured with SSL and providing its certificate (*.cer, *.pem)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -storepasswd -storepass $SYS_STOREPASS -new $SYS_STOREPASS_NEW -keystore `"$SYS_TRUSTED_SITE_CERT`" -storetype $STORE_TYPE -v"
	
	Log "About to modify password of SYSTEM-LEVEL TRUSTED certificates for CLIENT authentication"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -storepasswd -storepass $SYS_STOREPASS -new $SYS_STOREPASS_NEW -keystore `"$SYS_CLIENT_AUTH_CERT`" -storetype $STORE_TYPE -v"

	
	Log "+++ Modify-Trust-Stores-Password END"
	
}

################################################################################################
# Import-Cert
################################################################################################
Function Import-Cert {
	Log "+++ Import-Cert BEGIN"
	

	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_CA`" -storepass:file store-pass.txt -storetype `"$STORE_TYPE`" -importcert -file `"..\Certificates\MyCompany\Corporate-PKI\root-ca.cer`" -alias root-ca -noprompt -v"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_CA`" -storepass:file store-pass.txt -storetype `"$STORE_TYPE`" -importcert -file `"..\Certificates\MyCompany\Corporate-PKI\issuing-ca.cer`" -alias issuing-ca -noprompt -v"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_SITE_CA`" -storepass:file store-pass.txt -storetype `"$STORE_TYPE`" -importcert -file `"..\Certificates\MyCompany\Corporate-PKI\root-ca.cer`" -alias root-ca -noprompt -v"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_SITE_CA`" -storepass:file store-pass.txt -storetype `"$STORE_TYPE`" -importcert -file `"..\Certificates\MyCompany\Corporate-PKI\issuing-ca.cer`" -alias issuing-ca -noprompt -v"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_SITE_CERT`" -storepass:file store-pass.txt -storetype `"$STORE_TYPE`" -importcert -file `"..\Certificates\MyCompany\Corporate-PKI\my-cert.cer`" -alias my-cert -noprompt -v"
	
	Log "+++ Import-Cert END"
	
}

################################################################################################
#  List-CACerts
################################################################################################
Function List-CACerts {
	Log "+++ List-CACerts BEGIN"

	Log "Here is the SYSTEM-LEVEL Certificate Authorities you do TRUST (RootCA, PublishingCA and Certificates) for signed Applications (Java *.jar files)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_CA`" -v | more"
	
	Log "Here is the SYSTEM-LEVEL Signer Certificate you do TRUST for web servers configured with SSL and providing its certificate (*.cer, *.pem)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_SITE_CA`" -v | more"
	
	Log "+++ List-CACerts END"
	
}

################################################################################################
# List-Certs
################################################################################################
Function List-Certs {
	Log "+++ List-Certs BEGIN"

	Log "Here is the SYSTEM-LEVEL Certificate Authorities you do TRUST (RootCA, PublishingCA and Certificates) for signed Applications (Java *.jar files)"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_CERT`" -list -storepass:file store-pass.txt  -v | more"
	
$exeCmdc = @'
& "keytool" `"-J-Duser.language=en`" -keystore `"$SYS_TRUSTED_CERT`" -list -storepass:file store-pass.txt  -v | more 
'@
    #Invoke-Expression $exeCmdc

	Log "Here is the SYSTEM-LEVEL Signer Certificate you do TRUST for web servers configured with SSL and providing its certificate (*.cer, *.pem)"
	& keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_SITE_CERT`" -v | more
	
	Log "+++ List-Certs END"
	
}

################################################################################################
# Check-System-Stores
################################################################################################
Function Check-System-Stores {
	Log "+++ Check-System-Stores BEGIN"
	
	Log "listing entries for SYS_TRUSTED_CA ${SYS_TRUSTED_CA}: "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_CA`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\cacerts_entries.txt"
	
	Log "listing entries for SYS_TRUSTED_SITE_CA ${SYS_TRUSTED_SITE_CA}"
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_SITE_CA`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\jssecacerts_entries.txt"
	
	Log "listing entries for SYS_TRUSTED_CERT ${SYS_TRUSTED_CERT} "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_CERT`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.certs_entries.txt"
	
	Log "listing entries for SYS_TRUSTED_SITE_CERT ${SYS_TRUSTED_SITE_CERT} "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_TRUSTED_SITE_CERT`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.jssecerts_entries.txt"
	
	Log "listing entries for SYS_CLIENT_AUTH_CERT ${SYS_CLIENT_AUTH_CERT} "
	Invoke-Expression "keytool `"-J-Duser.language=en`" -list -storepass:file store-pass.txt -keystore `"$SYS_CLIENT_AUTH_CERT`" -v" | Out-File -Append -Encoding ASCII -FilePath "$WORK_DIR_TMP\trusted.clientcerts_entries.txt"	

	
	Log "+++ Check-System-Stores END"
	
}

################################################################################################
# Copy-Stores-To-JRE
################################################################################################
Function Copy-Stores-To-JRE {
	Log "+++  Copy-Stores-To-JRE BEGIN"

	$jreTrustStoresFiles = 	"$SYS_TRUSTED_CA",
							"$SYS_TRUSTED_SITE_CA",
							"$SYS_TRUSTED_CERT",
							"$SYS_TRUSTED_SITE_CERT",
							"$SYS_CLIENT_AUTH_CERT"

	$sysTrustStoresFiles =  "$SYS_TRUSTED_SITE_CERT",
							"$SYS_TRUSTED_CERT",
							"$SYS_CLIENT_AUTH_CERT"

	$usrTrustStoresFiles = 	"$SYS_TRUSTED_SITE_CERT",
							"$SYS_TRUSTED_CERT"
														
	#Copying files
	Foreach ($SourceFile in $jreTrustStoresFiles) {
		if ((Test-Path -Path $SourceFile) -eq $true) {
			Log-Sub-Step "Copying ""$SourceFile"" file to ""$JRE_SECURITY_FOLDER"" folder..."
			Copy-Item -LiteralPath $SourceFile -Destination $JRE_SECURITY_FOLDER -errorAction SilentlyContinue
			if (!$?) {
				Log "ERROR: failed to copy the $SourceFile file. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
				Terminate-Script "COPY_FILE_ERROR"
			}
			else {
				Log "File $SourceFile successfully copied!"
			}
		}
		else {
			Log "ERROR: $SourceFile file not found."
			Terminate-Script "FILE_NOT_FOUND"
		}
	}
							
	Foreach ($SourceFile in $sysTrustStoresFiles) {
		if ((Test-Path -Path $SourceFile) -eq $true) {
			Log-Sub-Step "Copying ""$SourceFile"" file to ""$SYSTEM_SECURITY_FOLDER"" folder..."
			Copy-Item -LiteralPath $SourceFile -Destination $SYSTEM_SECURITY_FOLDER -errorAction SilentlyContinue
			if (!$?) {
				Log "ERROR: failed to copy the $SourceFile file. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
				Terminate-Script "COPY_FILE_ERROR"
			}
			else {
				Log "File $SourceFile successfully copied!"
			}
		}
		else {
			Log "ERROR: $SourceFile file not found."
			Terminate-Script "FILE_NOT_FOUND"
		}
	}
	

	Foreach ($SourceFile in $usrTrustStoresFiles) {
		if ((Test-Path -Path $SourceFile) -eq $true) {
			Log-Sub-Step "Copying ""$SourceFile"" file to ""$USR_TRUSTED_SITE_CERTIFICATES"" folder..."
			Copy-Item -LiteralPath $SourceFile -Destination $USR_TRUSTED_SITE_CERTIFICATES -errorAction SilentlyContinue
			if (!$?) {
				Log "ERROR: failed to copy the $SourceFile file. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
				Terminate-Script "COPY_FILE_ERROR"
			}
			else {
				Log "File $SourceFile successfully copied!"
			}
		}
		else {
			Log "ERROR: $SourceFile file not found."
			Terminate-Script "FILE_NOT_FOUND"
		}
	}
	
	Log "+++  Copy-Stores-To-JRE END"
	
}

################################################################################################
# Run-JCP
################################################################################################
Function Run-JCP {
	Log "+++ Run-JCP BEGIN"
	& "$JRE_BIN\javacpl.exe"
	Log "+++ Run-JCP END"
	
}

################################################################################################
# Create-Secret-Store-Pass
################################################################################################
Function Create-Secret-Store-Pass {
    # https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_create-basic-secret.html
    # https://docs.aws.amazon.com/powershell/latest/reference/Index.html
	Log "+++ Create-Secret-Store-Pass BEGIN"
    Import-Module AWSPowerShell
    Get-AWSPowerShellVersion -ListServiceVersionInfo
    Get-AWSCredentials -ListProfileDetail -Verbose
    

	# Get-Module
    
    #
    # https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html#specifying-your-aws-credentials-use
    #

    #  Amazon.Runtime.AWSCredentials ProfileLocation: C:\Users\$env:USERNAME\.aws\credentials
    #$myCredential = Get-AWSCredentials -ListProfileDetail -Verbose -OutVariable "Amazon.PowerShell.Common.ProfileInfo"

    # Writes a new (or updates existing) profile with name "myProfileName"
    # in the encrypted SDK store file
    #Set-AWSCredential -AccessKey akey -SecretKey skey -StoreAs myProfileName

    # Checks the encrypted SDK credential store for the profile and then
    # falls back to the shared credentials file in the default location
    Set-AWSCredential -ProfileName "LABAdmin - EU West (Ireland) Profile"

    # Bypasses the encrypted SDK credential store and attempts to load the
    # profile from the ini-format credentials file "mycredentials" in the
    # folder C:\MyCustomPath
    #Set-AWSCredential -ProfileName myProfileName -ProfileLocation C:\MyCustomPath\mycredentials

    # https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html
    #Get-IAMAccessKey -UserName "" -Region "eu-west-1" -AccessKey "" -Credential "" -SecretKey "" -Verbose
    #$newScret = New-SECSecret -Name "poc/MyJreTrustStoreSecret-8U131" -SecretString `"file://mycreds.json`" -Description "My PoC Secret ..." -Region "eu-west-1" -Verbose
    $newSecret = New-SECSecret -Name "poc/MyJreTrustStoreSecret-8U131" -SecretString `"MySecretIs_BOT-SECRET!`" -Description "My PoC Secret ..." -Region "eu-west-1" -Verbose

    Log `"$newSecret.ARN`"
    Log `"$newSecret.Name`"
    Log `"$newSecret.VersionId`"

    #aws "secretsmanager create-secret --name poc/MyJreTrustStoreSecret-8U131 --secret-string file://mycreds.json"
    #{
    #    "SecretARN": "arn:aws:secretsmanager:eu-west-1:739798896944:secret:poc/MyJreTrustStoreSecret-8U131",
    #    "SecretName": "poc/MyJreTrustStoreSecret-8U131",
    #    "SecretVersionId": "MyJreTrustStoreSecret-8U131-initial-poc-release-version"
    #}
	Log "+++ Create-Secret-Store-Pass END"
	
}

################################################################################################
# Get-Secret-Store-Pass
################################################################################################
Function Get-Secret-Store-Pass {
	# https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_retrieve-secret.html
    Log "+++ Get-Secret-Store-Pass BEGIN"
    Import-Module AWSPowerShell
    #Get-AWSPowerShellVersion -ListServiceVersionInfo
    #Get-AWSCredentials -ListProfileDetail -Verbose
    Set-AWSCredential -ProfileName "LeadDev - EU West (Ireland) Profile" #-Region "eu-west-1" 

    $storePassSecret = Get-SECSecret -SecretId "poc/MyJreTrustStoreSecret-8U131"

    Log "ARN=$($storePassSecret.ARN)"
    Log "Name=$($storePassSecret.Name)"
    Log "Description=$($storePassSecret.Description)"

    $storePassSecretValue = Get-SECSecretValue -SecretId "poc/MyJreTrustStoreSecret-8U131"  # -OutVariable $storePassSecret -VersionId "" -VersionStage "" 
    #Write-Output $storePassSecretValue
    Log "ARN=`"$($storePassSecretValue.ARN)`""
    Log "Name=`"$($storePassSecretValue.Name)`""
    Log "VersionId=`"$($storePassSecretValue.VersionId)`""
    Log "storePassSecretValue=$($storePassSecretValue.SecretString)"

    #aws secretsmanager get-secret-value --secret-id poc/MyJreTrustStoreSecret-8U131
    #{
    #    "SecretARN": "arn:aws:secretsmanager:eu-west-1:739798896944:secret:poc/MyJreTrustStoreSecret-8U131",
    #    "SecretName": "poc/MyJreTrustStoreSecret-8U131",
    #    "SecretVersionId": "MyJreTrustStoreSecret-8U131-initial-poc-release-version",
    #    "SecretString": "{\"Store-Pass\":\"MyT0pSecretP@ssw0rd!\"}",
    #    "SecretVersionStages": [
    #        "AWSCURRENT"
    #    ],
    #    "CreatedDate": 1510089380.309
    #}	
	Log "+++ Get-Secret-Store-Pass END"
	
}


################################################################################################
# Get-Secret-Key-Pass
################################################################################################
Function Get-Secret-Key-Pass {
	Log "+++ Get-Secret-Key-Pass BEGIN"
	Import-Module AWSPowerShell
    
	Log "+++ Get-Secret-Key-Pass END"
	
}

################################################################################################
# Remove-Secret
################################################################################################
Function Remove-Secret() {
    Param ([string]$secretId)
	Log "+++ Remove-Secret BEGIN"
	Import-Module AWSPowerShell
    Set-AWSCredential -ProfileName "LeadDev - EU West (Ireland) Profile" #-Region "eu-west-1" 
    $deleteSecretResponse = Remove-SECSecret -SecretId $secretId -RecoveryWindowInDay 7  -Force TRUE
    Log "STATUS : $deleteSecretResponse.HttpStatusCode"

	Log "+++ Remove-Secret END"
	
}


################################################################################################
# Run-All-Automation
################################################################################################
Function Run-All-Automation {
	Log "+++ Run-All-Automation BEGIN"
    TraceVar
	#Clean
	CreateRootTrustStores
	CreateEmptyTrustStore
	CheckEmptyKeyStores
	ModifyTrustStoresPassword
	ImportCert
	#List-CACerts
	#List-Certs
	CheckSystemStores
	CopyStoresToJRE
	Run-JCP
	Log "+++ Run-All-Automation END"
}

################################################################################################
# Trace all variables values
################################################################################################
Function Trace-Var {
	Log "+++ Trace-Var BEGIN"
	Log " USERNAME = $USERNAME "
	Log " HOSTNAME = $HOSTNAME "
	Log " "
	Log " WORK_DIR = $WORK_DIR "
	Log " WORK_DIR_OUT = $WORK_DIR_OUT "
	Log " WORK_DIR_TMP = $WORK_DIR_TMP "
    Log " "
    Log " LogPath = $LogPath "
	Log " LogFile = $LogFile "
	Log " "	
	Log " JRE_VERSION = $JRE_VERSION "
	Log " JRE_HOME = $JRE_HOME "
	Log " JRE_BIN = $JRE_BIN "
	Log " env:Path = $env:Path "
	Log " "
	Log " JDK_SECURITY_FOLDER = $JDK_SECURITY_FOLDER "
	Log " JRE_SECURITY_FOLDER = $JRE_SECURITY_FOLDER "
	Log " SYSTEM_SECURITY_FOLDER = $SYSTEM_SECURITY_FOLDER "
	Log " USR_SECURITY_FOLDER = $USR_SECURITY_FOLDER "
	Log " "
	Log " STORE_TYPE = $STORE_TYPE "
	Log " SYS_STOREPASS = $SYS_STOREPASS "
	Log " SYS_STOREPASS_NEW = $SYS_STOREPASS_NEW "
	Log " "
    Log " TRUSTED_CA=$TRUSTED_CA"
    Log " TRUSTED_SITE_CA=$TRUSTED_SITE_CA"
    Log " TRUSTED_CERT=$TRUSTED_CERT"
    Log " TRUSTED_SITE_CERT=$TRUSTED_CERT"
    Log " CLIENT_AUTH_CERT=$CLIENT_AUTH_CERT"
    Log " "
	Log " SYS_TRUSTED_CA = $SYS_TRUSTED_CA "
	Log " SYS_TRUSTED_SITE_CA = $SYS_TRUSTED_SITE_CA "
	Log " "
	Log " SYS_TRUSTED_CERT = $SYS_TRUSTED_CERT "
	Log " SYS_TRUSTED_SITE_CERT = $SYS_TRUSTED_SITE_CERT "
	Log " SYS_CLIENT_AUTH_CERT = $SYS_CLIENT_AUTH_CERT "	
	Log " "
	Log "+++ Trace-Var END"
		
}

################################################################################################
# Start Code
################################################################################################

#Create log file folder if not found
if(!(Test-Path -Path $LogPath )) {
	New-Item -ItemType directory -Path $LogPath
}

#Start logging
Start-Script

#Display Logo
Display-Logo

#Creates working directory
Log-Sub-Step "Checking if ""tmp & out"" working folders do exist..."
if ((Test-Path -Path $WORK_DIR_OUT) -eq $true) {
	Log "Folder $WORK_DIR_OUT found"
}
else {
	Log "Folder $WORK_DIR_OUT not found. Creating it ..."
	New-Item -path $WORK_DIR_OUT -type directory -ErrorAction SilentlyContinue
	if (!$?) {
		Log "ERROR: failed to create ""$WORK_DIR_OUT"" folder. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
		Terminate-Script "CREATE_FOLDER_ERROR"
	}
	else {
		Log "Folder $WORK_DIR_OUT successfully created!"
	}
}

Log-Sub-Step "Checking if ""tmp & out"" working folders do exist..."
if ((Test-Path -Path $WORK_DIR_TMP) -eq $true) {
	Log "Folder $WORK_DIR_TMP found"
}
else {
	Log "Folder $WORK_DIR_TMP not found. Creating it ..."
	New-Item -path $WORK_DIR_TMP -type directory -ErrorAction SilentlyContinue
	if (!$?) {
		Log "ERROR: failed to create ""$WORK_DIR_TMP"" folder. Error description: $($error[0].ToString()) $($error[0].InvocationInfo.PositionMessage)"
		Terminate-Script "CREATE_FOLDER_ERROR"
	}
	else {
		Log "Folder $WORK_DIR_TMP successfully created!"
	}
}

	
#*********************************************************************
# Check OS Information
#*********************************************************************
Log-Step "Check OS"
$OS = Get-WmiObject -class Win32_OperatingSystem
Log "OS detected: $($OS.Caption) $($OS.OSArchitecture)"
#Check if OS is Windows 10
if ($OS.Version -match "10.0.15063") {
	Log "This OS is supported"
}
#Check if OS is Windows 7 SP1
elseif ($OS.Version -match "6.1.7601") {
		Log "This OS is supported"
	 }
	 else {
	 	Log "This OS is not supported."
	 	Terminate-Script "BAD_OS"
	 }

#*********************************************************************
# Check arguments
#*********************************************************************
Log-Step "Check arguments"

if ($clean){Log """-clean"" argument found"}
elseif ($backup) {Log """-backup"" argument found"}
elseif ($TraceVar) {Log """-TraceVar"" argument found"}
elseif ($createRootTrustStores) {Log """-createRootTrustStores"" argument found"}
elseif ($createEmptyTrustStore) {Log """-createEmptyTrustStore"" argument found"}
elseif ($checkEmptyKeyStores) {Log """-checkEmptyKeyStores"" argument found"}
elseif ($modifyTrustStoresPassword) {Log """-modifyTrustStoresPassword"" argument found"}
elseif ($importCert) {Log """-importCert"" argument found"}
elseif ($listCACerts) {Log """-listCACerts"" argument found"}
elseif ($listCerts) {Log """-listCerts"" argument found"}
elseif ($checkSystemStores) {Log """-checkSystemStores"" argument found"}
elseif ($copyStoresToJRE) {Log """-copyStoresToJRE"" argument found"}
elseif ($runJCP) {Log """-runJCP"" argument found"}
elseif ($getSecretKeyPass) {Log """-getSecretKeyPass"" argument found"}
elseif ($getSecretStorePass) {Log """-getSecretStorePass"" argument found"}
elseif ($createSecretStorePass) {Log """-createSecretStorePass"" argument found"}
else {
	Log "Missing argument."
    Log "USAGE: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File ""%~dp0automation_run_as_admin.ps1"" -RunAllAutomation"
	Terminate-Script "MISSING_ARG"
}

#*********************************************************************
# Check the user has read the README to ensure a safe backup ...
#*********************************************************************
# https://blogs.technet.microsoft.com/heyscriptingguy/2012/09/07/powertip-use-powershell-to-obtain-user-input/

# "Have you read carefully the README file ?[Y/N]: \n"
$readCheck = Read-host "Have you read carefully the README file ?[Y/N]: \n"

if ($readCheck -eq "y" -OR $readCheck -eq "Yes") {

    #*********************************************************************
    # Back-Up
    #*********************************************************************
    if ($backup) {
        Back-Up
    }

    #*********************************************************************
    # TraceVar
    #*********************************************************************
    if ($traceVar) {
        Trace-Var
    }

    #*********************************************************************
    # Clean
    #*********************************************************************
    if ($clean) {
        Clean
    }

    #*********************************************************************
    # CreateRootTrustStores
    #*********************************************************************
    if ($createRootTrustStores) {
        Create-Root-Trust-Stores
    }

    #*********************************************************************
    # CreateEmptyTrustStore
    #*********************************************************************
    if ($createEmptyTrustStore) {
        Create-Empty-Trust-Store
    }

    #*********************************************************************
    # CheckEmptyKeyStores
    #*********************************************************************
    if ($checkEmptyKeyStores) {
        Check-Empty-Key-Stores
    }

    #*********************************************************************
    # ModifyTrustStoresPassword
    #*********************************************************************
    if ($modifyTrustStoresPassword) {
        Modify-Trust-Stores-Password
    }

    #*********************************************************************
    # ImportCert
    #*********************************************************************
    if ($importCert) {
        Import-Cert
    }

    #*********************************************************************
    # ListCACerts
    #*********************************************************************
    if ($listCACerts) {
        List-CACerts
    }

    #*********************************************************************
    # ListCerts
    #*********************************************************************
    if ($ListCerts) {
        List-Certs
    }

    #*********************************************************************
    # CheckSystemStores
    #*********************************************************************
    if ($checkSystemStores) {
        Check-System-Stores
    }

    #*********************************************************************
    # CopyStoresToJRE
    #*********************************************************************
    if ($copyStoresToJRE) {
        Copy-Stores-To-JRE
    }

    #*********************************************************************
    # Run-JCP
    #*********************************************************************
    if ($runJCP) {
        Run-JCP
    }

    #*********************************************************************
    # Get-Secret-Key-Pass
    #*********************************************************************
    if ($getSecretKeyPass) {
        Get-Secret-Key-Pass
    }

    #*********************************************************************
    # Get-Secret-Store-Pass
    #*********************************************************************
    if ($getSecretStorePass) {
        Get-Secret-Store-Pass
    }

    #*********************************************************************
    # Create-Secret-Store-Pass
    #*********************************************************************
    if ($createSecretStorePass) {
        Create-Secret-Store-Pass
    }

} else {
    Log "You should read carefully the README file ... "
    Log "This is the end !"
    Terminate-Script "README_NOT_READ"
}

#*********************************************************************
# End of script
#*********************************************************************
Terminate-Script "OK"


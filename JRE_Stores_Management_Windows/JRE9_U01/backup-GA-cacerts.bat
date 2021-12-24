set JRE_VERSION=jre-9.0.1
set JRE_HOME="C:\Program Files\Java\"%JRE_VERSION%
set JRE_SECURITY_FOLDER=%JRE_HOME%\lib\security

set SYS_TRUSTED_CA=%JRE_SECURITY_FOLDER%"\cacerts"
set BACKUP_NAME=cacerts-GA-backup.original

copy %SYS_TRUSTED_CA% 			%JRE_SECURITY_FOLDER%\%BACKUP_NAME%
copy %SYS_TRUSTED_CA%			..\%JRE_VERSION%\GA\lib\security\cacerts.GA
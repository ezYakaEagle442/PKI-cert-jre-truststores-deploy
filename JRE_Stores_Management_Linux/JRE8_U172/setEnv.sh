#!/bin/bash

set -x
### Declare variables ###
# http://www.epons.org/shell-bash-variables.php
# https://unix.stackexchange.com/questions/130985/if-processes-inherit-the-parents-environment-why-do-we-need-export
env -i
set -a

mkdir ./tmp
mkdir ./out

USERNAME=`whoami`
HOSTNAME=`hostname`

#WORK_DIR="/home/${USERNAME}"
WORK_DIR="."
LOG_FILE="${WORK_DIR}/${0}.log"

JRE_VERSION=jre1.8.0_172
# On Azure : /usr/lib/jvm/zulu-11-azure-jre_11.33.15-11.0.4-linux_musl_x64
JRE_HOME=/usr/java/jdk1.8.0_172-amd64/
JRE_BIN="${JRE_HOME}/bin"
#PATH="/usr/bin;${JRE_BIN};$PATH"

#JDK_SECURITY_FOLDER=N/A ? it is used in copyStoresToJRE ...
JRE_SECURITY_FOLDER=/etc/pki/ca-trust/extracted/java
SYSTEM_SECURITY_FOLDER=/etc/.java/deployment/security
#USR_SECURITY_FOLDER="/home/${USERNAME}/.java/deployment/security"

STORE_TYPE=JKS
SYS_STOREPASS=changeit
# Modify SYS_STOREPASS_NEW value to the content of file store-pass.txt
SYS_STOREPASS_NEW=KEY_KiP@ss131--

TRUSTED_CA=cacerts
TRUSTED_SITE_CA=jssecacerts
TRUSTED_CERT=trusted.certs
TRUSTED_SITE_CERT=trusted.jssecerts
CLIENT_AUTH_CERT=trusted.clientcerts

SYS_TRUSTED_CA="./out/${TRUSTED_CA}"
SYS_TRUSTED_SITE_CA="./out/${TRUSTED_SITE_CA}"

SYS_TRUSTED_CERT="./out/${TRUSTED_CERT}"
SYS_TRUSTED_SITE_CERT="./out/${TRUSTED_SITE_CERT}"
SYS_CLIENT_AUTH_CERT="./out/${CLIENT_AUTH_CERT}"

#USR_TRUSTED_CA="${USR_SECURITY_FOLDER}/trusted.cacerts"
#USR_TRUSTED_SITE_CA="${USR_SECURITY_FOLDER}/trusted.jssecacerts"

#USR_TRUSTED_CERTIFICATES="${USR_SECURITY_FOLDER}/${TRUSTED_CERT}"
#USR_TRUSTED_SITE_CERTIFICATES="${USR_SECURITY_FOLDER}/${TRUSTED_SITE_CERT}"

### Log Function ###
log() {
    echo "`date +"%b %e %H:%M:%S"` JRE StroreManagement automation[$$]:" $* | tee -a $LOG_FILE    
}

log " USERNAME = ${USERNAME} "
log " HOSTNAME = ${HOSTNAME} "

log " WORK_DIR = ${WORK_DIR} "
log " LOG_FILE = ${LOG_FILE} "

log " JRE_SECURITY_FOLDER = ${JRE_SECURITY_FOLDER} "
log " #SYSTEM_SECURITY_FOLDER = ${SYSTEM_SECURITY_FOLDER} "
log " USR_SECURITY_FOLDER = ${USR_SECURITY_FOLDER} "


log " JRE_VERSION = ${JRE_VERSION} "
log " JRE_HOME = ${JRE_HOME} "
log " JRE_BIN = ${JRE_BIN} "
log " $PATH = ${PATH} "

log " #JDK_SECURITY_FOLDER = ${JDK_SECURITY_FOLDER} "
log " JRE_SECURITY_FOLDER = ${JRE_SECURITY_FOLDER} "
log " SYSTEM_SECURITY_FOLDER = ${SYSTEM_SECURITY_FOLDER} "
log " #USR_SECURITY_FOLDER = ${USR_SECURITY_FOLDER} "

log " STORE_TYPE = ${STORE_TYPE} "
log " SYS_STOREPASS = ${SYS_STOREPASS} "
log " SYS_STOREPASS_NEW = ${SYS_STOREPASS_NEW} "

log " SYS_TRUSTED_CA = ${SYS_TRUSTED_CA} "
log " SYS_TRUSTED_SITE_CA = ${SYS_TRUSTED_SITE_CA} "

log " SYS_TRUSTED_CERT = ${SYS_TRUSTED_CERT} "
log " SYS_TRUSTED_SITE_CERT = ${SYS_TRUSTED_SITE_CERT} "
log " SYS_CLIENT_AUTH_CERT = ${SYS_CLIENT_AUTH_CERT} "

#set +x
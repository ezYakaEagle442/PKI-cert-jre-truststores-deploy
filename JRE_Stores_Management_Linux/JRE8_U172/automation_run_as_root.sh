#!/bin/bash

echo "Have you read carefully the README file ?[Y/N]: \n"
read READ_CHECK
echo "\n"

bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log Automation START
	
	bash clean.sh
	bash createRootTrustStores.sh
	bash createEmptyTrustStore.sh
	bash checkEmptyKeyStores.sh
	bash modifyTrustStoresPassword.sh
	bash importCert.sh
	# bash list-CACerts.sh
	# bash list-Certs.sh
	bash checkSystemStores.sh
	bash copyStoresToJRE.sh
	bash run-JCP.sh 
	
	log Automation END
	
else
	echo "You should read carefully the README file ... \n"
fi

### Log Function ###
log() {
    echo "`date +"%b %e %H:%M:%S"` JRE StroreManagement automation[$$]:" $* | tee -a $LOG_FILE
}

# exit $?
# !/bin/bash
set -e
echo "START"

echo "Install JAVA"

sudo mkdir /sapcc

cd /sapcc

sudo wget "https://tools.eu1.hana.ondemand.com/additional/sapjvm-8.1.063-linux-x64.rpm" --header "Cookie: eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt"

sudo rpm -i sapjvm-8.1.063-linux-x64.rpm

echo "Install SAP Cloud Connector"

sudo wget "https://tools.eu1.hana.ondemand.com/additional/sapcc-2.12.4-linux-x64.zip" --header "Cookie: eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt"

sudo zypper --gpg-auto-import-keys --non-interactive --no-refresh install unzip

sudo unzip sapcc-2.12.4-linux-x64.zip

sudo rpm -i com.sap.scc-ui-2.12.4-4.x86_64.rpm

sleep 10

service scc_daemon status

echo "ALL DONE"

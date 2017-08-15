#!/bin/bash

if [ "`systemctl is-active wildfly`" == "active" ]; then
    echo "wildfly is actived"
else
	sudo yum install -y wget
	sudo yum install -y zip unzip
	sudo yum install -y net-tools
	sudo yum -y install java-1.8.0-openjdk.i686	

	if [ ! -f /resources/wildfly-10.1.0.Final.tar.gz ]; then
		echo "Download Wildfly"
		sudo wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz -P /resources
	fi


	echo "Install Wildfly"
	sudo tar xvfvz /resources/wildfly-10.1.0.Final.tar.gz -C /opt
	sudo ln -s /opt/wildfly-10.1.0.Final/ /opt/wildfly

	sudo cp /resources/wildfly/standalone*.xml /opt/wildfly/standalone/configuration/
	sudo cp /resources/wildfly/standalone.conf /opt/wildfly/bin

	sudo mkdir -p /var/log/wildfly


	echo "Create password vault"
	sudo mkdir -p /opt/wildfly/vault
	sudo keytool -genseckey -alias vault -keystore /opt/wildfly/vault/vault.keystore -storetype jceks -keyalg AES -keysize 128 -storepass vault22 -keypass vault22


	echo "Register wildfly service"
	sudo ln -s /opt/wildfly/docs/contrib/scripts/init.d/wildfly-init-redhat.sh /etc/init.d/wildfly
	sudo cp /resources/wildfly/wildfly.conf /etc/default/wildfly.conf

	sudo adduser wildfly
	sudo chown -R wildfly:wildfly /opt/wildfly*
	sudo chmod -R 755 /opt/wildfly*

	sudo chown -R wildfly:wildfly /var/log/wildfly
	sudo chmod -R 755 /var/log/wildfly

	sudo chmod +x /etc/init.d/wildfly*


	sudo sh /opt/wildfly/bin/add-user.sh -r ManagementRealm --user admin --password password1! --role admin

	sudo chkconfig --add wildfly
#	sudo systemctl start wildfly
#	sudo chkconfig wildfly on
fi

if [ -f /opt/wildfly/standalone/deployments/jbpm-console.war.deployed ]; then
    echo "jbpm is actived"
else

	if [ ! -f /resources/kie-wb-7.1.0.Final-wildfly10.war ]; then
		echo "Download jbpm-console"
		sudo wget https://repository.jboss.org/nexus/content/groups/public-jboss/org/kie/kie-wb/7.1.0.Final/kie-wb-7.1.0.Final-wildfly10.war -P /resources
	fi


	if [ ! -f /resources/jbpm-wb-case-mgmt-showcase-7.1.0.Final-wildfly10.war ]; then
		echo "Download jbpm-casemgt"
		sudo wget https://repository.jboss.org/nexus/content/groups/public-jboss/org/jbpm/jbpm-wb-case-mgmt-showcase/7.1.0.Final/jbpm-wb-case-mgmt-showcase-7.1.0.Final-wildfly10.war -P /resources
	fi
	if [ ! -f /resources/kie-server-7.1.0.Final-ee7.war ]; then
		echo "Download kie-server"
		sudo wget http://repository.jboss.org/nexus/content/groups/public-jboss/org/kie/server/kie-server/7.1.0.Final/kie-server-7.1.0.Final-ee7.war -P /resources
	fi

	sudo cp /resources/kie-wb-7.1.0.Final-wildfly10.war /opt/wildfly/standalone/deployments/jbpm-console.war
	sudo cp /resources/jbpm-wb-case-mgmt-showcase-7.1.0.Final-wildfly10.war /opt/wildfly/standalone/deployments/jbpm-casemgmt.war
	sudo cp /resources/kie-server-7.1.0.Final-ee7.war /opt/wildfly/standalone/deployments/kie-server.war

	sudo cp /resources/jbpm/auth/* /opt/wildfly/standalone/configuration/
	sudo cp /resources/jbpm/standalone-full.xml /opt/wildfly/standalone/configuration/

fi


sudo systemctl start wildfly
sudo chkconfig wildfly on
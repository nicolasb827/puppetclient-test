#!/bin/bash

MY_ENV=$1
MY_CERT=$2

if [ "" == "$MY_ENV" ]; then
	MY_ENV="production"

fi

if [ "" == "$MY_CERT" ]; then
	MY_CERT=$(hostname --fqdn)
fi

echo "[client] Starting using"
echo "[client] - env : $MY_ENV"
echo "[client] - cert: $MY_CERT"

echo "[client] creating puppet.conf"
cat - > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
certname = $MY_CERT
server = puppetmaster
masterport = 8140
environment = $MY_ENV
runinterval = 1h
basemodulepath = /etc/puppetlabs/code/modules
EOF

if [ -f /master.conf ]; then
	echo "[client] appending (sys)master.conf to puppet.conf"
	cat /master.conf >> /etc/puppetlabs/puppet/puppet.conf
fi

for CONF in puppetdb.conf hiera.yaml; do
	if [ -f /$CONF ]; then
		echo "[client] copy $CONF to /etc/puppetlabs/puppet/"
		cp /$CONF /etc/puppetlabs/puppet/
	fi
done

if [ ! -d /etc/puppetlabs/code/environments/$MY_ENV ]; then
	echo "[client] creating directory /etc/puppetlabs/code/environments/$MY_ENV"
	mkdir -p /etc/puppetlabs/code/environments/$MY_ENV
	chown -R puppet:puppet /etc/puppetlabs/code/environments
fi

echo "[client] creating helper script as /usr/local/bin/do_puppet.sh"
cat - > /usr/local/bin/do_puppet.sh <<EOF
#! /bin/bash

puppet agent --test -w 10 \$@
ret=\$?
case \$ret in
	0)
		echo "The run succeeded with no changes or failures; the system was already in the desired state."
		;;
	1)
		echo "The run failed, or wasn't attempted due to another run already in progress."
		;;
	2)
		echo "The run succeeded, and some resources were changed."
		;;
	4)
		echo "The run succeeded, and some resources failed."
		;;
	6)
		echo "The run succeeded, and included both changes and failures."
		;;
esac
exit \$ret
EOF

chmod a+x /usr/local/bin/do_puppet.sh

echo "[client] cleaning any certificates"
find /etc/puppetlabs/puppet/ssl/ -type f -exec rm -f {} \;

echo "[client] ready !"
while :; do
  sleep 300
done

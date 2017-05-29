#!/bin/bash

function initiate_instance {
  echo "Starting node initiation..."

  # Fire up regular Puppet master to generate
  # certificates and folder structure.
  # This shouldn't take more than five seconds.
  echo "Starting Puppet to generate certificates..."
  timeout 5 puppet agent  --no-daemonize

  echo "Node initation completed..."
}

cat - > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
certname = $(hostname)
server = puppetmaster
masterport = 8149
environment = production
runinterval = 1h
basemodulepath = /etc/puppetlabs/code/modules
EOF

if [ -f /master.conf ]; then
	cat /master.conf >> /etc/puppetlabs/puppet/puppet.conf
fi

for CONF in puppetdb.conf hiera.yaml; do
	if [ -f /$CONF ]; then
		cp /$CONF /etc/puppetlabs/puppet/
	fi
done

if [ ! -d /etc/puppetlabs/code/environments/production ]; then
	mkdir -p /etc/puppetlabs/code/environments/production
	chown puppet:puppet /etc/puppetlabs/code/environments
fi

bash

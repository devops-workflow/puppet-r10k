#!/bin/bash
set -u
set -e

hiera=$(puppet config print hiera_config)
confdir="$(puppet config print confdir)/environments"

script_dir=$(dirname $0)

puppet module install zack/r10k
puppet apply "${script_dir}/configure_r10k.pp"
r10k deploy environment -pv

if [ -f "${confdir}/production/hiera.yaml" ] && [ ! -f "$hiera" ]
then
  echo "Copying ${confdir}/production/hiera.yaml to $hiera"
  /bin/cp -f "${confdir}/production/hiera.yaml" "$hiera"
elif [ -f "${confdir}/production/hiera.yaml" ] && [ -f "$hiera" ]
then
  diff "${confdir}/production/hiera.yaml" "$hiera" > /dev/null
  if [ $? -ne 0 ]
  then
    echo "$hiera has changed.  Copying from production and restarting the master." 
    /bin/cp -f "${confdir}/production/hiera.yaml" "$hiera"
    config_dir=$(puppet config print confdir)
    if [ "$config_dir" == "/etc/puppet" ]
    then
      service httpd restart
    else
      service pe-puppetmaster restart
    fi
  fi
fi
if [ -f "$hiera" ]
then
  echo "Updating datadir in $hiera to point to $confdir"
  sed -i "s;:datadir.*;:datadir: \"${confdir}/%{::environment}/hieradata\";" "$hiera"
fi

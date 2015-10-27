#!/bin/bash
set -u
set -e

hiera=$(puppet config print hiera_config)
environments="$(puppet config print confdir)/environments"
script_dir=$(dirname $0)

puppet module install zack/r10k
puppet apply "${script_dir}/configure_r10k.pp"
r10k deploy environment -pv

if [ -f "${environments}/production/hiera.yaml" ] && [ ! -f "$hiera" ]
then
  echo "Copying ${environments}/production/hiera.yaml to $hiera"
  /bin/cp -f "${environments}/production/hiera.yaml" "$hiera"
elif [ -f "${environments}/production/hiera.yaml" ] && [ -f "$hiera" ]
then
  diff "${environments}/production/hiera.yaml" "$hiera" > /dev/null
  if [ $? -ne 0 ]
  then
    echo "$hiera has changed.  Copying from production and restarting the master." 
    /bin/cp -f "${environments}/production/hiera.yaml" "$hiera"
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
  echo "Updating datadir in $hiera to point to $environments"
  sed -i "s;:datadir.*;:datadir: \"${environments}/%{::environment}/hieradata\";" "$hiera"
fi

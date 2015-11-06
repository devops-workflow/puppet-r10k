#!/bin/bash
set -u
set -e

hiera=$(puppet config print hiera_config)
confdir="$(puppet config print confdir)/environments"
environ="$(puppet config print environment)"

script_dir=$(dirname $0)

echo "Installing Puppet Module: zack/r10k"
puppet module install zack/r10k

echo "Configuring R10K from $script_dir:"
puppet apply "${script_dir}/configure_r10k.pp"

echo "Deplying environment from R10k:"
r10k deploy environment -pv

if [ -f "${confdir}/${environ}/hiera.yaml" ] && [ ! -f "$hiera" ]
then
  echo "Copying ${confdir}/${environ}/hiera.yaml to $hiera"
  /bin/cp -f "${confdir}/${environ}/hiera.yaml" "$hiera"
elif [ -f "${confdir}/${environ}/hiera.yaml" ] && [ -f "$hiera" ]
then
  diff "${confdir}/${environ}/hiera.yaml" "$hiera" > /dev/null
  if [ $? -ne 0 ]
  then
    echo "$hiera has changed. Copying from ${environ} and restarting master."
    /bin/cp -f "${confdir}/${environ}/hiera.yaml" "$hiera"

    # Probably a better way to distinguish P-E and P-OS
    config_dir=$(puppet config print confdir)
    if [ "$config_dir" == "/etc/puppet" ]
    then
      echo "Restarting httpd"
      service httpd restart
    else
      echo "Restarting pe-puppetmaster"
      service pe-puppetmaster restart
    fi
  fi
fi
if [ -f "$hiera" ]
then
  echo "Updating datadir in $hiera to point to $confdir"
  sed -i "s;:datadir.*;:datadir: \"${confdir}/${environ}/hieradata\";" "$hiera"
fi

#!/bin/bash
puppet module install zack/r10k
puppet apply $(dirname $0)/configure_r10k.pp
# puppet apply configure_directory_environments.pp
r10k deploy environment -pv
# Copy hiera.yaml from production environment to confdir
hiera=$(puppet config print | grep hiera_config | cut -d= -f2)
environments=$(puppet config print | grep environmentpath | cut -d= -f2 | cut -c2-)
/bin/cp -f ${environments}/production/hiera.yaml ${hiera}
sed -i "s;:datadir.*;:datadir: \"${environments}/%{::environment}/hieradata\";" ${hiera}

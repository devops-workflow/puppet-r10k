#!/bin/bash
puppet module install zack/r10k
puppet apply $(dirname $0)/configure_r10k.pp
# puppet apply configure_directory_environments.pp
r10k deploy environment -pv
# Copy hiera.yaml from production environment to confdir
hiera=$(puppet config print hiera_config)
environments=$(puppet config print environmentpath)
if [ -f "${environments}/production/hiera.yaml" ]
then
  /bin/cp -f ${environments}/production/hiera.yaml ${hiera}
fi
if [ -f "${hiera}" ]
then
  sed -i "s;:datadir.*;:datadir: \"${environments}/%{::environment}/hieradata\";" ${hiera}
fi

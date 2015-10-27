#!/bin/bash
puppet module install zack/r10k
puppet apply $(dirname $0)/configure_r10k.pp
r10k deploy environment -pv
# Copy hiera.yaml from production environment to confdir
hiera=$(puppet config print hiera_config)
environments=$(puppet config print environmentpath)
current_environment=$(git show-branch --current | sed "s/^\[\([a-zA-Z0-9]*\)\].*/\1/")
if [ -f "${environments}/${current_branch}/hiera.yaml" ]
then
  /bin/cp -f "${environments}/${current_branch}/hiera.yaml" "$hiera"
fi
if [ -f "$hiera" ]
then
  sed -i "s;:datadir.*;:datadir: \"${environments}/%{::environment}/hieradata\";" "$hiera"
fi

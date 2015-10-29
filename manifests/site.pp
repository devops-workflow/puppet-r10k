node pe-381-master {
  class { '::profiles::base': }
  package { 'jq': ensure => latest, }

  # ERROR: Error installing netconf: net-ssh requires Ruby version >= 2.0
  package { 'netconf':
    ensure   => present,
    provider => 'pe_gem',
  }
}

node pe-381-agent-jenkins {
  class { '::profiles::base': }
  class { '::profiles::jenkins::master': }
}

node pe-381-agent-app {
  class { '::profiles::base': }
  #class { '::profiles::haproxy': }
  #class { '::profiles::kafka': }
  # No module yet - class { '::profiles::flume': }
  class { '::profiles::zookeeper': }

}

node /storage/ {
  # Ceph
  # GlusterFS
}

# Vagrant environment
node 'puppet-master' {
  $location = 'vagrant'
  hiera_include('classes')
}

node 'jenkins-master' {
  class { '::profiles::base': }
  class { '::profiles::jenkins::master': }
}

node 'foreman' {
  $location = 'vagrant'
  hiera_include('classes')
}

node 'ns-master' {
  $location = 'vagrant'
  hiera_include('classes')
}

node 'smtp' {
  class { '::profiles::base': }
  class { '::profiles::smtp': }
}

node 'cobbler' {
  $location = 'vagrant'
  hiera_include('classes')
}

node 'cobbler-ubuntu' {
  $location = 'vagrant'
  hiera_include('classes')
}

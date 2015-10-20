node pe-381-master {
  class { '::profiles::base': }
  package { 'jq': ensure => latest, }
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

node 'puppet-master' {
  class { '::profiles::base': }
  class { '::profiles::puppet::master': }
}

node jenkins-master {
  class { '::profiles::base': }
  class { '::profiles::jenkins::master': }
}

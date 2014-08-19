# == Class keepalived::config
#
class keepalived::config {
  File {
    ensure  => present,
    require => Class['::keepalived::install'],
    owner   => $::keepalived::config_owner,
    group   => $::keepalived::config_group,
  }

  if $::keepalived::service_manage == true {
    File {
      notify  => Service[$::keepalived::service_name],
    }
  }

  file { $::keepalived::config_dir:
    ensure => directory,
    group  => $::keepalived::config_group,
    mode   => $::keepalived::config_dir_mode,
    owner  => $::keepalived::config_owner,
  }

  file { "${::keepalived::config_dir}/conf.d":
    ensure => directory,
    group  => $::keepalived::config_group,
    mode   => $::keepalived::config_dir_mode,
    owner  => $::keepalived::config_owner,
    require => Class['::keepalived::install']
  }

  concat { "${::keepalived::config_dir}/keepalived.conf":
    owner => $::keepalived::config_owner,
    group => $::keepalived::config_group,
    mode  => $::keepalived::config_file_mode,
  }

  concat::fragment { 'keepalived.conf_header':
    target  => "${::keepalived::config_dir}/keepalived.conf",
    content => "# Managed by Puppet\n",
    order   => 001,
  }

  concat::fragment { 'keepalived.include':
    target  => "${::keepalived::config_dir}/keepalived.conf",
    content => "include /etc/keepalived/conf.d/*.conf\n",
    order   => 002,
  }

  concat::fragment { 'keepalived.conf_footer':
    target  => "${::keepalived::config_dir}/keepalived.conf",
    content => "\n",
    order   => 999,
  }

create_resources(keepalived::vrrp::instance, hiera_hash("keepalived-instances", {}))
}


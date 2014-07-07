


include java7

class { 'elasticsearch':
  package_url => "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb",
  config      => {
    'node' => {
      'name' => $hostname
    },
    'http' => {
      'max_content_length'=> '500mb'
    },
    'network' => {
      'publish_host'  => $ipaddress_eth0
    },
    'cluster' => {
      'name' => "Packer-cluster",
    },
    'marvel' => {
      'agent' => {
        'enabled' => "true"
      }
    },
    'cloud' => {
      'aws' => {
        'access_key' => "fill in",
        'secret_key' => "fill in",
      },

    },
    'discovery' => {
      'type' => "ec2"
    },
  },
  require => Class['java7']
}


#this can be done on a single call
elasticsearch::plugin{'mobz/elasticsearch-head':
  module_dir  => 'head',
}

elasticsearch::plugin { 'elasticsearch/marvel/latest':
  module_dir  => 'marvel',
}

elasticsearch::plugin { 'lukas-vlcek/bigdesk':
  module_dir  => 'bigdesk',
}
elasticsearch::plugin { 'elasticsearch/elasticsearch-cloud-aws/2.0.0.RC1':
  module_dir  => 'bigdesk',
}

class {'nginx': }
nginx::resource::upstream { 'elasticsearch':
  members => [
    'localhost:9200',
  ],
}
nginx::resource::vhost { 'escluster-prod.chicago.com':
  proxy => 'http://elasticsearch',
  listen_port => 80,
  auth_basic => "Restricted",
  auth_basic_user_file => "/etc/nginx/.htpasswd"
}
htpasswd { 'elasticsearch':
  cryptpasswd => "",
  target      => '/etc/nginx/.htpasswd',
  require     => Class['nginx']
}
file { "/etc/nginx/.htpasswd":
  owner => "nginx",
  group => "nginx",
  require => Htpasswd['elasticsearch']
}



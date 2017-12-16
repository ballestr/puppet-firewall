## file-based firewalld configuration on a RHEL7/Centos7 host
## GPLv3 https://github.com/ballestr/puppet-firewall
## Sergio.Ballestrero@gmail.com, 2017-01
##
## Usage: 
## include firewall::firewalld

class firewall::firewalld::params(){
    $SOURCE="puppet:///files_site/firewalld"
}
class firewall::firewalld() {
    include firewall::firewalld::base
    firewall::firewalld::zone{["public","lan"]:}
    ## fixed set of zones
}
## Packages, service and base configs
class firewall::firewalld::base() inherits firewall::firewalld::params {
    package{"iptables-services":ensure=>absent} ->
    package{"firewalld":ensure=>present} ->
    service{"firewalld":enable=>true,ensure=>running}
    file {
        "/etc/firewalld/firewalld.conf":
            ensure => file,
            source => "$SOURCE/firewalld.conf",
            mode => "u=rw,go=r", owner => root, group => root,
            notify=>Service["firewalld"];
    }
    file {
        "/etc/firewalld/direct.xml":
            ensure => file,
            source => ["$SOURCE/direct@${hostname}.xml","$SOURCE/direct.xml"],
            mode => "u=rw,go=r", owner => root, group => root,
            notify=>Service["firewalld"];
    }
    file {
        "/etc/firewalld/services":
            ensure => directory,
            source => "$SOURCE/services",
            recurse=> remote, ignore=>".*",
            mode => "u=rw,go=r,u+X,go+X", owner => root, group => root,
            notify=>Service["firewalld"];
    }
    file {
        "/etc/firewalld/ipsets":
            ensure => directory,
            source => "$SOURCE/ipsets",
            recurse=> remote, ignore=>".*",
            mode => "u=rw,go=r,u+X,go+X", owner => root, group => root,
            notify=>Service["firewalld"];
    }
}
## zone configs
define firewall::firewalld::zone() inherits firewall::firewalld::params {
    file {
        "/etc/firewalld/zones/${name}.xml":
            ensure => file,
            source => ["$SOURCE/zones/${name}@${hostname}.xml","$SOURCE/zones/${name}.xml"]
            mode => "u=rw,go=r", owner => root, group => root,
            notify=>Service["firewalld"];
    }
}

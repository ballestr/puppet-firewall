## file-based iptables configuration on a RHEL6/ScientificLinux6 host
## GPLv3 https://github.com/ballestr/puppet-firewall
## Sergio.Ballestrero@gmail.com, 2017-01
##
## Usage:
## include firewall::iptables::file

class firewall::iptables::params() {
	$SOURCE="puppet:///files_site/iptables"
}
class firewall::iptables::file() inherits firewall::iptables::params {
	include firewall::iptables::base
    file {
        "/etc/sysconfig/iptables":
            source => ["$SOURCE/iptables@${hostname}","$SOURCE/iptables@default"],
            mode => 600, owner => root, group => root,
            notify=>Service["iptables"];
    }
}
## Packages and service
class firewall::iptables::base() {
    service{"iptables":enable=>true,ensure=>running}
}

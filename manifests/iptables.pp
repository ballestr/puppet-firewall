## file-based iptables configuration on a RHEL6/ScientificLinux6 host
## GPLv3 https://github.com/ballestr/puppet-firewall
## Sergio.Ballestrero@gmail.com, 2017-01
##
## Usage:
## include firewall::iptables::file

class firewall::iptables::file() inherits firewall::iptables::params {
    service{"iptables":enable=>true,ensure=>running}
    file {
        "/etc/sysconfig/iptables":
            source => ["$CFGSOURCE/iptables@${hostname}","$CFGSOURCE/iptables@default"],
            mode => 600, owner => root, group => root,
            notify=>Service["iptables"];
    }
}

### Import iptables classes from ATLAS TDAQ
### with legacy baggage in need of cleanup, e.g. extdata

## turn iptables on or off based on extdata
class firewall::iptables::flex {
    $type=extlookup("firewall","off")
    case $type {
	    "on" : { include firewall::iptables }
	    "off" : { include firewall::iptables::off }
    }
}

## just turn it off and make sure it stays
class firewall::iptables::off {
    service {
        "iptables": ensure=>stopped, enable=>false;
    }
    file {
        "/etc/cron.daily/newiptables_check": ensure=>absent;
    }
}

### use a host-specific template, with general-use insertions
class firewall::iptables inherits firewall::iptables::params {
    include firewall::iptables::base
    $t="$fwdir/${hostname}.erb"
    file {
        "/etc/sysconfig/iptables.source":
            ensure=>present,
            content => template($t),
            mode=>640,owner=>root,group=>root;
    }
}

### use a extdata-specified template, with general-use insertions
class firewall::iptables::extdata ($default="off",$module=undef) inherits firewall::iptables::params {
    $type=hiera("firewall/type",$default)
    ## helper for extdata migration to hiera
    $type_e=extlookup("firewall",$default) ## legacy extdata
    if ( $type_e != $type ) {
        fail("firewall::iptables::extdata : hiera='$type' does not match extdata='$type_e'") 
    }
    if ($type == "off") {
        include firewall::iptables::off
    } else {
        include firewall::iptables::base
        if ( $module ) {
            $fwdir="$modulespath/$module/templates/"
        }
        $t="${fwdir}ed-${type}.erb"
        file {
            "/etc/sysconfig/iptables.source":
                ensure=>present,
                content => template($t),
                mode=>640,owner=>root,group=>root;
        }
    }
}

class firewall::iptables::params() {
    $CFGSOURCE=hiera("firewall/iptables/cfgsource","puppet:///files_site/iptables")
    $modulespath="${settings::confdir}/modules"
    $fwdir="$modulespath/site_${SITE}/files/firewall/"
}

class firewall::iptables::base {
    file {
        "/etc/sysconfig/iptables":ensure=>present;
        "/usr/local/sbin/newiptables":ensure=>absent; ## old file cleanup
        "/var/sbin/newiptables":
            ensure=>present,
            source=>"puppet:///modules/firewall/newiptables",
            mode=>750,owner=>root,group=>root,
            require=>File["/var/sbin"];
        "/etc/cron.daily/newiptables_check":
            ensure=>present,
            source=>"puppet:///modules/firewall/newiptables_check",
            mode=>750,owner=>root,group=>root;
    }
    exec { 
        "newiptables":
            command=>"/var/sbin/newiptables >/dev/null",
            require => File["/etc/sysconfig/iptables.source","/var/sbin/newiptables"],
            subscribe => File["/etc/sysconfig/iptables.source"],
            refreshonly => true;
    }
    service {
        "iptables": ensure=>running, enable=>true,
            require=>File["/etc/sysconfig/iptables"];
    }
}


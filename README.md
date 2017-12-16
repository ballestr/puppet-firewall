# puppet-firewall
File-based configuration for firewalld and iptables.

## Tested compatibilty
 * RHEL6/Centos6 (`firewall::iptables`)
 * RHEL7/Centos7 (`firewall::firewalld`)
 * Puppet 3.6

## Intro
The simplest possible configuration method for firewalld and iptables, 
based on copying files to the appropriate `/etc` directories.

Firewalld is reasonably nice in offering dynamic configuration, easy IPv6 support
and a clear zone structure, but the lack of support for OUTPUT zones is quite annoying.
Also the logging support is quite restrictive, and I have not yet figured out how to do a nice "noise filtering" chain.

## Usage
Firewalld on RHEL7
```
include firewall::firewalld
```
As you can read in the code, this deploys two standard zones, public and lan. You can skip this wrapper class if you want to manage different zones.

Plain iptables on RHEL6 or RHEL7
```
include firewall::iptables::file
```
Here you have plenty of rope to hang yourself with an unrestricted, direct iptables configuration.

As you can read in the `firewall::*::params()`, the configurations files are expected to be found under `/etc/puppet/files_site/firewall`. This could be parametrised in Hiera.

## Examples
The firewalld examples are relatively basic and intended for hosts which are already protected 
behind a good network firewall - for this reason `ssh` can be left exposed on "public" zone.

Also the outgoing filter (implemented as "direct" since firewalld has very little support for outgoing, as of 2017), is left in ACCEPT, and so intended more as a debug or intrusion detection logging than actual strong protection. Note that maintaining an proper outgoing firewall can be quite a tedious task, more than for the incoming, and incurs more risk of running into unexpected issues e.g. dropped packets with slow servers or clients.

The iptables example is really just an example. 

Make sure you use IPs and not hostnames in your iptables, else you may run into issues at boot time - if the DNS is not available or if the hostnames have changed.

## ToDo
- [ ] import iptables "source" management, with templates for chain/snippet inclusion, as used in ATLAS TDAQ.
- [ ] parametrise file source path - with Hiera?
- [ ] find out what happens with firewalld startup in case of DNS issues
- [ ] support ipsets also under plain iptables and on RHEL6

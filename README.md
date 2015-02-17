# IP Wrangler

[![Code Climate](https://codeclimate.com/github/dice-cyfronet/ip-wrangler/badges/gpa.svg)](https://codeclimate.com/github/dice-cyfronet/ip-wrangler)
[![Dependency Status](https://gemnasium.com/dice-cyfronet/ip-wrangler.svg)](https://gemnasium.com/dice-cyfronet/ip-wrangler)
[![Gem Version](https://badge.fury.io/rb/ip-wrangler.svg)](http://badge.fury.io/rb/ip-wrangler)

In polish __Portostawiaczka__

This application manages DNAT port mappings and IP mappings for Virtual Machines
(behind the NAT). It needs to be run on a node which is a router for Virtual
Machines. It provides an API reachable via HTTP URL (`GET`, `POST`, `DELETE`)
which allows the user to perform changes on `iptables` `nat` tables. It manages
a pool of used and empty port mappings or IP mappings using an SQLite database.

## Installation

### Requirements

* `iptables`
* `lsof`
* `sudo` (the user which runs `ipwrangler` needs permissions to run `/sbin/iptables` and `/usr/bin/lsof` via `sudo`)
* `sqlite3` with `libsqlite3-dev`

### Packages / Dependencies

Update your system (as root, **optional**):

    aptitude update
    aptitude upgrade

Install additional packages (as root, **optional**):

    aptitude install iptables lsof sudo libsqlite3-dev g++ make autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev

Install `ruby` and `bundler` (as root, **optional**):

    mkdir /tmp/ruby
    pushd /tmp/ruby
    curl --progress http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz | tar xz
    pushd /tmp/ruby/ruby-2.1.2
    ./configure --disable-install-rdoc
    make
    make install
    gem install bundler --no-ri --no-rdoc
    popd
    popd

> **Note!** You can use *rbenv* or *rvm* if you don't want to install ruby globally.

Install this software:

    gem install ip-wrangler

Add `user_name` (which will start `ip-wrangler`) to `sudo` group (as root):

    adduser user_name sudo

To enable `iptables` and `lsof` for user `user_name` modify `/etc/sudoers` (as root)
using `visudo`. Add the following line at the bottom of the file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

`host_name` must be the same like in `/etc/hostname`.

### Configuration

Before you start, configure *migratio* installation by executing short wizard:

    ip-wrangler-configure ./config.yml

You may edit manually configuration file, eg. `config.yml`.

### Run

When launching for the first time, run the application in the foreground:

    ip-wrangler-start -c ./config.yml -F

Verify that everything is okay.

Application can be run in the background:

    ip-wrangler-start -c ./config.yml -P ./ip-wrangler.pid

To stop `ipwrangler` which runs in the background:

    ip-wrangler-stop -P ./ip-wrangler.pid

To clean rules created by `ipwrangler` in `iptables`:

    ip-wrangler-clean <iptables_chain_name|maybe:IPT_WR>

You can use *init.d* scripts to start and stop *migratio* automatic.
Plase check [`initd.md`](support/initd.md). Be aware that service will
run as `root`. You can change it by modifing [script](support/initd/ip-wrangler).

### Log'n'roll

Use *logrotate* to roll generated logs. Example configuration for *logrotate*:

    # ip-wrangler logrotate settings
    # based on: http://stackoverflow.com/a/4883967
    
    /path/to/ip-wrangler/src/log/*.log {
        daily
        missingok
        rotate 90
        compress
        notifempty
        copytruncate
    }

## API

### Port

Listing:

* `GET /nat/port` - list all NAT port(s)
* `GET /nat/port/<private_ip>` - list NAT port(s) for specified private IP

Creating:

* `POST /nat/port/<private_ip>/<private_port>/<protocol>` - create NAT port for specified IP
* `POST /nat/port/<private_ip>/<private_port>` - create NAT ports (tcp,udp) for specified IP

Deleting:

* `DELETE /nat/port/<private_ip>/<private_port>/<protocol>` - delete NAT port with specified protocol for specified private IP
* `DELETE /nat/port/<private_ip>/<private_port` - delete NAT port for specified IP
* `DELETE /nat/port/<private_ip>` - delete any NAT port for specified IP

### IP

Listing:

* `GET /nat/ip` - get list of all NAT IPs
* `GET /nat/ip/<private_ip>` - get list of NAT IPs for specified private IP

Creating:

* `POST /nat/ip/<private_ip>` - create NAT IP for specified private IP

Deleting:

* `DELETE /nat/ip/<private_ip>/<public_ip>` - delete NAT IP for specified private IP
* `DELETE /nat/ip/<private_ip>` - delete any NAT IP for specified private IP

## API (old version)

Listing:

* `GET /` - get information about REST service
* `GET /dnat` - list all NAT port(s)
* `GET /dnat/<private_ip>` - list NAT port(s) for specified private IP

Creating:

* `POST /dnat/<private_ip>` - create NAT port for specified IP. The request body should be specified in the following format:

_example_

    [
        {
            "port": 21,
            "proto": tcp
        },
        {
            "port": 22,
            "proto": udp
        }
    ]

Deleting:

* `DELETE /dnat/<private_ip>/<private_port>/<protocol>` - delete NAT port with specified protocol for specified private IP
* `DELETE /dnat/<private_ip>/<private_port>` - delete NAT port for specified IP
* `DELETE /dnat/<private_ip>` - delete any NAT port for specified IP

## Flow

More information in [docs](DOCS.md).

## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new *Pull Request*


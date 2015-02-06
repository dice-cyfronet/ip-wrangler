# IP Wrangler

[![Code Climate](https://codeclimate.com/github/dice-cyfronet/ip-wrangler/badges/gpa.svg)](https://codeclimate.com/github/dice-cyfronet/ip-wrangler)
[![Dependency Status](https://gemnasium.com/dice-cyfronet/ip-wrangler.svg)](https://gemnasium.com/dice-cyfronet/ip-wrangler)

In polish __Portostawiaczka__

This application manages DNAT port mappings and IP mappings for Virtual Machiness (behind the NAT). It needs to be run on a node which is a router for Virtual Machines. It provides an API reachable via HTTP URL (`GET`, `POST`, `DELETE`) which allows the user to perform changes on `iptables` `nat` tables. It manages a pool of used and empty port mappings or IP mappings using an SQLite database.

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

#### Permissions

Create a user account which will be used to run `ipwrangler` (as root):

    adduser user_name

Add created user to `sudo` group (as root):

    adduser user_name sudo

To enable `iptables` and `lsof` for user `user_name` modify `/etc/sudoers` (as root):

    visudo

Add the following line at the bottom of the file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` comes from `/etc/hostname`

### Installation

Download source archive or clone repository from the `master` branch.

Download archive (as non-root):

    wget --no-check-certificate https://github.com/dice-cyfronet/ip-wrangler/archive/master.zip

Clone repository (as non-root):

    GIT_SSL_NO_VERIFY=1 git clone -b master https://github.com/dice-cyfronet/ip-wrangler.git

The following commands should be execute as `user_name` in the root directory of the project.

Install required bundles and configure `ipwrangler` (as non-root):

    bundle install --deployment
    rake configure

### Run

When launching for the first time, run the application in the foreground:

    rake rundevel

Verify that everything is okay.

Subsequently the application can be run in the background:

    rake run

To stop `ipwrangler` running in the background:

    rake stop

To clean rules created by `ipwrangler` in `iptables`:

    user_name@host_name $ rake clean

To purge the entire `ipwrangler` database and settings:

    user_name@host_name $ rake purge

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

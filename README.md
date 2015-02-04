# IP Wrangler

[![Code Climate](https://codeclimate.com/github/dice-cyfronet/ip-wrangler/badges/gpa.svg)](https://codeclimate.com/github/dice-cyfronet/ip-wrangler)
[![Dependency Status](https://gemnasium.com/dice-cyfronet/ip-wrangler.svg)](https://gemnasium.com/dice-cyfronet/ip-wrangler)

In polish __Portostawiaczka__

This application manages DNAT port mappings and IP mappings for Virtual Machiness (behind the NAT) managed by [Atmosphere](https://github.com/dice-cyfronet/atmosphere). It need to be run on a node which is a router for Virtual Machines. It provides API reachable via HTTP URL (`GET`, `POST`, `DELETE`) which allow to perform changes on `iptables` `nat` tables. It handles pool of used and empty port mappings or IP mappings using SQLite database.

## Installation

### Requirements

* `iptables`
* `lsof`
* `sudo` (user used to run `ipwrangler` needs to have permissions to run `/sbin/iptables` and `/usr/bin/lsof` via `sudo`)
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

Create user which will be used to run `ipwrangler` (as root):

    adduser user_name

Add created user to `sudo` group (as root):

    adduser user_name sudo

To enable `iptables` and `lsof` for user `user_name` modify `/etc/sudoers` (as root):

    visudo

Add following line at bottom of file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` is come from `/etc/hostname`

### Installation

Download archive with sources or clone repository from `master` branch.

Download archive (as non-root):

    wget --no-check-certificate https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr/repository/archive.zip?ref=master

Clone repository (as non-root):

    GIT_SSL_NO_VERIFY=1 git clone -b master https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr.git

Following command execute as `user_name` in root directory of project.

Install required bundles and configure `ipwrangler` (as non-root):

    bundle install --deployment
    rake configure

### Run

For the first time run application in foreground:

    rake rundevel

Verify if everything is okey.

For the next time run it in background:

    rake run

Stop `ipwrangler` running in background:

    rake stop

Clean rules created by `ipwrangler` from `iptables`:

    user_name@host_name $ rake clean

Purge `ipwrangler` database and settings:

    user_name@host_name $ rake purge

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

* `POST /dnat/<private_ip>` - create NAT port for specified IP, request body should be in format

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

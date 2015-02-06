# IP Wrangler

[![Code Climate](https://codeclimate.com/github/dice-cyfronet/ip-wrangler/badges/gpa.svg)](https://codeclimate.com/github/dice-cyfronet/ip-wrangler)
[![Dependency Status](https://gemnasium.com/dice-cyfronet/ip-wrangler.svg)](https://gemnasium.com/dice-cyfronet/ip-wrangler)

In polish __Portostawiaczka__

## Requirements

* `iptables`
* `lsof`
* `sudo` (user which will be used to start `ipwrangler` needs to have permissions to run `/sbin/iptables` and `/usr/bin/lsof`)
* `ruby` (recommended version ≥ 1.9)
* `ruby-dev` with `g++`, `make`
* `bundler`
* `rake`
* `thin`
* `libsqlite3-dev`

## Usage

The following commands shoule be executed as `root`.

Install required packages:

Using `apt-get`:

    root@host_name # apt-get install -y iptables lsof sudo ruby ruby-dev bundler rake thin libsqlite3-dev g++ make

Using `aptitude`:

    root@host_name # aptitude install -y iptables lsof sudo ruby ruby-dev bundler rake thin libsqlite3-dev g++ make

Create a user account which will be used to start `ipwrangler`:

    root@host_name # adduser user_name

where:

* `user_name` can be any name

Add the newly created user to the `sudo` group:

    root@host_name # adduser user_name sudo

To enable `iptables` and `lsof` for the user account which will be used to start `ipwrangler`, modify `/etc/sudoers`:

    root@host_name # visudo

Add the following line at the bottom of the file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` comes from `/etc/hostname`
* `user_name` is the name of user account which will be used to start `ipwrangler`

The following command should be executed as `user_name`.

Download the source archive or clone repository from the `master` branch:

Download archive:

    user_name@host_name $ wget --no-check-certificate https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr/repository/archive.zip?ref=master

Clone repository:

    user_name@host_name $ GIT_SSL_NO_VERIFY=1 git clone -b master https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr.git

The following commands should be executed as `user_name` in the root directory of the project.

Install te required bundles:

    user_name@host_name $ rake gem

Configure `ipwrangler`:

    user_name@host_name $ rake configure

When launching the system for the first time, run the following in foreground:

    user_name@host_name $ rake rundevel

Verify that everything is okay.

For subsequent runs, launch the system in the background:

    user_name@host_name $ rake run

To stop `ipwrangler` running in the background:

    user_name@host_name $ rake stop

To clean rules created by `ipwrangler` in `iptables`:

    user_name@host_name $ rake clean

To purge the whole `ipwrangler` database and settings:

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

* `POST /dnat/<private_ip>` - create NAT port for specified IP, request body should be in the following format

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

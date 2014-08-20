# IP Wrangler

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

Following command execute as `root`.

Install required packages:

Using `apt-get`:

    root@host_name # apt-get install -y iptables lsof sudo ruby ruby-dev bundler rake thin libsqlite3-dev g++ make

Using `aptitude`:

    root@host_name # aptitude install -y iptables lsof sudo ruby ruby-dev bundler rake thin libsqlite3-dev g++ make

Create user which will be used to start `ipwrangler`:

    root@host_name # adduser user_name

where:

* `user_name` can be any name

Add created user to `sudo` group:

    root@host_name # adduser user_name sudo

To enable `iptables` and `lsof` for user which will be used to start `ipwrangler` modify `/etc/sudoers`:

    root@host_name # visudo

Add following line at bottom of file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` is come from `/etc/hostname`
* `user_name` is the name of user which will be used to start `ipwrangler`

Following command execute as `user_name`.

Download archive with sources or clone repository from `master` branch:

Download archive:

    user_name@host_name $ wget --no-check-certificate https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr/repository/archive.zip?ref=master

Clone repository:

    user_name@host_name $ GIT_SSL_NO_VERIFY=1 git clone -b master https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr.git

Following command execute as `user_name` in root directory of project.

Install required bundles:

    user_name@host_name $ rake gem

Configure `ipwrangler`:

    user_name@host_name $ rake configure

First time run, in foreground:

    user_name@host_name $ rake rundevel

Verify if everything is okey.

Next time run, in background:

    user_name@host_name $ rake run

Stop `ipwrangler` running in background:

    user_name@host_name $ rake stop

Clean rules created by `ipwrangler` from `iptables`:

    user_name@host_name $ rake clean

Purge `ipwrangler` database and settings:

    user_name@host_name $ rake purge

### Options for scripts `run.sh` or `devel-run.sh`:

* `-i` - listen IP, default: `0.0.0.0`
* `-p` - listen port, default: `8400`
* `-t` - tag, default: `IptWr`

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

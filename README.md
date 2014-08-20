# IP Wrangler

In polish __Portostawiaczka__

## Requirements

* `sudo` (user running this wrangler need to have permission to run `/sbin/iptables` and `/usr/bin/lsof`, see below)
* `ruby` (recommended version ≥ 1.9)
* `bundler`
* `rake`
* `thin`
* `libsqlite3-dev`

## Usage

Following command execute as `root`.

Install required packages:

* using `apt-get`:

    `root@host_name # apt-get install -y sudo ruby bundler rake thin libsqlite3-dev`

* using `aptitude`:

    `root@host_name # aptitude install -y sudo ruby bundler rake thin libsqlite3-dev`

Create user which will be used to start `ipwrangler`:

    root@host_name # adduser user_name
    ... answer for questions
    root@host_name # adduser ipwrangler sudo

where:

* `user_name` can be any name

To enable `iptables` and `lsof` used by `ipwrangler`, modify `/etc/sudoers`:

    root@host_name # visudo

Add following line at bottom of file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` is come from `/etc/hostname`
* `user_name` is the name of user which will be used to start `ipwrangler`

Following command execute as `user_name`.

Download archive with sources or clone repository from `master` branch:

    ... download archive
    user_name@host_name $ wget --no-check-certificate https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr/repository/archive.zip?ref=master
    ... clone repository
    user_name@host_name $ GIT_SSL_NO_VERIFY=1 git clone -b master https://gitlab.dev.cyfronet.pl/atmosphere/ipt_wr.git

Install:

    ... execute command in root directory of project
    user_name@host_name $ sudo rake gem
    user_name@host_name $ rake configure
    ... answer for questions

First time run, in foreground:

    ... execute command in root directory of project
    user_name@host_name $ rake rundevel
    ... verify if everything is okey

Next time run, in background:

    ... execute command in root directory of project
    user_name@host_name $ rake run

Stop:

    ... execute command in root directory of project
    user_name@host_name $ rake stop

Clean rules from iptables:

    ... execute command in root directory of project
    user_name@host_name $ rake clean

Purge database and settings:

    ... execute command in root directory of project
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
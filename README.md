# IP Wrangler

In polish __Portostawiaczka__

## Requirements

* `ruby` (recommended version ≥ 1.9)
* `bundler`
* `rake`
* (maybe) `thin`

## Installation and run (with Rake)

    $ rake
    ... answer for questions
    ... first time run
    $ ./devel-run.sh
    ... verify if everything is okey
    ... next time run
    $ ./run.sh
    ... or
    $ rake run

### Options for ./run.sh or ./devel-run.sh

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
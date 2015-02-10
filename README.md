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

Install this software (as non-root):

    git clone https://github.com/dice-cyfronet/ip-wrangler.git

Install gems (as non-root, inside project directory):

    bundle install --path vendor/bundle

Add `user_name` to `sudo` group (as root):

    adduser user_name sudo

To enable `iptables` and `lsof` for user `user_name` modify `/etc/sudoers` (as root):

    visudo

Add the following line at the bottom of the file:

    user_name host_name= NOPASSWD: /sbin/iptables, /usr/bin/lsof

where:

* `host_name` comes from `/etc/hostname`

Enable upstart for non-root user (as root):

    nano /etc/dbus-1/system.d/Upstart.conf

It should looks like this:

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE busconfig PUBLIC
      "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
      "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    
    <busconfig>
      <!-- Only the root user can own the Upstart name -->
      <policy user="root">
        <allow own="com.ubuntu.Upstart" />
      </policy>
    
      <!-- Allow any user to invoke all of the methods on Upstart, its jobs
           or their instances, and to get and set properties - since Upstart
           isolates commands by user. -->
      <policy context="default">
        <allow send_destination="com.ubuntu.Upstart"
           send_interface="org.freedesktop.DBus.Introspectable" />
        <allow send_destination="com.ubuntu.Upstart"
           send_interface="org.freedesktop.DBus.Properties" />
        <allow send_destination="com.ubuntu.Upstart"
           send_interface="com.ubuntu.Upstart0_6" />
        <allow send_destination="com.ubuntu.Upstart"
           send_interface="com.ubuntu.Upstart0_6.Job" />
        <allow send_destination="com.ubuntu.Upstart"
           send_interface="com.ubuntu.Upstart0_6.Instance" />
      </policy>
    </busconfig>

Install *Upstart* scripts (as non-root):

    mkdir -p ${HOME}/.init
    cp -i ./support/upstart/*.conf ${HOME}/.init/

Set proper directory for `ip-wrangler/` and `ip-wrangler/log/`:

    nano ${HOME}/.init/ip-wrangler.conf
    nano ${HOME}/.init/ip-wrangler-thin.conf

Update profile files (eg. `.bash_profile`):

    cat >> ${HOME}/.bash_profile <<EOL
    if [ ! -f /var/run/user/\$(id -u)/upstart/sessions/*.session ]
    then
        /sbin/init --user --confdir \${HOME}/.init &
    fi
    
    if [ -f /var/run/user/\$(id -u)/upstart/sessions/*.session ]
    then
       export \$(cat /var/run/user/\$(id -u)/upstart/sessions/*.session)
    fi
    EOL

You need to re-login to apply changes in ${HOME}/.bash_profile

### Configuration

Before you start, configure *migratio* installation by executing short wizard:

    bin/ip-wrangler-configure

You may edit manually configuration file `lib/config.yml`.

### Run

When launching for the first time, run the application in the foreground:

    bin/ip-wrangler-start -F

Verify that everything is okay.

Application can be run in the background:

    bin/ip-wrangler-start

To stop `ipwrangler` which runs in the background:

    bin/ip-wrangler-stop

To clean rules created by `ipwrangler` in `iptables`:

    bin/ip-wrangler-clean <prefix>

To purge the entire `ipwrangler` database, settings and logs

    bin/ip-wrangler-purge

You can use *upstart* to start and stop *migratio*.

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

## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new *Pull Request*


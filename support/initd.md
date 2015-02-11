## Init.d

Download [`ip-wrangler`](https://github.com/dice-cyfronet/ip-wrangler/blob/master/support/initd/ip-wrangler)
into `/etc/init.d/ip-wrangler`.

    wget -O /etc/init.d/ip-wrangler https://raw.githubusercontent.com/dice-cyfronet/ip-wrangler/master/support/initd/ip-wrangler
    chmod +x /etc/init.d/ip-wrangler

Create directories:

    mkdir /var/log/ip-wrangler /etc/ip-wrangler

Create configuration file in `/etc/ip-wrangler/ip-wrangler.yml` by

    ip-wrangler-configure /etc/ip-wrangler/ip-wrangler.yml

Set values to:

* log directory: `/var/log/ip-wrangler`
* database file: `/etc/ip-wrangler/ip-wrangler.db`

Update your `initd` configuration to enable start and stop service. `ip-wrangler` will started by `root`.

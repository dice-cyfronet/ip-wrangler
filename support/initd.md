## Init.d

Download [`ip-wrangler`](https://github.com/dice-cyfronet/ip-wrangler/support/initd/ip-wrangler)
into `/etc/init.d/ip-wrangler`.

Create configuration file (as root) in `/etc/ip-wrangler/ip-wrangler.yml` using
`ip-wrangler-configure /etc/ip-wrangler/ip-wrangler.yml`.

Update your `initd` configuration to enable start and stop service.

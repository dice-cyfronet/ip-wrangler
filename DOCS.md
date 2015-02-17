# Flow - API

## get `/nat/port`

* `get_nat_ports` on NAT
* `select_nat_port` on DB
* replace `public_ip` with `ext_ip`

## get `/nat/port/<private_ip>`

* `get_nat_ports` on NAT by `private_ip`
* `select_nat_port` on DB by `private_ip`
* replace `public_ip` with `ext_ip`

## get `/nat/ip`

* `get_nat_ips` on NAT
* `select_nat_ip` on DB

## get `/nat/ip/<private_ip>`

* `get_nat_ips` on NAT by `private_ip`
* `select_nat_ip` on DB by `private_ip`

## post `/nat/port/<private_ip>/<private_port>/<protocol>`

* `lock_port` on NAT by `private_ip, private_port, protocol`
* `select_nat_port` on DB by `private_ip, private_port, protocol`
* check if empty
 * `find_port` on NAT by `private_ip, private_port, protocol`
 * `get_first_empty_nat_port` from DB for protocol `protocol`
 * check if `not_used_port` and if `not_exists_nat_port`
  * `insert_nat_port` to DB
  * `append_nat_port` to IpTables
* else return exists

## post `/nat/port/<private_ip>/<private_port>`

The same as for **post** `/nat/port/<private_ip>/<private_port>/<protocol>` for
both `tcp` and `udp` protocols.

## post `/nat/ip/<private_ip>`

* `lock_ip` on NAT by `private_ip`
* `select_nat_ip` on DB by `private_ip`
* check if empty
 * `find_ip` on NAT by `private_ip`
 * `get_first_empty_nat_ip` on DB
 * check if `not_used_ip` and if `not_exists_nat_ip`
  * `insert_nat_ip` to DB
  * `append_nat_ip` to IpTables
* else return exists

## delete `/nat/port/<private_ip>/<private_port>/<protocol>`

* `release_port` on NAT by `private_ip, private_port, protocol`
* for each `select_nat_port` on DB:
 * `delete_nat_port` on IpTables
* `delete_nat_port` on DB by `private_ip, private_port, protocol`

## delete `/nat/port/<private_ip>/<private_port>`

The same as for **delete** `/nat/port/<private_ip>/<private_port>/<protocol>` for
both `tcp` and `udp` protocols.

## delete `/nat/port/<private_ip>`

The same as for **delete** `/nat/port/<private_ip>/<private_port>/<protocol>` for
both for all mappings.

## delete `/nat/ip/<private_ip>/<private_port>`

* `release_ip` on NAT by `private_ip, public_ip`
* for each `select_nat_ip` on DB:
 * `delete_nat_ip` on IpTables

## delete `/nat/ip/<private_ip>`

The same as for **delete** `/nat/ip/<private_ip>/<private_port>` for all mappings.

# Flow - Old API

## get `/`

Return `IptWr REST Endpoint!`

## get `/dnat`

* `get_nat_ports` on NAT
* `select_nat_port` on DB
* replace `public_ip` with `ext_ip`

## get `/dnat/<ip>`

* `get_nat_ports` on NAT by `ip`
* `select_nat_port` on DB by `ip`
* replace `public_ip` with `ext_ip`

## post `/dnat/<ip>` with JSON body

* for each port in JSON body: `lock_port`; see **post** `/nat/port/`

## delete `/dnat/<ip>/<port>/<proto>`

The same as **delete** `/nat/port/<private_ip>/<private_port>/<protocol>`.

## delete `/dnat/<ip>/<port>`

The same as **delete** `/nat/port/<private_ip>/<private_port>`.

## delete `/dnat/<ip>`

The same as **delete** `/nat/port/<private_ip>`.

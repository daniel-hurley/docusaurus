Title | Configuring Fortinet Interface to send IPv6 RAs
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Configuring Fortinet Interface to send IPv6 RAs

Enabling Fortinet interface(s) to send IPv6 Route Advertisements on the LAN is not quite as simple as enabling the obvious configuration nob found in the CLI configuration of a Fortinet firewall.

To enable a fortinet interface to send IPv6 RAs on a LAN, reference the configuration located below, with v6 address fd00:1::/64 used as an example.

```
    edit "portXX"

        config ipv6

            set ip6-address fd00:1::1/64
            set ip6-send-adv enable
            set ip6-other-flag enable
            config ip6-prefix-list

                edit fd00:1::/64

                    set autonomous-flag enable

                    set onlink-flag enable

                next

            end

        end

```

`ip6-address` and `ip6-send-adv` parameters are required to 

1. enable IPv6 on the interface, with the a-lotted IPv6 Address and
2. enable the interface to send Route Advertisements.

Though, more configuration is needed.

`ip6-other-flag` enables the Fortinet to include DNS servers inside it’s Route Advertisements (RAs).

`ip6-prefix-list`, and its nested configuration, detail out the subnet to be included in the Route Advertisements (RAs).

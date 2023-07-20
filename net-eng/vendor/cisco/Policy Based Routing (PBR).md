Title | Policy Based Routing (PBR)
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Policy Based Routing (PBR)

Cisco Policy Based Routing (PBR) When a packets enters a router on a particular interface, it route packets based on any source address - even if that packet is sourcing an IP from a different network. The packet is routed either using a configured VRF or the default VRF. With PBR you can modify the direction an IP packet takes based on a criteria (route-map).
When a packets enters a router on a particular interface, it route packets based on *any* source address – even if that packet is sourcing an IP from a different network. The packet is routed either using a configured VRF or the default VRF. With PBR you can modify the direction an IP packet takes based on a criteria (route-map). PBR is performed right before regular routing. If a packet coming into an interface does *not* match the PBR criteria, then the packet will be routed normally (either in the default routing table or configured VRF). PBR that is applied to an interface does not apply to local generated traffic (aka ping ssh etc). PBR can also be applied globally (all interfaces where routing occurs).

You can accomplish PBR by completing the following high-level tasks:
1. Define match criteria using ACL/Prefix-List (aka what traffic you want to modify routing for)
2. Assign the criteria to a Route-Map sequence, and specify parameters
```
! Configure ACL for matching Source/Dest IPs
! Configure Route-Map to match on IP/length and set parameters for that packet
#match ip address [ACL]
```
or
```
#match length [length]
! The default keyword simply uses the default routing table FIRST, and if it does not find a route match use the IP/interface specified in the command. The precedence and tos values can be changed for traffic that is routed via PBR.
#set ip next-hop [ip address(es)]
#set ip default next-hop [ip address(es)]
#set interface [interface type/num]
#set default interface [interface type/num]
#set ip precedence [value]
#set ip tos [value]
! Apply PBR to incoming interface
#ip policy route-map [name]
! Apply PBR for local generated traffic
#ip local policy route-map [name]
! Verify PBR
#sh ip policy
#sh route-map
#debug ip policy
```
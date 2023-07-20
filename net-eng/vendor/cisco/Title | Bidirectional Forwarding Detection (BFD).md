Title | Bidirectional Forwarding Detection (BFD)
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Bidirectional Forwarding Detection (BFD)

BFD is a lightweight keepalive protocol that runs independently from your routing protocol(s). When a link goes down on a router (not using any in-between devices like a switch) it re-converges instantaneously. The reason for this is because since there is no L2 connectivity, L3 connectivity obviously cannot happen and therefore the routing protocol can act on it fast. However, if a link does down somewhere upstream (that is, not directly attached to the router) then the routing protocol will have to wait for its dead/hold timer to expire before re converging. The benefit of BFD is that it can detect L2 disconnects somewhere upstream, and then report that to your upper-layer routing protocol to re-converge faster.

BFD is a lightweight keepalive protocol that runs independently from your routing protocol(s).When a link goes down on a router (not using any in-between devices like a switch) it re-converges *instantaneously*. The reason for this is because since there is no L2 connectivity, L3 connectivity obviously cannot happen and therefore the routing protocol can act on it fast. However, if a link does down somewhere upstream (that is, not directly attached to the router) then the routing protocol will have to wait for its dead/hold timer to expire before re converging. The benefit of BFD is that it can detect L2 disconnects somewhere upstream, and then report that to your upper-layer routing protocol to re-converge faster.

- RFC 5880 – Bidirectional Forwarding Detection (BFD)
- RFC 7419 – Common Interval Support in BFD

There are two versions of BFD

- Version 0 – Echo mode with asymmetry
- Version 1 – Echo mode with symmetry

### BFD Configuration
```
! Turn on BFD on the interface level. The interval [ms] time is the time frequency that the interface sends out BFD echo packets to it’s neighboring router. The min_rx [ms] time is how often it expects to receive BFD echo packets from it’s neighboring router. Multiplier [interval] is the same as dead time for a routing protocol. If a router does not hear a BFD echo packet from it’s neighbor in [multiplier x min_rx ms] then it will report to the upper layer routing protocol that the link is dead (that is if you have the routing protocol end configured)

#bfd interval [ms] min_rx [ms] multiplier [interval]

! Associate BFD to your routing protocol, and interface

#router eigrp 1

#bfd [all-interfaces | interface {name}]

! Verification commands

#show bfd neighbors

#debug bfd [packet|event]
```
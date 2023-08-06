Title | Virtual Port-Channel (vPC) on Cisco Nexus
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Virtual Port-channel (vPC) – What is it?

vPC is a feature on Cisco Nexus switches that allows you to do port channel configuration across two *separate* switches. The benefit of this is that you can have a server (or a switch – practically any device that does port-channeling) create a port-channel configuration, and one uplink goes to one nexus switch, and the other uplink goes to another nexus switch. Despite the port-channel being physically connected to two different switches, the two vPC *peers* synchronize their control plain information – which makes their associated *member* ports part of one of logical switch. In a regular switching design, this would cause MAC Flapping between server port 1 and server port 2. But since vPC is used to synchronize the control plane data and their associated member ports – this type of topology becomes possible. vPC consists of 2 physical switches called ‘vPC Peers’. These switches must be identical for a vPC peer to be formed. If it is running a nexus-type chassis, then the two line cards have to be identical.

Cisco Fabric Services Over Ethernet (CFSoE) is a protocol developed by Cisco to facilitate the communication between two vPC peers. the CFSoE is the protocol used to synchronize the MAC, ARP, and IGMP tables. It is also used to compare hardware revisions when in the negotiation phase of the vPC Peers.

vPC Peers form a vPC Domain. The two vPC peers must match the Domain values to be considered in the same vPC domain. The LAG ID (LACP System ID) is inherited from the Domain ID, that is then shared across the peers. This makes it to where when LACP is found to be on a vPC member, that the two switches advertise the *same* LAG ID. Additionally, the vPC domain *number (*that is configured*)* is used in the LACP System Identifier. The well known MAC of 00:23:04:ee:be:xx is being used by Cisco for the LACP vPC identification. The last 8 bits are encoded with the vPC domain number that is configured. When creating a back to back vPC with nexus switches, the vPC peer domains must not be identical because of the LACP system identifier number that is inherited.

vPC peers also elect a *primary* and *secondary* vPC peer. This is elected based on the vPC Role Priority[1-65535]. The default role priority on a switch is 32667. If the Role Priority is the same on both switches the MAC Address between the two is used. Whichever switch with the lower priority/MAC becomes the primary while the other becomes the secondary. Whenever a type 1 consistency mis-match is found on the vPC peers, the secondary box disables their vPC member ports while the primary keeps them up.

There is a feature called “vPC peer switch” that can be enabled on vPC peers. What this does is make it to where both the vPC “Primary” and “Secondary” devices appear and operationally function as the root switch within a spanning tree topology. Essentially when you enable the feature the ‘vPC system MAC’ is inherited into the spanning-tree priority for all VLANs. The priority, however, is not changed. When you set the spanning-tree priority value to be the same as the root bridge(on the other switch), it does not cause a topology change by re-electing the root bridge. Instead both the primary and secondary peers advertise the vPC System MAC and the priority.

vPC Peers track reach-ability between each other using Peer Keepalives. Peer Keepalive is a UDP Ping to a L3 interface on the other peer. Any type of L3 interface can be created to facilitate this UDP ping communication: Routed Interface, L3 Port Channel, SVI, etc.

Peers sync their control plane over the Peer Link. A Peer Link is just a layer 2 port-channel between the peers. A miniumum of x2 10GB Links is needed for the vPC Peer Link. This is the link that synchronizes the MAC, ARP, and IGMP tables to each other so that both switches know that a particular MAC lives off both ports – not just one (just like a regular port-channel, but on two different switches)

A member port is the ports that are synchronized together to create the port-channel across the two switches IE. downlink and/or uplink ports.

A orphan Ports are ports that are singly attached connection to a vPC Peer (either by design, or by vPC Peer Failure)

Orphan Ports use modified loop prevention:

- Traffic from remote Orphan is allowed to enter peer link and exit via local Member
- Traffic from remote Member is allowed to enter via peer link and exit via local Orphan
- Traffic from remote Member is not allowed to enter via peer link and exit via local Member

By default two vPC peers running HSRP do active/active forwarding instead of active-standby (by default, no configuration needed). They achieve this by both vPC peers listening for the vMAC of HSRP and from there route the traffic. If the downstream server or switch is hashed to the ‘standby’ hsrp router, the ‘standby’ switch will still listen for the vmac and route the traffic itself (instead of switching the traffic over the peerlink).The only problem with the above is that HSRP/L3 functions are not communicated down to the vpc (or vice versa). So if a L3 function goes does, the vPC knows nothing about it. If the Peer link goes down, the secondary disables its SVIs and member ports. However, if the routed ports also go down on the primary, then the server is then isolated. In the case of HSRP, if the routed ports go down on one switch, the SVI for HSRP is still actively listening and trying to route traffic (to of which it cannot route). What you would want to do is implement enhanced object tracking to also track the routed ports, so if they do go down, HSRP is switched from A/A to A/S. See below for config.

### High-Level Configuration

1. Turn on the vPC feature

2. Define the vPC Domain

3. Establish a vPC Peer Keepalive connection

4. Establish a vPC Peer Link connection

5. Establish the vPC Member ports

The above steps detail out the order of operations when configuring/bringing up the vPC. A Member Port cannot be established unless, the peer link is established. A Peerlink cannot be established unless the keepalive connection is established.
```
! Turn on vPC feature

#feature vpc

! Define the vPC Domain

#vpc domain [1-1000]

! Define the peer keepalive *destination* (under vPC configuration mode). If you do not specify a VRF, the default management VRF will be used for the destination. If any other VRF is used you need to specify that VRF.

#peer-keepalive destination [IP Address] {vrf [name]}

! Create a port channel between the two vPC peers. Under the port channel you specify the peerlink as a the ‘vpc peer-link’. When configuring a vPC, Spanning Tree Bridge Assurance must be enabled on the peer-link. By default it will configure the port-channel with ‘spanning-tree port type network’ (which essentially enables bridge assurance). The reason for this is because if one VLAN is created on one vPC peer but not the other, bridge assurance will prune that VLAN off the trunk.

#interface port-channel1

#switchport mode trunk

#vpc peer-link

#int eth1/x

#switchport mode trunk

#channel-group 1

#int eth1/x

#switchport mode trunk

#channel-group 1

! Create Member ports (trunk or access). When you type just ‘vpc’ under the port-channel configuration, it inherits the number of the vpc with the port-channel number itself. So if you configure port-channel 11, and type just vpc, it will create vpc 11. The vpc numbers must match between both peers to form the member ports. The port-channel number between the two vpc peers, however, do not have to match. For simplicities sake it makes sense to match them on both sides.

#int eth1/x

#channel-group [#] mode active

#int port-channel[#]

#switchport

#vpc {#}

! Configure peer-switch feature on vPC Peer Switches. This must be configured on both the Primary and Secondary Switch for the feature to work.

#vpc domain [#]

#vpc peer-switch

! Configure delay restore for the vPC Peer Link. Delay restore is a ‘wait timer’ for how long the vPC Member ports have to wait until they come up, when the vPC Peer Link is restored/initialized. The reason for this is mainly to let your L3 Routing Protocol to converge first before bring up the vPC Members.

#delay restore [#]

! Configure the vPC Auto Recovery timer

#auto-recovery reload-delay [#]

! Configure the vPC Secondary Device to not disable its SVIs if the Peer Link goes down

#dual-active exclude interface-vlan

!Configure the vPC orphan ports to also be disabled if the peerlink fails and secondary receives a Keepalive ping

#vpc orphan-port suspend

! vPC verification commands

#show vpc

#show vpc keepalive

#show vpc role

#show vpc consistency-parameters

#show port-channel compatibility-parameters

#show run int po[#] membership

! Displays orphan ports that are attached to a vPC peer. This will only show ports that are not configured for a vpc. It will not show orphaned ports from a failure point of view.

#show vpc orphan-ports

! Configure advanced object tracking for Nexus vPC. What this does is allow other ports (such as uplink L3 ports) to be tracked so that if those interfaces fail, then the secondary vPC will become primary vPC. The same config can be applied to HSRP, where HSRP does A/A. Advanced object tracking can force both of the SVIs to be A/S. See below for failure scenario! Define the track object and the interface to ‘track’

track [#] interface [interface name/num] line-protocol

! Combine each track object created and type them to a boolean operatortrack [#] list boolean [OR|AND]object [#]object [#]

! Tie the Tracking group to the vpc

#vpc domain [#]

#track [#]

! Tie the tracking to HSRP

#int vlan [#]

#hsrp [#]

#track [#]

! Enable self-isolation in vPC under domain config (must be enabled on both peers)

#self-isolation
```

### vPC Initialization Order of Operations

1. vPC Process Starts

2. IP/UDP 3200 Peer Keepalive connectivity established

3. Peer-Link adjacency forms

4. vPC Primary/Secondary role election

5. vPC Performs consistency checks

6. Layer 3 SVIs move to up/up

7. vPC Member ports move to up/up state

### vPC Consistency Checks

The vPC Peers perform ‘consistency checks’ to bring the vPCs link and member ports up.

1. vPC Peers sync control plane over Peer Link with Cisco Fabric Services (CFS)

2. Verifying hardware and configuration match (e.g speed, duplex, STP config, LACP mode etc.)Three types of consistency checks:

**Type 1 Global**

- Mismatch results in vPC failing to form (e.g hardware not matching, STP config not matching)

**Type 1 Interface**

- Mismatch results in VLANs being suspended on vPC member (e.g STP port type network vs. normal)

**Type 2**

- Mismatch results in syslog message but not vPC failure
- Can result in failures in the data plane (e.g MTU mismatch)

### vPC Failure Scenarios

#### vPC Member Port Failure Detection

- vPC Peers exchange vPC member status over the peerlink
- Failed Member Ports result in “orphan ports”
    - Orphan Ports are single attached ports that use a vPC VLAN
    - vPC VLANs are any VLANs allowed on the Peer Link
    - show vpc orphan-ports

#### vPC Peer Link Failure

- vPC Secondary Pings Primary over Peer Keepalive
    - If vPC Primary responds
        - Disables vPC member ports on secondary
        - Disables SVIs on Secondary
        - Goal is to force end host to forward via primary
    - if vPC Primary is dead
        - Promote vPC Secondary to Operational Primary
        - Continue to forward traffic on new Primary
- Peer Keepalive and PeerLink must not share fate in order to prevent Split Brain
    - e.g seperate MGMT Switch, seperate port channels on seperate line cards

#### vPC Auto Recovery

- Certain Failures can result in neither vPC Peers forwarding
- Power Outage with node failure problem case
    - Power outage on both Peers
    - Only one Peer is restored
    - vPC Peer Keepalive never comes up
    - Means vPC Peer Link can never come up
    - Means vPC Member Ports can never come up
    - vPC Members are isolated
- vPC Auto Recovery allows a single Peer to promote itself to Primary
    - If Peer Link does not initialize before auto recovery timeout, promote myself to primary and bring up Member ports
- Gradual Failure problem case
    - vPC Peer Link goes down
    - vPC Secondary pings vPC Primary and gets response
    - vPC Secondary Disables vPC Member Ports
    - vPC Primary completely fails
    - vPC Secondary does not re active Member Ports
    - Member ports are isolated
- vPC Auto Recovery Allows Secondary to detect this over Peer Keepalive
    - vPC Primary is continually tracked over vPC Peer Keepalive
    - Peer Keepalive failure at a later time results in Secondary promoting itself to Primary
    - Secondary re-activates its Member Ports

The default timeout for vPC Auto Recovery is 240s. After 240s, if the other peer is still not detected or reachable, it brings up the vPC member ports/the vPC (in both cases stated above).

#### vPC Orphan Port Failures Problem case:

- vPC Primary And Secondary are Default Gateways for vPC VLAN hosts
- Orphan Port exists on Secondary
- vPC Peer Link fails, but Primary remains up
- Secondary Pings Primary, gets a response
    - Disables vPC Member Ports
    - Disables SVIs
- Orphan is now isolated from its Default Gateway

The above is only a problem if the orphan is connected to the secondary when the failure of the Peer Link occurs. However, it is hard to predict when vPC Peers will be secondary or primary in a topology based on previous failures, updates etc.Fixes to the above problem:

- Dual home the orphaned port
- Single attached hosts connect to a single access switch, and then dual home the access switch to the vPC peer.
- Single attached ports could use non-vPC VLANs
    - Port only counts as orphan if it is using a vPC VLAN
    - Non-vPC VLANs require additional east/west trunk between vPC Peers
- Don’t disable SVI when Peer Link fails on Secondary
    - enable under vpc domain config:”dual-active exclude interface-vlan’

#### Problem Case 1

- Active/Standby Failover Device connects via orphan ports on to vPC Peers
- Active Device Connects to vPC (operational) Secondary
- vPC Peer Link Fails, but primary remains up
- Secondary Pings Primary, gets response
    - Disables vPC Member Ports
    - Disables SVIs
    - Active device sees port as still up/up and does not failover
    - Active device is now isolated from it’s default-gateway, and potentially L2

##### Fixes to Problem Case 1

- Run Active/Active
- Dual home each device to vPC Peers
- Force the active device to failover to the vPC Primary
    - interface level “vpc orphan-port suspend”

#### Problem Case 2

- Peer Link and northbound routing links share same linecard
- Peer Keepalive does not fate share with peerlink
- vPC Primary linecard fails
    - Peer Link is Lost
    - Northbound routing lost
- Secondary pings primary, gets reponse
    - Disables vPC Member Ports
    - Disables SVIs
- Layer 2 traffic is collected via primary, but cannot route to WAN
- Servers Isolated

##### Fixes to Problem Case 2

- Keepalive, peerlink, and routing links do not share fate
- Enhanced object tracking on primary
    - If Peer link && WAN == Down, failover to secondary
- vPC Self-Isolation
    - If peerlink && WAN == Down, tell secondary over keepalive
    - Available in nx-os 7.2 and later
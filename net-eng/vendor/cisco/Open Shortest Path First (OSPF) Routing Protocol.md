Title | Open Shortest Path First (OSPF) Routing Protocol
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Introduction

What is OSPF? OSPF is a link-state routing protocol. OSPF uses a link-state database to build a tree of all the links that live in a area. OSPF uses the concept of ‘areas’ to limit the scope of these trees. Since OSPF is a link state routing protocol, it inherently *knows* alot more about a particular topology and its links compared to a distance vector protocol. What this means is that a router running OSPF receives all this information from other OSPF routers and keeps all this data in the link-state database (not just network and prefix information – but things such as: bandwidth, L2 encapsulation, delay etc.). After it has gained all of this information, it runs the Shortest Path First (SPF) Algorithm. This algorithm calculates the cost to get to all the networks it has learned within the OSPF routing domain.

OSPF is an open standard, as in it can be implemented by multiple vendors. There are two versions of OSPF:

- Version 2: RFC 1583, and RFC 2328
- Version 3: RFC 5340

Version 2 and Version 3 are very similar. Version 3 still has the same basis of foundation as compared to Version 2. However, Version 3 has added support for IPv6. With that, Version 3 has some changes in its configuration so that it can support IPv6.

### OSPF Messages

All OSPF packets are identified with IP Protocol code 89. The code can be found in the L3 header of the packet. For dynamic learning of neighbors, the multicast address of 224.0.0.5 is used for hello packets. Unicast is usually used for requests, updates, and acknowledgements.

![https://ospfcommand.files.wordpress.com/2019/07/0ef35360-325a-4c0e-bf91-11e2d10df0e8-2.png?w=1801](https://ospfcommand.files.wordpress.com/2019/07/0ef35360-325a-4c0e-bf91-11e2d10df0e8-2.png?w=1801)

Before any routes or links are learned about, each adjacent OSPF router must first form a neighbor relationship. Below is a summary of the different types of packets that OSPF uses for neighbor-forming, and updating topology changes:

- Hello: Fundamental Packet for discovery and holding neighborships in OSPF. It also keeps key information for the formation of OSPF Neighbors. A hello packet is just a packet that is sent periodically out on an interface with OSPF enabled. It is mainly used to form neighbors and to make sure that it’s neighbor is still connected.
- Database Description (DBD): Only used in the very beginning of the neighbor relationship process. Once hellos are exchanged, DBD are exchanged soon after. DBD is kinda of like a table of contents of what each router has, but it does not provide details of each specific link.
- Link-State Request: After DBD is exchanged, routers may or may not know the details that are pointed out in the DBD exchange. So a Link State Request is sent out for that information from each router.
- Link-State Update: Link State Update is then sent in response to the request message, with the details of what is missing.
- Link-State Acknowledgement: Every Link State Update is also acknowledged, with this type of message.

### OSPF Neighborship

For a OSPF neighbor relationship to form, the following parameters (that are found in the hello packet), must match:

- Hello Interval
- Dead Interval
- Area ID
- Subnet Mask
- Stub Area Flag
- Authentication

The following *does not* have to match for OSPF to form a neighbor relationship:

- OSPF Router ID
- List of neighbors reachable on the interface
- Router Priority
- Designated Router (DR) IP Address
- Backup Designated Router (BDR) IP Address

The Hello Interval dictates how often packets are sent out, and the Dead Interval dictates how long before declaring the neighbor as down. On a LAN interface, the default value of hello interval is 10s. The dead interval is 40s. When you change the Hello Interval on an interface, the Dead Interval is automatically changed to 4x the hello interval. However, when changing the hello interval, it will cause the neighbor relationship of the other side to go down if, that is if the other side doesn’t match.

This is how you configure those intervals on a per-interface basis (Cisco):

```
! Configure hello interval

#ip ospf hello-interval [value]

! Configure dead interval

#ip ospf dead-interval [value]

! Configure sub second hello interval and dead interval

#ip ospf dead-interval minimal hello-multiplier [multiplier]

! Verify

#show ip ospf interface [name]
```

In OSPF there is a chronological list of states that OSPF must go through for neighbors to be considered fully adjacent, and those states are:

### OSPF Neighbor States

*Attempt*: You will only see this neighbor state when you are configuring static neighbors (for example on frame relay interface). Basically means that OSPF tried to send packets to statically defined neighbor but never hears anything back.

*Init*: Init state is when hello packets have been received and exchanged. However, if say the first hello has been exchanged, then the router receiving it sees in the hello packet that it does not name itself in the hello packet (basically mean’s the neighbor has not recognized you yet). Say there are 4 routers on the same broadcast domain, and you receive a hello packet from one of the routers for first time, and in the hello packet you see two other routers listed, but not yourself. This means you are in the init state. After that point the hellos will populate that field.

*2-Way*: When Hello Packets have been exchanged but they contain the name of your own router in their. This basically verifies that the other adjacent router has at the very least received your hello. During the 2 way state DR/BDR election is formed. Routers that are DROTHers in a DR/BDR election, stay in the 2-way state with other DROTHERs. They do not exchange DBD or anything else with the other DROTHERs, just the DR/BDR. More on DR/BDR later*

*Exstart*: The Exstart is started right after the 2-way state. The router goes into Exstart state as soon as the first DBD message is received. In this state, an election is held for who is master and slave for a particular router within an adjacency. This is done by both routers sending empty DBDs to each other, and their RID. The Router with the higher RID is elected the master, while the other becomes the slave. The only reason this master/slave election is used is because DBD descriptors have a sequence number in each DBD descriptor packet sent to the neighbors. DBD are sent using unicast. Whoever becomes the master starts with the first sequence number. Once the election for master and slave is done, the exstart state ends.

*Exchange*: The exchange state starts right after the first DBD is sent to it’s neighbor with all it’s headers filled. Again, the DBD is simply a table of contents of what each router knows. The router itself will most likely need to send multiple DBD packets to fully send all of it’s data to the neighbors. The neighboring router know that it received all of the DBD from it’s neighbor because the last DBD packet is flagged with a value indicating that.

*Loading*: When routers have the same view of the LSIDs, they move to the loading state (after all DBD have been exhcnaged). For any missing LSA the router missing the LSA will send a Link State Request (LSR). The router listening to LSR sends a Link State Update (LSU) back. Every LSR is accompanied by an acknowledgement as well.

*Full*: When all LSAs have been sent, received, and acknowledged – the neighbor relationship goes to the FULL state (aka fully adjacent). Database is fully populated. It is then at this point each router runs SPF to calculate the best paths for each subnet.

### OSPF Router-ID

OSPF creates router ID just like all other routing protocol. Think of a Router ID as a name for the router. Router IDs are critical to the operation of OSPF. If two routers directly connected have the same router ID they do not form a neighbor relationship, and a syslog message is generated. If they are separated by a router (and are in the same area), the neighbor relationship is still formed, but a syslog is also generated saying that their is a router ID match within a topology. If there is Router ID mismatch for routers in different areas, the routers will flush each others LSAs and declare an “OSPF Floor War”. Since every LSA is signed with their RID, having matching RIDs in a topology messes up the LSDB LSAs and sequence numbers. RID will only change if you have either no neighbors, or if the OSPF process is cleared.

Router ID Election:

- Configured in OSPF Process configuration
- Highest Loopback IP
- Highest IP address on active interface
```
! Configure router ID in OSPF configuration mode

#router-id [#]

! Verify

#show ip ospf neighbor

#show ip protocols

#show ip ospf database

### OSPF MTU Mismatch
```
Routers typically have a default IP MTU of 1500 bytes. MTU stands for Maximum Transmission Unit. It is used to indicate how big a packet can be to be forwarded out on a link. If a router needs to forward a packet larger than the outgoing interfaces MTU, it either fragments the packet or discards it. It will depend on the settings of the Don’t Fragment (DF) bit in the IP Header. If it is set (1) the packet is dropped. Otherwise, it is fragmented.  The value of MTU on OSPF neighbor links should be the same. If there is an MTU mismatch between two OSPF routers, they will not be able to exchange topology information. The neighbors will get to Exstart state, and then go down. A log message will be generated reporting “too many re transmissions”. The reason for this is because during the neighbor process where they are exchanging Database Descriptors, the MTU value is specified on each end of the link. Since that value does not match for that specific link, it will never get past that stage in the neighbor process.

### OSPF Authentication

OSPF Supports either plain-text or MD5 authentication. OSPF does not support key-chain mode like EIGRP. OSPF Authentication key must be configured statically on the interface. Interface level mode configuration takes precedence over global (aka area) mode configuration
```
! Enable authentication on an interface

#ip ospf authentication [message-digest]! Enable on all interfaces in an area by changing the area wide authentication (in global routing mode)

#area [#] authentication [message-digest]

The Authentication key can only be configured on a per interface basis, and not area wide. Three types of authentication:

- Type 0: no authentication
- Type 1: clear text authentication
- Type 2: MD5 Authentication

OSPF supports multiple keys on the same interface, but not with key-chain. If you are using multiple keys on the same interface, then MD5 authentication must be used.

! Configure key on interface for plain text

#ip ospf authentication-key [key-value]

! Configure key on interface for MD5

#ip ospf message-digest-key [key number] md5 [key value]

! Verify

#show ip ospf interface [interface]

#debug ip ospf hello

#debug ip ospf adj
```

### OSPF Network Types

OSPF does classification for every link in a topology. The classification is for determining operational characteristics of each interface:

- Whether the router will use multicast to discover neighbors
- If two or more OSPF routers can exist in the subnet attached to the interface
- Whether the router should attempt to elect an OSPF DR (More on that later*) on that interface

These items are identified by the layer-2 encapsulation of OSPF Links.

See the table below for a list of all the different network types:

![https://ospfcommand.files.wordpress.com/2019/07/ospfnetworktype-2.png?w=1801](https://ospfcommand.files.wordpress.com/2019/07/ospfnetworktype-2.png?w=1801)

**Broadcast**:

- This network type discovers neighbors automatically
- This network type supports the use of DR/BDRs
- Hello & Dead Intervals: 10/40
- Ethernet, FDDI, Token Ring
- You can ‘force’ network type by using the #ip ospf network broadcast command on the interface level

**Non-Broadcast:**

- This network does not discover neighbors dynamically
- Intervals: 30&120
- Neighbors must be statically configured:#neighbor ip-address [priority priority]

The neighbor command can work with just one side of a link configured.

Consider the following frame-relay configuration:
```

interface Serial0

encapsulation frame-relay

no shut

ip address x.x.x.x

ip ospf 1 area x
```
In the above interface configuration, OSPF would ‘guess’ that this interface is a Non-Broadcast Multi-Access link. Since frame-relay can have multiple, DLCIs on it, it makes the assumption based on that. OSPF itself does not have knowledge of the DLCI config on a frame-relay interface. Since it is a non-broadcast multiaccess link, multicast is not supported on that type of interface. So neighbors HAVE to be statically configured to form a neighbor relationships. You can however configure that interface as a broadcast link with the ip ospf network broadcast command. You still have to make DLCI mapping on the frame relay end so that router knows where to put those multicast packets. When doing this type of setup there has to be a full mesh where every router has a full mesh to every other router in a frame relay cloud.

Now consider the following frame-relay configuration:
```
interface Serial0

encapsulation frame-relay

no shut

interface Serial 0.101 [point-to-point|multipoint]

ip address x.x.x.x

ip ospf 1 area x
```
In the above configuration, OSPF still thinks and views this as a Broadcast Multi-access link, even though the OSPF process has been enabled on sub interface. The reason is because it sees the multipoint keyword in sub interface and makes a decision based on that. The previous example ‘guesses’ that its a NBMA link, despite it possibly being point to point.

**Point-To-Point**:

- This network type does not elect a DR/BDR
- This network type discovers neighbors dynamically
- Interval: 10&40
- To configure an interface as p2p: #ip ospf network point-to-point

**Point-To-Multipoint:**

- This network type does not elect a DR/BDR
- This network type discovers neighbor dynamically
- Intervals: 30&120
- Must be manually set with: #ip ospf network point-to-multipoint

How does point to multipoint network type help with a partial mesh topology:

- Regardless of actual mask, each router advertises /32 LSAs for its connectivity to frame relay cloud
- LSAs received on a P-2-MP sub interface are allowed to be flooded right back out the same interface to other neighbors (effectively split horizon is disabled because it goes to different DLCIs)

Changing a broadcast network into a point to multipoint network can have certain advantages. Static neighbor configuration can allow per-neighbor cost configuration. This is done using the neighbor x.x.x.x cost [x] command. Usually the cost is derived from the interface it connects to (fast ethernet, serial etc). However, with point to multi point non broadcast you can specify cost PER NEIGHBOR, and not per interface.

How to memorize OSPF network types:

- Any network types with keyword nonbroadcast basically means that they cannot discover neighbors dynamically and must use static configuration of neighbors.
- If network starts with point it doesn’t use a DR/BDR
- Only broadcast and point to point use faster timers of hello 10 dead 40.

### What is DR/BDR?

DR stands for Designated Router and BDR stands for Backup Designated Router. On a link with OSPF enabled, if it classified as broadcast or non-broadcast link then a DR/BDR election is initiated. The reason is because on these *types* of links there is the possibility of more than two (2) other OSPF routers living on it. By electing a DR/BDR, these two routers act as the “hub” for the neighbor relationships on this link. The benefit is that it reduces LSA flooding and neighborship overhead.

DR/BDR are elected based on information in OSPF hello packet. Hello packet lists each routers RID and a priority value. Who ever has a high priority, gets elected the DR, with BDR being second highest priority. If priority is same then the highest RID is used to elect a DR. A DR stays the DR aslong as it is connected to the LAN and neighbor relationship doesn’t go down, even if a new router is added to the link with a higher priority/RID. Once the DR goes down, the BDR becomes the DR, and a new BDR is elected (if there is one).

You can configure the priority on a per interface basis:

`#ip ospf priority [value]`

DR/BDR for a particular segment use the multicast address 224.0.0.6 instead of 224.0.0.5. DR and BDRs ONLY listen to 224.0.0.6 multicast addresses. The 224.0.0.6 multicast address is only used for multicasts going TO the DR/BDR. The DR itself will send DBD to the multicast address of 224.0.0.5. The DR is the only router that forms a FULL neighbor relationship with all other routers on the segment. The others routers (called DROTHERS) stay in 2-way state with each other.

### OSPF Areas

OSPF implement the concept of areas in the protocol itself. When you enable OSPF on a routers interface, you have to explicitly state which area it is a part of. The area identification is a numeric number from 0-255. There is no specific criteria to use certain numbers, however, there is one cardinal rule about OSPF areas: All non-backbone areas must hook up to the backbone area. The backbone area is Area 0. Non-backbone areas are any areas that are not Area 0. Each area in a OSPF domain has its own Link State Database, and its own SPF calculation for how to get to routers within its area. An Area Border Router (ABR) is a router that has 2 links in more than one area. Any link changes in a particular area do not force a SPF re-calculation in other areas. When designing out OSPF for a network, knowing how areas work is extremely effective. You want to use area separation so that not every router in your topology is forcing a SPF recalculations. Separating your links into areas creates opportunities for route manipulation and prefix summarization.

Each OSPF interface is placed in an area. A router within an area send LSAs for everyone in that area. Each router has a link state database where it keeps tracks of all the LSAs it learns. Each router in an area builds a ‘tree’ of what the topology looks like with all the LSAs it receives and places it in the link state database. Everytime a LSA is received on a router, the links that are based on that are torn down and rebuilt, factoring in the new LSA.

### OSPF Router Roles

**Area Border Router (ABR)** – Any router that connects to more than one area

**Autonomous System Border Router (ASBR)** – any router that connects multiple AS’s together (via redistribute command)

**Designated Router (DR)** – In every broadcast domain a router is elected as a DR. A DR is responsible for receiving Type 1 and Type 2 LSAs from multicast address 224.0.0.6 and sending those LSAs back out into the area to 224.0.0.5. A router is elected a DR if it is the first router on that segment. If they are powered on at same time, then higher OSPF priority is elected the DR. If the priority is the same, the router with highest router id is elected the DR.

**Backup Designated Router (BDR)** – In every broadcast domain a router is elected as a BDR. A BDR is simply a backup to a DR. The router with second lowest DR becomes a BDR.

**DROTHERS** – Routers that are not elected a DR or a BDR. These routers stay in 2-way neighbor state between each other.

### OSPF Link-State Advertisements (LSAs)

In OSPF each router stores data which is composed of individual link-state advertisments (LSAs) in it’s Link State Database (LSDB).

Each router within an OSPF area must have the same link state database information. In addition there are two LSDBs if a router belongs to more than one area.

Each router individually runs the Shortest Path First (SPF) Algorithm. This Algorithm runs each time for each area a router is a part of. Each router considers itself to be the root of the tree and ‘draws’ its branches towards each of the destination via the shortest path. LSAs in OSPF LSDB are like pieces of a puzzle. The SPF process must examine the individual LSAs and see how they fit together based on their characteristics.

### Types of LSAs

**Type 1 Router LSA**: Router LSA is a fundamental LSA for creating the so-called tree that OSPF uses to calculate via SPF Algorithm. This LSA is generated to describe the interfaces connected on a particular router running OSPF. One LSA is generated per area per router. In the body of one LSA, is the combination of one or more sub headers for all the interfaces in that particular area. The LSA is then flooded to all other routers in a particular area. The Router LSA is fundamentally just a description of the interface for that particular router, and associated via the router ID. When another router in an area receives Type 1 LSA, it associates the links with the Router ID of the other router. Type 1 LSA does not go beyond its own area.

To view Type 1 LSAs use the following command: #show ip ospf database router [RID]

LS Sequence Number is a number to identify quote on quote the version of the LSA. If say a IP address changes on an interface participating in OSPF, OSPF first poisons the route by sending an update to that LSA Sequence number with an age of 60m. This effectively kills that LSA, and the new LSA with the new sequence number is used instead.

OSPF identifies a Type 1 LSA using a 32 bit link state identifier (LSID). Each router then uses its own OSPF router id as the LSID.

Each LSA (associated with a LSID) will then have link data for each interface depending on the type of interface:

- Interface with no neighbors: 1. Its subnet number/mask is advertised 2. Described as a ‘stub network’
- Interface with DR: 1. The IP address of the DR 2. Link connected to a ‘transit network’
- Interface with no DR: 1. it lists the neighbors RID 2. Link connected to ‘another router (point to point)’ 3. Point to point interface also create a second Link Data describing the network as a stub network, with the subnet and mask included.

**Type 2 Network LSA**: ****Type 2 LSA is generated for multi access networks. It is required for OSPF to properly map all connected routers to a single multi access network, like a LAN. The generation of a type 2 LSA depends on the existence of a DR. Only the DR in a particular multi access network creates this LSA. All other routers (BDRs and DROTHERs) do not. The LSA is flooded by the DR to all other routers in the area. The content of the LSA is the subnet, mask, and all the participating routers in that broadcast domain (RIDs).

A type 2 LSA is not generated for a link that is connected to a stub network (or a network with only one router on it). However, once you form a  neighbor relationship on a multi access link then a type 2 LSA is flooded within the area.
```
! To view a Type 2 LSA

#sh ip ospf database network
```

**Type 3 Network Summary LSA**: Type 3 LSA are not generated in single area deployments of OSPF. You will only see a type 3 LSA if you include more than one area.

Area Border Routers (ABRs) are used to connect different OSPF areas  together. ABRs do not forward the type 1 and type 2 LSAs on to other areas. ABRs generate a Type 3 LSA for each subnet in a particular area  and they are advertised out to another area. The Type 3 LSA only contains subnet and route information, no details of links. A type 3 LSA consists of each subnet and a cost to reach that subnet from that ABR. A Type 3 LSA does not initiate a SPF recalculation.

The ABR assigns an LSID of the subnet number being advertised. The ABR also adds its own RID in the LSA, because multiple ABRs can advertise the same subnet with the same LSID.
```
! To view a Type 3 LSA

#sh ip ospf database summary
```

**Type 4 ASBR Summary LSAB:** This LSA is generated by Area Border Routers (ABRs). This LSA is created when a Type 5 LSA is also advertised throughout the whole OSPF domain. Since the type 5 LSA is advertise throughout the whole OSPF domain (past all areas), routers in other areas cannot calculate how to get other areas wherever the ASBR might live. So what Area Border Routers (ABRs) do is create a Type 4 LSA, saying “Hey, I know how to get to the ASBR in this non-transit area, go through me”. This LSA simply states: “to reach the ASBR Router-ID, come through my Router-ID”

**Type 5: AS External LSA**: The Type 5 LSA is an LSA generated by ASBRs when redistributing routes from outside the OSPF Domain into OSPF. Whoever is doing the redistributing then becomes an ASBR. They are flooded within the entire OSPF domain, unchanged.

A Type 5 LSA has two sub types:

- Sub-Type-1 tells all routers receiving this Type 5 LSA to allow cost calculation on this LSA.

- Sub-Type-2 tells all routers receiving this Type 5 LSA to NOT allow cost calculations on this LSA. This tells the router to install this LSA with original cost that the ASBR was advertising and do not add cost calculation.

**Type 6 Group Membership LSA**:

**Type 7 NSSA External LSA**: The Type 7 LSA is a LSA generated when a router (ASBR) within a NSSA, is redistributing routes into OSPF. This LSA is Flooded within the area, and learned by every router. Once the Type 7 is reached to an ABR, that Type 7 is converted to a Type 5 for the other areas to learn.

**Type 8 External Attributes LSA**:

**Type 9-11 Opaque LSA**:

Each LSA has a age timer of 30m. When no changes to an LSA occur for 30m, the owning router increments the sequence number, resets the timer to 0, and re-floods the LSA.

LSAs are poisoned by flooding the LSA to it’s neighbor and setting the timer to the max age setting (3600s).

### Enabling OSPF (V2 and V3) on Cisco

You can enable OSPF on interface in two ways:

- With the *network* command (under routing config)
- With the `ip ospf [process] area [num]` command (under interface config)

```
! Enable OSPFv2 routing with certain process number. You can run multiple instances of OSPF if desired. The number here is only locally significant.

#router ospf [number]

! Enable an interface with the network command. This command tells the router to look for any interfaces that start with the network address and enable OSPF on that interface. This automatically makes the interface start sending hellos out on the interface, and *also* advertising that network into the OSPF domain (that is, if it has any adjacent neighbors). The network command also specifies the area number of where the link resides.

#network [network address] [wildcard mask] [area #]

! Enable OSPFv3 routing with certain process number. Again, the number is only locally significant.

#router ospfv3 [number]

! Enable an interface with the ip/ipv6 ospf command in interface configuration

#ip ospf [process-id] area [number]

#ipv6 ospf [process-id] area [number]

! Verification

#debug ip ospf adj

#sh ip ospf neigh

#sh ip ospf interface

#sh ip protocols

#sh ipv6 ospf interface brief

#sh ipv6 ospf neigh

#sh ipv6 ospf database

#sh ipv6 protocols

#debug ipv6 ospf adj
```

### OSPF Path Selection

OSPF analyzes each route it receives and determines the best path for each route by doing a metric calculation. OSPF calculates the metric by doing the following:

- Analyze the LSDB to find all possible routes to reach a particular subnet
- For each possible route, add the OSPF interface cost for all outgoing interfaces in that route.
- Pick the route with the lowest total cost.

The OSPF Cost is a metric derived from the egress interface bandwidth.
```
! View OSPF Cost for an interface running OSPF

#show ip ospf interface
```
Intra-Area is when routes/traffic are *inside* the area itself. Inter-Area is when routes/traffic are *outside* the area. The terms are used to describe traffic that is flowing internal to an area or flowing through other areas.

**Intra-Area**

To calculate the best route to each subnet, a router analyzes the LSDB and does the following:

- Finds all subnets inside the area, based on the stub interfaces listed in the Type 1 LSA and based on any Type 2 Network LSAs.
- Run SPF to find all possible paths through the area topology.
- Calculates the OSPF interface costs for all outgoing interfaces in each route, picking the lowest total cost route for each subnet as the best route.

**Inter-Area**

An ABR advertises a Type 3 Summary LSA to adjacent areas. The way the neighbors in accompanying areas calculate the cost is by adding the cost that is advertised in that LSA, to the cost it takes to get to that ABR. It uses the same method as inter-area, but adds the cost to get to the ABR as well as adding the cost of the Type 3 Summary LSA.

Priority of route selection:

- Intra-Area (Received a Type 1 LSA/Type 2 LSA)
- Inter-Area (Received a Type 3 LSA)
- External (Type 5 LSA or Type 7 LSA)

There are 3 ways to change the OSPF Cost/Metric:

- Changing the reference bandwidth
- Setting bandwidth
- Configuring cost directly

OSPF Calculates the OSPF cost for an interface based on the following formula: reference-bandwidth / interface bandwidth = OSPF Cost

The default reference bandwidth on *all* interfaces is 100Mbps.

The reference bandwidth can be changed using the following command: #auto-cost reference bandwidth [#]

This command is only locally significant to the router, because it calculates the cost after the fact.

The bandwidth can be changed using the following command: #bandwidth [#]

Other routing processes such as QOS and other routing protocols use this command as well to influence their operations.

The cost can be changed directly using the following command: #ip ospf cost [value]

### OSPF Stub Areas

In OSPF there are four (4) variation of stub areas:

- Stubby Area
- Totally Stubby Area
- Not-So-Stubby-Area (NSSA)
- Totally Not-So-Stubby Area (NSSA)

All types of stubby areas filter the Type 5 External LSA. Any area that starts with ‘Totally’ means that the ABR also filters out Type 3 LSAs. Any area that does not start with ‘Totally’ means that Type 3 LSAs are allowed to be learned and advertised in the area by the ABR.

Any other area besides Area 0 can be defined as a stub area. A stub area allows the routers in an area to use default routes for forwarding packets to the ABR rather than specific routes. The ABR injects a default rout into the stub area. All Type 5 LSAs will not be advertised into the stub area. ABRs create a default route using a Type 3 LSA and flood that into the Stub area. The default route has a metric of 1 unless otherwise configured using the command area [area-number] default-cost [cost]When configuring stubby areas, all routers must be configured as a stub area. If not then neighbor relationships will not be formed. This is based on the Stub flag in the hello packet. Any router in a stub area cannot become an ASBR. The reason for this is because all the routers in a stub area have agreed that no Type 5 LSAs can be created or advertised into the area. Creating an ASBR in the area goes against that rule.
```
! Configure an area as a Stub Area in router config. This command should be configured on all routers in the area.

#area [area-number] stub

! Specify metric for default route that ABR injects.

#area [area-number] default-metric [metric]

! Configure an area as a Totally Stub Area. This command only needs to be done on the ABR because it is the only router in an area that creates a Type 3 LSA.

#area [area-number] stub no-summary
```
Not-So-Stubby-Area (NSSA) are areas that allow any router in that area to become an ASBR with the help of a Type 7 LSA. With the stub/totally stubby areas, it was not allowed for those routers to become ASBRs because all Type 5s are filtered into all types of stub areas. So the way that this is solved is by using a Type 7 LSA, which has the exact same contents as a Type 5 LSA. The Type 7 LSA is only generated on ASBRs in NSSAs. The Type 7 is flooded by the ASBR within the entire NSSA. However, once it reaches an ABR, that Type 7 is then converted into a Type 5 LSA and flooded out. NSSA area must be configured on *all* routers in the area. When configuring NSSA the ‘NSSA is Supported’ bit is set. OSPF routers will not form a neighbor relationship if one side is a stub and the other is a NSSA.When configuring NSSA (as compared to Stub/Totally stub areas), a Type 3 LSA of all 0s (aka default route) is *not* injected automatically into the NSSA. An Extra command is needed to configure this: area [area-number] nssa default-information originate
```
! Configure a NSSA in router config

#area [area-number] nssa

! Configure a Totally NSSA in router config. This only needs to be done on the ABR

#area [area-number] nssa no-summary

! Configure default route into a NSSA

#area [area-number] nssa default-information originate

! Verify

#show ip ospf

#show ip ospf database

#show ip ospf database database-summary
```
### OSPF Route Summarization

OSPF allows summarization at ABRs or ASBRs. The reason for this is because all OSPF routers in an area must have the same exact LSDB. Summarization is done on LSAs *not* on routes. Summarization can be done to reduce the size of the LSDB (save memory, CPU etc). Summarization can also be used for path manipulation.
```
! Configure summarization on an ABR, use the following command in routing config

#area [area id] range [ip address] [mask] [cost [#]]
```
The configured area number refers to the area where the subnet you want to summarize exists. The summary will be advertised into all other areas connected to the area. There should be at least one subordinate subnet inside the range of the summary route for the summary route to actually be advertised. The ABR does not advertise the subordinate subnet Type 3 LSAs, only the summarized version of the Type 3 LSA. The ABR assigns a metric for the summary routes Type 3 LSA by default to match the best metric among all subordinate routes (AKA the lowest metric). The area range command can also explicitly set the cost of the summary (instead of whatever is route has the lowest metric).
```
! Configure summarization at an ASBR under router config

#summary-address [prefix] [mask]
```
### OSPF Default Routing

There are two ways to introduce a default route into OSPF, either within a specific area or throughout the whole OSPF domain.
```
! Configure default route across *all* areas, use the default-information originate command in routing config

#default-information orignate [always] [metric [metric-value]] [metric-type [metric-type]] [route-map [map-name]]
```
If you just type default-information originate, then the router will look into its routing table and if it has any route that starts with all 0s (aka a default route) then the router will give permission to OSPF to create a Type 5 LSA and flood it through the whole entire OSPF Domain. The always keyword does not do the initial check if there is an all 0s route in the routing table, it will just create the LSA and flood it regardless if you have a default route learned or configured.

When all the default parameters of this command are used, this command injects a default route into OSPF as a Type 2 route, using a Type 5 LSA with a metric of 1. A Type 5 LSA has two different types. A sub-Type 1 and a sub-Type 2. A Type 1 tells all the routers it gets to that it *can* modify the metric as it goes through each router. A Type 2 tells all the routers *to not* modify the metric and leaved it unchanged throughout the whole OSPF domain. OSPF by default makes all external routes a cost of 1 (for static and IGPs). You can also use route map in the default-information originate command to ‘track’ routes in your routing table. If the route disappears, then the Type 5 LSA will be poisoned.

### OSPF Route Filtering

Routers in the same area MUST have the same LSAs in their LSDB. Therefore it’s impossible to filter routes that are learned within an area. OSPF can filter the origination of an LSA BETWEEN areas. This is accomplished by telling the border router to not generate type 3/5 LSAs all together. Type 3 LSAs are filtered by ABRs, type 5 LSAs are filter by ASBRs. Type 3 LSAs are filtered PRIOR to origination.
```
! Configure type 3 LSA filtering on ABRs using prefix lists:

#area [#] filter-list prefix [name] [in|out]
```
When ‘in’ is configured, IOS filters prefixes being created and flooded into the configured area

When ‘out’ is configured, IOS filters prefixes coming out of the configured area
```
! Configure area range for filtering

#area [#] range [x.x.x.x] [mask] not-advertise
```
Not advertise keyword turns the area range command (usually used for summarization) into a filtering mechanism. Does not require prefix list or ACL. The big difference between this command compared to the area filter list command is that the area range command looks at the type1 and type2 LSAs for the range that you specify. If the area does not have a type 1 or type 2 LSA for that range, it will not filter it. So this command only works if you are filtering traffic that are directly filtering OSPF routes into the routing table (instead of filtering the LSAs)

Filtering this way essentially filters routes being learned into the routing table. It does not stop the generation or learning of LSAs in anyway. To accomplish this filtering a distribute list is used.
Title | Border Gateway Protocol (BGP) Fundamentals
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-17-2023


## Introduction

BGP is the premier routing protocol that runs on the internet. It is used by many (if not all) Internet Providers across the globe. BGP is designed as a Exterior Gateway Protocol (EGP). BGP is actually the *only* EGP that is standardized across the internet. In earlier years, EGP (not to be confused with the *category* EGP as previously stated) was the first routing protocol developed to communicate network reachability between two Autonomous Systems. BGP was developed as an extension of EGP, improving upon it. BGP is defined in RFC 1771/4271. The other category of routing protocols is an Interior Gateway Protocol (IGP). This includes protocols such as OSPF, EIGRP, and RIP. IGPs are meant to be run within a single Autonomous System. However for BGP, it is meant to be run *between* two Autonomous Systems.

BGP has a best-path algorithm to determine the best route for a particular destination. A total of up to 14 checks for each route are learned from BGP to determine what is the best path for a given prefix. In contrast, IGPs really only use Adminstrative Distance (AD) and Cost to determine the best path for a given destination. In this way, BGP is very flexible in influencing its route selection. BGP, by default, does not do any type of load balancing. BGP advertises prefixes/length – otherwise known as Network Layer Reachability Information (NLRI). The Term NLRI is used within the protocol to describe certain prefixes.

## IGPs comparison with BGP

BGP needs to form a neighbor relationship just like IGPs. However, BGP neighbors must be configured *statically*. There is no way to dynamically learn of neighbor in BGP. BGP advertises prefixes just like other IGPs, and also advertises the next hop for those prefixes. Another interesting thing about BGP is that neighbors do not have to be directly connected with each other. Two routers running BGP can form a neighbor relationship across multiple subnets. All BGP communications with its neighbor use unicast TCP packets on port 179. This is a big difference with most IGPs because IGPs use multicast packets to dynamically learn of and advertise subnets. BGP advertise things called Path-Attributes for each prefix/length to its neighbors so that the routers can make a best-path selection. In comparison, IGPs have to advertise their metric/cost. BGP uses Path Vector Logic, that is similar to IGPs running Distance Vector. BGP emphasizes scalability in its design. It is not nearly as fast compared to IGPs. But it was not designed for that. BGP was designed for mass scale routing across the internet.

## iBGP and eBGP

There are two types of neighbors in BGP: Internal BGP (iBGP) or External (eBGP) neighbors. When two neighbors are in the *same* Autonomous System they are considered iBGP neighbors, while if two neighbors are in *different* Autonomous Systems they are considered eBGP neighbors. BGP behaves differently in several ways depending if it is a iBGP neighbor or eBGP neighbor. In addition, the neighborship requirements are different for routers wanting to be iBGP/eBGP neighbors. When BGP sends prefix updates to its neighbor it updates the AS Path Attribute depending on what type neighbor it is sending the update to. When a router is sending a prefix to a iBGP neighbor, it does *not* update the AS Path Attribute because the Autonomous System number is the same between the two neighbors. However for eBGP it updates the AS Path Attribute because it is moving from one Autonomous System to another Autonomous System.

The AS_Path attribute in BGP essentially tells the router receiving a BGP update what Autonomous System the updates went to before getting received by said router. The reason eBGP updates the AS path attribute is because eBGP neighbors are not in the same AS, so they update it to reflect what AS it’s going to. When a BGP router is modifying the AS Path to send to another eBGP neighbor, it adds that AS path (aka the latest) in the front of the list (aka on the left). So if you see a route that says : `x.x.x.x/24 23 4000 56 702`, the last time that route got an update was through AS `23`. The next AS ‘hop’ for the update is `4000` and so on.

## Autonomous System

We have mentioned Autonomous Systems but haven’t given them much attention to them. So what is an Autonomous System? An Autonomous System is a single organizational unit that administers and controls the networks related to said entity. An example would be the IT organization for a e-commerce website. Every company has it’s own network that it administers, and thats what a Autonomous System is. In regards to configuration, an Autonomous System is simply a number in BGP. For the rest of the article Autonomous System/Autonomous System number will be abbreviated to AS/ASN. AS numbers were first identified as 16-bit intergers. However it was then extended to a 32-bit interger in RFC 4893. There are a few ways to write the number (hexadecimal, asplain, or asdot).

There are two kinds of AS Numbers: Public and Private

- Public AS number can be advertised over the internet.
- Private AS number are not advertised over the internet. Can only be internally used.

The ranges of Public and Private AS Numbers:

- Public: 1-64495, 131072-4199999999
- Private: 65512-65534, 4200000000-4294967294

All other numbers in the 0 to 4294967295 range are reserved.

## BGP Neighborship

! Start BGP with configuring the ASN

`#router bgp [ASN]`

! Configure a statically defined neighbor, and specify the remote ASN that the neighbor has

`#neighbor [ip address] remote-as [asn]`

To complete a neighbor relationship this has to be configured on both sides of the link.

Requirements to form a BGP neighborship:

- The local routers ASN must match the neighboring routers reference to the ASN with the neighbor remote-asn command
- The peers IP Address must be reachable via Connected, static or IGP route.
- The BGP Router IDs must not be the same between the two neighbors. BGP elects a router ID in similar fashion to other IGPs: 1. Use Setting from router-id command 2.Choose highest numeric IP on loopback interface 3. Choose the highest numeric IP Address on any non loopback interface.
- If configured, MD5 authentication must pass. This can be configured via the `neighbor [ip address] password [key]` command.
- Each router must be able to complete a TCP 3-way handshake with the BGP Peer.
- The source IP address used to reach that peer must match the peers BGP neighbor command.

When using the neighbor remote-as command, the source address is going to be the interface of wherever that route is pointing to. For redundancy purposes you can change the source interface of the BGP packet to something like a loopback. Changing it to a loopback interface makes it more redundant because it does not rely on an interface to be up to form a neighbor relationship. You can also have two neighbor statements going to the same router, one going to one link and the other link going to another link (different IPs, so there will be two neighbor statements). This will consume double the memory and CPU utilization on each router because even though the router has neighborship with the same box, it will receive the routes on both links.

When a rotuer is trying to form an eBGP neighbor relationship, by default all eBGP messages have a TTL of 1. You can disable this using the `neighbor [ip address] ebgp-multihop` command. This command changes the TTL from 1 to 255. To change the source interface of BGP packets use the `neighbor [ip address] update-source [interface]`.

! Configure an eBGP neighbor for multihop (increases TTL)

`#neighbor [ip address] ebgp-multihop`

! Force a router to use its source address for BGP packets to use the specified interface

`#neighbor [ip address] update-source [interface]`

! Verify

`#show ip bgp summary`

## iBGP vs eBGP Neighborship Differences

The only difference between iBGP and eBGP neighbors is that iBGP neighbors have the *same* ASN between the two routers connecting each other. eBGP neighbors have *different* ASN numbers connecting each other. The other difference is that the TTL value for iBGP neighbors is 255 by default. With eBGP, the TTL by default was 1 and needed to be changed to higher number so that it can communicate with routers multiple hops away. The configuration between an iBGP and eBGP relationship is the same.

## BGP Neighbor States

There are various states that BGP goes through when forming a neighbor relationship with another BGP router. These states are the following:

- **Idle** – The BGP process is either administratively down or awaiting the next retry attempt.
- **Connect** – The BGP process is waiting for the TCP connection to be completed. During this state the BGP router is *actively* trying to start a TCP session with the other neighbor. The connect-retry timer is started during this stage. If the connect-retry timer hits 0, and the TCP session was never able to finish, then the neighbor state will move to Active.
- **Active** – The TCP connection failed during the Connect state, the connect-retry timer is started again, only this time it is *passively* listening for incoming TCP connection. The connection-re-try timer is a timer that specifies how long the BGP neighbor will try to establish a TCP session, and once the timer is reached during the connect state, the BGP routers stop trying to *actively* make a TCP session. During the active state, the router *passively* listens for incoming TCP messages. However, this implementation is based on the router/manufacturer. Ultimately the Active State means that the TCP 3-way handshake failed.
- **Opensent** – The TCP connection exists, and a BGP Open Messages has been sent to the peer but the matching Open Messages has not yet been received from the other router.
- **Openconfirm** – An Open message has been both sent to and received from the other router.
- **Established** – All neighbors parameters match. The neighbor relationship works, and the peers can now exchange Update messages.

## BGP Message Types

Every header of a BGP packet is the same. BGP messages are carried inside a TCP/IP header.  It contains marker, length and type field. Marker field contains authentication if configured. If not it is all 1s. Type field contains a number to identify if it is a open, update, keepalive or notification message.

![https://ospfcommand.files.wordpress.com/2019/08/image.png?w=1801](https://ospfcommand.files.wordpress.com/2019/08/image.png?w=1801)

BGP uses four (4) types of emssages:

- Open
- Update
- Keepalive
- Notification

**BGP Open Message**

- Used in neighborship establishment
- BGP values and capabilities exchanged

![https://ospfcommand.files.wordpress.com/2019/08/image-1.png?w=1801](https://ospfcommand.files.wordpress.com/2019/08/image-1.png?w=1801)

**BGP Update Message**

- Informs neighbors about withdrawn routes, changed routes, and new routes
- Used to exchange PAs (Path Attributes) and the associated prefix-length (NLRI) that use those attributes

![https://ospfcommand.files.wordpress.com/2019/08/image-2.png?w=1801](https://ospfcommand.files.wordpress.com/2019/08/image-2.png?w=1801)

TLV stands for Type Length Value. The TLV value is a number that tells you what type of path attribute is following. NLRI stands for Network Layer Reachability.  Since Path Attributes, and Withdraw routes field can vary in size they are accompanied each by a length field to specify how big they are.

**BGP Notification Message**

- Used to signal a BGP error
- Typically results in reset of neighbor relationship

![https://ospfcommand.files.wordpress.com/2019/08/image-3.png?w=1801](https://ospfcommand.files.wordpress.com/2019/08/image-3.png?w=1801)

**BGP Keepalive Message**

- Sent on a periodic basis to maintain the neighbor relationship. The lack of receipt of a keepalive message within the negotiated hold time causes BGP to bring down the neighbor connection.
- Only contains the BGP Header

![https://ospfcommand.files.wordpress.com/2019/08/image-4.png?w=1801](https://ospfcommand.files.wordpress.com/2019/08/image-4.png?w=1801)

## BGP Table & Path Attributes

BGP has a table that it stores and keeps all of its routes. It is called the BGP table. You can view the table by issuing show ip bgp. The output will list all the BGP learned routes (locally injected plus learned routes). This command will only show a high level view of the table and not the details of each entry.

The output of show ip bgp displays a high level overview of all the routes learned via BGP. To the left of the Network Column there are various codes to help identify the route:

- – Means it is a valid route and can be installed in the routing table
- \> Means the best route BGP has discovered for that specific prefix
- r Means that there is a failure to put this prefix in the IP routing table (Better route already in routing table, Routing table is maxed (memory is full), VRF routing table limit succeeded)
- i Means that it learned about this prefix from a iBGP neighbor

A next hop of `0.0.0.0` means that the local router advertises this either via network or redistribution command. The Path Column shows the AS path that the particular prefix was learned from. A ? means that the prefix was locally learned within the routers AS.

! Verify BGP Learned Routes

```

#show ip bgp [prefix/subnet]

#show ip bgp neighbors [ip address] received-routes

#show ip bgp neighbors [ip address] routes

#show ip bgp neighbors [ip address] advertised-routes

#show ip bgp summary
```

BGP uses multiple path attributes to determine best path for a certain prefix. By default, if no BGP PAs have been explicitly set, BGP routers use the BGP AS_PATH (autonomous system path) PA when choosing the best route among many competing routes. The AS_PATH attribute is also used to prevent routing loops. If a router receives a BGP Update and the AS_PATH (or AS_SET) has an autonomous number that is the same as its own, it will drop it. AS_SEQ is a component of the AS_PATH attribute also. The AS_SEQ is simply the list of ASs a BGP prefix goes through in order. When route summarization is performed on routes coming from multiple ASs, then something called an AS_SET is used. AS_SET is simply all the ASes that are in that summarization. However, since it cannot decipher the order it just lists them out in brackets like so {6 8 2 5}.

## Injecting Routes into BGP

There are three (3) ways to inject routes into BGP:

- By using the BGP `network` command
- By using redistribution
- By using route summarization

The network command for BGP is different than IGPs. It does not “turn on” BGP on an interface, nor does it allow for dynamic neighborship of BGP on interface (BGP has to have static neighbors anyways). It also doesn’t allow hellos on the interface (BGP uses keepalives). The `network` command in BGP looks for the *exact* prefix/length matches in the IP routing table, and originates that prefix into the BGP table. It does not matter if it is a directly connected, static, or IGP route. Aslong as the route lives in the routing table and it is not a BGP route, the network command will take that route and convert it into BGP.

! To inject a route into BGP, use the following command in BGP config mode. The mask is optional. If the mask is omitted then the router assumes a classful boundary.

`#network [subnet] mask [mask]`

There is also the auto-summary command in BGP. The auto-summary command does not affect any network commands with the mask command included. The specific mask specified for the prefix will look into the routing table and advertise only that specific prefix/length. If the mask command is ommited, then the auto-summary command will advertise the classful route.

The classful route is added if:

- The exact classful route is in the routing table

AND

- Any subset routes of that classful network are in the routing table

The second way to inject routes into BGP is by using redistribution command in BGP router config mode. This essentially does the same thing as the network command however it has the option of injecting alot more at once.

! Configure redistribution in BGP router config mode

`#redistribute [static|ospf|eigrp|rip|connected]`

This command has many other options like implementing route-maps and metrics. However, that is out of the scope for this article.

The third way to add routes into BGP is by using summarization. This aggregates several smaller subnets into a larger subnet and advertised out as one prefix rather than multiple individual ones.

! Configure the prefix to be sent out as a BGP Update with accompanying length

`#aggregate-address [prefix] [prefix-length] [summary-only]`

If you do not specify the summary-only command then BGP will advertise the summarized routes *and* the specific routes. Specifying summary-only only advertises the summary routes to its neighbor. This command has to be accompanied by a matching network or redistribute command to successfully send the summary. Applying this command alone will not create the route even if it is in your routing table.

### BGP Advertising

BGP has two rules for advertising routes to its peers:

- Only advertise the best route in any BGP Update (BGP will never send an update with two possible next hops)
- Do not advertise iBGP learned routes to iBGP Peers

By default a router running BGP will only send networks it originates to its neighboring iBGP router. Once the neighboring router receives those networks, it will not send it on to other iBGP neighbors. The reason is to prevent routing loops. When routes are advertised to iBGP neighbors, the AS_PATH attribute remains the same (thus BGP identifies it as a loop). So by default iBGP neighbors don’t send non-locally generated routes to other iBGP neighbors. This behavior can be changed with configuration, however.

When BGP advertises a prefix to an eBGP neighbor, the next hop IP address is changed by the advertising router. However, when iBGP advertises a prefix to an iBGP neighbor, the next hop IP address is *not* changed (this behavior is configurable/can be changed). Routes learned from eBGP neighbors can pass through multiple iBGP neighbors. However, since they pass through iBGP neighbors the next hop *does not* change. This can cause issues because since the next-hop IP address is not changed, routers receiving it may or may not have IP reachability to the next hop IP address advertised. Everytime a BGP update is received on a BGP Router (iBGP or eBGP) BGP will look into its IP routing table and see if the next-hop IP address is reachable. If it is not it will not install that BGP route into the routing table.

If a router running BGP receives an update from an iBGP neighbor, and the next hop IP address is not reachable then:

- iBGP-learned routes will not be installed in IP Routing Table
- iBGP-learned routes will not be advertised to any other BGP Peers
- Viewable via the show ip bgp prefix/length command as inaccessible

There are a few ways to resolve this issue:

- Advertise those IP addresses into the internal network (static route, IGP)
- Use the `neighbor next-hop-self` command

The `neighbor next-hop-self` command changes the next-hop IP address to the source address of the neighbor statement you have with your iBGP neighbor. By default, as stated previously, when iBGP neighbors send updates the next-hop IP address is unchanged. This command forces it to change to the source address of the neighbor interface.

! Configure a iBGP neighbor to send the next-hop IP address of it’s source interface of neighbor relationship in the update message

`#neighbor [IP] next-hop-self`

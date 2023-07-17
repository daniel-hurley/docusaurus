Title | Internet Protocol Version 6 (IPv6)
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-17-2023

### **Introduction**

What is IPv6? It is the latest iteration of the IP Protocol, as of this writing. The main reason that this version was developed is to alleviate the IPv4 address exhaustion happening across the internet. It boasts a longer address of 128 bit versus the 32 bit of IPv4. It also has fundamentally changed certain methods of communicating as compared to IPv4. These details will be discussed below. Without further ado, lets get into it!

### **IPv6 Structure**

IPv6 is a 128-bit address represented in hexadecimal. Each character in an IPv6 address represents 4 bits of data. That 4 bits is presented by a hexadecimal character (0-F). When we think of IPv4 and the whole idea of “Subnet Masks” and “CIDR notation” – that still holds true in IPv6 the exact same way. The whole point of a subnet mask is to define what is the network portion and what is the host portion in a particular address. An IPv6 address with a /64 mask tells you that the first 64-bits is *the network portion* and the latter (remaining) 64-bits is *the host* *portion*. In IPv4, the mask could be represented using CIDR (/24) or a subnet mask (255.255.255.0). In IPv6, the only way that it is represented is by using CIDR notation (which makes sense considering how long the address actually is).

![https://ospfcommand.files.wordpress.com/2019/07/9ad4364f-4228-49b8-95ab-d46c5d3821fe.png?resize=338%2C208](https://ospfcommand.files.wordpress.com/2019/07/9ad4364f-4228-49b8-95ab-d46c5d3821fe.png?resize=338%2C208)

Above, you will see an example of the structure of an IPv6 address. The address above, `2001:0db8:3c4d:0015:0000:0000:1a2f:1a2b`, has been defined in RFC 4291 as a *global unicast address*. More on the different types of IPv6 addresses later*. The take away from this chart is to get familiar with the the full-length format of IPv6. You have eight (8) sixteen (16) bit sections, and the sections are separated by a colon. Again, each character represents a hexadecimal character (0-F) of 4 bits. 

When referring to parts of an IPv6 address, people may refer to the 16-bit blocks between semi-colons as either nibbles or quadrets.

### **How to Write IPv6**

Since IPv6 is very long, it can be a pain to write sometimes. Luckily, IPv6 addresses can be shortened/abbreviated. Take for example the address in the previous diagram:

`2001:0db8:3c4d:0015:0000:0000:1a2f:1a2b`

This address can be shortened to the following:

`2001:db8:3c4d:15::1a2f:1a2b`

Let’s start by specifying what are the rules for shortening IPv6 Addresses. (Most routers and switchers can use the written short-hand in configuration)

1. Leading Zeroes in a 16 bit quadret (within a semi-colon) can be omitted. So in our example,  `0db8` is shortened to `db8`. `0015` is shortened to `15`.
2. A double semi-colon can be used in place of an all zero 16-bit quadret. The double semi-colon can be used not just for one 16-bit quadret that has all 0s, but also two consecutive quadrets. A double semi-colon cannot be used two times in one address. So in our example, I could essentially “skip” block `15` all the way to block `1a2f` just by putting a double semi-colon.

### **IPv6 L3 Header vs IPv4 L3 Header**

![https://ospfcommand.files.wordpress.com/2019/07/comparison-of-ipv4-and-ipv6-headers-structures-15.png?w=1801](https://ospfcommand.files.wordpress.com/2019/07/comparison-of-ipv4-and-ipv6-headers-structures-15.png?w=1801)

There are a few key differences in the headers for IPv6 compared to the IPv4 :

1. Fragmentation is dealt with at the host level for IPv6. If a router receives a packet that is too big to be put on another link (the MTU is smaller for whatever reason), then the Router running IPv6 will send back a ‘too big’ ICMPv6 packet back to the host. The ‘too big’ ICMPv6 packet essentially tells the host: “hey your packet is too big, chop it up into something smaller than x”. If you compare this to IPv4, routers running IPv4 actually perform the fragmentation of packets instead of the host. Since IPv6 routers pushes the fragmentation to the host, the following headers are not in IPv6: Identification, Flags, and Fragment offset.
2. The flow label is used to uniquely identify a flow of packets. For example, if a certain host sends 100 packets to `google.com`, a unique flow number will be generated to identify the unique flow. This header is not present in IPv4.
3. The TTL Field is renamed to Hop Limit.
4. Checksum is removed completely. The reason for this is that all upper level protocols already have an implementation for error-checking (e.g TCP), so having it in the L3 header is redundant.

### **IPv6 Address Types**

There are lots of different IPv6 Address types. They all have a unique purpose and function for the operation of IPv6. Similarly, the same could be said for IPv4.

**Global unicast:**

A global unicast address is a *globally* unique address (aka routable through the internet). Currently IANA has assigned only `2000::/3` addresses to the global pool (as of this writing).

**Unique Local:**

A unique local address (ULA) is an IPv6 address in the block `fc00::/7`, defined in RFC 4193. It is the approximate counterpart of the IPv4 private address space.

**Link Local:**

![https://ospfcommand.files.wordpress.com/2019/07/4a6fb150-0333-4fe1-8f2a-b0ec74911356.png?w=1801](https://ospfcommand.files.wordpress.com/2019/07/4a6fb150-0333-4fe1-8f2a-b0ec74911356.png?w=1801)

The link-local address can be used only on the local network link (aka unique to a VLAN). Link-local addresses are not valid nor recognized outside the subnet. `fe80:/10` is a Hexadecimal representation of the 10-bit binary prefix `1111111010`. This prefix identifies the type of IPv6 address as link local. Link local addresses use the EUI-64 method to identify its interface id.

**Mutlicast:**

IPv6 multicast operates the same as in IPv4. A packet sent to a multicast address is delivered to all interfaces identified by the multicast address (in a given scope). in IPv6, `ff00:/8` is the pool for the multicast addresses.  In FFxy multicast addressing, the `x` will denote permanent (0) or temporary (1) addressing.  The `y` will denote the scope of the address:

- y=1 means interface local (kinda like an interface-based loopback)
- y=2 means link-local so they can’t be routed (within subnet)
- y=4 means admin-local which is really a bit varying in scope
- y=5 means site-local which should be your site’s physical infrastructure. Routable yes, but not outside your site.
- y=8 means organization-local which implies autonomous system number like in BGP (think Site prefix in 1.12 picture)
- y=E fully routable/usable on the Internet.

![https://ospfcommand.files.wordpress.com/2019/07/9ae0f74d-c6db-40c6-90b7-894ad5339034.jpg?w=1801](https://ospfcommand.files.wordpress.com/2019/07/9ae0f74d-c6db-40c6-90b7-894ad5339034.jpg?w=1801)

![https://ospfcommand.files.wordpress.com/2019/07/fdf1c2e6-508d-4c24-a725-746741566dd2.jpg?w=1801](https://ospfcommand.files.wordpress.com/2019/07/fdf1c2e6-508d-4c24-a725-746741566dd2.jpg?w=1801)

**Solicited Node Multicast:**

When an IPv6 interface is enabled on any device, a solicited node multicast address is created too. For every IPv6 assigned on an interface, a matching solicited node multicast is created (for link local AND global unicast) . The solicited node multicast starts with `ff02::1:ff/104`. The last 24-bits of the interface-id from the IPv6 address is used in the address.

The solicited multicast address purpose is to be able to replace the function of ARP/Broadcast in IPv4 that is used to find the MAC address of a particular host. The solicited node multicast address is also used for duplicate address detection on a subnet. More on duplicate address detection later*. However, in IPv6, the MAC address is found by initiating a neighbor discovery process - also know as neighbor discovery protocol (NDP). This is where the solicited node multicast address comes into play. The device sends a neighbor solicitation packet to the device with the address that start with `ff02::1:ff/104`. The reason it knows how to send it to a specific solicited node multicast address to that individual host is because it extracts the last 24 bits out of the interface-id of the original IPv6 address you’re trying to talk to, and slaps the last 24-bits of interface-id on the end of it: `ff02::1:ff[24bits]`. The destination device is listening on that multicast address, so when it receives it, it responds back with its full MAC Address. The difference compared to ARP, however, is that it uses multicast packets instead of broadcast packets. The multicast is also only going to that specific host because that host is the only one listening with that specific solicited node multicast address.

### **ICMPv6 Neighbor Discovery**

The collection of ICMPv6 types makes up what is called the Neighbor Discovery Protocol (NDP). NDP is used for MAC-finding, duplicate address detection, and Stateless Auto Address Configuration (SLAAC) for IPv6.

**ICMPv6 Message Types:**

- **Neighbor Solicitation**: During duplicate address detection a device sends a ICMPv6 packet destined for the solicited node multicast address of itself and source is the link local address or :: (all 0s). If it receives a reply from that neighbor solicitation, then obviously that address is already used on the local area network. Duplicate address detection is used for link local and global IPv6 addresses.
- **Neighbor Advertisement**: Is the reply message to a Neighbor Solicitation message (either for duplicate address detection or to find a MAC address on a subnet)
- **Router Solicitation**: A device that is configured for IPv6 Stateless Auto Configuration sends out a router solicitation with the destination as `ff02::2`. Only routers running IPv6 listen to this multicast address.
- **Router Advertisement**: Routers then send back a router advertisement back to the accompanying router solicitation message (destination could be the link local address of the specific node or `ff02::1`). Located in this router advertisement is the prefix for the routers interface. Router advertisements, are sent periodically, and they do not have to respond to a solicitation message. Router advertisements are abbreviated to RA in certain situations such as logging and configuration.

### **IPv6 Autoconfiguration**

All interfaces on IPv6 nodes must have a link-local address. Link-local addresses are usually automatically configured from the identifier of an interface(EUI-64 + MAC) and the link-local prefix `fe80::/10`. A link-local address enables a node to communicate with other nodes on the link and can be used to further configure the node.

Nodes can connect to a network and automatically generate global IPv6 addresses without the need for manual configuration or help of a server, such as a Dynamic Host Configuration Protocol (DHCP) server. With IPv6, a device (typically the default gateway / router) on the link advertises global prefix in Router Advertisement (RA) messages, as well as its willingness to function as a default device for the link. RA messages are sent periodically and in response to device solicitation messages.

A node on the link can automatically configure global IPv6 addresses by appending its interface identifier (64 bits) to the prefixes (64 bits) included in the RA message. The resulting 128-bit IPv6 addresses configured by the node are then subjected to duplicate address detection to ensure their uniqueness on the link. If the prefixes advertised in the RA messages are globally unique, then the IPv6 addresses configured by the node are also guaranteed to be globally unique. Device solicitation messages, which have a value of 133 in the Type field of the ICMPv6 packet header, are sent by hosts at system startup so that the host can immediately auto-configure without needing to wait for the next scheduled RA message. This is also referred to as Stateless Address Autoconfiguration (SLAAC).

### **EUI 64**

With IPv6, you can manually set them just like IPv4. However, since IPv6 addresses are bigger than MAC Addresses (which are globally unique), why not convert those MAC addresses *into* the host portion of the address? That is exactly what EUI-64 does. It converts a 48-bit MAC Address into a 64-bit counterpart, and placing that into the interface-id (host portion) of the address. This is how it is accomplished:

A 64-bit interface ID is created by inserting the hex number FFFE in the middle of the MAC address. Also, the 7th Bit in the first byte is flipped to a binary 1 (When the 7th bit is set to 0 it means that the MAC address is a burned-in MAC address.). When this is done, the interface-id is commonly called the modified extended unique identifier 64 (EUI-64).

For example, if the MAC address of a network card is `00:BB:CC:DD:11:22`, then the interface-id would be `02BB:CCFF:FEDD:1122`.

Why is that so, you might ask?

Well, first we need to flip the seventh bit from 0 to 1.

MAC addresses are in hex format. The binary format of the MAC address looks like this:

**hex** `00BBCCDD1122` 

**binary** `0000 0000 1011 1011 1100 1100 1101 1101 0001 0001 0010 0010`

We need to flip the seventh bit:

**binary** `0000 00**1**0 1011 1011 1100 1100 1101 1101 0001 0001 0010 0010`

Now we have this address

**hex** `02BBCCDD1122`

Next we need to insert `fffe` in the middle of the address:

**hex** `02BBCC**FFFE**DD1122`

The resulting Interface ID is, after inserting the appropriate semi-colons `02BB:CCFF:FEDD:1122`.

### **IPv6 Subnetting – How do you do it?**

It’s actually really easy. It’s the same concept as IPv4 subnetting, except you’re dealing with hexadecimal not dotted decimal.

Let’s look at a few interesting examples:

IANA will be using `2000::/3` (as of this writing) for all global unicast routable addresses. But a /3 doesn’t line up so well. What does a /3 even mean? Well again, it’s bit to bit comparison. It means that *the first 3 bits in this address,* if they match, then that means that every other bit to the ‘left’ of that will be considered a globally routable address.

`2000` in binary is `0010 0000 0000 0000`

IANA will be using the first 3 bits of this address for all globally routed addresses. So essentially, anything starting with a 2 or a 3.

Let’s look at another example: `fc00::/7` (private address space for IPv6)

`fc00` in binary is `1111 1100 0000 0000`

So any address where the first 7 bits are *those binary bits*, mean that it is a private address. Say, for example, I assigned a IPv6 private address to the following: `fd00::1/7` – this is still technically in the range of `fc00::/7` even though it actually doesn’t start with `fc`. The reason is because as long as the first 7 bits match, then it is still in the range. I flipped the *8th bit*. By flipping the 8th bit, I changed the hexadecimal character to a `d`. But that is still a perfectly valid private address.

Let’s look at an example where you’re given a netblock, and trying to figure out the available IPs in the block. Let’s look at this block:

`fc00:db8:1234:feed:face:f00d::/82`

So, what addresses are available in this block? Well, let’s write it out in binary, or at least the part where we want to see the *******binary******* line. First, we want to figure out which quadret the defining line is located. This can easily be done by looking at where the closest quadret is to the /82. 64 bits into a 128 bit address, divides the address into two. 64 plus 16 is 80.

So the binary line is in the `face` quadret. Lets write it out:

hex `face`

binary for f `1 1 1 1`

binary for a `1 0 1 0`

binary for c `1 1 0 0` 

binary for e `1 1 1 0`

Here is `f` hexadecimal represented in binary:

| power of 2 | 8 | 4 | 2 | 1 |
| --- | --- | --- | --- | --- |
| binary | 1 | 1 | 1 | 1 |

If you add up 8, 4, 2 and, 1: you get 15 (f). 

Now, let’s go back to our example. /82 is 2 bits into the `f` inside the `face` quadret. Draw the line between the 82nd and 83rd bit

`1 1` | `1 1`

Here, the power of 2, eight and four, are in this hexadecimal character and are considered the “network portion”. 8 and 4 added together is 12 (c in hex). What are the other iterations of those bits in the remaining hexadecimal character? Since it is in the host portion, it is technically free range. It could be `0 0`, `0 1`, `1 0`, or `1 1` . Those, converted into hex, adding in with the 12, are `c`, `d`, and `e` respectively. This means that any subnet starting with`fc00:db8:1234:feed:c`, `d`, `e`, or `f` are inside this /82 block.

In most scenarios, You will be given a /48 block (a site-prefix in the above diagrams). From there, you can use the next 16 bit quadret to create different subnets. The last 64-bits can either be implemented manually for servers, or some variation of DHCPv6 / SLAAC. But that does not mean you cannot make smaller subnets. You can still assign a /100, or even a /127 for point to point links. The same concepts of subnetting apply from IPv4 to IPv6, it’s just getting used to Hex, and the power of 2 numbers for the IPv6 address structure.
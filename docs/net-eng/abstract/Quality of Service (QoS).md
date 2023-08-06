Title | Quality of Service (QoS)
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-17-2023

# Quality of Service (QoS) Introduction

QoS provides predictable management of network resources during times of congestion. When a router is overloaded the memory buffers on it hit maximum capacity. The router has no other choice than to drop traffic. Congestion happens when the memory buffer is filled up on a particular interface on a router. This usually happens when traffic is being pushed passed the line rate for said cable. A router has certain memory reserved for each interface and when that memory gets full, it will drop packets. QoS gives control onto what packets can be dropped. It can also limit traffic by either policing or shaping it. Policing is the act of watching for the bandwidth of a particular stream of packets, and dropping any packets that are excess of that. Shaping is the act of watching for bandwidth of a particular stream of packets, and when the excess limit is reached, it holds the packet in memory until that interface is less congested.

During times of congestion on the network you can expect to see things like Delay, Jitter, and Drops. Delay is simply the latency for one packet to get to it’s destination. Jitter is the results of packets being received but in various time lapses. Drop is simply that the traffic had to be dropped because of the congestion.

To understand QoS, It is best to understand different switching and hardware architectures and how all these different platforms handle packets: particularly how packet is stored in memory and how those memory relate to the forwarding process.

## Network Equipment is very much like a computer

Us network engineers know how to configure network equipment, analyze packets and influence the forwarding decision of those packets. However, sometimes we don’t know how the switches/routers actually do it! *It*, as in how switches/routers take packets and put them onto other interfaces. What is going on behind the scenes?

Switches and routers are just like a computer. They have their storage. Their memory. They have a CPU. The big difference is that most network equipment have a thing called ASICs. ASICs stand for Application-specific integrated – and they *really* good at doing one thing and one thing only (or sometimes a subset of very specific tasks). That one thing could be looking up a MAC Address in a MAC Address Table. Another example would be looking up the routing destination for an IP Packet. Since these ASICs were made for a specific task, they perform these lookups very very quickly. In contrast, CPUs on routers/switches are much slower in there lookup. If you were to compare the two – a human could not differentiate, as the lookup on both would be similar to human perception. However, it makes a huge difference when you are handling thousands upon thousands of packets to use ASICs to make forwarding decision rather than CPUs. While a standard PC uses RAM/Memory to store the operating system, and various applications – Network Equipment use them the same way, but with a twist: they use memory to store packets ingressing and egressing the device. A network device has processes just like a computer. It runs an OS of some type, and it has processes that need to be stored into memory. Packets ingressing or leaving a network device have to be stored *somewhere*. That is where memory is used. There are lots of different network devices as well as alot of different hardware architecture for them. But the key take away is that memory in network devices are used for two things:

- For it’s own OS/processes (routing protocol, SNMP, OS, etc.) – These use CPU Resources
- For packets traversing the device (Packet Lookup) – These use ASIC Resources

## How routers deal with a packet

Below is a high-level chronological overview of how routers deal with packets:

- Packet Arrives on ingress interface and its placed in memory called the RX-Ring.
- Packet is then queued in the memory buffer. This is where CPU (or ASIC) takes control of that portion of memory and re classifies the memory.
- Forwarding Decision is made (routing via IP/Switching based on MAC etc.)
- Packet placed on TX-Ring. The same memory is then reclassified as TX-Ring. The outbound interface of the packet then takes control of that portion of memory.
- Packet transmitted out egress media.

Think of RX Ring and TX Ring as the dedicated memory for that specific interface. Every port has both a RX Ring and a TX Ring. These ‘Rings’ Are completely separate from queues and buffers* More on that later. QoS has no control over the RX Ring and TX Ring. QoS has control over handling of packets and congestion from the Queues and Buffers.

Packets could be physically moved from one memory chip to another. Depending on the memory architecture of the device, the packet could be physically moved from one memory chip to another -or- simply re-classified, but not moved.

## Memory Architecture

There are two types of memory architectures for switches. Shared memory and distributed memory. Shared memory essentially is one big block of memory that is used for all interfaces. The packets coming in and out are renamed and looked up by ASIC linked to that memory. A device with distributed memory has dedicated ASIC/memory for each port/a group of ports. A common shared ring that connects all the ASICs memory together tie them to other ports. Devices that use distributed memory are usually large switched chassis that have multiple line cards. Each linecard has ASICs, but they use high speed ring/bus to interconnect them all together. Below is high-level order of how packets are handled with shared/distributed memory.

How devices deal with packets (shared memory)

- Packet arrives on ingress interface
- Interface/Module ASIC forwards packet into a common shared memory pool.
- Forwarding decision is made by forwarding ASICs
- Memory ownership of packet buffer transferred to egress interface
- Packet transmitted onto the egress media

How devices deal with packets (distributed memory)

- Packets arrive on ingress interface
- Interface/Module ASIC places packet into memory (specific for port/group of ports
- Forwarding decision is made by forwarding ASIC
- Packet transmitted onto shared ring/bus to all egress interfaces
- Appropriate egress interface queues and then schedule the packet

## Buffers and Queues

A Buffer is physical memory used to store packets before and after a forwarding decision is made. On a router this memory can be allocated to interfaces as ingress/egress. In a shared memory architecture, certain parts of memory are dedicated as buffers. However, that same sahred memory is used for other CPU Proccesses.

A queue is different depending on the platform. On Routers, it is a logical part of the shared memory buffer. On switches, individual interfaces/linecards have their own memory which is used as interface queues. Think of queues as the logical section of the *physical* memory (buffer).

Configuration of buffers is not part of QoS. Buffer configuration would involve modifying the quantity of buffers allowed for particular sized packet. QoS configuration applies to queues. With QoS you’re not modifying the quanitity of buffers allocated or a particular sized packet. Instead, you are taking existing buffers that have already been defined as interface queues and modifying how packets are treated when inside those queues. During times of no congestion, QoS is not needed because packets are transmitted First In First Out (FIFO) up to the line-rate of said interface. During times of congestion what happens is the queue is filled up and trying to pass traffic higher than the line-rate of the interface.

## Integrated and Differentiated Services

Integrated Services is a QoS Model in which the entire packet from end to end is ensured certain minimum QoS. Initial RFCs published by IETF in mid 1990s: 1633, 2211, 2212. RSVP is used as the primary protocol to setup the path. Requires every node along path to heed its reservation and to keep per-flow state. This type of Service for QoS did not gain much traction because it was unfeasible to implement across multiple vendors and organizations.

Differentiated Services is designed to address challenges of Integrated Serivces. These are the following RFCs: 2474, 2597, 2598, 3246, 4594. The DiffServ Model describes various behaviors to be adopted by each compliant node (called Per-Hop Behaviors(PHB)). Each device has the capability to apply QoS the way they want with whatever method they choose fit. With Integrated Services it was guaranteed that each packet had end to end guarantee of QoS. With Differentiated Services, there is no guarantee and each device can or may not be configured with QoS.

## Classification/Marking

Traffic first must be divided into “classes”. A Class of traffic will receive the same type of QoS treatment. It analyzes the packets to differentiate flows. Packets are marked so that analysis happens only a limited number of times, usually at the ingress edge of a network. Usually this starts as a business decision and the business needs for the network. The whole idea behind classification is to identify traffic in your network that is critical to operation and quality of your buisness. After identifying what traffic is important, you can create rules to match that traffic – and mark them for QoS. Most ISPs will police ingress traffic. Traffic that is non-conforming (higher then the CIR) will be either dropped or marked down. Customers obviously don’t want any type of traffic drops, so shaping done on the egress interface leading to your ISP is recommended.

Queuing When egress traffic cannot immediately be transmitted (aka on the TX Ring), it is placed in an egress queue. A single egress interface may have multiple associated egress queues differentiated by priority. QoS features designed for queuing provide control over which classified traffic is placed into each of these queues. Queueing can also preemptively drop traffic from within queues to make room for higher priority traffic.

## Scheduling

Scheduling is defining what packets are put on the wire depending on their priority. On routers, QoS queuing features such as WFQ affect queuing and scheduling behaviors. On switches, queuing and scheduling can be separate features. Traffic shaping is a function of scheduling.

## Congestion Management

Congestion management features allow you to control congestion by determining the order in which packets are sent out an interface based on priorities assigned to those packets. Below is high-level overview of congestion management process:

- Creation of queues
- Assignment of packets to those queues based on the classification of the packet
- Selectively dropping packets from within queues when those queues reach pre-defined thresholds
- Scheduling of the packets in queue for transmission

Features for Congestion Management: WFQ, CBWFQ, PQ, LLQ, WRR, and SRR

Traffic Shaping Features of Congestion Avoidance: RED, WRED, WTD, and Policing

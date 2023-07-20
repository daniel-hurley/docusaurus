## Spanning-Tree Protocol (STP)

Spanning-Tree Protocol (STP) is a protocol to prevent loops in a switched 802.11 network by blocking ports based on a couple key parameters. 1: Priority of a bridge and 2. Port Roles for each Switch connection. STP uses Bridge Protocol Data Unit (BPDU) to converge the network. There is an election process using BPDUs to elect the root bridge of the network. Each BPDU has BID of who they think the root bridge is (themselves at first), and their own priority to identify the root bridge. Once a bridge sees a lower priority they stop generating BPDUs and only forward BPDUs from the root (this is only the case for vanilla 802.1D STP). Eventually a bridge is elected the root in a topology – and looped connections are blocked ( e.g discarding/blocking) based on alternate paths to the root bridge.

### Sequencing of STP

1. Elect a root bridge in a topology. The root bridge is elected by determining the switch/bridge with the lowest Bridge Priority within a topology. By default all cisco switches have a default priority of 32768.[internal mac-address]. The Bridge with the lowest priority in a topology becomes the root bridge. Every BPDU has a field for: sending bridge and root bridge priority. By default when a switch turns on it automatically thinks its the root bridge, but if it sees a lower priority, then it goes silent (only in vanilla 802.1d STP), and only advertises the root bridges BPDUs at that point. When the root bridge has been identified in a topology (usually after several seconds), it puts all of its ports in Forwarding state, with a port role of Designated Port. The job of a designated port is to forward BPDUs. Designated port and Root ports are in the forwarding state. Meaning they can forward ‘user’ traffic.

2. Find the root port for every switch that’s not the root bridge. Every switch in a topology that isn’t the root bridge has to find their root port, which is the port that has least cost to get back to the root bridge. The way this is calculated is by calculating the STP Cost. When a BPDU is sent to a non-root bridge, in the BPDU is a field for Cost to Root. This is calculated by the speed of the interface in relation to the root bridge. If a switch that has gigabit ethernet interface and directly connected to root bridge, the root bridge BPDUs will send a cost of 0 (because the root bridge costs nothing to get to himself). However, when that BPDU is sent to any other switches “down the line” it adds those costs together every time it gets to a bridge. Lower the cost is to the root, the easier it is to get to the root, and that port is put into the forwarding state, as a root port. Once a non root bridge receives Cost information from two possible ports to get to the root bridge, it will pick the port with the lowest total STP cost to assign the root port. If root STP cost is the same for both BPDUs, and the sending bridge ID is the also the same; it uses the sending port ID field in a BPDU to determine which one to choose. The Sending Port ID field tells you port ID (ex: gigabit0/1) and the port priority (default 128)). The lower port number/priority is chosen.

3. Find Designated Ports for every non root bridge. These are the rest of the connections that wouldn’t cause a loop in the network (aka to end nodes).

4. The Ports that are left are non designated ports. These ports are put in the blocking state because they form a loop.

### Per-VLAN Spanning-Tree (PVST)

1. Specified in 802.1d

2. On by default for all Cisco Switches

3. Load Balance sharing between vlans (uses 1 vlan on one port, and another vlan on the other alternate port)

### Rapid Rapid Per-VLAN Spanning-Tree(PVST)

1. specified in 802.1w

2. Proposal and agreement bit are added as flags in new BPDU header. If a bridge sends an agreement bit the ports are automatically put in the states that STP calculates. Can only work on a full duplex point to point link.

3. All Switches generate BPDUs every 2 seconds. Where as in 802.1d (STP) only the root bridge sends BPDUs

4. Uses BPDU protocol version 2 (compared to 0 in 802.1d)

5. When any RSTP ports receive legacy 802.1d BPDUs it falls back to legacy STP and the inherent fast convergence benefits of 802.1w are lost.

### Port Roles for RSTP

1. Root port – same as 802.1d

2. Designated port – same as 802.1d

3. Alternate port – Means you received a BPDU from the root from another switch that can lead to the root bridge.

4. Backup port – Means you received a BPDU from yourself.

### BPDU Frame Format

![https://ospfcommand.files.wordpress.com/2019/07/image-1.png?w=1801](https://ospfcommand.files.wordpress.com/2019/07/image-1.png?w=1801)

### STP Cost Table

- 10Mpbs – 100
- 100Mpbs – 19
- 1000Mpbs – 4
- 10gig – 2

### Timers (defaults)

**Hello Timer** = 2s – Every time a local switch sends a BPDUon the link

**Max Age** = 20s – Every time a bpdu is received on a port, the timer is set back to 0. If Max Age ever reaches 20s, and still havent seen a BPDU from the root bridge, it will start the process of electing a new root bridge. Set 10 times the hello timer.

**Forward Delay** = 15s – this governs the port states (listening, learning, etc.). The forward delay applies to each port state when a port detects electrical signal.

**Message Age** = Similiar to TTL. The message age is incremented by 1 every time it goes through a bridge. Cisco devices do not enforce the age on their devices as a boundary though.

### Port State > Port Role

Forwarding > Root Port – Port on the local switch that provides least-cost path back to the root | Designated Port – port on the *cable* that provides least cost path back to root.

Blocking > Non-Designated Port

RSTP contains the following states and roles:

- Discarding

- Learning

- Forwarding

While STP contains the following states and roles:

- Blocking

- Listening

- Learning

- Forwarding

### STP Port States

*Disabled* – Port that is in the down state or no cable plugged in. Does not participate in the STP topology.

*Blocking* – Port is only allowed to receive BPDUs, cannot receive or learn mac addresses.

When a port first detects electrical signal it goes into the following phases:

1. *Listening* State (15s) – only allows BPDU to send to the CPU. Actively participate in STP. Cannot send or receive data.

2. *Learning* State (15s) – only allows BPDUs, does not send data, however can learn MAC Addresses.

3. *Root* Port, *Designated* Port, or *Non-Designated* port – The port at that point has decided what state the port should be in but it has to go through the forwarding delay plus the listening and learning state to set it to that. RSTP uses the Proposal and Agreement bit in the BPDU to automatically bring the port up in a quick one-two.

### Bridge Priority

Bridge priority can only be set in increments of 4096. The reason for this is that the first 12 bits of Bridge ID in a BPDU is used for VLAN number. The last 4 (4096 and base 2 of that, can only be increments of 4096). Modifying timers on a non root bridge does not work, cause the only BPDUs that adhere are the root bridge BPDUs.
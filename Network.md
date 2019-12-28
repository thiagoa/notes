# Network

Back to basics.

## Basics

- Network layers stack on top of each other in order to form a complete system.
- Layers are independent, so it's possible to build networks with
different combinations of components.
- Each machine connected to the network is called a host.
- The hosts are connected to a router that can move data from one network to another.
- The hosts and the router form a LAN.
- The router may be connected to the Internet, thereby granting
Internet access to all machines.
- The data is transmitted over a network in small chunks called _packets_.
- A packet has two parts: a header and a payload. The header
  identifies the origin/destination hosts and basic protocol. The
  payload is the actual data.
- Hosts can send, receive, and process packets in any order,
  regardless of origin or destination.
- Breaking messages into smaller units makes it easier to detect and
compensate for errors in transmission.
- The OS handles packets for you.

## Network Layers

Also called _network stack_.

- **Application layer**: The language that application and servers use
  to communicate (high-level protocol). HTTP, SSL, FTP, HTTP + SSL, etc.
- **Transport layer**: Also called *protocol layer*. Defines the
transmission characteristics of the application layer. Usually TCP and
UDP.
    - Data integrity checking
    - Source and destination ports
    - Specification for breaking data into packets.
- **Network or Internet layer**: Defines how to move packets from
  source to destination. The internet uses Internet Protocol (IP).
  Many can be configured on a single host (IP, IPV6, IPX, AppleTalk, etc).
  IP specifies the way information is packetized, addressed, transferred,
  routed and received.
- **Physical layer**: Defines how to send raw data across a physical
medium, such as Ethernet or a modem. Link layer or host-to-network
layer.

The data travels through these layers at least twice before reaching
the destination.

## The Internet Layer

- Send and receive packets over any kind of hardware, using any OS.
- The internet is made up of _subnets_.
- IPs are like postal addresses.
- A router/gateway host can be attached to more than one subnet, so as
to transmit data from one subnet to another. In that case, it has at
least one IP address per subnet.
- Each host has at least one IP, a *dotted-quad* sequence of 4 bytes -
  `a.b.c.d`. `a` and `d` range from 1 to 254, and `b` and `c` from 0
  to 255.
- An IP address is split into two components: a network component and
  a node component.
- Each IP should be unique across the entire Internet (watch out for
  private networks and NATs).

To view active IP addresses and details from both the Internet layer
and physical layer, run `ifconfig` (stands for interface
configuration). Imagine this line to be part of the output:

```
inet addr:10.23.2.4  Bcast:10.23.2.255  Mask: 255.255.255.0
```

`255.255.255.0` is the subnet mask.

### Subnets

- A subnet is a connected group of hosts, usually on the same physical network.
- A subnet is defined in two pieces: a network prefix and a subnet mask.
- The network prefix is the part that is common to all addresses in the subnet.
- A subnet with IP addresses between 10.23.2.1 and 10.23.2.254 has
10.23.2.0 as the network prefix and 255.255.255.0 as the subnet mask.
- The mask marks the bit locations in an IP address that are common to
the subnet. Or, it hides the node component with logical AND:

```
10.23.2.10      00001010 00010111 00000010 00001010
255.255.255.0   11111111 11111111 11111111 00000000
10.23.2.0       00001010 00010111 00000010 00000000
```

The first 3 bytes are the network component, which is common to the
subnet. You can set the last byte to whatever in order to get a valid
IP address in this subnet. The notation for this subnet is
`10.23.2.0/255.255.255.0`, or in CIDR (Classless Inter-Domain Routing) notation
`10.23.2.0/24` (24 bits for the network component).

The subnet mask allows us to determine the network component of the IP
address. In early IPv4 networks we had the following classes:

```
Class A  network,node,node,node
Class B  network,network,node,node
Class C  network,network,network,node
```

The most significant byte determines the class:

|         | MSB     | Range                        | Description                     |
|---------|---------|------------------------------|---------------------------------|
| Class A | 0-126   | 1.0.0.1 to 126.255.255.254   | 16M hosts on 127 networks       |
| Class B | 128-191 | 128.1.0.1 to 191.255.255.254 | 65,000 hosts on 16,000 networks |
| Class C | 192-223 | 192.0.1.1 to 223.255.254.254 | 254 hosts on 2M networks        |

Ranges 127.x.x.x are reserved for the loopback or localhost.

Class A can accommodate millions of nodes, but it's impractical to
put this many nodes on a single network. Therefore, the solution is to
split the network into subnets.

The network part of the address is used for routing IP packets on the
public Internet. Once the packets enters the private network, only the
node address is used. It is possible to split the node address into
subnet and node:

```
network,subnet,node,node
network,subnet,subnet,node
```

A class A address of 11.1.1.21 and mask 255.255.255.0 has 11 as the
network and 1.1 as the subnet.

If I need to create 20 networks with a class A address of 29.0.0.0,
each supporting a maximum of 160 hosts, then both 255.255.0.0 and
255.255.255.0 masks would work. 255.255.0.0 has 8 bits for the subnet
and 16 bits for the host. 8 bits accommodates 256 subnets, and 16 bits,
over 64000 hosts. 255.255.255.0 has 16 bits for the subnet and 8 for
the host.

## Routing table

Host A at IP address 10.23.2.4 is connected to a local network of
10.23.2.0/24, so it can reach hosts on that network. To reach hosts
on the Internet, it must communicate through the router at 10.23.2.1.

To distinguish between local and Internet addresses, the kernel uses a
routing table.

```
$ route -n
```

| Destination | Gateway   | Genmask       | Flags | Metric | Ref | Use | Iface |
|-------------|-----------|---------------|-------|--------|-----|-----|-------|
| 0.0.0.0     | 10.23.2.1 | 0.0.0.0       | UG    | 0      | 0   | 0   | eth0  |
| 10.23.2.0   | 0.0.0.0   | 255.255.255.0 | U     | 1      | 0   | 0   | eth0  |

- Destination is the network prefix.
- Genmask is the netmask.
- 0.0.0.0 matches every address on the Internet and is the *default
  route* (when no other rules match).
- U indicates that the route is active.
- G means communication for the network must be sent through the gateway.
- Where there is no G, the network is directly connected.
- 0.0.0.0 is used as a stand-in under Gateway, and is the default gateway.

You can configure a host without a default gateway, but it won't be able to reach hosts outside the destinations in the routing table.

## ICMP and DNS tools

ICMP - Internet Control Message Protocol - Helps root out problems
with connectivity and routing.

### Ping

The `ping` command sends ICMP echo request packets and asks the
destination to return the packets. **The host must be configured to
reply**. Not all hosts respond for security reasons.

```
$ ping 10.23.2.1
PING 10.23.2.1 (10.23.2.1) 56(84) bytes of data.
64 bytes from 10.23.2.1: icmp_req=1 ttl=64 time=1.76 ms
64 bytes from 10.23.2.1: icmp_req=2 ttl=64 time=2.35 ms
64 bytes from 10.23.2.1: icmp_req=4 ttl=64 time=1.69 ms
64 bytes from 10.23.2.1: icmp_req=5 ttl=64 time=1.61 ms
```

- Sending 56-byte packets or 84-byte if including the headers
- icmp_req is the sequence number. A gap indicates some kind of
  connectivity problem.
- Time is the round-trip time.
- Packets can arrive out of order, which indicates a problem because
ping sends one packet a second. More than 1s indicates an extremely
slow connection.
- May return "host unreachable".

### Traceroute

```
$ traceroute google.com
traceroute to google.com (172.217.11.14), 30 hops max, 60 byte packets
 1  165.227.80.253 (165.227.80.253)  0.697 ms 165.227.80.254 (165.227.80.254)  5.403 ms  5.386 ms
 2  138.197.251.66 (138.197.251.66)  1.185 ms 138.197.251.88 (138.197.251.88)  1.069 ms  1.433 ms
 3  * 138.197.251.114 (138.197.251.114)  1.750 ms 138.197.251.118 (138.197.251.118)  1.708 ms
 4  138.197.244.3 (138.197.244.3)  0.867 ms 138.197.244.5 (138.197.244.5)  0.827 ms  0.815 ms
 5  162.243.191.241 (162.243.191.241)  1.101 ms 162.243.191.243 (162.243.191.243)  0.956 ms 162.243.191.241 (162.243.191.241)  1.072 ms
 6  * * 108.170.248.65 (108.170.248.65)  1.179 ms
 7  108.170.227.210 (108.170.227.210)  0.964 ms 108.170.237.210 (108.170.237.210)  1.218 ms 172.253.69.209 (172.253.69.209)  1.533 ms
 8  lga25s60-in-f14.1e100.net (172.217.11.14)  1.344 ms  1.317 ms 108.170.248.35 (108.170.248.35)  0.875 ms
```

- ICMP-based program.
- `-n` disables hostname lookups.
- Reports roundtrip times at each step.
- Can have inconsistent output: replies may time out only to reappear
later. A router may assign lower priority to debugging traffic.

### Host

```
$ host www.google.com
www.google.com has address 172.217.12.164
www.google.com has IPv6 address 2607:f8b0:4006:803::2004
```

- Find the IP address behind a domain name.
- Or find a domain name behind an IP address: may not work reliably
  because many hostnames can represent a single IP address. Depends on
  the domain admin to set up reverse lookup.

## The Physical Layer

- The Internet is a software network, but obviously still reliant on
hardware for the physical layer.
- The most common kind of physical layer is Ethernet.
    - Wired, wireless;
    - All devices on an Ethernet network have a Media Access Control
      (MAC) address that's unique to the host's Ethernet network;
      Example: `20:78:d2:ec:72:99`.
    - Devices on an Ethernet network send messages in frames, which
    are wrappers around the data sent;
    - A frame contains the origin and destination MAC addresses;
    - Each Ethernet network is also usually an Internet subnet;
    - A frame can't leave a physical network, but the router can take
      the data out of the frame, repackage it, and send it to a host
      on a different physical network (e.g., the Internet).

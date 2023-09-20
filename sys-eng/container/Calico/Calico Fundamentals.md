Title | Calico Fundamentals
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-29-2023

## Introduction

[Calico](https://github.com/projectcalico/calico) is a Carrier Network Infrastructure (CNI) plugin that provides flexible network  and security controls for kubernetes clusters. Calico first started, and still is, an Open Source Project called *Project Calico*. The effort eventually was adopted by companies, and a more advanced feature set was required. During that time, the company  [Tigera](https://www.tigera.io/) was created to fulfill the advanced needs of the company, and then was born *Calico Cloud* and *Calico Enterprise*. 

In this document, I will run through the basic building blocks of Calico open source version.

### Routing Modes

Calico has three "modes" that define how traffic is routed in a kubernetes cluster:

- IP-in-IP
- Direct
- VXLAN

#### IP-in-IP

IP-in-IP routing mode encapsulates packets going from one worker node, to another, by way of placing the worker nodes IP address *over* the respective pods IP. When the packet is received by the other worker node, it de-encapsulates the packet and sends it to the destination pod. The worker nodes maintain the routes of the other pods in the other worker nodes by way of BGP route sharing.

#### Direct

Direct routing mode simply routes the pod traffic with no encapsulation what so ever. Direct routing relies upon the gateway address of the node to be aware of the routes of all pods within' the cluster. The main difference is that when running this mode that you need to ensure these pods know of routes to upstream gateway network appliances. Direct mode is also inherently more performant, simply because it is not having to perform encapsulation.

#### VXLAN

VXLAN routing mode uses VXLAN headers (encapsulated with UDP) and tunnels traffic to other pods IPs. 

### Route Sharing

With those routing modes in mind, the methods in which calico shares routes between nodes depends upon the routing mode used.

### IP Address Management (IPAM)

Kubernetes requires a IPAM plugin of some sort to hand out IP addresses and create a structure for the pods in the cluster. Calico provides it's own plguin called *calico-plugin*. This is the default plugin used for most calico installations. 

By default, Calico uses one default IP pool pod CIDR for the entire kubernetes cluster. You may configure IP pool CIDRs for particular nodes based upon teams, users, or application per their kubenetes namespace. You may control which pools are designated to which pods based upon node selectors, namespace, or pod's annotation. 
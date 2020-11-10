---
title: Knockd setup for pivpn
date: 2020-10-15 16:00 +00:00
tags: [knockd, pivpn, sysadmin, homelab]
description: A simple iptables config to go with pivpn, knockd and your useing a crappy ISP supplied router.
layout: post
image: assets/img/iptables.jpg
---
I thought I'd put a quick post together on how I secure access to my home network with pivpn and knockd. There are a lot of guides out there that detail how to use iptables where they assume that the machine / device your configuring isn't NAT’ed which makes the setup pretty different.

##### A few caveats as usual...
-Knockd is an example of security by obscurity - it should be the only thing that you use to protect your network.

-Writing blog posts about your network config is a bad idea. Oh well, nevermind. Having said that, my main aim is just to deter / block automated attacks. Hopefully I won't give anyone reason to have a go at my stuff directly.

-I'm working on a Debian system, other Debian based flavours may work fine with all of this but YMMV.

##### Preamble

When your working in NAT’ed environment (like most people with their home network setups) unless you are really paranoid / security conscious you can write your iptables without starting by dropping everything, since unless your forwarding something from your router packets aren't going to make it to your machine unless its initiated the connection anyway.

What I see a lot of people struggle with online when they are trying to configure their own iptables setup is the order in which they input commands playing a very important role. The easiest way (i think!) of conceptualising how things will work is imagining a config file with all the commands you might issue and water (packets) flowing from top to bottom of this file.

The one thing I do need access to and forward is the connection port for my home VPN.
Perhaps this too may seem like overkill to some, but when you leave a free dns up for a long time some clever sniffers do then start trying to authenticate with all sorts of garbage keys. I've used fail2ban before in the past, but this solution seems to be a fair bit less of an overhead.

I like to secure this port with Knockd since, when I'm done doing whatever I need to remotely, I can start dropping the packets to that port again. Remote service detection with things like nmap is a fair bit more complicated with UDP (which the wireguard server runs on), since  unless you explicitly REJECT the incoming packet rather than DROP it, nmap has no way of discerning between open  and filtered. With UDP you can always send a packet to something, but what you get back relates to what service or program you sent it with. Nmap does have some key exchange scripts available, but I don't think any of them work with the latest versions of Wireguard.

This is different if you are using Knockd to protect something like ssh or other TCP services. If your firewall is open and the port is forwarded a scanner will get a succinct Open response back, so, it's perhaps even more beneficial from a service discovery PoV.

#### Setup

The first step is to install iptables-persistent if you want your changes to be preserved after a reboot. There are other methods to achieve the same thing by creating a few config files yourself and having them executed yourself, but this is the easiest method since it lets you just edit iptables via the cli then commit your changes with the  iptables-persistent script.

```bash
Sudo apt install iptables-persistent
```
 The first question of the setup script is pertinent if you want to discard or save any changes you have already made in your current session. If you have already been making changes recently test if your system is behaving as you expect it to before answering.

 To enable knockd edit the /etc/default/knockd file making the following changes:
 enter the interface you want knockd to run on in the KNOCKD_OPTS sections. You can get its exact name with "ip addr or ifconfig"

```bash
START_KNOCKD=1
KNOCKD_OPTS="-i eth0"
```

The next command we will issue tells iptables to keep connections open that have already been established on the INPUT chain. In my configuration, If I open up my VPN port with knockd, leave a client running doing something on the VPN, but then close the port it wont cut that client off. This is especially important if you are intending to use knockd with SSH and you are working remotely on a system to set this up. You don't want to lock yourself out!

```bash
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

On most ‘home’ systems the default INPUT policy will be ACCEPT. Thus, as we want the open / close requests to knockd to work we need a pre-existing rule that sets the default behaviour for the VPN’s services port at the bottom of the chain (-A). This way, later on we can insert / delete a  temporary rule above this with the insert option (-I).

```bash
sudo iptables -A INPUT -p UDP --dport (vpn_connection_port) -j REJECT
```

At this point we want to save our iptables configuration as its our default config before knockd modifys it.

```bash
sudo systemctl start netfilter-persistent
sudo netfilter-persistent reload
```

Now we have the system setup we can edit the config file. The one provided by the install script is setup to open the default ssh port, but is easily changeable for our needs. The only really important change apart from the ports and what kind of packets they will respond to is that we will use insert (-I) in our rule, rather than adding it. (-A). If we added after our permanent rule, it wouldn't do anything. Presumably the example config file for SSH was written with a default INPUT DROP policy in mind, rather than an ACCEPT one.




![Knockd config screen shot](/assets/img/knockd_conf_ss.jpg){: style=padding:16px"}

* What you see inside the braces will end up in whatever log file you pick when the knocking is triggered - Ive called mine open / close VPN.
* sequence = (portnumber):(port type),(portnumber):(port type)
    The ports will default to TCP if you do not specify a port type.
* seq_timeout = (time in seconds) 
    How long the service will listen for subsequent knocks before resetting the sequence.
* command = /sbin/iptables -I INPUT -p (protocol) --dport (port_number) -j ACCEPT
    The command to run when the knock sequence is received.
* tcpflags = "fin|syn|rst|psh|ack|urg"
    The type of flag the service will listen for. Sending the wrong type of packet will reset the sequence. See man knockd for more info

The closing knock follows the same conventions only we want to delete the rule we inserted. This will mean that the preexisting block rule we added to the bottom kicks in again. In my config I dont like to use a source IP with the rule. A lot of the time I'm connecting via a mobile device, where the IP frequently changes before I'm finished.

Since I mainly use this program on my phone, I wanted an easy way to kick it off without having to type into Termux on my phone. I wrote a quick script which I can then launch in the termux app.
[Termux knockd](https://github.com/mikebdict/bash_stuff/blob/master/termux_knock.sh)
I love that app, and will probably ditch android when support for these kinds of app are dropped in Android 11... :(
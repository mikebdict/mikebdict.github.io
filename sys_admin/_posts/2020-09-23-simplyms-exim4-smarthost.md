---
title: Exim4 smarthost
date: 2020-09-23 14:00 +00:00
tags: [Simplyms, exim4, sysadmin, homelab]
description: Adding a smarthost to exim4 to forward local mail
layout: post
image: assets/img/eximsms.jpg
---

I couldn't find any direction online on how to setup a local smarthost for my homelab stuff, so I thought I'd outline it here after I did some trial and error.
##### Why?
Lots of linux daemons like to use local mail to report on whats going on on the system. If you want to be kept alerted as to that stuff externally, and use things like the mail cli tool adding a smarthost to your local config to forward messages is convenient, quick and simple.

##### Who?
A mini shout out here to the mail provider I've been using personally and recommending to clients for years, [Simplymail solutions](https://www.simplymailsolutions.com/). They are a British based email / webservices hosting who, as they name suggest specialise in email hosting. The main reason I have stuck with them, which is really important for people I've supported, is that it's easy to get in touch with them and speak to a real human being directly who will help you with any issues you may have. This is increasingly rare these days!
 
So, this guide if you happen upon it is directed to people using Debian based distros and Simplymail solutions. The same instructions may well work with many other hosting providers and distros that use exim4 but, YMMV.


##### Lets get started.


```bash
sudo apt install exim4-daemon-light
```
This should get everything you need on the system including TLS support for exim.

```bash
sudo dpkg-reconfigure exim4-config
```
There are a few non defaults here and you may want to change some of the settings I pick, depending on your use case.

* General type of mail configuration: 
    * mail sent by smarthost; received via SMTP or fetchmail   
    * mail sent by smarthost; no local mail

Either of these could work fine depending on what you want. In my case I want to keep local user mail on the system enabled as I use it as a means to filter some messages with things like cron.

* System mail name:

Depending on your use case your either going to want to leave this blank or use a FQDN that your mail server allows you to send mail from. The way I use this service, I only send mail to the same account that I'm authorising onto, so i'm not worried about spam checking on different addresses. That gives me the advantage of being able to set it to whatever I want really, so I pick my machines / containers internal .local name. That way I can forward the mail onto other places based on the address and internal user name once gmail picks them up.

* IP-addresses to listen on for incoming SMTP connections
    * 127.0.0.1 ; ::1
    
    Just localhost addresses for ip4 / ip6

* Other destinations for which mail is accepted:
* Machines to relay mail for:
* IP address or host name of the outgoing smarthost:
    *  mailserveradress::1234

Address and port of your mail server goes here

* Hide local mail name in outgoing mail?

If you want mail to be sent with the same address as the mailbox you authenticated onto you will want to choose yes here, otherwise your messages will likely be spammed.
As I mentioned previously I'm only sending mail to my own mailbox, so I'm chooseing no.

* Keep number of DNS-queries minimal (Dial-on-Demand)?
* Delivery method for local mail:

I prefer "Maildir format in home directory" since If I create particular users to run a specific app everything I want goes to the same place.

* Split configuration into small files? 

We are only going to be changeing some small things to enable TLS and save some authentication details, so small files seems like the best option here.

Next up, we are going to create a file with the authentication details for our mail server and enable TLS for exim.

```bash
sudo vi /etc/exim4/passwd.client
``` 
add this line with your authentication details for your mail server
```bash
mailserveradress:[email address]:[password]
```

As an extra bit of security, I like to softlink this file to inside an encrypted location on another machine. I often forget where sensative files like this are kept between installs and images so that approach works well for me.

For the next step you need to know how you will be authenticating onto your server.

```bash
sudo vi /etc/exim4/exim4.conf.localmacros
```

If your just useing plaintext passwords (not recommended) add this line:
```bash
AUTH_CLIENT_ALLOW_NOTLS_PASSWORDS = 1
```
If you are useing TLS add this:
```bash
MAIN_TLS_ENABLE = 1
```

If your useing TLS you need the openssl package installed. Odds are you already have it beacuse of SSH, but incase you dont install it:
```bash
sudo apt install openssl
```
Once thats installed run this to generate a self signed certificate. 
```bash
sudo /usr/share/doc/exim4/examples/exim-gencert
```
If your just authenticateing onto a hosted mailbox what you put doesnt matter *that* much, getting stream encryption is the main bonus. Consider makeing a record of the generated cert. /etc/exim4/exim.crt - man exim4-config_files has more info.

Once this is done its time to restart exim and give it a test.

```bash
sudo update-exim4.conf
sudo systemctl restart exim4
echo "exim4 test" | mail -s "exim4 test" youremail@account.com
```

In my case I got an email where the evnelope was completely different to the mailbox's associated address (localusername@localdnsname.local) but this is what I wanted.

##### Sending without the local mail name

If you want to send external mail with exim without local mail names you have a couple of options. You could change the global config with dpkg-reconfigure and choose yes to hide the local names for everything, or change things on a per user basis with the /etc/email-addresses & /etc/alias files.

The /etc/alias file redicrects mail for local users - it will not change the envelope / reply to name. /etc/email-addresses rewrites the mail headers to anything that you specifiy in the file. In my config I have a user configured inside /etc/email that rewrites the headers to match the external mailbox domain. I can also use a .forward in a given users home directory to send via this account.










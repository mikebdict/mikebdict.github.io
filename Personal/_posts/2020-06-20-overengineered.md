---
title: Overengineering
date: 2020-06-20 15:00 +00:00
tags: [LPIC, Python, Study guides]
description: A not so simple challenge?
---


# Starting out

When I started doing research about taking LPIC qualifications  in May, the first thing I stumbled across was this, slightly out of date, but very well written study guide:


![LPIC Practical LPIC-1 Linux Certification Study Guide](/assets/img/LPIC-Practical-LPIC-1-Linux-Certification-Study-Guide.jpg){: style="float:left; padding-right:16px"}
Its been hosted on someone's Github, that I won't link for copyright reasons, but the first few chapters were a useful primer for me until I coughed up for an up to date Wiley / Sybex version of the same thing. Having reached the end of chapter 5 (Shells, scripting and Databases) I found an interesting challenge:
{: style="padding-bottom:80px"}

> "Write a script that asks for a user’s telephone area code and test to see if he lives within a
hundred miles or so from you. Extra points if you can do the same thing after asking for the user’s complete phone number (i.e., if you can figure out how to extract the area code digits from the longer number).”

Hmm. This struck me as a bit strange. Given the rest of the challenges and scripts that I had been playing around with from the book so far had taken a maximum of around 30 minutes or so, I thought that there must be some simple way to do this that was escaping me.

![Confused doge](/assets/img/462hge.jpg){: style="float:left; padding-right:16px"}
Surely solving this would require harvesting and storing a lot of data, a lot of decisions based on that data  and, overall something significantly more than a ‘simple’ exercise. It wasn't until I had finished my highly over engineered solution (which, admittedly set me off learning a load of cool new things) until I came back to the question, visualised it properly that I realised how overblown mine was.
{: style="padding-bottom:10px"}

##### Aktchurleyyy
![Confused doge](/assets/img/drake-hotline-yes.png){: style="float:left; padding-right:16px"}
The question stipulates **“... a hundred miles or so from you”**. I took it as **“... a hundred miles or so from any given number.”**. If I had actually read and thought about the question properly, it would have just taken some simple tests and research to establish which area codes surround my area and testing for them. I suppose had I not been me, I would have not gone on then to start experimenting with python and beautiful soup, which has definitely been a fun, unintended consequence!

So the takeaway from the whole thing was really just an exercise in reading the question, and not deploying highly over-engineered solutions. Nothing new there, but always worth remembering.




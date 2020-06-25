---
title: Phone code matcher
date: 2020-06-20 15:00 +00:00
tags: [Python, Beautiful Soup, GeoPy]
description: Some scripts that test if a phone codes distance is 100 miles or more from another.
---

Following on from my [Overengineered](/overengineered) post I thought I'd explain some of my process of creating the scripts in this repo: [phonecodedistance](https://github.com/mikebdict/phonecodedistance)

As a disclaimer, I know that they certainly aren't perfect and there's likely much better ways to do what they did, probably in fewer lines and with a bit more stylistic consistency. I had to start somewhere though! As someone whose previous programming knowledge could probably be neatly summed up as (admin) / script kiddy a few parts of it did take me a fair bit of wrangling. Still, its part of the journey and having a collection of programs that I can go back and improve as I get better is strangely compelling.

When I had settled on the task of doing this, the first thing I knew I wanted to learn was the basics with a html parser, so I chose [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/). I read the [getting started](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#quick-start) docs and this [tutorial](https://programminghistorian.org/en/lessons/intro-to-beautiful-soup) as primers then started fiddleing. I realise I could have grabbed the phone codes with something like w3m and pruned its output with awk (something I may still do, just for fun!) but I knew that in the end I wanted to feed coordinates to [geopy](https://geopy.readthedocs.io/en/stable/), so I decided to keep the whole thing in python.

I decided to make the program in two parts, one to grab the codes from a website and another to perform the matching from phone numbers. I wanted to keep it modular so I could maybe practice doing something similar later with python's mysql connector and also, I felt it was best to try and keep my scraping requests to a minimum on the website where the codes were listed alongside their geographical coordinates. Props to owner of [the phone code site](https://www.doogal.co.uk) for letting me use that site for this post. 

##### The Scraper
[uk_phonecodes_BS.py](https://github.com/mikebdict/phonecodedistance/blob/master/uk_phonecodes_BS.py)
I've been a bit lazy with the textdata and td2 loops - I'm sure there is a more eloquent way of doing that all in the same loop but I was having issues. I think I’ll make a stack overflow account soon so I can find out how I'm asking google the wrong questions… 🥺 I tried saving the area code td’s in a separate list using the append method then using extend later in the same loop, but the resulting list would have separate entries for the code and the rest of the data. I'll probably come back and smarten it up in the future, but, I want to press ahead with other things.

##### The code matcher
[phonecodedistance](https://github.com/mikebdict/phonecodedistance/blob/master/codes2_cords.py)
In the second program the thing that caused me the most issues was the code matchers themselves. I couldn't figure out why the break in firstcode / secondcode didn't seem to be working until I put some print strings into the loop and saw that the list was being traversed in the ‘wrong’ way for the matcher to stop, so it would return more than one code where the first 6 digits might match multiple codes.  It might have been best to make a map of the dict keys or just add an extra key as an int but reversing the list of strings worked fine too.

As I mentioned in my previous post, keeping the actual test in mind, this whole exercise was effectively pointless 🤷‍♂️. It would have been much easier to write a bash script to just test if one code was ‘close’ to another from looking at a phone code map and hardcodeing a set of values, but, Ive had fun learning some python along the way!

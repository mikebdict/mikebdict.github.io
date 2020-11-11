---
title: Haiku Space bot
date: 2020-10-21 18:00 +00:00
tags: [Python, Beautiful Soup, Selenium, pywand]
description: A collection of functions that post a picture and text mashup to facebook every day.
image: assets/img/hk_spacebot_og.jpg
---
![Knockd config screen shot](/assets/img/hk_spacebot_fb.jpg){: style=padding:16px"}

##### Facebook selenium bot.
[Github repo](https://github.com/mikebdict/hkspacebot)

One thing I'd wanted to do for a while was run a program that auto-posted pictures with accompanying text to facebook. Initially, I thought i'd be able to do what I wanted with graph api, but as it turns out this was actually impossible.

Not impossible to implement, but impossible to achieve currently… I was able to write the posting part to the bot using the python facebook library, which worked fine but it then took me a while to discover that posts made by facebook apps without verification cant be seen by anyone apart from yourself. What they dub ‘individual verification’ has been suspended since May. As I decided that I wouldn't fib and try to fabricate a business just to run a pictures and text bot, I decided to go with another option - selenium.

When you have problems like this doing things the canonical way and encounter issues that are quite hard to fish out, its really no surprise that so many people do things the ‘non-standard’ way. Perhaps Facebook cares, perhaps they don't - it's all traffic on their site at the end of the day I guess.

My bot has been running for over a month now, and works pretty successfully. There's still some things I could do better, like, some more persistence between it running and better fault handling in places, but overall i'm happy with it and I learned a lot whilst doing it.

The first thing was settling on a source for the poems. I like Haikus in general and I think they go quite well with pictures of space :) I wanted to find a website that would make it fairly easy for me to download a lot of poems, or at least, have a lot of links easily accessible. I wrote a small bash script that used wget to download a load of index pages then wrote [BS4_HK_page_downloader.py](https://github.com/mikebdict/hkspacebot/blob/master/BS4_HK_page_downloader.py) to extract all the links to the individual poems and download them.

[BS4_HK_extractor.py](https://github.com/mikebdict/hkspacebot/blob/master/BS4_HK_extractor.py) loops through all the download pages and uses Beautiful soup to extract the poems, save them to a list and saves it to a pickle file. The list returned from the function, that we will post on facebook later looks like this
```bash
haiku_spacebot_log_li = [
    'masaoka shiki',
    'the sky draws near', 
    "the sky draws near\nsuch a bright sunrise\nNew Year's Day"
    ],
```
[NASA_OPUS_downloader.py](https://github.com/mikebdict/hkspacebot/blob/master/NASA_OPUS_downloader.py) Uses data from a CSV generated from NASA’s OPUS website, then combines that data with some static urls to fetch a JSON from NASA’s site. This JSON contains an image url and some technical information about the image. The image is saved, and the relevant parts of the JSON are saved into a list that the function returns.

![Space rocks...](/assets/img/co-iss-n1831443018.jpg){: style="float:left; padding-right:16px"} This is one of the images that program downloads and below is the telemetry data we get from the JSON to overlay on the image in the next step.
{: style="padding-bottom:200px"}

```bash
haiku_spacebot_log_li = [ 
        [['COISS_2024/data/1532374774_1532425248/N1532375151_1.IMG',
         'Cassini ISS', 
        '2006-07-23T19:14:36.556', 
        'Saturn Rings'], 
        'https://opus.pds-rings.seti.org/opus/__api/metadata_v2/co-iss-n1532375151.json', 
        'datadir/images/2020-11-10/co-iss-n1532375151.jpg'
        ]
        ]
```
[Pywand_image_combiner.py](https://github.com/mikebdict/hkspacebot/blob/master/pywand_image_combiner.py) Takes the image and text returned by the downloader function and uses pywand to resize the image to a standard format, and overlay the technical information over the top of the photo to create a composited image.

![Space rocks...](/assets/img/wand_co-iss-n1831443018.jpg){: style="float:left; padding-right:16px"} The same image after pywand overlaid the telementry data and put a border around the image.
{: style="padding-bottom:200px"}

[Facebook_bot_selenium.py](https://github.com/mikebdict/hkspacebot/blob/master/facebook_bot_selenium.py) is a function that opens up its own facebook profile and posts supplied text and images to its wall.

[Poster.py](https://github.com/mikebdict/hkspacebot/blob/master/poster.py) accesses all the functions and finally calls the Facebook function to post a random HK with the composited pywand image. When the program has finished it prints the program log to stdout. I use a crontab to run this, calling the virtual environment which the program runs and redirecting the output to a log file. My exim config mails me if the bot fails for some reason. [Exit_test.py](https://github.com/mikebdict/hkspacebot/blob/master/exit_test.py) shows how the final log looks. The crontab entry is below.

```bash
0 12 * * * /usr/bin/bash -c 'cd (project path) && source (projectpath)/venv/bin/activate && python3 poster.py | grep "\[\["' >> (project path)/datadir/logs/hkspacebot.log 2>&1
```

There's a nice element of randomness to the whole process , since there are a lot of poems and over 360,000 entries in the csv file for the json download to pick from. One thing I gleaned from running the selenium bot for a while that not many of the guides I read touched on was the importance of giving it its own persistent data profile, and using this each time its run. This is perhaps somewhat contra to what selenium is used for in the main, which is why I guess people dont mention it much. Facebook is famous for irritating people by changing its layouts, asking you things via new popups and generally adapting its UX while it ‘gets to know’ a user. This obviously doesn't play very nicely with selenium in some ways, since things like the xpath selection will change frequently if your using a new account / browser to run a bot. It settles down after a while though, and if you build in some fault finding into what you're doing, you can at least get a quick indication as to what failed in retrospect.

At one point I was toying with the idea using a maria db for some of the persistence aspects, and using classes to update that. It would definitely result in something a bit neater at points and it would be nice to have some easy to access mechanism of what the bot has done in the past as opposed to grepping through log files. I hadnt really started to learn about classes when I started the project and still find it hard sometimes to define why / when I should use a class rather than a function.

My next project uses a classes a lot as its a flask app. Perhaps when im done with that ill come back to this and update it in a number of ways.
---
title: Python Version switcher
date: 2020-06-06 15:26 +00:00
tags: [bash, python, PS3, AWK]
description: Upping my Bash game
---

[Python version changer](https://github.com/mikebdict/pythonvchange/blob/master/pythonVchange.sh)

I've been trying to up my bash game over the last few months and thought Id explain some elements of a script I created recently that changes the softlinked version of python in my */usr/bin* folder so it might be useful to some one else learning.

Ive never really played around with AWK that much before. In the past when ever I've needed to do some regex or something like that I'd use perl (or more specifically some one elses Perl that I would then basterdise 👀). After reading up on it, I realise how powerful it is and that its greatest strong point is that so many of the considerations that you might have when useing something like perl are moot. AWK is pretty much installed everywhere, so you just dont have to worry.

The AWK part of the script was fairly easy to implement, just a little bit of testing to find out the right part of my ls / find output for the substring command to latch on to.

```bash
$ ls -l /usr/bin/python
lrwxrwxrwx 1 root root 18 Jun  4 14:49 /usr/bin/python -> /usr/bin/python2.7
# 11 Fields with "python2.7" starting from the 10th character of that field.
$ ls -l /usr/bin/python | awk '{print substr($11,10);}'
python2.7 
```

The next part was intialiseing an [array](https://tldp.org/LDP/abs/html/arrays.html) then haveing [PS3](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_06.html)  prompt the user for a choice. Im now useing PS3 all the time, as it saves you writeing a lot of error handleing vs only useing a select loop.

```bash
# Find all the different python binaries in /usr/bin then have awk chop the right bits out so we can use them later in the script
$ posspyv=$( find /usr/bin -maxdepth 1 -type f -name 'python*' | awk '{print substr($1,10);}')
$ echo $posspyv
python3.6 python2.7 python3.6m
# Intialise the $posspyv var as an array
$ posspyar=($posspyv)
$ echo ${posspyar[0]}
python3.6
```

After that everything is setup to switch versions by just removeing the the softlink and replaceing it with whatever the user picked. As this is working in */usr/bin* the script obvs needs root access, so I dropped a few extra lines in my */etc/sudoers.d/* file to stop it nagging me.

```bash
cat /etc/sudoers.d/gorby
gorby ALL=(root) NOPASSWD:/bin/rm /usr/bin/python
gorby ALL=(root) NOPASSWD:/bin/ln -s /usr/bin/python2.7 /usr/bin/python
gorby ALL=(root) NOPASSWD:/bin/ln -s /usr/bin/python3.6 /usr/bin/python
gorby ALL=(root) NOPASSWD:/bin/ln -s /usr/bin/python3.6m /usr/bin/python
```

[Remember](https://help.ubuntu.com/community/Sudoers) if your going to edit */etc/sudoers* dont do it directly unless your a real manly man. *visudo* will check for syntax / formating errors in the file before saveing it. As well as that the last line in the file (#includedir /etc/sudoers.d) *IS NOT* a comment, it actually enables the per user sudoers files in */etc/sudoers.d*.

Part of LPIC's sylabus requires you to be familiar with vim. If your preping up for it, Id recommend changeing your default editor as is outlined in that help article. Even if your just getting used to basic opperations that changeing your default will enable its gonna help. 

You might end up being the millionth person who googles how to exit vim, but, dont fret ;)










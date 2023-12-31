---
title: "I'm Giving NixOS a Try"
date: 2023-12-30T21:30:00-08:00
tags: ["nix"]
---

There has to be a better way to manage the state of a computer, right?
Is NixOS it?
I don't know yet, but it can't be any worse than what I'm doing now, _right?_

<!--more-->

## Motivation

Earlier this year, it happened (again):
I broke my development virtual machine (VM) during an upgrade.
I don't know the exact details as to what went wrong, but I didn't set myself up for success:

1. I hadn't been working in the VM for a couple of months, so its packages were fairly out of date.
2. More importantly, I forgot to create a snapshot of the VM before attempting the upgrade.

Truthfully, the second point above is the only reason why I'm writing this.
If I had a way to simply revert the VM, I'd still be using the same Debian VM for all my development.
Funny enough, many years ago I switched my development VM to use Debian instead of CentOS because I got myself into this same situation back then,
and I thought "Debian's more stable. This won't happen with Debian."
Also, having done several system upgrades with Debian before, which were all painless, I was fairly hopeful upgrading to Bookworm was going to be just as easy.

The good news is that after a couple of days of reading forums and debugging, I was able to get the VM stable enough to accomplish what I originally set out to do.
The bad news is that it took a couple of days, which translated to me working long hours at night to make up for the lost time.

## Meditation

To be clear, I'm not slinging mud at Debian, and I take complete ownership of what happened.
As I wrote above, there were things I should have done to mitigate and protect myself from this breakage.

But you know what? Working in that environment was beginning to feel bloated and brittle.
Again, that's not specific to Debian.
I felt that same way when I used CentOS, and OpenSuse before that.
I tend to install a lot of packages as time goes on, and I don't usually remove packages out of fear of breaking something.
Thinking back on it, I didn't need eight (8!) versions of Java installed in `/usr/java`.
I didn't even need Java at the system level.
I really only needed the version of Java for the project I was working on at the moment.
The same goes for Node.js and all the various CLI tools I get through that ecosystem.
Docker helps and did help with managing and containing a project's software, but I didn't containerize every tool I used (but maybe I should of!), and Docker images aren't cheap.
I already had to put my VM on an external hard drive because it took too much space on my laptop.
Suffice it to say that the problem was, is, and will continue to be me.

So if I love developing on Linux but I'm terrible at managing Linux, then am I doomed?
Maybe, but what about NixOS?
Wasn't that built to address the main issues I'm dealing with?

## A New Hope?

I really don't know much about Nix, let alone NixOS.
I remember learning about it years ago from [The Changelog podcast (episode 437)](https://changelog.com/podcast/437) and thinking, "I need to look into this."
Well, there's no better time than now to check it out.

My initial expectation is to create and maintain a very minimal system and user profile. 
For each software project that I am working on, I plan to use `nix-shell` (or whatever its equivalent is when using flakes) to manage the extra system dependencies needed for that project.
I'm not interested in using Nix as my software build system, but we'll see how far I can get with this mindset.
I'll still use Docker for more complex projects, but if I just need Java 17, then `nix-shell -p zulu17` should suffice.
Afterwards, I can run the Nix garbage collector and free up space.
I hope to keep the new VM very lean.

At the time of writing, I have a new VM with NixOS installed on it.
I'm reading the [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) and looking at Nix files I find on GitHub.
I have successfully used Nix flakes to model my minimum system along with my user profile using Home Manager.
I'm managing the configuration with Git and have pushed it to my work's GitLab repository.
(Oh yeah, this whole thing is within the context of managing my development environment at work.
If things works out well, I might expand it to include managing my personal laptop.)
I'm excited and terrified.

I hope to write more about this journey as it unfolds.

---
layout: post
title: "Using Octopress as a Photo Blog"
date: 2012-09-26 11:00
comments: false
categories:
- Computers
author: Aijaz Ansari
tags:
- Octopress
- Photography
description: "In this post I illustrate how I modified the default Octopress theme and added a type of layout that highlights a single photograph."
---

<!-- ai l /images/photoblog/hero.png /images/photoblog/heroSmall.png 320 480 A Layout for Photos -->

As an amateur photographer I like displaying my photos on my blog, especially when there are particularly interesting stories behind them. In this post I illustrate how I modified the default Octopress theme and added a type of layout that highlights a single photograph. 



<!-- more -->

Before I got started I identified the key requirements for my new layout: 

1. In this new layout the photograph should be the primary focus of the page.
2. The header above the navigation bar should be diminished, to allow for more vertical real estate for the photograph.
3. All the details of the photograph should be specified in the YAML preamble of the post.  The contents should only be notes.
4. Octopress should automatically display a thumbnail of the photograph in the Index view.
5. The photographs should be optimized for Retina displays, but still look good on normal displays
6. The header should not be displayed at the top of the page.  Instead, it should be displayed underneath the photograph.


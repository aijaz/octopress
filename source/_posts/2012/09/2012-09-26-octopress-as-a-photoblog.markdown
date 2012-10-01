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

As an amateur photographer I like displaying my photos on my blog, especially when there are particularly interesting stories behind them. In this post I illustrate how I modified the default Octopress theme and added a type of layout that highlights a single photograph.  You can see an example of this in [this sample blog](http://testphoto.aijazansari.com).  The first post in this sample blog is a "regular" post, and the second is a photo post - a photo of Cloud Gate, also known as "The Bean."


<!-- more -->

## Requirements

Before I got started I identified the key requirements for my new layout: 

1. In this new layout the photograph should be the primary focus of the page.
2. The header above the navigation bar should be diminished, to allow for more vertical real estate for the photograph.
3. All the details of the photograph should be specified in the YAML preamble of the post.  The contents should only be notes.
4. Octopress should automatically display a thumbnail of the photograph in the Index view.
5. The photographs should be optimized for Retina displays, but still look good on normal displays
6. The header should not be displayed at the top of the page.  Instead, it should be displayed underneath the photograph.



## The New YAML Tags

In this solution the YAML preamble dictates how the page is displayed.  Most importantly, instead of this tag
    layout: post
what you should have is 
    layout: photo
The following YAML tag is required.  It specifies the (absolute or relative) URI of the photograph. 
{% codeblock lang:bash %}
image: /images/photos/coolPhoto.jpg
# The width and height of the photo in pixels
photoWidth: 768
photoHeight: 511
{% endcodeblock %}


The following tags are also supported, and are optional.  If you include them, the respective value will be displayed on the web page. All of these values are treated as strings.  In the file below, a sample value is shown, and a descriptive comment appears above the tag.
{% codeblock lang:bash %}
# The URI to a thumbnail image. This thumbnail
# will be displayed on the index page.
thumbnail: /images/photos/coolPhotoTn.jpg

# The width and height of the thumbnail image in pixels
thumbnailWidth: 384
thumbnailHeight: 256

# ISO
iso: 400

# The aperture value 
aperture: 4.8

# Shutter speed in seconds
shutterSpeed: 0.4

# Focal length of the lens
focalLength: 24.0 mm

# Scale Factor to 35mm
scaleFactor: 1.0

# Flash
flash: No Flash

# Exposure Compensation
expComp: N/A

# Camera Model
camera: Nikon D700

# Lens 
lens: AF-S VR Zoom-Nikkor 24-120mm f/3.5-5.6G IF-ED

# Photographer Name
creator: Your Name Here

# Date and Time the photograph was taken
dateTaken: 2012/03/29 16:21:19

# Copyright information
copyright: Copyright 2012 Your Name Here

# License information
license: <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-nd/3.0/80x15.png" /></a>

# The URI to an image of the photo's histogram
histogram: /images/photos/coolPhotoHist.jpg

# The width and height of the histogram in pixels
histogramWidth: 128
histogramHeight: 50

{% endcodeblock %}    
These are just the tags that are supported by the system described in this blog post.  You can always add more tags and use them in ```photoFile.html``` file that you'll see in a little bit.  Later in this post I'll show you how to extract this information from your photograph's [EXIF data](http://digital-photography-school.com/using-exif-data).

## Layouts and Includes

### The Layout

The first step is to create a new layout file.  Since we're using ```layout: photo``` in the YAML preamble, we need to create a file called ```source/_layouts/photo.html```.  This layout file is almost identical to ```source/_layouts/post.html```, so I'll just show you the diffs: 

{% include_code photo.diff lang:diff photoBlog/photo.diff %}

Here are the changes: 

- I've set the ```sidebar``` YAML tag to ```collapse```.  This instructs octopress to collapse the sidebar and display it instead at the bottom. 
- I've set the ```no_header``` tag to ```true``` so that the post header is not displayed.
- I've set a new YAML tag: ```header: condensed```.  We'll see how this is used a little later.
- Instead of including article.html, I'm including photoFile.html.

Now that we've told Octopress that the photo layout should include photoFile.html, it's time to have a look at that file. Since it's so similar to article.html (before we change that file), I'll just show you the differences between the two files: 

{% include_code photoFile.html lang:diff photoBlog/photoFile.diff %}

As you can see, what we've done is replace line 4 with lines 5 through 30.  Instead of merely displaying the ```content```, we're also displaying a table with all the EXIF data that we provided in the YAML preamble.  We wrap each table row in an if/endif block, so that we don't include blank rows if any of the EXIF data is missing. 

If you want to support more data than you see in this table, simply modify this table, and then make sure to include that data in the YAML preamble.

### Displaying Thumbnails in the Index

In order to display the thumbnail of the image in the index view I changed source/_includes/article.html: 

{% include_code article.html lang:diff photoBlog/article.diff %}

What this says is that if Octopress is displaying the index and the current post's YAML has a ```thumbnail``` tag defined then display the thumbnail image in its own div and make the thumbnail a link to the actual post. 

### Condensing the Header

To get the condensed version of the header I changed source/_layouts/default.html: 

{% include_code default.html lang:diff photoBlog/default.diff %}

In the first set of changes (lines 5-10), if the page has a YAML tag of ```header``` whose value is ```condensed```, then instead of including header.html, we'll include custom/headerCondensed.html.  In the second set of changes (lines 12-15) we assign a class of ```photo``` to the ```main``` and ```content``` divs if the posts YAML has an ```image``` -- in other words, if the post is a photo layout post.  This is merely so that we can apply different styles to the photo pages.

The custom/headerCondensed.html file is shown below:

{% include_code custom/headerCondensed.html lang:html photoBlog/headerCondensed.html %}


## CSS Changes

All of the changes to CSS are in sass/custom/_styles.scss: 

{% include_code _styles.css lang:css photoBlog/styles.scss %}


## Supporting Retina Displays

It is easy to add support for retina displays using [retina.js](http://retinajs.com).  I added retina.js to source/javascripts and modified source/_includes/custom/after_footer.html as follows: 

{% include_code after_footer.html lang:diff photoBlog/after_footer.diff %}

I chose to add retina.js to photo pages (pages that have an ```image``` YAML tag) and to index pages (for the thumbnails).  If you want, you can chose to add retina.js all the time.  In order to get this to work, I also had to add @2x versions of the main photo, the thumbnail as well as the histogram image. 
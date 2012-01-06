#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use File::Find;
use HTML::TreeBuilder;

# The file that was specified on the command line
#

my $public_dir  = 'public';
my $custom_file = 'source/_includes/custom/tag_cloud.html';
my $result = { };

find(\&getTags, $public_dir);

# Now calculate the tag ranges.
# My fonts have weights of 200, 300, 400, 700, 900, so I'll 
# combine these with sizes for 10 ranges

my $max = 0;
foreach my $tag (keys %$result) {
    $result->{$tag}->{count} = scalar(@{$result->{$tag}->{pages}});
    if ($result->{$tag}->{count} >= $max) {
        $max = $result->{$tag}->{count};
    }
}

if ($max == 0) { 
    $max = 1; # to prevent divide by zero later
}


# Now that we have the grand total, let's get the ranges

my $num_ranges = 10;
#my $range_size = int(($max / $num_ranges) + 0.5); # round to the nearest whole number
my $range_size = ($max / $num_ranges);
if ($max < 10) { 
    $range_size = 1;
}



foreach my $tag (keys %$result) {
    $result->{$tag}->{range_num} = int(($result->{$tag}->{count} / $max) * 10 + 0.5); # nearest whole number
}

open (O, ">$custom_file") || die;
print O "<div id='tag_cloud'>\n";
foreach my $tag (sort { lc($a) cmp lc($b)} keys %$result) {
    my $plural = "y";
    if ($result->{$tag}->{count} > 1) { $plural = 'ies'; }

    print O qq[<a href="/tags/$tag/" title="$result->{$tag}->{count} entr$plural" class="tag_$result->{$tag}->{range_num}">$tag</a>\n];
}
close O;


# Now save the individual tag files

# clear out the directory because we're gonna regenerate all the files.
#
die "source/tags should be a directory, but is a file instead" if (-f "source/tags");

if (!-d "source/tags") { 
    mkdir "source/tags";
}
else {
    `find source/tags/* -type d -exec /bin/rm -rf \{\} \\;`;
    #`/bin/rm  -r source/tags/*/*`;
    #`/bin/rmdir source/tags/*`;
}



foreach my $tag (keys %$result) { 
    makeTagFile($tag);
}


sub makeTagFile { 
    my $tag = shift;
    mkdir "source/tags/$tag" || die "Couldn't make directory source/tags/$tag";

    open (O, "> source/tags/$tag/index.markdown") || die "Can't open source/tags/$tag/index.markdown";
    print O qq^---
layout: page
title: Tag&#58; $tag
footer: false
---

<div id="blog-archives" class="category">
^;

    my $year = 0;
    foreach my $file (sort { $b->{file} cmp $a->{file} } @{$result->{$tag}->{pages}}) {
        my ($yyyy, $mm, $dd) = $file->{file} =~ m!(\d\d\d\d)/(\d\d)/(\d\d)/!;
        if ($yyyy != $year) { 
            $year = $yyyy;
            print O "<h2>$year</h2>\n";
        }
        my $url = $file->{file};
        $url =~ s/^public//;
        my $title = $file->{title};
        my @months = qw ( x Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
        my $mon = $months[$mm * 1];

        print O qq[
<article>
<h1><a href="$url">$title</a></h1>
<time datetime="$yyyy-$mm-${dd}T00:00:00-06:00" pubdate><span class='month'>$mon</span> <span class='day'>$dd</span> <span class='year'>$yyyy</span></time>
<footer>
<span class="categories">posted in 
];

        print O join(", ", map { "<a href='$_->{href}'>$_->{text}</a>" } @{$file->{categories}});
print O qq[</span>
</footer>
</article>
];
    }

    print O "</div>\n";
    close O;
}

        
    

sub getTags {
    my $file = $File::Find::name;

    return unless $file =~ /\.html$/;
    return unless $file =~ /^public\/\d{4}\/\d{2}\/\d{2}\//;
    #return if $file =~ /^public\/tags/;
    #return if $file =~ /^public\/categories/;
    #return if $file =~ /^public\/ignore/;
    #return if $file =~ /^public\/downloads/;
    #return if $file =~ /^public\/404.html/;
    #return if $file =~ /^public\/index.html/;
    #return if $file =~ /^public\/about\/index.html/;
    #return if $file =~ /^public\/blog\/archives\/index.html/;
    #return if $file =~ /^public\/page/;
    ##return unless $file eq "public/2012/01/04/extracting-a-column-from-a-text-file/index.html";
    #print "file is $file\n";

    open (HTML, $_) || die "Can't open $file";
    my $contents = join("", <HTML>);
    close HTML;

    my $tree = HTML::TreeBuilder->new();
    $tree->parse($contents);
    my $title = $tree->look_down("_tag", "h1", "class", "entry-title");
    $title = $title->as_trimmed_text();
    my $category_ent = $tree->look_down("_tag" => "span", class => "categories");
    my @as = $category_ent->look_down("_tag" => "a", class => "category");
    my @categories = ();
    foreach my $a (@as) { 
        push(@categories, { href => $a->attr('href'), text => $a->as_trimmed_text});
    }

    my $ul = $tree->look_down("_tag", "ul", 
                              "id"  , "tags_ul");
    if ($ul) { 
        my @items = $ul->look_down("_tag" => "li");
        foreach my $item (@items) {
            my $tag = $item->as_trimmed_text();
            push (@{$result->{$tag}->{pages}}, { title => $title, file => $file, categories => \@categories } );
        }
    }
    else { 
        #else print "Couldn't find anything in $file\n";
    }

    $tree->delete();
    
}


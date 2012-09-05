#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use File::Basename;

my $image = '';
my $title = '';
my @tags;
Getopt::Long::GetOptions(
    "image=s"     => \$image,
    "title=s"     => \$title,
    "tag=s"       => \@tags,
    );

die "--image ($image)  not specified or does not point to an existing file" unless -f $image;

my ($baseName, $path, $suffix) = fileparse($image, qr/\.[^.]*/);

if ($baseName !~ /\@2x$/) { die "The image name should end with \@2x"; } 

my $realBase = $baseName;
$realBase =~ s/\@2x//;

my $regularImage = "$path$realBase$suffix";
my $tn = "$path${realBase}_tn$suffix";
my $tn2 = "$path${realBase}_tn\@2x$suffix";
my $hist = "$path${realBase}_hist.png";

# original dimensions should be 2040x1360 or 902x1356
my $img_info         = `identify $image`;
my @info_list        = split(/ /, $img_info);
my ($width, $height) = $info_list[2] =~ /(\d+)x(\d+)/;


doSys("convert $image -resize '50%' $regularImage");

if ($width > $height) { 
    doSys("convert $image -resize  '384x256' $tn");
    doSys("convert $image -resize  '768x512' $tn2");
}
else { 
    doSys("convert $image -resize  '256x384' $tn");
    doSys("convert $image -resize  '512x768' $tn2");
}
doSys("convert $image -define histogram:unique-colors=false  histogram:$hist");
doSys("mogrify -format png -fuzz 40% -fill \"#999999\" -opaque \"#000000\" -resize 128x50! $hist");

my $tags = join (" ", (map { "--tag '$_'"} @tags));

if ($title) {
    doSys("./generatePhotoPost.pl --image $regularImage --thumbnail $tn --title '$title' --histogram $hist $tags");
}


sub doSys {
    my $cmd = shift;
    print "SYS: $cmd\n";
    my $a = `$cmd`;
    die $@ if $?;
}

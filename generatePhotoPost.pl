#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Image::ExifTool qw(:Public);
use File::Basename;
use File::Path qw (make_path);
use File::Copy;

my $creator = "Aijaz Ansari";

my $file;
my $image;
my $title;
my @tags;
my $date;
my $thumbnail;
my $histogram;
my $exif_h;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon++;
$year += 1900;

Getopt::Long::GetOptions(
    "image=s"     => \$image,
    "thumbnail=s" => \$thumbnail,
    "histogram=s" => \$histogram,
    "title=s"     => \$title,
    "tag=s"       => \@tags,
    );

my $fileTitle = lc($title);
$fileTitle    =~ s/\s+/-/g;
$fileTitle    =~ s/^\-//;
$fileTitle    =~ s/\-$//;

my $dir = sprintf("source/_posts/%d/%02d", $year, $mon);
print "Directory: $dir\n";

if (! -e $dir) {
    print "Making directory\n";
    make_path($dir);
}
elsif (! -d $dir) {
    die "ERROR: $dir is a file.  It needs to be a directory.";
}

my $fileName = sprintf("$dir/%d-%02d-%02d-%s.markdown", $year, $mon, $mday, $fileTitle);
print "fileName: $fileName\n\n";

my $exif = ImageInfo($image);

unless ($thumbnail) {
    $thumbnail = $image;
    $thumbnail =~ s/\./T./;
}

my $postDate = sprintf("%d-%02d-%02d %02d:%02d", $year, $mon, $mday, $hour, $min);

my $imageUrl = $image;
$imageUrl =~ s/.*source//;

my %hash = ();

if ($thumbnail) {
    my $thumbnailUrl = $thumbnail;
    $thumbnailUrl =~ s/.*source//;
    $hash{thumbnail} = $thumbnailUrl;
    my $img_info         = `identify $thumbnail`;
    my @info_list        = split(/ /, $img_info);
    ($hash{thumbnailWidth}, $hash{thumbnailHeight}) = $info_list[2] =~ /(\d+)x(\d+)/;
}

if ($histogram) {
    my $histogramUrl = $histogram;
    $histogramUrl =~ s/.*source//;
    $hash{histogram} = $histogramUrl;
    my $img_info         = `identify $histogram`;
    my @info_list        = split(/ /, $img_info);
    ($hash{histogramWidth}, $hash{histogramHeight}) = $info_list[2] =~ /(\d+)x(\d+)/;
}

my $img_info         = `identify $image`;
my @info_list        = split(/ /, $img_info);
($hash{photoWidth}, $hash{photoHeight}) = $info_list[2] =~ /(\d+)x(\d+)/;


my $tags = "";
if (@tags) {
    $hash{tags} = join("\n",
                         "",
                         (map { "- $_" } @tags)
        );
}


open (F, ">$fileName.temp") || die "Cannot open $fileName for writing";
print F join("\n",
             "---",
             "layout: photo",
             "title: \"$title\"",
             "date: $postDate",
             "comments: false",
             "categories:",
             "- Photos",
             "author: Aijaz Ansari",
             "image: $imageUrl",
             "",
    );

#print Dumper (keys %$exif);

if ($exif->{ISO}) { $hash{iso} = $exif->{ISO}; }
if ($exif->{Aperture}) { $hash{aperture} = $exif->{Aperture}; }
if ($exif->{"ShutterSpeed"}) { $hash{shutterSpeed} = $exif->{"ShutterSpeed"}; }
if ($exif->{"FocalLength"}) { $hash{focalLength} = $exif->{"FocalLength"}; }
if ($exif->{"ScaleFactor35efl"}) { $hash{scaleFactor} = $exif->{"ScaleFactor35efl"}; }
if ($exif->{"Flash"}) { $hash{flash} = $exif->{"Flash"}; }
if ($exif->{"ExposureCompensation"}) { $hash{expComp} = $exif->{"ExposureCompensation"}; }
if ($exif->{"Model"}) { $hash{camera} = $exif->{"Model"}; }
if ($exif->{"LensID"}) { $hash{lens} = $exif->{"LensID"}; }
elsif ($exif->{"LensInfo"}) { $hash{lens} = $exif->{"LensInfo"}; }
elsif ($exif->{"LensModel"}) { $hash{lens} = $exif->{"LensModel"}; }
elsif ($exif->{"Lens"}) { $hash{lens} = $exif->{"Lens"}; }
if ($exif->{"Creator"}) { $hash{creator} = $exif->{"Creator"}; }
if ($exif->{"DateTimeOriginal"}) { $hash{dateTaken} = $exif->{"DateTimeOriginal"}; }
elsif ($exif->{"CreateDate"}) { $hash{dateTaken} = $exif->{"CreateDate"}; }
elsif ($exif->{"DateCreated"}) { $hash{dateTaken} = $exif->{"DateCreated"}; }
if ($exif->{"Copyright"}) { $hash{copyright} = $exif->{"Copyright"}; }
elsif ($exif->{"CopyrightNotice"}) { $hash{copyright} = $exif->{"CopyrightNotice"}; }

$hash{creator} = $creator unless $hash{creator};
$hash{lens} = '"'.$hash{lens}.'"';

my $license = qq^
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/StillImage" property="dct:title" rel="dct:type">$title</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="{{ site.root }}/$imageUrl" property="cc:attributionName" rel="cc:attributionURL">$hash{creator}</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/deed.en_US">Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>.
^;

$hash{license} = qq[<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" /></a>];

foreach my $k (sort keys (%hash) ) {
    print  F "$k: $hash{$k}\n";
}
print F "---\n";

# if the actual file already exists, and if there's any text there, print it here, so we don't lose it
if (open (ORIG, "$fileName")) {
    my $numSeen = 0;
    while (<ORIG>) {
        if (/^---\s*$/) {
            $numSeen++;
            if ($numSeen == 2) {
                last;
            }
        }
    }
    while (<ORIG>) {
        print F $_;
    }
    close ORIG;
}

close F;

my $success = move("$fileName.temp", $fileName);
if (! $success) {
    die "Couldn't move temp file \n  $fileName.tmp \n  to actual file\n  $fileName\n\n  Actual file may be corrupted. Recover data from temp file now.";
}



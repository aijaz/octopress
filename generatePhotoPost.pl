#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Image::ExifTool qw(:Public);
use File::Basename;
use File::Path qw (make_path);

my $file;
my $image;
my $title;
my @tags;
my $date;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon++;
$year += 1900;

Getopt::Long::GetOptions(
    "image=s"   => \$image,
    "title=s"   => \$title,
    "tag=s"     => \@tags,
    );

my $fileTitle = lc($title);
$fileTitle    =~ s/\s+/-/g;
$fileTitle    =~ s/^\-//;
$fileTitle    =~ s/\-$//;

my $dir = sprintf("source/posts/$d/%02d", $year, $mon);


if (! -e $dir) {
    make_path($dir);
}
elsif (! -d $dir) {
    die "ERROR: $dir is a file.  It needs to be a directory.";
}

$fileName = sprintf("$dir/%d-%02d-%02d-%s.markdown", $year, $mon, $mday, $fileTitle);








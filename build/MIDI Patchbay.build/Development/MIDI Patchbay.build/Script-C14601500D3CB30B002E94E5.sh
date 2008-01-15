#!/usr/bin/perl -w
# Xcode auto-versioning script for Subversion
# by Axel Andersson, modified by Daniel Jalkut to add
# "--revision HEAD" to the svn info line, which allows
# the latest revision to always be used.

# See http://www.red-sweater.com/blog/23/automatic-build-sub-versioning-in-xcode#finalscript

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

# Get the current subversion revision number and use it to set the CFBundleVersion value
my $REV = `/opt/local/bin/svnversion -n ./`;
my $INFO = "$ENV{BUILT_PRODUCTS_DIR}/$ENV{WRAPPER_NAME}/Contents/Info.plist";

my $version = $REV;

# (Match the last group of digits and optional letter M/S):

# ugly yet functional (barely) regex by Daniel Jalkut:
#$version =~ s/([\d]*:)(\d+[M|S]*).*/$2/;

# better yet still functional regex via Kevin "Regex Nerd" Ballard
#($version =~ m/\d+[MS]*$/) && ($version = $&);

# or a custom version that ignores the M and S flags by Pete Yandell
($version =~ m/(\d+)[MS]*$/) && ($version = $1);

die "$0: No Subversion revision found" unless $version;

open(FH, "$INFO") or die "$0: $INFO: $!";
my $info = join("", <FH>);
close(FH);

$info =~ s/([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>).*?(<\/string>)/$1$version$2/;

open(FH, ">$INFO") or die "$0: $INFO: $!";
print FH $info;
close(FH);


#!/usr/bin/perl

use strict;
use Getopt::Long;
use JSON;

my $opt_1;    # var_type = scalar
my $opt_2 = '';    # var_type = scalar

GetOptions(
    'fla--g!' => \$opt_1,
    'file|f=s' => \$opt_2,
) or die ("Error in command line argument.\n");

my $all_opt = {
    'fla' => $opt_1 ? JSON::true : JSON::false,
    'file' => $opt_2,
};

open JSON, '>tmp.json' or die 'Cannot create temp file: tmp.json';
print JSON to_json($all_opt, {pretty => 1});
close JSON;

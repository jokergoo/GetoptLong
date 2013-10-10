#!/usr/bin/perl

use strict;
use Getopt::Long qw(:config bundling);
use JSON;
use Data::Dumper;

my $opt_1;    # var_type = scalar, opt_type = logical
my $opt_2;    # var_type = scalar, opt_type = logical
my $opt_3;    # var_type = scalar, opt_type = logical
my $opt_4;    # var_type = scalar, opt_type = logical
my $opt_5;    # var_type = scalar, opt_type = logical

eval { GetOptions(
    'red|r' => \$opt_1,
    'blue|b' => \$opt_2,
    'yellow|y' => \$opt_3,
    'help' => \$opt_4,
    'version' => \$opt_5,
) or die 'Errors when parsing command-line arguments.'; };

if($@) { exit(123); }


my $all_opt = {
    'red' => $opt_1 ? JSON::true : JSON::false,
    'blue' => $opt_2 ? JSON::true : JSON::false,
    'yellow' => $opt_3 ? JSON::true : JSON::false,
    'help' => $opt_4 ? JSON::true : JSON::false,
    'version' => $opt_5 ? JSON::true : JSON::false,
};

open JSON, '>tmp.json' or die 'Cannot create temp file: tmp.json\n';
print JSON to_json($all_opt, {pretty => 1});
close JSON;

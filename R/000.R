msg = system("perl -v")
if(msg) {
    stop("Can not find Perl in your PATH.\n")
}

msg = system("perl -MGetopt::Long")
if(msg) {
    stop("Can not find Perl module Getopt::Long.\n")
}

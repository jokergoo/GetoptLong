
This R package is a wrapper of perl module `Getopt::Long`. The main workflow of `GetoptLong` package is:

1. generate perl script according to option design.
2. pass command-line arguments to perl script.
3. perl script parses command-line arguments by `Getopt::Long` and write into file which is formatedd in json by `JSON` module.
4. the R package read json file by `rjson` package.
5. export option into user's environment.

Besides keeping the power of `Getopt::Long`, this R package has some other advantages:

1. check mandatory options
2. can print the help message according to option design
3. set default values
4. import options as R variables into user's working environment automatically

The usage of this R package is quite similar as the perl module.

    output = "output.txt"
    spec = c(
        "input=s", "input file",
        "output:s", "output file",
        "verbose!", "print message"
    )
    GetoptLong(spec)
    
In above example, `output` has a default value, `input` and `verbose` will be imported into working environment.

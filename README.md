[![Build Status](https://travis-ci.org/jokergoo/GetoptLong.svg)](https://travis-ci.org/jokergoo/GetoptLong) [![CRAN](http://www.r-pkg.org/badges/version/GetoptLong)](https://cran.r-project.org/web/packages/GetoptLong/index.html) [![codecov](https://img.shields.io/codecov/c/github/jokergoo/GetoptLong.svg)](https://codecov.io/github/jokergoo/GetoptLong) 

GetoptLong
============

This is yet another command-line argument parser which wraps the 
powerful Perl module [`Getopt::Long`](http://perldoc.perl.org/Getopt/Long.html) and with some adaptation for easier use
in R. It also provides a simple way for variable interpolation in R.

There are two vignettes in the package which explain in more detail:

1. [Parsing command-line arguments by Getopt::Long](https://cran.r-project.org/web/packages/GetoptLong/vignettes/GetoptLong.pdf)
2. [Simple variable interpolation in R](https://cran.r-project.org/web/packages/GetoptLong/vignettes/variable_interpolation.pdf)

## Control command line options

This package wraps the powerful Perl module [`Getopt::Long`](http://perldoc.perl.org/Getopt/Long.html) and keeps almost all
features of it. The syntax of option specification is as same as `Getopt::Long`.
So if you are coming from Perl and you know `Getopt::Long`, there would be no
difficulty with using it. 

Also, this package supports default values, imports option
names into working environment, and automatically generates help messages.
The usage is very simple:

```r
library(GetoptLong)
cutoff = 0.05  # cutoff has default value and not necessary to specify in command line
GetoptLong(
    "cutoff=f", "cutoff of something (default is 0.05)",
    "input=s%", "input file",
    "verbose!", "print messages"
)
```

Then you can run this script by:

```
Rscript foo.R --cutoff 0.01 --input file=foo.txt --verbose
Rscript foo.R -i file=foo.txt -v
Rscript foo.R -i file=foo.txt --no-verbose
```

Help message can be automatically generated:

```
> Rscript test_list.R --help
Usage: Rscript foo.R [options]
    
  --cutoff numeric
    cutoff of something (default is 0.05)

  --input { name=character, ... }
    input file

  --verbose
    print messages

  --help
    Print help message and exit

  --version
    Print version information and exit
```

Also, arguments can be set when calling `GetoptLong:::source()`, so it would be convinient to control
variables even you are in an interactive R session:

```r
GetoptLong:::source("foo.R", argv = "--cutoff 0.01 --input file=foo.txt --verbose")
```

## Variable interpolation

This package also supports simple variable interpolation in R, which means you
can embed variables into texts directly, just like in Perl.

```r
r = c(1, 2)
value = 4
name = "name"
qq("region = (@{r[1]}, @{r[2]}), value = @{value}, name = '@{name}'")

## [1] "region = (1, 2), value = 4, name = 'name'"
```

So it would be much easier for you to construct complicated texts instead of
using `paste`.


## License

GPL (>= 2)

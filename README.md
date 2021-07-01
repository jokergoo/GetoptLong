# GetoptLong

[![R-CMD-check](https://github.com/jokergoo/GetoptLong/workflows/R-CMD-check/badge.svg)](https://github.com/jokergoo/GetoptLong/actions)
[![CRAN](http://www.r-pkg.org/badges/version/GetoptLong)](https://cran.r-project.org/web/packages/GetoptLong/index.html) 
[![codecov](https://img.shields.io/codecov/c/github/jokergoo/GetoptLong.svg)](https://codecov.io/github/jokergoo/GetoptLong) 

This is a command-line argument parser which wraps the powerful Perl module
[`Getopt::Long`](http://perldoc.perl.org/Getopt/Long.html) and with some
adaptations for easier use in R. It also provides a simple way for variable
interpolation in R.

There are two vignettes in the package which explain in more detail:

1. [Parsing command-line arguments by Getopt::Long](http://jokergoo.github.io/GetoptLong/articles/GetoptLong.html)
2. [Simple variable interpolation](http://jokergoo.github.io/GetoptLong/articles/variable_interpolation.html)

## Install

The package can be installed from CRAN:

```r
install.packages("GetoptLong")
```

or directly from GitHub:

```r
devtools::install_github("jokergoo/GetoptLong")
```

## Usage

### Control command line options

This package wraps the powerful Perl module
[`Getopt::Long`](https://metacpan.org/pod/Getopt::Long) and keeps almost all
features of it. The syntax of option specification is the same as
`Getopt::Long`. So if you are from Perl and you know `Getopt::Long`,
there would be no difficulty with using it.

The usage is very simple:

```r
library(GetoptLong)

cutoff = 0.05
GetoptLong(
    "number=i", "Number of items.",
    "cutoff=f", "Cutoff for filtering results.",
    "verbose!", "Print message."
)
```

Then you can run this script by:

```
~\> Rscript foo.R --number 4 --cutoff 0.01 --verbose
~\> Rscript foo.R --number=4 --cutoff=0.01 --no-verbose
~\> Rscript foo.R -n 4 -c 0.01 -v
~\> Rscript foo.R -n 4 --verbose
```

Help message is automatically generated:

```
Usage: Rscript foo.R [options]

Options:
  --number, -n integer
    Number of items.
 
  --cutoff, -c numeric
    Cutoff for filtering results.
    [default: 0.05]
 
  --verbose
    Print message.
 
  --help, -h
    Print help message and exit.
 
  --version
    Print version information and exit.

```


### Variable interpolation

This package also supports simple variable interpolation, which means you
can embed variables into texts directly, just like in Perl.

```r
r = c(1, 2)
value = 4
name = "name"
qq("region = (@{r[1]}, @{r[2]}), value = @{value}, name = '@{name}'")

## [1] "region = (1, 2), value = 4, name = 'name'"
```

So it would be much easier for you to construct complicated texts instead of
using `paste()`.


## License

MIT @ Zuguang Gu

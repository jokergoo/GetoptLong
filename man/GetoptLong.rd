\name{GetoptLong}
\alias{GetoptLong}
\title{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\description{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\usage{
GetoptLong(..., help = TRUE, version = TRUE, envir = parent.frame(), argv_str = NULL,
    head = NULL, foot = NULL)
}
\arguments{

  \item{...}{specification of options. The value should be a vector having even number of elements.}
  \item{help}{whether to add help option}
  \item{version}{whether to add version option}
  \item{envir}{user's enrivonment where \code{\link{GetoptLong}} will look for default values and export variables}
  \item{argv_str}{command-line arguments, only for testing purpose}

}
\details{
Following shows a simple example. Put following code at the beginning of your script (e.g. \code{foo.R}):

  \preformatted{
    library(GetoptLong)
    cutoff = 0.05
    GetoptLong(
        "number=i", "Number of items, integer, mandatory option",
        "cutoff=f", "cutoff to filter results, optional, default (0.05)",
        "verbose",  "print messages"
    )  }

Then you can call the script from command line either by:

  \preformatted{
    ~\> Rscript foo.R --number 4 --cutoff 0.01 --verbose
    ~\> Rscript foo.R -n 4 -c 0.01 -v
    ~\> Rscript foo.R -n 4 --verbose  }

In above example, \code{number} is a mandatory option and should only be integer mode. \code{cutoff}
is optional and already has a default value. \code{verbose} is a logical option. If parsing is
successful, two variables with name \code{number} and \code{verbose} will be imported into the working
environment with specified values, and value for \code{cutoff} will be updated if it is specified in
command-line argument.

For advanced use of this function, please go to the vignette.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
# There is no example
NULL

}

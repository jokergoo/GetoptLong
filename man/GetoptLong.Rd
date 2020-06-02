\name{GetoptLong}
\alias{GetoptLong}
\title{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\description{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\usage{
GetoptLong(..., help_head = NULL, help_foot = NULL, envir = parent.frame(),
    argv_str = NULL, template_control = list())
}
\arguments{

  \item{...}{Specification of options. The value can be a two-column matrix, a vector with even number of elements  or a text template. See the vignette for detailed explanation.}
  \item{help_head}{Head of the help message when invoking \code{Rscript foo.R --help}.}
  \item{help_foot}{Foot of the help message when invoking \code{Rscript foo.R --help}.}
  \item{envir}{User's enrivonment where \code{\link{GetoptLong}} looks for default values and exports variables.}
  \item{argv_str}{A string that contains command-line arguments. It is only for testing purpose.}
  \item{template_control}{A list of parameters for controlling when the specification is a template.}

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

In above example, \code{number} is a mandatory option and it should only be in integer mode. \code{cutoff}
is optional and it already has a default value. \code{verbose} is a logical option. If parsing is
successful, two variables with name \code{number} and \code{verbose} will be automatically imported into the working
environment with specified values, and value for \code{cutoff} will be updated if it is specified from the
command-line

For advanced use of this function, please go to the vignette.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
# There is no example
NULL

}

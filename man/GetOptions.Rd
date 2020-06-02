\name{GetOptions}
\alias{GetOptions}
\title{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\description{
Wrapper of the Perl module \code{Getopt::Long} in R
}
\usage{
GetOptions(..., envir = parent.frame())
}
\arguments{

  \item{...}{Pass to \code{\link{GetoptLong}}.}
  \item{envir}{User's enrivonment where \code{\link{GetoptLong}} looks for default values and exports variables.}

}
\details{
This function is the same as \code{\link{GetoptLong}}. It is just to make it consistent as the \code{GetOptions()} 
subroutine in \code{Getopt::Long} module in Perl.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
# There is no example
NULL

}

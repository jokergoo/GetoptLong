\name{source}
\alias{source}
\title{
read R source code
}
\description{
read R source code
}
\usage{
source(..., argv = NULL)
}
\arguments{

  \item{...}{pass to \code{\link[base]{source}}}
  \item{argv}{a string which contains command line arguments}

}
\details{
This function insert an \code{argv} argument into the base \code{\link[base]{source}},
so that when sourcing an R script, command line options can also be specfied
}
\examples{
\dontrun{
# assume you have GetoptLong() in foo.R
source("test.R", argv = "--number 4 --cutoff 0.01 --verbose")
}

}

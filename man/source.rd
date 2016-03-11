\name{source}
\alias{source}
\title{
Read R source code with arguments
}
\description{
Read R source code with arguments
}
\usage{
source(..., argv = NULL)
}
\arguments{

  \item{...}{pass to \code{\link[base]{source}}}
  \item{argv}{a string which contains command line arguments}

}
\details{
This function overwrites the default base::\code{\link[base]{source}}.

Command-line arguments can be used when sourcing an R file, just like running R script in the command-line.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
\dontrun{
# assume you have GetoptLong() in foo.R
source("test.R", argv = "--number 4 --cutoff 0.01 --verbose")
}

}

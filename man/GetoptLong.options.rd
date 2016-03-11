\name{GetoptLong.options}
\alias{GetoptLong.options}
\title{
Global options for GetoptLong()
}
\description{
Global options for GetoptLong()
}
\usage{
GetoptLong.options(..., RESET = FALSE, READ.ONLY = NULL, LOCAL = FALSE)
}
\arguments{

  \item{...}{options, see 'details' section}
  \item{RESET}{Whether to reset options to their default values}
  \item{READ.ONLY}{only return read-only options?}
  \item{LOCAL}{switch local mode}

}
\details{
Supported options are following:

\describe{
  \item{startingMsg}{message that will be printed before the helping message when running \code{Rscript foo.R --help}}
  \item{endingMsg}{message that will be printed after the helping message when running \code{Rscript foo.R --help}}
  \item{config}{configuration of \code{Getopt::Long}, check \url{http://perldoc.perl.org/Getopt/Long.html#Configuring-Getopt\%3a\%3aLong}}
}

\code{GetoptLong.options(...)} should be put before calling \code{\link{GetoptLong}} function.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
# There is no example
NULL

}

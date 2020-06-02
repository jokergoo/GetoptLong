\name{GetoptLong.options}
\alias{GetoptLong.options}
\title{
Global options for GetoptLong()
}
\description{
Global options for GetoptLong()
}
\usage{
GetoptLong.options(..., RESET = FALSE, READ.ONLY = NULL, LOCAL = FALSE, ADD = FALSE)
}
\arguments{

  \item{...}{Options, see 'Details' section.}
  \item{RESET}{Whether to reset options to their default values.}
  \item{READ.ONLY}{Whether to only return read-only options.}
  \item{LOCAL}{Whether to switch local mode.}
  \item{ADD}{Whether to add new options.}

}
\details{
Supported global options are following:

\describe{
  \item{\code{config}}{Configuration of \code{Getopt::Long}, check \url{http://perldoc.perl.org/Getopt/Long.html#Configuring-Getopt\%3a\%3aLong} .}
  \item{\code{template_tag}}{The tag for identifying specifications in the template. The format should be in \code{left_tag CODE right_tag}.}
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

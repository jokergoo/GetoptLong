\name{GetoptLong.options}
\alias{GetoptLong.options}
\title{
global options for \code{GetoptLong}

}
\description{
global options for \code{GetoptLong}

}
\usage{
GetoptLong.options(..., RESET = FALSE, READ.ONLY = NULL)}
\arguments{

  \item{...}{options, see 'details' section}
  \item{RESET}{Whether to reset options to their default values}
  \item{READ.ONLY}{only return read-only options?}
}
\details{
Supported options are following:

\describe{
  \item{startingMsg}{message that will be printed before the helping message when running \code{Rscript foo.R --help}}
  \item{endingMsg}{message that will be printed after the helping message when running \code{Rscript foo.R --help}}
  \item{config}{configuration of \code{Getopt::Long}}
}

}

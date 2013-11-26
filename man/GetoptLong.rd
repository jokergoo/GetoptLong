\name{GetoptLong}
\alias{GetoptLong}
\title{
  Wrapper of the Perl module \code{Getopt::Long} in R  


}
\description{
  Wrapper of the Perl module \code{Getopt::Long} in R  


}
\usage{
GetoptLong(spec, help = TRUE, version = TRUE, envir = parent.frame(),
    argv_str = NULL)
}
\arguments{
  \item{spec}{specification of options. A two-column matrix in which the first column is the setting for option names and the second column is the description of options. It is can also be a vector having even number of elements and it will be converted to the two-column matrix}
  \item{help}{whether to add help option}
  \item{version}{whether to add version option}
  \item{envir}{user's enrivonment where \code{\link{GetoptLong}} will look for default values and export variables}
  \item{argv_str}{command-line arguments, only for testing purpose}

}
\details{
  please see vignette. 


}

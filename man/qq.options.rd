\name{qq.options}
\alias{qq.options}
\title{
Global options for \code{qq} related functions  


}
\description{
Global options for \code{qq} related functions  


}
\usage{
qq.options(..., RESET = FALSE, READ.ONLY = NULL)
}
\arguments{

  \item{...}{options, see 'details' section}
  \item{RESET}{Whether to reset options to their default values}
  \item{READ.ONLY}{only return read-only options?}

}
\details{
Supported options are following:  

\describe{
  \item{cat_prefix}{prefix of the string which is printed by \code{\link{qqcat}}}
  \item{cat_verbose}{whether to print text by \code{\link{qqcat}}}
  \item{code.pattern}{code pattern for variable interpolation}
}


}

\name{qq.options}
\alias{qq.options}
\title{
Global options for qq() related functions
}
\description{
Global options for qq() related functions
}
\usage{
qq.options(..., RESET = FALSE, READ.ONLY = NULL, LOCAL = FALSE, ADD = FALSE)
}
\arguments{

  \item{...}{options, see 'details' section}
  \item{RESET}{Whether to reset options to their default values}
  \item{READ.ONLY}{only return read-only options?}
  \item{LOCAL}{switch local mode}
  \item{ADD}{add new options}
}
\details{
Supported options are following:

\describe{
  \item{\code{cat_prefix}}{prefix of the string which is printed by \code{\link{qqcat}}}
  \item{\code{cat_verbose}}{whether to print text by \code{\link{qqcat}}}
  \item{\code{cat_strwrap}}{whether call \code{\link[base]{strwrap}} to wrap the string}
  \item{\code{code.pattern}}{code pattern for variable interpolation}
}
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
a = 1
qq.options(cat_prefix = "[INFO] ")
qqcat("a = @{a}\n")
qq.options(cat_verbose = FALSE)
qqcat("a = @{a}\n")
qq.options(RESET = TRUE)
qq.options(code.pattern = "`CODE`")
qqcat("a = `a`\n")
qq.options(RESET = TRUE)
}

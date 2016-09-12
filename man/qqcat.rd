\name{qqcat}
\alias{qqcat}
\title{
Print a string which has been intepolated with variables
}
\description{
Print a string which has been intepolated with variables
}
\usage{
qqcat(text, envir = parent.frame(), code.pattern = NULL, file = "",
    sep = " ", fill = FALSE, labels = NULL, append = FALSE, cat_prefix = NULL,
    strwrap = TRUE, strwrap_param = list())
}
\arguments{

  \item{text}{text string in which variables are marked with certain rules}
  \item{envir}{environment where to look for those variables}
  \item{code.pattern}{pattern of marks for the variables}
  \item{file}{pass to \code{\link[base]{cat}}}
  \item{sep}{pass to \code{\link[base]{cat}}}
  \item{fill}{pass to \code{\link[base]{cat}}}
  \item{labels}{pass to \code{\link[base]{cat}}}
  \item{append}{pass to \code{\link[base]{cat}}}
  \item{cat_prefix}{prefix string. It is prior than \code{qq.options(cat_prefix)}.}
  \item{strwrap}{whether call \code{\link[base]{strwrap}} to wrap the string}
  \item{strwrap_param}{parameters sent to \code{\link[base]{strwrap}}, must be a list}

}
\details{
This function is a shortcut of

  \preformatted{
    cat(qq(text, envir, code.pattern), ...)  }

Additionally, you can add global prefix:

  \preformatted{
    qq.options("cat_prefix" = "[INFO] ")
    qq.options("cat_prefix" = function(x) format(Sys.time(), "[\%Y-\%m-\%d \%H:\%M:\%S] "))
    qq.options("cat_prefix" = NULL)  }

You can also add local prefix by specifying \code{cat_prefix} in \code{\link{qqcat}}.

  \preformatted{
    qqcat(text, cat_prefix = "[INFO] ")  }

Please refer to \code{\link{qq}} to find more details.
}
\author{
Zuguang Gu <z.gu@dkfz.de>
}
\examples{
a = 1
b = "text"
qqcat("a = @{a}, b = '@{b}'\n")
qqcat("a = `a`, b = '`b`'\n", code.pattern = "`CODE`")

qq.options("cat_prefix" = function(x) format(Sys.time(), "[\%Y-\%m-\%d \%H:\%M:\%S] "))
qqcat("a = @{a}, b = '@{b}'\n")
Sys.sleep(2)
qqcat("a = @{a}, b = '@{b}'\n")
qq.options(RESET = TRUE)
}

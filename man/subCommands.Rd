\name{subCommands}
\alias{subCommands}
\title{
Setting sub commands
}
\description{
Setting sub commands
}
\usage{
subCommands(..., help_head = NULL, help_foot = NULL, argv_str = NULL)
}
\arguments{

  \item{...}{Specification of commands. See section Details.}
  \item{help_head}{Head of the help message when invoking \code{Rscript foo.R}.}
  \item{help_foot}{Foot of the help message when invoking \code{Rscript foo.R}.}
  \item{argv_str}{A string that contains command-line arguments. It is only for testing purpose.}

}
\details{
The format of input can be one of the following:

1. A matrix with two columns. Then the first column contains paths of the scripts and the second column contains the description of the subcommand. The basenames of path in the first column
   by removing the suffix are taken as the sub commands.
2. A matrix with three columns. The the first column contains the sub commands, the second column contains corresponding script paths and the third column contains descriptions of the sub commands.
3. A vector with length as multiples of 2. In this case, every two elements are grouped and concatenated into a matrix by rows. Then it follows the rule 1.
4. A vector with length as multiples of 3. In this case, every three elements are grouped and concatenated into a matrix by rows. Then it follows the rule 2.
}
\examples{
# There is no example
NULL

}

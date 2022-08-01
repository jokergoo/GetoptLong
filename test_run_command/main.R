#!/usr/local/bin/Rscript

library(GetoptLong)

# subCommands(
#   "----", "----", "This is section1",
#   "sub1", "sub1.R", 
#           "This is the description of sub command 1, which will be a long long long text.",
#   "----", "----", "This is section2",
#   "sub2", "sub2.R",
#           "This is the description of sub command 2, which will be a long long long text."
# )



subCommands("
This is the head of the help message.

Usage: Rscript main.R [command] [options]

Commands:
  <sub1=sub1.R> This is the description of sub command 1, which will be a long long
          long text.
  <longlonglong=sub2.R> This is the description of sub command 2, which will be a long long
          long text.

This is the foot of the help message.
")
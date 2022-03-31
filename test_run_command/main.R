#!/usr/local/bin/Rscript

library(GetoptLong)

subCommands(
  "sub1", "sub1.R", 
          "This is the description of sub command 1, which will be a long long long text.",
  "sub2", "sub2.R",
          "This is the description of sub command 2, which will be a long long long text."
)

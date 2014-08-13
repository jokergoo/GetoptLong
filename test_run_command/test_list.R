library(GetoptLong)
cutoff = 0.05
GetoptLong(c(
    "cutoff=f",  "cutoff of something (default is 0.05)",
    "input=s%",   "input file",
    "verbose!", "print messages"
))
library(GetoptLong)

tag = list(1)
GetoptLong(c("tag=s%", "tag"))


print(tag)

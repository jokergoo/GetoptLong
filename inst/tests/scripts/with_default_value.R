library(GetoptLong)

tag = 4
GetoptLong(c(
	"tag=i", "integer"
))

qqcat("tag=@{tag}")
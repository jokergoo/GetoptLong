library(GetoptLong)

GetoptLong(c(
	"tag=i", "integer"
))

qqcat("tag=@{tag}")
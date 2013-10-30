source("../../../R/GetoptLong.R")
source("../../../R/qq.R")
library(rjson)

GetoptLong(c(
	"tag=i", "integer"
))

qqcat("tag=@{tag}")
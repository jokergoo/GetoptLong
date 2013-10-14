library(GetoptLong)

cutoff = 0.2

GetoptLong(spec = c(
	"tag=i", "xxx",
	"cutoff=f", "fff"
))

for(obj in ls()) {
	qqcat("@{obj}: @{get(obj, envir = .GlobalEnv)}\n")
}


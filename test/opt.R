source("../R/qq.R")
source("../R/script.R")


spec = matrix(c(
	"fla--g!", "desc",
	"file|f=s", "desc"
), ncol = 2, byrow = TRUE)

x = GetoptLong(spec, argv_str = "--file s1")
print_help_msg(spec)

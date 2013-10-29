library(testthat)
library(GetoptLong)

OS = Sys.info()["sysname"]

command = "perl -v"

# supress warnings
ow = options("warn")[[1]]
options(warn = -1)
if(OS == "Windows") {
	res = try(system("command", show.output.on.console = FALSE, intern = TRUE), silent = TRUE)
} else {
	res = try(system(command, intern = TRUE), silent = TRUE)
}
options(warn = ow)
	

if(is.null(attributes(res))) {
	test_package("GetoptLong")
} else {
	test_package("GetoptLong", filter = "qq")
}

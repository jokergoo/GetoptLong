library(testthat)
library(GetoptLong)

OS = Sys.info()["sysname"]

cmd = "perl -v"

if(OS == "Windows") {
	res = system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE, show.output.on.console = FALSE)
} else {
	res = system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
}


if(res == 0 && OS != "Windows") {
	test_package("GetoptLong", filter = "qq|GetoptLong")
} else {
	test_package("GetoptLong", filter = "qq")
}

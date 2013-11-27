library(testthat)
library(GetoptLong)

if(Sys.which("perl") != "") {
	test_package("GetoptLong", filter = "qq|GetoptLong")
} else {
	test_package("GetoptLong", filter = "qq")
}

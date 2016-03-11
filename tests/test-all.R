library(testthat)
library(GetoptLong)

is.solaris = function()
	grepl('SunOS',Sys.info()['sysname'])


if(!is.solaris()) {
	if(Sys.which("perl") != "") {
		test_package("GetoptLong", filter = "qq|GetoptLong")
	} else {
		test_package("GetoptLong", filter = "qq")
	}
}

.onLoad = function(libname, pkgname) {
	
	if(!check_perl()) {
		stop("Cannot find Perl in your PATH.\n")
	}
	
	if(!check_perl("Getopt::Long")) {
		stop("Cannot find Getopt::Long module in your Perl library.\n")
	}
	
	if(!check_perl("JSON", qq("@{system.file('extdata', 'GetoptLong')}/perl_lib"))) {
		stop("Cannot find JSON module in your Perl library.\n")
	}
}

check_perl = function(module = NULL, inc = NULL) {
	if(is.null(module)) {
		cmd = "perl -v"
	} else if(!is.null(module) && is.null(inc)) {
		cmd = qq("perl -M@{module} -e 'use @{module}'")
	} else if(!is.null(module) && !is.null(inc)) {
		cmd = qq("perl '-I@{inc}' -M@{module} -e 'use @{module}'")
	}
	
	exit_code = system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
	return(ifelse(exit_code, FALSE, TRUE))
}

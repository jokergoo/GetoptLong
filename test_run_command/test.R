
run_command = function(command) {
	OS = Sys.info()["sysname"]
	
	if(OS != "Windows") {
		command = qq("@{command} 2>&1")
	}
	print(command)
	# supress warnings
	ow = options("warn")[[1]]
	options(warn = -1)
	if(OS == "Windows") {
		# how to capture STDERR in Windows? envoke a perl script
		res = try(system(command, show.output.on.console = FALSE, intern = TRUE), silent = TRUE)
	} else {
		res = try(system(command, intern = TRUE), silent = TRUE)
	}
	options(warn = ow)
	
	if(is.null(attributes(res))) {
		return(list(status = 0, message = res))
	} else {
		return(list(status = ifelse(is.null(attributes(res)$status), 127, attributes(res)$status), message = as.vector(res)))
	}
}

run_command("perl stderr-fail.pl")
run_command("perl stderr-succeed.pl")
run_command("perl stdout-fail.pl")
run_command("perl stdout-succeed.pl")



context("test command-line")

setwd(qq("@{system.file('tests', package = 'GetoptLong')}/scripts"))

run_command = function(command) {
	OS = Sys.info()["sysname"]

	if(OS != "Windows") {
		command = qq("@{command} 2>&1")
	}

	# supress warnings
	ow = options("warn")[[1]]
	options(warn = -1)
	if(OS == "Windows") {
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

res = run_command("Rscript --version")
if(!res$status) {

	test_that("test command-line", {
		res = run_command("Rscript general.R --tag 1")
		expect_that(res$status, equals(0))
		expect_that(res$message, equals("tag=1"))

		res = run_command("Rscript general.R")
		expect_that(res$status, equals(127))
		expect_that(res$message, prints_text("error"))

		res = run_command("Rscript with_default_value.R --tag 1")
		expect_that(res$status, equals(0))
		expect_that(res$message, equals("tag=1"))

		res = run_command("Rscript with_default_value.R")
		expect_that(res$status, equals(0))
		expect_that(res$message, equals("tag=4"))
	})

}


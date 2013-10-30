
context("test command-line")

setwd(qq("@{system.file('tests', package = 'GetoptLong')}/scripts"))


OS = Sys.info()["sysname"]

command = "Rscript --version"

# supress warnings
ow = options("warn")[[1]]
options(warn = -1)
if(OS == "Windows") {
	res = try(system(command, show.output.on.console = FALSE, ignore.stderr = TRUE, intern = TRUE), silent = TRUE)
} else {
	res = try(system(command, intern = TRUE), silent = TRUE)
}
options(warn = ow)

if(is.null(attributes(res))) {

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


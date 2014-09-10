
# == title
# global options for ``GetoptLong``
#
# == param
# -... options, see 'details' section
# -RESET Whether to reset options to their default values
# -READ.ONLY only return read-only options?
#
# == detail
# Supported options are following:
#
# -startingMsg message that will be printed before the helping message when running ``Rscript foo.R --help``
# -endingMsg message that will be printed after the helping message when running ``Rscript foo.R --help``
# -config configuration of ``Getopt::Long``
#
GetoptLong.options = function(..., RESET = FALSE, READ.ONLY = NULL) {}
GetoptLong.options = setGlobalOptions(
	startingMsg = list(.value = NULL,
	                   .length = 1),
	endingMsg = list(.value = NULL,
	                 .length = 1),
	config = NULL
)

# == title
# Global options for ``qq`` related functions
#
# == param
# -... options, see 'details' section
# -RESET Whether to reset options to their default values
# -READ.ONLY only return read-only options?
#
# == detail
# Supported options are following:
#
# -cat_prefix prefix of the string which is printed by `qqcat`
# -cat_verbose whether to print text by `qqcat`
# -code.pattern code pattern for variable interpolation
#
qq.options = function(..., RESET = FALSE, READ.ONLY = NULL) {}
qq.options = setGlobalOptions(
	cat_prefix = list(.value = "",
		              .length = c(0, 1),
					  .class = c("character", "function", "numeric", "NULL"),
		              .filter = function(x) {
		              	if(is.null(x)) {
		              		return('')
		              	} else {
		              		return(x)
		              	}
		              }),
	cat_verbose = list(.value = TRUE,
	                   .class = "logical"),
	code.pattern = list(.value = "@\\{CODE\\}",
	                    .length = 1,
						.class = "character"),
	test = list(.value = 1)
)


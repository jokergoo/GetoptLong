
# == title
# Global options for GetoptLong() 
#
# == param
# -... Options, see 'Details' section.
# -RESET Whether to reset options to their default values.
# -READ.ONLY Whether to only return read-only options.
# -LOCAL Whether to switch local mode.
# -ADD Whether to add new options.
#
# == detail
# Supported global options are following:
#
# -``config`` Configuration of ``Getopt::Long``, check https://perldoc.pl/Getopt::Long#Configuring-Getopt::Long .
# -``template_tag`` The tag for identifying specifications in the template. The format should be in ``left_tag CODE right_tag``.
# -``help_style`` The style of the help message. 
#
# ``GetoptLong.options(...)`` should be put before calling `GetoptLong` function.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
GetoptLong.options = function(..., RESET = FALSE, READ.ONLY = NULL, LOCAL = FALSE, ADD = FALSE) {}
GetoptLong.options = setGlobalOptions(
	config = list(.value = NULL,
		          .class = "character"),
	template_tag = list(.value = "<CODE>",
						.length = 1,
						.validate = function(x) grepl("CODE", x)
					),
	help_style = list(.value = "one-column",
					 .length = 1,
					 .filter = function(x) {
					 	if(x == "one column") {
					 		x = "one-column"
					 	} else if(x == "one_column") {
					 		x = "one-column"
					 	} else if(x == "two column") {
					 		x = "two-column"
					 	} else if(x == "two_column") {
					 		x = "two-column"
					 	} else if(x == "two columns") {
					 		x = "two-column"
					 	} else if(x == "two_columns") {
					 		x = "two-column"
					 	}
					 	x
					 },
					 .validate = function(x) x %in% c("one-column", "two-column"),
					 .failed_msg = "help_style should be one of 'one-column' and 'two-column'"
					),
	"help_width" = 90,
	"__argv_str__" = list(.value = NULL,
						.length = c(0, 1),
						.visible = FALSE),
	"__script_name__" = list(.value = NULL,
		                    .private = TRUE,
		                    .visible = FALSE)
)

# == title
# Global options for qq() related functions
#
# == param
# -... Options, see 'Details' section.
# -RESET Whether to reset options to their default values.
# -READ.ONLY Whether to only return read-only options.
# -LOCAL Whether to switch local mode.
# -ADD Whether to add new options.
#
# == detail
# Supported options are following:
#
# -``cat_prefix`` prefix of the string which is printed by `qqcat`
# -``cat_verbose`` whether to print text by `qqcat`
# -``cat_strwrap`` whether call `base::strwrap` to wrap the string
# -``code.pattern`` code pattern for variable interpolation
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
# == example
# a = 1
# qq.options(cat_prefix = "[INFO] ")
# qqcat("a = @{a}\n")
# qq.options(cat_verbose = FALSE)
# qqcat("a = @{a}\n")
# qq.options(RESET = TRUE)
# qq.options(code.pattern = "`CODE`")
# qqcat("a = `a`\n")
# qq.options(RESET = TRUE)
qq.options = function(..., RESET = FALSE, READ.ONLY = NULL, LOCAL = FALSE, ADD = FALSE) {}
qq.options = setGlobalOptions(
	cat_prefix = list(.value = "",
					  .length = c(0, 1),
					  .class = c("character", "numeric", "NULL"),
					  .filter = function(x) {
						if(is.null(x)) {
							return('')
						} else {
							return(x)
						}
					  }),
	cat_verbose = list(.value = TRUE,
					   .class = "logical"),
	cat_strwrap = list(.value = FALSE,
					   .class = "logical"),
	code.pattern = list(.value = "@\\{CODE\\}",
						.length = 1,
						.class = "character")
)

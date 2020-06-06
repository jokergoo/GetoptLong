text = "
Usage: Rscript foo.R [options]

Options:
  <verbose!> print messages
  <foo=i> foo
  <bar=s@> bar
"

template_control = list(
	data_type = c("verbose" = TRUE, "bar" = FALSE),
	max_width = c("foo" = 30, "bar" = 40)
)
GetoptLong(text, argv_str = "--help", template_control = template_control)

GetoptLong(
	"tag=s", paste0("lsjflslljsfljslflsflsfjlslj",
	         "sfljlsjflsjflsjfljslfjsljsljslfls")


GetoptLong(
	"foo=i%", "This is foo. This is foo. This is foo. This is foo.",
	"foo$name1", "name1 in foo. name1 in foo. name1 in foo. name1 in foo.",
	"foo$name2", "name2 in foo. name2 in foo. name2 in foo. name2 in foo.",
	"bar=s%", "This is bar. This is bar. This is bar. This is bar.",
	"bar$name3", "name3 in bar. name3 in bar. name3 in bar. name3 in bar.",
	"bar$name4", "name4 in bar. name4 in bar. name4 in bar. name4 in bar.",

	argv_str = "--help"
)

GetoptLong(
	"foo|bar=i", "",
	 argv_str = "--help"
)

foo = NA

count = 1
number = 0.1
array = c(1, 2)
hash = list("foo" = "a", "bar" = "b")
verbose = TRUE
GetoptLong(
    "count=i", "This is a count. This is a count. This is a count. This is a count. This is a count.",
    "number=f", "This is a number. This is a number. This is a number. This is a number. This is a number.",
    "array=f@", "This is an array. This is an array. This is an array. This is an array. This is an array.",
    "hash=s%", "This is a hash. This is a hash.This is a hash.This is a hash.This is a hash.This is a hash.",
    "verbose!", "Whether show messages",
    "flag", "a non-sense option",

	argv_str = "--help"
)


GetoptLong("
This is a demonstration of using template as the option specification.

Usage: Rscript foo.R [options]

Binary options:
  <verbose!> Whether show messages
  <flag> a non-sense option

Single-value options:
  <count=i> This is a count. This is a count.
  <#count> This is a count
  <number=f> This is a number. This is a number. 

Multiple-vlaue options:
  <array=f@> This is an array. This is an array. 
  <hash=s%> This is a hash. This is a hash.

Questions, please contact your.name@email
", argv_str = "--help",
	template_control = list(
		opt_width = c(verbose = 23, flag = 23,
			          count = 22, number = 22,
			          array = 30, hash = 30)
))

cutoff = 0.05
GetoptLong(
    "number=i", "Number of items, integer, mandatory option",
    "cutoff=f", "cutoff to filter results, optional, default (0.05)",
    "verbose",  "print messages",
    argv_str = "--help"
)

cutoff = 0.05
spec = "
This is an example of using template to specify options.

Usage: Rscript foo.R [options]

Options:
  <number=i> Number of items.
  <cutoff=f> Cutoff for filtering results.               
  <verbose> Print messages 
"

GetoptLong(spec, template_control = list(opt_width = 25), argv_str = "--help")


library(GetoptLong)

cutoff = 0.05
GetoptLong(
    "number=i{1,}", "Number of items.",
    "cutoff=f", "Cutoff for filtering results.",
    "param=s%", "Parameters specified by name=value pairs.",
    "verbose",  "Print message.",

    argv_str = "--number 1 2 --param var1=a --param var2=b --verbose"
)


opt = new.env()

opt$cutoff = 0.05
GetoptLong(
    "number=i{1,}", "Number of items.",
    "cutoff=f", "Cutoff for filtering results.",
    "param=s%", "Parameters specified by name=value pairs.",
    "verbose",  "Print message.",

    envir = opt,
    argv_str = "--number 1 2 --param var1=a --param var2=b --verbose"
)
print(as.list(opt))

GetoptLong(
    help_head = "This is a demonstration of adding usage head and foot.",
    "number=i", "Number of items.",
    "cutoff=f", "Cutoff for filtering results.",
    "verbose",  "Print message.",
    help_foot = "Please contact name@address.",
    argv_str = "--help"
)


verbose = TRUE
GetoptLong(
    "help",  "Print message.",

	argv_str = "--help"
)


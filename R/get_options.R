# == title
# Wrapper of the Perl module ``Getopt::Long`` in R
#
# == param
# -...     Specification of options. The value can be a two-column matrix, a vector with even number of elements 
#          or a text template. See the vignette for detailed explanation.
# -help_head Head of the help message when invoking ``Rscript foo.R --help``.
# -help_foot Foot of the help message when invoking ``Rscript foo.R --help``.
# -envir    User's enrivonment where `GetoptLong` looks for default values and exports variables.
# -argv_str A string that contains command-line arguments. It is only for testing purpose.
# -template_control A list of parameters for controlling when the specification is a template.
# -help_style The style of the help messages. Value should be either "one-column" or "two-column".
#
# == details
# Following shows a simple example. Put following code at the beginning of your script (e.g. ``foo.R``):
#
#     library(GetoptLong)
#     
#     cutoff = 0.05
#     GetoptLong(
#         "number=i", "Number of items.",
#         "cutoff=f", "Cutoff for filtering results.",
#         "verbose",  "Print message."
#     )
#
# Then you can call the script from command line either by:
#
#     Rscript foo.R --number 4 --cutoff 0.01 --verbose
#     Rscript foo.R --number 4 --cutoff=0.01 --verbose
#     Rscript foo.R -n 4 -c 0.01 -v
#     Rscript foo.R -n 4 --verbose
#
# In this example, ``number`` is a mandatory option and it should only be in
# integer mode. ``cutoff`` is optional and it already has a default value 0.05.
# ``verbose`` is a logical option. If parsing is successful, two variables ``number``
# and ``verbose`` will be imported into the working environment with the specified
# values. Value for ``cutoff`` will be updated if it is specified in command-line.
#
# For advanced use of this function, please go to the vignette.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
GetoptLong = function(..., help_head = NULL, help_foot = NULL, envir = parent.frame(), 
	argv_str = NULL, template_control = list(), 
	help_style = GetoptLong.options$help_style) {

	if(is.null(get_scriptname())) {
		IS_UNDER_COMMAND_LINE = FALSE
	} else {
		IS_UNDER_COMMAND_LINE = TRUE
	}

	if(is.null(argv_str)) {
		argv_str = GetoptLong.options("__argv_str__")
	}
	on.exit(GetoptLong.options("__argv_str__" = NULL))

	# to test whether the script is run under command-line or in R interactive environment
	if(IS_UNDER_COMMAND_LINE || is.null(argv_str)) {
		OUT = stderr()
	} else {
		OUT = stdout()  # message from STDOUT is important under testing mode
	}

	############### parse specification ##################

	spec = list(...)

	# a vector or a two-column matrix
	if(length(spec) == 1) {
		spec = spec[[1]]
	} else {
		spec = unlist(spec)
	}

	# check first argument
	# it should be a matrix with two columns or a vector with even number of elements
	template = NULL
	if(is.matrix(spec)) {
		if(ncol(spec) != 2) {
			stop_wrap("If your specification is a matrix, it should be a two-column matrix.")
		}
	} else {
		if(is.vector(spec)) {
			if(length(spec) == 1) {
				template = spec
				template = gsub("^\\n", "", template)
				spec = parse_spec_template(spec)
				if(nrow(spec) == 0) {
					stop_wrap("Cannot detect option specification in the template.")
				}
			} else if(length(spec) %% 2) {
				stop_wrap("Since your specification is a vector, it should have even number of elements.")
			} else {
				spec = matrix(spec, ncol = 2, byrow = TRUE)
			}
		} else {
			stop_wrap("Wrong specification.")
		}
	}
	
	##### extract specification for hash
	l_sub_opt = grepl("\\w+\\$\\S+$", spec[, 1])
	hash_sub_opt = spec[l_sub_opt, , drop = FALSE]
	spec = spec[!l_sub_opt, , drop = FALSE]
	spec[, 1] = gsub("\\s*", "", spec[, 1])

	#### convert hash_sub_opt into a list
	sub_opt = NULL
	if(sum(l_sub_opt)) {
		sub_opt = lapply(split(seq_len(nrow(hash_sub_opt)), gsub("\\$.*$", "", hash_sub_opt[, 1])), function(ind) {
			nm = apply(hash_sub_opt[ind, , drop = FALSE], 1, function(x) {
				gsub("^.*?\\$", "", x[1])
			})
			structure(hash_sub_opt[ind, 2], names = nm)
		})
	}

	### opt groups
	l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
	if(any(l_opt_group)) {
		i_opt = 0
		i_group = 0
		opt_group = list()
		opt_group_desc = NULL
		if(!l_opt_group[1]) {
			opt_group[[1]] = list()
			opt_group_desc = ""
			i_group = 1
		}
		for(i in seq_along(l_opt_group)) {
			if(l_opt_group[i]) {
				i_group = i_group + 1
				opt_group[[i_group]] = list()
				opt_group_desc = c(opt_group_desc, spec[i, 2])
			} else {
				i_opt = i_opt + 1
				opt_group[[i_group]] = c(opt_group[[i_group]], i_opt)
			}
		}
		spec = spec[!l_opt_group, , drop = FALSE]
	} else {
		opt_group = list(1:nrow(spec))
		opt_group_desc = "Options:"
	}

	if(is.list(envir)) envir = as.environment(envir)

	############### construct a list of SingleOption objects ####################
	opt_lt = list()
	for(i in seq_len(nrow(spec))) {
		opt_lt[[i]] = SingleOption(spec = spec[i, 1], desc = spec[i, 2], envir = envir)
	}
	names(opt_lt) = sapply(opt_lt, function(x) x$name)

	if("help" %in% names(opt_lt)) {
		stop_wrap("`help` is reserved as a default option. Please do not use it.")
	}
	
	if("version" %in% names(opt_lt)) {
		stop_wrap("`version` is reserved as a default option. Please do not use it.")
	}
	
	opt_lt$help = SingleOption(spec = "help", "Print help message and exit.")
	opt_lt$version = SingleOption(spec = "version", "Print version information and exit.")
	n_opt = length(opt_lt)

	opt_group[[length(opt_group)]] = c(opt_group[[length(opt_group)]], n_opt - 1, n_opt)

	if(!is.null(sub_opt)) {
		for(i in seq_len(n_opt)) {
			if(opt_lt[[i]]$name %in% names(sub_opt) && opt_lt[[i]]$var_type == "hash") {
				opt_lt[[i]]$sub_opt = sub_opt[[ opt_lt[[i]]$name ]]
			}
		}
	}

	## add short opt name
	first_letter = lapply(opt_lt, function(opt) {
		full_opt = opt$full_opt
		substr(full_opt, 1, 1)
	})
	first_letter_tb = table(unlist(first_letter))[unique(unlist(first_letter))]
	first_letter_unique = names(first_letter_tb[first_letter_tb == 1])
	for(le in first_letter_unique) {
		ind = which(sapply(first_letter, function(x) any(x == le)))
		opt_lt[[ind]]$full_opt = unique(c(opt_lt[[ind]]$full_opt, le))
	}

	# get the path of binary perl
	# it will look in PATH and also user's command-line argument
	perl_bin = find_perl_bin(con = OUT, from_command_line = IS_UNDER_COMMAND_LINE)

	# check whether Getopt::Long is in @INC
	# normally, it is shippped with standard Perl distributions
	if(!check_perl("Getopt::Long", perl_bin = perl_bin)) {
		cat(red("Error: Cannot find Getopt::Long module in your Perl library.\n"), file = OUT)
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 127)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}
	
	# check whether JSON is in @INC
	if(!check_perl("JSON", inc = qq("@{system.file('extdata', package='GetoptLong')}/perl_lib"), perl_bin = perl_bin)) {
		cat(red("Error: Cannot find JSON module in your Perl library.\n"), file = OUT)
		
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 127)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	json_file = tempfile(fileext = ".json")
	perl_script = generate_perl_script(opt_lt, json_file)
	
	# get arguments string
	if(is.null(argv_str)) {
		ARGV = commandArgs(TRUE)
		ARGV_string = reformat_argv_string(opt_lt, ARGV)
	} else {
		if(grepl("'|\\\"", argv_str)) {
			ARGV_string = argv_str
		} else {
			ARGV_string = reformat_argv_string(opt_lt, strsplit(argv_str, "\\s+")[[1]])
		}
	}

	cmd = qq("\"@{perl_bin}\" \"@{perl_script}\" @{ARGV_string}")
	res = system(cmd, intern = TRUE)
	res = as.vector(res)

	script_name = NULL

	# if you specified wrong arguments
	if(length(res)) {
		cat(red(qq("Error: @{res}\n")), file = OUT)
		
		print_help_msg(opt_lt, file = OUT, script_name = script_name, head = help_head, foot = help_foot,
			template = template, template_control = template_control, style = help_style,
			opt_group = opt_group, opt_group_desc = opt_group_desc)
		
		suppressWarnings({
			file.remove(json_file)
			file.remove(perl_script)
		})
		
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 127)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	# if arguments are correct, values for options will be stored in .json file
	opt_json = fromJSON(file = json_file)
	suppressWarnings({
		file.remove(json_file)
		file.remove(perl_script)
	})

	for(opt_name in names(opt_json)) {
		opt = opt_lt[[opt_name]]
		if(opt$opt_type == "negatable_logical") {
			if(negatable_logical_is_called(opt_name, argv_str)) {
				opt$set_opt(opt_json[[opt_name]])
			} else { # Perl tells the value is FALSE, but if there is default, the value is reassigned
				opt$set_opt(opt$default)
			}
		} else {
			opt$set_opt(opt_json[[opt_name]])
		}
		opt_lt[[opt_name]] = opt
	}

	## logical options always have values no matter they are specified or not
	## reset the value to NULL if they are not specified.
	for(opt_name in names(opt_json)) {
		opt = opt_lt[[opt_name]]
		if(opt$opt_type == "negatable_logical") {
			if(!negatable_logical_is_called(opt_name, argv_str)) {
				# opt$set_opt(NULL)
			}
		}
	}

	if(opt_json$help) {
		print_help_msg(opt_lt, file = stdout(), script_name = script_name, head = help_head, foot = help_foot, 
			template = template, template_control = template_control, style = help_style,
			opt_group = opt_group, opt_group_desc = opt_group_desc)
		
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 0)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}
	
	if(opt_json$version) {
		print_version_msg(envir, file = stdout())
		
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 0)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	# check mandatory options
	for(opt_name in names(opt_json)) {
		if(!opt_lt[[opt_name]]$validate_mandatory(opt_json[[opt_name]])) {
			cat(red(qq("Error: `@{opt_name}` is mandatory\n")), file = OUT)

			print_help_msg(opt_lt, file = OUT, script_name = script_name, head = help_head, foot = help_foot,
				template = template, template_control = template_control, style = help_style,
				opt_group = opt_group, opt_group_desc = opt_group_desc)
			if(IS_UNDER_COMMAND_LINE) {
				q(save = "no", status = 127)
			} else if(!is.null(argv_str)) {  # under test
				return(invisible(NULL))
			} else {
				stop_wrap("You have an error.\n")
			}
		}
	}

	export_to_parent_frame(opt_lt, envir = envir)
	
	return(invisible(opt_lt))
}


# test whether long_name is called in argv_str
# negatable_logical_is_called("verbose", "--verbose")
# negatable_logical_is_called("verbose", "-verbose")
# negatable_logical_is_called("verbose", "--v")
# negatable_logical_is_called("verbose", "-v")
# negatable_logical_is_called("verbose", "--no-verbose")
negatable_logical_is_called = function(long_name, argv_str) {
	argv = strsplit(argv_str, " ")[[1]]
	argv = argv[grepl("^-", argv)]
	if(length(argv)) {
		argv = gsub("^-+", "", argv)
		if(any(sapply(argv, function(x) grepl(qq("^@{x}"), long_name)))) {
			return(TRUE)
		} else {
			long_name2 = gsub("(?<=\\w)_(?=\\w)", "-", long_name, perl = TRUE)
			any(sapply(argv, function(x) grepl(qq("(no-?)?@{long_name}$"), x))) || any(sapply(argv, function(x) grepl(qq("(no-?)?@{long_name2}$"), x)))
		}
	} else {
		return(FALSE)
	}
}


# == title
# Wrapper of the Perl module ``Getopt::Long`` in R
#
# == param
# -... Pass to `GetoptLong`.
# -envir User's enrivonment where `GetoptLong` looks for default values and exports variables.
#
# == details
# This function is the same as `GetoptLong`. It is just to make it consistent as the ``GetOptions()`` 
# subroutine in ``Getopt::Long`` module in Perl.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
GetOptions = function(..., envir = parent.frame()) GetoptLong(..., envir = envir)

export_to_parent_frame = function(opt_lt, envir = parent.frame()) {

	n = length(opt_lt)
	for(i in seq_len(n)) {
		opt = opt_lt[[i]]
		if(opt$name %in% c("help", "version")) {
			next
		}

		if(!is.null(opt$value)) {
			v = opt$value
			assign(opt$name, v, envir = envir)
		}
	}
	return(invisible(NULL))
}


# == title
# File name of current script
#
# == value
# If the R script is not run from the command-line, it returns ``NULL``.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
get_scriptname = function() {
	args = commandArgs()
	
	if(length(args) == 1) {
		return(NULL)
	}
    f = grep("^--file=", args, value = TRUE)
    if(length(f)) {
    	f = gsub("^--file=(.*)$", "\\1", f[1])
    	return(f)	
    } else {
    	return(GetoptLong.options("__script_name__"))
    }  
}

# == title
# Directory of current script
#
# == value
# If the R script is not run from the command-line, it returns ``NULL``.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
get_scriptdir = function() {
	args = commandArgs()
	
	f = grep("^--file=", args, value = TRUE)
    if(length(f)) {
    	f = gsub("^--file=(.*)$", "\\1", f[1])
    	return(dirname(normalizePath(f)))	
    } else {
    	return(NULL)
    }
}

# == title
# Source the R script with command-line arguments
#
# == param
# -file The R script
# -... Pass to `base::source`.
# -argv_str The command-line arguments.
#
source_script = function(file, ..., argv_str = NULL) {
	GetoptLong.options("__argv_str__" = argv_str)
	GetoptLong.options("__script_name__" = file)
	on.exit({
		GetoptLong.options("__script_name__" = NULL)
		GetoptLong.options("__argv_str__" = NULL)
	})

	base::source(file, ...)
}

source = function (file, ..., argv = NULL) {
    GetoptLong.options(`__argv_str__` = argv)
    GetoptLong.options(`__script_name__` = file)
    on.exit({
    	GetoptLong.options(`__script_name__` = NULL)
    	GetoptLong.options(`__argv_str__` = NULL)
    })
    base::source(file, ...)
}

parse_spec_template = function(template, match = GetoptLong.options("template_tag")) {
	lt = find_code(match, template)
	spec = cbind(lt$code, rep("", length(lt$code)))
	spec = spec[!grepl("^#", spec[, 1]), ,drop = FALSE]

	return(spec)
}

## careful when ARGV_string is --a '1 2 3' where '1, 2, 3' should not be split
reformat_argv_string = function(opt_lt, argv) {

	current_tag = NA
	tag_increment = 0
	argv2 = NULL

	for(i in seq_along(argv)) {
		if(grepl("^(-|\\+)", argv[i])) {

			## check multi-word option
			if(grepl("^--", argv[i])) {
				if(grepl("^--no-", argv[i])) {
					logi_var_name = gsub("^--no-", "", argv[i])
					logi_var_name2 = gsub("(?<=\\w)-(?=\\w)", "_", logi_var_name, perl = TRUE)

					opt = look_up_opt_by_tag(opt_lt, logi_var_name2)
					if(is.null(opt)) {
						argv[i] = gsub("(?<=\\w)-(?=\\w)", "_", argv[i], perl = TRUE)
					} else {
						if(!grepl("logical", opt$opt_type)) {
							argv[i] = gsub("(?<=\\w)-(?=\\w)", "_", argv[i], perl = TRUE)
						} else {
							argv[i] = paste0("--no-", logi_var_name2)
						}
					}
				} else {
					argv[i] = gsub("(?<=\\w)-(?=\\w)", "_", argv[i], perl = TRUE)
				}
			}

			current_tag = argv[i]
			tag_increment = 0
			argv2 = c(argv2, argv[i])
		} else {
			tag_increment = tag_increment + 1
			if(tag_increment == 1) argv2 = c(argv2, argv[i])
		}

		if(tag_increment >= 2) {
			opt  = look_up_opt_by_tag(opt_lt, current_tag)
			if(is.null(opt)) {
				argv2 = c(argv2, argv[i])
			} else {
				if(grepl("(@|%)$", opt$spec)) {
					argv2 = c(argv2, qq("--@{opt$name}"), argv[i])
				} else {
					argv2 = c(argv2, argv[i])
				}
			}
		}
	}

	paste(argv2, collapse = " ")
}

look_up_opt_by_tag = function(opt_lt, tag) {

	tag = gsub("^(-|--|\\+)", "", tag)
	ind = NULL
	for(i in seq_along(opt_lt)) {
		opt = opt_lt[[i]]
		if(tag %in% opt$full_opt) {
			ind = c(ind, i)
		} else if(any(grepl(qq("^@{tag}"), opt$full_opt))) {
			ind  = c(ind, i)
		}
	}
	if(length(ind) != 1) {
		return(NULL)
	} else {
		return(opt_lt[[ind]])
	}
}

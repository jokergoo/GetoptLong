
# == title
# Setting sub commands
#
# == param
# -...     Specification of commands. See section Details.
# -help_head Head of the help message when invoking ``Rscript foo.R``.
# -help_foot Foot of the help message when invoking ``Rscript foo.R``.
# -argv_str A string that contains command-line arguments. It is only for testing purpose.
#
# == details
# The format of input can be one of the following:
#
# 1. A matrix with two columns. Then the first column contains paths of the scripts and the second column contains the description of the subcommand. The basenames of path in the first column
#    by removing the suffix are taken as the sub commands.
# 2. A matrix with three columns. The the first column contains the sub commands, the second column contains corresponding script paths and the third column contains descriptions of the sub commands.
# 3. A vector with length as multiples of 2. In this case, every two elements are grouped and concatenated into a matrix by rows. Then it follows the rule 1.
# 4. A vector with length as multiples of 3. In this case, every three elements are grouped and concatenated into a matrix by rows. Then it follows the rule 2.
#
subCommands = function(..., help_head = NULL, help_foot = NULL, argv_str = NULL) {

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

	# a vector or a two-column/three-column matrix
	if(length(spec) == 1) {
		spec = spec[[1]]
	} else {
		spec = unlist(spec)
	}

	if(is.matrix(spec)) {
		if(ncol(spec) == 2) {
			l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
			if(!all(file.exists(spec[!l_opt_group, 1]))) {
				stop_wrap("The specification is set as a two-column matrix. The first column should be paths of the scripts.")
			}
			spec = cbind(gsub("\\.\\w+$", "", basename(spec)), spec)
		} else if(ncol(spec) == 3 ) {
			l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
			if(!all(file.exists(spec[!l_opt_group, 2]))) {
				stop_wrap("The specification is set as a three-column matrix. The second column should be paths of the scripts.")
			}
		} else {
			stop_wrap("If the specification is a matrix, it should be a two-column or three-column matrix.")
		}
		colnames(spec) = c("command", "script", "description")

	} else {
		if(is.vector(spec)) {
			if(length(spec) %% 6 == 0) {
				# test whether it is two-column setting or three-column
				l = seq_along(spec) %% 2 == 1
				spec2 = cbind(command = basename(spec[l]), script = spec[l], description = spec[!l])
				l_opt_group = grepl("^[-=\\+#%]*$", spec2[, 1])
				if(all(file.exists(spec2[!l_opt_group, 2]))) {
					spec = spec2
				} else {
					ind = seq_along(spec) %% 3 == 2
					spec2 = cbind(command = gsub("\\.\\w+$", "", basename(spec[seq_along(spec) %% 3 == 1])), script = spec[seq_along(spec) %% 3 == 2], description = spec[seq_along(spec) %% 3 == 0])
					l_opt_group = grepl("^[-=\\+#%]*$", spec2[, 1])
					if(all(file.exists(spec2[!l_opt_group, 2]))) {
						spec = spec2
					} else {
						stop_wrap(qq("The specification is set as a vector of length @{length(spec)}. If it is a multiple of 2, elements with indices 1,3,... should be paths of the script, and if the length is a multiple of 3, elements with indices 1,4,7,... should be command names and elements with indices 2,5,8,... should be paths of the corresponding scripts."))
					}
				}
				
			} else if(length(spec) %% 2 == 0) {
				l = seq_along(spec) %% 2 == 1
				spec = cbind(command = basename(spec[l]), script = spec[l], description = spec[!l])
				l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
				if(!all(file.exists(spec[!l_opt_group, 2]))) {
					stop_wrap(qq("The specification is set as a vector of length @{length(spec)}. Elements with indices 1,3,... should be paths of the script."))
				}
			} else if(length(spec) %% 3 == 0) {
				ind = seq_along(spec) %% 3 == 2
				spec = cbind(command = gsub("\\.\\w+$", "", basename(spec[seq_along(spec) %% 3 == 1])), script = spec[seq_along(spec) %% 3 == 2], description = spec[seq_along(spec) %% 3 == 0])
				l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
				if(!all(file.exists(spec[!l_opt_group, 2]))) {
					stop_wrap(qq("The specification is set as a vector of length @{length(spec)}. Elements with indices 1,4,7,... should be command names and elements with indices 2,5,8,... should be paths of the corresponding scripts."))
				}
			} else {
				stop_wrap(qq("The specification is set as a vector}. The length of it must be multiples of 2 or 3."))
			}
		} else {
			stop_wrap("Wrong specification.")
		}
	}
	
	### opt groups
	l_opt_group = grepl("^[-=\\+#%]*$", spec[, 1])
	if(any(l_opt_group)) {
		i_group = 0
		opt_group = list()
		opt_group_desc = NULL
		if(!l_opt_group[1]) {
			opt_group[[1]] = numeric(0)
			opt_group_desc = ""
			i_group = 1
		}
		for(i in seq_along(l_opt_group)) {
			if(l_opt_group[i]) {
				i_group = i_group + 1
				opt_group[[i_group]] = numeric(0)
				opt_group_desc = c(opt_group_desc, spec[i, 3])
			} else {
				opt_group[[i_group]] = c(opt_group[[i_group]], i)
			}
		}
	} else {
		opt_group = list(1:nrow(spec))
		opt_group_desc = "Commands:"
	}

	all_commands = spec[!l_opt_group, 1]

	script_name = get_scriptname()
    if(is.null(script_name)) {
    	script_name = "foo.R"
    } else {
    	script_name = basename(script_name)
    }

	if(is.null(argv_str)) {
		ARGV = commandArgs(TRUE)
	} else {
		ARGV = strsplit(argv_str, "\\s+")[[1]]
	}

	if(length(ARGV) == 0) {
		print_help_msg_sub_commands(spec, file = stdout(), script_name = script_name, head = help_head, foot = help_foot, 
			opt_group = opt_group, opt_group_desc = opt_group_desc)
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 0)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	cmd = ARGV[1]
	ARGV_string = paste(ARGV[-1], collapse = " ")

	if(grepl("^-", cmd)) {
		cat(red(qq("Error: a command should be specified.\n")), file = OUT)

		print_help_msg_sub_commands(spec, file = stdout(), script_name = script_name, head = help_head, foot = help_foot, 
			opt_group = opt_group, opt_group_desc = opt_group_desc)
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 0)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	if(!cmd %in% all_commands) {
		cat(red(qq("Error: wrong command: @{cmd}.\n")), file = OUT)

		print_help_msg_sub_commands(spec, file = OUT, script_name = script_name, head = help_head, foot = help_foot, 
			opt_group = opt_group, opt_group_desc = opt_group_desc)
		if(IS_UNDER_COMMAND_LINE) {
			q(save = "no", status = 0)
		} else if(!is.null(argv_str)) {  # under test
			return(invisible(NULL))
		} else {
			stop("You have an error.\n")
		}
	}

	script = spec[spec[, 1] == cmd, 2]
	GetoptLong.options("__prefix__" = paste0("Rscript ", script_name, " ", cmd))
	on.exit(GetoptLong.options("__prefix__" = NULL))

	source_script(script, argv_str = ARGV_string)
}


print_help_msg_sub_commands = function(spec, file = stderr(), script_name = NULL, head = NULL, foot = NULL,
	opt_group = NULL, opt_group_desc = NULL) {

	if(is.null(script_name)) {
    	script_name = get_scriptname()
	    if(is.null(script_name)) {
	    	script_name = "foo.R"
	    } else {
	    	script_name = basename(script_name)
	    }
	}
	if(!is.null(head)) {
		cat(format_text(head, prefix = NULL), file = file)
		cat("\n", file = file)
		cat("\n", file = file)
	}

    qqcat("Usage: Rscript @{script_name} [command] [options]\n", file = file)
    qqcat("\n", file = file)

    for(ig in seq_along(opt_group)) {

    	ind = opt_group[[ig]]

    	if(!grepl("^\\s*$", opt_group_desc[ig])) {
	    	qqcat("@{format_text(opt_group_desc[ig], prefix = NULL)}\n", file = file)
	    }
	    
	    opt_width = max(nchar(spec[ind, 1]))
	    prefix = strrep(" ", opt_width + 6)
		for(i in ind) {
			cat("  ", spec[i, 1], strrep(" ", opt_width - nchar(spec[i, 1])), "    ", file = file, sep = "")
			desc = strwrap(spec[i, 3], width = 0.9*GetoptLong.options$help_width - opt_width - 6)
			if(length(desc) > 1) {
				desc[-1] = paste0(prefix, desc[-1])
			}
			cat(paste(desc, collapse = "\n"), file = file)
			cat("\n", file = file)
		}

		cat("\n", file = file)
		
	}

	if(!is.null(foot)) {
		cat(format_text(foot, prefix = NULL), file = file)
		cat("\n", file = file)
	}
}

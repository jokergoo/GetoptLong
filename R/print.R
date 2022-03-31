
print_help_msg = function(opt_lt, file = stderr(), script_name = NULL, head = NULL, foot = NULL,
	template = NULL, template_control = template_control, style = c("one-column", "two-column"),
	opt_group = NULL, opt_group_desc = NULL) {

	if(is.null(template)) {
	
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

		if(is.null(GetoptLong.options("__prefix__"))) {
	    	qqcat("Usage: Rscript @{script_name} [options]\n", file = file)
	    } else {
	    	qqcat("Usage: @{GetoptLong.options('__prefix__')} [options]\n", file = file)
	    }
	    qqcat("\n", file = file)

	    for(ig in seq_along(opt_group)) {

	    	ind = opt_group[[ig]]

		    qqcat("@{format_text(opt_group_desc[ig], prefix = NULL)}\n", file = file)
		    
		    style = match.arg(style)
		    if(style == "one-column") {
				for(i in ind) {
					cat(opt_lt[[i]]$help_message(), "\n", file = file)
				}
			} else {
				opt_line = NULL
				for(i in ind) {
					opt_line = c(opt_line, opt_lt[[i]]$help_message_two_columns(only_opt = TRUE))
				}
				opt_width = max(nchar(opt_line))

				for(i in ind) {
					cat(opt_lt[[i]]$help_message_two_columns(opt_width = opt_width), "\n", file = file)
				}
				cat("\n", file = file)
			}
		}

		if(!is.null(foot)) {
			cat(format_text(foot, prefix = NULL), file = file)
			cat("\n", file = file)
		}
	} else {

		lines = strsplit(template, "\n")[[1]]
		for(i in seq_along(lines)) {
			lt = find_code(GetoptLong.options("template_tag"), lines[i])
			if(length(lt$template) == 0) next

			for(j in seq_along(lt$template)) {
				for(k in seq_along(opt_lt)) {
					if(opt_lt[[k]]$spec == lt$code[j]) {

						data_type = TRUE
						if(!is.null(template_control$data_type)) {
							if(length(template_control$data_type) == 1 && is.null(names(template_control$data_type))) {
								data_type = template_control$data_type
							} else {
								data_type = template_control$data_type[opt_lt[[k]]$name]
								if(is.na(data_type)) data_type = TRUE
							}
						}

						opt_str = gsub("\n$", "", opt_lt[[k]]$help_message(prefix = "", which = "opt_line", data_type = data_type))
							
						opt_width = NULL
						if(!is.null(template_control$opt_width)) {
							if(length(template_control$opt_width) == 1 && is.null(names(template_control$opt_width))) {
								opt_width = template_control$opt_width
							} else {
								opt_width = template_control$opt_width[opt_lt[[k]]$name]
								if(is.na(opt_width)) opt_width = NULL
							}
						}

						if(is.null(opt_width)) {
							lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
						} else {
							if(opt_width < nchar(opt_str)) {
								lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
							} else {
								opt_str = paste0(opt_str, strrep(" ", opt_width - nchar(opt_str)))
								lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
							}
						}
					} else if(grepl("^#", lt$code[j])) {
						if(opt_lt[[k]]$name == gsub("^#", "", lt$code[j])) {
							opt_str = gsub("\n$", "", opt_lt[[k]]$help_message(prefix = "", which = "opt_line", data_type = data_type))
							
							opt_width = NULL
							if(!is.null(template_control$opt_width)) {
								if(length(template_control$opt_width) == 1 && is.null(names(template_control$opt_width))) {
									opt_width = template_control$opt_width
								} else {
									opt_width = template_control$opt_width[opt_lt[[k]]$name]
									if(is.na(opt_width)) opt_width = NULL
								}
							}

							opt_str = ""
							if(is.null(opt_width)) {
								lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
							} else {
								if(opt_width < nchar(opt_str)) {
									lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
								} else {
									opt_str = paste0(opt_str, strrep(" ", opt_width - nchar(opt_str)))
									lines[i] = gsub(lt$template[j], opt_str, lines[i], fixed = TRUE)
								}
							}
						}
					}
				}
			}
		}

		cat(paste(lines, collapse  = "\n"), "\n", file = file)
	}
}

print_version_msg = function(envir, file = stderr()) {
	if(exists("VERSION", envir = envir)) {
		cat(get("VERSION", envir = envir, inherits = FALSE), file = file)
	} else {
		cat("No version information is found in the script.", file = file)
	}
	cat("\n", file = file)
}

format_text = function(text, prefix = "  ", width = GetoptLong.options$help_width) {
	text = text
	text = gsub("^\\s+", "", text)
	if(is.null(prefix)) {
		text = strwrap(text, width = 0.9*(width))
		text = paste(text, collapse = "\n")
	} else {
		text = strwrap(text, width = 0.9*(width - nchar(prefix) - 2))
		text = paste(prefix, "  ", text, sep = "", collapse = "\n")
	}

	text
}

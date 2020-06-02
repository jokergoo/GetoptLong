
print_help_msg = function(opt_lt, file = stderr(), script_name = NULL, head = NULL, foot = NULL,
	template = NULL, template_control = template_control) {

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

	    qqcat("Usage: Rscript @{script_name} [options]\n", file = file)
	    qqcat("\n", file = file)
	    qqcat("Options:\n", file = file)
	    	
		for(i in seq_along(opt_lt)) {
			cat(opt_lt[[i]]$help_message(), "\n", file = file)
		}

		if(!is.null(foot)) {
			cat(format_text(foot, prefix = NULL), file = file)
			cat("\n", file = file)
		}
	} else {

		lt = find_code(GetoptLong.options("template_tag"), template)
		lines = strsplit(template, "\n")[[1]]
		for(i in seq_along(lines)) {
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
							
						max_width = NULL
						if(!is.null(template_control$max_width)) {
							if(length(template_control$max_width) == 1 && is.null(names(template_control$max_width))) {
								max_width = template_control$max_width
							} else {
								max_width = template_control$max_width[opt_lt[[k]]$name]
								if(is.na(max_width)) max_width = NULL
							}
						}
						if(is.null(max_width)) {
							lines[i] = gsub(lt$template[k], opt_str, lines[i], fixed = TRUE)
						} else {
							if(max_width < nchar(opt_str)) {
								lines[i] = gsub(lt$template[k], opt_str, lines[i], fixed = TRUE)
							} else {
								opt_str = paste0(opt_str, strrep(" ", max_width - nchar(opt_str)))
								lines[i] = gsub(lt$template[k], opt_str, lines[i], fixed = TRUE)
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

format_text = function(text, prefix = "  ", width = 80) {
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


SingleOption = setRefClass("SingleOption",
    fields = list(
    	"name" = "character",
    	"spec" = "character",
    	"desc" = "character",
    	"full_opt" = "character",
    	"has_default" = "logical",
    	"is_mandatory" = "logical",
    	"value" = "ANY",
    	"default" = "ANY",
    	"var_type" = "character",
    	"opt_type" = "character",
    	"sub_opt" = "ANY"
    )
)

DEFAULT_OPTIONS = c("help", "version")

SingleOption$methods(
	initialize = function(spec, desc = "", envir = parent.frame(4), ...) {
		obj = callSuper(...)
		full_opt_names = extract_opt_name(spec)
		opt_name = full_opt_names[1]
		
		if(!grepl("^[a-zA-Z_\\.][a-zA-Z0-9_\\.]*$", opt_name)) {
			stop_wrap("Option name in option (@{spec}) can only be a valid R variable name which only uses numbers, letters,'.' and '_' (It should match /^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$/).")
		}
	
		obj$name = opt_name
		obj$spec = spec
		obj$full_opt = full_opt_names
		obj$value = NULL
		obj$desc = desc
		if(grepl("^\\s*$", obj$desc)) obj$desc = "No description is provided."

		obj$is_mandatory = detect_mandatory_on_spec(spec)

		if(detect_optional_on_spec(spec)) {
			stop_wrap("type :[isfo] is not allowed, use =[isfo] instead.")
		}

		obj$var_type = detect_var_type(spec) # scalar/array/hash
		obj$opt_type = detect_opt_type(spec) # character/integer/numeric/logical/negatable_logical

		obj$has_default = FALSE
		obj$is_mandatory = TRUE
		obj$default = NULL
		obj$sub_opt = NULL

		# assign defaults
		if(exists(opt_name, envir = envir, inherits = FALSE)) {
			v = get(opt_name, envir = envir, inherits = FALSE)
			if(is.function(v)) {
				obj$has_default = FALSE
				obj$is_mandatory = TRUE
				obj$default = NULL
			} else {
				obj$has_default = TRUE
				obj$default = v
				obj$is_mandatory = FALSE
			}
		}

		if(obj$opt_type == "negatable_logical") {
			if(!obj$has_default) {
				obj$has_default = TRUE
				obj$default = FALSE
				obj$is_mandatory = FALSE
			}
		} else if(obj$opt_type == "logical") {
			if(obj$has_default) {
				message_wrap(qq("The default of `@{opt_name}` is ignored unless the specification is set as '@{opt_name}!'. Reset it to FALSE."))
			}
			obj$has_default = TRUE
			obj$default = FALSE
			obj$is_mandatory = FALSE
		}

		## check the format of the default value
		v = obj$default
		if(obj$has_default && !obj$name %in% DEFAULT_OPTIONS) {
			if(!is.null(v)) {
				if(obj$opt_type == "logical") {
					
				} else if(obj$opt_type == "negatable_logical") {
					if(!(identical(v, TRUE) || identical(v, FALSE))) {
						if(is.atomic(v) && is.vector(v)) {
							if(length(v) > 1) {
								obj$default = TRUE
							} else if(length(v) == 1 ) {
								if(is.na(v)) {
									obj$default = FALSE
								} else if(is.numeric(v)) {
									obj$default = as.logical(v)
								} else if(is.character(v)) {
									if(grepl("^\\s*$", v)) {
										obj$default = FALSE
									} else {
										obj$default = TRUE
									}
								} else {
									obj$default = FALSE
								}
							} else {
								obj$default = FALSE
							}
						} else {
							if(length(v) > 1) {
								obj$default = TRUE
							} else {
								obj$default = FALSE
							}
						} 
						message_wrap(qq("The default of `@{opt_name}` should be a logical scalar. Reset `@{opt_name}` as @{obj$default}."))
					}
				} else if(obj$var_type == "scalar") {
					if(length(v) != 1) {
						stop_wrap(qq("`@{opt_name}` is set as a scalar. The length of it must be 1."))
					}
					if(!(is.atomic(v) && is.vector(v))) {
						stop_wrap(qq("`@{opt_name}` is set as a scalar. The value should be an atomic scalar."))
					}
					if(obj$opt_type %in% c("integer", "numeric")) {
						if(is.na(v) && !is.numeric(v)) {
							if(.self$opt_type == "integer") {
								v = NA_integer_
							} else {
								v = NA_real_
							}
							.self$default = v
						}
						if(!is.numeric(v)) {
							stop_wrap(qq("`@{opt_name}` is set in integer/numeric. The value must be number."))
						}
					}
					if(obj$opt_type == "character") {
						if(is.na(v) && !is.character(v)) {
							v = NA_character_
							.self$default = v
						}
						if(!is.character(v)) {
							stop_wrap(qq("`@{opt_name}` is set in character. The value must be a character."))
						}
					}
				} else if(obj$var_type == "array") {
					if(!(is.atomic(v) && is.vector(v))) {
						stop_wrap(qq("`@{opt_name}` is set as an array. The value should be an atomic vector"))
					}
					if(obj$opt_type %in% c("integer", "numeric")) {
						if(!is.numeric(v)) {
							stop_wrap(qq("`@{opt_name}` is set in integer/numeric. The value must be number."))
						}
					}
					if(obj$opt_type == "character") {
						if(!is.character(v)) {
							stop_wrap(qq("`@{opt_name}` is set in character. The value must be a character."))
						}
					}
				} else if(obj$var_type == "hash") {
					if(!is.list(v)) {
						stop_wrap(qq("`@{opt_name}` is set as a hash. The value should be a list."))
					}
					if(is.null(names(v))) {
						stop_wrap(qq("`@{opt_name}` is set as a hash. The value should be a named list."))
					}
					for(i in seq_along(v)) {
						if(!(is.atomic(v[[i]]) && is.vector(v[[i]]))) {
							stop_wrap(qq("`@{opt_name}` is set as an hash. The value should be an atomic vector."))
						}
						if(obj$opt_type %in% c("integer", "numeric")) {
							if(!is.numeric(v[[i]])) {
								stop_wrap(qq("`@{opt_name}` is set in integer/numeric. The value must be number."))
							}
						}
						if(obj$opt_type == "character") {
							if(!is.character(v[[i]])) {
								stop_wrap(qq("`@{opt_name}` is set in character. The value must be a character."))
							}
						}
					}
				}
			}
		}

		return(obj)
	}
)

SingleOption$methods(
	set_opt = function(v) {
		if(.self$var_type == "hash") {
			if(.self$has_default) {
				old_nm = setdiff(names(.self$default), names(v))
				v = c(v, .self$default[old_nm])
			}
		}
		.self$value = v
	}
)

SingleOption$methods(
	validate_mandatory = function(v) {
		if(missing(v)) v = .self$value
		if(is.null(v)) {
			if(.self$is_mandatory) {
				return(FALSE)
			}
		}
		TRUE
	}
)

SingleOption$methods(
	help_message = function(prefix = "  ", width = GetoptLong.options$help_width, 
		which = c("opt_line", "desc_line"), data_type = TRUE) {

		msg = ""

		if("opt_line" %in% which) {
			opt_line = NULL
			for(nm in .self$full_opt) {
				if(nchar(nm) == 1) {
					opt_line = c(opt_line, qq("-@{nm}"))
				} else {
					opt_line = c(opt_line, qq("--@{nm}"))
				}
			}
			opt_line = paste(opt_line, collapse = ", ")
			opt_line = paste0(prefix, opt_line)

			# data type
			if(data_type) {
				if(.self$var_type == "scalar") {
					if(.self$opt_type == "logical") {

					} else if(.self$opt_type == "negatable_logical") {
						opt_line = paste0(opt_line, ", -no-", .self$name)
					} else {
						opt_line = paste0(opt_line, " ", .self$opt_type)
					}
				} else if(.self$var_type == "array") {
					opt_line = paste0(opt_line, " ", qq("[@{.self$opt_type}, ...]"))
				} else if(.self$var_type == "hash") {
					opt_line = paste0(opt_line, " ", qq("{name=@{.self$opt_type}, ...}"))
				}
			}
			msg = paste0(msg, opt_line, "\n")
		}

		if("desc_line" %in% which) {
			desc_line = format_text(.self$desc, prefix = prefix, width = width)

			msg = paste0(msg, desc_line, "\n")
			default_str = .self$default_as_string()
			if(!is.null(default_str)) {
				msg = paste0(msg, prefix, "  ", "[default: ", default_str, "]\n")
			}

			abbr = c("character" = "chr", "integer" = "int", "extended_integer" = "int", "numeric" = "num")

			if(.self$var_type == "hash") {
				if(!is.null(.self$sub_opt)) {
					sub_opt_line = paste0("\n", prefix, "  Sub named options:\n")
					so = .self$sub_opt
					for(nm in names(so)) {
						str1 = paste0(prefix, "  ", nm, qq("=@{.self$opt_type}"))
						str2 = format_text(so[nm], prefix = paste0(prefix, strrep(" ", nchar(str1) + 1 - nchar(prefix) - 2)))
						substr(str2, 1, nchar(str1)) = str1
						sub_opt_line = paste0(sub_opt_line, str2, "\n")
					}

					msg = paste0(msg, sub_opt_line)
				}
			}
		}

		return(msg)
	}
)

SingleOption$methods(
	help_message_two_columns = function(prefix = "  ", only_opt = FALSE, opt_width = NULL,
		width = max(GetoptLong.options$help_width, opt_width + 60)) {
		
		opt_line = NULL
		for(nm in .self$full_opt) {
			if(nchar(nm) == 1) {
				opt_line = c(opt_line, qq("-@{nm}"))
			} else {
				opt_line = c(opt_line, qq("--@{nm}"))
			}
		}
		opt_line = paste(opt_line, collapse = ", ")
		opt_line = paste0(prefix, opt_line)

		abbr = c("character" = "chr", "integer" = "int", "extended_integer" = "int", "numeric" = "num")

		if(.self$var_type == "scalar") {
			if(.self$opt_type == "logical") {

			} else if(.self$opt_type == "negatable_logical") {
				opt_line = paste0(opt_line, ", -no-", .self$name)
			} else {
				opt_line = c(opt_line, paste0(prefix, "  [type: ", abbr[.self$opt_type], "]"))
			}
		} else if(.self$var_type == "array") {
			opt_line = c(opt_line, paste0(prefix, "  [type: ", qq("[@{abbr[.self$opt_type]}, ...]"), "]"))
		} else if(.self$var_type == "hash") {
			opt_line = c(opt_line, paste0(prefix, "  [type: ", qq("{name=@{abbr[.self$opt_type]}, ...}"), "]"))
		}
		
		if(only_opt) {
			return(opt_line)
		}

		prefix2 = strrep(" ", opt_width)
		desc_line = format_text(.self$desc, prefix = prefix2, width = width)

		default_str = .self$default_as_string()
		if(!is.null(default_str)) {
			desc_line = paste0(desc_line, prefix2, "\n", prefix2, "  ", "[default: ", default_str, "]")
		}

		if(.self$var_type == "hash") {
			if(!is.null(.self$sub_opt)) {
				sub_opt_line = paste0(prefix2, "\n", prefix2, "  Sub named options:\n")
				so = .self$sub_opt
				for(nm in names(so)) {
					str1 = paste0(prefix2, "  ", nm, qq("=@{abbr[.self$opt_type]}"))
					str2 = format_text(so[nm], prefix = paste0(prefix2, strrep(" ", nchar(str1) + 1 - nchar(prefix2) - 2)))
					substr(str2, 1, nchar(str1)) = str1
					sub_opt_line = paste0(sub_opt_line, str2, "\n")
				}
				desc_line = paste0(desc_line, prefix2, "\n", sub_opt_line, "\n")
			}
		}

		desc_line = strsplit(desc_line, "\n")[[1]]

		n1 = length(opt_line)
		n2 = length(desc_line)
		msg = character(max(n1, n2))
		for(i in seq_along(msg)) {
			if(i <= n1 && i <= n2) {
				msg[i] = desc_line[i]
				substr(msg[i], 1, nchar(opt_line[i])) = opt_line[i]
			} else if(i > n1) {
				msg[i] = desc_line[i]
			} else if(i > n2) {
				msg[i] = opt_line[i]
			}
		}

		paste(msg, collapse = "\n")

	}
)

SingleOption$methods(
	default_as_string = function() {
		if(.self$has_default) {
			if(.self$opt_type == "logical") {
				return(NULL)
			} else if(.self$opt_type == "negatable_logical") {
				if(.self$default) {
					return("on")
				} else {
					return("off")
				}
			} else if(.self$var_type == "scalar") {
				if(is.null(.self$default)) {
					return("NULL")
				} else {
					return(as.character(.self$default))
				}
			} else if(.self$var_type == "array") {
				if(is.null(.self$default)) {
					return("NULL")
				} else {
					return(paste(.self$default, collapse = ", "))
				}
			} else if(.self$var_type == "hash") {
				if(is.null(.self$default)) {
					return("NULL")
				} else {
					return(paste(names(.self$default), .self$default, sep = "=", collapse = ", "))
				}
			}
		} else {
			return(NULL)
		}
	}
)

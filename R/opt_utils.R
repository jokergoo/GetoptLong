extract_opt_name = function(spec) {
	spec = gsub("[$@%]$", "", spec)
	spec = gsub("\\{.*\\}$", "", spec)
	spec = gsub("[=:][siof]$", "", spec)
	spec = gsub("[!+]$", "", spec)

	strsplit(spec, "\\|")[[1]]
}

detect_mandatory_on_spec = function(spec) {
	spec = gsub("[$@%]$", "", spec)
	spec = gsub("\\{.*\\}$", "", spec)
	
	grepl("=[siof]$", spec)
}

detect_optional_on_spec = function(spec) {
	spec = gsub("[$@%]$", "", spec)
	spec = gsub("\\{.*\\}$", "", spec)
	
	grepl(":[siof]$", spec)
}

# variable type
detect_var_type = function(opt) {
	sapply(opt, function(x) {
		if (grepl("\\$$", x)) {
			return("scalar")
		} else if (grepl("@$", x)) {
			return("array")
		} else if (grepl("%$", x)) {
			return("hash")
		} else if (grepl("\\{\\d?,?\\d?\\}$", x)) {
			return("array")
		} else {
			return("scalar")
		}
	}, USE.NAMES = FALSE)
}

# storage type
detect_opt_type = function(opt) {
	
	opt = gsub("[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	
	sapply(opt, function(x) {
		if (grepl("[=:]s$", x)) {
			return("character")
		} else if (grepl("[=:]i$", x)) {
			return("integer")
		} else if (grepl("[=:]o$", x)) {
			return("extended_integer")
		} else if (grepl("[=:]f$", x)) {
			return("numeric")
		} else if (grepl("!$", x)) {
			return("negatable_logical")
		} else if (grepl("\\+$", x)) {
			return("integer")
		} else {
			return("logical")
		}
	}, USE.NAMES = FALSE)
}



stop_wrap = function (...) {
    x = paste0(...)
    x = paste(strwrap(x), collapse = "\n")
    stop(x, call. = FALSE)
}

warning_wrap = function (...) {
    x = paste0(...)
    x = paste(strwrap(x), collapse = "\n")
    warning(x, call. = FALSE)
}

message_wrap = function (...) {
    x = paste0(...)
    x = paste(strwrap(x), collapse = "\n")
    message(x)
}




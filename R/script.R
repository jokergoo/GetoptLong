library(rjson)

# == param
# -spec specification of arguments, prefer a two-column matrix
GetoptLong = function(spec, envir = parent.frame(), argv_str = NULL) {
	
	if(is.null(argv_str)) {
		ARGV = commandArgs(TRUE)
		ARGV_string = paste(ARGV, collapse = " ")
	} else {
		ARGV_string = argv_str
	}
	
	first_name = extract_first_name(spec[, 1])
	
	test_long_name = grepl("^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$", first_name)
	
	if(!all(test_long_name)) {
		cat("First option name can only be valid variable name which can only use numbers, letters,\n'.' and '_' (It should match /^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$/).")
		cat(qq(" Following option name@{ifelse(sum(test_long_name)==1, ' is', 's are')}\nnot valid:\n\n"))
		for(k in seq_along(test_long_name)) {
			if(!test_long_name[k]) cat(qq("  @{spec[k, 1]}\n"))
		}
		cat("\n")
		return(NULL)
	}
	
	#json_file = tempfile(tmpdir = ".", fileext = ".json")
	json_file = "tmp.json"
	perl_script = generate_perl_script(spec, json_file, envir = envir)
	
	msg = system(qq("perl @{perl_script} @{ARGV_string}"), intern = FALSE)
	
	if(msg) {
		print_help_msg(spec)
		#file.remove(json_file)
		#file.remove(perl_script)
		return(NULL)
	}

	opt = fromJSON(file = json_file)
	#file.remove(json_file)
	#file.remove(perl_script)
	
	is_mandatory = detect_mandatory(spec[, 1])
	long_name = gsub("^([a-zA-Z_\\.][a-zA-Z0-9_\\.]+).*$", "\\1", spec[, 1])
	
	print(long_name)
	print(opt)
	for(i in seq_len(nrow(spec))) {
		if(is_mandatory[i] && is.null(opt[[ long_name[i] ]])) {
			cat(qq("--@{long_name[i]} is mandatory, please specify it.\n"))
			return(NULL)
		}
		
		if(is_mandatory[i] && exists(long_name[i], envir = envir)) {
			tmp = get(long_name[i], envir = envir)
			if(mode(tmp) %in% c("numeric", "character")) {
				cat(qq("--@{long_name[i]} is mandatory, but detect in envoking environment you have already \ndefined `@{long_name[i]}`. Please remove definition of `@{long_name[i]}` in your source code.\n"))
				return(TRUE)
			}	
		}
	}
	# export to envir
	#export(opt, envir = envir)
	
	
	return(invisible(opt))
}


generate_perl_script = function(spec, json_file, envir) {
	#perl_script = tempfile(tmpdir = ".", fileext = ".pl")
	perl_script = "tmp.pl"
	
	long_name = extract_first_name(spec[, 1])

	# whether variable has been defined in parent environment
	name_defined = sapply(long_name, function(x) {
		if(exists(x, envir = envir)) {
			tmp = get(x, envir = envir)
			if(mode(tmp) %in% c("numeric", "character")) {
				return(TRUE)
			}	
		}
		return(FALSE)
	}, USE.NAMES = FALSE)
	
	var_type = sapply(spec[, 1], detect_var_type, USE.NAMES = FALSE)
	
	print(long_name)
	print(name_defined)
	print(var_type)
	
	spec[, 1] = gsub("[$@%]$", "", spec[, 1])
	spec[, 1] = gsub("\\{.*\\}$", "", spec[, 1])
	
	opt_type = sapply(spec[, 1], detect_opt_type)
	
	perl_code = ""
	perl_code = c(perl_code, qq("#!/usr/bin/perl"))
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("use strict;"))
	perl_code = c(perl_code, qq("use Getopt::Long;"))
	perl_code = c(perl_code, qq("use JSON;"))
	perl_code = c(perl_code, qq(""))

	for (i in seq_len(nrow(spec))) {
	
		if(var_type[i] == "array") {
		
			perl_code = c(perl_code, qq("my $opt_@{i}@{ifelse(name_defined[i], ' = []': '')};    # var_type = array"))
			
		} else if(var_type[i] == "hash") {
		
			perl_code = c(perl_code, qq("my $opt_@{i}@{ifelse(name_defined[i], ' = {}': '')};    # var_type = hash"))
			
		} else {
		
			perl_code = c(perl_code, qq("my $opt_@{i}@{ifelse(name_defined[i], ' = \\'\\'', '')};    # var_type = scalar"))
			
		}
	}
	
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("GetOptions("))
	
	for (i in seq_len(nrow(spec))) {
	
		if(var_type[i] == "scalar") {
		
			perl_code = perl_code = c(perl_code, qq("    '@{spec[i, 1]}' => \\$opt_@{i},"))

		} else {
		
			perl_code = perl_code = c(perl_code, qq("    '@{spec[i, 1]}' => $opt_@{i},"))

		}
	}
	
	perl_code = c(perl_code, qq(") or die (\"Error in command line argument.\\n\");"))

	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("my $all_opt = {"))

	for (i in seq_len(nrow(spec))) {
	
		if(opt_type[i] == "logical") {
		
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => $opt_@{i} ? JSON::true : JSON::false,"))

		} else {
		
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => $opt_@{i},"))

		}
	}
	
	perl_code = c(perl_code, qq("};"))
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("open JSON, '>@{json_file}' or die 'Cannot create temp file: @{json_file}';"))
	perl_code = c(perl_code, qq("print JSON to_json($all_opt, {pretty => 1});"))
	perl_code = c(perl_code, qq("close JSON;"))

	writeLines(perl_code, perl_script)
	return(perl_script)
}

print_help_msg = function(spec) {
	for(i in seq_len(nrow(spec))) {
		print_single_option(spec[i, 1], spec[i, 2])
	}
}

print_single_option = function(opt, desc) {
	var_type = detect_var_type(opt)
	opt = gsub("\\|[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	opt_type = detect_opt_type(opt)
	opt = gsub("[=:][siof]$", "", opt)
	opt = gsub("[!+]$", "", opt)
	
	choices = strsplit(opt, "\\|")[[1]]
	
	cat("  ")
	for(i in seq_along(choices)) {
		cat(qq("@{ifelse(nchar(choices[i]) == 1, '-', '--')}@{choices[i]}@{ifelse(i == length(choices), '', ', ')}"))
	}
	cat("\n")
	
	cat_format_line(desc, prefix = "    ")
	cat("\n")
}

cat_format_line = function(text, prefix = "", max.width = 70) {
	words = strsplit(text, "\\s+")[[1]]
	
	i_width = nchar(prefix)
	cat(prefix)
	for(i in seq_along(words)) {
		if(i_width + 1 + nchar(words[i]) > max.width) {
			cat("\n")
			cat(prefix)
			cat(words[i])
			i_width = nchar(prefix) + nchar(words[i])
		} else {
			cat(qq("@{words[i]}\n"))
			i_width = i_width + nchar(prefix)
		}
	}
}

detect_var_type = function(opt) {
	if (grepl("\\$$", opt)) {
		return("scalar")
	} else if (grepl("@$", opt)) {
		return("array")
	} else if (grepl("%$", opt)) {
		return("hash")
	} else if (grepl("\\{\\d?,?\\d?\\}$", opt)) {
		return("array")
	} else {
		return("scalar")
	}
}

detect_opt_type = function(opt) {
	if (grepl("[=:]s$", opt)) {
		return("character")
	} else if (grepl("[=:]i$", opt)) {
		return("integer")
	} else if (grepl("[=:]o$", opt)) {
		return("extended_integer")
	} else if (grepl("[=:]f$", opt)) {
		return("numeric")
	} else if (grepl("!$", opt)) {
		return("logical")
	} else if (grepl("\\+$", opt)) {
		return("integer")
	} else {
		return("logical")
	}
}

detect_mandatory = function(opt) {
	grepl("=", opt)
}

extract_first_name = function(opt) {
	opt = gsub("\\|[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	opt = gsub("[=:][siof]$", "", opt)
	opt = gsub("[!+]$", "", opt)

	first_name = sapply(strsplit(opt, "\\|"), function(x) x[1])
	return(first_name)
}
library(rjson)

# == title
# Wrapper of the Perl module ``Getopt::Long`` in R
#
# == param
# -spec     specification of options. A two-column matrix in which the first column
#           is the setting for option names and the second column is the description
#           of options. It is can also be a vector having even number of elements and it
#           will be converted to the two-column matrix
# -envir    user's enrivonment where `GetoptLong` will look for default values and export variables
# -export   whether export options as variables into user's enrivonment
# -argv_str command-line arguments, only for testing purpose
#
# == details
#
GetoptLong = function(spec, help = TRUE, version = TRUE, envir = parent.frame(), export = FALSE, argv_str = NULL) {
	
	# check first argument
	if(is.matrix(spec)) {
		if(ncol(spec) != 2) {
			stop("`spec` should be a two-column matrix.\n")
		}
	} else {
		if(is.vector(spec)) {
			if(length(spec) %% 2) {
				stop("Since `spec` is a vector, it should have even number of elements.\n")
			} else {
				spec = matrix(spec, ncol = 2, byrow = TRUE)
			}
		} else {
			stop("Wrong `spec` class.\n")
		}
	}
	
	if(help) {
		spec = rbind(spec, c("help", "Print help message and exit"))
	}
	if(version) {
		spec = rbind(spec, c("version", "Print version number and exit"))
	}
	
	# get arguments string
	if(is.null(argv_str)) {
		ARGV = commandArgs(TRUE)
		ARGV_string = paste(ARGV, collapse = " ")
	} else {
		ARGV_string = argv_str
	}
	
	first_name = extract_first_name(spec[, 1])
	
	if(!export) {
		# test whether first name in option name is a valid R variable name
		test_long_name = grepl("^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$", first_name) 
		
		if(!all(test_long_name)) {
			cat("First name in option names can only be valid R variable names which only use numbers, letters,\n'.' and '_' (It should match /^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$/).")
			cat(qq(" Following option name@{ifelse(sum(test_long_name)==1, ' is', 's are')}\nnot valid:\n\n"))
			for(k in seq_along(test_long_name)) {
				if(!test_long_name[k]) cat(qq("  @{spec[k, 1]}\n"))
			}
			cat("\n")
			return(NULL)
		}
	}
	
	#json_file = tempfile(tmpdir = ".", fileext = ".json")
	json_file = "tmp.json"
	perl_script = generate_perl_script(spec, json_file)
	
	ow = options("warn")[[1]]
	options(warn = -1)
	msg = system(qq("perl @{perl_script} @{ARGV_string}"), intern = FALSE)
	options(warn = ow)
	
	if(msg) {
		print_help_msg(spec)
		file.remove(json_file)
		file.remove(perl_script)
		return(NULL)
	}

	opt = fromJSON(file = json_file)
	file.remove(json_file)
	file.remove(perl_script)
	
	if(!is.null(opt$help) && opt$help) {
		print_help_msg(spec)
		return(NULL)
	}
	
	if(!is.null(opt$version) && opt$version) {
		print_version_msg(envir)
		return(NULL)
	}
	
	opt = opt[!names(opt) %in% c("help", "version")]
	
	if(!export) {
		return(opt)
	}
	
	# check mandatory options
	is_mandatory = detect_mandatory(spec[, 1])
	long_name = extract_first_name(spec[, 1])
	for(i in seq_len(nrow(spec))) {
		if(is_mandatory[i] && is.null(opt[[ first_name[i] ]])) {
			cat(qq("--@{first_name[i]} is mandatory, please specify it.\n"))
			return(NULL)
		}
		
		if(is_mandatory[i] && exists(first_name[i], envir = envir)) {
			tmp = get(first_name[i], envir = envir)
			if(mode(tmp) %in% c("numeric", "character")) {
				cat(qq("--@{first_name[i]} is mandatory, but detect in envoking environment you have already \ndefined `@{first_name[i]}`. Please remove definition of `@{long_name[i]}` in your source code.\n"))
				return(NULL)
			}	
		}
	}
	
	# export to envir
	export_parent_env(opt, envir = envir)
	
	return(invisible(opt))
}


generate_perl_script = function(spec, json_file) {
	#perl_script = tempfile(tmpdir = ".", fileext = ".pl")
	perl_script = "tmp.pl"
	
	long_name = extract_first_name(spec[, 1])

	var_type = detect_var_type(spec[, 1])
	opt_type = detect_opt_type(spec[, 1])
	
	perl_code = ""
	perl_code = c(perl_code, qq("#!/usr/bin/perl"))
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("use strict;"))
	if(is.null(options("GetoptLong.Config"))) {
		perl_code = c(perl_code, qq("use Getopt::Long;"))
	} else {
		perl_code = c(perl_code, qq("use Getopt::Long qw(:config @{paste(options('GetoptLong.Config')[[1]], collapse = ' ')});"))
	}
	
	perl_code = c(perl_code, qq("use JSON;"))
	perl_code = c(perl_code, qq("use Data::Dumper;"))
	perl_code = c(perl_code, qq(""))
	
	# check whether defined or not defined matters
	for (i in seq_len(nrow(spec))) {
	
		if(var_type[i] == "array") {
		
			perl_code = c(perl_code, qq("my @opt_@{i};    # var_type = array, opt_type = @{opt_type[i]}"))
			
		} else if(var_type[i] == "hash") {
			
			perl_code = c(perl_code, qq("my %opt_@{i};    # var_type = hash, opt_type = @{opt_type[i]}"))
			
		} else {
		
			perl_code = c(perl_code, qq("my $opt_@{i};    # var_type = scalar, opt_type = @{opt_type[i]}"))
			
		}
	}
	
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("GetOptions("))
	
	for (i in seq_len(nrow(spec))) {
		perl_code = perl_code = c(perl_code, qq("    '@{spec[i, 1]}' => \\@{perl_sigil(var_type[i])}opt_@{i},"))
	}
	
	perl_code = c(perl_code, qq(") or die (\"Error in command line argument.\\n\");"))

	
	perl_code = c(perl_code, qq(""))
	
	# if var_type == integer or numberic, value should be forced ensured
	for (i in seq_len(nrow(spec))) {
		if(opt_type[i] %in% c("integer", "numeric")) {
			
			if(var_type[i] == "scalar") {
				perl_code = c(perl_code, qq("if(defined(@{perl_sigil(var_type[i])}opt_@{i})) {"))
				perl_code = c(perl_code, qq("    $opt_@{i} += 0;"))
			} else if(var_type[i] == "array") {
				perl_code = c(perl_code, qq("if(@opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (@opt_@{i}) { $_ += 0; }"))
			} else if(var_type[i] == "hash") {
				perl_code = c(perl_code, qq("if(%opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (keys %opt_@{i}) { $opt_@{i}{$_} += 0; }"))
			}
			perl_code = c(perl_code, "}")
		}
	}
	perl_code = c(perl_code, qq(""))
	
	perl_code = c(perl_code, qq("my $all_opt = {"))
	

	for (i in seq_len(nrow(spec))) {
	
		if(opt_type[i] == "logical") {
		
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => $opt_@{i} ? JSON::true : JSON::false,"))

		} else if(var_type[i] == "scalar") {
			
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => $opt_@{i},"))

		} else {
		
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => scalar(@{perl_sigil(var_type[i])}opt_@{i}) ? \\@{perl_sigil(var_type[i])}opt_@{i} : undef,"))

		}
	}
	
	perl_code = c(perl_code, qq("};"))
	perl_code = c(perl_code, qq(""))

	perl_code = c(perl_code, qq("open JSON, '>@{json_file}' or die 'Cannot create temp file: @{json_file}';"))
	perl_code = c(perl_code, qq("print JSON to_json($all_opt, {pretty => 1});"))
	perl_code = c(perl_code, qq("close JSON;"))
	perl_code = c(perl_code, qq("print Dumper $all_opt;"))
	writeLines(perl_code, perl_script)
	return(perl_script)
}

perl_sigil = function(type) {
	if(type == "scalar") {
		return("$")
	} else if(type == "array") {
		return("@")
	} else if(type == "hash") {
		return("%")
	} else {
		return("$")
	}
}

print_help_msg = function(spec) {
	
	if(!is.null(options("GetoptLong.startingMsg")[[1]])) {
		cat(options("GetoptLong.startingMsg")[[1]])
	}
	
	for(i in seq_len(nrow(spec))) {
		print_single_option(spec[i, 1], spec[i, 2])
	}
	
	if(!is.null(options("GetoptLong.endingMsg")[[1]])) {
		cat(options("GetoptLong.endingMsg")[[1]])
	}
}

print_single_option = function(opt, desc) {
	var_type = detect_var_type(opt)
	opt_type = detect_opt_type(opt)
	
	opt = gsub("[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	opt = gsub("[=:][siof]$", "", opt)
	opt = gsub("[!+]$", "", opt)
	
	choices = strsplit(opt, "\\|")[[1]]
	
	cat("  ")
	for(i in seq_along(choices)) {
		cat(qq("@{ifelse(nchar(choices[i]) == 1, '-', '--')}@{choices[i]}@{ifelse(i == length(choices), '', ', ')}"))
	}
	cat(" ")
	if(var_type == "scalar" && opt_type == "extended_integer") {
		cat("extended_integer")
	} else if(var_type == "scalar") {
		cat(opt_type)
	} else if(var_type == "array") {
		cat(qq("[ @{opt_type}, ... ]"))
	} else if(var_type == "hash") {
		cat(qq("{ name=@{opt_type}, ... }"))
	}
	
	cat("\n")
	
	cat_format_line(desc, prefix = "    ")

}

print_version_msg = function(envir) {
	cat(get("VERSION", envir = envir))
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
			cat(ifelse(i == 1, "", " "))
			cat(qq("@{words[i]}"))
			i_width = i_width + nchar(prefix)
		}
	}
	cat("\n\n")
}

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
			return("logical")
		} else if (grepl("\\+$", x)) {
			return("integer")
		} else {
			return("logical")
		}
	}, USE.NAMES = FALSE)
}

detect_mandatory = function(opt) {
	opt = gsub("[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	
	grepl("=[siof]$", opt)
}

extract_first_name = function(opt) {
	opt = gsub("[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	opt = gsub("[=:][siof]$", "", opt)
	opt = gsub("[!+]$", "", opt)

	first_name = sapply(strsplit(opt, "\\|"), function(x) x[1])
	return(first_name)
}

export_parent_env = function(opt, envir = parent.frame()) {
	parent_opt_name = ls(envir = envir)
	parent_opt_name = parent_opt_name[ sapply(parent_opt_name, function(x) {
									tmp = get(x, envir = envir)
									mode(tmp) %in% c("numeric", "character")
									}) ]
	
	opt_name = names(opt)
	
	# specified from command line
	specified_opt_name = opt_name[ !sapply(opt, is.null) ]
	# export to global environment
	for(o in specified_opt_name) {
		assign(o, opt[[o]], envir = envir)
	}

	# defined with default values while not specified in command line
	specified_parent_opt_name = intersect(opt_name[ sapply(opt, is.null) ], parent_opt_name)
	# already have, do nothing

	return(invisible(NULL))
	
}
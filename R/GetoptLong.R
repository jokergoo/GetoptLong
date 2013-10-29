# == title
# Wrapper of the Perl module ``Getopt::Long`` in R
#
# == param
# -spec     specification of options. A two-column matrix in which the first column
#           is the setting for option names and the second column is the description
#           of options. It is can also be a vector having even number of elements and it
#           will be converted to the two-column matrix
# -help     whether to add help option
# -version  whether to add version option
# -envir    user's enrivonment where `GetoptLong` will look for default values and export variables
# -argv_str command-line arguments, only for testing purpose
#
# == details
# please see vignette.
GetoptLong = function(spec, help = TRUE, version = TRUE, envir = parent.frame(), argv_str = NULL) {
	
	perl_bin = find_perl_bin()
	if(is.null(argv_str)) {
		STDOUT = stderr()
	} else {
		STDOUT = stdout()
	}
	
	
	if(!check_perl(perl_bin = perl_bin)) {
		stop(qq("Error when testing Perl: @{perl_bin}.\n"))
	}
	
	if(!check_perl("Getopt::Long", perl_bin = perl_bin)) {
		stop("Cannot find Getopt::Long module in your Perl library.\n")
	}
	
	if(!check_perl("JSON", inc = qq("@{system.file('extdata', 'GetoptLong')}/perl_lib"), perl_bin = perl_bin)) {
		stop("Cannot find JSON module in your Perl library.\n")
	}

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
	
	if(any(detect_optional(spec[, 1]))) {
		stop("type :[isfo] is not allowed, use =[isfo] instead.\n")
	}
	
	# add help and version options in `spec`
	if(help) {
		spec = rbind(spec, c("help", "Print help message and exit"))
	}
	if(version) {
		spec = rbind(spec, c("version", "Print version information and exit"))
	}
	
	# get arguments string
	if(is.null(argv_str)) {
		ARGV = commandArgs(TRUE)
		ARGV_string = paste(ARGV, collapse = " ")
	} else {
		ARGV_string = argv_str
	}
	
	# first name in each options
	long_name = extract_first_name(spec[, 1])
	
	
	# test whether first name in option name is a valid R variable name
	test_long_name = grepl("^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$", long_name) 
		
	if(!all(test_long_name)) {
		cat("First name in option names can only be valid R variable names which only use numbers, letters,\n'.' and '_' (It should match /^[a-zA-Z_\\.][a-zA-Z0-9_\\.]+$/).")
		cat(qq(" Following option name@{ifelse(sum(test_long_name)==1, ' is', 's are')}\nnot valid:\n\n"))
		for(k in seq_along(test_long_name)) {
			if(!test_long_name[k]) cat(qq("  @{spec[k, 1]}\n"))
		}
		cat("\n")
			
		if(is.null(argv_str)) {
			q(save = "no")
		} else {
			return(invisible(NULL))
		}
	}
	
	json_file = tempfile(fileext = ".json")
	perl_script = generate_perl_script(spec, json_file)
	
	
	res = run_command(qq("\"@{perl_bin}\" \"@{perl_script}\" @{ARGV_string}"))
	
	# if there is error with execute perl program in which msg is non-zero
	if(res$status) {

		qqcat("@{res$message}\n")

		if(is.null(argv_str)) {
			print_help_msg(spec)
		}

		ow = options("warn")[[1]]
		options(warn = -1)
		file.remove(json_file)
		file.remove(perl_script)
		options(warn = ow)
		
		if(is.null(argv_str)) {
			q(save = "no")
		} else {
			return(invisible(NULL))
		}
	}

	opt = fromJSON(file = json_file)
	file.remove(json_file)
	file.remove(perl_script)
	
	# if detect user has specified --help or --version
	if(!is.null(opt$help) && opt$help) {
		print_help_msg(spec)
		
		if(is.null(argv_str)) {
			q(save = "no")
		} else {
			return(invisible(NULL))
		}
	}
	
	if(!is.null(opt$version) && opt$version) {
		print_version_msg(envir)
		
		if(is.null(argv_str)) {
			q(save = "no", status = 127)
		} else {
			return(invisible(NULL))
		}
	}
	
	# remove `help` and `version` if they exist
	opt = opt[! names(opt) %in% c("help", "version")]
	
	# check mandatory options
	is_mandatory = detect_mandatory(spec[, 1])
	for(i in seq_len(nrow(spec))) {
		if(is.null(opt[[ long_name[i]] ]) && is_mandatory[i] && !exists(long_name[i], envir = envir)) {
			cat(qq("@{long_name[i]} is mandatory, please specify it.\n"))
			if(is.null(argv_str)) {
				print_help_msg(spec)
			}

			if(is.null(argv_str)) {
				q(save = "no", status = 127)
			} else {
				return(invisible(NULL))
			}
		}
	}
	
	for(i in seq_len(nrow(spec))) {
		if(is_mandatory[i] && exists(long_name[i], envir = envir)) {
			tmp = get(long_name[i], envir = envir)
			if(!mode(tmp) %in% c("numeric", "character", "list")) {
				cat(qq("@{long_name[i]} is mandatory, and also detect in envoking environment you have already \ndefined `@{long_name[i]}`. Please make sure `@{long_name[i]}` should only be a simple vector.\n"))
				if(is.null(argv_str)) {
					print_help_msg(spec)
				}

				if(is.null(argv_str)) {
					q(save = "no", status = 127)
				} else {
					return(invisible(NULL))
				}
			}	
		}
	}
	
	# export to envir
	export_parent_env(opt, envir = envir)
	
	return(invisible(opt))
}


generate_perl_script = function(spec, json_file) {
	perl_script = tempfile(fileext = ".pl")
	#perl_script = "tmp.pl"
	
	long_name = extract_first_name(spec[, 1])

	var_type = detect_var_type(spec[, 1])  # which is scalar, array and hash
	opt_type = detect_opt_type(spec[, 1])  # which is integer, numeric, character, ...
	
	# construct perl code
	perl_code = NULL
	perl_code = c(perl_code, qq("#!/usr/bin/perl"))
	perl_code = c(perl_code, qq(""))
	perl_lib = qq("@{system.file('extdata', 'GetoptLong')}/perl_lib")
	perl_code = c(perl_code, qq("BEGIN { push (@INC, '@{perl_lib}'); }"))
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("use strict;"))
	if(is.null(options("GetoptLong.Config")[[1]])) {
		perl_code = c(perl_code, qq("use Getopt::Long;"))
	} else {
		perl_code = c(perl_code, qq("use Getopt::Long qw(:config @{paste(options('GetoptLong.Config')[[1]], collapse = ' ')});"))
	}
	
	perl_code = c(perl_code, qq("use JSON;"))
	perl_code = c(perl_code, qq("use Data::Dumper;"))
	perl_code = c(perl_code, qq(""))
	
	# declare variables according to variable types
	for (i in seq_len(nrow(spec))) {
	
		perl_code = c(perl_code, qq("my @{perl_sigil(var_type[i])}opt_@{i};    # var_type = @{var_type[i]}, opt_type = @{opt_type[i]}"))
		
	}
	
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("eval { GetOptions("))
	
	for (i in seq_len(nrow(spec))) {
		perl_code = perl_code = c(perl_code, qq("    '@{spec[i, 1]}' => \\@{perl_sigil(var_type[i])}opt_@{i},"))
	}
	
	perl_code = c(perl_code, qq(") or die 'Errors when parsing command-line arguments.'; };"))
	
	perl_code = c(perl_code, "")
	perl_code = c(perl_code, "if($@) { exit(123); }")
	
	perl_code = c(perl_code, qq(""))
	
	# if var_type == integer or numberic, value should be forced ensured
	for (i in seq_len(nrow(spec))) {
		if(opt_type[i] %in% c("integer", "numeric")) {
			
			if(var_type[i] == "scalar") {
			
				perl_code = c(perl_code, qq("if(defined(@{perl_sigil(var_type[i])}opt_@{i})) {"))
				perl_code = c(perl_code, qq("    $opt_@{i} += 0;"))
				perl_code = c(perl_code, "}")
				
			} else if(var_type[i] == "array") {
				
				# if array is defined
				perl_code = c(perl_code, qq("if(@opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (@opt_@{i}) { $_ += 0; }"))
				perl_code = c(perl_code, "}")
				
			} else if(var_type[i] == "hash") {
				
				# if hash is defined
				perl_code = c(perl_code, qq("if(%opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (keys %opt_@{i}) { $opt_@{i}{$_} += 0; }"))
				perl_code = c(perl_code, "}")
				
			}
			
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
			
			# in scalar content, empty list will be 0
			perl_code = c(perl_code, qq("    '@{long_name[i]}' => scalar(@{perl_sigil(var_type[i])}opt_@{i}) ? \\@{perl_sigil(var_type[i])}opt_@{i} : undef,"))

		}
	}
	
	perl_code = c(perl_code, qq("};"))
	perl_code = c(perl_code, qq(""))

	perl_code = c(perl_code, qq("open JSON, '>@{json_file}' or die 'Cannot create temp file: @{json_file}\\n';"))
	perl_code = c(perl_code, qq("print JSON to_json($all_opt, {pretty => 1});"))
	perl_code = c(perl_code, qq("close JSON;"))
	#perl_code = c(perl_code, qq("print Dumper $all_opt;"))
	
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
	} else {
        script_name = get_scriptname()
        cat(qq("Usage: Rscript @{script_name} [options]\n\n"))
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
	} else if(var_type == "scalar" && opt_type == "logical") {
		cat("")
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
	if(exists("VERSION", envir = envir)) {
		cat(get("VERSION", envir = envir))
	} else {
		cat("No version information is found in source code.\n")
	}
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

detect_optional = function(opt) {
	opt = gsub("[$@%]$", "", opt)
	opt = gsub("\\{.*\\}$", "", opt)
	
	grepl(":[siof]$", opt)
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
	#parent_opt_name = ls(envir = envir)
	#parent_opt_name = parent_opt_name[ sapply(parent_opt_name, function(x) {
	#								tmp = get(x, envir = envir)
	#								mode(tmp) %in% c("numeric", "character")
	#								}) ]
	
	opt_name = names(opt)
	
	# specified from command line
	specified_opt_name = opt_name[ !sapply(opt, is.null) ]
	# export to global environment
	for(o in specified_opt_name) {
		assign(o, opt[[o]], envir = envir)
	}

	# defined with default values while not specified in command line
	#specified_parent_opt_name = intersect(opt_name[ sapply(opt, is.null) ], parent_opt_name)
	# already have, do nothing

	return(invisible(NULL))
	
}

get_scriptname = function() {
		args = commandArgs()
		if(length(args) == 1) {
			return("foo.R")
		}
		i_arg = which(args == "--args")
		if(length(i_arg) == 0) {
			return("foo.R")
		}
		i_arg = i_arg[1]
		args = args[seq_len(i_arg)]
        f = grep("^--file=", args, value = TRUE)[1]
        f = gsub("^--file=(.*)$", "\\1", f)
        return(basename(f))
}

# find path of binary perl
find_perl_bin = function() {

	# first look at user's options
	args = commandArgs()
	i = which(args == "--")
	if(length(i) && length(args) > i) {
		perl_bin = args[i + 1]
	} else {  # look at PATH
		perl_bin = look_for_file_in_path("perl")
		if(is.null(perl_bin)) {
			stop("cannot find Perl in PATH.\n")
		}
	}
	
	if(!file.exists(perl_bin)) {
		stop(qq("Cannot find @{perl_bin}\n"))
	}
	
	OS = Sys.info()["sysname"]
	if(is.dir(perl_bin)) {
		if(OS == "Windows") {
			perl_bin = qq("@{perl_bin}\\perl.exe")
		} else {
			perl_bin = qq("@{perl_bin}/perl")
		}
		if(!file.exists(perl_bin)) {
			stop(qq("Cannot find @{perl_bin}\n"))
		}
	}
	
	return(perl_bin)
}

# check whether perl can be called
# check whether perl has certain module
check_perl = function(module = NULL, inc = NULL, perl_bin = "perl") {
	
	if(is.null(module)) {
		cmd = qq("\"@{perl_bin}\" -v")
	} else if(!is.null(module) && is.null(inc)) {
		cmd = qq("\"@{perl_bin}\" -M@{module} -e \"use @{module}\"")
	} else if(!is.null(module) && !is.null(inc)) {
		cmd = qq("\"@{perl_bin}\" \"-I@{inc}\" -M@{module} -e \"use @{module}\"")
	}
	
	res = run_command(cmd)
	return(ifelse(res$status, FALSE, TRUE))
}

look_for_file_in_path = function(file) {

	OS = Sys.info()["sysname"]
	if(OS == "Windows") {
		dir = strsplit(Sys.getenv("PATH"), ";")[[1]]
	} else {
		dir = strsplit(Sys.getenv("PATH"), ":")[[1]]
	}
	
	for(d in dir) {
		if(OS == "Windows" && file.exists(qq("@{d}\\@{file}.exe"))) {
			return(qq("@{d}\\@{file}.exe"))
		} else if(file.exists(qq("@{d}/@{file}"))) {
			return(qq("@{d}/@{file}"))
		}
	}
	return(NULL)
}

is.dir = function(dir) {
	sapply(dir, function(x) file.exists(x) && file.info(x)[1, "isdir"])
}

# wrapper of `base::system`
#
# == param
# -command command
#
# == details
# It will return a list with two elements:
#
# -status status of the command
#
# This function is platform independent.
#
# Assume binary file exists.
#
# I cannot capture error when binary file cannot be found
#
run_command = function(command) {
	OS = Sys.info()["sysname"]

	command = qq("@{command} 2>&1")

	# supress warnings
	ow = options("warn")[[1]]
	options(warn = -1)
	if(OS == "Windows") {
		res = try(system(command, show.output.on.console = FALSE, intern = TRUE), silent = TRUE)
	} else {
		res = try(system(command, intern = TRUE), silent = TRUE)
	}
	options(warn = ow)
	
	if(is.null(attributes(res))) {
		return(list(status = 0, message = res))
	} else {
		return(list(status = ifelse(is.null(attributes(res)$status), 127, attributes(res)$status), message = as.vector(res)))
	}
}

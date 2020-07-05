

generate_perl_script = function(opt_lt, json_file) {

	perl_script = tempfile(fileext = ".pl")
	#perl_script = "tmp.pl"
	
	# construct perl code
	perl_code = NULL
	perl_code = c(perl_code, qq("#!/usr/bin/perl"))
	perl_code = c(perl_code, qq(""))
	perl_lib = qq("@{system.file('extdata', package='GetoptLong')}/perl_lib")
	perl_code = c(perl_code, qq("BEGIN { push (@INC, '@{perl_lib}'); }"))
	perl_code = c(perl_code, qq(""))
	perl_code = c(perl_code, qq("use strict;"))
	
	config = NULL
	if(!is.null(options("GetoptLong.Config")[[1]]) && is.null(GetoptLong.options("config"))) {
		config = options("GetoptLong.Config")[[1]]
	} else {
		config = GetoptLong.options("config")
	}
	if(is.null(config)) {
		perl_code = c(perl_code, qq("use Getopt::Long;"))
	} else {
		perl_code = c(perl_code, qq("use Getopt::Long qw(:config @{paste(config, collapse = ' ')});"))
	}
	
	perl_code = c(perl_code, qq("use JSON;"))
	perl_code = c(perl_code, qq("use Data::Dumper;"))
	perl_code = c(perl_code, qq(""))

	n = length(opt_lt)

	# declare variables according to variable types
	for (i in seq_len(n)) {
		opt = opt_lt[[i]]
		perl_code = c(perl_code, qq("my @{perl_sigil(opt$var_type)}opt_@{i};"))
		
		if(opt$var_type == "negatable_logical") {
			perl_code = c(perl_code, qq("@{perl_sigil(opt$var_type)}opt_@{i} = @{opt$opt_default + 0};"))
		}
	}
	
	perl_code = c(perl_code, qq("*STDERR = *STDOUT;")) # all write to STDOUT
	perl_code = c(perl_code, qq("my $is_successful = GetOptions("))
	
	for (i in seq_len(n)) {
		opt = opt_lt[[i]]
		perl_code = c(perl_code, qq("    '@{opt$spec}' => \\@{perl_sigil(opt$var_type)}opt_@{i},"))
	}
	perl_code = c(perl_code, qq(");"))
	
	perl_code = c(perl_code, qq("if(!$is_successful) {"))
	perl_code = c(perl_code, qq("    exit;"))
	perl_code = c(perl_code, qq("}"))
	
	# if var_type == integer or numberic, value should be forced ensured
	for(i in seq_len(n)) {
		opt = opt_lt[[i]]
		if(opt$opt_type %in% c("integer", "numeric")) {
			
			if(opt$var_type == "scalar") {
			
				perl_code = c(perl_code, qq("if(defined(@{perl_sigil(opt$var_type)}opt_@{i})) {"))
				perl_code = c(perl_code, qq("    $opt_@{i} += 0;"))
				perl_code = c(perl_code, "}")
				
			} else if(opt$var_type == "array") {
				
				# if array is defined
				perl_code = c(perl_code, qq("if(@opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (@opt_@{i}) { $_ += 0; }"))
				perl_code = c(perl_code, "}")
				
			} else if(opt$var_type == "hash") {
				
				# if hash is defined
				perl_code = c(perl_code, qq("if(%opt_@{i}) {"))
				perl_code = c(perl_code, qq("    foreach (keys %opt_@{i}) { $opt_@{i}{$_} += 0; }"))
				perl_code = c(perl_code, "}")
				
			}
			
		}
	}
	perl_code = c(perl_code, qq(""))
	
	perl_code = c(perl_code, qq("my $all_opt = {"))
	
	for (i in seq_len(n)) {
		opt = opt_lt[[i]]
	
		if(opt$opt_type == "logical") {
		
			perl_code = c(perl_code, qq("    '@{opt$name}' => $opt_@{i} ? JSON::true : JSON::false,"))

		} else if(opt$opt_type == "negatable_logical") {
		
			perl_code = c(perl_code, qq("    '@{opt$name}' => $opt_@{i} ? JSON::true : JSON::false,"))

		} else if(opt$var_type == "scalar") {
			
			perl_code = c(perl_code, qq("    '@{opt$name}' => $opt_@{i},"))

		} else {
			
			# in scalar content, empty list will be 0
			perl_code = c(perl_code, qq("    '@{opt$name}' => scalar(@{perl_sigil(opt$var_type)}opt_@{i}) ? \\@{perl_sigil(opt$var_type)}opt_@{i} : undef,"))

		}
	}
	
	perl_code = c(perl_code, qq("};"))
	perl_code = c(perl_code, qq(""))

	perl_code = c(perl_code, qq("open JSON, '>@{json_file}' or die 'Cannot create temp file: @{json_file}\\n';"))
	perl_code = c(perl_code, qq("print JSON to_json($all_opt, {pretty => 1});"))
	perl_code = c(perl_code, qq("close JSON;"))
	# perl_code = c(perl_code, qq("print STDERR Dumper $all_opt;"))

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


# find path of binary perl
find_perl_bin = function(con = stderr(), from_command_line = TRUE) {

	# first look at user's options
	args = commandArgs()
	i = which(args == "--")
	if(length(i) && length(args) > i) {
		perl_bin = args[i + 1]
		
		if(!file.exists(perl_bin)) {
			cat(red(qq("Cannot find @{perl_bin}\n")), file = con)
			if(from_command_line) {
				q(save = "no", status = 127)
			} else {
				return(invisible(NULL))
			}
		}
		
		if(file.info(perl_bin)$isdir) {
			cat(red(qq("@{perl_bin} should be a file, not a directory.\n")), file = con)
			if(from_command_line) {
				q(save = "no", status = 127)
			} else {
				return(invisible(NULL))
			}
		}
		
	} else {  # look at PATH
		perl_bin = Sys.which("perl")
		if(perl_bin == "") {
			cat(red("Cannot find Perl in PATH.\n"), file = con)
			if(from_command_line) {
				q(save = "no", status = 127)
			} else {
				return(invisible(NULL))
			}
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
	
	OS = Sys.info()["sysname"]
	if(OS == "Windows") {
		res = system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE, show.output.on.console = FALSE)
	} else {
		res = system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
	}

	return(ifelse(res, FALSE, TRUE))
}


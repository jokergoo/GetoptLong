# == title
# Simple variable interpolation in texts
#
# == param
# -text         text string in which variables are marked with certain rules
# -envir          environment where to find those variables. By default it is the environment
#               where `qq` is envoked. It can also be a list in which list element names are
#               the variable names going to be interpolated.
# -code.pattern pattern of marks for the variables. By default it is ``@\\\\{CODE\\\\}`` which means
#               you can write your variable as ``@{variable}``.
#
# == details
# I like variable interpolation in Perl. But in R, if you want to concatenate plain text and variables,
# you need to use functions such as `base::paste`. However, if there are so many variables, quotes, braces 
# in the string you want to construct, it would kill you.
#   
# This function allows you to construct strings as in Perl style. Variables are
# marked in the text with certain rule. `qq` will look up these variables in user's
# environment and replace the variable marks with their real values.
#
# For more explaination of this function, please refer to vignette, "text interpolation" section.
#
# == value
# A single text
qq = function(text, envir = parent.frame(), code.pattern = NULL) {
	
	if(is.null(code.pattern)) {
		if(is.null(options("code.pattern")[[1]])) {
			code.pattern = "@\\{CODE\\}"
		} else {
			code.pattern = options("code.pattern")
		}
	}
	
    if(length(text) != 1) {
        stop("Now only support text with length of 1.\n")
    }
	
    if(!is.null(envir)) {
		if(is.environment(envir)) {
			e = envir
		} else {
			e = as.environment(envir)
		}
    } else {
        e = .GlobalEnv
    }
	
    for (i in 1:length(text)) {
 
        # check wether there are code replacements
        fc = find_code(code.pattern, text[i])
        template = fc[[1]]
        code = fc[[2]]
 
        if(length(template)) {   # if there is code replacement
           
            # replace the code with its value
            return_value = lapply(code, function(c) eval(parse(text = c), envir = e))  # anony function is the first level parent
			
			is_return_value_vector = sapply(return_value, function(r) is.vector(r) & !is.list(r))
			if(! all(is_return_value_vector)) {
				stop("All your codes should only return simple vectors.\n")
			}
			
            # length of the return value
            # need to test it since not all code returns a scalar
            return_value_length = sapply(return_value, function(x) length(x))
 
            if(max(return_value_length) > 1) {
            # if some piece of codes return a vector
            # recycle to `max(return_value_length)`
                current = rep(text[i], max(return_value_length))
                
                for(ai in 1:max(return_value_length)) {
                    for(iv in 1:length(template)) {
                        current[ai] = gsub(template[iv],
                                           return_value[[iv]][(ai-1) %% length(return_value[[iv]]) + 1],
                                           current[ai], fixed = TRUE)
                    }
                }
                
                text[i] = paste(current, collapse = "")
                
            } else if(max(return_value_length == 1)) {   # all variable returns a scalar
            
                current = text[i]
                
                for(iv in 1:length(template)) {
                    current = gsub(template[iv], return_value[[iv]], current, fixed = TRUE)
                }
                
                text[i] = current
                
            }
        }
    }
 
	return(text)
}
 
find_code = function(m, text) {
 
    if(length(text) != 1) {
        stop("text must be length of 1.")
    }
 
    m2 = gsub("CODE", ".+?", m)
 
    reg = gregexpr(m2, text)[[1]]
    v1 = character(0)
    if(reg[1] > -1) {
        v1 = sapply(1:length(reg), function(i) substr(text, as.numeric(reg)[i], as.numeric(reg)[i]+ attr(reg, "match.length")[i] - 1))
    }
    edge = strsplit(m, "CODE")[[1]]
    v2 = gsub(paste("^", edge[1], "|", edge[2], "$", sep=""), "", v1)
    
    return(list(template=v1, code=v2))
}


# == title
# Print a string which has been intepolated with variables
#
# == param
# -text         text string in which variables are marked with certain rules
# -envir          environment where to find those variables
# -code.pattern pattern of marks for the variables
#
# == details
# This function is a shortcut of
#
#     cat(qq(text, envir, code.pattern))
#
# Please refer to `qq` to find more details.
qqcat = function(text, envir = parent.frame(), code.pattern = NULL) {
	cat(qq(text, envir, code.pattern))
}

context("Test `GetoptLong`")

test_that("test simple", {
	GetoptLong("tag=i", "tag", argv_str = "--tag 1");         expect_that(tag, equals(1)); rm(tag)
	GetoptLong("tag=i", "tag", argv_str = "--tag=1");         expect_that(tag, equals(1)); rm(tag)
})

test_that("test `tag=i`", {
	spec = c(
		"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	)
	GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals(1)); rm(tag)
	tag = 2; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(2)); rm(tag)
	tag = 2; GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals(1)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 --tag 2"); expect_that(tag, equals(2)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),     prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = ""),          prints_text("mandatory"))

	tag = NA; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NA)); rm(tag)
	tag = NULL; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NULL)); rm(tag)
	tag = NA; GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals(1)); rm(tag)
})

test_that("test `len|size=i`", {
	spec = c(
		"len|size=i", "length"
	)
	GetoptLong(spec, argv_str = "--len 1");      expect_that(len, equals(1)); rm(len)
	GetoptLong(spec, argv_str = "--size 1");     expect_that(len, equals(1)); rm(len)
	GetoptLong(spec, argv_str = "-l 1");         expect_that(len, equals(1)); rm(len)
	GetoptLong(spec, argv_str = "-s 1");         expect_that(len, equals(1)); rm(len)
	expect_that(GetoptLong(spec, argv_str = ""), prints_text("mandatory"))
})

# option name is a built-in function
test_that("test `length=i`", {
	spec = c(
		"length|size=i", "length"
	)
	length = function() {}
	GetoptLong(spec, argv_str = "--length 1");   expect_that(length, equals(1)); rm(length)
	expect_that(GetoptLong(spec, argv_str = ""), prints_text("mandatory"))
})

test_that("test `tag=s`", {
	spec = c(
		"tag=s", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, is_identical_to("1"));   rm(tag)
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, is_identical_to("0.1")); rm(tag)
	GetoptLong(spec, argv_str = "--tag a");   expect_that(tag, is_identical_to("a"));   rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag"), prints_text("requires"))

	tag = NA; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NA)); rm(tag)
	tag = NULL; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NULL)); rm(tag)
	tag = NA; GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals("1")); rm(tag)
})

test_that("test `tag=f`", {
	spec = c(
		"tag=f", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, equals(1));   rm(tag)
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, equals(0.1)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag a"),  prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),    prints_text("requires"))

	tag = NA; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NA)); rm(tag)
	tag = NULL; GetoptLong(spec, argv_str = "");         expect_that(tag, equals(NULL)); rm(tag)
	tag = NA; GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals(1)); rm(tag)
})

test_that("test `tag=o`", {
	spec = c(
		"tag=o", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");    expect_that(tag, equals(1));  rm(tag)
	GetoptLong(spec, argv_str = "--tag 0b11"); expect_that(tag, equals(3));  rm(tag)
	GetoptLong(spec, argv_str = "--tag 011");  expect_that(tag, equals(9));  rm(tag)
	GetoptLong(spec, argv_str = "--tag 0x1f"); expect_that(tag, equals(31)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),     prints_text("requires"))
})

test_that("test `tag`", {
	spec = c(
		"tag", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, is_identical_to(TRUE)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 0");   expect_that(tag, is_identical_to(TRUE)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, is_identical_to(TRUE)); rm(tag)
	GetoptLong(spec, argv_str = "--tag a");   expect_that(tag, is_identical_to(TRUE)); rm(tag)
	GetoptLong(spec, argv_str = "--tag");     expect_that(tag, is_identical_to(TRUE)); rm(tag)
	GetoptLong(spec, argv_str = "");          expect_that(tag, is_identical_to(FALSE)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--no-tag"), prints_text("Unknown"))

	tag = FALSE
	GetoptLong(spec, argv_str = ""); expect_that(tag, equals(FALSE)); rm(tag)
	tag = FALSE
	GetoptLong(spec, argv_str = "--tag"); expect_that(tag, equals(TRUE)); rm(tag)
	tag = TRUE
	GetoptLong(spec, argv_str = ""); expect_that(tag, equals(FALSE)); rm(tag)

})

test_that("test `verbose!`", {
	spec = c(
		"verbose!", "print messages"
	)
	GetoptLong(spec, argv_str = "--verbose");    expect_that(verbose, is_identical_to(TRUE)); rm(verbose)
	GetoptLong(spec, argv_str = "--no-verbose"); expect_that(verbose, is_identical_to(FALSE)); rm(verbose)
	GetoptLong(spec, argv_str = "--noverbose"); expect_that(verbose, is_identical_to(FALSE)); rm(verbose)

	verbose = FALSE
	GetoptLong(spec, argv_str = ""); expect_that(verbose, equals(FALSE)); rm(verbose)
	verbose = TRUE
	GetoptLong(spec, argv_str = ""); expect_that(verbose, equals(TRUE)); rm(verbose)
	verbose = TRUE
	GetoptLong(spec, argv_str = "--verbose"); expect_that(verbose, equals(TRUE)); rm(verbose)
	verbose = FALSE
	GetoptLong(spec, argv_str = "--verbose"); expect_that(verbose, equals(TRUE)); rm(verbose)
	verbose = TRUE
	GetoptLong(spec, argv_str = "--no-verbose"); expect_that(verbose, equals(FALSE)); rm(verbose)

	GetoptLong(spec, argv_str = ""); expect_that(verbose, equals(FALSE)); rm(verbose)
})


test_that("test `tag=i@`", {
	spec = c(
		"tag=i@", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, is_identical_to(1));   rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 --tag 2"); expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--t 1 --t 2"); expect_that(tag, equals(1:2)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 1 --tag a"), prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"),       prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),         prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),           prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = ""),                prints_text("mandatory"))

	tag = "a"
	expect_error(GetoptLong(spec, argv_str = "--tag 1"), "number"); rm(tag)

	GetoptLong(spec, argv_str = "--tag 1 2"); expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--t 1 2"); expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--tag=1 --tag=2"); expect_that(tag, equals(1:2)); rm(tag)
	
	spec = c(
		"foo|bar=i@", "desc"
	)
	GetoptLong(spec, argv_str = "--foo=1 --bar=2"); expect_that(foo, equals(1:2)); rm(foo);
	GetoptLong(spec, argv_str = "--foo 1 --bar 2"); expect_that(foo, equals(1:2)); rm(foo);
	GetoptLong(spec, argv_str = "--bar 1 2"); expect_that(foo, equals(1:2)); rm(foo);
	
})

test_that("test `tag=i%`", {
	spec = c(
		"tag=i%", "desc"
	)
	GetoptLong(spec, argv_str = "--tag name=1"); expect_that(tag, is_identical_to(list(name = 1))); rm(tag)
	GetoptLong(spec, argv_str = "--tag name=1 value=2");tag = tag[sort(names(tag))]; expect_that(tag, is_identical_to(list(name = 1, value = 2))); rm(tag)
	GetoptLong(spec, argv_str = "--tag name=1 --tag value=2"); tag = tag[sort(names(tag))]; expect_that(tag, is_identical_to(list(name = 1, value = 2))); rm(tag)
	GetoptLong(spec, argv_str = "--tag name=1 --tag name=2"); expect_that(tag, is_identical_to(list(name = 2))); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 1"),   prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),     prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = ""),          prints_text("mandatory"))
	
	expect_error({tag = 1;GetoptLong(spec, argv_str = "--tag name=1")}, "should be a list");rm(tag)
	expect_error({tag = list(name = list(1));GetoptLong(spec, argv_str = "--tag name=1")}, "atomic"); rm(tag)
	expect_error({tag = list(1);GetoptLong(spec, argv_str = "--tag name=1")}, "should be a named list"); rm(tag)
	expect_error({tag = list(name = "a");GetoptLong(spec, argv_str = "--tag name=1")}, "number"); rm(tag)	
	expect_that({tag = list(name = 1);GetoptLong(spec, argv_str = "--tag name=s")}, prints_text("number expected")); rm(tag)	

	tag = list(name = 2)
	GetoptLong(spec, argv_str = ""); expect_that(tag, is_identical_to(list(name = 2))); rm(tag)
	tag = list(name = 2)
	GetoptLong(spec, argv_str = "--tag name=1"); expect_that(tag, is_identical_to(list(name = 1))); rm(tag)

	tag = list(name = 2, eman = 3)
	GetoptLong(spec, argv_str = "--tag name=1"); expect_that(tag, is_identical_to(list(name = 1, eman = 3))); rm(tag)
	tag = list(name = 2, eman = 3)
	GetoptLong(spec, argv_str = "--tag name=1 --tag eman=2 --tag sth=4"); 
	expect_that(tag$name, is_identical_to(1))
	expect_that(tag$eman, is_identical_to(2))
	expect_that(tag$sth, is_identical_to(4))
	rm(tag)

})

test_that("test `tag=i{2}`", {
	spec = c(
		"tag=i{2}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1 2"); expect_that(tag, equals(1:2)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 1"),   prints_text("Insufficient"))
	expect_that(GetoptLong(spec, argv_str = "--tag 1 --tag 2"),   prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   prints_text("invalid"))
	expect_that(GetoptLong(spec, argv_str = "--tag"),     prints_text("requires"))
	expect_that(GetoptLong(spec, argv_str = ""),          prints_text("mandatory"))
})

test_that("test `tag=i{2,3}`", {
	spec = c(
		"tag=i{2,3}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1 2");   expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3"); expect_that(tag, equals(1:3)); rm(tag)
	expect_that(GetoptLong(spec, argv_str = "--tag 1"), prints_text("Insufficient"))
	GetoptLong(spec, argv_str = "--tag 1 2 3"); expect_that(tag, equals(1:3)); rm(tag)
})

test_that("test `tag=i{2,}`", {
	spec = c(
		"tag=i{2,}", "desc"
	)
	expect_that(GetoptLong(spec, argv_str = "--tag 1"), prints_text("Insufficient"))
	GetoptLong(spec, argv_str = "--tag 1 2");     expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3");   expect_that(tag, equals(1:3)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3 4"); expect_that(tag, equals(1:4)); rm(tag)
})

test_that("test `tag=i{,3}`", {
	spec = c(
		"tag=i{,3}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");       expect_that(tag, equals(1));   rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2");     expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3");   expect_that(tag, equals(1:3)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3 4"); expect_that(tag, equals(1:3)); rm(tag)
})

test_that("test `tag=i{,}`", {
	spec = c(
		"tag=i{,}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");       expect_that(tag, equals(1));   rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2");     expect_that(tag, equals(1:2)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3");   expect_that(tag, equals(1:3)); rm(tag)
	GetoptLong(spec, argv_str = "--tag 1 2 3 4"); expect_that(tag, equals(1:4)); rm(tag)
})

test_that("test other configurations", {
	GetoptLong.options("config" = "bundling")
	spec = c(
		"red|r", "using red",
		"blue|b", "using blue",
		"yellow|y", "using yellow"
	)
	GetoptLong(spec, argv_str = "--red --blue --yellow")
	expect_that(red,    is_identical_to(TRUE)); rm(red)
	expect_that(blue,   is_identical_to(TRUE)); rm(blue)
	expect_that(yellow, is_identical_to(TRUE)); rm(yellow)
	GetoptLong(spec, argv_str = "-rby")
	expect_that(red,    is_identical_to(TRUE)); rm(red)
	expect_that(blue,   is_identical_to(TRUE)); rm(blue)
	expect_that(yellow, is_identical_to(TRUE)); rm(yellow)
})

# with default value
test_that("test default values", {
	spec = c(
		"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	)
	tag = 4
	GetoptLong(spec, argv_str = "--tag 1");  expect_that(tag, equals(1)); rm(tag)
	tag = 4
	GetoptLong(spec, argv_str = "");         expect_that(tag, equals(4)); rm(tag)
})

# message

GetoptLong.options(RESET = TRUE)

test_that("test `version` and `help` options", {

	spec = c(
		"verbose!", "print messages"
	)
	VERSION = "0.0.1"
	expect_that(GetoptLong(spec, argv_str = "--version"), prints_text("0.0.1"))
	rm(VERSION)
	expect_that(GetoptLong(spec, argv_str = "--version"), prints_text("No version information is found in the script"))
	
	expect_that(GetoptLong(spec, argv_str = "--help"), prints_text("Usage"))

	expect_that(GetoptLong(spec, argv_str = "--help", help_head = "test"), prints_text("test"))
	expect_that(GetoptLong(spec, argv_str = "--help", help_foot = "test"), prints_text("test"))

	VERSION = numeric_version("1.1-1")
	expect_that(GetoptLong(spec, argv_str = "--version"), prints_text("1.1.1"))
})

perl_bin = Sys.which("perl")
test_that(qq("--tag 1 -- @{perl_bin}"), {
	spec = c(
		"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	)
	GetoptLong(spec, argv_str = qq("--tag 1 -- @{perl_bin}")); expect_that(tag, equals(1)); rm(tag)
})

test_that("no default value under interactive session", {
	spec = c(
		"tag=i", "tag"
	)
	expect_error(GetoptLong(spec))
})

text = "
Usage: Rscript foo.R [options]

Options:
  <verbose!> print messages
  <foo=i> foo
  <bar=s@> bar
"

test_that("test template", {
	expect_that(GetoptLong(text, argv_str = "--help"), prints_text("--foo"))
})

test_that("test sub options", {
	expect_that(GetoptLong(
		"tag=i%", "a hash",
		"tag$name1", "name 1",
		"tag$name2", "name 2",
		"foo=s%", "a second hash",
		"foo$name3", "name 3",
		"foo$name4", "name 4",

		argv_str = "--help"
	), prints_text("name1"))
})



test_that("test grouped options", {
	expect_that(GetoptLong(    
		"-------", "Group1 options:",
	    "number=i", "Number of items.",

	    "-------", "Group2 options:",
	    "cutoff=f", "Cutoff for filtering results.",

	    "-------", "Group3 options:",
	    "verbose",  "Print message.",

    	argv_str = "--help"
    ), prints_text("Group1"))
})


test_that("test `multi-word option`", {
	spec = c(
		"foo_bar=i", "desc"
	)
	GetoptLong(spec, argv_str = "--foo_bar 1");       expect_that(foo_bar, equals(1));   rm(foo_bar)
	GetoptLong(spec, argv_str = "--foo-bar 1");       expect_that(foo_bar, equals(1));   rm(foo_bar)

	spec = c(
		"foo_bar!", "desc"
	)
	GetoptLong(spec, argv_str = "--foo-bar");       expect_that(foo_bar, equals(TRUE));   rm(foo_bar)
	GetoptLong(spec, argv_str = "--foo_bar");       expect_that(foo_bar, equals(TRUE));   rm(foo_bar)
	GetoptLong(spec, argv_str = "--no-foo-bar");     expect_that(foo_bar, equals(FALSE));   rm(foo_bar)
	GetoptLong(spec, argv_str = "--no-foo_bar");     expect_that(foo_bar, equals(FALSE));   rm(foo_bar)

	spec = c(
		"no_foo=i", "desc"
	)
	GetoptLong(spec, argv_str = "--no-foo 1");       expect_that(no_foo, equals(1));   rm(no_foo)
	GetoptLong(spec, argv_str = "--no_foo 1");       expect_that(no_foo, equals(1));   rm(no_foo)

})

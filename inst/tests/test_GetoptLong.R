context("Test `GetoptLong`")

options("GetoptLong.startingMsg" = "
Usage:
  Rscript xx.R --tag
Description of this script

")

options("GetoptLong.endingMsg" = "
Report bugs to xxx@xx.xx
")

VERSION = "0.0.1"

test_that("test `tag=i`", {
	spec = c(
		"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	)
	GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "--tag 1 --tag 2"); expect_that(tag, equals(2))
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),     throws_error())
	expect_that(GetoptLong(spec, argv_str = ""),          throws_error())
})

test_that("test `tag=s`", {
	spec = c(
		"tag=s", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, is_identical_to("1"))
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, is_identical_to("0.1"))
	GetoptLong(spec, argv_str = "--tag a");   expect_that(tag, is_identical_to("a"))
	GetoptLong(spec, argv_str = "--tag");     expect_that(tag, is_identical_to(""))
})

test_that("test `tag=f`", {
	spec = c(
		"tag=f", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, equals(0.1))
	expect_that(GetoptLong(spec, argv_str = "--tag a"),  throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),  throws_error())
})

test_that("test `tag=o`", {
	spec = c(
		"tag=o", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");        expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "--tag 0b001001"); expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "--tag 0721");     expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "--tag 0xaf2");    expect_that(tag, equals(1))
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),     throws_error())
})

test_that("test `tag`", {
	spec = c(
		"tag", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");   expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "--tag 0");   expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "--tag 0.1"); expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "--tag a");   expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "--tag");     expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "");          expect_that(tag, is_identical_to(FALSE))
})

test_that("test `tag=i@`", {
	spec = c(
		"tag=i@", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");         expect_that(tag, is_identical_to(1))
	GetoptLong(spec, argv_str = "--tag 1 --tag 2"); expect_that(tag, is_identical_to(1:2))
	expect_that(GetoptLong(spec, argv_str = "--tag 1 --tag a"), throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"),       throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag a"),         throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),           throws_error())
	expect_that(GetoptLong(spec, argv_str = ""),                throws_error())
})

test_that("test `tag=i%`", {
	spec = c(
		"tag=i%", "desc"
	)
	GetoptLong(spec, argv_str = "--tag name=1"); expect_that(tag, is_identical_to(c(name = 1)))
	expect_that(GetoptLong(spec, argv_str = "--tag 1"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),     throws_error())
	expect_that(GetoptLong(spec, argv_str = ""),          throws_error())
})

test_that("test `tag=i{2}`", {
	spec = c(
		"tag=i{2}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1 2"); expect_that(tag, is_identical_to(1:2))
	expect_that(GetoptLong(spec, argv_str = "--tag 1"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag 0.1"), throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag a"),   throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag"),     throws_error())
	expect_that(GetoptLong(spec, argv_str = ""),          throws_error())
})

test_that("test `tag=i{2,3}`", {
	spec = c(
		"tag=i{2,3}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1 2");   expect_that(tag, is_identical_to(1:2))
	GetoptLong(spec, argv_str = "--tag 1 2 3"); expect_that(tag, is_identical_to(1:3))
	expect_that(GetoptLong(spec, argv_str = "--tag 1"),       throws_error())
	expect_that(GetoptLong(spec, argv_str = "--tag 1 2 3 4"), throws_error())
})

test_that("test `tag=i{2,}`", {
	spec = c(
		"tag=i{2,}", "desc"
	)
	expect_that(GetoptLong(spec, argv_str = "--tag 1"), throws_error())
	GetoptLong(spec, argv_str = "--tag 1 2");     expect_that(tag, is_identical_to(1:2))
	GetoptLong(spec, argv_str = "--tag 1 2 3");   expect_that(tag, is_identical_to(1:3))
	GetoptLong(spec, argv_str = "--tag 1 2 3 4"); expect_that(tag, is_identical_to(1:4))
})

test_that("test `tag=i{,3}`", {
	spec = c(
		"tag=i{,3}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");     expect_that(tag, is_identical_to(1))
	GetoptLong(spec, argv_str = "--tag 1 2");   expect_that(tag, is_identical_to(1:2))
	GetoptLong(spec, argv_str = "--tag 1 2 3"); expect_that(tag, is_identical_to(1:3))
	expect_that(GetoptLong(spec, argv_str = "--tag 1 2 3 4"), throws_error())
})

test_that("test `tag=i{,}`", {
	spec = c(
		"tag=i{,}", "desc"
	)
	GetoptLong(spec, argv_str = "--tag 1");       expect_that(tag, is_identical_to(1))
	GetoptLong(spec, argv_str = "--tag 1 2");     expect_that(tag, is_identical_to(1:2))
	GetoptLong(spec, argv_str = "--tag 1 2 3");   expect_that(tag, is_identical_to(1:3))
	GetoptLong(spec, argv_str = "--tag 1 2 3 4"); expect_that(tag, is_identical_to(1:4))
})

test_that("test `verbose!`", {
	spec = c(
		"verbose!", "print messages"
	)
	GetoptLong(spec, argv_str = "--verbose");    expect_that(tag, is_identical_to(TRUE))
	GetoptLong(spec, argv_str = "--no-verbose"); expect_that(tag, is_identical_to(FALSE))
}

test_that("test other configurations", {
	options("GetoptLong.Config" = "bundling")
	spec = c(
		"red|r", "using red",
		"blue|b", "using blue",
		"yellow|y", "using yellow"
	)
	GetoptLong(spec, argv_str = "--red --blue --yellow")
	expect_that(red, is_identical_to(TRUE))
	expect_that(blue, is_identical_to(TRUE))
	expect_that(yellow, is_identical_to(TRUE))
})

# with default value
test_that("test default values", {
	spec = c(
		"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	)
	tag = 4
	GetoptLong(spec, argv_str = "--tag 1");  expect_that(tag, equals(1))
	GetoptLong(spec, argv_str = "");         expect_that(tag, equals(4))
})

# message
test_that("test `version` and `help` options", {
	expect_that(GetoptLong(spec, argc_str = "--version"), print_text())
	rm(VERSION)
	expect_that(GetoptLong(spec, argc_str = "--version"), print_text())
	expect_that(GetoptLong(spec, argc_str = "--version", version = FALSE), throws_error())

	expect_that(GetoptLong(spec, argc_str = "--help"), print_text())
	expect_that(GetoptLong(spec, argc_str = "--help", version = FALSE), throws_error())
})

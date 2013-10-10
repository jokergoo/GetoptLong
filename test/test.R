source("../R/qq.R")
source("../R/GetoptLong.R")


options("GetoptLong.startingMsg" = "
Usage:
  Rscript xx.R --tag
Description of this script

")

options("GetoptLong.endingMsg" = "
Report bugs to xxx@xx.xx
")

VERSION = "0.0.1"

spec = matrix(c(
	"tag=i", "this is a description of tag which is long long and very long and extremly long..."
	), ncol = 2, byrow = TRUE)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 --tag 2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = matrix(c(
	"tag=s", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = matrix(c(
	"tag=f", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = matrix(c(
	"tag=o", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0b001001")
GetoptLong(spec, argv_str = "--tag 0721")
GetoptLong(spec, argv_str = "--tag 0xaf2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = matrix(c(
	"tag:i", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")


spec = matrix(c(
	"tag:s", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = matrix(c(
	"tag:f", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")


spec = matrix(c(
	"tag!", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = matrix(c(
	"tag=i@", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 --tag a")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = matrix(c(
	"tag=i%", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag name=1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")


spec = matrix(c(
	"tag=i{2}", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = matrix(c(
	"tag=i{2,3}", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = matrix(c(
	"tag=i{2,}", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = matrix(c(
	"tag=i{,3}", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = matrix(c(
	"tag=i{,}", "desc"
	), ncol = 2, byrow = TRUE)
print_help_msg(spec)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

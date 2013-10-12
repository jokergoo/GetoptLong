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

spec = c(
	"tag=i", "this is a description of tag which is long long and very long and extremly long..."
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 --tag 2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = c(
	"tag=s", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = c(
	"tag=f", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = c(
	"tag=o", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0b001001")
GetoptLong(spec, argv_str = "--tag 0721")
GetoptLong(spec, argv_str = "--tag 0xaf2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = c(
	"tag:i", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")


spec = c(
	"tag:s", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")

spec = c(
	"tag:f", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")


spec = c(
	"tag", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 0")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = c(
	"tag=i@", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 --tag 2")
GetoptLong(spec, argv_str = "--tag 1 --tag a")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = c(
	"tag=i%", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag name=1")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")


spec = c(
	"tag=i{2}", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 0.1")
GetoptLong(spec, argv_str = "--tag a")
GetoptLong(spec, argv_str = "--tag")
GetoptLong(spec, argv_str = "")

spec = c(
	"tag=i{2,3}", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = c(
	"tag=i{2,}", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = c(
	"tag=i{,3}", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = c(
	"tag=i{,}", "desc"
)
GetoptLong(spec, argv_str = "--tag 1")
GetoptLong(spec, argv_str = "--tag 1 2")
GetoptLong(spec, argv_str = "--tag 1 2 3")
GetoptLong(spec, argv_str = "--tag 1 2 3 4")

spec = c(
	"verbose!", "print messages"
)
GetoptLong(spec, argv_str = "--verbose")
GetoptLong(spec, argv_str = "--no-verbose")

options("GetoptLong.Config" = "bundling")
spec = c(
	"red|r", "using red",
	"blue|b", "using blue",
	"yellow|y", "using yellow"
)
GetoptLong(spec, argv_str = "--red --blue --yellow")

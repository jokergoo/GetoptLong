library(GetoptLong)
options('GetoptLong.startingMsg' = '
Usage: Rscript test.R [options]
An example to show how to use the packages
')

options('GetoptLong.endingMsg' = '
Please contact author@gmail.com for comments
')
VERSION = "0.0.1"
spec = c(
	"tag=i", "this is a description of tag which is long long and very long and extremly long..."
)
GetoptLong(spec)

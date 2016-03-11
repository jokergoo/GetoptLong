source("../R/GetoptLong.R")
source("../R/qq.R")
library(rjson)

run_command("perl stderr-fail.pl")
run_command("perl stderr-succeed.pl")
run_command("perl stdout-fail.pl")
run_command("perl stdout-succeed.pl")

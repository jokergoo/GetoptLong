source("../R/qq.R")

a = 1
expect_that(qq("this is @{a}"), 
            equals("this is 1"))
expect_that(qqcat("this is @{a}"), 
            prints_text("this is 1"))
            
            
l = list(a = "a")
expect_that(qq("this is @{a} in `l`", env = l),
            equals("this is a in `l`"))
expect_that(qqcat("this is @{a} in `l`", env = l),
            prints_text("this is a in `l`"))

a = 1:6
expect_that(qq("@{a} is an @{ifelse(a %% 2, 'odd', 'even')} number\n"),
            equals("1 is an odd number\n2 is an even number\n3 is an odd number\n4 is an even number\n5 is an odd number\n6 is an even number\n"))


expect_that(find_code("@\\{CODE\\}", "@{a}, @[b], @<c>, @(d), ${e}, `f`"),
            equals(list(template = "@{a}",
                        code     =  "a")))
expect_that(find_code("@\\[CODE\\]", "@{a}, @[b], @<c>, @(d), ${e}, `f`"),
            equals(list(template = "@[b]",
                        code     =  "b")))
expect_that(find_code("@<CODE>", "@{a}, @[b], @<c>, @(d), ${e}, `f`"),
            equals(list(template = "@<c>",
                        code     =  "c")))       
expect_that(find_code("@\\(CODE\\)", "@{a}, @[b], @<c>, @(d), ${e}, `f`"),
            equals(list(template = "@(d)",
                        code     =  "d")))
expect_that(find_code("\\$\\{CODE\\}", "@{a}, @[b], @<c>, @(d), ${e}, `f`"),
            equals(list(template = "${e}",
                        code     =  "e")))
expect_that(find_code("#\\{CODE\\}", "@{a}, @[b], @<c>, @(d), #{e}, `f`"),
            equals(list(template = "#{e}",
                        code     =  "e"))) 
expect_that(find_code("`CODE`", "@{a}, @[b], @<c>, @(d), #{e}, `f`"),
            equals(list(template = "`f`",
                        code     =  "f")))                         
expect_that(find_code("@\\[\\[CODE\\]\\]", "@{a}, @[b], @<c>, @(d), #{e}, `f`, @[[g]]"),
            equals(list(template = "@[[g]]",
                        code     =  "g")))                         

a = letters[1:3]
b = 1:3
expect_that(qq("`text = character(length(a))
for(i in seq_along(a)) {
	text[i] = qq('<tr><td>@{a[i]}</td><td>@{b[i]}</td></tr>\n')
}
text`", code.pattern = "`CODE`"),
            equals("<tr><td>a</td><td>1</td></tr>\n<tr><td>b</td><td>2</td></tr>\n<tr><td>c</td><td>3</td></tr>\n"))

cd ..
R CMD REMOVE GetoptLong
R CMD build --compact-vignettes=gs+qpdf GetoptLong
R CMD check --as-cran --timings GetoptLong_0.0.6.tar.gz
R CMD INSTALL GetoptLong_0.0.6.tar.gz
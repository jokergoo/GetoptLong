perl -I../circlize/lib -MR::Comment2Man -e "R::Comment2Man->draft('R')"

cd ..
R CMD REMOVE GetoptLong
R CMD build --compact-vignettes=gs+qpdf GetoptLong
R CMD check --as-cran --timings GetoptLong_0.0.7.tar.gz
R CMD INSTALL GetoptLong_0.0.7.tar.gz
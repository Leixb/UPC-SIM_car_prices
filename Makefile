all: car_prices.pdf

car_prices.pdf: *.Rmd
	R -q -e "rmarkdown::render('car_prices.Rmd', 'pdf_document')"

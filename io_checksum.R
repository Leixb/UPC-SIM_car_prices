library(tidyverse)
library(glue)

write_rds_w_checksum <- function(data, output_file,
                                 checksum_file = paste0(output_file, ".md5"), ...) {
    readr::write_rds(data, output_file, ...)

    # Write checksum to file
    cat(tools::md5sum(output_file), file = checksum_file, sep = "\n")
}

read_rds_w_checksum <- function(input_file,
                                checksum_file = paste0(input_file, ".md5"), ...) {
    # Check file checksum
    expected <- readLines(checksum_file, n = 1)
    got <- tools::md5sum(input_file)

    if (expected != got) {
        stop(paste0(
            "MD5 check failed:",
            "\n     got: ", got,
            "\nexpected: ", expected
        ))
    }

    readr::read_rds(input_file, ...)
}

generate_checksums <- function(folder = "./data", pattern = "(csv|rds)$", ...) {
    walk(list.files(folder, full.names = TRUE, pattern = pattern, ...), function(file) {
        cat(tools::md5sum(file), file = paste0(file, ".md5"), sep = "\n")
    })
}

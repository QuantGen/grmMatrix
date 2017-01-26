context("grmMatrix")

# Taken from http://cnsgenomics.com/software/gcta/estimate_grm.html
ReadGRMBin <- function(prefix, AllN = F, size = 4) {
    sum_i <- function(i) {
        return(sum(1:i))
    }
    BinFileName <- paste(prefix, ".grm.bin", sep = "")
    NFileName <- paste(prefix, ".grm.N.bin", sep = "")
    IDFileName <- paste(prefix, ".grm.id", sep = "")
    id <- utils::read.table(IDFileName)
    n <- dim(id)[1]
    BinFile <- file(BinFileName, "rb")
    grm <- readBin(BinFile, n = n * (n + 1)/2, what = numeric(0), size = size)
    NFile <- file(NFileName, "rb")
    if (AllN == T) {
        N <- readBin(NFile, n = n * (n + 1)/2, what = numeric(0), size = size)
    } else {
        N <- readBin(NFile, n = 1, what = numeric(0), size = size)
    }
    i <- sapply(1:n, sum_i)
    return(list(diag = grm[i], off = grm[-i], id = id, N = N))
}

examplePrefix <- paste0(system.file("extdata", package = "grmMatrix"), "/example")

grm <- grmMatrix$new(prefix = examplePrefix)
gcta <- ReadGRMBin(prefix = examplePrefix)

test_that("it throws an error if file does not exist", {
    expect_error(grmMatrix$new(prefix = "NOT_FOUND"), "NOT_FOUND.grm.id does not exist")
})

test_that("the diagonals are the same", {
    expect_equal(unname(diag(grm)), gcta$diag)
})

test_that("the length is the same", {
    expect_equal(length(grm), length(gcta$off) * 2 + length(gcta$diag))
})

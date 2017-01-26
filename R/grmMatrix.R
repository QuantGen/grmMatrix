#' @useDynLib grmMatrix grmMatrix__new
initialize <- function(prefix) {
    # Check if ID and BIN files are available
    idPath <- paste0(prefix, ".grm.id")
    if (!file.exists(idPath)) {
        stop(idPath, " does not exist")
    }
    binPath <- paste0(prefix, ".grm.bin")
    if (!file.exists(binPath)) {
        stop(binPath, " does not exist")
    }
    # Load IDs
    if (requireNamespace("data.table", quietly = TRUE)) {
        ids <- data.table::fread(idPath, header = FALSE, col.names = c("FID", "IID"), data.table = FALSE, showProgress = FALSE)
    } else {
        ids <- utils::read.table(idPath, col.names = c("FID", "IID"), stringsAsFactors = FALSE)
    }
    # Determine n
    private$n <- nrow(ids)
    # Determine rownames
    private$names <- paste0(ids$FID, "_", ids$IID)
    # Create Rcpp object
    private$xptr <- .Call(grmMatrix__new, binPath, private$n)
    # Remember prefix
    private$prefix <- prefix
}

#' @useDynLib grmMatrix grmMatrix__subset_vector
subset_vector <- function(i) {
    .Call("grmMatrix__subset_vector", private$xptr, i)
}

#' @useDynLib grmMatrix grmMatrix__subset_matrix
subset_matrix <- function(i, j) {
    subset <- .Call("grmMatrix__subset_matrix", private$xptr, i, j)
    # Preserve dimnames
    names <- private$names
    dimnames(subset) <- list(
        names[i],
        names[j]
    )
    return(subset)
}

get_n <- function() {
    private$n
}

get_names <- function() {
    private$names
}

get_prefix <- function() {
    private$prefix
}

#' @export
grmMatrix <- R6::R6Class(
    classname = "grmMatrix",
    public = list(
        initialize = initialize,
        subset_vector = subset_vector,
        subset_matrix = subset_matrix,
        get_n = get_n,
        get_names = get_names,
        get_prefix = get_prefix
    ),
    private = list(
        xptr = NULL,
        names = NULL,
        n = NULL,
        prefix = NULL
    )
)

#' @export
dim.grmMatrix <- function(x) {
    n <- x$get_n()
    c(n, n)
}

#' @export
dimnames.grmMatrix <- function(x) {
    names <- x$get_names()
    list(names, names)
}

#' @export
length.grmMatrix <- function(x) {
    n <- x$get_n()
    n * n
}

#' @export
print.grmMatrix <- function(x, ...) {
    n <- x$get_n()
    prefix <- x$get_prefix()
    cat("grmMatrix: ", n, " x ", n, " [", prefix, "]\n", sep = "")
}

#' @export
str.grmMatrix <- function(object, ...) {
    print(object)
}

#' @export
`[.grmMatrix` <- function(x, i, j, drop = TRUE) {
    n <- x$get_n()
    if (nargs() > 2) {
        # Case [i, j]
        if (missing(i)) {
            i <- 1:n
        } else if (class(i) == "logical") {
            i <- which(rep_len(i, n))
        } else if (class(i) == "character") {
            i <- match(i, rownames(x))
        }
        if (missing(j)) {
            j <- 1:n
        } else if (class(j) == "logical") {
            j <- which(rep_len(j, n))
        } else if (class(j) == "character") {
            j <- match(j, colnames(x))
        }
        subset <- x$subset_matrix(i, j)
        # Let R handle drop behavior
        if (drop == TRUE && (nrow(subset) == 1 || ncol(subset) == 1)) {
            subset <- subset[, ]
        }
    } else {
        if (missing(i)) {
            # Case []
            i <- 1:n
            j <- 1:n
            subset <- x$subset_matrix(i, j)
        } else {
            # Case [i]
            if (class(i) == "matrix") {
                i <- as.vector(i)
                if (class(i) == "logical") {
                  i <- which(rep_len(i, n * n))
                  # matrix treats NAs as TRUE
                  i <- sort(c(i, which(is.na(x[]))))
                }
            } else {
                if (class(i) == "logical") {
                  i <- which(rep_len(i, n * n))
                }
            }
            subset <- x$subset_vector(i)
        }
    }
    return(subset)
}

#' @export
as.matrix.grmMatrix <- function(x, ...) {
    x[, , drop = FALSE]
}

#' @export
is.matrix.grmMatrix <- function(x) {
    TRUE
}

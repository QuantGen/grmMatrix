// [[Rcpp::depends(BH)]]

#include <boost/interprocess/file_mapping.hpp>
#include <boost/interprocess/exceptions.hpp>
#include <boost/interprocess/mapped_region.hpp>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <Rcpp.h>
#include <string>

class grmMatrix {
    public:
        grmMatrix(std::string path, std::size_t n);
        Rcpp::NumericVector subset_vector(Rcpp::IntegerVector i);
        Rcpp::NumericMatrix subset_matrix(Rcpp::IntegerVector i, Rcpp::IntegerVector j);
    private:
        grmMatrix(const grmMatrix&);
        grmMatrix& operator=(const grmMatrix&);
        float get_element(std::size_t i, std::size_t j);
        std::size_t n;
        boost::interprocess::file_mapping file;
        boost::interprocess::mapped_region file_region;
        const float* file_data;
};

grmMatrix::grmMatrix(std::string path, std::size_t n) : n(n) {
    try {
        this->file = boost::interprocess::file_mapping(path.c_str(), boost::interprocess::read_only);
    } catch(const boost::interprocess::interprocess_exception& e) {
        Rcpp::stop("File not found.");
    }
    this->file_region = boost::interprocess::mapped_region(this->file, boost::interprocess::read_only);
    this->file_data = static_cast<const float*>(this->file_region.get_address());
};

float grmMatrix::get_element(std::size_t i, std::size_t j) {
    // Flip index if pointing to upper triangle
    if (i > j) {
        std::size_t flip = i;
        i = j;
        j = flip;
    }
    // Reduce two-dimensional index to one-dimensional index for
    // lower-triangular matrices in row-major order
    std::size_t k = ((i + 1) * i) / 2 + j;
    // Read element
    float element = this->file_data[k];
    return element;
}

Rcpp::NumericVector grmMatrix::subset_vector(Rcpp::IntegerVector i) {
    // Check if index is out of bounds
    if (Rcpp::is_true(Rcpp::any(i <= 0)) || Rcpp::is_true(Rcpp::any(i > this->n * this->n))) {
        Rcpp::stop("Invalid dimensions.");
    }
    // Convert from 1-index to 0-index
    Rcpp::IntegerVector i0(i - 1);
    // Keep size of i
    std::size_t size_i = i0.size();
    // Reserve output vector
    Rcpp::NumericVector out(size_i);
    // Iterate over indexes
    for (std::size_t idx_i = 0; idx_i < size_i; idx_i++) {
        out(idx_i) = this->get_element(i0[idx_i] % this->n, i0[idx_i] / this->n);
    }
    return out;
}

Rcpp::NumericMatrix grmMatrix::subset_matrix(Rcpp::IntegerVector i, Rcpp::IntegerVector j) {
    // Check if indexes are out of bounds
    if (Rcpp::is_true(Rcpp::any(i <= 0)) || Rcpp::is_true(Rcpp::any(i > this->n)) || Rcpp::is_true(Rcpp::any(j <= 0)) || Rcpp::is_true(Rcpp::any(j > this->n))) {
        Rcpp::stop("Invalid dimensions.");
    }
    // Convert from 1-index to 0-index
    Rcpp::IntegerVector i0(i - 1);
    Rcpp::IntegerVector j0(j - 1);
    // Keep sizes of i and j
    std::size_t size_i = i0.size();
    std::size_t size_j = j0.size();
    // Reserve output matrix
    Rcpp::NumericMatrix out(size_i, size_j);
    // Iterate over row indexes
    for (std::size_t idx_i = 0; idx_i < size_i; idx_i++) {
        // Iterate over column indexes
        for (std::size_t idx_j = 0; idx_j < size_j; idx_j++) {
            out(idx_i, idx_j) = this->get_element(i0[idx_i], j0[idx_j]);
        }
    }
    return out;
}

// Export grmMatrix::grmMatrix
RcppExport SEXP grmMatrix__new(SEXP path_, SEXP n_) {
    // Convert inputs to appropriate C++ types
    std::string path = Rcpp::as<std::string>(path_);
    std::size_t n = Rcpp::as<std::size_t>(n_);
    // Create a pointer to a grmMatrix object and wrap it as an external
    // pointer
    Rcpp::XPtr<grmMatrix> ptr(new grmMatrix(path, n), true);
    // Return the external pointer to the R side
    return ptr;
};

// Export grmMatrix::subset_vector
RcppExport SEXP grmMatrix__subset_vector(SEXP xp_, SEXP i_) {
    // Convert inputs to appropriate C++ types
    Rcpp::XPtr<grmMatrix> ptr(xp_);
    Rcpp::IntegerVector i = Rcpp::as<Rcpp::IntegerVector>(i_);
    // Invoke the subset_vector function
    Rcpp::NumericVector res = ptr->subset_vector(i);
    return res;
};

// Export grmMatrix::subset_matrix
RcppExport SEXP grmMatrix__subset_matrix(SEXP xp_, SEXP i_, SEXP j_) {
    // Convert inputs to appropriate C++ types
    Rcpp::XPtr<grmMatrix> ptr(xp_);
    Rcpp::IntegerVector i = Rcpp::as<Rcpp::IntegerVector>(i_);
    Rcpp::IntegerVector j = Rcpp::as<Rcpp::IntegerVector>(j_);
    // Invoke the subset_matrix function
    Rcpp::NumericMatrix res = ptr->subset_matrix(i, j);
    return res;
};

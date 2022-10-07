# Helper functions for set_alpha
fake.eigenvectors <- function(p){
  a <- matrix(rnorm(p*p), p, p) # only orthogonal if p is infinity so need to orthogonalize it
  a <- t(a)%*%a # this is the sum-of-squares-and-cross-product-matrix
  E <- eigen(a)$vectors # decompose to truly orthogonal columns
  return(E)
}

fake.eigenvalues <- function(p, m=p, start=1, rate=1){
  # m is the number of positive eigenvalues
  # start and rate control the decline in the eigenvalue
  s <- start/seq(1:m)^rate
  s <- c(s, rep(0, p-m)) # add zero eigenvalues
  L <- diag(s/sum(s)*m) # rescale so that sum(s)=m and put into matrix,
  # which would occur if all the traits are variance standardized
  return(L)
}

fake.cov.matrix <- function(p){
  # p is the size of the matrix (number of cols and rows)
  E <- fake.eigenvectors(p)
  L <- fake.eigenvalues(p)
  S <- E%*%L%*%t(E)
  return(S)
}

#' Transforms a p-value into Jeffreys' approximate Bayes factor
#'
#' Converts a two-sided p-value from a z- or t-test into Jeffreys' approximate
#' Bayes factor, given the sample size.
#'
#' @inheritParams JABt
#' @param p The two-sided p-value.
#' @param z Is the p-value based on a z- or t-statistic? TRUE if z.
#' @param df If z=FALSE, provide the degrees of freedom for the t-statistic.
#'
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a p-value of 0.007038863 from a z-test into JAB
#' # using a sample size of 200.
#' JABp(200, 0.007038863)
#'
#' # Transform a p-value of 0.007038863 from a t-test with 190
#' # degrees of freedom into JAB using a sample size of 200.
#' JABp(200, 0.007038863, z=FALSE, df=190)
#'
#' @importFrom stats qnorm qt
JABp <- function(n, p, z = TRUE, df = NULL, method = "JAB", upper = 1){
  if (!is.numeric(p) || length(p) == 0 || !all(is.finite(p)) ||
      any(p <= 0) || any(p > 1)) {
    stop("`p` must be numeric with values in (0, 1].", call. = FALSE)
  }
  if (!isTRUE(z) && !isFALSE(z)) {
    stop("`z` must be TRUE or FALSE.", call. = FALSE)
  }

  # Find the corresponding z- or t-statistic
  if(z){
    stat <- qnorm(p/2, lower.tail = FALSE)
  } else {
    if (is.null(df)) {
      stop("When `z = FALSE`, provide the degrees of freedom of the t-statistic via `df`.",
           call. = FALSE)
    }
    if (!is.numeric(df) || length(df) == 0 || !all(is.finite(df)) ||
        any(df <= 0)) {
      stop("`df` must be a positive, finite numeric value.", call. = FALSE)
    }
    stat <- qt(p/2, df = df, lower.tail = FALSE)
  }

  BF <- JABt(n, stat, method = method, upper = upper)

  return(BF)
}

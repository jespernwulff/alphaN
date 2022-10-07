#' Set the alpha level based on sample size for coefficients in a  regression models.
#'
#' @param n The sample size.
#' @param p The number of parameters to be tested.
#' @param evidence Desired level of evidence: 1 to avoid the Lindley Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param tstat Should the t-statistic or the z-statistic be used? Set as TRUE in the case of linear regression.
#' @param plotprint If true prints a plot relating Bayes factors and p-values.
#' @param seed Set the seed for generating the random variance-covariance matrix. Only relevant for testing.
#'
#' @return numeric alpha level required achieve the desired level of evidence.
#' @export
#'
#' @examples
#' ## Set alpha such that the Lindley paradox is avoided for the test of
#' ## a single coefficient in a linear regression model with 10 regressors
#' ## with a sample size of 1000.
#'
#' set_alpha(1000, p = 10, evidence = 1)
#'
#' ## Set alpha such to achieve moderate evidence if the null is rejected
#' ## for the test of a single coefficient a logistic regression model with
#' ## 5 regressors and a sample size of 1000. Also print a plot relating
#' ## the Bayes factor to the p-value.
#'
#' set_alpha(1000, p = 5, evidence=3, tstat = FALSE, plotprint = TRUE)
#' @section References:
#' Taylor, L. & Wulff, J.N. (2022). Let alpha depend on n: A Bayesian-frequentist compromise by using lower alpha levels in larger sample size
#' @importFrom grDevices recordPlot
#' @importFrom graphics abline axis points
#' @importFrom stats dt pnorm rnorm
set_alpha <- function(n, p=1, evidence=1, tstat = TRUE, plotprint=FALSE, seed = 100){

  # Find the alpha level that corresponds to to the Bayes factor
  # specified by the parameter 'evidence'

  stopifnot(n%%1==0, p%%1==0, is.numeric(evidence),
            n >= 30, p > 0, evidence >= 1)

  ## First, generate a valid variance-covariance matrix
  set.seed(seed)
  corM <- fake.cov.matrix(p+1)
  colnames(corM) <- paste0("X", 0:p)
  rownames(corM) <- paste0("X", 0:p)

  ## Second, use it to set the SEs
  SE <- sqrt(diag(corM)[2])

  ### and make a sequence of betas to get p-values
  beta <- seq(1.2, 5, length.out=500)
  ts <- beta / SE

  if(tstat) {
    ps <- dt(ts, df= n-1-p) # for linear regression
  } else{
    ps <- pnorm(-abs(ts))*2 # for everything else
  }

  ## Third, loop to get a Bayes factor every p-value

  bf <- numeric(length(ps))
  i <- 0

  for(pvals in ps){
    i <- i+1
    estimates <- c(0, rep(beta[i], p))
    names(estimates) <- paste0("X", 0:p)
    bfs <- BFpack::BF(estimates, Sigma = corM, n = n,
                      hypothesis = "X1=0")
    bf[i] <- 1/bfs$BFtu_exploratory[,1][2]
  }

  ### Find the p-value that corrsponds to the desired level of evidence
  alpha <- ps[which.min(abs(bf-evidence))]

  if(plotprint){
    lindley <- ps[which.min(abs(bf-1))]
    moderate <- ps[which.min(abs(bf-3))]
    strong <- ps[which.min(abs(bf-10))]
    indicated <- alpha

    plot(ps, bf, type="l", lty=1, lwd=2, log = "y",
         xlab = "p-value", ylab = "Bayes factor",
         ylim = c(0.1, 10), xlim = c(0, max(c(0.05, lindley))),
         axes=FALSE)

    axis(side=1, at = c(0, as.numeric(lindley), as.numeric(moderate),
                        as.numeric(strong), 0.05, indicated),
         labels = c(0, round(lindley, digits = 3), round(moderate, digits = 3),
                    round(strong, digits = 3), 0.05, round(indicated, digits = 3)),
         lwd = 2, las = 3)

    axis(side=2, at = c(0.1, 0.33, 1, 3, 10), labels = c("1/10", "1/3", 1, 3, 10), lwd = 2)
    abline(h = c(0.1, 0.33, 1, 3, 10), col = "gray", lty = 2)
    abline(v = c(lindley, moderate, strong), lty = 3)
    abline(v = indicated, lty = 3, col = "red")

    points(indicated, evidence, col = "black", bg="red", cex=2, pch = 24, lwd = 2)
    plot <- recordPlot()
  }


  if(plotprint){

    return(list(alpha = alpha,
                evidence = evidence,
                plot = plot))

  } else {

    return(list(alpha = alpha,
                evidence = evidence))
  }

}

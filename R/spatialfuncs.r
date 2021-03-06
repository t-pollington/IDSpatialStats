applyBCa <- function(boots, ci.level){
  boots = boots[!is.na(boots)]
  CI = coxed::bca(boots, conf.level = ci.level)
  return(CI)
}

##' Generalized version of \code{get.pi}
##'
##' Generalized version of the \code{get.pi} function that takes in an arbitrary function and
##' returns the probability that a point within a particular range of a point of interest shares 
##' the relationship
##' specified by the passed in function with that point.
##'
##' @param posmat a matrix with columns x, y and any other named
##'    columns needed by \code{fun}
##' @param fun a function that takes in two rows of \code{posmat} and returns:
##' \enumerate{
##'      \item for pairs included in the numerator and denominator
##'      \item for pairs that should only be included in the denominator
##'      \item for pairs that should be ignored all together}
##' Note that names from \code{posmat} are not preserved in calls to \code{fun}, so the columns of 
##' the matrix should be
##' referenced numerically
##' so this is not available to the \code{fun}
##' @param r the series of spatial distances (or their maximums) we are
##'          interested in
##' @param r.low the low end of each range, 0 by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return  pi value for each distance range that we look at. Where:
##'
##'\deqn{ \pi(d_1, d_2) = \frac{\sum \boldsymbol{1} (d_{ij} \in [d_1,d_2)) \boldsymbol{1} (f(i,j)=1) }{\sum \sum \boldsymbol{1} [d_{ij} \in (d_1,d_2)) \boldsymbol{1} (f(i,j) \in \{1,2\}) }}
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.pi
##' @family spatialtau
##'
##' @example R/examples/get_pi.R
##'

get.pi <- function(posmat,
                   fun,
                   r = 1,
                   r.low=rep(0,length(r)),
                   data.frame=TRUE) {

  xcol <- which(colnames(posmat) == "x")
  ycol <- which(colnames(posmat) == "y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- .Call("get_pi",
              posmat,
              fun,
              r,
              r.low,
              1:nrow(posmat),
              xcol,
              ycol)
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, pi=rc))
  }
}


##'
##' Generalized version of \code{get.theta}
##'
##'
##' Generalized version of the \code{get.theta} function that takes in an arbitrary function and
##' returns the odds that a point within a particular range of a point of interest shares the relationship
##' specified by the passed in function with that point.
##'
##' @param posmat a matrix with columns x, y and any other named
##'    columns needed by \code{fun}
##' @param fun a function that takes in two rows of posmat and returns:
##' \enumerate{
##'      \item  for pairs that are (potentially) related
##'      \item for pairs that are unrelated
##'      \item for pairs that should be ignored all together}
##' Note that names from \code{posmat} are not preserved in calls to \code{fun}, so the columns of the matrix should be
##' referenced numerically
##' so this is not available to the fun
##' @param r the series of spatial distances (or their maximums) we are
##'          interested in
##' @param r.low the low end of each range, 0 by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return  theta value for each distance range that we look at. Where:
##'
##' \deqn{ \theta(d_1,d_2) = \frac{\sum \boldsymbol{1} d_{ij} \in [d_1,d_2)) \boldsymbol{1} (f(i,j)=1) }{\sum \sum \boldsymbol{1} d_{ij} \in [d_1,d_2)) \boldsymbol{1} (f(i,j)=2) }}
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.theta
##' @family spatialtau
##'
##' @example R/examples/get_theta.R
##'

get.theta <- function(posmat,
                      fun,
                      r = 1,
                      r.low=rep(0,length(r)),
                      data.frame=TRUE) {

  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- .Call("get_theta",
              posmat,
              fun,
              r,
              r.low,
              1:nrow(posmat),
              xcol,
              ycol)
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, theta=rc))
  }
}


##'
##' Optimized version of \code{get.pi} for typed data.
##'
##' Version of the \code{get.pi} function that is optimized for statically typed data. That is
##' data where we are interested in the probability of points within some distance of points of
##' typeA are of typeB.
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances wer are interested in
##' @param r.low the low end of each range....0  by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return pi values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.pi
##'
##' @example  R/examples/get_pi_typed.R
##'

get.pi.typed <- function(posmat,
                         typeA = -1,
                         typeB = -1,
                         r=1,
                         r.low=rep(0,length(r)),
                         data.frame=TRUE) {

  rc <- .C("get_pi_typed",
            as.integer(posmat[,"type"]),
            as.double(posmat[,"x"]),
            as.double(posmat[,"y"]),
            as.integer(nrow(posmat)),
            as.integer(typeA),
            as.integer(typeB),
            as.double(r.low),
            as.double(r),
            as.integer(length(r)),
            as.integer(1:nrow(posmat)),
            rc=double(length(r)))
     
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, pi=rc$rc))
  }
}


##'
##' Optimized version of \code{get.theta} for typed data.
##'
##' Version of the \code{get.theta} function that is optimized for statically typed data. That is
##' data where we are interested in the odds that points within some distance of points of
##' typeA are of typeB.
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances wer are interested in
##' @param r.low the low end of each range....0  by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return theta values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.theta
##'
##' @example R/examples/get_theta_typed.R
##'

get.theta.typed <- function(posmat,
                            typeA = -1,
                            typeB = -1,
                            r=1,
                            r.low=rep(0,length(r)),
                            data.frame=TRUE) {
     
     rc <- .C("get_theta_typed",
              as.integer(posmat[,"type"]),
              as.double(posmat[,"x"]),
              as.double(posmat[,"y"]),
              as.integer(nrow(posmat)),
              as.integer(typeA),
              as.integer(typeB),
              as.double(r.low),
              as.double(r),
              as.integer(length(r)),
              as.integer(1:nrow(posmat)),
              rc=double(length(r)))
     
     if (data.frame == FALSE) {
          return(rc)
     } else if (data.frame == TRUE) {
          return(data.frame(r.low=r.low, r=r, theta=rc$rc))
     }
}


##' Calculate bootstrapped BCa confidence intervals from \code{get.pi} values.
##'
##' Wrapper using \pkg{coxed} package to calculate the
##' BCa (bias-corrected and accelerated) confidence interval (CI) for \eqn{\pi}(\code{r.low}, \code{r}), based on bootstrapped values from \code{get.pi.bootstrap}.
##'
##' @param posmat a matrix with named columns x and y for 2D individual location
##' @param fun the function to decide transmission-related pairs
##' @param r the upper end of each distance band
##' @param r.low the low end of each distance band (default: a vector of zeroes)
##' @param boot.iter the number of bootstrap iterations (default = 1000)
##' @param ci.level the level of the desired BCa CI (default = 0.95)
##' @param data.frame logical: indicating whether to return results as a data frame (default = TRUE)
##'
##' @return If \code{data.frame = TRUE} then a data frame of 5 variables \code{r.low}, \code{r}, \code{pt.est} (the point estimate from \code{get.pi}), the confidence envelope as \code{ci.low} and \code{ci.high}, with the observations representing ascending distance bands. Else a matrix with first row \code{ci.low} and second row \code{ci.high} with columns representing ascending distance bands.
##'
##' @author Justin Lessler and Timothy M Pollington
##'
##' @references \href{https://arxiv.org/pdf/1911.08022v4.pdf#page=12}{Rationale for BCa rather than percentile CIs} is described in Pollington et al. (2020)
##' Developments in statistical inference when assessing 
##' spatiotemporal disease clustering with the tau statistic.
##' *arXiv/stat.ME: 1911.08022v4*.
##'
##' @family get.pi
##' 
##' @section Depends on:
##' coxed::bca()
##'
##' @example R/examples/get_pi_ci.R
##' @md

get.pi.ci <- function(posmat,
                      fun,
                      r = 1,
                      r.low = rep(0,length(r)),
                      boot.iter = 1000,
                      ci.level = 0.95,
                      data.frame = TRUE) {
     
  boots <- get.pi.bootstrap(posmat, fun, r, r.low, boot.iter)
  boots = boots[,-(1:2)]
  
  rc <- apply(boots, 1, applyBCa, ci.level = 0.95)
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low = r.low, 
                         r = r, 
                         pt.est = get.pi(posmat, fun, r, r.low)$pi, 
                         ci.low = rc[1,], 
                         ci.high = rc[2,]))
  }
}


##' Calculate bootstrapped confidence intervals for \code{get.theta} values.
##'
##' Wrapper to \code{get.theta.bootstrap} that takes care of calculating the
##' confidence intervals based on the bootstrapped values.
##'
##' @param posmat a matrix with columns type, x and y
##' @param fun the function to decide relationships
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range. 0 by default
##' @param boot.iter the number of bootstrap iterations
##' @param ci.level significance level of the 95% BCa CI, default = 0.95
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return a matrix with a row for the high and low values and a column per distance
##' @author Justin Lessler
##' @family get.theta
##' @example R/examples/get_theta_ci.R

get.theta.ci <- function(posmat,
                         fun,
                         r=1,
                         r.low=rep(0,length(r)),
                         boot.iter = 1000,
                         ci.level=0.95,
                         data.frame=TRUE) {
     
  boots <- get.theta.bootstrap(posmat, fun, r, r.low, boot.iter)
  boots = boots[,-(1:2)]
  rc <- apply(boots, 1, applyBCa, ci.level = 0.95)
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, 
                         r=r, 
                         pt.est=get.theta(posmat, fun, r, r.low)$theta, 
                         ci.low=rc[1,], 
                         ci.high=rc[2,]))
  }
}


##' Bootstrap \code{get.pi} values.
##'
##' Runs \code{get.pi} on multiple bootstraps of the data. Is formulated
##' such that the relationships between
##' points and themselves will not be calculated.
##'
##' @param posmat a matrix with columns type, x and y
##' @param fun the function to decide relationships
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range. 0 by default
##' @param boot.iter the number of bootstrap iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return Values of pi for all distance bands. Return value dependent on data.frame argument.
##' Asa matrix (rows = bootstrap samples, columns = increasing distance bands)
##' or a data.frame (r.low, r and increasing distance bands)
##'
##' @note In each bootstrap iteration N observations are drawn from the existing data with replacement. To avoid errors in
##' inference resulting from the same observatin being compared with itself in the bootstrapped data set, original indices
##' are perserved, and pairs of points in the bootstrapped dataset with the same original index are ignored.
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.pi
##'
##' @example R/examples/get_pi_bootstrap.R
##'

get.pi.bootstrap <- function(posmat,
                             fun,
                             r=1,
                             r.low=rep(0,length(r)),
                             boot.iter=500,
                             data.frame=TRUE) {

  xcol <- which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .Call("get_pi",
                    posmat[inds,],
                    fun,
                    r,
                    r.low,
                    inds,
                    xcol,
                    ycol)
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' Bootstrap \code{get.theta} values.
##'
##' Runs \code{get.theta} on multiple bootstraps of the data. Is formulated
##' such that the relationships between
##' points and themselves will not be calculated.
##'
##' @param posmat a matrix with columns type, x and y
##' @param fun the function to decide relationships
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range. 0 by default
##' @param boot.iter the number of bootstrap iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return theta values for all the distances we looked at
##'
##' @note In each bootstrap iteration N observations are drawn from the existing data with replacement. To avoid errors in
##' inference resulting from the same observatin being compared with itself in the bootstrapped data set, original indices
##' are perserved, and pairs of points in the bootstrapped dataset with the same original index are ignored.
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.theta
##'
##' @example R/examples/get_theta_bootstrap.R
##'

get.theta.bootstrap <- function(posmat,
                                fun,
                                r=1,
                                r.low=rep(0,length(r)),
                                boot.iter=500,
                                data.frame=TRUE) {


  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .Call("get_theta",
                    posmat[inds,],
                    fun,
                    r,
                    r.low,
                    inds,
                    xcol,
                    ycol)
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' runs bootstrapping on \code{get.pi.typed}
##'
##' Bootstraps typed pi values. Makes sure distances between a sample and
##' another draw of itself are left out
##'
##' @param boot.iter the number of bootstrap iterations
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return pi values for all the distances we looked at
##'
##' @family get.pi
##'
##' @example R/examples/get_pi_typed_bootstrap.R
##'

get.pi.typed.bootstrap <- function(posmat,
                                   typeA = -1,
                                   typeB = -1,
                                   r=1,
                                   r.low=rep(0,length(r)),
                                   boot.iter,
                                   data.frame=TRUE) {


  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .C("get_pi_typed",
                 as.integer(posmat[inds,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(inds),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' runs bootstrapping on \code{get.theta.typed}
##'
##' Bootstraps typed pi values. Makes sure distances between a sample and
##' another draw of itself are left out
##'
##' @param boot.iter the number of bootstrap iterations
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return theta values for all the distances we looked at
##'
##' @family get.theta
##'
##' @example R/examples/get_theta_typed_bootstrap.R
##'

get.theta.typed.bootstrap <- function(posmat,
                                      typeA = -1,
                                      typeB = -1,
                                      r=1,
                                      r.low=rep(0,length(r)),
                                      boot.iter,
                                      data.frame=TRUE) {


  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .C("get_theta_typed",
                 as.integer(posmat[inds,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(inds),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' get the null distribution of the \code{get.pi} function
##'
##' Does permutations to calculate the null distribution of get pi
##' if there were no spatial dependence. Randomly reassigns coordinates
##' to each observation permutations times
##'
##' @param posmat a matrix with columns type, x and y
##' @param fun the function to evaluate
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return pi values for all the distances we looked at
##'
##' @family get.pi
##'
##' @example R/examples/get_pi_permute.R
##'

get.pi.permute <- function(posmat,
                           fun,
                           r=1,
                           r.low=rep(0,length(r)),
                           permutations,
                           data.frame=TRUE) {


  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    tmp.posmat <- posmat
    tmp.posmat[,"x"] <- posmat[inds,"x"]
    tmp.posmat[,"y"] <- posmat[inds,"y"]
    rc[i,] <- .Call("get_pi",
                    tmp.posmat,
                    fun,
                    r,
                    r.low,
                    1:nrow(posmat),
                    xcol,
                    ycol)
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' get the null distribution of the \code{get.theta} function
##'
##' Does permutations to calculate the null distribution of get theta
##' if there were no spatial dependence. Randomly reassigns coordinates
##' to each observation permutations times
##'
##' @param posmat a matrix with columns type, x and y
##' @param fun the function to evaluate
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return theta values for all the distances we looked at
##'
##' @family get.theta
##'
##' @example R/examples/get_theta_permute.R
##'

get.theta.permute <- function(posmat,
                              fun,
                              r=1,
                              r.low=rep(0,length(r)),
                              permutations,
                              data.frame=TRUE) {


  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    tmp.posmat <- posmat
    tmp.posmat[,"x"] <- posmat[inds,"x"]
    tmp.posmat[,"y"] <- posmat[inds,"y"]
    rc[i,] <- .Call("get_theta",
                    tmp.posmat,
                    fun,
                    r,
                    r.low,
                    1:nrow(posmat),
                    xcol,
                    ycol)
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' get the null distribution of the get.pi.typed function
##'
##' Does permutations to calculate the null distribution of get pi
##' if there were no spatial dependence. Randomly reassigns coordinates
##' to each observation permutations times
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return pi values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.pi
##'
##' @example R/examples/get_pi_typed_permute.R
##'

get.pi.typed.permute <- function(posmat,
                                 typeA = -1,
                                 typeB = -1,
                                 r=1,
                                 r.low=rep(0,length(r)),
                                 permutations,
                                 data.frame=TRUE) {

  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }


  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    rc[i,] <- .C("get_pi_typed",
                 as.integer(posmat[,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(1:nrow(posmat)),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' get the null distribution of the get.theta.typed function
##'
##' Does permutations to calculate the null distribution of get theta
##' if there were no spatial dependence. Randomly reassigns coordinates
##' to each observation permutations times
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return theta values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.theta
##'
##' @example R/examples/get_theta_typed_permute.R
##'

get.theta.typed.permute <- function(posmat,
                                    typeA = -1,
                                    typeB = -1,
                                    r=1,
                                    r.low=rep(0,length(r)),
                                    permutations,
                                    data.frame=TRUE) {

  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }


  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    rc[i,] <- .C("get_theta_typed",
                 as.integer(posmat[,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(1:nrow(posmat)),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' generalized version of \code{get.tau}
##'
##'
##' returns the relative probability (or odds) that points at some distance
##' from an index point share some relationship with that point versus
##' the probability (or odds) any point shares that relationship with that point.
##'
##' @param posmat a matrix with columns x, y and any other named
##'    columns needed by \code{fun}
##' @param fun a function that takes in two rows of posmat and returns:
##' \enumerate{
##'      \item for pairs included in the numerator (and the denominator for independent data)
##'      \item for pairs that should only be included in the denominator
##'      \item for pairs that should be ignored all together}
##' Note that names from \code{posmat} are not preserved in calls to
##' \code{fun}, so the columns of the matrix should be referenced numerically
##' so this is not available to fun
##' @param r the series of spatial distances (or their maximums) we are
##'          interested in
##' @param r.low the low end of each range, 0 by default
##' @param comparison.type what type of points are included in the comparison set.
##' \itemize{
##'   \item "representative" if comparison set is representative of the underlying population
##'   \item "independent" if comparison set is cases/events coming from an indepedent process
##' }
##' @param data.frame logical indicating whether to return results 'like' a data frame format (default = TRUE)
##'
##' @return The tau value for each distance we look at as a tau class with a matrix or data frame style. If \code{comparison.type} is "representative", this is:
##'
##' \code{tau = get.pi(posmat, fun, r, r.low)/get.pi(posmat,fun,infinity,0)}
##'
##' If \code{comparison.type} is "independent", this is:
##'
##' \code{tau = get.theta(posmat, fun, r, r.low)/get.theta(posmat,fun,infinity,0)}
##'
##' @author Justin Lessler, Timothy M Pollington and Henrik Salje
##'
##' @family get.tau
##' @family spatialtau
##'
##' @example R/examples/get_tau.R
##'

get.tau <- function(posmat,
                    fun,
                    r = 1,
                    r.low=rep(0,length(r)),
                    comparison.type = "representative",
                    data.frame=TRUE) {

  xcol <- which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  if (comparison.type == "representative") {
    comp.type.int <- 0
  } else if (comparison.type == "independent") {
    comp.type.int <- 1
  } else {
    stop("unknown comparison.type specified")
  } 

  rc <- .Call("get_tau",
              posmat,
              fun,
              r,
              r.low,
              comp.type.int,
              1:nrow(posmat),
              xcol,
              ycol)
  
  if (data.frame == FALSE) {
       class(rc) <- "tau"
       attr(rc, "comparison.type") = comparison.type
       return(rc)
  } else if (data.frame == TRUE) {
       rc = data.frame(r.low=r.low, r=r, tau.pt.est=rc)
       class(rc) <- "tau"
       attr(rc, "comparison.type") = comparison.type
       return(rc)
  }
}

##' Global hypothesis testing for the tau statistic
##'
##' Performs a graphical hypothesis test to assess the evidence against the null hypothesis (H_0: tau = 1 i.e. no spatiotemporal clustering nor inhibition). A global envelope test from the \code{GET} package is used to see if any part of the point estimate connected line is outside the lower or upper bounds of the global envelope. The global envelope is formed on the tau estimator acting on time-permuted data to simulate H_0. The global envelope test is of 'extreme rank type' i.e. minimum of pointwise ranks with 95\% significance level. 
##'
##' @param posmat a matrix with columns x, y and any other named
##'    columns needed by \code{fun}
##' @param fun a function that takes in two rows of posmat and returns:
##' \enumerate{
##'      \item for pairs included in the numerator (and the denominator for independent data)
##'      \item for pairs that should only be included in the denominator
##'      \item for pairs that should be ignored all together}
##' Note that names from \code{posmat} are not preserved in calls to
##' \code{fun}, so the columns of the matrix should be referenced numerically
##' so this is not available to fun
##' @param r the series of spatial distances (or their maximums) we are
##'          interested in
##' @param r.low the low end of each range, 0 by default
##' @param permutations number of simulations of H_0. 2,500 is an optimal number according to Myllymäki et al. (2017).
##' @param comparison.type what type of points are included in the comparison set.
##' \itemize{
##'   \item "representative" if comparison set is representative of the underlying population
##'   \item "independent" if comparison set is cases/events coming from an indepedent process
##' }
##' @return An object of class \code{tauGET} which can then be plotted using \code{plot.tau()} and an additional \code{tau} class object. The object consists of:
##' \itemize{
##'   \item r that inputted earlier
##'   \item obs the tau point estimate computed internally using \code{get.tau()}
##'   \item central the median estimate of all simulation curves that represent the null hypothesis. Comparing this to the tau=1 line indicates if it is reasonable to assume that H_0 was adequately simulated.
##'   \item lo the lower bound of the global envelope
##'   \item hi the upper bound of the global envelope
##'   \item tau.permute the entire record of simulations of H_0, to plot with the global envelope using \code{plot.tau()}.
##' }
##' @section Attributes:
##' \itemize{
##'   \item p_interval represents a range rather than a single p-value to assess the evidence against H_0. Accessed using \code{attr(x,"p_interval")}.
##' }
##' @author Timothy M Pollington
##'
##' @family get.tau
##' @family spatialtau
##' @example R/examples/get_tau_GET.R
##'

get.tau.GET <- function(posmat, fun, r, r.low, permutations = 2500, comparison.type){
  get.tau = IDSpatialStats::get.tau(posmat = posmat, fun = fun, r = r, r.low = r.low, comparison.type = comparison.type, data.frame = FALSE)
  tau.permute = IDSpatialStats::get.tau.permute(posmat = posmat, fun = fun, r = r, r.low = r.low, permutations = permutations, comparison.type = comparison.type, data.frame = FALSE)
  curveset = GET::create_curve_set(list(r = r, obs = as.numeric(get.tau), sim_m = t(tau.permute)))
  GET.res = GET::global_envelope_test(curve_sets = curveset, type = "rank", alpha = 0.05,
           alternative = c("two.sided"), ties = "erl", probs = c(0.025, 0.975), quantile.type = 7, 
           central = "median")
  GET.res = list(GET.res, tau.permute)
  class(GET.res) <- "tauGET"
  return(GET.res)
}

##' Cluster range estimation using \code{get.tau.D.param.est}
##'
##' Estimates the range of spatiotemporal clustering. It records the place on the horizontal tau=1 line where each spatially bootstrapped simulation touches. This distribution then represents an empirical distribution for the clustering range and a confidence interval can be computed.  
##'
##' @param r the series of spatial distances (or their maximums) we are
##'          interested in
##' @param tausim the set of spatially-bootstrapped simulations. Has to be \code{taubstrap} class; use \code{get.tau.bootstrap(..., data.frame = FALSE)} to obtain this. 
##' @param GETres is a required object and is obtained from a previous global hypothesis test using \code{get.tau.GET}. It ensures that the user has performed a graphical hypothesis test first and has considered there is evidence against H_0, before deciding to estimate the clustering range.
##' @return An object of class \code{tauparamest} which can then be plotted using \code{plot.tau()}. The object consists of:
##' \itemize{
##'   \item envelope the distribution of clustering range estimates
##' }
##' @section Attributes:
##' \itemize{
##'   \item BCaCI the BCa CI for the distribution of clustering range estimates
##' }
##' @author Timothy M Pollington
##'
##' @family get.tau
##' @family spatialtau
##' @example R/examples/get_tau_D_param_est.R

get.tau.D.param.est <- function(r, tausim, GETres = NULL){
  stopifnot(!is.null(GETres)) # makes sure the user has been principled and performed a global
  # hypothesis test using get.tau() before estimating D
  stopifnot(length(r)>1)
  stopifnot(class(tausim)=="taubstrap")
  if(!is.null(names(tausim))){ # ie if tausim is like a 'data.frame despite having a taubstrap class
    tausim = t(tausim[,-c(1,2)])
  }
  boot.iter = dim(tausim)[1]
  ciIntercept <- function(boot.iter, r, tausim) {
    j.max = length(r)
    # define d.envelope by finding for each bootstrap sample the (interpolated) d-intercept point
    alwaysabove1 = 0
    d.envelope = NULL
    for (i in 1:boot.iter) {
      j = 1 # first distance band
      if(tausim[i,j] > 1){ # else ignore simulation as starting from below tau = 1
        stillabove1 = TRUE
          while (stillabove1 & (j < j.max)) {
            j = j + 1
            if(tausim[i,j] <= 1){ # else it stays above tau = 1 until the next j is tested
              stillabove1 = FALSE
              root.tau1 = ((1-tausim[i,(j-1)])*(r[j]-r[j-1])/(tausim[i,j]-tausim[i,(j-1)]))+r[j-1]
              d.envelope = c(d.envelope, root.tau1)
            }
          }
          if(stillabove1 & j==j.max){
            alwaysabove1 = alwaysabove1 + 1
          }
      }
    }
    print(paste0(length(d.envelope)/boot.iter*100, "% of boostrap sims crossing tau = 1 from above"))
    print(paste0(alwaysabove1/boot.iter*100, "% of bootstrap sims always above tau = 1"))
    if(alwaysabove1>0){
      warning("Note that there are some bootstrap sims that stay above tau = 1 for the entire distance band set. If more than a few percent of these are above tau = 1 then a reliable CI cannot be constructed as it will have not have come from a random sample.")
    }
    return(d.envelope)
  }
  envelope = ciIntercept(boot.iter,r,tausim)
  d.envelope = as.data.frame(envelope)
  attr(d.envelope,"BCaCI") = coxed::bca(d.envelope$envelope, conf.level = 0.95)
  
  class(d.envelope) <- "tauparamest"
  return(d.envelope)
}
  
##' Plotting the results from tau functions
##'
##' Three types of plots:
##' \enumerate{
##' \item Diagnostic plot to indicate the structure or magnitude of spatiotemporal clustering. Requires \code{tau} object; \code{tauCI} object optional to draw pointwise CIs. This plot is only suitable for the purpose of a graphical hypothesis test in the situation that a specific distance band is selected prior to graph creation.
##' \item Graphical hypothesis test to assess the evidence against the null hypothesis (no spatiotemporal clustering nor inhibition). Requires \code{tau} and \code{tauGET} objects.
##' \item Estimation of the clustering range (the distribution of the places on the horizontal tau=1 line, where decreasing bootstrap simulations first intercept). Requires \code{tau}, \code{tauparamest} and \code{taubstrap} objects.
##' }
##'
##' @param x \code{tau} object; create using \code{get.tau(..., data.frame = TRUE)}. Required for all plots.
##' @param r.mid If \code{TRUE}(default) then for each point the x-coordinate of the midpoint of a distance band is plotted and if \code{FALSE} the endpoint of the distance band is plotted.
##' @param tausim the set of spatially-bootstrapped simulations of \code{taubstrap} class; use \code{get.tau.bootstrap()} to obtain this. Required for Estimation of the clustering range plot.
##' @param ptwise.CI the set of pointwise CIs of \code{tauCI} class; create using \code{get.tau(..., data.frame = TRUE)}. Optional for the diagnostic plot but should not be supplied for the other plots.
##' @param GET.res is a required object for the graphical hypothesis test plot but should not be supplied for the other plots. It is obtained from \code{get.tau.GET(..., data.frame = TRUE)}. It ensures that the user has performed a graphical hypothesis test first and has considered there is evidence against H_0, before deciding to estimate the clustering range.
##' @param d.param.est a required object for Estimating the clustering range plot from \code{get.tau.D.param(..., data.frame = TRUE)}, but should not be supplied for the other plots. A \code{taubstrap} object will also be necessary.
##' @param ... other arguments which are standard for \code{plot()} for plot customisation
##' @author Timothy M Pollington
##'
##' @family get.tau
##' @family spatialtau
##'

plot.tau <- function(x, r.mid = TRUE, tausim = NULL, ptwise.CI = NULL, GET.res = NULL, d.param.est = NULL, ...)
{
  stopifnot(class(x)=="tau")
  if(!is.null(ptwise.CI)){
    stopifnot(class(ptwise.CI)=="tauCI")
  }
  if(!is.null(GET.res)){
    stopifnot(class(GET.res)=="tauGET")
  }
  if(!is.null(d.param.est)){
    stopifnot(class(d.param.est)=="tauparamest")
  }
  if(!is.null(tausim)){
    stopifnot(class(tausim)=="taubstrap")
  }
  if(!is.null(ptwise.CI) & !is.null(GET.res)){
    stop("To avoid misinterpretation of visual results we do not allow pointwise CIs and global envelopes to be plotted on the same graph")
  }
  if(!is.null(ptwise.CI) & !is.null(d.param.est)){
    stop("To avoid misinterpretation of visual results we do not allow pointwise CIs and clustering range estimates to be plotted on the same graph")
  }
  if(!is.null(GET.res) & !is.null(d.param.est)){
    stop("To avoid misinterpretation of visual results we do not allow global envelopes and clustering range estimates to be plotted on the same graph")
  }
  if(is.null(tausim) & !is.null(d.param.est)){
    stop("Need tausim and d.param.est class objects to plot clustering range estimates")
  }
  if(r.mid==TRUE){
    r.end = 0.5*(x$r.low + x$r)
    midorend = "at distance band midpoint"
    xlim = c(0,(max(r.end)*1.01))
  }
  else{
    r.end = x$r
    midorend = "at distance band endpoint"
    xlim = c(0,(max(x$r)*1.01))
  }
  
  # identify if the lower bound of each distance band contains zero or not, 
  # and label graph appropriately, with correct units if provided
  if(!is.null(attr(x$r.low, "units")) & !is.null(attr(x$r, "units")) & 
     identical(attr(x$r.low, "units"), attr(x$r, "units"))){
    unitslabel = c("(", attr(x$r.low, "units"), ")")
  }
  else{
    unitslabel = ""
  }
  
  if(all(x$r.low==0)){
    xlab = bquote("Distance [0," * d[m] * ") from an average case " * .(unitslabel))
  }
  else{
    xlab = bquote("Distance [" * d[l] * "," * d[m] * ") from an average case " * .(unitslabel))
  }
  
  if(is.null(GET.res) | is.null(d.param.est)){
    if(is.null(ptwise.CI)){
    plot(x = r.end, y = x$tau.pt.est, xlim=xlim,
       ylim=range(x$tau.pt.est, na.rm = TRUE)+diff(range(x$tau.pt.est, na.rm = TRUE))*c(-0.05,0.05),
       cex.axis=1,col="black", xlab=xlab, ylab="Tau", 
       cex.main=1, lwd=2, type="p", las=1, cex.axis=1, xaxs = "i", yaxs = "i", pch = 16)
       abline(h=1,lty=2)
       legend("topright",legend=bquote("point estimate" ~ hat(tau) * "," ~ .(midorend)),
         col="black", pch=16)
    }   
    if(!is.null(ptwise.CI)){
      ylimrange = range(c(x$tau.pt.est,ptwise.CI$ci.low,ptwise.CI$ci.high), na.rm = TRUE)
      plot(x = r.end, y = x$tau.pt.est, xlim=xlim, 
           ylim=ylimrange+diff(ylimrange)*c(-0.05,0.05),
           cex.axis=1,col="black", xlab=xlab, ylab="Tau", 
           cex.main=1, lwd=2, type="p", las=1, cex.axis=1, xaxs = "i", yaxs = "i", pch = 16)
      arrows(r.end, ptwise.CI$ci.low, r.end, ptwise.CI$ci.high, length = 0.04, angle = 90, code = 3)
      abline(h=1,lty=2)
      legend("topright",legend=bquote("point estimate" ~ hat(tau) * "," ~ .(midorend)),
        col="black", pch=16)
    }
  }
  
  if(!is.null(GET.res)){
  permutations = dim(GET.res[[2]])[1]
  plot(NULL, xlim = c(0,max(x$r, na.rm = TRUE)), ylim = c(min(GET.res[[1]]$lo, GET.res[[1]]$obs, na.rm = TRUE),max(GET.res[[1]]$hi, GET.res[[1]]$obs, na.rm = TRUE)), xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i",
       ylab = "Tau", xlab = xlab, lwd = 4, cex.lab = 1.5)
  for (i in 1:permutations) {
    lines(x$r, GET.res[[2]][i,], col = scales::alpha("grey", alpha = 0.3), lwd = 1)
  }
  yaxis.range = c(min(GET.res[[1]]$lo, GET.res[[1]]$obs, na.rm = TRUE),max(GET.res[[1]]$hi, GET.res[[1]]$obs, na.rm = TRUE))
  yaxis.lab = c(seq(yaxis.range[1],yaxis.range[2],length.out = 5),1)
  yaxis.lab = sort(yaxis.lab)
  yaxis.lab = round(yaxis.lab,digits = 1)
  yaxis.lab = unique(yaxis.lab) # prevents more than one 1.0 value
  yaxis.lab[which(yaxis.lab==1)] = round(yaxis.lab[which(yaxis.lab==1)],digits = 0)
  axis(2, las=1, at=yaxis.lab, labels = as.character(yaxis.lab), lwd = 1)
  lines(GET.res[[1]]$r, GET.res[[1]]$lo, col = "slategrey", lwd = 3)
  lines(GET.res[[1]]$r, GET.res[[1]]$hi, col = "slategrey", lwd = 3)
  lines(GET.res[[1]]$r, GET.res[[1]]$central, col = "red", lwd = 3)
  lines(GET.res[[1]]$r, GET.res[[1]]$obs, lwd = 3)
  axis(1, lwd = 1)
  abline(h=1, lty = 2, lwd = 3)
  legend("topright", legend=c(as.expression(bquote(~ hat(tau) ~ "point estimate")),
                              "95% global envelope",as.expression(bquote("simulations of " ~ H[0])),
                              "median simulation",
                              as.expression(bquote(~ tau == 1)) ),
         col=c("black", "slategrey", "grey", "red", "black"),
         lty=c(1,1,1,1,2), cex=1.05, yjust = 0.5, lwd = 6)
  par(xpd = TRUE)
  pint.lo = round(attr(GET.res[[1]],"p_interval"), digits = 3)[1]
  pint.hi = round(attr(GET.res[[1]],"p_interval"), digits = 3)[2]
  pint.x = 0.5 * max(x$r, na.rm = TRUE)
  pint.y = c(min(GET.res[[1]]$lo, GET.res[[1]]$obs, na.rm = TRUE),max(GET.res[[1]]$hi, GET.res[[1]]$obs, na.rm = TRUE))[1] + 0.5*diff(c(min(GET.res[[1]]$lo, GET.res[[1]]$obs, na.rm = TRUE),max(GET.res[[1]]$hi, GET.res[[1]]$obs, na.rm = TRUE)))
  text(bquote("p-value in [" ~ .(pint.lo) * "," * .(pint.hi) * "]"), x = pint.x, y = pint.y)
  }

  if(!is.null(d.param.est) & !is.null(tausim)){
    yaxis.range = c(min(x$tau.pt.est, tausim, na.rm = TRUE),max(x$tau.pt.est, tausim, 
    na.rm = TRUE))
    yaxis.lab = c(seq(yaxis.range[1],yaxis.range[2],length.out = 5),1)
    yaxis.lab = sort(yaxis.lab)
    yaxis.lab = round(yaxis.lab,digits = 1)
    yaxis.lab = unique(yaxis.lab) # prevents more than one 1.0 value
    yaxis.lab[which(yaxis.lab==1)] = round(yaxis.lab[which(yaxis.lab==1)],digits = 0)
    plot(NULL, xlim = xlim, ylim = yaxis.range, xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i",
    ylab = "", xlab = "")
    mtext("Tau", side=2, line=3, cex = 1.5)
    mtext(xlab, side=1, line=3, cex = 1.5)
    for (i in 1:dim(tausim)[1]) {
      lines(x$r, tausim[i,], col = scales::alpha("grey", alpha = 0.2), lwd = 4)
    }
    axis(2, las=1, at=yaxis.lab, labels = as.character(yaxis.lab), lwd = 1)
    axis(1, lwd = 1)
    lines(x = c(0,max(x$r, na.rm = TRUE)), y = c(1,1), lty = 2, lwd = 1) # as abline seems to overlap
    par(lend=1);
    lines(x = attr(d.param.est,"BCaCI"), y=c(1.03,1.03),
          type = "l", lwd = 20, col = "red")
    dintercept.ptest = median(d.param.est$envelope)
    lines(x=c(dintercept.ptest,dintercept.ptest), y = c(0.9,1.1), lwd = 4)
    lines(x$r, x$tau.pt.est, lwd = 4, col = "black")
    legend("topright",
           legend=c(as.expression(bquote(hat(tau) ~ "point estimate & " ~ hat(D) ~ "estimate")),
                    as.expression(bquote(underline(tau)^"*" ~ "bootstrap estimate (N=" ~ .(dim(tausim)[1]) * ")")),
                    as.expression(bquote("95% BCa CI of " ~ underline(D))),"tau = 1"), 
           col=c("black", "grey", "red", "black"),
           lty=c(1,1,1,2), lwd = c(2,2,10,1), pch = c(124,NA,NA,NA), cex=1.05, xjust = 1, yjust = 0.5)
  }
}

##' Optimized version of \code{get.tau} for typed data
##'
##' Version of th e \code{get.tau} function that is optimized for
##' statically typed data. That is data where we want the relationship between
##' points of type A and points of type B
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param comparison.type what type of points are included in the comparison set.
##' \itemize{
##'   \item "representative" if comparison set is representative of the underlying population
##'   \item "independent" if comparison set is cases/events coming from an indepedent process
##' }
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return data frame of tau values for all the distances
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_typed.R
##'

get.tau.typed <- function(posmat,
                          typeA = -1,
                          typeB = -1,
                          r=1,
                          r.low=rep(0,length(r)),
                          comparison.type = "representative",
                          data.frame=TRUE) {
     
     if (comparison.type == "representative") {
          comp.type.int <- 0
     } else if (comparison.type == "independent") {
          comp.type.int <- 1
     } else {
          stop("unknown comparison.type specified")
     }
     
     rc <- .C("get_tau_typed",
              as.integer(posmat[,"type"]),
              as.double(posmat[,"x"]),
              as.double(posmat[,"y"]),
              as.integer(nrow(posmat)),
              as.integer(typeA),
              as.integer(typeB),
              as.double(r.low),
              as.double(r),
              as.integer(length(r)),
              as.integer(1:nrow(posmat)),
              as.integer(comp.type.int),
              rc=double(length(r)))
     
     if (data.frame == FALSE) {
          return(rc)
     } else if (data.frame == TRUE) {
          return(data.frame(r.low=r.low, r=r, tau=rc$rc))
     }
}


##' Bootstrap confidence interval for the \code{get.tau} values
##'
##' Wrapper to \code{get.tau.bootstrap} that takes care of calulating
##' the confidence intervals based on the bootstrapped values.
##'
##' @param posmat a matrix appropriate for input to \code{get.tau}
##' @param fun a function appropriate as input to \code{get.pi}
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param boot.iter the number of bootstrap iterations
##' @param comparison.type the comparison type to pass to get.tau
##' @param ci.level significance level of the BCa CI, default = 0.95
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return a data frame with the point estimate of tau and its low and high confidence interval at each distance
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_ci.R
##'

get.tau.ci <- function(posmat,
                       fun,
                       r=1,
                       r.low=rep(0,length(r)),
                       boot.iter = 1000,
                       comparison.type = "representative",
                       ci.level = 0.95,
                       data.frame=TRUE) {
     
     boots <- get.tau.bootstrap(posmat, fun, r, r.low, boot.iter, comparison.type, 
                                data.frame = FALSE)
     rc <- apply(boots, 2, applyBCa, ci.level)
     
     if (data.frame == FALSE) {
          class(rc) <- "tauCI"
          return(rc)
     } else if (data.frame == TRUE) {
          rc = data.frame(r.low=r.low, r=r, pt.est=get.tau(posmat, fun, r, r.low)$tau, 
                  ci.low=rc[1,], ci.high=rc[2,])
          class(rc) <- "tauCI"
          return(rc)
     }
}


##' Bootstrap \code{get.tau} values.
##'
##' Runs \code{get.tau} on multiple bootstraps of the data. Is formulated
##' such that the relationship between points and themselves will not be
##' calculated
##'
##'
##' @param posmat a matrix appropriate for input to \code{get.tau}
##' @param fun a function appropriate as input to \code{get.pi}
##' @param r the series of spatial distances wer are interested in
##' @param r.low the low end of each range....0  by default
##' @param boot.iter the number of bootstrap iterations
##' @param comparison.type the comparison type to pass as input to \code{get.pi}
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return a matrix containing all bootstrapped values of tau for each distance interval
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_bootstrap.R
##'

get.tau.bootstrap <- function(posmat,
                              fun,
                              r=1,
                              r.low=rep(0,length(r)),
                              boot.iter,
                              comparison.type = "representative",
                              data.frame=TRUE) {

  xcol <- which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  if (comparison.type == "representative") {
    comp.type.int <- 0
  } else if (comparison.type == "independent") {
    comp.type.int <- 1
  } else {
    stop("unknown comparison type specified")
  }

  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .Call("get_tau",
                    posmat[inds,],
                    fun,
                    r,
                    r.low,
                    comp.type.int,
                    inds,
                    xcol,
                    ycol)
  }
  
  if (data.frame == FALSE) {
       class(rc) <- "taubstrap"
       return(rc)
  } else if (data.frame == TRUE) {
       rc = data.frame(r.low=r.low, r=r, t(rc))
       class(rc) <- "taubstrap"
       return(rc)
  }
}


##' runs bootstrapping for \code{get.tau.typed}
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param boot.iter the number of bootstrap iterations
##' @param comparison.type what type of points are included in the comparison set.
##' \itemize{
##'   \item "representative" if comparison set is representative of the underlying population
##'   \item "independent" if comparison set is cases/events coming from an independent process
##' }
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return tau values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_typed_bootstrap.R
##'

get.tau.typed.bootstrap <- function(posmat,
                                    typeA = -1,
                                    typeB = -1,
                                    r=1,
                                    r.low=rep(0,length(r)),
                                    boot.iter,
                                    comparison.type = "representative",
                                    data.frame=TRUE) {


  if (comparison.type == "representative") {
    comp.type.int <- 0
  } else if (comparison.type == "independent") {
    comp.type.int <- 1
  } else {
    stop("unknown comparison type specified")
  }

  rc <- matrix(nrow=boot.iter, ncol=length(r))
  for (i in 1:boot.iter) {
    inds <- sample(nrow(posmat), replace=T)
    rc[i,] <- .C("get_tau_typed",
                 as.integer(posmat[inds,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(inds),
                 as.integer(comp.type.int),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))  
  }
}


##' get the null distribution of the \code{get.tau} function
##'
##' Does permutations to calculate the null distribution of get pi
##' if there were no spatial dependence. Randomly reassigns coordinates
##' to each observation permutations times
##'
##' @param posmat a matrix appropriate for input to \code{get.tau}
##' @param fun a function appropriate for input to \code{get.tau}
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param comparison.type the comparison type to pass as input to \code{get.pi}
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return tau values for all the distances we looked at
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_permute.R
##'

get.tau.permute <- function(posmat,
                            fun,
                            r=1,
                            r.low=rep(0,length(r)),
                            permutations,
                            comparison.type = "representative",
                            data.frame=TRUE) {


  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  if (comparison.type == "representative") {
    comp.type.int <- 0
  } else if (comparison.type == "independent") {
    comp.type.int <- 1
  } else {
    stop("unknown comparison type specified")
  }

  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    tmp.posmat <- posmat
    tmp.posmat[,"x"] <- posmat[inds,"x"]
    tmp.posmat[,"y"] <- posmat[inds,"y"]
    rc[i,] <- .Call("get_tau",
                    tmp.posmat,
                    fun,
                    r,
                    r.low,
                    comp.type.int,
                    1:nrow(posmat),
                    xcol,
                    ycol)
  }

  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}


##' get the null distribution for the \code{get.tau.typed} function
##'
##'
##' @param posmat a matrix with columns type, x and y
##' @param typeA the "from" type that we are interested in, -1 is wildcard
##' @param typeB the "to" type that we are interested i, -1 is wildcard
##' @param r the series of spatial distances we are interested in
##' @param r.low the low end of each range....0  by default
##' @param permutations the number of permute iterations
##' @param comparison.type what type of points are included in the comparison set.
##' \itemize{
##'   \item "representative" if comparison set is representative of the underlying population
##'   \item "independent" if comparison set is cases/events coming from an indepedent process
##' }
##' @param data.frame logical indicating whether to return results as a data frame (default = TRUE)
##'
##' @return a matrix with permutation tau values for each distance specified
##'
##' @author Justin Lessler and Henrik Salje
##'
##' @family get.tau
##'
##' @example R/examples/get_tau_typed_permute.R
##'

get.tau.typed.permute <- function(posmat,
                                  typeA = -1,
                                  typeB = -1,
                                  r=1,
                                  r.low=rep(0,length(r)),
                                  permutations,
                                  comparison.type = "representative",
                                  data.frame=TRUE) {

  xcol <-  which(colnames(posmat)=="x")
  ycol <- which(colnames(posmat)=="y")

  #check that both columns exist
  if (length(xcol)!=1 & length(ycol)!=1) {
    stop("unique x and y columns must be defined")
  }

  if (comparison.type == "representative") {
    comp.type.int <- 0
  } else if (comparison.type == "independent") {
    comp.type.int <- 1
  } else {
    stop("unknown comparison type specified")
  }

  rc <- matrix(nrow=permutations, ncol=length(r))
  for (i in 1:permutations) {
    inds <- sample(nrow(posmat))#, replace=T)
    rc[i,] <- .C("get_tau_typed",
                 as.integer(posmat[,"type"]),
                 as.double(posmat[inds,"x"]),
                 as.double(posmat[inds,"y"]),
                 as.integer(nrow(posmat)),
                 as.integer(typeA),
                 as.integer(typeB),
                 as.double(r.low),
                 as.double(r),
                 as.integer(length(r)),
                 as.integer(1:nrow(posmat)),
                 as.integer(comp.type.int),
                 rc=double(length(r))
    )$rc
  }
  
  if (data.frame == FALSE) {
       return(rc)
  } else if (data.frame == TRUE) {
       return(data.frame(r.low=r.low, r=r, t(rc)))
  }
}

NULL

##' @name DengueSimR01
##' @title Simulated dataset of dengue transmission with basic reproductive number of 1
##' @format Matrix with five columns representing the X and Y coordinates of infected individuals, the time of infection, the genotype of the infecting pathogen and the serotype of the infecting pathogen.
##' @description Dataset simulated using an agent based model with a spatially heterogeneous population structure. Infectious agents were introduced resulting in agent to agent transmission. The distance between successive cases in a transmission chain were randomly drawn from a uniform distribution U(0,100). Each infectious agent resulted in a single transmission to another agent after a delay of 15 days, reflecting the generation time of dengue. There are 11 transmission chains, each with a different genotype. The genotypes are subdivided into four serotypes.
##' @docType data
##' @usage DengueSimulationR01
##' @author Justin Lessler and Henrik Salje

NULL

##' @name DengueSimR02
##' @title Simulated dataset of dengue cases with basic reproductive number of 2
##' @format Matrix with five columns representing the X and Y coordinates of infected individuals, the time of infection, the genotype of the infecting pathogen and the serotype of the infecting pathogen.
##' @description Dataset simulated using an agent based model with a spatially heterogeneous population structure. Infectious agents were introduced resulting in agent to agent transmission. The distance between successive cases in a transmission chain were randomly drawn from a uniform distribution U(0,100). Each infectious agent resulted in transmissions to two other agents after a delay of 15 days, reflecting the generation time of dengue. There are 11 transmission chains, each with a different genotype. The genotypes are subdivided into four serotypes.
##' @docType data
##' @usage DengueSimulationR02
##' @author Justin Lessler and Henrik Salje

NULL

##' @name DengueSimRepresentative
##' @title Simulated dataset of dengue cases with representative underlying population
##' @format Matrix with five columns representing the X and Y coordinates of infected individuals, the time of infection, the genotype of the infecting pathogen and the serotype of the infecting pathogen. Individuals representative from the underlying population have '-999'for time, genotype and serotype.
##' @description Dataset simulated using an agent based model with a spatially heterogeneous population structure. Infectious agents were introduced resulting in agent to agent transmission. The distance between successive cases in a transmission chain were randomly drawn from a uniform distribution U(0,100). Each infectious agent resulted in transmissions to two other agents after a delay of 15 days, reflecting the generation time of dengue. There are 11 transmission chains, each with a different genotype. The genotypes are subdivided into four serotypes. 500 randomly selected individuals from the underlying population also included.
##' @docType data
##' @usage DengueSimRepresentative
##' @author Justin Lessler and Henrik Salje

NULL


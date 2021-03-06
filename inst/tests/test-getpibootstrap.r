test_that("get.pi.bootstrap runs and returns 1 when it should", {

    x <- cbind(rep(c(1,2),50), x=runif(100,0,100), y=runif(100,0,100))

    colnames(x) <- c("type","x","y")

    test <- function(a,b) {return(1)}

    # should return a matrix of all ones
    res <- get.pi.bootstrap(x, test, seq(10,100,10), seq(0,90,10), 20)[,-(1:2)]
    expect_that(sum(res!=1),equals(0))
    expect_that(ncol(res),equals(20))
    
})

test_that("get.pi.ci returns bootstrap CIs when same seed", {
     
    x <- cbind(rep(c(1,2),50), x=runif(100,0,100), y=runif(100,0,100))

    colnames(x) <- c("type","x","y")

    test <- function(a,b) {
        if (a[1] != 1) return(3)
        if (b[1] == 2) return(1)
        return(2)
    }

    set.seed(787)
    res <- get.pi.bootstrap(x, test, seq(15,45,15), seq(0,30,15), 20)[,-(1:2)]

    set.seed(787)
    ci1 <- get.pi.ci(x, test, seq(15,45,15), seq(0,30,15), 20, ci.level = 0.95)[,4:5]

    expect_that(as.numeric(ci1[1,]), 
                equals(coxed::bca(as.numeric(res[1,]),conf.level = 0.95)))

    expect_that(as.numeric(ci1[2,]),
                equals(coxed::bca(as.numeric(res[2,]),conf.level = 0.95)))

    expect_that(as.numeric(ci1[3,]),
                equals(coxed::bca(as.numeric(res[3,]),conf.level = 0.95)))
    
})


test_that("performs correctly for test case 1 (equilateral triangle)", {
    x <- rbind(c(1,0,0), c(1,1,0),c(2,.5,sqrt(.75)))
    colnames(x) <-c("type","x","y")

    test <- function(a,b) {
        if (a[1] != 1) return(3)
        if (b[1] == 2) return(1)
        return(2)
    }

    res <- get.pi.bootstrap(x, test, 1.5, 0.1, 500)[,-(1:2)]
    res = res[!is.na(res)]
    res2 <- get.pi.typed.bootstrap(x, 1,2, 1.5, 0.1, 500)[,-(1:2)]
    res2 = res2[!is.na(res2)]
    
    #should have 95% CI of 0,1 and mean/median of 0.5
    expect_that(coxed::bca(res, conf.level = 0.95),
                equals(c(0,1)))
    expect_that(coxed::bca(res2, conf.level = 0.95),
                equals(c(0,1)))
})

test_that("performs correctly for test case 2 (points on a line)", {

    x <- rbind(c(1,0,0), c(2,1,0), c(2,-1,0), c(3,2,0),
             c(2,-2,0), c(3,3,0),c(3,-3,0))

    colnames(x) <- c("type","x","y")

    test <- function(a,b) {
        if (a[1] != 1) return(3)
        if (b[1] == 2) return(1)
        return(2)
    }

    #the medians for the null distribution should be 2,1,0
    res <- get.pi.bootstrap(x, test, c(1.5,2.5,3.5), c(0,1.5,2.5), 500)[,-(1:2)]
    res2 <- get.pi.typed.bootstrap(x, 1, 2, c(1.5,2.5,3.5), c(0,1.5,2.5), 500)[,-(1:2)]

    expect_that(median(as.numeric(res[1,]), na.rm=T), equals(1))
    expect_that(median(as.numeric(res[2,]), na.rm=T), equals(0.5))
    expect_that(median(as.numeric(res[3,]), na.rm=T), equals(0))

    expect_that(median(as.numeric(res2[1,]), na.rm=T), equals(1))
    expect_that(median(as.numeric(res2[2,]), na.rm=T), equals(0.5))
    expect_that(median(as.numeric(res2[3,]), na.rm=T), equals(0))

    # For the first and third ranges we use the quantile method as the BCa method breaks down for 
    # constant vectors of ones or zeroes
    
    #FIRST RANGE
    #deterministically 1
    
    expect_that(as.numeric(quantile(res[1,], probs=c(.025,.975), na.rm=T)),
                equals(c(1,1)))
    expect_that(as.numeric(quantile(res2[1,], probs=c(.025,.975), na.rm=T)),
                equals(c(1,1)))

    #SECOND RANGE...should be 0 and 1 respectively a fairly large % of the time
    res1.2 = na.omit(as.numeric(res[2,]))
    res2.2 = na.omit(as.numeric(res2[2,]))
    
    expect_that(coxed::bca(as.numeric(res1.2), conf.level = 0.95),
                equals(c(0,1)))
    expect_that(coxed::bca(as.numeric(res2.2), conf.level = 0.95),
                equals(c(0,1)))
    

    #THIRD RANGE
    #deterministically 0
    
    expect_that(as.numeric(quantile(res[3,], probs=c(.025,.975), na.rm=T)),
                equals(c(0,0)))
    expect_that(as.numeric(quantile(res2[3,], probs=c(.025,.975), na.rm=T)),
                equals(c(0,0)))

})



test_that ("fails nicely if x and y column names are not provided", {

    x<-cbind(rep(c(1,2),500), a=runif(1000,0,100), b=runif(1000,0,100))

    test <- function(a,b) {
        if (a[1] != 2) return(3)
        if (b[1] == 3) return(1)
        return(2)
    }

    expect_that(get.pi.bootstrap(x,test,seq(10,50,10), seq(0,40,10),100),
                throws_error("unique x and y columns must be defined"))

    expect_that(get.pi.ci(x,test,seq(10,50,10), seq(0,40,10),100),
                throws_error("unique x and y columns must be defined"))
})

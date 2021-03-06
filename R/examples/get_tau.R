\donttest{
# Load for all
r.max<-seq(20,1000,20)
r.min<-seq(0,980,20)
r.mid<-(r.max+r.min)/2
sero.type.func<-function(a,b,tlimit=20){
        if(a[5]==b[5]&(abs(a[3]-b[3])<=tlimit)){rc=1}
        else{rc=2}
        return(rc)
}
geno.type.func<-function(a,b,tlimit=20){
        if(a[4]==b[4]&(abs(a[3]-b[3])<=tlimit)){rc=1}
        else{rc=2}
        return(rc)
}

## R0 of 1        
data(DengueSimulationR01)
sero.tau.R01 <- get.tau(DengueSimR01, sero.type.func, r=r.max, r.low=r.min, 
                        comparison.type="independent")
geno.tau.R01 <- get.tau(DengueSimR01, geno.type.func, r=r.max, r.low=r.min, 
                        comparison.type="independent")

plot(r.mid,sero.tau.R01$tau,ylim=c(0.3,max(geno.tau.R01$tau)),log="y",
     cex.axis=1.25,col=rgb(t(col2rgb("blue")/255),alpha=0.6),
     xlab="Distance (m)",ylab="Tau",cex.main=0.9,lwd=2,type="l",las=1,cex.axis=0.75)
abline(h=1,lty=2)

abline(v=100,lty=1,lwd=2)
lines(r.mid,geno.tau.R01$tau,pch=20,col=rgb(t(col2rgb("dark green")/255),alpha=0.6),lwd=1)
lines(r.mid,sero.tau.representative$tau,pch=20,col=rgb(t(col2rgb("dark blue")/255),alpha=0.6),lty=2)
legend("topright",
       legend=c("Genotype",
                "Serotype",
                "Serotype (representative population)",
                "Maximum transmission distance"),
       lwd=1,col=c("dark green","blue","blue","black"),
       lty=c(1,1,2,1),bty="n")        
        
## R0 of 2
data(DengueSimulationR02)
sero.tau.R02 <- get.tau(DengueSimR02, sero.type.func, r=r.max, r.low=r.min, 
                        comparison.type="independent")
geno.tau.R02 <- get.tau(DengueSimR02, geno.type.func, r=r.max, r.low=r.min, 
                        comparison.type="independent") 

plot(r.mid,sero.tau.R02$tau,ylim=c(0.3,max(geno.tau.R02$tau.pt.est)),log="y",
     cex.axis=1.25,col=rgb(t(col2rgb("blue")/255),alpha=0.6),
     xlab="Distance (m)",ylab="Tau",cex.main=0.9,lwd=2,type="l",las=1,cex.axis=0.75)
abline(h=1,lty=2)
abline(v=100,lty=1,lwd=2)
lines(r.mid,geno.tau.R02$tau,pch=20,col=rgb(t(col2rgb("dark green")/255),alpha=0.6),lwd=1)
legend("topright",
       legend=c("Genotype",
                "Serotype",
                "Maximum transmission distance"),
       lwd=1,col=c("dark green","blue","black"),lty=1,bty="n")

## Obtaining a diagnostic plot using plot.tau() with pointwise CIs
data(DengueSimRepresentative)
sero.type.rep.func<-function(a,b,tlimit=20){
     if(a[5]==1&b[5]==1&(abs(a[3]-b[3])<=tlimit)){rc=1}
     else{if(a[5]==1&b[5]==-999){rc=2}else{rc=3}}
     return(rc)
}

# get point estimate
Dengue.tau = get.tau(DengueSimRepresentative, sero.type.rep.func, r.max, r.min, 
                     "representative", data.frame = TRUE)

# get 95% BCa CI
CIs = get.tau.ci(DengueSimRepresentative, sero.type.rep.func, r.max, r.min, 25, 
                 "representative", ci.level = 0.95, data.frame = TRUE)

#plot point estimate with CI
plot.tau(x = Dengue.tau, r.mid = TRUE, ptwise.CI = CIs)
}
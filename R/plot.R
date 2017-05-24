plotCoef <- function(beta,norm,lambda,df,dev,label=FALSE,
                     xvar=c("norm","lambda","dev"),
                     xlab=iname, ylab="Coefficients", ...){
  # as(x,"CsparseMatrix")
  # beta = as(res$beta,"sparseMatrix")
  # beta = res$beta
  # lambda = drop(res$x[,"Lambda"])
  # df = drop(res$x[,"Df"])
  # dev = drop(res$x[,"%Dev"])
  # xvar = "norm"
  # ===========================
  ##beta should be in "dgCMatrix" format
  ### bystep = FALSE means which variables were ever nonzero
  ### bystep = TRUE means which variables are nonzero for each step
  which=nonzeroCoef(beta, bystep = FALSE)
  nwhich=length(which)
  switch(nwhich+1,#we add one to make switch work
         "0"={
           warning("No plot produced since all coefficients zero")
           return()
         },
         "1"=warning("1 or less nonzero coefficients; glmnet plot is not meaningful")
  )
  beta=as.matrix(beta[which,,drop=FALSE])
  xvar=match.arg(xvar)
  switch(xvar,
         "norm"={
           index=if(missing(norm))apply(abs(beta),2,sum)else norm
           # index=apply(abs(beta),2,sum)
           iname="L1 Norm"
           approx.f=1
         },
         "lambda"={
           index=log(lambda)
           iname="Log Lambda"
           approx.f=0
         },
         "dev"= {
           index=dev
           iname="Fraction Deviance Explained"
           approx.f=1
         }
  )
  dotlist=list(...)
  type=dotlist$type
  if(is.null(type))
    matplot(index,t(beta),lty=1,xlab=xlab,ylab=ylab,type="l",...)
  else matplot(index,t(beta),lty=1,xlab=xlab,ylab=ylab,...)
  atdf=pretty(index)
  ### compute df by interpolating to df at next smaller lambda
  ### thanks to Yunyang Qian
  prettydf=approx(x=index,y=df,xout=atdf,rule=2,method="constant",f=approx.f)$y
  # prettydf=ceiling(approx(x=index,y=df,xout=atdf,rule=2)$y)
  axis(3,at=atdf,labels=prettydf,tcl=NA)
  if(label){
    nnz=length(which)
    xpos=max(index)
    pos=4
    if(xvar=="lambda"){
      xpos=min(index)
      pos=2
    }
    xpos=rep(xpos,nnz)
    ypos=beta[,ncol(beta)]
    text(xpos,ypos,paste(which),cex=.5,pos=pos)
  }

}


plotBIC <- function(object, sign.lambda, lambda.min, ...) {

  # object = res$x
  # sign.lambda = 1
  # lambda.min = res$lambda_min
  # ===============

  xlab="log(Lambda)"
  lambda_min <- drop(object[lambda.min,"Lambda"])
  if(sign.lambda<0) xlab=paste("-",xlab,sep="")
  plot.args=list(x=sign.lambda*log(drop(object[,"Lambda"])),
                 y=drop(object[,"BIC"]),
                 ylim=range(drop(object[,"BIC"])),
                 xlab=xlab,
                 ylab="BIC", type="n")
  new.args=list(...)
  if (length(new.args)) plot.args[names(new.args)]=new.args
  do.call("plot",plot.args)
  points(sign.lambda*log(drop(object[,"Lambda"])),
         drop(object[,"BIC"]),pch=20,col="red")
  axis(side=3,at=sign.lambda*log(drop(object[,"Lambda"])),
       labels=paste(drop(object[,"Df"])), tick=FALSE, line=0)
  abline(v=sign.lambda*log(lambda_min),lty=3)
  # abline(v=sign.lambda*log(.1605),lty=3)
  # abline(v=sign.lambda*log(cvobj$lambda.1se),lty=3)
  # invisible()
}
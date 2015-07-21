library(shiny)
library(ggplot2)
library(reshape2)
library(lubridate)
# read housing data
dat<-read.csv("housingData.csv")
dat$time<-ymd_hms(dat$time)
dat$priceMedian<-with(dat,(minPrices + maxPrices)/2)
dat<-dat[dat$time>as.POSIXct("2015-04-07 10:00:00"),]
# 
# function for calculating median home prices
medianPrice<-function(nHomes,datWide){
  nHomesCumulative<-cumsum(nHomes)
  medianDiff<-abs(nHomesCumulative - (max(nHomesCumulative,na.rm=T)/2))
  medianLoc<-medianDiff == min(medianDiff,na.rm=T)
  mean(datWide$priceMedian[medianLoc],na.rm=T)
}

# function for calculating mean home prices
meanPrice<-function(nHomes,datWide){
  sum(datWide$priceMedian*nHomes,na.rm=T)/sum(nHomes,na.rm=T)
}

shinyServer(
  function(input, output) {
    # reduce the data to a specific city
    datCity <- reactive({  
      dat[(dat$city == input$citySelect) & (dat$time > as.POSIXct(input$dates[1])) & (dat$time < as.POSIXct(input$dates[2])),]
    })
    
    # arrange data into columns of time
    datWide<-reactive({
      dcast(datCity(),minPrices + maxPrices + priceMedian + city ~ time,funaggregate=mean,value.var="nHomes")
    })

    # what are the timepoints?
    uTimes<-reactive({
      df<-unique(datCity()[,"time"])
      return(df)
    })
    
    metric<-reactive({
      if (input$metric=="Median") m<-"Median"
      if (input$metric=="Mean") m<-"Mean"
      return(m)
    })
    
    medianPrices<-reactive({    
      # which columns are date columns
      # determine which columns contain dates in the name
      nt<-grep("^[0-9]+",names(datWide()),value=T)
      dateCols<-is.element(names(datWide()),nt)
      datWideNHomes<-datWide()[,dateCols]
      
      # calculate the median home prices
      if (input$metric=="Median") {
        pricesOut<-apply(datWideNHomes,2,medianPrice,datWide=datWide())
      }
      if (input$metric=="Mean") {
        pricesOut<-apply(datWideNHomes,2,meanPrice,datWide=datWide())
      }
      return(pricesOut)
    })


    output$plot<-renderPlot({
      qplot(uTimes(),medianPrices(),xlab="Time",ylab=paste(metric(),"Home Price",sep=" "),main=input$citySelect) + geom_line()
    })
  }
)

# # arrange data into columns of time
# datCity$time<-ymd_hms(datCity$time)
# datWide<-reactive({
#   dcast(datCity,minPrices + maxPrices + priceMedian + city ~ time,funaggregate=mean,value.var="nHomes")
# })
# 
# # which columns are date columns
# # determine which columns contain dates in the name
# nt<-grep("^[0-9]+",names(datWide),value=T)
# dateCols<-is.element(names(datWide),nt)
# datWideNHomes<-datWide[,dateCols]
# 
# # calculate the median home prices
# medianPrices<-apply(datWideNHomes,2,medianPrice)
# 
# # establish dates of interest
# uTimes<-unique(datCity$time)



#     # plot the data
#     output$plot <- renderPlot({
#       q<-qplot(uTimes,medianPrices,xlab="Time",ylab = "Median Home Price",main=cityOI)
#       print(q)
#     })
#     output$plot<-renderPlot({
#       qplot(data=datCity(),x=time,y=nHomes)
#     })
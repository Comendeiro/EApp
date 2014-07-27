library(shiny)
library(zoo)
library(reshape)
library(ggplot2)

#Load the climate data

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  clim<-read.csv("helpers/climatedata.csv")
  cl<-melt(clim,by=c("city","type"))
  city<-unique(as.character(clim$city))
  cl$variable<-as.Date(as.POSIXct(as.yearmon(cl$variable,format="%b")))
  month <- as.Date(as.POSIXct(as.yearmon(names(clim)[3:14],format="%b")))
  
  # Calculate the building parameters
  #vol <- switch(input$floor * input$height)
  #Tin <- input$indoor.T
  #sur <- input$facade
  #u   <- input$uval
  

  output$t.city <- renderText({
      paste("You have selected the weather data of: ", city[as.numeric(input$cities)])
  })
  
  output$t.vol <- renderText({
      paste("The building volume is: ", (input$floor * input$height), " m^3.")
  })
  
  output$weather <- renderPlot({
      #ymini<-clim[clim$city == city[as.numeric(input$cities)],][1,3:14]
      #ymaxi<-clim[clim$city == city[as.numeric(input$cities)],][2,3:14]
      data<-cl[cl$city == city[as.numeric(input$cities)],]
            
      p<-qplot(variable,value,data=data,col=type,geom=c("line"))
      print(p)
      
  })
  
  output$fsurf <- renderText({
      paste("The building external surface is ",input$facade, " m, With a U-value of ",input$uval,
            " W/m^2-K, and the total thermal loss through the surface is ", input$facade * input$uval, "W/K")
  })
  
  output$heat <- renderPlot({
     deg<- input$indoor.T - clim[clim$city == city[as.numeric(input$cities)],][1,][3:14]
     Tdif<- rep(0,length(deg))
     for (i in 1:length(deg)){
       if (deg[i]>0){
         Tdif[i] <- deg[i]
       }
     }
     Tdif<-unlist(Tdif)
     cons<-Tdif * input$facade * input$uval * input$hours * 30/1000
     ach <- input$floor * input$height * input$ach * Tdif * 4.18*1.25/3600 * input$hours *30
     heating<-data.frame(month,ach,cons)
     kk<-melt(heating,id="month")
     
     l<-qplot(month,value,data=kk,col=variable,geom="line")
     print(l)
  })
  
})
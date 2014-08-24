library(shiny)
library(zoo)
library(reshape)
library(ggplot2)


#Load the climate data

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  clim<-read.csv("helpers/climatedata.csv")
  #clim <- data.frame(city=c("London","London","Madrid","Madrid","Moscow","Moscow"),type=c("min","max","min","max","min","max"),Jan=c(2.6,8.3,2.7,9.8,-9.1,-4.0),
   #                  Feb=c(2.4,8.5,3.7,12.0,-9.8,-3.7),Mar=c(4.1,1.4,6.2,16.3,-4.4,2.6),Apr=c(5.4,14.2,7.7,18.2,2.2,11.3),May=c(8.4,17.7,11.3,22.2,7.7,18.6),
    #                 Jun=c(11.5,20.7,16.1,28.2,12.1,22),Jul=c(13.9,23.2,19,32.1,14.4,24.3),Aug=c(13.7,22.9,18.8,31.3,12.5,21.9),Sep=c(11.2,20.1,15.4,26.4,7.4,15.7),
     #                Oct=c(8.3,15.6,10.7,19.4,2.7,8.7),Nov=c(5.1,11.4,6.3,13.5,-3.3,0.9),Dec=c(2.8,8.6,3.6,10,-7.6,-3))
  cl<-melt(clim,by=c("city","type"))
  city<-unique(as.character(clim$city))
  month <- seq(as.Date("2014-01-01"),as.Date("2014-12-01"),by="month")
  levels(cl$variable) <- month
  cl$variable <- as.Date(cl$variable)
  
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
  
  datas<- reactive({
    cl[cl$city == city[as.numeric(input$cities)],]
  })
  output$weather <- renderPlot({
      ymini<-clim[clim$city == city[as.numeric(input$cities)],][1,3:14]
      ymaxi<-clim[clim$city == city[as.numeric(input$cities)],][2,3:14]
    
  
     qplot(variable,value,data=datas(),col=type,geom=c("line","point")) + theme_bw()
     
      
  })
  

  
  output$fsurf <- renderText({
      paste("The building external surface is ",input$facade, " m, With a U-value of ",input$uval,
            " W/m^2-K, and the total thermal loss through the surface is ", input$facade * input$uval, "W/K")
  })
  dataheat <- reactive({
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
    melt(heating,id.vars="month")
  })
  
  output$heat <- renderPlot({

    qplot(month,value,data=dataheat(),col=variable,geom=c("point","line"))+ theme_bw() 
     
  })
  
})
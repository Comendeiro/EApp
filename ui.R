#ui.R 

library(shiny)
#Energy Application that estimates de energy consumption of a house in function of the location

#Load the climate data
clim<-read.csv("helpers/climatedata.csv")
city<-unique(as.character(clim$city))
cityindex<-list()
for (i in 1:length(city)){
  cityindex[i] = i
}
names(cityindex)<-city

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Energy consumption calculator"),
  
  # New fluid row
  fluidRow(
    h4("INSTRUCTIONS"),
    p("Welcome to this App created to estimate the energy consumption of a household with a known surface, height and facade area. The energy consumption of the buildings is highly worring nowadays
      and building lower consumption households is key to fight the climate change. In this app the effect of different building parameters
      can be studied for 3 differnt locations. When selecting the location the temperature profile will be updated for this place. The energy consumption per month
      is going to be calculated as a function of the building surface, exterior facade, volume and the expected usage hours per day. The user can choose the comfort temperature
       and the energy heating required to keep the building at that temperature will be calculated based on the input parameters.
       The results will be plotted separating the energy coming from ventilation (ACH) and the energy lost trhough the building envelope."),
    
    br(),
    
    h4("APP")
    ),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
       
        selectInput("cities", label = h5("City"),
        choices = cityindex, selected = 1),
    
        sliderInput("indoor.T",
                     label = h5("Indoor Temperature [C]"), min = 10, max = 30, step = 0.1,value = 20.5
                     ),
        
        sliderInput("floor",
                     label = h5("Floor surface [sqm]"), min = 10, max = 300, value = 80
        ),
        
        sliderInput("height",
                    label = h5("Average room heigth [m]"), min = 2, max = 6, value = 3,step=0.25
        ),
        
        sliderInput("facade",
                    label = h5("Total facade surface [sqm]"), min = 1, max = 600, value = 120,
        ),
        
        br(),
        
        sliderInput("hours",
                    label = h5("Daily usage hours"), min = 0, max = 24, value = 10),
        
        sliderInput("ach",
                    label = h5("Air change rate per hour"), min = 0, max = 12, value = 2),
        
        h5("Building U-value[W/sqm-C]"),
        
        sliderInput("uval", label=p(),
                    min = 0.01, max = 4, step= 0.01,value = 1,),
        
        p("The building average U-value is the average energy transmission per square meter and degree difference, as a reference
          this paramater ranges between 0.8 and 2 in most of UK dwelling stock. Higher values mean higher energy transmissions hence higher 
          energy losses. Passive buildings can attain values lower than 0.15, and decreasing the U-value below 0.1 requires more than 25cm of
          and insulating material. A facade comprised of two layers of brick with an air chamber with 5cm of insulation inside would have an
          U-value ranging from 0.7-1.4")
        

        
       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      textOutput("t.city"),
      plotOutput("weather"),
      textOutput("t.vol"),
      textOutput("fsurf"),
      plotOutput("heat")
      
    )
  )
))
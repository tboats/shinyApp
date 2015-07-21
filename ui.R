library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("SF Bay Area Mean 3-Bed 2-Bath Housing Prices"),
  sidebarPanel(
      selectInput("citySelect",label=h4("Select a city"),choices = list("Alameda","Campbell","Mountain View","Oakland","Palo Alto","Pleasanton","San Francisco","San Jose","Santa Clara","Saratoga","Sunnyvale"),selected="San Francisco"),
      #textInput(inputId="text2", label = "Input Text2"),
      #sliderInput("slider2", "", min = as.POSIXct("2015-04-07 10:00:00"), max = as.POSIXct("2015-07-12 10:00:00"), value = c(as.POSIXct("2015-04-07 10:00:00"), as.POSIXct("2015-07-12 10:00:00")))
      #sliderInput("date slider", "", min = 0, max = 100, value = c(0, 100)),
      dateRangeInput("dates", label = h3("Date range"),start="2015-04-10",end="2015-07-12"),
      #actionButton("goButton", "Go!")
      radioButtons("metric",label = h3("Housing Price Metric"),choices=list("Mean","Median"),selected="Mean")
  ),
  mainPanel(
    plotOutput("plot"),
    h4("Documentation"),
    helpText("This application gives the user a method of viewing housing price trends over a customized range of dates.
             There are 3 user inputs for this application: selection of a city, range of dates, and mean/median price metric.
             The application recomputes the mean/median house price for each date depending on the user selections.
             All prices are for 3 bedroom, 2 bath homes.  The data have been obtained from online real estate websites from 04/10/15 to 07/12/15.")
    )
))
#list("San Jose","San Francisco")
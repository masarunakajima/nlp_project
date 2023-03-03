#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(sbo)

load("./4-gram_100.rda")
p <- sbo_predictor(t)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  #output$text <- renderText({ input$input_text })
  df <- eventReactive(input$suggest, {

    prediction <- predict(p, input$input_text)
    data.frame(Prediction = prediction)
  }, ignoreInit = T)
  output$table <- renderTable( {
    df()
  })
  # output$pred2 <- renderText( {
  #   prediction[2]
  # })
  # output$pred3 <- renderText( {
  #   prediction[3]
  # })


  # output$distPlot <- renderPlot({
  #
  #   # generate bins based on input$bins from ui.R
  #   x    <- faithful[, 2]
  #   bins <- seq(min(x), max(x), length.out = input$bins + 1)
  #
  #   # draw the histogram with the specified number of bins
  #   hist(x, breaks = bins, col = 'darkgray', border = 'white')
  #
  # })

})

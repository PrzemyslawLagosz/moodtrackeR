library(shiny)
sampleUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("elo"), "ELO"),
    actionButton(ns("button"), "Button"),
    #textOutput(ns("out"))
  )
}
sampleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    #tekst <- eventReactive(input$button, input$elo)
    #output$out <- renderText(tekst())
    
    observeEvent(input$button, {
      message("click")
      updateTextInput(session = session, "elo", value = "kupa")
    })
})
}

ui <- fluidPage(
  sampleUI("kupa")
)

server <- function(input, output, session) {
  sampleServer("kupa")
}



shinyApp(ui, server)
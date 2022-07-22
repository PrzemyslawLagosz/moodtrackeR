library(shiny)

firstUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("update"), "Update 1st and 2nd module"),
    textInput(ns("first"), "Update me pls1", value = "Clear me!")
    
  )
}
firstServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$update, {
      updateTextInput(session = session, "first", value = "")
      updateTextInput(session = session,"second", value = "")
    })
})
}
secondUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("second"), "Update me pls", value = "Clear me!")
  )
}
secondServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$update, {
      updateTextInput(session = session, "first", value = "")
      updateTextInput(session = session,"second", value = "")
    })
})
}

ui <- fluidPage(
  firstUI("module_one"),
  secondUI("module_two")
)

server <- function(input, output, session) {
  firstServer("module_one")
  secondServer("module_two")
}

shinyApp(ui, server)
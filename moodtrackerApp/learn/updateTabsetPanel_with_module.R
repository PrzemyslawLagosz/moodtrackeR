library(shiny)

mod_ui <- function(id){
  ns <- NS(id)
  tagList(
    actionButton(ns("back"), "back")
  )
}

mod_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$back, {
      updateTabsetPanel(inputId = "tabs", selected = "home")
    })
})
}

ui <- navbarPage(
  "example",
  id = "tabs",
  tabPanel(
    "home",
    h4("updateTabsetPanel does not work with modules"),
    h5("But the button below does"),
    actionButton("switch", "switch")
  ),
  tabPanel(
    "secondtab",
    mod_ui("second")
  )
)

server <- function(input, output, session){
  mod_Server("second")
  observeEvent(input$switch, {
    updateTabsetPanel(session = session, inputId = "tabs", selected = "secondtab")
  })
}

shinyApp(ui, server)

    
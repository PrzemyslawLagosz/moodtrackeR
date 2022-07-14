library(shiny)

demoUI <- function(id){
  
  tabsetPanel(
    id = NS(id, "navigation"),
    type = "hidden",
    
    tabPanelBody(
      value = "main_panel",
      actionButton(NS(id, "info_nav"), "Get info") # Pressing this button should take user to info_panel
    ),
    
    tabPanelBody(
      value = "info_panel",
      actionButton(NS(id, "main_nav"), "Back to main page")
    )
  )
  
}

demoServer <- function(id){
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$info_nav, {
      updateTabsetPanel(
        inputId = "navigation",
        selected = "info_panel"
      )
    })
    
    observeEvent(input$main_nav, {
      updateTabsetPanel(
        inputId = "navigation",
        selected = "main_panel"
      )
    })
    
  })
}


ui <- fluidPage(
  demoUI("test")
)

server <- function(input, output, session) {
  demoServer("test")
}

shinyApp(ui, server)

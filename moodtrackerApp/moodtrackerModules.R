source("moodtrackerHelpers.R")

loginPageUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
        column(4),
        column(4,
               tags$div(
                 class = "well",
                 textInput(ns("username"), "User name:", placeholder = "Your username", value = ""),
                 passwordInput(ns("password"), "Password:", placeholder = "Password", value = ""),
                 fluidRow(
                   column(6, align="left", actionButton(ns("register"), "Register")),
                   column(6, align="right", actionButton(ns("login"), "Login"))
                 )
               )),
        column(4)
      )
  )
}

loginPageServer <- function(id, parent_session) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$login, {
      exist <- reactive(FALSE)
      # Vaidation login_page
      if (exist() == TRUE){
        hideFeedback("username")
        hideFeedback("password")
        showToast("success", "You loged in succesfully!", .options = myToastOptions)
        updateTextAreaInput(inputId = "comment", value = "")
        updateTextAreaInput(inputId = "important_comment", value = "")

        switch_page("main_page")
      } else {
        showFeedbackDanger("username", "")
        showFeedbackDanger("password", "Wrong username or password")
      }
    })
    
    # Register Button - login_page
    observeEvent(input$register, {
      message("click")
      #clear inputs
      # updateTextInput(inputId = "username_register", value = "")
      # updateTextInput(inputId = "password1", value = "")
      # updateTextInput(inputId = "password2", value = "")
      updateTabsetPanel(session = parent_session, inputId = "wizard", selected = "register_page")
      #switch_page("register_page")
    })
    
})
}


registerPageUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(4),
      column(4,
             tags$div(
               class = "well",
               textInput(ns("username_register"), "User name:", placeholder = "Your username"),
               textInput(ns("password1"), "Password:", placeholder = "Password"),
               textInput(ns("password2"), "Confirm password:", placeholder = "Confirm password"),
               fluidRow(
                 column(6, align="left", actionButton(ns("back"), "Back")),
                 column(6, align="right", actionButton(ns("register_confirm"), "Register"))
               )
             )),
      column(4)
    )
  )
}

registerPageServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
})
}
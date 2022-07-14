loginPageUI <- function(id) {
  ns <- NS(id)#
  tagList(
    logo_center <- fluidRow(column(4), column(4,  align="center", mood_logo_200), column(4)),
    
    login_page <-
      fluidRow(
        column(4),
        column(4,
               tags$div(
                 class = "well",
                 textInput("username", "User name:", placeholder = "Your username", value = ""),
                 passwordInput("password", "Password:", placeholder = "Password", value = ""),
                 textOutput("login_validation"),
                 fluidRow(
                   column(6, align="left", actionButton("register", "Register")),
                   column(6, align="right", actionButton("login", "Login"))
                 )
               )),
        column(4)
      )
  )
}

loginPageServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$login, {
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
    
})
}
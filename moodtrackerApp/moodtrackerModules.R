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

loginPageServer <- function(id, parent_session, passwords) {
  moduleServer(id, function(input, output, session) {
    
    user_password <- reactive({paste0(input$username, input$password)})
    exist <- reactive({user_password() %in% passwords()$user_pas})
    
    observeEvent(input$login, {
      # Vaidation login_page
      if (exist() == TRUE){
        hideFeedback("username")
        hideFeedback("password")
        showToast("success", "You loged in succesfully!", .options = myToastOptions)
        updateTextAreaInput(inputId = "comment", value = "")
        updateTextAreaInput(inputId = "important_comment", value = "")

        switch_page(session = parent_session, "main_page")
      } else {
        showFeedbackDanger("username", "")
        showFeedbackDanger("password", "Wrong username or password")
      }
    })
    
    # Register Button - login_page
    observeEvent(input$register, { 
      message("click")
      #clear inputs
      updateTextInput(inputId = "username_register", value = "")
      updateTextInput(inputId = "password1", value = "")
      updateTextInput(inputId = "password2", value = "")
      switch_page(session = parent_session, "register_page")
    })
    
    
    # user_password <- reactive({paste0(input$username, input$password)})
    # loged_user_id <- reactive(which(passwords()$user_pas == user_password()))
    # 
    # return(loged_user_id)
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

registerPageServer <- function(id, parent_session, passwords, cache) {
  moduleServer(id, function(input, output, session) {
    
    #Are passwords the same? - condition
    same <- reactive(input$password1 == input$password2)
    
    # Are the passwords the same - register_page
    observeEvent(eventExpr = {
      input$password1 
      input$password2
    }, {
      req(input$password1, input$password2)
      if (same() == FALSE) {
        showFeedbackWarning("password1", "")
        showFeedbackWarning("password2", "Passwords are not the same!")
      } else {
        hideFeedback("password1")
        hideFeedback("password2")
      }
    })
    
    # Is username already taken - condition - register_page
    is_taken <- reactive(input$username_register %in% passwords()$username)
    
    # Is username already taken - validation - register_page
    observeEvent(input$username_register, {
      if (is_taken() == TRUE) {
        showFeedbackWarning("username_register", "This username is already taken!")
      } else {
        hideFeedback("username_register")
      }
    })
    
    # Disable register_confirm button
    observeEvent({
      input$username_register
      input$password1
      input$password2
    }, {
      
      if (input$username_register == "" | input$password1 == "" | input$password2 == "" | is_taken() == TRUE) {
        shinyjs::disable("register_confirm")
      } else {
        shinyjs::enable("register_confirm")
      }
    })
    
    # Back button - register_page
    observeEvent(input$back, {
      
      # Clear inputs
      updateTextInput(inputId = "username", value = "")
      updateTextInput(inputId = "password", value = "")
      
      # Clear previou feedback
      hideFeedback("username")
      hideFeedback("password")
      
      switch_page(session = parent_session, "login_page")
    })
    
    # Register button - register_page
    observeEvent(input$register_confirm, {
      
      # Clear inputs
      updateTextInput(inputId = "username", value = "")
      updateTextInput(inputId = "password", value = "")
      
      # Clear previous feedback
      hideFeedback("username")
      hideFeedback("password")
      
      if (same() == TRUE & is_taken() != TRUE & input$username_register != "" & input$password1 != "" & input$password2 != "") {
        showToast("success", "You registered succesfully!", .options = myToastOptions)
        
        # Adding new registered user to saved_passwords
        new_user <- new_user_row(input$username_register, input$password1)
        passwords(rbind(passwords(), new_user))
        write_csv(passwords(), saved_passwords_file_location)
        
        # Adding new registered user to users_list
        ## user_password_registered <- isolate({paste0(input$username_register, input$password1)}) # <- would like to add this as a name of DF inside new_registered_user list.
        new_registered_user <- list(data.frame(date = c(as.Date(today())),
                                               rate = 0,
                                               day_comment = ""))
        
        cache$saved_users <- append(cache$saved_users, new_registered_user)
        
        saveRDS(cache$saved_users, saved_users_list_file_location)
        
        switch_page(session = parent_session, "login_page")
      } else {
        NULL
      }
    })
})
}



mainPageUI <- function(id) {
  ns <- NS(id)
  tagList(
    logo_top_left <- fluidRow(column(4,  align="left", mood_logo_150), 
                              column(4),
                              column(2),
                              column(2, 
                                     tags$div(
                                       class = "well",
                                       align="right", actionButton(ns("logout"), "Log Out"))
                              )
    ),
    sidebarLayout(
      sidebarPanel(
        sliderInput(ns("day_rate"), "Rate your day", min = 0, max = 10, value = 5, step = 0.5),
        dateInput(ns("date"), "Pick a date"),
        textAreaInput(ns("comment"), "Comment", placeholder = "Add a description (OPTIONAL)"),
        fluidRow(
          column(6, align="left", actionButton(ns("important_btn"), "Important event")),
          column(6, align="right", actionButton(ns("add_btn"), "Add"))
        ),
        hidden(dateInput(ns("important_date"), "Pick a date")),
        hidden(textAreaInput(ns("important_comment"), "Comment", placeholder = "Add a description (OPTIONAL)")),
        hidden(actionButton(ns("add_important_btn"), "Add important event"))
        
      ),
      mainPanel(
        plotlyOutput(ns("humor_plot"))
        ,tableOutput(ns("test_table"))
      )
    )
  )
}

mainPageServer <- function(id, parent_session, passwords, cache, loged_user_id) {
  moduleServer(id, function(input, output, session) {
    
    # loged_user_id <- reactive(which(passwords()$user_pas == user_password()))
    # user_password <- reactive({paste0(input$username, input$password)})
    
    # Logout Button - main_page
    observeEvent(input$logout, {
      message("click")
      # Clear inputs
      updateTextInput(inputId = "username", value = "")
      updateTextInput(inputId = "password", value = "")
      
      # Clear previous feedback
      hideFeedback("username")
      hideFeedback("password")
      
      switch_page(session = parent_session, "login_page")
    })
    
    # Important Button - main_page (show / hide)
    observeEvent(input$important_btn, {
      message(loged_user_id())
      if(input$important_btn %% 2 == 0){
        shinyjs::hide(id = "important_date")
        shinyjs::hide(id = "important_comment")
        shinyjs::hide(id = "add_important_btn")
      }else{
        shinyjs::show(id = "important_date")
        shinyjs::show(id = "important_comment")
        shinyjs::show(id = "add_important_btn")
      }
      
    })
    
    # Add button - main_page
    new_day_rate <- reactive(
      data.frame(
        date = input$date,
        rate = input$day_rate,
        day_comment = input$comment)
    )
    
    observeEvent(input$add_btn, {
      date_column_length <- length(cache$saved_users[[loged_user_id()]]$date)
      day_rate_already_exists <- (input$date %in% cache$saved_users[[loged_user_id()]]$date)
      
      # 1st if for first time logged in users
      if (day_rate_already_exists == TRUE & date_column_length == 1){
        cache$saved_users[[loged_user_id()]][cache$saved_users[[loged_user_id()]]$date == input$date, ] <- new_day_rate()
        saveRDS(cache$saved_users, saved_users_list_file_location)
        updateTextAreaInput(inputId = "comment", value = "")
      } else if (day_rate_already_exists == TRUE) {
        showModal(modal_confirm)
      } else {
        cache$saved_users[[loged_user_id()]] <- rbind(cache$saved_users[[loged_user_id()]], new_day_rate())
        saveRDS(cache$saved_users, saved_users_list_file_location)
        updateTextAreaInput(inputId = "comment", value = "")
      }
    })
    
    # Modal - login_page - ok_modal_btn
    observeEvent(input$ok_modal_btn, {
      # It checks which row in DF$date evaluate to currently choosen date, and replace after confirmation
      cache$saved_users[[loged_user_id()]][cache$saved_users[[loged_user_id()]]$date == input$date, ] <- new_day_rate()
      saveRDS(cache$saved_users, saved_users_list_file_location)
      removeModal()
      updateTextAreaInput(inputId = "comment", value = "")
      #browser()
    })
    # Modal - login_page - cancel_modal_btn
    observeEvent(input$cancel_modal_btn, {
      removeModal()
    })
})
}
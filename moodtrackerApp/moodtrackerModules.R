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
    
    
    observeEvent(input$login, {
      
    user_pas <- get_user_pas_from_DB()
    user_password <- reactive({paste0(input$username, input$password)})
    exist <- reactive({user_password() %in% user_pas})
    
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
      #clear inputs
      updateTextInput(inputId = "username_register", value = "")
      updateTextInput(inputId = "password1", value = "")
      updateTextInput(inputId = "password2", value = "")
      switch_page(session = parent_session, "register_page")
    })
    
    loged_user_username <- reactive(input$username)

    return(loged_user_username)
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
    takenUsernames <- get_usernames_from_DB()
    is_taken <- reactive(input$username_register %in% takenUsernames)
    
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
        
        # inserting new user to DataBase
        c("username", "password", "user_pas")
        new_user <- c(input$username_register, input$password1, paste0(input$username_register, input$password1))
        insert_new_user_into_DB(new_user)
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

mainPageServer <- function(id, parent_session, passwords, cache, loged_user_username) {
  moduleServer(id, function(input, output, session) {
    
    modal_confirm <- function() {
      # https://stackoverflow.com/questions/48127459/using-modal-window-in-shiny-module
      ns <- session$ns
      modalDialog(
        "Are you sure you want to override this day?",
        title = "This day is already reated",
        footer = tagList(
          actionButton(ns("cancel_modal_btn"), "Cancel"),
          actionButton(ns("ok_modal_btn"), "Override it", class = "btn btn-primary")
        ),
        easyClose = TRUE
      )
    }
    
    # Logout Button - main_page
    observeEvent(input$logout, {
      # Clear inputs
      updateTextInput(inputId = "username", value = "")    ### DOESN"T WORK
      updateTextInput(inputId = "password", value = "")
      
      # Clear previous feedback
      hideFeedback("username")
      hideFeedback("password")
      
      switch_page(session = parent_session, "login_page")
    })
    
    # Important Button - main_page (show / hide)
    observeEvent(input$important_btn, {
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
  
    observeEvent(input$add_btn, {
      
      myDate <- as.character(input$date)
      new_day_rate <- reactive(c(loged_user_username(), myDate, input$day_rate, input$comment))
      
      userData <- get_posts_from_DB(as.character(loged_user_username()))
      day_rate_already_exists <- (as.character(input$date) %in% userData[ ,"date"])
      
      if (day_rate_already_exists == TRUE) {
          showModal(modal_confirm())
        } else {
          insert_new_post_into_DB(new_day_rate)
          updateTextAreaInput(inputId = "comment", value = "")
        }
    })
    
    # Modal - login_page - ok_modal_btn
    observeEvent(input$ok_modal_btn, {
      override_rated_day_DB(day_rate = input$day_rate, 
                            comment = input$comment, 
                            loged_user_username = loged_user_username(), 
                            date = input$date)
      removeModal()
      updateTextAreaInput(inputId = "comment", value = "")
      
    })
    # Modal - login_page - cancel_modal_btn
    observeEvent(input$cancel_modal_btn, {
      removeModal()
    })
    
    # Humor plot
    output$humor_plot <- renderPlotly({
      input$add_btn
      input$ok_modal_btn
      userData <- get_posts_from_DB(as.character(loged_user_username()))
      ggplotly(
        ggplot(data = userData, aes(x = date, y = rate, label = comment, color = rate)) +
          geom_point() +
          ylim(c(0,10)) +
          ggtitle("Moodtracker Plot")+
          labs(x = element_blank(),
               y= element_blank()) +
          theme(axis.text.x=element_text(angle=50, vjust=0.5),
                plot.title = element_text(hjust = 0.5,  margin = margin(0, 0, 10, 0)),
                panel.background = element_blank(),
                panel.grid.major.y = element_line(colour = "grey75"),
                legend.position = "none"
          ) +
          scale_color_gradient(low="#393B57", high="#47A5CB")
      )
    })
})
}
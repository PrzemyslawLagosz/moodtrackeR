switch_page <- function(page) {
  updateTabsetPanel(inputId = "wizard", selected = page)
}

myToastOptions <- list(
  positionClass = "toast-top-right",
  progressBar = FALSE,
  timeOut = 3000,
  closeButton = TRUE,
  
  # same as defaults
  newestOnTop = TRUE,
  preventDuplicates = FALSE,
  showDuration = 300,
  hideDuration = 1000,
  extendedTimeOut = 1000,
  showEasing = "linear",
  hideEasing = "linear",
  showMethod = "fadeIn",
  hideMethod = "fadeOut"
)

mood_logo_200 <- tags$a(tags$img(src = "mood_logo.png", height = "200", width = "200"))
mood_logo_150 <- tags$a(tags$img(src = "mood_logo.png", height = "150", width = "150"))

modal_confirm <- modalDialog(
  "Are you sure you want to override this day?",
  title = "This day is already reated",
  footer = tagList(
    actionButton("cancel_modal_btn", "Cancel"),
    actionButton("ok_modal_btn", "Override it", class = "btn btn-primary")
  )
)

logo_center <- fluidRow(column(4), column(4,  align="center", mood_logo_200), column(4))

logo_top_left <- fluidRow(column(4,  align="left", mood_logo_150), 
                          column(4),
                          column(2),
                          column(2, 
                                 tags$div(
                                   class = "well",
                                   align="right", actionButton("logout", "Log Out"))
                          )
)
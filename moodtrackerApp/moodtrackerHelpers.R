switch_page <- function(page, session) {
  updateTabsetPanel(session, inputId = "wizard", selected = page)
}

new_user_row <- function(username, password) {
  newUserRow <- c(username, password, paste0(username, password))
}

sqlitePath <- "users.db" #non-relative PATH to DataBase
tableUsers <- "users"
tablePosts <- "posts"

get_user_pas_from_DB <- function() {
  #Get user_pas from DB.
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT user_pas FROM %s", tableUsers)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  user_pas <- data[,]
  dbDisconnect(db)
  user_pas
}

get_posts_from_DB <- function(username) {
  #Get user_pas from DB.
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s WHERE username = '%s'", tablePosts, username)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  posts <- data[,]
  dbDisconnect(db)
  posts
}

get_usernames_from_DB <- function() {
  #Get user_pas from DB.
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT username FROM %s", tableUsers)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  username <- data[,]
  dbDisconnect(db)
  username
}

insert_new_user_into_DB <- function(new_user) {
  fields <- c("username", "password", "user_pas")
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    tableUsers, 
    paste(fields, collapse = ", "),
    paste(new_user, collapse = "', '")
  )
  dbExecute(db, query)
  dbDisconnect(db)
}

insert_new_post_into_DB <- function(new_day_rate) {
  fields <- c("username", "date", "rate", "comment")
  
  db <- dbConnect(SQLite(), sqlitePath)
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    tablePosts,
    paste(fields, collapse = ", "),
    paste(new_day(), collapse = "', '")
  )
  dbExecute(db, query)
  dbDisconnect(db)
}

override_rated_day_DB <- function(day_rate, comment, loged_user_username, date) {
  db <- dbConnect(SQLite(), sqlitePath)
  query <- sprintf(
    "UPDATE %s SET rate = '%s', comment = '%s' WHERE username = '%s' AND date = '%s'",
    tablePosts,
    day_rate,
    comment,
    loged_user_username,
    date)
  dbExecute(db, query)
  dbDisconnect(db)
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

modal_confirm <- function() {
  ns <- parent_session$ns
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
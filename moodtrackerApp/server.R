server <- function(input, output, session) {
  
  passwords <- reactiveVal(saved_passwords)
  cache <- reactiveValues(saved_users = saved_users_list)
  loged_user_id <- loginPageServer("loginPage", parent_session = session, passwords = passwords)
  
  loginPageServer("loginPage",       parent_session = session, passwords = passwords)
  registerPageServer("registerPage", parent_session = session, passwords = passwords, cache = cache)
  mainPageServer("mainPage",         parent_session = session, passwords = passwords, cache = cache, loged_user_id = loged_user_id)
}
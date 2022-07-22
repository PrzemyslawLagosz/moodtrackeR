server <- function(input, output, session) {
  
  loged_user_username <- loginPageServer("loginPage", parent_session = session, passwords = passwords)
  
  loginPageServer("loginPage",       parent_session = session, passwords = passwords)
  registerPageServer("registerPage", parent_session = session, passwords = passwords, cache = cache)
  mainPageServer("mainPage",         parent_session = session, passwords = passwords, cache = cache, loged_user_username = loged_user_username)
}
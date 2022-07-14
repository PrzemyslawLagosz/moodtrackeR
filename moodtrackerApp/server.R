server <- function(input, output, session) {
  
  loginPageServer("loginPage", parent_session = session)
  registerPageServer("registerPage")
}
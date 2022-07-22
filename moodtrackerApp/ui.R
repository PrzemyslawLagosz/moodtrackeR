#library(shiny)
library(tidyverse)
library(shinyFeedback)
library(shinyjs)
#library(shinydashboard)
#library(ggplot2)
library(plotly)
#library(lubridate)
library(RSQLite)
library(rsconnect)

source("moodtrackerModules.R")
source("moodtrackerHelpers.R")

ui <- fluidPage(
  useShinyjs(),
  shinyFeedback::useShinyFeedback(),
  tabsetPanel(
    id = "wizard",
    type = "hidden",
    tabPanel("login_page",
             logo_center,
             loginPageUI("loginPage")),
    
    tabPanel("main_page",
             mainPageUI("mainPage")),
    
    tabPanel("register_page",
             logo_center,
             registerPageUI("registerPage"))
  )
  
)
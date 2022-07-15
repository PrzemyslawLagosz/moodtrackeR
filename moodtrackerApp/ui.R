library(shiny)
library(tidyverse)
library(shinyFeedback)
library(shinyjs)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(lubridate)

source("moodtrackerModules.R")
source("moodtrackerHelpers.R")

ui <- fluidPage(
  useShinyjs(),
  shinyFeedback::useShinyFeedback(),
  tabsetPanel(
    id = "wizard",
    type = "tabs",
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
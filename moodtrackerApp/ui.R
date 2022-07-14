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
    type = "hidden",
    tabPanel("login_page",
             loginPageUI("loginPage"))
    # ,
    # 
    # tabPanel("main_page",
    #          logo_top_left,
    #          main_page),
    # 
    # tabPanel("register_page",
    #          logo_center,
    #          register_page)
  )
  
)
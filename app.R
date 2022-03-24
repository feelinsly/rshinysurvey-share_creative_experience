# This is a Shiny web application. 
##building upon:    http://shiny.rstudio.com/
#

#yea successfully launch survey on R Shiny app and connect with google drive! 01042022
#to do -- add drawing function potentially to the survey to enable drawing their emotions https://stackoverflow.com/questions/41701807/way-to-free-hand-draw-shapes-in-shiny
#to do -- set up daily /regular email notifications for users to fill out the esm survey

library(shiny)
library(shinysurveys)
library(dplyr)
library(tidyr)
library(tidyverse) # all purpose package

library(googledrive)
library(googlesheets4)
library("DT")

# rsconnect::deployApp('/Users/xiao/Documents/R_Shiny/ESM_Dec292021', appFiles = c("app.R", ".secrets"))

# #run this once to create the file
# googlesheets4::gs4_create(name = "esm_try", 
#                           # Create a sheet called main for all data to 
#                           # go to the same place
#                           sheets = "esm_01042022")


# designate project-specific cache
options(gargle_oath_cache = ".secrets",
        gargle_oauth_email = "liz.gexiao@gmail.com",
        gargle_oob_default = TRUE)
# Authorize googledrive
googledrive::drive_auth(email = "liz.gexiao@gmail.com", # Replace with your email!
                        cache = ".secrets",
                        use_oob = TRUE)

# Authorize googlesheets4
googlesheets4::gs4_auth(email = "liz.gexiao@gmail.com", # Replace with your email!
                        cache = ".secrets",
                        use_oob = TRUE)

# see your token file in the cache, if you like
# list.files(".secrets/")

# alternatively
# options(
#   # whenever there is one account token found, use the cached token
#   gargle_oauth_email = TRUE,
#   # specify auth tokens should be stored in a hidden directory ".secrets"
#   gargle_oauth_cache = ".secrets"
# )



# Get the ID of the sheet for writing programmatically
# This should be placed at the top of your shiny app
sheet_id <- googledrive::drive_get("creative_experience_try")$id

# 
# #store the results
# Results <- reactive(c(
#   input$subject_id, input$question_id, input$question_type, input$response, Sys.time()
# ))


# Set working directory
#https://github.com/feelinsly/online_files/blob/main/esm_xg_01042022.csv

survey_questions <- read_csv("http://web.stanford.edu/~xiaog/online_files/shareyourcreative_experience_xg_03242022.csv", 
                             col_types = cols(question = col_character(),
                                              option = col_character(),
                                              input_type = col_character(),
                                              input_id = col_character(),
                                              dependence = col_character(),
                                              dependence_value = col_character(),
                                              required = col_logical(),
                                              page = col_number()))

survey_questions<-tibble(survey_questions)


# # Register a "check" input type
# extendInputType("check", {
#   shiny::checkboxGroupInput(
#     inputId = surveyID(),
#     label = surveyLabel(),
#     choices = surveyOptions(), 
#   )
# })

ui <- fluidPage(
  surveyOutput(df = survey_questions,
               survey_title = "Share Your Creative Experience!",
               survey_description = "Are you curious to learn what it takes to generate good ideas and insights? Share with us your own creative experiences! Learn real stories from others!",
               theme = "#63B8FF")
)
#It also takes in a theme color to style your survey. 
#Typical names such as “red” or “blue” work, as well as hex color codes such as “#63B8FF” (the default theme). 
#Further documentation can be accessed by typing ?shinysurveys::surveyOutput() in the console.



#define shiny server
server <- function(input, output, session) {
  renderSurvey()
  
  observeEvent(input$submit, {
    response_data <- getSurveyData()
    response_data$respond_time <- Sys.time()
    
    # Read our sheet
    values <- read_sheet(ss = sheet_id, 
                         sheet = "share_creative")
    
    # Check to see if our sheet has any existing data.
    # If not, let's write to it and set up column names. 
    # Otherwise, let's append to it.
    
    if (nrow(values) == 0) {
      sheet_write(data = response_data,
                  ss = sheet_id,
                  sheet = "share_creative")
    } else {
      sheet_append(data = response_data,
                   ss = sheet_id,
                   sheet = "share_creative")
    }
    
    showModal(modalDialog(
      title = "Awesome! Thanks for sharing! Feel free share another creative experience!"))
  })
  
}    

#     
#     
#     
#        print(getSurveyData())
#     Data  <- Data %>% as.list() %>% data.frame()
#       sheet_append(Data, response_data)  
#     #This will add the new row at the bottom of the dataset in Google Sheets.
#   })
# }

#run shiny application
shinyApp(ui, server)




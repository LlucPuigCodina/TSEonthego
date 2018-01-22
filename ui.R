library(shiny)

# Define UI for application that draws a histogram
shinyUI(
        
        #Front page where the app is deployed ----
        navbarPage(title = "TSE on the go",
                   
                   
                   #Panel for Data Upload ----
                   tabPanel("Data",
                        
                      fluidPage( tabsetPanel(    
                        
                        #Inner Panel Upload File ----
                        tabPanel("Upload File",    
                            
                            # Sidebar layout with input and output definitions ----
                            sidebarLayout(
                                    
                                    # Sidebar panel for inputs ----
                                    sidebarPanel(
                                            
                                            # Input: Select a file ----
                                            fileInput("file1", "Choose CSV File",
                                                      multiple = FALSE,
                                                      accept = c("text/csv",
                                                                 "text/comma-separated-values,text/plain",
                                                                 ".csv")),
                                            
                                            # Text indicating file max. size ----
                                            helpText("Default max. file size is 30MB"),
                                            
                                            # Horizontal line ----
                                            tags$hr(),
                                            
                                            # Input: Checkbox if file has header ----
                                            checkboxInput("header", "Header", TRUE),

                                            # Horizontal line ----
                                            tags$hr(),
                                            
                                            # Input: Select number of rows to display ----
                                            radioButtons("disp", "Display",
                                                         choices = c(Head = "head",
                                                                     All = "all"),
                                                         selected = "head"),
                                            
                                            # Horizontal line ----
                                            tags$hr(),
                                            
                                            #Input: Data Frequency
                                            numericInput(inputId = "data.frequency", "Frequency", 
                                                         value = 12),
                                            
                                            # Split layout for date input ----
                                            splitLayout(
                                                
                                                #Input: Starting Year ----
                                                numericInput(inputId = "start.date.year", "Starting Year", 
                                                      value = 1949),
                                                
                                                #Input: Starting Month ----
                                                numericInput(inputId = "start.date.month", "Starting Month", 
                                                      value = 1),
                                                
                                                #Input: Starting Day ----
                                                numericInput(inputId = "start.date.day", "Starting Day", 
                                                          value = NULL)
                                            
                                            )
                                            
                                    ),
                                    
                                    # Main panel for displaying outputs ----
                                    mainPanel(
                                            
                                            # Output: Data file display ----
                                            tableOutput("contents")
                                            
                                    )
                                    
                            )#end sidebarlayout
                   ),#end Upload File
                   
                        #Inner How-to panel ----
                        tabPanel("How-to", 
                            
                            tags$head(
                              tags$link(rel = "stylesheet", type = "text/css", href = "appStyle.css")
                            ),
                            
                            
                            fluidPage(
                              div(id = "about", class = "card",  
                                  includeHTML("./Data.html"))
                            )
                        )#end How-to panel
                   
              ))#end inner Data panel
        ),#end Data panel
        
                   
        

        # ETS Panel ----
        tabPanel("ETS", 
                 
                 fluidPage( tabsetPanel(
                         
                         # Fit & Forecast Panel ----
                         tabPanel("Fit & Forecast",
                                  
                                  # Sidebar layout with input and output definitions ----
                                  sidebarLayout(
                                          # Sidebar panel for inputs ----
                                          sidebarPanel(
                                                  
                                                  # ETS Error Type ----
                                                  selectInput(inputId = "ets.error.type",
                                                              "Error type",
                                                              c("Aditive" = "A",
                                                                "Multiplicative" = "M"),
                                                              selected = "A"),
                                                  # ETS Trend Type ----
                                                  selectInput(inputId = "ets.trend.type",
                                                              "Trend type",
                                                              c("None" = "N",
                                                                "Aditive" = "A",
                                                                "Multiplicative" = "M"),
                                                              selected = "N"),
                                                  # ETS Season Type ----
                                                  selectInput(inputId = "ets.season.type",
                                                              "Season type",
                                                              c("None" = "N",
                                                                "Aditive" = "A",
                                                                "Multiplicative" = "M"),
                                                              selected = "A"),
                                                  
                                                  # Split inputs ----
                                                  splitLayout(  
                                                          #Input: forecast horizon ----
                                                          numericInput(inputId = "ets.horizon", 
                                                                       "Forecasts ahead", value = 12),
                                                          #Input: Plot Y axis ----      
                                                          textInput(inputId = "ets.Y.axis", "Y axis name", value = "USAccDeaths")),
                                                  
                                                  # Horizontal line ----
                                                  tags$hr(),
                                                  
                                                  # Warning prohibited combinations ----
                                                  helpText("CAUTION: Some combinations are not allowed, see How-to for more details. If a prohibited combination is picked, the model will be automatically estimated, without regard for the introduced specification."),
                                                  
                                                  
                                                  # Split inputs ----
                                                  splitLayout( 
                                                          # Button: Manual Forecast ----
                                                          actionButton(inputId = "ets.manual", "Fit & Forecast"),
                                                          #Button: Automatic Forecast ----     
                                                          actionButton(inputId = "ets.automatic", "Automatic"))
                                                  
                                          ), 
                                          # Main panel for displaying outputs ----
                                          mainPanel(
                                                  # Output: Plot ETS forecast ----
                                                  plotOutput("ets.plot"),
                                                  
                                                  # Output: Summary ETS model ----
                                                  verbatimTextOutput("summary.ets")
                                                  
                                          )                                                   
                                  )
                                  
                         ), 
                         
                         #Inner How-to panel ----
                         tabPanel("How-to", 
                                  
                                  tags$head(
                                          tags$link(rel = "stylesheet", type = "text/css", href = "appStyle.css")
                                  ),
                                  
                                  
                                  fluidPage(
                                          div(id = "about", class = "card",  
                                              includeHTML("./ES.html"))
                                  )
                                  
                         )#end How-to panel
                 ))#end inner data panel
                 
        ),# end ETS Panel     

        # ARIMA Panel ----
        tabPanel("ARIMA", 
                 
                 fluidPage( tabsetPanel(
                         
                         # Fit & Forecast Panel ----
                         tabPanel("Fit & Forecast",
                                  
                                  # Sidebar layout with input and output definitions ----
                                  sidebarLayout(
                                          # Sidebar panel for inputs ----
                                          sidebarPanel(
                                                  # Split inputs ----
                                                  splitLayout( 
                                                        #Input: p ----
                                                        numericInput(inputId = "arima.p", 
                                                                            label = "p", value = 2),
                                                        #Input: q ----
                                                        numericInput(inputId = "arima.q", 
                                                                            "q", value = 1)),
                                                  # Split inputs ----
                                                  splitLayout( 
                                                          #Input: d ----
                                                          numericInput(inputId = "arima.d", 
                                                                            "d", value = 1),
                                                          #Input: P ----     
                                                          numericInput(inputId = "arima.P", 
                                                                            "P", value = 0)),
                                                  # Split inputs ----
                                                  splitLayout( 
                                                          #Input: Q ----
                                                          numericInput(inputId = "arima.Q", 
                                                                            "Q", value = 1),
                                                          #Input: D ----
                                                          numericInput(inputId = "arima.D", 
                                                                            "D", value = 0)),
                                                  # Split inputs ----
                                                  splitLayout(  
                                                          #Input: forecast horizon ----
                                                          numericInput(inputId = "arima.horizon", 
                                                                             "Forecasts ahead", value = 12),
                                                          #Input: Plot Y axis ----      
                                                          textInput(inputId = "arima.Y.axis", "Y axis name", value = "AirPassengers")),
                                                  
                                                  # Split inputs ----
                                                  splitLayout( 
                                                          
                                                          # Button: Manual Forecast ----
                                                          actionButton(inputId = "fit.and.forecast", "Fit & Forecast"),
                                                          #Button: Automatic Forecast ----     
                                                          actionButton(inputId = "box.jenkins.method", "Box-Jenkins Method"))
                                                  
                                          ), 
                                          # Main panel for displaying outputs ----
                                          mainPanel(
                                                  # Output: Plot ARIMA forecast ----
                                                  plotOutput("arima.plot"),
                                                  
                                                  # Output: Summary ARIMA model ----
                                                  verbatimTextOutput("summary.arima")
                                                  
                                          )                                                   
                                  )
                                  
                         ), 
                         
                         #Inner How-to panel ----
                         tabPanel("How-to", 
                                  
                                  tags$head(
                                          tags$link(rel = "stylesheet", type = "text/css", href = "appStyle.css")
                                  ),
                                  
                                  
                                  fluidPage(
                                          div(id = "about", class = "card",  
                                              includeHTML("./ARIMA.html"))
                                  )
                                  
                         )#end How-to panel
                ))#end inner data panel
                 
        ),# end ARIMA Panel
        
        
        # About Panel ----
        tabPanel("About",
                 
                 tags$head(
                         tags$link(rel = "stylesheet", type = "text/css", href = "appStyle.css")
                 ),
                 
                 
                 fluidPage(
                         div(id = "about", class = "card",  
                             includeHTML("./about.html"))
                 )
                 
                 
        )#end About tab
        
))#end front app page

library(shiny)

# Packages ----
        library(ggplot2)
        library(forecast)

# new.plot function ----
new.plot <-function(forec.obj, data.color = 'black', fit.color = 'blue', forec.color = 'red',
                    lower.fill = 'orange', upper.fill = 'darkorange', format.date = F, yaxis = "Data")
{
        serie.orig = forec.obj$x
        serie.fit = forec.obj$fitted
        pi.strings = paste(forec.obj$level, '%', sep = '')
        
        if(format.date)
                dates = as.Date(time(serie.orig))
        else
                dates = time(serie.orig)
        
        serie.df = data.frame(date = dates, serie.orig = serie.orig, serie.fit = serie.fit)
        
        forec.M = cbind(forec.obj$mean, forec.obj$lower[, 1:2], forec.obj$upper[, 1:2])
        forec.df = as.data.frame(forec.M)
        colnames(forec.df) = c('forec.val', 'l0', 'l1', 'u0', 'u1')
        
        if(format.date)
                forec.df$date = as.Date(time(forec.obj$mean))
        else
                forec.df$date = time(forec.obj$mean)
        
        p = ggplot() + theme_minimal()  + xlab("") + ylab(yaxis) +
                geom_line(aes(date, serie.orig, colour = 'data'), data = serie.df) + 
                geom_line(aes(date, serie.fit, colour = 'fit'), data = serie.df) + 
                scale_y_continuous() +
                geom_ribbon(aes(x = date, ymin = l0, ymax = u0, fill = 'lower'), data = forec.df, alpha = I(0.4)) + 
                geom_ribbon(aes(x = date, ymin = l1, ymax = u1, fill = 'upper'), data = forec.df, alpha = I(0.3)) + 
                geom_line(aes(date, forec.val, colour = 'forecast'), data = forec.df) + 
                scale_color_manual('Series', values=c('data' = data.color, 'fit' = fit.color, 'forecast' = forec.color), labels = c("Original Data", "Fitted Values", "Forecast") ) + 
                scale_fill_manual('Confidence Interval', values=c('lower' = lower.fill, 'upper' = upper.fill), labels = pi.strings)
        
        if (format.date)
                p = p + scale_x_date()
        
        p
}




# shiny Server ----
shinyServer(function(input, output){
        
        # Maximum file size ----
        options(shiny.maxRequestSize=30*1024^2)
        
        # Read uploaded data file ----
        user.data <- reactive({
          
          # input$file1 will be NULL initially. After the user selects
          # and uploads a file, head of that data file by default,
          # or all rows if selected, will be shown.
          
          req(input$file1)
          
          # reads data
          z <- read.csv(input$file1$datapath,
                                header = input$header,
                                colClasses = c("numeric")
                   )
          
          # converts into a time series object
          
          if (is.null(input$start.date.day) == TRUE){
                        ts(z, start = c(input$start.date.year, input$start.date.month), frequency = input$data.frequency)
                }else{
                        ts(z, start = c(input$start.date.year, input$start.date.month, input$start.date.day), frequency = input$data.frequency)        
          }
            
  })
        
        # Display user data file ----
        output$contents <- renderTable({

                req(input$file1)
                
                if(input$disp == "head") {
                        return(head(user.data()))
                }
                else {
                        return(user.data())
                }
                
        })
      

        # Set ARIMA forecast object ----
        arima.fcast <-reactiveValues(data=NULL)
        
        # Estimate ARIMA manual forecast ----
        observeEvent(
                input$fit.and.forecast,
                {
                        if(is.null(input$file1) == FALSE){ arima.data <- user.data()}else{arima.data <- AirPassengers}
                        arima.fcast$data <- forecast(arima(arima.data, order = c(input$arima.p, input$arima.q, input$arima.d), seasonal = list(order = c(input$arima.P, input$arima.Q, input$arima.D))), input$arima.horizon)
                }
        )
        
        # Estimate ARIMA automatic forecast ----
        observeEvent(
                input$box.jenkins.method,
                {
                        if(is.null(input$file1) == FALSE){ arima.data <- user.data()}else{arima.data <-AirPassengers}
                        arima.fcast$data <- forecast(auto.arima(arima.data), input$arima.horizon)
                }
        )
        
        # ARIMA Forecast Plot ----
        output$arima.plot<- renderPlot({ 
                if (is.null(arima.fcast$data)){ return()}else{
                new.plot(arima.fcast$data, yaxis = input$arima.Y.axis)}
                })
        
        # ARIMA Summary Table ----
        output$summary.arima <- renderPrint({
                req(arima.fcast$data)
                summary(arima.fcast$data)
                
        })
        
        # Set ETS forecast object ----
        ets.fcast <-reactiveValues(data=NULL)
        
        # Estimate ETS manual forecast ----
        observeEvent(
                input$ets.manual,
                {
                        if(is.null(input$file1) == FALSE){ ets.data <- user.data()}else{ets.data <-USAccDeaths}
                        
                        model.vector <- paste(c(input$ets.error.type, input$ets.trend.type, input$ets.season.type), collapse="" )
                        ets.prohibited <- c("ANM", "AMN", "AMA", "AAM", "AMM", "MMA")
                        
                        if ( is.element(model.vector, ets.prohibited) == TRUE ){
                                
                                ets.fcast$data <- forecast(ets(ets.data), input$ets.horizon)
                                
                        }else{
                        
                                ets.fcast$data <- forecast(ets(ets.data, model = model.vector), input$ets.horizon)
                        
                        }
                }
        )
        
        # Estimate ETS automatic forecast ----
        observeEvent(
                input$ets.automatic,
                {
                        if(is.null(input$file1) == FALSE){ ets.data <- user.data()}else{ets.data <-USAccDeaths}
                        ets.fcast$data <- forecast(ets(ets.data), input$ets.horizon)
                }
        )
        
        # ETS Forecast Plot ----
        output$ets.plot<- renderPlot({ 
                if (is.null(ets.fcast$data)){ return()}else{
                        new.plot(ets.fcast$data, yaxis = input$ets.Y.axis)}
        })
        
        

        # ETS Summary Table
        output$summary.ets <- renderPrint({
                req(ets.fcast$data)
                summary(ets.fcast$data)
                
        })
})
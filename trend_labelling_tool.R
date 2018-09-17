library(tidyquant)
library(ggplot2)
library(data.table)
library(scales)
library(shiny)

df <- read.csv("GBPUSDDaily.csv", sep=",", fileEncoding="utf-16")
df$Null <- NULL
df$Date <- as.Date(df$Date, "%Y.%m.%d")
df$trend <- 0

long_period <- 100
short_period <- 50

min_date <- min(df$Date)
max_date <- max(df$Date)

df <- df %>% 
    mutate(sma_LONGPERIOD = SMA( Close , n=long_period)) %>%
    mutate(sma_SHORTPERIOD = SMA( Close, n=short_period)) %>%
    filter(!is.na(sma_SHORTPERIOD) & !is.na(sma_LONGPERIOD))


ui <- fluidPage(
    
    titlePanel("Trend Labelling Tool"),
    
    sidebarPanel(
        actionButton("return_full_plot", "Return Full Plot"),
        dateRangeInput("dateRange", "Date Range: ", 
                       start = min(df$Date), 
                       end = max(df$Date)),
        verbatimTextOutput("fx_hover_info"),
        actionButton("label_up", "Label 'Up'"),
        actionButton("label_down", "Label 'Down'")
    ),
    
    mainPanel(
        plotOutput("fx_plot", height = 350,
                   hover = hoverOpts(id = "fx_plot_hover"),
                   brush = brushOpts(id = "fx_plot_brush")),
        verbatimTextOutput("fx_brush_info")
    )
)

server <- function(input, output, session) {
    
    rval <- reactiveValues(x = NULL, dat = df)
    
    observeEvent(input$fx_plot_hover, rval$x <- input$fx_plot_hover$x)
    
    observeEvent(input$label_up, {
        brushed_points <- brushedPoints(rval$dat, input$fx_plot_brush)$Date
        
        first_row_date <- format(
            brushed_points[1]
        )
        
        last_row_date <- format(
            brushed_points[length(brushed_points)]
        )
        
        rval$dat <- rval$dat %>%
            mutate(trend = ifelse(Date >= as.Date(first_row_date) & Date <= as.Date(last_row_date), 1, trend))
            
    })
    
    observeEvent(input$label_down, {
        brushed_points <- brushedPoints(rval$dat, input$fx_plot_brush)$Date
        
        first_row_date <- format(
            brushed_points[1]
        )
        
        last_row_date <- format(
            brushed_points[length(brushed_points)]
        )
        
        rval$dat <- rval$dat %>%
            mutate(trend = ifelse(Date >= as.Date(first_row_date) & Date <= as.Date(last_row_date), -1, trend))
        
    })
    
    observeEvent(input$return_full_plot, {
        updateDateRangeInput(session, "dateRange",
                             start = min(df$Date),
                             end = max(df$Date))
    })
    
    output$fx_plot <- renderPlot({
        
        min_date <- format(input$dateRange[1])
        max_date <- format(input$dateRange[2])
        
        ggplot(
          rval$dat %>%
              filter(Date %between% c(min_date, max_date))
          , aes(y = Close, x = Date)) +
          geom_candlestick(aes(open=Open, high=High, low=Low, close=Close)) +
          geom_line(aes(x = Date, y = sma_LONGPERIOD, group = 1), color = "green") +
          geom_line(aes(x = Date, y = sma_SHORTPERIOD, group = 2), color='steelblue') +
          theme_tq() +
          scale_x_date(labels = date_format("%Y-%m-%d"))
    })
  
    output$fx_hover_info <- renderPrint({
        if(!is.null(rval$x)) {
            print(as.Date(floor(rval$x)))   
        } else {
            print("Hover around graph to get date")
        }
    })
    
    output$fx_brush_info <- renderPrint({
        brushedPoints(rval$dat, input$fx_plot_brush)
    })
}

shinyApp(ui, server)
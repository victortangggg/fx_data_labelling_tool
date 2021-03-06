library(tidyquant)
library(ggplot2)
library(data.table) 
library(scales)
library(shiny)

filename <- "GBPUSDDaily.csv"

df <- read.csv(filename, sep=",", fileEncoding="utf-16")
if(is.null(df$trend)) {
    df$Null <- NULL
    df$Date <- as.Date(df$Date, "%Y.%m.%d")
    df$trend <- 0
    
    long_period <- 100
    short_period <- 50
    df <- df %>% 
        mutate(sma_LONGPERIOD = SMA( Close , n=long_period)) %>%
        mutate(sma_SHORTPERIOD = SMA( Close, n=short_period)) %>%
        filter(!is.na(sma_SHORTPERIOD) & !is.na(sma_LONGPERIOD))
} else {
    df$Date <- as.Date(df$Date, "%Y-%m-%d")
}

min_date <- min(df$Date)
max_date <- max(df$Date)


ui <- fluidPage(
    
    titlePanel("Trend Labelling Tool"),
    
    sidebarPanel(
        column(
            width = 6,
            actionButton("return_full_plot", "Return Full Plot", width = "100%")
        ),
        column(
            width = 6,
            actionButton("save_df", "Save", width = "100%")
        ),
        dateRangeInput("dateRange", "Date Range: ", 
                       start = min(df$Date), 
                       end = max(df$Date)),
        verbatimTextOutput("fx_hover_info"),
        actionButton("label_up", "Label 'Up'", width = "100%"),
        actionButton("label_down", "Label 'Down'", width = "100%"),
        verbatimTextOutput("num_unlabelled"),
        div(style="display:inline-block", textInput("column_name", "Column Name (label): ", width = "100%")),
        div(style="display:inline-block", textInput("column_value", "Column Value: ", width = "100%")),
        actionButton("add_new_label", "Add Label")
    ),
    
    mainPanel(
        plotOutput("fx_plot", height = 450,
                   hover = hoverOpts(id = "fx_plot_hover"),
                   brush = brushOpts(id = "fx_plot_brush"))
    ),
    
    fluidPage(
        fluidRow(
            style="overflow-y: auto",
            verbatimTextOutput("fx_brush_info")
        )
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
    
    observeEvent(input$add_new_label, {
        brushed_points <- brushedPoints(rval$dat, input$fx_plot_brush)$Date
        
        first_row_date <- format(
            brushed_points[1]
        )
        
        last_row_date <- format(
            brushed_points[length(brushed_points)]
        )
        
        rval$dat <- rval$dat %>%
            mutate(!!input$column_name := ifelse(Date >= as.Date(first_row_date) & Date <= as.Date(last_row_date), input$column_value, 0))
        
    })
    
    observeEvent(input$return_full_plot, {
        updateDateRangeInput(session, "dateRange",
                             start = min(df$Date),
                             end = max(df$Date))
    })
    
    observeEvent(input$save_df, {
        write.csv(rval$dat, file = filename, row.names=FALSE, fileEncoding = "utf-16")
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
            theme_bw() +
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
    
    output$num_unlabelled <- renderPrint({
        rval$dat %>%
            filter(trend == 0) %>%
            nrow()
    })
}

shinyApp(ui, server)
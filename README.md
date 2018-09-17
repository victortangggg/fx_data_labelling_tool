# FX trend labelling tool (incomplete)

make sure to have the following r packages:
```
library(tidyquant)
library(ggplot2)
library(data.table)
library(scales)
library(shiny)
```

to run:

* make sure you have RStudio installed

* in RStudio, Ctrl + A the whole R code and Ctrl+Enter (in other words just run the whole of the R code)
* play around!

data loaded is a csv containing past data of currency pair GBPUSD (daily), extracted from MetaTrader 5

this tool is created for me to label the trend of past FX data. labelled data is subsequently used for my personal research in FX data analysis.

## TODO

* using brush to window data instead of existing dateRangeInput (for better UX)

* persisting labelled data

* CSV export of labelled dataframe

* function to flag unlabelled data

if you are a researcher looking to have a way to label the trend of your stock/fx data and you think this is useful, feel free to clone this. if it sucks, feel free to let me know what can be done better!
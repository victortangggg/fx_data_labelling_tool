# FX trend/pattern labelling tool

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

this tool is created for me to label the trend/patterns of past FX data. labelled data is subsequently used for my personal research in FX data analysis.

## TODO

* ~~able to add new column name & value~~

* ~~persisting labelled data~~

* ~~CSV export of labelled dataframe~~

* ~~function to flag number of unlabelled data~~

* call quandl fx data instead of static MT5 FX csv(180 days only)

if you are a researcher looking to have a way to label the trend of your stock/fx data and you think this is useful, feel free to clone this. if it sucks, feel free to let me know what can be done better!
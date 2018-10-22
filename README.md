# wanderer4melb

Would weather affect the number of people wandering around the city of Melbourne? A shiny app for visualising Melbourne pedestrian and weather data in 2016.

## Installation

You could install the shiny app using:

```r
# install.packages("devtools")
devtools::install_github("earowang/wanderer4melb")
```

## Demo

```r
library(wanderer4melb)
launch_app()
```

The snippet above launches the shiny app with a viewer in RStudio or a browser from R.

A gif showing the app in action:

![demo](img/demo.gif)

## Related work

You may like to check out @cpsievert's [pedestrian app](https://github.com/cpsievert/pedestrians) by exploring pedestrian patterns from different aspects.

## Acknowledgements

* The New York Times post on [How Much Warmer Was Your City in 2015?](https://www.nytimes.com/interactive/2016/02/19/us/2015-year-in-weather-temperature-precipitation.html#melbourne_australia) provides the original display for the weather data.
* Carson's online book [Plotly for R](https://cpsievert.github.io/plotly_book/) is a great resource for learning `plotly`.

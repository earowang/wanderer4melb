# wanderer4melb

A shiny app for visualising Melbourne pedestrian and weather data in 2016.

## Inspiration

Would weather affect the number of people wandering around the city of Melbourne?

## Installation

You could install the shiny app using:

```r
# install.packages("devtools")
devtools::install_github("earowang/wanderer4melb")
```

By doing so, the development versions of [tidyverse/dplyr](https://github.com/tidyverse/dplyr) and [earowang/sugrrants](https://github.com/earowang/sugrrants) will be installed to enable the full functionality. The `dplyr` dev currently provides tidy evaluation in conjunction with `rlang`, and `sugrrants` (under development) helps to generate the calendar display used for the shiny app. 

## Demo

`wanderer4melb::launch_app()` launches the shiny app with a viewer in RStudio or a browser from R.

A gif showing the app in action:

![demo](img/demo.gif)

## Related work

You may like to check out @cpsievert's [pedestrian app](https://github.com/cpsievert/pedestrians) by exploring pedestrian patterns from different aspects.

## Acknowledgements

* The New York Times post on [How Much Warmer Was Your City in 2015?](https://www.nytimes.com/interactive/2016/02/19/us/2015-year-in-weather-temperature-precipitation.html#melbourne_australia) provides the original display for the weather data.
* Carson's online book [Plotly for R](https://cpsievert.github.io/plotly_book/) is a great source for learning `plotly`.

#' Launch shiny app for visualising pedestrian and weather data
#'
#' @export
#' @examples \dontrun{
#'    launch_app()
#' }
launch_app <- function() {
  ui <- fluidPage(
    titlePanel("Foot traffic in Melbourne"),
    fluidRow(
      column(
        width = 5,
        # h4("Sensor location"),
        leafletOutput("melb_map"),
        plotlyOutput("weather")
      ),
      column(
        width = 7,
        # h4("Calendar plot"),
        plotlyOutput("calendar", height = 850),
        column(
          width = 3,
          offset = 3,
          h4("calendar options:")
        ),
        column(
          width = 2,
          checkboxInput("polar", label = "Polar Coord", value = FALSE)
        ),
        column(
          width = 2,
          checkboxInput("sunday", label = "Sunday", value = FALSE)
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        textOutput("app_desc"),
        tags$head(tags$style(
          "#app_desc {
            color: #de2d26;
            font-size: 20px;
          }"
        ))
      )
    )
  )

  server <- function(input, output, session) {
    output$melb_map <- renderLeaflet({
      melb_map <- ped_loc %>%
        leaflet() %>%
        addTiles() %>%
        fitBounds(
          ~ min(Longitude), ~ min(Latitude),
          ~ max(Longitude), ~ max(Latitude)
        ) %>%
        addCircleMarkers(
          ~ Longitude, ~ Latitude, layerId = ~ Sensor_ID,
          color = I("#3182bd"), label = ~ Sensor_Name,
          stroke = TRUE, radius = 8, fillOpacity = 0.5
        )
    })
    observe({
      sensor_id <- input$melb_map_marker_click$id
      sensor_id <- sensor_id[length(sensor_id)] # keep the last selected sensor
      if (!is.null(sensor_id)) {
        sub_data <- ped_loc %>%
          mutate(color = if_else(Sensor_ID == sensor_id, "red", "#3182bd"))
        leafletProxy("melb_map", session) %>%
          clearMarkers() %>%
          addCircleMarkers(
            sub_data$Longitude, sub_data$Latitude, layerId = sub_data$Sensor_ID,
            color = sub_data$color, label = sub_data$Sensor_Name,
            stroke = TRUE, radius = 8, fillOpacity = 0.5
          )
      }
    })

    select_data <- reactive({
      sensor_id <- input$melb_map_marker_click$id
      sensor_id <- sensor_id[length(sensor_id)] # keep the last selected sensor
      week_start <- if (input$sunday) 7 else 1
      if (!is.null(sensor_id)) {
        ped_cal <- ped %>%
          filter(Sensor_ID == sensor_id) %>%
          frame_calendar(
            x = Time, y = Hourly_Counts, date = Date, nrow = 3, ncol = 4,
            polar = input$polar, week_start = week_start
          )
      } else {
        ped_cal <- ped %>%
          filter(Sensor_ID == 13) %>%
          frame_calendar(
            x = Time, y = Hourly_Counts, date = Date, nrow = 3, ncol = 4,
            polar = input$polar, week_start = week_start
          )
      }
      ped_cal
    })

    output$calendar <- renderPlotly({
      cal_dat <- select_data()
      ped_key <- row.names(cal_dat)
      cal_plotly <- cal_dat %>%
        group_by(Date) %>%
        plot_ly(
          x = ~ .Time, y = ~ .Hourly_Counts,
          hoverinfo = "text",
          text = ~ paste(
            "Sensor: ", Sensor_Name,
            "<br> Date: ", Date,
            "<br> Day: ", Day,
            "<br> Holiday: ", Holiday
          ),
          source = "calendar"
        ) %>%
        add_paths(color = I("#3182bd")) %>%
        add_markers(color = I("#3182bd"), size = I(0.1), key = ~ ped_key)
      cal_plot <- prettify(cal_plotly)
      d <- event_data("plotly_click", source = "calendar")
      if (!is.null(d)) {
        hl_point <- cal_dat[ped_key %in% d[["key"]], "Date"]
        hl_day <- cal_dat %>% filter(Date %in% hl_point)
        cal_plot <- add_paths(cal_plot, data = hl_day, color = I("#d73027"))
      }
      layout(cal_plot, showlegend = FALSE)
    })

    output$weather <- renderPlotly({
      cal_dat <- select_data()
      ped_key <- row.names(cal_dat)
      d <- event_data("plotly_click", source = "calendar")
      p_temp <- melb_temp %>%
        plot_ly(
          x = ~ date, xend = ~ date,
          y = ~ lower16, yend = ~ upper16
        ) %>%
        add_ribbons(
          ymin = ~ lower, ymax = ~ upper,
          hoverinfo = "none", color = I("#bdbdbd")
          ) %>%
        add_segments(
          color = I("#636363"),
          size = I(3),
          hoverinfo = "text",
          text = ~ paste(
            "Date: ", date,
            "<br> High: ", lower16,
            "<br> Low: ", upper16
          )
        )
      if (!is.null(d)) {
        hl_point <- cal_dat[ped_key %in% d[["key"]], "Date"]
        hl_day <- melb_temp %>% filter(date %in% hl_point)
        p_temp <- add_segments(
          p_temp, data = hl_day, color = I("#d73027"), size = I(3),
          hoverinfo = "text",
          text = ~ paste(
            "Date: ", date,
            "<br> High: ", lower16,
            "<br> Low: ", upper16
          )
        )
      }
      p_temp <- layout(
        p_temp,
        showlegend = FALSE,
        xaxis = list(title = "Day of the year"),
        yaxis = list(title = "Daily temperture")
      )

      p_prcp <- melb_prcp %>%
        plot_ly(
          x = ~ date, y = ~ prcp,
          hoverinfo = "text",
          text = ~ paste(
            "Date: ", date,
            "<br> Monthly Cumulative Precipation: ", prcp
          )
        ) %>%
        add_ribbons(ymin = I(0), ymax = ~ prcp, color = I("#3182bd"))
      if (!is.null(d)) {
        hl_point <- cal_dat[ped_key %in% d[["key"]], "Date"]
        hl_day <- melb_prcp %>% filter(date %in% hl_point)
        p_prcp <- add_markers(p_prcp, data = hl_day, color = I("#d73027"))
      }
      p_prcp <- layout(
          p_prcp,
          showlegend = FALSE,
          xaxis = list(title = "Day of the year"),
          yaxis = list(title = "Cumulative precipation")
        )

      p_weather <- subplot(
        p_temp, p_prcp, nrows = 2,
        heights = c(0.7, 0.3), shareX = TRUE
      )
    p_weather
    })
    output$app_desc <- renderText({
      "Would weather affect the number of people wandering around the city of Melbourne? This shiny app visualises Melbourne pedestrian and weather data in 2016. The top left map displays the locations of installed sensors in downtown Melbourne. Click the sensor of interest, the corresponding hourly traffic will be updated in the calendar plot on the right panel. The bottom left plots show the daily high and low temperatures, and monthly cumulative precipitation in Melbourne respectively. Selecting a day in the calendar plot will highlight the corresponding day in the weather plots."
    })
  }

  shinyApp(ui, server)

}


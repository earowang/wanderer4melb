#' Launch shiny app for visualising pedestrian and weather data
#' 
#' @export
#' @examples \dontrun{
#' launchApp()
#' }
lauch_app <- function() {
  a <- list(
    title = "",
    zeroline = FALSE,
    autotick = FALSE,
    showticklabels = FALSE,
    showline = FALSE,
    showgrid = FALSE
  )

  ui <- fluidPage(
    title = "Foot traffic in Melbourne",
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
          width = 3
        ),
        column(
          width = 3,
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
      if (!is.null(sensor_id)) {
        ped_cal <- ped %>% 
          filter(Sensor_ID == sensor_id) %>% 
          frame_calendar(
            x = Time, y = Hourly_Counts, date = Date, nrow = 3, ncol = 4,
            polar = input$polar, sunday = input$sunday
          )
      } else {
        ped_cal <- ped %>% 
          filter(Sensor_ID == 13) %>% 
          frame_calendar(
            x = Time, y = Hourly_Counts, date = Date, nrow = 3, ncol = 4,
            polar = input$polar, sunday = input$sunday
          )
      }
      ped_cal_data <- ped_cal
      ped_cal_labels <- attr(ped_cal, "mlabel")
      ped_cal_dlabels <- attr(ped_cal, "dlabel")
      return(list(ped_cal_data, ped_cal_labels, ped_cal_dlabels))
    })

    output$calendar <- renderPlotly({
      cal_dat <- select_data()[[1]]
      ped_key <- row.names(cal_dat)
      cal_plot <- cal_dat %>% 
        group_by(.group_id) %>% 
        plot_ly(
          x = ~ .x, y = ~ .y,
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
        add_markers(color = I("#3182bd"), size = I(0.1), key = ~ ped_key) %>% 
        add_text(
          x = ~ x, y = ~ y, text = ~ label, data = select_data()[[2]],
          color = I("black")
        ) %>% 
        add_text(
          x = ~ x, y = ~ y, text = ~ label, data = select_data()[[3]],
          color = I("black")
        )
      d <- event_data("plotly_click", source = "calendar")
      if (!is.null(d)) {
        hl_point <- cal_dat[ped_key %in% d[["key"]], "Date"] 
        hl_day <- cal_dat %>% filter(Date == hl_point)
        cal_plot <- add_paths(cal_plot, data = hl_day, color = I("#d73027"))
      }
      layout(cal_plot, showlegend = FALSE, xaxis = a, yaxis = a)
    })

    output$weather <- renderPlotly({
      cal_dat <- select_data()[[1]]
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
        hl_day <- melb_temp %>% filter(date == hl_point)
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
            "<br> Precipation: ", prcp
          )
        ) %>% 
        add_ribbons(ymin = I(0), ymax = ~ prcp, color = I("#3182bd"))
      if (!is.null(d)) {
        hl_point <- cal_dat[ped_key %in% d[["key"]], "Date"] 
        hl_day <- melb_prcp %>% filter(date == hl_point)
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
  }

  shinyApp(ui, server)
  
}


#' Hourly pedestrian counts in the city of Melbourne 2016
#'
#' A dataset containing the pedestrian counts at hourly intervals over the year
#' of 2016 at 43 sensors in the city of Melbourne. The variables are as follows:
#'
#' @format A data frame with 361,087 rows and 13 variables:
#' \describe{
#'   \item{Date_Time}{Date time in 2016}
#'   \item{Year}{Year component of Date_Time}
#'   \item{Month}{Month component of Date_Time}
#'   \item{Mdate}{Day component of Date_Time}
#'   \item{Day}{Weekday component of Date_Time}
#'   \item{Time}{Hour component of Date_Time}
#'   \item{Sensor_ID}{Sensor identifiers}
#'   \item{Sensor_Name}{Sensor names}
#'   \item{Hourly_Counts}{Pedestrian Counts at hourly intervals}
#'   \item{Date}{Date component of Date_Time}
#'   \item{Latitude}{Sensor latitude}
#'   \item{Longitude}{Sensor longitude}
#'   \item{Holiday}{Public holiday}
#' }
#' @docType data
#' @name ped
#' @usage ped
#' @examples
#' ped
NULL

#' Pedestrian sensor locations in the city of Melbourne 2016
#'
#' A dataset containing the pedestrian sensor locations in the city of Melbourne. 
#' The variables are as follows:
#'
#' @format A data frame with 43 rows and 4 variables:
#' \describe{
#'   \item{Sensor_ID}{Sensor identifiers}
#'   \item{Sensor_Name}{Sensor names}
#'   \item{Latitude}{Sensor latitude}
#'   \item{Longitude}{Sensor longitude}
#' }
#' @docType data
#' @name ped_loc
#' @usage ped_loc
#' @examples
#' ped_loc
NULL

#' Daily temperature recorded in Melbourne
#'
#' A dataset containing daily temperatures in Melbourne. The variables are as 
#' follows:
#'
#' @format A data frame with 366 rows and 5 variables:
#' \describe{
#'   \item{date}{Date of 2016}
#'   \item{upper16}{Daily high at Melbourne Airport}
#'   \item{lower16}{Daily low at Melbourne Airport}
#'   \item{lower}{Daily historical low from 1947 to 2014 recored at Melbourne Regional Office}
#'   \item{upper}{Daily historical high from 1947 to 2014 recored at Melbourne Regional Office}
#' }
#' @docType data
#' @name melb_temp
#' @usage melb_temp
#' @examples
#' melb_temp
NULL

#' Monthly cumulative precipitation recorded in Melbourne
#'
#' A dataset containing daily precipitations in Melbourne 2016. The variables 
#' are as follows:
#'
#' @format A data frame with 366 rows and 2 variables:
#' \describe{
#'   \item{date}{Date of 2016}
#'   \item{prcp}{Monthly cumulative precipitation}
#' }
#' @docType data
#' @name melb_prcp
#' @usage melb_prcp
#' @examples
#' melb_prcp
NULL

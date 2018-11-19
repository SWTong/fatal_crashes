# Make sure to use \\ instead of \ when referring to paths and include the schema name of the table
#cn <- odbcDriverConnect(connection="Driver={SQL Server Native Client 11.0};server={LAPTOP-7LOSBJJT\\ISM4402};database=FARSAccident2016;trusted_connection=yes;")
#dataFetch <- sqlFetch(cn,'FARS.Accident_Staging_DataMart')
# View(dataFetch)
# 
# head(dataFetch)

# install the R package to connect to Microsoft SQL Server
#install.packages('RODBC')

# load the package
#library(RODBC)

#establish the connection to Microsoft SQL Server
#cn <- odbcDriverConnect(connection="Driver={SQL Server Native Client 11.0};server={LAPTOP-7LOSBJJT\\ISM4402};database=FARSAccident2016;trusted_connection=yes;")

#query the data set and store the data set in a variable named 'dataSet'
# dataSet <- sqlQuery(cn, 'SELECT ST_CASE, STATE_NAME, CITY_NAME, COUNTY_NAME, RUR_URB_NAME, TYP_INT_NAME, HARM_EV_NAME, FATALS, DRUNK_DR, VE_TOTAL, VE_FORMS, PVH_INVL, PEDS, PERNOTMVIT, PERMVIT, PERSONS,
#                   MONTH_NAME, DAY_WEEK_NAME, WEATHER_NAME, LGT_COND_NAME, LATITUDE, LONGITUD
#                   FROM FARS.Fact_Accident
#                     INNER JOIN FARS.Dim_City
#                     ON FARS.Fact_Accident.DIM_CITYID = FARS.Dim_City.DIM_CITYID                     
#                     INNER JOIN FARS.Dim_County 
#                     ON FARS.Dim_City.DIM_COUNTYID = FARS.Dim_County.DIM_COUNTYID
#                     INNER JOIN FARS.Dim_State
#                    ON FARS.Dim_County.DIM_STATEID = FARS.Dim_State.DIM_STATEID
#                     INNER JOIN FARS.Dim_Rural_Urban
#                     ON FARS.Fact_Accident.DIM_RUR_URBID = FARS.Dim_Rural_Urban.DIM_RUR_URBID
#                     INNER JOIN FARS.Dim_Weather
#                     ON FARS.Fact_Accident.DIM_WEATHERID = FARS.Dim_Weather.DIM_WEATHERID
#                    INNER JOIN FARS.Dim_Light_Condition
#                     ON FARS.Fact_Accident.DIM_LGT_CONDID = FARS.Dim_Light_Condition.DIM_LGT_CONDID
#                     INNER JOIN FARS.Dim_Month
#                     ON FARS.Fact_Accident.DIM_MONTHID = FARS.Dim_Month.DIM_MONTHID
#                     INNER JOIN FARS.Dim_Day_of_Week
#                      ON FARS.Fact_Accident.DIM_DAY_WEEKID = FARS.Dim_Day_of_Week.DIM_DAY_WEEKID
#                      INNER JOIN FARS.Dim_Intersection_Type
#                    ON FARS.Fact_Accident.DIM_TYP_INTID = FARS.Dim_Intersection_Type.DIM_TYP_INTID
#                 INNER JOIN FARS.Dim_Harmful_Event
#                 ON FARS.Fact_Accident.DIM_HARM_EVID = FARS.Dim_Harmful_Event.DIM_HARM_EVID'
#                )

#subset accident data set to only include crashes in Florida (coded 12)
#florida <- accident[accident$STATE == 'FLORIDA',]

#Other way of doing this - may work better since publishing embeded R code later

#set the working directory (folder where we are obtaining data from)
setwd("C:\\Users\\Sharon\\Desktop\\fatal_crashes")

#read the csv file we'll we working with and store the data set from the csv file to a variable named accident
florida <- read.csv("florida_dataset.csv")

#discover the structure of the data set
str(dataSet)

#summary of data set
summary(dataSet)

#subset florida data set to hillsborough
hillsb <- florida[florida$COUNTY_NAME == 'HILLSBOROUGH',]

#subset florida data set to pinellas
pinellas <- florida[florida$COUNTY_NAME == 'PINELLAS',]

#subset florida data set to pasco
pasco <- florida[florida$COUNTY_NAME == 'PASCO',]

#subset florida data set to hernando
hernando <- florida[florida$COUNTY_NAME == 'HERNANDO',]

#subset florida data set to citrus
citrus <- florida[florida$COUNTY_NAME == 'CITRUS',]

#subset florida data set to manatee
manatee <- florida[florida$COUNTY_NAME == 'MANATEE',]

#subset florida data set to sarasota
sarasota <- florida[florida$COUNTY_NAME == 'SARASOTA',]

#combine counties to create the tampa bay data set
tpabay <- rbind(hillsb, pinellas, pasco, hernando, citrus, manatee, sarasota)
 
#create a new data set with the total fatalies by tampa bay county
CountyFatalities <- data.frame(aggregate(tpabay$FATALS, by=list(Category=tpabay$COUNTY_NAME), FUN=sum))

#rename columns in CountyFatalities data set
library(plyr)

#overwrite old CountyFatalities set with the new set that has the renamed columns
CountyFatalities <- rename(CountyFatalities, c("Category"="CountyName", "x"="TotalFatalities"))

#View the updated CountyFatalities set to make sure the renamed columns appear
#View(CountyFatalities)

#Plot CountyFatalities
library(ggplot2)
qplot(x=CountyFatalities$CountyName, y=CountyFatalities$TotalFatalities)

#View the first 6 rows in florida data set
#head(florida)

#Check out the structure of the florida data set
#str(florida)

#practice using ggplot2
#library("ggplot2")


#total number of fatalities in Florida 2016
#sum(florida$FATALS)

#ny <- dataSet[dataSet$STATE == 36,]

#View(ny)

#doesn't work. merge() works by matching on a common col with
#the same values. All the ST_CASE values are different so
#it doesn't work
#fl_ny <- merge(florida, ny, by.x="ST_CASE", by.y="ST_CASE")

#Empty set
#View(fl_ny)

#qplot() doesn't accept 2 data sets as arguments. To solve, merge data sets
#qplot(data=florida, data=ny, x=sum(florida$FATALS, y=sum(ny$FATALS)))

#combine florida and ny data sets
#fl_ny <- rbind(florida, ny)

#View(fl_ny)

#summary(fl_ny)

#install leaflet package to use map widget feature and magritter package to pipe map layers(?)

install.packages("leaflet")
install.packages("Rcpp")

library("leaflet")
library("magrittr") 

# #test leaflet map feature using one coordinate point
# m <- leaflet()
# m <- addTiles(m)
# m <- addMarkers(m, lng=174.768, lat=-36.852, popup="The birthplace of R")
# m

#Plot the crashes in the hillsborough data set using leaflet package and show popup info about the crash
leaflet(data = hillsb) %>% 
  addTiles() %>%
  addMarkers(~LONGITUD, ~LATITUDE, popup = ~as.character(FATALS), label = ~as.character(TWAY_ID))

#test out clustering by number of crashes
#create a variable named content to store marker label info
#like number of fatalies in that crash, the trafficway name(s),
#and the first injury or damage producing event of the crash

#need to figure out how to display content in label on multiple lines
content <- paste("FATALS: ",tpabay$FATALS,
                 "First Injury/Damage ", tpabay$HARM_EV_NAME,
                 "Trafficway: ",tpabay$TWAY_ID, "and ",
                 tpabay$TWAY_ID
                 )
tbay_map <- leaflet(data=tpabay) %>% 
addTiles() %>% 
addCircleMarkers(data = tpabay, lng = ~ LONGITUD, lat = ~ LATITUDE, radius = 5, 
                   color = ~ palette(),
                  label = content,
                   clusterOptions = markerClusterOptions())
tbay_map

#hillsborough map
content <- paste("FATALS: ",tpabay$FATALS,
                 "First Injury/Damage ", tpabay$HARM_EV_NAME,
                 "Trafficway: ",tpabay$TWAY_ID, "and ",
                 tpabay$TWAY_ID
)
hmap <- leaflet(data=hillsb) %>% 
  addTiles() %>% 
  addCircleMarkers(data = tpabay, lng = ~ LONGITUD, lat = ~ LATITUDE, radius = 5, 
                   color = ~ palette(),
                   label = content,
                   clusterOptions = markerClusterOptions())
hmap


# #example of clustering data. higher numbers of bribery incidents
# SFMap % 
# addTiles() %>% 
#   setView(-122.42, 37.78, zoom = 13) %>% 
#   addCircleMarkers(data = data, lng = ~ X, lat = ~ Y, radius = 5, 
#                    color = ~ ifelse(Category == 'BRIBERY', 'red', 'blue'),
#                    clusterOptions = markerClusterOptions())

#need to come up with a way to total crashes in each Florida county (use a counter) so I could create a heat map and see which
#counties have high number of fatal crashes. also good to know what streets have high number of crashes. maybe
#convert the geo coordinates into addresses and total the crashes for each address (use a counter), then create
#a heat map based on the count. OR limit data set to only tampa bay (hillsborough, pinellas, pasco, citrus, manatee,
#sarasota, hernando)

#test out geocode function to convert location coordinates to readable addresses
# revgeo(longitude, latitude, provider = 'google', API = AIzaSyBvz5ywHP3qUy3E2DEKwNIADfCItbKIHOQ, 
#        output = NULL,
#        item = NULL)
#  	

#------------reverse geocode method #1:
#Preview data set
head(tpabay)

#load ggmap package
library(ggmap)

#Translate multiple longitude and latitude coordinates into street addresses
#using revgeocode function with generated Google Geocode API key and then 
#store the addresses in an address column in tpabay data set
tpabay$ADDRESS <- mapply(FUN = function(LONGITUD,LATITUDE) revgeocode(c(LONGITUD,LATITUDE, provider = 'google', 
                             API = 'AIzaSyBvz5ywHP3qUy3E2DEKwNIADfCItbKIHOQ')),
                             tpabay$LONGITUD, tpabay$LATITUDE)


#---------reverse geocode method #2

#get index number of column name
grep("LATITUDE", colnames(tpabay))
grep("LONGITUD", colnames(tpabay))

#Create a location data set by subsetting tpabay data set and storing subset results into a variable named location
#Subset by using data from columns 1, 21, and 22 in tpabay data set.
#The [] means to subset tpabay data set by index. The comma means to keep all rows and the c() means what columns
#I want to keep, which are columns 1, 21, and 22.
location <- tpabay[,c(1,21,22)]

#View my location data set to make sure it looks right
View(location)

#Reverse geocode and store addresses in an address column
location$address <- lapply(seq(nrow(location)), function(i){ 
  revgeocode(location[i,], 
             output = c("address"), 
             messaging = FALSE, 
             sensor = FALSE, 
             override_limit = FALSE)
})

#troubleshoot by verifying if lon and lat are numeric
is.numeric(location$LONGITUD)
is.numeric(location$LATITUDE)


#--------------reverse geocode method #3:
#test out googlway method of batch reverse geocoding 

# library(googleway)
# 
# key <- "AIzaSyBvz5ywHP3qUy3E2DEKwNIADfCItbKIHOQ"
# 
# res <- apply(location, 1, function(x){
#   google_reverse_geocode(location = c(x["LATITUDE"], x["LONGITUD"]),
#                          key = key)
# })
# 
# View(res)
#I don't know where to go from here...
#------------------reverse geocode method #4:


#get index number of column name
grep("LATITUDE", colnames(tpabay))
grep("LONGITUD", colnames(tpabay))

#Create a location data set by subsetting tpabay data set and storing subset results into a variable named location
#Subset by using data from columns 1, 21, and 22 in tpabay data set.
#The [] means to subset tpabay data set by index. The comma means to keep all rows and the c() means what columns
#I want to keep, which are columns 1, 21, and 22.
locdata <- tpabay[,c(1,22,21)]

#View my location data set to make sure it looks right
# View(locdata)
# 
# library(ggmap)
# 
# result <- do.call(rbind,
#                   lapply(1:nrow(locdata),
#                          function(i)revgeocode(as.numeric(locdata[i,3:2]))))
# locdata <- cbind(locdata,result)
# View(locdata)

#end result didn't work. all addresses are NA

#EXAMPLE
# data <- read.csv(text="ID,      Longitude,      Latitude
# 311175,  41.298437,      -72.929179
# 292058,  41.936943,      -87.669838
# 12979,   37.580956,      -77.471439")
# 
# library(ggmap)
# result <- do.call(rbind,
#                   lapply(1:nrow(data),
#                          function(i)revgeocode(as.numeric(data[i,3:2]))))
# data <- cbind(data,result)
# data
 
#--------------------reverse geocode method #5:

locdata$textAddress <- revgeocode(c(locdata$LONGITUD, locdata$LATITUDE))


revgeocode(location, output = c("address", "more", "all"), messaging = FALSE, sensor = FALSE, override_limit = FALSE, client = "", signature = "")


#EXAMPLE
# revgeocode(c(df$lon[1], df$lat[1]))
# df$textAddress <- mapply(FUN = function(lon, lat) revgeocode(c(lon, lat)), df$lon, df$lat)

library(plotly)

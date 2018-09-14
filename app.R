# This web app will display all minimum instream flow violators
# The purpose of this app is to allow for stakeholders to view water availability

# Author: Brad Luff

# Load in the required libraries
library(shiny)
library(leaflet)
library(raster)
#library(sp)
library(rgdal)



# Load in the stream layer
palouse <- readOGR("HUC08Palouse.shp")
streams <- readOGR("PalouseStreams.shp")
dem <- raster("PalouseDEM2.tif")
con.lines <- rasterToContour(dem)


# Define UI
ui <- fluidPage(
  # Define the basemap
  leafletOutput(c("basemap"), height = "100vh", width = "100%")
)

# Define server logic
server <- function(input, output) {
  output$basemap <- renderLeaflet({
    # Generate map
    map <- leaflet() %>%
      # Add basemap
      addTiles() %>%
      # Add stream lines
      addPolylines(data = streams , color = "Blue", weight = 2, stroke = TRUE, fillOpacity = .25, group = "Streams") %>%
      # Center the map around Pullman-ish
      setView(lng = -117.3, lat = 47.05, zoom = 9) %>%
      # Add the gages
      #addCircles(data = gages, weight = 1, color = ~pal(Gage_wat_2), radius = 3000, fillOpacity = 1, group = "USGS Gages") %>%
      # Add the outline of the Palouse
      addPolygons(data = palouse, fill = F, group = "Palouse", color = "#981e32", weight = 3) %>%
      # Add the DEM
      addRasterImage(dem, colors = "Spectral", opacity = 0.5, group = "DEM") %>%
      # Add stream lines
      addPolylines(data = con.lines , color = "Green", weight = 1.5, stroke = TRUE, fillOpacity = .75, group = "Contour") %>%
      # Add layer control
      addLayersControl(
        overlayGroups =c("Palouse", "DEM", "Streams", "Contour"),
        options = layersControlOptions(collapsed=FALSE)) %>%
      hideGroup(c("Contour"))
    map
  })
}




# Run the application 
shinyApp(ui = ui, server = server)
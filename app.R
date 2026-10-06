library(shiny)
library(RiksbankenAPIProject)

# Download the available series.
series <- available_series()

# Display descriptions and identifiers. Use the identifiers as input values.
series_choices <- setNames(series$series_id,
                           paste(series$description, "-", series$series_id))

# ui saves the interface definition
# fluidPage() creates a page that adapts to the available width.
ui <- fluidPage(
  titlePanel("Explore Riksbank Data"),
  sidebarLayout( # arranges a sidebar and a main area.
    sidebarPanel( # contains the inputs
      # Choose a series, or type to search by description or identifier.
      selectInput(
        inputId = "series", # The server accesses the selection through input$series
        label = "Select a series:", # The heading shown above the dropdown.
        choices = series_choices, # The available identifiers and their display labels.
        selected = "SECBREPOEFF" # The initially selected identifier.
      ),
      dateRangeInput(
        inputId = "period",
        label = "Select date range:",
        start = Sys.Date() - 365,
        end = Sys.Date()
      ),
      actionButton(inputId = "fetch", label = "Fetch data")
    ),
    mainPanel( # Results go here
      plotOutput(outputId = "plot"),
      tableOutput(outputId = "table")
    )
  )
)

# Define how the app responds to the user.
# input reads the values of the interface controls.
# output defines the results displayed in the interface.
# session is supplied by Shiny automatically but our code does not directly use it.
# input$series - Selected series identifier
# input$period - Selected start and end dates
# input$fetch - Fetch button's click count
server <- function(input, output, session) {

  # Code that checks inputs and downloads observations.
  # eventReactive() takes input$fetch as an event expression and the code inside {} as a calculation.
  observations <- eventReactive(input$fetch, {
    req(input$period) # Checks that the required input is available. If NULL, "" or empty vector c(), it stops the calculation silently

    # Validate the selected series and date order
    # need(condition, message) returns a failure message but does not prevent the next line from running. Otherwise, NULL if the condition is TRUE.
    # validate() handles the result from need(): stop the Shiny calculation and displays the message.
    validate(
      need(input$series %in% series$series_id, "Please select an available series."),
      need(input$period[1] <= input$period[2],
           "The start date must be earlier than or equal to the end date.")
      )

    # If riksbanken_serie(...) succeeds, its returned data frame is assigned to d.
    # If it produces an error, tryCatch() runs the handler.
    d <- tryCatch(riksbanken_serie(ts = input$series,
                                   from = input$period[1],
                                   to = input$period[2]),
                  error = function(e) {validate(need(FALSE, paste("Could not retrieve data:", conditionMessage(e))))})

    validate(need(nrow(d) > 0, "No observations were found for this series and period."))

    # Sort the observations and return the result
    # order(d$date) returns the row positions needed to arrange dates from earliest to latest.
    # Because this is the last expression inside the calculation, R returns it automatically. It becomes the result obtained through observation()
    # observations stores a reactive expression, not an ordinary data frame. We obtain its result by observations()
    d[order(d$date), , drop = FALSE]
  }
  )

  # Draw the selected series.
  output$plot <- renderPlot({
    d <- observations()
    plot(
      d$date,
      d$value,
      type = "b", # Draw points and connecting lines
      xlab = "Date",
      ylab = "Value",
      main = "Selected series"
    )
  })

  # Display the first ten observations.
  output$table <- renderTable({
    d <- head(observations(), 10)
    d$date <- as.character(d$date) # Display the exact date and not convert to number of days
    d
  })
}
# Connect the user interface and server.
shinyApp(ui = ui, server = server)

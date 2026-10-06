#Det användaren ser
ui <- fluidPage(
  titlePanel("Utforska Riksbankens data"),
  sidebarLayout(
    sidebarPanel(
      textInput(
        "serie",
        "Serie-ID:",
        value = "SECBREPOEFF"
      ),
      dateRangeInput(
        "period",
        "Välj datumintervall:",
        start = Sys.Date() - 365,
        end = Sys.Date()
      ),
      actionButton("hamta", "Hämta data")
    ),
    mainPanel(
      plotOutput("graf"),
      tableOutput("tabell")
    )
  )
)
# Vad appen ska göra
server <- function(input, output, session) {
# Hämta data när användaren klickar på knappen
  observations <- eventReactive(input$hamta, {
    req(input$period)
    validate(
      need(nzchar(trimws(input$serie)), "Ange ett serie-ID."),
      need(
        input$period[1] <= input$period[2],
        "Startdatum måste vara före eller samma som slutdatum."
      )
    )
    d <- tryCatch(
      riksbanken_serie(
        ts = input$serie,
        from = input$period[1],
        to = input$period[2]
      ),
      error = function(e) {
        validate(
          need(FALSE, paste("Kunde inte hämta data:", conditionMessage(e)))
        )
      }
    )
    validate(
      need(nrow(d) > 0, "Inga observationer hittades.")
    )
    d[order(d$date), , drop = FALSE]
  })
  # Rita grafen
  output$graf <- renderPlot({
    d <- observations()
    plot(
      d$date,
      d$value,
      type = "b",
      xlab = "Datum",
      ylab = "Värde",
      main = "Vald tidsserie"
    )
  })
  # Visa de första tio observationerna
  output$tabell <- renderTable({
    d <- head(observations(), 10)
    d$date <- as.character(d$date)
    d
  })
}
# Starta appen
shinyApp(ui = ui, server = server)

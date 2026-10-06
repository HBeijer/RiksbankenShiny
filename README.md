# RiksbankenShiny

A Shiny app for exploring interest rate and exchange rate data from the Riksbank.
The app uses the [RiksbankenAPIProject](https://github.com/HBeijer/RiksbankenAPIProject) package to retrieve data.

Users can search for a series by its description or identifier, select a date interval,
and display a plot and the first ten observations. An internet connection is required.

## Install the dependencies

Run these commands once in R:

```r
install.packages(c("shiny", "remotes"))
remotes::install_github(
  "HBeijer/RiksbankenAPIProject",
  build_vignettes = FALSE,
  upgrade = "never"
)
```

## Run from GitHub

```r
shiny::runGitHub("RiksbankenShiny", "HBeijer")
```

## Run locally

Open the RiksbankenShiny project in RStudio and run:

```r
shiny::runApp()
```

## Use the app

1. Select a series from the searchable dropdown. The policy rate (`SECBREPOEFF`) is selected by default.
2. Choose the start and end dates.
3. Click **Fetch data** to display the plot and table.

The series catalogue is downloaded when the app starts. Observations are downloaded
only after clicking **Fetch data**, and the plot and table share the same result.
Changing the selection or dates alone does not download new observations.

The app displays messages for invalid inputs, API errors, and periods with no observations.

## Authors

Thai Pham and Hampus Beijer.

Created for Lab 5 of 732A94 Advanced R Programming at Linköping University.

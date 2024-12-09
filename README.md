[![](https://docs.posit.co/connect-cloud/images/cc-deploy.svg)](https://connect.posit.cloud/publish?contentType=shiny&sourceRepositoryURL=https%3A%2F%2Fgithub.com%2Falex-chisholm%2Fshiny-r-abtesting&sourceRef=main&sourceRefType=branch&primaryFile=app.R)



https://github.com/alex-chisholm/shiny-r-abtesting

# A/B Test Calculator

A Shiny application for analyzing A/B test results with statistical significance testing.

## Overview

This Shiny app provides a user-friendly interface for performing statistical analysis on A/B test data. It calculates conversion rates, performs statistical significance testing, and visualizes the results through intuitive charts and metrics.

## Features

- **Input Controls**: Easy input of visit and conversion numbers for both variants
- **Real-time Calculations**: Instantly updates results as you modify the input values
- **Visual Results**:
  - Conversion rate comparison bar chart
  - Chi-square distribution visualization
  - Statistical significance indicators
- **Key Metrics Display**:
  - Conversion rates for both variants
  - P-value calculation
  - Relative difference between variants
  - Clear significance interpretation

## Technical Details

The app uses:
- Chi-square test for statistical significance testing
- Bootstrap-based UI with cards and value boxes
- ggplot2 for data visualization
- Responsive layout that works on different screen sizes

## How to Use

1. Enter the number of visits and conversions for Variant A
2. Enter the number of visits and conversions for Variant B
3. The app will automatically:
   - Calculate conversion rates
   - Perform statistical testing
   - Update visualizations
   - Show whether the difference is statistically significant

## Dependencies

- shiny
- bslib
- ggplot2

To deploy on [Connect Cloud](https://connect.posit.cloud/) you need a manifest.json depedency file. You can create one by running the following code:

```r
rsconnect::writeManifest(appFiles = "app.R")

```

## Installation and Running

```r
# Install required packages
install.packages(c("shiny", "bslib", "ggplot2"))

# Run the app
shiny::runApp()
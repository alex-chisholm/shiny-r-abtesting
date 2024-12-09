library(shiny)
library(bslib)
library(ggplot2)

ui <- page_sidebar(
  title = "A/B Test Calculator",
  sidebar = sidebar(
    # Variant A inputs
    card(
      "Variant A",
      numericInput("visits_a", "Number of Visits (A)", value = 1000, min = 0),
      numericInput("conv_a", "Number of Conversions (A)", value = 100, min = 0)
    ),
    # Variant B inputs
    card(
      "Variant B",
      numericInput("visits_b", "Number of Visits (B)", value = 1000, min = 0),
      numericInput("conv_b", "Number of Conversions (B)", value = 120, min = 0)
    )
  ),
  
  layout_columns(
    col_widths = c(6, 6),
    value_box(
      title = "Conversion Rate A",
      value = textOutput("conv_rate_a"),
      style = "background-color: #447099;color: #ffffff;"
    ),
    value_box(
      title = "Conversion Rate B",
      value = textOutput("conv_rate_b"),
      style = "background-color: #EE6331; color:#ffffff;"
    )
  ),
  
  card(
    full_screen = TRUE,
    card_header("Results: Conversion Rates"),
    plotOutput("conv_plot")
  ),
  
  card(
    full_screen = TRUE,
    card_header("Statistical Significance Distribution"),
    plotOutput("dist_plot"),
    card_body(
      textOutput("significance_text")
    )
  )
)

server <- function(input, output) {
  # Calculate conversion rates and test results
  results <- reactive({
    conv_rate_a <- input$conv_a / input$visits_a
    conv_rate_b <- input$conv_b / input$visits_b
    
    # Perform chi-square test (which is what prop.test uses internally)
    test_result <- prop.test(
      x = c(input$conv_a, input$conv_b),
      n = c(input$visits_a, input$visits_b)
    )
    
    # Calculate chi-square statistic
    p1 <- input$conv_a / input$visits_a
    p2 <- input$conv_b / input$visits_b
    p_pooled <- (input$conv_a + input$conv_b) / (input$visits_a + input$visits_b)
    chi_sq <- sum(
      (input$conv_a - input$visits_a * p_pooled)^2 / (input$visits_a * p_pooled * (1 - p_pooled)) +
      (input$conv_b - input$visits_b * p_pooled)^2 / (input$visits_b * p_pooled * (1 - p_pooled))
    )
    
    list(
      rate_a = conv_rate_a,
      rate_b = conv_rate_b,
      p_value = test_result$p.value,
      significant = test_result$p.value < 0.05,
      chi_sq = chi_sq
    )
  })
  
  # Output conversion rates
  output$conv_rate_a <- renderText({
    sprintf("%.1f%%", results()$rate_a * 100)
  })
  
  output$conv_rate_b <- renderText({
    sprintf("%.1f%%", results()$rate_b * 100)
  })
  
  # Create bar plot visualization
  output$conv_plot <- renderPlot({
    rates <- data.frame(
      variant = c("A", "B"),
      rate = c(results()$rate_a, results()$rate_b)
    )
    
    ggplot(rates, aes(x = variant, y = rate)) +
      geom_bar(stat = "identity", fill = c("#447099", "#EE6331"), width = 0.6) +
      geom_label(aes(label = scales::percent(rate)), 
                 vjust = 0.5,  # Adjust the vertical position
                 size = 5) +    # Label text size
      scale_y_continuous(labels = scales::percent) +
      labs(x = "Variant", y = "Conversion Rate") +
      theme_minimal() +
      theme(text = element_text(size = 14))
  })
  
  # Create distribution plot
  output$dist_plot <- renderPlot({
    res <- results()
    
    # Create data for chi-square distribution
    x <- seq(0, max(15, res$chi_sq + 2), length.out = 200)
    y <- dchisq(x, df = 1)
    
    # Critical value for 95% confidence
    crit_value <- qchisq(0.95, df = 1)
    
    # Create data frame for plotting
    dist_data <- data.frame(x = x, y = y)
    
    # Create the plot
    ggplot(dist_data, aes(x = x, y = y)) +
      # Distribution curve
      geom_line(size = 1, color = "black") +
      # Fill significant region
      geom_area(data = subset(dist_data, x >= crit_value),
                aes(x = x, y = y), fill = "#EE6331", alpha = 0.3) +
      # Add vertical line for current test statistic
      geom_vline(xintercept = res$chi_sq, color = "#447099", 
                 linetype = "dashed", size = 1) +
      geom_vline(xintercept = crit_value, color = "gray", 
                linetype = "dashed", size = 1) +
      # Add labels
      annotate("text", x = crit_value, y = 1, 
               label = "95% threshold", angle = 90, vjust = -0.5) +
      annotate("text", x = res$chi_sq, y = 1, 
               label = "Current test", angle = 90, vjust = -0.5) +
      labs(x = "Chi-square statistic", y = "Density",
           title = "Chi-square Distribution (df = 1)") +
      theme_minimal() +
      theme(text = element_text(size = 14))
  })
  
  # Display significance text
  output$significance_text <- renderText({
    res <- results()
    rel_diff <- (res$rate_b - res$rate_a) / res$rate_a * 100
    
    if (res$significant) {
      sprintf("Statistically significant result (p = %.3f). 
              Variant B shows a %.1f%% %s conversion rate than Variant A.",
              res$p_value, abs(rel_diff),
              ifelse(rel_diff > 0, "higher", "lower"))
    } else {
      sprintf("Not statistically significant (p = %.3f). 
              Cannot conclude that there is a real difference between variants.",
              res$p_value)
    }
  })
}

shinyApp(ui, server)
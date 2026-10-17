# ==============================
# Load Libraries
# ==============================
library(tidyverse)    # Data manipulation & ggplot2
library(janitor)      # Cleaning column names
library(skimr)        # Overview of data
library(lme4)         # Linear mixed-effects models
library(lmerTest)     # p-values for lme4 models
library(BayesFactor)  # Bayesian analysis
library(psych)        # Tetrachoric correlation
library(polycor)      # Polychoric correlation
library(reshape2)     # Data reshaping for plotting
library(readxl)

# ==============================
# Load Data
# ==============================
file_path <- "C:/Users/brian/Downloads/Copy of Expt2_final.xlsx"

# Read individual sheets
workload <- read_excel(file_path, sheet = "Workload") %>% clean_names()
sa       <- read_excel(file_path, sheet = "SA") %>% clean_names()
fulldata <- read_excel(file_path, sheet = "FullData") %>% clean_names()
fulldata2 <- read_excel(file_path, sheet = "FullData2") %>% clean_names()

# Fix FullData2 data types (they're character instead of numeric)
fulldata2 <- fulldata2 %>%
  mutate(
    score = as.numeric(score),
    team_selection_clicks = as.numeric(team_selection_clicks),
    choice_accuracy = as.numeric(choice_accuracy),
    time_respond_env = as.numeric(time_respond_env),
    proportion_stag = as.numeric(proportion_stag),
    proportion_hare = as.numeric(proportion_hare),
    proportion_dis_adv = as.numeric(proportion_dis_adv),
    nasa_tlx = as.numeric(nasa_tlx),
    sart = as.numeric(sart)
  )

cat("\nData loaded successfully!\n")

# ==============================
# Quick Data Overview
# ==============================
cat("\n=== DATA STRUCTURE OVERVIEW ===\n")
cat("\n--- Workload Sheet ---\n")
cat("Dimensions:", dim(workload)[1], "rows x", dim(workload)[2], "columns\n")
print(head(workload, 3))

cat("\n--- SA Sheet ---\n")
cat("Dimensions:", dim(sa)[1], "rows x", dim(sa)[2], "columns\n")
print(head(sa, 3))

cat("\n--- FullData Sheet ---\n")
cat("Dimensions:", dim(fulldata)[1], "rows x", dim(fulldata)[2], "columns\n")
print(head(fulldata, 3))

cat("\n--- FullData2 Sheet ---\n")
cat("Dimensions:", dim(fulldata2)[1], "rows x", dim(fulldata2)[2], "columns\n")
print(head(fulldata2, 3))

# ==============================
# Descriptive Statistics
# ==============================
cat("\n=== DESCRIPTIVE STATISTICS ===\n")

# Workload by Condition
cat("\n--- Workload Summary by Condition ---\n")
workload_summary <- workload %>%
  group_by(condition) %>%
  summarise(
    n = n(),
    mean_total_score = mean(total_score_sum_6, na.rm = TRUE),
    sd_total_score = sd(total_score_sum_6, na.rm = TRUE),
    se_total_score = sd_total_score / sqrt(n),
    min_score = min(total_score_sum_6, na.rm = TRUE),
    max_score = max(total_score_sum_6, na.rm = TRUE),
    .groups = 'drop'
  )
print(workload_summary)

# NASA-TLX Subscales by Condition
cat("\n--- NASA-TLX Subscales by Condition ---\n")
subscale_summary <- workload %>%
  group_by(condition) %>%
  summarise(
    n = n(),
    mental_demand_m = mean(mental_demand, na.rm = TRUE),
    mental_demand_sd = sd(mental_demand, na.rm = TRUE),
    physical_demand_m = mean(physical_demand, na.rm = TRUE),
    physical_demand_sd = sd(physical_demand, na.rm = TRUE),
    temporal_demand_m = mean(temporal_demand, na.rm = TRUE),
    temporal_demand_sd = sd(temporal_demand, na.rm = TRUE),
    performance_m = mean(performance, na.rm = TRUE),
    performance_sd = sd(performance, na.rm = TRUE),
    effort_m = mean(effort, na.rm = TRUE),
    effort_sd = sd(effort, na.rm = TRUE),
    frustration_m = mean(frustration, na.rm = TRUE),
    frustration_sd = sd(frustration, na.rm = TRUE),
    .groups = 'drop'
  )
print(subscale_summary)

# SA by Demand-Condition
cat("\n--- Situation Awareness Summary by Condition ---\n")
sa_summary <- sa %>%
  group_by(demand_condition) %>%
  summarise(
    n = n(),
    mean_sa_total = mean(sa_total, na.rm = TRUE),
    sd_sa_total = sd(sa_total, na.rm = TRUE),
    se_sa_total = sd_sa_total / sqrt(n),
    .groups = 'drop'
  )
print(sa_summary)

# FullData Score by Condition
cat("\n--- FullData Score Summary by Condition ---\n")
fulldata_summary <- fulldata %>%
  group_by(condition) %>%
  summarise(
    n = n(),
    mean_score = mean(score, na.rm = TRUE),
    sd_score = sd(score, na.rm = TRUE),
    se_score = sd_score / sqrt(n),
    .groups = 'drop'
  )
print(fulldata_summary)

# FullData2 Score by Condition (aggregated means)
cat("\n--- FullData2 Score Summary by Condition ---\n")
fulldata2_summary <- fulldata2 %>%
  filter(!is.na(condition)) %>%
  group_by(condition) %>%
  summarise(
    n = sum(n, na.rm = TRUE),
    mean_score = mean(score, na.rm = TRUE),
    .groups = 'drop'
  )
print(fulldata2_summary)

# ==============================
# Visualizations with Data Output
# ==============================
cat("\n=== GENERATING VISUALIZATIONS ===\n")

# 1. Workload Total Score by Condition
cat("\n--- PLOT 1: Workload Total Score by Condition ---\n")
cat("Individual Data Points:\n")
workload_plot_data <- workload %>%
  select(participant, condition, total_score_sum_6) %>%
  arrange(condition, participant)
print(workload_plot_data)

cat("\nSummary Statistics for Plot:\n")
print(workload_summary)

p1 <- ggplot(workload, aes(x = condition, y = total_score_sum_6, fill = condition)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Workload Total Score by Condition",
    x = "Condition",
    y = "Total Score (sum/6)"
  ) +
  theme(legend.position = "none")
print(p1)

# 2. NASA-TLX Subscale Scores by Condition
cat("\n--- PLOT 2: NASA-TLX Subscale Scores by Condition ---\n")
workload_melt <- workload %>%
  select(participant, condition, mental_demand, physical_demand, 
         temporal_demand, performance, effort, frustration) %>%
  pivot_longer(
    cols = c(mental_demand, physical_demand, temporal_demand, 
             performance, effort, frustration),
    names_to = "subscale",
    values_to = "value"
  )

# Calculate means and SEs for plotting
subscale_plot_summary <- workload_melt %>%
  group_by(condition, subscale) %>%
  summarise(
    n = n(),
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    se = sd / sqrt(n),
    .groups = 'drop'
  )

cat("\nMean and SE values for NASA-TLX subscales:\n")
print(subscale_plot_summary)

p2 <- ggplot(workload_melt, aes(x = subscale, y = value, fill = condition)) +
  geom_bar(stat = "summary", fun = "mean", position = "dodge", alpha = 0.8) +
  geom_errorbar(
    stat = "summary",
    fun.data = mean_se,
    position = position_dodge(0.9),
    width = 0.2
  ) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Mean NASA-TLX Subscale Scores by Condition",
    x = "NASA-TLX Subscale",
    y = "Mean Score"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p2)

# 3. SA Total by Condition
cat("\n--- PLOT 3: Situation Awareness Total Score by Condition ---\n")
cat("Individual Data Points:\n")
sa_plot_data <- sa %>%
  select(participant, demand_condition, sa_total) %>%
  arrange(demand_condition, participant)
print(sa_plot_data)

cat("\nSummary Statistics for Plot:\n")
print(sa_summary)

p3 <- ggplot(sa, aes(x = demand_condition, y = sa_total, fill = demand_condition)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Situation Awareness Total Score by Condition",
    x = "Demand Condition",
    y = "SA Total Score"
  ) +
  theme(legend.position = "none")
print(p3)

# 4. Performance Scores (FullData)
cat("\n--- PLOT 4: Performance Scores by Condition (FullData) ---\n")
cat("Individual Data Points:\n")
performance_plot_data <- fulldata %>%
  select(participant, condition, score) %>%
  arrange(condition, participant)
print(performance_plot_data)

cat("\nSummary Statistics for Plot:\n")
print(fulldata_summary)

p4 <- ggplot(fulldata, aes(x = condition, y = score, fill = condition)) +
  geom_violin(alpha = 0.6) +
  geom_boxplot(width = 0.2, alpha = 0.8) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Performance Scores by Condition (FullData)",
    x = "Condition",
    y = "Score"
  ) +
  theme(legend.position = "none")
print(p4)

# ==============================
# Statistical Analyses
# ==============================
cat("\n=== STATISTICAL ANALYSES ===\n")

# Convert condition to factor for proper ANOVA
workload$condition <- as.factor(workload$condition)
sa$demand_condition <- as.factor(sa$demand_condition)
fulldata$condition <- as.factor(fulldata$condition)

# 1. One-Way ANOVA - Workload Total Score
cat("\n--- One-Way ANOVA: Workload Total Score by Condition ---\n")
aov_workload <- aov(total_score_sum_6 ~ condition, data = workload)
print(summary(aov_workload))

# Check assumptions
cat("\nChecking ANOVA assumptions:\n")
# Levene's test for homogeneity of variance
levene_workload <- car::leveneTest(total_score_sum_6 ~ condition, data = workload)
print(levene_workload)

# Normality test
shapiro_workload <- shapiro.test(residuals(aov_workload))
cat("\nShapiro-Wilk test for normality: W =", shapiro_workload$statistic, 
    ", p =", shapiro_workload$p.value, "\n")

# Effect size (eta-squared)
if(require(effectsize, quietly = TRUE)) {
  eta_sq <- eta_squared(aov_workload)
  print(eta_sq)
}

# Post-hoc comparisons (if ANOVA is significant)
cat("\n--- Post-hoc Pairwise Comparisons (Tukey HSD) ---\n")
tukey_workload <- TukeyHSD(aov_workload)
print(tukey_workload)

# 2. Bayesian ANOVA - Workload
cat("\n--- Bayesian ANOVA: Workload Total Score ---\n")
tryCatch({
  bf_workload <- anovaBF(total_score_sum_6 ~ condition, data = as.data.frame(workload))
  print(bf_workload)
}, error = function(e) {
  cat("Error in Bayesian analysis:", e$message, "\n")
})

# 3. One-Way ANOVA - Situation Awareness
cat("\n--- One-Way ANOVA: Situation Awareness by Condition ---\n")
aov_sa <- aov(sa_total ~ demand_condition, data = sa)
print(summary(aov_sa))

# Check assumptions
cat("\nChecking ANOVA assumptions:\n")
levene_sa <- car::leveneTest(sa_total ~ demand_condition, data = sa)
print(levene_sa)

shapiro_sa <- shapiro.test(residuals(aov_sa))
cat("\nShapiro-Wilk test for normality: W =", shapiro_sa$statistic, 
    ", p =", shapiro_sa$p.value, "\n")

# Post-hoc comparisons
cat("\n--- Post-hoc Pairwise Comparisons (Tukey HSD) ---\n")
tukey_sa <- TukeyHSD(aov_sa)
print(tukey_sa)

# 4. One-Way ANOVA - Performance Score (FullData)
cat("\n--- One-Way ANOVA: Performance Score by Condition ---\n")
aov_performance <- aov(score ~ condition, data = fulldata)
print(summary(aov_performance))

# Check assumptions
levene_perf <- car::leveneTest(score ~ condition, data = fulldata)
print(levene_perf)

shapiro_perf <- shapiro.test(residuals(aov_performance))
cat("\nShapiro-Wilk test for normality: W =", shapiro_perf$statistic, 
    ", p =", shapiro_perf$p.value, "\n")

# Post-hoc comparisons
cat("\n--- Post-hoc Pairwise Comparisons (Tukey HSD) ---\n")
tukey_perf <- TukeyHSD(aov_performance)
print(tukey_perf)

# 5. Individual NASA-TLX Subscale ANOVAs
cat("\n=== NASA-TLX SUBSCALE ANALYSES ===\n")
subscales <- c("mental_demand", "physical_demand", "temporal_demand", 
               "performance", "effort", "frustration")

for (subscale in subscales) {
  cat("\n--- ANOVA:", subscale, "---\n")
  formula_str <- paste(subscale, "~ condition")
  aov_sub <- aov(as.formula(formula_str), data = workload)
  print(summary(aov_sub))
}

# ==============================
# Correlation Analysis
# ==============================
cat("\n=== CORRELATION ANALYSIS ===\n")

# Pearson correlations for continuous variables
cat("\n--- Correlations: Workload and Performance ---\n")
cor_data <- fulldata %>%
  select(score, nasa_tlx, sart, choice_accuracy, time_respond_env)

cor_matrix <- cor(cor_data, use = "pairwise.complete.obs")
cat("\nCorrelation Matrix:\n")
print(round(cor_matrix, 3))

# Test significance
cor_test <- psych::corr.test(cor_data, use = "pairwise")
cat("\nCorrelation p-values:\n")
print(round(cor_test$p, 3))

# Visualize correlation matrix
cat("\n--- PLOT 5: Correlation Matrix ---\n")
cat("Correlation values shown in the plot:\n")
cor_melt <- melt(cor_matrix)
print(cor_melt)

p5 <- ggplot(cor_melt, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), color = "black", size = 3) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1)) +
  theme_minimal() +
  labs(title = "Correlation Matrix: Performance Measures") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p5)

# Polychoric correlations for SA variables
cat("\n--- Polychoric Correlations: SA Variables ---\n")
tryCatch({
  sa_numeric <- sa %>%
    select(demand_instab, complex, supply_variab, supply_arous, 
           supply_concen, supply_divis, understanding_spare, 
           understanding_quant, understanding_qual, sa_fami)
  
  if (ncol(sa_numeric) > 1) {
    polycor_matrix <- hetcor(sa_numeric, use = "pairwise.complete.obs")
    cat("\nPolychoric Correlation Matrix:\n")
    print(round(polycor_matrix$correlations, 3))
  }
}, error = function(e) {
  cat("Error in correlation analysis:", e$message, "\n")
})

# ==============================
# Additional Analyses
# ==============================
cat("\n=== ADDITIONAL ANALYSES ===\n")

# Reliability analysis for NASA-TLX subscales
cat("\n--- Reliability Analysis: NASA-TLX Subscales ---\n")
tlx_items <- workload %>%
  select(mental_demand, physical_demand, temporal_demand, 
         performance, effort, frustration)
alpha_tlx <- psych::alpha(tlx_items)
print(alpha_tlx)

# Effect sizes (Cohen's d) for pairwise comparisons
cat("\n--- Effect Sizes (Cohen's d): Workload Comparisons ---\n")
conditions <- unique(workload$condition)
for (i in 1:(length(conditions)-1)) {
  for (j in (i+1):length(conditions)) {
    group1 <- workload %>% filter(condition == conditions[i]) %>% 
      pull(total_score_sum_6)
    group2 <- workload %>% filter(condition == conditions[j]) %>% 
      pull(total_score_sum_6)
    
    cohens_d <- (mean(group1, na.rm = TRUE) - mean(group2, na.rm = TRUE)) / 
      sqrt((sd(group1, na.rm = TRUE)^2 + sd(group2, na.rm = TRUE)^2) / 2)
    
    cat(conditions[i], "vs", conditions[j], ": d =", round(cohens_d, 3), "\n")
  }
}

# Summary table combining all measures
cat("\n--- Combined Summary Table ---\n")
combined_summary <- fulldata %>%
  group_by(condition) %>%
  summarise(
    n = n(),
    performance_m = mean(score, na.rm = TRUE),
    performance_sd = sd(score, na.rm = TRUE),
    workload_m = mean(nasa_tlx, na.rm = TRUE),
    workload_sd = sd(nasa_tlx, na.rm = TRUE),
    sa_m = mean(sart, na.rm = TRUE),
    sa_sd = sd(sart, na.rm = TRUE),
    accuracy_m = mean(choice_accuracy, na.rm = TRUE),
    accuracy_sd = sd(choice_accuracy, na.rm = TRUE),
    .groups = 'drop'
  )
print(combined_summary)

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("All analyses have been completed successfully!\n")

# Summary table: Mental Demand, Effort, Physical Demand by condition (E / O / R)
library(dplyr)
library(tidyr)
library(knitr)

subscales <- c("mental_demand", "effort", "physical_demand")

table_subscales <- workload %>%
  # normalize condition labels to E / O / R (handles both full names and single letters)
  mutate(cond = case_when(
    condition %in% c("Extreme_Hare", "Extreme_Hare ", "E")  ~ "E",
    condition %in% c("Ambiguous", "Ambiguous ", "O")       ~ "O",
    condition %in% c("Extreme_Stag", "Extreme_Stag ", "R") ~ "R",
    TRUE ~ as.character(condition)
  )) %>%
  select(cond, all_of(subscales)) %>%
  pivot_longer(cols = all_of(subscales), names_to = "Subscale", values_to = "Value") %>%
  group_by(Subscale, cond) %>%
  summarise(
    Mean = round(mean(Value, na.rm = TRUE), 1),
    SD   = round(sd(Value, na.rm = TRUE), 1),
    n    = sum(!is.na(Value)),
    .groups = "drop"
  ) %>%
  # create "mean (sd)" label and reshape so subscales are rows and conditions are columns
  mutate(Mean_SD = ifelse(is.na(Mean), NA, paste0(Mean, " (", SD, ")"))) %>%
  select(Subscale, cond, Mean_SD) %>%
  pivot_wider(names_from = cond, values_from = Mean_SD) %>%
  # optional: rename subscales for nicer display
  mutate(Subscale = recode(Subscale,
                           mental_demand = "Mental Demand",
                           effort = "Effort",
                           physical_demand = "Physical Demand"))

# Print nicely
knitr::kable(table_subscales,
             caption = "Table: NASA-TLX Subscale Means (Mean (SD)) by Condition",
             booktabs = TRUE)

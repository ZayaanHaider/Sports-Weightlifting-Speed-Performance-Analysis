# ==================================================
# Sports Weightlifting & Speed Performance Analysis
# ==================================================


if (!dir.exists("visuals")) dir.create("visuals", recursive = TRUE)
if (!dir.exists("results")) dir.create("results", recursive = TRUE)

# Load data
Draft <- read.csv("data/Sports_WeightliftingSpeed.csv")

# Helper: write key test output to a text file
sink("results/statistical_tests.txt")
cat("Sports Weightlifting & Speed Performance Analysis\n")
cat("Generated on:", as.character(Sys.time()), "\n\n")

# 1) Distribution of Player Positions
cat("1) Position distribution\n")
position_counts <- table(Draft$Pos)
position_props <- prop.table(position_counts)
print(position_counts)
cat("\nProportions:\n")
print(round(position_props, 4))
cat("\n\n")

# 2) Distribution of 40-Yard Dash Times
cat("2) 40-yard dash summary\n")
forty <- na.omit(Draft$X40yd)

summary_stats <- c(
  mean = mean(forty),
  median = median(forty),
  sd = sd(forty),
  min = min(forty),
  max = max(forty),
  IQR = IQR(forty)
)
print(round(summary_stats, 4))
cat("\n\n")

# Histogram
png("visuals/histogram_40yd.png", width = 900, height = 650)
hist(forty,
     main = "Distribution of 40-Yard Dash Times",
     xlab = "40-Yard Dash Time (seconds)",
     ylab = "Count",
     col = "skyblue",
     border = "black")
dev.off()

# Boxplot
png("visuals/boxplot_40yd.png", width = 900, height = 650)
boxplot(forty,
        main = "Boxplot of 40-Yard Dash Times",
        ylab = "40-Yard Dash Time (seconds)",
        col = "orange")
dev.off()

# 3) Bench Press Level vs 40-Yard Dash Level

cat("3) Cross-tab: BenchRep_Levels vs 40yd_Levels\n")
level_table <- table(Draft$BenchRep_Levels, Draft$`40yd_Levels`)
print(level_table)
cat("\nProportions (overall):\n")
print(round(prop.table(level_table), 4))
cat("\n\n")

# 4) Bench Press Reps vs 40-Yard Dash (Quantitative)
#    + Upgrade: correlation + simple linear regression
cat("4) Bench reps vs 40yd (quantitative)\n")
sub_40_bench <- na.omit(data.frame(Bench = Draft$Bench, X40yd = Draft$X40yd))

# Scatterplot
png("visuals/scatter_bench_vs_40yd.png", width = 900, height = 650)
plot(sub_40_bench$Bench, sub_40_bench$X40yd,
     main = "Bench Press Reps vs 40-Yard Dash Time",
     xlab = "Bench Press Reps (225 lbs)",
     ylab = "40-Yard Dash Time (seconds)",
     col = "purple")
# Add regression line
abline(lm(X40yd ~ Bench, data = sub_40_bench), lwd = 2)
dev.off()

# Correlation test
cat("Correlation test (Bench vs 40yd):\n")
cor_test <- cor.test(sub_40_bench$Bench, sub_40_bench$X40yd)
print(cor_test)
cat("\n")

# Simple linear regression
cat("Linear regression (40yd ~ Bench):\n")
model <- lm(X40yd ~ Bench, data = sub_40_bench)
print(summary(model))
cat("\n\n")

# 5) Broad Jump by Bench Press Level
#    + Upgrade: one-way ANOVA
cat("5) Broad jump by bench level\n")
sub_bj <- na.omit(data.frame(
  BroadJump = Draft$`Broad Jump`,
  BenchLevel = Draft$BenchRep_Levels
))

# Aggregated means
broadjump_means <- aggregate(BroadJump ~ BenchLevel, data = sub_bj, FUN = mean)
cat("Mean broad jump by bench level:\n")
print(broadjump_means)
cat("\n")

# Boxplot
png("visuals/broadjump_by_bench.png", width = 900, height = 650)
boxplot(sub_bj$BroadJump ~ sub_bj$BenchLevel,
        main = "Broad Jump Distance by Bench Press Level",
        xlab = "Bench Press Level",
        ylab = "Broad Jump Distance (inches)",
        col = "royalblue")
dev.off()

# ANOVA
cat("One-way ANOVA (BroadJump ~ BenchLevel):\n")
anova_model <- aov(BroadJump ~ BenchLevel, data = sub_bj)
print(summary(anova_model))
cat("\n")

# Optional: pairwise comparisons (Tukey HSD)
cat("Tukey HSD post-hoc comparisons:\n")
print(TukeyHSD(anova_model))
cat("\n\n")

# Close sink
sink()

# Done
message("Done. Outputs saved to visuals/ and results/.")

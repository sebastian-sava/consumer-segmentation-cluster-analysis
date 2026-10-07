# Consumer segmentation analysis
# Individual university project using a fictional organic sandwich-spread case.

rm(list = ls())

library(cluster)
library(scatterplot3d)

# Load the public portfolio dataset
sandwich <- read.csv("data/consumer_preferences.csv")

str(sandwich)
summary(sandwich)

active_vars <- c(
  "Taste", "Fattiness", "Salt", "Spreadability",
  "Appearance", "Recycling", "Bio.content"
)

# The manager expected two main groups:
# 1) taste/health-oriented consumers
# 2) sustainability-oriented consumers
# I test the segment structure rather than fixing the number of clusters in advance.


# Exploratory plots ---------------------------------------------------------

plot(
  sandwich$Taste[1:50],
  xlab = "Respondent", ylab = "Taste",
  ylim = c(1, 7), pch = 16, main = "Taste"
)

plot(
  sandwich$Salt[1:50],
  xlab = "Respondent", ylab = "Salt",
  ylim = c(1, 7), pch = 16, main = "Salt"
)

plot(
  sandwich$Fattiness[1:50],
  xlab = "Respondent", ylab = "Fattiness",
  ylim = c(1, 7), pch = 16, main = "Fattiness"
)

scatterplot3d(
  sandwich$Taste, sandwich$Salt, sandwich$Fattiness,
  xlab = "Taste", ylab = "Salt", zlab = "Fattiness",
  xlim = c(1, 7), ylim = c(1, 7), zlim = c(1, 7),
  pch = 16, main = "Taste, Salt & Fattiness"
)

plot(
  sandwich$Recycling[1:50],
  xlab = "Respondent", ylab = "Recycling",
  ylim = c(1, 7), pch = 16, main = "Recycling"
)

plot(
  sandwich$Bio.content[1:50],
  xlab = "Respondent", ylab = "Bio Content",
  ylim = c(1, 7), pch = 16, main = "Bio Content"
)


# Standardize active variables ---------------------------------------------

sandwich2 <- sandwich
sandwich2[, active_vars] <- data.frame(scale(sandwich[, active_vars]))

# This Euclidean distance object uses the standardized variables.
d <- dist(sandwich2[, active_vars])
as.matrix(d)[1:10, 1:10]

# The submitted analysis used the original 1-7 preference variables in daisy()
# for the hierarchical stage. I keep that choice here so the portfolio version
# reproduces the original final clustering solution.
sandwich2.dist <- daisy(sandwich[, active_vars])
as.matrix(sandwich2.dist)[1:10, 1:10]


# Hierarchical clustering ---------------------------------------------------

sandwich2.hc <- hclust(sandwich2.dist, method = "ward.D2")
sandwich2.hc.centroid <- hclust(sandwich2.dist, method = "centroid")
sandwich2.hc.complete <- hclust(sandwich2.dist, method = "complete")

plot(sandwich2.hc, main = "Ward hierarchical clustering")
plot(sandwich2.hc.centroid, main = "Centroid hierarchical clustering")
plot(sandwich2.hc.complete, main = "Complete-linkage hierarchical clustering")

sandwichagglo <- cbind(
  as.data.frame(sandwich2.hc[1]),
  as.data.frame(sandwich2.hc[2])
)

sandwichagglo.centroid <- cbind(
  as.data.frame(sandwich2.hc.centroid[1]),
  as.data.frame(sandwich2.hc.centroid[2])
)

sandwichagglo.complete <- cbind(
  as.data.frame(sandwich2.hc.complete[1]),
  as.data.frame(sandwich2.hc.complete[2])
)

# Inspect the final merges. The elbows suggest that 3 and 4 clusters
# are both worth testing.
sandwich.scree <- sort(sandwichagglo[489:499, 3], decreasing = TRUE)
plot(
  sandwich.scree, type = "b",
  xlab = "Clusters", ylab = "Cluster distance",
  main = "Scree Plot - Ward"
)

sandwich.scree.centroid <- sort(
  sandwichagglo.centroid[489:499, 3],
  decreasing = TRUE
)
plot(
  sandwich.scree.centroid, type = "b",
  xlab = "Clusters", ylab = "Cluster distance",
  main = "Scree Plot - Centroid"
)

sandwich.scree.complete <- sort(
  sandwichagglo.complete[489:499, 3],
  decreasing = TRUE
)
plot(
  sandwich.scree.complete, type = "b",
  xlab = "Clusters", ylab = "Cluster distance",
  main = "Scree Plot - Complete"
)

plot(sandwich2.hc)
rect.hclust(sandwich2.hc, k = 4)

sandwich2.hc.segment3 <- cutree(sandwich2.hc, k = 3)
sandwich2.hc.segment4 <- cutree(sandwich2.hc, k = 4)

table(sandwich2.hc.segment3)
table(sandwich2.hc.segment4)

seg.summ <- function(data, groups) {
  aggregate(data, list(groups), function(x) mean(as.numeric(x)))
}

sandwich2k3.hc.means <- seg.summ(
  sandwich2[, active_vars],
  sandwich2.hc.segment3
)

sandwich2k4.hc.means <- seg.summ(
  sandwich2[, active_vars],
  sandwich2.hc.segment4
)

sandwich2k3.hc.means
sandwich2k4.hc.means


# Compare the hierarchical 3- and 4-cluster solutions ----------------------

clusmember3 <- as.factor(sandwich2.hc.segment3)
clusmember4 <- as.factor(sandwich2.hc.segment4)

aov3base <- cbind(clusmember3, sandwich2[, active_vars])
aov3age <- cbind(clusmember3, sandwich2[, c(active_vars, "Age")])

aov3.age <- aov(Age ~ clusmember3, data = aov3age)
summary(aov3.age)
TukeyHSD(aov3.age)

for (v in active_vars) {
  model <- aov(aov3base[[v]] ~ clusmember3)
  print(v)
  print(summary(model))
  print(TukeyHSD(model))
}

c3.gender <- table(clusmember3, sandwich2$Gender)
c3.education <- table(clusmember3, sandwich2$Education)
c3.area <- table(clusmember3, sandwich2$Area)

c3.gender
chisq.test(c3.gender)       # fixed: the submitted script accidentally tested education here
c3.education
chisq.test(c3.education)
c3.area
chisq.test(c3.area)

aov4base <- cbind(clusmember4, sandwich2[, active_vars])
aov4age <- cbind(clusmember4, sandwich2[, c(active_vars, "Age")])

aov4.age <- aov(Age ~ clusmember4, data = aov4age)
summary(aov4.age)
TukeyHSD(aov4.age)

for (v in active_vars) {
  model <- aov(aov4base[[v]] ~ clusmember4)
  print(v)
  print(summary(model))
  print(TukeyHSD(model))
}

c4.gender <- table(clusmember4, sandwich2$Gender)
c4.education <- table(clusmember4, sandwich2$Education)
c4.area <- table(clusmember4, sandwich2$Area)

c4.gender
chisq.test(c4.gender)
c4.education
chisq.test(c4.education)
c4.area
chisq.test(c4.area)


# PCA comparison for hierarchical solutions --------------------------------

pca_h <- prcomp(sandwich2[, active_vars])

plot(
  pca_h$x[, 1], pca_h$x[, 2],
  col = sandwich2.hc.segment3, pch = 16,
  xlab = "PC1", ylab = "PC2",
  main = "PCA - 3 Hierarchical Clusters"
)

plot(
  pca_h$x[, 1], pca_h$x[, 2],
  col = sandwich2.hc.segment4, pch = 16,
  xlab = "PC1", ylab = "PC2",
  main = "PCA - 4 Hierarchical Clusters"
)


# Standard K-means ----------------------------------------------------------

set.seed(96743)
sandwich2.k3 <- kmeans(sandwich2[, active_vars], centers = 3)
sandwich.k3.segment <- sandwich2.k3$cluster

table(sandwich.k3.segment)
seg.summ(sandwich2[, active_vars], sandwich.k3.segment)

set.seed(96743)
sandwich2.k4 <- kmeans(sandwich2[, active_vars], centers = 4)
sandwich.k4.segment <- sandwich2.k4$cluster

table(sandwich.k4.segment)
seg.summ(sandwich2[, active_vars], sandwich.k4.segment)

pca_k <- prcomp(sandwich2[, active_vars])

plot(
  pca_k$x[, 1], pca_k$x[, 2],
  col = sandwich.k3.segment, pch = 16,
  xlab = "PC1", ylab = "PC2",
  main = "PCA - 3 K-means Clusters"
)

plot(
  pca_k$x[, 1], pca_k$x[, 2],
  col = sandwich.k4.segment, pch = 16,
  xlab = "PC1", ylab = "PC2",
  main = "PCA - 4 K-means Clusters"
)


# Combined hierarchical + K-means ------------------------------------------

# Use the hierarchical cluster means as the K-means starting centres.
k3meanstart <- sandwich2k3.hc.means[, 2:8]
comb.k3 <- kmeans(sandwich2[, active_vars], k3meanstart)

table(comb.k3$cluster)
seg.summ(sandwich2[, active_vars], comb.k3$cluster)

k4meanstart <- sandwich2k4.hc.means[, 2:8]
comb.k4 <- kmeans(sandwich2[, active_vars], k4meanstart)

table(comb.k4$cluster)
final_profiles <- seg.summ(sandwich2[, active_vars], comb.k4$cluster)
final_profiles


# Final 4-cluster statistical profiling ------------------------------------

clusmember.combk4 <- as.factor(comb.k4$cluster)
combk4aovbase <- cbind(clusmember.combk4, sandwich2[, active_vars])
combk4aovage <- cbind(
  clusmember.combk4,
  sandwich2[, c(active_vars, "Age")]
)

combk4age <- aov(Age ~ clusmember.combk4, data = combk4aovage)
summary(combk4age)
TukeyHSD(combk4age)

for (v in active_vars) {
  model <- aov(combk4aovbase[[v]] ~ clusmember.combk4)
  print(v)
  print(summary(model))
  print(TukeyHSD(model))
}

combk4_gender <- table(clusmember.combk4, sandwich2$Gender)
combk4_education <- table(clusmember.combk4, sandwich2$Education)
combk4_area <- table(clusmember.combk4, sandwich2$Area)

combk4_gender
combk4_gender_chisq <- chisq.test(combk4_gender)
combk4_gender_chisq

combk4_education
combk4_education_chisq <- chisq.test(combk4_education)
combk4_education_chisq

combk4_area
combk4_area_chisq <- chisq.test(combk4_area)
combk4_area_chisq

# Gender and education have sparse cells, so R may warn that the chi-square
# approximation is imperfect. I keep the submitted tests but treat the
# demographic profiling cautiously.


# Final PCA -----------------------------------------------------------------

pca.comb4 <- prcomp(sandwich2[, active_vars])
pca_scores.comb4 <- predict(pca.comb4, sandwich2[, active_vars])

plot(
  pca_scores.comb4[, 1], pca_scores.comb4[, 2],
  col = comb.k4$cluster, pch = 16,
  xlab = "PC1", ylab = "PC2",
  main = "PCA - Final 4-Cluster Solution"
)


# Readable segment labels ---------------------------------------------------

segment_labels <- c(
  "Health-conscious",
  "Flavor-focused",
  "Sustainability-oriented",
  "Premium taste seekers"
)

sandwich$segment_id <- comb.k4$cluster
sandwich$segment <- factor(
  segment_labels[comb.k4$cluster],
  levels = segment_labels
)

table(sandwich$segment)
aggregate(sandwich$Age, list(sandwich$segment), mean)
prop.table(table(sandwich$segment, sandwich$Gender), 1)
prop.table(table(sandwich$segment, sandwich$Education), 1)
prop.table(table(sandwich$segment, sandwich$Area), 1)

# Optional local export
# write.csv(sandwich, "data/consumer_preferences_with_segments.csv", row.names = FALSE)

# Save final portfolio visuals ----------------------------------------------

dir.create("visuals", showWarnings = FALSE)

png("visuals/cluster_sizes_from_R.png", width = 1400, height = 900, res = 160)
barplot(
  100 * prop.table(table(sandwich$segment)),
  ylab = "Share of respondents (%)",
  main = "Segment sizes",
  las = 2
)
dev.off()

png("visuals/cluster_profiles_from_R.png", width = 1600, height = 950, res = 160)
profile_matrix <- as.matrix(final_profiles[, 2:8])
matplot(
  t(profile_matrix),
  type = "b",
  pch = 1:4,
  lty = 1,
  xaxt = "n",
  xlab = "",
  ylab = "Standardized mean",
  main = "Final segment profiles"
)
axis(
  1,
  at = seq_along(active_vars),
  labels = active_vars,
  las = 2
)
legend(
  "bottomleft",
  legend = segment_labels,
  lty = 1,
  pch = 1:4,
  bty = "n"
)
dev.off()

png("visuals/pca_clusters_from_R.png", width = 1400, height = 1000, res = 160)
plot(
  pca_scores.comb4[, 1], pca_scores.comb4[, 2],
  col = comb.k4$cluster,
  pch = 16,
  xlab = "PC1",
  ylab = "PC2",
  main = "PCA - Final 4-Cluster Solution"
)
legend(
  "topright",
  legend = segment_labels,
  col = 1:4,
  pch = 16,
  bty = "n"
)
dev.off()

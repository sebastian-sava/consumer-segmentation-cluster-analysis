# Analysis cleanup notes

The goal of this cleanup was to keep the original submitted analysis recognisable and preserve the final four-cluster solution.

## Changes made

- replaced the local Mac file path with `data/consumer_preferences.csv`;
- removed unused package imports;
- replaced fragile column-number references with named variables where possible;
- fixed the 3-cluster hierarchical gender test, which accidentally called `chisq.test(c3.education)` in the submitted script;
- fixed the final PCA plot so it uses `pca_scores.comb4`, the PCA scores calculated for the final four-cluster solution;
- removed hard-coded comments that stated p-values incorrectly;
- added readable final segment labels;
- added an optional local export line for cluster assignments.

## Intentionally preserved

The submitted workflow first creates a standardized copy of the seven active variables, but the hierarchical `daisy()` distance is calculated from the original 1–7 variables. Because all seven active attributes use the same response scale and because changing this step changes the submitted cluster solution, the public script preserves it and documents it explicitly.

The final solution still uses:

- Ward, centroid and complete-linkage hierarchical clustering;
- 3- and 4-cluster candidate solutions;
- K-means with seed `96743`;
- hierarchical cluster means as K-means starting centres;
- ANOVA and Tukey HSD for age and active attributes;
- chi-square tests for gender, education and area;
- PCA for visual comparison.

## Demographic correction

The original slide narrative contains a few demographic descriptions that do not match the coding in the assignment brief and the final contingency tables.

For example, the assignment defines Gender as `1 = female`, `2 = male`, `3 = other`. The final four-cluster gender table therefore shows:

- Cluster 1: 64 female, 63 male, 5 other
- Cluster 2: 18 female, 154 male
- Cluster 3: 86 female, 19 male, 3 other
- Cluster 4: 24 female, 60 male, 4 other

The public README avoids repeating the incorrect gender descriptions from the slide deck.

## Chi-square warnings

The final gender and education chi-square tests produced R warnings that the chi-square approximation may be inaccurate because some cells are sparse. The tests remain in the script because they were part of the submitted analysis, but their interpretation is deliberately cautious.

## Validation

The final submitted combined solution has cluster sizes of 132, 172, 108 and 88 respondents. The portfolio visuals were regenerated from the final submitted cluster centres and reproduce those sizes and standardized profile means exactly.

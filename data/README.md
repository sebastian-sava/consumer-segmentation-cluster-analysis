# Data

`consumer_preferences.csv` is the public version of the individual course dataset used in this fictional segmentation case.

Changes from the original file:

- removed the `Student` column, which contained only the student number;
- renamed `ID` to `respondent_id`;
- renamed `Bio-content` to `Bio.content` to match the R analysis.

No survey responses were changed.

## Columns

- `Gender`: 1 = female, 2 = male, 3 = other
- `Age`: age in years
- `Education`: 1–5 coded education level
- `Area`: 1 = metropolitan, 2 = urban, 3 = suburban, 4 = countryside
- `Taste`: desired flavor strength, 1–7
- `Fattiness`: desired fat level, 1–7
- `Salt`: desired salt level, 1–7
- `Spreadability`: desired spreadability, 1–7
- `Appearance`: importance/preference for appearance, 1–7
- `Recycling`: preference for recyclable packaging, 1–7
- `Bio.content`: preference for organic/bio content, 1–7
- `respondent_id`: respondent identifier

The seven preference variables are the active variables used for clustering. Demographics are used only for post-cluster profiling.

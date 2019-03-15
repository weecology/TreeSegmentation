# TreeSegmentation

An R package to replicate the submitted work [insert link on submission] using tree segmentation methods in R. This is a companion R package to the python-based
https://github.com/weecology/DeepForest.

This package follows the "Research Compendium" [philosophy](https://github.com/ropensci/rrrpkg/blob/master/README.md) advocated by ROpenSci. It is not meant as a stand alone package, but rather a clear way to document our work.

# Installation

Source can be cloned directly

```
git clone https://github.com/weecology/TreeSegmentation.git
```

Or installed directly into R.

```{r,eval=F}
library(devtools)
install_github("Weecology/TreeSegmentation")
```

## Package structure
* \analysis - The main analysis scripts to generate trees from lidR clouds. These have relative paths which need to be amended by future users.
* \data - The publically available data. This is maintained for legacy purposed. We continue to update NEON evaluated trees https://github.com/weecology/NeonTreeEvaluation

## Example

The main role of the package is to generate training bounding boxes for the deep learning analysis performed in the python. See /analysis/detection_training.

The exploratory analysis document is Evaluate.Rmd. The knitted html can be viewed [here](https://github.com/weecology/TreeSegmentation/blob/master/analysis/Evaluate.html).


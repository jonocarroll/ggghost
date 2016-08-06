## Test environments
* local linux (Ubuntu 14.04) install, R 3.3.0
* travis-ci linux (default)
* travis-ci Mac (default) 
* win-builder (default)
* appveyor-ci (default)

## Code Coverage: 100%

## R CMD check results
**There were no ERRORs or WARNINGs.**

**There was 1 NOTE on local check:**

* checking dependencies in R code ... NOTE  
Unexported objects imported by ':::' calls:  
  ‘ggplot2:::add_ggplot’ ‘ggplot2:::add_theme’  
  See the note in ?`:::` about the use of this operator.  

_I am extending ggplot2's `+` operator, which itself calls unexported functions. Copying the functions to this package requires further unexported functions. If this is an important concern, I can request that these functions be exported._
  
**There was 1 additional NOTE from win-builder:**

New submission

_As I have not previously submitted a package to CRAN._

**There were additional messages from win-builder:**

Possibly mis-spelled words in DESCRIPTION:  
  ggplot (2:35, 6:37)
  
The Title field should be in title case, current version then in title case:  
'Capture the Spirit of Your ggplot Calls'  
'Capture the Spirit of Your Ggplot Calls'  

_These are not mis-spelled as they refer to the plots, not the package ggplot2._


# CHANGES in ggghost 0.2.0
==========

* Allowed inclusion of supplementary data, with recovery (closes #3).

* Added a warning to `recover_data` when data object exists in the calling frame
but has changed since being captured, with opt-out where used interactively 
(closes #4). Note that this is responsible for the less than 100% code coverage
(everything except `if (interactive())` is covered.

* Moved README supplementary objects out of package, reducing package filesize 
(closes #2).

# ggghost 0.1.0
==========

* Initial CRAN submission. No ERRORs, WARNINGs, or NOTEs.
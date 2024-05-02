# squash 0.2.1

* Example courses used in {formation} are converted to qmd and included in tests

# squash 0.2.0

* Rename package

# nq1h 0.1.4

* Use layout syntax instead of .columns to display images side by side in test slides.

# nq1h 0.1.3

* Check if quakr is always up-to-date and informs devs if not.
This is done via `.check_if_quakr_up_to_date()` within the project's `.Rprofile`.

# nq1h 0.1.2

* `compile_qmd_course()` produces html with ThinkR theme rendering
  * quakr extension is copied to the final output directory
  * the `template` parameter allows tho choose a different template

# nq1h 0.1.1

* `compile_qmd_course()` handles the processing of images from individual qmds
  * images are stored in a new companion folder `*_img/chapter_img/img/`

# nq1h 0.1.0

* Functional version of the POC
* `compile_qmd_course()` can compile multiple independent quarto presentations into a single html

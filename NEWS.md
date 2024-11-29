# squash 0.4.2

* Use external extension directory.
* Enable metadata input as yaml
* Update doc to cimplify user example in ReadMe.

# squash 0.4.1

* Set rendering parameters as function parameters instead of yaml file.

# squash 0.4.0

* New feature : set `fix_img_path` to TRUE to enable img embedding with html code.

# squash 0.3.8

* Update quakr to increase text size in slides

# squash 0.3.7

* New feature: add a footer to the html

# squash 0.3.6

* Add admin file to install {squash} on dev containers

# squash 0.3.5

* Improve test slides description text to ease visual check
* Remove fusen structure

# squash 0.3.4

* Use keywords metadata as slide url id if present and check for duplicates

# squash 0.3.3

* Create output directory recursively if does not exist

# squash 0.3.2

* Do not try to fetch img dir when no media is extracted from a qmd

# squash 0.3.1

* Look for quarto project using directory path

# squash 0.3.0

* No file rendering is executed inside the package file architecture
* Rendering progress is tracked with {progressr}
* Quarto compil profile and quakr theme are added to quarto project if not pre-existing

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

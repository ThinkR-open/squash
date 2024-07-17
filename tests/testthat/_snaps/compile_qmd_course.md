# compile_qmd_course renders all input courses inside a unique html output

    Code
      slide_p_content
    Output
       [1] "<p class=\"subtitle\">alpha</p>"                                                                                                                                                        
       [2] "<p>An example code chunk</p>"                                                                                                                                                           
       [3] "<p>An example fenced code chunk</p>"                                                                                                                                                    
       [4] "<p>{dplyr} image</p>"                                                                                                                                                                   
       [5] "<p class=\"subtitle\">omega</p>"                                                                                                                                                        
       [6] "<p>Some text</p>"                                                                                                                                                                       
       [7] "<p>This is a speaker note, it is only visible in the speaker view.</p>"                                                                                                                 
       [8] "<p>two {tidyr} images side by side</p>"                                                                                                                                                 
       [9] "<p><img data-src=\"complete_course_img/M01S01_img/img/logo_2.png\"></p>"                                                                                                                
      [10] "<p><img data-src=\"complete_course_img/M01S01_img/img/logo_2.png\"></p>"                                                                                                                
      [11] "<p class=\"subtitle\">youpi</p>"                                                                                                                                                        
      [12] "<p>Some text</p>"                                                                                                                                                                       
      [13] "<p>Some text again</p>"                                                                                                                                                                 
      [14] "<p>{ggplot2} image</p>"                                                                                                                                                                 
      [15] "<p><br><br></p>"                                                                                                                                                                        
      [16] "<p><img data-src=\"complete_course_img/M02S01-presentation_des_personnes_presentes_img/img/bonjour_smiley.png\"></p>"                                                                   
      [17] "<p><img data-src=\"complete_course_img/M02S01-presentation_des_personnes_presentes_img/img/thinkr-hex.png\"></p>"                                                                       
      [18] "<p class=\"subtitle\">Pourquoi êtes-vous la?</p>"                                                                                                                                       
      [19] "<p>patate chaude</p>"                                                                                                                                                                   
      [20] "<p><img data-src=\"complete_course_img/M02S01-presentation_des_personnes_presentes_img/img/chevalet_blanc.jpg\" class=\"quarto-figure quarto-figure-center\" style=\"width:45.0%\"></p>"
      [21] "<p><img data-src=\"complete_course_img/M02S01-presentation_des_personnes_presentes_img/img/crayon.jpg\" class=\"quarto-figure quarto-figure-center\" style=\"width:45.0%\"></p>"        
      [22] "<p><img src=\"_extensions/ThinkR-open/thinkridentity/logo.png\" class=\"slide-logo\"></p>"                                                                                              
      [23] "<p><strong><i class=\"las la-book\"></i> Formation R</strong> | Retrouvez nous sur <a href=\"https://thinkr.fr\" class=\"uri\">https://thinkr.fr</a></p>"                               

# compile_qmd_course works with non-default parameters

    Code
      first_slide_content
    Output
      [1] "<section id=\"title-slide\" data-background-image=\"_extensions/ThinkR-open/thinkridentity/background.png\" class=\"quarto-title-block center\"><h1 class=\"title\">Trouloulou</h1>\n  <p class=\"subtitle\">66/66/66-66/66/66</p>\n\n<div class=\"quarto-title-authors\">\n</div>\n\n</section>"


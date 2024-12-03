# compile_qmd_course renders all input courses inside a unique html with default params

    Code
      slide_content_by_cat
    Output
      [[1]]
      [1] "Title"          "First chapter"  "Second chapter" "Third chapter" 
      [5] "Fourth chapter" "Fifth chapter" 
      
      [[2]]
       [1] "Slide with code"                      
       [2] "Slide with speaker note"              
       [3] "Slide with image"                     
       [4] "Slide with side-by-side image layout" 
       [5] "Slide with side-by-side image columns"
       [6] "Slide with side-by-side chunk layout" 
       [7] "Slide with side-by-side chunk columns"
       [8] "Slide with text"                      
       [9] "Slide with text"                      
      [10] "Slide with image"                     
      [11] "A ch@ptér wïth spéciàl character$%"   
      [12] "A bullet point list"                  
      [13] "A graph printed with knitr"           
      [14] "An embedded image"                    
      [15] "Two jpg images printed with knitr"    
      [16] "One png image printed with knitr"     
      [17] "A ggplot graph"                       
      [18] "A plot"                               
      [19] "Reading and printing data from csv"   
      
      [[3]]
       [1] "8 * 8"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
       [2] "[1] 64"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
       [3] "```{r}\n6 * 6\n```"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
       [4] "[1] 36"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
       [5] "cat(\"I'm the left chunk output\")\ncat(\"I'm the right chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                               
       [6] "I'm the left chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
       [7] "I'm the right chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
       [8] "cat(\"I'm the left chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
       [9] "I'm the left chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
      [10] "cat(\"I'm the right chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
      [11] "I'm the right chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
      [12] "figure-html/"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      [13] "plot()"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
      [14] "                  X  mpg cyl disp  hp drat    wt  qsec vs am gear carb\n1         Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4\n2     Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4\n3        Datsun 710 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1\n4    Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1\n5 Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2\n6           Valiant 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1"
      

# compile_qmd_course renders all input courses inside a unique html output with dummy theme

    Code
      slide_content_by_cat
    Output
      [[1]]
      [1] "Title"          "First chapter"  "Second chapter" "Third chapter" 
      [5] "Fourth chapter" "Fifth chapter" 
      
      [[2]]
       [1] "Slide with code"                      
       [2] "Slide with speaker note"              
       [3] "Slide with image"                     
       [4] "Slide with side-by-side image layout" 
       [5] "Slide with side-by-side image columns"
       [6] "Slide with side-by-side chunk layout" 
       [7] "Slide with side-by-side chunk columns"
       [8] "Slide with text"                      
       [9] "Slide with text"                      
      [10] "Slide with image"                     
      [11] "A ch@ptér wïth spéciàl character$%"   
      [12] "A bullet point list"                  
      [13] "A graph printed with knitr"           
      [14] "An embedded image"                    
      [15] "Two jpg images printed with knitr"    
      [16] "One png image printed with knitr"     
      [17] "A ggplot graph"                       
      [18] "A plot"                               
      [19] "Reading and printing data from csv"   
      
      [[3]]
       [1] "8 * 8"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
       [2] "[1] 64"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
       [3] "```{r}\n6 * 6\n```"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
       [4] "[1] 36"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
       [5] "cat(\"I'm the left chunk output\")\ncat(\"I'm the right chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                               
       [6] "I'm the left chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
       [7] "I'm the right chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
       [8] "cat(\"I'm the left chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
       [9] "I'm the left chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
      [10] "cat(\"I'm the right chunk output\")"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
      [11] "I'm the right chunk output"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
      [12] "figure-html/"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      [13] "plot()"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
      [14] "plot(1:10, 1:10)"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
      [15] "# export command line\nwrite.csv(mtcars, here::here(\"inst/courses/M02/M02S01-presentations/data/mtcars.csv\"))"                                                                                                                                                                                                                                                                                                                                                                                                       
      [16] "my_data <- read.csv(\"data/mtcars.csv\")\nhead(my_data)"                                                                                                                                                                                                                                                                                                                                                                                                                                                               
      [17] "                  X  mpg cyl disp  hp drat    wt  qsec vs am gear carb\n1         Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4\n2     Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4\n3        Datsun 710 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1\n4    Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1\n5 Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2\n6           Valiant 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1"
      

# compile_qmd_course works with non-default parameters

    Code
      first_slide_content
    Output
      [1] "<section id=\"title-slide\" class=\"quarto-title-block center\"><h1 class=\"title\">Trouloulou</h1>\n  <p class=\"subtitle\">66/66/66-66/66/66</p>\n\n<div class=\"quarto-title-authors\">\n</div>\n\n</section>"

---

    Code
      last_slide_content
    Output
      [1] "<section id=\"trainer\" class=\"slide level2\"><h2>Tralala</h2>\n<p><strong>+33 6 66 66 66 66</strong></p>\n<p><strong>Trili@li</strong></p>\n\n</section>"


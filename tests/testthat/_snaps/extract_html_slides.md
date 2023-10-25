# extract_html_slides returns all html slide classes in correct order

    Code
      html_slide_content
    Output
      <section id="title-slide-1" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Premier Chapitre</h1>
        <p class="subtitle">alpha</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-1" class="slide level2"><h2>Slide 1</h2>
      <p>An example code chunk</p>
      <div class="cell">
      <div class="sourceCode cell-code" id="cb1"><pre class="sourceCode numberSource r number-lines code-with-copy"><code class="sourceCode r"><span id="cb1-1"><a href="#cb1-1"></a><span class="dv">8</span> <span class="sc">*</span> <span class="dv">8</span></span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
      <div class="cell-output cell-output-stdout">
      <pre><code>[1] 64</code></pre>
      </div>
      </div>
      <p>An example fenced code chunk</p>
      <div class="cell">
      <div class="sourceCode cell-code" id="cb3"><pre class="sourceCode numberSource markdown number-lines code-with-copy"><code class="sourceCode markdown"><span id="cb3-1"><a href="#cb3-1"></a><span class="in">```{r}</span></span>
      <span id="cb3-2"><a href="#cb3-2"></a><span class="dv">6</span> <span class="sc">*</span> <span class="dv">6</span></span>
      <span id="cb3-3"><a href="#cb3-3"></a><span class="in">```</span></span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
      <div class="cell-output cell-output-stdout">
      <pre><code>[1] 36</code></pre>
      </div>
      </div>
      </section>
      <section id="slide-1-1" class="slide level2"><h2>Slide 1</h2>
      <p>{dplyr} image</p>
      <p><img data-src="img/logo_1.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Premier Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>
      <section id="title-slide-2" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Deuxième Chapitre</h1>
        <p class="subtitle">omega</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-2" class="slide level2"><h2>Slide 2</h2>
      <p>Texte 2</p>
      <aside class="notes"><p>This is a speaker note, it is only visible in the speaker view.</p>
      <style type="text/css">
              span.MJX_Assistive_MathML {
                position:absolute!important;
                clip: rect(1px, 1px, 1px, 1px);
                padding: 1px 0 0 0!important;
                border: 0!important;
                height: 1px!important;
                width: 1px!important;
                overflow: hidden!important;
                display:block!important;
            }</style></aside></section>
      <section id="slide-2-1" class="slide level2"><h2>Slide 2</h2>
      <p>{tidyr} image</p>
      <p><img data-src="img/logo_2.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Deuxième Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>
      <section id="title-slide-3" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Troisième Chapitre</h1>
        <p class="subtitle">youpi</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-3" class="slide level2"><h2>Slide 3</h2>
      <p>Texte 3</p>
      </section>
      <section id="slide-3-1" class="slide level2"><h2>Slide 3</h2>
      <p>{ggplot2} image</p>
      <p><img data-src="img/logo_1.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Troisième Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>

---

    Code
      html_slide_content_reordered
    Output
      <section id="title-slide-1" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Deuxième Chapitre</h1>
        <p class="subtitle">omega</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-2" class="slide level2"><h2>Slide 2</h2>
      <p>Texte 2</p>
      <aside class="notes"><p>This is a speaker note, it is only visible in the speaker view.</p>
      <style type="text/css">
              span.MJX_Assistive_MathML {
                position:absolute!important;
                clip: rect(1px, 1px, 1px, 1px);
                padding: 1px 0 0 0!important;
                border: 0!important;
                height: 1px!important;
                width: 1px!important;
                overflow: hidden!important;
                display:block!important;
            }</style></aside></section>
      <section id="slide-2-1" class="slide level2"><h2>Slide 2</h2>
      <p>{tidyr} image</p>
      <p><img data-src="img/logo_2.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Deuxième Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>
      <section id="title-slide-2" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Premier Chapitre</h1>
        <p class="subtitle">alpha</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-1" class="slide level2"><h2>Slide 1</h2>
      <p>An example code chunk</p>
      <div class="cell">
      <div class="sourceCode cell-code" id="cb1"><pre class="sourceCode numberSource r number-lines code-with-copy"><code class="sourceCode r"><span id="cb1-1"><a href="#cb1-1"></a><span class="dv">8</span> <span class="sc">*</span> <span class="dv">8</span></span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
      <div class="cell-output cell-output-stdout">
      <pre><code>[1] 64</code></pre>
      </div>
      </div>
      <p>An example fenced code chunk</p>
      <div class="cell">
      <div class="sourceCode cell-code" id="cb3"><pre class="sourceCode numberSource markdown number-lines code-with-copy"><code class="sourceCode markdown"><span id="cb3-1"><a href="#cb3-1"></a><span class="in">```{r}</span></span>
      <span id="cb3-2"><a href="#cb3-2"></a><span class="dv">6</span> <span class="sc">*</span> <span class="dv">6</span></span>
      <span id="cb3-3"><a href="#cb3-3"></a><span class="in">```</span></span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
      <div class="cell-output cell-output-stdout">
      <pre><code>[1] 36</code></pre>
      </div>
      </div>
      </section>
      <section id="slide-1-1" class="slide level2"><h2>Slide 1</h2>
      <p>{dplyr} image</p>
      <p><img data-src="img/logo_1.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Premier Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>
      <section id="title-slide-3" data-background-image="../../_extensions/ThinkR-open/thinkridentity/background.png" class="quarto-title-block center"><h1 class="title">Troisième Chapitre</h1>
        <p class="subtitle">youpi</p>
      
      <div class="quarto-title-authors">
      </div>
      
      </section>
      <section id="slide-3" class="slide level2"><h2>Slide 3</h2>
      <p>Texte 3</p>
      </section>
      <section id="slide-3-1" class="slide level2"><h2>Slide 3</h2>
      <p>{ggplot2} image</p>
      <p><img data-src="img/logo_1.png"></p>
      <p><img src="../../_extensions/ThinkR-open/thinkridentity/logo.png" class="slide-logo"></p>
      <div class="footer footer-default">
      <p><strong><i class="las la-book"></i> Troisième Chapitre</strong> | Retrouvez nous sur <a href="https://thinkr.fr" class="uri">https://thinkr.fr</a></p>
      </div>
      </section>


(use-package ess
  :commands (R julia)
  :mode (("\\.r\\'" . R-mode)
	 ("\\.R\\'" . R-mode)
	 ("\\.Rmd" . poly-markdown+r-mode)
	 ("\\.rmd" . poly-markdown+r-mode)
	 ("\\.jl\\'" . ess-julia-mode))
  :init
  (setq ess-r-package-auto-activate nil)
  (setq ess-default-style 'RStudio)
  (setq ess-use-flymake nil)
  (setq inferior-julia-program "./julia.sh")
  (setq ess-ask-for-ess-directory nil)
  (setq ess-history-file nil)
  (setq comint-scroll-to-bottom-on-input t)
  (setq comint-scroll-to-bottom-on-output t)
  (setq comint-move-point-for-output t)
  (setq ess-r-prettify-symbols '(("%>%"  . ?⟫) ("<-"  . #Xe137) ("function"  . "𝒇") 
	  ("!=" . ?≠) ("==" . ?≡) ("<=" . ?≤) (">=" . ?≥) ("|>" . "▷") 
	  ("%<>%" . ?⟪) ("%in%" . ?∈)))
  :config
  (require 'ess-site)
  (require 'polymode)
  (define-hostmode poly-r-markdown-hostmode
    :mode 'ess-r-mode)
  (define-innermode poly-r-markdown-innermode
    :mode 'markdown-mode
    :head-matcher "#'"
    :tail-matcher "#\\+"
    :head-mode 'body
    :tail-mode 'body)
  (define-polymode poly-r-markdown-mode
    :hostmode 'poly-r-markdown-hostmode
    :innermodes '(poly-r-markdown-innermode))
  (bind-key "C-c j"  'gpk-replace-loop-with-first ess-mode-map)
  (bind-key "C-c w" 'ess-execute-screen-options inferior-ess-mode-map)
  (bind-key "C-c D" 'gpk-set-display inferior-ess-mode-map)
  (bind-key "C-<up>" 'comint-previous-matching-input-from-input inferior-ess-mode-map)
  (bind-key "C-<down>" 'comint-next-matching-input-from-input inferior-ess-mode-map)
  (bind-key "C-c ="  'gpk-ess-clip ess-mode-map)
  (setq comint-input-ring-size 1000)
  (setq-default ess-dialect "R")
  (setq ess-eval-visibly nil)
  (setq ;ess-ask-for-ess-directory nil
   inferior-R-args "--no-save --no-restore")
  (defun gpk-set-display ()
    "Reset R's DISPLAY environment to current SSH host"
    (interactive)
    (ess-command (concat "Sys.setenv(DISPLAY=\"" (alist-get "DISPLAY" (mapcar 'gpk-kv-to-cons (frame-parameter nil 'environment)) nil nil 'equal) "\")\n"))
    )
  
  (defun gpk-replace-loop-with-first ()
    "Replace a loop with setting the variable to first possible value"
    (interactive)
    (save-excursion
      (let ((original (buffer-substring (line-beginning-position) (line-end-position)))
	    )
	(if (string-match " \*for ?(\\(\.\*\\) in \\(\.\*\\)) ?{ \*" original)
	    (ess-eval-linewise (replace-match "\\1 <- (\\2)[[1]]" t nil original) nil nil)
	  )
	)
      )
    (ess-next-code-line 1)
    )
  
  :preface
  (add-hook 'ess-r-mode-hook
	    (lambda ()
	      (if (not (executable-find "R"))
		    (setq inferior-ess-r-program (first (gpk-findr)) )
		)
	      )
	    )
    (defun gpk-rscripts (path)
    "Get a list of potential R-calling scripts in path"
    (append (file-name-all-completions "R-" path) (file-name-all-completions "my-R" path))
    )
  
  (defun gpk-findr ()
    (mapcan (lambda (path) 
	      (mapcar (lambda (r) (concat path r)) (gpk-rscripts path))
	      )
	    (list (or
		   (locate-dominating-file default-directory (lambda(d) (gpk-rscripts d)))
		   (locate-dominating-file "/nemo/stp/babs/working/kellyg/code/launcher/" (lambda(d) (gpk-rscripts d)))))
	    )
    )

  (defun gpk-r-set ()
    "Find R executibles"
    (interactive)
    (setq inferior-ess-r-program (completing-read "R version: "  (gpk-findr)) )
    )

  )





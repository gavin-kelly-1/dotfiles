;; README

;; most global objects are prefixed 'gpk-' - they shouldn't link to my area of the file-system, but they might depend on following my working patterns.

;; Things that are most likely specific to my way of working are probably signalled by use of anything derived from any calls to "user-login-name" or "gpk-babshome".  These are probably worth searching for.

;; Localisation
(if (or
     (string-match "babs" (system-name))
     (string-match "int" (system-name))
     (string-match "login" (system-name))
     )
    (setq gpk-babshome (getenv "my_lab")
	  gpk-oncamp t)
  (setq gpk-babshome "/ssh:babs2:/nemo/stp/babs/"
	gpk-oncamp nil)
  )
(setq inhibit-default-init t)
(setq use-package-always-ensure t)
(defun gpk-magit-status ()
  "Reset the environment variable SSH_AUTH_SOCK"
  (interactive)
    (setenv "SSH_AUTH_SOCK"
            (car (split-string
                  (shell-command-to-string
                   "ls -t $(find /tmp/ssh-* -user $USER -name 'agent.*' 2> /dev/null)"))))
    (magit-status)
    )
;;(setq-default with-editor-emacsclient-executable "emacsclient")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives
 	     '("MELPA" . "https://melpa.org/packages/"))
(package-initialize)
(require 'use-package)
(use-package dash)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Prefs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(setq byte-compile-warnings nil)
;; Appearance


(use-package emacs
  :custom
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  
  (tab-always-indent 'complete)
  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  
  (read-extended-command-predicate #'command-completion-default-include-p)
  )

(use-package hyperbole)
(defil project-dir ":wdir: " "$" ".*"
       '(lambda (x) (
		let ((default-directory (concat gpk-babshome "working/"  x)))
		 (shell (concat "*" (org-entry-get nil "ID") "-shell*"))
		 )
	  )
       nil t)
(defun gpk-wsl-browse (path &optional new-flag)
  "Use WSL's browser"
  (shell-command (concat "wslview " path))
  )

(defun gpk-babs-read ()
  "Get the contents of the .babs file"
  (interactive)
  (aref (yaml-parse-string (with-temp-buffer
		       (insert-file-contents (concat (locate-dominating-file "." ".babs") ".babs") )
		       (buffer-string))
		     :object-type 'alist
		     ) 0)
  )
(defun gpk-goto-org ()
  "Go to the section of the project org relevant to current buffer"
  (interactive)
  (let* ((yml (gpk-babs-read))
	 (id (alist-get 'Hash yml)))
    (find-file (cdr (get-register ?p)))
    (org-match-sparse-tree nil (concat "ID=\"" id "\""))
    )
  )
    
	 
;; (transient-define-prefix gpk-proj-manage ()
;;   "Prefix with descriptions specified with slots."
;;   ["Interface to Gavin's workflow\n" ; yes the newline works
;;    ["Project Management"
;;     ("po" "Open org file" gpk-goto-org)
;;     ("pi" "Github Issues" tsc-suffix-wave)]

;;    ["Group Two"
;;     (:info "Project info")
;;     ("wb" "wave better" tsc-suffix-wave)]]

;;   ["Bad title" :description "Group of Groups"
;;    ["Group Three"
;;     ("k" "bad desc" tsc-suffix-wave :description "key-value wins")
;;     ("n" tsc-suffix-wave :description "no desc necessary")]
;;    [:description "Key Only Def"
;;                  ("wt" "wave too much" tsc-suffix-wave)
;;                  ("we" "wave excessively" tsc-suffix-wave)]])

;; (require 'pcomplete)
;; (use-package pcmpl-args
;;   :after pcomplete)	 



(setq browse-url-browser-function 'gpk/wsl-browse)

(use-package tramp
  :ensure nil
  :config
  (connection-local-set-profile-variables
   'remote-bash
   '((shell-file-name . "/bin/bash")
     (shell-command-switch . "-c")
     (shell-interactive-switch . "-i")
     (shell-login-switch . "-l")
     (tramp-remote-path . ("/nemo/stp/babs/working/kellyg/code/bin" tramp-default-remote-path))
     ))
  (connection-local-set-profiles
   '(:application tramp :protocol "ssh")
   'remote-bash )
  (add-to-list 'tramp-connection-properties
               (list (regexp-quote "/ssh:babs2:")
                     "remote-shell" "/bin/bash"))
  (customize-set-variable 'tramp-encoding-shell "/bin/bash")
  :custom
  (tramp-default-method "ssh")
  )
(use-package rg)

(add-to-list 'tramp-remote-path "/nemo/stp/babs/working/kellyg/code/bin")
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

(setq visible-bell t)
(use-package modus-themes
  :config
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil)

  ;; Maybe define some palette overrides, such as by using our presets
  (setq modus-themes-common-palette-overrides
        modus-themes-preset-overrides-intense)

  ;; Load the theme of your choice.
  (load-theme 'modus-operandi :no-confirm)

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

(set-cursor-color "#532f62") 
(setq cursor-type 'bar)
(setq compilation-scroll-output t)

(require 'recentf)
(recentf-mode t)
(setq recentf-max-saved-items 50)


(setq ibuffer-saved-filter-groups
      '(("home" 
	 ("R scripts" (or
		       (mode . ess-r-mode)
		       (filename . "rmd$")
		       (filename . "Rmd$")
		       ))
	 ("R" (mode . inferior-ess-r-mode))
	 ("Julia scripts" (or
			   (mode . ess-julia-mode)
			   (filename . "jl$")
			   ))
	 ("Julia" (mode . inferior-ess-julia-mode))
	 ("Org" (or
		 (mode . org-mode)
		 (filename . "OrgMode")
		 ))
	 ("dired" (mode . dired-mode))
	 ("emacs" (or
		   (name . "^\\*scratch\\*$")
		   (name . "^\\*Messages\\*$")
		   (filename . ".emacs.d")
		   (filename . ".emacs")
		   (filename . "emacs-config")
		   ))
	 ;; ("Web Dev" (or (mode . html-mode)
	 ;; 		(mode . css-mode)))
	 ("Magit" (name . "^magit"))
	 ("Build" (mode . makefile-gmake-mode))
	 ("Forge" (or (name . "^\\*forge") (name . "^\\*Forge") ))
	 ("Help" (or
		  (name . "Help")
		  (name . "Apropos")
		  (name . "info")
		  ))
	 )))

(setq ibuffer-show-empty-filter-groups nil)
(global-set-key (kbd "C-x C-b") 'ibuffer)
;(dirvish-override-dired-mode)
(add-hook 'ibuffer-mode-hook
	  #'(lambda ()
	     (ibuffer-auto-mode 1)
	     (ibuffer-switch-to-saved-filter-groups "home")))

(use-package gptel)
(gptel-make-anthropic "Claude"          ;Any name you want
  :stream t                             ;Streaming responses
  :key (getenv "CLAUDE_API")
  )
(setq
 gptel-model 'claude-3-5-haiku-20241022 ;  "claude-3-opus-20240229" also available
 gptel-backend (gptel-make-anthropic "Claude"
                 :stream t
		 :key (getenv "CLAUDE_API")
		 )
 )

(use-package activities
  :init
  (activities-mode)
  (activities-tabs-mode)
  ;; Prevent `edebug' default bindings from interfering.
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  :bind
  (("C-x C-a C-n" . activities-new)
   ("C-x C-a C-d" . activities-define)
   ("C-x C-a C-a" . activities-resume)
   ("C-x C-a C-s" . activities-suspend)
   ("C-x C-a C-k" . activities-kill)
   ("C-x C-a RET" . activities-switch)
   ("C-x C-a b" . activities-switch-buffer)
   ("C-x C-a g" . activities-revert)
   ("C-x C-a l" . activities-list)))

(use-package denote
  :custom ((denote-directory "/camp/stp/babs/working/kellyg/docs/notes"))
  )

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))
(define-key global-map (kbd "C-g") #'prot/keyboard-quit-dwim)


(use-package org-modern
  :after org
  :config (global-org-modern-mode)
  :init
  (customize-set-variable 'org-blank-before-new-entry 
                          '((heading . nil)
                            (plain-list-item . nil)))
  (setq org-cycle-separator-lines 2)
  (setq
   ;; Edit settings
   org-todo-keywords
   '((sequence "TODO(t!)" "WIP(p!)" "HOLD(h!)" "WAIT(w!)" "|" "DONE(d!)" "ABANDONED(a!@)" "WON'T DO(k!@)"))
   org-log-into-drawer "HISTORY"
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content nil
   
   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-ellipsis "…"
   ;; org-blank-before-new-entry '((heading . nil)
   ;; 				(plain-list-item . nil))
;;   org-cycle-separator-lines 1
   org-agenda-files '("/nemo/stp/babs/working/kellyg/docs/projects.org")
   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (900 1100 1300 1500 1700)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "← now ─────────────────────────────────────────────────")
  )

(use-package org-review
  :bind (:map org-agenda-mode-map
              ("C-c C-r" . org-review-insert-last-review))
  :init (setq org-agenda-custom-commands
      '(("R" "Review projects" tags-todo "-CANCELLED/"
         ((org-agenda-overriding-header "Reviews Scheduled")
          (org-agenda-skip-function 'org-review-agenda-skip)
          (org-agenda-cmp-user-defined 'org-review-compare)
          (org-agenda-sorting-strategy '(user-defined-down))))))
  )

(defun clip-prop (prop)
  "My personal frame tweaks."
    (plist-get 
 (car (read-from-string (concat "(" (current-kill 0 t) ")" )))
 prop)
    )

(defun convert-time-format (time-str)
  "Convert time from 'dd/mm/yyyy hh:mm:ss' to 'yyyy-mm-dd'."
  (interactive "sEnter time in 'dd/mm/yyyy hh:mm:ss': ")
  (let ((date (split-string time-str " " t))
        (date-parts)
        (time-parts))
    (setq date-parts (split-string (car date) "/")
          time-parts (split-string (cadr date) ":"))
    (if (and (= (length date-parts) 3) (= (length time-parts) 3))
        (format "%s-%s-%s" (nth 2 date-parts) (nth 1 date-parts) (nth 0 date-parts))
      (error "Invalid time format"))))

(defun ticket-capture-target ()
  (find-file "/nemo/stp/babs/working/kellyg/docs/projects.org")
  (let ((sci (clip-prop :Name)))
    (unless (org-find-exact-headline-in-buffer sci)
      (goto-char (org-find-exact-headline-in-buffer  "Projects for Biologists" nil t))
      (next-line)
      (org-insert-heading)
      (insert sci))
    (goto-char (org-find-exact-headline-in-buffer sci nil t))
    ))

(setq org-capture-templates
      `(
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")
	
	("t" "Ticket" entry (function ticket-capture-target)
	 "** %(clip-prop :Subject) [/] 
:PROPERTIES:
:Effort:
:Assigned:
:Lab: %(clip-prop :Lab)
:Created: %u
:Sent: [%(convert-time-format (clip-prop :Sent))]
:END:
*** TODO Address query [/]
 - [ ] Reply to email
 - [ ] Allocate initial contact
 - [ ] Hold Meeting
 - [ ] Scope follow-on work


"
	 )
	)
      )

(setq org-startup-indented t)
(use-package csv-mode
  :mode (".tsv" ".csv" ".tabular" ".vcf")
  )

(use-package minions
   :config (minions-mode 1))

(defun my-frame-tweaks (&optional frame)
  "My personal frame tweaks."
  (unless frame
    (setq frame (selected-frame)))
  (when frame
    (with-selected-frame frame
      (when (display-graphic-p)
	(tool-bar-mode -1))))
  )

(defun my-changelog ()
  (interactive)
  "Insert markdown version history"
  (let ((v (save-excursion
	     (re-search-forward "\\[Version \\(.*\\)\\]")
	     (match-string 1))))
    (insert  (shell-command-to-string (concat
				       "/nemo/stp/babs/working/kellyg/code/bin/git-version.sh v"
				       v))
	     )
    )
  )

;; For the case that the init file runs after the frame has been created
;; Call of emacs without --daemon option.
(my-frame-tweaks)
;; For the case that the init file runs before the frame is created.
;; Call of emacs with --daemon option.
(add-hook 'after-make-frame-functions #'my-frame-tweaks t)

(use-package fontaine
  :init
  (setq fontaine-presets
	'(
          (Iosevka
	   :default-family "Iosevka Nerd Face Mono"
	   :default-height 120
	   :variable-pitch-family "FiraGO"
	   :variable-pitch-height 1.05
	   :line-spacing 1)
          (Jetbrains
	   :default-family "JetBrainsMono Nerd Font Mono"
           :default-height 120
           :variable-pitch-family "FiraGO"
	   :variable-pitch-height 1.05
	   :line-spacing 1)
          (Monaspace
	   :default-family " MonaspiceNe Nerd Font Mono"
           :default-height 120
           :variable-pitch-family "FiraGO"
	   :variable-pitch-height 1.05
	   :line-spacing 1)
	  
	  ))
  (fontaine-set-preset 'Monaspace)
  )

(menu-bar-mode 0) 
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(tool-bar-mode -1); hide the toolbar
(prefer-coding-system 'utf-8)
(display-time-mode t)
(global-prettify-symbols-mode 1)

;;Editing
(global-font-lock-mode t); syntax highlighting
(delete-selection-mode t); entry deletes marked text
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
;(global-visual-line-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill) ; wrap long lines in text mode

;;Shell
(setq shell-file-name "bash")
(setq shell-command-switch "-c")

;; Scrolling
(setq scroll-preserve-screen-position "always"
      scroll-conservatively 5
      scroll-margin 2)
(scroll-lock-mode -1)
(global-set-key (kbd "M-n") (kbd "C-u 1 C-v"))
(global-set-key (kbd "M-p") (kbd "C-u 1 M-v"))
(winner-mode 1)

;;Backup Prefs
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist '(("." . ".~"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t       ; use versioned backups
 vc-make-backup-files t
 )

(defun force-backup-of-buffer ()
  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . ".~/per-session")))
          (kept-new-versions 3))
      (backup-buffer)))
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  (let ((buffer-backed-up nil))
    (backup-buffer)))
(add-hook 'before-save-hook  'force-backup-of-buffer)
;;Spelling
;;(setq ispell-really-hunspell nil)
;;(setq ispell-program-name "/camp/stp/babs/working/kellyg/code/bin/hunspell.sh")
(setq ispell-program-name "aspell")
;;(setq ispell-local-dictionary "en_GB")
;;(setq ispell-hunspell-dict-paths-alist '(("en_GB" "/camp/stp/babs/working/kellyg/docs/en_GB.aff")))

(setq uniquify-buffer-name-style 'post-forward)
(setq uniquify-strip-common-suffix nil)
(remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ace-window
  :defer t
  :init
  (progn
    (global-set-key (kbd "M-o") 'ace-window)
    (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
    ;;more info at https://github.com/abo-abo/ace-window
    )
  )


(use-package easy-hugo
  :init
  (setq easy-hugo-basedir "/camp/stp/babs/working/kellyg/projects/babs/gavin.kelly/blog/")
  (setq easy-hugo-url "https://www.guermantes.xyz")
  (setq easy-hugo-sshdomain "blogdomain")
  (setq easy-hugo-root "/home/blog/")
  (setq easy-hugo-previewtime "300")
  (setq easy-hugo-bloglist
	;; blog2 setting
	'(((easy-hugo-basedir . "/camp/stp/babs/working/kellyg/projects/github/FrancisCrickInstitute/BABS_lab_site")
	   (easy-hugo-url . "https://wiki-bioinformatics.thecrick.org/~kellyg/blog")
	   (easy-hugo-sshdomain . "localhost")
	   (easy-hugo-postdir . "content/post")
	   (easy-hugo-root . "/camp/stp/babs/www/kellyg/public_html/LIVE/blog"))
	  ((easy-hugo-basedir . "/camp/stp/babs/working/kellyg/projects/github/FrancisCrickInstitute/babs-website/")
	   (easy-hugo-url . "https://bioinformatics.thecrick.org/babs")
	   (easy-hugo-sshdomain . "localhost")
	   (easy-hugo-postdir . "content/home")
	   (easy-hugo-root . "website-dev"))
	  ))
  (defun gpk-hugo-no-hidden (dirs)
    (seq-filter
     (lambda (x) (not (string-match-p (regexp-quote "/.") x)))
     dirs)
    )
      
  (advice-add 'easy-hugo--directory-files-recursively :filter-return #'gpk-hugo-no-hidden)
  
  :bind ("C-c C-e" . easy-hugo))


(use-package outshine
  :init
  (setq outshine-use-speed-commands t)
  ;;  (add-hook 'ess-mode-hook 'outshine-mode)
  ;;  (add-hook 'R-mode-hook 'outshine-mode)
  ;;  (add-hook 'julia-mode-hook 'outshine-mode)
  )

(use-package quarto-mode
  :mode (("\\.Rmd" . poly-quarto-mode)
	 ("\\.rmd" . poly-quarto-mode)
	 ("\\.qmd" . poly-quarto-mode))
  )

;; (use-package projectile
;;   :config
;;   (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
;;   (projectile-mode +1))

(use-package detached
  :init
  (detached-init)
  :bind (
         ([remap async-shell-command] . detached-shell-command)
         ([remap compile] . detached-compile)
         ([remap recompile] . detached-compile-recompile)
         ([remap detached-open-session] . detached-consult-session))
  :bind-keymap
  ("C-c d" . detached-embark-action-map)
  :custom ((detached-env "/camp/home/kellyg/.emacs.d/elpa/detached-0.7/detached-env")
           (detached-show-output-on-attach t)
           (detached-shell-history-file "~/.bash_history")))


(use-package magit
  :commands magit-get-top-dir
  :bind ("C-x g" . magit-status)
  )

(use-package forge
  :after magit)

(use-package s)

(use-package expand-region
  :commands er/expand-region
  :bind ("C-=" . er/expand-region))

(use-package undo-tree
  :config
  (global-undo-tree-mode)
  :custom
  (undo-tree-history-directory-alist '(("." . "/camp/stp/babs/scratch/kellyg/undo-tree")))
  )

(use-package web-mode
  :commands web-mode
  :mode (("\\.html\\'" . web-mode)
	 ("\\.php\\'" . web-mode)
	 )
  :config
  (setq web-mode-markup-indent-offset 2)
  )

(use-package corfu
  :init
  (global-corfu-mode)
  )

(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  :bind (:map vertico-map
              ("RET"   . vertico-directory-enter)
              ("DEL"   . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  )

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode)
  )

(use-package pandoc-mode
  :hook markdown-mode)

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc")
  )

(use-package polymode 
  :mode
  ("\\.Snw" . poly-noweb+r-mode)
  ("\\.Rnw" . poly-noweb+r-mode)
  ("\\.Rmd" . poly-markdown+r-mode)
  ("\\.rmd" . poly-markdown+r-mode)
  )

(use-package highlight-parentheses
  :config
  (show-paren-mode t)
  (setq hl-paren-colors '("#1b9e77" "#d95f02" "#7570b3" "#e7298a" "#a6761d" "#e6ab02"))
  (global-highlight-parentheses-mode t)
  )



(use-package treemacs
  :bind ("C-c t" . gpk-treemacsify)
  :bind (:map treemacs-mode-map
         ("W" . treemacs-switch-workspace))
  :init
  (defun gpk-treemacsify ()
    (interactive)
    "Put org projects into treemacs workspaces"
    (treemacs)
    (with-temp-buffer 
      (insert "* active\n")
      (setq active-pos (point-marker))
      (insert "* scientist\n")
      (setq sci-pos (point-marker))
      (insert "* inactive\n")
      (setq inactive-pos (point-marker))
      (insert-file-contents (concat gpk-babshome "www/kellyg/public_html/LIVE/tickets/yml/" user-login-name ".yml"))
      (set-marker-insertion-type active-pos t)
      (set-marker-insertion-type inactive-pos t)
      (set-marker-insertion-type sci-pos t)
      (keep-lines "^  \\(Project\\|Path\\|Active\\|Scientist\\): " inactive-pos (point-max))
      (while (re-search-forward "  Project: " nil t)
	(replace-match "** ")
	(when (re-search-forward "  Scientist: \\(.*\\)" nil t) (setq gpk-sci (car (split-string (match-string 1) "@"))))
	(when (re-search-forward "  Path: " nil t) (replace-match " - path :: "))
	(when (re-search-forward "  Active: \\(True\\|False\\)")
	  (if (string= (match-string 1) "True")
	      (setq gpk-move-to active-pos)
	    (setq gpk-move-to inactive-pos)
	    )
	  (save-excursion
	    (setq end-of-reg (point))
	    (forward-line -3)
	    (kill-region (point) end-of-reg)
	    (goto-char gpk-move-to)
	    (yank)
	    (insert "\n")
	    (goto-char sci-pos)
	    (yank)
	    (insert "\n")
	    (when (re-search-backward "\\*\\*" nil t) (replace-match (concat "** " gpk-sci)))
	    )
	  )
	)
      (beginning-of-buffer)
      (flush-lines "^  Active")
      (beginning-of-buffer)
      (flush-lines "^  Scientist")
      (beginning-of-buffer)
      (while (re-search-forward "/\\.babs$" nil t)
	(replace-match "")
	)
      (insert "\n* templates\n"
       (mapconcat (lambda (path) (concat "** " (file-name-nondirectory (substring path 0 -1)) "\n - path :: " path ))
		  (split-string
		   (shell-command-to-string (concat "ls -d " gpk-babshome "working/" user-login-name "/templates/*/")))
		  "\n" )
       )
      (write-file treemacs-persist-file)
      (treemacs--restore)
      )
    )
  )

(use-package hide-mode-line)


(use-package org-tree-slide
  :hook ((org-tree-slide-play . efs/presentation-setup)
         (org-tree-slide-stop . efs/presentation-end))
  :init
  (defun efs/presentation-setup ()
    ;; Display images inline
    (org-display-inline-images) ;; Can also use org-startup-with-inline-images
    (set-face-attribute 'default nil :family "Iosevka Aile" :height 240 :weight 'normal :width 'normal)
    )
  (defun efs/presentation-end ()
;;    (set-face-attribute 'default nil :family "Iosevka" :height 120 :weight 'normal :width 'normal)
    )
  
  :custom
  (org-tree-slide-activate-message "Presentation started!")
  (org-tree-slide-deactivate-message "Presentation finished!")
  (org-tree-slide-header t)
  (org-tree-slide-breadcrumbs " > ")
  (org-image-actual-width nil)
  )



(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :init
  (persp-mode))

(use-package yasnippet
  :commands
  (yas-minor-mode)
  :init
  (setq yas-indent-line 'fixed)
  (yas-global-mode 1)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'org-mode-hook #'yas-minor-mode)
  (add-hook 'ess-mode-hook #'yas-minor-mode)
  :config
  (yas-reload-all)
  )

(load-file (expand-file-name "gpk/ess.el" user-emacs-directory))
(load-file (expand-file-name "gpk/consult.el" user-emacs-directory))
(load-file (expand-file-name "gpk/compile.el" user-emacs-directory))
(use-package embark
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; work patterns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Abbreviations for standard directories
(defun gpk-abbrev (pth)
  (let ((gpk-abbrev-alist `(("//CAMP/working/USER/projects/" ."PROJ>")
			    ("//CAMP/working/USER/" . "GPK>")
			    ("//CAMP/working/" . "WORK>")
			    ("//CAMP" . "BABS>")
			    (,(getenv "HOME") . "~")
			    ("/home/camp/USER" . "~")
			    )))
    (seq-reduce (lambda (thispth sublist) (replace-regexp-in-string
					   (replace-regexp-in-string "USER" user-login-name
								     (replace-regexp-in-string "^//CAMP/" gpk-babshome (car sublist))
								     )
					   (cdr sublist) thispth))
		gpk-abbrev-alist pth)
    )
  )

;; Use abbreviations in window title
(setq frame-title-format
      '((:eval (gpk-abbrev (if (buffer-file-name)
			       (buffer-file-name)
			     (comint-directory "."))
			   )))
      )

;; Get lab names from directory structure
;; (if gpk-oncamp
;;     (setq gpk-lab-names (append
;; 			 '("external")
;; 			 (directory-files "/camp/lab" nil "^[a-z]")
;; 			 (directory-files "/camp/stp" nil "^[a-z]")))
;;   (setq gpk-lab-names (append
;; 		       '("external")
;; 		       (mapcar 
;; 			(lambda (x) (replace-regexp-in-string "lab-" "" x))
;; 			(directory-files "\\\\data.thecrick.org" nil "^[a-z]"))
;; 		       )
;; 	)
;;   )


;; My bookmarks
(dolist (r `((?e (file . ,(concat "~/.emacs.d/init.el")))
	     (?p (file . ,(concat gpk-babshome "working/" user-login-name "/docs/projects.org")))
	     (?t (file . ,(concat gpk-babshome "working/" user-login-name "/templates")))
	     (?P (file . ,(concat gpk-babshome "working/" user-login-name "/projects")))
	     (?T "## * TODO ")
	     (?c "@crick.ac.uk")
	     ))
  (set-register (car r) (car (cdr r))))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Interacting with slurm
(require 'transient)
(load-file (expand-file-name "gpk/slurm.el" user-emacs-directory))
(load-file (expand-file-name "gpk/slurm-transient.el" user-emacs-directory))
(load-file (expand-file-name "gpk/doit.el" user-emacs-directory))

;;; Interacting with .babs

(defun gpk-get-hash-from-yaml (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (aref (yaml-parse-string (buffer-string)) 0)))

(defun gpk-babs-to-github ()
  "Generate github repository from .babs file details"
  (let* ((babs (gpk-get-hash-from-yaml ".babs"))
	 (project (gethash 'Project babs))
	 (hash (gethash 'Hash babs))
	 (repo-name (concat hash "-" (replace-regexp-in-string "[^A-Za-z0-9_.-]" "-" project)))
	 )
    (ghub-post "/orgs/BABS-STP/repos" `((name . ,repo-name) (private true)))
    (magit-remote-add "origin" (concat "git@github.com:BABS-STP/" repo-name ".git"))
    )
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





			
(put 'narrow-to-region 'disabled nil)

(put 'dired-find-alternate-file 'disabled nil)

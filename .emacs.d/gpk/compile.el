(add-hook 'compilation-start-hook 'compilation-started)
(add-hook 'compilation-finish-functions 'hide-compile-buffer-if-successful)
(defcustom auto-hide-compile-buffer-delay 0
  "Time in seconds before auto hiding compile buffer."
  :group 'compilation
  :type 'number
  )
(defun hide-compile-buffer-if-successful (buffer string)
  (setq compilation-total-time (time-subtract nil compilation-start-time))
  (setq time-str (concat " (Time: " (format-time-string "%s.%3N" compilation-total-time) "s)"))
  
  (if
      (with-current-buffer buffer
        (setq warnings (eval compilation-num-warnings-found))
        (setq warnings-str (concat " (Warnings: " (number-to-string warnings) ")"))
        (setq errors (eval compilation-num-errors-found))
	
        (if (eq errors 0) nil t)
	)
      
      ;;If Errors then
      (message (concat "Compiled with Errors" warnings-str time-str))
    
    ;;If Compiled Successfully or with Warnings then
    (progn
      (bury-buffer buffer)
      (run-with-timer auto-hide-compile-buffer-delay nil 'delete-window (get-buffer-window buffer 'visible))
      (message (concat "Compiled Successfully" warnings-str time-str))
      )
    )
  )

(make-variable-buffer-local 'compilation-start-time)

(defun compilation-started (proc) 
  (setq compilation-start-time (current-time))
  )

(defun gpk-make ()
  (interactive)
  (let* ((mk-dir (locate-dominating-file (buffer-file-name) "makefile"))
         (compile-command (concat "make -k -C " (shell-quote-argument mk-dir)))
         (compilation-read-command nil))
    (call-interactively 'compile)))
(global-set-key "\C-cm" 'gpk-make)

(transient-define-prefix slurmacs ()
  "Slurmacs"
  :value (lambda () (list (concat "--output=" (buffer-file-name) ".out.log")
			  (concat "--error=" (buffer-file-name) ".err.log")
			  (concat "--job-name=" (buffer-name) "")
			  (concat "output_file='" (file-name-base) ".html'")
			  (concat "output_dir='" default-directory
				  (and (eq major-mode `ess-r-mode)
				       (car (ess-get-words-from-vector "dirname(vDevice())\n")) "'"))
			  (concat "params=list(verion='" (magit-git-str "describe") "')" )
			  "--mem=30G"  "--partition=cpu" "--time=1:00:00" "--cpus-per-task=4"
			  ))
  ["Arguments"
   ("-t" "Time Limit" "--time=" :reader gpk-sreader)
   ("-p" "Partition" "--partition=" :reader gpk-sreader)
   ("-c" "CPUs" "--cpus-per-task=" :reader gpk-sreader)
   ("-m" "Memory" "--mem=" :reader gpk-sreader)
   ("-l" "Log" "--output=" :reader gpk-freader)
   ("-e" "Error file" "--error=" :reader gpk-freader)
   ("-j" "Job Name" "--job-name=" :reader gpk-sreader)
   ]
  ["Markdown"
   :if (lambda () (bound-and-true-p poly-markdown+r-mode))
   ("-o" "Output file" "output_file=")
   ("-d" "Output dir" "output_dir=")
   ("-v" "Params" "params=")
   ]
  ["Actions"
   ("s" "Submit to slurm" slurmacs-submit)
   ("b" "Build script" slurmacs-message)
   ("S" "Status" slurm)
   ]
  )
(global-set-key "\C-cs" 'slurmacs)
(defun slurmacs-submit (&optional args)
  "Submit script to CAMP"
  (interactive (list (transient-args 'slurmacs)))
  (let ((script-string (gpk-build-slurm args))
	(inhibit-message t))
    (message script-string)
    (shell-command-to-string script-string)
    )
  )
(defun slurmacs-message (&optional args)
  "Submit script to CAMP"
  (interactive (list (transient-args 'slurmacs)))
  (setq shell-script (gpk-build-slurm args))
  (switch-to-buffer "slurm.sh")
  (insert shell-script)
  )
(defun gpk-build-slurm (args)
  "Make the bash script that will submit to slurm"
  (interactive (list (transient-args 'slurmacs)))
  (let* ((this-file (buffer-file-name (current-buffer)))
	 (all-args (gpk-slurmacs-args 'slurmacs))
	 (slurm-args (gpk-slurmacs-sub-args args all-args "Arguments"))
	 (rmd-args (gpk-slurmacs-sub-args args all-args "Markdown"))
	 (cmd (cond ((bound-and-true-p poly-markdown+r-mode)
		     (concat "R -e \"rmarkdown::render('" this-file "', " (string-join rmd-args ",")"')\"")
		     )
		    ((eq major-mode `ess-r-mode)
		     (concat "Rscript \"" this-file "\"")
		     )
		    (t this-file)
		    )
	      )
	 )
    (concat "sbatch " (string-join slurm-args " ") " <<EOF
#!/bin/bash
source " inferior-ess-r-program "
" cmd  "
[[ -z \"${SLACK_URL}\" ]] || curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"'$SLURM_JOB_NAME' has finished\"}' \"${SLACK_URL}\"
EOF")
    )
  )
(defun gpk-slurmacs-args (trans)
  "Give a grouped list of all arguments in a transient suffix"
  (mapcar (lambda (grp) (cons (plist-get (aref grp 2) :description)
			      (seq-map (lambda (cmd) (plist-get (third cmd) :argument)) (aref grp 3))))
	  (get trans 'transient--layout)
	  ))
(defun gpk-slurmacs-sub-args (args grouped-args group)
  "Find which args belong to a specific group"
  (let (
	(these-args (rest (seq-find (lambda (grp) (string= (car grp) group)) grouped-args)))
	)
    (seq-filter (lambda (argstr)
		  (member (replace-regexp-in-string "\\(=\\).*" "\\1" argstr) these-args)
		  )
		args)
    )
  )



(defun gpk-freader (prompt init hist)
  (let* (
	 (prefix (car (cdr (split-string (symbol-name (oref obj command)) ":")))) ; 'obj' is inherited from transient-infix-read
	 (all-vars (mapcar 'gpk-kv-to-cons (transient-args (intern prefix))))
	 (default (rest (assoc (string-remove-suffix "=" prompt) all-vars)))
	 )
    (read-file-name prompt default)
    )
  )
(defun gpk-kv-to-cons (kv)
  (let ((ss (split-string kv "=")))
    (cons (first ss) (car (cdr ss))))
  )

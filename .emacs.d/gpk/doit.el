(defun gpk-explorer (file)
  "Open windows explorer on current directory, or launch file in windows"
  (interactive "GPath: ")
  (call-process "explorer.exe" nil nil nil (gpk-tramp-to-windows file))
  )


(defun gpk-tramp-to-windows (path)
  "Convert a tramp path to a windows one"
  (replace-regexp-in-string "/" "\\\\" (replace-regexp-in-string "/ssh:babs.:/nemo/stp/" "//data.thecrick.org/" path))
  )

(defalias 'doit 'gpk-explorer)

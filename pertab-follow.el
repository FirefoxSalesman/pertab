;;; package --- pertab-follow: A pertab layout for follow-mode.
;;; Commentary:

;;; Code:
(require 'pertab)

(defvar pertab-follow--old-window-state nil "Window state prior to entering follow layout.")
(defvar pertab-follow--splits 1 "The number of splits to use in follow layout.")
(defvar pertab-follow-enter-hook nil "Hook run when entering follow layout.")
(defvar pertab-follow-exit-hook nil "Hook run when exiting follow layout.")

(defun pertab-follow-enter ()
  "Sets up the follow layout."
  (setq pertab-follow--old-window-state (current-window-configuration))
  (delete-other-windows)
  (follow-mode +1)
  (dotimes (i pertab-follow--splits) (split-window-horizontally))
  (run-hooks 'pertab-follow-enter-hook))

(defun pertab-follow-exit ()
  "Tears down follow layout."
  (follow-mode -1)
  (set-window-configuration pertab-follow--old-window-state)
  (run-hooks 'pertab-follow-exit-hook))

(defun pertab-follow-close ()
  "Close the current window."
  (setq pertab-follow--splits (max 0 (- pertab-follow--splits 1)))
  (pertab-set-tab-local 'pertab-follow--splits pertab-follow--splits)
  (delete-window)
  (balance-windows))

(defun pertab-follow-split ()
  "Split the current window."
  (setq pertab-follow--splits (+ 1 pertab-follow--splits))
  (pertab-set-tab-local 'pertab-follow--splits pertab-follow--splits)
  (split-window-horizontally)
  (balance-windows))

(pertab-register-layout 'follow '((pertab-follow--splits . 1)) (pertab-layout-manager :lighter "|||"
										      :enter-fun 'pertab-follow-enter
										      :exit-fun 'pertab-follow-exit
										      :focus-left-fun 'windmove-left
										      :focus-right-fun 'windmove-right
										      :close-window-fun 'pertab-follow-close
										      :horiz-split-fun 'pertab-follow-split
										      :vert-split-fun 'pertab-follow-split))
(provide 'pertab-follow)
;;; pertab-follow.el ends here

;;; package --- pertab-follow: A pertab layout for follow-mode.
;;; Commentary:

;;; Code:
(require 'pertab)

(defvar pertab-follow--old-window-state nil "Window state prior to entering follow layout.")
(defvar pertab-follow--splits 1 "The number of splits to use in follow layout.")
(defvar pertab-follow-enter-hook nil "Hook run when entering follow layout.")
(defvar pertab-follow-exit-hook nil "Hook run when exiting follow layout.")

(defun pertab-follow-enter (&optional reason)
  "Set up the follow layout. REASON is the reason for entering the layout."
  (follow-mode +1)
  (when (eq reason 'user)
    (setq pertab-follow--old-window-state (current-window-configuration))
    (delete-other-windows)
    (dotimes (i pertab-follow--splits) (split-window-horizontally))
    (balance-windows))
  (pertab-set-tab-local 'pertab-follow--old-window-state pertab-follow--old-window-state)
  (run-hooks 'pertab-follow-enter-hook))

(defun pertab-follow-exit (&optional reason)
  "Tears down follow layout. REASON is the reason for entering the layout."
  (follow-mode -1)
  (when (eq reason 'user)
    (set-window-configuration pertab-follow--old-window-state))
  (pertab-set-tab-local 'pertab-follow--old-window-state pertab-follow--old-window-state)
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

(defun pertab-follow-left ()
  "Move one window to the left, or if we are on the leftmost window, scroll up."
  (if (windmove-find-other-window 'left)
      (windmove-left)
    (scroll-down nil)))

(defun pertab-follow-right ()
  "Move one window to the down, or if we are on the rightmost window, scroll down."
  (if (windmove-find-other-window 'right)
      (windmove-right)
    (scroll-up nil)))

(pertab-register-layout 'follow '((pertab-follow--splits . 1)
				  (pertab-follow--old-window-state . ())) (pertab-layout-manager :lighter "|||"
										      :enter-fun 'pertab-follow-enter
										      :exit-fun 'pertab-follow-exit
										      :focus-left-fun 'pertab-follow-left
										      :focus-right-fun 'pertab-follow-right
										      :close-window-fun 'pertab-follow-close
										      :horiz-split-fun 'pertab-follow-split
										      :vert-split-fun 'pertab-follow-split))

(defun pertab-set-follow ()
  "Set the current layout to follow."
  (interactive)
  (pertab--set-layout 'follow))

(provide 'pertab-follow)
;;; pertab-follow.el ends here

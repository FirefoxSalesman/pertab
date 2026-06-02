;;; package --- pertab-monocle: A monocle layout for pertab.
;;; Commentary:
;; Borrowed from Dakra's Dmacs.

;;; Code:
(require 'pertab)
(defvar pertab-monocle--old-window-state nil "Window state prior to entering the monocle layout.")
(defvar pertab-monocle-enter-hook nil "Hook run when entering monocole layout.")
(defvar pertab-monocle-exit-hook nil "Hook run when exiting monocole layout.")

(defun pertab-monocle-enter (&optional reason)
  "Set up monocole layout. REASON is the reason for entering the layout."
  (when (eq reason 'user)
      (setq pertab-monocle--old-window-state (current-window-configuration)))
  (pertab-set-tab-local 'pertab-monocle--old-window-state pertab-monocle--old-window-state)
  (delete-other-windows)
  (run-hooks 'pertab-monocle-enter-hook))

(defun pertab-monocle-exit (&optional reason)
  "Tear down monocle layout. REASON is the reason for entering the layout."
  (when (eq reason 'user)
      (set-window-configuration pertab-monocle--old-window-state))
  (pertab-set-tab-local 'pertab-monocle--old-window-state pertab-monocle--old-window-state)
  (run-hooks 'pertab-monocle-exit-hook))

(pertab-register-layout 'monocle '((pertab-monocle--old-window-state . ())) (pertab-layout-manager :lighter "[M]"
							    :enter-fun 'pertab-monocle-enter
							    :exit-fun 'pertab-monocle-exit))
(provide 'pertab-monocle)
;;; pertab-monocle.el ends here

;;; package --- pertab-monocle: A monocle layout for pertab.
;;; Commentary:
;; Borrowed from Dakra's Dmacs.

;;; Code:
(require 'pertab)
(defvar pertab-monocle--old-window-state nil "Window state prior to entering monocole layout.")
(defvar pertab-monocle-enter-hook nil "Hook run when entering monocole layout.")
(defvar pertab-monocle-exit-hook nil "Hook run when exiting monocole layout.")

(defun pertab-monocle-enter ()
  "Set up monocole layout."
  (setq pertab-monocle--old-window-state (current-window-configuration))
  (delete-other-windows)
  (run-hooks 'pertab-monocle-enter-hook))

(defun pertab-monocle-exit ()
  "Tear down monocle layout."
  (set-window-configuration pertab-monocle--old-window-state)
  (run-hooks 'pertab-monocle-exit-hook))

(pertab-register-layout 'monocle '() (pertab-layout-manager :lighter "[M]"
							    :enter-fun 'pertab-monocle-enter
							    :exit-fun 'pertab-monocle-exit))
(provide 'pertab-monocle)
;;; pertab-monocle.el ends here

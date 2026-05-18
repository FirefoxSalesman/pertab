;;; pertab-master-stack.el --- A pair of master/stack layouts for pertab -*- lexical-binding: t -*-

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package requires elwm

;;; Code:

(require 'pertab)
(require 'elwm)

(defvar pertab-master-stack-enter-hook nil "Hook run when entering master/stack layout.")
(defvar pertab-master-stack-exit-hook nil "Hook run when exiting master/stack layout.")

(defun pertab-master-stack-enter ()
  "Set up the master/stack layout."
  (setq elwm-current-layout 'tile-vertical-left)
  (pertab-set-tab-local 'elwm-current-layout 'tile-vertical-left)
  (run-hooks 'pertab-master-stack-enter-hook))

(defun pertab-master-stack-exit ()
  "Tear down the master/stack layout."
  (run-hooks 'pertab-master-stack-exit-hook))

(defun pertab-master-stack-deactivate ()
  "Move to the previous window."
  (elwm-activate-window (prefix-numeric-value -1)))

(defun pertab-master-stack-derotate ()
  "Move the windows backwards."
  (elwm-rotate-window (prefix-numeric-value -1)))

(defun pertab-rotate-windows ()
  "Move the windows forwards."
  (elwm-rotate-window 1))

(defun pertab-master-stack-remove-window ()
  "Close the current window."
  (when (elwm--in-master-area-p)
    (elwm-rotate-window 1)
    (elwm-activate-window))
  (delete-window))

(pertab-register-layout 'master-stack '((elwm-current-layout . 'tile-vertical-left))
			(pertab-layout-manager :lighter "[]="
					       :enter-fun 'pertab-master-stack-enter
					       :exit-fun 'pertab-master-stack-exit
					       :horiz-split-fun 'elwm-split-window
					       :vert-split-fun 'elwm-split-window
					       :focus-down-fun 'elwm-activate-window
					       :focus-up-fun 'pertab-master-stack-deactivate
					       :move-down-fun 'pertab-rotate-windows
					       :move-up-fun 'pertab-master-stack-derotate
					       :close-window-fun 'pertab-master-stack-remove-window))

(defvar pertab-master-stack-horizontal-enter-hook nil "Hook run when entering horizontal master/stack layout.")
(defvar pertab-master-stack-horizontal-exit-hook nil "Hook run when exiting horizontal master/stack layout.")

(defun pertab-master-stack-horizontal-enter ()
  "Set up the horizontal master/stack layout."
  (setq elwm-current-layout 'tile-horizontal-top)
  (pertab-set-tab-local 'elwm-current-layout 'tile-horizontal-top)
  (run-hooks 'pertab-master-stack-horizontal-enter-hook))

(defun pertab-master-stack-horizontal-exit ()
  "Tear down the horizontal master/stack layout."
  (run-hooks 'pertab-master-stack-horizontal-exit-hook))

(pertab-register-layout 'master-stack-horizontal '()
			(pertab-layout-manager :lighter "|-|"
					       :enter-fun 'pertab-master-stack-horizontal-enter
					       :exit-fun 'pertab-master-stack-horizontal-exit
					       :horiz-split-fun 'elwm-split-window
					       :vert-split-fun 'elwm-split-window
					       :focus-down-fun 'elwm-activate-window
					       :focus-up-fun 'pertab-master-stack-deactivate
					       :move-down-fun 'pertab-rotate-windows
					       :move-up-fun 'pertab-master-stack-derotate
					       :close-window-fun 'pertab-master-stack-remove-window))

(provide 'pertab-master-stack)
;;; pertab-master-stack.el ends here

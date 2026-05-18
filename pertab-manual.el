;;; pertab-manual.el --- A manual tiling layout for pertab -*- lexical-binding: t -*-

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

;;; Code:

(defvar pertab-manual-enter-hook nil "Hook run when entering manual layout.")
(defvar pertab-manual-exit-hook nil "Hook run when exiting manual layout.")

(defun pertab-manual-enter ()
  "Set up the manual layout."
  (run-hooks 'pertab-manual-stack-enter-hook))

(defun pertab-manual-exit ()
  "Tear down the manual layout."
  (run-hooks 'pertab-manual-stack-exit-hook))

(pertab-register-layout 'manual '()
			(pertab-layout-manager :lighter "[+]"
					       :enter-fun 'pertab-manual-enter
					       :exit-fun 'pertab-manual-exit
					       :horiz-split-fun 'split-window-horizontally
					       :vert-split-fun 'split-window-vertically
					       :focus-left-fun 'windmove-left
					       :focus-right-fun 'windmove-right
					       :focus-down-fun 'windmove-down
					       :focus-up-fun 'windmove-up
					       :move-left-fun 'windmove-swap-states-left
					       :move-right-fun 'windmove-swap-states-right
					       :move-down-fun 'windmove-swap-states-down
					       :move-up-fun 'windmove-swap-states-up
					       :close-window-fun 'delete-window))

(provide 'pertab-manual)
;;; pertab-manual.el ends here

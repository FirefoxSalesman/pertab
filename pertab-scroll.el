;;; pertab-scroll.el --- A scrolling layout for pertab, built using roll.el -*- lexical-binding: t -*-

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

;; This package requires roll

;;; Code:

(require 'pertab)
(require 'roll)

(defun pertab-scroll--roll-enable ()
  "An edited version of roll--enable that makes it play nicely with pertab."
  (if (equal roll--windows '())
      (progn
        (delete-other-windows)
	(setq roll--windows (list (selected-window))))
    (balance-windows))
  (when (equal roll--panes '()) (setq roll--panes (list (roll--make-snapshot))))
  (roll--debug "roll-mode enabled"))
(advice-add 'roll--enable :override 'pertab-scroll--roll-enable)

(defvar pertab-scroll-enter-hook nil "Hook run when entering scrolling layout.")
(defvar pertab-scroll-exit-hook nil "Hook run when exiting scrolling layout.")

(defun pertab-scroll-enter (&optional reason)
  "Set up the scrolling layout. REASON is the reason for entering the layout."
  (roll-mode +1)
  (run-hooks 'pertab-scroll-enter-hook))

(defun pertab-scroll-exit (&optional reason)
  "Tear down the scrolling layout. REASON is the reason for entering the layout."
  (roll-mode -1)
  (pertab-set-tab-local 'roll-max-visible-panes roll-max-visible-panes)
  (pertab-set-tab-local 'roll--panes roll--panes)
  (pertab-set-tab-local 'roll--windows roll--windows)
  (pertab-set-tab-local 'roll--nof-visible-panes roll--nof-visible-panes)
  (pertab-set-tab-local 'roll--first-visible-pane roll--first-visible-pane)
  (run-hooks 'pertab-scroll-exit-hook))

(pertab-register-layout 'scroll '((roll-max-visible-panes . 2)
				  (roll--windows . ())
				  (roll--panes . ())
				  (roll--nof-visible-panes . 1)
				  (roll--first-visible-pane . 0))
			(pertab-layout-manager :lighter "[>]"
					       :enter-fun 'pertab-scroll-enter
					       :exit-fun 'pertab-scroll-exit
					       :horiz-split-fun 'roll-open
					       :vert-split-fun 'roll-open
					       :focus-left-fun 'roll-go-left
					       :focus-right-fun 'roll-go-right
					       :move-left-fun 'roll-move-left
					       :move-right-fun 'roll-move-right
					       :close-window-fun 'roll-close))


(provide 'pertab-scroll)
;;; pertab-scroll.el ends here

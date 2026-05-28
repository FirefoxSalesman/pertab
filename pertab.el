;;; package --- pertab: an implementation of DWM's pertab patch in emacs.
;;; Commentary:
;;; Many thanks to Alphapapa for writing bufler. Without it, I wouldn't have known where to start on this project.

;;; Code:
(require 'tab-bar)
(require 'eieio)

(defvar pertab-default-layout nil "The default layout to use when opening a new tab.")
(defvar pertab--default-tab-local-variables '() "The default values for each tab-local variable.")
(defvar pertab--layout-registry '() "An alist of symbols to their 'pertab-layout-manager' objects.")
(defvar pertab-next-buffer-function 'next-buffer "The function used to move to the next buffer when there is only 1 window.")
(defvar pertab-previous-buffer-function 'previous-buffer "The function used to move to the previous buffer when there is only 1 window.")

(defsubst pertab--get-tab-data (data)
  "Get DATA from current tab. Borrowed from bufler."
  (alist-get data (cdr (tab-bar--current-tab-find))))

(defsubst pertab--get-tab-local-variables ()
  "Gets this tab's alist of local variables."
  (pertab--get-tab-data 'pertab-local-variables))

(defsubst pertab--get-layout-symbol ()
  "Gets this tab's layout symbol."
  (pertab--get-tab-data 'pertab-layout))

(defun pertab--set-tab-parameter (parameter tab value)
  "Set PARAMETER in TAB to VALUE and return it. Stolen directly from Bufler."
  (setf (alist-get parameter (cdr tab)) value))

(defun pertab--add-tab-local-variables ()
  "If the current tab has no tab-local-variables, set them to their default values."
  (unless (pertab--get-tab-local-variables)
    (pertab--set-tab-parameter 'pertab-local-variables (tab-bar--current-tab-find) (copy-alist pertab--default-tab-local-variables))))

(defun pertab-set-tab-local (name value)
  "Set the tab local variable named NAME to VALUE."
  (pertab--add-tab-local-variables)
  (setf (alist-get name (pertab--get-tab-local-variables)) value))

(defun pertab--restore-tab-local-variables ()
  "Restores all tab local variables."
  (pertab--add-tab-local-variables)
  (dolist (pair (pertab--get-tab-local-variables))
    (set (car pair) (cdr pair))))

(defun pertab--get-current-layout ()
  "Returns the current tab's layout object."
  (unless (pertab--get-layout-symbol)
    (pertab--set-tab-parameter 'pertab-layout (tab-bar--current-tab-find) pertab-default-layout))
  (alist-get (pertab--get-layout-symbol) pertab--layout-registry))

(defclass pertab-layout-manager ()
  ((enter-fun :initarg :enter-fun
	      :type function
	      :custom function
	      :initform (lambda ())
	      :documentation "The function to run when entering the layout.")
   (exit-fun :initarg :exit-fun
	     :type function
	     :custom function
	     :initform (lambda ())
	     :documentation "The function to run when exiting the layout.")
   (horiz-split-fun :initarg :horiz-split-fun
		    :type function
		    :custom function
		    :initform (lambda ())
		    :documentation "The function to run when making a horizontal split.")
   (vert-split-fun :initarg :vert-split-fun
		   :type function
		   :custom function
		   :initform (lambda ())
		   :documentation "The function to run when making a vertical split.")
   (focus-left-fun :initarg :focus-left-fun
		   :type function
		   :custom function
		   :initform (lambda ())
		   :documentation "The function to run when focusing the window to the left.")
   (focus-right-fun :initarg :focus-right-fun
		    :type function
		    :custom function
		    :initform (lambda ())
		    :documentation "The function to run when focusing the window to the right.")
   (focus-up-fun :initarg :focus-up-fun
		 :type function
		 :custom function
		 :initform (lambda ())
		 :documentation "The function to run when focusing the window above.")
   (focus-down-fun :initarg :focus-down-fun
		   :type function
		   :custom function
		   :initform (lambda ())
		   :documentation "The function to run when focusing the window below.")
   (move-left-fun :initarg :move-left-fun
		  :type function
		  :custom function
		  :initform (lambda ())
		  :documentation "The function to run when moving the window left.")
   (move-right-fun :initarg :move-right-fun
		   :type function
		   :custom function
		   :initform (lambda ())
		   :documentation "The function to run when moving the window right.")
   (move-up-fun :initarg :move-up-fun
		:type function
		:custom function
		:initform (lambda ())
		:documentation "The function to run when moving the window upwards.")
   (move-down-fun :initarg :move-down-fun
		  :type function
		  :custom function
		  :initform (lambda ())
		  :documentation "The function to run when moving the window downwards.")
   (close-window-fun :initarg :close-window-fun
		     :type function
		     :custom function
		     :initform (lambda ())
		     :documentation "The function to run when closing the current window.")
   (lighter :initarg :lighter
		     :type string
		     :custom string
		     :initform "   "
		     :documentation "The 3 character string to represent this layout with.")))

(defun pertab-register-layout (key local-variables manager)
  "Register a new layout to the layout registry under KEY. LOCAL-VARIABLES should be an alist with variable names as the keys & their default values as the values. MANAGER is the 'pertab-layout-manager' that you wish to register."
  (setf (alist-get key pertab--layout-registry) manager)
  (dolist (pair local-variables)
    (setf (alist-get (car pair) pertab--default-tab-local-variables) (cdr pair))))

(defun pertab-get-lighter ()
  "Return the current layout's lighter."
  (oref (pertab--get-current-layout) lighter))

(defun pertab--do-window-management-action (action)
  "Run the function in the current layout stored in the field of 'pertab-layout-manager' named ACTION."
  (funcall (eieio-oref (pertab--get-current-layout) action)))

(defun pertab-horizontal-split ()
  "Split the current window horizontally, according to the current layout's rules."
  (interactive)
  (pertab--do-window-management-action 'horiz-split-fun))

(defun pertab-vertical-split ()
  "Split the current window vertically, according to the current layout's rules."
  (interactive)
  (pertab--do-window-management-action 'vert-split-fun))

(defun pertab--focus-action (command mono)
  "Run the window management action COMMAND. If only 1 window is active, run MONO instead."
  (if (eq (count-windows) 1)
      (funcall mono))
  (pertab--do-window-management-action command))

(defun pertab-focus-left ()
  "Put keyboard focus on the window to the left, according to the current layout's rules."
  (interactive)
  (pertab--focus-action 'focus-left-fun pertab-previous-buffer-function))

(defun pertab-focus-right ()
  "Put keyboard focus on the window to the right, according to the current layout's rules. If there is only one window, go to the next buffer instead."
  (interactive)
  (pertab--focus-action 'focus-right-fun pertab-next-buffer-function))

(defun pertab-focus-up ()
  "Put keyboard focus on the window above, according to the current layout's rules. If there is only one window, go to the next buffer instead."
  (interactive)
  (pertab--focus-action 'focus-up-fun pertab-previous-buffer-function))

(defun pertab-focus-down ()
  "Put keyboard focus on the window below, according to the current layout's rules. If there is only one window, go to the next buffer instead."
  (interactive)
  (pertab--focus-action 'focus-down-fun pertab-next-buffer-function))

(defun pertab-move-left ()
  "Move the current window to the left, according to the current layout's rules. If there is only one window, go to the next buffer instead."
  (interactive)
  (pertab--do-window-management-action 'move-left-fun))

(defun pertab-move-right ()
  "Move the current window to the right, according to the current layout's rules. If there is only one window, go to the next buffer instead."
  (interactive)
  (pertab--do-window-management-action 'move-right-fun))

(defun pertab-move-up ()
  "Move the current window upwards, according to the current layout's rules."
  (interactive)
  (pertab--do-window-management-action 'move-up-fun))

(defun pertab-move-down ()
  "Move the current window downwards, according to the current layout's rules."
  (interactive)
  (pertab--do-window-management-action 'move-down-fun))

(defun pertab-close-window ()
  "Close the current window, according to the current layout's rules."
  (interactive)
  (if (eq (count-windows) 1)
      (tab-close)
    (pertab--do-window-management-action 'close-window-fun)))

(defun pertab-kill-buffer-close-window ()
  "Kill the current buffer & close the current window, according to the current layout's rules."
  (interactive)
  (kill-current-buffer)
  (pertab-close-window))

(defun pertab--enter-layout ()
  "Run the current layout's entry function."
  (pertab--do-window-management-action 'enter-fun))

(defun pertab--exit-layout (&rest args)
  "Run the current layout's exit function. Ignores ARGS."
  (pertab--do-window-management-action 'exit-fun))

(defun pertab--after-switch-to-tab (&rest args)
  "Meant to be run in 'tab-bar-select-tab' & 'tab-bar-new-tab-to's hooks. Ignores ARGS."
  (pertab--restore-tab-local-variables)
  (pertab--enter-layout))

(define-minor-mode pertab-mode
  "Adds per-tab layout management, similar to dwm's pertag patch."
  :global t
  :keymap (let ((map (make-sparse-keymap))) map)
  (if pertab-mode
      (progn
	(advice-add 'tab-bar-select-tab :before 'pertab--exit-layout)
	(advice-add 'tab-bar-new-tab-to :before 'pertab--exit-layout)
	(advice-add 'other-frame :before 'pertab--exit-layout)
	(advice-add 'other-frame :after 'pertab--after-switch-to-tab)
	(add-hook 'tab-bar-tab-post-select-functions 'pertab--after-switch-to-tab)
	(add-hook 'tab-bar-tab-post-open-functions 'pertab--after-switch-to-tab))
    (advice-remove 'tab-bar-select-tab 'pertab--exit-layout)
    (advice-remove 'tab-bar-new-tab-to 'pertab--exit-layout)
    (advice-remove 'other-frame 'pertab--exit-layout)
    (advice-remove 'other-frame 'pertab--after-switch-to-tab)
    (remove-hook 'tab-bar-tab-post-select-functions 'pertab--after-switch-to-tab)
    (remove-hook 'tab-bar-tab-post-open-functions 'pertab--after-switch-to-tab)))

(defun pertab--set-layout (layout)
  "Set the current tab's layout to LAYOUT."
  (pertab--exit-layout)
  (pertab--set-tab-parameter 'pertab-layout (tab-bar--current-tab-find) layout)
  (pertab--enter-layout))

(defun pertab-layout-menu ()
  "Select a new layout with 'completing-read'."
  (interactive)
  (pertab--set-layout (intern (completing-read "Select a layout: " pertab--layout-registry))))

(provide 'pertab)
;;; pertab.el ends here

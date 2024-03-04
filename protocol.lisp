(in-package #:org.shirakumo.framebuffers)

;;; Backend Internals
(defvar *available-backends* ())
(defvar *backend* NIL)

(defgeneric init-backend (backend))
(defgeneric shutdown-backend (backend))
(defgeneric open-backend (backend &key))

;;; Setup
(defun init ()
  (dolist (backend *available-backends*)
    (handler-case
        (progn (init-backend backend)
               (setf *backend* backend)
               (return-from init backend))
      (error ())))
  (if *available-backends*
      (error "Tried to configure ~{~a~^, ~a~}, but none would start properly." *available-backends*)
      (error "There are no available backends for your system."))

(defun shutdown ()
  (when *backend*
    (shutdown-backend (shiftf *backend* NIL))))

;;; Base class
(defclass window () ())

(defun open (&key width height visible-p &allow-other-keys)
  (apply #'open-backend (or *backend* (init)) args))

;;; Window info
(defgeneric close (window))
(defgeneric width (window))
(defgeneric height (window))
(defgeneric size (window))
(defgeneric (setf size) (size window))
(defgeneric location (window))
(defgeneric (setf location) (location window))
(defgeneric title (window))
(defgeneric (setf title) (title window))
(defgeneric visible-p (window))
(defgeneric (setf visible-p) (state window))
(defgeneric maximized-p (window))
(defgeneric (setf maximized-p) (state window))
(defgeneric iconified-p (window))
(defgeneric (setf iconified-p) (state window))
(defgeneric clipboard-string (window))
(defgeneric (setf clipboard-string) (string window))
(defgeneric content-scale (window))
(defgeneric swap-buffers (window new-buffer))
(defgeneric process-events (window &key timeout))
(defgeneric request-attention (window))

;;; Event callbacks
(defmethod window-moved ((window window) xpos ypos))
(defmethod window-resized ((window window) width height))
(defmethod window-refreshed ((window window)))
(defmethod window-focused ((window window) focused-p))
(defmethod window-iconified ((window window) iconified-p))
(defmethod window-maximized ((window window) maximized-p))
(defmethod mouse-button-changed ((window window) button action modifiers))
;; Buttons: LEFT RIGHT MIDDLE X1 X2 X3
;; Actions: PRESS RELEASE DOUBLE-CLICK
(defmethod mouse-moved ((window window) xpos ypos))
(defmethod mouse-entered ((window window) entered-p))
(defmethod mouse-scrolled ((window window) xoffset yoffset))
(defmethod key-changed ((window window) key scan-code action modifiers))
;; Keys: ...
;; Actions: PRESS RELEASE REPEAT
(defmethod string-entered ((window window) string))
(defmethod file-dropped ((window window) paths))

(in-package #:org.shirakumo.framebuffers)

(define-condition framebuffer-error (error)
  ((window :initarg :window :initform NIL :reader window)))

;;; Window info
(defgeneric valid-p (window))
(defgeneric close (window))
(defgeneric close-requested-p (window))
(defgeneric width (window))
(defgeneric height (window))
(defgeneric size (window))
(defgeneric (setf size) (size window))
(defgeneric minimum-size (window))
(defgeneric (setf minimum-size) (value window))
(defgeneric maximum-size (window))
(defgeneric (setf maximum-size) (value window))
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
(defgeneric focused-p (window))
(defgeneric (setf focused-p) (value window))
(defgeneric borderless-p (window))
(defgeneric (setf borderless-p) (value window))
(defgeneric always-on-top-p (window))
(defgeneric (setf always-on-top-p) (value window))
(defgeneric resizable-p (window))
(defgeneric (setf resizable-p) (value window))
(defgeneric floating-p (window))
(defgeneric (setf floating-p) (value window))
(defgeneric mouse-entered-p (window))
(defgeneric clipboard-string (window))
(defgeneric (setf clipboard-string) (string window))
(defgeneric content-scale (window))
(defgeneric buffer (window))
(defgeneric swap-buffers (window &key x y w h sync))
(defgeneric process-events (window &key timeout))
(defgeneric request-attention (window))
(defgeneric mouse-location (window))
(defgeneric mouse-button-pressed-p (button window))
(defgeneric key-pressed-p (key window))
(defgeneric key-scan-code (key window))
(defgeneric local-key-string (key window))

;;; Event callbacks
(defgeneric window-moved (event-handler xpos ypos))
(defgeneric window-resized (event-handler width height))
(defgeneric window-refreshed (event-handler))
(defgeneric window-focused (event-handler focused-p))
(defgeneric window-iconified (event-handler iconified-p))
(defgeneric window-maximized (event-handler maximized-p))
(defgeneric window-closed (event-handler))
(defgeneric mouse-button-changed (event-handler button action modifiers))
(defgeneric mouse-moved (event-handler xpos ypos))
(defgeneric mouse-entered (event-handler entered-p))
(defgeneric mouse-scrolled (event-handler xoffset yoffset))
(defgeneric key-changed (event-handler key scan-code action modifiers))
(defgeneric string-entered (event-handler string))
(defgeneric file-dropped (event-handler paths))
(defgeneric content-scale-changed (window xscale yscale))

;;; TODO:
;;;; Cursor capturing
;; (defgeneric cursor-state (window))
;; (defgeneric (setf cursor-state) (value window))
;;
;;;; Icons API for cursors and windows
;; (defgeneric icon (window))
;; (defgeneric (setf icon) (value window))
;; (defgeneric cursor-icon (window))
;; (defgeneric (setf cursor-icon) (value window))
;;
;;;; Monitor API to allow fullscreening
;; (defgeneric fullscreen-p (window))
;; (defgeneric (setf fullscreen-p) (value window))
;; (defgeneric list-monitors ())
;; (defgeneric list-modes (monitor))
;; (defgeneric monitor (window))
;; (defgeneric (setf monitor) (value window))
;;
;;;; Input Method support

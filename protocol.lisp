(in-package #:org.shirakumo.framebuffers.int)

;;; Window info
(defgeneric valid-p (window))
(defgeneric close (window))
(defgeneric close-requested-p (window))
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
(defgeneric buffer (window))
(defgeneric swap-buffers (window))
(defgeneric process-events (window &key timeout))
(defgeneric request-attention (window))

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

;;; TODO:
;; minimum-size
;; maximum-size
;; borderless-p
;; always-on-top-p
;; fullscreen-p
;; resizable-p
;; icon
;; cursor-state (hidden, locked, visible)
;; cursor-icon
;; monitor
;; IM

;;; Backend Internals
(defvar *windows-table* (make-hash-table :test 'eql))
(defvar *available-backends* ())
(defvar *backend* NIL)

(defgeneric init-backend (backend))
(defgeneric shutdown-backend (backend))
(defgeneric open-backend (backend &key))

(defun default-title ()
  (format NIL "Framebuffer (~a ~a)" (lisp-implementation-type) (lisp-implementation-version)))

(declaim (inline ptr-int))
(defun ptr-int (ptr)
  (etypecase ptr
    (cffi:foreign-pointer (cffi:pointer-address ptr))
    ((integer 1) ptr)))

(declaim (inline ptr-window))
(defun ptr-window (ptr)
  (gethash (ptr-int ptr) *windows-table*))

(defun (setf ptr-window) (window ptr)
  (if window
      (setf (gethash (ptr-int ptr) *windows-table*) window)
      (remhash (ptr-int ptr) *windows-table*))
  window)

;;; Setup
(define-condition framebuffer-error (error)
  ((window :initarg :window :initform NIL :reader window)))

(defun init ()
  (dolist (backend *available-backends*)
    (handler-case
        (progn (init-backend backend)
               (setf *backend* backend)
               (return-from init backend))
      (error ())))
  (if *available-backends*
      (error "Tried to configure ~{~a~^, ~a~}, but none would start properly." *available-backends*)
      (error "There are no available backends for your system.")))

(defun shutdown ()
  (when *backend*
    (shutdown-backend (shiftf *backend* NIL))
    (clrhash *windows-table*)))

;;; Base class
(defclass window ()
  ((event-handler :initform (make-instance 'event-handler) :accessor event-handler)))

(defmethod initialize-instance :after ((window window) &key event-handler)
  (setf (event-handler window) event-handler))

(defclass event-handler ()
  ((window :initform NIL :initarg :window :accessor window)))

(defmethod (setf event-handler) :before ((handler event-handler) (window window))
  (setf (window handler) window))

(defun open (&rest args &key size location title visible-p &allow-other-keys)
  (declare (ignore size location title visible-p))
  (apply #'open-backend (or *backend* (init)) args))

(defmethod print-object ((window window) stream)
  (print-unreadable-object (window stream :type T :identity T)
    (if (valid-p window)
        (format stream "~dx~d" (width window) (height window))
        (format stream "CLOSED"))))

;;; Impls
(defmethod window-moved ((window window) xpos ypos)
  (window-moved (event-handler window) xpos ypos))
(defmethod window-resized ((window window) width height)
  (window-resized (event-handler window) width height))
(defmethod window-refreshed ((window window))
  (window-refreshed (event-handler window)))
(defmethod window-focused ((window window) focused-p)
  (window-focused (event-handler window) focused-p))
(defmethod window-iconified ((window window) iconified-p)
  (window-iconified (event-handler window) iconified-p))
(defmethod window-maximized ((window window) maximized-p)
  (window-maximized (event-handler window) maximized-p))
(defmethod window-closed ((window window))
  (window-closed (event-handler window)))
(defmethod mouse-button-changed ((window window) button action modifiers)
  (mouse-button-changed (event-handler window) button action modifiers))
(defmethod mouse-moved ((window window) xpos ypos)
  (mouse-moved (event-handler window) xpos ypos))
(defmethod mouse-entered ((window window) entered-p)
  (mouse-entered (event-handler window) entered-p))
(defmethod mouse-scrolled ((window window) xoffset yoffset)
  (mouse-scrolled (event-handler window) xoffset yoffset))
(defmethod key-changed ((window window) key scan-code action modifiers)
  (key-changed (event-handler window) key scan-code action modifiers))
(defmethod string-entered ((window window) string)
  (string-entered (event-handler window) string))
(defmethod file-dropped ((window window) paths)
  (file-dropped (event-handler window) paths))

(defmethod window-moved ((handler event-handler) xpos ypos))
(defmethod window-resized ((handler event-handler) width height))
(defmethod window-refreshed ((handler event-handler)))
(defmethod window-focused ((handler event-handler) focused-p))
(defmethod window-iconified ((handler event-handler) iconified-p))
(defmethod window-maximized ((handler event-handler) maximized-p))
(defmethod window-closed ((handler event-handler)))
(defmethod mouse-button-changed ((handler event-handler) button action modifiers))
(defmethod mouse-moved ((handler event-handler) xpos ypos))
(defmethod mouse-entered ((handler event-handler) entered-p))
(defmethod mouse-scrolled ((handler event-handler) xoffset yoffset))
(defmethod key-changed ((handler event-handler) key scan-code action modifiers))
(defmethod string-entered ((handler event-handler) string))
(defmethod file-dropped ((handler event-handler) paths))

(defclass dynamic-event-handler (event-handler)
  ((handler :initarg :handler :accessor handler)))

(defmethod window-moved ((handler dynamic-event-handler) xpos ypos)
  (funcall (handler handler) 'window-moved (window handler) xpos ypos))
(defmethod window-resized ((handler dynamic-event-handler) width height)
  (funcall (handler handler) 'window-resized (window handler) width height))
(defmethod window-refreshed ((handler dynamic-event-handler))
  (funcall (handler handler) 'window-refreshed (window handler)))
(defmethod window-focused ((handler dynamic-event-handler) focused-p)
  (funcall (handler handler) 'window-focused (window handler) focused-p))
(defmethod window-iconified ((handler dynamic-event-handler) iconified-p)
  (funcall (handler handler) 'window-iconified (window handler) iconified-p))
(defmethod window-maximized ((handler dynamic-event-handler) maximized-p)
  (funcall (handler handler) 'window-maximized (window handler) maximized-p))
(defmethod window-closed ((handler dynamic-event-handler))
  (funcall (handler handler) 'window-closed (window handler)))
(defmethod mouse-button-changed ((handler dynamic-event-handler) button action modifiers)
  (funcall (handler handler) 'mouse-button-changed (window handler) button action modifiers))
(defmethod mouse-moved ((handler dynamic-event-handler) xpos ypos)
  (funcall (handler handler) 'mouse-moved (window handler) xpos ypos))
(defmethod mouse-entered ((handler dynamic-event-handler) entered-p)
  (funcall (handler handler) 'mouse-entered (window handler) entered-p))
(defmethod mouse-scrolled ((handler dynamic-event-handler) xoffset yoffset)
  (funcall (handler handler) 'mouse-scrolled (window handler) xoffset yoffset))
(defmethod key-changed ((handler dynamic-event-handler) key scan-code action modifiers)
  (funcall (handler handler) 'key-changed (window handler) key scan-code action modifiers))
(defmethod string-entered ((handler dynamic-event-handler) string)
  (funcall (handler handler) 'string-entered (window handler) string))
(defmethod file-dropped ((handler dynamic-event-handler) paths)
  (funcall (handler handler) 'file-dropped (window handler) paths))

(defmacro with-window ((window &rest initargs) &body handlers)
  (let ((handle (gensym "HANDLE"))
        (event-type (gensym "EVENT-TYPE"))
        (args (gensym "ARGS")))
    `(flet ((,handle (,event-type ,window &rest ,args)
              (case ,event-type
                ,@(loop for (type lambda-list . body) in handlers
                        collect (if (eql T type)
                                    `(,type (destructuring-bind ,lambda-list (list* ,event-type ,args)
                                              ,@body))
                                    `(,type (destructuring-bind ,lambda-list ,args
                                              ,@body)))))))
       (let ((,window (open :event-handler (make-instance 'dynamic-event-handler :handler #',handle) ,@initargs)))
         (unwind-protect
              (loop initially (,handle 'init ,window)
                    finally (,handle 'shutdown ,window)
                    until (close-requested-p ,window)
                    do (process-events ,window :timeout T))
           (close ,window))))))

(in-package #:org.shirakumo.framebuffers.wayland.cffi)

(cffi:define-foreign-library wayland
  (T (:or (:default "libwayland-client") (:default "wayland-client"))))

;;; core defs
(defconstant MARSHAL-FLAG-DESTROY 1)

(cffi:defcstruct (message :conc-name message-)
  (name :string)
  (signature :string)
  (types :pointer))

(cffi:defcstruct (interface :conc-name interface-)
  (name :string)
  (version :int)
  (method-count :int)
  (methods :pointer)
  (event-count :int)
  (events :pointer))

(cffi:defcunion argument
  (i :int32)
  (u :uint32)
  (f :int32)
  (s :string)
  (o :pointer)
  (n :uint32)
  (a :pointer)
  (h :int32))

(cffi:defcfun (event-queue-destroy "wl_event_queue_destroy") :void
  (queue :pointer))

(cffi:defcfun (proxy-marshal-array-flags "wl_proxy_marshal_array_flags") :pointer
  (proxy :pointer)
  (opcode :uint32)
  (interface :pointer)
  (version :uint32)
  (flags :uint32)
  (args :pointer))

(defmacro define-vararg (name lambda-list call)
  (let ((args (car (last lambda-list)))
        (arglist (gensym "ARGLIST")))
    `(progn (defun ,name ,lambda-list
              (if ,args
                  (cffi:with-foreign-objects ((,arglist '(:union argument) (length ,args)))
                    (loop for i from 0
                          for arg in ,args
                          do (setf (cffi:mem-aref ,arglist '(:union argument) i) arg))
                    (let ((,args ,arglist))
                      ,call))
                  (let ((,args (cffi:null-pointer)))
                    ,call)))
            (define-compiler-macro ,name ,lambda-list
              (if ,args
                  `(cffi:with-foreign-objects ((,',arglist '(:union argument) ,(length ,args)))
                     ,@(loop for i from 0
                             for arg in ,args
                             collect `(setf (cffi:mem-aref ,',arglist '(:union argument) ,i) ,arg))
                     (let ((,',args ,',arglist)
                           ,@(list ,@(loop for arg in lambda-list
                                           until (eql arg '&rest)
                                           collect `(list ',arg ,arg))))
                       ,',call))
                  `(let ((,',args (cffi:null-pointer))
                         ,@(list ,@(loop for arg in lambda-list
                                         until (eql arg '&rest)
                                         collect `(list ',arg ,arg))))
                     ,',call))))))

(define-vararg proxy-marshal-flags (proxy opcode interface version flags &rest args)
  (proxy-marshal-array-flags proxy opcode interface version flags args))

(cffi:defcfun (proxy-marshal-array "wl_proxy_marshal_array") :void
  (p :pointer)
  (opcode :uint32)
  (args :pointer))

(define-vararg proxy-marshal (proxy opcode &rest args)
  (proxy-marshal-array proxy opcode args))

(cffi:defcfun (proxy-create "wl_proxy_create") :pointer
  (factory :pointer)
  (interface :pointer))

(cffi:defcfun (proxy-create-wrapper "wl_proxy_create_wrapper") :pointer
  (proxy :pointer))

(cffi:defcfun (proxy-wrapper-destroy "wl_proxy_wrapper_destroy") :void
  (proxy_wrapper :pointer))

(cffi:defcfun (proxy-marshal-array-constructor "wl_proxy_marshal_array_constructor") :pointer
  (proxy :pointer)
  (opcode :uint32)
  (args :pointer)
  (interface :pointer))

(define-vararg proxy-marshal-constructor (proxy opcode interface &rest args)
  (proxy-marshal-array-constructor proxy opcode args interface))

(cffi:defcfun (proxy-marshal-array-constructor-versioned "wl_proxy_marshal_array_constructor_versioned") :pointer
  (proxy :pointer)
  (opcode :uint32)
  (args :pointer)
  (interface :pointer)
  (version :uint32))

(define-vararg proxy-marshal-constructor-versioned (proxy opcode interface version &rest args)
  (proxy-marshal-array-constructor-versioned proxy opcode args interface version))

(cffi:defcfun (proxy-destroy "wl_proxy_destroy") :void
  (proxy :pointer))

(cffi:defcfun (proxy-add-listener "wl_proxy_add_listener") :int
  (proxy :pointer)
  (implementation :pointer)
  (data :pointer))

(cffi:defcfun (proxy-get-listener "wl_proxy_get_listener") :pointer
  (proxy :pointer))

(cffi:defcfun (proxy-add-dispatcher "wl_proxy_add_dispatcher") :int
  (proxy :pointer)
  (dispatcher_func :pointer)
  (dispatcher_data :pointer)
  (data :pointer))

(cffi:defcfun (proxy-set-user-data "wl_proxy_set_user_data") :void
  (proxy :pointer)
  (user_data :pointer))

(cffi:defcfun (proxy-get-user-data "wl_proxy_get_user_data") :pointer
  (proxy :pointer))

(cffi:defcfun (proxy-get-version "wl_proxy_get_version") :uint32
  (proxy :pointer))

(cffi:defcfun (proxy-get-id "wl_proxy_get_id") :uint32
  (proxy :pointer))

(cffi:defcfun (proxy-set-tag "wl_proxy_set_tag") :void
  (proxy :pointer)
  (tag :pointer))

(cffi:defcfun (proxy-get-tag "wl_proxy_get_tag") :pointer
  (proxy :pointer))

(cffi:defcfun (proxy-get-class "wl_proxy_get_class") :string
  (proxy :pointer))

(cffi:defcfun (proxy-set-queue "wl_proxy_set_queue") :void
  (proxy :pointer)
  (queue :pointer))

(cffi:defcfun (display-connect "wl_display_connect") :pointer
  (name :string))

(cffi:defcfun (display-connect-to-fd "wl_display_connect_to_fd") :pointer
  (fd :int))

(cffi:defcfun (display-disconnect "wl_display_disconnect") :void
  (display :pointer))

(cffi:defcfun (display-get-fd "wl_display_get_fd") :int
  (display :pointer))

(cffi:defcfun (display-dispatch "wl_display_dispatch") :int
  (display :pointer))

(cffi:defcfun (display-dispatch-queue "wl_display_dispatch_queue") :int
  (display :pointer)
  (queue :pointer))

(cffi:defcfun (display-dispatch-queue-pending "wl_display_dispatch_queue_pending") :int
  (display :pointer)
  (queue :pointer))

(cffi:defcfun (display-dispatch-pending "wl_display_dispatch_pending") :int
  (display :pointer))

(cffi:defcfun (display-get-error "wl_display_get_error") :int
  (display :pointer))

(cffi:defcfun (display-get-protocol-error "wl_display_get_protocol_error") :uint32
  (display :pointer)
  (interface :pointer)
  (id :pointer))

(cffi:defcfun (display-flush "wl_display_flush") :int
  (display :pointer))

(cffi:defcfun (display-roundtrip-queue "wl_display_roundtrip_queue") :int
  (display :pointer)
  (queue :pointer))

(cffi:defcfun (display-roundtrip "wl_display_roundtrip") :int
  (display :pointer))

(cffi:defcfun (display-create-queue "wl_display_create_queue") :pointer
  (display :pointer))

(cffi:defcfun (display-prepare-read-queue "wl_display_prepare_read_queue") :int
  (display :pointer)
  (queue :pointer))

(cffi:defcfun (display-prepare-read "wl_display_prepare_read") :int
  (display :pointer))

(cffi:defcfun (display-cancel-read "wl_display_cancel_read") :void
  (display :pointer))

(cffi:defcfun (display-read-events "wl_display_read_events") :int
  (display :pointer))

(cffi:defcfun (log-set-handler-client "wl_log_set_handler_client") :void
  (handler :pointer))

;;; protocol defs
(defconstant DISPLAY-SYNC 0)
(defconstant DISPLAY-GET-REGISTRY 1)
(defconstant REGISTRY-BIND 0)
(defconstant COMPOSITOR-CREATE-SURFACE 0)
(defconstant COMPOSITOR-CREATE-REGION 1)
(defconstant SHM-POOL-CREATE-BUFFER 0)
(defconstant SHM-POOL-DESTROY 1)
(defconstant SHM-POOL-RESIZE 2)
(defconstant SHM-CREATE-POOL 0)
(defconstant BUFFER-DESTROY 0)
(defconstant DATA-OFFER-ACCEPT 0)
(defconstant DATA-OFFER-RECEIVE 1)
(defconstant DATA-OFFER-DESTROY 2)
(defconstant DATA-OFFER-FINISH 3)
(defconstant DATA-OFFER-SET-ACTIONS 4)
(defconstant DATA-SOURCE-OFFER 0)
(defconstant DATA-SOURCE-DESTROY 1)
(defconstant DATA-SOURCE-SET-ACTIONS 2)
(defconstant DATA-DEVICE-START-DRAG 0)
(defconstant DATA-DEVICE-SET-SELECTION 1)
(defconstant DATA-DEVICE-RELEASE 2)
(defconstant DATA-DEVICE-MANAGER-CREATE-DATA-SOURCE 0)
(defconstant DATA-DEVICE-MANAGER-GET-DATA-DEVICE 1)
(defconstant SHELL-GET-SHELL-SURFACE 0)
(defconstant SHELL-SURFACE-PONG 0)
(defconstant SHELL-SURFACE-MOVE 1)
(defconstant SHELL-SURFACE-RESIZE 2)
(defconstant SHELL-SURFACE-SET-TOPLEVEL 3)
(defconstant SHELL-SURFACE-SET-TRANSIENT 4)
(defconstant SHELL-SURFACE-SET-FULLSCREEN 5)
(defconstant SHELL-SURFACE-SET-POPUP 6)
(defconstant SHELL-SURFACE-SET-MAXIMIZED 7)
(defconstant SHELL-SURFACE-SET-TITLE 8)
(defconstant SHELL-SURFACE-SET-CLASS 9)
(defconstant SURFACE-DESTROY 0)
(defconstant SURFACE-ATTACH 1)
(defconstant SURFACE-DAMAGE 2)
(defconstant SURFACE-FRAME 3)
(defconstant SURFACE-SET-OPAQUE-REGION 4)
(defconstant SURFACE-SET-INPUT-REGION 5)
(defconstant SURFACE-COMMIT 6)
(defconstant SURFACE-SET-BUFFER-TRANSFORM 7)
(defconstant SURFACE-SET-BUFFER-SCALE 8)
(defconstant SURFACE-DAMAGE-BUFFER 9)
(defconstant SURFACE-OFFSET 10)
(defconstant SEAT-GET-POINTER 0)
(defconstant SEAT-GET-KEYBOARD 1)
(defconstant SEAT-GET-TOUCH 2)
(defconstant SEAT-RELEASE 3)
(defconstant POINTER-SET-CURSOR 0)
(defconstant POINTER-RELEASE 1)
(defconstant KEYBOARD-RELEASE 0)
(defconstant TOUCH-RELEASE 0)
(defconstant OUTPUT-RELEASE 0)
(defconstant REGION-DESTROY 0)
(defconstant REGION-ADD 1)
(defconstant REGION-SUBTRACT 2)
(defconstant SUBCOMPOSITOR-DESTROY 0)
(defconstant SUBCOMPOSITOR-GET-SUBSURFACE 1)
(defconstant SUBSURFACE-DESTROY 0)
(defconstant SUBSURFACE-SET-POSITION 1)
(defconstant SUBSURFACE-PLACE-ABOVE 2)
(defconstant SUBSURFACE-PLACE-BELOW 3)
(defconstant SUBSURFACE-SET-SYNC 4)
(defconstant SUBSURFACE-SET-DESYNC 5)

(cffi:defcvar (surface-interface "wl_surface_interface") (:struct interface))
(cffi:defcvar (registry-interface "wl_registry_interface") (:struct interface))
(cffi:defcvar (shell-surface-interface "wl_shell_surface_interface") (:struct interface))
(cffi:defcvar (shm-pool-interface "wl_shm_pool_interface") (:struct interface))
(cffi:defcvar (buffer-interface "wl_buffer_interface") (:struct interface))
(cffi:defcvar (callback-interface "wl_callback_interface") (:struct interface))

(defmacro define-listener (name &body callbacks)
  `(progn (cffi:defcstruct (,name :conc-name ,(intern (format NIL "~a-" (symbol-name name))))
            ,@(loop for (cb) in callbacks collect `(,cb :pointer)))
          
          ,@(loop for (cb ret args . body) in callbacks
                  when ret
                  collect `(cffi:defcallback ,(intern (format NIL "~a-~a" (symbol-name name) (symbol-name cb))) ,ret ,args 
                             ,@body))

          (defun ,(intern (format NIL "~a-~a" (symbol-name :make) name)) (&optional (struct (cffi:foreign-alloc '(:struct ,name))))
            ,@(loop for (cb ret args . body) in callbacks
                    for slot = (intern (format NIL "~a-~a" (symbol-name name) (symbol-name cb)))
                    collect `(setf (,slot struct) ,(if ret `(cffi:callback ,slot) '(cffi:null-pointer))))
            struct)))

#++
(define-listener display-listener
  (error :void ((data :pointer) (display :pointer) (object-id :pointer) (code :uint32) (message :string)))
  (delete-id :void ((data :pointer) (display :pointer) (id :uint32))))

(defmacro define-marshal-fun (name interface args)
  (let ((object (gensym "OBJECT")))
    `(defun ,name (,object ,@(loop for arg in args when (and arg (symbolp arg)) collect arg))
       (proxy-arshal-flags ,object
                           ,name
                           ,(if interface `(cffi:get-var-pointer ',interface) '(cffi:null-pointer))
                           (proxy-get-version ,object)
                           0
                           ,@(loop for arg in args collect (or arg '(cffi:null-pointer)))))))

(defun buffer-destroy (buffer)
  (proxy-marshal-flags buffer BUFFER-DESTROY (cffi:null-pointer) (proxy-get-version buffer) MARSHAL-FLAG-DESTROY))

(define-marshal-fun compositor-create-surface surface-interface (NIL))

(define-marshal-fun display-get-registry registry-interface (NIL))

(define-marshal-fun pointer-set-cursor NIL (serial surface hotspot-x hotspot-y))

(defun registry-bind (registry name interface version)
  (proxy-marshal-flags registry REGISTRY-BIND interface version 0 name (interface-name interface) version (cffi:null-pointer)))

(define-marshal-fun shell-get-shell-surface shell-surface-interface (NIL surface))

(define-marshal-fun shell-surface-pong NIL (serial))

(define-marshal-fun shell-surface-set-title NIL (title))

(define-marshal-fun shell-surface-set-toplevel NIL ())

(define-marshal-fun shm-create-pool shm-pool-interface (NIL fd size))

(define-marshal-fun shm-pool-create-buffer buffer-interface (NIL offset width height stride format))

(define-marshal-fun shm-pool-resize NIL (size))

(define-marshal-fun surface-attach NIL (buffer x y))

(define-marshal-fun surface-commit NIL ())

(define-marshal-fun surface-damage NIL (x y width height))

(define-marshal-fun surface-frame callback-interface (NIL))
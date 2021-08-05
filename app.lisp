(ql:quickload '(:ningle :djula :lack :cl-ppcre))
(djula:add-template-directory  #P"templates/")
(defparameter *template-registry* (make-hash-table :test 'equal))

;; render template - copied & modified from caveman
(defun render (template-path &optional data)
  (let ((html (make-string-output-stream))
	(template (gethash template-path *template-registry*)))
    (unless template
      (setf template (djula:compile-template* (princ-to-string template-path)))
      (setf (gethash template-path *template-registry*) template))
    (apply #'djula:render-template* template html data)
    `(200 (:content-type "text/html")
	  (,(format nil "~a" (get-output-stream-string html))))))

(defvar *app* (make-instance 'ningle:app))

(setf (ningle:route *app* "/") (render #P"index.html"))
(lack:builder
 :session
 (:static
  :path "/public/"  :root #P"static/")

 (lambda (app)
   (lambda (env)
     (print env)
     (funcall app env)))
 *app*)

;; *app*


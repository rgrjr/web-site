(in-package :common-lisp-user)

(defun map-elts (tree functional)
  (if (arrayp tree)
      (dotimes (i (length tree))
	(map-elts (aref tree i) functional))
      (funcall functional tree)))

;;; Implementation of catch & throw via closures:

(defvar *catch-list* nil
  "Currently available throw tags.  This is either NIL,
or a three-element array of [tag, closure, outer], where:

    tag     is the catch tag,
    closure is the thing to call to throw to it, and
    outer   is the next outer *catch-list* entry.")

(defun clo-catch (tag body-function)
  (let ((*catch-list*
	  (vector tag
		  #'(lambda (value)
		      (return-from clo-catch value))
		  *catch-list*)))
    (funcall body-function)))

(defun clo-throw (tag value)
  (do ((tail *catch-list*
             (aref tail 2)))
      ((null tail)
        (error "No such tag:  ~S" tag))
    (if (eq (aref tail 0) tag)
        (funcall (aref tail 1) value))))

;;; Element processing using the above:

(defun process-elt (elt limit)
  (when (> elt limit)
    (format t "Found ~S~%" elt)
    (clo-throw 'found elt)))

(defun process-elts (tree arg)
  (clo-catch
    'found
    #'(lambda ()
	(map-elts tree #'(lambda (value)
			   (process-elt value arg)))
	"nothing")))

;; Test with a silly data structure.
(defvar data #(1 2 3 #(4 5 4) #(#(7 8 #(9 10)) 11)))
(dolist (x '(6 8 99))
  (format t "Returned ~A for ~A.~%" (process-elts data x) x))

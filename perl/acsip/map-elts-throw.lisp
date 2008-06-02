(in-package :common-lisp-user)

(defun map-elts (tree functional)
  (if (arrayp tree)
      (dotimes (i (length tree))
	(map-elts (aref tree i) functional))
      (funcall functional tree)))

(defun process-elt (elt limit)
  (when (> elt limit)
    (format t "Found ~S~%" elt)
    (throw 'found elt)))

(defun process-elts (tree arg)
  (catch 'found
    (map-elts tree #'(lambda (value)
		       (process-elt value arg)))
    "nothing"))

;; Test with a silly data structure.
(defvar data #(1 2 3 #(4 5 4) #(#(7 8 #(9 10)) 11)))
(dolist (x '(6 8 99))
  (format t "Returned ~A for ~A.~%" (process-elts data x) x))

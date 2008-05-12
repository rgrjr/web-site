(in-package :common-lisp-user)

(defun map-elts (tree functional)
  (if (arrayp tree)
      (dotimes (i (length tree))
	(map-elts (aref tree i) functional))
      (funcall functional tree)))

(defun find-if-greater (tree limit)
  (map-elts tree #'(lambda (value)
		     (when (> value limit)
		       (format t "Found ~S~%" value)
		       (return-from find-if-greater value))))
  "nothing")

;; Test with a silly data structure.
(defvar data #(1 2 3 #(4 5 4) #(#(7 8 #(9 10)) 11)))
(dolist (x '(7 99))
  (format t "Returned ~A for ~A.~%" (find-if-greater data x) x))

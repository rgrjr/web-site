(in-package :common-lisp-user)

(defun test-1 (x)
  (multiple-value-bind (v1 v2)
      (unwind-protect
	   (test-2 x)
	(format t "Unwinding.~%"))
    (format t "Returning ~S and ~S.~%" v1 v2)
    (list v1 v2 t)))

(defun test-2 (x)
  (format t "Doing something hairy with ~S.~%" x)
  (if (numberp x)
      (values (* x 3) x)
      (error "~S is not a number." x)))

(dolist (thing '(3 5 oops))
  (handler-case
      (let ((result (test-1 thing)))
	(format "Value ~S yielded result ~S.~%" thing result))
    (error (x)
      (format t "Oops, got an error ~A for ~S.~%" x thing))))

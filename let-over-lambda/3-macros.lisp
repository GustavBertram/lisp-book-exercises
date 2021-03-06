;;;; MACRO BASICS
;; Contains code from Let Over Lambda, Chapter 3.

;;; Domain specific languages --------------------------------------------------

(sleep 180)

(sleep (* 3 60))

(defun sleep-minutes (m)
  (sleep (* m 60)))

(defun sleep-units% (value unit)
  (sleep
    (* value
       (case unit
         ((s) 1)
         ((m) 60)
         ((h) 3600)
         ((d) 86400)
         ((ms) 1/1000)
         ((us) 1/1000000)))))

(defmacro sleep-units (value unit)
  `(sleep
     (* ,value
        ,(case unit
           ((s) 1)
           ((m) 60)
           ((h) 3600)
           ((d) 86400)
           ((ms) 1/1000)
           ((us) 1/1000000)))))

(sleep-units 5 s)

(defmacro unit-of-time (value unit)
  `(* ,value
      ,(case unit
         ((s) 1)
         ((m) 60)
         ((h) 3600)
         ((d) 86400)
         ((ms) 1/1000)
         ((us) 1/1000000))))

(unit-of-time 1 d)

;;; Control structures ---------------------------------------------------------

;; Replicates LET functionality from Scheme
(defmacro nlet (n letargs &rest body)
  `(labels ((,n ,(mapcar #'car letargs)
              ,@body))
     (,n ,@(mapcar #'cadr letargs))))

(defun nlet-fact (n)
  (nlet fact ((n n))
        (if (zerop n)
            1
            (* n (fact (1- n))))))

(macroexpand
 '(nlet fact ((n n))
   (if (zerop n)
       1
       (* n (fact (1- n))))))

;;; Free variables -------------------------------------------------------------

;; X is a free variable
;; (+ 1 x)

(let ((x 1)) ; X is captured
  (+ 1 x))

;; Free variable injection
(defmacro x-injector ()
  'x)

;;; Unwanted capture -----------------------------------------------------------

;; NIF from On Lisp
;; (nif x "positive" "zero" "negative")

(defmacro nif-buggy (expr pos zero neg)
  `(let ((obscure-name ,expr))
     (cond ((plusp obscure-name) ,pos)
           ((zerop obscure-name) ,zero)
           (t ,neg))))

(defparameter x 10)

;; No bug
(nif-buggy
 x
 (let ((obscure-name 'pos))
   obscure-name)
 'zero
 'neg)

;; Bug
(let ((obscure-name 'pos))
  (nif-buggy
   x
   obscure-name
   'zero
   'neg))

;; Safe version of NIF
(defmacro nif (expr pos zero neg)
  (let ((g (gensym)))
    `(let ((,g ,expr))
       (cond ((plusp ,g) ,pos)
             ((zerop ,g) ,zero)
             (t ,neg)))))


;; WITH-GENSYMS
;; (with-gensyms (a b c) ...)



(set! map
      (lambda (xs p)
        (if (nil? xs)
            '()
            (cons (p (car xs)) (map (cdr xs) p)))))

(set! compose
      (lambda (f g)
        (lambda (x)
          (f (g x)))))

(set! foldr
      (lambda (p init xs)
        (if (nil? xs)
            init
            (p (car xs) (foldr p init (cdr xs))))))

(set! compose-many
      (lambda (fs)
        (foldr compose (lambda (x) x) fs)))

(set! cadr (compose-many (list car cdr)))
(set! cddr (compose-many (list cdr cdr)))
(set! caddr (compose-many (list car cdr cdr)))
(set! cadddr (compose-many (list car cdr cdr cdr)))
(set! caadr (compose-many (list car car cdr)))
(set! cdadr (compose-many (list cdr car cdr)))

(define-syntax define
  (lambda (stx)
    ((lambda (fst)
       (if (pair? fst)
           ((lambda (name formals exprs)
              `(set! ,name (lambda ,formals ,@exprs)))
            (car fst) (cdr fst) (cddr stx))
           `(set! ,fst ,(caddr stx))))
     (cadr stx))))

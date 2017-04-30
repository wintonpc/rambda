(set! map
      (lambda (p xs)
        (if (nil? xs)
            '()
            (cons (p (car xs)) (map p (cdr xs))))))

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

(define-syntax let
  (lambda (stx)
    ((lambda (vvs exprs)
       ((lambda (vars vals)
          `((lambda ,vars ,@exprs) ,@vals))
        (map car vvs) (map cadr vvs)))
     (cadr stx) (cddr stx))))

(define-syntax let*
  (lambda (stx)
    (let ([vvs (cadr stx)]
          [exprs (cddr stx)])
      (if (nil? vvs)
          `(let () ,@exprs)
          `(let (,(car vvs))
             (let* ,(cdr vvs) ,@exprs))))))

(define-syntax define
  (lambda (stx)
    (let ([fst (cadr stx)])
      (if (not (pair? fst))
          `(set! ,fst ,(caddr stx))
          (let ([name (car fst)]
                [formals (cdr fst)]
                [exprs (cddr stx)])
            `(set! ,name (lambda ,formals ,@exprs)))))))

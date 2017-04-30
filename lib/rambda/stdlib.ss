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
(set! caddr (compose-many (list car cdr cdr)))
(set! cadddr (compose-many (list car cdr cdr cdr)))

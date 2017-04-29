(set! map
      (lambda (xs p)
        (if (nil? xs)
            '()
            (cons (p (car xs)) (map (cdr xs) p)))))

#lang racket

; this is a stronger interpreter 
; according to Chapter 4.1 of SICP



;eval apply loop
(define (eval exp env)
  (cond 
        [(self-evaluating? exp) exp]
  		[(variable? exp) (lookup-var-value exp evn)]
  		[(quoted? exp) (text-of-quotation exp)]
  		[(assignment? exp) (eval-assignment exp env)]
  		[(definition? exp) (eval-definition exp env)]
  		[(if? exp) (eval-if exp evn)]
  		[(lambda? exp)
  			(make-proc (lambda-params exp)
  					   (lambda-body exp)
  					   env)]
  		[(begin? exp) 
  			(eval-sequence (begin-actions exp) env)]
  		[(cond? exp) (eval (cond-to-if exp) env)]
  		[(application? exp)
  			(apply (eval (operator exp) env)
  				   (list-of-values (operands exp) env))]
  		[else (error "Unknow expression type -- EVAL" exp)]))

  
(define (apply proc args)
  (cond 
        [(primitive-proc? proc)
  			(apply-primitive-proc proc args)]
  		[(compound-proc? proc)
  			(eval-sequence (proc-body proc)
  						   (extend-env  (proc-params proc)
  						   				args
  						   				(proc-env proc)))]
  		[else (error "Unknow procedual type -- APPLY" proc)]))


;;;
(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval (first-operand exps) env)
            (list-of-values (rest-operands exps) env))))


(define (eval-if exp env)
  (if (true? (eval (if-perdicate exp) env))
      (eval (if-consequence exp) env)
      (eval (if-alternate exp) env)))


(define (eval-sequence exps env)
  (cond 
        [(last-sequence? exps) (eval (first-exps) env)]
        [else (eval (first-exp exps) env)
              (eval-sequence (rest-exp exps) env)]))


(define (eval-assignment exp evn)
  (set-variable-avlue! (assignment-variable exp)
                       (eval (assignment-value exp) env)
                       env)
  'OK)


(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
                    (eval (definition-value exp) env)
                    env))


;;; 
(define (self-evaluating? exp)
    (cond [(number? exp) true]
          [(string? exp) true]
          [else false]))

;
(define (variable? exp) 
    (symbol? exp))

;
(define (quoted? exp)
    (tagged-list? exp 'quote))

(define (tagged-list? exp tag)
    (if (pair? exp)
        (eq? (car exp) tag)
        false)

(define (text-of-quotation exp)
    (cadr exp))


;
(define (assignment? exp)
    (tagged-list? exp 'set!))

(define (assignment-variable exp)
    (cadr exp))

(define (assignment-value exp)
    (caddr exp))


;
(define (definition? exp)
    (tagged-list? exp 'define))

(define (definition-variable exp)
    (if (symbol? (cadr exp))
        (cadr exp)
        (caadr exp)))

(define (definition-value exp)
    (if (symbol? (cadr exp))
        (caddr exp)
        (make-lambda (cdadr exp)    ;parameters
                     (cddr exp))))  ;body wraped with brackets


;
(define (lambda? exp)
    (tagged-list? exp 'lambda))

(define (lambda-params exp)
    (cadr exp))

(define (lambda-body exp)
    (cddr exp))

(define (make-lambda params body)
    (cons 'lambda (cons params body)))



;
(define (if? exp)
    (tagged-list? exp 'if))

(define (if-perdicate exp)
    (cadr exp))

(define (if-consequence exp)
    (caddr exp))

(define (if-alternate exp)
    (if (null? (cdddr exp))
        false
        (cadddr exp)))









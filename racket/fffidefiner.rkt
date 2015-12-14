#lang racket
(require ffi/unsafe
         ffi/unsafe/define)
(require (for-syntax racket/match))

(define shading-lib-path (build-path "C:\\Users\\DEMO\\Documents\\Visual Studio 2015\\Projects\\shading\\x64\\Debug\\shading"))
;(define shading-lib-path (build-path "shading"))
(displayln shading-lib-path)
(define shading-lib (ffi-lib shading-lib-path #:fail (λ () (displayln "FAIL!!!"))))
(define-ffi-definer define-f-function shading-lib)

;(provide defffi)



(define-syntax (defffi stx)
  (define (ffi-type<-str-type type)
    (case (string->symbol type)
      ((int) #'_int)
      ((float) #'_float)
      ((void) #'_void)
      #;((char) #'_char)
      (else (error "Unknown type" type))))
  (syntax-case stx ()
    [(def str)
     (match (regexp-match #rx" *(.+) +(.+) *\\( *(.*) *\\)" (syntax->datum #'str))
       ((list _ return-type-str func-str params-str)
        (if (eq? (string-length params-str) 0)
            (let ((func (datum->syntax stx (string->symbol func-str)))
                  (return-type (ffi-type<-str-type return-type-str))
                  (params-strs (regexp-split #rx" *, *" params-str)))
              (with-syntax ((func func)
                            (return-type return-type))
                (syntax/loc stx
                  (begin
                    (provide func)
                    (define-f-function func (_fun -> return-type))))))
            (let ((func (datum->syntax stx (string->symbol func-str)))
                  (return-type (ffi-type<-str-type return-type-str))
                  (params-strs (regexp-split #rx" *, *" params-str)))
              (let ((types
                     (for/list ((param-str (in-list params-strs)))
                       (match (regexp-split #rx" +" param-str)
                         [(list type name) (ffi-type<-str-type type)]))))
                (with-syntax ((func func)
                              ((type ...) types)
                              (return-type return-type))
                  (syntax/loc stx
                    (begin
                      (provide func)
                      (define-f-function func (_fun type ... -> return-type))))))))
        ))]))


(defffi "int start()")
(defffi "int clean()")
(defffi "int init(int n)")
(defffi "int end_cycle()")
(defffi "int send_data()")
(defffi "int pool()")
(defffi "int cycle()")

(defffi "void city(int n)")

(defffi "int prismpts(float pos_x, float pos_y, float pos_z, float pos_x_2, float pos_y_2, float pos_z_2, float l, float w, float h, float sides, float red, float g, float b)")
(defffi "int box(float pos_x, float pos_y, float pos_z, float w, float l, float h, float red, float g, float b, float angle, float vx, float vy, float vz)")
(defffi "int sphere(float pos_x, float pos_y, float pos_z, float r, float red, float g, float b)")
(defffi "int pyramid(float pos_x, float pos_y, float pos_z, float w, float l, float h, float sides, float red, float g, float b)")
(defffi "int pyramidpts(float pos_x, float pos_y, float pos_z, float pos_x_2, float pos_y_2, float pos_z_2, float w, float l, float h, float sides, float red, float g, float b)")
(defffi "int rotate(int n, float angle, float vx, float vy, float vz)")
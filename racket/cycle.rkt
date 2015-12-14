#lang racket
(require ffi/unsafe
         ffi/unsafe/define
         math/flonum
         "base.rkt"
         (prefix-in p3d: pict3d)
         racket/trace
         "sliders.rkt"
         )

;(init 1000)

;(city 200)
#;
(begin
  (cylinder -8.0 -8.0 0.0 1.0 0.4 0.0 0.0 0.0)
  (cylinder -4.0 -4.0 0.0 1.0 0.4 0.0 0.0 0.0)
  (cylinder 0.0 0.0 0.0 1.0 0.4 0.0 0.0 0.0)
  (cylinder 4.0 4.0 0.0 1.0 0.4 0.0 0.0 0.0)
  (cylinder 8.0 8.0 0.0 1.0 0.4 0.0 0.0 0.0))
;(box -0.4 0.4 0.2 0.2)
;(box 1.0 0.0 0.2 0.2)
;(box 0.2 0.4 0.2 0.2)
;(box -0.4 0.4 0.2 0.2)


;(start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define truss-node-radius (make-parameter 0.08))

(define (no-trelica p)
  (sphere p (truss-node-radius)))

(define truss-radius-bar (make-parameter 0.01))

(define (barra-trelica p0 p1)
  (when (not (=c? p0 p1))
    ; (empty-shape)
    (cylinder p0 (truss-radius-bar) p1)))

(define (nos-trelica ps)
  (map no-trelica ps))

(define (barras-trelica ps qs)
  (for/list ((p (in-list ps))
             (q (in-list qs)))
    (barra-trelica p q)))

(define (spacial-truss curvas)
  (let ((as (car curvas))
        (bs (cadr curvas))
        (cs (caddr curvas)))
    (nos-trelica as)
    (nos-trelica bs)
    (barras-trelica as cs)
    (barras-trelica bs as)
    (barras-trelica bs cs)
    (barras-trelica bs (cdr as))
    (barras-trelica bs (cdr cs))
    (barras-trelica (cdr as) as)
    (barras-trelica (cdr bs) bs)
    (if (null? (cdddr curvas))
        (begin
          (nos-trelica cs)
          (barras-trelica (cdr cs) cs))
        (begin
          (barras-trelica bs (cadddr curvas))
          (spacial-truss (cddr curvas))))))

(define (media-pontos p0 p1)
  (xyz (/ (+ (cx p0) (cx p1)) 2)
       (/ (+ (cy p0) (cy p1)) 2)
       (/ (+ (cz p0) (cz p1)) 2)))

(define (centro-quadrangulo p0 p1 p2 p3)
  (media-pontos
   (media-pontos p0 p2)
   (media-pontos p1 p3)))

(define (normal-poligono pts)
  (vector-normalizado
   (produtos-cruzados
    (append pts (list (car pts))))))

(define (produtos-cruzados pts)
  (if (null? (cdr pts))
      (xyz 0 0 0)
      (+c (produto-cruzado (car pts) (cadr pts))
          (produtos-cruzados (cdr pts)))))

(define (produto-cruzado p0 p1)
  (xyz (* (- (cy p0) (cy p1)) (+ (cz p0) (cz p1)))
       (* (- (cz p0) (cz p1)) (+ (cx p0) (cx p1)))
       (* (- (cx p0) (cx p1)) (+ (cy p0) (cy p1)))))

(define (vector-normalizado v)
  (let ((l (sqrt (+ (sqr (cx v))
                    (sqr (cy v))
                    (sqr (cz v))))))
    (xyz (/ (cx v) l)
         (/ (cy v) l)
         (/ (cz v) l))))

(define (normal-quadrangulo p0 p1 p2 p3)
  (normal-poligono (list p0 p1 p2 p3)))


(define (quadrangular-pyramid-vertex p0 p1 p2 p3)
  (let ((h (/ (+ (distance p0 p1)
                 (distance p1 p2)
                 (distance p2 p3)
                 (distance p3 p0))
              4.0
              (sqrt 2))))
    (+c (centro-quadrangulo p0 p1 p2 p3)
        (*c (normal-quadrangulo p0 p1 p2 p3)
            h))))

(define (insert-pyramid-vertex ptss)
  (if (null? (cdr ptss))
      ptss
      (cons
       (car ptss)
       (cons (insert-pyramid-vertex-2 (car ptss) (cadr ptss))
             (insert-pyramid-vertex (cdr ptss))))))

(define (insert-pyramid-vertex-2 pts0 pts1)
  (cons (quadrangular-pyramid-vertex (car pts0) (car pts1) (cadr pts1) (cadr pts0))
        (if (null? (cddr pts0))
            (list)
            (insert-pyramid-vertex-2 (cdr pts0) (cdr pts1)))))

(define (render-truss matrix)
  (let* ((p0 (caar matrix))
         (p1 (caadr matrix))
         (p2 (cadadr matrix))
         (p3 (cadar matrix))
         (d (min (distance p0 p1) (distance p0 p3))))
    (parameterize ((truss-node-radius (/ d 9.0))
                   (truss-radius-bar (/ d 19.0)))
      (spacial-truss
       (insert-pyramid-vertex
        matrix)))))

(define (sin-u*v n sizex sizey)
  (map-division
   (lambda (u v)
     (xyz (* u sizex)
          (* v sizey)
          (* 4 (sin (* u v)))))
   (* -1 pi) (* 1 pi) n
   (* -1 pi) (* 1 pi) n))



(displayln "START")

(define (truss n sizex sizey)
  (render-truss (sin-u*v  n sizex sizey)))
;(trace while cycle pool)
(setup truss (list 20 10 10))

(time
 (begin
   (send_data)
   (thread while)))


(sliders
 "Truss"
 (lambda (n sizex sizey) (update (list n sizex sizey)))
 '(("n" 5 50 20)
   ("sizex" 1 20 10)
   ("sizey" 1 20 10)))
;(pyramid (xyz 0.0 0.0 0.0) 10.0 10.0 (xyz 0.0 0.0 5.0) 1.0 0.0 1.0)




;(cylinder 0.0 0.0 0.0 10.0 5.4 0.0 0.0 0.0 29.0 0.0 1.0 0.0)
;(cylinder-p (xyz 0.0 0.0 0.0) 2.0 (xyz 10.0 5.4 0.0))

(displayln "END")




;loop 0 to N{
;modelo(n)
;delete shapes
;flush/refresh
;}
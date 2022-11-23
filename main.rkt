#lang racket

(require db
         peg
         "item-description-language.peg"
         "types.rkt")

(define *db* (make-parameter #f))

;; If only https://github.com/racket/db/issues/15 would have an aboutface for
;; db systems that support dumping a schema down the pipe no problem.  Sigh!
(define (sql->statements sql)
  (regexp-split #px"\\s*;\\s*" sql))

(define SCHEMA-PATH "schema.sql")
(define DESTROY-PATH "destroy.sql")

(define (setup-connection #:destroy? [destroy? #f])
  (*db*
   (virtual-connection
    (connection-pool
     (thunk (postgresql-connect
             #:user (or (getenv "POSTGRES_USER")
                        "postgres")
             #:port (match (getenv "POSTGRES_PORT")
                      [#f 5432]
                      [s (string->number s)])
             #:database (or (getenv "POSTGRES_DB") "postgres")
             #:server (or (getenv "POSTGRES_HOST") "subby.localhost")
             #:password (or (getenv "POSTGRES_PASSWORD") "example")
             #:ssl 'optional)))))
  (when destroy?
    (for ([stmt (sql->statements (file->string DESTROY-PATH))])
      (query-exec (*db*) stmt)))
  (for ([stmt  (sql->statements (file->string SCHEMA-PATH))])
    (query-exec (*db*) stmt)))

(define items (peg items (file->string "items.idl")))

(define/contract all-ingredients
  (set/c string?)
  (for/fold ([acc (set)])
            ([item items])
    (match-define (recipe name ingredients) item)
    (set-union
     (set-add acc name)
     (for/set ([ing ingredients])
       (ingredient-item ing)))))


(define *ids* (make-parameter (make-hash)))
(define (by-id name)
  (hash-ref (*ids*) name))

(define (q stmt . args) (apply query-rows (*db*) stmt args))
(define (q1 stmt . args) (apply query-value (*db*) stmt args))
(define (qx stmt . args) (apply query-exec (*db*) stmt args))

(define/contract (insert-ingredents [ings all-ingredients])
  (->* () ((set/c string?)) void?)
  (for ([ing ings])
    (hash-set! (*ids*) ing (q1 "INSERT INTO item (name) VALUES ($1) RETURNING id" ing))))

(define/contract (insert-recipes [recipes items])
  (->* () ((listof recipe?)) void?)
  (for* ([r recipes]
         [ing (recipe-ingredients r)])
    (qx "INSERT INTO ingredient (quantity, item, builds) VALUES ($1, $2, $3)"
        (ingredient-quantity ing)
        (by-id (ingredient-item ing))
        (by-id (recipe-item r)))))

(define (boot)
  (setup-connection #:destroy? #t)
  (insert-ingredents)
  (insert-recipes))

;; Define FIT token
(define-fungible-token fit-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-workout (err u101))
(define-constant err-already-completed (err u102))
(define-constant tokens-per-workout u10)

;; Data structures
(define-map workouts 
  uint 
  {
    name: (string-ascii 50),
    duration: uint,
    difficulty: uint,
    creator: principal
  }
)

(define-map workout-completions
  { workout-id: uint, user: principal }
  { completed: bool, timestamp: uint }
)

(define-data-var next-workout-id uint u1)

;; Public functions
(define-public (create-workout (name (string-ascii 50)) (duration uint) (difficulty uint))
  (let ((workout-id (var-get next-workout-id)))
    (map-set workouts 
      workout-id
      {
        name: name,
        duration: duration,
        difficulty: difficulty,
        creator: tx-sender
      }
    )
    (var-set next-workout-id (+ workout-id u1))
    (ok workout-id)
  )
)

(define-public (complete-workout (workout-id uint))
  (let (
    (workout (unwrap! (map-get? workouts workout-id) (err err-invalid-workout)))
    (completion-key { workout-id: workout-id, user: tx-sender })
  )
    (asserts! (is-none (map-get? workout-completions completion-key)) (err err-already-completed))
    
    ;; Record completion
    (map-set workout-completions 
      completion-key
      { completed: true, timestamp: block-height }
    )
    
    ;; Mint reward tokens
    (try! (ft-mint? fit-token tokens-per-workout tx-sender))
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-workout (workout-id uint))
  (ok (map-get? workouts workout-id))
)

(define-read-only (get-user-tokens)
  (ok (ft-get-balance fit-token tx-sender))
)

(define-read-only (get-completion-status (workout-id uint) (user principal))
  (ok (map-get? workout-completions { workout-id: workout-id, user: user }))
)

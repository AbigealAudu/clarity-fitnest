;; Define FIT token
(define-fungible-token fit-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-workout (err u101))
(define-constant err-already-completed (err u102))
(define-constant err-invalid-params (err u103))
(define-constant err-duplicate-name (err u104))
(define-constant err-contract-paused (err u105))
(define-constant tokens-per-workout u10)
(define-constant max-token-supply u1000000000)
(define-constant min-workout-duration u1)
(define-constant max-workout-duration u180)
(define-constant max-difficulty u5)

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

(define-map workout-names
  (string-ascii 50)
  bool
)

(define-map workout-completions
  { workout-id: uint, user: principal }
  { completed: bool, timestamp: uint }
)

(define-data-var next-workout-id uint u1)
(define-data-var total-supply uint u0)
(define-data-var contract-paused bool false)

;; Initialize contract
(begin
  (try! (ft-mint? fit-token u1000 contract-owner))
  (var-set total-supply u1000)
)

;; Admin functions
(define-public (set-paused (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused paused)
    (ok true)
  )
)

;; Public functions
(define-public (create-workout (name (string-ascii 50)) (duration uint) (difficulty uint))
  (let ((workout-id (var-get next-workout-id)))
    ;; Check contract not paused
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    ;; Validate parameters
    (asserts! (not (is-eq name "")) err-invalid-params)
    (asserts! (and (>= duration min-workout-duration) (<= duration max-workout-duration)) err-invalid-params)
    (asserts! (<= difficulty max-difficulty) err-invalid-params)
    (asserts! (is-none (map-get? workout-names name)) err-duplicate-name)
    
    (map-set workout-names name true)
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
    (print { event: "workout-created", workout-id: workout-id, creator: tx-sender })
    (ok workout-id)
  )
)

(define-public (complete-workout (workout-id uint))
  (let (
    (workout (unwrap! (map-get? workouts workout-id) err-invalid-workout))
    (completion-key { workout-id: workout-id, user: tx-sender })
    (current-supply (var-get total-supply))
  )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (is-none (map-get? workout-completions completion-key)) err-already-completed)
    (asserts! (<= (+ current-supply tokens-per-workout) max-token-supply) err-invalid-params)
    
    ;; Record completion
    (map-set workout-completions 
      completion-key
      { completed: true, timestamp: block-height }
    )
    
    ;; Mint reward tokens
    (try! (ft-mint? fit-token tokens-per-workout tx-sender))
    (var-set total-supply (+ current-supply tokens-per-workout))
    (print { event: "workout-completed", workout-id: workout-id, user: tx-sender })
    (ok true)
  )
)

[Previous read-only functions remain unchanged...]

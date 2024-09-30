;; decentralized-cloud-storage


;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-name (err u103))
(define-constant err-invalid-size (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-invalid-recipient (err u106))

;; data maps and vars
(define-data-var total-files uint u0)

(define-map files
  { file-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    size: uint,
    created-at: uint
  }
)

(define-map file-permissions
  { file-id: uint, user: principal }
  { permission: bool }
)

;; private functions
(define-private (file-exists (file-id uint))
  (is-some (map-get? files { file-id: file-id }))
)

(define-private (get-owner-file (file-id int) (owner principal))
  (match (map-get? files { file-id: (to-uint file-id) })
    file-info (is-eq (get owner file-info) owner)
    false
  )
)

(define-private (get-file-size-by-owner (file-id int))
  (default-to u0 
    (get size 
      (map-get? files { file-id: (to-uint file-id) })
    )
  )
)

;; public functions
(define-public (upload-file (name (string-ascii 64)) (size uint))
  (let
    (
      (file-id (+ (var-get total-files) u1))
    )
    (asserts! (> (len name) u0) err-invalid-name)
    (asserts! (< (len name) u65) err-invalid-name)
    (asserts! (> size u0) err-invalid-size)
    (asserts! (< size u1000000000) err-invalid-size) ;; Assuming 1GB max file size
    ;; Insert the new file
    (map-insert files
      { file-id: file-id }
      {
        owner: tx-sender,
        name: name,
        size: size,
        created-at: block-height
      }
    )
    ;; Set default permission for the owner
    (map-insert file-permissions
      { file-id: file-id, user: tx-sender }
      { permission: true }
    )
    (var-set total-files file-id)
    (ok file-id)
  )
)

(define-public (update-file (file-id uint) (new-name (string-ascii 64)) (new-size uint))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (asserts! (> (len new-name) u0) err-invalid-name)
    (asserts! (< (len new-name) u65) err-invalid-name)
    (asserts! (> new-size u0) err-invalid-size)
    (asserts! (< new-size u1000000000) err-invalid-size)
    (map-set files
      { file-id: file-id }
      (merge file { name: new-name, size: new-size })
    )
    (ok true)
  )
)

(define-public (delete-file (file-id uint))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (map-delete files { file-id: file-id })
    (ok true)
  )
)

(define-public (transfer-file-ownership (file-id uint) (new-owner principal))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (map-set files
      { file-id: file-id }
      (merge file { owner: new-owner })
    )
    (ok true)
  )
)

;; read-only functions
(define-read-only (get-total-files)
  (ok (var-get total-files))
)

(define-read-only (get-file-info (file-id uint))
  (match (map-get? files { file-id: file-id })
    file-info (ok file-info)
    err-not-found
  )
)

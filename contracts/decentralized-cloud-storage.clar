;; decentralized-cloud-storage
;; <add a description here>

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

(define-private (get-owner-file (file-id int) (owner principal))
  (match (map-get? files { file-id: (to-uint file-id) })
    file-info (is-eq (get owner file-info) owner)
    false
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

;; read-only functions
(define-read-only (get-total-files)
  (ok (var-get total-files))
)

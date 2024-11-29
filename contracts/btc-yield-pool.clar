;; title: Staked BTC Smart Contract
;; summary: A smart contract for staking BTC and earning yield.
;; description: This smart contract allows users to stake BTC and earn yield over time. It includes functionalities for initializing the pool, staking, unstaking, distributing yield, and claiming rewards. The contract also supports SIP-010 token standard functions, internal helper functions, and transfer and allowance functions. The contract owner can set the token URI and manage the pool's yield rate. The contract ensures security and proper validation through various error constants and assertions.

(define-constant contract-owner tx-sender)

;; Error constants
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-ALREADY-INITIALIZED (err u101))
(define-constant ERR-NOT-INITIALIZED (err u102))
(define-constant ERR-POOL-ACTIVE (err u103))
(define-constant ERR-POOL-INACTIVE (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-INSUFFICIENT-BALANCE (err u106))
(define-constant ERR-NO-YIELD-AVAILABLE (err u107))
(define-constant ERR-MINIMUM-STAKE (err u108))
(define-constant ERR-UNAUTHORIZED (err u109))
(define-constant ERR-INVALID-URI (err u110))

;; Constants
(define-constant MINIMUM-STAKE-AMOUNT u1000000) ;; 0.01 BTC in sats
(define-constant BLOCKS-PER-DAY u144)
(define-constant MAX-YIELD-RATE u5000) ;; 50% maximum APY
(define-constant MAX-TOKEN-URI-LENGTH u200) ;; Maximum length for token URI

;; Data variables
(define-data-var total-staked uint u0)
(define-data-var total-yield uint u0)
(define-data-var pool-active bool false)
(define-data-var insurance-active bool false)
(define-data-var yield-rate uint u500) ;; 5% base APY
(define-data-var last-distribution-block uint u0)
(define-data-var insurance-fund-balance uint u0)
(define-data-var token-name (string-ascii 32) "Staked BTC")
(define-data-var token-symbol (string-ascii 10) "stBTC")
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Data maps
(define-map staker-balances principal uint)

(define-map staker-rewards principal uint)

(define-map yield-distribution-history 
    uint 
    {
        block: uint,
        amount: uint,
        apy: uint
    }
)

(define-map risk-scores principal uint)

(define-map insurance-coverage principal uint)

(define-map allowances 
    { 
        owner: principal, 
        spender: principal 
    } 
    uint
)

;; SIP-010 Token Standard Functions
(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok u8))

(define-read-only (get-balance (account principal))
    (ok (default-to u0 (map-get? staker-balances account))))

(define-read-only (get-total-supply)
    (ok (var-get total-staked)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

;; Internal Helper Functions
(define-private (calculate-yield (amount uint) (blocks uint))
    (let 
        (
            (rate (var-get yield-rate))
            (time-factor (/ blocks BLOCKS-PER-DAY))
            (base-yield (* amount rate))
        )
        (/ (* base-yield time-factor) u10000)
    )
)

(define-private (update-risk-score (staker principal) (amount uint))
    (let 
        (
            (current-score (default-to u0 (map-get? risk-scores staker)))
            (stake-factor (/ amount u100000000))
            (new-score (+ current-score stake-factor))
        )
        (map-set risk-scores staker new-score)
        new-score
    )
)

(define-private (check-yield-availability)
    (let 
        (
            (current-block block-height)
            (last-distribution (var-get last-distribution-block))
        )
        (if (>= current-block (+ last-distribution BLOCKS-PER-DAY))
            (ok true)
            (err ERR-NO-YIELD-AVAILABLE)
        )
    )
)

(define-private (transfer-internal (amount uint) (sender principal) (recipient principal))
    (begin
        ;; Validate transfer amount
        (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
        (asserts! (not (is-eq sender recipient)) (err ERR-INVALID-AMOUNT))
        
        (let 
            (
                (sender-balance (default-to u0 (map-get? staker-balances sender)))
            )
            (asserts! (>= sender-balance amount) (err ERR-INSUFFICIENT-BALANCE))
            
            (map-set staker-balances sender (- sender-balance amount))
            (map-set staker-balances recipient 
                (+ (default-to u0 (map-get? staker-balances recipient)) amount)
            )
            (ok true)
        )
    )
)
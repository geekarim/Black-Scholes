section .data
    ; Input
    S dd 100.0            ; Stock price
    K dd 100.0            ; Strike
    T dd 1.0              ; Time to expiration (in years)
    r dd 0.02             ; Interest rate (decimal representation)
    sigma dd 0.2          ; Volatility (decimal representation)

    ; Output
    Call_price dd 0.0     ; Reserve space for the Call price
    Put_price dd 0.0      ; Reserve space for the Put price

    ; Utility variables
    d1 dd 0.0             ; Reserve space for d1
    d2 dd 0.0             ; Reserve space for d2

    ; Constants
    CDF_const dd 0.044715  ; Store the constant 0.044715 in memory

    ; Output format
    fmt_Call db "Call option price: %f", 10, 0    ; Format string for printf (Call price)
    fmt_Put db "Put option price: %f", 0          ; Format string for printf (Put price)

section .bss
    ptrVar resd 1         ; Reserve space for a pointer to a float

section .text
    global _WinMain@16

    extern _printf
    extern _ExitProcess@4


_WinMain@16:
    ; Compute Call and Put option prices


    ; if T=0
    mov eax, [T]            ; Load value of T into eax
    mov ebx, 0              ; Load value of zero into ebx

    ; Compare T and zero
    cmp eax, ebx            ; Compare T with zero (eax - ebx)
    jg  T_greater_zero      ; If T > zero, jump to 'T_greater_zero'

    ; else block (T <= zero)

    ; if S>K
    mov eax, [S]            ; Load value of S into eax
    mov ebx, [K]            ; Load value of K into eax
    ; Compare S and K
    cmp eax, ebx            ; Compare S with K (eax - ebx)
    jg  S_greater_K         ; If S > K, jump to 'S_greater_K'

    ; else Call_price stays the same 0.0

    fld dword [K]             ; Load K
    fld dword [S]             ; Load S
    fsub                      ; K - S
    fstp dword [Put_price]    ; Store Put_price

    jmp end_if_T_equal_zero   ; Jump to end


S_greater_K:
    fld dword [S]               ; Load S
    fld dword [K]               ; Load K
    fsub                        ; S - K
    fstp dword [Call_price]     ; Store Call_price
    jmp end_if_T_equal_zero     ; Jump to end to avoid 'T_greater_zero'


T_greater_zero:
    ; Compute d1 = (log(S / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))
    ; d2 = d1 - sigma * sqrt(T)

    ; Compute log(S/K)
    fld dword [S]         ; Load S
    fld dword [K]         ; Load K
    fdiv                  ; S / K
    fldln2                ; Load log base e of 2 (ln(2))
    fxch                  ; Swap ST(0) and ST(1)
    fyl2x                 ; Compute log(S / K)

    ; Compute log(S/K) + (r + 0.5 * sigma^2)*T
    fld dword [sigma]     ; Load sigma
    fld dword [sigma]     ; Load sigma
    fmul                  ; sigma^2
    fld1                  ; Load 1.0 onto ST(0)
    fld1                  ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                  ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fdiv                  ; sigma^2/ 2
    fld dword [r]         ; Load r
    fadd                  ; r + 0.5 * sigma^2
    fld dword [T]         ; Load T
    fmul                  ; (r + 0.5 * sigma^2) * T
    fadd                  ; log(S/K) + (r + 0.5 * sigma^2) * T

    ; Compute d1 = (log(S / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))
    fld dword [T]         ; Load T
    fsqrt                 ; sqrt(T)
    fld dword [sigma]     ; Load sigma
    fmul                  ; sigma * sqrt(T)
    fdiv                  ; (log(S / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))

    fst dword [d1]        ; Store d1

    ; Compute d2 = d1 - sigma * sqrt(T)
    fld dword [T]         ; Load T
    fsqrt                 ; sqrt(T)
    fld dword [sigma]     ; Load sigma
    fmul                  ; sigma * sqrt(T)
    fchs                  ; Change sign
    fadd                  ; d2 = d1 - sigma * sqrt(T)

    fstp dword [d2]       ; Store d2


    ; Compute Call price


    lea eax, [d1]         ; Load the address of d1 into eax
    mov [ptrVar], eax     ; Store the address in ptrVar

    call norm_cdf         ; Call norm_cdf(d1) function

    ; Compute S * norm.cdf(d1)
    fld dword [S]         ; Load S
    fmul


    lea eax, [d2]         ; Load the address of d2 into eax
    mov [ptrVar], eax     ; Store the address in ptrVar

    call norm_cdf         ; Call norm_cdf(d2) function


    ; Compute K * norm.cdf(d2)
    fld dword [K]         ; Load K
    fmul


    ; Compute exp(-r*T)

    ; exp(x) = 2^(x/ln(2))
    ; Compute 2^(x/ln(2)) for x = -r*T
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    ; Dublicate -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    fmul                   ; exp(-r*T) * K * norm.cdf(d2)
    fsub                   ; S * norm.cdf(d1) - exp(-r*T) * K * norm.cdf(d2)


    fstp dword [Call_price]    ; Store Call price


    ; Compute Put price


    lea eax, [d2]          ; Load the address of d2 into eax
    mov [ptrVar], eax      ; Store the address of d2 in ptrVar

    fld dword [eax]        ; Load the float value at eax into the FPU
    fchs                   ; Change the sign of the value in the FPU
    fstp dword [eax]       ; Store the modified value back into eax

    call norm_cdf          ; Call norm_cdf(-d2) function


    ; Compute K * norm.cdf(-d2)
    fld dword [K]          ; Load K
    fmul


    ; Compute exp(-r*T)

    ; exp(x) = 2^(x/ln(2))
    ; Compute 2^(x/ln(2)) for x = -r*T
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    ; Dublicate -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate -r*T / ln(2)
    fld dword [T]          ; Load T
    fld dword [r]          ; Load r
    fchs                   ; Change sign: -r
    fmul
    fldln2                 ; Load ln(2)
    fdiv                   ; -r*T / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    fmul                   ; exp(-r*T) * K * norm.cdf(-d2)


    lea eax, [d1]          ; Load the address of d1 into eax
    mov [ptrVar], eax      ; Store the address of d1 in ptrVar

    fld dword [eax]        ; Load the float value at eax into the FPU
    fchs                   ; Change the sign of the value in the FPU
    fstp dword [eax]       ; Store the modified value back into eax

    call norm_cdf          ; Call norm_cdf(-d1) function


    ; Compute S * norm.cdf(-d1)
    fld dword [S]          ; Load S
    fmul


    fsub                   ; exp(-r*T) * K * norm.cdf(-d2) - S * norm.cdf(-d1)


    fstp dword [Put_price]    ; Store Put price


end_if_T_equal_zero:

    ; Print the Call price
    fld dword [Call_price]    ; Load Call_price into FPU stack
    sub esp, 8                ; Allocate space on the stack
    fstp qword [esp]          ; Store Call_price on the stack
    push fmt_Call             ; Push format string for Call_price
    call _printf              ; Call printf
    add esp, 12               ; Clean up the stack (remove Call_price and format string)

    ; Print the Put price
    fld dword [Put_price]     ; Load Put_price as floating-point
    sub esp, 8                ; Allocate space on the stack
    fstp qword [esp]          ; Store Put_price on the stack
    push fmt_Put              ; Push format string for Put_price
    call _printf              ; Call printf
    add esp, 12               ; Clean up the stack (remove Put_price and format string)


    ; Exit the program
    push 0                    ; Exit code
    call _ExitProcess@4       ; Call ExitProcess function


norm_cdf:
    ; Compute the CDF (Cumulative Distribution Function) of the standard normal distribution of d
    ; GELU approximation
    ; Normal CDF = 0.5 * [ 1 + tanh( sqrt(2/pi) * ( x + 0.044715 * x^3 ) ) ] for x = d
    ; tanh(x) = ( exp(x) - exp(-x) ) / ( exp(x) + exp(-x) )
    
    ; exp(x) = 2^(x/ln(2))
    ; Compute 2^(x/ln(2)) for x = sqrt(2/pi) * ( d + 0.044715 * d^3 )
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    ; Dublicate sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    ; exp(-x) = 2^(-x/ln(2))
    ; Compute 2^(-x/ln(2)) for -x = -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    ; Dublicate -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    fsub                   ; exp(x) - exp(-x)


    ; exp(x) = 2^(x/ln(2))
    ; Compute 2^(x/ln(2)) for x = sqrt(2/pi) * ( d + 0.044715 * d^3 )
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    ; Dublicate sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    ; exp(-x) = 2^(-x/ln(2))
    ; Compute 2^(-x/ln(2)) for -x = -sqrt(2/pi) * ( d + 0.044715 * d^3 )
    ; Note 2^(mantissa + integer part) = 2^(mantissa) * 2^(integer part)

    ; Compute 2^(mantissa)

    ; Compute -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    ; Dublicate -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)
    fsub                   ; Subtract integer part from original

    ; Compute 2^(mantissa)
    f2xm1                  ; ST(0) = 2^(mantissa) - 1
    fld1                   ; Load 1.0
    fadd                   ; ST(0) = 2^(mantissa)

    ; Compute 2^(integer part)

    ; Dublicate -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fmul                   ; d^2
    fmul                   ; d^3
    fld dword [CDF_const]  ; Load CDF_const
    fmul                   ; 0.044715 * d^3
    mov eax, [ptrVar]      ; Load the address from ptrVar
    fld dword [eax]        ; Load the float value into the FPU stack
    fadd                   ; d + 0.044715 * d^3
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fldpi                  ; Load pi
    fdiv                   ; 2 / pi
    fsqrt                  ; sqrt(2 / pi)
    fmul                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 )
    fldln2                 ; Load ln(2)
    fdiv                   ; sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)
    fchs                   ; -sqrt(2/pi) * ( d + 0.044715 * d^3 ) / ln(2)

    frndint                ; Round ST(0) to the nearest integer (integer part)

    ; Compute 2^(mantissa + integer part)
    fld1                   ; Load 1
    fscale                 ; ST(1) = 2^(integer part) , ( ST(0) = integer part )
    fstp                   ; Clean up the stack, leaving the result in ST(0)
    fmul                   ; 2^(mantissa) * 2^(integer part)


    fadd                   ; exp(x) + exp(-x)

    ; Compute tanh(x) = ( exp(x) - exp(-x) ) / ( exp(x) + exp(-x) )
    fdiv

    ; Compute norm.cdf(d1)
    fld1                   ; Load 1
    fadd
    fld1                   ; Load 1.0 onto ST(0)
    fld1                   ; Load another 1.0 onto ST(0) (ST(0) = 1.0)
    fadd                   ; ST(0) = 1.0 + 1.0 = 2.0 (now ST(0) = 2.0)
    fdiv

    ret                    ; Return

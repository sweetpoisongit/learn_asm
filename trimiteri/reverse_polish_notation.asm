section .note.GNU-stack

extern scanf
extern printf
extern atol

section .data

inputt db "%s", 0        ;; format input
outputt db "%ld", 10, 0        ;; format output

section .bss

token resb 50        ;; rezerv token size 50
stack resq 100        ;; rezerv stack size 100

section .text

global reverse_polish_notation

reverse_polish_notation:
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push r12		;; r12 = top = 0
    push r13		;; stack alignment
    xor r12, r12

read_loop:

    ;; scanf("%s", token)
    mov rdi, inputt
    mov rsi, token
    xor rax, rax
    call scanf

    cmp eax, -1        ;; EOF
    je print_result

    ;; verificam +
    cmp byte [token], '+'
    jne check_mul
    cmp byte [token + 1], 0        ;; \0 in string
    je do_plus

check_mul:
    ;; verificam *
    cmp byte [token], '*'
    jne check_sub
    cmp byte [token + 1], 0        ;; \0 in string
    je do_mul

check_sub:
    ;; verificam -
    cmp byte [token], '-'
    jne check_div
    cmp byte [token + 1], 0        ;; \0 in string
    je do_sub

check_div:
    ;; verificam /
    cmp byte [token], '/'
    jne push_number
    cmp byte [token + 1], 0        ;; \0 in string
    je do_div

push_number:
    ;; convertim tokenul in long
    mov rdi, token
    call atol

    ;; push numar in stack
    mov [stack + r12 * 8], rax        ;; 8 bytes pentru long
    inc r12

    jmp read_loop

do_plus:
    ;; pop b
    dec r12
    mov r10, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; pop a
    dec r12
    mov rax, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; a + b
    add rax, r10

    ;; push rezultat
    mov [stack + r12 * 8], rax        ;; 8 bytes pentru long
    inc r12

    jmp read_loop

do_mul:
    ;; pop b
    dec r12
    mov r10, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; pop a
    dec r12
    mov rax, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; a * b
    imul rax, r10

    ;; push rezultat
    mov [stack + r12 * 8], rax        ;; 8 bytes pentru long
    inc r12

    jmp read_loop

do_sub:
    ;; b = pop()
    dec r12
    mov r10, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; a = pop()
    dec r12
    mov rax, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; a - b
    sub rax, r10

    ;; push rezultat
    mov [stack + r12 * 8], rax        ;; 8 bytes pentru long
    inc r12

    jmp read_loop

do_div:
    ;; pop b
    dec r12
    mov r10, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; pop a
    dec r12
    mov rax, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; a / b
    cqo
    idiv r10

    ;; push rezultat
    mov [stack + r12 * 8], rax        ;; 8 bytes pentru long
    inc r12

    jmp read_loop

print_result:
    ;; luam rezultatul final
    dec r12
    mov rsi, [stack + r12 * 8]        ;; 8 bytes pentru long

    ;; printf("%ld\n", rezultat)
    mov rdi, outputt
    xor rax, rax
    call printf

    xor rax, rax
    pop r13			;; pop
    pop r12			;; stack alignment
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret
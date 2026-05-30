section .note.GNU-stack

extern putc
extern stdout

section .text

global my_printf

my_printf:
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 96     ;; rezervam 96 bytes
    mov rbx, rdi        ;; rbx = format
    xor r12, r12        ;; r12 = index

    mov r14, rsp        ;; salvam primele argumente
    mov [r14 + 0], rsi      ;; arg 1
    mov [r14 + 8], rdx      ;; arg 2
    mov [r14 + 16], rcx     ;; arg 3
    mov [r14 + 24], r8      ;; arg 4
    mov [r14 + 32], r9      ;; arg 5

loop_print:
    cmp byte [rbx], 0        ;; am parcurs formatul
    je end_printf

    cmp byte [rbx], '%'
    je check_format

    movzx rdi, byte [rbx]       ;; ia doar un byte
    mov rsi, [stdout]
    call putc

    inc rbx
    jmp loop_print

check_format:
    inc rbx

    ;; verificam %lu
    cmp byte [rbx], 'l'     ;; l
    jne check_char
    cmp byte [rbx + 1], 'u'     ;; u
    je print_lu

check_char:
    ;; verificam %c
    cmp byte [rbx], 'c'
    je print_c

check_string:
    ;; verificam %s
    cmp byte [rbx], 's'
    je print_s

print_lu:
    call get_arg

    add rbx, 2      ;; sarim peste l si u

    lea r15, [rsp + 40]        ;; buffer cifre
    xor r13, r13               ;; nr cifre

lu_loop:
    xor rdx, rdx

    ;; baza 10 pentru afisare
    mov r10, 10
    div r10

    add dl, '0'
    mov [r15 + r13], dl
    inc r13

    ;; continuam pana rax devine 0
    cmp rax, 0
    jne lu_loop

print_digits:
    ;; daca nu mai avem cifre, continuam formatul
    cmp r13, 0
    je loop_print

    dec r13
    movzx rdi, byte [r15 + r13]
    mov rsi, [stdout]
    call putc

    jmp print_digits

print_c:
    call get_arg

    mov rdi, rax
    mov rsi, [stdout]
    call putc

    inc rbx
    jmp loop_print

print_s:
    call get_arg
    mov r13, rax        ;; r13 = string

string_loop:
    ;; verificam ending string
    cmp byte [r13], 0
    je string_done

    movzx rdi, byte [r13]
    mov rsi, [stdout]
    call putc

    inc r13
    jmp string_loop

string_done:
    inc rbx
    jmp loop_print

get_arg:
    ;; primele 5 argumente
    cmp r12, 5
    jl arg_from_regs

    mov r13, r12
    sub r13, 5		;; scadem cele 5 argumente

    ;; primul argument e la rbp + 16 si fiecare are 8 bytes
    mov rax, [rbp + 16 + r13 * 8]
    inc r12
    ret

arg_from_regs:
    mov rax, [r14 + r12 * 8]		;; luam argumentul salvat
    inc r12
    ret

end_printf:
    xor rax, rax

    ;; refacem spatiul
    add rsp, 96
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret
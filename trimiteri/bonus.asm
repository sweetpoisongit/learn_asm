section .note.GNU-stack

extern printf

section .data

format_int db "%d", 10, 0		;; \n si eos
heavy_yes db "The number is heavy", 10, 0		;; \n si eos
heavy_no db "The number is not heavy", 10, 0		;; \n si eos


section .text

global ave
global switch_cases
global heavy
global flat_matrix

ave:	;;;;;;;;;;;;;;;;;;;; ave ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    xor rcx, rcx        ;; i = 0
    mov r9d, edx        ;; r9 = n

ave_loop:
    movsx eax, byte [rdi + rcx]

    cmp al, 0           ;; final string
    je ave_done

    sub eax, 'A'
    add eax, r9d

    mov r8d, 31         ;; modulo 31
    cdq
    idiv r8d

    add edx, 'A'
    mov [rsi + rcx], dl

    inc rcx
    jmp ave_loop

ave_done:
    mov byte [rsi + rcx], 0     ;; eos

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret

switch_cases:   ;;;;;;;;;;;;;;;;;;;; switch ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    xor rcx, rcx        ;; i = 0

switch_loop:
    mov al, [rdi + rcx]

    ;; 0 = final string
    cmp al, 0
    je switch_done

    ;; verificam litera mica
    cmp al, 'a'
    jl check_big
    cmp al, 'z'
    jg check_big

    ;; diferenta intre litera mica si mare este 32
    sub al, 32
    jmp save_char

check_big:
    ;; verificam litera mare
    cmp al, 'A'
    jl save_char
    cmp al, 'Z'
    jg save_char

    ;; diferenta intre litera mare si mica este 32
    add al, 32

save_char:
    mov [rsi + rcx], al
    inc rcx
    jmp switch_loop

switch_done:
    mov byte [rsi + rcx], 0		;; terminator string

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret

heavy:	;;;;;;;;;;;;;;;;;;;; heavy ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    mov eax, edi        ;; eax = number

    ;; check MSB
    test eax, 80000000h
    jz not_heavy

    mov ecx, eax

    ;; mutam byte 3 pe pozitia cea mai mica
    shr ecx, 16
    and ecx, 0FFh       ;; luam doar byte 3

    ;; daca byte 3 e 0 concatenarea nu trece de 255
    cmp ecx, 0
    je not_heavy

is_heavy:
    mov rdi, heavy_yes
    xor rax, rax
    call printf
    jmp heavy_done

not_heavy:
    mov rdi, heavy_no
    xor rax, rax
    call printf

heavy_done:
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret

flat_matrix:	;;;;;;;;;;;;;;;;;;;; matrix ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi        ;; rbx = mat
    mov r12d, esi       ;; r12 = n
    xor r13, r13        ;; col = 0

col_loop:
    cmp r13, r12
    jge flat_done

    mov eax, [rbx + r13 * 4]		;; 4 byte int
    mov r14d, eax       ;; max = mat[col]

    mov rcx, 1          ;; row = 1

row_loop:
    cmp rcx, r12
    jge print_max

    mov rax, rcx
    imul rax, r12
    add rax, r13        ;; i = row * n + col

    mov edx, [rbx + rax * 4]		;; 4 byte int

    cmp edx, r14d
    jle next_row

    mov r14d, edx

next_row:
    inc rcx
    jmp row_loop

print_max:
    mov rdi, format_int
    mov esi, r14d
    xor rax, rax
    call printf

    inc r13
    jmp col_loop

flat_done:
    pop r14
    pop r13
    pop r12
    pop rbx

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret
section .note.GNU-stack

section .bss

viz resd 100		;; vector pentru vizitate

section .text

global check_langford
global generate_langford_sequences

check_langford:     ;;;;;;;;;;;;;;;;;;;;; check ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov rbx, rdi        ;; rbx = sequence
    mov r12d, esi       ;; r12 = len

    xor r13, r13        ;; r13 = i = 0

loop_i:
    cmp r13, r12        ;; am ajuns la final
    jge check_viz

    movsxd r14, dword [rbx + r13 * 4]       ;; r14 = sequence[i]

    cmp dword [viz + r14 * 4], 1       ;; verificam daca x e vizitat
    je next_i

    mov r15, r13
    add r15, r14
    inc r15             ;; j = i + x + 1

    cmp r15, r12        ;; verificam daca j < len
    jge return_zero

    mov eax, [rbx + r15 * 4]        ;; eax = sequence[j]
    cmp eax, r14d       ;; verificam daca sequence[j] == x
    jne return_zero

    mov dword [viz + r14 * 4], 1       ;; marcam x vizitat

next_i:
    inc r13
    jmp loop_i

check_viz:
    mov r13, 1      ;; r13 = i = 1
    shr r12, 1      ;; len /= 2
    inc r12     ;; len++
loop_viz:
    cmp r13, r12		;; am ajuns la final
    je return_one       ;; secventa e buna

    mov eax, [viz + r13 * 4]        ;; viz[i]
    cmp eax, 0      ;; un numar nu apare
    je return_zero      ;; secventa nu e buna

    jmp next_i_viz

next_i_viz:
    inc r13     ;; i++
    jmp loop_viz        ;; next iter

return_one:
    mov eax, 1      ;; return 1
    jmp end_check

return_zero:
    xor eax, eax

end_check:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret

generate_langford_sequences:    ;;;;;;;;;;;;;;;;;;;;; generate ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    mov dword [rsi], 0      ;; seq = 0
    xor rax, rax            ;; return NULL

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    leave
    ret
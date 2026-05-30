section .note.GNU-stack

extern malloc
extern realloc
extern free
extern printf

section .data

;; format eroare set & get
error_sget_element db "Error: len <= %d", 10, 0
;; format afisare pop
error_pop_element db "The vector is empty", 10, 0
;; format afisare inceput print
out_start db "v -> {(", 0
;; format afisare element print
out_elem db "[%d]", 0
;; format afisare casuta goala print
out_empty db "[]", 0
;; format afisare sfarsit print
out_end db "), %d, %d}", 10, 0

section .text

global new_vector
global set_element
global get_element
global push_element
global pop_element
global print_vector
global free_vector

;	struct vector {
;		int *arr;
;		int len;
;		int cap;
;	}

new_vector:		;;;;;;;;;;;;;;;;;;;; new_vector ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    mov rsi, rdi		;; rsi = cap

    ;; malloc v
    mov rdi, 16
    push rcx
    call malloc
    pop rcx
    mov rbx, rax		;; rbx = v

    mov dword [rbx + 8], 0		;; v->len = 0

    mov dword [rbx + 12], esi	;; v->cap = cap

    ;; malloc arr
    push rcx
    mov rdi, rsi
    imul rdi, 4     ;; int 4 byte size
    call malloc
    pop rcx
    mov [rbx + 0], rax		;; v->arr = arr

    mov rax, rbx		;; return v

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

set_element:		;;;;;;;;;;;;;;;;;;;; set_element ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    ;; rdi = v
    ;; rsi = elem
    ;; rdx = pos

    mov eax, dword [rdi + 8]		;; eax = v->len
    cmp edx, eax
    jge error

    ;; v->arr[pos] = elem
    mov rbx, [rdi + 0]		;; rbx = vec->arr
    mov rcx, rdx
    imul rcx, 4     ;; int 4 byte offset
    mov dword [rbx + rcx], esi		;; arr[pos] = elem

    mov eax, edx		;; return pos
    jmp end_set_elem

error:
    ;; printf("Error: len <= %d\n", pos);

    push rcx
    mov rsi, rdx		;; pos
    mov rdi, error_sget_element
    xor rax, rax
    call printf
    pop rcx

    mov eax, -1		;; return -1

end_set_elem:

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

get_element:        ;;;;;;;;;;;;;;;;;;;; get_element ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    ;; rdi = v
    ;; rsi = pos

    mov eax, dword [rdi + 8]		;; eax = v->len
    cmp esi, eax
    jge error_get_element

    ;; return v->arr[pos]
    mov rbx, [rdi + 0]		;; rbx = vec->arr
    mov rcx, rsi
    imul rcx, 4     ;; int 4 byte offset
    mov eax, dword [rbx + rcx]		;; eax = arr[pos]

    jmp end_get_element

error_get_element:
    ;; printf("Error: len <= %d\n", pos);

    ;; mov rsi, rsi            ;; pos
    push rcx
    mov rdi, error_sget_element
    xor rax, rax
    call printf
    pop rcx

    mov eax, -1		;; return -1

end_get_element:

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

push_element:        ;;;;;;;;;;;;;;;;;;;; push_element ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    ;; rdi = v
    ;; rsi = elem
    push rsi

    mov eax, dword [rdi + 8]        ;; eax = len
    mov ebx, dword [rdi + 12]       ;; ebx = cap

    cmp eax, ebx
    jne no_resize

    mov rbx, rdi        ;; rbx = v

    ;; pe aici facem resize

    imul eax, 2     ;; cap *= 2
    mov dword [rbx + 12], eax       ;; cap *= 2

    ;; realloc(arr, cap * 4)
    mov rdi, [rbx + 0]
    mov esi, dword [rbx + 12]       ;; new cap
    imul rsi, 4     ;; int 4 byte size
    call realloc

    mov [rbx + 0], rax      ;; v->arr = new_arr
    mov rdi, rbx            ;; refacem v

no_resize:

    pop rsi

    mov rbx, [rdi + 0]      ;; rbx = arr

    ;; rcx = len
    mov ecx, dword [rdi + 8]
    imul rcx, 4     ;; int 4 byte offset

    mov dword [rbx + rcx], esi      ;; arr[len] = elem

    mov eax, dword [rdi + 8]    ;; eax = aux len
    inc eax
    mov dword [rdi + 8], eax        ;; len++

    dec eax     ;; return index

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

pop_element:        ;;;;;;;;;;;;;;;;;;;; pop_element ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    ;; rdi = v
    mov rbx, rdi        ;; rbx = v

    mov eax, dword [rbx + 8]        ;; eax = len
    cmp eax, 0      ;; vectorul e gol 
    je error_pop

    ;; val = arr[len - 1]
    mov rdi, [rbx + 0]      ;; rdi = arr
    mov ecx, eax
    dec ecx
    imul rcx, 4     ;; int 4 byte offset
    mov eax, dword [rdi + rcx]      ;; eax = val

    mov edx, dword [rbx + 8]        ;; edx = aux len
    dec edx
    mov dword [rbx + 8], edx        ;; len--

    ;; daca len <= cap / 2 realloc
    mov ecx, dword [rbx + 12]       ;; ecx = cap

    cmp ecx, 1      ;;  daca cap == 1
    jle end_pop

    shr ecx, 1      ;; cap / 2

    cmp edx, ecx
    jg end_pop

    ;; salvam valoarea returnata
    push rax

    ;; cap = cap / 2
    mov ecx, dword [rbx + 12]
    shr ecx, 1      ;; cap / 2
    mov dword [rbx + 12], ecx ;; cap /= 2

    ;; realloc(arr, cap * 4)
    mov rdi, [rbx + 0]      ;; rdi = arr
    mov esi, dword [rbx + 12]       ;; prepare pt realloc
    imul rsi, 4     ;; int 4 byte size
    call realloc

    mov [rbx + 0], rax      ;; v->arr = new_arr

    pop rax                 ;; refacem valoarea returnata

    jmp end_pop

error_pop:
    ;; printf("The vector is empty\n");

    push rcx
    mov rdi, error_pop_element
    xor rax, rax
    call printf
    pop rcx

    mov eax, -1     ;; return -1

end_pop:

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

print_vector:         ;;;;;;;;;;;;;;;;;;;; print_vector ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx

    ;; rdi = v
    mov rbx, rdi         ;; rbx = v

    ;; printf("v -> {(")
    push rcx
    mov rdi, out_start
    xor rax, rax
    call printf
    pop rcx

    mov ecx, 0           ;; ecx = i

loop_print:

    ;; daca i >= cap, iesim
    mov edx, dword [rbx + 12]       ;; edx = cap
    cmp ecx, edx
    jge end_loop

    ;; daca i < len, afisam elementul
    mov edx, dword [rbx + 8]        ;; edx = len
    cmp ecx, edx
    jl print_elem

    ;; daca i >= len, printf("[]")
    push rcx
    mov rdi, out_empty
    xor rax, rax
    call printf
    pop rcx

    jmp next_iter

print_elem:

    ;; printf("[%d]", arr[i])
    mov rdx, rcx
    imul rdx, 4     ;; int 4 byte size

    mov rax, [rbx + 0]      ;; rax = arr
    mov esi, dword [rax + rdx]

    push rcx
    mov rdi, out_elem
    xor rax, rax

    call printf

    pop rcx

next_iter:
    inc ecx
    jmp loop_print

end_loop:

    ;; printf("), %d, %d}\n", len, cap)
    mov esi, dword [rbx + 8]        ;; len
    mov edx, dword [rbx + 12]       ;; cap
    mov rdi, out_end
    xor rax, rax

    push rcx
    call printf
    pop rcx

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

free_vector:         ;;;;;;;;;;;;;;;;;;;; free_vector ;;;;;;;;;;;;;;;;;;;;
    push rbp
    mov rbp, rsp
    xor rax, rax
    ;;;;;;;;;;;;;;;

    push rbx
    push rdi            ;; salvam &v

    ;; rdi = &v
    mov rbx, [rdi]      ;; rbx = v

    ;; free(v->arr)
    mov rdi, [rbx + 0]
    call free

    ;; free(v)
    mov rdi, rbx
    call free

    pop rdx             ;; rdx = &v
    mov qword [rdx], 0      ;; *vec = NULL

    pop rbx

    ;;;;;;;;;;;;;;;
    leave
    ret

%include "utility.asm"

section .data
    ;question db "What is your name? ",0
	;hello db "Hello, ",0
	;number db 0
	char db "Y"

section .bss
    ;name resb 16
	;name_len resd 1

section .text
	global _start

_start:
	mov rdi, 5
	mov rsi, 3
	call _op_add
	mov rdi, rax
	call _print_int
	
	push endl
	pop rdi
	call _print_char

	push 0
	pop rdi
	call _exit
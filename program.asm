%include "utility.asm"
section .text
	global _start
_start:
	pop rsi
	pop rdi
	push rax
	push 3
	push 95
	pop rsi
	pop rdi
	call _op_add
	push rax
	pop rdi
	call _print_int
	mov rdi, endl
	call _print_char
	push 0
	pop rdi
	call _exit

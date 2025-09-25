%include "utility.asm"

section .data
    question db "What is your name? ",0
	hello db "Hello, ",0
	number db 0
	endl db 10,0

section .bss
    name resb 16
	name_len resd 1

section .text
	global _start

_start:
	print_int [number]
	print_str endl
	;print_str question

	;input_str name, 16, name_len

	;print_str hello

    ;print_str name

	exit 0
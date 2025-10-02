; mneumonics
SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_EXIT    equ 60
STD_IN       equ 0
STD_OUT      equ 1

section .data
	endl db 10,0

section .bss
    digitSpace resb 100
    digitSpacePos resb 8

section .text

_op_add:
	; adds rdi + rsi, returns in rax
    mov rax, rdi
    add rax, rsi
	ret

_op_sub:
	; subtracts rdi - rsi, returns in rax
    mov rax, rdi
    sub rax, rsi
	ret

_exit:
	; exit code in rdi
    mov rax, SYS_EXIT
    syscall
	ret

_print_char:
	mov rsi, rdi ; rdi contains a char*
	mov rax, SYS_WRITE
	mov rdi, STD_OUT
	mov rdx, 1 ; number of bytes to print
	syscall
	ret

_print_str:
	mov rsi, rdi ; rdi contains a char*
    mov rax, rdi
	mov rbx, 0
_print_str_loop:
	inc rax
	inc rbx
	mov cl, [rax]
	cmp cl, 0
	jne _print_str_loop

	mov rax, SYS_WRITE
	mov rdi, STD_OUT
	mov rdx, rbx
	syscall
    ret

_print_int:
    mov rax, rdi ; rdi contains a char*
	mov rcx, digitSpace ; rcx now points to the starting address of digitSpace
	mov [rcx], byte 0 ; any time there are square brackets around a register that contains a pointer,
    ;              		we're setting the value of the variable. digitSpace[0] = '\0';
	inc rcx ; now rcx points to digitSpace[1]
	mov [digitSpacePos], rcx ; store the index from the above line
_print_int_loop:
    ; important division notes:
    ;   - you can use whatever register you want for the divisor, but the dividend is always rax
    ;   - after dividing, rax contains the quotient, rdx contains the remainder
	mov rdx, 0 ; clear dividend
	mov rbx, 10 ; we are using the rbx as the divisor, so rax (dividend) is divided by 10
	div rbx ; actually perform the division
	push rax ; the quotient is pushed to the stack, might not be needed?
	add rdx, 48 ; adding 48 is a neat trick to get the ascii character of a digit
	mov rcx, [digitSpacePos] ; grab that index we stored in digitSpacePos earlier, store it in rcx
	mov [rcx], dl ; dl is just rdx but only the first 8 bits,
	;				this basically does digitSpace[index] = remainder + 48
	inc rcx ; proceed to next index of digitSpace
	mov [digitSpacePos], rcx ; store index again
	
	pop rax ; the quotient was stored on the stack earlier, let's put that back in rax (idk if it even changed)
	cmp rax, 0 ; compare the quotient to 0
	jne _print_int_loop ; if it is not equal to zero, continue the loop
_print_int_loop2: ; loop to print values to the screen
    mov rdi, [digitSpacePos]
	call _print_char

	mov rcx, [digitSpacePos] ; rcx now contains a pointer to the current char
	dec rcx ; decrement the pointer
	mov [digitSpacePos], rcx ; put it back in digitSpacePos

	cmp rcx, digitSpace
	jge _print_int_loop2
	ret

%macro input_str 3
    mov rsi, %1 ; fix this later
    mov rdx, %2
    call _input_str
    mov [%3], rax
%endmacro

_input_str:
	; we have to be careful with the order so that things aren't overwritten
	mov rdx, rsi ; rsi contains the size, now put into rdx
	mov rsi, rdi ; rdi contains a char*, now put into rsi
    mov rax, SYS_READ
    mov rdi, STD_IN
    syscall
	; rax contains the number of bytes that were read
    ret
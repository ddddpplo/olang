; mneumonics
SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_EXIT    equ 60
STDIN       equ 0
STDOUT      equ 1

section .bss
    digitSpace resb 100
    digitSpacePos resb 8
    digitChar resb 1

section .text

%macro op_add_rax 2
    mov rax, %1
    add rax, %2
%endmacro

%macro op_sub_rax 2
    mov rax, %1,
    sub rax, %2
%endmacro

%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

%macro print_str 1
    mov rsi, %1
    mov rax, %1
	mov rbx, 0
    call _print_str
%endmacro

_print_str:
	inc rax
	inc rbx
	mov cl, [rax]
	cmp cl, 0
	jne _print_str

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rdx, rbx
	syscall
    ret

%macro print_int 1
    mov rax, %1
    call _print_int
%endmacro

_print_int:
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
	print_str digitSpace
    ;print_str [digitSpacePos];

	;mov rcx, [digitSpacePos] ; move the value of |0x005| to the rcx. 
	;dec rcx ; decrement 0x005 - 1 = 0x004
	;mov [digitSpacePos], rcx ; store it back to the digitSpacePos. Now it looks like |0x002| -> |0x004|

	;cmp rcx, digitSpace ; compare 0x004 with 800 zero bits
	;jge _print_int_loop2 ; if rcx greater or equal to 0, then loop it back again
	; at the and, in the address of |0x000| we have ASCII 10. So end of the loop it will make a new line.
	ret

%macro input_str 3
    mov rsi, %1
    mov rdx, %2
    call _input_str
    mov [%3], rax
%endmacro

_input_str:
    mov rax, SYS_READ
    mov rdi, STDIN
    syscall
    ret

SYS_WRITE equ 1 ;for OSX 64bit Intel machines 0x2000004
STD_OUT equ 1

%macro s_exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro simpleWrite 0
	mov rax, SYS_WRITE
	mov rdi, STD_OUT
	mov rsi, rcx ; the address of string to output, in this case it is 0x005 and it contains value of |00000000|
	mov rdx, 1 ; number of bytes to be printed
	syscall ; write it in to screen
%endmacro
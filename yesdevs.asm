; 15.02.2020
;
; Have an animation with a moving X from left to right
;

    org 0x0100
    jmp start



x_pos: equ 0x0800
string: db "Hello, world", 0
string_welcome: db "Welcome: ", 0

start:
    call clear_screen
    mov dx, 0x0618
    call set_cursor
    mov bx, string_welcome
    call print_string
    mov byte [x_pos], 0
main_loop:
    mov cx, 12
main_loop_1:
    call draw
    add byte [x_pos], 1
    nop
    call wait_for_tick
    call is_key_pressed
    jnz end
    loop main_loop_1  
    mov cx, 12
main_loop_2:
    sub byte [x_pos], 1
    call draw
    nop
    call wait_for_tick
    call is_key_pressed
    jnz end
    loop main_loop_2  
    jmp main_loop
end:
    mov al, '?'
    call print_char
    mov ah, 0x0
    int 0x16
    int 0x20

draw:
    mov dx, 0x0818
    call set_cursor
    mov ax, string
    call draw_string
    call print_newline
    ret

draw_string:
    push ax
    push bx
    push cx
    mov bx, ax
    mov cx, 0    
draw_string_repeat:
    push bx                 ; get current char of string
    add bx, cx
    mov al, [bx]            
    pop bx
    cmp al, 0               ; is string finished
    je draw_string_end
    cmp cl, byte [x_pos]     ; am i at current pos 
    jne draw_string_repeat_1 ; replace char with an 'X'
    mov al, 'X'
draw_string_repeat_1: 
    call print_char 
    inc cx
    jmp draw_string_repeat
draw_string_end:
    pop cx
    pop bx
    pop ax
    ret

set_cursor:
    push ax
    mov ah, 0x02
    mov bh, 0x0
    int 0x10
    pop ax
    ret

; ---- library functions -----

; --- printing

print_char:
    push ax
    push bx
    mov ah, 0x0e
    mov bx, 0x000f
    int 0x10
    pop bx
    pop ax
    ret

print_newline:
    push ax
    mov ax, 0x0a
    call print_char
    mov ax, 0x0d
    call print_char
    pop ax
    ret

print_string:   ; prints characters at [bx] until a '\0' is found
    push ax
    push bx
print_string_repeat:
    mov al, byte [bx]     
    cmp al, 0               ; is string finished
    je print_string_end
    call print_char 
    inc bx
    jmp print_string_repeat
print_string_end:
    pop bx
    pop ax
    ret
    
clear_screen:
    push ax
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    pop ax
    ret

; --- others


get_time:   ; ticks are in (high) cx, (low) dx
    push ax 
    mov ah, 0x00
    int 0x1A
    pop ax
    ret    

is_key_pressed:
    push ax
    mov ah, 0x01
    int 0x16
    pop ax
    ret

wait_for_tick:   ; ticks are in cx, dx
    push ax 
    push cx
    push dx
    call get_time
    mov ax, dx
wait_for_tick_1:
    call get_time
    cmp ax, dx
    je wait_for_tick_1
    pop dx
    pop cx
    pop ax
    ret             

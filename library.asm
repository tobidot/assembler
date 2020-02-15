
    int 0x20
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
    
; --- screen control

set_cursor:
    push ax
    mov ah, 0x02
    mov bh, 0x0
    int 0x10
    pop ax
    ret

clear_screen:
    push ax
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    pop ax
    ret

; --- flow controls

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

; --- interrupt shorthands

get_time:   ; ticks are in (high) cx, (low) dx
    push ax 
    mov ah, 0x00
    int 0x1A
    pop ax
    ret    

is_key_pressed: ; set the Z-Flag (jz label) to 1 if a key is pressed
    push ax
    mov ah, 0x01
    int 0x16
    pop ax
    ret

; --- others
        

    int 0x20
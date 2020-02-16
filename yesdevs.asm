; 15.02.2020
;
; Have an animation with a moving X from left to right
;

    org 0x0100
    jmp start


bitmap_y: 
    db 0b00000000
    db 0b10000010
    db 0b01000100
    db 0b00101000
    db 0b00110000
    db 0b11100000

bitmap_e: 
    db 0b00000000
    db 0b00111100
    db 0b01000010
    db 0b01111110
    db 0b01000000
    db 0b00111100

bitmap_s: 
    db 0b00000000
    db 0b01111110
    db 0b11000001
    db 0b00111100
    db 0b10000011
    db 0b01111110

bitmap_d: 
    db 0b00000010
    db 0b00000010
    db 0b00111110
    db 0b01000010
    db 0b01000010
    db 0b00111110

bitmap_ex: 
    db 0b00011000
    db 0b00111100
    db 0b00011000
    db 0b00011000
    db 0b00000000
    db 0b00011000

bitmap_v: 
    db 0b00000000
    db 0b01000010
    db 0b01000010
    db 0b00100100
    db 0b00100100
    db 0b00011000


start:    
    call clear_screen  
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

loop:

    mov cx, 0x0106    
    mov dx, 0x0402
    add dl, 0x5
    mov bx, bitmap_y
    call draw_bitmap    
    mov bx, bitmap_e
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_s
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_ex
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_d
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_e
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_v
    add dl, 0x08
    call draw_bitmap
    mov bx, bitmap_s
    add dl, 0x08
    call draw_bitmap

    call wait_for_tick
    call is_key_pressed
    jz loop
end:
    mov ah, 0x01
    mov cx, 0x0607
    int 0x10

    mov dx, 0x0e04
    call set_cursor  
    mov al, '?'
    call print_char    
    call wait_for_key_press
    call print_char  
    int 0x20
   
; --- funcitons

; --- draws the bitmap at [bx] with (ch*8) cols and (cl) rows at position (dx)
; at (dx) position => (dh) => row, (dl) => col
; 8 x 6
draw_bitmap:
    push ax
    push bx 
    push cx
    push dx
    mov al, ch
    mov ah, 0x0     ; store cols
    mov ch, 0x0     ; store rows
draw_bitmap__all_rows:
    call set_cursor
    push cx
    mov cl, al
    call draw_bitmap__row
    pop cx
    inc dh          ; mov to next line
    loop draw_bitmap__all_rows
    pop dx
    pop cx
    pop bx 
    pop ax
    ret
    
draw_bitmap__row:    
    push ax
    mov ah, 0x0
    mov al, byte [bx]
    call draw_bitmap__byte
    add bx, 1
    loop draw_bitmap__row
    pop ax
    ret
draw_bitmap__byte:
    push cx
    mov cx, 8
draw_bitmap__byte_repeat:
    shl al, 1                       ; check leftmost bit if set
    push ax
    jnc draw_bitmap__byte_skip      ; then draw '+''
    mov al, '+'
    call print_char
    pop ax
    loop draw_bitmap__byte_repeat
    jmp draw_bitmap__byte_end
draw_bitmap__byte_skip:             ; else draw ' '
    mov al, ' '
    call print_char
    pop ax
    loop draw_bitmap__byte_repeat
draw_bitmap__byte_end:
    pop cx
    ret

   
; ---- general-library functions -----
    int 0x20

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

; mov the cursoer 
; (dh) => row
; (dl) => col
set_cursor:
    push ax
    push bx
    mov ah, 0x02
    mov bh, 0x0
    int 0x10
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
    
; returns 
; (ah) = keycode
; (al) = ascii char
wait_for_key_press:     
    call is_key_pressed
    nop
    jz wait_for_key_press
    call get_key_pressed
    ret   

; --- interrupt shorthands

; ticks are in (high) cx, (low) dx
get_time:   
    push ax 
    mov ah, 0x00
    int 0x1A
    pop ax
    ret    

; set the Z-Flag (jz label) to 1 if a key is pressed
is_key_pressed: 
    push ax
    mov ah, 0x01
    int 0x16
    pop ax
    ret

; returns 
; (ah) = keycode
; (al) = ascii char
get_key_pressed: 
    mov ah, 0x00
    int 0x16
    ret

; --- others
        

    int 0x20
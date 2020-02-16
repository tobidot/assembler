; ------- console-graphic library --------------
; 16.02.2020
; - added 'draw_rect'
; 16.02.2020
; - added a check to 'draw_bitmap' to prevent it from drawing outside the screen
; 16.02.2020
; - fixed an issue where a bordering bit would break 'draw_image'
; 16.02.2020

; --- draws the bitmap at [bx] with (ch*8) cols and (cl) rows at position (dx)
; (dh) => row
; (dl) => col
; (ch) => width * 8
; (cl) => height
draw_bitmap:
    push ax
    push bx 
    push cx
    push dx
    mov al, ch
    mov ah, 0x0     ; store cols
    mov ch, 0x0     ; store rows
draw_bitmap__all_rows:
    cmp dh, 0                   ; check boundries
    jl draw_bitmap__all_rows_1
    cmp dh, 23
    jg draw_bitmap__all_rows_1
    call set_cursor             ; draw row
    push cx
    mov cl, al
    call draw_bitmap__row
    pop cx
draw_bitmap__all_rows_1: 
    inc dh          ; mov to next line
    loop draw_bitmap__all_rows
    pop dx
    pop cx
    pop bx 
    pop ax
    ret
    
draw_bitmap__row:    
    push ax
    push dx
    cmp dl, 0                   ; check boundries
    jl draw_bitmap__row_1
    cmp dl, 72
    jg draw_bitmap__row_1
    mov ah, 0x0
    mov al, byte [bx]
    call draw_bitmap__byte
draw_bitmap__row_1:
    add bx, 1
    add dl, 1
    loop draw_bitmap__row
    pop dx
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

   
; --- draws a rect at 
; !!! needs massive improvement
; (dh) => row
; (dl) => col
; (ch) => width 
; (cl) => height
; (al) => character to draw
draw_rect:
    push ax
    push bx 
    push cx
    push dx
    mov bl, ch
    mov bh, 0x0
draw_rect__lines:
    push dx
    push cx
    mov ch, 0x0
    mov cl, bl  ; set cx to width 
    call draw_rect__horizontal
    pop cx
    pop dx

    push dx
    push cx
    add dh, cl  ; mov curser to the bottom
    mov ch, 0x0
    mov cl, bl  ; set cx to width 
    call draw_rect__horizontal
    pop cx
    pop dx

    push dx
    push cx
    mov ch, 0x0
    call draw_rect__vertical
    pop cx
    pop dx
    
    push dx
    push cx
    add dl, ch  ; mov curser to the right
    mov ch, 0x0
    call draw_rect__vertical
    pop cx
    pop dx
    ;
    pop dx
    pop cx
    pop bx 
    pop ax
    ret    
draw_rect__horizontal:
    push cx
    push dx
draw_rect__horizontal_repeat:
    call set_cursor    
    call print_char
    inc dl  
    loop draw_rect__horizontal_repeat
    pop dx
    pop cx
    ret
draw_rect__vertical:
    push cx
    push dx
draw_rect__vertical_repeat:
    call set_cursor    
    call print_char
    inc dh  
    loop draw_rect__vertical_repeat
    pop dx
    pop cx
    ret
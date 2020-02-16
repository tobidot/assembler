; ------- console-graphic library --------------
; 16.02.2020
; - fixed an issue where a bordering bit would break 'draw_image'
; 16.02.2020

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

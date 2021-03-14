; multi-segment executable file template.

data segment
   left    equ     4bh 
   right   equ     4dh
   up      equ     48h
   down    equ     50h
   ;ds for timer count
   ;di for direction
   ;si for rnd 'o' location
   ;es for score
ends

stack segment
    dw   128  dup(0)
ends

code segment
 main proc far
;set cursor 
   mov dh,4
   mov dl,10
   mov ah,2
   int 10h
  ;Up Line
   mov ah,09h
   mov al,'#'
   mov bh,0
   mov bl,1101b 
   mov cx,58
   int 10h
   ;;;;;
   ;set cursor
   mov dh,20
   mov dl,10
   mov ah,2
   int 10h
   ;Down Line
   mov ah,09h
   mov al,'#'
   mov bh,0
   mov bl,1101b 
   mov cx,58
   int 10h
   
   ;set cursor at UP Left
   mov dh,4
   mov dl,10
   ;select '#' char for Left & Right column
   mov al,'#'
   mov bh,0
   mov bl,1101b 
   int 10h
   mov cx,16
   ;Print Left column 
   Lcol:
   push cx
   mov ah,2
   inc dh
   int 10h              
   mov ah,9h
   mov cx,1
   int 10h
   pop cx
   loop Lcol
   ;Set cursor at UP Right
   mov dl,67
   mov dh,4
   mov cx,16
   ;Print Right column
   Rcol:
   push cx
   mov ah,2
   inc dh
   int 10h   
   mov ah,9h
   mov cx,1
   int 10h
   pop cx
   loop Rcol
;GAME-----------------------------------------------------------------------------------------------------------------------------------------
   ;Set cursor at UP Right for game start
   mov ax,20
   mov ds,ax
   sub ax,ax
   mov es,ax
   mov dh,5
   mov dl,11
   mov ah,2
   sub di,di
   int 10h 
   ;wait for input                                  
   wait_in:
   sub ax,ax
   ;Get keyboard status
   Get_st:
   call Get_stats
   jz wait_in
   call Get_key
   call Cmp_input
 ends
;Functions_________________________________________________________________________________________________________________________________________________ 
;Get Keyboard Status
 Get_stats proc
  push ax
  mov ah,01h
  int 16h
  pop ax
 ret
 Get_stats endp 
;Get keyboard buffer
 Get_key proc   
  sub ah,ah
  int 16h  
 ret   
 Get_key endp
 ;Compare key with directions 
 Cmp_input proc   
  cmp ah,right
  jz right
  cmp ah,left
  jz left
  cmp ah,up
  jz  up
  cmp ah,down
  jz  down 
  jmp wait_in  
  ret
 Cmp_input endp 
 Clear proc
    
    cmp di,1
    jz retR
    cmp di,2
    jz retL
    cmp di,3
    jz retD
    cmp di,4
    jz retU
    jmp retN
retR:
    call clearR
    ret
retL:
    call clearL
    ret
retD:
    call clearD
    ret
retU:
    call ClearU
    ret
retN:
    ret  
;Clear right tail   
 ClearR proc
   push dx
   push cx
   mov cx,4
   lblcr:
   push cx
   mov ah,09h
   mov al,' '
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   dec dl 
   mov ah,2
   int 10h
   pop cx
   loop lblcr
   pop cx
   pop dx
   ret
 endp 
;Clear left tail 
 ClearL proc
   push dx
   push cx  
   mov cx,4  
   lblcl:
   push cx 
   mov ah,09h
   mov al,' '
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h 
   inc dl
   mov ah,2
   int 10h
   pop cx
   loop lblcl
   pop cx
   pop dx   
   ret
 endp
;Clear down tail 
 ClearD proc
    push dx
    push cx
    mov cx,4
    lblcd:
    push cx
    mov ah,09h
    mov al,' '
    mov bh,0
    mov bl,1010b
    mov cx,1
    int 10h
    dec dh
    mov ah,2
    int 10h
    pop cx
    loop lblcd
    pop cx
    pop dx
    ret   
 endp 
;Clear up tail 
 ClearU proc
    push dx
    push cx
    mov cx,4
    lblcu:
    push cx
    mov ah,09h
    mov al,' '
    mov bh,0
    mov bl,1010b
    mov cx,1
    int 10h
    inc dh
    mov ah,2
    int 10h
    pop cx
    loop lblcu
    pop cx
    pop dx
    ret 
 endp
 
 
;generate random star
Gen_rnd proc
    push ax
    push cx
    push dx
        
    mov dx,si
    mov ah,2
    int 10h
    push cx
    mov ah,09h
    mov al,' '
    mov bh,0
    mov bl,1110b 
    mov cx,1
    int 10h
    pop cx
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    mov  ax, dx
    xor  dx, dx
    mov  cx, 10    
    div  cx       ; here dl contains the remainder of the division - from 0 to 9 
    add dl,5
    mov dh,dl       ;row rnd
    push dx
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    mov  ax, dx
    xor  dx, dx
    mov  cx, 10    
    div  cx       ; here dx contains the remainder of the division - from 0 to 9
    add dl,13      ;col rnd
    mov ah,dl
    pop dx
    mov dl,ah
    mov ah,2
    int 10h
    mov si,dx
    push cx
    mov ah,09h
    mov al,'o'
    mov bh,0
    mov bl,1110b 
    mov cx,1
    int 10h
    pop cx           
    pop dx
    pop cx
    pop ax
 
ret
endp 


;dsicription: What he did: 1.We moved value in DX to AX 2.We cleared DX. 3.We moved 10 dec to CX. 4.We divided AX by CX hence we get a remainder within 0-9 Dec which is stored in DX 5.Finally, we added ASCII '0' (dec 48) to DX to get them into ASCII '0' to '9'.


timer proc
    push ax
    
    mov ax,ds
    dec ax
    jz rettz
    mov ds,ax
    rettnz:
    pop ax
    ret 
    rettz:
    call Gen_rnd
    mov ax,20
    mov ds,ax
    pop ax
    ret 
endp

compare proc
    push dx
    push ax
    sub ax,ax
    cmp dx,si 
    jnz retcnz
    mov ax,es
    inc ax
    cmp ax,2
    jz endw
    mov es,ax
retcnz:
pop ax
pop dx    
ret
endp




;movements;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Move right
right:
  call Clear
  mov di,1
  mov cx,4
   lbl0:
   push cx  
   inc dl
   cmp dl,64
   jz end
   mov ah,02h
   int 10h   
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   pop cx
   loop lbl0
   mov cx,500
   lbl1:
   push cx
   sub dl,3
   mov ah,2
   int 10h
   mov ah,09h
   mov al,' '
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   ;call compare 
   add dl,4
   cmp dl,68
   mov ah,2
   int 10h
   jz end
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   call get_stats
   jnz wait_in
   pop ax   
   pop cx
   call timer
   call compare   
   loop lbl1
;Move left   
left:
   call Clear
   mov di,2
   mov cx,4
   lbl2:
   push cx  
   dec dl
   cmp dl,9
   jz end
   mov ah,02h
   int 10h   
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   pop cx
   loop lbl2 
   mov cx,500
   lbl3:
   push cx
   add dl,3
   mov ah,2
   int 10h
   mov ah,09h
   mov al,' '
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   ;call compare 
   sub dl,4
   cmp dl,4
   mov ah,2
   int 10h
   jz end
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   push ax
   call get_stats
   jnz wait_in
   pop ax   
   pop cx
   call timer
   call compare  
   loop lbl3
;Move down   
down:
   call clear
   mov di,3 
   push cx
   mov ah,2
   int 10h    
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h   
   pop cx
   mov cx,500
   lbl4:
   push cx
   sub dh,3
   mov ah,2
   int 10h
   mov ah,02h
   push dx
   mov dl,' '
   int 21h
   pop dx   
   add dh,4   
   mov ah,2
   int 10h 
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h         
   cmp dh,20
   jz end
   push ax
   call get_stats
   jnz wait_in
   pop ax   
   pop cx
   call timer
   call compare
   loop lbl4
;Move up
up:
   call clear
   mov di,4
   push cx
   mov ah,2
   int 10h   
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   pop cx
   mov cx,500   
   lbl5:   
   push cx   
   add dh,3         
   mov ah,2
   int 10h   
   mov ah,02h
   push dx
   mov dl,' '
   int 21h   
   pop dx 
   sub dh,4 
   mov ah,2
   int 10h
   mov ah,09h
   mov al,'*'
   mov bh,0
   mov bl,1010b 
   mov cx,1
   int 10h
   cmp dh,4
   jz end
   push ax
   call get_stats
   jnz wait_in
   pop ax   
   pop cx
   call timer
   call compare
   loop lbl5  
    
    
    
    
   end:
   mov ah,09h
   mov al,'L'
   mov bh,0
   mov bl,0100b 
   mov cx,1
   int 10h
   mov ax, 4c00h ; exit to operating system.
   int 21h

   endw:
   
   mov ah,09h
   mov al,'W'
   mov bh,0
   mov bl,0010b 
   mov cx,1
   int 10h
   mov ax, 4c00h ; exit to operating system.
   int 21h
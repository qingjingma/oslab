INITSEG  = 0x9000

entry _start
_start:

! Print "NOW we are in SETUP"

    mov ah,#0x03                ! read cursor pos
    xor bh,bh                   ! 页号bh=0
    int 0x10

    mov cx,#27
    mov bx,#0x0007              ! page 0, attribute 7 (normal) 页号BH=0 属性BL=7正常显示
    mov bp,#msg2                ! ES:BP要显示的字符串地址
    mov ax,cs        		! cs->es
    mov es,ax
    mov ax,#0x1301              ! write string, move cursor AH=13显示字符串 AL=01光标跟随移动
    int 0x10
    mov ax,cs
    mov es,ax

! init ss:sp
    mov ax,#INITSEG
    mov ss,ax
    mov sp,#0xFF00

! Get Params
   mov    ax,#INITSEG		! 设置 ds = 0x9000
   mov    ds,ax  
   mov    ah,#0x03		! 读入光标位置 CH=光标起始位置，CL=光标结束位置，DH=光标行号(0-based)，DL=光标列号(0-based)
   xor    bh,bh
   int    0x10
   mov    [0],dx		! 将光标位置写入 0x90000
   
   ! 读入内存大小位置
   mov    ah,#0x88
   int    0x15
   mov    [2],ax
   
   ! 从 0x41 处拷贝 16 个字节（磁盘参数表）
   mov    ax,#0x0000
   mov    ds,ax
   lds    si,[4*0x41]              !int 0x41 的中断向量位置(4*0x41 = 0x0000:0x0104)存放是第一个硬盘的基本参数表
   mov    ax,#INITSEG
   mov    es,ax
   mov    di,#0x0004
   mov    cx,#0x10
   ! 重复16次
   rep
   movsb

! Be Ready to Print
    mov ax,cs
    mov es,ax
    mov ax,#INITSEG
    mov ds,ax
! Cursor Position
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#18
    mov bx,#0x0007
    mov bp,#msg_cursor
    mov ax,#0x1301
    int 0x10
    mov dx,[0]
    call    print_hex
! Memory Size
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#14
    mov bx,#0x0007
    mov bp,#msg_memory
    mov ax,#0x1301
    int 0x10
    mov dx,[2]
    call    print_hex
! Add KB
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#2
    mov bx,#0x0007
    mov bp,#msg_kb
    mov ax,#0x1301
    int 0x10
! Cyles
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#7
    mov bx,#0x0007
    mov bp,#msg_cyles
    mov ax,#0x1301
    int 0x10
    mov dx,[4]
    call    print_hex
! Heads
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#8
    mov bx,#0x0007
    mov bp,#msg_heads
    mov ax,#0x1301
    int 0x10
    mov dx,[6]
    call    print_hex
! Secotrs
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#10
    mov bx,#0x0007
    mov bp,#msg_sectors
    mov ax,#0x1301
    int 0x10
    mov dx,[12]
    call    print_hex

inf_loop:
    jmp inf_loop
print_hex:
! 4 个十六进制数字
    mov cx,#4
! 将(bp)所指的值放入 dx 中，如果 bp 是指向栈顶的话
    mov dx,(bp)
print_digit:
! 循环以使低 4 比特用上 !! 取 dx 的高 4 比特移到低 4 比特处。
    rol dx,#4
! ah = 请求的功能值，al = 半字节(4 个比特)掩码。
    mov ax,#0xe0f
! 取 dl 的低 4 比特值。
    and al,dl
! 给 al 数字加上十六进制 0x30
    add al,#0x30
    cmp al,#0x3a
    jl  outp               ! 是一个不大于十的数字
    add al,#0x07          ! 是a～f，要多加 7
outp:
    int    0x10
    loop   print_digit
    ret
print_nl:				! 打印回车换行
    mov    ax,#0xe0d     ! CR
    int    0x10
    mov    al,#0xa     ! LF
    int    0x10
    ret
msg2:
    .byte   13,10
    .ascii  "Now we are in setup ~"
    .byte   13,10,13,10
msg_cursor:
    .byte 13,10
    .ascii "Cursor position:"
msg_memory:
    .byte 13,10
    .ascii "Memory Size:"
msg_kb:
    .ascii "KB"
msg_cyles:
    .byte 13,10
    .ascii "Cyls:"

msg_heads:
    .byte 13,10
    .ascii "Heads:"
msg_sectors:
    .byte 13,10
    .ascii "Sectors:"

.org 510                                ! boot_flag 必须在最后两个字节
boot_flag:
    .word   0xAA55                      ! 设置引导扇区标记 0xAA55

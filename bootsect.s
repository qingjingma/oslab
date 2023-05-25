!
! NOTE! currently system is at most 8*65536 bytes long. This should be no
! problem, even in the future. I want to keep it simple. This 512 kB
! kernel size should be enough, especially as this doesn't contain the
! buffer cache as in minix
!
! The loader has been made as simple as possible, and continuos
! read errors will result in a unbreakable loop. Reboot by hand. It
! loads pretty fast by getting whole sectors at a time whenever possible.

entry _start
_start:
    mov ah,#0x03                ! read cursor pos
    xor bh,bh                   ! 页号bh=0
    int 0x10

    mov cx,#36
    mov bx,#0x0007              ! page 0, attribute 7 (normal) 页号BH=0 属性BL=7正常显示
    mov bp,#msg1                ! ES:BP要显示的字符串地址
    mov ax,#0x07c0              !original address of boot-sector
    mov es,ax
    mov ax,#0x1301              ! write string, move cursor AH=13显示字符串 AL=01光标跟随移动
    int 0x10
inf_loop:
    jmp inf_loop
msg1:
    .byte   13,10
    .ascii  "Hello OS world, my name is MQJ"
    .byte   13,10,13,10
.org 510                                ! boot_flag 必须在最后两个字节
boot_flag:
    .word   0xAA55                      ! 设置引导扇区标记 0xAA55

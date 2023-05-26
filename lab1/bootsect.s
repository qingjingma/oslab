!
! SYS_SIZE is the number of clicks (16 bytes) to be loaded.
! 0x3000 is 0x30000 bytes = 196kB, more than enough for current
! versions of linux
!
SYSSIZE = 0x3000
!
!	bootsect.s		(C) 1991 Linus Torvalds
!
! bootsect.s is loaded at 0x7c00 by the bios-startup routines, and moves
! iself out of the way to address 0x90000, and jumps there.
!
! It then loads 'setup' directly after itself (0x90200), and the system
! at 0x10000, using BIOS interrupts. 
!
! NOTE! currently system is at most 8*65536 bytes long. This should be no
! problem, even in the future. I want to keep it simple. This 512 kB
! kernel size should be enough, especially as this doesn't contain the
! buffer cache as in minix
!
! The loader has been made as simple as possible, and continuos
! read errors will result in a unbreakable loop. Reboot by hand. It
! loads pretty fast by getting whole sectors at a time whenever possible.


SETUPLEN = 2				! nr of setup-sectors
SETUPSEG=0x07e0				!setup starts here
INITSEG  = 0x9000
 
entry _start
_start:
    mov ah,#0x03                ! read cursor pos
    xor bh,bh			! 页号bh=0
    int 0x10

    mov cx,#36
    mov bx,#0x0007 		! page 0, attribute 7 (normal) 页号BH=0 属性BL=7正常显示
    mov bp,#msg1		! ES:BP要显示的字符串地址
    mov ax,#0x07c0		!original address of boot-sector
    mov es,ax
    mov ax,#0x1301 		! write string, move cursor AH=13显示字符串 AL=01光标跟随移动
    int 0x10

load_setup:
    mov dx,#0x0000		! 设置驱动器和磁头(drive 0, head 0): 软盘 0 磁头	
    mov cx,#0x0002		! 设置扇区号和磁道(sector 2, track 0): 0 磁头、0 磁道、2 扇区
    mov bx,#0x0200		! 设置读入的内存地址：BOOTSEG+address = 512，偏移512字节
    mov ax,#0x0200+SETUPLEN	! 设置读入的扇区个数(service 2, nr of sectors)，
    int 0x13			! 应用 0x13 号 BIOS 中断读入 2 个 setup.s扇区
    jnc ok_load_setup		! 读入成功，跳转到 ok_load_setup: ok - continue
    mov dx,#0x0000		! 软驱、软盘有问题才会执行到这里
    mov ax,#0x0000		! 复位软驱
    int 0x13
    jmp load_setup		!再次尝试读取

ok_load_setup:			!跳到 setup 执行。
    jmpi    0,SETUPSEG 

msg1:
    .byte   13,10
    .ascii  "Hello OS world, my name is MQJ"
    .byte   13,10,13,10
.org 510				! boot_flag 必须在最后两个字节
boot_flag:		
    .word   0xAA55			! 设置引导扇区标记 0xAA55

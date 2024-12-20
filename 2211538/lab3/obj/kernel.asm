
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02082b7          	lui	t0,0xc0208
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00009517          	auipc	a0,0x9
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc0209040 <edata>
ffffffffc020003e:	00010617          	auipc	a2,0x10
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0210598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	026040ef          	jal	ra,ffffffffc0204074 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	04e58593          	addi	a1,a1,78 # ffffffffc02040a0 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	06650513          	addi	a0,a0,102 # ffffffffc02040c0 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	09e000ef          	jal	ra,ffffffffc0200104 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	263010ef          	jal	ra,ffffffffc0201acc <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4d8000ef          	jal	ra,ffffffffc0200546 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	3ee030ef          	jal	ra,ffffffffc0203460 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	41e000ef          	jal	ra,ffffffffc0200494 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	744020ef          	jal	ra,ffffffffc02027be <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	352000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	398000ef          	jal	ra,ffffffffc0200424 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	2e7030ef          	jal	ra,ffffffffc0203b98 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	2b3030ef          	jal	ra,ffffffffc0203b98 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	ae0d                	j	ffffffffc0200424 <cons_putc>

ffffffffc02000f4 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f4:	1141                	addi	sp,sp,-16
ffffffffc02000f6:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f8:	360000ef          	jal	ra,ffffffffc0200458 <cons_getc>
ffffffffc02000fc:	dd75                	beqz	a0,ffffffffc02000f8 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fe:	60a2                	ld	ra,8(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200106:	00004517          	auipc	a0,0x4
ffffffffc020010a:	ff250513          	addi	a0,a0,-14 # ffffffffc02040f8 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc020010e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200110:	fafff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200114:	00000597          	auipc	a1,0x0
ffffffffc0200118:	f2258593          	addi	a1,a1,-222 # ffffffffc0200036 <kern_init>
ffffffffc020011c:	00004517          	auipc	a0,0x4
ffffffffc0200120:	ffc50513          	addi	a0,a0,-4 # ffffffffc0204118 <etext+0x7a>
ffffffffc0200124:	f9bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200128:	00004597          	auipc	a1,0x4
ffffffffc020012c:	f7658593          	addi	a1,a1,-138 # ffffffffc020409e <etext>
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	00850513          	addi	a0,a0,8 # ffffffffc0204138 <etext+0x9a>
ffffffffc0200138:	f87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013c:	00009597          	auipc	a1,0x9
ffffffffc0200140:	f0458593          	addi	a1,a1,-252 # ffffffffc0209040 <edata>
ffffffffc0200144:	00004517          	auipc	a0,0x4
ffffffffc0200148:	01450513          	addi	a0,a0,20 # ffffffffc0204158 <etext+0xba>
ffffffffc020014c:	f73ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200150:	00010597          	auipc	a1,0x10
ffffffffc0200154:	44858593          	addi	a1,a1,1096 # ffffffffc0210598 <end>
ffffffffc0200158:	00004517          	auipc	a0,0x4
ffffffffc020015c:	02050513          	addi	a0,a0,32 # ffffffffc0204178 <etext+0xda>
ffffffffc0200160:	f5fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200164:	00011597          	auipc	a1,0x11
ffffffffc0200168:	83358593          	addi	a1,a1,-1997 # ffffffffc0210997 <end+0x3ff>
ffffffffc020016c:	00000797          	auipc	a5,0x0
ffffffffc0200170:	eca78793          	addi	a5,a5,-310 # ffffffffc0200036 <kern_init>
ffffffffc0200174:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200178:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200182:	95be                	add	a1,a1,a5
ffffffffc0200184:	85a9                	srai	a1,a1,0xa
ffffffffc0200186:	00004517          	auipc	a0,0x4
ffffffffc020018a:	01250513          	addi	a0,a0,18 # ffffffffc0204198 <etext+0xfa>
}
ffffffffc020018e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200190:	b73d                	j	ffffffffc02000be <cprintf>

ffffffffc0200192 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200192:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200194:	00004617          	auipc	a2,0x4
ffffffffc0200198:	f3460613          	addi	a2,a2,-204 # ffffffffc02040c8 <etext+0x2a>
ffffffffc020019c:	04e00593          	li	a1,78
ffffffffc02001a0:	00004517          	auipc	a0,0x4
ffffffffc02001a4:	f4050513          	addi	a0,a0,-192 # ffffffffc02040e0 <etext+0x42>
void print_stackframe(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001aa:	1c6000ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02001ae <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ae:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b0:	00004617          	auipc	a2,0x4
ffffffffc02001b4:	0f060613          	addi	a2,a2,240 # ffffffffc02042a0 <commands+0xd8>
ffffffffc02001b8:	00004597          	auipc	a1,0x4
ffffffffc02001bc:	10858593          	addi	a1,a1,264 # ffffffffc02042c0 <commands+0xf8>
ffffffffc02001c0:	00004517          	auipc	a0,0x4
ffffffffc02001c4:	10850513          	addi	a0,a0,264 # ffffffffc02042c8 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ca:	ef5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ce:	00004617          	auipc	a2,0x4
ffffffffc02001d2:	10a60613          	addi	a2,a2,266 # ffffffffc02042d8 <commands+0x110>
ffffffffc02001d6:	00004597          	auipc	a1,0x4
ffffffffc02001da:	12a58593          	addi	a1,a1,298 # ffffffffc0204300 <commands+0x138>
ffffffffc02001de:	00004517          	auipc	a0,0x4
ffffffffc02001e2:	0ea50513          	addi	a0,a0,234 # ffffffffc02042c8 <commands+0x100>
ffffffffc02001e6:	ed9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ea:	00004617          	auipc	a2,0x4
ffffffffc02001ee:	12660613          	addi	a2,a2,294 # ffffffffc0204310 <commands+0x148>
ffffffffc02001f2:	00004597          	auipc	a1,0x4
ffffffffc02001f6:	13e58593          	addi	a1,a1,318 # ffffffffc0204330 <commands+0x168>
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	0ce50513          	addi	a0,a0,206 # ffffffffc02042c8 <commands+0x100>
ffffffffc0200202:	ebdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc0200206:	60a2                	ld	ra,8(sp)
ffffffffc0200208:	4501                	li	a0,0
ffffffffc020020a:	0141                	addi	sp,sp,16
ffffffffc020020c:	8082                	ret

ffffffffc020020e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020e:	1141                	addi	sp,sp,-16
ffffffffc0200210:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200212:	ef3ff0ef          	jal	ra,ffffffffc0200104 <print_kerninfo>
    return 0;
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
ffffffffc0200218:	4501                	li	a0,0
ffffffffc020021a:	0141                	addi	sp,sp,16
ffffffffc020021c:	8082                	ret

ffffffffc020021e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021e:	1141                	addi	sp,sp,-16
ffffffffc0200220:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200222:	f71ff0ef          	jal	ra,ffffffffc0200192 <print_stackframe>
    return 0;
}
ffffffffc0200226:	60a2                	ld	ra,8(sp)
ffffffffc0200228:	4501                	li	a0,0
ffffffffc020022a:	0141                	addi	sp,sp,16
ffffffffc020022c:	8082                	ret

ffffffffc020022e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022e:	7115                	addi	sp,sp,-224
ffffffffc0200230:	e962                	sd	s8,144(sp)
ffffffffc0200232:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200234:	00004517          	auipc	a0,0x4
ffffffffc0200238:	fdc50513          	addi	a0,a0,-36 # ffffffffc0204210 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020023c:	ed86                	sd	ra,216(sp)
ffffffffc020023e:	e9a2                	sd	s0,208(sp)
ffffffffc0200240:	e5a6                	sd	s1,200(sp)
ffffffffc0200242:	e1ca                	sd	s2,192(sp)
ffffffffc0200244:	fd4e                	sd	s3,184(sp)
ffffffffc0200246:	f952                	sd	s4,176(sp)
ffffffffc0200248:	f556                	sd	s5,168(sp)
ffffffffc020024a:	f15a                	sd	s6,160(sp)
ffffffffc020024c:	ed5e                	sd	s7,152(sp)
ffffffffc020024e:	e566                	sd	s9,136(sp)
ffffffffc0200250:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200252:	e6dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200256:	00004517          	auipc	a0,0x4
ffffffffc020025a:	fe250513          	addi	a0,a0,-30 # ffffffffc0204238 <commands+0x70>
ffffffffc020025e:	e61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200262:	000c0563          	beqz	s8,ffffffffc020026c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200266:	8562                	mv	a0,s8
ffffffffc0200268:	4c8000ef          	jal	ra,ffffffffc0200730 <print_trapframe>
ffffffffc020026c:	00004c97          	auipc	s9,0x4
ffffffffc0200270:	f5cc8c93          	addi	s9,s9,-164 # ffffffffc02041c8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200274:	00005997          	auipc	s3,0x5
ffffffffc0200278:	49c98993          	addi	s3,s3,1180 # ffffffffc0205710 <default_pmm_manager+0x940>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027c:	00004917          	auipc	s2,0x4
ffffffffc0200280:	fe490913          	addi	s2,s2,-28 # ffffffffc0204260 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200284:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200286:	00004b17          	auipc	s6,0x4
ffffffffc020028a:	fe2b0b13          	addi	s6,s6,-30 # ffffffffc0204268 <commands+0xa0>
    if (argc == 0) {
ffffffffc020028e:	00004a97          	auipc	s5,0x4
ffffffffc0200292:	032a8a93          	addi	s5,s5,50 # ffffffffc02042c0 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200296:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200298:	854e                	mv	a0,s3
ffffffffc020029a:	47f030ef          	jal	ra,ffffffffc0203f18 <readline>
ffffffffc020029e:	842a                	mv	s0,a0
ffffffffc02002a0:	dd65                	beqz	a0,ffffffffc0200298 <kmonitor+0x6a>
ffffffffc02002a2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a8:	c999                	beqz	a1,ffffffffc02002be <kmonitor+0x90>
ffffffffc02002aa:	854a                	mv	a0,s2
ffffffffc02002ac:	5ab030ef          	jal	ra,ffffffffc0204056 <strchr>
ffffffffc02002b0:	c925                	beqz	a0,ffffffffc0200320 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b2:	00144583          	lbu	a1,1(s0)
ffffffffc02002b6:	00040023          	sb	zero,0(s0)
ffffffffc02002ba:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002bc:	f5fd                	bnez	a1,ffffffffc02002aa <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002be:	dce9                	beqz	s1,ffffffffc0200298 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c0:	6582                	ld	a1,0(sp)
ffffffffc02002c2:	00004d17          	auipc	s10,0x4
ffffffffc02002c6:	f06d0d13          	addi	s10,s10,-250 # ffffffffc02041c8 <commands>
    if (argc == 0) {
ffffffffc02002ca:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
ffffffffc02002d0:	55d030ef          	jal	ra,ffffffffc020402c <strcmp>
ffffffffc02002d4:	c919                	beqz	a0,ffffffffc02002ea <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d6:	2405                	addiw	s0,s0,1
ffffffffc02002d8:	09740463          	beq	s0,s7,ffffffffc0200360 <kmonitor+0x132>
ffffffffc02002dc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e0:	6582                	ld	a1,0(sp)
ffffffffc02002e2:	0d61                	addi	s10,s10,24
ffffffffc02002e4:	549030ef          	jal	ra,ffffffffc020402c <strcmp>
ffffffffc02002e8:	f57d                	bnez	a0,ffffffffc02002d6 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ea:	00141793          	slli	a5,s0,0x1
ffffffffc02002ee:	97a2                	add	a5,a5,s0
ffffffffc02002f0:	078e                	slli	a5,a5,0x3
ffffffffc02002f2:	97e6                	add	a5,a5,s9
ffffffffc02002f4:	6b9c                	ld	a5,16(a5)
ffffffffc02002f6:	8662                	mv	a2,s8
ffffffffc02002f8:	002c                	addi	a1,sp,8
ffffffffc02002fa:	fff4851b          	addiw	a0,s1,-1
ffffffffc02002fe:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200300:	f8055ce3          	bgez	a0,ffffffffc0200298 <kmonitor+0x6a>
}
ffffffffc0200304:	60ee                	ld	ra,216(sp)
ffffffffc0200306:	644e                	ld	s0,208(sp)
ffffffffc0200308:	64ae                	ld	s1,200(sp)
ffffffffc020030a:	690e                	ld	s2,192(sp)
ffffffffc020030c:	79ea                	ld	s3,184(sp)
ffffffffc020030e:	7a4a                	ld	s4,176(sp)
ffffffffc0200310:	7aaa                	ld	s5,168(sp)
ffffffffc0200312:	7b0a                	ld	s6,160(sp)
ffffffffc0200314:	6bea                	ld	s7,152(sp)
ffffffffc0200316:	6c4a                	ld	s8,144(sp)
ffffffffc0200318:	6caa                	ld	s9,136(sp)
ffffffffc020031a:	6d0a                	ld	s10,128(sp)
ffffffffc020031c:	612d                	addi	sp,sp,224
ffffffffc020031e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200320:	00044783          	lbu	a5,0(s0)
ffffffffc0200324:	dfc9                	beqz	a5,ffffffffc02002be <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200326:	03448863          	beq	s1,s4,ffffffffc0200356 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032a:	00349793          	slli	a5,s1,0x3
ffffffffc020032e:	0118                	addi	a4,sp,128
ffffffffc0200330:	97ba                	add	a5,a5,a4
ffffffffc0200332:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200336:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033c:	e591                	bnez	a1,ffffffffc0200348 <kmonitor+0x11a>
ffffffffc020033e:	b749                	j	ffffffffc02002c0 <kmonitor+0x92>
            buf ++;
ffffffffc0200340:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200342:	00044583          	lbu	a1,0(s0)
ffffffffc0200346:	ddad                	beqz	a1,ffffffffc02002c0 <kmonitor+0x92>
ffffffffc0200348:	854a                	mv	a0,s2
ffffffffc020034a:	50d030ef          	jal	ra,ffffffffc0204056 <strchr>
ffffffffc020034e:	d96d                	beqz	a0,ffffffffc0200340 <kmonitor+0x112>
ffffffffc0200350:	00044583          	lbu	a1,0(s0)
ffffffffc0200354:	bf91                	j	ffffffffc02002a8 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	45c1                	li	a1,16
ffffffffc0200358:	855a                	mv	a0,s6
ffffffffc020035a:	d65ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020035e:	b7f1                	j	ffffffffc020032a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200360:	6582                	ld	a1,0(sp)
ffffffffc0200362:	00004517          	auipc	a0,0x4
ffffffffc0200366:	f2650513          	addi	a0,a0,-218 # ffffffffc0204288 <commands+0xc0>
ffffffffc020036a:	d55ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc020036e:	b72d                	j	ffffffffc0200298 <kmonitor+0x6a>

ffffffffc0200370 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200370:	00010317          	auipc	t1,0x10
ffffffffc0200374:	0d030313          	addi	t1,t1,208 # ffffffffc0210440 <is_panic>
ffffffffc0200378:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020037c:	715d                	addi	sp,sp,-80
ffffffffc020037e:	ec06                	sd	ra,24(sp)
ffffffffc0200380:	e822                	sd	s0,16(sp)
ffffffffc0200382:	f436                	sd	a3,40(sp)
ffffffffc0200384:	f83a                	sd	a4,48(sp)
ffffffffc0200386:	fc3e                	sd	a5,56(sp)
ffffffffc0200388:	e0c2                	sd	a6,64(sp)
ffffffffc020038a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020038c:	02031c63          	bnez	t1,ffffffffc02003c4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200390:	4785                	li	a5,1
ffffffffc0200392:	8432                	mv	s0,a2
ffffffffc0200394:	00010717          	auipc	a4,0x10
ffffffffc0200398:	0af72623          	sw	a5,172(a4) # ffffffffc0210440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020039e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	f9e50513          	addi	a0,a0,-98 # ffffffffc0204340 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	cebff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	f0050513          	addi	a0,a0,-256 # ffffffffc02052b8 <default_pmm_manager+0x4e8>
ffffffffc02003c0:	cffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	10a000ef          	jal	ra,ffffffffc02004ce <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e65ff0ef          	jal	ra,ffffffffc020022e <kmonitor>
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x58>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003d6:	00010717          	auipc	a4,0x10
ffffffffc02003da:	06f73923          	sd	a5,114(a4) # ffffffffc0210448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	f6a50513          	addi	a0,a0,-150 # ffffffffc0204360 <commands+0x198>
    ticks = 0;
ffffffffc02003fe:	00010797          	auipc	a5,0x10
ffffffffc0200402:	0607b923          	sd	zero,114(a5) # ffffffffc0210470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b965                	j	ffffffffc02000be <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00010797          	auipc	a5,0x10
ffffffffc0200410:	03c78793          	addi	a5,a5,60 # ffffffffc0210448 <timebase>
ffffffffc0200414:	639c                	ld	a5,0(a5)
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	953e                	add	a0,a0,a5
ffffffffc020041c:	4881                	li	a7,0
ffffffffc020041e:	00000073          	ecall
ffffffffc0200422:	8082                	ret

ffffffffc0200424 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200424:	100027f3          	csrr	a5,sstatus
ffffffffc0200428:	8b89                	andi	a5,a5,2
ffffffffc020042a:	0ff57513          	andi	a0,a0,255
ffffffffc020042e:	e799                	bnez	a5,ffffffffc020043c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200430:	4581                	li	a1,0
ffffffffc0200432:	4601                	li	a2,0
ffffffffc0200434:	4885                	li	a7,1
ffffffffc0200436:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020043a:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043c:	1101                	addi	sp,sp,-32
ffffffffc020043e:	ec06                	sd	ra,24(sp)
ffffffffc0200440:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200442:	08c000ef          	jal	ra,ffffffffc02004ce <intr_disable>
ffffffffc0200446:	6522                	ld	a0,8(sp)
ffffffffc0200448:	4581                	li	a1,0
ffffffffc020044a:	4601                	li	a2,0
ffffffffc020044c:	4885                	li	a7,1
ffffffffc020044e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200452:	60e2                	ld	ra,24(sp)
ffffffffc0200454:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200456:	a88d                	j	ffffffffc02004c8 <intr_enable>

ffffffffc0200458 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200458:	100027f3          	csrr	a5,sstatus
ffffffffc020045c:	8b89                	andi	a5,a5,2
ffffffffc020045e:	eb89                	bnez	a5,ffffffffc0200470 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200460:	4501                	li	a0,0
ffffffffc0200462:	4581                	li	a1,0
ffffffffc0200464:	4601                	li	a2,0
ffffffffc0200466:	4889                	li	a7,2
ffffffffc0200468:	00000073          	ecall
ffffffffc020046c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046e:	8082                	ret
int cons_getc(void) {
ffffffffc0200470:	1101                	addi	sp,sp,-32
ffffffffc0200472:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200474:	05a000ef          	jal	ra,ffffffffc02004ce <intr_disable>
ffffffffc0200478:	4501                	li	a0,0
ffffffffc020047a:	4581                	li	a1,0
ffffffffc020047c:	4601                	li	a2,0
ffffffffc020047e:	4889                	li	a7,2
ffffffffc0200480:	00000073          	ecall
ffffffffc0200484:	2501                	sext.w	a0,a0
ffffffffc0200486:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200488:	040000ef          	jal	ra,ffffffffc02004c8 <intr_enable>
}
ffffffffc020048c:	60e2                	ld	ra,24(sp)
ffffffffc020048e:	6522                	ld	a0,8(sp)
ffffffffc0200490:	6105                	addi	sp,sp,32
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200494:	8082                	ret

ffffffffc0200496 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200496:	00253513          	sltiu	a0,a0,2
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049c:	03800513          	li	a0,56
ffffffffc02004a0:	8082                	ret

ffffffffc02004a2 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004a2:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004a4:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004a8:	00009517          	auipc	a0,0x9
ffffffffc02004ac:	b9850513          	addi	a0,a0,-1128 # ffffffffc0209040 <edata>
                   size_t nsecs) {
ffffffffc02004b0:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
ffffffffc02004b6:	85ba                	mv	a1,a4
ffffffffc02004b8:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004ba:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004bc:	3cb030ef          	jal	ra,ffffffffc0204086 <memcpy>
    return 0;
}
ffffffffc02004c0:	60a2                	ld	ra,8(sp)
ffffffffc02004c2:	4501                	li	a0,0
ffffffffc02004c4:	0141                	addi	sp,sp,16
ffffffffc02004c6:	8082                	ret

ffffffffc02004c8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004c8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ce:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004d2:	8082                	ret

ffffffffc02004d4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004d4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004d8:	1141                	addi	sp,sp,-16
ffffffffc02004da:	e022                	sd	s0,0(sp)
ffffffffc02004dc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004de:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e2:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004e4:	11053583          	ld	a1,272(a0)
ffffffffc02004e8:	05500613          	li	a2,85
ffffffffc02004ec:	c399                	beqz	a5,ffffffffc02004f2 <pgfault_handler+0x1e>
ffffffffc02004ee:	04b00613          	li	a2,75
ffffffffc02004f2:	11843703          	ld	a4,280(s0)
ffffffffc02004f6:	47bd                	li	a5,15
ffffffffc02004f8:	05700693          	li	a3,87
ffffffffc02004fc:	00f70463          	beq	a4,a5,ffffffffc0200504 <pgfault_handler+0x30>
ffffffffc0200500:	05200693          	li	a3,82
ffffffffc0200504:	00004517          	auipc	a0,0x4
ffffffffc0200508:	15450513          	addi	a0,a0,340 # ffffffffc0204658 <commands+0x490>
ffffffffc020050c:	bb3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200510:	00010797          	auipc	a5,0x10
ffffffffc0200514:	08078793          	addi	a5,a5,128 # ffffffffc0210590 <check_mm_struct>
ffffffffc0200518:	6388                	ld	a0,0(a5)
ffffffffc020051a:	c911                	beqz	a0,ffffffffc020052e <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020051c:	11043603          	ld	a2,272(s0)
ffffffffc0200520:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200524:	6402                	ld	s0,0(sp)
ffffffffc0200526:	60a2                	ld	ra,8(sp)
ffffffffc0200528:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020052a:	4740306f          	j	ffffffffc020399e <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020052e:	00004617          	auipc	a2,0x4
ffffffffc0200532:	14a60613          	addi	a2,a2,330 # ffffffffc0204678 <commands+0x4b0>
ffffffffc0200536:	07800593          	li	a1,120
ffffffffc020053a:	00004517          	auipc	a0,0x4
ffffffffc020053e:	15650513          	addi	a0,a0,342 # ffffffffc0204690 <commands+0x4c8>
ffffffffc0200542:	e2fff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0200546 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200546:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020054a:	00000797          	auipc	a5,0x0
ffffffffc020054e:	48678793          	addi	a5,a5,1158 # ffffffffc02009d0 <__alltraps>
ffffffffc0200552:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200556:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020055a:	000407b7          	lui	a5,0x40
ffffffffc020055e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200564:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200566:	1141                	addi	sp,sp,-16
ffffffffc0200568:	e022                	sd	s0,0(sp)
ffffffffc020056a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020056c:	00004517          	auipc	a0,0x4
ffffffffc0200570:	13c50513          	addi	a0,a0,316 # ffffffffc02046a8 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc0200574:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200576:	b49ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020057a:	640c                	ld	a1,8(s0)
ffffffffc020057c:	00004517          	auipc	a0,0x4
ffffffffc0200580:	14450513          	addi	a0,a0,324 # ffffffffc02046c0 <commands+0x4f8>
ffffffffc0200584:	b3bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200588:	680c                	ld	a1,16(s0)
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	14e50513          	addi	a0,a0,334 # ffffffffc02046d8 <commands+0x510>
ffffffffc0200592:	b2dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200596:	6c0c                	ld	a1,24(s0)
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	15850513          	addi	a0,a0,344 # ffffffffc02046f0 <commands+0x528>
ffffffffc02005a0:	b1fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005a4:	700c                	ld	a1,32(s0)
ffffffffc02005a6:	00004517          	auipc	a0,0x4
ffffffffc02005aa:	16250513          	addi	a0,a0,354 # ffffffffc0204708 <commands+0x540>
ffffffffc02005ae:	b11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005b2:	740c                	ld	a1,40(s0)
ffffffffc02005b4:	00004517          	auipc	a0,0x4
ffffffffc02005b8:	16c50513          	addi	a0,a0,364 # ffffffffc0204720 <commands+0x558>
ffffffffc02005bc:	b03ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005c0:	780c                	ld	a1,48(s0)
ffffffffc02005c2:	00004517          	auipc	a0,0x4
ffffffffc02005c6:	17650513          	addi	a0,a0,374 # ffffffffc0204738 <commands+0x570>
ffffffffc02005ca:	af5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ce:	7c0c                	ld	a1,56(s0)
ffffffffc02005d0:	00004517          	auipc	a0,0x4
ffffffffc02005d4:	18050513          	addi	a0,a0,384 # ffffffffc0204750 <commands+0x588>
ffffffffc02005d8:	ae7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005dc:	602c                	ld	a1,64(s0)
ffffffffc02005de:	00004517          	auipc	a0,0x4
ffffffffc02005e2:	18a50513          	addi	a0,a0,394 # ffffffffc0204768 <commands+0x5a0>
ffffffffc02005e6:	ad9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005ea:	642c                	ld	a1,72(s0)
ffffffffc02005ec:	00004517          	auipc	a0,0x4
ffffffffc02005f0:	19450513          	addi	a0,a0,404 # ffffffffc0204780 <commands+0x5b8>
ffffffffc02005f4:	acbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02005f8:	682c                	ld	a1,80(s0)
ffffffffc02005fa:	00004517          	auipc	a0,0x4
ffffffffc02005fe:	19e50513          	addi	a0,a0,414 # ffffffffc0204798 <commands+0x5d0>
ffffffffc0200602:	abdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200606:	6c2c                	ld	a1,88(s0)
ffffffffc0200608:	00004517          	auipc	a0,0x4
ffffffffc020060c:	1a850513          	addi	a0,a0,424 # ffffffffc02047b0 <commands+0x5e8>
ffffffffc0200610:	aafff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200614:	702c                	ld	a1,96(s0)
ffffffffc0200616:	00004517          	auipc	a0,0x4
ffffffffc020061a:	1b250513          	addi	a0,a0,434 # ffffffffc02047c8 <commands+0x600>
ffffffffc020061e:	aa1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200622:	742c                	ld	a1,104(s0)
ffffffffc0200624:	00004517          	auipc	a0,0x4
ffffffffc0200628:	1bc50513          	addi	a0,a0,444 # ffffffffc02047e0 <commands+0x618>
ffffffffc020062c:	a93ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200630:	782c                	ld	a1,112(s0)
ffffffffc0200632:	00004517          	auipc	a0,0x4
ffffffffc0200636:	1c650513          	addi	a0,a0,454 # ffffffffc02047f8 <commands+0x630>
ffffffffc020063a:	a85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020063e:	7c2c                	ld	a1,120(s0)
ffffffffc0200640:	00004517          	auipc	a0,0x4
ffffffffc0200644:	1d050513          	addi	a0,a0,464 # ffffffffc0204810 <commands+0x648>
ffffffffc0200648:	a77ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020064c:	604c                	ld	a1,128(s0)
ffffffffc020064e:	00004517          	auipc	a0,0x4
ffffffffc0200652:	1da50513          	addi	a0,a0,474 # ffffffffc0204828 <commands+0x660>
ffffffffc0200656:	a69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020065a:	644c                	ld	a1,136(s0)
ffffffffc020065c:	00004517          	auipc	a0,0x4
ffffffffc0200660:	1e450513          	addi	a0,a0,484 # ffffffffc0204840 <commands+0x678>
ffffffffc0200664:	a5bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200668:	684c                	ld	a1,144(s0)
ffffffffc020066a:	00004517          	auipc	a0,0x4
ffffffffc020066e:	1ee50513          	addi	a0,a0,494 # ffffffffc0204858 <commands+0x690>
ffffffffc0200672:	a4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200676:	6c4c                	ld	a1,152(s0)
ffffffffc0200678:	00004517          	auipc	a0,0x4
ffffffffc020067c:	1f850513          	addi	a0,a0,504 # ffffffffc0204870 <commands+0x6a8>
ffffffffc0200680:	a3fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200684:	704c                	ld	a1,160(s0)
ffffffffc0200686:	00004517          	auipc	a0,0x4
ffffffffc020068a:	20250513          	addi	a0,a0,514 # ffffffffc0204888 <commands+0x6c0>
ffffffffc020068e:	a31ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200692:	744c                	ld	a1,168(s0)
ffffffffc0200694:	00004517          	auipc	a0,0x4
ffffffffc0200698:	20c50513          	addi	a0,a0,524 # ffffffffc02048a0 <commands+0x6d8>
ffffffffc020069c:	a23ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006a0:	784c                	ld	a1,176(s0)
ffffffffc02006a2:	00004517          	auipc	a0,0x4
ffffffffc02006a6:	21650513          	addi	a0,a0,534 # ffffffffc02048b8 <commands+0x6f0>
ffffffffc02006aa:	a15ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006ae:	7c4c                	ld	a1,184(s0)
ffffffffc02006b0:	00004517          	auipc	a0,0x4
ffffffffc02006b4:	22050513          	addi	a0,a0,544 # ffffffffc02048d0 <commands+0x708>
ffffffffc02006b8:	a07ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006bc:	606c                	ld	a1,192(s0)
ffffffffc02006be:	00004517          	auipc	a0,0x4
ffffffffc02006c2:	22a50513          	addi	a0,a0,554 # ffffffffc02048e8 <commands+0x720>
ffffffffc02006c6:	9f9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006ca:	646c                	ld	a1,200(s0)
ffffffffc02006cc:	00004517          	auipc	a0,0x4
ffffffffc02006d0:	23450513          	addi	a0,a0,564 # ffffffffc0204900 <commands+0x738>
ffffffffc02006d4:	9ebff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006d8:	686c                	ld	a1,208(s0)
ffffffffc02006da:	00004517          	auipc	a0,0x4
ffffffffc02006de:	23e50513          	addi	a0,a0,574 # ffffffffc0204918 <commands+0x750>
ffffffffc02006e2:	9ddff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006e6:	6c6c                	ld	a1,216(s0)
ffffffffc02006e8:	00004517          	auipc	a0,0x4
ffffffffc02006ec:	24850513          	addi	a0,a0,584 # ffffffffc0204930 <commands+0x768>
ffffffffc02006f0:	9cfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006f4:	706c                	ld	a1,224(s0)
ffffffffc02006f6:	00004517          	auipc	a0,0x4
ffffffffc02006fa:	25250513          	addi	a0,a0,594 # ffffffffc0204948 <commands+0x780>
ffffffffc02006fe:	9c1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200702:	746c                	ld	a1,232(s0)
ffffffffc0200704:	00004517          	auipc	a0,0x4
ffffffffc0200708:	25c50513          	addi	a0,a0,604 # ffffffffc0204960 <commands+0x798>
ffffffffc020070c:	9b3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200710:	786c                	ld	a1,240(s0)
ffffffffc0200712:	00004517          	auipc	a0,0x4
ffffffffc0200716:	26650513          	addi	a0,a0,614 # ffffffffc0204978 <commands+0x7b0>
ffffffffc020071a:	9a5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020071e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200720:	6402                	ld	s0,0(sp)
ffffffffc0200722:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200724:	00004517          	auipc	a0,0x4
ffffffffc0200728:	26c50513          	addi	a0,a0,620 # ffffffffc0204990 <commands+0x7c8>
}
ffffffffc020072c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020072e:	ba41                	j	ffffffffc02000be <cprintf>

ffffffffc0200730 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200730:	1141                	addi	sp,sp,-16
ffffffffc0200732:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200734:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200736:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200738:	00004517          	auipc	a0,0x4
ffffffffc020073c:	27050513          	addi	a0,a0,624 # ffffffffc02049a8 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200740:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200742:	97dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200746:	8522                	mv	a0,s0
ffffffffc0200748:	e1dff0ef          	jal	ra,ffffffffc0200564 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020074c:	10043583          	ld	a1,256(s0)
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	27050513          	addi	a0,a0,624 # ffffffffc02049c0 <commands+0x7f8>
ffffffffc0200758:	967ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020075c:	10843583          	ld	a1,264(s0)
ffffffffc0200760:	00004517          	auipc	a0,0x4
ffffffffc0200764:	27850513          	addi	a0,a0,632 # ffffffffc02049d8 <commands+0x810>
ffffffffc0200768:	957ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020076c:	11043583          	ld	a1,272(s0)
ffffffffc0200770:	00004517          	auipc	a0,0x4
ffffffffc0200774:	28050513          	addi	a0,a0,640 # ffffffffc02049f0 <commands+0x828>
ffffffffc0200778:	947ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020077c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200780:	6402                	ld	s0,0(sp)
ffffffffc0200782:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	28450513          	addi	a0,a0,644 # ffffffffc0204a08 <commands+0x840>
}
ffffffffc020078c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020078e:	931ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200792 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200792:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200796:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200798:	0786                	slli	a5,a5,0x1
ffffffffc020079a:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020079c:	06f76f63          	bltu	a4,a5,ffffffffc020081a <interrupt_handler+0x88>
ffffffffc02007a0:	00004717          	auipc	a4,0x4
ffffffffc02007a4:	bdc70713          	addi	a4,a4,-1060 # ffffffffc020437c <commands+0x1b4>
ffffffffc02007a8:	078a                	slli	a5,a5,0x2
ffffffffc02007aa:	97ba                	add	a5,a5,a4
ffffffffc02007ac:	439c                	lw	a5,0(a5)
ffffffffc02007ae:	97ba                	add	a5,a5,a4
ffffffffc02007b0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	e5650513          	addi	a0,a0,-426 # ffffffffc0204608 <commands+0x440>
ffffffffc02007ba:	905ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	e2a50513          	addi	a0,a0,-470 # ffffffffc02045e8 <commands+0x420>
ffffffffc02007c6:	8f9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	dde50513          	addi	a0,a0,-546 # ffffffffc02045a8 <commands+0x3e0>
ffffffffc02007d2:	8edff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	df250513          	addi	a0,a0,-526 # ffffffffc02045c8 <commands+0x400>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	e5650513          	addi	a0,a0,-426 # ffffffffc0204638 <commands+0x470>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007ee:	1141                	addi	sp,sp,-16
ffffffffc02007f0:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02007f2:	c17ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007f6:	00010797          	auipc	a5,0x10
ffffffffc02007fa:	c7a78793          	addi	a5,a5,-902 # ffffffffc0210470 <ticks>
ffffffffc02007fe:	639c                	ld	a5,0(a5)
ffffffffc0200800:	06400713          	li	a4,100
ffffffffc0200804:	0785                	addi	a5,a5,1
ffffffffc0200806:	02e7f733          	remu	a4,a5,a4
ffffffffc020080a:	00010697          	auipc	a3,0x10
ffffffffc020080e:	c6f6b323          	sd	a5,-922(a3) # ffffffffc0210470 <ticks>
ffffffffc0200812:	c709                	beqz	a4,ffffffffc020081c <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200814:	60a2                	ld	ra,8(sp)
ffffffffc0200816:	0141                	addi	sp,sp,16
ffffffffc0200818:	8082                	ret
            print_trapframe(tf);
ffffffffc020081a:	bf19                	j	ffffffffc0200730 <print_trapframe>
}
ffffffffc020081c:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020081e:	06400593          	li	a1,100
ffffffffc0200822:	00004517          	auipc	a0,0x4
ffffffffc0200826:	e0650513          	addi	a0,a0,-506 # ffffffffc0204628 <commands+0x460>
}
ffffffffc020082a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020082c:	893ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200830 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200830:	11853783          	ld	a5,280(a0)
ffffffffc0200834:	473d                	li	a4,15
ffffffffc0200836:	16f76463          	bltu	a4,a5,ffffffffc020099e <exception_handler+0x16e>
ffffffffc020083a:	00004717          	auipc	a4,0x4
ffffffffc020083e:	b7270713          	addi	a4,a4,-1166 # ffffffffc02043ac <commands+0x1e4>
ffffffffc0200842:	078a                	slli	a5,a5,0x2
ffffffffc0200844:	97ba                	add	a5,a5,a4
ffffffffc0200846:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200848:	1101                	addi	sp,sp,-32
ffffffffc020084a:	e822                	sd	s0,16(sp)
ffffffffc020084c:	ec06                	sd	ra,24(sp)
ffffffffc020084e:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200850:	97ba                	add	a5,a5,a4
ffffffffc0200852:	842a                	mv	s0,a0
ffffffffc0200854:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200856:	00004517          	auipc	a0,0x4
ffffffffc020085a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204590 <commands+0x3c8>
ffffffffc020085e:	861ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200862:	8522                	mv	a0,s0
ffffffffc0200864:	c71ff0ef          	jal	ra,ffffffffc02004d4 <pgfault_handler>
ffffffffc0200868:	84aa                	mv	s1,a0
ffffffffc020086a:	12051b63          	bnez	a0,ffffffffc02009a0 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020086e:	60e2                	ld	ra,24(sp)
ffffffffc0200870:	6442                	ld	s0,16(sp)
ffffffffc0200872:	64a2                	ld	s1,8(sp)
ffffffffc0200874:	6105                	addi	sp,sp,32
ffffffffc0200876:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200878:	00004517          	auipc	a0,0x4
ffffffffc020087c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02043f0 <commands+0x228>
}
ffffffffc0200880:	6442                	ld	s0,16(sp)
ffffffffc0200882:	60e2                	ld	ra,24(sp)
ffffffffc0200884:	64a2                	ld	s1,8(sp)
ffffffffc0200886:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200888:	837ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc020088c:	00004517          	auipc	a0,0x4
ffffffffc0200890:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204410 <commands+0x248>
ffffffffc0200894:	b7f5                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200896:	00004517          	auipc	a0,0x4
ffffffffc020089a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204430 <commands+0x268>
ffffffffc020089e:	b7cd                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008a0:	00004517          	auipc	a0,0x4
ffffffffc02008a4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0204448 <commands+0x280>
ffffffffc02008a8:	bfe1                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	bae50513          	addi	a0,a0,-1106 # ffffffffc0204458 <commands+0x290>
ffffffffc02008b2:	b7f9                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008b4:	00004517          	auipc	a0,0x4
ffffffffc02008b8:	bc450513          	addi	a0,a0,-1084 # ffffffffc0204478 <commands+0x2b0>
ffffffffc02008bc:	803ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c0:	8522                	mv	a0,s0
ffffffffc02008c2:	c13ff0ef          	jal	ra,ffffffffc02004d4 <pgfault_handler>
ffffffffc02008c6:	84aa                	mv	s1,a0
ffffffffc02008c8:	d15d                	beqz	a0,ffffffffc020086e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008ca:	8522                	mv	a0,s0
ffffffffc02008cc:	e65ff0ef          	jal	ra,ffffffffc0200730 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008d0:	86a6                	mv	a3,s1
ffffffffc02008d2:	00004617          	auipc	a2,0x4
ffffffffc02008d6:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0204490 <commands+0x2c8>
ffffffffc02008da:	0ca00593          	li	a1,202
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	db250513          	addi	a0,a0,-590 # ffffffffc0204690 <commands+0x4c8>
ffffffffc02008e6:	a8bff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	bc650513          	addi	a0,a0,-1082 # ffffffffc02044b0 <commands+0x2e8>
ffffffffc02008f2:	b779                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	bd450513          	addi	a0,a0,-1068 # ffffffffc02044c8 <commands+0x300>
ffffffffc02008fc:	fc2ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200900:	8522                	mv	a0,s0
ffffffffc0200902:	bd3ff0ef          	jal	ra,ffffffffc02004d4 <pgfault_handler>
ffffffffc0200906:	84aa                	mv	s1,a0
ffffffffc0200908:	d13d                	beqz	a0,ffffffffc020086e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020090a:	8522                	mv	a0,s0
ffffffffc020090c:	e25ff0ef          	jal	ra,ffffffffc0200730 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200910:	86a6                	mv	a3,s1
ffffffffc0200912:	00004617          	auipc	a2,0x4
ffffffffc0200916:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204490 <commands+0x2c8>
ffffffffc020091a:	0d400593          	li	a1,212
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	d7250513          	addi	a0,a0,-654 # ffffffffc0204690 <commands+0x4c8>
ffffffffc0200926:	a4bff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020092a:	00004517          	auipc	a0,0x4
ffffffffc020092e:	bb650513          	addi	a0,a0,-1098 # ffffffffc02044e0 <commands+0x318>
ffffffffc0200932:	b7b9                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200934:	00004517          	auipc	a0,0x4
ffffffffc0200938:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0204500 <commands+0x338>
ffffffffc020093c:	b791                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020093e:	00004517          	auipc	a0,0x4
ffffffffc0200942:	be250513          	addi	a0,a0,-1054 # ffffffffc0204520 <commands+0x358>
ffffffffc0200946:	bf2d                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200948:	00004517          	auipc	a0,0x4
ffffffffc020094c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204540 <commands+0x378>
ffffffffc0200950:	bf05                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200952:	00004517          	auipc	a0,0x4
ffffffffc0200956:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0204560 <commands+0x398>
ffffffffc020095a:	b71d                	j	ffffffffc0200880 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204578 <commands+0x3b0>
ffffffffc0200964:	f5aff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200968:	8522                	mv	a0,s0
ffffffffc020096a:	b6bff0ef          	jal	ra,ffffffffc02004d4 <pgfault_handler>
ffffffffc020096e:	84aa                	mv	s1,a0
ffffffffc0200970:	ee050fe3          	beqz	a0,ffffffffc020086e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200974:	8522                	mv	a0,s0
ffffffffc0200976:	dbbff0ef          	jal	ra,ffffffffc0200730 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020097a:	86a6                	mv	a3,s1
ffffffffc020097c:	00004617          	auipc	a2,0x4
ffffffffc0200980:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204490 <commands+0x2c8>
ffffffffc0200984:	0ea00593          	li	a1,234
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	d0850513          	addi	a0,a0,-760 # ffffffffc0204690 <commands+0x4c8>
ffffffffc0200990:	9e1ff0ef          	jal	ra,ffffffffc0200370 <__panic>
}
ffffffffc0200994:	6442                	ld	s0,16(sp)
ffffffffc0200996:	60e2                	ld	ra,24(sp)
ffffffffc0200998:	64a2                	ld	s1,8(sp)
ffffffffc020099a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc020099c:	bb51                	j	ffffffffc0200730 <print_trapframe>
ffffffffc020099e:	bb49                	j	ffffffffc0200730 <print_trapframe>
                print_trapframe(tf);
ffffffffc02009a0:	8522                	mv	a0,s0
ffffffffc02009a2:	d8fff0ef          	jal	ra,ffffffffc0200730 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009a6:	86a6                	mv	a3,s1
ffffffffc02009a8:	00004617          	auipc	a2,0x4
ffffffffc02009ac:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204490 <commands+0x2c8>
ffffffffc02009b0:	0f100593          	li	a1,241
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204690 <commands+0x4c8>
ffffffffc02009bc:	9b5ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02009c0 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009c0:	11853783          	ld	a5,280(a0)
ffffffffc02009c4:	0007c363          	bltz	a5,ffffffffc02009ca <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009c8:	b5a5                	j	ffffffffc0200830 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009ca:	b3e1                	j	ffffffffc0200792 <interrupt_handler>
ffffffffc02009cc:	0000                	unimp
	...

ffffffffc02009d0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009d0:	14011073          	csrw	sscratch,sp
ffffffffc02009d4:	712d                	addi	sp,sp,-288
ffffffffc02009d6:	e406                	sd	ra,8(sp)
ffffffffc02009d8:	ec0e                	sd	gp,24(sp)
ffffffffc02009da:	f012                	sd	tp,32(sp)
ffffffffc02009dc:	f416                	sd	t0,40(sp)
ffffffffc02009de:	f81a                	sd	t1,48(sp)
ffffffffc02009e0:	fc1e                	sd	t2,56(sp)
ffffffffc02009e2:	e0a2                	sd	s0,64(sp)
ffffffffc02009e4:	e4a6                	sd	s1,72(sp)
ffffffffc02009e6:	e8aa                	sd	a0,80(sp)
ffffffffc02009e8:	ecae                	sd	a1,88(sp)
ffffffffc02009ea:	f0b2                	sd	a2,96(sp)
ffffffffc02009ec:	f4b6                	sd	a3,104(sp)
ffffffffc02009ee:	f8ba                	sd	a4,112(sp)
ffffffffc02009f0:	fcbe                	sd	a5,120(sp)
ffffffffc02009f2:	e142                	sd	a6,128(sp)
ffffffffc02009f4:	e546                	sd	a7,136(sp)
ffffffffc02009f6:	e94a                	sd	s2,144(sp)
ffffffffc02009f8:	ed4e                	sd	s3,152(sp)
ffffffffc02009fa:	f152                	sd	s4,160(sp)
ffffffffc02009fc:	f556                	sd	s5,168(sp)
ffffffffc02009fe:	f95a                	sd	s6,176(sp)
ffffffffc0200a00:	fd5e                	sd	s7,184(sp)
ffffffffc0200a02:	e1e2                	sd	s8,192(sp)
ffffffffc0200a04:	e5e6                	sd	s9,200(sp)
ffffffffc0200a06:	e9ea                	sd	s10,208(sp)
ffffffffc0200a08:	edee                	sd	s11,216(sp)
ffffffffc0200a0a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a0c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a0e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a10:	fdfe                	sd	t6,248(sp)
ffffffffc0200a12:	14002473          	csrr	s0,sscratch
ffffffffc0200a16:	100024f3          	csrr	s1,sstatus
ffffffffc0200a1a:	14102973          	csrr	s2,sepc
ffffffffc0200a1e:	143029f3          	csrr	s3,stval
ffffffffc0200a22:	14202a73          	csrr	s4,scause
ffffffffc0200a26:	e822                	sd	s0,16(sp)
ffffffffc0200a28:	e226                	sd	s1,256(sp)
ffffffffc0200a2a:	e64a                	sd	s2,264(sp)
ffffffffc0200a2c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a2e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a30:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a32:	f8fff0ef          	jal	ra,ffffffffc02009c0 <trap>

ffffffffc0200a36 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a36:	6492                	ld	s1,256(sp)
ffffffffc0200a38:	6932                	ld	s2,264(sp)
ffffffffc0200a3a:	10049073          	csrw	sstatus,s1
ffffffffc0200a3e:	14191073          	csrw	sepc,s2
ffffffffc0200a42:	60a2                	ld	ra,8(sp)
ffffffffc0200a44:	61e2                	ld	gp,24(sp)
ffffffffc0200a46:	7202                	ld	tp,32(sp)
ffffffffc0200a48:	72a2                	ld	t0,40(sp)
ffffffffc0200a4a:	7342                	ld	t1,48(sp)
ffffffffc0200a4c:	73e2                	ld	t2,56(sp)
ffffffffc0200a4e:	6406                	ld	s0,64(sp)
ffffffffc0200a50:	64a6                	ld	s1,72(sp)
ffffffffc0200a52:	6546                	ld	a0,80(sp)
ffffffffc0200a54:	65e6                	ld	a1,88(sp)
ffffffffc0200a56:	7606                	ld	a2,96(sp)
ffffffffc0200a58:	76a6                	ld	a3,104(sp)
ffffffffc0200a5a:	7746                	ld	a4,112(sp)
ffffffffc0200a5c:	77e6                	ld	a5,120(sp)
ffffffffc0200a5e:	680a                	ld	a6,128(sp)
ffffffffc0200a60:	68aa                	ld	a7,136(sp)
ffffffffc0200a62:	694a                	ld	s2,144(sp)
ffffffffc0200a64:	69ea                	ld	s3,152(sp)
ffffffffc0200a66:	7a0a                	ld	s4,160(sp)
ffffffffc0200a68:	7aaa                	ld	s5,168(sp)
ffffffffc0200a6a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a6c:	7bea                	ld	s7,184(sp)
ffffffffc0200a6e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a70:	6cae                	ld	s9,200(sp)
ffffffffc0200a72:	6d4e                	ld	s10,208(sp)
ffffffffc0200a74:	6dee                	ld	s11,216(sp)
ffffffffc0200a76:	7e0e                	ld	t3,224(sp)
ffffffffc0200a78:	7eae                	ld	t4,232(sp)
ffffffffc0200a7a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a7c:	7fee                	ld	t6,248(sp)
ffffffffc0200a7e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a80:	10200073          	sret
	...

ffffffffc0200a90 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a90:	00010797          	auipc	a5,0x10
ffffffffc0200a94:	9e878793          	addi	a5,a5,-1560 # ffffffffc0210478 <free_area>
ffffffffc0200a98:	e79c                	sd	a5,8(a5)
ffffffffc0200a9a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a9c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200aa0:	8082                	ret

ffffffffc0200aa2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200aa2:	00010517          	auipc	a0,0x10
ffffffffc0200aa6:	9e656503          	lwu	a0,-1562(a0) # ffffffffc0210488 <free_area+0x10>
ffffffffc0200aaa:	8082                	ret

ffffffffc0200aac <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200aac:	715d                	addi	sp,sp,-80
ffffffffc0200aae:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ab0:	00010917          	auipc	s2,0x10
ffffffffc0200ab4:	9c890913          	addi	s2,s2,-1592 # ffffffffc0210478 <free_area>
ffffffffc0200ab8:	00893783          	ld	a5,8(s2)
ffffffffc0200abc:	e486                	sd	ra,72(sp)
ffffffffc0200abe:	e0a2                	sd	s0,64(sp)
ffffffffc0200ac0:	fc26                	sd	s1,56(sp)
ffffffffc0200ac2:	f44e                	sd	s3,40(sp)
ffffffffc0200ac4:	f052                	sd	s4,32(sp)
ffffffffc0200ac6:	ec56                	sd	s5,24(sp)
ffffffffc0200ac8:	e85a                	sd	s6,16(sp)
ffffffffc0200aca:	e45e                	sd	s7,8(sp)
ffffffffc0200acc:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ace:	31278f63          	beq	a5,s2,ffffffffc0200dec <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ad2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ad6:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ad8:	8b05                	andi	a4,a4,1
ffffffffc0200ada:	30070d63          	beqz	a4,ffffffffc0200df4 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200ade:	4401                	li	s0,0
ffffffffc0200ae0:	4481                	li	s1,0
ffffffffc0200ae2:	a031                	j	ffffffffc0200aee <default_check+0x42>
ffffffffc0200ae4:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200ae8:	8b09                	andi	a4,a4,2
ffffffffc0200aea:	30070563          	beqz	a4,ffffffffc0200df4 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200aee:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200af2:	679c                	ld	a5,8(a5)
ffffffffc0200af4:	2485                	addiw	s1,s1,1
ffffffffc0200af6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200af8:	ff2796e3          	bne	a5,s2,ffffffffc0200ae4 <default_check+0x38>
ffffffffc0200afc:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200afe:	3ef000ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc0200b02:	75351963          	bne	a0,s3,ffffffffc0201254 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b06:	4505                	li	a0,1
ffffffffc0200b08:	317000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200b0c:	8a2a                	mv	s4,a0
ffffffffc0200b0e:	48050363          	beqz	a0,ffffffffc0200f94 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b12:	4505                	li	a0,1
ffffffffc0200b14:	30b000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200b18:	89aa                	mv	s3,a0
ffffffffc0200b1a:	74050d63          	beqz	a0,ffffffffc0201274 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b1e:	4505                	li	a0,1
ffffffffc0200b20:	2ff000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200b24:	8aaa                	mv	s5,a0
ffffffffc0200b26:	4e050763          	beqz	a0,ffffffffc0201014 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b2a:	2f3a0563          	beq	s4,s3,ffffffffc0200e14 <default_check+0x368>
ffffffffc0200b2e:	2eaa0363          	beq	s4,a0,ffffffffc0200e14 <default_check+0x368>
ffffffffc0200b32:	2ea98163          	beq	s3,a0,ffffffffc0200e14 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b36:	000a2783          	lw	a5,0(s4)
ffffffffc0200b3a:	2e079d63          	bnez	a5,ffffffffc0200e34 <default_check+0x388>
ffffffffc0200b3e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b42:	2e079963          	bnez	a5,ffffffffc0200e34 <default_check+0x388>
ffffffffc0200b46:	411c                	lw	a5,0(a0)
ffffffffc0200b48:	2e079663          	bnez	a5,ffffffffc0200e34 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b4c:	00010797          	auipc	a5,0x10
ffffffffc0200b50:	95c78793          	addi	a5,a5,-1700 # ffffffffc02104a8 <pages>
ffffffffc0200b54:	639c                	ld	a5,0(a5)
ffffffffc0200b56:	00004717          	auipc	a4,0x4
ffffffffc0200b5a:	eca70713          	addi	a4,a4,-310 # ffffffffc0204a20 <commands+0x858>
ffffffffc0200b5e:	630c                	ld	a1,0(a4)
ffffffffc0200b60:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b64:	870d                	srai	a4,a4,0x3
ffffffffc0200b66:	02b70733          	mul	a4,a4,a1
ffffffffc0200b6a:	00005697          	auipc	a3,0x5
ffffffffc0200b6e:	2c668693          	addi	a3,a3,710 # ffffffffc0205e30 <nbase>
ffffffffc0200b72:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b74:	00010697          	auipc	a3,0x10
ffffffffc0200b78:	8e468693          	addi	a3,a3,-1820 # ffffffffc0210458 <npage>
ffffffffc0200b7c:	6294                	ld	a3,0(a3)
ffffffffc0200b7e:	06b2                	slli	a3,a3,0xc
ffffffffc0200b80:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b82:	0732                	slli	a4,a4,0xc
ffffffffc0200b84:	2cd77863          	bgeu	a4,a3,ffffffffc0200e54 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b88:	40f98733          	sub	a4,s3,a5
ffffffffc0200b8c:	870d                	srai	a4,a4,0x3
ffffffffc0200b8e:	02b70733          	mul	a4,a4,a1
ffffffffc0200b92:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b94:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b96:	4ed77f63          	bgeu	a4,a3,ffffffffc0201094 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b9e:	878d                	srai	a5,a5,0x3
ffffffffc0200ba0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200ba4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ba6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ba8:	34d7f663          	bgeu	a5,a3,ffffffffc0200ef4 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bae:	00093c03          	ld	s8,0(s2)
ffffffffc0200bb2:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bb6:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200bba:	00010797          	auipc	a5,0x10
ffffffffc0200bbe:	8d27b323          	sd	s2,-1850(a5) # ffffffffc0210480 <free_area+0x8>
ffffffffc0200bc2:	00010797          	auipc	a5,0x10
ffffffffc0200bc6:	8b27bb23          	sd	s2,-1866(a5) # ffffffffc0210478 <free_area>
    nr_free = 0;
ffffffffc0200bca:	00010797          	auipc	a5,0x10
ffffffffc0200bce:	8a07af23          	sw	zero,-1858(a5) # ffffffffc0210488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bd2:	24d000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200bd6:	2e051f63          	bnez	a0,ffffffffc0200ed4 <default_check+0x428>
    free_page(p0);
ffffffffc0200bda:	4585                	li	a1,1
ffffffffc0200bdc:	8552                	mv	a0,s4
ffffffffc0200bde:	2c9000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_page(p1);
ffffffffc0200be2:	4585                	li	a1,1
ffffffffc0200be4:	854e                	mv	a0,s3
ffffffffc0200be6:	2c1000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_page(p2);
ffffffffc0200bea:	4585                	li	a1,1
ffffffffc0200bec:	8556                	mv	a0,s5
ffffffffc0200bee:	2b9000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bf2:	01092703          	lw	a4,16(s2)
ffffffffc0200bf6:	478d                	li	a5,3
ffffffffc0200bf8:	2af71e63          	bne	a4,a5,ffffffffc0200eb4 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bfc:	4505                	li	a0,1
ffffffffc0200bfe:	221000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c02:	89aa                	mv	s3,a0
ffffffffc0200c04:	28050863          	beqz	a0,ffffffffc0200e94 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c08:	4505                	li	a0,1
ffffffffc0200c0a:	215000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c0e:	8aaa                	mv	s5,a0
ffffffffc0200c10:	3e050263          	beqz	a0,ffffffffc0200ff4 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c14:	4505                	li	a0,1
ffffffffc0200c16:	209000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c1a:	8a2a                	mv	s4,a0
ffffffffc0200c1c:	3a050c63          	beqz	a0,ffffffffc0200fd4 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c20:	4505                	li	a0,1
ffffffffc0200c22:	1fd000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c26:	38051763          	bnez	a0,ffffffffc0200fb4 <default_check+0x508>
    free_page(p0);
ffffffffc0200c2a:	4585                	li	a1,1
ffffffffc0200c2c:	854e                	mv	a0,s3
ffffffffc0200c2e:	279000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c32:	00893783          	ld	a5,8(s2)
ffffffffc0200c36:	23278f63          	beq	a5,s2,ffffffffc0200e74 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c3a:	4505                	li	a0,1
ffffffffc0200c3c:	1e3000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c40:	32a99a63          	bne	s3,a0,ffffffffc0200f74 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c44:	4505                	li	a0,1
ffffffffc0200c46:	1d9000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c4a:	30051563          	bnez	a0,ffffffffc0200f54 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c4e:	01092783          	lw	a5,16(s2)
ffffffffc0200c52:	2e079163          	bnez	a5,ffffffffc0200f34 <default_check+0x488>
    free_page(p);
ffffffffc0200c56:	854e                	mv	a0,s3
ffffffffc0200c58:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c5a:	00010797          	auipc	a5,0x10
ffffffffc0200c5e:	8187bf23          	sd	s8,-2018(a5) # ffffffffc0210478 <free_area>
ffffffffc0200c62:	00010797          	auipc	a5,0x10
ffffffffc0200c66:	8177bf23          	sd	s7,-2018(a5) # ffffffffc0210480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200c6a:	00010797          	auipc	a5,0x10
ffffffffc0200c6e:	8167af23          	sw	s6,-2018(a5) # ffffffffc0210488 <free_area+0x10>
    free_page(p);
ffffffffc0200c72:	235000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_page(p1);
ffffffffc0200c76:	4585                	li	a1,1
ffffffffc0200c78:	8556                	mv	a0,s5
ffffffffc0200c7a:	22d000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_page(p2);
ffffffffc0200c7e:	4585                	li	a1,1
ffffffffc0200c80:	8552                	mv	a0,s4
ffffffffc0200c82:	225000ef          	jal	ra,ffffffffc02016a6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c86:	4515                	li	a0,5
ffffffffc0200c88:	197000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200c8c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c8e:	28050363          	beqz	a0,ffffffffc0200f14 <default_check+0x468>
ffffffffc0200c92:	651c                	ld	a5,8(a0)
ffffffffc0200c94:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c96:	8b85                	andi	a5,a5,1
ffffffffc0200c98:	54079e63          	bnez	a5,ffffffffc02011f4 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c9e:	00093b03          	ld	s6,0(s2)
ffffffffc0200ca2:	00893a83          	ld	s5,8(s2)
ffffffffc0200ca6:	0000f797          	auipc	a5,0xf
ffffffffc0200caa:	7d27b923          	sd	s2,2002(a5) # ffffffffc0210478 <free_area>
ffffffffc0200cae:	0000f797          	auipc	a5,0xf
ffffffffc0200cb2:	7d27b923          	sd	s2,2002(a5) # ffffffffc0210480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200cb6:	169000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200cba:	50051d63          	bnez	a0,ffffffffc02011d4 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cbe:	09098a13          	addi	s4,s3,144
ffffffffc0200cc2:	8552                	mv	a0,s4
ffffffffc0200cc4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cc6:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200cca:	0000f797          	auipc	a5,0xf
ffffffffc0200cce:	7a07af23          	sw	zero,1982(a5) # ffffffffc0210488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cd2:	1d5000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cd6:	4511                	li	a0,4
ffffffffc0200cd8:	147000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200cdc:	4c051c63          	bnez	a0,ffffffffc02011b4 <default_check+0x708>
ffffffffc0200ce0:	0989b783          	ld	a5,152(s3)
ffffffffc0200ce4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200ce6:	8b85                	andi	a5,a5,1
ffffffffc0200ce8:	4a078663          	beqz	a5,ffffffffc0201194 <default_check+0x6e8>
ffffffffc0200cec:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cf0:	478d                	li	a5,3
ffffffffc0200cf2:	4af71163          	bne	a4,a5,ffffffffc0201194 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cf6:	450d                	li	a0,3
ffffffffc0200cf8:	127000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200cfc:	8c2a                	mv	s8,a0
ffffffffc0200cfe:	46050b63          	beqz	a0,ffffffffc0201174 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d02:	4505                	li	a0,1
ffffffffc0200d04:	11b000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200d08:	44051663          	bnez	a0,ffffffffc0201154 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d0c:	438a1463          	bne	s4,s8,ffffffffc0201134 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d10:	4585                	li	a1,1
ffffffffc0200d12:	854e                	mv	a0,s3
ffffffffc0200d14:	193000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d18:	458d                	li	a1,3
ffffffffc0200d1a:	8552                	mv	a0,s4
ffffffffc0200d1c:	18b000ef          	jal	ra,ffffffffc02016a6 <free_pages>
ffffffffc0200d20:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d24:	04898c13          	addi	s8,s3,72
ffffffffc0200d28:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d2a:	8b85                	andi	a5,a5,1
ffffffffc0200d2c:	3e078463          	beqz	a5,ffffffffc0201114 <default_check+0x668>
ffffffffc0200d30:	0189a703          	lw	a4,24(s3)
ffffffffc0200d34:	4785                	li	a5,1
ffffffffc0200d36:	3cf71f63          	bne	a4,a5,ffffffffc0201114 <default_check+0x668>
ffffffffc0200d3a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d3e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d40:	8b85                	andi	a5,a5,1
ffffffffc0200d42:	3a078963          	beqz	a5,ffffffffc02010f4 <default_check+0x648>
ffffffffc0200d46:	018a2703          	lw	a4,24(s4)
ffffffffc0200d4a:	478d                	li	a5,3
ffffffffc0200d4c:	3af71463          	bne	a4,a5,ffffffffc02010f4 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d50:	4505                	li	a0,1
ffffffffc0200d52:	0cd000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200d56:	36a99f63          	bne	s3,a0,ffffffffc02010d4 <default_check+0x628>
    free_page(p0);
ffffffffc0200d5a:	4585                	li	a1,1
ffffffffc0200d5c:	14b000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d60:	4509                	li	a0,2
ffffffffc0200d62:	0bd000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200d66:	34aa1763          	bne	s4,a0,ffffffffc02010b4 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200d6a:	4589                	li	a1,2
ffffffffc0200d6c:	13b000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    free_page(p2);
ffffffffc0200d70:	4585                	li	a1,1
ffffffffc0200d72:	8562                	mv	a0,s8
ffffffffc0200d74:	133000ef          	jal	ra,ffffffffc02016a6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d78:	4515                	li	a0,5
ffffffffc0200d7a:	0a5000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200d7e:	89aa                	mv	s3,a0
ffffffffc0200d80:	48050a63          	beqz	a0,ffffffffc0201214 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200d84:	4505                	li	a0,1
ffffffffc0200d86:	099000ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0200d8a:	2e051563          	bnez	a0,ffffffffc0201074 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200d8e:	01092783          	lw	a5,16(s2)
ffffffffc0200d92:	2c079163          	bnez	a5,ffffffffc0201054 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d96:	4595                	li	a1,5
ffffffffc0200d98:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d9a:	0000f797          	auipc	a5,0xf
ffffffffc0200d9e:	6f77a723          	sw	s7,1774(a5) # ffffffffc0210488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200da2:	0000f797          	auipc	a5,0xf
ffffffffc0200da6:	6d67bb23          	sd	s6,1750(a5) # ffffffffc0210478 <free_area>
ffffffffc0200daa:	0000f797          	auipc	a5,0xf
ffffffffc0200dae:	6d57bb23          	sd	s5,1750(a5) # ffffffffc0210480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200db2:	0f5000ef          	jal	ra,ffffffffc02016a6 <free_pages>
    return listelm->next;
ffffffffc0200db6:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dba:	01278963          	beq	a5,s2,ffffffffc0200dcc <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dbe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dc2:	679c                	ld	a5,8(a5)
ffffffffc0200dc4:	34fd                	addiw	s1,s1,-1
ffffffffc0200dc6:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dc8:	ff279be3          	bne	a5,s2,ffffffffc0200dbe <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200dcc:	26049463          	bnez	s1,ffffffffc0201034 <default_check+0x588>
    assert(total == 0);
ffffffffc0200dd0:	46041263          	bnez	s0,ffffffffc0201234 <default_check+0x788>
}
ffffffffc0200dd4:	60a6                	ld	ra,72(sp)
ffffffffc0200dd6:	6406                	ld	s0,64(sp)
ffffffffc0200dd8:	74e2                	ld	s1,56(sp)
ffffffffc0200dda:	7942                	ld	s2,48(sp)
ffffffffc0200ddc:	79a2                	ld	s3,40(sp)
ffffffffc0200dde:	7a02                	ld	s4,32(sp)
ffffffffc0200de0:	6ae2                	ld	s5,24(sp)
ffffffffc0200de2:	6b42                	ld	s6,16(sp)
ffffffffc0200de4:	6ba2                	ld	s7,8(sp)
ffffffffc0200de6:	6c02                	ld	s8,0(sp)
ffffffffc0200de8:	6161                	addi	sp,sp,80
ffffffffc0200dea:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dec:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dee:	4401                	li	s0,0
ffffffffc0200df0:	4481                	li	s1,0
ffffffffc0200df2:	b331                	j	ffffffffc0200afe <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200df4:	00004697          	auipc	a3,0x4
ffffffffc0200df8:	c3468693          	addi	a3,a3,-972 # ffffffffc0204a28 <commands+0x860>
ffffffffc0200dfc:	00004617          	auipc	a2,0x4
ffffffffc0200e00:	c3c60613          	addi	a2,a2,-964 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200e04:	0f000593          	li	a1,240
ffffffffc0200e08:	00004517          	auipc	a0,0x4
ffffffffc0200e0c:	c4850513          	addi	a0,a0,-952 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200e10:	d60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e14:	00004697          	auipc	a3,0x4
ffffffffc0200e18:	cd468693          	addi	a3,a3,-812 # ffffffffc0204ae8 <commands+0x920>
ffffffffc0200e1c:	00004617          	auipc	a2,0x4
ffffffffc0200e20:	c1c60613          	addi	a2,a2,-996 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200e24:	0bd00593          	li	a1,189
ffffffffc0200e28:	00004517          	auipc	a0,0x4
ffffffffc0200e2c:	c2850513          	addi	a0,a0,-984 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200e30:	d40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e34:	00004697          	auipc	a3,0x4
ffffffffc0200e38:	cdc68693          	addi	a3,a3,-804 # ffffffffc0204b10 <commands+0x948>
ffffffffc0200e3c:	00004617          	auipc	a2,0x4
ffffffffc0200e40:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200e44:	0be00593          	li	a1,190
ffffffffc0200e48:	00004517          	auipc	a0,0x4
ffffffffc0200e4c:	c0850513          	addi	a0,a0,-1016 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200e50:	d20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e54:	00004697          	auipc	a3,0x4
ffffffffc0200e58:	cfc68693          	addi	a3,a3,-772 # ffffffffc0204b50 <commands+0x988>
ffffffffc0200e5c:	00004617          	auipc	a2,0x4
ffffffffc0200e60:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200e64:	0c000593          	li	a1,192
ffffffffc0200e68:	00004517          	auipc	a0,0x4
ffffffffc0200e6c:	be850513          	addi	a0,a0,-1048 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200e70:	d00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e74:	00004697          	auipc	a3,0x4
ffffffffc0200e78:	d6468693          	addi	a3,a3,-668 # ffffffffc0204bd8 <commands+0xa10>
ffffffffc0200e7c:	00004617          	auipc	a2,0x4
ffffffffc0200e80:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200e84:	0d900593          	li	a1,217
ffffffffc0200e88:	00004517          	auipc	a0,0x4
ffffffffc0200e8c:	bc850513          	addi	a0,a0,-1080 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200e90:	ce0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	bf468693          	addi	a3,a3,-1036 # ffffffffc0204a88 <commands+0x8c0>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200ea4:	0d200593          	li	a1,210
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	ba850513          	addi	a0,a0,-1112 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200eb0:	cc0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 3);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	d1468693          	addi	a3,a3,-748 # ffffffffc0204bc8 <commands+0xa00>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200ec4:	0d000593          	li	a1,208
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	b8850513          	addi	a0,a0,-1144 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200ed0:	ca0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	cdc68693          	addi	a3,a3,-804 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200ee4:	0cb00593          	li	a1,203
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	b6850513          	addi	a0,a0,-1176 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200ef0:	c80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	c9c68693          	addi	a3,a3,-868 # ffffffffc0204b90 <commands+0x9c8>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200f04:	0c200593          	li	a1,194
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	b4850513          	addi	a0,a0,-1208 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200f10:	c60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != NULL);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204c20 <commands+0xa58>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200f24:	0f800593          	li	a1,248
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200f30:	c40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	cdc68693          	addi	a3,a3,-804 # ffffffffc0204c10 <commands+0xa48>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200f44:	0df00593          	li	a1,223
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200f50:	c20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	c5c68693          	addi	a3,a3,-932 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200f64:	0dd00593          	li	a1,221
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200f70:	c00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	c7c68693          	addi	a3,a3,-900 # ffffffffc0204bf0 <commands+0xa28>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200f84:	0dc00593          	li	a1,220
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200f90:	be0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	af468693          	addi	a3,a3,-1292 # ffffffffc0204a88 <commands+0x8c0>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200fa4:	0b900593          	li	a1,185
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200fb0:	bc0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200fc4:	0d600593          	li	a1,214
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200fd0:	ba0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	af468693          	addi	a3,a3,-1292 # ffffffffc0204ac8 <commands+0x900>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204a38 <commands+0x870>
ffffffffc0200fe4:	0d400593          	li	a1,212
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	a6850513          	addi	a0,a0,-1432 # ffffffffc0204a50 <commands+0x888>
ffffffffc0200ff0:	b80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0204aa8 <commands+0x8e0>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201004:	0d300593          	li	a1,211
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201010:	b60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	ab468693          	addi	a3,a3,-1356 # ffffffffc0204ac8 <commands+0x900>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201024:	0bb00593          	li	a1,187
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201030:	b40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(count == 0);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	d3c68693          	addi	a3,a3,-708 # ffffffffc0204d70 <commands+0xba8>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201044:	12500593          	li	a1,293
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201050:	b20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0204c10 <commands+0xa48>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201064:	11a00593          	li	a1,282
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201070:	b00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201084:	11800593          	li	a1,280
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201090:	ae0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	adc68693          	addi	a3,a3,-1316 # ffffffffc0204b70 <commands+0x9a8>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0204a38 <commands+0x870>
ffffffffc02010a4:	0c100593          	li	a1,193
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	9a850513          	addi	a0,a0,-1624 # ffffffffc0204a50 <commands+0x888>
ffffffffc02010b0:	ac0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	c7c68693          	addi	a3,a3,-900 # ffffffffc0204d30 <commands+0xb68>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0204a38 <commands+0x870>
ffffffffc02010c4:	11200593          	li	a1,274
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	98850513          	addi	a0,a0,-1656 # ffffffffc0204a50 <commands+0x888>
ffffffffc02010d0:	aa0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	c3c68693          	addi	a3,a3,-964 # ffffffffc0204d10 <commands+0xb48>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0204a38 <commands+0x870>
ffffffffc02010e4:	11000593          	li	a1,272
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	96850513          	addi	a0,a0,-1688 # ffffffffc0204a50 <commands+0x888>
ffffffffc02010f0:	a80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	bf468693          	addi	a3,a3,-1036 # ffffffffc0204ce8 <commands+0xb20>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	93c60613          	addi	a2,a2,-1732 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201104:	10e00593          	li	a1,270
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	94850513          	addi	a0,a0,-1720 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201110:	a60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	bac68693          	addi	a3,a3,-1108 # ffffffffc0204cc0 <commands+0xaf8>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	91c60613          	addi	a2,a2,-1764 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201124:	10d00593          	li	a1,269
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	92850513          	addi	a0,a0,-1752 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201130:	a40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0204cb0 <commands+0xae8>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201144:	10800593          	li	a1,264
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	90850513          	addi	a0,a0,-1784 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201150:	a20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201164:	10700593          	li	a1,263
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201170:	a00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0204c90 <commands+0xac8>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201184:	10600593          	li	a1,262
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201190:	9e0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204c60 <commands+0xa98>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	89c60613          	addi	a2,a2,-1892 # ffffffffc0204a38 <commands+0x870>
ffffffffc02011a4:	10500593          	li	a1,261
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204a50 <commands+0x888>
ffffffffc02011b0:	9c0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	a9468693          	addi	a3,a3,-1388 # ffffffffc0204c48 <commands+0xa80>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204a38 <commands+0x870>
ffffffffc02011c4:	10400593          	li	a1,260
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	88850513          	addi	a0,a0,-1912 # ffffffffc0204a50 <commands+0x888>
ffffffffc02011d0:	9a0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0204bb0 <commands+0x9e8>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0204a38 <commands+0x870>
ffffffffc02011e4:	0fe00593          	li	a1,254
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	86850513          	addi	a0,a0,-1944 # ffffffffc0204a50 <commands+0x888>
ffffffffc02011f0:	980ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0204c30 <commands+0xa68>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201204:	0f900593          	li	a1,249
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	84850513          	addi	a0,a0,-1976 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201210:	960ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0204d50 <commands+0xb88>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201224:	11700593          	li	a1,279
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	82850513          	addi	a0,a0,-2008 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201230:	940ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == 0);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0204d80 <commands+0xbb8>
ffffffffc020123c:	00003617          	auipc	a2,0x3
ffffffffc0201240:	7fc60613          	addi	a2,a2,2044 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201244:	12600593          	li	a1,294
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	80850513          	addi	a0,a0,-2040 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201250:	920ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	81468693          	addi	a3,a3,-2028 # ffffffffc0204a68 <commands+0x8a0>
ffffffffc020125c:	00003617          	auipc	a2,0x3
ffffffffc0201260:	7dc60613          	addi	a2,a2,2012 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201264:	0f300593          	li	a1,243
ffffffffc0201268:	00003517          	auipc	a0,0x3
ffffffffc020126c:	7e850513          	addi	a0,a0,2024 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201270:	900ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	83468693          	addi	a3,a3,-1996 # ffffffffc0204aa8 <commands+0x8e0>
ffffffffc020127c:	00003617          	auipc	a2,0x3
ffffffffc0201280:	7bc60613          	addi	a2,a2,1980 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201284:	0ba00593          	li	a1,186
ffffffffc0201288:	00003517          	auipc	a0,0x3
ffffffffc020128c:	7c850513          	addi	a0,a0,1992 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201290:	8e0ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201294 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201294:	1141                	addi	sp,sp,-16
ffffffffc0201296:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201298:	18058063          	beqz	a1,ffffffffc0201418 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020129c:	00359693          	slli	a3,a1,0x3
ffffffffc02012a0:	96ae                	add	a3,a3,a1
ffffffffc02012a2:	068e                	slli	a3,a3,0x3
ffffffffc02012a4:	96aa                	add	a3,a3,a0
ffffffffc02012a6:	02d50d63          	beq	a0,a3,ffffffffc02012e0 <default_free_pages+0x4c>
ffffffffc02012aa:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012ac:	8b85                	andi	a5,a5,1
ffffffffc02012ae:	14079563          	bnez	a5,ffffffffc02013f8 <default_free_pages+0x164>
ffffffffc02012b2:	651c                	ld	a5,8(a0)
ffffffffc02012b4:	8385                	srli	a5,a5,0x1
ffffffffc02012b6:	8b85                	andi	a5,a5,1
ffffffffc02012b8:	14079063          	bnez	a5,ffffffffc02013f8 <default_free_pages+0x164>
ffffffffc02012bc:	87aa                	mv	a5,a0
ffffffffc02012be:	a809                	j	ffffffffc02012d0 <default_free_pages+0x3c>
ffffffffc02012c0:	6798                	ld	a4,8(a5)
ffffffffc02012c2:	8b05                	andi	a4,a4,1
ffffffffc02012c4:	12071a63          	bnez	a4,ffffffffc02013f8 <default_free_pages+0x164>
ffffffffc02012c8:	6798                	ld	a4,8(a5)
ffffffffc02012ca:	8b09                	andi	a4,a4,2
ffffffffc02012cc:	12071663          	bnez	a4,ffffffffc02013f8 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc02012d0:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012d4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012d8:	04878793          	addi	a5,a5,72
ffffffffc02012dc:	fed792e3          	bne	a5,a3,ffffffffc02012c0 <default_free_pages+0x2c>
    base->property = n;
ffffffffc02012e0:	2581                	sext.w	a1,a1
ffffffffc02012e2:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012e4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012e8:	4789                	li	a5,2
ffffffffc02012ea:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012ee:	0000f697          	auipc	a3,0xf
ffffffffc02012f2:	18a68693          	addi	a3,a3,394 # ffffffffc0210478 <free_area>
ffffffffc02012f6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012f8:	669c                	ld	a5,8(a3)
ffffffffc02012fa:	9db9                	addw	a1,a1,a4
ffffffffc02012fc:	0000f717          	auipc	a4,0xf
ffffffffc0201300:	18b72623          	sw	a1,396(a4) # ffffffffc0210488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201304:	08d78f63          	beq	a5,a3,ffffffffc02013a2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201308:	fe078713          	addi	a4,a5,-32
ffffffffc020130c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020130e:	4801                	li	a6,0
ffffffffc0201310:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201314:	00e56a63          	bltu	a0,a4,ffffffffc0201328 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201318:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020131a:	02d70563          	beq	a4,a3,ffffffffc0201344 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020131e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201320:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201324:	fee57ae3          	bgeu	a0,a4,ffffffffc0201318 <default_free_pages+0x84>
ffffffffc0201328:	00080663          	beqz	a6,ffffffffc0201334 <default_free_pages+0xa0>
ffffffffc020132c:	0000f817          	auipc	a6,0xf
ffffffffc0201330:	14b83623          	sd	a1,332(a6) # ffffffffc0210478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201334:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201336:	e390                	sd	a2,0(a5)
ffffffffc0201338:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020133a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020133c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020133e:	02d59163          	bne	a1,a3,ffffffffc0201360 <default_free_pages+0xcc>
ffffffffc0201342:	a091                	j	ffffffffc0201386 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201344:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201346:	f514                	sd	a3,40(a0)
ffffffffc0201348:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020134a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020134c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020134e:	00d70563          	beq	a4,a3,ffffffffc0201358 <default_free_pages+0xc4>
ffffffffc0201352:	4805                	li	a6,1
ffffffffc0201354:	87ba                	mv	a5,a4
ffffffffc0201356:	b7e9                	j	ffffffffc0201320 <default_free_pages+0x8c>
ffffffffc0201358:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020135a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020135c:	02d78163          	beq	a5,a3,ffffffffc020137e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201360:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201364:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201368:	02081713          	slli	a4,a6,0x20
ffffffffc020136c:	9301                	srli	a4,a4,0x20
ffffffffc020136e:	00371793          	slli	a5,a4,0x3
ffffffffc0201372:	97ba                	add	a5,a5,a4
ffffffffc0201374:	078e                	slli	a5,a5,0x3
ffffffffc0201376:	97b2                	add	a5,a5,a2
ffffffffc0201378:	02f50e63          	beq	a0,a5,ffffffffc02013b4 <default_free_pages+0x120>
ffffffffc020137c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020137e:	fe078713          	addi	a4,a5,-32
ffffffffc0201382:	00d78d63          	beq	a5,a3,ffffffffc020139c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201386:	4d0c                	lw	a1,24(a0)
ffffffffc0201388:	02059613          	slli	a2,a1,0x20
ffffffffc020138c:	9201                	srli	a2,a2,0x20
ffffffffc020138e:	00361693          	slli	a3,a2,0x3
ffffffffc0201392:	96b2                	add	a3,a3,a2
ffffffffc0201394:	068e                	slli	a3,a3,0x3
ffffffffc0201396:	96aa                	add	a3,a3,a0
ffffffffc0201398:	04d70063          	beq	a4,a3,ffffffffc02013d8 <default_free_pages+0x144>
}
ffffffffc020139c:	60a2                	ld	ra,8(sp)
ffffffffc020139e:	0141                	addi	sp,sp,16
ffffffffc02013a0:	8082                	ret
ffffffffc02013a2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013a4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013a8:	e398                	sd	a4,0(a5)
ffffffffc02013aa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ae:	f11c                	sd	a5,32(a0)
}
ffffffffc02013b0:	0141                	addi	sp,sp,16
ffffffffc02013b2:	8082                	ret
            p->property += base->property;
ffffffffc02013b4:	4d1c                	lw	a5,24(a0)
ffffffffc02013b6:	0107883b          	addw	a6,a5,a6
ffffffffc02013ba:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013be:	57f5                	li	a5,-3
ffffffffc02013c0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013c4:	02053803          	ld	a6,32(a0)
ffffffffc02013c8:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc02013ca:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013cc:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02013d0:	659c                	ld	a5,8(a1)
ffffffffc02013d2:	01073023          	sd	a6,0(a4)
ffffffffc02013d6:	b765                	j	ffffffffc020137e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02013d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013dc:	fe878693          	addi	a3,a5,-24
ffffffffc02013e0:	9db9                	addw	a1,a1,a4
ffffffffc02013e2:	cd0c                	sw	a1,24(a0)
ffffffffc02013e4:	5775                	li	a4,-3
ffffffffc02013e6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ea:	6398                	ld	a4,0(a5)
ffffffffc02013ec:	679c                	ld	a5,8(a5)
}
ffffffffc02013ee:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013f0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02013f2:	e398                	sd	a4,0(a5)
ffffffffc02013f4:	0141                	addi	sp,sp,16
ffffffffc02013f6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013f8:	00004697          	auipc	a3,0x4
ffffffffc02013fc:	99868693          	addi	a3,a3,-1640 # ffffffffc0204d90 <commands+0xbc8>
ffffffffc0201400:	00003617          	auipc	a2,0x3
ffffffffc0201404:	63860613          	addi	a2,a2,1592 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201408:	08300593          	li	a1,131
ffffffffc020140c:	00003517          	auipc	a0,0x3
ffffffffc0201410:	64450513          	addi	a0,a0,1604 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201414:	f5dfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc0201418:	00004697          	auipc	a3,0x4
ffffffffc020141c:	9a068693          	addi	a3,a3,-1632 # ffffffffc0204db8 <commands+0xbf0>
ffffffffc0201420:	00003617          	auipc	a2,0x3
ffffffffc0201424:	61860613          	addi	a2,a2,1560 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201428:	08000593          	li	a1,128
ffffffffc020142c:	00003517          	auipc	a0,0x3
ffffffffc0201430:	62450513          	addi	a0,a0,1572 # ffffffffc0204a50 <commands+0x888>
ffffffffc0201434:	f3dfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201438 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201438:	cd51                	beqz	a0,ffffffffc02014d4 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020143a:	0000f597          	auipc	a1,0xf
ffffffffc020143e:	03e58593          	addi	a1,a1,62 # ffffffffc0210478 <free_area>
ffffffffc0201442:	0105a803          	lw	a6,16(a1)
ffffffffc0201446:	862a                	mv	a2,a0
ffffffffc0201448:	02081793          	slli	a5,a6,0x20
ffffffffc020144c:	9381                	srli	a5,a5,0x20
ffffffffc020144e:	00a7ee63          	bltu	a5,a0,ffffffffc020146a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201452:	87ae                	mv	a5,a1
ffffffffc0201454:	a801                	j	ffffffffc0201464 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201456:	ff87a703          	lw	a4,-8(a5)
ffffffffc020145a:	02071693          	slli	a3,a4,0x20
ffffffffc020145e:	9281                	srli	a3,a3,0x20
ffffffffc0201460:	00c6f763          	bgeu	a3,a2,ffffffffc020146e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201464:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201466:	feb798e3          	bne	a5,a1,ffffffffc0201456 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020146a:	4501                	li	a0,0
}
ffffffffc020146c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020146e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201472:	dd6d                	beqz	a0,ffffffffc020146c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201474:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201478:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020147c:	00060e1b          	sext.w	t3,a2
ffffffffc0201480:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201484:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201488:	02d67b63          	bgeu	a2,a3,ffffffffc02014be <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020148c:	00361693          	slli	a3,a2,0x3
ffffffffc0201490:	96b2                	add	a3,a3,a2
ffffffffc0201492:	068e                	slli	a3,a3,0x3
ffffffffc0201494:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201496:	41c7073b          	subw	a4,a4,t3
ffffffffc020149a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020149c:	00868613          	addi	a2,a3,8
ffffffffc02014a0:	4709                	li	a4,2
ffffffffc02014a2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014a6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014aa:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014ae:	0105a803          	lw	a6,16(a1)
ffffffffc02014b2:	e310                	sd	a2,0(a4)
ffffffffc02014b4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014b8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02014ba:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc02014be:	41c8083b          	subw	a6,a6,t3
ffffffffc02014c2:	0000f717          	auipc	a4,0xf
ffffffffc02014c6:	fd072323          	sw	a6,-58(a4) # ffffffffc0210488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014ca:	5775                	li	a4,-3
ffffffffc02014cc:	17a1                	addi	a5,a5,-24
ffffffffc02014ce:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02014d2:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014d4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014d6:	00004697          	auipc	a3,0x4
ffffffffc02014da:	8e268693          	addi	a3,a3,-1822 # ffffffffc0204db8 <commands+0xbf0>
ffffffffc02014de:	00003617          	auipc	a2,0x3
ffffffffc02014e2:	55a60613          	addi	a2,a2,1370 # ffffffffc0204a38 <commands+0x870>
ffffffffc02014e6:	06200593          	li	a1,98
ffffffffc02014ea:	00003517          	auipc	a0,0x3
ffffffffc02014ee:	56650513          	addi	a0,a0,1382 # ffffffffc0204a50 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02014f2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014f4:	e7dfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02014f8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014f8:	1141                	addi	sp,sp,-16
ffffffffc02014fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014fc:	c1fd                	beqz	a1,ffffffffc02015e2 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02014fe:	00359693          	slli	a3,a1,0x3
ffffffffc0201502:	96ae                	add	a3,a3,a1
ffffffffc0201504:	068e                	slli	a3,a3,0x3
ffffffffc0201506:	96aa                	add	a3,a3,a0
ffffffffc0201508:	02d50463          	beq	a0,a3,ffffffffc0201530 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020150c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020150e:	87aa                	mv	a5,a0
ffffffffc0201510:	8b05                	andi	a4,a4,1
ffffffffc0201512:	e709                	bnez	a4,ffffffffc020151c <default_init_memmap+0x24>
ffffffffc0201514:	a07d                	j	ffffffffc02015c2 <default_init_memmap+0xca>
ffffffffc0201516:	6798                	ld	a4,8(a5)
ffffffffc0201518:	8b05                	andi	a4,a4,1
ffffffffc020151a:	c745                	beqz	a4,ffffffffc02015c2 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020151c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201520:	0007b423          	sd	zero,8(a5)
ffffffffc0201524:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201528:	04878793          	addi	a5,a5,72
ffffffffc020152c:	fed795e3          	bne	a5,a3,ffffffffc0201516 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201530:	2581                	sext.w	a1,a1
ffffffffc0201532:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201534:	4789                	li	a5,2
ffffffffc0201536:	00850713          	addi	a4,a0,8
ffffffffc020153a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020153e:	0000f697          	auipc	a3,0xf
ffffffffc0201542:	f3a68693          	addi	a3,a3,-198 # ffffffffc0210478 <free_area>
ffffffffc0201546:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201548:	669c                	ld	a5,8(a3)
ffffffffc020154a:	9db9                	addw	a1,a1,a4
ffffffffc020154c:	0000f717          	auipc	a4,0xf
ffffffffc0201550:	f2b72e23          	sw	a1,-196(a4) # ffffffffc0210488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201554:	04d78a63          	beq	a5,a3,ffffffffc02015a8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201558:	fe078713          	addi	a4,a5,-32
ffffffffc020155c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020155e:	4801                	li	a6,0
ffffffffc0201560:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201564:	00e56a63          	bltu	a0,a4,ffffffffc0201578 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201568:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020156a:	02d70563          	beq	a4,a3,ffffffffc0201594 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020156e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201570:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201574:	fee57ae3          	bgeu	a0,a4,ffffffffc0201568 <default_init_memmap+0x70>
ffffffffc0201578:	00080663          	beqz	a6,ffffffffc0201584 <default_init_memmap+0x8c>
ffffffffc020157c:	0000f717          	auipc	a4,0xf
ffffffffc0201580:	eeb73e23          	sd	a1,-260(a4) # ffffffffc0210478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201584:	6398                	ld	a4,0(a5)
}
ffffffffc0201586:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201588:	e390                	sd	a2,0(a5)
ffffffffc020158a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020158c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020158e:	f118                	sd	a4,32(a0)
ffffffffc0201590:	0141                	addi	sp,sp,16
ffffffffc0201592:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201594:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201596:	f514                	sd	a3,40(a0)
ffffffffc0201598:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020159a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020159c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020159e:	00d70e63          	beq	a4,a3,ffffffffc02015ba <default_init_memmap+0xc2>
ffffffffc02015a2:	4805                	li	a6,1
ffffffffc02015a4:	87ba                	mv	a5,a4
ffffffffc02015a6:	b7e9                	j	ffffffffc0201570 <default_init_memmap+0x78>
}
ffffffffc02015a8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015aa:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015ae:	e398                	sd	a4,0(a5)
ffffffffc02015b0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02015b2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015b4:	f11c                	sd	a5,32(a0)
}
ffffffffc02015b6:	0141                	addi	sp,sp,16
ffffffffc02015b8:	8082                	ret
ffffffffc02015ba:	60a2                	ld	ra,8(sp)
ffffffffc02015bc:	e290                	sd	a2,0(a3)
ffffffffc02015be:	0141                	addi	sp,sp,16
ffffffffc02015c0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015c2:	00003697          	auipc	a3,0x3
ffffffffc02015c6:	7fe68693          	addi	a3,a3,2046 # ffffffffc0204dc0 <commands+0xbf8>
ffffffffc02015ca:	00003617          	auipc	a2,0x3
ffffffffc02015ce:	46e60613          	addi	a2,a2,1134 # ffffffffc0204a38 <commands+0x870>
ffffffffc02015d2:	04900593          	li	a1,73
ffffffffc02015d6:	00003517          	auipc	a0,0x3
ffffffffc02015da:	47a50513          	addi	a0,a0,1146 # ffffffffc0204a50 <commands+0x888>
ffffffffc02015de:	d93fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc02015e2:	00003697          	auipc	a3,0x3
ffffffffc02015e6:	7d668693          	addi	a3,a3,2006 # ffffffffc0204db8 <commands+0xbf0>
ffffffffc02015ea:	00003617          	auipc	a2,0x3
ffffffffc02015ee:	44e60613          	addi	a2,a2,1102 # ffffffffc0204a38 <commands+0x870>
ffffffffc02015f2:	04600593          	li	a1,70
ffffffffc02015f6:	00003517          	auipc	a0,0x3
ffffffffc02015fa:	45a50513          	addi	a0,a0,1114 # ffffffffc0204a50 <commands+0x888>
ffffffffc02015fe:	d73fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201602 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201602:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201604:	00004617          	auipc	a2,0x4
ffffffffc0201608:	89460613          	addi	a2,a2,-1900 # ffffffffc0204e98 <default_pmm_manager+0xc8>
ffffffffc020160c:	06500593          	li	a1,101
ffffffffc0201610:	00004517          	auipc	a0,0x4
ffffffffc0201614:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201618:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020161a:	d57fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020161e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020161e:	715d                	addi	sp,sp,-80
ffffffffc0201620:	e0a2                	sd	s0,64(sp)
ffffffffc0201622:	fc26                	sd	s1,56(sp)
ffffffffc0201624:	f84a                	sd	s2,48(sp)
ffffffffc0201626:	f44e                	sd	s3,40(sp)
ffffffffc0201628:	f052                	sd	s4,32(sp)
ffffffffc020162a:	ec56                	sd	s5,24(sp)
ffffffffc020162c:	e486                	sd	ra,72(sp)
ffffffffc020162e:	842a                	mv	s0,a0
ffffffffc0201630:	0000f497          	auipc	s1,0xf
ffffffffc0201634:	e6048493          	addi	s1,s1,-416 # ffffffffc0210490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201638:	4985                	li	s3,1
ffffffffc020163a:	0000fa17          	auipc	s4,0xf
ffffffffc020163e:	e2ea0a13          	addi	s4,s4,-466 # ffffffffc0210468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201642:	0005091b          	sext.w	s2,a0
ffffffffc0201646:	0000fa97          	auipc	s5,0xf
ffffffffc020164a:	f4aa8a93          	addi	s5,s5,-182 # ffffffffc0210590 <check_mm_struct>
ffffffffc020164e:	a00d                	j	ffffffffc0201670 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201650:	609c                	ld	a5,0(s1)
ffffffffc0201652:	6f9c                	ld	a5,24(a5)
ffffffffc0201654:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201656:	4601                	li	a2,0
ffffffffc0201658:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020165a:	ed0d                	bnez	a0,ffffffffc0201694 <alloc_pages+0x76>
ffffffffc020165c:	0289ec63          	bltu	s3,s0,ffffffffc0201694 <alloc_pages+0x76>
ffffffffc0201660:	000a2783          	lw	a5,0(s4)
ffffffffc0201664:	2781                	sext.w	a5,a5
ffffffffc0201666:	c79d                	beqz	a5,ffffffffc0201694 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201668:	000ab503          	ld	a0,0(s5)
ffffffffc020166c:	013010ef          	jal	ra,ffffffffc0202e7e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201670:	100027f3          	csrr	a5,sstatus
ffffffffc0201674:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201676:	8522                	mv	a0,s0
ffffffffc0201678:	dfe1                	beqz	a5,ffffffffc0201650 <alloc_pages+0x32>
        intr_disable();
ffffffffc020167a:	e55fe0ef          	jal	ra,ffffffffc02004ce <intr_disable>
ffffffffc020167e:	609c                	ld	a5,0(s1)
ffffffffc0201680:	8522                	mv	a0,s0
ffffffffc0201682:	6f9c                	ld	a5,24(a5)
ffffffffc0201684:	9782                	jalr	a5
ffffffffc0201686:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201688:	e41fe0ef          	jal	ra,ffffffffc02004c8 <intr_enable>
ffffffffc020168c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020168e:	4601                	li	a2,0
ffffffffc0201690:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201692:	d569                	beqz	a0,ffffffffc020165c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201694:	60a6                	ld	ra,72(sp)
ffffffffc0201696:	6406                	ld	s0,64(sp)
ffffffffc0201698:	74e2                	ld	s1,56(sp)
ffffffffc020169a:	7942                	ld	s2,48(sp)
ffffffffc020169c:	79a2                	ld	s3,40(sp)
ffffffffc020169e:	7a02                	ld	s4,32(sp)
ffffffffc02016a0:	6ae2                	ld	s5,24(sp)
ffffffffc02016a2:	6161                	addi	sp,sp,80
ffffffffc02016a4:	8082                	ret

ffffffffc02016a6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016a6:	100027f3          	csrr	a5,sstatus
ffffffffc02016aa:	8b89                	andi	a5,a5,2
ffffffffc02016ac:	eb89                	bnez	a5,ffffffffc02016be <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ae:	0000f797          	auipc	a5,0xf
ffffffffc02016b2:	de278793          	addi	a5,a5,-542 # ffffffffc0210490 <pmm_manager>
ffffffffc02016b6:	639c                	ld	a5,0(a5)
ffffffffc02016b8:	0207b303          	ld	t1,32(a5)
ffffffffc02016bc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02016be:	1101                	addi	sp,sp,-32
ffffffffc02016c0:	ec06                	sd	ra,24(sp)
ffffffffc02016c2:	e822                	sd	s0,16(sp)
ffffffffc02016c4:	e426                	sd	s1,8(sp)
ffffffffc02016c6:	842a                	mv	s0,a0
ffffffffc02016c8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016ca:	e05fe0ef          	jal	ra,ffffffffc02004ce <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ce:	0000f797          	auipc	a5,0xf
ffffffffc02016d2:	dc278793          	addi	a5,a5,-574 # ffffffffc0210490 <pmm_manager>
ffffffffc02016d6:	639c                	ld	a5,0(a5)
ffffffffc02016d8:	85a6                	mv	a1,s1
ffffffffc02016da:	8522                	mv	a0,s0
ffffffffc02016dc:	739c                	ld	a5,32(a5)
ffffffffc02016de:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016e0:	6442                	ld	s0,16(sp)
ffffffffc02016e2:	60e2                	ld	ra,24(sp)
ffffffffc02016e4:	64a2                	ld	s1,8(sp)
ffffffffc02016e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016e8:	de1fe06f          	j	ffffffffc02004c8 <intr_enable>

ffffffffc02016ec <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016ec:	100027f3          	csrr	a5,sstatus
ffffffffc02016f0:	8b89                	andi	a5,a5,2
ffffffffc02016f2:	eb89                	bnez	a5,ffffffffc0201704 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016f4:	0000f797          	auipc	a5,0xf
ffffffffc02016f8:	d9c78793          	addi	a5,a5,-612 # ffffffffc0210490 <pmm_manager>
ffffffffc02016fc:	639c                	ld	a5,0(a5)
ffffffffc02016fe:	0287b303          	ld	t1,40(a5)
ffffffffc0201702:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201704:	1141                	addi	sp,sp,-16
ffffffffc0201706:	e406                	sd	ra,8(sp)
ffffffffc0201708:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020170a:	dc5fe0ef          	jal	ra,ffffffffc02004ce <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020170e:	0000f797          	auipc	a5,0xf
ffffffffc0201712:	d8278793          	addi	a5,a5,-638 # ffffffffc0210490 <pmm_manager>
ffffffffc0201716:	639c                	ld	a5,0(a5)
ffffffffc0201718:	779c                	ld	a5,40(a5)
ffffffffc020171a:	9782                	jalr	a5
ffffffffc020171c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020171e:	dabfe0ef          	jal	ra,ffffffffc02004c8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201722:	8522                	mv	a0,s0
ffffffffc0201724:	60a2                	ld	ra,8(sp)
ffffffffc0201726:	6402                	ld	s0,0(sp)
ffffffffc0201728:	0141                	addi	sp,sp,16
ffffffffc020172a:	8082                	ret

ffffffffc020172c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020172c:	715d                	addi	sp,sp,-80
ffffffffc020172e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201730:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201734:	1ff4f493          	andi	s1,s1,511
ffffffffc0201738:	048e                	slli	s1,s1,0x3
ffffffffc020173a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020173c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020173e:	f84a                	sd	s2,48(sp)
ffffffffc0201740:	f44e                	sd	s3,40(sp)
ffffffffc0201742:	f052                	sd	s4,32(sp)
ffffffffc0201744:	e486                	sd	ra,72(sp)
ffffffffc0201746:	e0a2                	sd	s0,64(sp)
ffffffffc0201748:	ec56                	sd	s5,24(sp)
ffffffffc020174a:	e85a                	sd	s6,16(sp)
ffffffffc020174c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020174e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201752:	892e                	mv	s2,a1
ffffffffc0201754:	8a32                	mv	s4,a2
ffffffffc0201756:	0000f997          	auipc	s3,0xf
ffffffffc020175a:	d0298993          	addi	s3,s3,-766 # ffffffffc0210458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020175e:	e3c9                	bnez	a5,ffffffffc02017e0 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201760:	16060163          	beqz	a2,ffffffffc02018c2 <get_pte+0x196>
ffffffffc0201764:	4505                	li	a0,1
ffffffffc0201766:	eb9ff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc020176a:	842a                	mv	s0,a0
ffffffffc020176c:	14050b63          	beqz	a0,ffffffffc02018c2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201770:	0000fb97          	auipc	s7,0xf
ffffffffc0201774:	d38b8b93          	addi	s7,s7,-712 # ffffffffc02104a8 <pages>
ffffffffc0201778:	000bb503          	ld	a0,0(s7)
ffffffffc020177c:	00003797          	auipc	a5,0x3
ffffffffc0201780:	2a478793          	addi	a5,a5,676 # ffffffffc0204a20 <commands+0x858>
ffffffffc0201784:	0007bb03          	ld	s6,0(a5)
ffffffffc0201788:	40a40533          	sub	a0,s0,a0
ffffffffc020178c:	850d                	srai	a0,a0,0x3
ffffffffc020178e:	03650533          	mul	a0,a0,s6
ffffffffc0201792:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201796:	0000f997          	auipc	s3,0xf
ffffffffc020179a:	cc298993          	addi	s3,s3,-830 # ffffffffc0210458 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020179e:	4785                	li	a5,1
ffffffffc02017a0:	0009b703          	ld	a4,0(s3)
ffffffffc02017a4:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017a6:	9556                	add	a0,a0,s5
ffffffffc02017a8:	00c51793          	slli	a5,a0,0xc
ffffffffc02017ac:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017ae:	0532                	slli	a0,a0,0xc
ffffffffc02017b0:	16e7f063          	bgeu	a5,a4,ffffffffc0201910 <get_pte+0x1e4>
ffffffffc02017b4:	0000f797          	auipc	a5,0xf
ffffffffc02017b8:	ce478793          	addi	a5,a5,-796 # ffffffffc0210498 <va_pa_offset>
ffffffffc02017bc:	639c                	ld	a5,0(a5)
ffffffffc02017be:	6605                	lui	a2,0x1
ffffffffc02017c0:	4581                	li	a1,0
ffffffffc02017c2:	953e                	add	a0,a0,a5
ffffffffc02017c4:	0b1020ef          	jal	ra,ffffffffc0204074 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c8:	000bb683          	ld	a3,0(s7)
ffffffffc02017cc:	40d406b3          	sub	a3,s0,a3
ffffffffc02017d0:	868d                	srai	a3,a3,0x3
ffffffffc02017d2:	036686b3          	mul	a3,a3,s6
ffffffffc02017d6:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017d8:	06aa                	slli	a3,a3,0xa
ffffffffc02017da:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017de:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017e0:	77fd                	lui	a5,0xfffff
ffffffffc02017e2:	068a                	slli	a3,a3,0x2
ffffffffc02017e4:	0009b703          	ld	a4,0(s3)
ffffffffc02017e8:	8efd                	and	a3,a3,a5
ffffffffc02017ea:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ee:	0ce7fc63          	bgeu	a5,a4,ffffffffc02018c6 <get_pte+0x19a>
ffffffffc02017f2:	0000fa97          	auipc	s5,0xf
ffffffffc02017f6:	ca6a8a93          	addi	s5,s5,-858 # ffffffffc0210498 <va_pa_offset>
ffffffffc02017fa:	000ab403          	ld	s0,0(s5)
ffffffffc02017fe:	01595793          	srli	a5,s2,0x15
ffffffffc0201802:	1ff7f793          	andi	a5,a5,511
ffffffffc0201806:	96a2                	add	a3,a3,s0
ffffffffc0201808:	00379413          	slli	s0,a5,0x3
ffffffffc020180c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020180e:	6014                	ld	a3,0(s0)
ffffffffc0201810:	0016f793          	andi	a5,a3,1
ffffffffc0201814:	ebbd                	bnez	a5,ffffffffc020188a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201816:	0a0a0663          	beqz	s4,ffffffffc02018c2 <get_pte+0x196>
ffffffffc020181a:	4505                	li	a0,1
ffffffffc020181c:	e03ff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0201820:	84aa                	mv	s1,a0
ffffffffc0201822:	c145                	beqz	a0,ffffffffc02018c2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201824:	0000fb97          	auipc	s7,0xf
ffffffffc0201828:	c84b8b93          	addi	s7,s7,-892 # ffffffffc02104a8 <pages>
ffffffffc020182c:	000bb503          	ld	a0,0(s7)
ffffffffc0201830:	00003797          	auipc	a5,0x3
ffffffffc0201834:	1f078793          	addi	a5,a5,496 # ffffffffc0204a20 <commands+0x858>
ffffffffc0201838:	0007bb03          	ld	s6,0(a5)
ffffffffc020183c:	40a48533          	sub	a0,s1,a0
ffffffffc0201840:	850d                	srai	a0,a0,0x3
ffffffffc0201842:	03650533          	mul	a0,a0,s6
ffffffffc0201846:	00080a37          	lui	s4,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020184a:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020184c:	0009b703          	ld	a4,0(s3)
ffffffffc0201850:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201852:	9552                	add	a0,a0,s4
ffffffffc0201854:	00c51793          	slli	a5,a0,0xc
ffffffffc0201858:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020185a:	0532                	slli	a0,a0,0xc
ffffffffc020185c:	08e7fd63          	bgeu	a5,a4,ffffffffc02018f6 <get_pte+0x1ca>
ffffffffc0201860:	000ab783          	ld	a5,0(s5)
ffffffffc0201864:	6605                	lui	a2,0x1
ffffffffc0201866:	4581                	li	a1,0
ffffffffc0201868:	953e                	add	a0,a0,a5
ffffffffc020186a:	00b020ef          	jal	ra,ffffffffc0204074 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020186e:	000bb683          	ld	a3,0(s7)
ffffffffc0201872:	40d486b3          	sub	a3,s1,a3
ffffffffc0201876:	868d                	srai	a3,a3,0x3
ffffffffc0201878:	036686b3          	mul	a3,a3,s6
ffffffffc020187c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020187e:	06aa                	slli	a3,a3,0xa
ffffffffc0201880:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201884:	e014                	sd	a3,0(s0)
ffffffffc0201886:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020188a:	068a                	slli	a3,a3,0x2
ffffffffc020188c:	757d                	lui	a0,0xfffff
ffffffffc020188e:	8ee9                	and	a3,a3,a0
ffffffffc0201890:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201894:	04e7f563          	bgeu	a5,a4,ffffffffc02018de <get_pte+0x1b2>
ffffffffc0201898:	000ab503          	ld	a0,0(s5)
ffffffffc020189c:	00c95793          	srli	a5,s2,0xc
ffffffffc02018a0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018a4:	96aa                	add	a3,a3,a0
ffffffffc02018a6:	00379513          	slli	a0,a5,0x3
ffffffffc02018aa:	9536                	add	a0,a0,a3
}
ffffffffc02018ac:	60a6                	ld	ra,72(sp)
ffffffffc02018ae:	6406                	ld	s0,64(sp)
ffffffffc02018b0:	74e2                	ld	s1,56(sp)
ffffffffc02018b2:	7942                	ld	s2,48(sp)
ffffffffc02018b4:	79a2                	ld	s3,40(sp)
ffffffffc02018b6:	7a02                	ld	s4,32(sp)
ffffffffc02018b8:	6ae2                	ld	s5,24(sp)
ffffffffc02018ba:	6b42                	ld	s6,16(sp)
ffffffffc02018bc:	6ba2                	ld	s7,8(sp)
ffffffffc02018be:	6161                	addi	sp,sp,80
ffffffffc02018c0:	8082                	ret
            return NULL;
ffffffffc02018c2:	4501                	li	a0,0
ffffffffc02018c4:	b7e5                	j	ffffffffc02018ac <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02018c6:	00003617          	auipc	a2,0x3
ffffffffc02018ca:	55a60613          	addi	a2,a2,1370 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc02018ce:	10200593          	li	a1,258
ffffffffc02018d2:	00003517          	auipc	a0,0x3
ffffffffc02018d6:	57650513          	addi	a0,a0,1398 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02018da:	a97fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018de:	00003617          	auipc	a2,0x3
ffffffffc02018e2:	54260613          	addi	a2,a2,1346 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc02018e6:	10f00593          	li	a1,271
ffffffffc02018ea:	00003517          	auipc	a0,0x3
ffffffffc02018ee:	55e50513          	addi	a0,a0,1374 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02018f2:	a7ffe0ef          	jal	ra,ffffffffc0200370 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018f6:	86aa                	mv	a3,a0
ffffffffc02018f8:	00003617          	auipc	a2,0x3
ffffffffc02018fc:	52860613          	addi	a2,a2,1320 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc0201900:	10b00593          	li	a1,267
ffffffffc0201904:	00003517          	auipc	a0,0x3
ffffffffc0201908:	54450513          	addi	a0,a0,1348 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020190c:	a65fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201910:	86aa                	mv	a3,a0
ffffffffc0201912:	00003617          	auipc	a2,0x3
ffffffffc0201916:	50e60613          	addi	a2,a2,1294 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc020191a:	0ff00593          	li	a1,255
ffffffffc020191e:	00003517          	auipc	a0,0x3
ffffffffc0201922:	52a50513          	addi	a0,a0,1322 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0201926:	a4bfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020192a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020192a:	1141                	addi	sp,sp,-16
ffffffffc020192c:	e022                	sd	s0,0(sp)
ffffffffc020192e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201930:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201932:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201934:	df9ff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201938:	c011                	beqz	s0,ffffffffc020193c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020193a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020193c:	c511                	beqz	a0,ffffffffc0201948 <get_page+0x1e>
ffffffffc020193e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201940:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201942:	0017f713          	andi	a4,a5,1
ffffffffc0201946:	e709                	bnez	a4,ffffffffc0201950 <get_page+0x26>
}
ffffffffc0201948:	60a2                	ld	ra,8(sp)
ffffffffc020194a:	6402                	ld	s0,0(sp)
ffffffffc020194c:	0141                	addi	sp,sp,16
ffffffffc020194e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201950:	0000f717          	auipc	a4,0xf
ffffffffc0201954:	b0870713          	addi	a4,a4,-1272 # ffffffffc0210458 <npage>
ffffffffc0201958:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020195a:	078a                	slli	a5,a5,0x2
ffffffffc020195c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020195e:	02e7f363          	bgeu	a5,a4,ffffffffc0201984 <get_page+0x5a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201962:	fff80537          	lui	a0,0xfff80
ffffffffc0201966:	97aa                	add	a5,a5,a0
ffffffffc0201968:	0000f697          	auipc	a3,0xf
ffffffffc020196c:	b4068693          	addi	a3,a3,-1216 # ffffffffc02104a8 <pages>
ffffffffc0201970:	6288                	ld	a0,0(a3)
ffffffffc0201972:	60a2                	ld	ra,8(sp)
ffffffffc0201974:	6402                	ld	s0,0(sp)
ffffffffc0201976:	00379713          	slli	a4,a5,0x3
ffffffffc020197a:	97ba                	add	a5,a5,a4
ffffffffc020197c:	078e                	slli	a5,a5,0x3
ffffffffc020197e:	953e                	add	a0,a0,a5
ffffffffc0201980:	0141                	addi	sp,sp,16
ffffffffc0201982:	8082                	ret
ffffffffc0201984:	c7fff0ef          	jal	ra,ffffffffc0201602 <pa2page.part.4>

ffffffffc0201988 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201988:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020198a:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020198c:	e406                	sd	ra,8(sp)
ffffffffc020198e:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201990:	d9dff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep != NULL) {
ffffffffc0201994:	c511                	beqz	a0,ffffffffc02019a0 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201996:	611c                	ld	a5,0(a0)
ffffffffc0201998:	842a                	mv	s0,a0
ffffffffc020199a:	0017f713          	andi	a4,a5,1
ffffffffc020199e:	e709                	bnez	a4,ffffffffc02019a8 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019a0:	60a2                	ld	ra,8(sp)
ffffffffc02019a2:	6402                	ld	s0,0(sp)
ffffffffc02019a4:	0141                	addi	sp,sp,16
ffffffffc02019a6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019a8:	0000f717          	auipc	a4,0xf
ffffffffc02019ac:	ab070713          	addi	a4,a4,-1360 # ffffffffc0210458 <npage>
ffffffffc02019b0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019b2:	078a                	slli	a5,a5,0x2
ffffffffc02019b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019b6:	04e7f063          	bgeu	a5,a4,ffffffffc02019f6 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc02019ba:	fff80737          	lui	a4,0xfff80
ffffffffc02019be:	97ba                	add	a5,a5,a4
ffffffffc02019c0:	0000f717          	auipc	a4,0xf
ffffffffc02019c4:	ae870713          	addi	a4,a4,-1304 # ffffffffc02104a8 <pages>
ffffffffc02019c8:	6308                	ld	a0,0(a4)
ffffffffc02019ca:	00379713          	slli	a4,a5,0x3
ffffffffc02019ce:	97ba                	add	a5,a5,a4
ffffffffc02019d0:	078e                	slli	a5,a5,0x3
ffffffffc02019d2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019d4:	411c                	lw	a5,0(a0)
ffffffffc02019d6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02019da:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019dc:	cb09                	beqz	a4,ffffffffc02019ee <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019de:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019e2:	12000073          	sfence.vma
}
ffffffffc02019e6:	60a2                	ld	ra,8(sp)
ffffffffc02019e8:	6402                	ld	s0,0(sp)
ffffffffc02019ea:	0141                	addi	sp,sp,16
ffffffffc02019ec:	8082                	ret
            free_page(page);
ffffffffc02019ee:	4585                	li	a1,1
ffffffffc02019f0:	cb7ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
ffffffffc02019f4:	b7ed                	j	ffffffffc02019de <page_remove+0x56>
ffffffffc02019f6:	c0dff0ef          	jal	ra,ffffffffc0201602 <pa2page.part.4>

ffffffffc02019fa <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019fa:	7179                	addi	sp,sp,-48
ffffffffc02019fc:	87b2                	mv	a5,a2
ffffffffc02019fe:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a00:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a02:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a04:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a06:	ec26                	sd	s1,24(sp)
ffffffffc0201a08:	f406                	sd	ra,40(sp)
ffffffffc0201a0a:	e84a                	sd	s2,16(sp)
ffffffffc0201a0c:	e44e                	sd	s3,8(sp)
ffffffffc0201a0e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a10:	d1dff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a14:	c945                	beqz	a0,ffffffffc0201ac4 <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a16:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a18:	611c                	ld	a5,0(a0)
ffffffffc0201a1a:	892a                	mv	s2,a0
ffffffffc0201a1c:	0016871b          	addiw	a4,a3,1
ffffffffc0201a20:	c018                	sw	a4,0(s0)
ffffffffc0201a22:	0017f713          	andi	a4,a5,1
ffffffffc0201a26:	e339                	bnez	a4,ffffffffc0201a6c <page_insert+0x72>
ffffffffc0201a28:	0000f797          	auipc	a5,0xf
ffffffffc0201a2c:	a8078793          	addi	a5,a5,-1408 # ffffffffc02104a8 <pages>
ffffffffc0201a30:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a32:	00003717          	auipc	a4,0x3
ffffffffc0201a36:	fee70713          	addi	a4,a4,-18 # ffffffffc0204a20 <commands+0x858>
ffffffffc0201a3a:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a3e:	6300                	ld	s0,0(a4)
ffffffffc0201a40:	878d                	srai	a5,a5,0x3
ffffffffc0201a42:	000806b7          	lui	a3,0x80
ffffffffc0201a46:	028787b3          	mul	a5,a5,s0
ffffffffc0201a4a:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a4c:	07aa                	slli	a5,a5,0xa
ffffffffc0201a4e:	8fc5                	or	a5,a5,s1
ffffffffc0201a50:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a54:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a58:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a5c:	4501                	li	a0,0
}
ffffffffc0201a5e:	70a2                	ld	ra,40(sp)
ffffffffc0201a60:	7402                	ld	s0,32(sp)
ffffffffc0201a62:	64e2                	ld	s1,24(sp)
ffffffffc0201a64:	6942                	ld	s2,16(sp)
ffffffffc0201a66:	69a2                	ld	s3,8(sp)
ffffffffc0201a68:	6145                	addi	sp,sp,48
ffffffffc0201a6a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a6c:	0000f717          	auipc	a4,0xf
ffffffffc0201a70:	9ec70713          	addi	a4,a4,-1556 # ffffffffc0210458 <npage>
ffffffffc0201a74:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a76:	00279513          	slli	a0,a5,0x2
ffffffffc0201a7a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a7c:	04e57663          	bgeu	a0,a4,ffffffffc0201ac8 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a80:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a84:	953e                	add	a0,a0,a5
ffffffffc0201a86:	0000f997          	auipc	s3,0xf
ffffffffc0201a8a:	a2298993          	addi	s3,s3,-1502 # ffffffffc02104a8 <pages>
ffffffffc0201a8e:	0009b783          	ld	a5,0(s3)
ffffffffc0201a92:	00351713          	slli	a4,a0,0x3
ffffffffc0201a96:	953a                	add	a0,a0,a4
ffffffffc0201a98:	050e                	slli	a0,a0,0x3
ffffffffc0201a9a:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201a9c:	00a40e63          	beq	s0,a0,ffffffffc0201ab8 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201aa0:	411c                	lw	a5,0(a0)
ffffffffc0201aa2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201aa6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201aa8:	cb11                	beqz	a4,ffffffffc0201abc <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201aaa:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201aae:	12000073          	sfence.vma
ffffffffc0201ab2:	0009b783          	ld	a5,0(s3)
ffffffffc0201ab6:	bfb5                	j	ffffffffc0201a32 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ab8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201aba:	bfa5                	j	ffffffffc0201a32 <page_insert+0x38>
            free_page(page);
ffffffffc0201abc:	4585                	li	a1,1
ffffffffc0201abe:	be9ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
ffffffffc0201ac2:	b7e5                	j	ffffffffc0201aaa <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201ac4:	5571                	li	a0,-4
ffffffffc0201ac6:	bf61                	j	ffffffffc0201a5e <page_insert+0x64>
ffffffffc0201ac8:	b3bff0ef          	jal	ra,ffffffffc0201602 <pa2page.part.4>

ffffffffc0201acc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201acc:	00003797          	auipc	a5,0x3
ffffffffc0201ad0:	30478793          	addi	a5,a5,772 # ffffffffc0204dd0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ad4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ad6:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ad8:	00003517          	auipc	a0,0x3
ffffffffc0201adc:	40850513          	addi	a0,a0,1032 # ffffffffc0204ee0 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201ae0:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ae2:	0000f717          	auipc	a4,0xf
ffffffffc0201ae6:	9af73723          	sd	a5,-1618(a4) # ffffffffc0210490 <pmm_manager>
void pmm_init(void) {
ffffffffc0201aea:	e8a2                	sd	s0,80(sp)
ffffffffc0201aec:	e4a6                	sd	s1,72(sp)
ffffffffc0201aee:	e0ca                	sd	s2,64(sp)
ffffffffc0201af0:	fc4e                	sd	s3,56(sp)
ffffffffc0201af2:	f852                	sd	s4,48(sp)
ffffffffc0201af4:	f456                	sd	s5,40(sp)
ffffffffc0201af6:	f05a                	sd	s6,32(sp)
ffffffffc0201af8:	ec5e                	sd	s7,24(sp)
ffffffffc0201afa:	e862                	sd	s8,16(sp)
ffffffffc0201afc:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201afe:	0000f417          	auipc	s0,0xf
ffffffffc0201b02:	99240413          	addi	s0,s0,-1646 # ffffffffc0210490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b06:	db8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b0a:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b0c:	49c5                	li	s3,17
ffffffffc0201b0e:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b12:	679c                	ld	a5,8(a5)
ffffffffc0201b14:	0000f497          	auipc	s1,0xf
ffffffffc0201b18:	94448493          	addi	s1,s1,-1724 # ffffffffc0210458 <npage>
ffffffffc0201b1c:	0000f917          	auipc	s2,0xf
ffffffffc0201b20:	98c90913          	addi	s2,s2,-1652 # ffffffffc02104a8 <pages>
ffffffffc0201b24:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b26:	57f5                	li	a5,-3
ffffffffc0201b28:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b2a:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b2e:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b32:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b36:	00003517          	auipc	a0,0x3
ffffffffc0201b3a:	3c250513          	addi	a0,a0,962 # ffffffffc0204ef8 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b3e:	0000f717          	auipc	a4,0xf
ffffffffc0201b42:	94f73d23          	sd	a5,-1702(a4) # ffffffffc0210498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b46:	d78fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b4a:	00003517          	auipc	a0,0x3
ffffffffc0201b4e:	3de50513          	addi	a0,a0,990 # ffffffffc0204f28 <default_pmm_manager+0x158>
ffffffffc0201b52:	d6cfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b56:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201b5a:	16fd                	addi	a3,a3,-1
ffffffffc0201b5c:	015a1613          	slli	a2,s4,0x15
ffffffffc0201b60:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b64:	00003517          	auipc	a0,0x3
ffffffffc0201b68:	3dc50513          	addi	a0,a0,988 # ffffffffc0204f40 <default_pmm_manager+0x170>
ffffffffc0201b6c:	d52fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b70:	777d                	lui	a4,0xfffff
ffffffffc0201b72:	00010797          	auipc	a5,0x10
ffffffffc0201b76:	a2578793          	addi	a5,a5,-1499 # ffffffffc0211597 <end+0xfff>
ffffffffc0201b7a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201b7c:	00088737          	lui	a4,0x88
ffffffffc0201b80:	0000f697          	auipc	a3,0xf
ffffffffc0201b84:	8ce6bc23          	sd	a4,-1832(a3) # ffffffffc0210458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b88:	0000f717          	auipc	a4,0xf
ffffffffc0201b8c:	92f73023          	sd	a5,-1760(a4) # ffffffffc02104a8 <pages>
ffffffffc0201b90:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b92:	4701                	li	a4,0
ffffffffc0201b94:	4585                	li	a1,1
ffffffffc0201b96:	fff80637          	lui	a2,0xfff80
ffffffffc0201b9a:	a019                	j	ffffffffc0201ba0 <pmm_init+0xd4>
ffffffffc0201b9c:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201ba0:	97b6                	add	a5,a5,a3
ffffffffc0201ba2:	07a1                	addi	a5,a5,8
ffffffffc0201ba4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201ba8:	609c                	ld	a5,0(s1)
ffffffffc0201baa:	0705                	addi	a4,a4,1
ffffffffc0201bac:	04868693          	addi	a3,a3,72
ffffffffc0201bb0:	00c78533          	add	a0,a5,a2
ffffffffc0201bb4:	fea764e3          	bltu	a4,a0,ffffffffc0201b9c <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bb8:	00093503          	ld	a0,0(s2)
ffffffffc0201bbc:	00379693          	slli	a3,a5,0x3
ffffffffc0201bc0:	96be                	add	a3,a3,a5
ffffffffc0201bc2:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bc6:	972a                	add	a4,a4,a0
ffffffffc0201bc8:	068e                	slli	a3,a3,0x3
ffffffffc0201bca:	96ba                	add	a3,a3,a4
ffffffffc0201bcc:	c0200737          	lui	a4,0xc0200
ffffffffc0201bd0:	58e6e863          	bltu	a3,a4,ffffffffc0202160 <pmm_init+0x694>
ffffffffc0201bd4:	0000f997          	auipc	s3,0xf
ffffffffc0201bd8:	8c498993          	addi	s3,s3,-1852 # ffffffffc0210498 <va_pa_offset>
ffffffffc0201bdc:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201be0:	45c5                	li	a1,17
ffffffffc0201be2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201be4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201be6:	44b6ed63          	bltu	a3,a1,ffffffffc0202040 <pmm_init+0x574>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bea:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bec:	0000f417          	auipc	s0,0xf
ffffffffc0201bf0:	86440413          	addi	s0,s0,-1948 # ffffffffc0210450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bf4:	7b9c                	ld	a5,48(a5)
ffffffffc0201bf6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201bf8:	00003517          	auipc	a0,0x3
ffffffffc0201bfc:	39850513          	addi	a0,a0,920 # ffffffffc0204f90 <default_pmm_manager+0x1c0>
ffffffffc0201c00:	cbefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c04:	00006697          	auipc	a3,0x6
ffffffffc0201c08:	3fc68693          	addi	a3,a3,1020 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201c0c:	0000f797          	auipc	a5,0xf
ffffffffc0201c10:	84d7b223          	sd	a3,-1980(a5) # ffffffffc0210450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c14:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c18:	0ef6eae3          	bltu	a3,a5,ffffffffc020250c <pmm_init+0xa40>
ffffffffc0201c1c:	0009b783          	ld	a5,0(s3)
ffffffffc0201c20:	8e9d                	sub	a3,a3,a5
ffffffffc0201c22:	0000f797          	auipc	a5,0xf
ffffffffc0201c26:	86d7bf23          	sd	a3,-1922(a5) # ffffffffc02104a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c2a:	ac3ff0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c2e:	6098                	ld	a4,0(s1)
ffffffffc0201c30:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c34:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c36:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c38:	0ae7eae3          	bltu	a5,a4,ffffffffc02024ec <pmm_init+0xa20>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c3c:	6008                	ld	a0,0(s0)
ffffffffc0201c3e:	4c050163          	beqz	a0,ffffffffc0202100 <pmm_init+0x634>
ffffffffc0201c42:	03451793          	slli	a5,a0,0x34
ffffffffc0201c46:	4a079d63          	bnez	a5,ffffffffc0202100 <pmm_init+0x634>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c4a:	4601                	li	a2,0
ffffffffc0201c4c:	4581                	li	a1,0
ffffffffc0201c4e:	cddff0ef          	jal	ra,ffffffffc020192a <get_page>
ffffffffc0201c52:	4c051763          	bnez	a0,ffffffffc0202120 <pmm_init+0x654>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c56:	4505                	li	a0,1
ffffffffc0201c58:	9c7ff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0201c5c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c5e:	6008                	ld	a0,0(s0)
ffffffffc0201c60:	4681                	li	a3,0
ffffffffc0201c62:	4601                	li	a2,0
ffffffffc0201c64:	85d6                	mv	a1,s5
ffffffffc0201c66:	d95ff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc0201c6a:	52051763          	bnez	a0,ffffffffc0202198 <pmm_init+0x6cc>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c6e:	6008                	ld	a0,0(s0)
ffffffffc0201c70:	4601                	li	a2,0
ffffffffc0201c72:	4581                	li	a1,0
ffffffffc0201c74:	ab9ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201c78:	50050063          	beqz	a0,ffffffffc0202178 <pmm_init+0x6ac>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c7c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c7e:	0017f713          	andi	a4,a5,1
ffffffffc0201c82:	46070363          	beqz	a4,ffffffffc02020e8 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201c86:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c88:	078a                	slli	a5,a5,0x2
ffffffffc0201c8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c8c:	44c7f063          	bgeu	a5,a2,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c90:	fff80737          	lui	a4,0xfff80
ffffffffc0201c94:	97ba                	add	a5,a5,a4
ffffffffc0201c96:	00379713          	slli	a4,a5,0x3
ffffffffc0201c9a:	00093683          	ld	a3,0(s2)
ffffffffc0201c9e:	97ba                	add	a5,a5,a4
ffffffffc0201ca0:	078e                	slli	a5,a5,0x3
ffffffffc0201ca2:	97b6                	add	a5,a5,a3
ffffffffc0201ca4:	5efa9463          	bne	s5,a5,ffffffffc020228c <pmm_init+0x7c0>
    assert(page_ref(p1) == 1);
ffffffffc0201ca8:	000aab83          	lw	s7,0(s5)
ffffffffc0201cac:	4785                	li	a5,1
ffffffffc0201cae:	5afb9f63          	bne	s7,a5,ffffffffc020226c <pmm_init+0x7a0>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cb2:	6008                	ld	a0,0(s0)
ffffffffc0201cb4:	76fd                	lui	a3,0xfffff
ffffffffc0201cb6:	611c                	ld	a5,0(a0)
ffffffffc0201cb8:	078a                	slli	a5,a5,0x2
ffffffffc0201cba:	8ff5                	and	a5,a5,a3
ffffffffc0201cbc:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201cc0:	58c77963          	bgeu	a4,a2,ffffffffc0202252 <pmm_init+0x786>
ffffffffc0201cc4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cc8:	97e2                	add	a5,a5,s8
ffffffffc0201cca:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7defa68>
ffffffffc0201cce:	0b0a                	slli	s6,s6,0x2
ffffffffc0201cd0:	00db7b33          	and	s6,s6,a3
ffffffffc0201cd4:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201cd8:	56c7f063          	bgeu	a5,a2,ffffffffc0202238 <pmm_init+0x76c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cdc:	4601                	li	a2,0
ffffffffc0201cde:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce0:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ce2:	a4bff0ef          	jal	ra,ffffffffc020172c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce6:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ce8:	53651863          	bne	a0,s6,ffffffffc0202218 <pmm_init+0x74c>

    p2 = alloc_page();
ffffffffc0201cec:	4505                	li	a0,1
ffffffffc0201cee:	931ff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0201cf2:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201cf4:	6008                	ld	a0,0(s0)
ffffffffc0201cf6:	46d1                	li	a3,20
ffffffffc0201cf8:	6605                	lui	a2,0x1
ffffffffc0201cfa:	85da                	mv	a1,s6
ffffffffc0201cfc:	cffff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc0201d00:	4e051c63          	bnez	a0,ffffffffc02021f8 <pmm_init+0x72c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d04:	6008                	ld	a0,0(s0)
ffffffffc0201d06:	4601                	li	a2,0
ffffffffc0201d08:	6585                	lui	a1,0x1
ffffffffc0201d0a:	a23ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201d0e:	4c050563          	beqz	a0,ffffffffc02021d8 <pmm_init+0x70c>
    assert(*ptep & PTE_U);
ffffffffc0201d12:	611c                	ld	a5,0(a0)
ffffffffc0201d14:	0107f713          	andi	a4,a5,16
ffffffffc0201d18:	4a070063          	beqz	a4,ffffffffc02021b8 <pmm_init+0x6ec>
    assert(*ptep & PTE_W);
ffffffffc0201d1c:	8b91                	andi	a5,a5,4
ffffffffc0201d1e:	66078763          	beqz	a5,ffffffffc020238c <pmm_init+0x8c0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d22:	6008                	ld	a0,0(s0)
ffffffffc0201d24:	611c                	ld	a5,0(a0)
ffffffffc0201d26:	8bc1                	andi	a5,a5,16
ffffffffc0201d28:	64078263          	beqz	a5,ffffffffc020236c <pmm_init+0x8a0>
    assert(page_ref(p2) == 1);
ffffffffc0201d2c:	000b2783          	lw	a5,0(s6)
ffffffffc0201d30:	61779e63          	bne	a5,s7,ffffffffc020234c <pmm_init+0x880>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d34:	4681                	li	a3,0
ffffffffc0201d36:	6605                	lui	a2,0x1
ffffffffc0201d38:	85d6                	mv	a1,s5
ffffffffc0201d3a:	cc1ff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc0201d3e:	5e051763          	bnez	a0,ffffffffc020232c <pmm_init+0x860>
    assert(page_ref(p1) == 2);
ffffffffc0201d42:	000aa703          	lw	a4,0(s5)
ffffffffc0201d46:	4789                	li	a5,2
ffffffffc0201d48:	5cf71263          	bne	a4,a5,ffffffffc020230c <pmm_init+0x840>
    assert(page_ref(p2) == 0);
ffffffffc0201d4c:	000b2783          	lw	a5,0(s6)
ffffffffc0201d50:	58079e63          	bnez	a5,ffffffffc02022ec <pmm_init+0x820>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d54:	6008                	ld	a0,0(s0)
ffffffffc0201d56:	4601                	li	a2,0
ffffffffc0201d58:	6585                	lui	a1,0x1
ffffffffc0201d5a:	9d3ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201d5e:	56050763          	beqz	a0,ffffffffc02022cc <pmm_init+0x800>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d62:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d64:	0016f793          	andi	a5,a3,1
ffffffffc0201d68:	38078063          	beqz	a5,ffffffffc02020e8 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201d6c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d6e:	00269793          	slli	a5,a3,0x2
ffffffffc0201d72:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d74:	34e7fc63          	bgeu	a5,a4,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d78:	fff80737          	lui	a4,0xfff80
ffffffffc0201d7c:	97ba                	add	a5,a5,a4
ffffffffc0201d7e:	00379713          	slli	a4,a5,0x3
ffffffffc0201d82:	00093603          	ld	a2,0(s2)
ffffffffc0201d86:	97ba                	add	a5,a5,a4
ffffffffc0201d88:	078e                	slli	a5,a5,0x3
ffffffffc0201d8a:	97b2                	add	a5,a5,a2
ffffffffc0201d8c:	52fa9063          	bne	s5,a5,ffffffffc02022ac <pmm_init+0x7e0>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d90:	8ac1                	andi	a3,a3,16
ffffffffc0201d92:	6e069d63          	bnez	a3,ffffffffc020248c <pmm_init+0x9c0>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201d96:	6008                	ld	a0,0(s0)
ffffffffc0201d98:	4581                	li	a1,0
ffffffffc0201d9a:	befff0ef          	jal	ra,ffffffffc0201988 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201d9e:	000aa703          	lw	a4,0(s5)
ffffffffc0201da2:	4785                	li	a5,1
ffffffffc0201da4:	6cf71463          	bne	a4,a5,ffffffffc020246c <pmm_init+0x9a0>
    assert(page_ref(p2) == 0);
ffffffffc0201da8:	000b2783          	lw	a5,0(s6)
ffffffffc0201dac:	6a079063          	bnez	a5,ffffffffc020244c <pmm_init+0x980>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201db0:	6008                	ld	a0,0(s0)
ffffffffc0201db2:	6585                	lui	a1,0x1
ffffffffc0201db4:	bd5ff0ef          	jal	ra,ffffffffc0201988 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201db8:	000aa783          	lw	a5,0(s5)
ffffffffc0201dbc:	66079863          	bnez	a5,ffffffffc020242c <pmm_init+0x960>
    assert(page_ref(p2) == 0);
ffffffffc0201dc0:	000b2783          	lw	a5,0(s6)
ffffffffc0201dc4:	70079463          	bnez	a5,ffffffffc02024cc <pmm_init+0xa00>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dc8:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201dcc:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dce:	000b3783          	ld	a5,0(s6)
ffffffffc0201dd2:	078a                	slli	a5,a5,0x2
ffffffffc0201dd4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dd6:	2ec7fb63          	bgeu	a5,a2,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dda:	fff80737          	lui	a4,0xfff80
ffffffffc0201dde:	973e                	add	a4,a4,a5
ffffffffc0201de0:	00371793          	slli	a5,a4,0x3
ffffffffc0201de4:	00093803          	ld	a6,0(s2)
ffffffffc0201de8:	97ba                	add	a5,a5,a4
ffffffffc0201dea:	078e                	slli	a5,a5,0x3
ffffffffc0201dec:	00f80733          	add	a4,a6,a5
ffffffffc0201df0:	4314                	lw	a3,0(a4)
ffffffffc0201df2:	4705                	li	a4,1
ffffffffc0201df4:	6ae69c63          	bne	a3,a4,ffffffffc02024ac <pmm_init+0x9e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201df8:	00003a97          	auipc	s5,0x3
ffffffffc0201dfc:	c28a8a93          	addi	s5,s5,-984 # ffffffffc0204a20 <commands+0x858>
ffffffffc0201e00:	000ab703          	ld	a4,0(s5)
ffffffffc0201e04:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e08:	00080bb7          	lui	s7,0x80
ffffffffc0201e0c:	02e686b3          	mul	a3,a3,a4
ffffffffc0201e10:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e12:	00c69793          	slli	a5,a3,0xc
ffffffffc0201e16:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e18:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e1a:	2ac7fb63          	bgeu	a5,a2,ffffffffc02020d0 <pmm_init+0x604>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e1e:	0009b703          	ld	a4,0(s3)
ffffffffc0201e22:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e24:	629c                	ld	a5,0(a3)
ffffffffc0201e26:	078a                	slli	a5,a5,0x2
ffffffffc0201e28:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	2ac7f163          	bgeu	a5,a2,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e2e:	417787b3          	sub	a5,a5,s7
ffffffffc0201e32:	00379513          	slli	a0,a5,0x3
ffffffffc0201e36:	97aa                	add	a5,a5,a0
ffffffffc0201e38:	00379513          	slli	a0,a5,0x3
ffffffffc0201e3c:	9542                	add	a0,a0,a6
ffffffffc0201e3e:	4585                	li	a1,1
ffffffffc0201e40:	867ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e44:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201e48:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4a:	050a                	slli	a0,a0,0x2
ffffffffc0201e4c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e4e:	26f57f63          	bgeu	a0,a5,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e52:	417507b3          	sub	a5,a0,s7
ffffffffc0201e56:	00379513          	slli	a0,a5,0x3
ffffffffc0201e5a:	00093703          	ld	a4,0(s2)
ffffffffc0201e5e:	953e                	add	a0,a0,a5
ffffffffc0201e60:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201e62:	4585                	li	a1,1
ffffffffc0201e64:	953a                	add	a0,a0,a4
ffffffffc0201e66:	841ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201e6a:	601c                	ld	a5,0(s0)
ffffffffc0201e6c:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e70:	87dff0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc0201e74:	2caa1663          	bne	s4,a0,ffffffffc0202140 <pmm_init+0x674>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e78:	00003517          	auipc	a0,0x3
ffffffffc0201e7c:	42850513          	addi	a0,a0,1064 # ffffffffc02052a0 <default_pmm_manager+0x4d0>
ffffffffc0201e80:	a3efe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201e84:	869ff0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201e88:	6098                	ld	a4,0(s1)
ffffffffc0201e8a:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201e8e:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201e90:	00c71693          	slli	a3,a4,0xc
ffffffffc0201e94:	1cd7fd63          	bgeu	a5,a3,ffffffffc020206e <pmm_init+0x5a2>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201e98:	83b1                	srli	a5,a5,0xc
ffffffffc0201e9a:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201e9c:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ea0:	1ce7f963          	bgeu	a5,a4,ffffffffc0202072 <pmm_init+0x5a6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ea4:	7c7d                	lui	s8,0xfffff
ffffffffc0201ea6:	6b85                	lui	s7,0x1
ffffffffc0201ea8:	a029                	j	ffffffffc0201eb2 <pmm_init+0x3e6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201eaa:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201eae:	1cf77263          	bgeu	a4,a5,ffffffffc0202072 <pmm_init+0x5a6>
ffffffffc0201eb2:	0009b583          	ld	a1,0(s3)
ffffffffc0201eb6:	4601                	li	a2,0
ffffffffc0201eb8:	95d2                	add	a1,a1,s4
ffffffffc0201eba:	873ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201ebe:	1c050763          	beqz	a0,ffffffffc020208c <pmm_init+0x5c0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ec2:	611c                	ld	a5,0(a0)
ffffffffc0201ec4:	078a                	slli	a5,a5,0x2
ffffffffc0201ec6:	0187f7b3          	and	a5,a5,s8
ffffffffc0201eca:	1f479163          	bne	a5,s4,ffffffffc02020ac <pmm_init+0x5e0>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ece:	609c                	ld	a5,0(s1)
ffffffffc0201ed0:	9a5e                	add	s4,s4,s7
ffffffffc0201ed2:	6008                	ld	a0,0(s0)
ffffffffc0201ed4:	00c79713          	slli	a4,a5,0xc
ffffffffc0201ed8:	fcea69e3          	bltu	s4,a4,ffffffffc0201eaa <pmm_init+0x3de>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201edc:	611c                	ld	a5,0(a0)
ffffffffc0201ede:	6a079363          	bnez	a5,ffffffffc0202584 <pmm_init+0xab8>

    struct Page *p;
    p = alloc_page();
ffffffffc0201ee2:	4505                	li	a0,1
ffffffffc0201ee4:	f3aff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc0201ee8:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201eea:	6008                	ld	a0,0(s0)
ffffffffc0201eec:	4699                	li	a3,6
ffffffffc0201eee:	10000613          	li	a2,256
ffffffffc0201ef2:	85d2                	mv	a1,s4
ffffffffc0201ef4:	b07ff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc0201ef8:	66051663          	bnez	a0,ffffffffc0202564 <pmm_init+0xa98>
    assert(page_ref(p) == 1);
ffffffffc0201efc:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f00:	4785                	li	a5,1
ffffffffc0201f02:	64f71163          	bne	a4,a5,ffffffffc0202544 <pmm_init+0xa78>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f06:	6008                	ld	a0,0(s0)
ffffffffc0201f08:	6b85                	lui	s7,0x1
ffffffffc0201f0a:	4699                	li	a3,6
ffffffffc0201f0c:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f10:	85d2                	mv	a1,s4
ffffffffc0201f12:	ae9ff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc0201f16:	60051763          	bnez	a0,ffffffffc0202524 <pmm_init+0xa58>
    assert(page_ref(p) == 2);
ffffffffc0201f1a:	000a2703          	lw	a4,0(s4)
ffffffffc0201f1e:	4789                	li	a5,2
ffffffffc0201f20:	4ef71663          	bne	a4,a5,ffffffffc020240c <pmm_init+0x940>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f24:	00003597          	auipc	a1,0x3
ffffffffc0201f28:	4b458593          	addi	a1,a1,1204 # ffffffffc02053d8 <default_pmm_manager+0x608>
ffffffffc0201f2c:	10000513          	li	a0,256
ffffffffc0201f30:	0ea020ef          	jal	ra,ffffffffc020401a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f34:	100b8593          	addi	a1,s7,256
ffffffffc0201f38:	10000513          	li	a0,256
ffffffffc0201f3c:	0f0020ef          	jal	ra,ffffffffc020402c <strcmp>
ffffffffc0201f40:	4a051663          	bnez	a0,ffffffffc02023ec <pmm_init+0x920>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f44:	00093683          	ld	a3,0(s2)
ffffffffc0201f48:	000abc83          	ld	s9,0(s5)
ffffffffc0201f4c:	00080c37          	lui	s8,0x80
ffffffffc0201f50:	40da06b3          	sub	a3,s4,a3
ffffffffc0201f54:	868d                	srai	a3,a3,0x3
ffffffffc0201f56:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f5a:	5afd                	li	s5,-1
ffffffffc0201f5c:	609c                	ld	a5,0(s1)
ffffffffc0201f5e:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f62:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f64:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f68:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f6a:	16f77363          	bgeu	a4,a5,ffffffffc02020d0 <pmm_init+0x604>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f6e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f72:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f76:	96be                	add	a3,a3,a5
ffffffffc0201f78:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeeb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f7c:	05a020ef          	jal	ra,ffffffffc0203fd6 <strlen>
ffffffffc0201f80:	44051663          	bnez	a0,ffffffffc02023cc <pmm_init+0x900>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f84:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201f88:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f8a:	000bb783          	ld	a5,0(s7)
ffffffffc0201f8e:	078a                	slli	a5,a5,0x2
ffffffffc0201f90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f92:	12e7fd63          	bgeu	a5,a4,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f96:	418787b3          	sub	a5,a5,s8
ffffffffc0201f9a:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f9e:	96be                	add	a3,a3,a5
ffffffffc0201fa0:	039686b3          	mul	a3,a3,s9
ffffffffc0201fa4:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fa6:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201faa:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fac:	12eaf263          	bgeu	s5,a4,ffffffffc02020d0 <pmm_init+0x604>
ffffffffc0201fb0:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201fb4:	4585                	li	a1,1
ffffffffc0201fb6:	8552                	mv	a0,s4
ffffffffc0201fb8:	99b6                	add	s3,s3,a3
ffffffffc0201fba:	eecff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fbe:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201fc2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fc4:	078a                	slli	a5,a5,0x2
ffffffffc0201fc6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fc8:	10e7f263          	bgeu	a5,a4,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fcc:	fff809b7          	lui	s3,0xfff80
ffffffffc0201fd0:	97ce                	add	a5,a5,s3
ffffffffc0201fd2:	00379513          	slli	a0,a5,0x3
ffffffffc0201fd6:	00093703          	ld	a4,0(s2)
ffffffffc0201fda:	97aa                	add	a5,a5,a0
ffffffffc0201fdc:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0201fe0:	953a                	add	a0,a0,a4
ffffffffc0201fe2:	4585                	li	a1,1
ffffffffc0201fe4:	ec2ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe8:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201fec:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fee:	050a                	slli	a0,a0,0x2
ffffffffc0201ff0:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ff2:	0cf57d63          	bgeu	a0,a5,ffffffffc02020cc <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff6:	013507b3          	add	a5,a0,s3
ffffffffc0201ffa:	00379513          	slli	a0,a5,0x3
ffffffffc0201ffe:	00093703          	ld	a4,0(s2)
ffffffffc0202002:	953e                	add	a0,a0,a5
ffffffffc0202004:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202006:	4585                	li	a1,1
ffffffffc0202008:	953a                	add	a0,a0,a4
ffffffffc020200a:	e9cff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020200e:	601c                	ld	a5,0(s0)
ffffffffc0202010:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202014:	ed8ff0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc0202018:	38ab1a63          	bne	s6,a0,ffffffffc02023ac <pmm_init+0x8e0>
}
ffffffffc020201c:	6446                	ld	s0,80(sp)
ffffffffc020201e:	60e6                	ld	ra,88(sp)
ffffffffc0202020:	64a6                	ld	s1,72(sp)
ffffffffc0202022:	6906                	ld	s2,64(sp)
ffffffffc0202024:	79e2                	ld	s3,56(sp)
ffffffffc0202026:	7a42                	ld	s4,48(sp)
ffffffffc0202028:	7aa2                	ld	s5,40(sp)
ffffffffc020202a:	7b02                	ld	s6,32(sp)
ffffffffc020202c:	6be2                	ld	s7,24(sp)
ffffffffc020202e:	6c42                	ld	s8,16(sp)
ffffffffc0202030:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202032:	00003517          	auipc	a0,0x3
ffffffffc0202036:	41e50513          	addi	a0,a0,1054 # ffffffffc0205450 <default_pmm_manager+0x680>
}
ffffffffc020203a:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020203c:	882fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202040:	6705                	lui	a4,0x1
ffffffffc0202042:	177d                	addi	a4,a4,-1
ffffffffc0202044:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202046:	00c6d713          	srli	a4,a3,0xc
ffffffffc020204a:	08f77163          	bgeu	a4,a5,ffffffffc02020cc <pmm_init+0x600>
    pmm_manager->init_memmap(base, n);
ffffffffc020204e:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202052:	9732                	add	a4,a4,a2
ffffffffc0202054:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202058:	767d                	lui	a2,0xfffff
ffffffffc020205a:	8ef1                	and	a3,a3,a2
ffffffffc020205c:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020205e:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202062:	8d95                	sub	a1,a1,a3
ffffffffc0202064:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202066:	81b1                	srli	a1,a1,0xc
ffffffffc0202068:	953e                	add	a0,a0,a5
ffffffffc020206a:	9702                	jalr	a4
ffffffffc020206c:	bebd                	j	ffffffffc0201bea <pmm_init+0x11e>
ffffffffc020206e:	6008                	ld	a0,0(s0)
ffffffffc0202070:	b5b5                	j	ffffffffc0201edc <pmm_init+0x410>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202072:	86d2                	mv	a3,s4
ffffffffc0202074:	00003617          	auipc	a2,0x3
ffffffffc0202078:	dac60613          	addi	a2,a2,-596 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc020207c:	1cd00593          	li	a1,461
ffffffffc0202080:	00003517          	auipc	a0,0x3
ffffffffc0202084:	dc850513          	addi	a0,a0,-568 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202088:	ae8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc020208c:	00003697          	auipc	a3,0x3
ffffffffc0202090:	23468693          	addi	a3,a3,564 # ffffffffc02052c0 <default_pmm_manager+0x4f0>
ffffffffc0202094:	00003617          	auipc	a2,0x3
ffffffffc0202098:	9a460613          	addi	a2,a2,-1628 # ffffffffc0204a38 <commands+0x870>
ffffffffc020209c:	1cd00593          	li	a1,461
ffffffffc02020a0:	00003517          	auipc	a0,0x3
ffffffffc02020a4:	da850513          	addi	a0,a0,-600 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02020a8:	ac8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02020ac:	00003697          	auipc	a3,0x3
ffffffffc02020b0:	25468693          	addi	a3,a3,596 # ffffffffc0205300 <default_pmm_manager+0x530>
ffffffffc02020b4:	00003617          	auipc	a2,0x3
ffffffffc02020b8:	98460613          	addi	a2,a2,-1660 # ffffffffc0204a38 <commands+0x870>
ffffffffc02020bc:	1ce00593          	li	a1,462
ffffffffc02020c0:	00003517          	auipc	a0,0x3
ffffffffc02020c4:	d8850513          	addi	a0,a0,-632 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02020c8:	aa8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02020cc:	d36ff0ef          	jal	ra,ffffffffc0201602 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020d0:	00003617          	auipc	a2,0x3
ffffffffc02020d4:	d5060613          	addi	a2,a2,-688 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc02020d8:	06a00593          	li	a1,106
ffffffffc02020dc:	00003517          	auipc	a0,0x3
ffffffffc02020e0:	ddc50513          	addi	a0,a0,-548 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc02020e4:	a8cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02020e8:	00003617          	auipc	a2,0x3
ffffffffc02020ec:	fa860613          	addi	a2,a2,-88 # ffffffffc0205090 <default_pmm_manager+0x2c0>
ffffffffc02020f0:	07000593          	li	a1,112
ffffffffc02020f4:	00003517          	auipc	a0,0x3
ffffffffc02020f8:	dc450513          	addi	a0,a0,-572 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc02020fc:	a74fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202100:	00003697          	auipc	a3,0x3
ffffffffc0202104:	ed068693          	addi	a3,a3,-304 # ffffffffc0204fd0 <default_pmm_manager+0x200>
ffffffffc0202108:	00003617          	auipc	a2,0x3
ffffffffc020210c:	93060613          	addi	a2,a2,-1744 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202110:	19300593          	li	a1,403
ffffffffc0202114:	00003517          	auipc	a0,0x3
ffffffffc0202118:	d3450513          	addi	a0,a0,-716 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020211c:	a54fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202120:	00003697          	auipc	a3,0x3
ffffffffc0202124:	ee868693          	addi	a3,a3,-280 # ffffffffc0205008 <default_pmm_manager+0x238>
ffffffffc0202128:	00003617          	auipc	a2,0x3
ffffffffc020212c:	91060613          	addi	a2,a2,-1776 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202130:	19400593          	li	a1,404
ffffffffc0202134:	00003517          	auipc	a0,0x3
ffffffffc0202138:	d1450513          	addi	a0,a0,-748 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020213c:	a34fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202140:	00003697          	auipc	a3,0x3
ffffffffc0202144:	14068693          	addi	a3,a3,320 # ffffffffc0205280 <default_pmm_manager+0x4b0>
ffffffffc0202148:	00003617          	auipc	a2,0x3
ffffffffc020214c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202150:	1c000593          	li	a1,448
ffffffffc0202154:	00003517          	auipc	a0,0x3
ffffffffc0202158:	cf450513          	addi	a0,a0,-780 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020215c:	a14fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202160:	00003617          	auipc	a2,0x3
ffffffffc0202164:	e0860613          	addi	a2,a2,-504 # ffffffffc0204f68 <default_pmm_manager+0x198>
ffffffffc0202168:	07700593          	li	a1,119
ffffffffc020216c:	00003517          	auipc	a0,0x3
ffffffffc0202170:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202174:	9fcfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202178:	00003697          	auipc	a3,0x3
ffffffffc020217c:	ee868693          	addi	a3,a3,-280 # ffffffffc0205060 <default_pmm_manager+0x290>
ffffffffc0202180:	00003617          	auipc	a2,0x3
ffffffffc0202184:	8b860613          	addi	a2,a2,-1864 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202188:	19a00593          	li	a1,410
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	cbc50513          	addi	a0,a0,-836 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202194:	9dcfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	e9868693          	addi	a3,a3,-360 # ffffffffc0205030 <default_pmm_manager+0x260>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	89860613          	addi	a2,a2,-1896 # ffffffffc0204a38 <commands+0x870>
ffffffffc02021a8:	19800593          	li	a1,408
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	c9c50513          	addi	a0,a0,-868 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02021b4:	9bcfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	fc068693          	addi	a3,a3,-64 # ffffffffc0205178 <default_pmm_manager+0x3a8>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	87860613          	addi	a2,a2,-1928 # ffffffffc0204a38 <commands+0x870>
ffffffffc02021c8:	1a500593          	li	a1,421
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	c7c50513          	addi	a0,a0,-900 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02021d4:	99cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	f7068693          	addi	a3,a3,-144 # ffffffffc0205148 <default_pmm_manager+0x378>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	85860613          	addi	a2,a2,-1960 # ffffffffc0204a38 <commands+0x870>
ffffffffc02021e8:	1a400593          	li	a1,420
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	c5c50513          	addi	a0,a0,-932 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02021f4:	97cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	f1868693          	addi	a3,a3,-232 # ffffffffc0205110 <default_pmm_manager+0x340>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	83860613          	addi	a2,a2,-1992 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202208:	1a300593          	li	a1,419
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	c3c50513          	addi	a0,a0,-964 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202214:	95cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	ed068693          	addi	a3,a3,-304 # ffffffffc02050e8 <default_pmm_manager+0x318>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	81860613          	addi	a2,a2,-2024 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202228:	1a000593          	li	a1,416
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202234:	93cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202238:	86da                	mv	a3,s6
ffffffffc020223a:	00003617          	auipc	a2,0x3
ffffffffc020223e:	be660613          	addi	a2,a2,-1050 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc0202242:	19f00593          	li	a1,415
ffffffffc0202246:	00003517          	auipc	a0,0x3
ffffffffc020224a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020224e:	922fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202252:	86be                	mv	a3,a5
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc020225c:	19e00593          	li	a1,414
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	be850513          	addi	a0,a0,-1048 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202268:	908fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020226c:	00003697          	auipc	a3,0x3
ffffffffc0202270:	e6468693          	addi	a3,a3,-412 # ffffffffc02050d0 <default_pmm_manager+0x300>
ffffffffc0202274:	00002617          	auipc	a2,0x2
ffffffffc0202278:	7c460613          	addi	a2,a2,1988 # ffffffffc0204a38 <commands+0x870>
ffffffffc020227c:	19c00593          	li	a1,412
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	bc850513          	addi	a0,a0,-1080 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202288:	8e8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	e2c68693          	addi	a3,a3,-468 # ffffffffc02050b8 <default_pmm_manager+0x2e8>
ffffffffc0202294:	00002617          	auipc	a2,0x2
ffffffffc0202298:	7a460613          	addi	a2,a2,1956 # ffffffffc0204a38 <commands+0x870>
ffffffffc020229c:	19b00593          	li	a1,411
ffffffffc02022a0:	00003517          	auipc	a0,0x3
ffffffffc02022a4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02022a8:	8c8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022ac:	00003697          	auipc	a3,0x3
ffffffffc02022b0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02050b8 <default_pmm_manager+0x2e8>
ffffffffc02022b4:	00002617          	auipc	a2,0x2
ffffffffc02022b8:	78460613          	addi	a2,a2,1924 # ffffffffc0204a38 <commands+0x870>
ffffffffc02022bc:	1ae00593          	li	a1,430
ffffffffc02022c0:	00003517          	auipc	a0,0x3
ffffffffc02022c4:	b8850513          	addi	a0,a0,-1144 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02022c8:	8a8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022cc:	00003697          	auipc	a3,0x3
ffffffffc02022d0:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205148 <default_pmm_manager+0x378>
ffffffffc02022d4:	00002617          	auipc	a2,0x2
ffffffffc02022d8:	76460613          	addi	a2,a2,1892 # ffffffffc0204a38 <commands+0x870>
ffffffffc02022dc:	1ad00593          	li	a1,429
ffffffffc02022e0:	00003517          	auipc	a0,0x3
ffffffffc02022e4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02022e8:	888fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02022ec:	00003697          	auipc	a3,0x3
ffffffffc02022f0:	f2468693          	addi	a3,a3,-220 # ffffffffc0205210 <default_pmm_manager+0x440>
ffffffffc02022f4:	00002617          	auipc	a2,0x2
ffffffffc02022f8:	74460613          	addi	a2,a2,1860 # ffffffffc0204a38 <commands+0x870>
ffffffffc02022fc:	1ac00593          	li	a1,428
ffffffffc0202300:	00003517          	auipc	a0,0x3
ffffffffc0202304:	b4850513          	addi	a0,a0,-1208 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202308:	868fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020230c:	00003697          	auipc	a3,0x3
ffffffffc0202310:	eec68693          	addi	a3,a3,-276 # ffffffffc02051f8 <default_pmm_manager+0x428>
ffffffffc0202314:	00002617          	auipc	a2,0x2
ffffffffc0202318:	72460613          	addi	a2,a2,1828 # ffffffffc0204a38 <commands+0x870>
ffffffffc020231c:	1ab00593          	li	a1,427
ffffffffc0202320:	00003517          	auipc	a0,0x3
ffffffffc0202324:	b2850513          	addi	a0,a0,-1240 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202328:	848fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020232c:	00003697          	auipc	a3,0x3
ffffffffc0202330:	e9c68693          	addi	a3,a3,-356 # ffffffffc02051c8 <default_pmm_manager+0x3f8>
ffffffffc0202334:	00002617          	auipc	a2,0x2
ffffffffc0202338:	70460613          	addi	a2,a2,1796 # ffffffffc0204a38 <commands+0x870>
ffffffffc020233c:	1aa00593          	li	a1,426
ffffffffc0202340:	00003517          	auipc	a0,0x3
ffffffffc0202344:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202348:	828fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020234c:	00003697          	auipc	a3,0x3
ffffffffc0202350:	e6468693          	addi	a3,a3,-412 # ffffffffc02051b0 <default_pmm_manager+0x3e0>
ffffffffc0202354:	00002617          	auipc	a2,0x2
ffffffffc0202358:	6e460613          	addi	a2,a2,1764 # ffffffffc0204a38 <commands+0x870>
ffffffffc020235c:	1a800593          	li	a1,424
ffffffffc0202360:	00003517          	auipc	a0,0x3
ffffffffc0202364:	ae850513          	addi	a0,a0,-1304 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202368:	808fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020236c:	00003697          	auipc	a3,0x3
ffffffffc0202370:	e2c68693          	addi	a3,a3,-468 # ffffffffc0205198 <default_pmm_manager+0x3c8>
ffffffffc0202374:	00002617          	auipc	a2,0x2
ffffffffc0202378:	6c460613          	addi	a2,a2,1732 # ffffffffc0204a38 <commands+0x870>
ffffffffc020237c:	1a700593          	li	a1,423
ffffffffc0202380:	00003517          	auipc	a0,0x3
ffffffffc0202384:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202388:	fe9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020238c:	00003697          	auipc	a3,0x3
ffffffffc0202390:	dfc68693          	addi	a3,a3,-516 # ffffffffc0205188 <default_pmm_manager+0x3b8>
ffffffffc0202394:	00002617          	auipc	a2,0x2
ffffffffc0202398:	6a460613          	addi	a2,a2,1700 # ffffffffc0204a38 <commands+0x870>
ffffffffc020239c:	1a600593          	li	a1,422
ffffffffc02023a0:	00003517          	auipc	a0,0x3
ffffffffc02023a4:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02023a8:	fc9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02023ac:	00003697          	auipc	a3,0x3
ffffffffc02023b0:	ed468693          	addi	a3,a3,-300 # ffffffffc0205280 <default_pmm_manager+0x4b0>
ffffffffc02023b4:	00002617          	auipc	a2,0x2
ffffffffc02023b8:	68460613          	addi	a2,a2,1668 # ffffffffc0204a38 <commands+0x870>
ffffffffc02023bc:	1e800593          	li	a1,488
ffffffffc02023c0:	00003517          	auipc	a0,0x3
ffffffffc02023c4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02023c8:	fa9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02023cc:	00003697          	auipc	a3,0x3
ffffffffc02023d0:	05c68693          	addi	a3,a3,92 # ffffffffc0205428 <default_pmm_manager+0x658>
ffffffffc02023d4:	00002617          	auipc	a2,0x2
ffffffffc02023d8:	66460613          	addi	a2,a2,1636 # ffffffffc0204a38 <commands+0x870>
ffffffffc02023dc:	1e000593          	li	a1,480
ffffffffc02023e0:	00003517          	auipc	a0,0x3
ffffffffc02023e4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02023e8:	f89fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02023ec:	00003697          	auipc	a3,0x3
ffffffffc02023f0:	00468693          	addi	a3,a3,4 # ffffffffc02053f0 <default_pmm_manager+0x620>
ffffffffc02023f4:	00002617          	auipc	a2,0x2
ffffffffc02023f8:	64460613          	addi	a2,a2,1604 # ffffffffc0204a38 <commands+0x870>
ffffffffc02023fc:	1dd00593          	li	a1,477
ffffffffc0202400:	00003517          	auipc	a0,0x3
ffffffffc0202404:	a4850513          	addi	a0,a0,-1464 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202408:	f69fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020240c:	00003697          	auipc	a3,0x3
ffffffffc0202410:	fb468693          	addi	a3,a3,-76 # ffffffffc02053c0 <default_pmm_manager+0x5f0>
ffffffffc0202414:	00002617          	auipc	a2,0x2
ffffffffc0202418:	62460613          	addi	a2,a2,1572 # ffffffffc0204a38 <commands+0x870>
ffffffffc020241c:	1d900593          	li	a1,473
ffffffffc0202420:	00003517          	auipc	a0,0x3
ffffffffc0202424:	a2850513          	addi	a0,a0,-1496 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202428:	f49fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020242c:	00003697          	auipc	a3,0x3
ffffffffc0202430:	e1468693          	addi	a3,a3,-492 # ffffffffc0205240 <default_pmm_manager+0x470>
ffffffffc0202434:	00002617          	auipc	a2,0x2
ffffffffc0202438:	60460613          	addi	a2,a2,1540 # ffffffffc0204a38 <commands+0x870>
ffffffffc020243c:	1b600593          	li	a1,438
ffffffffc0202440:	00003517          	auipc	a0,0x3
ffffffffc0202444:	a0850513          	addi	a0,a0,-1528 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202448:	f29fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020244c:	00003697          	auipc	a3,0x3
ffffffffc0202450:	dc468693          	addi	a3,a3,-572 # ffffffffc0205210 <default_pmm_manager+0x440>
ffffffffc0202454:	00002617          	auipc	a2,0x2
ffffffffc0202458:	5e460613          	addi	a2,a2,1508 # ffffffffc0204a38 <commands+0x870>
ffffffffc020245c:	1b300593          	li	a1,435
ffffffffc0202460:	00003517          	auipc	a0,0x3
ffffffffc0202464:	9e850513          	addi	a0,a0,-1560 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202468:	f09fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020246c:	00003697          	auipc	a3,0x3
ffffffffc0202470:	c6468693          	addi	a3,a3,-924 # ffffffffc02050d0 <default_pmm_manager+0x300>
ffffffffc0202474:	00002617          	auipc	a2,0x2
ffffffffc0202478:	5c460613          	addi	a2,a2,1476 # ffffffffc0204a38 <commands+0x870>
ffffffffc020247c:	1b200593          	li	a1,434
ffffffffc0202480:	00003517          	auipc	a0,0x3
ffffffffc0202484:	9c850513          	addi	a0,a0,-1592 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202488:	ee9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020248c:	00003697          	auipc	a3,0x3
ffffffffc0202490:	d9c68693          	addi	a3,a3,-612 # ffffffffc0205228 <default_pmm_manager+0x458>
ffffffffc0202494:	00002617          	auipc	a2,0x2
ffffffffc0202498:	5a460613          	addi	a2,a2,1444 # ffffffffc0204a38 <commands+0x870>
ffffffffc020249c:	1af00593          	li	a1,431
ffffffffc02024a0:	00003517          	auipc	a0,0x3
ffffffffc02024a4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02024a8:	ec9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024ac:	00003697          	auipc	a3,0x3
ffffffffc02024b0:	dac68693          	addi	a3,a3,-596 # ffffffffc0205258 <default_pmm_manager+0x488>
ffffffffc02024b4:	00002617          	auipc	a2,0x2
ffffffffc02024b8:	58460613          	addi	a2,a2,1412 # ffffffffc0204a38 <commands+0x870>
ffffffffc02024bc:	1b900593          	li	a1,441
ffffffffc02024c0:	00003517          	auipc	a0,0x3
ffffffffc02024c4:	98850513          	addi	a0,a0,-1656 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02024c8:	ea9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024cc:	00003697          	auipc	a3,0x3
ffffffffc02024d0:	d4468693          	addi	a3,a3,-700 # ffffffffc0205210 <default_pmm_manager+0x440>
ffffffffc02024d4:	00002617          	auipc	a2,0x2
ffffffffc02024d8:	56460613          	addi	a2,a2,1380 # ffffffffc0204a38 <commands+0x870>
ffffffffc02024dc:	1b700593          	li	a1,439
ffffffffc02024e0:	00003517          	auipc	a0,0x3
ffffffffc02024e4:	96850513          	addi	a0,a0,-1688 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02024e8:	e89fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02024ec:	00003697          	auipc	a3,0x3
ffffffffc02024f0:	ac468693          	addi	a3,a3,-1340 # ffffffffc0204fb0 <default_pmm_manager+0x1e0>
ffffffffc02024f4:	00002617          	auipc	a2,0x2
ffffffffc02024f8:	54460613          	addi	a2,a2,1348 # ffffffffc0204a38 <commands+0x870>
ffffffffc02024fc:	19200593          	li	a1,402
ffffffffc0202500:	00003517          	auipc	a0,0x3
ffffffffc0202504:	94850513          	addi	a0,a0,-1720 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202508:	e69fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020250c:	00003617          	auipc	a2,0x3
ffffffffc0202510:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204f68 <default_pmm_manager+0x198>
ffffffffc0202514:	0bd00593          	li	a1,189
ffffffffc0202518:	00003517          	auipc	a0,0x3
ffffffffc020251c:	93050513          	addi	a0,a0,-1744 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202520:	e51fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202524:	00003697          	auipc	a3,0x3
ffffffffc0202528:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205380 <default_pmm_manager+0x5b0>
ffffffffc020252c:	00002617          	auipc	a2,0x2
ffffffffc0202530:	50c60613          	addi	a2,a2,1292 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202534:	1d800593          	li	a1,472
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	91050513          	addi	a0,a0,-1776 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202540:	e31fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202544:	00003697          	auipc	a3,0x3
ffffffffc0202548:	e2468693          	addi	a3,a3,-476 # ffffffffc0205368 <default_pmm_manager+0x598>
ffffffffc020254c:	00002617          	auipc	a2,0x2
ffffffffc0202550:	4ec60613          	addi	a2,a2,1260 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202554:	1d700593          	li	a1,471
ffffffffc0202558:	00003517          	auipc	a0,0x3
ffffffffc020255c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202560:	e11fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202564:	00003697          	auipc	a3,0x3
ffffffffc0202568:	dcc68693          	addi	a3,a3,-564 # ffffffffc0205330 <default_pmm_manager+0x560>
ffffffffc020256c:	00002617          	auipc	a2,0x2
ffffffffc0202570:	4cc60613          	addi	a2,a2,1228 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202574:	1d600593          	li	a1,470
ffffffffc0202578:	00003517          	auipc	a0,0x3
ffffffffc020257c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc0202580:	df1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202584:	00003697          	auipc	a3,0x3
ffffffffc0202588:	d9468693          	addi	a3,a3,-620 # ffffffffc0205318 <default_pmm_manager+0x548>
ffffffffc020258c:	00002617          	auipc	a2,0x2
ffffffffc0202590:	4ac60613          	addi	a2,a2,1196 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202594:	1d200593          	li	a1,466
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02025a0:	dd1fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02025a4 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02025a4:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02025a8:	8082                	ret

ffffffffc02025aa <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025aa:	7179                	addi	sp,sp,-48
ffffffffc02025ac:	e84a                	sd	s2,16(sp)
ffffffffc02025ae:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02025b0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025b2:	f022                	sd	s0,32(sp)
ffffffffc02025b4:	ec26                	sd	s1,24(sp)
ffffffffc02025b6:	e44e                	sd	s3,8(sp)
ffffffffc02025b8:	f406                	sd	ra,40(sp)
ffffffffc02025ba:	84ae                	mv	s1,a1
ffffffffc02025bc:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02025be:	860ff0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc02025c2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02025c4:	cd19                	beqz	a0,ffffffffc02025e2 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02025c6:	85aa                	mv	a1,a0
ffffffffc02025c8:	86ce                	mv	a3,s3
ffffffffc02025ca:	8626                	mv	a2,s1
ffffffffc02025cc:	854a                	mv	a0,s2
ffffffffc02025ce:	c2cff0ef          	jal	ra,ffffffffc02019fa <page_insert>
ffffffffc02025d2:	ed39                	bnez	a0,ffffffffc0202630 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc02025d4:	0000e797          	auipc	a5,0xe
ffffffffc02025d8:	e9478793          	addi	a5,a5,-364 # ffffffffc0210468 <swap_init_ok>
ffffffffc02025dc:	439c                	lw	a5,0(a5)
ffffffffc02025de:	2781                	sext.w	a5,a5
ffffffffc02025e0:	eb89                	bnez	a5,ffffffffc02025f2 <pgdir_alloc_page+0x48>
}
ffffffffc02025e2:	8522                	mv	a0,s0
ffffffffc02025e4:	70a2                	ld	ra,40(sp)
ffffffffc02025e6:	7402                	ld	s0,32(sp)
ffffffffc02025e8:	64e2                	ld	s1,24(sp)
ffffffffc02025ea:	6942                	ld	s2,16(sp)
ffffffffc02025ec:	69a2                	ld	s3,8(sp)
ffffffffc02025ee:	6145                	addi	sp,sp,48
ffffffffc02025f0:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02025f2:	0000e797          	auipc	a5,0xe
ffffffffc02025f6:	f9e78793          	addi	a5,a5,-98 # ffffffffc0210590 <check_mm_struct>
ffffffffc02025fa:	6388                	ld	a0,0(a5)
ffffffffc02025fc:	4681                	li	a3,0
ffffffffc02025fe:	8622                	mv	a2,s0
ffffffffc0202600:	85a6                	mv	a1,s1
ffffffffc0202602:	06d000ef          	jal	ra,ffffffffc0202e6e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202606:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202608:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020260a:	4785                	li	a5,1
ffffffffc020260c:	fcf70be3          	beq	a4,a5,ffffffffc02025e2 <pgdir_alloc_page+0x38>
ffffffffc0202610:	00003697          	auipc	a3,0x3
ffffffffc0202614:	8b868693          	addi	a3,a3,-1864 # ffffffffc0204ec8 <default_pmm_manager+0xf8>
ffffffffc0202618:	00002617          	auipc	a2,0x2
ffffffffc020261c:	42060613          	addi	a2,a2,1056 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202620:	17a00593          	li	a1,378
ffffffffc0202624:	00003517          	auipc	a0,0x3
ffffffffc0202628:	82450513          	addi	a0,a0,-2012 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020262c:	d45fd0ef          	jal	ra,ffffffffc0200370 <__panic>
            free_page(page);
ffffffffc0202630:	8522                	mv	a0,s0
ffffffffc0202632:	4585                	li	a1,1
ffffffffc0202634:	872ff0ef          	jal	ra,ffffffffc02016a6 <free_pages>
            return NULL;
ffffffffc0202638:	4401                	li	s0,0
ffffffffc020263a:	b765                	j	ffffffffc02025e2 <pgdir_alloc_page+0x38>

ffffffffc020263c <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020263c:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020263e:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0202640:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202642:	fff50713          	addi	a4,a0,-1
ffffffffc0202646:	17f9                	addi	a5,a5,-2
ffffffffc0202648:	04e7ee63          	bltu	a5,a4,ffffffffc02026a4 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020264c:	6785                	lui	a5,0x1
ffffffffc020264e:	17fd                	addi	a5,a5,-1
ffffffffc0202650:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202652:	8131                	srli	a0,a0,0xc
ffffffffc0202654:	fcbfe0ef          	jal	ra,ffffffffc020161e <alloc_pages>
    assert(base != NULL);
ffffffffc0202658:	c159                	beqz	a0,ffffffffc02026de <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020265a:	0000e797          	auipc	a5,0xe
ffffffffc020265e:	e4e78793          	addi	a5,a5,-434 # ffffffffc02104a8 <pages>
ffffffffc0202662:	639c                	ld	a5,0(a5)
ffffffffc0202664:	8d1d                	sub	a0,a0,a5
ffffffffc0202666:	00002797          	auipc	a5,0x2
ffffffffc020266a:	3ba78793          	addi	a5,a5,954 # ffffffffc0204a20 <commands+0x858>
ffffffffc020266e:	6394                	ld	a3,0(a5)
ffffffffc0202670:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202672:	0000e797          	auipc	a5,0xe
ffffffffc0202676:	de678793          	addi	a5,a5,-538 # ffffffffc0210458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020267a:	02d50533          	mul	a0,a0,a3
ffffffffc020267e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202682:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202684:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202686:	00c51793          	slli	a5,a0,0xc
ffffffffc020268a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020268c:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020268e:	02e7fb63          	bgeu	a5,a4,ffffffffc02026c4 <kmalloc+0x88>
ffffffffc0202692:	0000e797          	auipc	a5,0xe
ffffffffc0202696:	e0678793          	addi	a5,a5,-506 # ffffffffc0210498 <va_pa_offset>
ffffffffc020269a:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020269c:	60a2                	ld	ra,8(sp)
ffffffffc020269e:	953e                	add	a0,a0,a5
ffffffffc02026a0:	0141                	addi	sp,sp,16
ffffffffc02026a2:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026a4:	00002697          	auipc	a3,0x2
ffffffffc02026a8:	7c468693          	addi	a3,a3,1988 # ffffffffc0204e68 <default_pmm_manager+0x98>
ffffffffc02026ac:	00002617          	auipc	a2,0x2
ffffffffc02026b0:	38c60613          	addi	a2,a2,908 # ffffffffc0204a38 <commands+0x870>
ffffffffc02026b4:	1f000593          	li	a1,496
ffffffffc02026b8:	00002517          	auipc	a0,0x2
ffffffffc02026bc:	79050513          	addi	a0,a0,1936 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02026c0:	cb1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02026c4:	86aa                	mv	a3,a0
ffffffffc02026c6:	00002617          	auipc	a2,0x2
ffffffffc02026ca:	75a60613          	addi	a2,a2,1882 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc02026ce:	06a00593          	li	a1,106
ffffffffc02026d2:	00002517          	auipc	a0,0x2
ffffffffc02026d6:	7e650513          	addi	a0,a0,2022 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc02026da:	c97fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(base != NULL);
ffffffffc02026de:	00002697          	auipc	a3,0x2
ffffffffc02026e2:	7aa68693          	addi	a3,a3,1962 # ffffffffc0204e88 <default_pmm_manager+0xb8>
ffffffffc02026e6:	00002617          	auipc	a2,0x2
ffffffffc02026ea:	35260613          	addi	a2,a2,850 # ffffffffc0204a38 <commands+0x870>
ffffffffc02026ee:	1f300593          	li	a1,499
ffffffffc02026f2:	00002517          	auipc	a0,0x2
ffffffffc02026f6:	75650513          	addi	a0,a0,1878 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02026fa:	c77fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02026fe <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc02026fe:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202700:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202702:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202704:	fff58713          	addi	a4,a1,-1
ffffffffc0202708:	17f9                	addi	a5,a5,-2
ffffffffc020270a:	04e7eb63          	bltu	a5,a4,ffffffffc0202760 <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020270e:	c941                	beqz	a0,ffffffffc020279e <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202710:	6785                	lui	a5,0x1
ffffffffc0202712:	17fd                	addi	a5,a5,-1
ffffffffc0202714:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202716:	c02007b7          	lui	a5,0xc0200
ffffffffc020271a:	81b1                	srli	a1,a1,0xc
ffffffffc020271c:	06f56463          	bltu	a0,a5,ffffffffc0202784 <kfree+0x86>
ffffffffc0202720:	0000e797          	auipc	a5,0xe
ffffffffc0202724:	d7878793          	addi	a5,a5,-648 # ffffffffc0210498 <va_pa_offset>
ffffffffc0202728:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020272a:	0000e717          	auipc	a4,0xe
ffffffffc020272e:	d2e70713          	addi	a4,a4,-722 # ffffffffc0210458 <npage>
ffffffffc0202732:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202734:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202738:	83b1                	srli	a5,a5,0xc
ffffffffc020273a:	04e7f363          	bgeu	a5,a4,ffffffffc0202780 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020273e:	fff80537          	lui	a0,0xfff80
ffffffffc0202742:	97aa                	add	a5,a5,a0
ffffffffc0202744:	0000e697          	auipc	a3,0xe
ffffffffc0202748:	d6468693          	addi	a3,a3,-668 # ffffffffc02104a8 <pages>
ffffffffc020274c:	6288                	ld	a0,0(a3)
ffffffffc020274e:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202752:	60a2                	ld	ra,8(sp)
ffffffffc0202754:	97ba                	add	a5,a5,a4
ffffffffc0202756:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202758:	953e                	add	a0,a0,a5
}
ffffffffc020275a:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020275c:	f4bfe06f          	j	ffffffffc02016a6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202760:	00002697          	auipc	a3,0x2
ffffffffc0202764:	70868693          	addi	a3,a3,1800 # ffffffffc0204e68 <default_pmm_manager+0x98>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	2d060613          	addi	a2,a2,720 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202770:	1f900593          	li	a1,505
ffffffffc0202774:	00002517          	auipc	a0,0x2
ffffffffc0202778:	6d450513          	addi	a0,a0,1748 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc020277c:	bf5fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0202780:	e83fe0ef          	jal	ra,ffffffffc0201602 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202784:	86aa                	mv	a3,a0
ffffffffc0202786:	00002617          	auipc	a2,0x2
ffffffffc020278a:	7e260613          	addi	a2,a2,2018 # ffffffffc0204f68 <default_pmm_manager+0x198>
ffffffffc020278e:	06c00593          	li	a1,108
ffffffffc0202792:	00002517          	auipc	a0,0x2
ffffffffc0202796:	72650513          	addi	a0,a0,1830 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc020279a:	bd7fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(ptr != NULL);
ffffffffc020279e:	00002697          	auipc	a3,0x2
ffffffffc02027a2:	6ba68693          	addi	a3,a3,1722 # ffffffffc0204e58 <default_pmm_manager+0x88>
ffffffffc02027a6:	00002617          	auipc	a2,0x2
ffffffffc02027aa:	29260613          	addi	a2,a2,658 # ffffffffc0204a38 <commands+0x870>
ffffffffc02027ae:	1fa00593          	li	a1,506
ffffffffc02027b2:	00002517          	auipc	a0,0x2
ffffffffc02027b6:	69650513          	addi	a0,a0,1686 # ffffffffc0204e48 <default_pmm_manager+0x78>
ffffffffc02027ba:	bb7fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02027be <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02027be:	7135                	addi	sp,sp,-160
ffffffffc02027c0:	ed06                	sd	ra,152(sp)
ffffffffc02027c2:	e922                	sd	s0,144(sp)
ffffffffc02027c4:	e526                	sd	s1,136(sp)
ffffffffc02027c6:	e14a                	sd	s2,128(sp)
ffffffffc02027c8:	fcce                	sd	s3,120(sp)
ffffffffc02027ca:	f8d2                	sd	s4,112(sp)
ffffffffc02027cc:	f4d6                	sd	s5,104(sp)
ffffffffc02027ce:	f0da                	sd	s6,96(sp)
ffffffffc02027d0:	ecde                	sd	s7,88(sp)
ffffffffc02027d2:	e8e2                	sd	s8,80(sp)
ffffffffc02027d4:	e4e6                	sd	s9,72(sp)
ffffffffc02027d6:	e0ea                	sd	s10,64(sp)
ffffffffc02027d8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02027da:	274010ef          	jal	ra,ffffffffc0203a4e <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02027de:	0000e797          	auipc	a5,0xe
ffffffffc02027e2:	d5a78793          	addi	a5,a5,-678 # ffffffffc0210538 <max_swap_offset>
ffffffffc02027e6:	6394                	ld	a3,0(a5)
ffffffffc02027e8:	010007b7          	lui	a5,0x1000
ffffffffc02027ec:	17e1                	addi	a5,a5,-8
ffffffffc02027ee:	ff968713          	addi	a4,a3,-7
ffffffffc02027f2:	42e7ea63          	bltu	a5,a4,ffffffffc0202c26 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02027f6:	00007797          	auipc	a5,0x7
ffffffffc02027fa:	80a78793          	addi	a5,a5,-2038 # ffffffffc0209000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02027fe:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202800:	0000e697          	auipc	a3,0xe
ffffffffc0202804:	c6f6b023          	sd	a5,-928(a3) # ffffffffc0210460 <sm>
     int r = sm->init();
ffffffffc0202808:	9702                	jalr	a4
ffffffffc020280a:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020280c:	c10d                	beqz	a0,ffffffffc020282e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020280e:	60ea                	ld	ra,152(sp)
ffffffffc0202810:	644a                	ld	s0,144(sp)
ffffffffc0202812:	855a                	mv	a0,s6
ffffffffc0202814:	64aa                	ld	s1,136(sp)
ffffffffc0202816:	690a                	ld	s2,128(sp)
ffffffffc0202818:	79e6                	ld	s3,120(sp)
ffffffffc020281a:	7a46                	ld	s4,112(sp)
ffffffffc020281c:	7aa6                	ld	s5,104(sp)
ffffffffc020281e:	7b06                	ld	s6,96(sp)
ffffffffc0202820:	6be6                	ld	s7,88(sp)
ffffffffc0202822:	6c46                	ld	s8,80(sp)
ffffffffc0202824:	6ca6                	ld	s9,72(sp)
ffffffffc0202826:	6d06                	ld	s10,64(sp)
ffffffffc0202828:	7de2                	ld	s11,56(sp)
ffffffffc020282a:	610d                	addi	sp,sp,160
ffffffffc020282c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020282e:	0000e797          	auipc	a5,0xe
ffffffffc0202832:	c3278793          	addi	a5,a5,-974 # ffffffffc0210460 <sm>
ffffffffc0202836:	639c                	ld	a5,0(a5)
ffffffffc0202838:	00003517          	auipc	a0,0x3
ffffffffc020283c:	c6850513          	addi	a0,a0,-920 # ffffffffc02054a0 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc0202840:	0000e417          	auipc	s0,0xe
ffffffffc0202844:	c3840413          	addi	s0,s0,-968 # ffffffffc0210478 <free_area>
ffffffffc0202848:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020284a:	4785                	li	a5,1
ffffffffc020284c:	0000e717          	auipc	a4,0xe
ffffffffc0202850:	c0f72e23          	sw	a5,-996(a4) # ffffffffc0210468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202854:	86bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202858:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020285a:	2e878a63          	beq	a5,s0,ffffffffc0202b4e <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020285e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202862:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202864:	8b05                	andi	a4,a4,1
ffffffffc0202866:	2e070863          	beqz	a4,ffffffffc0202b56 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020286a:	4481                	li	s1,0
ffffffffc020286c:	4901                	li	s2,0
ffffffffc020286e:	a031                	j	ffffffffc020287a <swap_init+0xbc>
ffffffffc0202870:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202874:	8b09                	andi	a4,a4,2
ffffffffc0202876:	2e070063          	beqz	a4,ffffffffc0202b56 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020287a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020287e:	679c                	ld	a5,8(a5)
ffffffffc0202880:	2905                	addiw	s2,s2,1
ffffffffc0202882:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202884:	fe8796e3          	bne	a5,s0,ffffffffc0202870 <swap_init+0xb2>
ffffffffc0202888:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020288a:	e63fe0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc020288e:	5b351863          	bne	a0,s3,ffffffffc0202e3e <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202892:	8626                	mv	a2,s1
ffffffffc0202894:	85ca                	mv	a1,s2
ffffffffc0202896:	00003517          	auipc	a0,0x3
ffffffffc020289a:	c2250513          	addi	a0,a0,-990 # ffffffffc02054b8 <default_pmm_manager+0x6e8>
ffffffffc020289e:	821fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02028a2:	203000ef          	jal	ra,ffffffffc02032a4 <mm_create>
ffffffffc02028a6:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02028a8:	50050b63          	beqz	a0,ffffffffc0202dbe <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02028ac:	0000e797          	auipc	a5,0xe
ffffffffc02028b0:	ce478793          	addi	a5,a5,-796 # ffffffffc0210590 <check_mm_struct>
ffffffffc02028b4:	639c                	ld	a5,0(a5)
ffffffffc02028b6:	52079463          	bnez	a5,ffffffffc0202dde <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028ba:	0000e797          	auipc	a5,0xe
ffffffffc02028be:	b9678793          	addi	a5,a5,-1130 # ffffffffc0210450 <boot_pgdir>
ffffffffc02028c2:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02028c4:	0000e797          	auipc	a5,0xe
ffffffffc02028c8:	cca7b623          	sd	a0,-820(a5) # ffffffffc0210590 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02028cc:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028ce:	ec3a                	sd	a4,24(sp)
ffffffffc02028d0:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02028d2:	52079663          	bnez	a5,ffffffffc0202dfe <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02028d6:	6599                	lui	a1,0x6
ffffffffc02028d8:	460d                	li	a2,3
ffffffffc02028da:	6505                	lui	a0,0x1
ffffffffc02028dc:	215000ef          	jal	ra,ffffffffc02032f0 <vma_create>
ffffffffc02028e0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02028e2:	52050e63          	beqz	a0,ffffffffc0202e1e <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02028e6:	855e                	mv	a0,s7
ffffffffc02028e8:	275000ef          	jal	ra,ffffffffc020335c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02028ec:	00003517          	auipc	a0,0x3
ffffffffc02028f0:	c3c50513          	addi	a0,a0,-964 # ffffffffc0205528 <default_pmm_manager+0x758>
ffffffffc02028f4:	fcafd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02028f8:	018bb503          	ld	a0,24(s7)
ffffffffc02028fc:	4605                	li	a2,1
ffffffffc02028fe:	6585                	lui	a1,0x1
ffffffffc0202900:	e2dfe0ef          	jal	ra,ffffffffc020172c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202904:	40050d63          	beqz	a0,ffffffffc0202d1e <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202908:	00003517          	auipc	a0,0x3
ffffffffc020290c:	c7050513          	addi	a0,a0,-912 # ffffffffc0205578 <default_pmm_manager+0x7a8>
ffffffffc0202910:	0000ea17          	auipc	s4,0xe
ffffffffc0202914:	ba0a0a13          	addi	s4,s4,-1120 # ffffffffc02104b0 <check_rp>
ffffffffc0202918:	fa6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020291c:	0000ea97          	auipc	s5,0xe
ffffffffc0202920:	bb4a8a93          	addi	s5,s5,-1100 # ffffffffc02104d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202924:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202926:	4505                	li	a0,1
ffffffffc0202928:	cf7fe0ef          	jal	ra,ffffffffc020161e <alloc_pages>
ffffffffc020292c:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6fa68>
          assert(check_rp[i] != NULL );
ffffffffc0202930:	2a050b63          	beqz	a0,ffffffffc0202be6 <swap_init+0x428>
ffffffffc0202934:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202936:	8b89                	andi	a5,a5,2
ffffffffc0202938:	28079763          	bnez	a5,ffffffffc0202bc6 <swap_init+0x408>
ffffffffc020293c:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020293e:	ff5994e3          	bne	s3,s5,ffffffffc0202926 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202942:	601c                	ld	a5,0(s0)
ffffffffc0202944:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202948:	0000ed17          	auipc	s10,0xe
ffffffffc020294c:	b68d0d13          	addi	s10,s10,-1176 # ffffffffc02104b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202950:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202952:	481c                	lw	a5,16(s0)
ffffffffc0202954:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202956:	0000e797          	auipc	a5,0xe
ffffffffc020295a:	b287b523          	sd	s0,-1238(a5) # ffffffffc0210480 <free_area+0x8>
ffffffffc020295e:	0000e797          	auipc	a5,0xe
ffffffffc0202962:	b087bd23          	sd	s0,-1254(a5) # ffffffffc0210478 <free_area>
     nr_free = 0;
ffffffffc0202966:	0000e797          	auipc	a5,0xe
ffffffffc020296a:	b207a123          	sw	zero,-1246(a5) # ffffffffc0210488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020296e:	000d3503          	ld	a0,0(s10)
ffffffffc0202972:	4585                	li	a1,1
ffffffffc0202974:	0d21                	addi	s10,s10,8
ffffffffc0202976:	d31fe0ef          	jal	ra,ffffffffc02016a6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020297a:	ff5d1ae3          	bne	s10,s5,ffffffffc020296e <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020297e:	01042d03          	lw	s10,16(s0)
ffffffffc0202982:	4791                	li	a5,4
ffffffffc0202984:	36fd1d63          	bne	s10,a5,ffffffffc0202cfe <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202988:	00003517          	auipc	a0,0x3
ffffffffc020298c:	c7850513          	addi	a0,a0,-904 # ffffffffc0205600 <default_pmm_manager+0x830>
ffffffffc0202990:	f2efd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202994:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202996:	0000e797          	auipc	a5,0xe
ffffffffc020299a:	ac07ab23          	sw	zero,-1322(a5) # ffffffffc021046c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020299e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029a0:	0000e797          	auipc	a5,0xe
ffffffffc02029a4:	acc78793          	addi	a5,a5,-1332 # ffffffffc021046c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029a8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02029ac:	4398                	lw	a4,0(a5)
ffffffffc02029ae:	4585                	li	a1,1
ffffffffc02029b0:	2701                	sext.w	a4,a4
ffffffffc02029b2:	30b71663          	bne	a4,a1,ffffffffc0202cbe <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02029b6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02029ba:	4394                	lw	a3,0(a5)
ffffffffc02029bc:	2681                	sext.w	a3,a3
ffffffffc02029be:	32e69063          	bne	a3,a4,ffffffffc0202cde <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02029c2:	6689                	lui	a3,0x2
ffffffffc02029c4:	462d                	li	a2,11
ffffffffc02029c6:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02029ca:	4398                	lw	a4,0(a5)
ffffffffc02029cc:	4589                	li	a1,2
ffffffffc02029ce:	2701                	sext.w	a4,a4
ffffffffc02029d0:	26b71763          	bne	a4,a1,ffffffffc0202c3e <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02029d4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02029d8:	4394                	lw	a3,0(a5)
ffffffffc02029da:	2681                	sext.w	a3,a3
ffffffffc02029dc:	28e69163          	bne	a3,a4,ffffffffc0202c5e <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02029e0:	668d                	lui	a3,0x3
ffffffffc02029e2:	4631                	li	a2,12
ffffffffc02029e4:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02029e8:	4398                	lw	a4,0(a5)
ffffffffc02029ea:	458d                	li	a1,3
ffffffffc02029ec:	2701                	sext.w	a4,a4
ffffffffc02029ee:	28b71863          	bne	a4,a1,ffffffffc0202c7e <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02029f2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02029f6:	4394                	lw	a3,0(a5)
ffffffffc02029f8:	2681                	sext.w	a3,a3
ffffffffc02029fa:	2ae69263          	bne	a3,a4,ffffffffc0202c9e <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02029fe:	6691                	lui	a3,0x4
ffffffffc0202a00:	4635                	li	a2,13
ffffffffc0202a02:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a06:	4398                	lw	a4,0(a5)
ffffffffc0202a08:	2701                	sext.w	a4,a4
ffffffffc0202a0a:	33a71a63          	bne	a4,s10,ffffffffc0202d3e <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a0e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a12:	439c                	lw	a5,0(a5)
ffffffffc0202a14:	2781                	sext.w	a5,a5
ffffffffc0202a16:	34e79463          	bne	a5,a4,ffffffffc0202d5e <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a1a:	481c                	lw	a5,16(s0)
ffffffffc0202a1c:	36079163          	bnez	a5,ffffffffc0202d7e <swap_init+0x5c0>
ffffffffc0202a20:	0000e797          	auipc	a5,0xe
ffffffffc0202a24:	ab078793          	addi	a5,a5,-1360 # ffffffffc02104d0 <swap_in_seq_no>
ffffffffc0202a28:	0000e717          	auipc	a4,0xe
ffffffffc0202a2c:	ad070713          	addi	a4,a4,-1328 # ffffffffc02104f8 <swap_out_seq_no>
ffffffffc0202a30:	0000e617          	auipc	a2,0xe
ffffffffc0202a34:	ac860613          	addi	a2,a2,-1336 # ffffffffc02104f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a38:	56fd                	li	a3,-1
ffffffffc0202a3a:	c394                	sw	a3,0(a5)
ffffffffc0202a3c:	c314                	sw	a3,0(a4)
ffffffffc0202a3e:	0791                	addi	a5,a5,4
ffffffffc0202a40:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202a42:	fec79ce3          	bne	a5,a2,ffffffffc0202a3a <swap_init+0x27c>
ffffffffc0202a46:	0000e697          	auipc	a3,0xe
ffffffffc0202a4a:	b1268693          	addi	a3,a3,-1262 # ffffffffc0210558 <check_ptep>
ffffffffc0202a4e:	0000e817          	auipc	a6,0xe
ffffffffc0202a52:	a6280813          	addi	a6,a6,-1438 # ffffffffc02104b0 <check_rp>
ffffffffc0202a56:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202a58:	0000ec97          	auipc	s9,0xe
ffffffffc0202a5c:	a00c8c93          	addi	s9,s9,-1536 # ffffffffc0210458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a60:	0000ed97          	auipc	s11,0xe
ffffffffc0202a64:	a48d8d93          	addi	s11,s11,-1464 # ffffffffc02104a8 <pages>
ffffffffc0202a68:	00003d17          	auipc	s10,0x3
ffffffffc0202a6c:	3c8d0d13          	addi	s10,s10,968 # ffffffffc0205e30 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a70:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202a72:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a76:	4601                	li	a2,0
ffffffffc0202a78:	85e2                	mv	a1,s8
ffffffffc0202a7a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202a7c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a7e:	caffe0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0202a82:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202a84:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a86:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202a88:	16050f63          	beqz	a0,ffffffffc0202c06 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202a8c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202a8e:	0017f613          	andi	a2,a5,1
ffffffffc0202a92:	10060263          	beqz	a2,ffffffffc0202b96 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202a96:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a9a:	078a                	slli	a5,a5,0x2
ffffffffc0202a9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a9e:	10c7f863          	bgeu	a5,a2,ffffffffc0202bae <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202aa2:	000d3603          	ld	a2,0(s10)
ffffffffc0202aa6:	000db583          	ld	a1,0(s11)
ffffffffc0202aaa:	00083503          	ld	a0,0(a6)
ffffffffc0202aae:	8f91                	sub	a5,a5,a2
ffffffffc0202ab0:	00379613          	slli	a2,a5,0x3
ffffffffc0202ab4:	97b2                	add	a5,a5,a2
ffffffffc0202ab6:	078e                	slli	a5,a5,0x3
ffffffffc0202ab8:	97ae                	add	a5,a5,a1
ffffffffc0202aba:	0af51e63          	bne	a0,a5,ffffffffc0202b76 <swap_init+0x3b8>
ffffffffc0202abe:	6785                	lui	a5,0x1
ffffffffc0202ac0:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ac2:	6795                	lui	a5,0x5
ffffffffc0202ac4:	06a1                	addi	a3,a3,8
ffffffffc0202ac6:	0821                	addi	a6,a6,8
ffffffffc0202ac8:	fafc14e3          	bne	s8,a5,ffffffffc0202a70 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202acc:	00003517          	auipc	a0,0x3
ffffffffc0202ad0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02056a8 <default_pmm_manager+0x8d8>
ffffffffc0202ad4:	deafd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202ad8:	0000e797          	auipc	a5,0xe
ffffffffc0202adc:	98878793          	addi	a5,a5,-1656 # ffffffffc0210460 <sm>
ffffffffc0202ae0:	639c                	ld	a5,0(a5)
ffffffffc0202ae2:	7f9c                	ld	a5,56(a5)
ffffffffc0202ae4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ae6:	2a051c63          	bnez	a0,ffffffffc0202d9e <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202aea:	000a3503          	ld	a0,0(s4)
ffffffffc0202aee:	4585                	li	a1,1
ffffffffc0202af0:	0a21                	addi	s4,s4,8
ffffffffc0202af2:	bb5fe0ef          	jal	ra,ffffffffc02016a6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202af6:	ff5a1ae3          	bne	s4,s5,ffffffffc0202aea <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202afa:	855e                	mv	a0,s7
ffffffffc0202afc:	12f000ef          	jal	ra,ffffffffc020342a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b00:	77a2                	ld	a5,40(sp)
ffffffffc0202b02:	0000e717          	auipc	a4,0xe
ffffffffc0202b06:	98f72323          	sw	a5,-1658(a4) # ffffffffc0210488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b0a:	7782                	ld	a5,32(sp)
ffffffffc0202b0c:	0000e717          	auipc	a4,0xe
ffffffffc0202b10:	96f73623          	sd	a5,-1684(a4) # ffffffffc0210478 <free_area>
ffffffffc0202b14:	0000e797          	auipc	a5,0xe
ffffffffc0202b18:	9737b623          	sd	s3,-1684(a5) # ffffffffc0210480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b1c:	00898a63          	beq	s3,s0,ffffffffc0202b30 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b20:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b24:	0089b983          	ld	s3,8(s3)
ffffffffc0202b28:	397d                	addiw	s2,s2,-1
ffffffffc0202b2a:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b2c:	fe899ae3          	bne	s3,s0,ffffffffc0202b20 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b30:	8626                	mv	a2,s1
ffffffffc0202b32:	85ca                	mv	a1,s2
ffffffffc0202b34:	00003517          	auipc	a0,0x3
ffffffffc0202b38:	ba450513          	addi	a0,a0,-1116 # ffffffffc02056d8 <default_pmm_manager+0x908>
ffffffffc0202b3c:	d82fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b40:	00003517          	auipc	a0,0x3
ffffffffc0202b44:	bb850513          	addi	a0,a0,-1096 # ffffffffc02056f8 <default_pmm_manager+0x928>
ffffffffc0202b48:	d76fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202b4c:	b1c9                	j	ffffffffc020280e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202b4e:	4481                	li	s1,0
ffffffffc0202b50:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b52:	4981                	li	s3,0
ffffffffc0202b54:	bb1d                	j	ffffffffc020288a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202b56:	00002697          	auipc	a3,0x2
ffffffffc0202b5a:	ed268693          	addi	a3,a3,-302 # ffffffffc0204a28 <commands+0x860>
ffffffffc0202b5e:	00002617          	auipc	a2,0x2
ffffffffc0202b62:	eda60613          	addi	a2,a2,-294 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202b66:	0ba00593          	li	a1,186
ffffffffc0202b6a:	00003517          	auipc	a0,0x3
ffffffffc0202b6e:	92650513          	addi	a0,a0,-1754 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202b72:	ffefd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b76:	00003697          	auipc	a3,0x3
ffffffffc0202b7a:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0205680 <default_pmm_manager+0x8b0>
ffffffffc0202b7e:	00002617          	auipc	a2,0x2
ffffffffc0202b82:	eba60613          	addi	a2,a2,-326 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202b86:	0fa00593          	li	a1,250
ffffffffc0202b8a:	00003517          	auipc	a0,0x3
ffffffffc0202b8e:	90650513          	addi	a0,a0,-1786 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202b92:	fdefd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202b96:	00002617          	auipc	a2,0x2
ffffffffc0202b9a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0205090 <default_pmm_manager+0x2c0>
ffffffffc0202b9e:	07000593          	li	a1,112
ffffffffc0202ba2:	00002517          	auipc	a0,0x2
ffffffffc0202ba6:	31650513          	addi	a0,a0,790 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc0202baa:	fc6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bae:	00002617          	auipc	a2,0x2
ffffffffc0202bb2:	2ea60613          	addi	a2,a2,746 # ffffffffc0204e98 <default_pmm_manager+0xc8>
ffffffffc0202bb6:	06500593          	li	a1,101
ffffffffc0202bba:	00002517          	auipc	a0,0x2
ffffffffc0202bbe:	2fe50513          	addi	a0,a0,766 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc0202bc2:	faefd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202bc6:	00003697          	auipc	a3,0x3
ffffffffc0202bca:	9f268693          	addi	a3,a3,-1550 # ffffffffc02055b8 <default_pmm_manager+0x7e8>
ffffffffc0202bce:	00002617          	auipc	a2,0x2
ffffffffc0202bd2:	e6a60613          	addi	a2,a2,-406 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202bd6:	0db00593          	li	a1,219
ffffffffc0202bda:	00003517          	auipc	a0,0x3
ffffffffc0202bde:	8b650513          	addi	a0,a0,-1866 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202be2:	f8efd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202be6:	00003697          	auipc	a3,0x3
ffffffffc0202bea:	9ba68693          	addi	a3,a3,-1606 # ffffffffc02055a0 <default_pmm_manager+0x7d0>
ffffffffc0202bee:	00002617          	auipc	a2,0x2
ffffffffc0202bf2:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202bf6:	0da00593          	li	a1,218
ffffffffc0202bfa:	00003517          	auipc	a0,0x3
ffffffffc0202bfe:	89650513          	addi	a0,a0,-1898 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c02:	f6efd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c06:	00003697          	auipc	a3,0x3
ffffffffc0202c0a:	a6268693          	addi	a3,a3,-1438 # ffffffffc0205668 <default_pmm_manager+0x898>
ffffffffc0202c0e:	00002617          	auipc	a2,0x2
ffffffffc0202c12:	e2a60613          	addi	a2,a2,-470 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202c16:	0f900593          	li	a1,249
ffffffffc0202c1a:	00003517          	auipc	a0,0x3
ffffffffc0202c1e:	87650513          	addi	a0,a0,-1930 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c22:	f4efd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c26:	00003617          	auipc	a2,0x3
ffffffffc0202c2a:	84a60613          	addi	a2,a2,-1974 # ffffffffc0205470 <default_pmm_manager+0x6a0>
ffffffffc0202c2e:	02700593          	li	a1,39
ffffffffc0202c32:	00003517          	auipc	a0,0x3
ffffffffc0202c36:	85e50513          	addi	a0,a0,-1954 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c3a:	f36fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c3e:	00003697          	auipc	a3,0x3
ffffffffc0202c42:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0205638 <default_pmm_manager+0x868>
ffffffffc0202c46:	00002617          	auipc	a2,0x2
ffffffffc0202c4a:	df260613          	addi	a2,a2,-526 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202c4e:	09500593          	li	a1,149
ffffffffc0202c52:	00003517          	auipc	a0,0x3
ffffffffc0202c56:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c5a:	f16fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c5e:	00003697          	auipc	a3,0x3
ffffffffc0202c62:	9da68693          	addi	a3,a3,-1574 # ffffffffc0205638 <default_pmm_manager+0x868>
ffffffffc0202c66:	00002617          	auipc	a2,0x2
ffffffffc0202c6a:	dd260613          	addi	a2,a2,-558 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202c6e:	09700593          	li	a1,151
ffffffffc0202c72:	00003517          	auipc	a0,0x3
ffffffffc0202c76:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c7a:	ef6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c7e:	00003697          	auipc	a3,0x3
ffffffffc0202c82:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0205648 <default_pmm_manager+0x878>
ffffffffc0202c86:	00002617          	auipc	a2,0x2
ffffffffc0202c8a:	db260613          	addi	a2,a2,-590 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202c8e:	09900593          	li	a1,153
ffffffffc0202c92:	00002517          	auipc	a0,0x2
ffffffffc0202c96:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202c9a:	ed6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c9e:	00003697          	auipc	a3,0x3
ffffffffc0202ca2:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0205648 <default_pmm_manager+0x878>
ffffffffc0202ca6:	00002617          	auipc	a2,0x2
ffffffffc0202caa:	d9260613          	addi	a2,a2,-622 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202cae:	09b00593          	li	a1,155
ffffffffc0202cb2:	00002517          	auipc	a0,0x2
ffffffffc0202cb6:	7de50513          	addi	a0,a0,2014 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202cba:	eb6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cbe:	00003697          	auipc	a3,0x3
ffffffffc0202cc2:	96a68693          	addi	a3,a3,-1686 # ffffffffc0205628 <default_pmm_manager+0x858>
ffffffffc0202cc6:	00002617          	auipc	a2,0x2
ffffffffc0202cca:	d7260613          	addi	a2,a2,-654 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202cce:	09100593          	li	a1,145
ffffffffc0202cd2:	00002517          	auipc	a0,0x2
ffffffffc0202cd6:	7be50513          	addi	a0,a0,1982 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202cda:	e96fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cde:	00003697          	auipc	a3,0x3
ffffffffc0202ce2:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205628 <default_pmm_manager+0x858>
ffffffffc0202ce6:	00002617          	auipc	a2,0x2
ffffffffc0202cea:	d5260613          	addi	a2,a2,-686 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202cee:	09300593          	li	a1,147
ffffffffc0202cf2:	00002517          	auipc	a0,0x2
ffffffffc0202cf6:	79e50513          	addi	a0,a0,1950 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202cfa:	e76fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cfe:	00003697          	auipc	a3,0x3
ffffffffc0202d02:	8da68693          	addi	a3,a3,-1830 # ffffffffc02055d8 <default_pmm_manager+0x808>
ffffffffc0202d06:	00002617          	auipc	a2,0x2
ffffffffc0202d0a:	d3260613          	addi	a2,a2,-718 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202d0e:	0e800593          	li	a1,232
ffffffffc0202d12:	00002517          	auipc	a0,0x2
ffffffffc0202d16:	77e50513          	addi	a0,a0,1918 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202d1a:	e56fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d1e:	00003697          	auipc	a3,0x3
ffffffffc0202d22:	84268693          	addi	a3,a3,-1982 # ffffffffc0205560 <default_pmm_manager+0x790>
ffffffffc0202d26:	00002617          	auipc	a2,0x2
ffffffffc0202d2a:	d1260613          	addi	a2,a2,-750 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202d2e:	0d500593          	li	a1,213
ffffffffc0202d32:	00002517          	auipc	a0,0x2
ffffffffc0202d36:	75e50513          	addi	a0,a0,1886 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202d3a:	e36fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d3e:	00003697          	auipc	a3,0x3
ffffffffc0202d42:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc0202d46:	00002617          	auipc	a2,0x2
ffffffffc0202d4a:	cf260613          	addi	a2,a2,-782 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202d4e:	09d00593          	li	a1,157
ffffffffc0202d52:	00002517          	auipc	a0,0x2
ffffffffc0202d56:	73e50513          	addi	a0,a0,1854 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202d5a:	e16fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d5e:	00003697          	auipc	a3,0x3
ffffffffc0202d62:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc0202d66:	00002617          	auipc	a2,0x2
ffffffffc0202d6a:	cd260613          	addi	a2,a2,-814 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202d6e:	09f00593          	li	a1,159
ffffffffc0202d72:	00002517          	auipc	a0,0x2
ffffffffc0202d76:	71e50513          	addi	a0,a0,1822 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202d7a:	df6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert( nr_free == 0);         
ffffffffc0202d7e:	00002697          	auipc	a3,0x2
ffffffffc0202d82:	e9268693          	addi	a3,a3,-366 # ffffffffc0204c10 <commands+0xa48>
ffffffffc0202d86:	00002617          	auipc	a2,0x2
ffffffffc0202d8a:	cb260613          	addi	a2,a2,-846 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202d8e:	0f100593          	li	a1,241
ffffffffc0202d92:	00002517          	auipc	a0,0x2
ffffffffc0202d96:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202d9a:	dd6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(ret==0);
ffffffffc0202d9e:	00003697          	auipc	a3,0x3
ffffffffc0202da2:	93268693          	addi	a3,a3,-1742 # ffffffffc02056d0 <default_pmm_manager+0x900>
ffffffffc0202da6:	00002617          	auipc	a2,0x2
ffffffffc0202daa:	c9260613          	addi	a2,a2,-878 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202dae:	10000593          	li	a1,256
ffffffffc0202db2:	00002517          	auipc	a0,0x2
ffffffffc0202db6:	6de50513          	addi	a0,a0,1758 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202dba:	db6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(mm != NULL);
ffffffffc0202dbe:	00002697          	auipc	a3,0x2
ffffffffc0202dc2:	72268693          	addi	a3,a3,1826 # ffffffffc02054e0 <default_pmm_manager+0x710>
ffffffffc0202dc6:	00002617          	auipc	a2,0x2
ffffffffc0202dca:	c7260613          	addi	a2,a2,-910 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202dce:	0c200593          	li	a1,194
ffffffffc0202dd2:	00002517          	auipc	a0,0x2
ffffffffc0202dd6:	6be50513          	addi	a0,a0,1726 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202dda:	d96fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202dde:	00002697          	auipc	a3,0x2
ffffffffc0202de2:	71268693          	addi	a3,a3,1810 # ffffffffc02054f0 <default_pmm_manager+0x720>
ffffffffc0202de6:	00002617          	auipc	a2,0x2
ffffffffc0202dea:	c5260613          	addi	a2,a2,-942 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202dee:	0c500593          	li	a1,197
ffffffffc0202df2:	00002517          	auipc	a0,0x2
ffffffffc0202df6:	69e50513          	addi	a0,a0,1694 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202dfa:	d76fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202dfe:	00002697          	auipc	a3,0x2
ffffffffc0202e02:	70a68693          	addi	a3,a3,1802 # ffffffffc0205508 <default_pmm_manager+0x738>
ffffffffc0202e06:	00002617          	auipc	a2,0x2
ffffffffc0202e0a:	c3260613          	addi	a2,a2,-974 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202e0e:	0ca00593          	li	a1,202
ffffffffc0202e12:	00002517          	auipc	a0,0x2
ffffffffc0202e16:	67e50513          	addi	a0,a0,1662 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202e1a:	d56fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(vma != NULL);
ffffffffc0202e1e:	00002697          	auipc	a3,0x2
ffffffffc0202e22:	6fa68693          	addi	a3,a3,1786 # ffffffffc0205518 <default_pmm_manager+0x748>
ffffffffc0202e26:	00002617          	auipc	a2,0x2
ffffffffc0202e2a:	c1260613          	addi	a2,a2,-1006 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202e2e:	0cd00593          	li	a1,205
ffffffffc0202e32:	00002517          	auipc	a0,0x2
ffffffffc0202e36:	65e50513          	addi	a0,a0,1630 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202e3a:	d36fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e3e:	00002697          	auipc	a3,0x2
ffffffffc0202e42:	c2a68693          	addi	a3,a3,-982 # ffffffffc0204a68 <commands+0x8a0>
ffffffffc0202e46:	00002617          	auipc	a2,0x2
ffffffffc0202e4a:	bf260613          	addi	a2,a2,-1038 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202e4e:	0bd00593          	li	a1,189
ffffffffc0202e52:	00002517          	auipc	a0,0x2
ffffffffc0202e56:	63e50513          	addi	a0,a0,1598 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202e5a:	d16fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202e5e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202e5e:	0000d797          	auipc	a5,0xd
ffffffffc0202e62:	60278793          	addi	a5,a5,1538 # ffffffffc0210460 <sm>
ffffffffc0202e66:	639c                	ld	a5,0(a5)
ffffffffc0202e68:	0107b303          	ld	t1,16(a5)
ffffffffc0202e6c:	8302                	jr	t1

ffffffffc0202e6e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202e6e:	0000d797          	auipc	a5,0xd
ffffffffc0202e72:	5f278793          	addi	a5,a5,1522 # ffffffffc0210460 <sm>
ffffffffc0202e76:	639c                	ld	a5,0(a5)
ffffffffc0202e78:	0207b303          	ld	t1,32(a5)
ffffffffc0202e7c:	8302                	jr	t1

ffffffffc0202e7e <swap_out>:
{
ffffffffc0202e7e:	711d                	addi	sp,sp,-96
ffffffffc0202e80:	ec86                	sd	ra,88(sp)
ffffffffc0202e82:	e8a2                	sd	s0,80(sp)
ffffffffc0202e84:	e4a6                	sd	s1,72(sp)
ffffffffc0202e86:	e0ca                	sd	s2,64(sp)
ffffffffc0202e88:	fc4e                	sd	s3,56(sp)
ffffffffc0202e8a:	f852                	sd	s4,48(sp)
ffffffffc0202e8c:	f456                	sd	s5,40(sp)
ffffffffc0202e8e:	f05a                	sd	s6,32(sp)
ffffffffc0202e90:	ec5e                	sd	s7,24(sp)
ffffffffc0202e92:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202e94:	cde9                	beqz	a1,ffffffffc0202f6e <swap_out+0xf0>
ffffffffc0202e96:	8ab2                	mv	s5,a2
ffffffffc0202e98:	892a                	mv	s2,a0
ffffffffc0202e9a:	8a2e                	mv	s4,a1
ffffffffc0202e9c:	4401                	li	s0,0
ffffffffc0202e9e:	0000d997          	auipc	s3,0xd
ffffffffc0202ea2:	5c298993          	addi	s3,s3,1474 # ffffffffc0210460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ea6:	00003b17          	auipc	s6,0x3
ffffffffc0202eaa:	8d2b0b13          	addi	s6,s6,-1838 # ffffffffc0205778 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202eae:	00003b97          	auipc	s7,0x3
ffffffffc0202eb2:	8b2b8b93          	addi	s7,s7,-1870 # ffffffffc0205760 <default_pmm_manager+0x990>
ffffffffc0202eb6:	a825                	j	ffffffffc0202eee <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202eb8:	67a2                	ld	a5,8(sp)
ffffffffc0202eba:	8626                	mv	a2,s1
ffffffffc0202ebc:	85a2                	mv	a1,s0
ffffffffc0202ebe:	63b4                	ld	a3,64(a5)
ffffffffc0202ec0:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202ec2:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ec4:	82b1                	srli	a3,a3,0xc
ffffffffc0202ec6:	0685                	addi	a3,a3,1
ffffffffc0202ec8:	9f6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202ecc:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202ece:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202ed0:	613c                	ld	a5,64(a0)
ffffffffc0202ed2:	83b1                	srli	a5,a5,0xc
ffffffffc0202ed4:	0785                	addi	a5,a5,1
ffffffffc0202ed6:	07a2                	slli	a5,a5,0x8
ffffffffc0202ed8:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202edc:	fcafe0ef          	jal	ra,ffffffffc02016a6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202ee0:	01893503          	ld	a0,24(s2)
ffffffffc0202ee4:	85a6                	mv	a1,s1
ffffffffc0202ee6:	ebeff0ef          	jal	ra,ffffffffc02025a4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202eea:	048a0d63          	beq	s4,s0,ffffffffc0202f44 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202eee:	0009b783          	ld	a5,0(s3)
ffffffffc0202ef2:	8656                	mv	a2,s5
ffffffffc0202ef4:	002c                	addi	a1,sp,8
ffffffffc0202ef6:	7b9c                	ld	a5,48(a5)
ffffffffc0202ef8:	854a                	mv	a0,s2
ffffffffc0202efa:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202efc:	e12d                	bnez	a0,ffffffffc0202f5e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202efe:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f00:	01893503          	ld	a0,24(s2)
ffffffffc0202f04:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f06:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f08:	85a6                	mv	a1,s1
ffffffffc0202f0a:	823fe0ef          	jal	ra,ffffffffc020172c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f0e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f10:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f12:	8b85                	andi	a5,a5,1
ffffffffc0202f14:	cfb9                	beqz	a5,ffffffffc0202f72 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f16:	65a2                	ld	a1,8(sp)
ffffffffc0202f18:	61bc                	ld	a5,64(a1)
ffffffffc0202f1a:	83b1                	srli	a5,a5,0xc
ffffffffc0202f1c:	00178513          	addi	a0,a5,1
ffffffffc0202f20:	0522                	slli	a0,a0,0x8
ffffffffc0202f22:	365000ef          	jal	ra,ffffffffc0203a86 <swapfs_write>
ffffffffc0202f26:	d949                	beqz	a0,ffffffffc0202eb8 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f28:	855e                	mv	a0,s7
ffffffffc0202f2a:	994fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f2e:	0009b783          	ld	a5,0(s3)
ffffffffc0202f32:	6622                	ld	a2,8(sp)
ffffffffc0202f34:	4681                	li	a3,0
ffffffffc0202f36:	739c                	ld	a5,32(a5)
ffffffffc0202f38:	85a6                	mv	a1,s1
ffffffffc0202f3a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202f3c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f3e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202f40:	fa8a17e3          	bne	s4,s0,ffffffffc0202eee <swap_out+0x70>
}
ffffffffc0202f44:	8522                	mv	a0,s0
ffffffffc0202f46:	60e6                	ld	ra,88(sp)
ffffffffc0202f48:	6446                	ld	s0,80(sp)
ffffffffc0202f4a:	64a6                	ld	s1,72(sp)
ffffffffc0202f4c:	6906                	ld	s2,64(sp)
ffffffffc0202f4e:	79e2                	ld	s3,56(sp)
ffffffffc0202f50:	7a42                	ld	s4,48(sp)
ffffffffc0202f52:	7aa2                	ld	s5,40(sp)
ffffffffc0202f54:	7b02                	ld	s6,32(sp)
ffffffffc0202f56:	6be2                	ld	s7,24(sp)
ffffffffc0202f58:	6c42                	ld	s8,16(sp)
ffffffffc0202f5a:	6125                	addi	sp,sp,96
ffffffffc0202f5c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202f5e:	85a2                	mv	a1,s0
ffffffffc0202f60:	00002517          	auipc	a0,0x2
ffffffffc0202f64:	7b850513          	addi	a0,a0,1976 # ffffffffc0205718 <default_pmm_manager+0x948>
ffffffffc0202f68:	956fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202f6c:	bfe1                	j	ffffffffc0202f44 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202f6e:	4401                	li	s0,0
ffffffffc0202f70:	bfd1                	j	ffffffffc0202f44 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f72:	00002697          	auipc	a3,0x2
ffffffffc0202f76:	7d668693          	addi	a3,a3,2006 # ffffffffc0205748 <default_pmm_manager+0x978>
ffffffffc0202f7a:	00002617          	auipc	a2,0x2
ffffffffc0202f7e:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204a38 <commands+0x870>
ffffffffc0202f82:	06600593          	li	a1,102
ffffffffc0202f86:	00002517          	auipc	a0,0x2
ffffffffc0202f8a:	50a50513          	addi	a0,a0,1290 # ffffffffc0205490 <default_pmm_manager+0x6c0>
ffffffffc0202f8e:	be2fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202f92 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202f92:	4501                	li	a0,0
ffffffffc0202f94:	8082                	ret

ffffffffc0202f96 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202f96:	4501                	li	a0,0
ffffffffc0202f98:	8082                	ret

ffffffffc0202f9a <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202f9a:	4501                	li	a0,0
ffffffffc0202f9c:	8082                	ret

ffffffffc0202f9e <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0202f9e:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202fa0:	678d                	lui	a5,0x3
ffffffffc0202fa2:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0202fa4:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202fa6:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202faa:	0000d797          	auipc	a5,0xd
ffffffffc0202fae:	4c278793          	addi	a5,a5,1218 # ffffffffc021046c <pgfault_num>
ffffffffc0202fb2:	4398                	lw	a4,0(a5)
ffffffffc0202fb4:	4691                	li	a3,4
ffffffffc0202fb6:	2701                	sext.w	a4,a4
ffffffffc0202fb8:	08d71f63          	bne	a4,a3,ffffffffc0203056 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202fbc:	6685                	lui	a3,0x1
ffffffffc0202fbe:	4629                	li	a2,10
ffffffffc0202fc0:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202fc4:	4394                	lw	a3,0(a5)
ffffffffc0202fc6:	2681                	sext.w	a3,a3
ffffffffc0202fc8:	20e69763          	bne	a3,a4,ffffffffc02031d6 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202fcc:	6711                	lui	a4,0x4
ffffffffc0202fce:	4635                	li	a2,13
ffffffffc0202fd0:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0202fd4:	4398                	lw	a4,0(a5)
ffffffffc0202fd6:	2701                	sext.w	a4,a4
ffffffffc0202fd8:	1cd71f63          	bne	a4,a3,ffffffffc02031b6 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202fdc:	6689                	lui	a3,0x2
ffffffffc0202fde:	462d                	li	a2,11
ffffffffc0202fe0:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0202fe4:	4394                	lw	a3,0(a5)
ffffffffc0202fe6:	2681                	sext.w	a3,a3
ffffffffc0202fe8:	1ae69763          	bne	a3,a4,ffffffffc0203196 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202fec:	6715                	lui	a4,0x5
ffffffffc0202fee:	46b9                	li	a3,14
ffffffffc0202ff0:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0202ff4:	4398                	lw	a4,0(a5)
ffffffffc0202ff6:	4695                	li	a3,5
ffffffffc0202ff8:	2701                	sext.w	a4,a4
ffffffffc0202ffa:	16d71e63          	bne	a4,a3,ffffffffc0203176 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0202ffe:	4394                	lw	a3,0(a5)
ffffffffc0203000:	2681                	sext.w	a3,a3
ffffffffc0203002:	14e69a63          	bne	a3,a4,ffffffffc0203156 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0203006:	4398                	lw	a4,0(a5)
ffffffffc0203008:	2701                	sext.w	a4,a4
ffffffffc020300a:	12d71663          	bne	a4,a3,ffffffffc0203136 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc020300e:	4394                	lw	a3,0(a5)
ffffffffc0203010:	2681                	sext.w	a3,a3
ffffffffc0203012:	10e69263          	bne	a3,a4,ffffffffc0203116 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0203016:	4398                	lw	a4,0(a5)
ffffffffc0203018:	2701                	sext.w	a4,a4
ffffffffc020301a:	0cd71e63          	bne	a4,a3,ffffffffc02030f6 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc020301e:	4394                	lw	a3,0(a5)
ffffffffc0203020:	2681                	sext.w	a3,a3
ffffffffc0203022:	0ae69a63          	bne	a3,a4,ffffffffc02030d6 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203026:	6715                	lui	a4,0x5
ffffffffc0203028:	46b9                	li	a3,14
ffffffffc020302a:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020302e:	4398                	lw	a4,0(a5)
ffffffffc0203030:	4695                	li	a3,5
ffffffffc0203032:	2701                	sext.w	a4,a4
ffffffffc0203034:	08d71163          	bne	a4,a3,ffffffffc02030b6 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203038:	6705                	lui	a4,0x1
ffffffffc020303a:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020303e:	4729                	li	a4,10
ffffffffc0203040:	04e69b63          	bne	a3,a4,ffffffffc0203096 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203044:	439c                	lw	a5,0(a5)
ffffffffc0203046:	4719                	li	a4,6
ffffffffc0203048:	2781                	sext.w	a5,a5
ffffffffc020304a:	02e79663          	bne	a5,a4,ffffffffc0203076 <_clock_check_swap+0xd8>
}
ffffffffc020304e:	60a2                	ld	ra,8(sp)
ffffffffc0203050:	4501                	li	a0,0
ffffffffc0203052:	0141                	addi	sp,sp,16
ffffffffc0203054:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203056:	00002697          	auipc	a3,0x2
ffffffffc020305a:	60268693          	addi	a3,a3,1538 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc020305e:	00002617          	auipc	a2,0x2
ffffffffc0203062:	9da60613          	addi	a2,a2,-1574 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203066:	07700593          	li	a1,119
ffffffffc020306a:	00002517          	auipc	a0,0x2
ffffffffc020306e:	74e50513          	addi	a0,a0,1870 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203072:	afefd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==6);
ffffffffc0203076:	00002697          	auipc	a3,0x2
ffffffffc020307a:	79268693          	addi	a3,a3,1938 # ffffffffc0205808 <default_pmm_manager+0xa38>
ffffffffc020307e:	00002617          	auipc	a2,0x2
ffffffffc0203082:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203086:	08e00593          	li	a1,142
ffffffffc020308a:	00002517          	auipc	a0,0x2
ffffffffc020308e:	72e50513          	addi	a0,a0,1838 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203092:	adefd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203096:	00002697          	auipc	a3,0x2
ffffffffc020309a:	74a68693          	addi	a3,a3,1866 # ffffffffc02057e0 <default_pmm_manager+0xa10>
ffffffffc020309e:	00002617          	auipc	a2,0x2
ffffffffc02030a2:	99a60613          	addi	a2,a2,-1638 # ffffffffc0204a38 <commands+0x870>
ffffffffc02030a6:	08c00593          	li	a1,140
ffffffffc02030aa:	00002517          	auipc	a0,0x2
ffffffffc02030ae:	70e50513          	addi	a0,a0,1806 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02030b2:	abefd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02030b6:	00002697          	auipc	a3,0x2
ffffffffc02030ba:	71a68693          	addi	a3,a3,1818 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc02030be:	00002617          	auipc	a2,0x2
ffffffffc02030c2:	97a60613          	addi	a2,a2,-1670 # ffffffffc0204a38 <commands+0x870>
ffffffffc02030c6:	08b00593          	li	a1,139
ffffffffc02030ca:	00002517          	auipc	a0,0x2
ffffffffc02030ce:	6ee50513          	addi	a0,a0,1774 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02030d2:	a9efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02030d6:	00002697          	auipc	a3,0x2
ffffffffc02030da:	6fa68693          	addi	a3,a3,1786 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc02030de:	00002617          	auipc	a2,0x2
ffffffffc02030e2:	95a60613          	addi	a2,a2,-1702 # ffffffffc0204a38 <commands+0x870>
ffffffffc02030e6:	08900593          	li	a1,137
ffffffffc02030ea:	00002517          	auipc	a0,0x2
ffffffffc02030ee:	6ce50513          	addi	a0,a0,1742 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02030f2:	a7efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02030f6:	00002697          	auipc	a3,0x2
ffffffffc02030fa:	6da68693          	addi	a3,a3,1754 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc02030fe:	00002617          	auipc	a2,0x2
ffffffffc0203102:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203106:	08700593          	li	a1,135
ffffffffc020310a:	00002517          	auipc	a0,0x2
ffffffffc020310e:	6ae50513          	addi	a0,a0,1710 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203112:	a5efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203116:	00002697          	auipc	a3,0x2
ffffffffc020311a:	6ba68693          	addi	a3,a3,1722 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc020311e:	00002617          	auipc	a2,0x2
ffffffffc0203122:	91a60613          	addi	a2,a2,-1766 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203126:	08500593          	li	a1,133
ffffffffc020312a:	00002517          	auipc	a0,0x2
ffffffffc020312e:	68e50513          	addi	a0,a0,1678 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203132:	a3efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203136:	00002697          	auipc	a3,0x2
ffffffffc020313a:	69a68693          	addi	a3,a3,1690 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc020313e:	00002617          	auipc	a2,0x2
ffffffffc0203142:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203146:	08300593          	li	a1,131
ffffffffc020314a:	00002517          	auipc	a0,0x2
ffffffffc020314e:	66e50513          	addi	a0,a0,1646 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203152:	a1efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203156:	00002697          	auipc	a3,0x2
ffffffffc020315a:	67a68693          	addi	a3,a3,1658 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc020315e:	00002617          	auipc	a2,0x2
ffffffffc0203162:	8da60613          	addi	a2,a2,-1830 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203166:	08100593          	li	a1,129
ffffffffc020316a:	00002517          	auipc	a0,0x2
ffffffffc020316e:	64e50513          	addi	a0,a0,1614 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203172:	9fefd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203176:	00002697          	auipc	a3,0x2
ffffffffc020317a:	65a68693          	addi	a3,a3,1626 # ffffffffc02057d0 <default_pmm_manager+0xa00>
ffffffffc020317e:	00002617          	auipc	a2,0x2
ffffffffc0203182:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203186:	07f00593          	li	a1,127
ffffffffc020318a:	00002517          	auipc	a0,0x2
ffffffffc020318e:	62e50513          	addi	a0,a0,1582 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc0203192:	9defd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc0203196:	00002697          	auipc	a3,0x2
ffffffffc020319a:	4c268693          	addi	a3,a3,1218 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc020319e:	00002617          	auipc	a2,0x2
ffffffffc02031a2:	89a60613          	addi	a2,a2,-1894 # ffffffffc0204a38 <commands+0x870>
ffffffffc02031a6:	07d00593          	li	a1,125
ffffffffc02031aa:	00002517          	auipc	a0,0x2
ffffffffc02031ae:	60e50513          	addi	a0,a0,1550 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02031b2:	9befd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc02031b6:	00002697          	auipc	a3,0x2
ffffffffc02031ba:	4a268693          	addi	a3,a3,1186 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc02031be:	00002617          	auipc	a2,0x2
ffffffffc02031c2:	87a60613          	addi	a2,a2,-1926 # ffffffffc0204a38 <commands+0x870>
ffffffffc02031c6:	07b00593          	li	a1,123
ffffffffc02031ca:	00002517          	auipc	a0,0x2
ffffffffc02031ce:	5ee50513          	addi	a0,a0,1518 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02031d2:	99efd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc02031d6:	00002697          	auipc	a3,0x2
ffffffffc02031da:	48268693          	addi	a3,a3,1154 # ffffffffc0205658 <default_pmm_manager+0x888>
ffffffffc02031de:	00002617          	auipc	a2,0x2
ffffffffc02031e2:	85a60613          	addi	a2,a2,-1958 # ffffffffc0204a38 <commands+0x870>
ffffffffc02031e6:	07900593          	li	a1,121
ffffffffc02031ea:	00002517          	auipc	a0,0x2
ffffffffc02031ee:	5ce50513          	addi	a0,a0,1486 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc02031f2:	97efd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02031f6 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc02031f6:	751c                	ld	a5,40(a0)
{
ffffffffc02031f8:	1141                	addi	sp,sp,-16
ffffffffc02031fa:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02031fc:	c39d                	beqz	a5,ffffffffc0203222 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc02031fe:	e211                	bnez	a2,ffffffffc0203202 <_clock_swap_out_victim+0xc>
    }
ffffffffc0203200:	a001                	j	ffffffffc0203200 <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc0203202:	00002697          	auipc	a3,0x2
ffffffffc0203206:	64e68693          	addi	a3,a3,1614 # ffffffffc0205850 <default_pmm_manager+0xa80>
ffffffffc020320a:	00002617          	auipc	a2,0x2
ffffffffc020320e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203212:	04400593          	li	a1,68
ffffffffc0203216:	00002517          	auipc	a0,0x2
ffffffffc020321a:	5a250513          	addi	a0,a0,1442 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc020321e:	952fd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(head != NULL);
ffffffffc0203222:	00002697          	auipc	a3,0x2
ffffffffc0203226:	61e68693          	addi	a3,a3,1566 # ffffffffc0205840 <default_pmm_manager+0xa70>
ffffffffc020322a:	00002617          	auipc	a2,0x2
ffffffffc020322e:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203232:	04300593          	li	a1,67
ffffffffc0203236:	00002517          	auipc	a0,0x2
ffffffffc020323a:	58250513          	addi	a0,a0,1410 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
ffffffffc020323e:	932fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203242 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203242:	03060613          	addi	a2,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203246:	ca09                	beqz	a2,ffffffffc0203258 <_clock_map_swappable+0x16>
ffffffffc0203248:	0000d797          	auipc	a5,0xd
ffffffffc020324c:	34078793          	addi	a5,a5,832 # ffffffffc0210588 <curr_ptr>
ffffffffc0203250:	639c                	ld	a5,0(a5)
ffffffffc0203252:	c399                	beqz	a5,ffffffffc0203258 <_clock_map_swappable+0x16>
}
ffffffffc0203254:	4501                	li	a0,0
ffffffffc0203256:	8082                	ret
{
ffffffffc0203258:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020325a:	00002697          	auipc	a3,0x2
ffffffffc020325e:	5be68693          	addi	a3,a3,1470 # ffffffffc0205818 <default_pmm_manager+0xa48>
ffffffffc0203262:	00001617          	auipc	a2,0x1
ffffffffc0203266:	7d660613          	addi	a2,a2,2006 # ffffffffc0204a38 <commands+0x870>
ffffffffc020326a:	03300593          	li	a1,51
ffffffffc020326e:	00002517          	auipc	a0,0x2
ffffffffc0203272:	54a50513          	addi	a0,a0,1354 # ffffffffc02057b8 <default_pmm_manager+0x9e8>
{
ffffffffc0203276:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203278:	8f8fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020327c <_clock_tick_event>:
ffffffffc020327c:	4501                	li	a0,0
ffffffffc020327e:	8082                	ret

ffffffffc0203280 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203280:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203282:	00002697          	auipc	a3,0x2
ffffffffc0203286:	5f668693          	addi	a3,a3,1526 # ffffffffc0205878 <default_pmm_manager+0xaa8>
ffffffffc020328a:	00001617          	auipc	a2,0x1
ffffffffc020328e:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203292:	07d00593          	li	a1,125
ffffffffc0203296:	00002517          	auipc	a0,0x2
ffffffffc020329a:	60250513          	addi	a0,a0,1538 # ffffffffc0205898 <default_pmm_manager+0xac8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020329e:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02032a0:	8d0fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02032a4 <mm_create>:
mm_create(void) {
ffffffffc02032a4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032a6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02032aa:	e022                	sd	s0,0(sp)
ffffffffc02032ac:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032ae:	b8eff0ef          	jal	ra,ffffffffc020263c <kmalloc>
ffffffffc02032b2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02032b4:	c115                	beqz	a0,ffffffffc02032d8 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02032b6:	0000d797          	auipc	a5,0xd
ffffffffc02032ba:	1b278793          	addi	a5,a5,434 # ffffffffc0210468 <swap_init_ok>
ffffffffc02032be:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02032c0:	e408                	sd	a0,8(s0)
ffffffffc02032c2:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02032c4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02032c8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02032cc:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02032d0:	2781                	sext.w	a5,a5
ffffffffc02032d2:	eb81                	bnez	a5,ffffffffc02032e2 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02032d4:	02053423          	sd	zero,40(a0)
}
ffffffffc02032d8:	8522                	mv	a0,s0
ffffffffc02032da:	60a2                	ld	ra,8(sp)
ffffffffc02032dc:	6402                	ld	s0,0(sp)
ffffffffc02032de:	0141                	addi	sp,sp,16
ffffffffc02032e0:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02032e2:	b7dff0ef          	jal	ra,ffffffffc0202e5e <swap_init_mm>
}
ffffffffc02032e6:	8522                	mv	a0,s0
ffffffffc02032e8:	60a2                	ld	ra,8(sp)
ffffffffc02032ea:	6402                	ld	s0,0(sp)
ffffffffc02032ec:	0141                	addi	sp,sp,16
ffffffffc02032ee:	8082                	ret

ffffffffc02032f0 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02032f0:	1101                	addi	sp,sp,-32
ffffffffc02032f2:	e04a                	sd	s2,0(sp)
ffffffffc02032f4:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02032f6:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02032fa:	e822                	sd	s0,16(sp)
ffffffffc02032fc:	e426                	sd	s1,8(sp)
ffffffffc02032fe:	ec06                	sd	ra,24(sp)
ffffffffc0203300:	84ae                	mv	s1,a1
ffffffffc0203302:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203304:	b38ff0ef          	jal	ra,ffffffffc020263c <kmalloc>
    if (vma != NULL) {
ffffffffc0203308:	c509                	beqz	a0,ffffffffc0203312 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020330a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020330e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203310:	ed00                	sd	s0,24(a0)
}
ffffffffc0203312:	60e2                	ld	ra,24(sp)
ffffffffc0203314:	6442                	ld	s0,16(sp)
ffffffffc0203316:	64a2                	ld	s1,8(sp)
ffffffffc0203318:	6902                	ld	s2,0(sp)
ffffffffc020331a:	6105                	addi	sp,sp,32
ffffffffc020331c:	8082                	ret

ffffffffc020331e <find_vma>:
    if (mm != NULL) {
ffffffffc020331e:	c51d                	beqz	a0,ffffffffc020334c <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0203320:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203322:	c781                	beqz	a5,ffffffffc020332a <find_vma+0xc>
ffffffffc0203324:	6798                	ld	a4,8(a5)
ffffffffc0203326:	02e5f663          	bgeu	a1,a4,ffffffffc0203352 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020332a:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020332c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020332e:	00f50f63          	beq	a0,a5,ffffffffc020334c <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203332:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203336:	fee5ebe3          	bltu	a1,a4,ffffffffc020332c <find_vma+0xe>
ffffffffc020333a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020333e:	fee5f7e3          	bgeu	a1,a4,ffffffffc020332c <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203342:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203344:	c781                	beqz	a5,ffffffffc020334c <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203346:	e91c                	sd	a5,16(a0)
}
ffffffffc0203348:	853e                	mv	a0,a5
ffffffffc020334a:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020334c:	4781                	li	a5,0
}
ffffffffc020334e:	853e                	mv	a0,a5
ffffffffc0203350:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203352:	6b98                	ld	a4,16(a5)
ffffffffc0203354:	fce5fbe3          	bgeu	a1,a4,ffffffffc020332a <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203358:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020335a:	b7fd                	j	ffffffffc0203348 <find_vma+0x2a>

ffffffffc020335c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020335c:	6590                	ld	a2,8(a1)
ffffffffc020335e:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203362:	1141                	addi	sp,sp,-16
ffffffffc0203364:	e406                	sd	ra,8(sp)
ffffffffc0203366:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203368:	01066863          	bltu	a2,a6,ffffffffc0203378 <insert_vma_struct+0x1c>
ffffffffc020336c:	a8b9                	j	ffffffffc02033ca <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020336e:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203372:	04d66763          	bltu	a2,a3,ffffffffc02033c0 <insert_vma_struct+0x64>
ffffffffc0203376:	873e                	mv	a4,a5
ffffffffc0203378:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020337a:	fef51ae3          	bne	a0,a5,ffffffffc020336e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020337e:	02a70463          	beq	a4,a0,ffffffffc02033a6 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203382:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203386:	fe873883          	ld	a7,-24(a4)
ffffffffc020338a:	08d8f063          	bgeu	a7,a3,ffffffffc020340a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020338e:	04d66e63          	bltu	a2,a3,ffffffffc02033ea <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203392:	00f50a63          	beq	a0,a5,ffffffffc02033a6 <insert_vma_struct+0x4a>
ffffffffc0203396:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020339a:	0506e863          	bltu	a3,a6,ffffffffc02033ea <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020339e:	ff07b603          	ld	a2,-16(a5)
ffffffffc02033a2:	02c6f263          	bgeu	a3,a2,ffffffffc02033c6 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02033a6:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02033a8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02033aa:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02033ae:	e390                	sd	a2,0(a5)
ffffffffc02033b0:	e710                	sd	a2,8(a4)
}
ffffffffc02033b2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02033b4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02033b6:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02033b8:	2685                	addiw	a3,a3,1
ffffffffc02033ba:	d114                	sw	a3,32(a0)
}
ffffffffc02033bc:	0141                	addi	sp,sp,16
ffffffffc02033be:	8082                	ret
    if (le_prev != list) {
ffffffffc02033c0:	fca711e3          	bne	a4,a0,ffffffffc0203382 <insert_vma_struct+0x26>
ffffffffc02033c4:	bfd9                	j	ffffffffc020339a <insert_vma_struct+0x3e>
ffffffffc02033c6:	ebbff0ef          	jal	ra,ffffffffc0203280 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033ca:	00002697          	auipc	a3,0x2
ffffffffc02033ce:	55e68693          	addi	a3,a3,1374 # ffffffffc0205928 <default_pmm_manager+0xb58>
ffffffffc02033d2:	00001617          	auipc	a2,0x1
ffffffffc02033d6:	66660613          	addi	a2,a2,1638 # ffffffffc0204a38 <commands+0x870>
ffffffffc02033da:	08400593          	li	a1,132
ffffffffc02033de:	00002517          	auipc	a0,0x2
ffffffffc02033e2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02033e6:	f8bfc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033ea:	00002697          	auipc	a3,0x2
ffffffffc02033ee:	57e68693          	addi	a3,a3,1406 # ffffffffc0205968 <default_pmm_manager+0xb98>
ffffffffc02033f2:	00001617          	auipc	a2,0x1
ffffffffc02033f6:	64660613          	addi	a2,a2,1606 # ffffffffc0204a38 <commands+0x870>
ffffffffc02033fa:	07c00593          	li	a1,124
ffffffffc02033fe:	00002517          	auipc	a0,0x2
ffffffffc0203402:	49a50513          	addi	a0,a0,1178 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203406:	f6bfc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020340a:	00002697          	auipc	a3,0x2
ffffffffc020340e:	53e68693          	addi	a3,a3,1342 # ffffffffc0205948 <default_pmm_manager+0xb78>
ffffffffc0203412:	00001617          	auipc	a2,0x1
ffffffffc0203416:	62660613          	addi	a2,a2,1574 # ffffffffc0204a38 <commands+0x870>
ffffffffc020341a:	07b00593          	li	a1,123
ffffffffc020341e:	00002517          	auipc	a0,0x2
ffffffffc0203422:	47a50513          	addi	a0,a0,1146 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203426:	f4bfc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020342a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020342a:	1141                	addi	sp,sp,-16
ffffffffc020342c:	e022                	sd	s0,0(sp)
ffffffffc020342e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203430:	6508                	ld	a0,8(a0)
ffffffffc0203432:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203434:	00a40e63          	beq	s0,a0,ffffffffc0203450 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203438:	6118                	ld	a4,0(a0)
ffffffffc020343a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020343c:	03000593          	li	a1,48
ffffffffc0203440:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203442:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203444:	e398                	sd	a4,0(a5)
ffffffffc0203446:	ab8ff0ef          	jal	ra,ffffffffc02026fe <kfree>
    return listelm->next;
ffffffffc020344a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020344c:	fea416e3          	bne	s0,a0,ffffffffc0203438 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203450:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203452:	6402                	ld	s0,0(sp)
ffffffffc0203454:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203456:	03000593          	li	a1,48
}
ffffffffc020345a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020345c:	aa2ff06f          	j	ffffffffc02026fe <kfree>

ffffffffc0203460 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203460:	715d                	addi	sp,sp,-80
ffffffffc0203462:	e486                	sd	ra,72(sp)
ffffffffc0203464:	e0a2                	sd	s0,64(sp)
ffffffffc0203466:	fc26                	sd	s1,56(sp)
ffffffffc0203468:	f84a                	sd	s2,48(sp)
ffffffffc020346a:	f052                	sd	s4,32(sp)
ffffffffc020346c:	f44e                	sd	s3,40(sp)
ffffffffc020346e:	ec56                	sd	s5,24(sp)
ffffffffc0203470:	e85a                	sd	s6,16(sp)
ffffffffc0203472:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203474:	a78fe0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc0203478:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020347a:	a72fe0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc020347e:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203480:	e25ff0ef          	jal	ra,ffffffffc02032a4 <mm_create>
    assert(mm != NULL);
ffffffffc0203484:	842a                	mv	s0,a0
ffffffffc0203486:	03200493          	li	s1,50
ffffffffc020348a:	e919                	bnez	a0,ffffffffc02034a0 <vmm_init+0x40>
ffffffffc020348c:	aeed                	j	ffffffffc0203886 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc020348e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203490:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203492:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203496:	14ed                	addi	s1,s1,-5
ffffffffc0203498:	8522                	mv	a0,s0
ffffffffc020349a:	ec3ff0ef          	jal	ra,ffffffffc020335c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020349e:	c88d                	beqz	s1,ffffffffc02034d0 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034a0:	03000513          	li	a0,48
ffffffffc02034a4:	998ff0ef          	jal	ra,ffffffffc020263c <kmalloc>
ffffffffc02034a8:	85aa                	mv	a1,a0
ffffffffc02034aa:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02034ae:	f165                	bnez	a0,ffffffffc020348e <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc02034b0:	00002697          	auipc	a3,0x2
ffffffffc02034b4:	06868693          	addi	a3,a3,104 # ffffffffc0205518 <default_pmm_manager+0x748>
ffffffffc02034b8:	00001617          	auipc	a2,0x1
ffffffffc02034bc:	58060613          	addi	a2,a2,1408 # ffffffffc0204a38 <commands+0x870>
ffffffffc02034c0:	0ce00593          	li	a1,206
ffffffffc02034c4:	00002517          	auipc	a0,0x2
ffffffffc02034c8:	3d450513          	addi	a0,a0,980 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02034cc:	ea5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02034d0:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034d4:	1f900993          	li	s3,505
ffffffffc02034d8:	a819                	j	ffffffffc02034ee <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc02034da:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034dc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034de:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02034e2:	0495                	addi	s1,s1,5
ffffffffc02034e4:	8522                	mv	a0,s0
ffffffffc02034e6:	e77ff0ef          	jal	ra,ffffffffc020335c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034ea:	03348a63          	beq	s1,s3,ffffffffc020351e <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ee:	03000513          	li	a0,48
ffffffffc02034f2:	94aff0ef          	jal	ra,ffffffffc020263c <kmalloc>
ffffffffc02034f6:	85aa                	mv	a1,a0
ffffffffc02034f8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02034fc:	fd79                	bnez	a0,ffffffffc02034da <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02034fe:	00002697          	auipc	a3,0x2
ffffffffc0203502:	01a68693          	addi	a3,a3,26 # ffffffffc0205518 <default_pmm_manager+0x748>
ffffffffc0203506:	00001617          	auipc	a2,0x1
ffffffffc020350a:	53260613          	addi	a2,a2,1330 # ffffffffc0204a38 <commands+0x870>
ffffffffc020350e:	0d400593          	li	a1,212
ffffffffc0203512:	00002517          	auipc	a0,0x2
ffffffffc0203516:	38650513          	addi	a0,a0,902 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc020351a:	e57fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc020351e:	6418                	ld	a4,8(s0)
ffffffffc0203520:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203522:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203526:	2ae40063          	beq	s0,a4,ffffffffc02037c6 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020352a:	fe873603          	ld	a2,-24(a4)
ffffffffc020352e:	ffe78693          	addi	a3,a5,-2
ffffffffc0203532:	20d61a63          	bne	a2,a3,ffffffffc0203746 <vmm_init+0x2e6>
ffffffffc0203536:	ff073683          	ld	a3,-16(a4)
ffffffffc020353a:	20d79663          	bne	a5,a3,ffffffffc0203746 <vmm_init+0x2e6>
ffffffffc020353e:	0795                	addi	a5,a5,5
ffffffffc0203540:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203542:	feb792e3          	bne	a5,a1,ffffffffc0203526 <vmm_init+0xc6>
ffffffffc0203546:	499d                	li	s3,7
ffffffffc0203548:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020354a:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020354e:	85a6                	mv	a1,s1
ffffffffc0203550:	8522                	mv	a0,s0
ffffffffc0203552:	dcdff0ef          	jal	ra,ffffffffc020331e <find_vma>
ffffffffc0203556:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203558:	2e050763          	beqz	a0,ffffffffc0203846 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020355c:	00148593          	addi	a1,s1,1
ffffffffc0203560:	8522                	mv	a0,s0
ffffffffc0203562:	dbdff0ef          	jal	ra,ffffffffc020331e <find_vma>
ffffffffc0203566:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203568:	2a050f63          	beqz	a0,ffffffffc0203826 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020356c:	85ce                	mv	a1,s3
ffffffffc020356e:	8522                	mv	a0,s0
ffffffffc0203570:	dafff0ef          	jal	ra,ffffffffc020331e <find_vma>
        assert(vma3 == NULL);
ffffffffc0203574:	28051963          	bnez	a0,ffffffffc0203806 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203578:	00348593          	addi	a1,s1,3
ffffffffc020357c:	8522                	mv	a0,s0
ffffffffc020357e:	da1ff0ef          	jal	ra,ffffffffc020331e <find_vma>
        assert(vma4 == NULL);
ffffffffc0203582:	26051263          	bnez	a0,ffffffffc02037e6 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203586:	00448593          	addi	a1,s1,4
ffffffffc020358a:	8522                	mv	a0,s0
ffffffffc020358c:	d93ff0ef          	jal	ra,ffffffffc020331e <find_vma>
        assert(vma5 == NULL);
ffffffffc0203590:	2c051b63          	bnez	a0,ffffffffc0203866 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203594:	008b3783          	ld	a5,8(s6)
ffffffffc0203598:	1c979763          	bne	a5,s1,ffffffffc0203766 <vmm_init+0x306>
ffffffffc020359c:	010b3783          	ld	a5,16(s6)
ffffffffc02035a0:	1d379363          	bne	a5,s3,ffffffffc0203766 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02035a4:	008ab783          	ld	a5,8(s5)
ffffffffc02035a8:	1c979f63          	bne	a5,s1,ffffffffc0203786 <vmm_init+0x326>
ffffffffc02035ac:	010ab783          	ld	a5,16(s5)
ffffffffc02035b0:	1d379b63          	bne	a5,s3,ffffffffc0203786 <vmm_init+0x326>
ffffffffc02035b4:	0495                	addi	s1,s1,5
ffffffffc02035b6:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035b8:	f9749be3          	bne	s1,s7,ffffffffc020354e <vmm_init+0xee>
ffffffffc02035bc:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02035be:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02035c0:	85a6                	mv	a1,s1
ffffffffc02035c2:	8522                	mv	a0,s0
ffffffffc02035c4:	d5bff0ef          	jal	ra,ffffffffc020331e <find_vma>
ffffffffc02035c8:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02035cc:	c90d                	beqz	a0,ffffffffc02035fe <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02035ce:	6914                	ld	a3,16(a0)
ffffffffc02035d0:	6510                	ld	a2,8(a0)
ffffffffc02035d2:	00002517          	auipc	a0,0x2
ffffffffc02035d6:	4b650513          	addi	a0,a0,1206 # ffffffffc0205a88 <default_pmm_manager+0xcb8>
ffffffffc02035da:	ae5fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02035de:	00002697          	auipc	a3,0x2
ffffffffc02035e2:	4d268693          	addi	a3,a3,1234 # ffffffffc0205ab0 <default_pmm_manager+0xce0>
ffffffffc02035e6:	00001617          	auipc	a2,0x1
ffffffffc02035ea:	45260613          	addi	a2,a2,1106 # ffffffffc0204a38 <commands+0x870>
ffffffffc02035ee:	0f600593          	li	a1,246
ffffffffc02035f2:	00002517          	auipc	a0,0x2
ffffffffc02035f6:	2a650513          	addi	a0,a0,678 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02035fa:	d77fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02035fe:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203600:	fd3490e3          	bne	s1,s3,ffffffffc02035c0 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0203604:	8522                	mv	a0,s0
ffffffffc0203606:	e25ff0ef          	jal	ra,ffffffffc020342a <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020360a:	8e2fe0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc020360e:	28aa1c63          	bne	s4,a0,ffffffffc02038a6 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203612:	00002517          	auipc	a0,0x2
ffffffffc0203616:	4de50513          	addi	a0,a0,1246 # ffffffffc0205af0 <default_pmm_manager+0xd20>
ffffffffc020361a:	aa5fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020361e:	8cefe0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc0203622:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203624:	c81ff0ef          	jal	ra,ffffffffc02032a4 <mm_create>
ffffffffc0203628:	0000d797          	auipc	a5,0xd
ffffffffc020362c:	f6a7b423          	sd	a0,-152(a5) # ffffffffc0210590 <check_mm_struct>
ffffffffc0203630:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0203632:	2a050a63          	beqz	a0,ffffffffc02038e6 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203636:	0000d797          	auipc	a5,0xd
ffffffffc020363a:	e1a78793          	addi	a5,a5,-486 # ffffffffc0210450 <boot_pgdir>
ffffffffc020363e:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203640:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203642:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203644:	32079d63          	bnez	a5,ffffffffc020397e <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203648:	03000513          	li	a0,48
ffffffffc020364c:	ff1fe0ef          	jal	ra,ffffffffc020263c <kmalloc>
ffffffffc0203650:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203652:	14050a63          	beqz	a0,ffffffffc02037a6 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0203656:	002007b7          	lui	a5,0x200
ffffffffc020365a:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020365e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203660:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203662:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203666:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203668:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020366c:	cf1ff0ef          	jal	ra,ffffffffc020335c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203670:	10000593          	li	a1,256
ffffffffc0203674:	8522                	mv	a0,s0
ffffffffc0203676:	ca9ff0ef          	jal	ra,ffffffffc020331e <find_vma>
ffffffffc020367a:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020367e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203682:	2aaa1263          	bne	s4,a0,ffffffffc0203926 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0203686:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc020368a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020368c:	fee79de3          	bne	a5,a4,ffffffffc0203686 <vmm_init+0x226>
        sum += i;
ffffffffc0203690:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203692:	10000793          	li	a5,256
        sum += i;
ffffffffc0203696:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020369a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020369e:	0007c683          	lbu	a3,0(a5)
ffffffffc02036a2:	0785                	addi	a5,a5,1
ffffffffc02036a4:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02036a6:	fec79ce3          	bne	a5,a2,ffffffffc020369e <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02036aa:	2a071a63          	bnez	a4,ffffffffc020395e <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02036ae:	4581                	li	a1,0
ffffffffc02036b0:	8526                	mv	a0,s1
ffffffffc02036b2:	ad6fe0ef          	jal	ra,ffffffffc0201988 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036b6:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02036b8:	0000d717          	auipc	a4,0xd
ffffffffc02036bc:	da070713          	addi	a4,a4,-608 # ffffffffc0210458 <npage>
ffffffffc02036c0:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036c2:	078a                	slli	a5,a5,0x2
ffffffffc02036c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036c6:	28e7f063          	bgeu	a5,a4,ffffffffc0203946 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02036ca:	00002717          	auipc	a4,0x2
ffffffffc02036ce:	76670713          	addi	a4,a4,1894 # ffffffffc0205e30 <nbase>
ffffffffc02036d2:	6318                	ld	a4,0(a4)
ffffffffc02036d4:	0000d697          	auipc	a3,0xd
ffffffffc02036d8:	dd468693          	addi	a3,a3,-556 # ffffffffc02104a8 <pages>
ffffffffc02036dc:	6288                	ld	a0,0(a3)
ffffffffc02036de:	8f99                	sub	a5,a5,a4
ffffffffc02036e0:	00379713          	slli	a4,a5,0x3
ffffffffc02036e4:	97ba                	add	a5,a5,a4
ffffffffc02036e6:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02036e8:	953e                	add	a0,a0,a5
ffffffffc02036ea:	4585                	li	a1,1
ffffffffc02036ec:	fbbfd0ef          	jal	ra,ffffffffc02016a6 <free_pages>

    pgdir[0] = 0;
ffffffffc02036f0:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02036f4:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02036f6:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02036fa:	d31ff0ef          	jal	ra,ffffffffc020342a <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02036fe:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc0203700:	0000d797          	auipc	a5,0xd
ffffffffc0203704:	e807b823          	sd	zero,-368(a5) # ffffffffc0210590 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203708:	fe5fd0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
ffffffffc020370c:	1aa99d63          	bne	s3,a0,ffffffffc02038c6 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203710:	00002517          	auipc	a0,0x2
ffffffffc0203714:	44850513          	addi	a0,a0,1096 # ffffffffc0205b58 <default_pmm_manager+0xd88>
ffffffffc0203718:	9a7fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020371c:	fd1fd0ef          	jal	ra,ffffffffc02016ec <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203720:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203722:	1ea91263          	bne	s2,a0,ffffffffc0203906 <vmm_init+0x4a6>
}
ffffffffc0203726:	6406                	ld	s0,64(sp)
ffffffffc0203728:	60a6                	ld	ra,72(sp)
ffffffffc020372a:	74e2                	ld	s1,56(sp)
ffffffffc020372c:	7942                	ld	s2,48(sp)
ffffffffc020372e:	79a2                	ld	s3,40(sp)
ffffffffc0203730:	7a02                	ld	s4,32(sp)
ffffffffc0203732:	6ae2                	ld	s5,24(sp)
ffffffffc0203734:	6b42                	ld	s6,16(sp)
ffffffffc0203736:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203738:	00002517          	auipc	a0,0x2
ffffffffc020373c:	44050513          	addi	a0,a0,1088 # ffffffffc0205b78 <default_pmm_manager+0xda8>
}
ffffffffc0203740:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203742:	97dfc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203746:	00002697          	auipc	a3,0x2
ffffffffc020374a:	25a68693          	addi	a3,a3,602 # ffffffffc02059a0 <default_pmm_manager+0xbd0>
ffffffffc020374e:	00001617          	auipc	a2,0x1
ffffffffc0203752:	2ea60613          	addi	a2,a2,746 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203756:	0dd00593          	li	a1,221
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	13e50513          	addi	a0,a0,318 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203762:	c0ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203766:	00002697          	auipc	a3,0x2
ffffffffc020376a:	2c268693          	addi	a3,a3,706 # ffffffffc0205a28 <default_pmm_manager+0xc58>
ffffffffc020376e:	00001617          	auipc	a2,0x1
ffffffffc0203772:	2ca60613          	addi	a2,a2,714 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203776:	0ed00593          	li	a1,237
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	11e50513          	addi	a0,a0,286 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203782:	beffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203786:	00002697          	auipc	a3,0x2
ffffffffc020378a:	2d268693          	addi	a3,a3,722 # ffffffffc0205a58 <default_pmm_manager+0xc88>
ffffffffc020378e:	00001617          	auipc	a2,0x1
ffffffffc0203792:	2aa60613          	addi	a2,a2,682 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203796:	0ee00593          	li	a1,238
ffffffffc020379a:	00002517          	auipc	a0,0x2
ffffffffc020379e:	0fe50513          	addi	a0,a0,254 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02037a2:	bcffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(vma != NULL);
ffffffffc02037a6:	00002697          	auipc	a3,0x2
ffffffffc02037aa:	d7268693          	addi	a3,a3,-654 # ffffffffc0205518 <default_pmm_manager+0x748>
ffffffffc02037ae:	00001617          	auipc	a2,0x1
ffffffffc02037b2:	28a60613          	addi	a2,a2,650 # ffffffffc0204a38 <commands+0x870>
ffffffffc02037b6:	11100593          	li	a1,273
ffffffffc02037ba:	00002517          	auipc	a0,0x2
ffffffffc02037be:	0de50513          	addi	a0,a0,222 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02037c2:	baffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02037c6:	00002697          	auipc	a3,0x2
ffffffffc02037ca:	1c268693          	addi	a3,a3,450 # ffffffffc0205988 <default_pmm_manager+0xbb8>
ffffffffc02037ce:	00001617          	auipc	a2,0x1
ffffffffc02037d2:	26a60613          	addi	a2,a2,618 # ffffffffc0204a38 <commands+0x870>
ffffffffc02037d6:	0db00593          	li	a1,219
ffffffffc02037da:	00002517          	auipc	a0,0x2
ffffffffc02037de:	0be50513          	addi	a0,a0,190 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02037e2:	b8ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma4 == NULL);
ffffffffc02037e6:	00002697          	auipc	a3,0x2
ffffffffc02037ea:	22268693          	addi	a3,a3,546 # ffffffffc0205a08 <default_pmm_manager+0xc38>
ffffffffc02037ee:	00001617          	auipc	a2,0x1
ffffffffc02037f2:	24a60613          	addi	a2,a2,586 # ffffffffc0204a38 <commands+0x870>
ffffffffc02037f6:	0e900593          	li	a1,233
ffffffffc02037fa:	00002517          	auipc	a0,0x2
ffffffffc02037fe:	09e50513          	addi	a0,a0,158 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203802:	b6ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma3 == NULL);
ffffffffc0203806:	00002697          	auipc	a3,0x2
ffffffffc020380a:	1f268693          	addi	a3,a3,498 # ffffffffc02059f8 <default_pmm_manager+0xc28>
ffffffffc020380e:	00001617          	auipc	a2,0x1
ffffffffc0203812:	22a60613          	addi	a2,a2,554 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203816:	0e700593          	li	a1,231
ffffffffc020381a:	00002517          	auipc	a0,0x2
ffffffffc020381e:	07e50513          	addi	a0,a0,126 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203822:	b4ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2 != NULL);
ffffffffc0203826:	00002697          	auipc	a3,0x2
ffffffffc020382a:	1c268693          	addi	a3,a3,450 # ffffffffc02059e8 <default_pmm_manager+0xc18>
ffffffffc020382e:	00001617          	auipc	a2,0x1
ffffffffc0203832:	20a60613          	addi	a2,a2,522 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203836:	0e500593          	li	a1,229
ffffffffc020383a:	00002517          	auipc	a0,0x2
ffffffffc020383e:	05e50513          	addi	a0,a0,94 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203842:	b2ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1 != NULL);
ffffffffc0203846:	00002697          	auipc	a3,0x2
ffffffffc020384a:	19268693          	addi	a3,a3,402 # ffffffffc02059d8 <default_pmm_manager+0xc08>
ffffffffc020384e:	00001617          	auipc	a2,0x1
ffffffffc0203852:	1ea60613          	addi	a2,a2,490 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203856:	0e300593          	li	a1,227
ffffffffc020385a:	00002517          	auipc	a0,0x2
ffffffffc020385e:	03e50513          	addi	a0,a0,62 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203862:	b0ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma5 == NULL);
ffffffffc0203866:	00002697          	auipc	a3,0x2
ffffffffc020386a:	1b268693          	addi	a3,a3,434 # ffffffffc0205a18 <default_pmm_manager+0xc48>
ffffffffc020386e:	00001617          	auipc	a2,0x1
ffffffffc0203872:	1ca60613          	addi	a2,a2,458 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203876:	0eb00593          	li	a1,235
ffffffffc020387a:	00002517          	auipc	a0,0x2
ffffffffc020387e:	01e50513          	addi	a0,a0,30 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203882:	aeffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(mm != NULL);
ffffffffc0203886:	00002697          	auipc	a3,0x2
ffffffffc020388a:	c5a68693          	addi	a3,a3,-934 # ffffffffc02054e0 <default_pmm_manager+0x710>
ffffffffc020388e:	00001617          	auipc	a2,0x1
ffffffffc0203892:	1aa60613          	addi	a2,a2,426 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203896:	0c700593          	li	a1,199
ffffffffc020389a:	00002517          	auipc	a0,0x2
ffffffffc020389e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02038a2:	acffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038a6:	00002697          	auipc	a3,0x2
ffffffffc02038aa:	22268693          	addi	a3,a3,546 # ffffffffc0205ac8 <default_pmm_manager+0xcf8>
ffffffffc02038ae:	00001617          	auipc	a2,0x1
ffffffffc02038b2:	18a60613          	addi	a2,a2,394 # ffffffffc0204a38 <commands+0x870>
ffffffffc02038b6:	0fb00593          	li	a1,251
ffffffffc02038ba:	00002517          	auipc	a0,0x2
ffffffffc02038be:	fde50513          	addi	a0,a0,-34 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02038c2:	aaffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038c6:	00002697          	auipc	a3,0x2
ffffffffc02038ca:	20268693          	addi	a3,a3,514 # ffffffffc0205ac8 <default_pmm_manager+0xcf8>
ffffffffc02038ce:	00001617          	auipc	a2,0x1
ffffffffc02038d2:	16a60613          	addi	a2,a2,362 # ffffffffc0204a38 <commands+0x870>
ffffffffc02038d6:	12e00593          	li	a1,302
ffffffffc02038da:	00002517          	auipc	a0,0x2
ffffffffc02038de:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc02038e2:	a8ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02038e6:	00002697          	auipc	a3,0x2
ffffffffc02038ea:	22a68693          	addi	a3,a3,554 # ffffffffc0205b10 <default_pmm_manager+0xd40>
ffffffffc02038ee:	00001617          	auipc	a2,0x1
ffffffffc02038f2:	14a60613          	addi	a2,a2,330 # ffffffffc0204a38 <commands+0x870>
ffffffffc02038f6:	10a00593          	li	a1,266
ffffffffc02038fa:	00002517          	auipc	a0,0x2
ffffffffc02038fe:	f9e50513          	addi	a0,a0,-98 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203902:	a6ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203906:	00002697          	auipc	a3,0x2
ffffffffc020390a:	1c268693          	addi	a3,a3,450 # ffffffffc0205ac8 <default_pmm_manager+0xcf8>
ffffffffc020390e:	00001617          	auipc	a2,0x1
ffffffffc0203912:	12a60613          	addi	a2,a2,298 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203916:	0bd00593          	li	a1,189
ffffffffc020391a:	00002517          	auipc	a0,0x2
ffffffffc020391e:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203922:	a4ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203926:	00002697          	auipc	a3,0x2
ffffffffc020392a:	20268693          	addi	a3,a3,514 # ffffffffc0205b28 <default_pmm_manager+0xd58>
ffffffffc020392e:	00001617          	auipc	a2,0x1
ffffffffc0203932:	10a60613          	addi	a2,a2,266 # ffffffffc0204a38 <commands+0x870>
ffffffffc0203936:	11600593          	li	a1,278
ffffffffc020393a:	00002517          	auipc	a0,0x2
ffffffffc020393e:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc0203942:	a2ffc0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203946:	00001617          	auipc	a2,0x1
ffffffffc020394a:	55260613          	addi	a2,a2,1362 # ffffffffc0204e98 <default_pmm_manager+0xc8>
ffffffffc020394e:	06500593          	li	a1,101
ffffffffc0203952:	00001517          	auipc	a0,0x1
ffffffffc0203956:	56650513          	addi	a0,a0,1382 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc020395a:	a17fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(sum == 0);
ffffffffc020395e:	00002697          	auipc	a3,0x2
ffffffffc0203962:	1ea68693          	addi	a3,a3,490 # ffffffffc0205b48 <default_pmm_manager+0xd78>
ffffffffc0203966:	00001617          	auipc	a2,0x1
ffffffffc020396a:	0d260613          	addi	a2,a2,210 # ffffffffc0204a38 <commands+0x870>
ffffffffc020396e:	12000593          	li	a1,288
ffffffffc0203972:	00002517          	auipc	a0,0x2
ffffffffc0203976:	f2650513          	addi	a0,a0,-218 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc020397a:	9f7fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020397e:	00002697          	auipc	a3,0x2
ffffffffc0203982:	b8a68693          	addi	a3,a3,-1142 # ffffffffc0205508 <default_pmm_manager+0x738>
ffffffffc0203986:	00001617          	auipc	a2,0x1
ffffffffc020398a:	0b260613          	addi	a2,a2,178 # ffffffffc0204a38 <commands+0x870>
ffffffffc020398e:	10d00593          	li	a1,269
ffffffffc0203992:	00002517          	auipc	a0,0x2
ffffffffc0203996:	f0650513          	addi	a0,a0,-250 # ffffffffc0205898 <default_pmm_manager+0xac8>
ffffffffc020399a:	9d7fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020399e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020399e:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039a0:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039a2:	e822                	sd	s0,16(sp)
ffffffffc02039a4:	e426                	sd	s1,8(sp)
ffffffffc02039a6:	ec06                	sd	ra,24(sp)
ffffffffc02039a8:	e04a                	sd	s2,0(sp)
ffffffffc02039aa:	8432                	mv	s0,a2
ffffffffc02039ac:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039ae:	971ff0ef          	jal	ra,ffffffffc020331e <find_vma>

    pgfault_num++;
ffffffffc02039b2:	0000d797          	auipc	a5,0xd
ffffffffc02039b6:	aba78793          	addi	a5,a5,-1350 # ffffffffc021046c <pgfault_num>
ffffffffc02039ba:	439c                	lw	a5,0(a5)
ffffffffc02039bc:	2785                	addiw	a5,a5,1
ffffffffc02039be:	0000d717          	auipc	a4,0xd
ffffffffc02039c2:	aaf72723          	sw	a5,-1362(a4) # ffffffffc021046c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02039c6:	c939                	beqz	a0,ffffffffc0203a1c <do_pgfault+0x7e>
ffffffffc02039c8:	651c                	ld	a5,8(a0)
ffffffffc02039ca:	04f46963          	bltu	s0,a5,ffffffffc0203a1c <do_pgfault+0x7e>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02039ce:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02039d0:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02039d2:	8b89                	andi	a5,a5,2
ffffffffc02039d4:	e785                	bnez	a5,ffffffffc02039fc <do_pgfault+0x5e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02039d6:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02039d8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02039da:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02039dc:	85a2                	mv	a1,s0
ffffffffc02039de:	4605                	li	a2,1
ffffffffc02039e0:	d4dfd0ef          	jal	ra,ffffffffc020172c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02039e4:	610c                	ld	a1,0(a0)
ffffffffc02039e6:	cd89                	beqz	a1,ffffffffc0203a00 <do_pgfault+0x62>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02039e8:	0000d797          	auipc	a5,0xd
ffffffffc02039ec:	a8078793          	addi	a5,a5,-1408 # ffffffffc0210468 <swap_init_ok>
ffffffffc02039f0:	439c                	lw	a5,0(a5)
ffffffffc02039f2:	2781                	sext.w	a5,a5
ffffffffc02039f4:	cf8d                	beqz	a5,ffffffffc0203a2e <do_pgfault+0x90>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc02039f6:	04003023          	sd	zero,64(zero) # 40 <BASE_ADDRESS-0xffffffffc01fffc0>
ffffffffc02039fa:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc02039fc:	4959                	li	s2,22
ffffffffc02039fe:	bfe1                	j	ffffffffc02039d6 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a00:	6c88                	ld	a0,24(s1)
ffffffffc0203a02:	864a                	mv	a2,s2
ffffffffc0203a04:	85a2                	mv	a1,s0
ffffffffc0203a06:	ba5fe0ef          	jal	ra,ffffffffc02025aa <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203a0a:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a0c:	c90d                	beqz	a0,ffffffffc0203a3e <do_pgfault+0xa0>
failed:
    return ret;
}
ffffffffc0203a0e:	60e2                	ld	ra,24(sp)
ffffffffc0203a10:	6442                	ld	s0,16(sp)
ffffffffc0203a12:	64a2                	ld	s1,8(sp)
ffffffffc0203a14:	6902                	ld	s2,0(sp)
ffffffffc0203a16:	853e                	mv	a0,a5
ffffffffc0203a18:	6105                	addi	sp,sp,32
ffffffffc0203a1a:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203a1c:	85a2                	mv	a1,s0
ffffffffc0203a1e:	00002517          	auipc	a0,0x2
ffffffffc0203a22:	e8a50513          	addi	a0,a0,-374 # ffffffffc02058a8 <default_pmm_manager+0xad8>
ffffffffc0203a26:	e98fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203a2a:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203a2c:	b7cd                	j	ffffffffc0203a0e <do_pgfault+0x70>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203a2e:	00002517          	auipc	a0,0x2
ffffffffc0203a32:	ed250513          	addi	a0,a0,-302 # ffffffffc0205900 <default_pmm_manager+0xb30>
ffffffffc0203a36:	e88fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a3a:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203a3c:	bfc9                	j	ffffffffc0203a0e <do_pgfault+0x70>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203a3e:	00002517          	auipc	a0,0x2
ffffffffc0203a42:	e9a50513          	addi	a0,a0,-358 # ffffffffc02058d8 <default_pmm_manager+0xb08>
ffffffffc0203a46:	e78fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a4a:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203a4c:	b7c9                	j	ffffffffc0203a0e <do_pgfault+0x70>

ffffffffc0203a4e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203a4e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203a50:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203a52:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203a54:	a43fc0ef          	jal	ra,ffffffffc0200496 <ide_device_valid>
ffffffffc0203a58:	cd01                	beqz	a0,ffffffffc0203a70 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203a5a:	4505                	li	a0,1
ffffffffc0203a5c:	a41fc0ef          	jal	ra,ffffffffc020049c <ide_device_size>
}
ffffffffc0203a60:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203a62:	810d                	srli	a0,a0,0x3
ffffffffc0203a64:	0000d797          	auipc	a5,0xd
ffffffffc0203a68:	aca7ba23          	sd	a0,-1324(a5) # ffffffffc0210538 <max_swap_offset>
}
ffffffffc0203a6c:	0141                	addi	sp,sp,16
ffffffffc0203a6e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203a70:	00002617          	auipc	a2,0x2
ffffffffc0203a74:	12060613          	addi	a2,a2,288 # ffffffffc0205b90 <default_pmm_manager+0xdc0>
ffffffffc0203a78:	45b5                	li	a1,13
ffffffffc0203a7a:	00002517          	auipc	a0,0x2
ffffffffc0203a7e:	13650513          	addi	a0,a0,310 # ffffffffc0205bb0 <default_pmm_manager+0xde0>
ffffffffc0203a82:	8effc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203a86 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203a86:	1141                	addi	sp,sp,-16
ffffffffc0203a88:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203a8a:	00855793          	srli	a5,a0,0x8
ffffffffc0203a8e:	c7b5                	beqz	a5,ffffffffc0203afa <swapfs_write+0x74>
ffffffffc0203a90:	0000d717          	auipc	a4,0xd
ffffffffc0203a94:	aa870713          	addi	a4,a4,-1368 # ffffffffc0210538 <max_swap_offset>
ffffffffc0203a98:	6318                	ld	a4,0(a4)
ffffffffc0203a9a:	06e7f063          	bgeu	a5,a4,ffffffffc0203afa <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a9e:	0000d717          	auipc	a4,0xd
ffffffffc0203aa2:	a0a70713          	addi	a4,a4,-1526 # ffffffffc02104a8 <pages>
ffffffffc0203aa6:	6310                	ld	a2,0(a4)
ffffffffc0203aa8:	00001717          	auipc	a4,0x1
ffffffffc0203aac:	f7870713          	addi	a4,a4,-136 # ffffffffc0204a20 <commands+0x858>
ffffffffc0203ab0:	00002697          	auipc	a3,0x2
ffffffffc0203ab4:	38068693          	addi	a3,a3,896 # ffffffffc0205e30 <nbase>
ffffffffc0203ab8:	40c58633          	sub	a2,a1,a2
ffffffffc0203abc:	630c                	ld	a1,0(a4)
ffffffffc0203abe:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ac0:	0000d717          	auipc	a4,0xd
ffffffffc0203ac4:	99870713          	addi	a4,a4,-1640 # ffffffffc0210458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ac8:	02b60633          	mul	a2,a2,a1
ffffffffc0203acc:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ad0:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ad2:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ad4:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ad6:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ada:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203adc:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ade:	02e7fa63          	bgeu	a5,a4,ffffffffc0203b12 <swapfs_write+0x8c>
ffffffffc0203ae2:	0000d797          	auipc	a5,0xd
ffffffffc0203ae6:	9b678793          	addi	a5,a5,-1610 # ffffffffc0210498 <va_pa_offset>
ffffffffc0203aea:	639c                	ld	a5,0(a5)
}
ffffffffc0203aec:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203aee:	46a1                	li	a3,8
ffffffffc0203af0:	963e                	add	a2,a2,a5
ffffffffc0203af2:	4505                	li	a0,1
}
ffffffffc0203af4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203af6:	9adfc06f          	j	ffffffffc02004a2 <ide_write_secs>
ffffffffc0203afa:	86aa                	mv	a3,a0
ffffffffc0203afc:	00002617          	auipc	a2,0x2
ffffffffc0203b00:	0cc60613          	addi	a2,a2,204 # ffffffffc0205bc8 <default_pmm_manager+0xdf8>
ffffffffc0203b04:	45e5                	li	a1,25
ffffffffc0203b06:	00002517          	auipc	a0,0x2
ffffffffc0203b0a:	0aa50513          	addi	a0,a0,170 # ffffffffc0205bb0 <default_pmm_manager+0xde0>
ffffffffc0203b0e:	863fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203b12:	86b2                	mv	a3,a2
ffffffffc0203b14:	06a00593          	li	a1,106
ffffffffc0203b18:	00001617          	auipc	a2,0x1
ffffffffc0203b1c:	30860613          	addi	a2,a2,776 # ffffffffc0204e20 <default_pmm_manager+0x50>
ffffffffc0203b20:	00001517          	auipc	a0,0x1
ffffffffc0203b24:	39850513          	addi	a0,a0,920 # ffffffffc0204eb8 <default_pmm_manager+0xe8>
ffffffffc0203b28:	849fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203b2c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b2c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b30:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203b32:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b36:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b38:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b3c:	f022                	sd	s0,32(sp)
ffffffffc0203b3e:	ec26                	sd	s1,24(sp)
ffffffffc0203b40:	e84a                	sd	s2,16(sp)
ffffffffc0203b42:	f406                	sd	ra,40(sp)
ffffffffc0203b44:	e44e                	sd	s3,8(sp)
ffffffffc0203b46:	84aa                	mv	s1,a0
ffffffffc0203b48:	892e                	mv	s2,a1
ffffffffc0203b4a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203b4e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203b50:	03067e63          	bgeu	a2,a6,ffffffffc0203b8c <printnum+0x60>
ffffffffc0203b54:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203b56:	00805763          	blez	s0,ffffffffc0203b64 <printnum+0x38>
ffffffffc0203b5a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b5c:	85ca                	mv	a1,s2
ffffffffc0203b5e:	854e                	mv	a0,s3
ffffffffc0203b60:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b62:	fc65                	bnez	s0,ffffffffc0203b5a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b64:	1a02                	slli	s4,s4,0x20
ffffffffc0203b66:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203b6a:	00002797          	auipc	a5,0x2
ffffffffc0203b6e:	20e78793          	addi	a5,a5,526 # ffffffffc0205d78 <error_string+0x38>
ffffffffc0203b72:	9a3e                	add	s4,s4,a5
}
ffffffffc0203b74:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b76:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203b7a:	70a2                	ld	ra,40(sp)
ffffffffc0203b7c:	69a2                	ld	s3,8(sp)
ffffffffc0203b7e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b80:	85ca                	mv	a1,s2
ffffffffc0203b82:	8326                	mv	t1,s1
}
ffffffffc0203b84:	6942                	ld	s2,16(sp)
ffffffffc0203b86:	64e2                	ld	s1,24(sp)
ffffffffc0203b88:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b8a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203b8c:	03065633          	divu	a2,a2,a6
ffffffffc0203b90:	8722                	mv	a4,s0
ffffffffc0203b92:	f9bff0ef          	jal	ra,ffffffffc0203b2c <printnum>
ffffffffc0203b96:	b7f9                	j	ffffffffc0203b64 <printnum+0x38>

ffffffffc0203b98 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203b98:	7119                	addi	sp,sp,-128
ffffffffc0203b9a:	f4a6                	sd	s1,104(sp)
ffffffffc0203b9c:	f0ca                	sd	s2,96(sp)
ffffffffc0203b9e:	e8d2                	sd	s4,80(sp)
ffffffffc0203ba0:	e4d6                	sd	s5,72(sp)
ffffffffc0203ba2:	e0da                	sd	s6,64(sp)
ffffffffc0203ba4:	fc5e                	sd	s7,56(sp)
ffffffffc0203ba6:	f862                	sd	s8,48(sp)
ffffffffc0203ba8:	f06a                	sd	s10,32(sp)
ffffffffc0203baa:	fc86                	sd	ra,120(sp)
ffffffffc0203bac:	f8a2                	sd	s0,112(sp)
ffffffffc0203bae:	ecce                	sd	s3,88(sp)
ffffffffc0203bb0:	f466                	sd	s9,40(sp)
ffffffffc0203bb2:	ec6e                	sd	s11,24(sp)
ffffffffc0203bb4:	892a                	mv	s2,a0
ffffffffc0203bb6:	84ae                	mv	s1,a1
ffffffffc0203bb8:	8d32                	mv	s10,a2
ffffffffc0203bba:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203bbc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bbe:	00002a17          	auipc	s4,0x2
ffffffffc0203bc2:	02aa0a13          	addi	s4,s4,42 # ffffffffc0205be8 <default_pmm_manager+0xe18>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203bc6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203bca:	00002c17          	auipc	s8,0x2
ffffffffc0203bce:	176c0c13          	addi	s8,s8,374 # ffffffffc0205d40 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bd2:	000d4503          	lbu	a0,0(s10)
ffffffffc0203bd6:	02500793          	li	a5,37
ffffffffc0203bda:	001d0413          	addi	s0,s10,1
ffffffffc0203bde:	00f50e63          	beq	a0,a5,ffffffffc0203bfa <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203be2:	c521                	beqz	a0,ffffffffc0203c2a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203be4:	02500993          	li	s3,37
ffffffffc0203be8:	a011                	j	ffffffffc0203bec <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203bea:	c121                	beqz	a0,ffffffffc0203c2a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203bec:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bee:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203bf0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bf2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203bf6:	ff351ae3          	bne	a0,s3,ffffffffc0203bea <vprintfmt+0x52>
ffffffffc0203bfa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203bfe:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203c02:	4981                	li	s3,0
ffffffffc0203c04:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203c06:	5cfd                	li	s9,-1
ffffffffc0203c08:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c0a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203c0e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c10:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203c14:	0ff6f693          	andi	a3,a3,255
ffffffffc0203c18:	00140d13          	addi	s10,s0,1
ffffffffc0203c1c:	1ed5ef63          	bltu	a1,a3,ffffffffc0203e1a <vprintfmt+0x282>
ffffffffc0203c20:	068a                	slli	a3,a3,0x2
ffffffffc0203c22:	96d2                	add	a3,a3,s4
ffffffffc0203c24:	4294                	lw	a3,0(a3)
ffffffffc0203c26:	96d2                	add	a3,a3,s4
ffffffffc0203c28:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c2a:	70e6                	ld	ra,120(sp)
ffffffffc0203c2c:	7446                	ld	s0,112(sp)
ffffffffc0203c2e:	74a6                	ld	s1,104(sp)
ffffffffc0203c30:	7906                	ld	s2,96(sp)
ffffffffc0203c32:	69e6                	ld	s3,88(sp)
ffffffffc0203c34:	6a46                	ld	s4,80(sp)
ffffffffc0203c36:	6aa6                	ld	s5,72(sp)
ffffffffc0203c38:	6b06                	ld	s6,64(sp)
ffffffffc0203c3a:	7be2                	ld	s7,56(sp)
ffffffffc0203c3c:	7c42                	ld	s8,48(sp)
ffffffffc0203c3e:	7ca2                	ld	s9,40(sp)
ffffffffc0203c40:	7d02                	ld	s10,32(sp)
ffffffffc0203c42:	6de2                	ld	s11,24(sp)
ffffffffc0203c44:	6109                	addi	sp,sp,128
ffffffffc0203c46:	8082                	ret
            padc = '-';
ffffffffc0203c48:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c4a:	00144603          	lbu	a2,1(s0)
ffffffffc0203c4e:	846a                	mv	s0,s10
ffffffffc0203c50:	b7c1                	j	ffffffffc0203c10 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0203c52:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203c56:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203c5a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c5c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203c5e:	fa0dd9e3          	bgez	s11,ffffffffc0203c10 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203c62:	8de6                	mv	s11,s9
ffffffffc0203c64:	5cfd                	li	s9,-1
ffffffffc0203c66:	b76d                	j	ffffffffc0203c10 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0203c68:	fffdc693          	not	a3,s11
ffffffffc0203c6c:	96fd                	srai	a3,a3,0x3f
ffffffffc0203c6e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203c72:	00144603          	lbu	a2,1(s0)
ffffffffc0203c76:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c78:	846a                	mv	s0,s10
ffffffffc0203c7a:	bf59                	j	ffffffffc0203c10 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203c7c:	4705                	li	a4,1
ffffffffc0203c7e:	008a8593          	addi	a1,s5,8
ffffffffc0203c82:	01074463          	blt	a4,a6,ffffffffc0203c8a <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0203c86:	22080863          	beqz	a6,ffffffffc0203eb6 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0203c8a:	000ab603          	ld	a2,0(s5)
ffffffffc0203c8e:	46c1                	li	a3,16
ffffffffc0203c90:	8aae                	mv	s5,a1
ffffffffc0203c92:	a291                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0203c94:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203c98:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c9c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203c9e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203ca2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203ca6:	fad56ce3          	bltu	a0,a3,ffffffffc0203c5e <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203caa:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203cac:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203cb0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203cb4:	0196873b          	addw	a4,a3,s9
ffffffffc0203cb8:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203cbc:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203cc0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203cc4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203cc8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203ccc:	fcd57fe3          	bgeu	a0,a3,ffffffffc0203caa <vprintfmt+0x112>
ffffffffc0203cd0:	b779                	j	ffffffffc0203c5e <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0203cd2:	000aa503          	lw	a0,0(s5)
ffffffffc0203cd6:	85a6                	mv	a1,s1
ffffffffc0203cd8:	0aa1                	addi	s5,s5,8
ffffffffc0203cda:	9902                	jalr	s2
            break;
ffffffffc0203cdc:	bddd                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203cde:	4705                	li	a4,1
ffffffffc0203ce0:	008a8993          	addi	s3,s5,8
ffffffffc0203ce4:	01074463          	blt	a4,a6,ffffffffc0203cec <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0203ce8:	1c080463          	beqz	a6,ffffffffc0203eb0 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0203cec:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203cf0:	1c044a63          	bltz	s0,ffffffffc0203ec4 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0203cf4:	8622                	mv	a2,s0
ffffffffc0203cf6:	8ace                	mv	s5,s3
ffffffffc0203cf8:	46a9                	li	a3,10
ffffffffc0203cfa:	a8f1                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0203cfc:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d00:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203d02:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203d04:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203d08:	8fb5                	xor	a5,a5,a3
ffffffffc0203d0a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d0e:	12d74963          	blt	a4,a3,ffffffffc0203e40 <vprintfmt+0x2a8>
ffffffffc0203d12:	00369793          	slli	a5,a3,0x3
ffffffffc0203d16:	97e2                	add	a5,a5,s8
ffffffffc0203d18:	639c                	ld	a5,0(a5)
ffffffffc0203d1a:	12078363          	beqz	a5,ffffffffc0203e40 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203d1e:	86be                	mv	a3,a5
ffffffffc0203d20:	00002617          	auipc	a2,0x2
ffffffffc0203d24:	10860613          	addi	a2,a2,264 # ffffffffc0205e28 <error_string+0xe8>
ffffffffc0203d28:	85a6                	mv	a1,s1
ffffffffc0203d2a:	854a                	mv	a0,s2
ffffffffc0203d2c:	1cc000ef          	jal	ra,ffffffffc0203ef8 <printfmt>
ffffffffc0203d30:	b54d                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d32:	000ab603          	ld	a2,0(s5)
ffffffffc0203d36:	0aa1                	addi	s5,s5,8
ffffffffc0203d38:	1a060163          	beqz	a2,ffffffffc0203eda <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0203d3c:	00160413          	addi	s0,a2,1
ffffffffc0203d40:	15b05763          	blez	s11,ffffffffc0203e8e <vprintfmt+0x2f6>
ffffffffc0203d44:	02d00593          	li	a1,45
ffffffffc0203d48:	10b79d63          	bne	a5,a1,ffffffffc0203e62 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d4c:	00064783          	lbu	a5,0(a2)
ffffffffc0203d50:	0007851b          	sext.w	a0,a5
ffffffffc0203d54:	c905                	beqz	a0,ffffffffc0203d84 <vprintfmt+0x1ec>
ffffffffc0203d56:	000cc563          	bltz	s9,ffffffffc0203d60 <vprintfmt+0x1c8>
ffffffffc0203d5a:	3cfd                	addiw	s9,s9,-1
ffffffffc0203d5c:	036c8263          	beq	s9,s6,ffffffffc0203d80 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0203d60:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d62:	14098f63          	beqz	s3,ffffffffc0203ec0 <vprintfmt+0x328>
ffffffffc0203d66:	3781                	addiw	a5,a5,-32
ffffffffc0203d68:	14fbfc63          	bgeu	s7,a5,ffffffffc0203ec0 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0203d6c:	03f00513          	li	a0,63
ffffffffc0203d70:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d72:	0405                	addi	s0,s0,1
ffffffffc0203d74:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203d78:	3dfd                	addiw	s11,s11,-1
ffffffffc0203d7a:	0007851b          	sext.w	a0,a5
ffffffffc0203d7e:	fd61                	bnez	a0,ffffffffc0203d56 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0203d80:	e5b059e3          	blez	s11,ffffffffc0203bd2 <vprintfmt+0x3a>
ffffffffc0203d84:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203d86:	85a6                	mv	a1,s1
ffffffffc0203d88:	02000513          	li	a0,32
ffffffffc0203d8c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203d8e:	e40d82e3          	beqz	s11,ffffffffc0203bd2 <vprintfmt+0x3a>
ffffffffc0203d92:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203d94:	85a6                	mv	a1,s1
ffffffffc0203d96:	02000513          	li	a0,32
ffffffffc0203d9a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203d9c:	fe0d94e3          	bnez	s11,ffffffffc0203d84 <vprintfmt+0x1ec>
ffffffffc0203da0:	bd0d                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203da2:	4705                	li	a4,1
ffffffffc0203da4:	008a8593          	addi	a1,s5,8
ffffffffc0203da8:	01074463          	blt	a4,a6,ffffffffc0203db0 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0203dac:	0e080863          	beqz	a6,ffffffffc0203e9c <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0203db0:	000ab603          	ld	a2,0(s5)
ffffffffc0203db4:	46a1                	li	a3,8
ffffffffc0203db6:	8aae                	mv	s5,a1
ffffffffc0203db8:	a839                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0203dba:	03000513          	li	a0,48
ffffffffc0203dbe:	85a6                	mv	a1,s1
ffffffffc0203dc0:	e03e                	sd	a5,0(sp)
ffffffffc0203dc2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203dc4:	85a6                	mv	a1,s1
ffffffffc0203dc6:	07800513          	li	a0,120
ffffffffc0203dca:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203dcc:	0aa1                	addi	s5,s5,8
ffffffffc0203dce:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203dd2:	6782                	ld	a5,0(sp)
ffffffffc0203dd4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203dd6:	2781                	sext.w	a5,a5
ffffffffc0203dd8:	876e                	mv	a4,s11
ffffffffc0203dda:	85a6                	mv	a1,s1
ffffffffc0203ddc:	854a                	mv	a0,s2
ffffffffc0203dde:	d4fff0ef          	jal	ra,ffffffffc0203b2c <printnum>
            break;
ffffffffc0203de2:	bbc5                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203de4:	00144603          	lbu	a2,1(s0)
ffffffffc0203de8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203dea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203dec:	b515                	j	ffffffffc0203c10 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0203dee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203df2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203df4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203df6:	bd29                	j	ffffffffc0203c10 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0203df8:	85a6                	mv	a1,s1
ffffffffc0203dfa:	02500513          	li	a0,37
ffffffffc0203dfe:	9902                	jalr	s2
            break;
ffffffffc0203e00:	bbc9                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203e02:	4705                	li	a4,1
ffffffffc0203e04:	008a8593          	addi	a1,s5,8
ffffffffc0203e08:	01074463          	blt	a4,a6,ffffffffc0203e10 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0203e0c:	08080d63          	beqz	a6,ffffffffc0203ea6 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0203e10:	000ab603          	ld	a2,0(s5)
ffffffffc0203e14:	46a9                	li	a3,10
ffffffffc0203e16:	8aae                	mv	s5,a1
ffffffffc0203e18:	bf7d                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0203e1a:	85a6                	mv	a1,s1
ffffffffc0203e1c:	02500513          	li	a0,37
ffffffffc0203e20:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203e22:	fff44703          	lbu	a4,-1(s0)
ffffffffc0203e26:	02500793          	li	a5,37
ffffffffc0203e2a:	8d22                	mv	s10,s0
ffffffffc0203e2c:	daf703e3          	beq	a4,a5,ffffffffc0203bd2 <vprintfmt+0x3a>
ffffffffc0203e30:	02500713          	li	a4,37
ffffffffc0203e34:	1d7d                	addi	s10,s10,-1
ffffffffc0203e36:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0203e3a:	fee79de3          	bne	a5,a4,ffffffffc0203e34 <vprintfmt+0x29c>
ffffffffc0203e3e:	bb51                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203e40:	00002617          	auipc	a2,0x2
ffffffffc0203e44:	fd860613          	addi	a2,a2,-40 # ffffffffc0205e18 <error_string+0xd8>
ffffffffc0203e48:	85a6                	mv	a1,s1
ffffffffc0203e4a:	854a                	mv	a0,s2
ffffffffc0203e4c:	0ac000ef          	jal	ra,ffffffffc0203ef8 <printfmt>
ffffffffc0203e50:	b349                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203e52:	00002617          	auipc	a2,0x2
ffffffffc0203e56:	fbe60613          	addi	a2,a2,-66 # ffffffffc0205e10 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0203e5a:	00002417          	auipc	s0,0x2
ffffffffc0203e5e:	fb740413          	addi	s0,s0,-73 # ffffffffc0205e11 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e62:	8532                	mv	a0,a2
ffffffffc0203e64:	85e6                	mv	a1,s9
ffffffffc0203e66:	e032                	sd	a2,0(sp)
ffffffffc0203e68:	e43e                	sd	a5,8(sp)
ffffffffc0203e6a:	18a000ef          	jal	ra,ffffffffc0203ff4 <strnlen>
ffffffffc0203e6e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203e72:	6602                	ld	a2,0(sp)
ffffffffc0203e74:	01b05d63          	blez	s11,ffffffffc0203e8e <vprintfmt+0x2f6>
ffffffffc0203e78:	67a2                	ld	a5,8(sp)
ffffffffc0203e7a:	2781                	sext.w	a5,a5
ffffffffc0203e7c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0203e7e:	6522                	ld	a0,8(sp)
ffffffffc0203e80:	85a6                	mv	a1,s1
ffffffffc0203e82:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e84:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203e86:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e88:	6602                	ld	a2,0(sp)
ffffffffc0203e8a:	fe0d9ae3          	bnez	s11,ffffffffc0203e7e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e8e:	00064783          	lbu	a5,0(a2)
ffffffffc0203e92:	0007851b          	sext.w	a0,a5
ffffffffc0203e96:	ec0510e3          	bnez	a0,ffffffffc0203d56 <vprintfmt+0x1be>
ffffffffc0203e9a:	bb25                	j	ffffffffc0203bd2 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0203e9c:	000ae603          	lwu	a2,0(s5)
ffffffffc0203ea0:	46a1                	li	a3,8
ffffffffc0203ea2:	8aae                	mv	s5,a1
ffffffffc0203ea4:	bf0d                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
ffffffffc0203ea6:	000ae603          	lwu	a2,0(s5)
ffffffffc0203eaa:	46a9                	li	a3,10
ffffffffc0203eac:	8aae                	mv	s5,a1
ffffffffc0203eae:	b725                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0203eb0:	000aa403          	lw	s0,0(s5)
ffffffffc0203eb4:	bd35                	j	ffffffffc0203cf0 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0203eb6:	000ae603          	lwu	a2,0(s5)
ffffffffc0203eba:	46c1                	li	a3,16
ffffffffc0203ebc:	8aae                	mv	s5,a1
ffffffffc0203ebe:	bf21                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0203ec0:	9902                	jalr	s2
ffffffffc0203ec2:	bd45                	j	ffffffffc0203d72 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0203ec4:	85a6                	mv	a1,s1
ffffffffc0203ec6:	02d00513          	li	a0,45
ffffffffc0203eca:	e03e                	sd	a5,0(sp)
ffffffffc0203ecc:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203ece:	8ace                	mv	s5,s3
ffffffffc0203ed0:	40800633          	neg	a2,s0
ffffffffc0203ed4:	46a9                	li	a3,10
ffffffffc0203ed6:	6782                	ld	a5,0(sp)
ffffffffc0203ed8:	bdfd                	j	ffffffffc0203dd6 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0203eda:	01b05663          	blez	s11,ffffffffc0203ee6 <vprintfmt+0x34e>
ffffffffc0203ede:	02d00693          	li	a3,45
ffffffffc0203ee2:	f6d798e3          	bne	a5,a3,ffffffffc0203e52 <vprintfmt+0x2ba>
ffffffffc0203ee6:	00002417          	auipc	s0,0x2
ffffffffc0203eea:	f2b40413          	addi	s0,s0,-213 # ffffffffc0205e11 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203eee:	02800513          	li	a0,40
ffffffffc0203ef2:	02800793          	li	a5,40
ffffffffc0203ef6:	b585                	j	ffffffffc0203d56 <vprintfmt+0x1be>

ffffffffc0203ef8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ef8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203efa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203efe:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f00:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f02:	ec06                	sd	ra,24(sp)
ffffffffc0203f04:	f83a                	sd	a4,48(sp)
ffffffffc0203f06:	fc3e                	sd	a5,56(sp)
ffffffffc0203f08:	e0c2                	sd	a6,64(sp)
ffffffffc0203f0a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203f0c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f0e:	c8bff0ef          	jal	ra,ffffffffc0203b98 <vprintfmt>
}
ffffffffc0203f12:	60e2                	ld	ra,24(sp)
ffffffffc0203f14:	6161                	addi	sp,sp,80
ffffffffc0203f16:	8082                	ret

ffffffffc0203f18 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0203f18:	715d                	addi	sp,sp,-80
ffffffffc0203f1a:	e486                	sd	ra,72(sp)
ffffffffc0203f1c:	e0a2                	sd	s0,64(sp)
ffffffffc0203f1e:	fc26                	sd	s1,56(sp)
ffffffffc0203f20:	f84a                	sd	s2,48(sp)
ffffffffc0203f22:	f44e                	sd	s3,40(sp)
ffffffffc0203f24:	f052                	sd	s4,32(sp)
ffffffffc0203f26:	ec56                	sd	s5,24(sp)
ffffffffc0203f28:	e85a                	sd	s6,16(sp)
ffffffffc0203f2a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0203f2c:	c901                	beqz	a0,ffffffffc0203f3c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0203f2e:	85aa                	mv	a1,a0
ffffffffc0203f30:	00002517          	auipc	a0,0x2
ffffffffc0203f34:	ef850513          	addi	a0,a0,-264 # ffffffffc0205e28 <error_string+0xe8>
ffffffffc0203f38:	986fc0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0203f3c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f3e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0203f40:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0203f42:	4aa9                	li	s5,10
ffffffffc0203f44:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0203f46:	0000cb97          	auipc	s7,0xc
ffffffffc0203f4a:	0fab8b93          	addi	s7,s7,250 # ffffffffc0210040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f4e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0203f52:	9a2fc0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0203f56:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203f58:	00054b63          	bltz	a0,ffffffffc0203f6e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f5c:	00a95b63          	bge	s2,a0,ffffffffc0203f72 <readline+0x5a>
ffffffffc0203f60:	029a5463          	bge	s4,s1,ffffffffc0203f88 <readline+0x70>
        c = getchar();
ffffffffc0203f64:	990fc0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0203f68:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203f6a:	fe0559e3          	bgez	a0,ffffffffc0203f5c <readline+0x44>
            return NULL;
ffffffffc0203f6e:	4501                	li	a0,0
ffffffffc0203f70:	a099                	j	ffffffffc0203fb6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0203f72:	03341463          	bne	s0,s3,ffffffffc0203f9a <readline+0x82>
ffffffffc0203f76:	e8b9                	bnez	s1,ffffffffc0203fcc <readline+0xb4>
        c = getchar();
ffffffffc0203f78:	97cfc0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0203f7c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203f7e:	fe0548e3          	bltz	a0,ffffffffc0203f6e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f82:	fea958e3          	bge	s2,a0,ffffffffc0203f72 <readline+0x5a>
ffffffffc0203f86:	4481                	li	s1,0
            cputchar(c);
ffffffffc0203f88:	8522                	mv	a0,s0
ffffffffc0203f8a:	968fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0203f8e:	009b87b3          	add	a5,s7,s1
ffffffffc0203f92:	00878023          	sb	s0,0(a5)
ffffffffc0203f96:	2485                	addiw	s1,s1,1
ffffffffc0203f98:	bf6d                	j	ffffffffc0203f52 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0203f9a:	01540463          	beq	s0,s5,ffffffffc0203fa2 <readline+0x8a>
ffffffffc0203f9e:	fb641ae3          	bne	s0,s6,ffffffffc0203f52 <readline+0x3a>
            cputchar(c);
ffffffffc0203fa2:	8522                	mv	a0,s0
ffffffffc0203fa4:	94efc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0203fa8:	0000c517          	auipc	a0,0xc
ffffffffc0203fac:	09850513          	addi	a0,a0,152 # ffffffffc0210040 <buf>
ffffffffc0203fb0:	94aa                	add	s1,s1,a0
ffffffffc0203fb2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0203fb6:	60a6                	ld	ra,72(sp)
ffffffffc0203fb8:	6406                	ld	s0,64(sp)
ffffffffc0203fba:	74e2                	ld	s1,56(sp)
ffffffffc0203fbc:	7942                	ld	s2,48(sp)
ffffffffc0203fbe:	79a2                	ld	s3,40(sp)
ffffffffc0203fc0:	7a02                	ld	s4,32(sp)
ffffffffc0203fc2:	6ae2                	ld	s5,24(sp)
ffffffffc0203fc4:	6b42                	ld	s6,16(sp)
ffffffffc0203fc6:	6ba2                	ld	s7,8(sp)
ffffffffc0203fc8:	6161                	addi	sp,sp,80
ffffffffc0203fca:	8082                	ret
            cputchar(c);
ffffffffc0203fcc:	4521                	li	a0,8
ffffffffc0203fce:	924fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0203fd2:	34fd                	addiw	s1,s1,-1
ffffffffc0203fd4:	bfbd                	j	ffffffffc0203f52 <readline+0x3a>

ffffffffc0203fd6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203fd6:	00054783          	lbu	a5,0(a0)
ffffffffc0203fda:	cb91                	beqz	a5,ffffffffc0203fee <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203fdc:	4781                	li	a5,0
        cnt ++;
ffffffffc0203fde:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203fe0:	00f50733          	add	a4,a0,a5
ffffffffc0203fe4:	00074703          	lbu	a4,0(a4)
ffffffffc0203fe8:	fb7d                	bnez	a4,ffffffffc0203fde <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203fea:	853e                	mv	a0,a5
ffffffffc0203fec:	8082                	ret
    size_t cnt = 0;
ffffffffc0203fee:	4781                	li	a5,0
}
ffffffffc0203ff0:	853e                	mv	a0,a5
ffffffffc0203ff2:	8082                	ret

ffffffffc0203ff4 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ff4:	c185                	beqz	a1,ffffffffc0204014 <strnlen+0x20>
ffffffffc0203ff6:	00054783          	lbu	a5,0(a0)
ffffffffc0203ffa:	cf89                	beqz	a5,ffffffffc0204014 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203ffc:	4781                	li	a5,0
ffffffffc0203ffe:	a021                	j	ffffffffc0204006 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204000:	00074703          	lbu	a4,0(a4)
ffffffffc0204004:	c711                	beqz	a4,ffffffffc0204010 <strnlen+0x1c>
        cnt ++;
ffffffffc0204006:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204008:	00f50733          	add	a4,a0,a5
ffffffffc020400c:	fef59ae3          	bne	a1,a5,ffffffffc0204000 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204010:	853e                	mv	a0,a5
ffffffffc0204012:	8082                	ret
    size_t cnt = 0;
ffffffffc0204014:	4781                	li	a5,0
}
ffffffffc0204016:	853e                	mv	a0,a5
ffffffffc0204018:	8082                	ret

ffffffffc020401a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020401a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020401c:	0585                	addi	a1,a1,1
ffffffffc020401e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204022:	0785                	addi	a5,a5,1
ffffffffc0204024:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204028:	fb75                	bnez	a4,ffffffffc020401c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020402a:	8082                	ret

ffffffffc020402c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020402c:	00054783          	lbu	a5,0(a0)
ffffffffc0204030:	0005c703          	lbu	a4,0(a1)
ffffffffc0204034:	cb91                	beqz	a5,ffffffffc0204048 <strcmp+0x1c>
ffffffffc0204036:	00e79c63          	bne	a5,a4,ffffffffc020404e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020403a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020403c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204040:	0585                	addi	a1,a1,1
ffffffffc0204042:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204046:	fbe5                	bnez	a5,ffffffffc0204036 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204048:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020404a:	9d19                	subw	a0,a0,a4
ffffffffc020404c:	8082                	ret
ffffffffc020404e:	0007851b          	sext.w	a0,a5
ffffffffc0204052:	9d19                	subw	a0,a0,a4
ffffffffc0204054:	8082                	ret

ffffffffc0204056 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204056:	00054783          	lbu	a5,0(a0)
ffffffffc020405a:	cb91                	beqz	a5,ffffffffc020406e <strchr+0x18>
        if (*s == c) {
ffffffffc020405c:	00b79563          	bne	a5,a1,ffffffffc0204066 <strchr+0x10>
ffffffffc0204060:	a809                	j	ffffffffc0204072 <strchr+0x1c>
ffffffffc0204062:	00b78763          	beq	a5,a1,ffffffffc0204070 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204066:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204068:	00054783          	lbu	a5,0(a0)
ffffffffc020406c:	fbfd                	bnez	a5,ffffffffc0204062 <strchr+0xc>
    }
    return NULL;
ffffffffc020406e:	4501                	li	a0,0
}
ffffffffc0204070:	8082                	ret
ffffffffc0204072:	8082                	ret

ffffffffc0204074 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204074:	ca01                	beqz	a2,ffffffffc0204084 <memset+0x10>
ffffffffc0204076:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204078:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020407a:	0785                	addi	a5,a5,1
ffffffffc020407c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204080:	fec79de3          	bne	a5,a2,ffffffffc020407a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204084:	8082                	ret

ffffffffc0204086 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204086:	ca19                	beqz	a2,ffffffffc020409c <memcpy+0x16>
ffffffffc0204088:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020408a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020408c:	0585                	addi	a1,a1,1
ffffffffc020408e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204092:	0785                	addi	a5,a5,1
ffffffffc0204094:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204098:	fec59ae3          	bne	a1,a2,ffffffffc020408c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020409c:	8082                	ret

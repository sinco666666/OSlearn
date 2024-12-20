
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

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
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56a60613          	addi	a2,a2,1386 # ffffffffc02115a8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	24a040ef          	jal	ra,ffffffffc0204298 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	27658593          	addi	a1,a1,630 # ffffffffc02042c8 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	28e50513          	addi	a0,a0,654 # ffffffffc02042e8 <etext+0x26>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	09e000ef          	jal	ra,ffffffffc0200104 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2b3010ef          	jal	ra,ffffffffc0201b1c <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4fc000ef          	jal	ra,ffffffffc020056a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	548030ef          	jal	ra,ffffffffc02035ba <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	41e000ef          	jal	ra,ffffffffc0200494 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	794020ef          	jal	ra,ffffffffc020280e <swap_init>

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
ffffffffc02000b2:	50b030ef          	jal	ra,ffffffffc0203dbc <vprintfmt>
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
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
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
ffffffffc02000e6:	4d7030ef          	jal	ra,ffffffffc0203dbc <vprintfmt>
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
ffffffffc020010a:	21a50513          	addi	a0,a0,538 # ffffffffc0204320 <etext+0x5e>
void print_kerninfo(void) {
ffffffffc020010e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200110:	fafff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200114:	00000597          	auipc	a1,0x0
ffffffffc0200118:	f2258593          	addi	a1,a1,-222 # ffffffffc0200036 <kern_init>
ffffffffc020011c:	00004517          	auipc	a0,0x4
ffffffffc0200120:	22450513          	addi	a0,a0,548 # ffffffffc0204340 <etext+0x7e>
ffffffffc0200124:	f9bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200128:	00004597          	auipc	a1,0x4
ffffffffc020012c:	19a58593          	addi	a1,a1,410 # ffffffffc02042c2 <etext>
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	23050513          	addi	a0,a0,560 # ffffffffc0204360 <etext+0x9e>
ffffffffc0200138:	f87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013c:	0000a597          	auipc	a1,0xa
ffffffffc0200140:	f0458593          	addi	a1,a1,-252 # ffffffffc020a040 <edata>
ffffffffc0200144:	00004517          	auipc	a0,0x4
ffffffffc0200148:	23c50513          	addi	a0,a0,572 # ffffffffc0204380 <etext+0xbe>
ffffffffc020014c:	f73ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200150:	00011597          	auipc	a1,0x11
ffffffffc0200154:	45858593          	addi	a1,a1,1112 # ffffffffc02115a8 <end>
ffffffffc0200158:	00004517          	auipc	a0,0x4
ffffffffc020015c:	24850513          	addi	a0,a0,584 # ffffffffc02043a0 <etext+0xde>
ffffffffc0200160:	f5fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200164:	00012597          	auipc	a1,0x12
ffffffffc0200168:	84358593          	addi	a1,a1,-1981 # ffffffffc02119a7 <end+0x3ff>
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
ffffffffc020018a:	23a50513          	addi	a0,a0,570 # ffffffffc02043c0 <etext+0xfe>
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
ffffffffc0200198:	15c60613          	addi	a2,a2,348 # ffffffffc02042f0 <etext+0x2e>
ffffffffc020019c:	04e00593          	li	a1,78
ffffffffc02001a0:	00004517          	auipc	a0,0x4
ffffffffc02001a4:	16850513          	addi	a0,a0,360 # ffffffffc0204308 <etext+0x46>
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
ffffffffc02001b4:	31860613          	addi	a2,a2,792 # ffffffffc02044c8 <commands+0xd8>
ffffffffc02001b8:	00004597          	auipc	a1,0x4
ffffffffc02001bc:	33058593          	addi	a1,a1,816 # ffffffffc02044e8 <commands+0xf8>
ffffffffc02001c0:	00004517          	auipc	a0,0x4
ffffffffc02001c4:	33050513          	addi	a0,a0,816 # ffffffffc02044f0 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ca:	ef5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ce:	00004617          	auipc	a2,0x4
ffffffffc02001d2:	33260613          	addi	a2,a2,818 # ffffffffc0204500 <commands+0x110>
ffffffffc02001d6:	00004597          	auipc	a1,0x4
ffffffffc02001da:	35258593          	addi	a1,a1,850 # ffffffffc0204528 <commands+0x138>
ffffffffc02001de:	00004517          	auipc	a0,0x4
ffffffffc02001e2:	31250513          	addi	a0,a0,786 # ffffffffc02044f0 <commands+0x100>
ffffffffc02001e6:	ed9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ea:	00004617          	auipc	a2,0x4
ffffffffc02001ee:	34e60613          	addi	a2,a2,846 # ffffffffc0204538 <commands+0x148>
ffffffffc02001f2:	00004597          	auipc	a1,0x4
ffffffffc02001f6:	36658593          	addi	a1,a1,870 # ffffffffc0204558 <commands+0x168>
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	2f650513          	addi	a0,a0,758 # ffffffffc02044f0 <commands+0x100>
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
ffffffffc0200238:	20450513          	addi	a0,a0,516 # ffffffffc0204438 <commands+0x48>
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
ffffffffc020025a:	20a50513          	addi	a0,a0,522 # ffffffffc0204460 <commands+0x70>
ffffffffc020025e:	e61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200262:	000c0563          	beqz	s8,ffffffffc020026c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200266:	8562                	mv	a0,s8
ffffffffc0200268:	4ec000ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc020026c:	00004c97          	auipc	s9,0x4
ffffffffc0200270:	184c8c93          	addi	s9,s9,388 # ffffffffc02043f0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200274:	00005997          	auipc	s3,0x5
ffffffffc0200278:	71498993          	addi	s3,s3,1812 # ffffffffc0205988 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027c:	00004917          	auipc	s2,0x4
ffffffffc0200280:	20c90913          	addi	s2,s2,524 # ffffffffc0204488 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200284:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200286:	00004b17          	auipc	s6,0x4
ffffffffc020028a:	20ab0b13          	addi	s6,s6,522 # ffffffffc0204490 <commands+0xa0>
    if (argc == 0) {
ffffffffc020028e:	00004a97          	auipc	s5,0x4
ffffffffc0200292:	25aa8a93          	addi	s5,s5,602 # ffffffffc02044e8 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200296:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200298:	854e                	mv	a0,s3
ffffffffc020029a:	6a3030ef          	jal	ra,ffffffffc020413c <readline>
ffffffffc020029e:	842a                	mv	s0,a0
ffffffffc02002a0:	dd65                	beqz	a0,ffffffffc0200298 <kmonitor+0x6a>
ffffffffc02002a2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a8:	c999                	beqz	a1,ffffffffc02002be <kmonitor+0x90>
ffffffffc02002aa:	854a                	mv	a0,s2
ffffffffc02002ac:	7cf030ef          	jal	ra,ffffffffc020427a <strchr>
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
ffffffffc02002c6:	12ed0d13          	addi	s10,s10,302 # ffffffffc02043f0 <commands>
    if (argc == 0) {
ffffffffc02002ca:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
ffffffffc02002d0:	781030ef          	jal	ra,ffffffffc0204250 <strcmp>
ffffffffc02002d4:	c919                	beqz	a0,ffffffffc02002ea <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d6:	2405                	addiw	s0,s0,1
ffffffffc02002d8:	09740463          	beq	s0,s7,ffffffffc0200360 <kmonitor+0x132>
ffffffffc02002dc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e0:	6582                	ld	a1,0(sp)
ffffffffc02002e2:	0d61                	addi	s10,s10,24
ffffffffc02002e4:	76d030ef          	jal	ra,ffffffffc0204250 <strcmp>
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
ffffffffc020034a:	731030ef          	jal	ra,ffffffffc020427a <strchr>
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
ffffffffc0200366:	14e50513          	addi	a0,a0,334 # ffffffffc02044b0 <commands+0xc0>
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
ffffffffc0200370:	00011317          	auipc	t1,0x11
ffffffffc0200374:	0d030313          	addi	t1,t1,208 # ffffffffc0211440 <is_panic>
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
ffffffffc0200394:	00011717          	auipc	a4,0x11
ffffffffc0200398:	0af72623          	sw	a5,172(a4) # ffffffffc0211440 <is_panic>

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
ffffffffc02003a6:	1c650513          	addi	a0,a0,454 # ffffffffc0204568 <commands+0x178>
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
ffffffffc02003bc:	12850513          	addi	a0,a0,296 # ffffffffc02054e0 <default_pmm_manager+0x4e8>
ffffffffc02003c0:	cffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12e000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
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
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	06f73923          	sd	a5,114(a4) # ffffffffc0211448 <timebase>
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
ffffffffc02003fa:	19250513          	addi	a0,a0,402 # ffffffffc0204588 <commands+0x198>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	0807b123          	sd	zero,130(a5) # ffffffffc0211480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b965                	j	ffffffffc02000be <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	03c78793          	addi	a5,a5,60 # ffffffffc0211448 <timebase>
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
ffffffffc0200442:	0b0000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
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
ffffffffc0200456:	a859                	j	ffffffffc02004ec <intr_enable>

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
ffffffffc0200474:	07e000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200478:	4501                	li	a0,0
ffffffffc020047a:	4581                	li	a1,0
ffffffffc020047c:	4601                	li	a2,0
ffffffffc020047e:	4889                	li	a7,2
ffffffffc0200480:	00000073          	ecall
ffffffffc0200484:	2501                	sext.w	a0,a0
ffffffffc0200486:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200488:	064000ef          	jal	ra,ffffffffc02004ec <intr_enable>
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

ffffffffc02004a2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a2:	0000a797          	auipc	a5,0xa
ffffffffc02004a6:	b9e78793          	addi	a5,a5,-1122 # ffffffffc020a040 <edata>
ffffffffc02004aa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ae:	1141                	addi	sp,sp,-16
ffffffffc02004b0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b2:	95be                	add	a1,a1,a5
ffffffffc02004b4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	5f1030ef          	jal	ra,ffffffffc02042aa <memcpy>
    return 0;
}
ffffffffc02004be:	60a2                	ld	ra,8(sp)
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	0141                	addi	sp,sp,16
ffffffffc02004c4:	8082                	ret

ffffffffc02004c6 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004c6:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004cc:	0000a517          	auipc	a0,0xa
ffffffffc02004d0:	b7450513          	addi	a0,a0,-1164 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
ffffffffc02004da:	85ba                	mv	a1,a4
ffffffffc02004dc:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004de:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e0:	5cb030ef          	jal	ra,ffffffffc02042aa <memcpy>
    return 0;
}
ffffffffc02004e4:	60a2                	ld	ra,8(sp)
ffffffffc02004e6:	4501                	li	a0,0
ffffffffc02004e8:	0141                	addi	sp,sp,16
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ec:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004fc:	1141                	addi	sp,sp,-16
ffffffffc02004fe:	e022                	sd	s0,0(sp)
ffffffffc0200500:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200502:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	11053583          	ld	a1,272(a0)
ffffffffc020050c:	05500613          	li	a2,85
ffffffffc0200510:	c399                	beqz	a5,ffffffffc0200516 <pgfault_handler+0x1e>
ffffffffc0200512:	04b00613          	li	a2,75
ffffffffc0200516:	11843703          	ld	a4,280(s0)
ffffffffc020051a:	47bd                	li	a5,15
ffffffffc020051c:	05700693          	li	a3,87
ffffffffc0200520:	00f70463          	beq	a4,a5,ffffffffc0200528 <pgfault_handler+0x30>
ffffffffc0200524:	05200693          	li	a3,82
ffffffffc0200528:	00004517          	auipc	a0,0x4
ffffffffc020052c:	35850513          	addi	a0,a0,856 # ffffffffc0204880 <commands+0x490>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200534:	00011797          	auipc	a5,0x11
ffffffffc0200538:	06c78793          	addi	a5,a5,108 # ffffffffc02115a0 <check_mm_struct>
ffffffffc020053c:	6388                	ld	a0,0(a5)
ffffffffc020053e:	c911                	beqz	a0,ffffffffc0200552 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200540:	11043603          	ld	a2,272(s0)
ffffffffc0200544:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200548:	6402                	ld	s0,0(sp)
ffffffffc020054a:	60a2                	ld	ra,8(sp)
ffffffffc020054c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020054e:	5aa0306f          	j	ffffffffc0203af8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200552:	00004617          	auipc	a2,0x4
ffffffffc0200556:	34e60613          	addi	a2,a2,846 # ffffffffc02048a0 <commands+0x4b0>
ffffffffc020055a:	07900593          	li	a1,121
ffffffffc020055e:	00004517          	auipc	a0,0x4
ffffffffc0200562:	35a50513          	addi	a0,a0,858 # ffffffffc02048b8 <commands+0x4c8>
ffffffffc0200566:	e0bff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020056a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020056a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020056e:	00000797          	auipc	a5,0x0
ffffffffc0200572:	4b278793          	addi	a5,a5,1202 # ffffffffc0200a20 <__alltraps>
ffffffffc0200576:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc020057a:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020057e:	000407b7          	lui	a5,0x40
ffffffffc0200582:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200588:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020058a:	1141                	addi	sp,sp,-16
ffffffffc020058c:	e022                	sd	s0,0(sp)
ffffffffc020058e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	00004517          	auipc	a0,0x4
ffffffffc0200594:	34050513          	addi	a0,a0,832 # ffffffffc02048d0 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc0200598:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020059e:	640c                	ld	a1,8(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	34850513          	addi	a0,a0,840 # ffffffffc02048e8 <commands+0x4f8>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005ac:	680c                	ld	a1,16(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	35250513          	addi	a0,a0,850 # ffffffffc0204900 <commands+0x510>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005ba:	6c0c                	ld	a1,24(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	35c50513          	addi	a0,a0,860 # ffffffffc0204918 <commands+0x528>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c8:	700c                	ld	a1,32(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	36650513          	addi	a0,a0,870 # ffffffffc0204930 <commands+0x540>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d6:	740c                	ld	a1,40(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	37050513          	addi	a0,a0,880 # ffffffffc0204948 <commands+0x558>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005e4:	780c                	ld	a1,48(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	37a50513          	addi	a0,a0,890 # ffffffffc0204960 <commands+0x570>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005f2:	7c0c                	ld	a1,56(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	38450513          	addi	a0,a0,900 # ffffffffc0204978 <commands+0x588>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200600:	602c                	ld	a1,64(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	38e50513          	addi	a0,a0,910 # ffffffffc0204990 <commands+0x5a0>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020060e:	642c                	ld	a1,72(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	39850513          	addi	a0,a0,920 # ffffffffc02049a8 <commands+0x5b8>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020061c:	682c                	ld	a1,80(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	3a250513          	addi	a0,a0,930 # ffffffffc02049c0 <commands+0x5d0>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020062a:	6c2c                	ld	a1,88(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	3ac50513          	addi	a0,a0,940 # ffffffffc02049d8 <commands+0x5e8>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200638:	702c                	ld	a1,96(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	3b650513          	addi	a0,a0,950 # ffffffffc02049f0 <commands+0x600>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200646:	742c                	ld	a1,104(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	3c050513          	addi	a0,a0,960 # ffffffffc0204a08 <commands+0x618>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200654:	782c                	ld	a1,112(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	3ca50513          	addi	a0,a0,970 # ffffffffc0204a20 <commands+0x630>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200662:	7c2c                	ld	a1,120(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	3d450513          	addi	a0,a0,980 # ffffffffc0204a38 <commands+0x648>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200670:	604c                	ld	a1,128(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	3de50513          	addi	a0,a0,990 # ffffffffc0204a50 <commands+0x660>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020067e:	644c                	ld	a1,136(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	3e850513          	addi	a0,a0,1000 # ffffffffc0204a68 <commands+0x678>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020068c:	684c                	ld	a1,144(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	3f250513          	addi	a0,a0,1010 # ffffffffc0204a80 <commands+0x690>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020069a:	6c4c                	ld	a1,152(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204a98 <commands+0x6a8>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a8:	704c                	ld	a1,160(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	40650513          	addi	a0,a0,1030 # ffffffffc0204ab0 <commands+0x6c0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b6:	744c                	ld	a1,168(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	41050513          	addi	a0,a0,1040 # ffffffffc0204ac8 <commands+0x6d8>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006c4:	784c                	ld	a1,176(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	41a50513          	addi	a0,a0,1050 # ffffffffc0204ae0 <commands+0x6f0>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006d2:	7c4c                	ld	a1,184(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	42450513          	addi	a0,a0,1060 # ffffffffc0204af8 <commands+0x708>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e0:	606c                	ld	a1,192(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	42e50513          	addi	a0,a0,1070 # ffffffffc0204b10 <commands+0x720>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006ee:	646c                	ld	a1,200(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	43850513          	addi	a0,a0,1080 # ffffffffc0204b28 <commands+0x738>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006fc:	686c                	ld	a1,208(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	44250513          	addi	a0,a0,1090 # ffffffffc0204b40 <commands+0x750>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020070a:	6c6c                	ld	a1,216(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	44c50513          	addi	a0,a0,1100 # ffffffffc0204b58 <commands+0x768>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200718:	706c                	ld	a1,224(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	45650513          	addi	a0,a0,1110 # ffffffffc0204b70 <commands+0x780>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200726:	746c                	ld	a1,232(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	46050513          	addi	a0,a0,1120 # ffffffffc0204b88 <commands+0x798>
ffffffffc0200730:	98fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200734:	786c                	ld	a1,240(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204ba0 <commands+0x7b0>
ffffffffc020073e:	981ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200744:	6402                	ld	s0,0(sp)
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200748:	00004517          	auipc	a0,0x4
ffffffffc020074c:	47050513          	addi	a0,a0,1136 # ffffffffc0204bb8 <commands+0x7c8>
}
ffffffffc0200750:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200752:	b2b5                	j	ffffffffc02000be <cprintf>

ffffffffc0200754 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	1141                	addi	sp,sp,-16
ffffffffc0200756:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200758:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020075a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	47450513          	addi	a0,a0,1140 # ffffffffc0204bd0 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	959ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc020076a:	8522                	mv	a0,s0
ffffffffc020076c:	e1dff0ef          	jal	ra,ffffffffc0200588 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200770:	10043583          	ld	a1,256(s0)
ffffffffc0200774:	00004517          	auipc	a0,0x4
ffffffffc0200778:	47450513          	addi	a0,a0,1140 # ffffffffc0204be8 <commands+0x7f8>
ffffffffc020077c:	943ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200780:	10843583          	ld	a1,264(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	47c50513          	addi	a0,a0,1148 # ffffffffc0204c00 <commands+0x810>
ffffffffc020078c:	933ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200790:	11043583          	ld	a1,272(s0)
ffffffffc0200794:	00004517          	auipc	a0,0x4
ffffffffc0200798:	48450513          	addi	a0,a0,1156 # ffffffffc0204c18 <commands+0x828>
ffffffffc020079c:	923ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a0:	11843583          	ld	a1,280(s0)
}
ffffffffc02007a4:	6402                	ld	s0,0(sp)
ffffffffc02007a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a8:	00004517          	auipc	a0,0x4
ffffffffc02007ac:	48850513          	addi	a0,a0,1160 # ffffffffc0204c30 <commands+0x840>
}
ffffffffc02007b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	90dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007b6 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b6:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02007ba:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007bc:	0786                	slli	a5,a5,0x1
ffffffffc02007be:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02007c0:	08f76f63          	bltu	a4,a5,ffffffffc020085e <interrupt_handler+0xa8>
ffffffffc02007c4:	00004717          	auipc	a4,0x4
ffffffffc02007c8:	de070713          	addi	a4,a4,-544 # ffffffffc02045a4 <commands+0x1b4>
ffffffffc02007cc:	078a                	slli	a5,a5,0x2
ffffffffc02007ce:	97ba                	add	a5,a5,a4
ffffffffc02007d0:	439c                	lw	a5,0(a5)
ffffffffc02007d2:	97ba                	add	a5,a5,a4
ffffffffc02007d4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	05a50513          	addi	a0,a0,90 # ffffffffc0204830 <commands+0x440>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	02e50513          	addi	a0,a0,46 # ffffffffc0204810 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	fe250513          	addi	a0,a0,-30 # ffffffffc02047d0 <commands+0x3e0>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	ff650513          	addi	a0,a0,-10 # ffffffffc02047f0 <commands+0x400>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	05a50513          	addi	a0,a0,90 # ffffffffc0204860 <commands+0x470>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e022                	sd	s0,0(sp)
ffffffffc0200816:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200818:	bf1ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            ticks++;
ffffffffc020081c:	00011797          	auipc	a5,0x11
ffffffffc0200820:	c3c78793          	addi	a5,a5,-964 # ffffffffc0211458 <ticks.1583>
ffffffffc0200824:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
ffffffffc0200826:	06400713          	li	a4,100
ffffffffc020082a:	00011417          	auipc	s0,0x11
ffffffffc020082e:	c2640413          	addi	s0,s0,-986 # ffffffffc0211450 <num>
            ticks++;
ffffffffc0200832:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
ffffffffc0200834:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200838:	00011697          	auipc	a3,0x11
ffffffffc020083c:	c2f6a023          	sw	a5,-992(a3) # ffffffffc0211458 <ticks.1583>
            if (ticks % TICK_NUM == 0){
ffffffffc0200840:	c305                	beqz	a4,ffffffffc0200860 <interrupt_handler+0xaa>
            if (num == 10){
ffffffffc0200842:	6018                	ld	a4,0(s0)
ffffffffc0200844:	47a9                	li	a5,10
ffffffffc0200846:	00f71863          	bne	a4,a5,ffffffffc0200856 <interrupt_handler+0xa0>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020084a:	4501                	li	a0,0
ffffffffc020084c:	4581                	li	a1,0
ffffffffc020084e:	4601                	li	a2,0
ffffffffc0200850:	48a1                	li	a7,8
ffffffffc0200852:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200856:	60a2                	ld	ra,8(sp)
ffffffffc0200858:	6402                	ld	s0,0(sp)
ffffffffc020085a:	0141                	addi	sp,sp,16
ffffffffc020085c:	8082                	ret
            print_trapframe(tf);
ffffffffc020085e:	bddd                	j	ffffffffc0200754 <print_trapframe>
            num++;
ffffffffc0200860:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200862:	06400593          	li	a1,100
ffffffffc0200866:	00004517          	auipc	a0,0x4
ffffffffc020086a:	fea50513          	addi	a0,a0,-22 # ffffffffc0204850 <commands+0x460>
            num++;
ffffffffc020086e:	0785                	addi	a5,a5,1
ffffffffc0200870:	00011717          	auipc	a4,0x11
ffffffffc0200874:	bef73023          	sd	a5,-1056(a4) # ffffffffc0211450 <num>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200878:	847ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020087c:	b7d9                	j	ffffffffc0200842 <interrupt_handler+0x8c>

ffffffffc020087e <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020087e:	11853783          	ld	a5,280(a0)
ffffffffc0200882:	473d                	li	a4,15
ffffffffc0200884:	16f76463          	bltu	a4,a5,ffffffffc02009ec <exception_handler+0x16e>
ffffffffc0200888:	00004717          	auipc	a4,0x4
ffffffffc020088c:	d4c70713          	addi	a4,a4,-692 # ffffffffc02045d4 <commands+0x1e4>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e822                	sd	s0,16(sp)
ffffffffc020089a:	ec06                	sd	ra,24(sp)
ffffffffc020089c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	842a                	mv	s0,a0
ffffffffc02008a2:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	f1450513          	addi	a0,a0,-236 # ffffffffc02047b8 <commands+0x3c8>
ffffffffc02008ac:	813ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b0:	8522                	mv	a0,s0
ffffffffc02008b2:	c47ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02008b6:	84aa                	mv	s1,a0
ffffffffc02008b8:	12051b63          	bnez	a0,ffffffffc02009ee <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008bc:	60e2                	ld	ra,24(sp)
ffffffffc02008be:	6442                	ld	s0,16(sp)
ffffffffc02008c0:	64a2                	ld	s1,8(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
ffffffffc02008c4:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008c6:	00004517          	auipc	a0,0x4
ffffffffc02008ca:	d5250513          	addi	a0,a0,-686 # ffffffffc0204618 <commands+0x228>
}
ffffffffc02008ce:	6442                	ld	s0,16(sp)
ffffffffc02008d0:	60e2                	ld	ra,24(sp)
ffffffffc02008d2:	64a2                	ld	s1,8(sp)
ffffffffc02008d4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008d6:	fe8ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008da:	00004517          	auipc	a0,0x4
ffffffffc02008de:	d5e50513          	addi	a0,a0,-674 # ffffffffc0204638 <commands+0x248>
ffffffffc02008e2:	b7f5                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008e4:	00004517          	auipc	a0,0x4
ffffffffc02008e8:	d7450513          	addi	a0,a0,-652 # ffffffffc0204658 <commands+0x268>
ffffffffc02008ec:	b7cd                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008ee:	00004517          	auipc	a0,0x4
ffffffffc02008f2:	d8250513          	addi	a0,a0,-638 # ffffffffc0204670 <commands+0x280>
ffffffffc02008f6:	bfe1                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008f8:	00004517          	auipc	a0,0x4
ffffffffc02008fc:	d8850513          	addi	a0,a0,-632 # ffffffffc0204680 <commands+0x290>
ffffffffc0200900:	b7f9                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	d9e50513          	addi	a0,a0,-610 # ffffffffc02046a0 <commands+0x2b0>
ffffffffc020090a:	fb4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020090e:	8522                	mv	a0,s0
ffffffffc0200910:	be9ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200914:	84aa                	mv	s1,a0
ffffffffc0200916:	d15d                	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	e3bff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020091e:	86a6                	mv	a3,s1
ffffffffc0200920:	00004617          	auipc	a2,0x4
ffffffffc0200924:	d9860613          	addi	a2,a2,-616 # ffffffffc02046b8 <commands+0x2c8>
ffffffffc0200928:	0d200593          	li	a1,210
ffffffffc020092c:	00004517          	auipc	a0,0x4
ffffffffc0200930:	f8c50513          	addi	a0,a0,-116 # ffffffffc02048b8 <commands+0x4c8>
ffffffffc0200934:	a3dff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200938:	00004517          	auipc	a0,0x4
ffffffffc020093c:	da050513          	addi	a0,a0,-608 # ffffffffc02046d8 <commands+0x2e8>
ffffffffc0200940:	b779                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	dae50513          	addi	a0,a0,-594 # ffffffffc02046f0 <commands+0x300>
ffffffffc020094a:	f74ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094e:	8522                	mv	a0,s0
ffffffffc0200950:	ba9ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200954:	84aa                	mv	s1,a0
ffffffffc0200956:	d13d                	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200958:	8522                	mv	a0,s0
ffffffffc020095a:	dfbff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020095e:	86a6                	mv	a3,s1
ffffffffc0200960:	00004617          	auipc	a2,0x4
ffffffffc0200964:	d5860613          	addi	a2,a2,-680 # ffffffffc02046b8 <commands+0x2c8>
ffffffffc0200968:	0dc00593          	li	a1,220
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	f4c50513          	addi	a0,a0,-180 # ffffffffc02048b8 <commands+0x4c8>
ffffffffc0200974:	9fdff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200978:	00004517          	auipc	a0,0x4
ffffffffc020097c:	d9050513          	addi	a0,a0,-624 # ffffffffc0204708 <commands+0x318>
ffffffffc0200980:	b7b9                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	da650513          	addi	a0,a0,-602 # ffffffffc0204728 <commands+0x338>
ffffffffc020098a:	b791                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020098c:	00004517          	auipc	a0,0x4
ffffffffc0200990:	dbc50513          	addi	a0,a0,-580 # ffffffffc0204748 <commands+0x358>
ffffffffc0200994:	bf2d                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200996:	00004517          	auipc	a0,0x4
ffffffffc020099a:	dd250513          	addi	a0,a0,-558 # ffffffffc0204768 <commands+0x378>
ffffffffc020099e:	bf05                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	de850513          	addi	a0,a0,-536 # ffffffffc0204788 <commands+0x398>
ffffffffc02009a8:	b71d                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	df650513          	addi	a0,a0,-522 # ffffffffc02047a0 <commands+0x3b0>
ffffffffc02009b2:	f0cff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009b6:	8522                	mv	a0,s0
ffffffffc02009b8:	b41ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02009bc:	84aa                	mv	s1,a0
ffffffffc02009be:	ee050fe3          	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009c2:	8522                	mv	a0,s0
ffffffffc02009c4:	d91ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009c8:	86a6                	mv	a3,s1
ffffffffc02009ca:	00004617          	auipc	a2,0x4
ffffffffc02009ce:	cee60613          	addi	a2,a2,-786 # ffffffffc02046b8 <commands+0x2c8>
ffffffffc02009d2:	0f200593          	li	a1,242
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	ee250513          	addi	a0,a0,-286 # ffffffffc02048b8 <commands+0x4c8>
ffffffffc02009de:	993ff0ef          	jal	ra,ffffffffc0200370 <__panic>
}
ffffffffc02009e2:	6442                	ld	s0,16(sp)
ffffffffc02009e4:	60e2                	ld	ra,24(sp)
ffffffffc02009e6:	64a2                	ld	s1,8(sp)
ffffffffc02009e8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ea:	b3ad                	j	ffffffffc0200754 <print_trapframe>
ffffffffc02009ec:	b3a5                	j	ffffffffc0200754 <print_trapframe>
                print_trapframe(tf);
ffffffffc02009ee:	8522                	mv	a0,s0
ffffffffc02009f0:	d65ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009f4:	86a6                	mv	a3,s1
ffffffffc02009f6:	00004617          	auipc	a2,0x4
ffffffffc02009fa:	cc260613          	addi	a2,a2,-830 # ffffffffc02046b8 <commands+0x2c8>
ffffffffc02009fe:	0f900593          	li	a1,249
ffffffffc0200a02:	00004517          	auipc	a0,0x4
ffffffffc0200a06:	eb650513          	addi	a0,a0,-330 # ffffffffc02048b8 <commands+0x4c8>
ffffffffc0200a0a:	967ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0200a0e <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a0e:	11853783          	ld	a5,280(a0)
ffffffffc0200a12:	0007c363          	bltz	a5,ffffffffc0200a18 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a16:	b5a5                	j	ffffffffc020087e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a18:	bb79                	j	ffffffffc02007b6 <interrupt_handler>
ffffffffc0200a1a:	0000                	unimp
ffffffffc0200a1c:	0000                	unimp
	...

ffffffffc0200a20 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a20:	14011073          	csrw	sscratch,sp
ffffffffc0200a24:	712d                	addi	sp,sp,-288
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	ec0e                	sd	gp,24(sp)
ffffffffc0200a2a:	f012                	sd	tp,32(sp)
ffffffffc0200a2c:	f416                	sd	t0,40(sp)
ffffffffc0200a2e:	f81a                	sd	t1,48(sp)
ffffffffc0200a30:	fc1e                	sd	t2,56(sp)
ffffffffc0200a32:	e0a2                	sd	s0,64(sp)
ffffffffc0200a34:	e4a6                	sd	s1,72(sp)
ffffffffc0200a36:	e8aa                	sd	a0,80(sp)
ffffffffc0200a38:	ecae                	sd	a1,88(sp)
ffffffffc0200a3a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a3c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a3e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a40:	fcbe                	sd	a5,120(sp)
ffffffffc0200a42:	e142                	sd	a6,128(sp)
ffffffffc0200a44:	e546                	sd	a7,136(sp)
ffffffffc0200a46:	e94a                	sd	s2,144(sp)
ffffffffc0200a48:	ed4e                	sd	s3,152(sp)
ffffffffc0200a4a:	f152                	sd	s4,160(sp)
ffffffffc0200a4c:	f556                	sd	s5,168(sp)
ffffffffc0200a4e:	f95a                	sd	s6,176(sp)
ffffffffc0200a50:	fd5e                	sd	s7,184(sp)
ffffffffc0200a52:	e1e2                	sd	s8,192(sp)
ffffffffc0200a54:	e5e6                	sd	s9,200(sp)
ffffffffc0200a56:	e9ea                	sd	s10,208(sp)
ffffffffc0200a58:	edee                	sd	s11,216(sp)
ffffffffc0200a5a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a5c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a5e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a60:	fdfe                	sd	t6,248(sp)
ffffffffc0200a62:	14002473          	csrr	s0,sscratch
ffffffffc0200a66:	100024f3          	csrr	s1,sstatus
ffffffffc0200a6a:	14102973          	csrr	s2,sepc
ffffffffc0200a6e:	143029f3          	csrr	s3,stval
ffffffffc0200a72:	14202a73          	csrr	s4,scause
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	e226                	sd	s1,256(sp)
ffffffffc0200a7a:	e64a                	sd	s2,264(sp)
ffffffffc0200a7c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a7e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a80:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a82:	f8dff0ef          	jal	ra,ffffffffc0200a0e <trap>

ffffffffc0200a86 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a86:	6492                	ld	s1,256(sp)
ffffffffc0200a88:	6932                	ld	s2,264(sp)
ffffffffc0200a8a:	10049073          	csrw	sstatus,s1
ffffffffc0200a8e:	14191073          	csrw	sepc,s2
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	61e2                	ld	gp,24(sp)
ffffffffc0200a96:	7202                	ld	tp,32(sp)
ffffffffc0200a98:	72a2                	ld	t0,40(sp)
ffffffffc0200a9a:	7342                	ld	t1,48(sp)
ffffffffc0200a9c:	73e2                	ld	t2,56(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	64a6                	ld	s1,72(sp)
ffffffffc0200aa2:	6546                	ld	a0,80(sp)
ffffffffc0200aa4:	65e6                	ld	a1,88(sp)
ffffffffc0200aa6:	7606                	ld	a2,96(sp)
ffffffffc0200aa8:	76a6                	ld	a3,104(sp)
ffffffffc0200aaa:	7746                	ld	a4,112(sp)
ffffffffc0200aac:	77e6                	ld	a5,120(sp)
ffffffffc0200aae:	680a                	ld	a6,128(sp)
ffffffffc0200ab0:	68aa                	ld	a7,136(sp)
ffffffffc0200ab2:	694a                	ld	s2,144(sp)
ffffffffc0200ab4:	69ea                	ld	s3,152(sp)
ffffffffc0200ab6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ab8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aba:	7b4a                	ld	s6,176(sp)
ffffffffc0200abc:	7bea                	ld	s7,184(sp)
ffffffffc0200abe:	6c0e                	ld	s8,192(sp)
ffffffffc0200ac0:	6cae                	ld	s9,200(sp)
ffffffffc0200ac2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ac4:	6dee                	ld	s11,216(sp)
ffffffffc0200ac6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ac8:	7eae                	ld	t4,232(sp)
ffffffffc0200aca:	7f4e                	ld	t5,240(sp)
ffffffffc0200acc:	7fee                	ld	t6,248(sp)
ffffffffc0200ace:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ad0:	10200073          	sret
	...

ffffffffc0200ae0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00011797          	auipc	a5,0x11
ffffffffc0200ae4:	9a878793          	addi	a5,a5,-1624 # ffffffffc0211488 <free_area>
ffffffffc0200ae8:	e79c                	sd	a5,8(a5)
ffffffffc0200aea:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aec:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200af0:	8082                	ret

ffffffffc0200af2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200af2:	00011517          	auipc	a0,0x11
ffffffffc0200af6:	9a656503          	lwu	a0,-1626(a0) # ffffffffc0211498 <free_area+0x10>
ffffffffc0200afa:	8082                	ret

ffffffffc0200afc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200afc:	715d                	addi	sp,sp,-80
ffffffffc0200afe:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b00:	00011917          	auipc	s2,0x11
ffffffffc0200b04:	98890913          	addi	s2,s2,-1656 # ffffffffc0211488 <free_area>
ffffffffc0200b08:	00893783          	ld	a5,8(s2)
ffffffffc0200b0c:	e486                	sd	ra,72(sp)
ffffffffc0200b0e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b10:	fc26                	sd	s1,56(sp)
ffffffffc0200b12:	f44e                	sd	s3,40(sp)
ffffffffc0200b14:	f052                	sd	s4,32(sp)
ffffffffc0200b16:	ec56                	sd	s5,24(sp)
ffffffffc0200b18:	e85a                	sd	s6,16(sp)
ffffffffc0200b1a:	e45e                	sd	s7,8(sp)
ffffffffc0200b1c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1e:	31278f63          	beq	a5,s2,ffffffffc0200e3c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b22:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b26:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b28:	8b05                	andi	a4,a4,1
ffffffffc0200b2a:	30070d63          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b2e:	4401                	li	s0,0
ffffffffc0200b30:	4481                	li	s1,0
ffffffffc0200b32:	a031                	j	ffffffffc0200b3e <default_check+0x42>
ffffffffc0200b34:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b38:	8b09                	andi	a4,a4,2
ffffffffc0200b3a:	30070563          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b42:	679c                	ld	a5,8(a5)
ffffffffc0200b44:	2485                	addiw	s1,s1,1
ffffffffc0200b46:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b48:	ff2796e3          	bne	a5,s2,ffffffffc0200b34 <default_check+0x38>
ffffffffc0200b4c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b4e:	3ef000ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0200b52:	75351963          	bne	a0,s3,ffffffffc02012a4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b56:	4505                	li	a0,1
ffffffffc0200b58:	317000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b5c:	8a2a                	mv	s4,a0
ffffffffc0200b5e:	48050363          	beqz	a0,ffffffffc0200fe4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b62:	4505                	li	a0,1
ffffffffc0200b64:	30b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b68:	89aa                	mv	s3,a0
ffffffffc0200b6a:	74050d63          	beqz	a0,ffffffffc02012c4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b6e:	4505                	li	a0,1
ffffffffc0200b70:	2ff000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b74:	8aaa                	mv	s5,a0
ffffffffc0200b76:	4e050763          	beqz	a0,ffffffffc0201064 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b7a:	2f3a0563          	beq	s4,s3,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b7e:	2eaa0363          	beq	s4,a0,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b82:	2ea98163          	beq	s3,a0,ffffffffc0200e64 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b86:	000a2783          	lw	a5,0(s4)
ffffffffc0200b8a:	2e079d63          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b8e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b92:	2e079963          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b96:	411c                	lw	a5,0(a0)
ffffffffc0200b98:	2e079663          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9c:	00011797          	auipc	a5,0x11
ffffffffc0200ba0:	91c78793          	addi	a5,a5,-1764 # ffffffffc02114b8 <pages>
ffffffffc0200ba4:	639c                	ld	a5,0(a5)
ffffffffc0200ba6:	00004717          	auipc	a4,0x4
ffffffffc0200baa:	0a270713          	addi	a4,a4,162 # ffffffffc0204c48 <commands+0x858>
ffffffffc0200bae:	630c                	ld	a1,0(a4)
ffffffffc0200bb0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bb4:	870d                	srai	a4,a4,0x3
ffffffffc0200bb6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bba:	00005697          	auipc	a3,0x5
ffffffffc0200bbe:	4fe68693          	addi	a3,a3,1278 # ffffffffc02060b8 <nbase>
ffffffffc0200bc2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bc4:	00011697          	auipc	a3,0x11
ffffffffc0200bc8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0211468 <npage>
ffffffffc0200bcc:	6294                	ld	a3,0(a3)
ffffffffc0200bce:	06b2                	slli	a3,a3,0xc
ffffffffc0200bd0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bd2:	0732                	slli	a4,a4,0xc
ffffffffc0200bd4:	2cd77863          	bgeu	a4,a3,ffffffffc0200ea4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bdc:	870d                	srai	a4,a4,0x3
ffffffffc0200bde:	02b70733          	mul	a4,a4,a1
ffffffffc0200be2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200be4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200be6:	4ed77f63          	bgeu	a4,a3,ffffffffc02010e4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bea:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bee:	878d                	srai	a5,a5,0x3
ffffffffc0200bf0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bf4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bf8:	34d7f663          	bgeu	a5,a3,ffffffffc0200f44 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bfe:	00093c03          	ld	s8,0(s2)
ffffffffc0200c02:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c06:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c0a:	00011797          	auipc	a5,0x11
ffffffffc0200c0e:	8927b323          	sd	s2,-1914(a5) # ffffffffc0211490 <free_area+0x8>
ffffffffc0200c12:	00011797          	auipc	a5,0x11
ffffffffc0200c16:	8727bb23          	sd	s2,-1930(a5) # ffffffffc0211488 <free_area>
    nr_free = 0;
ffffffffc0200c1a:	00011797          	auipc	a5,0x11
ffffffffc0200c1e:	8607af23          	sw	zero,-1922(a5) # ffffffffc0211498 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c22:	24d000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c26:	2e051f63          	bnez	a0,ffffffffc0200f24 <default_check+0x428>
    free_page(p0);
ffffffffc0200c2a:	4585                	li	a1,1
ffffffffc0200c2c:	8552                	mv	a0,s4
ffffffffc0200c2e:	2c9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200c32:	4585                	li	a1,1
ffffffffc0200c34:	854e                	mv	a0,s3
ffffffffc0200c36:	2c1000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200c3a:	4585                	li	a1,1
ffffffffc0200c3c:	8556                	mv	a0,s5
ffffffffc0200c3e:	2b9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c42:	01092703          	lw	a4,16(s2)
ffffffffc0200c46:	478d                	li	a5,3
ffffffffc0200c48:	2af71e63          	bne	a4,a5,ffffffffc0200f04 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	221000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c52:	89aa                	mv	s3,a0
ffffffffc0200c54:	28050863          	beqz	a0,ffffffffc0200ee4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c58:	4505                	li	a0,1
ffffffffc0200c5a:	215000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c5e:	8aaa                	mv	s5,a0
ffffffffc0200c60:	3e050263          	beqz	a0,ffffffffc0201044 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	209000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c6a:	8a2a                	mv	s4,a0
ffffffffc0200c6c:	3a050c63          	beqz	a0,ffffffffc0201024 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c70:	4505                	li	a0,1
ffffffffc0200c72:	1fd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c76:	38051763          	bnez	a0,ffffffffc0201004 <default_check+0x508>
    free_page(p0);
ffffffffc0200c7a:	4585                	li	a1,1
ffffffffc0200c7c:	854e                	mv	a0,s3
ffffffffc0200c7e:	279000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c82:	00893783          	ld	a5,8(s2)
ffffffffc0200c86:	23278f63          	beq	a5,s2,ffffffffc0200ec4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c8a:	4505                	li	a0,1
ffffffffc0200c8c:	1e3000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c90:	32a99a63          	bne	s3,a0,ffffffffc0200fc4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c94:	4505                	li	a0,1
ffffffffc0200c96:	1d9000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c9a:	30051563          	bnez	a0,ffffffffc0200fa4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c9e:	01092783          	lw	a5,16(s2)
ffffffffc0200ca2:	2e079163          	bnez	a5,ffffffffc0200f84 <default_check+0x488>
    free_page(p);
ffffffffc0200ca6:	854e                	mv	a0,s3
ffffffffc0200ca8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200caa:	00010797          	auipc	a5,0x10
ffffffffc0200cae:	7d87bf23          	sd	s8,2014(a5) # ffffffffc0211488 <free_area>
ffffffffc0200cb2:	00010797          	auipc	a5,0x10
ffffffffc0200cb6:	7d77bf23          	sd	s7,2014(a5) # ffffffffc0211490 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cba:	00010797          	auipc	a5,0x10
ffffffffc0200cbe:	7d67af23          	sw	s6,2014(a5) # ffffffffc0211498 <free_area+0x10>
    free_page(p);
ffffffffc0200cc2:	235000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200cc6:	4585                	li	a1,1
ffffffffc0200cc8:	8556                	mv	a0,s5
ffffffffc0200cca:	22d000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200cce:	4585                	li	a1,1
ffffffffc0200cd0:	8552                	mv	a0,s4
ffffffffc0200cd2:	225000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cd6:	4515                	li	a0,5
ffffffffc0200cd8:	197000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200cdc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cde:	28050363          	beqz	a0,ffffffffc0200f64 <default_check+0x468>
ffffffffc0200ce2:	651c                	ld	a5,8(a0)
ffffffffc0200ce4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ce6:	8b85                	andi	a5,a5,1
ffffffffc0200ce8:	54079e63          	bnez	a5,ffffffffc0201244 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cec:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cee:	00093b03          	ld	s6,0(s2)
ffffffffc0200cf2:	00893a83          	ld	s5,8(s2)
ffffffffc0200cf6:	00010797          	auipc	a5,0x10
ffffffffc0200cfa:	7927b923          	sd	s2,1938(a5) # ffffffffc0211488 <free_area>
ffffffffc0200cfe:	00010797          	auipc	a5,0x10
ffffffffc0200d02:	7927b923          	sd	s2,1938(a5) # ffffffffc0211490 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d06:	169000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d0a:	50051d63          	bnez	a0,ffffffffc0201224 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d0e:	09098a13          	addi	s4,s3,144
ffffffffc0200d12:	8552                	mv	a0,s4
ffffffffc0200d14:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d16:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d1a:	00010797          	auipc	a5,0x10
ffffffffc0200d1e:	7607af23          	sw	zero,1918(a5) # ffffffffc0211498 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d22:	1d5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d26:	4511                	li	a0,4
ffffffffc0200d28:	147000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d2c:	4c051c63          	bnez	a0,ffffffffc0201204 <default_check+0x708>
ffffffffc0200d30:	0989b783          	ld	a5,152(s3)
ffffffffc0200d34:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d36:	8b85                	andi	a5,a5,1
ffffffffc0200d38:	4a078663          	beqz	a5,ffffffffc02011e4 <default_check+0x6e8>
ffffffffc0200d3c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d40:	478d                	li	a5,3
ffffffffc0200d42:	4af71163          	bne	a4,a5,ffffffffc02011e4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d46:	450d                	li	a0,3
ffffffffc0200d48:	127000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d4c:	8c2a                	mv	s8,a0
ffffffffc0200d4e:	46050b63          	beqz	a0,ffffffffc02011c4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d52:	4505                	li	a0,1
ffffffffc0200d54:	11b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d58:	44051663          	bnez	a0,ffffffffc02011a4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d5c:	438a1463          	bne	s4,s8,ffffffffc0201184 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d60:	4585                	li	a1,1
ffffffffc0200d62:	854e                	mv	a0,s3
ffffffffc0200d64:	193000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d68:	458d                	li	a1,3
ffffffffc0200d6a:	8552                	mv	a0,s4
ffffffffc0200d6c:	18b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0200d70:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d74:	04898c13          	addi	s8,s3,72
ffffffffc0200d78:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d7a:	8b85                	andi	a5,a5,1
ffffffffc0200d7c:	3e078463          	beqz	a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d80:	0189a703          	lw	a4,24(s3)
ffffffffc0200d84:	4785                	li	a5,1
ffffffffc0200d86:	3cf71f63          	bne	a4,a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d8a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d8e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d90:	8b85                	andi	a5,a5,1
ffffffffc0200d92:	3a078963          	beqz	a5,ffffffffc0201144 <default_check+0x648>
ffffffffc0200d96:	018a2703          	lw	a4,24(s4)
ffffffffc0200d9a:	478d                	li	a5,3
ffffffffc0200d9c:	3af71463          	bne	a4,a5,ffffffffc0201144 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200da0:	4505                	li	a0,1
ffffffffc0200da2:	0cd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200da6:	36a99f63          	bne	s3,a0,ffffffffc0201124 <default_check+0x628>
    free_page(p0);
ffffffffc0200daa:	4585                	li	a1,1
ffffffffc0200dac:	14b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200db0:	4509                	li	a0,2
ffffffffc0200db2:	0bd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200db6:	34aa1763          	bne	s4,a0,ffffffffc0201104 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dba:	4589                	li	a1,2
ffffffffc0200dbc:	13b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	8562                	mv	a0,s8
ffffffffc0200dc4:	133000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dc8:	4515                	li	a0,5
ffffffffc0200dca:	0a5000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dce:	89aa                	mv	s3,a0
ffffffffc0200dd0:	48050a63          	beqz	a0,ffffffffc0201264 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	4505                	li	a0,1
ffffffffc0200dd6:	099000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dda:	2e051563          	bnez	a0,ffffffffc02010c4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dde:	01092783          	lw	a5,16(s2)
ffffffffc0200de2:	2c079163          	bnez	a5,ffffffffc02010a4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200de6:	4595                	li	a1,5
ffffffffc0200de8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dea:	00010797          	auipc	a5,0x10
ffffffffc0200dee:	6b77a723          	sw	s7,1710(a5) # ffffffffc0211498 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200df2:	00010797          	auipc	a5,0x10
ffffffffc0200df6:	6967bb23          	sd	s6,1686(a5) # ffffffffc0211488 <free_area>
ffffffffc0200dfa:	00010797          	auipc	a5,0x10
ffffffffc0200dfe:	6957bb23          	sd	s5,1686(a5) # ffffffffc0211490 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e02:	0f5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return listelm->next;
ffffffffc0200e06:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0a:	01278963          	beq	a5,s2,ffffffffc0200e1c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e12:	679c                	ld	a5,8(a5)
ffffffffc0200e14:	34fd                	addiw	s1,s1,-1
ffffffffc0200e16:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e18:	ff279be3          	bne	a5,s2,ffffffffc0200e0e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e1c:	26049463          	bnez	s1,ffffffffc0201084 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e20:	46041263          	bnez	s0,ffffffffc0201284 <default_check+0x788>
}
ffffffffc0200e24:	60a6                	ld	ra,72(sp)
ffffffffc0200e26:	6406                	ld	s0,64(sp)
ffffffffc0200e28:	74e2                	ld	s1,56(sp)
ffffffffc0200e2a:	7942                	ld	s2,48(sp)
ffffffffc0200e2c:	79a2                	ld	s3,40(sp)
ffffffffc0200e2e:	7a02                	ld	s4,32(sp)
ffffffffc0200e30:	6ae2                	ld	s5,24(sp)
ffffffffc0200e32:	6b42                	ld	s6,16(sp)
ffffffffc0200e34:	6ba2                	ld	s7,8(sp)
ffffffffc0200e36:	6c02                	ld	s8,0(sp)
ffffffffc0200e38:	6161                	addi	sp,sp,80
ffffffffc0200e3a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e3e:	4401                	li	s0,0
ffffffffc0200e40:	4481                	li	s1,0
ffffffffc0200e42:	b331                	j	ffffffffc0200b4e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	e0c68693          	addi	a3,a3,-500 # ffffffffc0204c50 <commands+0x860>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	e1460613          	addi	a2,a2,-492 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200e54:	0f000593          	li	a1,240
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200e60:	d10ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	eac68693          	addi	a3,a3,-340 # ffffffffc0204d10 <commands+0x920>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	df460613          	addi	a2,a2,-524 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200e74:	0bd00593          	li	a1,189
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200e80:	cf0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	eb468693          	addi	a3,a3,-332 # ffffffffc0204d38 <commands+0x948>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	dd460613          	addi	a2,a2,-556 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200e94:	0be00593          	li	a1,190
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	de050513          	addi	a0,a0,-544 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200ea0:	cd0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	ed468693          	addi	a3,a3,-300 # ffffffffc0204d78 <commands+0x988>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	db460613          	addi	a2,a2,-588 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200eb4:	0c000593          	li	a1,192
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	dc050513          	addi	a0,a0,-576 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200ec0:	cb0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	f3c68693          	addi	a3,a3,-196 # ffffffffc0204e00 <commands+0xa10>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	d9460613          	addi	a2,a2,-620 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200ed4:	0d900593          	li	a1,217
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	da050513          	addi	a0,a0,-608 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200ee0:	c90ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	dcc68693          	addi	a3,a3,-564 # ffffffffc0204cb0 <commands+0x8c0>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200ef4:	0d200593          	li	a1,210
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200f00:	c70ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 3);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	eec68693          	addi	a3,a3,-276 # ffffffffc0204df0 <commands+0xa00>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	d5460613          	addi	a2,a2,-684 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200f14:	0d000593          	li	a1,208
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	d6050513          	addi	a0,a0,-672 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200f20:	c50ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	eb468693          	addi	a3,a3,-332 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	d3460613          	addi	a2,a2,-716 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200f34:	0cb00593          	li	a1,203
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200f40:	c30ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	e7468693          	addi	a3,a3,-396 # ffffffffc0204db8 <commands+0x9c8>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	d1460613          	addi	a2,a2,-748 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200f54:	0c200593          	li	a1,194
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200f60:	c10ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != NULL);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	ee468693          	addi	a3,a3,-284 # ffffffffc0204e48 <commands+0xa58>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	cf460613          	addi	a2,a2,-780 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200f74:	0f800593          	li	a1,248
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200f80:	bf0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	eb468693          	addi	a3,a3,-332 # ffffffffc0204e38 <commands+0xa48>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	cd460613          	addi	a2,a2,-812 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200f94:	0df00593          	li	a1,223
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200fa0:	bd0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	e3468693          	addi	a3,a3,-460 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	cb460613          	addi	a2,a2,-844 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200fb4:	0dd00593          	li	a1,221
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	cc050513          	addi	a0,a0,-832 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200fc0:	bb0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	e5468693          	addi	a3,a3,-428 # ffffffffc0204e18 <commands+0xa28>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	c9460613          	addi	a2,a2,-876 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200fd4:	0dc00593          	li	a1,220
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	ca050513          	addi	a0,a0,-864 # ffffffffc0204c78 <commands+0x888>
ffffffffc0200fe0:	b90ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	ccc68693          	addi	a3,a3,-820 # ffffffffc0204cb0 <commands+0x8c0>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204c60 <commands+0x870>
ffffffffc0200ff4:	0b900593          	li	a1,185
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201000:	b70ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	dd468693          	addi	a3,a3,-556 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	c5460613          	addi	a2,a2,-940 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201014:	0d600593          	li	a1,214
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	c6050513          	addi	a0,a0,-928 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201020:	b50ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	ccc68693          	addi	a3,a3,-820 # ffffffffc0204cf0 <commands+0x900>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	c3460613          	addi	a2,a2,-972 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201034:	0d400593          	li	a1,212
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201040:	b30ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	c8c68693          	addi	a3,a3,-884 # ffffffffc0204cd0 <commands+0x8e0>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201054:	0d300593          	li	a1,211
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201060:	b10ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	c8c68693          	addi	a3,a3,-884 # ffffffffc0204cf0 <commands+0x900>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201074:	0bb00593          	li	a1,187
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201080:	af0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(count == 0);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	f1468693          	addi	a3,a3,-236 # ffffffffc0204f98 <commands+0xba8>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201094:	12500593          	li	a1,293
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204c78 <commands+0x888>
ffffffffc02010a0:	ad0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	d9468693          	addi	a3,a3,-620 # ffffffffc0204e38 <commands+0xa48>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204c60 <commands+0x870>
ffffffffc02010b4:	11a00593          	li	a1,282
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204c78 <commands+0x888>
ffffffffc02010c0:	ab0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	d1468693          	addi	a3,a3,-748 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204c60 <commands+0x870>
ffffffffc02010d4:	11800593          	li	a1,280
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204c78 <commands+0x888>
ffffffffc02010e0:	a90ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	cb468693          	addi	a3,a3,-844 # ffffffffc0204d98 <commands+0x9a8>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204c60 <commands+0x870>
ffffffffc02010f4:	0c100593          	li	a1,193
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201100:	a70ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	e5468693          	addi	a3,a3,-428 # ffffffffc0204f58 <commands+0xb68>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201114:	11200593          	li	a1,274
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201120:	a50ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	e1468693          	addi	a3,a3,-492 # ffffffffc0204f38 <commands+0xb48>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201134:	11000593          	li	a1,272
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201140:	a30ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	dcc68693          	addi	a3,a3,-564 # ffffffffc0204f10 <commands+0xb20>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201154:	10e00593          	li	a1,270
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201160:	a10ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	d8468693          	addi	a3,a3,-636 # ffffffffc0204ee8 <commands+0xaf8>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	af460613          	addi	a2,a2,-1292 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201174:	10d00593          	li	a1,269
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201180:	9f0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	d5468693          	addi	a3,a3,-684 # ffffffffc0204ed8 <commands+0xae8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201194:	10800593          	li	a1,264
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204c78 <commands+0x888>
ffffffffc02011a0:	9d0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	c3468693          	addi	a3,a3,-972 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204c60 <commands+0x870>
ffffffffc02011b4:	10700593          	li	a1,263
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204c78 <commands+0x888>
ffffffffc02011c0:	9b0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	cf468693          	addi	a3,a3,-780 # ffffffffc0204eb8 <commands+0xac8>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204c60 <commands+0x870>
ffffffffc02011d4:	10600593          	li	a1,262
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204c78 <commands+0x888>
ffffffffc02011e0:	990ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	ca468693          	addi	a3,a3,-860 # ffffffffc0204e88 <commands+0xa98>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204c60 <commands+0x870>
ffffffffc02011f4:	10500593          	li	a1,261
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201200:	970ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	c6c68693          	addi	a3,a3,-916 # ffffffffc0204e70 <commands+0xa80>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201214:	10400593          	li	a1,260
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201220:	950ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	bb468693          	addi	a3,a3,-1100 # ffffffffc0204dd8 <commands+0x9e8>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201234:	0fe00593          	li	a1,254
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201240:	930ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	c1468693          	addi	a3,a3,-1004 # ffffffffc0204e58 <commands+0xa68>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201254:	0f900593          	li	a1,249
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201260:	910ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	d1468693          	addi	a3,a3,-748 # ffffffffc0204f78 <commands+0xb88>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201274:	11700593          	li	a1,279
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201280:	8f0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == 0);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	d2468693          	addi	a3,a3,-732 # ffffffffc0204fa8 <commands+0xbb8>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201294:	12600593          	li	a1,294
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204c78 <commands+0x888>
ffffffffc02012a0:	8d0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0204c90 <commands+0x8a0>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204c60 <commands+0x870>
ffffffffc02012b4:	0f300593          	li	a1,243
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0204c78 <commands+0x888>
ffffffffc02012c0:	8b0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0204cd0 <commands+0x8e0>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	99460613          	addi	a2,a2,-1644 # ffffffffc0204c60 <commands+0x870>
ffffffffc02012d4:	0ba00593          	li	a1,186
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	9a050513          	addi	a0,a0,-1632 # ffffffffc0204c78 <commands+0x888>
ffffffffc02012e0:	890ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02012e4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012e4:	1141                	addi	sp,sp,-16
ffffffffc02012e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012e8:	18058063          	beqz	a1,ffffffffc0201468 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012ec:	00359693          	slli	a3,a1,0x3
ffffffffc02012f0:	96ae                	add	a3,a3,a1
ffffffffc02012f2:	068e                	slli	a3,a3,0x3
ffffffffc02012f4:	96aa                	add	a3,a3,a0
ffffffffc02012f6:	02d50d63          	beq	a0,a3,ffffffffc0201330 <default_free_pages+0x4c>
ffffffffc02012fa:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012fc:	8b85                	andi	a5,a5,1
ffffffffc02012fe:	14079563          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201302:	651c                	ld	a5,8(a0)
ffffffffc0201304:	8385                	srli	a5,a5,0x1
ffffffffc0201306:	8b85                	andi	a5,a5,1
ffffffffc0201308:	14079063          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc020130c:	87aa                	mv	a5,a0
ffffffffc020130e:	a809                	j	ffffffffc0201320 <default_free_pages+0x3c>
ffffffffc0201310:	6798                	ld	a4,8(a5)
ffffffffc0201312:	8b05                	andi	a4,a4,1
ffffffffc0201314:	12071a63          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201318:	6798                	ld	a4,8(a5)
ffffffffc020131a:	8b09                	andi	a4,a4,2
ffffffffc020131c:	12071663          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201320:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201324:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201328:	04878793          	addi	a5,a5,72
ffffffffc020132c:	fed792e3          	bne	a5,a3,ffffffffc0201310 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201330:	2581                	sext.w	a1,a1
ffffffffc0201332:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201334:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201338:	4789                	li	a5,2
ffffffffc020133a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020133e:	00010697          	auipc	a3,0x10
ffffffffc0201342:	14a68693          	addi	a3,a3,330 # ffffffffc0211488 <free_area>
ffffffffc0201346:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201348:	669c                	ld	a5,8(a3)
ffffffffc020134a:	9db9                	addw	a1,a1,a4
ffffffffc020134c:	00010717          	auipc	a4,0x10
ffffffffc0201350:	14b72623          	sw	a1,332(a4) # ffffffffc0211498 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201354:	08d78f63          	beq	a5,a3,ffffffffc02013f2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201358:	fe078713          	addi	a4,a5,-32
ffffffffc020135c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020135e:	4801                	li	a6,0
ffffffffc0201360:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201364:	00e56a63          	bltu	a0,a4,ffffffffc0201378 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201368:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020136a:	02d70563          	beq	a4,a3,ffffffffc0201394 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201370:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201374:	fee57ae3          	bgeu	a0,a4,ffffffffc0201368 <default_free_pages+0x84>
ffffffffc0201378:	00080663          	beqz	a6,ffffffffc0201384 <default_free_pages+0xa0>
ffffffffc020137c:	00010817          	auipc	a6,0x10
ffffffffc0201380:	10b83623          	sd	a1,268(a6) # ffffffffc0211488 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201384:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201386:	e390                	sd	a2,0(a5)
ffffffffc0201388:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020138a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020138c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020138e:	02d59163          	bne	a1,a3,ffffffffc02013b0 <default_free_pages+0xcc>
ffffffffc0201392:	a091                	j	ffffffffc02013d6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201394:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201396:	f514                	sd	a3,40(a0)
ffffffffc0201398:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020139a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020139c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139e:	00d70563          	beq	a4,a3,ffffffffc02013a8 <default_free_pages+0xc4>
ffffffffc02013a2:	4805                	li	a6,1
ffffffffc02013a4:	87ba                	mv	a5,a4
ffffffffc02013a6:	b7e9                	j	ffffffffc0201370 <default_free_pages+0x8c>
ffffffffc02013a8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013aa:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013ac:	02d78163          	beq	a5,a3,ffffffffc02013ce <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013b0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013b4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013b8:	02081713          	slli	a4,a6,0x20
ffffffffc02013bc:	9301                	srli	a4,a4,0x20
ffffffffc02013be:	00371793          	slli	a5,a4,0x3
ffffffffc02013c2:	97ba                	add	a5,a5,a4
ffffffffc02013c4:	078e                	slli	a5,a5,0x3
ffffffffc02013c6:	97b2                	add	a5,a5,a2
ffffffffc02013c8:	02f50e63          	beq	a0,a5,ffffffffc0201404 <default_free_pages+0x120>
ffffffffc02013cc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013ce:	fe078713          	addi	a4,a5,-32
ffffffffc02013d2:	00d78d63          	beq	a5,a3,ffffffffc02013ec <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013d6:	4d0c                	lw	a1,24(a0)
ffffffffc02013d8:	02059613          	slli	a2,a1,0x20
ffffffffc02013dc:	9201                	srli	a2,a2,0x20
ffffffffc02013de:	00361693          	slli	a3,a2,0x3
ffffffffc02013e2:	96b2                	add	a3,a3,a2
ffffffffc02013e4:	068e                	slli	a3,a3,0x3
ffffffffc02013e6:	96aa                	add	a3,a3,a0
ffffffffc02013e8:	04d70063          	beq	a4,a3,ffffffffc0201428 <default_free_pages+0x144>
}
ffffffffc02013ec:	60a2                	ld	ra,8(sp)
ffffffffc02013ee:	0141                	addi	sp,sp,16
ffffffffc02013f0:	8082                	ret
ffffffffc02013f2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013f4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013f8:	e398                	sd	a4,0(a5)
ffffffffc02013fa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013fc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013fe:	f11c                	sd	a5,32(a0)
}
ffffffffc0201400:	0141                	addi	sp,sp,16
ffffffffc0201402:	8082                	ret
            p->property += base->property;
ffffffffc0201404:	4d1c                	lw	a5,24(a0)
ffffffffc0201406:	0107883b          	addw	a6,a5,a6
ffffffffc020140a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020140e:	57f5                	li	a5,-3
ffffffffc0201410:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	02053803          	ld	a6,32(a0)
ffffffffc0201418:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020141a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020141c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201420:	659c                	ld	a5,8(a1)
ffffffffc0201422:	01073023          	sd	a6,0(a4)
ffffffffc0201426:	b765                	j	ffffffffc02013ce <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020142c:	fe878693          	addi	a3,a5,-24
ffffffffc0201430:	9db9                	addw	a1,a1,a4
ffffffffc0201432:	cd0c                	sw	a1,24(a0)
ffffffffc0201434:	5775                	li	a4,-3
ffffffffc0201436:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020143a:	6398                	ld	a4,0(a5)
ffffffffc020143c:	679c                	ld	a5,8(a5)
}
ffffffffc020143e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201440:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201442:	e398                	sd	a4,0(a5)
ffffffffc0201444:	0141                	addi	sp,sp,16
ffffffffc0201446:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201448:	00004697          	auipc	a3,0x4
ffffffffc020144c:	b7068693          	addi	a3,a3,-1168 # ffffffffc0204fb8 <commands+0xbc8>
ffffffffc0201450:	00004617          	auipc	a2,0x4
ffffffffc0201454:	81060613          	addi	a2,a2,-2032 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201458:	08300593          	li	a1,131
ffffffffc020145c:	00004517          	auipc	a0,0x4
ffffffffc0201460:	81c50513          	addi	a0,a0,-2020 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201464:	f0dfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc0201468:	00004697          	auipc	a3,0x4
ffffffffc020146c:	b7868693          	addi	a3,a3,-1160 # ffffffffc0204fe0 <commands+0xbf0>
ffffffffc0201470:	00003617          	auipc	a2,0x3
ffffffffc0201474:	7f060613          	addi	a2,a2,2032 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201478:	08000593          	li	a1,128
ffffffffc020147c:	00003517          	auipc	a0,0x3
ffffffffc0201480:	7fc50513          	addi	a0,a0,2044 # ffffffffc0204c78 <commands+0x888>
ffffffffc0201484:	eedfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201488 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201488:	cd51                	beqz	a0,ffffffffc0201524 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020148a:	00010597          	auipc	a1,0x10
ffffffffc020148e:	ffe58593          	addi	a1,a1,-2 # ffffffffc0211488 <free_area>
ffffffffc0201492:	0105a803          	lw	a6,16(a1)
ffffffffc0201496:	862a                	mv	a2,a0
ffffffffc0201498:	02081793          	slli	a5,a6,0x20
ffffffffc020149c:	9381                	srli	a5,a5,0x20
ffffffffc020149e:	00a7ee63          	bltu	a5,a0,ffffffffc02014ba <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014a2:	87ae                	mv	a5,a1
ffffffffc02014a4:	a801                	j	ffffffffc02014b4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014aa:	02071693          	slli	a3,a4,0x20
ffffffffc02014ae:	9281                	srli	a3,a3,0x20
ffffffffc02014b0:	00c6f763          	bgeu	a3,a2,ffffffffc02014be <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014b4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014b6:	feb798e3          	bne	a5,a1,ffffffffc02014a6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ba:	4501                	li	a0,0
}
ffffffffc02014bc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014be:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014c2:	dd6d                	beqz	a0,ffffffffc02014bc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014c4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014c8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014cc:	00060e1b          	sext.w	t3,a2
ffffffffc02014d0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014d4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014d8:	02d67b63          	bgeu	a2,a3,ffffffffc020150e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014dc:	00361693          	slli	a3,a2,0x3
ffffffffc02014e0:	96b2                	add	a3,a3,a2
ffffffffc02014e2:	068e                	slli	a3,a3,0x3
ffffffffc02014e4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014e6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014ea:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ec:	00868613          	addi	a2,a3,8
ffffffffc02014f0:	4709                	li	a4,2
ffffffffc02014f2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014f6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014fa:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014fe:	0105a803          	lw	a6,16(a1)
ffffffffc0201502:	e310                	sd	a2,0(a4)
ffffffffc0201504:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201508:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020150a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020150e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201512:	00010717          	auipc	a4,0x10
ffffffffc0201516:	f9072323          	sw	a6,-122(a4) # ffffffffc0211498 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020151a:	5775                	li	a4,-3
ffffffffc020151c:	17a1                	addi	a5,a5,-24
ffffffffc020151e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201522:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201524:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201526:	00004697          	auipc	a3,0x4
ffffffffc020152a:	aba68693          	addi	a3,a3,-1350 # ffffffffc0204fe0 <commands+0xbf0>
ffffffffc020152e:	00003617          	auipc	a2,0x3
ffffffffc0201532:	73260613          	addi	a2,a2,1842 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201536:	06200593          	li	a1,98
ffffffffc020153a:	00003517          	auipc	a0,0x3
ffffffffc020153e:	73e50513          	addi	a0,a0,1854 # ffffffffc0204c78 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201542:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201544:	e2dfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201548 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201548:	1141                	addi	sp,sp,-16
ffffffffc020154a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020154c:	c1fd                	beqz	a1,ffffffffc0201632 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020154e:	00359693          	slli	a3,a1,0x3
ffffffffc0201552:	96ae                	add	a3,a3,a1
ffffffffc0201554:	068e                	slli	a3,a3,0x3
ffffffffc0201556:	96aa                	add	a3,a3,a0
ffffffffc0201558:	02d50463          	beq	a0,a3,ffffffffc0201580 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020155c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020155e:	87aa                	mv	a5,a0
ffffffffc0201560:	8b05                	andi	a4,a4,1
ffffffffc0201562:	e709                	bnez	a4,ffffffffc020156c <default_init_memmap+0x24>
ffffffffc0201564:	a07d                	j	ffffffffc0201612 <default_init_memmap+0xca>
ffffffffc0201566:	6798                	ld	a4,8(a5)
ffffffffc0201568:	8b05                	andi	a4,a4,1
ffffffffc020156a:	c745                	beqz	a4,ffffffffc0201612 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020156c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201570:	0007b423          	sd	zero,8(a5)
ffffffffc0201574:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201578:	04878793          	addi	a5,a5,72
ffffffffc020157c:	fed795e3          	bne	a5,a3,ffffffffc0201566 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201580:	2581                	sext.w	a1,a1
ffffffffc0201582:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201584:	4789                	li	a5,2
ffffffffc0201586:	00850713          	addi	a4,a0,8
ffffffffc020158a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020158e:	00010697          	auipc	a3,0x10
ffffffffc0201592:	efa68693          	addi	a3,a3,-262 # ffffffffc0211488 <free_area>
ffffffffc0201596:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201598:	669c                	ld	a5,8(a3)
ffffffffc020159a:	9db9                	addw	a1,a1,a4
ffffffffc020159c:	00010717          	auipc	a4,0x10
ffffffffc02015a0:	eeb72e23          	sw	a1,-260(a4) # ffffffffc0211498 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015a4:	04d78a63          	beq	a5,a3,ffffffffc02015f8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015a8:	fe078713          	addi	a4,a5,-32
ffffffffc02015ac:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ae:	4801                	li	a6,0
ffffffffc02015b0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015b4:	00e56a63          	bltu	a0,a4,ffffffffc02015c8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015b8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ba:	02d70563          	beq	a4,a3,ffffffffc02015e4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015c0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015c4:	fee57ae3          	bgeu	a0,a4,ffffffffc02015b8 <default_init_memmap+0x70>
ffffffffc02015c8:	00080663          	beqz	a6,ffffffffc02015d4 <default_init_memmap+0x8c>
ffffffffc02015cc:	00010717          	auipc	a4,0x10
ffffffffc02015d0:	eab73e23          	sd	a1,-324(a4) # ffffffffc0211488 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015d4:	6398                	ld	a4,0(a5)
}
ffffffffc02015d6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015d8:	e390                	sd	a2,0(a5)
ffffffffc02015da:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015dc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015de:	f118                	sd	a4,32(a0)
ffffffffc02015e0:	0141                	addi	sp,sp,16
ffffffffc02015e2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015e4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015e6:	f514                	sd	a3,40(a0)
ffffffffc02015e8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015ea:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015ec:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015ee:	00d70e63          	beq	a4,a3,ffffffffc020160a <default_init_memmap+0xc2>
ffffffffc02015f2:	4805                	li	a6,1
ffffffffc02015f4:	87ba                	mv	a5,a4
ffffffffc02015f6:	b7e9                	j	ffffffffc02015c0 <default_init_memmap+0x78>
}
ffffffffc02015f8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015fa:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015fe:	e398                	sd	a4,0(a5)
ffffffffc0201600:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201602:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201604:	f11c                	sd	a5,32(a0)
}
ffffffffc0201606:	0141                	addi	sp,sp,16
ffffffffc0201608:	8082                	ret
ffffffffc020160a:	60a2                	ld	ra,8(sp)
ffffffffc020160c:	e290                	sd	a2,0(a3)
ffffffffc020160e:	0141                	addi	sp,sp,16
ffffffffc0201610:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201612:	00004697          	auipc	a3,0x4
ffffffffc0201616:	9d668693          	addi	a3,a3,-1578 # ffffffffc0204fe8 <commands+0xbf8>
ffffffffc020161a:	00003617          	auipc	a2,0x3
ffffffffc020161e:	64660613          	addi	a2,a2,1606 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201622:	04900593          	li	a1,73
ffffffffc0201626:	00003517          	auipc	a0,0x3
ffffffffc020162a:	65250513          	addi	a0,a0,1618 # ffffffffc0204c78 <commands+0x888>
ffffffffc020162e:	d43fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc0201632:	00004697          	auipc	a3,0x4
ffffffffc0201636:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0204fe0 <commands+0xbf0>
ffffffffc020163a:	00003617          	auipc	a2,0x3
ffffffffc020163e:	62660613          	addi	a2,a2,1574 # ffffffffc0204c60 <commands+0x870>
ffffffffc0201642:	04600593          	li	a1,70
ffffffffc0201646:	00003517          	auipc	a0,0x3
ffffffffc020164a:	63250513          	addi	a0,a0,1586 # ffffffffc0204c78 <commands+0x888>
ffffffffc020164e:	d23fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201652 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201652:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201654:	00004617          	auipc	a2,0x4
ffffffffc0201658:	a6c60613          	addi	a2,a2,-1428 # ffffffffc02050c0 <default_pmm_manager+0xc8>
ffffffffc020165c:	06500593          	li	a1,101
ffffffffc0201660:	00004517          	auipc	a0,0x4
ffffffffc0201664:	a8050513          	addi	a0,a0,-1408 # ffffffffc02050e0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201668:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020166a:	d07fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020166e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020166e:	715d                	addi	sp,sp,-80
ffffffffc0201670:	e0a2                	sd	s0,64(sp)
ffffffffc0201672:	fc26                	sd	s1,56(sp)
ffffffffc0201674:	f84a                	sd	s2,48(sp)
ffffffffc0201676:	f44e                	sd	s3,40(sp)
ffffffffc0201678:	f052                	sd	s4,32(sp)
ffffffffc020167a:	ec56                	sd	s5,24(sp)
ffffffffc020167c:	e486                	sd	ra,72(sp)
ffffffffc020167e:	842a                	mv	s0,a0
ffffffffc0201680:	00010497          	auipc	s1,0x10
ffffffffc0201684:	e2048493          	addi	s1,s1,-480 # ffffffffc02114a0 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201688:	4985                	li	s3,1
ffffffffc020168a:	00010a17          	auipc	s4,0x10
ffffffffc020168e:	deea0a13          	addi	s4,s4,-530 # ffffffffc0211478 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201692:	0005091b          	sext.w	s2,a0
ffffffffc0201696:	00010a97          	auipc	s5,0x10
ffffffffc020169a:	f0aa8a93          	addi	s5,s5,-246 # ffffffffc02115a0 <check_mm_struct>
ffffffffc020169e:	a00d                	j	ffffffffc02016c0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016a0:	609c                	ld	a5,0(s1)
ffffffffc02016a2:	6f9c                	ld	a5,24(a5)
ffffffffc02016a4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016a6:	4601                	li	a2,0
ffffffffc02016a8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016aa:	ed0d                	bnez	a0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016ac:	0289ec63          	bltu	s3,s0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016b0:	000a2783          	lw	a5,0(s4)
ffffffffc02016b4:	2781                	sext.w	a5,a5
ffffffffc02016b6:	c79d                	beqz	a5,ffffffffc02016e4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016b8:	000ab503          	ld	a0,0(s5)
ffffffffc02016bc:	013010ef          	jal	ra,ffffffffc0202ece <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c0:	100027f3          	csrr	a5,sstatus
ffffffffc02016c4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016c6:	8522                	mv	a0,s0
ffffffffc02016c8:	dfe1                	beqz	a5,ffffffffc02016a0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016ca:	e29fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02016ce:	609c                	ld	a5,0(s1)
ffffffffc02016d0:	8522                	mv	a0,s0
ffffffffc02016d2:	6f9c                	ld	a5,24(a5)
ffffffffc02016d4:	9782                	jalr	a5
ffffffffc02016d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016d8:	e15fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02016dc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016de:	4601                	li	a2,0
ffffffffc02016e0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e2:	d569                	beqz	a0,ffffffffc02016ac <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016e4:	60a6                	ld	ra,72(sp)
ffffffffc02016e6:	6406                	ld	s0,64(sp)
ffffffffc02016e8:	74e2                	ld	s1,56(sp)
ffffffffc02016ea:	7942                	ld	s2,48(sp)
ffffffffc02016ec:	79a2                	ld	s3,40(sp)
ffffffffc02016ee:	7a02                	ld	s4,32(sp)
ffffffffc02016f0:	6ae2                	ld	s5,24(sp)
ffffffffc02016f2:	6161                	addi	sp,sp,80
ffffffffc02016f4:	8082                	ret

ffffffffc02016f6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f6:	100027f3          	csrr	a5,sstatus
ffffffffc02016fa:	8b89                	andi	a5,a5,2
ffffffffc02016fc:	eb89                	bnez	a5,ffffffffc020170e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016fe:	00010797          	auipc	a5,0x10
ffffffffc0201702:	da278793          	addi	a5,a5,-606 # ffffffffc02114a0 <pmm_manager>
ffffffffc0201706:	639c                	ld	a5,0(a5)
ffffffffc0201708:	0207b303          	ld	t1,32(a5)
ffffffffc020170c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020170e:	1101                	addi	sp,sp,-32
ffffffffc0201710:	ec06                	sd	ra,24(sp)
ffffffffc0201712:	e822                	sd	s0,16(sp)
ffffffffc0201714:	e426                	sd	s1,8(sp)
ffffffffc0201716:	842a                	mv	s0,a0
ffffffffc0201718:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020171a:	dd9fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020171e:	00010797          	auipc	a5,0x10
ffffffffc0201722:	d8278793          	addi	a5,a5,-638 # ffffffffc02114a0 <pmm_manager>
ffffffffc0201726:	639c                	ld	a5,0(a5)
ffffffffc0201728:	85a6                	mv	a1,s1
ffffffffc020172a:	8522                	mv	a0,s0
ffffffffc020172c:	739c                	ld	a5,32(a5)
ffffffffc020172e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201730:	6442                	ld	s0,16(sp)
ffffffffc0201732:	60e2                	ld	ra,24(sp)
ffffffffc0201734:	64a2                	ld	s1,8(sp)
ffffffffc0201736:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201738:	db5fe06f          	j	ffffffffc02004ec <intr_enable>

ffffffffc020173c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020173c:	100027f3          	csrr	a5,sstatus
ffffffffc0201740:	8b89                	andi	a5,a5,2
ffffffffc0201742:	eb89                	bnez	a5,ffffffffc0201754 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201744:	00010797          	auipc	a5,0x10
ffffffffc0201748:	d5c78793          	addi	a5,a5,-676 # ffffffffc02114a0 <pmm_manager>
ffffffffc020174c:	639c                	ld	a5,0(a5)
ffffffffc020174e:	0287b303          	ld	t1,40(a5)
ffffffffc0201752:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201754:	1141                	addi	sp,sp,-16
ffffffffc0201756:	e406                	sd	ra,8(sp)
ffffffffc0201758:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020175a:	d99fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020175e:	00010797          	auipc	a5,0x10
ffffffffc0201762:	d4278793          	addi	a5,a5,-702 # ffffffffc02114a0 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	779c                	ld	a5,40(a5)
ffffffffc020176a:	9782                	jalr	a5
ffffffffc020176c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020176e:	d7ffe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201772:	8522                	mv	a0,s0
ffffffffc0201774:	60a2                	ld	ra,8(sp)
ffffffffc0201776:	6402                	ld	s0,0(sp)
ffffffffc0201778:	0141                	addi	sp,sp,16
ffffffffc020177a:	8082                	ret

ffffffffc020177c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020177c:	715d                	addi	sp,sp,-80
ffffffffc020177e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201780:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201784:	1ff4f493          	andi	s1,s1,511
ffffffffc0201788:	048e                	slli	s1,s1,0x3
ffffffffc020178a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020178c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020178e:	f84a                	sd	s2,48(sp)
ffffffffc0201790:	f44e                	sd	s3,40(sp)
ffffffffc0201792:	f052                	sd	s4,32(sp)
ffffffffc0201794:	e486                	sd	ra,72(sp)
ffffffffc0201796:	e0a2                	sd	s0,64(sp)
ffffffffc0201798:	ec56                	sd	s5,24(sp)
ffffffffc020179a:	e85a                	sd	s6,16(sp)
ffffffffc020179c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020179e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017a2:	892e                	mv	s2,a1
ffffffffc02017a4:	8a32                	mv	s4,a2
ffffffffc02017a6:	00010997          	auipc	s3,0x10
ffffffffc02017aa:	cc298993          	addi	s3,s3,-830 # ffffffffc0211468 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ae:	e3c9                	bnez	a5,ffffffffc0201830 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017b0:	16060163          	beqz	a2,ffffffffc0201912 <get_pte+0x196>
ffffffffc02017b4:	4505                	li	a0,1
ffffffffc02017b6:	eb9ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc02017ba:	842a                	mv	s0,a0
ffffffffc02017bc:	14050b63          	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c0:	00010b97          	auipc	s7,0x10
ffffffffc02017c4:	cf8b8b93          	addi	s7,s7,-776 # ffffffffc02114b8 <pages>
ffffffffc02017c8:	000bb503          	ld	a0,0(s7)
ffffffffc02017cc:	00003797          	auipc	a5,0x3
ffffffffc02017d0:	47c78793          	addi	a5,a5,1148 # ffffffffc0204c48 <commands+0x858>
ffffffffc02017d4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017d8:	40a40533          	sub	a0,s0,a0
ffffffffc02017dc:	850d                	srai	a0,a0,0x3
ffffffffc02017de:	03650533          	mul	a0,a0,s6
ffffffffc02017e2:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017e6:	00010997          	auipc	s3,0x10
ffffffffc02017ea:	c8298993          	addi	s3,s3,-894 # ffffffffc0211468 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017ee:	4785                	li	a5,1
ffffffffc02017f0:	0009b703          	ld	a4,0(s3)
ffffffffc02017f4:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017f6:	9556                	add	a0,a0,s5
ffffffffc02017f8:	00c51793          	slli	a5,a0,0xc
ffffffffc02017fc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017fe:	0532                	slli	a0,a0,0xc
ffffffffc0201800:	16e7f063          	bgeu	a5,a4,ffffffffc0201960 <get_pte+0x1e4>
ffffffffc0201804:	00010797          	auipc	a5,0x10
ffffffffc0201808:	ca478793          	addi	a5,a5,-860 # ffffffffc02114a8 <va_pa_offset>
ffffffffc020180c:	639c                	ld	a5,0(a5)
ffffffffc020180e:	6605                	lui	a2,0x1
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	953e                	add	a0,a0,a5
ffffffffc0201814:	285020ef          	jal	ra,ffffffffc0204298 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201818:	000bb683          	ld	a3,0(s7)
ffffffffc020181c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201820:	868d                	srai	a3,a3,0x3
ffffffffc0201822:	036686b3          	mul	a3,a3,s6
ffffffffc0201826:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201828:	06aa                	slli	a3,a3,0xa
ffffffffc020182a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020182e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201830:	77fd                	lui	a5,0xfffff
ffffffffc0201832:	068a                	slli	a3,a3,0x2
ffffffffc0201834:	0009b703          	ld	a4,0(s3)
ffffffffc0201838:	8efd                	and	a3,a3,a5
ffffffffc020183a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020183e:	0ce7fc63          	bgeu	a5,a4,ffffffffc0201916 <get_pte+0x19a>
ffffffffc0201842:	00010a97          	auipc	s5,0x10
ffffffffc0201846:	c66a8a93          	addi	s5,s5,-922 # ffffffffc02114a8 <va_pa_offset>
ffffffffc020184a:	000ab403          	ld	s0,0(s5)
ffffffffc020184e:	01595793          	srli	a5,s2,0x15
ffffffffc0201852:	1ff7f793          	andi	a5,a5,511
ffffffffc0201856:	96a2                	add	a3,a3,s0
ffffffffc0201858:	00379413          	slli	s0,a5,0x3
ffffffffc020185c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020185e:	6014                	ld	a3,0(s0)
ffffffffc0201860:	0016f793          	andi	a5,a3,1
ffffffffc0201864:	ebbd                	bnez	a5,ffffffffc02018da <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201866:	0a0a0663          	beqz	s4,ffffffffc0201912 <get_pte+0x196>
ffffffffc020186a:	4505                	li	a0,1
ffffffffc020186c:	e03ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201870:	84aa                	mv	s1,a0
ffffffffc0201872:	c145                	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201874:	00010b97          	auipc	s7,0x10
ffffffffc0201878:	c44b8b93          	addi	s7,s7,-956 # ffffffffc02114b8 <pages>
ffffffffc020187c:	000bb503          	ld	a0,0(s7)
ffffffffc0201880:	00003797          	auipc	a5,0x3
ffffffffc0201884:	3c878793          	addi	a5,a5,968 # ffffffffc0204c48 <commands+0x858>
ffffffffc0201888:	0007bb03          	ld	s6,0(a5)
ffffffffc020188c:	40a48533          	sub	a0,s1,a0
ffffffffc0201890:	850d                	srai	a0,a0,0x3
ffffffffc0201892:	03650533          	mul	a0,a0,s6
ffffffffc0201896:	00080a37          	lui	s4,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020189a:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020189c:	0009b703          	ld	a4,0(s3)
ffffffffc02018a0:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018a2:	9552                	add	a0,a0,s4
ffffffffc02018a4:	00c51793          	slli	a5,a0,0xc
ffffffffc02018a8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02018aa:	0532                	slli	a0,a0,0xc
ffffffffc02018ac:	08e7fd63          	bgeu	a5,a4,ffffffffc0201946 <get_pte+0x1ca>
ffffffffc02018b0:	000ab783          	ld	a5,0(s5)
ffffffffc02018b4:	6605                	lui	a2,0x1
ffffffffc02018b6:	4581                	li	a1,0
ffffffffc02018b8:	953e                	add	a0,a0,a5
ffffffffc02018ba:	1df020ef          	jal	ra,ffffffffc0204298 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018be:	000bb683          	ld	a3,0(s7)
ffffffffc02018c2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018c6:	868d                	srai	a3,a3,0x3
ffffffffc02018c8:	036686b3          	mul	a3,a3,s6
ffffffffc02018cc:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018ce:	06aa                	slli	a3,a3,0xa
ffffffffc02018d0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018d4:	e014                	sd	a3,0(s0)
ffffffffc02018d6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018da:	068a                	slli	a3,a3,0x2
ffffffffc02018dc:	757d                	lui	a0,0xfffff
ffffffffc02018de:	8ee9                	and	a3,a3,a0
ffffffffc02018e0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018e4:	04e7f563          	bgeu	a5,a4,ffffffffc020192e <get_pte+0x1b2>
ffffffffc02018e8:	000ab503          	ld	a0,0(s5)
ffffffffc02018ec:	00c95793          	srli	a5,s2,0xc
ffffffffc02018f0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018f4:	96aa                	add	a3,a3,a0
ffffffffc02018f6:	00379513          	slli	a0,a5,0x3
ffffffffc02018fa:	9536                	add	a0,a0,a3
}
ffffffffc02018fc:	60a6                	ld	ra,72(sp)
ffffffffc02018fe:	6406                	ld	s0,64(sp)
ffffffffc0201900:	74e2                	ld	s1,56(sp)
ffffffffc0201902:	7942                	ld	s2,48(sp)
ffffffffc0201904:	79a2                	ld	s3,40(sp)
ffffffffc0201906:	7a02                	ld	s4,32(sp)
ffffffffc0201908:	6ae2                	ld	s5,24(sp)
ffffffffc020190a:	6b42                	ld	s6,16(sp)
ffffffffc020190c:	6ba2                	ld	s7,8(sp)
ffffffffc020190e:	6161                	addi	sp,sp,80
ffffffffc0201910:	8082                	ret
            return NULL;
ffffffffc0201912:	4501                	li	a0,0
ffffffffc0201914:	b7e5                	j	ffffffffc02018fc <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201916:	00003617          	auipc	a2,0x3
ffffffffc020191a:	73260613          	addi	a2,a2,1842 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc020191e:	10200593          	li	a1,258
ffffffffc0201922:	00003517          	auipc	a0,0x3
ffffffffc0201926:	74e50513          	addi	a0,a0,1870 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020192a:	a47fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020192e:	00003617          	auipc	a2,0x3
ffffffffc0201932:	71a60613          	addi	a2,a2,1818 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0201936:	10f00593          	li	a1,271
ffffffffc020193a:	00003517          	auipc	a0,0x3
ffffffffc020193e:	73650513          	addi	a0,a0,1846 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0201942:	a2ffe0ef          	jal	ra,ffffffffc0200370 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201946:	86aa                	mv	a3,a0
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	70060613          	addi	a2,a2,1792 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0201950:	10b00593          	li	a1,267
ffffffffc0201954:	00003517          	auipc	a0,0x3
ffffffffc0201958:	71c50513          	addi	a0,a0,1820 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020195c:	a15fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201960:	86aa                	mv	a3,a0
ffffffffc0201962:	00003617          	auipc	a2,0x3
ffffffffc0201966:	6e660613          	addi	a2,a2,1766 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc020196a:	0ff00593          	li	a1,255
ffffffffc020196e:	00003517          	auipc	a0,0x3
ffffffffc0201972:	70250513          	addi	a0,a0,1794 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0201976:	9fbfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020197a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020197a:	1141                	addi	sp,sp,-16
ffffffffc020197c:	e022                	sd	s0,0(sp)
ffffffffc020197e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201980:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201982:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201984:	df9ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201988:	c011                	beqz	s0,ffffffffc020198c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020198a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020198c:	c511                	beqz	a0,ffffffffc0201998 <get_page+0x1e>
ffffffffc020198e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201990:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201992:	0017f713          	andi	a4,a5,1
ffffffffc0201996:	e709                	bnez	a4,ffffffffc02019a0 <get_page+0x26>
}
ffffffffc0201998:	60a2                	ld	ra,8(sp)
ffffffffc020199a:	6402                	ld	s0,0(sp)
ffffffffc020199c:	0141                	addi	sp,sp,16
ffffffffc020199e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	00010717          	auipc	a4,0x10
ffffffffc02019a4:	ac870713          	addi	a4,a4,-1336 # ffffffffc0211468 <npage>
ffffffffc02019a8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019aa:	078a                	slli	a5,a5,0x2
ffffffffc02019ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019ae:	02e7f363          	bgeu	a5,a4,ffffffffc02019d4 <get_page+0x5a>
    return &pages[PPN(pa) - nbase];
ffffffffc02019b2:	fff80537          	lui	a0,0xfff80
ffffffffc02019b6:	97aa                	add	a5,a5,a0
ffffffffc02019b8:	00010697          	auipc	a3,0x10
ffffffffc02019bc:	b0068693          	addi	a3,a3,-1280 # ffffffffc02114b8 <pages>
ffffffffc02019c0:	6288                	ld	a0,0(a3)
ffffffffc02019c2:	60a2                	ld	ra,8(sp)
ffffffffc02019c4:	6402                	ld	s0,0(sp)
ffffffffc02019c6:	00379713          	slli	a4,a5,0x3
ffffffffc02019ca:	97ba                	add	a5,a5,a4
ffffffffc02019cc:	078e                	slli	a5,a5,0x3
ffffffffc02019ce:	953e                	add	a0,a0,a5
ffffffffc02019d0:	0141                	addi	sp,sp,16
ffffffffc02019d2:	8082                	ret
ffffffffc02019d4:	c7fff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc02019d8 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019d8:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019da:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019dc:	e406                	sd	ra,8(sp)
ffffffffc02019de:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e0:	d9dff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep != NULL) {
ffffffffc02019e4:	c511                	beqz	a0,ffffffffc02019f0 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02019e6:	611c                	ld	a5,0(a0)
ffffffffc02019e8:	842a                	mv	s0,a0
ffffffffc02019ea:	0017f713          	andi	a4,a5,1
ffffffffc02019ee:	e709                	bnez	a4,ffffffffc02019f8 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019f0:	60a2                	ld	ra,8(sp)
ffffffffc02019f2:	6402                	ld	s0,0(sp)
ffffffffc02019f4:	0141                	addi	sp,sp,16
ffffffffc02019f6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019f8:	00010717          	auipc	a4,0x10
ffffffffc02019fc:	a7070713          	addi	a4,a4,-1424 # ffffffffc0211468 <npage>
ffffffffc0201a00:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a02:	078a                	slli	a5,a5,0x2
ffffffffc0201a04:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a06:	04e7f063          	bgeu	a5,a4,ffffffffc0201a46 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a0a:	fff80737          	lui	a4,0xfff80
ffffffffc0201a0e:	97ba                	add	a5,a5,a4
ffffffffc0201a10:	00010717          	auipc	a4,0x10
ffffffffc0201a14:	aa870713          	addi	a4,a4,-1368 # ffffffffc02114b8 <pages>
ffffffffc0201a18:	6308                	ld	a0,0(a4)
ffffffffc0201a1a:	00379713          	slli	a4,a5,0x3
ffffffffc0201a1e:	97ba                	add	a5,a5,a4
ffffffffc0201a20:	078e                	slli	a5,a5,0x3
ffffffffc0201a22:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a24:	411c                	lw	a5,0(a0)
ffffffffc0201a26:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a2a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a2c:	cb09                	beqz	a4,ffffffffc0201a3e <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a2e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a32:	12000073          	sfence.vma
}
ffffffffc0201a36:	60a2                	ld	ra,8(sp)
ffffffffc0201a38:	6402                	ld	s0,0(sp)
ffffffffc0201a3a:	0141                	addi	sp,sp,16
ffffffffc0201a3c:	8082                	ret
            free_page(page);
ffffffffc0201a3e:	4585                	li	a1,1
ffffffffc0201a40:	cb7ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201a44:	b7ed                	j	ffffffffc0201a2e <page_remove+0x56>
ffffffffc0201a46:	c0dff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201a4a <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a4a:	7179                	addi	sp,sp,-48
ffffffffc0201a4c:	87b2                	mv	a5,a2
ffffffffc0201a4e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a50:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a52:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a54:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a56:	ec26                	sd	s1,24(sp)
ffffffffc0201a58:	f406                	sd	ra,40(sp)
ffffffffc0201a5a:	e84a                	sd	s2,16(sp)
ffffffffc0201a5c:	e44e                	sd	s3,8(sp)
ffffffffc0201a5e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a60:	d1dff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a64:	c945                	beqz	a0,ffffffffc0201b14 <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a66:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a68:	611c                	ld	a5,0(a0)
ffffffffc0201a6a:	892a                	mv	s2,a0
ffffffffc0201a6c:	0016871b          	addiw	a4,a3,1
ffffffffc0201a70:	c018                	sw	a4,0(s0)
ffffffffc0201a72:	0017f713          	andi	a4,a5,1
ffffffffc0201a76:	e339                	bnez	a4,ffffffffc0201abc <page_insert+0x72>
ffffffffc0201a78:	00010797          	auipc	a5,0x10
ffffffffc0201a7c:	a4078793          	addi	a5,a5,-1472 # ffffffffc02114b8 <pages>
ffffffffc0201a80:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a82:	00003717          	auipc	a4,0x3
ffffffffc0201a86:	1c670713          	addi	a4,a4,454 # ffffffffc0204c48 <commands+0x858>
ffffffffc0201a8a:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a8e:	6300                	ld	s0,0(a4)
ffffffffc0201a90:	878d                	srai	a5,a5,0x3
ffffffffc0201a92:	000806b7          	lui	a3,0x80
ffffffffc0201a96:	028787b3          	mul	a5,a5,s0
ffffffffc0201a9a:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a9c:	07aa                	slli	a5,a5,0xa
ffffffffc0201a9e:	8fc5                	or	a5,a5,s1
ffffffffc0201aa0:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201aa4:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201aa8:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201aac:	4501                	li	a0,0
}
ffffffffc0201aae:	70a2                	ld	ra,40(sp)
ffffffffc0201ab0:	7402                	ld	s0,32(sp)
ffffffffc0201ab2:	64e2                	ld	s1,24(sp)
ffffffffc0201ab4:	6942                	ld	s2,16(sp)
ffffffffc0201ab6:	69a2                	ld	s3,8(sp)
ffffffffc0201ab8:	6145                	addi	sp,sp,48
ffffffffc0201aba:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201abc:	00010717          	auipc	a4,0x10
ffffffffc0201ac0:	9ac70713          	addi	a4,a4,-1620 # ffffffffc0211468 <npage>
ffffffffc0201ac4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ac6:	00279513          	slli	a0,a5,0x2
ffffffffc0201aca:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201acc:	04e57663          	bgeu	a0,a4,ffffffffc0201b18 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ad0:	fff807b7          	lui	a5,0xfff80
ffffffffc0201ad4:	953e                	add	a0,a0,a5
ffffffffc0201ad6:	00010997          	auipc	s3,0x10
ffffffffc0201ada:	9e298993          	addi	s3,s3,-1566 # ffffffffc02114b8 <pages>
ffffffffc0201ade:	0009b783          	ld	a5,0(s3)
ffffffffc0201ae2:	00351713          	slli	a4,a0,0x3
ffffffffc0201ae6:	953a                	add	a0,a0,a4
ffffffffc0201ae8:	050e                	slli	a0,a0,0x3
ffffffffc0201aea:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201aec:	00a40e63          	beq	s0,a0,ffffffffc0201b08 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201af0:	411c                	lw	a5,0(a0)
ffffffffc0201af2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201af6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201af8:	cb11                	beqz	a4,ffffffffc0201b0c <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201afa:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201afe:	12000073          	sfence.vma
ffffffffc0201b02:	0009b783          	ld	a5,0(s3)
ffffffffc0201b06:	bfb5                	j	ffffffffc0201a82 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b08:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b0a:	bfa5                	j	ffffffffc0201a82 <page_insert+0x38>
            free_page(page);
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	be9ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201b12:	b7e5                	j	ffffffffc0201afa <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b14:	5571                	li	a0,-4
ffffffffc0201b16:	bf61                	j	ffffffffc0201aae <page_insert+0x64>
ffffffffc0201b18:	b3bff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201b1c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b1c:	00003797          	auipc	a5,0x3
ffffffffc0201b20:	4dc78793          	addi	a5,a5,1244 # ffffffffc0204ff8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b24:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b26:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b28:	00003517          	auipc	a0,0x3
ffffffffc0201b2c:	5e050513          	addi	a0,a0,1504 # ffffffffc0205108 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b30:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b32:	00010717          	auipc	a4,0x10
ffffffffc0201b36:	96f73723          	sd	a5,-1682(a4) # ffffffffc02114a0 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b3a:	e8a2                	sd	s0,80(sp)
ffffffffc0201b3c:	e4a6                	sd	s1,72(sp)
ffffffffc0201b3e:	e0ca                	sd	s2,64(sp)
ffffffffc0201b40:	fc4e                	sd	s3,56(sp)
ffffffffc0201b42:	f852                	sd	s4,48(sp)
ffffffffc0201b44:	f456                	sd	s5,40(sp)
ffffffffc0201b46:	f05a                	sd	s6,32(sp)
ffffffffc0201b48:	ec5e                	sd	s7,24(sp)
ffffffffc0201b4a:	e862                	sd	s8,16(sp)
ffffffffc0201b4c:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b4e:	00010417          	auipc	s0,0x10
ffffffffc0201b52:	95240413          	addi	s0,s0,-1710 # ffffffffc02114a0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b56:	d68fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b5a:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b5c:	49c5                	li	s3,17
ffffffffc0201b5e:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b62:	679c                	ld	a5,8(a5)
ffffffffc0201b64:	00010497          	auipc	s1,0x10
ffffffffc0201b68:	90448493          	addi	s1,s1,-1788 # ffffffffc0211468 <npage>
ffffffffc0201b6c:	00010917          	auipc	s2,0x10
ffffffffc0201b70:	94c90913          	addi	s2,s2,-1716 # ffffffffc02114b8 <pages>
ffffffffc0201b74:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b76:	57f5                	li	a5,-3
ffffffffc0201b78:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b7a:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b7e:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b82:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b86:	00003517          	auipc	a0,0x3
ffffffffc0201b8a:	59a50513          	addi	a0,a0,1434 # ffffffffc0205120 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b8e:	00010717          	auipc	a4,0x10
ffffffffc0201b92:	90f73d23          	sd	a5,-1766(a4) # ffffffffc02114a8 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b96:	d28fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b9a:	00003517          	auipc	a0,0x3
ffffffffc0201b9e:	5b650513          	addi	a0,a0,1462 # ffffffffc0205150 <default_pmm_manager+0x158>
ffffffffc0201ba2:	d1cfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201ba6:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201baa:	16fd                	addi	a3,a3,-1
ffffffffc0201bac:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bb0:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bb4:	00003517          	auipc	a0,0x3
ffffffffc0201bb8:	5b450513          	addi	a0,a0,1460 # ffffffffc0205168 <default_pmm_manager+0x170>
ffffffffc0201bbc:	d02fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bc0:	777d                	lui	a4,0xfffff
ffffffffc0201bc2:	00011797          	auipc	a5,0x11
ffffffffc0201bc6:	9e578793          	addi	a5,a5,-1563 # ffffffffc02125a7 <end+0xfff>
ffffffffc0201bca:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bcc:	00088737          	lui	a4,0x88
ffffffffc0201bd0:	00010697          	auipc	a3,0x10
ffffffffc0201bd4:	88e6bc23          	sd	a4,-1896(a3) # ffffffffc0211468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bd8:	00010717          	auipc	a4,0x10
ffffffffc0201bdc:	8ef73023          	sd	a5,-1824(a4) # ffffffffc02114b8 <pages>
ffffffffc0201be0:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201be2:	4701                	li	a4,0
ffffffffc0201be4:	4585                	li	a1,1
ffffffffc0201be6:	fff80637          	lui	a2,0xfff80
ffffffffc0201bea:	a019                	j	ffffffffc0201bf0 <pmm_init+0xd4>
ffffffffc0201bec:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201bf0:	97b6                	add	a5,a5,a3
ffffffffc0201bf2:	07a1                	addi	a5,a5,8
ffffffffc0201bf4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bf8:	609c                	ld	a5,0(s1)
ffffffffc0201bfa:	0705                	addi	a4,a4,1
ffffffffc0201bfc:	04868693          	addi	a3,a3,72
ffffffffc0201c00:	00c78533          	add	a0,a5,a2
ffffffffc0201c04:	fea764e3          	bltu	a4,a0,ffffffffc0201bec <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c08:	00093503          	ld	a0,0(s2)
ffffffffc0201c0c:	00379693          	slli	a3,a5,0x3
ffffffffc0201c10:	96be                	add	a3,a3,a5
ffffffffc0201c12:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c16:	972a                	add	a4,a4,a0
ffffffffc0201c18:	068e                	slli	a3,a3,0x3
ffffffffc0201c1a:	96ba                	add	a3,a3,a4
ffffffffc0201c1c:	c0200737          	lui	a4,0xc0200
ffffffffc0201c20:	58e6e863          	bltu	a3,a4,ffffffffc02021b0 <pmm_init+0x694>
ffffffffc0201c24:	00010997          	auipc	s3,0x10
ffffffffc0201c28:	88498993          	addi	s3,s3,-1916 # ffffffffc02114a8 <va_pa_offset>
ffffffffc0201c2c:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c30:	45c5                	li	a1,17
ffffffffc0201c32:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c34:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c36:	44b6ed63          	bltu	a3,a1,ffffffffc0202090 <pmm_init+0x574>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c3a:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c3c:	00010417          	auipc	s0,0x10
ffffffffc0201c40:	82440413          	addi	s0,s0,-2012 # ffffffffc0211460 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c44:	7b9c                	ld	a5,48(a5)
ffffffffc0201c46:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c48:	00003517          	auipc	a0,0x3
ffffffffc0201c4c:	57050513          	addi	a0,a0,1392 # ffffffffc02051b8 <default_pmm_manager+0x1c0>
ffffffffc0201c50:	c6efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c54:	00007697          	auipc	a3,0x7
ffffffffc0201c58:	3ac68693          	addi	a3,a3,940 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c5c:	00010797          	auipc	a5,0x10
ffffffffc0201c60:	80d7b223          	sd	a3,-2044(a5) # ffffffffc0211460 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c64:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c68:	0ef6eae3          	bltu	a3,a5,ffffffffc020255c <pmm_init+0xa40>
ffffffffc0201c6c:	0009b783          	ld	a5,0(s3)
ffffffffc0201c70:	8e9d                	sub	a3,a3,a5
ffffffffc0201c72:	00010797          	auipc	a5,0x10
ffffffffc0201c76:	82d7bf23          	sd	a3,-1986(a5) # ffffffffc02114b0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c7a:	ac3ff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c7e:	6098                	ld	a4,0(s1)
ffffffffc0201c80:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c84:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c86:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c88:	0ae7eae3          	bltu	a5,a4,ffffffffc020253c <pmm_init+0xa20>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c8c:	6008                	ld	a0,0(s0)
ffffffffc0201c8e:	4c050163          	beqz	a0,ffffffffc0202150 <pmm_init+0x634>
ffffffffc0201c92:	03451793          	slli	a5,a0,0x34
ffffffffc0201c96:	4a079d63          	bnez	a5,ffffffffc0202150 <pmm_init+0x634>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c9a:	4601                	li	a2,0
ffffffffc0201c9c:	4581                	li	a1,0
ffffffffc0201c9e:	cddff0ef          	jal	ra,ffffffffc020197a <get_page>
ffffffffc0201ca2:	4c051763          	bnez	a0,ffffffffc0202170 <pmm_init+0x654>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201ca6:	4505                	li	a0,1
ffffffffc0201ca8:	9c7ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201cac:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cae:	6008                	ld	a0,0(s0)
ffffffffc0201cb0:	4681                	li	a3,0
ffffffffc0201cb2:	4601                	li	a2,0
ffffffffc0201cb4:	85d6                	mv	a1,s5
ffffffffc0201cb6:	d95ff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0201cba:	52051763          	bnez	a0,ffffffffc02021e8 <pmm_init+0x6cc>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cbe:	6008                	ld	a0,0(s0)
ffffffffc0201cc0:	4601                	li	a2,0
ffffffffc0201cc2:	4581                	li	a1,0
ffffffffc0201cc4:	ab9ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201cc8:	50050063          	beqz	a0,ffffffffc02021c8 <pmm_init+0x6ac>
    assert(pte2page(*ptep) == p1);
ffffffffc0201ccc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cce:	0017f713          	andi	a4,a5,1
ffffffffc0201cd2:	46070363          	beqz	a4,ffffffffc0202138 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201cd6:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cd8:	078a                	slli	a5,a5,0x2
ffffffffc0201cda:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cdc:	44c7f063          	bgeu	a5,a2,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ce0:	fff80737          	lui	a4,0xfff80
ffffffffc0201ce4:	97ba                	add	a5,a5,a4
ffffffffc0201ce6:	00379713          	slli	a4,a5,0x3
ffffffffc0201cea:	00093683          	ld	a3,0(s2)
ffffffffc0201cee:	97ba                	add	a5,a5,a4
ffffffffc0201cf0:	078e                	slli	a5,a5,0x3
ffffffffc0201cf2:	97b6                	add	a5,a5,a3
ffffffffc0201cf4:	5efa9463          	bne	s5,a5,ffffffffc02022dc <pmm_init+0x7c0>
    assert(page_ref(p1) == 1);
ffffffffc0201cf8:	000aab83          	lw	s7,0(s5)
ffffffffc0201cfc:	4785                	li	a5,1
ffffffffc0201cfe:	5afb9f63          	bne	s7,a5,ffffffffc02022bc <pmm_init+0x7a0>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d02:	6008                	ld	a0,0(s0)
ffffffffc0201d04:	76fd                	lui	a3,0xfffff
ffffffffc0201d06:	611c                	ld	a5,0(a0)
ffffffffc0201d08:	078a                	slli	a5,a5,0x2
ffffffffc0201d0a:	8ff5                	and	a5,a5,a3
ffffffffc0201d0c:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d10:	58c77963          	bgeu	a4,a2,ffffffffc02022a2 <pmm_init+0x786>
ffffffffc0201d14:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d18:	97e2                	add	a5,a5,s8
ffffffffc0201d1a:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deea58>
ffffffffc0201d1e:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d20:	00db7b33          	and	s6,s6,a3
ffffffffc0201d24:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d28:	56c7f063          	bgeu	a5,a2,ffffffffc0202288 <pmm_init+0x76c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d2c:	4601                	li	a2,0
ffffffffc0201d2e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d30:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d32:	a4bff0ef          	jal	ra,ffffffffc020177c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d36:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d38:	53651863          	bne	a0,s6,ffffffffc0202268 <pmm_init+0x74c>

    p2 = alloc_page();
ffffffffc0201d3c:	4505                	li	a0,1
ffffffffc0201d3e:	931ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201d42:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d44:	6008                	ld	a0,0(s0)
ffffffffc0201d46:	46d1                	li	a3,20
ffffffffc0201d48:	6605                	lui	a2,0x1
ffffffffc0201d4a:	85da                	mv	a1,s6
ffffffffc0201d4c:	cffff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0201d50:	4e051c63          	bnez	a0,ffffffffc0202248 <pmm_init+0x72c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d54:	6008                	ld	a0,0(s0)
ffffffffc0201d56:	4601                	li	a2,0
ffffffffc0201d58:	6585                	lui	a1,0x1
ffffffffc0201d5a:	a23ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201d5e:	4c050563          	beqz	a0,ffffffffc0202228 <pmm_init+0x70c>
    assert(*ptep & PTE_U);
ffffffffc0201d62:	611c                	ld	a5,0(a0)
ffffffffc0201d64:	0107f713          	andi	a4,a5,16
ffffffffc0201d68:	4a070063          	beqz	a4,ffffffffc0202208 <pmm_init+0x6ec>
    assert(*ptep & PTE_W);
ffffffffc0201d6c:	8b91                	andi	a5,a5,4
ffffffffc0201d6e:	66078763          	beqz	a5,ffffffffc02023dc <pmm_init+0x8c0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d72:	6008                	ld	a0,0(s0)
ffffffffc0201d74:	611c                	ld	a5,0(a0)
ffffffffc0201d76:	8bc1                	andi	a5,a5,16
ffffffffc0201d78:	64078263          	beqz	a5,ffffffffc02023bc <pmm_init+0x8a0>
    assert(page_ref(p2) == 1);
ffffffffc0201d7c:	000b2783          	lw	a5,0(s6)
ffffffffc0201d80:	61779e63          	bne	a5,s7,ffffffffc020239c <pmm_init+0x880>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d84:	4681                	li	a3,0
ffffffffc0201d86:	6605                	lui	a2,0x1
ffffffffc0201d88:	85d6                	mv	a1,s5
ffffffffc0201d8a:	cc1ff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0201d8e:	5e051763          	bnez	a0,ffffffffc020237c <pmm_init+0x860>
    assert(page_ref(p1) == 2);
ffffffffc0201d92:	000aa703          	lw	a4,0(s5)
ffffffffc0201d96:	4789                	li	a5,2
ffffffffc0201d98:	5cf71263          	bne	a4,a5,ffffffffc020235c <pmm_init+0x840>
    assert(page_ref(p2) == 0);
ffffffffc0201d9c:	000b2783          	lw	a5,0(s6)
ffffffffc0201da0:	58079e63          	bnez	a5,ffffffffc020233c <pmm_init+0x820>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201da4:	6008                	ld	a0,0(s0)
ffffffffc0201da6:	4601                	li	a2,0
ffffffffc0201da8:	6585                	lui	a1,0x1
ffffffffc0201daa:	9d3ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201dae:	56050763          	beqz	a0,ffffffffc020231c <pmm_init+0x800>
    assert(pte2page(*ptep) == p1);
ffffffffc0201db2:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201db4:	0016f793          	andi	a5,a3,1
ffffffffc0201db8:	38078063          	beqz	a5,ffffffffc0202138 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201dbc:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dbe:	00269793          	slli	a5,a3,0x2
ffffffffc0201dc2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dc4:	34e7fc63          	bgeu	a5,a4,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dc8:	fff80737          	lui	a4,0xfff80
ffffffffc0201dcc:	97ba                	add	a5,a5,a4
ffffffffc0201dce:	00379713          	slli	a4,a5,0x3
ffffffffc0201dd2:	00093603          	ld	a2,0(s2)
ffffffffc0201dd6:	97ba                	add	a5,a5,a4
ffffffffc0201dd8:	078e                	slli	a5,a5,0x3
ffffffffc0201dda:	97b2                	add	a5,a5,a2
ffffffffc0201ddc:	52fa9063          	bne	s5,a5,ffffffffc02022fc <pmm_init+0x7e0>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201de0:	8ac1                	andi	a3,a3,16
ffffffffc0201de2:	6e069d63          	bnez	a3,ffffffffc02024dc <pmm_init+0x9c0>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201de6:	6008                	ld	a0,0(s0)
ffffffffc0201de8:	4581                	li	a1,0
ffffffffc0201dea:	befff0ef          	jal	ra,ffffffffc02019d8 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dee:	000aa703          	lw	a4,0(s5)
ffffffffc0201df2:	4785                	li	a5,1
ffffffffc0201df4:	6cf71463          	bne	a4,a5,ffffffffc02024bc <pmm_init+0x9a0>
    assert(page_ref(p2) == 0);
ffffffffc0201df8:	000b2783          	lw	a5,0(s6)
ffffffffc0201dfc:	6a079063          	bnez	a5,ffffffffc020249c <pmm_init+0x980>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e00:	6008                	ld	a0,0(s0)
ffffffffc0201e02:	6585                	lui	a1,0x1
ffffffffc0201e04:	bd5ff0ef          	jal	ra,ffffffffc02019d8 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e08:	000aa783          	lw	a5,0(s5)
ffffffffc0201e0c:	66079863          	bnez	a5,ffffffffc020247c <pmm_init+0x960>
    assert(page_ref(p2) == 0);
ffffffffc0201e10:	000b2783          	lw	a5,0(s6)
ffffffffc0201e14:	70079463          	bnez	a5,ffffffffc020251c <pmm_init+0xa00>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e18:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e1c:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1e:	000b3783          	ld	a5,0(s6)
ffffffffc0201e22:	078a                	slli	a5,a5,0x2
ffffffffc0201e24:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e26:	2ec7fb63          	bgeu	a5,a2,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e2a:	fff80737          	lui	a4,0xfff80
ffffffffc0201e2e:	973e                	add	a4,a4,a5
ffffffffc0201e30:	00371793          	slli	a5,a4,0x3
ffffffffc0201e34:	00093803          	ld	a6,0(s2)
ffffffffc0201e38:	97ba                	add	a5,a5,a4
ffffffffc0201e3a:	078e                	slli	a5,a5,0x3
ffffffffc0201e3c:	00f80733          	add	a4,a6,a5
ffffffffc0201e40:	4314                	lw	a3,0(a4)
ffffffffc0201e42:	4705                	li	a4,1
ffffffffc0201e44:	6ae69c63          	bne	a3,a4,ffffffffc02024fc <pmm_init+0x9e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e48:	00003a97          	auipc	s5,0x3
ffffffffc0201e4c:	e00a8a93          	addi	s5,s5,-512 # ffffffffc0204c48 <commands+0x858>
ffffffffc0201e50:	000ab703          	ld	a4,0(s5)
ffffffffc0201e54:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e58:	00080bb7          	lui	s7,0x80
ffffffffc0201e5c:	02e686b3          	mul	a3,a3,a4
ffffffffc0201e60:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e62:	00c69793          	slli	a5,a3,0xc
ffffffffc0201e66:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e68:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6a:	2ac7fb63          	bgeu	a5,a2,ffffffffc0202120 <pmm_init+0x604>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e6e:	0009b703          	ld	a4,0(s3)
ffffffffc0201e72:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e74:	629c                	ld	a5,0(a3)
ffffffffc0201e76:	078a                	slli	a5,a5,0x2
ffffffffc0201e78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e7a:	2ac7f163          	bgeu	a5,a2,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e7e:	417787b3          	sub	a5,a5,s7
ffffffffc0201e82:	00379513          	slli	a0,a5,0x3
ffffffffc0201e86:	97aa                	add	a5,a5,a0
ffffffffc0201e88:	00379513          	slli	a0,a5,0x3
ffffffffc0201e8c:	9542                	add	a0,a0,a6
ffffffffc0201e8e:	4585                	li	a1,1
ffffffffc0201e90:	867ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e94:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201e98:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e9a:	050a                	slli	a0,a0,0x2
ffffffffc0201e9c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e9e:	26f57f63          	bgeu	a0,a5,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ea2:	417507b3          	sub	a5,a0,s7
ffffffffc0201ea6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eaa:	00093703          	ld	a4,0(s2)
ffffffffc0201eae:	953e                	add	a0,a0,a5
ffffffffc0201eb0:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201eb2:	4585                	li	a1,1
ffffffffc0201eb4:	953a                	add	a0,a0,a4
ffffffffc0201eb6:	841ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201eba:	601c                	ld	a5,0(s0)
ffffffffc0201ebc:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ec0:	87dff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0201ec4:	2caa1663          	bne	s4,a0,ffffffffc0202190 <pmm_init+0x674>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ec8:	00003517          	auipc	a0,0x3
ffffffffc0201ecc:	60050513          	addi	a0,a0,1536 # ffffffffc02054c8 <default_pmm_manager+0x4d0>
ffffffffc0201ed0:	9eefe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201ed4:	869ff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ed8:	6098                	ld	a4,0(s1)
ffffffffc0201eda:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201ede:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ee0:	00c71693          	slli	a3,a4,0xc
ffffffffc0201ee4:	1cd7fd63          	bgeu	a5,a3,ffffffffc02020be <pmm_init+0x5a2>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ee8:	83b1                	srli	a5,a5,0xc
ffffffffc0201eea:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eec:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ef0:	1ce7f963          	bgeu	a5,a4,ffffffffc02020c2 <pmm_init+0x5a6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ef4:	7c7d                	lui	s8,0xfffff
ffffffffc0201ef6:	6b85                	lui	s7,0x1
ffffffffc0201ef8:	a029                	j	ffffffffc0201f02 <pmm_init+0x3e6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201efa:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201efe:	1cf77263          	bgeu	a4,a5,ffffffffc02020c2 <pmm_init+0x5a6>
ffffffffc0201f02:	0009b583          	ld	a1,0(s3)
ffffffffc0201f06:	4601                	li	a2,0
ffffffffc0201f08:	95d2                	add	a1,a1,s4
ffffffffc0201f0a:	873ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201f0e:	1c050763          	beqz	a0,ffffffffc02020dc <pmm_init+0x5c0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f12:	611c                	ld	a5,0(a0)
ffffffffc0201f14:	078a                	slli	a5,a5,0x2
ffffffffc0201f16:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f1a:	1f479163          	bne	a5,s4,ffffffffc02020fc <pmm_init+0x5e0>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1e:	609c                	ld	a5,0(s1)
ffffffffc0201f20:	9a5e                	add	s4,s4,s7
ffffffffc0201f22:	6008                	ld	a0,0(s0)
ffffffffc0201f24:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f28:	fcea69e3          	bltu	s4,a4,ffffffffc0201efa <pmm_init+0x3de>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f2c:	611c                	ld	a5,0(a0)
ffffffffc0201f2e:	6a079363          	bnez	a5,ffffffffc02025d4 <pmm_init+0xab8>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f32:	4505                	li	a0,1
ffffffffc0201f34:	f3aff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201f38:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f3a:	6008                	ld	a0,0(s0)
ffffffffc0201f3c:	4699                	li	a3,6
ffffffffc0201f3e:	10000613          	li	a2,256
ffffffffc0201f42:	85d2                	mv	a1,s4
ffffffffc0201f44:	b07ff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0201f48:	66051663          	bnez	a0,ffffffffc02025b4 <pmm_init+0xa98>
    assert(page_ref(p) == 1);
ffffffffc0201f4c:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f50:	4785                	li	a5,1
ffffffffc0201f52:	64f71163          	bne	a4,a5,ffffffffc0202594 <pmm_init+0xa78>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f56:	6008                	ld	a0,0(s0)
ffffffffc0201f58:	6b85                	lui	s7,0x1
ffffffffc0201f5a:	4699                	li	a3,6
ffffffffc0201f5c:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f60:	85d2                	mv	a1,s4
ffffffffc0201f62:	ae9ff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0201f66:	60051763          	bnez	a0,ffffffffc0202574 <pmm_init+0xa58>
    assert(page_ref(p) == 2);
ffffffffc0201f6a:	000a2703          	lw	a4,0(s4)
ffffffffc0201f6e:	4789                	li	a5,2
ffffffffc0201f70:	4ef71663          	bne	a4,a5,ffffffffc020245c <pmm_init+0x940>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f74:	00003597          	auipc	a1,0x3
ffffffffc0201f78:	68c58593          	addi	a1,a1,1676 # ffffffffc0205600 <default_pmm_manager+0x608>
ffffffffc0201f7c:	10000513          	li	a0,256
ffffffffc0201f80:	2be020ef          	jal	ra,ffffffffc020423e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f84:	100b8593          	addi	a1,s7,256
ffffffffc0201f88:	10000513          	li	a0,256
ffffffffc0201f8c:	2c4020ef          	jal	ra,ffffffffc0204250 <strcmp>
ffffffffc0201f90:	4a051663          	bnez	a0,ffffffffc020243c <pmm_init+0x920>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f94:	00093683          	ld	a3,0(s2)
ffffffffc0201f98:	000abc83          	ld	s9,0(s5)
ffffffffc0201f9c:	00080c37          	lui	s8,0x80
ffffffffc0201fa0:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fa4:	868d                	srai	a3,a3,0x3
ffffffffc0201fa6:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201faa:	5afd                	li	s5,-1
ffffffffc0201fac:	609c                	ld	a5,0(s1)
ffffffffc0201fae:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fb2:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb4:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fb8:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fba:	16f77363          	bgeu	a4,a5,ffffffffc0202120 <pmm_init+0x604>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fbe:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fc2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fc6:	96be                	add	a3,a3,a5
ffffffffc0201fc8:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb58>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fcc:	22e020ef          	jal	ra,ffffffffc02041fa <strlen>
ffffffffc0201fd0:	44051663          	bnez	a0,ffffffffc020241c <pmm_init+0x900>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fd4:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fd8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fda:	000bb783          	ld	a5,0(s7)
ffffffffc0201fde:	078a                	slli	a5,a5,0x2
ffffffffc0201fe0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe2:	12e7fd63          	bgeu	a5,a4,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fe6:	418787b3          	sub	a5,a5,s8
ffffffffc0201fea:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fee:	96be                	add	a3,a3,a5
ffffffffc0201ff0:	039686b3          	mul	a3,a3,s9
ffffffffc0201ff4:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff6:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ffa:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ffc:	12eaf263          	bgeu	s5,a4,ffffffffc0202120 <pmm_init+0x604>
ffffffffc0202000:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202004:	4585                	li	a1,1
ffffffffc0202006:	8552                	mv	a0,s4
ffffffffc0202008:	99b6                	add	s3,s3,a3
ffffffffc020200a:	eecff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020200e:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202012:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202014:	078a                	slli	a5,a5,0x2
ffffffffc0202016:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202018:	10e7f263          	bgeu	a5,a4,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc020201c:	fff809b7          	lui	s3,0xfff80
ffffffffc0202020:	97ce                	add	a5,a5,s3
ffffffffc0202022:	00379513          	slli	a0,a5,0x3
ffffffffc0202026:	00093703          	ld	a4,0(s2)
ffffffffc020202a:	97aa                	add	a5,a5,a0
ffffffffc020202c:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0202030:	953a                	add	a0,a0,a4
ffffffffc0202032:	4585                	li	a1,1
ffffffffc0202034:	ec2ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202038:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020203c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020203e:	050a                	slli	a0,a0,0x2
ffffffffc0202040:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202042:	0cf57d63          	bgeu	a0,a5,ffffffffc020211c <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0202046:	013507b3          	add	a5,a0,s3
ffffffffc020204a:	00379513          	slli	a0,a5,0x3
ffffffffc020204e:	00093703          	ld	a4,0(s2)
ffffffffc0202052:	953e                	add	a0,a0,a5
ffffffffc0202054:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202056:	4585                	li	a1,1
ffffffffc0202058:	953a                	add	a0,a0,a4
ffffffffc020205a:	e9cff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020205e:	601c                	ld	a5,0(s0)
ffffffffc0202060:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202064:	ed8ff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0202068:	38ab1a63          	bne	s6,a0,ffffffffc02023fc <pmm_init+0x8e0>
}
ffffffffc020206c:	6446                	ld	s0,80(sp)
ffffffffc020206e:	60e6                	ld	ra,88(sp)
ffffffffc0202070:	64a6                	ld	s1,72(sp)
ffffffffc0202072:	6906                	ld	s2,64(sp)
ffffffffc0202074:	79e2                	ld	s3,56(sp)
ffffffffc0202076:	7a42                	ld	s4,48(sp)
ffffffffc0202078:	7aa2                	ld	s5,40(sp)
ffffffffc020207a:	7b02                	ld	s6,32(sp)
ffffffffc020207c:	6be2                	ld	s7,24(sp)
ffffffffc020207e:	6c42                	ld	s8,16(sp)
ffffffffc0202080:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202082:	00003517          	auipc	a0,0x3
ffffffffc0202086:	5f650513          	addi	a0,a0,1526 # ffffffffc0205678 <default_pmm_manager+0x680>
}
ffffffffc020208a:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020208c:	832fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202090:	6705                	lui	a4,0x1
ffffffffc0202092:	177d                	addi	a4,a4,-1
ffffffffc0202094:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202096:	00c6d713          	srli	a4,a3,0xc
ffffffffc020209a:	08f77163          	bgeu	a4,a5,ffffffffc020211c <pmm_init+0x600>
    pmm_manager->init_memmap(base, n);
ffffffffc020209e:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020a2:	9732                	add	a4,a4,a2
ffffffffc02020a4:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020a8:	767d                	lui	a2,0xfffff
ffffffffc02020aa:	8ef1                	and	a3,a3,a2
ffffffffc02020ac:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020ae:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020b2:	8d95                	sub	a1,a1,a3
ffffffffc02020b4:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020b6:	81b1                	srli	a1,a1,0xc
ffffffffc02020b8:	953e                	add	a0,a0,a5
ffffffffc02020ba:	9702                	jalr	a4
ffffffffc02020bc:	bebd                	j	ffffffffc0201c3a <pmm_init+0x11e>
ffffffffc02020be:	6008                	ld	a0,0(s0)
ffffffffc02020c0:	b5b5                	j	ffffffffc0201f2c <pmm_init+0x410>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020c2:	86d2                	mv	a3,s4
ffffffffc02020c4:	00003617          	auipc	a2,0x3
ffffffffc02020c8:	f8460613          	addi	a2,a2,-124 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc02020cc:	1cd00593          	li	a1,461
ffffffffc02020d0:	00003517          	auipc	a0,0x3
ffffffffc02020d4:	fa050513          	addi	a0,a0,-96 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02020d8:	a98fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02020dc:	00003697          	auipc	a3,0x3
ffffffffc02020e0:	40c68693          	addi	a3,a3,1036 # ffffffffc02054e8 <default_pmm_manager+0x4f0>
ffffffffc02020e4:	00003617          	auipc	a2,0x3
ffffffffc02020e8:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0204c60 <commands+0x870>
ffffffffc02020ec:	1cd00593          	li	a1,461
ffffffffc02020f0:	00003517          	auipc	a0,0x3
ffffffffc02020f4:	f8050513          	addi	a0,a0,-128 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02020f8:	a78fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02020fc:	00003697          	auipc	a3,0x3
ffffffffc0202100:	42c68693          	addi	a3,a3,1068 # ffffffffc0205528 <default_pmm_manager+0x530>
ffffffffc0202104:	00003617          	auipc	a2,0x3
ffffffffc0202108:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0204c60 <commands+0x870>
ffffffffc020210c:	1ce00593          	li	a1,462
ffffffffc0202110:	00003517          	auipc	a0,0x3
ffffffffc0202114:	f6050513          	addi	a0,a0,-160 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202118:	a58fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc020211c:	d36ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202120:	00003617          	auipc	a2,0x3
ffffffffc0202124:	f2860613          	addi	a2,a2,-216 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0202128:	06a00593          	li	a1,106
ffffffffc020212c:	00003517          	auipc	a0,0x3
ffffffffc0202130:	fb450513          	addi	a0,a0,-76 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0202134:	a3cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202138:	00003617          	auipc	a2,0x3
ffffffffc020213c:	18060613          	addi	a2,a2,384 # ffffffffc02052b8 <default_pmm_manager+0x2c0>
ffffffffc0202140:	07000593          	li	a1,112
ffffffffc0202144:	00003517          	auipc	a0,0x3
ffffffffc0202148:	f9c50513          	addi	a0,a0,-100 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc020214c:	a24fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202150:	00003697          	auipc	a3,0x3
ffffffffc0202154:	0a868693          	addi	a3,a3,168 # ffffffffc02051f8 <default_pmm_manager+0x200>
ffffffffc0202158:	00003617          	auipc	a2,0x3
ffffffffc020215c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202160:	19300593          	li	a1,403
ffffffffc0202164:	00003517          	auipc	a0,0x3
ffffffffc0202168:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020216c:	a04fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202170:	00003697          	auipc	a3,0x3
ffffffffc0202174:	0c068693          	addi	a3,a3,192 # ffffffffc0205230 <default_pmm_manager+0x238>
ffffffffc0202178:	00003617          	auipc	a2,0x3
ffffffffc020217c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202180:	19400593          	li	a1,404
ffffffffc0202184:	00003517          	auipc	a0,0x3
ffffffffc0202188:	eec50513          	addi	a0,a0,-276 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020218c:	9e4fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202190:	00003697          	auipc	a3,0x3
ffffffffc0202194:	31868693          	addi	a3,a3,792 # ffffffffc02054a8 <default_pmm_manager+0x4b0>
ffffffffc0202198:	00003617          	auipc	a2,0x3
ffffffffc020219c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204c60 <commands+0x870>
ffffffffc02021a0:	1c000593          	li	a1,448
ffffffffc02021a4:	00003517          	auipc	a0,0x3
ffffffffc02021a8:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02021ac:	9c4fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021b0:	00003617          	auipc	a2,0x3
ffffffffc02021b4:	fe060613          	addi	a2,a2,-32 # ffffffffc0205190 <default_pmm_manager+0x198>
ffffffffc02021b8:	07700593          	li	a1,119
ffffffffc02021bc:	00003517          	auipc	a0,0x3
ffffffffc02021c0:	eb450513          	addi	a0,a0,-332 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02021c4:	9acfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021c8:	00003697          	auipc	a3,0x3
ffffffffc02021cc:	0c068693          	addi	a3,a3,192 # ffffffffc0205288 <default_pmm_manager+0x290>
ffffffffc02021d0:	00003617          	auipc	a2,0x3
ffffffffc02021d4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204c60 <commands+0x870>
ffffffffc02021d8:	19a00593          	li	a1,410
ffffffffc02021dc:	00003517          	auipc	a0,0x3
ffffffffc02021e0:	e9450513          	addi	a0,a0,-364 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02021e4:	98cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021e8:	00003697          	auipc	a3,0x3
ffffffffc02021ec:	07068693          	addi	a3,a3,112 # ffffffffc0205258 <default_pmm_manager+0x260>
ffffffffc02021f0:	00003617          	auipc	a2,0x3
ffffffffc02021f4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204c60 <commands+0x870>
ffffffffc02021f8:	19800593          	li	a1,408
ffffffffc02021fc:	00003517          	auipc	a0,0x3
ffffffffc0202200:	e7450513          	addi	a0,a0,-396 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202204:	96cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202208:	00003697          	auipc	a3,0x3
ffffffffc020220c:	19868693          	addi	a3,a3,408 # ffffffffc02053a0 <default_pmm_manager+0x3a8>
ffffffffc0202210:	00003617          	auipc	a2,0x3
ffffffffc0202214:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202218:	1a500593          	li	a1,421
ffffffffc020221c:	00003517          	auipc	a0,0x3
ffffffffc0202220:	e5450513          	addi	a0,a0,-428 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202224:	94cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202228:	00003697          	auipc	a3,0x3
ffffffffc020222c:	14868693          	addi	a3,a3,328 # ffffffffc0205370 <default_pmm_manager+0x378>
ffffffffc0202230:	00003617          	auipc	a2,0x3
ffffffffc0202234:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202238:	1a400593          	li	a1,420
ffffffffc020223c:	00003517          	auipc	a0,0x3
ffffffffc0202240:	e3450513          	addi	a0,a0,-460 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202244:	92cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202248:	00003697          	auipc	a3,0x3
ffffffffc020224c:	0f068693          	addi	a3,a3,240 # ffffffffc0205338 <default_pmm_manager+0x340>
ffffffffc0202250:	00003617          	auipc	a2,0x3
ffffffffc0202254:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202258:	1a300593          	li	a1,419
ffffffffc020225c:	00003517          	auipc	a0,0x3
ffffffffc0202260:	e1450513          	addi	a0,a0,-492 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202264:	90cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202268:	00003697          	auipc	a3,0x3
ffffffffc020226c:	0a868693          	addi	a3,a3,168 # ffffffffc0205310 <default_pmm_manager+0x318>
ffffffffc0202270:	00003617          	auipc	a2,0x3
ffffffffc0202274:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202278:	1a000593          	li	a1,416
ffffffffc020227c:	00003517          	auipc	a0,0x3
ffffffffc0202280:	df450513          	addi	a0,a0,-524 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202284:	8ecfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202288:	86da                	mv	a3,s6
ffffffffc020228a:	00003617          	auipc	a2,0x3
ffffffffc020228e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0202292:	19f00593          	li	a1,415
ffffffffc0202296:	00003517          	auipc	a0,0x3
ffffffffc020229a:	dda50513          	addi	a0,a0,-550 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020229e:	8d2fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022a2:	86be                	mv	a3,a5
ffffffffc02022a4:	00003617          	auipc	a2,0x3
ffffffffc02022a8:	da460613          	addi	a2,a2,-604 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc02022ac:	19e00593          	li	a1,414
ffffffffc02022b0:	00003517          	auipc	a0,0x3
ffffffffc02022b4:	dc050513          	addi	a0,a0,-576 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02022b8:	8b8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022bc:	00003697          	auipc	a3,0x3
ffffffffc02022c0:	03c68693          	addi	a3,a3,60 # ffffffffc02052f8 <default_pmm_manager+0x300>
ffffffffc02022c4:	00003617          	auipc	a2,0x3
ffffffffc02022c8:	99c60613          	addi	a2,a2,-1636 # ffffffffc0204c60 <commands+0x870>
ffffffffc02022cc:	19c00593          	li	a1,412
ffffffffc02022d0:	00003517          	auipc	a0,0x3
ffffffffc02022d4:	da050513          	addi	a0,a0,-608 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02022d8:	898fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022dc:	00003697          	auipc	a3,0x3
ffffffffc02022e0:	00468693          	addi	a3,a3,4 # ffffffffc02052e0 <default_pmm_manager+0x2e8>
ffffffffc02022e4:	00003617          	auipc	a2,0x3
ffffffffc02022e8:	97c60613          	addi	a2,a2,-1668 # ffffffffc0204c60 <commands+0x870>
ffffffffc02022ec:	19b00593          	li	a1,411
ffffffffc02022f0:	00003517          	auipc	a0,0x3
ffffffffc02022f4:	d8050513          	addi	a0,a0,-640 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02022f8:	878fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022fc:	00003697          	auipc	a3,0x3
ffffffffc0202300:	fe468693          	addi	a3,a3,-28 # ffffffffc02052e0 <default_pmm_manager+0x2e8>
ffffffffc0202304:	00003617          	auipc	a2,0x3
ffffffffc0202308:	95c60613          	addi	a2,a2,-1700 # ffffffffc0204c60 <commands+0x870>
ffffffffc020230c:	1ae00593          	li	a1,430
ffffffffc0202310:	00003517          	auipc	a0,0x3
ffffffffc0202314:	d6050513          	addi	a0,a0,-672 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202318:	858fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020231c:	00003697          	auipc	a3,0x3
ffffffffc0202320:	05468693          	addi	a3,a3,84 # ffffffffc0205370 <default_pmm_manager+0x378>
ffffffffc0202324:	00003617          	auipc	a2,0x3
ffffffffc0202328:	93c60613          	addi	a2,a2,-1732 # ffffffffc0204c60 <commands+0x870>
ffffffffc020232c:	1ad00593          	li	a1,429
ffffffffc0202330:	00003517          	auipc	a0,0x3
ffffffffc0202334:	d4050513          	addi	a0,a0,-704 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202338:	838fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020233c:	00003697          	auipc	a3,0x3
ffffffffc0202340:	0fc68693          	addi	a3,a3,252 # ffffffffc0205438 <default_pmm_manager+0x440>
ffffffffc0202344:	00003617          	auipc	a2,0x3
ffffffffc0202348:	91c60613          	addi	a2,a2,-1764 # ffffffffc0204c60 <commands+0x870>
ffffffffc020234c:	1ac00593          	li	a1,428
ffffffffc0202350:	00003517          	auipc	a0,0x3
ffffffffc0202354:	d2050513          	addi	a0,a0,-736 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202358:	818fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020235c:	00003697          	auipc	a3,0x3
ffffffffc0202360:	0c468693          	addi	a3,a3,196 # ffffffffc0205420 <default_pmm_manager+0x428>
ffffffffc0202364:	00003617          	auipc	a2,0x3
ffffffffc0202368:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0204c60 <commands+0x870>
ffffffffc020236c:	1ab00593          	li	a1,427
ffffffffc0202370:	00003517          	auipc	a0,0x3
ffffffffc0202374:	d0050513          	addi	a0,a0,-768 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202378:	ff9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020237c:	00003697          	auipc	a3,0x3
ffffffffc0202380:	07468693          	addi	a3,a3,116 # ffffffffc02053f0 <default_pmm_manager+0x3f8>
ffffffffc0202384:	00003617          	auipc	a2,0x3
ffffffffc0202388:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0204c60 <commands+0x870>
ffffffffc020238c:	1aa00593          	li	a1,426
ffffffffc0202390:	00003517          	auipc	a0,0x3
ffffffffc0202394:	ce050513          	addi	a0,a0,-800 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202398:	fd9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020239c:	00003697          	auipc	a3,0x3
ffffffffc02023a0:	03c68693          	addi	a3,a3,60 # ffffffffc02053d8 <default_pmm_manager+0x3e0>
ffffffffc02023a4:	00003617          	auipc	a2,0x3
ffffffffc02023a8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204c60 <commands+0x870>
ffffffffc02023ac:	1a800593          	li	a1,424
ffffffffc02023b0:	00003517          	auipc	a0,0x3
ffffffffc02023b4:	cc050513          	addi	a0,a0,-832 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02023b8:	fb9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023bc:	00003697          	auipc	a3,0x3
ffffffffc02023c0:	00468693          	addi	a3,a3,4 # ffffffffc02053c0 <default_pmm_manager+0x3c8>
ffffffffc02023c4:	00003617          	auipc	a2,0x3
ffffffffc02023c8:	89c60613          	addi	a2,a2,-1892 # ffffffffc0204c60 <commands+0x870>
ffffffffc02023cc:	1a700593          	li	a1,423
ffffffffc02023d0:	00003517          	auipc	a0,0x3
ffffffffc02023d4:	ca050513          	addi	a0,a0,-864 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02023d8:	f99fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023dc:	00003697          	auipc	a3,0x3
ffffffffc02023e0:	fd468693          	addi	a3,a3,-44 # ffffffffc02053b0 <default_pmm_manager+0x3b8>
ffffffffc02023e4:	00003617          	auipc	a2,0x3
ffffffffc02023e8:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204c60 <commands+0x870>
ffffffffc02023ec:	1a600593          	li	a1,422
ffffffffc02023f0:	00003517          	auipc	a0,0x3
ffffffffc02023f4:	c8050513          	addi	a0,a0,-896 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02023f8:	f79fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02023fc:	00003697          	auipc	a3,0x3
ffffffffc0202400:	0ac68693          	addi	a3,a3,172 # ffffffffc02054a8 <default_pmm_manager+0x4b0>
ffffffffc0202404:	00003617          	auipc	a2,0x3
ffffffffc0202408:	85c60613          	addi	a2,a2,-1956 # ffffffffc0204c60 <commands+0x870>
ffffffffc020240c:	1e800593          	li	a1,488
ffffffffc0202410:	00003517          	auipc	a0,0x3
ffffffffc0202414:	c6050513          	addi	a0,a0,-928 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202418:	f59fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020241c:	00003697          	auipc	a3,0x3
ffffffffc0202420:	23468693          	addi	a3,a3,564 # ffffffffc0205650 <default_pmm_manager+0x658>
ffffffffc0202424:	00003617          	auipc	a2,0x3
ffffffffc0202428:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204c60 <commands+0x870>
ffffffffc020242c:	1e000593          	li	a1,480
ffffffffc0202430:	00003517          	auipc	a0,0x3
ffffffffc0202434:	c4050513          	addi	a0,a0,-960 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202438:	f39fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020243c:	00003697          	auipc	a3,0x3
ffffffffc0202440:	1dc68693          	addi	a3,a3,476 # ffffffffc0205618 <default_pmm_manager+0x620>
ffffffffc0202444:	00003617          	auipc	a2,0x3
ffffffffc0202448:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204c60 <commands+0x870>
ffffffffc020244c:	1dd00593          	li	a1,477
ffffffffc0202450:	00003517          	auipc	a0,0x3
ffffffffc0202454:	c2050513          	addi	a0,a0,-992 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202458:	f19fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020245c:	00003697          	auipc	a3,0x3
ffffffffc0202460:	18c68693          	addi	a3,a3,396 # ffffffffc02055e8 <default_pmm_manager+0x5f0>
ffffffffc0202464:	00002617          	auipc	a2,0x2
ffffffffc0202468:	7fc60613          	addi	a2,a2,2044 # ffffffffc0204c60 <commands+0x870>
ffffffffc020246c:	1d900593          	li	a1,473
ffffffffc0202470:	00003517          	auipc	a0,0x3
ffffffffc0202474:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202478:	ef9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020247c:	00003697          	auipc	a3,0x3
ffffffffc0202480:	fec68693          	addi	a3,a3,-20 # ffffffffc0205468 <default_pmm_manager+0x470>
ffffffffc0202484:	00002617          	auipc	a2,0x2
ffffffffc0202488:	7dc60613          	addi	a2,a2,2012 # ffffffffc0204c60 <commands+0x870>
ffffffffc020248c:	1b600593          	li	a1,438
ffffffffc0202490:	00003517          	auipc	a0,0x3
ffffffffc0202494:	be050513          	addi	a0,a0,-1056 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202498:	ed9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020249c:	00003697          	auipc	a3,0x3
ffffffffc02024a0:	f9c68693          	addi	a3,a3,-100 # ffffffffc0205438 <default_pmm_manager+0x440>
ffffffffc02024a4:	00002617          	auipc	a2,0x2
ffffffffc02024a8:	7bc60613          	addi	a2,a2,1980 # ffffffffc0204c60 <commands+0x870>
ffffffffc02024ac:	1b300593          	li	a1,435
ffffffffc02024b0:	00003517          	auipc	a0,0x3
ffffffffc02024b4:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02024b8:	eb9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024bc:	00003697          	auipc	a3,0x3
ffffffffc02024c0:	e3c68693          	addi	a3,a3,-452 # ffffffffc02052f8 <default_pmm_manager+0x300>
ffffffffc02024c4:	00002617          	auipc	a2,0x2
ffffffffc02024c8:	79c60613          	addi	a2,a2,1948 # ffffffffc0204c60 <commands+0x870>
ffffffffc02024cc:	1b200593          	li	a1,434
ffffffffc02024d0:	00003517          	auipc	a0,0x3
ffffffffc02024d4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02024d8:	e99fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024dc:	00003697          	auipc	a3,0x3
ffffffffc02024e0:	f7468693          	addi	a3,a3,-140 # ffffffffc0205450 <default_pmm_manager+0x458>
ffffffffc02024e4:	00002617          	auipc	a2,0x2
ffffffffc02024e8:	77c60613          	addi	a2,a2,1916 # ffffffffc0204c60 <commands+0x870>
ffffffffc02024ec:	1af00593          	li	a1,431
ffffffffc02024f0:	00003517          	auipc	a0,0x3
ffffffffc02024f4:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02024f8:	e79fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024fc:	00003697          	auipc	a3,0x3
ffffffffc0202500:	f8468693          	addi	a3,a3,-124 # ffffffffc0205480 <default_pmm_manager+0x488>
ffffffffc0202504:	00002617          	auipc	a2,0x2
ffffffffc0202508:	75c60613          	addi	a2,a2,1884 # ffffffffc0204c60 <commands+0x870>
ffffffffc020250c:	1b900593          	li	a1,441
ffffffffc0202510:	00003517          	auipc	a0,0x3
ffffffffc0202514:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202518:	e59fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020251c:	00003697          	auipc	a3,0x3
ffffffffc0202520:	f1c68693          	addi	a3,a3,-228 # ffffffffc0205438 <default_pmm_manager+0x440>
ffffffffc0202524:	00002617          	auipc	a2,0x2
ffffffffc0202528:	73c60613          	addi	a2,a2,1852 # ffffffffc0204c60 <commands+0x870>
ffffffffc020252c:	1b700593          	li	a1,439
ffffffffc0202530:	00003517          	auipc	a0,0x3
ffffffffc0202534:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202538:	e39fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020253c:	00003697          	auipc	a3,0x3
ffffffffc0202540:	c9c68693          	addi	a3,a3,-868 # ffffffffc02051d8 <default_pmm_manager+0x1e0>
ffffffffc0202544:	00002617          	auipc	a2,0x2
ffffffffc0202548:	71c60613          	addi	a2,a2,1820 # ffffffffc0204c60 <commands+0x870>
ffffffffc020254c:	19200593          	li	a1,402
ffffffffc0202550:	00003517          	auipc	a0,0x3
ffffffffc0202554:	b2050513          	addi	a0,a0,-1248 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202558:	e19fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020255c:	00003617          	auipc	a2,0x3
ffffffffc0202560:	c3460613          	addi	a2,a2,-972 # ffffffffc0205190 <default_pmm_manager+0x198>
ffffffffc0202564:	0bd00593          	li	a1,189
ffffffffc0202568:	00003517          	auipc	a0,0x3
ffffffffc020256c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202570:	e01fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202574:	00003697          	auipc	a3,0x3
ffffffffc0202578:	03468693          	addi	a3,a3,52 # ffffffffc02055a8 <default_pmm_manager+0x5b0>
ffffffffc020257c:	00002617          	auipc	a2,0x2
ffffffffc0202580:	6e460613          	addi	a2,a2,1764 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202584:	1d800593          	li	a1,472
ffffffffc0202588:	00003517          	auipc	a0,0x3
ffffffffc020258c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202590:	de1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202594:	00003697          	auipc	a3,0x3
ffffffffc0202598:	ffc68693          	addi	a3,a3,-4 # ffffffffc0205590 <default_pmm_manager+0x598>
ffffffffc020259c:	00002617          	auipc	a2,0x2
ffffffffc02025a0:	6c460613          	addi	a2,a2,1732 # ffffffffc0204c60 <commands+0x870>
ffffffffc02025a4:	1d700593          	li	a1,471
ffffffffc02025a8:	00003517          	auipc	a0,0x3
ffffffffc02025ac:	ac850513          	addi	a0,a0,-1336 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02025b0:	dc1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025b4:	00003697          	auipc	a3,0x3
ffffffffc02025b8:	fa468693          	addi	a3,a3,-92 # ffffffffc0205558 <default_pmm_manager+0x560>
ffffffffc02025bc:	00002617          	auipc	a2,0x2
ffffffffc02025c0:	6a460613          	addi	a2,a2,1700 # ffffffffc0204c60 <commands+0x870>
ffffffffc02025c4:	1d600593          	li	a1,470
ffffffffc02025c8:	00003517          	auipc	a0,0x3
ffffffffc02025cc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02025d0:	da1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025d4:	00003697          	auipc	a3,0x3
ffffffffc02025d8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0205540 <default_pmm_manager+0x548>
ffffffffc02025dc:	00002617          	auipc	a2,0x2
ffffffffc02025e0:	68460613          	addi	a2,a2,1668 # ffffffffc0204c60 <commands+0x870>
ffffffffc02025e4:	1d200593          	li	a1,466
ffffffffc02025e8:	00003517          	auipc	a0,0x3
ffffffffc02025ec:	a8850513          	addi	a0,a0,-1400 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02025f0:	d81fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02025f4 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02025f4:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02025f8:	8082                	ret

ffffffffc02025fa <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025fa:	7179                	addi	sp,sp,-48
ffffffffc02025fc:	e84a                	sd	s2,16(sp)
ffffffffc02025fe:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202600:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202602:	f022                	sd	s0,32(sp)
ffffffffc0202604:	ec26                	sd	s1,24(sp)
ffffffffc0202606:	e44e                	sd	s3,8(sp)
ffffffffc0202608:	f406                	sd	ra,40(sp)
ffffffffc020260a:	84ae                	mv	s1,a1
ffffffffc020260c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020260e:	860ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0202612:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202614:	cd19                	beqz	a0,ffffffffc0202632 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202616:	85aa                	mv	a1,a0
ffffffffc0202618:	86ce                	mv	a3,s3
ffffffffc020261a:	8626                	mv	a2,s1
ffffffffc020261c:	854a                	mv	a0,s2
ffffffffc020261e:	c2cff0ef          	jal	ra,ffffffffc0201a4a <page_insert>
ffffffffc0202622:	ed39                	bnez	a0,ffffffffc0202680 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202624:	0000f797          	auipc	a5,0xf
ffffffffc0202628:	e5478793          	addi	a5,a5,-428 # ffffffffc0211478 <swap_init_ok>
ffffffffc020262c:	439c                	lw	a5,0(a5)
ffffffffc020262e:	2781                	sext.w	a5,a5
ffffffffc0202630:	eb89                	bnez	a5,ffffffffc0202642 <pgdir_alloc_page+0x48>
}
ffffffffc0202632:	8522                	mv	a0,s0
ffffffffc0202634:	70a2                	ld	ra,40(sp)
ffffffffc0202636:	7402                	ld	s0,32(sp)
ffffffffc0202638:	64e2                	ld	s1,24(sp)
ffffffffc020263a:	6942                	ld	s2,16(sp)
ffffffffc020263c:	69a2                	ld	s3,8(sp)
ffffffffc020263e:	6145                	addi	sp,sp,48
ffffffffc0202640:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202642:	0000f797          	auipc	a5,0xf
ffffffffc0202646:	f5e78793          	addi	a5,a5,-162 # ffffffffc02115a0 <check_mm_struct>
ffffffffc020264a:	6388                	ld	a0,0(a5)
ffffffffc020264c:	4681                	li	a3,0
ffffffffc020264e:	8622                	mv	a2,s0
ffffffffc0202650:	85a6                	mv	a1,s1
ffffffffc0202652:	06d000ef          	jal	ra,ffffffffc0202ebe <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202656:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202658:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020265a:	4785                	li	a5,1
ffffffffc020265c:	fcf70be3          	beq	a4,a5,ffffffffc0202632 <pgdir_alloc_page+0x38>
ffffffffc0202660:	00003697          	auipc	a3,0x3
ffffffffc0202664:	a9068693          	addi	a3,a3,-1392 # ffffffffc02050f0 <default_pmm_manager+0xf8>
ffffffffc0202668:	00002617          	auipc	a2,0x2
ffffffffc020266c:	5f860613          	addi	a2,a2,1528 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202670:	17a00593          	li	a1,378
ffffffffc0202674:	00003517          	auipc	a0,0x3
ffffffffc0202678:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020267c:	cf5fd0ef          	jal	ra,ffffffffc0200370 <__panic>
            free_page(page);
ffffffffc0202680:	8522                	mv	a0,s0
ffffffffc0202682:	4585                	li	a1,1
ffffffffc0202684:	872ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
            return NULL;
ffffffffc0202688:	4401                	li	s0,0
ffffffffc020268a:	b765                	j	ffffffffc0202632 <pgdir_alloc_page+0x38>

ffffffffc020268c <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020268c:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020268e:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0202690:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202692:	fff50713          	addi	a4,a0,-1
ffffffffc0202696:	17f9                	addi	a5,a5,-2
ffffffffc0202698:	04e7ee63          	bltu	a5,a4,ffffffffc02026f4 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020269c:	6785                	lui	a5,0x1
ffffffffc020269e:	17fd                	addi	a5,a5,-1
ffffffffc02026a0:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026a2:	8131                	srli	a0,a0,0xc
ffffffffc02026a4:	fcbfe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
    assert(base != NULL);
ffffffffc02026a8:	c159                	beqz	a0,ffffffffc020272e <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026aa:	0000f797          	auipc	a5,0xf
ffffffffc02026ae:	e0e78793          	addi	a5,a5,-498 # ffffffffc02114b8 <pages>
ffffffffc02026b2:	639c                	ld	a5,0(a5)
ffffffffc02026b4:	8d1d                	sub	a0,a0,a5
ffffffffc02026b6:	00002797          	auipc	a5,0x2
ffffffffc02026ba:	59278793          	addi	a5,a5,1426 # ffffffffc0204c48 <commands+0x858>
ffffffffc02026be:	6394                	ld	a3,0(a5)
ffffffffc02026c0:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026c2:	0000f797          	auipc	a5,0xf
ffffffffc02026c6:	da678793          	addi	a5,a5,-602 # ffffffffc0211468 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026ca:	02d50533          	mul	a0,a0,a3
ffffffffc02026ce:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026d2:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026d4:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026d6:	00c51793          	slli	a5,a0,0xc
ffffffffc02026da:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02026dc:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026de:	02e7fb63          	bgeu	a5,a4,ffffffffc0202714 <kmalloc+0x88>
ffffffffc02026e2:	0000f797          	auipc	a5,0xf
ffffffffc02026e6:	dc678793          	addi	a5,a5,-570 # ffffffffc02114a8 <va_pa_offset>
ffffffffc02026ea:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02026ec:	60a2                	ld	ra,8(sp)
ffffffffc02026ee:	953e                	add	a0,a0,a5
ffffffffc02026f0:	0141                	addi	sp,sp,16
ffffffffc02026f2:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026f4:	00003697          	auipc	a3,0x3
ffffffffc02026f8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205090 <default_pmm_manager+0x98>
ffffffffc02026fc:	00002617          	auipc	a2,0x2
ffffffffc0202700:	56460613          	addi	a2,a2,1380 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202704:	1f000593          	li	a1,496
ffffffffc0202708:	00003517          	auipc	a0,0x3
ffffffffc020270c:	96850513          	addi	a0,a0,-1688 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc0202710:	c61fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0202714:	86aa                	mv	a3,a0
ffffffffc0202716:	00003617          	auipc	a2,0x3
ffffffffc020271a:	93260613          	addi	a2,a2,-1742 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc020271e:	06a00593          	li	a1,106
ffffffffc0202722:	00003517          	auipc	a0,0x3
ffffffffc0202726:	9be50513          	addi	a0,a0,-1602 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc020272a:	c47fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(base != NULL);
ffffffffc020272e:	00003697          	auipc	a3,0x3
ffffffffc0202732:	98268693          	addi	a3,a3,-1662 # ffffffffc02050b0 <default_pmm_manager+0xb8>
ffffffffc0202736:	00002617          	auipc	a2,0x2
ffffffffc020273a:	52a60613          	addi	a2,a2,1322 # ffffffffc0204c60 <commands+0x870>
ffffffffc020273e:	1f300593          	li	a1,499
ffffffffc0202742:	00003517          	auipc	a0,0x3
ffffffffc0202746:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020274a:	c27fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020274e <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020274e:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202750:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202752:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202754:	fff58713          	addi	a4,a1,-1
ffffffffc0202758:	17f9                	addi	a5,a5,-2
ffffffffc020275a:	04e7eb63          	bltu	a5,a4,ffffffffc02027b0 <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020275e:	c941                	beqz	a0,ffffffffc02027ee <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202760:	6785                	lui	a5,0x1
ffffffffc0202762:	17fd                	addi	a5,a5,-1
ffffffffc0202764:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202766:	c02007b7          	lui	a5,0xc0200
ffffffffc020276a:	81b1                	srli	a1,a1,0xc
ffffffffc020276c:	06f56463          	bltu	a0,a5,ffffffffc02027d4 <kfree+0x86>
ffffffffc0202770:	0000f797          	auipc	a5,0xf
ffffffffc0202774:	d3878793          	addi	a5,a5,-712 # ffffffffc02114a8 <va_pa_offset>
ffffffffc0202778:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020277a:	0000f717          	auipc	a4,0xf
ffffffffc020277e:	cee70713          	addi	a4,a4,-786 # ffffffffc0211468 <npage>
ffffffffc0202782:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202784:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202788:	83b1                	srli	a5,a5,0xc
ffffffffc020278a:	04e7f363          	bgeu	a5,a4,ffffffffc02027d0 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020278e:	fff80537          	lui	a0,0xfff80
ffffffffc0202792:	97aa                	add	a5,a5,a0
ffffffffc0202794:	0000f697          	auipc	a3,0xf
ffffffffc0202798:	d2468693          	addi	a3,a3,-732 # ffffffffc02114b8 <pages>
ffffffffc020279c:	6288                	ld	a0,0(a3)
ffffffffc020279e:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027a2:	60a2                	ld	ra,8(sp)
ffffffffc02027a4:	97ba                	add	a5,a5,a4
ffffffffc02027a6:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027a8:	953e                	add	a0,a0,a5
}
ffffffffc02027aa:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027ac:	f4bfe06f          	j	ffffffffc02016f6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027b0:	00003697          	auipc	a3,0x3
ffffffffc02027b4:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205090 <default_pmm_manager+0x98>
ffffffffc02027b8:	00002617          	auipc	a2,0x2
ffffffffc02027bc:	4a860613          	addi	a2,a2,1192 # ffffffffc0204c60 <commands+0x870>
ffffffffc02027c0:	1f900593          	li	a1,505
ffffffffc02027c4:	00003517          	auipc	a0,0x3
ffffffffc02027c8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc02027cc:	ba5fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02027d0:	e83fe0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027d4:	86aa                	mv	a3,a0
ffffffffc02027d6:	00003617          	auipc	a2,0x3
ffffffffc02027da:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0205190 <default_pmm_manager+0x198>
ffffffffc02027de:	06c00593          	li	a1,108
ffffffffc02027e2:	00003517          	auipc	a0,0x3
ffffffffc02027e6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc02027ea:	b87fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(ptr != NULL);
ffffffffc02027ee:	00003697          	auipc	a3,0x3
ffffffffc02027f2:	89268693          	addi	a3,a3,-1902 # ffffffffc0205080 <default_pmm_manager+0x88>
ffffffffc02027f6:	00002617          	auipc	a2,0x2
ffffffffc02027fa:	46a60613          	addi	a2,a2,1130 # ffffffffc0204c60 <commands+0x870>
ffffffffc02027fe:	1fa00593          	li	a1,506
ffffffffc0202802:	00003517          	auipc	a0,0x3
ffffffffc0202806:	86e50513          	addi	a0,a0,-1938 # ffffffffc0205070 <default_pmm_manager+0x78>
ffffffffc020280a:	b67fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020280e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020280e:	7135                	addi	sp,sp,-160
ffffffffc0202810:	ed06                	sd	ra,152(sp)
ffffffffc0202812:	e922                	sd	s0,144(sp)
ffffffffc0202814:	e526                	sd	s1,136(sp)
ffffffffc0202816:	e14a                	sd	s2,128(sp)
ffffffffc0202818:	fcce                	sd	s3,120(sp)
ffffffffc020281a:	f8d2                	sd	s4,112(sp)
ffffffffc020281c:	f4d6                	sd	s5,104(sp)
ffffffffc020281e:	f0da                	sd	s6,96(sp)
ffffffffc0202820:	ecde                	sd	s7,88(sp)
ffffffffc0202822:	e8e2                	sd	s8,80(sp)
ffffffffc0202824:	e4e6                	sd	s9,72(sp)
ffffffffc0202826:	e0ea                	sd	s10,64(sp)
ffffffffc0202828:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020282a:	3a2010ef          	jal	ra,ffffffffc0203bcc <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020282e:	0000f797          	auipc	a5,0xf
ffffffffc0202832:	d1a78793          	addi	a5,a5,-742 # ffffffffc0211548 <max_swap_offset>
ffffffffc0202836:	6394                	ld	a3,0(a5)
ffffffffc0202838:	010007b7          	lui	a5,0x1000
ffffffffc020283c:	17e1                	addi	a5,a5,-8
ffffffffc020283e:	ff968713          	addi	a4,a3,-7
ffffffffc0202842:	42e7ea63          	bltu	a5,a4,ffffffffc0202c76 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202846:	00007797          	auipc	a5,0x7
ffffffffc020284a:	7ba78793          	addi	a5,a5,1978 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020284e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202850:	0000f697          	auipc	a3,0xf
ffffffffc0202854:	c2f6b023          	sd	a5,-992(a3) # ffffffffc0211470 <sm>
     int r = sm->init();
ffffffffc0202858:	9702                	jalr	a4
ffffffffc020285a:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020285c:	c10d                	beqz	a0,ffffffffc020287e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020285e:	60ea                	ld	ra,152(sp)
ffffffffc0202860:	644a                	ld	s0,144(sp)
ffffffffc0202862:	855a                	mv	a0,s6
ffffffffc0202864:	64aa                	ld	s1,136(sp)
ffffffffc0202866:	690a                	ld	s2,128(sp)
ffffffffc0202868:	79e6                	ld	s3,120(sp)
ffffffffc020286a:	7a46                	ld	s4,112(sp)
ffffffffc020286c:	7aa6                	ld	s5,104(sp)
ffffffffc020286e:	7b06                	ld	s6,96(sp)
ffffffffc0202870:	6be6                	ld	s7,88(sp)
ffffffffc0202872:	6c46                	ld	s8,80(sp)
ffffffffc0202874:	6ca6                	ld	s9,72(sp)
ffffffffc0202876:	6d06                	ld	s10,64(sp)
ffffffffc0202878:	7de2                	ld	s11,56(sp)
ffffffffc020287a:	610d                	addi	sp,sp,160
ffffffffc020287c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020287e:	0000f797          	auipc	a5,0xf
ffffffffc0202882:	bf278793          	addi	a5,a5,-1038 # ffffffffc0211470 <sm>
ffffffffc0202886:	639c                	ld	a5,0(a5)
ffffffffc0202888:	00003517          	auipc	a0,0x3
ffffffffc020288c:	e9050513          	addi	a0,a0,-368 # ffffffffc0205718 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc0202890:	0000f417          	auipc	s0,0xf
ffffffffc0202894:	bf840413          	addi	s0,s0,-1032 # ffffffffc0211488 <free_area>
ffffffffc0202898:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020289a:	4785                	li	a5,1
ffffffffc020289c:	0000f717          	auipc	a4,0xf
ffffffffc02028a0:	bcf72e23          	sw	a5,-1060(a4) # ffffffffc0211478 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028a4:	81bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028a8:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028aa:	2e878a63          	beq	a5,s0,ffffffffc0202b9e <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028ae:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028b2:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028b4:	8b05                	andi	a4,a4,1
ffffffffc02028b6:	2e070863          	beqz	a4,ffffffffc0202ba6 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028ba:	4481                	li	s1,0
ffffffffc02028bc:	4901                	li	s2,0
ffffffffc02028be:	a031                	j	ffffffffc02028ca <swap_init+0xbc>
ffffffffc02028c0:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028c4:	8b09                	andi	a4,a4,2
ffffffffc02028c6:	2e070063          	beqz	a4,ffffffffc0202ba6 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028ce:	679c                	ld	a5,8(a5)
ffffffffc02028d0:	2905                	addiw	s2,s2,1
ffffffffc02028d2:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028d4:	fe8796e3          	bne	a5,s0,ffffffffc02028c0 <swap_init+0xb2>
ffffffffc02028d8:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028da:	e63fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02028de:	5b351863          	bne	a0,s3,ffffffffc0202e8e <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02028e2:	8626                	mv	a2,s1
ffffffffc02028e4:	85ca                	mv	a1,s2
ffffffffc02028e6:	00003517          	auipc	a0,0x3
ffffffffc02028ea:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205730 <default_pmm_manager+0x738>
ffffffffc02028ee:	fd0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02028f2:	30d000ef          	jal	ra,ffffffffc02033fe <mm_create>
ffffffffc02028f6:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02028f8:	50050b63          	beqz	a0,ffffffffc0202e0e <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02028fc:	0000f797          	auipc	a5,0xf
ffffffffc0202900:	ca478793          	addi	a5,a5,-860 # ffffffffc02115a0 <check_mm_struct>
ffffffffc0202904:	639c                	ld	a5,0(a5)
ffffffffc0202906:	52079463          	bnez	a5,ffffffffc0202e2e <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020290a:	0000f797          	auipc	a5,0xf
ffffffffc020290e:	b5678793          	addi	a5,a5,-1194 # ffffffffc0211460 <boot_pgdir>
ffffffffc0202912:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202914:	0000f797          	auipc	a5,0xf
ffffffffc0202918:	c8a7b623          	sd	a0,-884(a5) # ffffffffc02115a0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020291c:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020291e:	ec3a                	sd	a4,24(sp)
ffffffffc0202920:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202922:	52079663          	bnez	a5,ffffffffc0202e4e <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202926:	6599                	lui	a1,0x6
ffffffffc0202928:	460d                	li	a2,3
ffffffffc020292a:	6505                	lui	a0,0x1
ffffffffc020292c:	31f000ef          	jal	ra,ffffffffc020344a <vma_create>
ffffffffc0202930:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202932:	52050e63          	beqz	a0,ffffffffc0202e6e <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202936:	855e                	mv	a0,s7
ffffffffc0202938:	37f000ef          	jal	ra,ffffffffc02034b6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020293c:	00003517          	auipc	a0,0x3
ffffffffc0202940:	e6450513          	addi	a0,a0,-412 # ffffffffc02057a0 <default_pmm_manager+0x7a8>
ffffffffc0202944:	f7afd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202948:	018bb503          	ld	a0,24(s7)
ffffffffc020294c:	4605                	li	a2,1
ffffffffc020294e:	6585                	lui	a1,0x1
ffffffffc0202950:	e2dfe0ef          	jal	ra,ffffffffc020177c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202954:	40050d63          	beqz	a0,ffffffffc0202d6e <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	e9850513          	addi	a0,a0,-360 # ffffffffc02057f0 <default_pmm_manager+0x7f8>
ffffffffc0202960:	0000fa17          	auipc	s4,0xf
ffffffffc0202964:	b60a0a13          	addi	s4,s4,-1184 # ffffffffc02114c0 <check_rp>
ffffffffc0202968:	f56fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020296c:	0000fa97          	auipc	s5,0xf
ffffffffc0202970:	b74a8a93          	addi	s5,s5,-1164 # ffffffffc02114e0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202974:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202976:	4505                	li	a0,1
ffffffffc0202978:	cf7fe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc020297c:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea58>
          assert(check_rp[i] != NULL );
ffffffffc0202980:	2a050b63          	beqz	a0,ffffffffc0202c36 <swap_init+0x428>
ffffffffc0202984:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202986:	8b89                	andi	a5,a5,2
ffffffffc0202988:	28079763          	bnez	a5,ffffffffc0202c16 <swap_init+0x408>
ffffffffc020298c:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020298e:	ff5994e3          	bne	s3,s5,ffffffffc0202976 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202992:	601c                	ld	a5,0(s0)
ffffffffc0202994:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202998:	0000fd17          	auipc	s10,0xf
ffffffffc020299c:	b28d0d13          	addi	s10,s10,-1240 # ffffffffc02114c0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029a0:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029a2:	481c                	lw	a5,16(s0)
ffffffffc02029a4:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029a6:	0000f797          	auipc	a5,0xf
ffffffffc02029aa:	ae87b523          	sd	s0,-1302(a5) # ffffffffc0211490 <free_area+0x8>
ffffffffc02029ae:	0000f797          	auipc	a5,0xf
ffffffffc02029b2:	ac87bd23          	sd	s0,-1318(a5) # ffffffffc0211488 <free_area>
     nr_free = 0;
ffffffffc02029b6:	0000f797          	auipc	a5,0xf
ffffffffc02029ba:	ae07a123          	sw	zero,-1310(a5) # ffffffffc0211498 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029be:	000d3503          	ld	a0,0(s10)
ffffffffc02029c2:	4585                	li	a1,1
ffffffffc02029c4:	0d21                	addi	s10,s10,8
ffffffffc02029c6:	d31fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029ca:	ff5d1ae3          	bne	s10,s5,ffffffffc02029be <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029ce:	01042d03          	lw	s10,16(s0)
ffffffffc02029d2:	4791                	li	a5,4
ffffffffc02029d4:	36fd1d63          	bne	s10,a5,ffffffffc0202d4e <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029d8:	00003517          	auipc	a0,0x3
ffffffffc02029dc:	ea050513          	addi	a0,a0,-352 # ffffffffc0205878 <default_pmm_manager+0x880>
ffffffffc02029e0:	edefd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029e4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02029e6:	0000f797          	auipc	a5,0xf
ffffffffc02029ea:	a807ab23          	sw	zero,-1386(a5) # ffffffffc021147c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029ee:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029f0:	0000f797          	auipc	a5,0xf
ffffffffc02029f4:	a8c78793          	addi	a5,a5,-1396 # ffffffffc021147c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029f8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02029fc:	4398                	lw	a4,0(a5)
ffffffffc02029fe:	4585                	li	a1,1
ffffffffc0202a00:	2701                	sext.w	a4,a4
ffffffffc0202a02:	30b71663          	bne	a4,a1,ffffffffc0202d0e <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a06:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a0a:	4394                	lw	a3,0(a5)
ffffffffc0202a0c:	2681                	sext.w	a3,a3
ffffffffc0202a0e:	32e69063          	bne	a3,a4,ffffffffc0202d2e <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a12:	6689                	lui	a3,0x2
ffffffffc0202a14:	462d                	li	a2,11
ffffffffc0202a16:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a1a:	4398                	lw	a4,0(a5)
ffffffffc0202a1c:	4589                	li	a1,2
ffffffffc0202a1e:	2701                	sext.w	a4,a4
ffffffffc0202a20:	26b71763          	bne	a4,a1,ffffffffc0202c8e <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a24:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a28:	4394                	lw	a3,0(a5)
ffffffffc0202a2a:	2681                	sext.w	a3,a3
ffffffffc0202a2c:	28e69163          	bne	a3,a4,ffffffffc0202cae <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a30:	668d                	lui	a3,0x3
ffffffffc0202a32:	4631                	li	a2,12
ffffffffc0202a34:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a38:	4398                	lw	a4,0(a5)
ffffffffc0202a3a:	458d                	li	a1,3
ffffffffc0202a3c:	2701                	sext.w	a4,a4
ffffffffc0202a3e:	28b71863          	bne	a4,a1,ffffffffc0202cce <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a42:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a46:	4394                	lw	a3,0(a5)
ffffffffc0202a48:	2681                	sext.w	a3,a3
ffffffffc0202a4a:	2ae69263          	bne	a3,a4,ffffffffc0202cee <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a4e:	6691                	lui	a3,0x4
ffffffffc0202a50:	4635                	li	a2,13
ffffffffc0202a52:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a56:	4398                	lw	a4,0(a5)
ffffffffc0202a58:	2701                	sext.w	a4,a4
ffffffffc0202a5a:	33a71a63          	bne	a4,s10,ffffffffc0202d8e <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a5e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a62:	439c                	lw	a5,0(a5)
ffffffffc0202a64:	2781                	sext.w	a5,a5
ffffffffc0202a66:	34e79463          	bne	a5,a4,ffffffffc0202dae <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a6a:	481c                	lw	a5,16(s0)
ffffffffc0202a6c:	36079163          	bnez	a5,ffffffffc0202dce <swap_init+0x5c0>
ffffffffc0202a70:	0000f797          	auipc	a5,0xf
ffffffffc0202a74:	a7078793          	addi	a5,a5,-1424 # ffffffffc02114e0 <swap_in_seq_no>
ffffffffc0202a78:	0000f717          	auipc	a4,0xf
ffffffffc0202a7c:	a9070713          	addi	a4,a4,-1392 # ffffffffc0211508 <swap_out_seq_no>
ffffffffc0202a80:	0000f617          	auipc	a2,0xf
ffffffffc0202a84:	a8860613          	addi	a2,a2,-1400 # ffffffffc0211508 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a88:	56fd                	li	a3,-1
ffffffffc0202a8a:	c394                	sw	a3,0(a5)
ffffffffc0202a8c:	c314                	sw	a3,0(a4)
ffffffffc0202a8e:	0791                	addi	a5,a5,4
ffffffffc0202a90:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202a92:	fec79ce3          	bne	a5,a2,ffffffffc0202a8a <swap_init+0x27c>
ffffffffc0202a96:	0000f697          	auipc	a3,0xf
ffffffffc0202a9a:	ad268693          	addi	a3,a3,-1326 # ffffffffc0211568 <check_ptep>
ffffffffc0202a9e:	0000f817          	auipc	a6,0xf
ffffffffc0202aa2:	a2280813          	addi	a6,a6,-1502 # ffffffffc02114c0 <check_rp>
ffffffffc0202aa6:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202aa8:	0000fc97          	auipc	s9,0xf
ffffffffc0202aac:	9c0c8c93          	addi	s9,s9,-1600 # ffffffffc0211468 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ab0:	0000fd97          	auipc	s11,0xf
ffffffffc0202ab4:	a08d8d93          	addi	s11,s11,-1528 # ffffffffc02114b8 <pages>
ffffffffc0202ab8:	00003d17          	auipc	s10,0x3
ffffffffc0202abc:	600d0d13          	addi	s10,s10,1536 # ffffffffc02060b8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ac0:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202ac2:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ac6:	4601                	li	a2,0
ffffffffc0202ac8:	85e2                	mv	a1,s8
ffffffffc0202aca:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202acc:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ace:	caffe0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0202ad2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ad4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ad6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202ad8:	16050f63          	beqz	a0,ffffffffc0202c56 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202adc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202ade:	0017f613          	andi	a2,a5,1
ffffffffc0202ae2:	10060263          	beqz	a2,ffffffffc0202be6 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202ae6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202aea:	078a                	slli	a5,a5,0x2
ffffffffc0202aec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aee:	10c7f863          	bgeu	a5,a2,ffffffffc0202bfe <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af2:	000d3603          	ld	a2,0(s10)
ffffffffc0202af6:	000db583          	ld	a1,0(s11)
ffffffffc0202afa:	00083503          	ld	a0,0(a6)
ffffffffc0202afe:	8f91                	sub	a5,a5,a2
ffffffffc0202b00:	00379613          	slli	a2,a5,0x3
ffffffffc0202b04:	97b2                	add	a5,a5,a2
ffffffffc0202b06:	078e                	slli	a5,a5,0x3
ffffffffc0202b08:	97ae                	add	a5,a5,a1
ffffffffc0202b0a:	0af51e63          	bne	a0,a5,ffffffffc0202bc6 <swap_init+0x3b8>
ffffffffc0202b0e:	6785                	lui	a5,0x1
ffffffffc0202b10:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b12:	6795                	lui	a5,0x5
ffffffffc0202b14:	06a1                	addi	a3,a3,8
ffffffffc0202b16:	0821                	addi	a6,a6,8
ffffffffc0202b18:	fafc14e3          	bne	s8,a5,ffffffffc0202ac0 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b1c:	00003517          	auipc	a0,0x3
ffffffffc0202b20:	e0450513          	addi	a0,a0,-508 # ffffffffc0205920 <default_pmm_manager+0x928>
ffffffffc0202b24:	d9afd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b28:	0000f797          	auipc	a5,0xf
ffffffffc0202b2c:	94878793          	addi	a5,a5,-1720 # ffffffffc0211470 <sm>
ffffffffc0202b30:	639c                	ld	a5,0(a5)
ffffffffc0202b32:	7f9c                	ld	a5,56(a5)
ffffffffc0202b34:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b36:	2a051c63          	bnez	a0,ffffffffc0202dee <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b3a:	000a3503          	ld	a0,0(s4)
ffffffffc0202b3e:	4585                	li	a1,1
ffffffffc0202b40:	0a21                	addi	s4,s4,8
ffffffffc0202b42:	bb5fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b46:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b3a <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b4a:	855e                	mv	a0,s7
ffffffffc0202b4c:	239000ef          	jal	ra,ffffffffc0203584 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b50:	77a2                	ld	a5,40(sp)
ffffffffc0202b52:	0000f717          	auipc	a4,0xf
ffffffffc0202b56:	94f72323          	sw	a5,-1722(a4) # ffffffffc0211498 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b5a:	7782                	ld	a5,32(sp)
ffffffffc0202b5c:	0000f717          	auipc	a4,0xf
ffffffffc0202b60:	92f73623          	sd	a5,-1748(a4) # ffffffffc0211488 <free_area>
ffffffffc0202b64:	0000f797          	auipc	a5,0xf
ffffffffc0202b68:	9337b623          	sd	s3,-1748(a5) # ffffffffc0211490 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b6c:	00898a63          	beq	s3,s0,ffffffffc0202b80 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b70:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b74:	0089b983          	ld	s3,8(s3)
ffffffffc0202b78:	397d                	addiw	s2,s2,-1
ffffffffc0202b7a:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b7c:	fe899ae3          	bne	s3,s0,ffffffffc0202b70 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b80:	8626                	mv	a2,s1
ffffffffc0202b82:	85ca                	mv	a1,s2
ffffffffc0202b84:	00003517          	auipc	a0,0x3
ffffffffc0202b88:	dcc50513          	addi	a0,a0,-564 # ffffffffc0205950 <default_pmm_manager+0x958>
ffffffffc0202b8c:	d32fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b90:	00003517          	auipc	a0,0x3
ffffffffc0202b94:	de050513          	addi	a0,a0,-544 # ffffffffc0205970 <default_pmm_manager+0x978>
ffffffffc0202b98:	d26fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202b9c:	b1c9                	j	ffffffffc020285e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202b9e:	4481                	li	s1,0
ffffffffc0202ba0:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ba2:	4981                	li	s3,0
ffffffffc0202ba4:	bb1d                	j	ffffffffc02028da <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202ba6:	00002697          	auipc	a3,0x2
ffffffffc0202baa:	0aa68693          	addi	a3,a3,170 # ffffffffc0204c50 <commands+0x860>
ffffffffc0202bae:	00002617          	auipc	a2,0x2
ffffffffc0202bb2:	0b260613          	addi	a2,a2,178 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202bb6:	0ba00593          	li	a1,186
ffffffffc0202bba:	00003517          	auipc	a0,0x3
ffffffffc0202bbe:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202bc2:	faefd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bc6:	00003697          	auipc	a3,0x3
ffffffffc0202bca:	d3268693          	addi	a3,a3,-718 # ffffffffc02058f8 <default_pmm_manager+0x900>
ffffffffc0202bce:	00002617          	auipc	a2,0x2
ffffffffc0202bd2:	09260613          	addi	a2,a2,146 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202bd6:	0fa00593          	li	a1,250
ffffffffc0202bda:	00003517          	auipc	a0,0x3
ffffffffc0202bde:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202be2:	f8efd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202be6:	00002617          	auipc	a2,0x2
ffffffffc0202bea:	6d260613          	addi	a2,a2,1746 # ffffffffc02052b8 <default_pmm_manager+0x2c0>
ffffffffc0202bee:	07000593          	li	a1,112
ffffffffc0202bf2:	00002517          	auipc	a0,0x2
ffffffffc0202bf6:	4ee50513          	addi	a0,a0,1262 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0202bfa:	f76fd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bfe:	00002617          	auipc	a2,0x2
ffffffffc0202c02:	4c260613          	addi	a2,a2,1218 # ffffffffc02050c0 <default_pmm_manager+0xc8>
ffffffffc0202c06:	06500593          	li	a1,101
ffffffffc0202c0a:	00002517          	auipc	a0,0x2
ffffffffc0202c0e:	4d650513          	addi	a0,a0,1238 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0202c12:	f5efd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c16:	00003697          	auipc	a3,0x3
ffffffffc0202c1a:	c1a68693          	addi	a3,a3,-998 # ffffffffc0205830 <default_pmm_manager+0x838>
ffffffffc0202c1e:	00002617          	auipc	a2,0x2
ffffffffc0202c22:	04260613          	addi	a2,a2,66 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202c26:	0db00593          	li	a1,219
ffffffffc0202c2a:	00003517          	auipc	a0,0x3
ffffffffc0202c2e:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202c32:	f3efd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c36:	00003697          	auipc	a3,0x3
ffffffffc0202c3a:	be268693          	addi	a3,a3,-1054 # ffffffffc0205818 <default_pmm_manager+0x820>
ffffffffc0202c3e:	00002617          	auipc	a2,0x2
ffffffffc0202c42:	02260613          	addi	a2,a2,34 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202c46:	0da00593          	li	a1,218
ffffffffc0202c4a:	00003517          	auipc	a0,0x3
ffffffffc0202c4e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202c52:	f1efd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c56:	00003697          	auipc	a3,0x3
ffffffffc0202c5a:	c8a68693          	addi	a3,a3,-886 # ffffffffc02058e0 <default_pmm_manager+0x8e8>
ffffffffc0202c5e:	00002617          	auipc	a2,0x2
ffffffffc0202c62:	00260613          	addi	a2,a2,2 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202c66:	0f900593          	li	a1,249
ffffffffc0202c6a:	00003517          	auipc	a0,0x3
ffffffffc0202c6e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202c72:	efefd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c76:	00003617          	auipc	a2,0x3
ffffffffc0202c7a:	a7260613          	addi	a2,a2,-1422 # ffffffffc02056e8 <default_pmm_manager+0x6f0>
ffffffffc0202c7e:	02700593          	li	a1,39
ffffffffc0202c82:	00003517          	auipc	a0,0x3
ffffffffc0202c86:	a8650513          	addi	a0,a0,-1402 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202c8a:	ee6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c8e:	00003697          	auipc	a3,0x3
ffffffffc0202c92:	c2268693          	addi	a3,a3,-990 # ffffffffc02058b0 <default_pmm_manager+0x8b8>
ffffffffc0202c96:	00002617          	auipc	a2,0x2
ffffffffc0202c9a:	fca60613          	addi	a2,a2,-54 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202c9e:	09500593          	li	a1,149
ffffffffc0202ca2:	00003517          	auipc	a0,0x3
ffffffffc0202ca6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202caa:	ec6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cae:	00003697          	auipc	a3,0x3
ffffffffc0202cb2:	c0268693          	addi	a3,a3,-1022 # ffffffffc02058b0 <default_pmm_manager+0x8b8>
ffffffffc0202cb6:	00002617          	auipc	a2,0x2
ffffffffc0202cba:	faa60613          	addi	a2,a2,-86 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202cbe:	09700593          	li	a1,151
ffffffffc0202cc2:	00003517          	auipc	a0,0x3
ffffffffc0202cc6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202cca:	ea6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cce:	00003697          	auipc	a3,0x3
ffffffffc0202cd2:	bf268693          	addi	a3,a3,-1038 # ffffffffc02058c0 <default_pmm_manager+0x8c8>
ffffffffc0202cd6:	00002617          	auipc	a2,0x2
ffffffffc0202cda:	f8a60613          	addi	a2,a2,-118 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202cde:	09900593          	li	a1,153
ffffffffc0202ce2:	00003517          	auipc	a0,0x3
ffffffffc0202ce6:	a2650513          	addi	a0,a0,-1498 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202cea:	e86fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cee:	00003697          	auipc	a3,0x3
ffffffffc0202cf2:	bd268693          	addi	a3,a3,-1070 # ffffffffc02058c0 <default_pmm_manager+0x8c8>
ffffffffc0202cf6:	00002617          	auipc	a2,0x2
ffffffffc0202cfa:	f6a60613          	addi	a2,a2,-150 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202cfe:	09b00593          	li	a1,155
ffffffffc0202d02:	00003517          	auipc	a0,0x3
ffffffffc0202d06:	a0650513          	addi	a0,a0,-1530 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202d0a:	e66fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d0e:	00003697          	auipc	a3,0x3
ffffffffc0202d12:	b9268693          	addi	a3,a3,-1134 # ffffffffc02058a0 <default_pmm_manager+0x8a8>
ffffffffc0202d16:	00002617          	auipc	a2,0x2
ffffffffc0202d1a:	f4a60613          	addi	a2,a2,-182 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202d1e:	09100593          	li	a1,145
ffffffffc0202d22:	00003517          	auipc	a0,0x3
ffffffffc0202d26:	9e650513          	addi	a0,a0,-1562 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202d2a:	e46fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d2e:	00003697          	auipc	a3,0x3
ffffffffc0202d32:	b7268693          	addi	a3,a3,-1166 # ffffffffc02058a0 <default_pmm_manager+0x8a8>
ffffffffc0202d36:	00002617          	auipc	a2,0x2
ffffffffc0202d3a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202d3e:	09300593          	li	a1,147
ffffffffc0202d42:	00003517          	auipc	a0,0x3
ffffffffc0202d46:	9c650513          	addi	a0,a0,-1594 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202d4a:	e26fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d4e:	00003697          	auipc	a3,0x3
ffffffffc0202d52:	b0268693          	addi	a3,a3,-1278 # ffffffffc0205850 <default_pmm_manager+0x858>
ffffffffc0202d56:	00002617          	auipc	a2,0x2
ffffffffc0202d5a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202d5e:	0e800593          	li	a1,232
ffffffffc0202d62:	00003517          	auipc	a0,0x3
ffffffffc0202d66:	9a650513          	addi	a0,a0,-1626 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202d6a:	e06fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d6e:	00003697          	auipc	a3,0x3
ffffffffc0202d72:	a6a68693          	addi	a3,a3,-1430 # ffffffffc02057d8 <default_pmm_manager+0x7e0>
ffffffffc0202d76:	00002617          	auipc	a2,0x2
ffffffffc0202d7a:	eea60613          	addi	a2,a2,-278 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202d7e:	0d500593          	li	a1,213
ffffffffc0202d82:	00003517          	auipc	a0,0x3
ffffffffc0202d86:	98650513          	addi	a0,a0,-1658 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202d8a:	de6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d8e:	00003697          	auipc	a3,0x3
ffffffffc0202d92:	b4268693          	addi	a3,a3,-1214 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc0202d96:	00002617          	auipc	a2,0x2
ffffffffc0202d9a:	eca60613          	addi	a2,a2,-310 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202d9e:	09d00593          	li	a1,157
ffffffffc0202da2:	00003517          	auipc	a0,0x3
ffffffffc0202da6:	96650513          	addi	a0,a0,-1690 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202daa:	dc6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dae:	00003697          	auipc	a3,0x3
ffffffffc0202db2:	b2268693          	addi	a3,a3,-1246 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc0202db6:	00002617          	auipc	a2,0x2
ffffffffc0202dba:	eaa60613          	addi	a2,a2,-342 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202dbe:	09f00593          	li	a1,159
ffffffffc0202dc2:	00003517          	auipc	a0,0x3
ffffffffc0202dc6:	94650513          	addi	a0,a0,-1722 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202dca:	da6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dce:	00002697          	auipc	a3,0x2
ffffffffc0202dd2:	06a68693          	addi	a3,a3,106 # ffffffffc0204e38 <commands+0xa48>
ffffffffc0202dd6:	00002617          	auipc	a2,0x2
ffffffffc0202dda:	e8a60613          	addi	a2,a2,-374 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202dde:	0f100593          	li	a1,241
ffffffffc0202de2:	00003517          	auipc	a0,0x3
ffffffffc0202de6:	92650513          	addi	a0,a0,-1754 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202dea:	d86fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(ret==0);
ffffffffc0202dee:	00003697          	auipc	a3,0x3
ffffffffc0202df2:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0205948 <default_pmm_manager+0x950>
ffffffffc0202df6:	00002617          	auipc	a2,0x2
ffffffffc0202dfa:	e6a60613          	addi	a2,a2,-406 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202dfe:	10000593          	li	a1,256
ffffffffc0202e02:	00003517          	auipc	a0,0x3
ffffffffc0202e06:	90650513          	addi	a0,a0,-1786 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202e0a:	d66fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(mm != NULL);
ffffffffc0202e0e:	00003697          	auipc	a3,0x3
ffffffffc0202e12:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205758 <default_pmm_manager+0x760>
ffffffffc0202e16:	00002617          	auipc	a2,0x2
ffffffffc0202e1a:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202e1e:	0c200593          	li	a1,194
ffffffffc0202e22:	00003517          	auipc	a0,0x3
ffffffffc0202e26:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202e2a:	d46fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e2e:	00003697          	auipc	a3,0x3
ffffffffc0202e32:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205768 <default_pmm_manager+0x770>
ffffffffc0202e36:	00002617          	auipc	a2,0x2
ffffffffc0202e3a:	e2a60613          	addi	a2,a2,-470 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202e3e:	0c500593          	li	a1,197
ffffffffc0202e42:	00003517          	auipc	a0,0x3
ffffffffc0202e46:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202e4a:	d26fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e4e:	00003697          	auipc	a3,0x3
ffffffffc0202e52:	93268693          	addi	a3,a3,-1742 # ffffffffc0205780 <default_pmm_manager+0x788>
ffffffffc0202e56:	00002617          	auipc	a2,0x2
ffffffffc0202e5a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202e5e:	0ca00593          	li	a1,202
ffffffffc0202e62:	00003517          	auipc	a0,0x3
ffffffffc0202e66:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202e6a:	d06fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(vma != NULL);
ffffffffc0202e6e:	00003697          	auipc	a3,0x3
ffffffffc0202e72:	92268693          	addi	a3,a3,-1758 # ffffffffc0205790 <default_pmm_manager+0x798>
ffffffffc0202e76:	00002617          	auipc	a2,0x2
ffffffffc0202e7a:	dea60613          	addi	a2,a2,-534 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202e7e:	0cd00593          	li	a1,205
ffffffffc0202e82:	00003517          	auipc	a0,0x3
ffffffffc0202e86:	88650513          	addi	a0,a0,-1914 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202e8a:	ce6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e8e:	00002697          	auipc	a3,0x2
ffffffffc0202e92:	e0268693          	addi	a3,a3,-510 # ffffffffc0204c90 <commands+0x8a0>
ffffffffc0202e96:	00002617          	auipc	a2,0x2
ffffffffc0202e9a:	dca60613          	addi	a2,a2,-566 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202e9e:	0bd00593          	li	a1,189
ffffffffc0202ea2:	00003517          	auipc	a0,0x3
ffffffffc0202ea6:	86650513          	addi	a0,a0,-1946 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202eaa:	cc6fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202eae <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202eae:	0000e797          	auipc	a5,0xe
ffffffffc0202eb2:	5c278793          	addi	a5,a5,1474 # ffffffffc0211470 <sm>
ffffffffc0202eb6:	639c                	ld	a5,0(a5)
ffffffffc0202eb8:	0107b303          	ld	t1,16(a5)
ffffffffc0202ebc:	8302                	jr	t1

ffffffffc0202ebe <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ebe:	0000e797          	auipc	a5,0xe
ffffffffc0202ec2:	5b278793          	addi	a5,a5,1458 # ffffffffc0211470 <sm>
ffffffffc0202ec6:	639c                	ld	a5,0(a5)
ffffffffc0202ec8:	0207b303          	ld	t1,32(a5)
ffffffffc0202ecc:	8302                	jr	t1

ffffffffc0202ece <swap_out>:
{
ffffffffc0202ece:	711d                	addi	sp,sp,-96
ffffffffc0202ed0:	ec86                	sd	ra,88(sp)
ffffffffc0202ed2:	e8a2                	sd	s0,80(sp)
ffffffffc0202ed4:	e4a6                	sd	s1,72(sp)
ffffffffc0202ed6:	e0ca                	sd	s2,64(sp)
ffffffffc0202ed8:	fc4e                	sd	s3,56(sp)
ffffffffc0202eda:	f852                	sd	s4,48(sp)
ffffffffc0202edc:	f456                	sd	s5,40(sp)
ffffffffc0202ede:	f05a                	sd	s6,32(sp)
ffffffffc0202ee0:	ec5e                	sd	s7,24(sp)
ffffffffc0202ee2:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202ee4:	cde9                	beqz	a1,ffffffffc0202fbe <swap_out+0xf0>
ffffffffc0202ee6:	8ab2                	mv	s5,a2
ffffffffc0202ee8:	892a                	mv	s2,a0
ffffffffc0202eea:	8a2e                	mv	s4,a1
ffffffffc0202eec:	4401                	li	s0,0
ffffffffc0202eee:	0000e997          	auipc	s3,0xe
ffffffffc0202ef2:	58298993          	addi	s3,s3,1410 # ffffffffc0211470 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ef6:	00003b17          	auipc	s6,0x3
ffffffffc0202efa:	afab0b13          	addi	s6,s6,-1286 # ffffffffc02059f0 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202efe:	00003b97          	auipc	s7,0x3
ffffffffc0202f02:	adab8b93          	addi	s7,s7,-1318 # ffffffffc02059d8 <default_pmm_manager+0x9e0>
ffffffffc0202f06:	a825                	j	ffffffffc0202f3e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f08:	67a2                	ld	a5,8(sp)
ffffffffc0202f0a:	8626                	mv	a2,s1
ffffffffc0202f0c:	85a2                	mv	a1,s0
ffffffffc0202f0e:	63b4                	ld	a3,64(a5)
ffffffffc0202f10:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f12:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f14:	82b1                	srli	a3,a3,0xc
ffffffffc0202f16:	0685                	addi	a3,a3,1
ffffffffc0202f18:	9a6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f1c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f1e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f20:	613c                	ld	a5,64(a0)
ffffffffc0202f22:	83b1                	srli	a5,a5,0xc
ffffffffc0202f24:	0785                	addi	a5,a5,1
ffffffffc0202f26:	07a2                	slli	a5,a5,0x8
ffffffffc0202f28:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f2c:	fcafe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f30:	01893503          	ld	a0,24(s2)
ffffffffc0202f34:	85a6                	mv	a1,s1
ffffffffc0202f36:	ebeff0ef          	jal	ra,ffffffffc02025f4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f3a:	048a0d63          	beq	s4,s0,ffffffffc0202f94 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f3e:	0009b783          	ld	a5,0(s3)
ffffffffc0202f42:	8656                	mv	a2,s5
ffffffffc0202f44:	002c                	addi	a1,sp,8
ffffffffc0202f46:	7b9c                	ld	a5,48(a5)
ffffffffc0202f48:	854a                	mv	a0,s2
ffffffffc0202f4a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f4c:	e12d                	bnez	a0,ffffffffc0202fae <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f4e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f50:	01893503          	ld	a0,24(s2)
ffffffffc0202f54:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f56:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f58:	85a6                	mv	a1,s1
ffffffffc0202f5a:	823fe0ef          	jal	ra,ffffffffc020177c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f5e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f60:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f62:	8b85                	andi	a5,a5,1
ffffffffc0202f64:	cfb9                	beqz	a5,ffffffffc0202fc2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f66:	65a2                	ld	a1,8(sp)
ffffffffc0202f68:	61bc                	ld	a5,64(a1)
ffffffffc0202f6a:	83b1                	srli	a5,a5,0xc
ffffffffc0202f6c:	00178513          	addi	a0,a5,1
ffffffffc0202f70:	0522                	slli	a0,a0,0x8
ffffffffc0202f72:	539000ef          	jal	ra,ffffffffc0203caa <swapfs_write>
ffffffffc0202f76:	d949                	beqz	a0,ffffffffc0202f08 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f78:	855e                	mv	a0,s7
ffffffffc0202f7a:	944fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f7e:	0009b783          	ld	a5,0(s3)
ffffffffc0202f82:	6622                	ld	a2,8(sp)
ffffffffc0202f84:	4681                	li	a3,0
ffffffffc0202f86:	739c                	ld	a5,32(a5)
ffffffffc0202f88:	85a6                	mv	a1,s1
ffffffffc0202f8a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202f8c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f8e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202f90:	fa8a17e3          	bne	s4,s0,ffffffffc0202f3e <swap_out+0x70>
}
ffffffffc0202f94:	8522                	mv	a0,s0
ffffffffc0202f96:	60e6                	ld	ra,88(sp)
ffffffffc0202f98:	6446                	ld	s0,80(sp)
ffffffffc0202f9a:	64a6                	ld	s1,72(sp)
ffffffffc0202f9c:	6906                	ld	s2,64(sp)
ffffffffc0202f9e:	79e2                	ld	s3,56(sp)
ffffffffc0202fa0:	7a42                	ld	s4,48(sp)
ffffffffc0202fa2:	7aa2                	ld	s5,40(sp)
ffffffffc0202fa4:	7b02                	ld	s6,32(sp)
ffffffffc0202fa6:	6be2                	ld	s7,24(sp)
ffffffffc0202fa8:	6c42                	ld	s8,16(sp)
ffffffffc0202faa:	6125                	addi	sp,sp,96
ffffffffc0202fac:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fae:	85a2                	mv	a1,s0
ffffffffc0202fb0:	00003517          	auipc	a0,0x3
ffffffffc0202fb4:	9e050513          	addi	a0,a0,-1568 # ffffffffc0205990 <default_pmm_manager+0x998>
ffffffffc0202fb8:	906fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202fbc:	bfe1                	j	ffffffffc0202f94 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202fbe:	4401                	li	s0,0
ffffffffc0202fc0:	bfd1                	j	ffffffffc0202f94 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fc2:	00003697          	auipc	a3,0x3
ffffffffc0202fc6:	9fe68693          	addi	a3,a3,-1538 # ffffffffc02059c0 <default_pmm_manager+0x9c8>
ffffffffc0202fca:	00002617          	auipc	a2,0x2
ffffffffc0202fce:	c9660613          	addi	a2,a2,-874 # ffffffffc0204c60 <commands+0x870>
ffffffffc0202fd2:	06600593          	li	a1,102
ffffffffc0202fd6:	00002517          	auipc	a0,0x2
ffffffffc0202fda:	73250513          	addi	a0,a0,1842 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0202fde:	b92fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202fe2 <swap_in>:
{
ffffffffc0202fe2:	7179                	addi	sp,sp,-48
ffffffffc0202fe4:	e84a                	sd	s2,16(sp)
ffffffffc0202fe6:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202fe8:	4505                	li	a0,1
{
ffffffffc0202fea:	ec26                	sd	s1,24(sp)
ffffffffc0202fec:	e44e                	sd	s3,8(sp)
ffffffffc0202fee:	f406                	sd	ra,40(sp)
ffffffffc0202ff0:	f022                	sd	s0,32(sp)
ffffffffc0202ff2:	84ae                	mv	s1,a1
ffffffffc0202ff4:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202ff6:	e78fe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
     assert(result!=NULL);
ffffffffc0202ffa:	c129                	beqz	a0,ffffffffc020303c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202ffc:	842a                	mv	s0,a0
ffffffffc0202ffe:	01893503          	ld	a0,24(s2)
ffffffffc0203002:	4601                	li	a2,0
ffffffffc0203004:	85a6                	mv	a1,s1
ffffffffc0203006:	f76fe0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc020300a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020300c:	6108                	ld	a0,0(a0)
ffffffffc020300e:	85a2                	mv	a1,s0
ffffffffc0203010:	3f5000ef          	jal	ra,ffffffffc0203c04 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203014:	00093583          	ld	a1,0(s2)
ffffffffc0203018:	8626                	mv	a2,s1
ffffffffc020301a:	00002517          	auipc	a0,0x2
ffffffffc020301e:	68e50513          	addi	a0,a0,1678 # ffffffffc02056a8 <default_pmm_manager+0x6b0>
ffffffffc0203022:	81a1                	srli	a1,a1,0x8
ffffffffc0203024:	89afd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203028:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020302a:	0089b023          	sd	s0,0(s3)
}
ffffffffc020302e:	7402                	ld	s0,32(sp)
ffffffffc0203030:	64e2                	ld	s1,24(sp)
ffffffffc0203032:	6942                	ld	s2,16(sp)
ffffffffc0203034:	69a2                	ld	s3,8(sp)
ffffffffc0203036:	4501                	li	a0,0
ffffffffc0203038:	6145                	addi	sp,sp,48
ffffffffc020303a:	8082                	ret
     assert(result!=NULL);
ffffffffc020303c:	00002697          	auipc	a3,0x2
ffffffffc0203040:	65c68693          	addi	a3,a3,1628 # ffffffffc0205698 <default_pmm_manager+0x6a0>
ffffffffc0203044:	00002617          	auipc	a2,0x2
ffffffffc0203048:	c1c60613          	addi	a2,a2,-996 # ffffffffc0204c60 <commands+0x870>
ffffffffc020304c:	07c00593          	li	a1,124
ffffffffc0203050:	00002517          	auipc	a0,0x2
ffffffffc0203054:	6b850513          	addi	a0,a0,1720 # ffffffffc0205708 <default_pmm_manager+0x710>
ffffffffc0203058:	b18fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020305c <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020305c:	0000e797          	auipc	a5,0xe
ffffffffc0203060:	52c78793          	addi	a5,a5,1324 # ffffffffc0211588 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc0203064:	f51c                	sd	a5,40(a0)
ffffffffc0203066:	e79c                	sd	a5,8(a5)
ffffffffc0203068:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc020306a:	0000e717          	auipc	a4,0xe
ffffffffc020306e:	52f73723          	sd	a5,1326(a4) # ffffffffc0211598 <curr_ptr>
     return 0;
}
ffffffffc0203072:	4501                	li	a0,0
ffffffffc0203074:	8082                	ret

ffffffffc0203076 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203076:	4501                	li	a0,0
ffffffffc0203078:	8082                	ret

ffffffffc020307a <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020307a:	4501                	li	a0,0
ffffffffc020307c:	8082                	ret

ffffffffc020307e <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020307e:	4501                	li	a0,0
ffffffffc0203080:	8082                	ret

ffffffffc0203082 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203082:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203084:	678d                	lui	a5,0x3
ffffffffc0203086:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203088:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020308a:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc020308e:	0000e797          	auipc	a5,0xe
ffffffffc0203092:	3ee78793          	addi	a5,a5,1006 # ffffffffc021147c <pgfault_num>
ffffffffc0203096:	4398                	lw	a4,0(a5)
ffffffffc0203098:	4691                	li	a3,4
ffffffffc020309a:	2701                	sext.w	a4,a4
ffffffffc020309c:	08d71f63          	bne	a4,a3,ffffffffc020313a <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030a0:	6685                	lui	a3,0x1
ffffffffc02030a2:	4629                	li	a2,10
ffffffffc02030a4:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030a8:	4394                	lw	a3,0(a5)
ffffffffc02030aa:	2681                	sext.w	a3,a3
ffffffffc02030ac:	20e69763          	bne	a3,a4,ffffffffc02032ba <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030b0:	6711                	lui	a4,0x4
ffffffffc02030b2:	4635                	li	a2,13
ffffffffc02030b4:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030b8:	4398                	lw	a4,0(a5)
ffffffffc02030ba:	2701                	sext.w	a4,a4
ffffffffc02030bc:	1cd71f63          	bne	a4,a3,ffffffffc020329a <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030c0:	6689                	lui	a3,0x2
ffffffffc02030c2:	462d                	li	a2,11
ffffffffc02030c4:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030c8:	4394                	lw	a3,0(a5)
ffffffffc02030ca:	2681                	sext.w	a3,a3
ffffffffc02030cc:	1ae69763          	bne	a3,a4,ffffffffc020327a <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030d0:	6715                	lui	a4,0x5
ffffffffc02030d2:	46b9                	li	a3,14
ffffffffc02030d4:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030d8:	4398                	lw	a4,0(a5)
ffffffffc02030da:	4695                	li	a3,5
ffffffffc02030dc:	2701                	sext.w	a4,a4
ffffffffc02030de:	16d71e63          	bne	a4,a3,ffffffffc020325a <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc02030e2:	4394                	lw	a3,0(a5)
ffffffffc02030e4:	2681                	sext.w	a3,a3
ffffffffc02030e6:	14e69a63          	bne	a3,a4,ffffffffc020323a <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc02030ea:	4398                	lw	a4,0(a5)
ffffffffc02030ec:	2701                	sext.w	a4,a4
ffffffffc02030ee:	12d71663          	bne	a4,a3,ffffffffc020321a <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc02030f2:	4394                	lw	a3,0(a5)
ffffffffc02030f4:	2681                	sext.w	a3,a3
ffffffffc02030f6:	10e69263          	bne	a3,a4,ffffffffc02031fa <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc02030fa:	4398                	lw	a4,0(a5)
ffffffffc02030fc:	2701                	sext.w	a4,a4
ffffffffc02030fe:	0cd71e63          	bne	a4,a3,ffffffffc02031da <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203102:	4394                	lw	a3,0(a5)
ffffffffc0203104:	2681                	sext.w	a3,a3
ffffffffc0203106:	0ae69a63          	bne	a3,a4,ffffffffc02031ba <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020310a:	6715                	lui	a4,0x5
ffffffffc020310c:	46b9                	li	a3,14
ffffffffc020310e:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203112:	4398                	lw	a4,0(a5)
ffffffffc0203114:	4695                	li	a3,5
ffffffffc0203116:	2701                	sext.w	a4,a4
ffffffffc0203118:	08d71163          	bne	a4,a3,ffffffffc020319a <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020311c:	6705                	lui	a4,0x1
ffffffffc020311e:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203122:	4729                	li	a4,10
ffffffffc0203124:	04e69b63          	bne	a3,a4,ffffffffc020317a <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203128:	439c                	lw	a5,0(a5)
ffffffffc020312a:	4719                	li	a4,6
ffffffffc020312c:	2781                	sext.w	a5,a5
ffffffffc020312e:	02e79663          	bne	a5,a4,ffffffffc020315a <_clock_check_swap+0xd8>
}
ffffffffc0203132:	60a2                	ld	ra,8(sp)
ffffffffc0203134:	4501                	li	a0,0
ffffffffc0203136:	0141                	addi	sp,sp,16
ffffffffc0203138:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020313a:	00002697          	auipc	a3,0x2
ffffffffc020313e:	79668693          	addi	a3,a3,1942 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204c60 <commands+0x870>
ffffffffc020314a:	08d00593          	li	a1,141
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	8e250513          	addi	a0,a0,-1822 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203156:	a1afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==6);
ffffffffc020315a:	00003697          	auipc	a3,0x3
ffffffffc020315e:	92668693          	addi	a3,a3,-1754 # ffffffffc0205a80 <default_pmm_manager+0xa88>
ffffffffc0203162:	00002617          	auipc	a2,0x2
ffffffffc0203166:	afe60613          	addi	a2,a2,-1282 # ffffffffc0204c60 <commands+0x870>
ffffffffc020316a:	0a400593          	li	a1,164
ffffffffc020316e:	00003517          	auipc	a0,0x3
ffffffffc0203172:	8c250513          	addi	a0,a0,-1854 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203176:	9fafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020317a:	00003697          	auipc	a3,0x3
ffffffffc020317e:	8de68693          	addi	a3,a3,-1826 # ffffffffc0205a58 <default_pmm_manager+0xa60>
ffffffffc0203182:	00002617          	auipc	a2,0x2
ffffffffc0203186:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204c60 <commands+0x870>
ffffffffc020318a:	0a200593          	li	a1,162
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203196:	9dafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc020319a:	00003697          	auipc	a3,0x3
ffffffffc020319e:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc02031a2:	00002617          	auipc	a2,0x2
ffffffffc02031a6:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204c60 <commands+0x870>
ffffffffc02031aa:	0a100593          	li	a1,161
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	88250513          	addi	a0,a0,-1918 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02031b6:	9bafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02031ba:	00003697          	auipc	a3,0x3
ffffffffc02031be:	88e68693          	addi	a3,a3,-1906 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc02031c2:	00002617          	auipc	a2,0x2
ffffffffc02031c6:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204c60 <commands+0x870>
ffffffffc02031ca:	09f00593          	li	a1,159
ffffffffc02031ce:	00003517          	auipc	a0,0x3
ffffffffc02031d2:	86250513          	addi	a0,a0,-1950 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02031d6:	99afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02031da:	00003697          	auipc	a3,0x3
ffffffffc02031de:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc02031e2:	00002617          	auipc	a2,0x2
ffffffffc02031e6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204c60 <commands+0x870>
ffffffffc02031ea:	09d00593          	li	a1,157
ffffffffc02031ee:	00003517          	auipc	a0,0x3
ffffffffc02031f2:	84250513          	addi	a0,a0,-1982 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02031f6:	97afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02031fa:	00003697          	auipc	a3,0x3
ffffffffc02031fe:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc0203202:	00002617          	auipc	a2,0x2
ffffffffc0203206:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0204c60 <commands+0x870>
ffffffffc020320a:	09b00593          	li	a1,155
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	82250513          	addi	a0,a0,-2014 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203216:	95afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc020321a:	00003697          	auipc	a3,0x3
ffffffffc020321e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc0203222:	00002617          	auipc	a2,0x2
ffffffffc0203226:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0204c60 <commands+0x870>
ffffffffc020322a:	09900593          	li	a1,153
ffffffffc020322e:	00003517          	auipc	a0,0x3
ffffffffc0203232:	80250513          	addi	a0,a0,-2046 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203236:	93afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc020323a:	00003697          	auipc	a3,0x3
ffffffffc020323e:	80e68693          	addi	a3,a3,-2034 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc0203242:	00002617          	auipc	a2,0x2
ffffffffc0203246:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0204c60 <commands+0x870>
ffffffffc020324a:	09700593          	li	a1,151
ffffffffc020324e:	00002517          	auipc	a0,0x2
ffffffffc0203252:	7e250513          	addi	a0,a0,2018 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203256:	91afd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc020325a:	00002697          	auipc	a3,0x2
ffffffffc020325e:	7ee68693          	addi	a3,a3,2030 # ffffffffc0205a48 <default_pmm_manager+0xa50>
ffffffffc0203262:	00002617          	auipc	a2,0x2
ffffffffc0203266:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0204c60 <commands+0x870>
ffffffffc020326a:	09500593          	li	a1,149
ffffffffc020326e:	00002517          	auipc	a0,0x2
ffffffffc0203272:	7c250513          	addi	a0,a0,1986 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203276:	8fafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc020327a:	00002697          	auipc	a3,0x2
ffffffffc020327e:	65668693          	addi	a3,a3,1622 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc0203282:	00002617          	auipc	a2,0x2
ffffffffc0203286:	9de60613          	addi	a2,a2,-1570 # ffffffffc0204c60 <commands+0x870>
ffffffffc020328a:	09300593          	li	a1,147
ffffffffc020328e:	00002517          	auipc	a0,0x2
ffffffffc0203292:	7a250513          	addi	a0,a0,1954 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc0203296:	8dafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc020329a:	00002697          	auipc	a3,0x2
ffffffffc020329e:	63668693          	addi	a3,a3,1590 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc02032a2:	00002617          	auipc	a2,0x2
ffffffffc02032a6:	9be60613          	addi	a2,a2,-1602 # ffffffffc0204c60 <commands+0x870>
ffffffffc02032aa:	09100593          	li	a1,145
ffffffffc02032ae:	00002517          	auipc	a0,0x2
ffffffffc02032b2:	78250513          	addi	a0,a0,1922 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02032b6:	8bafd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc02032ba:	00002697          	auipc	a3,0x2
ffffffffc02032be:	61668693          	addi	a3,a3,1558 # ffffffffc02058d0 <default_pmm_manager+0x8d8>
ffffffffc02032c2:	00002617          	auipc	a2,0x2
ffffffffc02032c6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0204c60 <commands+0x870>
ffffffffc02032ca:	08f00593          	li	a1,143
ffffffffc02032ce:	00002517          	auipc	a0,0x2
ffffffffc02032d2:	76250513          	addi	a0,a0,1890 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02032d6:	89afd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02032da <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02032da:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032de:	c38d                	beqz	a5,ffffffffc0203300 <_clock_map_swappable+0x26>
ffffffffc02032e0:	0000e717          	auipc	a4,0xe
ffffffffc02032e4:	2b870713          	addi	a4,a4,696 # ffffffffc0211598 <curr_ptr>
ffffffffc02032e8:	6318                	ld	a4,0(a4)
ffffffffc02032ea:	cb19                	beqz	a4,ffffffffc0203300 <_clock_map_swappable+0x26>
    list_add_before((list_entry_t*) mm->sm_priv,entry);
ffffffffc02032ec:	7518                	ld	a4,40(a0)
}
ffffffffc02032ee:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc02032f0:	6314                	ld	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc02032f2:	e31c                	sd	a5,0(a4)
ffffffffc02032f4:	e69c                	sd	a5,8(a3)
    page->visited = 1;
ffffffffc02032f6:	4785                	li	a5,1
    elm->next = next;
ffffffffc02032f8:	fe18                	sd	a4,56(a2)
    elm->prev = prev;
ffffffffc02032fa:	fa14                	sd	a3,48(a2)
ffffffffc02032fc:	ea1c                	sd	a5,16(a2)
}
ffffffffc02032fe:	8082                	ret
{
ffffffffc0203300:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203302:	00002697          	auipc	a3,0x2
ffffffffc0203306:	78e68693          	addi	a3,a3,1934 # ffffffffc0205a90 <default_pmm_manager+0xa98>
ffffffffc020330a:	00002617          	auipc	a2,0x2
ffffffffc020330e:	95660613          	addi	a2,a2,-1706 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203312:	03600593          	li	a1,54
ffffffffc0203316:	00002517          	auipc	a0,0x2
ffffffffc020331a:	71a50513          	addi	a0,a0,1818 # ffffffffc0205a30 <default_pmm_manager+0xa38>
{
ffffffffc020331e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203320:	850fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203324 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203324:	7508                	ld	a0,40(a0)
{
ffffffffc0203326:	1141                	addi	sp,sp,-16
ffffffffc0203328:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020332a:	c941                	beqz	a0,ffffffffc02033ba <_clock_swap_out_victim+0x96>
     assert(in_tick==0);
ffffffffc020332c:	e63d                	bnez	a2,ffffffffc020339a <_clock_swap_out_victim+0x76>
ffffffffc020332e:	0000e797          	auipc	a5,0xe
ffffffffc0203332:	26a78793          	addi	a5,a5,618 # ffffffffc0211598 <curr_ptr>
ffffffffc0203336:	639c                	ld	a5,0(a5)
ffffffffc0203338:	679c                	ld	a5,8(a5)
ffffffffc020333a:	a039                	j	ffffffffc0203348 <_clock_swap_out_victim+0x24>
        if(!page->visited) {
ffffffffc020333c:	fe07b683          	ld	a3,-32(a5)
ffffffffc0203340:	ce91                	beqz	a3,ffffffffc020335c <_clock_swap_out_victim+0x38>
            page->visited = 0;
ffffffffc0203342:	fe07b023          	sd	zero,-32(a5)
    while (1) {
ffffffffc0203346:	87ba                	mv	a5,a4
        if(curr_ptr == head) {
ffffffffc0203348:	6798                	ld	a4,8(a5)
ffffffffc020334a:	fef519e3          	bne	a0,a5,ffffffffc020333c <_clock_swap_out_victim+0x18>
            if(curr_ptr == head) {
ffffffffc020334e:	02a70c63          	beq	a4,a0,ffffffffc0203386 <_clock_swap_out_victim+0x62>
ffffffffc0203352:	87ba                	mv	a5,a4
        if(!page->visited) {
ffffffffc0203354:	fe07b683          	ld	a3,-32(a5)
            if(curr_ptr == head) {
ffffffffc0203358:	6718                	ld	a4,8(a4)
        if(!page->visited) {
ffffffffc020335a:	f6e5                	bnez	a3,ffffffffc0203342 <_clock_swap_out_victim+0x1e>
    __list_del(listelm->prev, listelm->next);
ffffffffc020335c:	6394                	ld	a3,0(a5)
ffffffffc020335e:	0000e617          	auipc	a2,0xe
ffffffffc0203362:	22f63d23          	sd	a5,570(a2) # ffffffffc0211598 <curr_ptr>
        struct Page* page = le2page(curr_ptr, pra_page_link);
ffffffffc0203366:	fd078613          	addi	a2,a5,-48
            *ptr_page = page;
ffffffffc020336a:	e190                	sd	a2,0(a1)
    prev->next = next;
ffffffffc020336c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020336e:	e314                	sd	a3,0(a4)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc0203370:	85be                	mv	a1,a5
ffffffffc0203372:	00002517          	auipc	a0,0x2
ffffffffc0203376:	76650513          	addi	a0,a0,1894 # ffffffffc0205ad8 <default_pmm_manager+0xae0>
ffffffffc020337a:	d45fc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc020337e:	60a2                	ld	ra,8(sp)
ffffffffc0203380:	4501                	li	a0,0
ffffffffc0203382:	0141                	addi	sp,sp,16
ffffffffc0203384:	8082                	ret
ffffffffc0203386:	60a2                	ld	ra,8(sp)
ffffffffc0203388:	0000e797          	auipc	a5,0xe
ffffffffc020338c:	20a7b823          	sd	a0,528(a5) # ffffffffc0211598 <curr_ptr>
                *ptr_page = NULL;
ffffffffc0203390:	0005b023          	sd	zero,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
}
ffffffffc0203394:	4501                	li	a0,0
ffffffffc0203396:	0141                	addi	sp,sp,16
ffffffffc0203398:	8082                	ret
     assert(in_tick==0);
ffffffffc020339a:	00002697          	auipc	a3,0x2
ffffffffc020339e:	72e68693          	addi	a3,a3,1838 # ffffffffc0205ac8 <default_pmm_manager+0xad0>
ffffffffc02033a2:	00002617          	auipc	a2,0x2
ffffffffc02033a6:	8be60613          	addi	a2,a2,-1858 # ffffffffc0204c60 <commands+0x870>
ffffffffc02033aa:	04900593          	li	a1,73
ffffffffc02033ae:	00002517          	auipc	a0,0x2
ffffffffc02033b2:	68250513          	addi	a0,a0,1666 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02033b6:	fbbfc0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(head != NULL);
ffffffffc02033ba:	00002697          	auipc	a3,0x2
ffffffffc02033be:	6fe68693          	addi	a3,a3,1790 # ffffffffc0205ab8 <default_pmm_manager+0xac0>
ffffffffc02033c2:	00002617          	auipc	a2,0x2
ffffffffc02033c6:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204c60 <commands+0x870>
ffffffffc02033ca:	04800593          	li	a1,72
ffffffffc02033ce:	00002517          	auipc	a0,0x2
ffffffffc02033d2:	66250513          	addi	a0,a0,1634 # ffffffffc0205a30 <default_pmm_manager+0xa38>
ffffffffc02033d6:	f9bfc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02033da <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02033da:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02033dc:	00002697          	auipc	a3,0x2
ffffffffc02033e0:	72468693          	addi	a3,a3,1828 # ffffffffc0205b00 <default_pmm_manager+0xb08>
ffffffffc02033e4:	00002617          	auipc	a2,0x2
ffffffffc02033e8:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204c60 <commands+0x870>
ffffffffc02033ec:	07d00593          	li	a1,125
ffffffffc02033f0:	00002517          	auipc	a0,0x2
ffffffffc02033f4:	73050513          	addi	a0,a0,1840 # ffffffffc0205b20 <default_pmm_manager+0xb28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02033f8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02033fa:	f77fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02033fe <mm_create>:
mm_create(void) {
ffffffffc02033fe:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203400:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203404:	e022                	sd	s0,0(sp)
ffffffffc0203406:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203408:	a84ff0ef          	jal	ra,ffffffffc020268c <kmalloc>
ffffffffc020340c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020340e:	c115                	beqz	a0,ffffffffc0203432 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203410:	0000e797          	auipc	a5,0xe
ffffffffc0203414:	06878793          	addi	a5,a5,104 # ffffffffc0211478 <swap_init_ok>
ffffffffc0203418:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020341a:	e408                	sd	a0,8(s0)
ffffffffc020341c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020341e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203422:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203426:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020342a:	2781                	sext.w	a5,a5
ffffffffc020342c:	eb81                	bnez	a5,ffffffffc020343c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020342e:	02053423          	sd	zero,40(a0)
}
ffffffffc0203432:	8522                	mv	a0,s0
ffffffffc0203434:	60a2                	ld	ra,8(sp)
ffffffffc0203436:	6402                	ld	s0,0(sp)
ffffffffc0203438:	0141                	addi	sp,sp,16
ffffffffc020343a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020343c:	a73ff0ef          	jal	ra,ffffffffc0202eae <swap_init_mm>
}
ffffffffc0203440:	8522                	mv	a0,s0
ffffffffc0203442:	60a2                	ld	ra,8(sp)
ffffffffc0203444:	6402                	ld	s0,0(sp)
ffffffffc0203446:	0141                	addi	sp,sp,16
ffffffffc0203448:	8082                	ret

ffffffffc020344a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020344a:	1101                	addi	sp,sp,-32
ffffffffc020344c:	e04a                	sd	s2,0(sp)
ffffffffc020344e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203450:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203454:	e822                	sd	s0,16(sp)
ffffffffc0203456:	e426                	sd	s1,8(sp)
ffffffffc0203458:	ec06                	sd	ra,24(sp)
ffffffffc020345a:	84ae                	mv	s1,a1
ffffffffc020345c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020345e:	a2eff0ef          	jal	ra,ffffffffc020268c <kmalloc>
    if (vma != NULL) {
ffffffffc0203462:	c509                	beqz	a0,ffffffffc020346c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203464:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203468:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020346a:	ed00                	sd	s0,24(a0)
}
ffffffffc020346c:	60e2                	ld	ra,24(sp)
ffffffffc020346e:	6442                	ld	s0,16(sp)
ffffffffc0203470:	64a2                	ld	s1,8(sp)
ffffffffc0203472:	6902                	ld	s2,0(sp)
ffffffffc0203474:	6105                	addi	sp,sp,32
ffffffffc0203476:	8082                	ret

ffffffffc0203478 <find_vma>:
    if (mm != NULL) {
ffffffffc0203478:	c51d                	beqz	a0,ffffffffc02034a6 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020347a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020347c:	c781                	beqz	a5,ffffffffc0203484 <find_vma+0xc>
ffffffffc020347e:	6798                	ld	a4,8(a5)
ffffffffc0203480:	02e5f663          	bgeu	a1,a4,ffffffffc02034ac <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203484:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203486:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203488:	00f50f63          	beq	a0,a5,ffffffffc02034a6 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020348c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203490:	fee5ebe3          	bltu	a1,a4,ffffffffc0203486 <find_vma+0xe>
ffffffffc0203494:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203498:	fee5f7e3          	bgeu	a1,a4,ffffffffc0203486 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020349c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020349e:	c781                	beqz	a5,ffffffffc02034a6 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02034a0:	e91c                	sd	a5,16(a0)
}
ffffffffc02034a2:	853e                	mv	a0,a5
ffffffffc02034a4:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02034a6:	4781                	li	a5,0
}
ffffffffc02034a8:	853e                	mv	a0,a5
ffffffffc02034aa:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034ac:	6b98                	ld	a4,16(a5)
ffffffffc02034ae:	fce5fbe3          	bgeu	a1,a4,ffffffffc0203484 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02034b2:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02034b4:	b7fd                	j	ffffffffc02034a2 <find_vma+0x2a>

ffffffffc02034b6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02034b6:	6590                	ld	a2,8(a1)
ffffffffc02034b8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02034bc:	1141                	addi	sp,sp,-16
ffffffffc02034be:	e406                	sd	ra,8(sp)
ffffffffc02034c0:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02034c2:	01066863          	bltu	a2,a6,ffffffffc02034d2 <insert_vma_struct+0x1c>
ffffffffc02034c6:	a8b9                	j	ffffffffc0203524 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02034c8:	fe87b683          	ld	a3,-24(a5)
ffffffffc02034cc:	04d66763          	bltu	a2,a3,ffffffffc020351a <insert_vma_struct+0x64>
ffffffffc02034d0:	873e                	mv	a4,a5
ffffffffc02034d2:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02034d4:	fef51ae3          	bne	a0,a5,ffffffffc02034c8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02034d8:	02a70463          	beq	a4,a0,ffffffffc0203500 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02034dc:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02034e0:	fe873883          	ld	a7,-24(a4)
ffffffffc02034e4:	08d8f063          	bgeu	a7,a3,ffffffffc0203564 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02034e8:	04d66e63          	bltu	a2,a3,ffffffffc0203544 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02034ec:	00f50a63          	beq	a0,a5,ffffffffc0203500 <insert_vma_struct+0x4a>
ffffffffc02034f0:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02034f4:	0506e863          	bltu	a3,a6,ffffffffc0203544 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02034f8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02034fc:	02c6f263          	bgeu	a3,a2,ffffffffc0203520 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203500:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203502:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203504:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203508:	e390                	sd	a2,0(a5)
ffffffffc020350a:	e710                	sd	a2,8(a4)
}
ffffffffc020350c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020350e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203510:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203512:	2685                	addiw	a3,a3,1
ffffffffc0203514:	d114                	sw	a3,32(a0)
}
ffffffffc0203516:	0141                	addi	sp,sp,16
ffffffffc0203518:	8082                	ret
    if (le_prev != list) {
ffffffffc020351a:	fca711e3          	bne	a4,a0,ffffffffc02034dc <insert_vma_struct+0x26>
ffffffffc020351e:	bfd9                	j	ffffffffc02034f4 <insert_vma_struct+0x3e>
ffffffffc0203520:	ebbff0ef          	jal	ra,ffffffffc02033da <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203524:	00002697          	auipc	a3,0x2
ffffffffc0203528:	68c68693          	addi	a3,a3,1676 # ffffffffc0205bb0 <default_pmm_manager+0xbb8>
ffffffffc020352c:	00001617          	auipc	a2,0x1
ffffffffc0203530:	73460613          	addi	a2,a2,1844 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203534:	08400593          	li	a1,132
ffffffffc0203538:	00002517          	auipc	a0,0x2
ffffffffc020353c:	5e850513          	addi	a0,a0,1512 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203540:	e31fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203544:	00002697          	auipc	a3,0x2
ffffffffc0203548:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205bf0 <default_pmm_manager+0xbf8>
ffffffffc020354c:	00001617          	auipc	a2,0x1
ffffffffc0203550:	71460613          	addi	a2,a2,1812 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203554:	07c00593          	li	a1,124
ffffffffc0203558:	00002517          	auipc	a0,0x2
ffffffffc020355c:	5c850513          	addi	a0,a0,1480 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203560:	e11fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203564:	00002697          	auipc	a3,0x2
ffffffffc0203568:	66c68693          	addi	a3,a3,1644 # ffffffffc0205bd0 <default_pmm_manager+0xbd8>
ffffffffc020356c:	00001617          	auipc	a2,0x1
ffffffffc0203570:	6f460613          	addi	a2,a2,1780 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203574:	07b00593          	li	a1,123
ffffffffc0203578:	00002517          	auipc	a0,0x2
ffffffffc020357c:	5a850513          	addi	a0,a0,1448 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203580:	df1fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203584 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203584:	1141                	addi	sp,sp,-16
ffffffffc0203586:	e022                	sd	s0,0(sp)
ffffffffc0203588:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020358a:	6508                	ld	a0,8(a0)
ffffffffc020358c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020358e:	00a40e63          	beq	s0,a0,ffffffffc02035aa <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203592:	6118                	ld	a4,0(a0)
ffffffffc0203594:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203596:	03000593          	li	a1,48
ffffffffc020359a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020359c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020359e:	e398                	sd	a4,0(a5)
ffffffffc02035a0:	9aeff0ef          	jal	ra,ffffffffc020274e <kfree>
    return listelm->next;
ffffffffc02035a4:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02035a6:	fea416e3          	bne	s0,a0,ffffffffc0203592 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035aa:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02035ac:	6402                	ld	s0,0(sp)
ffffffffc02035ae:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035b0:	03000593          	li	a1,48
}
ffffffffc02035b4:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035b6:	998ff06f          	j	ffffffffc020274e <kfree>

ffffffffc02035ba <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02035ba:	715d                	addi	sp,sp,-80
ffffffffc02035bc:	e486                	sd	ra,72(sp)
ffffffffc02035be:	e0a2                	sd	s0,64(sp)
ffffffffc02035c0:	fc26                	sd	s1,56(sp)
ffffffffc02035c2:	f84a                	sd	s2,48(sp)
ffffffffc02035c4:	f052                	sd	s4,32(sp)
ffffffffc02035c6:	f44e                	sd	s3,40(sp)
ffffffffc02035c8:	ec56                	sd	s5,24(sp)
ffffffffc02035ca:	e85a                	sd	s6,16(sp)
ffffffffc02035cc:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02035ce:	96efe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02035d2:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02035d4:	968fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02035d8:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc02035da:	e25ff0ef          	jal	ra,ffffffffc02033fe <mm_create>
    assert(mm != NULL);
ffffffffc02035de:	842a                	mv	s0,a0
ffffffffc02035e0:	03200493          	li	s1,50
ffffffffc02035e4:	e919                	bnez	a0,ffffffffc02035fa <vmm_init+0x40>
ffffffffc02035e6:	aeed                	j	ffffffffc02039e0 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc02035e8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02035ea:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035ec:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02035f0:	14ed                	addi	s1,s1,-5
ffffffffc02035f2:	8522                	mv	a0,s0
ffffffffc02035f4:	ec3ff0ef          	jal	ra,ffffffffc02034b6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02035f8:	c88d                	beqz	s1,ffffffffc020362a <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035fa:	03000513          	li	a0,48
ffffffffc02035fe:	88eff0ef          	jal	ra,ffffffffc020268c <kmalloc>
ffffffffc0203602:	85aa                	mv	a1,a0
ffffffffc0203604:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203608:	f165                	bnez	a0,ffffffffc02035e8 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020360a:	00002697          	auipc	a3,0x2
ffffffffc020360e:	18668693          	addi	a3,a3,390 # ffffffffc0205790 <default_pmm_manager+0x798>
ffffffffc0203612:	00001617          	auipc	a2,0x1
ffffffffc0203616:	64e60613          	addi	a2,a2,1614 # ffffffffc0204c60 <commands+0x870>
ffffffffc020361a:	0ce00593          	li	a1,206
ffffffffc020361e:	00002517          	auipc	a0,0x2
ffffffffc0203622:	50250513          	addi	a0,a0,1282 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203626:	d4bfc0ef          	jal	ra,ffffffffc0200370 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020362a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020362e:	1f900993          	li	s3,505
ffffffffc0203632:	a819                	j	ffffffffc0203648 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203634:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203636:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203638:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020363c:	0495                	addi	s1,s1,5
ffffffffc020363e:	8522                	mv	a0,s0
ffffffffc0203640:	e77ff0ef          	jal	ra,ffffffffc02034b6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203644:	03348a63          	beq	s1,s3,ffffffffc0203678 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203648:	03000513          	li	a0,48
ffffffffc020364c:	840ff0ef          	jal	ra,ffffffffc020268c <kmalloc>
ffffffffc0203650:	85aa                	mv	a1,a0
ffffffffc0203652:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203656:	fd79                	bnez	a0,ffffffffc0203634 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0203658:	00002697          	auipc	a3,0x2
ffffffffc020365c:	13868693          	addi	a3,a3,312 # ffffffffc0205790 <default_pmm_manager+0x798>
ffffffffc0203660:	00001617          	auipc	a2,0x1
ffffffffc0203664:	60060613          	addi	a2,a2,1536 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203668:	0d400593          	li	a1,212
ffffffffc020366c:	00002517          	auipc	a0,0x2
ffffffffc0203670:	4b450513          	addi	a0,a0,1204 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203674:	cfdfc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203678:	6418                	ld	a4,8(s0)
ffffffffc020367a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020367c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203680:	2ae40063          	beq	s0,a4,ffffffffc0203920 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203684:	fe873603          	ld	a2,-24(a4)
ffffffffc0203688:	ffe78693          	addi	a3,a5,-2
ffffffffc020368c:	20d61a63          	bne	a2,a3,ffffffffc02038a0 <vmm_init+0x2e6>
ffffffffc0203690:	ff073683          	ld	a3,-16(a4)
ffffffffc0203694:	20d79663          	bne	a5,a3,ffffffffc02038a0 <vmm_init+0x2e6>
ffffffffc0203698:	0795                	addi	a5,a5,5
ffffffffc020369a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020369c:	feb792e3          	bne	a5,a1,ffffffffc0203680 <vmm_init+0xc6>
ffffffffc02036a0:	499d                	li	s3,7
ffffffffc02036a2:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02036a4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02036a8:	85a6                	mv	a1,s1
ffffffffc02036aa:	8522                	mv	a0,s0
ffffffffc02036ac:	dcdff0ef          	jal	ra,ffffffffc0203478 <find_vma>
ffffffffc02036b0:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02036b2:	2e050763          	beqz	a0,ffffffffc02039a0 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02036b6:	00148593          	addi	a1,s1,1
ffffffffc02036ba:	8522                	mv	a0,s0
ffffffffc02036bc:	dbdff0ef          	jal	ra,ffffffffc0203478 <find_vma>
ffffffffc02036c0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02036c2:	2a050f63          	beqz	a0,ffffffffc0203980 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02036c6:	85ce                	mv	a1,s3
ffffffffc02036c8:	8522                	mv	a0,s0
ffffffffc02036ca:	dafff0ef          	jal	ra,ffffffffc0203478 <find_vma>
        assert(vma3 == NULL);
ffffffffc02036ce:	28051963          	bnez	a0,ffffffffc0203960 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02036d2:	00348593          	addi	a1,s1,3
ffffffffc02036d6:	8522                	mv	a0,s0
ffffffffc02036d8:	da1ff0ef          	jal	ra,ffffffffc0203478 <find_vma>
        assert(vma4 == NULL);
ffffffffc02036dc:	26051263          	bnez	a0,ffffffffc0203940 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02036e0:	00448593          	addi	a1,s1,4
ffffffffc02036e4:	8522                	mv	a0,s0
ffffffffc02036e6:	d93ff0ef          	jal	ra,ffffffffc0203478 <find_vma>
        assert(vma5 == NULL);
ffffffffc02036ea:	2c051b63          	bnez	a0,ffffffffc02039c0 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02036ee:	008b3783          	ld	a5,8(s6)
ffffffffc02036f2:	1c979763          	bne	a5,s1,ffffffffc02038c0 <vmm_init+0x306>
ffffffffc02036f6:	010b3783          	ld	a5,16(s6)
ffffffffc02036fa:	1d379363          	bne	a5,s3,ffffffffc02038c0 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02036fe:	008ab783          	ld	a5,8(s5)
ffffffffc0203702:	1c979f63          	bne	a5,s1,ffffffffc02038e0 <vmm_init+0x326>
ffffffffc0203706:	010ab783          	ld	a5,16(s5)
ffffffffc020370a:	1d379b63          	bne	a5,s3,ffffffffc02038e0 <vmm_init+0x326>
ffffffffc020370e:	0495                	addi	s1,s1,5
ffffffffc0203710:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203712:	f9749be3          	bne	s1,s7,ffffffffc02036a8 <vmm_init+0xee>
ffffffffc0203716:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203718:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020371a:	85a6                	mv	a1,s1
ffffffffc020371c:	8522                	mv	a0,s0
ffffffffc020371e:	d5bff0ef          	jal	ra,ffffffffc0203478 <find_vma>
ffffffffc0203722:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203726:	c90d                	beqz	a0,ffffffffc0203758 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203728:	6914                	ld	a3,16(a0)
ffffffffc020372a:	6510                	ld	a2,8(a0)
ffffffffc020372c:	00002517          	auipc	a0,0x2
ffffffffc0203730:	5e450513          	addi	a0,a0,1508 # ffffffffc0205d10 <default_pmm_manager+0xd18>
ffffffffc0203734:	98bfc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203738:	00002697          	auipc	a3,0x2
ffffffffc020373c:	60068693          	addi	a3,a3,1536 # ffffffffc0205d38 <default_pmm_manager+0xd40>
ffffffffc0203740:	00001617          	auipc	a2,0x1
ffffffffc0203744:	52060613          	addi	a2,a2,1312 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203748:	0f600593          	li	a1,246
ffffffffc020374c:	00002517          	auipc	a0,0x2
ffffffffc0203750:	3d450513          	addi	a0,a0,980 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203754:	c1dfc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203758:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020375a:	fd3490e3          	bne	s1,s3,ffffffffc020371a <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020375e:	8522                	mv	a0,s0
ffffffffc0203760:	e25ff0ef          	jal	ra,ffffffffc0203584 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203764:	fd9fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0203768:	28aa1c63          	bne	s4,a0,ffffffffc0203a00 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020376c:	00002517          	auipc	a0,0x2
ffffffffc0203770:	60c50513          	addi	a0,a0,1548 # ffffffffc0205d78 <default_pmm_manager+0xd80>
ffffffffc0203774:	94bfc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203778:	fc5fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc020377c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020377e:	c81ff0ef          	jal	ra,ffffffffc02033fe <mm_create>
ffffffffc0203782:	0000e797          	auipc	a5,0xe
ffffffffc0203786:	e0a7bf23          	sd	a0,-482(a5) # ffffffffc02115a0 <check_mm_struct>
ffffffffc020378a:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020378c:	2a050a63          	beqz	a0,ffffffffc0203a40 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203790:	0000e797          	auipc	a5,0xe
ffffffffc0203794:	cd078793          	addi	a5,a5,-816 # ffffffffc0211460 <boot_pgdir>
ffffffffc0203798:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020379a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020379c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020379e:	32079d63          	bnez	a5,ffffffffc0203ad8 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037a2:	03000513          	li	a0,48
ffffffffc02037a6:	ee7fe0ef          	jal	ra,ffffffffc020268c <kmalloc>
ffffffffc02037aa:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02037ac:	14050a63          	beqz	a0,ffffffffc0203900 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02037b0:	002007b7          	lui	a5,0x200
ffffffffc02037b4:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02037b8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02037ba:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02037bc:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037c0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02037c2:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037c6:	cf1ff0ef          	jal	ra,ffffffffc02034b6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02037ca:	10000593          	li	a1,256
ffffffffc02037ce:	8522                	mv	a0,s0
ffffffffc02037d0:	ca9ff0ef          	jal	ra,ffffffffc0203478 <find_vma>
ffffffffc02037d4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02037d8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02037dc:	2aaa1263          	bne	s4,a0,ffffffffc0203a80 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02037e0:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02037e4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02037e6:	fee79de3          	bne	a5,a4,ffffffffc02037e0 <vmm_init+0x226>
        sum += i;
ffffffffc02037ea:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02037ec:	10000793          	li	a5,256
        sum += i;
ffffffffc02037f0:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02037f4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02037f8:	0007c683          	lbu	a3,0(a5)
ffffffffc02037fc:	0785                	addi	a5,a5,1
ffffffffc02037fe:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203800:	fec79ce3          	bne	a5,a2,ffffffffc02037f8 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203804:	2a071a63          	bnez	a4,ffffffffc0203ab8 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203808:	4581                	li	a1,0
ffffffffc020380a:	8526                	mv	a0,s1
ffffffffc020380c:	9ccfe0ef          	jal	ra,ffffffffc02019d8 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203810:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203812:	0000e717          	auipc	a4,0xe
ffffffffc0203816:	c5670713          	addi	a4,a4,-938 # ffffffffc0211468 <npage>
ffffffffc020381a:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020381c:	078a                	slli	a5,a5,0x2
ffffffffc020381e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203820:	28e7f063          	bgeu	a5,a4,ffffffffc0203aa0 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203824:	00003717          	auipc	a4,0x3
ffffffffc0203828:	89470713          	addi	a4,a4,-1900 # ffffffffc02060b8 <nbase>
ffffffffc020382c:	6318                	ld	a4,0(a4)
ffffffffc020382e:	0000e697          	auipc	a3,0xe
ffffffffc0203832:	c8a68693          	addi	a3,a3,-886 # ffffffffc02114b8 <pages>
ffffffffc0203836:	6288                	ld	a0,0(a3)
ffffffffc0203838:	8f99                	sub	a5,a5,a4
ffffffffc020383a:	00379713          	slli	a4,a5,0x3
ffffffffc020383e:	97ba                	add	a5,a5,a4
ffffffffc0203840:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203842:	953e                	add	a0,a0,a5
ffffffffc0203844:	4585                	li	a1,1
ffffffffc0203846:	eb1fd0ef          	jal	ra,ffffffffc02016f6 <free_pages>

    pgdir[0] = 0;
ffffffffc020384a:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020384e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0203850:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203854:	d31ff0ef          	jal	ra,ffffffffc0203584 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203858:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020385a:	0000e797          	auipc	a5,0xe
ffffffffc020385e:	d407b323          	sd	zero,-698(a5) # ffffffffc02115a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203862:	edbfd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0203866:	1aa99d63          	bne	s3,a0,ffffffffc0203a20 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020386a:	00002517          	auipc	a0,0x2
ffffffffc020386e:	57650513          	addi	a0,a0,1398 # ffffffffc0205de0 <default_pmm_manager+0xde8>
ffffffffc0203872:	84dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203876:	ec7fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020387a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020387c:	1ea91263          	bne	s2,a0,ffffffffc0203a60 <vmm_init+0x4a6>
}
ffffffffc0203880:	6406                	ld	s0,64(sp)
ffffffffc0203882:	60a6                	ld	ra,72(sp)
ffffffffc0203884:	74e2                	ld	s1,56(sp)
ffffffffc0203886:	7942                	ld	s2,48(sp)
ffffffffc0203888:	79a2                	ld	s3,40(sp)
ffffffffc020388a:	7a02                	ld	s4,32(sp)
ffffffffc020388c:	6ae2                	ld	s5,24(sp)
ffffffffc020388e:	6b42                	ld	s6,16(sp)
ffffffffc0203890:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203892:	00002517          	auipc	a0,0x2
ffffffffc0203896:	56e50513          	addi	a0,a0,1390 # ffffffffc0205e00 <default_pmm_manager+0xe08>
}
ffffffffc020389a:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020389c:	823fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038a0:	00002697          	auipc	a3,0x2
ffffffffc02038a4:	38868693          	addi	a3,a3,904 # ffffffffc0205c28 <default_pmm_manager+0xc30>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	3b860613          	addi	a2,a2,952 # ffffffffc0204c60 <commands+0x870>
ffffffffc02038b0:	0dd00593          	li	a1,221
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	26c50513          	addi	a0,a0,620 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02038bc:	ab5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	3f068693          	addi	a3,a3,1008 # ffffffffc0205cb0 <default_pmm_manager+0xcb8>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	39860613          	addi	a2,a2,920 # ffffffffc0204c60 <commands+0x870>
ffffffffc02038d0:	0ed00593          	li	a1,237
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	24c50513          	addi	a0,a0,588 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02038dc:	a95fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02038e0:	00002697          	auipc	a3,0x2
ffffffffc02038e4:	40068693          	addi	a3,a3,1024 # ffffffffc0205ce0 <default_pmm_manager+0xce8>
ffffffffc02038e8:	00001617          	auipc	a2,0x1
ffffffffc02038ec:	37860613          	addi	a2,a2,888 # ffffffffc0204c60 <commands+0x870>
ffffffffc02038f0:	0ee00593          	li	a1,238
ffffffffc02038f4:	00002517          	auipc	a0,0x2
ffffffffc02038f8:	22c50513          	addi	a0,a0,556 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02038fc:	a75fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(vma != NULL);
ffffffffc0203900:	00002697          	auipc	a3,0x2
ffffffffc0203904:	e9068693          	addi	a3,a3,-368 # ffffffffc0205790 <default_pmm_manager+0x798>
ffffffffc0203908:	00001617          	auipc	a2,0x1
ffffffffc020390c:	35860613          	addi	a2,a2,856 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203910:	11100593          	li	a1,273
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	20c50513          	addi	a0,a0,524 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc020391c:	a55fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203920:	00002697          	auipc	a3,0x2
ffffffffc0203924:	2f068693          	addi	a3,a3,752 # ffffffffc0205c10 <default_pmm_manager+0xc18>
ffffffffc0203928:	00001617          	auipc	a2,0x1
ffffffffc020392c:	33860613          	addi	a2,a2,824 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203930:	0db00593          	li	a1,219
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	1ec50513          	addi	a0,a0,492 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc020393c:	a35fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma4 == NULL);
ffffffffc0203940:	00002697          	auipc	a3,0x2
ffffffffc0203944:	35068693          	addi	a3,a3,848 # ffffffffc0205c90 <default_pmm_manager+0xc98>
ffffffffc0203948:	00001617          	auipc	a2,0x1
ffffffffc020394c:	31860613          	addi	a2,a2,792 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203950:	0e900593          	li	a1,233
ffffffffc0203954:	00002517          	auipc	a0,0x2
ffffffffc0203958:	1cc50513          	addi	a0,a0,460 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc020395c:	a15fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma3 == NULL);
ffffffffc0203960:	00002697          	auipc	a3,0x2
ffffffffc0203964:	32068693          	addi	a3,a3,800 # ffffffffc0205c80 <default_pmm_manager+0xc88>
ffffffffc0203968:	00001617          	auipc	a2,0x1
ffffffffc020396c:	2f860613          	addi	a2,a2,760 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203970:	0e700593          	li	a1,231
ffffffffc0203974:	00002517          	auipc	a0,0x2
ffffffffc0203978:	1ac50513          	addi	a0,a0,428 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc020397c:	9f5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2 != NULL);
ffffffffc0203980:	00002697          	auipc	a3,0x2
ffffffffc0203984:	2f068693          	addi	a3,a3,752 # ffffffffc0205c70 <default_pmm_manager+0xc78>
ffffffffc0203988:	00001617          	auipc	a2,0x1
ffffffffc020398c:	2d860613          	addi	a2,a2,728 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203990:	0e500593          	li	a1,229
ffffffffc0203994:	00002517          	auipc	a0,0x2
ffffffffc0203998:	18c50513          	addi	a0,a0,396 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc020399c:	9d5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1 != NULL);
ffffffffc02039a0:	00002697          	auipc	a3,0x2
ffffffffc02039a4:	2c068693          	addi	a3,a3,704 # ffffffffc0205c60 <default_pmm_manager+0xc68>
ffffffffc02039a8:	00001617          	auipc	a2,0x1
ffffffffc02039ac:	2b860613          	addi	a2,a2,696 # ffffffffc0204c60 <commands+0x870>
ffffffffc02039b0:	0e300593          	li	a1,227
ffffffffc02039b4:	00002517          	auipc	a0,0x2
ffffffffc02039b8:	16c50513          	addi	a0,a0,364 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02039bc:	9b5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma5 == NULL);
ffffffffc02039c0:	00002697          	auipc	a3,0x2
ffffffffc02039c4:	2e068693          	addi	a3,a3,736 # ffffffffc0205ca0 <default_pmm_manager+0xca8>
ffffffffc02039c8:	00001617          	auipc	a2,0x1
ffffffffc02039cc:	29860613          	addi	a2,a2,664 # ffffffffc0204c60 <commands+0x870>
ffffffffc02039d0:	0eb00593          	li	a1,235
ffffffffc02039d4:	00002517          	auipc	a0,0x2
ffffffffc02039d8:	14c50513          	addi	a0,a0,332 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02039dc:	995fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(mm != NULL);
ffffffffc02039e0:	00002697          	auipc	a3,0x2
ffffffffc02039e4:	d7868693          	addi	a3,a3,-648 # ffffffffc0205758 <default_pmm_manager+0x760>
ffffffffc02039e8:	00001617          	auipc	a2,0x1
ffffffffc02039ec:	27860613          	addi	a2,a2,632 # ffffffffc0204c60 <commands+0x870>
ffffffffc02039f0:	0c700593          	li	a1,199
ffffffffc02039f4:	00002517          	auipc	a0,0x2
ffffffffc02039f8:	12c50513          	addi	a0,a0,300 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc02039fc:	975fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a00:	00002697          	auipc	a3,0x2
ffffffffc0203a04:	35068693          	addi	a3,a3,848 # ffffffffc0205d50 <default_pmm_manager+0xd58>
ffffffffc0203a08:	00001617          	auipc	a2,0x1
ffffffffc0203a0c:	25860613          	addi	a2,a2,600 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203a10:	0fb00593          	li	a1,251
ffffffffc0203a14:	00002517          	auipc	a0,0x2
ffffffffc0203a18:	10c50513          	addi	a0,a0,268 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203a1c:	955fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a20:	00002697          	auipc	a3,0x2
ffffffffc0203a24:	33068693          	addi	a3,a3,816 # ffffffffc0205d50 <default_pmm_manager+0xd58>
ffffffffc0203a28:	00001617          	auipc	a2,0x1
ffffffffc0203a2c:	23860613          	addi	a2,a2,568 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203a30:	12e00593          	li	a1,302
ffffffffc0203a34:	00002517          	auipc	a0,0x2
ffffffffc0203a38:	0ec50513          	addi	a0,a0,236 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203a3c:	935fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203a40:	00002697          	auipc	a3,0x2
ffffffffc0203a44:	35868693          	addi	a3,a3,856 # ffffffffc0205d98 <default_pmm_manager+0xda0>
ffffffffc0203a48:	00001617          	auipc	a2,0x1
ffffffffc0203a4c:	21860613          	addi	a2,a2,536 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203a50:	10a00593          	li	a1,266
ffffffffc0203a54:	00002517          	auipc	a0,0x2
ffffffffc0203a58:	0cc50513          	addi	a0,a0,204 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203a5c:	915fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a60:	00002697          	auipc	a3,0x2
ffffffffc0203a64:	2f068693          	addi	a3,a3,752 # ffffffffc0205d50 <default_pmm_manager+0xd58>
ffffffffc0203a68:	00001617          	auipc	a2,0x1
ffffffffc0203a6c:	1f860613          	addi	a2,a2,504 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203a70:	0bd00593          	li	a1,189
ffffffffc0203a74:	00002517          	auipc	a0,0x2
ffffffffc0203a78:	0ac50513          	addi	a0,a0,172 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203a7c:	8f5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a80:	00002697          	auipc	a3,0x2
ffffffffc0203a84:	33068693          	addi	a3,a3,816 # ffffffffc0205db0 <default_pmm_manager+0xdb8>
ffffffffc0203a88:	00001617          	auipc	a2,0x1
ffffffffc0203a8c:	1d860613          	addi	a2,a2,472 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203a90:	11600593          	li	a1,278
ffffffffc0203a94:	00002517          	auipc	a0,0x2
ffffffffc0203a98:	08c50513          	addi	a0,a0,140 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203a9c:	8d5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203aa0:	00001617          	auipc	a2,0x1
ffffffffc0203aa4:	62060613          	addi	a2,a2,1568 # ffffffffc02050c0 <default_pmm_manager+0xc8>
ffffffffc0203aa8:	06500593          	li	a1,101
ffffffffc0203aac:	00001517          	auipc	a0,0x1
ffffffffc0203ab0:	63450513          	addi	a0,a0,1588 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0203ab4:	8bdfc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(sum == 0);
ffffffffc0203ab8:	00002697          	auipc	a3,0x2
ffffffffc0203abc:	31868693          	addi	a3,a3,792 # ffffffffc0205dd0 <default_pmm_manager+0xdd8>
ffffffffc0203ac0:	00001617          	auipc	a2,0x1
ffffffffc0203ac4:	1a060613          	addi	a2,a2,416 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203ac8:	12000593          	li	a1,288
ffffffffc0203acc:	00002517          	auipc	a0,0x2
ffffffffc0203ad0:	05450513          	addi	a0,a0,84 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203ad4:	89dfc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203ad8:	00002697          	auipc	a3,0x2
ffffffffc0203adc:	ca868693          	addi	a3,a3,-856 # ffffffffc0205780 <default_pmm_manager+0x788>
ffffffffc0203ae0:	00001617          	auipc	a2,0x1
ffffffffc0203ae4:	18060613          	addi	a2,a2,384 # ffffffffc0204c60 <commands+0x870>
ffffffffc0203ae8:	10d00593          	li	a1,269
ffffffffc0203aec:	00002517          	auipc	a0,0x2
ffffffffc0203af0:	03450513          	addi	a0,a0,52 # ffffffffc0205b20 <default_pmm_manager+0xb28>
ffffffffc0203af4:	87dfc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203af8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203af8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203afa:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203afc:	f022                	sd	s0,32(sp)
ffffffffc0203afe:	ec26                	sd	s1,24(sp)
ffffffffc0203b00:	f406                	sd	ra,40(sp)
ffffffffc0203b02:	e84a                	sd	s2,16(sp)
ffffffffc0203b04:	8432                	mv	s0,a2
ffffffffc0203b06:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b08:	971ff0ef          	jal	ra,ffffffffc0203478 <find_vma>

    pgfault_num++;
ffffffffc0203b0c:	0000e797          	auipc	a5,0xe
ffffffffc0203b10:	97078793          	addi	a5,a5,-1680 # ffffffffc021147c <pgfault_num>
ffffffffc0203b14:	439c                	lw	a5,0(a5)
ffffffffc0203b16:	2785                	addiw	a5,a5,1
ffffffffc0203b18:	0000e717          	auipc	a4,0xe
ffffffffc0203b1c:	96f72223          	sw	a5,-1692(a4) # ffffffffc021147c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b20:	c549                	beqz	a0,ffffffffc0203baa <do_pgfault+0xb2>
ffffffffc0203b22:	651c                	ld	a5,8(a0)
ffffffffc0203b24:	08f46363          	bltu	s0,a5,ffffffffc0203baa <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b28:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b2a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b2c:	8b89                	andi	a5,a5,2
ffffffffc0203b2e:	efa9                	bnez	a5,ffffffffc0203b88 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b30:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b32:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b34:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b36:	85a2                	mv	a1,s0
ffffffffc0203b38:	4605                	li	a2,1
ffffffffc0203b3a:	c43fd0ef          	jal	ra,ffffffffc020177c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203b3e:	610c                	ld	a1,0(a0)
ffffffffc0203b40:	c5b1                	beqz	a1,ffffffffc0203b8c <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203b42:	0000e797          	auipc	a5,0xe
ffffffffc0203b46:	93678793          	addi	a5,a5,-1738 # ffffffffc0211478 <swap_init_ok>
ffffffffc0203b4a:	439c                	lw	a5,0(a5)
ffffffffc0203b4c:	2781                	sext.w	a5,a5
ffffffffc0203b4e:	c7bd                	beqz	a5,ffffffffc0203bbc <do_pgfault+0xc4>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);
ffffffffc0203b50:	85a2                	mv	a1,s0
ffffffffc0203b52:	0030                	addi	a2,sp,8
ffffffffc0203b54:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203b56:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0203b58:	c8aff0ef          	jal	ra,ffffffffc0202fe2 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203b5c:	65a2                	ld	a1,8(sp)
ffffffffc0203b5e:	6c88                	ld	a0,24(s1)
ffffffffc0203b60:	86ca                	mv	a3,s2
ffffffffc0203b62:	8622                	mv	a2,s0
ffffffffc0203b64:	ee7fd0ef          	jal	ra,ffffffffc0201a4a <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,0);
ffffffffc0203b68:	6622                	ld	a2,8(sp)
ffffffffc0203b6a:	4681                	li	a3,0
ffffffffc0203b6c:	85a2                	mv	a1,s0
ffffffffc0203b6e:	8526                	mv	a0,s1
ffffffffc0203b70:	b4eff0ef          	jal	ra,ffffffffc0202ebe <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203b74:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203b76:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203b78:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203b7a:	70a2                	ld	ra,40(sp)
ffffffffc0203b7c:	7402                	ld	s0,32(sp)
ffffffffc0203b7e:	64e2                	ld	s1,24(sp)
ffffffffc0203b80:	6942                	ld	s2,16(sp)
ffffffffc0203b82:	853e                	mv	a0,a5
ffffffffc0203b84:	6145                	addi	sp,sp,48
ffffffffc0203b86:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203b88:	4959                	li	s2,22
ffffffffc0203b8a:	b75d                	j	ffffffffc0203b30 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203b8c:	6c88                	ld	a0,24(s1)
ffffffffc0203b8e:	864a                	mv	a2,s2
ffffffffc0203b90:	85a2                	mv	a1,s0
ffffffffc0203b92:	a69fe0ef          	jal	ra,ffffffffc02025fa <pgdir_alloc_page>
   ret = 0;
ffffffffc0203b96:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203b98:	f16d                	bnez	a0,ffffffffc0203b7a <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203b9a:	00002517          	auipc	a0,0x2
ffffffffc0203b9e:	fc650513          	addi	a0,a0,-58 # ffffffffc0205b60 <default_pmm_manager+0xb68>
ffffffffc0203ba2:	d1cfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ba6:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203ba8:	bfc9                	j	ffffffffc0203b7a <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203baa:	85a2                	mv	a1,s0
ffffffffc0203bac:	00002517          	auipc	a0,0x2
ffffffffc0203bb0:	f8450513          	addi	a0,a0,-124 # ffffffffc0205b30 <default_pmm_manager+0xb38>
ffffffffc0203bb4:	d0afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203bb8:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203bba:	b7c1                	j	ffffffffc0203b7a <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203bbc:	00002517          	auipc	a0,0x2
ffffffffc0203bc0:	fcc50513          	addi	a0,a0,-52 # ffffffffc0205b88 <default_pmm_manager+0xb90>
ffffffffc0203bc4:	cfafc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203bc8:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203bca:	bf45                	j	ffffffffc0203b7a <do_pgfault+0x82>

ffffffffc0203bcc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bcc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bce:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bd0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bd2:	8c5fc0ef          	jal	ra,ffffffffc0200496 <ide_device_valid>
ffffffffc0203bd6:	cd01                	beqz	a0,ffffffffc0203bee <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bd8:	4505                	li	a0,1
ffffffffc0203bda:	8c3fc0ef          	jal	ra,ffffffffc020049c <ide_device_size>
}
ffffffffc0203bde:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203be0:	810d                	srli	a0,a0,0x3
ffffffffc0203be2:	0000e797          	auipc	a5,0xe
ffffffffc0203be6:	96a7b323          	sd	a0,-1690(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203bea:	0141                	addi	sp,sp,16
ffffffffc0203bec:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203bee:	00002617          	auipc	a2,0x2
ffffffffc0203bf2:	22a60613          	addi	a2,a2,554 # ffffffffc0205e18 <default_pmm_manager+0xe20>
ffffffffc0203bf6:	45b5                	li	a1,13
ffffffffc0203bf8:	00002517          	auipc	a0,0x2
ffffffffc0203bfc:	24050513          	addi	a0,a0,576 # ffffffffc0205e38 <default_pmm_manager+0xe40>
ffffffffc0203c00:	f70fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203c04 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c04:	1141                	addi	sp,sp,-16
ffffffffc0203c06:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c08:	00855793          	srli	a5,a0,0x8
ffffffffc0203c0c:	c7b5                	beqz	a5,ffffffffc0203c78 <swapfs_read+0x74>
ffffffffc0203c0e:	0000e717          	auipc	a4,0xe
ffffffffc0203c12:	93a70713          	addi	a4,a4,-1734 # ffffffffc0211548 <max_swap_offset>
ffffffffc0203c16:	6318                	ld	a4,0(a4)
ffffffffc0203c18:	06e7f063          	bgeu	a5,a4,ffffffffc0203c78 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c1c:	0000e717          	auipc	a4,0xe
ffffffffc0203c20:	89c70713          	addi	a4,a4,-1892 # ffffffffc02114b8 <pages>
ffffffffc0203c24:	6310                	ld	a2,0(a4)
ffffffffc0203c26:	00001717          	auipc	a4,0x1
ffffffffc0203c2a:	02270713          	addi	a4,a4,34 # ffffffffc0204c48 <commands+0x858>
ffffffffc0203c2e:	00002697          	auipc	a3,0x2
ffffffffc0203c32:	48a68693          	addi	a3,a3,1162 # ffffffffc02060b8 <nbase>
ffffffffc0203c36:	40c58633          	sub	a2,a1,a2
ffffffffc0203c3a:	630c                	ld	a1,0(a4)
ffffffffc0203c3c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c3e:	0000e717          	auipc	a4,0xe
ffffffffc0203c42:	82a70713          	addi	a4,a4,-2006 # ffffffffc0211468 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c46:	02b60633          	mul	a2,a2,a1
ffffffffc0203c4a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c4e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c50:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c52:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c54:	00c61793          	slli	a5,a2,0xc
ffffffffc0203c58:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c5a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c5c:	02e7fa63          	bgeu	a5,a4,ffffffffc0203c90 <swapfs_read+0x8c>
ffffffffc0203c60:	0000e797          	auipc	a5,0xe
ffffffffc0203c64:	84878793          	addi	a5,a5,-1976 # ffffffffc02114a8 <va_pa_offset>
ffffffffc0203c68:	639c                	ld	a5,0(a5)
}
ffffffffc0203c6a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c6c:	46a1                	li	a3,8
ffffffffc0203c6e:	963e                	add	a2,a2,a5
ffffffffc0203c70:	4505                	li	a0,1
}
ffffffffc0203c72:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c74:	82ffc06f          	j	ffffffffc02004a2 <ide_read_secs>
ffffffffc0203c78:	86aa                	mv	a3,a0
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	1d660613          	addi	a2,a2,470 # ffffffffc0205e50 <default_pmm_manager+0xe58>
ffffffffc0203c82:	45d1                	li	a1,20
ffffffffc0203c84:	00002517          	auipc	a0,0x2
ffffffffc0203c88:	1b450513          	addi	a0,a0,436 # ffffffffc0205e38 <default_pmm_manager+0xe40>
ffffffffc0203c8c:	ee4fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203c90:	86b2                	mv	a3,a2
ffffffffc0203c92:	06a00593          	li	a1,106
ffffffffc0203c96:	00001617          	auipc	a2,0x1
ffffffffc0203c9a:	3b260613          	addi	a2,a2,946 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0203c9e:	00001517          	auipc	a0,0x1
ffffffffc0203ca2:	44250513          	addi	a0,a0,1090 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0203ca6:	ecafc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203caa <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203caa:	1141                	addi	sp,sp,-16
ffffffffc0203cac:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cae:	00855793          	srli	a5,a0,0x8
ffffffffc0203cb2:	c7b5                	beqz	a5,ffffffffc0203d1e <swapfs_write+0x74>
ffffffffc0203cb4:	0000e717          	auipc	a4,0xe
ffffffffc0203cb8:	89470713          	addi	a4,a4,-1900 # ffffffffc0211548 <max_swap_offset>
ffffffffc0203cbc:	6318                	ld	a4,0(a4)
ffffffffc0203cbe:	06e7f063          	bgeu	a5,a4,ffffffffc0203d1e <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cc2:	0000d717          	auipc	a4,0xd
ffffffffc0203cc6:	7f670713          	addi	a4,a4,2038 # ffffffffc02114b8 <pages>
ffffffffc0203cca:	6310                	ld	a2,0(a4)
ffffffffc0203ccc:	00001717          	auipc	a4,0x1
ffffffffc0203cd0:	f7c70713          	addi	a4,a4,-132 # ffffffffc0204c48 <commands+0x858>
ffffffffc0203cd4:	00002697          	auipc	a3,0x2
ffffffffc0203cd8:	3e468693          	addi	a3,a3,996 # ffffffffc02060b8 <nbase>
ffffffffc0203cdc:	40c58633          	sub	a2,a1,a2
ffffffffc0203ce0:	630c                	ld	a1,0(a4)
ffffffffc0203ce2:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce4:	0000d717          	auipc	a4,0xd
ffffffffc0203ce8:	78470713          	addi	a4,a4,1924 # ffffffffc0211468 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cec:	02b60633          	mul	a2,a2,a1
ffffffffc0203cf0:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cf4:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf6:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cf8:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cfa:	00c61793          	slli	a5,a2,0xc
ffffffffc0203cfe:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d00:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d02:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d36 <swapfs_write+0x8c>
ffffffffc0203d06:	0000d797          	auipc	a5,0xd
ffffffffc0203d0a:	7a278793          	addi	a5,a5,1954 # ffffffffc02114a8 <va_pa_offset>
ffffffffc0203d0e:	639c                	ld	a5,0(a5)
}
ffffffffc0203d10:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d12:	46a1                	li	a3,8
ffffffffc0203d14:	963e                	add	a2,a2,a5
ffffffffc0203d16:	4505                	li	a0,1
}
ffffffffc0203d18:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d1a:	facfc06f          	j	ffffffffc02004c6 <ide_write_secs>
ffffffffc0203d1e:	86aa                	mv	a3,a0
ffffffffc0203d20:	00002617          	auipc	a2,0x2
ffffffffc0203d24:	13060613          	addi	a2,a2,304 # ffffffffc0205e50 <default_pmm_manager+0xe58>
ffffffffc0203d28:	45e5                	li	a1,25
ffffffffc0203d2a:	00002517          	auipc	a0,0x2
ffffffffc0203d2e:	10e50513          	addi	a0,a0,270 # ffffffffc0205e38 <default_pmm_manager+0xe40>
ffffffffc0203d32:	e3efc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203d36:	86b2                	mv	a3,a2
ffffffffc0203d38:	06a00593          	li	a1,106
ffffffffc0203d3c:	00001617          	auipc	a2,0x1
ffffffffc0203d40:	30c60613          	addi	a2,a2,780 # ffffffffc0205048 <default_pmm_manager+0x50>
ffffffffc0203d44:	00001517          	auipc	a0,0x1
ffffffffc0203d48:	39c50513          	addi	a0,a0,924 # ffffffffc02050e0 <default_pmm_manager+0xe8>
ffffffffc0203d4c:	e24fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203d50 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203d50:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d54:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203d56:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d5a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203d5c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d60:	f022                	sd	s0,32(sp)
ffffffffc0203d62:	ec26                	sd	s1,24(sp)
ffffffffc0203d64:	e84a                	sd	s2,16(sp)
ffffffffc0203d66:	f406                	sd	ra,40(sp)
ffffffffc0203d68:	e44e                	sd	s3,8(sp)
ffffffffc0203d6a:	84aa                	mv	s1,a0
ffffffffc0203d6c:	892e                	mv	s2,a1
ffffffffc0203d6e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203d72:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203d74:	03067e63          	bgeu	a2,a6,ffffffffc0203db0 <printnum+0x60>
ffffffffc0203d78:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203d7a:	00805763          	blez	s0,ffffffffc0203d88 <printnum+0x38>
ffffffffc0203d7e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203d80:	85ca                	mv	a1,s2
ffffffffc0203d82:	854e                	mv	a0,s3
ffffffffc0203d84:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203d86:	fc65                	bnez	s0,ffffffffc0203d7e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203d88:	1a02                	slli	s4,s4,0x20
ffffffffc0203d8a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203d8e:	00002797          	auipc	a5,0x2
ffffffffc0203d92:	27278793          	addi	a5,a5,626 # ffffffffc0206000 <error_string+0x38>
ffffffffc0203d96:	9a3e                	add	s4,s4,a5
}
ffffffffc0203d98:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203d9a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203d9e:	70a2                	ld	ra,40(sp)
ffffffffc0203da0:	69a2                	ld	s3,8(sp)
ffffffffc0203da2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203da4:	85ca                	mv	a1,s2
ffffffffc0203da6:	8326                	mv	t1,s1
}
ffffffffc0203da8:	6942                	ld	s2,16(sp)
ffffffffc0203daa:	64e2                	ld	s1,24(sp)
ffffffffc0203dac:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dae:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203db0:	03065633          	divu	a2,a2,a6
ffffffffc0203db4:	8722                	mv	a4,s0
ffffffffc0203db6:	f9bff0ef          	jal	ra,ffffffffc0203d50 <printnum>
ffffffffc0203dba:	b7f9                	j	ffffffffc0203d88 <printnum+0x38>

ffffffffc0203dbc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203dbc:	7119                	addi	sp,sp,-128
ffffffffc0203dbe:	f4a6                	sd	s1,104(sp)
ffffffffc0203dc0:	f0ca                	sd	s2,96(sp)
ffffffffc0203dc2:	e8d2                	sd	s4,80(sp)
ffffffffc0203dc4:	e4d6                	sd	s5,72(sp)
ffffffffc0203dc6:	e0da                	sd	s6,64(sp)
ffffffffc0203dc8:	fc5e                	sd	s7,56(sp)
ffffffffc0203dca:	f862                	sd	s8,48(sp)
ffffffffc0203dcc:	f06a                	sd	s10,32(sp)
ffffffffc0203dce:	fc86                	sd	ra,120(sp)
ffffffffc0203dd0:	f8a2                	sd	s0,112(sp)
ffffffffc0203dd2:	ecce                	sd	s3,88(sp)
ffffffffc0203dd4:	f466                	sd	s9,40(sp)
ffffffffc0203dd6:	ec6e                	sd	s11,24(sp)
ffffffffc0203dd8:	892a                	mv	s2,a0
ffffffffc0203dda:	84ae                	mv	s1,a1
ffffffffc0203ddc:	8d32                	mv	s10,a2
ffffffffc0203dde:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203de0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203de2:	00002a17          	auipc	s4,0x2
ffffffffc0203de6:	08ea0a13          	addi	s4,s4,142 # ffffffffc0205e70 <default_pmm_manager+0xe78>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203dea:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203dee:	00002c17          	auipc	s8,0x2
ffffffffc0203df2:	1dac0c13          	addi	s8,s8,474 # ffffffffc0205fc8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203df6:	000d4503          	lbu	a0,0(s10)
ffffffffc0203dfa:	02500793          	li	a5,37
ffffffffc0203dfe:	001d0413          	addi	s0,s10,1
ffffffffc0203e02:	00f50e63          	beq	a0,a5,ffffffffc0203e1e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e06:	c521                	beqz	a0,ffffffffc0203e4e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e08:	02500993          	li	s3,37
ffffffffc0203e0c:	a011                	j	ffffffffc0203e10 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e0e:	c121                	beqz	a0,ffffffffc0203e4e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e10:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e12:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e14:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e16:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e1a:	ff351ae3          	bne	a0,s3,ffffffffc0203e0e <vprintfmt+0x52>
ffffffffc0203e1e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e22:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e26:	4981                	li	s3,0
ffffffffc0203e28:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e2a:	5cfd                	li	s9,-1
ffffffffc0203e2c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e2e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e32:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e34:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203e38:	0ff6f693          	andi	a3,a3,255
ffffffffc0203e3c:	00140d13          	addi	s10,s0,1
ffffffffc0203e40:	1ed5ef63          	bltu	a1,a3,ffffffffc020403e <vprintfmt+0x282>
ffffffffc0203e44:	068a                	slli	a3,a3,0x2
ffffffffc0203e46:	96d2                	add	a3,a3,s4
ffffffffc0203e48:	4294                	lw	a3,0(a3)
ffffffffc0203e4a:	96d2                	add	a3,a3,s4
ffffffffc0203e4c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203e4e:	70e6                	ld	ra,120(sp)
ffffffffc0203e50:	7446                	ld	s0,112(sp)
ffffffffc0203e52:	74a6                	ld	s1,104(sp)
ffffffffc0203e54:	7906                	ld	s2,96(sp)
ffffffffc0203e56:	69e6                	ld	s3,88(sp)
ffffffffc0203e58:	6a46                	ld	s4,80(sp)
ffffffffc0203e5a:	6aa6                	ld	s5,72(sp)
ffffffffc0203e5c:	6b06                	ld	s6,64(sp)
ffffffffc0203e5e:	7be2                	ld	s7,56(sp)
ffffffffc0203e60:	7c42                	ld	s8,48(sp)
ffffffffc0203e62:	7ca2                	ld	s9,40(sp)
ffffffffc0203e64:	7d02                	ld	s10,32(sp)
ffffffffc0203e66:	6de2                	ld	s11,24(sp)
ffffffffc0203e68:	6109                	addi	sp,sp,128
ffffffffc0203e6a:	8082                	ret
            padc = '-';
ffffffffc0203e6c:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e6e:	00144603          	lbu	a2,1(s0)
ffffffffc0203e72:	846a                	mv	s0,s10
ffffffffc0203e74:	b7c1                	j	ffffffffc0203e34 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0203e76:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203e7a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203e7e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e80:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203e82:	fa0dd9e3          	bgez	s11,ffffffffc0203e34 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203e86:	8de6                	mv	s11,s9
ffffffffc0203e88:	5cfd                	li	s9,-1
ffffffffc0203e8a:	b76d                	j	ffffffffc0203e34 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0203e8c:	fffdc693          	not	a3,s11
ffffffffc0203e90:	96fd                	srai	a3,a3,0x3f
ffffffffc0203e92:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203e96:	00144603          	lbu	a2,1(s0)
ffffffffc0203e9a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e9c:	846a                	mv	s0,s10
ffffffffc0203e9e:	bf59                	j	ffffffffc0203e34 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203ea0:	4705                	li	a4,1
ffffffffc0203ea2:	008a8593          	addi	a1,s5,8
ffffffffc0203ea6:	01074463          	blt	a4,a6,ffffffffc0203eae <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0203eaa:	22080863          	beqz	a6,ffffffffc02040da <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0203eae:	000ab603          	ld	a2,0(s5)
ffffffffc0203eb2:	46c1                	li	a3,16
ffffffffc0203eb4:	8aae                	mv	s5,a1
ffffffffc0203eb6:	a291                	j	ffffffffc0203ffa <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0203eb8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203ebc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203ec2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203ec6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203eca:	fad56ce3          	bltu	a0,a3,ffffffffc0203e82 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203ece:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203ed0:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203ed4:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203ed8:	0196873b          	addw	a4,a3,s9
ffffffffc0203edc:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203ee0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203ee4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203ee8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203eec:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203ef0:	fcd57fe3          	bgeu	a0,a3,ffffffffc0203ece <vprintfmt+0x112>
ffffffffc0203ef4:	b779                	j	ffffffffc0203e82 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ef6:	000aa503          	lw	a0,0(s5)
ffffffffc0203efa:	85a6                	mv	a1,s1
ffffffffc0203efc:	0aa1                	addi	s5,s5,8
ffffffffc0203efe:	9902                	jalr	s2
            break;
ffffffffc0203f00:	bddd                	j	ffffffffc0203df6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f02:	4705                	li	a4,1
ffffffffc0203f04:	008a8993          	addi	s3,s5,8
ffffffffc0203f08:	01074463          	blt	a4,a6,ffffffffc0203f10 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0203f0c:	1c080463          	beqz	a6,ffffffffc02040d4 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0203f10:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f14:	1c044a63          	bltz	s0,ffffffffc02040e8 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0203f18:	8622                	mv	a2,s0
ffffffffc0203f1a:	8ace                	mv	s5,s3
ffffffffc0203f1c:	46a9                	li	a3,10
ffffffffc0203f1e:	a8f1                	j	ffffffffc0203ffa <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0203f20:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f24:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f26:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f28:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f2c:	8fb5                	xor	a5,a5,a3
ffffffffc0203f2e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f32:	12d74963          	blt	a4,a3,ffffffffc0204064 <vprintfmt+0x2a8>
ffffffffc0203f36:	00369793          	slli	a5,a3,0x3
ffffffffc0203f3a:	97e2                	add	a5,a5,s8
ffffffffc0203f3c:	639c                	ld	a5,0(a5)
ffffffffc0203f3e:	12078363          	beqz	a5,ffffffffc0204064 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f42:	86be                	mv	a3,a5
ffffffffc0203f44:	00002617          	auipc	a2,0x2
ffffffffc0203f48:	16c60613          	addi	a2,a2,364 # ffffffffc02060b0 <error_string+0xe8>
ffffffffc0203f4c:	85a6                	mv	a1,s1
ffffffffc0203f4e:	854a                	mv	a0,s2
ffffffffc0203f50:	1cc000ef          	jal	ra,ffffffffc020411c <printfmt>
ffffffffc0203f54:	b54d                	j	ffffffffc0203df6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f56:	000ab603          	ld	a2,0(s5)
ffffffffc0203f5a:	0aa1                	addi	s5,s5,8
ffffffffc0203f5c:	1a060163          	beqz	a2,ffffffffc02040fe <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0203f60:	00160413          	addi	s0,a2,1
ffffffffc0203f64:	15b05763          	blez	s11,ffffffffc02040b2 <vprintfmt+0x2f6>
ffffffffc0203f68:	02d00593          	li	a1,45
ffffffffc0203f6c:	10b79d63          	bne	a5,a1,ffffffffc0204086 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f70:	00064783          	lbu	a5,0(a2)
ffffffffc0203f74:	0007851b          	sext.w	a0,a5
ffffffffc0203f78:	c905                	beqz	a0,ffffffffc0203fa8 <vprintfmt+0x1ec>
ffffffffc0203f7a:	000cc563          	bltz	s9,ffffffffc0203f84 <vprintfmt+0x1c8>
ffffffffc0203f7e:	3cfd                	addiw	s9,s9,-1
ffffffffc0203f80:	036c8263          	beq	s9,s6,ffffffffc0203fa4 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0203f84:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f86:	14098f63          	beqz	s3,ffffffffc02040e4 <vprintfmt+0x328>
ffffffffc0203f8a:	3781                	addiw	a5,a5,-32
ffffffffc0203f8c:	14fbfc63          	bgeu	s7,a5,ffffffffc02040e4 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0203f90:	03f00513          	li	a0,63
ffffffffc0203f94:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f96:	0405                	addi	s0,s0,1
ffffffffc0203f98:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203f9c:	3dfd                	addiw	s11,s11,-1
ffffffffc0203f9e:	0007851b          	sext.w	a0,a5
ffffffffc0203fa2:	fd61                	bnez	a0,ffffffffc0203f7a <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0203fa4:	e5b059e3          	blez	s11,ffffffffc0203df6 <vprintfmt+0x3a>
ffffffffc0203fa8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203faa:	85a6                	mv	a1,s1
ffffffffc0203fac:	02000513          	li	a0,32
ffffffffc0203fb0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203fb2:	e40d82e3          	beqz	s11,ffffffffc0203df6 <vprintfmt+0x3a>
ffffffffc0203fb6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203fb8:	85a6                	mv	a1,s1
ffffffffc0203fba:	02000513          	li	a0,32
ffffffffc0203fbe:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203fc0:	fe0d94e3          	bnez	s11,ffffffffc0203fa8 <vprintfmt+0x1ec>
ffffffffc0203fc4:	bd0d                	j	ffffffffc0203df6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203fc6:	4705                	li	a4,1
ffffffffc0203fc8:	008a8593          	addi	a1,s5,8
ffffffffc0203fcc:	01074463          	blt	a4,a6,ffffffffc0203fd4 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0203fd0:	0e080863          	beqz	a6,ffffffffc02040c0 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0203fd4:	000ab603          	ld	a2,0(s5)
ffffffffc0203fd8:	46a1                	li	a3,8
ffffffffc0203fda:	8aae                	mv	s5,a1
ffffffffc0203fdc:	a839                	j	ffffffffc0203ffa <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0203fde:	03000513          	li	a0,48
ffffffffc0203fe2:	85a6                	mv	a1,s1
ffffffffc0203fe4:	e03e                	sd	a5,0(sp)
ffffffffc0203fe6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203fe8:	85a6                	mv	a1,s1
ffffffffc0203fea:	07800513          	li	a0,120
ffffffffc0203fee:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203ff0:	0aa1                	addi	s5,s5,8
ffffffffc0203ff2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203ff6:	6782                	ld	a5,0(sp)
ffffffffc0203ff8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203ffa:	2781                	sext.w	a5,a5
ffffffffc0203ffc:	876e                	mv	a4,s11
ffffffffc0203ffe:	85a6                	mv	a1,s1
ffffffffc0204000:	854a                	mv	a0,s2
ffffffffc0204002:	d4fff0ef          	jal	ra,ffffffffc0203d50 <printnum>
            break;
ffffffffc0204006:	bbc5                	j	ffffffffc0203df6 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204008:	00144603          	lbu	a2,1(s0)
ffffffffc020400c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020400e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204010:	b515                	j	ffffffffc0203e34 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204012:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204016:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204018:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020401a:	bd29                	j	ffffffffc0203e34 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020401c:	85a6                	mv	a1,s1
ffffffffc020401e:	02500513          	li	a0,37
ffffffffc0204022:	9902                	jalr	s2
            break;
ffffffffc0204024:	bbc9                	j	ffffffffc0203df6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204026:	4705                	li	a4,1
ffffffffc0204028:	008a8593          	addi	a1,s5,8
ffffffffc020402c:	01074463          	blt	a4,a6,ffffffffc0204034 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0204030:	08080d63          	beqz	a6,ffffffffc02040ca <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0204034:	000ab603          	ld	a2,0(s5)
ffffffffc0204038:	46a9                	li	a3,10
ffffffffc020403a:	8aae                	mv	s5,a1
ffffffffc020403c:	bf7d                	j	ffffffffc0203ffa <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc020403e:	85a6                	mv	a1,s1
ffffffffc0204040:	02500513          	li	a0,37
ffffffffc0204044:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204046:	fff44703          	lbu	a4,-1(s0)
ffffffffc020404a:	02500793          	li	a5,37
ffffffffc020404e:	8d22                	mv	s10,s0
ffffffffc0204050:	daf703e3          	beq	a4,a5,ffffffffc0203df6 <vprintfmt+0x3a>
ffffffffc0204054:	02500713          	li	a4,37
ffffffffc0204058:	1d7d                	addi	s10,s10,-1
ffffffffc020405a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020405e:	fee79de3          	bne	a5,a4,ffffffffc0204058 <vprintfmt+0x29c>
ffffffffc0204062:	bb51                	j	ffffffffc0203df6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204064:	00002617          	auipc	a2,0x2
ffffffffc0204068:	03c60613          	addi	a2,a2,60 # ffffffffc02060a0 <error_string+0xd8>
ffffffffc020406c:	85a6                	mv	a1,s1
ffffffffc020406e:	854a                	mv	a0,s2
ffffffffc0204070:	0ac000ef          	jal	ra,ffffffffc020411c <printfmt>
ffffffffc0204074:	b349                	j	ffffffffc0203df6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204076:	00002617          	auipc	a2,0x2
ffffffffc020407a:	02260613          	addi	a2,a2,34 # ffffffffc0206098 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020407e:	00002417          	auipc	s0,0x2
ffffffffc0204082:	01b40413          	addi	s0,s0,27 # ffffffffc0206099 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204086:	8532                	mv	a0,a2
ffffffffc0204088:	85e6                	mv	a1,s9
ffffffffc020408a:	e032                	sd	a2,0(sp)
ffffffffc020408c:	e43e                	sd	a5,8(sp)
ffffffffc020408e:	18a000ef          	jal	ra,ffffffffc0204218 <strnlen>
ffffffffc0204092:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204096:	6602                	ld	a2,0(sp)
ffffffffc0204098:	01b05d63          	blez	s11,ffffffffc02040b2 <vprintfmt+0x2f6>
ffffffffc020409c:	67a2                	ld	a5,8(sp)
ffffffffc020409e:	2781                	sext.w	a5,a5
ffffffffc02040a0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02040a2:	6522                	ld	a0,8(sp)
ffffffffc02040a4:	85a6                	mv	a1,s1
ffffffffc02040a6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040a8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02040aa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040ac:	6602                	ld	a2,0(sp)
ffffffffc02040ae:	fe0d9ae3          	bnez	s11,ffffffffc02040a2 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02040b2:	00064783          	lbu	a5,0(a2)
ffffffffc02040b6:	0007851b          	sext.w	a0,a5
ffffffffc02040ba:	ec0510e3          	bnez	a0,ffffffffc0203f7a <vprintfmt+0x1be>
ffffffffc02040be:	bb25                	j	ffffffffc0203df6 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc02040c0:	000ae603          	lwu	a2,0(s5)
ffffffffc02040c4:	46a1                	li	a3,8
ffffffffc02040c6:	8aae                	mv	s5,a1
ffffffffc02040c8:	bf0d                	j	ffffffffc0203ffa <vprintfmt+0x23e>
ffffffffc02040ca:	000ae603          	lwu	a2,0(s5)
ffffffffc02040ce:	46a9                	li	a3,10
ffffffffc02040d0:	8aae                	mv	s5,a1
ffffffffc02040d2:	b725                	j	ffffffffc0203ffa <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc02040d4:	000aa403          	lw	s0,0(s5)
ffffffffc02040d8:	bd35                	j	ffffffffc0203f14 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02040da:	000ae603          	lwu	a2,0(s5)
ffffffffc02040de:	46c1                	li	a3,16
ffffffffc02040e0:	8aae                	mv	s5,a1
ffffffffc02040e2:	bf21                	j	ffffffffc0203ffa <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02040e4:	9902                	jalr	s2
ffffffffc02040e6:	bd45                	j	ffffffffc0203f96 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02040e8:	85a6                	mv	a1,s1
ffffffffc02040ea:	02d00513          	li	a0,45
ffffffffc02040ee:	e03e                	sd	a5,0(sp)
ffffffffc02040f0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02040f2:	8ace                	mv	s5,s3
ffffffffc02040f4:	40800633          	neg	a2,s0
ffffffffc02040f8:	46a9                	li	a3,10
ffffffffc02040fa:	6782                	ld	a5,0(sp)
ffffffffc02040fc:	bdfd                	j	ffffffffc0203ffa <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02040fe:	01b05663          	blez	s11,ffffffffc020410a <vprintfmt+0x34e>
ffffffffc0204102:	02d00693          	li	a3,45
ffffffffc0204106:	f6d798e3          	bne	a5,a3,ffffffffc0204076 <vprintfmt+0x2ba>
ffffffffc020410a:	00002417          	auipc	s0,0x2
ffffffffc020410e:	f8f40413          	addi	s0,s0,-113 # ffffffffc0206099 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204112:	02800513          	li	a0,40
ffffffffc0204116:	02800793          	li	a5,40
ffffffffc020411a:	b585                	j	ffffffffc0203f7a <vprintfmt+0x1be>

ffffffffc020411c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020411c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020411e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204122:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204124:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204126:	ec06                	sd	ra,24(sp)
ffffffffc0204128:	f83a                	sd	a4,48(sp)
ffffffffc020412a:	fc3e                	sd	a5,56(sp)
ffffffffc020412c:	e0c2                	sd	a6,64(sp)
ffffffffc020412e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204130:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204132:	c8bff0ef          	jal	ra,ffffffffc0203dbc <vprintfmt>
}
ffffffffc0204136:	60e2                	ld	ra,24(sp)
ffffffffc0204138:	6161                	addi	sp,sp,80
ffffffffc020413a:	8082                	ret

ffffffffc020413c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020413c:	715d                	addi	sp,sp,-80
ffffffffc020413e:	e486                	sd	ra,72(sp)
ffffffffc0204140:	e0a2                	sd	s0,64(sp)
ffffffffc0204142:	fc26                	sd	s1,56(sp)
ffffffffc0204144:	f84a                	sd	s2,48(sp)
ffffffffc0204146:	f44e                	sd	s3,40(sp)
ffffffffc0204148:	f052                	sd	s4,32(sp)
ffffffffc020414a:	ec56                	sd	s5,24(sp)
ffffffffc020414c:	e85a                	sd	s6,16(sp)
ffffffffc020414e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0204150:	c901                	beqz	a0,ffffffffc0204160 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0204152:	85aa                	mv	a1,a0
ffffffffc0204154:	00002517          	auipc	a0,0x2
ffffffffc0204158:	f5c50513          	addi	a0,a0,-164 # ffffffffc02060b0 <error_string+0xe8>
ffffffffc020415c:	f63fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0204160:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204162:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204164:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204166:	4aa9                	li	s5,10
ffffffffc0204168:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020416a:	0000db97          	auipc	s7,0xd
ffffffffc020416e:	ed6b8b93          	addi	s7,s7,-298 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204172:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204176:	f7ffb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc020417a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020417c:	00054b63          	bltz	a0,ffffffffc0204192 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204180:	00a95b63          	bge	s2,a0,ffffffffc0204196 <readline+0x5a>
ffffffffc0204184:	029a5463          	bge	s4,s1,ffffffffc02041ac <readline+0x70>
        c = getchar();
ffffffffc0204188:	f6dfb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc020418c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020418e:	fe0559e3          	bgez	a0,ffffffffc0204180 <readline+0x44>
            return NULL;
ffffffffc0204192:	4501                	li	a0,0
ffffffffc0204194:	a099                	j	ffffffffc02041da <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204196:	03341463          	bne	s0,s3,ffffffffc02041be <readline+0x82>
ffffffffc020419a:	e8b9                	bnez	s1,ffffffffc02041f0 <readline+0xb4>
        c = getchar();
ffffffffc020419c:	f59fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc02041a0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041a2:	fe0548e3          	bltz	a0,ffffffffc0204192 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041a6:	fea958e3          	bge	s2,a0,ffffffffc0204196 <readline+0x5a>
ffffffffc02041aa:	4481                	li	s1,0
            cputchar(c);
ffffffffc02041ac:	8522                	mv	a0,s0
ffffffffc02041ae:	f45fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02041b2:	009b87b3          	add	a5,s7,s1
ffffffffc02041b6:	00878023          	sb	s0,0(a5)
ffffffffc02041ba:	2485                	addiw	s1,s1,1
ffffffffc02041bc:	bf6d                	j	ffffffffc0204176 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02041be:	01540463          	beq	s0,s5,ffffffffc02041c6 <readline+0x8a>
ffffffffc02041c2:	fb641ae3          	bne	s0,s6,ffffffffc0204176 <readline+0x3a>
            cputchar(c);
ffffffffc02041c6:	8522                	mv	a0,s0
ffffffffc02041c8:	f2bfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc02041cc:	0000d517          	auipc	a0,0xd
ffffffffc02041d0:	e7450513          	addi	a0,a0,-396 # ffffffffc0211040 <buf>
ffffffffc02041d4:	94aa                	add	s1,s1,a0
ffffffffc02041d6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02041da:	60a6                	ld	ra,72(sp)
ffffffffc02041dc:	6406                	ld	s0,64(sp)
ffffffffc02041de:	74e2                	ld	s1,56(sp)
ffffffffc02041e0:	7942                	ld	s2,48(sp)
ffffffffc02041e2:	79a2                	ld	s3,40(sp)
ffffffffc02041e4:	7a02                	ld	s4,32(sp)
ffffffffc02041e6:	6ae2                	ld	s5,24(sp)
ffffffffc02041e8:	6b42                	ld	s6,16(sp)
ffffffffc02041ea:	6ba2                	ld	s7,8(sp)
ffffffffc02041ec:	6161                	addi	sp,sp,80
ffffffffc02041ee:	8082                	ret
            cputchar(c);
ffffffffc02041f0:	4521                	li	a0,8
ffffffffc02041f2:	f01fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc02041f6:	34fd                	addiw	s1,s1,-1
ffffffffc02041f8:	bfbd                	j	ffffffffc0204176 <readline+0x3a>

ffffffffc02041fa <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02041fa:	00054783          	lbu	a5,0(a0)
ffffffffc02041fe:	cb91                	beqz	a5,ffffffffc0204212 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204200:	4781                	li	a5,0
        cnt ++;
ffffffffc0204202:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204204:	00f50733          	add	a4,a0,a5
ffffffffc0204208:	00074703          	lbu	a4,0(a4)
ffffffffc020420c:	fb7d                	bnez	a4,ffffffffc0204202 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020420e:	853e                	mv	a0,a5
ffffffffc0204210:	8082                	ret
    size_t cnt = 0;
ffffffffc0204212:	4781                	li	a5,0
}
ffffffffc0204214:	853e                	mv	a0,a5
ffffffffc0204216:	8082                	ret

ffffffffc0204218 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204218:	c185                	beqz	a1,ffffffffc0204238 <strnlen+0x20>
ffffffffc020421a:	00054783          	lbu	a5,0(a0)
ffffffffc020421e:	cf89                	beqz	a5,ffffffffc0204238 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204220:	4781                	li	a5,0
ffffffffc0204222:	a021                	j	ffffffffc020422a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204224:	00074703          	lbu	a4,0(a4)
ffffffffc0204228:	c711                	beqz	a4,ffffffffc0204234 <strnlen+0x1c>
        cnt ++;
ffffffffc020422a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020422c:	00f50733          	add	a4,a0,a5
ffffffffc0204230:	fef59ae3          	bne	a1,a5,ffffffffc0204224 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204234:	853e                	mv	a0,a5
ffffffffc0204236:	8082                	ret
    size_t cnt = 0;
ffffffffc0204238:	4781                	li	a5,0
}
ffffffffc020423a:	853e                	mv	a0,a5
ffffffffc020423c:	8082                	ret

ffffffffc020423e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020423e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204240:	0585                	addi	a1,a1,1
ffffffffc0204242:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204246:	0785                	addi	a5,a5,1
ffffffffc0204248:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020424c:	fb75                	bnez	a4,ffffffffc0204240 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020424e:	8082                	ret

ffffffffc0204250 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204250:	00054783          	lbu	a5,0(a0)
ffffffffc0204254:	0005c703          	lbu	a4,0(a1)
ffffffffc0204258:	cb91                	beqz	a5,ffffffffc020426c <strcmp+0x1c>
ffffffffc020425a:	00e79c63          	bne	a5,a4,ffffffffc0204272 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020425e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204260:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204264:	0585                	addi	a1,a1,1
ffffffffc0204266:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020426a:	fbe5                	bnez	a5,ffffffffc020425a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020426c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020426e:	9d19                	subw	a0,a0,a4
ffffffffc0204270:	8082                	ret
ffffffffc0204272:	0007851b          	sext.w	a0,a5
ffffffffc0204276:	9d19                	subw	a0,a0,a4
ffffffffc0204278:	8082                	ret

ffffffffc020427a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020427a:	00054783          	lbu	a5,0(a0)
ffffffffc020427e:	cb91                	beqz	a5,ffffffffc0204292 <strchr+0x18>
        if (*s == c) {
ffffffffc0204280:	00b79563          	bne	a5,a1,ffffffffc020428a <strchr+0x10>
ffffffffc0204284:	a809                	j	ffffffffc0204296 <strchr+0x1c>
ffffffffc0204286:	00b78763          	beq	a5,a1,ffffffffc0204294 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020428a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020428c:	00054783          	lbu	a5,0(a0)
ffffffffc0204290:	fbfd                	bnez	a5,ffffffffc0204286 <strchr+0xc>
    }
    return NULL;
ffffffffc0204292:	4501                	li	a0,0
}
ffffffffc0204294:	8082                	ret
ffffffffc0204296:	8082                	ret

ffffffffc0204298 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204298:	ca01                	beqz	a2,ffffffffc02042a8 <memset+0x10>
ffffffffc020429a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020429c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020429e:	0785                	addi	a5,a5,1
ffffffffc02042a0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02042a4:	fec79de3          	bne	a5,a2,ffffffffc020429e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02042a8:	8082                	ret

ffffffffc02042aa <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02042aa:	ca19                	beqz	a2,ffffffffc02042c0 <memcpy+0x16>
ffffffffc02042ac:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02042ae:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02042b0:	0585                	addi	a1,a1,1
ffffffffc02042b2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042b6:	0785                	addi	a5,a5,1
ffffffffc02042b8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02042bc:	fec59ae3          	bne	a1,a2,ffffffffc02042b0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02042c0:	8082                	ret

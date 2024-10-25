
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	506010ef          	jal	ra,ffffffffc0201550 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201a70 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	0fb000ef          	jal	ra,ffffffffc0200960 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	528010ef          	jal	ra,ffffffffc02015ce <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	4f2010ef          	jal	ra,ffffffffc02015ce <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	2f630313          	addi	t1,t1,758 # ffffffffc0206430 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	92850513          	addi	a0,a0,-1752 # ffffffffc0201a90 <etext+0x22>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201b78 <etext+0x10a>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
    while (1) {
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00002517          	auipc	a0,0x2
ffffffffc020019c:	91850513          	addi	a0,a0,-1768 # ffffffffc0201ab0 <etext+0x42>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00002517          	auipc	a0,0x2
ffffffffc02001b2:	92250513          	addi	a0,a0,-1758 # ffffffffc0201ad0 <etext+0x62>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00002597          	auipc	a1,0x2
ffffffffc02001be:	8b458593          	addi	a1,a1,-1868 # ffffffffc0201a6e <etext>
ffffffffc02001c2:	00002517          	auipc	a0,0x2
ffffffffc02001c6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201af0 <etext+0x82>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4a58593          	addi	a1,a1,-438 # ffffffffc0206018 <free_area>
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201b10 <etext+0xa2>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	2a658593          	addi	a1,a1,678 # ffffffffc0206488 <end>
ffffffffc02001ea:	00002517          	auipc	a0,0x2
ffffffffc02001ee:	94650513          	addi	a0,a0,-1722 # ffffffffc0201b30 <etext+0xc2>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	69158593          	addi	a1,a1,1681 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	93850513          	addi	a0,a0,-1736 # ffffffffc0201b50 <etext+0xe2>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	95a60613          	addi	a2,a2,-1702 # ffffffffc0201b80 <etext+0x112>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	96650513          	addi	a0,a0,-1690 # ffffffffc0201b98 <etext+0x12a>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00002617          	auipc	a2,0x2
ffffffffc0200246:	96e60613          	addi	a2,a2,-1682 # ffffffffc0201bb0 <etext+0x142>
ffffffffc020024a:	00002597          	auipc	a1,0x2
ffffffffc020024e:	98658593          	addi	a1,a1,-1658 # ffffffffc0201bd0 <etext+0x162>
ffffffffc0200252:	00002517          	auipc	a0,0x2
ffffffffc0200256:	98650513          	addi	a0,a0,-1658 # ffffffffc0201bd8 <etext+0x16a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00002617          	auipc	a2,0x2
ffffffffc0200264:	98860613          	addi	a2,a2,-1656 # ffffffffc0201be8 <etext+0x17a>
ffffffffc0200268:	00002597          	auipc	a1,0x2
ffffffffc020026c:	9a858593          	addi	a1,a1,-1624 # ffffffffc0201c10 <etext+0x1a2>
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	96850513          	addi	a0,a0,-1688 # ffffffffc0201bd8 <etext+0x16a>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00002617          	auipc	a2,0x2
ffffffffc0200280:	9a460613          	addi	a2,a2,-1628 # ffffffffc0201c20 <etext+0x1b2>
ffffffffc0200284:	00002597          	auipc	a1,0x2
ffffffffc0200288:	9bc58593          	addi	a1,a1,-1604 # ffffffffc0201c40 <etext+0x1d2>
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201bd8 <etext+0x16a>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    return 0;
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
    return 0;
}
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c6:	00002517          	auipc	a0,0x2
ffffffffc02002ca:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201c50 <etext+0x1e2>
kmonitor(struct trapframe *tf) {
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e8:	00002517          	auipc	a0,0x2
ffffffffc02002ec:	99050513          	addi	a0,a0,-1648 # ffffffffc0201c78 <etext+0x20a>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00002c17          	auipc	s8,0x2
ffffffffc0200302:	9eac0c13          	addi	s8,s8,-1558 # ffffffffc0201ce8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00002917          	auipc	s2,0x2
ffffffffc020030a:	99a90913          	addi	s2,s2,-1638 # ffffffffc0201ca0 <etext+0x232>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00002497          	auipc	s1,0x2
ffffffffc0200312:	99a48493          	addi	s1,s1,-1638 # ffffffffc0201ca8 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00002b17          	auipc	s6,0x2
ffffffffc020031c:	998b0b13          	addi	s6,s6,-1640 # ffffffffc0201cb0 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc0200320:	00002a17          	auipc	s4,0x2
ffffffffc0200324:	8b0a0a13          	addi	s4,s4,-1872 # ffffffffc0201bd0 <etext+0x162>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	624010ef          	jal	ra,ffffffffc0201950 <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200338:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00002d17          	auipc	s10,0x2
ffffffffc0200346:	9a6d0d13          	addi	s10,s10,-1626 # ffffffffc0201ce8 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	1cc010ef          	jal	ra,ffffffffc020151c <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200362:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	1b8010ef          	jal	ra,ffffffffc020151c <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
}
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	198010ef          	jal	ra,ffffffffc020153a <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	15a010ef          	jal	ra,ffffffffc020153a <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201cd0 <etext+0x262>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	5fe010ef          	jal	ra,ffffffffc0201a1e <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	90250513          	addi	a0,a0,-1790 # ffffffffc0201d30 <commands+0x48>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5d80106f          	j	ffffffffc0201a1e <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	5b40106f          	j	ffffffffc0201a04 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5e40106f          	j	ffffffffc0201a38 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	38c78793          	addi	a5,a5,908 # ffffffffc02007f4 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201d50 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201d68 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201d80 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201d98 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201db0 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	90250513          	addi	a0,a0,-1790 # ffffffffc0201dc8 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201de0 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	91650513          	addi	a0,a0,-1770 # ffffffffc0201df8 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	92050513          	addi	a0,a0,-1760 # ffffffffc0201e10 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201e28 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	93450513          	addi	a0,a0,-1740 # ffffffffc0201e40 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201e58 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	94850513          	addi	a0,a0,-1720 # ffffffffc0201e70 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	95250513          	addi	a0,a0,-1710 # ffffffffc0201e88 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	95c50513          	addi	a0,a0,-1700 # ffffffffc0201ea0 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	96650513          	addi	a0,a0,-1690 # ffffffffc0201eb8 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	97050513          	addi	a0,a0,-1680 # ffffffffc0201ed0 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201ee8 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	98450513          	addi	a0,a0,-1660 # ffffffffc0201f00 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201f18 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	99850513          	addi	a0,a0,-1640 # ffffffffc0201f30 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201f48 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0201f60 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0201f78 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9c050513          	addi	a0,a0,-1600 # ffffffffc0201f90 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201fa8 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9d450513          	addi	a0,a0,-1580 # ffffffffc0201fc0 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9de50513          	addi	a0,a0,-1570 # ffffffffc0201fd8 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0201ff0 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0202008 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0202020 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0202038 <commands+0x350>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202050 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202068 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202080 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202098 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02020b0 <commands+0x3c8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	08f76663          	bltu	a4,a5,ffffffffc0200738 <interrupt_handler+0x96>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	ae070713          	addi	a4,a4,-1312 # ffffffffc0202190 <commands+0x4a8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0202128 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0202108 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	9f250513          	addi	a0,a0,-1550 # ffffffffc02020c8 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202148 <commands+0x460>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e022                	sd	s0,0(sp)
ffffffffc02006ee:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006f0:	d4bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            static int ticks = 0;
            ticks++;
ffffffffc02006f4:	00006697          	auipc	a3,0x6
ffffffffc02006f8:	d5468693          	addi	a3,a3,-684 # ffffffffc0206448 <ticks.0>
ffffffffc02006fc:	429c                	lw	a5,0(a3)
            if (ticks % TICK_NUM == 0){
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d3e40413          	addi	s0,s0,-706 # ffffffffc0206440 <num>
            ticks++;
ffffffffc020070a:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
ffffffffc020070c:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200710:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0){
ffffffffc0200712:	c705                	beqz	a4,ffffffffc020073a <interrupt_handler+0x98>
            num++;
            print_ticks();
            }
            
            if (num == 10){
ffffffffc0200714:	6018                	ld	a4,0(s0)
ffffffffc0200716:	47a9                	li	a5,10
ffffffffc0200718:	02f70d63          	beq	a4,a5,ffffffffc0200752 <interrupt_handler+0xb0>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020071c:	60a2                	ld	ra,8(sp)
ffffffffc020071e:	6402                	ld	s0,0(sp)
ffffffffc0200720:	0141                	addi	sp,sp,16
ffffffffc0200722:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200724:	00002517          	auipc	a0,0x2
ffffffffc0200728:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0202170 <commands+0x488>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00002517          	auipc	a0,0x2
ffffffffc0200732:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02020e8 <commands+0x400>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc020073a:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073c:	06400593          	li	a1,100
ffffffffc0200740:	00002517          	auipc	a0,0x2
ffffffffc0200744:	a2050513          	addi	a0,a0,-1504 # ffffffffc0202160 <commands+0x478>
            num++;
ffffffffc0200748:	0785                	addi	a5,a5,1
ffffffffc020074a:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074c:	967ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200750:	b7d1                	j	ffffffffc0200714 <interrupt_handler+0x72>
}
ffffffffc0200752:	6402                	ld	s0,0(sp)
ffffffffc0200754:	60a2                	ld	ra,8(sp)
ffffffffc0200756:	0141                	addi	sp,sp,16
            sbi_shutdown();
ffffffffc0200758:	2fc0106f          	j	ffffffffc0201a54 <sbi_shutdown>

ffffffffc020075c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc020075c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200760:	1141                	addi	sp,sp,-16
ffffffffc0200762:	e022                	sd	s0,0(sp)
ffffffffc0200764:	e406                	sd	ra,8(sp)
ffffffffc0200766:	472d                	li	a4,11
ffffffffc0200768:	842a                	mv	s0,a0
ffffffffc020076a:	04f76263          	bltu	a4,a5,ffffffffc02007ae <exception_handler+0x52>
ffffffffc020076e:	00002717          	auipc	a4,0x2
ffffffffc0200772:	ada70713          	addi	a4,a4,-1318 # ffffffffc0202248 <commands+0x560>
ffffffffc0200776:	078a                	slli	a5,a5,0x2
ffffffffc0200778:	97ba                	add	a5,a5,a4
ffffffffc020077a:	439c                	lw	a5,0(a5)
ffffffffc020077c:	97ba                	add	a5,a5,a4
ffffffffc020077e:	8782                	jr	a5
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
           cprintf("Exception type:Illegal instruction\n");
ffffffffc0200780:	00002517          	auipc	a0,0x2
ffffffffc0200784:	a4050513          	addi	a0,a0,-1472 # ffffffffc02021c0 <commands+0x4d8>
ffffffffc0200788:	92bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc020078c:	10843583          	ld	a1,264(s0)
ffffffffc0200790:	00002517          	auipc	a0,0x2
ffffffffc0200794:	a5850513          	addi	a0,a0,-1448 # ffffffffc02021e8 <commands+0x500>
ffffffffc0200798:	91bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           tf->epc += 4;
ffffffffc020079c:	10843783          	ld	a5,264(s0)
ffffffffc02007a0:	0791                	addi	a5,a5,4
ffffffffc02007a2:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02007a6:	60a2                	ld	ra,8(sp)
ffffffffc02007a8:	6402                	ld	s0,0(sp)
ffffffffc02007aa:	0141                	addi	sp,sp,16
ffffffffc02007ac:	8082                	ret
            print_trapframe(tf);
ffffffffc02007ae:	8522                	mv	a0,s0
}
ffffffffc02007b0:	6402                	ld	s0,0(sp)
ffffffffc02007b2:	60a2                	ld	ra,8(sp)
ffffffffc02007b4:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007b6:	b571                	j	ffffffffc0200642 <print_trapframe>
           cprintf("Exception type: breakpoint\n");
ffffffffc02007b8:	00002517          	auipc	a0,0x2
ffffffffc02007bc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0202210 <commands+0x528>
ffffffffc02007c0:	8f3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007c4:	10843583          	ld	a1,264(s0)
ffffffffc02007c8:	00002517          	auipc	a0,0x2
ffffffffc02007cc:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202230 <commands+0x548>
ffffffffc02007d0:	8e3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           tf->epc += 2;
ffffffffc02007d4:	10843783          	ld	a5,264(s0)
}
ffffffffc02007d8:	60a2                	ld	ra,8(sp)
           tf->epc += 2;
ffffffffc02007da:	0789                	addi	a5,a5,2
ffffffffc02007dc:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007e0:	6402                	ld	s0,0(sp)
ffffffffc02007e2:	0141                	addi	sp,sp,16
ffffffffc02007e4:	8082                	ret

ffffffffc02007e6 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007e6:	11853783          	ld	a5,280(a0)
ffffffffc02007ea:	0007c363          	bltz	a5,ffffffffc02007f0 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007ee:	b7bd                	j	ffffffffc020075c <exception_handler>
        interrupt_handler(tf);
ffffffffc02007f0:	bd4d                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc02007f4 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007f4:	14011073          	csrw	sscratch,sp
ffffffffc02007f8:	712d                	addi	sp,sp,-288
ffffffffc02007fa:	e002                	sd	zero,0(sp)
ffffffffc02007fc:	e406                	sd	ra,8(sp)
ffffffffc02007fe:	ec0e                	sd	gp,24(sp)
ffffffffc0200800:	f012                	sd	tp,32(sp)
ffffffffc0200802:	f416                	sd	t0,40(sp)
ffffffffc0200804:	f81a                	sd	t1,48(sp)
ffffffffc0200806:	fc1e                	sd	t2,56(sp)
ffffffffc0200808:	e0a2                	sd	s0,64(sp)
ffffffffc020080a:	e4a6                	sd	s1,72(sp)
ffffffffc020080c:	e8aa                	sd	a0,80(sp)
ffffffffc020080e:	ecae                	sd	a1,88(sp)
ffffffffc0200810:	f0b2                	sd	a2,96(sp)
ffffffffc0200812:	f4b6                	sd	a3,104(sp)
ffffffffc0200814:	f8ba                	sd	a4,112(sp)
ffffffffc0200816:	fcbe                	sd	a5,120(sp)
ffffffffc0200818:	e142                	sd	a6,128(sp)
ffffffffc020081a:	e546                	sd	a7,136(sp)
ffffffffc020081c:	e94a                	sd	s2,144(sp)
ffffffffc020081e:	ed4e                	sd	s3,152(sp)
ffffffffc0200820:	f152                	sd	s4,160(sp)
ffffffffc0200822:	f556                	sd	s5,168(sp)
ffffffffc0200824:	f95a                	sd	s6,176(sp)
ffffffffc0200826:	fd5e                	sd	s7,184(sp)
ffffffffc0200828:	e1e2                	sd	s8,192(sp)
ffffffffc020082a:	e5e6                	sd	s9,200(sp)
ffffffffc020082c:	e9ea                	sd	s10,208(sp)
ffffffffc020082e:	edee                	sd	s11,216(sp)
ffffffffc0200830:	f1f2                	sd	t3,224(sp)
ffffffffc0200832:	f5f6                	sd	t4,232(sp)
ffffffffc0200834:	f9fa                	sd	t5,240(sp)
ffffffffc0200836:	fdfe                	sd	t6,248(sp)
ffffffffc0200838:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020083c:	100024f3          	csrr	s1,sstatus
ffffffffc0200840:	14102973          	csrr	s2,sepc
ffffffffc0200844:	143029f3          	csrr	s3,stval
ffffffffc0200848:	14202a73          	csrr	s4,scause
ffffffffc020084c:	e822                	sd	s0,16(sp)
ffffffffc020084e:	e226                	sd	s1,256(sp)
ffffffffc0200850:	e64a                	sd	s2,264(sp)
ffffffffc0200852:	ea4e                	sd	s3,272(sp)
ffffffffc0200854:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200856:	850a                	mv	a0,sp
    jal trap
ffffffffc0200858:	f8fff0ef          	jal	ra,ffffffffc02007e6 <trap>

ffffffffc020085c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc020085c:	6492                	ld	s1,256(sp)
ffffffffc020085e:	6932                	ld	s2,264(sp)
ffffffffc0200860:	10049073          	csrw	sstatus,s1
ffffffffc0200864:	14191073          	csrw	sepc,s2
ffffffffc0200868:	60a2                	ld	ra,8(sp)
ffffffffc020086a:	61e2                	ld	gp,24(sp)
ffffffffc020086c:	7202                	ld	tp,32(sp)
ffffffffc020086e:	72a2                	ld	t0,40(sp)
ffffffffc0200870:	7342                	ld	t1,48(sp)
ffffffffc0200872:	73e2                	ld	t2,56(sp)
ffffffffc0200874:	6406                	ld	s0,64(sp)
ffffffffc0200876:	64a6                	ld	s1,72(sp)
ffffffffc0200878:	6546                	ld	a0,80(sp)
ffffffffc020087a:	65e6                	ld	a1,88(sp)
ffffffffc020087c:	7606                	ld	a2,96(sp)
ffffffffc020087e:	76a6                	ld	a3,104(sp)
ffffffffc0200880:	7746                	ld	a4,112(sp)
ffffffffc0200882:	77e6                	ld	a5,120(sp)
ffffffffc0200884:	680a                	ld	a6,128(sp)
ffffffffc0200886:	68aa                	ld	a7,136(sp)
ffffffffc0200888:	694a                	ld	s2,144(sp)
ffffffffc020088a:	69ea                	ld	s3,152(sp)
ffffffffc020088c:	7a0a                	ld	s4,160(sp)
ffffffffc020088e:	7aaa                	ld	s5,168(sp)
ffffffffc0200890:	7b4a                	ld	s6,176(sp)
ffffffffc0200892:	7bea                	ld	s7,184(sp)
ffffffffc0200894:	6c0e                	ld	s8,192(sp)
ffffffffc0200896:	6cae                	ld	s9,200(sp)
ffffffffc0200898:	6d4e                	ld	s10,208(sp)
ffffffffc020089a:	6dee                	ld	s11,216(sp)
ffffffffc020089c:	7e0e                	ld	t3,224(sp)
ffffffffc020089e:	7eae                	ld	t4,232(sp)
ffffffffc02008a0:	7f4e                	ld	t5,240(sp)
ffffffffc02008a2:	7fee                	ld	t6,248(sp)
ffffffffc02008a4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008a6:	10200073          	sret

ffffffffc02008aa <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008aa:	100027f3          	csrr	a5,sstatus
ffffffffc02008ae:	8b89                	andi	a5,a5,2
ffffffffc02008b0:	e799                	bnez	a5,ffffffffc02008be <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02008b2:	00006797          	auipc	a5,0x6
ffffffffc02008b6:	bae7b783          	ld	a5,-1106(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02008ba:	6f9c                	ld	a5,24(a5)
ffffffffc02008bc:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02008be:	1141                	addi	sp,sp,-16
ffffffffc02008c0:	e406                	sd	ra,8(sp)
ffffffffc02008c2:	e022                	sd	s0,0(sp)
ffffffffc02008c4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02008c6:	b99ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02008ca:	00006797          	auipc	a5,0x6
ffffffffc02008ce:	b967b783          	ld	a5,-1130(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02008d2:	6f9c                	ld	a5,24(a5)
ffffffffc02008d4:	8522                	mv	a0,s0
ffffffffc02008d6:	9782                	jalr	a5
ffffffffc02008d8:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02008da:	b7fff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02008de:	60a2                	ld	ra,8(sp)
ffffffffc02008e0:	8522                	mv	a0,s0
ffffffffc02008e2:	6402                	ld	s0,0(sp)
ffffffffc02008e4:	0141                	addi	sp,sp,16
ffffffffc02008e6:	8082                	ret

ffffffffc02008e8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008e8:	100027f3          	csrr	a5,sstatus
ffffffffc02008ec:	8b89                	andi	a5,a5,2
ffffffffc02008ee:	e799                	bnez	a5,ffffffffc02008fc <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02008f0:	00006797          	auipc	a5,0x6
ffffffffc02008f4:	b707b783          	ld	a5,-1168(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02008f8:	739c                	ld	a5,32(a5)
ffffffffc02008fa:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02008fc:	1101                	addi	sp,sp,-32
ffffffffc02008fe:	ec06                	sd	ra,24(sp)
ffffffffc0200900:	e822                	sd	s0,16(sp)
ffffffffc0200902:	e426                	sd	s1,8(sp)
ffffffffc0200904:	842a                	mv	s0,a0
ffffffffc0200906:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200908:	b57ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020090c:	00006797          	auipc	a5,0x6
ffffffffc0200910:	b547b783          	ld	a5,-1196(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200914:	739c                	ld	a5,32(a5)
ffffffffc0200916:	85a6                	mv	a1,s1
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020091c:	6442                	ld	s0,16(sp)
ffffffffc020091e:	60e2                	ld	ra,24(sp)
ffffffffc0200920:	64a2                	ld	s1,8(sp)
ffffffffc0200922:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200924:	be15                	j	ffffffffc0200458 <intr_enable>

ffffffffc0200926 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200926:	100027f3          	csrr	a5,sstatus
ffffffffc020092a:	8b89                	andi	a5,a5,2
ffffffffc020092c:	e799                	bnez	a5,ffffffffc020093a <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020092e:	00006797          	auipc	a5,0x6
ffffffffc0200932:	b327b783          	ld	a5,-1230(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200936:	779c                	ld	a5,40(a5)
ffffffffc0200938:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020093a:	1141                	addi	sp,sp,-16
ffffffffc020093c:	e406                	sd	ra,8(sp)
ffffffffc020093e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200940:	b1fff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200944:	00006797          	auipc	a5,0x6
ffffffffc0200948:	b1c7b783          	ld	a5,-1252(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc020094c:	779c                	ld	a5,40(a5)
ffffffffc020094e:	9782                	jalr	a5
ffffffffc0200950:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200952:	b07ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200956:	60a2                	ld	ra,8(sp)
ffffffffc0200958:	8522                	mv	a0,s0
ffffffffc020095a:	6402                	ld	s0,0(sp)
ffffffffc020095c:	0141                	addi	sp,sp,16
ffffffffc020095e:	8082                	ret

ffffffffc0200960 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200960:	00002797          	auipc	a5,0x2
ffffffffc0200964:	d8878793          	addi	a5,a5,-632 # ffffffffc02026e8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200968:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020096a:	1101                	addi	sp,sp,-32
ffffffffc020096c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020096e:	00002517          	auipc	a0,0x2
ffffffffc0200972:	90a50513          	addi	a0,a0,-1782 # ffffffffc0202278 <commands+0x590>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200976:	00006497          	auipc	s1,0x6
ffffffffc020097a:	aea48493          	addi	s1,s1,-1302 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc020097e:	ec06                	sd	ra,24(sp)
ffffffffc0200980:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200982:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200984:	f2eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200988:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020098a:	00006417          	auipc	s0,0x6
ffffffffc020098e:	aee40413          	addi	s0,s0,-1298 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200992:	679c                	ld	a5,8(a5)
ffffffffc0200994:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200996:	57f5                	li	a5,-3
ffffffffc0200998:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020099a:	00002517          	auipc	a0,0x2
ffffffffc020099e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0202290 <commands+0x5a8>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02009a2:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02009a4:	f0eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02009a8:	46c5                	li	a3,17
ffffffffc02009aa:	06ee                	slli	a3,a3,0x1b
ffffffffc02009ac:	40100613          	li	a2,1025
ffffffffc02009b0:	16fd                	addi	a3,a3,-1
ffffffffc02009b2:	07e005b7          	lui	a1,0x7e00
ffffffffc02009b6:	0656                	slli	a2,a2,0x15
ffffffffc02009b8:	00002517          	auipc	a0,0x2
ffffffffc02009bc:	8f050513          	addi	a0,a0,-1808 # ffffffffc02022a8 <commands+0x5c0>
ffffffffc02009c0:	ef2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009c4:	777d                	lui	a4,0xfffff
ffffffffc02009c6:	00007797          	auipc	a5,0x7
ffffffffc02009ca:	ac178793          	addi	a5,a5,-1343 # ffffffffc0207487 <end+0xfff>
ffffffffc02009ce:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	a8050513          	addi	a0,a0,-1408 # ffffffffc0206450 <npage>
ffffffffc02009d8:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009dc:	00006597          	auipc	a1,0x6
ffffffffc02009e0:	a7c58593          	addi	a1,a1,-1412 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02009e4:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02009e6:	e19c                	sd	a5,0(a1)
ffffffffc02009e8:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009ea:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009ec:	4885                	li	a7,1
ffffffffc02009ee:	fff80837          	lui	a6,0xfff80
ffffffffc02009f2:	a011                	j	ffffffffc02009f6 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02009f4:	619c                	ld	a5,0(a1)
ffffffffc02009f6:	97b6                	add	a5,a5,a3
ffffffffc02009f8:	07a1                	addi	a5,a5,8
ffffffffc02009fa:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009fe:	611c                	ld	a5,0(a0)
ffffffffc0200a00:	0705                	addi	a4,a4,1
ffffffffc0200a02:	02868693          	addi	a3,a3,40
ffffffffc0200a06:	01078633          	add	a2,a5,a6
ffffffffc0200a0a:	fec765e3          	bltu	a4,a2,ffffffffc02009f4 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a0e:	6190                	ld	a2,0(a1)
ffffffffc0200a10:	00279713          	slli	a4,a5,0x2
ffffffffc0200a14:	973e                	add	a4,a4,a5
ffffffffc0200a16:	fec006b7          	lui	a3,0xfec00
ffffffffc0200a1a:	070e                	slli	a4,a4,0x3
ffffffffc0200a1c:	96b2                	add	a3,a3,a2
ffffffffc0200a1e:	96ba                	add	a3,a3,a4
ffffffffc0200a20:	c0200737          	lui	a4,0xc0200
ffffffffc0200a24:	08e6ef63          	bltu	a3,a4,ffffffffc0200ac2 <pmm_init+0x162>
ffffffffc0200a28:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200a2a:	45c5                	li	a1,17
ffffffffc0200a2c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a2e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200a30:	04b6e863          	bltu	a3,a1,ffffffffc0200a80 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200a34:	609c                	ld	a5,0(s1)
ffffffffc0200a36:	7b9c                	ld	a5,48(a5)
ffffffffc0200a38:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200a3a:	00002517          	auipc	a0,0x2
ffffffffc0200a3e:	90650513          	addi	a0,a0,-1786 # ffffffffc0202340 <commands+0x658>
ffffffffc0200a42:	e70ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200a46:	00004597          	auipc	a1,0x4
ffffffffc0200a4a:	5ba58593          	addi	a1,a1,1466 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200a4e:	00006797          	auipc	a5,0x6
ffffffffc0200a52:	a2b7b123          	sd	a1,-1502(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a56:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a5a:	08f5e063          	bltu	a1,a5,ffffffffc0200ada <pmm_init+0x17a>
ffffffffc0200a5e:	6010                	ld	a2,0(s0)
}
ffffffffc0200a60:	6442                	ld	s0,16(sp)
ffffffffc0200a62:	60e2                	ld	ra,24(sp)
ffffffffc0200a64:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a66:	40c58633          	sub	a2,a1,a2
ffffffffc0200a6a:	00006797          	auipc	a5,0x6
ffffffffc0200a6e:	9ec7bf23          	sd	a2,-1538(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a72:	00002517          	auipc	a0,0x2
ffffffffc0200a76:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0202360 <commands+0x678>
}
ffffffffc0200a7a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a7c:	e36ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a80:	6705                	lui	a4,0x1
ffffffffc0200a82:	177d                	addi	a4,a4,-1
ffffffffc0200a84:	96ba                	add	a3,a3,a4
ffffffffc0200a86:	777d                	lui	a4,0xfffff
ffffffffc0200a88:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a8a:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200a8e:	00f57e63          	bgeu	a0,a5,ffffffffc0200aaa <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a92:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a94:	982a                	add	a6,a6,a0
ffffffffc0200a96:	00281513          	slli	a0,a6,0x2
ffffffffc0200a9a:	9542                	add	a0,a0,a6
ffffffffc0200a9c:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a9e:	8d95                	sub	a1,a1,a3
ffffffffc0200aa0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200aa2:	81b1                	srli	a1,a1,0xc
ffffffffc0200aa4:	9532                	add	a0,a0,a2
ffffffffc0200aa6:	9782                	jalr	a5
}
ffffffffc0200aa8:	b771                	j	ffffffffc0200a34 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200aaa:	00002617          	auipc	a2,0x2
ffffffffc0200aae:	86660613          	addi	a2,a2,-1946 # ffffffffc0202310 <commands+0x628>
ffffffffc0200ab2:	06b00593          	li	a1,107
ffffffffc0200ab6:	00002517          	auipc	a0,0x2
ffffffffc0200aba:	87a50513          	addi	a0,a0,-1926 # ffffffffc0202330 <commands+0x648>
ffffffffc0200abe:	e7cff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ac2:	00002617          	auipc	a2,0x2
ffffffffc0200ac6:	81660613          	addi	a2,a2,-2026 # ffffffffc02022d8 <commands+0x5f0>
ffffffffc0200aca:	06e00593          	li	a1,110
ffffffffc0200ace:	00002517          	auipc	a0,0x2
ffffffffc0200ad2:	83250513          	addi	a0,a0,-1998 # ffffffffc0202300 <commands+0x618>
ffffffffc0200ad6:	e64ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ada:	86ae                	mv	a3,a1
ffffffffc0200adc:	00001617          	auipc	a2,0x1
ffffffffc0200ae0:	7fc60613          	addi	a2,a2,2044 # ffffffffc02022d8 <commands+0x5f0>
ffffffffc0200ae4:	08900593          	li	a1,137
ffffffffc0200ae8:	00002517          	auipc	a0,0x2
ffffffffc0200aec:	81850513          	addi	a0,a0,-2024 # ffffffffc0202300 <commands+0x618>
ffffffffc0200af0:	e4aff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200af4 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200af4:	00005797          	auipc	a5,0x5
ffffffffc0200af8:	52478793          	addi	a5,a5,1316 # ffffffffc0206018 <free_area>
ffffffffc0200afc:	e79c                	sd	a5,8(a5)
ffffffffc0200afe:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b00:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b04:	8082                	ret

ffffffffc0200b06 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b06:	00005517          	auipc	a0,0x5
ffffffffc0200b0a:	52256503          	lwu	a0,1314(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200b0e:	8082                	ret

ffffffffc0200b10 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200b10:	c14d                	beqz	a0,ffffffffc0200bb2 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200b12:	00005617          	auipc	a2,0x5
ffffffffc0200b16:	50660613          	addi	a2,a2,1286 # ffffffffc0206018 <free_area>
ffffffffc0200b1a:	01062803          	lw	a6,16(a2)
ffffffffc0200b1e:	86aa                	mv	a3,a0
ffffffffc0200b20:	02081793          	slli	a5,a6,0x20
ffffffffc0200b24:	9381                	srli	a5,a5,0x20
ffffffffc0200b26:	08a7e463          	bltu	a5,a0,ffffffffc0200bae <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b2a:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200b2c:	0018059b          	addiw	a1,a6,1
ffffffffc0200b30:	1582                	slli	a1,a1,0x20
ffffffffc0200b32:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200b34:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b36:	06c78b63          	beq	a5,a2,ffffffffc0200bac <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size)
ffffffffc0200b3a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200b3e:	00d76763          	bltu	a4,a3,ffffffffc0200b4c <best_fit_alloc_pages+0x3c>
ffffffffc0200b42:	00b77563          	bgeu	a4,a1,ffffffffc0200b4c <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200b46:	fe878513          	addi	a0,a5,-24
ffffffffc0200b4a:	85ba                	mv	a1,a4
ffffffffc0200b4c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b4e:	fec796e3          	bne	a5,a2,ffffffffc0200b3a <best_fit_alloc_pages+0x2a>
    if (page != NULL)
ffffffffc0200b52:	cd29                	beqz	a0,ffffffffc0200bac <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b54:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200b56:	6d18                	ld	a4,24(a0)
        if (page->property > n)
ffffffffc0200b58:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200b5a:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b5e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b60:	e398                	sd	a4,0(a5)
        if (page->property > n)
ffffffffc0200b62:	02059793          	slli	a5,a1,0x20
ffffffffc0200b66:	9381                	srli	a5,a5,0x20
ffffffffc0200b68:	02f6f863          	bgeu	a3,a5,ffffffffc0200b98 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200b6c:	00269793          	slli	a5,a3,0x2
ffffffffc0200b70:	97b6                	add	a5,a5,a3
ffffffffc0200b72:	078e                	slli	a5,a5,0x3
ffffffffc0200b74:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200b76:	411585bb          	subw	a1,a1,a7
ffffffffc0200b7a:	cb8c                	sw	a1,16(a5)
ffffffffc0200b7c:	4689                	li	a3,2
ffffffffc0200b7e:	00878593          	addi	a1,a5,8
ffffffffc0200b82:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b86:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200b88:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200b8c:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200b90:	e28c                	sd	a1,0(a3)
ffffffffc0200b92:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200b94:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200b96:	ef98                	sd	a4,24(a5)
ffffffffc0200b98:	4118083b          	subw	a6,a6,a7
ffffffffc0200b9c:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ba0:	57f5                	li	a5,-3
ffffffffc0200ba2:	00850713          	addi	a4,a0,8
ffffffffc0200ba6:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200baa:	8082                	ret
}
ffffffffc0200bac:	8082                	ret
        return NULL;
ffffffffc0200bae:	4501                	li	a0,0
ffffffffc0200bb0:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200bb2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200bb4:	00001697          	auipc	a3,0x1
ffffffffc0200bb8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02023a0 <commands+0x6b8>
ffffffffc0200bbc:	00001617          	auipc	a2,0x1
ffffffffc0200bc0:	7ec60613          	addi	a2,a2,2028 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200bc4:	06e00593          	li	a1,110
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	7f850513          	addi	a0,a0,2040 # ffffffffc02023c0 <commands+0x6d8>
best_fit_alloc_pages(size_t n) {
ffffffffc0200bd0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200bd2:	d68ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200bd6 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200bd6:	715d                	addi	sp,sp,-80
ffffffffc0200bd8:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200bda:	00005417          	auipc	s0,0x5
ffffffffc0200bde:	43e40413          	addi	s0,s0,1086 # ffffffffc0206018 <free_area>
ffffffffc0200be2:	641c                	ld	a5,8(s0)
ffffffffc0200be4:	e486                	sd	ra,72(sp)
ffffffffc0200be6:	fc26                	sd	s1,56(sp)
ffffffffc0200be8:	f84a                	sd	s2,48(sp)
ffffffffc0200bea:	f44e                	sd	s3,40(sp)
ffffffffc0200bec:	f052                	sd	s4,32(sp)
ffffffffc0200bee:	ec56                	sd	s5,24(sp)
ffffffffc0200bf0:	e85a                	sd	s6,16(sp)
ffffffffc0200bf2:	e45e                	sd	s7,8(sp)
ffffffffc0200bf4:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bf6:	26878b63          	beq	a5,s0,ffffffffc0200e6c <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200bfa:	4481                	li	s1,0
ffffffffc0200bfc:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bfe:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c02:	8b09                	andi	a4,a4,2
ffffffffc0200c04:	26070863          	beqz	a4,ffffffffc0200e74 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200c08:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c0c:	679c                	ld	a5,8(a5)
ffffffffc0200c0e:	2905                	addiw	s2,s2,1
ffffffffc0200c10:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c12:	fe8796e3          	bne	a5,s0,ffffffffc0200bfe <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200c16:	89a6                	mv	s3,s1
ffffffffc0200c18:	d0fff0ef          	jal	ra,ffffffffc0200926 <nr_free_pages>
ffffffffc0200c1c:	33351c63          	bne	a0,s3,ffffffffc0200f54 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c20:	4505                	li	a0,1
ffffffffc0200c22:	c89ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200c26:	8a2a                	mv	s4,a0
ffffffffc0200c28:	36050663          	beqz	a0,ffffffffc0200f94 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c2c:	4505                	li	a0,1
ffffffffc0200c2e:	c7dff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200c32:	89aa                	mv	s3,a0
ffffffffc0200c34:	34050063          	beqz	a0,ffffffffc0200f74 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c38:	4505                	li	a0,1
ffffffffc0200c3a:	c71ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200c3e:	8aaa                	mv	s5,a0
ffffffffc0200c40:	2c050a63          	beqz	a0,ffffffffc0200f14 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c44:	253a0863          	beq	s4,s3,ffffffffc0200e94 <best_fit_check+0x2be>
ffffffffc0200c48:	24aa0663          	beq	s4,a0,ffffffffc0200e94 <best_fit_check+0x2be>
ffffffffc0200c4c:	24a98463          	beq	s3,a0,ffffffffc0200e94 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c50:	000a2783          	lw	a5,0(s4)
ffffffffc0200c54:	26079063          	bnez	a5,ffffffffc0200eb4 <best_fit_check+0x2de>
ffffffffc0200c58:	0009a783          	lw	a5,0(s3)
ffffffffc0200c5c:	24079c63          	bnez	a5,ffffffffc0200eb4 <best_fit_check+0x2de>
ffffffffc0200c60:	411c                	lw	a5,0(a0)
ffffffffc0200c62:	24079963          	bnez	a5,ffffffffc0200eb4 <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c66:	00005797          	auipc	a5,0x5
ffffffffc0200c6a:	7f27b783          	ld	a5,2034(a5) # ffffffffc0206458 <pages>
ffffffffc0200c6e:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c72:	870d                	srai	a4,a4,0x3
ffffffffc0200c74:	00002597          	auipc	a1,0x2
ffffffffc0200c78:	cfc5b583          	ld	a1,-772(a1) # ffffffffc0202970 <nbase+0x8>
ffffffffc0200c7c:	02b70733          	mul	a4,a4,a1
ffffffffc0200c80:	00002617          	auipc	a2,0x2
ffffffffc0200c84:	ce863603          	ld	a2,-792(a2) # ffffffffc0202968 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c88:	00005697          	auipc	a3,0x5
ffffffffc0200c8c:	7c86b683          	ld	a3,1992(a3) # ffffffffc0206450 <npage>
ffffffffc0200c90:	06b2                	slli	a3,a3,0xc
ffffffffc0200c92:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c94:	0732                	slli	a4,a4,0xc
ffffffffc0200c96:	22d77f63          	bgeu	a4,a3,ffffffffc0200ed4 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c9a:	40f98733          	sub	a4,s3,a5
ffffffffc0200c9e:	870d                	srai	a4,a4,0x3
ffffffffc0200ca0:	02b70733          	mul	a4,a4,a1
ffffffffc0200ca4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ca6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ca8:	3ed77663          	bgeu	a4,a3,ffffffffc0201094 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cac:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cb0:	878d                	srai	a5,a5,0x3
ffffffffc0200cb2:	02b787b3          	mul	a5,a5,a1
ffffffffc0200cb6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cb8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cba:	3ad7fd63          	bgeu	a5,a3,ffffffffc0201074 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200cbe:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cc0:	00043c03          	ld	s8,0(s0)
ffffffffc0200cc4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cc8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200ccc:	e400                	sd	s0,8(s0)
ffffffffc0200cce:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200cd0:	00005797          	auipc	a5,0x5
ffffffffc0200cd4:	3407ac23          	sw	zero,856(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cd8:	bd3ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200cdc:	36051c63          	bnez	a0,ffffffffc0201054 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200ce0:	4585                	li	a1,1
ffffffffc0200ce2:	8552                	mv	a0,s4
ffffffffc0200ce4:	c05ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    free_page(p1);
ffffffffc0200ce8:	4585                	li	a1,1
ffffffffc0200cea:	854e                	mv	a0,s3
ffffffffc0200cec:	bfdff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    free_page(p2);
ffffffffc0200cf0:	4585                	li	a1,1
ffffffffc0200cf2:	8556                	mv	a0,s5
ffffffffc0200cf4:	bf5ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    assert(nr_free == 3);
ffffffffc0200cf8:	4818                	lw	a4,16(s0)
ffffffffc0200cfa:	478d                	li	a5,3
ffffffffc0200cfc:	32f71c63          	bne	a4,a5,ffffffffc0201034 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d00:	4505                	li	a0,1
ffffffffc0200d02:	ba9ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d06:	89aa                	mv	s3,a0
ffffffffc0200d08:	30050663          	beqz	a0,ffffffffc0201014 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d0c:	4505                	li	a0,1
ffffffffc0200d0e:	b9dff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d12:	8aaa                	mv	s5,a0
ffffffffc0200d14:	2e050063          	beqz	a0,ffffffffc0200ff4 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	b91ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d1e:	8a2a                	mv	s4,a0
ffffffffc0200d20:	2a050a63          	beqz	a0,ffffffffc0200fd4 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200d24:	4505                	li	a0,1
ffffffffc0200d26:	b85ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d2a:	28051563          	bnez	a0,ffffffffc0200fb4 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200d2e:	4585                	li	a1,1
ffffffffc0200d30:	854e                	mv	a0,s3
ffffffffc0200d32:	bb7ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d36:	641c                	ld	a5,8(s0)
ffffffffc0200d38:	1a878e63          	beq	a5,s0,ffffffffc0200ef4 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200d3c:	4505                	li	a0,1
ffffffffc0200d3e:	b6dff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d42:	52a99963          	bne	s3,a0,ffffffffc0201274 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200d46:	4505                	li	a0,1
ffffffffc0200d48:	b63ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d4c:	50051463          	bnez	a0,ffffffffc0201254 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200d50:	481c                	lw	a5,16(s0)
ffffffffc0200d52:	4e079163          	bnez	a5,ffffffffc0201234 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200d56:	854e                	mv	a0,s3
ffffffffc0200d58:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d5a:	01843023          	sd	s8,0(s0)
ffffffffc0200d5e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200d62:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200d66:	b83ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    free_page(p1);
ffffffffc0200d6a:	4585                	li	a1,1
ffffffffc0200d6c:	8556                	mv	a0,s5
ffffffffc0200d6e:	b7bff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    free_page(p2);
ffffffffc0200d72:	4585                	li	a1,1
ffffffffc0200d74:	8552                	mv	a0,s4
ffffffffc0200d76:	b73ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d7a:	4515                	li	a0,5
ffffffffc0200d7c:	b2fff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200d80:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d82:	48050963          	beqz	a0,ffffffffc0201214 <best_fit_check+0x63e>
ffffffffc0200d86:	651c                	ld	a5,8(a0)
ffffffffc0200d88:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d8a:	8b85                	andi	a5,a5,1
ffffffffc0200d8c:	46079463          	bnez	a5,ffffffffc02011f4 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d90:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d92:	00043a83          	ld	s5,0(s0)
ffffffffc0200d96:	00843a03          	ld	s4,8(s0)
ffffffffc0200d9a:	e000                	sd	s0,0(s0)
ffffffffc0200d9c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200d9e:	b0dff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200da2:	42051963          	bnez	a0,ffffffffc02011d4 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200da6:	4589                	li	a1,2
ffffffffc0200da8:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200dac:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200db0:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200db4:	00005797          	auipc	a5,0x5
ffffffffc0200db8:	2607aa23          	sw	zero,628(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200dbc:	b2dff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200dc0:	8562                	mv	a0,s8
ffffffffc0200dc2:	4585                	li	a1,1
ffffffffc0200dc4:	b25ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dc8:	4511                	li	a0,4
ffffffffc0200dca:	ae1ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200dce:	3e051363          	bnez	a0,ffffffffc02011b4 <best_fit_check+0x5de>
ffffffffc0200dd2:	0309b783          	ld	a5,48(s3)
ffffffffc0200dd6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200dd8:	8b85                	andi	a5,a5,1
ffffffffc0200dda:	3a078d63          	beqz	a5,ffffffffc0201194 <best_fit_check+0x5be>
ffffffffc0200dde:	0389a703          	lw	a4,56(s3)
ffffffffc0200de2:	4789                	li	a5,2
ffffffffc0200de4:	3af71863          	bne	a4,a5,ffffffffc0201194 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200de8:	4505                	li	a0,1
ffffffffc0200dea:	ac1ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200dee:	8baa                	mv	s7,a0
ffffffffc0200df0:	38050263          	beqz	a0,ffffffffc0201174 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200df4:	4509                	li	a0,2
ffffffffc0200df6:	ab5ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200dfa:	34050d63          	beqz	a0,ffffffffc0201154 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200dfe:	337c1b63          	bne	s8,s7,ffffffffc0201134 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200e02:	854e                	mv	a0,s3
ffffffffc0200e04:	4595                	li	a1,5
ffffffffc0200e06:	ae3ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e0a:	4515                	li	a0,5
ffffffffc0200e0c:	a9fff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200e10:	89aa                	mv	s3,a0
ffffffffc0200e12:	30050163          	beqz	a0,ffffffffc0201114 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200e16:	4505                	li	a0,1
ffffffffc0200e18:	a93ff0ef          	jal	ra,ffffffffc02008aa <alloc_pages>
ffffffffc0200e1c:	2c051c63          	bnez	a0,ffffffffc02010f4 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200e20:	481c                	lw	a5,16(s0)
ffffffffc0200e22:	2a079963          	bnez	a5,ffffffffc02010d4 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e26:	4595                	li	a1,5
ffffffffc0200e28:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e2a:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200e2e:	01543023          	sd	s5,0(s0)
ffffffffc0200e32:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200e36:	ab3ff0ef          	jal	ra,ffffffffc02008e8 <free_pages>
    return listelm->next;
ffffffffc0200e3a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3c:	00878963          	beq	a5,s0,ffffffffc0200e4e <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e40:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e44:	679c                	ld	a5,8(a5)
ffffffffc0200e46:	397d                	addiw	s2,s2,-1
ffffffffc0200e48:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e4a:	fe879be3          	bne	a5,s0,ffffffffc0200e40 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200e4e:	26091363          	bnez	s2,ffffffffc02010b4 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200e52:	e0ed                	bnez	s1,ffffffffc0200f34 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200e54:	60a6                	ld	ra,72(sp)
ffffffffc0200e56:	6406                	ld	s0,64(sp)
ffffffffc0200e58:	74e2                	ld	s1,56(sp)
ffffffffc0200e5a:	7942                	ld	s2,48(sp)
ffffffffc0200e5c:	79a2                	ld	s3,40(sp)
ffffffffc0200e5e:	7a02                	ld	s4,32(sp)
ffffffffc0200e60:	6ae2                	ld	s5,24(sp)
ffffffffc0200e62:	6b42                	ld	s6,16(sp)
ffffffffc0200e64:	6ba2                	ld	s7,8(sp)
ffffffffc0200e66:	6c02                	ld	s8,0(sp)
ffffffffc0200e68:	6161                	addi	sp,sp,80
ffffffffc0200e6a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e6c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e6e:	4481                	li	s1,0
ffffffffc0200e70:	4901                	li	s2,0
ffffffffc0200e72:	b35d                	j	ffffffffc0200c18 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	56468693          	addi	a3,a3,1380 # ffffffffc02023d8 <commands+0x6f0>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	52c60613          	addi	a2,a2,1324 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200e84:	11200593          	li	a1,274
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	53850513          	addi	a0,a0,1336 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200e90:	aaaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	5d468693          	addi	a3,a3,1492 # ffffffffc0202468 <commands+0x780>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	50c60613          	addi	a2,a2,1292 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200ea4:	0de00593          	li	a1,222
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	51850513          	addi	a0,a0,1304 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200eb0:	a8aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202490 <commands+0x7a8>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	4ec60613          	addi	a2,a2,1260 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200ec4:	0df00593          	li	a1,223
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	4f850513          	addi	a0,a0,1272 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200ed0:	a6aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	5fc68693          	addi	a3,a3,1532 # ffffffffc02024d0 <commands+0x7e8>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	4cc60613          	addi	a2,a2,1228 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200ee4:	0e100593          	li	a1,225
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	4d850513          	addi	a0,a0,1240 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200ef0:	a4aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	66468693          	addi	a3,a3,1636 # ffffffffc0202558 <commands+0x870>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	4ac60613          	addi	a2,a2,1196 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200f04:	0fa00593          	li	a1,250
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	4b850513          	addi	a0,a0,1208 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f10:	a2aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	53468693          	addi	a3,a3,1332 # ffffffffc0202448 <commands+0x760>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	48c60613          	addi	a2,a2,1164 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200f24:	0dc00593          	li	a1,220
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	49850513          	addi	a0,a0,1176 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f30:	a0aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == 0);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	75468693          	addi	a3,a3,1876 # ffffffffc0202688 <commands+0x9a0>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	46c60613          	addi	a2,a2,1132 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200f44:	15400593          	li	a1,340
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	47850513          	addi	a0,a0,1144 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f50:	9eaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == nr_free_pages());
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	49468693          	addi	a3,a3,1172 # ffffffffc02023e8 <commands+0x700>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	44c60613          	addi	a2,a2,1100 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200f64:	11500593          	li	a1,277
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	45850513          	addi	a0,a0,1112 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f70:	9caff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	4b468693          	addi	a3,a3,1204 # ffffffffc0202428 <commands+0x740>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	42c60613          	addi	a2,a2,1068 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200f84:	0db00593          	li	a1,219
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	43850513          	addi	a0,a0,1080 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200f90:	9aaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	47468693          	addi	a3,a3,1140 # ffffffffc0202408 <commands+0x720>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	40c60613          	addi	a2,a2,1036 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200fa4:	0da00593          	li	a1,218
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	41850513          	addi	a0,a0,1048 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200fb0:	98aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	57c68693          	addi	a3,a3,1404 # ffffffffc0202530 <commands+0x848>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	3ec60613          	addi	a2,a2,1004 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200fc4:	0f700593          	li	a1,247
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	3f850513          	addi	a0,a0,1016 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200fd0:	96aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	47468693          	addi	a3,a3,1140 # ffffffffc0202448 <commands+0x760>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	3cc60613          	addi	a2,a2,972 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0200fe4:	0f500593          	li	a1,245
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	3d850513          	addi	a0,a0,984 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0200ff0:	94aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	43468693          	addi	a3,a3,1076 # ffffffffc0202428 <commands+0x740>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	3ac60613          	addi	a2,a2,940 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201004:	0f400593          	li	a1,244
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	3b850513          	addi	a0,a0,952 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201010:	92aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	3f468693          	addi	a3,a3,1012 # ffffffffc0202408 <commands+0x720>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	38c60613          	addi	a2,a2,908 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201024:	0f300593          	li	a1,243
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	39850513          	addi	a0,a0,920 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201030:	90aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 3);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	51468693          	addi	a3,a3,1300 # ffffffffc0202548 <commands+0x860>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	36c60613          	addi	a2,a2,876 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201044:	0f100593          	li	a1,241
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	37850513          	addi	a0,a0,888 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201050:	8eaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201054:	00001697          	auipc	a3,0x1
ffffffffc0201058:	4dc68693          	addi	a3,a3,1244 # ffffffffc0202530 <commands+0x848>
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	34c60613          	addi	a2,a2,844 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201064:	0ec00593          	li	a1,236
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	35850513          	addi	a0,a0,856 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201070:	8caff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201074:	00001697          	auipc	a3,0x1
ffffffffc0201078:	49c68693          	addi	a3,a3,1180 # ffffffffc0202510 <commands+0x828>
ffffffffc020107c:	00001617          	auipc	a2,0x1
ffffffffc0201080:	32c60613          	addi	a2,a2,812 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201084:	0e300593          	li	a1,227
ffffffffc0201088:	00001517          	auipc	a0,0x1
ffffffffc020108c:	33850513          	addi	a0,a0,824 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201090:	8aaff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201094:	00001697          	auipc	a3,0x1
ffffffffc0201098:	45c68693          	addi	a3,a3,1116 # ffffffffc02024f0 <commands+0x808>
ffffffffc020109c:	00001617          	auipc	a2,0x1
ffffffffc02010a0:	30c60613          	addi	a2,a2,780 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02010a4:	0e200593          	li	a1,226
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	31850513          	addi	a0,a0,792 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02010b0:	88aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(count == 0);
ffffffffc02010b4:	00001697          	auipc	a3,0x1
ffffffffc02010b8:	5c468693          	addi	a3,a3,1476 # ffffffffc0202678 <commands+0x990>
ffffffffc02010bc:	00001617          	auipc	a2,0x1
ffffffffc02010c0:	2ec60613          	addi	a2,a2,748 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02010c4:	15300593          	li	a1,339
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	2f850513          	addi	a0,a0,760 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02010d0:	86aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc02010d4:	00001697          	auipc	a3,0x1
ffffffffc02010d8:	4bc68693          	addi	a3,a3,1212 # ffffffffc0202590 <commands+0x8a8>
ffffffffc02010dc:	00001617          	auipc	a2,0x1
ffffffffc02010e0:	2cc60613          	addi	a2,a2,716 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02010e4:	14800593          	li	a1,328
ffffffffc02010e8:	00001517          	auipc	a0,0x1
ffffffffc02010ec:	2d850513          	addi	a0,a0,728 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02010f0:	84aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f4:	00001697          	auipc	a3,0x1
ffffffffc02010f8:	43c68693          	addi	a3,a3,1084 # ffffffffc0202530 <commands+0x848>
ffffffffc02010fc:	00001617          	auipc	a2,0x1
ffffffffc0201100:	2ac60613          	addi	a2,a2,684 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201104:	14200593          	li	a1,322
ffffffffc0201108:	00001517          	auipc	a0,0x1
ffffffffc020110c:	2b850513          	addi	a0,a0,696 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201110:	82aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201114:	00001697          	auipc	a3,0x1
ffffffffc0201118:	54468693          	addi	a3,a3,1348 # ffffffffc0202658 <commands+0x970>
ffffffffc020111c:	00001617          	auipc	a2,0x1
ffffffffc0201120:	28c60613          	addi	a2,a2,652 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201124:	14100593          	li	a1,321
ffffffffc0201128:	00001517          	auipc	a0,0x1
ffffffffc020112c:	29850513          	addi	a0,a0,664 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201130:	80aff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201134:	00001697          	auipc	a3,0x1
ffffffffc0201138:	51468693          	addi	a3,a3,1300 # ffffffffc0202648 <commands+0x960>
ffffffffc020113c:	00001617          	auipc	a2,0x1
ffffffffc0201140:	26c60613          	addi	a2,a2,620 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201144:	13900593          	li	a1,313
ffffffffc0201148:	00001517          	auipc	a0,0x1
ffffffffc020114c:	27850513          	addi	a0,a0,632 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201150:	febfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201154:	00001697          	auipc	a3,0x1
ffffffffc0201158:	4dc68693          	addi	a3,a3,1244 # ffffffffc0202630 <commands+0x948>
ffffffffc020115c:	00001617          	auipc	a2,0x1
ffffffffc0201160:	24c60613          	addi	a2,a2,588 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201164:	13800593          	li	a1,312
ffffffffc0201168:	00001517          	auipc	a0,0x1
ffffffffc020116c:	25850513          	addi	a0,a0,600 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201170:	fcbfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201174:	00001697          	auipc	a3,0x1
ffffffffc0201178:	49c68693          	addi	a3,a3,1180 # ffffffffc0202610 <commands+0x928>
ffffffffc020117c:	00001617          	auipc	a2,0x1
ffffffffc0201180:	22c60613          	addi	a2,a2,556 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201184:	13700593          	li	a1,311
ffffffffc0201188:	00001517          	auipc	a0,0x1
ffffffffc020118c:	23850513          	addi	a0,a0,568 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201190:	fabfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201194:	00001697          	auipc	a3,0x1
ffffffffc0201198:	44c68693          	addi	a3,a3,1100 # ffffffffc02025e0 <commands+0x8f8>
ffffffffc020119c:	00001617          	auipc	a2,0x1
ffffffffc02011a0:	20c60613          	addi	a2,a2,524 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02011a4:	13500593          	li	a1,309
ffffffffc02011a8:	00001517          	auipc	a0,0x1
ffffffffc02011ac:	21850513          	addi	a0,a0,536 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02011b0:	f8bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b4:	00001697          	auipc	a3,0x1
ffffffffc02011b8:	41468693          	addi	a3,a3,1044 # ffffffffc02025c8 <commands+0x8e0>
ffffffffc02011bc:	00001617          	auipc	a2,0x1
ffffffffc02011c0:	1ec60613          	addi	a2,a2,492 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02011c4:	13400593          	li	a1,308
ffffffffc02011c8:	00001517          	auipc	a0,0x1
ffffffffc02011cc:	1f850513          	addi	a0,a0,504 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02011d0:	f6bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d4:	00001697          	auipc	a3,0x1
ffffffffc02011d8:	35c68693          	addi	a3,a3,860 # ffffffffc0202530 <commands+0x848>
ffffffffc02011dc:	00001617          	auipc	a2,0x1
ffffffffc02011e0:	1cc60613          	addi	a2,a2,460 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02011e4:	12800593          	li	a1,296
ffffffffc02011e8:	00001517          	auipc	a0,0x1
ffffffffc02011ec:	1d850513          	addi	a0,a0,472 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02011f0:	f4bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!PageProperty(p0));
ffffffffc02011f4:	00001697          	auipc	a3,0x1
ffffffffc02011f8:	3bc68693          	addi	a3,a3,956 # ffffffffc02025b0 <commands+0x8c8>
ffffffffc02011fc:	00001617          	auipc	a2,0x1
ffffffffc0201200:	1ac60613          	addi	a2,a2,428 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201204:	11f00593          	li	a1,287
ffffffffc0201208:	00001517          	auipc	a0,0x1
ffffffffc020120c:	1b850513          	addi	a0,a0,440 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201210:	f2bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != NULL);
ffffffffc0201214:	00001697          	auipc	a3,0x1
ffffffffc0201218:	38c68693          	addi	a3,a3,908 # ffffffffc02025a0 <commands+0x8b8>
ffffffffc020121c:	00001617          	auipc	a2,0x1
ffffffffc0201220:	18c60613          	addi	a2,a2,396 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201224:	11e00593          	li	a1,286
ffffffffc0201228:	00001517          	auipc	a0,0x1
ffffffffc020122c:	19850513          	addi	a0,a0,408 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201230:	f0bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc0201234:	00001697          	auipc	a3,0x1
ffffffffc0201238:	35c68693          	addi	a3,a3,860 # ffffffffc0202590 <commands+0x8a8>
ffffffffc020123c:	00001617          	auipc	a2,0x1
ffffffffc0201240:	16c60613          	addi	a2,a2,364 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201244:	10000593          	li	a1,256
ffffffffc0201248:	00001517          	auipc	a0,0x1
ffffffffc020124c:	17850513          	addi	a0,a0,376 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201250:	eebfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201254:	00001697          	auipc	a3,0x1
ffffffffc0201258:	2dc68693          	addi	a3,a3,732 # ffffffffc0202530 <commands+0x848>
ffffffffc020125c:	00001617          	auipc	a2,0x1
ffffffffc0201260:	14c60613          	addi	a2,a2,332 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201264:	0fe00593          	li	a1,254
ffffffffc0201268:	00001517          	auipc	a0,0x1
ffffffffc020126c:	15850513          	addi	a0,a0,344 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201270:	ecbfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201274:	00001697          	auipc	a3,0x1
ffffffffc0201278:	2fc68693          	addi	a3,a3,764 # ffffffffc0202570 <commands+0x888>
ffffffffc020127c:	00001617          	auipc	a2,0x1
ffffffffc0201280:	12c60613          	addi	a2,a2,300 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc0201284:	0fd00593          	li	a1,253
ffffffffc0201288:	00001517          	auipc	a0,0x1
ffffffffc020128c:	13850513          	addi	a0,a0,312 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201290:	eabfe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201294 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201294:	1141                	addi	sp,sp,-16
ffffffffc0201296:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201298:	14058a63          	beqz	a1,ffffffffc02013ec <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020129c:	00259693          	slli	a3,a1,0x2
ffffffffc02012a0:	96ae                	add	a3,a3,a1
ffffffffc02012a2:	068e                	slli	a3,a3,0x3
ffffffffc02012a4:	96aa                	add	a3,a3,a0
ffffffffc02012a6:	87aa                	mv	a5,a0
ffffffffc02012a8:	02d50263          	beq	a0,a3,ffffffffc02012cc <best_fit_free_pages+0x38>
ffffffffc02012ac:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012ae:	8b05                	andi	a4,a4,1
ffffffffc02012b0:	10071e63          	bnez	a4,ffffffffc02013cc <best_fit_free_pages+0x138>
ffffffffc02012b4:	6798                	ld	a4,8(a5)
ffffffffc02012b6:	8b09                	andi	a4,a4,2
ffffffffc02012b8:	10071a63          	bnez	a4,ffffffffc02013cc <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc02012bc:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012c0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c4:	02878793          	addi	a5,a5,40
ffffffffc02012c8:	fed792e3          	bne	a5,a3,ffffffffc02012ac <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc02012cc:	2581                	sext.w	a1,a1
ffffffffc02012ce:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02012d0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012d4:	4789                	li	a5,2
ffffffffc02012d6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012da:	00005697          	auipc	a3,0x5
ffffffffc02012de:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206018 <free_area>
ffffffffc02012e2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012e6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02012ea:	9db9                	addw	a1,a1,a4
ffffffffc02012ec:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012ee:	0ad78863          	beq	a5,a3,ffffffffc020139e <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012f2:	fe878713          	addi	a4,a5,-24
ffffffffc02012f6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012fa:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012fc:	00e56a63          	bltu	a0,a4,ffffffffc0201310 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0201300:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201302:	06d70263          	beq	a4,a3,ffffffffc0201366 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201306:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201308:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020130c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201300 <best_fit_free_pages+0x6c>
ffffffffc0201310:	c199                	beqz	a1,ffffffffc0201316 <best_fit_free_pages+0x82>
ffffffffc0201312:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201316:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201318:	e390                	sd	a2,0(a5)
ffffffffc020131a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020131c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020131e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201320:	02d70063          	beq	a4,a3,ffffffffc0201340 <best_fit_free_pages+0xac>
        if (p + p->property == base)
ffffffffc0201324:	ff872803          	lw	a6,-8(a4) # ffffffffffffeff8 <end+0x3fdf8b70>
        p = le2page(le, page_link);
ffffffffc0201328:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc020132c:	02081613          	slli	a2,a6,0x20
ffffffffc0201330:	9201                	srli	a2,a2,0x20
ffffffffc0201332:	00261793          	slli	a5,a2,0x2
ffffffffc0201336:	97b2                	add	a5,a5,a2
ffffffffc0201338:	078e                	slli	a5,a5,0x3
ffffffffc020133a:	97ae                	add	a5,a5,a1
ffffffffc020133c:	02f50f63          	beq	a0,a5,ffffffffc020137a <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201340:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201342:	00d70f63          	beq	a4,a3,ffffffffc0201360 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201346:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201348:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020134c:	02059613          	slli	a2,a1,0x20
ffffffffc0201350:	9201                	srli	a2,a2,0x20
ffffffffc0201352:	00261793          	slli	a5,a2,0x2
ffffffffc0201356:	97b2                	add	a5,a5,a2
ffffffffc0201358:	078e                	slli	a5,a5,0x3
ffffffffc020135a:	97aa                	add	a5,a5,a0
ffffffffc020135c:	04f68863          	beq	a3,a5,ffffffffc02013ac <best_fit_free_pages+0x118>
}
ffffffffc0201360:	60a2                	ld	ra,8(sp)
ffffffffc0201362:	0141                	addi	sp,sp,16
ffffffffc0201364:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201366:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201368:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020136a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020136c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	02d70563          	beq	a4,a3,ffffffffc0201398 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201372:	8832                	mv	a6,a2
ffffffffc0201374:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201376:	87ba                	mv	a5,a4
ffffffffc0201378:	bf41                	j	ffffffffc0201308 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc020137a:	491c                	lw	a5,16(a0)
ffffffffc020137c:	0107883b          	addw	a6,a5,a6
ffffffffc0201380:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201384:	57f5                	li	a5,-3
ffffffffc0201386:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020138a:	6d10                	ld	a2,24(a0)
ffffffffc020138c:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020138e:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0201390:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201392:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201394:	e390                	sd	a2,0(a5)
ffffffffc0201396:	b775                	j	ffffffffc0201342 <best_fit_free_pages+0xae>
ffffffffc0201398:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139a:	873e                	mv	a4,a5
ffffffffc020139c:	b761                	j	ffffffffc0201324 <best_fit_free_pages+0x90>
}
ffffffffc020139e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013a0:	e390                	sd	a2,0(a5)
ffffffffc02013a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013a4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013a6:	ed1c                	sd	a5,24(a0)
ffffffffc02013a8:	0141                	addi	sp,sp,16
ffffffffc02013aa:	8082                	ret
            base->property += p->property;
ffffffffc02013ac:	ff872783          	lw	a5,-8(a4)
ffffffffc02013b0:	ff070693          	addi	a3,a4,-16
ffffffffc02013b4:	9dbd                	addw	a1,a1,a5
ffffffffc02013b6:	c90c                	sw	a1,16(a0)
ffffffffc02013b8:	57f5                	li	a5,-3
ffffffffc02013ba:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013be:	6314                	ld	a3,0(a4)
ffffffffc02013c0:	671c                	ld	a5,8(a4)
}
ffffffffc02013c2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013c4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013c6:	e394                	sd	a3,0(a5)
ffffffffc02013c8:	0141                	addi	sp,sp,16
ffffffffc02013ca:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013cc:	00001697          	auipc	a3,0x1
ffffffffc02013d0:	2cc68693          	addi	a3,a3,716 # ffffffffc0202698 <commands+0x9b0>
ffffffffc02013d4:	00001617          	auipc	a2,0x1
ffffffffc02013d8:	fd460613          	addi	a2,a2,-44 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02013dc:	09900593          	li	a1,153
ffffffffc02013e0:	00001517          	auipc	a0,0x1
ffffffffc02013e4:	fe050513          	addi	a0,a0,-32 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02013e8:	d53fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc02013ec:	00001697          	auipc	a3,0x1
ffffffffc02013f0:	fb468693          	addi	a3,a3,-76 # ffffffffc02023a0 <commands+0x6b8>
ffffffffc02013f4:	00001617          	auipc	a2,0x1
ffffffffc02013f8:	fb460613          	addi	a2,a2,-76 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02013fc:	09600593          	li	a1,150
ffffffffc0201400:	00001517          	auipc	a0,0x1
ffffffffc0201404:	fc050513          	addi	a0,a0,-64 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc0201408:	d33fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc020140c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020140c:	1141                	addi	sp,sp,-16
ffffffffc020140e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201410:	c9e1                	beqz	a1,ffffffffc02014e0 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201412:	00259693          	slli	a3,a1,0x2
ffffffffc0201416:	96ae                	add	a3,a3,a1
ffffffffc0201418:	068e                	slli	a3,a3,0x3
ffffffffc020141a:	96aa                	add	a3,a3,a0
ffffffffc020141c:	87aa                	mv	a5,a0
ffffffffc020141e:	00d50f63          	beq	a0,a3,ffffffffc020143c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201422:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201424:	8b05                	andi	a4,a4,1
ffffffffc0201426:	cf49                	beqz	a4,ffffffffc02014c0 <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc0201428:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc020142c:	0007a823          	sw	zero,16(a5)
ffffffffc0201430:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201434:	02878793          	addi	a5,a5,40
ffffffffc0201438:	fed795e3          	bne	a5,a3,ffffffffc0201422 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020143c:	2581                	sext.w	a1,a1
ffffffffc020143e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201440:	4789                	li	a5,2
ffffffffc0201442:	00850713          	addi	a4,a0,8
ffffffffc0201446:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020144a:	00005697          	auipc	a3,0x5
ffffffffc020144e:	bce68693          	addi	a3,a3,-1074 # ffffffffc0206018 <free_area>
ffffffffc0201452:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201454:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201456:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020145a:	9db9                	addw	a1,a1,a4
ffffffffc020145c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020145e:	04d78a63          	beq	a5,a3,ffffffffc02014b2 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201462:	fe878713          	addi	a4,a5,-24
ffffffffc0201466:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020146a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020146c:	00e56a63          	bltu	a0,a4,ffffffffc0201480 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201470:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201472:	02d70263          	beq	a4,a3,ffffffffc0201496 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201476:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201478:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020147c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201470 <best_fit_init_memmap+0x64>
ffffffffc0201480:	c199                	beqz	a1,ffffffffc0201486 <best_fit_init_memmap+0x7a>
ffffffffc0201482:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201486:	6398                	ld	a4,0(a5)
}
ffffffffc0201488:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020148a:	e390                	sd	a2,0(a5)
ffffffffc020148c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020148e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201490:	ed18                	sd	a4,24(a0)
ffffffffc0201492:	0141                	addi	sp,sp,16
ffffffffc0201494:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201496:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201498:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020149a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020149c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020149e:	00d70663          	beq	a4,a3,ffffffffc02014aa <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02014a2:	8832                	mv	a6,a2
ffffffffc02014a4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02014a6:	87ba                	mv	a5,a4
ffffffffc02014a8:	bfc1                	j	ffffffffc0201478 <best_fit_init_memmap+0x6c>
}
ffffffffc02014aa:	60a2                	ld	ra,8(sp)
ffffffffc02014ac:	e290                	sd	a2,0(a3)
ffffffffc02014ae:	0141                	addi	sp,sp,16
ffffffffc02014b0:	8082                	ret
ffffffffc02014b2:	60a2                	ld	ra,8(sp)
ffffffffc02014b4:	e390                	sd	a2,0(a5)
ffffffffc02014b6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014b8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014ba:	ed1c                	sd	a5,24(a0)
ffffffffc02014bc:	0141                	addi	sp,sp,16
ffffffffc02014be:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014c0:	00001697          	auipc	a3,0x1
ffffffffc02014c4:	20068693          	addi	a3,a3,512 # ffffffffc02026c0 <commands+0x9d8>
ffffffffc02014c8:	00001617          	auipc	a2,0x1
ffffffffc02014cc:	ee060613          	addi	a2,a2,-288 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02014d0:	04a00593          	li	a1,74
ffffffffc02014d4:	00001517          	auipc	a0,0x1
ffffffffc02014d8:	eec50513          	addi	a0,a0,-276 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02014dc:	c5ffe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc02014e0:	00001697          	auipc	a3,0x1
ffffffffc02014e4:	ec068693          	addi	a3,a3,-320 # ffffffffc02023a0 <commands+0x6b8>
ffffffffc02014e8:	00001617          	auipc	a2,0x1
ffffffffc02014ec:	ec060613          	addi	a2,a2,-320 # ffffffffc02023a8 <commands+0x6c0>
ffffffffc02014f0:	04700593          	li	a1,71
ffffffffc02014f4:	00001517          	auipc	a0,0x1
ffffffffc02014f8:	ecc50513          	addi	a0,a0,-308 # ffffffffc02023c0 <commands+0x6d8>
ffffffffc02014fc:	c3ffe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201500 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201500:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201502:	e589                	bnez	a1,ffffffffc020150c <strnlen+0xc>
ffffffffc0201504:	a811                	j	ffffffffc0201518 <strnlen+0x18>
        cnt ++;
ffffffffc0201506:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201508:	00f58863          	beq	a1,a5,ffffffffc0201518 <strnlen+0x18>
ffffffffc020150c:	00f50733          	add	a4,a0,a5
ffffffffc0201510:	00074703          	lbu	a4,0(a4)
ffffffffc0201514:	fb6d                	bnez	a4,ffffffffc0201506 <strnlen+0x6>
ffffffffc0201516:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201518:	852e                	mv	a0,a1
ffffffffc020151a:	8082                	ret

ffffffffc020151c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020151c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201520:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201524:	cb89                	beqz	a5,ffffffffc0201536 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201526:	0505                	addi	a0,a0,1
ffffffffc0201528:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020152a:	fee789e3          	beq	a5,a4,ffffffffc020151c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020152e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201532:	9d19                	subw	a0,a0,a4
ffffffffc0201534:	8082                	ret
ffffffffc0201536:	4501                	li	a0,0
ffffffffc0201538:	bfed                	j	ffffffffc0201532 <strcmp+0x16>

ffffffffc020153a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020153a:	00054783          	lbu	a5,0(a0)
ffffffffc020153e:	c799                	beqz	a5,ffffffffc020154c <strchr+0x12>
        if (*s == c) {
ffffffffc0201540:	00f58763          	beq	a1,a5,ffffffffc020154e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201544:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201548:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020154a:	fbfd                	bnez	a5,ffffffffc0201540 <strchr+0x6>
    }
    return NULL;
ffffffffc020154c:	4501                	li	a0,0
}
ffffffffc020154e:	8082                	ret

ffffffffc0201550 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201550:	ca01                	beqz	a2,ffffffffc0201560 <memset+0x10>
ffffffffc0201552:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201554:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201556:	0785                	addi	a5,a5,1
ffffffffc0201558:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020155c:	fec79de3          	bne	a5,a2,ffffffffc0201556 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201560:	8082                	ret

ffffffffc0201562 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201562:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201566:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201568:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020156c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020156e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201572:	f022                	sd	s0,32(sp)
ffffffffc0201574:	ec26                	sd	s1,24(sp)
ffffffffc0201576:	e84a                	sd	s2,16(sp)
ffffffffc0201578:	f406                	sd	ra,40(sp)
ffffffffc020157a:	e44e                	sd	s3,8(sp)
ffffffffc020157c:	84aa                	mv	s1,a0
ffffffffc020157e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201580:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201584:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201586:	03067e63          	bgeu	a2,a6,ffffffffc02015c2 <printnum+0x60>
ffffffffc020158a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020158c:	00805763          	blez	s0,ffffffffc020159a <printnum+0x38>
ffffffffc0201590:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201592:	85ca                	mv	a1,s2
ffffffffc0201594:	854e                	mv	a0,s3
ffffffffc0201596:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201598:	fc65                	bnez	s0,ffffffffc0201590 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020159a:	1a02                	slli	s4,s4,0x20
ffffffffc020159c:	00001797          	auipc	a5,0x1
ffffffffc02015a0:	18478793          	addi	a5,a5,388 # ffffffffc0202720 <best_fit_pmm_manager+0x38>
ffffffffc02015a4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015a8:	9a3e                	add	s4,s4,a5
}
ffffffffc02015aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ac:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015b0:	70a2                	ld	ra,40(sp)
ffffffffc02015b2:	69a2                	ld	s3,8(sp)
ffffffffc02015b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015b6:	85ca                	mv	a1,s2
ffffffffc02015b8:	87a6                	mv	a5,s1
}
ffffffffc02015ba:	6942                	ld	s2,16(sp)
ffffffffc02015bc:	64e2                	ld	s1,24(sp)
ffffffffc02015be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015c0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015c2:	03065633          	divu	a2,a2,a6
ffffffffc02015c6:	8722                	mv	a4,s0
ffffffffc02015c8:	f9bff0ef          	jal	ra,ffffffffc0201562 <printnum>
ffffffffc02015cc:	b7f9                	j	ffffffffc020159a <printnum+0x38>

ffffffffc02015ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015ce:	7119                	addi	sp,sp,-128
ffffffffc02015d0:	f4a6                	sd	s1,104(sp)
ffffffffc02015d2:	f0ca                	sd	s2,96(sp)
ffffffffc02015d4:	ecce                	sd	s3,88(sp)
ffffffffc02015d6:	e8d2                	sd	s4,80(sp)
ffffffffc02015d8:	e4d6                	sd	s5,72(sp)
ffffffffc02015da:	e0da                	sd	s6,64(sp)
ffffffffc02015dc:	fc5e                	sd	s7,56(sp)
ffffffffc02015de:	f06a                	sd	s10,32(sp)
ffffffffc02015e0:	fc86                	sd	ra,120(sp)
ffffffffc02015e2:	f8a2                	sd	s0,112(sp)
ffffffffc02015e4:	f862                	sd	s8,48(sp)
ffffffffc02015e6:	f466                	sd	s9,40(sp)
ffffffffc02015e8:	ec6e                	sd	s11,24(sp)
ffffffffc02015ea:	892a                	mv	s2,a0
ffffffffc02015ec:	84ae                	mv	s1,a1
ffffffffc02015ee:	8d32                	mv	s10,a2
ffffffffc02015f0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015f2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015f6:	5b7d                	li	s6,-1
ffffffffc02015f8:	00001a97          	auipc	s5,0x1
ffffffffc02015fc:	15ca8a93          	addi	s5,s5,348 # ffffffffc0202754 <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201600:	00001b97          	auipc	s7,0x1
ffffffffc0201604:	330b8b93          	addi	s7,s7,816 # ffffffffc0202930 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201608:	000d4503          	lbu	a0,0(s10)
ffffffffc020160c:	001d0413          	addi	s0,s10,1
ffffffffc0201610:	01350a63          	beq	a0,s3,ffffffffc0201624 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201614:	c121                	beqz	a0,ffffffffc0201654 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201616:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201618:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020161a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020161c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201620:	ff351ae3          	bne	a0,s3,ffffffffc0201614 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201624:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201628:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020162c:	4c81                	li	s9,0
ffffffffc020162e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201630:	5c7d                	li	s8,-1
ffffffffc0201632:	5dfd                	li	s11,-1
ffffffffc0201634:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201638:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020163e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201642:	00140d13          	addi	s10,s0,1
ffffffffc0201646:	04b56263          	bltu	a0,a1,ffffffffc020168a <vprintfmt+0xbc>
ffffffffc020164a:	058a                	slli	a1,a1,0x2
ffffffffc020164c:	95d6                	add	a1,a1,s5
ffffffffc020164e:	4194                	lw	a3,0(a1)
ffffffffc0201650:	96d6                	add	a3,a3,s5
ffffffffc0201652:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201654:	70e6                	ld	ra,120(sp)
ffffffffc0201656:	7446                	ld	s0,112(sp)
ffffffffc0201658:	74a6                	ld	s1,104(sp)
ffffffffc020165a:	7906                	ld	s2,96(sp)
ffffffffc020165c:	69e6                	ld	s3,88(sp)
ffffffffc020165e:	6a46                	ld	s4,80(sp)
ffffffffc0201660:	6aa6                	ld	s5,72(sp)
ffffffffc0201662:	6b06                	ld	s6,64(sp)
ffffffffc0201664:	7be2                	ld	s7,56(sp)
ffffffffc0201666:	7c42                	ld	s8,48(sp)
ffffffffc0201668:	7ca2                	ld	s9,40(sp)
ffffffffc020166a:	7d02                	ld	s10,32(sp)
ffffffffc020166c:	6de2                	ld	s11,24(sp)
ffffffffc020166e:	6109                	addi	sp,sp,128
ffffffffc0201670:	8082                	ret
            padc = '0';
ffffffffc0201672:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201674:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201678:	846a                	mv	s0,s10
ffffffffc020167a:	00140d13          	addi	s10,s0,1
ffffffffc020167e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201682:	0ff5f593          	zext.b	a1,a1
ffffffffc0201686:	fcb572e3          	bgeu	a0,a1,ffffffffc020164a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020168a:	85a6                	mv	a1,s1
ffffffffc020168c:	02500513          	li	a0,37
ffffffffc0201690:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201692:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201696:	8d22                	mv	s10,s0
ffffffffc0201698:	f73788e3          	beq	a5,s3,ffffffffc0201608 <vprintfmt+0x3a>
ffffffffc020169c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02016a0:	1d7d                	addi	s10,s10,-1
ffffffffc02016a2:	ff379de3          	bne	a5,s3,ffffffffc020169c <vprintfmt+0xce>
ffffffffc02016a6:	b78d                	j	ffffffffc0201608 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02016a8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02016ac:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02016b2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02016b6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016ba:	02d86463          	bltu	a6,a3,ffffffffc02016e2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02016be:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02016c2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02016c6:	0186873b          	addw	a4,a3,s8
ffffffffc02016ca:	0017171b          	slliw	a4,a4,0x1
ffffffffc02016ce:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02016d0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02016d4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02016d6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02016da:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016de:	fed870e3          	bgeu	a6,a3,ffffffffc02016be <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02016e2:	f40ddce3          	bgez	s11,ffffffffc020163a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02016e6:	8de2                	mv	s11,s8
ffffffffc02016e8:	5c7d                	li	s8,-1
ffffffffc02016ea:	bf81                	j	ffffffffc020163a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02016ec:	fffdc693          	not	a3,s11
ffffffffc02016f0:	96fd                	srai	a3,a3,0x3f
ffffffffc02016f2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f6:	00144603          	lbu	a2,1(s0)
ffffffffc02016fa:	2d81                	sext.w	s11,s11
ffffffffc02016fc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016fe:	bf35                	j	ffffffffc020163a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201700:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201704:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201708:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020170a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020170c:	bfd9                	j	ffffffffc02016e2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020170e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201710:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201714:	01174463          	blt	a4,a7,ffffffffc020171c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201718:	1a088e63          	beqz	a7,ffffffffc02018d4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020171c:	000a3603          	ld	a2,0(s4)
ffffffffc0201720:	46c1                	li	a3,16
ffffffffc0201722:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201724:	2781                	sext.w	a5,a5
ffffffffc0201726:	876e                	mv	a4,s11
ffffffffc0201728:	85a6                	mv	a1,s1
ffffffffc020172a:	854a                	mv	a0,s2
ffffffffc020172c:	e37ff0ef          	jal	ra,ffffffffc0201562 <printnum>
            break;
ffffffffc0201730:	bde1                	j	ffffffffc0201608 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201732:	000a2503          	lw	a0,0(s4)
ffffffffc0201736:	85a6                	mv	a1,s1
ffffffffc0201738:	0a21                	addi	s4,s4,8
ffffffffc020173a:	9902                	jalr	s2
            break;
ffffffffc020173c:	b5f1                	j	ffffffffc0201608 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020173e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201740:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201744:	01174463          	blt	a4,a7,ffffffffc020174c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201748:	18088163          	beqz	a7,ffffffffc02018ca <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020174c:	000a3603          	ld	a2,0(s4)
ffffffffc0201750:	46a9                	li	a3,10
ffffffffc0201752:	8a2e                	mv	s4,a1
ffffffffc0201754:	bfc1                	j	ffffffffc0201724 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201756:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020175a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020175c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020175e:	bdf1                	j	ffffffffc020163a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201760:	85a6                	mv	a1,s1
ffffffffc0201762:	02500513          	li	a0,37
ffffffffc0201766:	9902                	jalr	s2
            break;
ffffffffc0201768:	b545                	j	ffffffffc0201608 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020176a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020176e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201770:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201772:	b5e1                	j	ffffffffc020163a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201774:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201776:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020177a:	01174463          	blt	a4,a7,ffffffffc0201782 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020177e:	14088163          	beqz	a7,ffffffffc02018c0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201782:	000a3603          	ld	a2,0(s4)
ffffffffc0201786:	46a1                	li	a3,8
ffffffffc0201788:	8a2e                	mv	s4,a1
ffffffffc020178a:	bf69                	j	ffffffffc0201724 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020178c:	03000513          	li	a0,48
ffffffffc0201790:	85a6                	mv	a1,s1
ffffffffc0201792:	e03e                	sd	a5,0(sp)
ffffffffc0201794:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201796:	85a6                	mv	a1,s1
ffffffffc0201798:	07800513          	li	a0,120
ffffffffc020179c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020179e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02017a0:	6782                	ld	a5,0(sp)
ffffffffc02017a2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017a4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02017a8:	bfb5                	j	ffffffffc0201724 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017aa:	000a3403          	ld	s0,0(s4)
ffffffffc02017ae:	008a0713          	addi	a4,s4,8
ffffffffc02017b2:	e03a                	sd	a4,0(sp)
ffffffffc02017b4:	14040263          	beqz	s0,ffffffffc02018f8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02017b8:	0fb05763          	blez	s11,ffffffffc02018a6 <vprintfmt+0x2d8>
ffffffffc02017bc:	02d00693          	li	a3,45
ffffffffc02017c0:	0cd79163          	bne	a5,a3,ffffffffc0201882 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017c4:	00044783          	lbu	a5,0(s0)
ffffffffc02017c8:	0007851b          	sext.w	a0,a5
ffffffffc02017cc:	cf85                	beqz	a5,ffffffffc0201804 <vprintfmt+0x236>
ffffffffc02017ce:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017d2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017d6:	000c4563          	bltz	s8,ffffffffc02017e0 <vprintfmt+0x212>
ffffffffc02017da:	3c7d                	addiw	s8,s8,-1
ffffffffc02017dc:	036c0263          	beq	s8,s6,ffffffffc0201800 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02017e0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017e2:	0e0c8e63          	beqz	s9,ffffffffc02018de <vprintfmt+0x310>
ffffffffc02017e6:	3781                	addiw	a5,a5,-32
ffffffffc02017e8:	0ef47b63          	bgeu	s0,a5,ffffffffc02018de <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02017ec:	03f00513          	li	a0,63
ffffffffc02017f0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017f2:	000a4783          	lbu	a5,0(s4)
ffffffffc02017f6:	3dfd                	addiw	s11,s11,-1
ffffffffc02017f8:	0a05                	addi	s4,s4,1
ffffffffc02017fa:	0007851b          	sext.w	a0,a5
ffffffffc02017fe:	ffe1                	bnez	a5,ffffffffc02017d6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201800:	01b05963          	blez	s11,ffffffffc0201812 <vprintfmt+0x244>
ffffffffc0201804:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201806:	85a6                	mv	a1,s1
ffffffffc0201808:	02000513          	li	a0,32
ffffffffc020180c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020180e:	fe0d9be3          	bnez	s11,ffffffffc0201804 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201812:	6a02                	ld	s4,0(sp)
ffffffffc0201814:	bbd5                	j	ffffffffc0201608 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201816:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201818:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020181c:	01174463          	blt	a4,a7,ffffffffc0201824 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201820:	08088d63          	beqz	a7,ffffffffc02018ba <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201824:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201828:	0a044d63          	bltz	s0,ffffffffc02018e2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020182c:	8622                	mv	a2,s0
ffffffffc020182e:	8a66                	mv	s4,s9
ffffffffc0201830:	46a9                	li	a3,10
ffffffffc0201832:	bdcd                	j	ffffffffc0201724 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201834:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201838:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020183a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020183c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201840:	8fb5                	xor	a5,a5,a3
ffffffffc0201842:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201846:	02d74163          	blt	a4,a3,ffffffffc0201868 <vprintfmt+0x29a>
ffffffffc020184a:	00369793          	slli	a5,a3,0x3
ffffffffc020184e:	97de                	add	a5,a5,s7
ffffffffc0201850:	639c                	ld	a5,0(a5)
ffffffffc0201852:	cb99                	beqz	a5,ffffffffc0201868 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201854:	86be                	mv	a3,a5
ffffffffc0201856:	00001617          	auipc	a2,0x1
ffffffffc020185a:	efa60613          	addi	a2,a2,-262 # ffffffffc0202750 <best_fit_pmm_manager+0x68>
ffffffffc020185e:	85a6                	mv	a1,s1
ffffffffc0201860:	854a                	mv	a0,s2
ffffffffc0201862:	0ce000ef          	jal	ra,ffffffffc0201930 <printfmt>
ffffffffc0201866:	b34d                	j	ffffffffc0201608 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201868:	00001617          	auipc	a2,0x1
ffffffffc020186c:	ed860613          	addi	a2,a2,-296 # ffffffffc0202740 <best_fit_pmm_manager+0x58>
ffffffffc0201870:	85a6                	mv	a1,s1
ffffffffc0201872:	854a                	mv	a0,s2
ffffffffc0201874:	0bc000ef          	jal	ra,ffffffffc0201930 <printfmt>
ffffffffc0201878:	bb41                	j	ffffffffc0201608 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020187a:	00001417          	auipc	s0,0x1
ffffffffc020187e:	ebe40413          	addi	s0,s0,-322 # ffffffffc0202738 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201882:	85e2                	mv	a1,s8
ffffffffc0201884:	8522                	mv	a0,s0
ffffffffc0201886:	e43e                	sd	a5,8(sp)
ffffffffc0201888:	c79ff0ef          	jal	ra,ffffffffc0201500 <strnlen>
ffffffffc020188c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201890:	01b05b63          	blez	s11,ffffffffc02018a6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201894:	67a2                	ld	a5,8(sp)
ffffffffc0201896:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020189a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020189c:	85a6                	mv	a1,s1
ffffffffc020189e:	8552                	mv	a0,s4
ffffffffc02018a0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018a2:	fe0d9ce3          	bnez	s11,ffffffffc020189a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a6:	00044783          	lbu	a5,0(s0)
ffffffffc02018aa:	00140a13          	addi	s4,s0,1
ffffffffc02018ae:	0007851b          	sext.w	a0,a5
ffffffffc02018b2:	d3a5                	beqz	a5,ffffffffc0201812 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018b4:	05e00413          	li	s0,94
ffffffffc02018b8:	bf39                	j	ffffffffc02017d6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02018ba:	000a2403          	lw	s0,0(s4)
ffffffffc02018be:	b7ad                	j	ffffffffc0201828 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02018c0:	000a6603          	lwu	a2,0(s4)
ffffffffc02018c4:	46a1                	li	a3,8
ffffffffc02018c6:	8a2e                	mv	s4,a1
ffffffffc02018c8:	bdb1                	j	ffffffffc0201724 <vprintfmt+0x156>
ffffffffc02018ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02018ce:	46a9                	li	a3,10
ffffffffc02018d0:	8a2e                	mv	s4,a1
ffffffffc02018d2:	bd89                	j	ffffffffc0201724 <vprintfmt+0x156>
ffffffffc02018d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02018d8:	46c1                	li	a3,16
ffffffffc02018da:	8a2e                	mv	s4,a1
ffffffffc02018dc:	b5a1                	j	ffffffffc0201724 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02018de:	9902                	jalr	s2
ffffffffc02018e0:	bf09                	j	ffffffffc02017f2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02018e2:	85a6                	mv	a1,s1
ffffffffc02018e4:	02d00513          	li	a0,45
ffffffffc02018e8:	e03e                	sd	a5,0(sp)
ffffffffc02018ea:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018ec:	6782                	ld	a5,0(sp)
ffffffffc02018ee:	8a66                	mv	s4,s9
ffffffffc02018f0:	40800633          	neg	a2,s0
ffffffffc02018f4:	46a9                	li	a3,10
ffffffffc02018f6:	b53d                	j	ffffffffc0201724 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02018f8:	03b05163          	blez	s11,ffffffffc020191a <vprintfmt+0x34c>
ffffffffc02018fc:	02d00693          	li	a3,45
ffffffffc0201900:	f6d79de3          	bne	a5,a3,ffffffffc020187a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201904:	00001417          	auipc	s0,0x1
ffffffffc0201908:	e3440413          	addi	s0,s0,-460 # ffffffffc0202738 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020190c:	02800793          	li	a5,40
ffffffffc0201910:	02800513          	li	a0,40
ffffffffc0201914:	00140a13          	addi	s4,s0,1
ffffffffc0201918:	bd6d                	j	ffffffffc02017d2 <vprintfmt+0x204>
ffffffffc020191a:	00001a17          	auipc	s4,0x1
ffffffffc020191e:	e1fa0a13          	addi	s4,s4,-481 # ffffffffc0202739 <best_fit_pmm_manager+0x51>
ffffffffc0201922:	02800513          	li	a0,40
ffffffffc0201926:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020192a:	05e00413          	li	s0,94
ffffffffc020192e:	b565                	j	ffffffffc02017d6 <vprintfmt+0x208>

ffffffffc0201930 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201930:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201932:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201936:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201938:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020193a:	ec06                	sd	ra,24(sp)
ffffffffc020193c:	f83a                	sd	a4,48(sp)
ffffffffc020193e:	fc3e                	sd	a5,56(sp)
ffffffffc0201940:	e0c2                	sd	a6,64(sp)
ffffffffc0201942:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201944:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201946:	c89ff0ef          	jal	ra,ffffffffc02015ce <vprintfmt>
}
ffffffffc020194a:	60e2                	ld	ra,24(sp)
ffffffffc020194c:	6161                	addi	sp,sp,80
ffffffffc020194e:	8082                	ret

ffffffffc0201950 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201950:	715d                	addi	sp,sp,-80
ffffffffc0201952:	e486                	sd	ra,72(sp)
ffffffffc0201954:	e0a6                	sd	s1,64(sp)
ffffffffc0201956:	fc4a                	sd	s2,56(sp)
ffffffffc0201958:	f84e                	sd	s3,48(sp)
ffffffffc020195a:	f452                	sd	s4,40(sp)
ffffffffc020195c:	f056                	sd	s5,32(sp)
ffffffffc020195e:	ec5a                	sd	s6,24(sp)
ffffffffc0201960:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201962:	c901                	beqz	a0,ffffffffc0201972 <readline+0x22>
ffffffffc0201964:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201966:	00001517          	auipc	a0,0x1
ffffffffc020196a:	dea50513          	addi	a0,a0,-534 # ffffffffc0202750 <best_fit_pmm_manager+0x68>
ffffffffc020196e:	f44fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201972:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201974:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201976:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201978:	4aa9                	li	s5,10
ffffffffc020197a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020197c:	00004b97          	auipc	s7,0x4
ffffffffc0201980:	6b4b8b93          	addi	s7,s7,1716 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201984:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201988:	fa2fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020198c:	00054a63          	bltz	a0,ffffffffc02019a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201990:	00a95a63          	bge	s2,a0,ffffffffc02019a4 <readline+0x54>
ffffffffc0201994:	029a5263          	bge	s4,s1,ffffffffc02019b8 <readline+0x68>
        c = getchar();
ffffffffc0201998:	f92fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020199c:	fe055ae3          	bgez	a0,ffffffffc0201990 <readline+0x40>
            return NULL;
ffffffffc02019a0:	4501                	li	a0,0
ffffffffc02019a2:	a091                	j	ffffffffc02019e6 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02019a4:	03351463          	bne	a0,s3,ffffffffc02019cc <readline+0x7c>
ffffffffc02019a8:	e8a9                	bnez	s1,ffffffffc02019fa <readline+0xaa>
        c = getchar();
ffffffffc02019aa:	f80fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02019ae:	fe0549e3          	bltz	a0,ffffffffc02019a0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b2:	fea959e3          	bge	s2,a0,ffffffffc02019a4 <readline+0x54>
ffffffffc02019b6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019b8:	e42a                	sd	a0,8(sp)
ffffffffc02019ba:	f2efe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02019be:	6522                	ld	a0,8(sp)
ffffffffc02019c0:	009b87b3          	add	a5,s7,s1
ffffffffc02019c4:	2485                	addiw	s1,s1,1
ffffffffc02019c6:	00a78023          	sb	a0,0(a5)
ffffffffc02019ca:	bf7d                	j	ffffffffc0201988 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02019cc:	01550463          	beq	a0,s5,ffffffffc02019d4 <readline+0x84>
ffffffffc02019d0:	fb651ce3          	bne	a0,s6,ffffffffc0201988 <readline+0x38>
            cputchar(c);
ffffffffc02019d4:	f14fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02019d8:	00004517          	auipc	a0,0x4
ffffffffc02019dc:	65850513          	addi	a0,a0,1624 # ffffffffc0206030 <buf>
ffffffffc02019e0:	94aa                	add	s1,s1,a0
ffffffffc02019e2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019e6:	60a6                	ld	ra,72(sp)
ffffffffc02019e8:	6486                	ld	s1,64(sp)
ffffffffc02019ea:	7962                	ld	s2,56(sp)
ffffffffc02019ec:	79c2                	ld	s3,48(sp)
ffffffffc02019ee:	7a22                	ld	s4,40(sp)
ffffffffc02019f0:	7a82                	ld	s5,32(sp)
ffffffffc02019f2:	6b62                	ld	s6,24(sp)
ffffffffc02019f4:	6bc2                	ld	s7,16(sp)
ffffffffc02019f6:	6161                	addi	sp,sp,80
ffffffffc02019f8:	8082                	ret
            cputchar(c);
ffffffffc02019fa:	4521                	li	a0,8
ffffffffc02019fc:	eecfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201a00:	34fd                	addiw	s1,s1,-1
ffffffffc0201a02:	b759                	j	ffffffffc0201988 <readline+0x38>

ffffffffc0201a04 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201a04:	4781                	li	a5,0
ffffffffc0201a06:	00004717          	auipc	a4,0x4
ffffffffc0201a0a:	60273703          	ld	a4,1538(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201a0e:	88ba                	mv	a7,a4
ffffffffc0201a10:	852a                	mv	a0,a0
ffffffffc0201a12:	85be                	mv	a1,a5
ffffffffc0201a14:	863e                	mv	a2,a5
ffffffffc0201a16:	00000073          	ecall
ffffffffc0201a1a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201a1c:	8082                	ret

ffffffffc0201a1e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201a1e:	4781                	li	a5,0
ffffffffc0201a20:	00005717          	auipc	a4,0x5
ffffffffc0201a24:	a6073703          	ld	a4,-1440(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc0201a28:	88ba                	mv	a7,a4
ffffffffc0201a2a:	852a                	mv	a0,a0
ffffffffc0201a2c:	85be                	mv	a1,a5
ffffffffc0201a2e:	863e                	mv	a2,a5
ffffffffc0201a30:	00000073          	ecall
ffffffffc0201a34:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201a36:	8082                	ret

ffffffffc0201a38 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201a38:	4501                	li	a0,0
ffffffffc0201a3a:	00004797          	auipc	a5,0x4
ffffffffc0201a3e:	5c67b783          	ld	a5,1478(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201a42:	88be                	mv	a7,a5
ffffffffc0201a44:	852a                	mv	a0,a0
ffffffffc0201a46:	85aa                	mv	a1,a0
ffffffffc0201a48:	862a                	mv	a2,a0
ffffffffc0201a4a:	00000073          	ecall
ffffffffc0201a4e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201a50:	2501                	sext.w	a0,a0
ffffffffc0201a52:	8082                	ret

ffffffffc0201a54 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201a54:	4781                	li	a5,0
ffffffffc0201a56:	00004717          	auipc	a4,0x4
ffffffffc0201a5a:	5ba73703          	ld	a4,1466(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201a5e:	88ba                	mv	a7,a4
ffffffffc0201a60:	853e                	mv	a0,a5
ffffffffc0201a62:	85be                	mv	a1,a5
ffffffffc0201a64:	863e                	mv	a2,a5
ffffffffc0201a66:	00000073          	ecall
ffffffffc0201a6a:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a6c:	8082                	ret

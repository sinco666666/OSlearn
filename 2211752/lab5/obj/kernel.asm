
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	2fe50513          	addi	a0,a0,766 # ffffffffc02a7330 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	85260613          	addi	a2,a2,-1966 # ffffffffc02b288c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	01e060ef          	jal	ra,ffffffffc0206068 <memset>
    cons_init();                // init the console
ffffffffc020004e:	55c000ef          	jal	ra,ffffffffc02005aa <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	44658593          	addi	a1,a1,1094 # ffffffffc0206498 <etext+0x2>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	45e50513          	addi	a0,a0,1118 # ffffffffc02064b8 <etext+0x22>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	3cb030ef          	jal	ra,ffffffffc0203c34 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5ae000ef          	jal	ra,ffffffffc020061c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5b8000ef          	jal	ra,ffffffffc020062a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	144010ef          	jal	ra,ffffffffc02011ba <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	3d5050ef          	jal	ra,ffffffffc0205c4e <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	7e4010ef          	jal	ra,ffffffffc0201866 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4d2000ef          	jal	ra,ffffffffc0200558 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	594000ef          	jal	ra,ffffffffc020061e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	559050ef          	jal	ra,ffffffffc0205de6 <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	512000ef          	jal	ra,ffffffffc02005ac <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	03e060ef          	jal	ra,ffffffffc02060fe <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	008060ef          	jal	ra,ffffffffc02060fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a16d                	j	ffffffffc02005ac <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	492000ef          	jal	ra,ffffffffc02005ac <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	47c000ef          	jal	ra,ffffffffc02005ac <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	498000ef          	jal	ra,ffffffffc02005e0 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	35650513          	addi	a0,a0,854 # ffffffffc02064c0 <etext+0x2a>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	1b0b8b93          	addi	s7,s7,432 # ffffffffc02a7330 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	15450513          	addi	a0,a0,340 # ffffffffc02a7330 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	5f030313          	addi	t1,t1,1520 # ffffffffc02b27f8 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	29250513          	addi	a0,a0,658 # ffffffffc02064c8 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00008517          	auipc	a0,0x8
ffffffffc0200250:	d5c50513          	addi	a0,a0,-676 # ffffffffc0207fa8 <default_pmm_manager+0x400>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3c0000ef          	jal	ra,ffffffffc0200624 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	26850513          	addi	a0,a0,616 # ffffffffc02064e8 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00008517          	auipc	a0,0x8
ffffffffc02002a4:	d0850513          	addi	a0,a0,-760 # ffffffffc0207fa8 <default_pmm_manager+0x400>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	25250513          	addi	a0,a0,594 # ffffffffc0206508 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	25c50513          	addi	a0,a0,604 # ffffffffc0206528 <etext+0x92>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	1be58593          	addi	a1,a1,446 # ffffffffc0206496 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	26850513          	addi	a0,a0,616 # ffffffffc0206548 <etext+0xb2>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	04458593          	addi	a1,a1,68 # ffffffffc02a7330 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	27450513          	addi	a0,a0,628 # ffffffffc0206568 <etext+0xd2>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	58c58593          	addi	a1,a1,1420 # ffffffffc02b288c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	28050513          	addi	a0,a0,640 # ffffffffc0206588 <etext+0xf2>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	97758593          	addi	a1,a1,-1673 # ffffffffc02b2c8b <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	27250513          	addi	a0,a0,626 # ffffffffc02065a8 <etext+0x112>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	29460613          	addi	a2,a2,660 # ffffffffc02065d8 <etext+0x142>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	2a050513          	addi	a0,a0,672 # ffffffffc02065f0 <etext+0x15a>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	2a860613          	addi	a2,a2,680 # ffffffffc0206608 <etext+0x172>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	2c058593          	addi	a1,a1,704 # ffffffffc0206628 <etext+0x192>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	2c050513          	addi	a0,a0,704 # ffffffffc0206630 <etext+0x19a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	2c260613          	addi	a2,a2,706 # ffffffffc0206640 <etext+0x1aa>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	2e258593          	addi	a1,a1,738 # ffffffffc0206668 <etext+0x1d2>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	2a250513          	addi	a0,a0,674 # ffffffffc0206630 <etext+0x19a>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	2de60613          	addi	a2,a2,734 # ffffffffc0206678 <etext+0x1e2>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	2f658593          	addi	a1,a1,758 # ffffffffc0206698 <etext+0x202>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	28650513          	addi	a0,a0,646 # ffffffffc0206630 <etext+0x19a>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	2c450513          	addi	a0,a0,708 # ffffffffc02066a8 <etext+0x212>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	2ca50513          	addi	a0,a0,714 # ffffffffc02066d0 <etext+0x23a>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	3fa000ef          	jal	ra,ffffffffc0200812 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	324c0c13          	addi	s8,s8,804 # ffffffffc0206740 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	2d490913          	addi	s2,s2,724 # ffffffffc02066f8 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	2d448493          	addi	s1,s1,724 # ffffffffc0206700 <etext+0x26a>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	2d2b0b13          	addi	s6,s6,722 # ffffffffc0206708 <etext+0x272>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	1eaa0a13          	addi	s4,s4,490 # ffffffffc0206628 <etext+0x192>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	2e0d0d13          	addi	s10,s10,736 # ffffffffc0206740 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	3c7050ef          	jal	ra,ffffffffc0206034 <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	3b3050ef          	jal	ra,ffffffffc0206034 <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	393050ef          	jal	ra,ffffffffc0206052 <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	355050ef          	jal	ra,ffffffffc0206052 <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	21050513          	addi	a0,a0,528 # ffffffffc0206728 <etext+0x292>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200534:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200538:	000a7517          	auipc	a0,0xa7
ffffffffc020053c:	1f850513          	addi	a0,a0,504 # ffffffffc02a7730 <ide>
                   size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200544:	953e                	add	a0,a0,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020054c:	32f050ef          	jal	ra,ffffffffc020607a <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200558:	67e1                	lui	a5,0x18
ffffffffc020055a:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc020055e:	000b2717          	auipc	a4,0xb2
ffffffffc0200562:	2af73523          	sd	a5,682(a4) # ffffffffc02b2808 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020056a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	953e                	add	a0,a0,a5
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200576:	02000793          	li	a5,32
ffffffffc020057a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020057e:	00006517          	auipc	a0,0x6
ffffffffc0200582:	20a50513          	addi	a0,a0,522 # ffffffffc0206788 <commands+0x48>
    ticks = 0;
ffffffffc0200586:	000b2797          	auipc	a5,0xb2
ffffffffc020058a:	2607bd23          	sd	zero,634(a5) # ffffffffc02b2800 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020058e:	be3d                	j	ffffffffc02000cc <cprintf>

ffffffffc0200590 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200590:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200594:	000b2797          	auipc	a5,0xb2
ffffffffc0200598:	2747b783          	ld	a5,628(a5) # ffffffffc02b2808 <timebase>
ffffffffc020059c:	953e                	add	a0,a0,a5
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
ffffffffc02005a8:	8082                	ret

ffffffffc02005aa <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ac:	100027f3          	csrr	a5,sstatus
ffffffffc02005b0:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005b2:	0ff57513          	zext.b	a0,a0
ffffffffc02005b6:	e799                	bnez	a5,ffffffffc02005c4 <cons_putc+0x18>
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4885                	li	a7,1
ffffffffc02005be:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005c2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005c4:	1101                	addi	sp,sp,-32
ffffffffc02005c6:	ec06                	sd	ra,24(sp)
ffffffffc02005c8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ca:	05a000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02005ce:	6522                	ld	a0,8(sp)
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4885                	li	a7,1
ffffffffc02005d6:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005da:	60e2                	ld	ra,24(sp)
ffffffffc02005dc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005de:	a081                	j	ffffffffc020061e <intr_enable>

ffffffffc02005e0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e0:	100027f3          	csrr	a5,sstatus
ffffffffc02005e4:	8b89                	andi	a5,a5,2
ffffffffc02005e6:	eb89                	bnez	a5,ffffffffc02005f8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005e8:	4501                	li	a0,0
ffffffffc02005ea:	4581                	li	a1,0
ffffffffc02005ec:	4601                	li	a2,0
ffffffffc02005ee:	4889                	li	a7,2
ffffffffc02005f0:	00000073          	ecall
ffffffffc02005f4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005f6:	8082                	ret
int cons_getc(void) {
ffffffffc02005f8:	1101                	addi	sp,sp,-32
ffffffffc02005fa:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005fc:	028000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0200600:	4501                	li	a0,0
ffffffffc0200602:	4581                	li	a1,0
ffffffffc0200604:	4601                	li	a2,0
ffffffffc0200606:	4889                	li	a7,2
ffffffffc0200608:	00000073          	ecall
ffffffffc020060c:	2501                	sext.w	a0,a0
ffffffffc020060e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200610:	00e000ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc0200614:	60e2                	ld	ra,24(sp)
ffffffffc0200616:	6522                	ld	a0,8(sp)
ffffffffc0200618:	6105                	addi	sp,sp,32
ffffffffc020061a:	8082                	ret

ffffffffc020061c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020061c:	8082                	ret

ffffffffc020061e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020061e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200622:	8082                	ret

ffffffffc0200624 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200624:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200628:	8082                	ret

ffffffffc020062a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020062a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020062e:	00000797          	auipc	a5,0x0
ffffffffc0200632:	65a78793          	addi	a5,a5,1626 # ffffffffc0200c88 <__alltraps>
ffffffffc0200636:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063a:	000407b7          	lui	a5,0x40
ffffffffc020063e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200642:	8082                	ret

ffffffffc0200644 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200644:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064c:	00006517          	auipc	a0,0x6
ffffffffc0200650:	15c50513          	addi	a0,a0,348 # ffffffffc02067a8 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200654:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	a77ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065a:	640c                	ld	a1,8(s0)
ffffffffc020065c:	00006517          	auipc	a0,0x6
ffffffffc0200660:	16450513          	addi	a0,a0,356 # ffffffffc02067c0 <commands+0x80>
ffffffffc0200664:	a69ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200668:	680c                	ld	a1,16(s0)
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	16e50513          	addi	a0,a0,366 # ffffffffc02067d8 <commands+0x98>
ffffffffc0200672:	a5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200676:	6c0c                	ld	a1,24(s0)
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	17850513          	addi	a0,a0,376 # ffffffffc02067f0 <commands+0xb0>
ffffffffc0200680:	a4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200684:	700c                	ld	a1,32(s0)
ffffffffc0200686:	00006517          	auipc	a0,0x6
ffffffffc020068a:	18250513          	addi	a0,a0,386 # ffffffffc0206808 <commands+0xc8>
ffffffffc020068e:	a3fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200692:	740c                	ld	a1,40(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	18c50513          	addi	a0,a0,396 # ffffffffc0206820 <commands+0xe0>
ffffffffc020069c:	a31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a0:	780c                	ld	a1,48(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	19650513          	addi	a0,a0,406 # ffffffffc0206838 <commands+0xf8>
ffffffffc02006aa:	a23ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ae:	7c0c                	ld	a1,56(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	1a050513          	addi	a0,a0,416 # ffffffffc0206850 <commands+0x110>
ffffffffc02006b8:	a15ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006bc:	602c                	ld	a1,64(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	1aa50513          	addi	a0,a0,426 # ffffffffc0206868 <commands+0x128>
ffffffffc02006c6:	a07ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ca:	642c                	ld	a1,72(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	1b450513          	addi	a0,a0,436 # ffffffffc0206880 <commands+0x140>
ffffffffc02006d4:	9f9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d8:	682c                	ld	a1,80(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	1be50513          	addi	a0,a0,446 # ffffffffc0206898 <commands+0x158>
ffffffffc02006e2:	9ebff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e6:	6c2c                	ld	a1,88(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	1c850513          	addi	a0,a0,456 # ffffffffc02068b0 <commands+0x170>
ffffffffc02006f0:	9ddff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f4:	702c                	ld	a1,96(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	1d250513          	addi	a0,a0,466 # ffffffffc02068c8 <commands+0x188>
ffffffffc02006fe:	9cfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200702:	742c                	ld	a1,104(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	1dc50513          	addi	a0,a0,476 # ffffffffc02068e0 <commands+0x1a0>
ffffffffc020070c:	9c1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200710:	782c                	ld	a1,112(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	1e650513          	addi	a0,a0,486 # ffffffffc02068f8 <commands+0x1b8>
ffffffffc020071a:	9b3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071e:	7c2c                	ld	a1,120(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	1f050513          	addi	a0,a0,496 # ffffffffc0206910 <commands+0x1d0>
ffffffffc0200728:	9a5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020072c:	604c                	ld	a1,128(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	1fa50513          	addi	a0,a0,506 # ffffffffc0206928 <commands+0x1e8>
ffffffffc0200736:	997ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073a:	644c                	ld	a1,136(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	20450513          	addi	a0,a0,516 # ffffffffc0206940 <commands+0x200>
ffffffffc0200744:	989ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200748:	684c                	ld	a1,144(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	20e50513          	addi	a0,a0,526 # ffffffffc0206958 <commands+0x218>
ffffffffc0200752:	97bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200756:	6c4c                	ld	a1,152(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	21850513          	addi	a0,a0,536 # ffffffffc0206970 <commands+0x230>
ffffffffc0200760:	96dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200764:	704c                	ld	a1,160(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	22250513          	addi	a0,a0,546 # ffffffffc0206988 <commands+0x248>
ffffffffc020076e:	95fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200772:	744c                	ld	a1,168(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	22c50513          	addi	a0,a0,556 # ffffffffc02069a0 <commands+0x260>
ffffffffc020077c:	951ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200780:	784c                	ld	a1,176(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	23650513          	addi	a0,a0,566 # ffffffffc02069b8 <commands+0x278>
ffffffffc020078a:	943ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078e:	7c4c                	ld	a1,184(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	24050513          	addi	a0,a0,576 # ffffffffc02069d0 <commands+0x290>
ffffffffc0200798:	935ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020079c:	606c                	ld	a1,192(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	24a50513          	addi	a0,a0,586 # ffffffffc02069e8 <commands+0x2a8>
ffffffffc02007a6:	927ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007aa:	646c                	ld	a1,200(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	25450513          	addi	a0,a0,596 # ffffffffc0206a00 <commands+0x2c0>
ffffffffc02007b4:	919ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b8:	686c                	ld	a1,208(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	25e50513          	addi	a0,a0,606 # ffffffffc0206a18 <commands+0x2d8>
ffffffffc02007c2:	90bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c6:	6c6c                	ld	a1,216(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	26850513          	addi	a0,a0,616 # ffffffffc0206a30 <commands+0x2f0>
ffffffffc02007d0:	8fdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d4:	706c                	ld	a1,224(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	27250513          	addi	a0,a0,626 # ffffffffc0206a48 <commands+0x308>
ffffffffc02007de:	8efff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e2:	746c                	ld	a1,232(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	27c50513          	addi	a0,a0,636 # ffffffffc0206a60 <commands+0x320>
ffffffffc02007ec:	8e1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f0:	786c                	ld	a1,240(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	28650513          	addi	a0,a0,646 # ffffffffc0206a78 <commands+0x338>
ffffffffc02007fa:	8d3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fe:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200800:	6402                	ld	s0,0(sp)
ffffffffc0200802:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200804:	00006517          	auipc	a0,0x6
ffffffffc0200808:	28c50513          	addi	a0,a0,652 # ffffffffc0206a90 <commands+0x350>
}
ffffffffc020080c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	8bfff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200812 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200816:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200818:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	00006517          	auipc	a0,0x6
ffffffffc020081e:	28e50513          	addi	a0,a0,654 # ffffffffc0206aa8 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	8a9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200828:	8522                	mv	a0,s0
ffffffffc020082a:	e1bff0ef          	jal	ra,ffffffffc0200644 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082e:	10043583          	ld	a1,256(s0)
ffffffffc0200832:	00006517          	auipc	a0,0x6
ffffffffc0200836:	28e50513          	addi	a0,a0,654 # ffffffffc0206ac0 <commands+0x380>
ffffffffc020083a:	893ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083e:	10843583          	ld	a1,264(s0)
ffffffffc0200842:	00006517          	auipc	a0,0x6
ffffffffc0200846:	29650513          	addi	a0,a0,662 # ffffffffc0206ad8 <commands+0x398>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020084e:	11043583          	ld	a1,272(s0)
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	29e50513          	addi	a0,a0,670 # ffffffffc0206af0 <commands+0x3b0>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200862:	6402                	ld	s0,0(sp)
ffffffffc0200864:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	29a50513          	addi	a0,a0,666 # ffffffffc0206b00 <commands+0x3c0>
}
ffffffffc020086e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200870:	85dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200874 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200874:	1101                	addi	sp,sp,-32
ffffffffc0200876:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200878:	000b2497          	auipc	s1,0xb2
ffffffffc020087c:	f9848493          	addi	s1,s1,-104 # ffffffffc02b2810 <check_mm_struct>
ffffffffc0200880:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200882:	e822                	sd	s0,16(sp)
ffffffffc0200884:	ec06                	sd	ra,24(sp)
ffffffffc0200886:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200888:	cbad                	beqz	a5,ffffffffc02008fa <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020088a:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020088e:	11053583          	ld	a1,272(a0)
ffffffffc0200892:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200896:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020089a:	c7b1                	beqz	a5,ffffffffc02008e6 <pgfault_handler+0x72>
ffffffffc020089c:	11843703          	ld	a4,280(s0)
ffffffffc02008a0:	47bd                	li	a5,15
ffffffffc02008a2:	05700693          	li	a3,87
ffffffffc02008a6:	00f70463          	beq	a4,a5,ffffffffc02008ae <pgfault_handler+0x3a>
ffffffffc02008aa:	05200693          	li	a3,82
ffffffffc02008ae:	00006517          	auipc	a0,0x6
ffffffffc02008b2:	26a50513          	addi	a0,a0,618 # ffffffffc0206b18 <commands+0x3d8>
ffffffffc02008b6:	817ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ba:	6088                	ld	a0,0(s1)
ffffffffc02008bc:	cd1d                	beqz	a0,ffffffffc02008fa <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008be:	000b2717          	auipc	a4,0xb2
ffffffffc02008c2:	fb273703          	ld	a4,-78(a4) # ffffffffc02b2870 <current>
ffffffffc02008c6:	000b2797          	auipc	a5,0xb2
ffffffffc02008ca:	fb27b783          	ld	a5,-78(a5) # ffffffffc02b2878 <idleproc>
ffffffffc02008ce:	04f71663          	bne	a4,a5,ffffffffc020091a <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008d2:	11043603          	ld	a2,272(s0)
ffffffffc02008d6:	11843583          	ld	a1,280(s0)
}
ffffffffc02008da:	6442                	ld	s0,16(sp)
ffffffffc02008dc:	60e2                	ld	ra,24(sp)
ffffffffc02008de:	64a2                	ld	s1,8(sp)
ffffffffc02008e0:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e2:	6190006f          	j	ffffffffc02016fa <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008e6:	11843703          	ld	a4,280(s0)
ffffffffc02008ea:	47bd                	li	a5,15
ffffffffc02008ec:	05500613          	li	a2,85
ffffffffc02008f0:	05700693          	li	a3,87
ffffffffc02008f4:	faf71be3          	bne	a4,a5,ffffffffc02008aa <pgfault_handler+0x36>
ffffffffc02008f8:	bf5d                	j	ffffffffc02008ae <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc02008fa:	000b2797          	auipc	a5,0xb2
ffffffffc02008fe:	f767b783          	ld	a5,-138(a5) # ffffffffc02b2870 <current>
ffffffffc0200902:	cf85                	beqz	a5,ffffffffc020093a <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	11043603          	ld	a2,272(s0)
ffffffffc0200908:	11843583          	ld	a1,280(s0)
}
ffffffffc020090c:	6442                	ld	s0,16(sp)
ffffffffc020090e:	60e2                	ld	ra,24(sp)
ffffffffc0200910:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200912:	7788                	ld	a0,40(a5)
}
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	5e50006f          	j	ffffffffc02016fa <do_pgfault>
        assert(current == idleproc);
ffffffffc020091a:	00006697          	auipc	a3,0x6
ffffffffc020091e:	21e68693          	addi	a3,a3,542 # ffffffffc0206b38 <commands+0x3f8>
ffffffffc0200922:	00006617          	auipc	a2,0x6
ffffffffc0200926:	22e60613          	addi	a2,a2,558 # ffffffffc0206b50 <commands+0x410>
ffffffffc020092a:	06b00593          	li	a1,107
ffffffffc020092e:	00006517          	auipc	a0,0x6
ffffffffc0200932:	23a50513          	addi	a0,a0,570 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200936:	8d3ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020093a:	8522                	mv	a0,s0
ffffffffc020093c:	ed7ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200940:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200944:	11043583          	ld	a1,272(s0)
ffffffffc0200948:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020094c:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200950:	e399                	bnez	a5,ffffffffc0200956 <pgfault_handler+0xe2>
ffffffffc0200952:	05500613          	li	a2,85
ffffffffc0200956:	11843703          	ld	a4,280(s0)
ffffffffc020095a:	47bd                	li	a5,15
ffffffffc020095c:	02f70663          	beq	a4,a5,ffffffffc0200988 <pgfault_handler+0x114>
ffffffffc0200960:	05200693          	li	a3,82
ffffffffc0200964:	00006517          	auipc	a0,0x6
ffffffffc0200968:	1b450513          	addi	a0,a0,436 # ffffffffc0206b18 <commands+0x3d8>
ffffffffc020096c:	f60ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200970:	00006617          	auipc	a2,0x6
ffffffffc0200974:	21060613          	addi	a2,a2,528 # ffffffffc0206b80 <commands+0x440>
ffffffffc0200978:	07200593          	li	a1,114
ffffffffc020097c:	00006517          	auipc	a0,0x6
ffffffffc0200980:	1ec50513          	addi	a0,a0,492 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200984:	885ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200988:	05700693          	li	a3,87
ffffffffc020098c:	bfe1                	j	ffffffffc0200964 <pgfault_handler+0xf0>

ffffffffc020098e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020098e:	11853783          	ld	a5,280(a0)
ffffffffc0200992:	472d                	li	a4,11
ffffffffc0200994:	0786                	slli	a5,a5,0x1
ffffffffc0200996:	8385                	srli	a5,a5,0x1
ffffffffc0200998:	08f76363          	bltu	a4,a5,ffffffffc0200a1e <interrupt_handler+0x90>
ffffffffc020099c:	00006717          	auipc	a4,0x6
ffffffffc02009a0:	29c70713          	addi	a4,a4,668 # ffffffffc0206c38 <commands+0x4f8>
ffffffffc02009a4:	078a                	slli	a5,a5,0x2
ffffffffc02009a6:	97ba                	add	a5,a5,a4
ffffffffc02009a8:	439c                	lw	a5,0(a5)
ffffffffc02009aa:	97ba                	add	a5,a5,a4
ffffffffc02009ac:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ae:	00006517          	auipc	a0,0x6
ffffffffc02009b2:	24a50513          	addi	a0,a0,586 # ffffffffc0206bf8 <commands+0x4b8>
ffffffffc02009b6:	f16ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	21e50513          	addi	a0,a0,542 # ffffffffc0206bd8 <commands+0x498>
ffffffffc02009c2:	f0aff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009c6:	00006517          	auipc	a0,0x6
ffffffffc02009ca:	1d250513          	addi	a0,a0,466 # ffffffffc0206b98 <commands+0x458>
ffffffffc02009ce:	efeff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	1e650513          	addi	a0,a0,486 # ffffffffc0206bb8 <commands+0x478>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009de:	1141                	addi	sp,sp,-16
ffffffffc02009e0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009e2:	bafff0ef          	jal	ra,ffffffffc0200590 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009e6:	000b2697          	auipc	a3,0xb2
ffffffffc02009ea:	e1a68693          	addi	a3,a3,-486 # ffffffffc02b2800 <ticks>
ffffffffc02009ee:	629c                	ld	a5,0(a3)
ffffffffc02009f0:	06400713          	li	a4,100
ffffffffc02009f4:	0785                	addi	a5,a5,1
ffffffffc02009f6:	02e7f733          	remu	a4,a5,a4
ffffffffc02009fa:	e29c                	sd	a5,0(a3)
ffffffffc02009fc:	eb01                	bnez	a4,ffffffffc0200a0c <interrupt_handler+0x7e>
ffffffffc02009fe:	000b2797          	auipc	a5,0xb2
ffffffffc0200a02:	e727b783          	ld	a5,-398(a5) # ffffffffc02b2870 <current>
ffffffffc0200a06:	c399                	beqz	a5,ffffffffc0200a0c <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a08:	4705                	li	a4,1
ffffffffc0200a0a:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a0c:	60a2                	ld	ra,8(sp)
ffffffffc0200a0e:	0141                	addi	sp,sp,16
ffffffffc0200a10:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	20650513          	addi	a0,a0,518 # ffffffffc0206c18 <commands+0x4d8>
ffffffffc0200a1a:	eb2ff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a1e:	bbd5                	j	ffffffffc0200812 <print_trapframe>

ffffffffc0200a20 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a20:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a24:	1101                	addi	sp,sp,-32
ffffffffc0200a26:	e822                	sd	s0,16(sp)
ffffffffc0200a28:	ec06                	sd	ra,24(sp)
ffffffffc0200a2a:	e426                	sd	s1,8(sp)
ffffffffc0200a2c:	473d                	li	a4,15
ffffffffc0200a2e:	842a                	mv	s0,a0
ffffffffc0200a30:	18f76563          	bltu	a4,a5,ffffffffc0200bba <exception_handler+0x19a>
ffffffffc0200a34:	00006717          	auipc	a4,0x6
ffffffffc0200a38:	3cc70713          	addi	a4,a4,972 # ffffffffc0206e00 <commands+0x6c0>
ffffffffc0200a3c:	078a                	slli	a5,a5,0x2
ffffffffc0200a3e:	97ba                	add	a5,a5,a4
ffffffffc0200a40:	439c                	lw	a5,0(a5)
ffffffffc0200a42:	97ba                	add	a5,a5,a4
ffffffffc0200a44:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a46:	00006517          	auipc	a0,0x6
ffffffffc0200a4a:	31250513          	addi	a0,a0,786 # ffffffffc0206d58 <commands+0x618>
ffffffffc0200a4e:	e7eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a52:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a56:	60e2                	ld	ra,24(sp)
ffffffffc0200a58:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a5a:	0791                	addi	a5,a5,4
ffffffffc0200a5c:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a60:	6442                	ld	s0,16(sp)
ffffffffc0200a62:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a64:	5080506f          	j	ffffffffc0205f6c <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	31050513          	addi	a0,a0,784 # ffffffffc0206d78 <commands+0x638>
}
ffffffffc0200a70:	6442                	ld	s0,16(sp)
ffffffffc0200a72:	60e2                	ld	ra,24(sp)
ffffffffc0200a74:	64a2                	ld	s1,8(sp)
ffffffffc0200a76:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a78:	e54ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a7c:	00006517          	auipc	a0,0x6
ffffffffc0200a80:	31c50513          	addi	a0,a0,796 # ffffffffc0206d98 <commands+0x658>
ffffffffc0200a84:	b7f5                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a86:	00006517          	auipc	a0,0x6
ffffffffc0200a8a:	33250513          	addi	a0,a0,818 # ffffffffc0206db8 <commands+0x678>
ffffffffc0200a8e:	b7cd                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	34050513          	addi	a0,a0,832 # ffffffffc0206dd0 <commands+0x690>
ffffffffc0200a98:	e34ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a9c:	8522                	mv	a0,s0
ffffffffc0200a9e:	dd7ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200aa2:	84aa                	mv	s1,a0
ffffffffc0200aa4:	12051d63          	bnez	a0,ffffffffc0200bde <exception_handler+0x1be>
}
ffffffffc0200aa8:	60e2                	ld	ra,24(sp)
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	64a2                	ld	s1,8(sp)
ffffffffc0200aae:	6105                	addi	sp,sp,32
ffffffffc0200ab0:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	33650513          	addi	a0,a0,822 # ffffffffc0206de8 <commands+0x6a8>
ffffffffc0200aba:	e12ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	db5ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	d16d                	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ac8:	8522                	mv	a0,s0
ffffffffc0200aca:	d49ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ace:	86a6                	mv	a3,s1
ffffffffc0200ad0:	00006617          	auipc	a2,0x6
ffffffffc0200ad4:	23860613          	addi	a2,a2,568 # ffffffffc0206d08 <commands+0x5c8>
ffffffffc0200ad8:	0f800593          	li	a1,248
ffffffffc0200adc:	00006517          	auipc	a0,0x6
ffffffffc0200ae0:	08c50513          	addi	a0,a0,140 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200ae4:	f24ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ae8:	00006517          	auipc	a0,0x6
ffffffffc0200aec:	18050513          	addi	a0,a0,384 # ffffffffc0206c68 <commands+0x528>
ffffffffc0200af0:	b741                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200af2:	00006517          	auipc	a0,0x6
ffffffffc0200af6:	19650513          	addi	a0,a0,406 # ffffffffc0206c88 <commands+0x548>
ffffffffc0200afa:	bf9d                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	1ac50513          	addi	a0,a0,428 # ffffffffc0206ca8 <commands+0x568>
ffffffffc0200b04:	b7b5                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b06:	00006517          	auipc	a0,0x6
ffffffffc0200b0a:	1ba50513          	addi	a0,a0,442 # ffffffffc0206cc0 <commands+0x580>
ffffffffc0200b0e:	dbeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b12:	6458                	ld	a4,136(s0)
ffffffffc0200b14:	47a9                	li	a5,10
ffffffffc0200b16:	f8f719e3          	bne	a4,a5,ffffffffc0200aa8 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b1a:	10843783          	ld	a5,264(s0)
ffffffffc0200b1e:	0791                	addi	a5,a5,4
ffffffffc0200b20:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b24:	448050ef          	jal	ra,ffffffffc0205f6c <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b28:	000b2797          	auipc	a5,0xb2
ffffffffc0200b2c:	d487b783          	ld	a5,-696(a5) # ffffffffc02b2870 <current>
ffffffffc0200b30:	6b9c                	ld	a5,16(a5)
ffffffffc0200b32:	8522                	mv	a0,s0
}
ffffffffc0200b34:	6442                	ld	s0,16(sp)
ffffffffc0200b36:	60e2                	ld	ra,24(sp)
ffffffffc0200b38:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3a:	6589                	lui	a1,0x2
ffffffffc0200b3c:	95be                	add	a1,a1,a5
}
ffffffffc0200b3e:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b40:	ac19                	j	ffffffffc0200d56 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	18e50513          	addi	a0,a0,398 # ffffffffc0206cd0 <commands+0x590>
ffffffffc0200b4a:	b71d                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b4c:	00006517          	auipc	a0,0x6
ffffffffc0200b50:	1a450513          	addi	a0,a0,420 # ffffffffc0206cf0 <commands+0x5b0>
ffffffffc0200b54:	d78ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b58:	8522                	mv	a0,s0
ffffffffc0200b5a:	d1bff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b5e:	84aa                	mv	s1,a0
ffffffffc0200b60:	d521                	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b62:	8522                	mv	a0,s0
ffffffffc0200b64:	cafff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b68:	86a6                	mv	a3,s1
ffffffffc0200b6a:	00006617          	auipc	a2,0x6
ffffffffc0200b6e:	19e60613          	addi	a2,a2,414 # ffffffffc0206d08 <commands+0x5c8>
ffffffffc0200b72:	0cd00593          	li	a1,205
ffffffffc0200b76:	00006517          	auipc	a0,0x6
ffffffffc0200b7a:	ff250513          	addi	a0,a0,-14 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200b7e:	e8aff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	1be50513          	addi	a0,a0,446 # ffffffffc0206d40 <commands+0x600>
ffffffffc0200b8a:	d42ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b8e:	8522                	mv	a0,s0
ffffffffc0200b90:	ce5ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b94:	84aa                	mv	s1,a0
ffffffffc0200b96:	f00509e3          	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b9a:	8522                	mv	a0,s0
ffffffffc0200b9c:	c77ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba0:	86a6                	mv	a3,s1
ffffffffc0200ba2:	00006617          	auipc	a2,0x6
ffffffffc0200ba6:	16660613          	addi	a2,a2,358 # ffffffffc0206d08 <commands+0x5c8>
ffffffffc0200baa:	0d700593          	li	a1,215
ffffffffc0200bae:	00006517          	auipc	a0,0x6
ffffffffc0200bb2:	fba50513          	addi	a0,a0,-70 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200bb6:	e52ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bba:	8522                	mv	a0,s0
}
ffffffffc0200bbc:	6442                	ld	s0,16(sp)
ffffffffc0200bbe:	60e2                	ld	ra,24(sp)
ffffffffc0200bc0:	64a2                	ld	s1,8(sp)
ffffffffc0200bc2:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bc4:	b1b9                	j	ffffffffc0200812 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	16260613          	addi	a2,a2,354 # ffffffffc0206d28 <commands+0x5e8>
ffffffffc0200bce:	0d100593          	li	a1,209
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	f9650513          	addi	a0,a0,-106 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
ffffffffc0200be0:	c33ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be4:	86a6                	mv	a3,s1
ffffffffc0200be6:	00006617          	auipc	a2,0x6
ffffffffc0200bea:	12260613          	addi	a2,a2,290 # ffffffffc0206d08 <commands+0x5c8>
ffffffffc0200bee:	0f100593          	li	a1,241
ffffffffc0200bf2:	00006517          	auipc	a0,0x6
ffffffffc0200bf6:	f7650513          	addi	a0,a0,-138 # ffffffffc0206b68 <commands+0x428>
ffffffffc0200bfa:	e0eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200bfe <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bfe:	1101                	addi	sp,sp,-32
ffffffffc0200c00:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c02:	000b2417          	auipc	s0,0xb2
ffffffffc0200c06:	c6e40413          	addi	s0,s0,-914 # ffffffffc02b2870 <current>
ffffffffc0200c0a:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c0c:	ec06                	sd	ra,24(sp)
ffffffffc0200c0e:	e426                	sd	s1,8(sp)
ffffffffc0200c10:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c12:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c16:	cf1d                	beqz	a4,ffffffffc0200c54 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c18:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c1c:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c20:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c22:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c26:	0206c463          	bltz	a3,ffffffffc0200c4e <trap+0x50>
        exception_handler(tf);
ffffffffc0200c2a:	df7ff0ef          	jal	ra,ffffffffc0200a20 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c2e:	601c                	ld	a5,0(s0)
ffffffffc0200c30:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c34:	e499                	bnez	s1,ffffffffc0200c42 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c36:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c3a:	8b05                	andi	a4,a4,1
ffffffffc0200c3c:	e329                	bnez	a4,ffffffffc0200c7e <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c3e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c40:	eb85                	bnez	a5,ffffffffc0200c70 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c42:	60e2                	ld	ra,24(sp)
ffffffffc0200c44:	6442                	ld	s0,16(sp)
ffffffffc0200c46:	64a2                	ld	s1,8(sp)
ffffffffc0200c48:	6902                	ld	s2,0(sp)
ffffffffc0200c4a:	6105                	addi	sp,sp,32
ffffffffc0200c4c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c4e:	d41ff0ef          	jal	ra,ffffffffc020098e <interrupt_handler>
ffffffffc0200c52:	bff1                	j	ffffffffc0200c2e <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c54:	0006c863          	bltz	a3,ffffffffc0200c64 <trap+0x66>
}
ffffffffc0200c58:	6442                	ld	s0,16(sp)
ffffffffc0200c5a:	60e2                	ld	ra,24(sp)
ffffffffc0200c5c:	64a2                	ld	s1,8(sp)
ffffffffc0200c5e:	6902                	ld	s2,0(sp)
ffffffffc0200c60:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c62:	bb7d                	j	ffffffffc0200a20 <exception_handler>
}
ffffffffc0200c64:	6442                	ld	s0,16(sp)
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c6e:	b305                	j	ffffffffc020098e <interrupt_handler>
}
ffffffffc0200c70:	6442                	ld	s0,16(sp)
ffffffffc0200c72:	60e2                	ld	ra,24(sp)
ffffffffc0200c74:	64a2                	ld	s1,8(sp)
ffffffffc0200c76:	6902                	ld	s2,0(sp)
ffffffffc0200c78:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c7a:	2060506f          	j	ffffffffc0205e80 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c7e:	555d                	li	a0,-9
ffffffffc0200c80:	5b4040ef          	jal	ra,ffffffffc0205234 <do_exit>
            if (current->need_resched) {
ffffffffc0200c84:	601c                	ld	a5,0(s0)
ffffffffc0200c86:	bf65                	j	ffffffffc0200c3e <trap+0x40>

ffffffffc0200c88 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c88:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c8c:	00011463          	bnez	sp,ffffffffc0200c94 <__alltraps+0xc>
ffffffffc0200c90:	14002173          	csrr	sp,sscratch
ffffffffc0200c94:	712d                	addi	sp,sp,-288
ffffffffc0200c96:	e002                	sd	zero,0(sp)
ffffffffc0200c98:	e406                	sd	ra,8(sp)
ffffffffc0200c9a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c9c:	f012                	sd	tp,32(sp)
ffffffffc0200c9e:	f416                	sd	t0,40(sp)
ffffffffc0200ca0:	f81a                	sd	t1,48(sp)
ffffffffc0200ca2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ca4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ca6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ca8:	e8aa                	sd	a0,80(sp)
ffffffffc0200caa:	ecae                	sd	a1,88(sp)
ffffffffc0200cac:	f0b2                	sd	a2,96(sp)
ffffffffc0200cae:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cb2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cb4:	e142                	sd	a6,128(sp)
ffffffffc0200cb6:	e546                	sd	a7,136(sp)
ffffffffc0200cb8:	e94a                	sd	s2,144(sp)
ffffffffc0200cba:	ed4e                	sd	s3,152(sp)
ffffffffc0200cbc:	f152                	sd	s4,160(sp)
ffffffffc0200cbe:	f556                	sd	s5,168(sp)
ffffffffc0200cc0:	f95a                	sd	s6,176(sp)
ffffffffc0200cc2:	fd5e                	sd	s7,184(sp)
ffffffffc0200cc4:	e1e2                	sd	s8,192(sp)
ffffffffc0200cc6:	e5e6                	sd	s9,200(sp)
ffffffffc0200cc8:	e9ea                	sd	s10,208(sp)
ffffffffc0200cca:	edee                	sd	s11,216(sp)
ffffffffc0200ccc:	f1f2                	sd	t3,224(sp)
ffffffffc0200cce:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd0:	f9fa                	sd	t5,240(sp)
ffffffffc0200cd2:	fdfe                	sd	t6,248(sp)
ffffffffc0200cd4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cd8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cdc:	14102973          	csrr	s2,sepc
ffffffffc0200ce0:	143029f3          	csrr	s3,stval
ffffffffc0200ce4:	14202a73          	csrr	s4,scause
ffffffffc0200ce8:	e822                	sd	s0,16(sp)
ffffffffc0200cea:	e226                	sd	s1,256(sp)
ffffffffc0200cec:	e64a                	sd	s2,264(sp)
ffffffffc0200cee:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cf2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cf4:	f0bff0ef          	jal	ra,ffffffffc0200bfe <trap>

ffffffffc0200cf8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cf8:	6492                	ld	s1,256(sp)
ffffffffc0200cfa:	6932                	ld	s2,264(sp)
ffffffffc0200cfc:	1004f413          	andi	s0,s1,256
ffffffffc0200d00:	e401                	bnez	s0,ffffffffc0200d08 <__trapret+0x10>
ffffffffc0200d02:	1200                	addi	s0,sp,288
ffffffffc0200d04:	14041073          	csrw	sscratch,s0
ffffffffc0200d08:	10049073          	csrw	sstatus,s1
ffffffffc0200d0c:	14191073          	csrw	sepc,s2
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
ffffffffc0200d12:	61e2                	ld	gp,24(sp)
ffffffffc0200d14:	7202                	ld	tp,32(sp)
ffffffffc0200d16:	72a2                	ld	t0,40(sp)
ffffffffc0200d18:	7342                	ld	t1,48(sp)
ffffffffc0200d1a:	73e2                	ld	t2,56(sp)
ffffffffc0200d1c:	6406                	ld	s0,64(sp)
ffffffffc0200d1e:	64a6                	ld	s1,72(sp)
ffffffffc0200d20:	6546                	ld	a0,80(sp)
ffffffffc0200d22:	65e6                	ld	a1,88(sp)
ffffffffc0200d24:	7606                	ld	a2,96(sp)
ffffffffc0200d26:	76a6                	ld	a3,104(sp)
ffffffffc0200d28:	7746                	ld	a4,112(sp)
ffffffffc0200d2a:	77e6                	ld	a5,120(sp)
ffffffffc0200d2c:	680a                	ld	a6,128(sp)
ffffffffc0200d2e:	68aa                	ld	a7,136(sp)
ffffffffc0200d30:	694a                	ld	s2,144(sp)
ffffffffc0200d32:	69ea                	ld	s3,152(sp)
ffffffffc0200d34:	7a0a                	ld	s4,160(sp)
ffffffffc0200d36:	7aaa                	ld	s5,168(sp)
ffffffffc0200d38:	7b4a                	ld	s6,176(sp)
ffffffffc0200d3a:	7bea                	ld	s7,184(sp)
ffffffffc0200d3c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d3e:	6cae                	ld	s9,200(sp)
ffffffffc0200d40:	6d4e                	ld	s10,208(sp)
ffffffffc0200d42:	6dee                	ld	s11,216(sp)
ffffffffc0200d44:	7e0e                	ld	t3,224(sp)
ffffffffc0200d46:	7eae                	ld	t4,232(sp)
ffffffffc0200d48:	7f4e                	ld	t5,240(sp)
ffffffffc0200d4a:	7fee                	ld	t6,248(sp)
ffffffffc0200d4c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d4e:	10200073          	sret

ffffffffc0200d52 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d52:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d54:	b755                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200d56 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d56:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d5a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d5e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d62:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d66:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d6a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d6e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d72:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d76:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d7a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d7c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d7e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d80:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d82:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d84:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d86:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d88:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d8a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d8c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d8e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d90:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d92:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d94:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d96:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d98:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d9a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d9c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d9e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200da2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200da4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200da6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200da8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200daa:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dac:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dae:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200db2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200db4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200db6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200db8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dba:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dbc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dbe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc0:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dc2:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dc4:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dc6:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dc8:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dca:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dcc:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dce:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dd2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dd4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dd6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dd8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dda:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200ddc:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dde:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200de2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200de4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200de6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200de8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200dea:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200dec:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dee:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200df2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200df4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200df6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200df8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200dfa:	812e                	mv	sp,a1
ffffffffc0200dfc:	bdf5                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200dfe <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200dfe:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e00:	00006697          	auipc	a3,0x6
ffffffffc0200e04:	04068693          	addi	a3,a3,64 # ffffffffc0206e40 <commands+0x700>
ffffffffc0200e08:	00006617          	auipc	a2,0x6
ffffffffc0200e0c:	d4860613          	addi	a2,a2,-696 # ffffffffc0206b50 <commands+0x410>
ffffffffc0200e10:	06d00593          	li	a1,109
ffffffffc0200e14:	00006517          	auipc	a0,0x6
ffffffffc0200e18:	04c50513          	addi	a0,a0,76 # ffffffffc0206e60 <commands+0x720>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e1c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e1e:	beaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e22 <mm_create>:
mm_create(void) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e24:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e28:	e022                	sd	s0,0(sp)
ffffffffc0200e2a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e2c:	4de010ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc0200e30:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e32:	c505                	beqz	a0,ffffffffc0200e5a <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e34:	e408                	sd	a0,8(s0)
ffffffffc0200e36:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e38:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e3c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e40:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e44:	000b2797          	auipc	a5,0xb2
ffffffffc0200e48:	9ec7a783          	lw	a5,-1556(a5) # ffffffffc02b2830 <swap_init_ok>
ffffffffc0200e4c:	ef81                	bnez	a5,ffffffffc0200e64 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0200e4e:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200e52:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200e56:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200e5a:	60a2                	ld	ra,8(sp)
ffffffffc0200e5c:	8522                	mv	a0,s0
ffffffffc0200e5e:	6402                	ld	s0,0(sp)
ffffffffc0200e60:	0141                	addi	sp,sp,16
ffffffffc0200e62:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e64:	148010ef          	jal	ra,ffffffffc0201fac <swap_init_mm>
ffffffffc0200e68:	b7ed                	j	ffffffffc0200e52 <mm_create+0x30>

ffffffffc0200e6a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e6a:	1101                	addi	sp,sp,-32
ffffffffc0200e6c:	e04a                	sd	s2,0(sp)
ffffffffc0200e6e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e70:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e74:	e822                	sd	s0,16(sp)
ffffffffc0200e76:	e426                	sd	s1,8(sp)
ffffffffc0200e78:	ec06                	sd	ra,24(sp)
ffffffffc0200e7a:	84ae                	mv	s1,a1
ffffffffc0200e7c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e7e:	48c010ef          	jal	ra,ffffffffc020230a <kmalloc>
    if (vma != NULL) {
ffffffffc0200e82:	c509                	beqz	a0,ffffffffc0200e8c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200e84:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200e88:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200e8a:	cd00                	sw	s0,24(a0)
}
ffffffffc0200e8c:	60e2                	ld	ra,24(sp)
ffffffffc0200e8e:	6442                	ld	s0,16(sp)
ffffffffc0200e90:	64a2                	ld	s1,8(sp)
ffffffffc0200e92:	6902                	ld	s2,0(sp)
ffffffffc0200e94:	6105                	addi	sp,sp,32
ffffffffc0200e96:	8082                	ret

ffffffffc0200e98 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200e98:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200e9a:	c505                	beqz	a0,ffffffffc0200ec2 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200e9c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200e9e:	c501                	beqz	a0,ffffffffc0200ea6 <find_vma+0xe>
ffffffffc0200ea0:	651c                	ld	a5,8(a0)
ffffffffc0200ea2:	02f5f263          	bgeu	a1,a5,ffffffffc0200ec6 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ea6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200ea8:	00f68d63          	beq	a3,a5,ffffffffc0200ec2 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200eac:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200eb0:	00e5e663          	bltu	a1,a4,ffffffffc0200ebc <find_vma+0x24>
ffffffffc0200eb4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200eb8:	00e5ec63          	bltu	a1,a4,ffffffffc0200ed0 <find_vma+0x38>
ffffffffc0200ebc:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200ebe:	fef697e3          	bne	a3,a5,ffffffffc0200eac <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200ec2:	4501                	li	a0,0
}
ffffffffc0200ec4:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ec6:	691c                	ld	a5,16(a0)
ffffffffc0200ec8:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200ea6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200ecc:	ea88                	sd	a0,16(a3)
ffffffffc0200ece:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200ed0:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200ed4:	ea88                	sd	a0,16(a3)
ffffffffc0200ed6:	8082                	ret

ffffffffc0200ed8 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ed8:	6590                	ld	a2,8(a1)
ffffffffc0200eda:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200ede:	1141                	addi	sp,sp,-16
ffffffffc0200ee0:	e406                	sd	ra,8(sp)
ffffffffc0200ee2:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ee4:	01066763          	bltu	a2,a6,ffffffffc0200ef2 <insert_vma_struct+0x1a>
ffffffffc0200ee8:	a085                	j	ffffffffc0200f48 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200eea:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200eee:	04e66863          	bltu	a2,a4,ffffffffc0200f3e <insert_vma_struct+0x66>
ffffffffc0200ef2:	86be                	mv	a3,a5
ffffffffc0200ef4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200ef6:	fef51ae3          	bne	a0,a5,ffffffffc0200eea <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200efa:	02a68463          	beq	a3,a0,ffffffffc0200f22 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200efe:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f02:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f06:	08e8f163          	bgeu	a7,a4,ffffffffc0200f88 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f0a:	04e66f63          	bltu	a2,a4,ffffffffc0200f68 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f0e:	00f50a63          	beq	a0,a5,ffffffffc0200f22 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f12:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f16:	05076963          	bltu	a4,a6,ffffffffc0200f68 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f1a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f1e:	02c77363          	bgeu	a4,a2,ffffffffc0200f44 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f22:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f24:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f26:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f2a:	e390                	sd	a2,0(a5)
ffffffffc0200f2c:	e690                	sd	a2,8(a3)
}
ffffffffc0200f2e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f30:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f32:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f34:	0017079b          	addiw	a5,a4,1
ffffffffc0200f38:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f3a:	0141                	addi	sp,sp,16
ffffffffc0200f3c:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f3e:	fca690e3          	bne	a3,a0,ffffffffc0200efe <insert_vma_struct+0x26>
ffffffffc0200f42:	bfd1                	j	ffffffffc0200f16 <insert_vma_struct+0x3e>
ffffffffc0200f44:	ebbff0ef          	jal	ra,ffffffffc0200dfe <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f48:	00006697          	auipc	a3,0x6
ffffffffc0200f4c:	f2868693          	addi	a3,a3,-216 # ffffffffc0206e70 <commands+0x730>
ffffffffc0200f50:	00006617          	auipc	a2,0x6
ffffffffc0200f54:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206b50 <commands+0x410>
ffffffffc0200f58:	07400593          	li	a1,116
ffffffffc0200f5c:	00006517          	auipc	a0,0x6
ffffffffc0200f60:	f0450513          	addi	a0,a0,-252 # ffffffffc0206e60 <commands+0x720>
ffffffffc0200f64:	aa4ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f68:	00006697          	auipc	a3,0x6
ffffffffc0200f6c:	f4868693          	addi	a3,a3,-184 # ffffffffc0206eb0 <commands+0x770>
ffffffffc0200f70:	00006617          	auipc	a2,0x6
ffffffffc0200f74:	be060613          	addi	a2,a2,-1056 # ffffffffc0206b50 <commands+0x410>
ffffffffc0200f78:	06c00593          	li	a1,108
ffffffffc0200f7c:	00006517          	auipc	a0,0x6
ffffffffc0200f80:	ee450513          	addi	a0,a0,-284 # ffffffffc0206e60 <commands+0x720>
ffffffffc0200f84:	a84ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f88:	00006697          	auipc	a3,0x6
ffffffffc0200f8c:	f0868693          	addi	a3,a3,-248 # ffffffffc0206e90 <commands+0x750>
ffffffffc0200f90:	00006617          	auipc	a2,0x6
ffffffffc0200f94:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206b50 <commands+0x410>
ffffffffc0200f98:	06b00593          	li	a1,107
ffffffffc0200f9c:	00006517          	auipc	a0,0x6
ffffffffc0200fa0:	ec450513          	addi	a0,a0,-316 # ffffffffc0206e60 <commands+0x720>
ffffffffc0200fa4:	a64ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fa8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0200fa8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0200faa:	1141                	addi	sp,sp,-16
ffffffffc0200fac:	e406                	sd	ra,8(sp)
ffffffffc0200fae:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0200fb0:	e78d                	bnez	a5,ffffffffc0200fda <mm_destroy+0x32>
ffffffffc0200fb2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fb4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fb6:	00a40c63          	beq	s0,a0,ffffffffc0200fce <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fba:	6118                	ld	a4,0(a0)
ffffffffc0200fbc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200fbe:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fc0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fc2:	e398                	sd	a4,0(a5)
ffffffffc0200fc4:	3f6010ef          	jal	ra,ffffffffc02023ba <kfree>
    return listelm->next;
ffffffffc0200fc8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fca:	fea418e3          	bne	s0,a0,ffffffffc0200fba <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0200fce:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200fd0:	6402                	ld	s0,0(sp)
ffffffffc0200fd2:	60a2                	ld	ra,8(sp)
ffffffffc0200fd4:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200fd6:	3e40106f          	j	ffffffffc02023ba <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0200fda:	00006697          	auipc	a3,0x6
ffffffffc0200fde:	ef668693          	addi	a3,a3,-266 # ffffffffc0206ed0 <commands+0x790>
ffffffffc0200fe2:	00006617          	auipc	a2,0x6
ffffffffc0200fe6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0206b50 <commands+0x410>
ffffffffc0200fea:	09400593          	li	a1,148
ffffffffc0200fee:	00006517          	auipc	a0,0x6
ffffffffc0200ff2:	e7250513          	addi	a0,a0,-398 # ffffffffc0206e60 <commands+0x720>
ffffffffc0200ff6:	a12ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200ffa <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0200ffa:	7139                	addi	sp,sp,-64
ffffffffc0200ffc:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0200ffe:	6405                	lui	s0,0x1
ffffffffc0201000:	147d                	addi	s0,s0,-1
ffffffffc0201002:	77fd                	lui	a5,0xfffff
ffffffffc0201004:	9622                	add	a2,a2,s0
ffffffffc0201006:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0201008:	f426                	sd	s1,40(sp)
ffffffffc020100a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020100c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201010:	f04a                	sd	s2,32(sp)
ffffffffc0201012:	ec4e                	sd	s3,24(sp)
ffffffffc0201014:	e852                	sd	s4,16(sp)
ffffffffc0201016:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0201018:	002005b7          	lui	a1,0x200
ffffffffc020101c:	00f67433          	and	s0,a2,a5
ffffffffc0201020:	06b4e363          	bltu	s1,a1,ffffffffc0201086 <mm_map+0x8c>
ffffffffc0201024:	0684f163          	bgeu	s1,s0,ffffffffc0201086 <mm_map+0x8c>
ffffffffc0201028:	4785                	li	a5,1
ffffffffc020102a:	07fe                	slli	a5,a5,0x1f
ffffffffc020102c:	0487ed63          	bltu	a5,s0,ffffffffc0201086 <mm_map+0x8c>
ffffffffc0201030:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201032:	cd21                	beqz	a0,ffffffffc020108a <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201034:	85a6                	mv	a1,s1
ffffffffc0201036:	8ab6                	mv	s5,a3
ffffffffc0201038:	8a3a                	mv	s4,a4
ffffffffc020103a:	e5fff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc020103e:	c501                	beqz	a0,ffffffffc0201046 <mm_map+0x4c>
ffffffffc0201040:	651c                	ld	a5,8(a0)
ffffffffc0201042:	0487e263          	bltu	a5,s0,ffffffffc0201086 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201046:	03000513          	li	a0,48
ffffffffc020104a:	2c0010ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc020104e:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201050:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201052:	02090163          	beqz	s2,ffffffffc0201074 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0201056:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0201058:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020105c:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0201060:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0201064:	85ca                	mv	a1,s2
ffffffffc0201066:	e73ff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020106a:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020106c:	000a0463          	beqz	s4,ffffffffc0201074 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201070:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201074:	70e2                	ld	ra,56(sp)
ffffffffc0201076:	7442                	ld	s0,48(sp)
ffffffffc0201078:	74a2                	ld	s1,40(sp)
ffffffffc020107a:	7902                	ld	s2,32(sp)
ffffffffc020107c:	69e2                	ld	s3,24(sp)
ffffffffc020107e:	6a42                	ld	s4,16(sp)
ffffffffc0201080:	6aa2                	ld	s5,8(sp)
ffffffffc0201082:	6121                	addi	sp,sp,64
ffffffffc0201084:	8082                	ret
        return -E_INVAL;
ffffffffc0201086:	5575                	li	a0,-3
ffffffffc0201088:	b7f5                	j	ffffffffc0201074 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020108a:	00006697          	auipc	a3,0x6
ffffffffc020108e:	e5e68693          	addi	a3,a3,-418 # ffffffffc0206ee8 <commands+0x7a8>
ffffffffc0201092:	00006617          	auipc	a2,0x6
ffffffffc0201096:	abe60613          	addi	a2,a2,-1346 # ffffffffc0206b50 <commands+0x410>
ffffffffc020109a:	0a700593          	li	a1,167
ffffffffc020109e:	00006517          	auipc	a0,0x6
ffffffffc02010a2:	dc250513          	addi	a0,a0,-574 # ffffffffc0206e60 <commands+0x720>
ffffffffc02010a6:	962ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02010aa <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02010aa:	7139                	addi	sp,sp,-64
ffffffffc02010ac:	fc06                	sd	ra,56(sp)
ffffffffc02010ae:	f822                	sd	s0,48(sp)
ffffffffc02010b0:	f426                	sd	s1,40(sp)
ffffffffc02010b2:	f04a                	sd	s2,32(sp)
ffffffffc02010b4:	ec4e                	sd	s3,24(sp)
ffffffffc02010b6:	e852                	sd	s4,16(sp)
ffffffffc02010b8:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02010ba:	c52d                	beqz	a0,ffffffffc0201124 <dup_mmap+0x7a>
ffffffffc02010bc:	892a                	mv	s2,a0
ffffffffc02010be:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02010c0:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02010c2:	e595                	bnez	a1,ffffffffc02010ee <dup_mmap+0x44>
ffffffffc02010c4:	a085                	j	ffffffffc0201124 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02010c6:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02010c8:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee0>
        vma->vm_end = vm_end;
ffffffffc02010cc:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02010d0:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02010d4:	e05ff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02010d8:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc02010dc:	fe843603          	ld	a2,-24(s0)
ffffffffc02010e0:	6c8c                	ld	a1,24(s1)
ffffffffc02010e2:	01893503          	ld	a0,24(s2)
ffffffffc02010e6:	4701                	li	a4,0
ffffffffc02010e8:	6e6030ef          	jal	ra,ffffffffc02047ce <copy_range>
ffffffffc02010ec:	e105                	bnez	a0,ffffffffc020110c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02010ee:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02010f0:	02848863          	beq	s1,s0,ffffffffc0201120 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02010f4:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02010f8:	fe843a83          	ld	s5,-24(s0)
ffffffffc02010fc:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201100:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201104:	206010ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc0201108:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020110a:	fd55                	bnez	a0,ffffffffc02010c6 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020110c:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020110e:	70e2                	ld	ra,56(sp)
ffffffffc0201110:	7442                	ld	s0,48(sp)
ffffffffc0201112:	74a2                	ld	s1,40(sp)
ffffffffc0201114:	7902                	ld	s2,32(sp)
ffffffffc0201116:	69e2                	ld	s3,24(sp)
ffffffffc0201118:	6a42                	ld	s4,16(sp)
ffffffffc020111a:	6aa2                	ld	s5,8(sp)
ffffffffc020111c:	6121                	addi	sp,sp,64
ffffffffc020111e:	8082                	ret
    return 0;
ffffffffc0201120:	4501                	li	a0,0
ffffffffc0201122:	b7f5                	j	ffffffffc020110e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201124:	00006697          	auipc	a3,0x6
ffffffffc0201128:	dd468693          	addi	a3,a3,-556 # ffffffffc0206ef8 <commands+0x7b8>
ffffffffc020112c:	00006617          	auipc	a2,0x6
ffffffffc0201130:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201134:	0c000593          	li	a1,192
ffffffffc0201138:	00006517          	auipc	a0,0x6
ffffffffc020113c:	d2850513          	addi	a0,a0,-728 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201140:	8c8ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201144 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201144:	1101                	addi	sp,sp,-32
ffffffffc0201146:	ec06                	sd	ra,24(sp)
ffffffffc0201148:	e822                	sd	s0,16(sp)
ffffffffc020114a:	e426                	sd	s1,8(sp)
ffffffffc020114c:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020114e:	c531                	beqz	a0,ffffffffc020119a <exit_mmap+0x56>
ffffffffc0201150:	591c                	lw	a5,48(a0)
ffffffffc0201152:	84aa                	mv	s1,a0
ffffffffc0201154:	e3b9                	bnez	a5,ffffffffc020119a <exit_mmap+0x56>
    return listelm->next;
ffffffffc0201156:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0201158:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020115c:	02850663          	beq	a0,s0,ffffffffc0201188 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201160:	ff043603          	ld	a2,-16(s0)
ffffffffc0201164:	fe843583          	ld	a1,-24(s0)
ffffffffc0201168:	854a                	mv	a0,s2
ffffffffc020116a:	560020ef          	jal	ra,ffffffffc02036ca <unmap_range>
ffffffffc020116e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0201170:	fe8498e3          	bne	s1,s0,ffffffffc0201160 <exit_mmap+0x1c>
ffffffffc0201174:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0201176:	00848c63          	beq	s1,s0,ffffffffc020118e <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020117a:	ff043603          	ld	a2,-16(s0)
ffffffffc020117e:	fe843583          	ld	a1,-24(s0)
ffffffffc0201182:	854a                	mv	a0,s2
ffffffffc0201184:	68c020ef          	jal	ra,ffffffffc0203810 <exit_range>
ffffffffc0201188:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020118a:	fe8498e3          	bne	s1,s0,ffffffffc020117a <exit_mmap+0x36>
    }
}
ffffffffc020118e:	60e2                	ld	ra,24(sp)
ffffffffc0201190:	6442                	ld	s0,16(sp)
ffffffffc0201192:	64a2                	ld	s1,8(sp)
ffffffffc0201194:	6902                	ld	s2,0(sp)
ffffffffc0201196:	6105                	addi	sp,sp,32
ffffffffc0201198:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020119a:	00006697          	auipc	a3,0x6
ffffffffc020119e:	d7e68693          	addi	a3,a3,-642 # ffffffffc0206f18 <commands+0x7d8>
ffffffffc02011a2:	00006617          	auipc	a2,0x6
ffffffffc02011a6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206b50 <commands+0x410>
ffffffffc02011aa:	0d600593          	li	a1,214
ffffffffc02011ae:	00006517          	auipc	a0,0x6
ffffffffc02011b2:	cb250513          	addi	a0,a0,-846 # ffffffffc0206e60 <commands+0x720>
ffffffffc02011b6:	852ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02011ba <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02011ba:	7139                	addi	sp,sp,-64
ffffffffc02011bc:	f822                	sd	s0,48(sp)
ffffffffc02011be:	f426                	sd	s1,40(sp)
ffffffffc02011c0:	fc06                	sd	ra,56(sp)
ffffffffc02011c2:	f04a                	sd	s2,32(sp)
ffffffffc02011c4:	ec4e                	sd	s3,24(sp)
ffffffffc02011c6:	e852                	sd	s4,16(sp)
ffffffffc02011c8:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02011ca:	c59ff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
    assert(mm != NULL);
ffffffffc02011ce:	84aa                	mv	s1,a0
ffffffffc02011d0:	03200413          	li	s0,50
ffffffffc02011d4:	e919                	bnez	a0,ffffffffc02011ea <vmm_init+0x30>
ffffffffc02011d6:	a991                	j	ffffffffc020162a <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02011d8:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011da:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02011dc:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02011e0:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02011e2:	8526                	mv	a0,s1
ffffffffc02011e4:	cf5ff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02011e8:	c80d                	beqz	s0,ffffffffc020121a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011ea:	03000513          	li	a0,48
ffffffffc02011ee:	11c010ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc02011f2:	85aa                	mv	a1,a0
ffffffffc02011f4:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02011f8:	f165                	bnez	a0,ffffffffc02011d8 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02011fa:	00006697          	auipc	a3,0x6
ffffffffc02011fe:	fae68693          	addi	a3,a3,-82 # ffffffffc02071a8 <commands+0xa68>
ffffffffc0201202:	00006617          	auipc	a2,0x6
ffffffffc0201206:	94e60613          	addi	a2,a2,-1714 # ffffffffc0206b50 <commands+0x410>
ffffffffc020120a:	11300593          	li	a1,275
ffffffffc020120e:	00006517          	auipc	a0,0x6
ffffffffc0201212:	c5250513          	addi	a0,a0,-942 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201216:	ff3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020121a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020121e:	1f900913          	li	s2,505
ffffffffc0201222:	a819                	j	ffffffffc0201238 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201224:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201226:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201228:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020122c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020122e:	8526                	mv	a0,s1
ffffffffc0201230:	ca9ff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201234:	03240a63          	beq	s0,s2,ffffffffc0201268 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201238:	03000513          	li	a0,48
ffffffffc020123c:	0ce010ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc0201240:	85aa                	mv	a1,a0
ffffffffc0201242:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201246:	fd79                	bnez	a0,ffffffffc0201224 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201248:	00006697          	auipc	a3,0x6
ffffffffc020124c:	f6068693          	addi	a3,a3,-160 # ffffffffc02071a8 <commands+0xa68>
ffffffffc0201250:	00006617          	auipc	a2,0x6
ffffffffc0201254:	90060613          	addi	a2,a2,-1792 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201258:	11900593          	li	a1,281
ffffffffc020125c:	00006517          	auipc	a0,0x6
ffffffffc0201260:	c0450513          	addi	a0,a0,-1020 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201264:	fa5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201268:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020126a:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc020126c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201270:	2cf48d63          	beq	s1,a5,ffffffffc020154a <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201274:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c75c>
ffffffffc0201278:	ffe70613          	addi	a2,a4,-2
ffffffffc020127c:	24d61763          	bne	a2,a3,ffffffffc02014ca <vmm_init+0x310>
ffffffffc0201280:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201284:	24e69363          	bne	a3,a4,ffffffffc02014ca <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201288:	0715                	addi	a4,a4,5
ffffffffc020128a:	679c                	ld	a5,8(a5)
ffffffffc020128c:	feb712e3          	bne	a4,a1,ffffffffc0201270 <vmm_init+0xb6>
ffffffffc0201290:	4a1d                	li	s4,7
ffffffffc0201292:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201294:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201298:	85a2                	mv	a1,s0
ffffffffc020129a:	8526                	mv	a0,s1
ffffffffc020129c:	bfdff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc02012a0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012a2:	30050463          	beqz	a0,ffffffffc02015aa <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012a6:	00140593          	addi	a1,s0,1
ffffffffc02012aa:	8526                	mv	a0,s1
ffffffffc02012ac:	bedff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc02012b0:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02012b2:	2c050c63          	beqz	a0,ffffffffc020158a <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012b6:	85d2                	mv	a1,s4
ffffffffc02012b8:	8526                	mv	a0,s1
ffffffffc02012ba:	bdfff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
        assert(vma3 == NULL);
ffffffffc02012be:	2a051663          	bnez	a0,ffffffffc020156a <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012c2:	00340593          	addi	a1,s0,3
ffffffffc02012c6:	8526                	mv	a0,s1
ffffffffc02012c8:	bd1ff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
        assert(vma4 == NULL);
ffffffffc02012cc:	30051f63          	bnez	a0,ffffffffc02015ea <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012d0:	00440593          	addi	a1,s0,4
ffffffffc02012d4:	8526                	mv	a0,s1
ffffffffc02012d6:	bc3ff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
        assert(vma5 == NULL);
ffffffffc02012da:	2e051863          	bnez	a0,ffffffffc02015ca <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02012de:	00893783          	ld	a5,8(s2)
ffffffffc02012e2:	20879463          	bne	a5,s0,ffffffffc02014ea <vmm_init+0x330>
ffffffffc02012e6:	01093783          	ld	a5,16(s2)
ffffffffc02012ea:	20fa1063          	bne	s4,a5,ffffffffc02014ea <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02012ee:	0089b783          	ld	a5,8(s3)
ffffffffc02012f2:	20879c63          	bne	a5,s0,ffffffffc020150a <vmm_init+0x350>
ffffffffc02012f6:	0109b783          	ld	a5,16(s3)
ffffffffc02012fa:	20fa1863          	bne	s4,a5,ffffffffc020150a <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012fe:	0415                	addi	s0,s0,5
ffffffffc0201300:	0a15                	addi	s4,s4,5
ffffffffc0201302:	f9541be3          	bne	s0,s5,ffffffffc0201298 <vmm_init+0xde>
ffffffffc0201306:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201308:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020130a:	85a2                	mv	a1,s0
ffffffffc020130c:	8526                	mv	a0,s1
ffffffffc020130e:	b8bff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc0201312:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201316:	c90d                	beqz	a0,ffffffffc0201348 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201318:	6914                	ld	a3,16(a0)
ffffffffc020131a:	6510                	ld	a2,8(a0)
ffffffffc020131c:	00006517          	auipc	a0,0x6
ffffffffc0201320:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207038 <commands+0x8f8>
ffffffffc0201324:	da9fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201328:	00006697          	auipc	a3,0x6
ffffffffc020132c:	d3868693          	addi	a3,a3,-712 # ffffffffc0207060 <commands+0x920>
ffffffffc0201330:	00006617          	auipc	a2,0x6
ffffffffc0201334:	82060613          	addi	a2,a2,-2016 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201338:	13b00593          	li	a1,315
ffffffffc020133c:	00006517          	auipc	a0,0x6
ffffffffc0201340:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201344:	ec5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201348:	147d                	addi	s0,s0,-1
ffffffffc020134a:	fd2410e3          	bne	s0,s2,ffffffffc020130a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020134e:	8526                	mv	a0,s1
ffffffffc0201350:	c59ff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201354:	00006517          	auipc	a0,0x6
ffffffffc0201358:	d2450513          	addi	a0,a0,-732 # ffffffffc0207078 <commands+0x938>
ffffffffc020135c:	d71fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201360:	10a020ef          	jal	ra,ffffffffc020346a <nr_free_pages>
ffffffffc0201364:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0201366:	abdff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc020136a:	000b1797          	auipc	a5,0xb1
ffffffffc020136e:	4aa7b323          	sd	a0,1190(a5) # ffffffffc02b2810 <check_mm_struct>
ffffffffc0201372:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0201374:	28050b63          	beqz	a0,ffffffffc020160a <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201378:	000b1497          	auipc	s1,0xb1
ffffffffc020137c:	4d04b483          	ld	s1,1232(s1) # ffffffffc02b2848 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0201380:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201382:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201384:	2e079f63          	bnez	a5,ffffffffc0201682 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201388:	03000513          	li	a0,48
ffffffffc020138c:	77f000ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc0201390:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0201392:	18050c63          	beqz	a0,ffffffffc020152a <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0201396:	002007b7          	lui	a5,0x200
ffffffffc020139a:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc020139e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013a0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013a2:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013a6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013a8:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013ac:	b2dff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013b0:	10000593          	li	a1,256
ffffffffc02013b4:	8522                	mv	a0,s0
ffffffffc02013b6:	ae3ff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc02013ba:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02013be:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02013c2:	2ea99063          	bne	s3,a0,ffffffffc02016a2 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02013c6:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed8>
    for (i = 0; i < 100; i ++) {
ffffffffc02013ca:	0785                	addi	a5,a5,1
ffffffffc02013cc:	fee79de3          	bne	a5,a4,ffffffffc02013c6 <vmm_init+0x20c>
        sum += i;
ffffffffc02013d0:	6705                	lui	a4,0x1
ffffffffc02013d2:	10000793          	li	a5,256
ffffffffc02013d6:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8862>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02013da:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02013de:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02013e2:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02013e4:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02013e6:	fec79ce3          	bne	a5,a2,ffffffffc02013de <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02013ea:	2e071863          	bnez	a4,ffffffffc02016da <vmm_init+0x520>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc02013ee:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02013f0:	000b1a97          	auipc	s5,0xb1
ffffffffc02013f4:	460a8a93          	addi	s5,s5,1120 # ffffffffc02b2850 <npage>
ffffffffc02013f8:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013fc:	078a                	slli	a5,a5,0x2
ffffffffc02013fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201400:	2cc7f163          	bgeu	a5,a2,ffffffffc02016c2 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201404:	00007a17          	auipc	s4,0x7
ffffffffc0201408:	71ca3a03          	ld	s4,1820(s4) # ffffffffc0208b20 <nbase>
ffffffffc020140c:	414787b3          	sub	a5,a5,s4
ffffffffc0201410:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201412:	8799                	srai	a5,a5,0x6
ffffffffc0201414:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201416:	00c79713          	slli	a4,a5,0xc
ffffffffc020141a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020141c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201420:	24c77563          	bgeu	a4,a2,ffffffffc020166a <vmm_init+0x4b0>
ffffffffc0201424:	000b1997          	auipc	s3,0xb1
ffffffffc0201428:	4449b983          	ld	s3,1092(s3) # ffffffffc02b2868 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020142c:	4581                	li	a1,0
ffffffffc020142e:	8526                	mv	a0,s1
ffffffffc0201430:	99b6                	add	s3,s3,a3
ffffffffc0201432:	670020ef          	jal	ra,ffffffffc0203aa2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201436:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020143a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020143e:	078a                	slli	a5,a5,0x2
ffffffffc0201440:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201442:	28e7f063          	bgeu	a5,a4,ffffffffc02016c2 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201446:	000b1997          	auipc	s3,0xb1
ffffffffc020144a:	41298993          	addi	s3,s3,1042 # ffffffffc02b2858 <pages>
ffffffffc020144e:	0009b503          	ld	a0,0(s3)
ffffffffc0201452:	414787b3          	sub	a5,a5,s4
ffffffffc0201456:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201458:	953e                	add	a0,a0,a5
ffffffffc020145a:	4585                	li	a1,1
ffffffffc020145c:	7cf010ef          	jal	ra,ffffffffc020342a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201460:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201462:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201466:	078a                	slli	a5,a5,0x2
ffffffffc0201468:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020146a:	24e7fc63          	bgeu	a5,a4,ffffffffc02016c2 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020146e:	0009b503          	ld	a0,0(s3)
ffffffffc0201472:	414787b3          	sub	a5,a5,s4
ffffffffc0201476:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201478:	4585                	li	a1,1
ffffffffc020147a:	953e                	add	a0,a0,a5
ffffffffc020147c:	7af010ef          	jal	ra,ffffffffc020342a <free_pages>
    pgdir[0] = 0;
ffffffffc0201480:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc0201484:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0201488:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020148a:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc020148e:	b1bff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201492:	000b1797          	auipc	a5,0xb1
ffffffffc0201496:	3607bf23          	sd	zero,894(a5) # ffffffffc02b2810 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020149a:	7d1010ef          	jal	ra,ffffffffc020346a <nr_free_pages>
ffffffffc020149e:	1aa91663          	bne	s2,a0,ffffffffc020164a <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014a2:	00006517          	auipc	a0,0x6
ffffffffc02014a6:	cce50513          	addi	a0,a0,-818 # ffffffffc0207170 <commands+0xa30>
ffffffffc02014aa:	c23fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014ae:	7442                	ld	s0,48(sp)
ffffffffc02014b0:	70e2                	ld	ra,56(sp)
ffffffffc02014b2:	74a2                	ld	s1,40(sp)
ffffffffc02014b4:	7902                	ld	s2,32(sp)
ffffffffc02014b6:	69e2                	ld	s3,24(sp)
ffffffffc02014b8:	6a42                	ld	s4,16(sp)
ffffffffc02014ba:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	cd450513          	addi	a0,a0,-812 # ffffffffc0207190 <commands+0xa50>
}
ffffffffc02014c4:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014c6:	c07fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014ca:	00006697          	auipc	a3,0x6
ffffffffc02014ce:	a8668693          	addi	a3,a3,-1402 # ffffffffc0206f50 <commands+0x810>
ffffffffc02014d2:	00005617          	auipc	a2,0x5
ffffffffc02014d6:	67e60613          	addi	a2,a2,1662 # ffffffffc0206b50 <commands+0x410>
ffffffffc02014da:	12200593          	li	a1,290
ffffffffc02014de:	00006517          	auipc	a0,0x6
ffffffffc02014e2:	98250513          	addi	a0,a0,-1662 # ffffffffc0206e60 <commands+0x720>
ffffffffc02014e6:	d23fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02014ea:	00006697          	auipc	a3,0x6
ffffffffc02014ee:	aee68693          	addi	a3,a3,-1298 # ffffffffc0206fd8 <commands+0x898>
ffffffffc02014f2:	00005617          	auipc	a2,0x5
ffffffffc02014f6:	65e60613          	addi	a2,a2,1630 # ffffffffc0206b50 <commands+0x410>
ffffffffc02014fa:	13200593          	li	a1,306
ffffffffc02014fe:	00006517          	auipc	a0,0x6
ffffffffc0201502:	96250513          	addi	a0,a0,-1694 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201506:	d03fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020150a:	00006697          	auipc	a3,0x6
ffffffffc020150e:	afe68693          	addi	a3,a3,-1282 # ffffffffc0207008 <commands+0x8c8>
ffffffffc0201512:	00005617          	auipc	a2,0x5
ffffffffc0201516:	63e60613          	addi	a2,a2,1598 # ffffffffc0206b50 <commands+0x410>
ffffffffc020151a:	13300593          	li	a1,307
ffffffffc020151e:	00006517          	auipc	a0,0x6
ffffffffc0201522:	94250513          	addi	a0,a0,-1726 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201526:	ce3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020152a:	00006697          	auipc	a3,0x6
ffffffffc020152e:	c7e68693          	addi	a3,a3,-898 # ffffffffc02071a8 <commands+0xa68>
ffffffffc0201532:	00005617          	auipc	a2,0x5
ffffffffc0201536:	61e60613          	addi	a2,a2,1566 # ffffffffc0206b50 <commands+0x410>
ffffffffc020153a:	15200593          	li	a1,338
ffffffffc020153e:	00006517          	auipc	a0,0x6
ffffffffc0201542:	92250513          	addi	a0,a0,-1758 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201546:	cc3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020154a:	00006697          	auipc	a3,0x6
ffffffffc020154e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0206f38 <commands+0x7f8>
ffffffffc0201552:	00005617          	auipc	a2,0x5
ffffffffc0201556:	5fe60613          	addi	a2,a2,1534 # ffffffffc0206b50 <commands+0x410>
ffffffffc020155a:	12000593          	li	a1,288
ffffffffc020155e:	00006517          	auipc	a0,0x6
ffffffffc0201562:	90250513          	addi	a0,a0,-1790 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201566:	ca3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc020156a:	00006697          	auipc	a3,0x6
ffffffffc020156e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0206fa8 <commands+0x868>
ffffffffc0201572:	00005617          	auipc	a2,0x5
ffffffffc0201576:	5de60613          	addi	a2,a2,1502 # ffffffffc0206b50 <commands+0x410>
ffffffffc020157a:	12c00593          	li	a1,300
ffffffffc020157e:	00006517          	auipc	a0,0x6
ffffffffc0201582:	8e250513          	addi	a0,a0,-1822 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201586:	c83fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc020158a:	00006697          	auipc	a3,0x6
ffffffffc020158e:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0206f98 <commands+0x858>
ffffffffc0201592:	00005617          	auipc	a2,0x5
ffffffffc0201596:	5be60613          	addi	a2,a2,1470 # ffffffffc0206b50 <commands+0x410>
ffffffffc020159a:	12a00593          	li	a1,298
ffffffffc020159e:	00006517          	auipc	a0,0x6
ffffffffc02015a2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0206e60 <commands+0x720>
ffffffffc02015a6:	c63fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02015aa:	00006697          	auipc	a3,0x6
ffffffffc02015ae:	9de68693          	addi	a3,a3,-1570 # ffffffffc0206f88 <commands+0x848>
ffffffffc02015b2:	00005617          	auipc	a2,0x5
ffffffffc02015b6:	59e60613          	addi	a2,a2,1438 # ffffffffc0206b50 <commands+0x410>
ffffffffc02015ba:	12800593          	li	a1,296
ffffffffc02015be:	00006517          	auipc	a0,0x6
ffffffffc02015c2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0206e60 <commands+0x720>
ffffffffc02015c6:	c43fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc02015ca:	00006697          	auipc	a3,0x6
ffffffffc02015ce:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0206fc8 <commands+0x888>
ffffffffc02015d2:	00005617          	auipc	a2,0x5
ffffffffc02015d6:	57e60613          	addi	a2,a2,1406 # ffffffffc0206b50 <commands+0x410>
ffffffffc02015da:	13000593          	li	a1,304
ffffffffc02015de:	00006517          	auipc	a0,0x6
ffffffffc02015e2:	88250513          	addi	a0,a0,-1918 # ffffffffc0206e60 <commands+0x720>
ffffffffc02015e6:	c23fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc02015ea:	00006697          	auipc	a3,0x6
ffffffffc02015ee:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0206fb8 <commands+0x878>
ffffffffc02015f2:	00005617          	auipc	a2,0x5
ffffffffc02015f6:	55e60613          	addi	a2,a2,1374 # ffffffffc0206b50 <commands+0x410>
ffffffffc02015fa:	12e00593          	li	a1,302
ffffffffc02015fe:	00006517          	auipc	a0,0x6
ffffffffc0201602:	86250513          	addi	a0,a0,-1950 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201606:	c03fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020160a:	00006697          	auipc	a3,0x6
ffffffffc020160e:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0207098 <commands+0x958>
ffffffffc0201612:	00005617          	auipc	a2,0x5
ffffffffc0201616:	53e60613          	addi	a2,a2,1342 # ffffffffc0206b50 <commands+0x410>
ffffffffc020161a:	14b00593          	li	a1,331
ffffffffc020161e:	00006517          	auipc	a0,0x6
ffffffffc0201622:	84250513          	addi	a0,a0,-1982 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201626:	be3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020162a:	00006697          	auipc	a3,0x6
ffffffffc020162e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0206ee8 <commands+0x7a8>
ffffffffc0201632:	00005617          	auipc	a2,0x5
ffffffffc0201636:	51e60613          	addi	a2,a2,1310 # ffffffffc0206b50 <commands+0x410>
ffffffffc020163a:	10c00593          	li	a1,268
ffffffffc020163e:	00006517          	auipc	a0,0x6
ffffffffc0201642:	82250513          	addi	a0,a0,-2014 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201646:	bc3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020164a:	00006697          	auipc	a3,0x6
ffffffffc020164e:	afe68693          	addi	a3,a3,-1282 # ffffffffc0207148 <commands+0xa08>
ffffffffc0201652:	00005617          	auipc	a2,0x5
ffffffffc0201656:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206b50 <commands+0x410>
ffffffffc020165a:	17000593          	li	a1,368
ffffffffc020165e:	00006517          	auipc	a0,0x6
ffffffffc0201662:	80250513          	addi	a0,a0,-2046 # ffffffffc0206e60 <commands+0x720>
ffffffffc0201666:	ba3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020166a:	00006617          	auipc	a2,0x6
ffffffffc020166e:	ab660613          	addi	a2,a2,-1354 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0201672:	06900593          	li	a1,105
ffffffffc0201676:	00006517          	auipc	a0,0x6
ffffffffc020167a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0207110 <commands+0x9d0>
ffffffffc020167e:	b8bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201682:	00006697          	auipc	a3,0x6
ffffffffc0201686:	a2e68693          	addi	a3,a3,-1490 # ffffffffc02070b0 <commands+0x970>
ffffffffc020168a:	00005617          	auipc	a2,0x5
ffffffffc020168e:	4c660613          	addi	a2,a2,1222 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201692:	14f00593          	li	a1,335
ffffffffc0201696:	00005517          	auipc	a0,0x5
ffffffffc020169a:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206e60 <commands+0x720>
ffffffffc020169e:	b6bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016a2:	00006697          	auipc	a3,0x6
ffffffffc02016a6:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02070c0 <commands+0x980>
ffffffffc02016aa:	00005617          	auipc	a2,0x5
ffffffffc02016ae:	4a660613          	addi	a2,a2,1190 # ffffffffc0206b50 <commands+0x410>
ffffffffc02016b2:	15700593          	li	a1,343
ffffffffc02016b6:	00005517          	auipc	a0,0x5
ffffffffc02016ba:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206e60 <commands+0x720>
ffffffffc02016be:	b4bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016c2:	00006617          	auipc	a2,0x6
ffffffffc02016c6:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc02016ca:	06200593          	li	a1,98
ffffffffc02016ce:	00006517          	auipc	a0,0x6
ffffffffc02016d2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02016d6:	b33fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc02016da:	00006697          	auipc	a3,0x6
ffffffffc02016de:	a0668693          	addi	a3,a3,-1530 # ffffffffc02070e0 <commands+0x9a0>
ffffffffc02016e2:	00005617          	auipc	a2,0x5
ffffffffc02016e6:	46e60613          	addi	a2,a2,1134 # ffffffffc0206b50 <commands+0x410>
ffffffffc02016ea:	16300593          	li	a1,355
ffffffffc02016ee:	00005517          	auipc	a0,0x5
ffffffffc02016f2:	77250513          	addi	a0,a0,1906 # ffffffffc0206e60 <commands+0x720>
ffffffffc02016f6:	b13fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02016fa <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02016fa:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02016fc:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02016fe:	e822                	sd	s0,16(sp)
ffffffffc0201700:	e426                	sd	s1,8(sp)
ffffffffc0201702:	ec06                	sd	ra,24(sp)
ffffffffc0201704:	e04a                	sd	s2,0(sp)
ffffffffc0201706:	8432                	mv	s0,a2
ffffffffc0201708:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020170a:	f8eff0ef          	jal	ra,ffffffffc0200e98 <find_vma>

    pgfault_num++;
ffffffffc020170e:	000b1797          	auipc	a5,0xb1
ffffffffc0201712:	10a7a783          	lw	a5,266(a5) # ffffffffc02b2818 <pgfault_num>
ffffffffc0201716:	2785                	addiw	a5,a5,1
ffffffffc0201718:	000b1717          	auipc	a4,0xb1
ffffffffc020171c:	10f72023          	sw	a5,256(a4) # ffffffffc02b2818 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201720:	c931                	beqz	a0,ffffffffc0201774 <do_pgfault+0x7a>
ffffffffc0201722:	651c                	ld	a5,8(a0)
ffffffffc0201724:	04f46863          	bltu	s0,a5,ffffffffc0201774 <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201728:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020172a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020172c:	8b89                	andi	a5,a5,2
ffffffffc020172e:	e39d                	bnez	a5,ffffffffc0201754 <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201730:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201732:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201734:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201736:	4605                	li	a2,1
ffffffffc0201738:	85a2                	mv	a1,s0
ffffffffc020173a:	56b010ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc020173e:	cd21                	beqz	a0,ffffffffc0201796 <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201740:	610c                	ld	a1,0(a0)
ffffffffc0201742:	c999                	beqz	a1,ffffffffc0201758 <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201744:	000b1797          	auipc	a5,0xb1
ffffffffc0201748:	0ec7a783          	lw	a5,236(a5) # ffffffffc02b2830 <swap_init_ok>
ffffffffc020174c:	cf8d                	beqz	a5,ffffffffc0201786 <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020174e:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9b80>
ffffffffc0201752:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0201754:	495d                	li	s2,23
ffffffffc0201756:	bfe9                	j	ffffffffc0201730 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201758:	6c88                	ld	a0,24(s1)
ffffffffc020175a:	864a                	mv	a2,s2
ffffffffc020175c:	85a2                	mv	a1,s0
ffffffffc020175e:	2a6030ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc0201762:	87aa                	mv	a5,a0
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0201764:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201766:	c3a1                	beqz	a5,ffffffffc02017a6 <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc0201768:	60e2                	ld	ra,24(sp)
ffffffffc020176a:	6442                	ld	s0,16(sp)
ffffffffc020176c:	64a2                	ld	s1,8(sp)
ffffffffc020176e:	6902                	ld	s2,0(sp)
ffffffffc0201770:	6105                	addi	sp,sp,32
ffffffffc0201772:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201774:	85a2                	mv	a1,s0
ffffffffc0201776:	00006517          	auipc	a0,0x6
ffffffffc020177a:	a4250513          	addi	a0,a0,-1470 # ffffffffc02071b8 <commands+0xa78>
ffffffffc020177e:	94ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc0201782:	5575                	li	a0,-3
        goto failed;
ffffffffc0201784:	b7d5                	j	ffffffffc0201768 <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201786:	00006517          	auipc	a0,0x6
ffffffffc020178a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0207230 <commands+0xaf0>
ffffffffc020178e:	93ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201792:	5571                	li	a0,-4
            goto failed;
ffffffffc0201794:	bfd1                	j	ffffffffc0201768 <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201796:	00006517          	auipc	a0,0x6
ffffffffc020179a:	a5250513          	addi	a0,a0,-1454 # ffffffffc02071e8 <commands+0xaa8>
ffffffffc020179e:	92ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017a2:	5571                	li	a0,-4
        goto failed;
ffffffffc02017a4:	b7d1                	j	ffffffffc0201768 <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02017a6:	00006517          	auipc	a0,0x6
ffffffffc02017aa:	a6250513          	addi	a0,a0,-1438 # ffffffffc0207208 <commands+0xac8>
ffffffffc02017ae:	91ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017b2:	5571                	li	a0,-4
            goto failed;
ffffffffc02017b4:	bf55                	j	ffffffffc0201768 <do_pgfault+0x6e>

ffffffffc02017b6 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc02017b6:	7179                	addi	sp,sp,-48
ffffffffc02017b8:	f022                	sd	s0,32(sp)
ffffffffc02017ba:	f406                	sd	ra,40(sp)
ffffffffc02017bc:	ec26                	sd	s1,24(sp)
ffffffffc02017be:	e84a                	sd	s2,16(sp)
ffffffffc02017c0:	e44e                	sd	s3,8(sp)
ffffffffc02017c2:	e052                	sd	s4,0(sp)
ffffffffc02017c4:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc02017c6:	c135                	beqz	a0,ffffffffc020182a <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc02017c8:	002007b7          	lui	a5,0x200
ffffffffc02017cc:	04f5e663          	bltu	a1,a5,ffffffffc0201818 <user_mem_check+0x62>
ffffffffc02017d0:	00c584b3          	add	s1,a1,a2
ffffffffc02017d4:	0495f263          	bgeu	a1,s1,ffffffffc0201818 <user_mem_check+0x62>
ffffffffc02017d8:	4785                	li	a5,1
ffffffffc02017da:	07fe                	slli	a5,a5,0x1f
ffffffffc02017dc:	0297ee63          	bltu	a5,s1,ffffffffc0201818 <user_mem_check+0x62>
ffffffffc02017e0:	892a                	mv	s2,a0
ffffffffc02017e2:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02017e4:	6a05                	lui	s4,0x1
ffffffffc02017e6:	a821                	j	ffffffffc02017fe <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02017e8:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02017ec:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02017ee:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02017f0:	c685                	beqz	a3,ffffffffc0201818 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02017f2:	c399                	beqz	a5,ffffffffc02017f8 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02017f4:	02e46263          	bltu	s0,a4,ffffffffc0201818 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02017f8:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02017fa:	04947663          	bgeu	s0,s1,ffffffffc0201846 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02017fe:	85a2                	mv	a1,s0
ffffffffc0201800:	854a                	mv	a0,s2
ffffffffc0201802:	e96ff0ef          	jal	ra,ffffffffc0200e98 <find_vma>
ffffffffc0201806:	c909                	beqz	a0,ffffffffc0201818 <user_mem_check+0x62>
ffffffffc0201808:	6518                	ld	a4,8(a0)
ffffffffc020180a:	00e46763          	bltu	s0,a4,ffffffffc0201818 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020180e:	4d1c                	lw	a5,24(a0)
ffffffffc0201810:	fc099ce3          	bnez	s3,ffffffffc02017e8 <user_mem_check+0x32>
ffffffffc0201814:	8b85                	andi	a5,a5,1
ffffffffc0201816:	f3ed                	bnez	a5,ffffffffc02017f8 <user_mem_check+0x42>
            return 0;
ffffffffc0201818:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc020181a:	70a2                	ld	ra,40(sp)
ffffffffc020181c:	7402                	ld	s0,32(sp)
ffffffffc020181e:	64e2                	ld	s1,24(sp)
ffffffffc0201820:	6942                	ld	s2,16(sp)
ffffffffc0201822:	69a2                	ld	s3,8(sp)
ffffffffc0201824:	6a02                	ld	s4,0(sp)
ffffffffc0201826:	6145                	addi	sp,sp,48
ffffffffc0201828:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc020182a:	c02007b7          	lui	a5,0xc0200
ffffffffc020182e:	4501                	li	a0,0
ffffffffc0201830:	fef5e5e3          	bltu	a1,a5,ffffffffc020181a <user_mem_check+0x64>
ffffffffc0201834:	962e                	add	a2,a2,a1
ffffffffc0201836:	fec5f2e3          	bgeu	a1,a2,ffffffffc020181a <user_mem_check+0x64>
ffffffffc020183a:	c8000537          	lui	a0,0xc8000
ffffffffc020183e:	0505                	addi	a0,a0,1
ffffffffc0201840:	00a63533          	sltu	a0,a2,a0
ffffffffc0201844:	bfd9                	j	ffffffffc020181a <user_mem_check+0x64>
        return 1;
ffffffffc0201846:	4505                	li	a0,1
ffffffffc0201848:	bfc9                	j	ffffffffc020181a <user_mem_check+0x64>

ffffffffc020184a <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020184a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020184c:	00006617          	auipc	a2,0x6
ffffffffc0201850:	8a460613          	addi	a2,a2,-1884 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc0201854:	06200593          	li	a1,98
ffffffffc0201858:	00006517          	auipc	a0,0x6
ffffffffc020185c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0207110 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc0201860:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201862:	9a7fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201866 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201866:	7135                	addi	sp,sp,-160
ffffffffc0201868:	ed06                	sd	ra,152(sp)
ffffffffc020186a:	e922                	sd	s0,144(sp)
ffffffffc020186c:	e526                	sd	s1,136(sp)
ffffffffc020186e:	e14a                	sd	s2,128(sp)
ffffffffc0201870:	fcce                	sd	s3,120(sp)
ffffffffc0201872:	f8d2                	sd	s4,112(sp)
ffffffffc0201874:	f4d6                	sd	s5,104(sp)
ffffffffc0201876:	f0da                	sd	s6,96(sp)
ffffffffc0201878:	ecde                	sd	s7,88(sp)
ffffffffc020187a:	e8e2                	sd	s8,80(sp)
ffffffffc020187c:	e4e6                	sd	s9,72(sp)
ffffffffc020187e:	e0ea                	sd	s10,64(sp)
ffffffffc0201880:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201882:	23c030ef          	jal	ra,ffffffffc0204abe <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201886:	000b1697          	auipc	a3,0xb1
ffffffffc020188a:	f9a6b683          	ld	a3,-102(a3) # ffffffffc02b2820 <max_swap_offset>
ffffffffc020188e:	010007b7          	lui	a5,0x1000
ffffffffc0201892:	ff968713          	addi	a4,a3,-7
ffffffffc0201896:	17e1                	addi	a5,a5,-8
ffffffffc0201898:	42e7e663          	bltu	a5,a4,ffffffffc0201cc4 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020189c:	000a6797          	auipc	a5,0xa6
ffffffffc02018a0:	a4478793          	addi	a5,a5,-1468 # ffffffffc02a72e0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02018a4:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02018a6:	000b1b97          	auipc	s7,0xb1
ffffffffc02018aa:	f82b8b93          	addi	s7,s7,-126 # ffffffffc02b2828 <sm>
ffffffffc02018ae:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02018b2:	9702                	jalr	a4
ffffffffc02018b4:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02018b6:	c10d                	beqz	a0,ffffffffc02018d8 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02018b8:	60ea                	ld	ra,152(sp)
ffffffffc02018ba:	644a                	ld	s0,144(sp)
ffffffffc02018bc:	64aa                	ld	s1,136(sp)
ffffffffc02018be:	79e6                	ld	s3,120(sp)
ffffffffc02018c0:	7a46                	ld	s4,112(sp)
ffffffffc02018c2:	7aa6                	ld	s5,104(sp)
ffffffffc02018c4:	7b06                	ld	s6,96(sp)
ffffffffc02018c6:	6be6                	ld	s7,88(sp)
ffffffffc02018c8:	6c46                	ld	s8,80(sp)
ffffffffc02018ca:	6ca6                	ld	s9,72(sp)
ffffffffc02018cc:	6d06                	ld	s10,64(sp)
ffffffffc02018ce:	7de2                	ld	s11,56(sp)
ffffffffc02018d0:	854a                	mv	a0,s2
ffffffffc02018d2:	690a                	ld	s2,128(sp)
ffffffffc02018d4:	610d                	addi	sp,sp,160
ffffffffc02018d6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02018d8:	000bb783          	ld	a5,0(s7)
ffffffffc02018dc:	00006517          	auipc	a0,0x6
ffffffffc02018e0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207288 <commands+0xb48>
ffffffffc02018e4:	000ad417          	auipc	s0,0xad
ffffffffc02018e8:	eec40413          	addi	s0,s0,-276 # ffffffffc02ae7d0 <free_area>
ffffffffc02018ec:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02018ee:	4785                	li	a5,1
ffffffffc02018f0:	000b1717          	auipc	a4,0xb1
ffffffffc02018f4:	f4f72023          	sw	a5,-192(a4) # ffffffffc02b2830 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02018f8:	fd4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02018fc:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02018fe:	4d01                	li	s10,0
ffffffffc0201900:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201902:	34878163          	beq	a5,s0,ffffffffc0201c44 <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201906:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020190a:	8b09                	andi	a4,a4,2
ffffffffc020190c:	32070e63          	beqz	a4,ffffffffc0201c48 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0201910:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201914:	679c                	ld	a5,8(a5)
ffffffffc0201916:	2d85                	addiw	s11,s11,1
ffffffffc0201918:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc020191c:	fe8795e3          	bne	a5,s0,ffffffffc0201906 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201920:	84ea                	mv	s1,s10
ffffffffc0201922:	349010ef          	jal	ra,ffffffffc020346a <nr_free_pages>
ffffffffc0201926:	42951763          	bne	a0,s1,ffffffffc0201d54 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020192a:	866a                	mv	a2,s10
ffffffffc020192c:	85ee                	mv	a1,s11
ffffffffc020192e:	00006517          	auipc	a0,0x6
ffffffffc0201932:	9a250513          	addi	a0,a0,-1630 # ffffffffc02072d0 <commands+0xb90>
ffffffffc0201936:	f96fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020193a:	ce8ff0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc020193e:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201940:	46050a63          	beqz	a0,ffffffffc0201db4 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201944:	000b1797          	auipc	a5,0xb1
ffffffffc0201948:	ecc78793          	addi	a5,a5,-308 # ffffffffc02b2810 <check_mm_struct>
ffffffffc020194c:	6398                	ld	a4,0(a5)
ffffffffc020194e:	3e071363          	bnez	a4,ffffffffc0201d34 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201952:	000b1717          	auipc	a4,0xb1
ffffffffc0201956:	ef670713          	addi	a4,a4,-266 # ffffffffc02b2848 <boot_pgdir>
ffffffffc020195a:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc020195e:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0201960:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201964:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201968:	42079663          	bnez	a5,ffffffffc0201d94 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020196c:	6599                	lui	a1,0x6
ffffffffc020196e:	460d                	li	a2,3
ffffffffc0201970:	6505                	lui	a0,0x1
ffffffffc0201972:	cf8ff0ef          	jal	ra,ffffffffc0200e6a <vma_create>
ffffffffc0201976:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201978:	52050a63          	beqz	a0,ffffffffc0201eac <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc020197c:	8556                	mv	a0,s5
ffffffffc020197e:	d5aff0ef          	jal	ra,ffffffffc0200ed8 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201982:	00006517          	auipc	a0,0x6
ffffffffc0201986:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207310 <commands+0xbd0>
ffffffffc020198a:	f42fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020198e:	018ab503          	ld	a0,24(s5)
ffffffffc0201992:	4605                	li	a2,1
ffffffffc0201994:	6585                	lui	a1,0x1
ffffffffc0201996:	30f010ef          	jal	ra,ffffffffc02034a4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020199a:	4c050963          	beqz	a0,ffffffffc0201e6c <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020199e:	00006517          	auipc	a0,0x6
ffffffffc02019a2:	9c250513          	addi	a0,a0,-1598 # ffffffffc0207360 <commands+0xc20>
ffffffffc02019a6:	000ad497          	auipc	s1,0xad
ffffffffc02019aa:	daa48493          	addi	s1,s1,-598 # ffffffffc02ae750 <check_rp>
ffffffffc02019ae:	f1efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019b2:	000ad997          	auipc	s3,0xad
ffffffffc02019b6:	dbe98993          	addi	s3,s3,-578 # ffffffffc02ae770 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02019ba:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02019bc:	4505                	li	a0,1
ffffffffc02019be:	1db010ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02019c2:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
          assert(check_rp[i] != NULL );
ffffffffc02019c6:	2c050f63          	beqz	a0,ffffffffc0201ca4 <swap_init+0x43e>
ffffffffc02019ca:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02019cc:	8b89                	andi	a5,a5,2
ffffffffc02019ce:	34079363          	bnez	a5,ffffffffc0201d14 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019d2:	0a21                	addi	s4,s4,8
ffffffffc02019d4:	ff3a14e3          	bne	s4,s3,ffffffffc02019bc <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02019d8:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02019da:	000ada17          	auipc	s4,0xad
ffffffffc02019de:	d76a0a13          	addi	s4,s4,-650 # ffffffffc02ae750 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02019e2:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02019e4:	ec3e                	sd	a5,24(sp)
ffffffffc02019e6:	641c                	ld	a5,8(s0)
ffffffffc02019e8:	e400                	sd	s0,8(s0)
ffffffffc02019ea:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02019ec:	481c                	lw	a5,16(s0)
ffffffffc02019ee:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02019f0:	000ad797          	auipc	a5,0xad
ffffffffc02019f4:	de07a823          	sw	zero,-528(a5) # ffffffffc02ae7e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02019f8:	000a3503          	ld	a0,0(s4)
ffffffffc02019fc:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019fe:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201a00:	22b010ef          	jal	ra,ffffffffc020342a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201a04:	ff3a1ae3          	bne	s4,s3,ffffffffc02019f8 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201a08:	01042a03          	lw	s4,16(s0)
ffffffffc0201a0c:	4791                	li	a5,4
ffffffffc0201a0e:	42fa1f63          	bne	s4,a5,ffffffffc0201e4c <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201a12:	00006517          	auipc	a0,0x6
ffffffffc0201a16:	9d650513          	addi	a0,a0,-1578 # ffffffffc02073e8 <commands+0xca8>
ffffffffc0201a1a:	eb2fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a1e:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201a20:	000b1797          	auipc	a5,0xb1
ffffffffc0201a24:	de07ac23          	sw	zero,-520(a5) # ffffffffc02b2818 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a28:	4629                	li	a2,10
ffffffffc0201a2a:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
     assert(pgfault_num==1);
ffffffffc0201a2e:	000b1697          	auipc	a3,0xb1
ffffffffc0201a32:	dea6a683          	lw	a3,-534(a3) # ffffffffc02b2818 <pgfault_num>
ffffffffc0201a36:	4585                	li	a1,1
ffffffffc0201a38:	000b1797          	auipc	a5,0xb1
ffffffffc0201a3c:	de078793          	addi	a5,a5,-544 # ffffffffc02b2818 <pgfault_num>
ffffffffc0201a40:	54b69663          	bne	a3,a1,ffffffffc0201f8c <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201a44:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201a48:	4398                	lw	a4,0(a5)
ffffffffc0201a4a:	2701                	sext.w	a4,a4
ffffffffc0201a4c:	3ed71063          	bne	a4,a3,ffffffffc0201e2c <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a50:	6689                	lui	a3,0x2
ffffffffc0201a52:	462d                	li	a2,11
ffffffffc0201a54:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
     assert(pgfault_num==2);
ffffffffc0201a58:	4398                	lw	a4,0(a5)
ffffffffc0201a5a:	4589                	li	a1,2
ffffffffc0201a5c:	2701                	sext.w	a4,a4
ffffffffc0201a5e:	4ab71763          	bne	a4,a1,ffffffffc0201f0c <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201a62:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201a66:	4394                	lw	a3,0(a5)
ffffffffc0201a68:	2681                	sext.w	a3,a3
ffffffffc0201a6a:	4ce69163          	bne	a3,a4,ffffffffc0201f2c <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201a6e:	668d                	lui	a3,0x3
ffffffffc0201a70:	4631                	li	a2,12
ffffffffc0201a72:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
     assert(pgfault_num==3);
ffffffffc0201a76:	4398                	lw	a4,0(a5)
ffffffffc0201a78:	458d                	li	a1,3
ffffffffc0201a7a:	2701                	sext.w	a4,a4
ffffffffc0201a7c:	4cb71863          	bne	a4,a1,ffffffffc0201f4c <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201a80:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201a84:	4394                	lw	a3,0(a5)
ffffffffc0201a86:	2681                	sext.w	a3,a3
ffffffffc0201a88:	4ee69263          	bne	a3,a4,ffffffffc0201f6c <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a8c:	6691                	lui	a3,0x4
ffffffffc0201a8e:	4635                	li	a2,13
ffffffffc0201a90:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
     assert(pgfault_num==4);
ffffffffc0201a94:	4398                	lw	a4,0(a5)
ffffffffc0201a96:	2701                	sext.w	a4,a4
ffffffffc0201a98:	43471a63          	bne	a4,s4,ffffffffc0201ecc <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201a9c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201aa0:	439c                	lw	a5,0(a5)
ffffffffc0201aa2:	2781                	sext.w	a5,a5
ffffffffc0201aa4:	44e79463          	bne	a5,a4,ffffffffc0201eec <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201aa8:	481c                	lw	a5,16(s0)
ffffffffc0201aaa:	2c079563          	bnez	a5,ffffffffc0201d74 <swap_init+0x50e>
ffffffffc0201aae:	000ad797          	auipc	a5,0xad
ffffffffc0201ab2:	cc278793          	addi	a5,a5,-830 # ffffffffc02ae770 <swap_in_seq_no>
ffffffffc0201ab6:	000ad717          	auipc	a4,0xad
ffffffffc0201aba:	ce270713          	addi	a4,a4,-798 # ffffffffc02ae798 <swap_out_seq_no>
ffffffffc0201abe:	000ad617          	auipc	a2,0xad
ffffffffc0201ac2:	cda60613          	addi	a2,a2,-806 # ffffffffc02ae798 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201ac6:	56fd                	li	a3,-1
ffffffffc0201ac8:	c394                	sw	a3,0(a5)
ffffffffc0201aca:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201acc:	0791                	addi	a5,a5,4
ffffffffc0201ace:	0711                	addi	a4,a4,4
ffffffffc0201ad0:	fec79ce3          	bne	a5,a2,ffffffffc0201ac8 <swap_init+0x262>
ffffffffc0201ad4:	000ad717          	auipc	a4,0xad
ffffffffc0201ad8:	c5c70713          	addi	a4,a4,-932 # ffffffffc02ae730 <check_ptep>
ffffffffc0201adc:	000ad697          	auipc	a3,0xad
ffffffffc0201ae0:	c7468693          	addi	a3,a3,-908 # ffffffffc02ae750 <check_rp>
ffffffffc0201ae4:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201ae6:	000b1c17          	auipc	s8,0xb1
ffffffffc0201aea:	d6ac0c13          	addi	s8,s8,-662 # ffffffffc02b2850 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201aee:	000b1c97          	auipc	s9,0xb1
ffffffffc0201af2:	d6ac8c93          	addi	s9,s9,-662 # ffffffffc02b2858 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201af6:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201afa:	4601                	li	a2,0
ffffffffc0201afc:	855a                	mv	a0,s6
ffffffffc0201afe:	e836                	sd	a3,16(sp)
ffffffffc0201b00:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201b02:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b04:	1a1010ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0201b08:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201b0a:	65a2                	ld	a1,8(sp)
ffffffffc0201b0c:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b0e:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201b10:	1c050663          	beqz	a0,ffffffffc0201cdc <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201b14:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201b16:	0017f613          	andi	a2,a5,1
ffffffffc0201b1a:	1e060163          	beqz	a2,ffffffffc0201cfc <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0201b1e:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b22:	078a                	slli	a5,a5,0x2
ffffffffc0201b24:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b26:	14c7f363          	bgeu	a5,a2,ffffffffc0201c6c <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b2a:	00007617          	auipc	a2,0x7
ffffffffc0201b2e:	ff660613          	addi	a2,a2,-10 # ffffffffc0208b20 <nbase>
ffffffffc0201b32:	00063a03          	ld	s4,0(a2)
ffffffffc0201b36:	000cb603          	ld	a2,0(s9)
ffffffffc0201b3a:	6288                	ld	a0,0(a3)
ffffffffc0201b3c:	414787b3          	sub	a5,a5,s4
ffffffffc0201b40:	079a                	slli	a5,a5,0x6
ffffffffc0201b42:	97b2                	add	a5,a5,a2
ffffffffc0201b44:	14f51063          	bne	a0,a5,ffffffffc0201c84 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b48:	6785                	lui	a5,0x1
ffffffffc0201b4a:	95be                	add	a1,a1,a5
ffffffffc0201b4c:	6795                	lui	a5,0x5
ffffffffc0201b4e:	0721                	addi	a4,a4,8
ffffffffc0201b50:	06a1                	addi	a3,a3,8
ffffffffc0201b52:	faf592e3          	bne	a1,a5,ffffffffc0201af6 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201b56:	00006517          	auipc	a0,0x6
ffffffffc0201b5a:	97250513          	addi	a0,a0,-1678 # ffffffffc02074c8 <commands+0xd88>
ffffffffc0201b5e:	d6efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0201b62:	000bb783          	ld	a5,0(s7)
ffffffffc0201b66:	7f9c                	ld	a5,56(a5)
ffffffffc0201b68:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201b6a:	32051163          	bnez	a0,ffffffffc0201e8c <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0201b6e:	77a2                	ld	a5,40(sp)
ffffffffc0201b70:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201b72:	67e2                	ld	a5,24(sp)
ffffffffc0201b74:	e01c                	sd	a5,0(s0)
ffffffffc0201b76:	7782                	ld	a5,32(sp)
ffffffffc0201b78:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201b7a:	6088                	ld	a0,0(s1)
ffffffffc0201b7c:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b7e:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201b80:	0ab010ef          	jal	ra,ffffffffc020342a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b84:	ff349be3          	bne	s1,s3,ffffffffc0201b7a <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0201b88:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0201b8c:	8556                	mv	a0,s5
ffffffffc0201b8e:	c1aff0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201b92:	000b1797          	auipc	a5,0xb1
ffffffffc0201b96:	cb678793          	addi	a5,a5,-842 # ffffffffc02b2848 <boot_pgdir>
ffffffffc0201b9a:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201b9c:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0201ba0:	000b1697          	auipc	a3,0xb1
ffffffffc0201ba4:	c606b823          	sd	zero,-912(a3) # ffffffffc02b2810 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ba8:	639c                	ld	a5,0(a5)
ffffffffc0201baa:	078a                	slli	a5,a5,0x2
ffffffffc0201bac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bae:	0ae7fd63          	bgeu	a5,a4,ffffffffc0201c68 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bb2:	414786b3          	sub	a3,a5,s4
ffffffffc0201bb6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201bb8:	8699                	srai	a3,a3,0x6
ffffffffc0201bba:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201bbc:	00c69793          	slli	a5,a3,0xc
ffffffffc0201bc0:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201bc2:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bc6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201bc8:	22e7f663          	bgeu	a5,a4,ffffffffc0201df4 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0201bcc:	000b1797          	auipc	a5,0xb1
ffffffffc0201bd0:	c9c7b783          	ld	a5,-868(a5) # ffffffffc02b2868 <va_pa_offset>
ffffffffc0201bd4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bd6:	629c                	ld	a5,0(a3)
ffffffffc0201bd8:	078a                	slli	a5,a5,0x2
ffffffffc0201bda:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bdc:	08e7f663          	bgeu	a5,a4,ffffffffc0201c68 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201be0:	414787b3          	sub	a5,a5,s4
ffffffffc0201be4:	079a                	slli	a5,a5,0x6
ffffffffc0201be6:	953e                	add	a0,a0,a5
ffffffffc0201be8:	4585                	li	a1,1
ffffffffc0201bea:	041010ef          	jal	ra,ffffffffc020342a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bee:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201bf2:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bf6:	078a                	slli	a5,a5,0x2
ffffffffc0201bf8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bfa:	06e7f763          	bgeu	a5,a4,ffffffffc0201c68 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bfe:	000cb503          	ld	a0,0(s9)
ffffffffc0201c02:	414787b3          	sub	a5,a5,s4
ffffffffc0201c06:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201c08:	4585                	li	a1,1
ffffffffc0201c0a:	953e                	add	a0,a0,a5
ffffffffc0201c0c:	01f010ef          	jal	ra,ffffffffc020342a <free_pages>
     pgdir[0] = 0;
ffffffffc0201c10:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201c14:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201c18:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c1a:	00878a63          	beq	a5,s0,ffffffffc0201c2e <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201c1e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201c22:	679c                	ld	a5,8(a5)
ffffffffc0201c24:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c26:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c2a:	fe879ae3          	bne	a5,s0,ffffffffc0201c1e <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0201c2e:	1c0d9f63          	bnez	s11,ffffffffc0201e0c <swap_init+0x5a6>
     assert(total==0);
ffffffffc0201c32:	1a0d1163          	bnez	s10,ffffffffc0201dd4 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201c36:	00006517          	auipc	a0,0x6
ffffffffc0201c3a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207518 <commands+0xdd8>
ffffffffc0201c3e:	c8efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201c42:	b99d                	j	ffffffffc02018b8 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c44:	4481                	li	s1,0
ffffffffc0201c46:	b9f1                	j	ffffffffc0201922 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0201c48:	00005697          	auipc	a3,0x5
ffffffffc0201c4c:	65868693          	addi	a3,a3,1624 # ffffffffc02072a0 <commands+0xb60>
ffffffffc0201c50:	00005617          	auipc	a2,0x5
ffffffffc0201c54:	f0060613          	addi	a2,a2,-256 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201c58:	0bc00593          	li	a1,188
ffffffffc0201c5c:	00005517          	auipc	a0,0x5
ffffffffc0201c60:	61c50513          	addi	a0,a0,1564 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201c64:	da4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201c68:	be3ff0ef          	jal	ra,ffffffffc020184a <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0201c6c:	00005617          	auipc	a2,0x5
ffffffffc0201c70:	48460613          	addi	a2,a2,1156 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc0201c74:	06200593          	li	a1,98
ffffffffc0201c78:	00005517          	auipc	a0,0x5
ffffffffc0201c7c:	49850513          	addi	a0,a0,1176 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0201c80:	d88fe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201c84:	00006697          	auipc	a3,0x6
ffffffffc0201c88:	81c68693          	addi	a3,a3,-2020 # ffffffffc02074a0 <commands+0xd60>
ffffffffc0201c8c:	00005617          	auipc	a2,0x5
ffffffffc0201c90:	ec460613          	addi	a2,a2,-316 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201c94:	0fc00593          	li	a1,252
ffffffffc0201c98:	00005517          	auipc	a0,0x5
ffffffffc0201c9c:	5e050513          	addi	a0,a0,1504 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201ca0:	d68fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201ca4:	00005697          	auipc	a3,0x5
ffffffffc0201ca8:	6e468693          	addi	a3,a3,1764 # ffffffffc0207388 <commands+0xc48>
ffffffffc0201cac:	00005617          	auipc	a2,0x5
ffffffffc0201cb0:	ea460613          	addi	a2,a2,-348 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201cb4:	0dc00593          	li	a1,220
ffffffffc0201cb8:	00005517          	auipc	a0,0x5
ffffffffc0201cbc:	5c050513          	addi	a0,a0,1472 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201cc0:	d48fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201cc4:	00005617          	auipc	a2,0x5
ffffffffc0201cc8:	59460613          	addi	a2,a2,1428 # ffffffffc0207258 <commands+0xb18>
ffffffffc0201ccc:	02800593          	li	a1,40
ffffffffc0201cd0:	00005517          	auipc	a0,0x5
ffffffffc0201cd4:	5a850513          	addi	a0,a0,1448 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201cd8:	d30fe0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201cdc:	00005697          	auipc	a3,0x5
ffffffffc0201ce0:	78468693          	addi	a3,a3,1924 # ffffffffc0207460 <commands+0xd20>
ffffffffc0201ce4:	00005617          	auipc	a2,0x5
ffffffffc0201ce8:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201cec:	0fb00593          	li	a1,251
ffffffffc0201cf0:	00005517          	auipc	a0,0x5
ffffffffc0201cf4:	58850513          	addi	a0,a0,1416 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201cf8:	d10fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201cfc:	00005617          	auipc	a2,0x5
ffffffffc0201d00:	77c60613          	addi	a2,a2,1916 # ffffffffc0207478 <commands+0xd38>
ffffffffc0201d04:	07400593          	li	a1,116
ffffffffc0201d08:	00005517          	auipc	a0,0x5
ffffffffc0201d0c:	40850513          	addi	a0,a0,1032 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0201d10:	cf8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d14:	00005697          	auipc	a3,0x5
ffffffffc0201d18:	68c68693          	addi	a3,a3,1676 # ffffffffc02073a0 <commands+0xc60>
ffffffffc0201d1c:	00005617          	auipc	a2,0x5
ffffffffc0201d20:	e3460613          	addi	a2,a2,-460 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201d24:	0dd00593          	li	a1,221
ffffffffc0201d28:	00005517          	auipc	a0,0x5
ffffffffc0201d2c:	55050513          	addi	a0,a0,1360 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201d30:	cd8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201d34:	00005697          	auipc	a3,0x5
ffffffffc0201d38:	5c468693          	addi	a3,a3,1476 # ffffffffc02072f8 <commands+0xbb8>
ffffffffc0201d3c:	00005617          	auipc	a2,0x5
ffffffffc0201d40:	e1460613          	addi	a2,a2,-492 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201d44:	0c700593          	li	a1,199
ffffffffc0201d48:	00005517          	auipc	a0,0x5
ffffffffc0201d4c:	53050513          	addi	a0,a0,1328 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201d50:	cb8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201d54:	00005697          	auipc	a3,0x5
ffffffffc0201d58:	55c68693          	addi	a3,a3,1372 # ffffffffc02072b0 <commands+0xb70>
ffffffffc0201d5c:	00005617          	auipc	a2,0x5
ffffffffc0201d60:	df460613          	addi	a2,a2,-524 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201d64:	0bf00593          	li	a1,191
ffffffffc0201d68:	00005517          	auipc	a0,0x5
ffffffffc0201d6c:	51050513          	addi	a0,a0,1296 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201d70:	c98fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0201d74:	00005697          	auipc	a3,0x5
ffffffffc0201d78:	6dc68693          	addi	a3,a3,1756 # ffffffffc0207450 <commands+0xd10>
ffffffffc0201d7c:	00005617          	auipc	a2,0x5
ffffffffc0201d80:	dd460613          	addi	a2,a2,-556 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201d84:	0f300593          	li	a1,243
ffffffffc0201d88:	00005517          	auipc	a0,0x5
ffffffffc0201d8c:	4f050513          	addi	a0,a0,1264 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201d90:	c78fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201d94:	00005697          	auipc	a3,0x5
ffffffffc0201d98:	31c68693          	addi	a3,a3,796 # ffffffffc02070b0 <commands+0x970>
ffffffffc0201d9c:	00005617          	auipc	a2,0x5
ffffffffc0201da0:	db460613          	addi	a2,a2,-588 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201da4:	0cc00593          	li	a1,204
ffffffffc0201da8:	00005517          	auipc	a0,0x5
ffffffffc0201dac:	4d050513          	addi	a0,a0,1232 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201db0:	c58fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0201db4:	00005697          	auipc	a3,0x5
ffffffffc0201db8:	13468693          	addi	a3,a3,308 # ffffffffc0206ee8 <commands+0x7a8>
ffffffffc0201dbc:	00005617          	auipc	a2,0x5
ffffffffc0201dc0:	d9460613          	addi	a2,a2,-620 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201dc4:	0c400593          	li	a1,196
ffffffffc0201dc8:	00005517          	auipc	a0,0x5
ffffffffc0201dcc:	4b050513          	addi	a0,a0,1200 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201dd0:	c38fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0201dd4:	00005697          	auipc	a3,0x5
ffffffffc0201dd8:	73468693          	addi	a3,a3,1844 # ffffffffc0207508 <commands+0xdc8>
ffffffffc0201ddc:	00005617          	auipc	a2,0x5
ffffffffc0201de0:	d7460613          	addi	a2,a2,-652 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201de4:	11e00593          	li	a1,286
ffffffffc0201de8:	00005517          	auipc	a0,0x5
ffffffffc0201dec:	49050513          	addi	a0,a0,1168 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201df0:	c18fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201df4:	00005617          	auipc	a2,0x5
ffffffffc0201df8:	32c60613          	addi	a2,a2,812 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0201dfc:	06900593          	li	a1,105
ffffffffc0201e00:	00005517          	auipc	a0,0x5
ffffffffc0201e04:	31050513          	addi	a0,a0,784 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0201e08:	c00fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0201e0c:	00005697          	auipc	a3,0x5
ffffffffc0201e10:	6ec68693          	addi	a3,a3,1772 # ffffffffc02074f8 <commands+0xdb8>
ffffffffc0201e14:	00005617          	auipc	a2,0x5
ffffffffc0201e18:	d3c60613          	addi	a2,a2,-708 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201e1c:	11d00593          	li	a1,285
ffffffffc0201e20:	00005517          	auipc	a0,0x5
ffffffffc0201e24:	45850513          	addi	a0,a0,1112 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201e28:	be0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e2c:	00005697          	auipc	a3,0x5
ffffffffc0201e30:	5e468693          	addi	a3,a3,1508 # ffffffffc0207410 <commands+0xcd0>
ffffffffc0201e34:	00005617          	auipc	a2,0x5
ffffffffc0201e38:	d1c60613          	addi	a2,a2,-740 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201e3c:	09500593          	li	a1,149
ffffffffc0201e40:	00005517          	auipc	a0,0x5
ffffffffc0201e44:	43850513          	addi	a0,a0,1080 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201e48:	bc0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201e4c:	00005697          	auipc	a3,0x5
ffffffffc0201e50:	57468693          	addi	a3,a3,1396 # ffffffffc02073c0 <commands+0xc80>
ffffffffc0201e54:	00005617          	auipc	a2,0x5
ffffffffc0201e58:	cfc60613          	addi	a2,a2,-772 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201e5c:	0ea00593          	li	a1,234
ffffffffc0201e60:	00005517          	auipc	a0,0x5
ffffffffc0201e64:	41850513          	addi	a0,a0,1048 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201e68:	ba0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201e6c:	00005697          	auipc	a3,0x5
ffffffffc0201e70:	4dc68693          	addi	a3,a3,1244 # ffffffffc0207348 <commands+0xc08>
ffffffffc0201e74:	00005617          	auipc	a2,0x5
ffffffffc0201e78:	cdc60613          	addi	a2,a2,-804 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201e7c:	0d700593          	li	a1,215
ffffffffc0201e80:	00005517          	auipc	a0,0x5
ffffffffc0201e84:	3f850513          	addi	a0,a0,1016 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201e88:	b80fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0201e8c:	00005697          	auipc	a3,0x5
ffffffffc0201e90:	66468693          	addi	a3,a3,1636 # ffffffffc02074f0 <commands+0xdb0>
ffffffffc0201e94:	00005617          	auipc	a2,0x5
ffffffffc0201e98:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201e9c:	10200593          	li	a1,258
ffffffffc0201ea0:	00005517          	auipc	a0,0x5
ffffffffc0201ea4:	3d850513          	addi	a0,a0,984 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201ea8:	b60fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0201eac:	00005697          	auipc	a3,0x5
ffffffffc0201eb0:	2fc68693          	addi	a3,a3,764 # ffffffffc02071a8 <commands+0xa68>
ffffffffc0201eb4:	00005617          	auipc	a2,0x5
ffffffffc0201eb8:	c9c60613          	addi	a2,a2,-868 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201ebc:	0cf00593          	li	a1,207
ffffffffc0201ec0:	00005517          	auipc	a0,0x5
ffffffffc0201ec4:	3b850513          	addi	a0,a0,952 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201ec8:	b40fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0201ecc:	00005697          	auipc	a3,0x5
ffffffffc0201ed0:	57468693          	addi	a3,a3,1396 # ffffffffc0207440 <commands+0xd00>
ffffffffc0201ed4:	00005617          	auipc	a2,0x5
ffffffffc0201ed8:	c7c60613          	addi	a2,a2,-900 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201edc:	09f00593          	li	a1,159
ffffffffc0201ee0:	00005517          	auipc	a0,0x5
ffffffffc0201ee4:	39850513          	addi	a0,a0,920 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201ee8:	b20fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0201eec:	00005697          	auipc	a3,0x5
ffffffffc0201ef0:	55468693          	addi	a3,a3,1364 # ffffffffc0207440 <commands+0xd00>
ffffffffc0201ef4:	00005617          	auipc	a2,0x5
ffffffffc0201ef8:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201efc:	0a100593          	li	a1,161
ffffffffc0201f00:	00005517          	auipc	a0,0x5
ffffffffc0201f04:	37850513          	addi	a0,a0,888 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201f08:	b00fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0201f0c:	00005697          	auipc	a3,0x5
ffffffffc0201f10:	51468693          	addi	a3,a3,1300 # ffffffffc0207420 <commands+0xce0>
ffffffffc0201f14:	00005617          	auipc	a2,0x5
ffffffffc0201f18:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201f1c:	09700593          	li	a1,151
ffffffffc0201f20:	00005517          	auipc	a0,0x5
ffffffffc0201f24:	35850513          	addi	a0,a0,856 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201f28:	ae0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0201f2c:	00005697          	auipc	a3,0x5
ffffffffc0201f30:	4f468693          	addi	a3,a3,1268 # ffffffffc0207420 <commands+0xce0>
ffffffffc0201f34:	00005617          	auipc	a2,0x5
ffffffffc0201f38:	c1c60613          	addi	a2,a2,-996 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201f3c:	09900593          	li	a1,153
ffffffffc0201f40:	00005517          	auipc	a0,0x5
ffffffffc0201f44:	33850513          	addi	a0,a0,824 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201f48:	ac0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0201f4c:	00005697          	auipc	a3,0x5
ffffffffc0201f50:	4e468693          	addi	a3,a3,1252 # ffffffffc0207430 <commands+0xcf0>
ffffffffc0201f54:	00005617          	auipc	a2,0x5
ffffffffc0201f58:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201f5c:	09b00593          	li	a1,155
ffffffffc0201f60:	00005517          	auipc	a0,0x5
ffffffffc0201f64:	31850513          	addi	a0,a0,792 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201f68:	aa0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0201f6c:	00005697          	auipc	a3,0x5
ffffffffc0201f70:	4c468693          	addi	a3,a3,1220 # ffffffffc0207430 <commands+0xcf0>
ffffffffc0201f74:	00005617          	auipc	a2,0x5
ffffffffc0201f78:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201f7c:	09d00593          	li	a1,157
ffffffffc0201f80:	00005517          	auipc	a0,0x5
ffffffffc0201f84:	2f850513          	addi	a0,a0,760 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201f88:	a80fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0201f8c:	00005697          	auipc	a3,0x5
ffffffffc0201f90:	48468693          	addi	a3,a3,1156 # ffffffffc0207410 <commands+0xcd0>
ffffffffc0201f94:	00005617          	auipc	a2,0x5
ffffffffc0201f98:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0206b50 <commands+0x410>
ffffffffc0201f9c:	09300593          	li	a1,147
ffffffffc0201fa0:	00005517          	auipc	a0,0x5
ffffffffc0201fa4:	2d850513          	addi	a0,a0,728 # ffffffffc0207278 <commands+0xb38>
ffffffffc0201fa8:	a60fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201fac <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201fac:	000b1797          	auipc	a5,0xb1
ffffffffc0201fb0:	87c7b783          	ld	a5,-1924(a5) # ffffffffc02b2828 <sm>
ffffffffc0201fb4:	6b9c                	ld	a5,16(a5)
ffffffffc0201fb6:	8782                	jr	a5

ffffffffc0201fb8 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201fb8:	000b1797          	auipc	a5,0xb1
ffffffffc0201fbc:	8707b783          	ld	a5,-1936(a5) # ffffffffc02b2828 <sm>
ffffffffc0201fc0:	739c                	ld	a5,32(a5)
ffffffffc0201fc2:	8782                	jr	a5

ffffffffc0201fc4 <swap_out>:
{
ffffffffc0201fc4:	711d                	addi	sp,sp,-96
ffffffffc0201fc6:	ec86                	sd	ra,88(sp)
ffffffffc0201fc8:	e8a2                	sd	s0,80(sp)
ffffffffc0201fca:	e4a6                	sd	s1,72(sp)
ffffffffc0201fcc:	e0ca                	sd	s2,64(sp)
ffffffffc0201fce:	fc4e                	sd	s3,56(sp)
ffffffffc0201fd0:	f852                	sd	s4,48(sp)
ffffffffc0201fd2:	f456                	sd	s5,40(sp)
ffffffffc0201fd4:	f05a                	sd	s6,32(sp)
ffffffffc0201fd6:	ec5e                	sd	s7,24(sp)
ffffffffc0201fd8:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201fda:	cde9                	beqz	a1,ffffffffc02020b4 <swap_out+0xf0>
ffffffffc0201fdc:	8a2e                	mv	s4,a1
ffffffffc0201fde:	892a                	mv	s2,a0
ffffffffc0201fe0:	8ab2                	mv	s5,a2
ffffffffc0201fe2:	4401                	li	s0,0
ffffffffc0201fe4:	000b1997          	auipc	s3,0xb1
ffffffffc0201fe8:	84498993          	addi	s3,s3,-1980 # ffffffffc02b2828 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201fec:	00005b17          	auipc	s6,0x5
ffffffffc0201ff0:	5acb0b13          	addi	s6,s6,1452 # ffffffffc0207598 <commands+0xe58>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201ff4:	00005b97          	auipc	s7,0x5
ffffffffc0201ff8:	58cb8b93          	addi	s7,s7,1420 # ffffffffc0207580 <commands+0xe40>
ffffffffc0201ffc:	a825                	j	ffffffffc0202034 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201ffe:	67a2                	ld	a5,8(sp)
ffffffffc0202000:	8626                	mv	a2,s1
ffffffffc0202002:	85a2                	mv	a1,s0
ffffffffc0202004:	7f94                	ld	a3,56(a5)
ffffffffc0202006:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202008:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020200a:	82b1                	srli	a3,a3,0xc
ffffffffc020200c:	0685                	addi	a3,a3,1
ffffffffc020200e:	8befe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202012:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202014:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202016:	7d1c                	ld	a5,56(a0)
ffffffffc0202018:	83b1                	srli	a5,a5,0xc
ffffffffc020201a:	0785                	addi	a5,a5,1
ffffffffc020201c:	07a2                	slli	a5,a5,0x8
ffffffffc020201e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202022:	408010ef          	jal	ra,ffffffffc020342a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202026:	01893503          	ld	a0,24(s2)
ffffffffc020202a:	85a6                	mv	a1,s1
ffffffffc020202c:	1d3020ef          	jal	ra,ffffffffc02049fe <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202030:	048a0d63          	beq	s4,s0,ffffffffc020208a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202034:	0009b783          	ld	a5,0(s3)
ffffffffc0202038:	8656                	mv	a2,s5
ffffffffc020203a:	002c                	addi	a1,sp,8
ffffffffc020203c:	7b9c                	ld	a5,48(a5)
ffffffffc020203e:	854a                	mv	a0,s2
ffffffffc0202040:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202042:	e12d                	bnez	a0,ffffffffc02020a4 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202044:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202046:	01893503          	ld	a0,24(s2)
ffffffffc020204a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020204c:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020204e:	85a6                	mv	a1,s1
ffffffffc0202050:	454010ef          	jal	ra,ffffffffc02034a4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202054:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202056:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202058:	8b85                	andi	a5,a5,1
ffffffffc020205a:	cfb9                	beqz	a5,ffffffffc02020b8 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020205c:	65a2                	ld	a1,8(sp)
ffffffffc020205e:	7d9c                	ld	a5,56(a1)
ffffffffc0202060:	83b1                	srli	a5,a5,0xc
ffffffffc0202062:	0785                	addi	a5,a5,1
ffffffffc0202064:	00879513          	slli	a0,a5,0x8
ffffffffc0202068:	28f020ef          	jal	ra,ffffffffc0204af6 <swapfs_write>
ffffffffc020206c:	d949                	beqz	a0,ffffffffc0201ffe <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020206e:	855e                	mv	a0,s7
ffffffffc0202070:	85cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202074:	0009b783          	ld	a5,0(s3)
ffffffffc0202078:	6622                	ld	a2,8(sp)
ffffffffc020207a:	4681                	li	a3,0
ffffffffc020207c:	739c                	ld	a5,32(a5)
ffffffffc020207e:	85a6                	mv	a1,s1
ffffffffc0202080:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202082:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202084:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202086:	fa8a17e3          	bne	s4,s0,ffffffffc0202034 <swap_out+0x70>
}
ffffffffc020208a:	60e6                	ld	ra,88(sp)
ffffffffc020208c:	8522                	mv	a0,s0
ffffffffc020208e:	6446                	ld	s0,80(sp)
ffffffffc0202090:	64a6                	ld	s1,72(sp)
ffffffffc0202092:	6906                	ld	s2,64(sp)
ffffffffc0202094:	79e2                	ld	s3,56(sp)
ffffffffc0202096:	7a42                	ld	s4,48(sp)
ffffffffc0202098:	7aa2                	ld	s5,40(sp)
ffffffffc020209a:	7b02                	ld	s6,32(sp)
ffffffffc020209c:	6be2                	ld	s7,24(sp)
ffffffffc020209e:	6c42                	ld	s8,16(sp)
ffffffffc02020a0:	6125                	addi	sp,sp,96
ffffffffc02020a2:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02020a4:	85a2                	mv	a1,s0
ffffffffc02020a6:	00005517          	auipc	a0,0x5
ffffffffc02020aa:	49250513          	addi	a0,a0,1170 # ffffffffc0207538 <commands+0xdf8>
ffffffffc02020ae:	81efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02020b2:	bfe1                	j	ffffffffc020208a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02020b4:	4401                	li	s0,0
ffffffffc02020b6:	bfd1                	j	ffffffffc020208a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02020b8:	00005697          	auipc	a3,0x5
ffffffffc02020bc:	4b068693          	addi	a3,a3,1200 # ffffffffc0207568 <commands+0xe28>
ffffffffc02020c0:	00005617          	auipc	a2,0x5
ffffffffc02020c4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206b50 <commands+0x410>
ffffffffc02020c8:	06800593          	li	a1,104
ffffffffc02020cc:	00005517          	auipc	a0,0x5
ffffffffc02020d0:	1ac50513          	addi	a0,a0,428 # ffffffffc0207278 <commands+0xb38>
ffffffffc02020d4:	934fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02020d8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02020d8:	c94d                	beqz	a0,ffffffffc020218a <slob_free+0xb2>
{
ffffffffc02020da:	1141                	addi	sp,sp,-16
ffffffffc02020dc:	e022                	sd	s0,0(sp)
ffffffffc02020de:	e406                	sd	ra,8(sp)
ffffffffc02020e0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02020e2:	e9c1                	bnez	a1,ffffffffc0202172 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e4:	100027f3          	csrr	a5,sstatus
ffffffffc02020e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02020ea:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020ec:	ebd9                	bnez	a5,ffffffffc0202182 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02020ee:	000a5617          	auipc	a2,0xa5
ffffffffc02020f2:	23260613          	addi	a2,a2,562 # ffffffffc02a7320 <slobfree>
ffffffffc02020f6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02020f8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02020fa:	679c                	ld	a5,8(a5)
ffffffffc02020fc:	02877a63          	bgeu	a4,s0,ffffffffc0202130 <slob_free+0x58>
ffffffffc0202100:	00f46463          	bltu	s0,a5,ffffffffc0202108 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202104:	fef76ae3          	bltu	a4,a5,ffffffffc02020f8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202108:	400c                	lw	a1,0(s0)
ffffffffc020210a:	00459693          	slli	a3,a1,0x4
ffffffffc020210e:	96a2                	add	a3,a3,s0
ffffffffc0202110:	02d78a63          	beq	a5,a3,ffffffffc0202144 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202114:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0202116:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202118:	00469793          	slli	a5,a3,0x4
ffffffffc020211c:	97ba                	add	a5,a5,a4
ffffffffc020211e:	02f40e63          	beq	s0,a5,ffffffffc020215a <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202122:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0202124:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0202126:	e129                	bnez	a0,ffffffffc0202168 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202128:	60a2                	ld	ra,8(sp)
ffffffffc020212a:	6402                	ld	s0,0(sp)
ffffffffc020212c:	0141                	addi	sp,sp,16
ffffffffc020212e:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202130:	fcf764e3          	bltu	a4,a5,ffffffffc02020f8 <slob_free+0x20>
ffffffffc0202134:	fcf472e3          	bgeu	s0,a5,ffffffffc02020f8 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0202138:	400c                	lw	a1,0(s0)
ffffffffc020213a:	00459693          	slli	a3,a1,0x4
ffffffffc020213e:	96a2                	add	a3,a3,s0
ffffffffc0202140:	fcd79ae3          	bne	a5,a3,ffffffffc0202114 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0202144:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202146:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0202148:	9db5                	addw	a1,a1,a3
ffffffffc020214a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020214c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020214e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202150:	00469793          	slli	a5,a3,0x4
ffffffffc0202154:	97ba                	add	a5,a5,a4
ffffffffc0202156:	fcf416e3          	bne	s0,a5,ffffffffc0202122 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020215a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020215c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020215e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0202160:	9ebd                	addw	a3,a3,a5
ffffffffc0202162:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0202164:	e70c                	sd	a1,8(a4)
ffffffffc0202166:	d169                	beqz	a0,ffffffffc0202128 <slob_free+0x50>
}
ffffffffc0202168:	6402                	ld	s0,0(sp)
ffffffffc020216a:	60a2                	ld	ra,8(sp)
ffffffffc020216c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020216e:	cb0fe06f          	j	ffffffffc020061e <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0202172:	25bd                	addiw	a1,a1,15
ffffffffc0202174:	8191                	srli	a1,a1,0x4
ffffffffc0202176:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202178:	100027f3          	csrr	a5,sstatus
ffffffffc020217c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020217e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202180:	d7bd                	beqz	a5,ffffffffc02020ee <slob_free+0x16>
        intr_disable();
ffffffffc0202182:	ca2fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0202186:	4505                	li	a0,1
ffffffffc0202188:	b79d                	j	ffffffffc02020ee <slob_free+0x16>
ffffffffc020218a:	8082                	ret

ffffffffc020218c <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020218c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020218e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202190:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202194:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202196:	202010ef          	jal	ra,ffffffffc0203398 <alloc_pages>
  if(!page)
ffffffffc020219a:	c91d                	beqz	a0,ffffffffc02021d0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020219c:	000b0697          	auipc	a3,0xb0
ffffffffc02021a0:	6bc6b683          	ld	a3,1724(a3) # ffffffffc02b2858 <pages>
ffffffffc02021a4:	8d15                	sub	a0,a0,a3
ffffffffc02021a6:	8519                	srai	a0,a0,0x6
ffffffffc02021a8:	00007697          	auipc	a3,0x7
ffffffffc02021ac:	9786b683          	ld	a3,-1672(a3) # ffffffffc0208b20 <nbase>
ffffffffc02021b0:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02021b2:	00c51793          	slli	a5,a0,0xc
ffffffffc02021b6:	83b1                	srli	a5,a5,0xc
ffffffffc02021b8:	000b0717          	auipc	a4,0xb0
ffffffffc02021bc:	69873703          	ld	a4,1688(a4) # ffffffffc02b2850 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02021c0:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02021c2:	00e7fa63          	bgeu	a5,a4,ffffffffc02021d6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02021c6:	000b0697          	auipc	a3,0xb0
ffffffffc02021ca:	6a26b683          	ld	a3,1698(a3) # ffffffffc02b2868 <va_pa_offset>
ffffffffc02021ce:	9536                	add	a0,a0,a3
}
ffffffffc02021d0:	60a2                	ld	ra,8(sp)
ffffffffc02021d2:	0141                	addi	sp,sp,16
ffffffffc02021d4:	8082                	ret
ffffffffc02021d6:	86aa                	mv	a3,a0
ffffffffc02021d8:	00005617          	auipc	a2,0x5
ffffffffc02021dc:	f4860613          	addi	a2,a2,-184 # ffffffffc0207120 <commands+0x9e0>
ffffffffc02021e0:	06900593          	li	a1,105
ffffffffc02021e4:	00005517          	auipc	a0,0x5
ffffffffc02021e8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02021ec:	81cfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02021f0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02021f0:	1101                	addi	sp,sp,-32
ffffffffc02021f2:	ec06                	sd	ra,24(sp)
ffffffffc02021f4:	e822                	sd	s0,16(sp)
ffffffffc02021f6:	e426                	sd	s1,8(sp)
ffffffffc02021f8:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02021fa:	01050713          	addi	a4,a0,16
ffffffffc02021fe:	6785                	lui	a5,0x1
ffffffffc0202200:	0cf77363          	bgeu	a4,a5,ffffffffc02022c6 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202204:	00f50493          	addi	s1,a0,15
ffffffffc0202208:	8091                	srli	s1,s1,0x4
ffffffffc020220a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020220c:	10002673          	csrr	a2,sstatus
ffffffffc0202210:	8a09                	andi	a2,a2,2
ffffffffc0202212:	e25d                	bnez	a2,ffffffffc02022b8 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0202214:	000a5917          	auipc	s2,0xa5
ffffffffc0202218:	10c90913          	addi	s2,s2,268 # ffffffffc02a7320 <slobfree>
ffffffffc020221c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202220:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202222:	4398                	lw	a4,0(a5)
ffffffffc0202224:	08975e63          	bge	a4,s1,ffffffffc02022c0 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0202228:	00f68b63          	beq	a3,a5,ffffffffc020223e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020222c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020222e:	4018                	lw	a4,0(s0)
ffffffffc0202230:	02975a63          	bge	a4,s1,ffffffffc0202264 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0202234:	00093683          	ld	a3,0(s2)
ffffffffc0202238:	87a2                	mv	a5,s0
ffffffffc020223a:	fef699e3          	bne	a3,a5,ffffffffc020222c <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020223e:	ee31                	bnez	a2,ffffffffc020229a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202240:	4501                	li	a0,0
ffffffffc0202242:	f4bff0ef          	jal	ra,ffffffffc020218c <__slob_get_free_pages.constprop.0>
ffffffffc0202246:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202248:	cd05                	beqz	a0,ffffffffc0202280 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020224a:	6585                	lui	a1,0x1
ffffffffc020224c:	e8dff0ef          	jal	ra,ffffffffc02020d8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202250:	10002673          	csrr	a2,sstatus
ffffffffc0202254:	8a09                	andi	a2,a2,2
ffffffffc0202256:	ee05                	bnez	a2,ffffffffc020228e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0202258:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020225c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020225e:	4018                	lw	a4,0(s0)
ffffffffc0202260:	fc974ae3          	blt	a4,s1,ffffffffc0202234 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202264:	04e48763          	beq	s1,a4,ffffffffc02022b2 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0202268:	00449693          	slli	a3,s1,0x4
ffffffffc020226c:	96a2                	add	a3,a3,s0
ffffffffc020226e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202270:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202272:	9f05                	subw	a4,a4,s1
ffffffffc0202274:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202276:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202278:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020227a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020227e:	e20d                	bnez	a2,ffffffffc02022a0 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202280:	60e2                	ld	ra,24(sp)
ffffffffc0202282:	8522                	mv	a0,s0
ffffffffc0202284:	6442                	ld	s0,16(sp)
ffffffffc0202286:	64a2                	ld	s1,8(sp)
ffffffffc0202288:	6902                	ld	s2,0(sp)
ffffffffc020228a:	6105                	addi	sp,sp,32
ffffffffc020228c:	8082                	ret
        intr_disable();
ffffffffc020228e:	b96fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
			cur = slobfree;
ffffffffc0202292:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202296:	4605                	li	a2,1
ffffffffc0202298:	b7d1                	j	ffffffffc020225c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020229a:	b84fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020229e:	b74d                	j	ffffffffc0202240 <slob_alloc.constprop.0+0x50>
ffffffffc02022a0:	b7efe0ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc02022a4:	60e2                	ld	ra,24(sp)
ffffffffc02022a6:	8522                	mv	a0,s0
ffffffffc02022a8:	6442                	ld	s0,16(sp)
ffffffffc02022aa:	64a2                	ld	s1,8(sp)
ffffffffc02022ac:	6902                	ld	s2,0(sp)
ffffffffc02022ae:	6105                	addi	sp,sp,32
ffffffffc02022b0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02022b2:	6418                	ld	a4,8(s0)
ffffffffc02022b4:	e798                	sd	a4,8(a5)
ffffffffc02022b6:	b7d1                	j	ffffffffc020227a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02022b8:	b6cfe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc02022bc:	4605                	li	a2,1
ffffffffc02022be:	bf99                	j	ffffffffc0202214 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02022c0:	843e                	mv	s0,a5
ffffffffc02022c2:	87b6                	mv	a5,a3
ffffffffc02022c4:	b745                	j	ffffffffc0202264 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02022c6:	00005697          	auipc	a3,0x5
ffffffffc02022ca:	31268693          	addi	a3,a3,786 # ffffffffc02075d8 <commands+0xe98>
ffffffffc02022ce:	00005617          	auipc	a2,0x5
ffffffffc02022d2:	88260613          	addi	a2,a2,-1918 # ffffffffc0206b50 <commands+0x410>
ffffffffc02022d6:	06400593          	li	a1,100
ffffffffc02022da:	00005517          	auipc	a0,0x5
ffffffffc02022de:	31e50513          	addi	a0,a0,798 # ffffffffc02075f8 <commands+0xeb8>
ffffffffc02022e2:	f27fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02022e6 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02022e6:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02022e8:	00005517          	auipc	a0,0x5
ffffffffc02022ec:	32850513          	addi	a0,a0,808 # ffffffffc0207610 <commands+0xed0>
kmalloc_init(void) {
ffffffffc02022f0:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02022f2:	ddbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02022f6:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02022f8:	00005517          	auipc	a0,0x5
ffffffffc02022fc:	33050513          	addi	a0,a0,816 # ffffffffc0207628 <commands+0xee8>
}
ffffffffc0202300:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202302:	dcbfd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0202306 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0202306:	4501                	li	a0,0
ffffffffc0202308:	8082                	ret

ffffffffc020230a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020230a:	1101                	addi	sp,sp,-32
ffffffffc020230c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020230e:	6905                	lui	s2,0x1
{
ffffffffc0202310:	e822                	sd	s0,16(sp)
ffffffffc0202312:	ec06                	sd	ra,24(sp)
ffffffffc0202314:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202316:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc020231a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020231c:	04a7f963          	bgeu	a5,a0,ffffffffc020236e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202320:	4561                	li	a0,24
ffffffffc0202322:	ecfff0ef          	jal	ra,ffffffffc02021f0 <slob_alloc.constprop.0>
ffffffffc0202326:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202328:	c929                	beqz	a0,ffffffffc020237a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc020232a:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020232e:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202330:	00f95763          	bge	s2,a5,ffffffffc020233e <kmalloc+0x34>
ffffffffc0202334:	6705                	lui	a4,0x1
ffffffffc0202336:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202338:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020233a:	fef74ee3          	blt	a4,a5,ffffffffc0202336 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020233e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202340:	e4dff0ef          	jal	ra,ffffffffc020218c <__slob_get_free_pages.constprop.0>
ffffffffc0202344:	e488                	sd	a0,8(s1)
ffffffffc0202346:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202348:	c525                	beqz	a0,ffffffffc02023b0 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020234a:	100027f3          	csrr	a5,sstatus
ffffffffc020234e:	8b89                	andi	a5,a5,2
ffffffffc0202350:	ef8d                	bnez	a5,ffffffffc020238a <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202352:	000b0797          	auipc	a5,0xb0
ffffffffc0202356:	4e678793          	addi	a5,a5,1254 # ffffffffc02b2838 <bigblocks>
ffffffffc020235a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020235c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020235e:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202360:	60e2                	ld	ra,24(sp)
ffffffffc0202362:	8522                	mv	a0,s0
ffffffffc0202364:	6442                	ld	s0,16(sp)
ffffffffc0202366:	64a2                	ld	s1,8(sp)
ffffffffc0202368:	6902                	ld	s2,0(sp)
ffffffffc020236a:	6105                	addi	sp,sp,32
ffffffffc020236c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020236e:	0541                	addi	a0,a0,16
ffffffffc0202370:	e81ff0ef          	jal	ra,ffffffffc02021f0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202374:	01050413          	addi	s0,a0,16
ffffffffc0202378:	f565                	bnez	a0,ffffffffc0202360 <kmalloc+0x56>
ffffffffc020237a:	4401                	li	s0,0
}
ffffffffc020237c:	60e2                	ld	ra,24(sp)
ffffffffc020237e:	8522                	mv	a0,s0
ffffffffc0202380:	6442                	ld	s0,16(sp)
ffffffffc0202382:	64a2                	ld	s1,8(sp)
ffffffffc0202384:	6902                	ld	s2,0(sp)
ffffffffc0202386:	6105                	addi	sp,sp,32
ffffffffc0202388:	8082                	ret
        intr_disable();
ffffffffc020238a:	a9afe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		bb->next = bigblocks;
ffffffffc020238e:	000b0797          	auipc	a5,0xb0
ffffffffc0202392:	4aa78793          	addi	a5,a5,1194 # ffffffffc02b2838 <bigblocks>
ffffffffc0202396:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202398:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020239a:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020239c:	a82fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
		return bb->pages;
ffffffffc02023a0:	6480                	ld	s0,8(s1)
}
ffffffffc02023a2:	60e2                	ld	ra,24(sp)
ffffffffc02023a4:	64a2                	ld	s1,8(sp)
ffffffffc02023a6:	8522                	mv	a0,s0
ffffffffc02023a8:	6442                	ld	s0,16(sp)
ffffffffc02023aa:	6902                	ld	s2,0(sp)
ffffffffc02023ac:	6105                	addi	sp,sp,32
ffffffffc02023ae:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02023b0:	45e1                	li	a1,24
ffffffffc02023b2:	8526                	mv	a0,s1
ffffffffc02023b4:	d25ff0ef          	jal	ra,ffffffffc02020d8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc02023b8:	b765                	j	ffffffffc0202360 <kmalloc+0x56>

ffffffffc02023ba <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02023ba:	c179                	beqz	a0,ffffffffc0202480 <kfree+0xc6>
{
ffffffffc02023bc:	1101                	addi	sp,sp,-32
ffffffffc02023be:	e822                	sd	s0,16(sp)
ffffffffc02023c0:	ec06                	sd	ra,24(sp)
ffffffffc02023c2:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02023c4:	03451793          	slli	a5,a0,0x34
ffffffffc02023c8:	842a                	mv	s0,a0
ffffffffc02023ca:	e7c1                	bnez	a5,ffffffffc0202452 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023cc:	100027f3          	csrr	a5,sstatus
ffffffffc02023d0:	8b89                	andi	a5,a5,2
ffffffffc02023d2:	ebc9                	bnez	a5,ffffffffc0202464 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02023d4:	000b0797          	auipc	a5,0xb0
ffffffffc02023d8:	4647b783          	ld	a5,1124(a5) # ffffffffc02b2838 <bigblocks>
    return 0;
ffffffffc02023dc:	4601                	li	a2,0
ffffffffc02023de:	cbb5                	beqz	a5,ffffffffc0202452 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02023e0:	000b0697          	auipc	a3,0xb0
ffffffffc02023e4:	45868693          	addi	a3,a3,1112 # ffffffffc02b2838 <bigblocks>
ffffffffc02023e8:	a021                	j	ffffffffc02023f0 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02023ea:	01048693          	addi	a3,s1,16
ffffffffc02023ee:	c3ad                	beqz	a5,ffffffffc0202450 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02023f0:	6798                	ld	a4,8(a5)
ffffffffc02023f2:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02023f4:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02023f6:	fe871ae3          	bne	a4,s0,ffffffffc02023ea <kfree+0x30>
				*last = bb->next;
ffffffffc02023fa:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02023fc:	ee3d                	bnez	a2,ffffffffc020247a <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02023fe:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0202402:	4098                	lw	a4,0(s1)
ffffffffc0202404:	08f46b63          	bltu	s0,a5,ffffffffc020249a <kfree+0xe0>
ffffffffc0202408:	000b0697          	auipc	a3,0xb0
ffffffffc020240c:	4606b683          	ld	a3,1120(a3) # ffffffffc02b2868 <va_pa_offset>
ffffffffc0202410:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0202412:	8031                	srli	s0,s0,0xc
ffffffffc0202414:	000b0797          	auipc	a5,0xb0
ffffffffc0202418:	43c7b783          	ld	a5,1084(a5) # ffffffffc02b2850 <npage>
ffffffffc020241c:	06f47363          	bgeu	s0,a5,ffffffffc0202482 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202420:	00006517          	auipc	a0,0x6
ffffffffc0202424:	70053503          	ld	a0,1792(a0) # ffffffffc0208b20 <nbase>
ffffffffc0202428:	8c09                	sub	s0,s0,a0
ffffffffc020242a:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020242c:	000b0517          	auipc	a0,0xb0
ffffffffc0202430:	42c53503          	ld	a0,1068(a0) # ffffffffc02b2858 <pages>
ffffffffc0202434:	4585                	li	a1,1
ffffffffc0202436:	9522                	add	a0,a0,s0
ffffffffc0202438:	00e595bb          	sllw	a1,a1,a4
ffffffffc020243c:	7ef000ef          	jal	ra,ffffffffc020342a <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202440:	6442                	ld	s0,16(sp)
ffffffffc0202442:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202444:	8526                	mv	a0,s1
}
ffffffffc0202446:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202448:	45e1                	li	a1,24
}
ffffffffc020244a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020244c:	c8dff06f          	j	ffffffffc02020d8 <slob_free>
ffffffffc0202450:	e215                	bnez	a2,ffffffffc0202474 <kfree+0xba>
ffffffffc0202452:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202456:	6442                	ld	s0,16(sp)
ffffffffc0202458:	60e2                	ld	ra,24(sp)
ffffffffc020245a:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020245c:	4581                	li	a1,0
}
ffffffffc020245e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202460:	c79ff06f          	j	ffffffffc02020d8 <slob_free>
        intr_disable();
ffffffffc0202464:	9c0fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202468:	000b0797          	auipc	a5,0xb0
ffffffffc020246c:	3d07b783          	ld	a5,976(a5) # ffffffffc02b2838 <bigblocks>
        return 1;
ffffffffc0202470:	4605                	li	a2,1
ffffffffc0202472:	f7bd                	bnez	a5,ffffffffc02023e0 <kfree+0x26>
        intr_enable();
ffffffffc0202474:	9aafe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0202478:	bfe9                	j	ffffffffc0202452 <kfree+0x98>
ffffffffc020247a:	9a4fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020247e:	b741                	j	ffffffffc02023fe <kfree+0x44>
ffffffffc0202480:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202482:	00005617          	auipc	a2,0x5
ffffffffc0202486:	c6e60613          	addi	a2,a2,-914 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc020248a:	06200593          	li	a1,98
ffffffffc020248e:	00005517          	auipc	a0,0x5
ffffffffc0202492:	c8250513          	addi	a0,a0,-894 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0202496:	d73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020249a:	86a2                	mv	a3,s0
ffffffffc020249c:	00005617          	auipc	a2,0x5
ffffffffc02024a0:	1ac60613          	addi	a2,a2,428 # ffffffffc0207648 <commands+0xf08>
ffffffffc02024a4:	06e00593          	li	a1,110
ffffffffc02024a8:	00005517          	auipc	a0,0x5
ffffffffc02024ac:	c6850513          	addi	a0,a0,-920 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02024b0:	d59fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02024b4 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02024b4:	000ac797          	auipc	a5,0xac
ffffffffc02024b8:	30c78793          	addi	a5,a5,780 # ffffffffc02ae7c0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02024bc:	f51c                	sd	a5,40(a0)
ffffffffc02024be:	e79c                	sd	a5,8(a5)
ffffffffc02024c0:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02024c2:	4501                	li	a0,0
ffffffffc02024c4:	8082                	ret

ffffffffc02024c6 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02024c6:	4501                	li	a0,0
ffffffffc02024c8:	8082                	ret

ffffffffc02024ca <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02024ca:	4501                	li	a0,0
ffffffffc02024cc:	8082                	ret

ffffffffc02024ce <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02024ce:	4501                	li	a0,0
ffffffffc02024d0:	8082                	ret

ffffffffc02024d2 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02024d2:	711d                	addi	sp,sp,-96
ffffffffc02024d4:	fc4e                	sd	s3,56(sp)
ffffffffc02024d6:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02024d8:	00005517          	auipc	a0,0x5
ffffffffc02024dc:	19850513          	addi	a0,a0,408 # ffffffffc0207670 <commands+0xf30>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02024e0:	698d                	lui	s3,0x3
ffffffffc02024e2:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02024e4:	e0ca                	sd	s2,64(sp)
ffffffffc02024e6:	ec86                	sd	ra,88(sp)
ffffffffc02024e8:	e8a2                	sd	s0,80(sp)
ffffffffc02024ea:	e4a6                	sd	s1,72(sp)
ffffffffc02024ec:	f456                	sd	s5,40(sp)
ffffffffc02024ee:	f05a                	sd	s6,32(sp)
ffffffffc02024f0:	ec5e                	sd	s7,24(sp)
ffffffffc02024f2:	e862                	sd	s8,16(sp)
ffffffffc02024f4:	e466                	sd	s9,8(sp)
ffffffffc02024f6:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02024f8:	bd5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02024fc:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
    assert(pgfault_num==4);
ffffffffc0202500:	000b0917          	auipc	s2,0xb0
ffffffffc0202504:	31892903          	lw	s2,792(s2) # ffffffffc02b2818 <pgfault_num>
ffffffffc0202508:	4791                	li	a5,4
ffffffffc020250a:	14f91e63          	bne	s2,a5,ffffffffc0202666 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020250e:	00005517          	auipc	a0,0x5
ffffffffc0202512:	1a250513          	addi	a0,a0,418 # ffffffffc02076b0 <commands+0xf70>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202516:	6a85                	lui	s5,0x1
ffffffffc0202518:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020251a:	bb3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020251e:	000b0417          	auipc	s0,0xb0
ffffffffc0202522:	2fa40413          	addi	s0,s0,762 # ffffffffc02b2818 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202526:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    assert(pgfault_num==4);
ffffffffc020252a:	4004                	lw	s1,0(s0)
ffffffffc020252c:	2481                	sext.w	s1,s1
ffffffffc020252e:	2b249c63          	bne	s1,s2,ffffffffc02027e6 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202532:	00005517          	auipc	a0,0x5
ffffffffc0202536:	1a650513          	addi	a0,a0,422 # ffffffffc02076d8 <commands+0xf98>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020253a:	6b91                	lui	s7,0x4
ffffffffc020253c:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020253e:	b8ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202542:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
    assert(pgfault_num==4);
ffffffffc0202546:	00042903          	lw	s2,0(s0)
ffffffffc020254a:	2901                	sext.w	s2,s2
ffffffffc020254c:	26991d63          	bne	s2,s1,ffffffffc02027c6 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202550:	00005517          	auipc	a0,0x5
ffffffffc0202554:	1b050513          	addi	a0,a0,432 # ffffffffc0207700 <commands+0xfc0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202558:	6c89                	lui	s9,0x2
ffffffffc020255a:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020255c:	b71fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202560:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
    assert(pgfault_num==4);
ffffffffc0202564:	401c                	lw	a5,0(s0)
ffffffffc0202566:	2781                	sext.w	a5,a5
ffffffffc0202568:	23279f63          	bne	a5,s2,ffffffffc02027a6 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020256c:	00005517          	auipc	a0,0x5
ffffffffc0202570:	1bc50513          	addi	a0,a0,444 # ffffffffc0207728 <commands+0xfe8>
ffffffffc0202574:	b59fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202578:	6795                	lui	a5,0x5
ffffffffc020257a:	4739                	li	a4,14
ffffffffc020257c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==5);
ffffffffc0202580:	4004                	lw	s1,0(s0)
ffffffffc0202582:	4795                	li	a5,5
ffffffffc0202584:	2481                	sext.w	s1,s1
ffffffffc0202586:	20f49063          	bne	s1,a5,ffffffffc0202786 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020258a:	00005517          	auipc	a0,0x5
ffffffffc020258e:	17650513          	addi	a0,a0,374 # ffffffffc0207700 <commands+0xfc0>
ffffffffc0202592:	b3bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202596:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020259a:	401c                	lw	a5,0(s0)
ffffffffc020259c:	2781                	sext.w	a5,a5
ffffffffc020259e:	1c979463          	bne	a5,s1,ffffffffc0202766 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025a2:	00005517          	auipc	a0,0x5
ffffffffc02025a6:	10e50513          	addi	a0,a0,270 # ffffffffc02076b0 <commands+0xf70>
ffffffffc02025aa:	b23fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025ae:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02025b2:	401c                	lw	a5,0(s0)
ffffffffc02025b4:	4719                	li	a4,6
ffffffffc02025b6:	2781                	sext.w	a5,a5
ffffffffc02025b8:	18e79763          	bne	a5,a4,ffffffffc0202746 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02025bc:	00005517          	auipc	a0,0x5
ffffffffc02025c0:	14450513          	addi	a0,a0,324 # ffffffffc0207700 <commands+0xfc0>
ffffffffc02025c4:	b09fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02025c8:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02025cc:	401c                	lw	a5,0(s0)
ffffffffc02025ce:	471d                	li	a4,7
ffffffffc02025d0:	2781                	sext.w	a5,a5
ffffffffc02025d2:	14e79a63          	bne	a5,a4,ffffffffc0202726 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025d6:	00005517          	auipc	a0,0x5
ffffffffc02025da:	09a50513          	addi	a0,a0,154 # ffffffffc0207670 <commands+0xf30>
ffffffffc02025de:	aeffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025e2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02025e6:	401c                	lw	a5,0(s0)
ffffffffc02025e8:	4721                	li	a4,8
ffffffffc02025ea:	2781                	sext.w	a5,a5
ffffffffc02025ec:	10e79d63          	bne	a5,a4,ffffffffc0202706 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025f0:	00005517          	auipc	a0,0x5
ffffffffc02025f4:	0e850513          	addi	a0,a0,232 # ffffffffc02076d8 <commands+0xf98>
ffffffffc02025f8:	ad5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025fc:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0202600:	401c                	lw	a5,0(s0)
ffffffffc0202602:	4725                	li	a4,9
ffffffffc0202604:	2781                	sext.w	a5,a5
ffffffffc0202606:	0ee79063          	bne	a5,a4,ffffffffc02026e6 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020260a:	00005517          	auipc	a0,0x5
ffffffffc020260e:	11e50513          	addi	a0,a0,286 # ffffffffc0207728 <commands+0xfe8>
ffffffffc0202612:	abbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202616:	6795                	lui	a5,0x5
ffffffffc0202618:	4739                	li	a4,14
ffffffffc020261a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==10);
ffffffffc020261e:	4004                	lw	s1,0(s0)
ffffffffc0202620:	47a9                	li	a5,10
ffffffffc0202622:	2481                	sext.w	s1,s1
ffffffffc0202624:	0af49163          	bne	s1,a5,ffffffffc02026c6 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202628:	00005517          	auipc	a0,0x5
ffffffffc020262c:	08850513          	addi	a0,a0,136 # ffffffffc02076b0 <commands+0xf70>
ffffffffc0202630:	a9dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202634:	6785                	lui	a5,0x1
ffffffffc0202636:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc020263a:	06979663          	bne	a5,s1,ffffffffc02026a6 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc020263e:	401c                	lw	a5,0(s0)
ffffffffc0202640:	472d                	li	a4,11
ffffffffc0202642:	2781                	sext.w	a5,a5
ffffffffc0202644:	04e79163          	bne	a5,a4,ffffffffc0202686 <_fifo_check_swap+0x1b4>
}
ffffffffc0202648:	60e6                	ld	ra,88(sp)
ffffffffc020264a:	6446                	ld	s0,80(sp)
ffffffffc020264c:	64a6                	ld	s1,72(sp)
ffffffffc020264e:	6906                	ld	s2,64(sp)
ffffffffc0202650:	79e2                	ld	s3,56(sp)
ffffffffc0202652:	7a42                	ld	s4,48(sp)
ffffffffc0202654:	7aa2                	ld	s5,40(sp)
ffffffffc0202656:	7b02                	ld	s6,32(sp)
ffffffffc0202658:	6be2                	ld	s7,24(sp)
ffffffffc020265a:	6c42                	ld	s8,16(sp)
ffffffffc020265c:	6ca2                	ld	s9,8(sp)
ffffffffc020265e:	6d02                	ld	s10,0(sp)
ffffffffc0202660:	4501                	li	a0,0
ffffffffc0202662:	6125                	addi	sp,sp,96
ffffffffc0202664:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202666:	00005697          	auipc	a3,0x5
ffffffffc020266a:	dda68693          	addi	a3,a3,-550 # ffffffffc0207440 <commands+0xd00>
ffffffffc020266e:	00004617          	auipc	a2,0x4
ffffffffc0202672:	4e260613          	addi	a2,a2,1250 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202676:	05400593          	li	a1,84
ffffffffc020267a:	00005517          	auipc	a0,0x5
ffffffffc020267e:	01e50513          	addi	a0,a0,30 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202682:	b87fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0202686:	00005697          	auipc	a3,0x5
ffffffffc020268a:	15268693          	addi	a3,a3,338 # ffffffffc02077d8 <commands+0x1098>
ffffffffc020268e:	00004617          	auipc	a2,0x4
ffffffffc0202692:	4c260613          	addi	a2,a2,1218 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202696:	07600593          	li	a1,118
ffffffffc020269a:	00005517          	auipc	a0,0x5
ffffffffc020269e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0207698 <commands+0xf58>
ffffffffc02026a2:	b67fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026a6:	00005697          	auipc	a3,0x5
ffffffffc02026aa:	10a68693          	addi	a3,a3,266 # ffffffffc02077b0 <commands+0x1070>
ffffffffc02026ae:	00004617          	auipc	a2,0x4
ffffffffc02026b2:	4a260613          	addi	a2,a2,1186 # ffffffffc0206b50 <commands+0x410>
ffffffffc02026b6:	07400593          	li	a1,116
ffffffffc02026ba:	00005517          	auipc	a0,0x5
ffffffffc02026be:	fde50513          	addi	a0,a0,-34 # ffffffffc0207698 <commands+0xf58>
ffffffffc02026c2:	b47fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc02026c6:	00005697          	auipc	a3,0x5
ffffffffc02026ca:	0da68693          	addi	a3,a3,218 # ffffffffc02077a0 <commands+0x1060>
ffffffffc02026ce:	00004617          	auipc	a2,0x4
ffffffffc02026d2:	48260613          	addi	a2,a2,1154 # ffffffffc0206b50 <commands+0x410>
ffffffffc02026d6:	07200593          	li	a1,114
ffffffffc02026da:	00005517          	auipc	a0,0x5
ffffffffc02026de:	fbe50513          	addi	a0,a0,-66 # ffffffffc0207698 <commands+0xf58>
ffffffffc02026e2:	b27fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc02026e6:	00005697          	auipc	a3,0x5
ffffffffc02026ea:	0aa68693          	addi	a3,a3,170 # ffffffffc0207790 <commands+0x1050>
ffffffffc02026ee:	00004617          	auipc	a2,0x4
ffffffffc02026f2:	46260613          	addi	a2,a2,1122 # ffffffffc0206b50 <commands+0x410>
ffffffffc02026f6:	06f00593          	li	a1,111
ffffffffc02026fa:	00005517          	auipc	a0,0x5
ffffffffc02026fe:	f9e50513          	addi	a0,a0,-98 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202702:	b07fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc0202706:	00005697          	auipc	a3,0x5
ffffffffc020270a:	07a68693          	addi	a3,a3,122 # ffffffffc0207780 <commands+0x1040>
ffffffffc020270e:	00004617          	auipc	a2,0x4
ffffffffc0202712:	44260613          	addi	a2,a2,1090 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202716:	06c00593          	li	a1,108
ffffffffc020271a:	00005517          	auipc	a0,0x5
ffffffffc020271e:	f7e50513          	addi	a0,a0,-130 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202722:	ae7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc0202726:	00005697          	auipc	a3,0x5
ffffffffc020272a:	04a68693          	addi	a3,a3,74 # ffffffffc0207770 <commands+0x1030>
ffffffffc020272e:	00004617          	auipc	a2,0x4
ffffffffc0202732:	42260613          	addi	a2,a2,1058 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202736:	06900593          	li	a1,105
ffffffffc020273a:	00005517          	auipc	a0,0x5
ffffffffc020273e:	f5e50513          	addi	a0,a0,-162 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202742:	ac7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0202746:	00005697          	auipc	a3,0x5
ffffffffc020274a:	01a68693          	addi	a3,a3,26 # ffffffffc0207760 <commands+0x1020>
ffffffffc020274e:	00004617          	auipc	a2,0x4
ffffffffc0202752:	40260613          	addi	a2,a2,1026 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202756:	06600593          	li	a1,102
ffffffffc020275a:	00005517          	auipc	a0,0x5
ffffffffc020275e:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202762:	aa7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202766:	00005697          	auipc	a3,0x5
ffffffffc020276a:	fea68693          	addi	a3,a3,-22 # ffffffffc0207750 <commands+0x1010>
ffffffffc020276e:	00004617          	auipc	a2,0x4
ffffffffc0202772:	3e260613          	addi	a2,a2,994 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202776:	06300593          	li	a1,99
ffffffffc020277a:	00005517          	auipc	a0,0x5
ffffffffc020277e:	f1e50513          	addi	a0,a0,-226 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202782:	a87fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202786:	00005697          	auipc	a3,0x5
ffffffffc020278a:	fca68693          	addi	a3,a3,-54 # ffffffffc0207750 <commands+0x1010>
ffffffffc020278e:	00004617          	auipc	a2,0x4
ffffffffc0202792:	3c260613          	addi	a2,a2,962 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202796:	06000593          	li	a1,96
ffffffffc020279a:	00005517          	auipc	a0,0x5
ffffffffc020279e:	efe50513          	addi	a0,a0,-258 # ffffffffc0207698 <commands+0xf58>
ffffffffc02027a2:	a67fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02027a6:	00005697          	auipc	a3,0x5
ffffffffc02027aa:	c9a68693          	addi	a3,a3,-870 # ffffffffc0207440 <commands+0xd00>
ffffffffc02027ae:	00004617          	auipc	a2,0x4
ffffffffc02027b2:	3a260613          	addi	a2,a2,930 # ffffffffc0206b50 <commands+0x410>
ffffffffc02027b6:	05d00593          	li	a1,93
ffffffffc02027ba:	00005517          	auipc	a0,0x5
ffffffffc02027be:	ede50513          	addi	a0,a0,-290 # ffffffffc0207698 <commands+0xf58>
ffffffffc02027c2:	a47fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02027c6:	00005697          	auipc	a3,0x5
ffffffffc02027ca:	c7a68693          	addi	a3,a3,-902 # ffffffffc0207440 <commands+0xd00>
ffffffffc02027ce:	00004617          	auipc	a2,0x4
ffffffffc02027d2:	38260613          	addi	a2,a2,898 # ffffffffc0206b50 <commands+0x410>
ffffffffc02027d6:	05a00593          	li	a1,90
ffffffffc02027da:	00005517          	auipc	a0,0x5
ffffffffc02027de:	ebe50513          	addi	a0,a0,-322 # ffffffffc0207698 <commands+0xf58>
ffffffffc02027e2:	a27fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02027e6:	00005697          	auipc	a3,0x5
ffffffffc02027ea:	c5a68693          	addi	a3,a3,-934 # ffffffffc0207440 <commands+0xd00>
ffffffffc02027ee:	00004617          	auipc	a2,0x4
ffffffffc02027f2:	36260613          	addi	a2,a2,866 # ffffffffc0206b50 <commands+0x410>
ffffffffc02027f6:	05700593          	li	a1,87
ffffffffc02027fa:	00005517          	auipc	a0,0x5
ffffffffc02027fe:	e9e50513          	addi	a0,a0,-354 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202802:	a07fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202806 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202806:	7518                	ld	a4,40(a0)
{
ffffffffc0202808:	1141                	addi	sp,sp,-16
ffffffffc020280a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020280c:	c731                	beqz	a4,ffffffffc0202858 <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc020280e:	e60d                	bnez	a2,ffffffffc0202838 <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0202810:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0202812:	00f70d63          	beq	a4,a5,ffffffffc020282c <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202816:	6394                	ld	a3,0(a5)
ffffffffc0202818:	6798                	ld	a4,8(a5)
}
ffffffffc020281a:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc020281c:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0202820:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202822:	e314                	sd	a3,0(a4)
ffffffffc0202824:	e19c                	sd	a5,0(a1)
}
ffffffffc0202826:	4501                	li	a0,0
ffffffffc0202828:	0141                	addi	sp,sp,16
ffffffffc020282a:	8082                	ret
ffffffffc020282c:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc020282e:	0005b023          	sd	zero,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
}
ffffffffc0202832:	4501                	li	a0,0
ffffffffc0202834:	0141                	addi	sp,sp,16
ffffffffc0202836:	8082                	ret
     assert(in_tick==0);
ffffffffc0202838:	00005697          	auipc	a3,0x5
ffffffffc020283c:	fc068693          	addi	a3,a3,-64 # ffffffffc02077f8 <commands+0x10b8>
ffffffffc0202840:	00004617          	auipc	a2,0x4
ffffffffc0202844:	31060613          	addi	a2,a2,784 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202848:	04200593          	li	a1,66
ffffffffc020284c:	00005517          	auipc	a0,0x5
ffffffffc0202850:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202854:	9b5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(head != NULL);
ffffffffc0202858:	00005697          	auipc	a3,0x5
ffffffffc020285c:	f9068693          	addi	a3,a3,-112 # ffffffffc02077e8 <commands+0x10a8>
ffffffffc0202860:	00004617          	auipc	a2,0x4
ffffffffc0202864:	2f060613          	addi	a2,a2,752 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202868:	04100593          	li	a1,65
ffffffffc020286c:	00005517          	auipc	a0,0x5
ffffffffc0202870:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207698 <commands+0xf58>
ffffffffc0202874:	995fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202878 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202878:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020287a:	cb91                	beqz	a5,ffffffffc020288e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc020287c:	6794                	ld	a3,8(a5)
ffffffffc020287e:	02860713          	addi	a4,a2,40
}
ffffffffc0202882:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0202884:	e298                	sd	a4,0(a3)
ffffffffc0202886:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202888:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc020288a:	f61c                	sd	a5,40(a2)
ffffffffc020288c:	8082                	ret
{
ffffffffc020288e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202890:	00005697          	auipc	a3,0x5
ffffffffc0202894:	f7868693          	addi	a3,a3,-136 # ffffffffc0207808 <commands+0x10c8>
ffffffffc0202898:	00004617          	auipc	a2,0x4
ffffffffc020289c:	2b860613          	addi	a2,a2,696 # ffffffffc0206b50 <commands+0x410>
ffffffffc02028a0:	03200593          	li	a1,50
ffffffffc02028a4:	00005517          	auipc	a0,0x5
ffffffffc02028a8:	df450513          	addi	a0,a0,-524 # ffffffffc0207698 <commands+0xf58>
{
ffffffffc02028ac:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02028ae:	95bfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028b2 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02028b2:	000ac797          	auipc	a5,0xac
ffffffffc02028b6:	f1e78793          	addi	a5,a5,-226 # ffffffffc02ae7d0 <free_area>
ffffffffc02028ba:	e79c                	sd	a5,8(a5)
ffffffffc02028bc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02028be:	0007a823          	sw	zero,16(a5)
}
ffffffffc02028c2:	8082                	ret

ffffffffc02028c4 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02028c4:	000ac517          	auipc	a0,0xac
ffffffffc02028c8:	f1c56503          	lwu	a0,-228(a0) # ffffffffc02ae7e0 <free_area+0x10>
ffffffffc02028cc:	8082                	ret

ffffffffc02028ce <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02028ce:	715d                	addi	sp,sp,-80
ffffffffc02028d0:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02028d2:	000ac417          	auipc	s0,0xac
ffffffffc02028d6:	efe40413          	addi	s0,s0,-258 # ffffffffc02ae7d0 <free_area>
ffffffffc02028da:	641c                	ld	a5,8(s0)
ffffffffc02028dc:	e486                	sd	ra,72(sp)
ffffffffc02028de:	fc26                	sd	s1,56(sp)
ffffffffc02028e0:	f84a                	sd	s2,48(sp)
ffffffffc02028e2:	f44e                	sd	s3,40(sp)
ffffffffc02028e4:	f052                	sd	s4,32(sp)
ffffffffc02028e6:	ec56                	sd	s5,24(sp)
ffffffffc02028e8:	e85a                	sd	s6,16(sp)
ffffffffc02028ea:	e45e                	sd	s7,8(sp)
ffffffffc02028ec:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02028ee:	2a878d63          	beq	a5,s0,ffffffffc0202ba8 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02028f2:	4481                	li	s1,0
ffffffffc02028f4:	4901                	li	s2,0
ffffffffc02028f6:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028fa:	8b09                	andi	a4,a4,2
ffffffffc02028fc:	2a070a63          	beqz	a4,ffffffffc0202bb0 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202900:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202904:	679c                	ld	a5,8(a5)
ffffffffc0202906:	2905                	addiw	s2,s2,1
ffffffffc0202908:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020290a:	fe8796e3          	bne	a5,s0,ffffffffc02028f6 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020290e:	89a6                	mv	s3,s1
ffffffffc0202910:	35b000ef          	jal	ra,ffffffffc020346a <nr_free_pages>
ffffffffc0202914:	6f351e63          	bne	a0,s3,ffffffffc0203010 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202918:	4505                	li	a0,1
ffffffffc020291a:	27f000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc020291e:	8aaa                	mv	s5,a0
ffffffffc0202920:	42050863          	beqz	a0,ffffffffc0202d50 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202924:	4505                	li	a0,1
ffffffffc0202926:	273000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc020292a:	89aa                	mv	s3,a0
ffffffffc020292c:	70050263          	beqz	a0,ffffffffc0203030 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202930:	4505                	li	a0,1
ffffffffc0202932:	267000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202936:	8a2a                	mv	s4,a0
ffffffffc0202938:	48050c63          	beqz	a0,ffffffffc0202dd0 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020293c:	293a8a63          	beq	s5,s3,ffffffffc0202bd0 <default_check+0x302>
ffffffffc0202940:	28aa8863          	beq	s5,a0,ffffffffc0202bd0 <default_check+0x302>
ffffffffc0202944:	28a98663          	beq	s3,a0,ffffffffc0202bd0 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202948:	000aa783          	lw	a5,0(s5)
ffffffffc020294c:	2a079263          	bnez	a5,ffffffffc0202bf0 <default_check+0x322>
ffffffffc0202950:	0009a783          	lw	a5,0(s3)
ffffffffc0202954:	28079e63          	bnez	a5,ffffffffc0202bf0 <default_check+0x322>
ffffffffc0202958:	411c                	lw	a5,0(a0)
ffffffffc020295a:	28079b63          	bnez	a5,ffffffffc0202bf0 <default_check+0x322>
    return page - pages + nbase;
ffffffffc020295e:	000b0797          	auipc	a5,0xb0
ffffffffc0202962:	efa7b783          	ld	a5,-262(a5) # ffffffffc02b2858 <pages>
ffffffffc0202966:	40fa8733          	sub	a4,s5,a5
ffffffffc020296a:	00006617          	auipc	a2,0x6
ffffffffc020296e:	1b663603          	ld	a2,438(a2) # ffffffffc0208b20 <nbase>
ffffffffc0202972:	8719                	srai	a4,a4,0x6
ffffffffc0202974:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202976:	000b0697          	auipc	a3,0xb0
ffffffffc020297a:	eda6b683          	ld	a3,-294(a3) # ffffffffc02b2850 <npage>
ffffffffc020297e:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202980:	0732                	slli	a4,a4,0xc
ffffffffc0202982:	28d77763          	bgeu	a4,a3,ffffffffc0202c10 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202986:	40f98733          	sub	a4,s3,a5
ffffffffc020298a:	8719                	srai	a4,a4,0x6
ffffffffc020298c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020298e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202990:	4cd77063          	bgeu	a4,a3,ffffffffc0202e50 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202994:	40f507b3          	sub	a5,a0,a5
ffffffffc0202998:	8799                	srai	a5,a5,0x6
ffffffffc020299a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020299c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020299e:	30d7f963          	bgeu	a5,a3,ffffffffc0202cb0 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02029a2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02029a4:	00043c03          	ld	s8,0(s0)
ffffffffc02029a8:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02029ac:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02029b0:	e400                	sd	s0,8(s0)
ffffffffc02029b2:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02029b4:	000ac797          	auipc	a5,0xac
ffffffffc02029b8:	e207a623          	sw	zero,-468(a5) # ffffffffc02ae7e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02029bc:	1dd000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02029c0:	2c051863          	bnez	a0,ffffffffc0202c90 <default_check+0x3c2>
    free_page(p0);
ffffffffc02029c4:	4585                	li	a1,1
ffffffffc02029c6:	8556                	mv	a0,s5
ffffffffc02029c8:	263000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_page(p1);
ffffffffc02029cc:	4585                	li	a1,1
ffffffffc02029ce:	854e                	mv	a0,s3
ffffffffc02029d0:	25b000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_page(p2);
ffffffffc02029d4:	4585                	li	a1,1
ffffffffc02029d6:	8552                	mv	a0,s4
ffffffffc02029d8:	253000ef          	jal	ra,ffffffffc020342a <free_pages>
    assert(nr_free == 3);
ffffffffc02029dc:	4818                	lw	a4,16(s0)
ffffffffc02029de:	478d                	li	a5,3
ffffffffc02029e0:	28f71863          	bne	a4,a5,ffffffffc0202c70 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02029e4:	4505                	li	a0,1
ffffffffc02029e6:	1b3000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02029ea:	89aa                	mv	s3,a0
ffffffffc02029ec:	26050263          	beqz	a0,ffffffffc0202c50 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029f0:	4505                	li	a0,1
ffffffffc02029f2:	1a7000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02029f6:	8aaa                	mv	s5,a0
ffffffffc02029f8:	3a050c63          	beqz	a0,ffffffffc0202db0 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029fc:	4505                	li	a0,1
ffffffffc02029fe:	19b000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a02:	8a2a                	mv	s4,a0
ffffffffc0202a04:	38050663          	beqz	a0,ffffffffc0202d90 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202a08:	4505                	li	a0,1
ffffffffc0202a0a:	18f000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a0e:	36051163          	bnez	a0,ffffffffc0202d70 <default_check+0x4a2>
    free_page(p0);
ffffffffc0202a12:	4585                	li	a1,1
ffffffffc0202a14:	854e                	mv	a0,s3
ffffffffc0202a16:	215000ef          	jal	ra,ffffffffc020342a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202a1a:	641c                	ld	a5,8(s0)
ffffffffc0202a1c:	20878a63          	beq	a5,s0,ffffffffc0202c30 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202a20:	4505                	li	a0,1
ffffffffc0202a22:	177000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a26:	30a99563          	bne	s3,a0,ffffffffc0202d30 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202a2a:	4505                	li	a0,1
ffffffffc0202a2c:	16d000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a30:	2e051063          	bnez	a0,ffffffffc0202d10 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202a34:	481c                	lw	a5,16(s0)
ffffffffc0202a36:	2a079d63          	bnez	a5,ffffffffc0202cf0 <default_check+0x422>
    free_page(p);
ffffffffc0202a3a:	854e                	mv	a0,s3
ffffffffc0202a3c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202a3e:	01843023          	sd	s8,0(s0)
ffffffffc0202a42:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202a46:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202a4a:	1e1000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_page(p1);
ffffffffc0202a4e:	4585                	li	a1,1
ffffffffc0202a50:	8556                	mv	a0,s5
ffffffffc0202a52:	1d9000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_page(p2);
ffffffffc0202a56:	4585                	li	a1,1
ffffffffc0202a58:	8552                	mv	a0,s4
ffffffffc0202a5a:	1d1000ef          	jal	ra,ffffffffc020342a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202a5e:	4515                	li	a0,5
ffffffffc0202a60:	139000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a64:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202a66:	26050563          	beqz	a0,ffffffffc0202cd0 <default_check+0x402>
ffffffffc0202a6a:	651c                	ld	a5,8(a0)
ffffffffc0202a6c:	8385                	srli	a5,a5,0x1
ffffffffc0202a6e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202a70:	54079063          	bnez	a5,ffffffffc0202fb0 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202a74:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202a76:	00043b03          	ld	s6,0(s0)
ffffffffc0202a7a:	00843a83          	ld	s5,8(s0)
ffffffffc0202a7e:	e000                	sd	s0,0(s0)
ffffffffc0202a80:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202a82:	117000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202a86:	50051563          	bnez	a0,ffffffffc0202f90 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202a8a:	08098a13          	addi	s4,s3,128
ffffffffc0202a8e:	8552                	mv	a0,s4
ffffffffc0202a90:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202a92:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202a96:	000ac797          	auipc	a5,0xac
ffffffffc0202a9a:	d407a523          	sw	zero,-694(a5) # ffffffffc02ae7e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202a9e:	18d000ef          	jal	ra,ffffffffc020342a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202aa2:	4511                	li	a0,4
ffffffffc0202aa4:	0f5000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202aa8:	4c051463          	bnez	a0,ffffffffc0202f70 <default_check+0x6a2>
ffffffffc0202aac:	0889b783          	ld	a5,136(s3)
ffffffffc0202ab0:	8385                	srli	a5,a5,0x1
ffffffffc0202ab2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202ab4:	48078e63          	beqz	a5,ffffffffc0202f50 <default_check+0x682>
ffffffffc0202ab8:	0909a703          	lw	a4,144(s3)
ffffffffc0202abc:	478d                	li	a5,3
ffffffffc0202abe:	48f71963          	bne	a4,a5,ffffffffc0202f50 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202ac2:	450d                	li	a0,3
ffffffffc0202ac4:	0d5000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202ac8:	8c2a                	mv	s8,a0
ffffffffc0202aca:	46050363          	beqz	a0,ffffffffc0202f30 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202ace:	4505                	li	a0,1
ffffffffc0202ad0:	0c9000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202ad4:	42051e63          	bnez	a0,ffffffffc0202f10 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202ad8:	418a1c63          	bne	s4,s8,ffffffffc0202ef0 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202adc:	4585                	li	a1,1
ffffffffc0202ade:	854e                	mv	a0,s3
ffffffffc0202ae0:	14b000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_pages(p1, 3);
ffffffffc0202ae4:	458d                	li	a1,3
ffffffffc0202ae6:	8552                	mv	a0,s4
ffffffffc0202ae8:	143000ef          	jal	ra,ffffffffc020342a <free_pages>
ffffffffc0202aec:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202af0:	04098c13          	addi	s8,s3,64
ffffffffc0202af4:	8385                	srli	a5,a5,0x1
ffffffffc0202af6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202af8:	3c078c63          	beqz	a5,ffffffffc0202ed0 <default_check+0x602>
ffffffffc0202afc:	0109a703          	lw	a4,16(s3)
ffffffffc0202b00:	4785                	li	a5,1
ffffffffc0202b02:	3cf71763          	bne	a4,a5,ffffffffc0202ed0 <default_check+0x602>
ffffffffc0202b06:	008a3783          	ld	a5,8(s4)
ffffffffc0202b0a:	8385                	srli	a5,a5,0x1
ffffffffc0202b0c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202b0e:	3a078163          	beqz	a5,ffffffffc0202eb0 <default_check+0x5e2>
ffffffffc0202b12:	010a2703          	lw	a4,16(s4)
ffffffffc0202b16:	478d                	li	a5,3
ffffffffc0202b18:	38f71c63          	bne	a4,a5,ffffffffc0202eb0 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202b1c:	4505                	li	a0,1
ffffffffc0202b1e:	07b000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202b22:	36a99763          	bne	s3,a0,ffffffffc0202e90 <default_check+0x5c2>
    free_page(p0);
ffffffffc0202b26:	4585                	li	a1,1
ffffffffc0202b28:	103000ef          	jal	ra,ffffffffc020342a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202b2c:	4509                	li	a0,2
ffffffffc0202b2e:	06b000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202b32:	32aa1f63          	bne	s4,a0,ffffffffc0202e70 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202b36:	4589                	li	a1,2
ffffffffc0202b38:	0f3000ef          	jal	ra,ffffffffc020342a <free_pages>
    free_page(p2);
ffffffffc0202b3c:	4585                	li	a1,1
ffffffffc0202b3e:	8562                	mv	a0,s8
ffffffffc0202b40:	0eb000ef          	jal	ra,ffffffffc020342a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202b44:	4515                	li	a0,5
ffffffffc0202b46:	053000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202b4a:	89aa                	mv	s3,a0
ffffffffc0202b4c:	48050263          	beqz	a0,ffffffffc0202fd0 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202b50:	4505                	li	a0,1
ffffffffc0202b52:	047000ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0202b56:	2c051d63          	bnez	a0,ffffffffc0202e30 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202b5a:	481c                	lw	a5,16(s0)
ffffffffc0202b5c:	2a079a63          	bnez	a5,ffffffffc0202e10 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202b60:	4595                	li	a1,5
ffffffffc0202b62:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202b64:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202b68:	01643023          	sd	s6,0(s0)
ffffffffc0202b6c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202b70:	0bb000ef          	jal	ra,ffffffffc020342a <free_pages>
    return listelm->next;
ffffffffc0202b74:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202b76:	00878963          	beq	a5,s0,ffffffffc0202b88 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202b7a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202b7e:	679c                	ld	a5,8(a5)
ffffffffc0202b80:	397d                	addiw	s2,s2,-1
ffffffffc0202b82:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202b84:	fe879be3          	bne	a5,s0,ffffffffc0202b7a <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202b88:	26091463          	bnez	s2,ffffffffc0202df0 <default_check+0x522>
    assert(total == 0);
ffffffffc0202b8c:	46049263          	bnez	s1,ffffffffc0202ff0 <default_check+0x722>
}
ffffffffc0202b90:	60a6                	ld	ra,72(sp)
ffffffffc0202b92:	6406                	ld	s0,64(sp)
ffffffffc0202b94:	74e2                	ld	s1,56(sp)
ffffffffc0202b96:	7942                	ld	s2,48(sp)
ffffffffc0202b98:	79a2                	ld	s3,40(sp)
ffffffffc0202b9a:	7a02                	ld	s4,32(sp)
ffffffffc0202b9c:	6ae2                	ld	s5,24(sp)
ffffffffc0202b9e:	6b42                	ld	s6,16(sp)
ffffffffc0202ba0:	6ba2                	ld	s7,8(sp)
ffffffffc0202ba2:	6c02                	ld	s8,0(sp)
ffffffffc0202ba4:	6161                	addi	sp,sp,80
ffffffffc0202ba6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ba8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202baa:	4481                	li	s1,0
ffffffffc0202bac:	4901                	li	s2,0
ffffffffc0202bae:	b38d                	j	ffffffffc0202910 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202bb0:	00004697          	auipc	a3,0x4
ffffffffc0202bb4:	6f068693          	addi	a3,a3,1776 # ffffffffc02072a0 <commands+0xb60>
ffffffffc0202bb8:	00004617          	auipc	a2,0x4
ffffffffc0202bbc:	f9860613          	addi	a2,a2,-104 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202bc0:	0f000593          	li	a1,240
ffffffffc0202bc4:	00005517          	auipc	a0,0x5
ffffffffc0202bc8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202bcc:	e3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202bd0:	00005697          	auipc	a3,0x5
ffffffffc0202bd4:	ce868693          	addi	a3,a3,-792 # ffffffffc02078b8 <commands+0x1178>
ffffffffc0202bd8:	00004617          	auipc	a2,0x4
ffffffffc0202bdc:	f7860613          	addi	a2,a2,-136 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202be0:	0bd00593          	li	a1,189
ffffffffc0202be4:	00005517          	auipc	a0,0x5
ffffffffc0202be8:	c5c50513          	addi	a0,a0,-932 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202bec:	e1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202bf0:	00005697          	auipc	a3,0x5
ffffffffc0202bf4:	cf068693          	addi	a3,a3,-784 # ffffffffc02078e0 <commands+0x11a0>
ffffffffc0202bf8:	00004617          	auipc	a2,0x4
ffffffffc0202bfc:	f5860613          	addi	a2,a2,-168 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202c00:	0be00593          	li	a1,190
ffffffffc0202c04:	00005517          	auipc	a0,0x5
ffffffffc0202c08:	c3c50513          	addi	a0,a0,-964 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202c0c:	dfcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202c10:	00005697          	auipc	a3,0x5
ffffffffc0202c14:	d1068693          	addi	a3,a3,-752 # ffffffffc0207920 <commands+0x11e0>
ffffffffc0202c18:	00004617          	auipc	a2,0x4
ffffffffc0202c1c:	f3860613          	addi	a2,a2,-200 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202c20:	0c000593          	li	a1,192
ffffffffc0202c24:	00005517          	auipc	a0,0x5
ffffffffc0202c28:	c1c50513          	addi	a0,a0,-996 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202c2c:	ddcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202c30:	00005697          	auipc	a3,0x5
ffffffffc0202c34:	d7868693          	addi	a3,a3,-648 # ffffffffc02079a8 <commands+0x1268>
ffffffffc0202c38:	00004617          	auipc	a2,0x4
ffffffffc0202c3c:	f1860613          	addi	a2,a2,-232 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202c40:	0d900593          	li	a1,217
ffffffffc0202c44:	00005517          	auipc	a0,0x5
ffffffffc0202c48:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202c4c:	dbcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202c50:	00005697          	auipc	a3,0x5
ffffffffc0202c54:	c0868693          	addi	a3,a3,-1016 # ffffffffc0207858 <commands+0x1118>
ffffffffc0202c58:	00004617          	auipc	a2,0x4
ffffffffc0202c5c:	ef860613          	addi	a2,a2,-264 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202c60:	0d200593          	li	a1,210
ffffffffc0202c64:	00005517          	auipc	a0,0x5
ffffffffc0202c68:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202c6c:	d9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202c70:	00005697          	auipc	a3,0x5
ffffffffc0202c74:	d2868693          	addi	a3,a3,-728 # ffffffffc0207998 <commands+0x1258>
ffffffffc0202c78:	00004617          	auipc	a2,0x4
ffffffffc0202c7c:	ed860613          	addi	a2,a2,-296 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202c80:	0d000593          	li	a1,208
ffffffffc0202c84:	00005517          	auipc	a0,0x5
ffffffffc0202c88:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202c8c:	d7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202c90:	00005697          	auipc	a3,0x5
ffffffffc0202c94:	cf068693          	addi	a3,a3,-784 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202c98:	00004617          	auipc	a2,0x4
ffffffffc0202c9c:	eb860613          	addi	a2,a2,-328 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202ca0:	0cb00593          	li	a1,203
ffffffffc0202ca4:	00005517          	auipc	a0,0x5
ffffffffc0202ca8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202cac:	d5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202cb0:	00005697          	auipc	a3,0x5
ffffffffc0202cb4:	cb068693          	addi	a3,a3,-848 # ffffffffc0207960 <commands+0x1220>
ffffffffc0202cb8:	00004617          	auipc	a2,0x4
ffffffffc0202cbc:	e9860613          	addi	a2,a2,-360 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202cc0:	0c200593          	li	a1,194
ffffffffc0202cc4:	00005517          	auipc	a0,0x5
ffffffffc0202cc8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202ccc:	d3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202cd0:	00005697          	auipc	a3,0x5
ffffffffc0202cd4:	d1068693          	addi	a3,a3,-752 # ffffffffc02079e0 <commands+0x12a0>
ffffffffc0202cd8:	00004617          	auipc	a2,0x4
ffffffffc0202cdc:	e7860613          	addi	a2,a2,-392 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202ce0:	0f800593          	li	a1,248
ffffffffc0202ce4:	00005517          	auipc	a0,0x5
ffffffffc0202ce8:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202cec:	d1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202cf0:	00004697          	auipc	a3,0x4
ffffffffc0202cf4:	76068693          	addi	a3,a3,1888 # ffffffffc0207450 <commands+0xd10>
ffffffffc0202cf8:	00004617          	auipc	a2,0x4
ffffffffc0202cfc:	e5860613          	addi	a2,a2,-424 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202d00:	0df00593          	li	a1,223
ffffffffc0202d04:	00005517          	auipc	a0,0x5
ffffffffc0202d08:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202d0c:	cfcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d10:	00005697          	auipc	a3,0x5
ffffffffc0202d14:	c7068693          	addi	a3,a3,-912 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202d18:	00004617          	auipc	a2,0x4
ffffffffc0202d1c:	e3860613          	addi	a2,a2,-456 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202d20:	0dd00593          	li	a1,221
ffffffffc0202d24:	00005517          	auipc	a0,0x5
ffffffffc0202d28:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202d2c:	cdcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202d30:	00005697          	auipc	a3,0x5
ffffffffc0202d34:	c9068693          	addi	a3,a3,-880 # ffffffffc02079c0 <commands+0x1280>
ffffffffc0202d38:	00004617          	auipc	a2,0x4
ffffffffc0202d3c:	e1860613          	addi	a2,a2,-488 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202d40:	0dc00593          	li	a1,220
ffffffffc0202d44:	00005517          	auipc	a0,0x5
ffffffffc0202d48:	afc50513          	addi	a0,a0,-1284 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202d4c:	cbcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202d50:	00005697          	auipc	a3,0x5
ffffffffc0202d54:	b0868693          	addi	a3,a3,-1272 # ffffffffc0207858 <commands+0x1118>
ffffffffc0202d58:	00004617          	auipc	a2,0x4
ffffffffc0202d5c:	df860613          	addi	a2,a2,-520 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202d60:	0b900593          	li	a1,185
ffffffffc0202d64:	00005517          	auipc	a0,0x5
ffffffffc0202d68:	adc50513          	addi	a0,a0,-1316 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202d6c:	c9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d70:	00005697          	auipc	a3,0x5
ffffffffc0202d74:	c1068693          	addi	a3,a3,-1008 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202d78:	00004617          	auipc	a2,0x4
ffffffffc0202d7c:	dd860613          	addi	a2,a2,-552 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202d80:	0d600593          	li	a1,214
ffffffffc0202d84:	00005517          	auipc	a0,0x5
ffffffffc0202d88:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202d8c:	c7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202d90:	00005697          	auipc	a3,0x5
ffffffffc0202d94:	b0868693          	addi	a3,a3,-1272 # ffffffffc0207898 <commands+0x1158>
ffffffffc0202d98:	00004617          	auipc	a2,0x4
ffffffffc0202d9c:	db860613          	addi	a2,a2,-584 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202da0:	0d400593          	li	a1,212
ffffffffc0202da4:	00005517          	auipc	a0,0x5
ffffffffc0202da8:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202dac:	c5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202db0:	00005697          	auipc	a3,0x5
ffffffffc0202db4:	ac868693          	addi	a3,a3,-1336 # ffffffffc0207878 <commands+0x1138>
ffffffffc0202db8:	00004617          	auipc	a2,0x4
ffffffffc0202dbc:	d9860613          	addi	a2,a2,-616 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202dc0:	0d300593          	li	a1,211
ffffffffc0202dc4:	00005517          	auipc	a0,0x5
ffffffffc0202dc8:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202dcc:	c3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202dd0:	00005697          	auipc	a3,0x5
ffffffffc0202dd4:	ac868693          	addi	a3,a3,-1336 # ffffffffc0207898 <commands+0x1158>
ffffffffc0202dd8:	00004617          	auipc	a2,0x4
ffffffffc0202ddc:	d7860613          	addi	a2,a2,-648 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202de0:	0bb00593          	li	a1,187
ffffffffc0202de4:	00005517          	auipc	a0,0x5
ffffffffc0202de8:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202dec:	c1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0202df0:	00005697          	auipc	a3,0x5
ffffffffc0202df4:	d4068693          	addi	a3,a3,-704 # ffffffffc0207b30 <commands+0x13f0>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	d5860613          	addi	a2,a2,-680 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202e00:	12500593          	li	a1,293
ffffffffc0202e04:	00005517          	auipc	a0,0x5
ffffffffc0202e08:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202e0c:	bfcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202e10:	00004697          	auipc	a3,0x4
ffffffffc0202e14:	64068693          	addi	a3,a3,1600 # ffffffffc0207450 <commands+0xd10>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	d3860613          	addi	a2,a2,-712 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202e20:	11a00593          	li	a1,282
ffffffffc0202e24:	00005517          	auipc	a0,0x5
ffffffffc0202e28:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202e2c:	bdcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e30:	00005697          	auipc	a3,0x5
ffffffffc0202e34:	b5068693          	addi	a3,a3,-1200 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202e38:	00004617          	auipc	a2,0x4
ffffffffc0202e3c:	d1860613          	addi	a2,a2,-744 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202e40:	11800593          	li	a1,280
ffffffffc0202e44:	00005517          	auipc	a0,0x5
ffffffffc0202e48:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202e4c:	bbcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202e50:	00005697          	auipc	a3,0x5
ffffffffc0202e54:	af068693          	addi	a3,a3,-1296 # ffffffffc0207940 <commands+0x1200>
ffffffffc0202e58:	00004617          	auipc	a2,0x4
ffffffffc0202e5c:	cf860613          	addi	a2,a2,-776 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202e60:	0c100593          	li	a1,193
ffffffffc0202e64:	00005517          	auipc	a0,0x5
ffffffffc0202e68:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202e6c:	b9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202e70:	00005697          	auipc	a3,0x5
ffffffffc0202e74:	c8068693          	addi	a3,a3,-896 # ffffffffc0207af0 <commands+0x13b0>
ffffffffc0202e78:	00004617          	auipc	a2,0x4
ffffffffc0202e7c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202e80:	11200593          	li	a1,274
ffffffffc0202e84:	00005517          	auipc	a0,0x5
ffffffffc0202e88:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202e8c:	b7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202e90:	00005697          	auipc	a3,0x5
ffffffffc0202e94:	c4068693          	addi	a3,a3,-960 # ffffffffc0207ad0 <commands+0x1390>
ffffffffc0202e98:	00004617          	auipc	a2,0x4
ffffffffc0202e9c:	cb860613          	addi	a2,a2,-840 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202ea0:	11000593          	li	a1,272
ffffffffc0202ea4:	00005517          	auipc	a0,0x5
ffffffffc0202ea8:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202eac:	b5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202eb0:	00005697          	auipc	a3,0x5
ffffffffc0202eb4:	bf868693          	addi	a3,a3,-1032 # ffffffffc0207aa8 <commands+0x1368>
ffffffffc0202eb8:	00004617          	auipc	a2,0x4
ffffffffc0202ebc:	c9860613          	addi	a2,a2,-872 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202ec0:	10e00593          	li	a1,270
ffffffffc0202ec4:	00005517          	auipc	a0,0x5
ffffffffc0202ec8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202ecc:	b3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202ed0:	00005697          	auipc	a3,0x5
ffffffffc0202ed4:	bb068693          	addi	a3,a3,-1104 # ffffffffc0207a80 <commands+0x1340>
ffffffffc0202ed8:	00004617          	auipc	a2,0x4
ffffffffc0202edc:	c7860613          	addi	a2,a2,-904 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202ee0:	10d00593          	li	a1,269
ffffffffc0202ee4:	00005517          	auipc	a0,0x5
ffffffffc0202ee8:	95c50513          	addi	a0,a0,-1700 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202eec:	b1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202ef0:	00005697          	auipc	a3,0x5
ffffffffc0202ef4:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207a70 <commands+0x1330>
ffffffffc0202ef8:	00004617          	auipc	a2,0x4
ffffffffc0202efc:	c5860613          	addi	a2,a2,-936 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202f00:	10800593          	li	a1,264
ffffffffc0202f04:	00005517          	auipc	a0,0x5
ffffffffc0202f08:	93c50513          	addi	a0,a0,-1732 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202f0c:	afcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f10:	00005697          	auipc	a3,0x5
ffffffffc0202f14:	a7068693          	addi	a3,a3,-1424 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202f18:	00004617          	auipc	a2,0x4
ffffffffc0202f1c:	c3860613          	addi	a2,a2,-968 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202f20:	10700593          	li	a1,263
ffffffffc0202f24:	00005517          	auipc	a0,0x5
ffffffffc0202f28:	91c50513          	addi	a0,a0,-1764 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202f2c:	adcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202f30:	00005697          	auipc	a3,0x5
ffffffffc0202f34:	b2068693          	addi	a3,a3,-1248 # ffffffffc0207a50 <commands+0x1310>
ffffffffc0202f38:	00004617          	auipc	a2,0x4
ffffffffc0202f3c:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202f40:	10600593          	li	a1,262
ffffffffc0202f44:	00005517          	auipc	a0,0x5
ffffffffc0202f48:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202f4c:	abcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202f50:	00005697          	auipc	a3,0x5
ffffffffc0202f54:	ad068693          	addi	a3,a3,-1328 # ffffffffc0207a20 <commands+0x12e0>
ffffffffc0202f58:	00004617          	auipc	a2,0x4
ffffffffc0202f5c:	bf860613          	addi	a2,a2,-1032 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202f60:	10500593          	li	a1,261
ffffffffc0202f64:	00005517          	auipc	a0,0x5
ffffffffc0202f68:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202f6c:	a9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202f70:	00005697          	auipc	a3,0x5
ffffffffc0202f74:	a9868693          	addi	a3,a3,-1384 # ffffffffc0207a08 <commands+0x12c8>
ffffffffc0202f78:	00004617          	auipc	a2,0x4
ffffffffc0202f7c:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202f80:	10400593          	li	a1,260
ffffffffc0202f84:	00005517          	auipc	a0,0x5
ffffffffc0202f88:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202f8c:	a7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f90:	00005697          	auipc	a3,0x5
ffffffffc0202f94:	9f068693          	addi	a3,a3,-1552 # ffffffffc0207980 <commands+0x1240>
ffffffffc0202f98:	00004617          	auipc	a2,0x4
ffffffffc0202f9c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202fa0:	0fe00593          	li	a1,254
ffffffffc0202fa4:	00005517          	auipc	a0,0x5
ffffffffc0202fa8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202fac:	a5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202fb0:	00005697          	auipc	a3,0x5
ffffffffc0202fb4:	a4068693          	addi	a3,a3,-1472 # ffffffffc02079f0 <commands+0x12b0>
ffffffffc0202fb8:	00004617          	auipc	a2,0x4
ffffffffc0202fbc:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202fc0:	0f900593          	li	a1,249
ffffffffc0202fc4:	00005517          	auipc	a0,0x5
ffffffffc0202fc8:	87c50513          	addi	a0,a0,-1924 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202fcc:	a3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202fd0:	00005697          	auipc	a3,0x5
ffffffffc0202fd4:	b4068693          	addi	a3,a3,-1216 # ffffffffc0207b10 <commands+0x13d0>
ffffffffc0202fd8:	00004617          	auipc	a2,0x4
ffffffffc0202fdc:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206b50 <commands+0x410>
ffffffffc0202fe0:	11700593          	li	a1,279
ffffffffc0202fe4:	00005517          	auipc	a0,0x5
ffffffffc0202fe8:	85c50513          	addi	a0,a0,-1956 # ffffffffc0207840 <commands+0x1100>
ffffffffc0202fec:	a1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc0202ff0:	00005697          	auipc	a3,0x5
ffffffffc0202ff4:	b5068693          	addi	a3,a3,-1200 # ffffffffc0207b40 <commands+0x1400>
ffffffffc0202ff8:	00004617          	auipc	a2,0x4
ffffffffc0202ffc:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203000:	12600593          	li	a1,294
ffffffffc0203004:	00005517          	auipc	a0,0x5
ffffffffc0203008:	83c50513          	addi	a0,a0,-1988 # ffffffffc0207840 <commands+0x1100>
ffffffffc020300c:	9fcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203010:	00004697          	auipc	a3,0x4
ffffffffc0203014:	2a068693          	addi	a3,a3,672 # ffffffffc02072b0 <commands+0xb70>
ffffffffc0203018:	00004617          	auipc	a2,0x4
ffffffffc020301c:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203020:	0f300593          	li	a1,243
ffffffffc0203024:	00005517          	auipc	a0,0x5
ffffffffc0203028:	81c50513          	addi	a0,a0,-2020 # ffffffffc0207840 <commands+0x1100>
ffffffffc020302c:	9dcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203030:	00005697          	auipc	a3,0x5
ffffffffc0203034:	84868693          	addi	a3,a3,-1976 # ffffffffc0207878 <commands+0x1138>
ffffffffc0203038:	00004617          	auipc	a2,0x4
ffffffffc020303c:	b1860613          	addi	a2,a2,-1256 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203040:	0ba00593          	li	a1,186
ffffffffc0203044:	00004517          	auipc	a0,0x4
ffffffffc0203048:	7fc50513          	addi	a0,a0,2044 # ffffffffc0207840 <commands+0x1100>
ffffffffc020304c:	9bcfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203050 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203050:	1141                	addi	sp,sp,-16
ffffffffc0203052:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203054:	14058463          	beqz	a1,ffffffffc020319c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203058:	00659693          	slli	a3,a1,0x6
ffffffffc020305c:	96aa                	add	a3,a3,a0
ffffffffc020305e:	87aa                	mv	a5,a0
ffffffffc0203060:	02d50263          	beq	a0,a3,ffffffffc0203084 <default_free_pages+0x34>
ffffffffc0203064:	6798                	ld	a4,8(a5)
ffffffffc0203066:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203068:	10071a63          	bnez	a4,ffffffffc020317c <default_free_pages+0x12c>
ffffffffc020306c:	6798                	ld	a4,8(a5)
ffffffffc020306e:	8b09                	andi	a4,a4,2
ffffffffc0203070:	10071663          	bnez	a4,ffffffffc020317c <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203074:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203078:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020307c:	04078793          	addi	a5,a5,64
ffffffffc0203080:	fed792e3          	bne	a5,a3,ffffffffc0203064 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203084:	2581                	sext.w	a1,a1
ffffffffc0203086:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203088:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020308c:	4789                	li	a5,2
ffffffffc020308e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203092:	000ab697          	auipc	a3,0xab
ffffffffc0203096:	73e68693          	addi	a3,a3,1854 # ffffffffc02ae7d0 <free_area>
ffffffffc020309a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020309c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020309e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02030a2:	9db9                	addw	a1,a1,a4
ffffffffc02030a4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02030a6:	0ad78463          	beq	a5,a3,ffffffffc020314e <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02030aa:	fe878713          	addi	a4,a5,-24
ffffffffc02030ae:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02030b2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02030b4:	00e56a63          	bltu	a0,a4,ffffffffc02030c8 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02030b8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02030ba:	04d70c63          	beq	a4,a3,ffffffffc0203112 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02030be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02030c0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02030c4:	fee57ae3          	bgeu	a0,a4,ffffffffc02030b8 <default_free_pages+0x68>
ffffffffc02030c8:	c199                	beqz	a1,ffffffffc02030ce <default_free_pages+0x7e>
ffffffffc02030ca:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02030ce:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02030d0:	e390                	sd	a2,0(a5)
ffffffffc02030d2:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02030d4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02030d6:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02030d8:	00d70d63          	beq	a4,a3,ffffffffc02030f2 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02030dc:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bc0>
        p = le2page(le, page_link);
ffffffffc02030e0:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02030e4:	02059813          	slli	a6,a1,0x20
ffffffffc02030e8:	01a85793          	srli	a5,a6,0x1a
ffffffffc02030ec:	97b2                	add	a5,a5,a2
ffffffffc02030ee:	02f50c63          	beq	a0,a5,ffffffffc0203126 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02030f2:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02030f4:	00d78c63          	beq	a5,a3,ffffffffc020310c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02030f8:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02030fa:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02030fe:	02061593          	slli	a1,a2,0x20
ffffffffc0203102:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203106:	972a                	add	a4,a4,a0
ffffffffc0203108:	04e68a63          	beq	a3,a4,ffffffffc020315c <default_free_pages+0x10c>
}
ffffffffc020310c:	60a2                	ld	ra,8(sp)
ffffffffc020310e:	0141                	addi	sp,sp,16
ffffffffc0203110:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203112:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203114:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203116:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203118:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020311a:	02d70763          	beq	a4,a3,ffffffffc0203148 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020311e:	8832                	mv	a6,a2
ffffffffc0203120:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203122:	87ba                	mv	a5,a4
ffffffffc0203124:	bf71                	j	ffffffffc02030c0 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203126:	491c                	lw	a5,16(a0)
ffffffffc0203128:	9dbd                	addw	a1,a1,a5
ffffffffc020312a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020312e:	57f5                	li	a5,-3
ffffffffc0203130:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203134:	01853803          	ld	a6,24(a0)
ffffffffc0203138:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020313a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020313c:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0203140:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203142:	0105b023          	sd	a6,0(a1)
ffffffffc0203146:	b77d                	j	ffffffffc02030f4 <default_free_pages+0xa4>
ffffffffc0203148:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020314a:	873e                	mv	a4,a5
ffffffffc020314c:	bf41                	j	ffffffffc02030dc <default_free_pages+0x8c>
}
ffffffffc020314e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203150:	e390                	sd	a2,0(a5)
ffffffffc0203152:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203154:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203156:	ed1c                	sd	a5,24(a0)
ffffffffc0203158:	0141                	addi	sp,sp,16
ffffffffc020315a:	8082                	ret
            base->property += p->property;
ffffffffc020315c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203160:	ff078693          	addi	a3,a5,-16
ffffffffc0203164:	9e39                	addw	a2,a2,a4
ffffffffc0203166:	c910                	sw	a2,16(a0)
ffffffffc0203168:	5775                	li	a4,-3
ffffffffc020316a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020316e:	6398                	ld	a4,0(a5)
ffffffffc0203170:	679c                	ld	a5,8(a5)
}
ffffffffc0203172:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203174:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203176:	e398                	sd	a4,0(a5)
ffffffffc0203178:	0141                	addi	sp,sp,16
ffffffffc020317a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020317c:	00005697          	auipc	a3,0x5
ffffffffc0203180:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0207b58 <commands+0x1418>
ffffffffc0203184:	00004617          	auipc	a2,0x4
ffffffffc0203188:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206b50 <commands+0x410>
ffffffffc020318c:	08300593          	li	a1,131
ffffffffc0203190:	00004517          	auipc	a0,0x4
ffffffffc0203194:	6b050513          	addi	a0,a0,1712 # ffffffffc0207840 <commands+0x1100>
ffffffffc0203198:	870fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020319c:	00005697          	auipc	a3,0x5
ffffffffc02031a0:	9b468693          	addi	a3,a3,-1612 # ffffffffc0207b50 <commands+0x1410>
ffffffffc02031a4:	00004617          	auipc	a2,0x4
ffffffffc02031a8:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206b50 <commands+0x410>
ffffffffc02031ac:	08000593          	li	a1,128
ffffffffc02031b0:	00004517          	auipc	a0,0x4
ffffffffc02031b4:	69050513          	addi	a0,a0,1680 # ffffffffc0207840 <commands+0x1100>
ffffffffc02031b8:	850fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02031bc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02031bc:	c941                	beqz	a0,ffffffffc020324c <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02031be:	000ab597          	auipc	a1,0xab
ffffffffc02031c2:	61258593          	addi	a1,a1,1554 # ffffffffc02ae7d0 <free_area>
ffffffffc02031c6:	0105a803          	lw	a6,16(a1)
ffffffffc02031ca:	872a                	mv	a4,a0
ffffffffc02031cc:	02081793          	slli	a5,a6,0x20
ffffffffc02031d0:	9381                	srli	a5,a5,0x20
ffffffffc02031d2:	00a7ee63          	bltu	a5,a0,ffffffffc02031ee <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02031d6:	87ae                	mv	a5,a1
ffffffffc02031d8:	a801                	j	ffffffffc02031e8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02031da:	ff87a683          	lw	a3,-8(a5)
ffffffffc02031de:	02069613          	slli	a2,a3,0x20
ffffffffc02031e2:	9201                	srli	a2,a2,0x20
ffffffffc02031e4:	00e67763          	bgeu	a2,a4,ffffffffc02031f2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02031e8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02031ea:	feb798e3          	bne	a5,a1,ffffffffc02031da <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02031ee:	4501                	li	a0,0
}
ffffffffc02031f0:	8082                	ret
    return listelm->prev;
ffffffffc02031f2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031f6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02031fa:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02031fe:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203202:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203206:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020320a:	02c77863          	bgeu	a4,a2,ffffffffc020323a <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020320e:	071a                	slli	a4,a4,0x6
ffffffffc0203210:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203212:	41c686bb          	subw	a3,a3,t3
ffffffffc0203216:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203218:	00870613          	addi	a2,a4,8
ffffffffc020321c:	4689                	li	a3,2
ffffffffc020321e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203222:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203226:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020322a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020322e:	e290                	sd	a2,0(a3)
ffffffffc0203230:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203234:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203236:	01173c23          	sd	a7,24(a4)
ffffffffc020323a:	41c8083b          	subw	a6,a6,t3
ffffffffc020323e:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203242:	5775                	li	a4,-3
ffffffffc0203244:	17c1                	addi	a5,a5,-16
ffffffffc0203246:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020324a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020324c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020324e:	00005697          	auipc	a3,0x5
ffffffffc0203252:	90268693          	addi	a3,a3,-1790 # ffffffffc0207b50 <commands+0x1410>
ffffffffc0203256:	00004617          	auipc	a2,0x4
ffffffffc020325a:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0206b50 <commands+0x410>
ffffffffc020325e:	06200593          	li	a1,98
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	5de50513          	addi	a0,a0,1502 # ffffffffc0207840 <commands+0x1100>
default_alloc_pages(size_t n) {
ffffffffc020326a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020326c:	f9dfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203270 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203270:	1141                	addi	sp,sp,-16
ffffffffc0203272:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203274:	c5f1                	beqz	a1,ffffffffc0203340 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203276:	00659693          	slli	a3,a1,0x6
ffffffffc020327a:	96aa                	add	a3,a3,a0
ffffffffc020327c:	87aa                	mv	a5,a0
ffffffffc020327e:	00d50f63          	beq	a0,a3,ffffffffc020329c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203282:	6798                	ld	a4,8(a5)
ffffffffc0203284:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203286:	cf49                	beqz	a4,ffffffffc0203320 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203288:	0007a823          	sw	zero,16(a5)
ffffffffc020328c:	0007b423          	sd	zero,8(a5)
ffffffffc0203290:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203294:	04078793          	addi	a5,a5,64
ffffffffc0203298:	fed795e3          	bne	a5,a3,ffffffffc0203282 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020329c:	2581                	sext.w	a1,a1
ffffffffc020329e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032a0:	4789                	li	a5,2
ffffffffc02032a2:	00850713          	addi	a4,a0,8
ffffffffc02032a6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02032aa:	000ab697          	auipc	a3,0xab
ffffffffc02032ae:	52668693          	addi	a3,a3,1318 # ffffffffc02ae7d0 <free_area>
ffffffffc02032b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02032b4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02032b6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02032ba:	9db9                	addw	a1,a1,a4
ffffffffc02032bc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02032be:	04d78a63          	beq	a5,a3,ffffffffc0203312 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02032c2:	fe878713          	addi	a4,a5,-24
ffffffffc02032c6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02032ca:	4581                	li	a1,0
            if (base < page) {
ffffffffc02032cc:	00e56a63          	bltu	a0,a4,ffffffffc02032e0 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02032d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02032d2:	02d70263          	beq	a4,a3,ffffffffc02032f6 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc02032d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02032d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02032dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02032d0 <default_init_memmap+0x60>
ffffffffc02032e0:	c199                	beqz	a1,ffffffffc02032e6 <default_init_memmap+0x76>
ffffffffc02032e2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02032e6:	6398                	ld	a4,0(a5)
}
ffffffffc02032e8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02032ea:	e390                	sd	a2,0(a5)
ffffffffc02032ec:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02032ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02032f0:	ed18                	sd	a4,24(a0)
ffffffffc02032f2:	0141                	addi	sp,sp,16
ffffffffc02032f4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02032f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02032f8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02032fa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02032fc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02032fe:	00d70663          	beq	a4,a3,ffffffffc020330a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0203302:	8832                	mv	a6,a2
ffffffffc0203304:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203306:	87ba                	mv	a5,a4
ffffffffc0203308:	bfc1                	j	ffffffffc02032d8 <default_init_memmap+0x68>
}
ffffffffc020330a:	60a2                	ld	ra,8(sp)
ffffffffc020330c:	e290                	sd	a2,0(a3)
ffffffffc020330e:	0141                	addi	sp,sp,16
ffffffffc0203310:	8082                	ret
ffffffffc0203312:	60a2                	ld	ra,8(sp)
ffffffffc0203314:	e390                	sd	a2,0(a5)
ffffffffc0203316:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203318:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020331a:	ed1c                	sd	a5,24(a0)
ffffffffc020331c:	0141                	addi	sp,sp,16
ffffffffc020331e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203320:	00005697          	auipc	a3,0x5
ffffffffc0203324:	86068693          	addi	a3,a3,-1952 # ffffffffc0207b80 <commands+0x1440>
ffffffffc0203328:	00004617          	auipc	a2,0x4
ffffffffc020332c:	82860613          	addi	a2,a2,-2008 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203330:	04900593          	li	a1,73
ffffffffc0203334:	00004517          	auipc	a0,0x4
ffffffffc0203338:	50c50513          	addi	a0,a0,1292 # ffffffffc0207840 <commands+0x1100>
ffffffffc020333c:	ecdfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0203340:	00005697          	auipc	a3,0x5
ffffffffc0203344:	81068693          	addi	a3,a3,-2032 # ffffffffc0207b50 <commands+0x1410>
ffffffffc0203348:	00004617          	auipc	a2,0x4
ffffffffc020334c:	80860613          	addi	a2,a2,-2040 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203350:	04600593          	li	a1,70
ffffffffc0203354:	00004517          	auipc	a0,0x4
ffffffffc0203358:	4ec50513          	addi	a0,a0,1260 # ffffffffc0207840 <commands+0x1100>
ffffffffc020335c:	eadfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203360 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203360:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203362:	00004617          	auipc	a2,0x4
ffffffffc0203366:	d8e60613          	addi	a2,a2,-626 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc020336a:	06200593          	li	a1,98
ffffffffc020336e:	00004517          	auipc	a0,0x4
ffffffffc0203372:	da250513          	addi	a0,a0,-606 # ffffffffc0207110 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc0203376:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203378:	e91fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020337c <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc020337c:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc020337e:	00004617          	auipc	a2,0x4
ffffffffc0203382:	0fa60613          	addi	a2,a2,250 # ffffffffc0207478 <commands+0xd38>
ffffffffc0203386:	07400593          	li	a1,116
ffffffffc020338a:	00004517          	auipc	a0,0x4
ffffffffc020338e:	d8650513          	addi	a0,a0,-634 # ffffffffc0207110 <commands+0x9d0>
pte2page(pte_t pte) {
ffffffffc0203392:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0203394:	e75fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203398 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203398:	7139                	addi	sp,sp,-64
ffffffffc020339a:	f426                	sd	s1,40(sp)
ffffffffc020339c:	f04a                	sd	s2,32(sp)
ffffffffc020339e:	ec4e                	sd	s3,24(sp)
ffffffffc02033a0:	e852                	sd	s4,16(sp)
ffffffffc02033a2:	e456                	sd	s5,8(sp)
ffffffffc02033a4:	e05a                	sd	s6,0(sp)
ffffffffc02033a6:	fc06                	sd	ra,56(sp)
ffffffffc02033a8:	f822                	sd	s0,48(sp)
ffffffffc02033aa:	84aa                	mv	s1,a0
ffffffffc02033ac:	000af917          	auipc	s2,0xaf
ffffffffc02033b0:	4b490913          	addi	s2,s2,1204 # ffffffffc02b2860 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02033b4:	4a05                	li	s4,1
ffffffffc02033b6:	000afa97          	auipc	s5,0xaf
ffffffffc02033ba:	47aa8a93          	addi	s5,s5,1146 # ffffffffc02b2830 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02033be:	0005099b          	sext.w	s3,a0
ffffffffc02033c2:	000afb17          	auipc	s6,0xaf
ffffffffc02033c6:	44eb0b13          	addi	s6,s6,1102 # ffffffffc02b2810 <check_mm_struct>
ffffffffc02033ca:	a01d                	j	ffffffffc02033f0 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc02033cc:	00093783          	ld	a5,0(s2)
ffffffffc02033d0:	6f9c                	ld	a5,24(a5)
ffffffffc02033d2:	9782                	jalr	a5
ffffffffc02033d4:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02033d6:	4601                	li	a2,0
ffffffffc02033d8:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02033da:	ec0d                	bnez	s0,ffffffffc0203414 <alloc_pages+0x7c>
ffffffffc02033dc:	029a6c63          	bltu	s4,s1,ffffffffc0203414 <alloc_pages+0x7c>
ffffffffc02033e0:	000aa783          	lw	a5,0(s5)
ffffffffc02033e4:	2781                	sext.w	a5,a5
ffffffffc02033e6:	c79d                	beqz	a5,ffffffffc0203414 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc02033e8:	000b3503          	ld	a0,0(s6)
ffffffffc02033ec:	bd9fe0ef          	jal	ra,ffffffffc0201fc4 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033f0:	100027f3          	csrr	a5,sstatus
ffffffffc02033f4:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02033f6:	8526                	mv	a0,s1
ffffffffc02033f8:	dbf1                	beqz	a5,ffffffffc02033cc <alloc_pages+0x34>
        intr_disable();
ffffffffc02033fa:	a2afd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02033fe:	00093783          	ld	a5,0(s2)
ffffffffc0203402:	8526                	mv	a0,s1
ffffffffc0203404:	6f9c                	ld	a5,24(a5)
ffffffffc0203406:	9782                	jalr	a5
ffffffffc0203408:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020340a:	a14fd0ef          	jal	ra,ffffffffc020061e <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc020340e:	4601                	li	a2,0
ffffffffc0203410:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203412:	d469                	beqz	s0,ffffffffc02033dc <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0203414:	70e2                	ld	ra,56(sp)
ffffffffc0203416:	8522                	mv	a0,s0
ffffffffc0203418:	7442                	ld	s0,48(sp)
ffffffffc020341a:	74a2                	ld	s1,40(sp)
ffffffffc020341c:	7902                	ld	s2,32(sp)
ffffffffc020341e:	69e2                	ld	s3,24(sp)
ffffffffc0203420:	6a42                	ld	s4,16(sp)
ffffffffc0203422:	6aa2                	ld	s5,8(sp)
ffffffffc0203424:	6b02                	ld	s6,0(sp)
ffffffffc0203426:	6121                	addi	sp,sp,64
ffffffffc0203428:	8082                	ret

ffffffffc020342a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020342a:	100027f3          	csrr	a5,sstatus
ffffffffc020342e:	8b89                	andi	a5,a5,2
ffffffffc0203430:	e799                	bnez	a5,ffffffffc020343e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203432:	000af797          	auipc	a5,0xaf
ffffffffc0203436:	42e7b783          	ld	a5,1070(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc020343a:	739c                	ld	a5,32(a5)
ffffffffc020343c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020343e:	1101                	addi	sp,sp,-32
ffffffffc0203440:	ec06                	sd	ra,24(sp)
ffffffffc0203442:	e822                	sd	s0,16(sp)
ffffffffc0203444:	e426                	sd	s1,8(sp)
ffffffffc0203446:	842a                	mv	s0,a0
ffffffffc0203448:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020344a:	9dafd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020344e:	000af797          	auipc	a5,0xaf
ffffffffc0203452:	4127b783          	ld	a5,1042(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203456:	739c                	ld	a5,32(a5)
ffffffffc0203458:	85a6                	mv	a1,s1
ffffffffc020345a:	8522                	mv	a0,s0
ffffffffc020345c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020345e:	6442                	ld	s0,16(sp)
ffffffffc0203460:	60e2                	ld	ra,24(sp)
ffffffffc0203462:	64a2                	ld	s1,8(sp)
ffffffffc0203464:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203466:	9b8fd06f          	j	ffffffffc020061e <intr_enable>

ffffffffc020346a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020346a:	100027f3          	csrr	a5,sstatus
ffffffffc020346e:	8b89                	andi	a5,a5,2
ffffffffc0203470:	e799                	bnez	a5,ffffffffc020347e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203472:	000af797          	auipc	a5,0xaf
ffffffffc0203476:	3ee7b783          	ld	a5,1006(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc020347a:	779c                	ld	a5,40(a5)
ffffffffc020347c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020347e:	1141                	addi	sp,sp,-16
ffffffffc0203480:	e406                	sd	ra,8(sp)
ffffffffc0203482:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203484:	9a0fd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203488:	000af797          	auipc	a5,0xaf
ffffffffc020348c:	3d87b783          	ld	a5,984(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203490:	779c                	ld	a5,40(a5)
ffffffffc0203492:	9782                	jalr	a5
ffffffffc0203494:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203496:	988fd0ef          	jal	ra,ffffffffc020061e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020349a:	60a2                	ld	ra,8(sp)
ffffffffc020349c:	8522                	mv	a0,s0
ffffffffc020349e:	6402                	ld	s0,0(sp)
ffffffffc02034a0:	0141                	addi	sp,sp,16
ffffffffc02034a2:	8082                	ret

ffffffffc02034a4 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02034a4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02034a8:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02034ac:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02034ae:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02034b0:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02034b2:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02034b6:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02034b8:	f04a                	sd	s2,32(sp)
ffffffffc02034ba:	ec4e                	sd	s3,24(sp)
ffffffffc02034bc:	e852                	sd	s4,16(sp)
ffffffffc02034be:	fc06                	sd	ra,56(sp)
ffffffffc02034c0:	f822                	sd	s0,48(sp)
ffffffffc02034c2:	e456                	sd	s5,8(sp)
ffffffffc02034c4:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02034c6:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02034ca:	892e                	mv	s2,a1
ffffffffc02034cc:	89b2                	mv	s3,a2
ffffffffc02034ce:	000afa17          	auipc	s4,0xaf
ffffffffc02034d2:	382a0a13          	addi	s4,s4,898 # ffffffffc02b2850 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02034d6:	e7b5                	bnez	a5,ffffffffc0203542 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02034d8:	12060b63          	beqz	a2,ffffffffc020360e <get_pte+0x16a>
ffffffffc02034dc:	4505                	li	a0,1
ffffffffc02034de:	ebbff0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02034e2:	842a                	mv	s0,a0
ffffffffc02034e4:	12050563          	beqz	a0,ffffffffc020360e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02034e8:	000afb17          	auipc	s6,0xaf
ffffffffc02034ec:	370b0b13          	addi	s6,s6,880 # ffffffffc02b2858 <pages>
ffffffffc02034f0:	000b3503          	ld	a0,0(s6)
ffffffffc02034f4:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02034f8:	000afa17          	auipc	s4,0xaf
ffffffffc02034fc:	358a0a13          	addi	s4,s4,856 # ffffffffc02b2850 <npage>
ffffffffc0203500:	40a40533          	sub	a0,s0,a0
ffffffffc0203504:	8519                	srai	a0,a0,0x6
ffffffffc0203506:	9556                	add	a0,a0,s5
ffffffffc0203508:	000a3703          	ld	a4,0(s4)
ffffffffc020350c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203510:	4685                	li	a3,1
ffffffffc0203512:	c014                	sw	a3,0(s0)
ffffffffc0203514:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203516:	0532                	slli	a0,a0,0xc
ffffffffc0203518:	14e7f263          	bgeu	a5,a4,ffffffffc020365c <get_pte+0x1b8>
ffffffffc020351c:	000af797          	auipc	a5,0xaf
ffffffffc0203520:	34c7b783          	ld	a5,844(a5) # ffffffffc02b2868 <va_pa_offset>
ffffffffc0203524:	6605                	lui	a2,0x1
ffffffffc0203526:	4581                	li	a1,0
ffffffffc0203528:	953e                	add	a0,a0,a5
ffffffffc020352a:	33f020ef          	jal	ra,ffffffffc0206068 <memset>
    return page - pages + nbase;
ffffffffc020352e:	000b3683          	ld	a3,0(s6)
ffffffffc0203532:	40d406b3          	sub	a3,s0,a3
ffffffffc0203536:	8699                	srai	a3,a3,0x6
ffffffffc0203538:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020353a:	06aa                	slli	a3,a3,0xa
ffffffffc020353c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203540:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203542:	77fd                	lui	a5,0xfffff
ffffffffc0203544:	068a                	slli	a3,a3,0x2
ffffffffc0203546:	000a3703          	ld	a4,0(s4)
ffffffffc020354a:	8efd                	and	a3,a3,a5
ffffffffc020354c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203550:	0ce7f163          	bgeu	a5,a4,ffffffffc0203612 <get_pte+0x16e>
ffffffffc0203554:	000afa97          	auipc	s5,0xaf
ffffffffc0203558:	314a8a93          	addi	s5,s5,788 # ffffffffc02b2868 <va_pa_offset>
ffffffffc020355c:	000ab403          	ld	s0,0(s5)
ffffffffc0203560:	01595793          	srli	a5,s2,0x15
ffffffffc0203564:	1ff7f793          	andi	a5,a5,511
ffffffffc0203568:	96a2                	add	a3,a3,s0
ffffffffc020356a:	00379413          	slli	s0,a5,0x3
ffffffffc020356e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0203570:	6014                	ld	a3,0(s0)
ffffffffc0203572:	0016f793          	andi	a5,a3,1
ffffffffc0203576:	e3ad                	bnez	a5,ffffffffc02035d8 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203578:	08098b63          	beqz	s3,ffffffffc020360e <get_pte+0x16a>
ffffffffc020357c:	4505                	li	a0,1
ffffffffc020357e:	e1bff0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0203582:	84aa                	mv	s1,a0
ffffffffc0203584:	c549                	beqz	a0,ffffffffc020360e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203586:	000afb17          	auipc	s6,0xaf
ffffffffc020358a:	2d2b0b13          	addi	s6,s6,722 # ffffffffc02b2858 <pages>
ffffffffc020358e:	000b3503          	ld	a0,0(s6)
ffffffffc0203592:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203596:	000a3703          	ld	a4,0(s4)
ffffffffc020359a:	40a48533          	sub	a0,s1,a0
ffffffffc020359e:	8519                	srai	a0,a0,0x6
ffffffffc02035a0:	954e                	add	a0,a0,s3
ffffffffc02035a2:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02035a6:	4685                	li	a3,1
ffffffffc02035a8:	c094                	sw	a3,0(s1)
ffffffffc02035aa:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02035ac:	0532                	slli	a0,a0,0xc
ffffffffc02035ae:	08e7fa63          	bgeu	a5,a4,ffffffffc0203642 <get_pte+0x19e>
ffffffffc02035b2:	000ab783          	ld	a5,0(s5)
ffffffffc02035b6:	6605                	lui	a2,0x1
ffffffffc02035b8:	4581                	li	a1,0
ffffffffc02035ba:	953e                	add	a0,a0,a5
ffffffffc02035bc:	2ad020ef          	jal	ra,ffffffffc0206068 <memset>
    return page - pages + nbase;
ffffffffc02035c0:	000b3683          	ld	a3,0(s6)
ffffffffc02035c4:	40d486b3          	sub	a3,s1,a3
ffffffffc02035c8:	8699                	srai	a3,a3,0x6
ffffffffc02035ca:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02035cc:	06aa                	slli	a3,a3,0xa
ffffffffc02035ce:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02035d2:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02035d4:	000a3703          	ld	a4,0(s4)
ffffffffc02035d8:	068a                	slli	a3,a3,0x2
ffffffffc02035da:	757d                	lui	a0,0xfffff
ffffffffc02035dc:	8ee9                	and	a3,a3,a0
ffffffffc02035de:	00c6d793          	srli	a5,a3,0xc
ffffffffc02035e2:	04e7f463          	bgeu	a5,a4,ffffffffc020362a <get_pte+0x186>
ffffffffc02035e6:	000ab503          	ld	a0,0(s5)
ffffffffc02035ea:	00c95913          	srli	s2,s2,0xc
ffffffffc02035ee:	1ff97913          	andi	s2,s2,511
ffffffffc02035f2:	96aa                	add	a3,a3,a0
ffffffffc02035f4:	00391513          	slli	a0,s2,0x3
ffffffffc02035f8:	9536                	add	a0,a0,a3
}
ffffffffc02035fa:	70e2                	ld	ra,56(sp)
ffffffffc02035fc:	7442                	ld	s0,48(sp)
ffffffffc02035fe:	74a2                	ld	s1,40(sp)
ffffffffc0203600:	7902                	ld	s2,32(sp)
ffffffffc0203602:	69e2                	ld	s3,24(sp)
ffffffffc0203604:	6a42                	ld	s4,16(sp)
ffffffffc0203606:	6aa2                	ld	s5,8(sp)
ffffffffc0203608:	6b02                	ld	s6,0(sp)
ffffffffc020360a:	6121                	addi	sp,sp,64
ffffffffc020360c:	8082                	ret
            return NULL;
ffffffffc020360e:	4501                	li	a0,0
ffffffffc0203610:	b7ed                	j	ffffffffc02035fa <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203612:	00004617          	auipc	a2,0x4
ffffffffc0203616:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0207120 <commands+0x9e0>
ffffffffc020361a:	0e300593          	li	a1,227
ffffffffc020361e:	00004517          	auipc	a0,0x4
ffffffffc0203622:	5c250513          	addi	a0,a0,1474 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203626:	be3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020362a:	00004617          	auipc	a2,0x4
ffffffffc020362e:	af660613          	addi	a2,a2,-1290 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0203632:	0ee00593          	li	a1,238
ffffffffc0203636:	00004517          	auipc	a0,0x4
ffffffffc020363a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020363e:	bcbfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203642:	86aa                	mv	a3,a0
ffffffffc0203644:	00004617          	auipc	a2,0x4
ffffffffc0203648:	adc60613          	addi	a2,a2,-1316 # ffffffffc0207120 <commands+0x9e0>
ffffffffc020364c:	0eb00593          	li	a1,235
ffffffffc0203650:	00004517          	auipc	a0,0x4
ffffffffc0203654:	59050513          	addi	a0,a0,1424 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203658:	bb1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020365c:	86aa                	mv	a3,a0
ffffffffc020365e:	00004617          	auipc	a2,0x4
ffffffffc0203662:	ac260613          	addi	a2,a2,-1342 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0203666:	0df00593          	li	a1,223
ffffffffc020366a:	00004517          	auipc	a0,0x4
ffffffffc020366e:	57650513          	addi	a0,a0,1398 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203672:	b97fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203676 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203676:	1141                	addi	sp,sp,-16
ffffffffc0203678:	e022                	sd	s0,0(sp)
ffffffffc020367a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020367c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020367e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203680:	e25ff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203684:	c011                	beqz	s0,ffffffffc0203688 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203686:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203688:	c511                	beqz	a0,ffffffffc0203694 <get_page+0x1e>
ffffffffc020368a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020368c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020368e:	0017f713          	andi	a4,a5,1
ffffffffc0203692:	e709                	bnez	a4,ffffffffc020369c <get_page+0x26>
}
ffffffffc0203694:	60a2                	ld	ra,8(sp)
ffffffffc0203696:	6402                	ld	s0,0(sp)
ffffffffc0203698:	0141                	addi	sp,sp,16
ffffffffc020369a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020369c:	078a                	slli	a5,a5,0x2
ffffffffc020369e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036a0:	000af717          	auipc	a4,0xaf
ffffffffc02036a4:	1b073703          	ld	a4,432(a4) # ffffffffc02b2850 <npage>
ffffffffc02036a8:	00e7ff63          	bgeu	a5,a4,ffffffffc02036c6 <get_page+0x50>
ffffffffc02036ac:	60a2                	ld	ra,8(sp)
ffffffffc02036ae:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02036b0:	fff80537          	lui	a0,0xfff80
ffffffffc02036b4:	97aa                	add	a5,a5,a0
ffffffffc02036b6:	079a                	slli	a5,a5,0x6
ffffffffc02036b8:	000af517          	auipc	a0,0xaf
ffffffffc02036bc:	1a053503          	ld	a0,416(a0) # ffffffffc02b2858 <pages>
ffffffffc02036c0:	953e                	add	a0,a0,a5
ffffffffc02036c2:	0141                	addi	sp,sp,16
ffffffffc02036c4:	8082                	ret
ffffffffc02036c6:	c9bff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>

ffffffffc02036ca <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02036ca:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02036cc:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02036d0:	f486                	sd	ra,104(sp)
ffffffffc02036d2:	f0a2                	sd	s0,96(sp)
ffffffffc02036d4:	eca6                	sd	s1,88(sp)
ffffffffc02036d6:	e8ca                	sd	s2,80(sp)
ffffffffc02036d8:	e4ce                	sd	s3,72(sp)
ffffffffc02036da:	e0d2                	sd	s4,64(sp)
ffffffffc02036dc:	fc56                	sd	s5,56(sp)
ffffffffc02036de:	f85a                	sd	s6,48(sp)
ffffffffc02036e0:	f45e                	sd	s7,40(sp)
ffffffffc02036e2:	f062                	sd	s8,32(sp)
ffffffffc02036e4:	ec66                	sd	s9,24(sp)
ffffffffc02036e6:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02036e8:	17d2                	slli	a5,a5,0x34
ffffffffc02036ea:	e3ed                	bnez	a5,ffffffffc02037cc <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02036ec:	002007b7          	lui	a5,0x200
ffffffffc02036f0:	842e                	mv	s0,a1
ffffffffc02036f2:	0ef5ed63          	bltu	a1,a5,ffffffffc02037ec <unmap_range+0x122>
ffffffffc02036f6:	8932                	mv	s2,a2
ffffffffc02036f8:	0ec5fa63          	bgeu	a1,a2,ffffffffc02037ec <unmap_range+0x122>
ffffffffc02036fc:	4785                	li	a5,1
ffffffffc02036fe:	07fe                	slli	a5,a5,0x1f
ffffffffc0203700:	0ec7e663          	bltu	a5,a2,ffffffffc02037ec <unmap_range+0x122>
ffffffffc0203704:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203706:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203708:	000afc97          	auipc	s9,0xaf
ffffffffc020370c:	148c8c93          	addi	s9,s9,328 # ffffffffc02b2850 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203710:	000afc17          	auipc	s8,0xaf
ffffffffc0203714:	148c0c13          	addi	s8,s8,328 # ffffffffc02b2858 <pages>
ffffffffc0203718:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020371c:	000afd17          	auipc	s10,0xaf
ffffffffc0203720:	144d0d13          	addi	s10,s10,324 # ffffffffc02b2860 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203724:	00200b37          	lui	s6,0x200
ffffffffc0203728:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020372c:	4601                	li	a2,0
ffffffffc020372e:	85a2                	mv	a1,s0
ffffffffc0203730:	854e                	mv	a0,s3
ffffffffc0203732:	d73ff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0203736:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203738:	cd29                	beqz	a0,ffffffffc0203792 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc020373a:	611c                	ld	a5,0(a0)
ffffffffc020373c:	e395                	bnez	a5,ffffffffc0203760 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020373e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203740:	ff2466e3          	bltu	s0,s2,ffffffffc020372c <unmap_range+0x62>
}
ffffffffc0203744:	70a6                	ld	ra,104(sp)
ffffffffc0203746:	7406                	ld	s0,96(sp)
ffffffffc0203748:	64e6                	ld	s1,88(sp)
ffffffffc020374a:	6946                	ld	s2,80(sp)
ffffffffc020374c:	69a6                	ld	s3,72(sp)
ffffffffc020374e:	6a06                	ld	s4,64(sp)
ffffffffc0203750:	7ae2                	ld	s5,56(sp)
ffffffffc0203752:	7b42                	ld	s6,48(sp)
ffffffffc0203754:	7ba2                	ld	s7,40(sp)
ffffffffc0203756:	7c02                	ld	s8,32(sp)
ffffffffc0203758:	6ce2                	ld	s9,24(sp)
ffffffffc020375a:	6d42                	ld	s10,16(sp)
ffffffffc020375c:	6165                	addi	sp,sp,112
ffffffffc020375e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203760:	0017f713          	andi	a4,a5,1
ffffffffc0203764:	df69                	beqz	a4,ffffffffc020373e <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203766:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020376a:	078a                	slli	a5,a5,0x2
ffffffffc020376c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020376e:	08e7ff63          	bgeu	a5,a4,ffffffffc020380c <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203772:	000c3503          	ld	a0,0(s8)
ffffffffc0203776:	97de                	add	a5,a5,s7
ffffffffc0203778:	079a                	slli	a5,a5,0x6
ffffffffc020377a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020377c:	411c                	lw	a5,0(a0)
ffffffffc020377e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203782:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203784:	cf11                	beqz	a4,ffffffffc02037a0 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203786:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020378a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020378e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203790:	bf45                	j	ffffffffc0203740 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203792:	945a                	add	s0,s0,s6
ffffffffc0203794:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203798:	d455                	beqz	s0,ffffffffc0203744 <unmap_range+0x7a>
ffffffffc020379a:	f92469e3          	bltu	s0,s2,ffffffffc020372c <unmap_range+0x62>
ffffffffc020379e:	b75d                	j	ffffffffc0203744 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037a0:	100027f3          	csrr	a5,sstatus
ffffffffc02037a4:	8b89                	andi	a5,a5,2
ffffffffc02037a6:	e799                	bnez	a5,ffffffffc02037b4 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02037a8:	000d3783          	ld	a5,0(s10)
ffffffffc02037ac:	4585                	li	a1,1
ffffffffc02037ae:	739c                	ld	a5,32(a5)
ffffffffc02037b0:	9782                	jalr	a5
    if (flag) {
ffffffffc02037b2:	bfd1                	j	ffffffffc0203786 <unmap_range+0xbc>
ffffffffc02037b4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02037b6:	e6ffc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02037ba:	000d3783          	ld	a5,0(s10)
ffffffffc02037be:	6522                	ld	a0,8(sp)
ffffffffc02037c0:	4585                	li	a1,1
ffffffffc02037c2:	739c                	ld	a5,32(a5)
ffffffffc02037c4:	9782                	jalr	a5
        intr_enable();
ffffffffc02037c6:	e59fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02037ca:	bf75                	j	ffffffffc0203786 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02037cc:	00004697          	auipc	a3,0x4
ffffffffc02037d0:	42468693          	addi	a3,a3,1060 # ffffffffc0207bf0 <default_pmm_manager+0x48>
ffffffffc02037d4:	00003617          	auipc	a2,0x3
ffffffffc02037d8:	37c60613          	addi	a2,a2,892 # ffffffffc0206b50 <commands+0x410>
ffffffffc02037dc:	10f00593          	li	a1,271
ffffffffc02037e0:	00004517          	auipc	a0,0x4
ffffffffc02037e4:	40050513          	addi	a0,a0,1024 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02037e8:	a21fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02037ec:	00004697          	auipc	a3,0x4
ffffffffc02037f0:	43468693          	addi	a3,a3,1076 # ffffffffc0207c20 <default_pmm_manager+0x78>
ffffffffc02037f4:	00003617          	auipc	a2,0x3
ffffffffc02037f8:	35c60613          	addi	a2,a2,860 # ffffffffc0206b50 <commands+0x410>
ffffffffc02037fc:	11000593          	li	a1,272
ffffffffc0203800:	00004517          	auipc	a0,0x4
ffffffffc0203804:	3e050513          	addi	a0,a0,992 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203808:	a01fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020380c:	b55ff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>

ffffffffc0203810 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203810:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203812:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203816:	fc86                	sd	ra,120(sp)
ffffffffc0203818:	f8a2                	sd	s0,112(sp)
ffffffffc020381a:	f4a6                	sd	s1,104(sp)
ffffffffc020381c:	f0ca                	sd	s2,96(sp)
ffffffffc020381e:	ecce                	sd	s3,88(sp)
ffffffffc0203820:	e8d2                	sd	s4,80(sp)
ffffffffc0203822:	e4d6                	sd	s5,72(sp)
ffffffffc0203824:	e0da                	sd	s6,64(sp)
ffffffffc0203826:	fc5e                	sd	s7,56(sp)
ffffffffc0203828:	f862                	sd	s8,48(sp)
ffffffffc020382a:	f466                	sd	s9,40(sp)
ffffffffc020382c:	f06a                	sd	s10,32(sp)
ffffffffc020382e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203830:	17d2                	slli	a5,a5,0x34
ffffffffc0203832:	20079a63          	bnez	a5,ffffffffc0203a46 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0203836:	002007b7          	lui	a5,0x200
ffffffffc020383a:	24f5e463          	bltu	a1,a5,ffffffffc0203a82 <exit_range+0x272>
ffffffffc020383e:	8ab2                	mv	s5,a2
ffffffffc0203840:	24c5f163          	bgeu	a1,a2,ffffffffc0203a82 <exit_range+0x272>
ffffffffc0203844:	4785                	li	a5,1
ffffffffc0203846:	07fe                	slli	a5,a5,0x1f
ffffffffc0203848:	22c7ed63          	bltu	a5,a2,ffffffffc0203a82 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020384c:	c00009b7          	lui	s3,0xc0000
ffffffffc0203850:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203854:	ffe00937          	lui	s2,0xffe00
ffffffffc0203858:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020385c:	5cfd                	li	s9,-1
ffffffffc020385e:	8c2a                	mv	s8,a0
ffffffffc0203860:	0125f933          	and	s2,a1,s2
ffffffffc0203864:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203866:	000afd17          	auipc	s10,0xaf
ffffffffc020386a:	fead0d13          	addi	s10,s10,-22 # ffffffffc02b2850 <npage>
    return KADDR(page2pa(page));
ffffffffc020386e:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203872:	000af717          	auipc	a4,0xaf
ffffffffc0203876:	fe670713          	addi	a4,a4,-26 # ffffffffc02b2858 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020387a:	000afd97          	auipc	s11,0xaf
ffffffffc020387e:	fe6d8d93          	addi	s11,s11,-26 # ffffffffc02b2860 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203882:	c0000437          	lui	s0,0xc0000
ffffffffc0203886:	944e                	add	s0,s0,s3
ffffffffc0203888:	8079                	srli	s0,s0,0x1e
ffffffffc020388a:	1ff47413          	andi	s0,s0,511
ffffffffc020388e:	040e                	slli	s0,s0,0x3
ffffffffc0203890:	9462                	add	s0,s0,s8
ffffffffc0203892:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1&PTE_V){
ffffffffc0203896:	001a7793          	andi	a5,s4,1
ffffffffc020389a:	eb99                	bnez	a5,ffffffffc02038b0 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020389c:	12098463          	beqz	s3,ffffffffc02039c4 <exit_range+0x1b4>
ffffffffc02038a0:	400007b7          	lui	a5,0x40000
ffffffffc02038a4:	97ce                	add	a5,a5,s3
ffffffffc02038a6:	894e                	mv	s2,s3
ffffffffc02038a8:	1159fe63          	bgeu	s3,s5,ffffffffc02039c4 <exit_range+0x1b4>
ffffffffc02038ac:	89be                	mv	s3,a5
ffffffffc02038ae:	bfd1                	j	ffffffffc0203882 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02038b0:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02038b4:	0a0a                	slli	s4,s4,0x2
ffffffffc02038b6:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038ba:	1cfa7263          	bgeu	s4,a5,ffffffffc0203a7e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02038be:	fff80637          	lui	a2,0xfff80
ffffffffc02038c2:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02038c4:	000806b7          	lui	a3,0x80
ffffffffc02038c8:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02038ca:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02038ce:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02038d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02038d2:	18f5fa63          	bgeu	a1,a5,ffffffffc0203a66 <exit_range+0x256>
ffffffffc02038d6:	000af817          	auipc	a6,0xaf
ffffffffc02038da:	f9280813          	addi	a6,a6,-110 # ffffffffc02b2868 <va_pa_offset>
ffffffffc02038de:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02038e2:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02038e4:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02038e8:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02038ea:	00080337          	lui	t1,0x80
ffffffffc02038ee:	6885                	lui	a7,0x1
ffffffffc02038f0:	a819                	j	ffffffffc0203906 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02038f2:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02038f4:	002007b7          	lui	a5,0x200
ffffffffc02038f8:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02038fa:	08090c63          	beqz	s2,ffffffffc0203992 <exit_range+0x182>
ffffffffc02038fe:	09397a63          	bgeu	s2,s3,ffffffffc0203992 <exit_range+0x182>
ffffffffc0203902:	0f597063          	bgeu	s2,s5,ffffffffc02039e2 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203906:	01595493          	srli	s1,s2,0x15
ffffffffc020390a:	1ff4f493          	andi	s1,s1,511
ffffffffc020390e:	048e                	slli	s1,s1,0x3
ffffffffc0203910:	94da                	add	s1,s1,s6
ffffffffc0203912:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0203914:	0017f693          	andi	a3,a5,1
ffffffffc0203918:	dee9                	beqz	a3,ffffffffc02038f2 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc020391a:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020391e:	078a                	slli	a5,a5,0x2
ffffffffc0203920:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203922:	14b7fe63          	bgeu	a5,a1,ffffffffc0203a7e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203926:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0203928:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc020392c:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203930:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203934:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203936:	12bef863          	bgeu	t4,a1,ffffffffc0203a66 <exit_range+0x256>
ffffffffc020393a:	00083783          	ld	a5,0(a6)
ffffffffc020393e:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203940:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0203944:	629c                	ld	a5,0(a3)
ffffffffc0203946:	8b85                	andi	a5,a5,1
ffffffffc0203948:	f7d5                	bnez	a5,ffffffffc02038f4 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020394a:	06a1                	addi	a3,a3,8
ffffffffc020394c:	fed59ce3          	bne	a1,a3,ffffffffc0203944 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0203950:	631c                	ld	a5,0(a4)
ffffffffc0203952:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203954:	100027f3          	csrr	a5,sstatus
ffffffffc0203958:	8b89                	andi	a5,a5,2
ffffffffc020395a:	e7d9                	bnez	a5,ffffffffc02039e8 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020395c:	000db783          	ld	a5,0(s11)
ffffffffc0203960:	4585                	li	a1,1
ffffffffc0203962:	e032                	sd	a2,0(sp)
ffffffffc0203964:	739c                	ld	a5,32(a5)
ffffffffc0203966:	9782                	jalr	a5
    if (flag) {
ffffffffc0203968:	6602                	ld	a2,0(sp)
ffffffffc020396a:	000af817          	auipc	a6,0xaf
ffffffffc020396e:	efe80813          	addi	a6,a6,-258 # ffffffffc02b2868 <va_pa_offset>
ffffffffc0203972:	fff80e37          	lui	t3,0xfff80
ffffffffc0203976:	00080337          	lui	t1,0x80
ffffffffc020397a:	6885                	lui	a7,0x1
ffffffffc020397c:	000af717          	auipc	a4,0xaf
ffffffffc0203980:	edc70713          	addi	a4,a4,-292 # ffffffffc02b2858 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203984:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203988:	002007b7          	lui	a5,0x200
ffffffffc020398c:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020398e:	f60918e3          	bnez	s2,ffffffffc02038fe <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203992:	f00b85e3          	beqz	s7,ffffffffc020389c <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203996:	000d3783          	ld	a5,0(s10)
ffffffffc020399a:	0efa7263          	bgeu	s4,a5,ffffffffc0203a7e <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020399e:	6308                	ld	a0,0(a4)
ffffffffc02039a0:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02039a2:	100027f3          	csrr	a5,sstatus
ffffffffc02039a6:	8b89                	andi	a5,a5,2
ffffffffc02039a8:	efad                	bnez	a5,ffffffffc0203a22 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02039aa:	000db783          	ld	a5,0(s11)
ffffffffc02039ae:	4585                	li	a1,1
ffffffffc02039b0:	739c                	ld	a5,32(a5)
ffffffffc02039b2:	9782                	jalr	a5
ffffffffc02039b4:	000af717          	auipc	a4,0xaf
ffffffffc02039b8:	ea470713          	addi	a4,a4,-348 # ffffffffc02b2858 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02039bc:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02039c0:	ee0990e3          	bnez	s3,ffffffffc02038a0 <exit_range+0x90>
}
ffffffffc02039c4:	70e6                	ld	ra,120(sp)
ffffffffc02039c6:	7446                	ld	s0,112(sp)
ffffffffc02039c8:	74a6                	ld	s1,104(sp)
ffffffffc02039ca:	7906                	ld	s2,96(sp)
ffffffffc02039cc:	69e6                	ld	s3,88(sp)
ffffffffc02039ce:	6a46                	ld	s4,80(sp)
ffffffffc02039d0:	6aa6                	ld	s5,72(sp)
ffffffffc02039d2:	6b06                	ld	s6,64(sp)
ffffffffc02039d4:	7be2                	ld	s7,56(sp)
ffffffffc02039d6:	7c42                	ld	s8,48(sp)
ffffffffc02039d8:	7ca2                	ld	s9,40(sp)
ffffffffc02039da:	7d02                	ld	s10,32(sp)
ffffffffc02039dc:	6de2                	ld	s11,24(sp)
ffffffffc02039de:	6109                	addi	sp,sp,128
ffffffffc02039e0:	8082                	ret
            if (free_pd0) {
ffffffffc02039e2:	ea0b8fe3          	beqz	s7,ffffffffc02038a0 <exit_range+0x90>
ffffffffc02039e6:	bf45                	j	ffffffffc0203996 <exit_range+0x186>
ffffffffc02039e8:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02039ea:	e42a                	sd	a0,8(sp)
ffffffffc02039ec:	c39fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02039f0:	000db783          	ld	a5,0(s11)
ffffffffc02039f4:	6522                	ld	a0,8(sp)
ffffffffc02039f6:	4585                	li	a1,1
ffffffffc02039f8:	739c                	ld	a5,32(a5)
ffffffffc02039fa:	9782                	jalr	a5
        intr_enable();
ffffffffc02039fc:	c23fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203a00:	6602                	ld	a2,0(sp)
ffffffffc0203a02:	000af717          	auipc	a4,0xaf
ffffffffc0203a06:	e5670713          	addi	a4,a4,-426 # ffffffffc02b2858 <pages>
ffffffffc0203a0a:	6885                	lui	a7,0x1
ffffffffc0203a0c:	00080337          	lui	t1,0x80
ffffffffc0203a10:	fff80e37          	lui	t3,0xfff80
ffffffffc0203a14:	000af817          	auipc	a6,0xaf
ffffffffc0203a18:	e5480813          	addi	a6,a6,-428 # ffffffffc02b2868 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203a1c:	0004b023          	sd	zero,0(s1)
ffffffffc0203a20:	b7a5                	j	ffffffffc0203988 <exit_range+0x178>
ffffffffc0203a22:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203a24:	c01fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203a28:	000db783          	ld	a5,0(s11)
ffffffffc0203a2c:	6502                	ld	a0,0(sp)
ffffffffc0203a2e:	4585                	li	a1,1
ffffffffc0203a30:	739c                	ld	a5,32(a5)
ffffffffc0203a32:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a34:	bebfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203a38:	000af717          	auipc	a4,0xaf
ffffffffc0203a3c:	e2070713          	addi	a4,a4,-480 # ffffffffc02b2858 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203a40:	00043023          	sd	zero,0(s0)
ffffffffc0203a44:	bfb5                	j	ffffffffc02039c0 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a46:	00004697          	auipc	a3,0x4
ffffffffc0203a4a:	1aa68693          	addi	a3,a3,426 # ffffffffc0207bf0 <default_pmm_manager+0x48>
ffffffffc0203a4e:	00003617          	auipc	a2,0x3
ffffffffc0203a52:	10260613          	addi	a2,a2,258 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203a56:	12000593          	li	a1,288
ffffffffc0203a5a:	00004517          	auipc	a0,0x4
ffffffffc0203a5e:	18650513          	addi	a0,a0,390 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203a62:	fa6fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a66:	00003617          	auipc	a2,0x3
ffffffffc0203a6a:	6ba60613          	addi	a2,a2,1722 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0203a6e:	06900593          	li	a1,105
ffffffffc0203a72:	00003517          	auipc	a0,0x3
ffffffffc0203a76:	69e50513          	addi	a0,a0,1694 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0203a7a:	f8efc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203a7e:	8e3ff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203a82:	00004697          	auipc	a3,0x4
ffffffffc0203a86:	19e68693          	addi	a3,a3,414 # ffffffffc0207c20 <default_pmm_manager+0x78>
ffffffffc0203a8a:	00003617          	auipc	a2,0x3
ffffffffc0203a8e:	0c660613          	addi	a2,a2,198 # ffffffffc0206b50 <commands+0x410>
ffffffffc0203a92:	12100593          	li	a1,289
ffffffffc0203a96:	00004517          	auipc	a0,0x4
ffffffffc0203a9a:	14a50513          	addi	a0,a0,330 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0203a9e:	f6afc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203aa2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203aa2:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203aa4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203aa6:	ec26                	sd	s1,24(sp)
ffffffffc0203aa8:	f406                	sd	ra,40(sp)
ffffffffc0203aaa:	f022                	sd	s0,32(sp)
ffffffffc0203aac:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203aae:	9f7ff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
    if (ptep != NULL) {
ffffffffc0203ab2:	c511                	beqz	a0,ffffffffc0203abe <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203ab4:	611c                	ld	a5,0(a0)
ffffffffc0203ab6:	842a                	mv	s0,a0
ffffffffc0203ab8:	0017f713          	andi	a4,a5,1
ffffffffc0203abc:	e711                	bnez	a4,ffffffffc0203ac8 <page_remove+0x26>
}
ffffffffc0203abe:	70a2                	ld	ra,40(sp)
ffffffffc0203ac0:	7402                	ld	s0,32(sp)
ffffffffc0203ac2:	64e2                	ld	s1,24(sp)
ffffffffc0203ac4:	6145                	addi	sp,sp,48
ffffffffc0203ac6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ac8:	078a                	slli	a5,a5,0x2
ffffffffc0203aca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203acc:	000af717          	auipc	a4,0xaf
ffffffffc0203ad0:	d8473703          	ld	a4,-636(a4) # ffffffffc02b2850 <npage>
ffffffffc0203ad4:	06e7f363          	bgeu	a5,a4,ffffffffc0203b3a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ad8:	fff80537          	lui	a0,0xfff80
ffffffffc0203adc:	97aa                	add	a5,a5,a0
ffffffffc0203ade:	079a                	slli	a5,a5,0x6
ffffffffc0203ae0:	000af517          	auipc	a0,0xaf
ffffffffc0203ae4:	d7853503          	ld	a0,-648(a0) # ffffffffc02b2858 <pages>
ffffffffc0203ae8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203aea:	411c                	lw	a5,0(a0)
ffffffffc0203aec:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203af0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203af2:	cb11                	beqz	a4,ffffffffc0203b06 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203af4:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203af8:	12048073          	sfence.vma	s1
}
ffffffffc0203afc:	70a2                	ld	ra,40(sp)
ffffffffc0203afe:	7402                	ld	s0,32(sp)
ffffffffc0203b00:	64e2                	ld	s1,24(sp)
ffffffffc0203b02:	6145                	addi	sp,sp,48
ffffffffc0203b04:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b06:	100027f3          	csrr	a5,sstatus
ffffffffc0203b0a:	8b89                	andi	a5,a5,2
ffffffffc0203b0c:	eb89                	bnez	a5,ffffffffc0203b1e <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203b0e:	000af797          	auipc	a5,0xaf
ffffffffc0203b12:	d527b783          	ld	a5,-686(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203b16:	739c                	ld	a5,32(a5)
ffffffffc0203b18:	4585                	li	a1,1
ffffffffc0203b1a:	9782                	jalr	a5
    if (flag) {
ffffffffc0203b1c:	bfe1                	j	ffffffffc0203af4 <page_remove+0x52>
        intr_disable();
ffffffffc0203b1e:	e42a                	sd	a0,8(sp)
ffffffffc0203b20:	b05fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0203b24:	000af797          	auipc	a5,0xaf
ffffffffc0203b28:	d3c7b783          	ld	a5,-708(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203b2c:	739c                	ld	a5,32(a5)
ffffffffc0203b2e:	6522                	ld	a0,8(sp)
ffffffffc0203b30:	4585                	li	a1,1
ffffffffc0203b32:	9782                	jalr	a5
        intr_enable();
ffffffffc0203b34:	aebfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203b38:	bf75                	j	ffffffffc0203af4 <page_remove+0x52>
ffffffffc0203b3a:	827ff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>

ffffffffc0203b3e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203b3e:	7139                	addi	sp,sp,-64
ffffffffc0203b40:	e852                	sd	s4,16(sp)
ffffffffc0203b42:	8a32                	mv	s4,a2
ffffffffc0203b44:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203b46:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203b48:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203b4a:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203b4c:	f426                	sd	s1,40(sp)
ffffffffc0203b4e:	fc06                	sd	ra,56(sp)
ffffffffc0203b50:	f04a                	sd	s2,32(sp)
ffffffffc0203b52:	ec4e                	sd	s3,24(sp)
ffffffffc0203b54:	e456                	sd	s5,8(sp)
ffffffffc0203b56:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203b58:	94dff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
    if (ptep == NULL) {
ffffffffc0203b5c:	c961                	beqz	a0,ffffffffc0203c2c <page_insert+0xee>
    page->ref += 1;
ffffffffc0203b5e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203b60:	611c                	ld	a5,0(a0)
ffffffffc0203b62:	89aa                	mv	s3,a0
ffffffffc0203b64:	0016871b          	addiw	a4,a3,1
ffffffffc0203b68:	c018                	sw	a4,0(s0)
ffffffffc0203b6a:	0017f713          	andi	a4,a5,1
ffffffffc0203b6e:	ef05                	bnez	a4,ffffffffc0203ba6 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203b70:	000af717          	auipc	a4,0xaf
ffffffffc0203b74:	ce873703          	ld	a4,-792(a4) # ffffffffc02b2858 <pages>
ffffffffc0203b78:	8c19                	sub	s0,s0,a4
ffffffffc0203b7a:	000807b7          	lui	a5,0x80
ffffffffc0203b7e:	8419                	srai	s0,s0,0x6
ffffffffc0203b80:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203b82:	042a                	slli	s0,s0,0xa
ffffffffc0203b84:	8cc1                	or	s1,s1,s0
ffffffffc0203b86:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203b8a:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203b8e:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203b92:	4501                	li	a0,0
}
ffffffffc0203b94:	70e2                	ld	ra,56(sp)
ffffffffc0203b96:	7442                	ld	s0,48(sp)
ffffffffc0203b98:	74a2                	ld	s1,40(sp)
ffffffffc0203b9a:	7902                	ld	s2,32(sp)
ffffffffc0203b9c:	69e2                	ld	s3,24(sp)
ffffffffc0203b9e:	6a42                	ld	s4,16(sp)
ffffffffc0203ba0:	6aa2                	ld	s5,8(sp)
ffffffffc0203ba2:	6121                	addi	sp,sp,64
ffffffffc0203ba4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ba6:	078a                	slli	a5,a5,0x2
ffffffffc0203ba8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203baa:	000af717          	auipc	a4,0xaf
ffffffffc0203bae:	ca673703          	ld	a4,-858(a4) # ffffffffc02b2850 <npage>
ffffffffc0203bb2:	06e7ff63          	bgeu	a5,a4,ffffffffc0203c30 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bb6:	000afa97          	auipc	s5,0xaf
ffffffffc0203bba:	ca2a8a93          	addi	s5,s5,-862 # ffffffffc02b2858 <pages>
ffffffffc0203bbe:	000ab703          	ld	a4,0(s5)
ffffffffc0203bc2:	fff80937          	lui	s2,0xfff80
ffffffffc0203bc6:	993e                	add	s2,s2,a5
ffffffffc0203bc8:	091a                	slli	s2,s2,0x6
ffffffffc0203bca:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203bcc:	01240c63          	beq	s0,s2,ffffffffc0203be4 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203bd0:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd774>
ffffffffc0203bd4:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203bd8:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203bdc:	c691                	beqz	a3,ffffffffc0203be8 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203bde:	120a0073          	sfence.vma	s4
}
ffffffffc0203be2:	bf59                	j	ffffffffc0203b78 <page_insert+0x3a>
ffffffffc0203be4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203be6:	bf49                	j	ffffffffc0203b78 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203be8:	100027f3          	csrr	a5,sstatus
ffffffffc0203bec:	8b89                	andi	a5,a5,2
ffffffffc0203bee:	ef91                	bnez	a5,ffffffffc0203c0a <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203bf0:	000af797          	auipc	a5,0xaf
ffffffffc0203bf4:	c707b783          	ld	a5,-912(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203bf8:	739c                	ld	a5,32(a5)
ffffffffc0203bfa:	4585                	li	a1,1
ffffffffc0203bfc:	854a                	mv	a0,s2
ffffffffc0203bfe:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203c00:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c04:	120a0073          	sfence.vma	s4
ffffffffc0203c08:	bf85                	j	ffffffffc0203b78 <page_insert+0x3a>
        intr_disable();
ffffffffc0203c0a:	a1bfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203c0e:	000af797          	auipc	a5,0xaf
ffffffffc0203c12:	c527b783          	ld	a5,-942(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0203c16:	739c                	ld	a5,32(a5)
ffffffffc0203c18:	4585                	li	a1,1
ffffffffc0203c1a:	854a                	mv	a0,s2
ffffffffc0203c1c:	9782                	jalr	a5
        intr_enable();
ffffffffc0203c1e:	a01fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203c22:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c26:	120a0073          	sfence.vma	s4
ffffffffc0203c2a:	b7b9                	j	ffffffffc0203b78 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203c2c:	5571                	li	a0,-4
ffffffffc0203c2e:	b79d                	j	ffffffffc0203b94 <page_insert+0x56>
ffffffffc0203c30:	f30ff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>

ffffffffc0203c34 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203c34:	00004797          	auipc	a5,0x4
ffffffffc0203c38:	f7478793          	addi	a5,a5,-140 # ffffffffc0207ba8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203c3c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203c3e:	711d                	addi	sp,sp,-96
ffffffffc0203c40:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203c42:	00004517          	auipc	a0,0x4
ffffffffc0203c46:	ff650513          	addi	a0,a0,-10 # ffffffffc0207c38 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc0203c4a:	000afb97          	auipc	s7,0xaf
ffffffffc0203c4e:	c16b8b93          	addi	s7,s7,-1002 # ffffffffc02b2860 <pmm_manager>
void pmm_init(void) {
ffffffffc0203c52:	ec86                	sd	ra,88(sp)
ffffffffc0203c54:	e4a6                	sd	s1,72(sp)
ffffffffc0203c56:	fc4e                	sd	s3,56(sp)
ffffffffc0203c58:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203c5a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203c5e:	e8a2                	sd	s0,80(sp)
ffffffffc0203c60:	e0ca                	sd	s2,64(sp)
ffffffffc0203c62:	f852                	sd	s4,48(sp)
ffffffffc0203c64:	f456                	sd	s5,40(sp)
ffffffffc0203c66:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203c68:	c64fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203c6c:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203c70:	000af997          	auipc	s3,0xaf
ffffffffc0203c74:	bf898993          	addi	s3,s3,-1032 # ffffffffc02b2868 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203c78:	000af497          	auipc	s1,0xaf
ffffffffc0203c7c:	bd848493          	addi	s1,s1,-1064 # ffffffffc02b2850 <npage>
    pmm_manager->init();
ffffffffc0203c80:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203c82:	000afb17          	auipc	s6,0xaf
ffffffffc0203c86:	bd6b0b13          	addi	s6,s6,-1066 # ffffffffc02b2858 <pages>
    pmm_manager->init();
ffffffffc0203c8a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203c8c:	57f5                	li	a5,-3
ffffffffc0203c8e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203c90:	00004517          	auipc	a0,0x4
ffffffffc0203c94:	fc050513          	addi	a0,a0,-64 # ffffffffc0207c50 <default_pmm_manager+0xa8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203c98:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203c9c:	c30fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203ca0:	46c5                	li	a3,17
ffffffffc0203ca2:	06ee                	slli	a3,a3,0x1b
ffffffffc0203ca4:	40100613          	li	a2,1025
ffffffffc0203ca8:	07e005b7          	lui	a1,0x7e00
ffffffffc0203cac:	16fd                	addi	a3,a3,-1
ffffffffc0203cae:	0656                	slli	a2,a2,0x15
ffffffffc0203cb0:	00004517          	auipc	a0,0x4
ffffffffc0203cb4:	fb850513          	addi	a0,a0,-72 # ffffffffc0207c68 <default_pmm_manager+0xc0>
ffffffffc0203cb8:	c14fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203cbc:	777d                	lui	a4,0xfffff
ffffffffc0203cbe:	000b0797          	auipc	a5,0xb0
ffffffffc0203cc2:	bcd78793          	addi	a5,a5,-1075 # ffffffffc02b388b <end+0xfff>
ffffffffc0203cc6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203cc8:	00088737          	lui	a4,0x88
ffffffffc0203ccc:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203cce:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203cd2:	4701                	li	a4,0
ffffffffc0203cd4:	4585                	li	a1,1
ffffffffc0203cd6:	fff80837          	lui	a6,0xfff80
ffffffffc0203cda:	a019                	j	ffffffffc0203ce0 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203cdc:	000b3783          	ld	a5,0(s6)
ffffffffc0203ce0:	00671693          	slli	a3,a4,0x6
ffffffffc0203ce4:	97b6                	add	a5,a5,a3
ffffffffc0203ce6:	07a1                	addi	a5,a5,8
ffffffffc0203ce8:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203cec:	6090                	ld	a2,0(s1)
ffffffffc0203cee:	0705                	addi	a4,a4,1
ffffffffc0203cf0:	010607b3          	add	a5,a2,a6
ffffffffc0203cf4:	fef764e3          	bltu	a4,a5,ffffffffc0203cdc <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203cf8:	000b3503          	ld	a0,0(s6)
ffffffffc0203cfc:	079a                	slli	a5,a5,0x6
ffffffffc0203cfe:	c0200737          	lui	a4,0xc0200
ffffffffc0203d02:	00f506b3          	add	a3,a0,a5
ffffffffc0203d06:	60e6e563          	bltu	a3,a4,ffffffffc0204310 <pmm_init+0x6dc>
ffffffffc0203d0a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203d0e:	4745                	li	a4,17
ffffffffc0203d10:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203d12:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203d14:	4ae6e563          	bltu	a3,a4,ffffffffc02041be <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203d18:	00004517          	auipc	a0,0x4
ffffffffc0203d1c:	f7850513          	addi	a0,a0,-136 # ffffffffc0207c90 <default_pmm_manager+0xe8>
ffffffffc0203d20:	bacfc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203d24:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203d28:	000af917          	auipc	s2,0xaf
ffffffffc0203d2c:	b2090913          	addi	s2,s2,-1248 # ffffffffc02b2848 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203d30:	7b9c                	ld	a5,48(a5)
ffffffffc0203d32:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203d34:	00004517          	auipc	a0,0x4
ffffffffc0203d38:	f7450513          	addi	a0,a0,-140 # ffffffffc0207ca8 <default_pmm_manager+0x100>
ffffffffc0203d3c:	b90fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203d40:	00007697          	auipc	a3,0x7
ffffffffc0203d44:	2c068693          	addi	a3,a3,704 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203d48:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203d4c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d50:	5cf6ec63          	bltu	a3,a5,ffffffffc0204328 <pmm_init+0x6f4>
ffffffffc0203d54:	0009b783          	ld	a5,0(s3)
ffffffffc0203d58:	8e9d                	sub	a3,a3,a5
ffffffffc0203d5a:	000af797          	auipc	a5,0xaf
ffffffffc0203d5e:	aed7b323          	sd	a3,-1306(a5) # ffffffffc02b2840 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d62:	100027f3          	csrr	a5,sstatus
ffffffffc0203d66:	8b89                	andi	a5,a5,2
ffffffffc0203d68:	48079263          	bnez	a5,ffffffffc02041ec <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203d6c:	000bb783          	ld	a5,0(s7)
ffffffffc0203d70:	779c                	ld	a5,40(a5)
ffffffffc0203d72:	9782                	jalr	a5
ffffffffc0203d74:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203d76:	6098                	ld	a4,0(s1)
ffffffffc0203d78:	c80007b7          	lui	a5,0xc8000
ffffffffc0203d7c:	83b1                	srli	a5,a5,0xc
ffffffffc0203d7e:	5ee7e163          	bltu	a5,a4,ffffffffc0204360 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203d82:	00093503          	ld	a0,0(s2)
ffffffffc0203d86:	5a050d63          	beqz	a0,ffffffffc0204340 <pmm_init+0x70c>
ffffffffc0203d8a:	03451793          	slli	a5,a0,0x34
ffffffffc0203d8e:	5a079963          	bnez	a5,ffffffffc0204340 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203d92:	4601                	li	a2,0
ffffffffc0203d94:	4581                	li	a1,0
ffffffffc0203d96:	8e1ff0ef          	jal	ra,ffffffffc0203676 <get_page>
ffffffffc0203d9a:	62051563          	bnez	a0,ffffffffc02043c4 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203d9e:	4505                	li	a0,1
ffffffffc0203da0:	df8ff0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0203da4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203da6:	00093503          	ld	a0,0(s2)
ffffffffc0203daa:	4681                	li	a3,0
ffffffffc0203dac:	4601                	li	a2,0
ffffffffc0203dae:	85d2                	mv	a1,s4
ffffffffc0203db0:	d8fff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc0203db4:	5e051863          	bnez	a0,ffffffffc02043a4 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203db8:	00093503          	ld	a0,0(s2)
ffffffffc0203dbc:	4601                	li	a2,0
ffffffffc0203dbe:	4581                	li	a1,0
ffffffffc0203dc0:	ee4ff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0203dc4:	5c050063          	beqz	a0,ffffffffc0204384 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203dc8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203dca:	0017f713          	andi	a4,a5,1
ffffffffc0203dce:	5a070963          	beqz	a4,ffffffffc0204380 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203dd2:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203dd4:	078a                	slli	a5,a5,0x2
ffffffffc0203dd6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203dd8:	52e7fa63          	bgeu	a5,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ddc:	000b3683          	ld	a3,0(s6)
ffffffffc0203de0:	fff80637          	lui	a2,0xfff80
ffffffffc0203de4:	97b2                	add	a5,a5,a2
ffffffffc0203de6:	079a                	slli	a5,a5,0x6
ffffffffc0203de8:	97b6                	add	a5,a5,a3
ffffffffc0203dea:	10fa16e3          	bne	s4,a5,ffffffffc02046f6 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0203dee:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203df2:	4785                	li	a5,1
ffffffffc0203df4:	12f69de3          	bne	a3,a5,ffffffffc020472e <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203df8:	00093503          	ld	a0,0(s2)
ffffffffc0203dfc:	77fd                	lui	a5,0xfffff
ffffffffc0203dfe:	6114                	ld	a3,0(a0)
ffffffffc0203e00:	068a                	slli	a3,a3,0x2
ffffffffc0203e02:	8efd                	and	a3,a3,a5
ffffffffc0203e04:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203e08:	10e677e3          	bgeu	a2,a4,ffffffffc0204716 <pmm_init+0xae2>
ffffffffc0203e0c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203e10:	96e2                	add	a3,a3,s8
ffffffffc0203e12:	0006ba83          	ld	s5,0(a3)
ffffffffc0203e16:	0a8a                	slli	s5,s5,0x2
ffffffffc0203e18:	00fafab3          	and	s5,s5,a5
ffffffffc0203e1c:	00cad793          	srli	a5,s5,0xc
ffffffffc0203e20:	62e7f263          	bgeu	a5,a4,ffffffffc0204444 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203e24:	4601                	li	a2,0
ffffffffc0203e26:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203e28:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203e2a:	e7aff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203e2e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203e30:	5f551a63          	bne	a0,s5,ffffffffc0204424 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203e34:	4505                	li	a0,1
ffffffffc0203e36:	d62ff0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0203e3a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203e3c:	00093503          	ld	a0,0(s2)
ffffffffc0203e40:	46d1                	li	a3,20
ffffffffc0203e42:	6605                	lui	a2,0x1
ffffffffc0203e44:	85d6                	mv	a1,s5
ffffffffc0203e46:	cf9ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc0203e4a:	58051d63          	bnez	a0,ffffffffc02043e4 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203e4e:	00093503          	ld	a0,0(s2)
ffffffffc0203e52:	4601                	li	a2,0
ffffffffc0203e54:	6585                	lui	a1,0x1
ffffffffc0203e56:	e4eff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0203e5a:	0e050ae3          	beqz	a0,ffffffffc020474e <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0203e5e:	611c                	ld	a5,0(a0)
ffffffffc0203e60:	0107f713          	andi	a4,a5,16
ffffffffc0203e64:	6e070d63          	beqz	a4,ffffffffc020455e <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0203e68:	8b91                	andi	a5,a5,4
ffffffffc0203e6a:	6a078a63          	beqz	a5,ffffffffc020451e <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203e6e:	00093503          	ld	a0,0(s2)
ffffffffc0203e72:	611c                	ld	a5,0(a0)
ffffffffc0203e74:	8bc1                	andi	a5,a5,16
ffffffffc0203e76:	68078463          	beqz	a5,ffffffffc02044fe <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0203e7a:	000aa703          	lw	a4,0(s5)
ffffffffc0203e7e:	4785                	li	a5,1
ffffffffc0203e80:	58f71263          	bne	a4,a5,ffffffffc0204404 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203e84:	4681                	li	a3,0
ffffffffc0203e86:	6605                	lui	a2,0x1
ffffffffc0203e88:	85d2                	mv	a1,s4
ffffffffc0203e8a:	cb5ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc0203e8e:	62051863          	bnez	a0,ffffffffc02044be <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0203e92:	000a2703          	lw	a4,0(s4)
ffffffffc0203e96:	4789                	li	a5,2
ffffffffc0203e98:	60f71363          	bne	a4,a5,ffffffffc020449e <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0203e9c:	000aa783          	lw	a5,0(s5)
ffffffffc0203ea0:	5c079f63          	bnez	a5,ffffffffc020447e <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203ea4:	00093503          	ld	a0,0(s2)
ffffffffc0203ea8:	4601                	li	a2,0
ffffffffc0203eaa:	6585                	lui	a1,0x1
ffffffffc0203eac:	df8ff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0203eb0:	5a050763          	beqz	a0,ffffffffc020445e <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0203eb4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203eb6:	00177793          	andi	a5,a4,1
ffffffffc0203eba:	4c078363          	beqz	a5,ffffffffc0204380 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203ebe:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ec0:	00271793          	slli	a5,a4,0x2
ffffffffc0203ec4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ec6:	44d7f363          	bgeu	a5,a3,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203eca:	000b3683          	ld	a3,0(s6)
ffffffffc0203ece:	fff80637          	lui	a2,0xfff80
ffffffffc0203ed2:	97b2                	add	a5,a5,a2
ffffffffc0203ed4:	079a                	slli	a5,a5,0x6
ffffffffc0203ed6:	97b6                	add	a5,a5,a3
ffffffffc0203ed8:	6efa1363          	bne	s4,a5,ffffffffc02045be <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203edc:	8b41                	andi	a4,a4,16
ffffffffc0203ede:	6c071063          	bnez	a4,ffffffffc020459e <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203ee2:	00093503          	ld	a0,0(s2)
ffffffffc0203ee6:	4581                	li	a1,0
ffffffffc0203ee8:	bbbff0ef          	jal	ra,ffffffffc0203aa2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203eec:	000a2703          	lw	a4,0(s4)
ffffffffc0203ef0:	4785                	li	a5,1
ffffffffc0203ef2:	68f71663          	bne	a4,a5,ffffffffc020457e <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203ef6:	000aa783          	lw	a5,0(s5)
ffffffffc0203efa:	74079e63          	bnez	a5,ffffffffc0204656 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203efe:	00093503          	ld	a0,0(s2)
ffffffffc0203f02:	6585                	lui	a1,0x1
ffffffffc0203f04:	b9fff0ef          	jal	ra,ffffffffc0203aa2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203f08:	000a2783          	lw	a5,0(s4)
ffffffffc0203f0c:	72079563          	bnez	a5,ffffffffc0204636 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0203f10:	000aa783          	lw	a5,0(s5)
ffffffffc0203f14:	70079163          	bnez	a5,ffffffffc0204616 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203f18:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203f1c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203f1e:	000a3683          	ld	a3,0(s4)
ffffffffc0203f22:	068a                	slli	a3,a3,0x2
ffffffffc0203f24:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f26:	3ee6f363          	bgeu	a3,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f2a:	fff807b7          	lui	a5,0xfff80
ffffffffc0203f2e:	000b3503          	ld	a0,0(s6)
ffffffffc0203f32:	96be                	add	a3,a3,a5
ffffffffc0203f34:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203f36:	00d507b3          	add	a5,a0,a3
ffffffffc0203f3a:	4390                	lw	a2,0(a5)
ffffffffc0203f3c:	4785                	li	a5,1
ffffffffc0203f3e:	6af61c63          	bne	a2,a5,ffffffffc02045f6 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0203f42:	8699                	srai	a3,a3,0x6
ffffffffc0203f44:	000805b7          	lui	a1,0x80
ffffffffc0203f48:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203f4a:	00c69613          	slli	a2,a3,0xc
ffffffffc0203f4e:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f50:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203f52:	68e67663          	bgeu	a2,a4,ffffffffc02045de <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203f56:	0009b603          	ld	a2,0(s3)
ffffffffc0203f5a:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0203f5c:	629c                	ld	a5,0(a3)
ffffffffc0203f5e:	078a                	slli	a5,a5,0x2
ffffffffc0203f60:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f62:	3ae7f563          	bgeu	a5,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f66:	8f8d                	sub	a5,a5,a1
ffffffffc0203f68:	079a                	slli	a5,a5,0x6
ffffffffc0203f6a:	953e                	add	a0,a0,a5
ffffffffc0203f6c:	100027f3          	csrr	a5,sstatus
ffffffffc0203f70:	8b89                	andi	a5,a5,2
ffffffffc0203f72:	2c079763          	bnez	a5,ffffffffc0204240 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0203f76:	000bb783          	ld	a5,0(s7)
ffffffffc0203f7a:	4585                	li	a1,1
ffffffffc0203f7c:	739c                	ld	a5,32(a5)
ffffffffc0203f7e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203f80:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203f84:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203f86:	078a                	slli	a5,a5,0x2
ffffffffc0203f88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f8a:	38e7f163          	bgeu	a5,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f8e:	000b3503          	ld	a0,0(s6)
ffffffffc0203f92:	fff80737          	lui	a4,0xfff80
ffffffffc0203f96:	97ba                	add	a5,a5,a4
ffffffffc0203f98:	079a                	slli	a5,a5,0x6
ffffffffc0203f9a:	953e                	add	a0,a0,a5
ffffffffc0203f9c:	100027f3          	csrr	a5,sstatus
ffffffffc0203fa0:	8b89                	andi	a5,a5,2
ffffffffc0203fa2:	28079363          	bnez	a5,ffffffffc0204228 <pmm_init+0x5f4>
ffffffffc0203fa6:	000bb783          	ld	a5,0(s7)
ffffffffc0203faa:	4585                	li	a1,1
ffffffffc0203fac:	739c                	ld	a5,32(a5)
ffffffffc0203fae:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203fb0:	00093783          	ld	a5,0(s2)
ffffffffc0203fb4:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd774>
  asm volatile("sfence.vma");
ffffffffc0203fb8:	12000073          	sfence.vma
ffffffffc0203fbc:	100027f3          	csrr	a5,sstatus
ffffffffc0203fc0:	8b89                	andi	a5,a5,2
ffffffffc0203fc2:	24079963          	bnez	a5,ffffffffc0204214 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203fc6:	000bb783          	ld	a5,0(s7)
ffffffffc0203fca:	779c                	ld	a5,40(a5)
ffffffffc0203fcc:	9782                	jalr	a5
ffffffffc0203fce:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203fd0:	71441363          	bne	s0,s4,ffffffffc02046d6 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203fd4:	00004517          	auipc	a0,0x4
ffffffffc0203fd8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207f90 <default_pmm_manager+0x3e8>
ffffffffc0203fdc:	8f0fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203fe0:	100027f3          	csrr	a5,sstatus
ffffffffc0203fe4:	8b89                	andi	a5,a5,2
ffffffffc0203fe6:	20079d63          	bnez	a5,ffffffffc0204200 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203fea:	000bb783          	ld	a5,0(s7)
ffffffffc0203fee:	779c                	ld	a5,40(a5)
ffffffffc0203ff0:	9782                	jalr	a5
ffffffffc0203ff2:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203ff4:	6098                	ld	a4,0(s1)
ffffffffc0203ff6:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203ffa:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203ffc:	00c71793          	slli	a5,a4,0xc
ffffffffc0204000:	6a05                	lui	s4,0x1
ffffffffc0204002:	02f47c63          	bgeu	s0,a5,ffffffffc020403a <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204006:	00c45793          	srli	a5,s0,0xc
ffffffffc020400a:	00093503          	ld	a0,0(s2)
ffffffffc020400e:	2ee7f263          	bgeu	a5,a4,ffffffffc02042f2 <pmm_init+0x6be>
ffffffffc0204012:	0009b583          	ld	a1,0(s3)
ffffffffc0204016:	4601                	li	a2,0
ffffffffc0204018:	95a2                	add	a1,a1,s0
ffffffffc020401a:	c8aff0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc020401e:	2a050a63          	beqz	a0,ffffffffc02042d2 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204022:	611c                	ld	a5,0(a0)
ffffffffc0204024:	078a                	slli	a5,a5,0x2
ffffffffc0204026:	0157f7b3          	and	a5,a5,s5
ffffffffc020402a:	28879463          	bne	a5,s0,ffffffffc02042b2 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020402e:	6098                	ld	a4,0(s1)
ffffffffc0204030:	9452                	add	s0,s0,s4
ffffffffc0204032:	00c71793          	slli	a5,a4,0xc
ffffffffc0204036:	fcf468e3          	bltu	s0,a5,ffffffffc0204006 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020403a:	00093783          	ld	a5,0(s2)
ffffffffc020403e:	639c                	ld	a5,0(a5)
ffffffffc0204040:	66079b63          	bnez	a5,ffffffffc02046b6 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0204044:	4505                	li	a0,1
ffffffffc0204046:	b52ff0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc020404a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020404c:	00093503          	ld	a0,0(s2)
ffffffffc0204050:	4699                	li	a3,6
ffffffffc0204052:	10000613          	li	a2,256
ffffffffc0204056:	85d6                	mv	a1,s5
ffffffffc0204058:	ae7ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc020405c:	62051d63          	bnez	a0,ffffffffc0204696 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0204060:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c774>
ffffffffc0204064:	4785                	li	a5,1
ffffffffc0204066:	60f71863          	bne	a4,a5,ffffffffc0204676 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020406a:	00093503          	ld	a0,0(s2)
ffffffffc020406e:	6405                	lui	s0,0x1
ffffffffc0204070:	4699                	li	a3,6
ffffffffc0204072:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab8>
ffffffffc0204076:	85d6                	mv	a1,s5
ffffffffc0204078:	ac7ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc020407c:	46051163          	bnez	a0,ffffffffc02044de <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0204080:	000aa703          	lw	a4,0(s5)
ffffffffc0204084:	4789                	li	a5,2
ffffffffc0204086:	72f71463          	bne	a4,a5,ffffffffc02047ae <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020408a:	00004597          	auipc	a1,0x4
ffffffffc020408e:	03e58593          	addi	a1,a1,62 # ffffffffc02080c8 <default_pmm_manager+0x520>
ffffffffc0204092:	10000513          	li	a0,256
ffffffffc0204096:	78d010ef          	jal	ra,ffffffffc0206022 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020409a:	10040593          	addi	a1,s0,256
ffffffffc020409e:	10000513          	li	a0,256
ffffffffc02040a2:	793010ef          	jal	ra,ffffffffc0206034 <strcmp>
ffffffffc02040a6:	6e051463          	bnez	a0,ffffffffc020478e <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02040aa:	000b3683          	ld	a3,0(s6)
ffffffffc02040ae:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02040b2:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02040b4:	40da86b3          	sub	a3,s5,a3
ffffffffc02040b8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02040ba:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02040bc:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02040be:	8031                	srli	s0,s0,0xc
ffffffffc02040c0:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02040c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02040c6:	50f77c63          	bgeu	a4,a5,ffffffffc02045de <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02040ca:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02040ce:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02040d2:	96be                	add	a3,a3,a5
ffffffffc02040d4:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02040d8:	715010ef          	jal	ra,ffffffffc0205fec <strlen>
ffffffffc02040dc:	68051963          	bnez	a0,ffffffffc020476e <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02040e0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02040e4:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02040e6:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02040ea:	068a                	slli	a3,a3,0x2
ffffffffc02040ec:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040ee:	20f6ff63          	bgeu	a3,a5,ffffffffc020430c <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02040f2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02040f6:	4ef47463          	bgeu	s0,a5,ffffffffc02045de <pmm_init+0x9aa>
ffffffffc02040fa:	0009b403          	ld	s0,0(s3)
ffffffffc02040fe:	9436                	add	s0,s0,a3
ffffffffc0204100:	100027f3          	csrr	a5,sstatus
ffffffffc0204104:	8b89                	andi	a5,a5,2
ffffffffc0204106:	18079b63          	bnez	a5,ffffffffc020429c <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc020410a:	000bb783          	ld	a5,0(s7)
ffffffffc020410e:	4585                	li	a1,1
ffffffffc0204110:	8556                	mv	a0,s5
ffffffffc0204112:	739c                	ld	a5,32(a5)
ffffffffc0204114:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204116:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204118:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020411a:	078a                	slli	a5,a5,0x2
ffffffffc020411c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020411e:	1ee7f763          	bgeu	a5,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204122:	000b3503          	ld	a0,0(s6)
ffffffffc0204126:	fff80737          	lui	a4,0xfff80
ffffffffc020412a:	97ba                	add	a5,a5,a4
ffffffffc020412c:	079a                	slli	a5,a5,0x6
ffffffffc020412e:	953e                	add	a0,a0,a5
ffffffffc0204130:	100027f3          	csrr	a5,sstatus
ffffffffc0204134:	8b89                	andi	a5,a5,2
ffffffffc0204136:	14079763          	bnez	a5,ffffffffc0204284 <pmm_init+0x650>
ffffffffc020413a:	000bb783          	ld	a5,0(s7)
ffffffffc020413e:	4585                	li	a1,1
ffffffffc0204140:	739c                	ld	a5,32(a5)
ffffffffc0204142:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204144:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204148:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020414a:	078a                	slli	a5,a5,0x2
ffffffffc020414c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020414e:	1ae7ff63          	bgeu	a5,a4,ffffffffc020430c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204152:	000b3503          	ld	a0,0(s6)
ffffffffc0204156:	fff80737          	lui	a4,0xfff80
ffffffffc020415a:	97ba                	add	a5,a5,a4
ffffffffc020415c:	079a                	slli	a5,a5,0x6
ffffffffc020415e:	953e                	add	a0,a0,a5
ffffffffc0204160:	100027f3          	csrr	a5,sstatus
ffffffffc0204164:	8b89                	andi	a5,a5,2
ffffffffc0204166:	10079363          	bnez	a5,ffffffffc020426c <pmm_init+0x638>
ffffffffc020416a:	000bb783          	ld	a5,0(s7)
ffffffffc020416e:	4585                	li	a1,1
ffffffffc0204170:	739c                	ld	a5,32(a5)
ffffffffc0204172:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204174:	00093783          	ld	a5,0(s2)
ffffffffc0204178:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020417c:	12000073          	sfence.vma
ffffffffc0204180:	100027f3          	csrr	a5,sstatus
ffffffffc0204184:	8b89                	andi	a5,a5,2
ffffffffc0204186:	0c079963          	bnez	a5,ffffffffc0204258 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc020418a:	000bb783          	ld	a5,0(s7)
ffffffffc020418e:	779c                	ld	a5,40(a5)
ffffffffc0204190:	9782                	jalr	a5
ffffffffc0204192:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204194:	3a8c1563          	bne	s8,s0,ffffffffc020453e <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0204198:	00004517          	auipc	a0,0x4
ffffffffc020419c:	fa850513          	addi	a0,a0,-88 # ffffffffc0208140 <default_pmm_manager+0x598>
ffffffffc02041a0:	f2dfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02041a4:	6446                	ld	s0,80(sp)
ffffffffc02041a6:	60e6                	ld	ra,88(sp)
ffffffffc02041a8:	64a6                	ld	s1,72(sp)
ffffffffc02041aa:	6906                	ld	s2,64(sp)
ffffffffc02041ac:	79e2                	ld	s3,56(sp)
ffffffffc02041ae:	7a42                	ld	s4,48(sp)
ffffffffc02041b0:	7aa2                	ld	s5,40(sp)
ffffffffc02041b2:	7b02                	ld	s6,32(sp)
ffffffffc02041b4:	6be2                	ld	s7,24(sp)
ffffffffc02041b6:	6c42                	ld	s8,16(sp)
ffffffffc02041b8:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02041ba:	92cfe06f          	j	ffffffffc02022e6 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02041be:	6785                	lui	a5,0x1
ffffffffc02041c0:	17fd                	addi	a5,a5,-1
ffffffffc02041c2:	96be                	add	a3,a3,a5
ffffffffc02041c4:	77fd                	lui	a5,0xfffff
ffffffffc02041c6:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc02041c8:	00c7d693          	srli	a3,a5,0xc
ffffffffc02041cc:	14c6f063          	bgeu	a3,a2,ffffffffc020430c <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc02041d0:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02041d4:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02041d6:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02041da:	6a10                	ld	a2,16(a2)
ffffffffc02041dc:	069a                	slli	a3,a3,0x6
ffffffffc02041de:	00c7d593          	srli	a1,a5,0xc
ffffffffc02041e2:	9536                	add	a0,a0,a3
ffffffffc02041e4:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02041e6:	0009b583          	ld	a1,0(s3)
}
ffffffffc02041ea:	b63d                	j	ffffffffc0203d18 <pmm_init+0xe4>
        intr_disable();
ffffffffc02041ec:	c38fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02041f0:	000bb783          	ld	a5,0(s7)
ffffffffc02041f4:	779c                	ld	a5,40(a5)
ffffffffc02041f6:	9782                	jalr	a5
ffffffffc02041f8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02041fa:	c24fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02041fe:	bea5                	j	ffffffffc0203d76 <pmm_init+0x142>
        intr_disable();
ffffffffc0204200:	c24fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204204:	000bb783          	ld	a5,0(s7)
ffffffffc0204208:	779c                	ld	a5,40(a5)
ffffffffc020420a:	9782                	jalr	a5
ffffffffc020420c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020420e:	c10fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204212:	b3cd                	j	ffffffffc0203ff4 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0204214:	c10fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204218:	000bb783          	ld	a5,0(s7)
ffffffffc020421c:	779c                	ld	a5,40(a5)
ffffffffc020421e:	9782                	jalr	a5
ffffffffc0204220:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0204222:	bfcfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204226:	b36d                	j	ffffffffc0203fd0 <pmm_init+0x39c>
ffffffffc0204228:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020422a:	bfafc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020422e:	000bb783          	ld	a5,0(s7)
ffffffffc0204232:	6522                	ld	a0,8(sp)
ffffffffc0204234:	4585                	li	a1,1
ffffffffc0204236:	739c                	ld	a5,32(a5)
ffffffffc0204238:	9782                	jalr	a5
        intr_enable();
ffffffffc020423a:	be4fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020423e:	bb8d                	j	ffffffffc0203fb0 <pmm_init+0x37c>
ffffffffc0204240:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204242:	be2fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204246:	000bb783          	ld	a5,0(s7)
ffffffffc020424a:	6522                	ld	a0,8(sp)
ffffffffc020424c:	4585                	li	a1,1
ffffffffc020424e:	739c                	ld	a5,32(a5)
ffffffffc0204250:	9782                	jalr	a5
        intr_enable();
ffffffffc0204252:	bccfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204256:	b32d                	j	ffffffffc0203f80 <pmm_init+0x34c>
        intr_disable();
ffffffffc0204258:	bccfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020425c:	000bb783          	ld	a5,0(s7)
ffffffffc0204260:	779c                	ld	a5,40(a5)
ffffffffc0204262:	9782                	jalr	a5
ffffffffc0204264:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204266:	bb8fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020426a:	b72d                	j	ffffffffc0204194 <pmm_init+0x560>
ffffffffc020426c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020426e:	bb6fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204272:	000bb783          	ld	a5,0(s7)
ffffffffc0204276:	6522                	ld	a0,8(sp)
ffffffffc0204278:	4585                	li	a1,1
ffffffffc020427a:	739c                	ld	a5,32(a5)
ffffffffc020427c:	9782                	jalr	a5
        intr_enable();
ffffffffc020427e:	ba0fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204282:	bdcd                	j	ffffffffc0204174 <pmm_init+0x540>
ffffffffc0204284:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204286:	b9efc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc020428a:	000bb783          	ld	a5,0(s7)
ffffffffc020428e:	6522                	ld	a0,8(sp)
ffffffffc0204290:	4585                	li	a1,1
ffffffffc0204292:	739c                	ld	a5,32(a5)
ffffffffc0204294:	9782                	jalr	a5
        intr_enable();
ffffffffc0204296:	b88fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020429a:	b56d                	j	ffffffffc0204144 <pmm_init+0x510>
        intr_disable();
ffffffffc020429c:	b88fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02042a0:	000bb783          	ld	a5,0(s7)
ffffffffc02042a4:	4585                	li	a1,1
ffffffffc02042a6:	8556                	mv	a0,s5
ffffffffc02042a8:	739c                	ld	a5,32(a5)
ffffffffc02042aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02042ac:	b72fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02042b0:	b59d                	j	ffffffffc0204116 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02042b2:	00004697          	auipc	a3,0x4
ffffffffc02042b6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0207ff0 <default_pmm_manager+0x448>
ffffffffc02042ba:	00003617          	auipc	a2,0x3
ffffffffc02042be:	89660613          	addi	a2,a2,-1898 # ffffffffc0206b50 <commands+0x410>
ffffffffc02042c2:	22800593          	li	a1,552
ffffffffc02042c6:	00004517          	auipc	a0,0x4
ffffffffc02042ca:	91a50513          	addi	a0,a0,-1766 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02042ce:	f3bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02042d2:	00004697          	auipc	a3,0x4
ffffffffc02042d6:	cde68693          	addi	a3,a3,-802 # ffffffffc0207fb0 <default_pmm_manager+0x408>
ffffffffc02042da:	00003617          	auipc	a2,0x3
ffffffffc02042de:	87660613          	addi	a2,a2,-1930 # ffffffffc0206b50 <commands+0x410>
ffffffffc02042e2:	22700593          	li	a1,551
ffffffffc02042e6:	00004517          	auipc	a0,0x4
ffffffffc02042ea:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02042ee:	f1bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02042f2:	86a2                	mv	a3,s0
ffffffffc02042f4:	00003617          	auipc	a2,0x3
ffffffffc02042f8:	e2c60613          	addi	a2,a2,-468 # ffffffffc0207120 <commands+0x9e0>
ffffffffc02042fc:	22700593          	li	a1,551
ffffffffc0204300:	00004517          	auipc	a0,0x4
ffffffffc0204304:	8e050513          	addi	a0,a0,-1824 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204308:	f01fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020430c:	854ff0ef          	jal	ra,ffffffffc0203360 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0204310:	00003617          	auipc	a2,0x3
ffffffffc0204314:	33860613          	addi	a2,a2,824 # ffffffffc0207648 <commands+0xf08>
ffffffffc0204318:	07f00593          	li	a1,127
ffffffffc020431c:	00004517          	auipc	a0,0x4
ffffffffc0204320:	8c450513          	addi	a0,a0,-1852 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204324:	ee5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204328:	00003617          	auipc	a2,0x3
ffffffffc020432c:	32060613          	addi	a2,a2,800 # ffffffffc0207648 <commands+0xf08>
ffffffffc0204330:	0c100593          	li	a1,193
ffffffffc0204334:	00004517          	auipc	a0,0x4
ffffffffc0204338:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020433c:	ecdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0204340:	00004697          	auipc	a3,0x4
ffffffffc0204344:	9a868693          	addi	a3,a3,-1624 # ffffffffc0207ce8 <default_pmm_manager+0x140>
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	80860613          	addi	a2,a2,-2040 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204350:	1eb00593          	li	a1,491
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	88c50513          	addi	a0,a0,-1908 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020435c:	eadfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204360:	00004697          	auipc	a3,0x4
ffffffffc0204364:	96868693          	addi	a3,a3,-1688 # ffffffffc0207cc8 <default_pmm_manager+0x120>
ffffffffc0204368:	00002617          	auipc	a2,0x2
ffffffffc020436c:	7e860613          	addi	a2,a2,2024 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204370:	1ea00593          	li	a1,490
ffffffffc0204374:	00004517          	auipc	a0,0x4
ffffffffc0204378:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020437c:	e8dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204380:	ffdfe0ef          	jal	ra,ffffffffc020337c <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204384:	00004697          	auipc	a3,0x4
ffffffffc0204388:	9f468693          	addi	a3,a3,-1548 # ffffffffc0207d78 <default_pmm_manager+0x1d0>
ffffffffc020438c:	00002617          	auipc	a2,0x2
ffffffffc0204390:	7c460613          	addi	a2,a2,1988 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204394:	1f300593          	li	a1,499
ffffffffc0204398:	00004517          	auipc	a0,0x4
ffffffffc020439c:	84850513          	addi	a0,a0,-1976 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02043a0:	e69fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02043a4:	00004697          	auipc	a3,0x4
ffffffffc02043a8:	9a468693          	addi	a3,a3,-1628 # ffffffffc0207d48 <default_pmm_manager+0x1a0>
ffffffffc02043ac:	00002617          	auipc	a2,0x2
ffffffffc02043b0:	7a460613          	addi	a2,a2,1956 # ffffffffc0206b50 <commands+0x410>
ffffffffc02043b4:	1f000593          	li	a1,496
ffffffffc02043b8:	00004517          	auipc	a0,0x4
ffffffffc02043bc:	82850513          	addi	a0,a0,-2008 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02043c0:	e49fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02043c4:	00004697          	auipc	a3,0x4
ffffffffc02043c8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0207d20 <default_pmm_manager+0x178>
ffffffffc02043cc:	00002617          	auipc	a2,0x2
ffffffffc02043d0:	78460613          	addi	a2,a2,1924 # ffffffffc0206b50 <commands+0x410>
ffffffffc02043d4:	1ec00593          	li	a1,492
ffffffffc02043d8:	00004517          	auipc	a0,0x4
ffffffffc02043dc:	80850513          	addi	a0,a0,-2040 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02043e0:	e29fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02043e4:	00004697          	auipc	a3,0x4
ffffffffc02043e8:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0207e00 <default_pmm_manager+0x258>
ffffffffc02043ec:	00002617          	auipc	a2,0x2
ffffffffc02043f0:	76460613          	addi	a2,a2,1892 # ffffffffc0206b50 <commands+0x410>
ffffffffc02043f4:	1fc00593          	li	a1,508
ffffffffc02043f8:	00003517          	auipc	a0,0x3
ffffffffc02043fc:	7e850513          	addi	a0,a0,2024 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204400:	e09fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204404:	00004697          	auipc	a3,0x4
ffffffffc0204408:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207ea0 <default_pmm_manager+0x2f8>
ffffffffc020440c:	00002617          	auipc	a2,0x2
ffffffffc0204410:	74460613          	addi	a2,a2,1860 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204414:	20100593          	li	a1,513
ffffffffc0204418:	00003517          	auipc	a0,0x3
ffffffffc020441c:	7c850513          	addi	a0,a0,1992 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204420:	de9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204424:	00004697          	auipc	a3,0x4
ffffffffc0204428:	9b468693          	addi	a3,a3,-1612 # ffffffffc0207dd8 <default_pmm_manager+0x230>
ffffffffc020442c:	00002617          	auipc	a2,0x2
ffffffffc0204430:	72460613          	addi	a2,a2,1828 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204434:	1f900593          	li	a1,505
ffffffffc0204438:	00003517          	auipc	a0,0x3
ffffffffc020443c:	7a850513          	addi	a0,a0,1960 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204440:	dc9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204444:	86d6                	mv	a3,s5
ffffffffc0204446:	00003617          	auipc	a2,0x3
ffffffffc020444a:	cda60613          	addi	a2,a2,-806 # ffffffffc0207120 <commands+0x9e0>
ffffffffc020444e:	1f800593          	li	a1,504
ffffffffc0204452:	00003517          	auipc	a0,0x3
ffffffffc0204456:	78e50513          	addi	a0,a0,1934 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020445a:	daffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020445e:	00004697          	auipc	a3,0x4
ffffffffc0204462:	9da68693          	addi	a3,a3,-1574 # ffffffffc0207e38 <default_pmm_manager+0x290>
ffffffffc0204466:	00002617          	auipc	a2,0x2
ffffffffc020446a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206b50 <commands+0x410>
ffffffffc020446e:	20600593          	li	a1,518
ffffffffc0204472:	00003517          	auipc	a0,0x3
ffffffffc0204476:	76e50513          	addi	a0,a0,1902 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020447a:	d8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020447e:	00004697          	auipc	a3,0x4
ffffffffc0204482:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207f00 <default_pmm_manager+0x358>
ffffffffc0204486:	00002617          	auipc	a2,0x2
ffffffffc020448a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0206b50 <commands+0x410>
ffffffffc020448e:	20500593          	li	a1,517
ffffffffc0204492:	00003517          	auipc	a0,0x3
ffffffffc0204496:	74e50513          	addi	a0,a0,1870 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020449a:	d6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020449e:	00004697          	auipc	a3,0x4
ffffffffc02044a2:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0207ee8 <default_pmm_manager+0x340>
ffffffffc02044a6:	00002617          	auipc	a2,0x2
ffffffffc02044aa:	6aa60613          	addi	a2,a2,1706 # ffffffffc0206b50 <commands+0x410>
ffffffffc02044ae:	20400593          	li	a1,516
ffffffffc02044b2:	00003517          	auipc	a0,0x3
ffffffffc02044b6:	72e50513          	addi	a0,a0,1838 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02044ba:	d4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02044be:	00004697          	auipc	a3,0x4
ffffffffc02044c2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207eb8 <default_pmm_manager+0x310>
ffffffffc02044c6:	00002617          	auipc	a2,0x2
ffffffffc02044ca:	68a60613          	addi	a2,a2,1674 # ffffffffc0206b50 <commands+0x410>
ffffffffc02044ce:	20300593          	li	a1,515
ffffffffc02044d2:	00003517          	auipc	a0,0x3
ffffffffc02044d6:	70e50513          	addi	a0,a0,1806 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02044da:	d2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02044de:	00004697          	auipc	a3,0x4
ffffffffc02044e2:	b9268693          	addi	a3,a3,-1134 # ffffffffc0208070 <default_pmm_manager+0x4c8>
ffffffffc02044e6:	00002617          	auipc	a2,0x2
ffffffffc02044ea:	66a60613          	addi	a2,a2,1642 # ffffffffc0206b50 <commands+0x410>
ffffffffc02044ee:	23200593          	li	a1,562
ffffffffc02044f2:	00003517          	auipc	a0,0x3
ffffffffc02044f6:	6ee50513          	addi	a0,a0,1774 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02044fa:	d0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02044fe:	00004697          	auipc	a3,0x4
ffffffffc0204502:	98a68693          	addi	a3,a3,-1654 # ffffffffc0207e88 <default_pmm_manager+0x2e0>
ffffffffc0204506:	00002617          	auipc	a2,0x2
ffffffffc020450a:	64a60613          	addi	a2,a2,1610 # ffffffffc0206b50 <commands+0x410>
ffffffffc020450e:	20000593          	li	a1,512
ffffffffc0204512:	00003517          	auipc	a0,0x3
ffffffffc0204516:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020451a:	ceffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020451e:	00004697          	auipc	a3,0x4
ffffffffc0204522:	95a68693          	addi	a3,a3,-1702 # ffffffffc0207e78 <default_pmm_manager+0x2d0>
ffffffffc0204526:	00002617          	auipc	a2,0x2
ffffffffc020452a:	62a60613          	addi	a2,a2,1578 # ffffffffc0206b50 <commands+0x410>
ffffffffc020452e:	1ff00593          	li	a1,511
ffffffffc0204532:	00003517          	auipc	a0,0x3
ffffffffc0204536:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020453a:	ccffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020453e:	00004697          	auipc	a3,0x4
ffffffffc0204542:	a3268693          	addi	a3,a3,-1486 # ffffffffc0207f70 <default_pmm_manager+0x3c8>
ffffffffc0204546:	00002617          	auipc	a2,0x2
ffffffffc020454a:	60a60613          	addi	a2,a2,1546 # ffffffffc0206b50 <commands+0x410>
ffffffffc020454e:	24300593          	li	a1,579
ffffffffc0204552:	00003517          	auipc	a0,0x3
ffffffffc0204556:	68e50513          	addi	a0,a0,1678 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020455a:	caffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020455e:	00004697          	auipc	a3,0x4
ffffffffc0204562:	90a68693          	addi	a3,a3,-1782 # ffffffffc0207e68 <default_pmm_manager+0x2c0>
ffffffffc0204566:	00002617          	auipc	a2,0x2
ffffffffc020456a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206b50 <commands+0x410>
ffffffffc020456e:	1fe00593          	li	a1,510
ffffffffc0204572:	00003517          	auipc	a0,0x3
ffffffffc0204576:	66e50513          	addi	a0,a0,1646 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020457a:	c8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020457e:	00004697          	auipc	a3,0x4
ffffffffc0204582:	84268693          	addi	a3,a3,-1982 # ffffffffc0207dc0 <default_pmm_manager+0x218>
ffffffffc0204586:	00002617          	auipc	a2,0x2
ffffffffc020458a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0206b50 <commands+0x410>
ffffffffc020458e:	20b00593          	li	a1,523
ffffffffc0204592:	00003517          	auipc	a0,0x3
ffffffffc0204596:	64e50513          	addi	a0,a0,1614 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020459a:	c6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020459e:	00004697          	auipc	a3,0x4
ffffffffc02045a2:	97a68693          	addi	a3,a3,-1670 # ffffffffc0207f18 <default_pmm_manager+0x370>
ffffffffc02045a6:	00002617          	auipc	a2,0x2
ffffffffc02045aa:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206b50 <commands+0x410>
ffffffffc02045ae:	20800593          	li	a1,520
ffffffffc02045b2:	00003517          	auipc	a0,0x3
ffffffffc02045b6:	62e50513          	addi	a0,a0,1582 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02045ba:	c4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02045be:	00003697          	auipc	a3,0x3
ffffffffc02045c2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0207da8 <default_pmm_manager+0x200>
ffffffffc02045c6:	00002617          	auipc	a2,0x2
ffffffffc02045ca:	58a60613          	addi	a2,a2,1418 # ffffffffc0206b50 <commands+0x410>
ffffffffc02045ce:	20700593          	li	a1,519
ffffffffc02045d2:	00003517          	auipc	a0,0x3
ffffffffc02045d6:	60e50513          	addi	a0,a0,1550 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02045da:	c2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02045de:	00003617          	auipc	a2,0x3
ffffffffc02045e2:	b4260613          	addi	a2,a2,-1214 # ffffffffc0207120 <commands+0x9e0>
ffffffffc02045e6:	06900593          	li	a1,105
ffffffffc02045ea:	00003517          	auipc	a0,0x3
ffffffffc02045ee:	b2650513          	addi	a0,a0,-1242 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02045f2:	c17fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02045f6:	00004697          	auipc	a3,0x4
ffffffffc02045fa:	95268693          	addi	a3,a3,-1710 # ffffffffc0207f48 <default_pmm_manager+0x3a0>
ffffffffc02045fe:	00002617          	auipc	a2,0x2
ffffffffc0204602:	55260613          	addi	a2,a2,1362 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204606:	21200593          	li	a1,530
ffffffffc020460a:	00003517          	auipc	a0,0x3
ffffffffc020460e:	5d650513          	addi	a0,a0,1494 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204612:	bf7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204616:	00004697          	auipc	a3,0x4
ffffffffc020461a:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0207f00 <default_pmm_manager+0x358>
ffffffffc020461e:	00002617          	auipc	a2,0x2
ffffffffc0204622:	53260613          	addi	a2,a2,1330 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204626:	21000593          	li	a1,528
ffffffffc020462a:	00003517          	auipc	a0,0x3
ffffffffc020462e:	5b650513          	addi	a0,a0,1462 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204632:	bd7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0204636:	00004697          	auipc	a3,0x4
ffffffffc020463a:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0207f30 <default_pmm_manager+0x388>
ffffffffc020463e:	00002617          	auipc	a2,0x2
ffffffffc0204642:	51260613          	addi	a2,a2,1298 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204646:	20f00593          	li	a1,527
ffffffffc020464a:	00003517          	auipc	a0,0x3
ffffffffc020464e:	59650513          	addi	a0,a0,1430 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204652:	bb7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204656:	00004697          	auipc	a3,0x4
ffffffffc020465a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207f00 <default_pmm_manager+0x358>
ffffffffc020465e:	00002617          	auipc	a2,0x2
ffffffffc0204662:	4f260613          	addi	a2,a2,1266 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204666:	20c00593          	li	a1,524
ffffffffc020466a:	00003517          	auipc	a0,0x3
ffffffffc020466e:	57650513          	addi	a0,a0,1398 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204672:	b97fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204676:	00004697          	auipc	a3,0x4
ffffffffc020467a:	9e268693          	addi	a3,a3,-1566 # ffffffffc0208058 <default_pmm_manager+0x4b0>
ffffffffc020467e:	00002617          	auipc	a2,0x2
ffffffffc0204682:	4d260613          	addi	a2,a2,1234 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204686:	23100593          	li	a1,561
ffffffffc020468a:	00003517          	auipc	a0,0x3
ffffffffc020468e:	55650513          	addi	a0,a0,1366 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204692:	b77fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204696:	00004697          	auipc	a3,0x4
ffffffffc020469a:	98a68693          	addi	a3,a3,-1654 # ffffffffc0208020 <default_pmm_manager+0x478>
ffffffffc020469e:	00002617          	auipc	a2,0x2
ffffffffc02046a2:	4b260613          	addi	a2,a2,1202 # ffffffffc0206b50 <commands+0x410>
ffffffffc02046a6:	23000593          	li	a1,560
ffffffffc02046aa:	00003517          	auipc	a0,0x3
ffffffffc02046ae:	53650513          	addi	a0,a0,1334 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02046b2:	b57fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02046b6:	00004697          	auipc	a3,0x4
ffffffffc02046ba:	95268693          	addi	a3,a3,-1710 # ffffffffc0208008 <default_pmm_manager+0x460>
ffffffffc02046be:	00002617          	auipc	a2,0x2
ffffffffc02046c2:	49260613          	addi	a2,a2,1170 # ffffffffc0206b50 <commands+0x410>
ffffffffc02046c6:	22c00593          	li	a1,556
ffffffffc02046ca:	00003517          	auipc	a0,0x3
ffffffffc02046ce:	51650513          	addi	a0,a0,1302 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02046d2:	b37fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02046d6:	00004697          	auipc	a3,0x4
ffffffffc02046da:	89a68693          	addi	a3,a3,-1894 # ffffffffc0207f70 <default_pmm_manager+0x3c8>
ffffffffc02046de:	00002617          	auipc	a2,0x2
ffffffffc02046e2:	47260613          	addi	a2,a2,1138 # ffffffffc0206b50 <commands+0x410>
ffffffffc02046e6:	21a00593          	li	a1,538
ffffffffc02046ea:	00003517          	auipc	a0,0x3
ffffffffc02046ee:	4f650513          	addi	a0,a0,1270 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02046f2:	b17fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02046f6:	00003697          	auipc	a3,0x3
ffffffffc02046fa:	6b268693          	addi	a3,a3,1714 # ffffffffc0207da8 <default_pmm_manager+0x200>
ffffffffc02046fe:	00002617          	auipc	a2,0x2
ffffffffc0204702:	45260613          	addi	a2,a2,1106 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204706:	1f400593          	li	a1,500
ffffffffc020470a:	00003517          	auipc	a0,0x3
ffffffffc020470e:	4d650513          	addi	a0,a0,1238 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204712:	af7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204716:	00003617          	auipc	a2,0x3
ffffffffc020471a:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0207120 <commands+0x9e0>
ffffffffc020471e:	1f700593          	li	a1,503
ffffffffc0204722:	00003517          	auipc	a0,0x3
ffffffffc0204726:	4be50513          	addi	a0,a0,1214 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020472a:	adffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020472e:	00003697          	auipc	a3,0x3
ffffffffc0204732:	69268693          	addi	a3,a3,1682 # ffffffffc0207dc0 <default_pmm_manager+0x218>
ffffffffc0204736:	00002617          	auipc	a2,0x2
ffffffffc020473a:	41a60613          	addi	a2,a2,1050 # ffffffffc0206b50 <commands+0x410>
ffffffffc020473e:	1f500593          	li	a1,501
ffffffffc0204742:	00003517          	auipc	a0,0x3
ffffffffc0204746:	49e50513          	addi	a0,a0,1182 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020474a:	abffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020474e:	00003697          	auipc	a3,0x3
ffffffffc0204752:	6ea68693          	addi	a3,a3,1770 # ffffffffc0207e38 <default_pmm_manager+0x290>
ffffffffc0204756:	00002617          	auipc	a2,0x2
ffffffffc020475a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206b50 <commands+0x410>
ffffffffc020475e:	1fd00593          	li	a1,509
ffffffffc0204762:	00003517          	auipc	a0,0x3
ffffffffc0204766:	47e50513          	addi	a0,a0,1150 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020476a:	a9ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020476e:	00004697          	auipc	a3,0x4
ffffffffc0204772:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0208118 <default_pmm_manager+0x570>
ffffffffc0204776:	00002617          	auipc	a2,0x2
ffffffffc020477a:	3da60613          	addi	a2,a2,986 # ffffffffc0206b50 <commands+0x410>
ffffffffc020477e:	23a00593          	li	a1,570
ffffffffc0204782:	00003517          	auipc	a0,0x3
ffffffffc0204786:	45e50513          	addi	a0,a0,1118 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020478a:	a7ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020478e:	00004697          	auipc	a3,0x4
ffffffffc0204792:	95268693          	addi	a3,a3,-1710 # ffffffffc02080e0 <default_pmm_manager+0x538>
ffffffffc0204796:	00002617          	auipc	a2,0x2
ffffffffc020479a:	3ba60613          	addi	a2,a2,954 # ffffffffc0206b50 <commands+0x410>
ffffffffc020479e:	23700593          	li	a1,567
ffffffffc02047a2:	00003517          	auipc	a0,0x3
ffffffffc02047a6:	43e50513          	addi	a0,a0,1086 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02047aa:	a5ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02047ae:	00004697          	auipc	a3,0x4
ffffffffc02047b2:	90268693          	addi	a3,a3,-1790 # ffffffffc02080b0 <default_pmm_manager+0x508>
ffffffffc02047b6:	00002617          	auipc	a2,0x2
ffffffffc02047ba:	39a60613          	addi	a2,a2,922 # ffffffffc0206b50 <commands+0x410>
ffffffffc02047be:	23300593          	li	a1,563
ffffffffc02047c2:	00003517          	auipc	a0,0x3
ffffffffc02047c6:	41e50513          	addi	a0,a0,1054 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02047ca:	a3ffb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02047ce <copy_range>:
               bool share) {
ffffffffc02047ce:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02047d0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02047d4:	f486                	sd	ra,104(sp)
ffffffffc02047d6:	f0a2                	sd	s0,96(sp)
ffffffffc02047d8:	eca6                	sd	s1,88(sp)
ffffffffc02047da:	e8ca                	sd	s2,80(sp)
ffffffffc02047dc:	e4ce                	sd	s3,72(sp)
ffffffffc02047de:	e0d2                	sd	s4,64(sp)
ffffffffc02047e0:	fc56                	sd	s5,56(sp)
ffffffffc02047e2:	f85a                	sd	s6,48(sp)
ffffffffc02047e4:	f45e                	sd	s7,40(sp)
ffffffffc02047e6:	f062                	sd	s8,32(sp)
ffffffffc02047e8:	ec66                	sd	s9,24(sp)
ffffffffc02047ea:	e86a                	sd	s10,16(sp)
ffffffffc02047ec:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02047ee:	17d2                	slli	a5,a5,0x34
ffffffffc02047f0:	1e079763          	bnez	a5,ffffffffc02049de <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02047f4:	002007b7          	lui	a5,0x200
ffffffffc02047f8:	8432                	mv	s0,a2
ffffffffc02047fa:	16f66a63          	bltu	a2,a5,ffffffffc020496e <copy_range+0x1a0>
ffffffffc02047fe:	8936                	mv	s2,a3
ffffffffc0204800:	16d67763          	bgeu	a2,a3,ffffffffc020496e <copy_range+0x1a0>
ffffffffc0204804:	4785                	li	a5,1
ffffffffc0204806:	07fe                	slli	a5,a5,0x1f
ffffffffc0204808:	16d7e363          	bltu	a5,a3,ffffffffc020496e <copy_range+0x1a0>
ffffffffc020480c:	5b7d                	li	s6,-1
ffffffffc020480e:	8aaa                	mv	s5,a0
ffffffffc0204810:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0204812:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0204814:	000aec97          	auipc	s9,0xae
ffffffffc0204818:	03cc8c93          	addi	s9,s9,60 # ffffffffc02b2850 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020481c:	000aec17          	auipc	s8,0xae
ffffffffc0204820:	03cc0c13          	addi	s8,s8,60 # ffffffffc02b2858 <pages>
    return page - pages + nbase;
ffffffffc0204824:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc0204828:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020482c:	4601                	li	a2,0
ffffffffc020482e:	85a2                	mv	a1,s0
ffffffffc0204830:	854e                	mv	a0,s3
ffffffffc0204832:	c73fe0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0204836:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0204838:	c175                	beqz	a0,ffffffffc020491c <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc020483a:	611c                	ld	a5,0(a0)
ffffffffc020483c:	8b85                	andi	a5,a5,1
ffffffffc020483e:	e785                	bnez	a5,ffffffffc0204866 <copy_range+0x98>
        start += PGSIZE;
ffffffffc0204840:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0204842:	ff2465e3          	bltu	s0,s2,ffffffffc020482c <copy_range+0x5e>
    return 0;
ffffffffc0204846:	4501                	li	a0,0
}
ffffffffc0204848:	70a6                	ld	ra,104(sp)
ffffffffc020484a:	7406                	ld	s0,96(sp)
ffffffffc020484c:	64e6                	ld	s1,88(sp)
ffffffffc020484e:	6946                	ld	s2,80(sp)
ffffffffc0204850:	69a6                	ld	s3,72(sp)
ffffffffc0204852:	6a06                	ld	s4,64(sp)
ffffffffc0204854:	7ae2                	ld	s5,56(sp)
ffffffffc0204856:	7b42                	ld	s6,48(sp)
ffffffffc0204858:	7ba2                	ld	s7,40(sp)
ffffffffc020485a:	7c02                	ld	s8,32(sp)
ffffffffc020485c:	6ce2                	ld	s9,24(sp)
ffffffffc020485e:	6d42                	ld	s10,16(sp)
ffffffffc0204860:	6da2                	ld	s11,8(sp)
ffffffffc0204862:	6165                	addi	sp,sp,112
ffffffffc0204864:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0204866:	4605                	li	a2,1
ffffffffc0204868:	85a2                	mv	a1,s0
ffffffffc020486a:	8556                	mv	a0,s5
ffffffffc020486c:	c39fe0ef          	jal	ra,ffffffffc02034a4 <get_pte>
ffffffffc0204870:	c161                	beqz	a0,ffffffffc0204930 <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204872:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0204874:	0017f713          	andi	a4,a5,1
ffffffffc0204878:	01f7f493          	andi	s1,a5,31
ffffffffc020487c:	14070563          	beqz	a4,ffffffffc02049c6 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc0204880:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204884:	078a                	slli	a5,a5,0x2
ffffffffc0204886:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020488a:	12d77263          	bgeu	a4,a3,ffffffffc02049ae <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc020488e:	000c3783          	ld	a5,0(s8)
ffffffffc0204892:	fff806b7          	lui	a3,0xfff80
ffffffffc0204896:	9736                	add	a4,a4,a3
ffffffffc0204898:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020489a:	4505                	li	a0,1
ffffffffc020489c:	00e78db3          	add	s11,a5,a4
ffffffffc02048a0:	af9fe0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc02048a4:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02048a6:	0a0d8463          	beqz	s11,ffffffffc020494e <copy_range+0x180>
            assert(npage != NULL);
ffffffffc02048aa:	c175                	beqz	a0,ffffffffc020498e <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc02048ac:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc02048b0:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02048b4:	40ed86b3          	sub	a3,s11,a4
ffffffffc02048b8:	8699                	srai	a3,a3,0x6
ffffffffc02048ba:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02048bc:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02048c0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02048c2:	06c7fa63          	bgeu	a5,a2,ffffffffc0204936 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc02048c6:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02048ca:	000ae717          	auipc	a4,0xae
ffffffffc02048ce:	f9e70713          	addi	a4,a4,-98 # ffffffffc02b2868 <va_pa_offset>
ffffffffc02048d2:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02048d4:	8799                	srai	a5,a5,0x6
ffffffffc02048d6:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc02048d8:	0167f733          	and	a4,a5,s6
ffffffffc02048dc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02048e0:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02048e2:	04c77963          	bgeu	a4,a2,ffffffffc0204934 <copy_range+0x166>
            memcpy(dst, src, PGSIZE);
ffffffffc02048e6:	6605                	lui	a2,0x1
ffffffffc02048e8:	953e                	add	a0,a0,a5
ffffffffc02048ea:	790010ef          	jal	ra,ffffffffc020607a <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02048ee:	86a6                	mv	a3,s1
ffffffffc02048f0:	8622                	mv	a2,s0
ffffffffc02048f2:	85ea                	mv	a1,s10
ffffffffc02048f4:	8556                	mv	a0,s5
ffffffffc02048f6:	a48ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
            assert(ret == 0);
ffffffffc02048fa:	d139                	beqz	a0,ffffffffc0204840 <copy_range+0x72>
ffffffffc02048fc:	00004697          	auipc	a3,0x4
ffffffffc0204900:	88468693          	addi	a3,a3,-1916 # ffffffffc0208180 <default_pmm_manager+0x5d8>
ffffffffc0204904:	00002617          	auipc	a2,0x2
ffffffffc0204908:	24c60613          	addi	a2,a2,588 # ffffffffc0206b50 <commands+0x410>
ffffffffc020490c:	18c00593          	li	a1,396
ffffffffc0204910:	00003517          	auipc	a0,0x3
ffffffffc0204914:	2d050513          	addi	a0,a0,720 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204918:	8f1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020491c:	00200637          	lui	a2,0x200
ffffffffc0204920:	9432                	add	s0,s0,a2
ffffffffc0204922:	ffe00637          	lui	a2,0xffe00
ffffffffc0204926:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0204928:	dc19                	beqz	s0,ffffffffc0204846 <copy_range+0x78>
ffffffffc020492a:	f12461e3          	bltu	s0,s2,ffffffffc020482c <copy_range+0x5e>
ffffffffc020492e:	bf21                	j	ffffffffc0204846 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc0204930:	5571                	li	a0,-4
ffffffffc0204932:	bf19                	j	ffffffffc0204848 <copy_range+0x7a>
ffffffffc0204934:	86be                	mv	a3,a5
ffffffffc0204936:	00002617          	auipc	a2,0x2
ffffffffc020493a:	7ea60613          	addi	a2,a2,2026 # ffffffffc0207120 <commands+0x9e0>
ffffffffc020493e:	06900593          	li	a1,105
ffffffffc0204942:	00002517          	auipc	a0,0x2
ffffffffc0204946:	7ce50513          	addi	a0,a0,1998 # ffffffffc0207110 <commands+0x9d0>
ffffffffc020494a:	8bffb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc020494e:	00004697          	auipc	a3,0x4
ffffffffc0204952:	81268693          	addi	a3,a3,-2030 # ffffffffc0208160 <default_pmm_manager+0x5b8>
ffffffffc0204956:	00002617          	auipc	a2,0x2
ffffffffc020495a:	1fa60613          	addi	a2,a2,506 # ffffffffc0206b50 <commands+0x410>
ffffffffc020495e:	17200593          	li	a1,370
ffffffffc0204962:	00003517          	auipc	a0,0x3
ffffffffc0204966:	27e50513          	addi	a0,a0,638 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020496a:	89ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020496e:	00003697          	auipc	a3,0x3
ffffffffc0204972:	2b268693          	addi	a3,a3,690 # ffffffffc0207c20 <default_pmm_manager+0x78>
ffffffffc0204976:	00002617          	auipc	a2,0x2
ffffffffc020497a:	1da60613          	addi	a2,a2,474 # ffffffffc0206b50 <commands+0x410>
ffffffffc020497e:	15e00593          	li	a1,350
ffffffffc0204982:	00003517          	auipc	a0,0x3
ffffffffc0204986:	25e50513          	addi	a0,a0,606 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc020498a:	87ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc020498e:	00003697          	auipc	a3,0x3
ffffffffc0204992:	7e268693          	addi	a3,a3,2018 # ffffffffc0208170 <default_pmm_manager+0x5c8>
ffffffffc0204996:	00002617          	auipc	a2,0x2
ffffffffc020499a:	1ba60613          	addi	a2,a2,442 # ffffffffc0206b50 <commands+0x410>
ffffffffc020499e:	17300593          	li	a1,371
ffffffffc02049a2:	00003517          	auipc	a0,0x3
ffffffffc02049a6:	23e50513          	addi	a0,a0,574 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02049aa:	85ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049ae:	00002617          	auipc	a2,0x2
ffffffffc02049b2:	74260613          	addi	a2,a2,1858 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc02049b6:	06200593          	li	a1,98
ffffffffc02049ba:	00002517          	auipc	a0,0x2
ffffffffc02049be:	75650513          	addi	a0,a0,1878 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02049c2:	847fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02049c6:	00003617          	auipc	a2,0x3
ffffffffc02049ca:	ab260613          	addi	a2,a2,-1358 # ffffffffc0207478 <commands+0xd38>
ffffffffc02049ce:	07400593          	li	a1,116
ffffffffc02049d2:	00002517          	auipc	a0,0x2
ffffffffc02049d6:	73e50513          	addi	a0,a0,1854 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02049da:	82ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02049de:	00003697          	auipc	a3,0x3
ffffffffc02049e2:	21268693          	addi	a3,a3,530 # ffffffffc0207bf0 <default_pmm_manager+0x48>
ffffffffc02049e6:	00002617          	auipc	a2,0x2
ffffffffc02049ea:	16a60613          	addi	a2,a2,362 # ffffffffc0206b50 <commands+0x410>
ffffffffc02049ee:	15d00593          	li	a1,349
ffffffffc02049f2:	00003517          	auipc	a0,0x3
ffffffffc02049f6:	1ee50513          	addi	a0,a0,494 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc02049fa:	80ffb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02049fe <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02049fe:	12058073          	sfence.vma	a1
}
ffffffffc0204a02:	8082                	ret

ffffffffc0204a04 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a04:	7179                	addi	sp,sp,-48
ffffffffc0204a06:	e84a                	sd	s2,16(sp)
ffffffffc0204a08:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204a0a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a0c:	f022                	sd	s0,32(sp)
ffffffffc0204a0e:	ec26                	sd	s1,24(sp)
ffffffffc0204a10:	e44e                	sd	s3,8(sp)
ffffffffc0204a12:	f406                	sd	ra,40(sp)
ffffffffc0204a14:	84ae                	mv	s1,a1
ffffffffc0204a16:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204a18:	981fe0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc0204a1c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204a1e:	cd05                	beqz	a0,ffffffffc0204a56 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204a20:	85aa                	mv	a1,a0
ffffffffc0204a22:	86ce                	mv	a3,s3
ffffffffc0204a24:	8626                	mv	a2,s1
ffffffffc0204a26:	854a                	mv	a0,s2
ffffffffc0204a28:	916ff0ef          	jal	ra,ffffffffc0203b3e <page_insert>
ffffffffc0204a2c:	ed0d                	bnez	a0,ffffffffc0204a66 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204a2e:	000ae797          	auipc	a5,0xae
ffffffffc0204a32:	e027a783          	lw	a5,-510(a5) # ffffffffc02b2830 <swap_init_ok>
ffffffffc0204a36:	c385                	beqz	a5,ffffffffc0204a56 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204a38:	000ae517          	auipc	a0,0xae
ffffffffc0204a3c:	dd853503          	ld	a0,-552(a0) # ffffffffc02b2810 <check_mm_struct>
ffffffffc0204a40:	c919                	beqz	a0,ffffffffc0204a56 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204a42:	4681                	li	a3,0
ffffffffc0204a44:	8622                	mv	a2,s0
ffffffffc0204a46:	85a6                	mv	a1,s1
ffffffffc0204a48:	d70fd0ef          	jal	ra,ffffffffc0201fb8 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204a4c:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204a4e:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204a50:	4785                	li	a5,1
ffffffffc0204a52:	04f71663          	bne	a4,a5,ffffffffc0204a9e <pgdir_alloc_page+0x9a>
}
ffffffffc0204a56:	70a2                	ld	ra,40(sp)
ffffffffc0204a58:	8522                	mv	a0,s0
ffffffffc0204a5a:	7402                	ld	s0,32(sp)
ffffffffc0204a5c:	64e2                	ld	s1,24(sp)
ffffffffc0204a5e:	6942                	ld	s2,16(sp)
ffffffffc0204a60:	69a2                	ld	s3,8(sp)
ffffffffc0204a62:	6145                	addi	sp,sp,48
ffffffffc0204a64:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a66:	100027f3          	csrr	a5,sstatus
ffffffffc0204a6a:	8b89                	andi	a5,a5,2
ffffffffc0204a6c:	eb99                	bnez	a5,ffffffffc0204a82 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204a6e:	000ae797          	auipc	a5,0xae
ffffffffc0204a72:	df27b783          	ld	a5,-526(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0204a76:	739c                	ld	a5,32(a5)
ffffffffc0204a78:	8522                	mv	a0,s0
ffffffffc0204a7a:	4585                	li	a1,1
ffffffffc0204a7c:	9782                	jalr	a5
            return NULL;
ffffffffc0204a7e:	4401                	li	s0,0
ffffffffc0204a80:	bfd9                	j	ffffffffc0204a56 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204a82:	ba3fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204a86:	000ae797          	auipc	a5,0xae
ffffffffc0204a8a:	dda7b783          	ld	a5,-550(a5) # ffffffffc02b2860 <pmm_manager>
ffffffffc0204a8e:	739c                	ld	a5,32(a5)
ffffffffc0204a90:	8522                	mv	a0,s0
ffffffffc0204a92:	4585                	li	a1,1
ffffffffc0204a94:	9782                	jalr	a5
            return NULL;
ffffffffc0204a96:	4401                	li	s0,0
        intr_enable();
ffffffffc0204a98:	b87fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204a9c:	bf6d                	j	ffffffffc0204a56 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204a9e:	00003697          	auipc	a3,0x3
ffffffffc0204aa2:	6f268693          	addi	a3,a3,1778 # ffffffffc0208190 <default_pmm_manager+0x5e8>
ffffffffc0204aa6:	00002617          	auipc	a2,0x2
ffffffffc0204aaa:	0aa60613          	addi	a2,a2,170 # ffffffffc0206b50 <commands+0x410>
ffffffffc0204aae:	1cb00593          	li	a1,459
ffffffffc0204ab2:	00003517          	auipc	a0,0x3
ffffffffc0204ab6:	12e50513          	addi	a0,a0,302 # ffffffffc0207be0 <default_pmm_manager+0x38>
ffffffffc0204aba:	f4efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204abe <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204abe:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ac0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204ac2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ac4:	a65fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204ac8:	cd01                	beqz	a0,ffffffffc0204ae0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204aca:	4505                	li	a0,1
ffffffffc0204acc:	a63fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204ad0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ad2:	810d                	srli	a0,a0,0x3
ffffffffc0204ad4:	000ae797          	auipc	a5,0xae
ffffffffc0204ad8:	d4a7b623          	sd	a0,-692(a5) # ffffffffc02b2820 <max_swap_offset>
}
ffffffffc0204adc:	0141                	addi	sp,sp,16
ffffffffc0204ade:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204ae0:	00003617          	auipc	a2,0x3
ffffffffc0204ae4:	6c860613          	addi	a2,a2,1736 # ffffffffc02081a8 <default_pmm_manager+0x600>
ffffffffc0204ae8:	45b5                	li	a1,13
ffffffffc0204aea:	00003517          	auipc	a0,0x3
ffffffffc0204aee:	6de50513          	addi	a0,a0,1758 # ffffffffc02081c8 <default_pmm_manager+0x620>
ffffffffc0204af2:	f16fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204af6 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204af6:	1141                	addi	sp,sp,-16
ffffffffc0204af8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204afa:	00855793          	srli	a5,a0,0x8
ffffffffc0204afe:	cbb1                	beqz	a5,ffffffffc0204b52 <swapfs_write+0x5c>
ffffffffc0204b00:	000ae717          	auipc	a4,0xae
ffffffffc0204b04:	d2073703          	ld	a4,-736(a4) # ffffffffc02b2820 <max_swap_offset>
ffffffffc0204b08:	04e7f563          	bgeu	a5,a4,ffffffffc0204b52 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204b0c:	000ae617          	auipc	a2,0xae
ffffffffc0204b10:	d4c63603          	ld	a2,-692(a2) # ffffffffc02b2858 <pages>
ffffffffc0204b14:	8d91                	sub	a1,a1,a2
ffffffffc0204b16:	4065d613          	srai	a2,a1,0x6
ffffffffc0204b1a:	00004717          	auipc	a4,0x4
ffffffffc0204b1e:	00673703          	ld	a4,6(a4) # ffffffffc0208b20 <nbase>
ffffffffc0204b22:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204b24:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b28:	8331                	srli	a4,a4,0xc
ffffffffc0204b2a:	000ae697          	auipc	a3,0xae
ffffffffc0204b2e:	d266b683          	ld	a3,-730(a3) # ffffffffc02b2850 <npage>
ffffffffc0204b32:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b36:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b38:	02d77963          	bgeu	a4,a3,ffffffffc0204b6a <swapfs_write+0x74>
}
ffffffffc0204b3c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b3e:	000ae797          	auipc	a5,0xae
ffffffffc0204b42:	d2a7b783          	ld	a5,-726(a5) # ffffffffc02b2868 <va_pa_offset>
ffffffffc0204b46:	46a1                	li	a3,8
ffffffffc0204b48:	963e                	add	a2,a2,a5
ffffffffc0204b4a:	4505                	li	a0,1
}
ffffffffc0204b4c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b4e:	9e7fb06f          	j	ffffffffc0200534 <ide_write_secs>
ffffffffc0204b52:	86aa                	mv	a3,a0
ffffffffc0204b54:	00003617          	auipc	a2,0x3
ffffffffc0204b58:	68c60613          	addi	a2,a2,1676 # ffffffffc02081e0 <default_pmm_manager+0x638>
ffffffffc0204b5c:	45e5                	li	a1,25
ffffffffc0204b5e:	00003517          	auipc	a0,0x3
ffffffffc0204b62:	66a50513          	addi	a0,a0,1642 # ffffffffc02081c8 <default_pmm_manager+0x620>
ffffffffc0204b66:	ea2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204b6a:	86b2                	mv	a3,a2
ffffffffc0204b6c:	06900593          	li	a1,105
ffffffffc0204b70:	00002617          	auipc	a2,0x2
ffffffffc0204b74:	5b060613          	addi	a2,a2,1456 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0204b78:	00002517          	auipc	a0,0x2
ffffffffc0204b7c:	59850513          	addi	a0,a0,1432 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0204b80:	e88fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b84 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204b84:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204b88:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204b8c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204b8e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204b90:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204b94:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204b98:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204b9c:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204ba0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204ba4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ba8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204bac:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204bb0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204bb4:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204bb8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204bbc:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204bc0:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204bc2:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204bc4:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204bc8:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204bcc:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204bd0:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204bd4:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204bd8:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204bdc:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204be0:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204be4:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204be8:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204bec:	8082                	ret

ffffffffc0204bee <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204bee:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204bf0:	9402                	jalr	s0

	jal do_exit
ffffffffc0204bf2:	642000ef          	jal	ra,ffffffffc0205234 <do_exit>

ffffffffc0204bf6 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204bf6:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204bf8:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204bfc:	e022                	sd	s0,0(sp)
ffffffffc0204bfe:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c00:	f0afd0ef          	jal	ra,ffffffffc020230a <kmalloc>
ffffffffc0204c04:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c06:	cd21                	beqz	a0,ffffffffc0204c5e <alloc_proc+0x68>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204c08:	57fd                	li	a5,-1
ffffffffc0204c0a:	1782                	slli	a5,a5,0x20
ffffffffc0204c0c:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c0e:	07000613          	li	a2,112
ffffffffc0204c12:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204c14:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204c18:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204c1c:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204c20:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204c24:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c28:	03050513          	addi	a0,a0,48
ffffffffc0204c2c:	43c010ef          	jal	ra,ffffffffc0206068 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204c30:	000ae797          	auipc	a5,0xae
ffffffffc0204c34:	c107b783          	ld	a5,-1008(a5) # ffffffffc02b2840 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204c38:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204c3c:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0204c3e:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204c42:	463d                	li	a2,15
ffffffffc0204c44:	4581                	li	a1,0
ffffffffc0204c46:	0b440513          	addi	a0,s0,180
ffffffffc0204c4a:	41e010ef          	jal	ra,ffffffffc0206068 <memset>
        proc->wait_state = 0;
ffffffffc0204c4e:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204c52:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc0204c56:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc0204c5a:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0204c5e:	60a2                	ld	ra,8(sp)
ffffffffc0204c60:	8522                	mv	a0,s0
ffffffffc0204c62:	6402                	ld	s0,0(sp)
ffffffffc0204c64:	0141                	addi	sp,sp,16
ffffffffc0204c66:	8082                	ret

ffffffffc0204c68 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204c68:	000ae797          	auipc	a5,0xae
ffffffffc0204c6c:	c087b783          	ld	a5,-1016(a5) # ffffffffc02b2870 <current>
ffffffffc0204c70:	73c8                	ld	a0,160(a5)
ffffffffc0204c72:	8e0fc06f          	j	ffffffffc0200d52 <forkrets>

ffffffffc0204c76 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c76:	000ae797          	auipc	a5,0xae
ffffffffc0204c7a:	bfa7b783          	ld	a5,-1030(a5) # ffffffffc02b2870 <current>
ffffffffc0204c7e:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204c80:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c82:	00003617          	auipc	a2,0x3
ffffffffc0204c86:	57e60613          	addi	a2,a2,1406 # ffffffffc0208200 <default_pmm_manager+0x658>
ffffffffc0204c8a:	00003517          	auipc	a0,0x3
ffffffffc0204c8e:	58650513          	addi	a0,a0,1414 # ffffffffc0208210 <default_pmm_manager+0x668>
user_main(void *arg) {
ffffffffc0204c92:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c94:	c38fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204c98:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204c9c:	cd878793          	addi	a5,a5,-808 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc0204ca0:	e43e                	sd	a5,8(sp)
ffffffffc0204ca2:	00003517          	auipc	a0,0x3
ffffffffc0204ca6:	55e50513          	addi	a0,a0,1374 # ffffffffc0208200 <default_pmm_manager+0x658>
ffffffffc0204caa:	00098797          	auipc	a5,0x98
ffffffffc0204cae:	cb678793          	addi	a5,a5,-842 # ffffffffc029c960 <_binary_obj___user_forktest_out_start>
ffffffffc0204cb2:	f03e                	sd	a5,32(sp)
ffffffffc0204cb4:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204cb6:	e802                	sd	zero,16(sp)
ffffffffc0204cb8:	334010ef          	jal	ra,ffffffffc0205fec <strlen>
ffffffffc0204cbc:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204cbe:	4511                	li	a0,4
ffffffffc0204cc0:	55a2                	lw	a1,40(sp)
ffffffffc0204cc2:	4662                	lw	a2,24(sp)
ffffffffc0204cc4:	5682                	lw	a3,32(sp)
ffffffffc0204cc6:	4722                	lw	a4,8(sp)
ffffffffc0204cc8:	48a9                	li	a7,10
ffffffffc0204cca:	9002                	ebreak
ffffffffc0204ccc:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204cce:	65c2                	ld	a1,16(sp)
ffffffffc0204cd0:	00003517          	auipc	a0,0x3
ffffffffc0204cd4:	56850513          	addi	a0,a0,1384 # ffffffffc0208238 <default_pmm_manager+0x690>
ffffffffc0204cd8:	bf4fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204cdc:	00003617          	auipc	a2,0x3
ffffffffc0204ce0:	56c60613          	addi	a2,a2,1388 # ffffffffc0208248 <default_pmm_manager+0x6a0>
ffffffffc0204ce4:	35500593          	li	a1,853
ffffffffc0204ce8:	00003517          	auipc	a0,0x3
ffffffffc0204cec:	58050513          	addi	a0,a0,1408 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0204cf0:	d18fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cf4 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204cf4:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204cf6:	1141                	addi	sp,sp,-16
ffffffffc0204cf8:	e406                	sd	ra,8(sp)
ffffffffc0204cfa:	c02007b7          	lui	a5,0xc0200
ffffffffc0204cfe:	02f6ee63          	bltu	a3,a5,ffffffffc0204d3a <put_pgdir+0x46>
ffffffffc0204d02:	000ae517          	auipc	a0,0xae
ffffffffc0204d06:	b6653503          	ld	a0,-1178(a0) # ffffffffc02b2868 <va_pa_offset>
ffffffffc0204d0a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204d0c:	82b1                	srli	a3,a3,0xc
ffffffffc0204d0e:	000ae797          	auipc	a5,0xae
ffffffffc0204d12:	b427b783          	ld	a5,-1214(a5) # ffffffffc02b2850 <npage>
ffffffffc0204d16:	02f6fe63          	bgeu	a3,a5,ffffffffc0204d52 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d1a:	00004517          	auipc	a0,0x4
ffffffffc0204d1e:	e0653503          	ld	a0,-506(a0) # ffffffffc0208b20 <nbase>
}
ffffffffc0204d22:	60a2                	ld	ra,8(sp)
ffffffffc0204d24:	8e89                	sub	a3,a3,a0
ffffffffc0204d26:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204d28:	000ae517          	auipc	a0,0xae
ffffffffc0204d2c:	b3053503          	ld	a0,-1232(a0) # ffffffffc02b2858 <pages>
ffffffffc0204d30:	4585                	li	a1,1
ffffffffc0204d32:	9536                	add	a0,a0,a3
}
ffffffffc0204d34:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204d36:	ef4fe06f          	j	ffffffffc020342a <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204d3a:	00003617          	auipc	a2,0x3
ffffffffc0204d3e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0207648 <commands+0xf08>
ffffffffc0204d42:	06e00593          	li	a1,110
ffffffffc0204d46:	00002517          	auipc	a0,0x2
ffffffffc0204d4a:	3ca50513          	addi	a0,a0,970 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0204d4e:	cbafb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204d52:	00002617          	auipc	a2,0x2
ffffffffc0204d56:	39e60613          	addi	a2,a2,926 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc0204d5a:	06200593          	li	a1,98
ffffffffc0204d5e:	00002517          	auipc	a0,0x2
ffffffffc0204d62:	3b250513          	addi	a0,a0,946 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0204d66:	ca2fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d6a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204d6a:	7179                	addi	sp,sp,-48
ffffffffc0204d6c:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204d6e:	000ae917          	auipc	s2,0xae
ffffffffc0204d72:	b0290913          	addi	s2,s2,-1278 # ffffffffc02b2870 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204d76:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204d78:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204d7c:	f406                	sd	ra,40(sp)
ffffffffc0204d7e:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204d80:	02a48863          	beq	s1,a0,ffffffffc0204db0 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d84:	100027f3          	csrr	a5,sstatus
ffffffffc0204d88:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d8a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d8c:	ef9d                	bnez	a5,ffffffffc0204dca <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204d8e:	755c                	ld	a5,168(a0)
ffffffffc0204d90:	577d                	li	a4,-1
ffffffffc0204d92:	177e                	slli	a4,a4,0x3f
ffffffffc0204d94:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204d96:	00a93023          	sd	a0,0(s2)
ffffffffc0204d9a:	8fd9                	or	a5,a5,a4
ffffffffc0204d9c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204da0:	03050593          	addi	a1,a0,48
ffffffffc0204da4:	03048513          	addi	a0,s1,48
ffffffffc0204da8:	dddff0ef          	jal	ra,ffffffffc0204b84 <switch_to>
    if (flag) {
ffffffffc0204dac:	00099863          	bnez	s3,ffffffffc0204dbc <proc_run+0x52>
}
ffffffffc0204db0:	70a2                	ld	ra,40(sp)
ffffffffc0204db2:	7482                	ld	s1,32(sp)
ffffffffc0204db4:	6962                	ld	s2,24(sp)
ffffffffc0204db6:	69c2                	ld	s3,16(sp)
ffffffffc0204db8:	6145                	addi	sp,sp,48
ffffffffc0204dba:	8082                	ret
ffffffffc0204dbc:	70a2                	ld	ra,40(sp)
ffffffffc0204dbe:	7482                	ld	s1,32(sp)
ffffffffc0204dc0:	6962                	ld	s2,24(sp)
ffffffffc0204dc2:	69c2                	ld	s3,16(sp)
ffffffffc0204dc4:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204dc6:	859fb06f          	j	ffffffffc020061e <intr_enable>
ffffffffc0204dca:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204dcc:	859fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0204dd0:	6522                	ld	a0,8(sp)
ffffffffc0204dd2:	4985                	li	s3,1
ffffffffc0204dd4:	bf6d                	j	ffffffffc0204d8e <proc_run+0x24>

ffffffffc0204dd6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204dd6:	7119                	addi	sp,sp,-128
ffffffffc0204dd8:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dda:	000ae917          	auipc	s2,0xae
ffffffffc0204dde:	aae90913          	addi	s2,s2,-1362 # ffffffffc02b2888 <nr_process>
ffffffffc0204de2:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204de6:	fc86                	sd	ra,120(sp)
ffffffffc0204de8:	f8a2                	sd	s0,112(sp)
ffffffffc0204dea:	f4a6                	sd	s1,104(sp)
ffffffffc0204dec:	ecce                	sd	s3,88(sp)
ffffffffc0204dee:	e8d2                	sd	s4,80(sp)
ffffffffc0204df0:	e4d6                	sd	s5,72(sp)
ffffffffc0204df2:	e0da                	sd	s6,64(sp)
ffffffffc0204df4:	fc5e                	sd	s7,56(sp)
ffffffffc0204df6:	f862                	sd	s8,48(sp)
ffffffffc0204df8:	f466                	sd	s9,40(sp)
ffffffffc0204dfa:	f06a                	sd	s10,32(sp)
ffffffffc0204dfc:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dfe:	6785                	lui	a5,0x1
ffffffffc0204e00:	34f75063          	bge	a4,a5,ffffffffc0205140 <do_fork+0x36a>
ffffffffc0204e04:	8a2a                	mv	s4,a0
ffffffffc0204e06:	89ae                	mv	s3,a1
ffffffffc0204e08:	8432                	mv	s0,a2
    if((proc = alloc_proc()) == NULL) {
ffffffffc0204e0a:	dedff0ef          	jal	ra,ffffffffc0204bf6 <alloc_proc>
ffffffffc0204e0e:	84aa                	mv	s1,a0
ffffffffc0204e10:	30050963          	beqz	a0,ffffffffc0205122 <do_fork+0x34c>
    proc->parent = current;
ffffffffc0204e14:	000aec17          	auipc	s8,0xae
ffffffffc0204e18:	a5cc0c13          	addi	s8,s8,-1444 # ffffffffc02b2870 <current>
ffffffffc0204e1c:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0204e20:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8acc>
    proc->parent = current;
ffffffffc0204e24:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204e26:	32071263          	bnez	a4,ffffffffc020514a <do_fork+0x374>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204e2a:	4509                	li	a0,2
ffffffffc0204e2c:	d6cfe0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
    if (page != NULL) {
ffffffffc0204e30:	2e050663          	beqz	a0,ffffffffc020511c <do_fork+0x346>
    return page - pages + nbase;
ffffffffc0204e34:	000aea97          	auipc	s5,0xae
ffffffffc0204e38:	a24a8a93          	addi	s5,s5,-1500 # ffffffffc02b2858 <pages>
ffffffffc0204e3c:	000ab683          	ld	a3,0(s5)
ffffffffc0204e40:	00004b17          	auipc	s6,0x4
ffffffffc0204e44:	ce0b0b13          	addi	s6,s6,-800 # ffffffffc0208b20 <nbase>
ffffffffc0204e48:	000b3783          	ld	a5,0(s6)
ffffffffc0204e4c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e50:	000aeb97          	auipc	s7,0xae
ffffffffc0204e54:	a00b8b93          	addi	s7,s7,-1536 # ffffffffc02b2850 <npage>
    return page - pages + nbase;
ffffffffc0204e58:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e5a:	5dfd                	li	s11,-1
ffffffffc0204e5c:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204e60:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204e62:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204e66:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e6a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e6c:	2ee67f63          	bgeu	a2,a4,ffffffffc020516a <do_fork+0x394>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204e70:	000c3603          	ld	a2,0(s8)
ffffffffc0204e74:	000aec17          	auipc	s8,0xae
ffffffffc0204e78:	9f4c0c13          	addi	s8,s8,-1548 # ffffffffc02b2868 <va_pa_offset>
ffffffffc0204e7c:	000c3703          	ld	a4,0(s8)
ffffffffc0204e80:	02863d03          	ld	s10,40(a2)
ffffffffc0204e84:	e43e                	sd	a5,8(sp)
ffffffffc0204e86:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204e88:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204e8a:	020d0863          	beqz	s10,ffffffffc0204eba <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc0204e8e:	100a7a13          	andi	s4,s4,256
ffffffffc0204e92:	1c0a0663          	beqz	s4,ffffffffc020505e <do_fork+0x288>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204e96:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e9a:	018d3783          	ld	a5,24(s10)
ffffffffc0204e9e:	c02006b7          	lui	a3,0xc0200
ffffffffc0204ea2:	2705                	addiw	a4,a4,1
ffffffffc0204ea4:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204ea8:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204eac:	2ed7e763          	bltu	a5,a3,ffffffffc020519a <do_fork+0x3c4>
ffffffffc0204eb0:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204eb4:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204eb6:	8f99                	sub	a5,a5,a4
ffffffffc0204eb8:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204eba:	6709                	lui	a4,0x2
ffffffffc0204ebc:	ee070713          	addi	a4,a4,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc0204ec0:	9736                	add	a4,a4,a3
    *(proc->tf) = *tf;
ffffffffc0204ec2:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ec4:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204ec6:	87ba                	mv	a5,a4
ffffffffc0204ec8:	12040313          	addi	t1,s0,288
ffffffffc0204ecc:	00063883          	ld	a7,0(a2)
ffffffffc0204ed0:	00863803          	ld	a6,8(a2)
ffffffffc0204ed4:	6a08                	ld	a0,16(a2)
ffffffffc0204ed6:	6e0c                	ld	a1,24(a2)
ffffffffc0204ed8:	0117b023          	sd	a7,0(a5)
ffffffffc0204edc:	0107b423          	sd	a6,8(a5)
ffffffffc0204ee0:	eb88                	sd	a0,16(a5)
ffffffffc0204ee2:	ef8c                	sd	a1,24(a5)
ffffffffc0204ee4:	02060613          	addi	a2,a2,32
ffffffffc0204ee8:	02078793          	addi	a5,a5,32
ffffffffc0204eec:	fe6610e3          	bne	a2,t1,ffffffffc0204ecc <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc0204ef0:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc0204ef4:	12098f63          	beqz	s3,ffffffffc0205032 <do_fork+0x25c>
ffffffffc0204ef8:	01373823          	sd	s3,16(a4)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204efc:	00000797          	auipc	a5,0x0
ffffffffc0204f00:	d6c78793          	addi	a5,a5,-660 # ffffffffc0204c68 <forkret>
ffffffffc0204f04:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f06:	fc98                	sd	a4,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f08:	100027f3          	csrr	a5,sstatus
ffffffffc0204f0c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f0e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f10:	14079363          	bnez	a5,ffffffffc0205056 <do_fork+0x280>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204f14:	000a2817          	auipc	a6,0xa2
ffffffffc0204f18:	41480813          	addi	a6,a6,1044 # ffffffffc02a7328 <last_pid.1>
ffffffffc0204f1c:	00082783          	lw	a5,0(a6)
ffffffffc0204f20:	6709                	lui	a4,0x2
ffffffffc0204f22:	0017851b          	addiw	a0,a5,1
ffffffffc0204f26:	00a82023          	sw	a0,0(a6)
ffffffffc0204f2a:	08e55d63          	bge	a0,a4,ffffffffc0204fc4 <do_fork+0x1ee>
    if (last_pid >= next_safe) {
ffffffffc0204f2e:	000a2317          	auipc	t1,0xa2
ffffffffc0204f32:	3fe30313          	addi	t1,t1,1022 # ffffffffc02a732c <next_safe.0>
ffffffffc0204f36:	00032783          	lw	a5,0(t1)
ffffffffc0204f3a:	000ae417          	auipc	s0,0xae
ffffffffc0204f3e:	8ae40413          	addi	s0,s0,-1874 # ffffffffc02b27e8 <proc_list>
ffffffffc0204f42:	08f55963          	bge	a0,a5,ffffffffc0204fd4 <do_fork+0x1fe>
        proc->pid = get_pid();
ffffffffc0204f46:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f48:	45a9                	li	a1,10
ffffffffc0204f4a:	2501                	sext.w	a0,a0
ffffffffc0204f4c:	534010ef          	jal	ra,ffffffffc0206480 <hash32>
ffffffffc0204f50:	02051793          	slli	a5,a0,0x20
ffffffffc0204f54:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204f58:	000aa797          	auipc	a5,0xaa
ffffffffc0204f5c:	89078793          	addi	a5,a5,-1904 # ffffffffc02ae7e8 <hash_list>
ffffffffc0204f60:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f62:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f64:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f66:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204f6a:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f6c:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204f6e:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f70:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204f72:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204f76:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204f78:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204f7a:	e21c                	sd	a5,0(a2)
ffffffffc0204f7c:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204f7e:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0204f80:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204f82:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f86:	10e4b023          	sd	a4,256(s1)
ffffffffc0204f8a:	c311                	beqz	a4,ffffffffc0204f8e <do_fork+0x1b8>
        proc->optr->yptr = proc;
ffffffffc0204f8c:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0204f8e:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204f92:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0204f94:	2785                	addiw	a5,a5,1
ffffffffc0204f96:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0204f9a:	18099663          	bnez	s3,ffffffffc0205126 <do_fork+0x350>
    wakeup_proc(proc);
ffffffffc0204f9e:	8526                	mv	a0,s1
ffffffffc0204fa0:	661000ef          	jal	ra,ffffffffc0205e00 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204fa4:	40c8                	lw	a0,4(s1)
}
ffffffffc0204fa6:	70e6                	ld	ra,120(sp)
ffffffffc0204fa8:	7446                	ld	s0,112(sp)
ffffffffc0204faa:	74a6                	ld	s1,104(sp)
ffffffffc0204fac:	7906                	ld	s2,96(sp)
ffffffffc0204fae:	69e6                	ld	s3,88(sp)
ffffffffc0204fb0:	6a46                	ld	s4,80(sp)
ffffffffc0204fb2:	6aa6                	ld	s5,72(sp)
ffffffffc0204fb4:	6b06                	ld	s6,64(sp)
ffffffffc0204fb6:	7be2                	ld	s7,56(sp)
ffffffffc0204fb8:	7c42                	ld	s8,48(sp)
ffffffffc0204fba:	7ca2                	ld	s9,40(sp)
ffffffffc0204fbc:	7d02                	ld	s10,32(sp)
ffffffffc0204fbe:	6de2                	ld	s11,24(sp)
ffffffffc0204fc0:	6109                	addi	sp,sp,128
ffffffffc0204fc2:	8082                	ret
        last_pid = 1;
ffffffffc0204fc4:	4785                	li	a5,1
ffffffffc0204fc6:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204fca:	4505                	li	a0,1
ffffffffc0204fcc:	000a2317          	auipc	t1,0xa2
ffffffffc0204fd0:	36030313          	addi	t1,t1,864 # ffffffffc02a732c <next_safe.0>
    return listelm->next;
ffffffffc0204fd4:	000ae417          	auipc	s0,0xae
ffffffffc0204fd8:	81440413          	addi	s0,s0,-2028 # ffffffffc02b27e8 <proc_list>
ffffffffc0204fdc:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0204fe0:	6789                	lui	a5,0x2
ffffffffc0204fe2:	00f32023          	sw	a5,0(t1)
ffffffffc0204fe6:	86aa                	mv	a3,a0
ffffffffc0204fe8:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204fea:	6e89                	lui	t4,0x2
ffffffffc0204fec:	148e0563          	beq	t3,s0,ffffffffc0205136 <do_fork+0x360>
ffffffffc0204ff0:	88ae                	mv	a7,a1
ffffffffc0204ff2:	87f2                	mv	a5,t3
ffffffffc0204ff4:	6609                	lui	a2,0x2
ffffffffc0204ff6:	a811                	j	ffffffffc020500a <do_fork+0x234>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204ff8:	00e6d663          	bge	a3,a4,ffffffffc0205004 <do_fork+0x22e>
ffffffffc0204ffc:	00c75463          	bge	a4,a2,ffffffffc0205004 <do_fork+0x22e>
ffffffffc0205000:	863a                	mv	a2,a4
ffffffffc0205002:	4885                	li	a7,1
ffffffffc0205004:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205006:	00878d63          	beq	a5,s0,ffffffffc0205020 <do_fork+0x24a>
            if (proc->pid == last_pid) {
ffffffffc020500a:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc020500e:	fed715e3          	bne	a4,a3,ffffffffc0204ff8 <do_fork+0x222>
                if (++ last_pid >= next_safe) {
ffffffffc0205012:	2685                	addiw	a3,a3,1
ffffffffc0205014:	10c6dc63          	bge	a3,a2,ffffffffc020512c <do_fork+0x356>
ffffffffc0205018:	679c                	ld	a5,8(a5)
ffffffffc020501a:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020501c:	fe8797e3          	bne	a5,s0,ffffffffc020500a <do_fork+0x234>
ffffffffc0205020:	c581                	beqz	a1,ffffffffc0205028 <do_fork+0x252>
ffffffffc0205022:	00d82023          	sw	a3,0(a6)
ffffffffc0205026:	8536                	mv	a0,a3
ffffffffc0205028:	f0088fe3          	beqz	a7,ffffffffc0204f46 <do_fork+0x170>
ffffffffc020502c:	00c32023          	sw	a2,0(t1)
ffffffffc0205030:	bf19                	j	ffffffffc0204f46 <do_fork+0x170>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc0205032:	6989                	lui	s3,0x2
ffffffffc0205034:	edc98993          	addi	s3,s3,-292 # 1edc <_binary_obj___user_faultread_out_size-0x7cdc>
ffffffffc0205038:	99b6                	add	s3,s3,a3
ffffffffc020503a:	01373823          	sd	s3,16(a4) # 2010 <_binary_obj___user_faultread_out_size-0x7ba8>
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020503e:	00000797          	auipc	a5,0x0
ffffffffc0205042:	c2a78793          	addi	a5,a5,-982 # ffffffffc0204c68 <forkret>
ffffffffc0205046:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205048:	fc98                	sd	a4,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020504a:	100027f3          	csrr	a5,sstatus
ffffffffc020504e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205050:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205052:	ec0781e3          	beqz	a5,ffffffffc0204f14 <do_fork+0x13e>
        intr_disable();
ffffffffc0205056:	dcefb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc020505a:	4985                	li	s3,1
ffffffffc020505c:	bd65                	j	ffffffffc0204f14 <do_fork+0x13e>
    if ((mm = mm_create()) == NULL) {
ffffffffc020505e:	dc5fb0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc0205062:	8caa                	mv	s9,a0
ffffffffc0205064:	c541                	beqz	a0,ffffffffc02050ec <do_fork+0x316>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205066:	4505                	li	a0,1
ffffffffc0205068:	b30fe0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc020506c:	cd2d                	beqz	a0,ffffffffc02050e6 <do_fork+0x310>
    return page - pages + nbase;
ffffffffc020506e:	000ab683          	ld	a3,0(s5)
ffffffffc0205072:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205074:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0205078:	40d506b3          	sub	a3,a0,a3
ffffffffc020507c:	8699                	srai	a3,a3,0x6
ffffffffc020507e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205080:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0205084:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205086:	0eedf263          	bgeu	s11,a4,ffffffffc020516a <do_fork+0x394>
ffffffffc020508a:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020508e:	6605                	lui	a2,0x1
ffffffffc0205090:	000ad597          	auipc	a1,0xad
ffffffffc0205094:	7b85b583          	ld	a1,1976(a1) # ffffffffc02b2848 <boot_pgdir>
ffffffffc0205098:	9a36                	add	s4,s4,a3
ffffffffc020509a:	8552                	mv	a0,s4
ffffffffc020509c:	7df000ef          	jal	ra,ffffffffc020607a <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02050a0:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02050a4:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02050a8:	4785                	li	a5,1
ffffffffc02050aa:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02050ae:	8b85                	andi	a5,a5,1
ffffffffc02050b0:	4a05                	li	s4,1
ffffffffc02050b2:	c799                	beqz	a5,ffffffffc02050c0 <do_fork+0x2ea>
        schedule();
ffffffffc02050b4:	5cd000ef          	jal	ra,ffffffffc0205e80 <schedule>
ffffffffc02050b8:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02050bc:	8b85                	andi	a5,a5,1
ffffffffc02050be:	fbfd                	bnez	a5,ffffffffc02050b4 <do_fork+0x2de>
        ret = dup_mmap(mm, oldmm);
ffffffffc02050c0:	85ea                	mv	a1,s10
ffffffffc02050c2:	8566                	mv	a0,s9
ffffffffc02050c4:	fe7fb0ef          	jal	ra,ffffffffc02010aa <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02050c8:	57f9                	li	a5,-2
ffffffffc02050ca:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02050ce:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02050d0:	0e078e63          	beqz	a5,ffffffffc02051cc <do_fork+0x3f6>
good_mm:
ffffffffc02050d4:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc02050d6:	dc0500e3          	beqz	a0,ffffffffc0204e96 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc02050da:	8566                	mv	a0,s9
ffffffffc02050dc:	868fc0ef          	jal	ra,ffffffffc0201144 <exit_mmap>
    put_pgdir(mm);
ffffffffc02050e0:	8566                	mv	a0,s9
ffffffffc02050e2:	c13ff0ef          	jal	ra,ffffffffc0204cf4 <put_pgdir>
    mm_destroy(mm);
ffffffffc02050e6:	8566                	mv	a0,s9
ffffffffc02050e8:	ec1fb0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02050ec:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02050ee:	c02007b7          	lui	a5,0xc0200
ffffffffc02050f2:	0cf6e163          	bltu	a3,a5,ffffffffc02051b4 <do_fork+0x3de>
ffffffffc02050f6:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc02050fa:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02050fe:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205102:	83b1                	srli	a5,a5,0xc
ffffffffc0205104:	06e7ff63          	bgeu	a5,a4,ffffffffc0205182 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc0205108:	000b3703          	ld	a4,0(s6)
ffffffffc020510c:	000ab503          	ld	a0,0(s5)
ffffffffc0205110:	4589                	li	a1,2
ffffffffc0205112:	8f99                	sub	a5,a5,a4
ffffffffc0205114:	079a                	slli	a5,a5,0x6
ffffffffc0205116:	953e                	add	a0,a0,a5
ffffffffc0205118:	b12fe0ef          	jal	ra,ffffffffc020342a <free_pages>
    kfree(proc);
ffffffffc020511c:	8526                	mv	a0,s1
ffffffffc020511e:	a9cfd0ef          	jal	ra,ffffffffc02023ba <kfree>
    ret = -E_NO_MEM;
ffffffffc0205122:	5571                	li	a0,-4
    return ret;
ffffffffc0205124:	b549                	j	ffffffffc0204fa6 <do_fork+0x1d0>
        intr_enable();
ffffffffc0205126:	cf8fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020512a:	bd95                	j	ffffffffc0204f9e <do_fork+0x1c8>
                    if (last_pid >= MAX_PID) {
ffffffffc020512c:	01d6c363          	blt	a3,t4,ffffffffc0205132 <do_fork+0x35c>
                        last_pid = 1;
ffffffffc0205130:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205132:	4585                	li	a1,1
ffffffffc0205134:	bd65                	j	ffffffffc0204fec <do_fork+0x216>
ffffffffc0205136:	c599                	beqz	a1,ffffffffc0205144 <do_fork+0x36e>
ffffffffc0205138:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020513c:	8536                	mv	a0,a3
ffffffffc020513e:	b521                	j	ffffffffc0204f46 <do_fork+0x170>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205140:	556d                	li	a0,-5
ffffffffc0205142:	b595                	j	ffffffffc0204fa6 <do_fork+0x1d0>
    return last_pid;
ffffffffc0205144:	00082503          	lw	a0,0(a6)
ffffffffc0205148:	bbfd                	j	ffffffffc0204f46 <do_fork+0x170>
    assert(current->wait_state == 0);
ffffffffc020514a:	00003697          	auipc	a3,0x3
ffffffffc020514e:	13668693          	addi	a3,a3,310 # ffffffffc0208280 <default_pmm_manager+0x6d8>
ffffffffc0205152:	00002617          	auipc	a2,0x2
ffffffffc0205156:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206b50 <commands+0x410>
ffffffffc020515a:	1b500593          	li	a1,437
ffffffffc020515e:	00003517          	auipc	a0,0x3
ffffffffc0205162:	10a50513          	addi	a0,a0,266 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205166:	8a2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020516a:	00002617          	auipc	a2,0x2
ffffffffc020516e:	fb660613          	addi	a2,a2,-74 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0205172:	06900593          	li	a1,105
ffffffffc0205176:	00002517          	auipc	a0,0x2
ffffffffc020517a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0207110 <commands+0x9d0>
ffffffffc020517e:	88afb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205182:	00002617          	auipc	a2,0x2
ffffffffc0205186:	f6e60613          	addi	a2,a2,-146 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc020518a:	06200593          	li	a1,98
ffffffffc020518e:	00002517          	auipc	a0,0x2
ffffffffc0205192:	f8250513          	addi	a0,a0,-126 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0205196:	872fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020519a:	86be                	mv	a3,a5
ffffffffc020519c:	00002617          	auipc	a2,0x2
ffffffffc02051a0:	4ac60613          	addi	a2,a2,1196 # ffffffffc0207648 <commands+0xf08>
ffffffffc02051a4:	16700593          	li	a1,359
ffffffffc02051a8:	00003517          	auipc	a0,0x3
ffffffffc02051ac:	0c050513          	addi	a0,a0,192 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc02051b0:	858fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02051b4:	00002617          	auipc	a2,0x2
ffffffffc02051b8:	49460613          	addi	a2,a2,1172 # ffffffffc0207648 <commands+0xf08>
ffffffffc02051bc:	06e00593          	li	a1,110
ffffffffc02051c0:	00002517          	auipc	a0,0x2
ffffffffc02051c4:	f5050513          	addi	a0,a0,-176 # ffffffffc0207110 <commands+0x9d0>
ffffffffc02051c8:	840fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc02051cc:	00003617          	auipc	a2,0x3
ffffffffc02051d0:	0d460613          	addi	a2,a2,212 # ffffffffc02082a0 <default_pmm_manager+0x6f8>
ffffffffc02051d4:	03100593          	li	a1,49
ffffffffc02051d8:	00003517          	auipc	a0,0x3
ffffffffc02051dc:	0d850513          	addi	a0,a0,216 # ffffffffc02082b0 <default_pmm_manager+0x708>
ffffffffc02051e0:	828fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02051e4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051e4:	7129                	addi	sp,sp,-320
ffffffffc02051e6:	fa22                	sd	s0,304(sp)
ffffffffc02051e8:	f626                	sd	s1,296(sp)
ffffffffc02051ea:	f24a                	sd	s2,288(sp)
ffffffffc02051ec:	84ae                	mv	s1,a1
ffffffffc02051ee:	892a                	mv	s2,a0
ffffffffc02051f0:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02051f2:	4581                	li	a1,0
ffffffffc02051f4:	12000613          	li	a2,288
ffffffffc02051f8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051fa:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02051fc:	66d000ef          	jal	ra,ffffffffc0206068 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205200:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205202:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205204:	100027f3          	csrr	a5,sstatus
ffffffffc0205208:	edd7f793          	andi	a5,a5,-291
ffffffffc020520c:	1207e793          	ori	a5,a5,288
ffffffffc0205210:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205212:	860a                	mv	a2,sp
ffffffffc0205214:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205218:	00000797          	auipc	a5,0x0
ffffffffc020521c:	9d678793          	addi	a5,a5,-1578 # ffffffffc0204bee <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205220:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205222:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205224:	bb3ff0ef          	jal	ra,ffffffffc0204dd6 <do_fork>
}
ffffffffc0205228:	70f2                	ld	ra,312(sp)
ffffffffc020522a:	7452                	ld	s0,304(sp)
ffffffffc020522c:	74b2                	ld	s1,296(sp)
ffffffffc020522e:	7912                	ld	s2,288(sp)
ffffffffc0205230:	6131                	addi	sp,sp,320
ffffffffc0205232:	8082                	ret

ffffffffc0205234 <do_exit>:
do_exit(int error_code) {
ffffffffc0205234:	7179                	addi	sp,sp,-48
ffffffffc0205236:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205238:	000ad417          	auipc	s0,0xad
ffffffffc020523c:	63840413          	addi	s0,s0,1592 # ffffffffc02b2870 <current>
ffffffffc0205240:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205242:	f406                	sd	ra,40(sp)
ffffffffc0205244:	ec26                	sd	s1,24(sp)
ffffffffc0205246:	e84a                	sd	s2,16(sp)
ffffffffc0205248:	e44e                	sd	s3,8(sp)
ffffffffc020524a:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020524c:	000ad717          	auipc	a4,0xad
ffffffffc0205250:	62c73703          	ld	a4,1580(a4) # ffffffffc02b2878 <idleproc>
ffffffffc0205254:	0ce78c63          	beq	a5,a4,ffffffffc020532c <do_exit+0xf8>
    if (current == initproc) {
ffffffffc0205258:	000ad497          	auipc	s1,0xad
ffffffffc020525c:	62848493          	addi	s1,s1,1576 # ffffffffc02b2880 <initproc>
ffffffffc0205260:	6098                	ld	a4,0(s1)
ffffffffc0205262:	0ee78b63          	beq	a5,a4,ffffffffc0205358 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205266:	0287b983          	ld	s3,40(a5)
ffffffffc020526a:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020526c:	02098663          	beqz	s3,ffffffffc0205298 <do_exit+0x64>
ffffffffc0205270:	000ad797          	auipc	a5,0xad
ffffffffc0205274:	5d07b783          	ld	a5,1488(a5) # ffffffffc02b2840 <boot_cr3>
ffffffffc0205278:	577d                	li	a4,-1
ffffffffc020527a:	177e                	slli	a4,a4,0x3f
ffffffffc020527c:	83b1                	srli	a5,a5,0xc
ffffffffc020527e:	8fd9                	or	a5,a5,a4
ffffffffc0205280:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205284:	0309a783          	lw	a5,48(s3)
ffffffffc0205288:	fff7871b          	addiw	a4,a5,-1
ffffffffc020528c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205290:	cb55                	beqz	a4,ffffffffc0205344 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205292:	601c                	ld	a5,0(s0)
ffffffffc0205294:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205298:	601c                	ld	a5,0(s0)
ffffffffc020529a:	470d                	li	a4,3
ffffffffc020529c:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020529e:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052a2:	100027f3          	csrr	a5,sstatus
ffffffffc02052a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052a8:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052aa:	e3f9                	bnez	a5,ffffffffc0205370 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02052ac:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052ae:	800007b7          	lui	a5,0x80000
ffffffffc02052b2:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02052b4:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052b6:	0ec52703          	lw	a4,236(a0)
ffffffffc02052ba:	0af70f63          	beq	a4,a5,ffffffffc0205378 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02052be:	6018                	ld	a4,0(s0)
ffffffffc02052c0:	7b7c                	ld	a5,240(a4)
ffffffffc02052c2:	c3a1                	beqz	a5,ffffffffc0205302 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052c4:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052c8:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052ca:	0985                	addi	s3,s3,1
ffffffffc02052cc:	a021                	j	ffffffffc02052d4 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02052ce:	6018                	ld	a4,0(s0)
ffffffffc02052d0:	7b7c                	ld	a5,240(a4)
ffffffffc02052d2:	cb85                	beqz	a5,ffffffffc0205302 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02052d4:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052d8:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02052da:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052dc:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02052de:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052e2:	10e7b023          	sd	a4,256(a5)
ffffffffc02052e6:	c311                	beqz	a4,ffffffffc02052ea <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02052e8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052ea:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02052ec:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02052ee:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052f0:	fd271fe3          	bne	a4,s2,ffffffffc02052ce <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052f4:	0ec52783          	lw	a5,236(a0)
ffffffffc02052f8:	fd379be3          	bne	a5,s3,ffffffffc02052ce <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02052fc:	305000ef          	jal	ra,ffffffffc0205e00 <wakeup_proc>
ffffffffc0205300:	b7f9                	j	ffffffffc02052ce <do_exit+0x9a>
    if (flag) {
ffffffffc0205302:	020a1263          	bnez	s4,ffffffffc0205326 <do_exit+0xf2>
    schedule();
ffffffffc0205306:	37b000ef          	jal	ra,ffffffffc0205e80 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020530a:	601c                	ld	a5,0(s0)
ffffffffc020530c:	00003617          	auipc	a2,0x3
ffffffffc0205310:	fdc60613          	addi	a2,a2,-36 # ffffffffc02082e8 <default_pmm_manager+0x740>
ffffffffc0205314:	20800593          	li	a1,520
ffffffffc0205318:	43d4                	lw	a3,4(a5)
ffffffffc020531a:	00003517          	auipc	a0,0x3
ffffffffc020531e:	f4e50513          	addi	a0,a0,-178 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205322:	ee7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc0205326:	af8fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020532a:	bff1                	j	ffffffffc0205306 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020532c:	00003617          	auipc	a2,0x3
ffffffffc0205330:	f9c60613          	addi	a2,a2,-100 # ffffffffc02082c8 <default_pmm_manager+0x720>
ffffffffc0205334:	1dc00593          	li	a1,476
ffffffffc0205338:	00003517          	auipc	a0,0x3
ffffffffc020533c:	f3050513          	addi	a0,a0,-208 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205340:	ec9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc0205344:	854e                	mv	a0,s3
ffffffffc0205346:	dfffb0ef          	jal	ra,ffffffffc0201144 <exit_mmap>
            put_pgdir(mm);
ffffffffc020534a:	854e                	mv	a0,s3
ffffffffc020534c:	9a9ff0ef          	jal	ra,ffffffffc0204cf4 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205350:	854e                	mv	a0,s3
ffffffffc0205352:	c57fb0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
ffffffffc0205356:	bf35                	j	ffffffffc0205292 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0205358:	00003617          	auipc	a2,0x3
ffffffffc020535c:	f8060613          	addi	a2,a2,-128 # ffffffffc02082d8 <default_pmm_manager+0x730>
ffffffffc0205360:	1df00593          	li	a1,479
ffffffffc0205364:	00003517          	auipc	a0,0x3
ffffffffc0205368:	f0450513          	addi	a0,a0,-252 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc020536c:	e9dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc0205370:	ab4fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205374:	4a05                	li	s4,1
ffffffffc0205376:	bf1d                	j	ffffffffc02052ac <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0205378:	289000ef          	jal	ra,ffffffffc0205e00 <wakeup_proc>
ffffffffc020537c:	b789                	j	ffffffffc02052be <do_exit+0x8a>

ffffffffc020537e <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc020537e:	715d                	addi	sp,sp,-80
ffffffffc0205380:	f84a                	sd	s2,48(sp)
ffffffffc0205382:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205384:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205388:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc020538a:	fc26                	sd	s1,56(sp)
ffffffffc020538c:	f052                	sd	s4,32(sp)
ffffffffc020538e:	ec56                	sd	s5,24(sp)
ffffffffc0205390:	e85a                	sd	s6,16(sp)
ffffffffc0205392:	e45e                	sd	s7,8(sp)
ffffffffc0205394:	e486                	sd	ra,72(sp)
ffffffffc0205396:	e0a2                	sd	s0,64(sp)
ffffffffc0205398:	84aa                	mv	s1,a0
ffffffffc020539a:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc020539c:	000adb97          	auipc	s7,0xad
ffffffffc02053a0:	4d4b8b93          	addi	s7,s7,1236 # ffffffffc02b2870 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053a4:	00050b1b          	sext.w	s6,a0
ffffffffc02053a8:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02053ac:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02053ae:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02053b0:	ccbd                	beqz	s1,ffffffffc020542e <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053b2:	0359e863          	bltu	s3,s5,ffffffffc02053e2 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02053b6:	45a9                	li	a1,10
ffffffffc02053b8:	855a                	mv	a0,s6
ffffffffc02053ba:	0c6010ef          	jal	ra,ffffffffc0206480 <hash32>
ffffffffc02053be:	02051793          	slli	a5,a0,0x20
ffffffffc02053c2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02053c6:	000a9797          	auipc	a5,0xa9
ffffffffc02053ca:	42278793          	addi	a5,a5,1058 # ffffffffc02ae7e8 <hash_list>
ffffffffc02053ce:	953e                	add	a0,a0,a5
ffffffffc02053d0:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02053d2:	a029                	j	ffffffffc02053dc <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02053d4:	f2c42783          	lw	a5,-212(s0)
ffffffffc02053d8:	02978163          	beq	a5,s1,ffffffffc02053fa <do_wait.part.0+0x7c>
ffffffffc02053dc:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02053de:	fe851be3          	bne	a0,s0,ffffffffc02053d4 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02053e2:	5579                	li	a0,-2
}
ffffffffc02053e4:	60a6                	ld	ra,72(sp)
ffffffffc02053e6:	6406                	ld	s0,64(sp)
ffffffffc02053e8:	74e2                	ld	s1,56(sp)
ffffffffc02053ea:	7942                	ld	s2,48(sp)
ffffffffc02053ec:	79a2                	ld	s3,40(sp)
ffffffffc02053ee:	7a02                	ld	s4,32(sp)
ffffffffc02053f0:	6ae2                	ld	s5,24(sp)
ffffffffc02053f2:	6b42                	ld	s6,16(sp)
ffffffffc02053f4:	6ba2                	ld	s7,8(sp)
ffffffffc02053f6:	6161                	addi	sp,sp,80
ffffffffc02053f8:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02053fa:	000bb683          	ld	a3,0(s7)
ffffffffc02053fe:	f4843783          	ld	a5,-184(s0)
ffffffffc0205402:	fed790e3          	bne	a5,a3,ffffffffc02053e2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205406:	f2842703          	lw	a4,-216(s0)
ffffffffc020540a:	478d                	li	a5,3
ffffffffc020540c:	0ef70b63          	beq	a4,a5,ffffffffc0205502 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205410:	4785                	li	a5,1
ffffffffc0205412:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205414:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205418:	269000ef          	jal	ra,ffffffffc0205e80 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020541c:	000bb783          	ld	a5,0(s7)
ffffffffc0205420:	0b07a783          	lw	a5,176(a5)
ffffffffc0205424:	8b85                	andi	a5,a5,1
ffffffffc0205426:	d7c9                	beqz	a5,ffffffffc02053b0 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205428:	555d                	li	a0,-9
ffffffffc020542a:	e0bff0ef          	jal	ra,ffffffffc0205234 <do_exit>
        proc = current->cptr;
ffffffffc020542e:	000bb683          	ld	a3,0(s7)
ffffffffc0205432:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205434:	d45d                	beqz	s0,ffffffffc02053e2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205436:	470d                	li	a4,3
ffffffffc0205438:	a021                	j	ffffffffc0205440 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020543a:	10043403          	ld	s0,256(s0)
ffffffffc020543e:	d869                	beqz	s0,ffffffffc0205410 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205440:	401c                	lw	a5,0(s0)
ffffffffc0205442:	fee79ce3          	bne	a5,a4,ffffffffc020543a <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205446:	000ad797          	auipc	a5,0xad
ffffffffc020544a:	4327b783          	ld	a5,1074(a5) # ffffffffc02b2878 <idleproc>
ffffffffc020544e:	0c878963          	beq	a5,s0,ffffffffc0205520 <do_wait.part.0+0x1a2>
ffffffffc0205452:	000ad797          	auipc	a5,0xad
ffffffffc0205456:	42e7b783          	ld	a5,1070(a5) # ffffffffc02b2880 <initproc>
ffffffffc020545a:	0cf40363          	beq	s0,a5,ffffffffc0205520 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc020545e:	000a0663          	beqz	s4,ffffffffc020546a <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205462:	0e842783          	lw	a5,232(s0)
ffffffffc0205466:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020546a:	100027f3          	csrr	a5,sstatus
ffffffffc020546e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205470:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205472:	e7c1                	bnez	a5,ffffffffc02054fa <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205474:	6c70                	ld	a2,216(s0)
ffffffffc0205476:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205478:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020547c:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020547e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205480:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205482:	6470                	ld	a2,200(s0)
ffffffffc0205484:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205486:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205488:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc020548a:	c319                	beqz	a4,ffffffffc0205490 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020548c:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc020548e:	7c7c                	ld	a5,248(s0)
ffffffffc0205490:	c3b5                	beqz	a5,ffffffffc02054f4 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205492:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205496:	000ad717          	auipc	a4,0xad
ffffffffc020549a:	3f270713          	addi	a4,a4,1010 # ffffffffc02b2888 <nr_process>
ffffffffc020549e:	431c                	lw	a5,0(a4)
ffffffffc02054a0:	37fd                	addiw	a5,a5,-1
ffffffffc02054a2:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02054a4:	e5a9                	bnez	a1,ffffffffc02054ee <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02054a6:	6814                	ld	a3,16(s0)
ffffffffc02054a8:	c02007b7          	lui	a5,0xc0200
ffffffffc02054ac:	04f6ee63          	bltu	a3,a5,ffffffffc0205508 <do_wait.part.0+0x18a>
ffffffffc02054b0:	000ad797          	auipc	a5,0xad
ffffffffc02054b4:	3b87b783          	ld	a5,952(a5) # ffffffffc02b2868 <va_pa_offset>
ffffffffc02054b8:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02054ba:	82b1                	srli	a3,a3,0xc
ffffffffc02054bc:	000ad797          	auipc	a5,0xad
ffffffffc02054c0:	3947b783          	ld	a5,916(a5) # ffffffffc02b2850 <npage>
ffffffffc02054c4:	06f6fa63          	bgeu	a3,a5,ffffffffc0205538 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02054c8:	00003517          	auipc	a0,0x3
ffffffffc02054cc:	65853503          	ld	a0,1624(a0) # ffffffffc0208b20 <nbase>
ffffffffc02054d0:	8e89                	sub	a3,a3,a0
ffffffffc02054d2:	069a                	slli	a3,a3,0x6
ffffffffc02054d4:	000ad517          	auipc	a0,0xad
ffffffffc02054d8:	38453503          	ld	a0,900(a0) # ffffffffc02b2858 <pages>
ffffffffc02054dc:	9536                	add	a0,a0,a3
ffffffffc02054de:	4589                	li	a1,2
ffffffffc02054e0:	f4bfd0ef          	jal	ra,ffffffffc020342a <free_pages>
    kfree(proc);
ffffffffc02054e4:	8522                	mv	a0,s0
ffffffffc02054e6:	ed5fc0ef          	jal	ra,ffffffffc02023ba <kfree>
    return 0;
ffffffffc02054ea:	4501                	li	a0,0
ffffffffc02054ec:	bde5                	j	ffffffffc02053e4 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02054ee:	930fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02054f2:	bf55                	j	ffffffffc02054a6 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02054f4:	701c                	ld	a5,32(s0)
ffffffffc02054f6:	fbf8                	sd	a4,240(a5)
ffffffffc02054f8:	bf79                	j	ffffffffc0205496 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02054fa:	92afb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc02054fe:	4585                	li	a1,1
ffffffffc0205500:	bf95                	j	ffffffffc0205474 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205502:	f2840413          	addi	s0,s0,-216
ffffffffc0205506:	b781                	j	ffffffffc0205446 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205508:	00002617          	auipc	a2,0x2
ffffffffc020550c:	14060613          	addi	a2,a2,320 # ffffffffc0207648 <commands+0xf08>
ffffffffc0205510:	06e00593          	li	a1,110
ffffffffc0205514:	00002517          	auipc	a0,0x2
ffffffffc0205518:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207110 <commands+0x9d0>
ffffffffc020551c:	cedfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205520:	00003617          	auipc	a2,0x3
ffffffffc0205524:	de860613          	addi	a2,a2,-536 # ffffffffc0208308 <default_pmm_manager+0x760>
ffffffffc0205528:	30300593          	li	a1,771
ffffffffc020552c:	00003517          	auipc	a0,0x3
ffffffffc0205530:	d3c50513          	addi	a0,a0,-708 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205534:	cd5fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205538:	00002617          	auipc	a2,0x2
ffffffffc020553c:	bb860613          	addi	a2,a2,-1096 # ffffffffc02070f0 <commands+0x9b0>
ffffffffc0205540:	06200593          	li	a1,98
ffffffffc0205544:	00002517          	auipc	a0,0x2
ffffffffc0205548:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0207110 <commands+0x9d0>
ffffffffc020554c:	cbdfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205550 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205550:	1141                	addi	sp,sp,-16
ffffffffc0205552:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205554:	f17fd0ef          	jal	ra,ffffffffc020346a <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205558:	daffc0ef          	jal	ra,ffffffffc0202306 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020555c:	4601                	li	a2,0
ffffffffc020555e:	4581                	li	a1,0
ffffffffc0205560:	fffff517          	auipc	a0,0xfffff
ffffffffc0205564:	71650513          	addi	a0,a0,1814 # ffffffffc0204c76 <user_main>
ffffffffc0205568:	c7dff0ef          	jal	ra,ffffffffc02051e4 <kernel_thread>
    if (pid <= 0) {
ffffffffc020556c:	00a04563          	bgtz	a0,ffffffffc0205576 <init_main+0x26>
ffffffffc0205570:	a071                	j	ffffffffc02055fc <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205572:	10f000ef          	jal	ra,ffffffffc0205e80 <schedule>
    if (code_store != NULL) {
ffffffffc0205576:	4581                	li	a1,0
ffffffffc0205578:	4501                	li	a0,0
ffffffffc020557a:	e05ff0ef          	jal	ra,ffffffffc020537e <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc020557e:	d975                	beqz	a0,ffffffffc0205572 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205580:	00003517          	auipc	a0,0x3
ffffffffc0205584:	dc850513          	addi	a0,a0,-568 # ffffffffc0208348 <default_pmm_manager+0x7a0>
ffffffffc0205588:	b45fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020558c:	000ad797          	auipc	a5,0xad
ffffffffc0205590:	2f47b783          	ld	a5,756(a5) # ffffffffc02b2880 <initproc>
ffffffffc0205594:	7bf8                	ld	a4,240(a5)
ffffffffc0205596:	e339                	bnez	a4,ffffffffc02055dc <init_main+0x8c>
ffffffffc0205598:	7ff8                	ld	a4,248(a5)
ffffffffc020559a:	e329                	bnez	a4,ffffffffc02055dc <init_main+0x8c>
ffffffffc020559c:	1007b703          	ld	a4,256(a5)
ffffffffc02055a0:	ef15                	bnez	a4,ffffffffc02055dc <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02055a2:	000ad697          	auipc	a3,0xad
ffffffffc02055a6:	2e66a683          	lw	a3,742(a3) # ffffffffc02b2888 <nr_process>
ffffffffc02055aa:	4709                	li	a4,2
ffffffffc02055ac:	0ae69463          	bne	a3,a4,ffffffffc0205654 <init_main+0x104>
    return listelm->next;
ffffffffc02055b0:	000ad697          	auipc	a3,0xad
ffffffffc02055b4:	23868693          	addi	a3,a3,568 # ffffffffc02b27e8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02055b8:	6698                	ld	a4,8(a3)
ffffffffc02055ba:	0c878793          	addi	a5,a5,200
ffffffffc02055be:	06f71b63          	bne	a4,a5,ffffffffc0205634 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02055c2:	629c                	ld	a5,0(a3)
ffffffffc02055c4:	04f71863          	bne	a4,a5,ffffffffc0205614 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02055c8:	00003517          	auipc	a0,0x3
ffffffffc02055cc:	e6850513          	addi	a0,a0,-408 # ffffffffc0208430 <default_pmm_manager+0x888>
ffffffffc02055d0:	afdfa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02055d4:	60a2                	ld	ra,8(sp)
ffffffffc02055d6:	4501                	li	a0,0
ffffffffc02055d8:	0141                	addi	sp,sp,16
ffffffffc02055da:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02055dc:	00003697          	auipc	a3,0x3
ffffffffc02055e0:	d9468693          	addi	a3,a3,-620 # ffffffffc0208370 <default_pmm_manager+0x7c8>
ffffffffc02055e4:	00001617          	auipc	a2,0x1
ffffffffc02055e8:	56c60613          	addi	a2,a2,1388 # ffffffffc0206b50 <commands+0x410>
ffffffffc02055ec:	36800593          	li	a1,872
ffffffffc02055f0:	00003517          	auipc	a0,0x3
ffffffffc02055f4:	c7850513          	addi	a0,a0,-904 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc02055f8:	c11fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc02055fc:	00003617          	auipc	a2,0x3
ffffffffc0205600:	d2c60613          	addi	a2,a2,-724 # ffffffffc0208328 <default_pmm_manager+0x780>
ffffffffc0205604:	36000593          	li	a1,864
ffffffffc0205608:	00003517          	auipc	a0,0x3
ffffffffc020560c:	c6050513          	addi	a0,a0,-928 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205610:	bf9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205614:	00003697          	auipc	a3,0x3
ffffffffc0205618:	dec68693          	addi	a3,a3,-532 # ffffffffc0208400 <default_pmm_manager+0x858>
ffffffffc020561c:	00001617          	auipc	a2,0x1
ffffffffc0205620:	53460613          	addi	a2,a2,1332 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205624:	36b00593          	li	a1,875
ffffffffc0205628:	00003517          	auipc	a0,0x3
ffffffffc020562c:	c4050513          	addi	a0,a0,-960 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205630:	bd9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205634:	00003697          	auipc	a3,0x3
ffffffffc0205638:	d9c68693          	addi	a3,a3,-612 # ffffffffc02083d0 <default_pmm_manager+0x828>
ffffffffc020563c:	00001617          	auipc	a2,0x1
ffffffffc0205640:	51460613          	addi	a2,a2,1300 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205644:	36a00593          	li	a1,874
ffffffffc0205648:	00003517          	auipc	a0,0x3
ffffffffc020564c:	c2050513          	addi	a0,a0,-992 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205650:	bb9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc0205654:	00003697          	auipc	a3,0x3
ffffffffc0205658:	d6c68693          	addi	a3,a3,-660 # ffffffffc02083c0 <default_pmm_manager+0x818>
ffffffffc020565c:	00001617          	auipc	a2,0x1
ffffffffc0205660:	4f460613          	addi	a2,a2,1268 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205664:	36900593          	li	a1,873
ffffffffc0205668:	00003517          	auipc	a0,0x3
ffffffffc020566c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205670:	b99fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205674 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205674:	7171                	addi	sp,sp,-176
ffffffffc0205676:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205678:	000add97          	auipc	s11,0xad
ffffffffc020567c:	1f8d8d93          	addi	s11,s11,504 # ffffffffc02b2870 <current>
ffffffffc0205680:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205684:	e54e                	sd	s3,136(sp)
ffffffffc0205686:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205688:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020568c:	e94a                	sd	s2,144(sp)
ffffffffc020568e:	f4de                	sd	s7,104(sp)
ffffffffc0205690:	892a                	mv	s2,a0
ffffffffc0205692:	8bb2                	mv	s7,a2
ffffffffc0205694:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205696:	862e                	mv	a2,a1
ffffffffc0205698:	4681                	li	a3,0
ffffffffc020569a:	85aa                	mv	a1,a0
ffffffffc020569c:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020569e:	f506                	sd	ra,168(sp)
ffffffffc02056a0:	f122                	sd	s0,160(sp)
ffffffffc02056a2:	e152                	sd	s4,128(sp)
ffffffffc02056a4:	fcd6                	sd	s5,120(sp)
ffffffffc02056a6:	f8da                	sd	s6,112(sp)
ffffffffc02056a8:	f0e2                	sd	s8,96(sp)
ffffffffc02056aa:	ece6                	sd	s9,88(sp)
ffffffffc02056ac:	e8ea                	sd	s10,80(sp)
ffffffffc02056ae:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02056b0:	906fc0ef          	jal	ra,ffffffffc02017b6 <user_mem_check>
ffffffffc02056b4:	40050863          	beqz	a0,ffffffffc0205ac4 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02056b8:	4641                	li	a2,16
ffffffffc02056ba:	4581                	li	a1,0
ffffffffc02056bc:	1808                	addi	a0,sp,48
ffffffffc02056be:	1ab000ef          	jal	ra,ffffffffc0206068 <memset>
    memcpy(local_name, name, len);
ffffffffc02056c2:	47bd                	li	a5,15
ffffffffc02056c4:	8626                	mv	a2,s1
ffffffffc02056c6:	1e97e063          	bltu	a5,s1,ffffffffc02058a6 <do_execve+0x232>
ffffffffc02056ca:	85ca                	mv	a1,s2
ffffffffc02056cc:	1808                	addi	a0,sp,48
ffffffffc02056ce:	1ad000ef          	jal	ra,ffffffffc020607a <memcpy>
    if (mm != NULL) {
ffffffffc02056d2:	1e098163          	beqz	s3,ffffffffc02058b4 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02056d6:	00002517          	auipc	a0,0x2
ffffffffc02056da:	81250513          	addi	a0,a0,-2030 # ffffffffc0206ee8 <commands+0x7a8>
ffffffffc02056de:	a27fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc02056e2:	000ad797          	auipc	a5,0xad
ffffffffc02056e6:	15e7b783          	ld	a5,350(a5) # ffffffffc02b2840 <boot_cr3>
ffffffffc02056ea:	577d                	li	a4,-1
ffffffffc02056ec:	177e                	slli	a4,a4,0x3f
ffffffffc02056ee:	83b1                	srli	a5,a5,0xc
ffffffffc02056f0:	8fd9                	or	a5,a5,a4
ffffffffc02056f2:	18079073          	csrw	satp,a5
ffffffffc02056f6:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc02056fa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02056fe:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205702:	2c070263          	beqz	a4,ffffffffc02059c6 <do_execve+0x352>
        current->mm = NULL;
ffffffffc0205706:	000db783          	ld	a5,0(s11)
ffffffffc020570a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020570e:	f14fb0ef          	jal	ra,ffffffffc0200e22 <mm_create>
ffffffffc0205712:	84aa                	mv	s1,a0
ffffffffc0205714:	1c050b63          	beqz	a0,ffffffffc02058ea <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205718:	4505                	li	a0,1
ffffffffc020571a:	c7ffd0ef          	jal	ra,ffffffffc0203398 <alloc_pages>
ffffffffc020571e:	3a050763          	beqz	a0,ffffffffc0205acc <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205722:	000adc97          	auipc	s9,0xad
ffffffffc0205726:	136c8c93          	addi	s9,s9,310 # ffffffffc02b2858 <pages>
ffffffffc020572a:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc020572e:	000adc17          	auipc	s8,0xad
ffffffffc0205732:	122c0c13          	addi	s8,s8,290 # ffffffffc02b2850 <npage>
    return page - pages + nbase;
ffffffffc0205736:	00003717          	auipc	a4,0x3
ffffffffc020573a:	3ea73703          	ld	a4,1002(a4) # ffffffffc0208b20 <nbase>
ffffffffc020573e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205742:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205744:	5afd                	li	s5,-1
ffffffffc0205746:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc020574a:	96ba                	add	a3,a3,a4
ffffffffc020574c:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc020574e:	00cad713          	srli	a4,s5,0xc
ffffffffc0205752:	ec3a                	sd	a4,24(sp)
ffffffffc0205754:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205756:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205758:	36f77e63          	bgeu	a4,a5,ffffffffc0205ad4 <do_execve+0x460>
ffffffffc020575c:	000adb17          	auipc	s6,0xad
ffffffffc0205760:	10cb0b13          	addi	s6,s6,268 # ffffffffc02b2868 <va_pa_offset>
ffffffffc0205764:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205768:	6605                	lui	a2,0x1
ffffffffc020576a:	000ad597          	auipc	a1,0xad
ffffffffc020576e:	0de5b583          	ld	a1,222(a1) # ffffffffc02b2848 <boot_pgdir>
ffffffffc0205772:	9936                	add	s2,s2,a3
ffffffffc0205774:	854a                	mv	a0,s2
ffffffffc0205776:	105000ef          	jal	ra,ffffffffc020607a <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020577a:	7782                	ld	a5,32(sp)
ffffffffc020577c:	4398                	lw	a4,0(a5)
ffffffffc020577e:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205782:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205786:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc020578a:	14f71663          	bne	a4,a5,ffffffffc02058d6 <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020578e:	7682                	ld	a3,32(sp)
ffffffffc0205790:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205794:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205798:	00371793          	slli	a5,a4,0x3
ffffffffc020579c:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020579e:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02057a0:	078e                	slli	a5,a5,0x3
ffffffffc02057a2:	97ce                	add	a5,a5,s3
ffffffffc02057a4:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02057a6:	00f9fc63          	bgeu	s3,a5,ffffffffc02057be <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02057aa:	0009a783          	lw	a5,0(s3)
ffffffffc02057ae:	4705                	li	a4,1
ffffffffc02057b0:	12e78f63          	beq	a5,a4,ffffffffc02058ee <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02057b4:	77a2                	ld	a5,40(sp)
ffffffffc02057b6:	03898993          	addi	s3,s3,56
ffffffffc02057ba:	fef9e8e3          	bltu	s3,a5,ffffffffc02057aa <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02057be:	4701                	li	a4,0
ffffffffc02057c0:	46ad                	li	a3,11
ffffffffc02057c2:	00100637          	lui	a2,0x100
ffffffffc02057c6:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02057ca:	8526                	mv	a0,s1
ffffffffc02057cc:	82ffb0ef          	jal	ra,ffffffffc0200ffa <mm_map>
ffffffffc02057d0:	8a2a                	mv	s4,a0
ffffffffc02057d2:	1e051063          	bnez	a0,ffffffffc02059b2 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02057d6:	6c88                	ld	a0,24(s1)
ffffffffc02057d8:	467d                	li	a2,31
ffffffffc02057da:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02057de:	a26ff0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc02057e2:	38050163          	beqz	a0,ffffffffc0205b64 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02057e6:	6c88                	ld	a0,24(s1)
ffffffffc02057e8:	467d                	li	a2,31
ffffffffc02057ea:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02057ee:	a16ff0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc02057f2:	34050963          	beqz	a0,ffffffffc0205b44 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02057f6:	6c88                	ld	a0,24(s1)
ffffffffc02057f8:	467d                	li	a2,31
ffffffffc02057fa:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02057fe:	a06ff0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc0205802:	32050163          	beqz	a0,ffffffffc0205b24 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205806:	6c88                	ld	a0,24(s1)
ffffffffc0205808:	467d                	li	a2,31
ffffffffc020580a:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020580e:	9f6ff0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc0205812:	2e050963          	beqz	a0,ffffffffc0205b04 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc0205816:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205818:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020581c:	6c94                	ld	a3,24(s1)
ffffffffc020581e:	2785                	addiw	a5,a5,1
ffffffffc0205820:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205822:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205824:	c02007b7          	lui	a5,0xc0200
ffffffffc0205828:	2cf6e263          	bltu	a3,a5,ffffffffc0205aec <do_execve+0x478>
ffffffffc020582c:	000b3783          	ld	a5,0(s6)
ffffffffc0205830:	577d                	li	a4,-1
ffffffffc0205832:	177e                	slli	a4,a4,0x3f
ffffffffc0205834:	8e9d                	sub	a3,a3,a5
ffffffffc0205836:	00c6d793          	srli	a5,a3,0xc
ffffffffc020583a:	f654                	sd	a3,168(a2)
ffffffffc020583c:	8fd9                	or	a5,a5,a4
ffffffffc020583e:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205842:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205844:	4581                	li	a1,0
ffffffffc0205846:	12000613          	li	a2,288
ffffffffc020584a:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020584c:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205850:	019000ef          	jal	ra,ffffffffc0206068 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205854:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205856:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc020585a:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc020585e:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205860:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205862:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc0205866:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205868:	4641                	li	a2,16
ffffffffc020586a:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc020586c:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc020586e:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205872:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205876:	8526                	mv	a0,s1
ffffffffc0205878:	7f0000ef          	jal	ra,ffffffffc0206068 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020587c:	463d                	li	a2,15
ffffffffc020587e:	180c                	addi	a1,sp,48
ffffffffc0205880:	8526                	mv	a0,s1
ffffffffc0205882:	7f8000ef          	jal	ra,ffffffffc020607a <memcpy>
}
ffffffffc0205886:	70aa                	ld	ra,168(sp)
ffffffffc0205888:	740a                	ld	s0,160(sp)
ffffffffc020588a:	64ea                	ld	s1,152(sp)
ffffffffc020588c:	694a                	ld	s2,144(sp)
ffffffffc020588e:	69aa                	ld	s3,136(sp)
ffffffffc0205890:	7ae6                	ld	s5,120(sp)
ffffffffc0205892:	7b46                	ld	s6,112(sp)
ffffffffc0205894:	7ba6                	ld	s7,104(sp)
ffffffffc0205896:	7c06                	ld	s8,96(sp)
ffffffffc0205898:	6ce6                	ld	s9,88(sp)
ffffffffc020589a:	6d46                	ld	s10,80(sp)
ffffffffc020589c:	6da6                	ld	s11,72(sp)
ffffffffc020589e:	8552                	mv	a0,s4
ffffffffc02058a0:	6a0a                	ld	s4,128(sp)
ffffffffc02058a2:	614d                	addi	sp,sp,176
ffffffffc02058a4:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02058a6:	463d                	li	a2,15
ffffffffc02058a8:	85ca                	mv	a1,s2
ffffffffc02058aa:	1808                	addi	a0,sp,48
ffffffffc02058ac:	7ce000ef          	jal	ra,ffffffffc020607a <memcpy>
    if (mm != NULL) {
ffffffffc02058b0:	e20993e3          	bnez	s3,ffffffffc02056d6 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02058b4:	000db783          	ld	a5,0(s11)
ffffffffc02058b8:	779c                	ld	a5,40(a5)
ffffffffc02058ba:	e4078ae3          	beqz	a5,ffffffffc020570e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058be:	00003617          	auipc	a2,0x3
ffffffffc02058c2:	b9260613          	addi	a2,a2,-1134 # ffffffffc0208450 <default_pmm_manager+0x8a8>
ffffffffc02058c6:	21200593          	li	a1,530
ffffffffc02058ca:	00003517          	auipc	a0,0x3
ffffffffc02058ce:	99e50513          	addi	a0,a0,-1634 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc02058d2:	937fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc02058d6:	8526                	mv	a0,s1
ffffffffc02058d8:	c1cff0ef          	jal	ra,ffffffffc0204cf4 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058dc:	8526                	mv	a0,s1
ffffffffc02058de:	ecafb0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058e2:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02058e4:	8552                	mv	a0,s4
ffffffffc02058e6:	94fff0ef          	jal	ra,ffffffffc0205234 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02058ea:	5a71                	li	s4,-4
ffffffffc02058ec:	bfe5                	j	ffffffffc02058e4 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02058ee:	0289b603          	ld	a2,40(s3)
ffffffffc02058f2:	0209b783          	ld	a5,32(s3)
ffffffffc02058f6:	1cf66d63          	bltu	a2,a5,ffffffffc0205ad0 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02058fa:	0049a783          	lw	a5,4(s3)
ffffffffc02058fe:	0017f693          	andi	a3,a5,1
ffffffffc0205902:	c291                	beqz	a3,ffffffffc0205906 <do_execve+0x292>
ffffffffc0205904:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205906:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020590a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020590c:	e779                	bnez	a4,ffffffffc02059da <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020590e:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205910:	c781                	beqz	a5,ffffffffc0205918 <do_execve+0x2a4>
ffffffffc0205912:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205916:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205918:	0026f793          	andi	a5,a3,2
ffffffffc020591c:	e3f1                	bnez	a5,ffffffffc02059e0 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc020591e:	0046f793          	andi	a5,a3,4
ffffffffc0205922:	c399                	beqz	a5,ffffffffc0205928 <do_execve+0x2b4>
ffffffffc0205924:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205928:	0109b583          	ld	a1,16(s3)
ffffffffc020592c:	4701                	li	a4,0
ffffffffc020592e:	8526                	mv	a0,s1
ffffffffc0205930:	ecafb0ef          	jal	ra,ffffffffc0200ffa <mm_map>
ffffffffc0205934:	8a2a                	mv	s4,a0
ffffffffc0205936:	ed35                	bnez	a0,ffffffffc02059b2 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205938:	0109bb83          	ld	s7,16(s3)
ffffffffc020593c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc020593e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205942:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205946:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc020594a:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc020594c:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc020594e:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205950:	054be963          	bltu	s7,s4,ffffffffc02059a2 <do_execve+0x32e>
ffffffffc0205954:	aa95                	j	ffffffffc0205ac8 <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205956:	6785                	lui	a5,0x1
ffffffffc0205958:	415b8533          	sub	a0,s7,s5
ffffffffc020595c:	9abe                	add	s5,s5,a5
ffffffffc020595e:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205962:	015a7463          	bgeu	s4,s5,ffffffffc020596a <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205966:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc020596a:	000cb683          	ld	a3,0(s9)
ffffffffc020596e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205970:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205974:	40d406b3          	sub	a3,s0,a3
ffffffffc0205978:	8699                	srai	a3,a3,0x6
ffffffffc020597a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020597c:	67e2                	ld	a5,24(sp)
ffffffffc020597e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205982:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205984:	14b87863          	bgeu	a6,a1,ffffffffc0205ad4 <do_execve+0x460>
ffffffffc0205988:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020598c:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc020598e:	9bb2                	add	s7,s7,a2
ffffffffc0205990:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205992:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205994:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205996:	6e4000ef          	jal	ra,ffffffffc020607a <memcpy>
            start += size, from += size;
ffffffffc020599a:	6622                	ld	a2,8(sp)
ffffffffc020599c:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc020599e:	054bf363          	bgeu	s7,s4,ffffffffc02059e4 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02059a2:	6c88                	ld	a0,24(s1)
ffffffffc02059a4:	866a                	mv	a2,s10
ffffffffc02059a6:	85d6                	mv	a1,s5
ffffffffc02059a8:	85cff0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc02059ac:	842a                	mv	s0,a0
ffffffffc02059ae:	f545                	bnez	a0,ffffffffc0205956 <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc02059b0:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc02059b2:	8526                	mv	a0,s1
ffffffffc02059b4:	f90fb0ef          	jal	ra,ffffffffc0201144 <exit_mmap>
    put_pgdir(mm);
ffffffffc02059b8:	8526                	mv	a0,s1
ffffffffc02059ba:	b3aff0ef          	jal	ra,ffffffffc0204cf4 <put_pgdir>
    mm_destroy(mm);
ffffffffc02059be:	8526                	mv	a0,s1
ffffffffc02059c0:	de8fb0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
    return ret;
ffffffffc02059c4:	b705                	j	ffffffffc02058e4 <do_execve+0x270>
            exit_mmap(mm);
ffffffffc02059c6:	854e                	mv	a0,s3
ffffffffc02059c8:	f7cfb0ef          	jal	ra,ffffffffc0201144 <exit_mmap>
            put_pgdir(mm);
ffffffffc02059cc:	854e                	mv	a0,s3
ffffffffc02059ce:	b26ff0ef          	jal	ra,ffffffffc0204cf4 <put_pgdir>
            mm_destroy(mm);
ffffffffc02059d2:	854e                	mv	a0,s3
ffffffffc02059d4:	dd4fb0ef          	jal	ra,ffffffffc0200fa8 <mm_destroy>
ffffffffc02059d8:	b33d                	j	ffffffffc0205706 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059da:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059de:	fb95                	bnez	a5,ffffffffc0205912 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02059e0:	4d5d                	li	s10,23
ffffffffc02059e2:	bf35                	j	ffffffffc020591e <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc02059e4:	0109b683          	ld	a3,16(s3)
ffffffffc02059e8:	0289b903          	ld	s2,40(s3)
ffffffffc02059ec:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc02059ee:	075bfd63          	bgeu	s7,s5,ffffffffc0205a68 <do_execve+0x3f4>
            if (start == end) {
ffffffffc02059f2:	dd7901e3          	beq	s2,s7,ffffffffc02057b4 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02059f6:	6785                	lui	a5,0x1
ffffffffc02059f8:	00fb8533          	add	a0,s7,a5
ffffffffc02059fc:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205a00:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205a04:	0b597d63          	bgeu	s2,s5,ffffffffc0205abe <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205a08:	000cb683          	ld	a3,0(s9)
ffffffffc0205a0c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a0e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205a12:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a16:	8699                	srai	a3,a3,0x6
ffffffffc0205a18:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a1a:	67e2                	ld	a5,24(sp)
ffffffffc0205a1c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a20:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a22:	0ac5f963          	bgeu	a1,a2,ffffffffc0205ad4 <do_execve+0x460>
ffffffffc0205a26:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a2a:	8652                	mv	a2,s4
ffffffffc0205a2c:	4581                	li	a1,0
ffffffffc0205a2e:	96c2                	add	a3,a3,a6
ffffffffc0205a30:	9536                	add	a0,a0,a3
ffffffffc0205a32:	636000ef          	jal	ra,ffffffffc0206068 <memset>
            start += size;
ffffffffc0205a36:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205a3a:	03597463          	bgeu	s2,s5,ffffffffc0205a62 <do_execve+0x3ee>
ffffffffc0205a3e:	d6e90be3          	beq	s2,a4,ffffffffc02057b4 <do_execve+0x140>
ffffffffc0205a42:	00003697          	auipc	a3,0x3
ffffffffc0205a46:	a3668693          	addi	a3,a3,-1482 # ffffffffc0208478 <default_pmm_manager+0x8d0>
ffffffffc0205a4a:	00001617          	auipc	a2,0x1
ffffffffc0205a4e:	10660613          	addi	a2,a2,262 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205a52:	26700593          	li	a1,615
ffffffffc0205a56:	00003517          	auipc	a0,0x3
ffffffffc0205a5a:	81250513          	addi	a0,a0,-2030 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205a5e:	faafa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205a62:	ff5710e3          	bne	a4,s5,ffffffffc0205a42 <do_execve+0x3ce>
ffffffffc0205a66:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205a68:	d52bf6e3          	bgeu	s7,s2,ffffffffc02057b4 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a6c:	6c88                	ld	a0,24(s1)
ffffffffc0205a6e:	866a                	mv	a2,s10
ffffffffc0205a70:	85d6                	mv	a1,s5
ffffffffc0205a72:	f93fe0ef          	jal	ra,ffffffffc0204a04 <pgdir_alloc_page>
ffffffffc0205a76:	842a                	mv	s0,a0
ffffffffc0205a78:	dd05                	beqz	a0,ffffffffc02059b0 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a7a:	6785                	lui	a5,0x1
ffffffffc0205a7c:	415b8533          	sub	a0,s7,s5
ffffffffc0205a80:	9abe                	add	s5,s5,a5
ffffffffc0205a82:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a86:	01597463          	bgeu	s2,s5,ffffffffc0205a8e <do_execve+0x41a>
                size -= la - end;
ffffffffc0205a8a:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205a8e:	000cb683          	ld	a3,0(s9)
ffffffffc0205a92:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a94:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205a98:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a9c:	8699                	srai	a3,a3,0x6
ffffffffc0205a9e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205aa0:	67e2                	ld	a5,24(sp)
ffffffffc0205aa2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205aa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205aa8:	02b87663          	bgeu	a6,a1,ffffffffc0205ad4 <do_execve+0x460>
ffffffffc0205aac:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ab0:	4581                	li	a1,0
            start += size;
ffffffffc0205ab2:	9bb2                	add	s7,s7,a2
ffffffffc0205ab4:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ab6:	9536                	add	a0,a0,a3
ffffffffc0205ab8:	5b0000ef          	jal	ra,ffffffffc0206068 <memset>
ffffffffc0205abc:	b775                	j	ffffffffc0205a68 <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205abe:	417a8a33          	sub	s4,s5,s7
ffffffffc0205ac2:	b799                	j	ffffffffc0205a08 <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205ac4:	5a75                	li	s4,-3
ffffffffc0205ac6:	b3c1                	j	ffffffffc0205886 <do_execve+0x212>
        while (start < end) {
ffffffffc0205ac8:	86de                	mv	a3,s7
ffffffffc0205aca:	bf39                	j	ffffffffc02059e8 <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205acc:	5a71                	li	s4,-4
ffffffffc0205ace:	bdc5                	j	ffffffffc02059be <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205ad0:	5a61                	li	s4,-8
ffffffffc0205ad2:	b5c5                	j	ffffffffc02059b2 <do_execve+0x33e>
ffffffffc0205ad4:	00001617          	auipc	a2,0x1
ffffffffc0205ad8:	64c60613          	addi	a2,a2,1612 # ffffffffc0207120 <commands+0x9e0>
ffffffffc0205adc:	06900593          	li	a1,105
ffffffffc0205ae0:	00001517          	auipc	a0,0x1
ffffffffc0205ae4:	63050513          	addi	a0,a0,1584 # ffffffffc0207110 <commands+0x9d0>
ffffffffc0205ae8:	f20fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205aec:	00002617          	auipc	a2,0x2
ffffffffc0205af0:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0207648 <commands+0xf08>
ffffffffc0205af4:	28200593          	li	a1,642
ffffffffc0205af8:	00002517          	auipc	a0,0x2
ffffffffc0205afc:	77050513          	addi	a0,a0,1904 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205b00:	f08fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b04:	00003697          	auipc	a3,0x3
ffffffffc0205b08:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0208590 <default_pmm_manager+0x9e8>
ffffffffc0205b0c:	00001617          	auipc	a2,0x1
ffffffffc0205b10:	04460613          	addi	a2,a2,68 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205b14:	27d00593          	li	a1,637
ffffffffc0205b18:	00002517          	auipc	a0,0x2
ffffffffc0205b1c:	75050513          	addi	a0,a0,1872 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205b20:	ee8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b24:	00003697          	auipc	a3,0x3
ffffffffc0205b28:	a2468693          	addi	a3,a3,-1500 # ffffffffc0208548 <default_pmm_manager+0x9a0>
ffffffffc0205b2c:	00001617          	auipc	a2,0x1
ffffffffc0205b30:	02460613          	addi	a2,a2,36 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205b34:	27c00593          	li	a1,636
ffffffffc0205b38:	00002517          	auipc	a0,0x2
ffffffffc0205b3c:	73050513          	addi	a0,a0,1840 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205b40:	ec8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b44:	00003697          	auipc	a3,0x3
ffffffffc0205b48:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0208500 <default_pmm_manager+0x958>
ffffffffc0205b4c:	00001617          	auipc	a2,0x1
ffffffffc0205b50:	00460613          	addi	a2,a2,4 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205b54:	27b00593          	li	a1,635
ffffffffc0205b58:	00002517          	auipc	a0,0x2
ffffffffc0205b5c:	71050513          	addi	a0,a0,1808 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205b60:	ea8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b64:	00003697          	auipc	a3,0x3
ffffffffc0205b68:	95468693          	addi	a3,a3,-1708 # ffffffffc02084b8 <default_pmm_manager+0x910>
ffffffffc0205b6c:	00001617          	auipc	a2,0x1
ffffffffc0205b70:	fe460613          	addi	a2,a2,-28 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205b74:	27a00593          	li	a1,634
ffffffffc0205b78:	00002517          	auipc	a0,0x2
ffffffffc0205b7c:	6f050513          	addi	a0,a0,1776 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205b80:	e88fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205b84 <do_yield>:
    current->need_resched = 1;
ffffffffc0205b84:	000ad797          	auipc	a5,0xad
ffffffffc0205b88:	cec7b783          	ld	a5,-788(a5) # ffffffffc02b2870 <current>
ffffffffc0205b8c:	4705                	li	a4,1
ffffffffc0205b8e:	ef98                	sd	a4,24(a5)
}
ffffffffc0205b90:	4501                	li	a0,0
ffffffffc0205b92:	8082                	ret

ffffffffc0205b94 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205b94:	1101                	addi	sp,sp,-32
ffffffffc0205b96:	e822                	sd	s0,16(sp)
ffffffffc0205b98:	e426                	sd	s1,8(sp)
ffffffffc0205b9a:	ec06                	sd	ra,24(sp)
ffffffffc0205b9c:	842e                	mv	s0,a1
ffffffffc0205b9e:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ba0:	c999                	beqz	a1,ffffffffc0205bb6 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205ba2:	000ad797          	auipc	a5,0xad
ffffffffc0205ba6:	cce7b783          	ld	a5,-818(a5) # ffffffffc02b2870 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205baa:	7788                	ld	a0,40(a5)
ffffffffc0205bac:	4685                	li	a3,1
ffffffffc0205bae:	4611                	li	a2,4
ffffffffc0205bb0:	c07fb0ef          	jal	ra,ffffffffc02017b6 <user_mem_check>
ffffffffc0205bb4:	c909                	beqz	a0,ffffffffc0205bc6 <do_wait+0x32>
ffffffffc0205bb6:	85a2                	mv	a1,s0
}
ffffffffc0205bb8:	6442                	ld	s0,16(sp)
ffffffffc0205bba:	60e2                	ld	ra,24(sp)
ffffffffc0205bbc:	8526                	mv	a0,s1
ffffffffc0205bbe:	64a2                	ld	s1,8(sp)
ffffffffc0205bc0:	6105                	addi	sp,sp,32
ffffffffc0205bc2:	fbcff06f          	j	ffffffffc020537e <do_wait.part.0>
ffffffffc0205bc6:	60e2                	ld	ra,24(sp)
ffffffffc0205bc8:	6442                	ld	s0,16(sp)
ffffffffc0205bca:	64a2                	ld	s1,8(sp)
ffffffffc0205bcc:	5575                	li	a0,-3
ffffffffc0205bce:	6105                	addi	sp,sp,32
ffffffffc0205bd0:	8082                	ret

ffffffffc0205bd2 <do_kill>:
do_kill(int pid) {
ffffffffc0205bd2:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205bd4:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205bd6:	e406                	sd	ra,8(sp)
ffffffffc0205bd8:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205bda:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205bde:	17f9                	addi	a5,a5,-2
ffffffffc0205be0:	02e7e963          	bltu	a5,a4,ffffffffc0205c12 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205be4:	842a                	mv	s0,a0
ffffffffc0205be6:	45a9                	li	a1,10
ffffffffc0205be8:	2501                	sext.w	a0,a0
ffffffffc0205bea:	097000ef          	jal	ra,ffffffffc0206480 <hash32>
ffffffffc0205bee:	02051793          	slli	a5,a0,0x20
ffffffffc0205bf2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205bf6:	000a9797          	auipc	a5,0xa9
ffffffffc0205bfa:	bf278793          	addi	a5,a5,-1038 # ffffffffc02ae7e8 <hash_list>
ffffffffc0205bfe:	953e                	add	a0,a0,a5
ffffffffc0205c00:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205c02:	a029                	j	ffffffffc0205c0c <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205c04:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205c08:	00870b63          	beq	a4,s0,ffffffffc0205c1e <do_kill+0x4c>
ffffffffc0205c0c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c0e:	fef51be3          	bne	a0,a5,ffffffffc0205c04 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205c12:	5475                	li	s0,-3
}
ffffffffc0205c14:	60a2                	ld	ra,8(sp)
ffffffffc0205c16:	8522                	mv	a0,s0
ffffffffc0205c18:	6402                	ld	s0,0(sp)
ffffffffc0205c1a:	0141                	addi	sp,sp,16
ffffffffc0205c1c:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205c1e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205c22:	00177693          	andi	a3,a4,1
ffffffffc0205c26:	e295                	bnez	a3,ffffffffc0205c4a <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c28:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205c2a:	00176713          	ori	a4,a4,1
ffffffffc0205c2e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205c32:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c34:	fe06d0e3          	bgez	a3,ffffffffc0205c14 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205c38:	f2878513          	addi	a0,a5,-216
ffffffffc0205c3c:	1c4000ef          	jal	ra,ffffffffc0205e00 <wakeup_proc>
}
ffffffffc0205c40:	60a2                	ld	ra,8(sp)
ffffffffc0205c42:	8522                	mv	a0,s0
ffffffffc0205c44:	6402                	ld	s0,0(sp)
ffffffffc0205c46:	0141                	addi	sp,sp,16
ffffffffc0205c48:	8082                	ret
        return -E_KILLED;
ffffffffc0205c4a:	545d                	li	s0,-9
ffffffffc0205c4c:	b7e1                	j	ffffffffc0205c14 <do_kill+0x42>

ffffffffc0205c4e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205c4e:	1101                	addi	sp,sp,-32
ffffffffc0205c50:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205c52:	000ad797          	auipc	a5,0xad
ffffffffc0205c56:	b9678793          	addi	a5,a5,-1130 # ffffffffc02b27e8 <proc_list>
ffffffffc0205c5a:	ec06                	sd	ra,24(sp)
ffffffffc0205c5c:	e822                	sd	s0,16(sp)
ffffffffc0205c5e:	e04a                	sd	s2,0(sp)
ffffffffc0205c60:	000a9497          	auipc	s1,0xa9
ffffffffc0205c64:	b8848493          	addi	s1,s1,-1144 # ffffffffc02ae7e8 <hash_list>
ffffffffc0205c68:	e79c                	sd	a5,8(a5)
ffffffffc0205c6a:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205c6c:	000ad717          	auipc	a4,0xad
ffffffffc0205c70:	b7c70713          	addi	a4,a4,-1156 # ffffffffc02b27e8 <proc_list>
ffffffffc0205c74:	87a6                	mv	a5,s1
ffffffffc0205c76:	e79c                	sd	a5,8(a5)
ffffffffc0205c78:	e39c                	sd	a5,0(a5)
ffffffffc0205c7a:	07c1                	addi	a5,a5,16
ffffffffc0205c7c:	fef71de3          	bne	a4,a5,ffffffffc0205c76 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205c80:	f77fe0ef          	jal	ra,ffffffffc0204bf6 <alloc_proc>
ffffffffc0205c84:	000ad917          	auipc	s2,0xad
ffffffffc0205c88:	bf490913          	addi	s2,s2,-1036 # ffffffffc02b2878 <idleproc>
ffffffffc0205c8c:	00a93023          	sd	a0,0(s2)
ffffffffc0205c90:	0e050f63          	beqz	a0,ffffffffc0205d8e <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205c94:	4789                	li	a5,2
ffffffffc0205c96:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c98:	00003797          	auipc	a5,0x3
ffffffffc0205c9c:	36878793          	addi	a5,a5,872 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ca0:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ca4:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205ca6:	4785                	li	a5,1
ffffffffc0205ca8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205caa:	4641                	li	a2,16
ffffffffc0205cac:	4581                	li	a1,0
ffffffffc0205cae:	8522                	mv	a0,s0
ffffffffc0205cb0:	3b8000ef          	jal	ra,ffffffffc0206068 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205cb4:	463d                	li	a2,15
ffffffffc0205cb6:	00003597          	auipc	a1,0x3
ffffffffc0205cba:	93a58593          	addi	a1,a1,-1734 # ffffffffc02085f0 <default_pmm_manager+0xa48>
ffffffffc0205cbe:	8522                	mv	a0,s0
ffffffffc0205cc0:	3ba000ef          	jal	ra,ffffffffc020607a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205cc4:	000ad717          	auipc	a4,0xad
ffffffffc0205cc8:	bc470713          	addi	a4,a4,-1084 # ffffffffc02b2888 <nr_process>
ffffffffc0205ccc:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205cce:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cd2:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205cd4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cd6:	4581                	li	a1,0
ffffffffc0205cd8:	00000517          	auipc	a0,0x0
ffffffffc0205cdc:	87850513          	addi	a0,a0,-1928 # ffffffffc0205550 <init_main>
    nr_process ++;
ffffffffc0205ce0:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205ce2:	000ad797          	auipc	a5,0xad
ffffffffc0205ce6:	b8d7b723          	sd	a3,-1138(a5) # ffffffffc02b2870 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cea:	cfaff0ef          	jal	ra,ffffffffc02051e4 <kernel_thread>
ffffffffc0205cee:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205cf0:	08a05363          	blez	a0,ffffffffc0205d76 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205cf4:	6789                	lui	a5,0x2
ffffffffc0205cf6:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205cfa:	17f9                	addi	a5,a5,-2
ffffffffc0205cfc:	2501                	sext.w	a0,a0
ffffffffc0205cfe:	02e7e363          	bltu	a5,a4,ffffffffc0205d24 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d02:	45a9                	li	a1,10
ffffffffc0205d04:	77c000ef          	jal	ra,ffffffffc0206480 <hash32>
ffffffffc0205d08:	02051793          	slli	a5,a0,0x20
ffffffffc0205d0c:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205d10:	96a6                	add	a3,a3,s1
ffffffffc0205d12:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205d14:	a029                	j	ffffffffc0205d1e <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205d16:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0205d1a:	04870b63          	beq	a4,s0,ffffffffc0205d70 <proc_init+0x122>
    return listelm->next;
ffffffffc0205d1e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d20:	fef69be3          	bne	a3,a5,ffffffffc0205d16 <proc_init+0xc8>
    return NULL;
ffffffffc0205d24:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d26:	0b478493          	addi	s1,a5,180
ffffffffc0205d2a:	4641                	li	a2,16
ffffffffc0205d2c:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205d2e:	000ad417          	auipc	s0,0xad
ffffffffc0205d32:	b5240413          	addi	s0,s0,-1198 # ffffffffc02b2880 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d36:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205d38:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d3a:	32e000ef          	jal	ra,ffffffffc0206068 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205d3e:	463d                	li	a2,15
ffffffffc0205d40:	00003597          	auipc	a1,0x3
ffffffffc0205d44:	8d858593          	addi	a1,a1,-1832 # ffffffffc0208618 <default_pmm_manager+0xa70>
ffffffffc0205d48:	8526                	mv	a0,s1
ffffffffc0205d4a:	330000ef          	jal	ra,ffffffffc020607a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205d4e:	00093783          	ld	a5,0(s2)
ffffffffc0205d52:	cbb5                	beqz	a5,ffffffffc0205dc6 <proc_init+0x178>
ffffffffc0205d54:	43dc                	lw	a5,4(a5)
ffffffffc0205d56:	eba5                	bnez	a5,ffffffffc0205dc6 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205d58:	601c                	ld	a5,0(s0)
ffffffffc0205d5a:	c7b1                	beqz	a5,ffffffffc0205da6 <proc_init+0x158>
ffffffffc0205d5c:	43d8                	lw	a4,4(a5)
ffffffffc0205d5e:	4785                	li	a5,1
ffffffffc0205d60:	04f71363          	bne	a4,a5,ffffffffc0205da6 <proc_init+0x158>
}
ffffffffc0205d64:	60e2                	ld	ra,24(sp)
ffffffffc0205d66:	6442                	ld	s0,16(sp)
ffffffffc0205d68:	64a2                	ld	s1,8(sp)
ffffffffc0205d6a:	6902                	ld	s2,0(sp)
ffffffffc0205d6c:	6105                	addi	sp,sp,32
ffffffffc0205d6e:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205d70:	f2878793          	addi	a5,a5,-216
ffffffffc0205d74:	bf4d                	j	ffffffffc0205d26 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205d76:	00003617          	auipc	a2,0x3
ffffffffc0205d7a:	88260613          	addi	a2,a2,-1918 # ffffffffc02085f8 <default_pmm_manager+0xa50>
ffffffffc0205d7e:	38b00593          	li	a1,907
ffffffffc0205d82:	00002517          	auipc	a0,0x2
ffffffffc0205d86:	4e650513          	addi	a0,a0,1254 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205d8a:	c7efa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205d8e:	00003617          	auipc	a2,0x3
ffffffffc0205d92:	84a60613          	addi	a2,a2,-1974 # ffffffffc02085d8 <default_pmm_manager+0xa30>
ffffffffc0205d96:	37d00593          	li	a1,893
ffffffffc0205d9a:	00002517          	auipc	a0,0x2
ffffffffc0205d9e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205da2:	c66fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205da6:	00003697          	auipc	a3,0x3
ffffffffc0205daa:	8a268693          	addi	a3,a3,-1886 # ffffffffc0208648 <default_pmm_manager+0xaa0>
ffffffffc0205dae:	00001617          	auipc	a2,0x1
ffffffffc0205db2:	da260613          	addi	a2,a2,-606 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205db6:	39200593          	li	a1,914
ffffffffc0205dba:	00002517          	auipc	a0,0x2
ffffffffc0205dbe:	4ae50513          	addi	a0,a0,1198 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205dc2:	c46fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205dc6:	00003697          	auipc	a3,0x3
ffffffffc0205dca:	85a68693          	addi	a3,a3,-1958 # ffffffffc0208620 <default_pmm_manager+0xa78>
ffffffffc0205dce:	00001617          	auipc	a2,0x1
ffffffffc0205dd2:	d8260613          	addi	a2,a2,-638 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205dd6:	39100593          	li	a1,913
ffffffffc0205dda:	00002517          	auipc	a0,0x2
ffffffffc0205dde:	48e50513          	addi	a0,a0,1166 # ffffffffc0208268 <default_pmm_manager+0x6c0>
ffffffffc0205de2:	c26fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205de6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205de6:	1141                	addi	sp,sp,-16
ffffffffc0205de8:	e022                	sd	s0,0(sp)
ffffffffc0205dea:	e406                	sd	ra,8(sp)
ffffffffc0205dec:	000ad417          	auipc	s0,0xad
ffffffffc0205df0:	a8440413          	addi	s0,s0,-1404 # ffffffffc02b2870 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205df4:	6018                	ld	a4,0(s0)
ffffffffc0205df6:	6f1c                	ld	a5,24(a4)
ffffffffc0205df8:	dffd                	beqz	a5,ffffffffc0205df6 <cpu_idle+0x10>
            schedule();
ffffffffc0205dfa:	086000ef          	jal	ra,ffffffffc0205e80 <schedule>
ffffffffc0205dfe:	bfdd                	j	ffffffffc0205df4 <cpu_idle+0xe>

ffffffffc0205e00 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e00:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205e02:	1101                	addi	sp,sp,-32
ffffffffc0205e04:	ec06                	sd	ra,24(sp)
ffffffffc0205e06:	e822                	sd	s0,16(sp)
ffffffffc0205e08:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e0a:	478d                	li	a5,3
ffffffffc0205e0c:	04f70b63          	beq	a4,a5,ffffffffc0205e62 <wakeup_proc+0x62>
ffffffffc0205e10:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e12:	100027f3          	csrr	a5,sstatus
ffffffffc0205e16:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205e18:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e1a:	ef9d                	bnez	a5,ffffffffc0205e58 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e1c:	4789                	li	a5,2
ffffffffc0205e1e:	02f70163          	beq	a4,a5,ffffffffc0205e40 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205e22:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205e24:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205e28:	e491                	bnez	s1,ffffffffc0205e34 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e2a:	60e2                	ld	ra,24(sp)
ffffffffc0205e2c:	6442                	ld	s0,16(sp)
ffffffffc0205e2e:	64a2                	ld	s1,8(sp)
ffffffffc0205e30:	6105                	addi	sp,sp,32
ffffffffc0205e32:	8082                	ret
ffffffffc0205e34:	6442                	ld	s0,16(sp)
ffffffffc0205e36:	60e2                	ld	ra,24(sp)
ffffffffc0205e38:	64a2                	ld	s1,8(sp)
ffffffffc0205e3a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205e3c:	fe2fa06f          	j	ffffffffc020061e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205e40:	00003617          	auipc	a2,0x3
ffffffffc0205e44:	86860613          	addi	a2,a2,-1944 # ffffffffc02086a8 <default_pmm_manager+0xb00>
ffffffffc0205e48:	45c9                	li	a1,18
ffffffffc0205e4a:	00003517          	auipc	a0,0x3
ffffffffc0205e4e:	84650513          	addi	a0,a0,-1978 # ffffffffc0208690 <default_pmm_manager+0xae8>
ffffffffc0205e52:	c1efa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205e56:	bfc9                	j	ffffffffc0205e28 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205e58:	fccfa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e5c:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205e5e:	4485                	li	s1,1
ffffffffc0205e60:	bf75                	j	ffffffffc0205e1c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e62:	00003697          	auipc	a3,0x3
ffffffffc0205e66:	80e68693          	addi	a3,a3,-2034 # ffffffffc0208670 <default_pmm_manager+0xac8>
ffffffffc0205e6a:	00001617          	auipc	a2,0x1
ffffffffc0205e6e:	ce660613          	addi	a2,a2,-794 # ffffffffc0206b50 <commands+0x410>
ffffffffc0205e72:	45a5                	li	a1,9
ffffffffc0205e74:	00003517          	auipc	a0,0x3
ffffffffc0205e78:	81c50513          	addi	a0,a0,-2020 # ffffffffc0208690 <default_pmm_manager+0xae8>
ffffffffc0205e7c:	b8cfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205e80 <schedule>:

void
schedule(void) {
ffffffffc0205e80:	1141                	addi	sp,sp,-16
ffffffffc0205e82:	e406                	sd	ra,8(sp)
ffffffffc0205e84:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e86:	100027f3          	csrr	a5,sstatus
ffffffffc0205e8a:	8b89                	andi	a5,a5,2
ffffffffc0205e8c:	4401                	li	s0,0
ffffffffc0205e8e:	efbd                	bnez	a5,ffffffffc0205f0c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205e90:	000ad897          	auipc	a7,0xad
ffffffffc0205e94:	9e08b883          	ld	a7,-1568(a7) # ffffffffc02b2870 <current>
ffffffffc0205e98:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205e9c:	000ad517          	auipc	a0,0xad
ffffffffc0205ea0:	9dc53503          	ld	a0,-1572(a0) # ffffffffc02b2878 <idleproc>
ffffffffc0205ea4:	04a88e63          	beq	a7,a0,ffffffffc0205f00 <schedule+0x80>
ffffffffc0205ea8:	0c888693          	addi	a3,a7,200
ffffffffc0205eac:	000ad617          	auipc	a2,0xad
ffffffffc0205eb0:	93c60613          	addi	a2,a2,-1732 # ffffffffc02b27e8 <proc_list>
        le = last;
ffffffffc0205eb4:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205eb6:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205eb8:	4809                	li	a6,2
ffffffffc0205eba:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ebc:	00c78863          	beq	a5,a2,ffffffffc0205ecc <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ec0:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205ec4:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ec8:	03070163          	beq	a4,a6,ffffffffc0205eea <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205ecc:	fef697e3          	bne	a3,a5,ffffffffc0205eba <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ed0:	ed89                	bnez	a1,ffffffffc0205eea <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205ed2:	451c                	lw	a5,8(a0)
ffffffffc0205ed4:	2785                	addiw	a5,a5,1
ffffffffc0205ed6:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205ed8:	00a88463          	beq	a7,a0,ffffffffc0205ee0 <schedule+0x60>
            proc_run(next);
ffffffffc0205edc:	e8ffe0ef          	jal	ra,ffffffffc0204d6a <proc_run>
    if (flag) {
ffffffffc0205ee0:	e819                	bnez	s0,ffffffffc0205ef6 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ee2:	60a2                	ld	ra,8(sp)
ffffffffc0205ee4:	6402                	ld	s0,0(sp)
ffffffffc0205ee6:	0141                	addi	sp,sp,16
ffffffffc0205ee8:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205eea:	4198                	lw	a4,0(a1)
ffffffffc0205eec:	4789                	li	a5,2
ffffffffc0205eee:	fef712e3          	bne	a4,a5,ffffffffc0205ed2 <schedule+0x52>
ffffffffc0205ef2:	852e                	mv	a0,a1
ffffffffc0205ef4:	bff9                	j	ffffffffc0205ed2 <schedule+0x52>
}
ffffffffc0205ef6:	6402                	ld	s0,0(sp)
ffffffffc0205ef8:	60a2                	ld	ra,8(sp)
ffffffffc0205efa:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205efc:	f22fa06f          	j	ffffffffc020061e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f00:	000ad617          	auipc	a2,0xad
ffffffffc0205f04:	8e860613          	addi	a2,a2,-1816 # ffffffffc02b27e8 <proc_list>
ffffffffc0205f08:	86b2                	mv	a3,a2
ffffffffc0205f0a:	b76d                	j	ffffffffc0205eb4 <schedule+0x34>
        intr_disable();
ffffffffc0205f0c:	f18fa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205f10:	4405                	li	s0,1
ffffffffc0205f12:	bfbd                	j	ffffffffc0205e90 <schedule+0x10>

ffffffffc0205f14 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205f14:	000ad797          	auipc	a5,0xad
ffffffffc0205f18:	95c7b783          	ld	a5,-1700(a5) # ffffffffc02b2870 <current>
}
ffffffffc0205f1c:	43c8                	lw	a0,4(a5)
ffffffffc0205f1e:	8082                	ret

ffffffffc0205f20 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205f20:	4501                	li	a0,0
ffffffffc0205f22:	8082                	ret

ffffffffc0205f24 <sys_putc>:
    cputchar(c);
ffffffffc0205f24:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205f26:	1141                	addi	sp,sp,-16
ffffffffc0205f28:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205f2a:	9d8fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0205f2e:	60a2                	ld	ra,8(sp)
ffffffffc0205f30:	4501                	li	a0,0
ffffffffc0205f32:	0141                	addi	sp,sp,16
ffffffffc0205f34:	8082                	ret

ffffffffc0205f36 <sys_kill>:
    return do_kill(pid);
ffffffffc0205f36:	4108                	lw	a0,0(a0)
ffffffffc0205f38:	c9bff06f          	j	ffffffffc0205bd2 <do_kill>

ffffffffc0205f3c <sys_yield>:
    return do_yield();
ffffffffc0205f3c:	c49ff06f          	j	ffffffffc0205b84 <do_yield>

ffffffffc0205f40 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205f40:	6d14                	ld	a3,24(a0)
ffffffffc0205f42:	6910                	ld	a2,16(a0)
ffffffffc0205f44:	650c                	ld	a1,8(a0)
ffffffffc0205f46:	6108                	ld	a0,0(a0)
ffffffffc0205f48:	f2cff06f          	j	ffffffffc0205674 <do_execve>

ffffffffc0205f4c <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205f4c:	650c                	ld	a1,8(a0)
ffffffffc0205f4e:	4108                	lw	a0,0(a0)
ffffffffc0205f50:	c45ff06f          	j	ffffffffc0205b94 <do_wait>

ffffffffc0205f54 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205f54:	000ad797          	auipc	a5,0xad
ffffffffc0205f58:	91c7b783          	ld	a5,-1764(a5) # ffffffffc02b2870 <current>
ffffffffc0205f5c:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205f5e:	4501                	li	a0,0
ffffffffc0205f60:	6a0c                	ld	a1,16(a2)
ffffffffc0205f62:	e75fe06f          	j	ffffffffc0204dd6 <do_fork>

ffffffffc0205f66 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205f66:	4108                	lw	a0,0(a0)
ffffffffc0205f68:	accff06f          	j	ffffffffc0205234 <do_exit>

ffffffffc0205f6c <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205f6c:	715d                	addi	sp,sp,-80
ffffffffc0205f6e:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f70:	000ad497          	auipc	s1,0xad
ffffffffc0205f74:	90048493          	addi	s1,s1,-1792 # ffffffffc02b2870 <current>
ffffffffc0205f78:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205f7a:	e0a2                	sd	s0,64(sp)
ffffffffc0205f7c:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f7e:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205f80:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f82:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205f84:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f88:	0327ee63          	bltu	a5,s2,ffffffffc0205fc4 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205f8c:	00391713          	slli	a4,s2,0x3
ffffffffc0205f90:	00002797          	auipc	a5,0x2
ffffffffc0205f94:	78078793          	addi	a5,a5,1920 # ffffffffc0208710 <syscalls>
ffffffffc0205f98:	97ba                	add	a5,a5,a4
ffffffffc0205f9a:	639c                	ld	a5,0(a5)
ffffffffc0205f9c:	c785                	beqz	a5,ffffffffc0205fc4 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205f9e:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205fa0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205fa2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205fa4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205fa6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205fa8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205faa:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205fac:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205fae:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205fb0:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fb2:	0028                	addi	a0,sp,8
ffffffffc0205fb4:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205fb6:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fb8:	e828                	sd	a0,80(s0)
}
ffffffffc0205fba:	6406                	ld	s0,64(sp)
ffffffffc0205fbc:	74e2                	ld	s1,56(sp)
ffffffffc0205fbe:	7942                	ld	s2,48(sp)
ffffffffc0205fc0:	6161                	addi	sp,sp,80
ffffffffc0205fc2:	8082                	ret
    print_trapframe(tf);
ffffffffc0205fc4:	8522                	mv	a0,s0
ffffffffc0205fc6:	84dfa0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205fca:	609c                	ld	a5,0(s1)
ffffffffc0205fcc:	86ca                	mv	a3,s2
ffffffffc0205fce:	00002617          	auipc	a2,0x2
ffffffffc0205fd2:	6fa60613          	addi	a2,a2,1786 # ffffffffc02086c8 <default_pmm_manager+0xb20>
ffffffffc0205fd6:	43d8                	lw	a4,4(a5)
ffffffffc0205fd8:	06200593          	li	a1,98
ffffffffc0205fdc:	0b478793          	addi	a5,a5,180
ffffffffc0205fe0:	00002517          	auipc	a0,0x2
ffffffffc0205fe4:	71850513          	addi	a0,a0,1816 # ffffffffc02086f8 <default_pmm_manager+0xb50>
ffffffffc0205fe8:	a20fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205fec <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205fec:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205ff0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205ff2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205ff4:	cb81                	beqz	a5,ffffffffc0206004 <strlen+0x18>
        cnt ++;
ffffffffc0205ff6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205ff8:	00a707b3          	add	a5,a4,a0
ffffffffc0205ffc:	0007c783          	lbu	a5,0(a5)
ffffffffc0206000:	fbfd                	bnez	a5,ffffffffc0205ff6 <strlen+0xa>
ffffffffc0206002:	8082                	ret
    }
    return cnt;
}
ffffffffc0206004:	8082                	ret

ffffffffc0206006 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206006:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206008:	e589                	bnez	a1,ffffffffc0206012 <strnlen+0xc>
ffffffffc020600a:	a811                	j	ffffffffc020601e <strnlen+0x18>
        cnt ++;
ffffffffc020600c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020600e:	00f58863          	beq	a1,a5,ffffffffc020601e <strnlen+0x18>
ffffffffc0206012:	00f50733          	add	a4,a0,a5
ffffffffc0206016:	00074703          	lbu	a4,0(a4)
ffffffffc020601a:	fb6d                	bnez	a4,ffffffffc020600c <strnlen+0x6>
ffffffffc020601c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020601e:	852e                	mv	a0,a1
ffffffffc0206020:	8082                	ret

ffffffffc0206022 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206022:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206024:	0005c703          	lbu	a4,0(a1)
ffffffffc0206028:	0785                	addi	a5,a5,1
ffffffffc020602a:	0585                	addi	a1,a1,1
ffffffffc020602c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206030:	fb75                	bnez	a4,ffffffffc0206024 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206032:	8082                	ret

ffffffffc0206034 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206034:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206038:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020603c:	cb89                	beqz	a5,ffffffffc020604e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020603e:	0505                	addi	a0,a0,1
ffffffffc0206040:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206042:	fee789e3          	beq	a5,a4,ffffffffc0206034 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206046:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020604a:	9d19                	subw	a0,a0,a4
ffffffffc020604c:	8082                	ret
ffffffffc020604e:	4501                	li	a0,0
ffffffffc0206050:	bfed                	j	ffffffffc020604a <strcmp+0x16>

ffffffffc0206052 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206052:	00054783          	lbu	a5,0(a0)
ffffffffc0206056:	c799                	beqz	a5,ffffffffc0206064 <strchr+0x12>
        if (*s == c) {
ffffffffc0206058:	00f58763          	beq	a1,a5,ffffffffc0206066 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020605c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206060:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206062:	fbfd                	bnez	a5,ffffffffc0206058 <strchr+0x6>
    }
    return NULL;
ffffffffc0206064:	4501                	li	a0,0
}
ffffffffc0206066:	8082                	ret

ffffffffc0206068 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206068:	ca01                	beqz	a2,ffffffffc0206078 <memset+0x10>
ffffffffc020606a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020606c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020606e:	0785                	addi	a5,a5,1
ffffffffc0206070:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206074:	fec79de3          	bne	a5,a2,ffffffffc020606e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206078:	8082                	ret

ffffffffc020607a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020607a:	ca19                	beqz	a2,ffffffffc0206090 <memcpy+0x16>
ffffffffc020607c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020607e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206080:	0005c703          	lbu	a4,0(a1)
ffffffffc0206084:	0585                	addi	a1,a1,1
ffffffffc0206086:	0785                	addi	a5,a5,1
ffffffffc0206088:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020608c:	fec59ae3          	bne	a1,a2,ffffffffc0206080 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206090:	8082                	ret

ffffffffc0206092 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206092:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206096:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206098:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020609c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020609e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060a2:	f022                	sd	s0,32(sp)
ffffffffc02060a4:	ec26                	sd	s1,24(sp)
ffffffffc02060a6:	e84a                	sd	s2,16(sp)
ffffffffc02060a8:	f406                	sd	ra,40(sp)
ffffffffc02060aa:	e44e                	sd	s3,8(sp)
ffffffffc02060ac:	84aa                	mv	s1,a0
ffffffffc02060ae:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02060b0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02060b4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02060b6:	03067e63          	bgeu	a2,a6,ffffffffc02060f2 <printnum+0x60>
ffffffffc02060ba:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02060bc:	00805763          	blez	s0,ffffffffc02060ca <printnum+0x38>
ffffffffc02060c0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02060c2:	85ca                	mv	a1,s2
ffffffffc02060c4:	854e                	mv	a0,s3
ffffffffc02060c6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02060c8:	fc65                	bnez	s0,ffffffffc02060c0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060ca:	1a02                	slli	s4,s4,0x20
ffffffffc02060cc:	00002797          	auipc	a5,0x2
ffffffffc02060d0:	74478793          	addi	a5,a5,1860 # ffffffffc0208810 <syscalls+0x100>
ffffffffc02060d4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02060d8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02060da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060dc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02060e0:	70a2                	ld	ra,40(sp)
ffffffffc02060e2:	69a2                	ld	s3,8(sp)
ffffffffc02060e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060e6:	85ca                	mv	a1,s2
ffffffffc02060e8:	87a6                	mv	a5,s1
}
ffffffffc02060ea:	6942                	ld	s2,16(sp)
ffffffffc02060ec:	64e2                	ld	s1,24(sp)
ffffffffc02060ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060f0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02060f2:	03065633          	divu	a2,a2,a6
ffffffffc02060f6:	8722                	mv	a4,s0
ffffffffc02060f8:	f9bff0ef          	jal	ra,ffffffffc0206092 <printnum>
ffffffffc02060fc:	b7f9                	j	ffffffffc02060ca <printnum+0x38>

ffffffffc02060fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02060fe:	7119                	addi	sp,sp,-128
ffffffffc0206100:	f4a6                	sd	s1,104(sp)
ffffffffc0206102:	f0ca                	sd	s2,96(sp)
ffffffffc0206104:	ecce                	sd	s3,88(sp)
ffffffffc0206106:	e8d2                	sd	s4,80(sp)
ffffffffc0206108:	e4d6                	sd	s5,72(sp)
ffffffffc020610a:	e0da                	sd	s6,64(sp)
ffffffffc020610c:	fc5e                	sd	s7,56(sp)
ffffffffc020610e:	f06a                	sd	s10,32(sp)
ffffffffc0206110:	fc86                	sd	ra,120(sp)
ffffffffc0206112:	f8a2                	sd	s0,112(sp)
ffffffffc0206114:	f862                	sd	s8,48(sp)
ffffffffc0206116:	f466                	sd	s9,40(sp)
ffffffffc0206118:	ec6e                	sd	s11,24(sp)
ffffffffc020611a:	892a                	mv	s2,a0
ffffffffc020611c:	84ae                	mv	s1,a1
ffffffffc020611e:	8d32                	mv	s10,a2
ffffffffc0206120:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206122:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206126:	5b7d                	li	s6,-1
ffffffffc0206128:	00002a97          	auipc	s5,0x2
ffffffffc020612c:	714a8a93          	addi	s5,s5,1812 # ffffffffc020883c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206130:	00003b97          	auipc	s7,0x3
ffffffffc0206134:	928b8b93          	addi	s7,s7,-1752 # ffffffffc0208a58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206138:	000d4503          	lbu	a0,0(s10)
ffffffffc020613c:	001d0413          	addi	s0,s10,1
ffffffffc0206140:	01350a63          	beq	a0,s3,ffffffffc0206154 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206144:	c121                	beqz	a0,ffffffffc0206184 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206146:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206148:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020614a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020614c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206150:	ff351ae3          	bne	a0,s3,ffffffffc0206144 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206154:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206158:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020615c:	4c81                	li	s9,0
ffffffffc020615e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206160:	5c7d                	li	s8,-1
ffffffffc0206162:	5dfd                	li	s11,-1
ffffffffc0206164:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206168:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020616a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020616e:	0ff5f593          	zext.b	a1,a1
ffffffffc0206172:	00140d13          	addi	s10,s0,1
ffffffffc0206176:	04b56263          	bltu	a0,a1,ffffffffc02061ba <vprintfmt+0xbc>
ffffffffc020617a:	058a                	slli	a1,a1,0x2
ffffffffc020617c:	95d6                	add	a1,a1,s5
ffffffffc020617e:	4194                	lw	a3,0(a1)
ffffffffc0206180:	96d6                	add	a3,a3,s5
ffffffffc0206182:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206184:	70e6                	ld	ra,120(sp)
ffffffffc0206186:	7446                	ld	s0,112(sp)
ffffffffc0206188:	74a6                	ld	s1,104(sp)
ffffffffc020618a:	7906                	ld	s2,96(sp)
ffffffffc020618c:	69e6                	ld	s3,88(sp)
ffffffffc020618e:	6a46                	ld	s4,80(sp)
ffffffffc0206190:	6aa6                	ld	s5,72(sp)
ffffffffc0206192:	6b06                	ld	s6,64(sp)
ffffffffc0206194:	7be2                	ld	s7,56(sp)
ffffffffc0206196:	7c42                	ld	s8,48(sp)
ffffffffc0206198:	7ca2                	ld	s9,40(sp)
ffffffffc020619a:	7d02                	ld	s10,32(sp)
ffffffffc020619c:	6de2                	ld	s11,24(sp)
ffffffffc020619e:	6109                	addi	sp,sp,128
ffffffffc02061a0:	8082                	ret
            padc = '0';
ffffffffc02061a2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02061a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061a8:	846a                	mv	s0,s10
ffffffffc02061aa:	00140d13          	addi	s10,s0,1
ffffffffc02061ae:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02061b2:	0ff5f593          	zext.b	a1,a1
ffffffffc02061b6:	fcb572e3          	bgeu	a0,a1,ffffffffc020617a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02061ba:	85a6                	mv	a1,s1
ffffffffc02061bc:	02500513          	li	a0,37
ffffffffc02061c0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02061c2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02061c6:	8d22                	mv	s10,s0
ffffffffc02061c8:	f73788e3          	beq	a5,s3,ffffffffc0206138 <vprintfmt+0x3a>
ffffffffc02061cc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02061d0:	1d7d                	addi	s10,s10,-1
ffffffffc02061d2:	ff379de3          	bne	a5,s3,ffffffffc02061cc <vprintfmt+0xce>
ffffffffc02061d6:	b78d                	j	ffffffffc0206138 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02061d8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02061dc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061e0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02061e2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02061e6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02061ea:	02d86463          	bltu	a6,a3,ffffffffc0206212 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02061ee:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02061f2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02061f6:	0186873b          	addw	a4,a3,s8
ffffffffc02061fa:	0017171b          	slliw	a4,a4,0x1
ffffffffc02061fe:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206200:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206204:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206206:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020620a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020620e:	fed870e3          	bgeu	a6,a3,ffffffffc02061ee <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206212:	f40ddce3          	bgez	s11,ffffffffc020616a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206216:	8de2                	mv	s11,s8
ffffffffc0206218:	5c7d                	li	s8,-1
ffffffffc020621a:	bf81                	j	ffffffffc020616a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020621c:	fffdc693          	not	a3,s11
ffffffffc0206220:	96fd                	srai	a3,a3,0x3f
ffffffffc0206222:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206226:	00144603          	lbu	a2,1(s0)
ffffffffc020622a:	2d81                	sext.w	s11,s11
ffffffffc020622c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020622e:	bf35                	j	ffffffffc020616a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206230:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206234:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206238:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020623a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020623c:	bfd9                	j	ffffffffc0206212 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020623e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206240:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206244:	01174463          	blt	a4,a7,ffffffffc020624c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206248:	1a088e63          	beqz	a7,ffffffffc0206404 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020624c:	000a3603          	ld	a2,0(s4)
ffffffffc0206250:	46c1                	li	a3,16
ffffffffc0206252:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206254:	2781                	sext.w	a5,a5
ffffffffc0206256:	876e                	mv	a4,s11
ffffffffc0206258:	85a6                	mv	a1,s1
ffffffffc020625a:	854a                	mv	a0,s2
ffffffffc020625c:	e37ff0ef          	jal	ra,ffffffffc0206092 <printnum>
            break;
ffffffffc0206260:	bde1                	j	ffffffffc0206138 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206262:	000a2503          	lw	a0,0(s4)
ffffffffc0206266:	85a6                	mv	a1,s1
ffffffffc0206268:	0a21                	addi	s4,s4,8
ffffffffc020626a:	9902                	jalr	s2
            break;
ffffffffc020626c:	b5f1                	j	ffffffffc0206138 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020626e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206270:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206274:	01174463          	blt	a4,a7,ffffffffc020627c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206278:	18088163          	beqz	a7,ffffffffc02063fa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020627c:	000a3603          	ld	a2,0(s4)
ffffffffc0206280:	46a9                	li	a3,10
ffffffffc0206282:	8a2e                	mv	s4,a1
ffffffffc0206284:	bfc1                	j	ffffffffc0206254 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206286:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020628a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020628c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020628e:	bdf1                	j	ffffffffc020616a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206290:	85a6                	mv	a1,s1
ffffffffc0206292:	02500513          	li	a0,37
ffffffffc0206296:	9902                	jalr	s2
            break;
ffffffffc0206298:	b545                	j	ffffffffc0206138 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020629a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020629e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062a0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062a2:	b5e1                	j	ffffffffc020616a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02062a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02062aa:	01174463          	blt	a4,a7,ffffffffc02062b2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02062ae:	14088163          	beqz	a7,ffffffffc02063f0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02062b2:	000a3603          	ld	a2,0(s4)
ffffffffc02062b6:	46a1                	li	a3,8
ffffffffc02062b8:	8a2e                	mv	s4,a1
ffffffffc02062ba:	bf69                	j	ffffffffc0206254 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02062bc:	03000513          	li	a0,48
ffffffffc02062c0:	85a6                	mv	a1,s1
ffffffffc02062c2:	e03e                	sd	a5,0(sp)
ffffffffc02062c4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02062c6:	85a6                	mv	a1,s1
ffffffffc02062c8:	07800513          	li	a0,120
ffffffffc02062cc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062ce:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02062d0:	6782                	ld	a5,0(sp)
ffffffffc02062d2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062d4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02062d8:	bfb5                	j	ffffffffc0206254 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02062da:	000a3403          	ld	s0,0(s4)
ffffffffc02062de:	008a0713          	addi	a4,s4,8
ffffffffc02062e2:	e03a                	sd	a4,0(sp)
ffffffffc02062e4:	14040263          	beqz	s0,ffffffffc0206428 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02062e8:	0fb05763          	blez	s11,ffffffffc02063d6 <vprintfmt+0x2d8>
ffffffffc02062ec:	02d00693          	li	a3,45
ffffffffc02062f0:	0cd79163          	bne	a5,a3,ffffffffc02063b2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062f4:	00044783          	lbu	a5,0(s0)
ffffffffc02062f8:	0007851b          	sext.w	a0,a5
ffffffffc02062fc:	cf85                	beqz	a5,ffffffffc0206334 <vprintfmt+0x236>
ffffffffc02062fe:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206302:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206306:	000c4563          	bltz	s8,ffffffffc0206310 <vprintfmt+0x212>
ffffffffc020630a:	3c7d                	addiw	s8,s8,-1
ffffffffc020630c:	036c0263          	beq	s8,s6,ffffffffc0206330 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206310:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206312:	0e0c8e63          	beqz	s9,ffffffffc020640e <vprintfmt+0x310>
ffffffffc0206316:	3781                	addiw	a5,a5,-32
ffffffffc0206318:	0ef47b63          	bgeu	s0,a5,ffffffffc020640e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020631c:	03f00513          	li	a0,63
ffffffffc0206320:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206322:	000a4783          	lbu	a5,0(s4)
ffffffffc0206326:	3dfd                	addiw	s11,s11,-1
ffffffffc0206328:	0a05                	addi	s4,s4,1
ffffffffc020632a:	0007851b          	sext.w	a0,a5
ffffffffc020632e:	ffe1                	bnez	a5,ffffffffc0206306 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206330:	01b05963          	blez	s11,ffffffffc0206342 <vprintfmt+0x244>
ffffffffc0206334:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206336:	85a6                	mv	a1,s1
ffffffffc0206338:	02000513          	li	a0,32
ffffffffc020633c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020633e:	fe0d9be3          	bnez	s11,ffffffffc0206334 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206342:	6a02                	ld	s4,0(sp)
ffffffffc0206344:	bbd5                	j	ffffffffc0206138 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206346:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206348:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020634c:	01174463          	blt	a4,a7,ffffffffc0206354 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206350:	08088d63          	beqz	a7,ffffffffc02063ea <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206354:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206358:	0a044d63          	bltz	s0,ffffffffc0206412 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020635c:	8622                	mv	a2,s0
ffffffffc020635e:	8a66                	mv	s4,s9
ffffffffc0206360:	46a9                	li	a3,10
ffffffffc0206362:	bdcd                	j	ffffffffc0206254 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206364:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206368:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020636a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020636c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206370:	8fb5                	xor	a5,a5,a3
ffffffffc0206372:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206376:	02d74163          	blt	a4,a3,ffffffffc0206398 <vprintfmt+0x29a>
ffffffffc020637a:	00369793          	slli	a5,a3,0x3
ffffffffc020637e:	97de                	add	a5,a5,s7
ffffffffc0206380:	639c                	ld	a5,0(a5)
ffffffffc0206382:	cb99                	beqz	a5,ffffffffc0206398 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206384:	86be                	mv	a3,a5
ffffffffc0206386:	00000617          	auipc	a2,0x0
ffffffffc020638a:	13a60613          	addi	a2,a2,314 # ffffffffc02064c0 <etext+0x2a>
ffffffffc020638e:	85a6                	mv	a1,s1
ffffffffc0206390:	854a                	mv	a0,s2
ffffffffc0206392:	0ce000ef          	jal	ra,ffffffffc0206460 <printfmt>
ffffffffc0206396:	b34d                	j	ffffffffc0206138 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206398:	00002617          	auipc	a2,0x2
ffffffffc020639c:	49860613          	addi	a2,a2,1176 # ffffffffc0208830 <syscalls+0x120>
ffffffffc02063a0:	85a6                	mv	a1,s1
ffffffffc02063a2:	854a                	mv	a0,s2
ffffffffc02063a4:	0bc000ef          	jal	ra,ffffffffc0206460 <printfmt>
ffffffffc02063a8:	bb41                	j	ffffffffc0206138 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02063aa:	00002417          	auipc	s0,0x2
ffffffffc02063ae:	47e40413          	addi	s0,s0,1150 # ffffffffc0208828 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063b2:	85e2                	mv	a1,s8
ffffffffc02063b4:	8522                	mv	a0,s0
ffffffffc02063b6:	e43e                	sd	a5,8(sp)
ffffffffc02063b8:	c4fff0ef          	jal	ra,ffffffffc0206006 <strnlen>
ffffffffc02063bc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02063c0:	01b05b63          	blez	s11,ffffffffc02063d6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02063c4:	67a2                	ld	a5,8(sp)
ffffffffc02063c6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02063cc:	85a6                	mv	a1,s1
ffffffffc02063ce:	8552                	mv	a0,s4
ffffffffc02063d0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063d2:	fe0d9ce3          	bnez	s11,ffffffffc02063ca <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063d6:	00044783          	lbu	a5,0(s0)
ffffffffc02063da:	00140a13          	addi	s4,s0,1
ffffffffc02063de:	0007851b          	sext.w	a0,a5
ffffffffc02063e2:	d3a5                	beqz	a5,ffffffffc0206342 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063e4:	05e00413          	li	s0,94
ffffffffc02063e8:	bf39                	j	ffffffffc0206306 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02063ea:	000a2403          	lw	s0,0(s4)
ffffffffc02063ee:	b7ad                	j	ffffffffc0206358 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02063f0:	000a6603          	lwu	a2,0(s4)
ffffffffc02063f4:	46a1                	li	a3,8
ffffffffc02063f6:	8a2e                	mv	s4,a1
ffffffffc02063f8:	bdb1                	j	ffffffffc0206254 <vprintfmt+0x156>
ffffffffc02063fa:	000a6603          	lwu	a2,0(s4)
ffffffffc02063fe:	46a9                	li	a3,10
ffffffffc0206400:	8a2e                	mv	s4,a1
ffffffffc0206402:	bd89                	j	ffffffffc0206254 <vprintfmt+0x156>
ffffffffc0206404:	000a6603          	lwu	a2,0(s4)
ffffffffc0206408:	46c1                	li	a3,16
ffffffffc020640a:	8a2e                	mv	s4,a1
ffffffffc020640c:	b5a1                	j	ffffffffc0206254 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020640e:	9902                	jalr	s2
ffffffffc0206410:	bf09                	j	ffffffffc0206322 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206412:	85a6                	mv	a1,s1
ffffffffc0206414:	02d00513          	li	a0,45
ffffffffc0206418:	e03e                	sd	a5,0(sp)
ffffffffc020641a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020641c:	6782                	ld	a5,0(sp)
ffffffffc020641e:	8a66                	mv	s4,s9
ffffffffc0206420:	40800633          	neg	a2,s0
ffffffffc0206424:	46a9                	li	a3,10
ffffffffc0206426:	b53d                	j	ffffffffc0206254 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206428:	03b05163          	blez	s11,ffffffffc020644a <vprintfmt+0x34c>
ffffffffc020642c:	02d00693          	li	a3,45
ffffffffc0206430:	f6d79de3          	bne	a5,a3,ffffffffc02063aa <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206434:	00002417          	auipc	s0,0x2
ffffffffc0206438:	3f440413          	addi	s0,s0,1012 # ffffffffc0208828 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020643c:	02800793          	li	a5,40
ffffffffc0206440:	02800513          	li	a0,40
ffffffffc0206444:	00140a13          	addi	s4,s0,1
ffffffffc0206448:	bd6d                	j	ffffffffc0206302 <vprintfmt+0x204>
ffffffffc020644a:	00002a17          	auipc	s4,0x2
ffffffffc020644e:	3dfa0a13          	addi	s4,s4,991 # ffffffffc0208829 <syscalls+0x119>
ffffffffc0206452:	02800513          	li	a0,40
ffffffffc0206456:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020645a:	05e00413          	li	s0,94
ffffffffc020645e:	b565                	j	ffffffffc0206306 <vprintfmt+0x208>

ffffffffc0206460 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206460:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206462:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206466:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206468:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020646a:	ec06                	sd	ra,24(sp)
ffffffffc020646c:	f83a                	sd	a4,48(sp)
ffffffffc020646e:	fc3e                	sd	a5,56(sp)
ffffffffc0206470:	e0c2                	sd	a6,64(sp)
ffffffffc0206472:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206474:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206476:	c89ff0ef          	jal	ra,ffffffffc02060fe <vprintfmt>
}
ffffffffc020647a:	60e2                	ld	ra,24(sp)
ffffffffc020647c:	6161                	addi	sp,sp,80
ffffffffc020647e:	8082                	ret

ffffffffc0206480 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206480:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206484:	2785                	addiw	a5,a5,1
ffffffffc0206486:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020648a:	02000793          	li	a5,32
ffffffffc020648e:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206490:	00f5553b          	srlw	a0,a0,a5
ffffffffc0206494:	8082                	ret

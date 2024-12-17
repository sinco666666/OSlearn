
bin/kernel：     文件格式 elf64-littleriscv


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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	3d250513          	addi	a0,a0,978 # ffffffffc02a1408 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	95260613          	addi	a2,a2,-1710 # ffffffffc02ac990 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	304060ef          	jal	ra,ffffffffc0206352 <memset>
    cons_init();                // init the console
ffffffffc0200052:	530000ef          	jal	ra,ffffffffc0200582 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	32a58593          	addi	a1,a1,810 # ffffffffc0206380 <etext+0x4>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	34250513          	addi	a0,a0,834 # ffffffffc02063a0 <etext+0x24>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1aa000ef          	jal	ra,ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	56a020ef          	jal	ra,ffffffffc02025d8 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5c2000ef          	jal	ra,ffffffffc0200634 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5c0000ef          	jal	ra,ffffffffc0200636 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	30e040ef          	jal	ra,ffffffffc0204388 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	2db050ef          	jal	ra,ffffffffc0205b58 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	572000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2a6030ef          	jal	ra,ffffffffc020332c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a4000ef          	jal	ra,ffffffffc020052e <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	59a000ef          	jal	ra,ffffffffc0200628 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	413050ef          	jal	ra,ffffffffc0205ca4 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	2fa50513          	addi	a0,a0,762 # ffffffffc02063a8 <etext+0x2c>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	344b8b93          	addi	s7,s7,836 # ffffffffc02a1408 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	134000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	bge	s4,s1,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	122000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	10e000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	2e250513          	addi	a0,a0,738 # ffffffffc02a1408 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	428000ef          	jal	ra,ffffffffc0200584 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	5b3050ef          	jal	ra,ffffffffc0205f34 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	57f050ef          	jal	ra,ffffffffc0205f34 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	a6c9                	j	ffffffffc0200584 <cons_putc>

ffffffffc02001c4 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c4:	1101                	addi	sp,sp,-32
ffffffffc02001c6:	e822                	sd	s0,16(sp)
ffffffffc02001c8:	ec06                	sd	ra,24(sp)
ffffffffc02001ca:	e426                	sd	s1,8(sp)
ffffffffc02001cc:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001ce:	00054503          	lbu	a0,0(a0)
ffffffffc02001d2:	c51d                	beqz	a0,ffffffffc0200200 <cputs+0x3c>
ffffffffc02001d4:	0405                	addi	s0,s0,1
ffffffffc02001d6:	4485                	li	s1,1
ffffffffc02001d8:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001da:	3aa000ef          	jal	ra,ffffffffc0200584 <cons_putc>
    (*cnt) ++;
ffffffffc02001de:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e2:	0405                	addi	s0,s0,1
ffffffffc02001e4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001e8:	f96d                	bnez	a0,ffffffffc02001da <cputs+0x16>
ffffffffc02001ea:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ee:	4529                	li	a0,10
ffffffffc02001f0:	394000ef          	jal	ra,ffffffffc0200584 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f4:	8522                	mv	a0,s0
ffffffffc02001f6:	60e2                	ld	ra,24(sp)
ffffffffc02001f8:	6442                	ld	s0,16(sp)
ffffffffc02001fa:	64a2                	ld	s1,8(sp)
ffffffffc02001fc:	6105                	addi	sp,sp,32
ffffffffc02001fe:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200200:	4405                	li	s0,1
ffffffffc0200202:	b7f5                	j	ffffffffc02001ee <cputs+0x2a>

ffffffffc0200204 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200204:	1141                	addi	sp,sp,-16
ffffffffc0200206:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200208:	3b0000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc020020c:	dd75                	beqz	a0,ffffffffc0200208 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	0141                	addi	sp,sp,16
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200216:	00006517          	auipc	a0,0x6
ffffffffc020021a:	1ca50513          	addi	a0,a0,458 # ffffffffc02063e0 <etext+0x64>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e1258593          	addi	a1,a1,-494 # ffffffffc0200036 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	1d450513          	addi	a0,a0,468 # ffffffffc0206400 <etext+0x84>
ffffffffc0200234:	f5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	14458593          	addi	a1,a1,324 # ffffffffc020637c <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	1e050513          	addi	a0,a0,480 # ffffffffc0206420 <etext+0xa4>
ffffffffc0200248:	f47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	000a1597          	auipc	a1,0xa1
ffffffffc0200250:	1bc58593          	addi	a1,a1,444 # ffffffffc02a1408 <edata>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	1ec50513          	addi	a0,a0,492 # ffffffffc0206440 <etext+0xc4>
ffffffffc020025c:	f33ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	000ac597          	auipc	a1,0xac
ffffffffc0200264:	73058593          	addi	a1,a1,1840 # ffffffffc02ac990 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	1f850513          	addi	a0,a0,504 # ffffffffc0206460 <etext+0xe4>
ffffffffc0200270:	f1fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	000ad597          	auipc	a1,0xad
ffffffffc0200278:	b1b58593          	addi	a1,a1,-1253 # ffffffffc02acd8f <end+0x3ff>
ffffffffc020027c:	00000797          	auipc	a5,0x0
ffffffffc0200280:	dba78793          	addi	a5,a5,-582 # ffffffffc0200036 <kern_init>
ffffffffc0200284:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200288:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200292:	95be                	add	a1,a1,a5
ffffffffc0200294:	85a9                	srai	a1,a1,0xa
ffffffffc0200296:	00006517          	auipc	a0,0x6
ffffffffc020029a:	1ea50513          	addi	a0,a0,490 # ffffffffc0206480 <etext+0x104>
}
ffffffffc020029e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a0:	b5fd                	j	ffffffffc020018e <cprintf>

ffffffffc02002a2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a4:	00006617          	auipc	a2,0x6
ffffffffc02002a8:	10c60613          	addi	a2,a2,268 # ffffffffc02063b0 <etext+0x34>
ffffffffc02002ac:	04d00593          	li	a1,77
ffffffffc02002b0:	00006517          	auipc	a0,0x6
ffffffffc02002b4:	11850513          	addi	a0,a0,280 # ffffffffc02063c8 <etext+0x4c>
void print_stackframe(void) {
ffffffffc02002b8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ba:	1c6000ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02002be <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002be:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c0:	00006617          	auipc	a2,0x6
ffffffffc02002c4:	2d060613          	addi	a2,a2,720 # ffffffffc0206590 <commands+0xe0>
ffffffffc02002c8:	00006597          	auipc	a1,0x6
ffffffffc02002cc:	2e858593          	addi	a1,a1,744 # ffffffffc02065b0 <commands+0x100>
ffffffffc02002d0:	00006517          	auipc	a0,0x6
ffffffffc02002d4:	2e850513          	addi	a0,a0,744 # ffffffffc02065b8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002da:	eb5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002de:	00006617          	auipc	a2,0x6
ffffffffc02002e2:	2ea60613          	addi	a2,a2,746 # ffffffffc02065c8 <commands+0x118>
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	30a58593          	addi	a1,a1,778 # ffffffffc02065f0 <commands+0x140>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	2ca50513          	addi	a0,a0,714 # ffffffffc02065b8 <commands+0x108>
ffffffffc02002f6:	e99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fa:	00006617          	auipc	a2,0x6
ffffffffc02002fe:	30660613          	addi	a2,a2,774 # ffffffffc0206600 <commands+0x150>
ffffffffc0200302:	00006597          	auipc	a1,0x6
ffffffffc0200306:	31e58593          	addi	a1,a1,798 # ffffffffc0206620 <commands+0x170>
ffffffffc020030a:	00006517          	auipc	a0,0x6
ffffffffc020030e:	2ae50513          	addi	a0,a0,686 # ffffffffc02065b8 <commands+0x108>
ffffffffc0200312:	e7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc0200316:	60a2                	ld	ra,8(sp)
ffffffffc0200318:	4501                	li	a0,0
ffffffffc020031a:	0141                	addi	sp,sp,16
ffffffffc020031c:	8082                	ret

ffffffffc020031e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031e:	1141                	addi	sp,sp,-16
ffffffffc0200320:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200322:	ef3ff0ef          	jal	ra,ffffffffc0200214 <print_kerninfo>
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200332:	f71ff0ef          	jal	ra,ffffffffc02002a2 <print_stackframe>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033e:	7115                	addi	sp,sp,-224
ffffffffc0200340:	e962                	sd	s8,144(sp)
ffffffffc0200342:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200344:	00006517          	auipc	a0,0x6
ffffffffc0200348:	1b450513          	addi	a0,a0,436 # ffffffffc02064f8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020034c:	ed86                	sd	ra,216(sp)
ffffffffc020034e:	e9a2                	sd	s0,208(sp)
ffffffffc0200350:	e5a6                	sd	s1,200(sp)
ffffffffc0200352:	e1ca                	sd	s2,192(sp)
ffffffffc0200354:	fd4e                	sd	s3,184(sp)
ffffffffc0200356:	f952                	sd	s4,176(sp)
ffffffffc0200358:	f556                	sd	s5,168(sp)
ffffffffc020035a:	f15a                	sd	s6,160(sp)
ffffffffc020035c:	ed5e                	sd	s7,152(sp)
ffffffffc020035e:	e566                	sd	s9,136(sp)
ffffffffc0200360:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200362:	e2dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200366:	00006517          	auipc	a0,0x6
ffffffffc020036a:	1ba50513          	addi	a0,a0,442 # ffffffffc0206520 <commands+0x70>
ffffffffc020036e:	e21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200372:	000c0563          	beqz	s8,ffffffffc020037c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200376:	8562                	mv	a0,s8
ffffffffc0200378:	4a4000ef          	jal	ra,ffffffffc020081c <print_trapframe>
ffffffffc020037c:	00006c97          	auipc	s9,0x6
ffffffffc0200380:	134c8c93          	addi	s9,s9,308 # ffffffffc02064b0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200384:	00006997          	auipc	s3,0x6
ffffffffc0200388:	1c498993          	addi	s3,s3,452 # ffffffffc0206548 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	1c490913          	addi	s2,s2,452 # ffffffffc0206550 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200394:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200396:	00006b17          	auipc	s6,0x6
ffffffffc020039a:	1c2b0b13          	addi	s6,s6,450 # ffffffffc0206558 <commands+0xa8>
    if (argc == 0) {
ffffffffc020039e:	00006a97          	auipc	s5,0x6
ffffffffc02003a2:	212a8a93          	addi	s5,s5,530 # ffffffffc02065b0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a8:	854e                	mv	a0,s3
ffffffffc02003aa:	cedff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003ae:	842a                	mv	s0,a0
ffffffffc02003b0:	dd65                	beqz	a0,ffffffffc02003a8 <kmonitor+0x6a>
ffffffffc02003b2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003b6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	c999                	beqz	a1,ffffffffc02003ce <kmonitor+0x90>
ffffffffc02003ba:	854a                	mv	a0,s2
ffffffffc02003bc:	779050ef          	jal	ra,ffffffffc0206334 <strchr>
ffffffffc02003c0:	c925                	beqz	a0,ffffffffc0200430 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c2:	00144583          	lbu	a1,1(s0)
ffffffffc02003c6:	00040023          	sb	zero,0(s0)
ffffffffc02003ca:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003cc:	f5fd                	bnez	a1,ffffffffc02003ba <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003ce:	dce9                	beqz	s1,ffffffffc02003a8 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d0:	6582                	ld	a1,0(sp)
ffffffffc02003d2:	00006d17          	auipc	s10,0x6
ffffffffc02003d6:	0ded0d13          	addi	s10,s10,222 # ffffffffc02064b0 <commands>
    if (argc == 0) {
ffffffffc02003da:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003dc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003de:	0d61                	addi	s10,s10,24
ffffffffc02003e0:	72b050ef          	jal	ra,ffffffffc020630a <strcmp>
ffffffffc02003e4:	c919                	beqz	a0,ffffffffc02003fa <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	2405                	addiw	s0,s0,1
ffffffffc02003e8:	09740463          	beq	s0,s7,ffffffffc0200470 <kmonitor+0x132>
ffffffffc02003ec:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	0d61                	addi	s10,s10,24
ffffffffc02003f4:	717050ef          	jal	ra,ffffffffc020630a <strcmp>
ffffffffc02003f8:	f57d                	bnez	a0,ffffffffc02003e6 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fa:	00141793          	slli	a5,s0,0x1
ffffffffc02003fe:	97a2                	add	a5,a5,s0
ffffffffc0200400:	078e                	slli	a5,a5,0x3
ffffffffc0200402:	97e6                	add	a5,a5,s9
ffffffffc0200404:	6b9c                	ld	a5,16(a5)
ffffffffc0200406:	8662                	mv	a2,s8
ffffffffc0200408:	002c                	addi	a1,sp,8
ffffffffc020040a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020040e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200410:	f8055ce3          	bgez	a0,ffffffffc02003a8 <kmonitor+0x6a>
}
ffffffffc0200414:	60ee                	ld	ra,216(sp)
ffffffffc0200416:	644e                	ld	s0,208(sp)
ffffffffc0200418:	64ae                	ld	s1,200(sp)
ffffffffc020041a:	690e                	ld	s2,192(sp)
ffffffffc020041c:	79ea                	ld	s3,184(sp)
ffffffffc020041e:	7a4a                	ld	s4,176(sp)
ffffffffc0200420:	7aaa                	ld	s5,168(sp)
ffffffffc0200422:	7b0a                	ld	s6,160(sp)
ffffffffc0200424:	6bea                	ld	s7,152(sp)
ffffffffc0200426:	6c4a                	ld	s8,144(sp)
ffffffffc0200428:	6caa                	ld	s9,136(sp)
ffffffffc020042a:	6d0a                	ld	s10,128(sp)
ffffffffc020042c:	612d                	addi	sp,sp,224
ffffffffc020042e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200430:	00044783          	lbu	a5,0(s0)
ffffffffc0200434:	dfc9                	beqz	a5,ffffffffc02003ce <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200436:	03448863          	beq	s1,s4,ffffffffc0200466 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043a:	00349793          	slli	a5,s1,0x3
ffffffffc020043e:	0118                	addi	a4,sp,128
ffffffffc0200440:	97ba                	add	a5,a5,a4
ffffffffc0200442:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200446:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044c:	e591                	bnez	a1,ffffffffc0200458 <kmonitor+0x11a>
ffffffffc020044e:	b749                	j	ffffffffc02003d0 <kmonitor+0x92>
            buf ++;
ffffffffc0200450:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200452:	00044583          	lbu	a1,0(s0)
ffffffffc0200456:	ddad                	beqz	a1,ffffffffc02003d0 <kmonitor+0x92>
ffffffffc0200458:	854a                	mv	a0,s2
ffffffffc020045a:	6db050ef          	jal	ra,ffffffffc0206334 <strchr>
ffffffffc020045e:	d96d                	beqz	a0,ffffffffc0200450 <kmonitor+0x112>
ffffffffc0200460:	00044583          	lbu	a1,0(s0)
ffffffffc0200464:	bf91                	j	ffffffffc02003b8 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200466:	45c1                	li	a1,16
ffffffffc0200468:	855a                	mv	a0,s6
ffffffffc020046a:	d25ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020046e:	b7f1                	j	ffffffffc020043a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200470:	6582                	ld	a1,0(sp)
ffffffffc0200472:	00006517          	auipc	a0,0x6
ffffffffc0200476:	10650513          	addi	a0,a0,262 # ffffffffc0206578 <commands+0xc8>
ffffffffc020047a:	d15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020047e:	b72d                	j	ffffffffc02003a8 <kmonitor+0x6a>

ffffffffc0200480 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200480:	000ac317          	auipc	t1,0xac
ffffffffc0200484:	38830313          	addi	t1,t1,904 # ffffffffc02ac808 <is_panic>
ffffffffc0200488:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020048c:	715d                	addi	sp,sp,-80
ffffffffc020048e:	ec06                	sd	ra,24(sp)
ffffffffc0200490:	e822                	sd	s0,16(sp)
ffffffffc0200492:	f436                	sd	a3,40(sp)
ffffffffc0200494:	f83a                	sd	a4,48(sp)
ffffffffc0200496:	fc3e                	sd	a5,56(sp)
ffffffffc0200498:	e0c2                	sd	a6,64(sp)
ffffffffc020049a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020049c:	02031c63          	bnez	t1,ffffffffc02004d4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a0:	4785                	li	a5,1
ffffffffc02004a2:	8432                	mv	s0,a2
ffffffffc02004a4:	000ac717          	auipc	a4,0xac
ffffffffc02004a8:	36f73223          	sd	a5,868(a4) # ffffffffc02ac808 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ac:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004ae:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	85aa                	mv	a1,a0
ffffffffc02004b2:	00006517          	auipc	a0,0x6
ffffffffc02004b6:	17e50513          	addi	a0,a0,382 # ffffffffc0206630 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004ba:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004bc:	cd3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c0:	65a2                	ld	a1,8(sp)
ffffffffc02004c2:	8522                	mv	a0,s0
ffffffffc02004c4:	cabff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004c8:	00007517          	auipc	a0,0x7
ffffffffc02004cc:	12050513          	addi	a0,a0,288 # ffffffffc02075e8 <default_pmm_manager+0x530>
ffffffffc02004d0:	cbfff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d4:	4501                	li	a0,0
ffffffffc02004d6:	4581                	li	a1,0
ffffffffc02004d8:	4601                	li	a2,0
ffffffffc02004da:	48a1                	li	a7,8
ffffffffc02004dc:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e0:	14e000ef          	jal	ra,ffffffffc020062e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e4:	4501                	li	a0,0
ffffffffc02004e6:	e59ff0ef          	jal	ra,ffffffffc020033e <kmonitor>
ffffffffc02004ea:	bfed                	j	ffffffffc02004e4 <__panic+0x64>

ffffffffc02004ec <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ec:	715d                	addi	sp,sp,-80
ffffffffc02004ee:	e822                	sd	s0,16(sp)
ffffffffc02004f0:	fc3e                	sd	a5,56(sp)
ffffffffc02004f2:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f6:	862e                	mv	a2,a1
ffffffffc02004f8:	85aa                	mv	a1,a0
ffffffffc02004fa:	00006517          	auipc	a0,0x6
ffffffffc02004fe:	15650513          	addi	a0,a0,342 # ffffffffc0206650 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200502:	ec06                	sd	ra,24(sp)
ffffffffc0200504:	f436                	sd	a3,40(sp)
ffffffffc0200506:	f83a                	sd	a4,48(sp)
ffffffffc0200508:	e0c2                	sd	a6,64(sp)
ffffffffc020050a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020050c:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020050e:	c81ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200512:	65a2                	ld	a1,8(sp)
ffffffffc0200514:	8522                	mv	a0,s0
ffffffffc0200516:	c59ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051a:	00007517          	auipc	a0,0x7
ffffffffc020051e:	0ce50513          	addi	a0,a0,206 # ffffffffc02075e8 <default_pmm_manager+0x530>
ffffffffc0200522:	c6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc0200526:	60e2                	ld	ra,24(sp)
ffffffffc0200528:	6442                	ld	s0,16(sp)
ffffffffc020052a:	6161                	addi	sp,sp,80
ffffffffc020052c:	8082                	ret

ffffffffc020052e <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020052e:	67e1                	lui	a5,0x18
ffffffffc0200530:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbd8>
ffffffffc0200534:	000ac717          	auipc	a4,0xac
ffffffffc0200538:	2cf73e23          	sd	a5,732(a4) # ffffffffc02ac810 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200540:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	953e                	add	a0,a0,a5
ffffffffc0200544:	4601                	li	a2,0
ffffffffc0200546:	4881                	li	a7,0
ffffffffc0200548:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020054c:	02000793          	li	a5,32
ffffffffc0200550:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00006517          	auipc	a0,0x6
ffffffffc0200558:	11c50513          	addi	a0,a0,284 # ffffffffc0206670 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000ac797          	auipc	a5,0xac
ffffffffc0200560:	3007b223          	sd	zero,772(a5) # ffffffffc02ac860 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	b12d                	j	ffffffffc020018e <cprintf>

ffffffffc0200566 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056a:	000ac797          	auipc	a5,0xac
ffffffffc020056e:	2a678793          	addi	a5,a5,678 # ffffffffc02ac810 <timebase>
ffffffffc0200572:	639c                	ld	a5,0(a5)
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	953e                	add	a0,a0,a5
ffffffffc020057a:	4881                	li	a7,0
ffffffffc020057c:	00000073          	ecall
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200582:	8082                	ret

ffffffffc0200584 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200584:	100027f3          	csrr	a5,sstatus
ffffffffc0200588:	8b89                	andi	a5,a5,2
ffffffffc020058a:	0ff57513          	andi	a0,a0,255
ffffffffc020058e:	e799                	bnez	a5,ffffffffc020059c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200590:	4581                	li	a1,0
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4885                	li	a7,1
ffffffffc0200596:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020059a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059c:	1101                	addi	sp,sp,-32
ffffffffc020059e:	ec06                	sd	ra,24(sp)
ffffffffc02005a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a2:	08c000ef          	jal	ra,ffffffffc020062e <intr_disable>
ffffffffc02005a6:	6522                	ld	a0,8(sp)
ffffffffc02005a8:	4581                	li	a1,0
ffffffffc02005aa:	4601                	li	a2,0
ffffffffc02005ac:	4885                	li	a7,1
ffffffffc02005ae:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b2:	60e2                	ld	ra,24(sp)
ffffffffc02005b4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b6:	a88d                	j	ffffffffc0200628 <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	05a000ef          	jal	ra,ffffffffc020062e <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	040000ef          	jal	ra,ffffffffc0200628 <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200602:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200604:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200608:	000a1517          	auipc	a0,0xa1
ffffffffc020060c:	20050513          	addi	a0,a0,512 # ffffffffc02a1808 <ide>
                   size_t nsecs) {
ffffffffc0200610:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200612:	00969613          	slli	a2,a3,0x9
ffffffffc0200616:	85ba                	mv	a1,a4
ffffffffc0200618:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020061a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061c:	549050ef          	jal	ra,ffffffffc0206364 <memcpy>
    return 0;
}
ffffffffc0200620:	60a2                	ld	ra,8(sp)
ffffffffc0200622:	4501                	li	a0,0
ffffffffc0200624:	0141                	addi	sp,sp,16
ffffffffc0200626:	8082                	ret

ffffffffc0200628 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200628:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020062c:	8082                	ret

ffffffffc020062e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020062e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200632:	8082                	ret

ffffffffc0200634 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200634:	8082                	ret

ffffffffc0200636 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200636:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020063a:	00000797          	auipc	a5,0x0
ffffffffc020063e:	66a78793          	addi	a5,a5,1642 # ffffffffc0200ca4 <__alltraps>
ffffffffc0200642:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200646:	000407b7          	lui	a5,0x40
ffffffffc020064a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020064e:	8082                	ret

ffffffffc0200650 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200650:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200652:	1141                	addi	sp,sp,-16
ffffffffc0200654:	e022                	sd	s0,0(sp)
ffffffffc0200656:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200658:	00006517          	auipc	a0,0x6
ffffffffc020065c:	36050513          	addi	a0,a0,864 # ffffffffc02069b8 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200660:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	b2dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200666:	640c                	ld	a1,8(s0)
ffffffffc0200668:	00006517          	auipc	a0,0x6
ffffffffc020066c:	36850513          	addi	a0,a0,872 # ffffffffc02069d0 <commands+0x520>
ffffffffc0200670:	b1fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200674:	680c                	ld	a1,16(s0)
ffffffffc0200676:	00006517          	auipc	a0,0x6
ffffffffc020067a:	37250513          	addi	a0,a0,882 # ffffffffc02069e8 <commands+0x538>
ffffffffc020067e:	b11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200682:	6c0c                	ld	a1,24(s0)
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	37c50513          	addi	a0,a0,892 # ffffffffc0206a00 <commands+0x550>
ffffffffc020068c:	b03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200690:	700c                	ld	a1,32(s0)
ffffffffc0200692:	00006517          	auipc	a0,0x6
ffffffffc0200696:	38650513          	addi	a0,a0,902 # ffffffffc0206a18 <commands+0x568>
ffffffffc020069a:	af5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020069e:	740c                	ld	a1,40(s0)
ffffffffc02006a0:	00006517          	auipc	a0,0x6
ffffffffc02006a4:	39050513          	addi	a0,a0,912 # ffffffffc0206a30 <commands+0x580>
ffffffffc02006a8:	ae7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006ac:	780c                	ld	a1,48(s0)
ffffffffc02006ae:	00006517          	auipc	a0,0x6
ffffffffc02006b2:	39a50513          	addi	a0,a0,922 # ffffffffc0206a48 <commands+0x598>
ffffffffc02006b6:	ad9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ba:	7c0c                	ld	a1,56(s0)
ffffffffc02006bc:	00006517          	auipc	a0,0x6
ffffffffc02006c0:	3a450513          	addi	a0,a0,932 # ffffffffc0206a60 <commands+0x5b0>
ffffffffc02006c4:	acbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c8:	602c                	ld	a1,64(s0)
ffffffffc02006ca:	00006517          	auipc	a0,0x6
ffffffffc02006ce:	3ae50513          	addi	a0,a0,942 # ffffffffc0206a78 <commands+0x5c8>
ffffffffc02006d2:	abdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006d6:	642c                	ld	a1,72(s0)
ffffffffc02006d8:	00006517          	auipc	a0,0x6
ffffffffc02006dc:	3b850513          	addi	a0,a0,952 # ffffffffc0206a90 <commands+0x5e0>
ffffffffc02006e0:	aafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e4:	682c                	ld	a1,80(s0)
ffffffffc02006e6:	00006517          	auipc	a0,0x6
ffffffffc02006ea:	3c250513          	addi	a0,a0,962 # ffffffffc0206aa8 <commands+0x5f8>
ffffffffc02006ee:	aa1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f2:	6c2c                	ld	a1,88(s0)
ffffffffc02006f4:	00006517          	auipc	a0,0x6
ffffffffc02006f8:	3cc50513          	addi	a0,a0,972 # ffffffffc0206ac0 <commands+0x610>
ffffffffc02006fc:	a93ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200700:	702c                	ld	a1,96(s0)
ffffffffc0200702:	00006517          	auipc	a0,0x6
ffffffffc0200706:	3d650513          	addi	a0,a0,982 # ffffffffc0206ad8 <commands+0x628>
ffffffffc020070a:	a85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020070e:	742c                	ld	a1,104(s0)
ffffffffc0200710:	00006517          	auipc	a0,0x6
ffffffffc0200714:	3e050513          	addi	a0,a0,992 # ffffffffc0206af0 <commands+0x640>
ffffffffc0200718:	a77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020071c:	782c                	ld	a1,112(s0)
ffffffffc020071e:	00006517          	auipc	a0,0x6
ffffffffc0200722:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206b08 <commands+0x658>
ffffffffc0200726:	a69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072a:	7c2c                	ld	a1,120(s0)
ffffffffc020072c:	00006517          	auipc	a0,0x6
ffffffffc0200730:	3f450513          	addi	a0,a0,1012 # ffffffffc0206b20 <commands+0x670>
ffffffffc0200734:	a5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200738:	604c                	ld	a1,128(s0)
ffffffffc020073a:	00006517          	auipc	a0,0x6
ffffffffc020073e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206b38 <commands+0x688>
ffffffffc0200742:	a4dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200746:	644c                	ld	a1,136(s0)
ffffffffc0200748:	00006517          	auipc	a0,0x6
ffffffffc020074c:	40850513          	addi	a0,a0,1032 # ffffffffc0206b50 <commands+0x6a0>
ffffffffc0200750:	a3fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200754:	684c                	ld	a1,144(s0)
ffffffffc0200756:	00006517          	auipc	a0,0x6
ffffffffc020075a:	41250513          	addi	a0,a0,1042 # ffffffffc0206b68 <commands+0x6b8>
ffffffffc020075e:	a31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200762:	6c4c                	ld	a1,152(s0)
ffffffffc0200764:	00006517          	auipc	a0,0x6
ffffffffc0200768:	41c50513          	addi	a0,a0,1052 # ffffffffc0206b80 <commands+0x6d0>
ffffffffc020076c:	a23ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200770:	704c                	ld	a1,160(s0)
ffffffffc0200772:	00006517          	auipc	a0,0x6
ffffffffc0200776:	42650513          	addi	a0,a0,1062 # ffffffffc0206b98 <commands+0x6e8>
ffffffffc020077a:	a15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020077e:	744c                	ld	a1,168(s0)
ffffffffc0200780:	00006517          	auipc	a0,0x6
ffffffffc0200784:	43050513          	addi	a0,a0,1072 # ffffffffc0206bb0 <commands+0x700>
ffffffffc0200788:	a07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020078c:	784c                	ld	a1,176(s0)
ffffffffc020078e:	00006517          	auipc	a0,0x6
ffffffffc0200792:	43a50513          	addi	a0,a0,1082 # ffffffffc0206bc8 <commands+0x718>
ffffffffc0200796:	9f9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079a:	7c4c                	ld	a1,184(s0)
ffffffffc020079c:	00006517          	auipc	a0,0x6
ffffffffc02007a0:	44450513          	addi	a0,a0,1092 # ffffffffc0206be0 <commands+0x730>
ffffffffc02007a4:	9ebff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a8:	606c                	ld	a1,192(s0)
ffffffffc02007aa:	00006517          	auipc	a0,0x6
ffffffffc02007ae:	44e50513          	addi	a0,a0,1102 # ffffffffc0206bf8 <commands+0x748>
ffffffffc02007b2:	9ddff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007b6:	646c                	ld	a1,200(s0)
ffffffffc02007b8:	00006517          	auipc	a0,0x6
ffffffffc02007bc:	45850513          	addi	a0,a0,1112 # ffffffffc0206c10 <commands+0x760>
ffffffffc02007c0:	9cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c4:	686c                	ld	a1,208(s0)
ffffffffc02007c6:	00006517          	auipc	a0,0x6
ffffffffc02007ca:	46250513          	addi	a0,a0,1122 # ffffffffc0206c28 <commands+0x778>
ffffffffc02007ce:	9c1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d2:	6c6c                	ld	a1,216(s0)
ffffffffc02007d4:	00006517          	auipc	a0,0x6
ffffffffc02007d8:	46c50513          	addi	a0,a0,1132 # ffffffffc0206c40 <commands+0x790>
ffffffffc02007dc:	9b3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e0:	706c                	ld	a1,224(s0)
ffffffffc02007e2:	00006517          	auipc	a0,0x6
ffffffffc02007e6:	47650513          	addi	a0,a0,1142 # ffffffffc0206c58 <commands+0x7a8>
ffffffffc02007ea:	9a5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007ee:	746c                	ld	a1,232(s0)
ffffffffc02007f0:	00006517          	auipc	a0,0x6
ffffffffc02007f4:	48050513          	addi	a0,a0,1152 # ffffffffc0206c70 <commands+0x7c0>
ffffffffc02007f8:	997ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007fc:	786c                	ld	a1,240(s0)
ffffffffc02007fe:	00006517          	auipc	a0,0x6
ffffffffc0200802:	48a50513          	addi	a0,a0,1162 # ffffffffc0206c88 <commands+0x7d8>
ffffffffc0200806:	989ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020080c:	6402                	ld	s0,0(sp)
ffffffffc020080e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200810:	00006517          	auipc	a0,0x6
ffffffffc0200814:	49050513          	addi	a0,a0,1168 # ffffffffc0206ca0 <commands+0x7f0>
}
ffffffffc0200818:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081a:	ba95                	j	ffffffffc020018e <cprintf>

ffffffffc020081c <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020081c:	1141                	addi	sp,sp,-16
ffffffffc020081e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200820:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	00006517          	auipc	a0,0x6
ffffffffc0200828:	49450513          	addi	a0,a0,1172 # ffffffffc0206cb8 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc020082c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020082e:	961ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200832:	8522                	mv	a0,s0
ffffffffc0200834:	e1dff0ef          	jal	ra,ffffffffc0200650 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200838:	10043583          	ld	a1,256(s0)
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	49450513          	addi	a0,a0,1172 # ffffffffc0206cd0 <commands+0x820>
ffffffffc0200844:	94bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200848:	10843583          	ld	a1,264(s0)
ffffffffc020084c:	00006517          	auipc	a0,0x6
ffffffffc0200850:	49c50513          	addi	a0,a0,1180 # ffffffffc0206ce8 <commands+0x838>
ffffffffc0200854:	93bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200858:	11043583          	ld	a1,272(s0)
ffffffffc020085c:	00006517          	auipc	a0,0x6
ffffffffc0200860:	4a450513          	addi	a0,a0,1188 # ffffffffc0206d00 <commands+0x850>
ffffffffc0200864:	92bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200868:	11843583          	ld	a1,280(s0)
}
ffffffffc020086c:	6402                	ld	s0,0(sp)
ffffffffc020086e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	4a050513          	addi	a0,a0,1184 # ffffffffc0206d10 <commands+0x860>
}
ffffffffc0200878:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	915ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020087e <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc020087e:	1101                	addi	sp,sp,-32
ffffffffc0200880:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200882:	000ac497          	auipc	s1,0xac
ffffffffc0200886:	0f648493          	addi	s1,s1,246 # ffffffffc02ac978 <check_mm_struct>
ffffffffc020088a:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc020088c:	e822                	sd	s0,16(sp)
ffffffffc020088e:	ec06                	sd	ra,24(sp)
ffffffffc0200890:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200892:	cbbd                	beqz	a5,ffffffffc0200908 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200894:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200898:	11053583          	ld	a1,272(a0)
ffffffffc020089c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a0:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008a4:	cba1                	beqz	a5,ffffffffc02008f4 <pgfault_handler+0x76>
ffffffffc02008a6:	11843703          	ld	a4,280(s0)
ffffffffc02008aa:	47bd                	li	a5,15
ffffffffc02008ac:	05700693          	li	a3,87
ffffffffc02008b0:	00f70463          	beq	a4,a5,ffffffffc02008b8 <pgfault_handler+0x3a>
ffffffffc02008b4:	05200693          	li	a3,82
ffffffffc02008b8:	00006517          	auipc	a0,0x6
ffffffffc02008bc:	08050513          	addi	a0,a0,128 # ffffffffc0206938 <commands+0x488>
ffffffffc02008c0:	8cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008c4:	6088                	ld	a0,0(s1)
ffffffffc02008c6:	c129                	beqz	a0,ffffffffc0200908 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008c8:	000ac797          	auipc	a5,0xac
ffffffffc02008cc:	f7878793          	addi	a5,a5,-136 # ffffffffc02ac840 <current>
ffffffffc02008d0:	6398                	ld	a4,0(a5)
ffffffffc02008d2:	000ac797          	auipc	a5,0xac
ffffffffc02008d6:	f7678793          	addi	a5,a5,-138 # ffffffffc02ac848 <idleproc>
ffffffffc02008da:	639c                	ld	a5,0(a5)
ffffffffc02008dc:	04f71763          	bne	a4,a5,ffffffffc020092a <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e0:	11043603          	ld	a2,272(s0)
ffffffffc02008e4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008e8:	6442                	ld	s0,16(sp)
ffffffffc02008ea:	60e2                	ld	ra,24(sp)
ffffffffc02008ec:	64a2                	ld	s1,8(sp)
ffffffffc02008ee:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f0:	7df0306f          	j	ffffffffc02048ce <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008f4:	11843703          	ld	a4,280(s0)
ffffffffc02008f8:	47bd                	li	a5,15
ffffffffc02008fa:	05500613          	li	a2,85
ffffffffc02008fe:	05700693          	li	a3,87
ffffffffc0200902:	faf719e3          	bne	a4,a5,ffffffffc02008b4 <pgfault_handler+0x36>
ffffffffc0200906:	bf4d                	j	ffffffffc02008b8 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200908:	000ac797          	auipc	a5,0xac
ffffffffc020090c:	f3878793          	addi	a5,a5,-200 # ffffffffc02ac840 <current>
ffffffffc0200910:	639c                	ld	a5,0(a5)
ffffffffc0200912:	cf85                	beqz	a5,ffffffffc020094a <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	11043603          	ld	a2,272(s0)
ffffffffc0200918:	11843583          	ld	a1,280(s0)
}
ffffffffc020091c:	6442                	ld	s0,16(sp)
ffffffffc020091e:	60e2                	ld	ra,24(sp)
ffffffffc0200920:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200922:	7788                	ld	a0,40(a5)
}
ffffffffc0200924:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200926:	7a90306f          	j	ffffffffc02048ce <do_pgfault>
        assert(current == idleproc);
ffffffffc020092a:	00006697          	auipc	a3,0x6
ffffffffc020092e:	02e68693          	addi	a3,a3,46 # ffffffffc0206958 <commands+0x4a8>
ffffffffc0200932:	00006617          	auipc	a2,0x6
ffffffffc0200936:	03e60613          	addi	a2,a2,62 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020093a:	06b00593          	li	a1,107
ffffffffc020093e:	00006517          	auipc	a0,0x6
ffffffffc0200942:	04a50513          	addi	a0,a0,74 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200946:	b3bff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	ed1ff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200950:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200954:	11043583          	ld	a1,272(s0)
ffffffffc0200958:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095c:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200960:	e399                	bnez	a5,ffffffffc0200966 <pgfault_handler+0xe8>
ffffffffc0200962:	05500613          	li	a2,85
ffffffffc0200966:	11843703          	ld	a4,280(s0)
ffffffffc020096a:	47bd                	li	a5,15
ffffffffc020096c:	02f70663          	beq	a4,a5,ffffffffc0200998 <pgfault_handler+0x11a>
ffffffffc0200970:	05200693          	li	a3,82
ffffffffc0200974:	00006517          	auipc	a0,0x6
ffffffffc0200978:	fc450513          	addi	a0,a0,-60 # ffffffffc0206938 <commands+0x488>
ffffffffc020097c:	813ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200980:	00006617          	auipc	a2,0x6
ffffffffc0200984:	02060613          	addi	a2,a2,32 # ffffffffc02069a0 <commands+0x4f0>
ffffffffc0200988:	07200593          	li	a1,114
ffffffffc020098c:	00006517          	auipc	a0,0x6
ffffffffc0200990:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200994:	aedff0ef          	jal	ra,ffffffffc0200480 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200998:	05700693          	li	a3,87
ffffffffc020099c:	bfe1                	j	ffffffffc0200974 <pgfault_handler+0xf6>

ffffffffc020099e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020099e:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009a2:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009a4:	0786                	slli	a5,a5,0x1
ffffffffc02009a6:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009a8:	08f76763          	bltu	a4,a5,ffffffffc0200a36 <interrupt_handler+0x98>
ffffffffc02009ac:	00006717          	auipc	a4,0x6
ffffffffc02009b0:	ce070713          	addi	a4,a4,-800 # ffffffffc020668c <commands+0x1dc>
ffffffffc02009b4:	078a                	slli	a5,a5,0x2
ffffffffc02009b6:	97ba                	add	a5,a5,a4
ffffffffc02009b8:	439c                	lw	a5,0(a5)
ffffffffc02009ba:	97ba                	add	a5,a5,a4
ffffffffc02009bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009be:	00006517          	auipc	a0,0x6
ffffffffc02009c2:	f3a50513          	addi	a0,a0,-198 # ffffffffc02068f8 <commands+0x448>
ffffffffc02009c6:	fc8ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ca:	00006517          	auipc	a0,0x6
ffffffffc02009ce:	f0e50513          	addi	a0,a0,-242 # ffffffffc02068d8 <commands+0x428>
ffffffffc02009d2:	fbcff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009d6:	00006517          	auipc	a0,0x6
ffffffffc02009da:	ec250513          	addi	a0,a0,-318 # ffffffffc0206898 <commands+0x3e8>
ffffffffc02009de:	fb0ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	ed650513          	addi	a0,a0,-298 # ffffffffc02068b8 <commands+0x408>
ffffffffc02009ea:	fa4ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	f2a50513          	addi	a0,a0,-214 # ffffffffc0206918 <commands+0x468>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009fa:	1141                	addi	sp,sp,-16
ffffffffc02009fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02009fe:	b69ff0ef          	jal	ra,ffffffffc0200566 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a02:	000ac797          	auipc	a5,0xac
ffffffffc0200a06:	e5e78793          	addi	a5,a5,-418 # ffffffffc02ac860 <ticks>
ffffffffc0200a0a:	639c                	ld	a5,0(a5)
ffffffffc0200a0c:	06400713          	li	a4,100
ffffffffc0200a10:	0785                	addi	a5,a5,1
ffffffffc0200a12:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a16:	000ac697          	auipc	a3,0xac
ffffffffc0200a1a:	e4f6b523          	sd	a5,-438(a3) # ffffffffc02ac860 <ticks>
ffffffffc0200a1e:	eb09                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x92>
ffffffffc0200a20:	000ac797          	auipc	a5,0xac
ffffffffc0200a24:	e2078793          	addi	a5,a5,-480 # ffffffffc02ac840 <current>
ffffffffc0200a28:	639c                	ld	a5,0(a5)
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a36:	b3dd                	j	ffffffffc020081c <print_trapframe>

ffffffffc0200a38 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a38:	11853783          	ld	a5,280(a0)
ffffffffc0200a3c:	473d                	li	a4,15
ffffffffc0200a3e:	1af76c63          	bltu	a4,a5,ffffffffc0200bf6 <exception_handler+0x1be>
ffffffffc0200a42:	00006717          	auipc	a4,0x6
ffffffffc0200a46:	c7a70713          	addi	a4,a4,-902 # ffffffffc02066bc <commands+0x20c>
ffffffffc0200a4a:	078a                	slli	a5,a5,0x2
ffffffffc0200a4c:	97ba                	add	a5,a5,a4
ffffffffc0200a4e:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a50:	1101                	addi	sp,sp,-32
ffffffffc0200a52:	e822                	sd	s0,16(sp)
ffffffffc0200a54:	ec06                	sd	ra,24(sp)
ffffffffc0200a56:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a58:	97ba                	add	a5,a5,a4
ffffffffc0200a5a:	842a                	mv	s0,a0
ffffffffc0200a5c:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a5e:	00006517          	auipc	a0,0x6
ffffffffc0200a62:	d9250513          	addi	a0,a0,-622 # ffffffffc02067f0 <commands+0x340>
ffffffffc0200a66:	f28ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a6a:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a6e:	60e2                	ld	ra,24(sp)
ffffffffc0200a70:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a72:	0791                	addi	a5,a5,4
ffffffffc0200a74:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a78:	6442                	ld	s0,16(sp)
ffffffffc0200a7a:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a7c:	3b40506f          	j	ffffffffc0205e30 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a80:	00006517          	auipc	a0,0x6
ffffffffc0200a84:	d9050513          	addi	a0,a0,-624 # ffffffffc0206810 <commands+0x360>
}
ffffffffc0200a88:	6442                	ld	s0,16(sp)
ffffffffc0200a8a:	60e2                	ld	ra,24(sp)
ffffffffc0200a8c:	64a2                	ld	s1,8(sp)
ffffffffc0200a8e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a90:	efeff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a94:	00006517          	auipc	a0,0x6
ffffffffc0200a98:	d9c50513          	addi	a0,a0,-612 # ffffffffc0206830 <commands+0x380>
ffffffffc0200a9c:	b7f5                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a9e:	00006517          	auipc	a0,0x6
ffffffffc0200aa2:	db250513          	addi	a0,a0,-590 # ffffffffc0206850 <commands+0x3a0>
ffffffffc0200aa6:	b7cd                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	dc050513          	addi	a0,a0,-576 # ffffffffc0206868 <commands+0x3b8>
ffffffffc0200ab0:	edeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ab4:	8522                	mv	a0,s0
ffffffffc0200ab6:	dc9ff0ef          	jal	ra,ffffffffc020087e <pgfault_handler>
ffffffffc0200aba:	84aa                	mv	s1,a0
ffffffffc0200abc:	12051e63          	bnez	a0,ffffffffc0200bf8 <exception_handler+0x1c0>
}
ffffffffc0200ac0:	60e2                	ld	ra,24(sp)
ffffffffc0200ac2:	6442                	ld	s0,16(sp)
ffffffffc0200ac4:	64a2                	ld	s1,8(sp)
ffffffffc0200ac6:	6105                	addi	sp,sp,32
ffffffffc0200ac8:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aca:	00006517          	auipc	a0,0x6
ffffffffc0200ace:	db650513          	addi	a0,a0,-586 # ffffffffc0206880 <commands+0x3d0>
ffffffffc0200ad2:	ebcff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad6:	8522                	mv	a0,s0
ffffffffc0200ad8:	da7ff0ef          	jal	ra,ffffffffc020087e <pgfault_handler>
ffffffffc0200adc:	84aa                	mv	s1,a0
ffffffffc0200ade:	d16d                	beqz	a0,ffffffffc0200ac0 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	d3bff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ae6:	86a6                	mv	a3,s1
ffffffffc0200ae8:	00006617          	auipc	a2,0x6
ffffffffc0200aec:	cb860613          	addi	a2,a2,-840 # ffffffffc02067a0 <commands+0x2f0>
ffffffffc0200af0:	0f800593          	li	a1,248
ffffffffc0200af4:	00006517          	auipc	a0,0x6
ffffffffc0200af8:	e9450513          	addi	a0,a0,-364 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200afc:	985ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	c0050513          	addi	a0,a0,-1024 # ffffffffc0206700 <commands+0x250>
ffffffffc0200b08:	b741                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b0a:	00006517          	auipc	a0,0x6
ffffffffc0200b0e:	c1650513          	addi	a0,a0,-1002 # ffffffffc0206720 <commands+0x270>
ffffffffc0200b12:	bf9d                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b14:	00006517          	auipc	a0,0x6
ffffffffc0200b18:	c2c50513          	addi	a0,a0,-980 # ffffffffc0206740 <commands+0x290>
ffffffffc0200b1c:	b7b5                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	c3a50513          	addi	a0,a0,-966 # ffffffffc0206758 <commands+0x2a8>
ffffffffc0200b26:	e68ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b2a:	6458                	ld	a4,136(s0)
ffffffffc0200b2c:	47a9                	li	a5,10
ffffffffc0200b2e:	f8f719e3          	bne	a4,a5,ffffffffc0200ac0 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b32:	10843783          	ld	a5,264(s0)
ffffffffc0200b36:	0791                	addi	a5,a5,4
ffffffffc0200b38:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b3c:	2f4050ef          	jal	ra,ffffffffc0205e30 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b40:	000ac797          	auipc	a5,0xac
ffffffffc0200b44:	d0078793          	addi	a5,a5,-768 # ffffffffc02ac840 <current>
ffffffffc0200b48:	639c                	ld	a5,0(a5)
ffffffffc0200b4a:	8522                	mv	a0,s0
}
ffffffffc0200b4c:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4e:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b50:	60e2                	ld	ra,24(sp)
ffffffffc0200b52:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b54:	6589                	lui	a1,0x2
ffffffffc0200b56:	95be                	add	a1,a1,a5
}
ffffffffc0200b58:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5a:	ac21                	j	ffffffffc0200d72 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b5c:	00006517          	auipc	a0,0x6
ffffffffc0200b60:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206768 <commands+0x2b8>
ffffffffc0200b64:	b715                	j	ffffffffc0200a88 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	c2250513          	addi	a0,a0,-990 # ffffffffc0206788 <commands+0x2d8>
ffffffffc0200b6e:	e20ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b72:	8522                	mv	a0,s0
ffffffffc0200b74:	d0bff0ef          	jal	ra,ffffffffc020087e <pgfault_handler>
ffffffffc0200b78:	84aa                	mv	s1,a0
ffffffffc0200b7a:	d139                	beqz	a0,ffffffffc0200ac0 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	c9fff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b82:	86a6                	mv	a3,s1
ffffffffc0200b84:	00006617          	auipc	a2,0x6
ffffffffc0200b88:	c1c60613          	addi	a2,a2,-996 # ffffffffc02067a0 <commands+0x2f0>
ffffffffc0200b8c:	0cd00593          	li	a1,205
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	df850513          	addi	a0,a0,-520 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200b98:	8e9ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b9c:	00006517          	auipc	a0,0x6
ffffffffc0200ba0:	c3c50513          	addi	a0,a0,-964 # ffffffffc02067d8 <commands+0x328>
ffffffffc0200ba4:	deaff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba8:	8522                	mv	a0,s0
ffffffffc0200baa:	cd5ff0ef          	jal	ra,ffffffffc020087e <pgfault_handler>
ffffffffc0200bae:	84aa                	mv	s1,a0
ffffffffc0200bb0:	f00508e3          	beqz	a0,ffffffffc0200ac0 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb4:	8522                	mv	a0,s0
ffffffffc0200bb6:	c67ff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bba:	86a6                	mv	a3,s1
ffffffffc0200bbc:	00006617          	auipc	a2,0x6
ffffffffc0200bc0:	be460613          	addi	a2,a2,-1052 # ffffffffc02067a0 <commands+0x2f0>
ffffffffc0200bc4:	0d700593          	li	a1,215
ffffffffc0200bc8:	00006517          	auipc	a0,0x6
ffffffffc0200bcc:	dc050513          	addi	a0,a0,-576 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200bd0:	8b1ff0ef          	jal	ra,ffffffffc0200480 <__panic>
}
ffffffffc0200bd4:	6442                	ld	s0,16(sp)
ffffffffc0200bd6:	60e2                	ld	ra,24(sp)
ffffffffc0200bd8:	64a2                	ld	s1,8(sp)
ffffffffc0200bda:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bdc:	b181                	j	ffffffffc020081c <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bde:	00006617          	auipc	a2,0x6
ffffffffc0200be2:	be260613          	addi	a2,a2,-1054 # ffffffffc02067c0 <commands+0x310>
ffffffffc0200be6:	0d100593          	li	a1,209
ffffffffc0200bea:	00006517          	auipc	a0,0x6
ffffffffc0200bee:	d9e50513          	addi	a0,a0,-610 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200bf2:	88fff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc0200bf6:	b11d                	j	ffffffffc020081c <print_trapframe>
                print_trapframe(tf);
ffffffffc0200bf8:	8522                	mv	a0,s0
ffffffffc0200bfa:	c23ff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bfe:	86a6                	mv	a3,s1
ffffffffc0200c00:	00006617          	auipc	a2,0x6
ffffffffc0200c04:	ba060613          	addi	a2,a2,-1120 # ffffffffc02067a0 <commands+0x2f0>
ffffffffc0200c08:	0f100593          	li	a1,241
ffffffffc0200c0c:	00006517          	auipc	a0,0x6
ffffffffc0200c10:	d7c50513          	addi	a0,a0,-644 # ffffffffc0206988 <commands+0x4d8>
ffffffffc0200c14:	86dff0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0200c18 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c18:	1101                	addi	sp,sp,-32
ffffffffc0200c1a:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c1c:	000ac417          	auipc	s0,0xac
ffffffffc0200c20:	c2440413          	addi	s0,s0,-988 # ffffffffc02ac840 <current>
ffffffffc0200c24:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c26:	ec06                	sd	ra,24(sp)
ffffffffc0200c28:	e426                	sd	s1,8(sp)
ffffffffc0200c2a:	e04a                	sd	s2,0(sp)
ffffffffc0200c2c:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c30:	cf1d                	beqz	a4,ffffffffc0200c6e <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c32:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c36:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c3a:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c40:	0206c463          	bltz	a3,ffffffffc0200c68 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c44:	df5ff0ef          	jal	ra,ffffffffc0200a38 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c48:	601c                	ld	a5,0(s0)
ffffffffc0200c4a:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c4e:	e499                	bnez	s1,ffffffffc0200c5c <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c50:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c54:	8b05                	andi	a4,a4,1
ffffffffc0200c56:	e329                	bnez	a4,ffffffffc0200c98 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c58:	6f9c                	ld	a5,24(a5)
ffffffffc0200c5a:	eb85                	bnez	a5,ffffffffc0200c8a <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c5c:	60e2                	ld	ra,24(sp)
ffffffffc0200c5e:	6442                	ld	s0,16(sp)
ffffffffc0200c60:	64a2                	ld	s1,8(sp)
ffffffffc0200c62:	6902                	ld	s2,0(sp)
ffffffffc0200c64:	6105                	addi	sp,sp,32
ffffffffc0200c66:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c68:	d37ff0ef          	jal	ra,ffffffffc020099e <interrupt_handler>
ffffffffc0200c6c:	bff1                	j	ffffffffc0200c48 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6e:	0006c863          	bltz	a3,ffffffffc0200c7e <trap+0x66>
}
ffffffffc0200c72:	6442                	ld	s0,16(sp)
ffffffffc0200c74:	60e2                	ld	ra,24(sp)
ffffffffc0200c76:	64a2                	ld	s1,8(sp)
ffffffffc0200c78:	6902                	ld	s2,0(sp)
ffffffffc0200c7a:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c7c:	bb75                	j	ffffffffc0200a38 <exception_handler>
}
ffffffffc0200c7e:	6442                	ld	s0,16(sp)
ffffffffc0200c80:	60e2                	ld	ra,24(sp)
ffffffffc0200c82:	64a2                	ld	s1,8(sp)
ffffffffc0200c84:	6902                	ld	s2,0(sp)
ffffffffc0200c86:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c88:	bb19                	j	ffffffffc020099e <interrupt_handler>
}
ffffffffc0200c8a:	6442                	ld	s0,16(sp)
ffffffffc0200c8c:	60e2                	ld	ra,24(sp)
ffffffffc0200c8e:	64a2                	ld	s1,8(sp)
ffffffffc0200c90:	6902                	ld	s2,0(sp)
ffffffffc0200c92:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c94:	0a60506f          	j	ffffffffc0205d3a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c98:	555d                	li	a0,-9
ffffffffc0200c9a:	50c040ef          	jal	ra,ffffffffc02051a6 <do_exit>
ffffffffc0200c9e:	601c                	ld	a5,0(s0)
ffffffffc0200ca0:	bf65                	j	ffffffffc0200c58 <trap+0x40>
	...

ffffffffc0200ca4 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ca4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ca8:	00011463          	bnez	sp,ffffffffc0200cb0 <__alltraps+0xc>
ffffffffc0200cac:	14002173          	csrr	sp,sscratch
ffffffffc0200cb0:	712d                	addi	sp,sp,-288
ffffffffc0200cb2:	e002                	sd	zero,0(sp)
ffffffffc0200cb4:	e406                	sd	ra,8(sp)
ffffffffc0200cb6:	ec0e                	sd	gp,24(sp)
ffffffffc0200cb8:	f012                	sd	tp,32(sp)
ffffffffc0200cba:	f416                	sd	t0,40(sp)
ffffffffc0200cbc:	f81a                	sd	t1,48(sp)
ffffffffc0200cbe:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc0:	e0a2                	sd	s0,64(sp)
ffffffffc0200cc2:	e4a6                	sd	s1,72(sp)
ffffffffc0200cc4:	e8aa                	sd	a0,80(sp)
ffffffffc0200cc6:	ecae                	sd	a1,88(sp)
ffffffffc0200cc8:	f0b2                	sd	a2,96(sp)
ffffffffc0200cca:	f4b6                	sd	a3,104(sp)
ffffffffc0200ccc:	f8ba                	sd	a4,112(sp)
ffffffffc0200cce:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd0:	e142                	sd	a6,128(sp)
ffffffffc0200cd2:	e546                	sd	a7,136(sp)
ffffffffc0200cd4:	e94a                	sd	s2,144(sp)
ffffffffc0200cd6:	ed4e                	sd	s3,152(sp)
ffffffffc0200cd8:	f152                	sd	s4,160(sp)
ffffffffc0200cda:	f556                	sd	s5,168(sp)
ffffffffc0200cdc:	f95a                	sd	s6,176(sp)
ffffffffc0200cde:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce0:	e1e2                	sd	s8,192(sp)
ffffffffc0200ce2:	e5e6                	sd	s9,200(sp)
ffffffffc0200ce4:	e9ea                	sd	s10,208(sp)
ffffffffc0200ce6:	edee                	sd	s11,216(sp)
ffffffffc0200ce8:	f1f2                	sd	t3,224(sp)
ffffffffc0200cea:	f5f6                	sd	t4,232(sp)
ffffffffc0200cec:	f9fa                	sd	t5,240(sp)
ffffffffc0200cee:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cf4:	100024f3          	csrr	s1,sstatus
ffffffffc0200cf8:	14102973          	csrr	s2,sepc
ffffffffc0200cfc:	143029f3          	csrr	s3,stval
ffffffffc0200d00:	14202a73          	csrr	s4,scause
ffffffffc0200d04:	e822                	sd	s0,16(sp)
ffffffffc0200d06:	e226                	sd	s1,256(sp)
ffffffffc0200d08:	e64a                	sd	s2,264(sp)
ffffffffc0200d0a:	ea4e                	sd	s3,272(sp)
ffffffffc0200d0c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d0e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d10:	f09ff0ef          	jal	ra,ffffffffc0200c18 <trap>

ffffffffc0200d14 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d14:	6492                	ld	s1,256(sp)
ffffffffc0200d16:	6932                	ld	s2,264(sp)
ffffffffc0200d18:	1004f413          	andi	s0,s1,256
ffffffffc0200d1c:	e401                	bnez	s0,ffffffffc0200d24 <__trapret+0x10>
ffffffffc0200d1e:	1200                	addi	s0,sp,288
ffffffffc0200d20:	14041073          	csrw	sscratch,s0
ffffffffc0200d24:	10049073          	csrw	sstatus,s1
ffffffffc0200d28:	14191073          	csrw	sepc,s2
ffffffffc0200d2c:	60a2                	ld	ra,8(sp)
ffffffffc0200d2e:	61e2                	ld	gp,24(sp)
ffffffffc0200d30:	7202                	ld	tp,32(sp)
ffffffffc0200d32:	72a2                	ld	t0,40(sp)
ffffffffc0200d34:	7342                	ld	t1,48(sp)
ffffffffc0200d36:	73e2                	ld	t2,56(sp)
ffffffffc0200d38:	6406                	ld	s0,64(sp)
ffffffffc0200d3a:	64a6                	ld	s1,72(sp)
ffffffffc0200d3c:	6546                	ld	a0,80(sp)
ffffffffc0200d3e:	65e6                	ld	a1,88(sp)
ffffffffc0200d40:	7606                	ld	a2,96(sp)
ffffffffc0200d42:	76a6                	ld	a3,104(sp)
ffffffffc0200d44:	7746                	ld	a4,112(sp)
ffffffffc0200d46:	77e6                	ld	a5,120(sp)
ffffffffc0200d48:	680a                	ld	a6,128(sp)
ffffffffc0200d4a:	68aa                	ld	a7,136(sp)
ffffffffc0200d4c:	694a                	ld	s2,144(sp)
ffffffffc0200d4e:	69ea                	ld	s3,152(sp)
ffffffffc0200d50:	7a0a                	ld	s4,160(sp)
ffffffffc0200d52:	7aaa                	ld	s5,168(sp)
ffffffffc0200d54:	7b4a                	ld	s6,176(sp)
ffffffffc0200d56:	7bea                	ld	s7,184(sp)
ffffffffc0200d58:	6c0e                	ld	s8,192(sp)
ffffffffc0200d5a:	6cae                	ld	s9,200(sp)
ffffffffc0200d5c:	6d4e                	ld	s10,208(sp)
ffffffffc0200d5e:	6dee                	ld	s11,216(sp)
ffffffffc0200d60:	7e0e                	ld	t3,224(sp)
ffffffffc0200d62:	7eae                	ld	t4,232(sp)
ffffffffc0200d64:	7f4e                	ld	t5,240(sp)
ffffffffc0200d66:	7fee                	ld	t6,248(sp)
ffffffffc0200d68:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d6a:	10200073          	sret

ffffffffc0200d6e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d6e:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d70:	b755                	j	ffffffffc0200d14 <__trapret>

ffffffffc0200d72 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d72:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d76:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d7a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d7e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d82:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d86:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d8a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d8e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d92:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d96:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d98:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d9a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d9c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d9e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da0:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200da2:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200da4:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200da6:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200da8:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200daa:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dac:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dae:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db0:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200db2:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200db4:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200db6:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200db8:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dba:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dbc:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dbe:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc0:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dc2:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dc4:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dc6:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dc8:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dca:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dcc:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dce:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dd2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dd4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dd6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dd8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dda:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200ddc:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dde:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200de2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200de4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200de6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200de8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dea:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dec:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dee:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200df2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200df4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200df6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200df8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dfa:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200dfc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dfe:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e00:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e02:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e04:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e06:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e08:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e0a:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e0c:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e0e:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e10:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e12:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e14:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e16:	812e                	mv	sp,a1
ffffffffc0200e18:	bdf5                	j	ffffffffc0200d14 <__trapret>

ffffffffc0200e1a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e1a:	000ac797          	auipc	a5,0xac
ffffffffc0200e1e:	a4e78793          	addi	a5,a5,-1458 # ffffffffc02ac868 <free_area>
ffffffffc0200e22:	e79c                	sd	a5,8(a5)
ffffffffc0200e24:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e26:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e2a:	8082                	ret

ffffffffc0200e2c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e2c:	000ac517          	auipc	a0,0xac
ffffffffc0200e30:	a4c56503          	lwu	a0,-1460(a0) # ffffffffc02ac878 <free_area+0x10>
ffffffffc0200e34:	8082                	ret

ffffffffc0200e36 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e36:	715d                	addi	sp,sp,-80
ffffffffc0200e38:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e3a:	000ac917          	auipc	s2,0xac
ffffffffc0200e3e:	a2e90913          	addi	s2,s2,-1490 # ffffffffc02ac868 <free_area>
ffffffffc0200e42:	00893783          	ld	a5,8(s2)
ffffffffc0200e46:	e486                	sd	ra,72(sp)
ffffffffc0200e48:	e0a2                	sd	s0,64(sp)
ffffffffc0200e4a:	fc26                	sd	s1,56(sp)
ffffffffc0200e4c:	f44e                	sd	s3,40(sp)
ffffffffc0200e4e:	f052                	sd	s4,32(sp)
ffffffffc0200e50:	ec56                	sd	s5,24(sp)
ffffffffc0200e52:	e85a                	sd	s6,16(sp)
ffffffffc0200e54:	e45e                	sd	s7,8(sp)
ffffffffc0200e56:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e58:	31278463          	beq	a5,s2,ffffffffc0201160 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e5c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e60:	8305                	srli	a4,a4,0x1
ffffffffc0200e62:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e64:	30070263          	beqz	a4,ffffffffc0201168 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e68:	4401                	li	s0,0
ffffffffc0200e6a:	4481                	li	s1,0
ffffffffc0200e6c:	a031                	j	ffffffffc0200e78 <default_check+0x42>
ffffffffc0200e6e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e72:	8b09                	andi	a4,a4,2
ffffffffc0200e74:	2e070a63          	beqz	a4,ffffffffc0201168 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200e78:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e7c:	679c                	ld	a5,8(a5)
ffffffffc0200e7e:	2485                	addiw	s1,s1,1
ffffffffc0200e80:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e82:	ff2796e3          	bne	a5,s2,ffffffffc0200e6e <default_check+0x38>
ffffffffc0200e86:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200e88:	046010ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc0200e8c:	73351e63          	bne	a0,s3,ffffffffc02015c8 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e90:	4505                	li	a0,1
ffffffffc0200e92:	76f000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200e96:	8a2a                	mv	s4,a0
ffffffffc0200e98:	46050863          	beqz	a0,ffffffffc0201308 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e9c:	4505                	li	a0,1
ffffffffc0200e9e:	763000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200ea2:	89aa                	mv	s3,a0
ffffffffc0200ea4:	74050263          	beqz	a0,ffffffffc02015e8 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ea8:	4505                	li	a0,1
ffffffffc0200eaa:	757000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200eae:	8aaa                	mv	s5,a0
ffffffffc0200eb0:	4c050c63          	beqz	a0,ffffffffc0201388 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eb4:	2d3a0a63          	beq	s4,s3,ffffffffc0201188 <default_check+0x352>
ffffffffc0200eb8:	2caa0863          	beq	s4,a0,ffffffffc0201188 <default_check+0x352>
ffffffffc0200ebc:	2ca98663          	beq	s3,a0,ffffffffc0201188 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ec0:	000a2783          	lw	a5,0(s4)
ffffffffc0200ec4:	2e079263          	bnez	a5,ffffffffc02011a8 <default_check+0x372>
ffffffffc0200ec8:	0009a783          	lw	a5,0(s3)
ffffffffc0200ecc:	2c079e63          	bnez	a5,ffffffffc02011a8 <default_check+0x372>
ffffffffc0200ed0:	411c                	lw	a5,0(a0)
ffffffffc0200ed2:	2c079b63          	bnez	a5,ffffffffc02011a8 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ed6:	000ac797          	auipc	a5,0xac
ffffffffc0200eda:	9c278793          	addi	a5,a5,-1598 # ffffffffc02ac898 <pages>
ffffffffc0200ede:	639c                	ld	a5,0(a5)
ffffffffc0200ee0:	00008717          	auipc	a4,0x8
ffffffffc0200ee4:	b0070713          	addi	a4,a4,-1280 # ffffffffc02089e0 <nbase>
ffffffffc0200ee8:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eea:	000ac717          	auipc	a4,0xac
ffffffffc0200eee:	93e70713          	addi	a4,a4,-1730 # ffffffffc02ac828 <npage>
ffffffffc0200ef2:	6314                	ld	a3,0(a4)
ffffffffc0200ef4:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ef8:	8719                	srai	a4,a4,0x6
ffffffffc0200efa:	9732                	add	a4,a4,a2
ffffffffc0200efc:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200efe:	0732                	slli	a4,a4,0xc
ffffffffc0200f00:	2cd77463          	bgeu	a4,a3,ffffffffc02011c8 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f04:	40f98733          	sub	a4,s3,a5
ffffffffc0200f08:	8719                	srai	a4,a4,0x6
ffffffffc0200f0a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f0c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f0e:	4ed77d63          	bgeu	a4,a3,ffffffffc0201408 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f12:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f16:	8799                	srai	a5,a5,0x6
ffffffffc0200f18:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f1a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f1c:	34d7f663          	bgeu	a5,a3,ffffffffc0201268 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f20:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f22:	00093c03          	ld	s8,0(s2)
ffffffffc0200f26:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f2a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f2e:	000ac797          	auipc	a5,0xac
ffffffffc0200f32:	9527b123          	sd	s2,-1726(a5) # ffffffffc02ac870 <free_area+0x8>
ffffffffc0200f36:	000ac797          	auipc	a5,0xac
ffffffffc0200f3a:	9327b923          	sd	s2,-1742(a5) # ffffffffc02ac868 <free_area>
    nr_free = 0;
ffffffffc0200f3e:	000ac797          	auipc	a5,0xac
ffffffffc0200f42:	9207ad23          	sw	zero,-1734(a5) # ffffffffc02ac878 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f46:	6bb000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200f4a:	2e051f63          	bnez	a0,ffffffffc0201248 <default_check+0x412>
    free_page(p0);
ffffffffc0200f4e:	4585                	li	a1,1
ffffffffc0200f50:	8552                	mv	a0,s4
ffffffffc0200f52:	737000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_page(p1);
ffffffffc0200f56:	4585                	li	a1,1
ffffffffc0200f58:	854e                	mv	a0,s3
ffffffffc0200f5a:	72f000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_page(p2);
ffffffffc0200f5e:	4585                	li	a1,1
ffffffffc0200f60:	8556                	mv	a0,s5
ffffffffc0200f62:	727000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f66:	01092703          	lw	a4,16(s2)
ffffffffc0200f6a:	478d                	li	a5,3
ffffffffc0200f6c:	2af71e63          	bne	a4,a5,ffffffffc0201228 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f70:	4505                	li	a0,1
ffffffffc0200f72:	68f000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200f76:	89aa                	mv	s3,a0
ffffffffc0200f78:	28050863          	beqz	a0,ffffffffc0201208 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f7c:	4505                	li	a0,1
ffffffffc0200f7e:	683000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200f82:	8aaa                	mv	s5,a0
ffffffffc0200f84:	3e050263          	beqz	a0,ffffffffc0201368 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f88:	4505                	li	a0,1
ffffffffc0200f8a:	677000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200f8e:	8a2a                	mv	s4,a0
ffffffffc0200f90:	3a050c63          	beqz	a0,ffffffffc0201348 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200f94:	4505                	li	a0,1
ffffffffc0200f96:	66b000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200f9a:	38051763          	bnez	a0,ffffffffc0201328 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200f9e:	4585                	li	a1,1
ffffffffc0200fa0:	854e                	mv	a0,s3
ffffffffc0200fa2:	6e7000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fa6:	00893783          	ld	a5,8(s2)
ffffffffc0200faa:	23278f63          	beq	a5,s2,ffffffffc02011e8 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fae:	4505                	li	a0,1
ffffffffc0200fb0:	651000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200fb4:	32a99a63          	bne	s3,a0,ffffffffc02012e8 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	647000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0200fbe:	30051563          	bnez	a0,ffffffffc02012c8 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fc2:	01092783          	lw	a5,16(s2)
ffffffffc0200fc6:	2e079163          	bnez	a5,ffffffffc02012a8 <default_check+0x472>
    free_page(p);
ffffffffc0200fca:	854e                	mv	a0,s3
ffffffffc0200fcc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fce:	000ac797          	auipc	a5,0xac
ffffffffc0200fd2:	8987bd23          	sd	s8,-1894(a5) # ffffffffc02ac868 <free_area>
ffffffffc0200fd6:	000ac797          	auipc	a5,0xac
ffffffffc0200fda:	8977bd23          	sd	s7,-1894(a5) # ffffffffc02ac870 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200fde:	000ac797          	auipc	a5,0xac
ffffffffc0200fe2:	8967ad23          	sw	s6,-1894(a5) # ffffffffc02ac878 <free_area+0x10>
    free_page(p);
ffffffffc0200fe6:	6a3000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_page(p1);
ffffffffc0200fea:	4585                	li	a1,1
ffffffffc0200fec:	8556                	mv	a0,s5
ffffffffc0200fee:	69b000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_page(p2);
ffffffffc0200ff2:	4585                	li	a1,1
ffffffffc0200ff4:	8552                	mv	a0,s4
ffffffffc0200ff6:	693000ef          	jal	ra,ffffffffc0201e88 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ffa:	4515                	li	a0,5
ffffffffc0200ffc:	605000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0201000:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201002:	28050363          	beqz	a0,ffffffffc0201288 <default_check+0x452>
ffffffffc0201006:	651c                	ld	a5,8(a0)
ffffffffc0201008:	8385                	srli	a5,a5,0x1
ffffffffc020100a:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc020100c:	54079e63          	bnez	a5,ffffffffc0201568 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201010:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201012:	00093b03          	ld	s6,0(s2)
ffffffffc0201016:	00893a83          	ld	s5,8(s2)
ffffffffc020101a:	000ac797          	auipc	a5,0xac
ffffffffc020101e:	8527b723          	sd	s2,-1970(a5) # ffffffffc02ac868 <free_area>
ffffffffc0201022:	000ac797          	auipc	a5,0xac
ffffffffc0201026:	8527b723          	sd	s2,-1970(a5) # ffffffffc02ac870 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020102a:	5d7000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc020102e:	50051d63          	bnez	a0,ffffffffc0201548 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201032:	08098a13          	addi	s4,s3,128
ffffffffc0201036:	8552                	mv	a0,s4
ffffffffc0201038:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020103a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020103e:	000ac797          	auipc	a5,0xac
ffffffffc0201042:	8207ad23          	sw	zero,-1990(a5) # ffffffffc02ac878 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201046:	643000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020104a:	4511                	li	a0,4
ffffffffc020104c:	5b5000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0201050:	4c051c63          	bnez	a0,ffffffffc0201528 <default_check+0x6f2>
ffffffffc0201054:	0889b783          	ld	a5,136(s3)
ffffffffc0201058:	8385                	srli	a5,a5,0x1
ffffffffc020105a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020105c:	4a078663          	beqz	a5,ffffffffc0201508 <default_check+0x6d2>
ffffffffc0201060:	0909a703          	lw	a4,144(s3)
ffffffffc0201064:	478d                	li	a5,3
ffffffffc0201066:	4af71163          	bne	a4,a5,ffffffffc0201508 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020106a:	450d                	li	a0,3
ffffffffc020106c:	595000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0201070:	8c2a                	mv	s8,a0
ffffffffc0201072:	46050b63          	beqz	a0,ffffffffc02014e8 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0201076:	4505                	li	a0,1
ffffffffc0201078:	589000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc020107c:	44051663          	bnez	a0,ffffffffc02014c8 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0201080:	438a1463          	bne	s4,s8,ffffffffc02014a8 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201084:	4585                	li	a1,1
ffffffffc0201086:	854e                	mv	a0,s3
ffffffffc0201088:	601000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_pages(p1, 3);
ffffffffc020108c:	458d                	li	a1,3
ffffffffc020108e:	8552                	mv	a0,s4
ffffffffc0201090:	5f9000ef          	jal	ra,ffffffffc0201e88 <free_pages>
ffffffffc0201094:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201098:	04098c13          	addi	s8,s3,64
ffffffffc020109c:	8385                	srli	a5,a5,0x1
ffffffffc020109e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010a0:	3e078463          	beqz	a5,ffffffffc0201488 <default_check+0x652>
ffffffffc02010a4:	0109a703          	lw	a4,16(s3)
ffffffffc02010a8:	4785                	li	a5,1
ffffffffc02010aa:	3cf71f63          	bne	a4,a5,ffffffffc0201488 <default_check+0x652>
ffffffffc02010ae:	008a3783          	ld	a5,8(s4)
ffffffffc02010b2:	8385                	srli	a5,a5,0x1
ffffffffc02010b4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010b6:	3a078963          	beqz	a5,ffffffffc0201468 <default_check+0x632>
ffffffffc02010ba:	010a2703          	lw	a4,16(s4)
ffffffffc02010be:	478d                	li	a5,3
ffffffffc02010c0:	3af71463          	bne	a4,a5,ffffffffc0201468 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010c4:	4505                	li	a0,1
ffffffffc02010c6:	53b000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02010ca:	36a99f63          	bne	s3,a0,ffffffffc0201448 <default_check+0x612>
    free_page(p0);
ffffffffc02010ce:	4585                	li	a1,1
ffffffffc02010d0:	5b9000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010d4:	4509                	li	a0,2
ffffffffc02010d6:	52b000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02010da:	34aa1763          	bne	s4,a0,ffffffffc0201428 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02010de:	4589                	li	a1,2
ffffffffc02010e0:	5a9000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    free_page(p2);
ffffffffc02010e4:	4585                	li	a1,1
ffffffffc02010e6:	8562                	mv	a0,s8
ffffffffc02010e8:	5a1000ef          	jal	ra,ffffffffc0201e88 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010ec:	4515                	li	a0,5
ffffffffc02010ee:	513000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02010f2:	89aa                	mv	s3,a0
ffffffffc02010f4:	48050a63          	beqz	a0,ffffffffc0201588 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02010f8:	4505                	li	a0,1
ffffffffc02010fa:	507000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02010fe:	2e051563          	bnez	a0,ffffffffc02013e8 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201102:	01092783          	lw	a5,16(s2)
ffffffffc0201106:	2c079163          	bnez	a5,ffffffffc02013c8 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020110a:	4595                	li	a1,5
ffffffffc020110c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020110e:	000ab797          	auipc	a5,0xab
ffffffffc0201112:	7777a523          	sw	s7,1898(a5) # ffffffffc02ac878 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201116:	000ab797          	auipc	a5,0xab
ffffffffc020111a:	7567b923          	sd	s6,1874(a5) # ffffffffc02ac868 <free_area>
ffffffffc020111e:	000ab797          	auipc	a5,0xab
ffffffffc0201122:	7557b923          	sd	s5,1874(a5) # ffffffffc02ac870 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201126:	563000ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return listelm->next;
ffffffffc020112a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020112e:	01278963          	beq	a5,s2,ffffffffc0201140 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201132:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201136:	679c                	ld	a5,8(a5)
ffffffffc0201138:	34fd                	addiw	s1,s1,-1
ffffffffc020113a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020113c:	ff279be3          	bne	a5,s2,ffffffffc0201132 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201140:	26049463          	bnez	s1,ffffffffc02013a8 <default_check+0x572>
    assert(total == 0);
ffffffffc0201144:	46041263          	bnez	s0,ffffffffc02015a8 <default_check+0x772>
}
ffffffffc0201148:	60a6                	ld	ra,72(sp)
ffffffffc020114a:	6406                	ld	s0,64(sp)
ffffffffc020114c:	74e2                	ld	s1,56(sp)
ffffffffc020114e:	7942                	ld	s2,48(sp)
ffffffffc0201150:	79a2                	ld	s3,40(sp)
ffffffffc0201152:	7a02                	ld	s4,32(sp)
ffffffffc0201154:	6ae2                	ld	s5,24(sp)
ffffffffc0201156:	6b42                	ld	s6,16(sp)
ffffffffc0201158:	6ba2                	ld	s7,8(sp)
ffffffffc020115a:	6c02                	ld	s8,0(sp)
ffffffffc020115c:	6161                	addi	sp,sp,80
ffffffffc020115e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201160:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201162:	4401                	li	s0,0
ffffffffc0201164:	4481                	li	s1,0
ffffffffc0201166:	b30d                	j	ffffffffc0200e88 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201168:	00006697          	auipc	a3,0x6
ffffffffc020116c:	bc068693          	addi	a3,a3,-1088 # ffffffffc0206d28 <commands+0x878>
ffffffffc0201170:	00006617          	auipc	a2,0x6
ffffffffc0201174:	80060613          	addi	a2,a2,-2048 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201178:	0f000593          	li	a1,240
ffffffffc020117c:	00006517          	auipc	a0,0x6
ffffffffc0201180:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201184:	afcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201188:	00006697          	auipc	a3,0x6
ffffffffc020118c:	c4868693          	addi	a3,a3,-952 # ffffffffc0206dd0 <commands+0x920>
ffffffffc0201190:	00005617          	auipc	a2,0x5
ffffffffc0201194:	7e060613          	addi	a2,a2,2016 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201198:	0bd00593          	li	a1,189
ffffffffc020119c:	00006517          	auipc	a0,0x6
ffffffffc02011a0:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0206d38 <commands+0x888>
ffffffffc02011a4:	adcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011a8:	00006697          	auipc	a3,0x6
ffffffffc02011ac:	c5068693          	addi	a3,a3,-944 # ffffffffc0206df8 <commands+0x948>
ffffffffc02011b0:	00005617          	auipc	a2,0x5
ffffffffc02011b4:	7c060613          	addi	a2,a2,1984 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02011b8:	0be00593          	li	a1,190
ffffffffc02011bc:	00006517          	auipc	a0,0x6
ffffffffc02011c0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0206d38 <commands+0x888>
ffffffffc02011c4:	abcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011c8:	00006697          	auipc	a3,0x6
ffffffffc02011cc:	c7068693          	addi	a3,a3,-912 # ffffffffc0206e38 <commands+0x988>
ffffffffc02011d0:	00005617          	auipc	a2,0x5
ffffffffc02011d4:	7a060613          	addi	a2,a2,1952 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02011d8:	0c000593          	li	a1,192
ffffffffc02011dc:	00006517          	auipc	a0,0x6
ffffffffc02011e0:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0206d38 <commands+0x888>
ffffffffc02011e4:	a9cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011e8:	00006697          	auipc	a3,0x6
ffffffffc02011ec:	cd868693          	addi	a3,a3,-808 # ffffffffc0206ec0 <commands+0xa10>
ffffffffc02011f0:	00005617          	auipc	a2,0x5
ffffffffc02011f4:	78060613          	addi	a2,a2,1920 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02011f8:	0d900593          	li	a1,217
ffffffffc02011fc:	00006517          	auipc	a0,0x6
ffffffffc0201200:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201204:	a7cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201208:	00006697          	auipc	a3,0x6
ffffffffc020120c:	b6868693          	addi	a3,a3,-1176 # ffffffffc0206d70 <commands+0x8c0>
ffffffffc0201210:	00005617          	auipc	a2,0x5
ffffffffc0201214:	76060613          	addi	a2,a2,1888 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201218:	0d200593          	li	a1,210
ffffffffc020121c:	00006517          	auipc	a0,0x6
ffffffffc0201220:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201224:	a5cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 3);
ffffffffc0201228:	00006697          	auipc	a3,0x6
ffffffffc020122c:	c8868693          	addi	a3,a3,-888 # ffffffffc0206eb0 <commands+0xa00>
ffffffffc0201230:	00005617          	auipc	a2,0x5
ffffffffc0201234:	74060613          	addi	a2,a2,1856 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201238:	0d000593          	li	a1,208
ffffffffc020123c:	00006517          	auipc	a0,0x6
ffffffffc0201240:	afc50513          	addi	a0,a0,-1284 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201244:	a3cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201248:	00006697          	auipc	a3,0x6
ffffffffc020124c:	c5068693          	addi	a3,a3,-944 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc0201250:	00005617          	auipc	a2,0x5
ffffffffc0201254:	72060613          	addi	a2,a2,1824 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201258:	0cb00593          	li	a1,203
ffffffffc020125c:	00006517          	auipc	a0,0x6
ffffffffc0201260:	adc50513          	addi	a0,a0,-1316 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201264:	a1cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201268:	00006697          	auipc	a3,0x6
ffffffffc020126c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0206e78 <commands+0x9c8>
ffffffffc0201270:	00005617          	auipc	a2,0x5
ffffffffc0201274:	70060613          	addi	a2,a2,1792 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201278:	0c200593          	li	a1,194
ffffffffc020127c:	00006517          	auipc	a0,0x6
ffffffffc0201280:	abc50513          	addi	a0,a0,-1348 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201284:	9fcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != NULL);
ffffffffc0201288:	00006697          	auipc	a3,0x6
ffffffffc020128c:	c8068693          	addi	a3,a3,-896 # ffffffffc0206f08 <commands+0xa58>
ffffffffc0201290:	00005617          	auipc	a2,0x5
ffffffffc0201294:	6e060613          	addi	a2,a2,1760 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201298:	0f800593          	li	a1,248
ffffffffc020129c:	00006517          	auipc	a0,0x6
ffffffffc02012a0:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0206d38 <commands+0x888>
ffffffffc02012a4:	9dcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02012a8:	00006697          	auipc	a3,0x6
ffffffffc02012ac:	c5068693          	addi	a3,a3,-944 # ffffffffc0206ef8 <commands+0xa48>
ffffffffc02012b0:	00005617          	auipc	a2,0x5
ffffffffc02012b4:	6c060613          	addi	a2,a2,1728 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02012b8:	0df00593          	li	a1,223
ffffffffc02012bc:	00006517          	auipc	a0,0x6
ffffffffc02012c0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0206d38 <commands+0x888>
ffffffffc02012c4:	9bcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012c8:	00006697          	auipc	a3,0x6
ffffffffc02012cc:	bd068693          	addi	a3,a3,-1072 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc02012d0:	00005617          	auipc	a2,0x5
ffffffffc02012d4:	6a060613          	addi	a2,a2,1696 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02012d8:	0dd00593          	li	a1,221
ffffffffc02012dc:	00006517          	auipc	a0,0x6
ffffffffc02012e0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0206d38 <commands+0x888>
ffffffffc02012e4:	99cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012e8:	00006697          	auipc	a3,0x6
ffffffffc02012ec:	bf068693          	addi	a3,a3,-1040 # ffffffffc0206ed8 <commands+0xa28>
ffffffffc02012f0:	00005617          	auipc	a2,0x5
ffffffffc02012f4:	68060613          	addi	a2,a2,1664 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02012f8:	0dc00593          	li	a1,220
ffffffffc02012fc:	00006517          	auipc	a0,0x6
ffffffffc0201300:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201304:	97cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201308:	00006697          	auipc	a3,0x6
ffffffffc020130c:	a6868693          	addi	a3,a3,-1432 # ffffffffc0206d70 <commands+0x8c0>
ffffffffc0201310:	00005617          	auipc	a2,0x5
ffffffffc0201314:	66060613          	addi	a2,a2,1632 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201318:	0b900593          	li	a1,185
ffffffffc020131c:	00006517          	auipc	a0,0x6
ffffffffc0201320:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201324:	95cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201328:	00006697          	auipc	a3,0x6
ffffffffc020132c:	b7068693          	addi	a3,a3,-1168 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc0201330:	00005617          	auipc	a2,0x5
ffffffffc0201334:	64060613          	addi	a2,a2,1600 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201338:	0d600593          	li	a1,214
ffffffffc020133c:	00006517          	auipc	a0,0x6
ffffffffc0201340:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201344:	93cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201348:	00006697          	auipc	a3,0x6
ffffffffc020134c:	a6868693          	addi	a3,a3,-1432 # ffffffffc0206db0 <commands+0x900>
ffffffffc0201350:	00005617          	auipc	a2,0x5
ffffffffc0201354:	62060613          	addi	a2,a2,1568 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201358:	0d400593          	li	a1,212
ffffffffc020135c:	00006517          	auipc	a0,0x6
ffffffffc0201360:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201364:	91cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201368:	00006697          	auipc	a3,0x6
ffffffffc020136c:	a2868693          	addi	a3,a3,-1496 # ffffffffc0206d90 <commands+0x8e0>
ffffffffc0201370:	00005617          	auipc	a2,0x5
ffffffffc0201374:	60060613          	addi	a2,a2,1536 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201378:	0d300593          	li	a1,211
ffffffffc020137c:	00006517          	auipc	a0,0x6
ffffffffc0201380:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201384:	8fcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201388:	00006697          	auipc	a3,0x6
ffffffffc020138c:	a2868693          	addi	a3,a3,-1496 # ffffffffc0206db0 <commands+0x900>
ffffffffc0201390:	00005617          	auipc	a2,0x5
ffffffffc0201394:	5e060613          	addi	a2,a2,1504 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201398:	0bb00593          	li	a1,187
ffffffffc020139c:	00006517          	auipc	a0,0x6
ffffffffc02013a0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206d38 <commands+0x888>
ffffffffc02013a4:	8dcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(count == 0);
ffffffffc02013a8:	00006697          	auipc	a3,0x6
ffffffffc02013ac:	cb068693          	addi	a3,a3,-848 # ffffffffc0207058 <commands+0xba8>
ffffffffc02013b0:	00005617          	auipc	a2,0x5
ffffffffc02013b4:	5c060613          	addi	a2,a2,1472 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02013b8:	12500593          	li	a1,293
ffffffffc02013bc:	00006517          	auipc	a0,0x6
ffffffffc02013c0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206d38 <commands+0x888>
ffffffffc02013c4:	8bcff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02013c8:	00006697          	auipc	a3,0x6
ffffffffc02013cc:	b3068693          	addi	a3,a3,-1232 # ffffffffc0206ef8 <commands+0xa48>
ffffffffc02013d0:	00005617          	auipc	a2,0x5
ffffffffc02013d4:	5a060613          	addi	a2,a2,1440 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02013d8:	11a00593          	li	a1,282
ffffffffc02013dc:	00006517          	auipc	a0,0x6
ffffffffc02013e0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0206d38 <commands+0x888>
ffffffffc02013e4:	89cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013e8:	00006697          	auipc	a3,0x6
ffffffffc02013ec:	ab068693          	addi	a3,a3,-1360 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc02013f0:	00005617          	auipc	a2,0x5
ffffffffc02013f4:	58060613          	addi	a2,a2,1408 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02013f8:	11800593          	li	a1,280
ffffffffc02013fc:	00006517          	auipc	a0,0x6
ffffffffc0201400:	93c50513          	addi	a0,a0,-1732 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201404:	87cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201408:	00006697          	auipc	a3,0x6
ffffffffc020140c:	a5068693          	addi	a3,a3,-1456 # ffffffffc0206e58 <commands+0x9a8>
ffffffffc0201410:	00005617          	auipc	a2,0x5
ffffffffc0201414:	56060613          	addi	a2,a2,1376 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201418:	0c100593          	li	a1,193
ffffffffc020141c:	00006517          	auipc	a0,0x6
ffffffffc0201420:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201424:	85cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201428:	00006697          	auipc	a3,0x6
ffffffffc020142c:	bf068693          	addi	a3,a3,-1040 # ffffffffc0207018 <commands+0xb68>
ffffffffc0201430:	00005617          	auipc	a2,0x5
ffffffffc0201434:	54060613          	addi	a2,a2,1344 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201438:	11200593          	li	a1,274
ffffffffc020143c:	00006517          	auipc	a0,0x6
ffffffffc0201440:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201444:	83cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201448:	00006697          	auipc	a3,0x6
ffffffffc020144c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0206ff8 <commands+0xb48>
ffffffffc0201450:	00005617          	auipc	a2,0x5
ffffffffc0201454:	52060613          	addi	a2,a2,1312 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201458:	11000593          	li	a1,272
ffffffffc020145c:	00006517          	auipc	a0,0x6
ffffffffc0201460:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201464:	81cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201468:	00006697          	auipc	a3,0x6
ffffffffc020146c:	b6868693          	addi	a3,a3,-1176 # ffffffffc0206fd0 <commands+0xb20>
ffffffffc0201470:	00005617          	auipc	a2,0x5
ffffffffc0201474:	50060613          	addi	a2,a2,1280 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201478:	10e00593          	li	a1,270
ffffffffc020147c:	00006517          	auipc	a0,0x6
ffffffffc0201480:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201484:	ffdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201488:	00006697          	auipc	a3,0x6
ffffffffc020148c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0206fa8 <commands+0xaf8>
ffffffffc0201490:	00005617          	auipc	a2,0x5
ffffffffc0201494:	4e060613          	addi	a2,a2,1248 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201498:	10d00593          	li	a1,269
ffffffffc020149c:	00006517          	auipc	a0,0x6
ffffffffc02014a0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0206d38 <commands+0x888>
ffffffffc02014a4:	fddfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014a8:	00006697          	auipc	a3,0x6
ffffffffc02014ac:	af068693          	addi	a3,a3,-1296 # ffffffffc0206f98 <commands+0xae8>
ffffffffc02014b0:	00005617          	auipc	a2,0x5
ffffffffc02014b4:	4c060613          	addi	a2,a2,1216 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02014b8:	10800593          	li	a1,264
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0206d38 <commands+0x888>
ffffffffc02014c4:	fbdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014c8:	00006697          	auipc	a3,0x6
ffffffffc02014cc:	9d068693          	addi	a3,a3,-1584 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc02014d0:	00005617          	auipc	a2,0x5
ffffffffc02014d4:	4a060613          	addi	a2,a2,1184 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02014d8:	10700593          	li	a1,263
ffffffffc02014dc:	00006517          	auipc	a0,0x6
ffffffffc02014e0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0206d38 <commands+0x888>
ffffffffc02014e4:	f9dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014e8:	00006697          	auipc	a3,0x6
ffffffffc02014ec:	a9068693          	addi	a3,a3,-1392 # ffffffffc0206f78 <commands+0xac8>
ffffffffc02014f0:	00005617          	auipc	a2,0x5
ffffffffc02014f4:	48060613          	addi	a2,a2,1152 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02014f8:	10600593          	li	a1,262
ffffffffc02014fc:	00006517          	auipc	a0,0x6
ffffffffc0201500:	83c50513          	addi	a0,a0,-1988 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201504:	f7dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201508:	00006697          	auipc	a3,0x6
ffffffffc020150c:	a4068693          	addi	a3,a3,-1472 # ffffffffc0206f48 <commands+0xa98>
ffffffffc0201510:	00005617          	auipc	a2,0x5
ffffffffc0201514:	46060613          	addi	a2,a2,1120 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201518:	10500593          	li	a1,261
ffffffffc020151c:	00006517          	auipc	a0,0x6
ffffffffc0201520:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201524:	f5dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201528:	00006697          	auipc	a3,0x6
ffffffffc020152c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0206f30 <commands+0xa80>
ffffffffc0201530:	00005617          	auipc	a2,0x5
ffffffffc0201534:	44060613          	addi	a2,a2,1088 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201538:	10400593          	li	a1,260
ffffffffc020153c:	00005517          	auipc	a0,0x5
ffffffffc0201540:	7fc50513          	addi	a0,a0,2044 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201544:	f3dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201548:	00006697          	auipc	a3,0x6
ffffffffc020154c:	95068693          	addi	a3,a3,-1712 # ffffffffc0206e98 <commands+0x9e8>
ffffffffc0201550:	00005617          	auipc	a2,0x5
ffffffffc0201554:	42060613          	addi	a2,a2,1056 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201558:	0fe00593          	li	a1,254
ffffffffc020155c:	00005517          	auipc	a0,0x5
ffffffffc0201560:	7dc50513          	addi	a0,a0,2012 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201564:	f1dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201568:	00006697          	auipc	a3,0x6
ffffffffc020156c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0206f18 <commands+0xa68>
ffffffffc0201570:	00005617          	auipc	a2,0x5
ffffffffc0201574:	40060613          	addi	a2,a2,1024 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201578:	0f900593          	li	a1,249
ffffffffc020157c:	00005517          	auipc	a0,0x5
ffffffffc0201580:	7bc50513          	addi	a0,a0,1980 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201584:	efdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201588:	00006697          	auipc	a3,0x6
ffffffffc020158c:	ab068693          	addi	a3,a3,-1360 # ffffffffc0207038 <commands+0xb88>
ffffffffc0201590:	00005617          	auipc	a2,0x5
ffffffffc0201594:	3e060613          	addi	a2,a2,992 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201598:	11700593          	li	a1,279
ffffffffc020159c:	00005517          	auipc	a0,0x5
ffffffffc02015a0:	79c50513          	addi	a0,a0,1948 # ffffffffc0206d38 <commands+0x888>
ffffffffc02015a4:	eddfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == 0);
ffffffffc02015a8:	00006697          	auipc	a3,0x6
ffffffffc02015ac:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207068 <commands+0xbb8>
ffffffffc02015b0:	00005617          	auipc	a2,0x5
ffffffffc02015b4:	3c060613          	addi	a2,a2,960 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02015b8:	12600593          	li	a1,294
ffffffffc02015bc:	00005517          	auipc	a0,0x5
ffffffffc02015c0:	77c50513          	addi	a0,a0,1916 # ffffffffc0206d38 <commands+0x888>
ffffffffc02015c4:	ebdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015c8:	00005697          	auipc	a3,0x5
ffffffffc02015cc:	78868693          	addi	a3,a3,1928 # ffffffffc0206d50 <commands+0x8a0>
ffffffffc02015d0:	00005617          	auipc	a2,0x5
ffffffffc02015d4:	3a060613          	addi	a2,a2,928 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02015d8:	0f300593          	li	a1,243
ffffffffc02015dc:	00005517          	auipc	a0,0x5
ffffffffc02015e0:	75c50513          	addi	a0,a0,1884 # ffffffffc0206d38 <commands+0x888>
ffffffffc02015e4:	e9dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015e8:	00005697          	auipc	a3,0x5
ffffffffc02015ec:	7a868693          	addi	a3,a3,1960 # ffffffffc0206d90 <commands+0x8e0>
ffffffffc02015f0:	00005617          	auipc	a2,0x5
ffffffffc02015f4:	38060613          	addi	a2,a2,896 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02015f8:	0ba00593          	li	a1,186
ffffffffc02015fc:	00005517          	auipc	a0,0x5
ffffffffc0201600:	73c50513          	addi	a0,a0,1852 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201604:	e7dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201608 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201608:	1141                	addi	sp,sp,-16
ffffffffc020160a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020160c:	16058e63          	beqz	a1,ffffffffc0201788 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201610:	00659693          	slli	a3,a1,0x6
ffffffffc0201614:	96aa                	add	a3,a3,a0
ffffffffc0201616:	02d50d63          	beq	a0,a3,ffffffffc0201650 <default_free_pages+0x48>
ffffffffc020161a:	651c                	ld	a5,8(a0)
ffffffffc020161c:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020161e:	14079563          	bnez	a5,ffffffffc0201768 <default_free_pages+0x160>
ffffffffc0201622:	651c                	ld	a5,8(a0)
ffffffffc0201624:	8385                	srli	a5,a5,0x1
ffffffffc0201626:	8b85                	andi	a5,a5,1
ffffffffc0201628:	14079063          	bnez	a5,ffffffffc0201768 <default_free_pages+0x160>
ffffffffc020162c:	87aa                	mv	a5,a0
ffffffffc020162e:	a809                	j	ffffffffc0201640 <default_free_pages+0x38>
ffffffffc0201630:	6798                	ld	a4,8(a5)
ffffffffc0201632:	8b05                	andi	a4,a4,1
ffffffffc0201634:	12071a63          	bnez	a4,ffffffffc0201768 <default_free_pages+0x160>
ffffffffc0201638:	6798                	ld	a4,8(a5)
ffffffffc020163a:	8b09                	andi	a4,a4,2
ffffffffc020163c:	12071663          	bnez	a4,ffffffffc0201768 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201640:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201644:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201648:	04078793          	addi	a5,a5,64
ffffffffc020164c:	fed792e3          	bne	a5,a3,ffffffffc0201630 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201650:	2581                	sext.w	a1,a1
ffffffffc0201652:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201654:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201658:	4789                	li	a5,2
ffffffffc020165a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020165e:	000ab697          	auipc	a3,0xab
ffffffffc0201662:	20a68693          	addi	a3,a3,522 # ffffffffc02ac868 <free_area>
ffffffffc0201666:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201668:	669c                	ld	a5,8(a3)
ffffffffc020166a:	9db9                	addw	a1,a1,a4
ffffffffc020166c:	000ab717          	auipc	a4,0xab
ffffffffc0201670:	20b72623          	sw	a1,524(a4) # ffffffffc02ac878 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201674:	0cd78163          	beq	a5,a3,ffffffffc0201736 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201678:	fe878713          	addi	a4,a5,-24
ffffffffc020167c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020167e:	4801                	li	a6,0
ffffffffc0201680:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201684:	00e56a63          	bltu	a0,a4,ffffffffc0201698 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0201688:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020168a:	04d70f63          	beq	a4,a3,ffffffffc02016e8 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020168e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201690:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201694:	fee57ae3          	bgeu	a0,a4,ffffffffc0201688 <default_free_pages+0x80>
ffffffffc0201698:	00080663          	beqz	a6,ffffffffc02016a4 <default_free_pages+0x9c>
ffffffffc020169c:	000ab817          	auipc	a6,0xab
ffffffffc02016a0:	1cb83623          	sd	a1,460(a6) # ffffffffc02ac868 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016a4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016a6:	e390                	sd	a2,0(a5)
ffffffffc02016a8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016aa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016ac:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016ae:	06d58a63          	beq	a1,a3,ffffffffc0201722 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016b2:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016b6:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016ba:	02061793          	slli	a5,a2,0x20
ffffffffc02016be:	83e9                	srli	a5,a5,0x1a
ffffffffc02016c0:	97ba                	add	a5,a5,a4
ffffffffc02016c2:	04f51b63          	bne	a0,a5,ffffffffc0201718 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016c6:	491c                	lw	a5,16(a0)
ffffffffc02016c8:	9e3d                	addw	a2,a2,a5
ffffffffc02016ca:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016ce:	57f5                	li	a5,-3
ffffffffc02016d0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016d4:	01853803          	ld	a6,24(a0)
ffffffffc02016d8:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02016da:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016dc:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02016e0:	659c                	ld	a5,8(a1)
ffffffffc02016e2:	01063023          	sd	a6,0(a2)
ffffffffc02016e6:	a815                	j	ffffffffc020171a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02016e8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016ea:	f114                	sd	a3,32(a0)
ffffffffc02016ec:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016ee:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016f0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016f2:	00d70563          	beq	a4,a3,ffffffffc02016fc <default_free_pages+0xf4>
ffffffffc02016f6:	4805                	li	a6,1
ffffffffc02016f8:	87ba                	mv	a5,a4
ffffffffc02016fa:	bf59                	j	ffffffffc0201690 <default_free_pages+0x88>
ffffffffc02016fc:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02016fe:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201700:	00d78d63          	beq	a5,a3,ffffffffc020171a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201704:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201708:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020170c:	02061793          	slli	a5,a2,0x20
ffffffffc0201710:	83e9                	srli	a5,a5,0x1a
ffffffffc0201712:	97ba                	add	a5,a5,a4
ffffffffc0201714:	faf509e3          	beq	a0,a5,ffffffffc02016c6 <default_free_pages+0xbe>
ffffffffc0201718:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020171a:	fe878713          	addi	a4,a5,-24
ffffffffc020171e:	00d78963          	beq	a5,a3,ffffffffc0201730 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201722:	4910                	lw	a2,16(a0)
ffffffffc0201724:	02061693          	slli	a3,a2,0x20
ffffffffc0201728:	82e9                	srli	a3,a3,0x1a
ffffffffc020172a:	96aa                	add	a3,a3,a0
ffffffffc020172c:	00d70e63          	beq	a4,a3,ffffffffc0201748 <default_free_pages+0x140>
}
ffffffffc0201730:	60a2                	ld	ra,8(sp)
ffffffffc0201732:	0141                	addi	sp,sp,16
ffffffffc0201734:	8082                	ret
ffffffffc0201736:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201738:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020173c:	e398                	sd	a4,0(a5)
ffffffffc020173e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201740:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201742:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201744:	0141                	addi	sp,sp,16
ffffffffc0201746:	8082                	ret
            base->property += p->property;
ffffffffc0201748:	ff87a703          	lw	a4,-8(a5)
ffffffffc020174c:	ff078693          	addi	a3,a5,-16
ffffffffc0201750:	9e39                	addw	a2,a2,a4
ffffffffc0201752:	c910                	sw	a2,16(a0)
ffffffffc0201754:	5775                	li	a4,-3
ffffffffc0201756:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020175a:	6398                	ld	a4,0(a5)
ffffffffc020175c:	679c                	ld	a5,8(a5)
}
ffffffffc020175e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201760:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201762:	e398                	sd	a4,0(a5)
ffffffffc0201764:	0141                	addi	sp,sp,16
ffffffffc0201766:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201768:	00006697          	auipc	a3,0x6
ffffffffc020176c:	91068693          	addi	a3,a3,-1776 # ffffffffc0207078 <commands+0xbc8>
ffffffffc0201770:	00005617          	auipc	a2,0x5
ffffffffc0201774:	20060613          	addi	a2,a2,512 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201778:	08300593          	li	a1,131
ffffffffc020177c:	00005517          	auipc	a0,0x5
ffffffffc0201780:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201784:	cfdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc0201788:	00006697          	auipc	a3,0x6
ffffffffc020178c:	91868693          	addi	a3,a3,-1768 # ffffffffc02070a0 <commands+0xbf0>
ffffffffc0201790:	00005617          	auipc	a2,0x5
ffffffffc0201794:	1e060613          	addi	a2,a2,480 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201798:	08000593          	li	a1,128
ffffffffc020179c:	00005517          	auipc	a0,0x5
ffffffffc02017a0:	59c50513          	addi	a0,a0,1436 # ffffffffc0206d38 <commands+0x888>
ffffffffc02017a4:	cddfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02017a8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017a8:	c959                	beqz	a0,ffffffffc020183e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017aa:	000ab597          	auipc	a1,0xab
ffffffffc02017ae:	0be58593          	addi	a1,a1,190 # ffffffffc02ac868 <free_area>
ffffffffc02017b2:	0105a803          	lw	a6,16(a1)
ffffffffc02017b6:	862a                	mv	a2,a0
ffffffffc02017b8:	02081793          	slli	a5,a6,0x20
ffffffffc02017bc:	9381                	srli	a5,a5,0x20
ffffffffc02017be:	00a7ee63          	bltu	a5,a0,ffffffffc02017da <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017c2:	87ae                	mv	a5,a1
ffffffffc02017c4:	a801                	j	ffffffffc02017d4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017ca:	02071693          	slli	a3,a4,0x20
ffffffffc02017ce:	9281                	srli	a3,a3,0x20
ffffffffc02017d0:	00c6f763          	bgeu	a3,a2,ffffffffc02017de <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017d4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017d6:	feb798e3          	bne	a5,a1,ffffffffc02017c6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02017da:	4501                	li	a0,0
}
ffffffffc02017dc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02017de:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02017e2:	dd6d                	beqz	a0,ffffffffc02017dc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02017e4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017e8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02017ec:	00060e1b          	sext.w	t3,a2
ffffffffc02017f0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02017f4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02017f8:	02d67863          	bgeu	a2,a3,ffffffffc0201828 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02017fc:	061a                	slli	a2,a2,0x6
ffffffffc02017fe:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201800:	41c7073b          	subw	a4,a4,t3
ffffffffc0201804:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201806:	00860693          	addi	a3,a2,8
ffffffffc020180a:	4709                	li	a4,2
ffffffffc020180c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201810:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201814:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201818:	0105a803          	lw	a6,16(a1)
ffffffffc020181c:	e314                	sd	a3,0(a4)
ffffffffc020181e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201822:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201824:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201828:	41c8083b          	subw	a6,a6,t3
ffffffffc020182c:	000ab717          	auipc	a4,0xab
ffffffffc0201830:	05072623          	sw	a6,76(a4) # ffffffffc02ac878 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201834:	5775                	li	a4,-3
ffffffffc0201836:	17c1                	addi	a5,a5,-16
ffffffffc0201838:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020183c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020183e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201840:	00006697          	auipc	a3,0x6
ffffffffc0201844:	86068693          	addi	a3,a3,-1952 # ffffffffc02070a0 <commands+0xbf0>
ffffffffc0201848:	00005617          	auipc	a2,0x5
ffffffffc020184c:	12860613          	addi	a2,a2,296 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201850:	06200593          	li	a1,98
ffffffffc0201854:	00005517          	auipc	a0,0x5
ffffffffc0201858:	4e450513          	addi	a0,a0,1252 # ffffffffc0206d38 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc020185c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020185e:	c23fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201862 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201862:	1141                	addi	sp,sp,-16
ffffffffc0201864:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201866:	c1ed                	beqz	a1,ffffffffc0201948 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201868:	00659693          	slli	a3,a1,0x6
ffffffffc020186c:	96aa                	add	a3,a3,a0
ffffffffc020186e:	02d50463          	beq	a0,a3,ffffffffc0201896 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201872:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201874:	87aa                	mv	a5,a0
ffffffffc0201876:	8b05                	andi	a4,a4,1
ffffffffc0201878:	e709                	bnez	a4,ffffffffc0201882 <default_init_memmap+0x20>
ffffffffc020187a:	a07d                	j	ffffffffc0201928 <default_init_memmap+0xc6>
ffffffffc020187c:	6798                	ld	a4,8(a5)
ffffffffc020187e:	8b05                	andi	a4,a4,1
ffffffffc0201880:	c745                	beqz	a4,ffffffffc0201928 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0201882:	0007a823          	sw	zero,16(a5)
ffffffffc0201886:	0007b423          	sd	zero,8(a5)
ffffffffc020188a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020188e:	04078793          	addi	a5,a5,64
ffffffffc0201892:	fed795e3          	bne	a5,a3,ffffffffc020187c <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0201896:	2581                	sext.w	a1,a1
ffffffffc0201898:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020189a:	4789                	li	a5,2
ffffffffc020189c:	00850713          	addi	a4,a0,8
ffffffffc02018a0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018a4:	000ab697          	auipc	a3,0xab
ffffffffc02018a8:	fc468693          	addi	a3,a3,-60 # ffffffffc02ac868 <free_area>
ffffffffc02018ac:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ae:	669c                	ld	a5,8(a3)
ffffffffc02018b0:	9db9                	addw	a1,a1,a4
ffffffffc02018b2:	000ab717          	auipc	a4,0xab
ffffffffc02018b6:	fcb72323          	sw	a1,-58(a4) # ffffffffc02ac878 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018ba:	04d78a63          	beq	a5,a3,ffffffffc020190e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018be:	fe878713          	addi	a4,a5,-24
ffffffffc02018c2:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018c4:	4801                	li	a6,0
ffffffffc02018c6:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018ca:	00e56a63          	bltu	a0,a4,ffffffffc02018de <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018ce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018d0:	02d70563          	beq	a4,a3,ffffffffc02018fa <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018d4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018d6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018da:	fee57ae3          	bgeu	a0,a4,ffffffffc02018ce <default_init_memmap+0x6c>
ffffffffc02018de:	00080663          	beqz	a6,ffffffffc02018ea <default_init_memmap+0x88>
ffffffffc02018e2:	000ab717          	auipc	a4,0xab
ffffffffc02018e6:	f8b73323          	sd	a1,-122(a4) # ffffffffc02ac868 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018ea:	6398                	ld	a4,0(a5)
}
ffffffffc02018ec:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02018ee:	e390                	sd	a2,0(a5)
ffffffffc02018f0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02018f2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018f4:	ed18                	sd	a4,24(a0)
ffffffffc02018f6:	0141                	addi	sp,sp,16
ffffffffc02018f8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018fa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018fc:	f114                	sd	a3,32(a0)
ffffffffc02018fe:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201900:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201902:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201904:	00d70e63          	beq	a4,a3,ffffffffc0201920 <default_init_memmap+0xbe>
ffffffffc0201908:	4805                	li	a6,1
ffffffffc020190a:	87ba                	mv	a5,a4
ffffffffc020190c:	b7e9                	j	ffffffffc02018d6 <default_init_memmap+0x74>
}
ffffffffc020190e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201910:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201914:	e398                	sd	a4,0(a5)
ffffffffc0201916:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201918:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020191a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020191c:	0141                	addi	sp,sp,16
ffffffffc020191e:	8082                	ret
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	e290                	sd	a2,0(a3)
ffffffffc0201924:	0141                	addi	sp,sp,16
ffffffffc0201926:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201928:	00005697          	auipc	a3,0x5
ffffffffc020192c:	78068693          	addi	a3,a3,1920 # ffffffffc02070a8 <commands+0xbf8>
ffffffffc0201930:	00005617          	auipc	a2,0x5
ffffffffc0201934:	04060613          	addi	a2,a2,64 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201938:	04900593          	li	a1,73
ffffffffc020193c:	00005517          	auipc	a0,0x5
ffffffffc0201940:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201944:	b3dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc0201948:	00005697          	auipc	a3,0x5
ffffffffc020194c:	75868693          	addi	a3,a3,1880 # ffffffffc02070a0 <commands+0xbf0>
ffffffffc0201950:	00005617          	auipc	a2,0x5
ffffffffc0201954:	02060613          	addi	a2,a2,32 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201958:	04600593          	li	a1,70
ffffffffc020195c:	00005517          	auipc	a0,0x5
ffffffffc0201960:	3dc50513          	addi	a0,a0,988 # ffffffffc0206d38 <commands+0x888>
ffffffffc0201964:	b1dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201968 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201968:	c125                	beqz	a0,ffffffffc02019c8 <slob_free+0x60>
		return;

	if (size)
ffffffffc020196a:	e1a5                	bnez	a1,ffffffffc02019ca <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020196c:	100027f3          	csrr	a5,sstatus
ffffffffc0201970:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201972:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201974:	e3bd                	bnez	a5,ffffffffc02019da <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201976:	000a0797          	auipc	a5,0xa0
ffffffffc020197a:	a8278793          	addi	a5,a5,-1406 # ffffffffc02a13f8 <slobfree>
ffffffffc020197e:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201980:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201982:	00a7fa63          	bgeu	a5,a0,ffffffffc0201996 <slob_free+0x2e>
ffffffffc0201986:	00e56c63          	bltu	a0,a4,ffffffffc020199e <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020198a:	00e7fa63          	bgeu	a5,a4,ffffffffc020199e <slob_free+0x36>
    return 0;
ffffffffc020198e:	87ba                	mv	a5,a4
ffffffffc0201990:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201992:	fea7eae3          	bltu	a5,a0,ffffffffc0201986 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201996:	fee7ece3          	bltu	a5,a4,ffffffffc020198e <slob_free+0x26>
ffffffffc020199a:	fee57ae3          	bgeu	a0,a4,ffffffffc020198e <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020199e:	4110                	lw	a2,0(a0)
ffffffffc02019a0:	00461693          	slli	a3,a2,0x4
ffffffffc02019a4:	96aa                	add	a3,a3,a0
ffffffffc02019a6:	08d70b63          	beq	a4,a3,ffffffffc0201a3c <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019aa:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019ac:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019ae:	00469713          	slli	a4,a3,0x4
ffffffffc02019b2:	973e                	add	a4,a4,a5
ffffffffc02019b4:	08e50f63          	beq	a0,a4,ffffffffc0201a52 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019b8:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019ba:	000a0717          	auipc	a4,0xa0
ffffffffc02019be:	a2f73f23          	sd	a5,-1474(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc02019c2:	c199                	beqz	a1,ffffffffc02019c8 <slob_free+0x60>
        intr_enable();
ffffffffc02019c4:	c65fe06f          	j	ffffffffc0200628 <intr_enable>
ffffffffc02019c8:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019ca:	05bd                	addi	a1,a1,15
ffffffffc02019cc:	8191                	srli	a1,a1,0x4
ffffffffc02019ce:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019d0:	100027f3          	csrr	a5,sstatus
ffffffffc02019d4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019d6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019d8:	dfd9                	beqz	a5,ffffffffc0201976 <slob_free+0xe>
{
ffffffffc02019da:	1101                	addi	sp,sp,-32
ffffffffc02019dc:	e42a                	sd	a0,8(sp)
ffffffffc02019de:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02019e0:	c4ffe0ef          	jal	ra,ffffffffc020062e <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019e4:	000a0797          	auipc	a5,0xa0
ffffffffc02019e8:	a1478793          	addi	a5,a5,-1516 # ffffffffc02a13f8 <slobfree>
ffffffffc02019ec:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02019ee:	6522                	ld	a0,8(sp)
ffffffffc02019f0:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019f2:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019f4:	00a7fa63          	bgeu	a5,a0,ffffffffc0201a08 <slob_free+0xa0>
ffffffffc02019f8:	00e56c63          	bltu	a0,a4,ffffffffc0201a10 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019fc:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a10 <slob_free+0xa8>
    return 0;
ffffffffc0201a00:	87ba                	mv	a5,a4
ffffffffc0201a02:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a04:	fea7eae3          	bltu	a5,a0,ffffffffc02019f8 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a08:	fee7ece3          	bltu	a5,a4,ffffffffc0201a00 <slob_free+0x98>
ffffffffc0201a0c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a00 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a10:	4110                	lw	a2,0(a0)
ffffffffc0201a12:	00461693          	slli	a3,a2,0x4
ffffffffc0201a16:	96aa                	add	a3,a3,a0
ffffffffc0201a18:	04d70763          	beq	a4,a3,ffffffffc0201a66 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a1c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a1e:	4394                	lw	a3,0(a5)
ffffffffc0201a20:	00469713          	slli	a4,a3,0x4
ffffffffc0201a24:	973e                	add	a4,a4,a5
ffffffffc0201a26:	04e50663          	beq	a0,a4,ffffffffc0201a72 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a2a:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a2c:	000a0717          	auipc	a4,0xa0
ffffffffc0201a30:	9cf73623          	sd	a5,-1588(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0201a34:	e58d                	bnez	a1,ffffffffc0201a5e <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a36:	60e2                	ld	ra,24(sp)
ffffffffc0201a38:	6105                	addi	sp,sp,32
ffffffffc0201a3a:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a3c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a3e:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a40:	9e35                	addw	a2,a2,a3
ffffffffc0201a42:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a44:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a46:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a48:	00469713          	slli	a4,a3,0x4
ffffffffc0201a4c:	973e                	add	a4,a4,a5
ffffffffc0201a4e:	f6e515e3          	bne	a0,a4,ffffffffc02019b8 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a52:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a54:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a56:	9eb9                	addw	a3,a3,a4
ffffffffc0201a58:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a5a:	e790                	sd	a2,8(a5)
ffffffffc0201a5c:	bfb9                	j	ffffffffc02019ba <slob_free+0x52>
}
ffffffffc0201a5e:	60e2                	ld	ra,24(sp)
ffffffffc0201a60:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a62:	bc7fe06f          	j	ffffffffc0200628 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a66:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a68:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a6a:	9e35                	addw	a2,a2,a3
ffffffffc0201a6c:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a6e:	e518                	sd	a4,8(a0)
ffffffffc0201a70:	b77d                	j	ffffffffc0201a1e <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a72:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a74:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a76:	9eb9                	addw	a3,a3,a4
ffffffffc0201a78:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a7a:	e790                	sd	a2,8(a5)
ffffffffc0201a7c:	bf45                	j	ffffffffc0201a2c <slob_free+0xc4>

ffffffffc0201a7e <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a7e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a80:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a82:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a86:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a88:	378000ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
  if(!page)
ffffffffc0201a8c:	cd1d                	beqz	a0,ffffffffc0201aca <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0201a8e:	000ab797          	auipc	a5,0xab
ffffffffc0201a92:	e0a78793          	addi	a5,a5,-502 # ffffffffc02ac898 <pages>
ffffffffc0201a96:	6394                	ld	a3,0(a5)
ffffffffc0201a98:	00007797          	auipc	a5,0x7
ffffffffc0201a9c:	f4878793          	addi	a5,a5,-184 # ffffffffc02089e0 <nbase>
ffffffffc0201aa0:	8d15                	sub	a0,a0,a3
ffffffffc0201aa2:	6394                	ld	a3,0(a5)
ffffffffc0201aa4:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0201aa6:	000ab797          	auipc	a5,0xab
ffffffffc0201aaa:	d8278793          	addi	a5,a5,-638 # ffffffffc02ac828 <npage>
    return page - pages + nbase;
ffffffffc0201aae:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201ab0:	6398                	ld	a4,0(a5)
ffffffffc0201ab2:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ab6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ab8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201aba:	00e7fb63          	bgeu	a5,a4,ffffffffc0201ad0 <__slob_get_free_pages.isra.0+0x52>
ffffffffc0201abe:	000ab797          	auipc	a5,0xab
ffffffffc0201ac2:	dca78793          	addi	a5,a5,-566 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0201ac6:	6394                	ld	a3,0(a5)
ffffffffc0201ac8:	9536                	add	a0,a0,a3
}
ffffffffc0201aca:	60a2                	ld	ra,8(sp)
ffffffffc0201acc:	0141                	addi	sp,sp,16
ffffffffc0201ace:	8082                	ret
ffffffffc0201ad0:	86aa                	mv	a3,a0
ffffffffc0201ad2:	00005617          	auipc	a2,0x5
ffffffffc0201ad6:	63660613          	addi	a2,a2,1590 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0201ada:	06900593          	li	a1,105
ffffffffc0201ade:	00005517          	auipc	a0,0x5
ffffffffc0201ae2:	65250513          	addi	a0,a0,1618 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0201ae6:	99bfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201aea <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201aea:	1101                	addi	sp,sp,-32
ffffffffc0201aec:	ec06                	sd	ra,24(sp)
ffffffffc0201aee:	e822                	sd	s0,16(sp)
ffffffffc0201af0:	e426                	sd	s1,8(sp)
ffffffffc0201af2:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201af4:	01050713          	addi	a4,a0,16
ffffffffc0201af8:	6785                	lui	a5,0x1
ffffffffc0201afa:	0cf77563          	bgeu	a4,a5,ffffffffc0201bc4 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201afe:	00f50493          	addi	s1,a0,15
ffffffffc0201b02:	8091                	srli	s1,s1,0x4
ffffffffc0201b04:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b06:	10002673          	csrr	a2,sstatus
ffffffffc0201b0a:	8a09                	andi	a2,a2,2
ffffffffc0201b0c:	e64d                	bnez	a2,ffffffffc0201bb6 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0201b0e:	000a0917          	auipc	s2,0xa0
ffffffffc0201b12:	8ea90913          	addi	s2,s2,-1814 # ffffffffc02a13f8 <slobfree>
ffffffffc0201b16:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b1a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b1c:	4398                	lw	a4,0(a5)
ffffffffc0201b1e:	0a975063          	bge	a4,s1,ffffffffc0201bbe <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0201b22:	00d78b63          	beq	a5,a3,ffffffffc0201b38 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b26:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b28:	4018                	lw	a4,0(s0)
ffffffffc0201b2a:	02975a63          	bge	a4,s1,ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0201b2e:	00093683          	ld	a3,0(s2)
ffffffffc0201b32:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0201b34:	fed799e3          	bne	a5,a3,ffffffffc0201b26 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0201b38:	e225                	bnez	a2,ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b3a:	4501                	li	a0,0
ffffffffc0201b3c:	f43ff0ef          	jal	ra,ffffffffc0201a7e <__slob_get_free_pages.isra.0>
ffffffffc0201b40:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b42:	cd15                	beqz	a0,ffffffffc0201b7e <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b44:	6585                	lui	a1,0x1
ffffffffc0201b46:	e23ff0ef          	jal	ra,ffffffffc0201968 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b4a:	10002673          	csrr	a2,sstatus
ffffffffc0201b4e:	8a09                	andi	a2,a2,2
ffffffffc0201b50:	ee15                	bnez	a2,ffffffffc0201b8c <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0201b52:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b56:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b58:	4018                	lw	a4,0(s0)
ffffffffc0201b5a:	fc974ae3          	blt	a4,s1,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b5e:	04e48963          	beq	s1,a4,ffffffffc0201bb0 <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0201b62:	00449693          	slli	a3,s1,0x4
ffffffffc0201b66:	96a2                	add	a3,a3,s0
ffffffffc0201b68:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b6a:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b6c:	9f05                	subw	a4,a4,s1
ffffffffc0201b6e:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b70:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b72:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201b74:	000a0717          	auipc	a4,0xa0
ffffffffc0201b78:	88f73223          	sd	a5,-1916(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0201b7c:	e20d                	bnez	a2,ffffffffc0201b9e <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0201b7e:	8522                	mv	a0,s0
ffffffffc0201b80:	60e2                	ld	ra,24(sp)
ffffffffc0201b82:	6442                	ld	s0,16(sp)
ffffffffc0201b84:	64a2                	ld	s1,8(sp)
ffffffffc0201b86:	6902                	ld	s2,0(sp)
ffffffffc0201b88:	6105                	addi	sp,sp,32
ffffffffc0201b8a:	8082                	ret
        intr_disable();
ffffffffc0201b8c:	aa3fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
ffffffffc0201b90:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201b92:	00093783          	ld	a5,0(s2)
ffffffffc0201b96:	b7c1                	j	ffffffffc0201b56 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0201b98:	a91fe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0201b9c:	bf79                	j	ffffffffc0201b3a <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0201b9e:	a8bfe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
}
ffffffffc0201ba2:	8522                	mv	a0,s0
ffffffffc0201ba4:	60e2                	ld	ra,24(sp)
ffffffffc0201ba6:	6442                	ld	s0,16(sp)
ffffffffc0201ba8:	64a2                	ld	s1,8(sp)
ffffffffc0201baa:	6902                	ld	s2,0(sp)
ffffffffc0201bac:	6105                	addi	sp,sp,32
ffffffffc0201bae:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bb0:	6418                	ld	a4,8(s0)
ffffffffc0201bb2:	e798                	sd	a4,8(a5)
ffffffffc0201bb4:	b7c1                	j	ffffffffc0201b74 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0201bb6:	a79fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
ffffffffc0201bba:	4605                	li	a2,1
ffffffffc0201bbc:	bf89                	j	ffffffffc0201b0e <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bbe:	843e                	mv	s0,a5
ffffffffc0201bc0:	87b6                	mv	a5,a3
ffffffffc0201bc2:	bf71                	j	ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201bc4:	00005697          	auipc	a3,0x5
ffffffffc0201bc8:	5e468693          	addi	a3,a3,1508 # ffffffffc02071a8 <default_pmm_manager+0xf0>
ffffffffc0201bcc:	00005617          	auipc	a2,0x5
ffffffffc0201bd0:	da460613          	addi	a2,a2,-604 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0201bd4:	06400593          	li	a1,100
ffffffffc0201bd8:	00005517          	auipc	a0,0x5
ffffffffc0201bdc:	5f050513          	addi	a0,a0,1520 # ffffffffc02071c8 <default_pmm_manager+0x110>
ffffffffc0201be0:	8a1fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201be4 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201be4:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201be6:	00005517          	auipc	a0,0x5
ffffffffc0201bea:	5fa50513          	addi	a0,a0,1530 # ffffffffc02071e0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201bee:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201bf0:	d9efe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201bf4:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bf6:	00005517          	auipc	a0,0x5
ffffffffc0201bfa:	59250513          	addi	a0,a0,1426 # ffffffffc0207188 <default_pmm_manager+0xd0>
}
ffffffffc0201bfe:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c00:	d8efe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c04 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c04:	4501                	li	a0,0
ffffffffc0201c06:	8082                	ret

ffffffffc0201c08 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c08:	1101                	addi	sp,sp,-32
ffffffffc0201c0a:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c0c:	6905                	lui	s2,0x1
{
ffffffffc0201c0e:	e822                	sd	s0,16(sp)
ffffffffc0201c10:	ec06                	sd	ra,24(sp)
ffffffffc0201c12:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c14:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc0201c18:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c1a:	04a7fc63          	bgeu	a5,a0,ffffffffc0201c72 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c1e:	4561                	li	a0,24
ffffffffc0201c20:	ecbff0ef          	jal	ra,ffffffffc0201aea <slob_alloc.isra.1.constprop.3>
ffffffffc0201c24:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c26:	cd21                	beqz	a0,ffffffffc0201c7e <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c28:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c2c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c2e:	00f95763          	bge	s2,a5,ffffffffc0201c3c <kmalloc+0x34>
ffffffffc0201c32:	6705                	lui	a4,0x1
ffffffffc0201c34:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c36:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c38:	fef74ee3          	blt	a4,a5,ffffffffc0201c34 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c3c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c3e:	e41ff0ef          	jal	ra,ffffffffc0201a7e <__slob_get_free_pages.isra.0>
ffffffffc0201c42:	e488                	sd	a0,8(s1)
ffffffffc0201c44:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c46:	c935                	beqz	a0,ffffffffc0201cba <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c48:	100027f3          	csrr	a5,sstatus
ffffffffc0201c4c:	8b89                	andi	a5,a5,2
ffffffffc0201c4e:	e3a1                	bnez	a5,ffffffffc0201c8e <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c50:	000ab797          	auipc	a5,0xab
ffffffffc0201c54:	bc878793          	addi	a5,a5,-1080 # ffffffffc02ac818 <bigblocks>
ffffffffc0201c58:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c5a:	000ab717          	auipc	a4,0xab
ffffffffc0201c5e:	ba973f23          	sd	s1,-1090(a4) # ffffffffc02ac818 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c62:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201c64:	8522                	mv	a0,s0
ffffffffc0201c66:	60e2                	ld	ra,24(sp)
ffffffffc0201c68:	6442                	ld	s0,16(sp)
ffffffffc0201c6a:	64a2                	ld	s1,8(sp)
ffffffffc0201c6c:	6902                	ld	s2,0(sp)
ffffffffc0201c6e:	6105                	addi	sp,sp,32
ffffffffc0201c70:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c72:	0541                	addi	a0,a0,16
ffffffffc0201c74:	e77ff0ef          	jal	ra,ffffffffc0201aea <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c78:	01050413          	addi	s0,a0,16
ffffffffc0201c7c:	f565                	bnez	a0,ffffffffc0201c64 <kmalloc+0x5c>
ffffffffc0201c7e:	4401                	li	s0,0
}
ffffffffc0201c80:	8522                	mv	a0,s0
ffffffffc0201c82:	60e2                	ld	ra,24(sp)
ffffffffc0201c84:	6442                	ld	s0,16(sp)
ffffffffc0201c86:	64a2                	ld	s1,8(sp)
ffffffffc0201c88:	6902                	ld	s2,0(sp)
ffffffffc0201c8a:	6105                	addi	sp,sp,32
ffffffffc0201c8c:	8082                	ret
        intr_disable();
ffffffffc0201c8e:	9a1fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
		bb->next = bigblocks;
ffffffffc0201c92:	000ab797          	auipc	a5,0xab
ffffffffc0201c96:	b8678793          	addi	a5,a5,-1146 # ffffffffc02ac818 <bigblocks>
ffffffffc0201c9a:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c9c:	000ab717          	auipc	a4,0xab
ffffffffc0201ca0:	b6973e23          	sd	s1,-1156(a4) # ffffffffc02ac818 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ca4:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201ca6:	983fe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0201caa:	6480                	ld	s0,8(s1)
}
ffffffffc0201cac:	60e2                	ld	ra,24(sp)
ffffffffc0201cae:	64a2                	ld	s1,8(sp)
ffffffffc0201cb0:	8522                	mv	a0,s0
ffffffffc0201cb2:	6442                	ld	s0,16(sp)
ffffffffc0201cb4:	6902                	ld	s2,0(sp)
ffffffffc0201cb6:	6105                	addi	sp,sp,32
ffffffffc0201cb8:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cba:	45e1                	li	a1,24
ffffffffc0201cbc:	8526                	mv	a0,s1
ffffffffc0201cbe:	cabff0ef          	jal	ra,ffffffffc0201968 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201cc2:	b74d                	j	ffffffffc0201c64 <kmalloc+0x5c>

ffffffffc0201cc4 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201cc4:	c165                	beqz	a0,ffffffffc0201da4 <kfree+0xe0>
{
ffffffffc0201cc6:	1101                	addi	sp,sp,-32
ffffffffc0201cc8:	e426                	sd	s1,8(sp)
ffffffffc0201cca:	ec06                	sd	ra,24(sp)
ffffffffc0201ccc:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201cce:	03451793          	slli	a5,a0,0x34
ffffffffc0201cd2:	84aa                	mv	s1,a0
ffffffffc0201cd4:	eb8d                	bnez	a5,ffffffffc0201d06 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cd6:	100027f3          	csrr	a5,sstatus
ffffffffc0201cda:	8b89                	andi	a5,a5,2
ffffffffc0201cdc:	ebd9                	bnez	a5,ffffffffc0201d72 <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201cde:	000ab797          	auipc	a5,0xab
ffffffffc0201ce2:	b3a78793          	addi	a5,a5,-1222 # ffffffffc02ac818 <bigblocks>
ffffffffc0201ce6:	6394                	ld	a3,0(a5)
ffffffffc0201ce8:	ce99                	beqz	a3,ffffffffc0201d06 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201cea:	669c                	ld	a5,8(a3)
ffffffffc0201cec:	6a80                	ld	s0,16(a3)
ffffffffc0201cee:	0af50c63          	beq	a0,a5,ffffffffc0201da6 <kfree+0xe2>
    return 0;
ffffffffc0201cf2:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201cf4:	c801                	beqz	s0,ffffffffc0201d04 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201cf6:	6418                	ld	a4,8(s0)
ffffffffc0201cf8:	681c                	ld	a5,16(s0)
ffffffffc0201cfa:	00970e63          	beq	a4,s1,ffffffffc0201d16 <kfree+0x52>
ffffffffc0201cfe:	86a2                	mv	a3,s0
ffffffffc0201d00:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d02:	f875                	bnez	s0,ffffffffc0201cf6 <kfree+0x32>
    if (flag) {
ffffffffc0201d04:	e649                	bnez	a2,ffffffffc0201d8e <kfree+0xca>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d06:	6442                	ld	s0,16(sp)
ffffffffc0201d08:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d0a:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d0e:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d10:	4581                	li	a1,0
}
ffffffffc0201d12:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d14:	b991                	j	ffffffffc0201968 <slob_free>
				*last = bb->next;
ffffffffc0201d16:	ea9c                	sd	a5,16(a3)
ffffffffc0201d18:	e259                	bnez	a2,ffffffffc0201d9e <kfree+0xda>
    return pa2page(PADDR(kva));
ffffffffc0201d1a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d1e:	4018                	lw	a4,0(s0)
ffffffffc0201d20:	08f4e963          	bltu	s1,a5,ffffffffc0201db2 <kfree+0xee>
ffffffffc0201d24:	000ab797          	auipc	a5,0xab
ffffffffc0201d28:	b6478793          	addi	a5,a5,-1180 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0201d2c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d2e:	000ab797          	auipc	a5,0xab
ffffffffc0201d32:	afa78793          	addi	a5,a5,-1286 # ffffffffc02ac828 <npage>
ffffffffc0201d36:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d38:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d3a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d3c:	08f4f863          	bgeu	s1,a5,ffffffffc0201dcc <kfree+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d40:	00007797          	auipc	a5,0x7
ffffffffc0201d44:	ca078793          	addi	a5,a5,-864 # ffffffffc02089e0 <nbase>
ffffffffc0201d48:	639c                	ld	a5,0(a5)
ffffffffc0201d4a:	000ab697          	auipc	a3,0xab
ffffffffc0201d4e:	b4e68693          	addi	a3,a3,-1202 # ffffffffc02ac898 <pages>
ffffffffc0201d52:	6288                	ld	a0,0(a3)
ffffffffc0201d54:	8c9d                	sub	s1,s1,a5
ffffffffc0201d56:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d58:	4585                	li	a1,1
ffffffffc0201d5a:	9526                	add	a0,a0,s1
ffffffffc0201d5c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d60:	128000ef          	jal	ra,ffffffffc0201e88 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d64:	8522                	mv	a0,s0
}
ffffffffc0201d66:	6442                	ld	s0,16(sp)
ffffffffc0201d68:	60e2                	ld	ra,24(sp)
ffffffffc0201d6a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d6c:	45e1                	li	a1,24
}
ffffffffc0201d6e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d70:	bee5                	j	ffffffffc0201968 <slob_free>
        intr_disable();
ffffffffc0201d72:	8bdfe0ef          	jal	ra,ffffffffc020062e <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d76:	000ab797          	auipc	a5,0xab
ffffffffc0201d7a:	aa278793          	addi	a5,a5,-1374 # ffffffffc02ac818 <bigblocks>
ffffffffc0201d7e:	6394                	ld	a3,0(a5)
ffffffffc0201d80:	c699                	beqz	a3,ffffffffc0201d8e <kfree+0xca>
			if (bb->pages == block) {
ffffffffc0201d82:	669c                	ld	a5,8(a3)
ffffffffc0201d84:	6a80                	ld	s0,16(a3)
ffffffffc0201d86:	00f48763          	beq	s1,a5,ffffffffc0201d94 <kfree+0xd0>
        return 1;
ffffffffc0201d8a:	4605                	li	a2,1
ffffffffc0201d8c:	b7a5                	j	ffffffffc0201cf4 <kfree+0x30>
        intr_enable();
ffffffffc0201d8e:	89bfe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0201d92:	bf95                	j	ffffffffc0201d06 <kfree+0x42>
				*last = bb->next;
ffffffffc0201d94:	000ab797          	auipc	a5,0xab
ffffffffc0201d98:	a887b223          	sd	s0,-1404(a5) # ffffffffc02ac818 <bigblocks>
ffffffffc0201d9c:	8436                	mv	s0,a3
ffffffffc0201d9e:	88bfe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0201da2:	bfa5                	j	ffffffffc0201d1a <kfree+0x56>
ffffffffc0201da4:	8082                	ret
ffffffffc0201da6:	000ab797          	auipc	a5,0xab
ffffffffc0201daa:	a687b923          	sd	s0,-1422(a5) # ffffffffc02ac818 <bigblocks>
ffffffffc0201dae:	8436                	mv	s0,a3
ffffffffc0201db0:	b7ad                	j	ffffffffc0201d1a <kfree+0x56>
    return pa2page(PADDR(kva));
ffffffffc0201db2:	86a6                	mv	a3,s1
ffffffffc0201db4:	00005617          	auipc	a2,0x5
ffffffffc0201db8:	38c60613          	addi	a2,a2,908 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc0201dbc:	06e00593          	li	a1,110
ffffffffc0201dc0:	00005517          	auipc	a0,0x5
ffffffffc0201dc4:	37050513          	addi	a0,a0,880 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0201dc8:	eb8fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201dcc:	00005617          	auipc	a2,0x5
ffffffffc0201dd0:	39c60613          	addi	a2,a2,924 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0201dd4:	06200593          	li	a1,98
ffffffffc0201dd8:	00005517          	auipc	a0,0x5
ffffffffc0201ddc:	35850513          	addi	a0,a0,856 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0201de0:	ea0fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201de4 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201de4:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201de6:	00005617          	auipc	a2,0x5
ffffffffc0201dea:	38260613          	addi	a2,a2,898 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0201dee:	06200593          	li	a1,98
ffffffffc0201df2:	00005517          	auipc	a0,0x5
ffffffffc0201df6:	33e50513          	addi	a0,a0,830 # ffffffffc0207130 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201dfa:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201dfc:	e84fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e00 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e00:	715d                	addi	sp,sp,-80
ffffffffc0201e02:	e0a2                	sd	s0,64(sp)
ffffffffc0201e04:	fc26                	sd	s1,56(sp)
ffffffffc0201e06:	f84a                	sd	s2,48(sp)
ffffffffc0201e08:	f44e                	sd	s3,40(sp)
ffffffffc0201e0a:	f052                	sd	s4,32(sp)
ffffffffc0201e0c:	ec56                	sd	s5,24(sp)
ffffffffc0201e0e:	e486                	sd	ra,72(sp)
ffffffffc0201e10:	842a                	mv	s0,a0
ffffffffc0201e12:	000ab497          	auipc	s1,0xab
ffffffffc0201e16:	a6e48493          	addi	s1,s1,-1426 # ffffffffc02ac880 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e1a:	4985                	li	s3,1
ffffffffc0201e1c:	000aba17          	auipc	s4,0xab
ffffffffc0201e20:	a1ca0a13          	addi	s4,s4,-1508 # ffffffffc02ac838 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e24:	0005091b          	sext.w	s2,a0
ffffffffc0201e28:	000aba97          	auipc	s5,0xab
ffffffffc0201e2c:	b50a8a93          	addi	s5,s5,-1200 # ffffffffc02ac978 <check_mm_struct>
ffffffffc0201e30:	a00d                	j	ffffffffc0201e52 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e32:	609c                	ld	a5,0(s1)
ffffffffc0201e34:	6f9c                	ld	a5,24(a5)
ffffffffc0201e36:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e38:	4601                	li	a2,0
ffffffffc0201e3a:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e3c:	ed0d                	bnez	a0,ffffffffc0201e76 <alloc_pages+0x76>
ffffffffc0201e3e:	0289ec63          	bltu	s3,s0,ffffffffc0201e76 <alloc_pages+0x76>
ffffffffc0201e42:	000a2783          	lw	a5,0(s4)
ffffffffc0201e46:	2781                	sext.w	a5,a5
ffffffffc0201e48:	c79d                	beqz	a5,ffffffffc0201e76 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e4a:	000ab503          	ld	a0,0(s5)
ffffffffc0201e4e:	47f010ef          	jal	ra,ffffffffc0203acc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e52:	100027f3          	csrr	a5,sstatus
ffffffffc0201e56:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e58:	8522                	mv	a0,s0
ffffffffc0201e5a:	dfe1                	beqz	a5,ffffffffc0201e32 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e5c:	fd2fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
ffffffffc0201e60:	609c                	ld	a5,0(s1)
ffffffffc0201e62:	8522                	mv	a0,s0
ffffffffc0201e64:	6f9c                	ld	a5,24(a5)
ffffffffc0201e66:	9782                	jalr	a5
ffffffffc0201e68:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e6a:	fbefe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0201e6e:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e70:	4601                	li	a2,0
ffffffffc0201e72:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e74:	d569                	beqz	a0,ffffffffc0201e3e <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201e76:	60a6                	ld	ra,72(sp)
ffffffffc0201e78:	6406                	ld	s0,64(sp)
ffffffffc0201e7a:	74e2                	ld	s1,56(sp)
ffffffffc0201e7c:	7942                	ld	s2,48(sp)
ffffffffc0201e7e:	79a2                	ld	s3,40(sp)
ffffffffc0201e80:	7a02                	ld	s4,32(sp)
ffffffffc0201e82:	6ae2                	ld	s5,24(sp)
ffffffffc0201e84:	6161                	addi	sp,sp,80
ffffffffc0201e86:	8082                	ret

ffffffffc0201e88 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e88:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8c:	8b89                	andi	a5,a5,2
ffffffffc0201e8e:	eb89                	bnez	a5,ffffffffc0201ea0 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201e90:	000ab797          	auipc	a5,0xab
ffffffffc0201e94:	9f078793          	addi	a5,a5,-1552 # ffffffffc02ac880 <pmm_manager>
ffffffffc0201e98:	639c                	ld	a5,0(a5)
ffffffffc0201e9a:	0207b303          	ld	t1,32(a5)
ffffffffc0201e9e:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ea0:	1101                	addi	sp,sp,-32
ffffffffc0201ea2:	ec06                	sd	ra,24(sp)
ffffffffc0201ea4:	e822                	sd	s0,16(sp)
ffffffffc0201ea6:	e426                	sd	s1,8(sp)
ffffffffc0201ea8:	842a                	mv	s0,a0
ffffffffc0201eaa:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201eac:	f82fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201eb0:	000ab797          	auipc	a5,0xab
ffffffffc0201eb4:	9d078793          	addi	a5,a5,-1584 # ffffffffc02ac880 <pmm_manager>
ffffffffc0201eb8:	639c                	ld	a5,0(a5)
ffffffffc0201eba:	85a6                	mv	a1,s1
ffffffffc0201ebc:	8522                	mv	a0,s0
ffffffffc0201ebe:	739c                	ld	a5,32(a5)
ffffffffc0201ec0:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ec2:	6442                	ld	s0,16(sp)
ffffffffc0201ec4:	60e2                	ld	ra,24(sp)
ffffffffc0201ec6:	64a2                	ld	s1,8(sp)
ffffffffc0201ec8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201eca:	f5efe06f          	j	ffffffffc0200628 <intr_enable>

ffffffffc0201ece <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ece:	100027f3          	csrr	a5,sstatus
ffffffffc0201ed2:	8b89                	andi	a5,a5,2
ffffffffc0201ed4:	eb89                	bnez	a5,ffffffffc0201ee6 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ed6:	000ab797          	auipc	a5,0xab
ffffffffc0201eda:	9aa78793          	addi	a5,a5,-1622 # ffffffffc02ac880 <pmm_manager>
ffffffffc0201ede:	639c                	ld	a5,0(a5)
ffffffffc0201ee0:	0287b303          	ld	t1,40(a5)
ffffffffc0201ee4:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201ee6:	1141                	addi	sp,sp,-16
ffffffffc0201ee8:	e406                	sd	ra,8(sp)
ffffffffc0201eea:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201eec:	f42fe0ef          	jal	ra,ffffffffc020062e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ef0:	000ab797          	auipc	a5,0xab
ffffffffc0201ef4:	99078793          	addi	a5,a5,-1648 # ffffffffc02ac880 <pmm_manager>
ffffffffc0201ef8:	639c                	ld	a5,0(a5)
ffffffffc0201efa:	779c                	ld	a5,40(a5)
ffffffffc0201efc:	9782                	jalr	a5
ffffffffc0201efe:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f00:	f28fe0ef          	jal	ra,ffffffffc0200628 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f04:	8522                	mv	a0,s0
ffffffffc0201f06:	60a2                	ld	ra,8(sp)
ffffffffc0201f08:	6402                	ld	s0,0(sp)
ffffffffc0201f0a:	0141                	addi	sp,sp,16
ffffffffc0201f0c:	8082                	ret

ffffffffc0201f0e <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f0e:	7139                	addi	sp,sp,-64
ffffffffc0201f10:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f12:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f16:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f1a:	048e                	slli	s1,s1,0x3
ffffffffc0201f1c:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f1e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f20:	f04a                	sd	s2,32(sp)
ffffffffc0201f22:	ec4e                	sd	s3,24(sp)
ffffffffc0201f24:	e852                	sd	s4,16(sp)
ffffffffc0201f26:	fc06                	sd	ra,56(sp)
ffffffffc0201f28:	f822                	sd	s0,48(sp)
ffffffffc0201f2a:	e456                	sd	s5,8(sp)
ffffffffc0201f2c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f2e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f32:	892e                	mv	s2,a1
ffffffffc0201f34:	8a32                	mv	s4,a2
ffffffffc0201f36:	000ab997          	auipc	s3,0xab
ffffffffc0201f3a:	8f298993          	addi	s3,s3,-1806 # ffffffffc02ac828 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f3e:	e7bd                	bnez	a5,ffffffffc0201fac <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f40:	12060c63          	beqz	a2,ffffffffc0202078 <get_pte+0x16a>
ffffffffc0201f44:	4505                	li	a0,1
ffffffffc0201f46:	ebbff0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0201f4a:	842a                	mv	s0,a0
ffffffffc0201f4c:	12050663          	beqz	a0,ffffffffc0202078 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f50:	000abb17          	auipc	s6,0xab
ffffffffc0201f54:	948b0b13          	addi	s6,s6,-1720 # ffffffffc02ac898 <pages>
ffffffffc0201f58:	000b3503          	ld	a0,0(s6)
ffffffffc0201f5c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f60:	000ab997          	auipc	s3,0xab
ffffffffc0201f64:	8c898993          	addi	s3,s3,-1848 # ffffffffc02ac828 <npage>
ffffffffc0201f68:	40a40533          	sub	a0,s0,a0
ffffffffc0201f6c:	8519                	srai	a0,a0,0x6
ffffffffc0201f6e:	9556                	add	a0,a0,s5
ffffffffc0201f70:	0009b703          	ld	a4,0(s3)
ffffffffc0201f74:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f78:	4685                	li	a3,1
ffffffffc0201f7a:	c014                	sw	a3,0(s0)
ffffffffc0201f7c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f7e:	0532                	slli	a0,a0,0xc
ffffffffc0201f80:	14e7f363          	bgeu	a5,a4,ffffffffc02020c6 <get_pte+0x1b8>
ffffffffc0201f84:	000ab797          	auipc	a5,0xab
ffffffffc0201f88:	90478793          	addi	a5,a5,-1788 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0201f8c:	639c                	ld	a5,0(a5)
ffffffffc0201f8e:	6605                	lui	a2,0x1
ffffffffc0201f90:	4581                	li	a1,0
ffffffffc0201f92:	953e                	add	a0,a0,a5
ffffffffc0201f94:	3be040ef          	jal	ra,ffffffffc0206352 <memset>
    return page - pages + nbase;
ffffffffc0201f98:	000b3683          	ld	a3,0(s6)
ffffffffc0201f9c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fa0:	8699                	srai	a3,a3,0x6
ffffffffc0201fa2:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fa4:	06aa                	slli	a3,a3,0xa
ffffffffc0201fa6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201faa:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fac:	77fd                	lui	a5,0xfffff
ffffffffc0201fae:	068a                	slli	a3,a3,0x2
ffffffffc0201fb0:	0009b703          	ld	a4,0(s3)
ffffffffc0201fb4:	8efd                	and	a3,a3,a5
ffffffffc0201fb6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fba:	0ce7f163          	bgeu	a5,a4,ffffffffc020207c <get_pte+0x16e>
ffffffffc0201fbe:	000aba97          	auipc	s5,0xab
ffffffffc0201fc2:	8caa8a93          	addi	s5,s5,-1846 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0201fc6:	000ab403          	ld	s0,0(s5)
ffffffffc0201fca:	01595793          	srli	a5,s2,0x15
ffffffffc0201fce:	1ff7f793          	andi	a5,a5,511
ffffffffc0201fd2:	96a2                	add	a3,a3,s0
ffffffffc0201fd4:	00379413          	slli	s0,a5,0x3
ffffffffc0201fd8:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201fda:	6014                	ld	a3,0(s0)
ffffffffc0201fdc:	0016f793          	andi	a5,a3,1
ffffffffc0201fe0:	e3ad                	bnez	a5,ffffffffc0202042 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201fe2:	080a0b63          	beqz	s4,ffffffffc0202078 <get_pte+0x16a>
ffffffffc0201fe6:	4505                	li	a0,1
ffffffffc0201fe8:	e19ff0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0201fec:	84aa                	mv	s1,a0
ffffffffc0201fee:	c549                	beqz	a0,ffffffffc0202078 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ff0:	000abb17          	auipc	s6,0xab
ffffffffc0201ff4:	8a8b0b13          	addi	s6,s6,-1880 # ffffffffc02ac898 <pages>
ffffffffc0201ff8:	000b3503          	ld	a0,0(s6)
ffffffffc0201ffc:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202000:	0009b703          	ld	a4,0(s3)
ffffffffc0202004:	40a48533          	sub	a0,s1,a0
ffffffffc0202008:	8519                	srai	a0,a0,0x6
ffffffffc020200a:	9552                	add	a0,a0,s4
ffffffffc020200c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202010:	4685                	li	a3,1
ffffffffc0202012:	c094                	sw	a3,0(s1)
ffffffffc0202014:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202016:	0532                	slli	a0,a0,0xc
ffffffffc0202018:	08e7fa63          	bgeu	a5,a4,ffffffffc02020ac <get_pte+0x19e>
ffffffffc020201c:	000ab783          	ld	a5,0(s5)
ffffffffc0202020:	6605                	lui	a2,0x1
ffffffffc0202022:	4581                	li	a1,0
ffffffffc0202024:	953e                	add	a0,a0,a5
ffffffffc0202026:	32c040ef          	jal	ra,ffffffffc0206352 <memset>
    return page - pages + nbase;
ffffffffc020202a:	000b3683          	ld	a3,0(s6)
ffffffffc020202e:	40d486b3          	sub	a3,s1,a3
ffffffffc0202032:	8699                	srai	a3,a3,0x6
ffffffffc0202034:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202036:	06aa                	slli	a3,a3,0xa
ffffffffc0202038:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020203c:	e014                	sd	a3,0(s0)
ffffffffc020203e:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202042:	068a                	slli	a3,a3,0x2
ffffffffc0202044:	757d                	lui	a0,0xfffff
ffffffffc0202046:	8ee9                	and	a3,a3,a0
ffffffffc0202048:	00c6d793          	srli	a5,a3,0xc
ffffffffc020204c:	04e7f463          	bgeu	a5,a4,ffffffffc0202094 <get_pte+0x186>
ffffffffc0202050:	000ab503          	ld	a0,0(s5)
ffffffffc0202054:	00c95913          	srli	s2,s2,0xc
ffffffffc0202058:	1ff97913          	andi	s2,s2,511
ffffffffc020205c:	96aa                	add	a3,a3,a0
ffffffffc020205e:	00391513          	slli	a0,s2,0x3
ffffffffc0202062:	9536                	add	a0,a0,a3
}
ffffffffc0202064:	70e2                	ld	ra,56(sp)
ffffffffc0202066:	7442                	ld	s0,48(sp)
ffffffffc0202068:	74a2                	ld	s1,40(sp)
ffffffffc020206a:	7902                	ld	s2,32(sp)
ffffffffc020206c:	69e2                	ld	s3,24(sp)
ffffffffc020206e:	6a42                	ld	s4,16(sp)
ffffffffc0202070:	6aa2                	ld	s5,8(sp)
ffffffffc0202072:	6b02                	ld	s6,0(sp)
ffffffffc0202074:	6121                	addi	sp,sp,64
ffffffffc0202076:	8082                	ret
            return NULL;
ffffffffc0202078:	4501                	li	a0,0
ffffffffc020207a:	b7ed                	j	ffffffffc0202064 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020207c:	00005617          	auipc	a2,0x5
ffffffffc0202080:	08c60613          	addi	a2,a2,140 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202084:	0e300593          	li	a1,227
ffffffffc0202088:	00005517          	auipc	a0,0x5
ffffffffc020208c:	1a050513          	addi	a0,a0,416 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202090:	bf0fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202094:	00005617          	auipc	a2,0x5
ffffffffc0202098:	07460613          	addi	a2,a2,116 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc020209c:	0ee00593          	li	a1,238
ffffffffc02020a0:	00005517          	auipc	a0,0x5
ffffffffc02020a4:	18850513          	addi	a0,a0,392 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02020a8:	bd8fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ac:	86aa                	mv	a3,a0
ffffffffc02020ae:	00005617          	auipc	a2,0x5
ffffffffc02020b2:	05a60613          	addi	a2,a2,90 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc02020b6:	0eb00593          	li	a1,235
ffffffffc02020ba:	00005517          	auipc	a0,0x5
ffffffffc02020be:	16e50513          	addi	a0,a0,366 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02020c2:	bbefe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020c6:	86aa                	mv	a3,a0
ffffffffc02020c8:	00005617          	auipc	a2,0x5
ffffffffc02020cc:	04060613          	addi	a2,a2,64 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc02020d0:	0df00593          	li	a1,223
ffffffffc02020d4:	00005517          	auipc	a0,0x5
ffffffffc02020d8:	15450513          	addi	a0,a0,340 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02020dc:	ba4fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02020e0 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02020e0:	1141                	addi	sp,sp,-16
ffffffffc02020e2:	e022                	sd	s0,0(sp)
ffffffffc02020e4:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020e6:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02020e8:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020ea:	e25ff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
    if (ptep_store != NULL) {
ffffffffc02020ee:	c011                	beqz	s0,ffffffffc02020f2 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02020f0:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02020f2:	c511                	beqz	a0,ffffffffc02020fe <get_page+0x1e>
ffffffffc02020f4:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02020f6:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02020f8:	0017f713          	andi	a4,a5,1
ffffffffc02020fc:	e709                	bnez	a4,ffffffffc0202106 <get_page+0x26>
}
ffffffffc02020fe:	60a2                	ld	ra,8(sp)
ffffffffc0202100:	6402                	ld	s0,0(sp)
ffffffffc0202102:	0141                	addi	sp,sp,16
ffffffffc0202104:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202106:	000aa717          	auipc	a4,0xaa
ffffffffc020210a:	72270713          	addi	a4,a4,1826 # ffffffffc02ac828 <npage>
ffffffffc020210e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202110:	078a                	slli	a5,a5,0x2
ffffffffc0202112:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202114:	02e7f063          	bgeu	a5,a4,ffffffffc0202134 <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0202118:	000aa717          	auipc	a4,0xaa
ffffffffc020211c:	78070713          	addi	a4,a4,1920 # ffffffffc02ac898 <pages>
ffffffffc0202120:	6308                	ld	a0,0(a4)
ffffffffc0202122:	60a2                	ld	ra,8(sp)
ffffffffc0202124:	6402                	ld	s0,0(sp)
ffffffffc0202126:	fff80737          	lui	a4,0xfff80
ffffffffc020212a:	97ba                	add	a5,a5,a4
ffffffffc020212c:	079a                	slli	a5,a5,0x6
ffffffffc020212e:	953e                	add	a0,a0,a5
ffffffffc0202130:	0141                	addi	sp,sp,16
ffffffffc0202132:	8082                	ret
ffffffffc0202134:	cb1ff0ef          	jal	ra,ffffffffc0201de4 <pa2page.part.4>

ffffffffc0202138 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202138:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020213a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020213e:	ec86                	sd	ra,88(sp)
ffffffffc0202140:	e8a2                	sd	s0,80(sp)
ffffffffc0202142:	e4a6                	sd	s1,72(sp)
ffffffffc0202144:	e0ca                	sd	s2,64(sp)
ffffffffc0202146:	fc4e                	sd	s3,56(sp)
ffffffffc0202148:	f852                	sd	s4,48(sp)
ffffffffc020214a:	f456                	sd	s5,40(sp)
ffffffffc020214c:	f05a                	sd	s6,32(sp)
ffffffffc020214e:	ec5e                	sd	s7,24(sp)
ffffffffc0202150:	e862                	sd	s8,16(sp)
ffffffffc0202152:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202154:	03479713          	slli	a4,a5,0x34
ffffffffc0202158:	eb71                	bnez	a4,ffffffffc020222c <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020215a:	002007b7          	lui	a5,0x200
ffffffffc020215e:	842e                	mv	s0,a1
ffffffffc0202160:	0af5e663          	bltu	a1,a5,ffffffffc020220c <unmap_range+0xd4>
ffffffffc0202164:	8932                	mv	s2,a2
ffffffffc0202166:	0ac5f363          	bgeu	a1,a2,ffffffffc020220c <unmap_range+0xd4>
ffffffffc020216a:	4785                	li	a5,1
ffffffffc020216c:	07fe                	slli	a5,a5,0x1f
ffffffffc020216e:	08c7ef63          	bltu	a5,a2,ffffffffc020220c <unmap_range+0xd4>
ffffffffc0202172:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202174:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202176:	000aac97          	auipc	s9,0xaa
ffffffffc020217a:	6b2c8c93          	addi	s9,s9,1714 # ffffffffc02ac828 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020217e:	000aac17          	auipc	s8,0xaa
ffffffffc0202182:	71ac0c13          	addi	s8,s8,1818 # ffffffffc02ac898 <pages>
ffffffffc0202186:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020218a:	00200b37          	lui	s6,0x200
ffffffffc020218e:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202192:	4601                	li	a2,0
ffffffffc0202194:	85a2                	mv	a1,s0
ffffffffc0202196:	854e                	mv	a0,s3
ffffffffc0202198:	d77ff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc020219c:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020219e:	cd21                	beqz	a0,ffffffffc02021f6 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021a0:	611c                	ld	a5,0(a0)
ffffffffc02021a2:	e38d                	bnez	a5,ffffffffc02021c4 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021a4:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021a6:	ff2466e3          	bltu	s0,s2,ffffffffc0202192 <unmap_range+0x5a>
}
ffffffffc02021aa:	60e6                	ld	ra,88(sp)
ffffffffc02021ac:	6446                	ld	s0,80(sp)
ffffffffc02021ae:	64a6                	ld	s1,72(sp)
ffffffffc02021b0:	6906                	ld	s2,64(sp)
ffffffffc02021b2:	79e2                	ld	s3,56(sp)
ffffffffc02021b4:	7a42                	ld	s4,48(sp)
ffffffffc02021b6:	7aa2                	ld	s5,40(sp)
ffffffffc02021b8:	7b02                	ld	s6,32(sp)
ffffffffc02021ba:	6be2                	ld	s7,24(sp)
ffffffffc02021bc:	6c42                	ld	s8,16(sp)
ffffffffc02021be:	6ca2                	ld	s9,8(sp)
ffffffffc02021c0:	6125                	addi	sp,sp,96
ffffffffc02021c2:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02021c4:	0017f713          	andi	a4,a5,1
ffffffffc02021c8:	df71                	beqz	a4,ffffffffc02021a4 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc02021ca:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021ce:	078a                	slli	a5,a5,0x2
ffffffffc02021d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021d2:	06e7fd63          	bgeu	a5,a4,ffffffffc020224c <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02021d6:	000c3503          	ld	a0,0(s8)
ffffffffc02021da:	97de                	add	a5,a5,s7
ffffffffc02021dc:	079a                	slli	a5,a5,0x6
ffffffffc02021de:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02021e0:	411c                	lw	a5,0(a0)
ffffffffc02021e2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02021e6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02021e8:	cf11                	beqz	a4,ffffffffc0202204 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02021ea:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02021ee:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02021f2:	9452                	add	s0,s0,s4
ffffffffc02021f4:	bf4d                	j	ffffffffc02021a6 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021f6:	945a                	add	s0,s0,s6
ffffffffc02021f8:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02021fc:	d45d                	beqz	s0,ffffffffc02021aa <unmap_range+0x72>
ffffffffc02021fe:	f9246ae3          	bltu	s0,s2,ffffffffc0202192 <unmap_range+0x5a>
ffffffffc0202202:	b765                	j	ffffffffc02021aa <unmap_range+0x72>
            free_page(page);
ffffffffc0202204:	4585                	li	a1,1
ffffffffc0202206:	c83ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
ffffffffc020220a:	b7c5                	j	ffffffffc02021ea <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc020220c:	00005697          	auipc	a3,0x5
ffffffffc0202210:	5c468693          	addi	a3,a3,1476 # ffffffffc02077d0 <default_pmm_manager+0x718>
ffffffffc0202214:	00004617          	auipc	a2,0x4
ffffffffc0202218:	75c60613          	addi	a2,a2,1884 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020221c:	11000593          	li	a1,272
ffffffffc0202220:	00005517          	auipc	a0,0x5
ffffffffc0202224:	00850513          	addi	a0,a0,8 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202228:	a58fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020222c:	00005697          	auipc	a3,0x5
ffffffffc0202230:	57468693          	addi	a3,a3,1396 # ffffffffc02077a0 <default_pmm_manager+0x6e8>
ffffffffc0202234:	00004617          	auipc	a2,0x4
ffffffffc0202238:	73c60613          	addi	a2,a2,1852 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020223c:	10f00593          	li	a1,271
ffffffffc0202240:	00005517          	auipc	a0,0x5
ffffffffc0202244:	fe850513          	addi	a0,a0,-24 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202248:	a38fe0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc020224c:	b99ff0ef          	jal	ra,ffffffffc0201de4 <pa2page.part.4>

ffffffffc0202250 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202250:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202252:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202256:	fc86                	sd	ra,120(sp)
ffffffffc0202258:	f8a2                	sd	s0,112(sp)
ffffffffc020225a:	f4a6                	sd	s1,104(sp)
ffffffffc020225c:	f0ca                	sd	s2,96(sp)
ffffffffc020225e:	ecce                	sd	s3,88(sp)
ffffffffc0202260:	e8d2                	sd	s4,80(sp)
ffffffffc0202262:	e4d6                	sd	s5,72(sp)
ffffffffc0202264:	e0da                	sd	s6,64(sp)
ffffffffc0202266:	fc5e                	sd	s7,56(sp)
ffffffffc0202268:	f862                	sd	s8,48(sp)
ffffffffc020226a:	f466                	sd	s9,40(sp)
ffffffffc020226c:	f06a                	sd	s10,32(sp)
ffffffffc020226e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202270:	03479713          	slli	a4,a5,0x34
ffffffffc0202274:	1c071163          	bnez	a4,ffffffffc0202436 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc0202278:	002007b7          	lui	a5,0x200
ffffffffc020227c:	20f5e563          	bltu	a1,a5,ffffffffc0202486 <exit_range+0x236>
ffffffffc0202280:	8b32                	mv	s6,a2
ffffffffc0202282:	20c5f263          	bgeu	a1,a2,ffffffffc0202486 <exit_range+0x236>
ffffffffc0202286:	4785                	li	a5,1
ffffffffc0202288:	07fe                	slli	a5,a5,0x1f
ffffffffc020228a:	1ec7ee63          	bltu	a5,a2,ffffffffc0202486 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020228e:	c00009b7          	lui	s3,0xc0000
ffffffffc0202292:	400007b7          	lui	a5,0x40000
ffffffffc0202296:	0135f9b3          	and	s3,a1,s3
ffffffffc020229a:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020229c:	c0000337          	lui	t1,0xc0000
ffffffffc02022a0:	00698933          	add	s2,s3,t1
ffffffffc02022a4:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022a8:	1ff97913          	andi	s2,s2,511
ffffffffc02022ac:	8e2a                	mv	t3,a0
ffffffffc02022ae:	090e                	slli	s2,s2,0x3
ffffffffc02022b0:	9972                	add	s2,s2,t3
ffffffffc02022b2:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022b6:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02022ba:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02022bc:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022c0:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02022c2:	000aad17          	auipc	s10,0xaa
ffffffffc02022c6:	566d0d13          	addi	s10,s10,1382 # ffffffffc02ac828 <npage>
    return KADDR(page2pa(page));
ffffffffc02022ca:	00cddd93          	srli	s11,s11,0xc
ffffffffc02022ce:	000aa717          	auipc	a4,0xaa
ffffffffc02022d2:	5ba70713          	addi	a4,a4,1466 # ffffffffc02ac888 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc02022d6:	000aae97          	auipc	t4,0xaa
ffffffffc02022da:	5c2e8e93          	addi	t4,t4,1474 # ffffffffc02ac898 <pages>
        if (pde1&PTE_V){
ffffffffc02022de:	e79d                	bnez	a5,ffffffffc020230c <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc02022e0:	12098963          	beqz	s3,ffffffffc0202412 <exit_range+0x1c2>
ffffffffc02022e4:	400007b7          	lui	a5,0x40000
ffffffffc02022e8:	84ce                	mv	s1,s3
ffffffffc02022ea:	97ce                	add	a5,a5,s3
ffffffffc02022ec:	1369f363          	bgeu	s3,s6,ffffffffc0202412 <exit_range+0x1c2>
ffffffffc02022f0:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022f2:	00698933          	add	s2,s3,t1
ffffffffc02022f6:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022fa:	1ff97913          	andi	s2,s2,511
ffffffffc02022fe:	090e                	slli	s2,s2,0x3
ffffffffc0202300:	9972                	add	s2,s2,t3
ffffffffc0202302:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202306:	001bf793          	andi	a5,s7,1
ffffffffc020230a:	dbf9                	beqz	a5,ffffffffc02022e0 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc020230c:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202310:	0b8a                	slli	s7,s7,0x2
ffffffffc0202312:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202316:	14fbfc63          	bgeu	s7,a5,ffffffffc020246e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020231a:	fff80ab7          	lui	s5,0xfff80
ffffffffc020231e:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202320:	000806b7          	lui	a3,0x80
ffffffffc0202324:	96d6                	add	a3,a3,s5
ffffffffc0202326:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc020232a:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020232e:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202330:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202332:	12f67263          	bgeu	a2,a5,ffffffffc0202456 <exit_range+0x206>
ffffffffc0202336:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc020233a:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc020233c:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202340:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0202342:	00080837          	lui	a6,0x80
ffffffffc0202346:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202348:	00200c37          	lui	s8,0x200
ffffffffc020234c:	a801                	j	ffffffffc020235c <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020234e:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202350:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202352:	c0d9                	beqz	s1,ffffffffc02023d8 <exit_range+0x188>
ffffffffc0202354:	0934f263          	bgeu	s1,s3,ffffffffc02023d8 <exit_range+0x188>
ffffffffc0202358:	0d64fc63          	bgeu	s1,s6,ffffffffc0202430 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020235c:	0154d413          	srli	s0,s1,0x15
ffffffffc0202360:	1ff47413          	andi	s0,s0,511
ffffffffc0202364:	040e                	slli	s0,s0,0x3
ffffffffc0202366:	9452                	add	s0,s0,s4
ffffffffc0202368:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc020236a:	0017f693          	andi	a3,a5,1
ffffffffc020236e:	d2e5                	beqz	a3,ffffffffc020234e <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0202370:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202374:	00279513          	slli	a0,a5,0x2
ffffffffc0202378:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020237a:	0eb57a63          	bgeu	a0,a1,ffffffffc020246e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020237e:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0202380:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0202384:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0202388:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020238a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020238c:	0cb7f563          	bgeu	a5,a1,ffffffffc0202456 <exit_range+0x206>
ffffffffc0202390:	631c                	ld	a5,0(a4)
ffffffffc0202392:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202394:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0202398:	629c                	ld	a5,0(a3)
ffffffffc020239a:	8b85                	andi	a5,a5,1
ffffffffc020239c:	fbd5                	bnez	a5,ffffffffc0202350 <exit_range+0x100>
ffffffffc020239e:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023a0:	fed59ce3          	bne	a1,a3,ffffffffc0202398 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023a4:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023a8:	4585                	li	a1,1
ffffffffc02023aa:	e072                	sd	t3,0(sp)
ffffffffc02023ac:	953e                	add	a0,a0,a5
ffffffffc02023ae:	adbff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
                d0start += PTSIZE;
ffffffffc02023b2:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023b4:	00043023          	sd	zero,0(s0)
ffffffffc02023b8:	000aae97          	auipc	t4,0xaa
ffffffffc02023bc:	4e0e8e93          	addi	t4,t4,1248 # ffffffffc02ac898 <pages>
ffffffffc02023c0:	6e02                	ld	t3,0(sp)
ffffffffc02023c2:	c0000337          	lui	t1,0xc0000
ffffffffc02023c6:	fff808b7          	lui	a7,0xfff80
ffffffffc02023ca:	00080837          	lui	a6,0x80
ffffffffc02023ce:	000aa717          	auipc	a4,0xaa
ffffffffc02023d2:	4ba70713          	addi	a4,a4,1210 # ffffffffc02ac888 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023d6:	fcbd                	bnez	s1,ffffffffc0202354 <exit_range+0x104>
            if (free_pd0) {
ffffffffc02023d8:	f00c84e3          	beqz	s9,ffffffffc02022e0 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc02023dc:	000d3783          	ld	a5,0(s10)
ffffffffc02023e0:	e072                	sd	t3,0(sp)
ffffffffc02023e2:	08fbf663          	bgeu	s7,a5,ffffffffc020246e <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e6:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc02023ea:	67a2                	ld	a5,8(sp)
ffffffffc02023ec:	4585                	li	a1,1
ffffffffc02023ee:	953e                	add	a0,a0,a5
ffffffffc02023f0:	a99ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02023f4:	00093023          	sd	zero,0(s2)
ffffffffc02023f8:	000aa717          	auipc	a4,0xaa
ffffffffc02023fc:	49070713          	addi	a4,a4,1168 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0202400:	c0000337          	lui	t1,0xc0000
ffffffffc0202404:	6e02                	ld	t3,0(sp)
ffffffffc0202406:	000aae97          	auipc	t4,0xaa
ffffffffc020240a:	492e8e93          	addi	t4,t4,1170 # ffffffffc02ac898 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020240e:	ec099be3          	bnez	s3,ffffffffc02022e4 <exit_range+0x94>
}
ffffffffc0202412:	70e6                	ld	ra,120(sp)
ffffffffc0202414:	7446                	ld	s0,112(sp)
ffffffffc0202416:	74a6                	ld	s1,104(sp)
ffffffffc0202418:	7906                	ld	s2,96(sp)
ffffffffc020241a:	69e6                	ld	s3,88(sp)
ffffffffc020241c:	6a46                	ld	s4,80(sp)
ffffffffc020241e:	6aa6                	ld	s5,72(sp)
ffffffffc0202420:	6b06                	ld	s6,64(sp)
ffffffffc0202422:	7be2                	ld	s7,56(sp)
ffffffffc0202424:	7c42                	ld	s8,48(sp)
ffffffffc0202426:	7ca2                	ld	s9,40(sp)
ffffffffc0202428:	7d02                	ld	s10,32(sp)
ffffffffc020242a:	6de2                	ld	s11,24(sp)
ffffffffc020242c:	6109                	addi	sp,sp,128
ffffffffc020242e:	8082                	ret
            if (free_pd0) {
ffffffffc0202430:	ea0c8ae3          	beqz	s9,ffffffffc02022e4 <exit_range+0x94>
ffffffffc0202434:	b765                	j	ffffffffc02023dc <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202436:	00005697          	auipc	a3,0x5
ffffffffc020243a:	36a68693          	addi	a3,a3,874 # ffffffffc02077a0 <default_pmm_manager+0x6e8>
ffffffffc020243e:	00004617          	auipc	a2,0x4
ffffffffc0202442:	53260613          	addi	a2,a2,1330 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202446:	12000593          	li	a1,288
ffffffffc020244a:	00005517          	auipc	a0,0x5
ffffffffc020244e:	dde50513          	addi	a0,a0,-546 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202452:	82efe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202456:	00005617          	auipc	a2,0x5
ffffffffc020245a:	cb260613          	addi	a2,a2,-846 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc020245e:	06900593          	li	a1,105
ffffffffc0202462:	00005517          	auipc	a0,0x5
ffffffffc0202466:	cce50513          	addi	a0,a0,-818 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc020246a:	816fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020246e:	00005617          	auipc	a2,0x5
ffffffffc0202472:	cfa60613          	addi	a2,a2,-774 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0202476:	06200593          	li	a1,98
ffffffffc020247a:	00005517          	auipc	a0,0x5
ffffffffc020247e:	cb650513          	addi	a0,a0,-842 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0202482:	ffffd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202486:	00005697          	auipc	a3,0x5
ffffffffc020248a:	34a68693          	addi	a3,a3,842 # ffffffffc02077d0 <default_pmm_manager+0x718>
ffffffffc020248e:	00004617          	auipc	a2,0x4
ffffffffc0202492:	4e260613          	addi	a2,a2,1250 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202496:	12100593          	li	a1,289
ffffffffc020249a:	00005517          	auipc	a0,0x5
ffffffffc020249e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02024a2:	fdffd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02024a6 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024a6:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024a8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024aa:	e426                	sd	s1,8(sp)
ffffffffc02024ac:	ec06                	sd	ra,24(sp)
ffffffffc02024ae:	e822                	sd	s0,16(sp)
ffffffffc02024b0:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024b2:	a5dff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
    if (ptep != NULL) {
ffffffffc02024b6:	c511                	beqz	a0,ffffffffc02024c2 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02024b8:	611c                	ld	a5,0(a0)
ffffffffc02024ba:	842a                	mv	s0,a0
ffffffffc02024bc:	0017f713          	andi	a4,a5,1
ffffffffc02024c0:	e711                	bnez	a4,ffffffffc02024cc <page_remove+0x26>
}
ffffffffc02024c2:	60e2                	ld	ra,24(sp)
ffffffffc02024c4:	6442                	ld	s0,16(sp)
ffffffffc02024c6:	64a2                	ld	s1,8(sp)
ffffffffc02024c8:	6105                	addi	sp,sp,32
ffffffffc02024ca:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02024cc:	000aa717          	auipc	a4,0xaa
ffffffffc02024d0:	35c70713          	addi	a4,a4,860 # ffffffffc02ac828 <npage>
ffffffffc02024d4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02024d6:	078a                	slli	a5,a5,0x2
ffffffffc02024d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024da:	02e7fe63          	bgeu	a5,a4,ffffffffc0202516 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc02024de:	000aa717          	auipc	a4,0xaa
ffffffffc02024e2:	3ba70713          	addi	a4,a4,954 # ffffffffc02ac898 <pages>
ffffffffc02024e6:	6308                	ld	a0,0(a4)
ffffffffc02024e8:	fff80737          	lui	a4,0xfff80
ffffffffc02024ec:	97ba                	add	a5,a5,a4
ffffffffc02024ee:	079a                	slli	a5,a5,0x6
ffffffffc02024f0:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02024f2:	411c                	lw	a5,0(a0)
ffffffffc02024f4:	fff7871b          	addiw	a4,a5,-1
ffffffffc02024f8:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02024fa:	cb11                	beqz	a4,ffffffffc020250e <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02024fc:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202500:	12048073          	sfence.vma	s1
}
ffffffffc0202504:	60e2                	ld	ra,24(sp)
ffffffffc0202506:	6442                	ld	s0,16(sp)
ffffffffc0202508:	64a2                	ld	s1,8(sp)
ffffffffc020250a:	6105                	addi	sp,sp,32
ffffffffc020250c:	8082                	ret
            free_page(page);
ffffffffc020250e:	4585                	li	a1,1
ffffffffc0202510:	979ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
ffffffffc0202514:	b7e5                	j	ffffffffc02024fc <page_remove+0x56>
ffffffffc0202516:	8cfff0ef          	jal	ra,ffffffffc0201de4 <pa2page.part.4>

ffffffffc020251a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020251a:	7179                	addi	sp,sp,-48
ffffffffc020251c:	e44e                	sd	s3,8(sp)
ffffffffc020251e:	89b2                	mv	s3,a2
ffffffffc0202520:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202522:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202524:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202526:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202528:	ec26                	sd	s1,24(sp)
ffffffffc020252a:	f406                	sd	ra,40(sp)
ffffffffc020252c:	e84a                	sd	s2,16(sp)
ffffffffc020252e:	e052                	sd	s4,0(sp)
ffffffffc0202530:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202532:	9ddff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
    if (ptep == NULL) {
ffffffffc0202536:	cd49                	beqz	a0,ffffffffc02025d0 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202538:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020253a:	611c                	ld	a5,0(a0)
ffffffffc020253c:	892a                	mv	s2,a0
ffffffffc020253e:	0016871b          	addiw	a4,a3,1
ffffffffc0202542:	c018                	sw	a4,0(s0)
ffffffffc0202544:	0017f713          	andi	a4,a5,1
ffffffffc0202548:	ef05                	bnez	a4,ffffffffc0202580 <page_insert+0x66>
ffffffffc020254a:	000aa797          	auipc	a5,0xaa
ffffffffc020254e:	34e78793          	addi	a5,a5,846 # ffffffffc02ac898 <pages>
ffffffffc0202552:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202554:	8c19                	sub	s0,s0,a4
ffffffffc0202556:	000806b7          	lui	a3,0x80
ffffffffc020255a:	8419                	srai	s0,s0,0x6
ffffffffc020255c:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020255e:	042a                	slli	s0,s0,0xa
ffffffffc0202560:	8c45                	or	s0,s0,s1
ffffffffc0202562:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202566:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256a:	12098073          	sfence.vma	s3
    return 0;
ffffffffc020256e:	4501                	li	a0,0
}
ffffffffc0202570:	70a2                	ld	ra,40(sp)
ffffffffc0202572:	7402                	ld	s0,32(sp)
ffffffffc0202574:	64e2                	ld	s1,24(sp)
ffffffffc0202576:	6942                	ld	s2,16(sp)
ffffffffc0202578:	69a2                	ld	s3,8(sp)
ffffffffc020257a:	6a02                	ld	s4,0(sp)
ffffffffc020257c:	6145                	addi	sp,sp,48
ffffffffc020257e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202580:	000aa717          	auipc	a4,0xaa
ffffffffc0202584:	2a870713          	addi	a4,a4,680 # ffffffffc02ac828 <npage>
ffffffffc0202588:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020258a:	078a                	slli	a5,a5,0x2
ffffffffc020258c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020258e:	04e7f363          	bgeu	a5,a4,ffffffffc02025d4 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202592:	000aaa17          	auipc	s4,0xaa
ffffffffc0202596:	306a0a13          	addi	s4,s4,774 # ffffffffc02ac898 <pages>
ffffffffc020259a:	000a3703          	ld	a4,0(s4)
ffffffffc020259e:	fff80537          	lui	a0,0xfff80
ffffffffc02025a2:	953e                	add	a0,a0,a5
ffffffffc02025a4:	051a                	slli	a0,a0,0x6
ffffffffc02025a6:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025a8:	00a40a63          	beq	s0,a0,ffffffffc02025bc <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025ac:	411c                	lw	a5,0(a0)
ffffffffc02025ae:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025b2:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02025b4:	c691                	beqz	a3,ffffffffc02025c0 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025b6:	12098073          	sfence.vma	s3
ffffffffc02025ba:	bf69                	j	ffffffffc0202554 <page_insert+0x3a>
ffffffffc02025bc:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025be:	bf59                	j	ffffffffc0202554 <page_insert+0x3a>
            free_page(page);
ffffffffc02025c0:	4585                	li	a1,1
ffffffffc02025c2:	8c7ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
ffffffffc02025c6:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ca:	12098073          	sfence.vma	s3
ffffffffc02025ce:	b759                	j	ffffffffc0202554 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02025d0:	5571                	li	a0,-4
ffffffffc02025d2:	bf79                	j	ffffffffc0202570 <page_insert+0x56>
ffffffffc02025d4:	811ff0ef          	jal	ra,ffffffffc0201de4 <pa2page.part.4>

ffffffffc02025d8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02025d8:	00005797          	auipc	a5,0x5
ffffffffc02025dc:	ae078793          	addi	a5,a5,-1312 # ffffffffc02070b8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025e0:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02025e2:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025e4:	00005517          	auipc	a0,0x5
ffffffffc02025e8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0207250 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc02025ec:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02025ee:	000aa717          	auipc	a4,0xaa
ffffffffc02025f2:	28f73923          	sd	a5,658(a4) # ffffffffc02ac880 <pmm_manager>
void pmm_init(void) {
ffffffffc02025f6:	e0a2                	sd	s0,64(sp)
ffffffffc02025f8:	fc26                	sd	s1,56(sp)
ffffffffc02025fa:	f84a                	sd	s2,48(sp)
ffffffffc02025fc:	f44e                	sd	s3,40(sp)
ffffffffc02025fe:	f052                	sd	s4,32(sp)
ffffffffc0202600:	ec56                	sd	s5,24(sp)
ffffffffc0202602:	e85a                	sd	s6,16(sp)
ffffffffc0202604:	e45e                	sd	s7,8(sp)
ffffffffc0202606:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202608:	000aa417          	auipc	s0,0xaa
ffffffffc020260c:	27840413          	addi	s0,s0,632 # ffffffffc02ac880 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202610:	b7ffd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202614:	601c                	ld	a5,0(s0)
ffffffffc0202616:	000aa497          	auipc	s1,0xaa
ffffffffc020261a:	21248493          	addi	s1,s1,530 # ffffffffc02ac828 <npage>
ffffffffc020261e:	000aa917          	auipc	s2,0xaa
ffffffffc0202622:	27a90913          	addi	s2,s2,634 # ffffffffc02ac898 <pages>
ffffffffc0202626:	679c                	ld	a5,8(a5)
ffffffffc0202628:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020262a:	57f5                	li	a5,-3
ffffffffc020262c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020262e:	00005517          	auipc	a0,0x5
ffffffffc0202632:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207268 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202636:	000aa717          	auipc	a4,0xaa
ffffffffc020263a:	24f73923          	sd	a5,594(a4) # ffffffffc02ac888 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020263e:	b51fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202642:	46c5                	li	a3,17
ffffffffc0202644:	06ee                	slli	a3,a3,0x1b
ffffffffc0202646:	40100613          	li	a2,1025
ffffffffc020264a:	16fd                	addi	a3,a3,-1
ffffffffc020264c:	0656                	slli	a2,a2,0x15
ffffffffc020264e:	07e005b7          	lui	a1,0x7e00
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	c2e50513          	addi	a0,a0,-978 # ffffffffc0207280 <default_pmm_manager+0x1c8>
ffffffffc020265a:	b35fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020265e:	777d                	lui	a4,0xfffff
ffffffffc0202660:	000ab797          	auipc	a5,0xab
ffffffffc0202664:	32f78793          	addi	a5,a5,815 # ffffffffc02ad98f <end+0xfff>
ffffffffc0202668:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020266a:	00088737          	lui	a4,0x88
ffffffffc020266e:	000aa697          	auipc	a3,0xaa
ffffffffc0202672:	1ae6bd23          	sd	a4,442(a3) # ffffffffc02ac828 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202676:	000aa717          	auipc	a4,0xaa
ffffffffc020267a:	22f73123          	sd	a5,546(a4) # ffffffffc02ac898 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020267e:	4701                	li	a4,0
ffffffffc0202680:	4685                	li	a3,1
ffffffffc0202682:	fff80837          	lui	a6,0xfff80
ffffffffc0202686:	a019                	j	ffffffffc020268c <pmm_init+0xb4>
ffffffffc0202688:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020268c:	00671613          	slli	a2,a4,0x6
ffffffffc0202690:	97b2                	add	a5,a5,a2
ffffffffc0202692:	07a1                	addi	a5,a5,8
ffffffffc0202694:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202698:	6090                	ld	a2,0(s1)
ffffffffc020269a:	0705                	addi	a4,a4,1
ffffffffc020269c:	010607b3          	add	a5,a2,a6
ffffffffc02026a0:	fef764e3          	bltu	a4,a5,ffffffffc0202688 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026a4:	00093503          	ld	a0,0(s2)
ffffffffc02026a8:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026ac:	00661693          	slli	a3,a2,0x6
ffffffffc02026b0:	97aa                	add	a5,a5,a0
ffffffffc02026b2:	96be                	add	a3,a3,a5
ffffffffc02026b4:	c02007b7          	lui	a5,0xc0200
ffffffffc02026b8:	7af6eb63          	bltu	a3,a5,ffffffffc0202e6e <pmm_init+0x896>
ffffffffc02026bc:	000aa997          	auipc	s3,0xaa
ffffffffc02026c0:	1cc98993          	addi	s3,s3,460 # ffffffffc02ac888 <va_pa_offset>
ffffffffc02026c4:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02026c8:	47c5                	li	a5,17
ffffffffc02026ca:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026cc:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02026ce:	02f6f763          	bgeu	a3,a5,ffffffffc02026fc <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02026d2:	6585                	lui	a1,0x1
ffffffffc02026d4:	15fd                	addi	a1,a1,-1
ffffffffc02026d6:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02026d8:	00c6d713          	srli	a4,a3,0xc
ffffffffc02026dc:	48c77863          	bgeu	a4,a2,ffffffffc0202b6c <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc02026e0:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02026e2:	75fd                	lui	a1,0xfffff
ffffffffc02026e4:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02026e6:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02026e8:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02026ea:	40d786b3          	sub	a3,a5,a3
ffffffffc02026ee:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02026f0:	00c6d593          	srli	a1,a3,0xc
ffffffffc02026f4:	953a                	add	a0,a0,a4
ffffffffc02026f6:	9602                	jalr	a2
ffffffffc02026f8:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02026fc:	00005517          	auipc	a0,0x5
ffffffffc0202700:	bac50513          	addi	a0,a0,-1108 # ffffffffc02072a8 <default_pmm_manager+0x1f0>
ffffffffc0202704:	a8bfd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202708:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020270a:	000aa417          	auipc	s0,0xaa
ffffffffc020270e:	11640413          	addi	s0,s0,278 # ffffffffc02ac820 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202712:	7b9c                	ld	a5,48(a5)
ffffffffc0202714:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202716:	00005517          	auipc	a0,0x5
ffffffffc020271a:	baa50513          	addi	a0,a0,-1110 # ffffffffc02072c0 <default_pmm_manager+0x208>
ffffffffc020271e:	a71fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202722:	00009697          	auipc	a3,0x9
ffffffffc0202726:	8de68693          	addi	a3,a3,-1826 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020272a:	000aa797          	auipc	a5,0xaa
ffffffffc020272e:	0ed7bb23          	sd	a3,246(a5) # ffffffffc02ac820 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202732:	c02007b7          	lui	a5,0xc0200
ffffffffc0202736:	10f6e8e3          	bltu	a3,a5,ffffffffc0203046 <pmm_init+0xa6e>
ffffffffc020273a:	0009b783          	ld	a5,0(s3)
ffffffffc020273e:	8e9d                	sub	a3,a3,a5
ffffffffc0202740:	000aa797          	auipc	a5,0xaa
ffffffffc0202744:	14d7b823          	sd	a3,336(a5) # ffffffffc02ac890 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202748:	f86ff0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020274c:	6098                	ld	a4,0(s1)
ffffffffc020274e:	c80007b7          	lui	a5,0xc8000
ffffffffc0202752:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202754:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202756:	0ce7e8e3          	bltu	a5,a4,ffffffffc0203026 <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020275a:	6008                	ld	a0,0(s0)
ffffffffc020275c:	44050263          	beqz	a0,ffffffffc0202ba0 <pmm_init+0x5c8>
ffffffffc0202760:	03451793          	slli	a5,a0,0x34
ffffffffc0202764:	42079e63          	bnez	a5,ffffffffc0202ba0 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202768:	4601                	li	a2,0
ffffffffc020276a:	4581                	li	a1,0
ffffffffc020276c:	975ff0ef          	jal	ra,ffffffffc02020e0 <get_page>
ffffffffc0202770:	78051b63          	bnez	a0,ffffffffc0202f06 <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202774:	4505                	li	a0,1
ffffffffc0202776:	e8aff0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc020277a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020277c:	6008                	ld	a0,0(s0)
ffffffffc020277e:	4681                	li	a3,0
ffffffffc0202780:	4601                	li	a2,0
ffffffffc0202782:	85d6                	mv	a1,s5
ffffffffc0202784:	d97ff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc0202788:	7a051f63          	bnez	a0,ffffffffc0202f46 <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020278c:	6008                	ld	a0,0(s0)
ffffffffc020278e:	4601                	li	a2,0
ffffffffc0202790:	4581                	li	a1,0
ffffffffc0202792:	f7cff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc0202796:	78050863          	beqz	a0,ffffffffc0202f26 <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc020279a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020279c:	0017f713          	andi	a4,a5,1
ffffffffc02027a0:	3e070463          	beqz	a4,ffffffffc0202b88 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02027a4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027a6:	078a                	slli	a5,a5,0x2
ffffffffc02027a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027aa:	3ce7f163          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ae:	00093683          	ld	a3,0(s2)
ffffffffc02027b2:	fff80637          	lui	a2,0xfff80
ffffffffc02027b6:	97b2                	add	a5,a5,a2
ffffffffc02027b8:	079a                	slli	a5,a5,0x6
ffffffffc02027ba:	97b6                	add	a5,a5,a3
ffffffffc02027bc:	72fa9563          	bne	s5,a5,ffffffffc0202ee6 <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02027c0:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc02027c4:	4785                	li	a5,1
ffffffffc02027c6:	70fb9063          	bne	s7,a5,ffffffffc0202ec6 <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02027ca:	6008                	ld	a0,0(s0)
ffffffffc02027cc:	76fd                	lui	a3,0xfffff
ffffffffc02027ce:	611c                	ld	a5,0(a0)
ffffffffc02027d0:	078a                	slli	a5,a5,0x2
ffffffffc02027d2:	8ff5                	and	a5,a5,a3
ffffffffc02027d4:	00c7d613          	srli	a2,a5,0xc
ffffffffc02027d8:	66e67e63          	bgeu	a2,a4,ffffffffc0202e54 <pmm_init+0x87c>
ffffffffc02027dc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027e0:	97e2                	add	a5,a5,s8
ffffffffc02027e2:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53670>
ffffffffc02027e6:	0b0a                	slli	s6,s6,0x2
ffffffffc02027e8:	00db7b33          	and	s6,s6,a3
ffffffffc02027ec:	00cb5793          	srli	a5,s6,0xc
ffffffffc02027f0:	56e7f863          	bgeu	a5,a4,ffffffffc0202d60 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02027f4:	4601                	li	a2,0
ffffffffc02027f6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027f8:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02027fa:	f14ff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027fe:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202800:	55651063          	bne	a0,s6,ffffffffc0202d40 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc0202804:	4505                	li	a0,1
ffffffffc0202806:	dfaff0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc020280a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020280c:	6008                	ld	a0,0(s0)
ffffffffc020280e:	46d1                	li	a3,20
ffffffffc0202810:	6605                	lui	a2,0x1
ffffffffc0202812:	85da                	mv	a1,s6
ffffffffc0202814:	d07ff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc0202818:	50051463          	bnez	a0,ffffffffc0202d20 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020281c:	6008                	ld	a0,0(s0)
ffffffffc020281e:	4601                	li	a2,0
ffffffffc0202820:	6585                	lui	a1,0x1
ffffffffc0202822:	eecff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc0202826:	4c050d63          	beqz	a0,ffffffffc0202d00 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc020282a:	611c                	ld	a5,0(a0)
ffffffffc020282c:	0107f713          	andi	a4,a5,16
ffffffffc0202830:	4a070863          	beqz	a4,ffffffffc0202ce0 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc0202834:	8b91                	andi	a5,a5,4
ffffffffc0202836:	48078563          	beqz	a5,ffffffffc0202cc0 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020283a:	6008                	ld	a0,0(s0)
ffffffffc020283c:	611c                	ld	a5,0(a0)
ffffffffc020283e:	8bc1                	andi	a5,a5,16
ffffffffc0202840:	46078063          	beqz	a5,ffffffffc0202ca0 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc0202844:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
ffffffffc0202848:	43779c63          	bne	a5,s7,ffffffffc0202c80 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020284c:	4681                	li	a3,0
ffffffffc020284e:	6605                	lui	a2,0x1
ffffffffc0202850:	85d6                	mv	a1,s5
ffffffffc0202852:	cc9ff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc0202856:	40051563          	bnez	a0,ffffffffc0202c60 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc020285a:	000aa703          	lw	a4,0(s5)
ffffffffc020285e:	4789                	li	a5,2
ffffffffc0202860:	3ef71063          	bne	a4,a5,ffffffffc0202c40 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc0202864:	000b2783          	lw	a5,0(s6)
ffffffffc0202868:	3a079c63          	bnez	a5,ffffffffc0202c20 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	4601                	li	a2,0
ffffffffc0202870:	6585                	lui	a1,0x1
ffffffffc0202872:	e9cff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc0202876:	38050563          	beqz	a0,ffffffffc0202c00 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc020287a:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020287c:	00177793          	andi	a5,a4,1
ffffffffc0202880:	30078463          	beqz	a5,ffffffffc0202b88 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc0202884:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202886:	00271793          	slli	a5,a4,0x2
ffffffffc020288a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020288c:	2ed7f063          	bgeu	a5,a3,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202890:	00093683          	ld	a3,0(s2)
ffffffffc0202894:	fff80637          	lui	a2,0xfff80
ffffffffc0202898:	97b2                	add	a5,a5,a2
ffffffffc020289a:	079a                	slli	a5,a5,0x6
ffffffffc020289c:	97b6                	add	a5,a5,a3
ffffffffc020289e:	32fa9163          	bne	s5,a5,ffffffffc0202bc0 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028a2:	8b41                	andi	a4,a4,16
ffffffffc02028a4:	70071163          	bnez	a4,ffffffffc0202fa6 <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028a8:	6008                	ld	a0,0(s0)
ffffffffc02028aa:	4581                	li	a1,0
ffffffffc02028ac:	bfbff0ef          	jal	ra,ffffffffc02024a6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028b0:	000aa703          	lw	a4,0(s5)
ffffffffc02028b4:	4785                	li	a5,1
ffffffffc02028b6:	6cf71863          	bne	a4,a5,ffffffffc0202f86 <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02028ba:	000b2783          	lw	a5,0(s6)
ffffffffc02028be:	6a079463          	bnez	a5,ffffffffc0202f66 <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02028c2:	6008                	ld	a0,0(s0)
ffffffffc02028c4:	6585                	lui	a1,0x1
ffffffffc02028c6:	be1ff0ef          	jal	ra,ffffffffc02024a6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02028ca:	000aa783          	lw	a5,0(s5)
ffffffffc02028ce:	50079363          	bnez	a5,ffffffffc0202dd4 <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc02028d2:	000b2783          	lw	a5,0(s6)
ffffffffc02028d6:	4c079f63          	bnez	a5,ffffffffc0202db4 <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02028da:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02028de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028e0:	000b3783          	ld	a5,0(s6)
ffffffffc02028e4:	078a                	slli	a5,a5,0x2
ffffffffc02028e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028e8:	28e7f263          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ec:	fff806b7          	lui	a3,0xfff80
ffffffffc02028f0:	00093503          	ld	a0,0(s2)
ffffffffc02028f4:	97b6                	add	a5,a5,a3
ffffffffc02028f6:	079a                	slli	a5,a5,0x6
ffffffffc02028f8:	00f506b3          	add	a3,a0,a5
ffffffffc02028fc:	4290                	lw	a2,0(a3)
ffffffffc02028fe:	4685                	li	a3,1
ffffffffc0202900:	48d61a63          	bne	a2,a3,ffffffffc0202d94 <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc0202904:	8799                	srai	a5,a5,0x6
ffffffffc0202906:	00080ab7          	lui	s5,0x80
ffffffffc020290a:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc020290c:	00c79693          	slli	a3,a5,0xc
ffffffffc0202910:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202912:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202914:	46e6f363          	bgeu	a3,a4,ffffffffc0202d7a <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202918:	0009b683          	ld	a3,0(s3)
ffffffffc020291c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020291e:	639c                	ld	a5,0(a5)
ffffffffc0202920:	078a                	slli	a5,a5,0x2
ffffffffc0202922:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202924:	24e7f463          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202928:	415787b3          	sub	a5,a5,s5
ffffffffc020292c:	079a                	slli	a5,a5,0x6
ffffffffc020292e:	953e                	add	a0,a0,a5
ffffffffc0202930:	4585                	li	a1,1
ffffffffc0202932:	d56ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202936:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020293a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020293c:	078a                	slli	a5,a5,0x2
ffffffffc020293e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202940:	22e7f663          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202944:	00093503          	ld	a0,0(s2)
ffffffffc0202948:	415787b3          	sub	a5,a5,s5
ffffffffc020294c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020294e:	953e                	add	a0,a0,a5
ffffffffc0202950:	4585                	li	a1,1
ffffffffc0202952:	d36ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202956:	601c                	ld	a5,0(s0)
ffffffffc0202958:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020295c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202960:	d6eff0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc0202964:	68aa1163          	bne	s4,a0,ffffffffc0202fe6 <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202968:	00005517          	auipc	a0,0x5
ffffffffc020296c:	c6850513          	addi	a0,a0,-920 # ffffffffc02075d0 <default_pmm_manager+0x518>
ffffffffc0202970:	81ffd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202974:	d5aff0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202978:	6098                	ld	a4,0(s1)
ffffffffc020297a:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020297e:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202980:	00c71693          	slli	a3,a4,0xc
ffffffffc0202984:	18d7f563          	bgeu	a5,a3,ffffffffc0202b0e <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202988:	83b1                	srli	a5,a5,0xc
ffffffffc020298a:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020298c:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202990:	1ae7f163          	bgeu	a5,a4,ffffffffc0202b32 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202994:	7bfd                	lui	s7,0xfffff
ffffffffc0202996:	6b05                	lui	s6,0x1
ffffffffc0202998:	a029                	j	ffffffffc02029a2 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020299a:	00cad713          	srli	a4,s5,0xc
ffffffffc020299e:	18f77a63          	bgeu	a4,a5,ffffffffc0202b32 <pmm_init+0x55a>
ffffffffc02029a2:	0009b583          	ld	a1,0(s3)
ffffffffc02029a6:	4601                	li	a2,0
ffffffffc02029a8:	95d6                	add	a1,a1,s5
ffffffffc02029aa:	d64ff0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc02029ae:	16050263          	beqz	a0,ffffffffc0202b12 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029b2:	611c                	ld	a5,0(a0)
ffffffffc02029b4:	078a                	slli	a5,a5,0x2
ffffffffc02029b6:	0177f7b3          	and	a5,a5,s7
ffffffffc02029ba:	19579963          	bne	a5,s5,ffffffffc0202b4c <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029be:	609c                	ld	a5,0(s1)
ffffffffc02029c0:	9ada                	add	s5,s5,s6
ffffffffc02029c2:	6008                	ld	a0,0(s0)
ffffffffc02029c4:	00c79713          	slli	a4,a5,0xc
ffffffffc02029c8:	fceae9e3          	bltu	s5,a4,ffffffffc020299a <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02029cc:	611c                	ld	a5,0(a0)
ffffffffc02029ce:	62079c63          	bnez	a5,ffffffffc0203006 <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc02029d2:	4505                	li	a0,1
ffffffffc02029d4:	c2cff0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02029d8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02029da:	6008                	ld	a0,0(s0)
ffffffffc02029dc:	4699                	li	a3,6
ffffffffc02029de:	10000613          	li	a2,256
ffffffffc02029e2:	85d6                	mv	a1,s5
ffffffffc02029e4:	b37ff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc02029e8:	1e051c63          	bnez	a0,ffffffffc0202be0 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc02029ec:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc02029f0:	4785                	li	a5,1
ffffffffc02029f2:	44f71163          	bne	a4,a5,ffffffffc0202e34 <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029f6:	6008                	ld	a0,0(s0)
ffffffffc02029f8:	6b05                	lui	s6,0x1
ffffffffc02029fa:	4699                	li	a3,6
ffffffffc02029fc:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0202a00:	85d6                	mv	a1,s5
ffffffffc0202a02:	b19ff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc0202a06:	40051763          	bnez	a0,ffffffffc0202e14 <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0202a0a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a0e:	4789                	li	a5,2
ffffffffc0202a10:	3ef71263          	bne	a4,a5,ffffffffc0202df4 <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a14:	00005597          	auipc	a1,0x5
ffffffffc0202a18:	cf458593          	addi	a1,a1,-780 # ffffffffc0207708 <default_pmm_manager+0x650>
ffffffffc0202a1c:	10000513          	li	a0,256
ffffffffc0202a20:	0d9030ef          	jal	ra,ffffffffc02062f8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a24:	100b0593          	addi	a1,s6,256
ffffffffc0202a28:	10000513          	li	a0,256
ffffffffc0202a2c:	0df030ef          	jal	ra,ffffffffc020630a <strcmp>
ffffffffc0202a30:	44051b63          	bnez	a0,ffffffffc0202e86 <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0202a34:	00093683          	ld	a3,0(s2)
ffffffffc0202a38:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a3c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a3e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a42:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a44:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a46:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a48:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a4c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a50:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a52:	10f77f63          	bgeu	a4,a5,ffffffffc0202b70 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a56:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a5a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a5e:	96be                	add	a3,a3,a5
ffffffffc0202a60:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3770>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a64:	051030ef          	jal	ra,ffffffffc02062b4 <strlen>
ffffffffc0202a68:	54051f63          	bnez	a0,ffffffffc0202fc6 <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a6c:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a70:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a72:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52670>
ffffffffc0202a76:	068a                	slli	a3,a3,0x2
ffffffffc0202a78:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a7a:	0ef6f963          	bgeu	a3,a5,ffffffffc0202b6c <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0202a7e:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a82:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a84:	0efb7663          	bgeu	s6,a5,ffffffffc0202b70 <pmm_init+0x598>
ffffffffc0202a88:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202a8c:	4585                	li	a1,1
ffffffffc0202a8e:	8556                	mv	a0,s5
ffffffffc0202a90:	99b6                	add	s3,s3,a3
ffffffffc0202a92:	bf6ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a96:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202a9a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a9c:	078a                	slli	a5,a5,0x2
ffffffffc0202a9e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aa0:	0ce7f663          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202aa4:	00093503          	ld	a0,0(s2)
ffffffffc0202aa8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202aac:	97ce                	add	a5,a5,s3
ffffffffc0202aae:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202ab0:	953e                	add	a0,a0,a5
ffffffffc0202ab2:	4585                	li	a1,1
ffffffffc0202ab4:	bd4ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ab8:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202abc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202abe:	078a                	slli	a5,a5,0x2
ffffffffc0202ac0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ac2:	0ae7f563          	bgeu	a5,a4,ffffffffc0202b6c <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac6:	00093503          	ld	a0,0(s2)
ffffffffc0202aca:	97ce                	add	a5,a5,s3
ffffffffc0202acc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202ace:	953e                	add	a0,a0,a5
ffffffffc0202ad0:	4585                	li	a1,1
ffffffffc0202ad2:	bb6ff0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202ad6:	601c                	ld	a5,0(s0)
ffffffffc0202ad8:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202adc:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202ae0:	beeff0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc0202ae4:	3caa1163          	bne	s4,a0,ffffffffc0202ea6 <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ae8:	00005517          	auipc	a0,0x5
ffffffffc0202aec:	c9850513          	addi	a0,a0,-872 # ffffffffc0207780 <default_pmm_manager+0x6c8>
ffffffffc0202af0:	e9efd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202af4:	6406                	ld	s0,64(sp)
ffffffffc0202af6:	60a6                	ld	ra,72(sp)
ffffffffc0202af8:	74e2                	ld	s1,56(sp)
ffffffffc0202afa:	7942                	ld	s2,48(sp)
ffffffffc0202afc:	79a2                	ld	s3,40(sp)
ffffffffc0202afe:	7a02                	ld	s4,32(sp)
ffffffffc0202b00:	6ae2                	ld	s5,24(sp)
ffffffffc0202b02:	6b42                	ld	s6,16(sp)
ffffffffc0202b04:	6ba2                	ld	s7,8(sp)
ffffffffc0202b06:	6c02                	ld	s8,0(sp)
ffffffffc0202b08:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b0a:	8daff06f          	j	ffffffffc0201be4 <kmalloc_init>
ffffffffc0202b0e:	6008                	ld	a0,0(s0)
ffffffffc0202b10:	bd75                	j	ffffffffc02029cc <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b12:	00005697          	auipc	a3,0x5
ffffffffc0202b16:	ade68693          	addi	a3,a3,-1314 # ffffffffc02075f0 <default_pmm_manager+0x538>
ffffffffc0202b1a:	00004617          	auipc	a2,0x4
ffffffffc0202b1e:	e5660613          	addi	a2,a2,-426 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202b22:	22700593          	li	a1,551
ffffffffc0202b26:	00004517          	auipc	a0,0x4
ffffffffc0202b2a:	70250513          	addi	a0,a0,1794 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202b2e:	953fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b32:	86d6                	mv	a3,s5
ffffffffc0202b34:	00004617          	auipc	a2,0x4
ffffffffc0202b38:	5d460613          	addi	a2,a2,1492 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202b3c:	22700593          	li	a1,551
ffffffffc0202b40:	00004517          	auipc	a0,0x4
ffffffffc0202b44:	6e850513          	addi	a0,a0,1768 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202b48:	939fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b4c:	00005697          	auipc	a3,0x5
ffffffffc0202b50:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207630 <default_pmm_manager+0x578>
ffffffffc0202b54:	00004617          	auipc	a2,0x4
ffffffffc0202b58:	e1c60613          	addi	a2,a2,-484 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202b5c:	22800593          	li	a1,552
ffffffffc0202b60:	00004517          	auipc	a0,0x4
ffffffffc0202b64:	6c850513          	addi	a0,a0,1736 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202b68:	919fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b6c:	a78ff0ef          	jal	ra,ffffffffc0201de4 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202b70:	00004617          	auipc	a2,0x4
ffffffffc0202b74:	59860613          	addi	a2,a2,1432 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202b78:	06900593          	li	a1,105
ffffffffc0202b7c:	00004517          	auipc	a0,0x4
ffffffffc0202b80:	5b450513          	addi	a0,a0,1460 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0202b84:	8fdfd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202b88:	00005617          	auipc	a2,0x5
ffffffffc0202b8c:	83860613          	addi	a2,a2,-1992 # ffffffffc02073c0 <default_pmm_manager+0x308>
ffffffffc0202b90:	07400593          	li	a1,116
ffffffffc0202b94:	00004517          	auipc	a0,0x4
ffffffffc0202b98:	59c50513          	addi	a0,a0,1436 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0202b9c:	8e5fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202ba0:	00004697          	auipc	a3,0x4
ffffffffc0202ba4:	76068693          	addi	a3,a3,1888 # ffffffffc0207300 <default_pmm_manager+0x248>
ffffffffc0202ba8:	00004617          	auipc	a2,0x4
ffffffffc0202bac:	dc860613          	addi	a2,a2,-568 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202bb0:	1eb00593          	li	a1,491
ffffffffc0202bb4:	00004517          	auipc	a0,0x4
ffffffffc0202bb8:	67450513          	addi	a0,a0,1652 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202bbc:	8c5fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bc0:	00005697          	auipc	a3,0x5
ffffffffc0202bc4:	82868693          	addi	a3,a3,-2008 # ffffffffc02073e8 <default_pmm_manager+0x330>
ffffffffc0202bc8:	00004617          	auipc	a2,0x4
ffffffffc0202bcc:	da860613          	addi	a2,a2,-600 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202bd0:	20700593          	li	a1,519
ffffffffc0202bd4:	00004517          	auipc	a0,0x4
ffffffffc0202bd8:	65450513          	addi	a0,a0,1620 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202bdc:	8a5fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202be0:	00005697          	auipc	a3,0x5
ffffffffc0202be4:	a8068693          	addi	a3,a3,-1408 # ffffffffc0207660 <default_pmm_manager+0x5a8>
ffffffffc0202be8:	00004617          	auipc	a2,0x4
ffffffffc0202bec:	d8860613          	addi	a2,a2,-632 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202bf0:	23000593          	li	a1,560
ffffffffc0202bf4:	00004517          	auipc	a0,0x4
ffffffffc0202bf8:	63450513          	addi	a0,a0,1588 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202bfc:	885fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c00:	00005697          	auipc	a3,0x5
ffffffffc0202c04:	87868693          	addi	a3,a3,-1928 # ffffffffc0207478 <default_pmm_manager+0x3c0>
ffffffffc0202c08:	00004617          	auipc	a2,0x4
ffffffffc0202c0c:	d6860613          	addi	a2,a2,-664 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202c10:	20600593          	li	a1,518
ffffffffc0202c14:	00004517          	auipc	a0,0x4
ffffffffc0202c18:	61450513          	addi	a0,a0,1556 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202c1c:	865fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c20:	00005697          	auipc	a3,0x5
ffffffffc0202c24:	92068693          	addi	a3,a3,-1760 # ffffffffc0207540 <default_pmm_manager+0x488>
ffffffffc0202c28:	00004617          	auipc	a2,0x4
ffffffffc0202c2c:	d4860613          	addi	a2,a2,-696 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202c30:	20500593          	li	a1,517
ffffffffc0202c34:	00004517          	auipc	a0,0x4
ffffffffc0202c38:	5f450513          	addi	a0,a0,1524 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202c3c:	845fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c40:	00005697          	auipc	a3,0x5
ffffffffc0202c44:	8e868693          	addi	a3,a3,-1816 # ffffffffc0207528 <default_pmm_manager+0x470>
ffffffffc0202c48:	00004617          	auipc	a2,0x4
ffffffffc0202c4c:	d2860613          	addi	a2,a2,-728 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202c50:	20400593          	li	a1,516
ffffffffc0202c54:	00004517          	auipc	a0,0x4
ffffffffc0202c58:	5d450513          	addi	a0,a0,1492 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202c5c:	825fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202c60:	00005697          	auipc	a3,0x5
ffffffffc0202c64:	89868693          	addi	a3,a3,-1896 # ffffffffc02074f8 <default_pmm_manager+0x440>
ffffffffc0202c68:	00004617          	auipc	a2,0x4
ffffffffc0202c6c:	d0860613          	addi	a2,a2,-760 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202c70:	20300593          	li	a1,515
ffffffffc0202c74:	00004517          	auipc	a0,0x4
ffffffffc0202c78:	5b450513          	addi	a0,a0,1460 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202c7c:	805fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202c80:	00005697          	auipc	a3,0x5
ffffffffc0202c84:	86068693          	addi	a3,a3,-1952 # ffffffffc02074e0 <default_pmm_manager+0x428>
ffffffffc0202c88:	00004617          	auipc	a2,0x4
ffffffffc0202c8c:	ce860613          	addi	a2,a2,-792 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202c90:	20100593          	li	a1,513
ffffffffc0202c94:	00004517          	auipc	a0,0x4
ffffffffc0202c98:	59450513          	addi	a0,a0,1428 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202c9c:	fe4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202ca0:	00005697          	auipc	a3,0x5
ffffffffc0202ca4:	82868693          	addi	a3,a3,-2008 # ffffffffc02074c8 <default_pmm_manager+0x410>
ffffffffc0202ca8:	00004617          	auipc	a2,0x4
ffffffffc0202cac:	cc860613          	addi	a2,a2,-824 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202cb0:	20000593          	li	a1,512
ffffffffc0202cb4:	00004517          	auipc	a0,0x4
ffffffffc0202cb8:	57450513          	addi	a0,a0,1396 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202cbc:	fc4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202cc0:	00004697          	auipc	a3,0x4
ffffffffc0202cc4:	7f868693          	addi	a3,a3,2040 # ffffffffc02074b8 <default_pmm_manager+0x400>
ffffffffc0202cc8:	00004617          	auipc	a2,0x4
ffffffffc0202ccc:	ca860613          	addi	a2,a2,-856 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202cd0:	1ff00593          	li	a1,511
ffffffffc0202cd4:	00004517          	auipc	a0,0x4
ffffffffc0202cd8:	55450513          	addi	a0,a0,1364 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202cdc:	fa4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ce0:	00004697          	auipc	a3,0x4
ffffffffc0202ce4:	7c868693          	addi	a3,a3,1992 # ffffffffc02074a8 <default_pmm_manager+0x3f0>
ffffffffc0202ce8:	00004617          	auipc	a2,0x4
ffffffffc0202cec:	c8860613          	addi	a2,a2,-888 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202cf0:	1fe00593          	li	a1,510
ffffffffc0202cf4:	00004517          	auipc	a0,0x4
ffffffffc0202cf8:	53450513          	addi	a0,a0,1332 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202cfc:	f84fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d00:	00004697          	auipc	a3,0x4
ffffffffc0202d04:	77868693          	addi	a3,a3,1912 # ffffffffc0207478 <default_pmm_manager+0x3c0>
ffffffffc0202d08:	00004617          	auipc	a2,0x4
ffffffffc0202d0c:	c6860613          	addi	a2,a2,-920 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202d10:	1fd00593          	li	a1,509
ffffffffc0202d14:	00004517          	auipc	a0,0x4
ffffffffc0202d18:	51450513          	addi	a0,a0,1300 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202d1c:	f64fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d20:	00004697          	auipc	a3,0x4
ffffffffc0202d24:	72068693          	addi	a3,a3,1824 # ffffffffc0207440 <default_pmm_manager+0x388>
ffffffffc0202d28:	00004617          	auipc	a2,0x4
ffffffffc0202d2c:	c4860613          	addi	a2,a2,-952 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202d30:	1fc00593          	li	a1,508
ffffffffc0202d34:	00004517          	auipc	a0,0x4
ffffffffc0202d38:	4f450513          	addi	a0,a0,1268 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202d3c:	f44fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d40:	00004697          	auipc	a3,0x4
ffffffffc0202d44:	6d868693          	addi	a3,a3,1752 # ffffffffc0207418 <default_pmm_manager+0x360>
ffffffffc0202d48:	00004617          	auipc	a2,0x4
ffffffffc0202d4c:	c2860613          	addi	a2,a2,-984 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202d50:	1f900593          	li	a1,505
ffffffffc0202d54:	00004517          	auipc	a0,0x4
ffffffffc0202d58:	4d450513          	addi	a0,a0,1236 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202d5c:	f24fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d60:	86da                	mv	a3,s6
ffffffffc0202d62:	00004617          	auipc	a2,0x4
ffffffffc0202d66:	3a660613          	addi	a2,a2,934 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202d6a:	1f800593          	li	a1,504
ffffffffc0202d6e:	00004517          	auipc	a0,0x4
ffffffffc0202d72:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202d76:	f0afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202d7a:	86be                	mv	a3,a5
ffffffffc0202d7c:	00004617          	auipc	a2,0x4
ffffffffc0202d80:	38c60613          	addi	a2,a2,908 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202d84:	06900593          	li	a1,105
ffffffffc0202d88:	00004517          	auipc	a0,0x4
ffffffffc0202d8c:	3a850513          	addi	a0,a0,936 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0202d90:	ef0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202d94:	00004697          	auipc	a3,0x4
ffffffffc0202d98:	7f468693          	addi	a3,a3,2036 # ffffffffc0207588 <default_pmm_manager+0x4d0>
ffffffffc0202d9c:	00004617          	auipc	a2,0x4
ffffffffc0202da0:	bd460613          	addi	a2,a2,-1068 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202da4:	21200593          	li	a1,530
ffffffffc0202da8:	00004517          	auipc	a0,0x4
ffffffffc0202dac:	48050513          	addi	a0,a0,1152 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202db0:	ed0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202db4:	00004697          	auipc	a3,0x4
ffffffffc0202db8:	78c68693          	addi	a3,a3,1932 # ffffffffc0207540 <default_pmm_manager+0x488>
ffffffffc0202dbc:	00004617          	auipc	a2,0x4
ffffffffc0202dc0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202dc4:	21000593          	li	a1,528
ffffffffc0202dc8:	00004517          	auipc	a0,0x4
ffffffffc0202dcc:	46050513          	addi	a0,a0,1120 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202dd0:	eb0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202dd4:	00004697          	auipc	a3,0x4
ffffffffc0202dd8:	79c68693          	addi	a3,a3,1948 # ffffffffc0207570 <default_pmm_manager+0x4b8>
ffffffffc0202ddc:	00004617          	auipc	a2,0x4
ffffffffc0202de0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202de4:	20f00593          	li	a1,527
ffffffffc0202de8:	00004517          	auipc	a0,0x4
ffffffffc0202dec:	44050513          	addi	a0,a0,1088 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202df0:	e90fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202df4:	00005697          	auipc	a3,0x5
ffffffffc0202df8:	8fc68693          	addi	a3,a3,-1796 # ffffffffc02076f0 <default_pmm_manager+0x638>
ffffffffc0202dfc:	00004617          	auipc	a2,0x4
ffffffffc0202e00:	b7460613          	addi	a2,a2,-1164 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202e04:	23300593          	li	a1,563
ffffffffc0202e08:	00004517          	auipc	a0,0x4
ffffffffc0202e0c:	42050513          	addi	a0,a0,1056 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202e10:	e70fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e14:	00005697          	auipc	a3,0x5
ffffffffc0202e18:	89c68693          	addi	a3,a3,-1892 # ffffffffc02076b0 <default_pmm_manager+0x5f8>
ffffffffc0202e1c:	00004617          	auipc	a2,0x4
ffffffffc0202e20:	b5460613          	addi	a2,a2,-1196 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202e24:	23200593          	li	a1,562
ffffffffc0202e28:	00004517          	auipc	a0,0x4
ffffffffc0202e2c:	40050513          	addi	a0,a0,1024 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202e30:	e50fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e34:	00005697          	auipc	a3,0x5
ffffffffc0202e38:	86468693          	addi	a3,a3,-1948 # ffffffffc0207698 <default_pmm_manager+0x5e0>
ffffffffc0202e3c:	00004617          	auipc	a2,0x4
ffffffffc0202e40:	b3460613          	addi	a2,a2,-1228 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202e44:	23100593          	li	a1,561
ffffffffc0202e48:	00004517          	auipc	a0,0x4
ffffffffc0202e4c:	3e050513          	addi	a0,a0,992 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202e50:	e30fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202e54:	86be                	mv	a3,a5
ffffffffc0202e56:	00004617          	auipc	a2,0x4
ffffffffc0202e5a:	2b260613          	addi	a2,a2,690 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0202e5e:	1f700593          	li	a1,503
ffffffffc0202e62:	00004517          	auipc	a0,0x4
ffffffffc0202e66:	3c650513          	addi	a0,a0,966 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202e6a:	e16fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202e6e:	00004617          	auipc	a2,0x4
ffffffffc0202e72:	2d260613          	addi	a2,a2,722 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc0202e76:	07f00593          	li	a1,127
ffffffffc0202e7a:	00004517          	auipc	a0,0x4
ffffffffc0202e7e:	3ae50513          	addi	a0,a0,942 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202e82:	dfefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202e86:	00005697          	auipc	a3,0x5
ffffffffc0202e8a:	89a68693          	addi	a3,a3,-1894 # ffffffffc0207720 <default_pmm_manager+0x668>
ffffffffc0202e8e:	00004617          	auipc	a2,0x4
ffffffffc0202e92:	ae260613          	addi	a2,a2,-1310 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202e96:	23700593          	li	a1,567
ffffffffc0202e9a:	00004517          	auipc	a0,0x4
ffffffffc0202e9e:	38e50513          	addi	a0,a0,910 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202ea2:	ddefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ea6:	00004697          	auipc	a3,0x4
ffffffffc0202eaa:	70a68693          	addi	a3,a3,1802 # ffffffffc02075b0 <default_pmm_manager+0x4f8>
ffffffffc0202eae:	00004617          	auipc	a2,0x4
ffffffffc0202eb2:	ac260613          	addi	a2,a2,-1342 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202eb6:	24300593          	li	a1,579
ffffffffc0202eba:	00004517          	auipc	a0,0x4
ffffffffc0202ebe:	36e50513          	addi	a0,a0,878 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202ec2:	dbefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ec6:	00004697          	auipc	a3,0x4
ffffffffc0202eca:	53a68693          	addi	a3,a3,1338 # ffffffffc0207400 <default_pmm_manager+0x348>
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202ed6:	1f500593          	li	a1,501
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	34e50513          	addi	a0,a0,846 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202ee2:	d9efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ee6:	00004697          	auipc	a3,0x4
ffffffffc0202eea:	50268693          	addi	a3,a3,1282 # ffffffffc02073e8 <default_pmm_manager+0x330>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202ef6:	1f400593          	li	a1,500
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	32e50513          	addi	a0,a0,814 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202f02:	d7efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f06:	00004697          	auipc	a3,0x4
ffffffffc0202f0a:	43268693          	addi	a3,a3,1074 # ffffffffc0207338 <default_pmm_manager+0x280>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	a6260613          	addi	a2,a2,-1438 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202f16:	1ec00593          	li	a1,492
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	30e50513          	addi	a0,a0,782 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202f22:	d5efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f26:	00004697          	auipc	a3,0x4
ffffffffc0202f2a:	46a68693          	addi	a3,a3,1130 # ffffffffc0207390 <default_pmm_manager+0x2d8>
ffffffffc0202f2e:	00004617          	auipc	a2,0x4
ffffffffc0202f32:	a4260613          	addi	a2,a2,-1470 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202f36:	1f300593          	li	a1,499
ffffffffc0202f3a:	00004517          	auipc	a0,0x4
ffffffffc0202f3e:	2ee50513          	addi	a0,a0,750 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202f42:	d3efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f46:	00004697          	auipc	a3,0x4
ffffffffc0202f4a:	41a68693          	addi	a3,a3,1050 # ffffffffc0207360 <default_pmm_manager+0x2a8>
ffffffffc0202f4e:	00004617          	auipc	a2,0x4
ffffffffc0202f52:	a2260613          	addi	a2,a2,-1502 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202f56:	1f000593          	li	a1,496
ffffffffc0202f5a:	00004517          	auipc	a0,0x4
ffffffffc0202f5e:	2ce50513          	addi	a0,a0,718 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202f62:	d1efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f66:	00004697          	auipc	a3,0x4
ffffffffc0202f6a:	5da68693          	addi	a3,a3,1498 # ffffffffc0207540 <default_pmm_manager+0x488>
ffffffffc0202f6e:	00004617          	auipc	a2,0x4
ffffffffc0202f72:	a0260613          	addi	a2,a2,-1534 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202f76:	20c00593          	li	a1,524
ffffffffc0202f7a:	00004517          	auipc	a0,0x4
ffffffffc0202f7e:	2ae50513          	addi	a0,a0,686 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202f82:	cfefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f86:	00004697          	auipc	a3,0x4
ffffffffc0202f8a:	47a68693          	addi	a3,a3,1146 # ffffffffc0207400 <default_pmm_manager+0x348>
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	9e260613          	addi	a2,a2,-1566 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202f96:	20b00593          	li	a1,523
ffffffffc0202f9a:	00004517          	auipc	a0,0x4
ffffffffc0202f9e:	28e50513          	addi	a0,a0,654 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202fa2:	cdefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fa6:	00004697          	auipc	a3,0x4
ffffffffc0202faa:	5b268693          	addi	a3,a3,1458 # ffffffffc0207558 <default_pmm_manager+0x4a0>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202fb6:	20800593          	li	a1,520
ffffffffc0202fba:	00004517          	auipc	a0,0x4
ffffffffc0202fbe:	26e50513          	addi	a0,a0,622 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202fc2:	cbefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202fc6:	00004697          	auipc	a3,0x4
ffffffffc0202fca:	79268693          	addi	a3,a3,1938 # ffffffffc0207758 <default_pmm_manager+0x6a0>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	9a260613          	addi	a2,a2,-1630 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202fd6:	23a00593          	li	a1,570
ffffffffc0202fda:	00004517          	auipc	a0,0x4
ffffffffc0202fde:	24e50513          	addi	a0,a0,590 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0202fe2:	c9efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202fe6:	00004697          	auipc	a3,0x4
ffffffffc0202fea:	5ca68693          	addi	a3,a3,1482 # ffffffffc02075b0 <default_pmm_manager+0x4f8>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	98260613          	addi	a2,a2,-1662 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0202ff6:	21a00593          	li	a1,538
ffffffffc0202ffa:	00004517          	auipc	a0,0x4
ffffffffc0202ffe:	22e50513          	addi	a0,a0,558 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0203002:	c7efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203006:	00004697          	auipc	a3,0x4
ffffffffc020300a:	64268693          	addi	a3,a3,1602 # ffffffffc0207648 <default_pmm_manager+0x590>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	96260613          	addi	a2,a2,-1694 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203016:	22c00593          	li	a1,556
ffffffffc020301a:	00004517          	auipc	a0,0x4
ffffffffc020301e:	20e50513          	addi	a0,a0,526 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0203022:	c5efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203026:	00004697          	auipc	a3,0x4
ffffffffc020302a:	2ba68693          	addi	a3,a3,698 # ffffffffc02072e0 <default_pmm_manager+0x228>
ffffffffc020302e:	00004617          	auipc	a2,0x4
ffffffffc0203032:	94260613          	addi	a2,a2,-1726 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203036:	1ea00593          	li	a1,490
ffffffffc020303a:	00004517          	auipc	a0,0x4
ffffffffc020303e:	1ee50513          	addi	a0,a0,494 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0203042:	c3efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	0fa60613          	addi	a2,a2,250 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc020304e:	0c100593          	li	a1,193
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	1d650513          	addi	a0,a0,470 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc020305a:	c26fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020305e <copy_range>:
               bool share) {
ffffffffc020305e:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203060:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0203064:	f486                	sd	ra,104(sp)
ffffffffc0203066:	f0a2                	sd	s0,96(sp)
ffffffffc0203068:	eca6                	sd	s1,88(sp)
ffffffffc020306a:	e8ca                	sd	s2,80(sp)
ffffffffc020306c:	e4ce                	sd	s3,72(sp)
ffffffffc020306e:	e0d2                	sd	s4,64(sp)
ffffffffc0203070:	fc56                	sd	s5,56(sp)
ffffffffc0203072:	f85a                	sd	s6,48(sp)
ffffffffc0203074:	f45e                	sd	s7,40(sp)
ffffffffc0203076:	f062                	sd	s8,32(sp)
ffffffffc0203078:	ec66                	sd	s9,24(sp)
ffffffffc020307a:	e86a                	sd	s10,16(sp)
ffffffffc020307c:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020307e:	03479713          	slli	a4,a5,0x34
ffffffffc0203082:	1e071863          	bnez	a4,ffffffffc0203272 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc0203086:	002007b7          	lui	a5,0x200
ffffffffc020308a:	8432                	mv	s0,a2
ffffffffc020308c:	16f66b63          	bltu	a2,a5,ffffffffc0203202 <copy_range+0x1a4>
ffffffffc0203090:	84b6                	mv	s1,a3
ffffffffc0203092:	16d67863          	bgeu	a2,a3,ffffffffc0203202 <copy_range+0x1a4>
ffffffffc0203096:	4785                	li	a5,1
ffffffffc0203098:	07fe                	slli	a5,a5,0x1f
ffffffffc020309a:	16d7e463          	bltu	a5,a3,ffffffffc0203202 <copy_range+0x1a4>
ffffffffc020309e:	5a7d                	li	s4,-1
ffffffffc02030a0:	8aaa                	mv	s5,a0
ffffffffc02030a2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030a4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030a6:	000a9c17          	auipc	s8,0xa9
ffffffffc02030aa:	782c0c13          	addi	s8,s8,1922 # ffffffffc02ac828 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030ae:	000a9b97          	auipc	s7,0xa9
ffffffffc02030b2:	7eab8b93          	addi	s7,s7,2026 # ffffffffc02ac898 <pages>
    return page - pages + nbase;
ffffffffc02030b6:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02030ba:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02030be:	4601                	li	a2,0
ffffffffc02030c0:	85a2                	mv	a1,s0
ffffffffc02030c2:	854a                	mv	a0,s2
ffffffffc02030c4:	e4bfe0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc02030c8:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc02030ca:	c17d                	beqz	a0,ffffffffc02031b0 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc02030cc:	611c                	ld	a5,0(a0)
ffffffffc02030ce:	8b85                	andi	a5,a5,1
ffffffffc02030d0:	e785                	bnez	a5,ffffffffc02030f8 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc02030d2:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02030d4:	fe9465e3          	bltu	s0,s1,ffffffffc02030be <copy_range+0x60>
    return 0;
ffffffffc02030d8:	4501                	li	a0,0
}
ffffffffc02030da:	70a6                	ld	ra,104(sp)
ffffffffc02030dc:	7406                	ld	s0,96(sp)
ffffffffc02030de:	64e6                	ld	s1,88(sp)
ffffffffc02030e0:	6946                	ld	s2,80(sp)
ffffffffc02030e2:	69a6                	ld	s3,72(sp)
ffffffffc02030e4:	6a06                	ld	s4,64(sp)
ffffffffc02030e6:	7ae2                	ld	s5,56(sp)
ffffffffc02030e8:	7b42                	ld	s6,48(sp)
ffffffffc02030ea:	7ba2                	ld	s7,40(sp)
ffffffffc02030ec:	7c02                	ld	s8,32(sp)
ffffffffc02030ee:	6ce2                	ld	s9,24(sp)
ffffffffc02030f0:	6d42                	ld	s10,16(sp)
ffffffffc02030f2:	6da2                	ld	s11,8(sp)
ffffffffc02030f4:	6165                	addi	sp,sp,112
ffffffffc02030f6:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02030f8:	4605                	li	a2,1
ffffffffc02030fa:	85a2                	mv	a1,s0
ffffffffc02030fc:	8556                	mv	a0,s5
ffffffffc02030fe:	e11fe0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc0203102:	c169                	beqz	a0,ffffffffc02031c4 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203104:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203108:	0017f713          	andi	a4,a5,1
ffffffffc020310c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203110:	14070563          	beqz	a4,ffffffffc020325a <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203114:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203118:	078a                	slli	a5,a5,0x2
ffffffffc020311a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020311e:	12d77263          	bgeu	a4,a3,ffffffffc0203242 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203122:	000bb783          	ld	a5,0(s7)
ffffffffc0203126:	fff806b7          	lui	a3,0xfff80
ffffffffc020312a:	9736                	add	a4,a4,a3
ffffffffc020312c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020312e:	4505                	li	a0,1
ffffffffc0203130:	00e78db3          	add	s11,a5,a4
ffffffffc0203134:	ccdfe0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0203138:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020313a:	0a0d8463          	beqz	s11,ffffffffc02031e2 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020313e:	c175                	beqz	a0,ffffffffc0203222 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203140:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203144:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203148:	40ed86b3          	sub	a3,s11,a4
ffffffffc020314c:	8699                	srai	a3,a3,0x6
ffffffffc020314e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0203150:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0203154:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203156:	06c7fa63          	bgeu	a5,a2,ffffffffc02031ca <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc020315a:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc020315e:	000a9717          	auipc	a4,0xa9
ffffffffc0203162:	72a70713          	addi	a4,a4,1834 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0203166:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0203168:	8799                	srai	a5,a5,0x6
ffffffffc020316a:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020316c:	0147f733          	and	a4,a5,s4
ffffffffc0203170:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203174:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203176:	04c77963          	bgeu	a4,a2,ffffffffc02031c8 <copy_range+0x16a>
            memcpy(dst, src, PGSIZE);
ffffffffc020317a:	6605                	lui	a2,0x1
ffffffffc020317c:	953e                	add	a0,a0,a5
ffffffffc020317e:	1e6030ef          	jal	ra,ffffffffc0206364 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc0203182:	86e6                	mv	a3,s9
ffffffffc0203184:	8622                	mv	a2,s0
ffffffffc0203186:	85ea                	mv	a1,s10
ffffffffc0203188:	8556                	mv	a0,s5
ffffffffc020318a:	b90ff0ef          	jal	ra,ffffffffc020251a <page_insert>
            assert(ret == 0);
ffffffffc020318e:	d131                	beqz	a0,ffffffffc02030d2 <copy_range+0x74>
ffffffffc0203190:	00004697          	auipc	a3,0x4
ffffffffc0203194:	08868693          	addi	a3,a3,136 # ffffffffc0207218 <default_pmm_manager+0x160>
ffffffffc0203198:	00003617          	auipc	a2,0x3
ffffffffc020319c:	7d860613          	addi	a2,a2,2008 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02031a0:	18c00593          	li	a1,396
ffffffffc02031a4:	00004517          	auipc	a0,0x4
ffffffffc02031a8:	08450513          	addi	a0,a0,132 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02031ac:	ad4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02031b0:	002007b7          	lui	a5,0x200
ffffffffc02031b4:	943e                	add	s0,s0,a5
ffffffffc02031b6:	ffe007b7          	lui	a5,0xffe00
ffffffffc02031ba:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc02031bc:	dc11                	beqz	s0,ffffffffc02030d8 <copy_range+0x7a>
ffffffffc02031be:	f09460e3          	bltu	s0,s1,ffffffffc02030be <copy_range+0x60>
ffffffffc02031c2:	bf19                	j	ffffffffc02030d8 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc02031c4:	5571                	li	a0,-4
ffffffffc02031c6:	bf11                	j	ffffffffc02030da <copy_range+0x7c>
ffffffffc02031c8:	86be                	mv	a3,a5
ffffffffc02031ca:	00004617          	auipc	a2,0x4
ffffffffc02031ce:	f3e60613          	addi	a2,a2,-194 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc02031d2:	06900593          	li	a1,105
ffffffffc02031d6:	00004517          	auipc	a0,0x4
ffffffffc02031da:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc02031de:	aa2fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(page != NULL);
ffffffffc02031e2:	00004697          	auipc	a3,0x4
ffffffffc02031e6:	01668693          	addi	a3,a3,22 # ffffffffc02071f8 <default_pmm_manager+0x140>
ffffffffc02031ea:	00003617          	auipc	a2,0x3
ffffffffc02031ee:	78660613          	addi	a2,a2,1926 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02031f2:	17200593          	li	a1,370
ffffffffc02031f6:	00004517          	auipc	a0,0x4
ffffffffc02031fa:	03250513          	addi	a0,a0,50 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc02031fe:	a82fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203202:	00004697          	auipc	a3,0x4
ffffffffc0203206:	5ce68693          	addi	a3,a3,1486 # ffffffffc02077d0 <default_pmm_manager+0x718>
ffffffffc020320a:	00003617          	auipc	a2,0x3
ffffffffc020320e:	76660613          	addi	a2,a2,1894 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203212:	15e00593          	li	a1,350
ffffffffc0203216:	00004517          	auipc	a0,0x4
ffffffffc020321a:	01250513          	addi	a0,a0,18 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc020321e:	a62fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(npage != NULL);
ffffffffc0203222:	00004697          	auipc	a3,0x4
ffffffffc0203226:	fe668693          	addi	a3,a3,-26 # ffffffffc0207208 <default_pmm_manager+0x150>
ffffffffc020322a:	00003617          	auipc	a2,0x3
ffffffffc020322e:	74660613          	addi	a2,a2,1862 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203232:	17300593          	li	a1,371
ffffffffc0203236:	00004517          	auipc	a0,0x4
ffffffffc020323a:	ff250513          	addi	a0,a0,-14 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc020323e:	a42fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203242:	00004617          	auipc	a2,0x4
ffffffffc0203246:	f2660613          	addi	a2,a2,-218 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc020324a:	06200593          	li	a1,98
ffffffffc020324e:	00004517          	auipc	a0,0x4
ffffffffc0203252:	ee250513          	addi	a0,a0,-286 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0203256:	a2afd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020325a:	00004617          	auipc	a2,0x4
ffffffffc020325e:	16660613          	addi	a2,a2,358 # ffffffffc02073c0 <default_pmm_manager+0x308>
ffffffffc0203262:	07400593          	li	a1,116
ffffffffc0203266:	00004517          	auipc	a0,0x4
ffffffffc020326a:	eca50513          	addi	a0,a0,-310 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc020326e:	a12fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203272:	00004697          	auipc	a3,0x4
ffffffffc0203276:	52e68693          	addi	a3,a3,1326 # ffffffffc02077a0 <default_pmm_manager+0x6e8>
ffffffffc020327a:	00003617          	auipc	a2,0x3
ffffffffc020327e:	6f660613          	addi	a2,a2,1782 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203282:	15d00593          	li	a1,349
ffffffffc0203286:	00004517          	auipc	a0,0x4
ffffffffc020328a:	fa250513          	addi	a0,a0,-94 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc020328e:	9f2fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203292 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203292:	12058073          	sfence.vma	a1
}
ffffffffc0203296:	8082                	ret

ffffffffc0203298 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203298:	7179                	addi	sp,sp,-48
ffffffffc020329a:	e84a                	sd	s2,16(sp)
ffffffffc020329c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020329e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032a0:	f022                	sd	s0,32(sp)
ffffffffc02032a2:	ec26                	sd	s1,24(sp)
ffffffffc02032a4:	e44e                	sd	s3,8(sp)
ffffffffc02032a6:	f406                	sd	ra,40(sp)
ffffffffc02032a8:	84ae                	mv	s1,a1
ffffffffc02032aa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032ac:	b55fe0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc02032b0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02032b2:	cd1d                	beqz	a0,ffffffffc02032f0 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02032b4:	85aa                	mv	a1,a0
ffffffffc02032b6:	86ce                	mv	a3,s3
ffffffffc02032b8:	8626                	mv	a2,s1
ffffffffc02032ba:	854a                	mv	a0,s2
ffffffffc02032bc:	a5eff0ef          	jal	ra,ffffffffc020251a <page_insert>
ffffffffc02032c0:	e121                	bnez	a0,ffffffffc0203300 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02032c2:	000a9797          	auipc	a5,0xa9
ffffffffc02032c6:	57678793          	addi	a5,a5,1398 # ffffffffc02ac838 <swap_init_ok>
ffffffffc02032ca:	439c                	lw	a5,0(a5)
ffffffffc02032cc:	2781                	sext.w	a5,a5
ffffffffc02032ce:	c38d                	beqz	a5,ffffffffc02032f0 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02032d0:	000a9797          	auipc	a5,0xa9
ffffffffc02032d4:	6a878793          	addi	a5,a5,1704 # ffffffffc02ac978 <check_mm_struct>
ffffffffc02032d8:	6388                	ld	a0,0(a5)
ffffffffc02032da:	c919                	beqz	a0,ffffffffc02032f0 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02032dc:	4681                	li	a3,0
ffffffffc02032de:	8622                	mv	a2,s0
ffffffffc02032e0:	85a6                	mv	a1,s1
ffffffffc02032e2:	7da000ef          	jal	ra,ffffffffc0203abc <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02032e6:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02032e8:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02032ea:	4785                	li	a5,1
ffffffffc02032ec:	02f71063          	bne	a4,a5,ffffffffc020330c <pgdir_alloc_page+0x74>
}
ffffffffc02032f0:	8522                	mv	a0,s0
ffffffffc02032f2:	70a2                	ld	ra,40(sp)
ffffffffc02032f4:	7402                	ld	s0,32(sp)
ffffffffc02032f6:	64e2                	ld	s1,24(sp)
ffffffffc02032f8:	6942                	ld	s2,16(sp)
ffffffffc02032fa:	69a2                	ld	s3,8(sp)
ffffffffc02032fc:	6145                	addi	sp,sp,48
ffffffffc02032fe:	8082                	ret
            free_page(page);
ffffffffc0203300:	8522                	mv	a0,s0
ffffffffc0203302:	4585                	li	a1,1
ffffffffc0203304:	b85fe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
            return NULL;
ffffffffc0203308:	4401                	li	s0,0
ffffffffc020330a:	b7dd                	j	ffffffffc02032f0 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020330c:	00004697          	auipc	a3,0x4
ffffffffc0203310:	f2c68693          	addi	a3,a3,-212 # ffffffffc0207238 <default_pmm_manager+0x180>
ffffffffc0203314:	00003617          	auipc	a2,0x3
ffffffffc0203318:	65c60613          	addi	a2,a2,1628 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020331c:	1cb00593          	li	a1,459
ffffffffc0203320:	00004517          	auipc	a0,0x4
ffffffffc0203324:	f0850513          	addi	a0,a0,-248 # ffffffffc0207228 <default_pmm_manager+0x170>
ffffffffc0203328:	958fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020332c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020332c:	7135                	addi	sp,sp,-160
ffffffffc020332e:	ed06                	sd	ra,152(sp)
ffffffffc0203330:	e922                	sd	s0,144(sp)
ffffffffc0203332:	e526                	sd	s1,136(sp)
ffffffffc0203334:	e14a                	sd	s2,128(sp)
ffffffffc0203336:	fcce                	sd	s3,120(sp)
ffffffffc0203338:	f8d2                	sd	s4,112(sp)
ffffffffc020333a:	f4d6                	sd	s5,104(sp)
ffffffffc020333c:	f0da                	sd	s6,96(sp)
ffffffffc020333e:	ecde                	sd	s7,88(sp)
ffffffffc0203340:	e8e2                	sd	s8,80(sp)
ffffffffc0203342:	e4e6                	sd	s9,72(sp)
ffffffffc0203344:	e0ea                	sd	s10,64(sp)
ffffffffc0203346:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203348:	6dc010ef          	jal	ra,ffffffffc0204a24 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020334c:	000a9797          	auipc	a5,0xa9
ffffffffc0203350:	5dc78793          	addi	a5,a5,1500 # ffffffffc02ac928 <max_swap_offset>
ffffffffc0203354:	6394                	ld	a3,0(a5)
ffffffffc0203356:	010007b7          	lui	a5,0x1000
ffffffffc020335a:	17e1                	addi	a5,a5,-8
ffffffffc020335c:	ff968713          	addi	a4,a3,-7
ffffffffc0203360:	4ae7ee63          	bltu	a5,a4,ffffffffc020381c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203364:	0009e797          	auipc	a5,0x9e
ffffffffc0203368:	05478793          	addi	a5,a5,84 # ffffffffc02a13b8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020336c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020336e:	000a9697          	auipc	a3,0xa9
ffffffffc0203372:	4cf6b123          	sd	a5,1218(a3) # ffffffffc02ac830 <sm>
     int r = sm->init();
ffffffffc0203376:	9702                	jalr	a4
ffffffffc0203378:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc020337a:	c10d                	beqz	a0,ffffffffc020339c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020337c:	60ea                	ld	ra,152(sp)
ffffffffc020337e:	644a                	ld	s0,144(sp)
ffffffffc0203380:	8556                	mv	a0,s5
ffffffffc0203382:	64aa                	ld	s1,136(sp)
ffffffffc0203384:	690a                	ld	s2,128(sp)
ffffffffc0203386:	79e6                	ld	s3,120(sp)
ffffffffc0203388:	7a46                	ld	s4,112(sp)
ffffffffc020338a:	7aa6                	ld	s5,104(sp)
ffffffffc020338c:	7b06                	ld	s6,96(sp)
ffffffffc020338e:	6be6                	ld	s7,88(sp)
ffffffffc0203390:	6c46                	ld	s8,80(sp)
ffffffffc0203392:	6ca6                	ld	s9,72(sp)
ffffffffc0203394:	6d06                	ld	s10,64(sp)
ffffffffc0203396:	7de2                	ld	s11,56(sp)
ffffffffc0203398:	610d                	addi	sp,sp,160
ffffffffc020339a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020339c:	000a9797          	auipc	a5,0xa9
ffffffffc02033a0:	49478793          	addi	a5,a5,1172 # ffffffffc02ac830 <sm>
ffffffffc02033a4:	639c                	ld	a5,0(a5)
ffffffffc02033a6:	00004517          	auipc	a0,0x4
ffffffffc02033aa:	47250513          	addi	a0,a0,1138 # ffffffffc0207818 <default_pmm_manager+0x760>
    return listelm->next;
ffffffffc02033ae:	000a9417          	auipc	s0,0xa9
ffffffffc02033b2:	4ba40413          	addi	s0,s0,1210 # ffffffffc02ac868 <free_area>
ffffffffc02033b6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02033b8:	4785                	li	a5,1
ffffffffc02033ba:	000a9717          	auipc	a4,0xa9
ffffffffc02033be:	46f72f23          	sw	a5,1150(a4) # ffffffffc02ac838 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033c2:	dcdfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02033c6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033c8:	36878e63          	beq	a5,s0,ffffffffc0203744 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02033cc:	ff07b703          	ld	a4,-16(a5)
ffffffffc02033d0:	8305                	srli	a4,a4,0x1
ffffffffc02033d2:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02033d4:	36070c63          	beqz	a4,ffffffffc020374c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02033d8:	4481                	li	s1,0
ffffffffc02033da:	4901                	li	s2,0
ffffffffc02033dc:	a031                	j	ffffffffc02033e8 <swap_init+0xbc>
ffffffffc02033de:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02033e2:	8b09                	andi	a4,a4,2
ffffffffc02033e4:	36070463          	beqz	a4,ffffffffc020374c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc02033e8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033ec:	679c                	ld	a5,8(a5)
ffffffffc02033ee:	2905                	addiw	s2,s2,1
ffffffffc02033f0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033f2:	fe8796e3          	bne	a5,s0,ffffffffc02033de <swap_init+0xb2>
ffffffffc02033f6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02033f8:	ad7fe0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc02033fc:	69351863          	bne	a0,s3,ffffffffc0203a8c <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203400:	8626                	mv	a2,s1
ffffffffc0203402:	85ca                	mv	a1,s2
ffffffffc0203404:	00004517          	auipc	a0,0x4
ffffffffc0203408:	42c50513          	addi	a0,a0,1068 # ffffffffc0207830 <default_pmm_manager+0x778>
ffffffffc020340c:	d83fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203410:	3dd000ef          	jal	ra,ffffffffc0203fec <mm_create>
ffffffffc0203414:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203416:	60050b63          	beqz	a0,ffffffffc0203a2c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020341a:	000a9797          	auipc	a5,0xa9
ffffffffc020341e:	55e78793          	addi	a5,a5,1374 # ffffffffc02ac978 <check_mm_struct>
ffffffffc0203422:	639c                	ld	a5,0(a5)
ffffffffc0203424:	62079463          	bnez	a5,ffffffffc0203a4c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203428:	000a9797          	auipc	a5,0xa9
ffffffffc020342c:	3f878793          	addi	a5,a5,1016 # ffffffffc02ac820 <boot_pgdir>
ffffffffc0203430:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203434:	000a9797          	auipc	a5,0xa9
ffffffffc0203438:	54a7b223          	sd	a0,1348(a5) # ffffffffc02ac978 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020343c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75538>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203440:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203444:	4e079863          	bnez	a5,ffffffffc0203934 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203448:	6599                	lui	a1,0x6
ffffffffc020344a:	460d                	li	a2,3
ffffffffc020344c:	6505                	lui	a0,0x1
ffffffffc020344e:	3eb000ef          	jal	ra,ffffffffc0204038 <vma_create>
ffffffffc0203452:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203454:	50050063          	beqz	a0,ffffffffc0203954 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0203458:	855e                	mv	a0,s7
ffffffffc020345a:	44b000ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020345e:	00004517          	auipc	a0,0x4
ffffffffc0203462:	44250513          	addi	a0,a0,1090 # ffffffffc02078a0 <default_pmm_manager+0x7e8>
ffffffffc0203466:	d29fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020346a:	018bb503          	ld	a0,24(s7)
ffffffffc020346e:	4605                	li	a2,1
ffffffffc0203470:	6585                	lui	a1,0x1
ffffffffc0203472:	a9dfe0ef          	jal	ra,ffffffffc0201f0e <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203476:	4e050f63          	beqz	a0,ffffffffc0203974 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020347a:	00004517          	auipc	a0,0x4
ffffffffc020347e:	47650513          	addi	a0,a0,1142 # ffffffffc02078f0 <default_pmm_manager+0x838>
ffffffffc0203482:	000a9997          	auipc	s3,0xa9
ffffffffc0203486:	41e98993          	addi	s3,s3,1054 # ffffffffc02ac8a0 <check_rp>
ffffffffc020348a:	d05fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020348e:	000a9a17          	auipc	s4,0xa9
ffffffffc0203492:	432a0a13          	addi	s4,s4,1074 # ffffffffc02ac8c0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203496:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203498:	4505                	li	a0,1
ffffffffc020349a:	967fe0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc020349e:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034a2:	32050d63          	beqz	a0,ffffffffc02037dc <swap_init+0x4b0>
ffffffffc02034a6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034a8:	8b89                	andi	a5,a5,2
ffffffffc02034aa:	30079963          	bnez	a5,ffffffffc02037bc <swap_init+0x490>
ffffffffc02034ae:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034b0:	ff4c14e3          	bne	s8,s4,ffffffffc0203498 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02034b4:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02034b6:	000a9c17          	auipc	s8,0xa9
ffffffffc02034ba:	3eac0c13          	addi	s8,s8,1002 # ffffffffc02ac8a0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02034be:	ec3e                	sd	a5,24(sp)
ffffffffc02034c0:	641c                	ld	a5,8(s0)
ffffffffc02034c2:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02034c4:	481c                	lw	a5,16(s0)
ffffffffc02034c6:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02034c8:	000a9797          	auipc	a5,0xa9
ffffffffc02034cc:	3a87b423          	sd	s0,936(a5) # ffffffffc02ac870 <free_area+0x8>
ffffffffc02034d0:	000a9797          	auipc	a5,0xa9
ffffffffc02034d4:	3887bc23          	sd	s0,920(a5) # ffffffffc02ac868 <free_area>
     nr_free = 0;
ffffffffc02034d8:	000a9797          	auipc	a5,0xa9
ffffffffc02034dc:	3a07a023          	sw	zero,928(a5) # ffffffffc02ac878 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02034e0:	000c3503          	ld	a0,0(s8)
ffffffffc02034e4:	4585                	li	a1,1
ffffffffc02034e6:	0c21                	addi	s8,s8,8
ffffffffc02034e8:	9a1fe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034ec:	ff4c1ae3          	bne	s8,s4,ffffffffc02034e0 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02034f0:	01042c03          	lw	s8,16(s0)
ffffffffc02034f4:	4791                	li	a5,4
ffffffffc02034f6:	50fc1b63          	bne	s8,a5,ffffffffc0203a0c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02034fa:	00004517          	auipc	a0,0x4
ffffffffc02034fe:	47e50513          	addi	a0,a0,1150 # ffffffffc0207978 <default_pmm_manager+0x8c0>
ffffffffc0203502:	c8dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203506:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203508:	000a9797          	auipc	a5,0xa9
ffffffffc020350c:	3207aa23          	sw	zero,820(a5) # ffffffffc02ac83c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203510:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203512:	000a9797          	auipc	a5,0xa9
ffffffffc0203516:	32a78793          	addi	a5,a5,810 # ffffffffc02ac83c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020351a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc020351e:	4398                	lw	a4,0(a5)
ffffffffc0203520:	4585                	li	a1,1
ffffffffc0203522:	2701                	sext.w	a4,a4
ffffffffc0203524:	38b71863          	bne	a4,a1,ffffffffc02038b4 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203528:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020352c:	4394                	lw	a3,0(a5)
ffffffffc020352e:	2681                	sext.w	a3,a3
ffffffffc0203530:	3ae69263          	bne	a3,a4,ffffffffc02038d4 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203534:	6689                	lui	a3,0x2
ffffffffc0203536:	462d                	li	a2,11
ffffffffc0203538:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc020353c:	4398                	lw	a4,0(a5)
ffffffffc020353e:	4589                	li	a1,2
ffffffffc0203540:	2701                	sext.w	a4,a4
ffffffffc0203542:	2eb71963          	bne	a4,a1,ffffffffc0203834 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203546:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020354a:	4394                	lw	a3,0(a5)
ffffffffc020354c:	2681                	sext.w	a3,a3
ffffffffc020354e:	30e69363          	bne	a3,a4,ffffffffc0203854 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203552:	668d                	lui	a3,0x3
ffffffffc0203554:	4631                	li	a2,12
ffffffffc0203556:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc020355a:	4398                	lw	a4,0(a5)
ffffffffc020355c:	458d                	li	a1,3
ffffffffc020355e:	2701                	sext.w	a4,a4
ffffffffc0203560:	30b71a63          	bne	a4,a1,ffffffffc0203874 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203564:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203568:	4394                	lw	a3,0(a5)
ffffffffc020356a:	2681                	sext.w	a3,a3
ffffffffc020356c:	32e69463          	bne	a3,a4,ffffffffc0203894 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203570:	6691                	lui	a3,0x4
ffffffffc0203572:	4635                	li	a2,13
ffffffffc0203574:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc0203578:	4398                	lw	a4,0(a5)
ffffffffc020357a:	2701                	sext.w	a4,a4
ffffffffc020357c:	37871c63          	bne	a4,s8,ffffffffc02038f4 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203580:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203584:	439c                	lw	a5,0(a5)
ffffffffc0203586:	2781                	sext.w	a5,a5
ffffffffc0203588:	38e79663          	bne	a5,a4,ffffffffc0203914 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020358c:	481c                	lw	a5,16(s0)
ffffffffc020358e:	40079363          	bnez	a5,ffffffffc0203994 <swap_init+0x668>
ffffffffc0203592:	000a9797          	auipc	a5,0xa9
ffffffffc0203596:	32e78793          	addi	a5,a5,814 # ffffffffc02ac8c0 <swap_in_seq_no>
ffffffffc020359a:	000a9717          	auipc	a4,0xa9
ffffffffc020359e:	34e70713          	addi	a4,a4,846 # ffffffffc02ac8e8 <swap_out_seq_no>
ffffffffc02035a2:	000a9617          	auipc	a2,0xa9
ffffffffc02035a6:	34660613          	addi	a2,a2,838 # ffffffffc02ac8e8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035aa:	56fd                	li	a3,-1
ffffffffc02035ac:	c394                	sw	a3,0(a5)
ffffffffc02035ae:	c314                	sw	a3,0(a4)
ffffffffc02035b0:	0791                	addi	a5,a5,4
ffffffffc02035b2:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02035b4:	fef61ce3          	bne	a2,a5,ffffffffc02035ac <swap_init+0x280>
ffffffffc02035b8:	000a9697          	auipc	a3,0xa9
ffffffffc02035bc:	39068693          	addi	a3,a3,912 # ffffffffc02ac948 <check_ptep>
ffffffffc02035c0:	000a9817          	auipc	a6,0xa9
ffffffffc02035c4:	2e080813          	addi	a6,a6,736 # ffffffffc02ac8a0 <check_rp>
ffffffffc02035c8:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02035ca:	000a9c97          	auipc	s9,0xa9
ffffffffc02035ce:	25ec8c93          	addi	s9,s9,606 # ffffffffc02ac828 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02035d2:	00005d97          	auipc	s11,0x5
ffffffffc02035d6:	40ed8d93          	addi	s11,s11,1038 # ffffffffc02089e0 <nbase>
ffffffffc02035da:	000a9c17          	auipc	s8,0xa9
ffffffffc02035de:	2bec0c13          	addi	s8,s8,702 # ffffffffc02ac898 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02035e2:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035e6:	4601                	li	a2,0
ffffffffc02035e8:	85ea                	mv	a1,s10
ffffffffc02035ea:	855a                	mv	a0,s6
ffffffffc02035ec:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02035ee:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035f0:	91ffe0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc02035f4:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02035f6:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035f8:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02035fa:	20050163          	beqz	a0,ffffffffc02037fc <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02035fe:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203600:	0017f613          	andi	a2,a5,1
ffffffffc0203604:	1a060063          	beqz	a2,ffffffffc02037a4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203608:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020360c:	078a                	slli	a5,a5,0x2
ffffffffc020360e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203610:	14c7fe63          	bgeu	a5,a2,ffffffffc020376c <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203614:	000db703          	ld	a4,0(s11)
ffffffffc0203618:	000c3603          	ld	a2,0(s8)
ffffffffc020361c:	00083583          	ld	a1,0(a6)
ffffffffc0203620:	8f99                	sub	a5,a5,a4
ffffffffc0203622:	079a                	slli	a5,a5,0x6
ffffffffc0203624:	e43a                	sd	a4,8(sp)
ffffffffc0203626:	97b2                	add	a5,a5,a2
ffffffffc0203628:	14f59e63          	bne	a1,a5,ffffffffc0203784 <swap_init+0x458>
ffffffffc020362c:	6785                	lui	a5,0x1
ffffffffc020362e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203630:	6795                	lui	a5,0x5
ffffffffc0203632:	06a1                	addi	a3,a3,8
ffffffffc0203634:	0821                	addi	a6,a6,8
ffffffffc0203636:	fafd16e3          	bne	s10,a5,ffffffffc02035e2 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020363a:	00004517          	auipc	a0,0x4
ffffffffc020363e:	3e650513          	addi	a0,a0,998 # ffffffffc0207a20 <default_pmm_manager+0x968>
ffffffffc0203642:	b4dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203646:	000a9797          	auipc	a5,0xa9
ffffffffc020364a:	1ea78793          	addi	a5,a5,490 # ffffffffc02ac830 <sm>
ffffffffc020364e:	639c                	ld	a5,0(a5)
ffffffffc0203650:	7f9c                	ld	a5,56(a5)
ffffffffc0203652:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203654:	40051c63          	bnez	a0,ffffffffc0203a6c <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203658:	77a2                	ld	a5,40(sp)
ffffffffc020365a:	000a9717          	auipc	a4,0xa9
ffffffffc020365e:	20f72f23          	sw	a5,542(a4) # ffffffffc02ac878 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203662:	67e2                	ld	a5,24(sp)
ffffffffc0203664:	000a9717          	auipc	a4,0xa9
ffffffffc0203668:	20f73223          	sd	a5,516(a4) # ffffffffc02ac868 <free_area>
ffffffffc020366c:	7782                	ld	a5,32(sp)
ffffffffc020366e:	000a9717          	auipc	a4,0xa9
ffffffffc0203672:	20f73123          	sd	a5,514(a4) # ffffffffc02ac870 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203676:	0009b503          	ld	a0,0(s3)
ffffffffc020367a:	4585                	li	a1,1
ffffffffc020367c:	09a1                	addi	s3,s3,8
ffffffffc020367e:	80bfe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203682:	ff499ae3          	bne	s3,s4,ffffffffc0203676 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203686:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc020368a:	855e                	mv	a0,s7
ffffffffc020368c:	2e7000ef          	jal	ra,ffffffffc0204172 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203690:	000a9797          	auipc	a5,0xa9
ffffffffc0203694:	19078793          	addi	a5,a5,400 # ffffffffc02ac820 <boot_pgdir>
ffffffffc0203698:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc020369a:	000a9697          	auipc	a3,0xa9
ffffffffc020369e:	2c06bf23          	sd	zero,734(a3) # ffffffffc02ac978 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036a2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036a6:	6394                	ld	a3,0(a5)
ffffffffc02036a8:	068a                	slli	a3,a3,0x2
ffffffffc02036aa:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ac:	0ce6f063          	bgeu	a3,a4,ffffffffc020376c <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036b0:	67a2                	ld	a5,8(sp)
ffffffffc02036b2:	000c3503          	ld	a0,0(s8)
ffffffffc02036b6:	8e9d                	sub	a3,a3,a5
ffffffffc02036b8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02036ba:	8699                	srai	a3,a3,0x6
ffffffffc02036bc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02036be:	00c69793          	slli	a5,a3,0xc
ffffffffc02036c2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02036c6:	2ee7f763          	bgeu	a5,a4,ffffffffc02039b4 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02036ca:	000a9797          	auipc	a5,0xa9
ffffffffc02036ce:	1be78793          	addi	a5,a5,446 # ffffffffc02ac888 <va_pa_offset>
ffffffffc02036d2:	639c                	ld	a5,0(a5)
ffffffffc02036d4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02036d6:	629c                	ld	a5,0(a3)
ffffffffc02036d8:	078a                	slli	a5,a5,0x2
ffffffffc02036da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036dc:	08e7f863          	bgeu	a5,a4,ffffffffc020376c <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036e0:	69a2                	ld	s3,8(sp)
ffffffffc02036e2:	4585                	li	a1,1
ffffffffc02036e4:	413787b3          	sub	a5,a5,s3
ffffffffc02036e8:	079a                	slli	a5,a5,0x6
ffffffffc02036ea:	953e                	add	a0,a0,a5
ffffffffc02036ec:	f9cfe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02036f4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f8:	078a                	slli	a5,a5,0x2
ffffffffc02036fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	06e7f863          	bgeu	a5,a4,ffffffffc020376c <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203700:	000c3503          	ld	a0,0(s8)
ffffffffc0203704:	413787b3          	sub	a5,a5,s3
ffffffffc0203708:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020370a:	4585                	li	a1,1
ffffffffc020370c:	953e                	add	a0,a0,a5
ffffffffc020370e:	f7afe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
     pgdir[0] = 0;
ffffffffc0203712:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203716:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020371a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020371c:	00878963          	beq	a5,s0,ffffffffc020372e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203720:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203724:	679c                	ld	a5,8(a5)
ffffffffc0203726:	397d                	addiw	s2,s2,-1
ffffffffc0203728:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020372a:	fe879be3          	bne	a5,s0,ffffffffc0203720 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020372e:	28091f63          	bnez	s2,ffffffffc02039cc <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203732:	2a049d63          	bnez	s1,ffffffffc02039ec <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203736:	00004517          	auipc	a0,0x4
ffffffffc020373a:	33a50513          	addi	a0,a0,826 # ffffffffc0207a70 <default_pmm_manager+0x9b8>
ffffffffc020373e:	a51fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203742:	b92d                	j	ffffffffc020337c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203744:	4481                	li	s1,0
ffffffffc0203746:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203748:	4981                	li	s3,0
ffffffffc020374a:	b17d                	j	ffffffffc02033f8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020374c:	00003697          	auipc	a3,0x3
ffffffffc0203750:	5dc68693          	addi	a3,a3,1500 # ffffffffc0206d28 <commands+0x878>
ffffffffc0203754:	00003617          	auipc	a2,0x3
ffffffffc0203758:	21c60613          	addi	a2,a2,540 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020375c:	0bc00593          	li	a1,188
ffffffffc0203760:	00004517          	auipc	a0,0x4
ffffffffc0203764:	0a850513          	addi	a0,a0,168 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203768:	d19fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020376c:	00004617          	auipc	a2,0x4
ffffffffc0203770:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0203774:	06200593          	li	a1,98
ffffffffc0203778:	00004517          	auipc	a0,0x4
ffffffffc020377c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0203780:	d01fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203784:	00004697          	auipc	a3,0x4
ffffffffc0203788:	27468693          	addi	a3,a3,628 # ffffffffc02079f8 <default_pmm_manager+0x940>
ffffffffc020378c:	00003617          	auipc	a2,0x3
ffffffffc0203790:	1e460613          	addi	a2,a2,484 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203794:	0fc00593          	li	a1,252
ffffffffc0203798:	00004517          	auipc	a0,0x4
ffffffffc020379c:	07050513          	addi	a0,a0,112 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02037a0:	ce1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037a4:	00004617          	auipc	a2,0x4
ffffffffc02037a8:	c1c60613          	addi	a2,a2,-996 # ffffffffc02073c0 <default_pmm_manager+0x308>
ffffffffc02037ac:	07400593          	li	a1,116
ffffffffc02037b0:	00004517          	auipc	a0,0x4
ffffffffc02037b4:	98050513          	addi	a0,a0,-1664 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc02037b8:	cc9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02037bc:	00004697          	auipc	a3,0x4
ffffffffc02037c0:	17468693          	addi	a3,a3,372 # ffffffffc0207930 <default_pmm_manager+0x878>
ffffffffc02037c4:	00003617          	auipc	a2,0x3
ffffffffc02037c8:	1ac60613          	addi	a2,a2,428 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02037cc:	0dd00593          	li	a1,221
ffffffffc02037d0:	00004517          	auipc	a0,0x4
ffffffffc02037d4:	03850513          	addi	a0,a0,56 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02037d8:	ca9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02037dc:	00004697          	auipc	a3,0x4
ffffffffc02037e0:	13c68693          	addi	a3,a3,316 # ffffffffc0207918 <default_pmm_manager+0x860>
ffffffffc02037e4:	00003617          	auipc	a2,0x3
ffffffffc02037e8:	18c60613          	addi	a2,a2,396 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02037ec:	0dc00593          	li	a1,220
ffffffffc02037f0:	00004517          	auipc	a0,0x4
ffffffffc02037f4:	01850513          	addi	a0,a0,24 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02037f8:	c89fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02037fc:	00004697          	auipc	a3,0x4
ffffffffc0203800:	1e468693          	addi	a3,a3,484 # ffffffffc02079e0 <default_pmm_manager+0x928>
ffffffffc0203804:	00003617          	auipc	a2,0x3
ffffffffc0203808:	16c60613          	addi	a2,a2,364 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020380c:	0fb00593          	li	a1,251
ffffffffc0203810:	00004517          	auipc	a0,0x4
ffffffffc0203814:	ff850513          	addi	a0,a0,-8 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203818:	c69fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020381c:	00004617          	auipc	a2,0x4
ffffffffc0203820:	fcc60613          	addi	a2,a2,-52 # ffffffffc02077e8 <default_pmm_manager+0x730>
ffffffffc0203824:	02800593          	li	a1,40
ffffffffc0203828:	00004517          	auipc	a0,0x4
ffffffffc020382c:	fe050513          	addi	a0,a0,-32 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203830:	c51fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc0203834:	00004697          	auipc	a3,0x4
ffffffffc0203838:	17c68693          	addi	a3,a3,380 # ffffffffc02079b0 <default_pmm_manager+0x8f8>
ffffffffc020383c:	00003617          	auipc	a2,0x3
ffffffffc0203840:	13460613          	addi	a2,a2,308 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203844:	09700593          	li	a1,151
ffffffffc0203848:	00004517          	auipc	a0,0x4
ffffffffc020384c:	fc050513          	addi	a0,a0,-64 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203850:	c31fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc0203854:	00004697          	auipc	a3,0x4
ffffffffc0203858:	15c68693          	addi	a3,a3,348 # ffffffffc02079b0 <default_pmm_manager+0x8f8>
ffffffffc020385c:	00003617          	auipc	a2,0x3
ffffffffc0203860:	11460613          	addi	a2,a2,276 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203864:	09900593          	li	a1,153
ffffffffc0203868:	00004517          	auipc	a0,0x4
ffffffffc020386c:	fa050513          	addi	a0,a0,-96 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203870:	c11fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc0203874:	00004697          	auipc	a3,0x4
ffffffffc0203878:	14c68693          	addi	a3,a3,332 # ffffffffc02079c0 <default_pmm_manager+0x908>
ffffffffc020387c:	00003617          	auipc	a2,0x3
ffffffffc0203880:	0f460613          	addi	a2,a2,244 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203884:	09b00593          	li	a1,155
ffffffffc0203888:	00004517          	auipc	a0,0x4
ffffffffc020388c:	f8050513          	addi	a0,a0,-128 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203890:	bf1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc0203894:	00004697          	auipc	a3,0x4
ffffffffc0203898:	12c68693          	addi	a3,a3,300 # ffffffffc02079c0 <default_pmm_manager+0x908>
ffffffffc020389c:	00003617          	auipc	a2,0x3
ffffffffc02038a0:	0d460613          	addi	a2,a2,212 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02038a4:	09d00593          	li	a1,157
ffffffffc02038a8:	00004517          	auipc	a0,0x4
ffffffffc02038ac:	f6050513          	addi	a0,a0,-160 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02038b0:	bd1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc02038b4:	00004697          	auipc	a3,0x4
ffffffffc02038b8:	0ec68693          	addi	a3,a3,236 # ffffffffc02079a0 <default_pmm_manager+0x8e8>
ffffffffc02038bc:	00003617          	auipc	a2,0x3
ffffffffc02038c0:	0b460613          	addi	a2,a2,180 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02038c4:	09300593          	li	a1,147
ffffffffc02038c8:	00004517          	auipc	a0,0x4
ffffffffc02038cc:	f4050513          	addi	a0,a0,-192 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02038d0:	bb1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc02038d4:	00004697          	auipc	a3,0x4
ffffffffc02038d8:	0cc68693          	addi	a3,a3,204 # ffffffffc02079a0 <default_pmm_manager+0x8e8>
ffffffffc02038dc:	00003617          	auipc	a2,0x3
ffffffffc02038e0:	09460613          	addi	a2,a2,148 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02038e4:	09500593          	li	a1,149
ffffffffc02038e8:	00004517          	auipc	a0,0x4
ffffffffc02038ec:	f2050513          	addi	a0,a0,-224 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02038f0:	b91fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc02038f4:	00004697          	auipc	a3,0x4
ffffffffc02038f8:	0dc68693          	addi	a3,a3,220 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc02038fc:	00003617          	auipc	a2,0x3
ffffffffc0203900:	07460613          	addi	a2,a2,116 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203904:	09f00593          	li	a1,159
ffffffffc0203908:	00004517          	auipc	a0,0x4
ffffffffc020390c:	f0050513          	addi	a0,a0,-256 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203910:	b71fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203914:	00004697          	auipc	a3,0x4
ffffffffc0203918:	0bc68693          	addi	a3,a3,188 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc020391c:	00003617          	auipc	a2,0x3
ffffffffc0203920:	05460613          	addi	a2,a2,84 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203924:	0a100593          	li	a1,161
ffffffffc0203928:	00004517          	auipc	a0,0x4
ffffffffc020392c:	ee050513          	addi	a0,a0,-288 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203930:	b51fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203934:	00004697          	auipc	a3,0x4
ffffffffc0203938:	f4c68693          	addi	a3,a3,-180 # ffffffffc0207880 <default_pmm_manager+0x7c8>
ffffffffc020393c:	00003617          	auipc	a2,0x3
ffffffffc0203940:	03460613          	addi	a2,a2,52 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203944:	0cc00593          	li	a1,204
ffffffffc0203948:	00004517          	auipc	a0,0x4
ffffffffc020394c:	ec050513          	addi	a0,a0,-320 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203950:	b31fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(vma != NULL);
ffffffffc0203954:	00004697          	auipc	a3,0x4
ffffffffc0203958:	f3c68693          	addi	a3,a3,-196 # ffffffffc0207890 <default_pmm_manager+0x7d8>
ffffffffc020395c:	00003617          	auipc	a2,0x3
ffffffffc0203960:	01460613          	addi	a2,a2,20 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203964:	0cf00593          	li	a1,207
ffffffffc0203968:	00004517          	auipc	a0,0x4
ffffffffc020396c:	ea050513          	addi	a0,a0,-352 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203970:	b11fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203974:	00004697          	auipc	a3,0x4
ffffffffc0203978:	f6468693          	addi	a3,a3,-156 # ffffffffc02078d8 <default_pmm_manager+0x820>
ffffffffc020397c:	00003617          	auipc	a2,0x3
ffffffffc0203980:	ff460613          	addi	a2,a2,-12 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203984:	0d700593          	li	a1,215
ffffffffc0203988:	00004517          	auipc	a0,0x4
ffffffffc020398c:	e8050513          	addi	a0,a0,-384 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203990:	af1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert( nr_free == 0);         
ffffffffc0203994:	00003697          	auipc	a3,0x3
ffffffffc0203998:	56468693          	addi	a3,a3,1380 # ffffffffc0206ef8 <commands+0xa48>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	fd460613          	addi	a2,a2,-44 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02039a4:	0f300593          	li	a1,243
ffffffffc02039a8:	00004517          	auipc	a0,0x4
ffffffffc02039ac:	e6050513          	addi	a0,a0,-416 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02039b0:	ad1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc02039b4:	00003617          	auipc	a2,0x3
ffffffffc02039b8:	75460613          	addi	a2,a2,1876 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc02039bc:	06900593          	li	a1,105
ffffffffc02039c0:	00003517          	auipc	a0,0x3
ffffffffc02039c4:	77050513          	addi	a0,a0,1904 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc02039c8:	ab9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(count==0);
ffffffffc02039cc:	00004697          	auipc	a3,0x4
ffffffffc02039d0:	08468693          	addi	a3,a3,132 # ffffffffc0207a50 <default_pmm_manager+0x998>
ffffffffc02039d4:	00003617          	auipc	a2,0x3
ffffffffc02039d8:	f9c60613          	addi	a2,a2,-100 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02039dc:	11d00593          	li	a1,285
ffffffffc02039e0:	00004517          	auipc	a0,0x4
ffffffffc02039e4:	e2850513          	addi	a0,a0,-472 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc02039e8:	a99fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total==0);
ffffffffc02039ec:	00004697          	auipc	a3,0x4
ffffffffc02039f0:	07468693          	addi	a3,a3,116 # ffffffffc0207a60 <default_pmm_manager+0x9a8>
ffffffffc02039f4:	00003617          	auipc	a2,0x3
ffffffffc02039f8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02039fc:	11e00593          	li	a1,286
ffffffffc0203a00:	00004517          	auipc	a0,0x4
ffffffffc0203a04:	e0850513          	addi	a0,a0,-504 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203a08:	a79fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a0c:	00004697          	auipc	a3,0x4
ffffffffc0203a10:	f4468693          	addi	a3,a3,-188 # ffffffffc0207950 <default_pmm_manager+0x898>
ffffffffc0203a14:	00003617          	auipc	a2,0x3
ffffffffc0203a18:	f5c60613          	addi	a2,a2,-164 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203a1c:	0ea00593          	li	a1,234
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	de850513          	addi	a0,a0,-536 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203a28:	a59fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(mm != NULL);
ffffffffc0203a2c:	00004697          	auipc	a3,0x4
ffffffffc0203a30:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207858 <default_pmm_manager+0x7a0>
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	f3c60613          	addi	a2,a2,-196 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203a3c:	0c400593          	li	a1,196
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	dc850513          	addi	a0,a0,-568 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203a48:	a39fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	e1c68693          	addi	a3,a3,-484 # ffffffffc0207868 <default_pmm_manager+0x7b0>
ffffffffc0203a54:	00003617          	auipc	a2,0x3
ffffffffc0203a58:	f1c60613          	addi	a2,a2,-228 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203a5c:	0c700593          	li	a1,199
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	da850513          	addi	a0,a0,-600 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203a68:	a19fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(ret==0);
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	fdc68693          	addi	a3,a3,-36 # ffffffffc0207a48 <default_pmm_manager+0x990>
ffffffffc0203a74:	00003617          	auipc	a2,0x3
ffffffffc0203a78:	efc60613          	addi	a2,a2,-260 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203a7c:	10200593          	li	a1,258
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	d8850513          	addi	a0,a0,-632 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203a88:	9f9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203a8c:	00003697          	auipc	a3,0x3
ffffffffc0203a90:	2c468693          	addi	a3,a3,708 # ffffffffc0206d50 <commands+0x8a0>
ffffffffc0203a94:	00003617          	auipc	a2,0x3
ffffffffc0203a98:	edc60613          	addi	a2,a2,-292 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203a9c:	0bf00593          	li	a1,191
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	d6850513          	addi	a0,a0,-664 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203aa8:	9d9fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203aac <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203aac:	000a9797          	auipc	a5,0xa9
ffffffffc0203ab0:	d8478793          	addi	a5,a5,-636 # ffffffffc02ac830 <sm>
ffffffffc0203ab4:	639c                	ld	a5,0(a5)
ffffffffc0203ab6:	0107b303          	ld	t1,16(a5)
ffffffffc0203aba:	8302                	jr	t1

ffffffffc0203abc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203abc:	000a9797          	auipc	a5,0xa9
ffffffffc0203ac0:	d7478793          	addi	a5,a5,-652 # ffffffffc02ac830 <sm>
ffffffffc0203ac4:	639c                	ld	a5,0(a5)
ffffffffc0203ac6:	0207b303          	ld	t1,32(a5)
ffffffffc0203aca:	8302                	jr	t1

ffffffffc0203acc <swap_out>:
{
ffffffffc0203acc:	711d                	addi	sp,sp,-96
ffffffffc0203ace:	ec86                	sd	ra,88(sp)
ffffffffc0203ad0:	e8a2                	sd	s0,80(sp)
ffffffffc0203ad2:	e4a6                	sd	s1,72(sp)
ffffffffc0203ad4:	e0ca                	sd	s2,64(sp)
ffffffffc0203ad6:	fc4e                	sd	s3,56(sp)
ffffffffc0203ad8:	f852                	sd	s4,48(sp)
ffffffffc0203ada:	f456                	sd	s5,40(sp)
ffffffffc0203adc:	f05a                	sd	s6,32(sp)
ffffffffc0203ade:	ec5e                	sd	s7,24(sp)
ffffffffc0203ae0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203ae2:	cde9                	beqz	a1,ffffffffc0203bbc <swap_out+0xf0>
ffffffffc0203ae4:	8ab2                	mv	s5,a2
ffffffffc0203ae6:	892a                	mv	s2,a0
ffffffffc0203ae8:	8a2e                	mv	s4,a1
ffffffffc0203aea:	4401                	li	s0,0
ffffffffc0203aec:	000a9997          	auipc	s3,0xa9
ffffffffc0203af0:	d4498993          	addi	s3,s3,-700 # ffffffffc02ac830 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203af4:	00004b17          	auipc	s6,0x4
ffffffffc0203af8:	ffcb0b13          	addi	s6,s6,-4 # ffffffffc0207af0 <default_pmm_manager+0xa38>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203afc:	00004b97          	auipc	s7,0x4
ffffffffc0203b00:	fdcb8b93          	addi	s7,s7,-36 # ffffffffc0207ad8 <default_pmm_manager+0xa20>
ffffffffc0203b04:	a825                	j	ffffffffc0203b3c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b06:	67a2                	ld	a5,8(sp)
ffffffffc0203b08:	8626                	mv	a2,s1
ffffffffc0203b0a:	85a2                	mv	a1,s0
ffffffffc0203b0c:	7f94                	ld	a3,56(a5)
ffffffffc0203b0e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b10:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b12:	82b1                	srli	a3,a3,0xc
ffffffffc0203b14:	0685                	addi	a3,a3,1
ffffffffc0203b16:	e78fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b1a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b1c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b1e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b20:	83b1                	srli	a5,a5,0xc
ffffffffc0203b22:	0785                	addi	a5,a5,1
ffffffffc0203b24:	07a2                	slli	a5,a5,0x8
ffffffffc0203b26:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b2a:	b5efe0ef          	jal	ra,ffffffffc0201e88 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b2e:	01893503          	ld	a0,24(s2)
ffffffffc0203b32:	85a6                	mv	a1,s1
ffffffffc0203b34:	f5eff0ef          	jal	ra,ffffffffc0203292 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b38:	048a0d63          	beq	s4,s0,ffffffffc0203b92 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b3c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b40:	8656                	mv	a2,s5
ffffffffc0203b42:	002c                	addi	a1,sp,8
ffffffffc0203b44:	7b9c                	ld	a5,48(a5)
ffffffffc0203b46:	854a                	mv	a0,s2
ffffffffc0203b48:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b4a:	e12d                	bnez	a0,ffffffffc0203bac <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b4c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b4e:	01893503          	ld	a0,24(s2)
ffffffffc0203b52:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b54:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b56:	85a6                	mv	a1,s1
ffffffffc0203b58:	bb6fe0ef          	jal	ra,ffffffffc0201f0e <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b5c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b5e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b60:	8b85                	andi	a5,a5,1
ffffffffc0203b62:	cfb9                	beqz	a5,ffffffffc0203bc0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203b64:	65a2                	ld	a1,8(sp)
ffffffffc0203b66:	7d9c                	ld	a5,56(a1)
ffffffffc0203b68:	83b1                	srli	a5,a5,0xc
ffffffffc0203b6a:	00178513          	addi	a0,a5,1
ffffffffc0203b6e:	0522                	slli	a0,a0,0x8
ffffffffc0203b70:	6ed000ef          	jal	ra,ffffffffc0204a5c <swapfs_write>
ffffffffc0203b74:	d949                	beqz	a0,ffffffffc0203b06 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b76:	855e                	mv	a0,s7
ffffffffc0203b78:	e16fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b7c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b80:	6622                	ld	a2,8(sp)
ffffffffc0203b82:	4681                	li	a3,0
ffffffffc0203b84:	739c                	ld	a5,32(a5)
ffffffffc0203b86:	85a6                	mv	a1,s1
ffffffffc0203b88:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203b8a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b8c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203b8e:	fa8a17e3          	bne	s4,s0,ffffffffc0203b3c <swap_out+0x70>
}
ffffffffc0203b92:	8522                	mv	a0,s0
ffffffffc0203b94:	60e6                	ld	ra,88(sp)
ffffffffc0203b96:	6446                	ld	s0,80(sp)
ffffffffc0203b98:	64a6                	ld	s1,72(sp)
ffffffffc0203b9a:	6906                	ld	s2,64(sp)
ffffffffc0203b9c:	79e2                	ld	s3,56(sp)
ffffffffc0203b9e:	7a42                	ld	s4,48(sp)
ffffffffc0203ba0:	7aa2                	ld	s5,40(sp)
ffffffffc0203ba2:	7b02                	ld	s6,32(sp)
ffffffffc0203ba4:	6be2                	ld	s7,24(sp)
ffffffffc0203ba6:	6c42                	ld	s8,16(sp)
ffffffffc0203ba8:	6125                	addi	sp,sp,96
ffffffffc0203baa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bac:	85a2                	mv	a1,s0
ffffffffc0203bae:	00004517          	auipc	a0,0x4
ffffffffc0203bb2:	ee250513          	addi	a0,a0,-286 # ffffffffc0207a90 <default_pmm_manager+0x9d8>
ffffffffc0203bb6:	dd8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203bba:	bfe1                	j	ffffffffc0203b92 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203bbc:	4401                	li	s0,0
ffffffffc0203bbe:	bfd1                	j	ffffffffc0203b92 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bc0:	00004697          	auipc	a3,0x4
ffffffffc0203bc4:	f0068693          	addi	a3,a3,-256 # ffffffffc0207ac0 <default_pmm_manager+0xa08>
ffffffffc0203bc8:	00003617          	auipc	a2,0x3
ffffffffc0203bcc:	da860613          	addi	a2,a2,-600 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203bd0:	06800593          	li	a1,104
ffffffffc0203bd4:	00004517          	auipc	a0,0x4
ffffffffc0203bd8:	c3450513          	addi	a0,a0,-972 # ffffffffc0207808 <default_pmm_manager+0x750>
ffffffffc0203bdc:	8a5fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203be0 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203be0:	000a9797          	auipc	a5,0xa9
ffffffffc0203be4:	d8878793          	addi	a5,a5,-632 # ffffffffc02ac968 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203be8:	f51c                	sd	a5,40(a0)
ffffffffc0203bea:	e79c                	sd	a5,8(a5)
ffffffffc0203bec:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203bee:	4501                	li	a0,0
ffffffffc0203bf0:	8082                	ret

ffffffffc0203bf2 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203bf2:	4501                	li	a0,0
ffffffffc0203bf4:	8082                	ret

ffffffffc0203bf6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203bf6:	4501                	li	a0,0
ffffffffc0203bf8:	8082                	ret

ffffffffc0203bfa <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203bfa:	4501                	li	a0,0
ffffffffc0203bfc:	8082                	ret

ffffffffc0203bfe <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203bfe:	711d                	addi	sp,sp,-96
ffffffffc0203c00:	fc4e                	sd	s3,56(sp)
ffffffffc0203c02:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c04:	00004517          	auipc	a0,0x4
ffffffffc0203c08:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207b30 <default_pmm_manager+0xa78>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c0c:	698d                	lui	s3,0x3
ffffffffc0203c0e:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c10:	e8a2                	sd	s0,80(sp)
ffffffffc0203c12:	e4a6                	sd	s1,72(sp)
ffffffffc0203c14:	ec86                	sd	ra,88(sp)
ffffffffc0203c16:	e0ca                	sd	s2,64(sp)
ffffffffc0203c18:	f456                	sd	s5,40(sp)
ffffffffc0203c1a:	f05a                	sd	s6,32(sp)
ffffffffc0203c1c:	ec5e                	sd	s7,24(sp)
ffffffffc0203c1e:	e862                	sd	s8,16(sp)
ffffffffc0203c20:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c22:	000a9417          	auipc	s0,0xa9
ffffffffc0203c26:	c1a40413          	addi	s0,s0,-998 # ffffffffc02ac83c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c2a:	d64fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c2e:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0203c32:	4004                	lw	s1,0(s0)
ffffffffc0203c34:	4791                	li	a5,4
ffffffffc0203c36:	2481                	sext.w	s1,s1
ffffffffc0203c38:	14f49963          	bne	s1,a5,ffffffffc0203d8a <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c3c:	00004517          	auipc	a0,0x4
ffffffffc0203c40:	f3450513          	addi	a0,a0,-204 # ffffffffc0207b70 <default_pmm_manager+0xab8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c44:	6a85                	lui	s5,0x1
ffffffffc0203c46:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c48:	d46fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c4c:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0203c50:	00042903          	lw	s2,0(s0)
ffffffffc0203c54:	2901                	sext.w	s2,s2
ffffffffc0203c56:	2a991a63          	bne	s2,s1,ffffffffc0203f0a <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c5a:	00004517          	auipc	a0,0x4
ffffffffc0203c5e:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207b98 <default_pmm_manager+0xae0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c62:	6b91                	lui	s7,0x4
ffffffffc0203c64:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c66:	d28fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c6a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc0203c6e:	4004                	lw	s1,0(s0)
ffffffffc0203c70:	2481                	sext.w	s1,s1
ffffffffc0203c72:	27249c63          	bne	s1,s2,ffffffffc0203eea <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c76:	00004517          	auipc	a0,0x4
ffffffffc0203c7a:	f4a50513          	addi	a0,a0,-182 # ffffffffc0207bc0 <default_pmm_manager+0xb08>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c7e:	6909                	lui	s2,0x2
ffffffffc0203c80:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c82:	d0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c86:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc0203c8a:	401c                	lw	a5,0(s0)
ffffffffc0203c8c:	2781                	sext.w	a5,a5
ffffffffc0203c8e:	22979e63          	bne	a5,s1,ffffffffc0203eca <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203c92:	00004517          	auipc	a0,0x4
ffffffffc0203c96:	f5650513          	addi	a0,a0,-170 # ffffffffc0207be8 <default_pmm_manager+0xb30>
ffffffffc0203c9a:	cf4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203c9e:	6795                	lui	a5,0x5
ffffffffc0203ca0:	4739                	li	a4,14
ffffffffc0203ca2:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc0203ca6:	4004                	lw	s1,0(s0)
ffffffffc0203ca8:	4795                	li	a5,5
ffffffffc0203caa:	2481                	sext.w	s1,s1
ffffffffc0203cac:	1ef49f63          	bne	s1,a5,ffffffffc0203eaa <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cb0:	00004517          	auipc	a0,0x4
ffffffffc0203cb4:	f1050513          	addi	a0,a0,-240 # ffffffffc0207bc0 <default_pmm_manager+0xb08>
ffffffffc0203cb8:	cd6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cbc:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cc0:	401c                	lw	a5,0(s0)
ffffffffc0203cc2:	2781                	sext.w	a5,a5
ffffffffc0203cc4:	1c979363          	bne	a5,s1,ffffffffc0203e8a <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cc8:	00004517          	auipc	a0,0x4
ffffffffc0203ccc:	ea850513          	addi	a0,a0,-344 # ffffffffc0207b70 <default_pmm_manager+0xab8>
ffffffffc0203cd0:	cbefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203cd4:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203cd8:	401c                	lw	a5,0(s0)
ffffffffc0203cda:	4719                	li	a4,6
ffffffffc0203cdc:	2781                	sext.w	a5,a5
ffffffffc0203cde:	18e79663          	bne	a5,a4,ffffffffc0203e6a <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ce2:	00004517          	auipc	a0,0x4
ffffffffc0203ce6:	ede50513          	addi	a0,a0,-290 # ffffffffc0207bc0 <default_pmm_manager+0xb08>
ffffffffc0203cea:	ca4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cee:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203cf2:	401c                	lw	a5,0(s0)
ffffffffc0203cf4:	471d                	li	a4,7
ffffffffc0203cf6:	2781                	sext.w	a5,a5
ffffffffc0203cf8:	14e79963          	bne	a5,a4,ffffffffc0203e4a <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cfc:	00004517          	auipc	a0,0x4
ffffffffc0203d00:	e3450513          	addi	a0,a0,-460 # ffffffffc0207b30 <default_pmm_manager+0xa78>
ffffffffc0203d04:	c8afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d08:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d0c:	401c                	lw	a5,0(s0)
ffffffffc0203d0e:	4721                	li	a4,8
ffffffffc0203d10:	2781                	sext.w	a5,a5
ffffffffc0203d12:	10e79c63          	bne	a5,a4,ffffffffc0203e2a <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d16:	00004517          	auipc	a0,0x4
ffffffffc0203d1a:	e8250513          	addi	a0,a0,-382 # ffffffffc0207b98 <default_pmm_manager+0xae0>
ffffffffc0203d1e:	c70fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d22:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d26:	401c                	lw	a5,0(s0)
ffffffffc0203d28:	4725                	li	a4,9
ffffffffc0203d2a:	2781                	sext.w	a5,a5
ffffffffc0203d2c:	0ce79f63          	bne	a5,a4,ffffffffc0203e0a <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d30:	00004517          	auipc	a0,0x4
ffffffffc0203d34:	eb850513          	addi	a0,a0,-328 # ffffffffc0207be8 <default_pmm_manager+0xb30>
ffffffffc0203d38:	c56fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d3c:	6795                	lui	a5,0x5
ffffffffc0203d3e:	4739                	li	a4,14
ffffffffc0203d40:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0203d44:	4004                	lw	s1,0(s0)
ffffffffc0203d46:	47a9                	li	a5,10
ffffffffc0203d48:	2481                	sext.w	s1,s1
ffffffffc0203d4a:	0af49063          	bne	s1,a5,ffffffffc0203dea <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d4e:	00004517          	auipc	a0,0x4
ffffffffc0203d52:	e2250513          	addi	a0,a0,-478 # ffffffffc0207b70 <default_pmm_manager+0xab8>
ffffffffc0203d56:	c38fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d5a:	6785                	lui	a5,0x1
ffffffffc0203d5c:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0203d60:	06979563          	bne	a5,s1,ffffffffc0203dca <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203d64:	401c                	lw	a5,0(s0)
ffffffffc0203d66:	472d                	li	a4,11
ffffffffc0203d68:	2781                	sext.w	a5,a5
ffffffffc0203d6a:	04e79063          	bne	a5,a4,ffffffffc0203daa <_fifo_check_swap+0x1ac>
}
ffffffffc0203d6e:	60e6                	ld	ra,88(sp)
ffffffffc0203d70:	6446                	ld	s0,80(sp)
ffffffffc0203d72:	64a6                	ld	s1,72(sp)
ffffffffc0203d74:	6906                	ld	s2,64(sp)
ffffffffc0203d76:	79e2                	ld	s3,56(sp)
ffffffffc0203d78:	7a42                	ld	s4,48(sp)
ffffffffc0203d7a:	7aa2                	ld	s5,40(sp)
ffffffffc0203d7c:	7b02                	ld	s6,32(sp)
ffffffffc0203d7e:	6be2                	ld	s7,24(sp)
ffffffffc0203d80:	6c42                	ld	s8,16(sp)
ffffffffc0203d82:	6ca2                	ld	s9,8(sp)
ffffffffc0203d84:	4501                	li	a0,0
ffffffffc0203d86:	6125                	addi	sp,sp,96
ffffffffc0203d88:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203d8a:	00004697          	auipc	a3,0x4
ffffffffc0203d8e:	c4668693          	addi	a3,a3,-954 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc0203d92:	00003617          	auipc	a2,0x3
ffffffffc0203d96:	bde60613          	addi	a2,a2,-1058 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203d9a:	05100593          	li	a1,81
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	dba50513          	addi	a0,a0,-582 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203da6:	edafc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==11);
ffffffffc0203daa:	00004697          	auipc	a3,0x4
ffffffffc0203dae:	eee68693          	addi	a3,a3,-274 # ffffffffc0207c98 <default_pmm_manager+0xbe0>
ffffffffc0203db2:	00003617          	auipc	a2,0x3
ffffffffc0203db6:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203dba:	07300593          	li	a1,115
ffffffffc0203dbe:	00004517          	auipc	a0,0x4
ffffffffc0203dc2:	d9a50513          	addi	a0,a0,-614 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203dc6:	ebafc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203dca:	00004697          	auipc	a3,0x4
ffffffffc0203dce:	ea668693          	addi	a3,a3,-346 # ffffffffc0207c70 <default_pmm_manager+0xbb8>
ffffffffc0203dd2:	00003617          	auipc	a2,0x3
ffffffffc0203dd6:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203dda:	07100593          	li	a1,113
ffffffffc0203dde:	00004517          	auipc	a0,0x4
ffffffffc0203de2:	d7a50513          	addi	a0,a0,-646 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203de6:	e9afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==10);
ffffffffc0203dea:	00004697          	auipc	a3,0x4
ffffffffc0203dee:	e7668693          	addi	a3,a3,-394 # ffffffffc0207c60 <default_pmm_manager+0xba8>
ffffffffc0203df2:	00003617          	auipc	a2,0x3
ffffffffc0203df6:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203dfa:	06f00593          	li	a1,111
ffffffffc0203dfe:	00004517          	auipc	a0,0x4
ffffffffc0203e02:	d5a50513          	addi	a0,a0,-678 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203e06:	e7afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e0a:	00004697          	auipc	a3,0x4
ffffffffc0203e0e:	e4668693          	addi	a3,a3,-442 # ffffffffc0207c50 <default_pmm_manager+0xb98>
ffffffffc0203e12:	00003617          	auipc	a2,0x3
ffffffffc0203e16:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203e1a:	06c00593          	li	a1,108
ffffffffc0203e1e:	00004517          	auipc	a0,0x4
ffffffffc0203e22:	d3a50513          	addi	a0,a0,-710 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203e26:	e5afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e2a:	00004697          	auipc	a3,0x4
ffffffffc0203e2e:	e1668693          	addi	a3,a3,-490 # ffffffffc0207c40 <default_pmm_manager+0xb88>
ffffffffc0203e32:	00003617          	auipc	a2,0x3
ffffffffc0203e36:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203e3a:	06900593          	li	a1,105
ffffffffc0203e3e:	00004517          	auipc	a0,0x4
ffffffffc0203e42:	d1a50513          	addi	a0,a0,-742 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203e46:	e3afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e4a:	00004697          	auipc	a3,0x4
ffffffffc0203e4e:	de668693          	addi	a3,a3,-538 # ffffffffc0207c30 <default_pmm_manager+0xb78>
ffffffffc0203e52:	00003617          	auipc	a2,0x3
ffffffffc0203e56:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203e5a:	06600593          	li	a1,102
ffffffffc0203e5e:	00004517          	auipc	a0,0x4
ffffffffc0203e62:	cfa50513          	addi	a0,a0,-774 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203e66:	e1afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==6);
ffffffffc0203e6a:	00004697          	auipc	a3,0x4
ffffffffc0203e6e:	db668693          	addi	a3,a3,-586 # ffffffffc0207c20 <default_pmm_manager+0xb68>
ffffffffc0203e72:	00003617          	auipc	a2,0x3
ffffffffc0203e76:	afe60613          	addi	a2,a2,-1282 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203e7a:	06300593          	li	a1,99
ffffffffc0203e7e:	00004517          	auipc	a0,0x4
ffffffffc0203e82:	cda50513          	addi	a0,a0,-806 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203e86:	dfafc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203e8a:	00004697          	auipc	a3,0x4
ffffffffc0203e8e:	d8668693          	addi	a3,a3,-634 # ffffffffc0207c10 <default_pmm_manager+0xb58>
ffffffffc0203e92:	00003617          	auipc	a2,0x3
ffffffffc0203e96:	ade60613          	addi	a2,a2,-1314 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203e9a:	06000593          	li	a1,96
ffffffffc0203e9e:	00004517          	auipc	a0,0x4
ffffffffc0203ea2:	cba50513          	addi	a0,a0,-838 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203ea6:	ddafc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203eaa:	00004697          	auipc	a3,0x4
ffffffffc0203eae:	d6668693          	addi	a3,a3,-666 # ffffffffc0207c10 <default_pmm_manager+0xb58>
ffffffffc0203eb2:	00003617          	auipc	a2,0x3
ffffffffc0203eb6:	abe60613          	addi	a2,a2,-1346 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203eba:	05d00593          	li	a1,93
ffffffffc0203ebe:	00004517          	auipc	a0,0x4
ffffffffc0203ec2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203ec6:	dbafc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203eca:	00004697          	auipc	a3,0x4
ffffffffc0203ece:	b0668693          	addi	a3,a3,-1274 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc0203ed2:	00003617          	auipc	a2,0x3
ffffffffc0203ed6:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203eda:	05a00593          	li	a1,90
ffffffffc0203ede:	00004517          	auipc	a0,0x4
ffffffffc0203ee2:	c7a50513          	addi	a0,a0,-902 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203ee6:	d9afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203eea:	00004697          	auipc	a3,0x4
ffffffffc0203eee:	ae668693          	addi	a3,a3,-1306 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc0203ef2:	00003617          	auipc	a2,0x3
ffffffffc0203ef6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203efa:	05700593          	li	a1,87
ffffffffc0203efe:	00004517          	auipc	a0,0x4
ffffffffc0203f02:	c5a50513          	addi	a0,a0,-934 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203f06:	d7afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f0a:	00004697          	auipc	a3,0x4
ffffffffc0203f0e:	ac668693          	addi	a3,a3,-1338 # ffffffffc02079d0 <default_pmm_manager+0x918>
ffffffffc0203f12:	00003617          	auipc	a2,0x3
ffffffffc0203f16:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203f1a:	05400593          	li	a1,84
ffffffffc0203f1e:	00004517          	auipc	a0,0x4
ffffffffc0203f22:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203f26:	d5afc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203f2a <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f2a:	751c                	ld	a5,40(a0)
{
ffffffffc0203f2c:	1141                	addi	sp,sp,-16
ffffffffc0203f2e:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f30:	cf91                	beqz	a5,ffffffffc0203f4c <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f32:	ee0d                	bnez	a2,ffffffffc0203f6c <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f34:	679c                	ld	a5,8(a5)
}
ffffffffc0203f36:	60a2                	ld	ra,8(sp)
ffffffffc0203f38:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f3a:	6394                	ld	a3,0(a5)
ffffffffc0203f3c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f3e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f42:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f44:	e314                	sd	a3,0(a4)
ffffffffc0203f46:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f48:	0141                	addi	sp,sp,16
ffffffffc0203f4a:	8082                	ret
         assert(head != NULL);
ffffffffc0203f4c:	00004697          	auipc	a3,0x4
ffffffffc0203f50:	d7c68693          	addi	a3,a3,-644 # ffffffffc0207cc8 <default_pmm_manager+0xc10>
ffffffffc0203f54:	00003617          	auipc	a2,0x3
ffffffffc0203f58:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203f5c:	04100593          	li	a1,65
ffffffffc0203f60:	00004517          	auipc	a0,0x4
ffffffffc0203f64:	bf850513          	addi	a0,a0,-1032 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203f68:	d18fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(in_tick==0);
ffffffffc0203f6c:	00004697          	auipc	a3,0x4
ffffffffc0203f70:	d6c68693          	addi	a3,a3,-660 # ffffffffc0207cd8 <default_pmm_manager+0xc20>
ffffffffc0203f74:	00003617          	auipc	a2,0x3
ffffffffc0203f78:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203f7c:	04200593          	li	a1,66
ffffffffc0203f80:	00004517          	auipc	a0,0x4
ffffffffc0203f84:	bd850513          	addi	a0,a0,-1064 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
ffffffffc0203f88:	cf8fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203f8c <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203f8c:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f90:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203f92:	cb09                	beqz	a4,ffffffffc0203fa4 <_fifo_map_swappable+0x18>
ffffffffc0203f94:	cb81                	beqz	a5,ffffffffc0203fa4 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203f96:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203f98:	e398                	sd	a4,0(a5)
}
ffffffffc0203f9a:	4501                	li	a0,0
ffffffffc0203f9c:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203f9e:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fa0:	f614                	sd	a3,40(a2)
ffffffffc0203fa2:	8082                	ret
{
ffffffffc0203fa4:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fa6:	00004697          	auipc	a3,0x4
ffffffffc0203faa:	d0268693          	addi	a3,a3,-766 # ffffffffc0207ca8 <default_pmm_manager+0xbf0>
ffffffffc0203fae:	00003617          	auipc	a2,0x3
ffffffffc0203fb2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203fb6:	03200593          	li	a1,50
ffffffffc0203fba:	00004517          	auipc	a0,0x4
ffffffffc0203fbe:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0207b58 <default_pmm_manager+0xaa0>
{
ffffffffc0203fc2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203fc4:	cbcfc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203fc8 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203fc8:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203fca:	00004697          	auipc	a3,0x4
ffffffffc0203fce:	d3668693          	addi	a3,a3,-714 # ffffffffc0207d00 <default_pmm_manager+0xc48>
ffffffffc0203fd2:	00003617          	auipc	a2,0x3
ffffffffc0203fd6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0203fda:	06d00593          	li	a1,109
ffffffffc0203fde:	00004517          	auipc	a0,0x4
ffffffffc0203fe2:	d4250513          	addi	a0,a0,-702 # ffffffffc0207d20 <default_pmm_manager+0xc68>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203fe6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203fe8:	c98fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203fec <mm_create>:
mm_create(void) {
ffffffffc0203fec:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203fee:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0203ff2:	e022                	sd	s0,0(sp)
ffffffffc0203ff4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203ff6:	c13fd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc0203ffa:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203ffc:	c515                	beqz	a0,ffffffffc0204028 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203ffe:	000a9797          	auipc	a5,0xa9
ffffffffc0204002:	83a78793          	addi	a5,a5,-1990 # ffffffffc02ac838 <swap_init_ok>
ffffffffc0204006:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204008:	e408                	sd	a0,8(s0)
ffffffffc020400a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020400c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204010:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204014:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204018:	2781                	sext.w	a5,a5
ffffffffc020401a:	ef81                	bnez	a5,ffffffffc0204032 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc020401c:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204020:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204024:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204028:	8522                	mv	a0,s0
ffffffffc020402a:	60a2                	ld	ra,8(sp)
ffffffffc020402c:	6402                	ld	s0,0(sp)
ffffffffc020402e:	0141                	addi	sp,sp,16
ffffffffc0204030:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204032:	a7bff0ef          	jal	ra,ffffffffc0203aac <swap_init_mm>
ffffffffc0204036:	b7ed                	j	ffffffffc0204020 <mm_create+0x34>

ffffffffc0204038 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204038:	1101                	addi	sp,sp,-32
ffffffffc020403a:	e04a                	sd	s2,0(sp)
ffffffffc020403c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020403e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204042:	e822                	sd	s0,16(sp)
ffffffffc0204044:	e426                	sd	s1,8(sp)
ffffffffc0204046:	ec06                	sd	ra,24(sp)
ffffffffc0204048:	84ae                	mv	s1,a1
ffffffffc020404a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020404c:	bbdfd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
    if (vma != NULL) {
ffffffffc0204050:	c509                	beqz	a0,ffffffffc020405a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204052:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204056:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204058:	cd00                	sw	s0,24(a0)
}
ffffffffc020405a:	60e2                	ld	ra,24(sp)
ffffffffc020405c:	6442                	ld	s0,16(sp)
ffffffffc020405e:	64a2                	ld	s1,8(sp)
ffffffffc0204060:	6902                	ld	s2,0(sp)
ffffffffc0204062:	6105                	addi	sp,sp,32
ffffffffc0204064:	8082                	ret

ffffffffc0204066 <find_vma>:
    if (mm != NULL) {
ffffffffc0204066:	c51d                	beqz	a0,ffffffffc0204094 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204068:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020406a:	c781                	beqz	a5,ffffffffc0204072 <find_vma+0xc>
ffffffffc020406c:	6798                	ld	a4,8(a5)
ffffffffc020406e:	02e5f663          	bgeu	a1,a4,ffffffffc020409a <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0204072:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0204074:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204076:	00f50f63          	beq	a0,a5,ffffffffc0204094 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020407a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020407e:	fee5ebe3          	bltu	a1,a4,ffffffffc0204074 <find_vma+0xe>
ffffffffc0204082:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204086:	fee5f7e3          	bgeu	a1,a4,ffffffffc0204074 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020408a:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020408c:	c781                	beqz	a5,ffffffffc0204094 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020408e:	e91c                	sd	a5,16(a0)
}
ffffffffc0204090:	853e                	mv	a0,a5
ffffffffc0204092:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0204094:	4781                	li	a5,0
}
ffffffffc0204096:	853e                	mv	a0,a5
ffffffffc0204098:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020409a:	6b98                	ld	a4,16(a5)
ffffffffc020409c:	fce5fbe3          	bgeu	a1,a4,ffffffffc0204072 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02040a0:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02040a2:	b7fd                	j	ffffffffc0204090 <find_vma+0x2a>

ffffffffc02040a4 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040a4:	6590                	ld	a2,8(a1)
ffffffffc02040a6:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x85b8>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02040aa:	1141                	addi	sp,sp,-16
ffffffffc02040ac:	e406                	sd	ra,8(sp)
ffffffffc02040ae:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040b0:	01066863          	bltu	a2,a6,ffffffffc02040c0 <insert_vma_struct+0x1c>
ffffffffc02040b4:	a8b9                	j	ffffffffc0204112 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02040b6:	fe87b683          	ld	a3,-24(a5)
ffffffffc02040ba:	04d66763          	bltu	a2,a3,ffffffffc0204108 <insert_vma_struct+0x64>
ffffffffc02040be:	873e                	mv	a4,a5
ffffffffc02040c0:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02040c2:	fef51ae3          	bne	a0,a5,ffffffffc02040b6 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02040c6:	02a70463          	beq	a4,a0,ffffffffc02040ee <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02040ca:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02040ce:	fe873883          	ld	a7,-24(a4)
ffffffffc02040d2:	08d8f063          	bgeu	a7,a3,ffffffffc0204152 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02040d6:	04d66e63          	bltu	a2,a3,ffffffffc0204132 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02040da:	00f50a63          	beq	a0,a5,ffffffffc02040ee <insert_vma_struct+0x4a>
ffffffffc02040de:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02040e2:	0506e863          	bltu	a3,a6,ffffffffc0204132 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02040e6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02040ea:	02c6f263          	bgeu	a3,a2,ffffffffc020410e <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02040ee:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02040f0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02040f2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02040f6:	e390                	sd	a2,0(a5)
ffffffffc02040f8:	e710                	sd	a2,8(a4)
}
ffffffffc02040fa:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02040fc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02040fe:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0204100:	2685                	addiw	a3,a3,1
ffffffffc0204102:	d114                	sw	a3,32(a0)
}
ffffffffc0204104:	0141                	addi	sp,sp,16
ffffffffc0204106:	8082                	ret
    if (le_prev != list) {
ffffffffc0204108:	fca711e3          	bne	a4,a0,ffffffffc02040ca <insert_vma_struct+0x26>
ffffffffc020410c:	bfd9                	j	ffffffffc02040e2 <insert_vma_struct+0x3e>
ffffffffc020410e:	ebbff0ef          	jal	ra,ffffffffc0203fc8 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204112:	00004697          	auipc	a3,0x4
ffffffffc0204116:	cfe68693          	addi	a3,a3,-770 # ffffffffc0207e10 <default_pmm_manager+0xd58>
ffffffffc020411a:	00003617          	auipc	a2,0x3
ffffffffc020411e:	85660613          	addi	a2,a2,-1962 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204122:	07400593          	li	a1,116
ffffffffc0204126:	00004517          	auipc	a0,0x4
ffffffffc020412a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020412e:	b52fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204132:	00004697          	auipc	a3,0x4
ffffffffc0204136:	d1e68693          	addi	a3,a3,-738 # ffffffffc0207e50 <default_pmm_manager+0xd98>
ffffffffc020413a:	00003617          	auipc	a2,0x3
ffffffffc020413e:	83660613          	addi	a2,a2,-1994 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204142:	06c00593          	li	a1,108
ffffffffc0204146:	00004517          	auipc	a0,0x4
ffffffffc020414a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020414e:	b32fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204152:	00004697          	auipc	a3,0x4
ffffffffc0204156:	cde68693          	addi	a3,a3,-802 # ffffffffc0207e30 <default_pmm_manager+0xd78>
ffffffffc020415a:	00003617          	auipc	a2,0x3
ffffffffc020415e:	81660613          	addi	a2,a2,-2026 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204162:	06b00593          	li	a1,107
ffffffffc0204166:	00004517          	auipc	a0,0x4
ffffffffc020416a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020416e:	b12fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204172 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204172:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204174:	1141                	addi	sp,sp,-16
ffffffffc0204176:	e406                	sd	ra,8(sp)
ffffffffc0204178:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020417a:	e78d                	bnez	a5,ffffffffc02041a4 <mm_destroy+0x32>
ffffffffc020417c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020417e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204180:	00a40c63          	beq	s0,a0,ffffffffc0204198 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204184:	6118                	ld	a4,0(a0)
ffffffffc0204186:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204188:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020418a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020418c:	e398                	sd	a4,0(a5)
ffffffffc020418e:	b37fd0ef          	jal	ra,ffffffffc0201cc4 <kfree>
    return listelm->next;
ffffffffc0204192:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204194:	fea418e3          	bne	s0,a0,ffffffffc0204184 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204198:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020419a:	6402                	ld	s0,0(sp)
ffffffffc020419c:	60a2                	ld	ra,8(sp)
ffffffffc020419e:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02041a0:	b25fd06f          	j	ffffffffc0201cc4 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02041a4:	00004697          	auipc	a3,0x4
ffffffffc02041a8:	ccc68693          	addi	a3,a3,-820 # ffffffffc0207e70 <default_pmm_manager+0xdb8>
ffffffffc02041ac:	00002617          	auipc	a2,0x2
ffffffffc02041b0:	7c460613          	addi	a2,a2,1988 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02041b4:	09400593          	li	a1,148
ffffffffc02041b8:	00004517          	auipc	a0,0x4
ffffffffc02041bc:	b6850513          	addi	a0,a0,-1176 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02041c0:	ac0fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02041c4 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041c4:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02041c6:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041c8:	17fd                	addi	a5,a5,-1
ffffffffc02041ca:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02041cc:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041ce:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02041d2:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041d4:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02041d6:	fc06                	sd	ra,56(sp)
ffffffffc02041d8:	f04a                	sd	s2,32(sp)
ffffffffc02041da:	ec4e                	sd	s3,24(sp)
ffffffffc02041dc:	e852                	sd	s4,16(sp)
ffffffffc02041de:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041e0:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02041e4:	002007b7          	lui	a5,0x200
ffffffffc02041e8:	01047433          	and	s0,s0,a6
ffffffffc02041ec:	06f4e363          	bltu	s1,a5,ffffffffc0204252 <mm_map+0x8e>
ffffffffc02041f0:	0684f163          	bgeu	s1,s0,ffffffffc0204252 <mm_map+0x8e>
ffffffffc02041f4:	4785                	li	a5,1
ffffffffc02041f6:	07fe                	slli	a5,a5,0x1f
ffffffffc02041f8:	0487ed63          	bltu	a5,s0,ffffffffc0204252 <mm_map+0x8e>
ffffffffc02041fc:	89aa                	mv	s3,a0
ffffffffc02041fe:	8a3a                	mv	s4,a4
ffffffffc0204200:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204202:	c931                	beqz	a0,ffffffffc0204256 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204204:	85a6                	mv	a1,s1
ffffffffc0204206:	e61ff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc020420a:	c501                	beqz	a0,ffffffffc0204212 <mm_map+0x4e>
ffffffffc020420c:	651c                	ld	a5,8(a0)
ffffffffc020420e:	0487e263          	bltu	a5,s0,ffffffffc0204252 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204212:	03000513          	li	a0,48
ffffffffc0204216:	9f3fd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc020421a:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020421c:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020421e:	02090163          	beqz	s2,ffffffffc0204240 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204222:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204224:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204228:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020422c:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204230:	85ca                	mv	a1,s2
ffffffffc0204232:	e73ff0ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204236:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204238:	000a0463          	beqz	s4,ffffffffc0204240 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc020423c:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204240:	70e2                	ld	ra,56(sp)
ffffffffc0204242:	7442                	ld	s0,48(sp)
ffffffffc0204244:	74a2                	ld	s1,40(sp)
ffffffffc0204246:	7902                	ld	s2,32(sp)
ffffffffc0204248:	69e2                	ld	s3,24(sp)
ffffffffc020424a:	6a42                	ld	s4,16(sp)
ffffffffc020424c:	6aa2                	ld	s5,8(sp)
ffffffffc020424e:	6121                	addi	sp,sp,64
ffffffffc0204250:	8082                	ret
        return -E_INVAL;
ffffffffc0204252:	5575                	li	a0,-3
ffffffffc0204254:	b7f5                	j	ffffffffc0204240 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204256:	00003697          	auipc	a3,0x3
ffffffffc020425a:	60268693          	addi	a3,a3,1538 # ffffffffc0207858 <default_pmm_manager+0x7a0>
ffffffffc020425e:	00002617          	auipc	a2,0x2
ffffffffc0204262:	71260613          	addi	a2,a2,1810 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204266:	0a700593          	li	a1,167
ffffffffc020426a:	00004517          	auipc	a0,0x4
ffffffffc020426e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204272:	a0efc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204276 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204276:	7139                	addi	sp,sp,-64
ffffffffc0204278:	fc06                	sd	ra,56(sp)
ffffffffc020427a:	f822                	sd	s0,48(sp)
ffffffffc020427c:	f426                	sd	s1,40(sp)
ffffffffc020427e:	f04a                	sd	s2,32(sp)
ffffffffc0204280:	ec4e                	sd	s3,24(sp)
ffffffffc0204282:	e852                	sd	s4,16(sp)
ffffffffc0204284:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204286:	c535                	beqz	a0,ffffffffc02042f2 <dup_mmap+0x7c>
ffffffffc0204288:	892a                	mv	s2,a0
ffffffffc020428a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020428c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020428e:	e59d                	bnez	a1,ffffffffc02042bc <dup_mmap+0x46>
ffffffffc0204290:	a08d                	j	ffffffffc02042f2 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204292:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204294:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5540>
        insert_vma_struct(to, nvma);
ffffffffc0204298:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc020429a:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020429e:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02042a2:	e03ff0ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02042a6:	ff043683          	ld	a3,-16(s0)
ffffffffc02042aa:	fe843603          	ld	a2,-24(s0)
ffffffffc02042ae:	6c8c                	ld	a1,24(s1)
ffffffffc02042b0:	01893503          	ld	a0,24(s2)
ffffffffc02042b4:	4701                	li	a4,0
ffffffffc02042b6:	da9fe0ef          	jal	ra,ffffffffc020305e <copy_range>
ffffffffc02042ba:	e105                	bnez	a0,ffffffffc02042da <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02042bc:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02042be:	02848863          	beq	s1,s0,ffffffffc02042ee <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042c2:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02042c6:	fe843a83          	ld	s5,-24(s0)
ffffffffc02042ca:	ff043a03          	ld	s4,-16(s0)
ffffffffc02042ce:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042d2:	937fd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc02042d6:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02042d8:	fd4d                	bnez	a0,ffffffffc0204292 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02042da:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02042dc:	70e2                	ld	ra,56(sp)
ffffffffc02042de:	7442                	ld	s0,48(sp)
ffffffffc02042e0:	74a2                	ld	s1,40(sp)
ffffffffc02042e2:	7902                	ld	s2,32(sp)
ffffffffc02042e4:	69e2                	ld	s3,24(sp)
ffffffffc02042e6:	6a42                	ld	s4,16(sp)
ffffffffc02042e8:	6aa2                	ld	s5,8(sp)
ffffffffc02042ea:	6121                	addi	sp,sp,64
ffffffffc02042ec:	8082                	ret
    return 0;
ffffffffc02042ee:	4501                	li	a0,0
ffffffffc02042f0:	b7f5                	j	ffffffffc02042dc <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02042f2:	00004697          	auipc	a3,0x4
ffffffffc02042f6:	ade68693          	addi	a3,a3,-1314 # ffffffffc0207dd0 <default_pmm_manager+0xd18>
ffffffffc02042fa:	00002617          	auipc	a2,0x2
ffffffffc02042fe:	67660613          	addi	a2,a2,1654 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204302:	0c000593          	li	a1,192
ffffffffc0204306:	00004517          	auipc	a0,0x4
ffffffffc020430a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020430e:	972fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204312 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204312:	1101                	addi	sp,sp,-32
ffffffffc0204314:	ec06                	sd	ra,24(sp)
ffffffffc0204316:	e822                	sd	s0,16(sp)
ffffffffc0204318:	e426                	sd	s1,8(sp)
ffffffffc020431a:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020431c:	c531                	beqz	a0,ffffffffc0204368 <exit_mmap+0x56>
ffffffffc020431e:	591c                	lw	a5,48(a0)
ffffffffc0204320:	84aa                	mv	s1,a0
ffffffffc0204322:	e3b9                	bnez	a5,ffffffffc0204368 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204324:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204326:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020432a:	02850663          	beq	a0,s0,ffffffffc0204356 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020432e:	ff043603          	ld	a2,-16(s0)
ffffffffc0204332:	fe843583          	ld	a1,-24(s0)
ffffffffc0204336:	854a                	mv	a0,s2
ffffffffc0204338:	e01fd0ef          	jal	ra,ffffffffc0202138 <unmap_range>
ffffffffc020433c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020433e:	fe8498e3          	bne	s1,s0,ffffffffc020432e <exit_mmap+0x1c>
ffffffffc0204342:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204344:	00848c63          	beq	s1,s0,ffffffffc020435c <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204348:	ff043603          	ld	a2,-16(s0)
ffffffffc020434c:	fe843583          	ld	a1,-24(s0)
ffffffffc0204350:	854a                	mv	a0,s2
ffffffffc0204352:	efffd0ef          	jal	ra,ffffffffc0202250 <exit_range>
ffffffffc0204356:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204358:	fe8498e3          	bne	s1,s0,ffffffffc0204348 <exit_mmap+0x36>
    }
}
ffffffffc020435c:	60e2                	ld	ra,24(sp)
ffffffffc020435e:	6442                	ld	s0,16(sp)
ffffffffc0204360:	64a2                	ld	s1,8(sp)
ffffffffc0204362:	6902                	ld	s2,0(sp)
ffffffffc0204364:	6105                	addi	sp,sp,32
ffffffffc0204366:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204368:	00004697          	auipc	a3,0x4
ffffffffc020436c:	a8868693          	addi	a3,a3,-1400 # ffffffffc0207df0 <default_pmm_manager+0xd38>
ffffffffc0204370:	00002617          	auipc	a2,0x2
ffffffffc0204374:	60060613          	addi	a2,a2,1536 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204378:	0d600593          	li	a1,214
ffffffffc020437c:	00004517          	auipc	a0,0x4
ffffffffc0204380:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204384:	8fcfc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204388 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204388:	7139                	addi	sp,sp,-64
ffffffffc020438a:	f822                	sd	s0,48(sp)
ffffffffc020438c:	f426                	sd	s1,40(sp)
ffffffffc020438e:	fc06                	sd	ra,56(sp)
ffffffffc0204390:	f04a                	sd	s2,32(sp)
ffffffffc0204392:	ec4e                	sd	s3,24(sp)
ffffffffc0204394:	e852                	sd	s4,16(sp)
ffffffffc0204396:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204398:	c55ff0ef          	jal	ra,ffffffffc0203fec <mm_create>
    assert(mm != NULL);
ffffffffc020439c:	842a                	mv	s0,a0
ffffffffc020439e:	03200493          	li	s1,50
ffffffffc02043a2:	e919                	bnez	a0,ffffffffc02043b8 <vmm_init+0x30>
ffffffffc02043a4:	a989                	j	ffffffffc02047f6 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc02043a6:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02043a8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02043aa:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02043ae:	14ed                	addi	s1,s1,-5
ffffffffc02043b0:	8522                	mv	a0,s0
ffffffffc02043b2:	cf3ff0ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02043b6:	c88d                	beqz	s1,ffffffffc02043e8 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043b8:	03000513          	li	a0,48
ffffffffc02043bc:	84dfd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc02043c0:	85aa                	mv	a1,a0
ffffffffc02043c2:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02043c6:	f165                	bnez	a0,ffffffffc02043a6 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02043c8:	00003697          	auipc	a3,0x3
ffffffffc02043cc:	4c868693          	addi	a3,a3,1224 # ffffffffc0207890 <default_pmm_manager+0x7d8>
ffffffffc02043d0:	00002617          	auipc	a2,0x2
ffffffffc02043d4:	5a060613          	addi	a2,a2,1440 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02043d8:	11300593          	li	a1,275
ffffffffc02043dc:	00004517          	auipc	a0,0x4
ffffffffc02043e0:	94450513          	addi	a0,a0,-1724 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02043e4:	89cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02043e8:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02043ec:	1f900913          	li	s2,505
ffffffffc02043f0:	a819                	j	ffffffffc0204406 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02043f2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02043f4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02043f6:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02043fa:	0495                	addi	s1,s1,5
ffffffffc02043fc:	8522                	mv	a0,s0
ffffffffc02043fe:	ca7ff0ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204402:	03248a63          	beq	s1,s2,ffffffffc0204436 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204406:	03000513          	li	a0,48
ffffffffc020440a:	ffefd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc020440e:	85aa                	mv	a1,a0
ffffffffc0204410:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204414:	fd79                	bnez	a0,ffffffffc02043f2 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204416:	00003697          	auipc	a3,0x3
ffffffffc020441a:	47a68693          	addi	a3,a3,1146 # ffffffffc0207890 <default_pmm_manager+0x7d8>
ffffffffc020441e:	00002617          	auipc	a2,0x2
ffffffffc0204422:	55260613          	addi	a2,a2,1362 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204426:	11900593          	li	a1,281
ffffffffc020442a:	00004517          	auipc	a0,0x4
ffffffffc020442e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204432:	84efc0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204436:	6418                	ld	a4,8(s0)
ffffffffc0204438:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020443a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020443e:	2ee40063          	beq	s0,a4,ffffffffc020471e <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204442:	fe873603          	ld	a2,-24(a4)
ffffffffc0204446:	ffe78693          	addi	a3,a5,-2
ffffffffc020444a:	24d61a63          	bne	a2,a3,ffffffffc020469e <vmm_init+0x316>
ffffffffc020444e:	ff073683          	ld	a3,-16(a4)
ffffffffc0204452:	24f69663          	bne	a3,a5,ffffffffc020469e <vmm_init+0x316>
ffffffffc0204456:	0795                	addi	a5,a5,5
ffffffffc0204458:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020445a:	feb792e3          	bne	a5,a1,ffffffffc020443e <vmm_init+0xb6>
ffffffffc020445e:	491d                	li	s2,7
ffffffffc0204460:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204462:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204466:	85a6                	mv	a1,s1
ffffffffc0204468:	8522                	mv	a0,s0
ffffffffc020446a:	bfdff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc020446e:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0204470:	30050763          	beqz	a0,ffffffffc020477e <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204474:	00148593          	addi	a1,s1,1
ffffffffc0204478:	8522                	mv	a0,s0
ffffffffc020447a:	bedff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc020447e:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204480:	2c050f63          	beqz	a0,ffffffffc020475e <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204484:	85ca                	mv	a1,s2
ffffffffc0204486:	8522                	mv	a0,s0
ffffffffc0204488:	bdfff0ef          	jal	ra,ffffffffc0204066 <find_vma>
        assert(vma3 == NULL);
ffffffffc020448c:	2a051963          	bnez	a0,ffffffffc020473e <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204490:	00348593          	addi	a1,s1,3
ffffffffc0204494:	8522                	mv	a0,s0
ffffffffc0204496:	bd1ff0ef          	jal	ra,ffffffffc0204066 <find_vma>
        assert(vma4 == NULL);
ffffffffc020449a:	32051263          	bnez	a0,ffffffffc02047be <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020449e:	00448593          	addi	a1,s1,4
ffffffffc02044a2:	8522                	mv	a0,s0
ffffffffc02044a4:	bc3ff0ef          	jal	ra,ffffffffc0204066 <find_vma>
        assert(vma5 == NULL);
ffffffffc02044a8:	2e051b63          	bnez	a0,ffffffffc020479e <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02044ac:	008a3783          	ld	a5,8(s4)
ffffffffc02044b0:	20979763          	bne	a5,s1,ffffffffc02046be <vmm_init+0x336>
ffffffffc02044b4:	010a3783          	ld	a5,16(s4)
ffffffffc02044b8:	21279363          	bne	a5,s2,ffffffffc02046be <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02044bc:	0089b783          	ld	a5,8(s3)
ffffffffc02044c0:	20979f63          	bne	a5,s1,ffffffffc02046de <vmm_init+0x356>
ffffffffc02044c4:	0109b783          	ld	a5,16(s3)
ffffffffc02044c8:	21279b63          	bne	a5,s2,ffffffffc02046de <vmm_init+0x356>
ffffffffc02044cc:	0495                	addi	s1,s1,5
ffffffffc02044ce:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02044d0:	f9549be3          	bne	s1,s5,ffffffffc0204466 <vmm_init+0xde>
ffffffffc02044d4:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02044d6:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02044d8:	85a6                	mv	a1,s1
ffffffffc02044da:	8522                	mv	a0,s0
ffffffffc02044dc:	b8bff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc02044e0:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02044e4:	c90d                	beqz	a0,ffffffffc0204516 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02044e6:	6914                	ld	a3,16(a0)
ffffffffc02044e8:	6510                	ld	a2,8(a0)
ffffffffc02044ea:	00004517          	auipc	a0,0x4
ffffffffc02044ee:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0207f88 <default_pmm_manager+0xed0>
ffffffffc02044f2:	c9dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02044f6:	00004697          	auipc	a3,0x4
ffffffffc02044fa:	aba68693          	addi	a3,a3,-1350 # ffffffffc0207fb0 <default_pmm_manager+0xef8>
ffffffffc02044fe:	00002617          	auipc	a2,0x2
ffffffffc0204502:	47260613          	addi	a2,a2,1138 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204506:	13b00593          	li	a1,315
ffffffffc020450a:	00004517          	auipc	a0,0x4
ffffffffc020450e:	81650513          	addi	a0,a0,-2026 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204512:	f6ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204516:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204518:	fd2490e3          	bne	s1,s2,ffffffffc02044d8 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020451c:	8522                	mv	a0,s0
ffffffffc020451e:	c55ff0ef          	jal	ra,ffffffffc0204172 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204522:	00004517          	auipc	a0,0x4
ffffffffc0204526:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207fc8 <default_pmm_manager+0xf10>
ffffffffc020452a:	c65fb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020452e:	9a1fd0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc0204532:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0204534:	ab9ff0ef          	jal	ra,ffffffffc0203fec <mm_create>
ffffffffc0204538:	000a8797          	auipc	a5,0xa8
ffffffffc020453c:	44a7b023          	sd	a0,1088(a5) # ffffffffc02ac978 <check_mm_struct>
ffffffffc0204540:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0204542:	36050663          	beqz	a0,ffffffffc02048ae <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204546:	000a8797          	auipc	a5,0xa8
ffffffffc020454a:	2da78793          	addi	a5,a5,730 # ffffffffc02ac820 <boot_pgdir>
ffffffffc020454e:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0204552:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204556:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020455a:	2c079e63          	bnez	a5,ffffffffc0204836 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020455e:	03000513          	li	a0,48
ffffffffc0204562:	ea6fd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc0204566:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204568:	18050b63          	beqz	a0,ffffffffc02046fe <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc020456c:	002007b7          	lui	a5,0x200
ffffffffc0204570:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0204572:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204574:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204576:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204578:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc020457a:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020457e:	b27ff0ef          	jal	ra,ffffffffc02040a4 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204582:	10000593          	li	a1,256
ffffffffc0204586:	8526                	mv	a0,s1
ffffffffc0204588:	adfff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc020458c:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204590:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204594:	2ca41163          	bne	s0,a0,ffffffffc0204856 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204598:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc020459c:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020459e:	fee79de3          	bne	a5,a4,ffffffffc0204598 <vmm_init+0x210>
        sum += i;
ffffffffc02045a2:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02045a4:	10000793          	li	a5,256
        sum += i;
ffffffffc02045a8:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02045ac:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02045b0:	0007c683          	lbu	a3,0(a5)
ffffffffc02045b4:	0785                	addi	a5,a5,1
ffffffffc02045b6:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02045b8:	fec79ce3          	bne	a5,a2,ffffffffc02045b0 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02045bc:	2c071963          	bnez	a4,ffffffffc020488e <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02045c0:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02045c4:	000a8a97          	auipc	s5,0xa8
ffffffffc02045c8:	264a8a93          	addi	s5,s5,612 # ffffffffc02ac828 <npage>
ffffffffc02045cc:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02045d0:	078a                	slli	a5,a5,0x2
ffffffffc02045d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02045d4:	20e7f563          	bgeu	a5,a4,ffffffffc02047de <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02045d8:	00004697          	auipc	a3,0x4
ffffffffc02045dc:	40868693          	addi	a3,a3,1032 # ffffffffc02089e0 <nbase>
ffffffffc02045e0:	0006ba03          	ld	s4,0(a3)
ffffffffc02045e4:	414786b3          	sub	a3,a5,s4
ffffffffc02045e8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02045ea:	8699                	srai	a3,a3,0x6
ffffffffc02045ec:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02045ee:	00c69793          	slli	a5,a3,0xc
ffffffffc02045f2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02045f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02045f6:	28e7f063          	bgeu	a5,a4,ffffffffc0204876 <vmm_init+0x4ee>
ffffffffc02045fa:	000a8797          	auipc	a5,0xa8
ffffffffc02045fe:	28e78793          	addi	a5,a5,654 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0204602:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204604:	4581                	li	a1,0
ffffffffc0204606:	854a                	mv	a0,s2
ffffffffc0204608:	9436                	add	s0,s0,a3
ffffffffc020460a:	e9dfd0ef          	jal	ra,ffffffffc02024a6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020460e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204610:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204614:	078a                	slli	a5,a5,0x2
ffffffffc0204616:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204618:	1ce7f363          	bgeu	a5,a4,ffffffffc02047de <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020461c:	000a8417          	auipc	s0,0xa8
ffffffffc0204620:	27c40413          	addi	s0,s0,636 # ffffffffc02ac898 <pages>
ffffffffc0204624:	6008                	ld	a0,0(s0)
ffffffffc0204626:	414787b3          	sub	a5,a5,s4
ffffffffc020462a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020462c:	953e                	add	a0,a0,a5
ffffffffc020462e:	4585                	li	a1,1
ffffffffc0204630:	859fd0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204634:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204638:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020463c:	078a                	slli	a5,a5,0x2
ffffffffc020463e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204640:	18e7ff63          	bgeu	a5,a4,ffffffffc02047de <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204644:	6008                	ld	a0,0(s0)
ffffffffc0204646:	414787b3          	sub	a5,a5,s4
ffffffffc020464a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020464c:	4585                	li	a1,1
ffffffffc020464e:	953e                	add	a0,a0,a5
ffffffffc0204650:	839fd0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    pgdir[0] = 0;
ffffffffc0204654:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204658:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc020465c:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0204660:	8526                	mv	a0,s1
ffffffffc0204662:	b11ff0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204666:	000a8797          	auipc	a5,0xa8
ffffffffc020466a:	3007b923          	sd	zero,786(a5) # ffffffffc02ac978 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020466e:	861fd0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
ffffffffc0204672:	1aa99263          	bne	s3,a0,ffffffffc0204816 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204676:	00004517          	auipc	a0,0x4
ffffffffc020467a:	9e250513          	addi	a0,a0,-1566 # ffffffffc0208058 <default_pmm_manager+0xfa0>
ffffffffc020467e:	b11fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0204682:	7442                	ld	s0,48(sp)
ffffffffc0204684:	70e2                	ld	ra,56(sp)
ffffffffc0204686:	74a2                	ld	s1,40(sp)
ffffffffc0204688:	7902                	ld	s2,32(sp)
ffffffffc020468a:	69e2                	ld	s3,24(sp)
ffffffffc020468c:	6a42                	ld	s4,16(sp)
ffffffffc020468e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204690:	00004517          	auipc	a0,0x4
ffffffffc0204694:	9e850513          	addi	a0,a0,-1560 # ffffffffc0208078 <default_pmm_manager+0xfc0>
}
ffffffffc0204698:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020469a:	af5fb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020469e:	00004697          	auipc	a3,0x4
ffffffffc02046a2:	80268693          	addi	a3,a3,-2046 # ffffffffc0207ea0 <default_pmm_manager+0xde8>
ffffffffc02046a6:	00002617          	auipc	a2,0x2
ffffffffc02046aa:	2ca60613          	addi	a2,a2,714 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02046ae:	12200593          	li	a1,290
ffffffffc02046b2:	00003517          	auipc	a0,0x3
ffffffffc02046b6:	66e50513          	addi	a0,a0,1646 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02046ba:	dc7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	86a68693          	addi	a3,a3,-1942 # ffffffffc0207f28 <default_pmm_manager+0xe70>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	2aa60613          	addi	a2,a2,682 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02046ce:	13200593          	li	a1,306
ffffffffc02046d2:	00003517          	auipc	a0,0x3
ffffffffc02046d6:	64e50513          	addi	a0,a0,1614 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02046da:	da7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02046de:	00004697          	auipc	a3,0x4
ffffffffc02046e2:	87a68693          	addi	a3,a3,-1926 # ffffffffc0207f58 <default_pmm_manager+0xea0>
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	28a60613          	addi	a2,a2,650 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02046ee:	13300593          	li	a1,307
ffffffffc02046f2:	00003517          	auipc	a0,0x3
ffffffffc02046f6:	62e50513          	addi	a0,a0,1582 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02046fa:	d87fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(vma != NULL);
ffffffffc02046fe:	00003697          	auipc	a3,0x3
ffffffffc0204702:	19268693          	addi	a3,a3,402 # ffffffffc0207890 <default_pmm_manager+0x7d8>
ffffffffc0204706:	00002617          	auipc	a2,0x2
ffffffffc020470a:	26a60613          	addi	a2,a2,618 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020470e:	15200593          	li	a1,338
ffffffffc0204712:	00003517          	auipc	a0,0x3
ffffffffc0204716:	60e50513          	addi	a0,a0,1550 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020471a:	d67fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020471e:	00003697          	auipc	a3,0x3
ffffffffc0204722:	76a68693          	addi	a3,a3,1898 # ffffffffc0207e88 <default_pmm_manager+0xdd0>
ffffffffc0204726:	00002617          	auipc	a2,0x2
ffffffffc020472a:	24a60613          	addi	a2,a2,586 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020472e:	12000593          	li	a1,288
ffffffffc0204732:	00003517          	auipc	a0,0x3
ffffffffc0204736:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020473a:	d47fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma3 == NULL);
ffffffffc020473e:	00003697          	auipc	a3,0x3
ffffffffc0204742:	7ba68693          	addi	a3,a3,1978 # ffffffffc0207ef8 <default_pmm_manager+0xe40>
ffffffffc0204746:	00002617          	auipc	a2,0x2
ffffffffc020474a:	22a60613          	addi	a2,a2,554 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020474e:	12c00593          	li	a1,300
ffffffffc0204752:	00003517          	auipc	a0,0x3
ffffffffc0204756:	5ce50513          	addi	a0,a0,1486 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020475a:	d27fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2 != NULL);
ffffffffc020475e:	00003697          	auipc	a3,0x3
ffffffffc0204762:	78a68693          	addi	a3,a3,1930 # ffffffffc0207ee8 <default_pmm_manager+0xe30>
ffffffffc0204766:	00002617          	auipc	a2,0x2
ffffffffc020476a:	20a60613          	addi	a2,a2,522 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020476e:	12a00593          	li	a1,298
ffffffffc0204772:	00003517          	auipc	a0,0x3
ffffffffc0204776:	5ae50513          	addi	a0,a0,1454 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020477a:	d07fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1 != NULL);
ffffffffc020477e:	00003697          	auipc	a3,0x3
ffffffffc0204782:	75a68693          	addi	a3,a3,1882 # ffffffffc0207ed8 <default_pmm_manager+0xe20>
ffffffffc0204786:	00002617          	auipc	a2,0x2
ffffffffc020478a:	1ea60613          	addi	a2,a2,490 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020478e:	12800593          	li	a1,296
ffffffffc0204792:	00003517          	auipc	a0,0x3
ffffffffc0204796:	58e50513          	addi	a0,a0,1422 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc020479a:	ce7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma5 == NULL);
ffffffffc020479e:	00003697          	auipc	a3,0x3
ffffffffc02047a2:	77a68693          	addi	a3,a3,1914 # ffffffffc0207f18 <default_pmm_manager+0xe60>
ffffffffc02047a6:	00002617          	auipc	a2,0x2
ffffffffc02047aa:	1ca60613          	addi	a2,a2,458 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02047ae:	13000593          	li	a1,304
ffffffffc02047b2:	00003517          	auipc	a0,0x3
ffffffffc02047b6:	56e50513          	addi	a0,a0,1390 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02047ba:	cc7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma4 == NULL);
ffffffffc02047be:	00003697          	auipc	a3,0x3
ffffffffc02047c2:	74a68693          	addi	a3,a3,1866 # ffffffffc0207f08 <default_pmm_manager+0xe50>
ffffffffc02047c6:	00002617          	auipc	a2,0x2
ffffffffc02047ca:	1aa60613          	addi	a2,a2,426 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02047ce:	12e00593          	li	a1,302
ffffffffc02047d2:	00003517          	auipc	a0,0x3
ffffffffc02047d6:	54e50513          	addi	a0,a0,1358 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02047da:	ca7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02047de:	00003617          	auipc	a2,0x3
ffffffffc02047e2:	98a60613          	addi	a2,a2,-1654 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc02047e6:	06200593          	li	a1,98
ffffffffc02047ea:	00003517          	auipc	a0,0x3
ffffffffc02047ee:	94650513          	addi	a0,a0,-1722 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc02047f2:	c8ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(mm != NULL);
ffffffffc02047f6:	00003697          	auipc	a3,0x3
ffffffffc02047fa:	06268693          	addi	a3,a3,98 # ffffffffc0207858 <default_pmm_manager+0x7a0>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	17260613          	addi	a2,a2,370 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204806:	10c00593          	li	a1,268
ffffffffc020480a:	00003517          	auipc	a0,0x3
ffffffffc020480e:	51650513          	addi	a0,a0,1302 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204812:	c6ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204816:	00004697          	auipc	a3,0x4
ffffffffc020481a:	81a68693          	addi	a3,a3,-2022 # ffffffffc0208030 <default_pmm_manager+0xf78>
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	15260613          	addi	a2,a2,338 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204826:	17000593          	li	a1,368
ffffffffc020482a:	00003517          	auipc	a0,0x3
ffffffffc020482e:	4f650513          	addi	a0,a0,1270 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204832:	c4ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204836:	00003697          	auipc	a3,0x3
ffffffffc020483a:	04a68693          	addi	a3,a3,74 # ffffffffc0207880 <default_pmm_manager+0x7c8>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	13260613          	addi	a2,a2,306 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204846:	14f00593          	li	a1,335
ffffffffc020484a:	00003517          	auipc	a0,0x3
ffffffffc020484e:	4d650513          	addi	a0,a0,1238 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204852:	c2ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204856:	00003697          	auipc	a3,0x3
ffffffffc020485a:	7aa68693          	addi	a3,a3,1962 # ffffffffc0208000 <default_pmm_manager+0xf48>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	11260613          	addi	a2,a2,274 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0204866:	15700593          	li	a1,343
ffffffffc020486a:	00003517          	auipc	a0,0x3
ffffffffc020486e:	4b650513          	addi	a0,a0,1206 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc0204872:	c0ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204876:	00003617          	auipc	a2,0x3
ffffffffc020487a:	89260613          	addi	a2,a2,-1902 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc020487e:	06900593          	li	a1,105
ffffffffc0204882:	00003517          	auipc	a0,0x3
ffffffffc0204886:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc020488a:	bf7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(sum == 0);
ffffffffc020488e:	00003697          	auipc	a3,0x3
ffffffffc0204892:	79268693          	addi	a3,a3,1938 # ffffffffc0208020 <default_pmm_manager+0xf68>
ffffffffc0204896:	00002617          	auipc	a2,0x2
ffffffffc020489a:	0da60613          	addi	a2,a2,218 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020489e:	16300593          	li	a1,355
ffffffffc02048a2:	00003517          	auipc	a0,0x3
ffffffffc02048a6:	47e50513          	addi	a0,a0,1150 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02048aa:	bd7fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02048ae:	00003697          	auipc	a3,0x3
ffffffffc02048b2:	73a68693          	addi	a3,a3,1850 # ffffffffc0207fe8 <default_pmm_manager+0xf30>
ffffffffc02048b6:	00002617          	auipc	a2,0x2
ffffffffc02048ba:	0ba60613          	addi	a2,a2,186 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02048be:	14b00593          	li	a1,331
ffffffffc02048c2:	00003517          	auipc	a0,0x3
ffffffffc02048c6:	45e50513          	addi	a0,a0,1118 # ffffffffc0207d20 <default_pmm_manager+0xc68>
ffffffffc02048ca:	bb7fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02048ce <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048ce:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02048d0:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048d2:	e822                	sd	s0,16(sp)
ffffffffc02048d4:	e426                	sd	s1,8(sp)
ffffffffc02048d6:	ec06                	sd	ra,24(sp)
ffffffffc02048d8:	e04a                	sd	s2,0(sp)
ffffffffc02048da:	8432                	mv	s0,a2
ffffffffc02048dc:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02048de:	f88ff0ef          	jal	ra,ffffffffc0204066 <find_vma>

    pgfault_num++;
ffffffffc02048e2:	000a8797          	auipc	a5,0xa8
ffffffffc02048e6:	f5a78793          	addi	a5,a5,-166 # ffffffffc02ac83c <pgfault_num>
ffffffffc02048ea:	439c                	lw	a5,0(a5)
ffffffffc02048ec:	2785                	addiw	a5,a5,1
ffffffffc02048ee:	000a8717          	auipc	a4,0xa8
ffffffffc02048f2:	f4f72723          	sw	a5,-178(a4) # ffffffffc02ac83c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02048f6:	cd21                	beqz	a0,ffffffffc020494e <do_pgfault+0x80>
ffffffffc02048f8:	651c                	ld	a5,8(a0)
ffffffffc02048fa:	04f46a63          	bltu	s0,a5,ffffffffc020494e <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02048fe:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204900:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204902:	8b89                	andi	a5,a5,2
ffffffffc0204904:	e78d                	bnez	a5,ffffffffc020492e <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204906:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204908:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020490a:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020490c:	85a2                	mv	a1,s0
ffffffffc020490e:	4605                	li	a2,1
ffffffffc0204910:	dfefd0ef          	jal	ra,ffffffffc0201f0e <get_pte>
ffffffffc0204914:	cd31                	beqz	a0,ffffffffc0204970 <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204916:	610c                	ld	a1,0(a0)
ffffffffc0204918:	cd89                	beqz	a1,ffffffffc0204932 <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc020491a:	000a8797          	auipc	a5,0xa8
ffffffffc020491e:	f1e78793          	addi	a5,a5,-226 # ffffffffc02ac838 <swap_init_ok>
ffffffffc0204922:	439c                	lw	a5,0(a5)
ffffffffc0204924:	2781                	sext.w	a5,a5
ffffffffc0204926:	cf8d                	beqz	a5,ffffffffc0204960 <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0204928:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9590>
ffffffffc020492c:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc020492e:	495d                	li	s2,23
ffffffffc0204930:	bfd9                	j	ffffffffc0204906 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204932:	6c88                	ld	a0,24(s1)
ffffffffc0204934:	864a                	mv	a2,s2
ffffffffc0204936:	85a2                	mv	a1,s0
ffffffffc0204938:	961fe0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc020493c:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020493e:	c129                	beqz	a0,ffffffffc0204980 <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc0204940:	60e2                	ld	ra,24(sp)
ffffffffc0204942:	6442                	ld	s0,16(sp)
ffffffffc0204944:	64a2                	ld	s1,8(sp)
ffffffffc0204946:	6902                	ld	s2,0(sp)
ffffffffc0204948:	853e                	mv	a0,a5
ffffffffc020494a:	6105                	addi	sp,sp,32
ffffffffc020494c:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020494e:	85a2                	mv	a1,s0
ffffffffc0204950:	00003517          	auipc	a0,0x3
ffffffffc0204954:	3e050513          	addi	a0,a0,992 # ffffffffc0207d30 <default_pmm_manager+0xc78>
ffffffffc0204958:	837fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc020495c:	57f5                	li	a5,-3
        goto failed;
ffffffffc020495e:	b7cd                	j	ffffffffc0204940 <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204960:	00003517          	auipc	a0,0x3
ffffffffc0204964:	44850513          	addi	a0,a0,1096 # ffffffffc0207da8 <default_pmm_manager+0xcf0>
ffffffffc0204968:	827fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020496c:	57f1                	li	a5,-4
            goto failed;
ffffffffc020496e:	bfc9                	j	ffffffffc0204940 <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204970:	00003517          	auipc	a0,0x3
ffffffffc0204974:	3f050513          	addi	a0,a0,1008 # ffffffffc0207d60 <default_pmm_manager+0xca8>
ffffffffc0204978:	817fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020497c:	57f1                	li	a5,-4
        goto failed;
ffffffffc020497e:	b7c9                	j	ffffffffc0204940 <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204980:	00003517          	auipc	a0,0x3
ffffffffc0204984:	40050513          	addi	a0,a0,1024 # ffffffffc0207d80 <default_pmm_manager+0xcc8>
ffffffffc0204988:	807fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020498c:	57f1                	li	a5,-4
            goto failed;
ffffffffc020498e:	bf4d                	j	ffffffffc0204940 <do_pgfault+0x72>

ffffffffc0204990 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204990:	7179                	addi	sp,sp,-48
ffffffffc0204992:	f022                	sd	s0,32(sp)
ffffffffc0204994:	f406                	sd	ra,40(sp)
ffffffffc0204996:	ec26                	sd	s1,24(sp)
ffffffffc0204998:	e84a                	sd	s2,16(sp)
ffffffffc020499a:	e44e                	sd	s3,8(sp)
ffffffffc020499c:	e052                	sd	s4,0(sp)
ffffffffc020499e:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc02049a0:	c135                	beqz	a0,ffffffffc0204a04 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc02049a2:	002007b7          	lui	a5,0x200
ffffffffc02049a6:	04f5e663          	bltu	a1,a5,ffffffffc02049f2 <user_mem_check+0x62>
ffffffffc02049aa:	00c584b3          	add	s1,a1,a2
ffffffffc02049ae:	0495f263          	bgeu	a1,s1,ffffffffc02049f2 <user_mem_check+0x62>
ffffffffc02049b2:	4785                	li	a5,1
ffffffffc02049b4:	07fe                	slli	a5,a5,0x1f
ffffffffc02049b6:	0297ee63          	bltu	a5,s1,ffffffffc02049f2 <user_mem_check+0x62>
ffffffffc02049ba:	892a                	mv	s2,a0
ffffffffc02049bc:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049be:	6a05                	lui	s4,0x1
ffffffffc02049c0:	a821                	j	ffffffffc02049d8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049c2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049c6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049c8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049ca:	c685                	beqz	a3,ffffffffc02049f2 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049cc:	c399                	beqz	a5,ffffffffc02049d2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049ce:	02e46263          	bltu	s0,a4,ffffffffc02049f2 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02049d2:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02049d4:	04947663          	bgeu	s0,s1,ffffffffc0204a20 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02049d8:	85a2                	mv	a1,s0
ffffffffc02049da:	854a                	mv	a0,s2
ffffffffc02049dc:	e8aff0ef          	jal	ra,ffffffffc0204066 <find_vma>
ffffffffc02049e0:	c909                	beqz	a0,ffffffffc02049f2 <user_mem_check+0x62>
ffffffffc02049e2:	6518                	ld	a4,8(a0)
ffffffffc02049e4:	00e46763          	bltu	s0,a4,ffffffffc02049f2 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049e8:	4d1c                	lw	a5,24(a0)
ffffffffc02049ea:	fc099ce3          	bnez	s3,ffffffffc02049c2 <user_mem_check+0x32>
ffffffffc02049ee:	8b85                	andi	a5,a5,1
ffffffffc02049f0:	f3ed                	bnez	a5,ffffffffc02049d2 <user_mem_check+0x42>
            return 0;
ffffffffc02049f2:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02049f4:	70a2                	ld	ra,40(sp)
ffffffffc02049f6:	7402                	ld	s0,32(sp)
ffffffffc02049f8:	64e2                	ld	s1,24(sp)
ffffffffc02049fa:	6942                	ld	s2,16(sp)
ffffffffc02049fc:	69a2                	ld	s3,8(sp)
ffffffffc02049fe:	6a02                	ld	s4,0(sp)
ffffffffc0204a00:	6145                	addi	sp,sp,48
ffffffffc0204a02:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204a04:	c02007b7          	lui	a5,0xc0200
ffffffffc0204a08:	4501                	li	a0,0
ffffffffc0204a0a:	fef5e5e3          	bltu	a1,a5,ffffffffc02049f4 <user_mem_check+0x64>
ffffffffc0204a0e:	962e                	add	a2,a2,a1
ffffffffc0204a10:	fec5f2e3          	bgeu	a1,a2,ffffffffc02049f4 <user_mem_check+0x64>
ffffffffc0204a14:	c8000537          	lui	a0,0xc8000
ffffffffc0204a18:	0505                	addi	a0,a0,1
ffffffffc0204a1a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204a1e:	bfd9                	j	ffffffffc02049f4 <user_mem_check+0x64>
        return 1;
ffffffffc0204a20:	4505                	li	a0,1
ffffffffc0204a22:	bfc9                	j	ffffffffc02049f4 <user_mem_check+0x64>

ffffffffc0204a24 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204a24:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a26:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204a28:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a2a:	bcdfb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204a2e:	cd01                	beqz	a0,ffffffffc0204a46 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a30:	4505                	li	a0,1
ffffffffc0204a32:	bcbfb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204a36:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a38:	810d                	srli	a0,a0,0x3
ffffffffc0204a3a:	000a8797          	auipc	a5,0xa8
ffffffffc0204a3e:	eea7b723          	sd	a0,-274(a5) # ffffffffc02ac928 <max_swap_offset>
}
ffffffffc0204a42:	0141                	addi	sp,sp,16
ffffffffc0204a44:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204a46:	00003617          	auipc	a2,0x3
ffffffffc0204a4a:	64a60613          	addi	a2,a2,1610 # ffffffffc0208090 <default_pmm_manager+0xfd8>
ffffffffc0204a4e:	45b5                	li	a1,13
ffffffffc0204a50:	00003517          	auipc	a0,0x3
ffffffffc0204a54:	66050513          	addi	a0,a0,1632 # ffffffffc02080b0 <default_pmm_manager+0xff8>
ffffffffc0204a58:	a29fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204a5c <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204a5c:	1141                	addi	sp,sp,-16
ffffffffc0204a5e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a60:	00855793          	srli	a5,a0,0x8
ffffffffc0204a64:	cfb9                	beqz	a5,ffffffffc0204ac2 <swapfs_write+0x66>
ffffffffc0204a66:	000a8717          	auipc	a4,0xa8
ffffffffc0204a6a:	ec270713          	addi	a4,a4,-318 # ffffffffc02ac928 <max_swap_offset>
ffffffffc0204a6e:	6318                	ld	a4,0(a4)
ffffffffc0204a70:	04e7f963          	bgeu	a5,a4,ffffffffc0204ac2 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204a74:	000a8717          	auipc	a4,0xa8
ffffffffc0204a78:	e2470713          	addi	a4,a4,-476 # ffffffffc02ac898 <pages>
ffffffffc0204a7c:	6310                	ld	a2,0(a4)
ffffffffc0204a7e:	00004717          	auipc	a4,0x4
ffffffffc0204a82:	f6270713          	addi	a4,a4,-158 # ffffffffc02089e0 <nbase>
ffffffffc0204a86:	40c58633          	sub	a2,a1,a2
ffffffffc0204a8a:	630c                	ld	a1,0(a4)
ffffffffc0204a8c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204a8e:	000a8717          	auipc	a4,0xa8
ffffffffc0204a92:	d9a70713          	addi	a4,a4,-614 # ffffffffc02ac828 <npage>
    return page - pages + nbase;
ffffffffc0204a96:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204a98:	6314                	ld	a3,0(a4)
ffffffffc0204a9a:	00c61713          	slli	a4,a2,0xc
ffffffffc0204a9e:	8331                	srli	a4,a4,0xc
ffffffffc0204aa0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204aa4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204aa6:	02d77a63          	bgeu	a4,a3,ffffffffc0204ada <swapfs_write+0x7e>
ffffffffc0204aaa:	000a8797          	auipc	a5,0xa8
ffffffffc0204aae:	dde78793          	addi	a5,a5,-546 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0204ab2:	639c                	ld	a5,0(a5)
}
ffffffffc0204ab4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ab6:	46a1                	li	a3,8
ffffffffc0204ab8:	963e                	add	a2,a2,a5
ffffffffc0204aba:	4505                	li	a0,1
}
ffffffffc0204abc:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204abe:	b45fb06f          	j	ffffffffc0200602 <ide_write_secs>
ffffffffc0204ac2:	86aa                	mv	a3,a0
ffffffffc0204ac4:	00003617          	auipc	a2,0x3
ffffffffc0204ac8:	60460613          	addi	a2,a2,1540 # ffffffffc02080c8 <default_pmm_manager+0x1010>
ffffffffc0204acc:	45e5                	li	a1,25
ffffffffc0204ace:	00003517          	auipc	a0,0x3
ffffffffc0204ad2:	5e250513          	addi	a0,a0,1506 # ffffffffc02080b0 <default_pmm_manager+0xff8>
ffffffffc0204ad6:	9abfb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204ada:	86b2                	mv	a3,a2
ffffffffc0204adc:	06900593          	li	a1,105
ffffffffc0204ae0:	00002617          	auipc	a2,0x2
ffffffffc0204ae4:	62860613          	addi	a2,a2,1576 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0204ae8:	00002517          	auipc	a0,0x2
ffffffffc0204aec:	64850513          	addi	a0,a0,1608 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0204af0:	991fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204af4 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204af4:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204af6:	9402                	jalr	s0

	jal do_exit
ffffffffc0204af8:	6ae000ef          	jal	ra,ffffffffc02051a6 <do_exit>

ffffffffc0204afc <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204afc:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204afe:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204b02:	e022                	sd	s0,0(sp)
ffffffffc0204b04:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204b06:	902fd0ef          	jal	ra,ffffffffc0201c08 <kmalloc>
ffffffffc0204b0a:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204b0c:	c939                	beqz	a0,ffffffffc0204b62 <alloc_proc+0x66>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */

    proc->state = PROC_UNINIT;
ffffffffc0204b0e:	57fd                	li	a5,-1
ffffffffc0204b10:	1782                	slli	a5,a5,0x20
ffffffffc0204b12:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204b14:	07000613          	li	a2,112
ffffffffc0204b18:	4581                	li	a1,0
    proc->cptr = NULL; // 初始化 cptr 为 NULL，表示没有子进程
ffffffffc0204b1a:	0e053823          	sd	zero,240(a0)
    proc->yptr = NULL; // 初始化 yptr 为 NULL，表示没有“年轻”兄弟进程
ffffffffc0204b1e:	0e053c23          	sd	zero,248(a0)
    proc->optr = NULL; // 初始化 optr 为 NULL，表示没有“老”兄弟进程
ffffffffc0204b22:	10053023          	sd	zero,256(a0)
    proc->runs = 0;
ffffffffc0204b26:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204b2a:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204b2e:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204b32:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204b36:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204b3a:	03050513          	addi	a0,a0,48
ffffffffc0204b3e:	015010ef          	jal	ra,ffffffffc0206352 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204b42:	000a8797          	auipc	a5,0xa8
ffffffffc0204b46:	d4e78793          	addi	a5,a5,-690 # ffffffffc02ac890 <boot_cr3>
ffffffffc0204b4a:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc0204b4c:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204b50:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204b54:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204b56:	4641                	li	a2,16
ffffffffc0204b58:	4581                	li	a1,0
ffffffffc0204b5a:	0b440513          	addi	a0,s0,180
ffffffffc0204b5e:	7f4010ef          	jal	ra,ffffffffc0206352 <memset>
    }
    return proc;
}
ffffffffc0204b62:	8522                	mv	a0,s0
ffffffffc0204b64:	60a2                	ld	ra,8(sp)
ffffffffc0204b66:	6402                	ld	s0,0(sp)
ffffffffc0204b68:	0141                	addi	sp,sp,16
ffffffffc0204b6a:	8082                	ret

ffffffffc0204b6c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204b6c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b70:	cd478793          	addi	a5,a5,-812 # ffffffffc02ac840 <current>
ffffffffc0204b74:	639c                	ld	a5,0(a5)
ffffffffc0204b76:	73c8                	ld	a0,160(a5)
ffffffffc0204b78:	9f6fc06f          	j	ffffffffc0200d6e <forkrets>

ffffffffc0204b7c <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204b7c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b80:	cc478793          	addi	a5,a5,-828 # ffffffffc02ac840 <current>
ffffffffc0204b84:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204b86:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204b88:	00004617          	auipc	a2,0x4
ffffffffc0204b8c:	93060613          	addi	a2,a2,-1744 # ffffffffc02084b8 <default_pmm_manager+0x1400>
ffffffffc0204b90:	43cc                	lw	a1,4(a5)
ffffffffc0204b92:	00004517          	auipc	a0,0x4
ffffffffc0204b96:	92e50513          	addi	a0,a0,-1746 # ffffffffc02084c0 <default_pmm_manager+0x1408>
user_main(void *arg) {
ffffffffc0204b9a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204b9c:	df2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204ba0:	00004797          	auipc	a5,0x4
ffffffffc0204ba4:	91878793          	addi	a5,a5,-1768 # ffffffffc02084b8 <default_pmm_manager+0x1400>
ffffffffc0204ba8:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204bac:	f2070713          	addi	a4,a4,-224 # aac8 <_binary_obj___user_exit_out_size>
ffffffffc0204bb0:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204bb2:	853e                	mv	a0,a5
ffffffffc0204bb4:	00025717          	auipc	a4,0x25
ffffffffc0204bb8:	69c70713          	addi	a4,a4,1692 # ffffffffc022a250 <_binary_obj___user_exit_out_start>
ffffffffc0204bbc:	f03a                	sd	a4,32(sp)
ffffffffc0204bbe:	f43e                	sd	a5,40(sp)
ffffffffc0204bc0:	e802                	sd	zero,16(sp)
ffffffffc0204bc2:	6f2010ef          	jal	ra,ffffffffc02062b4 <strlen>
ffffffffc0204bc6:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204bc8:	4511                	li	a0,4
ffffffffc0204bca:	55a2                	lw	a1,40(sp)
ffffffffc0204bcc:	4662                	lw	a2,24(sp)
ffffffffc0204bce:	5682                	lw	a3,32(sp)
ffffffffc0204bd0:	4722                	lw	a4,8(sp)
ffffffffc0204bd2:	48a9                	li	a7,10
ffffffffc0204bd4:	9002                	ebreak
ffffffffc0204bd6:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204bd8:	65c2                	ld	a1,16(sp)
ffffffffc0204bda:	00004517          	auipc	a0,0x4
ffffffffc0204bde:	90e50513          	addi	a0,a0,-1778 # ffffffffc02084e8 <default_pmm_manager+0x1430>
ffffffffc0204be2:	dacfb0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204be6:	00004617          	auipc	a2,0x4
ffffffffc0204bea:	91260613          	addi	a2,a2,-1774 # ffffffffc02084f8 <default_pmm_manager+0x1440>
ffffffffc0204bee:	36000593          	li	a1,864
ffffffffc0204bf2:	00004517          	auipc	a0,0x4
ffffffffc0204bf6:	92650513          	addi	a0,a0,-1754 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0204bfa:	887fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204bfe <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204bfe:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204c00:	1141                	addi	sp,sp,-16
ffffffffc0204c02:	e406                	sd	ra,8(sp)
ffffffffc0204c04:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c08:	04f6e263          	bltu	a3,a5,ffffffffc0204c4c <put_pgdir+0x4e>
ffffffffc0204c0c:	000a8797          	auipc	a5,0xa8
ffffffffc0204c10:	c7c78793          	addi	a5,a5,-900 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0204c14:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204c16:	000a8797          	auipc	a5,0xa8
ffffffffc0204c1a:	c1278793          	addi	a5,a5,-1006 # ffffffffc02ac828 <npage>
ffffffffc0204c1e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204c20:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204c22:	82b1                	srli	a3,a3,0xc
ffffffffc0204c24:	04f6f063          	bgeu	a3,a5,ffffffffc0204c64 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204c28:	00004797          	auipc	a5,0x4
ffffffffc0204c2c:	db878793          	addi	a5,a5,-584 # ffffffffc02089e0 <nbase>
ffffffffc0204c30:	639c                	ld	a5,0(a5)
ffffffffc0204c32:	000a8717          	auipc	a4,0xa8
ffffffffc0204c36:	c6670713          	addi	a4,a4,-922 # ffffffffc02ac898 <pages>
ffffffffc0204c3a:	6308                	ld	a0,0(a4)
}
ffffffffc0204c3c:	60a2                	ld	ra,8(sp)
ffffffffc0204c3e:	8e9d                	sub	a3,a3,a5
ffffffffc0204c40:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204c42:	4585                	li	a1,1
ffffffffc0204c44:	9536                	add	a0,a0,a3
}
ffffffffc0204c46:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204c48:	a40fd06f          	j	ffffffffc0201e88 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204c4c:	00002617          	auipc	a2,0x2
ffffffffc0204c50:	4f460613          	addi	a2,a2,1268 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc0204c54:	06e00593          	li	a1,110
ffffffffc0204c58:	00002517          	auipc	a0,0x2
ffffffffc0204c5c:	4d850513          	addi	a0,a0,1240 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0204c60:	821fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c64:	00002617          	auipc	a2,0x2
ffffffffc0204c68:	50460613          	addi	a2,a2,1284 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0204c6c:	06200593          	li	a1,98
ffffffffc0204c70:	00002517          	auipc	a0,0x2
ffffffffc0204c74:	4c050513          	addi	a0,a0,1216 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0204c78:	809fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204c7c <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c7c:	1101                	addi	sp,sp,-32
ffffffffc0204c7e:	e426                	sd	s1,8(sp)
ffffffffc0204c80:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c82:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c84:	ec06                	sd	ra,24(sp)
ffffffffc0204c86:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c88:	978fd0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
ffffffffc0204c8c:	c125                	beqz	a0,ffffffffc0204cec <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204c8e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c92:	c0a78793          	addi	a5,a5,-1014 # ffffffffc02ac898 <pages>
ffffffffc0204c96:	6394                	ld	a3,0(a5)
ffffffffc0204c98:	00004797          	auipc	a5,0x4
ffffffffc0204c9c:	d4878793          	addi	a5,a5,-696 # ffffffffc02089e0 <nbase>
ffffffffc0204ca0:	6380                	ld	s0,0(a5)
ffffffffc0204ca2:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204ca6:	000a8797          	auipc	a5,0xa8
ffffffffc0204caa:	b8278793          	addi	a5,a5,-1150 # ffffffffc02ac828 <npage>
    return page - pages + nbase;
ffffffffc0204cae:	8699                	srai	a3,a3,0x6
ffffffffc0204cb0:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204cb2:	6398                	ld	a4,0(a5)
ffffffffc0204cb4:	00c69793          	slli	a5,a3,0xc
ffffffffc0204cb8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cbc:	02e7fa63          	bgeu	a5,a4,ffffffffc0204cf0 <setup_pgdir+0x74>
ffffffffc0204cc0:	000a8797          	auipc	a5,0xa8
ffffffffc0204cc4:	bc878793          	addi	a5,a5,-1080 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0204cc8:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204cca:	000a8797          	auipc	a5,0xa8
ffffffffc0204cce:	b5678793          	addi	a5,a5,-1194 # ffffffffc02ac820 <boot_pgdir>
ffffffffc0204cd2:	638c                	ld	a1,0(a5)
ffffffffc0204cd4:	9436                	add	s0,s0,a3
ffffffffc0204cd6:	6605                	lui	a2,0x1
ffffffffc0204cd8:	8522                	mv	a0,s0
ffffffffc0204cda:	68a010ef          	jal	ra,ffffffffc0206364 <memcpy>
    return 0;
ffffffffc0204cde:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ce0:	ec80                	sd	s0,24(s1)
}
ffffffffc0204ce2:	60e2                	ld	ra,24(sp)
ffffffffc0204ce4:	6442                	ld	s0,16(sp)
ffffffffc0204ce6:	64a2                	ld	s1,8(sp)
ffffffffc0204ce8:	6105                	addi	sp,sp,32
ffffffffc0204cea:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204cec:	5571                	li	a0,-4
ffffffffc0204cee:	bfd5                	j	ffffffffc0204ce2 <setup_pgdir+0x66>
ffffffffc0204cf0:	00002617          	auipc	a2,0x2
ffffffffc0204cf4:	41860613          	addi	a2,a2,1048 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0204cf8:	06900593          	li	a1,105
ffffffffc0204cfc:	00002517          	auipc	a0,0x2
ffffffffc0204d00:	43450513          	addi	a0,a0,1076 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0204d04:	f7cfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204d08 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d08:	1101                	addi	sp,sp,-32
ffffffffc0204d0a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d0c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d10:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d12:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d14:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d16:	8522                	mv	a0,s0
ffffffffc0204d18:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d1a:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d1c:	636010ef          	jal	ra,ffffffffc0206352 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d20:	8522                	mv	a0,s0
}
ffffffffc0204d22:	6442                	ld	s0,16(sp)
ffffffffc0204d24:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d26:	85a6                	mv	a1,s1
}
ffffffffc0204d28:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d2a:	463d                	li	a2,15
}
ffffffffc0204d2c:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d2e:	6360106f          	j	ffffffffc0206364 <memcpy>

ffffffffc0204d32 <proc_run>:
}
ffffffffc0204d32:	8082                	ret

ffffffffc0204d34 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204d34:	0005071b          	sext.w	a4,a0
ffffffffc0204d38:	6789                	lui	a5,0x2
ffffffffc0204d3a:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204d3e:	17f9                	addi	a5,a5,-2
ffffffffc0204d40:	04d7e063          	bltu	a5,a3,ffffffffc0204d80 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204d44:	1141                	addi	sp,sp,-16
ffffffffc0204d46:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d48:	45a9                	li	a1,10
ffffffffc0204d4a:	842a                	mv	s0,a0
ffffffffc0204d4c:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204d4e:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d50:	160010ef          	jal	ra,ffffffffc0205eb0 <hash32>
ffffffffc0204d54:	02051693          	slli	a3,a0,0x20
ffffffffc0204d58:	82f1                	srli	a3,a3,0x1c
ffffffffc0204d5a:	000a4517          	auipc	a0,0xa4
ffffffffc0204d5e:	aae50513          	addi	a0,a0,-1362 # ffffffffc02a8808 <hash_list>
ffffffffc0204d62:	96aa                	add	a3,a3,a0
ffffffffc0204d64:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204d66:	a029                	j	ffffffffc0204d70 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204d68:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc0204d6c:	00870c63          	beq	a4,s0,ffffffffc0204d84 <find_proc+0x50>
ffffffffc0204d70:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204d72:	fef69be3          	bne	a3,a5,ffffffffc0204d68 <find_proc+0x34>
}
ffffffffc0204d76:	60a2                	ld	ra,8(sp)
ffffffffc0204d78:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204d7a:	4501                	li	a0,0
}
ffffffffc0204d7c:	0141                	addi	sp,sp,16
ffffffffc0204d7e:	8082                	ret
    return NULL;
ffffffffc0204d80:	4501                	li	a0,0
}
ffffffffc0204d82:	8082                	ret
ffffffffc0204d84:	60a2                	ld	ra,8(sp)
ffffffffc0204d86:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204d88:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204d8c:	0141                	addi	sp,sp,16
ffffffffc0204d8e:	8082                	ret

ffffffffc0204d90 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204d90:	715d                	addi	sp,sp,-80
ffffffffc0204d92:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204d94:	000a8917          	auipc	s2,0xa8
ffffffffc0204d98:	ac490913          	addi	s2,s2,-1340 # ffffffffc02ac858 <nr_process>
ffffffffc0204d9c:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204da0:	e486                	sd	ra,72(sp)
ffffffffc0204da2:	e0a2                	sd	s0,64(sp)
ffffffffc0204da4:	fc26                	sd	s1,56(sp)
ffffffffc0204da6:	f44e                	sd	s3,40(sp)
ffffffffc0204da8:	f052                	sd	s4,32(sp)
ffffffffc0204daa:	ec56                	sd	s5,24(sp)
ffffffffc0204dac:	e85a                	sd	s6,16(sp)
ffffffffc0204dae:	e45e                	sd	s7,8(sp)
ffffffffc0204db0:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204db2:	6785                	lui	a5,0x1
ffffffffc0204db4:	32f75263          	bge	a4,a5,ffffffffc02050d8 <do_fork+0x348>
ffffffffc0204db8:	8aaa                	mv	s5,a0
ffffffffc0204dba:	89ae                	mv	s3,a1
ffffffffc0204dbc:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204dbe:	d3fff0ef          	jal	ra,ffffffffc0204afc <alloc_proc>
ffffffffc0204dc2:	842a                	mv	s0,a0
ffffffffc0204dc4:	2a050763          	beqz	a0,ffffffffc0205072 <do_fork+0x2e2>
    current->wait_state = 0;
ffffffffc0204dc8:	000a8a17          	auipc	s4,0xa8
ffffffffc0204dcc:	a78a0a13          	addi	s4,s4,-1416 # ffffffffc02ac840 <current>
ffffffffc0204dd0:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204dd4:	4509                	li	a0,2
    current->wait_state = 0;
ffffffffc0204dd6:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;
ffffffffc0204dda:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204ddc:	824fd0ef          	jal	ra,ffffffffc0201e00 <alloc_pages>
    if (page != NULL) {
ffffffffc0204de0:	2a050763          	beqz	a0,ffffffffc020508e <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc0204de4:	000a8797          	auipc	a5,0xa8
ffffffffc0204de8:	ab478793          	addi	a5,a5,-1356 # ffffffffc02ac898 <pages>
ffffffffc0204dec:	6394                	ld	a3,0(a5)
ffffffffc0204dee:	00004797          	auipc	a5,0x4
ffffffffc0204df2:	bf278793          	addi	a5,a5,-1038 # ffffffffc02089e0 <nbase>
ffffffffc0204df6:	40d506b3          	sub	a3,a0,a3
ffffffffc0204dfa:	6388                	ld	a0,0(a5)
ffffffffc0204dfc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204dfe:	000a8797          	auipc	a5,0xa8
ffffffffc0204e02:	a2a78793          	addi	a5,a5,-1494 # ffffffffc02ac828 <npage>
    return page - pages + nbase;
ffffffffc0204e06:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204e08:	6398                	ld	a4,0(a5)
ffffffffc0204e0a:	00c69793          	slli	a5,a3,0xc
ffffffffc0204e0e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e12:	2ce7f563          	bgeu	a5,a4,ffffffffc02050dc <do_fork+0x34c>
ffffffffc0204e16:	000a8b17          	auipc	s6,0xa8
ffffffffc0204e1a:	a72b0b13          	addi	s6,s6,-1422 # ffffffffc02ac888 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204e1e:	000a3703          	ld	a4,0(s4)
ffffffffc0204e22:	000b3783          	ld	a5,0(s6)
ffffffffc0204e26:	02873a03          	ld	s4,40(a4)
ffffffffc0204e2a:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204e2c:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0204e2e:	020a0863          	beqz	s4,ffffffffc0204e5e <do_fork+0xce>
    if (clone_flags & CLONE_VM) {
ffffffffc0204e32:	100afa93          	andi	s5,s5,256
ffffffffc0204e36:	1e0a8163          	beqz	s5,ffffffffc0205018 <do_fork+0x288>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204e3a:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e3e:	018a3783          	ld	a5,24(s4)
ffffffffc0204e42:	c02006b7          	lui	a3,0xc0200
ffffffffc0204e46:	2705                	addiw	a4,a4,1
ffffffffc0204e48:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc0204e4c:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e50:	2ad7e263          	bltu	a5,a3,ffffffffc02050f4 <do_fork+0x364>
ffffffffc0204e54:	000b3703          	ld	a4,0(s6)
ffffffffc0204e58:	6814                	ld	a3,16(s0)
ffffffffc0204e5a:	8f99                	sub	a5,a5,a4
ffffffffc0204e5c:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e5e:	6789                	lui	a5,0x2
ffffffffc0204e60:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc0204e64:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204e66:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e68:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204e6a:	87b6                	mv	a5,a3
ffffffffc0204e6c:	12048893          	addi	a7,s1,288
ffffffffc0204e70:	00063803          	ld	a6,0(a2)
ffffffffc0204e74:	6608                	ld	a0,8(a2)
ffffffffc0204e76:	6a0c                	ld	a1,16(a2)
ffffffffc0204e78:	6e18                	ld	a4,24(a2)
ffffffffc0204e7a:	0107b023          	sd	a6,0(a5)
ffffffffc0204e7e:	e788                	sd	a0,8(a5)
ffffffffc0204e80:	eb8c                	sd	a1,16(a5)
ffffffffc0204e82:	ef98                	sd	a4,24(a5)
ffffffffc0204e84:	02060613          	addi	a2,a2,32
ffffffffc0204e88:	02078793          	addi	a5,a5,32
ffffffffc0204e8c:	ff1612e3          	bne	a2,a7,ffffffffc0204e70 <do_fork+0xe0>
    proc->tf->gpr.a0 = 0;
ffffffffc0204e90:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204e94:	12098b63          	beqz	s3,ffffffffc0204fca <do_fork+0x23a>
ffffffffc0204e98:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204e9c:	00000797          	auipc	a5,0x0
ffffffffc0204ea0:	cd078793          	addi	a5,a5,-816 # ffffffffc0204b6c <forkret>
ffffffffc0204ea4:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204ea6:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ea8:	100027f3          	csrr	a5,sstatus
ffffffffc0204eac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204eae:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204eb0:	12079c63          	bnez	a5,ffffffffc0204fe8 <do_fork+0x258>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204eb4:	0009c797          	auipc	a5,0x9c
ffffffffc0204eb8:	54c78793          	addi	a5,a5,1356 # ffffffffc02a1400 <last_pid.1691>
ffffffffc0204ebc:	439c                	lw	a5,0(a5)
ffffffffc0204ebe:	6709                	lui	a4,0x2
ffffffffc0204ec0:	0017851b          	addiw	a0,a5,1
ffffffffc0204ec4:	0009c697          	auipc	a3,0x9c
ffffffffc0204ec8:	52a6ae23          	sw	a0,1340(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0204ecc:	12e55f63          	bge	a0,a4,ffffffffc020500a <do_fork+0x27a>
    if (last_pid >= next_safe) {
ffffffffc0204ed0:	0009c797          	auipc	a5,0x9c
ffffffffc0204ed4:	53478793          	addi	a5,a5,1332 # ffffffffc02a1404 <next_safe.1690>
ffffffffc0204ed8:	439c                	lw	a5,0(a5)
ffffffffc0204eda:	000a8497          	auipc	s1,0xa8
ffffffffc0204ede:	aa648493          	addi	s1,s1,-1370 # ffffffffc02ac980 <proc_list>
ffffffffc0204ee2:	06f54063          	blt	a0,a5,ffffffffc0204f42 <do_fork+0x1b2>
        next_safe = MAX_PID;
ffffffffc0204ee6:	6789                	lui	a5,0x2
ffffffffc0204ee8:	0009c717          	auipc	a4,0x9c
ffffffffc0204eec:	50f72e23          	sw	a5,1308(a4) # ffffffffc02a1404 <next_safe.1690>
ffffffffc0204ef0:	4581                	li	a1,0
ffffffffc0204ef2:	87aa                	mv	a5,a0
ffffffffc0204ef4:	000a8497          	auipc	s1,0xa8
ffffffffc0204ef8:	a8c48493          	addi	s1,s1,-1396 # ffffffffc02ac980 <proc_list>
    repeat:
ffffffffc0204efc:	6889                	lui	a7,0x2
ffffffffc0204efe:	882e                	mv	a6,a1
ffffffffc0204f00:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204f02:	000a8697          	auipc	a3,0xa8
ffffffffc0204f06:	a7e68693          	addi	a3,a3,-1410 # ffffffffc02ac980 <proc_list>
ffffffffc0204f0a:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204f0c:	00968f63          	beq	a3,s1,ffffffffc0204f2a <do_fork+0x19a>
            if (proc->pid == last_pid) {
ffffffffc0204f10:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204f14:	0ae78663          	beq	a5,a4,ffffffffc0204fc0 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204f18:	fee7d9e3          	bge	a5,a4,ffffffffc0204f0a <do_fork+0x17a>
ffffffffc0204f1c:	fec757e3          	bge	a4,a2,ffffffffc0204f0a <do_fork+0x17a>
ffffffffc0204f20:	6694                	ld	a3,8(a3)
ffffffffc0204f22:	863a                	mv	a2,a4
ffffffffc0204f24:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204f26:	fe9695e3          	bne	a3,s1,ffffffffc0204f10 <do_fork+0x180>
ffffffffc0204f2a:	c591                	beqz	a1,ffffffffc0204f36 <do_fork+0x1a6>
ffffffffc0204f2c:	0009c717          	auipc	a4,0x9c
ffffffffc0204f30:	4cf72a23          	sw	a5,1236(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0204f34:	853e                	mv	a0,a5
ffffffffc0204f36:	00080663          	beqz	a6,ffffffffc0204f42 <do_fork+0x1b2>
ffffffffc0204f3a:	0009c797          	auipc	a5,0x9c
ffffffffc0204f3e:	4cc7a523          	sw	a2,1226(a5) # ffffffffc02a1404 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0204f42:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f44:	45a9                	li	a1,10
ffffffffc0204f46:	2501                	sext.w	a0,a0
ffffffffc0204f48:	769000ef          	jal	ra,ffffffffc0205eb0 <hash32>
ffffffffc0204f4c:	1502                	slli	a0,a0,0x20
ffffffffc0204f4e:	000a4797          	auipc	a5,0xa4
ffffffffc0204f52:	8ba78793          	addi	a5,a5,-1862 # ffffffffc02a8808 <hash_list>
ffffffffc0204f56:	8171                	srli	a0,a0,0x1c
ffffffffc0204f58:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f5a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f5c:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f5e:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0204f62:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f64:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204f66:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f68:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204f6a:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204f6e:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0204f70:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204f72:	e21c                	sd	a5,0(a2)
ffffffffc0204f74:	000a8597          	auipc	a1,0xa8
ffffffffc0204f78:	a0f5ba23          	sd	a5,-1516(a1) # ffffffffc02ac988 <proc_list+0x8>
    elm->next = next;
ffffffffc0204f7c:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204f7e:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0204f80:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f84:	10e43023          	sd	a4,256(s0)
ffffffffc0204f88:	c311                	beqz	a4,ffffffffc0204f8c <do_fork+0x1fc>
        proc->optr->yptr = proc;
ffffffffc0204f8a:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0204f8c:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204f90:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0204f92:	2785                	addiw	a5,a5,1
ffffffffc0204f94:	000a8717          	auipc	a4,0xa8
ffffffffc0204f98:	8cf72223          	sw	a5,-1852(a4) # ffffffffc02ac858 <nr_process>
    if (flag) {
ffffffffc0204f9c:	0c099d63          	bnez	s3,ffffffffc0205076 <do_fork+0x2e6>
    wakeup_proc(proc);
ffffffffc0204fa0:	8522                	mv	a0,s0
ffffffffc0204fa2:	51d000ef          	jal	ra,ffffffffc0205cbe <wakeup_proc>
    ret = proc->pid;
ffffffffc0204fa6:	4048                	lw	a0,4(s0)
}
ffffffffc0204fa8:	60a6                	ld	ra,72(sp)
ffffffffc0204faa:	6406                	ld	s0,64(sp)
ffffffffc0204fac:	74e2                	ld	s1,56(sp)
ffffffffc0204fae:	7942                	ld	s2,48(sp)
ffffffffc0204fb0:	79a2                	ld	s3,40(sp)
ffffffffc0204fb2:	7a02                	ld	s4,32(sp)
ffffffffc0204fb4:	6ae2                	ld	s5,24(sp)
ffffffffc0204fb6:	6b42                	ld	s6,16(sp)
ffffffffc0204fb8:	6ba2                	ld	s7,8(sp)
ffffffffc0204fba:	6c02                	ld	s8,0(sp)
ffffffffc0204fbc:	6161                	addi	sp,sp,80
ffffffffc0204fbe:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204fc0:	2785                	addiw	a5,a5,1
ffffffffc0204fc2:	0ac7dd63          	bge	a5,a2,ffffffffc020507c <do_fork+0x2ec>
ffffffffc0204fc6:	4585                	li	a1,1
ffffffffc0204fc8:	b789                	j	ffffffffc0204f0a <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204fca:	89b6                	mv	s3,a3
ffffffffc0204fcc:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204fd0:	00000797          	auipc	a5,0x0
ffffffffc0204fd4:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0204b6c <forkret>
ffffffffc0204fd8:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204fda:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204fdc:	100027f3          	csrr	a5,sstatus
ffffffffc0204fe0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204fe2:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204fe4:	ec0788e3          	beqz	a5,ffffffffc0204eb4 <do_fork+0x124>
        intr_disable();
ffffffffc0204fe8:	e46fb0ef          	jal	ra,ffffffffc020062e <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204fec:	0009c797          	auipc	a5,0x9c
ffffffffc0204ff0:	41478793          	addi	a5,a5,1044 # ffffffffc02a1400 <last_pid.1691>
ffffffffc0204ff4:	439c                	lw	a5,0(a5)
ffffffffc0204ff6:	6709                	lui	a4,0x2
        return 1;
ffffffffc0204ff8:	4985                	li	s3,1
ffffffffc0204ffa:	0017851b          	addiw	a0,a5,1
ffffffffc0204ffe:	0009c697          	auipc	a3,0x9c
ffffffffc0205002:	40a6a123          	sw	a0,1026(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0205006:	ece545e3          	blt	a0,a4,ffffffffc0204ed0 <do_fork+0x140>
        last_pid = 1;
ffffffffc020500a:	4785                	li	a5,1
ffffffffc020500c:	0009c717          	auipc	a4,0x9c
ffffffffc0205010:	3ef72a23          	sw	a5,1012(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc0205014:	4505                	li	a0,1
ffffffffc0205016:	bdc1                	j	ffffffffc0204ee6 <do_fork+0x156>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205018:	fd5fe0ef          	jal	ra,ffffffffc0203fec <mm_create>
ffffffffc020501c:	8c2a                	mv	s8,a0
ffffffffc020501e:	c539                	beqz	a0,ffffffffc020506c <do_fork+0x2dc>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205020:	c5dff0ef          	jal	ra,ffffffffc0204c7c <setup_pgdir>
ffffffffc0205024:	e12d                	bnez	a0,ffffffffc0205086 <do_fork+0x2f6>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205026:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020502a:	4785                	li	a5,1
ffffffffc020502c:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc0205030:	8b85                	andi	a5,a5,1
ffffffffc0205032:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205034:	c799                	beqz	a5,ffffffffc0205042 <do_fork+0x2b2>
        schedule();
ffffffffc0205036:	505000ef          	jal	ra,ffffffffc0205d3a <schedule>
ffffffffc020503a:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc020503e:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205040:	fbfd                	bnez	a5,ffffffffc0205036 <do_fork+0x2a6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205042:	85d2                	mv	a1,s4
ffffffffc0205044:	8562                	mv	a0,s8
ffffffffc0205046:	a30ff0ef          	jal	ra,ffffffffc0204276 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020504a:	57f9                	li	a5,-2
ffffffffc020504c:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc0205050:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205052:	cfd5                	beqz	a5,ffffffffc020510e <do_fork+0x37e>
    if (ret != 0) {
ffffffffc0205054:	8a62                	mv	s4,s8
ffffffffc0205056:	de0502e3          	beqz	a0,ffffffffc0204e3a <do_fork+0xaa>
    exit_mmap(mm);
ffffffffc020505a:	8562                	mv	a0,s8
ffffffffc020505c:	ab6ff0ef          	jal	ra,ffffffffc0204312 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205060:	8562                	mv	a0,s8
ffffffffc0205062:	b9dff0ef          	jal	ra,ffffffffc0204bfe <put_pgdir>
    mm_destroy(mm);
ffffffffc0205066:	8562                	mv	a0,s8
ffffffffc0205068:	90aff0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
    kfree(proc);
ffffffffc020506c:	8522                	mv	a0,s0
ffffffffc020506e:	c57fc0ef          	jal	ra,ffffffffc0201cc4 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205072:	5571                	li	a0,-4
    return ret;
ffffffffc0205074:	bf15                	j	ffffffffc0204fa8 <do_fork+0x218>
        intr_enable();
ffffffffc0205076:	db2fb0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc020507a:	b71d                	j	ffffffffc0204fa0 <do_fork+0x210>
                    if (last_pid >= MAX_PID) {
ffffffffc020507c:	0117c363          	blt	a5,a7,ffffffffc0205082 <do_fork+0x2f2>
                        last_pid = 1;
ffffffffc0205080:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205082:	4585                	li	a1,1
ffffffffc0205084:	bdad                	j	ffffffffc0204efe <do_fork+0x16e>
    mm_destroy(mm);
ffffffffc0205086:	8562                	mv	a0,s8
ffffffffc0205088:	8eaff0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
ffffffffc020508c:	b7c5                	j	ffffffffc020506c <do_fork+0x2dc>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020508e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205090:	c02007b7          	lui	a5,0xc0200
ffffffffc0205094:	0af6e563          	bltu	a3,a5,ffffffffc020513e <do_fork+0x3ae>
ffffffffc0205098:	000a7797          	auipc	a5,0xa7
ffffffffc020509c:	7f078793          	addi	a5,a5,2032 # ffffffffc02ac888 <va_pa_offset>
ffffffffc02050a0:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02050a2:	000a7717          	auipc	a4,0xa7
ffffffffc02050a6:	78670713          	addi	a4,a4,1926 # ffffffffc02ac828 <npage>
ffffffffc02050aa:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc02050ac:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02050b0:	83b1                	srli	a5,a5,0xc
ffffffffc02050b2:	06e7fa63          	bgeu	a5,a4,ffffffffc0205126 <do_fork+0x396>
    return &pages[PPN(pa) - nbase];
ffffffffc02050b6:	00004717          	auipc	a4,0x4
ffffffffc02050ba:	92a70713          	addi	a4,a4,-1750 # ffffffffc02089e0 <nbase>
ffffffffc02050be:	6318                	ld	a4,0(a4)
ffffffffc02050c0:	000a7697          	auipc	a3,0xa7
ffffffffc02050c4:	7d868693          	addi	a3,a3,2008 # ffffffffc02ac898 <pages>
ffffffffc02050c8:	6288                	ld	a0,0(a3)
ffffffffc02050ca:	8f99                	sub	a5,a5,a4
ffffffffc02050cc:	079a                	slli	a5,a5,0x6
ffffffffc02050ce:	4589                	li	a1,2
ffffffffc02050d0:	953e                	add	a0,a0,a5
ffffffffc02050d2:	db7fc0ef          	jal	ra,ffffffffc0201e88 <free_pages>
ffffffffc02050d6:	bf59                	j	ffffffffc020506c <do_fork+0x2dc>
    int ret = -E_NO_FREE_PROC;
ffffffffc02050d8:	556d                	li	a0,-5
ffffffffc02050da:	b5f9                	j	ffffffffc0204fa8 <do_fork+0x218>
    return KADDR(page2pa(page));
ffffffffc02050dc:	00002617          	auipc	a2,0x2
ffffffffc02050e0:	02c60613          	addi	a2,a2,44 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc02050e4:	06900593          	li	a1,105
ffffffffc02050e8:	00002517          	auipc	a0,0x2
ffffffffc02050ec:	04850513          	addi	a0,a0,72 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc02050f0:	b90fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050f4:	86be                	mv	a3,a5
ffffffffc02050f6:	00002617          	auipc	a2,0x2
ffffffffc02050fa:	04a60613          	addi	a2,a2,74 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc02050fe:	16100593          	li	a1,353
ffffffffc0205102:	00003517          	auipc	a0,0x3
ffffffffc0205106:	41650513          	addi	a0,a0,1046 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc020510a:	b76fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("Unlock failed.\n");
ffffffffc020510e:	00003617          	auipc	a2,0x3
ffffffffc0205112:	1a260613          	addi	a2,a2,418 # ffffffffc02082b0 <default_pmm_manager+0x11f8>
ffffffffc0205116:	03100593          	li	a1,49
ffffffffc020511a:	00003517          	auipc	a0,0x3
ffffffffc020511e:	1a650513          	addi	a0,a0,422 # ffffffffc02082c0 <default_pmm_manager+0x1208>
ffffffffc0205122:	b5efb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205126:	00002617          	auipc	a2,0x2
ffffffffc020512a:	04260613          	addi	a2,a2,66 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc020512e:	06200593          	li	a1,98
ffffffffc0205132:	00002517          	auipc	a0,0x2
ffffffffc0205136:	ffe50513          	addi	a0,a0,-2 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc020513a:	b46fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020513e:	00002617          	auipc	a2,0x2
ffffffffc0205142:	00260613          	addi	a2,a2,2 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc0205146:	06e00593          	li	a1,110
ffffffffc020514a:	00002517          	auipc	a0,0x2
ffffffffc020514e:	fe650513          	addi	a0,a0,-26 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0205152:	b2efb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205156 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205156:	7129                	addi	sp,sp,-320
ffffffffc0205158:	fa22                	sd	s0,304(sp)
ffffffffc020515a:	f626                	sd	s1,296(sp)
ffffffffc020515c:	f24a                	sd	s2,288(sp)
ffffffffc020515e:	84ae                	mv	s1,a1
ffffffffc0205160:	892a                	mv	s2,a0
ffffffffc0205162:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205164:	4581                	li	a1,0
ffffffffc0205166:	12000613          	li	a2,288
ffffffffc020516a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020516c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020516e:	1e4010ef          	jal	ra,ffffffffc0206352 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205172:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205174:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205176:	100027f3          	csrr	a5,sstatus
ffffffffc020517a:	edd7f793          	andi	a5,a5,-291
ffffffffc020517e:	1207e793          	ori	a5,a5,288
ffffffffc0205182:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205184:	860a                	mv	a2,sp
ffffffffc0205186:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020518a:	00000797          	auipc	a5,0x0
ffffffffc020518e:	96a78793          	addi	a5,a5,-1686 # ffffffffc0204af4 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205192:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205194:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205196:	bfbff0ef          	jal	ra,ffffffffc0204d90 <do_fork>
}
ffffffffc020519a:	70f2                	ld	ra,312(sp)
ffffffffc020519c:	7452                	ld	s0,304(sp)
ffffffffc020519e:	74b2                	ld	s1,296(sp)
ffffffffc02051a0:	7912                	ld	s2,288(sp)
ffffffffc02051a2:	6131                	addi	sp,sp,320
ffffffffc02051a4:	8082                	ret

ffffffffc02051a6 <do_exit>:
do_exit(int error_code) {
ffffffffc02051a6:	7179                	addi	sp,sp,-48
ffffffffc02051a8:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02051aa:	000a7717          	auipc	a4,0xa7
ffffffffc02051ae:	69e70713          	addi	a4,a4,1694 # ffffffffc02ac848 <idleproc>
ffffffffc02051b2:	000a7917          	auipc	s2,0xa7
ffffffffc02051b6:	68e90913          	addi	s2,s2,1678 # ffffffffc02ac840 <current>
ffffffffc02051ba:	00093783          	ld	a5,0(s2)
ffffffffc02051be:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02051c0:	f406                	sd	ra,40(sp)
ffffffffc02051c2:	f022                	sd	s0,32(sp)
ffffffffc02051c4:	ec26                	sd	s1,24(sp)
ffffffffc02051c6:	e44e                	sd	s3,8(sp)
ffffffffc02051c8:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02051ca:	0ce78c63          	beq	a5,a4,ffffffffc02052a2 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc02051ce:	000a7417          	auipc	s0,0xa7
ffffffffc02051d2:	68240413          	addi	s0,s0,1666 # ffffffffc02ac850 <initproc>
ffffffffc02051d6:	6018                	ld	a4,0(s0)
ffffffffc02051d8:	0ee78b63          	beq	a5,a4,ffffffffc02052ce <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02051dc:	7784                	ld	s1,40(a5)
ffffffffc02051de:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02051e0:	c48d                	beqz	s1,ffffffffc020520a <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02051e2:	000a7797          	auipc	a5,0xa7
ffffffffc02051e6:	6ae78793          	addi	a5,a5,1710 # ffffffffc02ac890 <boot_cr3>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc02051ea:	639c                	ld	a5,0(a5)
ffffffffc02051ec:	577d                	li	a4,-1
ffffffffc02051ee:	177e                	slli	a4,a4,0x3f
ffffffffc02051f0:	83b1                	srli	a5,a5,0xc
ffffffffc02051f2:	8fd9                	or	a5,a5,a4
ffffffffc02051f4:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02051f8:	589c                	lw	a5,48(s1)
ffffffffc02051fa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02051fe:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205200:	cf4d                	beqz	a4,ffffffffc02052ba <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205202:	00093783          	ld	a5,0(s2)
ffffffffc0205206:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020520a:	00093783          	ld	a5,0(s2)
ffffffffc020520e:	470d                	li	a4,3
ffffffffc0205210:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205212:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205216:	100027f3          	csrr	a5,sstatus
ffffffffc020521a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020521c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020521e:	e7e1                	bnez	a5,ffffffffc02052e6 <do_exit+0x140>
        proc = current->parent;
ffffffffc0205220:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205224:	800007b7          	lui	a5,0x80000
ffffffffc0205228:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020522a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020522c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205230:	0af70f63          	beq	a4,a5,ffffffffc02052ee <do_exit+0x148>
ffffffffc0205234:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205238:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020523c:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020523e:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205240:	7afc                	ld	a5,240(a3)
ffffffffc0205242:	cb95                	beqz	a5,ffffffffc0205276 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205244:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205248:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020524a:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020524c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020524e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205252:	10e7b023          	sd	a4,256(a5)
ffffffffc0205256:	c311                	beqz	a4,ffffffffc020525a <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205258:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020525a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020525c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020525e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205260:	fe9710e3          	bne	a4,s1,ffffffffc0205240 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205264:	0ec52783          	lw	a5,236(a0)
ffffffffc0205268:	fd379ce3          	bne	a5,s3,ffffffffc0205240 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020526c:	253000ef          	jal	ra,ffffffffc0205cbe <wakeup_proc>
ffffffffc0205270:	00093683          	ld	a3,0(s2)
ffffffffc0205274:	b7f1                	j	ffffffffc0205240 <do_exit+0x9a>
    if (flag) {
ffffffffc0205276:	020a1363          	bnez	s4,ffffffffc020529c <do_exit+0xf6>
    schedule();
ffffffffc020527a:	2c1000ef          	jal	ra,ffffffffc0205d3a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020527e:	00093783          	ld	a5,0(s2)
ffffffffc0205282:	00003617          	auipc	a2,0x3
ffffffffc0205286:	00e60613          	addi	a2,a2,14 # ffffffffc0208290 <default_pmm_manager+0x11d8>
ffffffffc020528a:	21700593          	li	a1,535
ffffffffc020528e:	43d4                	lw	a3,4(a5)
ffffffffc0205290:	00003517          	auipc	a0,0x3
ffffffffc0205294:	28850513          	addi	a0,a0,648 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205298:	9e8fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_enable();
ffffffffc020529c:	b8cfb0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc02052a0:	bfe9                	j	ffffffffc020527a <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02052a2:	00003617          	auipc	a2,0x3
ffffffffc02052a6:	fce60613          	addi	a2,a2,-50 # ffffffffc0208270 <default_pmm_manager+0x11b8>
ffffffffc02052aa:	1eb00593          	li	a1,491
ffffffffc02052ae:	00003517          	auipc	a0,0x3
ffffffffc02052b2:	26a50513          	addi	a0,a0,618 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc02052b6:	9cafb0ef          	jal	ra,ffffffffc0200480 <__panic>
            exit_mmap(mm);
ffffffffc02052ba:	8526                	mv	a0,s1
ffffffffc02052bc:	856ff0ef          	jal	ra,ffffffffc0204312 <exit_mmap>
            put_pgdir(mm);
ffffffffc02052c0:	8526                	mv	a0,s1
ffffffffc02052c2:	93dff0ef          	jal	ra,ffffffffc0204bfe <put_pgdir>
            mm_destroy(mm);
ffffffffc02052c6:	8526                	mv	a0,s1
ffffffffc02052c8:	eabfe0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
ffffffffc02052cc:	bf1d                	j	ffffffffc0205202 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02052ce:	00003617          	auipc	a2,0x3
ffffffffc02052d2:	fb260613          	addi	a2,a2,-78 # ffffffffc0208280 <default_pmm_manager+0x11c8>
ffffffffc02052d6:	1ee00593          	li	a1,494
ffffffffc02052da:	00003517          	auipc	a0,0x3
ffffffffc02052de:	23e50513          	addi	a0,a0,574 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc02052e2:	99efb0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_disable();
ffffffffc02052e6:	b48fb0ef          	jal	ra,ffffffffc020062e <intr_disable>
        return 1;
ffffffffc02052ea:	4a05                	li	s4,1
ffffffffc02052ec:	bf15                	j	ffffffffc0205220 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02052ee:	1d1000ef          	jal	ra,ffffffffc0205cbe <wakeup_proc>
ffffffffc02052f2:	b789                	j	ffffffffc0205234 <do_exit+0x8e>

ffffffffc02052f4 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02052f4:	7139                	addi	sp,sp,-64
ffffffffc02052f6:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02052f8:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02052fc:	f426                	sd	s1,40(sp)
ffffffffc02052fe:	f04a                	sd	s2,32(sp)
ffffffffc0205300:	ec4e                	sd	s3,24(sp)
ffffffffc0205302:	e456                	sd	s5,8(sp)
ffffffffc0205304:	e05a                	sd	s6,0(sp)
ffffffffc0205306:	fc06                	sd	ra,56(sp)
ffffffffc0205308:	f822                	sd	s0,48(sp)
ffffffffc020530a:	89aa                	mv	s3,a0
ffffffffc020530c:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020530e:	000a7917          	auipc	s2,0xa7
ffffffffc0205312:	53290913          	addi	s2,s2,1330 # ffffffffc02ac840 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205316:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205318:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020531a:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc020531c:	02098f63          	beqz	s3,ffffffffc020535a <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205320:	854e                	mv	a0,s3
ffffffffc0205322:	a13ff0ef          	jal	ra,ffffffffc0204d34 <find_proc>
ffffffffc0205326:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205328:	12050063          	beqz	a0,ffffffffc0205448 <do_wait.part.1+0x154>
ffffffffc020532c:	00093703          	ld	a4,0(s2)
ffffffffc0205330:	711c                	ld	a5,32(a0)
ffffffffc0205332:	10e79b63          	bne	a5,a4,ffffffffc0205448 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205336:	411c                	lw	a5,0(a0)
ffffffffc0205338:	02978c63          	beq	a5,s1,ffffffffc0205370 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc020533c:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205340:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205344:	1f7000ef          	jal	ra,ffffffffc0205d3a <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205348:	00093783          	ld	a5,0(s2)
ffffffffc020534c:	0b07a783          	lw	a5,176(a5)
ffffffffc0205350:	8b85                	andi	a5,a5,1
ffffffffc0205352:	d7e9                	beqz	a5,ffffffffc020531c <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205354:	555d                	li	a0,-9
ffffffffc0205356:	e51ff0ef          	jal	ra,ffffffffc02051a6 <do_exit>
        proc = current->cptr;
ffffffffc020535a:	00093703          	ld	a4,0(s2)
ffffffffc020535e:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205360:	e409                	bnez	s0,ffffffffc020536a <do_wait.part.1+0x76>
ffffffffc0205362:	a0dd                	j	ffffffffc0205448 <do_wait.part.1+0x154>
ffffffffc0205364:	10043403          	ld	s0,256(s0)
ffffffffc0205368:	d871                	beqz	s0,ffffffffc020533c <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020536a:	401c                	lw	a5,0(s0)
ffffffffc020536c:	fe979ce3          	bne	a5,s1,ffffffffc0205364 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205370:	000a7797          	auipc	a5,0xa7
ffffffffc0205374:	4d878793          	addi	a5,a5,1240 # ffffffffc02ac848 <idleproc>
ffffffffc0205378:	639c                	ld	a5,0(a5)
ffffffffc020537a:	0c878d63          	beq	a5,s0,ffffffffc0205454 <do_wait.part.1+0x160>
ffffffffc020537e:	000a7797          	auipc	a5,0xa7
ffffffffc0205382:	4d278793          	addi	a5,a5,1234 # ffffffffc02ac850 <initproc>
ffffffffc0205386:	639c                	ld	a5,0(a5)
ffffffffc0205388:	0cf40663          	beq	s0,a5,ffffffffc0205454 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc020538c:	000b0663          	beqz	s6,ffffffffc0205398 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205390:	0e842783          	lw	a5,232(s0)
ffffffffc0205394:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205398:	100027f3          	csrr	a5,sstatus
ffffffffc020539c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020539e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053a0:	e7d5                	bnez	a5,ffffffffc020544c <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02053a2:	6c70                	ld	a2,216(s0)
ffffffffc02053a4:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02053a6:	10043703          	ld	a4,256(s0)
ffffffffc02053aa:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02053ac:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02053ae:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02053b0:	6470                	ld	a2,200(s0)
ffffffffc02053b2:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02053b4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02053b6:	e290                	sd	a2,0(a3)
ffffffffc02053b8:	c319                	beqz	a4,ffffffffc02053be <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02053ba:	ff7c                	sd	a5,248(a4)
ffffffffc02053bc:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02053be:	c3d1                	beqz	a5,ffffffffc0205442 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02053c0:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02053c4:	000a7797          	auipc	a5,0xa7
ffffffffc02053c8:	49478793          	addi	a5,a5,1172 # ffffffffc02ac858 <nr_process>
ffffffffc02053cc:	439c                	lw	a5,0(a5)
ffffffffc02053ce:	37fd                	addiw	a5,a5,-1
ffffffffc02053d0:	000a7717          	auipc	a4,0xa7
ffffffffc02053d4:	48f72423          	sw	a5,1160(a4) # ffffffffc02ac858 <nr_process>
    if (flag) {
ffffffffc02053d8:	e1b5                	bnez	a1,ffffffffc020543c <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02053da:	6814                	ld	a3,16(s0)
ffffffffc02053dc:	c02007b7          	lui	a5,0xc0200
ffffffffc02053e0:	0af6e263          	bltu	a3,a5,ffffffffc0205484 <do_wait.part.1+0x190>
ffffffffc02053e4:	000a7797          	auipc	a5,0xa7
ffffffffc02053e8:	4a478793          	addi	a5,a5,1188 # ffffffffc02ac888 <va_pa_offset>
ffffffffc02053ec:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02053ee:	000a7797          	auipc	a5,0xa7
ffffffffc02053f2:	43a78793          	addi	a5,a5,1082 # ffffffffc02ac828 <npage>
ffffffffc02053f6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02053f8:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02053fa:	82b1                	srli	a3,a3,0xc
ffffffffc02053fc:	06f6f863          	bgeu	a3,a5,ffffffffc020546c <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205400:	00003797          	auipc	a5,0x3
ffffffffc0205404:	5e078793          	addi	a5,a5,1504 # ffffffffc02089e0 <nbase>
ffffffffc0205408:	639c                	ld	a5,0(a5)
ffffffffc020540a:	000a7717          	auipc	a4,0xa7
ffffffffc020540e:	48e70713          	addi	a4,a4,1166 # ffffffffc02ac898 <pages>
ffffffffc0205412:	6308                	ld	a0,0(a4)
ffffffffc0205414:	8e9d                	sub	a3,a3,a5
ffffffffc0205416:	069a                	slli	a3,a3,0x6
ffffffffc0205418:	9536                	add	a0,a0,a3
ffffffffc020541a:	4589                	li	a1,2
ffffffffc020541c:	a6dfc0ef          	jal	ra,ffffffffc0201e88 <free_pages>
    kfree(proc);
ffffffffc0205420:	8522                	mv	a0,s0
ffffffffc0205422:	8a3fc0ef          	jal	ra,ffffffffc0201cc4 <kfree>
    return 0;
ffffffffc0205426:	4501                	li	a0,0
}
ffffffffc0205428:	70e2                	ld	ra,56(sp)
ffffffffc020542a:	7442                	ld	s0,48(sp)
ffffffffc020542c:	74a2                	ld	s1,40(sp)
ffffffffc020542e:	7902                	ld	s2,32(sp)
ffffffffc0205430:	69e2                	ld	s3,24(sp)
ffffffffc0205432:	6a42                	ld	s4,16(sp)
ffffffffc0205434:	6aa2                	ld	s5,8(sp)
ffffffffc0205436:	6b02                	ld	s6,0(sp)
ffffffffc0205438:	6121                	addi	sp,sp,64
ffffffffc020543a:	8082                	ret
        intr_enable();
ffffffffc020543c:	9ecfb0ef          	jal	ra,ffffffffc0200628 <intr_enable>
ffffffffc0205440:	bf69                	j	ffffffffc02053da <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205442:	701c                	ld	a5,32(s0)
ffffffffc0205444:	fbf8                	sd	a4,240(a5)
ffffffffc0205446:	bfbd                	j	ffffffffc02053c4 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205448:	5579                	li	a0,-2
ffffffffc020544a:	bff9                	j	ffffffffc0205428 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020544c:	9e2fb0ef          	jal	ra,ffffffffc020062e <intr_disable>
        return 1;
ffffffffc0205450:	4585                	li	a1,1
ffffffffc0205452:	bf81                	j	ffffffffc02053a2 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205454:	00003617          	auipc	a2,0x3
ffffffffc0205458:	e8460613          	addi	a2,a2,-380 # ffffffffc02082d8 <default_pmm_manager+0x1220>
ffffffffc020545c:	30e00593          	li	a1,782
ffffffffc0205460:	00003517          	auipc	a0,0x3
ffffffffc0205464:	0b850513          	addi	a0,a0,184 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205468:	818fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020546c:	00002617          	auipc	a2,0x2
ffffffffc0205470:	cfc60613          	addi	a2,a2,-772 # ffffffffc0207168 <default_pmm_manager+0xb0>
ffffffffc0205474:	06200593          	li	a1,98
ffffffffc0205478:	00002517          	auipc	a0,0x2
ffffffffc020547c:	cb850513          	addi	a0,a0,-840 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0205480:	800fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205484:	00002617          	auipc	a2,0x2
ffffffffc0205488:	cbc60613          	addi	a2,a2,-836 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc020548c:	06e00593          	li	a1,110
ffffffffc0205490:	00002517          	auipc	a0,0x2
ffffffffc0205494:	ca050513          	addi	a0,a0,-864 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0205498:	fe9fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020549c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020549c:	1141                	addi	sp,sp,-16
ffffffffc020549e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02054a0:	a2ffc0ef          	jal	ra,ffffffffc0201ece <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02054a4:	f60fc0ef          	jal	ra,ffffffffc0201c04 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02054a8:	4601                	li	a2,0
ffffffffc02054aa:	4581                	li	a1,0
ffffffffc02054ac:	fffff517          	auipc	a0,0xfffff
ffffffffc02054b0:	6d050513          	addi	a0,a0,1744 # ffffffffc0204b7c <user_main>
ffffffffc02054b4:	ca3ff0ef          	jal	ra,ffffffffc0205156 <kernel_thread>
    if (pid <= 0) {
ffffffffc02054b8:	00a04563          	bgtz	a0,ffffffffc02054c2 <init_main+0x26>
ffffffffc02054bc:	a841                	j	ffffffffc020554c <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02054be:	07d000ef          	jal	ra,ffffffffc0205d3a <schedule>
    if (code_store != NULL) {
ffffffffc02054c2:	4581                	li	a1,0
ffffffffc02054c4:	4501                	li	a0,0
ffffffffc02054c6:	e2fff0ef          	jal	ra,ffffffffc02052f4 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02054ca:	d975                	beqz	a0,ffffffffc02054be <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02054cc:	00003517          	auipc	a0,0x3
ffffffffc02054d0:	e4c50513          	addi	a0,a0,-436 # ffffffffc0208318 <default_pmm_manager+0x1260>
ffffffffc02054d4:	cbbfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02054d8:	000a7797          	auipc	a5,0xa7
ffffffffc02054dc:	37878793          	addi	a5,a5,888 # ffffffffc02ac850 <initproc>
ffffffffc02054e0:	639c                	ld	a5,0(a5)
ffffffffc02054e2:	7bf8                	ld	a4,240(a5)
ffffffffc02054e4:	e721                	bnez	a4,ffffffffc020552c <init_main+0x90>
ffffffffc02054e6:	7ff8                	ld	a4,248(a5)
ffffffffc02054e8:	e331                	bnez	a4,ffffffffc020552c <init_main+0x90>
ffffffffc02054ea:	1007b703          	ld	a4,256(a5)
ffffffffc02054ee:	ef1d                	bnez	a4,ffffffffc020552c <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02054f0:	000a7717          	auipc	a4,0xa7
ffffffffc02054f4:	36870713          	addi	a4,a4,872 # ffffffffc02ac858 <nr_process>
ffffffffc02054f8:	4314                	lw	a3,0(a4)
ffffffffc02054fa:	4709                	li	a4,2
ffffffffc02054fc:	0ae69463          	bne	a3,a4,ffffffffc02055a4 <init_main+0x108>
    return listelm->next;
ffffffffc0205500:	000a7697          	auipc	a3,0xa7
ffffffffc0205504:	48068693          	addi	a3,a3,1152 # ffffffffc02ac980 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205508:	6698                	ld	a4,8(a3)
ffffffffc020550a:	0c878793          	addi	a5,a5,200
ffffffffc020550e:	06f71b63          	bne	a4,a5,ffffffffc0205584 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205512:	629c                	ld	a5,0(a3)
ffffffffc0205514:	04f71863          	bne	a4,a5,ffffffffc0205564 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205518:	00003517          	auipc	a0,0x3
ffffffffc020551c:	ee850513          	addi	a0,a0,-280 # ffffffffc0208400 <default_pmm_manager+0x1348>
ffffffffc0205520:	c6ffa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0205524:	60a2                	ld	ra,8(sp)
ffffffffc0205526:	4501                	li	a0,0
ffffffffc0205528:	0141                	addi	sp,sp,16
ffffffffc020552a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020552c:	00003697          	auipc	a3,0x3
ffffffffc0205530:	e1468693          	addi	a3,a3,-492 # ffffffffc0208340 <default_pmm_manager+0x1288>
ffffffffc0205534:	00001617          	auipc	a2,0x1
ffffffffc0205538:	43c60613          	addi	a2,a2,1084 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020553c:	37300593          	li	a1,883
ffffffffc0205540:	00003517          	auipc	a0,0x3
ffffffffc0205544:	fd850513          	addi	a0,a0,-40 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205548:	f39fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create user_main failed.\n");
ffffffffc020554c:	00003617          	auipc	a2,0x3
ffffffffc0205550:	dac60613          	addi	a2,a2,-596 # ffffffffc02082f8 <default_pmm_manager+0x1240>
ffffffffc0205554:	36b00593          	li	a1,875
ffffffffc0205558:	00003517          	auipc	a0,0x3
ffffffffc020555c:	fc050513          	addi	a0,a0,-64 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205560:	f21fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205564:	00003697          	auipc	a3,0x3
ffffffffc0205568:	e6c68693          	addi	a3,a3,-404 # ffffffffc02083d0 <default_pmm_manager+0x1318>
ffffffffc020556c:	00001617          	auipc	a2,0x1
ffffffffc0205570:	40460613          	addi	a2,a2,1028 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205574:	37600593          	li	a1,886
ffffffffc0205578:	00003517          	auipc	a0,0x3
ffffffffc020557c:	fa050513          	addi	a0,a0,-96 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205580:	f01fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205584:	00003697          	auipc	a3,0x3
ffffffffc0205588:	e1c68693          	addi	a3,a3,-484 # ffffffffc02083a0 <default_pmm_manager+0x12e8>
ffffffffc020558c:	00001617          	auipc	a2,0x1
ffffffffc0205590:	3e460613          	addi	a2,a2,996 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205594:	37500593          	li	a1,885
ffffffffc0205598:	00003517          	auipc	a0,0x3
ffffffffc020559c:	f8050513          	addi	a0,a0,-128 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc02055a0:	ee1fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_process == 2);
ffffffffc02055a4:	00003697          	auipc	a3,0x3
ffffffffc02055a8:	dec68693          	addi	a3,a3,-532 # ffffffffc0208390 <default_pmm_manager+0x12d8>
ffffffffc02055ac:	00001617          	auipc	a2,0x1
ffffffffc02055b0:	3c460613          	addi	a2,a2,964 # ffffffffc0206970 <commands+0x4c0>
ffffffffc02055b4:	37400593          	li	a1,884
ffffffffc02055b8:	00003517          	auipc	a0,0x3
ffffffffc02055bc:	f6050513          	addi	a0,a0,-160 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc02055c0:	ec1fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02055c4 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055c4:	7135                	addi	sp,sp,-160
ffffffffc02055c6:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02055c8:	000a7a17          	auipc	s4,0xa7
ffffffffc02055cc:	278a0a13          	addi	s4,s4,632 # ffffffffc02ac840 <current>
ffffffffc02055d0:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055d4:	e14a                	sd	s2,128(sp)
ffffffffc02055d6:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02055d8:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055dc:	fcce                	sd	s3,120(sp)
ffffffffc02055de:	f0da                	sd	s6,96(sp)
ffffffffc02055e0:	89aa                	mv	s3,a0
ffffffffc02055e2:	842e                	mv	s0,a1
ffffffffc02055e4:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02055e6:	4681                	li	a3,0
ffffffffc02055e8:	862e                	mv	a2,a1
ffffffffc02055ea:	85aa                	mv	a1,a0
ffffffffc02055ec:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055ee:	ed06                	sd	ra,152(sp)
ffffffffc02055f0:	e526                	sd	s1,136(sp)
ffffffffc02055f2:	f4d6                	sd	s5,104(sp)
ffffffffc02055f4:	ecde                	sd	s7,88(sp)
ffffffffc02055f6:	e8e2                	sd	s8,80(sp)
ffffffffc02055f8:	e4e6                	sd	s9,72(sp)
ffffffffc02055fa:	e0ea                	sd	s10,64(sp)
ffffffffc02055fc:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02055fe:	b92ff0ef          	jal	ra,ffffffffc0204990 <user_mem_check>
ffffffffc0205602:	40050263          	beqz	a0,ffffffffc0205a06 <do_execve+0x442>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205606:	4641                	li	a2,16
ffffffffc0205608:	4581                	li	a1,0
ffffffffc020560a:	1008                	addi	a0,sp,32
ffffffffc020560c:	547000ef          	jal	ra,ffffffffc0206352 <memset>
    memcpy(local_name, name, len);
ffffffffc0205610:	47bd                	li	a5,15
ffffffffc0205612:	8622                	mv	a2,s0
ffffffffc0205614:	0687ee63          	bltu	a5,s0,ffffffffc0205690 <do_execve+0xcc>
ffffffffc0205618:	85ce                	mv	a1,s3
ffffffffc020561a:	1008                	addi	a0,sp,32
ffffffffc020561c:	549000ef          	jal	ra,ffffffffc0206364 <memcpy>
    if (mm != NULL) {
ffffffffc0205620:	06090f63          	beqz	s2,ffffffffc020569e <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205624:	00002517          	auipc	a0,0x2
ffffffffc0205628:	23450513          	addi	a0,a0,564 # ffffffffc0207858 <default_pmm_manager+0x7a0>
ffffffffc020562c:	b99fa0ef          	jal	ra,ffffffffc02001c4 <cputs>
        lcr3(boot_cr3);
ffffffffc0205630:	000a7797          	auipc	a5,0xa7
ffffffffc0205634:	26078793          	addi	a5,a5,608 # ffffffffc02ac890 <boot_cr3>
ffffffffc0205638:	639c                	ld	a5,0(a5)
ffffffffc020563a:	577d                	li	a4,-1
ffffffffc020563c:	177e                	slli	a4,a4,0x3f
ffffffffc020563e:	83b1                	srli	a5,a5,0xc
ffffffffc0205640:	8fd9                	or	a5,a5,a4
ffffffffc0205642:	18079073          	csrw	satp,a5
ffffffffc0205646:	03092783          	lw	a5,48(s2)
ffffffffc020564a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020564e:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205652:	28070c63          	beqz	a4,ffffffffc02058ea <do_execve+0x326>
        current->mm = NULL;
ffffffffc0205656:	000a3783          	ld	a5,0(s4)
ffffffffc020565a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020565e:	98ffe0ef          	jal	ra,ffffffffc0203fec <mm_create>
ffffffffc0205662:	892a                	mv	s2,a0
ffffffffc0205664:	c135                	beqz	a0,ffffffffc02056c8 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205666:	e16ff0ef          	jal	ra,ffffffffc0204c7c <setup_pgdir>
ffffffffc020566a:	e931                	bnez	a0,ffffffffc02056be <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020566c:	000b2703          	lw	a4,0(s6)
ffffffffc0205670:	464c47b7          	lui	a5,0x464c4
ffffffffc0205674:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc0205678:	04f70a63          	beq	a4,a5,ffffffffc02056cc <do_execve+0x108>
    put_pgdir(mm);
ffffffffc020567c:	854a                	mv	a0,s2
ffffffffc020567e:	d80ff0ef          	jal	ra,ffffffffc0204bfe <put_pgdir>
    mm_destroy(mm);
ffffffffc0205682:	854a                	mv	a0,s2
ffffffffc0205684:	aeffe0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205688:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc020568a:	854e                	mv	a0,s3
ffffffffc020568c:	b1bff0ef          	jal	ra,ffffffffc02051a6 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205690:	463d                	li	a2,15
ffffffffc0205692:	85ce                	mv	a1,s3
ffffffffc0205694:	1008                	addi	a0,sp,32
ffffffffc0205696:	4cf000ef          	jal	ra,ffffffffc0206364 <memcpy>
    if (mm != NULL) {
ffffffffc020569a:	f80915e3          	bnez	s2,ffffffffc0205624 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc020569e:	000a3783          	ld	a5,0(s4)
ffffffffc02056a2:	779c                	ld	a5,40(a5)
ffffffffc02056a4:	dfcd                	beqz	a5,ffffffffc020565e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02056a6:	00003617          	auipc	a2,0x3
ffffffffc02056aa:	a4260613          	addi	a2,a2,-1470 # ffffffffc02080e8 <default_pmm_manager+0x1030>
ffffffffc02056ae:	22100593          	li	a1,545
ffffffffc02056b2:	00003517          	auipc	a0,0x3
ffffffffc02056b6:	e6650513          	addi	a0,a0,-410 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc02056ba:	dc7fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    mm_destroy(mm);
ffffffffc02056be:	854a                	mv	a0,s2
ffffffffc02056c0:	ab3fe0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02056c4:	59f1                	li	s3,-4
ffffffffc02056c6:	b7d1                	j	ffffffffc020568a <do_execve+0xc6>
ffffffffc02056c8:	59f1                	li	s3,-4
ffffffffc02056ca:	b7c1                	j	ffffffffc020568a <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02056cc:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02056d0:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02056d4:	00371793          	slli	a5,a4,0x3
ffffffffc02056d8:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02056da:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02056dc:	078e                	slli	a5,a5,0x3
ffffffffc02056de:	97a2                	add	a5,a5,s0
ffffffffc02056e0:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02056e2:	02f47b63          	bgeu	s0,a5,ffffffffc0205718 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02056e6:	5bfd                	li	s7,-1
ffffffffc02056e8:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc02056ec:	000a7d97          	auipc	s11,0xa7
ffffffffc02056f0:	1acd8d93          	addi	s11,s11,428 # ffffffffc02ac898 <pages>
ffffffffc02056f4:	00003d17          	auipc	s10,0x3
ffffffffc02056f8:	2ecd0d13          	addi	s10,s10,748 # ffffffffc02089e0 <nbase>
    return KADDR(page2pa(page));
ffffffffc02056fc:	e43e                	sd	a5,8(sp)
ffffffffc02056fe:	000a7c97          	auipc	s9,0xa7
ffffffffc0205702:	12ac8c93          	addi	s9,s9,298 # ffffffffc02ac828 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205706:	4018                	lw	a4,0(s0)
ffffffffc0205708:	4785                	li	a5,1
ffffffffc020570a:	0ef70d63          	beq	a4,a5,ffffffffc0205804 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc020570e:	67e2                	ld	a5,24(sp)
ffffffffc0205710:	03840413          	addi	s0,s0,56
ffffffffc0205714:	fef469e3          	bltu	s0,a5,ffffffffc0205706 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205718:	4701                	li	a4,0
ffffffffc020571a:	46ad                	li	a3,11
ffffffffc020571c:	00100637          	lui	a2,0x100
ffffffffc0205720:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205724:	854a                	mv	a0,s2
ffffffffc0205726:	a9ffe0ef          	jal	ra,ffffffffc02041c4 <mm_map>
ffffffffc020572a:	89aa                	mv	s3,a0
ffffffffc020572c:	1a051563          	bnez	a0,ffffffffc02058d6 <do_execve+0x312>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205730:	01893503          	ld	a0,24(s2)
ffffffffc0205734:	467d                	li	a2,31
ffffffffc0205736:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020573a:	b5ffd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc020573e:	36050063          	beqz	a0,ffffffffc0205a9e <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205742:	01893503          	ld	a0,24(s2)
ffffffffc0205746:	467d                	li	a2,31
ffffffffc0205748:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc020574c:	b4dfd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc0205750:	32050763          	beqz	a0,ffffffffc0205a7e <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205754:	01893503          	ld	a0,24(s2)
ffffffffc0205758:	467d                	li	a2,31
ffffffffc020575a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020575e:	b3bfd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc0205762:	2e050e63          	beqz	a0,ffffffffc0205a5e <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205766:	01893503          	ld	a0,24(s2)
ffffffffc020576a:	467d                	li	a2,31
ffffffffc020576c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205770:	b29fd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc0205774:	2c050563          	beqz	a0,ffffffffc0205a3e <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc0205778:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc020577c:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205780:	01893683          	ld	a3,24(s2)
ffffffffc0205784:	2785                	addiw	a5,a5,1
ffffffffc0205786:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc020578a:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5560>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020578e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205792:	28f6ea63          	bltu	a3,a5,ffffffffc0205a26 <do_execve+0x462>
ffffffffc0205796:	000a7797          	auipc	a5,0xa7
ffffffffc020579a:	0f278793          	addi	a5,a5,242 # ffffffffc02ac888 <va_pa_offset>
ffffffffc020579e:	639c                	ld	a5,0(a5)
ffffffffc02057a0:	577d                	li	a4,-1
ffffffffc02057a2:	177e                	slli	a4,a4,0x3f
ffffffffc02057a4:	8e9d                	sub	a3,a3,a5
ffffffffc02057a6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02057aa:	f654                	sd	a3,168(a2)
ffffffffc02057ac:	8fd9                	or	a5,a5,a4
ffffffffc02057ae:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02057b2:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02057b4:	4581                	li	a1,0
ffffffffc02057b6:	12000613          	li	a2,288
ffffffffc02057ba:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02057bc:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02057c0:	393000ef          	jal	ra,ffffffffc0206352 <memset>
    tf->epc = elf->e_entry;
ffffffffc02057c4:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc02057c8:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc02057ca:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02057ce:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc02057d2:	07fe                	slli	a5,a5,0x1f
ffffffffc02057d4:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02057d6:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02057da:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc02057de:	100c                	addi	a1,sp,32
ffffffffc02057e0:	d28ff0ef          	jal	ra,ffffffffc0204d08 <set_proc_name>
}
ffffffffc02057e4:	60ea                	ld	ra,152(sp)
ffffffffc02057e6:	644a                	ld	s0,144(sp)
ffffffffc02057e8:	854e                	mv	a0,s3
ffffffffc02057ea:	64aa                	ld	s1,136(sp)
ffffffffc02057ec:	690a                	ld	s2,128(sp)
ffffffffc02057ee:	79e6                	ld	s3,120(sp)
ffffffffc02057f0:	7a46                	ld	s4,112(sp)
ffffffffc02057f2:	7aa6                	ld	s5,104(sp)
ffffffffc02057f4:	7b06                	ld	s6,96(sp)
ffffffffc02057f6:	6be6                	ld	s7,88(sp)
ffffffffc02057f8:	6c46                	ld	s8,80(sp)
ffffffffc02057fa:	6ca6                	ld	s9,72(sp)
ffffffffc02057fc:	6d06                	ld	s10,64(sp)
ffffffffc02057fe:	7de2                	ld	s11,56(sp)
ffffffffc0205800:	610d                	addi	sp,sp,160
ffffffffc0205802:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205804:	7410                	ld	a2,40(s0)
ffffffffc0205806:	701c                	ld	a5,32(s0)
ffffffffc0205808:	20f66163          	bltu	a2,a5,ffffffffc0205a0a <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc020580c:	405c                	lw	a5,4(s0)
ffffffffc020580e:	0017f693          	andi	a3,a5,1
ffffffffc0205812:	c291                	beqz	a3,ffffffffc0205816 <do_execve+0x252>
ffffffffc0205814:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205816:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020581a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020581c:	0e071163          	bnez	a4,ffffffffc02058fe <do_execve+0x33a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205820:	4745                	li	a4,17
ffffffffc0205822:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205824:	c789                	beqz	a5,ffffffffc020582e <do_execve+0x26a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205826:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205828:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020582c:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc020582e:	0026f793          	andi	a5,a3,2
ffffffffc0205832:	ebe9                	bnez	a5,ffffffffc0205904 <do_execve+0x340>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205834:	0046f793          	andi	a5,a3,4
ffffffffc0205838:	c789                	beqz	a5,ffffffffc0205842 <do_execve+0x27e>
ffffffffc020583a:	6782                	ld	a5,0(sp)
ffffffffc020583c:	0087e793          	ori	a5,a5,8
ffffffffc0205840:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205842:	680c                	ld	a1,16(s0)
ffffffffc0205844:	4701                	li	a4,0
ffffffffc0205846:	854a                	mv	a0,s2
ffffffffc0205848:	97dfe0ef          	jal	ra,ffffffffc02041c4 <mm_map>
ffffffffc020584c:	89aa                	mv	s3,a0
ffffffffc020584e:	e541                	bnez	a0,ffffffffc02058d6 <do_execve+0x312>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205850:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205854:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205858:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020585c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc020585e:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205860:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205862:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205866:	053bef63          	bltu	s7,s3,ffffffffc02058c4 <do_execve+0x300>
ffffffffc020586a:	aa61                	j	ffffffffc0205a02 <do_execve+0x43e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020586c:	6785                	lui	a5,0x1
ffffffffc020586e:	418b8533          	sub	a0,s7,s8
ffffffffc0205872:	9c3e                	add	s8,s8,a5
ffffffffc0205874:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205878:	0189f463          	bgeu	s3,s8,ffffffffc0205880 <do_execve+0x2bc>
                size -= la - end;
ffffffffc020587c:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205880:	000db683          	ld	a3,0(s11)
ffffffffc0205884:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205888:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc020588a:	40d486b3          	sub	a3,s1,a3
ffffffffc020588e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205890:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205894:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205896:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020589a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020589c:	16c5f963          	bgeu	a1,a2,ffffffffc0205a0e <do_execve+0x44a>
ffffffffc02058a0:	000a7797          	auipc	a5,0xa7
ffffffffc02058a4:	fe878793          	addi	a5,a5,-24 # ffffffffc02ac888 <va_pa_offset>
ffffffffc02058a8:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02058ac:	85d6                	mv	a1,s5
ffffffffc02058ae:	8642                	mv	a2,a6
ffffffffc02058b0:	96c6                	add	a3,a3,a7
ffffffffc02058b2:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc02058b4:	9bc2                	add	s7,s7,a6
ffffffffc02058b6:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02058b8:	2ad000ef          	jal	ra,ffffffffc0206364 <memcpy>
            start += size, from += size;
ffffffffc02058bc:	6842                	ld	a6,16(sp)
ffffffffc02058be:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc02058c0:	053bf563          	bgeu	s7,s3,ffffffffc020590a <do_execve+0x346>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02058c4:	01893503          	ld	a0,24(s2)
ffffffffc02058c8:	6602                	ld	a2,0(sp)
ffffffffc02058ca:	85e2                	mv	a1,s8
ffffffffc02058cc:	9cdfd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc02058d0:	84aa                	mv	s1,a0
ffffffffc02058d2:	fd49                	bnez	a0,ffffffffc020586c <do_execve+0x2a8>
        ret = -E_NO_MEM;
ffffffffc02058d4:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc02058d6:	854a                	mv	a0,s2
ffffffffc02058d8:	a3bfe0ef          	jal	ra,ffffffffc0204312 <exit_mmap>
    put_pgdir(mm);
ffffffffc02058dc:	854a                	mv	a0,s2
ffffffffc02058de:	b20ff0ef          	jal	ra,ffffffffc0204bfe <put_pgdir>
    mm_destroy(mm);
ffffffffc02058e2:	854a                	mv	a0,s2
ffffffffc02058e4:	88ffe0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
    return ret;
ffffffffc02058e8:	b34d                	j	ffffffffc020568a <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc02058ea:	854a                	mv	a0,s2
ffffffffc02058ec:	a27fe0ef          	jal	ra,ffffffffc0204312 <exit_mmap>
            put_pgdir(mm);
ffffffffc02058f0:	854a                	mv	a0,s2
ffffffffc02058f2:	b0cff0ef          	jal	ra,ffffffffc0204bfe <put_pgdir>
            mm_destroy(mm);
ffffffffc02058f6:	854a                	mv	a0,s2
ffffffffc02058f8:	87bfe0ef          	jal	ra,ffffffffc0204172 <mm_destroy>
ffffffffc02058fc:	bba9                	j	ffffffffc0205656 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02058fe:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205902:	f395                	bnez	a5,ffffffffc0205826 <do_execve+0x262>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205904:	47dd                	li	a5,23
ffffffffc0205906:	e03e                	sd	a5,0(sp)
ffffffffc0205908:	b735                	j	ffffffffc0205834 <do_execve+0x270>
ffffffffc020590a:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc020590e:	7414                	ld	a3,40(s0)
ffffffffc0205910:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205912:	098bf163          	bgeu	s7,s8,ffffffffc0205994 <do_execve+0x3d0>
            if (start == end) {
ffffffffc0205916:	df798ce3          	beq	s3,s7,ffffffffc020570e <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020591a:	6505                	lui	a0,0x1
ffffffffc020591c:	955e                	add	a0,a0,s7
ffffffffc020591e:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205922:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205926:	0d89fb63          	bgeu	s3,s8,ffffffffc02059fc <do_execve+0x438>
    return page - pages + nbase;
ffffffffc020592a:	000db683          	ld	a3,0(s11)
ffffffffc020592e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205932:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205934:	40d486b3          	sub	a3,s1,a3
ffffffffc0205938:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020593a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc020593e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205940:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205944:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205946:	0cc5f463          	bgeu	a1,a2,ffffffffc0205a0e <do_execve+0x44a>
ffffffffc020594a:	000a7617          	auipc	a2,0xa7
ffffffffc020594e:	f3e60613          	addi	a2,a2,-194 # ffffffffc02ac888 <va_pa_offset>
ffffffffc0205952:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205956:	4581                	li	a1,0
ffffffffc0205958:	8656                	mv	a2,s5
ffffffffc020595a:	96c2                	add	a3,a3,a6
ffffffffc020595c:	9536                	add	a0,a0,a3
ffffffffc020595e:	1f5000ef          	jal	ra,ffffffffc0206352 <memset>
            start += size;
ffffffffc0205962:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205966:	0389f463          	bgeu	s3,s8,ffffffffc020598e <do_execve+0x3ca>
ffffffffc020596a:	dae982e3          	beq	s3,a4,ffffffffc020570e <do_execve+0x14a>
ffffffffc020596e:	00002697          	auipc	a3,0x2
ffffffffc0205972:	7a268693          	addi	a3,a3,1954 # ffffffffc0208110 <default_pmm_manager+0x1058>
ffffffffc0205976:	00001617          	auipc	a2,0x1
ffffffffc020597a:	ffa60613          	addi	a2,a2,-6 # ffffffffc0206970 <commands+0x4c0>
ffffffffc020597e:	27600593          	li	a1,630
ffffffffc0205982:	00003517          	auipc	a0,0x3
ffffffffc0205986:	b9650513          	addi	a0,a0,-1130 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc020598a:	af7fa0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc020598e:	ff8710e3          	bne	a4,s8,ffffffffc020596e <do_execve+0x3aa>
ffffffffc0205992:	8be2                	mv	s7,s8
ffffffffc0205994:	000a7a97          	auipc	s5,0xa7
ffffffffc0205998:	ef4a8a93          	addi	s5,s5,-268 # ffffffffc02ac888 <va_pa_offset>
        while (start < end) {
ffffffffc020599c:	053be763          	bltu	s7,s3,ffffffffc02059ea <do_execve+0x426>
ffffffffc02059a0:	b3bd                	j	ffffffffc020570e <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02059a2:	6785                	lui	a5,0x1
ffffffffc02059a4:	418b8533          	sub	a0,s7,s8
ffffffffc02059a8:	9c3e                	add	s8,s8,a5
ffffffffc02059aa:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc02059ae:	0189f463          	bgeu	s3,s8,ffffffffc02059b6 <do_execve+0x3f2>
                size -= la - end;
ffffffffc02059b2:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc02059b6:	000db683          	ld	a3,0(s11)
ffffffffc02059ba:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc02059be:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc02059c0:	40d486b3          	sub	a3,s1,a3
ffffffffc02059c4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02059c6:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc02059ca:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc02059cc:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02059d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02059d2:	02b87e63          	bgeu	a6,a1,ffffffffc0205a0e <do_execve+0x44a>
ffffffffc02059d6:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc02059da:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc02059dc:	4581                	li	a1,0
ffffffffc02059de:	96c2                	add	a3,a3,a6
ffffffffc02059e0:	9536                	add	a0,a0,a3
ffffffffc02059e2:	171000ef          	jal	ra,ffffffffc0206352 <memset>
        while (start < end) {
ffffffffc02059e6:	d33bf4e3          	bgeu	s7,s3,ffffffffc020570e <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02059ea:	01893503          	ld	a0,24(s2)
ffffffffc02059ee:	6602                	ld	a2,0(sp)
ffffffffc02059f0:	85e2                	mv	a1,s8
ffffffffc02059f2:	8a7fd0ef          	jal	ra,ffffffffc0203298 <pgdir_alloc_page>
ffffffffc02059f6:	84aa                	mv	s1,a0
ffffffffc02059f8:	f54d                	bnez	a0,ffffffffc02059a2 <do_execve+0x3de>
ffffffffc02059fa:	bde9                	j	ffffffffc02058d4 <do_execve+0x310>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02059fc:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205a00:	b72d                	j	ffffffffc020592a <do_execve+0x366>
        while (start < end) {
ffffffffc0205a02:	89de                	mv	s3,s7
ffffffffc0205a04:	b729                	j	ffffffffc020590e <do_execve+0x34a>
        return -E_INVAL;
ffffffffc0205a06:	59f5                	li	s3,-3
ffffffffc0205a08:	bbf1                	j	ffffffffc02057e4 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205a0a:	59e1                	li	s3,-8
ffffffffc0205a0c:	b5e9                	j	ffffffffc02058d6 <do_execve+0x312>
ffffffffc0205a0e:	00001617          	auipc	a2,0x1
ffffffffc0205a12:	6fa60613          	addi	a2,a2,1786 # ffffffffc0207108 <default_pmm_manager+0x50>
ffffffffc0205a16:	06900593          	li	a1,105
ffffffffc0205a1a:	00001517          	auipc	a0,0x1
ffffffffc0205a1e:	71650513          	addi	a0,a0,1814 # ffffffffc0207130 <default_pmm_manager+0x78>
ffffffffc0205a22:	a5ffa0ef          	jal	ra,ffffffffc0200480 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a26:	00001617          	auipc	a2,0x1
ffffffffc0205a2a:	71a60613          	addi	a2,a2,1818 # ffffffffc0207140 <default_pmm_manager+0x88>
ffffffffc0205a2e:	29100593          	li	a1,657
ffffffffc0205a32:	00003517          	auipc	a0,0x3
ffffffffc0205a36:	ae650513          	addi	a0,a0,-1306 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205a3a:	a47fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a3e:	00002697          	auipc	a3,0x2
ffffffffc0205a42:	7ea68693          	addi	a3,a3,2026 # ffffffffc0208228 <default_pmm_manager+0x1170>
ffffffffc0205a46:	00001617          	auipc	a2,0x1
ffffffffc0205a4a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205a4e:	28c00593          	li	a1,652
ffffffffc0205a52:	00003517          	auipc	a0,0x3
ffffffffc0205a56:	ac650513          	addi	a0,a0,-1338 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205a5a:	a27fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a5e:	00002697          	auipc	a3,0x2
ffffffffc0205a62:	78268693          	addi	a3,a3,1922 # ffffffffc02081e0 <default_pmm_manager+0x1128>
ffffffffc0205a66:	00001617          	auipc	a2,0x1
ffffffffc0205a6a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205a6e:	28b00593          	li	a1,651
ffffffffc0205a72:	00003517          	auipc	a0,0x3
ffffffffc0205a76:	aa650513          	addi	a0,a0,-1370 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205a7a:	a07fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a7e:	00002697          	auipc	a3,0x2
ffffffffc0205a82:	71a68693          	addi	a3,a3,1818 # ffffffffc0208198 <default_pmm_manager+0x10e0>
ffffffffc0205a86:	00001617          	auipc	a2,0x1
ffffffffc0205a8a:	eea60613          	addi	a2,a2,-278 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205a8e:	28a00593          	li	a1,650
ffffffffc0205a92:	00003517          	auipc	a0,0x3
ffffffffc0205a96:	a8650513          	addi	a0,a0,-1402 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205a9a:	9e7fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a9e:	00002697          	auipc	a3,0x2
ffffffffc0205aa2:	6b268693          	addi	a3,a3,1714 # ffffffffc0208150 <default_pmm_manager+0x1098>
ffffffffc0205aa6:	00001617          	auipc	a2,0x1
ffffffffc0205aaa:	eca60613          	addi	a2,a2,-310 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205aae:	28900593          	li	a1,649
ffffffffc0205ab2:	00003517          	auipc	a0,0x3
ffffffffc0205ab6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205aba:	9c7fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205abe <do_yield>:
    current->need_resched = 1;
ffffffffc0205abe:	000a7797          	auipc	a5,0xa7
ffffffffc0205ac2:	d8278793          	addi	a5,a5,-638 # ffffffffc02ac840 <current>
ffffffffc0205ac6:	639c                	ld	a5,0(a5)
ffffffffc0205ac8:	4705                	li	a4,1
}
ffffffffc0205aca:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205acc:	ef98                	sd	a4,24(a5)
}
ffffffffc0205ace:	8082                	ret

ffffffffc0205ad0 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205ad0:	1101                	addi	sp,sp,-32
ffffffffc0205ad2:	e822                	sd	s0,16(sp)
ffffffffc0205ad4:	e426                	sd	s1,8(sp)
ffffffffc0205ad6:	ec06                	sd	ra,24(sp)
ffffffffc0205ad8:	842e                	mv	s0,a1
ffffffffc0205ada:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205adc:	cd81                	beqz	a1,ffffffffc0205af4 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205ade:	000a7797          	auipc	a5,0xa7
ffffffffc0205ae2:	d6278793          	addi	a5,a5,-670 # ffffffffc02ac840 <current>
ffffffffc0205ae6:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205ae8:	4685                	li	a3,1
ffffffffc0205aea:	4611                	li	a2,4
ffffffffc0205aec:	7788                	ld	a0,40(a5)
ffffffffc0205aee:	ea3fe0ef          	jal	ra,ffffffffc0204990 <user_mem_check>
ffffffffc0205af2:	c909                	beqz	a0,ffffffffc0205b04 <do_wait+0x34>
ffffffffc0205af4:	85a2                	mv	a1,s0
}
ffffffffc0205af6:	6442                	ld	s0,16(sp)
ffffffffc0205af8:	60e2                	ld	ra,24(sp)
ffffffffc0205afa:	8526                	mv	a0,s1
ffffffffc0205afc:	64a2                	ld	s1,8(sp)
ffffffffc0205afe:	6105                	addi	sp,sp,32
ffffffffc0205b00:	ff4ff06f          	j	ffffffffc02052f4 <do_wait.part.1>
ffffffffc0205b04:	60e2                	ld	ra,24(sp)
ffffffffc0205b06:	6442                	ld	s0,16(sp)
ffffffffc0205b08:	64a2                	ld	s1,8(sp)
ffffffffc0205b0a:	5575                	li	a0,-3
ffffffffc0205b0c:	6105                	addi	sp,sp,32
ffffffffc0205b0e:	8082                	ret

ffffffffc0205b10 <do_kill>:
do_kill(int pid) {
ffffffffc0205b10:	1141                	addi	sp,sp,-16
ffffffffc0205b12:	e406                	sd	ra,8(sp)
ffffffffc0205b14:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205b16:	a1eff0ef          	jal	ra,ffffffffc0204d34 <find_proc>
ffffffffc0205b1a:	cd0d                	beqz	a0,ffffffffc0205b54 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205b1c:	0b052703          	lw	a4,176(a0)
ffffffffc0205b20:	00177693          	andi	a3,a4,1
ffffffffc0205b24:	e695                	bnez	a3,ffffffffc0205b50 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b26:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205b2a:	00176713          	ori	a4,a4,1
ffffffffc0205b2e:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205b32:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b34:	0006c763          	bltz	a3,ffffffffc0205b42 <do_kill+0x32>
}
ffffffffc0205b38:	8522                	mv	a0,s0
ffffffffc0205b3a:	60a2                	ld	ra,8(sp)
ffffffffc0205b3c:	6402                	ld	s0,0(sp)
ffffffffc0205b3e:	0141                	addi	sp,sp,16
ffffffffc0205b40:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205b42:	17c000ef          	jal	ra,ffffffffc0205cbe <wakeup_proc>
}
ffffffffc0205b46:	8522                	mv	a0,s0
ffffffffc0205b48:	60a2                	ld	ra,8(sp)
ffffffffc0205b4a:	6402                	ld	s0,0(sp)
ffffffffc0205b4c:	0141                	addi	sp,sp,16
ffffffffc0205b4e:	8082                	ret
        return -E_KILLED;
ffffffffc0205b50:	545d                	li	s0,-9
ffffffffc0205b52:	b7dd                	j	ffffffffc0205b38 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205b54:	5475                	li	s0,-3
ffffffffc0205b56:	b7cd                	j	ffffffffc0205b38 <do_kill+0x28>

ffffffffc0205b58 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205b58:	000a7797          	auipc	a5,0xa7
ffffffffc0205b5c:	e2878793          	addi	a5,a5,-472 # ffffffffc02ac980 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205b60:	1101                	addi	sp,sp,-32
ffffffffc0205b62:	000a7717          	auipc	a4,0xa7
ffffffffc0205b66:	e2f73323          	sd	a5,-474(a4) # ffffffffc02ac988 <proc_list+0x8>
ffffffffc0205b6a:	000a7717          	auipc	a4,0xa7
ffffffffc0205b6e:	e0f73b23          	sd	a5,-490(a4) # ffffffffc02ac980 <proc_list>
ffffffffc0205b72:	ec06                	sd	ra,24(sp)
ffffffffc0205b74:	e822                	sd	s0,16(sp)
ffffffffc0205b76:	e426                	sd	s1,8(sp)
ffffffffc0205b78:	000a3797          	auipc	a5,0xa3
ffffffffc0205b7c:	c9078793          	addi	a5,a5,-880 # ffffffffc02a8808 <hash_list>
ffffffffc0205b80:	000a7717          	auipc	a4,0xa7
ffffffffc0205b84:	c8870713          	addi	a4,a4,-888 # ffffffffc02ac808 <is_panic>
ffffffffc0205b88:	e79c                	sd	a5,8(a5)
ffffffffc0205b8a:	e39c                	sd	a5,0(a5)
ffffffffc0205b8c:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205b8e:	fee79de3          	bne	a5,a4,ffffffffc0205b88 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205b92:	f6bfe0ef          	jal	ra,ffffffffc0204afc <alloc_proc>
ffffffffc0205b96:	000a7717          	auipc	a4,0xa7
ffffffffc0205b9a:	caa73923          	sd	a0,-846(a4) # ffffffffc02ac848 <idleproc>
ffffffffc0205b9e:	000a7497          	auipc	s1,0xa7
ffffffffc0205ba2:	caa48493          	addi	s1,s1,-854 # ffffffffc02ac848 <idleproc>
ffffffffc0205ba6:	c559                	beqz	a0,ffffffffc0205c34 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205ba8:	4709                	li	a4,2
ffffffffc0205baa:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205bac:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205bae:	00003717          	auipc	a4,0x3
ffffffffc0205bb2:	45270713          	addi	a4,a4,1106 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205bb6:	00003597          	auipc	a1,0x3
ffffffffc0205bba:	88258593          	addi	a1,a1,-1918 # ffffffffc0208438 <default_pmm_manager+0x1380>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205bbe:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205bc0:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205bc2:	946ff0ef          	jal	ra,ffffffffc0204d08 <set_proc_name>
    nr_process ++;
ffffffffc0205bc6:	000a7797          	auipc	a5,0xa7
ffffffffc0205bca:	c9278793          	addi	a5,a5,-878 # ffffffffc02ac858 <nr_process>
ffffffffc0205bce:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205bd0:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bd2:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205bd4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bd6:	4581                	li	a1,0
ffffffffc0205bd8:	00000517          	auipc	a0,0x0
ffffffffc0205bdc:	8c450513          	addi	a0,a0,-1852 # ffffffffc020549c <init_main>
    nr_process ++;
ffffffffc0205be0:	000a7697          	auipc	a3,0xa7
ffffffffc0205be4:	c6f6ac23          	sw	a5,-904(a3) # ffffffffc02ac858 <nr_process>
    current = idleproc;
ffffffffc0205be8:	000a7797          	auipc	a5,0xa7
ffffffffc0205bec:	c4e7bc23          	sd	a4,-936(a5) # ffffffffc02ac840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205bf0:	d66ff0ef          	jal	ra,ffffffffc0205156 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205bf4:	08a05c63          	blez	a0,ffffffffc0205c8c <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205bf8:	93cff0ef          	jal	ra,ffffffffc0204d34 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205bfc:	00003597          	auipc	a1,0x3
ffffffffc0205c00:	86458593          	addi	a1,a1,-1948 # ffffffffc0208460 <default_pmm_manager+0x13a8>
    initproc = find_proc(pid);
ffffffffc0205c04:	000a7797          	auipc	a5,0xa7
ffffffffc0205c08:	c4a7b623          	sd	a0,-948(a5) # ffffffffc02ac850 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205c0c:	8fcff0ef          	jal	ra,ffffffffc0204d08 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205c10:	609c                	ld	a5,0(s1)
ffffffffc0205c12:	cfa9                	beqz	a5,ffffffffc0205c6c <proc_init+0x114>
ffffffffc0205c14:	43dc                	lw	a5,4(a5)
ffffffffc0205c16:	ebb9                	bnez	a5,ffffffffc0205c6c <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205c18:	000a7797          	auipc	a5,0xa7
ffffffffc0205c1c:	c3878793          	addi	a5,a5,-968 # ffffffffc02ac850 <initproc>
ffffffffc0205c20:	639c                	ld	a5,0(a5)
ffffffffc0205c22:	c78d                	beqz	a5,ffffffffc0205c4c <proc_init+0xf4>
ffffffffc0205c24:	43dc                	lw	a5,4(a5)
ffffffffc0205c26:	02879363          	bne	a5,s0,ffffffffc0205c4c <proc_init+0xf4>
}
ffffffffc0205c2a:	60e2                	ld	ra,24(sp)
ffffffffc0205c2c:	6442                	ld	s0,16(sp)
ffffffffc0205c2e:	64a2                	ld	s1,8(sp)
ffffffffc0205c30:	6105                	addi	sp,sp,32
ffffffffc0205c32:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205c34:	00002617          	auipc	a2,0x2
ffffffffc0205c38:	7ec60613          	addi	a2,a2,2028 # ffffffffc0208420 <default_pmm_manager+0x1368>
ffffffffc0205c3c:	38800593          	li	a1,904
ffffffffc0205c40:	00003517          	auipc	a0,0x3
ffffffffc0205c44:	8d850513          	addi	a0,a0,-1832 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205c48:	839fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205c4c:	00003697          	auipc	a3,0x3
ffffffffc0205c50:	84468693          	addi	a3,a3,-1980 # ffffffffc0208490 <default_pmm_manager+0x13d8>
ffffffffc0205c54:	00001617          	auipc	a2,0x1
ffffffffc0205c58:	d1c60613          	addi	a2,a2,-740 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205c5c:	39d00593          	li	a1,925
ffffffffc0205c60:	00003517          	auipc	a0,0x3
ffffffffc0205c64:	8b850513          	addi	a0,a0,-1864 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205c68:	819fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205c6c:	00002697          	auipc	a3,0x2
ffffffffc0205c70:	7fc68693          	addi	a3,a3,2044 # ffffffffc0208468 <default_pmm_manager+0x13b0>
ffffffffc0205c74:	00001617          	auipc	a2,0x1
ffffffffc0205c78:	cfc60613          	addi	a2,a2,-772 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205c7c:	39c00593          	li	a1,924
ffffffffc0205c80:	00003517          	auipc	a0,0x3
ffffffffc0205c84:	89850513          	addi	a0,a0,-1896 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205c88:	ff8fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205c8c:	00002617          	auipc	a2,0x2
ffffffffc0205c90:	7b460613          	addi	a2,a2,1972 # ffffffffc0208440 <default_pmm_manager+0x1388>
ffffffffc0205c94:	39600593          	li	a1,918
ffffffffc0205c98:	00003517          	auipc	a0,0x3
ffffffffc0205c9c:	88050513          	addi	a0,a0,-1920 # ffffffffc0208518 <default_pmm_manager+0x1460>
ffffffffc0205ca0:	fe0fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205ca4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ca4:	1141                	addi	sp,sp,-16
ffffffffc0205ca6:	e022                	sd	s0,0(sp)
ffffffffc0205ca8:	e406                	sd	ra,8(sp)
ffffffffc0205caa:	000a7417          	auipc	s0,0xa7
ffffffffc0205cae:	b9640413          	addi	s0,s0,-1130 # ffffffffc02ac840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205cb2:	6018                	ld	a4,0(s0)
ffffffffc0205cb4:	6f1c                	ld	a5,24(a4)
ffffffffc0205cb6:	dffd                	beqz	a5,ffffffffc0205cb4 <cpu_idle+0x10>
            schedule();
ffffffffc0205cb8:	082000ef          	jal	ra,ffffffffc0205d3a <schedule>
ffffffffc0205cbc:	bfdd                	j	ffffffffc0205cb2 <cpu_idle+0xe>

ffffffffc0205cbe <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205cbe:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205cc0:	1101                	addi	sp,sp,-32
ffffffffc0205cc2:	ec06                	sd	ra,24(sp)
ffffffffc0205cc4:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205cc6:	478d                	li	a5,3
ffffffffc0205cc8:	04f70a63          	beq	a4,a5,ffffffffc0205d1c <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ccc:	100027f3          	csrr	a5,sstatus
ffffffffc0205cd0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205cd2:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205cd4:	ef8d                	bnez	a5,ffffffffc0205d0e <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205cd6:	4789                	li	a5,2
ffffffffc0205cd8:	00f70f63          	beq	a4,a5,ffffffffc0205cf6 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205cdc:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205cde:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205ce2:	e409                	bnez	s0,ffffffffc0205cec <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ce4:	60e2                	ld	ra,24(sp)
ffffffffc0205ce6:	6442                	ld	s0,16(sp)
ffffffffc0205ce8:	6105                	addi	sp,sp,32
ffffffffc0205cea:	8082                	ret
ffffffffc0205cec:	6442                	ld	s0,16(sp)
ffffffffc0205cee:	60e2                	ld	ra,24(sp)
ffffffffc0205cf0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205cf2:	937fa06f          	j	ffffffffc0200628 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205cf6:	00003617          	auipc	a2,0x3
ffffffffc0205cfa:	87260613          	addi	a2,a2,-1934 # ffffffffc0208568 <default_pmm_manager+0x14b0>
ffffffffc0205cfe:	45c9                	li	a1,18
ffffffffc0205d00:	00003517          	auipc	a0,0x3
ffffffffc0205d04:	85050513          	addi	a0,a0,-1968 # ffffffffc0208550 <default_pmm_manager+0x1498>
ffffffffc0205d08:	fe4fa0ef          	jal	ra,ffffffffc02004ec <__warn>
ffffffffc0205d0c:	bfd9                	j	ffffffffc0205ce2 <wakeup_proc+0x24>
ffffffffc0205d0e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205d10:	91ffa0ef          	jal	ra,ffffffffc020062e <intr_disable>
        return 1;
ffffffffc0205d14:	6522                	ld	a0,8(sp)
ffffffffc0205d16:	4405                	li	s0,1
ffffffffc0205d18:	4118                	lw	a4,0(a0)
ffffffffc0205d1a:	bf75                	j	ffffffffc0205cd6 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d1c:	00003697          	auipc	a3,0x3
ffffffffc0205d20:	81468693          	addi	a3,a3,-2028 # ffffffffc0208530 <default_pmm_manager+0x1478>
ffffffffc0205d24:	00001617          	auipc	a2,0x1
ffffffffc0205d28:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206970 <commands+0x4c0>
ffffffffc0205d2c:	45a5                	li	a1,9
ffffffffc0205d2e:	00003517          	auipc	a0,0x3
ffffffffc0205d32:	82250513          	addi	a0,a0,-2014 # ffffffffc0208550 <default_pmm_manager+0x1498>
ffffffffc0205d36:	f4afa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205d3a <schedule>:

void
schedule(void) {
ffffffffc0205d3a:	1141                	addi	sp,sp,-16
ffffffffc0205d3c:	e406                	sd	ra,8(sp)
ffffffffc0205d3e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d40:	100027f3          	csrr	a5,sstatus
ffffffffc0205d44:	8b89                	andi	a5,a5,2
ffffffffc0205d46:	4401                	li	s0,0
ffffffffc0205d48:	e3d1                	bnez	a5,ffffffffc0205dcc <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205d4a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d4e:	af678793          	addi	a5,a5,-1290 # ffffffffc02ac840 <current>
ffffffffc0205d52:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205d56:	000a7797          	auipc	a5,0xa7
ffffffffc0205d5a:	af278793          	addi	a5,a5,-1294 # ffffffffc02ac848 <idleproc>
ffffffffc0205d5e:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205d60:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205d64:	04a88e63          	beq	a7,a0,ffffffffc0205dc0 <schedule+0x86>
ffffffffc0205d68:	0c888693          	addi	a3,a7,200
ffffffffc0205d6c:	000a7617          	auipc	a2,0xa7
ffffffffc0205d70:	c1460613          	addi	a2,a2,-1004 # ffffffffc02ac980 <proc_list>
        le = last;
ffffffffc0205d74:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205d76:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205d78:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205d7a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205d7c:	00c78863          	beq	a5,a2,ffffffffc0205d8c <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205d80:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205d84:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205d88:	01070463          	beq	a4,a6,ffffffffc0205d90 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205d8c:	fef697e3          	bne	a3,a5,ffffffffc0205d7a <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205d90:	c589                	beqz	a1,ffffffffc0205d9a <schedule+0x60>
ffffffffc0205d92:	4198                	lw	a4,0(a1)
ffffffffc0205d94:	4789                	li	a5,2
ffffffffc0205d96:	00f70e63          	beq	a4,a5,ffffffffc0205db2 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205d9a:	451c                	lw	a5,8(a0)
ffffffffc0205d9c:	2785                	addiw	a5,a5,1
ffffffffc0205d9e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205da0:	00a88463          	beq	a7,a0,ffffffffc0205da8 <schedule+0x6e>
            proc_run(next);
ffffffffc0205da4:	f8ffe0ef          	jal	ra,ffffffffc0204d32 <proc_run>
    if (flag) {
ffffffffc0205da8:	e419                	bnez	s0,ffffffffc0205db6 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205daa:	60a2                	ld	ra,8(sp)
ffffffffc0205dac:	6402                	ld	s0,0(sp)
ffffffffc0205dae:	0141                	addi	sp,sp,16
ffffffffc0205db0:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205db2:	852e                	mv	a0,a1
ffffffffc0205db4:	b7dd                	j	ffffffffc0205d9a <schedule+0x60>
}
ffffffffc0205db6:	6402                	ld	s0,0(sp)
ffffffffc0205db8:	60a2                	ld	ra,8(sp)
ffffffffc0205dba:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205dbc:	86dfa06f          	j	ffffffffc0200628 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205dc0:	000a7617          	auipc	a2,0xa7
ffffffffc0205dc4:	bc060613          	addi	a2,a2,-1088 # ffffffffc02ac980 <proc_list>
ffffffffc0205dc8:	86b2                	mv	a3,a2
ffffffffc0205dca:	b76d                	j	ffffffffc0205d74 <schedule+0x3a>
        intr_disable();
ffffffffc0205dcc:	863fa0ef          	jal	ra,ffffffffc020062e <intr_disable>
        return 1;
ffffffffc0205dd0:	4405                	li	s0,1
ffffffffc0205dd2:	bfa5                	j	ffffffffc0205d4a <schedule+0x10>

ffffffffc0205dd4 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205dd4:	000a7797          	auipc	a5,0xa7
ffffffffc0205dd8:	a6c78793          	addi	a5,a5,-1428 # ffffffffc02ac840 <current>
ffffffffc0205ddc:	639c                	ld	a5,0(a5)
}
ffffffffc0205dde:	43c8                	lw	a0,4(a5)
ffffffffc0205de0:	8082                	ret

ffffffffc0205de2 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205de2:	4501                	li	a0,0
ffffffffc0205de4:	8082                	ret

ffffffffc0205de6 <sys_putc>:
    cputchar(c);
ffffffffc0205de6:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205de8:	1141                	addi	sp,sp,-16
ffffffffc0205dea:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205dec:	bd6fa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc0205df0:	60a2                	ld	ra,8(sp)
ffffffffc0205df2:	4501                	li	a0,0
ffffffffc0205df4:	0141                	addi	sp,sp,16
ffffffffc0205df6:	8082                	ret

ffffffffc0205df8 <sys_kill>:
    return do_kill(pid);
ffffffffc0205df8:	4108                	lw	a0,0(a0)
ffffffffc0205dfa:	d17ff06f          	j	ffffffffc0205b10 <do_kill>

ffffffffc0205dfe <sys_yield>:
    return do_yield();
ffffffffc0205dfe:	cc1ff06f          	j	ffffffffc0205abe <do_yield>

ffffffffc0205e02 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205e02:	6d14                	ld	a3,24(a0)
ffffffffc0205e04:	6910                	ld	a2,16(a0)
ffffffffc0205e06:	650c                	ld	a1,8(a0)
ffffffffc0205e08:	6108                	ld	a0,0(a0)
ffffffffc0205e0a:	fbaff06f          	j	ffffffffc02055c4 <do_execve>

ffffffffc0205e0e <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205e0e:	650c                	ld	a1,8(a0)
ffffffffc0205e10:	4108                	lw	a0,0(a0)
ffffffffc0205e12:	cbfff06f          	j	ffffffffc0205ad0 <do_wait>

ffffffffc0205e16 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205e16:	000a7797          	auipc	a5,0xa7
ffffffffc0205e1a:	a2a78793          	addi	a5,a5,-1494 # ffffffffc02ac840 <current>
ffffffffc0205e1e:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e20:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205e22:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e24:	6a0c                	ld	a1,16(a2)
ffffffffc0205e26:	f6bfe06f          	j	ffffffffc0204d90 <do_fork>

ffffffffc0205e2a <sys_exit>:
    return do_exit(error_code);
ffffffffc0205e2a:	4108                	lw	a0,0(a0)
ffffffffc0205e2c:	b7aff06f          	j	ffffffffc02051a6 <do_exit>

ffffffffc0205e30 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205e30:	715d                	addi	sp,sp,-80
ffffffffc0205e32:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205e34:	000a7497          	auipc	s1,0xa7
ffffffffc0205e38:	a0c48493          	addi	s1,s1,-1524 # ffffffffc02ac840 <current>
ffffffffc0205e3c:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205e3e:	e0a2                	sd	s0,64(sp)
ffffffffc0205e40:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205e42:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205e44:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205e46:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205e48:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205e4c:	0327ee63          	bltu	a5,s2,ffffffffc0205e88 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205e50:	00391713          	slli	a4,s2,0x3
ffffffffc0205e54:	00002797          	auipc	a5,0x2
ffffffffc0205e58:	77c78793          	addi	a5,a5,1916 # ffffffffc02085d0 <syscalls>
ffffffffc0205e5c:	97ba                	add	a5,a5,a4
ffffffffc0205e5e:	639c                	ld	a5,0(a5)
ffffffffc0205e60:	c785                	beqz	a5,ffffffffc0205e88 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205e62:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205e64:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205e66:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205e68:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205e6a:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205e6c:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205e6e:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205e70:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205e72:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205e74:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205e76:	0028                	addi	a0,sp,8
ffffffffc0205e78:	9782                	jalr	a5
ffffffffc0205e7a:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205e7c:	60a6                	ld	ra,72(sp)
ffffffffc0205e7e:	6406                	ld	s0,64(sp)
ffffffffc0205e80:	74e2                	ld	s1,56(sp)
ffffffffc0205e82:	7942                	ld	s2,48(sp)
ffffffffc0205e84:	6161                	addi	sp,sp,80
ffffffffc0205e86:	8082                	ret
    print_trapframe(tf);
ffffffffc0205e88:	8522                	mv	a0,s0
ffffffffc0205e8a:	993fa0ef          	jal	ra,ffffffffc020081c <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205e8e:	609c                	ld	a5,0(s1)
ffffffffc0205e90:	86ca                	mv	a3,s2
ffffffffc0205e92:	00002617          	auipc	a2,0x2
ffffffffc0205e96:	6f660613          	addi	a2,a2,1782 # ffffffffc0208588 <default_pmm_manager+0x14d0>
ffffffffc0205e9a:	43d8                	lw	a4,4(a5)
ffffffffc0205e9c:	06300593          	li	a1,99
ffffffffc0205ea0:	0b478793          	addi	a5,a5,180
ffffffffc0205ea4:	00002517          	auipc	a0,0x2
ffffffffc0205ea8:	71450513          	addi	a0,a0,1812 # ffffffffc02085b8 <default_pmm_manager+0x1500>
ffffffffc0205eac:	dd4fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205eb0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205eb0:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205eb4:	2785                	addiw	a5,a5,1
ffffffffc0205eb6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0205eba:	02000793          	li	a5,32
ffffffffc0205ebe:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0205ec2:	00b5553b          	srlw	a0,a0,a1
ffffffffc0205ec6:	8082                	ret

ffffffffc0205ec8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205ec8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ecc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205ece:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ed2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205ed4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ed8:	f022                	sd	s0,32(sp)
ffffffffc0205eda:	ec26                	sd	s1,24(sp)
ffffffffc0205edc:	e84a                	sd	s2,16(sp)
ffffffffc0205ede:	f406                	sd	ra,40(sp)
ffffffffc0205ee0:	e44e                	sd	s3,8(sp)
ffffffffc0205ee2:	84aa                	mv	s1,a0
ffffffffc0205ee4:	892e                	mv	s2,a1
ffffffffc0205ee6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205eea:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0205eec:	03067e63          	bgeu	a2,a6,ffffffffc0205f28 <printnum+0x60>
ffffffffc0205ef0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205ef2:	00805763          	blez	s0,ffffffffc0205f00 <printnum+0x38>
ffffffffc0205ef6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205ef8:	85ca                	mv	a1,s2
ffffffffc0205efa:	854e                	mv	a0,s3
ffffffffc0205efc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205efe:	fc65                	bnez	s0,ffffffffc0205ef6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f00:	1a02                	slli	s4,s4,0x20
ffffffffc0205f02:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205f06:	00003797          	auipc	a5,0x3
ffffffffc0205f0a:	9ea78793          	addi	a5,a5,-1558 # ffffffffc02088f0 <error_string+0xc8>
ffffffffc0205f0e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205f10:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f12:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205f16:	70a2                	ld	ra,40(sp)
ffffffffc0205f18:	69a2                	ld	s3,8(sp)
ffffffffc0205f1a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f1c:	85ca                	mv	a1,s2
ffffffffc0205f1e:	8326                	mv	t1,s1
}
ffffffffc0205f20:	6942                	ld	s2,16(sp)
ffffffffc0205f22:	64e2                	ld	s1,24(sp)
ffffffffc0205f24:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f26:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205f28:	03065633          	divu	a2,a2,a6
ffffffffc0205f2c:	8722                	mv	a4,s0
ffffffffc0205f2e:	f9bff0ef          	jal	ra,ffffffffc0205ec8 <printnum>
ffffffffc0205f32:	b7f9                	j	ffffffffc0205f00 <printnum+0x38>

ffffffffc0205f34 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205f34:	7119                	addi	sp,sp,-128
ffffffffc0205f36:	f4a6                	sd	s1,104(sp)
ffffffffc0205f38:	f0ca                	sd	s2,96(sp)
ffffffffc0205f3a:	e8d2                	sd	s4,80(sp)
ffffffffc0205f3c:	e4d6                	sd	s5,72(sp)
ffffffffc0205f3e:	e0da                	sd	s6,64(sp)
ffffffffc0205f40:	fc5e                	sd	s7,56(sp)
ffffffffc0205f42:	f862                	sd	s8,48(sp)
ffffffffc0205f44:	f06a                	sd	s10,32(sp)
ffffffffc0205f46:	fc86                	sd	ra,120(sp)
ffffffffc0205f48:	f8a2                	sd	s0,112(sp)
ffffffffc0205f4a:	ecce                	sd	s3,88(sp)
ffffffffc0205f4c:	f466                	sd	s9,40(sp)
ffffffffc0205f4e:	ec6e                	sd	s11,24(sp)
ffffffffc0205f50:	892a                	mv	s2,a0
ffffffffc0205f52:	84ae                	mv	s1,a1
ffffffffc0205f54:	8d32                	mv	s10,a2
ffffffffc0205f56:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205f58:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205f5a:	00002a17          	auipc	s4,0x2
ffffffffc0205f5e:	776a0a13          	addi	s4,s4,1910 # ffffffffc02086d0 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205f62:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205f66:	00003c17          	auipc	s8,0x3
ffffffffc0205f6a:	8c2c0c13          	addi	s8,s8,-1854 # ffffffffc0208828 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f6e:	000d4503          	lbu	a0,0(s10)
ffffffffc0205f72:	02500793          	li	a5,37
ffffffffc0205f76:	001d0413          	addi	s0,s10,1
ffffffffc0205f7a:	00f50e63          	beq	a0,a5,ffffffffc0205f96 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0205f7e:	c521                	beqz	a0,ffffffffc0205fc6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f80:	02500993          	li	s3,37
ffffffffc0205f84:	a011                	j	ffffffffc0205f88 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0205f86:	c121                	beqz	a0,ffffffffc0205fc6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0205f88:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f8a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205f8c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f8e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205f92:	ff351ae3          	bne	a0,s3,ffffffffc0205f86 <vprintfmt+0x52>
ffffffffc0205f96:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205f9a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205f9e:	4981                	li	s3,0
ffffffffc0205fa0:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0205fa2:	5cfd                	li	s9,-1
ffffffffc0205fa4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205fa6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0205faa:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205fac:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0205fb0:	0ff6f693          	andi	a3,a3,255
ffffffffc0205fb4:	00140d13          	addi	s10,s0,1
ffffffffc0205fb8:	1ed5ef63          	bltu	a1,a3,ffffffffc02061b6 <vprintfmt+0x282>
ffffffffc0205fbc:	068a                	slli	a3,a3,0x2
ffffffffc0205fbe:	96d2                	add	a3,a3,s4
ffffffffc0205fc0:	4294                	lw	a3,0(a3)
ffffffffc0205fc2:	96d2                	add	a3,a3,s4
ffffffffc0205fc4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205fc6:	70e6                	ld	ra,120(sp)
ffffffffc0205fc8:	7446                	ld	s0,112(sp)
ffffffffc0205fca:	74a6                	ld	s1,104(sp)
ffffffffc0205fcc:	7906                	ld	s2,96(sp)
ffffffffc0205fce:	69e6                	ld	s3,88(sp)
ffffffffc0205fd0:	6a46                	ld	s4,80(sp)
ffffffffc0205fd2:	6aa6                	ld	s5,72(sp)
ffffffffc0205fd4:	6b06                	ld	s6,64(sp)
ffffffffc0205fd6:	7be2                	ld	s7,56(sp)
ffffffffc0205fd8:	7c42                	ld	s8,48(sp)
ffffffffc0205fda:	7ca2                	ld	s9,40(sp)
ffffffffc0205fdc:	7d02                	ld	s10,32(sp)
ffffffffc0205fde:	6de2                	ld	s11,24(sp)
ffffffffc0205fe0:	6109                	addi	sp,sp,128
ffffffffc0205fe2:	8082                	ret
            padc = '-';
ffffffffc0205fe4:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205fe6:	00144603          	lbu	a2,1(s0)
ffffffffc0205fea:	846a                	mv	s0,s10
ffffffffc0205fec:	b7c1                	j	ffffffffc0205fac <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0205fee:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0205ff2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205ff6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205ff8:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0205ffa:	fa0dd9e3          	bgez	s11,ffffffffc0205fac <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0205ffe:	8de6                	mv	s11,s9
ffffffffc0206000:	5cfd                	li	s9,-1
ffffffffc0206002:	b76d                	j	ffffffffc0205fac <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206004:	fffdc693          	not	a3,s11
ffffffffc0206008:	96fd                	srai	a3,a3,0x3f
ffffffffc020600a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020600e:	00144603          	lbu	a2,1(s0)
ffffffffc0206012:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206014:	846a                	mv	s0,s10
ffffffffc0206016:	bf59                	j	ffffffffc0205fac <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206018:	4705                	li	a4,1
ffffffffc020601a:	008a8593          	addi	a1,s5,8
ffffffffc020601e:	01074463          	blt	a4,a6,ffffffffc0206026 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0206022:	22080863          	beqz	a6,ffffffffc0206252 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206026:	000ab603          	ld	a2,0(s5)
ffffffffc020602a:	46c1                	li	a3,16
ffffffffc020602c:	8aae                	mv	s5,a1
ffffffffc020602e:	a291                	j	ffffffffc0206172 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0206030:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206034:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206038:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020603a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020603e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206042:	fad56ce3          	bltu	a0,a3,ffffffffc0205ffa <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206046:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206048:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020604c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206050:	0196873b          	addw	a4,a3,s9
ffffffffc0206054:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206058:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020605c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206060:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206064:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206068:	fcd57fe3          	bgeu	a0,a3,ffffffffc0206046 <vprintfmt+0x112>
ffffffffc020606c:	b779                	j	ffffffffc0205ffa <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc020606e:	000aa503          	lw	a0,0(s5)
ffffffffc0206072:	85a6                	mv	a1,s1
ffffffffc0206074:	0aa1                	addi	s5,s5,8
ffffffffc0206076:	9902                	jalr	s2
            break;
ffffffffc0206078:	bddd                	j	ffffffffc0205f6e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020607a:	4705                	li	a4,1
ffffffffc020607c:	008a8993          	addi	s3,s5,8
ffffffffc0206080:	01074463          	blt	a4,a6,ffffffffc0206088 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0206084:	1c080463          	beqz	a6,ffffffffc020624c <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0206088:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020608c:	1c044a63          	bltz	s0,ffffffffc0206260 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0206090:	8622                	mv	a2,s0
ffffffffc0206092:	8ace                	mv	s5,s3
ffffffffc0206094:	46a9                	li	a3,10
ffffffffc0206096:	a8f1                	j	ffffffffc0206172 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0206098:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020609c:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020609e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02060a0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02060a4:	8fb5                	xor	a5,a5,a3
ffffffffc02060a6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02060aa:	12d74963          	blt	a4,a3,ffffffffc02061dc <vprintfmt+0x2a8>
ffffffffc02060ae:	00369793          	slli	a5,a3,0x3
ffffffffc02060b2:	97e2                	add	a5,a5,s8
ffffffffc02060b4:	639c                	ld	a5,0(a5)
ffffffffc02060b6:	12078363          	beqz	a5,ffffffffc02061dc <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02060ba:	86be                	mv	a3,a5
ffffffffc02060bc:	00000617          	auipc	a2,0x0
ffffffffc02060c0:	2ec60613          	addi	a2,a2,748 # ffffffffc02063a8 <etext+0x2c>
ffffffffc02060c4:	85a6                	mv	a1,s1
ffffffffc02060c6:	854a                	mv	a0,s2
ffffffffc02060c8:	1cc000ef          	jal	ra,ffffffffc0206294 <printfmt>
ffffffffc02060cc:	b54d                	j	ffffffffc0205f6e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02060ce:	000ab603          	ld	a2,0(s5)
ffffffffc02060d2:	0aa1                	addi	s5,s5,8
ffffffffc02060d4:	1a060163          	beqz	a2,ffffffffc0206276 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02060d8:	00160413          	addi	s0,a2,1
ffffffffc02060dc:	15b05763          	blez	s11,ffffffffc020622a <vprintfmt+0x2f6>
ffffffffc02060e0:	02d00593          	li	a1,45
ffffffffc02060e4:	10b79d63          	bne	a5,a1,ffffffffc02061fe <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02060e8:	00064783          	lbu	a5,0(a2)
ffffffffc02060ec:	0007851b          	sext.w	a0,a5
ffffffffc02060f0:	c905                	beqz	a0,ffffffffc0206120 <vprintfmt+0x1ec>
ffffffffc02060f2:	000cc563          	bltz	s9,ffffffffc02060fc <vprintfmt+0x1c8>
ffffffffc02060f6:	3cfd                	addiw	s9,s9,-1
ffffffffc02060f8:	036c8263          	beq	s9,s6,ffffffffc020611c <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc02060fc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02060fe:	14098f63          	beqz	s3,ffffffffc020625c <vprintfmt+0x328>
ffffffffc0206102:	3781                	addiw	a5,a5,-32
ffffffffc0206104:	14fbfc63          	bgeu	s7,a5,ffffffffc020625c <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206108:	03f00513          	li	a0,63
ffffffffc020610c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020610e:	0405                	addi	s0,s0,1
ffffffffc0206110:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206114:	3dfd                	addiw	s11,s11,-1
ffffffffc0206116:	0007851b          	sext.w	a0,a5
ffffffffc020611a:	fd61                	bnez	a0,ffffffffc02060f2 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020611c:	e5b059e3          	blez	s11,ffffffffc0205f6e <vprintfmt+0x3a>
ffffffffc0206120:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206122:	85a6                	mv	a1,s1
ffffffffc0206124:	02000513          	li	a0,32
ffffffffc0206128:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020612a:	e40d82e3          	beqz	s11,ffffffffc0205f6e <vprintfmt+0x3a>
ffffffffc020612e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206130:	85a6                	mv	a1,s1
ffffffffc0206132:	02000513          	li	a0,32
ffffffffc0206136:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206138:	fe0d94e3          	bnez	s11,ffffffffc0206120 <vprintfmt+0x1ec>
ffffffffc020613c:	bd0d                	j	ffffffffc0205f6e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020613e:	4705                	li	a4,1
ffffffffc0206140:	008a8593          	addi	a1,s5,8
ffffffffc0206144:	01074463          	blt	a4,a6,ffffffffc020614c <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0206148:	0e080863          	beqz	a6,ffffffffc0206238 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc020614c:	000ab603          	ld	a2,0(s5)
ffffffffc0206150:	46a1                	li	a3,8
ffffffffc0206152:	8aae                	mv	s5,a1
ffffffffc0206154:	a839                	j	ffffffffc0206172 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0206156:	03000513          	li	a0,48
ffffffffc020615a:	85a6                	mv	a1,s1
ffffffffc020615c:	e03e                	sd	a5,0(sp)
ffffffffc020615e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206160:	85a6                	mv	a1,s1
ffffffffc0206162:	07800513          	li	a0,120
ffffffffc0206166:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206168:	0aa1                	addi	s5,s5,8
ffffffffc020616a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020616e:	6782                	ld	a5,0(sp)
ffffffffc0206170:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206172:	2781                	sext.w	a5,a5
ffffffffc0206174:	876e                	mv	a4,s11
ffffffffc0206176:	85a6                	mv	a1,s1
ffffffffc0206178:	854a                	mv	a0,s2
ffffffffc020617a:	d4fff0ef          	jal	ra,ffffffffc0205ec8 <printnum>
            break;
ffffffffc020617e:	bbc5                	j	ffffffffc0205f6e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206180:	00144603          	lbu	a2,1(s0)
ffffffffc0206184:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206186:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206188:	b515                	j	ffffffffc0205fac <vprintfmt+0x78>
            goto reswitch;
ffffffffc020618a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020618e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206190:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206192:	bd29                	j	ffffffffc0205fac <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206194:	85a6                	mv	a1,s1
ffffffffc0206196:	02500513          	li	a0,37
ffffffffc020619a:	9902                	jalr	s2
            break;
ffffffffc020619c:	bbc9                	j	ffffffffc0205f6e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020619e:	4705                	li	a4,1
ffffffffc02061a0:	008a8593          	addi	a1,s5,8
ffffffffc02061a4:	01074463          	blt	a4,a6,ffffffffc02061ac <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02061a8:	08080d63          	beqz	a6,ffffffffc0206242 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02061ac:	000ab603          	ld	a2,0(s5)
ffffffffc02061b0:	46a9                	li	a3,10
ffffffffc02061b2:	8aae                	mv	s5,a1
ffffffffc02061b4:	bf7d                	j	ffffffffc0206172 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02061b6:	85a6                	mv	a1,s1
ffffffffc02061b8:	02500513          	li	a0,37
ffffffffc02061bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02061be:	fff44703          	lbu	a4,-1(s0)
ffffffffc02061c2:	02500793          	li	a5,37
ffffffffc02061c6:	8d22                	mv	s10,s0
ffffffffc02061c8:	daf703e3          	beq	a4,a5,ffffffffc0205f6e <vprintfmt+0x3a>
ffffffffc02061cc:	02500713          	li	a4,37
ffffffffc02061d0:	1d7d                	addi	s10,s10,-1
ffffffffc02061d2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02061d6:	fee79de3          	bne	a5,a4,ffffffffc02061d0 <vprintfmt+0x29c>
ffffffffc02061da:	bb51                	j	ffffffffc0205f6e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02061dc:	00002617          	auipc	a2,0x2
ffffffffc02061e0:	7f460613          	addi	a2,a2,2036 # ffffffffc02089d0 <error_string+0x1a8>
ffffffffc02061e4:	85a6                	mv	a1,s1
ffffffffc02061e6:	854a                	mv	a0,s2
ffffffffc02061e8:	0ac000ef          	jal	ra,ffffffffc0206294 <printfmt>
ffffffffc02061ec:	b349                	j	ffffffffc0205f6e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02061ee:	00002617          	auipc	a2,0x2
ffffffffc02061f2:	7da60613          	addi	a2,a2,2010 # ffffffffc02089c8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02061f6:	00002417          	auipc	s0,0x2
ffffffffc02061fa:	7d340413          	addi	s0,s0,2003 # ffffffffc02089c9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02061fe:	8532                	mv	a0,a2
ffffffffc0206200:	85e6                	mv	a1,s9
ffffffffc0206202:	e032                	sd	a2,0(sp)
ffffffffc0206204:	e43e                	sd	a5,8(sp)
ffffffffc0206206:	0cc000ef          	jal	ra,ffffffffc02062d2 <strnlen>
ffffffffc020620a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020620e:	6602                	ld	a2,0(sp)
ffffffffc0206210:	01b05d63          	blez	s11,ffffffffc020622a <vprintfmt+0x2f6>
ffffffffc0206214:	67a2                	ld	a5,8(sp)
ffffffffc0206216:	2781                	sext.w	a5,a5
ffffffffc0206218:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020621a:	6522                	ld	a0,8(sp)
ffffffffc020621c:	85a6                	mv	a1,s1
ffffffffc020621e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206220:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206222:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206224:	6602                	ld	a2,0(sp)
ffffffffc0206226:	fe0d9ae3          	bnez	s11,ffffffffc020621a <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020622a:	00064783          	lbu	a5,0(a2)
ffffffffc020622e:	0007851b          	sext.w	a0,a5
ffffffffc0206232:	ec0510e3          	bnez	a0,ffffffffc02060f2 <vprintfmt+0x1be>
ffffffffc0206236:	bb25                	j	ffffffffc0205f6e <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0206238:	000ae603          	lwu	a2,0(s5)
ffffffffc020623c:	46a1                	li	a3,8
ffffffffc020623e:	8aae                	mv	s5,a1
ffffffffc0206240:	bf0d                	j	ffffffffc0206172 <vprintfmt+0x23e>
ffffffffc0206242:	000ae603          	lwu	a2,0(s5)
ffffffffc0206246:	46a9                	li	a3,10
ffffffffc0206248:	8aae                	mv	s5,a1
ffffffffc020624a:	b725                	j	ffffffffc0206172 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc020624c:	000aa403          	lw	s0,0(s5)
ffffffffc0206250:	bd35                	j	ffffffffc020608c <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0206252:	000ae603          	lwu	a2,0(s5)
ffffffffc0206256:	46c1                	li	a3,16
ffffffffc0206258:	8aae                	mv	s5,a1
ffffffffc020625a:	bf21                	j	ffffffffc0206172 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc020625c:	9902                	jalr	s2
ffffffffc020625e:	bd45                	j	ffffffffc020610e <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0206260:	85a6                	mv	a1,s1
ffffffffc0206262:	02d00513          	li	a0,45
ffffffffc0206266:	e03e                	sd	a5,0(sp)
ffffffffc0206268:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020626a:	8ace                	mv	s5,s3
ffffffffc020626c:	40800633          	neg	a2,s0
ffffffffc0206270:	46a9                	li	a3,10
ffffffffc0206272:	6782                	ld	a5,0(sp)
ffffffffc0206274:	bdfd                	j	ffffffffc0206172 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0206276:	01b05663          	blez	s11,ffffffffc0206282 <vprintfmt+0x34e>
ffffffffc020627a:	02d00693          	li	a3,45
ffffffffc020627e:	f6d798e3          	bne	a5,a3,ffffffffc02061ee <vprintfmt+0x2ba>
ffffffffc0206282:	00002417          	auipc	s0,0x2
ffffffffc0206286:	74740413          	addi	s0,s0,1863 # ffffffffc02089c9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020628a:	02800513          	li	a0,40
ffffffffc020628e:	02800793          	li	a5,40
ffffffffc0206292:	b585                	j	ffffffffc02060f2 <vprintfmt+0x1be>

ffffffffc0206294 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206294:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206296:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020629a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020629c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020629e:	ec06                	sd	ra,24(sp)
ffffffffc02062a0:	f83a                	sd	a4,48(sp)
ffffffffc02062a2:	fc3e                	sd	a5,56(sp)
ffffffffc02062a4:	e0c2                	sd	a6,64(sp)
ffffffffc02062a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02062a8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02062aa:	c8bff0ef          	jal	ra,ffffffffc0205f34 <vprintfmt>
}
ffffffffc02062ae:	60e2                	ld	ra,24(sp)
ffffffffc02062b0:	6161                	addi	sp,sp,80
ffffffffc02062b2:	8082                	ret

ffffffffc02062b4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02062b4:	00054783          	lbu	a5,0(a0)
ffffffffc02062b8:	cb91                	beqz	a5,ffffffffc02062cc <strlen+0x18>
    size_t cnt = 0;
ffffffffc02062ba:	4781                	li	a5,0
        cnt ++;
ffffffffc02062bc:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02062be:	00f50733          	add	a4,a0,a5
ffffffffc02062c2:	00074703          	lbu	a4,0(a4)
ffffffffc02062c6:	fb7d                	bnez	a4,ffffffffc02062bc <strlen+0x8>
    }
    return cnt;
}
ffffffffc02062c8:	853e                	mv	a0,a5
ffffffffc02062ca:	8082                	ret
    size_t cnt = 0;
ffffffffc02062cc:	4781                	li	a5,0
}
ffffffffc02062ce:	853e                	mv	a0,a5
ffffffffc02062d0:	8082                	ret

ffffffffc02062d2 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062d2:	c185                	beqz	a1,ffffffffc02062f2 <strnlen+0x20>
ffffffffc02062d4:	00054783          	lbu	a5,0(a0)
ffffffffc02062d8:	cf89                	beqz	a5,ffffffffc02062f2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02062da:	4781                	li	a5,0
ffffffffc02062dc:	a021                	j	ffffffffc02062e4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062de:	00074703          	lbu	a4,0(a4)
ffffffffc02062e2:	c711                	beqz	a4,ffffffffc02062ee <strnlen+0x1c>
        cnt ++;
ffffffffc02062e4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062e6:	00f50733          	add	a4,a0,a5
ffffffffc02062ea:	fef59ae3          	bne	a1,a5,ffffffffc02062de <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02062ee:	853e                	mv	a0,a5
ffffffffc02062f0:	8082                	ret
    size_t cnt = 0;
ffffffffc02062f2:	4781                	li	a5,0
}
ffffffffc02062f4:	853e                	mv	a0,a5
ffffffffc02062f6:	8082                	ret

ffffffffc02062f8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02062f8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02062fa:	0585                	addi	a1,a1,1
ffffffffc02062fc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206300:	0785                	addi	a5,a5,1
ffffffffc0206302:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206306:	fb75                	bnez	a4,ffffffffc02062fa <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206308:	8082                	ret

ffffffffc020630a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020630a:	00054783          	lbu	a5,0(a0)
ffffffffc020630e:	0005c703          	lbu	a4,0(a1)
ffffffffc0206312:	cb91                	beqz	a5,ffffffffc0206326 <strcmp+0x1c>
ffffffffc0206314:	00e79c63          	bne	a5,a4,ffffffffc020632c <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206318:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020631a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020631e:	0585                	addi	a1,a1,1
ffffffffc0206320:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206324:	fbe5                	bnez	a5,ffffffffc0206314 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206326:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206328:	9d19                	subw	a0,a0,a4
ffffffffc020632a:	8082                	ret
ffffffffc020632c:	0007851b          	sext.w	a0,a5
ffffffffc0206330:	9d19                	subw	a0,a0,a4
ffffffffc0206332:	8082                	ret

ffffffffc0206334 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206334:	00054783          	lbu	a5,0(a0)
ffffffffc0206338:	cb91                	beqz	a5,ffffffffc020634c <strchr+0x18>
        if (*s == c) {
ffffffffc020633a:	00b79563          	bne	a5,a1,ffffffffc0206344 <strchr+0x10>
ffffffffc020633e:	a809                	j	ffffffffc0206350 <strchr+0x1c>
ffffffffc0206340:	00b78763          	beq	a5,a1,ffffffffc020634e <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206344:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206346:	00054783          	lbu	a5,0(a0)
ffffffffc020634a:	fbfd                	bnez	a5,ffffffffc0206340 <strchr+0xc>
    }
    return NULL;
ffffffffc020634c:	4501                	li	a0,0
}
ffffffffc020634e:	8082                	ret
ffffffffc0206350:	8082                	ret

ffffffffc0206352 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206352:	ca01                	beqz	a2,ffffffffc0206362 <memset+0x10>
ffffffffc0206354:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206356:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206358:	0785                	addi	a5,a5,1
ffffffffc020635a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020635e:	fec79de3          	bne	a5,a2,ffffffffc0206358 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206362:	8082                	ret

ffffffffc0206364 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206364:	ca19                	beqz	a2,ffffffffc020637a <memcpy+0x16>
ffffffffc0206366:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206368:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020636a:	0585                	addi	a1,a1,1
ffffffffc020636c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206370:	0785                	addi	a5,a5,1
ffffffffc0206372:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206376:	fec59ae3          	bne	a1,a2,ffffffffc020636a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020637a:	8082                	ret

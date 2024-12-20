
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
ffffffffc0200042:	96260613          	addi	a2,a2,-1694 # ffffffffc02ac9a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	584060ef          	jal	ra,ffffffffc02065d2 <memset>
    cons_init();                // init the console
ffffffffc0200052:	530000ef          	jal	ra,ffffffffc0200582 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5aa58593          	addi	a1,a1,1450 # ffffffffc0206600 <etext+0x4>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5c250513          	addi	a0,a0,1474 # ffffffffc0206620 <etext+0x24>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1aa000ef          	jal	ra,ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5ba020ef          	jal	ra,ffffffffc0202628 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3e8040ef          	jal	ra,ffffffffc0204462 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	4f1050ef          	jal	ra,ffffffffc0205d6e <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	572000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2f6030ef          	jal	ra,ffffffffc020337c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a4000ef          	jal	ra,ffffffffc020052e <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5be000ef          	jal	ra,ffffffffc020064c <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	629050ef          	jal	ra,ffffffffc0205eba <cpu_idle>

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
ffffffffc02000b2:	57a50513          	addi	a0,a0,1402 # ffffffffc0206628 <etext+0x2c>
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
ffffffffc0200182:	032060ef          	jal	ra,ffffffffc02061b4 <vprintfmt>
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
ffffffffc02001b6:	7ff050ef          	jal	ra,ffffffffc02061b4 <vprintfmt>
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
ffffffffc020021a:	44a50513          	addi	a0,a0,1098 # ffffffffc0206660 <etext+0x64>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e1258593          	addi	a1,a1,-494 # ffffffffc0200036 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	45450513          	addi	a0,a0,1108 # ffffffffc0206680 <etext+0x84>
ffffffffc0200234:	f5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	3c458593          	addi	a1,a1,964 # ffffffffc02065fc <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	46050513          	addi	a0,a0,1120 # ffffffffc02066a0 <etext+0xa4>
ffffffffc0200248:	f47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	000a1597          	auipc	a1,0xa1
ffffffffc0200250:	1bc58593          	addi	a1,a1,444 # ffffffffc02a1408 <edata>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	46c50513          	addi	a0,a0,1132 # ffffffffc02066c0 <etext+0xc4>
ffffffffc020025c:	f33ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	000ac597          	auipc	a1,0xac
ffffffffc0200264:	74058593          	addi	a1,a1,1856 # ffffffffc02ac9a0 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	47850513          	addi	a0,a0,1144 # ffffffffc02066e0 <etext+0xe4>
ffffffffc0200270:	f1fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	000ad597          	auipc	a1,0xad
ffffffffc0200278:	b2b58593          	addi	a1,a1,-1237 # ffffffffc02acd9f <end+0x3ff>
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
ffffffffc020029a:	46a50513          	addi	a0,a0,1130 # ffffffffc0206700 <etext+0x104>
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
ffffffffc02002a8:	38c60613          	addi	a2,a2,908 # ffffffffc0206630 <etext+0x34>
ffffffffc02002ac:	04d00593          	li	a1,77
ffffffffc02002b0:	00006517          	auipc	a0,0x6
ffffffffc02002b4:	39850513          	addi	a0,a0,920 # ffffffffc0206648 <etext+0x4c>
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
ffffffffc02002c4:	55060613          	addi	a2,a2,1360 # ffffffffc0206810 <commands+0xe0>
ffffffffc02002c8:	00006597          	auipc	a1,0x6
ffffffffc02002cc:	56858593          	addi	a1,a1,1384 # ffffffffc0206830 <commands+0x100>
ffffffffc02002d0:	00006517          	auipc	a0,0x6
ffffffffc02002d4:	56850513          	addi	a0,a0,1384 # ffffffffc0206838 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002da:	eb5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002de:	00006617          	auipc	a2,0x6
ffffffffc02002e2:	56a60613          	addi	a2,a2,1386 # ffffffffc0206848 <commands+0x118>
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	58a58593          	addi	a1,a1,1418 # ffffffffc0206870 <commands+0x140>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	54a50513          	addi	a0,a0,1354 # ffffffffc0206838 <commands+0x108>
ffffffffc02002f6:	e99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fa:	00006617          	auipc	a2,0x6
ffffffffc02002fe:	58660613          	addi	a2,a2,1414 # ffffffffc0206880 <commands+0x150>
ffffffffc0200302:	00006597          	auipc	a1,0x6
ffffffffc0200306:	59e58593          	addi	a1,a1,1438 # ffffffffc02068a0 <commands+0x170>
ffffffffc020030a:	00006517          	auipc	a0,0x6
ffffffffc020030e:	52e50513          	addi	a0,a0,1326 # ffffffffc0206838 <commands+0x108>
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
ffffffffc0200348:	43450513          	addi	a0,a0,1076 # ffffffffc0206778 <commands+0x48>
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
ffffffffc020036a:	43a50513          	addi	a0,a0,1082 # ffffffffc02067a0 <commands+0x70>
ffffffffc020036e:	e21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200372:	000c0563          	beqz	s8,ffffffffc020037c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200376:	8562                	mv	a0,s8
ffffffffc0200378:	4c8000ef          	jal	ra,ffffffffc0200840 <print_trapframe>
ffffffffc020037c:	00006c97          	auipc	s9,0x6
ffffffffc0200380:	3b4c8c93          	addi	s9,s9,948 # ffffffffc0206730 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200384:	00006997          	auipc	s3,0x6
ffffffffc0200388:	44498993          	addi	s3,s3,1092 # ffffffffc02067c8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	44490913          	addi	s2,s2,1092 # ffffffffc02067d0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200394:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200396:	00006b17          	auipc	s6,0x6
ffffffffc020039a:	442b0b13          	addi	s6,s6,1090 # ffffffffc02067d8 <commands+0xa8>
    if (argc == 0) {
ffffffffc020039e:	00006a97          	auipc	s5,0x6
ffffffffc02003a2:	492a8a93          	addi	s5,s5,1170 # ffffffffc0206830 <commands+0x100>
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
ffffffffc02003bc:	1f8060ef          	jal	ra,ffffffffc02065b4 <strchr>
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
ffffffffc02003d6:	35ed0d13          	addi	s10,s10,862 # ffffffffc0206730 <commands>
    if (argc == 0) {
ffffffffc02003da:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003dc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003de:	0d61                	addi	s10,s10,24
ffffffffc02003e0:	1aa060ef          	jal	ra,ffffffffc020658a <strcmp>
ffffffffc02003e4:	c919                	beqz	a0,ffffffffc02003fa <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	2405                	addiw	s0,s0,1
ffffffffc02003e8:	09740463          	beq	s0,s7,ffffffffc0200470 <kmonitor+0x132>
ffffffffc02003ec:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	0d61                	addi	s10,s10,24
ffffffffc02003f4:	196060ef          	jal	ra,ffffffffc020658a <strcmp>
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
ffffffffc020045a:	15a060ef          	jal	ra,ffffffffc02065b4 <strchr>
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
ffffffffc0200476:	38650513          	addi	a0,a0,902 # ffffffffc02067f8 <commands+0xc8>
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
ffffffffc02004b6:	3fe50513          	addi	a0,a0,1022 # ffffffffc02068b0 <commands+0x180>
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
ffffffffc02004cc:	3b050513          	addi	a0,a0,944 # ffffffffc0207878 <default_pmm_manager+0x530>
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
ffffffffc02004e0:	172000ef          	jal	ra,ffffffffc0200652 <intr_disable>
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
ffffffffc02004fe:	3d650513          	addi	a0,a0,982 # ffffffffc02068d0 <commands+0x1a0>
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
ffffffffc020051e:	35e50513          	addi	a0,a0,862 # ffffffffc0207878 <default_pmm_manager+0x530>
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
ffffffffc0200558:	39c50513          	addi	a0,a0,924 # ffffffffc02068f0 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000ac797          	auipc	a5,0xac
ffffffffc0200560:	3007ba23          	sd	zero,788(a5) # ffffffffc02ac870 <ticks>
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
ffffffffc02005a2:	0b0000ef          	jal	ra,ffffffffc0200652 <intr_disable>
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
ffffffffc02005b6:	a859                	j	ffffffffc020064c <intr_enable>

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
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
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

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000a1797          	auipc	a5,0xa1
ffffffffc0200606:	20678793          	addi	a5,a5,518 # ffffffffc02a1808 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	7cb050ef          	jal	ra,ffffffffc02065e4 <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000a1517          	auipc	a0,0xa1
ffffffffc0200630:	1dc50513          	addi	a0,a0,476 # ffffffffc02a1808 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	7a5050ef          	jal	ra,ffffffffc02065e4 <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	69678793          	addi	a5,a5,1686 # ffffffffc0200cf4 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00006517          	auipc	a0,0x6
ffffffffc0200680:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206c48 <commands+0x518>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b09ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	5d450513          	addi	a0,a0,1492 # ffffffffc0206c60 <commands+0x530>
ffffffffc0200694:	afbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	5de50513          	addi	a0,a0,1502 # ffffffffc0206c78 <commands+0x548>
ffffffffc02006a2:	aedff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	5e850513          	addi	a0,a0,1512 # ffffffffc0206c90 <commands+0x560>
ffffffffc02006b0:	adfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	5f250513          	addi	a0,a0,1522 # ffffffffc0206ca8 <commands+0x578>
ffffffffc02006be:	ad1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206cc0 <commands+0x590>
ffffffffc02006cc:	ac3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	60650513          	addi	a0,a0,1542 # ffffffffc0206cd8 <commands+0x5a8>
ffffffffc02006da:	ab5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	61050513          	addi	a0,a0,1552 # ffffffffc0206cf0 <commands+0x5c0>
ffffffffc02006e8:	aa7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	61a50513          	addi	a0,a0,1562 # ffffffffc0206d08 <commands+0x5d8>
ffffffffc02006f6:	a99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	62450513          	addi	a0,a0,1572 # ffffffffc0206d20 <commands+0x5f0>
ffffffffc0200704:	a8bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206d38 <commands+0x608>
ffffffffc0200712:	a7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	63850513          	addi	a0,a0,1592 # ffffffffc0206d50 <commands+0x620>
ffffffffc0200720:	a6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	64250513          	addi	a0,a0,1602 # ffffffffc0206d68 <commands+0x638>
ffffffffc020072e:	a61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	64c50513          	addi	a0,a0,1612 # ffffffffc0206d80 <commands+0x650>
ffffffffc020073c:	a53ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	65650513          	addi	a0,a0,1622 # ffffffffc0206d98 <commands+0x668>
ffffffffc020074a:	a45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	66050513          	addi	a0,a0,1632 # ffffffffc0206db0 <commands+0x680>
ffffffffc0200758:	a37ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	66a50513          	addi	a0,a0,1642 # ffffffffc0206dc8 <commands+0x698>
ffffffffc0200766:	a29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	67450513          	addi	a0,a0,1652 # ffffffffc0206de0 <commands+0x6b0>
ffffffffc0200774:	a1bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	67e50513          	addi	a0,a0,1662 # ffffffffc0206df8 <commands+0x6c8>
ffffffffc0200782:	a0dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	68850513          	addi	a0,a0,1672 # ffffffffc0206e10 <commands+0x6e0>
ffffffffc0200790:	9ffff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	69250513          	addi	a0,a0,1682 # ffffffffc0206e28 <commands+0x6f8>
ffffffffc020079e:	9f1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	69c50513          	addi	a0,a0,1692 # ffffffffc0206e40 <commands+0x710>
ffffffffc02007ac:	9e3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	6a650513          	addi	a0,a0,1702 # ffffffffc0206e58 <commands+0x728>
ffffffffc02007ba:	9d5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	6b050513          	addi	a0,a0,1712 # ffffffffc0206e70 <commands+0x740>
ffffffffc02007c8:	9c7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206e88 <commands+0x758>
ffffffffc02007d6:	9b9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	6c450513          	addi	a0,a0,1732 # ffffffffc0206ea0 <commands+0x770>
ffffffffc02007e4:	9abff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206eb8 <commands+0x788>
ffffffffc02007f2:	99dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	6d850513          	addi	a0,a0,1752 # ffffffffc0206ed0 <commands+0x7a0>
ffffffffc0200800:	98fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	6e250513          	addi	a0,a0,1762 # ffffffffc0206ee8 <commands+0x7b8>
ffffffffc020080e:	981ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206f00 <commands+0x7d0>
ffffffffc020081c:	973ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	6f650513          	addi	a0,a0,1782 # ffffffffc0206f18 <commands+0x7e8>
ffffffffc020082a:	965ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00006517          	auipc	a0,0x6
ffffffffc0200838:	6fc50513          	addi	a0,a0,1788 # ffffffffc0206f30 <commands+0x800>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	ba81                	j	ffffffffc020018e <cprintf>

ffffffffc0200840 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	1141                	addi	sp,sp,-16
ffffffffc0200842:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200844:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	00006517          	auipc	a0,0x6
ffffffffc020084c:	70050513          	addi	a0,a0,1792 # ffffffffc0206f48 <commands+0x818>
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	93dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200856:	8522                	mv	a0,s0
ffffffffc0200858:	e1dff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085c:	10043583          	ld	a1,256(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	70050513          	addi	a0,a0,1792 # ffffffffc0206f60 <commands+0x830>
ffffffffc0200868:	927ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086c:	10843583          	ld	a1,264(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	70850513          	addi	a0,a0,1800 # ffffffffc0206f78 <commands+0x848>
ffffffffc0200878:	917ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087c:	11043583          	ld	a1,272(s0)
ffffffffc0200880:	00006517          	auipc	a0,0x6
ffffffffc0200884:	71050513          	addi	a0,a0,1808 # ffffffffc0206f90 <commands+0x860>
ffffffffc0200888:	907ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200890:	6402                	ld	s0,0(sp)
ffffffffc0200892:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	00006517          	auipc	a0,0x6
ffffffffc0200898:	70c50513          	addi	a0,a0,1804 # ffffffffc0206fa0 <commands+0x870>
}
ffffffffc020089c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	8f1ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008a2 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a2:	1101                	addi	sp,sp,-32
ffffffffc02008a4:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	000ac497          	auipc	s1,0xac
ffffffffc02008aa:	0e248493          	addi	s1,s1,226 # ffffffffc02ac988 <check_mm_struct>
ffffffffc02008ae:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b0:	e822                	sd	s0,16(sp)
ffffffffc02008b2:	ec06                	sd	ra,24(sp)
ffffffffc02008b4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b6:	cbbd                	beqz	a5,ffffffffc020092c <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	11053583          	ld	a1,272(a0)
ffffffffc02008c0:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c8:	cba1                	beqz	a5,ffffffffc0200918 <pgfault_handler+0x76>
ffffffffc02008ca:	11843703          	ld	a4,280(s0)
ffffffffc02008ce:	47bd                	li	a5,15
ffffffffc02008d0:	05700693          	li	a3,87
ffffffffc02008d4:	00f70463          	beq	a4,a5,ffffffffc02008dc <pgfault_handler+0x3a>
ffffffffc02008d8:	05200693          	li	a3,82
ffffffffc02008dc:	00006517          	auipc	a0,0x6
ffffffffc02008e0:	2ec50513          	addi	a0,a0,748 # ffffffffc0206bc8 <commands+0x498>
ffffffffc02008e4:	8abff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008e8:	6088                	ld	a0,0(s1)
ffffffffc02008ea:	c129                	beqz	a0,ffffffffc020092c <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ec:	000ac797          	auipc	a5,0xac
ffffffffc02008f0:	f6478793          	addi	a5,a5,-156 # ffffffffc02ac850 <current>
ffffffffc02008f4:	6398                	ld	a4,0(a5)
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	f6278793          	addi	a5,a5,-158 # ffffffffc02ac858 <idleproc>
ffffffffc02008fe:	639c                	ld	a5,0(a5)
ffffffffc0200900:	04f71763          	bne	a4,a5,ffffffffc020094e <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	11043603          	ld	a2,272(s0)
ffffffffc0200908:	11843583          	ld	a1,280(s0)
}
ffffffffc020090c:	6442                	ld	s0,16(sp)
ffffffffc020090e:	60e2                	ld	ra,24(sp)
ffffffffc0200910:	64a2                	ld	s1,8(sp)
ffffffffc0200912:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	0940406f          	j	ffffffffc02049a8 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200918:	11843703          	ld	a4,280(s0)
ffffffffc020091c:	47bd                	li	a5,15
ffffffffc020091e:	05500613          	li	a2,85
ffffffffc0200922:	05700693          	li	a3,87
ffffffffc0200926:	faf719e3          	bne	a4,a5,ffffffffc02008d8 <pgfault_handler+0x36>
ffffffffc020092a:	bf4d                	j	ffffffffc02008dc <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092c:	000ac797          	auipc	a5,0xac
ffffffffc0200930:	f2478793          	addi	a5,a5,-220 # ffffffffc02ac850 <current>
ffffffffc0200934:	639c                	ld	a5,0(a5)
ffffffffc0200936:	cf85                	beqz	a5,ffffffffc020096e <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	11043603          	ld	a2,272(s0)
ffffffffc020093c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200940:	6442                	ld	s0,16(sp)
ffffffffc0200942:	60e2                	ld	ra,24(sp)
ffffffffc0200944:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200946:	7788                	ld	a0,40(a5)
}
ffffffffc0200948:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094a:	05e0406f          	j	ffffffffc02049a8 <do_pgfault>
        assert(current == idleproc);
ffffffffc020094e:	00006697          	auipc	a3,0x6
ffffffffc0200952:	29a68693          	addi	a3,a3,666 # ffffffffc0206be8 <commands+0x4b8>
ffffffffc0200956:	00006617          	auipc	a2,0x6
ffffffffc020095a:	2aa60613          	addi	a2,a2,682 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020095e:	06c00593          	li	a1,108
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	2b650513          	addi	a0,a0,694 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc020096a:	b17ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	ed1ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200974:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200978:	11043583          	ld	a1,272(s0)
ffffffffc020097c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200980:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200984:	e399                	bnez	a5,ffffffffc020098a <pgfault_handler+0xe8>
ffffffffc0200986:	05500613          	li	a2,85
ffffffffc020098a:	11843703          	ld	a4,280(s0)
ffffffffc020098e:	47bd                	li	a5,15
ffffffffc0200990:	02f70663          	beq	a4,a5,ffffffffc02009bc <pgfault_handler+0x11a>
ffffffffc0200994:	05200693          	li	a3,82
ffffffffc0200998:	00006517          	auipc	a0,0x6
ffffffffc020099c:	23050513          	addi	a0,a0,560 # ffffffffc0206bc8 <commands+0x498>
ffffffffc02009a0:	feeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a4:	00006617          	auipc	a2,0x6
ffffffffc02009a8:	28c60613          	addi	a2,a2,652 # ffffffffc0206c30 <commands+0x500>
ffffffffc02009ac:	07300593          	li	a1,115
ffffffffc02009b0:	00006517          	auipc	a0,0x6
ffffffffc02009b4:	26850513          	addi	a0,a0,616 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc02009b8:	ac9ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009bc:	05700693          	li	a3,87
ffffffffc02009c0:	bfe1                	j	ffffffffc0200998 <pgfault_handler+0xf6>

ffffffffc02009c2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009c6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c8:	0786                	slli	a5,a5,0x1
ffffffffc02009ca:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009cc:	08f76f63          	bltu	a4,a5,ffffffffc0200a6a <interrupt_handler+0xa8>
ffffffffc02009d0:	00006717          	auipc	a4,0x6
ffffffffc02009d4:	f3c70713          	addi	a4,a4,-196 # ffffffffc020690c <commands+0x1dc>
ffffffffc02009d8:	078a                	slli	a5,a5,0x2
ffffffffc02009da:	97ba                	add	a5,a5,a4
ffffffffc02009dc:	439c                	lw	a5,0(a5)
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	19650513          	addi	a0,a0,406 # ffffffffc0206b78 <commands+0x448>
ffffffffc02009ea:	fa4ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	16a50513          	addi	a0,a0,362 # ffffffffc0206b58 <commands+0x428>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	11e50513          	addi	a0,a0,286 # ffffffffc0206b18 <commands+0x3e8>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	13250513          	addi	a0,a0,306 # ffffffffc0206b38 <commands+0x408>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	19650513          	addi	a0,a0,406 # ffffffffc0206ba8 <commands+0x478>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a1e:	1141                	addi	sp,sp,-16
ffffffffc0200a20:	e022                	sd	s0,0(sp)
ffffffffc0200a22:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a24:	b43ff0ef          	jal	ra,ffffffffc0200566 <clock_set_next_event>
            ticks++;
ffffffffc0200a28:	000ac797          	auipc	a5,0xac
ffffffffc0200a2c:	df878793          	addi	a5,a5,-520 # ffffffffc02ac820 <ticks.1754>
ffffffffc0200a30:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
ffffffffc0200a32:	06400713          	li	a4,100
ffffffffc0200a36:	000ac417          	auipc	s0,0xac
ffffffffc0200a3a:	de240413          	addi	s0,s0,-542 # ffffffffc02ac818 <num>
            ticks++;
ffffffffc0200a3e:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
ffffffffc0200a40:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200a44:	000ac697          	auipc	a3,0xac
ffffffffc0200a48:	dcf6ae23          	sw	a5,-548(a3) # ffffffffc02ac820 <ticks.1754>
            if (ticks % TICK_NUM == 0){
ffffffffc0200a4c:	c305                	beqz	a4,ffffffffc0200a6c <interrupt_handler+0xaa>
            if (num == 10){
ffffffffc0200a4e:	6018                	ld	a4,0(s0)
ffffffffc0200a50:	47a9                	li	a5,10
ffffffffc0200a52:	00f71863          	bne	a4,a5,ffffffffc0200a62 <interrupt_handler+0xa0>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200a56:	4501                	li	a0,0
ffffffffc0200a58:	4581                	li	a1,0
ffffffffc0200a5a:	4601                	li	a2,0
ffffffffc0200a5c:	48a1                	li	a7,8
ffffffffc0200a5e:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	6402                	ld	s0,0(sp)
ffffffffc0200a66:	0141                	addi	sp,sp,16
ffffffffc0200a68:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a6a:	bbd9                	j	ffffffffc0200840 <print_trapframe>
            num++;
ffffffffc0200a6c:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n",TICK_NUM);
ffffffffc0200a6e:	06400593          	li	a1,100
ffffffffc0200a72:	00006517          	auipc	a0,0x6
ffffffffc0200a76:	12650513          	addi	a0,a0,294 # ffffffffc0206b98 <commands+0x468>
            num++;
ffffffffc0200a7a:	0785                	addi	a5,a5,1
ffffffffc0200a7c:	000ac717          	auipc	a4,0xac
ffffffffc0200a80:	d8f73e23          	sd	a5,-612(a4) # ffffffffc02ac818 <num>
    cprintf("%d ticks\n",TICK_NUM);
ffffffffc0200a84:	f0aff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200a88:	b7d9                	j	ffffffffc0200a4e <interrupt_handler+0x8c>

ffffffffc0200a8a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a8a:	11853783          	ld	a5,280(a0)
ffffffffc0200a8e:	473d                	li	a4,15
ffffffffc0200a90:	1af76c63          	bltu	a4,a5,ffffffffc0200c48 <exception_handler+0x1be>
ffffffffc0200a94:	00006717          	auipc	a4,0x6
ffffffffc0200a98:	ea870713          	addi	a4,a4,-344 # ffffffffc020693c <commands+0x20c>
ffffffffc0200a9c:	078a                	slli	a5,a5,0x2
ffffffffc0200a9e:	97ba                	add	a5,a5,a4
ffffffffc0200aa0:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200aa2:	1101                	addi	sp,sp,-32
ffffffffc0200aa4:	e822                	sd	s0,16(sp)
ffffffffc0200aa6:	ec06                	sd	ra,24(sp)
ffffffffc0200aa8:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200aaa:	97ba                	add	a5,a5,a4
ffffffffc0200aac:	842a                	mv	s0,a0
ffffffffc0200aae:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200ab0:	00006517          	auipc	a0,0x6
ffffffffc0200ab4:	fc050513          	addi	a0,a0,-64 # ffffffffc0206a70 <commands+0x340>
ffffffffc0200ab8:	ed6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200abc:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200ac0:	60e2                	ld	ra,24(sp)
ffffffffc0200ac2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200ac4:	0791                	addi	a5,a5,4
ffffffffc0200ac6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aca:	6442                	ld	s0,16(sp)
ffffffffc0200acc:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200ace:	5e20506f          	j	ffffffffc02060b0 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ad2:	00006517          	auipc	a0,0x6
ffffffffc0200ad6:	fbe50513          	addi	a0,a0,-66 # ffffffffc0206a90 <commands+0x360>
}
ffffffffc0200ada:	6442                	ld	s0,16(sp)
ffffffffc0200adc:	60e2                	ld	ra,24(sp)
ffffffffc0200ade:	64a2                	ld	s1,8(sp)
ffffffffc0200ae0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ae2:	eacff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ae6:	00006517          	auipc	a0,0x6
ffffffffc0200aea:	fca50513          	addi	a0,a0,-54 # ffffffffc0206ab0 <commands+0x380>
ffffffffc0200aee:	b7f5                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200af0:	00006517          	auipc	a0,0x6
ffffffffc0200af4:	fe050513          	addi	a0,a0,-32 # ffffffffc0206ad0 <commands+0x3a0>
ffffffffc0200af8:	b7cd                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200afa:	00006517          	auipc	a0,0x6
ffffffffc0200afe:	fee50513          	addi	a0,a0,-18 # ffffffffc0206ae8 <commands+0x3b8>
ffffffffc0200b02:	e8cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	d9bff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b0c:	84aa                	mv	s1,a0
ffffffffc0200b0e:	12051e63          	bnez	a0,ffffffffc0200c4a <exception_handler+0x1c0>
}
ffffffffc0200b12:	60e2                	ld	ra,24(sp)
ffffffffc0200b14:	6442                	ld	s0,16(sp)
ffffffffc0200b16:	64a2                	ld	s1,8(sp)
ffffffffc0200b18:	6105                	addi	sp,sp,32
ffffffffc0200b1a:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200b1c:	00006517          	auipc	a0,0x6
ffffffffc0200b20:	fe450513          	addi	a0,a0,-28 # ffffffffc0206b00 <commands+0x3d0>
ffffffffc0200b24:	e6aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b28:	8522                	mv	a0,s0
ffffffffc0200b2a:	d79ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b2e:	84aa                	mv	s1,a0
ffffffffc0200b30:	d16d                	beqz	a0,ffffffffc0200b12 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b32:	8522                	mv	a0,s0
ffffffffc0200b34:	d0dff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b38:	86a6                	mv	a3,s1
ffffffffc0200b3a:	00006617          	auipc	a2,0x6
ffffffffc0200b3e:	ee660613          	addi	a2,a2,-282 # ffffffffc0206a20 <commands+0x2f0>
ffffffffc0200b42:	0ff00593          	li	a1,255
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	0d250513          	addi	a0,a0,210 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc0200b4e:	933ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b52:	00006517          	auipc	a0,0x6
ffffffffc0200b56:	e2e50513          	addi	a0,a0,-466 # ffffffffc0206980 <commands+0x250>
ffffffffc0200b5a:	b741                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b5c:	00006517          	auipc	a0,0x6
ffffffffc0200b60:	e4450513          	addi	a0,a0,-444 # ffffffffc02069a0 <commands+0x270>
ffffffffc0200b64:	bf9d                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	e5a50513          	addi	a0,a0,-422 # ffffffffc02069c0 <commands+0x290>
ffffffffc0200b6e:	b7b5                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	e6850513          	addi	a0,a0,-408 # ffffffffc02069d8 <commands+0x2a8>
ffffffffc0200b78:	e16ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b7c:	6458                	ld	a4,136(s0)
ffffffffc0200b7e:	47a9                	li	a5,10
ffffffffc0200b80:	f8f719e3          	bne	a4,a5,ffffffffc0200b12 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b84:	10843783          	ld	a5,264(s0)
ffffffffc0200b88:	0791                	addi	a5,a5,4
ffffffffc0200b8a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b8e:	522050ef          	jal	ra,ffffffffc02060b0 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b92:	000ac797          	auipc	a5,0xac
ffffffffc0200b96:	cbe78793          	addi	a5,a5,-834 # ffffffffc02ac850 <current>
ffffffffc0200b9a:	639c                	ld	a5,0(a5)
ffffffffc0200b9c:	8522                	mv	a0,s0
}
ffffffffc0200b9e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200ba0:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200ba2:	60e2                	ld	ra,24(sp)
ffffffffc0200ba4:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200ba6:	6589                	lui	a1,0x2
ffffffffc0200ba8:	95be                	add	a1,a1,a5
}
ffffffffc0200baa:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200bac:	ac19                	j	ffffffffc0200dc2 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200bae:	00006517          	auipc	a0,0x6
ffffffffc0200bb2:	e3a50513          	addi	a0,a0,-454 # ffffffffc02069e8 <commands+0x2b8>
ffffffffc0200bb6:	b715                	j	ffffffffc0200ada <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200bb8:	00006517          	auipc	a0,0x6
ffffffffc0200bbc:	e5050513          	addi	a0,a0,-432 # ffffffffc0206a08 <commands+0x2d8>
ffffffffc0200bc0:	dceff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bc4:	8522                	mv	a0,s0
ffffffffc0200bc6:	cddff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200bca:	84aa                	mv	s1,a0
ffffffffc0200bcc:	d139                	beqz	a0,ffffffffc0200b12 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	c71ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bd4:	86a6                	mv	a3,s1
ffffffffc0200bd6:	00006617          	auipc	a2,0x6
ffffffffc0200bda:	e4a60613          	addi	a2,a2,-438 # ffffffffc0206a20 <commands+0x2f0>
ffffffffc0200bde:	0d400593          	li	a1,212
ffffffffc0200be2:	00006517          	auipc	a0,0x6
ffffffffc0200be6:	03650513          	addi	a0,a0,54 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc0200bea:	897ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bee:	00006517          	auipc	a0,0x6
ffffffffc0200bf2:	e6a50513          	addi	a0,a0,-406 # ffffffffc0206a58 <commands+0x328>
ffffffffc0200bf6:	d98ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bfa:	8522                	mv	a0,s0
ffffffffc0200bfc:	ca7ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200c00:	84aa                	mv	s1,a0
ffffffffc0200c02:	f00508e3          	beqz	a0,ffffffffc0200b12 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200c06:	8522                	mv	a0,s0
ffffffffc0200c08:	c39ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c0c:	86a6                	mv	a3,s1
ffffffffc0200c0e:	00006617          	auipc	a2,0x6
ffffffffc0200c12:	e1260613          	addi	a2,a2,-494 # ffffffffc0206a20 <commands+0x2f0>
ffffffffc0200c16:	0de00593          	li	a1,222
ffffffffc0200c1a:	00006517          	auipc	a0,0x6
ffffffffc0200c1e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc0200c22:	85fff0ef          	jal	ra,ffffffffc0200480 <__panic>
}
ffffffffc0200c26:	6442                	ld	s0,16(sp)
ffffffffc0200c28:	60e2                	ld	ra,24(sp)
ffffffffc0200c2a:	64a2                	ld	s1,8(sp)
ffffffffc0200c2c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c2e:	b909                	j	ffffffffc0200840 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c30:	00006617          	auipc	a2,0x6
ffffffffc0200c34:	e1060613          	addi	a2,a2,-496 # ffffffffc0206a40 <commands+0x310>
ffffffffc0200c38:	0d800593          	li	a1,216
ffffffffc0200c3c:	00006517          	auipc	a0,0x6
ffffffffc0200c40:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc0200c44:	83dff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc0200c48:	bee5                	j	ffffffffc0200840 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c4a:	8522                	mv	a0,s0
ffffffffc0200c4c:	bf5ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c50:	86a6                	mv	a3,s1
ffffffffc0200c52:	00006617          	auipc	a2,0x6
ffffffffc0200c56:	dce60613          	addi	a2,a2,-562 # ffffffffc0206a20 <commands+0x2f0>
ffffffffc0200c5a:	0f800593          	li	a1,248
ffffffffc0200c5e:	00006517          	auipc	a0,0x6
ffffffffc0200c62:	fba50513          	addi	a0,a0,-70 # ffffffffc0206c18 <commands+0x4e8>
ffffffffc0200c66:	81bff0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0200c6a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c6a:	1101                	addi	sp,sp,-32
ffffffffc0200c6c:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c6e:	000ac417          	auipc	s0,0xac
ffffffffc0200c72:	be240413          	addi	s0,s0,-1054 # ffffffffc02ac850 <current>
ffffffffc0200c76:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c78:	ec06                	sd	ra,24(sp)
ffffffffc0200c7a:	e426                	sd	s1,8(sp)
ffffffffc0200c7c:	e04a                	sd	s2,0(sp)
ffffffffc0200c7e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c82:	cf1d                	beqz	a4,ffffffffc0200cc0 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c84:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c88:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c8c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c8e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c92:	0206c463          	bltz	a3,ffffffffc0200cba <trap+0x50>
        exception_handler(tf);
ffffffffc0200c96:	df5ff0ef          	jal	ra,ffffffffc0200a8a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c9a:	601c                	ld	a5,0(s0)
ffffffffc0200c9c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200ca0:	e499                	bnez	s1,ffffffffc0200cae <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200ca2:	0b07a703          	lw	a4,176(a5)
ffffffffc0200ca6:	8b05                	andi	a4,a4,1
ffffffffc0200ca8:	e329                	bnez	a4,ffffffffc0200cea <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200caa:	6f9c                	ld	a5,24(a5)
ffffffffc0200cac:	eb85                	bnez	a5,ffffffffc0200cdc <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200cae:	60e2                	ld	ra,24(sp)
ffffffffc0200cb0:	6442                	ld	s0,16(sp)
ffffffffc0200cb2:	64a2                	ld	s1,8(sp)
ffffffffc0200cb4:	6902                	ld	s2,0(sp)
ffffffffc0200cb6:	6105                	addi	sp,sp,32
ffffffffc0200cb8:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cba:	d09ff0ef          	jal	ra,ffffffffc02009c2 <interrupt_handler>
ffffffffc0200cbe:	bff1                	j	ffffffffc0200c9a <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cc0:	0006c863          	bltz	a3,ffffffffc0200cd0 <trap+0x66>
}
ffffffffc0200cc4:	6442                	ld	s0,16(sp)
ffffffffc0200cc6:	60e2                	ld	ra,24(sp)
ffffffffc0200cc8:	64a2                	ld	s1,8(sp)
ffffffffc0200cca:	6902                	ld	s2,0(sp)
ffffffffc0200ccc:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cce:	bb75                	j	ffffffffc0200a8a <exception_handler>
}
ffffffffc0200cd0:	6442                	ld	s0,16(sp)
ffffffffc0200cd2:	60e2                	ld	ra,24(sp)
ffffffffc0200cd4:	64a2                	ld	s1,8(sp)
ffffffffc0200cd6:	6902                	ld	s2,0(sp)
ffffffffc0200cd8:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cda:	b1e5                	j	ffffffffc02009c2 <interrupt_handler>
}
ffffffffc0200cdc:	6442                	ld	s0,16(sp)
ffffffffc0200cde:	60e2                	ld	ra,24(sp)
ffffffffc0200ce0:	64a2                	ld	s1,8(sp)
ffffffffc0200ce2:	6902                	ld	s2,0(sp)
ffffffffc0200ce4:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200ce6:	2d40506f          	j	ffffffffc0205fba <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cea:	555d                	li	a0,-9
ffffffffc0200cec:	6d0040ef          	jal	ra,ffffffffc02053bc <do_exit>
ffffffffc0200cf0:	601c                	ld	a5,0(s0)
ffffffffc0200cf2:	bf65                	j	ffffffffc0200caa <trap+0x40>

ffffffffc0200cf4 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cf4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cf8:	00011463          	bnez	sp,ffffffffc0200d00 <__alltraps+0xc>
ffffffffc0200cfc:	14002173          	csrr	sp,sscratch
ffffffffc0200d00:	712d                	addi	sp,sp,-288
ffffffffc0200d02:	e002                	sd	zero,0(sp)
ffffffffc0200d04:	e406                	sd	ra,8(sp)
ffffffffc0200d06:	ec0e                	sd	gp,24(sp)
ffffffffc0200d08:	f012                	sd	tp,32(sp)
ffffffffc0200d0a:	f416                	sd	t0,40(sp)
ffffffffc0200d0c:	f81a                	sd	t1,48(sp)
ffffffffc0200d0e:	fc1e                	sd	t2,56(sp)
ffffffffc0200d10:	e0a2                	sd	s0,64(sp)
ffffffffc0200d12:	e4a6                	sd	s1,72(sp)
ffffffffc0200d14:	e8aa                	sd	a0,80(sp)
ffffffffc0200d16:	ecae                	sd	a1,88(sp)
ffffffffc0200d18:	f0b2                	sd	a2,96(sp)
ffffffffc0200d1a:	f4b6                	sd	a3,104(sp)
ffffffffc0200d1c:	f8ba                	sd	a4,112(sp)
ffffffffc0200d1e:	fcbe                	sd	a5,120(sp)
ffffffffc0200d20:	e142                	sd	a6,128(sp)
ffffffffc0200d22:	e546                	sd	a7,136(sp)
ffffffffc0200d24:	e94a                	sd	s2,144(sp)
ffffffffc0200d26:	ed4e                	sd	s3,152(sp)
ffffffffc0200d28:	f152                	sd	s4,160(sp)
ffffffffc0200d2a:	f556                	sd	s5,168(sp)
ffffffffc0200d2c:	f95a                	sd	s6,176(sp)
ffffffffc0200d2e:	fd5e                	sd	s7,184(sp)
ffffffffc0200d30:	e1e2                	sd	s8,192(sp)
ffffffffc0200d32:	e5e6                	sd	s9,200(sp)
ffffffffc0200d34:	e9ea                	sd	s10,208(sp)
ffffffffc0200d36:	edee                	sd	s11,216(sp)
ffffffffc0200d38:	f1f2                	sd	t3,224(sp)
ffffffffc0200d3a:	f5f6                	sd	t4,232(sp)
ffffffffc0200d3c:	f9fa                	sd	t5,240(sp)
ffffffffc0200d3e:	fdfe                	sd	t6,248(sp)
ffffffffc0200d40:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d44:	100024f3          	csrr	s1,sstatus
ffffffffc0200d48:	14102973          	csrr	s2,sepc
ffffffffc0200d4c:	143029f3          	csrr	s3,stval
ffffffffc0200d50:	14202a73          	csrr	s4,scause
ffffffffc0200d54:	e822                	sd	s0,16(sp)
ffffffffc0200d56:	e226                	sd	s1,256(sp)
ffffffffc0200d58:	e64a                	sd	s2,264(sp)
ffffffffc0200d5a:	ea4e                	sd	s3,272(sp)
ffffffffc0200d5c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d5e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d60:	f0bff0ef          	jal	ra,ffffffffc0200c6a <trap>

ffffffffc0200d64 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d64:	6492                	ld	s1,256(sp)
ffffffffc0200d66:	6932                	ld	s2,264(sp)
ffffffffc0200d68:	1004f413          	andi	s0,s1,256
ffffffffc0200d6c:	e401                	bnez	s0,ffffffffc0200d74 <__trapret+0x10>
ffffffffc0200d6e:	1200                	addi	s0,sp,288
ffffffffc0200d70:	14041073          	csrw	sscratch,s0
ffffffffc0200d74:	10049073          	csrw	sstatus,s1
ffffffffc0200d78:	14191073          	csrw	sepc,s2
ffffffffc0200d7c:	60a2                	ld	ra,8(sp)
ffffffffc0200d7e:	61e2                	ld	gp,24(sp)
ffffffffc0200d80:	7202                	ld	tp,32(sp)
ffffffffc0200d82:	72a2                	ld	t0,40(sp)
ffffffffc0200d84:	7342                	ld	t1,48(sp)
ffffffffc0200d86:	73e2                	ld	t2,56(sp)
ffffffffc0200d88:	6406                	ld	s0,64(sp)
ffffffffc0200d8a:	64a6                	ld	s1,72(sp)
ffffffffc0200d8c:	6546                	ld	a0,80(sp)
ffffffffc0200d8e:	65e6                	ld	a1,88(sp)
ffffffffc0200d90:	7606                	ld	a2,96(sp)
ffffffffc0200d92:	76a6                	ld	a3,104(sp)
ffffffffc0200d94:	7746                	ld	a4,112(sp)
ffffffffc0200d96:	77e6                	ld	a5,120(sp)
ffffffffc0200d98:	680a                	ld	a6,128(sp)
ffffffffc0200d9a:	68aa                	ld	a7,136(sp)
ffffffffc0200d9c:	694a                	ld	s2,144(sp)
ffffffffc0200d9e:	69ea                	ld	s3,152(sp)
ffffffffc0200da0:	7a0a                	ld	s4,160(sp)
ffffffffc0200da2:	7aaa                	ld	s5,168(sp)
ffffffffc0200da4:	7b4a                	ld	s6,176(sp)
ffffffffc0200da6:	7bea                	ld	s7,184(sp)
ffffffffc0200da8:	6c0e                	ld	s8,192(sp)
ffffffffc0200daa:	6cae                	ld	s9,200(sp)
ffffffffc0200dac:	6d4e                	ld	s10,208(sp)
ffffffffc0200dae:	6dee                	ld	s11,216(sp)
ffffffffc0200db0:	7e0e                	ld	t3,224(sp)
ffffffffc0200db2:	7eae                	ld	t4,232(sp)
ffffffffc0200db4:	7f4e                	ld	t5,240(sp)
ffffffffc0200db6:	7fee                	ld	t6,248(sp)
ffffffffc0200db8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200dba:	10200073          	sret

ffffffffc0200dbe <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200dbe:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dc0:	b755                	j	ffffffffc0200d64 <__trapret>

ffffffffc0200dc2 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dc2:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200dc6:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200dca:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dce:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dd2:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dd6:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dda:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dde:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200de2:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200de6:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200de8:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dea:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dec:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dee:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200df0:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200df2:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200df4:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200df6:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200df8:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dfa:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dfc:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dfe:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200e00:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200e02:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200e04:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200e06:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200e08:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200e0a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200e0c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200e0e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200e10:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200e12:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e14:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e16:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e18:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e1a:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e1c:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e1e:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e20:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e22:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e24:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e26:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e28:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e2a:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e2c:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e2e:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e30:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e32:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e34:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e36:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e38:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e3a:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e3c:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e3e:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e40:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e42:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e44:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e46:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e48:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e4a:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e4c:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e4e:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e50:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e52:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e54:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e56:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e58:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e5a:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e5c:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e5e:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e60:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e62:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e64:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e66:	812e                	mv	sp,a1
ffffffffc0200e68:	bdf5                	j	ffffffffc0200d64 <__trapret>

ffffffffc0200e6a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e6a:	000ac797          	auipc	a5,0xac
ffffffffc0200e6e:	a0e78793          	addi	a5,a5,-1522 # ffffffffc02ac878 <free_area>
ffffffffc0200e72:	e79c                	sd	a5,8(a5)
ffffffffc0200e74:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e76:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e7a:	8082                	ret

ffffffffc0200e7c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e7c:	000ac517          	auipc	a0,0xac
ffffffffc0200e80:	a0c56503          	lwu	a0,-1524(a0) # ffffffffc02ac888 <free_area+0x10>
ffffffffc0200e84:	8082                	ret

ffffffffc0200e86 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e86:	715d                	addi	sp,sp,-80
ffffffffc0200e88:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e8a:	000ac917          	auipc	s2,0xac
ffffffffc0200e8e:	9ee90913          	addi	s2,s2,-1554 # ffffffffc02ac878 <free_area>
ffffffffc0200e92:	00893783          	ld	a5,8(s2)
ffffffffc0200e96:	e486                	sd	ra,72(sp)
ffffffffc0200e98:	e0a2                	sd	s0,64(sp)
ffffffffc0200e9a:	fc26                	sd	s1,56(sp)
ffffffffc0200e9c:	f44e                	sd	s3,40(sp)
ffffffffc0200e9e:	f052                	sd	s4,32(sp)
ffffffffc0200ea0:	ec56                	sd	s5,24(sp)
ffffffffc0200ea2:	e85a                	sd	s6,16(sp)
ffffffffc0200ea4:	e45e                	sd	s7,8(sp)
ffffffffc0200ea6:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea8:	31278463          	beq	a5,s2,ffffffffc02011b0 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200eac:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200eb0:	8305                	srli	a4,a4,0x1
ffffffffc0200eb2:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200eb4:	30070263          	beqz	a4,ffffffffc02011b8 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200eb8:	4401                	li	s0,0
ffffffffc0200eba:	4481                	li	s1,0
ffffffffc0200ebc:	a031                	j	ffffffffc0200ec8 <default_check+0x42>
ffffffffc0200ebe:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200ec2:	8b09                	andi	a4,a4,2
ffffffffc0200ec4:	2e070a63          	beqz	a4,ffffffffc02011b8 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200ec8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ecc:	679c                	ld	a5,8(a5)
ffffffffc0200ece:	2485                	addiw	s1,s1,1
ffffffffc0200ed0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ed2:	ff2796e3          	bne	a5,s2,ffffffffc0200ebe <default_check+0x38>
ffffffffc0200ed6:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ed8:	046010ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc0200edc:	73351e63          	bne	a0,s3,ffffffffc0201618 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ee0:	4505                	li	a0,1
ffffffffc0200ee2:	76f000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200ee6:	8a2a                	mv	s4,a0
ffffffffc0200ee8:	46050863          	beqz	a0,ffffffffc0201358 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200eec:	4505                	li	a0,1
ffffffffc0200eee:	763000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200ef2:	89aa                	mv	s3,a0
ffffffffc0200ef4:	74050263          	beqz	a0,ffffffffc0201638 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ef8:	4505                	li	a0,1
ffffffffc0200efa:	757000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200efe:	8aaa                	mv	s5,a0
ffffffffc0200f00:	4c050c63          	beqz	a0,ffffffffc02013d8 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f04:	2d3a0a63          	beq	s4,s3,ffffffffc02011d8 <default_check+0x352>
ffffffffc0200f08:	2caa0863          	beq	s4,a0,ffffffffc02011d8 <default_check+0x352>
ffffffffc0200f0c:	2ca98663          	beq	s3,a0,ffffffffc02011d8 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f10:	000a2783          	lw	a5,0(s4)
ffffffffc0200f14:	2e079263          	bnez	a5,ffffffffc02011f8 <default_check+0x372>
ffffffffc0200f18:	0009a783          	lw	a5,0(s3)
ffffffffc0200f1c:	2c079e63          	bnez	a5,ffffffffc02011f8 <default_check+0x372>
ffffffffc0200f20:	411c                	lw	a5,0(a0)
ffffffffc0200f22:	2c079b63          	bnez	a5,ffffffffc02011f8 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f26:	000ac797          	auipc	a5,0xac
ffffffffc0200f2a:	98278793          	addi	a5,a5,-1662 # ffffffffc02ac8a8 <pages>
ffffffffc0200f2e:	639c                	ld	a5,0(a5)
ffffffffc0200f30:	00008717          	auipc	a4,0x8
ffffffffc0200f34:	d9870713          	addi	a4,a4,-616 # ffffffffc0208cc8 <nbase>
ffffffffc0200f38:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f3a:	000ac717          	auipc	a4,0xac
ffffffffc0200f3e:	8fe70713          	addi	a4,a4,-1794 # ffffffffc02ac838 <npage>
ffffffffc0200f42:	6314                	ld	a3,0(a4)
ffffffffc0200f44:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f48:	8719                	srai	a4,a4,0x6
ffffffffc0200f4a:	9732                	add	a4,a4,a2
ffffffffc0200f4c:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f4e:	0732                	slli	a4,a4,0xc
ffffffffc0200f50:	2cd77463          	bgeu	a4,a3,ffffffffc0201218 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f54:	40f98733          	sub	a4,s3,a5
ffffffffc0200f58:	8719                	srai	a4,a4,0x6
ffffffffc0200f5a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f5c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f5e:	4ed77d63          	bgeu	a4,a3,ffffffffc0201458 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f62:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f66:	8799                	srai	a5,a5,0x6
ffffffffc0200f68:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f6a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f6c:	34d7f663          	bgeu	a5,a3,ffffffffc02012b8 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f70:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f72:	00093c03          	ld	s8,0(s2)
ffffffffc0200f76:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f7a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f7e:	000ac797          	auipc	a5,0xac
ffffffffc0200f82:	9127b123          	sd	s2,-1790(a5) # ffffffffc02ac880 <free_area+0x8>
ffffffffc0200f86:	000ac797          	auipc	a5,0xac
ffffffffc0200f8a:	8f27b923          	sd	s2,-1806(a5) # ffffffffc02ac878 <free_area>
    nr_free = 0;
ffffffffc0200f8e:	000ac797          	auipc	a5,0xac
ffffffffc0200f92:	8e07ad23          	sw	zero,-1798(a5) # ffffffffc02ac888 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f96:	6bb000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200f9a:	2e051f63          	bnez	a0,ffffffffc0201298 <default_check+0x412>
    free_page(p0);
ffffffffc0200f9e:	4585                	li	a1,1
ffffffffc0200fa0:	8552                	mv	a0,s4
ffffffffc0200fa2:	737000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_page(p1);
ffffffffc0200fa6:	4585                	li	a1,1
ffffffffc0200fa8:	854e                	mv	a0,s3
ffffffffc0200faa:	72f000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_page(p2);
ffffffffc0200fae:	4585                	li	a1,1
ffffffffc0200fb0:	8556                	mv	a0,s5
ffffffffc0200fb2:	727000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    assert(nr_free == 3);
ffffffffc0200fb6:	01092703          	lw	a4,16(s2)
ffffffffc0200fba:	478d                	li	a5,3
ffffffffc0200fbc:	2af71e63          	bne	a4,a5,ffffffffc0201278 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fc0:	4505                	li	a0,1
ffffffffc0200fc2:	68f000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200fc6:	89aa                	mv	s3,a0
ffffffffc0200fc8:	28050863          	beqz	a0,ffffffffc0201258 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fcc:	4505                	li	a0,1
ffffffffc0200fce:	683000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200fd2:	8aaa                	mv	s5,a0
ffffffffc0200fd4:	3e050263          	beqz	a0,ffffffffc02013b8 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd8:	4505                	li	a0,1
ffffffffc0200fda:	677000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200fde:	8a2a                	mv	s4,a0
ffffffffc0200fe0:	3a050c63          	beqz	a0,ffffffffc0201398 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
ffffffffc0200fe6:	66b000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0200fea:	38051763          	bnez	a0,ffffffffc0201378 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fee:	4585                	li	a1,1
ffffffffc0200ff0:	854e                	mv	a0,s3
ffffffffc0200ff2:	6e7000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ff6:	00893783          	ld	a5,8(s2)
ffffffffc0200ffa:	23278f63          	beq	a5,s2,ffffffffc0201238 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200ffe:	4505                	li	a0,1
ffffffffc0201000:	651000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0201004:	32a99a63          	bne	s3,a0,ffffffffc0201338 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0201008:	4505                	li	a0,1
ffffffffc020100a:	647000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020100e:	30051563          	bnez	a0,ffffffffc0201318 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0201012:	01092783          	lw	a5,16(s2)
ffffffffc0201016:	2e079163          	bnez	a5,ffffffffc02012f8 <default_check+0x472>
    free_page(p);
ffffffffc020101a:	854e                	mv	a0,s3
ffffffffc020101c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020101e:	000ac797          	auipc	a5,0xac
ffffffffc0201022:	8587bd23          	sd	s8,-1958(a5) # ffffffffc02ac878 <free_area>
ffffffffc0201026:	000ac797          	auipc	a5,0xac
ffffffffc020102a:	8577bd23          	sd	s7,-1958(a5) # ffffffffc02ac880 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020102e:	000ac797          	auipc	a5,0xac
ffffffffc0201032:	8567ad23          	sw	s6,-1958(a5) # ffffffffc02ac888 <free_area+0x10>
    free_page(p);
ffffffffc0201036:	6a3000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_page(p1);
ffffffffc020103a:	4585                	li	a1,1
ffffffffc020103c:	8556                	mv	a0,s5
ffffffffc020103e:	69b000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_page(p2);
ffffffffc0201042:	4585                	li	a1,1
ffffffffc0201044:	8552                	mv	a0,s4
ffffffffc0201046:	693000ef          	jal	ra,ffffffffc0201ed8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020104a:	4515                	li	a0,5
ffffffffc020104c:	605000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0201050:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201052:	28050363          	beqz	a0,ffffffffc02012d8 <default_check+0x452>
ffffffffc0201056:	651c                	ld	a5,8(a0)
ffffffffc0201058:	8385                	srli	a5,a5,0x1
ffffffffc020105a:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc020105c:	54079e63          	bnez	a5,ffffffffc02015b8 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201060:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201062:	00093b03          	ld	s6,0(s2)
ffffffffc0201066:	00893a83          	ld	s5,8(s2)
ffffffffc020106a:	000ac797          	auipc	a5,0xac
ffffffffc020106e:	8127b723          	sd	s2,-2034(a5) # ffffffffc02ac878 <free_area>
ffffffffc0201072:	000ac797          	auipc	a5,0xac
ffffffffc0201076:	8127b723          	sd	s2,-2034(a5) # ffffffffc02ac880 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020107a:	5d7000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020107e:	50051d63          	bnez	a0,ffffffffc0201598 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201082:	08098a13          	addi	s4,s3,128
ffffffffc0201086:	8552                	mv	a0,s4
ffffffffc0201088:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020108a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020108e:	000ab797          	auipc	a5,0xab
ffffffffc0201092:	7e07ad23          	sw	zero,2042(a5) # ffffffffc02ac888 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201096:	643000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020109a:	4511                	li	a0,4
ffffffffc020109c:	5b5000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc02010a0:	4c051c63          	bnez	a0,ffffffffc0201578 <default_check+0x6f2>
ffffffffc02010a4:	0889b783          	ld	a5,136(s3)
ffffffffc02010a8:	8385                	srli	a5,a5,0x1
ffffffffc02010aa:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02010ac:	4a078663          	beqz	a5,ffffffffc0201558 <default_check+0x6d2>
ffffffffc02010b0:	0909a703          	lw	a4,144(s3)
ffffffffc02010b4:	478d                	li	a5,3
ffffffffc02010b6:	4af71163          	bne	a4,a5,ffffffffc0201558 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010ba:	450d                	li	a0,3
ffffffffc02010bc:	595000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc02010c0:	8c2a                	mv	s8,a0
ffffffffc02010c2:	46050b63          	beqz	a0,ffffffffc0201538 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010c6:	4505                	li	a0,1
ffffffffc02010c8:	589000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc02010cc:	44051663          	bnez	a0,ffffffffc0201518 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010d0:	438a1463          	bne	s4,s8,ffffffffc02014f8 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010d4:	4585                	li	a1,1
ffffffffc02010d6:	854e                	mv	a0,s3
ffffffffc02010d8:	601000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_pages(p1, 3);
ffffffffc02010dc:	458d                	li	a1,3
ffffffffc02010de:	8552                	mv	a0,s4
ffffffffc02010e0:	5f9000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
ffffffffc02010e4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010e8:	04098c13          	addi	s8,s3,64
ffffffffc02010ec:	8385                	srli	a5,a5,0x1
ffffffffc02010ee:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010f0:	3e078463          	beqz	a5,ffffffffc02014d8 <default_check+0x652>
ffffffffc02010f4:	0109a703          	lw	a4,16(s3)
ffffffffc02010f8:	4785                	li	a5,1
ffffffffc02010fa:	3cf71f63          	bne	a4,a5,ffffffffc02014d8 <default_check+0x652>
ffffffffc02010fe:	008a3783          	ld	a5,8(s4)
ffffffffc0201102:	8385                	srli	a5,a5,0x1
ffffffffc0201104:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201106:	3a078963          	beqz	a5,ffffffffc02014b8 <default_check+0x632>
ffffffffc020110a:	010a2703          	lw	a4,16(s4)
ffffffffc020110e:	478d                	li	a5,3
ffffffffc0201110:	3af71463          	bne	a4,a5,ffffffffc02014b8 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	53b000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020111a:	36a99f63          	bne	s3,a0,ffffffffc0201498 <default_check+0x612>
    free_page(p0);
ffffffffc020111e:	4585                	li	a1,1
ffffffffc0201120:	5b9000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201124:	4509                	li	a0,2
ffffffffc0201126:	52b000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020112a:	34aa1763          	bne	s4,a0,ffffffffc0201478 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020112e:	4589                	li	a1,2
ffffffffc0201130:	5a9000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    free_page(p2);
ffffffffc0201134:	4585                	li	a1,1
ffffffffc0201136:	8562                	mv	a0,s8
ffffffffc0201138:	5a1000ef          	jal	ra,ffffffffc0201ed8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020113c:	4515                	li	a0,5
ffffffffc020113e:	513000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0201142:	89aa                	mv	s3,a0
ffffffffc0201144:	48050a63          	beqz	a0,ffffffffc02015d8 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201148:	4505                	li	a0,1
ffffffffc020114a:	507000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020114e:	2e051563          	bnez	a0,ffffffffc0201438 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201152:	01092783          	lw	a5,16(s2)
ffffffffc0201156:	2c079163          	bnez	a5,ffffffffc0201418 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020115a:	4595                	li	a1,5
ffffffffc020115c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020115e:	000ab797          	auipc	a5,0xab
ffffffffc0201162:	7377a523          	sw	s7,1834(a5) # ffffffffc02ac888 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201166:	000ab797          	auipc	a5,0xab
ffffffffc020116a:	7167b923          	sd	s6,1810(a5) # ffffffffc02ac878 <free_area>
ffffffffc020116e:	000ab797          	auipc	a5,0xab
ffffffffc0201172:	7157b923          	sd	s5,1810(a5) # ffffffffc02ac880 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201176:	563000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return listelm->next;
ffffffffc020117a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020117e:	01278963          	beq	a5,s2,ffffffffc0201190 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201182:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201186:	679c                	ld	a5,8(a5)
ffffffffc0201188:	34fd                	addiw	s1,s1,-1
ffffffffc020118a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020118c:	ff279be3          	bne	a5,s2,ffffffffc0201182 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201190:	26049463          	bnez	s1,ffffffffc02013f8 <default_check+0x572>
    assert(total == 0);
ffffffffc0201194:	46041263          	bnez	s0,ffffffffc02015f8 <default_check+0x772>
}
ffffffffc0201198:	60a6                	ld	ra,72(sp)
ffffffffc020119a:	6406                	ld	s0,64(sp)
ffffffffc020119c:	74e2                	ld	s1,56(sp)
ffffffffc020119e:	7942                	ld	s2,48(sp)
ffffffffc02011a0:	79a2                	ld	s3,40(sp)
ffffffffc02011a2:	7a02                	ld	s4,32(sp)
ffffffffc02011a4:	6ae2                	ld	s5,24(sp)
ffffffffc02011a6:	6b42                	ld	s6,16(sp)
ffffffffc02011a8:	6ba2                	ld	s7,8(sp)
ffffffffc02011aa:	6c02                	ld	s8,0(sp)
ffffffffc02011ac:	6161                	addi	sp,sp,80
ffffffffc02011ae:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011b0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02011b2:	4401                	li	s0,0
ffffffffc02011b4:	4481                	li	s1,0
ffffffffc02011b6:	b30d                	j	ffffffffc0200ed8 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011b8:	00006697          	auipc	a3,0x6
ffffffffc02011bc:	e0068693          	addi	a3,a3,-512 # ffffffffc0206fb8 <commands+0x888>
ffffffffc02011c0:	00006617          	auipc	a2,0x6
ffffffffc02011c4:	a4060613          	addi	a2,a2,-1472 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02011c8:	0f000593          	li	a1,240
ffffffffc02011cc:	00006517          	auipc	a0,0x6
ffffffffc02011d0:	dfc50513          	addi	a0,a0,-516 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02011d4:	aacff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011d8:	00006697          	auipc	a3,0x6
ffffffffc02011dc:	e8868693          	addi	a3,a3,-376 # ffffffffc0207060 <commands+0x930>
ffffffffc02011e0:	00006617          	auipc	a2,0x6
ffffffffc02011e4:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02011e8:	0bd00593          	li	a1,189
ffffffffc02011ec:	00006517          	auipc	a0,0x6
ffffffffc02011f0:	ddc50513          	addi	a0,a0,-548 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02011f4:	a8cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011f8:	00006697          	auipc	a3,0x6
ffffffffc02011fc:	e9068693          	addi	a3,a3,-368 # ffffffffc0207088 <commands+0x958>
ffffffffc0201200:	00006617          	auipc	a2,0x6
ffffffffc0201204:	a0060613          	addi	a2,a2,-1536 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201208:	0be00593          	li	a1,190
ffffffffc020120c:	00006517          	auipc	a0,0x6
ffffffffc0201210:	dbc50513          	addi	a0,a0,-580 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201214:	a6cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201218:	00006697          	auipc	a3,0x6
ffffffffc020121c:	eb068693          	addi	a3,a3,-336 # ffffffffc02070c8 <commands+0x998>
ffffffffc0201220:	00006617          	auipc	a2,0x6
ffffffffc0201224:	9e060613          	addi	a2,a2,-1568 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201228:	0c000593          	li	a1,192
ffffffffc020122c:	00006517          	auipc	a0,0x6
ffffffffc0201230:	d9c50513          	addi	a0,a0,-612 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201234:	a4cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201238:	00006697          	auipc	a3,0x6
ffffffffc020123c:	f1868693          	addi	a3,a3,-232 # ffffffffc0207150 <commands+0xa20>
ffffffffc0201240:	00006617          	auipc	a2,0x6
ffffffffc0201244:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201248:	0d900593          	li	a1,217
ffffffffc020124c:	00006517          	auipc	a0,0x6
ffffffffc0201250:	d7c50513          	addi	a0,a0,-644 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201254:	a2cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201258:	00006697          	auipc	a3,0x6
ffffffffc020125c:	da868693          	addi	a3,a3,-600 # ffffffffc0207000 <commands+0x8d0>
ffffffffc0201260:	00006617          	auipc	a2,0x6
ffffffffc0201264:	9a060613          	addi	a2,a2,-1632 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201268:	0d200593          	li	a1,210
ffffffffc020126c:	00006517          	auipc	a0,0x6
ffffffffc0201270:	d5c50513          	addi	a0,a0,-676 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201274:	a0cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 3);
ffffffffc0201278:	00006697          	auipc	a3,0x6
ffffffffc020127c:	ec868693          	addi	a3,a3,-312 # ffffffffc0207140 <commands+0xa10>
ffffffffc0201280:	00006617          	auipc	a2,0x6
ffffffffc0201284:	98060613          	addi	a2,a2,-1664 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201288:	0d000593          	li	a1,208
ffffffffc020128c:	00006517          	auipc	a0,0x6
ffffffffc0201290:	d3c50513          	addi	a0,a0,-708 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201294:	9ecff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201298:	00006697          	auipc	a3,0x6
ffffffffc020129c:	e9068693          	addi	a3,a3,-368 # ffffffffc0207128 <commands+0x9f8>
ffffffffc02012a0:	00006617          	auipc	a2,0x6
ffffffffc02012a4:	96060613          	addi	a2,a2,-1696 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02012a8:	0cb00593          	li	a1,203
ffffffffc02012ac:	00006517          	auipc	a0,0x6
ffffffffc02012b0:	d1c50513          	addi	a0,a0,-740 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02012b4:	9ccff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012b8:	00006697          	auipc	a3,0x6
ffffffffc02012bc:	e5068693          	addi	a3,a3,-432 # ffffffffc0207108 <commands+0x9d8>
ffffffffc02012c0:	00006617          	auipc	a2,0x6
ffffffffc02012c4:	94060613          	addi	a2,a2,-1728 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02012c8:	0c200593          	li	a1,194
ffffffffc02012cc:	00006517          	auipc	a0,0x6
ffffffffc02012d0:	cfc50513          	addi	a0,a0,-772 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02012d4:	9acff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != NULL);
ffffffffc02012d8:	00006697          	auipc	a3,0x6
ffffffffc02012dc:	ec068693          	addi	a3,a3,-320 # ffffffffc0207198 <commands+0xa68>
ffffffffc02012e0:	00006617          	auipc	a2,0x6
ffffffffc02012e4:	92060613          	addi	a2,a2,-1760 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02012e8:	0f800593          	li	a1,248
ffffffffc02012ec:	00006517          	auipc	a0,0x6
ffffffffc02012f0:	cdc50513          	addi	a0,a0,-804 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02012f4:	98cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02012f8:	00006697          	auipc	a3,0x6
ffffffffc02012fc:	e9068693          	addi	a3,a3,-368 # ffffffffc0207188 <commands+0xa58>
ffffffffc0201300:	00006617          	auipc	a2,0x6
ffffffffc0201304:	90060613          	addi	a2,a2,-1792 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201308:	0df00593          	li	a1,223
ffffffffc020130c:	00006517          	auipc	a0,0x6
ffffffffc0201310:	cbc50513          	addi	a0,a0,-836 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201314:	96cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201318:	00006697          	auipc	a3,0x6
ffffffffc020131c:	e1068693          	addi	a3,a3,-496 # ffffffffc0207128 <commands+0x9f8>
ffffffffc0201320:	00006617          	auipc	a2,0x6
ffffffffc0201324:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201328:	0dd00593          	li	a1,221
ffffffffc020132c:	00006517          	auipc	a0,0x6
ffffffffc0201330:	c9c50513          	addi	a0,a0,-868 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201334:	94cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201338:	00006697          	auipc	a3,0x6
ffffffffc020133c:	e3068693          	addi	a3,a3,-464 # ffffffffc0207168 <commands+0xa38>
ffffffffc0201340:	00006617          	auipc	a2,0x6
ffffffffc0201344:	8c060613          	addi	a2,a2,-1856 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201348:	0dc00593          	li	a1,220
ffffffffc020134c:	00006517          	auipc	a0,0x6
ffffffffc0201350:	c7c50513          	addi	a0,a0,-900 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201354:	92cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201358:	00006697          	auipc	a3,0x6
ffffffffc020135c:	ca868693          	addi	a3,a3,-856 # ffffffffc0207000 <commands+0x8d0>
ffffffffc0201360:	00006617          	auipc	a2,0x6
ffffffffc0201364:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201368:	0b900593          	li	a1,185
ffffffffc020136c:	00006517          	auipc	a0,0x6
ffffffffc0201370:	c5c50513          	addi	a0,a0,-932 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201374:	90cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201378:	00006697          	auipc	a3,0x6
ffffffffc020137c:	db068693          	addi	a3,a3,-592 # ffffffffc0207128 <commands+0x9f8>
ffffffffc0201380:	00006617          	auipc	a2,0x6
ffffffffc0201384:	88060613          	addi	a2,a2,-1920 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201388:	0d600593          	li	a1,214
ffffffffc020138c:	00006517          	auipc	a0,0x6
ffffffffc0201390:	c3c50513          	addi	a0,a0,-964 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201394:	8ecff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201398:	00006697          	auipc	a3,0x6
ffffffffc020139c:	ca868693          	addi	a3,a3,-856 # ffffffffc0207040 <commands+0x910>
ffffffffc02013a0:	00006617          	auipc	a2,0x6
ffffffffc02013a4:	86060613          	addi	a2,a2,-1952 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02013a8:	0d400593          	li	a1,212
ffffffffc02013ac:	00006517          	auipc	a0,0x6
ffffffffc02013b0:	c1c50513          	addi	a0,a0,-996 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02013b4:	8ccff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013b8:	00006697          	auipc	a3,0x6
ffffffffc02013bc:	c6868693          	addi	a3,a3,-920 # ffffffffc0207020 <commands+0x8f0>
ffffffffc02013c0:	00006617          	auipc	a2,0x6
ffffffffc02013c4:	84060613          	addi	a2,a2,-1984 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02013c8:	0d300593          	li	a1,211
ffffffffc02013cc:	00006517          	auipc	a0,0x6
ffffffffc02013d0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02013d4:	8acff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013d8:	00006697          	auipc	a3,0x6
ffffffffc02013dc:	c6868693          	addi	a3,a3,-920 # ffffffffc0207040 <commands+0x910>
ffffffffc02013e0:	00006617          	auipc	a2,0x6
ffffffffc02013e4:	82060613          	addi	a2,a2,-2016 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02013e8:	0bb00593          	li	a1,187
ffffffffc02013ec:	00006517          	auipc	a0,0x6
ffffffffc02013f0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02013f4:	88cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(count == 0);
ffffffffc02013f8:	00006697          	auipc	a3,0x6
ffffffffc02013fc:	ef068693          	addi	a3,a3,-272 # ffffffffc02072e8 <commands+0xbb8>
ffffffffc0201400:	00006617          	auipc	a2,0x6
ffffffffc0201404:	80060613          	addi	a2,a2,-2048 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201408:	12500593          	li	a1,293
ffffffffc020140c:	00006517          	auipc	a0,0x6
ffffffffc0201410:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201414:	86cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc0201418:	00006697          	auipc	a3,0x6
ffffffffc020141c:	d7068693          	addi	a3,a3,-656 # ffffffffc0207188 <commands+0xa58>
ffffffffc0201420:	00005617          	auipc	a2,0x5
ffffffffc0201424:	7e060613          	addi	a2,a2,2016 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201428:	11a00593          	li	a1,282
ffffffffc020142c:	00006517          	auipc	a0,0x6
ffffffffc0201430:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201434:	84cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201438:	00006697          	auipc	a3,0x6
ffffffffc020143c:	cf068693          	addi	a3,a3,-784 # ffffffffc0207128 <commands+0x9f8>
ffffffffc0201440:	00005617          	auipc	a2,0x5
ffffffffc0201444:	7c060613          	addi	a2,a2,1984 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201448:	11800593          	li	a1,280
ffffffffc020144c:	00006517          	auipc	a0,0x6
ffffffffc0201450:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201454:	82cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201458:	00006697          	auipc	a3,0x6
ffffffffc020145c:	c9068693          	addi	a3,a3,-880 # ffffffffc02070e8 <commands+0x9b8>
ffffffffc0201460:	00005617          	auipc	a2,0x5
ffffffffc0201464:	7a060613          	addi	a2,a2,1952 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201468:	0c100593          	li	a1,193
ffffffffc020146c:	00006517          	auipc	a0,0x6
ffffffffc0201470:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201474:	80cff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201478:	00006697          	auipc	a3,0x6
ffffffffc020147c:	e3068693          	addi	a3,a3,-464 # ffffffffc02072a8 <commands+0xb78>
ffffffffc0201480:	00005617          	auipc	a2,0x5
ffffffffc0201484:	78060613          	addi	a2,a2,1920 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201488:	11200593          	li	a1,274
ffffffffc020148c:	00006517          	auipc	a0,0x6
ffffffffc0201490:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201494:	fedfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201498:	00006697          	auipc	a3,0x6
ffffffffc020149c:	df068693          	addi	a3,a3,-528 # ffffffffc0207288 <commands+0xb58>
ffffffffc02014a0:	00005617          	auipc	a2,0x5
ffffffffc02014a4:	76060613          	addi	a2,a2,1888 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02014a8:	11000593          	li	a1,272
ffffffffc02014ac:	00006517          	auipc	a0,0x6
ffffffffc02014b0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02014b4:	fcdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014b8:	00006697          	auipc	a3,0x6
ffffffffc02014bc:	da868693          	addi	a3,a3,-600 # ffffffffc0207260 <commands+0xb30>
ffffffffc02014c0:	00005617          	auipc	a2,0x5
ffffffffc02014c4:	74060613          	addi	a2,a2,1856 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02014c8:	10e00593          	li	a1,270
ffffffffc02014cc:	00006517          	auipc	a0,0x6
ffffffffc02014d0:	afc50513          	addi	a0,a0,-1284 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02014d4:	fadfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014d8:	00006697          	auipc	a3,0x6
ffffffffc02014dc:	d6068693          	addi	a3,a3,-672 # ffffffffc0207238 <commands+0xb08>
ffffffffc02014e0:	00005617          	auipc	a2,0x5
ffffffffc02014e4:	72060613          	addi	a2,a2,1824 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02014e8:	10d00593          	li	a1,269
ffffffffc02014ec:	00006517          	auipc	a0,0x6
ffffffffc02014f0:	adc50513          	addi	a0,a0,-1316 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02014f4:	f8dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014f8:	00006697          	auipc	a3,0x6
ffffffffc02014fc:	d3068693          	addi	a3,a3,-720 # ffffffffc0207228 <commands+0xaf8>
ffffffffc0201500:	00005617          	auipc	a2,0x5
ffffffffc0201504:	70060613          	addi	a2,a2,1792 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201508:	10800593          	li	a1,264
ffffffffc020150c:	00006517          	auipc	a0,0x6
ffffffffc0201510:	abc50513          	addi	a0,a0,-1348 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201514:	f6dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201518:	00006697          	auipc	a3,0x6
ffffffffc020151c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0207128 <commands+0x9f8>
ffffffffc0201520:	00005617          	auipc	a2,0x5
ffffffffc0201524:	6e060613          	addi	a2,a2,1760 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201528:	10700593          	li	a1,263
ffffffffc020152c:	00006517          	auipc	a0,0x6
ffffffffc0201530:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201534:	f4dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201538:	00006697          	auipc	a3,0x6
ffffffffc020153c:	cd068693          	addi	a3,a3,-816 # ffffffffc0207208 <commands+0xad8>
ffffffffc0201540:	00005617          	auipc	a2,0x5
ffffffffc0201544:	6c060613          	addi	a2,a2,1728 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201548:	10600593          	li	a1,262
ffffffffc020154c:	00006517          	auipc	a0,0x6
ffffffffc0201550:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201554:	f2dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201558:	00006697          	auipc	a3,0x6
ffffffffc020155c:	c8068693          	addi	a3,a3,-896 # ffffffffc02071d8 <commands+0xaa8>
ffffffffc0201560:	00005617          	auipc	a2,0x5
ffffffffc0201564:	6a060613          	addi	a2,a2,1696 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201568:	10500593          	li	a1,261
ffffffffc020156c:	00006517          	auipc	a0,0x6
ffffffffc0201570:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201574:	f0dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201578:	00006697          	auipc	a3,0x6
ffffffffc020157c:	c4868693          	addi	a3,a3,-952 # ffffffffc02071c0 <commands+0xa90>
ffffffffc0201580:	00005617          	auipc	a2,0x5
ffffffffc0201584:	68060613          	addi	a2,a2,1664 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201588:	10400593          	li	a1,260
ffffffffc020158c:	00006517          	auipc	a0,0x6
ffffffffc0201590:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201594:	eedfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201598:	00006697          	auipc	a3,0x6
ffffffffc020159c:	b9068693          	addi	a3,a3,-1136 # ffffffffc0207128 <commands+0x9f8>
ffffffffc02015a0:	00005617          	auipc	a2,0x5
ffffffffc02015a4:	66060613          	addi	a2,a2,1632 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02015a8:	0fe00593          	li	a1,254
ffffffffc02015ac:	00006517          	auipc	a0,0x6
ffffffffc02015b0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02015b4:	ecdfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015b8:	00006697          	auipc	a3,0x6
ffffffffc02015bc:	bf068693          	addi	a3,a3,-1040 # ffffffffc02071a8 <commands+0xa78>
ffffffffc02015c0:	00005617          	auipc	a2,0x5
ffffffffc02015c4:	64060613          	addi	a2,a2,1600 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02015c8:	0f900593          	li	a1,249
ffffffffc02015cc:	00006517          	auipc	a0,0x6
ffffffffc02015d0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02015d4:	eadfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015d8:	00006697          	auipc	a3,0x6
ffffffffc02015dc:	cf068693          	addi	a3,a3,-784 # ffffffffc02072c8 <commands+0xb98>
ffffffffc02015e0:	00005617          	auipc	a2,0x5
ffffffffc02015e4:	62060613          	addi	a2,a2,1568 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02015e8:	11700593          	li	a1,279
ffffffffc02015ec:	00006517          	auipc	a0,0x6
ffffffffc02015f0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02015f4:	e8dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == 0);
ffffffffc02015f8:	00006697          	auipc	a3,0x6
ffffffffc02015fc:	d0068693          	addi	a3,a3,-768 # ffffffffc02072f8 <commands+0xbc8>
ffffffffc0201600:	00005617          	auipc	a2,0x5
ffffffffc0201604:	60060613          	addi	a2,a2,1536 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201608:	12600593          	li	a1,294
ffffffffc020160c:	00006517          	auipc	a0,0x6
ffffffffc0201610:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201614:	e6dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201618:	00006697          	auipc	a3,0x6
ffffffffc020161c:	9c868693          	addi	a3,a3,-1592 # ffffffffc0206fe0 <commands+0x8b0>
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	5e060613          	addi	a2,a2,1504 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201628:	0f300593          	li	a1,243
ffffffffc020162c:	00006517          	auipc	a0,0x6
ffffffffc0201630:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201634:	e4dfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201638:	00006697          	auipc	a3,0x6
ffffffffc020163c:	9e868693          	addi	a3,a3,-1560 # ffffffffc0207020 <commands+0x8f0>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	5c060613          	addi	a2,a2,1472 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201648:	0ba00593          	li	a1,186
ffffffffc020164c:	00006517          	auipc	a0,0x6
ffffffffc0201650:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201654:	e2dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201658 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201658:	1141                	addi	sp,sp,-16
ffffffffc020165a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020165c:	16058e63          	beqz	a1,ffffffffc02017d8 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201660:	00659693          	slli	a3,a1,0x6
ffffffffc0201664:	96aa                	add	a3,a3,a0
ffffffffc0201666:	02d50d63          	beq	a0,a3,ffffffffc02016a0 <default_free_pages+0x48>
ffffffffc020166a:	651c                	ld	a5,8(a0)
ffffffffc020166c:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020166e:	14079563          	bnez	a5,ffffffffc02017b8 <default_free_pages+0x160>
ffffffffc0201672:	651c                	ld	a5,8(a0)
ffffffffc0201674:	8385                	srli	a5,a5,0x1
ffffffffc0201676:	8b85                	andi	a5,a5,1
ffffffffc0201678:	14079063          	bnez	a5,ffffffffc02017b8 <default_free_pages+0x160>
ffffffffc020167c:	87aa                	mv	a5,a0
ffffffffc020167e:	a809                	j	ffffffffc0201690 <default_free_pages+0x38>
ffffffffc0201680:	6798                	ld	a4,8(a5)
ffffffffc0201682:	8b05                	andi	a4,a4,1
ffffffffc0201684:	12071a63          	bnez	a4,ffffffffc02017b8 <default_free_pages+0x160>
ffffffffc0201688:	6798                	ld	a4,8(a5)
ffffffffc020168a:	8b09                	andi	a4,a4,2
ffffffffc020168c:	12071663          	bnez	a4,ffffffffc02017b8 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201690:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201694:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201698:	04078793          	addi	a5,a5,64
ffffffffc020169c:	fed792e3          	bne	a5,a3,ffffffffc0201680 <default_free_pages+0x28>
    base->property = n;
ffffffffc02016a0:	2581                	sext.w	a1,a1
ffffffffc02016a2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016a4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016a8:	4789                	li	a5,2
ffffffffc02016aa:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016ae:	000ab697          	auipc	a3,0xab
ffffffffc02016b2:	1ca68693          	addi	a3,a3,458 # ffffffffc02ac878 <free_area>
ffffffffc02016b6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016b8:	669c                	ld	a5,8(a3)
ffffffffc02016ba:	9db9                	addw	a1,a1,a4
ffffffffc02016bc:	000ab717          	auipc	a4,0xab
ffffffffc02016c0:	1cb72623          	sw	a1,460(a4) # ffffffffc02ac888 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016c4:	0cd78163          	beq	a5,a3,ffffffffc0201786 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016c8:	fe878713          	addi	a4,a5,-24
ffffffffc02016cc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016ce:	4801                	li	a6,0
ffffffffc02016d0:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016d4:	00e56a63          	bltu	a0,a4,ffffffffc02016e8 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016d8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016da:	04d70f63          	beq	a4,a3,ffffffffc0201738 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016de:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016e0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016e4:	fee57ae3          	bgeu	a0,a4,ffffffffc02016d8 <default_free_pages+0x80>
ffffffffc02016e8:	00080663          	beqz	a6,ffffffffc02016f4 <default_free_pages+0x9c>
ffffffffc02016ec:	000ab817          	auipc	a6,0xab
ffffffffc02016f0:	18b83623          	sd	a1,396(a6) # ffffffffc02ac878 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016f4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016f6:	e390                	sd	a2,0(a5)
ffffffffc02016f8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016fa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016fc:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016fe:	06d58a63          	beq	a1,a3,ffffffffc0201772 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201702:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201706:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020170a:	02061793          	slli	a5,a2,0x20
ffffffffc020170e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201710:	97ba                	add	a5,a5,a4
ffffffffc0201712:	04f51b63          	bne	a0,a5,ffffffffc0201768 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201716:	491c                	lw	a5,16(a0)
ffffffffc0201718:	9e3d                	addw	a2,a2,a5
ffffffffc020171a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020171e:	57f5                	li	a5,-3
ffffffffc0201720:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201724:	01853803          	ld	a6,24(a0)
ffffffffc0201728:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020172a:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020172c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201730:	659c                	ld	a5,8(a1)
ffffffffc0201732:	01063023          	sd	a6,0(a2)
ffffffffc0201736:	a815                	j	ffffffffc020176a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201738:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020173a:	f114                	sd	a3,32(a0)
ffffffffc020173c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020173e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201740:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201742:	00d70563          	beq	a4,a3,ffffffffc020174c <default_free_pages+0xf4>
ffffffffc0201746:	4805                	li	a6,1
ffffffffc0201748:	87ba                	mv	a5,a4
ffffffffc020174a:	bf59                	j	ffffffffc02016e0 <default_free_pages+0x88>
ffffffffc020174c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020174e:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201750:	00d78d63          	beq	a5,a3,ffffffffc020176a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201754:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201758:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020175c:	02061793          	slli	a5,a2,0x20
ffffffffc0201760:	83e9                	srli	a5,a5,0x1a
ffffffffc0201762:	97ba                	add	a5,a5,a4
ffffffffc0201764:	faf509e3          	beq	a0,a5,ffffffffc0201716 <default_free_pages+0xbe>
ffffffffc0201768:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020176a:	fe878713          	addi	a4,a5,-24
ffffffffc020176e:	00d78963          	beq	a5,a3,ffffffffc0201780 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201772:	4910                	lw	a2,16(a0)
ffffffffc0201774:	02061693          	slli	a3,a2,0x20
ffffffffc0201778:	82e9                	srli	a3,a3,0x1a
ffffffffc020177a:	96aa                	add	a3,a3,a0
ffffffffc020177c:	00d70e63          	beq	a4,a3,ffffffffc0201798 <default_free_pages+0x140>
}
ffffffffc0201780:	60a2                	ld	ra,8(sp)
ffffffffc0201782:	0141                	addi	sp,sp,16
ffffffffc0201784:	8082                	ret
ffffffffc0201786:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201788:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020178c:	e398                	sd	a4,0(a5)
ffffffffc020178e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201790:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201792:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201794:	0141                	addi	sp,sp,16
ffffffffc0201796:	8082                	ret
            base->property += p->property;
ffffffffc0201798:	ff87a703          	lw	a4,-8(a5)
ffffffffc020179c:	ff078693          	addi	a3,a5,-16
ffffffffc02017a0:	9e39                	addw	a2,a2,a4
ffffffffc02017a2:	c910                	sw	a2,16(a0)
ffffffffc02017a4:	5775                	li	a4,-3
ffffffffc02017a6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017aa:	6398                	ld	a4,0(a5)
ffffffffc02017ac:	679c                	ld	a5,8(a5)
}
ffffffffc02017ae:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017b0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017b2:	e398                	sd	a4,0(a5)
ffffffffc02017b4:	0141                	addi	sp,sp,16
ffffffffc02017b6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017b8:	00006697          	auipc	a3,0x6
ffffffffc02017bc:	b5068693          	addi	a3,a3,-1200 # ffffffffc0207308 <commands+0xbd8>
ffffffffc02017c0:	00005617          	auipc	a2,0x5
ffffffffc02017c4:	44060613          	addi	a2,a2,1088 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02017c8:	08300593          	li	a1,131
ffffffffc02017cc:	00005517          	auipc	a0,0x5
ffffffffc02017d0:	7fc50513          	addi	a0,a0,2044 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02017d4:	cadfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc02017d8:	00006697          	auipc	a3,0x6
ffffffffc02017dc:	b5868693          	addi	a3,a3,-1192 # ffffffffc0207330 <commands+0xc00>
ffffffffc02017e0:	00005617          	auipc	a2,0x5
ffffffffc02017e4:	42060613          	addi	a2,a2,1056 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02017e8:	08000593          	li	a1,128
ffffffffc02017ec:	00005517          	auipc	a0,0x5
ffffffffc02017f0:	7dc50513          	addi	a0,a0,2012 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02017f4:	c8dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02017f8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017f8:	c959                	beqz	a0,ffffffffc020188e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017fa:	000ab597          	auipc	a1,0xab
ffffffffc02017fe:	07e58593          	addi	a1,a1,126 # ffffffffc02ac878 <free_area>
ffffffffc0201802:	0105a803          	lw	a6,16(a1)
ffffffffc0201806:	862a                	mv	a2,a0
ffffffffc0201808:	02081793          	slli	a5,a6,0x20
ffffffffc020180c:	9381                	srli	a5,a5,0x20
ffffffffc020180e:	00a7ee63          	bltu	a5,a0,ffffffffc020182a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201812:	87ae                	mv	a5,a1
ffffffffc0201814:	a801                	j	ffffffffc0201824 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201816:	ff87a703          	lw	a4,-8(a5)
ffffffffc020181a:	02071693          	slli	a3,a4,0x20
ffffffffc020181e:	9281                	srli	a3,a3,0x20
ffffffffc0201820:	00c6f763          	bgeu	a3,a2,ffffffffc020182e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201824:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201826:	feb798e3          	bne	a5,a1,ffffffffc0201816 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020182a:	4501                	li	a0,0
}
ffffffffc020182c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020182e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201832:	dd6d                	beqz	a0,ffffffffc020182c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201834:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201838:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020183c:	00060e1b          	sext.w	t3,a2
ffffffffc0201840:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201844:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201848:	02d67863          	bgeu	a2,a3,ffffffffc0201878 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020184c:	061a                	slli	a2,a2,0x6
ffffffffc020184e:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201850:	41c7073b          	subw	a4,a4,t3
ffffffffc0201854:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201856:	00860693          	addi	a3,a2,8
ffffffffc020185a:	4709                	li	a4,2
ffffffffc020185c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201860:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201864:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201868:	0105a803          	lw	a6,16(a1)
ffffffffc020186c:	e314                	sd	a3,0(a4)
ffffffffc020186e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201872:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201874:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201878:	41c8083b          	subw	a6,a6,t3
ffffffffc020187c:	000ab717          	auipc	a4,0xab
ffffffffc0201880:	01072623          	sw	a6,12(a4) # ffffffffc02ac888 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201884:	5775                	li	a4,-3
ffffffffc0201886:	17c1                	addi	a5,a5,-16
ffffffffc0201888:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020188c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020188e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201890:	00006697          	auipc	a3,0x6
ffffffffc0201894:	aa068693          	addi	a3,a3,-1376 # ffffffffc0207330 <commands+0xc00>
ffffffffc0201898:	00005617          	auipc	a2,0x5
ffffffffc020189c:	36860613          	addi	a2,a2,872 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02018a0:	06200593          	li	a1,98
ffffffffc02018a4:	00005517          	auipc	a0,0x5
ffffffffc02018a8:	72450513          	addi	a0,a0,1828 # ffffffffc0206fc8 <commands+0x898>
default_alloc_pages(size_t n) {
ffffffffc02018ac:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018ae:	bd3fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02018b2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02018b2:	1141                	addi	sp,sp,-16
ffffffffc02018b4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018b6:	c1ed                	beqz	a1,ffffffffc0201998 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018b8:	00659693          	slli	a3,a1,0x6
ffffffffc02018bc:	96aa                	add	a3,a3,a0
ffffffffc02018be:	02d50463          	beq	a0,a3,ffffffffc02018e6 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018c2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018c4:	87aa                	mv	a5,a0
ffffffffc02018c6:	8b05                	andi	a4,a4,1
ffffffffc02018c8:	e709                	bnez	a4,ffffffffc02018d2 <default_init_memmap+0x20>
ffffffffc02018ca:	a07d                	j	ffffffffc0201978 <default_init_memmap+0xc6>
ffffffffc02018cc:	6798                	ld	a4,8(a5)
ffffffffc02018ce:	8b05                	andi	a4,a4,1
ffffffffc02018d0:	c745                	beqz	a4,ffffffffc0201978 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018d2:	0007a823          	sw	zero,16(a5)
ffffffffc02018d6:	0007b423          	sd	zero,8(a5)
ffffffffc02018da:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018de:	04078793          	addi	a5,a5,64
ffffffffc02018e2:	fed795e3          	bne	a5,a3,ffffffffc02018cc <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018e6:	2581                	sext.w	a1,a1
ffffffffc02018e8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018ea:	4789                	li	a5,2
ffffffffc02018ec:	00850713          	addi	a4,a0,8
ffffffffc02018f0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018f4:	000ab697          	auipc	a3,0xab
ffffffffc02018f8:	f8468693          	addi	a3,a3,-124 # ffffffffc02ac878 <free_area>
ffffffffc02018fc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018fe:	669c                	ld	a5,8(a3)
ffffffffc0201900:	9db9                	addw	a1,a1,a4
ffffffffc0201902:	000ab717          	auipc	a4,0xab
ffffffffc0201906:	f8b72323          	sw	a1,-122(a4) # ffffffffc02ac888 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020190a:	04d78a63          	beq	a5,a3,ffffffffc020195e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020190e:	fe878713          	addi	a4,a5,-24
ffffffffc0201912:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201914:	4801                	li	a6,0
ffffffffc0201916:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020191a:	00e56a63          	bltu	a0,a4,ffffffffc020192e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020191e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201920:	02d70563          	beq	a4,a3,ffffffffc020194a <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201924:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201926:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020192a:	fee57ae3          	bgeu	a0,a4,ffffffffc020191e <default_init_memmap+0x6c>
ffffffffc020192e:	00080663          	beqz	a6,ffffffffc020193a <default_init_memmap+0x88>
ffffffffc0201932:	000ab717          	auipc	a4,0xab
ffffffffc0201936:	f4b73323          	sd	a1,-186(a4) # ffffffffc02ac878 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020193a:	6398                	ld	a4,0(a5)
}
ffffffffc020193c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020193e:	e390                	sd	a2,0(a5)
ffffffffc0201940:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201942:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201944:	ed18                	sd	a4,24(a0)
ffffffffc0201946:	0141                	addi	sp,sp,16
ffffffffc0201948:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020194a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020194c:	f114                	sd	a3,32(a0)
ffffffffc020194e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201950:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201952:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201954:	00d70e63          	beq	a4,a3,ffffffffc0201970 <default_init_memmap+0xbe>
ffffffffc0201958:	4805                	li	a6,1
ffffffffc020195a:	87ba                	mv	a5,a4
ffffffffc020195c:	b7e9                	j	ffffffffc0201926 <default_init_memmap+0x74>
}
ffffffffc020195e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201960:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201964:	e398                	sd	a4,0(a5)
ffffffffc0201966:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201968:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020196a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
ffffffffc0201970:	60a2                	ld	ra,8(sp)
ffffffffc0201972:	e290                	sd	a2,0(a3)
ffffffffc0201974:	0141                	addi	sp,sp,16
ffffffffc0201976:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201978:	00006697          	auipc	a3,0x6
ffffffffc020197c:	9c068693          	addi	a3,a3,-1600 # ffffffffc0207338 <commands+0xc08>
ffffffffc0201980:	00005617          	auipc	a2,0x5
ffffffffc0201984:	28060613          	addi	a2,a2,640 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201988:	04900593          	li	a1,73
ffffffffc020198c:	00005517          	auipc	a0,0x5
ffffffffc0201990:	63c50513          	addi	a0,a0,1596 # ffffffffc0206fc8 <commands+0x898>
ffffffffc0201994:	aedfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc0201998:	00006697          	auipc	a3,0x6
ffffffffc020199c:	99868693          	addi	a3,a3,-1640 # ffffffffc0207330 <commands+0xc00>
ffffffffc02019a0:	00005617          	auipc	a2,0x5
ffffffffc02019a4:	26060613          	addi	a2,a2,608 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02019a8:	04600593          	li	a1,70
ffffffffc02019ac:	00005517          	auipc	a0,0x5
ffffffffc02019b0:	61c50513          	addi	a0,a0,1564 # ffffffffc0206fc8 <commands+0x898>
ffffffffc02019b4:	acdfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02019b8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019b8:	c125                	beqz	a0,ffffffffc0201a18 <slob_free+0x60>
		return;

	if (size)
ffffffffc02019ba:	e1a5                	bnez	a1,ffffffffc0201a1a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019bc:	100027f3          	csrr	a5,sstatus
ffffffffc02019c0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019c2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019c4:	e3bd                	bnez	a5,ffffffffc0201a2a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019c6:	000a0797          	auipc	a5,0xa0
ffffffffc02019ca:	a3278793          	addi	a5,a5,-1486 # ffffffffc02a13f8 <slobfree>
ffffffffc02019ce:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019d2:	00a7fa63          	bgeu	a5,a0,ffffffffc02019e6 <slob_free+0x2e>
ffffffffc02019d6:	00e56c63          	bltu	a0,a4,ffffffffc02019ee <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019da:	00e7fa63          	bgeu	a5,a4,ffffffffc02019ee <slob_free+0x36>
    return 0;
ffffffffc02019de:	87ba                	mv	a5,a4
ffffffffc02019e0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019e2:	fea7eae3          	bltu	a5,a0,ffffffffc02019d6 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019e6:	fee7ece3          	bltu	a5,a4,ffffffffc02019de <slob_free+0x26>
ffffffffc02019ea:	fee57ae3          	bgeu	a0,a4,ffffffffc02019de <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019ee:	4110                	lw	a2,0(a0)
ffffffffc02019f0:	00461693          	slli	a3,a2,0x4
ffffffffc02019f4:	96aa                	add	a3,a3,a0
ffffffffc02019f6:	08d70b63          	beq	a4,a3,ffffffffc0201a8c <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019fa:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019fc:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019fe:	00469713          	slli	a4,a3,0x4
ffffffffc0201a02:	973e                	add	a4,a4,a5
ffffffffc0201a04:	08e50f63          	beq	a0,a4,ffffffffc0201aa2 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201a08:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201a0a:	000a0717          	auipc	a4,0xa0
ffffffffc0201a0e:	9ef73723          	sd	a5,-1554(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0201a12:	c199                	beqz	a1,ffffffffc0201a18 <slob_free+0x60>
        intr_enable();
ffffffffc0201a14:	c39fe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc0201a18:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a1a:	05bd                	addi	a1,a1,15
ffffffffc0201a1c:	8191                	srli	a1,a1,0x4
ffffffffc0201a1e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a20:	100027f3          	csrr	a5,sstatus
ffffffffc0201a24:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a26:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a28:	dfd9                	beqz	a5,ffffffffc02019c6 <slob_free+0xe>
{
ffffffffc0201a2a:	1101                	addi	sp,sp,-32
ffffffffc0201a2c:	e42a                	sd	a0,8(sp)
ffffffffc0201a2e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a30:	c23fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a34:	000a0797          	auipc	a5,0xa0
ffffffffc0201a38:	9c478793          	addi	a5,a5,-1596 # ffffffffc02a13f8 <slobfree>
ffffffffc0201a3c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a3e:	6522                	ld	a0,8(sp)
ffffffffc0201a40:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a42:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a44:	00a7fa63          	bgeu	a5,a0,ffffffffc0201a58 <slob_free+0xa0>
ffffffffc0201a48:	00e56c63          	bltu	a0,a4,ffffffffc0201a60 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a4c:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a60 <slob_free+0xa8>
    return 0;
ffffffffc0201a50:	87ba                	mv	a5,a4
ffffffffc0201a52:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a54:	fea7eae3          	bltu	a5,a0,ffffffffc0201a48 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a58:	fee7ece3          	bltu	a5,a4,ffffffffc0201a50 <slob_free+0x98>
ffffffffc0201a5c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a50 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a60:	4110                	lw	a2,0(a0)
ffffffffc0201a62:	00461693          	slli	a3,a2,0x4
ffffffffc0201a66:	96aa                	add	a3,a3,a0
ffffffffc0201a68:	04d70763          	beq	a4,a3,ffffffffc0201ab6 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a6c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a6e:	4394                	lw	a3,0(a5)
ffffffffc0201a70:	00469713          	slli	a4,a3,0x4
ffffffffc0201a74:	973e                	add	a4,a4,a5
ffffffffc0201a76:	04e50663          	beq	a0,a4,ffffffffc0201ac2 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a7a:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a7c:	000a0717          	auipc	a4,0xa0
ffffffffc0201a80:	96f73e23          	sd	a5,-1668(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0201a84:	e58d                	bnez	a1,ffffffffc0201aae <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a86:	60e2                	ld	ra,24(sp)
ffffffffc0201a88:	6105                	addi	sp,sp,32
ffffffffc0201a8a:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a8c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a8e:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a90:	9e35                	addw	a2,a2,a3
ffffffffc0201a92:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a94:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a96:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a98:	00469713          	slli	a4,a3,0x4
ffffffffc0201a9c:	973e                	add	a4,a4,a5
ffffffffc0201a9e:	f6e515e3          	bne	a0,a4,ffffffffc0201a08 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201aa2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201aa4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aa6:	9eb9                	addw	a3,a3,a4
ffffffffc0201aa8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aaa:	e790                	sd	a2,8(a5)
ffffffffc0201aac:	bfb9                	j	ffffffffc0201a0a <slob_free+0x52>
}
ffffffffc0201aae:	60e2                	ld	ra,24(sp)
ffffffffc0201ab0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ab2:	b9bfe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201ab6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ab8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201aba:	9e35                	addw	a2,a2,a3
ffffffffc0201abc:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201abe:	e518                	sd	a4,8(a0)
ffffffffc0201ac0:	b77d                	j	ffffffffc0201a6e <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201ac2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ac4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ac6:	9eb9                	addw	a3,a3,a4
ffffffffc0201ac8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aca:	e790                	sd	a2,8(a5)
ffffffffc0201acc:	bf45                	j	ffffffffc0201a7c <slob_free+0xc4>

ffffffffc0201ace <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ace:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ad0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ad2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ad6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ad8:	378000ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
  if(!page)
ffffffffc0201adc:	cd1d                	beqz	a0,ffffffffc0201b1a <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0201ade:	000ab797          	auipc	a5,0xab
ffffffffc0201ae2:	dca78793          	addi	a5,a5,-566 # ffffffffc02ac8a8 <pages>
ffffffffc0201ae6:	6394                	ld	a3,0(a5)
ffffffffc0201ae8:	00007797          	auipc	a5,0x7
ffffffffc0201aec:	1e078793          	addi	a5,a5,480 # ffffffffc0208cc8 <nbase>
ffffffffc0201af0:	8d15                	sub	a0,a0,a3
ffffffffc0201af2:	6394                	ld	a3,0(a5)
ffffffffc0201af4:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0201af6:	000ab797          	auipc	a5,0xab
ffffffffc0201afa:	d4278793          	addi	a5,a5,-702 # ffffffffc02ac838 <npage>
    return page - pages + nbase;
ffffffffc0201afe:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201b00:	6398                	ld	a4,0(a5)
ffffffffc0201b02:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b06:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b08:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201b0a:	00e7fb63          	bgeu	a5,a4,ffffffffc0201b20 <__slob_get_free_pages.isra.0+0x52>
ffffffffc0201b0e:	000ab797          	auipc	a5,0xab
ffffffffc0201b12:	d8a78793          	addi	a5,a5,-630 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0201b16:	6394                	ld	a3,0(a5)
ffffffffc0201b18:	9536                	add	a0,a0,a3
}
ffffffffc0201b1a:	60a2                	ld	ra,8(sp)
ffffffffc0201b1c:	0141                	addi	sp,sp,16
ffffffffc0201b1e:	8082                	ret
ffffffffc0201b20:	86aa                	mv	a3,a0
ffffffffc0201b22:	00006617          	auipc	a2,0x6
ffffffffc0201b26:	87660613          	addi	a2,a2,-1930 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0201b2a:	06900593          	li	a1,105
ffffffffc0201b2e:	00006517          	auipc	a0,0x6
ffffffffc0201b32:	89250513          	addi	a0,a0,-1902 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0201b36:	94bfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b3a:	1101                	addi	sp,sp,-32
ffffffffc0201b3c:	ec06                	sd	ra,24(sp)
ffffffffc0201b3e:	e822                	sd	s0,16(sp)
ffffffffc0201b40:	e426                	sd	s1,8(sp)
ffffffffc0201b42:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b44:	01050713          	addi	a4,a0,16
ffffffffc0201b48:	6785                	lui	a5,0x1
ffffffffc0201b4a:	0cf77563          	bgeu	a4,a5,ffffffffc0201c14 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b4e:	00f50493          	addi	s1,a0,15
ffffffffc0201b52:	8091                	srli	s1,s1,0x4
ffffffffc0201b54:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b56:	10002673          	csrr	a2,sstatus
ffffffffc0201b5a:	8a09                	andi	a2,a2,2
ffffffffc0201b5c:	e64d                	bnez	a2,ffffffffc0201c06 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0201b5e:	000a0917          	auipc	s2,0xa0
ffffffffc0201b62:	89a90913          	addi	s2,s2,-1894 # ffffffffc02a13f8 <slobfree>
ffffffffc0201b66:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b6a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b6c:	4398                	lw	a4,0(a5)
ffffffffc0201b6e:	0a975063          	bge	a4,s1,ffffffffc0201c0e <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0201b72:	00d78b63          	beq	a5,a3,ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b76:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b78:	4018                	lw	a4,0(s0)
ffffffffc0201b7a:	02975a63          	bge	a4,s1,ffffffffc0201bae <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0201b7e:	00093683          	ld	a3,0(s2)
ffffffffc0201b82:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0201b84:	fed799e3          	bne	a5,a3,ffffffffc0201b76 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0201b88:	e225                	bnez	a2,ffffffffc0201be8 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b8a:	4501                	li	a0,0
ffffffffc0201b8c:	f43ff0ef          	jal	ra,ffffffffc0201ace <__slob_get_free_pages.isra.0>
ffffffffc0201b90:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b92:	cd15                	beqz	a0,ffffffffc0201bce <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b94:	6585                	lui	a1,0x1
ffffffffc0201b96:	e23ff0ef          	jal	ra,ffffffffc02019b8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b9a:	10002673          	csrr	a2,sstatus
ffffffffc0201b9e:	8a09                	andi	a2,a2,2
ffffffffc0201ba0:	ee15                	bnez	a2,ffffffffc0201bdc <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0201ba2:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201ba6:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ba8:	4018                	lw	a4,0(s0)
ffffffffc0201baa:	fc974ae3          	blt	a4,s1,ffffffffc0201b7e <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201bae:	04e48963          	beq	s1,a4,ffffffffc0201c00 <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0201bb2:	00449693          	slli	a3,s1,0x4
ffffffffc0201bb6:	96a2                	add	a3,a3,s0
ffffffffc0201bb8:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201bba:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201bbc:	9f05                	subw	a4,a4,s1
ffffffffc0201bbe:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201bc0:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201bc2:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201bc4:	000a0717          	auipc	a4,0xa0
ffffffffc0201bc8:	82f73a23          	sd	a5,-1996(a4) # ffffffffc02a13f8 <slobfree>
    if (flag) {
ffffffffc0201bcc:	e20d                	bnez	a2,ffffffffc0201bee <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0201bce:	8522                	mv	a0,s0
ffffffffc0201bd0:	60e2                	ld	ra,24(sp)
ffffffffc0201bd2:	6442                	ld	s0,16(sp)
ffffffffc0201bd4:	64a2                	ld	s1,8(sp)
ffffffffc0201bd6:	6902                	ld	s2,0(sp)
ffffffffc0201bd8:	6105                	addi	sp,sp,32
ffffffffc0201bda:	8082                	ret
        intr_disable();
ffffffffc0201bdc:	a77fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201be0:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201be2:	00093783          	ld	a5,0(s2)
ffffffffc0201be6:	b7c1                	j	ffffffffc0201ba6 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0201be8:	a65fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201bec:	bf79                	j	ffffffffc0201b8a <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0201bee:	a5ffe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201bf2:	8522                	mv	a0,s0
ffffffffc0201bf4:	60e2                	ld	ra,24(sp)
ffffffffc0201bf6:	6442                	ld	s0,16(sp)
ffffffffc0201bf8:	64a2                	ld	s1,8(sp)
ffffffffc0201bfa:	6902                	ld	s2,0(sp)
ffffffffc0201bfc:	6105                	addi	sp,sp,32
ffffffffc0201bfe:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201c00:	6418                	ld	a4,8(s0)
ffffffffc0201c02:	e798                	sd	a4,8(a5)
ffffffffc0201c04:	b7c1                	j	ffffffffc0201bc4 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0201c06:	a4dfe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201c0a:	4605                	li	a2,1
ffffffffc0201c0c:	bf89                	j	ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c0e:	843e                	mv	s0,a5
ffffffffc0201c10:	87b6                	mv	a5,a3
ffffffffc0201c12:	bf71                	j	ffffffffc0201bae <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c14:	00006697          	auipc	a3,0x6
ffffffffc0201c18:	82468693          	addi	a3,a3,-2012 # ffffffffc0207438 <default_pmm_manager+0xf0>
ffffffffc0201c1c:	00005617          	auipc	a2,0x5
ffffffffc0201c20:	fe460613          	addi	a2,a2,-28 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0201c24:	06400593          	li	a1,100
ffffffffc0201c28:	00006517          	auipc	a0,0x6
ffffffffc0201c2c:	83050513          	addi	a0,a0,-2000 # ffffffffc0207458 <default_pmm_manager+0x110>
ffffffffc0201c30:	851fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201c34 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c34:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c36:	00006517          	auipc	a0,0x6
ffffffffc0201c3a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0207470 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c3e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c40:	d4efe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c44:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c46:	00005517          	auipc	a0,0x5
ffffffffc0201c4a:	7d250513          	addi	a0,a0,2002 # ffffffffc0207418 <default_pmm_manager+0xd0>
}
ffffffffc0201c4e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c50:	d3efe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c54 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c54:	4501                	li	a0,0
ffffffffc0201c56:	8082                	ret

ffffffffc0201c58 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c58:	1101                	addi	sp,sp,-32
ffffffffc0201c5a:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c5c:	6905                	lui	s2,0x1
{
ffffffffc0201c5e:	e822                	sd	s0,16(sp)
ffffffffc0201c60:	ec06                	sd	ra,24(sp)
ffffffffc0201c62:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c64:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc0201c68:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c6a:	04a7fc63          	bgeu	a5,a0,ffffffffc0201cc2 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c6e:	4561                	li	a0,24
ffffffffc0201c70:	ecbff0ef          	jal	ra,ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>
ffffffffc0201c74:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c76:	cd21                	beqz	a0,ffffffffc0201cce <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c78:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c7c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c7e:	00f95763          	bge	s2,a5,ffffffffc0201c8c <kmalloc+0x34>
ffffffffc0201c82:	6705                	lui	a4,0x1
ffffffffc0201c84:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c86:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c88:	fef74ee3          	blt	a4,a5,ffffffffc0201c84 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c8c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c8e:	e41ff0ef          	jal	ra,ffffffffc0201ace <__slob_get_free_pages.isra.0>
ffffffffc0201c92:	e488                	sd	a0,8(s1)
ffffffffc0201c94:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c96:	c935                	beqz	a0,ffffffffc0201d0a <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c98:	100027f3          	csrr	a5,sstatus
ffffffffc0201c9c:	8b89                	andi	a5,a5,2
ffffffffc0201c9e:	e3a1                	bnez	a5,ffffffffc0201cde <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201ca0:	000ab797          	auipc	a5,0xab
ffffffffc0201ca4:	b8878793          	addi	a5,a5,-1144 # ffffffffc02ac828 <bigblocks>
ffffffffc0201ca8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201caa:	000ab717          	auipc	a4,0xab
ffffffffc0201cae:	b6973f23          	sd	s1,-1154(a4) # ffffffffc02ac828 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cb2:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cb4:	8522                	mv	a0,s0
ffffffffc0201cb6:	60e2                	ld	ra,24(sp)
ffffffffc0201cb8:	6442                	ld	s0,16(sp)
ffffffffc0201cba:	64a2                	ld	s1,8(sp)
ffffffffc0201cbc:	6902                	ld	s2,0(sp)
ffffffffc0201cbe:	6105                	addi	sp,sp,32
ffffffffc0201cc0:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cc2:	0541                	addi	a0,a0,16
ffffffffc0201cc4:	e77ff0ef          	jal	ra,ffffffffc0201b3a <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cc8:	01050413          	addi	s0,a0,16
ffffffffc0201ccc:	f565                	bnez	a0,ffffffffc0201cb4 <kmalloc+0x5c>
ffffffffc0201cce:	4401                	li	s0,0
}
ffffffffc0201cd0:	8522                	mv	a0,s0
ffffffffc0201cd2:	60e2                	ld	ra,24(sp)
ffffffffc0201cd4:	6442                	ld	s0,16(sp)
ffffffffc0201cd6:	64a2                	ld	s1,8(sp)
ffffffffc0201cd8:	6902                	ld	s2,0(sp)
ffffffffc0201cda:	6105                	addi	sp,sp,32
ffffffffc0201cdc:	8082                	ret
        intr_disable();
ffffffffc0201cde:	975fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ce2:	000ab797          	auipc	a5,0xab
ffffffffc0201ce6:	b4678793          	addi	a5,a5,-1210 # ffffffffc02ac828 <bigblocks>
ffffffffc0201cea:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cec:	000ab717          	auipc	a4,0xab
ffffffffc0201cf0:	b2973e23          	sd	s1,-1220(a4) # ffffffffc02ac828 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cf4:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cf6:	957fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201cfa:	6480                	ld	s0,8(s1)
}
ffffffffc0201cfc:	60e2                	ld	ra,24(sp)
ffffffffc0201cfe:	64a2                	ld	s1,8(sp)
ffffffffc0201d00:	8522                	mv	a0,s0
ffffffffc0201d02:	6442                	ld	s0,16(sp)
ffffffffc0201d04:	6902                	ld	s2,0(sp)
ffffffffc0201d06:	6105                	addi	sp,sp,32
ffffffffc0201d08:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d0a:	45e1                	li	a1,24
ffffffffc0201d0c:	8526                	mv	a0,s1
ffffffffc0201d0e:	cabff0ef          	jal	ra,ffffffffc02019b8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d12:	b74d                	j	ffffffffc0201cb4 <kmalloc+0x5c>

ffffffffc0201d14 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d14:	c165                	beqz	a0,ffffffffc0201df4 <kfree+0xe0>
{
ffffffffc0201d16:	1101                	addi	sp,sp,-32
ffffffffc0201d18:	e426                	sd	s1,8(sp)
ffffffffc0201d1a:	ec06                	sd	ra,24(sp)
ffffffffc0201d1c:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d1e:	03451793          	slli	a5,a0,0x34
ffffffffc0201d22:	84aa                	mv	s1,a0
ffffffffc0201d24:	eb8d                	bnez	a5,ffffffffc0201d56 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d26:	100027f3          	csrr	a5,sstatus
ffffffffc0201d2a:	8b89                	andi	a5,a5,2
ffffffffc0201d2c:	ebd9                	bnez	a5,ffffffffc0201dc2 <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d2e:	000ab797          	auipc	a5,0xab
ffffffffc0201d32:	afa78793          	addi	a5,a5,-1286 # ffffffffc02ac828 <bigblocks>
ffffffffc0201d36:	6394                	ld	a3,0(a5)
ffffffffc0201d38:	ce99                	beqz	a3,ffffffffc0201d56 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d3a:	669c                	ld	a5,8(a3)
ffffffffc0201d3c:	6a80                	ld	s0,16(a3)
ffffffffc0201d3e:	0af50c63          	beq	a0,a5,ffffffffc0201df6 <kfree+0xe2>
    return 0;
ffffffffc0201d42:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d44:	c801                	beqz	s0,ffffffffc0201d54 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d46:	6418                	ld	a4,8(s0)
ffffffffc0201d48:	681c                	ld	a5,16(s0)
ffffffffc0201d4a:	00970e63          	beq	a4,s1,ffffffffc0201d66 <kfree+0x52>
ffffffffc0201d4e:	86a2                	mv	a3,s0
ffffffffc0201d50:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d52:	f875                	bnez	s0,ffffffffc0201d46 <kfree+0x32>
    if (flag) {
ffffffffc0201d54:	e649                	bnez	a2,ffffffffc0201dde <kfree+0xca>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d56:	6442                	ld	s0,16(sp)
ffffffffc0201d58:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d5a:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d5e:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d60:	4581                	li	a1,0
}
ffffffffc0201d62:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d64:	b991                	j	ffffffffc02019b8 <slob_free>
				*last = bb->next;
ffffffffc0201d66:	ea9c                	sd	a5,16(a3)
ffffffffc0201d68:	e259                	bnez	a2,ffffffffc0201dee <kfree+0xda>
    return pa2page(PADDR(kva));
ffffffffc0201d6a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d6e:	4018                	lw	a4,0(s0)
ffffffffc0201d70:	08f4e963          	bltu	s1,a5,ffffffffc0201e02 <kfree+0xee>
ffffffffc0201d74:	000ab797          	auipc	a5,0xab
ffffffffc0201d78:	b2478793          	addi	a5,a5,-1244 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0201d7c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d7e:	000ab797          	auipc	a5,0xab
ffffffffc0201d82:	aba78793          	addi	a5,a5,-1350 # ffffffffc02ac838 <npage>
ffffffffc0201d86:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d88:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d8c:	08f4f863          	bgeu	s1,a5,ffffffffc0201e1c <kfree+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d90:	00007797          	auipc	a5,0x7
ffffffffc0201d94:	f3878793          	addi	a5,a5,-200 # ffffffffc0208cc8 <nbase>
ffffffffc0201d98:	639c                	ld	a5,0(a5)
ffffffffc0201d9a:	000ab697          	auipc	a3,0xab
ffffffffc0201d9e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc02ac8a8 <pages>
ffffffffc0201da2:	6288                	ld	a0,0(a3)
ffffffffc0201da4:	8c9d                	sub	s1,s1,a5
ffffffffc0201da6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201da8:	4585                	li	a1,1
ffffffffc0201daa:	9526                	add	a0,a0,s1
ffffffffc0201dac:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201db0:	128000ef          	jal	ra,ffffffffc0201ed8 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201db4:	8522                	mv	a0,s0
}
ffffffffc0201db6:	6442                	ld	s0,16(sp)
ffffffffc0201db8:	60e2                	ld	ra,24(sp)
ffffffffc0201dba:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dbc:	45e1                	li	a1,24
}
ffffffffc0201dbe:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201dc0:	bee5                	j	ffffffffc02019b8 <slob_free>
        intr_disable();
ffffffffc0201dc2:	891fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dc6:	000ab797          	auipc	a5,0xab
ffffffffc0201dca:	a6278793          	addi	a5,a5,-1438 # ffffffffc02ac828 <bigblocks>
ffffffffc0201dce:	6394                	ld	a3,0(a5)
ffffffffc0201dd0:	c699                	beqz	a3,ffffffffc0201dde <kfree+0xca>
			if (bb->pages == block) {
ffffffffc0201dd2:	669c                	ld	a5,8(a3)
ffffffffc0201dd4:	6a80                	ld	s0,16(a3)
ffffffffc0201dd6:	00f48763          	beq	s1,a5,ffffffffc0201de4 <kfree+0xd0>
        return 1;
ffffffffc0201dda:	4605                	li	a2,1
ffffffffc0201ddc:	b7a5                	j	ffffffffc0201d44 <kfree+0x30>
        intr_enable();
ffffffffc0201dde:	86ffe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201de2:	bf95                	j	ffffffffc0201d56 <kfree+0x42>
				*last = bb->next;
ffffffffc0201de4:	000ab797          	auipc	a5,0xab
ffffffffc0201de8:	a487b223          	sd	s0,-1468(a5) # ffffffffc02ac828 <bigblocks>
ffffffffc0201dec:	8436                	mv	s0,a3
ffffffffc0201dee:	85ffe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201df2:	bfa5                	j	ffffffffc0201d6a <kfree+0x56>
ffffffffc0201df4:	8082                	ret
ffffffffc0201df6:	000ab797          	auipc	a5,0xab
ffffffffc0201dfa:	a287b923          	sd	s0,-1486(a5) # ffffffffc02ac828 <bigblocks>
ffffffffc0201dfe:	8436                	mv	s0,a3
ffffffffc0201e00:	b7ad                	j	ffffffffc0201d6a <kfree+0x56>
    return pa2page(PADDR(kva));
ffffffffc0201e02:	86a6                	mv	a3,s1
ffffffffc0201e04:	00005617          	auipc	a2,0x5
ffffffffc0201e08:	5cc60613          	addi	a2,a2,1484 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc0201e0c:	06e00593          	li	a1,110
ffffffffc0201e10:	00005517          	auipc	a0,0x5
ffffffffc0201e14:	5b050513          	addi	a0,a0,1456 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0201e18:	e68fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e1c:	00005617          	auipc	a2,0x5
ffffffffc0201e20:	5dc60613          	addi	a2,a2,1500 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc0201e24:	06200593          	li	a1,98
ffffffffc0201e28:	00005517          	auipc	a0,0x5
ffffffffc0201e2c:	59850513          	addi	a0,a0,1432 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0201e30:	e50fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e34 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e34:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e36:	00005617          	auipc	a2,0x5
ffffffffc0201e3a:	5c260613          	addi	a2,a2,1474 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc0201e3e:	06200593          	li	a1,98
ffffffffc0201e42:	00005517          	auipc	a0,0x5
ffffffffc0201e46:	57e50513          	addi	a0,a0,1406 # ffffffffc02073c0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e4a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e4c:	e34fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e50 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e50:	715d                	addi	sp,sp,-80
ffffffffc0201e52:	e0a2                	sd	s0,64(sp)
ffffffffc0201e54:	fc26                	sd	s1,56(sp)
ffffffffc0201e56:	f84a                	sd	s2,48(sp)
ffffffffc0201e58:	f44e                	sd	s3,40(sp)
ffffffffc0201e5a:	f052                	sd	s4,32(sp)
ffffffffc0201e5c:	ec56                	sd	s5,24(sp)
ffffffffc0201e5e:	e486                	sd	ra,72(sp)
ffffffffc0201e60:	842a                	mv	s0,a0
ffffffffc0201e62:	000ab497          	auipc	s1,0xab
ffffffffc0201e66:	a2e48493          	addi	s1,s1,-1490 # ffffffffc02ac890 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e6a:	4985                	li	s3,1
ffffffffc0201e6c:	000aba17          	auipc	s4,0xab
ffffffffc0201e70:	9dca0a13          	addi	s4,s4,-1572 # ffffffffc02ac848 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e74:	0005091b          	sext.w	s2,a0
ffffffffc0201e78:	000aba97          	auipc	s5,0xab
ffffffffc0201e7c:	b10a8a93          	addi	s5,s5,-1264 # ffffffffc02ac988 <check_mm_struct>
ffffffffc0201e80:	a00d                	j	ffffffffc0201ea2 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e82:	609c                	ld	a5,0(s1)
ffffffffc0201e84:	6f9c                	ld	a5,24(a5)
ffffffffc0201e86:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e88:	4601                	li	a2,0
ffffffffc0201e8a:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e8c:	ed0d                	bnez	a0,ffffffffc0201ec6 <alloc_pages+0x76>
ffffffffc0201e8e:	0289ec63          	bltu	s3,s0,ffffffffc0201ec6 <alloc_pages+0x76>
ffffffffc0201e92:	000a2783          	lw	a5,0(s4)
ffffffffc0201e96:	2781                	sext.w	a5,a5
ffffffffc0201e98:	c79d                	beqz	a5,ffffffffc0201ec6 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e9a:	000ab503          	ld	a0,0(s5)
ffffffffc0201e9e:	47f010ef          	jal	ra,ffffffffc0203b1c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea6:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ea8:	8522                	mv	a0,s0
ffffffffc0201eaa:	dfe1                	beqz	a5,ffffffffc0201e82 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201eac:	fa6fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201eb0:	609c                	ld	a5,0(s1)
ffffffffc0201eb2:	8522                	mv	a0,s0
ffffffffc0201eb4:	6f9c                	ld	a5,24(a5)
ffffffffc0201eb6:	9782                	jalr	a5
ffffffffc0201eb8:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201eba:	f92fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ebe:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ec0:	4601                	li	a2,0
ffffffffc0201ec2:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ec4:	d569                	beqz	a0,ffffffffc0201e8e <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ec6:	60a6                	ld	ra,72(sp)
ffffffffc0201ec8:	6406                	ld	s0,64(sp)
ffffffffc0201eca:	74e2                	ld	s1,56(sp)
ffffffffc0201ecc:	7942                	ld	s2,48(sp)
ffffffffc0201ece:	79a2                	ld	s3,40(sp)
ffffffffc0201ed0:	7a02                	ld	s4,32(sp)
ffffffffc0201ed2:	6ae2                	ld	s5,24(sp)
ffffffffc0201ed4:	6161                	addi	sp,sp,80
ffffffffc0201ed6:	8082                	ret

ffffffffc0201ed8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ed8:	100027f3          	csrr	a5,sstatus
ffffffffc0201edc:	8b89                	andi	a5,a5,2
ffffffffc0201ede:	eb89                	bnez	a5,ffffffffc0201ef0 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ee0:	000ab797          	auipc	a5,0xab
ffffffffc0201ee4:	9b078793          	addi	a5,a5,-1616 # ffffffffc02ac890 <pmm_manager>
ffffffffc0201ee8:	639c                	ld	a5,0(a5)
ffffffffc0201eea:	0207b303          	ld	t1,32(a5)
ffffffffc0201eee:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ef0:	1101                	addi	sp,sp,-32
ffffffffc0201ef2:	ec06                	sd	ra,24(sp)
ffffffffc0201ef4:	e822                	sd	s0,16(sp)
ffffffffc0201ef6:	e426                	sd	s1,8(sp)
ffffffffc0201ef8:	842a                	mv	s0,a0
ffffffffc0201efa:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201efc:	f56fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f00:	000ab797          	auipc	a5,0xab
ffffffffc0201f04:	99078793          	addi	a5,a5,-1648 # ffffffffc02ac890 <pmm_manager>
ffffffffc0201f08:	639c                	ld	a5,0(a5)
ffffffffc0201f0a:	85a6                	mv	a1,s1
ffffffffc0201f0c:	8522                	mv	a0,s0
ffffffffc0201f0e:	739c                	ld	a5,32(a5)
ffffffffc0201f10:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f12:	6442                	ld	s0,16(sp)
ffffffffc0201f14:	60e2                	ld	ra,24(sp)
ffffffffc0201f16:	64a2                	ld	s1,8(sp)
ffffffffc0201f18:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f1a:	f32fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f1e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201f22:	8b89                	andi	a5,a5,2
ffffffffc0201f24:	eb89                	bnez	a5,ffffffffc0201f36 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f26:	000ab797          	auipc	a5,0xab
ffffffffc0201f2a:	96a78793          	addi	a5,a5,-1686 # ffffffffc02ac890 <pmm_manager>
ffffffffc0201f2e:	639c                	ld	a5,0(a5)
ffffffffc0201f30:	0287b303          	ld	t1,40(a5)
ffffffffc0201f34:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f36:	1141                	addi	sp,sp,-16
ffffffffc0201f38:	e406                	sd	ra,8(sp)
ffffffffc0201f3a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f3c:	f16fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f40:	000ab797          	auipc	a5,0xab
ffffffffc0201f44:	95078793          	addi	a5,a5,-1712 # ffffffffc02ac890 <pmm_manager>
ffffffffc0201f48:	639c                	ld	a5,0(a5)
ffffffffc0201f4a:	779c                	ld	a5,40(a5)
ffffffffc0201f4c:	9782                	jalr	a5
ffffffffc0201f4e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f50:	efcfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f54:	8522                	mv	a0,s0
ffffffffc0201f56:	60a2                	ld	ra,8(sp)
ffffffffc0201f58:	6402                	ld	s0,0(sp)
ffffffffc0201f5a:	0141                	addi	sp,sp,16
ffffffffc0201f5c:	8082                	ret

ffffffffc0201f5e <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f5e:	7139                	addi	sp,sp,-64
ffffffffc0201f60:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f62:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f66:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f6a:	048e                	slli	s1,s1,0x3
ffffffffc0201f6c:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f6e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f70:	f04a                	sd	s2,32(sp)
ffffffffc0201f72:	ec4e                	sd	s3,24(sp)
ffffffffc0201f74:	e852                	sd	s4,16(sp)
ffffffffc0201f76:	fc06                	sd	ra,56(sp)
ffffffffc0201f78:	f822                	sd	s0,48(sp)
ffffffffc0201f7a:	e456                	sd	s5,8(sp)
ffffffffc0201f7c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f7e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f82:	892e                	mv	s2,a1
ffffffffc0201f84:	8a32                	mv	s4,a2
ffffffffc0201f86:	000ab997          	auipc	s3,0xab
ffffffffc0201f8a:	8b298993          	addi	s3,s3,-1870 # ffffffffc02ac838 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f8e:	e7bd                	bnez	a5,ffffffffc0201ffc <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f90:	12060c63          	beqz	a2,ffffffffc02020c8 <get_pte+0x16a>
ffffffffc0201f94:	4505                	li	a0,1
ffffffffc0201f96:	ebbff0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0201f9a:	842a                	mv	s0,a0
ffffffffc0201f9c:	12050663          	beqz	a0,ffffffffc02020c8 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fa0:	000abb17          	auipc	s6,0xab
ffffffffc0201fa4:	908b0b13          	addi	s6,s6,-1784 # ffffffffc02ac8a8 <pages>
ffffffffc0201fa8:	000b3503          	ld	a0,0(s6)
ffffffffc0201fac:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb0:	000ab997          	auipc	s3,0xab
ffffffffc0201fb4:	88898993          	addi	s3,s3,-1912 # ffffffffc02ac838 <npage>
ffffffffc0201fb8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fbc:	8519                	srai	a0,a0,0x6
ffffffffc0201fbe:	9556                	add	a0,a0,s5
ffffffffc0201fc0:	0009b703          	ld	a4,0(s3)
ffffffffc0201fc4:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201fc8:	4685                	li	a3,1
ffffffffc0201fca:	c014                	sw	a3,0(s0)
ffffffffc0201fcc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fce:	0532                	slli	a0,a0,0xc
ffffffffc0201fd0:	14e7f363          	bgeu	a5,a4,ffffffffc0202116 <get_pte+0x1b8>
ffffffffc0201fd4:	000ab797          	auipc	a5,0xab
ffffffffc0201fd8:	8c478793          	addi	a5,a5,-1852 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0201fdc:	639c                	ld	a5,0(a5)
ffffffffc0201fde:	6605                	lui	a2,0x1
ffffffffc0201fe0:	4581                	li	a1,0
ffffffffc0201fe2:	953e                	add	a0,a0,a5
ffffffffc0201fe4:	5ee040ef          	jal	ra,ffffffffc02065d2 <memset>
    return page - pages + nbase;
ffffffffc0201fe8:	000b3683          	ld	a3,0(s6)
ffffffffc0201fec:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ff0:	8699                	srai	a3,a3,0x6
ffffffffc0201ff2:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ff4:	06aa                	slli	a3,a3,0xa
ffffffffc0201ff6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ffa:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ffc:	77fd                	lui	a5,0xfffff
ffffffffc0201ffe:	068a                	slli	a3,a3,0x2
ffffffffc0202000:	0009b703          	ld	a4,0(s3)
ffffffffc0202004:	8efd                	and	a3,a3,a5
ffffffffc0202006:	00c6d793          	srli	a5,a3,0xc
ffffffffc020200a:	0ce7f163          	bgeu	a5,a4,ffffffffc02020cc <get_pte+0x16e>
ffffffffc020200e:	000aba97          	auipc	s5,0xab
ffffffffc0202012:	88aa8a93          	addi	s5,s5,-1910 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0202016:	000ab403          	ld	s0,0(s5)
ffffffffc020201a:	01595793          	srli	a5,s2,0x15
ffffffffc020201e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202022:	96a2                	add	a3,a3,s0
ffffffffc0202024:	00379413          	slli	s0,a5,0x3
ffffffffc0202028:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020202a:	6014                	ld	a3,0(s0)
ffffffffc020202c:	0016f793          	andi	a5,a3,1
ffffffffc0202030:	e3ad                	bnez	a5,ffffffffc0202092 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202032:	080a0b63          	beqz	s4,ffffffffc02020c8 <get_pte+0x16a>
ffffffffc0202036:	4505                	li	a0,1
ffffffffc0202038:	e19ff0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020203c:	84aa                	mv	s1,a0
ffffffffc020203e:	c549                	beqz	a0,ffffffffc02020c8 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202040:	000abb17          	auipc	s6,0xab
ffffffffc0202044:	868b0b13          	addi	s6,s6,-1944 # ffffffffc02ac8a8 <pages>
ffffffffc0202048:	000b3503          	ld	a0,0(s6)
ffffffffc020204c:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202050:	0009b703          	ld	a4,0(s3)
ffffffffc0202054:	40a48533          	sub	a0,s1,a0
ffffffffc0202058:	8519                	srai	a0,a0,0x6
ffffffffc020205a:	9552                	add	a0,a0,s4
ffffffffc020205c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202060:	4685                	li	a3,1
ffffffffc0202062:	c094                	sw	a3,0(s1)
ffffffffc0202064:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202066:	0532                	slli	a0,a0,0xc
ffffffffc0202068:	08e7fa63          	bgeu	a5,a4,ffffffffc02020fc <get_pte+0x19e>
ffffffffc020206c:	000ab783          	ld	a5,0(s5)
ffffffffc0202070:	6605                	lui	a2,0x1
ffffffffc0202072:	4581                	li	a1,0
ffffffffc0202074:	953e                	add	a0,a0,a5
ffffffffc0202076:	55c040ef          	jal	ra,ffffffffc02065d2 <memset>
    return page - pages + nbase;
ffffffffc020207a:	000b3683          	ld	a3,0(s6)
ffffffffc020207e:	40d486b3          	sub	a3,s1,a3
ffffffffc0202082:	8699                	srai	a3,a3,0x6
ffffffffc0202084:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202086:	06aa                	slli	a3,a3,0xa
ffffffffc0202088:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020208c:	e014                	sd	a3,0(s0)
ffffffffc020208e:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202092:	068a                	slli	a3,a3,0x2
ffffffffc0202094:	757d                	lui	a0,0xfffff
ffffffffc0202096:	8ee9                	and	a3,a3,a0
ffffffffc0202098:	00c6d793          	srli	a5,a3,0xc
ffffffffc020209c:	04e7f463          	bgeu	a5,a4,ffffffffc02020e4 <get_pte+0x186>
ffffffffc02020a0:	000ab503          	ld	a0,0(s5)
ffffffffc02020a4:	00c95913          	srli	s2,s2,0xc
ffffffffc02020a8:	1ff97913          	andi	s2,s2,511
ffffffffc02020ac:	96aa                	add	a3,a3,a0
ffffffffc02020ae:	00391513          	slli	a0,s2,0x3
ffffffffc02020b2:	9536                	add	a0,a0,a3
}
ffffffffc02020b4:	70e2                	ld	ra,56(sp)
ffffffffc02020b6:	7442                	ld	s0,48(sp)
ffffffffc02020b8:	74a2                	ld	s1,40(sp)
ffffffffc02020ba:	7902                	ld	s2,32(sp)
ffffffffc02020bc:	69e2                	ld	s3,24(sp)
ffffffffc02020be:	6a42                	ld	s4,16(sp)
ffffffffc02020c0:	6aa2                	ld	s5,8(sp)
ffffffffc02020c2:	6b02                	ld	s6,0(sp)
ffffffffc02020c4:	6121                	addi	sp,sp,64
ffffffffc02020c6:	8082                	ret
            return NULL;
ffffffffc02020c8:	4501                	li	a0,0
ffffffffc02020ca:	b7ed                	j	ffffffffc02020b4 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020cc:	00005617          	auipc	a2,0x5
ffffffffc02020d0:	2cc60613          	addi	a2,a2,716 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc02020d4:	0e300593          	li	a1,227
ffffffffc02020d8:	00005517          	auipc	a0,0x5
ffffffffc02020dc:	3e050513          	addi	a0,a0,992 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02020e0:	ba0fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020e4:	00005617          	auipc	a2,0x5
ffffffffc02020e8:	2b460613          	addi	a2,a2,692 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc02020ec:	0ee00593          	li	a1,238
ffffffffc02020f0:	00005517          	auipc	a0,0x5
ffffffffc02020f4:	3c850513          	addi	a0,a0,968 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02020f8:	b88fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020fc:	86aa                	mv	a3,a0
ffffffffc02020fe:	00005617          	auipc	a2,0x5
ffffffffc0202102:	29a60613          	addi	a2,a2,666 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202106:	0eb00593          	li	a1,235
ffffffffc020210a:	00005517          	auipc	a0,0x5
ffffffffc020210e:	3ae50513          	addi	a0,a0,942 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202112:	b6efe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202116:	86aa                	mv	a3,a0
ffffffffc0202118:	00005617          	auipc	a2,0x5
ffffffffc020211c:	28060613          	addi	a2,a2,640 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202120:	0df00593          	li	a1,223
ffffffffc0202124:	00005517          	auipc	a0,0x5
ffffffffc0202128:	39450513          	addi	a0,a0,916 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc020212c:	b54fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0202130 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202130:	1141                	addi	sp,sp,-16
ffffffffc0202132:	e022                	sd	s0,0(sp)
ffffffffc0202134:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202136:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202138:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020213a:	e25ff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
    if (ptep_store != NULL) {
ffffffffc020213e:	c011                	beqz	s0,ffffffffc0202142 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202140:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202142:	c511                	beqz	a0,ffffffffc020214e <get_page+0x1e>
ffffffffc0202144:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202146:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202148:	0017f713          	andi	a4,a5,1
ffffffffc020214c:	e709                	bnez	a4,ffffffffc0202156 <get_page+0x26>
}
ffffffffc020214e:	60a2                	ld	ra,8(sp)
ffffffffc0202150:	6402                	ld	s0,0(sp)
ffffffffc0202152:	0141                	addi	sp,sp,16
ffffffffc0202154:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202156:	000aa717          	auipc	a4,0xaa
ffffffffc020215a:	6e270713          	addi	a4,a4,1762 # ffffffffc02ac838 <npage>
ffffffffc020215e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202160:	078a                	slli	a5,a5,0x2
ffffffffc0202162:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202164:	02e7f063          	bgeu	a5,a4,ffffffffc0202184 <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0202168:	000aa717          	auipc	a4,0xaa
ffffffffc020216c:	74070713          	addi	a4,a4,1856 # ffffffffc02ac8a8 <pages>
ffffffffc0202170:	6308                	ld	a0,0(a4)
ffffffffc0202172:	60a2                	ld	ra,8(sp)
ffffffffc0202174:	6402                	ld	s0,0(sp)
ffffffffc0202176:	fff80737          	lui	a4,0xfff80
ffffffffc020217a:	97ba                	add	a5,a5,a4
ffffffffc020217c:	079a                	slli	a5,a5,0x6
ffffffffc020217e:	953e                	add	a0,a0,a5
ffffffffc0202180:	0141                	addi	sp,sp,16
ffffffffc0202182:	8082                	ret
ffffffffc0202184:	cb1ff0ef          	jal	ra,ffffffffc0201e34 <pa2page.part.4>

ffffffffc0202188 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202188:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020218a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020218e:	ec86                	sd	ra,88(sp)
ffffffffc0202190:	e8a2                	sd	s0,80(sp)
ffffffffc0202192:	e4a6                	sd	s1,72(sp)
ffffffffc0202194:	e0ca                	sd	s2,64(sp)
ffffffffc0202196:	fc4e                	sd	s3,56(sp)
ffffffffc0202198:	f852                	sd	s4,48(sp)
ffffffffc020219a:	f456                	sd	s5,40(sp)
ffffffffc020219c:	f05a                	sd	s6,32(sp)
ffffffffc020219e:	ec5e                	sd	s7,24(sp)
ffffffffc02021a0:	e862                	sd	s8,16(sp)
ffffffffc02021a2:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021a4:	03479713          	slli	a4,a5,0x34
ffffffffc02021a8:	eb71                	bnez	a4,ffffffffc020227c <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021aa:	002007b7          	lui	a5,0x200
ffffffffc02021ae:	842e                	mv	s0,a1
ffffffffc02021b0:	0af5e663          	bltu	a1,a5,ffffffffc020225c <unmap_range+0xd4>
ffffffffc02021b4:	8932                	mv	s2,a2
ffffffffc02021b6:	0ac5f363          	bgeu	a1,a2,ffffffffc020225c <unmap_range+0xd4>
ffffffffc02021ba:	4785                	li	a5,1
ffffffffc02021bc:	07fe                	slli	a5,a5,0x1f
ffffffffc02021be:	08c7ef63          	bltu	a5,a2,ffffffffc020225c <unmap_range+0xd4>
ffffffffc02021c2:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021c4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021c6:	000aac97          	auipc	s9,0xaa
ffffffffc02021ca:	672c8c93          	addi	s9,s9,1650 # ffffffffc02ac838 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ce:	000aac17          	auipc	s8,0xaa
ffffffffc02021d2:	6dac0c13          	addi	s8,s8,1754 # ffffffffc02ac8a8 <pages>
ffffffffc02021d6:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021da:	00200b37          	lui	s6,0x200
ffffffffc02021de:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021e2:	4601                	li	a2,0
ffffffffc02021e4:	85a2                	mv	a1,s0
ffffffffc02021e6:	854e                	mv	a0,s3
ffffffffc02021e8:	d77ff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc02021ec:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021ee:	cd21                	beqz	a0,ffffffffc0202246 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021f0:	611c                	ld	a5,0(a0)
ffffffffc02021f2:	e38d                	bnez	a5,ffffffffc0202214 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021f4:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021f6:	ff2466e3          	bltu	s0,s2,ffffffffc02021e2 <unmap_range+0x5a>
}
ffffffffc02021fa:	60e6                	ld	ra,88(sp)
ffffffffc02021fc:	6446                	ld	s0,80(sp)
ffffffffc02021fe:	64a6                	ld	s1,72(sp)
ffffffffc0202200:	6906                	ld	s2,64(sp)
ffffffffc0202202:	79e2                	ld	s3,56(sp)
ffffffffc0202204:	7a42                	ld	s4,48(sp)
ffffffffc0202206:	7aa2                	ld	s5,40(sp)
ffffffffc0202208:	7b02                	ld	s6,32(sp)
ffffffffc020220a:	6be2                	ld	s7,24(sp)
ffffffffc020220c:	6c42                	ld	s8,16(sp)
ffffffffc020220e:	6ca2                	ld	s9,8(sp)
ffffffffc0202210:	6125                	addi	sp,sp,96
ffffffffc0202212:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202214:	0017f713          	andi	a4,a5,1
ffffffffc0202218:	df71                	beqz	a4,ffffffffc02021f4 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc020221a:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020221e:	078a                	slli	a5,a5,0x2
ffffffffc0202220:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202222:	06e7fd63          	bgeu	a5,a4,ffffffffc020229c <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202226:	000c3503          	ld	a0,0(s8)
ffffffffc020222a:	97de                	add	a5,a5,s7
ffffffffc020222c:	079a                	slli	a5,a5,0x6
ffffffffc020222e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202230:	411c                	lw	a5,0(a0)
ffffffffc0202232:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202236:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202238:	cf11                	beqz	a4,ffffffffc0202254 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020223a:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020223e:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202242:	9452                	add	s0,s0,s4
ffffffffc0202244:	bf4d                	j	ffffffffc02021f6 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202246:	945a                	add	s0,s0,s6
ffffffffc0202248:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020224c:	d45d                	beqz	s0,ffffffffc02021fa <unmap_range+0x72>
ffffffffc020224e:	f9246ae3          	bltu	s0,s2,ffffffffc02021e2 <unmap_range+0x5a>
ffffffffc0202252:	b765                	j	ffffffffc02021fa <unmap_range+0x72>
            free_page(page);
ffffffffc0202254:	4585                	li	a1,1
ffffffffc0202256:	c83ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
ffffffffc020225a:	b7c5                	j	ffffffffc020223a <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc020225c:	00006697          	auipc	a3,0x6
ffffffffc0202260:	80468693          	addi	a3,a3,-2044 # ffffffffc0207a60 <default_pmm_manager+0x718>
ffffffffc0202264:	00005617          	auipc	a2,0x5
ffffffffc0202268:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020226c:	11000593          	li	a1,272
ffffffffc0202270:	00005517          	auipc	a0,0x5
ffffffffc0202274:	24850513          	addi	a0,a0,584 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202278:	a08fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020227c:	00005697          	auipc	a3,0x5
ffffffffc0202280:	7b468693          	addi	a3,a3,1972 # ffffffffc0207a30 <default_pmm_manager+0x6e8>
ffffffffc0202284:	00005617          	auipc	a2,0x5
ffffffffc0202288:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020228c:	10f00593          	li	a1,271
ffffffffc0202290:	00005517          	auipc	a0,0x5
ffffffffc0202294:	22850513          	addi	a0,a0,552 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202298:	9e8fe0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc020229c:	b99ff0ef          	jal	ra,ffffffffc0201e34 <pa2page.part.4>

ffffffffc02022a0 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022a0:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022a2:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022a6:	fc86                	sd	ra,120(sp)
ffffffffc02022a8:	f8a2                	sd	s0,112(sp)
ffffffffc02022aa:	f4a6                	sd	s1,104(sp)
ffffffffc02022ac:	f0ca                	sd	s2,96(sp)
ffffffffc02022ae:	ecce                	sd	s3,88(sp)
ffffffffc02022b0:	e8d2                	sd	s4,80(sp)
ffffffffc02022b2:	e4d6                	sd	s5,72(sp)
ffffffffc02022b4:	e0da                	sd	s6,64(sp)
ffffffffc02022b6:	fc5e                	sd	s7,56(sp)
ffffffffc02022b8:	f862                	sd	s8,48(sp)
ffffffffc02022ba:	f466                	sd	s9,40(sp)
ffffffffc02022bc:	f06a                	sd	s10,32(sp)
ffffffffc02022be:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022c0:	03479713          	slli	a4,a5,0x34
ffffffffc02022c4:	1c071163          	bnez	a4,ffffffffc0202486 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022c8:	002007b7          	lui	a5,0x200
ffffffffc02022cc:	20f5e563          	bltu	a1,a5,ffffffffc02024d6 <exit_range+0x236>
ffffffffc02022d0:	8b32                	mv	s6,a2
ffffffffc02022d2:	20c5f263          	bgeu	a1,a2,ffffffffc02024d6 <exit_range+0x236>
ffffffffc02022d6:	4785                	li	a5,1
ffffffffc02022d8:	07fe                	slli	a5,a5,0x1f
ffffffffc02022da:	1ec7ee63          	bltu	a5,a2,ffffffffc02024d6 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022de:	c00009b7          	lui	s3,0xc0000
ffffffffc02022e2:	400007b7          	lui	a5,0x40000
ffffffffc02022e6:	0135f9b3          	and	s3,a1,s3
ffffffffc02022ea:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022ec:	c0000337          	lui	t1,0xc0000
ffffffffc02022f0:	00698933          	add	s2,s3,t1
ffffffffc02022f4:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022f8:	1ff97913          	andi	s2,s2,511
ffffffffc02022fc:	8e2a                	mv	t3,a0
ffffffffc02022fe:	090e                	slli	s2,s2,0x3
ffffffffc0202300:	9972                	add	s2,s2,t3
ffffffffc0202302:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202306:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc020230a:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc020230c:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202310:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0202312:	000aad17          	auipc	s10,0xaa
ffffffffc0202316:	526d0d13          	addi	s10,s10,1318 # ffffffffc02ac838 <npage>
    return KADDR(page2pa(page));
ffffffffc020231a:	00cddd93          	srli	s11,s11,0xc
ffffffffc020231e:	000aa717          	auipc	a4,0xaa
ffffffffc0202322:	57a70713          	addi	a4,a4,1402 # ffffffffc02ac898 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202326:	000aae97          	auipc	t4,0xaa
ffffffffc020232a:	582e8e93          	addi	t4,t4,1410 # ffffffffc02ac8a8 <pages>
        if (pde1&PTE_V){
ffffffffc020232e:	e79d                	bnez	a5,ffffffffc020235c <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202330:	12098963          	beqz	s3,ffffffffc0202462 <exit_range+0x1c2>
ffffffffc0202334:	400007b7          	lui	a5,0x40000
ffffffffc0202338:	84ce                	mv	s1,s3
ffffffffc020233a:	97ce                	add	a5,a5,s3
ffffffffc020233c:	1369f363          	bgeu	s3,s6,ffffffffc0202462 <exit_range+0x1c2>
ffffffffc0202340:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202342:	00698933          	add	s2,s3,t1
ffffffffc0202346:	01e95913          	srli	s2,s2,0x1e
ffffffffc020234a:	1ff97913          	andi	s2,s2,511
ffffffffc020234e:	090e                	slli	s2,s2,0x3
ffffffffc0202350:	9972                	add	s2,s2,t3
ffffffffc0202352:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202356:	001bf793          	andi	a5,s7,1
ffffffffc020235a:	dbf9                	beqz	a5,ffffffffc0202330 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc020235c:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202360:	0b8a                	slli	s7,s7,0x2
ffffffffc0202362:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202366:	14fbfc63          	bgeu	s7,a5,ffffffffc02024be <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020236a:	fff80ab7          	lui	s5,0xfff80
ffffffffc020236e:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202370:	000806b7          	lui	a3,0x80
ffffffffc0202374:	96d6                	add	a3,a3,s5
ffffffffc0202376:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc020237a:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020237e:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202380:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202382:	12f67263          	bgeu	a2,a5,ffffffffc02024a6 <exit_range+0x206>
ffffffffc0202386:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc020238a:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc020238c:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202390:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0202392:	00080837          	lui	a6,0x80
ffffffffc0202396:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202398:	00200c37          	lui	s8,0x200
ffffffffc020239c:	a801                	j	ffffffffc02023ac <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020239e:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023a0:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023a2:	c0d9                	beqz	s1,ffffffffc0202428 <exit_range+0x188>
ffffffffc02023a4:	0934f263          	bgeu	s1,s3,ffffffffc0202428 <exit_range+0x188>
ffffffffc02023a8:	0d64fc63          	bgeu	s1,s6,ffffffffc0202480 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023ac:	0154d413          	srli	s0,s1,0x15
ffffffffc02023b0:	1ff47413          	andi	s0,s0,511
ffffffffc02023b4:	040e                	slli	s0,s0,0x3
ffffffffc02023b6:	9452                	add	s0,s0,s4
ffffffffc02023b8:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023ba:	0017f693          	andi	a3,a5,1
ffffffffc02023be:	d2e5                	beqz	a3,ffffffffc020239e <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023c0:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c4:	00279513          	slli	a0,a5,0x2
ffffffffc02023c8:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ca:	0eb57a63          	bgeu	a0,a1,ffffffffc02024be <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ce:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023d0:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023d4:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023d8:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023da:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023dc:	0cb7f563          	bgeu	a5,a1,ffffffffc02024a6 <exit_range+0x206>
ffffffffc02023e0:	631c                	ld	a5,0(a4)
ffffffffc02023e2:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023e4:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023e8:	629c                	ld	a5,0(a3)
ffffffffc02023ea:	8b85                	andi	a5,a5,1
ffffffffc02023ec:	fbd5                	bnez	a5,ffffffffc02023a0 <exit_range+0x100>
ffffffffc02023ee:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023f0:	fed59ce3          	bne	a1,a3,ffffffffc02023e8 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f4:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023f8:	4585                	li	a1,1
ffffffffc02023fa:	e072                	sd	t3,0(sp)
ffffffffc02023fc:	953e                	add	a0,a0,a5
ffffffffc02023fe:	adbff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
                d0start += PTSIZE;
ffffffffc0202402:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202404:	00043023          	sd	zero,0(s0)
ffffffffc0202408:	000aae97          	auipc	t4,0xaa
ffffffffc020240c:	4a0e8e93          	addi	t4,t4,1184 # ffffffffc02ac8a8 <pages>
ffffffffc0202410:	6e02                	ld	t3,0(sp)
ffffffffc0202412:	c0000337          	lui	t1,0xc0000
ffffffffc0202416:	fff808b7          	lui	a7,0xfff80
ffffffffc020241a:	00080837          	lui	a6,0x80
ffffffffc020241e:	000aa717          	auipc	a4,0xaa
ffffffffc0202422:	47a70713          	addi	a4,a4,1146 # ffffffffc02ac898 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202426:	fcbd                	bnez	s1,ffffffffc02023a4 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202428:	f00c84e3          	beqz	s9,ffffffffc0202330 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc020242c:	000d3783          	ld	a5,0(s10)
ffffffffc0202430:	e072                	sd	t3,0(sp)
ffffffffc0202432:	08fbf663          	bgeu	s7,a5,ffffffffc02024be <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202436:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc020243a:	67a2                	ld	a5,8(sp)
ffffffffc020243c:	4585                	li	a1,1
ffffffffc020243e:	953e                	add	a0,a0,a5
ffffffffc0202440:	a99ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202444:	00093023          	sd	zero,0(s2)
ffffffffc0202448:	000aa717          	auipc	a4,0xaa
ffffffffc020244c:	45070713          	addi	a4,a4,1104 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0202450:	c0000337          	lui	t1,0xc0000
ffffffffc0202454:	6e02                	ld	t3,0(sp)
ffffffffc0202456:	000aae97          	auipc	t4,0xaa
ffffffffc020245a:	452e8e93          	addi	t4,t4,1106 # ffffffffc02ac8a8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020245e:	ec099be3          	bnez	s3,ffffffffc0202334 <exit_range+0x94>
}
ffffffffc0202462:	70e6                	ld	ra,120(sp)
ffffffffc0202464:	7446                	ld	s0,112(sp)
ffffffffc0202466:	74a6                	ld	s1,104(sp)
ffffffffc0202468:	7906                	ld	s2,96(sp)
ffffffffc020246a:	69e6                	ld	s3,88(sp)
ffffffffc020246c:	6a46                	ld	s4,80(sp)
ffffffffc020246e:	6aa6                	ld	s5,72(sp)
ffffffffc0202470:	6b06                	ld	s6,64(sp)
ffffffffc0202472:	7be2                	ld	s7,56(sp)
ffffffffc0202474:	7c42                	ld	s8,48(sp)
ffffffffc0202476:	7ca2                	ld	s9,40(sp)
ffffffffc0202478:	7d02                	ld	s10,32(sp)
ffffffffc020247a:	6de2                	ld	s11,24(sp)
ffffffffc020247c:	6109                	addi	sp,sp,128
ffffffffc020247e:	8082                	ret
            if (free_pd0) {
ffffffffc0202480:	ea0c8ae3          	beqz	s9,ffffffffc0202334 <exit_range+0x94>
ffffffffc0202484:	b765                	j	ffffffffc020242c <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202486:	00005697          	auipc	a3,0x5
ffffffffc020248a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0207a30 <default_pmm_manager+0x6e8>
ffffffffc020248e:	00004617          	auipc	a2,0x4
ffffffffc0202492:	77260613          	addi	a2,a2,1906 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202496:	12000593          	li	a1,288
ffffffffc020249a:	00005517          	auipc	a0,0x5
ffffffffc020249e:	01e50513          	addi	a0,a0,30 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02024a2:	fdffd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024a6:	00005617          	auipc	a2,0x5
ffffffffc02024aa:	ef260613          	addi	a2,a2,-270 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc02024ae:	06900593          	li	a1,105
ffffffffc02024b2:	00005517          	auipc	a0,0x5
ffffffffc02024b6:	f0e50513          	addi	a0,a0,-242 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02024ba:	fc7fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024be:	00005617          	auipc	a2,0x5
ffffffffc02024c2:	f3a60613          	addi	a2,a2,-198 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc02024c6:	06200593          	li	a1,98
ffffffffc02024ca:	00005517          	auipc	a0,0x5
ffffffffc02024ce:	ef650513          	addi	a0,a0,-266 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02024d2:	faffd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024d6:	00005697          	auipc	a3,0x5
ffffffffc02024da:	58a68693          	addi	a3,a3,1418 # ffffffffc0207a60 <default_pmm_manager+0x718>
ffffffffc02024de:	00004617          	auipc	a2,0x4
ffffffffc02024e2:	72260613          	addi	a2,a2,1826 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02024e6:	12100593          	li	a1,289
ffffffffc02024ea:	00005517          	auipc	a0,0x5
ffffffffc02024ee:	fce50513          	addi	a0,a0,-50 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02024f2:	f8ffd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02024f6 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024f6:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024f8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024fa:	e426                	sd	s1,8(sp)
ffffffffc02024fc:	ec06                	sd	ra,24(sp)
ffffffffc02024fe:	e822                	sd	s0,16(sp)
ffffffffc0202500:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202502:	a5dff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
    if (ptep != NULL) {
ffffffffc0202506:	c511                	beqz	a0,ffffffffc0202512 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202508:	611c                	ld	a5,0(a0)
ffffffffc020250a:	842a                	mv	s0,a0
ffffffffc020250c:	0017f713          	andi	a4,a5,1
ffffffffc0202510:	e711                	bnez	a4,ffffffffc020251c <page_remove+0x26>
}
ffffffffc0202512:	60e2                	ld	ra,24(sp)
ffffffffc0202514:	6442                	ld	s0,16(sp)
ffffffffc0202516:	64a2                	ld	s1,8(sp)
ffffffffc0202518:	6105                	addi	sp,sp,32
ffffffffc020251a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020251c:	000aa717          	auipc	a4,0xaa
ffffffffc0202520:	31c70713          	addi	a4,a4,796 # ffffffffc02ac838 <npage>
ffffffffc0202524:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202526:	078a                	slli	a5,a5,0x2
ffffffffc0202528:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020252a:	02e7fe63          	bgeu	a5,a4,ffffffffc0202566 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020252e:	000aa717          	auipc	a4,0xaa
ffffffffc0202532:	37a70713          	addi	a4,a4,890 # ffffffffc02ac8a8 <pages>
ffffffffc0202536:	6308                	ld	a0,0(a4)
ffffffffc0202538:	fff80737          	lui	a4,0xfff80
ffffffffc020253c:	97ba                	add	a5,a5,a4
ffffffffc020253e:	079a                	slli	a5,a5,0x6
ffffffffc0202540:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202542:	411c                	lw	a5,0(a0)
ffffffffc0202544:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202548:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020254a:	cb11                	beqz	a4,ffffffffc020255e <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020254c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202550:	12048073          	sfence.vma	s1
}
ffffffffc0202554:	60e2                	ld	ra,24(sp)
ffffffffc0202556:	6442                	ld	s0,16(sp)
ffffffffc0202558:	64a2                	ld	s1,8(sp)
ffffffffc020255a:	6105                	addi	sp,sp,32
ffffffffc020255c:	8082                	ret
            free_page(page);
ffffffffc020255e:	4585                	li	a1,1
ffffffffc0202560:	979ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
ffffffffc0202564:	b7e5                	j	ffffffffc020254c <page_remove+0x56>
ffffffffc0202566:	8cfff0ef          	jal	ra,ffffffffc0201e34 <pa2page.part.4>

ffffffffc020256a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020256a:	7179                	addi	sp,sp,-48
ffffffffc020256c:	e44e                	sd	s3,8(sp)
ffffffffc020256e:	89b2                	mv	s3,a2
ffffffffc0202570:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202572:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202574:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202576:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202578:	ec26                	sd	s1,24(sp)
ffffffffc020257a:	f406                	sd	ra,40(sp)
ffffffffc020257c:	e84a                	sd	s2,16(sp)
ffffffffc020257e:	e052                	sd	s4,0(sp)
ffffffffc0202580:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202582:	9ddff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
    if (ptep == NULL) {
ffffffffc0202586:	cd49                	beqz	a0,ffffffffc0202620 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202588:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020258a:	611c                	ld	a5,0(a0)
ffffffffc020258c:	892a                	mv	s2,a0
ffffffffc020258e:	0016871b          	addiw	a4,a3,1
ffffffffc0202592:	c018                	sw	a4,0(s0)
ffffffffc0202594:	0017f713          	andi	a4,a5,1
ffffffffc0202598:	ef05                	bnez	a4,ffffffffc02025d0 <page_insert+0x66>
ffffffffc020259a:	000aa797          	auipc	a5,0xaa
ffffffffc020259e:	30e78793          	addi	a5,a5,782 # ffffffffc02ac8a8 <pages>
ffffffffc02025a2:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025a4:	8c19                	sub	s0,s0,a4
ffffffffc02025a6:	000806b7          	lui	a3,0x80
ffffffffc02025aa:	8419                	srai	s0,s0,0x6
ffffffffc02025ac:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025ae:	042a                	slli	s0,s0,0xa
ffffffffc02025b0:	8c45                	or	s0,s0,s1
ffffffffc02025b2:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025b6:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ba:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025be:	4501                	li	a0,0
}
ffffffffc02025c0:	70a2                	ld	ra,40(sp)
ffffffffc02025c2:	7402                	ld	s0,32(sp)
ffffffffc02025c4:	64e2                	ld	s1,24(sp)
ffffffffc02025c6:	6942                	ld	s2,16(sp)
ffffffffc02025c8:	69a2                	ld	s3,8(sp)
ffffffffc02025ca:	6a02                	ld	s4,0(sp)
ffffffffc02025cc:	6145                	addi	sp,sp,48
ffffffffc02025ce:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025d0:	000aa717          	auipc	a4,0xaa
ffffffffc02025d4:	26870713          	addi	a4,a4,616 # ffffffffc02ac838 <npage>
ffffffffc02025d8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025da:	078a                	slli	a5,a5,0x2
ffffffffc02025dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025de:	04e7f363          	bgeu	a5,a4,ffffffffc0202624 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025e2:	000aaa17          	auipc	s4,0xaa
ffffffffc02025e6:	2c6a0a13          	addi	s4,s4,710 # ffffffffc02ac8a8 <pages>
ffffffffc02025ea:	000a3703          	ld	a4,0(s4)
ffffffffc02025ee:	fff80537          	lui	a0,0xfff80
ffffffffc02025f2:	953e                	add	a0,a0,a5
ffffffffc02025f4:	051a                	slli	a0,a0,0x6
ffffffffc02025f6:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025f8:	00a40a63          	beq	s0,a0,ffffffffc020260c <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025fc:	411c                	lw	a5,0(a0)
ffffffffc02025fe:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202602:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202604:	c691                	beqz	a3,ffffffffc0202610 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202606:	12098073          	sfence.vma	s3
ffffffffc020260a:	bf69                	j	ffffffffc02025a4 <page_insert+0x3a>
ffffffffc020260c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020260e:	bf59                	j	ffffffffc02025a4 <page_insert+0x3a>
            free_page(page);
ffffffffc0202610:	4585                	li	a1,1
ffffffffc0202612:	8c7ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
ffffffffc0202616:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020261a:	12098073          	sfence.vma	s3
ffffffffc020261e:	b759                	j	ffffffffc02025a4 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202620:	5571                	li	a0,-4
ffffffffc0202622:	bf79                	j	ffffffffc02025c0 <page_insert+0x56>
ffffffffc0202624:	811ff0ef          	jal	ra,ffffffffc0201e34 <pa2page.part.4>

ffffffffc0202628 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202628:	00005797          	auipc	a5,0x5
ffffffffc020262c:	d2078793          	addi	a5,a5,-736 # ffffffffc0207348 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202630:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202632:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202634:	00005517          	auipc	a0,0x5
ffffffffc0202638:	eac50513          	addi	a0,a0,-340 # ffffffffc02074e0 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc020263c:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020263e:	000aa717          	auipc	a4,0xaa
ffffffffc0202642:	24f73923          	sd	a5,594(a4) # ffffffffc02ac890 <pmm_manager>
void pmm_init(void) {
ffffffffc0202646:	e0a2                	sd	s0,64(sp)
ffffffffc0202648:	fc26                	sd	s1,56(sp)
ffffffffc020264a:	f84a                	sd	s2,48(sp)
ffffffffc020264c:	f44e                	sd	s3,40(sp)
ffffffffc020264e:	f052                	sd	s4,32(sp)
ffffffffc0202650:	ec56                	sd	s5,24(sp)
ffffffffc0202652:	e85a                	sd	s6,16(sp)
ffffffffc0202654:	e45e                	sd	s7,8(sp)
ffffffffc0202656:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202658:	000aa417          	auipc	s0,0xaa
ffffffffc020265c:	23840413          	addi	s0,s0,568 # ffffffffc02ac890 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202660:	b2ffd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202664:	601c                	ld	a5,0(s0)
ffffffffc0202666:	000aa497          	auipc	s1,0xaa
ffffffffc020266a:	1d248493          	addi	s1,s1,466 # ffffffffc02ac838 <npage>
ffffffffc020266e:	000aa917          	auipc	s2,0xaa
ffffffffc0202672:	23a90913          	addi	s2,s2,570 # ffffffffc02ac8a8 <pages>
ffffffffc0202676:	679c                	ld	a5,8(a5)
ffffffffc0202678:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020267a:	57f5                	li	a5,-3
ffffffffc020267c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020267e:	00005517          	auipc	a0,0x5
ffffffffc0202682:	e7a50513          	addi	a0,a0,-390 # ffffffffc02074f8 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202686:	000aa717          	auipc	a4,0xaa
ffffffffc020268a:	20f73923          	sd	a5,530(a4) # ffffffffc02ac898 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020268e:	b01fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202692:	46c5                	li	a3,17
ffffffffc0202694:	06ee                	slli	a3,a3,0x1b
ffffffffc0202696:	40100613          	li	a2,1025
ffffffffc020269a:	16fd                	addi	a3,a3,-1
ffffffffc020269c:	0656                	slli	a2,a2,0x15
ffffffffc020269e:	07e005b7          	lui	a1,0x7e00
ffffffffc02026a2:	00005517          	auipc	a0,0x5
ffffffffc02026a6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0207510 <default_pmm_manager+0x1c8>
ffffffffc02026aa:	ae5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026ae:	777d                	lui	a4,0xfffff
ffffffffc02026b0:	000ab797          	auipc	a5,0xab
ffffffffc02026b4:	2ef78793          	addi	a5,a5,751 # ffffffffc02ad99f <end+0xfff>
ffffffffc02026b8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026ba:	00088737          	lui	a4,0x88
ffffffffc02026be:	000aa697          	auipc	a3,0xaa
ffffffffc02026c2:	16e6bd23          	sd	a4,378(a3) # ffffffffc02ac838 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c6:	000aa717          	auipc	a4,0xaa
ffffffffc02026ca:	1ef73123          	sd	a5,482(a4) # ffffffffc02ac8a8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026ce:	4701                	li	a4,0
ffffffffc02026d0:	4685                	li	a3,1
ffffffffc02026d2:	fff80837          	lui	a6,0xfff80
ffffffffc02026d6:	a019                	j	ffffffffc02026dc <pmm_init+0xb4>
ffffffffc02026d8:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026dc:	00671613          	slli	a2,a4,0x6
ffffffffc02026e0:	97b2                	add	a5,a5,a2
ffffffffc02026e2:	07a1                	addi	a5,a5,8
ffffffffc02026e4:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026e8:	6090                	ld	a2,0(s1)
ffffffffc02026ea:	0705                	addi	a4,a4,1
ffffffffc02026ec:	010607b3          	add	a5,a2,a6
ffffffffc02026f0:	fef764e3          	bltu	a4,a5,ffffffffc02026d8 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f4:	00093503          	ld	a0,0(s2)
ffffffffc02026f8:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026fc:	00661693          	slli	a3,a2,0x6
ffffffffc0202700:	97aa                	add	a5,a5,a0
ffffffffc0202702:	96be                	add	a3,a3,a5
ffffffffc0202704:	c02007b7          	lui	a5,0xc0200
ffffffffc0202708:	7af6eb63          	bltu	a3,a5,ffffffffc0202ebe <pmm_init+0x896>
ffffffffc020270c:	000aa997          	auipc	s3,0xaa
ffffffffc0202710:	18c98993          	addi	s3,s3,396 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0202714:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202718:	47c5                	li	a5,17
ffffffffc020271a:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020271c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020271e:	02f6f763          	bgeu	a3,a5,ffffffffc020274c <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202722:	6585                	lui	a1,0x1
ffffffffc0202724:	15fd                	addi	a1,a1,-1
ffffffffc0202726:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202728:	00c6d713          	srli	a4,a3,0xc
ffffffffc020272c:	48c77863          	bgeu	a4,a2,ffffffffc0202bbc <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0202730:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202732:	75fd                	lui	a1,0xfffff
ffffffffc0202734:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202736:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202738:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020273a:	40d786b3          	sub	a3,a5,a3
ffffffffc020273e:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202740:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202744:	953a                	add	a0,a0,a4
ffffffffc0202746:	9602                	jalr	a2
ffffffffc0202748:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020274c:	00005517          	auipc	a0,0x5
ffffffffc0202750:	dec50513          	addi	a0,a0,-532 # ffffffffc0207538 <default_pmm_manager+0x1f0>
ffffffffc0202754:	a3bfd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202758:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020275a:	000aa417          	auipc	s0,0xaa
ffffffffc020275e:	0d640413          	addi	s0,s0,214 # ffffffffc02ac830 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202762:	7b9c                	ld	a5,48(a5)
ffffffffc0202764:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202766:	00005517          	auipc	a0,0x5
ffffffffc020276a:	dea50513          	addi	a0,a0,-534 # ffffffffc0207550 <default_pmm_manager+0x208>
ffffffffc020276e:	a21fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202772:	00009697          	auipc	a3,0x9
ffffffffc0202776:	88e68693          	addi	a3,a3,-1906 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020277a:	000aa797          	auipc	a5,0xaa
ffffffffc020277e:	0ad7bb23          	sd	a3,182(a5) # ffffffffc02ac830 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202782:	c02007b7          	lui	a5,0xc0200
ffffffffc0202786:	10f6e8e3          	bltu	a3,a5,ffffffffc0203096 <pmm_init+0xa6e>
ffffffffc020278a:	0009b783          	ld	a5,0(s3)
ffffffffc020278e:	8e9d                	sub	a3,a3,a5
ffffffffc0202790:	000aa797          	auipc	a5,0xaa
ffffffffc0202794:	10d7b823          	sd	a3,272(a5) # ffffffffc02ac8a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202798:	f86ff0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020279c:	6098                	ld	a4,0(s1)
ffffffffc020279e:	c80007b7          	lui	a5,0xc8000
ffffffffc02027a2:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027a4:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a6:	0ce7e8e3          	bltu	a5,a4,ffffffffc0203076 <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027aa:	6008                	ld	a0,0(s0)
ffffffffc02027ac:	44050263          	beqz	a0,ffffffffc0202bf0 <pmm_init+0x5c8>
ffffffffc02027b0:	03451793          	slli	a5,a0,0x34
ffffffffc02027b4:	42079e63          	bnez	a5,ffffffffc0202bf0 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027b8:	4601                	li	a2,0
ffffffffc02027ba:	4581                	li	a1,0
ffffffffc02027bc:	975ff0ef          	jal	ra,ffffffffc0202130 <get_page>
ffffffffc02027c0:	78051b63          	bnez	a0,ffffffffc0202f56 <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027c4:	4505                	li	a0,1
ffffffffc02027c6:	e8aff0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc02027ca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027cc:	6008                	ld	a0,0(s0)
ffffffffc02027ce:	4681                	li	a3,0
ffffffffc02027d0:	4601                	li	a2,0
ffffffffc02027d2:	85d6                	mv	a1,s5
ffffffffc02027d4:	d97ff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc02027d8:	7a051f63          	bnez	a0,ffffffffc0202f96 <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4601                	li	a2,0
ffffffffc02027e0:	4581                	li	a1,0
ffffffffc02027e2:	f7cff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc02027e6:	78050863          	beqz	a0,ffffffffc0202f76 <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02027ea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027ec:	0017f713          	andi	a4,a5,1
ffffffffc02027f0:	3e070463          	beqz	a4,ffffffffc0202bd8 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02027f4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027f6:	078a                	slli	a5,a5,0x2
ffffffffc02027f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027fa:	3ce7f163          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fe:	00093683          	ld	a3,0(s2)
ffffffffc0202802:	fff80637          	lui	a2,0xfff80
ffffffffc0202806:	97b2                	add	a5,a5,a2
ffffffffc0202808:	079a                	slli	a5,a5,0x6
ffffffffc020280a:	97b6                	add	a5,a5,a3
ffffffffc020280c:	72fa9563          	bne	s5,a5,ffffffffc0202f36 <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc0202810:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0202814:	4785                	li	a5,1
ffffffffc0202816:	70fb9063          	bne	s7,a5,ffffffffc0202f16 <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020281a:	6008                	ld	a0,0(s0)
ffffffffc020281c:	76fd                	lui	a3,0xfffff
ffffffffc020281e:	611c                	ld	a5,0(a0)
ffffffffc0202820:	078a                	slli	a5,a5,0x2
ffffffffc0202822:	8ff5                	and	a5,a5,a3
ffffffffc0202824:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202828:	66e67e63          	bgeu	a2,a4,ffffffffc0202ea4 <pmm_init+0x87c>
ffffffffc020282c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202830:	97e2                	add	a5,a5,s8
ffffffffc0202832:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53660>
ffffffffc0202836:	0b0a                	slli	s6,s6,0x2
ffffffffc0202838:	00db7b33          	and	s6,s6,a3
ffffffffc020283c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202840:	56e7f863          	bgeu	a5,a4,ffffffffc0202db0 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202844:	4601                	li	a2,0
ffffffffc0202846:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202848:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020284a:	f14ff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020284e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202850:	55651063          	bne	a0,s6,ffffffffc0202d90 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc0202854:	4505                	li	a0,1
ffffffffc0202856:	dfaff0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc020285a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020285c:	6008                	ld	a0,0(s0)
ffffffffc020285e:	46d1                	li	a3,20
ffffffffc0202860:	6605                	lui	a2,0x1
ffffffffc0202862:	85da                	mv	a1,s6
ffffffffc0202864:	d07ff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc0202868:	50051463          	bnez	a0,ffffffffc0202d70 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	4601                	li	a2,0
ffffffffc0202870:	6585                	lui	a1,0x1
ffffffffc0202872:	eecff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc0202876:	4c050d63          	beqz	a0,ffffffffc0202d50 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc020287a:	611c                	ld	a5,0(a0)
ffffffffc020287c:	0107f713          	andi	a4,a5,16
ffffffffc0202880:	4a070863          	beqz	a4,ffffffffc0202d30 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc0202884:	8b91                	andi	a5,a5,4
ffffffffc0202886:	48078563          	beqz	a5,ffffffffc0202d10 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020288a:	6008                	ld	a0,0(s0)
ffffffffc020288c:	611c                	ld	a5,0(a0)
ffffffffc020288e:	8bc1                	andi	a5,a5,16
ffffffffc0202890:	46078063          	beqz	a5,ffffffffc0202cf0 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc0202894:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
ffffffffc0202898:	43779c63          	bne	a5,s7,ffffffffc0202cd0 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020289c:	4681                	li	a3,0
ffffffffc020289e:	6605                	lui	a2,0x1
ffffffffc02028a0:	85d6                	mv	a1,s5
ffffffffc02028a2:	cc9ff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc02028a6:	40051563          	bnez	a0,ffffffffc0202cb0 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc02028aa:	000aa703          	lw	a4,0(s5)
ffffffffc02028ae:	4789                	li	a5,2
ffffffffc02028b0:	3ef71063          	bne	a4,a5,ffffffffc0202c90 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc02028b4:	000b2783          	lw	a5,0(s6)
ffffffffc02028b8:	3a079c63          	bnez	a5,ffffffffc0202c70 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028bc:	6008                	ld	a0,0(s0)
ffffffffc02028be:	4601                	li	a2,0
ffffffffc02028c0:	6585                	lui	a1,0x1
ffffffffc02028c2:	e9cff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc02028c6:	38050563          	beqz	a0,ffffffffc0202c50 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ca:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028cc:	00177793          	andi	a5,a4,1
ffffffffc02028d0:	30078463          	beqz	a5,ffffffffc0202bd8 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02028d4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028d6:	00271793          	slli	a5,a4,0x2
ffffffffc02028da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028dc:	2ed7f063          	bgeu	a5,a3,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02028e0:	00093683          	ld	a3,0(s2)
ffffffffc02028e4:	fff80637          	lui	a2,0xfff80
ffffffffc02028e8:	97b2                	add	a5,a5,a2
ffffffffc02028ea:	079a                	slli	a5,a5,0x6
ffffffffc02028ec:	97b6                	add	a5,a5,a3
ffffffffc02028ee:	32fa9163          	bne	s5,a5,ffffffffc0202c10 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028f2:	8b41                	andi	a4,a4,16
ffffffffc02028f4:	70071163          	bnez	a4,ffffffffc0202ff6 <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028f8:	6008                	ld	a0,0(s0)
ffffffffc02028fa:	4581                	li	a1,0
ffffffffc02028fc:	bfbff0ef          	jal	ra,ffffffffc02024f6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202900:	000aa703          	lw	a4,0(s5)
ffffffffc0202904:	4785                	li	a5,1
ffffffffc0202906:	6cf71863          	bne	a4,a5,ffffffffc0202fd6 <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc020290a:	000b2783          	lw	a5,0(s6)
ffffffffc020290e:	6a079463          	bnez	a5,ffffffffc0202fb6 <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202912:	6008                	ld	a0,0(s0)
ffffffffc0202914:	6585                	lui	a1,0x1
ffffffffc0202916:	be1ff0ef          	jal	ra,ffffffffc02024f6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020291a:	000aa783          	lw	a5,0(s5)
ffffffffc020291e:	50079363          	bnez	a5,ffffffffc0202e24 <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc0202922:	000b2783          	lw	a5,0(s6)
ffffffffc0202926:	4c079f63          	bnez	a5,ffffffffc0202e04 <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020292a:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020292e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202930:	000b3783          	ld	a5,0(s6)
ffffffffc0202934:	078a                	slli	a5,a5,0x2
ffffffffc0202936:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202938:	28e7f263          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020293c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	97b6                	add	a5,a5,a3
ffffffffc0202946:	079a                	slli	a5,a5,0x6
ffffffffc0202948:	00f506b3          	add	a3,a0,a5
ffffffffc020294c:	4290                	lw	a2,0(a3)
ffffffffc020294e:	4685                	li	a3,1
ffffffffc0202950:	48d61a63          	bne	a2,a3,ffffffffc0202de4 <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc0202954:	8799                	srai	a5,a5,0x6
ffffffffc0202956:	00080ab7          	lui	s5,0x80
ffffffffc020295a:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc020295c:	00c79693          	slli	a3,a5,0xc
ffffffffc0202960:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202962:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202964:	46e6f363          	bgeu	a3,a4,ffffffffc0202dca <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202968:	0009b683          	ld	a3,0(s3)
ffffffffc020296c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020296e:	639c                	ld	a5,0(a5)
ffffffffc0202970:	078a                	slli	a5,a5,0x2
ffffffffc0202972:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202974:	24e7f463          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202978:	415787b3          	sub	a5,a5,s5
ffffffffc020297c:	079a                	slli	a5,a5,0x6
ffffffffc020297e:	953e                	add	a0,a0,a5
ffffffffc0202980:	4585                	li	a1,1
ffffffffc0202982:	d56ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202986:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020298a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298c:	078a                	slli	a5,a5,0x2
ffffffffc020298e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202990:	22e7f663          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	415787b3          	sub	a5,a5,s5
ffffffffc020299c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020299e:	953e                	add	a0,a0,a5
ffffffffc02029a0:	4585                	li	a1,1
ffffffffc02029a2:	d36ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029a6:	601c                	ld	a5,0(s0)
ffffffffc02029a8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029ac:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029b0:	d6eff0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc02029b4:	68aa1163          	bne	s4,a0,ffffffffc0203036 <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029b8:	00005517          	auipc	a0,0x5
ffffffffc02029bc:	ea850513          	addi	a0,a0,-344 # ffffffffc0207860 <default_pmm_manager+0x518>
ffffffffc02029c0:	fcefd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029c4:	d5aff0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029c8:	6098                	ld	a4,0(s1)
ffffffffc02029ca:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029ce:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029d0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029d4:	18d7f563          	bgeu	a5,a3,ffffffffc0202b5e <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d8:	83b1                	srli	a5,a5,0xc
ffffffffc02029da:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029dc:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e0:	1ae7f163          	bgeu	a5,a4,ffffffffc0202b82 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029e4:	7bfd                	lui	s7,0xfffff
ffffffffc02029e6:	6b05                	lui	s6,0x1
ffffffffc02029e8:	a029                	j	ffffffffc02029f2 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ea:	00cad713          	srli	a4,s5,0xc
ffffffffc02029ee:	18f77a63          	bgeu	a4,a5,ffffffffc0202b82 <pmm_init+0x55a>
ffffffffc02029f2:	0009b583          	ld	a1,0(s3)
ffffffffc02029f6:	4601                	li	a2,0
ffffffffc02029f8:	95d6                	add	a1,a1,s5
ffffffffc02029fa:	d64ff0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc02029fe:	16050263          	beqz	a0,ffffffffc0202b62 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a02:	611c                	ld	a5,0(a0)
ffffffffc0202a04:	078a                	slli	a5,a5,0x2
ffffffffc0202a06:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a0a:	19579963          	bne	a5,s5,ffffffffc0202b9c <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a0e:	609c                	ld	a5,0(s1)
ffffffffc0202a10:	9ada                	add	s5,s5,s6
ffffffffc0202a12:	6008                	ld	a0,0(s0)
ffffffffc0202a14:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a18:	fceae9e3          	bltu	s5,a4,ffffffffc02029ea <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a1c:	611c                	ld	a5,0(a0)
ffffffffc0202a1e:	62079c63          	bnez	a5,ffffffffc0203056 <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a22:	4505                	li	a0,1
ffffffffc0202a24:	c2cff0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0202a28:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a2a:	6008                	ld	a0,0(s0)
ffffffffc0202a2c:	4699                	li	a3,6
ffffffffc0202a2e:	10000613          	li	a2,256
ffffffffc0202a32:	85d6                	mv	a1,s5
ffffffffc0202a34:	b37ff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc0202a38:	1e051c63          	bnez	a0,ffffffffc0202c30 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0202a3c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a40:	4785                	li	a5,1
ffffffffc0202a42:	44f71163          	bne	a4,a5,ffffffffc0202e84 <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	6008                	ld	a0,0(s0)
ffffffffc0202a48:	6b05                	lui	s6,0x1
ffffffffc0202a4a:	4699                	li	a3,6
ffffffffc0202a4c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0202a50:	85d6                	mv	a1,s5
ffffffffc0202a52:	b19ff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc0202a56:	40051763          	bnez	a0,ffffffffc0202e64 <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0202a5a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a5e:	4789                	li	a5,2
ffffffffc0202a60:	3ef71263          	bne	a4,a5,ffffffffc0202e44 <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a64:	00005597          	auipc	a1,0x5
ffffffffc0202a68:	f3458593          	addi	a1,a1,-204 # ffffffffc0207998 <default_pmm_manager+0x650>
ffffffffc0202a6c:	10000513          	li	a0,256
ffffffffc0202a70:	309030ef          	jal	ra,ffffffffc0206578 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a74:	100b0593          	addi	a1,s6,256
ffffffffc0202a78:	10000513          	li	a0,256
ffffffffc0202a7c:	30f030ef          	jal	ra,ffffffffc020658a <strcmp>
ffffffffc0202a80:	44051b63          	bnez	a0,ffffffffc0202ed6 <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0202a84:	00093683          	ld	a3,0(s2)
ffffffffc0202a88:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a8c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a8e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a92:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a96:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a98:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a9c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa2:	10f77f63          	bgeu	a4,a5,ffffffffc0202bc0 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aa6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aaa:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aae:	96be                	add	a3,a3,a5
ffffffffc0202ab0:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3760>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ab4:	281030ef          	jal	ra,ffffffffc0206534 <strlen>
ffffffffc0202ab8:	54051f63          	bnez	a0,ffffffffc0203016 <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202abc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ac0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52660>
ffffffffc0202ac6:	068a                	slli	a3,a3,0x2
ffffffffc0202ac8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aca:	0ef6f963          	bgeu	a3,a5,ffffffffc0202bbc <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0202ace:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ad4:	0efb7663          	bgeu	s6,a5,ffffffffc0202bc0 <pmm_init+0x598>
ffffffffc0202ad8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202adc:	4585                	li	a1,1
ffffffffc0202ade:	8556                	mv	a0,s5
ffffffffc0202ae0:	99b6                	add	s3,s3,a3
ffffffffc0202ae2:	bf6ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202aea:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aec:	078a                	slli	a5,a5,0x2
ffffffffc0202aee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202af0:	0ce7f663          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af4:	00093503          	ld	a0,0(s2)
ffffffffc0202af8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202afc:	97ce                	add	a5,a5,s3
ffffffffc0202afe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	4585                	li	a1,1
ffffffffc0202b04:	bd4ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b08:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b0e:	078a                	slli	a5,a5,0x2
ffffffffc0202b10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b12:	0ae7f563          	bgeu	a5,a4,ffffffffc0202bbc <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b16:	00093503          	ld	a0,0(s2)
ffffffffc0202b1a:	97ce                	add	a5,a5,s3
ffffffffc0202b1c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b1e:	953e                	add	a0,a0,a5
ffffffffc0202b20:	4585                	li	a1,1
ffffffffc0202b22:	bb6ff0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b26:	601c                	ld	a5,0(s0)
ffffffffc0202b28:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b2c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b30:	beeff0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc0202b34:	3caa1163          	bne	s4,a0,ffffffffc0202ef6 <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b38:	00005517          	auipc	a0,0x5
ffffffffc0202b3c:	ed850513          	addi	a0,a0,-296 # ffffffffc0207a10 <default_pmm_manager+0x6c8>
ffffffffc0202b40:	e4efd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b44:	6406                	ld	s0,64(sp)
ffffffffc0202b46:	60a6                	ld	ra,72(sp)
ffffffffc0202b48:	74e2                	ld	s1,56(sp)
ffffffffc0202b4a:	7942                	ld	s2,48(sp)
ffffffffc0202b4c:	79a2                	ld	s3,40(sp)
ffffffffc0202b4e:	7a02                	ld	s4,32(sp)
ffffffffc0202b50:	6ae2                	ld	s5,24(sp)
ffffffffc0202b52:	6b42                	ld	s6,16(sp)
ffffffffc0202b54:	6ba2                	ld	s7,8(sp)
ffffffffc0202b56:	6c02                	ld	s8,0(sp)
ffffffffc0202b58:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b5a:	8daff06f          	j	ffffffffc0201c34 <kmalloc_init>
ffffffffc0202b5e:	6008                	ld	a0,0(s0)
ffffffffc0202b60:	bd75                	j	ffffffffc0202a1c <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b62:	00005697          	auipc	a3,0x5
ffffffffc0202b66:	d1e68693          	addi	a3,a3,-738 # ffffffffc0207880 <default_pmm_manager+0x538>
ffffffffc0202b6a:	00004617          	auipc	a2,0x4
ffffffffc0202b6e:	09660613          	addi	a2,a2,150 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202b72:	22700593          	li	a1,551
ffffffffc0202b76:	00005517          	auipc	a0,0x5
ffffffffc0202b7a:	94250513          	addi	a0,a0,-1726 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202b7e:	903fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b82:	86d6                	mv	a3,s5
ffffffffc0202b84:	00005617          	auipc	a2,0x5
ffffffffc0202b88:	81460613          	addi	a2,a2,-2028 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202b8c:	22700593          	li	a1,551
ffffffffc0202b90:	00005517          	auipc	a0,0x5
ffffffffc0202b94:	92850513          	addi	a0,a0,-1752 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202b98:	8e9fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b9c:	00005697          	auipc	a3,0x5
ffffffffc0202ba0:	d2468693          	addi	a3,a3,-732 # ffffffffc02078c0 <default_pmm_manager+0x578>
ffffffffc0202ba4:	00004617          	auipc	a2,0x4
ffffffffc0202ba8:	05c60613          	addi	a2,a2,92 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202bac:	22800593          	li	a1,552
ffffffffc0202bb0:	00005517          	auipc	a0,0x5
ffffffffc0202bb4:	90850513          	addi	a0,a0,-1784 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202bb8:	8c9fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202bbc:	a78ff0ef          	jal	ra,ffffffffc0201e34 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bc0:	00004617          	auipc	a2,0x4
ffffffffc0202bc4:	7d860613          	addi	a2,a2,2008 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202bc8:	06900593          	li	a1,105
ffffffffc0202bcc:	00004517          	auipc	a0,0x4
ffffffffc0202bd0:	7f450513          	addi	a0,a0,2036 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0202bd4:	8adfd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bd8:	00005617          	auipc	a2,0x5
ffffffffc0202bdc:	a7860613          	addi	a2,a2,-1416 # ffffffffc0207650 <default_pmm_manager+0x308>
ffffffffc0202be0:	07400593          	li	a1,116
ffffffffc0202be4:	00004517          	auipc	a0,0x4
ffffffffc0202be8:	7dc50513          	addi	a0,a0,2012 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0202bec:	895fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bf0:	00005697          	auipc	a3,0x5
ffffffffc0202bf4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0207590 <default_pmm_manager+0x248>
ffffffffc0202bf8:	00004617          	auipc	a2,0x4
ffffffffc0202bfc:	00860613          	addi	a2,a2,8 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202c00:	1eb00593          	li	a1,491
ffffffffc0202c04:	00005517          	auipc	a0,0x5
ffffffffc0202c08:	8b450513          	addi	a0,a0,-1868 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202c0c:	875fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c10:	00005697          	auipc	a3,0x5
ffffffffc0202c14:	a6868693          	addi	a3,a3,-1432 # ffffffffc0207678 <default_pmm_manager+0x330>
ffffffffc0202c18:	00004617          	auipc	a2,0x4
ffffffffc0202c1c:	fe860613          	addi	a2,a2,-24 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202c20:	20700593          	li	a1,519
ffffffffc0202c24:	00005517          	auipc	a0,0x5
ffffffffc0202c28:	89450513          	addi	a0,a0,-1900 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202c2c:	855fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c30:	00005697          	auipc	a3,0x5
ffffffffc0202c34:	cc068693          	addi	a3,a3,-832 # ffffffffc02078f0 <default_pmm_manager+0x5a8>
ffffffffc0202c38:	00004617          	auipc	a2,0x4
ffffffffc0202c3c:	fc860613          	addi	a2,a2,-56 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202c40:	23000593          	li	a1,560
ffffffffc0202c44:	00005517          	auipc	a0,0x5
ffffffffc0202c48:	87450513          	addi	a0,a0,-1932 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202c4c:	835fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c50:	00005697          	auipc	a3,0x5
ffffffffc0202c54:	ab868693          	addi	a3,a3,-1352 # ffffffffc0207708 <default_pmm_manager+0x3c0>
ffffffffc0202c58:	00004617          	auipc	a2,0x4
ffffffffc0202c5c:	fa860613          	addi	a2,a2,-88 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202c60:	20600593          	li	a1,518
ffffffffc0202c64:	00005517          	auipc	a0,0x5
ffffffffc0202c68:	85450513          	addi	a0,a0,-1964 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202c6c:	815fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c70:	00005697          	auipc	a3,0x5
ffffffffc0202c74:	b6068693          	addi	a3,a3,-1184 # ffffffffc02077d0 <default_pmm_manager+0x488>
ffffffffc0202c78:	00004617          	auipc	a2,0x4
ffffffffc0202c7c:	f8860613          	addi	a2,a2,-120 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202c80:	20500593          	li	a1,517
ffffffffc0202c84:	00005517          	auipc	a0,0x5
ffffffffc0202c88:	83450513          	addi	a0,a0,-1996 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202c8c:	ff4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c90:	00005697          	auipc	a3,0x5
ffffffffc0202c94:	b2868693          	addi	a3,a3,-1240 # ffffffffc02077b8 <default_pmm_manager+0x470>
ffffffffc0202c98:	00004617          	auipc	a2,0x4
ffffffffc0202c9c:	f6860613          	addi	a2,a2,-152 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202ca0:	20400593          	li	a1,516
ffffffffc0202ca4:	00005517          	auipc	a0,0x5
ffffffffc0202ca8:	81450513          	addi	a0,a0,-2028 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202cac:	fd4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cb0:	00005697          	auipc	a3,0x5
ffffffffc0202cb4:	ad868693          	addi	a3,a3,-1320 # ffffffffc0207788 <default_pmm_manager+0x440>
ffffffffc0202cb8:	00004617          	auipc	a2,0x4
ffffffffc0202cbc:	f4860613          	addi	a2,a2,-184 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202cc0:	20300593          	li	a1,515
ffffffffc0202cc4:	00004517          	auipc	a0,0x4
ffffffffc0202cc8:	7f450513          	addi	a0,a0,2036 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202ccc:	fb4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cd0:	00005697          	auipc	a3,0x5
ffffffffc0202cd4:	aa068693          	addi	a3,a3,-1376 # ffffffffc0207770 <default_pmm_manager+0x428>
ffffffffc0202cd8:	00004617          	auipc	a2,0x4
ffffffffc0202cdc:	f2860613          	addi	a2,a2,-216 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202ce0:	20100593          	li	a1,513
ffffffffc0202ce4:	00004517          	auipc	a0,0x4
ffffffffc0202ce8:	7d450513          	addi	a0,a0,2004 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202cec:	f94fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cf0:	00005697          	auipc	a3,0x5
ffffffffc0202cf4:	a6868693          	addi	a3,a3,-1432 # ffffffffc0207758 <default_pmm_manager+0x410>
ffffffffc0202cf8:	00004617          	auipc	a2,0x4
ffffffffc0202cfc:	f0860613          	addi	a2,a2,-248 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202d00:	20000593          	li	a1,512
ffffffffc0202d04:	00004517          	auipc	a0,0x4
ffffffffc0202d08:	7b450513          	addi	a0,a0,1972 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202d0c:	f74fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d10:	00005697          	auipc	a3,0x5
ffffffffc0202d14:	a3868693          	addi	a3,a3,-1480 # ffffffffc0207748 <default_pmm_manager+0x400>
ffffffffc0202d18:	00004617          	auipc	a2,0x4
ffffffffc0202d1c:	ee860613          	addi	a2,a2,-280 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202d20:	1ff00593          	li	a1,511
ffffffffc0202d24:	00004517          	auipc	a0,0x4
ffffffffc0202d28:	79450513          	addi	a0,a0,1940 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202d2c:	f54fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d30:	00005697          	auipc	a3,0x5
ffffffffc0202d34:	a0868693          	addi	a3,a3,-1528 # ffffffffc0207738 <default_pmm_manager+0x3f0>
ffffffffc0202d38:	00004617          	auipc	a2,0x4
ffffffffc0202d3c:	ec860613          	addi	a2,a2,-312 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202d40:	1fe00593          	li	a1,510
ffffffffc0202d44:	00004517          	auipc	a0,0x4
ffffffffc0202d48:	77450513          	addi	a0,a0,1908 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202d4c:	f34fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d50:	00005697          	auipc	a3,0x5
ffffffffc0202d54:	9b868693          	addi	a3,a3,-1608 # ffffffffc0207708 <default_pmm_manager+0x3c0>
ffffffffc0202d58:	00004617          	auipc	a2,0x4
ffffffffc0202d5c:	ea860613          	addi	a2,a2,-344 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202d60:	1fd00593          	li	a1,509
ffffffffc0202d64:	00004517          	auipc	a0,0x4
ffffffffc0202d68:	75450513          	addi	a0,a0,1876 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202d6c:	f14fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d70:	00005697          	auipc	a3,0x5
ffffffffc0202d74:	96068693          	addi	a3,a3,-1696 # ffffffffc02076d0 <default_pmm_manager+0x388>
ffffffffc0202d78:	00004617          	auipc	a2,0x4
ffffffffc0202d7c:	e8860613          	addi	a2,a2,-376 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202d80:	1fc00593          	li	a1,508
ffffffffc0202d84:	00004517          	auipc	a0,0x4
ffffffffc0202d88:	73450513          	addi	a0,a0,1844 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202d8c:	ef4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d90:	00005697          	auipc	a3,0x5
ffffffffc0202d94:	91868693          	addi	a3,a3,-1768 # ffffffffc02076a8 <default_pmm_manager+0x360>
ffffffffc0202d98:	00004617          	auipc	a2,0x4
ffffffffc0202d9c:	e6860613          	addi	a2,a2,-408 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202da0:	1f900593          	li	a1,505
ffffffffc0202da4:	00004517          	auipc	a0,0x4
ffffffffc0202da8:	71450513          	addi	a0,a0,1812 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202dac:	ed4fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202db0:	86da                	mv	a3,s6
ffffffffc0202db2:	00004617          	auipc	a2,0x4
ffffffffc0202db6:	5e660613          	addi	a2,a2,1510 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202dba:	1f800593          	li	a1,504
ffffffffc0202dbe:	00004517          	auipc	a0,0x4
ffffffffc0202dc2:	6fa50513          	addi	a0,a0,1786 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202dc6:	ebafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dca:	86be                	mv	a3,a5
ffffffffc0202dcc:	00004617          	auipc	a2,0x4
ffffffffc0202dd0:	5cc60613          	addi	a2,a2,1484 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202dd4:	06900593          	li	a1,105
ffffffffc0202dd8:	00004517          	auipc	a0,0x4
ffffffffc0202ddc:	5e850513          	addi	a0,a0,1512 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0202de0:	ea0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202de4:	00005697          	auipc	a3,0x5
ffffffffc0202de8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0207818 <default_pmm_manager+0x4d0>
ffffffffc0202dec:	00004617          	auipc	a2,0x4
ffffffffc0202df0:	e1460613          	addi	a2,a2,-492 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202df4:	21200593          	li	a1,530
ffffffffc0202df8:	00004517          	auipc	a0,0x4
ffffffffc0202dfc:	6c050513          	addi	a0,a0,1728 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202e00:	e80fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e04:	00005697          	auipc	a3,0x5
ffffffffc0202e08:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02077d0 <default_pmm_manager+0x488>
ffffffffc0202e0c:	00004617          	auipc	a2,0x4
ffffffffc0202e10:	df460613          	addi	a2,a2,-524 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202e14:	21000593          	li	a1,528
ffffffffc0202e18:	00004517          	auipc	a0,0x4
ffffffffc0202e1c:	6a050513          	addi	a0,a0,1696 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202e20:	e60fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e24:	00005697          	auipc	a3,0x5
ffffffffc0202e28:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0207800 <default_pmm_manager+0x4b8>
ffffffffc0202e2c:	00004617          	auipc	a2,0x4
ffffffffc0202e30:	dd460613          	addi	a2,a2,-556 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202e34:	20f00593          	li	a1,527
ffffffffc0202e38:	00004517          	auipc	a0,0x4
ffffffffc0202e3c:	68050513          	addi	a0,a0,1664 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202e40:	e40fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e44:	00005697          	auipc	a3,0x5
ffffffffc0202e48:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0207980 <default_pmm_manager+0x638>
ffffffffc0202e4c:	00004617          	auipc	a2,0x4
ffffffffc0202e50:	db460613          	addi	a2,a2,-588 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202e54:	23300593          	li	a1,563
ffffffffc0202e58:	00004517          	auipc	a0,0x4
ffffffffc0202e5c:	66050513          	addi	a0,a0,1632 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202e60:	e20fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e64:	00005697          	auipc	a3,0x5
ffffffffc0202e68:	adc68693          	addi	a3,a3,-1316 # ffffffffc0207940 <default_pmm_manager+0x5f8>
ffffffffc0202e6c:	00004617          	auipc	a2,0x4
ffffffffc0202e70:	d9460613          	addi	a2,a2,-620 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202e74:	23200593          	li	a1,562
ffffffffc0202e78:	00004517          	auipc	a0,0x4
ffffffffc0202e7c:	64050513          	addi	a0,a0,1600 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202e80:	e00fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e84:	00005697          	auipc	a3,0x5
ffffffffc0202e88:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207928 <default_pmm_manager+0x5e0>
ffffffffc0202e8c:	00004617          	auipc	a2,0x4
ffffffffc0202e90:	d7460613          	addi	a2,a2,-652 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202e94:	23100593          	li	a1,561
ffffffffc0202e98:	00004517          	auipc	a0,0x4
ffffffffc0202e9c:	62050513          	addi	a0,a0,1568 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202ea0:	de0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ea4:	86be                	mv	a3,a5
ffffffffc0202ea6:	00004617          	auipc	a2,0x4
ffffffffc0202eaa:	4f260613          	addi	a2,a2,1266 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0202eae:	1f700593          	li	a1,503
ffffffffc0202eb2:	00004517          	auipc	a0,0x4
ffffffffc0202eb6:	60650513          	addi	a0,a0,1542 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202eba:	dc6fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ebe:	00004617          	auipc	a2,0x4
ffffffffc0202ec2:	51260613          	addi	a2,a2,1298 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc0202ec6:	07f00593          	li	a1,127
ffffffffc0202eca:	00004517          	auipc	a0,0x4
ffffffffc0202ece:	5ee50513          	addi	a0,a0,1518 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202ed2:	daefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ed6:	00005697          	auipc	a3,0x5
ffffffffc0202eda:	ada68693          	addi	a3,a3,-1318 # ffffffffc02079b0 <default_pmm_manager+0x668>
ffffffffc0202ede:	00004617          	auipc	a2,0x4
ffffffffc0202ee2:	d2260613          	addi	a2,a2,-734 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202ee6:	23700593          	li	a1,567
ffffffffc0202eea:	00004517          	auipc	a0,0x4
ffffffffc0202eee:	5ce50513          	addi	a0,a0,1486 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202ef2:	d8efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ef6:	00005697          	auipc	a3,0x5
ffffffffc0202efa:	94a68693          	addi	a3,a3,-1718 # ffffffffc0207840 <default_pmm_manager+0x4f8>
ffffffffc0202efe:	00004617          	auipc	a2,0x4
ffffffffc0202f02:	d0260613          	addi	a2,a2,-766 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202f06:	24300593          	li	a1,579
ffffffffc0202f0a:	00004517          	auipc	a0,0x4
ffffffffc0202f0e:	5ae50513          	addi	a0,a0,1454 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202f12:	d6efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f16:	00004697          	auipc	a3,0x4
ffffffffc0202f1a:	77a68693          	addi	a3,a3,1914 # ffffffffc0207690 <default_pmm_manager+0x348>
ffffffffc0202f1e:	00004617          	auipc	a2,0x4
ffffffffc0202f22:	ce260613          	addi	a2,a2,-798 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202f26:	1f500593          	li	a1,501
ffffffffc0202f2a:	00004517          	auipc	a0,0x4
ffffffffc0202f2e:	58e50513          	addi	a0,a0,1422 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202f32:	d4efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f36:	00004697          	auipc	a3,0x4
ffffffffc0202f3a:	74268693          	addi	a3,a3,1858 # ffffffffc0207678 <default_pmm_manager+0x330>
ffffffffc0202f3e:	00004617          	auipc	a2,0x4
ffffffffc0202f42:	cc260613          	addi	a2,a2,-830 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202f46:	1f400593          	li	a1,500
ffffffffc0202f4a:	00004517          	auipc	a0,0x4
ffffffffc0202f4e:	56e50513          	addi	a0,a0,1390 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202f52:	d2efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f56:	00004697          	auipc	a3,0x4
ffffffffc0202f5a:	67268693          	addi	a3,a3,1650 # ffffffffc02075c8 <default_pmm_manager+0x280>
ffffffffc0202f5e:	00004617          	auipc	a2,0x4
ffffffffc0202f62:	ca260613          	addi	a2,a2,-862 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202f66:	1ec00593          	li	a1,492
ffffffffc0202f6a:	00004517          	auipc	a0,0x4
ffffffffc0202f6e:	54e50513          	addi	a0,a0,1358 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202f72:	d0efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f76:	00004697          	auipc	a3,0x4
ffffffffc0202f7a:	6aa68693          	addi	a3,a3,1706 # ffffffffc0207620 <default_pmm_manager+0x2d8>
ffffffffc0202f7e:	00004617          	auipc	a2,0x4
ffffffffc0202f82:	c8260613          	addi	a2,a2,-894 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202f86:	1f300593          	li	a1,499
ffffffffc0202f8a:	00004517          	auipc	a0,0x4
ffffffffc0202f8e:	52e50513          	addi	a0,a0,1326 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202f92:	ceefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f96:	00004697          	auipc	a3,0x4
ffffffffc0202f9a:	65a68693          	addi	a3,a3,1626 # ffffffffc02075f0 <default_pmm_manager+0x2a8>
ffffffffc0202f9e:	00004617          	auipc	a2,0x4
ffffffffc0202fa2:	c6260613          	addi	a2,a2,-926 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202fa6:	1f000593          	li	a1,496
ffffffffc0202faa:	00004517          	auipc	a0,0x4
ffffffffc0202fae:	50e50513          	addi	a0,a0,1294 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202fb2:	ccefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fb6:	00005697          	auipc	a3,0x5
ffffffffc0202fba:	81a68693          	addi	a3,a3,-2022 # ffffffffc02077d0 <default_pmm_manager+0x488>
ffffffffc0202fbe:	00004617          	auipc	a2,0x4
ffffffffc0202fc2:	c4260613          	addi	a2,a2,-958 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202fc6:	20c00593          	li	a1,524
ffffffffc0202fca:	00004517          	auipc	a0,0x4
ffffffffc0202fce:	4ee50513          	addi	a0,a0,1262 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202fd2:	caefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fd6:	00004697          	auipc	a3,0x4
ffffffffc0202fda:	6ba68693          	addi	a3,a3,1722 # ffffffffc0207690 <default_pmm_manager+0x348>
ffffffffc0202fde:	00004617          	auipc	a2,0x4
ffffffffc0202fe2:	c2260613          	addi	a2,a2,-990 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0202fe6:	20b00593          	li	a1,523
ffffffffc0202fea:	00004517          	auipc	a0,0x4
ffffffffc0202fee:	4ce50513          	addi	a0,a0,1230 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0202ff2:	c8efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ff6:	00004697          	auipc	a3,0x4
ffffffffc0202ffa:	7f268693          	addi	a3,a3,2034 # ffffffffc02077e8 <default_pmm_manager+0x4a0>
ffffffffc0202ffe:	00004617          	auipc	a2,0x4
ffffffffc0203002:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203006:	20800593          	li	a1,520
ffffffffc020300a:	00004517          	auipc	a0,0x4
ffffffffc020300e:	4ae50513          	addi	a0,a0,1198 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203012:	c6efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203016:	00005697          	auipc	a3,0x5
ffffffffc020301a:	9d268693          	addi	a3,a3,-1582 # ffffffffc02079e8 <default_pmm_manager+0x6a0>
ffffffffc020301e:	00004617          	auipc	a2,0x4
ffffffffc0203022:	be260613          	addi	a2,a2,-1054 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203026:	23a00593          	li	a1,570
ffffffffc020302a:	00004517          	auipc	a0,0x4
ffffffffc020302e:	48e50513          	addi	a0,a0,1166 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203032:	c4efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203036:	00005697          	auipc	a3,0x5
ffffffffc020303a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0207840 <default_pmm_manager+0x4f8>
ffffffffc020303e:	00004617          	auipc	a2,0x4
ffffffffc0203042:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203046:	21a00593          	li	a1,538
ffffffffc020304a:	00004517          	auipc	a0,0x4
ffffffffc020304e:	46e50513          	addi	a0,a0,1134 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203052:	c2efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203056:	00005697          	auipc	a3,0x5
ffffffffc020305a:	88268693          	addi	a3,a3,-1918 # ffffffffc02078d8 <default_pmm_manager+0x590>
ffffffffc020305e:	00004617          	auipc	a2,0x4
ffffffffc0203062:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203066:	22c00593          	li	a1,556
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	44e50513          	addi	a0,a0,1102 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203072:	c0efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203076:	00004697          	auipc	a3,0x4
ffffffffc020307a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0207570 <default_pmm_manager+0x228>
ffffffffc020307e:	00004617          	auipc	a2,0x4
ffffffffc0203082:	b8260613          	addi	a2,a2,-1150 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203086:	1ea00593          	li	a1,490
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	42e50513          	addi	a0,a0,1070 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203092:	beefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203096:	00004617          	auipc	a2,0x4
ffffffffc020309a:	33a60613          	addi	a2,a2,826 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc020309e:	0c100593          	li	a1,193
ffffffffc02030a2:	00004517          	auipc	a0,0x4
ffffffffc02030a6:	41650513          	addi	a0,a0,1046 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02030aa:	bd6fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02030ae <copy_range>:
               bool share) {
ffffffffc02030ae:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030b0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030b4:	f486                	sd	ra,104(sp)
ffffffffc02030b6:	f0a2                	sd	s0,96(sp)
ffffffffc02030b8:	eca6                	sd	s1,88(sp)
ffffffffc02030ba:	e8ca                	sd	s2,80(sp)
ffffffffc02030bc:	e4ce                	sd	s3,72(sp)
ffffffffc02030be:	e0d2                	sd	s4,64(sp)
ffffffffc02030c0:	fc56                	sd	s5,56(sp)
ffffffffc02030c2:	f85a                	sd	s6,48(sp)
ffffffffc02030c4:	f45e                	sd	s7,40(sp)
ffffffffc02030c6:	f062                	sd	s8,32(sp)
ffffffffc02030c8:	ec66                	sd	s9,24(sp)
ffffffffc02030ca:	e86a                	sd	s10,16(sp)
ffffffffc02030cc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030ce:	03479713          	slli	a4,a5,0x34
ffffffffc02030d2:	1e071863          	bnez	a4,ffffffffc02032c2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030d6:	002007b7          	lui	a5,0x200
ffffffffc02030da:	8432                	mv	s0,a2
ffffffffc02030dc:	16f66b63          	bltu	a2,a5,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e0:	84b6                	mv	s1,a3
ffffffffc02030e2:	16d67863          	bgeu	a2,a3,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e6:	4785                	li	a5,1
ffffffffc02030e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030ea:	16d7e463          	bltu	a5,a3,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030ee:	5a7d                	li	s4,-1
ffffffffc02030f0:	8aaa                	mv	s5,a0
ffffffffc02030f2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030f4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030f6:	000a9c17          	auipc	s8,0xa9
ffffffffc02030fa:	742c0c13          	addi	s8,s8,1858 # ffffffffc02ac838 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030fe:	000a9b97          	auipc	s7,0xa9
ffffffffc0203102:	7aab8b93          	addi	s7,s7,1962 # ffffffffc02ac8a8 <pages>
    return page - pages + nbase;
ffffffffc0203106:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020310a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	85a2                	mv	a1,s0
ffffffffc0203112:	854a                	mv	a0,s2
ffffffffc0203114:	e4bfe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc0203118:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020311a:	c17d                	beqz	a0,ffffffffc0203200 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	8b85                	andi	a5,a5,1
ffffffffc0203120:	e785                	bnez	a5,ffffffffc0203148 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203122:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203124:	fe9465e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
    return 0;
ffffffffc0203128:	4501                	li	a0,0
}
ffffffffc020312a:	70a6                	ld	ra,104(sp)
ffffffffc020312c:	7406                	ld	s0,96(sp)
ffffffffc020312e:	64e6                	ld	s1,88(sp)
ffffffffc0203130:	6946                	ld	s2,80(sp)
ffffffffc0203132:	69a6                	ld	s3,72(sp)
ffffffffc0203134:	6a06                	ld	s4,64(sp)
ffffffffc0203136:	7ae2                	ld	s5,56(sp)
ffffffffc0203138:	7b42                	ld	s6,48(sp)
ffffffffc020313a:	7ba2                	ld	s7,40(sp)
ffffffffc020313c:	7c02                	ld	s8,32(sp)
ffffffffc020313e:	6ce2                	ld	s9,24(sp)
ffffffffc0203140:	6d42                	ld	s10,16(sp)
ffffffffc0203142:	6da2                	ld	s11,8(sp)
ffffffffc0203144:	6165                	addi	sp,sp,112
ffffffffc0203146:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203148:	4605                	li	a2,1
ffffffffc020314a:	85a2                	mv	a1,s0
ffffffffc020314c:	8556                	mv	a0,s5
ffffffffc020314e:	e11fe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc0203152:	c169                	beqz	a0,ffffffffc0203214 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203154:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203158:	0017f713          	andi	a4,a5,1
ffffffffc020315c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203160:	14070563          	beqz	a4,ffffffffc02032aa <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203164:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203168:	078a                	slli	a5,a5,0x2
ffffffffc020316a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020316e:	12d77263          	bgeu	a4,a3,ffffffffc0203292 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203172:	000bb783          	ld	a5,0(s7)
ffffffffc0203176:	fff806b7          	lui	a3,0xfff80
ffffffffc020317a:	9736                	add	a4,a4,a3
ffffffffc020317c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020317e:	4505                	li	a0,1
ffffffffc0203180:	00e78db3          	add	s11,a5,a4
ffffffffc0203184:	ccdfe0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0203188:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020318a:	0a0d8463          	beqz	s11,ffffffffc0203232 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020318e:	c175                	beqz	a0,ffffffffc0203272 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203190:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203194:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203198:	40ed86b3          	sub	a3,s11,a4
ffffffffc020319c:	8699                	srai	a3,a3,0x6
ffffffffc020319e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031a0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031a6:	06c7fa63          	bgeu	a5,a2,ffffffffc020321a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031aa:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031ae:	000a9717          	auipc	a4,0xa9
ffffffffc02031b2:	6ea70713          	addi	a4,a4,1770 # ffffffffc02ac898 <va_pa_offset>
ffffffffc02031b6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031b8:	8799                	srai	a5,a5,0x6
ffffffffc02031ba:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031bc:	0147f733          	and	a4,a5,s4
ffffffffc02031c0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031c6:	04c77963          	bgeu	a4,a2,ffffffffc0203218 <copy_range+0x16a>
            memcpy(dst, src, PGSIZE);
ffffffffc02031ca:	6605                	lui	a2,0x1
ffffffffc02031cc:	953e                	add	a0,a0,a5
ffffffffc02031ce:	416030ef          	jal	ra,ffffffffc02065e4 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031d2:	86e6                	mv	a3,s9
ffffffffc02031d4:	8622                	mv	a2,s0
ffffffffc02031d6:	85ea                	mv	a1,s10
ffffffffc02031d8:	8556                	mv	a0,s5
ffffffffc02031da:	b90ff0ef          	jal	ra,ffffffffc020256a <page_insert>
            assert(ret == 0);
ffffffffc02031de:	d131                	beqz	a0,ffffffffc0203122 <copy_range+0x74>
ffffffffc02031e0:	00004697          	auipc	a3,0x4
ffffffffc02031e4:	2c868693          	addi	a3,a3,712 # ffffffffc02074a8 <default_pmm_manager+0x160>
ffffffffc02031e8:	00004617          	auipc	a2,0x4
ffffffffc02031ec:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02031f0:	18c00593          	li	a1,396
ffffffffc02031f4:	00004517          	auipc	a0,0x4
ffffffffc02031f8:	2c450513          	addi	a0,a0,708 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02031fc:	a84fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203200:	002007b7          	lui	a5,0x200
ffffffffc0203204:	943e                	add	s0,s0,a5
ffffffffc0203206:	ffe007b7          	lui	a5,0xffe00
ffffffffc020320a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020320c:	dc11                	beqz	s0,ffffffffc0203128 <copy_range+0x7a>
ffffffffc020320e:	f09460e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
ffffffffc0203212:	bf19                	j	ffffffffc0203128 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203214:	5571                	li	a0,-4
ffffffffc0203216:	bf11                	j	ffffffffc020312a <copy_range+0x7c>
ffffffffc0203218:	86be                	mv	a3,a5
ffffffffc020321a:	00004617          	auipc	a2,0x4
ffffffffc020321e:	17e60613          	addi	a2,a2,382 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0203222:	06900593          	li	a1,105
ffffffffc0203226:	00004517          	auipc	a0,0x4
ffffffffc020322a:	19a50513          	addi	a0,a0,410 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc020322e:	a52fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(page != NULL);
ffffffffc0203232:	00004697          	auipc	a3,0x4
ffffffffc0203236:	25668693          	addi	a3,a3,598 # ffffffffc0207488 <default_pmm_manager+0x140>
ffffffffc020323a:	00004617          	auipc	a2,0x4
ffffffffc020323e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203242:	17200593          	li	a1,370
ffffffffc0203246:	00004517          	auipc	a0,0x4
ffffffffc020324a:	27250513          	addi	a0,a0,626 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc020324e:	a32fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203252:	00005697          	auipc	a3,0x5
ffffffffc0203256:	80e68693          	addi	a3,a3,-2034 # ffffffffc0207a60 <default_pmm_manager+0x718>
ffffffffc020325a:	00004617          	auipc	a2,0x4
ffffffffc020325e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203262:	15e00593          	li	a1,350
ffffffffc0203266:	00004517          	auipc	a0,0x4
ffffffffc020326a:	25250513          	addi	a0,a0,594 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc020326e:	a12fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(npage != NULL);
ffffffffc0203272:	00004697          	auipc	a3,0x4
ffffffffc0203276:	22668693          	addi	a3,a3,550 # ffffffffc0207498 <default_pmm_manager+0x150>
ffffffffc020327a:	00004617          	auipc	a2,0x4
ffffffffc020327e:	98660613          	addi	a2,a2,-1658 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203282:	17300593          	li	a1,371
ffffffffc0203286:	00004517          	auipc	a0,0x4
ffffffffc020328a:	23250513          	addi	a0,a0,562 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc020328e:	9f2fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203292:	00004617          	auipc	a2,0x4
ffffffffc0203296:	16660613          	addi	a2,a2,358 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc020329a:	06200593          	li	a1,98
ffffffffc020329e:	00004517          	auipc	a0,0x4
ffffffffc02032a2:	12250513          	addi	a0,a0,290 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02032a6:	9dafd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032aa:	00004617          	auipc	a2,0x4
ffffffffc02032ae:	3a660613          	addi	a2,a2,934 # ffffffffc0207650 <default_pmm_manager+0x308>
ffffffffc02032b2:	07400593          	li	a1,116
ffffffffc02032b6:	00004517          	auipc	a0,0x4
ffffffffc02032ba:	10a50513          	addi	a0,a0,266 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02032be:	9c2fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c2:	00004697          	auipc	a3,0x4
ffffffffc02032c6:	76e68693          	addi	a3,a3,1902 # ffffffffc0207a30 <default_pmm_manager+0x6e8>
ffffffffc02032ca:	00004617          	auipc	a2,0x4
ffffffffc02032ce:	93660613          	addi	a2,a2,-1738 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02032d2:	15d00593          	li	a1,349
ffffffffc02032d6:	00004517          	auipc	a0,0x4
ffffffffc02032da:	1e250513          	addi	a0,a0,482 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc02032de:	9a2fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02032e2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032e2:	12058073          	sfence.vma	a1
}
ffffffffc02032e6:	8082                	ret

ffffffffc02032e8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032e8:	7179                	addi	sp,sp,-48
ffffffffc02032ea:	e84a                	sd	s2,16(sp)
ffffffffc02032ec:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032ee:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032f0:	f022                	sd	s0,32(sp)
ffffffffc02032f2:	ec26                	sd	s1,24(sp)
ffffffffc02032f4:	e44e                	sd	s3,8(sp)
ffffffffc02032f6:	f406                	sd	ra,40(sp)
ffffffffc02032f8:	84ae                	mv	s1,a1
ffffffffc02032fa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032fc:	b55fe0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0203300:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203302:	cd1d                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203304:	85aa                	mv	a1,a0
ffffffffc0203306:	86ce                	mv	a3,s3
ffffffffc0203308:	8626                	mv	a2,s1
ffffffffc020330a:	854a                	mv	a0,s2
ffffffffc020330c:	a5eff0ef          	jal	ra,ffffffffc020256a <page_insert>
ffffffffc0203310:	e121                	bnez	a0,ffffffffc0203350 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203312:	000a9797          	auipc	a5,0xa9
ffffffffc0203316:	53678793          	addi	a5,a5,1334 # ffffffffc02ac848 <swap_init_ok>
ffffffffc020331a:	439c                	lw	a5,0(a5)
ffffffffc020331c:	2781                	sext.w	a5,a5
ffffffffc020331e:	c38d                	beqz	a5,ffffffffc0203340 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0203320:	000a9797          	auipc	a5,0xa9
ffffffffc0203324:	66878793          	addi	a5,a5,1640 # ffffffffc02ac988 <check_mm_struct>
ffffffffc0203328:	6388                	ld	a0,0(a5)
ffffffffc020332a:	c919                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020332c:	4681                	li	a3,0
ffffffffc020332e:	8622                	mv	a2,s0
ffffffffc0203330:	85a6                	mv	a1,s1
ffffffffc0203332:	7da000ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203336:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203338:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020333a:	4785                	li	a5,1
ffffffffc020333c:	02f71063          	bne	a4,a5,ffffffffc020335c <pgdir_alloc_page+0x74>
}
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	70a2                	ld	ra,40(sp)
ffffffffc0203344:	7402                	ld	s0,32(sp)
ffffffffc0203346:	64e2                	ld	s1,24(sp)
ffffffffc0203348:	6942                	ld	s2,16(sp)
ffffffffc020334a:	69a2                	ld	s3,8(sp)
ffffffffc020334c:	6145                	addi	sp,sp,48
ffffffffc020334e:	8082                	ret
            free_page(page);
ffffffffc0203350:	8522                	mv	a0,s0
ffffffffc0203352:	4585                	li	a1,1
ffffffffc0203354:	b85fe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
            return NULL;
ffffffffc0203358:	4401                	li	s0,0
ffffffffc020335a:	b7dd                	j	ffffffffc0203340 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020335c:	00004697          	auipc	a3,0x4
ffffffffc0203360:	16c68693          	addi	a3,a3,364 # ffffffffc02074c8 <default_pmm_manager+0x180>
ffffffffc0203364:	00004617          	auipc	a2,0x4
ffffffffc0203368:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020336c:	1cb00593          	li	a1,459
ffffffffc0203370:	00004517          	auipc	a0,0x4
ffffffffc0203374:	14850513          	addi	a0,a0,328 # ffffffffc02074b8 <default_pmm_manager+0x170>
ffffffffc0203378:	908fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020337c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020337c:	7135                	addi	sp,sp,-160
ffffffffc020337e:	ed06                	sd	ra,152(sp)
ffffffffc0203380:	e922                	sd	s0,144(sp)
ffffffffc0203382:	e526                	sd	s1,136(sp)
ffffffffc0203384:	e14a                	sd	s2,128(sp)
ffffffffc0203386:	fcce                	sd	s3,120(sp)
ffffffffc0203388:	f8d2                	sd	s4,112(sp)
ffffffffc020338a:	f4d6                	sd	s5,104(sp)
ffffffffc020338c:	f0da                	sd	s6,96(sp)
ffffffffc020338e:	ecde                	sd	s7,88(sp)
ffffffffc0203390:	e8e2                	sd	s8,80(sp)
ffffffffc0203392:	e4e6                	sd	s9,72(sp)
ffffffffc0203394:	e0ea                	sd	s10,64(sp)
ffffffffc0203396:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203398:	7a0010ef          	jal	ra,ffffffffc0204b38 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020339c:	000a9797          	auipc	a5,0xa9
ffffffffc02033a0:	59c78793          	addi	a5,a5,1436 # ffffffffc02ac938 <max_swap_offset>
ffffffffc02033a4:	6394                	ld	a3,0(a5)
ffffffffc02033a6:	010007b7          	lui	a5,0x1000
ffffffffc02033aa:	17e1                	addi	a5,a5,-8
ffffffffc02033ac:	ff968713          	addi	a4,a3,-7
ffffffffc02033b0:	4ae7ee63          	bltu	a5,a4,ffffffffc020386c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033b4:	0009e797          	auipc	a5,0x9e
ffffffffc02033b8:	00478793          	addi	a5,a5,4 # ffffffffc02a13b8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033be:	000a9697          	auipc	a3,0xa9
ffffffffc02033c2:	48f6b123          	sd	a5,1154(a3) # ffffffffc02ac840 <sm>
     int r = sm->init();
ffffffffc02033c6:	9702                	jalr	a4
ffffffffc02033c8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033ca:	c10d                	beqz	a0,ffffffffc02033ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033cc:	60ea                	ld	ra,152(sp)
ffffffffc02033ce:	644a                	ld	s0,144(sp)
ffffffffc02033d0:	8556                	mv	a0,s5
ffffffffc02033d2:	64aa                	ld	s1,136(sp)
ffffffffc02033d4:	690a                	ld	s2,128(sp)
ffffffffc02033d6:	79e6                	ld	s3,120(sp)
ffffffffc02033d8:	7a46                	ld	s4,112(sp)
ffffffffc02033da:	7aa6                	ld	s5,104(sp)
ffffffffc02033dc:	7b06                	ld	s6,96(sp)
ffffffffc02033de:	6be6                	ld	s7,88(sp)
ffffffffc02033e0:	6c46                	ld	s8,80(sp)
ffffffffc02033e2:	6ca6                	ld	s9,72(sp)
ffffffffc02033e4:	6d06                	ld	s10,64(sp)
ffffffffc02033e6:	7de2                	ld	s11,56(sp)
ffffffffc02033e8:	610d                	addi	sp,sp,160
ffffffffc02033ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ec:	000a9797          	auipc	a5,0xa9
ffffffffc02033f0:	45478793          	addi	a5,a5,1108 # ffffffffc02ac840 <sm>
ffffffffc02033f4:	639c                	ld	a5,0(a5)
ffffffffc02033f6:	00004517          	auipc	a0,0x4
ffffffffc02033fa:	70250513          	addi	a0,a0,1794 # ffffffffc0207af8 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc02033fe:	000a9417          	auipc	s0,0xa9
ffffffffc0203402:	47a40413          	addi	s0,s0,1146 # ffffffffc02ac878 <free_area>
ffffffffc0203406:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203408:	4785                	li	a5,1
ffffffffc020340a:	000a9717          	auipc	a4,0xa9
ffffffffc020340e:	42f72f23          	sw	a5,1086(a4) # ffffffffc02ac848 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203412:	d7dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203416:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203418:	36878e63          	beq	a5,s0,ffffffffc0203794 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020341c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203420:	8305                	srli	a4,a4,0x1
ffffffffc0203422:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203424:	36070c63          	beqz	a4,ffffffffc020379c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203428:	4481                	li	s1,0
ffffffffc020342a:	4901                	li	s2,0
ffffffffc020342c:	a031                	j	ffffffffc0203438 <swap_init+0xbc>
ffffffffc020342e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203432:	8b09                	andi	a4,a4,2
ffffffffc0203434:	36070463          	beqz	a4,ffffffffc020379c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020343c:	679c                	ld	a5,8(a5)
ffffffffc020343e:	2905                	addiw	s2,s2,1
ffffffffc0203440:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203442:	fe8796e3          	bne	a5,s0,ffffffffc020342e <swap_init+0xb2>
ffffffffc0203446:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203448:	ad7fe0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc020344c:	69351863          	bne	a0,s3,ffffffffc0203adc <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203450:	8626                	mv	a2,s1
ffffffffc0203452:	85ca                	mv	a1,s2
ffffffffc0203454:	00004517          	auipc	a0,0x4
ffffffffc0203458:	6bc50513          	addi	a0,a0,1724 # ffffffffc0207b10 <default_pmm_manager+0x7c8>
ffffffffc020345c:	d33fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203460:	467000ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0203464:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203466:	60050b63          	beqz	a0,ffffffffc0203a7c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020346a:	000a9797          	auipc	a5,0xa9
ffffffffc020346e:	51e78793          	addi	a5,a5,1310 # ffffffffc02ac988 <check_mm_struct>
ffffffffc0203472:	639c                	ld	a5,0(a5)
ffffffffc0203474:	62079463          	bnez	a5,ffffffffc0203a9c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203478:	000a9797          	auipc	a5,0xa9
ffffffffc020347c:	3b878793          	addi	a5,a5,952 # ffffffffc02ac830 <boot_pgdir>
ffffffffc0203480:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203484:	000a9797          	auipc	a5,0xa9
ffffffffc0203488:	50a7b223          	sd	a0,1284(a5) # ffffffffc02ac988 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020348c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75538>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203490:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203494:	4e079863          	bnez	a5,ffffffffc0203984 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203498:	6599                	lui	a1,0x6
ffffffffc020349a:	460d                	li	a2,3
ffffffffc020349c:	6505                	lui	a0,0x1
ffffffffc020349e:	475000ef          	jal	ra,ffffffffc0204112 <vma_create>
ffffffffc02034a2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034a4:	50050063          	beqz	a0,ffffffffc02039a4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034a8:	855e                	mv	a0,s7
ffffffffc02034aa:	4d5000ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ae:	00004517          	auipc	a0,0x4
ffffffffc02034b2:	6d250513          	addi	a0,a0,1746 # ffffffffc0207b80 <default_pmm_manager+0x838>
ffffffffc02034b6:	cd9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ba:	018bb503          	ld	a0,24(s7)
ffffffffc02034be:	4605                	li	a2,1
ffffffffc02034c0:	6585                	lui	a1,0x1
ffffffffc02034c2:	a9dfe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034c6:	4e050f63          	beqz	a0,ffffffffc02039c4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ca:	00004517          	auipc	a0,0x4
ffffffffc02034ce:	70650513          	addi	a0,a0,1798 # ffffffffc0207bd0 <default_pmm_manager+0x888>
ffffffffc02034d2:	000a9997          	auipc	s3,0xa9
ffffffffc02034d6:	3de98993          	addi	s3,s3,990 # ffffffffc02ac8b0 <check_rp>
ffffffffc02034da:	cb5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034de:	000a9a17          	auipc	s4,0xa9
ffffffffc02034e2:	3f2a0a13          	addi	s4,s4,1010 # ffffffffc02ac8d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	967fe0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc02034ee:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034f2:	32050d63          	beqz	a0,ffffffffc020382c <swap_init+0x4b0>
ffffffffc02034f6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034f8:	8b89                	andi	a5,a5,2
ffffffffc02034fa:	30079963          	bnez	a5,ffffffffc020380c <swap_init+0x490>
ffffffffc02034fe:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203500:	ff4c14e3          	bne	s8,s4,ffffffffc02034e8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203504:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203506:	000a9c17          	auipc	s8,0xa9
ffffffffc020350a:	3aac0c13          	addi	s8,s8,938 # ffffffffc02ac8b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020350e:	ec3e                	sd	a5,24(sp)
ffffffffc0203510:	641c                	ld	a5,8(s0)
ffffffffc0203512:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203514:	481c                	lw	a5,16(s0)
ffffffffc0203516:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203518:	000a9797          	auipc	a5,0xa9
ffffffffc020351c:	3687b423          	sd	s0,872(a5) # ffffffffc02ac880 <free_area+0x8>
ffffffffc0203520:	000a9797          	auipc	a5,0xa9
ffffffffc0203524:	3487bc23          	sd	s0,856(a5) # ffffffffc02ac878 <free_area>
     nr_free = 0;
ffffffffc0203528:	000a9797          	auipc	a5,0xa9
ffffffffc020352c:	3607a023          	sw	zero,864(a5) # ffffffffc02ac888 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203530:	000c3503          	ld	a0,0(s8)
ffffffffc0203534:	4585                	li	a1,1
ffffffffc0203536:	0c21                	addi	s8,s8,8
ffffffffc0203538:	9a1fe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020353c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203530 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203540:	01042c03          	lw	s8,16(s0)
ffffffffc0203544:	4791                	li	a5,4
ffffffffc0203546:	50fc1b63          	bne	s8,a5,ffffffffc0203a5c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020354a:	00004517          	auipc	a0,0x4
ffffffffc020354e:	70e50513          	addi	a0,a0,1806 # ffffffffc0207c58 <default_pmm_manager+0x910>
ffffffffc0203552:	c3dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203556:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203558:	000a9797          	auipc	a5,0xa9
ffffffffc020355c:	2e07aa23          	sw	zero,756(a5) # ffffffffc02ac84c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203560:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203562:	000a9797          	auipc	a5,0xa9
ffffffffc0203566:	2ea78793          	addi	a5,a5,746 # ffffffffc02ac84c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020356a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc020356e:	4398                	lw	a4,0(a5)
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	2701                	sext.w	a4,a4
ffffffffc0203574:	38b71863          	bne	a4,a1,ffffffffc0203904 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203578:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020357c:	4394                	lw	a3,0(a5)
ffffffffc020357e:	2681                	sext.w	a3,a3
ffffffffc0203580:	3ae69263          	bne	a3,a4,ffffffffc0203924 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203584:	6689                	lui	a3,0x2
ffffffffc0203586:	462d                	li	a2,11
ffffffffc0203588:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc020358c:	4398                	lw	a4,0(a5)
ffffffffc020358e:	4589                	li	a1,2
ffffffffc0203590:	2701                	sext.w	a4,a4
ffffffffc0203592:	2eb71963          	bne	a4,a1,ffffffffc0203884 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203596:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020359a:	4394                	lw	a3,0(a5)
ffffffffc020359c:	2681                	sext.w	a3,a3
ffffffffc020359e:	30e69363          	bne	a3,a4,ffffffffc02038a4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035a2:	668d                	lui	a3,0x3
ffffffffc02035a4:	4631                	li	a2,12
ffffffffc02035a6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc02035aa:	4398                	lw	a4,0(a5)
ffffffffc02035ac:	458d                	li	a1,3
ffffffffc02035ae:	2701                	sext.w	a4,a4
ffffffffc02035b0:	30b71a63          	bne	a4,a1,ffffffffc02038c4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035b4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035b8:	4394                	lw	a3,0(a5)
ffffffffc02035ba:	2681                	sext.w	a3,a3
ffffffffc02035bc:	32e69463          	bne	a3,a4,ffffffffc02038e4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035c0:	6691                	lui	a3,0x4
ffffffffc02035c2:	4635                	li	a2,13
ffffffffc02035c4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc02035c8:	4398                	lw	a4,0(a5)
ffffffffc02035ca:	2701                	sext.w	a4,a4
ffffffffc02035cc:	37871c63          	bne	a4,s8,ffffffffc0203944 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035d4:	439c                	lw	a5,0(a5)
ffffffffc02035d6:	2781                	sext.w	a5,a5
ffffffffc02035d8:	38e79663          	bne	a5,a4,ffffffffc0203964 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035dc:	481c                	lw	a5,16(s0)
ffffffffc02035de:	40079363          	bnez	a5,ffffffffc02039e4 <swap_init+0x668>
ffffffffc02035e2:	000a9797          	auipc	a5,0xa9
ffffffffc02035e6:	2ee78793          	addi	a5,a5,750 # ffffffffc02ac8d0 <swap_in_seq_no>
ffffffffc02035ea:	000a9717          	auipc	a4,0xa9
ffffffffc02035ee:	30e70713          	addi	a4,a4,782 # ffffffffc02ac8f8 <swap_out_seq_no>
ffffffffc02035f2:	000a9617          	auipc	a2,0xa9
ffffffffc02035f6:	30660613          	addi	a2,a2,774 # ffffffffc02ac8f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035fa:	56fd                	li	a3,-1
ffffffffc02035fc:	c394                	sw	a3,0(a5)
ffffffffc02035fe:	c314                	sw	a3,0(a4)
ffffffffc0203600:	0791                	addi	a5,a5,4
ffffffffc0203602:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203604:	fef61ce3          	bne	a2,a5,ffffffffc02035fc <swap_init+0x280>
ffffffffc0203608:	000a9697          	auipc	a3,0xa9
ffffffffc020360c:	35068693          	addi	a3,a3,848 # ffffffffc02ac958 <check_ptep>
ffffffffc0203610:	000a9817          	auipc	a6,0xa9
ffffffffc0203614:	2a080813          	addi	a6,a6,672 # ffffffffc02ac8b0 <check_rp>
ffffffffc0203618:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020361a:	000a9c97          	auipc	s9,0xa9
ffffffffc020361e:	21ec8c93          	addi	s9,s9,542 # ffffffffc02ac838 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203622:	00005d97          	auipc	s11,0x5
ffffffffc0203626:	6a6d8d93          	addi	s11,s11,1702 # ffffffffc0208cc8 <nbase>
ffffffffc020362a:	000a9c17          	auipc	s8,0xa9
ffffffffc020362e:	27ec0c13          	addi	s8,s8,638 # ffffffffc02ac8a8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203632:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203636:	4601                	li	a2,0
ffffffffc0203638:	85ea                	mv	a1,s10
ffffffffc020363a:	855a                	mv	a0,s6
ffffffffc020363c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020363e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203640:	91ffe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc0203644:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203646:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203648:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020364a:	20050163          	beqz	a0,ffffffffc020384c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020364e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203650:	0017f613          	andi	a2,a5,1
ffffffffc0203654:	1a060063          	beqz	a2,ffffffffc02037f4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203658:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020365c:	078a                	slli	a5,a5,0x2
ffffffffc020365e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203660:	14c7fe63          	bgeu	a5,a2,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203664:	000db703          	ld	a4,0(s11)
ffffffffc0203668:	000c3603          	ld	a2,0(s8)
ffffffffc020366c:	00083583          	ld	a1,0(a6)
ffffffffc0203670:	8f99                	sub	a5,a5,a4
ffffffffc0203672:	079a                	slli	a5,a5,0x6
ffffffffc0203674:	e43a                	sd	a4,8(sp)
ffffffffc0203676:	97b2                	add	a5,a5,a2
ffffffffc0203678:	14f59e63          	bne	a1,a5,ffffffffc02037d4 <swap_init+0x458>
ffffffffc020367c:	6785                	lui	a5,0x1
ffffffffc020367e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203680:	6795                	lui	a5,0x5
ffffffffc0203682:	06a1                	addi	a3,a3,8
ffffffffc0203684:	0821                	addi	a6,a6,8
ffffffffc0203686:	fafd16e3          	bne	s10,a5,ffffffffc0203632 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020368a:	00004517          	auipc	a0,0x4
ffffffffc020368e:	67650513          	addi	a0,a0,1654 # ffffffffc0207d00 <default_pmm_manager+0x9b8>
ffffffffc0203692:	afdfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203696:	000a9797          	auipc	a5,0xa9
ffffffffc020369a:	1aa78793          	addi	a5,a5,426 # ffffffffc02ac840 <sm>
ffffffffc020369e:	639c                	ld	a5,0(a5)
ffffffffc02036a0:	7f9c                	ld	a5,56(a5)
ffffffffc02036a2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036a4:	40051c63          	bnez	a0,ffffffffc0203abc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036a8:	77a2                	ld	a5,40(sp)
ffffffffc02036aa:	000a9717          	auipc	a4,0xa9
ffffffffc02036ae:	1cf72f23          	sw	a5,478(a4) # ffffffffc02ac888 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036b2:	67e2                	ld	a5,24(sp)
ffffffffc02036b4:	000a9717          	auipc	a4,0xa9
ffffffffc02036b8:	1cf73223          	sd	a5,452(a4) # ffffffffc02ac878 <free_area>
ffffffffc02036bc:	7782                	ld	a5,32(sp)
ffffffffc02036be:	000a9717          	auipc	a4,0xa9
ffffffffc02036c2:	1cf73123          	sd	a5,450(a4) # ffffffffc02ac880 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036c6:	0009b503          	ld	a0,0(s3)
ffffffffc02036ca:	4585                	li	a1,1
ffffffffc02036cc:	09a1                	addi	s3,s3,8
ffffffffc02036ce:	80bfe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036d2:	ff499ae3          	bne	s3,s4,ffffffffc02036c6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036d6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036da:	855e                	mv	a0,s7
ffffffffc02036dc:	371000ef          	jal	ra,ffffffffc020424c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036e0:	000a9797          	auipc	a5,0xa9
ffffffffc02036e4:	15078793          	addi	a5,a5,336 # ffffffffc02ac830 <boot_pgdir>
ffffffffc02036e8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036ea:	000a9697          	auipc	a3,0xa9
ffffffffc02036ee:	2806bf23          	sd	zero,670(a3) # ffffffffc02ac988 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036f2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f6:	6394                	ld	a3,0(a5)
ffffffffc02036f8:	068a                	slli	a3,a3,0x2
ffffffffc02036fa:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	0ce6f063          	bgeu	a3,a4,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203700:	67a2                	ld	a5,8(sp)
ffffffffc0203702:	000c3503          	ld	a0,0(s8)
ffffffffc0203706:	8e9d                	sub	a3,a3,a5
ffffffffc0203708:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020370a:	8699                	srai	a3,a3,0x6
ffffffffc020370c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020370e:	00c69793          	slli	a5,a3,0xc
ffffffffc0203712:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203714:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203716:	2ee7f763          	bgeu	a5,a4,ffffffffc0203a04 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020371a:	000a9797          	auipc	a5,0xa9
ffffffffc020371e:	17e78793          	addi	a5,a5,382 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0203722:	639c                	ld	a5,0(a5)
ffffffffc0203724:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203726:	629c                	ld	a5,0(a3)
ffffffffc0203728:	078a                	slli	a5,a5,0x2
ffffffffc020372a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020372c:	08e7f863          	bgeu	a5,a4,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203730:	69a2                	ld	s3,8(sp)
ffffffffc0203732:	4585                	li	a1,1
ffffffffc0203734:	413787b3          	sub	a5,a5,s3
ffffffffc0203738:	079a                	slli	a5,a5,0x6
ffffffffc020373a:	953e                	add	a0,a0,a5
ffffffffc020373c:	f9cfe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203740:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203744:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203748:	078a                	slli	a5,a5,0x2
ffffffffc020374a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374c:	06e7f863          	bgeu	a5,a4,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203750:	000c3503          	ld	a0,0(s8)
ffffffffc0203754:	413787b3          	sub	a5,a5,s3
ffffffffc0203758:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020375a:	4585                	li	a1,1
ffffffffc020375c:	953e                	add	a0,a0,a5
ffffffffc020375e:	f7afe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
     pgdir[0] = 0;
ffffffffc0203762:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203766:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020376a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376c:	00878963          	beq	a5,s0,ffffffffc020377e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203770:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203774:	679c                	ld	a5,8(a5)
ffffffffc0203776:	397d                	addiw	s2,s2,-1
ffffffffc0203778:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020377a:	fe879be3          	bne	a5,s0,ffffffffc0203770 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020377e:	28091f63          	bnez	s2,ffffffffc0203a1c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203782:	2a049d63          	bnez	s1,ffffffffc0203a3c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203786:	00004517          	auipc	a0,0x4
ffffffffc020378a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0207d50 <default_pmm_manager+0xa08>
ffffffffc020378e:	a01fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203792:	b92d                	j	ffffffffc02033cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203794:	4481                	li	s1,0
ffffffffc0203796:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203798:	4981                	li	s3,0
ffffffffc020379a:	b17d                	j	ffffffffc0203448 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020379c:	00004697          	auipc	a3,0x4
ffffffffc02037a0:	81c68693          	addi	a3,a3,-2020 # ffffffffc0206fb8 <commands+0x888>
ffffffffc02037a4:	00003617          	auipc	a2,0x3
ffffffffc02037a8:	45c60613          	addi	a2,a2,1116 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02037ac:	0bc00593          	li	a1,188
ffffffffc02037b0:	00004517          	auipc	a0,0x4
ffffffffc02037b4:	33850513          	addi	a0,a0,824 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02037b8:	cc9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037bc:	00004617          	auipc	a2,0x4
ffffffffc02037c0:	c3c60613          	addi	a2,a2,-964 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc02037c4:	06200593          	li	a1,98
ffffffffc02037c8:	00004517          	auipc	a0,0x4
ffffffffc02037cc:	bf850513          	addi	a0,a0,-1032 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02037d0:	cb1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037d4:	00004697          	auipc	a3,0x4
ffffffffc02037d8:	50468693          	addi	a3,a3,1284 # ffffffffc0207cd8 <default_pmm_manager+0x990>
ffffffffc02037dc:	00003617          	auipc	a2,0x3
ffffffffc02037e0:	42460613          	addi	a2,a2,1060 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02037e4:	0fc00593          	li	a1,252
ffffffffc02037e8:	00004517          	auipc	a0,0x4
ffffffffc02037ec:	30050513          	addi	a0,a0,768 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02037f0:	c91fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037f4:	00004617          	auipc	a2,0x4
ffffffffc02037f8:	e5c60613          	addi	a2,a2,-420 # ffffffffc0207650 <default_pmm_manager+0x308>
ffffffffc02037fc:	07400593          	li	a1,116
ffffffffc0203800:	00004517          	auipc	a0,0x4
ffffffffc0203804:	bc050513          	addi	a0,a0,-1088 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0203808:	c79fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020380c:	00004697          	auipc	a3,0x4
ffffffffc0203810:	40468693          	addi	a3,a3,1028 # ffffffffc0207c10 <default_pmm_manager+0x8c8>
ffffffffc0203814:	00003617          	auipc	a2,0x3
ffffffffc0203818:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020381c:	0dd00593          	li	a1,221
ffffffffc0203820:	00004517          	auipc	a0,0x4
ffffffffc0203824:	2c850513          	addi	a0,a0,712 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203828:	c59fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020382c:	00004697          	auipc	a3,0x4
ffffffffc0203830:	3cc68693          	addi	a3,a3,972 # ffffffffc0207bf8 <default_pmm_manager+0x8b0>
ffffffffc0203834:	00003617          	auipc	a2,0x3
ffffffffc0203838:	3cc60613          	addi	a2,a2,972 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020383c:	0dc00593          	li	a1,220
ffffffffc0203840:	00004517          	auipc	a0,0x4
ffffffffc0203844:	2a850513          	addi	a0,a0,680 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203848:	c39fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020384c:	00004697          	auipc	a3,0x4
ffffffffc0203850:	47468693          	addi	a3,a3,1140 # ffffffffc0207cc0 <default_pmm_manager+0x978>
ffffffffc0203854:	00003617          	auipc	a2,0x3
ffffffffc0203858:	3ac60613          	addi	a2,a2,940 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020385c:	0fb00593          	li	a1,251
ffffffffc0203860:	00004517          	auipc	a0,0x4
ffffffffc0203864:	28850513          	addi	a0,a0,648 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203868:	c19fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020386c:	00004617          	auipc	a2,0x4
ffffffffc0203870:	25c60613          	addi	a2,a2,604 # ffffffffc0207ac8 <default_pmm_manager+0x780>
ffffffffc0203874:	02800593          	li	a1,40
ffffffffc0203878:	00004517          	auipc	a0,0x4
ffffffffc020387c:	27050513          	addi	a0,a0,624 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203880:	c01fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc0203884:	00004697          	auipc	a3,0x4
ffffffffc0203888:	40c68693          	addi	a3,a3,1036 # ffffffffc0207c90 <default_pmm_manager+0x948>
ffffffffc020388c:	00003617          	auipc	a2,0x3
ffffffffc0203890:	37460613          	addi	a2,a2,884 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203894:	09700593          	li	a1,151
ffffffffc0203898:	00004517          	auipc	a0,0x4
ffffffffc020389c:	25050513          	addi	a0,a0,592 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02038a0:	be1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a4:	00004697          	auipc	a3,0x4
ffffffffc02038a8:	3ec68693          	addi	a3,a3,1004 # ffffffffc0207c90 <default_pmm_manager+0x948>
ffffffffc02038ac:	00003617          	auipc	a2,0x3
ffffffffc02038b0:	35460613          	addi	a2,a2,852 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02038b4:	09900593          	li	a1,153
ffffffffc02038b8:	00004517          	auipc	a0,0x4
ffffffffc02038bc:	23050513          	addi	a0,a0,560 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02038c0:	bc1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc02038c4:	00004697          	auipc	a3,0x4
ffffffffc02038c8:	3dc68693          	addi	a3,a3,988 # ffffffffc0207ca0 <default_pmm_manager+0x958>
ffffffffc02038cc:	00003617          	auipc	a2,0x3
ffffffffc02038d0:	33460613          	addi	a2,a2,820 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02038d4:	09b00593          	li	a1,155
ffffffffc02038d8:	00004517          	auipc	a0,0x4
ffffffffc02038dc:	21050513          	addi	a0,a0,528 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02038e0:	ba1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e4:	00004697          	auipc	a3,0x4
ffffffffc02038e8:	3bc68693          	addi	a3,a3,956 # ffffffffc0207ca0 <default_pmm_manager+0x958>
ffffffffc02038ec:	00003617          	auipc	a2,0x3
ffffffffc02038f0:	31460613          	addi	a2,a2,788 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02038f4:	09d00593          	li	a1,157
ffffffffc02038f8:	00004517          	auipc	a0,0x4
ffffffffc02038fc:	1f050513          	addi	a0,a0,496 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203900:	b81fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc0203904:	00004697          	auipc	a3,0x4
ffffffffc0203908:	37c68693          	addi	a3,a3,892 # ffffffffc0207c80 <default_pmm_manager+0x938>
ffffffffc020390c:	00003617          	auipc	a2,0x3
ffffffffc0203910:	2f460613          	addi	a2,a2,756 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203914:	09300593          	li	a1,147
ffffffffc0203918:	00004517          	auipc	a0,0x4
ffffffffc020391c:	1d050513          	addi	a0,a0,464 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203920:	b61fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc0203924:	00004697          	auipc	a3,0x4
ffffffffc0203928:	35c68693          	addi	a3,a3,860 # ffffffffc0207c80 <default_pmm_manager+0x938>
ffffffffc020392c:	00003617          	auipc	a2,0x3
ffffffffc0203930:	2d460613          	addi	a2,a2,724 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203934:	09500593          	li	a1,149
ffffffffc0203938:	00004517          	auipc	a0,0x4
ffffffffc020393c:	1b050513          	addi	a0,a0,432 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203940:	b41fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203944:	00004697          	auipc	a3,0x4
ffffffffc0203948:	36c68693          	addi	a3,a3,876 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc020394c:	00003617          	auipc	a2,0x3
ffffffffc0203950:	2b460613          	addi	a2,a2,692 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203954:	09f00593          	li	a1,159
ffffffffc0203958:	00004517          	auipc	a0,0x4
ffffffffc020395c:	19050513          	addi	a0,a0,400 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203960:	b21fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203964:	00004697          	auipc	a3,0x4
ffffffffc0203968:	34c68693          	addi	a3,a3,844 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc020396c:	00003617          	auipc	a2,0x3
ffffffffc0203970:	29460613          	addi	a2,a2,660 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203974:	0a100593          	li	a1,161
ffffffffc0203978:	00004517          	auipc	a0,0x4
ffffffffc020397c:	17050513          	addi	a0,a0,368 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203980:	b01fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203984:	00004697          	auipc	a3,0x4
ffffffffc0203988:	1dc68693          	addi	a3,a3,476 # ffffffffc0207b60 <default_pmm_manager+0x818>
ffffffffc020398c:	00003617          	auipc	a2,0x3
ffffffffc0203990:	27460613          	addi	a2,a2,628 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203994:	0cc00593          	li	a1,204
ffffffffc0203998:	00004517          	auipc	a0,0x4
ffffffffc020399c:	15050513          	addi	a0,a0,336 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02039a0:	ae1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(vma != NULL);
ffffffffc02039a4:	00004697          	auipc	a3,0x4
ffffffffc02039a8:	1cc68693          	addi	a3,a3,460 # ffffffffc0207b70 <default_pmm_manager+0x828>
ffffffffc02039ac:	00003617          	auipc	a2,0x3
ffffffffc02039b0:	25460613          	addi	a2,a2,596 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02039b4:	0cf00593          	li	a1,207
ffffffffc02039b8:	00004517          	auipc	a0,0x4
ffffffffc02039bc:	13050513          	addi	a0,a0,304 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02039c0:	ac1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039c4:	00004697          	auipc	a3,0x4
ffffffffc02039c8:	1f468693          	addi	a3,a3,500 # ffffffffc0207bb8 <default_pmm_manager+0x870>
ffffffffc02039cc:	00003617          	auipc	a2,0x3
ffffffffc02039d0:	23460613          	addi	a2,a2,564 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02039d4:	0d700593          	li	a1,215
ffffffffc02039d8:	00004517          	auipc	a0,0x4
ffffffffc02039dc:	11050513          	addi	a0,a0,272 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc02039e0:	aa1fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert( nr_free == 0);         
ffffffffc02039e4:	00003697          	auipc	a3,0x3
ffffffffc02039e8:	7a468693          	addi	a3,a3,1956 # ffffffffc0207188 <commands+0xa58>
ffffffffc02039ec:	00003617          	auipc	a2,0x3
ffffffffc02039f0:	21460613          	addi	a2,a2,532 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02039f4:	0f300593          	li	a1,243
ffffffffc02039f8:	00004517          	auipc	a0,0x4
ffffffffc02039fc:	0f050513          	addi	a0,a0,240 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203a00:	a81fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a04:	00004617          	auipc	a2,0x4
ffffffffc0203a08:	99460613          	addi	a2,a2,-1644 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0203a0c:	06900593          	li	a1,105
ffffffffc0203a10:	00004517          	auipc	a0,0x4
ffffffffc0203a14:	9b050513          	addi	a0,a0,-1616 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0203a18:	a69fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(count==0);
ffffffffc0203a1c:	00004697          	auipc	a3,0x4
ffffffffc0203a20:	31468693          	addi	a3,a3,788 # ffffffffc0207d30 <default_pmm_manager+0x9e8>
ffffffffc0203a24:	00003617          	auipc	a2,0x3
ffffffffc0203a28:	1dc60613          	addi	a2,a2,476 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203a2c:	11d00593          	li	a1,285
ffffffffc0203a30:	00004517          	auipc	a0,0x4
ffffffffc0203a34:	0b850513          	addi	a0,a0,184 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203a38:	a49fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total==0);
ffffffffc0203a3c:	00004697          	auipc	a3,0x4
ffffffffc0203a40:	30468693          	addi	a3,a3,772 # ffffffffc0207d40 <default_pmm_manager+0x9f8>
ffffffffc0203a44:	00003617          	auipc	a2,0x3
ffffffffc0203a48:	1bc60613          	addi	a2,a2,444 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203a4c:	11e00593          	li	a1,286
ffffffffc0203a50:	00004517          	auipc	a0,0x4
ffffffffc0203a54:	09850513          	addi	a0,a0,152 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203a58:	a29fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a5c:	00004697          	auipc	a3,0x4
ffffffffc0203a60:	1d468693          	addi	a3,a3,468 # ffffffffc0207c30 <default_pmm_manager+0x8e8>
ffffffffc0203a64:	00003617          	auipc	a2,0x3
ffffffffc0203a68:	19c60613          	addi	a2,a2,412 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203a6c:	0ea00593          	li	a1,234
ffffffffc0203a70:	00004517          	auipc	a0,0x4
ffffffffc0203a74:	07850513          	addi	a0,a0,120 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203a78:	a09fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(mm != NULL);
ffffffffc0203a7c:	00004697          	auipc	a3,0x4
ffffffffc0203a80:	0bc68693          	addi	a3,a3,188 # ffffffffc0207b38 <default_pmm_manager+0x7f0>
ffffffffc0203a84:	00003617          	auipc	a2,0x3
ffffffffc0203a88:	17c60613          	addi	a2,a2,380 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203a8c:	0c400593          	li	a1,196
ffffffffc0203a90:	00004517          	auipc	a0,0x4
ffffffffc0203a94:	05850513          	addi	a0,a0,88 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203a98:	9e9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a9c:	00004697          	auipc	a3,0x4
ffffffffc0203aa0:	0ac68693          	addi	a3,a3,172 # ffffffffc0207b48 <default_pmm_manager+0x800>
ffffffffc0203aa4:	00003617          	auipc	a2,0x3
ffffffffc0203aa8:	15c60613          	addi	a2,a2,348 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203aac:	0c700593          	li	a1,199
ffffffffc0203ab0:	00004517          	auipc	a0,0x4
ffffffffc0203ab4:	03850513          	addi	a0,a0,56 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203ab8:	9c9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(ret==0);
ffffffffc0203abc:	00004697          	auipc	a3,0x4
ffffffffc0203ac0:	26c68693          	addi	a3,a3,620 # ffffffffc0207d28 <default_pmm_manager+0x9e0>
ffffffffc0203ac4:	00003617          	auipc	a2,0x3
ffffffffc0203ac8:	13c60613          	addi	a2,a2,316 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203acc:	10200593          	li	a1,258
ffffffffc0203ad0:	00004517          	auipc	a0,0x4
ffffffffc0203ad4:	01850513          	addi	a0,a0,24 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203ad8:	9a9fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203adc:	00003697          	auipc	a3,0x3
ffffffffc0203ae0:	50468693          	addi	a3,a3,1284 # ffffffffc0206fe0 <commands+0x8b0>
ffffffffc0203ae4:	00003617          	auipc	a2,0x3
ffffffffc0203ae8:	11c60613          	addi	a2,a2,284 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203aec:	0bf00593          	li	a1,191
ffffffffc0203af0:	00004517          	auipc	a0,0x4
ffffffffc0203af4:	ff850513          	addi	a0,a0,-8 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203af8:	989fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203afc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203afc:	000a9797          	auipc	a5,0xa9
ffffffffc0203b00:	d4478793          	addi	a5,a5,-700 # ffffffffc02ac840 <sm>
ffffffffc0203b04:	639c                	ld	a5,0(a5)
ffffffffc0203b06:	0107b303          	ld	t1,16(a5)
ffffffffc0203b0a:	8302                	jr	t1

ffffffffc0203b0c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b0c:	000a9797          	auipc	a5,0xa9
ffffffffc0203b10:	d3478793          	addi	a5,a5,-716 # ffffffffc02ac840 <sm>
ffffffffc0203b14:	639c                	ld	a5,0(a5)
ffffffffc0203b16:	0207b303          	ld	t1,32(a5)
ffffffffc0203b1a:	8302                	jr	t1

ffffffffc0203b1c <swap_out>:
{
ffffffffc0203b1c:	711d                	addi	sp,sp,-96
ffffffffc0203b1e:	ec86                	sd	ra,88(sp)
ffffffffc0203b20:	e8a2                	sd	s0,80(sp)
ffffffffc0203b22:	e4a6                	sd	s1,72(sp)
ffffffffc0203b24:	e0ca                	sd	s2,64(sp)
ffffffffc0203b26:	fc4e                	sd	s3,56(sp)
ffffffffc0203b28:	f852                	sd	s4,48(sp)
ffffffffc0203b2a:	f456                	sd	s5,40(sp)
ffffffffc0203b2c:	f05a                	sd	s6,32(sp)
ffffffffc0203b2e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b30:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b32:	cde9                	beqz	a1,ffffffffc0203c0c <swap_out+0xf0>
ffffffffc0203b34:	8ab2                	mv	s5,a2
ffffffffc0203b36:	892a                	mv	s2,a0
ffffffffc0203b38:	8a2e                	mv	s4,a1
ffffffffc0203b3a:	4401                	li	s0,0
ffffffffc0203b3c:	000a9997          	auipc	s3,0xa9
ffffffffc0203b40:	d0498993          	addi	s3,s3,-764 # ffffffffc02ac840 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b44:	00004b17          	auipc	s6,0x4
ffffffffc0203b48:	28cb0b13          	addi	s6,s6,652 # ffffffffc0207dd0 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b4c:	00004b97          	auipc	s7,0x4
ffffffffc0203b50:	26cb8b93          	addi	s7,s7,620 # ffffffffc0207db8 <default_pmm_manager+0xa70>
ffffffffc0203b54:	a825                	j	ffffffffc0203b8c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b56:	67a2                	ld	a5,8(sp)
ffffffffc0203b58:	8626                	mv	a2,s1
ffffffffc0203b5a:	85a2                	mv	a1,s0
ffffffffc0203b5c:	7f94                	ld	a3,56(a5)
ffffffffc0203b5e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b60:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b62:	82b1                	srli	a3,a3,0xc
ffffffffc0203b64:	0685                	addi	a3,a3,1
ffffffffc0203b66:	e28fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b6c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b70:	83b1                	srli	a5,a5,0xc
ffffffffc0203b72:	0785                	addi	a5,a5,1
ffffffffc0203b74:	07a2                	slli	a5,a5,0x8
ffffffffc0203b76:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b7a:	b5efe0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b7e:	01893503          	ld	a0,24(s2)
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	f5eff0ef          	jal	ra,ffffffffc02032e2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b88:	048a0d63          	beq	s4,s0,ffffffffc0203be2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b8c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b90:	8656                	mv	a2,s5
ffffffffc0203b92:	002c                	addi	a1,sp,8
ffffffffc0203b94:	7b9c                	ld	a5,48(a5)
ffffffffc0203b96:	854a                	mv	a0,s2
ffffffffc0203b98:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b9a:	e12d                	bnez	a0,ffffffffc0203bfc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b9c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b9e:	01893503          	ld	a0,24(s2)
ffffffffc0203ba2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203ba4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ba6:	85a6                	mv	a1,s1
ffffffffc0203ba8:	bb6fe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bac:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bb0:	8b85                	andi	a5,a5,1
ffffffffc0203bb2:	cfb9                	beqz	a5,ffffffffc0203c10 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bb4:	65a2                	ld	a1,8(sp)
ffffffffc0203bb6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bba:	00178513          	addi	a0,a5,1
ffffffffc0203bbe:	0522                	slli	a0,a0,0x8
ffffffffc0203bc0:	048010ef          	jal	ra,ffffffffc0204c08 <swapfs_write>
ffffffffc0203bc4:	d949                	beqz	a0,ffffffffc0203b56 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bc6:	855e                	mv	a0,s7
ffffffffc0203bc8:	dc6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bcc:	0009b783          	ld	a5,0(s3)
ffffffffc0203bd0:	6622                	ld	a2,8(sp)
ffffffffc0203bd2:	4681                	li	a3,0
ffffffffc0203bd4:	739c                	ld	a5,32(a5)
ffffffffc0203bd6:	85a6                	mv	a1,s1
ffffffffc0203bd8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bda:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bde:	fa8a17e3          	bne	s4,s0,ffffffffc0203b8c <swap_out+0x70>
}
ffffffffc0203be2:	8522                	mv	a0,s0
ffffffffc0203be4:	60e6                	ld	ra,88(sp)
ffffffffc0203be6:	6446                	ld	s0,80(sp)
ffffffffc0203be8:	64a6                	ld	s1,72(sp)
ffffffffc0203bea:	6906                	ld	s2,64(sp)
ffffffffc0203bec:	79e2                	ld	s3,56(sp)
ffffffffc0203bee:	7a42                	ld	s4,48(sp)
ffffffffc0203bf0:	7aa2                	ld	s5,40(sp)
ffffffffc0203bf2:	7b02                	ld	s6,32(sp)
ffffffffc0203bf4:	6be2                	ld	s7,24(sp)
ffffffffc0203bf6:	6c42                	ld	s8,16(sp)
ffffffffc0203bf8:	6125                	addi	sp,sp,96
ffffffffc0203bfa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bfc:	85a2                	mv	a1,s0
ffffffffc0203bfe:	00004517          	auipc	a0,0x4
ffffffffc0203c02:	17250513          	addi	a0,a0,370 # ffffffffc0207d70 <default_pmm_manager+0xa28>
ffffffffc0203c06:	d88fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203c0a:	bfe1                	j	ffffffffc0203be2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c0c:	4401                	li	s0,0
ffffffffc0203c0e:	bfd1                	j	ffffffffc0203be2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c10:	00004697          	auipc	a3,0x4
ffffffffc0203c14:	19068693          	addi	a3,a3,400 # ffffffffc0207da0 <default_pmm_manager+0xa58>
ffffffffc0203c18:	00003617          	auipc	a2,0x3
ffffffffc0203c1c:	fe860613          	addi	a2,a2,-24 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203c20:	06800593          	li	a1,104
ffffffffc0203c24:	00004517          	auipc	a0,0x4
ffffffffc0203c28:	ec450513          	addi	a0,a0,-316 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203c2c:	855fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203c30 <swap_in>:
{
ffffffffc0203c30:	7179                	addi	sp,sp,-48
ffffffffc0203c32:	e84a                	sd	s2,16(sp)
ffffffffc0203c34:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c36:	4505                	li	a0,1
{
ffffffffc0203c38:	ec26                	sd	s1,24(sp)
ffffffffc0203c3a:	e44e                	sd	s3,8(sp)
ffffffffc0203c3c:	f406                	sd	ra,40(sp)
ffffffffc0203c3e:	f022                	sd	s0,32(sp)
ffffffffc0203c40:	84ae                	mv	s1,a1
ffffffffc0203c42:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c44:	a0cfe0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c48:	c129                	beqz	a0,ffffffffc0203c8a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c4a:	842a                	mv	s0,a0
ffffffffc0203c4c:	01893503          	ld	a0,24(s2)
ffffffffc0203c50:	4601                	li	a2,0
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	b0afe0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc0203c58:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c5a:	6108                	ld	a0,0(a0)
ffffffffc0203c5c:	85a2                	mv	a1,s0
ffffffffc0203c5e:	713000ef          	jal	ra,ffffffffc0204b70 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c62:	00093583          	ld	a1,0(s2)
ffffffffc0203c66:	8626                	mv	a2,s1
ffffffffc0203c68:	00004517          	auipc	a0,0x4
ffffffffc0203c6c:	e2050513          	addi	a0,a0,-480 # ffffffffc0207a88 <default_pmm_manager+0x740>
ffffffffc0203c70:	81a1                	srli	a1,a1,0x8
ffffffffc0203c72:	d1cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203c76:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c78:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c7c:	7402                	ld	s0,32(sp)
ffffffffc0203c7e:	64e2                	ld	s1,24(sp)
ffffffffc0203c80:	6942                	ld	s2,16(sp)
ffffffffc0203c82:	69a2                	ld	s3,8(sp)
ffffffffc0203c84:	4501                	li	a0,0
ffffffffc0203c86:	6145                	addi	sp,sp,48
ffffffffc0203c88:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c8a:	00004697          	auipc	a3,0x4
ffffffffc0203c8e:	dee68693          	addi	a3,a3,-530 # ffffffffc0207a78 <default_pmm_manager+0x730>
ffffffffc0203c92:	00003617          	auipc	a2,0x3
ffffffffc0203c96:	f6e60613          	addi	a2,a2,-146 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203c9a:	07e00593          	li	a1,126
ffffffffc0203c9e:	00004517          	auipc	a0,0x4
ffffffffc0203ca2:	e4a50513          	addi	a0,a0,-438 # ffffffffc0207ae8 <default_pmm_manager+0x7a0>
ffffffffc0203ca6:	fdafc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203caa <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203caa:	000a9797          	auipc	a5,0xa9
ffffffffc0203cae:	cce78793          	addi	a5,a5,-818 # ffffffffc02ac978 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cb2:	f51c                	sd	a5,40(a0)
ffffffffc0203cb4:	e79c                	sd	a5,8(a5)
ffffffffc0203cb6:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cb8:	4501                	li	a0,0
ffffffffc0203cba:	8082                	ret

ffffffffc0203cbc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cbc:	4501                	li	a0,0
ffffffffc0203cbe:	8082                	ret

ffffffffc0203cc0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cc0:	4501                	li	a0,0
ffffffffc0203cc2:	8082                	ret

ffffffffc0203cc4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cc4:	4501                	li	a0,0
ffffffffc0203cc6:	8082                	ret

ffffffffc0203cc8 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cc8:	711d                	addi	sp,sp,-96
ffffffffc0203cca:	fc4e                	sd	s3,56(sp)
ffffffffc0203ccc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cce:	00004517          	auipc	a0,0x4
ffffffffc0203cd2:	14250513          	addi	a0,a0,322 # ffffffffc0207e10 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cd6:	698d                	lui	s3,0x3
ffffffffc0203cd8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cda:	e8a2                	sd	s0,80(sp)
ffffffffc0203cdc:	e4a6                	sd	s1,72(sp)
ffffffffc0203cde:	ec86                	sd	ra,88(sp)
ffffffffc0203ce0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ce2:	f456                	sd	s5,40(sp)
ffffffffc0203ce4:	f05a                	sd	s6,32(sp)
ffffffffc0203ce6:	ec5e                	sd	s7,24(sp)
ffffffffc0203ce8:	e862                	sd	s8,16(sp)
ffffffffc0203cea:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203cec:	000a9417          	auipc	s0,0xa9
ffffffffc0203cf0:	b6040413          	addi	s0,s0,-1184 # ffffffffc02ac84c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cf4:	c9afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cf8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0203cfc:	4004                	lw	s1,0(s0)
ffffffffc0203cfe:	4791                	li	a5,4
ffffffffc0203d00:	2481                	sext.w	s1,s1
ffffffffc0203d02:	14f49963          	bne	s1,a5,ffffffffc0203e54 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d06:	00004517          	auipc	a0,0x4
ffffffffc0203d0a:	14a50513          	addi	a0,a0,330 # ffffffffc0207e50 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d0e:	6a85                	lui	s5,0x1
ffffffffc0203d10:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d12:	c7cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d16:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0203d1a:	00042903          	lw	s2,0(s0)
ffffffffc0203d1e:	2901                	sext.w	s2,s2
ffffffffc0203d20:	2a991a63          	bne	s2,s1,ffffffffc0203fd4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d24:	00004517          	auipc	a0,0x4
ffffffffc0203d28:	15450513          	addi	a0,a0,340 # ffffffffc0207e78 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d2c:	6b91                	lui	s7,0x4
ffffffffc0203d2e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d30:	c5efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d34:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc0203d38:	4004                	lw	s1,0(s0)
ffffffffc0203d3a:	2481                	sext.w	s1,s1
ffffffffc0203d3c:	27249c63          	bne	s1,s2,ffffffffc0203fb4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	16050513          	addi	a0,a0,352 # ffffffffc0207ea0 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d48:	6909                	lui	s2,0x2
ffffffffc0203d4a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d4c:	c42fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d50:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc0203d54:	401c                	lw	a5,0(s0)
ffffffffc0203d56:	2781                	sext.w	a5,a5
ffffffffc0203d58:	22979e63          	bne	a5,s1,ffffffffc0203f94 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5c:	00004517          	auipc	a0,0x4
ffffffffc0203d60:	16c50513          	addi	a0,a0,364 # ffffffffc0207ec8 <default_pmm_manager+0xb80>
ffffffffc0203d64:	c2afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d68:	6795                	lui	a5,0x5
ffffffffc0203d6a:	4739                	li	a4,14
ffffffffc0203d6c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc0203d70:	4004                	lw	s1,0(s0)
ffffffffc0203d72:	4795                	li	a5,5
ffffffffc0203d74:	2481                	sext.w	s1,s1
ffffffffc0203d76:	1ef49f63          	bne	s1,a5,ffffffffc0203f74 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d7a:	00004517          	auipc	a0,0x4
ffffffffc0203d7e:	12650513          	addi	a0,a0,294 # ffffffffc0207ea0 <default_pmm_manager+0xb58>
ffffffffc0203d82:	c0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d86:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d8a:	401c                	lw	a5,0(s0)
ffffffffc0203d8c:	2781                	sext.w	a5,a5
ffffffffc0203d8e:	1c979363          	bne	a5,s1,ffffffffc0203f54 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d92:	00004517          	auipc	a0,0x4
ffffffffc0203d96:	0be50513          	addi	a0,a0,190 # ffffffffc0207e50 <default_pmm_manager+0xb08>
ffffffffc0203d9a:	bf4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d9e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203da2:	401c                	lw	a5,0(s0)
ffffffffc0203da4:	4719                	li	a4,6
ffffffffc0203da6:	2781                	sext.w	a5,a5
ffffffffc0203da8:	18e79663          	bne	a5,a4,ffffffffc0203f34 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dac:	00004517          	auipc	a0,0x4
ffffffffc0203db0:	0f450513          	addi	a0,a0,244 # ffffffffc0207ea0 <default_pmm_manager+0xb58>
ffffffffc0203db4:	bdafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203db8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dbc:	401c                	lw	a5,0(s0)
ffffffffc0203dbe:	471d                	li	a4,7
ffffffffc0203dc0:	2781                	sext.w	a5,a5
ffffffffc0203dc2:	14e79963          	bne	a5,a4,ffffffffc0203f14 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc6:	00004517          	auipc	a0,0x4
ffffffffc0203dca:	04a50513          	addi	a0,a0,74 # ffffffffc0207e10 <default_pmm_manager+0xac8>
ffffffffc0203dce:	bc0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dd2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203dd6:	401c                	lw	a5,0(s0)
ffffffffc0203dd8:	4721                	li	a4,8
ffffffffc0203dda:	2781                	sext.w	a5,a5
ffffffffc0203ddc:	10e79c63          	bne	a5,a4,ffffffffc0203ef4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203de0:	00004517          	auipc	a0,0x4
ffffffffc0203de4:	09850513          	addi	a0,a0,152 # ffffffffc0207e78 <default_pmm_manager+0xb30>
ffffffffc0203de8:	ba6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dec:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203df0:	401c                	lw	a5,0(s0)
ffffffffc0203df2:	4725                	li	a4,9
ffffffffc0203df4:	2781                	sext.w	a5,a5
ffffffffc0203df6:	0ce79f63          	bne	a5,a4,ffffffffc0203ed4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dfa:	00004517          	auipc	a0,0x4
ffffffffc0203dfe:	0ce50513          	addi	a0,a0,206 # ffffffffc0207ec8 <default_pmm_manager+0xb80>
ffffffffc0203e02:	b8cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e06:	6795                	lui	a5,0x5
ffffffffc0203e08:	4739                	li	a4,14
ffffffffc0203e0a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0203e0e:	4004                	lw	s1,0(s0)
ffffffffc0203e10:	47a9                	li	a5,10
ffffffffc0203e12:	2481                	sext.w	s1,s1
ffffffffc0203e14:	0af49063          	bne	s1,a5,ffffffffc0203eb4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e18:	00004517          	auipc	a0,0x4
ffffffffc0203e1c:	03850513          	addi	a0,a0,56 # ffffffffc0207e50 <default_pmm_manager+0xb08>
ffffffffc0203e20:	b6efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e24:	6785                	lui	a5,0x1
ffffffffc0203e26:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0203e2a:	06979563          	bne	a5,s1,ffffffffc0203e94 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e2e:	401c                	lw	a5,0(s0)
ffffffffc0203e30:	472d                	li	a4,11
ffffffffc0203e32:	2781                	sext.w	a5,a5
ffffffffc0203e34:	04e79063          	bne	a5,a4,ffffffffc0203e74 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e38:	60e6                	ld	ra,88(sp)
ffffffffc0203e3a:	6446                	ld	s0,80(sp)
ffffffffc0203e3c:	64a6                	ld	s1,72(sp)
ffffffffc0203e3e:	6906                	ld	s2,64(sp)
ffffffffc0203e40:	79e2                	ld	s3,56(sp)
ffffffffc0203e42:	7a42                	ld	s4,48(sp)
ffffffffc0203e44:	7aa2                	ld	s5,40(sp)
ffffffffc0203e46:	7b02                	ld	s6,32(sp)
ffffffffc0203e48:	6be2                	ld	s7,24(sp)
ffffffffc0203e4a:	6c42                	ld	s8,16(sp)
ffffffffc0203e4c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e4e:	4501                	li	a0,0
ffffffffc0203e50:	6125                	addi	sp,sp,96
ffffffffc0203e52:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e54:	00004697          	auipc	a3,0x4
ffffffffc0203e58:	e5c68693          	addi	a3,a3,-420 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc0203e5c:	00003617          	auipc	a2,0x3
ffffffffc0203e60:	da460613          	addi	a2,a2,-604 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203e64:	05500593          	li	a1,85
ffffffffc0203e68:	00004517          	auipc	a0,0x4
ffffffffc0203e6c:	fd050513          	addi	a0,a0,-48 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203e70:	e10fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e74:	00004697          	auipc	a3,0x4
ffffffffc0203e78:	10468693          	addi	a3,a3,260 # ffffffffc0207f78 <default_pmm_manager+0xc30>
ffffffffc0203e7c:	00003617          	auipc	a2,0x3
ffffffffc0203e80:	d8460613          	addi	a2,a2,-636 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203e84:	07700593          	li	a1,119
ffffffffc0203e88:	00004517          	auipc	a0,0x4
ffffffffc0203e8c:	fb050513          	addi	a0,a0,-80 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203e90:	df0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e94:	00004697          	auipc	a3,0x4
ffffffffc0203e98:	0bc68693          	addi	a3,a3,188 # ffffffffc0207f50 <default_pmm_manager+0xc08>
ffffffffc0203e9c:	00003617          	auipc	a2,0x3
ffffffffc0203ea0:	d6460613          	addi	a2,a2,-668 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203ea4:	07500593          	li	a1,117
ffffffffc0203ea8:	00004517          	auipc	a0,0x4
ffffffffc0203eac:	f9050513          	addi	a0,a0,-112 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203eb0:	dd0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==10);
ffffffffc0203eb4:	00004697          	auipc	a3,0x4
ffffffffc0203eb8:	08c68693          	addi	a3,a3,140 # ffffffffc0207f40 <default_pmm_manager+0xbf8>
ffffffffc0203ebc:	00003617          	auipc	a2,0x3
ffffffffc0203ec0:	d4460613          	addi	a2,a2,-700 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203ec4:	07300593          	li	a1,115
ffffffffc0203ec8:	00004517          	auipc	a0,0x4
ffffffffc0203ecc:	f7050513          	addi	a0,a0,-144 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203ed0:	db0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ed4:	00004697          	auipc	a3,0x4
ffffffffc0203ed8:	05c68693          	addi	a3,a3,92 # ffffffffc0207f30 <default_pmm_manager+0xbe8>
ffffffffc0203edc:	00003617          	auipc	a2,0x3
ffffffffc0203ee0:	d2460613          	addi	a2,a2,-732 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203ee4:	07000593          	li	a1,112
ffffffffc0203ee8:	00004517          	auipc	a0,0x4
ffffffffc0203eec:	f5050513          	addi	a0,a0,-176 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203ef0:	d90fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ef4:	00004697          	auipc	a3,0x4
ffffffffc0203ef8:	02c68693          	addi	a3,a3,44 # ffffffffc0207f20 <default_pmm_manager+0xbd8>
ffffffffc0203efc:	00003617          	auipc	a2,0x3
ffffffffc0203f00:	d0460613          	addi	a2,a2,-764 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203f04:	06d00593          	li	a1,109
ffffffffc0203f08:	00004517          	auipc	a0,0x4
ffffffffc0203f0c:	f3050513          	addi	a0,a0,-208 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203f10:	d70fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f14:	00004697          	auipc	a3,0x4
ffffffffc0203f18:	ffc68693          	addi	a3,a3,-4 # ffffffffc0207f10 <default_pmm_manager+0xbc8>
ffffffffc0203f1c:	00003617          	auipc	a2,0x3
ffffffffc0203f20:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203f24:	06a00593          	li	a1,106
ffffffffc0203f28:	00004517          	auipc	a0,0x4
ffffffffc0203f2c:	f1050513          	addi	a0,a0,-240 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203f30:	d50fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f34:	00004697          	auipc	a3,0x4
ffffffffc0203f38:	fcc68693          	addi	a3,a3,-52 # ffffffffc0207f00 <default_pmm_manager+0xbb8>
ffffffffc0203f3c:	00003617          	auipc	a2,0x3
ffffffffc0203f40:	cc460613          	addi	a2,a2,-828 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203f44:	06700593          	li	a1,103
ffffffffc0203f48:	00004517          	auipc	a0,0x4
ffffffffc0203f4c:	ef050513          	addi	a0,a0,-272 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203f50:	d30fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f54:	00004697          	auipc	a3,0x4
ffffffffc0203f58:	f9c68693          	addi	a3,a3,-100 # ffffffffc0207ef0 <default_pmm_manager+0xba8>
ffffffffc0203f5c:	00003617          	auipc	a2,0x3
ffffffffc0203f60:	ca460613          	addi	a2,a2,-860 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203f64:	06400593          	li	a1,100
ffffffffc0203f68:	00004517          	auipc	a0,0x4
ffffffffc0203f6c:	ed050513          	addi	a0,a0,-304 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203f70:	d10fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f74:	00004697          	auipc	a3,0x4
ffffffffc0203f78:	f7c68693          	addi	a3,a3,-132 # ffffffffc0207ef0 <default_pmm_manager+0xba8>
ffffffffc0203f7c:	00003617          	auipc	a2,0x3
ffffffffc0203f80:	c8460613          	addi	a2,a2,-892 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203f84:	06100593          	li	a1,97
ffffffffc0203f88:	00004517          	auipc	a0,0x4
ffffffffc0203f8c:	eb050513          	addi	a0,a0,-336 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203f90:	cf0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f94:	00004697          	auipc	a3,0x4
ffffffffc0203f98:	d1c68693          	addi	a3,a3,-740 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc0203f9c:	00003617          	auipc	a2,0x3
ffffffffc0203fa0:	c6460613          	addi	a2,a2,-924 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203fa4:	05e00593          	li	a1,94
ffffffffc0203fa8:	00004517          	auipc	a0,0x4
ffffffffc0203fac:	e9050513          	addi	a0,a0,-368 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203fb0:	cd0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fb4:	00004697          	auipc	a3,0x4
ffffffffc0203fb8:	cfc68693          	addi	a3,a3,-772 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc0203fbc:	00003617          	auipc	a2,0x3
ffffffffc0203fc0:	c4460613          	addi	a2,a2,-956 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203fc4:	05b00593          	li	a1,91
ffffffffc0203fc8:	00004517          	auipc	a0,0x4
ffffffffc0203fcc:	e7050513          	addi	a0,a0,-400 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203fd0:	cb0fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd4:	00004697          	auipc	a3,0x4
ffffffffc0203fd8:	cdc68693          	addi	a3,a3,-804 # ffffffffc0207cb0 <default_pmm_manager+0x968>
ffffffffc0203fdc:	00003617          	auipc	a2,0x3
ffffffffc0203fe0:	c2460613          	addi	a2,a2,-988 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0203fe4:	05800593          	li	a1,88
ffffffffc0203fe8:	00004517          	auipc	a0,0x4
ffffffffc0203fec:	e5050513          	addi	a0,a0,-432 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0203ff0:	c90fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203ff4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203ff4:	7518                	ld	a4,40(a0)
{
ffffffffc0203ff6:	1141                	addi	sp,sp,-16
ffffffffc0203ff8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203ffa:	c731                	beqz	a4,ffffffffc0204046 <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0203ffc:	e60d                	bnez	a2,ffffffffc0204026 <_fifo_swap_out_victim+0x32>
    return listelm->next;
ffffffffc0203ffe:	671c                	ld	a5,8(a4)
    if (entry != head) {
ffffffffc0204000:	00f70d63          	beq	a4,a5,ffffffffc020401a <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204004:	6394                	ld	a3,0(a5)
ffffffffc0204006:	6798                	ld	a4,8(a5)
}
ffffffffc0204008:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc020400a:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020400e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204010:	e314                	sd	a3,0(a4)
ffffffffc0204012:	e19c                	sd	a5,0(a1)
}
ffffffffc0204014:	4501                	li	a0,0
ffffffffc0204016:	0141                	addi	sp,sp,16
ffffffffc0204018:	8082                	ret
ffffffffc020401a:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc020401c:	0005b023          	sd	zero,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
}
ffffffffc0204020:	4501                	li	a0,0
ffffffffc0204022:	0141                	addi	sp,sp,16
ffffffffc0204024:	8082                	ret
     assert(in_tick==0);
ffffffffc0204026:	00004697          	auipc	a3,0x4
ffffffffc020402a:	f9268693          	addi	a3,a3,-110 # ffffffffc0207fb8 <default_pmm_manager+0xc70>
ffffffffc020402e:	00003617          	auipc	a2,0x3
ffffffffc0204032:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204036:	04200593          	li	a1,66
ffffffffc020403a:	00004517          	auipc	a0,0x4
ffffffffc020403e:	dfe50513          	addi	a0,a0,-514 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0204042:	c3efc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(head != NULL);
ffffffffc0204046:	00004697          	auipc	a3,0x4
ffffffffc020404a:	f6268693          	addi	a3,a3,-158 # ffffffffc0207fa8 <default_pmm_manager+0xc60>
ffffffffc020404e:	00003617          	auipc	a2,0x3
ffffffffc0204052:	bb260613          	addi	a2,a2,-1102 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204056:	04100593          	li	a1,65
ffffffffc020405a:	00004517          	auipc	a0,0x4
ffffffffc020405e:	dde50513          	addi	a0,a0,-546 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
ffffffffc0204062:	c1efc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204066 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204066:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020406a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020406c:	cb09                	beqz	a4,ffffffffc020407e <_fifo_map_swappable+0x18>
ffffffffc020406e:	cb81                	beqz	a5,ffffffffc020407e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204070:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204072:	e398                	sd	a4,0(a5)
}
ffffffffc0204074:	4501                	li	a0,0
ffffffffc0204076:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204078:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020407a:	f614                	sd	a3,40(a2)
ffffffffc020407c:	8082                	ret
{
ffffffffc020407e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204080:	00004697          	auipc	a3,0x4
ffffffffc0204084:	f0868693          	addi	a3,a3,-248 # ffffffffc0207f88 <default_pmm_manager+0xc40>
ffffffffc0204088:	00003617          	auipc	a2,0x3
ffffffffc020408c:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204090:	03200593          	li	a1,50
ffffffffc0204094:	00004517          	auipc	a0,0x4
ffffffffc0204098:	da450513          	addi	a0,a0,-604 # ffffffffc0207e38 <default_pmm_manager+0xaf0>
{
ffffffffc020409c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020409e:	be2fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02040a2 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040a2:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040a4:	00004697          	auipc	a3,0x4
ffffffffc02040a8:	f3c68693          	addi	a3,a3,-196 # ffffffffc0207fe0 <default_pmm_manager+0xc98>
ffffffffc02040ac:	00003617          	auipc	a2,0x3
ffffffffc02040b0:	b5460613          	addi	a2,a2,-1196 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02040b4:	06d00593          	li	a1,109
ffffffffc02040b8:	00004517          	auipc	a0,0x4
ffffffffc02040bc:	f4850513          	addi	a0,a0,-184 # ffffffffc0208000 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040c0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040c2:	bbefc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02040c6 <mm_create>:
mm_create(void) {
ffffffffc02040c6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040c8:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02040cc:	e022                	sd	s0,0(sp)
ffffffffc02040ce:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040d0:	b89fd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc02040d4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040d6:	c515                	beqz	a0,ffffffffc0204102 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040d8:	000a8797          	auipc	a5,0xa8
ffffffffc02040dc:	77078793          	addi	a5,a5,1904 # ffffffffc02ac848 <swap_init_ok>
ffffffffc02040e0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040e2:	e408                	sd	a0,8(s0)
ffffffffc02040e4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040e6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040ea:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040ee:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040f2:	2781                	sext.w	a5,a5
ffffffffc02040f4:	ef81                	bnez	a5,ffffffffc020410c <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02040f6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040fa:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040fe:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204102:	8522                	mv	a0,s0
ffffffffc0204104:	60a2                	ld	ra,8(sp)
ffffffffc0204106:	6402                	ld	s0,0(sp)
ffffffffc0204108:	0141                	addi	sp,sp,16
ffffffffc020410a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020410c:	9f1ff0ef          	jal	ra,ffffffffc0203afc <swap_init_mm>
ffffffffc0204110:	b7ed                	j	ffffffffc02040fa <mm_create+0x34>

ffffffffc0204112 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204112:	1101                	addi	sp,sp,-32
ffffffffc0204114:	e04a                	sd	s2,0(sp)
ffffffffc0204116:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204118:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020411c:	e822                	sd	s0,16(sp)
ffffffffc020411e:	e426                	sd	s1,8(sp)
ffffffffc0204120:	ec06                	sd	ra,24(sp)
ffffffffc0204122:	84ae                	mv	s1,a1
ffffffffc0204124:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204126:	b33fd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
    if (vma != NULL) {
ffffffffc020412a:	c509                	beqz	a0,ffffffffc0204134 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020412c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204130:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204132:	cd00                	sw	s0,24(a0)
}
ffffffffc0204134:	60e2                	ld	ra,24(sp)
ffffffffc0204136:	6442                	ld	s0,16(sp)
ffffffffc0204138:	64a2                	ld	s1,8(sp)
ffffffffc020413a:	6902                	ld	s2,0(sp)
ffffffffc020413c:	6105                	addi	sp,sp,32
ffffffffc020413e:	8082                	ret

ffffffffc0204140 <find_vma>:
    if (mm != NULL) {
ffffffffc0204140:	c51d                	beqz	a0,ffffffffc020416e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204142:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204144:	c781                	beqz	a5,ffffffffc020414c <find_vma+0xc>
ffffffffc0204146:	6798                	ld	a4,8(a5)
ffffffffc0204148:	02e5f663          	bgeu	a1,a4,ffffffffc0204174 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020414c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020414e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204150:	00f50f63          	beq	a0,a5,ffffffffc020416e <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204154:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204158:	fee5ebe3          	bltu	a1,a4,ffffffffc020414e <find_vma+0xe>
ffffffffc020415c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204160:	fee5f7e3          	bgeu	a1,a4,ffffffffc020414e <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204164:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204166:	c781                	beqz	a5,ffffffffc020416e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204168:	e91c                	sd	a5,16(a0)
}
ffffffffc020416a:	853e                	mv	a0,a5
ffffffffc020416c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020416e:	4781                	li	a5,0
}
ffffffffc0204170:	853e                	mv	a0,a5
ffffffffc0204172:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204174:	6b98                	ld	a4,16(a5)
ffffffffc0204176:	fce5fbe3          	bgeu	a1,a4,ffffffffc020414c <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020417a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020417c:	b7fd                	j	ffffffffc020416a <find_vma+0x2a>

ffffffffc020417e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020417e:	6590                	ld	a2,8(a1)
ffffffffc0204180:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204184:	1141                	addi	sp,sp,-16
ffffffffc0204186:	e406                	sd	ra,8(sp)
ffffffffc0204188:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020418a:	01066863          	bltu	a2,a6,ffffffffc020419a <insert_vma_struct+0x1c>
ffffffffc020418e:	a8b9                	j	ffffffffc02041ec <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204190:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204194:	04d66763          	bltu	a2,a3,ffffffffc02041e2 <insert_vma_struct+0x64>
ffffffffc0204198:	873e                	mv	a4,a5
ffffffffc020419a:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020419c:	fef51ae3          	bne	a0,a5,ffffffffc0204190 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041a0:	02a70463          	beq	a4,a0,ffffffffc02041c8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041a4:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041a8:	fe873883          	ld	a7,-24(a4)
ffffffffc02041ac:	08d8f063          	bgeu	a7,a3,ffffffffc020422c <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041b0:	04d66e63          	bltu	a2,a3,ffffffffc020420c <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041b4:	00f50a63          	beq	a0,a5,ffffffffc02041c8 <insert_vma_struct+0x4a>
ffffffffc02041b8:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041bc:	0506e863          	bltu	a3,a6,ffffffffc020420c <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041c0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041c4:	02c6f263          	bgeu	a3,a2,ffffffffc02041e8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041c8:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041ca:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041cc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041d0:	e390                	sd	a2,0(a5)
ffffffffc02041d2:	e710                	sd	a2,8(a4)
}
ffffffffc02041d4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041d6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041d8:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041da:	2685                	addiw	a3,a3,1
ffffffffc02041dc:	d114                	sw	a3,32(a0)
}
ffffffffc02041de:	0141                	addi	sp,sp,16
ffffffffc02041e0:	8082                	ret
    if (le_prev != list) {
ffffffffc02041e2:	fca711e3          	bne	a4,a0,ffffffffc02041a4 <insert_vma_struct+0x26>
ffffffffc02041e6:	bfd9                	j	ffffffffc02041bc <insert_vma_struct+0x3e>
ffffffffc02041e8:	ebbff0ef          	jal	ra,ffffffffc02040a2 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041ec:	00004697          	auipc	a3,0x4
ffffffffc02041f0:	f0468693          	addi	a3,a3,-252 # ffffffffc02080f0 <default_pmm_manager+0xda8>
ffffffffc02041f4:	00003617          	auipc	a2,0x3
ffffffffc02041f8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02041fc:	07400593          	li	a1,116
ffffffffc0204200:	00004517          	auipc	a0,0x4
ffffffffc0204204:	e0050513          	addi	a0,a0,-512 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204208:	a78fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020420c:	00004697          	auipc	a3,0x4
ffffffffc0204210:	f2468693          	addi	a3,a3,-220 # ffffffffc0208130 <default_pmm_manager+0xde8>
ffffffffc0204214:	00003617          	auipc	a2,0x3
ffffffffc0204218:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020421c:	06c00593          	li	a1,108
ffffffffc0204220:	00004517          	auipc	a0,0x4
ffffffffc0204224:	de050513          	addi	a0,a0,-544 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204228:	a58fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020422c:	00004697          	auipc	a3,0x4
ffffffffc0204230:	ee468693          	addi	a3,a3,-284 # ffffffffc0208110 <default_pmm_manager+0xdc8>
ffffffffc0204234:	00003617          	auipc	a2,0x3
ffffffffc0204238:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020423c:	06b00593          	li	a1,107
ffffffffc0204240:	00004517          	auipc	a0,0x4
ffffffffc0204244:	dc050513          	addi	a0,a0,-576 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204248:	a38fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020424c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020424c:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020424e:	1141                	addi	sp,sp,-16
ffffffffc0204250:	e406                	sd	ra,8(sp)
ffffffffc0204252:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204254:	e78d                	bnez	a5,ffffffffc020427e <mm_destroy+0x32>
ffffffffc0204256:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204258:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020425a:	00a40c63          	beq	s0,a0,ffffffffc0204272 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020425e:	6118                	ld	a4,0(a0)
ffffffffc0204260:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204262:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204264:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204266:	e398                	sd	a4,0(a5)
ffffffffc0204268:	aadfd0ef          	jal	ra,ffffffffc0201d14 <kfree>
    return listelm->next;
ffffffffc020426c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020426e:	fea418e3          	bne	s0,a0,ffffffffc020425e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204272:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204274:	6402                	ld	s0,0(sp)
ffffffffc0204276:	60a2                	ld	ra,8(sp)
ffffffffc0204278:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020427a:	a9bfd06f          	j	ffffffffc0201d14 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020427e:	00004697          	auipc	a3,0x4
ffffffffc0204282:	ed268693          	addi	a3,a3,-302 # ffffffffc0208150 <default_pmm_manager+0xe08>
ffffffffc0204286:	00003617          	auipc	a2,0x3
ffffffffc020428a:	97a60613          	addi	a2,a2,-1670 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020428e:	09400593          	li	a1,148
ffffffffc0204292:	00004517          	auipc	a0,0x4
ffffffffc0204296:	d6e50513          	addi	a0,a0,-658 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020429a:	9e6fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020429e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020429e:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02042a0:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042a2:	17fd                	addi	a5,a5,-1
ffffffffc02042a4:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02042a6:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042a8:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02042ac:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ae:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042b0:	fc06                	sd	ra,56(sp)
ffffffffc02042b2:	f04a                	sd	s2,32(sp)
ffffffffc02042b4:	ec4e                	sd	s3,24(sp)
ffffffffc02042b6:	e852                	sd	s4,16(sp)
ffffffffc02042b8:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ba:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042be:	002007b7          	lui	a5,0x200
ffffffffc02042c2:	01047433          	and	s0,s0,a6
ffffffffc02042c6:	06f4e363          	bltu	s1,a5,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042ca:	0684f163          	bgeu	s1,s0,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042ce:	4785                	li	a5,1
ffffffffc02042d0:	07fe                	slli	a5,a5,0x1f
ffffffffc02042d2:	0487ed63          	bltu	a5,s0,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042d6:	89aa                	mv	s3,a0
ffffffffc02042d8:	8a3a                	mv	s4,a4
ffffffffc02042da:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042dc:	c931                	beqz	a0,ffffffffc0204330 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042de:	85a6                	mv	a1,s1
ffffffffc02042e0:	e61ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc02042e4:	c501                	beqz	a0,ffffffffc02042ec <mm_map+0x4e>
ffffffffc02042e6:	651c                	ld	a5,8(a0)
ffffffffc02042e8:	0487e263          	bltu	a5,s0,ffffffffc020432c <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042ec:	03000513          	li	a0,48
ffffffffc02042f0:	969fd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc02042f4:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042f6:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02042f8:	02090163          	beqz	s2,ffffffffc020431a <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042fc:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042fe:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204302:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204306:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020430a:	85ca                	mv	a1,s2
ffffffffc020430c:	e73ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204310:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204312:	000a0463          	beqz	s4,ffffffffc020431a <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204316:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020431a:	70e2                	ld	ra,56(sp)
ffffffffc020431c:	7442                	ld	s0,48(sp)
ffffffffc020431e:	74a2                	ld	s1,40(sp)
ffffffffc0204320:	7902                	ld	s2,32(sp)
ffffffffc0204322:	69e2                	ld	s3,24(sp)
ffffffffc0204324:	6a42                	ld	s4,16(sp)
ffffffffc0204326:	6aa2                	ld	s5,8(sp)
ffffffffc0204328:	6121                	addi	sp,sp,64
ffffffffc020432a:	8082                	ret
        return -E_INVAL;
ffffffffc020432c:	5575                	li	a0,-3
ffffffffc020432e:	b7f5                	j	ffffffffc020431a <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204330:	00004697          	auipc	a3,0x4
ffffffffc0204334:	80868693          	addi	a3,a3,-2040 # ffffffffc0207b38 <default_pmm_manager+0x7f0>
ffffffffc0204338:	00003617          	auipc	a2,0x3
ffffffffc020433c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204340:	0a700593          	li	a1,167
ffffffffc0204344:	00004517          	auipc	a0,0x4
ffffffffc0204348:	cbc50513          	addi	a0,a0,-836 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020434c:	934fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204350 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204350:	7139                	addi	sp,sp,-64
ffffffffc0204352:	fc06                	sd	ra,56(sp)
ffffffffc0204354:	f822                	sd	s0,48(sp)
ffffffffc0204356:	f426                	sd	s1,40(sp)
ffffffffc0204358:	f04a                	sd	s2,32(sp)
ffffffffc020435a:	ec4e                	sd	s3,24(sp)
ffffffffc020435c:	e852                	sd	s4,16(sp)
ffffffffc020435e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204360:	c535                	beqz	a0,ffffffffc02043cc <dup_mmap+0x7c>
ffffffffc0204362:	892a                	mv	s2,a0
ffffffffc0204364:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204366:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204368:	e59d                	bnez	a1,ffffffffc0204396 <dup_mmap+0x46>
ffffffffc020436a:	a08d                	j	ffffffffc02043cc <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020436c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020436e:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5540>
        insert_vma_struct(to, nvma);
ffffffffc0204372:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204374:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204378:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020437c:	e03ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204380:	ff043683          	ld	a3,-16(s0)
ffffffffc0204384:	fe843603          	ld	a2,-24(s0)
ffffffffc0204388:	6c8c                	ld	a1,24(s1)
ffffffffc020438a:	01893503          	ld	a0,24(s2)
ffffffffc020438e:	4701                	li	a4,0
ffffffffc0204390:	d1ffe0ef          	jal	ra,ffffffffc02030ae <copy_range>
ffffffffc0204394:	e105                	bnez	a0,ffffffffc02043b4 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204396:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204398:	02848863          	beq	s1,s0,ffffffffc02043c8 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020439c:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043a0:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043a4:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043a8:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ac:	8adfd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc02043b0:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043b2:	fd4d                	bnez	a0,ffffffffc020436c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043b4:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043b6:	70e2                	ld	ra,56(sp)
ffffffffc02043b8:	7442                	ld	s0,48(sp)
ffffffffc02043ba:	74a2                	ld	s1,40(sp)
ffffffffc02043bc:	7902                	ld	s2,32(sp)
ffffffffc02043be:	69e2                	ld	s3,24(sp)
ffffffffc02043c0:	6a42                	ld	s4,16(sp)
ffffffffc02043c2:	6aa2                	ld	s5,8(sp)
ffffffffc02043c4:	6121                	addi	sp,sp,64
ffffffffc02043c6:	8082                	ret
    return 0;
ffffffffc02043c8:	4501                	li	a0,0
ffffffffc02043ca:	b7f5                	j	ffffffffc02043b6 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043cc:	00004697          	auipc	a3,0x4
ffffffffc02043d0:	ce468693          	addi	a3,a3,-796 # ffffffffc02080b0 <default_pmm_manager+0xd68>
ffffffffc02043d4:	00003617          	auipc	a2,0x3
ffffffffc02043d8:	82c60613          	addi	a2,a2,-2004 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02043dc:	0c000593          	li	a1,192
ffffffffc02043e0:	00004517          	auipc	a0,0x4
ffffffffc02043e4:	c2050513          	addi	a0,a0,-992 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02043e8:	898fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02043ec <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043ec:	1101                	addi	sp,sp,-32
ffffffffc02043ee:	ec06                	sd	ra,24(sp)
ffffffffc02043f0:	e822                	sd	s0,16(sp)
ffffffffc02043f2:	e426                	sd	s1,8(sp)
ffffffffc02043f4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043f6:	c531                	beqz	a0,ffffffffc0204442 <exit_mmap+0x56>
ffffffffc02043f8:	591c                	lw	a5,48(a0)
ffffffffc02043fa:	84aa                	mv	s1,a0
ffffffffc02043fc:	e3b9                	bnez	a5,ffffffffc0204442 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043fe:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204400:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204404:	02850663          	beq	a0,s0,ffffffffc0204430 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204408:	ff043603          	ld	a2,-16(s0)
ffffffffc020440c:	fe843583          	ld	a1,-24(s0)
ffffffffc0204410:	854a                	mv	a0,s2
ffffffffc0204412:	d77fd0ef          	jal	ra,ffffffffc0202188 <unmap_range>
ffffffffc0204416:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204418:	fe8498e3          	bne	s1,s0,ffffffffc0204408 <exit_mmap+0x1c>
ffffffffc020441c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020441e:	00848c63          	beq	s1,s0,ffffffffc0204436 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204422:	ff043603          	ld	a2,-16(s0)
ffffffffc0204426:	fe843583          	ld	a1,-24(s0)
ffffffffc020442a:	854a                	mv	a0,s2
ffffffffc020442c:	e75fd0ef          	jal	ra,ffffffffc02022a0 <exit_range>
ffffffffc0204430:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204432:	fe8498e3          	bne	s1,s0,ffffffffc0204422 <exit_mmap+0x36>
    }
}
ffffffffc0204436:	60e2                	ld	ra,24(sp)
ffffffffc0204438:	6442                	ld	s0,16(sp)
ffffffffc020443a:	64a2                	ld	s1,8(sp)
ffffffffc020443c:	6902                	ld	s2,0(sp)
ffffffffc020443e:	6105                	addi	sp,sp,32
ffffffffc0204440:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204442:	00004697          	auipc	a3,0x4
ffffffffc0204446:	c8e68693          	addi	a3,a3,-882 # ffffffffc02080d0 <default_pmm_manager+0xd88>
ffffffffc020444a:	00002617          	auipc	a2,0x2
ffffffffc020444e:	7b660613          	addi	a2,a2,1974 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204452:	0d600593          	li	a1,214
ffffffffc0204456:	00004517          	auipc	a0,0x4
ffffffffc020445a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020445e:	822fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204462 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204462:	7139                	addi	sp,sp,-64
ffffffffc0204464:	f822                	sd	s0,48(sp)
ffffffffc0204466:	f426                	sd	s1,40(sp)
ffffffffc0204468:	fc06                	sd	ra,56(sp)
ffffffffc020446a:	f04a                	sd	s2,32(sp)
ffffffffc020446c:	ec4e                	sd	s3,24(sp)
ffffffffc020446e:	e852                	sd	s4,16(sp)
ffffffffc0204470:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204472:	c55ff0ef          	jal	ra,ffffffffc02040c6 <mm_create>
    assert(mm != NULL);
ffffffffc0204476:	842a                	mv	s0,a0
ffffffffc0204478:	03200493          	li	s1,50
ffffffffc020447c:	e919                	bnez	a0,ffffffffc0204492 <vmm_init+0x30>
ffffffffc020447e:	a989                	j	ffffffffc02048d0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204480:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204482:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204484:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204488:	14ed                	addi	s1,s1,-5
ffffffffc020448a:	8522                	mv	a0,s0
ffffffffc020448c:	cf3ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204490:	c88d                	beqz	s1,ffffffffc02044c2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204492:	03000513          	li	a0,48
ffffffffc0204496:	fc2fd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc020449a:	85aa                	mv	a1,a0
ffffffffc020449c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044a0:	f165                	bnez	a0,ffffffffc0204480 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044a2:	00003697          	auipc	a3,0x3
ffffffffc02044a6:	6ce68693          	addi	a3,a3,1742 # ffffffffc0207b70 <default_pmm_manager+0x828>
ffffffffc02044aa:	00002617          	auipc	a2,0x2
ffffffffc02044ae:	75660613          	addi	a2,a2,1878 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02044b2:	11300593          	li	a1,275
ffffffffc02044b6:	00004517          	auipc	a0,0x4
ffffffffc02044ba:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02044be:	fc3fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044c2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044c6:	1f900913          	li	s2,505
ffffffffc02044ca:	a819                	j	ffffffffc02044e0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044cc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044ce:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044d0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044d4:	0495                	addi	s1,s1,5
ffffffffc02044d6:	8522                	mv	a0,s0
ffffffffc02044d8:	ca7ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044dc:	03248a63          	beq	s1,s2,ffffffffc0204510 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044e0:	03000513          	li	a0,48
ffffffffc02044e4:	f74fd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc02044e8:	85aa                	mv	a1,a0
ffffffffc02044ea:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044ee:	fd79                	bnez	a0,ffffffffc02044cc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044f0:	00003697          	auipc	a3,0x3
ffffffffc02044f4:	68068693          	addi	a3,a3,1664 # ffffffffc0207b70 <default_pmm_manager+0x828>
ffffffffc02044f8:	00002617          	auipc	a2,0x2
ffffffffc02044fc:	70860613          	addi	a2,a2,1800 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204500:	11900593          	li	a1,281
ffffffffc0204504:	00004517          	auipc	a0,0x4
ffffffffc0204508:	afc50513          	addi	a0,a0,-1284 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020450c:	f75fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204510:	6418                	ld	a4,8(s0)
ffffffffc0204512:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204514:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204518:	2ee40063          	beq	s0,a4,ffffffffc02047f8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020451c:	fe873603          	ld	a2,-24(a4)
ffffffffc0204520:	ffe78693          	addi	a3,a5,-2
ffffffffc0204524:	24d61a63          	bne	a2,a3,ffffffffc0204778 <vmm_init+0x316>
ffffffffc0204528:	ff073683          	ld	a3,-16(a4)
ffffffffc020452c:	24f69663          	bne	a3,a5,ffffffffc0204778 <vmm_init+0x316>
ffffffffc0204530:	0795                	addi	a5,a5,5
ffffffffc0204532:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204534:	feb792e3          	bne	a5,a1,ffffffffc0204518 <vmm_init+0xb6>
ffffffffc0204538:	491d                	li	s2,7
ffffffffc020453a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020453c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204540:	85a6                	mv	a1,s1
ffffffffc0204542:	8522                	mv	a0,s0
ffffffffc0204544:	bfdff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204548:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020454a:	30050763          	beqz	a0,ffffffffc0204858 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020454e:	00148593          	addi	a1,s1,1
ffffffffc0204552:	8522                	mv	a0,s0
ffffffffc0204554:	bedff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204558:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020455a:	2c050f63          	beqz	a0,ffffffffc0204838 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020455e:	85ca                	mv	a1,s2
ffffffffc0204560:	8522                	mv	a0,s0
ffffffffc0204562:	bdfff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204566:	2a051963          	bnez	a0,ffffffffc0204818 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020456a:	00348593          	addi	a1,s1,3
ffffffffc020456e:	8522                	mv	a0,s0
ffffffffc0204570:	bd1ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204574:	32051263          	bnez	a0,ffffffffc0204898 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204578:	00448593          	addi	a1,s1,4
ffffffffc020457c:	8522                	mv	a0,s0
ffffffffc020457e:	bc3ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204582:	2e051b63          	bnez	a0,ffffffffc0204878 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204586:	008a3783          	ld	a5,8(s4)
ffffffffc020458a:	20979763          	bne	a5,s1,ffffffffc0204798 <vmm_init+0x336>
ffffffffc020458e:	010a3783          	ld	a5,16(s4)
ffffffffc0204592:	21279363          	bne	a5,s2,ffffffffc0204798 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204596:	0089b783          	ld	a5,8(s3)
ffffffffc020459a:	20979f63          	bne	a5,s1,ffffffffc02047b8 <vmm_init+0x356>
ffffffffc020459e:	0109b783          	ld	a5,16(s3)
ffffffffc02045a2:	21279b63          	bne	a5,s2,ffffffffc02047b8 <vmm_init+0x356>
ffffffffc02045a6:	0495                	addi	s1,s1,5
ffffffffc02045a8:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045aa:	f9549be3          	bne	s1,s5,ffffffffc0204540 <vmm_init+0xde>
ffffffffc02045ae:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045b0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045b2:	85a6                	mv	a1,s1
ffffffffc02045b4:	8522                	mv	a0,s0
ffffffffc02045b6:	b8bff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc02045ba:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045be:	c90d                	beqz	a0,ffffffffc02045f0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045c0:	6914                	ld	a3,16(a0)
ffffffffc02045c2:	6510                	ld	a2,8(a0)
ffffffffc02045c4:	00004517          	auipc	a0,0x4
ffffffffc02045c8:	ca450513          	addi	a0,a0,-860 # ffffffffc0208268 <default_pmm_manager+0xf20>
ffffffffc02045cc:	bc3fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045d0:	00004697          	auipc	a3,0x4
ffffffffc02045d4:	cc068693          	addi	a3,a3,-832 # ffffffffc0208290 <default_pmm_manager+0xf48>
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	62860613          	addi	a2,a2,1576 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02045e0:	13b00593          	li	a1,315
ffffffffc02045e4:	00004517          	auipc	a0,0x4
ffffffffc02045e8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02045ec:	e95fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc02045f0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045f2:	fd2490e3          	bne	s1,s2,ffffffffc02045b2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045f6:	8522                	mv	a0,s0
ffffffffc02045f8:	c55ff0ef          	jal	ra,ffffffffc020424c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045fc:	00004517          	auipc	a0,0x4
ffffffffc0204600:	cac50513          	addi	a0,a0,-852 # ffffffffc02082a8 <default_pmm_manager+0xf60>
ffffffffc0204604:	b8bfb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204608:	917fd0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc020460c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020460e:	ab9ff0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0204612:	000a8797          	auipc	a5,0xa8
ffffffffc0204616:	36a7bb23          	sd	a0,886(a5) # ffffffffc02ac988 <check_mm_struct>
ffffffffc020461a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020461c:	36050663          	beqz	a0,ffffffffc0204988 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204620:	000a8797          	auipc	a5,0xa8
ffffffffc0204624:	21078793          	addi	a5,a5,528 # ffffffffc02ac830 <boot_pgdir>
ffffffffc0204628:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020462c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204630:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204634:	2c079e63          	bnez	a5,ffffffffc0204910 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204638:	03000513          	li	a0,48
ffffffffc020463c:	e1cfd0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc0204640:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204642:	18050b63          	beqz	a0,ffffffffc02047d8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204646:	002007b7          	lui	a5,0x200
ffffffffc020464a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020464c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020464e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204650:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204652:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204654:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204658:	b27ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020465c:	10000593          	li	a1,256
ffffffffc0204660:	8526                	mv	a0,s1
ffffffffc0204662:	adfff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204666:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020466a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020466e:	2ca41163          	bne	s0,a0,ffffffffc0204930 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204672:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc0204676:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0204678:	fee79de3          	bne	a5,a4,ffffffffc0204672 <vmm_init+0x210>
        sum += i;
ffffffffc020467c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020467e:	10000793          	li	a5,256
        sum += i;
ffffffffc0204682:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204686:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020468a:	0007c683          	lbu	a3,0(a5)
ffffffffc020468e:	0785                	addi	a5,a5,1
ffffffffc0204690:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204692:	fec79ce3          	bne	a5,a2,ffffffffc020468a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204696:	2c071963          	bnez	a4,ffffffffc0204968 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020469a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020469e:	000a8a97          	auipc	s5,0xa8
ffffffffc02046a2:	19aa8a93          	addi	s5,s5,410 # ffffffffc02ac838 <npage>
ffffffffc02046a6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046aa:	078a                	slli	a5,a5,0x2
ffffffffc02046ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046ae:	20e7f563          	bgeu	a5,a4,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046b2:	00004697          	auipc	a3,0x4
ffffffffc02046b6:	61668693          	addi	a3,a3,1558 # ffffffffc0208cc8 <nbase>
ffffffffc02046ba:	0006ba03          	ld	s4,0(a3)
ffffffffc02046be:	414786b3          	sub	a3,a5,s4
ffffffffc02046c2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046c4:	8699                	srai	a3,a3,0x6
ffffffffc02046c6:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046c8:	00c69793          	slli	a5,a3,0xc
ffffffffc02046cc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02046ce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046d0:	28e7f063          	bgeu	a5,a4,ffffffffc0204950 <vmm_init+0x4ee>
ffffffffc02046d4:	000a8797          	auipc	a5,0xa8
ffffffffc02046d8:	1c478793          	addi	a5,a5,452 # ffffffffc02ac898 <va_pa_offset>
ffffffffc02046dc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046de:	4581                	li	a1,0
ffffffffc02046e0:	854a                	mv	a0,s2
ffffffffc02046e2:	9436                	add	s0,s0,a3
ffffffffc02046e4:	e13fd0ef          	jal	ra,ffffffffc02024f6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046e8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046ea:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ee:	078a                	slli	a5,a5,0x2
ffffffffc02046f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046f2:	1ce7f363          	bgeu	a5,a4,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046f6:	000a8417          	auipc	s0,0xa8
ffffffffc02046fa:	1b240413          	addi	s0,s0,434 # ffffffffc02ac8a8 <pages>
ffffffffc02046fe:	6008                	ld	a0,0(s0)
ffffffffc0204700:	414787b3          	sub	a5,a5,s4
ffffffffc0204704:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204706:	953e                	add	a0,a0,a5
ffffffffc0204708:	4585                	li	a1,1
ffffffffc020470a:	fcefd0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020470e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204712:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204716:	078a                	slli	a5,a5,0x2
ffffffffc0204718:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020471a:	18e7ff63          	bgeu	a5,a4,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020471e:	6008                	ld	a0,0(s0)
ffffffffc0204720:	414787b3          	sub	a5,a5,s4
ffffffffc0204724:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204726:	4585                	li	a1,1
ffffffffc0204728:	953e                	add	a0,a0,a5
ffffffffc020472a:	faefd0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    pgdir[0] = 0;
ffffffffc020472e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204732:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204736:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020473a:	8526                	mv	a0,s1
ffffffffc020473c:	b11ff0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204740:	000a8797          	auipc	a5,0xa8
ffffffffc0204744:	2407b423          	sd	zero,584(a5) # ffffffffc02ac988 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204748:	fd6fd0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
ffffffffc020474c:	1aa99263          	bne	s3,a0,ffffffffc02048f0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204750:	00004517          	auipc	a0,0x4
ffffffffc0204754:	be850513          	addi	a0,a0,-1048 # ffffffffc0208338 <default_pmm_manager+0xff0>
ffffffffc0204758:	a37fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020475c:	7442                	ld	s0,48(sp)
ffffffffc020475e:	70e2                	ld	ra,56(sp)
ffffffffc0204760:	74a2                	ld	s1,40(sp)
ffffffffc0204762:	7902                	ld	s2,32(sp)
ffffffffc0204764:	69e2                	ld	s3,24(sp)
ffffffffc0204766:	6a42                	ld	s4,16(sp)
ffffffffc0204768:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020476a:	00004517          	auipc	a0,0x4
ffffffffc020476e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0208358 <default_pmm_manager+0x1010>
}
ffffffffc0204772:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204774:	a1bfb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204778:	00004697          	auipc	a3,0x4
ffffffffc020477c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0208180 <default_pmm_manager+0xe38>
ffffffffc0204780:	00002617          	auipc	a2,0x2
ffffffffc0204784:	48060613          	addi	a2,a2,1152 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204788:	12200593          	li	a1,290
ffffffffc020478c:	00004517          	auipc	a0,0x4
ffffffffc0204790:	87450513          	addi	a0,a0,-1932 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204794:	cedfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204798:	00004697          	auipc	a3,0x4
ffffffffc020479c:	a7068693          	addi	a3,a3,-1424 # ffffffffc0208208 <default_pmm_manager+0xec0>
ffffffffc02047a0:	00002617          	auipc	a2,0x2
ffffffffc02047a4:	46060613          	addi	a2,a2,1120 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02047a8:	13200593          	li	a1,306
ffffffffc02047ac:	00004517          	auipc	a0,0x4
ffffffffc02047b0:	85450513          	addi	a0,a0,-1964 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02047b4:	ccdfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047b8:	00004697          	auipc	a3,0x4
ffffffffc02047bc:	a8068693          	addi	a3,a3,-1408 # ffffffffc0208238 <default_pmm_manager+0xef0>
ffffffffc02047c0:	00002617          	auipc	a2,0x2
ffffffffc02047c4:	44060613          	addi	a2,a2,1088 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02047c8:	13300593          	li	a1,307
ffffffffc02047cc:	00004517          	auipc	a0,0x4
ffffffffc02047d0:	83450513          	addi	a0,a0,-1996 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02047d4:	cadfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(vma != NULL);
ffffffffc02047d8:	00003697          	auipc	a3,0x3
ffffffffc02047dc:	39868693          	addi	a3,a3,920 # ffffffffc0207b70 <default_pmm_manager+0x828>
ffffffffc02047e0:	00002617          	auipc	a2,0x2
ffffffffc02047e4:	42060613          	addi	a2,a2,1056 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02047e8:	15200593          	li	a1,338
ffffffffc02047ec:	00004517          	auipc	a0,0x4
ffffffffc02047f0:	81450513          	addi	a0,a0,-2028 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02047f4:	c8dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047f8:	00004697          	auipc	a3,0x4
ffffffffc02047fc:	97068693          	addi	a3,a3,-1680 # ffffffffc0208168 <default_pmm_manager+0xe20>
ffffffffc0204800:	00002617          	auipc	a2,0x2
ffffffffc0204804:	40060613          	addi	a2,a2,1024 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204808:	12000593          	li	a1,288
ffffffffc020480c:	00003517          	auipc	a0,0x3
ffffffffc0204810:	7f450513          	addi	a0,a0,2036 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204814:	c6dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma3 == NULL);
ffffffffc0204818:	00004697          	auipc	a3,0x4
ffffffffc020481c:	9c068693          	addi	a3,a3,-1600 # ffffffffc02081d8 <default_pmm_manager+0xe90>
ffffffffc0204820:	00002617          	auipc	a2,0x2
ffffffffc0204824:	3e060613          	addi	a2,a2,992 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204828:	12c00593          	li	a1,300
ffffffffc020482c:	00003517          	auipc	a0,0x3
ffffffffc0204830:	7d450513          	addi	a0,a0,2004 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204834:	c4dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2 != NULL);
ffffffffc0204838:	00004697          	auipc	a3,0x4
ffffffffc020483c:	99068693          	addi	a3,a3,-1648 # ffffffffc02081c8 <default_pmm_manager+0xe80>
ffffffffc0204840:	00002617          	auipc	a2,0x2
ffffffffc0204844:	3c060613          	addi	a2,a2,960 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204848:	12a00593          	li	a1,298
ffffffffc020484c:	00003517          	auipc	a0,0x3
ffffffffc0204850:	7b450513          	addi	a0,a0,1972 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204854:	c2dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1 != NULL);
ffffffffc0204858:	00004697          	auipc	a3,0x4
ffffffffc020485c:	96068693          	addi	a3,a3,-1696 # ffffffffc02081b8 <default_pmm_manager+0xe70>
ffffffffc0204860:	00002617          	auipc	a2,0x2
ffffffffc0204864:	3a060613          	addi	a2,a2,928 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204868:	12800593          	li	a1,296
ffffffffc020486c:	00003517          	auipc	a0,0x3
ffffffffc0204870:	79450513          	addi	a0,a0,1940 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204874:	c0dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma5 == NULL);
ffffffffc0204878:	00004697          	auipc	a3,0x4
ffffffffc020487c:	98068693          	addi	a3,a3,-1664 # ffffffffc02081f8 <default_pmm_manager+0xeb0>
ffffffffc0204880:	00002617          	auipc	a2,0x2
ffffffffc0204884:	38060613          	addi	a2,a2,896 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204888:	13000593          	li	a1,304
ffffffffc020488c:	00003517          	auipc	a0,0x3
ffffffffc0204890:	77450513          	addi	a0,a0,1908 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204894:	bedfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma4 == NULL);
ffffffffc0204898:	00004697          	auipc	a3,0x4
ffffffffc020489c:	95068693          	addi	a3,a3,-1712 # ffffffffc02081e8 <default_pmm_manager+0xea0>
ffffffffc02048a0:	00002617          	auipc	a2,0x2
ffffffffc02048a4:	36060613          	addi	a2,a2,864 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02048a8:	12e00593          	li	a1,302
ffffffffc02048ac:	00003517          	auipc	a0,0x3
ffffffffc02048b0:	75450513          	addi	a0,a0,1876 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02048b4:	bcdfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048b8:	00003617          	auipc	a2,0x3
ffffffffc02048bc:	b4060613          	addi	a2,a2,-1216 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc02048c0:	06200593          	li	a1,98
ffffffffc02048c4:	00003517          	auipc	a0,0x3
ffffffffc02048c8:	afc50513          	addi	a0,a0,-1284 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02048cc:	bb5fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(mm != NULL);
ffffffffc02048d0:	00003697          	auipc	a3,0x3
ffffffffc02048d4:	26868693          	addi	a3,a3,616 # ffffffffc0207b38 <default_pmm_manager+0x7f0>
ffffffffc02048d8:	00002617          	auipc	a2,0x2
ffffffffc02048dc:	32860613          	addi	a2,a2,808 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02048e0:	10c00593          	li	a1,268
ffffffffc02048e4:	00003517          	auipc	a0,0x3
ffffffffc02048e8:	71c50513          	addi	a0,a0,1820 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02048ec:	b95fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048f0:	00004697          	auipc	a3,0x4
ffffffffc02048f4:	a2068693          	addi	a3,a3,-1504 # ffffffffc0208310 <default_pmm_manager+0xfc8>
ffffffffc02048f8:	00002617          	auipc	a2,0x2
ffffffffc02048fc:	30860613          	addi	a2,a2,776 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204900:	17000593          	li	a1,368
ffffffffc0204904:	00003517          	auipc	a0,0x3
ffffffffc0204908:	6fc50513          	addi	a0,a0,1788 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020490c:	b75fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204910:	00003697          	auipc	a3,0x3
ffffffffc0204914:	25068693          	addi	a3,a3,592 # ffffffffc0207b60 <default_pmm_manager+0x818>
ffffffffc0204918:	00002617          	auipc	a2,0x2
ffffffffc020491c:	2e860613          	addi	a2,a2,744 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204920:	14f00593          	li	a1,335
ffffffffc0204924:	00003517          	auipc	a0,0x3
ffffffffc0204928:	6dc50513          	addi	a0,a0,1756 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020492c:	b55fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204930:	00004697          	auipc	a3,0x4
ffffffffc0204934:	9b068693          	addi	a3,a3,-1616 # ffffffffc02082e0 <default_pmm_manager+0xf98>
ffffffffc0204938:	00002617          	auipc	a2,0x2
ffffffffc020493c:	2c860613          	addi	a2,a2,712 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204940:	15700593          	li	a1,343
ffffffffc0204944:	00003517          	auipc	a0,0x3
ffffffffc0204948:	6bc50513          	addi	a0,a0,1724 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc020494c:	b35fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204950:	00003617          	auipc	a2,0x3
ffffffffc0204954:	a4860613          	addi	a2,a2,-1464 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0204958:	06900593          	li	a1,105
ffffffffc020495c:	00003517          	auipc	a0,0x3
ffffffffc0204960:	a6450513          	addi	a0,a0,-1436 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204964:	b1dfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(sum == 0);
ffffffffc0204968:	00004697          	auipc	a3,0x4
ffffffffc020496c:	99868693          	addi	a3,a3,-1640 # ffffffffc0208300 <default_pmm_manager+0xfb8>
ffffffffc0204970:	00002617          	auipc	a2,0x2
ffffffffc0204974:	29060613          	addi	a2,a2,656 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204978:	16300593          	li	a1,355
ffffffffc020497c:	00003517          	auipc	a0,0x3
ffffffffc0204980:	68450513          	addi	a0,a0,1668 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc0204984:	afdfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204988:	00004697          	auipc	a3,0x4
ffffffffc020498c:	94068693          	addi	a3,a3,-1728 # ffffffffc02082c8 <default_pmm_manager+0xf80>
ffffffffc0204990:	00002617          	auipc	a2,0x2
ffffffffc0204994:	27060613          	addi	a2,a2,624 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0204998:	14b00593          	li	a1,331
ffffffffc020499c:	00003517          	auipc	a0,0x3
ffffffffc02049a0:	66450513          	addi	a0,a0,1636 # ffffffffc0208000 <default_pmm_manager+0xcb8>
ffffffffc02049a4:	addfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02049a8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049a8:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049aa:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049ac:	f822                	sd	s0,48(sp)
ffffffffc02049ae:	f426                	sd	s1,40(sp)
ffffffffc02049b0:	fc06                	sd	ra,56(sp)
ffffffffc02049b2:	f04a                	sd	s2,32(sp)
ffffffffc02049b4:	ec4e                	sd	s3,24(sp)
ffffffffc02049b6:	8432                	mv	s0,a2
ffffffffc02049b8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049ba:	f86ff0ef          	jal	ra,ffffffffc0204140 <find_vma>

    pgfault_num++;
ffffffffc02049be:	000a8797          	auipc	a5,0xa8
ffffffffc02049c2:	e8e78793          	addi	a5,a5,-370 # ffffffffc02ac84c <pgfault_num>
ffffffffc02049c6:	439c                	lw	a5,0(a5)
ffffffffc02049c8:	2785                	addiw	a5,a5,1
ffffffffc02049ca:	000a8717          	auipc	a4,0xa8
ffffffffc02049ce:	e8f72123          	sw	a5,-382(a4) # ffffffffc02ac84c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049d2:	c145                	beqz	a0,ffffffffc0204a72 <do_pgfault+0xca>
ffffffffc02049d4:	651c                	ld	a5,8(a0)
ffffffffc02049d6:	08f46e63          	bltu	s0,a5,ffffffffc0204a72 <do_pgfault+0xca>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049da:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049dc:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049de:	8b89                	andi	a5,a5,2
ffffffffc02049e0:	e3b1                	bnez	a5,ffffffffc0204a24 <do_pgfault+0x7c>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049e2:	767d                	lui	a2,0xfffff
    // }


    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049e4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049e6:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049e8:	85a2                	mv	a1,s0
ffffffffc02049ea:	4605                	li	a2,1
ffffffffc02049ec:	d72fd0ef          	jal	ra,ffffffffc0201f5e <get_pte>
ffffffffc02049f0:	c155                	beqz	a0,ffffffffc0204a94 <do_pgfault+0xec>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049f2:	610c                	ld	a1,0(a0)
ffffffffc02049f4:	c1a5                	beqz	a1,ffffffffc0204a54 <do_pgfault+0xac>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02049f6:	000a8797          	auipc	a5,0xa8
ffffffffc02049fa:	e5278793          	addi	a5,a5,-430 # ffffffffc02ac848 <swap_init_ok>
ffffffffc02049fe:	439c                	lw	a5,0(a5)
ffffffffc0204a00:	2781                	sext.w	a5,a5
ffffffffc0204a02:	c3c9                	beqz	a5,ffffffffc0204a84 <do_pgfault+0xdc>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            // cprintf("do_pgfault called!!!\n");
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc0204a04:	0030                	addi	a2,sp,8
ffffffffc0204a06:	85a2                	mv	a1,s0
ffffffffc0204a08:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a0a:	e402                	sd	zero,8(sp)
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc0204a0c:	a24ff0ef          	jal	ra,ffffffffc0203c30 <swap_in>
ffffffffc0204a10:	892a                	mv	s2,a0
ffffffffc0204a12:	c919                	beqz	a0,ffffffffc0204a28 <do_pgfault+0x80>
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a14:	70e2                	ld	ra,56(sp)
ffffffffc0204a16:	7442                	ld	s0,48(sp)
ffffffffc0204a18:	854a                	mv	a0,s2
ffffffffc0204a1a:	74a2                	ld	s1,40(sp)
ffffffffc0204a1c:	7902                	ld	s2,32(sp)
ffffffffc0204a1e:	69e2                	ld	s3,24(sp)
ffffffffc0204a20:	6121                	addi	sp,sp,64
ffffffffc0204a22:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a24:	49dd                	li	s3,23
ffffffffc0204a26:	bf75                	j	ffffffffc02049e2 <do_pgfault+0x3a>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204a28:	65a2                	ld	a1,8(sp)
ffffffffc0204a2a:	6c88                	ld	a0,24(s1)
ffffffffc0204a2c:	86ce                	mv	a3,s3
ffffffffc0204a2e:	8622                	mv	a2,s0
ffffffffc0204a30:	b3bfd0ef          	jal	ra,ffffffffc020256a <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0204a34:	6622                	ld	a2,8(sp)
ffffffffc0204a36:	85a2                	mv	a1,s0
ffffffffc0204a38:	8526                	mv	a0,s1
ffffffffc0204a3a:	4685                	li	a3,1
ffffffffc0204a3c:	8d0ff0ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a40:	67a2                	ld	a5,8(sp)
}
ffffffffc0204a42:	70e2                	ld	ra,56(sp)
ffffffffc0204a44:	854a                	mv	a0,s2
            page->pra_vaddr = addr;
ffffffffc0204a46:	ff80                	sd	s0,56(a5)
}
ffffffffc0204a48:	7442                	ld	s0,48(sp)
ffffffffc0204a4a:	74a2                	ld	s1,40(sp)
ffffffffc0204a4c:	7902                	ld	s2,32(sp)
ffffffffc0204a4e:	69e2                	ld	s3,24(sp)
ffffffffc0204a50:	6121                	addi	sp,sp,64
ffffffffc0204a52:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a54:	6c88                	ld	a0,24(s1)
ffffffffc0204a56:	864e                	mv	a2,s3
ffffffffc0204a58:	85a2                	mv	a1,s0
ffffffffc0204a5a:	88ffe0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a5e:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a60:	f955                	bnez	a0,ffffffffc0204a14 <do_pgfault+0x6c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a62:	00003517          	auipc	a0,0x3
ffffffffc0204a66:	5fe50513          	addi	a0,a0,1534 # ffffffffc0208060 <default_pmm_manager+0xd18>
ffffffffc0204a6a:	f24fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a6e:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a70:	b755                	j	ffffffffc0204a14 <do_pgfault+0x6c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a72:	85a2                	mv	a1,s0
ffffffffc0204a74:	00003517          	auipc	a0,0x3
ffffffffc0204a78:	59c50513          	addi	a0,a0,1436 # ffffffffc0208010 <default_pmm_manager+0xcc8>
ffffffffc0204a7c:	f12fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a80:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a82:	bf49                	j	ffffffffc0204a14 <do_pgfault+0x6c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a84:	00003517          	auipc	a0,0x3
ffffffffc0204a88:	60450513          	addi	a0,a0,1540 # ffffffffc0208088 <default_pmm_manager+0xd40>
ffffffffc0204a8c:	f02fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a90:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a92:	b749                	j	ffffffffc0204a14 <do_pgfault+0x6c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a94:	00003517          	auipc	a0,0x3
ffffffffc0204a98:	5ac50513          	addi	a0,a0,1452 # ffffffffc0208040 <default_pmm_manager+0xcf8>
ffffffffc0204a9c:	ef2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204aa0:	5971                	li	s2,-4
        goto failed;
ffffffffc0204aa2:	bf8d                	j	ffffffffc0204a14 <do_pgfault+0x6c>

ffffffffc0204aa4 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204aa4:	7179                	addi	sp,sp,-48
ffffffffc0204aa6:	f022                	sd	s0,32(sp)
ffffffffc0204aa8:	f406                	sd	ra,40(sp)
ffffffffc0204aaa:	ec26                	sd	s1,24(sp)
ffffffffc0204aac:	e84a                	sd	s2,16(sp)
ffffffffc0204aae:	e44e                	sd	s3,8(sp)
ffffffffc0204ab0:	e052                	sd	s4,0(sp)
ffffffffc0204ab2:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204ab4:	c135                	beqz	a0,ffffffffc0204b18 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ab6:	002007b7          	lui	a5,0x200
ffffffffc0204aba:	04f5e663          	bltu	a1,a5,ffffffffc0204b06 <user_mem_check+0x62>
ffffffffc0204abe:	00c584b3          	add	s1,a1,a2
ffffffffc0204ac2:	0495f263          	bgeu	a1,s1,ffffffffc0204b06 <user_mem_check+0x62>
ffffffffc0204ac6:	4785                	li	a5,1
ffffffffc0204ac8:	07fe                	slli	a5,a5,0x1f
ffffffffc0204aca:	0297ee63          	bltu	a5,s1,ffffffffc0204b06 <user_mem_check+0x62>
ffffffffc0204ace:	892a                	mv	s2,a0
ffffffffc0204ad0:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ad2:	6a05                	lui	s4,0x1
ffffffffc0204ad4:	a821                	j	ffffffffc0204aec <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ad6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ada:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204adc:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ade:	c685                	beqz	a3,ffffffffc0204b06 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204ae0:	c399                	beqz	a5,ffffffffc0204ae6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ae2:	02e46263          	bltu	s0,a4,ffffffffc0204b06 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ae6:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204ae8:	04947663          	bgeu	s0,s1,ffffffffc0204b34 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204aec:	85a2                	mv	a1,s0
ffffffffc0204aee:	854a                	mv	a0,s2
ffffffffc0204af0:	e50ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204af4:	c909                	beqz	a0,ffffffffc0204b06 <user_mem_check+0x62>
ffffffffc0204af6:	6518                	ld	a4,8(a0)
ffffffffc0204af8:	00e46763          	bltu	s0,a4,ffffffffc0204b06 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204afc:	4d1c                	lw	a5,24(a0)
ffffffffc0204afe:	fc099ce3          	bnez	s3,ffffffffc0204ad6 <user_mem_check+0x32>
ffffffffc0204b02:	8b85                	andi	a5,a5,1
ffffffffc0204b04:	f3ed                	bnez	a5,ffffffffc0204ae6 <user_mem_check+0x42>
            return 0;
ffffffffc0204b06:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b08:	70a2                	ld	ra,40(sp)
ffffffffc0204b0a:	7402                	ld	s0,32(sp)
ffffffffc0204b0c:	64e2                	ld	s1,24(sp)
ffffffffc0204b0e:	6942                	ld	s2,16(sp)
ffffffffc0204b10:	69a2                	ld	s3,8(sp)
ffffffffc0204b12:	6a02                	ld	s4,0(sp)
ffffffffc0204b14:	6145                	addi	sp,sp,48
ffffffffc0204b16:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b18:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b1c:	4501                	li	a0,0
ffffffffc0204b1e:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b08 <user_mem_check+0x64>
ffffffffc0204b22:	962e                	add	a2,a2,a1
ffffffffc0204b24:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204b08 <user_mem_check+0x64>
ffffffffc0204b28:	c8000537          	lui	a0,0xc8000
ffffffffc0204b2c:	0505                	addi	a0,a0,1
ffffffffc0204b2e:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b32:	bfd9                	j	ffffffffc0204b08 <user_mem_check+0x64>
        return 1;
ffffffffc0204b34:	4505                	li	a0,1
ffffffffc0204b36:	bfc9                	j	ffffffffc0204b08 <user_mem_check+0x64>

ffffffffc0204b38 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b38:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b3a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b3c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b3e:	ab9fb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204b42:	cd01                	beqz	a0,ffffffffc0204b5a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b44:	4505                	li	a0,1
ffffffffc0204b46:	ab7fb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204b4a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b4c:	810d                	srli	a0,a0,0x3
ffffffffc0204b4e:	000a8797          	auipc	a5,0xa8
ffffffffc0204b52:	dea7b523          	sd	a0,-534(a5) # ffffffffc02ac938 <max_swap_offset>
}
ffffffffc0204b56:	0141                	addi	sp,sp,16
ffffffffc0204b58:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b5a:	00004617          	auipc	a2,0x4
ffffffffc0204b5e:	81660613          	addi	a2,a2,-2026 # ffffffffc0208370 <default_pmm_manager+0x1028>
ffffffffc0204b62:	45b5                	li	a1,13
ffffffffc0204b64:	00004517          	auipc	a0,0x4
ffffffffc0204b68:	82c50513          	addi	a0,a0,-2004 # ffffffffc0208390 <default_pmm_manager+0x1048>
ffffffffc0204b6c:	915fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204b70 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b70:	1141                	addi	sp,sp,-16
ffffffffc0204b72:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b74:	00855793          	srli	a5,a0,0x8
ffffffffc0204b78:	cfb9                	beqz	a5,ffffffffc0204bd6 <swapfs_read+0x66>
ffffffffc0204b7a:	000a8717          	auipc	a4,0xa8
ffffffffc0204b7e:	dbe70713          	addi	a4,a4,-578 # ffffffffc02ac938 <max_swap_offset>
ffffffffc0204b82:	6318                	ld	a4,0(a4)
ffffffffc0204b84:	04e7f963          	bgeu	a5,a4,ffffffffc0204bd6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b88:	000a8717          	auipc	a4,0xa8
ffffffffc0204b8c:	d2070713          	addi	a4,a4,-736 # ffffffffc02ac8a8 <pages>
ffffffffc0204b90:	6310                	ld	a2,0(a4)
ffffffffc0204b92:	00004717          	auipc	a4,0x4
ffffffffc0204b96:	13670713          	addi	a4,a4,310 # ffffffffc0208cc8 <nbase>
ffffffffc0204b9a:	40c58633          	sub	a2,a1,a2
ffffffffc0204b9e:	630c                	ld	a1,0(a4)
ffffffffc0204ba0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204ba2:	000a8717          	auipc	a4,0xa8
ffffffffc0204ba6:	c9670713          	addi	a4,a4,-874 # ffffffffc02ac838 <npage>
    return page - pages + nbase;
ffffffffc0204baa:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bac:	6314                	ld	a3,0(a4)
ffffffffc0204bae:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bb2:	8331                	srli	a4,a4,0xc
ffffffffc0204bb4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bb8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bba:	02d77a63          	bgeu	a4,a3,ffffffffc0204bee <swapfs_read+0x7e>
ffffffffc0204bbe:	000a8797          	auipc	a5,0xa8
ffffffffc0204bc2:	cda78793          	addi	a5,a5,-806 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0204bc6:	639c                	ld	a5,0(a5)
}
ffffffffc0204bc8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bca:	46a1                	li	a3,8
ffffffffc0204bcc:	963e                	add	a2,a2,a5
ffffffffc0204bce:	4505                	li	a0,1
}
ffffffffc0204bd0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bd2:	a31fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204bd6:	86aa                	mv	a3,a0
ffffffffc0204bd8:	00003617          	auipc	a2,0x3
ffffffffc0204bdc:	7d060613          	addi	a2,a2,2000 # ffffffffc02083a8 <default_pmm_manager+0x1060>
ffffffffc0204be0:	45d1                	li	a1,20
ffffffffc0204be2:	00003517          	auipc	a0,0x3
ffffffffc0204be6:	7ae50513          	addi	a0,a0,1966 # ffffffffc0208390 <default_pmm_manager+0x1048>
ffffffffc0204bea:	897fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204bee:	86b2                	mv	a3,a2
ffffffffc0204bf0:	06900593          	li	a1,105
ffffffffc0204bf4:	00002617          	auipc	a2,0x2
ffffffffc0204bf8:	7a460613          	addi	a2,a2,1956 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0204bfc:	00002517          	auipc	a0,0x2
ffffffffc0204c00:	7c450513          	addi	a0,a0,1988 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204c04:	87dfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204c08 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c08:	1141                	addi	sp,sp,-16
ffffffffc0204c0a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c0c:	00855793          	srli	a5,a0,0x8
ffffffffc0204c10:	cfb9                	beqz	a5,ffffffffc0204c6e <swapfs_write+0x66>
ffffffffc0204c12:	000a8717          	auipc	a4,0xa8
ffffffffc0204c16:	d2670713          	addi	a4,a4,-730 # ffffffffc02ac938 <max_swap_offset>
ffffffffc0204c1a:	6318                	ld	a4,0(a4)
ffffffffc0204c1c:	04e7f963          	bgeu	a5,a4,ffffffffc0204c6e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c20:	000a8717          	auipc	a4,0xa8
ffffffffc0204c24:	c8870713          	addi	a4,a4,-888 # ffffffffc02ac8a8 <pages>
ffffffffc0204c28:	6310                	ld	a2,0(a4)
ffffffffc0204c2a:	00004717          	auipc	a4,0x4
ffffffffc0204c2e:	09e70713          	addi	a4,a4,158 # ffffffffc0208cc8 <nbase>
ffffffffc0204c32:	40c58633          	sub	a2,a1,a2
ffffffffc0204c36:	630c                	ld	a1,0(a4)
ffffffffc0204c38:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c3a:	000a8717          	auipc	a4,0xa8
ffffffffc0204c3e:	bfe70713          	addi	a4,a4,-1026 # ffffffffc02ac838 <npage>
    return page - pages + nbase;
ffffffffc0204c42:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c44:	6314                	ld	a3,0(a4)
ffffffffc0204c46:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c4a:	8331                	srli	a4,a4,0xc
ffffffffc0204c4c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c50:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c52:	02d77a63          	bgeu	a4,a3,ffffffffc0204c86 <swapfs_write+0x7e>
ffffffffc0204c56:	000a8797          	auipc	a5,0xa8
ffffffffc0204c5a:	c4278793          	addi	a5,a5,-958 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0204c5e:	639c                	ld	a5,0(a5)
}
ffffffffc0204c60:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c62:	46a1                	li	a3,8
ffffffffc0204c64:	963e                	add	a2,a2,a5
ffffffffc0204c66:	4505                	li	a0,1
}
ffffffffc0204c68:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c6a:	9bdfb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204c6e:	86aa                	mv	a3,a0
ffffffffc0204c70:	00003617          	auipc	a2,0x3
ffffffffc0204c74:	73860613          	addi	a2,a2,1848 # ffffffffc02083a8 <default_pmm_manager+0x1060>
ffffffffc0204c78:	45e5                	li	a1,25
ffffffffc0204c7a:	00003517          	auipc	a0,0x3
ffffffffc0204c7e:	71650513          	addi	a0,a0,1814 # ffffffffc0208390 <default_pmm_manager+0x1048>
ffffffffc0204c82:	ffefb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204c86:	86b2                	mv	a3,a2
ffffffffc0204c88:	06900593          	li	a1,105
ffffffffc0204c8c:	00002617          	auipc	a2,0x2
ffffffffc0204c90:	70c60613          	addi	a2,a2,1804 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0204c94:	00002517          	auipc	a0,0x2
ffffffffc0204c98:	72c50513          	addi	a0,a0,1836 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204c9c:	fe4fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204ca0 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204ca0:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204ca2:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ca4:	718000ef          	jal	ra,ffffffffc02053bc <do_exit>

ffffffffc0204ca8 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ca8:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204caa:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204cae:	e022                	sd	s0,0(sp)
ffffffffc0204cb0:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cb2:	fa7fc0ef          	jal	ra,ffffffffc0201c58 <kmalloc>
ffffffffc0204cb6:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cb8:	c939                	beqz	a0,ffffffffc0204d0e <alloc_proc+0x66>
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */

    proc->state = PROC_UNINIT;
ffffffffc0204cba:	57fd                	li	a5,-1
ffffffffc0204cbc:	1782                	slli	a5,a5,0x20
ffffffffc0204cbe:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cc0:	07000613          	li	a2,112
ffffffffc0204cc4:	4581                	li	a1,0
    proc->cptr = NULL; // 初始化 cptr 为 NULL，表示没有子进程
ffffffffc0204cc6:	0e053823          	sd	zero,240(a0)
    proc->yptr = NULL; // 初始化 yptr 为 NULL，表示没有“年轻”兄弟进程
ffffffffc0204cca:	0e053c23          	sd	zero,248(a0)
    proc->optr = NULL; // 初始化 optr 为 NULL，表示没有“老”兄弟进程
ffffffffc0204cce:	10053023          	sd	zero,256(a0)
    proc->runs = 0;
ffffffffc0204cd2:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204cd6:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204cda:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204cde:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204ce2:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204ce6:	03050513          	addi	a0,a0,48
ffffffffc0204cea:	0e9010ef          	jal	ra,ffffffffc02065d2 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204cee:	000a8797          	auipc	a5,0xa8
ffffffffc0204cf2:	bb278793          	addi	a5,a5,-1102 # ffffffffc02ac8a0 <boot_cr3>
ffffffffc0204cf6:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc0204cf8:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204cfc:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204d00:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204d02:	4641                	li	a2,16
ffffffffc0204d04:	4581                	li	a1,0
ffffffffc0204d06:	0b440513          	addi	a0,s0,180
ffffffffc0204d0a:	0c9010ef          	jal	ra,ffffffffc02065d2 <memset>
    }
    return proc;
}
ffffffffc0204d0e:	8522                	mv	a0,s0
ffffffffc0204d10:	60a2                	ld	ra,8(sp)
ffffffffc0204d12:	6402                	ld	s0,0(sp)
ffffffffc0204d14:	0141                	addi	sp,sp,16
ffffffffc0204d16:	8082                	ret

ffffffffc0204d18 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d18:	000a8797          	auipc	a5,0xa8
ffffffffc0204d1c:	b3878793          	addi	a5,a5,-1224 # ffffffffc02ac850 <current>
ffffffffc0204d20:	639c                	ld	a5,0(a5)
ffffffffc0204d22:	73c8                	ld	a0,160(a5)
ffffffffc0204d24:	89afc06f          	j	ffffffffc0200dbe <forkrets>

ffffffffc0204d28 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d28:	000a8797          	auipc	a5,0xa8
ffffffffc0204d2c:	b2878793          	addi	a5,a5,-1240 # ffffffffc02ac850 <current>
ffffffffc0204d30:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d32:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d34:	00004617          	auipc	a2,0x4
ffffffffc0204d38:	a6460613          	addi	a2,a2,-1436 # ffffffffc0208798 <default_pmm_manager+0x1450>
ffffffffc0204d3c:	43cc                	lw	a1,4(a5)
ffffffffc0204d3e:	00004517          	auipc	a0,0x4
ffffffffc0204d42:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02087a8 <default_pmm_manager+0x1460>
user_main(void *arg) {
ffffffffc0204d46:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d48:	c46fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204d4c:	00004797          	auipc	a5,0x4
ffffffffc0204d50:	a4c78793          	addi	a5,a5,-1460 # ffffffffc0208798 <default_pmm_manager+0x1450>
ffffffffc0204d54:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d58:	11c70713          	addi	a4,a4,284 # 9e70 <_binary_obj___user_badsegment_out_size>
ffffffffc0204d5c:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d5e:	853e                	mv	a0,a5
ffffffffc0204d60:	00011717          	auipc	a4,0x11
ffffffffc0204d64:	6f870713          	addi	a4,a4,1784 # ffffffffc0216458 <_binary_obj___user_badsegment_out_start>
ffffffffc0204d68:	f03a                	sd	a4,32(sp)
ffffffffc0204d6a:	f43e                	sd	a5,40(sp)
ffffffffc0204d6c:	e802                	sd	zero,16(sp)
ffffffffc0204d6e:	7c6010ef          	jal	ra,ffffffffc0206534 <strlen>
ffffffffc0204d72:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d74:	4511                	li	a0,4
ffffffffc0204d76:	55a2                	lw	a1,40(sp)
ffffffffc0204d78:	4662                	lw	a2,24(sp)
ffffffffc0204d7a:	5682                	lw	a3,32(sp)
ffffffffc0204d7c:	4722                	lw	a4,8(sp)
ffffffffc0204d7e:	48a9                	li	a7,10
ffffffffc0204d80:	9002                	ebreak
ffffffffc0204d82:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d84:	65c2                	ld	a1,16(sp)
ffffffffc0204d86:	00004517          	auipc	a0,0x4
ffffffffc0204d8a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02087d0 <default_pmm_manager+0x1488>
ffffffffc0204d8e:	c00fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d92:	00004617          	auipc	a2,0x4
ffffffffc0204d96:	a4e60613          	addi	a2,a2,-1458 # ffffffffc02087e0 <default_pmm_manager+0x1498>
ffffffffc0204d9a:	36800593          	li	a1,872
ffffffffc0204d9e:	00004517          	auipc	a0,0x4
ffffffffc0204da2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0204da6:	edafb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204daa <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204daa:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dac:	1141                	addi	sp,sp,-16
ffffffffc0204dae:	e406                	sd	ra,8(sp)
ffffffffc0204db0:	c02007b7          	lui	a5,0xc0200
ffffffffc0204db4:	04f6e263          	bltu	a3,a5,ffffffffc0204df8 <put_pgdir+0x4e>
ffffffffc0204db8:	000a8797          	auipc	a5,0xa8
ffffffffc0204dbc:	ae078793          	addi	a5,a5,-1312 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0204dc0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dc2:	000a8797          	auipc	a5,0xa8
ffffffffc0204dc6:	a7678793          	addi	a5,a5,-1418 # ffffffffc02ac838 <npage>
ffffffffc0204dca:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204dcc:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dce:	82b1                	srli	a3,a3,0xc
ffffffffc0204dd0:	04f6f063          	bgeu	a3,a5,ffffffffc0204e10 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204dd4:	00004797          	auipc	a5,0x4
ffffffffc0204dd8:	ef478793          	addi	a5,a5,-268 # ffffffffc0208cc8 <nbase>
ffffffffc0204ddc:	639c                	ld	a5,0(a5)
ffffffffc0204dde:	000a8717          	auipc	a4,0xa8
ffffffffc0204de2:	aca70713          	addi	a4,a4,-1334 # ffffffffc02ac8a8 <pages>
ffffffffc0204de6:	6308                	ld	a0,0(a4)
}
ffffffffc0204de8:	60a2                	ld	ra,8(sp)
ffffffffc0204dea:	8e9d                	sub	a3,a3,a5
ffffffffc0204dec:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204dee:	4585                	li	a1,1
ffffffffc0204df0:	9536                	add	a0,a0,a3
}
ffffffffc0204df2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204df4:	8e4fd06f          	j	ffffffffc0201ed8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204df8:	00002617          	auipc	a2,0x2
ffffffffc0204dfc:	5d860613          	addi	a2,a2,1496 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc0204e00:	06e00593          	li	a1,110
ffffffffc0204e04:	00002517          	auipc	a0,0x2
ffffffffc0204e08:	5bc50513          	addi	a0,a0,1468 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204e0c:	e74fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e10:	00002617          	auipc	a2,0x2
ffffffffc0204e14:	5e860613          	addi	a2,a2,1512 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc0204e18:	06200593          	li	a1,98
ffffffffc0204e1c:	00002517          	auipc	a0,0x2
ffffffffc0204e20:	5a450513          	addi	a0,a0,1444 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204e24:	e5cfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204e28 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e28:	1101                	addi	sp,sp,-32
ffffffffc0204e2a:	e426                	sd	s1,8(sp)
ffffffffc0204e2c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e2e:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e30:	ec06                	sd	ra,24(sp)
ffffffffc0204e32:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e34:	81cfd0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
ffffffffc0204e38:	c125                	beqz	a0,ffffffffc0204e98 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e3a:	000a8797          	auipc	a5,0xa8
ffffffffc0204e3e:	a6e78793          	addi	a5,a5,-1426 # ffffffffc02ac8a8 <pages>
ffffffffc0204e42:	6394                	ld	a3,0(a5)
ffffffffc0204e44:	00004797          	auipc	a5,0x4
ffffffffc0204e48:	e8478793          	addi	a5,a5,-380 # ffffffffc0208cc8 <nbase>
ffffffffc0204e4c:	6380                	ld	s0,0(a5)
ffffffffc0204e4e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e52:	000a8797          	auipc	a5,0xa8
ffffffffc0204e56:	9e678793          	addi	a5,a5,-1562 # ffffffffc02ac838 <npage>
    return page - pages + nbase;
ffffffffc0204e5a:	8699                	srai	a3,a3,0x6
ffffffffc0204e5c:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e5e:	6398                	ld	a4,0(a5)
ffffffffc0204e60:	00c69793          	slli	a5,a3,0xc
ffffffffc0204e64:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e66:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e68:	02e7fa63          	bgeu	a5,a4,ffffffffc0204e9c <setup_pgdir+0x74>
ffffffffc0204e6c:	000a8797          	auipc	a5,0xa8
ffffffffc0204e70:	a2c78793          	addi	a5,a5,-1492 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0204e74:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e76:	000a8797          	auipc	a5,0xa8
ffffffffc0204e7a:	9ba78793          	addi	a5,a5,-1606 # ffffffffc02ac830 <boot_pgdir>
ffffffffc0204e7e:	638c                	ld	a1,0(a5)
ffffffffc0204e80:	9436                	add	s0,s0,a3
ffffffffc0204e82:	6605                	lui	a2,0x1
ffffffffc0204e84:	8522                	mv	a0,s0
ffffffffc0204e86:	75e010ef          	jal	ra,ffffffffc02065e4 <memcpy>
    return 0;
ffffffffc0204e8a:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204e8c:	ec80                	sd	s0,24(s1)
}
ffffffffc0204e8e:	60e2                	ld	ra,24(sp)
ffffffffc0204e90:	6442                	ld	s0,16(sp)
ffffffffc0204e92:	64a2                	ld	s1,8(sp)
ffffffffc0204e94:	6105                	addi	sp,sp,32
ffffffffc0204e96:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204e98:	5571                	li	a0,-4
ffffffffc0204e9a:	bfd5                	j	ffffffffc0204e8e <setup_pgdir+0x66>
ffffffffc0204e9c:	00002617          	auipc	a2,0x2
ffffffffc0204ea0:	4fc60613          	addi	a2,a2,1276 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0204ea4:	06900593          	li	a1,105
ffffffffc0204ea8:	00002517          	auipc	a0,0x2
ffffffffc0204eac:	51850513          	addi	a0,a0,1304 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0204eb0:	dd0fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204eb4 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204eb4:	1101                	addi	sp,sp,-32
ffffffffc0204eb6:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eb8:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ebc:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ebe:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ec0:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ec2:	8522                	mv	a0,s0
ffffffffc0204ec4:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ec6:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ec8:	70a010ef          	jal	ra,ffffffffc02065d2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ecc:	8522                	mv	a0,s0
}
ffffffffc0204ece:	6442                	ld	s0,16(sp)
ffffffffc0204ed0:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ed2:	85a6                	mv	a1,s1
}
ffffffffc0204ed4:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ed6:	463d                	li	a2,15
}
ffffffffc0204ed8:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204eda:	70a0106f          	j	ffffffffc02065e4 <memcpy>

ffffffffc0204ede <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204ede:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204ee0:	000a8797          	auipc	a5,0xa8
ffffffffc0204ee4:	97078793          	addi	a5,a5,-1680 # ffffffffc02ac850 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204ee8:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204eea:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204eec:	ec06                	sd	ra,24(sp)
ffffffffc0204eee:	e822                	sd	s0,16(sp)
ffffffffc0204ef0:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204ef2:	02a48b63          	beq	s1,a0,ffffffffc0204f28 <proc_run+0x4a>
ffffffffc0204ef6:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ef8:	100027f3          	csrr	a5,sstatus
ffffffffc0204efc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204efe:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f00:	e3a9                	bnez	a5,ffffffffc0204f42 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f02:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc0204f04:	000a8717          	auipc	a4,0xa8
ffffffffc0204f08:	94873623          	sd	s0,-1716(a4) # ffffffffc02ac850 <current>
ffffffffc0204f0c:	577d                	li	a4,-1
ffffffffc0204f0e:	177e                	slli	a4,a4,0x3f
ffffffffc0204f10:	83b1                	srli	a5,a5,0xc
ffffffffc0204f12:	8fd9                	or	a5,a5,a4
ffffffffc0204f14:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0204f18:	03040593          	addi	a1,s0,48
ffffffffc0204f1c:	03048513          	addi	a0,s1,48
ffffffffc0204f20:	7b5000ef          	jal	ra,ffffffffc0205ed4 <switch_to>
    if (flag) {
ffffffffc0204f24:	00091863          	bnez	s2,ffffffffc0204f34 <proc_run+0x56>
}
ffffffffc0204f28:	60e2                	ld	ra,24(sp)
ffffffffc0204f2a:	6442                	ld	s0,16(sp)
ffffffffc0204f2c:	64a2                	ld	s1,8(sp)
ffffffffc0204f2e:	6902                	ld	s2,0(sp)
ffffffffc0204f30:	6105                	addi	sp,sp,32
ffffffffc0204f32:	8082                	ret
ffffffffc0204f34:	6442                	ld	s0,16(sp)
ffffffffc0204f36:	60e2                	ld	ra,24(sp)
ffffffffc0204f38:	64a2                	ld	s1,8(sp)
ffffffffc0204f3a:	6902                	ld	s2,0(sp)
ffffffffc0204f3c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f3e:	f0efb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0204f42:	f10fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0204f46:	4905                	li	s2,1
ffffffffc0204f48:	bf6d                	j	ffffffffc0204f02 <proc_run+0x24>

ffffffffc0204f4a <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f4a:	0005071b          	sext.w	a4,a0
ffffffffc0204f4e:	6789                	lui	a5,0x2
ffffffffc0204f50:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f54:	17f9                	addi	a5,a5,-2
ffffffffc0204f56:	04d7e063          	bltu	a5,a3,ffffffffc0204f96 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f5a:	1141                	addi	sp,sp,-16
ffffffffc0204f5c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f5e:	45a9                	li	a1,10
ffffffffc0204f60:	842a                	mv	s0,a0
ffffffffc0204f62:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f64:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f66:	1ca010ef          	jal	ra,ffffffffc0206130 <hash32>
ffffffffc0204f6a:	02051693          	slli	a3,a0,0x20
ffffffffc0204f6e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f70:	000a4517          	auipc	a0,0xa4
ffffffffc0204f74:	89850513          	addi	a0,a0,-1896 # ffffffffc02a8808 <hash_list>
ffffffffc0204f78:	96aa                	add	a3,a3,a0
ffffffffc0204f7a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204f7c:	a029                	j	ffffffffc0204f86 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204f7e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc0204f82:	00870c63          	beq	a4,s0,ffffffffc0204f9a <find_proc+0x50>
ffffffffc0204f86:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204f88:	fef69be3          	bne	a3,a5,ffffffffc0204f7e <find_proc+0x34>
}
ffffffffc0204f8c:	60a2                	ld	ra,8(sp)
ffffffffc0204f8e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204f90:	4501                	li	a0,0
}
ffffffffc0204f92:	0141                	addi	sp,sp,16
ffffffffc0204f94:	8082                	ret
    return NULL;
ffffffffc0204f96:	4501                	li	a0,0
}
ffffffffc0204f98:	8082                	ret
ffffffffc0204f9a:	60a2                	ld	ra,8(sp)
ffffffffc0204f9c:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204f9e:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fa2:	0141                	addi	sp,sp,16
ffffffffc0204fa4:	8082                	ret

ffffffffc0204fa6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fa6:	715d                	addi	sp,sp,-80
ffffffffc0204fa8:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204faa:	000a8917          	auipc	s2,0xa8
ffffffffc0204fae:	8be90913          	addi	s2,s2,-1858 # ffffffffc02ac868 <nr_process>
ffffffffc0204fb2:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fb6:	e486                	sd	ra,72(sp)
ffffffffc0204fb8:	e0a2                	sd	s0,64(sp)
ffffffffc0204fba:	fc26                	sd	s1,56(sp)
ffffffffc0204fbc:	f44e                	sd	s3,40(sp)
ffffffffc0204fbe:	f052                	sd	s4,32(sp)
ffffffffc0204fc0:	ec56                	sd	s5,24(sp)
ffffffffc0204fc2:	e85a                	sd	s6,16(sp)
ffffffffc0204fc4:	e45e                	sd	s7,8(sp)
ffffffffc0204fc6:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fc8:	6785                	lui	a5,0x1
ffffffffc0204fca:	32f75263          	bge	a4,a5,ffffffffc02052ee <do_fork+0x348>
ffffffffc0204fce:	8aaa                	mv	s5,a0
ffffffffc0204fd0:	89ae                	mv	s3,a1
ffffffffc0204fd2:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204fd4:	cd5ff0ef          	jal	ra,ffffffffc0204ca8 <alloc_proc>
ffffffffc0204fd8:	842a                	mv	s0,a0
ffffffffc0204fda:	2a050763          	beqz	a0,ffffffffc0205288 <do_fork+0x2e2>
    current->wait_state = 0;
ffffffffc0204fde:	000a8a17          	auipc	s4,0xa8
ffffffffc0204fe2:	872a0a13          	addi	s4,s4,-1934 # ffffffffc02ac850 <current>
ffffffffc0204fe6:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204fea:	4509                	li	a0,2
    current->wait_state = 0;
ffffffffc0204fec:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;
ffffffffc0204ff0:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204ff2:	e5ffc0ef          	jal	ra,ffffffffc0201e50 <alloc_pages>
    if (page != NULL) {
ffffffffc0204ff6:	2a050763          	beqz	a0,ffffffffc02052a4 <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc0204ffa:	000a8797          	auipc	a5,0xa8
ffffffffc0204ffe:	8ae78793          	addi	a5,a5,-1874 # ffffffffc02ac8a8 <pages>
ffffffffc0205002:	6394                	ld	a3,0(a5)
ffffffffc0205004:	00004797          	auipc	a5,0x4
ffffffffc0205008:	cc478793          	addi	a5,a5,-828 # ffffffffc0208cc8 <nbase>
ffffffffc020500c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205010:	6388                	ld	a0,0(a5)
ffffffffc0205012:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205014:	000a8797          	auipc	a5,0xa8
ffffffffc0205018:	82478793          	addi	a5,a5,-2012 # ffffffffc02ac838 <npage>
    return page - pages + nbase;
ffffffffc020501c:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020501e:	6398                	ld	a4,0(a5)
ffffffffc0205020:	00c69793          	slli	a5,a3,0xc
ffffffffc0205024:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205026:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205028:	2ce7f563          	bgeu	a5,a4,ffffffffc02052f2 <do_fork+0x34c>
ffffffffc020502c:	000a8b17          	auipc	s6,0xa8
ffffffffc0205030:	86cb0b13          	addi	s6,s6,-1940 # ffffffffc02ac898 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205034:	000a3703          	ld	a4,0(s4)
ffffffffc0205038:	000b3783          	ld	a5,0(s6)
ffffffffc020503c:	02873a03          	ld	s4,40(a4)
ffffffffc0205040:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205042:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205044:	020a0863          	beqz	s4,ffffffffc0205074 <do_fork+0xce>
    if (clone_flags & CLONE_VM) {
ffffffffc0205048:	100afa93          	andi	s5,s5,256
ffffffffc020504c:	1e0a8163          	beqz	s5,ffffffffc020522e <do_fork+0x288>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205050:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205054:	018a3783          	ld	a5,24(s4)
ffffffffc0205058:	c02006b7          	lui	a3,0xc0200
ffffffffc020505c:	2705                	addiw	a4,a4,1
ffffffffc020505e:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc0205062:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205066:	2ad7e263          	bltu	a5,a3,ffffffffc020530a <do_fork+0x364>
ffffffffc020506a:	000b3703          	ld	a4,0(s6)
ffffffffc020506e:	6814                	ld	a3,16(s0)
ffffffffc0205070:	8f99                	sub	a5,a5,a4
ffffffffc0205072:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205074:	6789                	lui	a5,0x2
ffffffffc0205076:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc020507a:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020507c:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020507e:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205080:	87b6                	mv	a5,a3
ffffffffc0205082:	12048893          	addi	a7,s1,288
ffffffffc0205086:	00063803          	ld	a6,0(a2)
ffffffffc020508a:	6608                	ld	a0,8(a2)
ffffffffc020508c:	6a0c                	ld	a1,16(a2)
ffffffffc020508e:	6e18                	ld	a4,24(a2)
ffffffffc0205090:	0107b023          	sd	a6,0(a5)
ffffffffc0205094:	e788                	sd	a0,8(a5)
ffffffffc0205096:	eb8c                	sd	a1,16(a5)
ffffffffc0205098:	ef98                	sd	a4,24(a5)
ffffffffc020509a:	02060613          	addi	a2,a2,32
ffffffffc020509e:	02078793          	addi	a5,a5,32
ffffffffc02050a2:	ff1612e3          	bne	a2,a7,ffffffffc0205086 <do_fork+0xe0>
    proc->tf->gpr.a0 = 0;
ffffffffc02050a6:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050aa:	12098b63          	beqz	s3,ffffffffc02051e0 <do_fork+0x23a>
ffffffffc02050ae:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050b2:	00000797          	auipc	a5,0x0
ffffffffc02050b6:	c6678793          	addi	a5,a5,-922 # ffffffffc0204d18 <forkret>
ffffffffc02050ba:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050bc:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050be:	100027f3          	csrr	a5,sstatus
ffffffffc02050c2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050c4:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050c6:	12079c63          	bnez	a5,ffffffffc02051fe <do_fork+0x258>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050ca:	0009c797          	auipc	a5,0x9c
ffffffffc02050ce:	33678793          	addi	a5,a5,822 # ffffffffc02a1400 <last_pid.1691>
ffffffffc02050d2:	439c                	lw	a5,0(a5)
ffffffffc02050d4:	6709                	lui	a4,0x2
ffffffffc02050d6:	0017851b          	addiw	a0,a5,1
ffffffffc02050da:	0009c697          	auipc	a3,0x9c
ffffffffc02050de:	32a6a323          	sw	a0,806(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc02050e2:	12e55f63          	bge	a0,a4,ffffffffc0205220 <do_fork+0x27a>
    if (last_pid >= next_safe) {
ffffffffc02050e6:	0009c797          	auipc	a5,0x9c
ffffffffc02050ea:	31e78793          	addi	a5,a5,798 # ffffffffc02a1404 <next_safe.1690>
ffffffffc02050ee:	439c                	lw	a5,0(a5)
ffffffffc02050f0:	000a8497          	auipc	s1,0xa8
ffffffffc02050f4:	8a048493          	addi	s1,s1,-1888 # ffffffffc02ac990 <proc_list>
ffffffffc02050f8:	06f54063          	blt	a0,a5,ffffffffc0205158 <do_fork+0x1b2>
        next_safe = MAX_PID;
ffffffffc02050fc:	6789                	lui	a5,0x2
ffffffffc02050fe:	0009c717          	auipc	a4,0x9c
ffffffffc0205102:	30f72323          	sw	a5,774(a4) # ffffffffc02a1404 <next_safe.1690>
ffffffffc0205106:	4581                	li	a1,0
ffffffffc0205108:	87aa                	mv	a5,a0
ffffffffc020510a:	000a8497          	auipc	s1,0xa8
ffffffffc020510e:	88648493          	addi	s1,s1,-1914 # ffffffffc02ac990 <proc_list>
    repeat:
ffffffffc0205112:	6889                	lui	a7,0x2
ffffffffc0205114:	882e                	mv	a6,a1
ffffffffc0205116:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205118:	000a8697          	auipc	a3,0xa8
ffffffffc020511c:	87868693          	addi	a3,a3,-1928 # ffffffffc02ac990 <proc_list>
ffffffffc0205120:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205122:	00968f63          	beq	a3,s1,ffffffffc0205140 <do_fork+0x19a>
            if (proc->pid == last_pid) {
ffffffffc0205126:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020512a:	0ae78663          	beq	a5,a4,ffffffffc02051d6 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020512e:	fee7d9e3          	bge	a5,a4,ffffffffc0205120 <do_fork+0x17a>
ffffffffc0205132:	fec757e3          	bge	a4,a2,ffffffffc0205120 <do_fork+0x17a>
ffffffffc0205136:	6694                	ld	a3,8(a3)
ffffffffc0205138:	863a                	mv	a2,a4
ffffffffc020513a:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020513c:	fe9695e3          	bne	a3,s1,ffffffffc0205126 <do_fork+0x180>
ffffffffc0205140:	c591                	beqz	a1,ffffffffc020514c <do_fork+0x1a6>
ffffffffc0205142:	0009c717          	auipc	a4,0x9c
ffffffffc0205146:	2af72f23          	sw	a5,702(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020514a:	853e                	mv	a0,a5
ffffffffc020514c:	00080663          	beqz	a6,ffffffffc0205158 <do_fork+0x1b2>
ffffffffc0205150:	0009c797          	auipc	a5,0x9c
ffffffffc0205154:	2ac7aa23          	sw	a2,692(a5) # ffffffffc02a1404 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0205158:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020515a:	45a9                	li	a1,10
ffffffffc020515c:	2501                	sext.w	a0,a0
ffffffffc020515e:	7d3000ef          	jal	ra,ffffffffc0206130 <hash32>
ffffffffc0205162:	1502                	slli	a0,a0,0x20
ffffffffc0205164:	000a3797          	auipc	a5,0xa3
ffffffffc0205168:	6a478793          	addi	a5,a5,1700 # ffffffffc02a8808 <hash_list>
ffffffffc020516c:	8171                	srli	a0,a0,0x1c
ffffffffc020516e:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205170:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205172:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205174:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205178:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020517a:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020517c:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020517e:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205180:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205184:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205186:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205188:	e21c                	sd	a5,0(a2)
ffffffffc020518a:	000a8597          	auipc	a1,0xa8
ffffffffc020518e:	80f5b723          	sd	a5,-2034(a1) # ffffffffc02ac998 <proc_list+0x8>
    elm->next = next;
ffffffffc0205192:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205194:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205196:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020519a:	10e43023          	sd	a4,256(s0)
ffffffffc020519e:	c311                	beqz	a4,ffffffffc02051a2 <do_fork+0x1fc>
        proc->optr->yptr = proc;
ffffffffc02051a0:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051a2:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02051a6:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051a8:	2785                	addiw	a5,a5,1
ffffffffc02051aa:	000a7717          	auipc	a4,0xa7
ffffffffc02051ae:	6af72f23          	sw	a5,1726(a4) # ffffffffc02ac868 <nr_process>
    if (flag) {
ffffffffc02051b2:	0c099d63          	bnez	s3,ffffffffc020528c <do_fork+0x2e6>
    wakeup_proc(proc);
ffffffffc02051b6:	8522                	mv	a0,s0
ffffffffc02051b8:	587000ef          	jal	ra,ffffffffc0205f3e <wakeup_proc>
    ret = proc->pid;
ffffffffc02051bc:	4048                	lw	a0,4(s0)
}
ffffffffc02051be:	60a6                	ld	ra,72(sp)
ffffffffc02051c0:	6406                	ld	s0,64(sp)
ffffffffc02051c2:	74e2                	ld	s1,56(sp)
ffffffffc02051c4:	7942                	ld	s2,48(sp)
ffffffffc02051c6:	79a2                	ld	s3,40(sp)
ffffffffc02051c8:	7a02                	ld	s4,32(sp)
ffffffffc02051ca:	6ae2                	ld	s5,24(sp)
ffffffffc02051cc:	6b42                	ld	s6,16(sp)
ffffffffc02051ce:	6ba2                	ld	s7,8(sp)
ffffffffc02051d0:	6c02                	ld	s8,0(sp)
ffffffffc02051d2:	6161                	addi	sp,sp,80
ffffffffc02051d4:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02051d6:	2785                	addiw	a5,a5,1
ffffffffc02051d8:	0ac7dd63          	bge	a5,a2,ffffffffc0205292 <do_fork+0x2ec>
ffffffffc02051dc:	4585                	li	a1,1
ffffffffc02051de:	b789                	j	ffffffffc0205120 <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051e0:	89b6                	mv	s3,a3
ffffffffc02051e2:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051e6:	00000797          	auipc	a5,0x0
ffffffffc02051ea:	b3278793          	addi	a5,a5,-1230 # ffffffffc0204d18 <forkret>
ffffffffc02051ee:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051f0:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051f2:	100027f3          	csrr	a5,sstatus
ffffffffc02051f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051f8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051fa:	ec0788e3          	beqz	a5,ffffffffc02050ca <do_fork+0x124>
        intr_disable();
ffffffffc02051fe:	c54fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205202:	0009c797          	auipc	a5,0x9c
ffffffffc0205206:	1fe78793          	addi	a5,a5,510 # ffffffffc02a1400 <last_pid.1691>
ffffffffc020520a:	439c                	lw	a5,0(a5)
ffffffffc020520c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020520e:	4985                	li	s3,1
ffffffffc0205210:	0017851b          	addiw	a0,a5,1
ffffffffc0205214:	0009c697          	auipc	a3,0x9c
ffffffffc0205218:	1ea6a623          	sw	a0,492(a3) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020521c:	ece545e3          	blt	a0,a4,ffffffffc02050e6 <do_fork+0x140>
        last_pid = 1;
ffffffffc0205220:	4785                	li	a5,1
ffffffffc0205222:	0009c717          	auipc	a4,0x9c
ffffffffc0205226:	1cf72f23          	sw	a5,478(a4) # ffffffffc02a1400 <last_pid.1691>
ffffffffc020522a:	4505                	li	a0,1
ffffffffc020522c:	bdc1                	j	ffffffffc02050fc <do_fork+0x156>
    if ((mm = mm_create()) == NULL) {
ffffffffc020522e:	e99fe0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0205232:	8c2a                	mv	s8,a0
ffffffffc0205234:	c539                	beqz	a0,ffffffffc0205282 <do_fork+0x2dc>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205236:	bf3ff0ef          	jal	ra,ffffffffc0204e28 <setup_pgdir>
ffffffffc020523a:	e12d                	bnez	a0,ffffffffc020529c <do_fork+0x2f6>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020523c:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205240:	4785                	li	a5,1
ffffffffc0205242:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc0205246:	8b85                	andi	a5,a5,1
ffffffffc0205248:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020524a:	c799                	beqz	a5,ffffffffc0205258 <do_fork+0x2b2>
        schedule();
ffffffffc020524c:	56f000ef          	jal	ra,ffffffffc0205fba <schedule>
ffffffffc0205250:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc0205254:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205256:	fbfd                	bnez	a5,ffffffffc020524c <do_fork+0x2a6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205258:	85d2                	mv	a1,s4
ffffffffc020525a:	8562                	mv	a0,s8
ffffffffc020525c:	8f4ff0ef          	jal	ra,ffffffffc0204350 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205260:	57f9                	li	a5,-2
ffffffffc0205262:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc0205266:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205268:	cfd5                	beqz	a5,ffffffffc0205324 <do_fork+0x37e>
    if (ret != 0) {
ffffffffc020526a:	8a62                	mv	s4,s8
ffffffffc020526c:	de0502e3          	beqz	a0,ffffffffc0205050 <do_fork+0xaa>
    exit_mmap(mm);
ffffffffc0205270:	8562                	mv	a0,s8
ffffffffc0205272:	97aff0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
    put_pgdir(mm);
ffffffffc0205276:	8562                	mv	a0,s8
ffffffffc0205278:	b33ff0ef          	jal	ra,ffffffffc0204daa <put_pgdir>
    mm_destroy(mm);
ffffffffc020527c:	8562                	mv	a0,s8
ffffffffc020527e:	fcffe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    kfree(proc);
ffffffffc0205282:	8522                	mv	a0,s0
ffffffffc0205284:	a91fc0ef          	jal	ra,ffffffffc0201d14 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205288:	5571                	li	a0,-4
    return ret;
ffffffffc020528a:	bf15                	j	ffffffffc02051be <do_fork+0x218>
        intr_enable();
ffffffffc020528c:	bc0fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205290:	b71d                	j	ffffffffc02051b6 <do_fork+0x210>
                    if (last_pid >= MAX_PID) {
ffffffffc0205292:	0117c363          	blt	a5,a7,ffffffffc0205298 <do_fork+0x2f2>
                        last_pid = 1;
ffffffffc0205296:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205298:	4585                	li	a1,1
ffffffffc020529a:	bdad                	j	ffffffffc0205114 <do_fork+0x16e>
    mm_destroy(mm);
ffffffffc020529c:	8562                	mv	a0,s8
ffffffffc020529e:	faffe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
ffffffffc02052a2:	b7c5                	j	ffffffffc0205282 <do_fork+0x2dc>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052a4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052a6:	c02007b7          	lui	a5,0xc0200
ffffffffc02052aa:	0af6e563          	bltu	a3,a5,ffffffffc0205354 <do_fork+0x3ae>
ffffffffc02052ae:	000a7797          	auipc	a5,0xa7
ffffffffc02052b2:	5ea78793          	addi	a5,a5,1514 # ffffffffc02ac898 <va_pa_offset>
ffffffffc02052b6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02052b8:	000a7717          	auipc	a4,0xa7
ffffffffc02052bc:	58070713          	addi	a4,a4,1408 # ffffffffc02ac838 <npage>
ffffffffc02052c0:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc02052c2:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052c6:	83b1                	srli	a5,a5,0xc
ffffffffc02052c8:	06e7fa63          	bgeu	a5,a4,ffffffffc020533c <do_fork+0x396>
    return &pages[PPN(pa) - nbase];
ffffffffc02052cc:	00004717          	auipc	a4,0x4
ffffffffc02052d0:	9fc70713          	addi	a4,a4,-1540 # ffffffffc0208cc8 <nbase>
ffffffffc02052d4:	6318                	ld	a4,0(a4)
ffffffffc02052d6:	000a7697          	auipc	a3,0xa7
ffffffffc02052da:	5d268693          	addi	a3,a3,1490 # ffffffffc02ac8a8 <pages>
ffffffffc02052de:	6288                	ld	a0,0(a3)
ffffffffc02052e0:	8f99                	sub	a5,a5,a4
ffffffffc02052e2:	079a                	slli	a5,a5,0x6
ffffffffc02052e4:	4589                	li	a1,2
ffffffffc02052e6:	953e                	add	a0,a0,a5
ffffffffc02052e8:	bf1fc0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
ffffffffc02052ec:	bf59                	j	ffffffffc0205282 <do_fork+0x2dc>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052ee:	556d                	li	a0,-5
ffffffffc02052f0:	b5f9                	j	ffffffffc02051be <do_fork+0x218>
    return KADDR(page2pa(page));
ffffffffc02052f2:	00002617          	auipc	a2,0x2
ffffffffc02052f6:	0a660613          	addi	a2,a2,166 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc02052fa:	06900593          	li	a1,105
ffffffffc02052fe:	00002517          	auipc	a0,0x2
ffffffffc0205302:	0c250513          	addi	a0,a0,194 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0205306:	97afb0ef          	jal	ra,ffffffffc0200480 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020530a:	86be                	mv	a3,a5
ffffffffc020530c:	00002617          	auipc	a2,0x2
ffffffffc0205310:	0c460613          	addi	a2,a2,196 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc0205314:	16900593          	li	a1,361
ffffffffc0205318:	00003517          	auipc	a0,0x3
ffffffffc020531c:	4e850513          	addi	a0,a0,1256 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205320:	960fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205324:	00003617          	auipc	a2,0x3
ffffffffc0205328:	26c60613          	addi	a2,a2,620 # ffffffffc0208590 <default_pmm_manager+0x1248>
ffffffffc020532c:	03100593          	li	a1,49
ffffffffc0205330:	00003517          	auipc	a0,0x3
ffffffffc0205334:	27050513          	addi	a0,a0,624 # ffffffffc02085a0 <default_pmm_manager+0x1258>
ffffffffc0205338:	948fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020533c:	00002617          	auipc	a2,0x2
ffffffffc0205340:	0bc60613          	addi	a2,a2,188 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc0205344:	06200593          	li	a1,98
ffffffffc0205348:	00002517          	auipc	a0,0x2
ffffffffc020534c:	07850513          	addi	a0,a0,120 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0205350:	930fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205354:	00002617          	auipc	a2,0x2
ffffffffc0205358:	07c60613          	addi	a2,a2,124 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc020535c:	06e00593          	li	a1,110
ffffffffc0205360:	00002517          	auipc	a0,0x2
ffffffffc0205364:	06050513          	addi	a0,a0,96 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0205368:	918fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020536c <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020536c:	7129                	addi	sp,sp,-320
ffffffffc020536e:	fa22                	sd	s0,304(sp)
ffffffffc0205370:	f626                	sd	s1,296(sp)
ffffffffc0205372:	f24a                	sd	s2,288(sp)
ffffffffc0205374:	84ae                	mv	s1,a1
ffffffffc0205376:	892a                	mv	s2,a0
ffffffffc0205378:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020537a:	4581                	li	a1,0
ffffffffc020537c:	12000613          	li	a2,288
ffffffffc0205380:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205382:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205384:	24e010ef          	jal	ra,ffffffffc02065d2 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205388:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020538a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020538c:	100027f3          	csrr	a5,sstatus
ffffffffc0205390:	edd7f793          	andi	a5,a5,-291
ffffffffc0205394:	1207e793          	ori	a5,a5,288
ffffffffc0205398:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020539a:	860a                	mv	a2,sp
ffffffffc020539c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053a0:	00000797          	auipc	a5,0x0
ffffffffc02053a4:	90078793          	addi	a5,a5,-1792 # ffffffffc0204ca0 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053a8:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053aa:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053ac:	bfbff0ef          	jal	ra,ffffffffc0204fa6 <do_fork>
}
ffffffffc02053b0:	70f2                	ld	ra,312(sp)
ffffffffc02053b2:	7452                	ld	s0,304(sp)
ffffffffc02053b4:	74b2                	ld	s1,296(sp)
ffffffffc02053b6:	7912                	ld	s2,288(sp)
ffffffffc02053b8:	6131                	addi	sp,sp,320
ffffffffc02053ba:	8082                	ret

ffffffffc02053bc <do_exit>:
do_exit(int error_code) {
ffffffffc02053bc:	7179                	addi	sp,sp,-48
ffffffffc02053be:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053c0:	000a7717          	auipc	a4,0xa7
ffffffffc02053c4:	49870713          	addi	a4,a4,1176 # ffffffffc02ac858 <idleproc>
ffffffffc02053c8:	000a7917          	auipc	s2,0xa7
ffffffffc02053cc:	48890913          	addi	s2,s2,1160 # ffffffffc02ac850 <current>
ffffffffc02053d0:	00093783          	ld	a5,0(s2)
ffffffffc02053d4:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02053d6:	f406                	sd	ra,40(sp)
ffffffffc02053d8:	f022                	sd	s0,32(sp)
ffffffffc02053da:	ec26                	sd	s1,24(sp)
ffffffffc02053dc:	e44e                	sd	s3,8(sp)
ffffffffc02053de:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02053e0:	0ce78c63          	beq	a5,a4,ffffffffc02054b8 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc02053e4:	000a7417          	auipc	s0,0xa7
ffffffffc02053e8:	47c40413          	addi	s0,s0,1148 # ffffffffc02ac860 <initproc>
ffffffffc02053ec:	6018                	ld	a4,0(s0)
ffffffffc02053ee:	0ee78b63          	beq	a5,a4,ffffffffc02054e4 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02053f2:	7784                	ld	s1,40(a5)
ffffffffc02053f4:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02053f6:	c48d                	beqz	s1,ffffffffc0205420 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02053f8:	000a7797          	auipc	a5,0xa7
ffffffffc02053fc:	4a878793          	addi	a5,a5,1192 # ffffffffc02ac8a0 <boot_cr3>
ffffffffc0205400:	639c                	ld	a5,0(a5)
ffffffffc0205402:	577d                	li	a4,-1
ffffffffc0205404:	177e                	slli	a4,a4,0x3f
ffffffffc0205406:	83b1                	srli	a5,a5,0xc
ffffffffc0205408:	8fd9                	or	a5,a5,a4
ffffffffc020540a:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020540e:	589c                	lw	a5,48(s1)
ffffffffc0205410:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205414:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205416:	cf4d                	beqz	a4,ffffffffc02054d0 <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205418:	00093783          	ld	a5,0(s2)
ffffffffc020541c:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205420:	00093783          	ld	a5,0(s2)
ffffffffc0205424:	470d                	li	a4,3
ffffffffc0205426:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205428:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020542c:	100027f3          	csrr	a5,sstatus
ffffffffc0205430:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205432:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205434:	e7e1                	bnez	a5,ffffffffc02054fc <do_exit+0x140>
        proc = current->parent;
ffffffffc0205436:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020543a:	800007b7          	lui	a5,0x80000
ffffffffc020543e:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205440:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205442:	0ec52703          	lw	a4,236(a0)
ffffffffc0205446:	0af70f63          	beq	a4,a5,ffffffffc0205504 <do_exit+0x148>
ffffffffc020544a:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020544e:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205452:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205454:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205456:	7afc                	ld	a5,240(a3)
ffffffffc0205458:	cb95                	beqz	a5,ffffffffc020548c <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc020545a:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020545e:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205460:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205462:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205464:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205468:	10e7b023          	sd	a4,256(a5)
ffffffffc020546c:	c311                	beqz	a4,ffffffffc0205470 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc020546e:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205470:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205472:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205474:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205476:	fe9710e3          	bne	a4,s1,ffffffffc0205456 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020547a:	0ec52783          	lw	a5,236(a0)
ffffffffc020547e:	fd379ce3          	bne	a5,s3,ffffffffc0205456 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205482:	2bd000ef          	jal	ra,ffffffffc0205f3e <wakeup_proc>
ffffffffc0205486:	00093683          	ld	a3,0(s2)
ffffffffc020548a:	b7f1                	j	ffffffffc0205456 <do_exit+0x9a>
    if (flag) {
ffffffffc020548c:	020a1363          	bnez	s4,ffffffffc02054b2 <do_exit+0xf6>
    schedule();
ffffffffc0205490:	32b000ef          	jal	ra,ffffffffc0205fba <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205494:	00093783          	ld	a5,0(s2)
ffffffffc0205498:	00003617          	auipc	a2,0x3
ffffffffc020549c:	0d860613          	addi	a2,a2,216 # ffffffffc0208570 <default_pmm_manager+0x1228>
ffffffffc02054a0:	21f00593          	li	a1,543
ffffffffc02054a4:	43d4                	lw	a3,4(a5)
ffffffffc02054a6:	00003517          	auipc	a0,0x3
ffffffffc02054aa:	35a50513          	addi	a0,a0,858 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02054ae:	fd3fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_enable();
ffffffffc02054b2:	99afb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02054b6:	bfe9                	j	ffffffffc0205490 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054b8:	00003617          	auipc	a2,0x3
ffffffffc02054bc:	09860613          	addi	a2,a2,152 # ffffffffc0208550 <default_pmm_manager+0x1208>
ffffffffc02054c0:	1f300593          	li	a1,499
ffffffffc02054c4:	00003517          	auipc	a0,0x3
ffffffffc02054c8:	33c50513          	addi	a0,a0,828 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02054cc:	fb5fa0ef          	jal	ra,ffffffffc0200480 <__panic>
            exit_mmap(mm);
ffffffffc02054d0:	8526                	mv	a0,s1
ffffffffc02054d2:	f1bfe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
            put_pgdir(mm);
ffffffffc02054d6:	8526                	mv	a0,s1
ffffffffc02054d8:	8d3ff0ef          	jal	ra,ffffffffc0204daa <put_pgdir>
            mm_destroy(mm);
ffffffffc02054dc:	8526                	mv	a0,s1
ffffffffc02054de:	d6ffe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
ffffffffc02054e2:	bf1d                	j	ffffffffc0205418 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02054e4:	00003617          	auipc	a2,0x3
ffffffffc02054e8:	07c60613          	addi	a2,a2,124 # ffffffffc0208560 <default_pmm_manager+0x1218>
ffffffffc02054ec:	1f600593          	li	a1,502
ffffffffc02054f0:	00003517          	auipc	a0,0x3
ffffffffc02054f4:	31050513          	addi	a0,a0,784 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02054f8:	f89fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_disable();
ffffffffc02054fc:	956fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205500:	4a05                	li	s4,1
ffffffffc0205502:	bf15                	j	ffffffffc0205436 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205504:	23b000ef          	jal	ra,ffffffffc0205f3e <wakeup_proc>
ffffffffc0205508:	b789                	j	ffffffffc020544a <do_exit+0x8e>

ffffffffc020550a <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020550a:	7139                	addi	sp,sp,-64
ffffffffc020550c:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020550e:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205512:	f426                	sd	s1,40(sp)
ffffffffc0205514:	f04a                	sd	s2,32(sp)
ffffffffc0205516:	ec4e                	sd	s3,24(sp)
ffffffffc0205518:	e456                	sd	s5,8(sp)
ffffffffc020551a:	e05a                	sd	s6,0(sp)
ffffffffc020551c:	fc06                	sd	ra,56(sp)
ffffffffc020551e:	f822                	sd	s0,48(sp)
ffffffffc0205520:	89aa                	mv	s3,a0
ffffffffc0205522:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205524:	000a7917          	auipc	s2,0xa7
ffffffffc0205528:	32c90913          	addi	s2,s2,812 # ffffffffc02ac850 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020552c:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc020552e:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205530:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc0205532:	02098f63          	beqz	s3,ffffffffc0205570 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205536:	854e                	mv	a0,s3
ffffffffc0205538:	a13ff0ef          	jal	ra,ffffffffc0204f4a <find_proc>
ffffffffc020553c:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc020553e:	12050063          	beqz	a0,ffffffffc020565e <do_wait.part.1+0x154>
ffffffffc0205542:	00093703          	ld	a4,0(s2)
ffffffffc0205546:	711c                	ld	a5,32(a0)
ffffffffc0205548:	10e79b63          	bne	a5,a4,ffffffffc020565e <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020554c:	411c                	lw	a5,0(a0)
ffffffffc020554e:	02978c63          	beq	a5,s1,ffffffffc0205586 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205552:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205556:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc020555a:	261000ef          	jal	ra,ffffffffc0205fba <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020555e:	00093783          	ld	a5,0(s2)
ffffffffc0205562:	0b07a783          	lw	a5,176(a5)
ffffffffc0205566:	8b85                	andi	a5,a5,1
ffffffffc0205568:	d7e9                	beqz	a5,ffffffffc0205532 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc020556a:	555d                	li	a0,-9
ffffffffc020556c:	e51ff0ef          	jal	ra,ffffffffc02053bc <do_exit>
        proc = current->cptr;
ffffffffc0205570:	00093703          	ld	a4,0(s2)
ffffffffc0205574:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205576:	e409                	bnez	s0,ffffffffc0205580 <do_wait.part.1+0x76>
ffffffffc0205578:	a0dd                	j	ffffffffc020565e <do_wait.part.1+0x154>
ffffffffc020557a:	10043403          	ld	s0,256(s0)
ffffffffc020557e:	d871                	beqz	s0,ffffffffc0205552 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205580:	401c                	lw	a5,0(s0)
ffffffffc0205582:	fe979ce3          	bne	a5,s1,ffffffffc020557a <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205586:	000a7797          	auipc	a5,0xa7
ffffffffc020558a:	2d278793          	addi	a5,a5,722 # ffffffffc02ac858 <idleproc>
ffffffffc020558e:	639c                	ld	a5,0(a5)
ffffffffc0205590:	0c878d63          	beq	a5,s0,ffffffffc020566a <do_wait.part.1+0x160>
ffffffffc0205594:	000a7797          	auipc	a5,0xa7
ffffffffc0205598:	2cc78793          	addi	a5,a5,716 # ffffffffc02ac860 <initproc>
ffffffffc020559c:	639c                	ld	a5,0(a5)
ffffffffc020559e:	0cf40663          	beq	s0,a5,ffffffffc020566a <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055a2:	000b0663          	beqz	s6,ffffffffc02055ae <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055a6:	0e842783          	lw	a5,232(s0)
ffffffffc02055aa:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055ae:	100027f3          	csrr	a5,sstatus
ffffffffc02055b2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055b4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055b6:	e7d5                	bnez	a5,ffffffffc0205662 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055b8:	6c70                	ld	a2,216(s0)
ffffffffc02055ba:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055bc:	10043703          	ld	a4,256(s0)
ffffffffc02055c0:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055c2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055c4:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055c6:	6470                	ld	a2,200(s0)
ffffffffc02055c8:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055ca:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055cc:	e290                	sd	a2,0(a3)
ffffffffc02055ce:	c319                	beqz	a4,ffffffffc02055d4 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02055d0:	ff7c                	sd	a5,248(a4)
ffffffffc02055d2:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02055d4:	c3d1                	beqz	a5,ffffffffc0205658 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02055d6:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02055da:	000a7797          	auipc	a5,0xa7
ffffffffc02055de:	28e78793          	addi	a5,a5,654 # ffffffffc02ac868 <nr_process>
ffffffffc02055e2:	439c                	lw	a5,0(a5)
ffffffffc02055e4:	37fd                	addiw	a5,a5,-1
ffffffffc02055e6:	000a7717          	auipc	a4,0xa7
ffffffffc02055ea:	28f72123          	sw	a5,642(a4) # ffffffffc02ac868 <nr_process>
    if (flag) {
ffffffffc02055ee:	e1b5                	bnez	a1,ffffffffc0205652 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02055f0:	6814                	ld	a3,16(s0)
ffffffffc02055f2:	c02007b7          	lui	a5,0xc0200
ffffffffc02055f6:	0af6e263          	bltu	a3,a5,ffffffffc020569a <do_wait.part.1+0x190>
ffffffffc02055fa:	000a7797          	auipc	a5,0xa7
ffffffffc02055fe:	29e78793          	addi	a5,a5,670 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0205602:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205604:	000a7797          	auipc	a5,0xa7
ffffffffc0205608:	23478793          	addi	a5,a5,564 # ffffffffc02ac838 <npage>
ffffffffc020560c:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020560e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205610:	82b1                	srli	a3,a3,0xc
ffffffffc0205612:	06f6f863          	bgeu	a3,a5,ffffffffc0205682 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205616:	00003797          	auipc	a5,0x3
ffffffffc020561a:	6b278793          	addi	a5,a5,1714 # ffffffffc0208cc8 <nbase>
ffffffffc020561e:	639c                	ld	a5,0(a5)
ffffffffc0205620:	000a7717          	auipc	a4,0xa7
ffffffffc0205624:	28870713          	addi	a4,a4,648 # ffffffffc02ac8a8 <pages>
ffffffffc0205628:	6308                	ld	a0,0(a4)
ffffffffc020562a:	8e9d                	sub	a3,a3,a5
ffffffffc020562c:	069a                	slli	a3,a3,0x6
ffffffffc020562e:	9536                	add	a0,a0,a3
ffffffffc0205630:	4589                	li	a1,2
ffffffffc0205632:	8a7fc0ef          	jal	ra,ffffffffc0201ed8 <free_pages>
    kfree(proc);
ffffffffc0205636:	8522                	mv	a0,s0
ffffffffc0205638:	edcfc0ef          	jal	ra,ffffffffc0201d14 <kfree>
    return 0;
ffffffffc020563c:	4501                	li	a0,0
}
ffffffffc020563e:	70e2                	ld	ra,56(sp)
ffffffffc0205640:	7442                	ld	s0,48(sp)
ffffffffc0205642:	74a2                	ld	s1,40(sp)
ffffffffc0205644:	7902                	ld	s2,32(sp)
ffffffffc0205646:	69e2                	ld	s3,24(sp)
ffffffffc0205648:	6a42                	ld	s4,16(sp)
ffffffffc020564a:	6aa2                	ld	s5,8(sp)
ffffffffc020564c:	6b02                	ld	s6,0(sp)
ffffffffc020564e:	6121                	addi	sp,sp,64
ffffffffc0205650:	8082                	ret
        intr_enable();
ffffffffc0205652:	ffbfa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205656:	bf69                	j	ffffffffc02055f0 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205658:	701c                	ld	a5,32(s0)
ffffffffc020565a:	fbf8                	sd	a4,240(a5)
ffffffffc020565c:	bfbd                	j	ffffffffc02055da <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc020565e:	5579                	li	a0,-2
ffffffffc0205660:	bff9                	j	ffffffffc020563e <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205662:	ff1fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205666:	4585                	li	a1,1
ffffffffc0205668:	bf81                	j	ffffffffc02055b8 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc020566a:	00003617          	auipc	a2,0x3
ffffffffc020566e:	f4e60613          	addi	a2,a2,-178 # ffffffffc02085b8 <default_pmm_manager+0x1270>
ffffffffc0205672:	31600593          	li	a1,790
ffffffffc0205676:	00003517          	auipc	a0,0x3
ffffffffc020567a:	18a50513          	addi	a0,a0,394 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc020567e:	e03fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205682:	00002617          	auipc	a2,0x2
ffffffffc0205686:	d7660613          	addi	a2,a2,-650 # ffffffffc02073f8 <default_pmm_manager+0xb0>
ffffffffc020568a:	06200593          	li	a1,98
ffffffffc020568e:	00002517          	auipc	a0,0x2
ffffffffc0205692:	d3250513          	addi	a0,a0,-718 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0205696:	debfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020569a:	00002617          	auipc	a2,0x2
ffffffffc020569e:	d3660613          	addi	a2,a2,-714 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc02056a2:	06e00593          	li	a1,110
ffffffffc02056a6:	00002517          	auipc	a0,0x2
ffffffffc02056aa:	d1a50513          	addi	a0,a0,-742 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc02056ae:	dd3fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02056b2 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056b2:	1141                	addi	sp,sp,-16
ffffffffc02056b4:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056b6:	869fc0ef          	jal	ra,ffffffffc0201f1e <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056ba:	d9afc0ef          	jal	ra,ffffffffc0201c54 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056be:	4601                	li	a2,0
ffffffffc02056c0:	4581                	li	a1,0
ffffffffc02056c2:	fffff517          	auipc	a0,0xfffff
ffffffffc02056c6:	66650513          	addi	a0,a0,1638 # ffffffffc0204d28 <user_main>
ffffffffc02056ca:	ca3ff0ef          	jal	ra,ffffffffc020536c <kernel_thread>
    if (pid <= 0) {
ffffffffc02056ce:	00a04563          	bgtz	a0,ffffffffc02056d8 <init_main+0x26>
ffffffffc02056d2:	a841                	j	ffffffffc0205762 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056d4:	0e7000ef          	jal	ra,ffffffffc0205fba <schedule>
    if (code_store != NULL) {
ffffffffc02056d8:	4581                	li	a1,0
ffffffffc02056da:	4501                	li	a0,0
ffffffffc02056dc:	e2fff0ef          	jal	ra,ffffffffc020550a <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056e0:	d975                	beqz	a0,ffffffffc02056d4 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056e2:	00003517          	auipc	a0,0x3
ffffffffc02056e6:	f1650513          	addi	a0,a0,-234 # ffffffffc02085f8 <default_pmm_manager+0x12b0>
ffffffffc02056ea:	aa5fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056ee:	000a7797          	auipc	a5,0xa7
ffffffffc02056f2:	17278793          	addi	a5,a5,370 # ffffffffc02ac860 <initproc>
ffffffffc02056f6:	639c                	ld	a5,0(a5)
ffffffffc02056f8:	7bf8                	ld	a4,240(a5)
ffffffffc02056fa:	e721                	bnez	a4,ffffffffc0205742 <init_main+0x90>
ffffffffc02056fc:	7ff8                	ld	a4,248(a5)
ffffffffc02056fe:	e331                	bnez	a4,ffffffffc0205742 <init_main+0x90>
ffffffffc0205700:	1007b703          	ld	a4,256(a5)
ffffffffc0205704:	ef1d                	bnez	a4,ffffffffc0205742 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205706:	000a7717          	auipc	a4,0xa7
ffffffffc020570a:	16270713          	addi	a4,a4,354 # ffffffffc02ac868 <nr_process>
ffffffffc020570e:	4314                	lw	a3,0(a4)
ffffffffc0205710:	4709                	li	a4,2
ffffffffc0205712:	0ae69463          	bne	a3,a4,ffffffffc02057ba <init_main+0x108>
    return listelm->next;
ffffffffc0205716:	000a7697          	auipc	a3,0xa7
ffffffffc020571a:	27a68693          	addi	a3,a3,634 # ffffffffc02ac990 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020571e:	6698                	ld	a4,8(a3)
ffffffffc0205720:	0c878793          	addi	a5,a5,200
ffffffffc0205724:	06f71b63          	bne	a4,a5,ffffffffc020579a <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205728:	629c                	ld	a5,0(a3)
ffffffffc020572a:	04f71863          	bne	a4,a5,ffffffffc020577a <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc020572e:	00003517          	auipc	a0,0x3
ffffffffc0205732:	fb250513          	addi	a0,a0,-78 # ffffffffc02086e0 <default_pmm_manager+0x1398>
ffffffffc0205736:	a59fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc020573a:	60a2                	ld	ra,8(sp)
ffffffffc020573c:	4501                	li	a0,0
ffffffffc020573e:	0141                	addi	sp,sp,16
ffffffffc0205740:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205742:	00003697          	auipc	a3,0x3
ffffffffc0205746:	ede68693          	addi	a3,a3,-290 # ffffffffc0208620 <default_pmm_manager+0x12d8>
ffffffffc020574a:	00001617          	auipc	a2,0x1
ffffffffc020574e:	4b660613          	addi	a2,a2,1206 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205752:	37b00593          	li	a1,891
ffffffffc0205756:	00003517          	auipc	a0,0x3
ffffffffc020575a:	0aa50513          	addi	a0,a0,170 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc020575e:	d23fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205762:	00003617          	auipc	a2,0x3
ffffffffc0205766:	e7660613          	addi	a2,a2,-394 # ffffffffc02085d8 <default_pmm_manager+0x1290>
ffffffffc020576a:	37300593          	li	a1,883
ffffffffc020576e:	00003517          	auipc	a0,0x3
ffffffffc0205772:	09250513          	addi	a0,a0,146 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205776:	d0bfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020577a:	00003697          	auipc	a3,0x3
ffffffffc020577e:	f3668693          	addi	a3,a3,-202 # ffffffffc02086b0 <default_pmm_manager+0x1368>
ffffffffc0205782:	00001617          	auipc	a2,0x1
ffffffffc0205786:	47e60613          	addi	a2,a2,1150 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc020578a:	37e00593          	li	a1,894
ffffffffc020578e:	00003517          	auipc	a0,0x3
ffffffffc0205792:	07250513          	addi	a0,a0,114 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205796:	cebfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020579a:	00003697          	auipc	a3,0x3
ffffffffc020579e:	ee668693          	addi	a3,a3,-282 # ffffffffc0208680 <default_pmm_manager+0x1338>
ffffffffc02057a2:	00001617          	auipc	a2,0x1
ffffffffc02057a6:	45e60613          	addi	a2,a2,1118 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02057aa:	37d00593          	li	a1,893
ffffffffc02057ae:	00003517          	auipc	a0,0x3
ffffffffc02057b2:	05250513          	addi	a0,a0,82 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02057b6:	ccbfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_process == 2);
ffffffffc02057ba:	00003697          	auipc	a3,0x3
ffffffffc02057be:	eb668693          	addi	a3,a3,-330 # ffffffffc0208670 <default_pmm_manager+0x1328>
ffffffffc02057c2:	00001617          	auipc	a2,0x1
ffffffffc02057c6:	43e60613          	addi	a2,a2,1086 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc02057ca:	37c00593          	li	a1,892
ffffffffc02057ce:	00003517          	auipc	a0,0x3
ffffffffc02057d2:	03250513          	addi	a0,a0,50 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02057d6:	cabfa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02057da <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057da:	7135                	addi	sp,sp,-160
ffffffffc02057dc:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057de:	000a7a17          	auipc	s4,0xa7
ffffffffc02057e2:	072a0a13          	addi	s4,s4,114 # ffffffffc02ac850 <current>
ffffffffc02057e6:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057ea:	e14a                	sd	s2,128(sp)
ffffffffc02057ec:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057ee:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057f2:	fcce                	sd	s3,120(sp)
ffffffffc02057f4:	f0da                	sd	s6,96(sp)
ffffffffc02057f6:	89aa                	mv	s3,a0
ffffffffc02057f8:	842e                	mv	s0,a1
ffffffffc02057fa:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057fc:	4681                	li	a3,0
ffffffffc02057fe:	862e                	mv	a2,a1
ffffffffc0205800:	85aa                	mv	a1,a0
ffffffffc0205802:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205804:	ed06                	sd	ra,152(sp)
ffffffffc0205806:	e526                	sd	s1,136(sp)
ffffffffc0205808:	f4d6                	sd	s5,104(sp)
ffffffffc020580a:	ecde                	sd	s7,88(sp)
ffffffffc020580c:	e8e2                	sd	s8,80(sp)
ffffffffc020580e:	e4e6                	sd	s9,72(sp)
ffffffffc0205810:	e0ea                	sd	s10,64(sp)
ffffffffc0205812:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205814:	a90ff0ef          	jal	ra,ffffffffc0204aa4 <user_mem_check>
ffffffffc0205818:	40050263          	beqz	a0,ffffffffc0205c1c <do_execve+0x442>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020581c:	4641                	li	a2,16
ffffffffc020581e:	4581                	li	a1,0
ffffffffc0205820:	1008                	addi	a0,sp,32
ffffffffc0205822:	5b1000ef          	jal	ra,ffffffffc02065d2 <memset>
    memcpy(local_name, name, len);
ffffffffc0205826:	47bd                	li	a5,15
ffffffffc0205828:	8622                	mv	a2,s0
ffffffffc020582a:	0687ee63          	bltu	a5,s0,ffffffffc02058a6 <do_execve+0xcc>
ffffffffc020582e:	85ce                	mv	a1,s3
ffffffffc0205830:	1008                	addi	a0,sp,32
ffffffffc0205832:	5b3000ef          	jal	ra,ffffffffc02065e4 <memcpy>
    if (mm != NULL) {
ffffffffc0205836:	06090f63          	beqz	s2,ffffffffc02058b4 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc020583a:	00002517          	auipc	a0,0x2
ffffffffc020583e:	2fe50513          	addi	a0,a0,766 # ffffffffc0207b38 <default_pmm_manager+0x7f0>
ffffffffc0205842:	983fa0ef          	jal	ra,ffffffffc02001c4 <cputs>
        lcr3(boot_cr3);
ffffffffc0205846:	000a7797          	auipc	a5,0xa7
ffffffffc020584a:	05a78793          	addi	a5,a5,90 # ffffffffc02ac8a0 <boot_cr3>
ffffffffc020584e:	639c                	ld	a5,0(a5)
ffffffffc0205850:	577d                	li	a4,-1
ffffffffc0205852:	177e                	slli	a4,a4,0x3f
ffffffffc0205854:	83b1                	srli	a5,a5,0xc
ffffffffc0205856:	8fd9                	or	a5,a5,a4
ffffffffc0205858:	18079073          	csrw	satp,a5
ffffffffc020585c:	03092783          	lw	a5,48(s2)
ffffffffc0205860:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205864:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205868:	28070c63          	beqz	a4,ffffffffc0205b00 <do_execve+0x326>
        current->mm = NULL;
ffffffffc020586c:	000a3783          	ld	a5,0(s4)
ffffffffc0205870:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205874:	853fe0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0205878:	892a                	mv	s2,a0
ffffffffc020587a:	c135                	beqz	a0,ffffffffc02058de <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc020587c:	dacff0ef          	jal	ra,ffffffffc0204e28 <setup_pgdir>
ffffffffc0205880:	e931                	bnez	a0,ffffffffc02058d4 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205882:	000b2703          	lw	a4,0(s6)
ffffffffc0205886:	464c47b7          	lui	a5,0x464c4
ffffffffc020588a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc020588e:	04f70a63          	beq	a4,a5,ffffffffc02058e2 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205892:	854a                	mv	a0,s2
ffffffffc0205894:	d16ff0ef          	jal	ra,ffffffffc0204daa <put_pgdir>
    mm_destroy(mm);
ffffffffc0205898:	854a                	mv	a0,s2
ffffffffc020589a:	9b3fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020589e:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058a0:	854e                	mv	a0,s3
ffffffffc02058a2:	b1bff0ef          	jal	ra,ffffffffc02053bc <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058a6:	463d                	li	a2,15
ffffffffc02058a8:	85ce                	mv	a1,s3
ffffffffc02058aa:	1008                	addi	a0,sp,32
ffffffffc02058ac:	539000ef          	jal	ra,ffffffffc02065e4 <memcpy>
    if (mm != NULL) {
ffffffffc02058b0:	f80915e3          	bnez	s2,ffffffffc020583a <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058b4:	000a3783          	ld	a5,0(s4)
ffffffffc02058b8:	779c                	ld	a5,40(a5)
ffffffffc02058ba:	dfcd                	beqz	a5,ffffffffc0205874 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058bc:	00003617          	auipc	a2,0x3
ffffffffc02058c0:	b0c60613          	addi	a2,a2,-1268 # ffffffffc02083c8 <default_pmm_manager+0x1080>
ffffffffc02058c4:	22900593          	li	a1,553
ffffffffc02058c8:	00003517          	auipc	a0,0x3
ffffffffc02058cc:	f3850513          	addi	a0,a0,-200 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc02058d0:	bb1fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    mm_destroy(mm);
ffffffffc02058d4:	854a                	mv	a0,s2
ffffffffc02058d6:	977fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02058da:	59f1                	li	s3,-4
ffffffffc02058dc:	b7d1                	j	ffffffffc02058a0 <do_execve+0xc6>
ffffffffc02058de:	59f1                	li	s3,-4
ffffffffc02058e0:	b7c1                	j	ffffffffc02058a0 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058e2:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058e6:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058ea:	00371793          	slli	a5,a4,0x3
ffffffffc02058ee:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058f0:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058f2:	078e                	slli	a5,a5,0x3
ffffffffc02058f4:	97a2                	add	a5,a5,s0
ffffffffc02058f6:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02058f8:	02f47b63          	bgeu	s0,a5,ffffffffc020592e <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02058fc:	5bfd                	li	s7,-1
ffffffffc02058fe:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205902:	000a7d97          	auipc	s11,0xa7
ffffffffc0205906:	fa6d8d93          	addi	s11,s11,-90 # ffffffffc02ac8a8 <pages>
ffffffffc020590a:	00003d17          	auipc	s10,0x3
ffffffffc020590e:	3bed0d13          	addi	s10,s10,958 # ffffffffc0208cc8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205912:	e43e                	sd	a5,8(sp)
ffffffffc0205914:	000a7c97          	auipc	s9,0xa7
ffffffffc0205918:	f24c8c93          	addi	s9,s9,-220 # ffffffffc02ac838 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020591c:	4018                	lw	a4,0(s0)
ffffffffc020591e:	4785                	li	a5,1
ffffffffc0205920:	0ef70d63          	beq	a4,a5,ffffffffc0205a1a <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205924:	67e2                	ld	a5,24(sp)
ffffffffc0205926:	03840413          	addi	s0,s0,56
ffffffffc020592a:	fef469e3          	bltu	s0,a5,ffffffffc020591c <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020592e:	4701                	li	a4,0
ffffffffc0205930:	46ad                	li	a3,11
ffffffffc0205932:	00100637          	lui	a2,0x100
ffffffffc0205936:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020593a:	854a                	mv	a0,s2
ffffffffc020593c:	963fe0ef          	jal	ra,ffffffffc020429e <mm_map>
ffffffffc0205940:	89aa                	mv	s3,a0
ffffffffc0205942:	1a051563          	bnez	a0,ffffffffc0205aec <do_execve+0x312>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205946:	01893503          	ld	a0,24(s2)
ffffffffc020594a:	467d                	li	a2,31
ffffffffc020594c:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205950:	999fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205954:	36050063          	beqz	a0,ffffffffc0205cb4 <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205958:	01893503          	ld	a0,24(s2)
ffffffffc020595c:	467d                	li	a2,31
ffffffffc020595e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205962:	987fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205966:	32050763          	beqz	a0,ffffffffc0205c94 <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020596a:	01893503          	ld	a0,24(s2)
ffffffffc020596e:	467d                	li	a2,31
ffffffffc0205970:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205974:	975fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205978:	2e050e63          	beqz	a0,ffffffffc0205c74 <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020597c:	01893503          	ld	a0,24(s2)
ffffffffc0205980:	467d                	li	a2,31
ffffffffc0205982:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205986:	963fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc020598a:	2c050563          	beqz	a0,ffffffffc0205c54 <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc020598e:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205992:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205996:	01893683          	ld	a3,24(s2)
ffffffffc020599a:	2785                	addiw	a5,a5,1
ffffffffc020599c:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059a0:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5560>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02059a8:	28f6ea63          	bltu	a3,a5,ffffffffc0205c3c <do_execve+0x462>
ffffffffc02059ac:	000a7797          	auipc	a5,0xa7
ffffffffc02059b0:	eec78793          	addi	a5,a5,-276 # ffffffffc02ac898 <va_pa_offset>
ffffffffc02059b4:	639c                	ld	a5,0(a5)
ffffffffc02059b6:	577d                	li	a4,-1
ffffffffc02059b8:	177e                	slli	a4,a4,0x3f
ffffffffc02059ba:	8e9d                	sub	a3,a3,a5
ffffffffc02059bc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059c0:	f654                	sd	a3,168(a2)
ffffffffc02059c2:	8fd9                	or	a5,a5,a4
ffffffffc02059c4:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059c8:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059ca:	4581                	li	a1,0
ffffffffc02059cc:	12000613          	li	a2,288
ffffffffc02059d0:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02059d2:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059d6:	3fd000ef          	jal	ra,ffffffffc02065d2 <memset>
    tf->epc = elf->e_entry;
ffffffffc02059da:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc02059de:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc02059e0:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059e4:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc02059e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02059ea:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02059ec:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059f0:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc02059f4:	100c                	addi	a1,sp,32
ffffffffc02059f6:	cbeff0ef          	jal	ra,ffffffffc0204eb4 <set_proc_name>
}
ffffffffc02059fa:	60ea                	ld	ra,152(sp)
ffffffffc02059fc:	644a                	ld	s0,144(sp)
ffffffffc02059fe:	854e                	mv	a0,s3
ffffffffc0205a00:	64aa                	ld	s1,136(sp)
ffffffffc0205a02:	690a                	ld	s2,128(sp)
ffffffffc0205a04:	79e6                	ld	s3,120(sp)
ffffffffc0205a06:	7a46                	ld	s4,112(sp)
ffffffffc0205a08:	7aa6                	ld	s5,104(sp)
ffffffffc0205a0a:	7b06                	ld	s6,96(sp)
ffffffffc0205a0c:	6be6                	ld	s7,88(sp)
ffffffffc0205a0e:	6c46                	ld	s8,80(sp)
ffffffffc0205a10:	6ca6                	ld	s9,72(sp)
ffffffffc0205a12:	6d06                	ld	s10,64(sp)
ffffffffc0205a14:	7de2                	ld	s11,56(sp)
ffffffffc0205a16:	610d                	addi	sp,sp,160
ffffffffc0205a18:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a1a:	7410                	ld	a2,40(s0)
ffffffffc0205a1c:	701c                	ld	a5,32(s0)
ffffffffc0205a1e:	20f66163          	bltu	a2,a5,ffffffffc0205c20 <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a22:	405c                	lw	a5,4(s0)
ffffffffc0205a24:	0017f693          	andi	a3,a5,1
ffffffffc0205a28:	c291                	beqz	a3,ffffffffc0205a2c <do_execve+0x252>
ffffffffc0205a2a:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a2c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a30:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a32:	0e071163          	bnez	a4,ffffffffc0205b14 <do_execve+0x33a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a36:	4745                	li	a4,17
ffffffffc0205a38:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a3a:	c789                	beqz	a5,ffffffffc0205a44 <do_execve+0x26a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a3c:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a3e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a42:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a44:	0026f793          	andi	a5,a3,2
ffffffffc0205a48:	ebe9                	bnez	a5,ffffffffc0205b1a <do_execve+0x340>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a4a:	0046f793          	andi	a5,a3,4
ffffffffc0205a4e:	c789                	beqz	a5,ffffffffc0205a58 <do_execve+0x27e>
ffffffffc0205a50:	6782                	ld	a5,0(sp)
ffffffffc0205a52:	0087e793          	ori	a5,a5,8
ffffffffc0205a56:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a58:	680c                	ld	a1,16(s0)
ffffffffc0205a5a:	4701                	li	a4,0
ffffffffc0205a5c:	854a                	mv	a0,s2
ffffffffc0205a5e:	841fe0ef          	jal	ra,ffffffffc020429e <mm_map>
ffffffffc0205a62:	89aa                	mv	s3,a0
ffffffffc0205a64:	e541                	bnez	a0,ffffffffc0205aec <do_execve+0x312>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a66:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a6a:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a6e:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a72:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a74:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a76:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a78:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205a7c:	053bef63          	bltu	s7,s3,ffffffffc0205ada <do_execve+0x300>
ffffffffc0205a80:	aa61                	j	ffffffffc0205c18 <do_execve+0x43e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a82:	6785                	lui	a5,0x1
ffffffffc0205a84:	418b8533          	sub	a0,s7,s8
ffffffffc0205a88:	9c3e                	add	s8,s8,a5
ffffffffc0205a8a:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205a8e:	0189f463          	bgeu	s3,s8,ffffffffc0205a96 <do_execve+0x2bc>
                size -= la - end;
ffffffffc0205a92:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205a96:	000db683          	ld	a3,0(s11)
ffffffffc0205a9a:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205a9e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205aa0:	40d486b3          	sub	a3,s1,a3
ffffffffc0205aa4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205aa6:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205aaa:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205aac:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ab0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ab2:	16c5f963          	bgeu	a1,a2,ffffffffc0205c24 <do_execve+0x44a>
ffffffffc0205ab6:	000a7797          	auipc	a5,0xa7
ffffffffc0205aba:	de278793          	addi	a5,a5,-542 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0205abe:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ac2:	85d6                	mv	a1,s5
ffffffffc0205ac4:	8642                	mv	a2,a6
ffffffffc0205ac6:	96c6                	add	a3,a3,a7
ffffffffc0205ac8:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205aca:	9bc2                	add	s7,s7,a6
ffffffffc0205acc:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ace:	317000ef          	jal	ra,ffffffffc02065e4 <memcpy>
            start += size, from += size;
ffffffffc0205ad2:	6842                	ld	a6,16(sp)
ffffffffc0205ad4:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205ad6:	053bf563          	bgeu	s7,s3,ffffffffc0205b20 <do_execve+0x346>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ada:	01893503          	ld	a0,24(s2)
ffffffffc0205ade:	6602                	ld	a2,0(sp)
ffffffffc0205ae0:	85e2                	mv	a1,s8
ffffffffc0205ae2:	807fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205ae6:	84aa                	mv	s1,a0
ffffffffc0205ae8:	fd49                	bnez	a0,ffffffffc0205a82 <do_execve+0x2a8>
        ret = -E_NO_MEM;
ffffffffc0205aea:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205aec:	854a                	mv	a0,s2
ffffffffc0205aee:	8fffe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
    put_pgdir(mm);
ffffffffc0205af2:	854a                	mv	a0,s2
ffffffffc0205af4:	ab6ff0ef          	jal	ra,ffffffffc0204daa <put_pgdir>
    mm_destroy(mm);
ffffffffc0205af8:	854a                	mv	a0,s2
ffffffffc0205afa:	f52fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    return ret;
ffffffffc0205afe:	b34d                	j	ffffffffc02058a0 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b00:	854a                	mv	a0,s2
ffffffffc0205b02:	8ebfe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b06:	854a                	mv	a0,s2
ffffffffc0205b08:	aa2ff0ef          	jal	ra,ffffffffc0204daa <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b0c:	854a                	mv	a0,s2
ffffffffc0205b0e:	f3efe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
ffffffffc0205b12:	bba9                	j	ffffffffc020586c <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b14:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b18:	f395                	bnez	a5,ffffffffc0205a3c <do_execve+0x262>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b1a:	47dd                	li	a5,23
ffffffffc0205b1c:	e03e                	sd	a5,0(sp)
ffffffffc0205b1e:	b735                	j	ffffffffc0205a4a <do_execve+0x270>
ffffffffc0205b20:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b24:	7414                	ld	a3,40(s0)
ffffffffc0205b26:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b28:	098bf163          	bgeu	s7,s8,ffffffffc0205baa <do_execve+0x3d0>
            if (start == end) {
ffffffffc0205b2c:	df798ce3          	beq	s3,s7,ffffffffc0205924 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b30:	6505                	lui	a0,0x1
ffffffffc0205b32:	955e                	add	a0,a0,s7
ffffffffc0205b34:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b38:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b3c:	0d89fb63          	bgeu	s3,s8,ffffffffc0205c12 <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0205b40:	000db683          	ld	a3,0(s11)
ffffffffc0205b44:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b48:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b4a:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b4e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b50:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b54:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b56:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b5c:	0cc5f463          	bgeu	a1,a2,ffffffffc0205c24 <do_execve+0x44a>
ffffffffc0205b60:	000a7617          	auipc	a2,0xa7
ffffffffc0205b64:	d3860613          	addi	a2,a2,-712 # ffffffffc02ac898 <va_pa_offset>
ffffffffc0205b68:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b6c:	4581                	li	a1,0
ffffffffc0205b6e:	8656                	mv	a2,s5
ffffffffc0205b70:	96c2                	add	a3,a3,a6
ffffffffc0205b72:	9536                	add	a0,a0,a3
ffffffffc0205b74:	25f000ef          	jal	ra,ffffffffc02065d2 <memset>
            start += size;
ffffffffc0205b78:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b7c:	0389f463          	bgeu	s3,s8,ffffffffc0205ba4 <do_execve+0x3ca>
ffffffffc0205b80:	dae982e3          	beq	s3,a4,ffffffffc0205924 <do_execve+0x14a>
ffffffffc0205b84:	00003697          	auipc	a3,0x3
ffffffffc0205b88:	86c68693          	addi	a3,a3,-1940 # ffffffffc02083f0 <default_pmm_manager+0x10a8>
ffffffffc0205b8c:	00001617          	auipc	a2,0x1
ffffffffc0205b90:	07460613          	addi	a2,a2,116 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205b94:	27e00593          	li	a1,638
ffffffffc0205b98:	00003517          	auipc	a0,0x3
ffffffffc0205b9c:	c6850513          	addi	a0,a0,-920 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205ba0:	8e1fa0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0205ba4:	ff8710e3          	bne	a4,s8,ffffffffc0205b84 <do_execve+0x3aa>
ffffffffc0205ba8:	8be2                	mv	s7,s8
ffffffffc0205baa:	000a7a97          	auipc	s5,0xa7
ffffffffc0205bae:	ceea8a93          	addi	s5,s5,-786 # ffffffffc02ac898 <va_pa_offset>
        while (start < end) {
ffffffffc0205bb2:	053be763          	bltu	s7,s3,ffffffffc0205c00 <do_execve+0x426>
ffffffffc0205bb6:	b3bd                	j	ffffffffc0205924 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bb8:	6785                	lui	a5,0x1
ffffffffc0205bba:	418b8533          	sub	a0,s7,s8
ffffffffc0205bbe:	9c3e                	add	s8,s8,a5
ffffffffc0205bc0:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205bc4:	0189f463          	bgeu	s3,s8,ffffffffc0205bcc <do_execve+0x3f2>
                size -= la - end;
ffffffffc0205bc8:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205bcc:	000db683          	ld	a3,0(s11)
ffffffffc0205bd0:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bd4:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205bd6:	40d486b3          	sub	a3,s1,a3
ffffffffc0205bda:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bdc:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205be0:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205be2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205be6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205be8:	02b87e63          	bgeu	a6,a1,ffffffffc0205c24 <do_execve+0x44a>
ffffffffc0205bec:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205bf0:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bf2:	4581                	li	a1,0
ffffffffc0205bf4:	96c2                	add	a3,a3,a6
ffffffffc0205bf6:	9536                	add	a0,a0,a3
ffffffffc0205bf8:	1db000ef          	jal	ra,ffffffffc02065d2 <memset>
        while (start < end) {
ffffffffc0205bfc:	d33bf4e3          	bgeu	s7,s3,ffffffffc0205924 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c00:	01893503          	ld	a0,24(s2)
ffffffffc0205c04:	6602                	ld	a2,0(sp)
ffffffffc0205c06:	85e2                	mv	a1,s8
ffffffffc0205c08:	ee0fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205c0c:	84aa                	mv	s1,a0
ffffffffc0205c0e:	f54d                	bnez	a0,ffffffffc0205bb8 <do_execve+0x3de>
ffffffffc0205c10:	bde9                	j	ffffffffc0205aea <do_execve+0x310>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c12:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c16:	b72d                	j	ffffffffc0205b40 <do_execve+0x366>
        while (start < end) {
ffffffffc0205c18:	89de                	mv	s3,s7
ffffffffc0205c1a:	b729                	j	ffffffffc0205b24 <do_execve+0x34a>
        return -E_INVAL;
ffffffffc0205c1c:	59f5                	li	s3,-3
ffffffffc0205c1e:	bbf1                	j	ffffffffc02059fa <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c20:	59e1                	li	s3,-8
ffffffffc0205c22:	b5e9                	j	ffffffffc0205aec <do_execve+0x312>
ffffffffc0205c24:	00001617          	auipc	a2,0x1
ffffffffc0205c28:	77460613          	addi	a2,a2,1908 # ffffffffc0207398 <default_pmm_manager+0x50>
ffffffffc0205c2c:	06900593          	li	a1,105
ffffffffc0205c30:	00001517          	auipc	a0,0x1
ffffffffc0205c34:	79050513          	addi	a0,a0,1936 # ffffffffc02073c0 <default_pmm_manager+0x78>
ffffffffc0205c38:	849fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c3c:	00001617          	auipc	a2,0x1
ffffffffc0205c40:	79460613          	addi	a2,a2,1940 # ffffffffc02073d0 <default_pmm_manager+0x88>
ffffffffc0205c44:	29900593          	li	a1,665
ffffffffc0205c48:	00003517          	auipc	a0,0x3
ffffffffc0205c4c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205c50:	831fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c54:	00003697          	auipc	a3,0x3
ffffffffc0205c58:	8b468693          	addi	a3,a3,-1868 # ffffffffc0208508 <default_pmm_manager+0x11c0>
ffffffffc0205c5c:	00001617          	auipc	a2,0x1
ffffffffc0205c60:	fa460613          	addi	a2,a2,-92 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205c64:	29400593          	li	a1,660
ffffffffc0205c68:	00003517          	auipc	a0,0x3
ffffffffc0205c6c:	b9850513          	addi	a0,a0,-1128 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205c70:	811fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c74:	00003697          	auipc	a3,0x3
ffffffffc0205c78:	84c68693          	addi	a3,a3,-1972 # ffffffffc02084c0 <default_pmm_manager+0x1178>
ffffffffc0205c7c:	00001617          	auipc	a2,0x1
ffffffffc0205c80:	f8460613          	addi	a2,a2,-124 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205c84:	29300593          	li	a1,659
ffffffffc0205c88:	00003517          	auipc	a0,0x3
ffffffffc0205c8c:	b7850513          	addi	a0,a0,-1160 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205c90:	ff0fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c94:	00002697          	auipc	a3,0x2
ffffffffc0205c98:	7e468693          	addi	a3,a3,2020 # ffffffffc0208478 <default_pmm_manager+0x1130>
ffffffffc0205c9c:	00001617          	auipc	a2,0x1
ffffffffc0205ca0:	f6460613          	addi	a2,a2,-156 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205ca4:	29200593          	li	a1,658
ffffffffc0205ca8:	00003517          	auipc	a0,0x3
ffffffffc0205cac:	b5850513          	addi	a0,a0,-1192 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205cb0:	fd0fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cb4:	00002697          	auipc	a3,0x2
ffffffffc0205cb8:	77c68693          	addi	a3,a3,1916 # ffffffffc0208430 <default_pmm_manager+0x10e8>
ffffffffc0205cbc:	00001617          	auipc	a2,0x1
ffffffffc0205cc0:	f4460613          	addi	a2,a2,-188 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205cc4:	29100593          	li	a1,657
ffffffffc0205cc8:	00003517          	auipc	a0,0x3
ffffffffc0205ccc:	b3850513          	addi	a0,a0,-1224 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205cd0:	fb0fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205cd4 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cd4:	000a7797          	auipc	a5,0xa7
ffffffffc0205cd8:	b7c78793          	addi	a5,a5,-1156 # ffffffffc02ac850 <current>
ffffffffc0205cdc:	639c                	ld	a5,0(a5)
ffffffffc0205cde:	4705                	li	a4,1
}
ffffffffc0205ce0:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205ce2:	ef98                	sd	a4,24(a5)
}
ffffffffc0205ce4:	8082                	ret

ffffffffc0205ce6 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205ce6:	1101                	addi	sp,sp,-32
ffffffffc0205ce8:	e822                	sd	s0,16(sp)
ffffffffc0205cea:	e426                	sd	s1,8(sp)
ffffffffc0205cec:	ec06                	sd	ra,24(sp)
ffffffffc0205cee:	842e                	mv	s0,a1
ffffffffc0205cf0:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205cf2:	cd81                	beqz	a1,ffffffffc0205d0a <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205cf4:	000a7797          	auipc	a5,0xa7
ffffffffc0205cf8:	b5c78793          	addi	a5,a5,-1188 # ffffffffc02ac850 <current>
ffffffffc0205cfc:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205cfe:	4685                	li	a3,1
ffffffffc0205d00:	4611                	li	a2,4
ffffffffc0205d02:	7788                	ld	a0,40(a5)
ffffffffc0205d04:	da1fe0ef          	jal	ra,ffffffffc0204aa4 <user_mem_check>
ffffffffc0205d08:	c909                	beqz	a0,ffffffffc0205d1a <do_wait+0x34>
ffffffffc0205d0a:	85a2                	mv	a1,s0
}
ffffffffc0205d0c:	6442                	ld	s0,16(sp)
ffffffffc0205d0e:	60e2                	ld	ra,24(sp)
ffffffffc0205d10:	8526                	mv	a0,s1
ffffffffc0205d12:	64a2                	ld	s1,8(sp)
ffffffffc0205d14:	6105                	addi	sp,sp,32
ffffffffc0205d16:	ff4ff06f          	j	ffffffffc020550a <do_wait.part.1>
ffffffffc0205d1a:	60e2                	ld	ra,24(sp)
ffffffffc0205d1c:	6442                	ld	s0,16(sp)
ffffffffc0205d1e:	64a2                	ld	s1,8(sp)
ffffffffc0205d20:	5575                	li	a0,-3
ffffffffc0205d22:	6105                	addi	sp,sp,32
ffffffffc0205d24:	8082                	ret

ffffffffc0205d26 <do_kill>:
do_kill(int pid) {
ffffffffc0205d26:	1141                	addi	sp,sp,-16
ffffffffc0205d28:	e406                	sd	ra,8(sp)
ffffffffc0205d2a:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d2c:	a1eff0ef          	jal	ra,ffffffffc0204f4a <find_proc>
ffffffffc0205d30:	cd0d                	beqz	a0,ffffffffc0205d6a <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d32:	0b052703          	lw	a4,176(a0)
ffffffffc0205d36:	00177693          	andi	a3,a4,1
ffffffffc0205d3a:	e695                	bnez	a3,ffffffffc0205d66 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d3c:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d40:	00176713          	ori	a4,a4,1
ffffffffc0205d44:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d48:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d4a:	0006c763          	bltz	a3,ffffffffc0205d58 <do_kill+0x32>
}
ffffffffc0205d4e:	8522                	mv	a0,s0
ffffffffc0205d50:	60a2                	ld	ra,8(sp)
ffffffffc0205d52:	6402                	ld	s0,0(sp)
ffffffffc0205d54:	0141                	addi	sp,sp,16
ffffffffc0205d56:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d58:	1e6000ef          	jal	ra,ffffffffc0205f3e <wakeup_proc>
}
ffffffffc0205d5c:	8522                	mv	a0,s0
ffffffffc0205d5e:	60a2                	ld	ra,8(sp)
ffffffffc0205d60:	6402                	ld	s0,0(sp)
ffffffffc0205d62:	0141                	addi	sp,sp,16
ffffffffc0205d64:	8082                	ret
        return -E_KILLED;
ffffffffc0205d66:	545d                	li	s0,-9
ffffffffc0205d68:	b7dd                	j	ffffffffc0205d4e <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205d6a:	5475                	li	s0,-3
ffffffffc0205d6c:	b7cd                	j	ffffffffc0205d4e <do_kill+0x28>

ffffffffc0205d6e <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205d6e:	000a7797          	auipc	a5,0xa7
ffffffffc0205d72:	c2278793          	addi	a5,a5,-990 # ffffffffc02ac990 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d76:	1101                	addi	sp,sp,-32
ffffffffc0205d78:	000a7717          	auipc	a4,0xa7
ffffffffc0205d7c:	c2f73023          	sd	a5,-992(a4) # ffffffffc02ac998 <proc_list+0x8>
ffffffffc0205d80:	000a7717          	auipc	a4,0xa7
ffffffffc0205d84:	c0f73823          	sd	a5,-1008(a4) # ffffffffc02ac990 <proc_list>
ffffffffc0205d88:	ec06                	sd	ra,24(sp)
ffffffffc0205d8a:	e822                	sd	s0,16(sp)
ffffffffc0205d8c:	e426                	sd	s1,8(sp)
ffffffffc0205d8e:	000a3797          	auipc	a5,0xa3
ffffffffc0205d92:	a7a78793          	addi	a5,a5,-1414 # ffffffffc02a8808 <hash_list>
ffffffffc0205d96:	000a7717          	auipc	a4,0xa7
ffffffffc0205d9a:	a7270713          	addi	a4,a4,-1422 # ffffffffc02ac808 <is_panic>
ffffffffc0205d9e:	e79c                	sd	a5,8(a5)
ffffffffc0205da0:	e39c                	sd	a5,0(a5)
ffffffffc0205da2:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205da4:	fee79de3          	bne	a5,a4,ffffffffc0205d9e <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205da8:	f01fe0ef          	jal	ra,ffffffffc0204ca8 <alloc_proc>
ffffffffc0205dac:	000a7717          	auipc	a4,0xa7
ffffffffc0205db0:	aaa73623          	sd	a0,-1364(a4) # ffffffffc02ac858 <idleproc>
ffffffffc0205db4:	000a7497          	auipc	s1,0xa7
ffffffffc0205db8:	aa448493          	addi	s1,s1,-1372 # ffffffffc02ac858 <idleproc>
ffffffffc0205dbc:	c559                	beqz	a0,ffffffffc0205e4a <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205dbe:	4709                	li	a4,2
ffffffffc0205dc0:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205dc2:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dc4:	00003717          	auipc	a4,0x3
ffffffffc0205dc8:	23c70713          	addi	a4,a4,572 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205dcc:	00003597          	auipc	a1,0x3
ffffffffc0205dd0:	94c58593          	addi	a1,a1,-1716 # ffffffffc0208718 <default_pmm_manager+0x13d0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dd4:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205dd6:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205dd8:	8dcff0ef          	jal	ra,ffffffffc0204eb4 <set_proc_name>
    nr_process ++;
ffffffffc0205ddc:	000a7797          	auipc	a5,0xa7
ffffffffc0205de0:	a8c78793          	addi	a5,a5,-1396 # ffffffffc02ac868 <nr_process>
ffffffffc0205de4:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205de6:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205de8:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205dea:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dec:	4581                	li	a1,0
ffffffffc0205dee:	00000517          	auipc	a0,0x0
ffffffffc0205df2:	8c450513          	addi	a0,a0,-1852 # ffffffffc02056b2 <init_main>
    nr_process ++;
ffffffffc0205df6:	000a7697          	auipc	a3,0xa7
ffffffffc0205dfa:	a6f6a923          	sw	a5,-1422(a3) # ffffffffc02ac868 <nr_process>
    current = idleproc;
ffffffffc0205dfe:	000a7797          	auipc	a5,0xa7
ffffffffc0205e02:	a4e7b923          	sd	a4,-1454(a5) # ffffffffc02ac850 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e06:	d66ff0ef          	jal	ra,ffffffffc020536c <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e0a:	08a05c63          	blez	a0,ffffffffc0205ea2 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e0e:	93cff0ef          	jal	ra,ffffffffc0204f4a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e12:	00003597          	auipc	a1,0x3
ffffffffc0205e16:	92e58593          	addi	a1,a1,-1746 # ffffffffc0208740 <default_pmm_manager+0x13f8>
    initproc = find_proc(pid);
ffffffffc0205e1a:	000a7797          	auipc	a5,0xa7
ffffffffc0205e1e:	a4a7b323          	sd	a0,-1466(a5) # ffffffffc02ac860 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e22:	892ff0ef          	jal	ra,ffffffffc0204eb4 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e26:	609c                	ld	a5,0(s1)
ffffffffc0205e28:	cfa9                	beqz	a5,ffffffffc0205e82 <proc_init+0x114>
ffffffffc0205e2a:	43dc                	lw	a5,4(a5)
ffffffffc0205e2c:	ebb9                	bnez	a5,ffffffffc0205e82 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e2e:	000a7797          	auipc	a5,0xa7
ffffffffc0205e32:	a3278793          	addi	a5,a5,-1486 # ffffffffc02ac860 <initproc>
ffffffffc0205e36:	639c                	ld	a5,0(a5)
ffffffffc0205e38:	c78d                	beqz	a5,ffffffffc0205e62 <proc_init+0xf4>
ffffffffc0205e3a:	43dc                	lw	a5,4(a5)
ffffffffc0205e3c:	02879363          	bne	a5,s0,ffffffffc0205e62 <proc_init+0xf4>
}
ffffffffc0205e40:	60e2                	ld	ra,24(sp)
ffffffffc0205e42:	6442                	ld	s0,16(sp)
ffffffffc0205e44:	64a2                	ld	s1,8(sp)
ffffffffc0205e46:	6105                	addi	sp,sp,32
ffffffffc0205e48:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e4a:	00003617          	auipc	a2,0x3
ffffffffc0205e4e:	8b660613          	addi	a2,a2,-1866 # ffffffffc0208700 <default_pmm_manager+0x13b8>
ffffffffc0205e52:	39000593          	li	a1,912
ffffffffc0205e56:	00003517          	auipc	a0,0x3
ffffffffc0205e5a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205e5e:	e22fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e62:	00003697          	auipc	a3,0x3
ffffffffc0205e66:	90e68693          	addi	a3,a3,-1778 # ffffffffc0208770 <default_pmm_manager+0x1428>
ffffffffc0205e6a:	00001617          	auipc	a2,0x1
ffffffffc0205e6e:	d9660613          	addi	a2,a2,-618 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205e72:	3a500593          	li	a1,933
ffffffffc0205e76:	00003517          	auipc	a0,0x3
ffffffffc0205e7a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205e7e:	e02fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e82:	00003697          	auipc	a3,0x3
ffffffffc0205e86:	8c668693          	addi	a3,a3,-1850 # ffffffffc0208748 <default_pmm_manager+0x1400>
ffffffffc0205e8a:	00001617          	auipc	a2,0x1
ffffffffc0205e8e:	d7660613          	addi	a2,a2,-650 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205e92:	3a400593          	li	a1,932
ffffffffc0205e96:	00003517          	auipc	a0,0x3
ffffffffc0205e9a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205e9e:	de2fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ea2:	00003617          	auipc	a2,0x3
ffffffffc0205ea6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0208720 <default_pmm_manager+0x13d8>
ffffffffc0205eaa:	39e00593          	li	a1,926
ffffffffc0205eae:	00003517          	auipc	a0,0x3
ffffffffc0205eb2:	95250513          	addi	a0,a0,-1710 # ffffffffc0208800 <default_pmm_manager+0x14b8>
ffffffffc0205eb6:	dcafa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205eba <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205eba:	1141                	addi	sp,sp,-16
ffffffffc0205ebc:	e022                	sd	s0,0(sp)
ffffffffc0205ebe:	e406                	sd	ra,8(sp)
ffffffffc0205ec0:	000a7417          	auipc	s0,0xa7
ffffffffc0205ec4:	99040413          	addi	s0,s0,-1648 # ffffffffc02ac850 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205ec8:	6018                	ld	a4,0(s0)
ffffffffc0205eca:	6f1c                	ld	a5,24(a4)
ffffffffc0205ecc:	dffd                	beqz	a5,ffffffffc0205eca <cpu_idle+0x10>
            schedule();
ffffffffc0205ece:	0ec000ef          	jal	ra,ffffffffc0205fba <schedule>
ffffffffc0205ed2:	bfdd                	j	ffffffffc0205ec8 <cpu_idle+0xe>

ffffffffc0205ed4 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205ed4:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205ed8:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205edc:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205ede:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205ee0:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205ee4:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205ee8:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205eec:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205ef0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205ef4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205ef8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205efc:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f00:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f04:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f08:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f0c:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f10:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f12:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f14:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f18:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f1c:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f20:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f24:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f28:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f2c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f30:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f34:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f38:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f3c:	8082                	ret

ffffffffc0205f3e <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f3e:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f40:	1101                	addi	sp,sp,-32
ffffffffc0205f42:	ec06                	sd	ra,24(sp)
ffffffffc0205f44:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f46:	478d                	li	a5,3
ffffffffc0205f48:	04f70a63          	beq	a4,a5,ffffffffc0205f9c <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f4c:	100027f3          	csrr	a5,sstatus
ffffffffc0205f50:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f52:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f54:	ef8d                	bnez	a5,ffffffffc0205f8e <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f56:	4789                	li	a5,2
ffffffffc0205f58:	00f70f63          	beq	a4,a5,ffffffffc0205f76 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f5c:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f5e:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f62:	e409                	bnez	s0,ffffffffc0205f6c <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f64:	60e2                	ld	ra,24(sp)
ffffffffc0205f66:	6442                	ld	s0,16(sp)
ffffffffc0205f68:	6105                	addi	sp,sp,32
ffffffffc0205f6a:	8082                	ret
ffffffffc0205f6c:	6442                	ld	s0,16(sp)
ffffffffc0205f6e:	60e2                	ld	ra,24(sp)
ffffffffc0205f70:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f72:	edafa06f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f76:	00003617          	auipc	a2,0x3
ffffffffc0205f7a:	8da60613          	addi	a2,a2,-1830 # ffffffffc0208850 <default_pmm_manager+0x1508>
ffffffffc0205f7e:	45c9                	li	a1,18
ffffffffc0205f80:	00003517          	auipc	a0,0x3
ffffffffc0205f84:	8b850513          	addi	a0,a0,-1864 # ffffffffc0208838 <default_pmm_manager+0x14f0>
ffffffffc0205f88:	d64fa0ef          	jal	ra,ffffffffc02004ec <__warn>
ffffffffc0205f8c:	bfd9                	j	ffffffffc0205f62 <wakeup_proc+0x24>
ffffffffc0205f8e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f90:	ec2fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205f94:	6522                	ld	a0,8(sp)
ffffffffc0205f96:	4405                	li	s0,1
ffffffffc0205f98:	4118                	lw	a4,0(a0)
ffffffffc0205f9a:	bf75                	j	ffffffffc0205f56 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f9c:	00003697          	auipc	a3,0x3
ffffffffc0205fa0:	87c68693          	addi	a3,a3,-1924 # ffffffffc0208818 <default_pmm_manager+0x14d0>
ffffffffc0205fa4:	00001617          	auipc	a2,0x1
ffffffffc0205fa8:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206c00 <commands+0x4d0>
ffffffffc0205fac:	45a5                	li	a1,9
ffffffffc0205fae:	00003517          	auipc	a0,0x3
ffffffffc0205fb2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0208838 <default_pmm_manager+0x14f0>
ffffffffc0205fb6:	ccafa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205fba <schedule>:

void
schedule(void) {
ffffffffc0205fba:	1141                	addi	sp,sp,-16
ffffffffc0205fbc:	e406                	sd	ra,8(sp)
ffffffffc0205fbe:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fc0:	100027f3          	csrr	a5,sstatus
ffffffffc0205fc4:	8b89                	andi	a5,a5,2
ffffffffc0205fc6:	4401                	li	s0,0
ffffffffc0205fc8:	e3d1                	bnez	a5,ffffffffc020604c <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fca:	000a7797          	auipc	a5,0xa7
ffffffffc0205fce:	88678793          	addi	a5,a5,-1914 # ffffffffc02ac850 <current>
ffffffffc0205fd2:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fd6:	000a7797          	auipc	a5,0xa7
ffffffffc0205fda:	88278793          	addi	a5,a5,-1918 # ffffffffc02ac858 <idleproc>
ffffffffc0205fde:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fe0:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fe4:	04a88e63          	beq	a7,a0,ffffffffc0206040 <schedule+0x86>
ffffffffc0205fe8:	0c888693          	addi	a3,a7,200
ffffffffc0205fec:	000a7617          	auipc	a2,0xa7
ffffffffc0205ff0:	9a460613          	addi	a2,a2,-1628 # ffffffffc02ac990 <proc_list>
        le = last;
ffffffffc0205ff4:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205ff6:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ff8:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205ffa:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ffc:	00c78863          	beq	a5,a2,ffffffffc020600c <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206000:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206004:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206008:	01070463          	beq	a4,a6,ffffffffc0206010 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc020600c:	fef697e3          	bne	a3,a5,ffffffffc0205ffa <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206010:	c589                	beqz	a1,ffffffffc020601a <schedule+0x60>
ffffffffc0206012:	4198                	lw	a4,0(a1)
ffffffffc0206014:	4789                	li	a5,2
ffffffffc0206016:	00f70e63          	beq	a4,a5,ffffffffc0206032 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020601a:	451c                	lw	a5,8(a0)
ffffffffc020601c:	2785                	addiw	a5,a5,1
ffffffffc020601e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206020:	00a88463          	beq	a7,a0,ffffffffc0206028 <schedule+0x6e>
            proc_run(next);
ffffffffc0206024:	ebbfe0ef          	jal	ra,ffffffffc0204ede <proc_run>
    if (flag) {
ffffffffc0206028:	e419                	bnez	s0,ffffffffc0206036 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020602a:	60a2                	ld	ra,8(sp)
ffffffffc020602c:	6402                	ld	s0,0(sp)
ffffffffc020602e:	0141                	addi	sp,sp,16
ffffffffc0206030:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206032:	852e                	mv	a0,a1
ffffffffc0206034:	b7dd                	j	ffffffffc020601a <schedule+0x60>
}
ffffffffc0206036:	6402                	ld	s0,0(sp)
ffffffffc0206038:	60a2                	ld	ra,8(sp)
ffffffffc020603a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020603c:	e10fa06f          	j	ffffffffc020064c <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206040:	000a7617          	auipc	a2,0xa7
ffffffffc0206044:	95060613          	addi	a2,a2,-1712 # ffffffffc02ac990 <proc_list>
ffffffffc0206048:	86b2                	mv	a3,a2
ffffffffc020604a:	b76d                	j	ffffffffc0205ff4 <schedule+0x3a>
        intr_disable();
ffffffffc020604c:	e06fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206050:	4405                	li	s0,1
ffffffffc0206052:	bfa5                	j	ffffffffc0205fca <schedule+0x10>

ffffffffc0206054 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206054:	000a6797          	auipc	a5,0xa6
ffffffffc0206058:	7fc78793          	addi	a5,a5,2044 # ffffffffc02ac850 <current>
ffffffffc020605c:	639c                	ld	a5,0(a5)
}
ffffffffc020605e:	43c8                	lw	a0,4(a5)
ffffffffc0206060:	8082                	ret

ffffffffc0206062 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206062:	4501                	li	a0,0
ffffffffc0206064:	8082                	ret

ffffffffc0206066 <sys_putc>:
    cputchar(c);
ffffffffc0206066:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206068:	1141                	addi	sp,sp,-16
ffffffffc020606a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020606c:	956fa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc0206070:	60a2                	ld	ra,8(sp)
ffffffffc0206072:	4501                	li	a0,0
ffffffffc0206074:	0141                	addi	sp,sp,16
ffffffffc0206076:	8082                	ret

ffffffffc0206078 <sys_kill>:
    return do_kill(pid);
ffffffffc0206078:	4108                	lw	a0,0(a0)
ffffffffc020607a:	cadff06f          	j	ffffffffc0205d26 <do_kill>

ffffffffc020607e <sys_yield>:
    return do_yield();
ffffffffc020607e:	c57ff06f          	j	ffffffffc0205cd4 <do_yield>

ffffffffc0206082 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206082:	6d14                	ld	a3,24(a0)
ffffffffc0206084:	6910                	ld	a2,16(a0)
ffffffffc0206086:	650c                	ld	a1,8(a0)
ffffffffc0206088:	6108                	ld	a0,0(a0)
ffffffffc020608a:	f50ff06f          	j	ffffffffc02057da <do_execve>

ffffffffc020608e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020608e:	650c                	ld	a1,8(a0)
ffffffffc0206090:	4108                	lw	a0,0(a0)
ffffffffc0206092:	c55ff06f          	j	ffffffffc0205ce6 <do_wait>

ffffffffc0206096 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206096:	000a6797          	auipc	a5,0xa6
ffffffffc020609a:	7ba78793          	addi	a5,a5,1978 # ffffffffc02ac850 <current>
ffffffffc020609e:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060a0:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060a2:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060a4:	6a0c                	ld	a1,16(a2)
ffffffffc02060a6:	f01fe06f          	j	ffffffffc0204fa6 <do_fork>

ffffffffc02060aa <sys_exit>:
    return do_exit(error_code);
ffffffffc02060aa:	4108                	lw	a0,0(a0)
ffffffffc02060ac:	b10ff06f          	j	ffffffffc02053bc <do_exit>

ffffffffc02060b0 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060b0:	715d                	addi	sp,sp,-80
ffffffffc02060b2:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060b4:	000a6497          	auipc	s1,0xa6
ffffffffc02060b8:	79c48493          	addi	s1,s1,1948 # ffffffffc02ac850 <current>
ffffffffc02060bc:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060be:	e0a2                	sd	s0,64(sp)
ffffffffc02060c0:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060c2:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060c4:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060c6:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060c8:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060cc:	0327ee63          	bltu	a5,s2,ffffffffc0206108 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060d0:	00391713          	slli	a4,s2,0x3
ffffffffc02060d4:	00002797          	auipc	a5,0x2
ffffffffc02060d8:	7e478793          	addi	a5,a5,2020 # ffffffffc02088b8 <syscalls>
ffffffffc02060dc:	97ba                	add	a5,a5,a4
ffffffffc02060de:	639c                	ld	a5,0(a5)
ffffffffc02060e0:	c785                	beqz	a5,ffffffffc0206108 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060e2:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060e4:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060e6:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060e8:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060ea:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060ec:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060ee:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060f0:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060f2:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060f4:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060f6:	0028                	addi	a0,sp,8
ffffffffc02060f8:	9782                	jalr	a5
ffffffffc02060fa:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060fc:	60a6                	ld	ra,72(sp)
ffffffffc02060fe:	6406                	ld	s0,64(sp)
ffffffffc0206100:	74e2                	ld	s1,56(sp)
ffffffffc0206102:	7942                	ld	s2,48(sp)
ffffffffc0206104:	6161                	addi	sp,sp,80
ffffffffc0206106:	8082                	ret
    print_trapframe(tf);
ffffffffc0206108:	8522                	mv	a0,s0
ffffffffc020610a:	f36fa0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020610e:	609c                	ld	a5,0(s1)
ffffffffc0206110:	86ca                	mv	a3,s2
ffffffffc0206112:	00002617          	auipc	a2,0x2
ffffffffc0206116:	75e60613          	addi	a2,a2,1886 # ffffffffc0208870 <default_pmm_manager+0x1528>
ffffffffc020611a:	43d8                	lw	a4,4(a5)
ffffffffc020611c:	06300593          	li	a1,99
ffffffffc0206120:	0b478793          	addi	a5,a5,180
ffffffffc0206124:	00002517          	auipc	a0,0x2
ffffffffc0206128:	77c50513          	addi	a0,a0,1916 # ffffffffc02088a0 <default_pmm_manager+0x1558>
ffffffffc020612c:	b54fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0206130 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206130:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206134:	2785                	addiw	a5,a5,1
ffffffffc0206136:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc020613a:	02000793          	li	a5,32
ffffffffc020613e:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206142:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206146:	8082                	ret

ffffffffc0206148 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206148:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020614c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020614e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206152:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206154:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206158:	f022                	sd	s0,32(sp)
ffffffffc020615a:	ec26                	sd	s1,24(sp)
ffffffffc020615c:	e84a                	sd	s2,16(sp)
ffffffffc020615e:	f406                	sd	ra,40(sp)
ffffffffc0206160:	e44e                	sd	s3,8(sp)
ffffffffc0206162:	84aa                	mv	s1,a0
ffffffffc0206164:	892e                	mv	s2,a1
ffffffffc0206166:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020616a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020616c:	03067e63          	bgeu	a2,a6,ffffffffc02061a8 <printnum+0x60>
ffffffffc0206170:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206172:	00805763          	blez	s0,ffffffffc0206180 <printnum+0x38>
ffffffffc0206176:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206178:	85ca                	mv	a1,s2
ffffffffc020617a:	854e                	mv	a0,s3
ffffffffc020617c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020617e:	fc65                	bnez	s0,ffffffffc0206176 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206180:	1a02                	slli	s4,s4,0x20
ffffffffc0206182:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206186:	00003797          	auipc	a5,0x3
ffffffffc020618a:	a5278793          	addi	a5,a5,-1454 # ffffffffc0208bd8 <error_string+0xc8>
ffffffffc020618e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206190:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206192:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206196:	70a2                	ld	ra,40(sp)
ffffffffc0206198:	69a2                	ld	s3,8(sp)
ffffffffc020619a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020619c:	85ca                	mv	a1,s2
ffffffffc020619e:	8326                	mv	t1,s1
}
ffffffffc02061a0:	6942                	ld	s2,16(sp)
ffffffffc02061a2:	64e2                	ld	s1,24(sp)
ffffffffc02061a4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061a6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02061a8:	03065633          	divu	a2,a2,a6
ffffffffc02061ac:	8722                	mv	a4,s0
ffffffffc02061ae:	f9bff0ef          	jal	ra,ffffffffc0206148 <printnum>
ffffffffc02061b2:	b7f9                	j	ffffffffc0206180 <printnum+0x38>

ffffffffc02061b4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02061b4:	7119                	addi	sp,sp,-128
ffffffffc02061b6:	f4a6                	sd	s1,104(sp)
ffffffffc02061b8:	f0ca                	sd	s2,96(sp)
ffffffffc02061ba:	e8d2                	sd	s4,80(sp)
ffffffffc02061bc:	e4d6                	sd	s5,72(sp)
ffffffffc02061be:	e0da                	sd	s6,64(sp)
ffffffffc02061c0:	fc5e                	sd	s7,56(sp)
ffffffffc02061c2:	f862                	sd	s8,48(sp)
ffffffffc02061c4:	f06a                	sd	s10,32(sp)
ffffffffc02061c6:	fc86                	sd	ra,120(sp)
ffffffffc02061c8:	f8a2                	sd	s0,112(sp)
ffffffffc02061ca:	ecce                	sd	s3,88(sp)
ffffffffc02061cc:	f466                	sd	s9,40(sp)
ffffffffc02061ce:	ec6e                	sd	s11,24(sp)
ffffffffc02061d0:	892a                	mv	s2,a0
ffffffffc02061d2:	84ae                	mv	s1,a1
ffffffffc02061d4:	8d32                	mv	s10,a2
ffffffffc02061d6:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02061d8:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061da:	00002a17          	auipc	s4,0x2
ffffffffc02061de:	7dea0a13          	addi	s4,s4,2014 # ffffffffc02089b8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02061e2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02061e6:	00003c17          	auipc	s8,0x3
ffffffffc02061ea:	92ac0c13          	addi	s8,s8,-1750 # ffffffffc0208b10 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061ee:	000d4503          	lbu	a0,0(s10)
ffffffffc02061f2:	02500793          	li	a5,37
ffffffffc02061f6:	001d0413          	addi	s0,s10,1
ffffffffc02061fa:	00f50e63          	beq	a0,a5,ffffffffc0206216 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02061fe:	c521                	beqz	a0,ffffffffc0206246 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206200:	02500993          	li	s3,37
ffffffffc0206204:	a011                	j	ffffffffc0206208 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206206:	c121                	beqz	a0,ffffffffc0206246 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206208:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020620a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020620c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020620e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206212:	ff351ae3          	bne	a0,s3,ffffffffc0206206 <vprintfmt+0x52>
ffffffffc0206216:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020621a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020621e:	4981                	li	s3,0
ffffffffc0206220:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206222:	5cfd                	li	s9,-1
ffffffffc0206224:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206226:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020622a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020622c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0206230:	0ff6f693          	andi	a3,a3,255
ffffffffc0206234:	00140d13          	addi	s10,s0,1
ffffffffc0206238:	1ed5ef63          	bltu	a1,a3,ffffffffc0206436 <vprintfmt+0x282>
ffffffffc020623c:	068a                	slli	a3,a3,0x2
ffffffffc020623e:	96d2                	add	a3,a3,s4
ffffffffc0206240:	4294                	lw	a3,0(a3)
ffffffffc0206242:	96d2                	add	a3,a3,s4
ffffffffc0206244:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206246:	70e6                	ld	ra,120(sp)
ffffffffc0206248:	7446                	ld	s0,112(sp)
ffffffffc020624a:	74a6                	ld	s1,104(sp)
ffffffffc020624c:	7906                	ld	s2,96(sp)
ffffffffc020624e:	69e6                	ld	s3,88(sp)
ffffffffc0206250:	6a46                	ld	s4,80(sp)
ffffffffc0206252:	6aa6                	ld	s5,72(sp)
ffffffffc0206254:	6b06                	ld	s6,64(sp)
ffffffffc0206256:	7be2                	ld	s7,56(sp)
ffffffffc0206258:	7c42                	ld	s8,48(sp)
ffffffffc020625a:	7ca2                	ld	s9,40(sp)
ffffffffc020625c:	7d02                	ld	s10,32(sp)
ffffffffc020625e:	6de2                	ld	s11,24(sp)
ffffffffc0206260:	6109                	addi	sp,sp,128
ffffffffc0206262:	8082                	ret
            padc = '-';
ffffffffc0206264:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206266:	00144603          	lbu	a2,1(s0)
ffffffffc020626a:	846a                	mv	s0,s10
ffffffffc020626c:	b7c1                	j	ffffffffc020622c <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020626e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206272:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206276:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206278:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020627a:	fa0dd9e3          	bgez	s11,ffffffffc020622c <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020627e:	8de6                	mv	s11,s9
ffffffffc0206280:	5cfd                	li	s9,-1
ffffffffc0206282:	b76d                	j	ffffffffc020622c <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206284:	fffdc693          	not	a3,s11
ffffffffc0206288:	96fd                	srai	a3,a3,0x3f
ffffffffc020628a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020628e:	00144603          	lbu	a2,1(s0)
ffffffffc0206292:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206294:	846a                	mv	s0,s10
ffffffffc0206296:	bf59                	j	ffffffffc020622c <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206298:	4705                	li	a4,1
ffffffffc020629a:	008a8593          	addi	a1,s5,8
ffffffffc020629e:	01074463          	blt	a4,a6,ffffffffc02062a6 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc02062a2:	22080863          	beqz	a6,ffffffffc02064d2 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc02062a6:	000ab603          	ld	a2,0(s5)
ffffffffc02062aa:	46c1                	li	a3,16
ffffffffc02062ac:	8aae                	mv	s5,a1
ffffffffc02062ae:	a291                	j	ffffffffc02063f2 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc02062b0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02062b4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02062ba:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02062be:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062c2:	fad56ce3          	bltu	a0,a3,ffffffffc020627a <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc02062c6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02062c8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02062cc:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02062d0:	0196873b          	addw	a4,a3,s9
ffffffffc02062d4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02062d8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02062dc:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02062e0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02062e4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062e8:	fcd57fe3          	bgeu	a0,a3,ffffffffc02062c6 <vprintfmt+0x112>
ffffffffc02062ec:	b779                	j	ffffffffc020627a <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02062ee:	000aa503          	lw	a0,0(s5)
ffffffffc02062f2:	85a6                	mv	a1,s1
ffffffffc02062f4:	0aa1                	addi	s5,s5,8
ffffffffc02062f6:	9902                	jalr	s2
            break;
ffffffffc02062f8:	bddd                	j	ffffffffc02061ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062fa:	4705                	li	a4,1
ffffffffc02062fc:	008a8993          	addi	s3,s5,8
ffffffffc0206300:	01074463          	blt	a4,a6,ffffffffc0206308 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0206304:	1c080463          	beqz	a6,ffffffffc02064cc <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0206308:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020630c:	1c044a63          	bltz	s0,ffffffffc02064e0 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0206310:	8622                	mv	a2,s0
ffffffffc0206312:	8ace                	mv	s5,s3
ffffffffc0206314:	46a9                	li	a3,10
ffffffffc0206316:	a8f1                	j	ffffffffc02063f2 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0206318:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020631c:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020631e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206320:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206324:	8fb5                	xor	a5,a5,a3
ffffffffc0206326:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020632a:	12d74963          	blt	a4,a3,ffffffffc020645c <vprintfmt+0x2a8>
ffffffffc020632e:	00369793          	slli	a5,a3,0x3
ffffffffc0206332:	97e2                	add	a5,a5,s8
ffffffffc0206334:	639c                	ld	a5,0(a5)
ffffffffc0206336:	12078363          	beqz	a5,ffffffffc020645c <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc020633a:	86be                	mv	a3,a5
ffffffffc020633c:	00000617          	auipc	a2,0x0
ffffffffc0206340:	2ec60613          	addi	a2,a2,748 # ffffffffc0206628 <etext+0x2c>
ffffffffc0206344:	85a6                	mv	a1,s1
ffffffffc0206346:	854a                	mv	a0,s2
ffffffffc0206348:	1cc000ef          	jal	ra,ffffffffc0206514 <printfmt>
ffffffffc020634c:	b54d                	j	ffffffffc02061ee <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020634e:	000ab603          	ld	a2,0(s5)
ffffffffc0206352:	0aa1                	addi	s5,s5,8
ffffffffc0206354:	1a060163          	beqz	a2,ffffffffc02064f6 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0206358:	00160413          	addi	s0,a2,1
ffffffffc020635c:	15b05763          	blez	s11,ffffffffc02064aa <vprintfmt+0x2f6>
ffffffffc0206360:	02d00593          	li	a1,45
ffffffffc0206364:	10b79d63          	bne	a5,a1,ffffffffc020647e <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206368:	00064783          	lbu	a5,0(a2)
ffffffffc020636c:	0007851b          	sext.w	a0,a5
ffffffffc0206370:	c905                	beqz	a0,ffffffffc02063a0 <vprintfmt+0x1ec>
ffffffffc0206372:	000cc563          	bltz	s9,ffffffffc020637c <vprintfmt+0x1c8>
ffffffffc0206376:	3cfd                	addiw	s9,s9,-1
ffffffffc0206378:	036c8263          	beq	s9,s6,ffffffffc020639c <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020637c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020637e:	14098f63          	beqz	s3,ffffffffc02064dc <vprintfmt+0x328>
ffffffffc0206382:	3781                	addiw	a5,a5,-32
ffffffffc0206384:	14fbfc63          	bgeu	s7,a5,ffffffffc02064dc <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206388:	03f00513          	li	a0,63
ffffffffc020638c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020638e:	0405                	addi	s0,s0,1
ffffffffc0206390:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206394:	3dfd                	addiw	s11,s11,-1
ffffffffc0206396:	0007851b          	sext.w	a0,a5
ffffffffc020639a:	fd61                	bnez	a0,ffffffffc0206372 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020639c:	e5b059e3          	blez	s11,ffffffffc02061ee <vprintfmt+0x3a>
ffffffffc02063a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063a2:	85a6                	mv	a1,s1
ffffffffc02063a4:	02000513          	li	a0,32
ffffffffc02063a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063aa:	e40d82e3          	beqz	s11,ffffffffc02061ee <vprintfmt+0x3a>
ffffffffc02063ae:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063b0:	85a6                	mv	a1,s1
ffffffffc02063b2:	02000513          	li	a0,32
ffffffffc02063b6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063b8:	fe0d94e3          	bnez	s11,ffffffffc02063a0 <vprintfmt+0x1ec>
ffffffffc02063bc:	bd0d                	j	ffffffffc02061ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063be:	4705                	li	a4,1
ffffffffc02063c0:	008a8593          	addi	a1,s5,8
ffffffffc02063c4:	01074463          	blt	a4,a6,ffffffffc02063cc <vprintfmt+0x218>
    else if (lflag) {
ffffffffc02063c8:	0e080863          	beqz	a6,ffffffffc02064b8 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc02063cc:	000ab603          	ld	a2,0(s5)
ffffffffc02063d0:	46a1                	li	a3,8
ffffffffc02063d2:	8aae                	mv	s5,a1
ffffffffc02063d4:	a839                	j	ffffffffc02063f2 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02063d6:	03000513          	li	a0,48
ffffffffc02063da:	85a6                	mv	a1,s1
ffffffffc02063dc:	e03e                	sd	a5,0(sp)
ffffffffc02063de:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063e0:	85a6                	mv	a1,s1
ffffffffc02063e2:	07800513          	li	a0,120
ffffffffc02063e6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063e8:	0aa1                	addi	s5,s5,8
ffffffffc02063ea:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02063ee:	6782                	ld	a5,0(sp)
ffffffffc02063f0:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063f2:	2781                	sext.w	a5,a5
ffffffffc02063f4:	876e                	mv	a4,s11
ffffffffc02063f6:	85a6                	mv	a1,s1
ffffffffc02063f8:	854a                	mv	a0,s2
ffffffffc02063fa:	d4fff0ef          	jal	ra,ffffffffc0206148 <printnum>
            break;
ffffffffc02063fe:	bbc5                	j	ffffffffc02061ee <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206400:	00144603          	lbu	a2,1(s0)
ffffffffc0206404:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206406:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206408:	b515                	j	ffffffffc020622c <vprintfmt+0x78>
            goto reswitch;
ffffffffc020640a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020640e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206410:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206412:	bd29                	j	ffffffffc020622c <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206414:	85a6                	mv	a1,s1
ffffffffc0206416:	02500513          	li	a0,37
ffffffffc020641a:	9902                	jalr	s2
            break;
ffffffffc020641c:	bbc9                	j	ffffffffc02061ee <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020641e:	4705                	li	a4,1
ffffffffc0206420:	008a8593          	addi	a1,s5,8
ffffffffc0206424:	01074463          	blt	a4,a6,ffffffffc020642c <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0206428:	08080d63          	beqz	a6,ffffffffc02064c2 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc020642c:	000ab603          	ld	a2,0(s5)
ffffffffc0206430:	46a9                	li	a3,10
ffffffffc0206432:	8aae                	mv	s5,a1
ffffffffc0206434:	bf7d                	j	ffffffffc02063f2 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0206436:	85a6                	mv	a1,s1
ffffffffc0206438:	02500513          	li	a0,37
ffffffffc020643c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020643e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206442:	02500793          	li	a5,37
ffffffffc0206446:	8d22                	mv	s10,s0
ffffffffc0206448:	daf703e3          	beq	a4,a5,ffffffffc02061ee <vprintfmt+0x3a>
ffffffffc020644c:	02500713          	li	a4,37
ffffffffc0206450:	1d7d                	addi	s10,s10,-1
ffffffffc0206452:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206456:	fee79de3          	bne	a5,a4,ffffffffc0206450 <vprintfmt+0x29c>
ffffffffc020645a:	bb51                	j	ffffffffc02061ee <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020645c:	00003617          	auipc	a2,0x3
ffffffffc0206460:	85c60613          	addi	a2,a2,-1956 # ffffffffc0208cb8 <error_string+0x1a8>
ffffffffc0206464:	85a6                	mv	a1,s1
ffffffffc0206466:	854a                	mv	a0,s2
ffffffffc0206468:	0ac000ef          	jal	ra,ffffffffc0206514 <printfmt>
ffffffffc020646c:	b349                	j	ffffffffc02061ee <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020646e:	00003617          	auipc	a2,0x3
ffffffffc0206472:	84260613          	addi	a2,a2,-1982 # ffffffffc0208cb0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206476:	00003417          	auipc	s0,0x3
ffffffffc020647a:	83b40413          	addi	s0,s0,-1989 # ffffffffc0208cb1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020647e:	8532                	mv	a0,a2
ffffffffc0206480:	85e6                	mv	a1,s9
ffffffffc0206482:	e032                	sd	a2,0(sp)
ffffffffc0206484:	e43e                	sd	a5,8(sp)
ffffffffc0206486:	0cc000ef          	jal	ra,ffffffffc0206552 <strnlen>
ffffffffc020648a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020648e:	6602                	ld	a2,0(sp)
ffffffffc0206490:	01b05d63          	blez	s11,ffffffffc02064aa <vprintfmt+0x2f6>
ffffffffc0206494:	67a2                	ld	a5,8(sp)
ffffffffc0206496:	2781                	sext.w	a5,a5
ffffffffc0206498:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020649a:	6522                	ld	a0,8(sp)
ffffffffc020649c:	85a6                	mv	a1,s1
ffffffffc020649e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064a0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02064a2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064a4:	6602                	ld	a2,0(sp)
ffffffffc02064a6:	fe0d9ae3          	bnez	s11,ffffffffc020649a <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064aa:	00064783          	lbu	a5,0(a2)
ffffffffc02064ae:	0007851b          	sext.w	a0,a5
ffffffffc02064b2:	ec0510e3          	bnez	a0,ffffffffc0206372 <vprintfmt+0x1be>
ffffffffc02064b6:	bb25                	j	ffffffffc02061ee <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc02064b8:	000ae603          	lwu	a2,0(s5)
ffffffffc02064bc:	46a1                	li	a3,8
ffffffffc02064be:	8aae                	mv	s5,a1
ffffffffc02064c0:	bf0d                	j	ffffffffc02063f2 <vprintfmt+0x23e>
ffffffffc02064c2:	000ae603          	lwu	a2,0(s5)
ffffffffc02064c6:	46a9                	li	a3,10
ffffffffc02064c8:	8aae                	mv	s5,a1
ffffffffc02064ca:	b725                	j	ffffffffc02063f2 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc02064cc:	000aa403          	lw	s0,0(s5)
ffffffffc02064d0:	bd35                	j	ffffffffc020630c <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02064d2:	000ae603          	lwu	a2,0(s5)
ffffffffc02064d6:	46c1                	li	a3,16
ffffffffc02064d8:	8aae                	mv	s5,a1
ffffffffc02064da:	bf21                	j	ffffffffc02063f2 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02064dc:	9902                	jalr	s2
ffffffffc02064de:	bd45                	j	ffffffffc020638e <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02064e0:	85a6                	mv	a1,s1
ffffffffc02064e2:	02d00513          	li	a0,45
ffffffffc02064e6:	e03e                	sd	a5,0(sp)
ffffffffc02064e8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02064ea:	8ace                	mv	s5,s3
ffffffffc02064ec:	40800633          	neg	a2,s0
ffffffffc02064f0:	46a9                	li	a3,10
ffffffffc02064f2:	6782                	ld	a5,0(sp)
ffffffffc02064f4:	bdfd                	j	ffffffffc02063f2 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02064f6:	01b05663          	blez	s11,ffffffffc0206502 <vprintfmt+0x34e>
ffffffffc02064fa:	02d00693          	li	a3,45
ffffffffc02064fe:	f6d798e3          	bne	a5,a3,ffffffffc020646e <vprintfmt+0x2ba>
ffffffffc0206502:	00002417          	auipc	s0,0x2
ffffffffc0206506:	7af40413          	addi	s0,s0,1967 # ffffffffc0208cb1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020650a:	02800513          	li	a0,40
ffffffffc020650e:	02800793          	li	a5,40
ffffffffc0206512:	b585                	j	ffffffffc0206372 <vprintfmt+0x1be>

ffffffffc0206514 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206514:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206516:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020651a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020651c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020651e:	ec06                	sd	ra,24(sp)
ffffffffc0206520:	f83a                	sd	a4,48(sp)
ffffffffc0206522:	fc3e                	sd	a5,56(sp)
ffffffffc0206524:	e0c2                	sd	a6,64(sp)
ffffffffc0206526:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206528:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020652a:	c8bff0ef          	jal	ra,ffffffffc02061b4 <vprintfmt>
}
ffffffffc020652e:	60e2                	ld	ra,24(sp)
ffffffffc0206530:	6161                	addi	sp,sp,80
ffffffffc0206532:	8082                	ret

ffffffffc0206534 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206534:	00054783          	lbu	a5,0(a0)
ffffffffc0206538:	cb91                	beqz	a5,ffffffffc020654c <strlen+0x18>
    size_t cnt = 0;
ffffffffc020653a:	4781                	li	a5,0
        cnt ++;
ffffffffc020653c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020653e:	00f50733          	add	a4,a0,a5
ffffffffc0206542:	00074703          	lbu	a4,0(a4)
ffffffffc0206546:	fb7d                	bnez	a4,ffffffffc020653c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206548:	853e                	mv	a0,a5
ffffffffc020654a:	8082                	ret
    size_t cnt = 0;
ffffffffc020654c:	4781                	li	a5,0
}
ffffffffc020654e:	853e                	mv	a0,a5
ffffffffc0206550:	8082                	ret

ffffffffc0206552 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206552:	c185                	beqz	a1,ffffffffc0206572 <strnlen+0x20>
ffffffffc0206554:	00054783          	lbu	a5,0(a0)
ffffffffc0206558:	cf89                	beqz	a5,ffffffffc0206572 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020655a:	4781                	li	a5,0
ffffffffc020655c:	a021                	j	ffffffffc0206564 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020655e:	00074703          	lbu	a4,0(a4)
ffffffffc0206562:	c711                	beqz	a4,ffffffffc020656e <strnlen+0x1c>
        cnt ++;
ffffffffc0206564:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206566:	00f50733          	add	a4,a0,a5
ffffffffc020656a:	fef59ae3          	bne	a1,a5,ffffffffc020655e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020656e:	853e                	mv	a0,a5
ffffffffc0206570:	8082                	ret
    size_t cnt = 0;
ffffffffc0206572:	4781                	li	a5,0
}
ffffffffc0206574:	853e                	mv	a0,a5
ffffffffc0206576:	8082                	ret

ffffffffc0206578 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206578:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020657a:	0585                	addi	a1,a1,1
ffffffffc020657c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206580:	0785                	addi	a5,a5,1
ffffffffc0206582:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206586:	fb75                	bnez	a4,ffffffffc020657a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206588:	8082                	ret

ffffffffc020658a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020658a:	00054783          	lbu	a5,0(a0)
ffffffffc020658e:	0005c703          	lbu	a4,0(a1)
ffffffffc0206592:	cb91                	beqz	a5,ffffffffc02065a6 <strcmp+0x1c>
ffffffffc0206594:	00e79c63          	bne	a5,a4,ffffffffc02065ac <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206598:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020659a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020659e:	0585                	addi	a1,a1,1
ffffffffc02065a0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065a4:	fbe5                	bnez	a5,ffffffffc0206594 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02065a6:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02065a8:	9d19                	subw	a0,a0,a4
ffffffffc02065aa:	8082                	ret
ffffffffc02065ac:	0007851b          	sext.w	a0,a5
ffffffffc02065b0:	9d19                	subw	a0,a0,a4
ffffffffc02065b2:	8082                	ret

ffffffffc02065b4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02065b4:	00054783          	lbu	a5,0(a0)
ffffffffc02065b8:	cb91                	beqz	a5,ffffffffc02065cc <strchr+0x18>
        if (*s == c) {
ffffffffc02065ba:	00b79563          	bne	a5,a1,ffffffffc02065c4 <strchr+0x10>
ffffffffc02065be:	a809                	j	ffffffffc02065d0 <strchr+0x1c>
ffffffffc02065c0:	00b78763          	beq	a5,a1,ffffffffc02065ce <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02065c4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02065c6:	00054783          	lbu	a5,0(a0)
ffffffffc02065ca:	fbfd                	bnez	a5,ffffffffc02065c0 <strchr+0xc>
    }
    return NULL;
ffffffffc02065cc:	4501                	li	a0,0
}
ffffffffc02065ce:	8082                	ret
ffffffffc02065d0:	8082                	ret

ffffffffc02065d2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02065d2:	ca01                	beqz	a2,ffffffffc02065e2 <memset+0x10>
ffffffffc02065d4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02065d6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02065d8:	0785                	addi	a5,a5,1
ffffffffc02065da:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02065de:	fec79de3          	bne	a5,a2,ffffffffc02065d8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02065e2:	8082                	ret

ffffffffc02065e4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02065e4:	ca19                	beqz	a2,ffffffffc02065fa <memcpy+0x16>
ffffffffc02065e6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02065e8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02065ea:	0585                	addi	a1,a1,1
ffffffffc02065ec:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02065f0:	0785                	addi	a5,a5,1
ffffffffc02065f2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02065f6:	fec59ae3          	bne	a1,a2,ffffffffc02065ea <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02065fa:	8082                	ret

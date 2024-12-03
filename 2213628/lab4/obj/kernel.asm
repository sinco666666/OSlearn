
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc0200028:	c020a137          	lui	sp,0xc020a

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
ffffffffc0200036:	0000b517          	auipc	a0,0xb
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020b060 <edata>
ffffffffc020003e:	00016617          	auipc	a2,0x16
ffffffffc0200042:	5ca60613          	addi	a2,a2,1482 # ffffffffc0216608 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	00a050ef          	jal	ra,ffffffffc0205058 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4ae000ef          	jal	ra,ffffffffc0200500 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	06258593          	addi	a1,a1,98 # ffffffffc02050b8 <etext+0x6>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	07a50513          	addi	a0,a0,122 # ffffffffc02050d8 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16a000ef          	jal	ra,ffffffffc02001d4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	056020ef          	jal	ra,ffffffffc02020c4 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	564000ef          	jal	ra,ffffffffc02005d6 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5d4000ef          	jal	ra,ffffffffc020064a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	2c9030ef          	jal	ra,ffffffffc0203b42 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	7f4040ef          	jal	ra,ffffffffc0204872 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f0000ef          	jal	ra,ffffffffc0200572 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	3b1020ef          	jal	ra,ffffffffc0202c36 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	422000ef          	jal	ra,ffffffffc02004ac <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	53c000ef          	jal	ra,ffffffffc02005ca <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	1d3040ef          	jal	ra,ffffffffc0204a64 <cpu_idle>

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
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	03250513          	addi	a0,a0,50 # ffffffffc02050e0 <etext+0x2e>
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
ffffffffc02000c4:	0000bb97          	auipc	s7,0xb
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020b060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f4000ef          	jal	ra,ffffffffc02001c4 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	bge	s4,s1,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e2000ef          	jal	ra,ffffffffc02001c4 <getchar>
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
ffffffffc02000f6:	0ce000ef          	jal	ra,ffffffffc02001c4 <getchar>
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
ffffffffc0200126:	0000b517          	auipc	a0,0xb
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020b060 <edata>
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
ffffffffc020015c:	3a6000ef          	jal	ra,ffffffffc0200502 <cons_putc>
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
ffffffffc0200182:	2b9040ef          	jal	ra,ffffffffc0204c3a <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	285040ef          	jal	ra,ffffffffc0204c3a <vprintfmt>
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
ffffffffc02001c2:	a681                	j	ffffffffc0200502 <cons_putc>

ffffffffc02001c4 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c4:	1141                	addi	sp,sp,-16
ffffffffc02001c6:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001c8:	36e000ef          	jal	ra,ffffffffc0200536 <cons_getc>
ffffffffc02001cc:	dd75                	beqz	a0,ffffffffc02001c8 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001ce:	60a2                	ld	ra,8(sp)
ffffffffc02001d0:	0141                	addi	sp,sp,16
ffffffffc02001d2:	8082                	ret

ffffffffc02001d4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d6:	00005517          	auipc	a0,0x5
ffffffffc02001da:	f4250513          	addi	a0,a0,-190 # ffffffffc0205118 <etext+0x66>
void print_kerninfo(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e0:	fafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e4:	00000597          	auipc	a1,0x0
ffffffffc02001e8:	e5258593          	addi	a1,a1,-430 # ffffffffc0200036 <kern_init>
ffffffffc02001ec:	00005517          	auipc	a0,0x5
ffffffffc02001f0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205138 <etext+0x86>
ffffffffc02001f4:	f9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001f8:	00005597          	auipc	a1,0x5
ffffffffc02001fc:	eba58593          	addi	a1,a1,-326 # ffffffffc02050b2 <etext>
ffffffffc0200200:	00005517          	auipc	a0,0x5
ffffffffc0200204:	f5850513          	addi	a0,a0,-168 # ffffffffc0205158 <etext+0xa6>
ffffffffc0200208:	f87ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020c:	0000b597          	auipc	a1,0xb
ffffffffc0200210:	e5458593          	addi	a1,a1,-428 # ffffffffc020b060 <edata>
ffffffffc0200214:	00005517          	auipc	a0,0x5
ffffffffc0200218:	f6450513          	addi	a0,a0,-156 # ffffffffc0205178 <etext+0xc6>
ffffffffc020021c:	f73ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200220:	00016597          	auipc	a1,0x16
ffffffffc0200224:	3e858593          	addi	a1,a1,1000 # ffffffffc0216608 <end>
ffffffffc0200228:	00005517          	auipc	a0,0x5
ffffffffc020022c:	f7050513          	addi	a0,a0,-144 # ffffffffc0205198 <etext+0xe6>
ffffffffc0200230:	f5fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200234:	00016597          	auipc	a1,0x16
ffffffffc0200238:	7d358593          	addi	a1,a1,2003 # ffffffffc0216a07 <end+0x3ff>
ffffffffc020023c:	00000797          	auipc	a5,0x0
ffffffffc0200240:	dfa78793          	addi	a5,a5,-518 # ffffffffc0200036 <kern_init>
ffffffffc0200244:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200248:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200252:	95be                	add	a1,a1,a5
ffffffffc0200254:	85a9                	srai	a1,a1,0xa
ffffffffc0200256:	00005517          	auipc	a0,0x5
ffffffffc020025a:	f6250513          	addi	a0,a0,-158 # ffffffffc02051b8 <etext+0x106>
}
ffffffffc020025e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200260:	b73d                	j	ffffffffc020018e <cprintf>

ffffffffc0200262 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200262:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200264:	00005617          	auipc	a2,0x5
ffffffffc0200268:	e8460613          	addi	a2,a2,-380 # ffffffffc02050e8 <etext+0x36>
ffffffffc020026c:	04d00593          	li	a1,77
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	e9050513          	addi	a0,a0,-368 # ffffffffc0205100 <etext+0x4e>
void print_stackframe(void) {
ffffffffc0200278:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027a:	1d2000ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020027e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020027e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200280:	00005617          	auipc	a2,0x5
ffffffffc0200284:	04860613          	addi	a2,a2,72 # ffffffffc02052c8 <commands+0xe0>
ffffffffc0200288:	00005597          	auipc	a1,0x5
ffffffffc020028c:	06058593          	addi	a1,a1,96 # ffffffffc02052e8 <commands+0x100>
ffffffffc0200290:	00005517          	auipc	a0,0x5
ffffffffc0200294:	06050513          	addi	a0,a0,96 # ffffffffc02052f0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200298:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029a:	ef5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020029e:	00005617          	auipc	a2,0x5
ffffffffc02002a2:	06260613          	addi	a2,a2,98 # ffffffffc0205300 <commands+0x118>
ffffffffc02002a6:	00005597          	auipc	a1,0x5
ffffffffc02002aa:	08258593          	addi	a1,a1,130 # ffffffffc0205328 <commands+0x140>
ffffffffc02002ae:	00005517          	auipc	a0,0x5
ffffffffc02002b2:	04250513          	addi	a0,a0,66 # ffffffffc02052f0 <commands+0x108>
ffffffffc02002b6:	ed9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002ba:	00005617          	auipc	a2,0x5
ffffffffc02002be:	07e60613          	addi	a2,a2,126 # ffffffffc0205338 <commands+0x150>
ffffffffc02002c2:	00005597          	auipc	a1,0x5
ffffffffc02002c6:	09658593          	addi	a1,a1,150 # ffffffffc0205358 <commands+0x170>
ffffffffc02002ca:	00005517          	auipc	a0,0x5
ffffffffc02002ce:	02650513          	addi	a0,a0,38 # ffffffffc02052f0 <commands+0x108>
ffffffffc02002d2:	ebdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002d6:	60a2                	ld	ra,8(sp)
ffffffffc02002d8:	4501                	li	a0,0
ffffffffc02002da:	0141                	addi	sp,sp,16
ffffffffc02002dc:	8082                	ret

ffffffffc02002de <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002de:	1141                	addi	sp,sp,-16
ffffffffc02002e0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e2:	ef3ff0ef          	jal	ra,ffffffffc02001d4 <print_kerninfo>
    return 0;
}
ffffffffc02002e6:	60a2                	ld	ra,8(sp)
ffffffffc02002e8:	4501                	li	a0,0
ffffffffc02002ea:	0141                	addi	sp,sp,16
ffffffffc02002ec:	8082                	ret

ffffffffc02002ee <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ee:	1141                	addi	sp,sp,-16
ffffffffc02002f0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f2:	f71ff0ef          	jal	ra,ffffffffc0200262 <print_stackframe>
    return 0;
}
ffffffffc02002f6:	60a2                	ld	ra,8(sp)
ffffffffc02002f8:	4501                	li	a0,0
ffffffffc02002fa:	0141                	addi	sp,sp,16
ffffffffc02002fc:	8082                	ret

ffffffffc02002fe <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002fe:	7115                	addi	sp,sp,-224
ffffffffc0200300:	e962                	sd	s8,144(sp)
ffffffffc0200302:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200304:	00005517          	auipc	a0,0x5
ffffffffc0200308:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205230 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020030c:	ed86                	sd	ra,216(sp)
ffffffffc020030e:	e9a2                	sd	s0,208(sp)
ffffffffc0200310:	e5a6                	sd	s1,200(sp)
ffffffffc0200312:	e1ca                	sd	s2,192(sp)
ffffffffc0200314:	fd4e                	sd	s3,184(sp)
ffffffffc0200316:	f952                	sd	s4,176(sp)
ffffffffc0200318:	f556                	sd	s5,168(sp)
ffffffffc020031a:	f15a                	sd	s6,160(sp)
ffffffffc020031c:	ed5e                	sd	s7,152(sp)
ffffffffc020031e:	e566                	sd	s9,136(sp)
ffffffffc0200320:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200322:	e6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200326:	00005517          	auipc	a0,0x5
ffffffffc020032a:	f3250513          	addi	a0,a0,-206 # ffffffffc0205258 <commands+0x70>
ffffffffc020032e:	e61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200332:	000c0563          	beqz	s8,ffffffffc020033c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200336:	8562                	mv	a0,s8
ffffffffc0200338:	4f8000ef          	jal	ra,ffffffffc0200830 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	4581                	li	a1,0
ffffffffc0200340:	4601                	li	a2,0
ffffffffc0200342:	48a1                	li	a7,8
ffffffffc0200344:	00000073          	ecall
ffffffffc0200348:	00005c97          	auipc	s9,0x5
ffffffffc020034c:	ea0c8c93          	addi	s9,s9,-352 # ffffffffc02051e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200350:	00005997          	auipc	s3,0x5
ffffffffc0200354:	f3098993          	addi	s3,s3,-208 # ffffffffc0205280 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	00005917          	auipc	s2,0x5
ffffffffc020035c:	f3090913          	addi	s2,s2,-208 # ffffffffc0205288 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200362:	00005b17          	auipc	s6,0x5
ffffffffc0200366:	f2eb0b13          	addi	s6,s6,-210 # ffffffffc0205290 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036a:	00005a97          	auipc	s5,0x5
ffffffffc020036e:	f7ea8a93          	addi	s5,s5,-130 # ffffffffc02052e8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200374:	854e                	mv	a0,s3
ffffffffc0200376:	d21ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037a:	842a                	mv	s0,a0
ffffffffc020037c:	dd65                	beqz	a0,ffffffffc0200374 <kmonitor+0x76>
ffffffffc020037e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200382:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200384:	c999                	beqz	a1,ffffffffc020039a <kmonitor+0x9c>
ffffffffc0200386:	854a                	mv	a0,s2
ffffffffc0200388:	4b3040ef          	jal	ra,ffffffffc020503a <strchr>
ffffffffc020038c:	c925                	beqz	a0,ffffffffc02003fc <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc020038e:	00144583          	lbu	a1,1(s0)
ffffffffc0200392:	00040023          	sb	zero,0(s0)
ffffffffc0200396:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200398:	f5fd                	bnez	a1,ffffffffc0200386 <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039a:	dce9                	beqz	s1,ffffffffc0200374 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00005d17          	auipc	s10,0x5
ffffffffc02003a2:	e4ad0d13          	addi	s10,s10,-438 # ffffffffc02051e8 <commands>
    if (argc == 0) {
ffffffffc02003a6:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a8:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003aa:	0d61                	addi	s10,s10,24
ffffffffc02003ac:	465040ef          	jal	ra,ffffffffc0205010 <strcmp>
ffffffffc02003b0:	c919                	beqz	a0,ffffffffc02003c6 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b2:	2405                	addiw	s0,s0,1
ffffffffc02003b4:	09740463          	beq	s0,s7,ffffffffc020043c <kmonitor+0x13e>
ffffffffc02003b8:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003bc:	6582                	ld	a1,0(sp)
ffffffffc02003be:	0d61                	addi	s10,s10,24
ffffffffc02003c0:	451040ef          	jal	ra,ffffffffc0205010 <strcmp>
ffffffffc02003c4:	f57d                	bnez	a0,ffffffffc02003b2 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003c6:	00141793          	slli	a5,s0,0x1
ffffffffc02003ca:	97a2                	add	a5,a5,s0
ffffffffc02003cc:	078e                	slli	a5,a5,0x3
ffffffffc02003ce:	97e6                	add	a5,a5,s9
ffffffffc02003d0:	6b9c                	ld	a5,16(a5)
ffffffffc02003d2:	8662                	mv	a2,s8
ffffffffc02003d4:	002c                	addi	a1,sp,8
ffffffffc02003d6:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003da:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003dc:	f8055ce3          	bgez	a0,ffffffffc0200374 <kmonitor+0x76>
}
ffffffffc02003e0:	60ee                	ld	ra,216(sp)
ffffffffc02003e2:	644e                	ld	s0,208(sp)
ffffffffc02003e4:	64ae                	ld	s1,200(sp)
ffffffffc02003e6:	690e                	ld	s2,192(sp)
ffffffffc02003e8:	79ea                	ld	s3,184(sp)
ffffffffc02003ea:	7a4a                	ld	s4,176(sp)
ffffffffc02003ec:	7aaa                	ld	s5,168(sp)
ffffffffc02003ee:	7b0a                	ld	s6,160(sp)
ffffffffc02003f0:	6bea                	ld	s7,152(sp)
ffffffffc02003f2:	6c4a                	ld	s8,144(sp)
ffffffffc02003f4:	6caa                	ld	s9,136(sp)
ffffffffc02003f6:	6d0a                	ld	s10,128(sp)
ffffffffc02003f8:	612d                	addi	sp,sp,224
ffffffffc02003fa:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003fc:	00044783          	lbu	a5,0(s0)
ffffffffc0200400:	dfc9                	beqz	a5,ffffffffc020039a <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200402:	03448863          	beq	s1,s4,ffffffffc0200432 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc0200406:	00349793          	slli	a5,s1,0x3
ffffffffc020040a:	0118                	addi	a4,sp,128
ffffffffc020040c:	97ba                	add	a5,a5,a4
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200416:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0x126>
ffffffffc020041a:	b749                	j	ffffffffc020039c <kmonitor+0x9e>
            buf ++;
ffffffffc020041c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041e:	00044583          	lbu	a1,0(s0)
ffffffffc0200422:	ddad                	beqz	a1,ffffffffc020039c <kmonitor+0x9e>
ffffffffc0200424:	854a                	mv	a0,s2
ffffffffc0200426:	415040ef          	jal	ra,ffffffffc020503a <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0x11e>
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	bf91                	j	ffffffffc0200384 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200432:	45c1                	li	a1,16
ffffffffc0200434:	855a                	mv	a0,s6
ffffffffc0200436:	d59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043a:	b7f1                	j	ffffffffc0200406 <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020043c:	6582                	ld	a1,0(sp)
ffffffffc020043e:	00005517          	auipc	a0,0x5
ffffffffc0200442:	e7250513          	addi	a0,a0,-398 # ffffffffc02052b0 <commands+0xc8>
ffffffffc0200446:	d49ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044a:	b72d                	j	ffffffffc0200374 <kmonitor+0x76>

ffffffffc020044c <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020044c:	00016317          	auipc	t1,0x16
ffffffffc0200450:	02430313          	addi	t1,t1,36 # ffffffffc0216470 <is_panic>
ffffffffc0200454:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200458:	715d                	addi	sp,sp,-80
ffffffffc020045a:	ec06                	sd	ra,24(sp)
ffffffffc020045c:	e822                	sd	s0,16(sp)
ffffffffc020045e:	f436                	sd	a3,40(sp)
ffffffffc0200460:	f83a                	sd	a4,48(sp)
ffffffffc0200462:	fc3e                	sd	a5,56(sp)
ffffffffc0200464:	e0c2                	sd	a6,64(sp)
ffffffffc0200466:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200468:	02031c63          	bnez	t1,ffffffffc02004a0 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020046c:	4785                	li	a5,1
ffffffffc020046e:	8432                	mv	s0,a2
ffffffffc0200470:	00016717          	auipc	a4,0x16
ffffffffc0200474:	00f72023          	sw	a5,0(a4) # ffffffffc0216470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200478:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	85aa                	mv	a1,a0
ffffffffc020047e:	00005517          	auipc	a0,0x5
ffffffffc0200482:	eea50513          	addi	a0,a0,-278 # ffffffffc0205368 <commands+0x180>
    va_start(ap, fmt);
ffffffffc0200486:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200488:	d07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc020048c:	65a2                	ld	a1,8(sp)
ffffffffc020048e:	8522                	mv	a0,s0
ffffffffc0200490:	cdfff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200494:	00006517          	auipc	a0,0x6
ffffffffc0200498:	ec450513          	addi	a0,a0,-316 # ffffffffc0206358 <default_pmm_manager+0x500>
ffffffffc020049c:	cf3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a0:	130000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a4:	4501                	li	a0,0
ffffffffc02004a6:	e59ff0ef          	jal	ra,ffffffffc02002fe <kmonitor>
ffffffffc02004aa:	bfed                	j	ffffffffc02004a4 <__panic+0x58>

ffffffffc02004ac <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004ac:	67e1                	lui	a5,0x18
ffffffffc02004ae:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b2:	00016717          	auipc	a4,0x16
ffffffffc02004b6:	fcf73323          	sd	a5,-58(a4) # ffffffffc0216478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ba:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004be:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c0:	953e                	add	a0,a0,a5
ffffffffc02004c2:	4601                	li	a2,0
ffffffffc02004c4:	4881                	li	a7,0
ffffffffc02004c6:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ca:	02000793          	li	a5,32
ffffffffc02004ce:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d2:	00005517          	auipc	a0,0x5
ffffffffc02004d6:	eb650513          	addi	a0,a0,-330 # ffffffffc0205388 <commands+0x1a0>
    ticks = 0;
ffffffffc02004da:	00016797          	auipc	a5,0x16
ffffffffc02004de:	fe07bf23          	sd	zero,-2(a5) # ffffffffc02164d8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e2:	b175                	j	ffffffffc020018e <cprintf>

ffffffffc02004e4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004e4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004e8:	00016797          	auipc	a5,0x16
ffffffffc02004ec:	f9078793          	addi	a5,a5,-112 # ffffffffc0216478 <timebase>
ffffffffc02004f0:	639c                	ld	a5,0(a5)
ffffffffc02004f2:	4581                	li	a1,0
ffffffffc02004f4:	4601                	li	a2,0
ffffffffc02004f6:	953e                	add	a0,a0,a5
ffffffffc02004f8:	4881                	li	a7,0
ffffffffc02004fa:	00000073          	ecall
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200500:	8082                	ret

ffffffffc0200502 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200502:	100027f3          	csrr	a5,sstatus
ffffffffc0200506:	8b89                	andi	a5,a5,2
ffffffffc0200508:	0ff57513          	andi	a0,a0,255
ffffffffc020050c:	e799                	bnez	a5,ffffffffc020051a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020050e:	4581                	li	a1,0
ffffffffc0200510:	4601                	li	a2,0
ffffffffc0200512:	4885                	li	a7,1
ffffffffc0200514:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200518:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020051a:	1101                	addi	sp,sp,-32
ffffffffc020051c:	ec06                	sd	ra,24(sp)
ffffffffc020051e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200520:	0b0000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0200524:	6522                	ld	a0,8(sp)
ffffffffc0200526:	4581                	li	a1,0
ffffffffc0200528:	4601                	li	a2,0
ffffffffc020052a:	4885                	li	a7,1
ffffffffc020052c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200530:	60e2                	ld	ra,24(sp)
ffffffffc0200532:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200534:	a859                	j	ffffffffc02005ca <intr_enable>

ffffffffc0200536 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200536:	100027f3          	csrr	a5,sstatus
ffffffffc020053a:	8b89                	andi	a5,a5,2
ffffffffc020053c:	eb89                	bnez	a5,ffffffffc020054e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020053e:	4501                	li	a0,0
ffffffffc0200540:	4581                	li	a1,0
ffffffffc0200542:	4601                	li	a2,0
ffffffffc0200544:	4889                	li	a7,2
ffffffffc0200546:	00000073          	ecall
ffffffffc020054a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020054c:	8082                	ret
int cons_getc(void) {
ffffffffc020054e:	1101                	addi	sp,sp,-32
ffffffffc0200550:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200552:	07e000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0200556:	4501                	li	a0,0
ffffffffc0200558:	4581                	li	a1,0
ffffffffc020055a:	4601                	li	a2,0
ffffffffc020055c:	4889                	li	a7,2
ffffffffc020055e:	00000073          	ecall
ffffffffc0200562:	2501                	sext.w	a0,a0
ffffffffc0200564:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200566:	064000ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc020056a:	60e2                	ld	ra,24(sp)
ffffffffc020056c:	6522                	ld	a0,8(sp)
ffffffffc020056e:	6105                	addi	sp,sp,32
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200574:	00253513          	sltiu	a0,a0,2
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020057a:	03800513          	li	a0,56
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200580:	0000b797          	auipc	a5,0xb
ffffffffc0200584:	ee078793          	addi	a5,a5,-288 # ffffffffc020b460 <ide>
ffffffffc0200588:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020058c:	1141                	addi	sp,sp,-16
ffffffffc020058e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200590:	95be                	add	a1,a1,a5
ffffffffc0200592:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200596:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	2d3040ef          	jal	ra,ffffffffc020506a <memcpy>
    return 0;
}
ffffffffc020059c:	60a2                	ld	ra,8(sp)
ffffffffc020059e:	4501                	li	a0,0
ffffffffc02005a0:	0141                	addi	sp,sp,16
ffffffffc02005a2:	8082                	ret

ffffffffc02005a4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005a4:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a6:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005aa:	0000b517          	auipc	a0,0xb
ffffffffc02005ae:	eb650513          	addi	a0,a0,-330 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005b2:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b4:	00969613          	slli	a2,a3,0x9
ffffffffc02005b8:	85ba                	mv	a1,a4
ffffffffc02005ba:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005bc:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005be:	2ad040ef          	jal	ra,ffffffffc020506a <memcpy>
    return 0;
}
ffffffffc02005c2:	60a2                	ld	ra,8(sp)
ffffffffc02005c4:	4501                	li	a0,0
ffffffffc02005c6:	0141                	addi	sp,sp,16
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ca:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005d4:	8082                	ret

ffffffffc02005d6 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d8:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	1141                	addi	sp,sp,-16
ffffffffc02005de:	e022                	sd	s0,0(sp)
ffffffffc02005e0:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e2:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e6:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005e8:	11053583          	ld	a1,272(a0)
ffffffffc02005ec:	05500613          	li	a2,85
ffffffffc02005f0:	c399                	beqz	a5,ffffffffc02005f6 <pgfault_handler+0x1e>
ffffffffc02005f2:	04b00613          	li	a2,75
ffffffffc02005f6:	11843703          	ld	a4,280(s0)
ffffffffc02005fa:	47bd                	li	a5,15
ffffffffc02005fc:	05700693          	li	a3,87
ffffffffc0200600:	00f70463          	beq	a4,a5,ffffffffc0200608 <pgfault_handler+0x30>
ffffffffc0200604:	05200693          	li	a3,82
ffffffffc0200608:	00005517          	auipc	a0,0x5
ffffffffc020060c:	0d850513          	addi	a0,a0,216 # ffffffffc02056e0 <commands+0x4f8>
ffffffffc0200610:	b7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200614:	00016797          	auipc	a5,0x16
ffffffffc0200618:	fdc78793          	addi	a5,a5,-36 # ffffffffc02165f0 <check_mm_struct>
ffffffffc020061c:	6388                	ld	a0,0(a5)
ffffffffc020061e:	c911                	beqz	a0,ffffffffc0200632 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200620:	11043603          	ld	a2,272(s0)
ffffffffc0200624:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200628:	6402                	ld	s0,0(sp)
ffffffffc020062a:	60a2                	ld	ra,8(sp)
ffffffffc020062c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020062e:	27b0306f          	j	ffffffffc02040a8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200632:	00005617          	auipc	a2,0x5
ffffffffc0200636:	0ce60613          	addi	a2,a2,206 # ffffffffc0205700 <commands+0x518>
ffffffffc020063a:	06400593          	li	a1,100
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	0da50513          	addi	a0,a0,218 # ffffffffc0205718 <commands+0x530>
ffffffffc0200646:	e07ff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020064a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020064a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020064e:	00000797          	auipc	a5,0x0
ffffffffc0200652:	4e678793          	addi	a5,a5,1254 # ffffffffc0200b34 <__alltraps>
ffffffffc0200656:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065a:	000407b7          	lui	a5,0x40
ffffffffc020065e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200662:	8082                	ret

ffffffffc0200664 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200664:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200666:	1141                	addi	sp,sp,-16
ffffffffc0200668:	e022                	sd	s0,0(sp)
ffffffffc020066a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	0c450513          	addi	a0,a0,196 # ffffffffc0205730 <commands+0x548>
void print_regs(struct pushregs *gpr) {
ffffffffc0200674:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200676:	b19ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067a:	640c                	ld	a1,8(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	0cc50513          	addi	a0,a0,204 # ffffffffc0205748 <commands+0x560>
ffffffffc0200684:	b0bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200688:	680c                	ld	a1,16(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	0d650513          	addi	a0,a0,214 # ffffffffc0205760 <commands+0x578>
ffffffffc0200692:	afdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200696:	6c0c                	ld	a1,24(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	0e050513          	addi	a0,a0,224 # ffffffffc0205778 <commands+0x590>
ffffffffc02006a0:	aefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a4:	700c                	ld	a1,32(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	0ea50513          	addi	a0,a0,234 # ffffffffc0205790 <commands+0x5a8>
ffffffffc02006ae:	ae1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b2:	740c                	ld	a1,40(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	0f450513          	addi	a0,a0,244 # ffffffffc02057a8 <commands+0x5c0>
ffffffffc02006bc:	ad3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c0:	780c                	ld	a1,48(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	0fe50513          	addi	a0,a0,254 # ffffffffc02057c0 <commands+0x5d8>
ffffffffc02006ca:	ac5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ce:	7c0c                	ld	a1,56(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	10850513          	addi	a0,a0,264 # ffffffffc02057d8 <commands+0x5f0>
ffffffffc02006d8:	ab7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006dc:	602c                	ld	a1,64(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	11250513          	addi	a0,a0,274 # ffffffffc02057f0 <commands+0x608>
ffffffffc02006e6:	aa9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ea:	642c                	ld	a1,72(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	11c50513          	addi	a0,a0,284 # ffffffffc0205808 <commands+0x620>
ffffffffc02006f4:	a9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f8:	682c                	ld	a1,80(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	12650513          	addi	a0,a0,294 # ffffffffc0205820 <commands+0x638>
ffffffffc0200702:	a8dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200706:	6c2c                	ld	a1,88(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	13050513          	addi	a0,a0,304 # ffffffffc0205838 <commands+0x650>
ffffffffc0200710:	a7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200714:	702c                	ld	a1,96(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	13a50513          	addi	a0,a0,314 # ffffffffc0205850 <commands+0x668>
ffffffffc020071e:	a71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200722:	742c                	ld	a1,104(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	14450513          	addi	a0,a0,324 # ffffffffc0205868 <commands+0x680>
ffffffffc020072c:	a63ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200730:	782c                	ld	a1,112(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	14e50513          	addi	a0,a0,334 # ffffffffc0205880 <commands+0x698>
ffffffffc020073a:	a55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073e:	7c2c                	ld	a1,120(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	15850513          	addi	a0,a0,344 # ffffffffc0205898 <commands+0x6b0>
ffffffffc0200748:	a47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074c:	604c                	ld	a1,128(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	16250513          	addi	a0,a0,354 # ffffffffc02058b0 <commands+0x6c8>
ffffffffc0200756:	a39ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075a:	644c                	ld	a1,136(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	16c50513          	addi	a0,a0,364 # ffffffffc02058c8 <commands+0x6e0>
ffffffffc0200764:	a2bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200768:	684c                	ld	a1,144(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	17650513          	addi	a0,a0,374 # ffffffffc02058e0 <commands+0x6f8>
ffffffffc0200772:	a1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200776:	6c4c                	ld	a1,152(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	18050513          	addi	a0,a0,384 # ffffffffc02058f8 <commands+0x710>
ffffffffc0200780:	a0fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200784:	704c                	ld	a1,160(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	18a50513          	addi	a0,a0,394 # ffffffffc0205910 <commands+0x728>
ffffffffc020078e:	a01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200792:	744c                	ld	a1,168(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	19450513          	addi	a0,a0,404 # ffffffffc0205928 <commands+0x740>
ffffffffc020079c:	9f3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a0:	784c                	ld	a1,176(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	19e50513          	addi	a0,a0,414 # ffffffffc0205940 <commands+0x758>
ffffffffc02007aa:	9e5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ae:	7c4c                	ld	a1,184(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	1a850513          	addi	a0,a0,424 # ffffffffc0205958 <commands+0x770>
ffffffffc02007b8:	9d7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007bc:	606c                	ld	a1,192(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	1b250513          	addi	a0,a0,434 # ffffffffc0205970 <commands+0x788>
ffffffffc02007c6:	9c9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ca:	646c                	ld	a1,200(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	1bc50513          	addi	a0,a0,444 # ffffffffc0205988 <commands+0x7a0>
ffffffffc02007d4:	9bbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d8:	686c                	ld	a1,208(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	1c650513          	addi	a0,a0,454 # ffffffffc02059a0 <commands+0x7b8>
ffffffffc02007e2:	9adff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e6:	6c6c                	ld	a1,216(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	1d050513          	addi	a0,a0,464 # ffffffffc02059b8 <commands+0x7d0>
ffffffffc02007f0:	99fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f4:	706c                	ld	a1,224(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	1da50513          	addi	a0,a0,474 # ffffffffc02059d0 <commands+0x7e8>
ffffffffc02007fe:	991ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200802:	746c                	ld	a1,232(s0)
ffffffffc0200804:	00005517          	auipc	a0,0x5
ffffffffc0200808:	1e450513          	addi	a0,a0,484 # ffffffffc02059e8 <commands+0x800>
ffffffffc020080c:	983ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200810:	786c                	ld	a1,240(s0)
ffffffffc0200812:	00005517          	auipc	a0,0x5
ffffffffc0200816:	1ee50513          	addi	a0,a0,494 # ffffffffc0205a00 <commands+0x818>
ffffffffc020081a:	975ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200820:	6402                	ld	s0,0(sp)
ffffffffc0200822:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200824:	00005517          	auipc	a0,0x5
ffffffffc0200828:	1f450513          	addi	a0,a0,500 # ffffffffc0205a18 <commands+0x830>
}
ffffffffc020082c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	b285                	j	ffffffffc020018e <cprintf>

ffffffffc0200830 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	1141                	addi	sp,sp,-16
ffffffffc0200832:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	00005517          	auipc	a0,0x5
ffffffffc020083c:	1f850513          	addi	a0,a0,504 # ffffffffc0205a30 <commands+0x848>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	94dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200846:	8522                	mv	a0,s0
ffffffffc0200848:	e1dff0ef          	jal	ra,ffffffffc0200664 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084c:	10043583          	ld	a1,256(s0)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	1f850513          	addi	a0,a0,504 # ffffffffc0205a48 <commands+0x860>
ffffffffc0200858:	937ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085c:	10843583          	ld	a1,264(s0)
ffffffffc0200860:	00005517          	auipc	a0,0x5
ffffffffc0200864:	20050513          	addi	a0,a0,512 # ffffffffc0205a60 <commands+0x878>
ffffffffc0200868:	927ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020086c:	11043583          	ld	a1,272(s0)
ffffffffc0200870:	00005517          	auipc	a0,0x5
ffffffffc0200874:	20850513          	addi	a0,a0,520 # ffffffffc0205a78 <commands+0x890>
ffffffffc0200878:	917ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200880:	6402                	ld	s0,0(sp)
ffffffffc0200882:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	00005517          	auipc	a0,0x5
ffffffffc0200888:	20c50513          	addi	a0,a0,524 # ffffffffc0205a90 <commands+0x8a8>
}
ffffffffc020088c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	901ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200892 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200892:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200896:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200898:	0786                	slli	a5,a5,0x1
ffffffffc020089a:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020089c:	08f76f63          	bltu	a4,a5,ffffffffc020093a <interrupt_handler+0xa8>
ffffffffc02008a0:	00005717          	auipc	a4,0x5
ffffffffc02008a4:	b0470713          	addi	a4,a4,-1276 # ffffffffc02053a4 <commands+0x1bc>
ffffffffc02008a8:	078a                	slli	a5,a5,0x2
ffffffffc02008aa:	97ba                	add	a5,a5,a4
ffffffffc02008ac:	439c                	lw	a5,0(a5)
ffffffffc02008ae:	97ba                	add	a5,a5,a4
ffffffffc02008b0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	dde50513          	addi	a0,a0,-546 # ffffffffc0205690 <commands+0x4a8>
ffffffffc02008ba:	8d5ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	db250513          	addi	a0,a0,-590 # ffffffffc0205670 <commands+0x488>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	d6650513          	addi	a0,a0,-666 # ffffffffc0205630 <commands+0x448>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205650 <commands+0x468>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	dde50513          	addi	a0,a0,-546 # ffffffffc02056c0 <commands+0x4d8>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008ee:	1141                	addi	sp,sp,-16
ffffffffc02008f0:	e022                	sd	s0,0(sp)
ffffffffc02008f2:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008f4:	bf1ff0ef          	jal	ra,ffffffffc02004e4 <clock_set_next_event>
            ticks++;
ffffffffc02008f8:	00016797          	auipc	a5,0x16
ffffffffc02008fc:	b9078793          	addi	a5,a5,-1136 # ffffffffc0216488 <ticks.1577>
ffffffffc0200900:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
ffffffffc0200902:	06400713          	li	a4,100
ffffffffc0200906:	00016417          	auipc	s0,0x16
ffffffffc020090a:	b7a40413          	addi	s0,s0,-1158 # ffffffffc0216480 <num>
            ticks++;
ffffffffc020090e:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
ffffffffc0200910:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200914:	00016697          	auipc	a3,0x16
ffffffffc0200918:	b6f6aa23          	sw	a5,-1164(a3) # ffffffffc0216488 <ticks.1577>
            if (ticks % TICK_NUM == 0){
ffffffffc020091c:	c305                	beqz	a4,ffffffffc020093c <interrupt_handler+0xaa>
            if (num == 10){
ffffffffc020091e:	6018                	ld	a4,0(s0)
ffffffffc0200920:	47a9                	li	a5,10
ffffffffc0200922:	00f71863          	bne	a4,a5,ffffffffc0200932 <interrupt_handler+0xa0>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200926:	4501                	li	a0,0
ffffffffc0200928:	4581                	li	a1,0
ffffffffc020092a:	4601                	li	a2,0
ffffffffc020092c:	48a1                	li	a7,8
ffffffffc020092e:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200932:	60a2                	ld	ra,8(sp)
ffffffffc0200934:	6402                	ld	s0,0(sp)
ffffffffc0200936:	0141                	addi	sp,sp,16
ffffffffc0200938:	8082                	ret
            print_trapframe(tf);
ffffffffc020093a:	bddd                	j	ffffffffc0200830 <print_trapframe>
            num++;
ffffffffc020093c:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020093e:	06400593          	li	a1,100
ffffffffc0200942:	00005517          	auipc	a0,0x5
ffffffffc0200946:	d6e50513          	addi	a0,a0,-658 # ffffffffc02056b0 <commands+0x4c8>
            num++;
ffffffffc020094a:	0785                	addi	a5,a5,1
ffffffffc020094c:	00016717          	auipc	a4,0x16
ffffffffc0200950:	b2f73a23          	sd	a5,-1228(a4) # ffffffffc0216480 <num>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200954:	83bff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200958:	b7d9                	j	ffffffffc020091e <interrupt_handler+0x8c>

ffffffffc020095a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020095a:	11853783          	ld	a5,280(a0)
ffffffffc020095e:	473d                	li	a4,15
ffffffffc0200960:	1af76363          	bltu	a4,a5,ffffffffc0200b06 <exception_handler+0x1ac>
ffffffffc0200964:	00005717          	auipc	a4,0x5
ffffffffc0200968:	a7070713          	addi	a4,a4,-1424 # ffffffffc02053d4 <commands+0x1ec>
ffffffffc020096c:	078a                	slli	a5,a5,0x2
ffffffffc020096e:	97ba                	add	a5,a5,a4
ffffffffc0200970:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200972:	1101                	addi	sp,sp,-32
ffffffffc0200974:	e822                	sd	s0,16(sp)
ffffffffc0200976:	ec06                	sd	ra,24(sp)
ffffffffc0200978:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020097a:	97ba                	add	a5,a5,a4
ffffffffc020097c:	842a                	mv	s0,a0
ffffffffc020097e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	c9850513          	addi	a0,a0,-872 # ffffffffc0205618 <commands+0x430>
ffffffffc0200988:	807ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	c4bff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200992:	84aa                	mv	s1,a0
ffffffffc0200994:	16051a63          	bnez	a0,ffffffffc0200b08 <exception_handler+0x1ae>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200998:	60e2                	ld	ra,24(sp)
ffffffffc020099a:	6442                	ld	s0,16(sp)
ffffffffc020099c:	64a2                	ld	s1,8(sp)
ffffffffc020099e:	6105                	addi	sp,sp,32
ffffffffc02009a0:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02009a2:	00005517          	auipc	a0,0x5
ffffffffc02009a6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0205418 <commands+0x230>
}
ffffffffc02009aa:	6442                	ld	s0,16(sp)
ffffffffc02009ac:	60e2                	ld	ra,24(sp)
ffffffffc02009ae:	64a2                	ld	s1,8(sp)
ffffffffc02009b0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02009b2:	fdcff06f          	j	ffffffffc020018e <cprintf>
ffffffffc02009b6:	00005517          	auipc	a0,0x5
ffffffffc02009ba:	a8250513          	addi	a0,a0,-1406 # ffffffffc0205438 <commands+0x250>
ffffffffc02009be:	b7f5                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02009c0:	00005517          	auipc	a0,0x5
ffffffffc02009c4:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205458 <commands+0x270>
ffffffffc02009c8:	fc6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc02009cc:	10843583          	ld	a1,264(s0)
ffffffffc02009d0:	00005517          	auipc	a0,0x5
ffffffffc02009d4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205480 <commands+0x298>
ffffffffc02009d8:	fb6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc02009dc:	10843783          	ld	a5,264(s0)
ffffffffc02009e0:	0791                	addi	a5,a5,4
ffffffffc02009e2:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02009e6:	bf4d                	j	ffffffffc0200998 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	ac050513          	addi	a0,a0,-1344 # ffffffffc02054a8 <commands+0x2c0>
ffffffffc02009f0:	f9eff0ef          	jal	ra,ffffffffc020018e <cprintf>
            cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02009f4:	10843583          	ld	a1,264(s0)
ffffffffc02009f8:	00005517          	auipc	a0,0x5
ffffffffc02009fc:	ad050513          	addi	a0,a0,-1328 # ffffffffc02054c8 <commands+0x2e0>
ffffffffc0200a00:	f8eff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 2;
ffffffffc0200a04:	10843783          	ld	a5,264(s0)
ffffffffc0200a08:	0789                	addi	a5,a5,2
ffffffffc0200a0a:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200a0e:	b769                	j	ffffffffc0200998 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	ad050513          	addi	a0,a0,-1328 # ffffffffc02054e0 <commands+0x2f8>
ffffffffc0200a18:	bf49                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200a1a:	00005517          	auipc	a0,0x5
ffffffffc0200a1e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0205500 <commands+0x318>
ffffffffc0200a22:	f6cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a26:	8522                	mv	a0,s0
ffffffffc0200a28:	bb1ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a2c:	84aa                	mv	s1,a0
ffffffffc0200a2e:	d52d                	beqz	a0,ffffffffc0200998 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a30:	8522                	mv	a0,s0
ffffffffc0200a32:	dffff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a36:	86a6                	mv	a3,s1
ffffffffc0200a38:	00005617          	auipc	a2,0x5
ffffffffc0200a3c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0205518 <commands+0x330>
ffffffffc0200a40:	0c000593          	li	a1,192
ffffffffc0200a44:	00005517          	auipc	a0,0x5
ffffffffc0200a48:	cd450513          	addi	a0,a0,-812 # ffffffffc0205718 <commands+0x530>
ffffffffc0200a4c:	a01ff0ef          	jal	ra,ffffffffc020044c <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205538 <commands+0x350>
ffffffffc0200a58:	bf89                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a5a:	00005517          	auipc	a0,0x5
ffffffffc0200a5e:	af650513          	addi	a0,a0,-1290 # ffffffffc0205550 <commands+0x368>
ffffffffc0200a62:	f2cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a66:	8522                	mv	a0,s0
ffffffffc0200a68:	b71ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a6c:	84aa                	mv	s1,a0
ffffffffc0200a6e:	f20505e3          	beqz	a0,ffffffffc0200998 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a72:	8522                	mv	a0,s0
ffffffffc0200a74:	dbdff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a78:	86a6                	mv	a3,s1
ffffffffc0200a7a:	00005617          	auipc	a2,0x5
ffffffffc0200a7e:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0205518 <commands+0x330>
ffffffffc0200a82:	0ca00593          	li	a1,202
ffffffffc0200a86:	00005517          	auipc	a0,0x5
ffffffffc0200a8a:	c9250513          	addi	a0,a0,-878 # ffffffffc0205718 <commands+0x530>
ffffffffc0200a8e:	9bfff0ef          	jal	ra,ffffffffc020044c <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a92:	00005517          	auipc	a0,0x5
ffffffffc0200a96:	ad650513          	addi	a0,a0,-1322 # ffffffffc0205568 <commands+0x380>
ffffffffc0200a9a:	bf01                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	aec50513          	addi	a0,a0,-1300 # ffffffffc0205588 <commands+0x3a0>
ffffffffc0200aa4:	b719                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa6:	00005517          	auipc	a0,0x5
ffffffffc0200aaa:	b0250513          	addi	a0,a0,-1278 # ffffffffc02055a8 <commands+0x3c0>
ffffffffc0200aae:	bdf5                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab0:	00005517          	auipc	a0,0x5
ffffffffc0200ab4:	b1850513          	addi	a0,a0,-1256 # ffffffffc02055c8 <commands+0x3e0>
ffffffffc0200ab8:	bdcd                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aba:	00005517          	auipc	a0,0x5
ffffffffc0200abe:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02055e8 <commands+0x400>
ffffffffc0200ac2:	b5e5                	j	ffffffffc02009aa <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0205600 <commands+0x418>
ffffffffc0200acc:	ec2ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad0:	8522                	mv	a0,s0
ffffffffc0200ad2:	b07ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200ad6:	84aa                	mv	s1,a0
ffffffffc0200ad8:	ec0500e3          	beqz	a0,ffffffffc0200998 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200adc:	8522                	mv	a0,s0
ffffffffc0200ade:	d53ff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ae2:	86a6                	mv	a3,s1
ffffffffc0200ae4:	00005617          	auipc	a2,0x5
ffffffffc0200ae8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0205518 <commands+0x330>
ffffffffc0200aec:	0e000593          	li	a1,224
ffffffffc0200af0:	00005517          	auipc	a0,0x5
ffffffffc0200af4:	c2850513          	addi	a0,a0,-984 # ffffffffc0205718 <commands+0x530>
ffffffffc0200af8:	955ff0ef          	jal	ra,ffffffffc020044c <__panic>
}
ffffffffc0200afc:	6442                	ld	s0,16(sp)
ffffffffc0200afe:	60e2                	ld	ra,24(sp)
ffffffffc0200b00:	64a2                	ld	s1,8(sp)
ffffffffc0200b02:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200b04:	b335                	j	ffffffffc0200830 <print_trapframe>
ffffffffc0200b06:	b32d                	j	ffffffffc0200830 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	d27ff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0e:	86a6                	mv	a3,s1
ffffffffc0200b10:	00005617          	auipc	a2,0x5
ffffffffc0200b14:	a0860613          	addi	a2,a2,-1528 # ffffffffc0205518 <commands+0x330>
ffffffffc0200b18:	0e700593          	li	a1,231
ffffffffc0200b1c:	00005517          	auipc	a0,0x5
ffffffffc0200b20:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0205718 <commands+0x530>
ffffffffc0200b24:	929ff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0200b28 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200b28:	11853783          	ld	a5,280(a0)
ffffffffc0200b2c:	0007c363          	bltz	a5,ffffffffc0200b32 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b30:	b52d                	j	ffffffffc020095a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b32:	b385                	j	ffffffffc0200892 <interrupt_handler>

ffffffffc0200b34 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b34:	14011073          	csrw	sscratch,sp
ffffffffc0200b38:	712d                	addi	sp,sp,-288
ffffffffc0200b3a:	e406                	sd	ra,8(sp)
ffffffffc0200b3c:	ec0e                	sd	gp,24(sp)
ffffffffc0200b3e:	f012                	sd	tp,32(sp)
ffffffffc0200b40:	f416                	sd	t0,40(sp)
ffffffffc0200b42:	f81a                	sd	t1,48(sp)
ffffffffc0200b44:	fc1e                	sd	t2,56(sp)
ffffffffc0200b46:	e0a2                	sd	s0,64(sp)
ffffffffc0200b48:	e4a6                	sd	s1,72(sp)
ffffffffc0200b4a:	e8aa                	sd	a0,80(sp)
ffffffffc0200b4c:	ecae                	sd	a1,88(sp)
ffffffffc0200b4e:	f0b2                	sd	a2,96(sp)
ffffffffc0200b50:	f4b6                	sd	a3,104(sp)
ffffffffc0200b52:	f8ba                	sd	a4,112(sp)
ffffffffc0200b54:	fcbe                	sd	a5,120(sp)
ffffffffc0200b56:	e142                	sd	a6,128(sp)
ffffffffc0200b58:	e546                	sd	a7,136(sp)
ffffffffc0200b5a:	e94a                	sd	s2,144(sp)
ffffffffc0200b5c:	ed4e                	sd	s3,152(sp)
ffffffffc0200b5e:	f152                	sd	s4,160(sp)
ffffffffc0200b60:	f556                	sd	s5,168(sp)
ffffffffc0200b62:	f95a                	sd	s6,176(sp)
ffffffffc0200b64:	fd5e                	sd	s7,184(sp)
ffffffffc0200b66:	e1e2                	sd	s8,192(sp)
ffffffffc0200b68:	e5e6                	sd	s9,200(sp)
ffffffffc0200b6a:	e9ea                	sd	s10,208(sp)
ffffffffc0200b6c:	edee                	sd	s11,216(sp)
ffffffffc0200b6e:	f1f2                	sd	t3,224(sp)
ffffffffc0200b70:	f5f6                	sd	t4,232(sp)
ffffffffc0200b72:	f9fa                	sd	t5,240(sp)
ffffffffc0200b74:	fdfe                	sd	t6,248(sp)
ffffffffc0200b76:	14002473          	csrr	s0,sscratch
ffffffffc0200b7a:	100024f3          	csrr	s1,sstatus
ffffffffc0200b7e:	14102973          	csrr	s2,sepc
ffffffffc0200b82:	143029f3          	csrr	s3,stval
ffffffffc0200b86:	14202a73          	csrr	s4,scause
ffffffffc0200b8a:	e822                	sd	s0,16(sp)
ffffffffc0200b8c:	e226                	sd	s1,256(sp)
ffffffffc0200b8e:	e64a                	sd	s2,264(sp)
ffffffffc0200b90:	ea4e                	sd	s3,272(sp)
ffffffffc0200b92:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b94:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b96:	f93ff0ef          	jal	ra,ffffffffc0200b28 <trap>

ffffffffc0200b9a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b9a:	6492                	ld	s1,256(sp)
ffffffffc0200b9c:	6932                	ld	s2,264(sp)
ffffffffc0200b9e:	10049073          	csrw	sstatus,s1
ffffffffc0200ba2:	14191073          	csrw	sepc,s2
ffffffffc0200ba6:	60a2                	ld	ra,8(sp)
ffffffffc0200ba8:	61e2                	ld	gp,24(sp)
ffffffffc0200baa:	7202                	ld	tp,32(sp)
ffffffffc0200bac:	72a2                	ld	t0,40(sp)
ffffffffc0200bae:	7342                	ld	t1,48(sp)
ffffffffc0200bb0:	73e2                	ld	t2,56(sp)
ffffffffc0200bb2:	6406                	ld	s0,64(sp)
ffffffffc0200bb4:	64a6                	ld	s1,72(sp)
ffffffffc0200bb6:	6546                	ld	a0,80(sp)
ffffffffc0200bb8:	65e6                	ld	a1,88(sp)
ffffffffc0200bba:	7606                	ld	a2,96(sp)
ffffffffc0200bbc:	76a6                	ld	a3,104(sp)
ffffffffc0200bbe:	7746                	ld	a4,112(sp)
ffffffffc0200bc0:	77e6                	ld	a5,120(sp)
ffffffffc0200bc2:	680a                	ld	a6,128(sp)
ffffffffc0200bc4:	68aa                	ld	a7,136(sp)
ffffffffc0200bc6:	694a                	ld	s2,144(sp)
ffffffffc0200bc8:	69ea                	ld	s3,152(sp)
ffffffffc0200bca:	7a0a                	ld	s4,160(sp)
ffffffffc0200bcc:	7aaa                	ld	s5,168(sp)
ffffffffc0200bce:	7b4a                	ld	s6,176(sp)
ffffffffc0200bd0:	7bea                	ld	s7,184(sp)
ffffffffc0200bd2:	6c0e                	ld	s8,192(sp)
ffffffffc0200bd4:	6cae                	ld	s9,200(sp)
ffffffffc0200bd6:	6d4e                	ld	s10,208(sp)
ffffffffc0200bd8:	6dee                	ld	s11,216(sp)
ffffffffc0200bda:	7e0e                	ld	t3,224(sp)
ffffffffc0200bdc:	7eae                	ld	t4,232(sp)
ffffffffc0200bde:	7f4e                	ld	t5,240(sp)
ffffffffc0200be0:	7fee                	ld	t6,248(sp)
ffffffffc0200be2:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200be4:	10200073          	sret

ffffffffc0200be8 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200be8:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200bea:	bf45                	j	ffffffffc0200b9a <__trapret>
	...

ffffffffc0200bee <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bee:	00016797          	auipc	a5,0x16
ffffffffc0200bf2:	8f278793          	addi	a5,a5,-1806 # ffffffffc02164e0 <free_area>
ffffffffc0200bf6:	e79c                	sd	a5,8(a5)
ffffffffc0200bf8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200bfa:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200bfe:	8082                	ret

ffffffffc0200c00 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200c00:	00016517          	auipc	a0,0x16
ffffffffc0200c04:	8f056503          	lwu	a0,-1808(a0) # ffffffffc02164f0 <free_area+0x10>
ffffffffc0200c08:	8082                	ret

ffffffffc0200c0a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200c0a:	715d                	addi	sp,sp,-80
ffffffffc0200c0c:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c0e:	00016917          	auipc	s2,0x16
ffffffffc0200c12:	8d290913          	addi	s2,s2,-1838 # ffffffffc02164e0 <free_area>
ffffffffc0200c16:	00893783          	ld	a5,8(s2)
ffffffffc0200c1a:	e486                	sd	ra,72(sp)
ffffffffc0200c1c:	e0a2                	sd	s0,64(sp)
ffffffffc0200c1e:	fc26                	sd	s1,56(sp)
ffffffffc0200c20:	f44e                	sd	s3,40(sp)
ffffffffc0200c22:	f052                	sd	s4,32(sp)
ffffffffc0200c24:	ec56                	sd	s5,24(sp)
ffffffffc0200c26:	e85a                	sd	s6,16(sp)
ffffffffc0200c28:	e45e                	sd	s7,8(sp)
ffffffffc0200c2a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c2c:	31278f63          	beq	a5,s2,ffffffffc0200f4a <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c30:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c34:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c36:	8b05                	andi	a4,a4,1
ffffffffc0200c38:	30070d63          	beqz	a4,ffffffffc0200f52 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200c3c:	4401                	li	s0,0
ffffffffc0200c3e:	4481                	li	s1,0
ffffffffc0200c40:	a031                	j	ffffffffc0200c4c <default_check+0x42>
ffffffffc0200c42:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200c46:	8b09                	andi	a4,a4,2
ffffffffc0200c48:	30070563          	beqz	a4,ffffffffc0200f52 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200c4c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c50:	679c                	ld	a5,8(a5)
ffffffffc0200c52:	2485                	addiw	s1,s1,1
ffffffffc0200c54:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c56:	ff2796e3          	bne	a5,s2,ffffffffc0200c42 <default_check+0x38>
ffffffffc0200c5a:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c5c:	07c010ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0200c60:	75351963          	bne	a0,s3,ffffffffc02013b2 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	7a5000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200c6a:	8a2a                	mv	s4,a0
ffffffffc0200c6c:	48050363          	beqz	a0,ffffffffc02010f2 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c70:	4505                	li	a0,1
ffffffffc0200c72:	799000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200c76:	89aa                	mv	s3,a0
ffffffffc0200c78:	74050d63          	beqz	a0,ffffffffc02013d2 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c7c:	4505                	li	a0,1
ffffffffc0200c7e:	78d000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200c82:	8aaa                	mv	s5,a0
ffffffffc0200c84:	4e050763          	beqz	a0,ffffffffc0201172 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c88:	2f3a0563          	beq	s4,s3,ffffffffc0200f72 <default_check+0x368>
ffffffffc0200c8c:	2eaa0363          	beq	s4,a0,ffffffffc0200f72 <default_check+0x368>
ffffffffc0200c90:	2ea98163          	beq	s3,a0,ffffffffc0200f72 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c94:	000a2783          	lw	a5,0(s4)
ffffffffc0200c98:	2e079d63          	bnez	a5,ffffffffc0200f92 <default_check+0x388>
ffffffffc0200c9c:	0009a783          	lw	a5,0(s3)
ffffffffc0200ca0:	2e079963          	bnez	a5,ffffffffc0200f92 <default_check+0x388>
ffffffffc0200ca4:	411c                	lw	a5,0(a0)
ffffffffc0200ca6:	2e079663          	bnez	a5,ffffffffc0200f92 <default_check+0x388>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200caa:	00016797          	auipc	a5,0x16
ffffffffc0200cae:	86678793          	addi	a5,a5,-1946 # ffffffffc0216510 <pages>
ffffffffc0200cb2:	639c                	ld	a5,0(a5)
ffffffffc0200cb4:	00005717          	auipc	a4,0x5
ffffffffc0200cb8:	df470713          	addi	a4,a4,-524 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0200cbc:	630c                	ld	a1,0(a4)
ffffffffc0200cbe:	40fa0733          	sub	a4,s4,a5
ffffffffc0200cc2:	870d                	srai	a4,a4,0x3
ffffffffc0200cc4:	02b70733          	mul	a4,a4,a1
ffffffffc0200cc8:	00006697          	auipc	a3,0x6
ffffffffc0200ccc:	53868693          	addi	a3,a3,1336 # ffffffffc0207200 <nbase>
ffffffffc0200cd0:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200cd2:	00015697          	auipc	a3,0x15
ffffffffc0200cd6:	7ce68693          	addi	a3,a3,1998 # ffffffffc02164a0 <npage>
ffffffffc0200cda:	6294                	ld	a3,0(a3)
ffffffffc0200cdc:	06b2                	slli	a3,a3,0xc
ffffffffc0200cde:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ce0:	0732                	slli	a4,a4,0xc
ffffffffc0200ce2:	2cd77863          	bgeu	a4,a3,ffffffffc0200fb2 <default_check+0x3a8>
    return page - pages + nbase;
ffffffffc0200ce6:	40f98733          	sub	a4,s3,a5
ffffffffc0200cea:	870d                	srai	a4,a4,0x3
ffffffffc0200cec:	02b70733          	mul	a4,a4,a1
ffffffffc0200cf0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cf2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cf4:	4ed77f63          	bgeu	a4,a3,ffffffffc02011f2 <default_check+0x5e8>
    return page - pages + nbase;
ffffffffc0200cf8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cfc:	878d                	srai	a5,a5,0x3
ffffffffc0200cfe:	02b787b3          	mul	a5,a5,a1
ffffffffc0200d02:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d04:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d06:	34d7f663          	bgeu	a5,a3,ffffffffc0201052 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200d0a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d0c:	00093c03          	ld	s8,0(s2)
ffffffffc0200d10:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200d14:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200d18:	00015797          	auipc	a5,0x15
ffffffffc0200d1c:	7d27b823          	sd	s2,2000(a5) # ffffffffc02164e8 <free_area+0x8>
ffffffffc0200d20:	00015797          	auipc	a5,0x15
ffffffffc0200d24:	7d27b023          	sd	s2,1984(a5) # ffffffffc02164e0 <free_area>
    nr_free = 0;
ffffffffc0200d28:	00015797          	auipc	a5,0x15
ffffffffc0200d2c:	7c07a423          	sw	zero,1992(a5) # ffffffffc02164f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200d30:	6db000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d34:	2e051f63          	bnez	a0,ffffffffc0201032 <default_check+0x428>
    free_page(p0);
ffffffffc0200d38:	4585                	li	a1,1
ffffffffc0200d3a:	8552                	mv	a0,s4
ffffffffc0200d3c:	757000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p1);
ffffffffc0200d40:	4585                	li	a1,1
ffffffffc0200d42:	854e                	mv	a0,s3
ffffffffc0200d44:	74f000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200d48:	4585                	li	a1,1
ffffffffc0200d4a:	8556                	mv	a0,s5
ffffffffc0200d4c:	747000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(nr_free == 3);
ffffffffc0200d50:	01092703          	lw	a4,16(s2)
ffffffffc0200d54:	478d                	li	a5,3
ffffffffc0200d56:	2af71e63          	bne	a4,a5,ffffffffc0201012 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d5a:	4505                	li	a0,1
ffffffffc0200d5c:	6af000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d60:	89aa                	mv	s3,a0
ffffffffc0200d62:	28050863          	beqz	a0,ffffffffc0200ff2 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d66:	4505                	li	a0,1
ffffffffc0200d68:	6a3000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d6c:	8aaa                	mv	s5,a0
ffffffffc0200d6e:	3e050263          	beqz	a0,ffffffffc0201152 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d72:	4505                	li	a0,1
ffffffffc0200d74:	697000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d78:	8a2a                	mv	s4,a0
ffffffffc0200d7a:	3a050c63          	beqz	a0,ffffffffc0201132 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200d7e:	4505                	li	a0,1
ffffffffc0200d80:	68b000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d84:	38051763          	bnez	a0,ffffffffc0201112 <default_check+0x508>
    free_page(p0);
ffffffffc0200d88:	4585                	li	a1,1
ffffffffc0200d8a:	854e                	mv	a0,s3
ffffffffc0200d8c:	707000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d90:	00893783          	ld	a5,8(s2)
ffffffffc0200d94:	23278f63          	beq	a5,s2,ffffffffc0200fd2 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200d98:	4505                	li	a0,1
ffffffffc0200d9a:	671000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d9e:	32a99a63          	bne	s3,a0,ffffffffc02010d2 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200da2:	4505                	li	a0,1
ffffffffc0200da4:	667000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200da8:	30051563          	bnez	a0,ffffffffc02010b2 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200dac:	01092783          	lw	a5,16(s2)
ffffffffc0200db0:	2e079163          	bnez	a5,ffffffffc0201092 <default_check+0x488>
    free_page(p);
ffffffffc0200db4:	854e                	mv	a0,s3
ffffffffc0200db6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200db8:	00015797          	auipc	a5,0x15
ffffffffc0200dbc:	7387b423          	sd	s8,1832(a5) # ffffffffc02164e0 <free_area>
ffffffffc0200dc0:	00015797          	auipc	a5,0x15
ffffffffc0200dc4:	7377b423          	sd	s7,1832(a5) # ffffffffc02164e8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200dc8:	00015797          	auipc	a5,0x15
ffffffffc0200dcc:	7367a423          	sw	s6,1832(a5) # ffffffffc02164f0 <free_area+0x10>
    free_page(p);
ffffffffc0200dd0:	6c3000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p1);
ffffffffc0200dd4:	4585                	li	a1,1
ffffffffc0200dd6:	8556                	mv	a0,s5
ffffffffc0200dd8:	6bb000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200ddc:	4585                	li	a1,1
ffffffffc0200dde:	8552                	mv	a0,s4
ffffffffc0200de0:	6b3000ef          	jal	ra,ffffffffc0201c92 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200de4:	4515                	li	a0,5
ffffffffc0200de6:	625000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200dea:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200dec:	28050363          	beqz	a0,ffffffffc0201072 <default_check+0x468>
ffffffffc0200df0:	651c                	ld	a5,8(a0)
ffffffffc0200df2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200df4:	8b85                	andi	a5,a5,1
ffffffffc0200df6:	54079e63          	bnez	a5,ffffffffc0201352 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200dfa:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200dfc:	00093b03          	ld	s6,0(s2)
ffffffffc0200e00:	00893a83          	ld	s5,8(s2)
ffffffffc0200e04:	00015797          	auipc	a5,0x15
ffffffffc0200e08:	6d27be23          	sd	s2,1756(a5) # ffffffffc02164e0 <free_area>
ffffffffc0200e0c:	00015797          	auipc	a5,0x15
ffffffffc0200e10:	6d27be23          	sd	s2,1756(a5) # ffffffffc02164e8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200e14:	5f7000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e18:	50051d63          	bnez	a0,ffffffffc0201332 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200e1c:	09098a13          	addi	s4,s3,144
ffffffffc0200e20:	8552                	mv	a0,s4
ffffffffc0200e22:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200e24:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200e28:	00015797          	auipc	a5,0x15
ffffffffc0200e2c:	6c07a423          	sw	zero,1736(a5) # ffffffffc02164f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200e30:	663000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e34:	4511                	li	a0,4
ffffffffc0200e36:	5d5000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e3a:	4c051c63          	bnez	a0,ffffffffc0201312 <default_check+0x708>
ffffffffc0200e3e:	0989b783          	ld	a5,152(s3)
ffffffffc0200e42:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200e44:	8b85                	andi	a5,a5,1
ffffffffc0200e46:	4a078663          	beqz	a5,ffffffffc02012f2 <default_check+0x6e8>
ffffffffc0200e4a:	0a89a703          	lw	a4,168(s3)
ffffffffc0200e4e:	478d                	li	a5,3
ffffffffc0200e50:	4af71163          	bne	a4,a5,ffffffffc02012f2 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e54:	450d                	li	a0,3
ffffffffc0200e56:	5b5000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e5a:	8c2a                	mv	s8,a0
ffffffffc0200e5c:	46050b63          	beqz	a0,ffffffffc02012d2 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200e60:	4505                	li	a0,1
ffffffffc0200e62:	5a9000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e66:	44051663          	bnez	a0,ffffffffc02012b2 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200e6a:	438a1463          	bne	s4,s8,ffffffffc0201292 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e6e:	4585                	li	a1,1
ffffffffc0200e70:	854e                	mv	a0,s3
ffffffffc0200e72:	621000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_pages(p1, 3);
ffffffffc0200e76:	458d                	li	a1,3
ffffffffc0200e78:	8552                	mv	a0,s4
ffffffffc0200e7a:	619000ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc0200e7e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e82:	04898c13          	addi	s8,s3,72
ffffffffc0200e86:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e88:	8b85                	andi	a5,a5,1
ffffffffc0200e8a:	3e078463          	beqz	a5,ffffffffc0201272 <default_check+0x668>
ffffffffc0200e8e:	0189a703          	lw	a4,24(s3)
ffffffffc0200e92:	4785                	li	a5,1
ffffffffc0200e94:	3cf71f63          	bne	a4,a5,ffffffffc0201272 <default_check+0x668>
ffffffffc0200e98:	008a3783          	ld	a5,8(s4)
ffffffffc0200e9c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e9e:	8b85                	andi	a5,a5,1
ffffffffc0200ea0:	3a078963          	beqz	a5,ffffffffc0201252 <default_check+0x648>
ffffffffc0200ea4:	018a2703          	lw	a4,24(s4)
ffffffffc0200ea8:	478d                	li	a5,3
ffffffffc0200eaa:	3af71463          	bne	a4,a5,ffffffffc0201252 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200eae:	4505                	li	a0,1
ffffffffc0200eb0:	55b000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200eb4:	36a99f63          	bne	s3,a0,ffffffffc0201232 <default_check+0x628>
    free_page(p0);
ffffffffc0200eb8:	4585                	li	a1,1
ffffffffc0200eba:	5d9000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200ebe:	4509                	li	a0,2
ffffffffc0200ec0:	54b000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ec4:	34aa1763          	bne	s4,a0,ffffffffc0201212 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200ec8:	4589                	li	a1,2
ffffffffc0200eca:	5c9000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200ece:	4585                	li	a1,1
ffffffffc0200ed0:	8562                	mv	a0,s8
ffffffffc0200ed2:	5c1000ef          	jal	ra,ffffffffc0201c92 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ed6:	4515                	li	a0,5
ffffffffc0200ed8:	533000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200edc:	89aa                	mv	s3,a0
ffffffffc0200ede:	48050a63          	beqz	a0,ffffffffc0201372 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200ee2:	4505                	li	a0,1
ffffffffc0200ee4:	527000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ee8:	2e051563          	bnez	a0,ffffffffc02011d2 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200eec:	01092783          	lw	a5,16(s2)
ffffffffc0200ef0:	2c079163          	bnez	a5,ffffffffc02011b2 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ef4:	4595                	li	a1,5
ffffffffc0200ef6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ef8:	00015797          	auipc	a5,0x15
ffffffffc0200efc:	5f77ac23          	sw	s7,1528(a5) # ffffffffc02164f0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200f00:	00015797          	auipc	a5,0x15
ffffffffc0200f04:	5f67b023          	sd	s6,1504(a5) # ffffffffc02164e0 <free_area>
ffffffffc0200f08:	00015797          	auipc	a5,0x15
ffffffffc0200f0c:	5f57b023          	sd	s5,1504(a5) # ffffffffc02164e8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200f10:	583000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return listelm->next;
ffffffffc0200f14:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f18:	01278963          	beq	a5,s2,ffffffffc0200f2a <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200f1c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f20:	679c                	ld	a5,8(a5)
ffffffffc0200f22:	34fd                	addiw	s1,s1,-1
ffffffffc0200f24:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f26:	ff279be3          	bne	a5,s2,ffffffffc0200f1c <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200f2a:	26049463          	bnez	s1,ffffffffc0201192 <default_check+0x588>
    assert(total == 0);
ffffffffc0200f2e:	46041263          	bnez	s0,ffffffffc0201392 <default_check+0x788>
}
ffffffffc0200f32:	60a6                	ld	ra,72(sp)
ffffffffc0200f34:	6406                	ld	s0,64(sp)
ffffffffc0200f36:	74e2                	ld	s1,56(sp)
ffffffffc0200f38:	7942                	ld	s2,48(sp)
ffffffffc0200f3a:	79a2                	ld	s3,40(sp)
ffffffffc0200f3c:	7a02                	ld	s4,32(sp)
ffffffffc0200f3e:	6ae2                	ld	s5,24(sp)
ffffffffc0200f40:	6b42                	ld	s6,16(sp)
ffffffffc0200f42:	6ba2                	ld	s7,8(sp)
ffffffffc0200f44:	6c02                	ld	s8,0(sp)
ffffffffc0200f46:	6161                	addi	sp,sp,80
ffffffffc0200f48:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f4a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f4c:	4401                	li	s0,0
ffffffffc0200f4e:	4481                	li	s1,0
ffffffffc0200f50:	b331                	j	ffffffffc0200c5c <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200f52:	00005697          	auipc	a3,0x5
ffffffffc0200f56:	b5e68693          	addi	a3,a3,-1186 # ffffffffc0205ab0 <commands+0x8c8>
ffffffffc0200f5a:	00005617          	auipc	a2,0x5
ffffffffc0200f5e:	b6660613          	addi	a2,a2,-1178 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200f62:	0f000593          	li	a1,240
ffffffffc0200f66:	00005517          	auipc	a0,0x5
ffffffffc0200f6a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0200f6e:	cdeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f72:	00005697          	auipc	a3,0x5
ffffffffc0200f76:	bfe68693          	addi	a3,a3,-1026 # ffffffffc0205b70 <commands+0x988>
ffffffffc0200f7a:	00005617          	auipc	a2,0x5
ffffffffc0200f7e:	b4660613          	addi	a2,a2,-1210 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200f82:	0bd00593          	li	a1,189
ffffffffc0200f86:	00005517          	auipc	a0,0x5
ffffffffc0200f8a:	b5250513          	addi	a0,a0,-1198 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0200f8e:	cbeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f92:	00005697          	auipc	a3,0x5
ffffffffc0200f96:	c0668693          	addi	a3,a3,-1018 # ffffffffc0205b98 <commands+0x9b0>
ffffffffc0200f9a:	00005617          	auipc	a2,0x5
ffffffffc0200f9e:	b2660613          	addi	a2,a2,-1242 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200fa2:	0be00593          	li	a1,190
ffffffffc0200fa6:	00005517          	auipc	a0,0x5
ffffffffc0200faa:	b3250513          	addi	a0,a0,-1230 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0200fae:	c9eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fb2:	00005697          	auipc	a3,0x5
ffffffffc0200fb6:	c2668693          	addi	a3,a3,-986 # ffffffffc0205bd8 <commands+0x9f0>
ffffffffc0200fba:	00005617          	auipc	a2,0x5
ffffffffc0200fbe:	b0660613          	addi	a2,a2,-1274 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200fc2:	0c000593          	li	a1,192
ffffffffc0200fc6:	00005517          	auipc	a0,0x5
ffffffffc0200fca:	b1250513          	addi	a0,a0,-1262 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0200fce:	c7eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200fd2:	00005697          	auipc	a3,0x5
ffffffffc0200fd6:	c8e68693          	addi	a3,a3,-882 # ffffffffc0205c60 <commands+0xa78>
ffffffffc0200fda:	00005617          	auipc	a2,0x5
ffffffffc0200fde:	ae660613          	addi	a2,a2,-1306 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0200fe2:	0d900593          	li	a1,217
ffffffffc0200fe6:	00005517          	auipc	a0,0x5
ffffffffc0200fea:	af250513          	addi	a0,a0,-1294 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0200fee:	c5eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ff2:	00005697          	auipc	a3,0x5
ffffffffc0200ff6:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0205b10 <commands+0x928>
ffffffffc0200ffa:	00005617          	auipc	a2,0x5
ffffffffc0200ffe:	ac660613          	addi	a2,a2,-1338 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201002:	0d200593          	li	a1,210
ffffffffc0201006:	00005517          	auipc	a0,0x5
ffffffffc020100a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020100e:	c3eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 3);
ffffffffc0201012:	00005697          	auipc	a3,0x5
ffffffffc0201016:	c3e68693          	addi	a3,a3,-962 # ffffffffc0205c50 <commands+0xa68>
ffffffffc020101a:	00005617          	auipc	a2,0x5
ffffffffc020101e:	aa660613          	addi	a2,a2,-1370 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201022:	0d000593          	li	a1,208
ffffffffc0201026:	00005517          	auipc	a0,0x5
ffffffffc020102a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020102e:	c1eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201032:	00005697          	auipc	a3,0x5
ffffffffc0201036:	c0668693          	addi	a3,a3,-1018 # ffffffffc0205c38 <commands+0xa50>
ffffffffc020103a:	00005617          	auipc	a2,0x5
ffffffffc020103e:	a8660613          	addi	a2,a2,-1402 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201042:	0cb00593          	li	a1,203
ffffffffc0201046:	00005517          	auipc	a0,0x5
ffffffffc020104a:	a9250513          	addi	a0,a0,-1390 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020104e:	bfeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201052:	00005697          	auipc	a3,0x5
ffffffffc0201056:	bc668693          	addi	a3,a3,-1082 # ffffffffc0205c18 <commands+0xa30>
ffffffffc020105a:	00005617          	auipc	a2,0x5
ffffffffc020105e:	a6660613          	addi	a2,a2,-1434 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201062:	0c200593          	li	a1,194
ffffffffc0201066:	00005517          	auipc	a0,0x5
ffffffffc020106a:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020106e:	bdeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 != NULL);
ffffffffc0201072:	00005697          	auipc	a3,0x5
ffffffffc0201076:	c3668693          	addi	a3,a3,-970 # ffffffffc0205ca8 <commands+0xac0>
ffffffffc020107a:	00005617          	auipc	a2,0x5
ffffffffc020107e:	a4660613          	addi	a2,a2,-1466 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201082:	0f800593          	li	a1,248
ffffffffc0201086:	00005517          	auipc	a0,0x5
ffffffffc020108a:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020108e:	bbeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 0);
ffffffffc0201092:	00005697          	auipc	a3,0x5
ffffffffc0201096:	c0668693          	addi	a3,a3,-1018 # ffffffffc0205c98 <commands+0xab0>
ffffffffc020109a:	00005617          	auipc	a2,0x5
ffffffffc020109e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02010a2:	0df00593          	li	a1,223
ffffffffc02010a6:	00005517          	auipc	a0,0x5
ffffffffc02010aa:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02010ae:	b9eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010b2:	00005697          	auipc	a3,0x5
ffffffffc02010b6:	b8668693          	addi	a3,a3,-1146 # ffffffffc0205c38 <commands+0xa50>
ffffffffc02010ba:	00005617          	auipc	a2,0x5
ffffffffc02010be:	a0660613          	addi	a2,a2,-1530 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02010c2:	0dd00593          	li	a1,221
ffffffffc02010c6:	00005517          	auipc	a0,0x5
ffffffffc02010ca:	a1250513          	addi	a0,a0,-1518 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02010ce:	b7eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02010d2:	00005697          	auipc	a3,0x5
ffffffffc02010d6:	ba668693          	addi	a3,a3,-1114 # ffffffffc0205c78 <commands+0xa90>
ffffffffc02010da:	00005617          	auipc	a2,0x5
ffffffffc02010de:	9e660613          	addi	a2,a2,-1562 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02010e2:	0dc00593          	li	a1,220
ffffffffc02010e6:	00005517          	auipc	a0,0x5
ffffffffc02010ea:	9f250513          	addi	a0,a0,-1550 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02010ee:	b5eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010f2:	00005697          	auipc	a3,0x5
ffffffffc02010f6:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0205b10 <commands+0x928>
ffffffffc02010fa:	00005617          	auipc	a2,0x5
ffffffffc02010fe:	9c660613          	addi	a2,a2,-1594 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201102:	0b900593          	li	a1,185
ffffffffc0201106:	00005517          	auipc	a0,0x5
ffffffffc020110a:	9d250513          	addi	a0,a0,-1582 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020110e:	b3eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201112:	00005697          	auipc	a3,0x5
ffffffffc0201116:	b2668693          	addi	a3,a3,-1242 # ffffffffc0205c38 <commands+0xa50>
ffffffffc020111a:	00005617          	auipc	a2,0x5
ffffffffc020111e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201122:	0d600593          	li	a1,214
ffffffffc0201126:	00005517          	auipc	a0,0x5
ffffffffc020112a:	9b250513          	addi	a0,a0,-1614 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020112e:	b1eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201132:	00005697          	auipc	a3,0x5
ffffffffc0201136:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0205b50 <commands+0x968>
ffffffffc020113a:	00005617          	auipc	a2,0x5
ffffffffc020113e:	98660613          	addi	a2,a2,-1658 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201142:	0d400593          	li	a1,212
ffffffffc0201146:	00005517          	auipc	a0,0x5
ffffffffc020114a:	99250513          	addi	a0,a0,-1646 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020114e:	afeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201152:	00005697          	auipc	a3,0x5
ffffffffc0201156:	9de68693          	addi	a3,a3,-1570 # ffffffffc0205b30 <commands+0x948>
ffffffffc020115a:	00005617          	auipc	a2,0x5
ffffffffc020115e:	96660613          	addi	a2,a2,-1690 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201162:	0d300593          	li	a1,211
ffffffffc0201166:	00005517          	auipc	a0,0x5
ffffffffc020116a:	97250513          	addi	a0,a0,-1678 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020116e:	adeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201172:	00005697          	auipc	a3,0x5
ffffffffc0201176:	9de68693          	addi	a3,a3,-1570 # ffffffffc0205b50 <commands+0x968>
ffffffffc020117a:	00005617          	auipc	a2,0x5
ffffffffc020117e:	94660613          	addi	a2,a2,-1722 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201182:	0bb00593          	li	a1,187
ffffffffc0201186:	00005517          	auipc	a0,0x5
ffffffffc020118a:	95250513          	addi	a0,a0,-1710 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020118e:	abeff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(count == 0);
ffffffffc0201192:	00005697          	auipc	a3,0x5
ffffffffc0201196:	c6668693          	addi	a3,a3,-922 # ffffffffc0205df8 <commands+0xc10>
ffffffffc020119a:	00005617          	auipc	a2,0x5
ffffffffc020119e:	92660613          	addi	a2,a2,-1754 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02011a2:	12500593          	li	a1,293
ffffffffc02011a6:	00005517          	auipc	a0,0x5
ffffffffc02011aa:	93250513          	addi	a0,a0,-1742 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02011ae:	a9eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 0);
ffffffffc02011b2:	00005697          	auipc	a3,0x5
ffffffffc02011b6:	ae668693          	addi	a3,a3,-1306 # ffffffffc0205c98 <commands+0xab0>
ffffffffc02011ba:	00005617          	auipc	a2,0x5
ffffffffc02011be:	90660613          	addi	a2,a2,-1786 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02011c2:	11a00593          	li	a1,282
ffffffffc02011c6:	00005517          	auipc	a0,0x5
ffffffffc02011ca:	91250513          	addi	a0,a0,-1774 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02011ce:	a7eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d2:	00005697          	auipc	a3,0x5
ffffffffc02011d6:	a6668693          	addi	a3,a3,-1434 # ffffffffc0205c38 <commands+0xa50>
ffffffffc02011da:	00005617          	auipc	a2,0x5
ffffffffc02011de:	8e660613          	addi	a2,a2,-1818 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02011e2:	11800593          	li	a1,280
ffffffffc02011e6:	00005517          	auipc	a0,0x5
ffffffffc02011ea:	8f250513          	addi	a0,a0,-1806 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02011ee:	a5eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011f2:	00005697          	auipc	a3,0x5
ffffffffc02011f6:	a0668693          	addi	a3,a3,-1530 # ffffffffc0205bf8 <commands+0xa10>
ffffffffc02011fa:	00005617          	auipc	a2,0x5
ffffffffc02011fe:	8c660613          	addi	a2,a2,-1850 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201202:	0c100593          	li	a1,193
ffffffffc0201206:	00005517          	auipc	a0,0x5
ffffffffc020120a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020120e:	a3eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201212:	00005697          	auipc	a3,0x5
ffffffffc0201216:	ba668693          	addi	a3,a3,-1114 # ffffffffc0205db8 <commands+0xbd0>
ffffffffc020121a:	00005617          	auipc	a2,0x5
ffffffffc020121e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201222:	11200593          	li	a1,274
ffffffffc0201226:	00005517          	auipc	a0,0x5
ffffffffc020122a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020122e:	a1eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201232:	00005697          	auipc	a3,0x5
ffffffffc0201236:	b6668693          	addi	a3,a3,-1178 # ffffffffc0205d98 <commands+0xbb0>
ffffffffc020123a:	00005617          	auipc	a2,0x5
ffffffffc020123e:	88660613          	addi	a2,a2,-1914 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201242:	11000593          	li	a1,272
ffffffffc0201246:	00005517          	auipc	a0,0x5
ffffffffc020124a:	89250513          	addi	a0,a0,-1902 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020124e:	9feff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201252:	00005697          	auipc	a3,0x5
ffffffffc0201256:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0205d70 <commands+0xb88>
ffffffffc020125a:	00005617          	auipc	a2,0x5
ffffffffc020125e:	86660613          	addi	a2,a2,-1946 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201262:	10e00593          	li	a1,270
ffffffffc0201266:	00005517          	auipc	a0,0x5
ffffffffc020126a:	87250513          	addi	a0,a0,-1934 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020126e:	9deff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201272:	00005697          	auipc	a3,0x5
ffffffffc0201276:	ad668693          	addi	a3,a3,-1322 # ffffffffc0205d48 <commands+0xb60>
ffffffffc020127a:	00005617          	auipc	a2,0x5
ffffffffc020127e:	84660613          	addi	a2,a2,-1978 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201282:	10d00593          	li	a1,269
ffffffffc0201286:	00005517          	auipc	a0,0x5
ffffffffc020128a:	85250513          	addi	a0,a0,-1966 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020128e:	9beff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201292:	00005697          	auipc	a3,0x5
ffffffffc0201296:	aa668693          	addi	a3,a3,-1370 # ffffffffc0205d38 <commands+0xb50>
ffffffffc020129a:	00005617          	auipc	a2,0x5
ffffffffc020129e:	82660613          	addi	a2,a2,-2010 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02012a2:	10800593          	li	a1,264
ffffffffc02012a6:	00005517          	auipc	a0,0x5
ffffffffc02012aa:	83250513          	addi	a0,a0,-1998 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02012ae:	99eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012b2:	00005697          	auipc	a3,0x5
ffffffffc02012b6:	98668693          	addi	a3,a3,-1658 # ffffffffc0205c38 <commands+0xa50>
ffffffffc02012ba:	00005617          	auipc	a2,0x5
ffffffffc02012be:	80660613          	addi	a2,a2,-2042 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02012c2:	10700593          	li	a1,263
ffffffffc02012c6:	00005517          	auipc	a0,0x5
ffffffffc02012ca:	81250513          	addi	a0,a0,-2030 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02012ce:	97eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02012d2:	00005697          	auipc	a3,0x5
ffffffffc02012d6:	a4668693          	addi	a3,a3,-1466 # ffffffffc0205d18 <commands+0xb30>
ffffffffc02012da:	00004617          	auipc	a2,0x4
ffffffffc02012de:	7e660613          	addi	a2,a2,2022 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02012e2:	10600593          	li	a1,262
ffffffffc02012e6:	00004517          	auipc	a0,0x4
ffffffffc02012ea:	7f250513          	addi	a0,a0,2034 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02012ee:	95eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02012f2:	00005697          	auipc	a3,0x5
ffffffffc02012f6:	9f668693          	addi	a3,a3,-1546 # ffffffffc0205ce8 <commands+0xb00>
ffffffffc02012fa:	00004617          	auipc	a2,0x4
ffffffffc02012fe:	7c660613          	addi	a2,a2,1990 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201302:	10500593          	li	a1,261
ffffffffc0201306:	00004517          	auipc	a0,0x4
ffffffffc020130a:	7d250513          	addi	a0,a0,2002 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020130e:	93eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201312:	00005697          	auipc	a3,0x5
ffffffffc0201316:	9be68693          	addi	a3,a3,-1602 # ffffffffc0205cd0 <commands+0xae8>
ffffffffc020131a:	00004617          	auipc	a2,0x4
ffffffffc020131e:	7a660613          	addi	a2,a2,1958 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201322:	10400593          	li	a1,260
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	7b250513          	addi	a0,a0,1970 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020132e:	91eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201332:	00005697          	auipc	a3,0x5
ffffffffc0201336:	90668693          	addi	a3,a3,-1786 # ffffffffc0205c38 <commands+0xa50>
ffffffffc020133a:	00004617          	auipc	a2,0x4
ffffffffc020133e:	78660613          	addi	a2,a2,1926 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201342:	0fe00593          	li	a1,254
ffffffffc0201346:	00004517          	auipc	a0,0x4
ffffffffc020134a:	79250513          	addi	a0,a0,1938 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020134e:	8feff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(!PageProperty(p0));
ffffffffc0201352:	00005697          	auipc	a3,0x5
ffffffffc0201356:	96668693          	addi	a3,a3,-1690 # ffffffffc0205cb8 <commands+0xad0>
ffffffffc020135a:	00004617          	auipc	a2,0x4
ffffffffc020135e:	76660613          	addi	a2,a2,1894 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201362:	0f900593          	li	a1,249
ffffffffc0201366:	00004517          	auipc	a0,0x4
ffffffffc020136a:	77250513          	addi	a0,a0,1906 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020136e:	8deff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201372:	00005697          	auipc	a3,0x5
ffffffffc0201376:	a6668693          	addi	a3,a3,-1434 # ffffffffc0205dd8 <commands+0xbf0>
ffffffffc020137a:	00004617          	auipc	a2,0x4
ffffffffc020137e:	74660613          	addi	a2,a2,1862 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201382:	11700593          	li	a1,279
ffffffffc0201386:	00004517          	auipc	a0,0x4
ffffffffc020138a:	75250513          	addi	a0,a0,1874 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020138e:	8beff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(total == 0);
ffffffffc0201392:	00005697          	auipc	a3,0x5
ffffffffc0201396:	a7668693          	addi	a3,a3,-1418 # ffffffffc0205e08 <commands+0xc20>
ffffffffc020139a:	00004617          	auipc	a2,0x4
ffffffffc020139e:	72660613          	addi	a2,a2,1830 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02013a2:	12600593          	li	a1,294
ffffffffc02013a6:	00004517          	auipc	a0,0x4
ffffffffc02013aa:	73250513          	addi	a0,a0,1842 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02013ae:	89eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(total == nr_free_pages());
ffffffffc02013b2:	00004697          	auipc	a3,0x4
ffffffffc02013b6:	73e68693          	addi	a3,a3,1854 # ffffffffc0205af0 <commands+0x908>
ffffffffc02013ba:	00004617          	auipc	a2,0x4
ffffffffc02013be:	70660613          	addi	a2,a2,1798 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02013c2:	0f300593          	li	a1,243
ffffffffc02013c6:	00004517          	auipc	a0,0x4
ffffffffc02013ca:	71250513          	addi	a0,a0,1810 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02013ce:	87eff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013d2:	00004697          	auipc	a3,0x4
ffffffffc02013d6:	75e68693          	addi	a3,a3,1886 # ffffffffc0205b30 <commands+0x948>
ffffffffc02013da:	00004617          	auipc	a2,0x4
ffffffffc02013de:	6e660613          	addi	a2,a2,1766 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02013e2:	0ba00593          	li	a1,186
ffffffffc02013e6:	00004517          	auipc	a0,0x4
ffffffffc02013ea:	6f250513          	addi	a0,a0,1778 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc02013ee:	85eff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02013f2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02013f2:	1141                	addi	sp,sp,-16
ffffffffc02013f4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013f6:	18058063          	beqz	a1,ffffffffc0201576 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02013fa:	00359693          	slli	a3,a1,0x3
ffffffffc02013fe:	96ae                	add	a3,a3,a1
ffffffffc0201400:	068e                	slli	a3,a3,0x3
ffffffffc0201402:	96aa                	add	a3,a3,a0
ffffffffc0201404:	02d50d63          	beq	a0,a3,ffffffffc020143e <default_free_pages+0x4c>
ffffffffc0201408:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020140a:	8b85                	andi	a5,a5,1
ffffffffc020140c:	14079563          	bnez	a5,ffffffffc0201556 <default_free_pages+0x164>
ffffffffc0201410:	651c                	ld	a5,8(a0)
ffffffffc0201412:	8385                	srli	a5,a5,0x1
ffffffffc0201414:	8b85                	andi	a5,a5,1
ffffffffc0201416:	14079063          	bnez	a5,ffffffffc0201556 <default_free_pages+0x164>
ffffffffc020141a:	87aa                	mv	a5,a0
ffffffffc020141c:	a809                	j	ffffffffc020142e <default_free_pages+0x3c>
ffffffffc020141e:	6798                	ld	a4,8(a5)
ffffffffc0201420:	8b05                	andi	a4,a4,1
ffffffffc0201422:	12071a63          	bnez	a4,ffffffffc0201556 <default_free_pages+0x164>
ffffffffc0201426:	6798                	ld	a4,8(a5)
ffffffffc0201428:	8b09                	andi	a4,a4,2
ffffffffc020142a:	12071663          	bnez	a4,ffffffffc0201556 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020142e:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201432:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201436:	04878793          	addi	a5,a5,72
ffffffffc020143a:	fed792e3          	bne	a5,a3,ffffffffc020141e <default_free_pages+0x2c>
    base->property = n;
ffffffffc020143e:	2581                	sext.w	a1,a1
ffffffffc0201440:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201442:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201446:	4789                	li	a5,2
ffffffffc0201448:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020144c:	00015697          	auipc	a3,0x15
ffffffffc0201450:	09468693          	addi	a3,a3,148 # ffffffffc02164e0 <free_area>
ffffffffc0201454:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201456:	669c                	ld	a5,8(a3)
ffffffffc0201458:	9db9                	addw	a1,a1,a4
ffffffffc020145a:	00015717          	auipc	a4,0x15
ffffffffc020145e:	08b72b23          	sw	a1,150(a4) # ffffffffc02164f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201462:	08d78f63          	beq	a5,a3,ffffffffc0201500 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201466:	fe078713          	addi	a4,a5,-32
ffffffffc020146a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020146c:	4801                	li	a6,0
ffffffffc020146e:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201472:	00e56a63          	bltu	a0,a4,ffffffffc0201486 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201476:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201478:	02d70563          	beq	a4,a3,ffffffffc02014a2 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020147c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020147e:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201482:	fee57ae3          	bgeu	a0,a4,ffffffffc0201476 <default_free_pages+0x84>
ffffffffc0201486:	00080663          	beqz	a6,ffffffffc0201492 <default_free_pages+0xa0>
ffffffffc020148a:	00015817          	auipc	a6,0x15
ffffffffc020148e:	04b83b23          	sd	a1,86(a6) # ffffffffc02164e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201492:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201494:	e390                	sd	a2,0(a5)
ffffffffc0201496:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201498:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020149a:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020149c:	02d59163          	bne	a1,a3,ffffffffc02014be <default_free_pages+0xcc>
ffffffffc02014a0:	a091                	j	ffffffffc02014e4 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02014a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014a4:	f514                	sd	a3,40(a0)
ffffffffc02014a6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014a8:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02014aa:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014ac:	00d70563          	beq	a4,a3,ffffffffc02014b6 <default_free_pages+0xc4>
ffffffffc02014b0:	4805                	li	a6,1
ffffffffc02014b2:	87ba                	mv	a5,a4
ffffffffc02014b4:	b7e9                	j	ffffffffc020147e <default_free_pages+0x8c>
ffffffffc02014b6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02014b8:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02014ba:	02d78163          	beq	a5,a3,ffffffffc02014dc <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02014be:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02014c2:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02014c6:	02081713          	slli	a4,a6,0x20
ffffffffc02014ca:	9301                	srli	a4,a4,0x20
ffffffffc02014cc:	00371793          	slli	a5,a4,0x3
ffffffffc02014d0:	97ba                	add	a5,a5,a4
ffffffffc02014d2:	078e                	slli	a5,a5,0x3
ffffffffc02014d4:	97b2                	add	a5,a5,a2
ffffffffc02014d6:	02f50e63          	beq	a0,a5,ffffffffc0201512 <default_free_pages+0x120>
ffffffffc02014da:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02014dc:	fe078713          	addi	a4,a5,-32
ffffffffc02014e0:	00d78d63          	beq	a5,a3,ffffffffc02014fa <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02014e4:	4d0c                	lw	a1,24(a0)
ffffffffc02014e6:	02059613          	slli	a2,a1,0x20
ffffffffc02014ea:	9201                	srli	a2,a2,0x20
ffffffffc02014ec:	00361693          	slli	a3,a2,0x3
ffffffffc02014f0:	96b2                	add	a3,a3,a2
ffffffffc02014f2:	068e                	slli	a3,a3,0x3
ffffffffc02014f4:	96aa                	add	a3,a3,a0
ffffffffc02014f6:	04d70063          	beq	a4,a3,ffffffffc0201536 <default_free_pages+0x144>
}
ffffffffc02014fa:	60a2                	ld	ra,8(sp)
ffffffffc02014fc:	0141                	addi	sp,sp,16
ffffffffc02014fe:	8082                	ret
ffffffffc0201500:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201502:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201506:	e398                	sd	a4,0(a5)
ffffffffc0201508:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020150a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020150c:	f11c                	sd	a5,32(a0)
}
ffffffffc020150e:	0141                	addi	sp,sp,16
ffffffffc0201510:	8082                	ret
            p->property += base->property;
ffffffffc0201512:	4d1c                	lw	a5,24(a0)
ffffffffc0201514:	0107883b          	addw	a6,a5,a6
ffffffffc0201518:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020151c:	57f5                	li	a5,-3
ffffffffc020151e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201522:	02053803          	ld	a6,32(a0)
ffffffffc0201526:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0201528:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020152a:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020152e:	659c                	ld	a5,8(a1)
ffffffffc0201530:	01073023          	sd	a6,0(a4)
ffffffffc0201534:	b765                	j	ffffffffc02014dc <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201536:	ff87a703          	lw	a4,-8(a5)
ffffffffc020153a:	fe878693          	addi	a3,a5,-24
ffffffffc020153e:	9db9                	addw	a1,a1,a4
ffffffffc0201540:	cd0c                	sw	a1,24(a0)
ffffffffc0201542:	5775                	li	a4,-3
ffffffffc0201544:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201548:	6398                	ld	a4,0(a5)
ffffffffc020154a:	679c                	ld	a5,8(a5)
}
ffffffffc020154c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020154e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201550:	e398                	sd	a4,0(a5)
ffffffffc0201552:	0141                	addi	sp,sp,16
ffffffffc0201554:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201556:	00005697          	auipc	a3,0x5
ffffffffc020155a:	8c268693          	addi	a3,a3,-1854 # ffffffffc0205e18 <commands+0xc30>
ffffffffc020155e:	00004617          	auipc	a2,0x4
ffffffffc0201562:	56260613          	addi	a2,a2,1378 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201566:	08300593          	li	a1,131
ffffffffc020156a:	00004517          	auipc	a0,0x4
ffffffffc020156e:	56e50513          	addi	a0,a0,1390 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0201572:	edbfe0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(n > 0);
ffffffffc0201576:	00005697          	auipc	a3,0x5
ffffffffc020157a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0205e40 <commands+0xc58>
ffffffffc020157e:	00004617          	auipc	a2,0x4
ffffffffc0201582:	54260613          	addi	a2,a2,1346 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201586:	08000593          	li	a1,128
ffffffffc020158a:	00004517          	auipc	a0,0x4
ffffffffc020158e:	54e50513          	addi	a0,a0,1358 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc0201592:	ebbfe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201596 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201596:	cd51                	beqz	a0,ffffffffc0201632 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0201598:	00015597          	auipc	a1,0x15
ffffffffc020159c:	f4858593          	addi	a1,a1,-184 # ffffffffc02164e0 <free_area>
ffffffffc02015a0:	0105a803          	lw	a6,16(a1)
ffffffffc02015a4:	862a                	mv	a2,a0
ffffffffc02015a6:	02081793          	slli	a5,a6,0x20
ffffffffc02015aa:	9381                	srli	a5,a5,0x20
ffffffffc02015ac:	00a7ee63          	bltu	a5,a0,ffffffffc02015c8 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02015b0:	87ae                	mv	a5,a1
ffffffffc02015b2:	a801                	j	ffffffffc02015c2 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02015b4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02015b8:	02071693          	slli	a3,a4,0x20
ffffffffc02015bc:	9281                	srli	a3,a3,0x20
ffffffffc02015be:	00c6f763          	bgeu	a3,a2,ffffffffc02015cc <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02015c2:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02015c4:	feb798e3          	bne	a5,a1,ffffffffc02015b4 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02015c8:	4501                	li	a0,0
}
ffffffffc02015ca:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02015cc:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02015d0:	dd6d                	beqz	a0,ffffffffc02015ca <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02015d2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015d6:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02015da:	00060e1b          	sext.w	t3,a2
ffffffffc02015de:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02015e2:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02015e6:	02d67b63          	bgeu	a2,a3,ffffffffc020161c <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02015ea:	00361693          	slli	a3,a2,0x3
ffffffffc02015ee:	96b2                	add	a3,a3,a2
ffffffffc02015f0:	068e                	slli	a3,a3,0x3
ffffffffc02015f2:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02015f4:	41c7073b          	subw	a4,a4,t3
ffffffffc02015f8:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fa:	00868613          	addi	a2,a3,8
ffffffffc02015fe:	4709                	li	a4,2
ffffffffc0201600:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201604:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201608:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020160c:	0105a803          	lw	a6,16(a1)
ffffffffc0201610:	e310                	sd	a2,0(a4)
ffffffffc0201612:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201616:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0201618:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020161c:	41c8083b          	subw	a6,a6,t3
ffffffffc0201620:	00015717          	auipc	a4,0x15
ffffffffc0201624:	ed072823          	sw	a6,-304(a4) # ffffffffc02164f0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201628:	5775                	li	a4,-3
ffffffffc020162a:	17a1                	addi	a5,a5,-24
ffffffffc020162c:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201630:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201632:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201634:	00005697          	auipc	a3,0x5
ffffffffc0201638:	80c68693          	addi	a3,a3,-2036 # ffffffffc0205e40 <commands+0xc58>
ffffffffc020163c:	00004617          	auipc	a2,0x4
ffffffffc0201640:	48460613          	addi	a2,a2,1156 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201644:	06200593          	li	a1,98
ffffffffc0201648:	00004517          	auipc	a0,0x4
ffffffffc020164c:	49050513          	addi	a0,a0,1168 # ffffffffc0205ad8 <commands+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc0201650:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201652:	dfbfe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201656 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201656:	1141                	addi	sp,sp,-16
ffffffffc0201658:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020165a:	c1fd                	beqz	a1,ffffffffc0201740 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020165c:	00359693          	slli	a3,a1,0x3
ffffffffc0201660:	96ae                	add	a3,a3,a1
ffffffffc0201662:	068e                	slli	a3,a3,0x3
ffffffffc0201664:	96aa                	add	a3,a3,a0
ffffffffc0201666:	02d50463          	beq	a0,a3,ffffffffc020168e <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020166a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020166c:	87aa                	mv	a5,a0
ffffffffc020166e:	8b05                	andi	a4,a4,1
ffffffffc0201670:	e709                	bnez	a4,ffffffffc020167a <default_init_memmap+0x24>
ffffffffc0201672:	a07d                	j	ffffffffc0201720 <default_init_memmap+0xca>
ffffffffc0201674:	6798                	ld	a4,8(a5)
ffffffffc0201676:	8b05                	andi	a4,a4,1
ffffffffc0201678:	c745                	beqz	a4,ffffffffc0201720 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020167a:	0007ac23          	sw	zero,24(a5)
ffffffffc020167e:	0007b423          	sd	zero,8(a5)
ffffffffc0201682:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201686:	04878793          	addi	a5,a5,72
ffffffffc020168a:	fed795e3          	bne	a5,a3,ffffffffc0201674 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc020168e:	2581                	sext.w	a1,a1
ffffffffc0201690:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201692:	4789                	li	a5,2
ffffffffc0201694:	00850713          	addi	a4,a0,8
ffffffffc0201698:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020169c:	00015697          	auipc	a3,0x15
ffffffffc02016a0:	e4468693          	addi	a3,a3,-444 # ffffffffc02164e0 <free_area>
ffffffffc02016a4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016a6:	669c                	ld	a5,8(a3)
ffffffffc02016a8:	9db9                	addw	a1,a1,a4
ffffffffc02016aa:	00015717          	auipc	a4,0x15
ffffffffc02016ae:	e4b72323          	sw	a1,-442(a4) # ffffffffc02164f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016b2:	04d78a63          	beq	a5,a3,ffffffffc0201706 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02016b6:	fe078713          	addi	a4,a5,-32
ffffffffc02016ba:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016bc:	4801                	li	a6,0
ffffffffc02016be:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02016c2:	00e56a63          	bltu	a0,a4,ffffffffc02016d6 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02016c6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016c8:	02d70563          	beq	a4,a3,ffffffffc02016f2 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016cc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016ce:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02016d2:	fee57ae3          	bgeu	a0,a4,ffffffffc02016c6 <default_init_memmap+0x70>
ffffffffc02016d6:	00080663          	beqz	a6,ffffffffc02016e2 <default_init_memmap+0x8c>
ffffffffc02016da:	00015717          	auipc	a4,0x15
ffffffffc02016de:	e0b73323          	sd	a1,-506(a4) # ffffffffc02164e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e2:	6398                	ld	a4,0(a5)
}
ffffffffc02016e4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016e6:	e390                	sd	a2,0(a5)
ffffffffc02016e8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02016ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02016ec:	f118                	sd	a4,32(a0)
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016f2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016f4:	f514                	sd	a3,40(a0)
ffffffffc02016f6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016f8:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02016fa:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016fc:	00d70e63          	beq	a4,a3,ffffffffc0201718 <default_init_memmap+0xc2>
ffffffffc0201700:	4805                	li	a6,1
ffffffffc0201702:	87ba                	mv	a5,a4
ffffffffc0201704:	b7e9                	j	ffffffffc02016ce <default_init_memmap+0x78>
}
ffffffffc0201706:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201708:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020170c:	e398                	sd	a4,0(a5)
ffffffffc020170e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201710:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201712:	f11c                	sd	a5,32(a0)
}
ffffffffc0201714:	0141                	addi	sp,sp,16
ffffffffc0201716:	8082                	ret
ffffffffc0201718:	60a2                	ld	ra,8(sp)
ffffffffc020171a:	e290                	sd	a2,0(a3)
ffffffffc020171c:	0141                	addi	sp,sp,16
ffffffffc020171e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201720:	00004697          	auipc	a3,0x4
ffffffffc0201724:	72868693          	addi	a3,a3,1832 # ffffffffc0205e48 <commands+0xc60>
ffffffffc0201728:	00004617          	auipc	a2,0x4
ffffffffc020172c:	39860613          	addi	a2,a2,920 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201730:	04900593          	li	a1,73
ffffffffc0201734:	00004517          	auipc	a0,0x4
ffffffffc0201738:	3a450513          	addi	a0,a0,932 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020173c:	d11fe0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(n > 0);
ffffffffc0201740:	00004697          	auipc	a3,0x4
ffffffffc0201744:	70068693          	addi	a3,a3,1792 # ffffffffc0205e40 <commands+0xc58>
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	37860613          	addi	a2,a2,888 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0201750:	04600593          	li	a1,70
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	38450513          	addi	a0,a0,900 # ffffffffc0205ad8 <commands+0x8f0>
ffffffffc020175c:	cf1fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201760 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201760:	c125                	beqz	a0,ffffffffc02017c0 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201762:	e1a5                	bnez	a1,ffffffffc02017c2 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201764:	100027f3          	csrr	a5,sstatus
ffffffffc0201768:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020176a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020176c:	e3bd                	bnez	a5,ffffffffc02017d2 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020176e:	0000a797          	auipc	a5,0xa
ffffffffc0201772:	8e278793          	addi	a5,a5,-1822 # ffffffffc020b050 <slobfree>
ffffffffc0201776:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201778:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020177a:	00a7fa63          	bgeu	a5,a0,ffffffffc020178e <slob_free+0x2e>
ffffffffc020177e:	00e56c63          	bltu	a0,a4,ffffffffc0201796 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201782:	00e7fa63          	bgeu	a5,a4,ffffffffc0201796 <slob_free+0x36>
    return 0;
ffffffffc0201786:	87ba                	mv	a5,a4
ffffffffc0201788:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020178a:	fea7eae3          	bltu	a5,a0,ffffffffc020177e <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020178e:	fee7ece3          	bltu	a5,a4,ffffffffc0201786 <slob_free+0x26>
ffffffffc0201792:	fee57ae3          	bgeu	a0,a4,ffffffffc0201786 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201796:	4110                	lw	a2,0(a0)
ffffffffc0201798:	00461693          	slli	a3,a2,0x4
ffffffffc020179c:	96aa                	add	a3,a3,a0
ffffffffc020179e:	08d70b63          	beq	a4,a3,ffffffffc0201834 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02017a2:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02017a4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017a6:	00469713          	slli	a4,a3,0x4
ffffffffc02017aa:	973e                	add	a4,a4,a5
ffffffffc02017ac:	08e50f63          	beq	a0,a4,ffffffffc020184a <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02017b0:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02017b2:	0000a717          	auipc	a4,0xa
ffffffffc02017b6:	88f73f23          	sd	a5,-1890(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc02017ba:	c199                	beqz	a1,ffffffffc02017c0 <slob_free+0x60>
        intr_enable();
ffffffffc02017bc:	e0ffe06f          	j	ffffffffc02005ca <intr_enable>
ffffffffc02017c0:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02017c2:	05bd                	addi	a1,a1,15
ffffffffc02017c4:	8191                	srli	a1,a1,0x4
ffffffffc02017c6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017c8:	100027f3          	csrr	a5,sstatus
ffffffffc02017cc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02017ce:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017d0:	dfd9                	beqz	a5,ffffffffc020176e <slob_free+0xe>
{
ffffffffc02017d2:	1101                	addi	sp,sp,-32
ffffffffc02017d4:	e42a                	sd	a0,8(sp)
ffffffffc02017d6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02017d8:	df9fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017dc:	0000a797          	auipc	a5,0xa
ffffffffc02017e0:	87478793          	addi	a5,a5,-1932 # ffffffffc020b050 <slobfree>
ffffffffc02017e4:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02017e6:	6522                	ld	a0,8(sp)
ffffffffc02017e8:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017ea:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017ec:	00a7fa63          	bgeu	a5,a0,ffffffffc0201800 <slob_free+0xa0>
ffffffffc02017f0:	00e56c63          	bltu	a0,a4,ffffffffc0201808 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017f4:	00e7fa63          	bgeu	a5,a4,ffffffffc0201808 <slob_free+0xa8>
    return 0;
ffffffffc02017f8:	87ba                	mv	a5,a4
ffffffffc02017fa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017fc:	fea7eae3          	bltu	a5,a0,ffffffffc02017f0 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201800:	fee7ece3          	bltu	a5,a4,ffffffffc02017f8 <slob_free+0x98>
ffffffffc0201804:	fee57ae3          	bgeu	a0,a4,ffffffffc02017f8 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201808:	4110                	lw	a2,0(a0)
ffffffffc020180a:	00461693          	slli	a3,a2,0x4
ffffffffc020180e:	96aa                	add	a3,a3,a0
ffffffffc0201810:	04d70763          	beq	a4,a3,ffffffffc020185e <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201814:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201816:	4394                	lw	a3,0(a5)
ffffffffc0201818:	00469713          	slli	a4,a3,0x4
ffffffffc020181c:	973e                	add	a4,a4,a5
ffffffffc020181e:	04e50663          	beq	a0,a4,ffffffffc020186a <slob_free+0x10a>
		cur->next = b;
ffffffffc0201822:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201824:	0000a717          	auipc	a4,0xa
ffffffffc0201828:	82f73623          	sd	a5,-2004(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc020182c:	e58d                	bnez	a1,ffffffffc0201856 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020182e:	60e2                	ld	ra,24(sp)
ffffffffc0201830:	6105                	addi	sp,sp,32
ffffffffc0201832:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201834:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201836:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201838:	9e35                	addw	a2,a2,a3
ffffffffc020183a:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc020183c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020183e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201840:	00469713          	slli	a4,a3,0x4
ffffffffc0201844:	973e                	add	a4,a4,a5
ffffffffc0201846:	f6e515e3          	bne	a0,a4,ffffffffc02017b0 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020184a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020184c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020184e:	9eb9                	addw	a3,a3,a4
ffffffffc0201850:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201852:	e790                	sd	a2,8(a5)
ffffffffc0201854:	bfb9                	j	ffffffffc02017b2 <slob_free+0x52>
}
ffffffffc0201856:	60e2                	ld	ra,24(sp)
ffffffffc0201858:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020185a:	d71fe06f          	j	ffffffffc02005ca <intr_enable>
		b->units += cur->next->units;
ffffffffc020185e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201860:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201862:	9e35                	addw	a2,a2,a3
ffffffffc0201864:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201866:	e518                	sd	a4,8(a0)
ffffffffc0201868:	b77d                	j	ffffffffc0201816 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020186a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020186c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020186e:	9eb9                	addw	a3,a3,a4
ffffffffc0201870:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201872:	e790                	sd	a2,8(a5)
ffffffffc0201874:	bf45                	j	ffffffffc0201824 <slob_free+0xc4>

ffffffffc0201876 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201876:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201878:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020187a:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020187e:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201880:	38a000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
  if(!page)
ffffffffc0201884:	c531                	beqz	a0,ffffffffc02018d0 <__slob_get_free_pages.isra.0+0x5a>
    return page - pages + nbase;
ffffffffc0201886:	00015797          	auipc	a5,0x15
ffffffffc020188a:	c8a78793          	addi	a5,a5,-886 # ffffffffc0216510 <pages>
ffffffffc020188e:	6394                	ld	a3,0(a5)
ffffffffc0201890:	00004797          	auipc	a5,0x4
ffffffffc0201894:	21878793          	addi	a5,a5,536 # ffffffffc0205aa8 <commands+0x8c0>
    return KADDR(page2pa(page));
ffffffffc0201898:	00015717          	auipc	a4,0x15
ffffffffc020189c:	c0870713          	addi	a4,a4,-1016 # ffffffffc02164a0 <npage>
    return page - pages + nbase;
ffffffffc02018a0:	8d15                	sub	a0,a0,a3
ffffffffc02018a2:	6394                	ld	a3,0(a5)
ffffffffc02018a4:	850d                	srai	a0,a0,0x3
ffffffffc02018a6:	00006797          	auipc	a5,0x6
ffffffffc02018aa:	95a78793          	addi	a5,a5,-1702 # ffffffffc0207200 <nbase>
ffffffffc02018ae:	02d50533          	mul	a0,a0,a3
ffffffffc02018b2:	6394                	ld	a3,0(a5)
    return KADDR(page2pa(page));
ffffffffc02018b4:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02018b6:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02018b8:	00c51793          	slli	a5,a0,0xc
ffffffffc02018bc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02018be:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02018c0:	00e7fb63          	bgeu	a5,a4,ffffffffc02018d6 <__slob_get_free_pages.isra.0+0x60>
ffffffffc02018c4:	00015797          	auipc	a5,0x15
ffffffffc02018c8:	c3c78793          	addi	a5,a5,-964 # ffffffffc0216500 <va_pa_offset>
ffffffffc02018cc:	6394                	ld	a3,0(a5)
ffffffffc02018ce:	9536                	add	a0,a0,a3
}
ffffffffc02018d0:	60a2                	ld	ra,8(sp)
ffffffffc02018d2:	0141                	addi	sp,sp,16
ffffffffc02018d4:	8082                	ret
ffffffffc02018d6:	86aa                	mv	a3,a0
ffffffffc02018d8:	00004617          	auipc	a2,0x4
ffffffffc02018dc:	5d060613          	addi	a2,a2,1488 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc02018e0:	06900593          	li	a1,105
ffffffffc02018e4:	00004517          	auipc	a0,0x4
ffffffffc02018e8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02018ec:	b61fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02018f0 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02018f0:	1101                	addi	sp,sp,-32
ffffffffc02018f2:	ec06                	sd	ra,24(sp)
ffffffffc02018f4:	e822                	sd	s0,16(sp)
ffffffffc02018f6:	e426                	sd	s1,8(sp)
ffffffffc02018f8:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02018fa:	01050713          	addi	a4,a0,16
ffffffffc02018fe:	6785                	lui	a5,0x1
ffffffffc0201900:	0cf77563          	bgeu	a4,a5,ffffffffc02019ca <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201904:	00f50493          	addi	s1,a0,15
ffffffffc0201908:	8091                	srli	s1,s1,0x4
ffffffffc020190a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020190c:	10002673          	csrr	a2,sstatus
ffffffffc0201910:	8a09                	andi	a2,a2,2
ffffffffc0201912:	e64d                	bnez	a2,ffffffffc02019bc <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0201914:	00009917          	auipc	s2,0x9
ffffffffc0201918:	73c90913          	addi	s2,s2,1852 # ffffffffc020b050 <slobfree>
ffffffffc020191c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201920:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201922:	4398                	lw	a4,0(a5)
ffffffffc0201924:	0a975063          	bge	a4,s1,ffffffffc02019c4 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0201928:	00d78b63          	beq	a5,a3,ffffffffc020193e <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020192c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020192e:	4018                	lw	a4,0(s0)
ffffffffc0201930:	02975a63          	bge	a4,s1,ffffffffc0201964 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0201934:	00093683          	ld	a3,0(s2)
ffffffffc0201938:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc020193a:	fed799e3          	bne	a5,a3,ffffffffc020192c <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc020193e:	e225                	bnez	a2,ffffffffc020199e <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201940:	4501                	li	a0,0
ffffffffc0201942:	f35ff0ef          	jal	ra,ffffffffc0201876 <__slob_get_free_pages.isra.0>
ffffffffc0201946:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201948:	cd15                	beqz	a0,ffffffffc0201984 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc020194a:	6585                	lui	a1,0x1
ffffffffc020194c:	e15ff0ef          	jal	ra,ffffffffc0201760 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201950:	10002673          	csrr	a2,sstatus
ffffffffc0201954:	8a09                	andi	a2,a2,2
ffffffffc0201956:	ee15                	bnez	a2,ffffffffc0201992 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0201958:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020195c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020195e:	4018                	lw	a4,0(s0)
ffffffffc0201960:	fc974ae3          	blt	a4,s1,ffffffffc0201934 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201964:	04e48963          	beq	s1,a4,ffffffffc02019b6 <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0201968:	00449693          	slli	a3,s1,0x4
ffffffffc020196c:	96a2                	add	a3,a3,s0
ffffffffc020196e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201970:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201972:	9f05                	subw	a4,a4,s1
ffffffffc0201974:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201976:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201978:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020197a:	00009717          	auipc	a4,0x9
ffffffffc020197e:	6cf73b23          	sd	a5,1750(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201982:	e20d                	bnez	a2,ffffffffc02019a4 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0201984:	8522                	mv	a0,s0
ffffffffc0201986:	60e2                	ld	ra,24(sp)
ffffffffc0201988:	6442                	ld	s0,16(sp)
ffffffffc020198a:	64a2                	ld	s1,8(sp)
ffffffffc020198c:	6902                	ld	s2,0(sp)
ffffffffc020198e:	6105                	addi	sp,sp,32
ffffffffc0201990:	8082                	ret
        intr_disable();
ffffffffc0201992:	c3ffe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0201996:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201998:	00093783          	ld	a5,0(s2)
ffffffffc020199c:	b7c1                	j	ffffffffc020195c <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc020199e:	c2dfe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc02019a2:	bf79                	j	ffffffffc0201940 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc02019a4:	c27fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc02019a8:	8522                	mv	a0,s0
ffffffffc02019aa:	60e2                	ld	ra,24(sp)
ffffffffc02019ac:	6442                	ld	s0,16(sp)
ffffffffc02019ae:	64a2                	ld	s1,8(sp)
ffffffffc02019b0:	6902                	ld	s2,0(sp)
ffffffffc02019b2:	6105                	addi	sp,sp,32
ffffffffc02019b4:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019b6:	6418                	ld	a4,8(s0)
ffffffffc02019b8:	e798                	sd	a4,8(a5)
ffffffffc02019ba:	b7c1                	j	ffffffffc020197a <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc02019bc:	c15fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc02019c0:	4605                	li	a2,1
ffffffffc02019c2:	bf89                	j	ffffffffc0201914 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019c4:	843e                	mv	s0,a5
ffffffffc02019c6:	87b6                	mv	a5,a3
ffffffffc02019c8:	bf71                	j	ffffffffc0201964 <slob_alloc.isra.1.constprop.3+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019ca:	00004697          	auipc	a3,0x4
ffffffffc02019ce:	57e68693          	addi	a3,a3,1406 # ffffffffc0205f48 <default_pmm_manager+0xf0>
ffffffffc02019d2:	00004617          	auipc	a2,0x4
ffffffffc02019d6:	0ee60613          	addi	a2,a2,238 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02019da:	06300593          	li	a1,99
ffffffffc02019de:	00004517          	auipc	a0,0x4
ffffffffc02019e2:	58a50513          	addi	a0,a0,1418 # ffffffffc0205f68 <default_pmm_manager+0x110>
ffffffffc02019e6:	a67fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02019ea <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02019ea:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02019ec:	00004517          	auipc	a0,0x4
ffffffffc02019f0:	59450513          	addi	a0,a0,1428 # ffffffffc0205f80 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc02019f4:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02019f6:	f98fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02019fa:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019fc:	00004517          	auipc	a0,0x4
ffffffffc0201a00:	52c50513          	addi	a0,a0,1324 # ffffffffc0205f28 <default_pmm_manager+0xd0>
}
ffffffffc0201a04:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a06:	f88fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201a0a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a0a:	1101                	addi	sp,sp,-32
ffffffffc0201a0c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a0e:	6905                	lui	s2,0x1
{
ffffffffc0201a10:	e822                	sd	s0,16(sp)
ffffffffc0201a12:	ec06                	sd	ra,24(sp)
ffffffffc0201a14:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a16:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201a1a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a1c:	04a7fc63          	bgeu	a5,a0,ffffffffc0201a74 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a20:	4561                	li	a0,24
ffffffffc0201a22:	ecfff0ef          	jal	ra,ffffffffc02018f0 <slob_alloc.isra.1.constprop.3>
ffffffffc0201a26:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a28:	cd21                	beqz	a0,ffffffffc0201a80 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201a2a:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a2e:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a30:	00f95763          	bge	s2,a5,ffffffffc0201a3e <kmalloc+0x34>
ffffffffc0201a34:	6705                	lui	a4,0x1
ffffffffc0201a36:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a38:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a3a:	fef74ee3          	blt	a4,a5,ffffffffc0201a36 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a3e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a40:	e37ff0ef          	jal	ra,ffffffffc0201876 <__slob_get_free_pages.isra.0>
ffffffffc0201a44:	e488                	sd	a0,8(s1)
ffffffffc0201a46:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a48:	c935                	beqz	a0,ffffffffc0201abc <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a4a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a4e:	8b89                	andi	a5,a5,2
ffffffffc0201a50:	e3a1                	bnez	a5,ffffffffc0201a90 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201a52:	00015797          	auipc	a5,0x15
ffffffffc0201a56:	a3e78793          	addi	a5,a5,-1474 # ffffffffc0216490 <bigblocks>
ffffffffc0201a5a:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a5c:	00015717          	auipc	a4,0x15
ffffffffc0201a60:	a2973a23          	sd	s1,-1484(a4) # ffffffffc0216490 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a64:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a66:	8522                	mv	a0,s0
ffffffffc0201a68:	60e2                	ld	ra,24(sp)
ffffffffc0201a6a:	6442                	ld	s0,16(sp)
ffffffffc0201a6c:	64a2                	ld	s1,8(sp)
ffffffffc0201a6e:	6902                	ld	s2,0(sp)
ffffffffc0201a70:	6105                	addi	sp,sp,32
ffffffffc0201a72:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a74:	0541                	addi	a0,a0,16
ffffffffc0201a76:	e7bff0ef          	jal	ra,ffffffffc02018f0 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a7a:	01050413          	addi	s0,a0,16
ffffffffc0201a7e:	f565                	bnez	a0,ffffffffc0201a66 <kmalloc+0x5c>
ffffffffc0201a80:	4401                	li	s0,0
}
ffffffffc0201a82:	8522                	mv	a0,s0
ffffffffc0201a84:	60e2                	ld	ra,24(sp)
ffffffffc0201a86:	6442                	ld	s0,16(sp)
ffffffffc0201a88:	64a2                	ld	s1,8(sp)
ffffffffc0201a8a:	6902                	ld	s2,0(sp)
ffffffffc0201a8c:	6105                	addi	sp,sp,32
ffffffffc0201a8e:	8082                	ret
        intr_disable();
ffffffffc0201a90:	b41fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a94:	00015797          	auipc	a5,0x15
ffffffffc0201a98:	9fc78793          	addi	a5,a5,-1540 # ffffffffc0216490 <bigblocks>
ffffffffc0201a9c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a9e:	00015717          	auipc	a4,0x15
ffffffffc0201aa2:	9e973923          	sd	s1,-1550(a4) # ffffffffc0216490 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201aa6:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201aa8:	b23fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201aac:	6480                	ld	s0,8(s1)
}
ffffffffc0201aae:	60e2                	ld	ra,24(sp)
ffffffffc0201ab0:	64a2                	ld	s1,8(sp)
ffffffffc0201ab2:	8522                	mv	a0,s0
ffffffffc0201ab4:	6442                	ld	s0,16(sp)
ffffffffc0201ab6:	6902                	ld	s2,0(sp)
ffffffffc0201ab8:	6105                	addi	sp,sp,32
ffffffffc0201aba:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201abc:	45e1                	li	a1,24
ffffffffc0201abe:	8526                	mv	a0,s1
ffffffffc0201ac0:	ca1ff0ef          	jal	ra,ffffffffc0201760 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ac4:	b74d                	j	ffffffffc0201a66 <kmalloc+0x5c>

ffffffffc0201ac6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ac6:	0e050463          	beqz	a0,ffffffffc0201bae <kfree+0xe8>
{
ffffffffc0201aca:	1101                	addi	sp,sp,-32
ffffffffc0201acc:	e426                	sd	s1,8(sp)
ffffffffc0201ace:	ec06                	sd	ra,24(sp)
ffffffffc0201ad0:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201ad2:	03451793          	slli	a5,a0,0x34
ffffffffc0201ad6:	84aa                	mv	s1,a0
ffffffffc0201ad8:	eb8d                	bnez	a5,ffffffffc0201b0a <kfree+0x44>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ada:	100027f3          	csrr	a5,sstatus
ffffffffc0201ade:	8b89                	andi	a5,a5,2
ffffffffc0201ae0:	efd1                	bnez	a5,ffffffffc0201b7c <kfree+0xb6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ae2:	00015797          	auipc	a5,0x15
ffffffffc0201ae6:	9ae78793          	addi	a5,a5,-1618 # ffffffffc0216490 <bigblocks>
ffffffffc0201aea:	6394                	ld	a3,0(a5)
ffffffffc0201aec:	ce99                	beqz	a3,ffffffffc0201b0a <kfree+0x44>
			if (bb->pages == block) {
ffffffffc0201aee:	669c                	ld	a5,8(a3)
ffffffffc0201af0:	6a80                	ld	s0,16(a3)
ffffffffc0201af2:	0af50f63          	beq	a0,a5,ffffffffc0201bb0 <kfree+0xea>
    return 0;
ffffffffc0201af6:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201af8:	c801                	beqz	s0,ffffffffc0201b08 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201afa:	6418                	ld	a4,8(s0)
ffffffffc0201afc:	681c                	ld	a5,16(s0)
ffffffffc0201afe:	00970e63          	beq	a4,s1,ffffffffc0201b1a <kfree+0x54>
ffffffffc0201b02:	86a2                	mv	a3,s0
ffffffffc0201b04:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b06:	f875                	bnez	s0,ffffffffc0201afa <kfree+0x34>
    if (flag) {
ffffffffc0201b08:	ea41                	bnez	a2,ffffffffc0201b98 <kfree+0xd2>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b0a:	6442                	ld	s0,16(sp)
ffffffffc0201b0c:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b0e:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201b12:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b14:	4581                	li	a1,0
}
ffffffffc0201b16:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b18:	b1a1                	j	ffffffffc0201760 <slob_free>
				*last = bb->next;
ffffffffc0201b1a:	ea9c                	sd	a5,16(a3)
ffffffffc0201b1c:	e651                	bnez	a2,ffffffffc0201ba8 <kfree+0xe2>
    return pa2page(PADDR(kva));
ffffffffc0201b1e:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b22:	4018                	lw	a4,0(s0)
ffffffffc0201b24:	08f4ec63          	bltu	s1,a5,ffffffffc0201bbc <kfree+0xf6>
ffffffffc0201b28:	00015797          	auipc	a5,0x15
ffffffffc0201b2c:	9d878793          	addi	a5,a5,-1576 # ffffffffc0216500 <va_pa_offset>
ffffffffc0201b30:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201b32:	00015797          	auipc	a5,0x15
ffffffffc0201b36:	96e78793          	addi	a5,a5,-1682 # ffffffffc02164a0 <npage>
ffffffffc0201b3a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201b3c:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b3e:	80b1                	srli	s1,s1,0xc
ffffffffc0201b40:	08f4fb63          	bgeu	s1,a5,ffffffffc0201bd6 <kfree+0x110>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b44:	00005797          	auipc	a5,0x5
ffffffffc0201b48:	6bc78793          	addi	a5,a5,1724 # ffffffffc0207200 <nbase>
ffffffffc0201b4c:	639c                	ld	a5,0(a5)
ffffffffc0201b4e:	00015697          	auipc	a3,0x15
ffffffffc0201b52:	9c268693          	addi	a3,a3,-1598 # ffffffffc0216510 <pages>
ffffffffc0201b56:	6288                	ld	a0,0(a3)
ffffffffc0201b58:	8c9d                	sub	s1,s1,a5
ffffffffc0201b5a:	00349793          	slli	a5,s1,0x3
ffffffffc0201b5e:	94be                	add	s1,s1,a5
ffffffffc0201b60:	048e                	slli	s1,s1,0x3
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b62:	4585                	li	a1,1
ffffffffc0201b64:	9526                	add	a0,a0,s1
ffffffffc0201b66:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b6a:	128000ef          	jal	ra,ffffffffc0201c92 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b6e:	8522                	mv	a0,s0
}
ffffffffc0201b70:	6442                	ld	s0,16(sp)
ffffffffc0201b72:	60e2                	ld	ra,24(sp)
ffffffffc0201b74:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b76:	45e1                	li	a1,24
}
ffffffffc0201b78:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b7a:	b6dd                	j	ffffffffc0201760 <slob_free>
        intr_disable();
ffffffffc0201b7c:	a55fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b80:	00015797          	auipc	a5,0x15
ffffffffc0201b84:	91078793          	addi	a5,a5,-1776 # ffffffffc0216490 <bigblocks>
ffffffffc0201b88:	6394                	ld	a3,0(a5)
ffffffffc0201b8a:	c699                	beqz	a3,ffffffffc0201b98 <kfree+0xd2>
			if (bb->pages == block) {
ffffffffc0201b8c:	669c                	ld	a5,8(a3)
ffffffffc0201b8e:	6a80                	ld	s0,16(a3)
ffffffffc0201b90:	00f48763          	beq	s1,a5,ffffffffc0201b9e <kfree+0xd8>
        return 1;
ffffffffc0201b94:	4605                	li	a2,1
ffffffffc0201b96:	b78d                	j	ffffffffc0201af8 <kfree+0x32>
        intr_enable();
ffffffffc0201b98:	a33fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201b9c:	b7bd                	j	ffffffffc0201b0a <kfree+0x44>
				*last = bb->next;
ffffffffc0201b9e:	00015797          	auipc	a5,0x15
ffffffffc0201ba2:	8e87b923          	sd	s0,-1806(a5) # ffffffffc0216490 <bigblocks>
ffffffffc0201ba6:	8436                	mv	s0,a3
ffffffffc0201ba8:	a23fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201bac:	bf8d                	j	ffffffffc0201b1e <kfree+0x58>
ffffffffc0201bae:	8082                	ret
ffffffffc0201bb0:	00015797          	auipc	a5,0x15
ffffffffc0201bb4:	8e87b023          	sd	s0,-1824(a5) # ffffffffc0216490 <bigblocks>
ffffffffc0201bb8:	8436                	mv	s0,a3
ffffffffc0201bba:	b795                	j	ffffffffc0201b1e <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201bbc:	86a6                	mv	a3,s1
ffffffffc0201bbe:	00004617          	auipc	a2,0x4
ffffffffc0201bc2:	32260613          	addi	a2,a2,802 # ffffffffc0205ee0 <default_pmm_manager+0x88>
ffffffffc0201bc6:	06e00593          	li	a1,110
ffffffffc0201bca:	00004517          	auipc	a0,0x4
ffffffffc0201bce:	30650513          	addi	a0,a0,774 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0201bd2:	87bfe0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201bd6:	00004617          	auipc	a2,0x4
ffffffffc0201bda:	33260613          	addi	a2,a2,818 # ffffffffc0205f08 <default_pmm_manager+0xb0>
ffffffffc0201bde:	06200593          	li	a1,98
ffffffffc0201be2:	00004517          	auipc	a0,0x4
ffffffffc0201be6:	2ee50513          	addi	a0,a0,750 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0201bea:	863fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201bee <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201bee:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201bf0:	00004617          	auipc	a2,0x4
ffffffffc0201bf4:	31860613          	addi	a2,a2,792 # ffffffffc0205f08 <default_pmm_manager+0xb0>
ffffffffc0201bf8:	06200593          	li	a1,98
ffffffffc0201bfc:	00004517          	auipc	a0,0x4
ffffffffc0201c00:	2d450513          	addi	a0,a0,724 # ffffffffc0205ed0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201c04:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c06:	847fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201c0a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201c0a:	715d                	addi	sp,sp,-80
ffffffffc0201c0c:	e0a2                	sd	s0,64(sp)
ffffffffc0201c0e:	fc26                	sd	s1,56(sp)
ffffffffc0201c10:	f84a                	sd	s2,48(sp)
ffffffffc0201c12:	f44e                	sd	s3,40(sp)
ffffffffc0201c14:	f052                	sd	s4,32(sp)
ffffffffc0201c16:	ec56                	sd	s5,24(sp)
ffffffffc0201c18:	e486                	sd	ra,72(sp)
ffffffffc0201c1a:	842a                	mv	s0,a0
ffffffffc0201c1c:	00015497          	auipc	s1,0x15
ffffffffc0201c20:	8dc48493          	addi	s1,s1,-1828 # ffffffffc02164f8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c24:	4985                	li	s3,1
ffffffffc0201c26:	00015a17          	auipc	s4,0x15
ffffffffc0201c2a:	88aa0a13          	addi	s4,s4,-1910 # ffffffffc02164b0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c2e:	0005091b          	sext.w	s2,a0
ffffffffc0201c32:	00015a97          	auipc	s5,0x15
ffffffffc0201c36:	9bea8a93          	addi	s5,s5,-1602 # ffffffffc02165f0 <check_mm_struct>
ffffffffc0201c3a:	a00d                	j	ffffffffc0201c5c <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c3c:	609c                	ld	a5,0(s1)
ffffffffc0201c3e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c40:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c42:	4601                	li	a2,0
ffffffffc0201c44:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c46:	ed0d                	bnez	a0,ffffffffc0201c80 <alloc_pages+0x76>
ffffffffc0201c48:	0289ec63          	bltu	s3,s0,ffffffffc0201c80 <alloc_pages+0x76>
ffffffffc0201c4c:	000a2783          	lw	a5,0(s4)
ffffffffc0201c50:	2781                	sext.w	a5,a5
ffffffffc0201c52:	c79d                	beqz	a5,ffffffffc0201c80 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c54:	000ab503          	ld	a0,0(s5)
ffffffffc0201c58:	79c010ef          	jal	ra,ffffffffc02033f4 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c5c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c60:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c62:	8522                	mv	a0,s0
ffffffffc0201c64:	dfe1                	beqz	a5,ffffffffc0201c3c <alloc_pages+0x32>
        intr_disable();
ffffffffc0201c66:	96bfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0201c6a:	609c                	ld	a5,0(s1)
ffffffffc0201c6c:	8522                	mv	a0,s0
ffffffffc0201c6e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c70:	9782                	jalr	a5
ffffffffc0201c72:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c74:	957fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201c78:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c7a:	4601                	li	a2,0
ffffffffc0201c7c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c7e:	d569                	beqz	a0,ffffffffc0201c48 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c80:	60a6                	ld	ra,72(sp)
ffffffffc0201c82:	6406                	ld	s0,64(sp)
ffffffffc0201c84:	74e2                	ld	s1,56(sp)
ffffffffc0201c86:	7942                	ld	s2,48(sp)
ffffffffc0201c88:	79a2                	ld	s3,40(sp)
ffffffffc0201c8a:	7a02                	ld	s4,32(sp)
ffffffffc0201c8c:	6ae2                	ld	s5,24(sp)
ffffffffc0201c8e:	6161                	addi	sp,sp,80
ffffffffc0201c90:	8082                	ret

ffffffffc0201c92 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c92:	100027f3          	csrr	a5,sstatus
ffffffffc0201c96:	8b89                	andi	a5,a5,2
ffffffffc0201c98:	eb89                	bnez	a5,ffffffffc0201caa <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c9a:	00015797          	auipc	a5,0x15
ffffffffc0201c9e:	85e78793          	addi	a5,a5,-1954 # ffffffffc02164f8 <pmm_manager>
ffffffffc0201ca2:	639c                	ld	a5,0(a5)
ffffffffc0201ca4:	0207b303          	ld	t1,32(a5)
ffffffffc0201ca8:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201caa:	1101                	addi	sp,sp,-32
ffffffffc0201cac:	ec06                	sd	ra,24(sp)
ffffffffc0201cae:	e822                	sd	s0,16(sp)
ffffffffc0201cb0:	e426                	sd	s1,8(sp)
ffffffffc0201cb2:	842a                	mv	s0,a0
ffffffffc0201cb4:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201cb6:	91bfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201cba:	00015797          	auipc	a5,0x15
ffffffffc0201cbe:	83e78793          	addi	a5,a5,-1986 # ffffffffc02164f8 <pmm_manager>
ffffffffc0201cc2:	639c                	ld	a5,0(a5)
ffffffffc0201cc4:	85a6                	mv	a1,s1
ffffffffc0201cc6:	8522                	mv	a0,s0
ffffffffc0201cc8:	739c                	ld	a5,32(a5)
ffffffffc0201cca:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ccc:	6442                	ld	s0,16(sp)
ffffffffc0201cce:	60e2                	ld	ra,24(sp)
ffffffffc0201cd0:	64a2                	ld	s1,8(sp)
ffffffffc0201cd2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201cd4:	8f7fe06f          	j	ffffffffc02005ca <intr_enable>

ffffffffc0201cd8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cd8:	100027f3          	csrr	a5,sstatus
ffffffffc0201cdc:	8b89                	andi	a5,a5,2
ffffffffc0201cde:	eb89                	bnez	a5,ffffffffc0201cf0 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ce0:	00015797          	auipc	a5,0x15
ffffffffc0201ce4:	81878793          	addi	a5,a5,-2024 # ffffffffc02164f8 <pmm_manager>
ffffffffc0201ce8:	639c                	ld	a5,0(a5)
ffffffffc0201cea:	0287b303          	ld	t1,40(a5)
ffffffffc0201cee:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201cf0:	1141                	addi	sp,sp,-16
ffffffffc0201cf2:	e406                	sd	ra,8(sp)
ffffffffc0201cf4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201cf6:	8dbfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cfa:	00014797          	auipc	a5,0x14
ffffffffc0201cfe:	7fe78793          	addi	a5,a5,2046 # ffffffffc02164f8 <pmm_manager>
ffffffffc0201d02:	639c                	ld	a5,0(a5)
ffffffffc0201d04:	779c                	ld	a5,40(a5)
ffffffffc0201d06:	9782                	jalr	a5
ffffffffc0201d08:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d0a:	8c1fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201d0e:	8522                	mv	a0,s0
ffffffffc0201d10:	60a2                	ld	ra,8(sp)
ffffffffc0201d12:	6402                	ld	s0,0(sp)
ffffffffc0201d14:	0141                	addi	sp,sp,16
ffffffffc0201d16:	8082                	ret

ffffffffc0201d18 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d18:	715d                	addi	sp,sp,-80
ffffffffc0201d1a:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d1c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201d20:	1ff4f493          	andi	s1,s1,511
ffffffffc0201d24:	048e                	slli	s1,s1,0x3
ffffffffc0201d26:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d28:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d2a:	f84a                	sd	s2,48(sp)
ffffffffc0201d2c:	f44e                	sd	s3,40(sp)
ffffffffc0201d2e:	f052                	sd	s4,32(sp)
ffffffffc0201d30:	e486                	sd	ra,72(sp)
ffffffffc0201d32:	e0a2                	sd	s0,64(sp)
ffffffffc0201d34:	ec56                	sd	s5,24(sp)
ffffffffc0201d36:	e85a                	sd	s6,16(sp)
ffffffffc0201d38:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d3a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d3e:	892e                	mv	s2,a1
ffffffffc0201d40:	8a32                	mv	s4,a2
ffffffffc0201d42:	00014997          	auipc	s3,0x14
ffffffffc0201d46:	75e98993          	addi	s3,s3,1886 # ffffffffc02164a0 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d4a:	e3c9                	bnez	a5,ffffffffc0201dcc <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d4c:	16060163          	beqz	a2,ffffffffc0201eae <get_pte+0x196>
ffffffffc0201d50:	4505                	li	a0,1
ffffffffc0201d52:	eb9ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0201d56:	842a                	mv	s0,a0
ffffffffc0201d58:	14050b63          	beqz	a0,ffffffffc0201eae <get_pte+0x196>
    return page - pages + nbase;
ffffffffc0201d5c:	00014b97          	auipc	s7,0x14
ffffffffc0201d60:	7b4b8b93          	addi	s7,s7,1972 # ffffffffc0216510 <pages>
ffffffffc0201d64:	000bb503          	ld	a0,0(s7)
ffffffffc0201d68:	00004797          	auipc	a5,0x4
ffffffffc0201d6c:	d4078793          	addi	a5,a5,-704 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0201d70:	0007bb03          	ld	s6,0(a5)
ffffffffc0201d74:	40a40533          	sub	a0,s0,a0
ffffffffc0201d78:	850d                	srai	a0,a0,0x3
ffffffffc0201d7a:	03650533          	mul	a0,a0,s6
ffffffffc0201d7e:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d82:	00014997          	auipc	s3,0x14
ffffffffc0201d86:	71e98993          	addi	s3,s3,1822 # ffffffffc02164a0 <npage>
    page->ref = val;
ffffffffc0201d8a:	4785                	li	a5,1
ffffffffc0201d8c:	0009b703          	ld	a4,0(s3)
ffffffffc0201d90:	c01c                	sw	a5,0(s0)
    return page - pages + nbase;
ffffffffc0201d92:	9556                	add	a0,a0,s5
ffffffffc0201d94:	00c51793          	slli	a5,a0,0xc
ffffffffc0201d98:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d9a:	0532                	slli	a0,a0,0xc
ffffffffc0201d9c:	16e7f063          	bgeu	a5,a4,ffffffffc0201efc <get_pte+0x1e4>
ffffffffc0201da0:	00014797          	auipc	a5,0x14
ffffffffc0201da4:	76078793          	addi	a5,a5,1888 # ffffffffc0216500 <va_pa_offset>
ffffffffc0201da8:	639c                	ld	a5,0(a5)
ffffffffc0201daa:	6605                	lui	a2,0x1
ffffffffc0201dac:	4581                	li	a1,0
ffffffffc0201dae:	953e                	add	a0,a0,a5
ffffffffc0201db0:	2a8030ef          	jal	ra,ffffffffc0205058 <memset>
    return page - pages + nbase;
ffffffffc0201db4:	000bb683          	ld	a3,0(s7)
ffffffffc0201db8:	40d406b3          	sub	a3,s0,a3
ffffffffc0201dbc:	868d                	srai	a3,a3,0x3
ffffffffc0201dbe:	036686b3          	mul	a3,a3,s6
ffffffffc0201dc2:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201dc4:	06aa                	slli	a3,a3,0xa
ffffffffc0201dc6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201dca:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201dcc:	77fd                	lui	a5,0xfffff
ffffffffc0201dce:	068a                	slli	a3,a3,0x2
ffffffffc0201dd0:	0009b703          	ld	a4,0(s3)
ffffffffc0201dd4:	8efd                	and	a3,a3,a5
ffffffffc0201dd6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201dda:	0ce7fc63          	bgeu	a5,a4,ffffffffc0201eb2 <get_pte+0x19a>
ffffffffc0201dde:	00014a97          	auipc	s5,0x14
ffffffffc0201de2:	722a8a93          	addi	s5,s5,1826 # ffffffffc0216500 <va_pa_offset>
ffffffffc0201de6:	000ab403          	ld	s0,0(s5)
ffffffffc0201dea:	01595793          	srli	a5,s2,0x15
ffffffffc0201dee:	1ff7f793          	andi	a5,a5,511
ffffffffc0201df2:	96a2                	add	a3,a3,s0
ffffffffc0201df4:	00379413          	slli	s0,a5,0x3
ffffffffc0201df8:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201dfa:	6014                	ld	a3,0(s0)
ffffffffc0201dfc:	0016f793          	andi	a5,a3,1
ffffffffc0201e00:	ebbd                	bnez	a5,ffffffffc0201e76 <get_pte+0x15e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e02:	0a0a0663          	beqz	s4,ffffffffc0201eae <get_pte+0x196>
ffffffffc0201e06:	4505                	li	a0,1
ffffffffc0201e08:	e03ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0201e0c:	84aa                	mv	s1,a0
ffffffffc0201e0e:	c145                	beqz	a0,ffffffffc0201eae <get_pte+0x196>
    return page - pages + nbase;
ffffffffc0201e10:	00014b97          	auipc	s7,0x14
ffffffffc0201e14:	700b8b93          	addi	s7,s7,1792 # ffffffffc0216510 <pages>
ffffffffc0201e18:	000bb503          	ld	a0,0(s7)
ffffffffc0201e1c:	00004797          	auipc	a5,0x4
ffffffffc0201e20:	c8c78793          	addi	a5,a5,-884 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0201e24:	0007bb03          	ld	s6,0(a5)
ffffffffc0201e28:	40a48533          	sub	a0,s1,a0
ffffffffc0201e2c:	850d                	srai	a0,a0,0x3
ffffffffc0201e2e:	03650533          	mul	a0,a0,s6
ffffffffc0201e32:	00080a37          	lui	s4,0x80
    page->ref = val;
ffffffffc0201e36:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e38:	0009b703          	ld	a4,0(s3)
ffffffffc0201e3c:	c09c                	sw	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201e3e:	9552                	add	a0,a0,s4
ffffffffc0201e40:	00c51793          	slli	a5,a0,0xc
ffffffffc0201e44:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e46:	0532                	slli	a0,a0,0xc
ffffffffc0201e48:	08e7fd63          	bgeu	a5,a4,ffffffffc0201ee2 <get_pte+0x1ca>
ffffffffc0201e4c:	000ab783          	ld	a5,0(s5)
ffffffffc0201e50:	6605                	lui	a2,0x1
ffffffffc0201e52:	4581                	li	a1,0
ffffffffc0201e54:	953e                	add	a0,a0,a5
ffffffffc0201e56:	202030ef          	jal	ra,ffffffffc0205058 <memset>
    return page - pages + nbase;
ffffffffc0201e5a:	000bb683          	ld	a3,0(s7)
ffffffffc0201e5e:	40d486b3          	sub	a3,s1,a3
ffffffffc0201e62:	868d                	srai	a3,a3,0x3
ffffffffc0201e64:	036686b3          	mul	a3,a3,s6
ffffffffc0201e68:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e6a:	06aa                	slli	a3,a3,0xa
ffffffffc0201e6c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e70:	e014                	sd	a3,0(s0)
ffffffffc0201e72:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e76:	068a                	slli	a3,a3,0x2
ffffffffc0201e78:	757d                	lui	a0,0xfffff
ffffffffc0201e7a:	8ee9                	and	a3,a3,a0
ffffffffc0201e7c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e80:	04e7f563          	bgeu	a5,a4,ffffffffc0201eca <get_pte+0x1b2>
ffffffffc0201e84:	000ab503          	ld	a0,0(s5)
ffffffffc0201e88:	00c95793          	srli	a5,s2,0xc
ffffffffc0201e8c:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e90:	96aa                	add	a3,a3,a0
ffffffffc0201e92:	00379513          	slli	a0,a5,0x3
ffffffffc0201e96:	9536                	add	a0,a0,a3
}
ffffffffc0201e98:	60a6                	ld	ra,72(sp)
ffffffffc0201e9a:	6406                	ld	s0,64(sp)
ffffffffc0201e9c:	74e2                	ld	s1,56(sp)
ffffffffc0201e9e:	7942                	ld	s2,48(sp)
ffffffffc0201ea0:	79a2                	ld	s3,40(sp)
ffffffffc0201ea2:	7a02                	ld	s4,32(sp)
ffffffffc0201ea4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ea6:	6b42                	ld	s6,16(sp)
ffffffffc0201ea8:	6ba2                	ld	s7,8(sp)
ffffffffc0201eaa:	6161                	addi	sp,sp,80
ffffffffc0201eac:	8082                	ret
            return NULL;
ffffffffc0201eae:	4501                	li	a0,0
ffffffffc0201eb0:	b7e5                	j	ffffffffc0201e98 <get_pte+0x180>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201eb2:	00004617          	auipc	a2,0x4
ffffffffc0201eb6:	ff660613          	addi	a2,a2,-10 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0201eba:	0e400593          	li	a1,228
ffffffffc0201ebe:	00004517          	auipc	a0,0x4
ffffffffc0201ec2:	0da50513          	addi	a0,a0,218 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0201ec6:	d86fe0ef          	jal	ra,ffffffffc020044c <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201eca:	00004617          	auipc	a2,0x4
ffffffffc0201ece:	fde60613          	addi	a2,a2,-34 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0201ed2:	0ef00593          	li	a1,239
ffffffffc0201ed6:	00004517          	auipc	a0,0x4
ffffffffc0201eda:	0c250513          	addi	a0,a0,194 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0201ede:	d6efe0ef          	jal	ra,ffffffffc020044c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ee2:	86aa                	mv	a3,a0
ffffffffc0201ee4:	00004617          	auipc	a2,0x4
ffffffffc0201ee8:	fc460613          	addi	a2,a2,-60 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0201eec:	0ec00593          	li	a1,236
ffffffffc0201ef0:	00004517          	auipc	a0,0x4
ffffffffc0201ef4:	0a850513          	addi	a0,a0,168 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0201ef8:	d54fe0ef          	jal	ra,ffffffffc020044c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201efc:	86aa                	mv	a3,a0
ffffffffc0201efe:	00004617          	auipc	a2,0x4
ffffffffc0201f02:	faa60613          	addi	a2,a2,-86 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0201f06:	0e100593          	li	a1,225
ffffffffc0201f0a:	00004517          	auipc	a0,0x4
ffffffffc0201f0e:	08e50513          	addi	a0,a0,142 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0201f12:	d3afe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201f16 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f16:	1141                	addi	sp,sp,-16
ffffffffc0201f18:	e022                	sd	s0,0(sp)
ffffffffc0201f1a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f1c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f1e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f20:	df9ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201f24:	c011                	beqz	s0,ffffffffc0201f28 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201f26:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f28:	c511                	beqz	a0,ffffffffc0201f34 <get_page+0x1e>
ffffffffc0201f2a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201f2c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f2e:	0017f713          	andi	a4,a5,1
ffffffffc0201f32:	e709                	bnez	a4,ffffffffc0201f3c <get_page+0x26>
}
ffffffffc0201f34:	60a2                	ld	ra,8(sp)
ffffffffc0201f36:	6402                	ld	s0,0(sp)
ffffffffc0201f38:	0141                	addi	sp,sp,16
ffffffffc0201f3a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f3c:	00014717          	auipc	a4,0x14
ffffffffc0201f40:	56470713          	addi	a4,a4,1380 # ffffffffc02164a0 <npage>
ffffffffc0201f44:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f46:	078a                	slli	a5,a5,0x2
ffffffffc0201f48:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f4a:	02e7f363          	bgeu	a5,a4,ffffffffc0201f70 <get_page+0x5a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f4e:	fff80537          	lui	a0,0xfff80
ffffffffc0201f52:	97aa                	add	a5,a5,a0
ffffffffc0201f54:	00014697          	auipc	a3,0x14
ffffffffc0201f58:	5bc68693          	addi	a3,a3,1468 # ffffffffc0216510 <pages>
ffffffffc0201f5c:	6288                	ld	a0,0(a3)
ffffffffc0201f5e:	60a2                	ld	ra,8(sp)
ffffffffc0201f60:	6402                	ld	s0,0(sp)
ffffffffc0201f62:	00379713          	slli	a4,a5,0x3
ffffffffc0201f66:	97ba                	add	a5,a5,a4
ffffffffc0201f68:	078e                	slli	a5,a5,0x3
ffffffffc0201f6a:	953e                	add	a0,a0,a5
ffffffffc0201f6c:	0141                	addi	sp,sp,16
ffffffffc0201f6e:	8082                	ret
ffffffffc0201f70:	c7fff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc0201f74 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f74:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f76:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f78:	e426                	sd	s1,8(sp)
ffffffffc0201f7a:	ec06                	sd	ra,24(sp)
ffffffffc0201f7c:	e822                	sd	s0,16(sp)
ffffffffc0201f7e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f80:	d99ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep != NULL) {
ffffffffc0201f84:	c511                	beqz	a0,ffffffffc0201f90 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201f86:	611c                	ld	a5,0(a0)
ffffffffc0201f88:	842a                	mv	s0,a0
ffffffffc0201f8a:	0017f713          	andi	a4,a5,1
ffffffffc0201f8e:	e711                	bnez	a4,ffffffffc0201f9a <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201f90:	60e2                	ld	ra,24(sp)
ffffffffc0201f92:	6442                	ld	s0,16(sp)
ffffffffc0201f94:	64a2                	ld	s1,8(sp)
ffffffffc0201f96:	6105                	addi	sp,sp,32
ffffffffc0201f98:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f9a:	00014717          	auipc	a4,0x14
ffffffffc0201f9e:	50670713          	addi	a4,a4,1286 # ffffffffc02164a0 <npage>
ffffffffc0201fa2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fa4:	078a                	slli	a5,a5,0x2
ffffffffc0201fa6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fa8:	04e7f163          	bgeu	a5,a4,ffffffffc0201fea <page_remove+0x76>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fac:	fff80737          	lui	a4,0xfff80
ffffffffc0201fb0:	97ba                	add	a5,a5,a4
ffffffffc0201fb2:	00014717          	auipc	a4,0x14
ffffffffc0201fb6:	55e70713          	addi	a4,a4,1374 # ffffffffc0216510 <pages>
ffffffffc0201fba:	6308                	ld	a0,0(a4)
ffffffffc0201fbc:	00379713          	slli	a4,a5,0x3
ffffffffc0201fc0:	97ba                	add	a5,a5,a4
ffffffffc0201fc2:	078e                	slli	a5,a5,0x3
ffffffffc0201fc4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201fc6:	411c                	lw	a5,0(a0)
ffffffffc0201fc8:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201fcc:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201fce:	cb11                	beqz	a4,ffffffffc0201fe2 <page_remove+0x6e>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201fd0:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fd4:	12048073          	sfence.vma	s1
}
ffffffffc0201fd8:	60e2                	ld	ra,24(sp)
ffffffffc0201fda:	6442                	ld	s0,16(sp)
ffffffffc0201fdc:	64a2                	ld	s1,8(sp)
ffffffffc0201fde:	6105                	addi	sp,sp,32
ffffffffc0201fe0:	8082                	ret
            free_page(page);
ffffffffc0201fe2:	4585                	li	a1,1
ffffffffc0201fe4:	cafff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc0201fe8:	b7e5                	j	ffffffffc0201fd0 <page_remove+0x5c>
ffffffffc0201fea:	c05ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc0201fee <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fee:	7179                	addi	sp,sp,-48
ffffffffc0201ff0:	e44e                	sd	s3,8(sp)
ffffffffc0201ff2:	89b2                	mv	s3,a2
ffffffffc0201ff4:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201ff6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ff8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201ffa:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ffc:	ec26                	sd	s1,24(sp)
ffffffffc0201ffe:	f406                	sd	ra,40(sp)
ffffffffc0202000:	e84a                	sd	s2,16(sp)
ffffffffc0202002:	e052                	sd	s4,0(sp)
ffffffffc0202004:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202006:	d13ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep == NULL) {
ffffffffc020200a:	c94d                	beqz	a0,ffffffffc02020bc <page_insert+0xce>
    page->ref += 1;
ffffffffc020200c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020200e:	611c                	ld	a5,0(a0)
ffffffffc0202010:	892a                	mv	s2,a0
ffffffffc0202012:	0016871b          	addiw	a4,a3,1
ffffffffc0202016:	c018                	sw	a4,0(s0)
ffffffffc0202018:	0017f713          	andi	a4,a5,1
ffffffffc020201c:	e721                	bnez	a4,ffffffffc0202064 <page_insert+0x76>
ffffffffc020201e:	00014797          	auipc	a5,0x14
ffffffffc0202022:	4f278793          	addi	a5,a5,1266 # ffffffffc0216510 <pages>
ffffffffc0202026:	639c                	ld	a5,0(a5)
    return page - pages + nbase;
ffffffffc0202028:	00004717          	auipc	a4,0x4
ffffffffc020202c:	a8070713          	addi	a4,a4,-1408 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0202030:	40f407b3          	sub	a5,s0,a5
ffffffffc0202034:	6300                	ld	s0,0(a4)
ffffffffc0202036:	878d                	srai	a5,a5,0x3
ffffffffc0202038:	000806b7          	lui	a3,0x80
ffffffffc020203c:	028787b3          	mul	a5,a5,s0
ffffffffc0202040:	97b6                	add	a5,a5,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202042:	07aa                	slli	a5,a5,0xa
ffffffffc0202044:	8fc5                	or	a5,a5,s1
ffffffffc0202046:	0017e793          	ori	a5,a5,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020204a:	00f93023          	sd	a5,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020204e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202052:	4501                	li	a0,0
}
ffffffffc0202054:	70a2                	ld	ra,40(sp)
ffffffffc0202056:	7402                	ld	s0,32(sp)
ffffffffc0202058:	64e2                	ld	s1,24(sp)
ffffffffc020205a:	6942                	ld	s2,16(sp)
ffffffffc020205c:	69a2                	ld	s3,8(sp)
ffffffffc020205e:	6a02                	ld	s4,0(sp)
ffffffffc0202060:	6145                	addi	sp,sp,48
ffffffffc0202062:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202064:	00014717          	auipc	a4,0x14
ffffffffc0202068:	43c70713          	addi	a4,a4,1084 # ffffffffc02164a0 <npage>
ffffffffc020206c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020206e:	00279513          	slli	a0,a5,0x2
ffffffffc0202072:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202074:	04e57663          	bgeu	a0,a4,ffffffffc02020c0 <page_insert+0xd2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202078:	fff807b7          	lui	a5,0xfff80
ffffffffc020207c:	953e                	add	a0,a0,a5
ffffffffc020207e:	00014a17          	auipc	s4,0x14
ffffffffc0202082:	492a0a13          	addi	s4,s4,1170 # ffffffffc0216510 <pages>
ffffffffc0202086:	000a3783          	ld	a5,0(s4)
ffffffffc020208a:	00351713          	slli	a4,a0,0x3
ffffffffc020208e:	953a                	add	a0,a0,a4
ffffffffc0202090:	050e                	slli	a0,a0,0x3
ffffffffc0202092:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0202094:	00a40a63          	beq	s0,a0,ffffffffc02020a8 <page_insert+0xba>
    page->ref -= 1;
ffffffffc0202098:	4118                	lw	a4,0(a0)
ffffffffc020209a:	fff7069b          	addiw	a3,a4,-1
ffffffffc020209e:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02020a0:	c691                	beqz	a3,ffffffffc02020ac <page_insert+0xbe>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020a2:	12098073          	sfence.vma	s3
ffffffffc02020a6:	b749                	j	ffffffffc0202028 <page_insert+0x3a>
ffffffffc02020a8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02020aa:	bfbd                	j	ffffffffc0202028 <page_insert+0x3a>
            free_page(page);
ffffffffc02020ac:	4585                	li	a1,1
ffffffffc02020ae:	be5ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc02020b2:	000a3783          	ld	a5,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020b6:	12098073          	sfence.vma	s3
ffffffffc02020ba:	b7bd                	j	ffffffffc0202028 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02020bc:	5571                	li	a0,-4
ffffffffc02020be:	bf59                	j	ffffffffc0202054 <page_insert+0x66>
ffffffffc02020c0:	b2fff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc02020c4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02020c4:	00004797          	auipc	a5,0x4
ffffffffc02020c8:	d9478793          	addi	a5,a5,-620 # ffffffffc0205e58 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020cc:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02020ce:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020d0:	00004517          	auipc	a0,0x4
ffffffffc02020d4:	ef050513          	addi	a0,a0,-272 # ffffffffc0205fc0 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc02020d8:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02020da:	00014717          	auipc	a4,0x14
ffffffffc02020de:	40f73f23          	sd	a5,1054(a4) # ffffffffc02164f8 <pmm_manager>
void pmm_init(void) {
ffffffffc02020e2:	e8a2                	sd	s0,80(sp)
ffffffffc02020e4:	e4a6                	sd	s1,72(sp)
ffffffffc02020e6:	e0ca                	sd	s2,64(sp)
ffffffffc02020e8:	fc4e                	sd	s3,56(sp)
ffffffffc02020ea:	f852                	sd	s4,48(sp)
ffffffffc02020ec:	f456                	sd	s5,40(sp)
ffffffffc02020ee:	f05a                	sd	s6,32(sp)
ffffffffc02020f0:	ec5e                	sd	s7,24(sp)
ffffffffc02020f2:	e862                	sd	s8,16(sp)
ffffffffc02020f4:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02020f6:	00014417          	auipc	s0,0x14
ffffffffc02020fa:	40240413          	addi	s0,s0,1026 # ffffffffc02164f8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020fe:	890fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202102:	601c                	ld	a5,0(s0)
ffffffffc0202104:	00014497          	auipc	s1,0x14
ffffffffc0202108:	39c48493          	addi	s1,s1,924 # ffffffffc02164a0 <npage>
ffffffffc020210c:	00014917          	auipc	s2,0x14
ffffffffc0202110:	40490913          	addi	s2,s2,1028 # ffffffffc0216510 <pages>
ffffffffc0202114:	679c                	ld	a5,8(a5)
ffffffffc0202116:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202118:	57f5                	li	a5,-3
ffffffffc020211a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020211c:	00004517          	auipc	a0,0x4
ffffffffc0202120:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205fd8 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202124:	00014717          	auipc	a4,0x14
ffffffffc0202128:	3cf73e23          	sd	a5,988(a4) # ffffffffc0216500 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020212c:	862fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202130:	46c5                	li	a3,17
ffffffffc0202132:	06ee                	slli	a3,a3,0x1b
ffffffffc0202134:	40100613          	li	a2,1025
ffffffffc0202138:	16fd                	addi	a3,a3,-1
ffffffffc020213a:	0656                	slli	a2,a2,0x15
ffffffffc020213c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202140:	00004517          	auipc	a0,0x4
ffffffffc0202144:	eb050513          	addi	a0,a0,-336 # ffffffffc0205ff0 <default_pmm_manager+0x198>
ffffffffc0202148:	846fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020214c:	777d                	lui	a4,0xfffff
ffffffffc020214e:	00015797          	auipc	a5,0x15
ffffffffc0202152:	4b978793          	addi	a5,a5,1209 # ffffffffc0217607 <end+0xfff>
ffffffffc0202156:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202158:	00088737          	lui	a4,0x88
ffffffffc020215c:	00014697          	auipc	a3,0x14
ffffffffc0202160:	34e6b223          	sd	a4,836(a3) # ffffffffc02164a0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202164:	4581                	li	a1,0
ffffffffc0202166:	00014717          	auipc	a4,0x14
ffffffffc020216a:	3af73523          	sd	a5,938(a4) # ffffffffc0216510 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020216e:	4681                	li	a3,0
ffffffffc0202170:	4605                	li	a2,1
ffffffffc0202172:	fff80837          	lui	a6,0xfff80
ffffffffc0202176:	a019                	j	ffffffffc020217c <pmm_init+0xb8>
ffffffffc0202178:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020217c:	97ae                	add	a5,a5,a1
ffffffffc020217e:	07a1                	addi	a5,a5,8
ffffffffc0202180:	40c7b02f          	amoor.d	zero,a2,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202184:	6098                	ld	a4,0(s1)
ffffffffc0202186:	0685                	addi	a3,a3,1
ffffffffc0202188:	04858593          	addi	a1,a1,72 # 7e00048 <BASE_ADDRESS-0xffffffffb83fffb8>
ffffffffc020218c:	010707b3          	add	a5,a4,a6
ffffffffc0202190:	fef6e4e3          	bltu	a3,a5,ffffffffc0202178 <pmm_init+0xb4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202194:	00093503          	ld	a0,0(s2)
ffffffffc0202198:	00371693          	slli	a3,a4,0x3
ffffffffc020219c:	96ba                	add	a3,a3,a4
ffffffffc020219e:	fdc005b7          	lui	a1,0xfdc00
ffffffffc02021a2:	068e                	slli	a3,a3,0x3
ffffffffc02021a4:	95aa                	add	a1,a1,a0
ffffffffc02021a6:	96ae                	add	a3,a3,a1
ffffffffc02021a8:	c02007b7          	lui	a5,0xc0200
ffffffffc02021ac:	16f6ede3          	bltu	a3,a5,ffffffffc0202b26 <pmm_init+0xa62>
ffffffffc02021b0:	00014997          	auipc	s3,0x14
ffffffffc02021b4:	35098993          	addi	s3,s3,848 # ffffffffc0216500 <va_pa_offset>
ffffffffc02021b8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02021bc:	47c5                	li	a5,17
ffffffffc02021be:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021c0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02021c2:	02f6fc63          	bgeu	a3,a5,ffffffffc02021fa <pmm_init+0x136>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02021c6:	6585                	lui	a1,0x1
ffffffffc02021c8:	15fd                	addi	a1,a1,-1
ffffffffc02021ca:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02021cc:	00c6d613          	srli	a2,a3,0xc
ffffffffc02021d0:	4ee67b63          	bgeu	a2,a4,ffffffffc02026c6 <pmm_init+0x602>
    pmm_manager->init_memmap(base, n);
ffffffffc02021d4:	00043883          	ld	a7,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02021d8:	9642                	add	a2,a2,a6
ffffffffc02021da:	00361713          	slli	a4,a2,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02021de:	75fd                	lui	a1,0xfffff
ffffffffc02021e0:	8eed                	and	a3,a3,a1
ffffffffc02021e2:	9732                	add	a4,a4,a2
    pmm_manager->init_memmap(base, n);
ffffffffc02021e4:	0108b603          	ld	a2,16(a7)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02021e8:	40d786b3          	sub	a3,a5,a3
ffffffffc02021ec:	070e                	slli	a4,a4,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02021ee:	00c6d593          	srli	a1,a3,0xc
ffffffffc02021f2:	953a                	add	a0,a0,a4
ffffffffc02021f4:	9602                	jalr	a2
ffffffffc02021f6:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02021fa:	00004517          	auipc	a0,0x4
ffffffffc02021fe:	e1e50513          	addi	a0,a0,-482 # ffffffffc0206018 <default_pmm_manager+0x1c0>
ffffffffc0202202:	f8dfd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202206:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202208:	00014417          	auipc	s0,0x14
ffffffffc020220c:	29040413          	addi	s0,s0,656 # ffffffffc0216498 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202210:	7b9c                	ld	a5,48(a5)
ffffffffc0202212:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202214:	00004517          	auipc	a0,0x4
ffffffffc0202218:	e1c50513          	addi	a0,a0,-484 # ffffffffc0206030 <default_pmm_manager+0x1d8>
ffffffffc020221c:	f73fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202220:	00008697          	auipc	a3,0x8
ffffffffc0202224:	de068693          	addi	a3,a3,-544 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202228:	00014797          	auipc	a5,0x14
ffffffffc020222c:	26d7b823          	sd	a3,624(a5) # ffffffffc0216498 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202230:	c02007b7          	lui	a5,0xc0200
ffffffffc0202234:	7cf6ed63          	bltu	a3,a5,ffffffffc0202a0e <pmm_init+0x94a>
ffffffffc0202238:	0009b783          	ld	a5,0(s3)
ffffffffc020223c:	8e9d                	sub	a3,a3,a5
ffffffffc020223e:	00014797          	auipc	a5,0x14
ffffffffc0202242:	2cd7b523          	sd	a3,714(a5) # ffffffffc0216508 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202246:	a93ff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020224a:	6098                	ld	a4,0(s1)
ffffffffc020224c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202250:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202252:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202254:	76e7ed63          	bltu	a5,a4,ffffffffc02029ce <pmm_init+0x90a>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202258:	6008                	ld	a0,0(s0)
ffffffffc020225a:	48050463          	beqz	a0,ffffffffc02026e2 <pmm_init+0x61e>
ffffffffc020225e:	03451793          	slli	a5,a0,0x34
ffffffffc0202262:	48079063          	bnez	a5,ffffffffc02026e2 <pmm_init+0x61e>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202266:	4601                	li	a2,0
ffffffffc0202268:	4581                	li	a1,0
ffffffffc020226a:	cadff0ef          	jal	ra,ffffffffc0201f16 <get_page>
ffffffffc020226e:	08051ce3          	bnez	a0,ffffffffc0202b06 <pmm_init+0xa42>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202272:	4505                	li	a0,1
ffffffffc0202274:	997ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202278:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020227a:	6008                	ld	a0,0(s0)
ffffffffc020227c:	4681                	li	a3,0
ffffffffc020227e:	4601                	li	a2,0
ffffffffc0202280:	85d6                	mv	a1,s5
ffffffffc0202282:	d6dff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc0202286:	060510e3          	bnez	a0,ffffffffc0202ae6 <pmm_init+0xa22>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020228a:	6008                	ld	a0,0(s0)
ffffffffc020228c:	4601                	li	a2,0
ffffffffc020228e:	4581                	li	a1,0
ffffffffc0202290:	a89ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202294:	48050363          	beqz	a0,ffffffffc020271a <pmm_init+0x656>
    assert(pte2page(*ptep) == p1);
ffffffffc0202298:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020229a:	0017f713          	andi	a4,a5,1
ffffffffc020229e:	46070263          	beqz	a4,ffffffffc0202702 <pmm_init+0x63e>
    if (PPN(pa) >= npage) {
ffffffffc02022a2:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02022a4:	078a                	slli	a5,a5,0x2
ffffffffc02022a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022a8:	40c7ff63          	bgeu	a5,a2,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ac:	fff80737          	lui	a4,0xfff80
ffffffffc02022b0:	97ba                	add	a5,a5,a4
ffffffffc02022b2:	00379713          	slli	a4,a5,0x3
ffffffffc02022b6:	00093683          	ld	a3,0(s2)
ffffffffc02022ba:	97ba                	add	a5,a5,a4
ffffffffc02022bc:	078e                	slli	a5,a5,0x3
ffffffffc02022be:	97b6                	add	a5,a5,a3
ffffffffc02022c0:	4cfa9763          	bne	s5,a5,ffffffffc020278e <pmm_init+0x6ca>
    assert(page_ref(p1) == 1);
ffffffffc02022c4:	000aab83          	lw	s7,0(s5)
ffffffffc02022c8:	4785                	li	a5,1
ffffffffc02022ca:	4afb9263          	bne	s7,a5,ffffffffc020276e <pmm_init+0x6aa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022ce:	6008                	ld	a0,0(s0)
ffffffffc02022d0:	76fd                	lui	a3,0xfffff
ffffffffc02022d2:	611c                	ld	a5,0(a0)
ffffffffc02022d4:	078a                	slli	a5,a5,0x2
ffffffffc02022d6:	8ff5                	and	a5,a5,a3
ffffffffc02022d8:	00c7d713          	srli	a4,a5,0xc
ffffffffc02022dc:	46c77c63          	bgeu	a4,a2,ffffffffc0202754 <pmm_init+0x690>
ffffffffc02022e0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022e4:	97e2                	add	a5,a5,s8
ffffffffc02022e6:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7de99f8>
ffffffffc02022ea:	0b0a                	slli	s6,s6,0x2
ffffffffc02022ec:	00db7b33          	and	s6,s6,a3
ffffffffc02022f0:	00cb5793          	srli	a5,s6,0xc
ffffffffc02022f4:	44c7f363          	bgeu	a5,a2,ffffffffc020273a <pmm_init+0x676>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022f8:	4601                	li	a2,0
ffffffffc02022fa:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022fc:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022fe:	a1bff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202302:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202304:	59651563          	bne	a0,s6,ffffffffc020288e <pmm_init+0x7ca>

    p2 = alloc_page();
ffffffffc0202308:	4505                	li	a0,1
ffffffffc020230a:	901ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc020230e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202310:	6008                	ld	a0,0(s0)
ffffffffc0202312:	46d1                	li	a3,20
ffffffffc0202314:	6605                	lui	a2,0x1
ffffffffc0202316:	85da                	mv	a1,s6
ffffffffc0202318:	cd7ff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc020231c:	54051963          	bnez	a0,ffffffffc020286e <pmm_init+0x7aa>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202320:	6008                	ld	a0,0(s0)
ffffffffc0202322:	4601                	li	a2,0
ffffffffc0202324:	6585                	lui	a1,0x1
ffffffffc0202326:	9f3ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc020232a:	52050263          	beqz	a0,ffffffffc020284e <pmm_init+0x78a>
    assert(*ptep & PTE_U);
ffffffffc020232e:	611c                	ld	a5,0(a0)
ffffffffc0202330:	0107f713          	andi	a4,a5,16
ffffffffc0202334:	4e070d63          	beqz	a4,ffffffffc020282e <pmm_init+0x76a>
    assert(*ptep & PTE_W);
ffffffffc0202338:	8b91                	andi	a5,a5,4
ffffffffc020233a:	4c078a63          	beqz	a5,ffffffffc020280e <pmm_init+0x74a>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020233e:	6008                	ld	a0,0(s0)
ffffffffc0202340:	611c                	ld	a5,0(a0)
ffffffffc0202342:	8bc1                	andi	a5,a5,16
ffffffffc0202344:	4a078563          	beqz	a5,ffffffffc02027ee <pmm_init+0x72a>
    assert(page_ref(p2) == 1);
ffffffffc0202348:	000b2783          	lw	a5,0(s6)
ffffffffc020234c:	49779163          	bne	a5,s7,ffffffffc02027ce <pmm_init+0x70a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202350:	4681                	li	a3,0
ffffffffc0202352:	6605                	lui	a2,0x1
ffffffffc0202354:	85d6                	mv	a1,s5
ffffffffc0202356:	c99ff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc020235a:	44051a63          	bnez	a0,ffffffffc02027ae <pmm_init+0x6ea>
    assert(page_ref(p1) == 2);
ffffffffc020235e:	000aa703          	lw	a4,0(s5)
ffffffffc0202362:	4789                	li	a5,2
ffffffffc0202364:	62f71563          	bne	a4,a5,ffffffffc020298e <pmm_init+0x8ca>
    assert(page_ref(p2) == 0);
ffffffffc0202368:	000b2783          	lw	a5,0(s6)
ffffffffc020236c:	60079163          	bnez	a5,ffffffffc020296e <pmm_init+0x8aa>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202370:	6008                	ld	a0,0(s0)
ffffffffc0202372:	4601                	li	a2,0
ffffffffc0202374:	6585                	lui	a1,0x1
ffffffffc0202376:	9a3ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc020237a:	5c050a63          	beqz	a0,ffffffffc020294e <pmm_init+0x88a>
    assert(pte2page(*ptep) == p1);
ffffffffc020237e:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202380:	0016f793          	andi	a5,a3,1
ffffffffc0202384:	36078f63          	beqz	a5,ffffffffc0202702 <pmm_init+0x63e>
    if (PPN(pa) >= npage) {
ffffffffc0202388:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020238a:	00269793          	slli	a5,a3,0x2
ffffffffc020238e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202390:	32e7fb63          	bgeu	a5,a4,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc0202394:	fff80737          	lui	a4,0xfff80
ffffffffc0202398:	97ba                	add	a5,a5,a4
ffffffffc020239a:	00379713          	slli	a4,a5,0x3
ffffffffc020239e:	00093603          	ld	a2,0(s2)
ffffffffc02023a2:	97ba                	add	a5,a5,a4
ffffffffc02023a4:	078e                	slli	a5,a5,0x3
ffffffffc02023a6:	97b2                	add	a5,a5,a2
ffffffffc02023a8:	58fa9363          	bne	s5,a5,ffffffffc020292e <pmm_init+0x86a>
    assert((*ptep & PTE_U) == 0);
ffffffffc02023ac:	8ac1                	andi	a3,a3,16
ffffffffc02023ae:	56069063          	bnez	a3,ffffffffc020290e <pmm_init+0x84a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02023b2:	6008                	ld	a0,0(s0)
ffffffffc02023b4:	4581                	li	a1,0
ffffffffc02023b6:	bbfff0ef          	jal	ra,ffffffffc0201f74 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02023ba:	000aa703          	lw	a4,0(s5)
ffffffffc02023be:	4785                	li	a5,1
ffffffffc02023c0:	52f71763          	bne	a4,a5,ffffffffc02028ee <pmm_init+0x82a>
    assert(page_ref(p2) == 0);
ffffffffc02023c4:	000b2783          	lw	a5,0(s6)
ffffffffc02023c8:	50079363          	bnez	a5,ffffffffc02028ce <pmm_init+0x80a>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02023cc:	6008                	ld	a0,0(s0)
ffffffffc02023ce:	6585                	lui	a1,0x1
ffffffffc02023d0:	ba5ff0ef          	jal	ra,ffffffffc0201f74 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02023d4:	000aa783          	lw	a5,0(s5)
ffffffffc02023d8:	4c079b63          	bnez	a5,ffffffffc02028ae <pmm_init+0x7ea>
    assert(page_ref(p2) == 0);
ffffffffc02023dc:	000b2783          	lw	a5,0(s6)
ffffffffc02023e0:	6e079363          	bnez	a5,ffffffffc0202ac6 <pmm_init+0xa02>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02023e4:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02023e8:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023ea:	000b3783          	ld	a5,0(s6)
ffffffffc02023ee:	078a                	slli	a5,a5,0x2
ffffffffc02023f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023f2:	2cc7fa63          	bgeu	a5,a2,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f6:	fff80737          	lui	a4,0xfff80
ffffffffc02023fa:	973e                	add	a4,a4,a5
ffffffffc02023fc:	00371793          	slli	a5,a4,0x3
ffffffffc0202400:	00093803          	ld	a6,0(s2)
ffffffffc0202404:	97ba                	add	a5,a5,a4
ffffffffc0202406:	078e                	slli	a5,a5,0x3
ffffffffc0202408:	00f80733          	add	a4,a6,a5
ffffffffc020240c:	4314                	lw	a3,0(a4)
ffffffffc020240e:	4705                	li	a4,1
ffffffffc0202410:	68e69b63          	bne	a3,a4,ffffffffc0202aa6 <pmm_init+0x9e2>
    return page - pages + nbase;
ffffffffc0202414:	00003a97          	auipc	s5,0x3
ffffffffc0202418:	694a8a93          	addi	s5,s5,1684 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc020241c:	000ab703          	ld	a4,0(s5)
ffffffffc0202420:	4037d693          	srai	a3,a5,0x3
ffffffffc0202424:	00080bb7          	lui	s7,0x80
ffffffffc0202428:	02e686b3          	mul	a3,a3,a4
ffffffffc020242c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020242e:	00c69793          	slli	a5,a3,0xc
ffffffffc0202432:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202434:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202436:	28c7fa63          	bgeu	a5,a2,ffffffffc02026ca <pmm_init+0x606>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020243a:	0009b703          	ld	a4,0(s3)
ffffffffc020243e:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202440:	629c                	ld	a5,0(a3)
ffffffffc0202442:	078a                	slli	a5,a5,0x2
ffffffffc0202444:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202446:	28c7f063          	bgeu	a5,a2,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc020244a:	417787b3          	sub	a5,a5,s7
ffffffffc020244e:	00379513          	slli	a0,a5,0x3
ffffffffc0202452:	97aa                	add	a5,a5,a0
ffffffffc0202454:	00379513          	slli	a0,a5,0x3
ffffffffc0202458:	9542                	add	a0,a0,a6
ffffffffc020245a:	4585                	li	a1,1
ffffffffc020245c:	837ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202460:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202464:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202466:	050a                	slli	a0,a0,0x2
ffffffffc0202468:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020246a:	24f57e63          	bgeu	a0,a5,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc020246e:	417507b3          	sub	a5,a0,s7
ffffffffc0202472:	00379513          	slli	a0,a5,0x3
ffffffffc0202476:	00093703          	ld	a4,0(s2)
ffffffffc020247a:	953e                	add	a0,a0,a5
ffffffffc020247c:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020247e:	4585                	li	a1,1
ffffffffc0202480:	953a                	add	a0,a0,a4
ffffffffc0202482:	811ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202486:	601c                	ld	a5,0(s0)
ffffffffc0202488:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020248c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202490:	849ff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0202494:	50aa1d63          	bne	s4,a0,ffffffffc02029ae <pmm_init+0x8ea>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202498:	00004517          	auipc	a0,0x4
ffffffffc020249c:	ea850513          	addi	a0,a0,-344 # ffffffffc0206340 <default_pmm_manager+0x4e8>
ffffffffc02024a0:	ceffd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02024a4:	835ff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02024a8:	6098                	ld	a4,0(s1)
ffffffffc02024aa:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02024ae:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02024b0:	00c71693          	slli	a3,a4,0xc
ffffffffc02024b4:	1ad7fa63          	bgeu	a5,a3,ffffffffc0202668 <pmm_init+0x5a4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02024b8:	83b1                	srli	a5,a5,0xc
ffffffffc02024ba:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02024bc:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02024c0:	1ce7f663          	bgeu	a5,a4,ffffffffc020268c <pmm_init+0x5c8>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02024c4:	7c7d                	lui	s8,0xfffff
ffffffffc02024c6:	6b85                	lui	s7,0x1
ffffffffc02024c8:	a029                	j	ffffffffc02024d2 <pmm_init+0x40e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02024ca:	00ca5713          	srli	a4,s4,0xc
ffffffffc02024ce:	1af77f63          	bgeu	a4,a5,ffffffffc020268c <pmm_init+0x5c8>
ffffffffc02024d2:	0009b583          	ld	a1,0(s3)
ffffffffc02024d6:	4601                	li	a2,0
ffffffffc02024d8:	95d2                	add	a1,a1,s4
ffffffffc02024da:	83fff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc02024de:	18050763          	beqz	a0,ffffffffc020266c <pmm_init+0x5a8>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02024e2:	611c                	ld	a5,0(a0)
ffffffffc02024e4:	078a                	slli	a5,a5,0x2
ffffffffc02024e6:	0187f7b3          	and	a5,a5,s8
ffffffffc02024ea:	1b479e63          	bne	a5,s4,ffffffffc02026a6 <pmm_init+0x5e2>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02024ee:	609c                	ld	a5,0(s1)
ffffffffc02024f0:	9a5e                	add	s4,s4,s7
ffffffffc02024f2:	6008                	ld	a0,0(s0)
ffffffffc02024f4:	00c79713          	slli	a4,a5,0xc
ffffffffc02024f8:	fcea69e3          	bltu	s4,a4,ffffffffc02024ca <pmm_init+0x406>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02024fc:	611c                	ld	a5,0(a0)
ffffffffc02024fe:	4e079863          	bnez	a5,ffffffffc02029ee <pmm_init+0x92a>

    struct Page *p;
    p = alloc_page();
ffffffffc0202502:	4505                	li	a0,1
ffffffffc0202504:	f06ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202508:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020250a:	6008                	ld	a0,0(s0)
ffffffffc020250c:	4699                	li	a3,6
ffffffffc020250e:	10000613          	li	a2,256
ffffffffc0202512:	85d2                	mv	a1,s4
ffffffffc0202514:	adbff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc0202518:	56051763          	bnez	a0,ffffffffc0202a86 <pmm_init+0x9c2>
    assert(page_ref(p) == 1);
ffffffffc020251c:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0202520:	4785                	li	a5,1
ffffffffc0202522:	54f71263          	bne	a4,a5,ffffffffc0202a66 <pmm_init+0x9a2>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202526:	6008                	ld	a0,0(s0)
ffffffffc0202528:	6b85                	lui	s7,0x1
ffffffffc020252a:	4699                	li	a3,6
ffffffffc020252c:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0202530:	85d2                	mv	a1,s4
ffffffffc0202532:	abdff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc0202536:	50051863          	bnez	a0,ffffffffc0202a46 <pmm_init+0x982>
    assert(page_ref(p) == 2);
ffffffffc020253a:	000a2703          	lw	a4,0(s4)
ffffffffc020253e:	4789                	li	a5,2
ffffffffc0202540:	4ef71363          	bne	a4,a5,ffffffffc0202a26 <pmm_init+0x962>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202544:	00004597          	auipc	a1,0x4
ffffffffc0202548:	f3458593          	addi	a1,a1,-204 # ffffffffc0206478 <default_pmm_manager+0x620>
ffffffffc020254c:	10000513          	li	a0,256
ffffffffc0202550:	2af020ef          	jal	ra,ffffffffc0204ffe <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202554:	100b8593          	addi	a1,s7,256
ffffffffc0202558:	10000513          	li	a0,256
ffffffffc020255c:	2b5020ef          	jal	ra,ffffffffc0205010 <strcmp>
ffffffffc0202560:	60051f63          	bnez	a0,ffffffffc0202b7e <pmm_init+0xaba>
    return page - pages + nbase;
ffffffffc0202564:	00093683          	ld	a3,0(s2)
ffffffffc0202568:	000abc83          	ld	s9,0(s5)
ffffffffc020256c:	00080c37          	lui	s8,0x80
ffffffffc0202570:	40da06b3          	sub	a3,s4,a3
ffffffffc0202574:	868d                	srai	a3,a3,0x3
ffffffffc0202576:	039686b3          	mul	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc020257a:	5afd                	li	s5,-1
ffffffffc020257c:	609c                	ld	a5,0(s1)
ffffffffc020257e:	00cada93          	srli	s5,s5,0xc
    return page - pages + nbase;
ffffffffc0202582:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0202584:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202588:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020258a:	14f77063          	bgeu	a4,a5,ffffffffc02026ca <pmm_init+0x606>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020258e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202592:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202596:	96be                	add	a3,a3,a5
ffffffffc0202598:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde8af8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020259c:	21f020ef          	jal	ra,ffffffffc0204fba <strlen>
ffffffffc02025a0:	5a051f63          	bnez	a0,ffffffffc0202b5e <pmm_init+0xa9a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02025a4:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02025a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025aa:	000bb783          	ld	a5,0(s7)
ffffffffc02025ae:	078a                	slli	a5,a5,0x2
ffffffffc02025b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025b2:	10e7fa63          	bgeu	a5,a4,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b6:	418787b3          	sub	a5,a5,s8
ffffffffc02025ba:	00379693          	slli	a3,a5,0x3
    return page - pages + nbase;
ffffffffc02025be:	96be                	add	a3,a3,a5
ffffffffc02025c0:	039686b3          	mul	a3,a3,s9
ffffffffc02025c4:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc02025c6:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02025ca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02025cc:	0eeaff63          	bgeu	s5,a4,ffffffffc02026ca <pmm_init+0x606>
ffffffffc02025d0:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02025d4:	4585                	li	a1,1
ffffffffc02025d6:	8552                	mv	a0,s4
ffffffffc02025d8:	99b6                	add	s3,s3,a3
ffffffffc02025da:	eb8ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02025de:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02025e2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025e4:	078a                	slli	a5,a5,0x2
ffffffffc02025e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025e8:	0ce7ff63          	bgeu	a5,a4,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ec:	fff809b7          	lui	s3,0xfff80
ffffffffc02025f0:	97ce                	add	a5,a5,s3
ffffffffc02025f2:	00379513          	slli	a0,a5,0x3
ffffffffc02025f6:	00093703          	ld	a4,0(s2)
ffffffffc02025fa:	97aa                	add	a5,a5,a0
ffffffffc02025fc:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0202600:	953a                	add	a0,a0,a4
ffffffffc0202602:	4585                	li	a1,1
ffffffffc0202604:	e8eff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202608:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020260c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020260e:	050a                	slli	a0,a0,0x2
ffffffffc0202610:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202612:	0af57a63          	bgeu	a0,a5,ffffffffc02026c6 <pmm_init+0x602>
    return &pages[PPN(pa) - nbase];
ffffffffc0202616:	013507b3          	add	a5,a0,s3
ffffffffc020261a:	00379513          	slli	a0,a5,0x3
ffffffffc020261e:	00093703          	ld	a4,0(s2)
ffffffffc0202622:	953e                	add	a0,a0,a5
ffffffffc0202624:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202626:	4585                	li	a1,1
ffffffffc0202628:	953a                	add	a0,a0,a4
ffffffffc020262a:	e68ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020262e:	601c                	ld	a5,0(s0)
ffffffffc0202630:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202634:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202638:	ea0ff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc020263c:	50ab1163          	bne	s6,a0,ffffffffc0202b3e <pmm_init+0xa7a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202640:	00004517          	auipc	a0,0x4
ffffffffc0202644:	eb050513          	addi	a0,a0,-336 # ffffffffc02064f0 <default_pmm_manager+0x698>
ffffffffc0202648:	b47fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020264c:	6446                	ld	s0,80(sp)
ffffffffc020264e:	60e6                	ld	ra,88(sp)
ffffffffc0202650:	64a6                	ld	s1,72(sp)
ffffffffc0202652:	6906                	ld	s2,64(sp)
ffffffffc0202654:	79e2                	ld	s3,56(sp)
ffffffffc0202656:	7a42                	ld	s4,48(sp)
ffffffffc0202658:	7aa2                	ld	s5,40(sp)
ffffffffc020265a:	7b02                	ld	s6,32(sp)
ffffffffc020265c:	6be2                	ld	s7,24(sp)
ffffffffc020265e:	6c42                	ld	s8,16(sp)
ffffffffc0202660:	6ca2                	ld	s9,8(sp)
ffffffffc0202662:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202664:	b86ff06f          	j	ffffffffc02019ea <kmalloc_init>
ffffffffc0202668:	6008                	ld	a0,0(s0)
ffffffffc020266a:	bd49                	j	ffffffffc02024fc <pmm_init+0x438>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020266c:	00004697          	auipc	a3,0x4
ffffffffc0202670:	cf468693          	addi	a3,a3,-780 # ffffffffc0206360 <default_pmm_manager+0x508>
ffffffffc0202674:	00003617          	auipc	a2,0x3
ffffffffc0202678:	44c60613          	addi	a2,a2,1100 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020267c:	19d00593          	li	a1,413
ffffffffc0202680:	00004517          	auipc	a0,0x4
ffffffffc0202684:	91850513          	addi	a0,a0,-1768 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202688:	dc5fd0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc020268c:	86d2                	mv	a3,s4
ffffffffc020268e:	00004617          	auipc	a2,0x4
ffffffffc0202692:	81a60613          	addi	a2,a2,-2022 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0202696:	19d00593          	li	a1,413
ffffffffc020269a:	00004517          	auipc	a0,0x4
ffffffffc020269e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02026a2:	dabfd0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02026a6:	00004697          	auipc	a3,0x4
ffffffffc02026aa:	cfa68693          	addi	a3,a3,-774 # ffffffffc02063a0 <default_pmm_manager+0x548>
ffffffffc02026ae:	00003617          	auipc	a2,0x3
ffffffffc02026b2:	41260613          	addi	a2,a2,1042 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02026b6:	19e00593          	li	a1,414
ffffffffc02026ba:	00004517          	auipc	a0,0x4
ffffffffc02026be:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02026c2:	d8bfd0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc02026c6:	d28ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02026ca:	00003617          	auipc	a2,0x3
ffffffffc02026ce:	7de60613          	addi	a2,a2,2014 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc02026d2:	06900593          	li	a1,105
ffffffffc02026d6:	00003517          	auipc	a0,0x3
ffffffffc02026da:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02026de:	d6ffd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026e2:	00004697          	auipc	a3,0x4
ffffffffc02026e6:	98e68693          	addi	a3,a3,-1650 # ffffffffc0206070 <default_pmm_manager+0x218>
ffffffffc02026ea:	00003617          	auipc	a2,0x3
ffffffffc02026ee:	3d660613          	addi	a2,a2,982 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02026f2:	16100593          	li	a1,353
ffffffffc02026f6:	00004517          	auipc	a0,0x4
ffffffffc02026fa:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02026fe:	d4ffd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202702:	00004617          	auipc	a2,0x4
ffffffffc0202706:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206130 <default_pmm_manager+0x2d8>
ffffffffc020270a:	07400593          	li	a1,116
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	7c250513          	addi	a0,a0,1986 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0202716:	d37fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020271a:	00004697          	auipc	a3,0x4
ffffffffc020271e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0206100 <default_pmm_manager+0x2a8>
ffffffffc0202722:	00003617          	auipc	a2,0x3
ffffffffc0202726:	39e60613          	addi	a2,a2,926 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020272a:	16900593          	li	a1,361
ffffffffc020272e:	00004517          	auipc	a0,0x4
ffffffffc0202732:	86a50513          	addi	a0,a0,-1942 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202736:	d17fd0ef          	jal	ra,ffffffffc020044c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020273a:	86da                	mv	a3,s6
ffffffffc020273c:	00003617          	auipc	a2,0x3
ffffffffc0202740:	76c60613          	addi	a2,a2,1900 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0202744:	16e00593          	li	a1,366
ffffffffc0202748:	00004517          	auipc	a0,0x4
ffffffffc020274c:	85050513          	addi	a0,a0,-1968 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202750:	cfdfd0ef          	jal	ra,ffffffffc020044c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202754:	86be                	mv	a3,a5
ffffffffc0202756:	00003617          	auipc	a2,0x3
ffffffffc020275a:	75260613          	addi	a2,a2,1874 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc020275e:	16d00593          	li	a1,365
ffffffffc0202762:	00004517          	auipc	a0,0x4
ffffffffc0202766:	83650513          	addi	a0,a0,-1994 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020276a:	ce3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020276e:	00004697          	auipc	a3,0x4
ffffffffc0202772:	a0268693          	addi	a3,a3,-1534 # ffffffffc0206170 <default_pmm_manager+0x318>
ffffffffc0202776:	00003617          	auipc	a2,0x3
ffffffffc020277a:	34a60613          	addi	a2,a2,842 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020277e:	16b00593          	li	a1,363
ffffffffc0202782:	00004517          	auipc	a0,0x4
ffffffffc0202786:	81650513          	addi	a0,a0,-2026 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020278a:	cc3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020278e:	00004697          	auipc	a3,0x4
ffffffffc0202792:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0206158 <default_pmm_manager+0x300>
ffffffffc0202796:	00003617          	auipc	a2,0x3
ffffffffc020279a:	32a60613          	addi	a2,a2,810 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020279e:	16a00593          	li	a1,362
ffffffffc02027a2:	00003517          	auipc	a0,0x3
ffffffffc02027a6:	7f650513          	addi	a0,a0,2038 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02027aa:	ca3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027ae:	00004697          	auipc	a3,0x4
ffffffffc02027b2:	aba68693          	addi	a3,a3,-1350 # ffffffffc0206268 <default_pmm_manager+0x410>
ffffffffc02027b6:	00003617          	auipc	a2,0x3
ffffffffc02027ba:	30a60613          	addi	a2,a2,778 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02027be:	17900593          	li	a1,377
ffffffffc02027c2:	00003517          	auipc	a0,0x3
ffffffffc02027c6:	7d650513          	addi	a0,a0,2006 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02027ca:	c83fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02027ce:	00004697          	auipc	a3,0x4
ffffffffc02027d2:	a8268693          	addi	a3,a3,-1406 # ffffffffc0206250 <default_pmm_manager+0x3f8>
ffffffffc02027d6:	00003617          	auipc	a2,0x3
ffffffffc02027da:	2ea60613          	addi	a2,a2,746 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02027de:	17700593          	li	a1,375
ffffffffc02027e2:	00003517          	auipc	a0,0x3
ffffffffc02027e6:	7b650513          	addi	a0,a0,1974 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02027ea:	c63fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027ee:	00004697          	auipc	a3,0x4
ffffffffc02027f2:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0206238 <default_pmm_manager+0x3e0>
ffffffffc02027f6:	00003617          	auipc	a2,0x3
ffffffffc02027fa:	2ca60613          	addi	a2,a2,714 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02027fe:	17600593          	li	a1,374
ffffffffc0202802:	00003517          	auipc	a0,0x3
ffffffffc0202806:	79650513          	addi	a0,a0,1942 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020280a:	c43fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*ptep & PTE_W);
ffffffffc020280e:	00004697          	auipc	a3,0x4
ffffffffc0202812:	a1a68693          	addi	a3,a3,-1510 # ffffffffc0206228 <default_pmm_manager+0x3d0>
ffffffffc0202816:	00003617          	auipc	a2,0x3
ffffffffc020281a:	2aa60613          	addi	a2,a2,682 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020281e:	17500593          	li	a1,373
ffffffffc0202822:	00003517          	auipc	a0,0x3
ffffffffc0202826:	77650513          	addi	a0,a0,1910 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020282a:	c23fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*ptep & PTE_U);
ffffffffc020282e:	00004697          	auipc	a3,0x4
ffffffffc0202832:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0206218 <default_pmm_manager+0x3c0>
ffffffffc0202836:	00003617          	auipc	a2,0x3
ffffffffc020283a:	28a60613          	addi	a2,a2,650 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020283e:	17400593          	li	a1,372
ffffffffc0202842:	00003517          	auipc	a0,0x3
ffffffffc0202846:	75650513          	addi	a0,a0,1878 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020284a:	c03fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020284e:	00004697          	auipc	a3,0x4
ffffffffc0202852:	99a68693          	addi	a3,a3,-1638 # ffffffffc02061e8 <default_pmm_manager+0x390>
ffffffffc0202856:	00003617          	auipc	a2,0x3
ffffffffc020285a:	26a60613          	addi	a2,a2,618 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020285e:	17300593          	li	a1,371
ffffffffc0202862:	00003517          	auipc	a0,0x3
ffffffffc0202866:	73650513          	addi	a0,a0,1846 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020286a:	be3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020286e:	00004697          	auipc	a3,0x4
ffffffffc0202872:	94268693          	addi	a3,a3,-1726 # ffffffffc02061b0 <default_pmm_manager+0x358>
ffffffffc0202876:	00003617          	auipc	a2,0x3
ffffffffc020287a:	24a60613          	addi	a2,a2,586 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020287e:	17200593          	li	a1,370
ffffffffc0202882:	00003517          	auipc	a0,0x3
ffffffffc0202886:	71650513          	addi	a0,a0,1814 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020288a:	bc3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020288e:	00004697          	auipc	a3,0x4
ffffffffc0202892:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0206188 <default_pmm_manager+0x330>
ffffffffc0202896:	00003617          	auipc	a2,0x3
ffffffffc020289a:	22a60613          	addi	a2,a2,554 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020289e:	16f00593          	li	a1,367
ffffffffc02028a2:	00003517          	auipc	a0,0x3
ffffffffc02028a6:	6f650513          	addi	a0,a0,1782 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02028aa:	ba3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02028ae:	00004697          	auipc	a3,0x4
ffffffffc02028b2:	a3268693          	addi	a3,a3,-1486 # ffffffffc02062e0 <default_pmm_manager+0x488>
ffffffffc02028b6:	00003617          	auipc	a2,0x3
ffffffffc02028ba:	20a60613          	addi	a2,a2,522 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02028be:	18500593          	li	a1,389
ffffffffc02028c2:	00003517          	auipc	a0,0x3
ffffffffc02028c6:	6d650513          	addi	a0,a0,1750 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02028ca:	b83fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028ce:	00004697          	auipc	a3,0x4
ffffffffc02028d2:	9e268693          	addi	a3,a3,-1566 # ffffffffc02062b0 <default_pmm_manager+0x458>
ffffffffc02028d6:	00003617          	auipc	a2,0x3
ffffffffc02028da:	1ea60613          	addi	a2,a2,490 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02028de:	18200593          	li	a1,386
ffffffffc02028e2:	00003517          	auipc	a0,0x3
ffffffffc02028e6:	6b650513          	addi	a0,a0,1718 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02028ea:	b63fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02028ee:	00004697          	auipc	a3,0x4
ffffffffc02028f2:	88268693          	addi	a3,a3,-1918 # ffffffffc0206170 <default_pmm_manager+0x318>
ffffffffc02028f6:	00003617          	auipc	a2,0x3
ffffffffc02028fa:	1ca60613          	addi	a2,a2,458 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02028fe:	18100593          	li	a1,385
ffffffffc0202902:	00003517          	auipc	a0,0x3
ffffffffc0202906:	69650513          	addi	a0,a0,1686 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020290a:	b43fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020290e:	00004697          	auipc	a3,0x4
ffffffffc0202912:	9ba68693          	addi	a3,a3,-1606 # ffffffffc02062c8 <default_pmm_manager+0x470>
ffffffffc0202916:	00003617          	auipc	a2,0x3
ffffffffc020291a:	1aa60613          	addi	a2,a2,426 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020291e:	17e00593          	li	a1,382
ffffffffc0202922:	00003517          	auipc	a0,0x3
ffffffffc0202926:	67650513          	addi	a0,a0,1654 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020292a:	b23fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020292e:	00004697          	auipc	a3,0x4
ffffffffc0202932:	82a68693          	addi	a3,a3,-2006 # ffffffffc0206158 <default_pmm_manager+0x300>
ffffffffc0202936:	00003617          	auipc	a2,0x3
ffffffffc020293a:	18a60613          	addi	a2,a2,394 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020293e:	17d00593          	li	a1,381
ffffffffc0202942:	00003517          	auipc	a0,0x3
ffffffffc0202946:	65650513          	addi	a0,a0,1622 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020294a:	b03fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020294e:	00004697          	auipc	a3,0x4
ffffffffc0202952:	89a68693          	addi	a3,a3,-1894 # ffffffffc02061e8 <default_pmm_manager+0x390>
ffffffffc0202956:	00003617          	auipc	a2,0x3
ffffffffc020295a:	16a60613          	addi	a2,a2,362 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020295e:	17c00593          	li	a1,380
ffffffffc0202962:	00003517          	auipc	a0,0x3
ffffffffc0202966:	63650513          	addi	a0,a0,1590 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020296a:	ae3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020296e:	00004697          	auipc	a3,0x4
ffffffffc0202972:	94268693          	addi	a3,a3,-1726 # ffffffffc02062b0 <default_pmm_manager+0x458>
ffffffffc0202976:	00003617          	auipc	a2,0x3
ffffffffc020297a:	14a60613          	addi	a2,a2,330 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020297e:	17b00593          	li	a1,379
ffffffffc0202982:	00003517          	auipc	a0,0x3
ffffffffc0202986:	61650513          	addi	a0,a0,1558 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc020298a:	ac3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020298e:	00004697          	auipc	a3,0x4
ffffffffc0202992:	90a68693          	addi	a3,a3,-1782 # ffffffffc0206298 <default_pmm_manager+0x440>
ffffffffc0202996:	00003617          	auipc	a2,0x3
ffffffffc020299a:	12a60613          	addi	a2,a2,298 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020299e:	17a00593          	li	a1,378
ffffffffc02029a2:	00003517          	auipc	a0,0x3
ffffffffc02029a6:	5f650513          	addi	a0,a0,1526 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02029aa:	aa3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029ae:	00004697          	auipc	a3,0x4
ffffffffc02029b2:	97268693          	addi	a3,a3,-1678 # ffffffffc0206320 <default_pmm_manager+0x4c8>
ffffffffc02029b6:	00003617          	auipc	a2,0x3
ffffffffc02029ba:	10a60613          	addi	a2,a2,266 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02029be:	19000593          	li	a1,400
ffffffffc02029c2:	00003517          	auipc	a0,0x3
ffffffffc02029c6:	5d650513          	addi	a0,a0,1494 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02029ca:	a83fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029ce:	00003697          	auipc	a3,0x3
ffffffffc02029d2:	68268693          	addi	a3,a3,1666 # ffffffffc0206050 <default_pmm_manager+0x1f8>
ffffffffc02029d6:	00003617          	auipc	a2,0x3
ffffffffc02029da:	0ea60613          	addi	a2,a2,234 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02029de:	16000593          	li	a1,352
ffffffffc02029e2:	00003517          	auipc	a0,0x3
ffffffffc02029e6:	5b650513          	addi	a0,a0,1462 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc02029ea:	a63fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02029ee:	00004697          	auipc	a3,0x4
ffffffffc02029f2:	9ca68693          	addi	a3,a3,-1590 # ffffffffc02063b8 <default_pmm_manager+0x560>
ffffffffc02029f6:	00003617          	auipc	a2,0x3
ffffffffc02029fa:	0ca60613          	addi	a2,a2,202 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02029fe:	1a100593          	li	a1,417
ffffffffc0202a02:	00003517          	auipc	a0,0x3
ffffffffc0202a06:	59650513          	addi	a0,a0,1430 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202a0a:	a43fd0ef          	jal	ra,ffffffffc020044c <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202a0e:	00003617          	auipc	a2,0x3
ffffffffc0202a12:	4d260613          	addi	a2,a2,1234 # ffffffffc0205ee0 <default_pmm_manager+0x88>
ffffffffc0202a16:	0c300593          	li	a1,195
ffffffffc0202a1a:	00003517          	auipc	a0,0x3
ffffffffc0202a1e:	57e50513          	addi	a0,a0,1406 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202a22:	a2bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202a26:	00004697          	auipc	a3,0x4
ffffffffc0202a2a:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0206460 <default_pmm_manager+0x608>
ffffffffc0202a2e:	00003617          	auipc	a2,0x3
ffffffffc0202a32:	09260613          	addi	a2,a2,146 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202a36:	1a800593          	li	a1,424
ffffffffc0202a3a:	00003517          	auipc	a0,0x3
ffffffffc0202a3e:	55e50513          	addi	a0,a0,1374 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202a42:	a0bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	00004697          	auipc	a3,0x4
ffffffffc0202a4a:	9da68693          	addi	a3,a3,-1574 # ffffffffc0206420 <default_pmm_manager+0x5c8>
ffffffffc0202a4e:	00003617          	auipc	a2,0x3
ffffffffc0202a52:	07260613          	addi	a2,a2,114 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202a56:	1a700593          	li	a1,423
ffffffffc0202a5a:	00003517          	auipc	a0,0x3
ffffffffc0202a5e:	53e50513          	addi	a0,a0,1342 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202a62:	9ebfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202a66:	00004697          	auipc	a3,0x4
ffffffffc0202a6a:	9a268693          	addi	a3,a3,-1630 # ffffffffc0206408 <default_pmm_manager+0x5b0>
ffffffffc0202a6e:	00003617          	auipc	a2,0x3
ffffffffc0202a72:	05260613          	addi	a2,a2,82 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202a76:	1a600593          	li	a1,422
ffffffffc0202a7a:	00003517          	auipc	a0,0x3
ffffffffc0202a7e:	51e50513          	addi	a0,a0,1310 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202a82:	9cbfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a86:	00004697          	auipc	a3,0x4
ffffffffc0202a8a:	94a68693          	addi	a3,a3,-1718 # ffffffffc02063d0 <default_pmm_manager+0x578>
ffffffffc0202a8e:	00003617          	auipc	a2,0x3
ffffffffc0202a92:	03260613          	addi	a2,a2,50 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202a96:	1a500593          	li	a1,421
ffffffffc0202a9a:	00003517          	auipc	a0,0x3
ffffffffc0202a9e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202aa2:	9abfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202aa6:	00004697          	auipc	a3,0x4
ffffffffc0202aaa:	85268693          	addi	a3,a3,-1966 # ffffffffc02062f8 <default_pmm_manager+0x4a0>
ffffffffc0202aae:	00003617          	auipc	a2,0x3
ffffffffc0202ab2:	01260613          	addi	a2,a2,18 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202ab6:	18800593          	li	a1,392
ffffffffc0202aba:	00003517          	auipc	a0,0x3
ffffffffc0202abe:	4de50513          	addi	a0,a0,1246 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202ac2:	98bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ac6:	00003697          	auipc	a3,0x3
ffffffffc0202aca:	7ea68693          	addi	a3,a3,2026 # ffffffffc02062b0 <default_pmm_manager+0x458>
ffffffffc0202ace:	00003617          	auipc	a2,0x3
ffffffffc0202ad2:	ff260613          	addi	a2,a2,-14 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202ad6:	18600593          	li	a1,390
ffffffffc0202ada:	00003517          	auipc	a0,0x3
ffffffffc0202ade:	4be50513          	addi	a0,a0,1214 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202ae2:	96bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202ae6:	00003697          	auipc	a3,0x3
ffffffffc0202aea:	5ea68693          	addi	a3,a3,1514 # ffffffffc02060d0 <default_pmm_manager+0x278>
ffffffffc0202aee:	00003617          	auipc	a2,0x3
ffffffffc0202af2:	fd260613          	addi	a2,a2,-46 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202af6:	16600593          	li	a1,358
ffffffffc0202afa:	00003517          	auipc	a0,0x3
ffffffffc0202afe:	49e50513          	addi	a0,a0,1182 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b02:	94bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202b06:	00003697          	auipc	a3,0x3
ffffffffc0202b0a:	5a268693          	addi	a3,a3,1442 # ffffffffc02060a8 <default_pmm_manager+0x250>
ffffffffc0202b0e:	00003617          	auipc	a2,0x3
ffffffffc0202b12:	fb260613          	addi	a2,a2,-78 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202b16:	16200593          	li	a1,354
ffffffffc0202b1a:	00003517          	auipc	a0,0x3
ffffffffc0202b1e:	47e50513          	addi	a0,a0,1150 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b22:	92bfd0ef          	jal	ra,ffffffffc020044c <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202b26:	00003617          	auipc	a2,0x3
ffffffffc0202b2a:	3ba60613          	addi	a2,a2,954 # ffffffffc0205ee0 <default_pmm_manager+0x88>
ffffffffc0202b2e:	07f00593          	li	a1,127
ffffffffc0202b32:	00003517          	auipc	a0,0x3
ffffffffc0202b36:	46650513          	addi	a0,a0,1126 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b3a:	913fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202b3e:	00003697          	auipc	a3,0x3
ffffffffc0202b42:	7e268693          	addi	a3,a3,2018 # ffffffffc0206320 <default_pmm_manager+0x4c8>
ffffffffc0202b46:	00003617          	auipc	a2,0x3
ffffffffc0202b4a:	f7a60613          	addi	a2,a2,-134 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202b4e:	1b800593          	li	a1,440
ffffffffc0202b52:	00003517          	auipc	a0,0x3
ffffffffc0202b56:	44650513          	addi	a0,a0,1094 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b5a:	8f3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b5e:	00004697          	auipc	a3,0x4
ffffffffc0202b62:	96a68693          	addi	a3,a3,-1686 # ffffffffc02064c8 <default_pmm_manager+0x670>
ffffffffc0202b66:	00003617          	auipc	a2,0x3
ffffffffc0202b6a:	f5a60613          	addi	a2,a2,-166 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202b6e:	1af00593          	li	a1,431
ffffffffc0202b72:	00003517          	auipc	a0,0x3
ffffffffc0202b76:	42650513          	addi	a0,a0,1062 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b7a:	8d3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202b7e:	00004697          	auipc	a3,0x4
ffffffffc0202b82:	91268693          	addi	a3,a3,-1774 # ffffffffc0206490 <default_pmm_manager+0x638>
ffffffffc0202b86:	00003617          	auipc	a2,0x3
ffffffffc0202b8a:	f3a60613          	addi	a2,a2,-198 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202b8e:	1ac00593          	li	a1,428
ffffffffc0202b92:	00003517          	auipc	a0,0x3
ffffffffc0202b96:	40650513          	addi	a0,a0,1030 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202b9a:	8b3fd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0202b9e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b9e:	12058073          	sfence.vma	a1
}
ffffffffc0202ba2:	8082                	ret

ffffffffc0202ba4 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202ba4:	7179                	addi	sp,sp,-48
ffffffffc0202ba6:	e84a                	sd	s2,16(sp)
ffffffffc0202ba8:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202baa:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202bac:	f022                	sd	s0,32(sp)
ffffffffc0202bae:	ec26                	sd	s1,24(sp)
ffffffffc0202bb0:	e44e                	sd	s3,8(sp)
ffffffffc0202bb2:	f406                	sd	ra,40(sp)
ffffffffc0202bb4:	84ae                	mv	s1,a1
ffffffffc0202bb6:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202bb8:	852ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202bbc:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202bbe:	cd19                	beqz	a0,ffffffffc0202bdc <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202bc0:	85aa                	mv	a1,a0
ffffffffc0202bc2:	86ce                	mv	a3,s3
ffffffffc0202bc4:	8626                	mv	a2,s1
ffffffffc0202bc6:	854a                	mv	a0,s2
ffffffffc0202bc8:	c26ff0ef          	jal	ra,ffffffffc0201fee <page_insert>
ffffffffc0202bcc:	ed39                	bnez	a0,ffffffffc0202c2a <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202bce:	00014797          	auipc	a5,0x14
ffffffffc0202bd2:	8e278793          	addi	a5,a5,-1822 # ffffffffc02164b0 <swap_init_ok>
ffffffffc0202bd6:	439c                	lw	a5,0(a5)
ffffffffc0202bd8:	2781                	sext.w	a5,a5
ffffffffc0202bda:	eb89                	bnez	a5,ffffffffc0202bec <pgdir_alloc_page+0x48>
}
ffffffffc0202bdc:	8522                	mv	a0,s0
ffffffffc0202bde:	70a2                	ld	ra,40(sp)
ffffffffc0202be0:	7402                	ld	s0,32(sp)
ffffffffc0202be2:	64e2                	ld	s1,24(sp)
ffffffffc0202be4:	6942                	ld	s2,16(sp)
ffffffffc0202be6:	69a2                	ld	s3,8(sp)
ffffffffc0202be8:	6145                	addi	sp,sp,48
ffffffffc0202bea:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202bec:	00014797          	auipc	a5,0x14
ffffffffc0202bf0:	a0478793          	addi	a5,a5,-1532 # ffffffffc02165f0 <check_mm_struct>
ffffffffc0202bf4:	6388                	ld	a0,0(a5)
ffffffffc0202bf6:	4681                	li	a3,0
ffffffffc0202bf8:	8622                	mv	a2,s0
ffffffffc0202bfa:	85a6                	mv	a1,s1
ffffffffc0202bfc:	7e8000ef          	jal	ra,ffffffffc02033e4 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202c00:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202c02:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202c04:	4785                	li	a5,1
ffffffffc0202c06:	fcf70be3          	beq	a4,a5,ffffffffc0202bdc <pgdir_alloc_page+0x38>
ffffffffc0202c0a:	00003697          	auipc	a3,0x3
ffffffffc0202c0e:	39e68693          	addi	a3,a3,926 # ffffffffc0205fa8 <default_pmm_manager+0x150>
ffffffffc0202c12:	00003617          	auipc	a2,0x3
ffffffffc0202c16:	eae60613          	addi	a2,a2,-338 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0202c1a:	14800593          	li	a1,328
ffffffffc0202c1e:	00003517          	auipc	a0,0x3
ffffffffc0202c22:	37a50513          	addi	a0,a0,890 # ffffffffc0205f98 <default_pmm_manager+0x140>
ffffffffc0202c26:	827fd0ef          	jal	ra,ffffffffc020044c <__panic>
            free_page(page);
ffffffffc0202c2a:	8522                	mv	a0,s0
ffffffffc0202c2c:	4585                	li	a1,1
ffffffffc0202c2e:	864ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
            return NULL;
ffffffffc0202c32:	4401                	li	s0,0
ffffffffc0202c34:	b765                	j	ffffffffc0202bdc <pgdir_alloc_page+0x38>

ffffffffc0202c36 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202c36:	7135                	addi	sp,sp,-160
ffffffffc0202c38:	ed06                	sd	ra,152(sp)
ffffffffc0202c3a:	e922                	sd	s0,144(sp)
ffffffffc0202c3c:	e526                	sd	s1,136(sp)
ffffffffc0202c3e:	e14a                	sd	s2,128(sp)
ffffffffc0202c40:	fcce                	sd	s3,120(sp)
ffffffffc0202c42:	f8d2                	sd	s4,112(sp)
ffffffffc0202c44:	f4d6                	sd	s5,104(sp)
ffffffffc0202c46:	f0da                	sd	s6,96(sp)
ffffffffc0202c48:	ecde                	sd	s7,88(sp)
ffffffffc0202c4a:	e8e2                	sd	s8,80(sp)
ffffffffc0202c4c:	e4e6                	sd	s9,72(sp)
ffffffffc0202c4e:	e0ea                	sd	s10,64(sp)
ffffffffc0202c50:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202c52:	53c010ef          	jal	ra,ffffffffc020418e <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202c56:	00014797          	auipc	a5,0x14
ffffffffc0202c5a:	94a78793          	addi	a5,a5,-1718 # ffffffffc02165a0 <max_swap_offset>
ffffffffc0202c5e:	6394                	ld	a3,0(a5)
ffffffffc0202c60:	010007b7          	lui	a5,0x1000
ffffffffc0202c64:	17e1                	addi	a5,a5,-8
ffffffffc0202c66:	ff968713          	addi	a4,a3,-7
ffffffffc0202c6a:	4ce7ed63          	bltu	a5,a4,ffffffffc0203144 <swap_init+0x50e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202c6e:	00008797          	auipc	a5,0x8
ffffffffc0202c72:	3a278793          	addi	a5,a5,930 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202c76:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202c78:	00014697          	auipc	a3,0x14
ffffffffc0202c7c:	82f6b823          	sd	a5,-2000(a3) # ffffffffc02164a8 <sm>
     int r = sm->init();
ffffffffc0202c80:	9702                	jalr	a4
ffffffffc0202c82:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202c84:	c10d                	beqz	a0,ffffffffc0202ca6 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202c86:	60ea                	ld	ra,152(sp)
ffffffffc0202c88:	644a                	ld	s0,144(sp)
ffffffffc0202c8a:	8556                	mv	a0,s5
ffffffffc0202c8c:	64aa                	ld	s1,136(sp)
ffffffffc0202c8e:	690a                	ld	s2,128(sp)
ffffffffc0202c90:	79e6                	ld	s3,120(sp)
ffffffffc0202c92:	7a46                	ld	s4,112(sp)
ffffffffc0202c94:	7aa6                	ld	s5,104(sp)
ffffffffc0202c96:	7b06                	ld	s6,96(sp)
ffffffffc0202c98:	6be6                	ld	s7,88(sp)
ffffffffc0202c9a:	6c46                	ld	s8,80(sp)
ffffffffc0202c9c:	6ca6                	ld	s9,72(sp)
ffffffffc0202c9e:	6d06                	ld	s10,64(sp)
ffffffffc0202ca0:	7de2                	ld	s11,56(sp)
ffffffffc0202ca2:	610d                	addi	sp,sp,160
ffffffffc0202ca4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ca6:	00014797          	auipc	a5,0x14
ffffffffc0202caa:	80278793          	addi	a5,a5,-2046 # ffffffffc02164a8 <sm>
ffffffffc0202cae:	639c                	ld	a5,0(a5)
ffffffffc0202cb0:	00004517          	auipc	a0,0x4
ffffffffc0202cb4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0206590 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202cb8:	00014417          	auipc	s0,0x14
ffffffffc0202cbc:	82840413          	addi	s0,s0,-2008 # ffffffffc02164e0 <free_area>
ffffffffc0202cc0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202cc2:	4785                	li	a5,1
ffffffffc0202cc4:	00013717          	auipc	a4,0x13
ffffffffc0202cc8:	7ef72623          	sw	a5,2028(a4) # ffffffffc02164b0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ccc:	cc2fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202cd0:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cd2:	38878d63          	beq	a5,s0,ffffffffc020306c <swap_init+0x436>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202cd6:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202cda:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202cdc:	8b05                	andi	a4,a4,1
ffffffffc0202cde:	38070b63          	beqz	a4,ffffffffc0203074 <swap_init+0x43e>
     int ret, count = 0, total = 0, i;
ffffffffc0202ce2:	4481                	li	s1,0
ffffffffc0202ce4:	4901                	li	s2,0
ffffffffc0202ce6:	a031                	j	ffffffffc0202cf2 <swap_init+0xbc>
ffffffffc0202ce8:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202cec:	8b09                	andi	a4,a4,2
ffffffffc0202cee:	38070363          	beqz	a4,ffffffffc0203074 <swap_init+0x43e>
        count ++, total += p->property;
ffffffffc0202cf2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202cf6:	679c                	ld	a5,8(a5)
ffffffffc0202cf8:	2905                	addiw	s2,s2,1
ffffffffc0202cfa:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cfc:	fe8796e3          	bne	a5,s0,ffffffffc0202ce8 <swap_init+0xb2>
ffffffffc0202d00:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202d02:	fd7fe0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0202d06:	6b351763          	bne	a0,s3,ffffffffc02033b4 <swap_init+0x77e>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202d0a:	8626                	mv	a2,s1
ffffffffc0202d0c:	85ca                	mv	a1,s2
ffffffffc0202d0e:	00004517          	auipc	a0,0x4
ffffffffc0202d12:	89a50513          	addi	a0,a0,-1894 # ffffffffc02065a8 <default_pmm_manager+0x750>
ffffffffc0202d16:	c78fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202d1a:	475000ef          	jal	ra,ffffffffc020398e <mm_create>
ffffffffc0202d1e:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202d20:	62050a63          	beqz	a0,ffffffffc0203354 <swap_init+0x71e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202d24:	00014797          	auipc	a5,0x14
ffffffffc0202d28:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02165f0 <check_mm_struct>
ffffffffc0202d2c:	639c                	ld	a5,0(a5)
ffffffffc0202d2e:	64079363          	bnez	a5,ffffffffc0203374 <swap_init+0x73e>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202d32:	00013797          	auipc	a5,0x13
ffffffffc0202d36:	76678793          	addi	a5,a5,1894 # ffffffffc0216498 <boot_pgdir>
ffffffffc0202d3a:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202d3e:	00014797          	auipc	a5,0x14
ffffffffc0202d42:	8aa7b923          	sd	a0,-1870(a5) # ffffffffc02165f0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202d46:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202d4a:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202d4e:	50079763          	bnez	a5,ffffffffc020325c <swap_init+0x626>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202d52:	6599                	lui	a1,0x6
ffffffffc0202d54:	460d                	li	a2,3
ffffffffc0202d56:	6505                	lui	a0,0x1
ffffffffc0202d58:	483000ef          	jal	ra,ffffffffc02039da <vma_create>
ffffffffc0202d5c:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202d5e:	50050f63          	beqz	a0,ffffffffc020327c <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0202d62:	855e                	mv	a0,s7
ffffffffc0202d64:	4e3000ef          	jal	ra,ffffffffc0203a46 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202d68:	00004517          	auipc	a0,0x4
ffffffffc0202d6c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206618 <default_pmm_manager+0x7c0>
ffffffffc0202d70:	c1efd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202d74:	018bb503          	ld	a0,24(s7)
ffffffffc0202d78:	4605                	li	a2,1
ffffffffc0202d7a:	6585                	lui	a1,0x1
ffffffffc0202d7c:	f9dfe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202d80:	50050e63          	beqz	a0,ffffffffc020329c <swap_init+0x666>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202d84:	00004517          	auipc	a0,0x4
ffffffffc0202d88:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206668 <default_pmm_manager+0x810>
ffffffffc0202d8c:	00013997          	auipc	s3,0x13
ffffffffc0202d90:	78c98993          	addi	s3,s3,1932 # ffffffffc0216518 <check_rp>
ffffffffc0202d94:	bfafd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d98:	00013a17          	auipc	s4,0x13
ffffffffc0202d9c:	7a0a0a13          	addi	s4,s4,1952 # ffffffffc0216538 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202da0:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202da2:	4505                	li	a0,1
ffffffffc0202da4:	e67fe0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202da8:	00ac3023          	sd	a0,0(s8) # 80000 <BASE_ADDRESS-0xffffffffc0180000>
          assert(check_rp[i] != NULL );
ffffffffc0202dac:	34050c63          	beqz	a0,ffffffffc0203104 <swap_init+0x4ce>
ffffffffc0202db0:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202db2:	8b89                	andi	a5,a5,2
ffffffffc0202db4:	32079863          	bnez	a5,ffffffffc02030e4 <swap_init+0x4ae>
ffffffffc0202db8:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202dba:	ff4c14e3          	bne	s8,s4,ffffffffc0202da2 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202dbe:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202dc0:	00013c17          	auipc	s8,0x13
ffffffffc0202dc4:	758c0c13          	addi	s8,s8,1880 # ffffffffc0216518 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202dc8:	ec3e                	sd	a5,24(sp)
ffffffffc0202dca:	641c                	ld	a5,8(s0)
ffffffffc0202dcc:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202dce:	481c                	lw	a5,16(s0)
ffffffffc0202dd0:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202dd2:	00013797          	auipc	a5,0x13
ffffffffc0202dd6:	7087bb23          	sd	s0,1814(a5) # ffffffffc02164e8 <free_area+0x8>
ffffffffc0202dda:	00013797          	auipc	a5,0x13
ffffffffc0202dde:	7087b323          	sd	s0,1798(a5) # ffffffffc02164e0 <free_area>
     nr_free = 0;
ffffffffc0202de2:	00013797          	auipc	a5,0x13
ffffffffc0202de6:	7007a723          	sw	zero,1806(a5) # ffffffffc02164f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202dea:	000c3503          	ld	a0,0(s8)
ffffffffc0202dee:	4585                	li	a1,1
ffffffffc0202df0:	0c21                	addi	s8,s8,8
ffffffffc0202df2:	ea1fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202df6:	ff4c1ae3          	bne	s8,s4,ffffffffc0202dea <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202dfa:	01042c03          	lw	s8,16(s0)
ffffffffc0202dfe:	4791                	li	a5,4
ffffffffc0202e00:	52fc1a63          	bne	s8,a5,ffffffffc0203334 <swap_init+0x6fe>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202e04:	00004517          	auipc	a0,0x4
ffffffffc0202e08:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02066f0 <default_pmm_manager+0x898>
ffffffffc0202e0c:	b82fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202e10:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202e12:	00013797          	auipc	a5,0x13
ffffffffc0202e16:	6a07a123          	sw	zero,1698(a5) # ffffffffc02164b4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202e1a:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202e1c:	00013797          	auipc	a5,0x13
ffffffffc0202e20:	69878793          	addi	a5,a5,1688 # ffffffffc02164b4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202e24:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202e28:	4398                	lw	a4,0(a5)
ffffffffc0202e2a:	4585                	li	a1,1
ffffffffc0202e2c:	2701                	sext.w	a4,a4
ffffffffc0202e2e:	3ab71763          	bne	a4,a1,ffffffffc02031dc <swap_init+0x5a6>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202e32:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202e36:	4394                	lw	a3,0(a5)
ffffffffc0202e38:	2681                	sext.w	a3,a3
ffffffffc0202e3a:	3ce69163          	bne	a3,a4,ffffffffc02031fc <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202e3e:	6689                	lui	a3,0x2
ffffffffc0202e40:	462d                	li	a2,11
ffffffffc0202e42:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202e46:	4398                	lw	a4,0(a5)
ffffffffc0202e48:	4589                	li	a1,2
ffffffffc0202e4a:	2701                	sext.w	a4,a4
ffffffffc0202e4c:	30b71863          	bne	a4,a1,ffffffffc020315c <swap_init+0x526>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202e50:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202e54:	4394                	lw	a3,0(a5)
ffffffffc0202e56:	2681                	sext.w	a3,a3
ffffffffc0202e58:	32e69263          	bne	a3,a4,ffffffffc020317c <swap_init+0x546>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202e5c:	668d                	lui	a3,0x3
ffffffffc0202e5e:	4631                	li	a2,12
ffffffffc0202e60:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202e64:	4398                	lw	a4,0(a5)
ffffffffc0202e66:	458d                	li	a1,3
ffffffffc0202e68:	2701                	sext.w	a4,a4
ffffffffc0202e6a:	32b71963          	bne	a4,a1,ffffffffc020319c <swap_init+0x566>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202e6e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202e72:	4394                	lw	a3,0(a5)
ffffffffc0202e74:	2681                	sext.w	a3,a3
ffffffffc0202e76:	34e69363          	bne	a3,a4,ffffffffc02031bc <swap_init+0x586>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202e7a:	6691                	lui	a3,0x4
ffffffffc0202e7c:	4635                	li	a2,13
ffffffffc0202e7e:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202e82:	4398                	lw	a4,0(a5)
ffffffffc0202e84:	2701                	sext.w	a4,a4
ffffffffc0202e86:	39871b63          	bne	a4,s8,ffffffffc020321c <swap_init+0x5e6>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202e8a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202e8e:	439c                	lw	a5,0(a5)
ffffffffc0202e90:	2781                	sext.w	a5,a5
ffffffffc0202e92:	3ae79563          	bne	a5,a4,ffffffffc020323c <swap_init+0x606>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202e96:	481c                	lw	a5,16(s0)
ffffffffc0202e98:	42079263          	bnez	a5,ffffffffc02032bc <swap_init+0x686>
ffffffffc0202e9c:	00013797          	auipc	a5,0x13
ffffffffc0202ea0:	69c78793          	addi	a5,a5,1692 # ffffffffc0216538 <swap_in_seq_no>
ffffffffc0202ea4:	00013717          	auipc	a4,0x13
ffffffffc0202ea8:	6bc70713          	addi	a4,a4,1724 # ffffffffc0216560 <swap_out_seq_no>
ffffffffc0202eac:	00013617          	auipc	a2,0x13
ffffffffc0202eb0:	6b460613          	addi	a2,a2,1716 # ffffffffc0216560 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202eb4:	56fd                	li	a3,-1
ffffffffc0202eb6:	c394                	sw	a3,0(a5)
ffffffffc0202eb8:	c314                	sw	a3,0(a4)
ffffffffc0202eba:	0791                	addi	a5,a5,4
ffffffffc0202ebc:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202ebe:	fef61ce3          	bne	a2,a5,ffffffffc0202eb6 <swap_init+0x280>
ffffffffc0202ec2:	00013817          	auipc	a6,0x13
ffffffffc0202ec6:	6fe80813          	addi	a6,a6,1790 # ffffffffc02165c0 <check_ptep>
ffffffffc0202eca:	00013897          	auipc	a7,0x13
ffffffffc0202ece:	64e88893          	addi	a7,a7,1614 # ffffffffc0216518 <check_rp>
ffffffffc0202ed2:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ed4:	00013c97          	auipc	s9,0x13
ffffffffc0202ed8:	5ccc8c93          	addi	s9,s9,1484 # ffffffffc02164a0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202edc:	00004d97          	auipc	s11,0x4
ffffffffc0202ee0:	324d8d93          	addi	s11,s11,804 # ffffffffc0207200 <nbase>
ffffffffc0202ee4:	00013c17          	auipc	s8,0x13
ffffffffc0202ee8:	62cc0c13          	addi	s8,s8,1580 # ffffffffc0216510 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202eec:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ef0:	4601                	li	a2,0
ffffffffc0202ef2:	85ea                	mv	a1,s10
ffffffffc0202ef4:	855a                	mv	a0,s6
ffffffffc0202ef6:	e846                	sd	a7,16(sp)
         check_ptep[i]=0;
ffffffffc0202ef8:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202efa:	e1ffe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202efe:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202f00:	68c2                	ld	a7,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202f02:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202f06:	20050f63          	beqz	a0,ffffffffc0203124 <swap_init+0x4ee>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f0a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202f0c:	0017f713          	andi	a4,a5,1
ffffffffc0202f10:	1a070e63          	beqz	a4,ffffffffc02030cc <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0202f14:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f18:	078a                	slli	a5,a5,0x2
ffffffffc0202f1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f1c:	16e7fc63          	bgeu	a5,a4,ffffffffc0203094 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f20:	000db703          	ld	a4,0(s11)
ffffffffc0202f24:	000c3603          	ld	a2,0(s8)
ffffffffc0202f28:	0008b583          	ld	a1,0(a7)
ffffffffc0202f2c:	8f99                	sub	a5,a5,a4
ffffffffc0202f2e:	e43a                	sd	a4,8(sp)
ffffffffc0202f30:	00379713          	slli	a4,a5,0x3
ffffffffc0202f34:	97ba                	add	a5,a5,a4
ffffffffc0202f36:	078e                	slli	a5,a5,0x3
ffffffffc0202f38:	97b2                	add	a5,a5,a2
ffffffffc0202f3a:	16f59963          	bne	a1,a5,ffffffffc02030ac <swap_init+0x476>
ffffffffc0202f3e:	6785                	lui	a5,0x1
ffffffffc0202f40:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f42:	6795                	lui	a5,0x5
ffffffffc0202f44:	0821                	addi	a6,a6,8
ffffffffc0202f46:	08a1                	addi	a7,a7,8
ffffffffc0202f48:	fafd12e3          	bne	s10,a5,ffffffffc0202eec <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202f4c:	00004517          	auipc	a0,0x4
ffffffffc0202f50:	84c50513          	addi	a0,a0,-1972 # ffffffffc0206798 <default_pmm_manager+0x940>
ffffffffc0202f54:	a3afd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202f58:	00013797          	auipc	a5,0x13
ffffffffc0202f5c:	55078793          	addi	a5,a5,1360 # ffffffffc02164a8 <sm>
ffffffffc0202f60:	639c                	ld	a5,0(a5)
ffffffffc0202f62:	7f9c                	ld	a5,56(a5)
ffffffffc0202f64:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202f66:	42051763          	bnez	a0,ffffffffc0203394 <swap_init+0x75e>

     nr_free = nr_free_store;
ffffffffc0202f6a:	77a2                	ld	a5,40(sp)
ffffffffc0202f6c:	00013717          	auipc	a4,0x13
ffffffffc0202f70:	58f72223          	sw	a5,1412(a4) # ffffffffc02164f0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202f74:	67e2                	ld	a5,24(sp)
ffffffffc0202f76:	00013717          	auipc	a4,0x13
ffffffffc0202f7a:	56f73523          	sd	a5,1386(a4) # ffffffffc02164e0 <free_area>
ffffffffc0202f7e:	7782                	ld	a5,32(sp)
ffffffffc0202f80:	00013717          	auipc	a4,0x13
ffffffffc0202f84:	56f73423          	sd	a5,1384(a4) # ffffffffc02164e8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202f88:	0009b503          	ld	a0,0(s3)
ffffffffc0202f8c:	4585                	li	a1,1
ffffffffc0202f8e:	09a1                	addi	s3,s3,8
ffffffffc0202f90:	d03fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f94:	ff499ae3          	bne	s3,s4,ffffffffc0202f88 <swap_init+0x352>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202f98:	855e                	mv	a0,s7
ffffffffc0202f9a:	37b000ef          	jal	ra,ffffffffc0203b14 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202f9e:	00013797          	auipc	a5,0x13
ffffffffc0202fa2:	4fa78793          	addi	a5,a5,1274 # ffffffffc0216498 <boot_pgdir>
ffffffffc0202fa6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202fa8:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fac:	6394                	ld	a3,0(a5)
ffffffffc0202fae:	068a                	slli	a3,a3,0x2
ffffffffc0202fb0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fb2:	0ee6f163          	bgeu	a3,a4,ffffffffc0203094 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fb6:	6622                	ld	a2,8(sp)
ffffffffc0202fb8:	000c3503          	ld	a0,0(s8)
ffffffffc0202fbc:	40c687b3          	sub	a5,a3,a2
ffffffffc0202fc0:	00379693          	slli	a3,a5,0x3
ffffffffc0202fc4:	96be                	add	a3,a3,a5
    return page - pages + nbase;
ffffffffc0202fc6:	00003797          	auipc	a5,0x3
ffffffffc0202fca:	ae278793          	addi	a5,a5,-1310 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0202fce:	639c                	ld	a5,0(a5)
    return &pages[PPN(pa) - nbase];
ffffffffc0202fd0:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc0202fd2:	868d                	srai	a3,a3,0x3
ffffffffc0202fd4:	02f686b3          	mul	a3,a3,a5
ffffffffc0202fd8:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202fda:	00c69793          	slli	a5,a3,0xc
ffffffffc0202fde:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fe0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202fe2:	2ee7fd63          	bgeu	a5,a4,ffffffffc02032dc <swap_init+0x6a6>
     free_page(pde2page(pd0[0]));
ffffffffc0202fe6:	00013797          	auipc	a5,0x13
ffffffffc0202fea:	51a78793          	addi	a5,a5,1306 # ffffffffc0216500 <va_pa_offset>
ffffffffc0202fee:	639c                	ld	a5,0(a5)
ffffffffc0202ff0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ff2:	629c                	ld	a5,0(a3)
ffffffffc0202ff4:	078a                	slli	a5,a5,0x2
ffffffffc0202ff6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ff8:	08e7fe63          	bgeu	a5,a4,ffffffffc0203094 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ffc:	69a2                	ld	s3,8(sp)
ffffffffc0202ffe:	4585                	li	a1,1
ffffffffc0203000:	413787b3          	sub	a5,a5,s3
ffffffffc0203004:	00379713          	slli	a4,a5,0x3
ffffffffc0203008:	97ba                	add	a5,a5,a4
ffffffffc020300a:	078e                	slli	a5,a5,0x3
ffffffffc020300c:	953e                	add	a0,a0,a5
ffffffffc020300e:	c85fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203012:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203016:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020301a:	078a                	slli	a5,a5,0x2
ffffffffc020301c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020301e:	06e7fb63          	bgeu	a5,a4,ffffffffc0203094 <swap_init+0x45e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203022:	413787b3          	sub	a5,a5,s3
ffffffffc0203026:	00379713          	slli	a4,a5,0x3
ffffffffc020302a:	000c3503          	ld	a0,0(s8)
ffffffffc020302e:	97ba                	add	a5,a5,a4
ffffffffc0203030:	078e                	slli	a5,a5,0x3
     free_page(pde2page(pd1[0]));
ffffffffc0203032:	4585                	li	a1,1
ffffffffc0203034:	953e                	add	a0,a0,a5
ffffffffc0203036:	c5dfe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     pgdir[0] = 0;
ffffffffc020303a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020303e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203042:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203044:	00878963          	beq	a5,s0,ffffffffc0203056 <swap_init+0x420>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203048:	ff87a703          	lw	a4,-8(a5)
ffffffffc020304c:	679c                	ld	a5,8(a5)
ffffffffc020304e:	397d                	addiw	s2,s2,-1
ffffffffc0203050:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203052:	fe879be3          	bne	a5,s0,ffffffffc0203048 <swap_init+0x412>
     }
     assert(count==0);
ffffffffc0203056:	28091f63          	bnez	s2,ffffffffc02032f4 <swap_init+0x6be>
     assert(total==0);
ffffffffc020305a:	2a049d63          	bnez	s1,ffffffffc0203314 <swap_init+0x6de>

     cprintf("check_swap() succeeded!\n");
ffffffffc020305e:	00003517          	auipc	a0,0x3
ffffffffc0203062:	78a50513          	addi	a0,a0,1930 # ffffffffc02067e8 <default_pmm_manager+0x990>
ffffffffc0203066:	928fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020306a:	b931                	j	ffffffffc0202c86 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020306c:	4481                	li	s1,0
ffffffffc020306e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203070:	4981                	li	s3,0
ffffffffc0203072:	b941                	j	ffffffffc0202d02 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203074:	00003697          	auipc	a3,0x3
ffffffffc0203078:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0205ab0 <commands+0x8c8>
ffffffffc020307c:	00003617          	auipc	a2,0x3
ffffffffc0203080:	a4460613          	addi	a2,a2,-1468 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203084:	0bd00593          	li	a1,189
ffffffffc0203088:	00003517          	auipc	a0,0x3
ffffffffc020308c:	4f850513          	addi	a0,a0,1272 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203090:	bbcfd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203094:	00003617          	auipc	a2,0x3
ffffffffc0203098:	e7460613          	addi	a2,a2,-396 # ffffffffc0205f08 <default_pmm_manager+0xb0>
ffffffffc020309c:	06200593          	li	a1,98
ffffffffc02030a0:	00003517          	auipc	a0,0x3
ffffffffc02030a4:	e3050513          	addi	a0,a0,-464 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02030a8:	ba4fd0ef          	jal	ra,ffffffffc020044c <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02030ac:	00003697          	auipc	a3,0x3
ffffffffc02030b0:	6c468693          	addi	a3,a3,1732 # ffffffffc0206770 <default_pmm_manager+0x918>
ffffffffc02030b4:	00003617          	auipc	a2,0x3
ffffffffc02030b8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02030bc:	0fd00593          	li	a1,253
ffffffffc02030c0:	00003517          	auipc	a0,0x3
ffffffffc02030c4:	4c050513          	addi	a0,a0,1216 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02030c8:	b84fd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02030cc:	00003617          	auipc	a2,0x3
ffffffffc02030d0:	06460613          	addi	a2,a2,100 # ffffffffc0206130 <default_pmm_manager+0x2d8>
ffffffffc02030d4:	07400593          	li	a1,116
ffffffffc02030d8:	00003517          	auipc	a0,0x3
ffffffffc02030dc:	df850513          	addi	a0,a0,-520 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02030e0:	b6cfd0ef          	jal	ra,ffffffffc020044c <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02030e4:	00003697          	auipc	a3,0x3
ffffffffc02030e8:	5c468693          	addi	a3,a3,1476 # ffffffffc02066a8 <default_pmm_manager+0x850>
ffffffffc02030ec:	00003617          	auipc	a2,0x3
ffffffffc02030f0:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02030f4:	0de00593          	li	a1,222
ffffffffc02030f8:	00003517          	auipc	a0,0x3
ffffffffc02030fc:	48850513          	addi	a0,a0,1160 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203100:	b4cfd0ef          	jal	ra,ffffffffc020044c <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203104:	00003697          	auipc	a3,0x3
ffffffffc0203108:	58c68693          	addi	a3,a3,1420 # ffffffffc0206690 <default_pmm_manager+0x838>
ffffffffc020310c:	00003617          	auipc	a2,0x3
ffffffffc0203110:	9b460613          	addi	a2,a2,-1612 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203114:	0dd00593          	li	a1,221
ffffffffc0203118:	00003517          	auipc	a0,0x3
ffffffffc020311c:	46850513          	addi	a0,a0,1128 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203120:	b2cfd0ef          	jal	ra,ffffffffc020044c <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203124:	00003697          	auipc	a3,0x3
ffffffffc0203128:	63468693          	addi	a3,a3,1588 # ffffffffc0206758 <default_pmm_manager+0x900>
ffffffffc020312c:	00003617          	auipc	a2,0x3
ffffffffc0203130:	99460613          	addi	a2,a2,-1644 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203134:	0fc00593          	li	a1,252
ffffffffc0203138:	00003517          	auipc	a0,0x3
ffffffffc020313c:	44850513          	addi	a0,a0,1096 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203140:	b0cfd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203144:	00003617          	auipc	a2,0x3
ffffffffc0203148:	41c60613          	addi	a2,a2,1052 # ffffffffc0206560 <default_pmm_manager+0x708>
ffffffffc020314c:	02a00593          	li	a1,42
ffffffffc0203150:	00003517          	auipc	a0,0x3
ffffffffc0203154:	43050513          	addi	a0,a0,1072 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203158:	af4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==2);
ffffffffc020315c:	00003697          	auipc	a3,0x3
ffffffffc0203160:	5cc68693          	addi	a3,a3,1484 # ffffffffc0206728 <default_pmm_manager+0x8d0>
ffffffffc0203164:	00003617          	auipc	a2,0x3
ffffffffc0203168:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020316c:	09800593          	li	a1,152
ffffffffc0203170:	00003517          	auipc	a0,0x3
ffffffffc0203174:	41050513          	addi	a0,a0,1040 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203178:	ad4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==2);
ffffffffc020317c:	00003697          	auipc	a3,0x3
ffffffffc0203180:	5ac68693          	addi	a3,a3,1452 # ffffffffc0206728 <default_pmm_manager+0x8d0>
ffffffffc0203184:	00003617          	auipc	a2,0x3
ffffffffc0203188:	93c60613          	addi	a2,a2,-1732 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020318c:	09a00593          	li	a1,154
ffffffffc0203190:	00003517          	auipc	a0,0x3
ffffffffc0203194:	3f050513          	addi	a0,a0,1008 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203198:	ab4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==3);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	59c68693          	addi	a3,a3,1436 # ffffffffc0206738 <default_pmm_manager+0x8e0>
ffffffffc02031a4:	00003617          	auipc	a2,0x3
ffffffffc02031a8:	91c60613          	addi	a2,a2,-1764 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02031ac:	09c00593          	li	a1,156
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	3d050513          	addi	a0,a0,976 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02031b8:	a94fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==3);
ffffffffc02031bc:	00003697          	auipc	a3,0x3
ffffffffc02031c0:	57c68693          	addi	a3,a3,1404 # ffffffffc0206738 <default_pmm_manager+0x8e0>
ffffffffc02031c4:	00003617          	auipc	a2,0x3
ffffffffc02031c8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02031cc:	09e00593          	li	a1,158
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	3b050513          	addi	a0,a0,944 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02031d8:	a74fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==1);
ffffffffc02031dc:	00003697          	auipc	a3,0x3
ffffffffc02031e0:	53c68693          	addi	a3,a3,1340 # ffffffffc0206718 <default_pmm_manager+0x8c0>
ffffffffc02031e4:	00003617          	auipc	a2,0x3
ffffffffc02031e8:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02031ec:	09400593          	li	a1,148
ffffffffc02031f0:	00003517          	auipc	a0,0x3
ffffffffc02031f4:	39050513          	addi	a0,a0,912 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02031f8:	a54fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==1);
ffffffffc02031fc:	00003697          	auipc	a3,0x3
ffffffffc0203200:	51c68693          	addi	a3,a3,1308 # ffffffffc0206718 <default_pmm_manager+0x8c0>
ffffffffc0203204:	00003617          	auipc	a2,0x3
ffffffffc0203208:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020320c:	09600593          	li	a1,150
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	37050513          	addi	a0,a0,880 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203218:	a34fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==4);
ffffffffc020321c:	00003697          	auipc	a3,0x3
ffffffffc0203220:	52c68693          	addi	a3,a3,1324 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc0203224:	00003617          	auipc	a2,0x3
ffffffffc0203228:	89c60613          	addi	a2,a2,-1892 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020322c:	0a000593          	li	a1,160
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	35050513          	addi	a0,a0,848 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203238:	a14fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==4);
ffffffffc020323c:	00003697          	auipc	a3,0x3
ffffffffc0203240:	50c68693          	addi	a3,a3,1292 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc0203244:	00003617          	auipc	a2,0x3
ffffffffc0203248:	87c60613          	addi	a2,a2,-1924 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020324c:	0a200593          	li	a1,162
ffffffffc0203250:	00003517          	auipc	a0,0x3
ffffffffc0203254:	33050513          	addi	a0,a0,816 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203258:	9f4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgdir[0] == 0);
ffffffffc020325c:	00003697          	auipc	a3,0x3
ffffffffc0203260:	39c68693          	addi	a3,a3,924 # ffffffffc02065f8 <default_pmm_manager+0x7a0>
ffffffffc0203264:	00003617          	auipc	a2,0x3
ffffffffc0203268:	85c60613          	addi	a2,a2,-1956 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020326c:	0cd00593          	li	a1,205
ffffffffc0203270:	00003517          	auipc	a0,0x3
ffffffffc0203274:	31050513          	addi	a0,a0,784 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203278:	9d4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(vma != NULL);
ffffffffc020327c:	00003697          	auipc	a3,0x3
ffffffffc0203280:	38c68693          	addi	a3,a3,908 # ffffffffc0206608 <default_pmm_manager+0x7b0>
ffffffffc0203284:	00003617          	auipc	a2,0x3
ffffffffc0203288:	83c60613          	addi	a2,a2,-1988 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020328c:	0d000593          	li	a1,208
ffffffffc0203290:	00003517          	auipc	a0,0x3
ffffffffc0203294:	2f050513          	addi	a0,a0,752 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203298:	9b4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020329c:	00003697          	auipc	a3,0x3
ffffffffc02032a0:	3b468693          	addi	a3,a3,948 # ffffffffc0206650 <default_pmm_manager+0x7f8>
ffffffffc02032a4:	00003617          	auipc	a2,0x3
ffffffffc02032a8:	81c60613          	addi	a2,a2,-2020 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02032ac:	0d800593          	li	a1,216
ffffffffc02032b0:	00003517          	auipc	a0,0x3
ffffffffc02032b4:	2d050513          	addi	a0,a0,720 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02032b8:	994fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert( nr_free == 0);         
ffffffffc02032bc:	00003697          	auipc	a3,0x3
ffffffffc02032c0:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205c98 <commands+0xab0>
ffffffffc02032c4:	00002617          	auipc	a2,0x2
ffffffffc02032c8:	7fc60613          	addi	a2,a2,2044 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02032cc:	0f400593          	li	a1,244
ffffffffc02032d0:	00003517          	auipc	a0,0x3
ffffffffc02032d4:	2b050513          	addi	a0,a0,688 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02032d8:	974fd0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc02032dc:	00003617          	auipc	a2,0x3
ffffffffc02032e0:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc02032e4:	06900593          	li	a1,105
ffffffffc02032e8:	00003517          	auipc	a0,0x3
ffffffffc02032ec:	be850513          	addi	a0,a0,-1048 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02032f0:	95cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(count==0);
ffffffffc02032f4:	00003697          	auipc	a3,0x3
ffffffffc02032f8:	4d468693          	addi	a3,a3,1236 # ffffffffc02067c8 <default_pmm_manager+0x970>
ffffffffc02032fc:	00002617          	auipc	a2,0x2
ffffffffc0203300:	7c460613          	addi	a2,a2,1988 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203304:	11c00593          	li	a1,284
ffffffffc0203308:	00003517          	auipc	a0,0x3
ffffffffc020330c:	27850513          	addi	a0,a0,632 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203310:	93cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(total==0);
ffffffffc0203314:	00003697          	auipc	a3,0x3
ffffffffc0203318:	4c468693          	addi	a3,a3,1220 # ffffffffc02067d8 <default_pmm_manager+0x980>
ffffffffc020331c:	00002617          	auipc	a2,0x2
ffffffffc0203320:	7a460613          	addi	a2,a2,1956 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203324:	11d00593          	li	a1,285
ffffffffc0203328:	00003517          	auipc	a0,0x3
ffffffffc020332c:	25850513          	addi	a0,a0,600 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203330:	91cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203334:	00003697          	auipc	a3,0x3
ffffffffc0203338:	39468693          	addi	a3,a3,916 # ffffffffc02066c8 <default_pmm_manager+0x870>
ffffffffc020333c:	00002617          	auipc	a2,0x2
ffffffffc0203340:	78460613          	addi	a2,a2,1924 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203344:	0eb00593          	li	a1,235
ffffffffc0203348:	00003517          	auipc	a0,0x3
ffffffffc020334c:	23850513          	addi	a0,a0,568 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203350:	8fcfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(mm != NULL);
ffffffffc0203354:	00003697          	auipc	a3,0x3
ffffffffc0203358:	27c68693          	addi	a3,a3,636 # ffffffffc02065d0 <default_pmm_manager+0x778>
ffffffffc020335c:	00002617          	auipc	a2,0x2
ffffffffc0203360:	76460613          	addi	a2,a2,1892 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203364:	0c500593          	li	a1,197
ffffffffc0203368:	00003517          	auipc	a0,0x3
ffffffffc020336c:	21850513          	addi	a0,a0,536 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203370:	8dcfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203374:	00003697          	auipc	a3,0x3
ffffffffc0203378:	26c68693          	addi	a3,a3,620 # ffffffffc02065e0 <default_pmm_manager+0x788>
ffffffffc020337c:	00002617          	auipc	a2,0x2
ffffffffc0203380:	74460613          	addi	a2,a2,1860 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203384:	0c800593          	li	a1,200
ffffffffc0203388:	00003517          	auipc	a0,0x3
ffffffffc020338c:	1f850513          	addi	a0,a0,504 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203390:	8bcfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(ret==0);
ffffffffc0203394:	00003697          	auipc	a3,0x3
ffffffffc0203398:	42c68693          	addi	a3,a3,1068 # ffffffffc02067c0 <default_pmm_manager+0x968>
ffffffffc020339c:	00002617          	auipc	a2,0x2
ffffffffc02033a0:	72460613          	addi	a2,a2,1828 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02033a4:	10300593          	li	a1,259
ffffffffc02033a8:	00003517          	auipc	a0,0x3
ffffffffc02033ac:	1d850513          	addi	a0,a0,472 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02033b0:	89cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(total == nr_free_pages());
ffffffffc02033b4:	00002697          	auipc	a3,0x2
ffffffffc02033b8:	73c68693          	addi	a3,a3,1852 # ffffffffc0205af0 <commands+0x908>
ffffffffc02033bc:	00002617          	auipc	a2,0x2
ffffffffc02033c0:	70460613          	addi	a2,a2,1796 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02033c4:	0c000593          	li	a1,192
ffffffffc02033c8:	00003517          	auipc	a0,0x3
ffffffffc02033cc:	1b850513          	addi	a0,a0,440 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc02033d0:	87cfd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02033d4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02033d4:	00013797          	auipc	a5,0x13
ffffffffc02033d8:	0d478793          	addi	a5,a5,212 # ffffffffc02164a8 <sm>
ffffffffc02033dc:	639c                	ld	a5,0(a5)
ffffffffc02033de:	0107b303          	ld	t1,16(a5)
ffffffffc02033e2:	8302                	jr	t1

ffffffffc02033e4 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02033e4:	00013797          	auipc	a5,0x13
ffffffffc02033e8:	0c478793          	addi	a5,a5,196 # ffffffffc02164a8 <sm>
ffffffffc02033ec:	639c                	ld	a5,0(a5)
ffffffffc02033ee:	0207b303          	ld	t1,32(a5)
ffffffffc02033f2:	8302                	jr	t1

ffffffffc02033f4 <swap_out>:
{
ffffffffc02033f4:	711d                	addi	sp,sp,-96
ffffffffc02033f6:	ec86                	sd	ra,88(sp)
ffffffffc02033f8:	e8a2                	sd	s0,80(sp)
ffffffffc02033fa:	e4a6                	sd	s1,72(sp)
ffffffffc02033fc:	e0ca                	sd	s2,64(sp)
ffffffffc02033fe:	fc4e                	sd	s3,56(sp)
ffffffffc0203400:	f852                	sd	s4,48(sp)
ffffffffc0203402:	f456                	sd	s5,40(sp)
ffffffffc0203404:	f05a                	sd	s6,32(sp)
ffffffffc0203406:	ec5e                	sd	s7,24(sp)
ffffffffc0203408:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020340a:	cde9                	beqz	a1,ffffffffc02034e4 <swap_out+0xf0>
ffffffffc020340c:	8ab2                	mv	s5,a2
ffffffffc020340e:	892a                	mv	s2,a0
ffffffffc0203410:	8a2e                	mv	s4,a1
ffffffffc0203412:	4401                	li	s0,0
ffffffffc0203414:	00013997          	auipc	s3,0x13
ffffffffc0203418:	09498993          	addi	s3,s3,148 # ffffffffc02164a8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020341c:	00003b17          	auipc	s6,0x3
ffffffffc0203420:	44cb0b13          	addi	s6,s6,1100 # ffffffffc0206868 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203424:	00003b97          	auipc	s7,0x3
ffffffffc0203428:	42cb8b93          	addi	s7,s7,1068 # ffffffffc0206850 <default_pmm_manager+0x9f8>
ffffffffc020342c:	a825                	j	ffffffffc0203464 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020342e:	67a2                	ld	a5,8(sp)
ffffffffc0203430:	8626                	mv	a2,s1
ffffffffc0203432:	85a2                	mv	a1,s0
ffffffffc0203434:	63b4                	ld	a3,64(a5)
ffffffffc0203436:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203438:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020343a:	82b1                	srli	a3,a3,0xc
ffffffffc020343c:	0685                	addi	a3,a3,1
ffffffffc020343e:	d51fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203442:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203444:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203446:	613c                	ld	a5,64(a0)
ffffffffc0203448:	83b1                	srli	a5,a5,0xc
ffffffffc020344a:	0785                	addi	a5,a5,1
ffffffffc020344c:	07a2                	slli	a5,a5,0x8
ffffffffc020344e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203452:	841fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203456:	01893503          	ld	a0,24(s2)
ffffffffc020345a:	85a6                	mv	a1,s1
ffffffffc020345c:	f42ff0ef          	jal	ra,ffffffffc0202b9e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203460:	048a0d63          	beq	s4,s0,ffffffffc02034ba <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203464:	0009b783          	ld	a5,0(s3)
ffffffffc0203468:	8656                	mv	a2,s5
ffffffffc020346a:	002c                	addi	a1,sp,8
ffffffffc020346c:	7b9c                	ld	a5,48(a5)
ffffffffc020346e:	854a                	mv	a0,s2
ffffffffc0203470:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203472:	e12d                	bnez	a0,ffffffffc02034d4 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203474:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203476:	01893503          	ld	a0,24(s2)
ffffffffc020347a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020347c:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020347e:	85a6                	mv	a1,s1
ffffffffc0203480:	899fe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203484:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203486:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203488:	8b85                	andi	a5,a5,1
ffffffffc020348a:	cfb9                	beqz	a5,ffffffffc02034e8 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020348c:	65a2                	ld	a1,8(sp)
ffffffffc020348e:	61bc                	ld	a5,64(a1)
ffffffffc0203490:	83b1                	srli	a5,a5,0xc
ffffffffc0203492:	00178513          	addi	a0,a5,1
ffffffffc0203496:	0522                	slli	a0,a0,0x8
ffffffffc0203498:	5d5000ef          	jal	ra,ffffffffc020426c <swapfs_write>
ffffffffc020349c:	d949                	beqz	a0,ffffffffc020342e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020349e:	855e                	mv	a0,s7
ffffffffc02034a0:	ceffc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02034a4:	0009b783          	ld	a5,0(s3)
ffffffffc02034a8:	6622                	ld	a2,8(sp)
ffffffffc02034aa:	4681                	li	a3,0
ffffffffc02034ac:	739c                	ld	a5,32(a5)
ffffffffc02034ae:	85a6                	mv	a1,s1
ffffffffc02034b0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02034b2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02034b4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02034b6:	fa8a17e3          	bne	s4,s0,ffffffffc0203464 <swap_out+0x70>
}
ffffffffc02034ba:	8522                	mv	a0,s0
ffffffffc02034bc:	60e6                	ld	ra,88(sp)
ffffffffc02034be:	6446                	ld	s0,80(sp)
ffffffffc02034c0:	64a6                	ld	s1,72(sp)
ffffffffc02034c2:	6906                	ld	s2,64(sp)
ffffffffc02034c4:	79e2                	ld	s3,56(sp)
ffffffffc02034c6:	7a42                	ld	s4,48(sp)
ffffffffc02034c8:	7aa2                	ld	s5,40(sp)
ffffffffc02034ca:	7b02                	ld	s6,32(sp)
ffffffffc02034cc:	6be2                	ld	s7,24(sp)
ffffffffc02034ce:	6c42                	ld	s8,16(sp)
ffffffffc02034d0:	6125                	addi	sp,sp,96
ffffffffc02034d2:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02034d4:	85a2                	mv	a1,s0
ffffffffc02034d6:	00003517          	auipc	a0,0x3
ffffffffc02034da:	33250513          	addi	a0,a0,818 # ffffffffc0206808 <default_pmm_manager+0x9b0>
ffffffffc02034de:	cb1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc02034e2:	bfe1                	j	ffffffffc02034ba <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02034e4:	4401                	li	s0,0
ffffffffc02034e6:	bfd1                	j	ffffffffc02034ba <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02034e8:	00003697          	auipc	a3,0x3
ffffffffc02034ec:	35068693          	addi	a3,a3,848 # ffffffffc0206838 <default_pmm_manager+0x9e0>
ffffffffc02034f0:	00002617          	auipc	a2,0x2
ffffffffc02034f4:	5d060613          	addi	a2,a2,1488 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02034f8:	06900593          	li	a1,105
ffffffffc02034fc:	00003517          	auipc	a0,0x3
ffffffffc0203500:	08450513          	addi	a0,a0,132 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc0203504:	f49fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203508 <swap_in>:
{
ffffffffc0203508:	7179                	addi	sp,sp,-48
ffffffffc020350a:	e84a                	sd	s2,16(sp)
ffffffffc020350c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020350e:	4505                	li	a0,1
{
ffffffffc0203510:	ec26                	sd	s1,24(sp)
ffffffffc0203512:	e44e                	sd	s3,8(sp)
ffffffffc0203514:	f406                	sd	ra,40(sp)
ffffffffc0203516:	f022                	sd	s0,32(sp)
ffffffffc0203518:	84ae                	mv	s1,a1
ffffffffc020351a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020351c:	eeefe0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203520:	c129                	beqz	a0,ffffffffc0203562 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203522:	842a                	mv	s0,a0
ffffffffc0203524:	01893503          	ld	a0,24(s2)
ffffffffc0203528:	4601                	li	a2,0
ffffffffc020352a:	85a6                	mv	a1,s1
ffffffffc020352c:	fecfe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0203530:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203532:	6108                	ld	a0,0(a0)
ffffffffc0203534:	85a2                	mv	a1,s0
ffffffffc0203536:	491000ef          	jal	ra,ffffffffc02041c6 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020353a:	00093583          	ld	a1,0(s2)
ffffffffc020353e:	8626                	mv	a2,s1
ffffffffc0203540:	00003517          	auipc	a0,0x3
ffffffffc0203544:	fe050513          	addi	a0,a0,-32 # ffffffffc0206520 <default_pmm_manager+0x6c8>
ffffffffc0203548:	81a1                	srli	a1,a1,0x8
ffffffffc020354a:	c45fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020354e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203550:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203554:	7402                	ld	s0,32(sp)
ffffffffc0203556:	64e2                	ld	s1,24(sp)
ffffffffc0203558:	6942                	ld	s2,16(sp)
ffffffffc020355a:	69a2                	ld	s3,8(sp)
ffffffffc020355c:	4501                	li	a0,0
ffffffffc020355e:	6145                	addi	sp,sp,48
ffffffffc0203560:	8082                	ret
     assert(result!=NULL);
ffffffffc0203562:	00003697          	auipc	a3,0x3
ffffffffc0203566:	fae68693          	addi	a3,a3,-82 # ffffffffc0206510 <default_pmm_manager+0x6b8>
ffffffffc020356a:	00002617          	auipc	a2,0x2
ffffffffc020356e:	55660613          	addi	a2,a2,1366 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203572:	07f00593          	li	a1,127
ffffffffc0203576:	00003517          	auipc	a0,0x3
ffffffffc020357a:	00a50513          	addi	a0,a0,10 # ffffffffc0206580 <default_pmm_manager+0x728>
ffffffffc020357e:	ecffc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203582 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203582:	00013797          	auipc	a5,0x13
ffffffffc0203586:	05e78793          	addi	a5,a5,94 # ffffffffc02165e0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020358a:	f51c                	sd	a5,40(a0)
ffffffffc020358c:	e79c                	sd	a5,8(a5)
ffffffffc020358e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203590:	4501                	li	a0,0
ffffffffc0203592:	8082                	ret

ffffffffc0203594 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203594:	4501                	li	a0,0
ffffffffc0203596:	8082                	ret

ffffffffc0203598 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203598:	4501                	li	a0,0
ffffffffc020359a:	8082                	ret

ffffffffc020359c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020359c:	4501                	li	a0,0
ffffffffc020359e:	8082                	ret

ffffffffc02035a0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02035a0:	711d                	addi	sp,sp,-96
ffffffffc02035a2:	fc4e                	sd	s3,56(sp)
ffffffffc02035a4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02035a6:	00003517          	auipc	a0,0x3
ffffffffc02035aa:	30250513          	addi	a0,a0,770 # ffffffffc02068a8 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035ae:	698d                	lui	s3,0x3
ffffffffc02035b0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02035b2:	e8a2                	sd	s0,80(sp)
ffffffffc02035b4:	e4a6                	sd	s1,72(sp)
ffffffffc02035b6:	ec86                	sd	ra,88(sp)
ffffffffc02035b8:	e0ca                	sd	s2,64(sp)
ffffffffc02035ba:	f456                	sd	s5,40(sp)
ffffffffc02035bc:	f05a                	sd	s6,32(sp)
ffffffffc02035be:	ec5e                	sd	s7,24(sp)
ffffffffc02035c0:	e862                	sd	s8,16(sp)
ffffffffc02035c2:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02035c4:	00013417          	auipc	s0,0x13
ffffffffc02035c8:	ef040413          	addi	s0,s0,-272 # ffffffffc02164b4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02035cc:	bc3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035d0:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02035d4:	4004                	lw	s1,0(s0)
ffffffffc02035d6:	4791                	li	a5,4
ffffffffc02035d8:	2481                	sext.w	s1,s1
ffffffffc02035da:	14f49963          	bne	s1,a5,ffffffffc020372c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035de:	00003517          	auipc	a0,0x3
ffffffffc02035e2:	30a50513          	addi	a0,a0,778 # ffffffffc02068e8 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035e6:	6a85                	lui	s5,0x1
ffffffffc02035e8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035ea:	ba5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035ee:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02035f2:	00042903          	lw	s2,0(s0)
ffffffffc02035f6:	2901                	sext.w	s2,s2
ffffffffc02035f8:	2a991a63          	bne	s2,s1,ffffffffc02038ac <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035fc:	00003517          	auipc	a0,0x3
ffffffffc0203600:	31450513          	addi	a0,a0,788 # ffffffffc0206910 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203604:	6b91                	lui	s7,0x4
ffffffffc0203606:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203608:	b87fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020360c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203610:	4004                	lw	s1,0(s0)
ffffffffc0203612:	2481                	sext.w	s1,s1
ffffffffc0203614:	27249c63          	bne	s1,s2,ffffffffc020388c <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203618:	00003517          	auipc	a0,0x3
ffffffffc020361c:	32050513          	addi	a0,a0,800 # ffffffffc0206938 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203620:	6909                	lui	s2,0x2
ffffffffc0203622:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203624:	b6bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203628:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020362c:	401c                	lw	a5,0(s0)
ffffffffc020362e:	2781                	sext.w	a5,a5
ffffffffc0203630:	22979e63          	bne	a5,s1,ffffffffc020386c <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203634:	00003517          	auipc	a0,0x3
ffffffffc0203638:	32c50513          	addi	a0,a0,812 # ffffffffc0206960 <default_pmm_manager+0xb08>
ffffffffc020363c:	b53fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203640:	6795                	lui	a5,0x5
ffffffffc0203642:	4739                	li	a4,14
ffffffffc0203644:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203648:	4004                	lw	s1,0(s0)
ffffffffc020364a:	4795                	li	a5,5
ffffffffc020364c:	2481                	sext.w	s1,s1
ffffffffc020364e:	1ef49f63          	bne	s1,a5,ffffffffc020384c <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203652:	00003517          	auipc	a0,0x3
ffffffffc0203656:	2e650513          	addi	a0,a0,742 # ffffffffc0206938 <default_pmm_manager+0xae0>
ffffffffc020365a:	b35fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020365e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203662:	401c                	lw	a5,0(s0)
ffffffffc0203664:	2781                	sext.w	a5,a5
ffffffffc0203666:	1c979363          	bne	a5,s1,ffffffffc020382c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020366a:	00003517          	auipc	a0,0x3
ffffffffc020366e:	27e50513          	addi	a0,a0,638 # ffffffffc02068e8 <default_pmm_manager+0xa90>
ffffffffc0203672:	b1dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203676:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020367a:	401c                	lw	a5,0(s0)
ffffffffc020367c:	4719                	li	a4,6
ffffffffc020367e:	2781                	sext.w	a5,a5
ffffffffc0203680:	18e79663          	bne	a5,a4,ffffffffc020380c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203684:	00003517          	auipc	a0,0x3
ffffffffc0203688:	2b450513          	addi	a0,a0,692 # ffffffffc0206938 <default_pmm_manager+0xae0>
ffffffffc020368c:	b03fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203690:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203694:	401c                	lw	a5,0(s0)
ffffffffc0203696:	471d                	li	a4,7
ffffffffc0203698:	2781                	sext.w	a5,a5
ffffffffc020369a:	14e79963          	bne	a5,a4,ffffffffc02037ec <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020369e:	00003517          	auipc	a0,0x3
ffffffffc02036a2:	20a50513          	addi	a0,a0,522 # ffffffffc02068a8 <default_pmm_manager+0xa50>
ffffffffc02036a6:	ae9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02036aa:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02036ae:	401c                	lw	a5,0(s0)
ffffffffc02036b0:	4721                	li	a4,8
ffffffffc02036b2:	2781                	sext.w	a5,a5
ffffffffc02036b4:	10e79c63          	bne	a5,a4,ffffffffc02037cc <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02036b8:	00003517          	auipc	a0,0x3
ffffffffc02036bc:	25850513          	addi	a0,a0,600 # ffffffffc0206910 <default_pmm_manager+0xab8>
ffffffffc02036c0:	acffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02036c4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02036c8:	401c                	lw	a5,0(s0)
ffffffffc02036ca:	4725                	li	a4,9
ffffffffc02036cc:	2781                	sext.w	a5,a5
ffffffffc02036ce:	0ce79f63          	bne	a5,a4,ffffffffc02037ac <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02036d2:	00003517          	auipc	a0,0x3
ffffffffc02036d6:	28e50513          	addi	a0,a0,654 # ffffffffc0206960 <default_pmm_manager+0xb08>
ffffffffc02036da:	ab5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02036de:	6795                	lui	a5,0x5
ffffffffc02036e0:	4739                	li	a4,14
ffffffffc02036e2:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02036e6:	4004                	lw	s1,0(s0)
ffffffffc02036e8:	47a9                	li	a5,10
ffffffffc02036ea:	2481                	sext.w	s1,s1
ffffffffc02036ec:	0af49063          	bne	s1,a5,ffffffffc020378c <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02036f0:	00003517          	auipc	a0,0x3
ffffffffc02036f4:	1f850513          	addi	a0,a0,504 # ffffffffc02068e8 <default_pmm_manager+0xa90>
ffffffffc02036f8:	a97fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02036fc:	6785                	lui	a5,0x1
ffffffffc02036fe:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203702:	06979563          	bne	a5,s1,ffffffffc020376c <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203706:	401c                	lw	a5,0(s0)
ffffffffc0203708:	472d                	li	a4,11
ffffffffc020370a:	2781                	sext.w	a5,a5
ffffffffc020370c:	04e79063          	bne	a5,a4,ffffffffc020374c <_fifo_check_swap+0x1ac>
}
ffffffffc0203710:	60e6                	ld	ra,88(sp)
ffffffffc0203712:	6446                	ld	s0,80(sp)
ffffffffc0203714:	64a6                	ld	s1,72(sp)
ffffffffc0203716:	6906                	ld	s2,64(sp)
ffffffffc0203718:	79e2                	ld	s3,56(sp)
ffffffffc020371a:	7a42                	ld	s4,48(sp)
ffffffffc020371c:	7aa2                	ld	s5,40(sp)
ffffffffc020371e:	7b02                	ld	s6,32(sp)
ffffffffc0203720:	6be2                	ld	s7,24(sp)
ffffffffc0203722:	6c42                	ld	s8,16(sp)
ffffffffc0203724:	6ca2                	ld	s9,8(sp)
ffffffffc0203726:	4501                	li	a0,0
ffffffffc0203728:	6125                	addi	sp,sp,96
ffffffffc020372a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020372c:	00003697          	auipc	a3,0x3
ffffffffc0203730:	01c68693          	addi	a3,a3,28 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc0203734:	00002617          	auipc	a2,0x2
ffffffffc0203738:	38c60613          	addi	a2,a2,908 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020373c:	05100593          	li	a1,81
ffffffffc0203740:	00003517          	auipc	a0,0x3
ffffffffc0203744:	19050513          	addi	a0,a0,400 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203748:	d05fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==11);
ffffffffc020374c:	00003697          	auipc	a3,0x3
ffffffffc0203750:	2c468693          	addi	a3,a3,708 # ffffffffc0206a10 <default_pmm_manager+0xbb8>
ffffffffc0203754:	00002617          	auipc	a2,0x2
ffffffffc0203758:	36c60613          	addi	a2,a2,876 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020375c:	07300593          	li	a1,115
ffffffffc0203760:	00003517          	auipc	a0,0x3
ffffffffc0203764:	17050513          	addi	a0,a0,368 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203768:	ce5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020376c:	00003697          	auipc	a3,0x3
ffffffffc0203770:	27c68693          	addi	a3,a3,636 # ffffffffc02069e8 <default_pmm_manager+0xb90>
ffffffffc0203774:	00002617          	auipc	a2,0x2
ffffffffc0203778:	34c60613          	addi	a2,a2,844 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020377c:	07100593          	li	a1,113
ffffffffc0203780:	00003517          	auipc	a0,0x3
ffffffffc0203784:	15050513          	addi	a0,a0,336 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203788:	cc5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==10);
ffffffffc020378c:	00003697          	auipc	a3,0x3
ffffffffc0203790:	24c68693          	addi	a3,a3,588 # ffffffffc02069d8 <default_pmm_manager+0xb80>
ffffffffc0203794:	00002617          	auipc	a2,0x2
ffffffffc0203798:	32c60613          	addi	a2,a2,812 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020379c:	06f00593          	li	a1,111
ffffffffc02037a0:	00003517          	auipc	a0,0x3
ffffffffc02037a4:	13050513          	addi	a0,a0,304 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc02037a8:	ca5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==9);
ffffffffc02037ac:	00003697          	auipc	a3,0x3
ffffffffc02037b0:	21c68693          	addi	a3,a3,540 # ffffffffc02069c8 <default_pmm_manager+0xb70>
ffffffffc02037b4:	00002617          	auipc	a2,0x2
ffffffffc02037b8:	30c60613          	addi	a2,a2,780 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02037bc:	06c00593          	li	a1,108
ffffffffc02037c0:	00003517          	auipc	a0,0x3
ffffffffc02037c4:	11050513          	addi	a0,a0,272 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc02037c8:	c85fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==8);
ffffffffc02037cc:	00003697          	auipc	a3,0x3
ffffffffc02037d0:	1ec68693          	addi	a3,a3,492 # ffffffffc02069b8 <default_pmm_manager+0xb60>
ffffffffc02037d4:	00002617          	auipc	a2,0x2
ffffffffc02037d8:	2ec60613          	addi	a2,a2,748 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02037dc:	06900593          	li	a1,105
ffffffffc02037e0:	00003517          	auipc	a0,0x3
ffffffffc02037e4:	0f050513          	addi	a0,a0,240 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc02037e8:	c65fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==7);
ffffffffc02037ec:	00003697          	auipc	a3,0x3
ffffffffc02037f0:	1bc68693          	addi	a3,a3,444 # ffffffffc02069a8 <default_pmm_manager+0xb50>
ffffffffc02037f4:	00002617          	auipc	a2,0x2
ffffffffc02037f8:	2cc60613          	addi	a2,a2,716 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02037fc:	06600593          	li	a1,102
ffffffffc0203800:	00003517          	auipc	a0,0x3
ffffffffc0203804:	0d050513          	addi	a0,a0,208 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203808:	c45fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==6);
ffffffffc020380c:	00003697          	auipc	a3,0x3
ffffffffc0203810:	18c68693          	addi	a3,a3,396 # ffffffffc0206998 <default_pmm_manager+0xb40>
ffffffffc0203814:	00002617          	auipc	a2,0x2
ffffffffc0203818:	2ac60613          	addi	a2,a2,684 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020381c:	06300593          	li	a1,99
ffffffffc0203820:	00003517          	auipc	a0,0x3
ffffffffc0203824:	0b050513          	addi	a0,a0,176 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203828:	c25fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==5);
ffffffffc020382c:	00003697          	auipc	a3,0x3
ffffffffc0203830:	15c68693          	addi	a3,a3,348 # ffffffffc0206988 <default_pmm_manager+0xb30>
ffffffffc0203834:	00002617          	auipc	a2,0x2
ffffffffc0203838:	28c60613          	addi	a2,a2,652 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020383c:	06000593          	li	a1,96
ffffffffc0203840:	00003517          	auipc	a0,0x3
ffffffffc0203844:	09050513          	addi	a0,a0,144 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203848:	c05fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==5);
ffffffffc020384c:	00003697          	auipc	a3,0x3
ffffffffc0203850:	13c68693          	addi	a3,a3,316 # ffffffffc0206988 <default_pmm_manager+0xb30>
ffffffffc0203854:	00002617          	auipc	a2,0x2
ffffffffc0203858:	26c60613          	addi	a2,a2,620 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020385c:	05d00593          	li	a1,93
ffffffffc0203860:	00003517          	auipc	a0,0x3
ffffffffc0203864:	07050513          	addi	a0,a0,112 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203868:	be5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc020386c:	00003697          	auipc	a3,0x3
ffffffffc0203870:	edc68693          	addi	a3,a3,-292 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc0203874:	00002617          	auipc	a2,0x2
ffffffffc0203878:	24c60613          	addi	a2,a2,588 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020387c:	05a00593          	li	a1,90
ffffffffc0203880:	00003517          	auipc	a0,0x3
ffffffffc0203884:	05050513          	addi	a0,a0,80 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc0203888:	bc5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc020388c:	00003697          	auipc	a3,0x3
ffffffffc0203890:	ebc68693          	addi	a3,a3,-324 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc0203894:	00002617          	auipc	a2,0x2
ffffffffc0203898:	22c60613          	addi	a2,a2,556 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020389c:	05700593          	li	a1,87
ffffffffc02038a0:	00003517          	auipc	a0,0x3
ffffffffc02038a4:	03050513          	addi	a0,a0,48 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc02038a8:	ba5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc02038ac:	00003697          	auipc	a3,0x3
ffffffffc02038b0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0206748 <default_pmm_manager+0x8f0>
ffffffffc02038b4:	00002617          	auipc	a2,0x2
ffffffffc02038b8:	20c60613          	addi	a2,a2,524 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02038bc:	05400593          	li	a1,84
ffffffffc02038c0:	00003517          	auipc	a0,0x3
ffffffffc02038c4:	01050513          	addi	a0,a0,16 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc02038c8:	b85fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02038cc <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02038cc:	751c                	ld	a5,40(a0)
{
ffffffffc02038ce:	1141                	addi	sp,sp,-16
ffffffffc02038d0:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02038d2:	cf91                	beqz	a5,ffffffffc02038ee <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02038d4:	ee0d                	bnez	a2,ffffffffc020390e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02038d6:	679c                	ld	a5,8(a5)
}
ffffffffc02038d8:	60a2                	ld	ra,8(sp)
ffffffffc02038da:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02038dc:	6394                	ld	a3,0(a5)
ffffffffc02038de:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02038e0:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02038e4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02038e6:	e314                	sd	a3,0(a4)
ffffffffc02038e8:	e19c                	sd	a5,0(a1)
}
ffffffffc02038ea:	0141                	addi	sp,sp,16
ffffffffc02038ec:	8082                	ret
         assert(head != NULL);
ffffffffc02038ee:	00003697          	auipc	a3,0x3
ffffffffc02038f2:	15268693          	addi	a3,a3,338 # ffffffffc0206a40 <default_pmm_manager+0xbe8>
ffffffffc02038f6:	00002617          	auipc	a2,0x2
ffffffffc02038fa:	1ca60613          	addi	a2,a2,458 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02038fe:	04100593          	li	a1,65
ffffffffc0203902:	00003517          	auipc	a0,0x3
ffffffffc0203906:	fce50513          	addi	a0,a0,-50 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc020390a:	b43fc0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(in_tick==0);
ffffffffc020390e:	00003697          	auipc	a3,0x3
ffffffffc0203912:	14268693          	addi	a3,a3,322 # ffffffffc0206a50 <default_pmm_manager+0xbf8>
ffffffffc0203916:	00002617          	auipc	a2,0x2
ffffffffc020391a:	1aa60613          	addi	a2,a2,426 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020391e:	04200593          	li	a1,66
ffffffffc0203922:	00003517          	auipc	a0,0x3
ffffffffc0203926:	fae50513          	addi	a0,a0,-82 # ffffffffc02068d0 <default_pmm_manager+0xa78>
ffffffffc020392a:	b23fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020392e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020392e:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203932:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203934:	cb09                	beqz	a4,ffffffffc0203946 <_fifo_map_swappable+0x18>
ffffffffc0203936:	cb81                	beqz	a5,ffffffffc0203946 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203938:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020393a:	e398                	sd	a4,0(a5)
}
ffffffffc020393c:	4501                	li	a0,0
ffffffffc020393e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203940:	fe1c                	sd	a5,56(a2)
    elm->prev = prev;
ffffffffc0203942:	fa14                	sd	a3,48(a2)
ffffffffc0203944:	8082                	ret
{
ffffffffc0203946:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203948:	00003697          	auipc	a3,0x3
ffffffffc020394c:	0d868693          	addi	a3,a3,216 # ffffffffc0206a20 <default_pmm_manager+0xbc8>
ffffffffc0203950:	00002617          	auipc	a2,0x2
ffffffffc0203954:	17060613          	addi	a2,a2,368 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203958:	03200593          	li	a1,50
ffffffffc020395c:	00003517          	auipc	a0,0x3
ffffffffc0203960:	f7450513          	addi	a0,a0,-140 # ffffffffc02068d0 <default_pmm_manager+0xa78>
{
ffffffffc0203964:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203966:	ae7fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020396a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020396a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020396c:	00003697          	auipc	a3,0x3
ffffffffc0203970:	10c68693          	addi	a3,a3,268 # ffffffffc0206a78 <default_pmm_manager+0xc20>
ffffffffc0203974:	00002617          	auipc	a2,0x2
ffffffffc0203978:	14c60613          	addi	a2,a2,332 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc020397c:	07e00593          	li	a1,126
ffffffffc0203980:	00003517          	auipc	a0,0x3
ffffffffc0203984:	11850513          	addi	a0,a0,280 # ffffffffc0206a98 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203988:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020398a:	ac3fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020398e <mm_create>:
mm_create(void) {
ffffffffc020398e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203990:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203994:	e022                	sd	s0,0(sp)
ffffffffc0203996:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203998:	872fe0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
ffffffffc020399c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020399e:	c115                	beqz	a0,ffffffffc02039c2 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039a0:	00013797          	auipc	a5,0x13
ffffffffc02039a4:	b1078793          	addi	a5,a5,-1264 # ffffffffc02164b0 <swap_init_ok>
ffffffffc02039a8:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02039aa:	e408                	sd	a0,8(s0)
ffffffffc02039ac:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02039ae:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02039b2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039b6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039ba:	2781                	sext.w	a5,a5
ffffffffc02039bc:	eb81                	bnez	a5,ffffffffc02039cc <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02039be:	02053423          	sd	zero,40(a0)
}
ffffffffc02039c2:	8522                	mv	a0,s0
ffffffffc02039c4:	60a2                	ld	ra,8(sp)
ffffffffc02039c6:	6402                	ld	s0,0(sp)
ffffffffc02039c8:	0141                	addi	sp,sp,16
ffffffffc02039ca:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039cc:	a09ff0ef          	jal	ra,ffffffffc02033d4 <swap_init_mm>
}
ffffffffc02039d0:	8522                	mv	a0,s0
ffffffffc02039d2:	60a2                	ld	ra,8(sp)
ffffffffc02039d4:	6402                	ld	s0,0(sp)
ffffffffc02039d6:	0141                	addi	sp,sp,16
ffffffffc02039d8:	8082                	ret

ffffffffc02039da <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02039da:	1101                	addi	sp,sp,-32
ffffffffc02039dc:	e04a                	sd	s2,0(sp)
ffffffffc02039de:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039e0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02039e4:	e822                	sd	s0,16(sp)
ffffffffc02039e6:	e426                	sd	s1,8(sp)
ffffffffc02039e8:	ec06                	sd	ra,24(sp)
ffffffffc02039ea:	84ae                	mv	s1,a1
ffffffffc02039ec:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ee:	81cfe0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
    if (vma != NULL) {
ffffffffc02039f2:	c509                	beqz	a0,ffffffffc02039fc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02039f4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039f8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039fa:	cd00                	sw	s0,24(a0)
}
ffffffffc02039fc:	60e2                	ld	ra,24(sp)
ffffffffc02039fe:	6442                	ld	s0,16(sp)
ffffffffc0203a00:	64a2                	ld	s1,8(sp)
ffffffffc0203a02:	6902                	ld	s2,0(sp)
ffffffffc0203a04:	6105                	addi	sp,sp,32
ffffffffc0203a06:	8082                	ret

ffffffffc0203a08 <find_vma>:
    if (mm != NULL) {
ffffffffc0203a08:	c51d                	beqz	a0,ffffffffc0203a36 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0203a0a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203a0c:	c781                	beqz	a5,ffffffffc0203a14 <find_vma+0xc>
ffffffffc0203a0e:	6798                	ld	a4,8(a5)
ffffffffc0203a10:	02e5f663          	bgeu	a1,a4,ffffffffc0203a3c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203a14:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203a16:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203a18:	00f50f63          	beq	a0,a5,ffffffffc0203a36 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203a1c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203a20:	fee5ebe3          	bltu	a1,a4,ffffffffc0203a16 <find_vma+0xe>
ffffffffc0203a24:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203a28:	fee5f7e3          	bgeu	a1,a4,ffffffffc0203a16 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203a2c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203a2e:	c781                	beqz	a5,ffffffffc0203a36 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203a30:	e91c                	sd	a5,16(a0)
}
ffffffffc0203a32:	853e                	mv	a0,a5
ffffffffc0203a34:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203a36:	4781                	li	a5,0
}
ffffffffc0203a38:	853e                	mv	a0,a5
ffffffffc0203a3a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203a3c:	6b98                	ld	a4,16(a5)
ffffffffc0203a3e:	fce5fbe3          	bgeu	a1,a4,ffffffffc0203a14 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203a42:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203a44:	b7fd                	j	ffffffffc0203a32 <find_vma+0x2a>

ffffffffc0203a46 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a46:	6590                	ld	a2,8(a1)
ffffffffc0203a48:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203a4c:	1141                	addi	sp,sp,-16
ffffffffc0203a4e:	e406                	sd	ra,8(sp)
ffffffffc0203a50:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203a52:	01066863          	bltu	a2,a6,ffffffffc0203a62 <insert_vma_struct+0x1c>
ffffffffc0203a56:	a8b9                	j	ffffffffc0203ab4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203a58:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203a5c:	04d66763          	bltu	a2,a3,ffffffffc0203aaa <insert_vma_struct+0x64>
ffffffffc0203a60:	873e                	mv	a4,a5
ffffffffc0203a62:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203a64:	fef51ae3          	bne	a0,a5,ffffffffc0203a58 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203a68:	02a70463          	beq	a4,a0,ffffffffc0203a90 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203a6c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203a70:	fe873883          	ld	a7,-24(a4)
ffffffffc0203a74:	08d8f063          	bgeu	a7,a3,ffffffffc0203af4 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a78:	04d66e63          	bltu	a2,a3,ffffffffc0203ad4 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203a7c:	00f50a63          	beq	a0,a5,ffffffffc0203a90 <insert_vma_struct+0x4a>
ffffffffc0203a80:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a84:	0506e863          	bltu	a3,a6,ffffffffc0203ad4 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203a88:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203a8c:	02c6f263          	bgeu	a3,a2,ffffffffc0203ab0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203a90:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203a92:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203a94:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203a98:	e390                	sd	a2,0(a5)
ffffffffc0203a9a:	e710                	sd	a2,8(a4)
}
ffffffffc0203a9c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203a9e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203aa0:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203aa2:	2685                	addiw	a3,a3,1
ffffffffc0203aa4:	d114                	sw	a3,32(a0)
}
ffffffffc0203aa6:	0141                	addi	sp,sp,16
ffffffffc0203aa8:	8082                	ret
    if (le_prev != list) {
ffffffffc0203aaa:	fca711e3          	bne	a4,a0,ffffffffc0203a6c <insert_vma_struct+0x26>
ffffffffc0203aae:	bfd9                	j	ffffffffc0203a84 <insert_vma_struct+0x3e>
ffffffffc0203ab0:	ebbff0ef          	jal	ra,ffffffffc020396a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203ab4:	00003697          	auipc	a3,0x3
ffffffffc0203ab8:	09468693          	addi	a3,a3,148 # ffffffffc0206b48 <default_pmm_manager+0xcf0>
ffffffffc0203abc:	00002617          	auipc	a2,0x2
ffffffffc0203ac0:	00460613          	addi	a2,a2,4 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203ac4:	08500593          	li	a1,133
ffffffffc0203ac8:	00003517          	auipc	a0,0x3
ffffffffc0203acc:	fd050513          	addi	a0,a0,-48 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203ad0:	97dfc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203ad4:	00003697          	auipc	a3,0x3
ffffffffc0203ad8:	0b468693          	addi	a3,a3,180 # ffffffffc0206b88 <default_pmm_manager+0xd30>
ffffffffc0203adc:	00002617          	auipc	a2,0x2
ffffffffc0203ae0:	fe460613          	addi	a2,a2,-28 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203ae4:	07d00593          	li	a1,125
ffffffffc0203ae8:	00003517          	auipc	a0,0x3
ffffffffc0203aec:	fb050513          	addi	a0,a0,-80 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203af0:	95dfc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203af4:	00003697          	auipc	a3,0x3
ffffffffc0203af8:	07468693          	addi	a3,a3,116 # ffffffffc0206b68 <default_pmm_manager+0xd10>
ffffffffc0203afc:	00002617          	auipc	a2,0x2
ffffffffc0203b00:	fc460613          	addi	a2,a2,-60 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203b04:	07c00593          	li	a1,124
ffffffffc0203b08:	00003517          	auipc	a0,0x3
ffffffffc0203b0c:	f9050513          	addi	a0,a0,-112 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203b10:	93dfc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203b14 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203b14:	1141                	addi	sp,sp,-16
ffffffffc0203b16:	e022                	sd	s0,0(sp)
ffffffffc0203b18:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203b1a:	6508                	ld	a0,8(a0)
ffffffffc0203b1c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203b1e:	00a40c63          	beq	s0,a0,ffffffffc0203b36 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b22:	6118                	ld	a4,0(a0)
ffffffffc0203b24:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203b26:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b28:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b2a:	e398                	sd	a4,0(a5)
ffffffffc0203b2c:	f9bfd0ef          	jal	ra,ffffffffc0201ac6 <kfree>
    return listelm->next;
ffffffffc0203b30:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203b32:	fea418e3          	bne	s0,a0,ffffffffc0203b22 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203b36:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203b38:	6402                	ld	s0,0(sp)
ffffffffc0203b3a:	60a2                	ld	ra,8(sp)
ffffffffc0203b3c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203b3e:	f89fd06f          	j	ffffffffc0201ac6 <kfree>

ffffffffc0203b42 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203b42:	7139                	addi	sp,sp,-64
ffffffffc0203b44:	f822                	sd	s0,48(sp)
ffffffffc0203b46:	f426                	sd	s1,40(sp)
ffffffffc0203b48:	fc06                	sd	ra,56(sp)
ffffffffc0203b4a:	f04a                	sd	s2,32(sp)
ffffffffc0203b4c:	ec4e                	sd	s3,24(sp)
ffffffffc0203b4e:	e852                	sd	s4,16(sp)
ffffffffc0203b50:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203b52:	e3dff0ef          	jal	ra,ffffffffc020398e <mm_create>
    assert(mm != NULL);
ffffffffc0203b56:	842a                	mv	s0,a0
ffffffffc0203b58:	03200493          	li	s1,50
ffffffffc0203b5c:	e919                	bnez	a0,ffffffffc0203b72 <vmm_init+0x30>
ffffffffc0203b5e:	a98d                	j	ffffffffc0203fd0 <vmm_init+0x48e>
        vma->vm_start = vm_start;
ffffffffc0203b60:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b62:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b64:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b68:	14ed                	addi	s1,s1,-5
ffffffffc0203b6a:	8522                	mv	a0,s0
ffffffffc0203b6c:	edbff0ef          	jal	ra,ffffffffc0203a46 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203b70:	c88d                	beqz	s1,ffffffffc0203ba2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b72:	03000513          	li	a0,48
ffffffffc0203b76:	e95fd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
ffffffffc0203b7a:	85aa                	mv	a1,a0
ffffffffc0203b7c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203b80:	f165                	bnez	a0,ffffffffc0203b60 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203b82:	00003697          	auipc	a3,0x3
ffffffffc0203b86:	a8668693          	addi	a3,a3,-1402 # ffffffffc0206608 <default_pmm_manager+0x7b0>
ffffffffc0203b8a:	00002617          	auipc	a2,0x2
ffffffffc0203b8e:	f3660613          	addi	a2,a2,-202 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203b92:	0c900593          	li	a1,201
ffffffffc0203b96:	00003517          	auipc	a0,0x3
ffffffffc0203b9a:	f0250513          	addi	a0,a0,-254 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203b9e:	8affc0ef          	jal	ra,ffffffffc020044c <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203ba2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203ba6:	1f900913          	li	s2,505
ffffffffc0203baa:	a819                	j	ffffffffc0203bc0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203bac:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203bae:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bb0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bb4:	0495                	addi	s1,s1,5
ffffffffc0203bb6:	8522                	mv	a0,s0
ffffffffc0203bb8:	e8fff0ef          	jal	ra,ffffffffc0203a46 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203bbc:	03248a63          	beq	s1,s2,ffffffffc0203bf0 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203bc0:	03000513          	li	a0,48
ffffffffc0203bc4:	e47fd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
ffffffffc0203bc8:	85aa                	mv	a1,a0
ffffffffc0203bca:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203bce:	fd79                	bnez	a0,ffffffffc0203bac <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203bd0:	00003697          	auipc	a3,0x3
ffffffffc0203bd4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206608 <default_pmm_manager+0x7b0>
ffffffffc0203bd8:	00002617          	auipc	a2,0x2
ffffffffc0203bdc:	ee860613          	addi	a2,a2,-280 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203be0:	0cf00593          	li	a1,207
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	eb450513          	addi	a0,a0,-332 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203bec:	861fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0203bf0:	6418                	ld	a4,8(s0)
ffffffffc0203bf2:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203bf4:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203bf8:	30e40063          	beq	s0,a4,ffffffffc0203ef8 <vmm_init+0x3b6>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bfc:	fe873603          	ld	a2,-24(a4)
ffffffffc0203c00:	ffe78693          	addi	a3,a5,-2
ffffffffc0203c04:	26d61a63          	bne	a2,a3,ffffffffc0203e78 <vmm_init+0x336>
ffffffffc0203c08:	ff073683          	ld	a3,-16(a4)
ffffffffc0203c0c:	26f69663          	bne	a3,a5,ffffffffc0203e78 <vmm_init+0x336>
ffffffffc0203c10:	0795                	addi	a5,a5,5
ffffffffc0203c12:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203c14:	feb792e3          	bne	a5,a1,ffffffffc0203bf8 <vmm_init+0xb6>
ffffffffc0203c18:	491d                	li	s2,7
ffffffffc0203c1a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203c1c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c20:	85a6                	mv	a1,s1
ffffffffc0203c22:	8522                	mv	a0,s0
ffffffffc0203c24:	de5ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
ffffffffc0203c28:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203c2a:	32050763          	beqz	a0,ffffffffc0203f58 <vmm_init+0x416>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203c2e:	00148593          	addi	a1,s1,1
ffffffffc0203c32:	8522                	mv	a0,s0
ffffffffc0203c34:	dd5ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
ffffffffc0203c38:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203c3a:	2e050f63          	beqz	a0,ffffffffc0203f38 <vmm_init+0x3f6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203c3e:	85ca                	mv	a1,s2
ffffffffc0203c40:	8522                	mv	a0,s0
ffffffffc0203c42:	dc7ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203c46:	2c051963          	bnez	a0,ffffffffc0203f18 <vmm_init+0x3d6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203c4a:	00348593          	addi	a1,s1,3
ffffffffc0203c4e:	8522                	mv	a0,s0
ffffffffc0203c50:	db9ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203c54:	34051263          	bnez	a0,ffffffffc0203f98 <vmm_init+0x456>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203c58:	00448593          	addi	a1,s1,4
ffffffffc0203c5c:	8522                	mv	a0,s0
ffffffffc0203c5e:	dabff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203c62:	30051b63          	bnez	a0,ffffffffc0203f78 <vmm_init+0x436>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203c66:	008a3783          	ld	a5,8(s4)
ffffffffc0203c6a:	22979763          	bne	a5,s1,ffffffffc0203e98 <vmm_init+0x356>
ffffffffc0203c6e:	010a3783          	ld	a5,16(s4)
ffffffffc0203c72:	23279363          	bne	a5,s2,ffffffffc0203e98 <vmm_init+0x356>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203c76:	0089b783          	ld	a5,8(s3)
ffffffffc0203c7a:	22979f63          	bne	a5,s1,ffffffffc0203eb8 <vmm_init+0x376>
ffffffffc0203c7e:	0109b783          	ld	a5,16(s3)
ffffffffc0203c82:	23279b63          	bne	a5,s2,ffffffffc0203eb8 <vmm_init+0x376>
ffffffffc0203c86:	0495                	addi	s1,s1,5
ffffffffc0203c88:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203c8a:	f9549be3          	bne	s1,s5,ffffffffc0203c20 <vmm_init+0xde>
ffffffffc0203c8e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203c90:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203c92:	85a6                	mv	a1,s1
ffffffffc0203c94:	8522                	mv	a0,s0
ffffffffc0203c96:	d73ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
ffffffffc0203c9a:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203c9e:	c90d                	beqz	a0,ffffffffc0203cd0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203ca0:	6914                	ld	a3,16(a0)
ffffffffc0203ca2:	6510                	ld	a2,8(a0)
ffffffffc0203ca4:	00003517          	auipc	a0,0x3
ffffffffc0203ca8:	00450513          	addi	a0,a0,4 # ffffffffc0206ca8 <default_pmm_manager+0xe50>
ffffffffc0203cac:	ce2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203cb0:	00003697          	auipc	a3,0x3
ffffffffc0203cb4:	02068693          	addi	a3,a3,32 # ffffffffc0206cd0 <default_pmm_manager+0xe78>
ffffffffc0203cb8:	00002617          	auipc	a2,0x2
ffffffffc0203cbc:	e0860613          	addi	a2,a2,-504 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203cc0:	0f100593          	li	a1,241
ffffffffc0203cc4:	00003517          	auipc	a0,0x3
ffffffffc0203cc8:	dd450513          	addi	a0,a0,-556 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203ccc:	f80fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0203cd0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203cd2:	fd2490e3          	bne	s1,s2,ffffffffc0203c92 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203cd6:	8522                	mv	a0,s0
ffffffffc0203cd8:	e3dff0ef          	jal	ra,ffffffffc0203b14 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203cdc:	00003517          	auipc	a0,0x3
ffffffffc0203ce0:	00c50513          	addi	a0,a0,12 # ffffffffc0206ce8 <default_pmm_manager+0xe90>
ffffffffc0203ce4:	caafc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203ce8:	ff1fd0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0203cec:	8a2a                	mv	s4,a0

    check_mm_struct = mm_create();
ffffffffc0203cee:	ca1ff0ef          	jal	ra,ffffffffc020398e <mm_create>
ffffffffc0203cf2:	00013797          	auipc	a5,0x13
ffffffffc0203cf6:	8ea7bf23          	sd	a0,-1794(a5) # ffffffffc02165f0 <check_mm_struct>
ffffffffc0203cfa:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203cfc:	38050663          	beqz	a0,ffffffffc0204088 <vmm_init+0x546>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203d00:	00012797          	auipc	a5,0x12
ffffffffc0203d04:	79878793          	addi	a5,a5,1944 # ffffffffc0216498 <boot_pgdir>
ffffffffc0203d08:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203d0c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203d10:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203d14:	2e079e63          	bnez	a5,ffffffffc0204010 <vmm_init+0x4ce>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203d18:	03000513          	li	a0,48
ffffffffc0203d1c:	ceffd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
ffffffffc0203d20:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203d22:	1a050b63          	beqz	a0,ffffffffc0203ed8 <vmm_init+0x396>
        vma->vm_end = vm_end;
ffffffffc0203d26:	002007b7          	lui	a5,0x200
ffffffffc0203d2a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203d2c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203d2e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203d30:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203d32:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203d34:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203d38:	d0fff0ef          	jal	ra,ffffffffc0203a46 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d3c:	10000593          	li	a1,256
ffffffffc0203d40:	8526                	mv	a0,s1
ffffffffc0203d42:	cc7ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>
ffffffffc0203d46:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203d4a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203d4e:	2ea41163          	bne	s0,a0,ffffffffc0204030 <vmm_init+0x4ee>
        *(char *)(addr + i) = i;
ffffffffc0203d52:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203d56:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203d58:	fee79de3          	bne	a5,a4,ffffffffc0203d52 <vmm_init+0x210>
        sum += i;
ffffffffc0203d5c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203d5e:	10000793          	li	a5,256
        sum += i;
ffffffffc0203d62:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203d66:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203d6a:	0007c683          	lbu	a3,0(a5)
ffffffffc0203d6e:	0785                	addi	a5,a5,1
ffffffffc0203d70:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203d72:	fec79ce3          	bne	a5,a2,ffffffffc0203d6a <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203d76:	2e071963          	bnez	a4,ffffffffc0204068 <vmm_init+0x526>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d7a:	00093683          	ld	a3,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203d7e:	00012a97          	auipc	s5,0x12
ffffffffc0203d82:	722a8a93          	addi	s5,s5,1826 # ffffffffc02164a0 <npage>
ffffffffc0203d86:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d8a:	068a                	slli	a3,a3,0x2
ffffffffc0203d8c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d8e:	22e6f563          	bgeu	a3,a4,ffffffffc0203fb8 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d92:	00003797          	auipc	a5,0x3
ffffffffc0203d96:	46e78793          	addi	a5,a5,1134 # ffffffffc0207200 <nbase>
ffffffffc0203d9a:	0007b983          	ld	s3,0(a5)
ffffffffc0203d9e:	413687b3          	sub	a5,a3,s3
ffffffffc0203da2:	00379693          	slli	a3,a5,0x3
ffffffffc0203da6:	96be                	add	a3,a3,a5
    return page - pages + nbase;
ffffffffc0203da8:	00002797          	auipc	a5,0x2
ffffffffc0203dac:	d0078793          	addi	a5,a5,-768 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0203db0:	639c                	ld	a5,0(a5)
    return &pages[PPN(pa) - nbase];
ffffffffc0203db2:	068e                	slli	a3,a3,0x3
    return page - pages + nbase;
ffffffffc0203db4:	868d                	srai	a3,a3,0x3
ffffffffc0203db6:	02f686b3          	mul	a3,a3,a5
ffffffffc0203dba:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0203dbc:	00c69793          	slli	a5,a3,0xc
ffffffffc0203dc0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203dc2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203dc4:	28e7f663          	bgeu	a5,a4,ffffffffc0204050 <vmm_init+0x50e>
ffffffffc0203dc8:	00012797          	auipc	a5,0x12
ffffffffc0203dcc:	73878793          	addi	a5,a5,1848 # ffffffffc0216500 <va_pa_offset>
ffffffffc0203dd0:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203dd2:	4581                	li	a1,0
ffffffffc0203dd4:	854a                	mv	a0,s2
ffffffffc0203dd6:	9436                	add	s0,s0,a3
ffffffffc0203dd8:	99cfe0ef          	jal	ra,ffffffffc0201f74 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ddc:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203dde:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203de2:	078a                	slli	a5,a5,0x2
ffffffffc0203de4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203de6:	1ce7f963          	bgeu	a5,a4,ffffffffc0203fb8 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dea:	413787b3          	sub	a5,a5,s3
ffffffffc0203dee:	00012417          	auipc	s0,0x12
ffffffffc0203df2:	72240413          	addi	s0,s0,1826 # ffffffffc0216510 <pages>
ffffffffc0203df6:	00379713          	slli	a4,a5,0x3
ffffffffc0203dfa:	6008                	ld	a0,0(s0)
ffffffffc0203dfc:	97ba                	add	a5,a5,a4
ffffffffc0203dfe:	078e                	slli	a5,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0203e00:	953e                	add	a0,a0,a5
ffffffffc0203e02:	4585                	li	a1,1
ffffffffc0203e04:	e8ffd0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e08:	00093503          	ld	a0,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203e0c:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203e10:	050a                	slli	a0,a0,0x2
ffffffffc0203e12:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e14:	1af57263          	bgeu	a0,a5,ffffffffc0203fb8 <vmm_init+0x476>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e18:	413509b3          	sub	s3,a0,s3
ffffffffc0203e1c:	00399793          	slli	a5,s3,0x3
ffffffffc0203e20:	6008                	ld	a0,0(s0)
ffffffffc0203e22:	99be                	add	s3,s3,a5
ffffffffc0203e24:	098e                	slli	s3,s3,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0203e26:	4585                	li	a1,1
ffffffffc0203e28:	954e                	add	a0,a0,s3
ffffffffc0203e2a:	e69fd0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    pgdir[0] = 0;
ffffffffc0203e2e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203e32:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203e36:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203e3a:	8526                	mv	a0,s1
ffffffffc0203e3c:	cd9ff0ef          	jal	ra,ffffffffc0203b14 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203e40:	00012797          	auipc	a5,0x12
ffffffffc0203e44:	7a07b823          	sd	zero,1968(a5) # ffffffffc02165f0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e48:	e91fd0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0203e4c:	1aaa1263          	bne	s4,a0,ffffffffc0203ff0 <vmm_init+0x4ae>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203e50:	00003517          	auipc	a0,0x3
ffffffffc0203e54:	f2850513          	addi	a0,a0,-216 # ffffffffc0206d78 <default_pmm_manager+0xf20>
ffffffffc0203e58:	b36fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203e5c:	7442                	ld	s0,48(sp)
ffffffffc0203e5e:	70e2                	ld	ra,56(sp)
ffffffffc0203e60:	74a2                	ld	s1,40(sp)
ffffffffc0203e62:	7902                	ld	s2,32(sp)
ffffffffc0203e64:	69e2                	ld	s3,24(sp)
ffffffffc0203e66:	6a42                	ld	s4,16(sp)
ffffffffc0203e68:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203e6a:	00003517          	auipc	a0,0x3
ffffffffc0203e6e:	f2e50513          	addi	a0,a0,-210 # ffffffffc0206d98 <default_pmm_manager+0xf40>
}
ffffffffc0203e72:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203e74:	b1afc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203e78:	00003697          	auipc	a3,0x3
ffffffffc0203e7c:	d4868693          	addi	a3,a3,-696 # ffffffffc0206bc0 <default_pmm_manager+0xd68>
ffffffffc0203e80:	00002617          	auipc	a2,0x2
ffffffffc0203e84:	c4060613          	addi	a2,a2,-960 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203e88:	0d800593          	li	a1,216
ffffffffc0203e8c:	00003517          	auipc	a0,0x3
ffffffffc0203e90:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203e94:	db8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203e98:	00003697          	auipc	a3,0x3
ffffffffc0203e9c:	db068693          	addi	a3,a3,-592 # ffffffffc0206c48 <default_pmm_manager+0xdf0>
ffffffffc0203ea0:	00002617          	auipc	a2,0x2
ffffffffc0203ea4:	c2060613          	addi	a2,a2,-992 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203ea8:	0e800593          	li	a1,232
ffffffffc0203eac:	00003517          	auipc	a0,0x3
ffffffffc0203eb0:	bec50513          	addi	a0,a0,-1044 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203eb4:	d98fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203eb8:	00003697          	auipc	a3,0x3
ffffffffc0203ebc:	dc068693          	addi	a3,a3,-576 # ffffffffc0206c78 <default_pmm_manager+0xe20>
ffffffffc0203ec0:	00002617          	auipc	a2,0x2
ffffffffc0203ec4:	c0060613          	addi	a2,a2,-1024 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203ec8:	0e900593          	li	a1,233
ffffffffc0203ecc:	00003517          	auipc	a0,0x3
ffffffffc0203ed0:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203ed4:	d78fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(vma != NULL);
ffffffffc0203ed8:	00002697          	auipc	a3,0x2
ffffffffc0203edc:	73068693          	addi	a3,a3,1840 # ffffffffc0206608 <default_pmm_manager+0x7b0>
ffffffffc0203ee0:	00002617          	auipc	a2,0x2
ffffffffc0203ee4:	be060613          	addi	a2,a2,-1056 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203ee8:	10800593          	li	a1,264
ffffffffc0203eec:	00003517          	auipc	a0,0x3
ffffffffc0203ef0:	bac50513          	addi	a0,a0,-1108 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203ef4:	d58fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203ef8:	00003697          	auipc	a3,0x3
ffffffffc0203efc:	cb068693          	addi	a3,a3,-848 # ffffffffc0206ba8 <default_pmm_manager+0xd50>
ffffffffc0203f00:	00002617          	auipc	a2,0x2
ffffffffc0203f04:	bc060613          	addi	a2,a2,-1088 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203f08:	0d600593          	li	a1,214
ffffffffc0203f0c:	00003517          	auipc	a0,0x3
ffffffffc0203f10:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203f14:	d38fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma3 == NULL);
ffffffffc0203f18:	00003697          	auipc	a3,0x3
ffffffffc0203f1c:	d0068693          	addi	a3,a3,-768 # ffffffffc0206c18 <default_pmm_manager+0xdc0>
ffffffffc0203f20:	00002617          	auipc	a2,0x2
ffffffffc0203f24:	ba060613          	addi	a2,a2,-1120 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203f28:	0e200593          	li	a1,226
ffffffffc0203f2c:	00003517          	auipc	a0,0x3
ffffffffc0203f30:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203f34:	d18fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma2 != NULL);
ffffffffc0203f38:	00003697          	auipc	a3,0x3
ffffffffc0203f3c:	cd068693          	addi	a3,a3,-816 # ffffffffc0206c08 <default_pmm_manager+0xdb0>
ffffffffc0203f40:	00002617          	auipc	a2,0x2
ffffffffc0203f44:	b8060613          	addi	a2,a2,-1152 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203f48:	0e000593          	li	a1,224
ffffffffc0203f4c:	00003517          	auipc	a0,0x3
ffffffffc0203f50:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203f54:	cf8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma1 != NULL);
ffffffffc0203f58:	00003697          	auipc	a3,0x3
ffffffffc0203f5c:	ca068693          	addi	a3,a3,-864 # ffffffffc0206bf8 <default_pmm_manager+0xda0>
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	b6060613          	addi	a2,a2,-1184 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203f68:	0de00593          	li	a1,222
ffffffffc0203f6c:	00003517          	auipc	a0,0x3
ffffffffc0203f70:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203f74:	cd8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma5 == NULL);
ffffffffc0203f78:	00003697          	auipc	a3,0x3
ffffffffc0203f7c:	cc068693          	addi	a3,a3,-832 # ffffffffc0206c38 <default_pmm_manager+0xde0>
ffffffffc0203f80:	00002617          	auipc	a2,0x2
ffffffffc0203f84:	b4060613          	addi	a2,a2,-1216 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203f88:	0e600593          	li	a1,230
ffffffffc0203f8c:	00003517          	auipc	a0,0x3
ffffffffc0203f90:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203f94:	cb8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma4 == NULL);
ffffffffc0203f98:	00003697          	auipc	a3,0x3
ffffffffc0203f9c:	c9068693          	addi	a3,a3,-880 # ffffffffc0206c28 <default_pmm_manager+0xdd0>
ffffffffc0203fa0:	00002617          	auipc	a2,0x2
ffffffffc0203fa4:	b2060613          	addi	a2,a2,-1248 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203fa8:	0e400593          	li	a1,228
ffffffffc0203fac:	00003517          	auipc	a0,0x3
ffffffffc0203fb0:	aec50513          	addi	a0,a0,-1300 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203fb4:	c98fc0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203fb8:	00002617          	auipc	a2,0x2
ffffffffc0203fbc:	f5060613          	addi	a2,a2,-176 # ffffffffc0205f08 <default_pmm_manager+0xb0>
ffffffffc0203fc0:	06200593          	li	a1,98
ffffffffc0203fc4:	00002517          	auipc	a0,0x2
ffffffffc0203fc8:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0203fcc:	c80fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(mm != NULL);
ffffffffc0203fd0:	00002697          	auipc	a3,0x2
ffffffffc0203fd4:	60068693          	addi	a3,a3,1536 # ffffffffc02065d0 <default_pmm_manager+0x778>
ffffffffc0203fd8:	00002617          	auipc	a2,0x2
ffffffffc0203fdc:	ae860613          	addi	a2,a2,-1304 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0203fe0:	0c200593          	li	a1,194
ffffffffc0203fe4:	00003517          	auipc	a0,0x3
ffffffffc0203fe8:	ab450513          	addi	a0,a0,-1356 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0203fec:	c60fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ff0:	00003697          	auipc	a3,0x3
ffffffffc0203ff4:	d6068693          	addi	a3,a3,-672 # ffffffffc0206d50 <default_pmm_manager+0xef8>
ffffffffc0203ff8:	00002617          	auipc	a2,0x2
ffffffffc0203ffc:	ac860613          	addi	a2,a2,-1336 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204000:	12400593          	li	a1,292
ffffffffc0204004:	00003517          	auipc	a0,0x3
ffffffffc0204008:	a9450513          	addi	a0,a0,-1388 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc020400c:	c40fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204010:	00002697          	auipc	a3,0x2
ffffffffc0204014:	5e868693          	addi	a3,a3,1512 # ffffffffc02065f8 <default_pmm_manager+0x7a0>
ffffffffc0204018:	00002617          	auipc	a2,0x2
ffffffffc020401c:	aa860613          	addi	a2,a2,-1368 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204020:	10500593          	li	a1,261
ffffffffc0204024:	00003517          	auipc	a0,0x3
ffffffffc0204028:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc020402c:	c20fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204030:	00003697          	auipc	a3,0x3
ffffffffc0204034:	cf068693          	addi	a3,a3,-784 # ffffffffc0206d20 <default_pmm_manager+0xec8>
ffffffffc0204038:	00002617          	auipc	a2,0x2
ffffffffc020403c:	a8860613          	addi	a2,a2,-1400 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204040:	10d00593          	li	a1,269
ffffffffc0204044:	00003517          	auipc	a0,0x3
ffffffffc0204048:	a5450513          	addi	a0,a0,-1452 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc020404c:	c00fc0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc0204050:	00002617          	auipc	a2,0x2
ffffffffc0204054:	e5860613          	addi	a2,a2,-424 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0204058:	06900593          	li	a1,105
ffffffffc020405c:	00002517          	auipc	a0,0x2
ffffffffc0204060:	e7450513          	addi	a0,a0,-396 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0204064:	be8fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(sum == 0);
ffffffffc0204068:	00003697          	auipc	a3,0x3
ffffffffc020406c:	cd868693          	addi	a3,a3,-808 # ffffffffc0206d40 <default_pmm_manager+0xee8>
ffffffffc0204070:	00002617          	auipc	a2,0x2
ffffffffc0204074:	a5060613          	addi	a2,a2,-1456 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204078:	11700593          	li	a1,279
ffffffffc020407c:	00003517          	auipc	a0,0x3
ffffffffc0204080:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc0204084:	bc8fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204088:	00003697          	auipc	a3,0x3
ffffffffc020408c:	c8068693          	addi	a3,a3,-896 # ffffffffc0206d08 <default_pmm_manager+0xeb0>
ffffffffc0204090:	00002617          	auipc	a2,0x2
ffffffffc0204094:	a3060613          	addi	a2,a2,-1488 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204098:	10100593          	li	a1,257
ffffffffc020409c:	00003517          	auipc	a0,0x3
ffffffffc02040a0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206a98 <default_pmm_manager+0xc40>
ffffffffc02040a4:	ba8fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02040a8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02040a8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02040aa:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02040ac:	f022                	sd	s0,32(sp)
ffffffffc02040ae:	ec26                	sd	s1,24(sp)
ffffffffc02040b0:	f406                	sd	ra,40(sp)
ffffffffc02040b2:	e84a                	sd	s2,16(sp)
ffffffffc02040b4:	8432                	mv	s0,a2
ffffffffc02040b6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02040b8:	951ff0ef          	jal	ra,ffffffffc0203a08 <find_vma>

    pgfault_num++;
ffffffffc02040bc:	00012797          	auipc	a5,0x12
ffffffffc02040c0:	3f878793          	addi	a5,a5,1016 # ffffffffc02164b4 <pgfault_num>
ffffffffc02040c4:	439c                	lw	a5,0(a5)
ffffffffc02040c6:	2785                	addiw	a5,a5,1
ffffffffc02040c8:	00012717          	auipc	a4,0x12
ffffffffc02040cc:	3ef72623          	sw	a5,1004(a4) # ffffffffc02164b4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02040d0:	c551                	beqz	a0,ffffffffc020415c <do_pgfault+0xb4>
ffffffffc02040d2:	651c                	ld	a5,8(a0)
ffffffffc02040d4:	08f46463          	bltu	s0,a5,ffffffffc020415c <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02040d8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02040da:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02040dc:	8b89                	andi	a5,a5,2
ffffffffc02040de:	efb1                	bnez	a5,ffffffffc020413a <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02040e0:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02040e2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02040e4:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02040e6:	85a2                	mv	a1,s0
ffffffffc02040e8:	4605                	li	a2,1
ffffffffc02040ea:	c2ffd0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc02040ee:	c941                	beqz	a0,ffffffffc020417e <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02040f0:	610c                	ld	a1,0(a0)
ffffffffc02040f2:	c5b1                	beqz	a1,ffffffffc020413e <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02040f4:	00012797          	auipc	a5,0x12
ffffffffc02040f8:	3bc78793          	addi	a5,a5,956 # ffffffffc02164b0 <swap_init_ok>
ffffffffc02040fc:	439c                	lw	a5,0(a5)
ffffffffc02040fe:	2781                	sext.w	a5,a5
ffffffffc0204100:	c7bd                	beqz	a5,ffffffffc020416e <do_pgfault+0xc6>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);
ffffffffc0204102:	85a2                	mv	a1,s0
ffffffffc0204104:	0030                	addi	a2,sp,8
ffffffffc0204106:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204108:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc020410a:	bfeff0ef          	jal	ra,ffffffffc0203508 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc020410e:	65a2                	ld	a1,8(sp)
ffffffffc0204110:	6c88                	ld	a0,24(s1)
ffffffffc0204112:	86ca                	mv	a3,s2
ffffffffc0204114:	8622                	mv	a2,s0
ffffffffc0204116:	ed9fd0ef          	jal	ra,ffffffffc0201fee <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,0);
ffffffffc020411a:	6622                	ld	a2,8(sp)
ffffffffc020411c:	4681                	li	a3,0
ffffffffc020411e:	85a2                	mv	a1,s0
ffffffffc0204120:	8526                	mv	a0,s1
ffffffffc0204122:	ac2ff0ef          	jal	ra,ffffffffc02033e4 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204126:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0204128:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc020412a:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc020412c:	70a2                	ld	ra,40(sp)
ffffffffc020412e:	7402                	ld	s0,32(sp)
ffffffffc0204130:	64e2                	ld	s1,24(sp)
ffffffffc0204132:	6942                	ld	s2,16(sp)
ffffffffc0204134:	853e                	mv	a0,a5
ffffffffc0204136:	6145                	addi	sp,sp,48
ffffffffc0204138:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020413a:	495d                	li	s2,23
ffffffffc020413c:	b755                	j	ffffffffc02040e0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020413e:	6c88                	ld	a0,24(s1)
ffffffffc0204140:	864a                	mv	a2,s2
ffffffffc0204142:	85a2                	mv	a1,s0
ffffffffc0204144:	a61fe0ef          	jal	ra,ffffffffc0202ba4 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204148:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020414a:	f16d                	bnez	a0,ffffffffc020412c <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020414c:	00003517          	auipc	a0,0x3
ffffffffc0204150:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0206af8 <default_pmm_manager+0xca0>
ffffffffc0204154:	83afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204158:	57f1                	li	a5,-4
            goto failed;
ffffffffc020415a:	bfc9                	j	ffffffffc020412c <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020415c:	85a2                	mv	a1,s0
ffffffffc020415e:	00003517          	auipc	a0,0x3
ffffffffc0204162:	94a50513          	addi	a0,a0,-1718 # ffffffffc0206aa8 <default_pmm_manager+0xc50>
ffffffffc0204166:	828fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc020416a:	57f5                	li	a5,-3
        goto failed;
ffffffffc020416c:	b7c1                	j	ffffffffc020412c <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020416e:	00003517          	auipc	a0,0x3
ffffffffc0204172:	9b250513          	addi	a0,a0,-1614 # ffffffffc0206b20 <default_pmm_manager+0xcc8>
ffffffffc0204176:	818fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020417a:	57f1                	li	a5,-4
            goto failed;
ffffffffc020417c:	bf45                	j	ffffffffc020412c <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020417e:	00003517          	auipc	a0,0x3
ffffffffc0204182:	95a50513          	addi	a0,a0,-1702 # ffffffffc0206ad8 <default_pmm_manager+0xc80>
ffffffffc0204186:	808fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020418a:	57f1                	li	a5,-4
        goto failed;
ffffffffc020418c:	b745                	j	ffffffffc020412c <do_pgfault+0x84>

ffffffffc020418e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc020418e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204190:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204192:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204194:	be0fc0ef          	jal	ra,ffffffffc0200574 <ide_device_valid>
ffffffffc0204198:	cd01                	beqz	a0,ffffffffc02041b0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020419a:	4505                	li	a0,1
ffffffffc020419c:	bdefc0ef          	jal	ra,ffffffffc020057a <ide_device_size>
}
ffffffffc02041a0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02041a2:	810d                	srli	a0,a0,0x3
ffffffffc02041a4:	00012797          	auipc	a5,0x12
ffffffffc02041a8:	3ea7be23          	sd	a0,1020(a5) # ffffffffc02165a0 <max_swap_offset>
}
ffffffffc02041ac:	0141                	addi	sp,sp,16
ffffffffc02041ae:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02041b0:	00003617          	auipc	a2,0x3
ffffffffc02041b4:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206db0 <default_pmm_manager+0xf58>
ffffffffc02041b8:	45b5                	li	a1,13
ffffffffc02041ba:	00003517          	auipc	a0,0x3
ffffffffc02041be:	c1650513          	addi	a0,a0,-1002 # ffffffffc0206dd0 <default_pmm_manager+0xf78>
ffffffffc02041c2:	a8afc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02041c6 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc02041c6:	1141                	addi	sp,sp,-16
ffffffffc02041c8:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041ca:	00855793          	srli	a5,a0,0x8
ffffffffc02041ce:	c7b5                	beqz	a5,ffffffffc020423a <swapfs_read+0x74>
ffffffffc02041d0:	00012717          	auipc	a4,0x12
ffffffffc02041d4:	3d070713          	addi	a4,a4,976 # ffffffffc02165a0 <max_swap_offset>
ffffffffc02041d8:	6318                	ld	a4,0(a4)
ffffffffc02041da:	06e7f063          	bgeu	a5,a4,ffffffffc020423a <swapfs_read+0x74>
    return page - pages + nbase;
ffffffffc02041de:	00012717          	auipc	a4,0x12
ffffffffc02041e2:	33270713          	addi	a4,a4,818 # ffffffffc0216510 <pages>
ffffffffc02041e6:	6310                	ld	a2,0(a4)
ffffffffc02041e8:	00002717          	auipc	a4,0x2
ffffffffc02041ec:	8c070713          	addi	a4,a4,-1856 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc02041f0:	00003697          	auipc	a3,0x3
ffffffffc02041f4:	01068693          	addi	a3,a3,16 # ffffffffc0207200 <nbase>
ffffffffc02041f8:	40c58633          	sub	a2,a1,a2
ffffffffc02041fc:	630c                	ld	a1,0(a4)
ffffffffc02041fe:	860d                	srai	a2,a2,0x3
    return KADDR(page2pa(page));
ffffffffc0204200:	00012717          	auipc	a4,0x12
ffffffffc0204204:	2a070713          	addi	a4,a4,672 # ffffffffc02164a0 <npage>
    return page - pages + nbase;
ffffffffc0204208:	02b60633          	mul	a2,a2,a1
ffffffffc020420c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204210:	629c                	ld	a5,0(a3)
    return KADDR(page2pa(page));
ffffffffc0204212:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204214:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc0204216:	00c61793          	slli	a5,a2,0xc
ffffffffc020421a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020421c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020421e:	02e7fa63          	bgeu	a5,a4,ffffffffc0204252 <swapfs_read+0x8c>
ffffffffc0204222:	00012797          	auipc	a5,0x12
ffffffffc0204226:	2de78793          	addi	a5,a5,734 # ffffffffc0216500 <va_pa_offset>
ffffffffc020422a:	639c                	ld	a5,0(a5)
}
ffffffffc020422c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020422e:	46a1                	li	a3,8
ffffffffc0204230:	963e                	add	a2,a2,a5
ffffffffc0204232:	4505                	li	a0,1
}
ffffffffc0204234:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204236:	b4afc06f          	j	ffffffffc0200580 <ide_read_secs>
ffffffffc020423a:	86aa                	mv	a3,a0
ffffffffc020423c:	00003617          	auipc	a2,0x3
ffffffffc0204240:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206de8 <default_pmm_manager+0xf90>
ffffffffc0204244:	45d1                	li	a1,20
ffffffffc0204246:	00003517          	auipc	a0,0x3
ffffffffc020424a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0206dd0 <default_pmm_manager+0xf78>
ffffffffc020424e:	9fefc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0204252:	86b2                	mv	a3,a2
ffffffffc0204254:	06900593          	li	a1,105
ffffffffc0204258:	00002617          	auipc	a2,0x2
ffffffffc020425c:	c5060613          	addi	a2,a2,-944 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0204260:	00002517          	auipc	a0,0x2
ffffffffc0204264:	c7050513          	addi	a0,a0,-912 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0204268:	9e4fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020426c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020426c:	1141                	addi	sp,sp,-16
ffffffffc020426e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204270:	00855793          	srli	a5,a0,0x8
ffffffffc0204274:	c7b5                	beqz	a5,ffffffffc02042e0 <swapfs_write+0x74>
ffffffffc0204276:	00012717          	auipc	a4,0x12
ffffffffc020427a:	32a70713          	addi	a4,a4,810 # ffffffffc02165a0 <max_swap_offset>
ffffffffc020427e:	6318                	ld	a4,0(a4)
ffffffffc0204280:	06e7f063          	bgeu	a5,a4,ffffffffc02042e0 <swapfs_write+0x74>
    return page - pages + nbase;
ffffffffc0204284:	00012717          	auipc	a4,0x12
ffffffffc0204288:	28c70713          	addi	a4,a4,652 # ffffffffc0216510 <pages>
ffffffffc020428c:	6310                	ld	a2,0(a4)
ffffffffc020428e:	00002717          	auipc	a4,0x2
ffffffffc0204292:	81a70713          	addi	a4,a4,-2022 # ffffffffc0205aa8 <commands+0x8c0>
ffffffffc0204296:	00003697          	auipc	a3,0x3
ffffffffc020429a:	f6a68693          	addi	a3,a3,-150 # ffffffffc0207200 <nbase>
ffffffffc020429e:	40c58633          	sub	a2,a1,a2
ffffffffc02042a2:	630c                	ld	a1,0(a4)
ffffffffc02042a4:	860d                	srai	a2,a2,0x3
    return KADDR(page2pa(page));
ffffffffc02042a6:	00012717          	auipc	a4,0x12
ffffffffc02042aa:	1fa70713          	addi	a4,a4,506 # ffffffffc02164a0 <npage>
    return page - pages + nbase;
ffffffffc02042ae:	02b60633          	mul	a2,a2,a1
ffffffffc02042b2:	0037959b          	slliw	a1,a5,0x3
ffffffffc02042b6:	629c                	ld	a5,0(a3)
    return KADDR(page2pa(page));
ffffffffc02042b8:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02042ba:	963e                	add	a2,a2,a5
    return KADDR(page2pa(page));
ffffffffc02042bc:	00c61793          	slli	a5,a2,0xc
ffffffffc02042c0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02042c2:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02042c4:	02e7fa63          	bgeu	a5,a4,ffffffffc02042f8 <swapfs_write+0x8c>
ffffffffc02042c8:	00012797          	auipc	a5,0x12
ffffffffc02042cc:	23878793          	addi	a5,a5,568 # ffffffffc0216500 <va_pa_offset>
ffffffffc02042d0:	639c                	ld	a5,0(a5)
}
ffffffffc02042d2:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02042d4:	46a1                	li	a3,8
ffffffffc02042d6:	963e                	add	a2,a2,a5
ffffffffc02042d8:	4505                	li	a0,1
}
ffffffffc02042da:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02042dc:	ac8fc06f          	j	ffffffffc02005a4 <ide_write_secs>
ffffffffc02042e0:	86aa                	mv	a3,a0
ffffffffc02042e2:	00003617          	auipc	a2,0x3
ffffffffc02042e6:	b0660613          	addi	a2,a2,-1274 # ffffffffc0206de8 <default_pmm_manager+0xf90>
ffffffffc02042ea:	45e5                	li	a1,25
ffffffffc02042ec:	00003517          	auipc	a0,0x3
ffffffffc02042f0:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206dd0 <default_pmm_manager+0xf78>
ffffffffc02042f4:	958fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc02042f8:	86b2                	mv	a3,a2
ffffffffc02042fa:	06900593          	li	a1,105
ffffffffc02042fe:	00002617          	auipc	a2,0x2
ffffffffc0204302:	baa60613          	addi	a2,a2,-1110 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc0204306:	00002517          	auipc	a0,0x2
ffffffffc020430a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc020430e:	93efc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204312 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204312:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204314:	9402                	jalr	s0

	jal do_exit
ffffffffc0204316:	540000ef          	jal	ra,ffffffffc0204856 <do_exit>

ffffffffc020431a <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc020431a:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020431c:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204320:	e022                	sd	s0,0(sp)
ffffffffc0204322:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204324:	ee6fd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
ffffffffc0204328:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc020432a:	c529                	beqz	a0,ffffffffc0204374 <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc020432c:	57fd                	li	a5,-1
ffffffffc020432e:	1782                	slli	a5,a5,0x20
ffffffffc0204330:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204332:	07000613          	li	a2,112
ffffffffc0204336:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204338:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc020433c:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204340:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204344:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204348:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020434c:	03050513          	addi	a0,a0,48
ffffffffc0204350:	509000ef          	jal	ra,ffffffffc0205058 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204354:	00012797          	auipc	a5,0x12
ffffffffc0204358:	1b478793          	addi	a5,a5,436 # ffffffffc0216508 <boot_cr3>
ffffffffc020435c:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc020435e:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204362:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204366:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204368:	4641                	li	a2,16
ffffffffc020436a:	4581                	li	a1,0
ffffffffc020436c:	0b440513          	addi	a0,s0,180
ffffffffc0204370:	4e9000ef          	jal	ra,ffffffffc0205058 <memset>
    }
    return proc;
}
ffffffffc0204374:	8522                	mv	a0,s0
ffffffffc0204376:	60a2                	ld	ra,8(sp)
ffffffffc0204378:	6402                	ld	s0,0(sp)
ffffffffc020437a:	0141                	addi	sp,sp,16
ffffffffc020437c:	8082                	ret

ffffffffc020437e <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020437e:	00012797          	auipc	a5,0x12
ffffffffc0204382:	13a78793          	addi	a5,a5,314 # ffffffffc02164b8 <current>
ffffffffc0204386:	639c                	ld	a5,0(a5)
ffffffffc0204388:	73c8                	ld	a0,160(a5)
ffffffffc020438a:	85ffc06f          	j	ffffffffc0200be8 <forkrets>

ffffffffc020438e <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020438e:	1101                	addi	sp,sp,-32
ffffffffc0204390:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204392:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204396:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204398:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020439a:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020439c:	8522                	mv	a0,s0
ffffffffc020439e:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02043a0:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02043a2:	4b7000ef          	jal	ra,ffffffffc0205058 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02043a6:	8522                	mv	a0,s0
}
ffffffffc02043a8:	6442                	ld	s0,16(sp)
ffffffffc02043aa:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02043ac:	85a6                	mv	a1,s1
}
ffffffffc02043ae:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02043b0:	463d                	li	a2,15
}
ffffffffc02043b2:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02043b4:	4b70006f          	j	ffffffffc020506a <memcpy>

ffffffffc02043b8 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc02043b8:	1101                	addi	sp,sp,-32
ffffffffc02043ba:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc02043bc:	00012417          	auipc	s0,0x12
ffffffffc02043c0:	0a440413          	addi	s0,s0,164 # ffffffffc0216460 <name.1566>
get_proc_name(struct proc_struct *proc) {
ffffffffc02043c4:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02043c6:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc02043c8:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02043ca:	4581                	li	a1,0
ffffffffc02043cc:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc02043ce:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02043d0:	489000ef          	jal	ra,ffffffffc0205058 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043d4:	8522                	mv	a0,s0
}
ffffffffc02043d6:	6442                	ld	s0,16(sp)
ffffffffc02043d8:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043da:	0b448593          	addi	a1,s1,180
}
ffffffffc02043de:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043e0:	463d                	li	a2,15
}
ffffffffc02043e2:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02043e4:	4870006f          	j	ffffffffc020506a <memcpy>

ffffffffc02043e8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043e8:	00012797          	auipc	a5,0x12
ffffffffc02043ec:	0d078793          	addi	a5,a5,208 # ffffffffc02164b8 <current>
ffffffffc02043f0:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02043f2:	1101                	addi	sp,sp,-32
ffffffffc02043f4:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043f6:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02043f8:	e822                	sd	s0,16(sp)
ffffffffc02043fa:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02043fc:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02043fe:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204400:	fb9ff0ef          	jal	ra,ffffffffc02043b8 <get_proc_name>
ffffffffc0204404:	862a                	mv	a2,a0
ffffffffc0204406:	85a6                	mv	a1,s1
ffffffffc0204408:	00003517          	auipc	a0,0x3
ffffffffc020440c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0206e50 <default_pmm_manager+0xff8>
ffffffffc0204410:	d7ffb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204414:	85a2                	mv	a1,s0
ffffffffc0204416:	00003517          	auipc	a0,0x3
ffffffffc020441a:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206e78 <default_pmm_manager+0x1020>
ffffffffc020441e:	d71fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204422:	00003517          	auipc	a0,0x3
ffffffffc0204426:	a6650513          	addi	a0,a0,-1434 # ffffffffc0206e88 <default_pmm_manager+0x1030>
ffffffffc020442a:	d65fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc020442e:	60e2                	ld	ra,24(sp)
ffffffffc0204430:	6442                	ld	s0,16(sp)
ffffffffc0204432:	64a2                	ld	s1,8(sp)
ffffffffc0204434:	4501                	li	a0,0
ffffffffc0204436:	6105                	addi	sp,sp,32
ffffffffc0204438:	8082                	ret

ffffffffc020443a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc020443a:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc020443c:	00012797          	auipc	a5,0x12
ffffffffc0204440:	07c78793          	addi	a5,a5,124 # ffffffffc02164b8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204444:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204446:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204448:	ec06                	sd	ra,24(sp)
ffffffffc020444a:	e822                	sd	s0,16(sp)
ffffffffc020444c:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc020444e:	02a48c63          	beq	s1,a0,ffffffffc0204486 <proc_run+0x4c>
ffffffffc0204452:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204454:	100027f3          	csrr	a5,sstatus
ffffffffc0204458:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020445a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020445c:	e3b1                	bnez	a5,ffffffffc02044a0 <proc_run+0x66>
        lcr3(next->cr3);
ffffffffc020445e:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc0204460:	00012717          	auipc	a4,0x12
ffffffffc0204464:	04873c23          	sd	s0,88(a4) # ffffffffc02164b8 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204468:	80000737          	lui	a4,0x80000
ffffffffc020446c:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204470:	8fd9                	or	a5,a5,a4
ffffffffc0204472:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0204476:	03040593          	addi	a1,s0,48
ffffffffc020447a:	03048513          	addi	a0,s1,48
ffffffffc020447e:	602000ef          	jal	ra,ffffffffc0204a80 <switch_to>
    if (flag) {
ffffffffc0204482:	00091863          	bnez	s2,ffffffffc0204492 <proc_run+0x58>
}
ffffffffc0204486:	60e2                	ld	ra,24(sp)
ffffffffc0204488:	6442                	ld	s0,16(sp)
ffffffffc020448a:	64a2                	ld	s1,8(sp)
ffffffffc020448c:	6902                	ld	s2,0(sp)
ffffffffc020448e:	6105                	addi	sp,sp,32
ffffffffc0204490:	8082                	ret
ffffffffc0204492:	6442                	ld	s0,16(sp)
ffffffffc0204494:	60e2                	ld	ra,24(sp)
ffffffffc0204496:	64a2                	ld	s1,8(sp)
ffffffffc0204498:	6902                	ld	s2,0(sp)
ffffffffc020449a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020449c:	92efc06f          	j	ffffffffc02005ca <intr_enable>
        intr_disable();
ffffffffc02044a0:	930fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc02044a4:	4905                	li	s2,1
ffffffffc02044a6:	bf65                	j	ffffffffc020445e <proc_run+0x24>

ffffffffc02044a8 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02044a8:	0005071b          	sext.w	a4,a0
ffffffffc02044ac:	6789                	lui	a5,0x2
ffffffffc02044ae:	fff7069b          	addiw	a3,a4,-1
ffffffffc02044b2:	17f9                	addi	a5,a5,-2
ffffffffc02044b4:	04d7e063          	bltu	a5,a3,ffffffffc02044f4 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02044b8:	1141                	addi	sp,sp,-16
ffffffffc02044ba:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02044bc:	45a9                	li	a1,10
ffffffffc02044be:	842a                	mv	s0,a0
ffffffffc02044c0:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02044c2:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02044c4:	6f2000ef          	jal	ra,ffffffffc0204bb6 <hash32>
ffffffffc02044c8:	02051693          	slli	a3,a0,0x20
ffffffffc02044cc:	82f1                	srli	a3,a3,0x1c
ffffffffc02044ce:	0000e517          	auipc	a0,0xe
ffffffffc02044d2:	f9250513          	addi	a0,a0,-110 # ffffffffc0212460 <hash_list>
ffffffffc02044d6:	96aa                	add	a3,a3,a0
ffffffffc02044d8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02044da:	a029                	j	ffffffffc02044e4 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02044dc:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02044e0:	00870c63          	beq	a4,s0,ffffffffc02044f8 <find_proc+0x50>
ffffffffc02044e4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02044e6:	fef69be3          	bne	a3,a5,ffffffffc02044dc <find_proc+0x34>
}
ffffffffc02044ea:	60a2                	ld	ra,8(sp)
ffffffffc02044ec:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02044ee:	4501                	li	a0,0
}
ffffffffc02044f0:	0141                	addi	sp,sp,16
ffffffffc02044f2:	8082                	ret
    return NULL;
ffffffffc02044f4:	4501                	li	a0,0
}
ffffffffc02044f6:	8082                	ret
ffffffffc02044f8:	60a2                	ld	ra,8(sp)
ffffffffc02044fa:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02044fc:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204500:	0141                	addi	sp,sp,16
ffffffffc0204502:	8082                	ret

ffffffffc0204504 <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204504:	00012797          	auipc	a5,0x12
ffffffffc0204508:	fcc78793          	addi	a5,a5,-52 # ffffffffc02164d0 <nr_process>
ffffffffc020450c:	4398                	lw	a4,0(a5)
ffffffffc020450e:	6785                	lui	a5,0x1
ffffffffc0204510:	28f75363          	bge	a4,a5,ffffffffc0204796 <do_fork+0x292>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204514:	7179                	addi	sp,sp,-48
ffffffffc0204516:	f022                	sd	s0,32(sp)
ffffffffc0204518:	ec26                	sd	s1,24(sp)
ffffffffc020451a:	e84a                	sd	s2,16(sp)
ffffffffc020451c:	f406                	sd	ra,40(sp)
ffffffffc020451e:	e44e                	sd	s3,8(sp)
ffffffffc0204520:	892e                	mv	s2,a1
ffffffffc0204522:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204524:	df7ff0ef          	jal	ra,ffffffffc020431a <alloc_proc>
ffffffffc0204528:	842a                	mv	s0,a0
ffffffffc020452a:	26050863          	beqz	a0,ffffffffc020479a <do_fork+0x296>
    proc->parent = current;
ffffffffc020452e:	00012997          	auipc	s3,0x12
ffffffffc0204532:	f8a98993          	addi	s3,s3,-118 # ffffffffc02164b8 <current>
ffffffffc0204536:	0009b783          	ld	a5,0(s3)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020453a:	4509                	li	a0,2
    proc->parent = current;
ffffffffc020453c:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020453e:	eccfd0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
    if (page != NULL) {
ffffffffc0204542:	1e050e63          	beqz	a0,ffffffffc020473e <do_fork+0x23a>
    return page - pages + nbase;
ffffffffc0204546:	00012797          	auipc	a5,0x12
ffffffffc020454a:	fca78793          	addi	a5,a5,-54 # ffffffffc0216510 <pages>
ffffffffc020454e:	6394                	ld	a3,0(a5)
ffffffffc0204550:	00001797          	auipc	a5,0x1
ffffffffc0204554:	55878793          	addi	a5,a5,1368 # ffffffffc0205aa8 <commands+0x8c0>
    return KADDR(page2pa(page));
ffffffffc0204558:	00012717          	auipc	a4,0x12
ffffffffc020455c:	f4870713          	addi	a4,a4,-184 # ffffffffc02164a0 <npage>
    return page - pages + nbase;
ffffffffc0204560:	40d506b3          	sub	a3,a0,a3
ffffffffc0204564:	6388                	ld	a0,0(a5)
ffffffffc0204566:	868d                	srai	a3,a3,0x3
ffffffffc0204568:	00003797          	auipc	a5,0x3
ffffffffc020456c:	c9878793          	addi	a5,a5,-872 # ffffffffc0207200 <nbase>
ffffffffc0204570:	02a686b3          	mul	a3,a3,a0
ffffffffc0204574:	6388                	ld	a0,0(a5)
    return KADDR(page2pa(page));
ffffffffc0204576:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204578:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020457a:	00c69793          	slli	a5,a3,0xc
ffffffffc020457e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204580:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204582:	22e7fe63          	bgeu	a5,a4,ffffffffc02047be <do_fork+0x2ba>
    assert(current->mm == NULL);
ffffffffc0204586:	0009b783          	ld	a5,0(s3)
ffffffffc020458a:	00012717          	auipc	a4,0x12
ffffffffc020458e:	f7670713          	addi	a4,a4,-138 # ffffffffc0216500 <va_pa_offset>
ffffffffc0204592:	6318                	ld	a4,0(a4)
ffffffffc0204594:	779c                	ld	a5,40(a5)
ffffffffc0204596:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204598:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc020459a:	20079263          	bnez	a5,ffffffffc020479e <do_fork+0x29a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020459e:	6789                	lui	a5,0x2
ffffffffc02045a0:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc02045a4:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02045a6:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02045a8:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02045aa:	87b6                	mv	a5,a3
ffffffffc02045ac:	12048893          	addi	a7,s1,288
ffffffffc02045b0:	00063803          	ld	a6,0(a2)
ffffffffc02045b4:	6608                	ld	a0,8(a2)
ffffffffc02045b6:	6a0c                	ld	a1,16(a2)
ffffffffc02045b8:	6e18                	ld	a4,24(a2)
ffffffffc02045ba:	0107b023          	sd	a6,0(a5)
ffffffffc02045be:	e788                	sd	a0,8(a5)
ffffffffc02045c0:	eb8c                	sd	a1,16(a5)
ffffffffc02045c2:	ef98                	sd	a4,24(a5)
ffffffffc02045c4:	02060613          	addi	a2,a2,32
ffffffffc02045c8:	02078793          	addi	a5,a5,32
ffffffffc02045cc:	ff1612e3          	bne	a2,a7,ffffffffc02045b0 <do_fork+0xac>
    proc->tf->gpr.a0 = 0;
ffffffffc02045d0:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045d4:	10090663          	beqz	s2,ffffffffc02046e0 <do_fork+0x1dc>
ffffffffc02045d8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045dc:	00000797          	auipc	a5,0x0
ffffffffc02045e0:	da278793          	addi	a5,a5,-606 # ffffffffc020437e <forkret>
ffffffffc02045e4:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045e6:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045e8:	100027f3          	csrr	a5,sstatus
ffffffffc02045ec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045ee:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045f0:	10079763          	bnez	a5,ffffffffc02046fe <do_fork+0x1fa>
    if (++ last_pid >= MAX_PID) {
ffffffffc02045f4:	00007797          	auipc	a5,0x7
ffffffffc02045f8:	a6478793          	addi	a5,a5,-1436 # ffffffffc020b058 <last_pid.1576>
ffffffffc02045fc:	439c                	lw	a5,0(a5)
ffffffffc02045fe:	6709                	lui	a4,0x2
ffffffffc0204600:	0017851b          	addiw	a0,a5,1
ffffffffc0204604:	00007697          	auipc	a3,0x7
ffffffffc0204608:	a4a6aa23          	sw	a0,-1452(a3) # ffffffffc020b058 <last_pid.1576>
ffffffffc020460c:	10e55a63          	bge	a0,a4,ffffffffc0204720 <do_fork+0x21c>
    if (last_pid >= next_safe) {
ffffffffc0204610:	00007797          	auipc	a5,0x7
ffffffffc0204614:	a4c78793          	addi	a5,a5,-1460 # ffffffffc020b05c <next_safe.1575>
ffffffffc0204618:	439c                	lw	a5,0(a5)
ffffffffc020461a:	00012497          	auipc	s1,0x12
ffffffffc020461e:	fde48493          	addi	s1,s1,-34 # ffffffffc02165f8 <proc_list>
ffffffffc0204622:	06f54063          	blt	a0,a5,ffffffffc0204682 <do_fork+0x17e>
        next_safe = MAX_PID;
ffffffffc0204626:	6789                	lui	a5,0x2
ffffffffc0204628:	00007717          	auipc	a4,0x7
ffffffffc020462c:	a2f72a23          	sw	a5,-1484(a4) # ffffffffc020b05c <next_safe.1575>
ffffffffc0204630:	4581                	li	a1,0
ffffffffc0204632:	87aa                	mv	a5,a0
ffffffffc0204634:	00012497          	auipc	s1,0x12
ffffffffc0204638:	fc448493          	addi	s1,s1,-60 # ffffffffc02165f8 <proc_list>
    repeat:
ffffffffc020463c:	6889                	lui	a7,0x2
ffffffffc020463e:	882e                	mv	a6,a1
ffffffffc0204640:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204642:	00012697          	auipc	a3,0x12
ffffffffc0204646:	fb668693          	addi	a3,a3,-74 # ffffffffc02165f8 <proc_list>
ffffffffc020464a:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020464c:	00968f63          	beq	a3,s1,ffffffffc020466a <do_fork+0x166>
            if (proc->pid == last_pid) {
ffffffffc0204650:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204654:	08e78163          	beq	a5,a4,ffffffffc02046d6 <do_fork+0x1d2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204658:	fee7d9e3          	bge	a5,a4,ffffffffc020464a <do_fork+0x146>
ffffffffc020465c:	fec757e3          	bge	a4,a2,ffffffffc020464a <do_fork+0x146>
ffffffffc0204660:	6694                	ld	a3,8(a3)
ffffffffc0204662:	863a                	mv	a2,a4
ffffffffc0204664:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204666:	fe9695e3          	bne	a3,s1,ffffffffc0204650 <do_fork+0x14c>
ffffffffc020466a:	c591                	beqz	a1,ffffffffc0204676 <do_fork+0x172>
ffffffffc020466c:	00007717          	auipc	a4,0x7
ffffffffc0204670:	9ef72623          	sw	a5,-1556(a4) # ffffffffc020b058 <last_pid.1576>
ffffffffc0204674:	853e                	mv	a0,a5
ffffffffc0204676:	00080663          	beqz	a6,ffffffffc0204682 <do_fork+0x17e>
ffffffffc020467a:	00007797          	auipc	a5,0x7
ffffffffc020467e:	9ec7a123          	sw	a2,-1566(a5) # ffffffffc020b05c <next_safe.1575>
        proc->pid = get_pid();
ffffffffc0204682:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204684:	45a9                	li	a1,10
ffffffffc0204686:	2501                	sext.w	a0,a0
ffffffffc0204688:	52e000ef          	jal	ra,ffffffffc0204bb6 <hash32>
ffffffffc020468c:	1502                	slli	a0,a0,0x20
ffffffffc020468e:	0000e797          	auipc	a5,0xe
ffffffffc0204692:	dd278793          	addi	a5,a5,-558 # ffffffffc0212460 <hash_list>
ffffffffc0204696:	8171                	srli	a0,a0,0x1c
ffffffffc0204698:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020469a:	6514                	ld	a3,8(a0)
ffffffffc020469c:	0d840793          	addi	a5,s0,216
ffffffffc02046a0:	6498                	ld	a4,8(s1)
    prev->next = next->prev = elm;
ffffffffc02046a2:	e29c                	sd	a5,0(a3)
ffffffffc02046a4:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc02046a6:	f074                	sd	a3,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc02046a8:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc02046ac:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02046ae:	e31c                	sd	a5,0(a4)
ffffffffc02046b0:	00012697          	auipc	a3,0x12
ffffffffc02046b4:	f4f6b823          	sd	a5,-176(a3) # ffffffffc0216600 <proc_list+0x8>
    elm->next = next;
ffffffffc02046b8:	e878                	sd	a4,208(s0)
    elm->prev = prev;
ffffffffc02046ba:	e464                	sd	s1,200(s0)
    if (flag) {
ffffffffc02046bc:	06091963          	bnez	s2,ffffffffc020472e <do_fork+0x22a>
    wakeup_proc(proc);
ffffffffc02046c0:	8522                	mv	a0,s0
ffffffffc02046c2:	428000ef          	jal	ra,ffffffffc0204aea <wakeup_proc>
    ret = proc->pid;
ffffffffc02046c6:	4048                	lw	a0,4(s0)
}
ffffffffc02046c8:	70a2                	ld	ra,40(sp)
ffffffffc02046ca:	7402                	ld	s0,32(sp)
ffffffffc02046cc:	64e2                	ld	s1,24(sp)
ffffffffc02046ce:	6942                	ld	s2,16(sp)
ffffffffc02046d0:	69a2                	ld	s3,8(sp)
ffffffffc02046d2:	6145                	addi	sp,sp,48
ffffffffc02046d4:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02046d6:	2785                	addiw	a5,a5,1
ffffffffc02046d8:	04c7de63          	bge	a5,a2,ffffffffc0204734 <do_fork+0x230>
ffffffffc02046dc:	4585                	li	a1,1
ffffffffc02046de:	b7b5                	j	ffffffffc020464a <do_fork+0x146>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02046e0:	8936                	mv	s2,a3
ffffffffc02046e2:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02046e6:	00000797          	auipc	a5,0x0
ffffffffc02046ea:	c9878793          	addi	a5,a5,-872 # ffffffffc020437e <forkret>
ffffffffc02046ee:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02046f0:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02046f2:	100027f3          	csrr	a5,sstatus
ffffffffc02046f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02046f8:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02046fa:	ee078de3          	beqz	a5,ffffffffc02045f4 <do_fork+0xf0>
        intr_disable();
ffffffffc02046fe:	ed3fb0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204702:	00007797          	auipc	a5,0x7
ffffffffc0204706:	95678793          	addi	a5,a5,-1706 # ffffffffc020b058 <last_pid.1576>
ffffffffc020470a:	439c                	lw	a5,0(a5)
ffffffffc020470c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020470e:	4905                	li	s2,1
ffffffffc0204710:	0017851b          	addiw	a0,a5,1
ffffffffc0204714:	00007697          	auipc	a3,0x7
ffffffffc0204718:	94a6a223          	sw	a0,-1724(a3) # ffffffffc020b058 <last_pid.1576>
ffffffffc020471c:	eee54ae3          	blt	a0,a4,ffffffffc0204610 <do_fork+0x10c>
        last_pid = 1;
ffffffffc0204720:	4785                	li	a5,1
ffffffffc0204722:	00007717          	auipc	a4,0x7
ffffffffc0204726:	92f72b23          	sw	a5,-1738(a4) # ffffffffc020b058 <last_pid.1576>
ffffffffc020472a:	4505                	li	a0,1
ffffffffc020472c:	bded                	j	ffffffffc0204626 <do_fork+0x122>
        intr_enable();
ffffffffc020472e:	e9dfb0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0204732:	b779                	j	ffffffffc02046c0 <do_fork+0x1bc>
                    if (last_pid >= MAX_PID) {
ffffffffc0204734:	0117c363          	blt	a5,a7,ffffffffc020473a <do_fork+0x236>
                        last_pid = 1;
ffffffffc0204738:	4785                	li	a5,1
                    goto repeat;
ffffffffc020473a:	4585                	li	a1,1
ffffffffc020473c:	b709                	j	ffffffffc020463e <do_fork+0x13a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020473e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204740:	c02007b7          	lui	a5,0xc0200
ffffffffc0204744:	0af6e563          	bltu	a3,a5,ffffffffc02047ee <do_fork+0x2ea>
ffffffffc0204748:	00012797          	auipc	a5,0x12
ffffffffc020474c:	db878793          	addi	a5,a5,-584 # ffffffffc0216500 <va_pa_offset>
ffffffffc0204750:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204752:	00012717          	auipc	a4,0x12
ffffffffc0204756:	d4e70713          	addi	a4,a4,-690 # ffffffffc02164a0 <npage>
ffffffffc020475a:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc020475c:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204760:	83b1                	srli	a5,a5,0xc
ffffffffc0204762:	06e7fa63          	bgeu	a5,a4,ffffffffc02047d6 <do_fork+0x2d2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204766:	00003717          	auipc	a4,0x3
ffffffffc020476a:	a9a70713          	addi	a4,a4,-1382 # ffffffffc0207200 <nbase>
ffffffffc020476e:	6318                	ld	a4,0(a4)
ffffffffc0204770:	00012697          	auipc	a3,0x12
ffffffffc0204774:	da068693          	addi	a3,a3,-608 # ffffffffc0216510 <pages>
ffffffffc0204778:	6288                	ld	a0,0(a3)
ffffffffc020477a:	8f99                	sub	a5,a5,a4
ffffffffc020477c:	00379713          	slli	a4,a5,0x3
ffffffffc0204780:	97ba                	add	a5,a5,a4
ffffffffc0204782:	078e                	slli	a5,a5,0x3
ffffffffc0204784:	953e                	add	a0,a0,a5
ffffffffc0204786:	4589                	li	a1,2
ffffffffc0204788:	d0afd0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    kfree(proc);
ffffffffc020478c:	8522                	mv	a0,s0
ffffffffc020478e:	b38fd0ef          	jal	ra,ffffffffc0201ac6 <kfree>
    ret = -E_NO_MEM;
ffffffffc0204792:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0204794:	bf15                	j	ffffffffc02046c8 <do_fork+0x1c4>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204796:	556d                	li	a0,-5
}
ffffffffc0204798:	8082                	ret
    ret = -E_NO_MEM;
ffffffffc020479a:	5571                	li	a0,-4
ffffffffc020479c:	b735                	j	ffffffffc02046c8 <do_fork+0x1c4>
    assert(current->mm == NULL);
ffffffffc020479e:	00002697          	auipc	a3,0x2
ffffffffc02047a2:	68268693          	addi	a3,a3,1666 # ffffffffc0206e20 <default_pmm_manager+0xfc8>
ffffffffc02047a6:	00001617          	auipc	a2,0x1
ffffffffc02047aa:	31a60613          	addi	a2,a2,794 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc02047ae:	10500593          	li	a1,261
ffffffffc02047b2:	00002517          	auipc	a0,0x2
ffffffffc02047b6:	68650513          	addi	a0,a0,1670 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
ffffffffc02047ba:	c93fb0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc02047be:	00001617          	auipc	a2,0x1
ffffffffc02047c2:	6ea60613          	addi	a2,a2,1770 # ffffffffc0205ea8 <default_pmm_manager+0x50>
ffffffffc02047c6:	06900593          	li	a1,105
ffffffffc02047ca:	00001517          	auipc	a0,0x1
ffffffffc02047ce:	70650513          	addi	a0,a0,1798 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02047d2:	c7bfb0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02047d6:	00001617          	auipc	a2,0x1
ffffffffc02047da:	73260613          	addi	a2,a2,1842 # ffffffffc0205f08 <default_pmm_manager+0xb0>
ffffffffc02047de:	06200593          	li	a1,98
ffffffffc02047e2:	00001517          	auipc	a0,0x1
ffffffffc02047e6:	6ee50513          	addi	a0,a0,1774 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc02047ea:	c63fb0ef          	jal	ra,ffffffffc020044c <__panic>
    return pa2page(PADDR(kva));
ffffffffc02047ee:	00001617          	auipc	a2,0x1
ffffffffc02047f2:	6f260613          	addi	a2,a2,1778 # ffffffffc0205ee0 <default_pmm_manager+0x88>
ffffffffc02047f6:	06e00593          	li	a1,110
ffffffffc02047fa:	00001517          	auipc	a0,0x1
ffffffffc02047fe:	6d650513          	addi	a0,a0,1750 # ffffffffc0205ed0 <default_pmm_manager+0x78>
ffffffffc0204802:	c4bfb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204806 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204806:	7129                	addi	sp,sp,-320
ffffffffc0204808:	fa22                	sd	s0,304(sp)
ffffffffc020480a:	f626                	sd	s1,296(sp)
ffffffffc020480c:	f24a                	sd	s2,288(sp)
ffffffffc020480e:	84ae                	mv	s1,a1
ffffffffc0204810:	892a                	mv	s2,a0
ffffffffc0204812:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204814:	4581                	li	a1,0
ffffffffc0204816:	12000613          	li	a2,288
ffffffffc020481a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020481c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020481e:	03b000ef          	jal	ra,ffffffffc0205058 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204822:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204824:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204826:	100027f3          	csrr	a5,sstatus
ffffffffc020482a:	edd7f793          	andi	a5,a5,-291
ffffffffc020482e:	1207e793          	ori	a5,a5,288
ffffffffc0204832:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204834:	860a                	mv	a2,sp
ffffffffc0204836:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020483a:	00000797          	auipc	a5,0x0
ffffffffc020483e:	ad878793          	addi	a5,a5,-1320 # ffffffffc0204312 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204842:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204844:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204846:	cbfff0ef          	jal	ra,ffffffffc0204504 <do_fork>
}
ffffffffc020484a:	70f2                	ld	ra,312(sp)
ffffffffc020484c:	7452                	ld	s0,304(sp)
ffffffffc020484e:	74b2                	ld	s1,296(sp)
ffffffffc0204850:	7912                	ld	s2,288(sp)
ffffffffc0204852:	6131                	addi	sp,sp,320
ffffffffc0204854:	8082                	ret

ffffffffc0204856 <do_exit>:
do_exit(int error_code) {
ffffffffc0204856:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204858:	00002617          	auipc	a2,0x2
ffffffffc020485c:	5b060613          	addi	a2,a2,1456 # ffffffffc0206e08 <default_pmm_manager+0xfb0>
ffffffffc0204860:	16900593          	li	a1,361
ffffffffc0204864:	00002517          	auipc	a0,0x2
ffffffffc0204868:	5d450513          	addi	a0,a0,1492 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
do_exit(int error_code) {
ffffffffc020486c:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020486e:	bdffb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204872 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0204872:	00012797          	auipc	a5,0x12
ffffffffc0204876:	d8678793          	addi	a5,a5,-634 # ffffffffc02165f8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc020487a:	1101                	addi	sp,sp,-32
ffffffffc020487c:	00012717          	auipc	a4,0x12
ffffffffc0204880:	d8f73223          	sd	a5,-636(a4) # ffffffffc0216600 <proc_list+0x8>
ffffffffc0204884:	00012717          	auipc	a4,0x12
ffffffffc0204888:	d6f73a23          	sd	a5,-652(a4) # ffffffffc02165f8 <proc_list>
ffffffffc020488c:	ec06                	sd	ra,24(sp)
ffffffffc020488e:	e822                	sd	s0,16(sp)
ffffffffc0204890:	e426                	sd	s1,8(sp)
ffffffffc0204892:	e04a                	sd	s2,0(sp)
ffffffffc0204894:	0000e797          	auipc	a5,0xe
ffffffffc0204898:	bcc78793          	addi	a5,a5,-1076 # ffffffffc0212460 <hash_list>
ffffffffc020489c:	00012717          	auipc	a4,0x12
ffffffffc02048a0:	bc470713          	addi	a4,a4,-1084 # ffffffffc0216460 <name.1566>
ffffffffc02048a4:	e79c                	sd	a5,8(a5)
ffffffffc02048a6:	e39c                	sd	a5,0(a5)
ffffffffc02048a8:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02048aa:	fee79de3          	bne	a5,a4,ffffffffc02048a4 <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02048ae:	a6dff0ef          	jal	ra,ffffffffc020431a <alloc_proc>
ffffffffc02048b2:	00012797          	auipc	a5,0x12
ffffffffc02048b6:	c0a7b723          	sd	a0,-1010(a5) # ffffffffc02164c0 <idleproc>
ffffffffc02048ba:	00012417          	auipc	s0,0x12
ffffffffc02048be:	c0640413          	addi	s0,s0,-1018 # ffffffffc02164c0 <idleproc>
ffffffffc02048c2:	12050963          	beqz	a0,ffffffffc02049f4 <proc_init+0x182>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02048c6:	07000513          	li	a0,112
ffffffffc02048ca:	940fd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02048ce:	07000613          	li	a2,112
ffffffffc02048d2:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02048d4:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02048d6:	782000ef          	jal	ra,ffffffffc0205058 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02048da:	6008                	ld	a0,0(s0)
ffffffffc02048dc:	85a6                	mv	a1,s1
ffffffffc02048de:	07000613          	li	a2,112
ffffffffc02048e2:	03050513          	addi	a0,a0,48
ffffffffc02048e6:	79c000ef          	jal	ra,ffffffffc0205082 <memcmp>
ffffffffc02048ea:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02048ec:	453d                	li	a0,15
ffffffffc02048ee:	91cfd0ef          	jal	ra,ffffffffc0201a0a <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02048f2:	463d                	li	a2,15
ffffffffc02048f4:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02048f6:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02048f8:	760000ef          	jal	ra,ffffffffc0205058 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02048fc:	6008                	ld	a0,0(s0)
ffffffffc02048fe:	463d                	li	a2,15
ffffffffc0204900:	85a6                	mv	a1,s1
ffffffffc0204902:	0b450513          	addi	a0,a0,180
ffffffffc0204906:	77c000ef          	jal	ra,ffffffffc0205082 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020490a:	601c                	ld	a5,0(s0)
ffffffffc020490c:	00012717          	auipc	a4,0x12
ffffffffc0204910:	bfc70713          	addi	a4,a4,-1028 # ffffffffc0216508 <boot_cr3>
ffffffffc0204914:	6318                	ld	a4,0(a4)
ffffffffc0204916:	77d4                	ld	a3,168(a5)
ffffffffc0204918:	08e68d63          	beq	a3,a4,ffffffffc02049b2 <proc_init+0x140>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc020491c:	4709                	li	a4,2
ffffffffc020491e:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0204920:	4485                	li	s1,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204922:	00003717          	auipc	a4,0x3
ffffffffc0204926:	6de70713          	addi	a4,a4,1758 # ffffffffc0208000 <bootstack>
ffffffffc020492a:	eb98                	sd	a4,16(a5)
    set_proc_name(idleproc, "idle");
ffffffffc020492c:	00002597          	auipc	a1,0x2
ffffffffc0204930:	5ac58593          	addi	a1,a1,1452 # ffffffffc0206ed8 <default_pmm_manager+0x1080>
    idleproc->need_resched = 1;
ffffffffc0204934:	cf84                	sw	s1,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc0204936:	853e                	mv	a0,a5
ffffffffc0204938:	a57ff0ef          	jal	ra,ffffffffc020438e <set_proc_name>
    nr_process ++;
ffffffffc020493c:	00012797          	auipc	a5,0x12
ffffffffc0204940:	b9478793          	addi	a5,a5,-1132 # ffffffffc02164d0 <nr_process>
ffffffffc0204944:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0204946:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204948:	4601                	li	a2,0
    nr_process ++;
ffffffffc020494a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020494c:	00002597          	auipc	a1,0x2
ffffffffc0204950:	59458593          	addi	a1,a1,1428 # ffffffffc0206ee0 <default_pmm_manager+0x1088>
ffffffffc0204954:	00000517          	auipc	a0,0x0
ffffffffc0204958:	a9450513          	addi	a0,a0,-1388 # ffffffffc02043e8 <init_main>
    nr_process ++;
ffffffffc020495c:	00012697          	auipc	a3,0x12
ffffffffc0204960:	b6f6aa23          	sw	a5,-1164(a3) # ffffffffc02164d0 <nr_process>
    current = idleproc;
ffffffffc0204964:	00012797          	auipc	a5,0x12
ffffffffc0204968:	b4e7ba23          	sd	a4,-1196(a5) # ffffffffc02164b8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020496c:	e9bff0ef          	jal	ra,ffffffffc0204806 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204970:	0ca05e63          	blez	a0,ffffffffc0204a4c <proc_init+0x1da>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204974:	b35ff0ef          	jal	ra,ffffffffc02044a8 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204978:	00002597          	auipc	a1,0x2
ffffffffc020497c:	59858593          	addi	a1,a1,1432 # ffffffffc0206f10 <default_pmm_manager+0x10b8>
    initproc = find_proc(pid);
ffffffffc0204980:	00012797          	auipc	a5,0x12
ffffffffc0204984:	b4a7b423          	sd	a0,-1208(a5) # ffffffffc02164c8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204988:	a07ff0ef          	jal	ra,ffffffffc020438e <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020498c:	601c                	ld	a5,0(s0)
ffffffffc020498e:	cfd9                	beqz	a5,ffffffffc0204a2c <proc_init+0x1ba>
ffffffffc0204990:	43dc                	lw	a5,4(a5)
ffffffffc0204992:	efc9                	bnez	a5,ffffffffc0204a2c <proc_init+0x1ba>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204994:	00012797          	auipc	a5,0x12
ffffffffc0204998:	b3478793          	addi	a5,a5,-1228 # ffffffffc02164c8 <initproc>
ffffffffc020499c:	639c                	ld	a5,0(a5)
ffffffffc020499e:	c7bd                	beqz	a5,ffffffffc0204a0c <proc_init+0x19a>
ffffffffc02049a0:	43dc                	lw	a5,4(a5)
ffffffffc02049a2:	06979563          	bne	a5,s1,ffffffffc0204a0c <proc_init+0x19a>
}
ffffffffc02049a6:	60e2                	ld	ra,24(sp)
ffffffffc02049a8:	6442                	ld	s0,16(sp)
ffffffffc02049aa:	64a2                	ld	s1,8(sp)
ffffffffc02049ac:	6902                	ld	s2,0(sp)
ffffffffc02049ae:	6105                	addi	sp,sp,32
ffffffffc02049b0:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02049b2:	73d8                	ld	a4,160(a5)
ffffffffc02049b4:	f725                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
ffffffffc02049b6:	f60913e3          	bnez	s2,ffffffffc020491c <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02049ba:	6394                	ld	a3,0(a5)
ffffffffc02049bc:	577d                	li	a4,-1
ffffffffc02049be:	1702                	slli	a4,a4,0x20
ffffffffc02049c0:	f4e69ee3          	bne	a3,a4,ffffffffc020491c <proc_init+0xaa>
ffffffffc02049c4:	4798                	lw	a4,8(a5)
ffffffffc02049c6:	fb39                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02049c8:	6b98                	ld	a4,16(a5)
ffffffffc02049ca:	fb29                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
ffffffffc02049cc:	4f98                	lw	a4,24(a5)
ffffffffc02049ce:	2701                	sext.w	a4,a4
ffffffffc02049d0:	f731                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
ffffffffc02049d2:	7398                	ld	a4,32(a5)
ffffffffc02049d4:	f721                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02049d6:	7798                	ld	a4,40(a5)
ffffffffc02049d8:	f331                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
ffffffffc02049da:	0b07a703          	lw	a4,176(a5)
ffffffffc02049de:	8f49                	or	a4,a4,a0
ffffffffc02049e0:	2701                	sext.w	a4,a4
ffffffffc02049e2:	ff0d                	bnez	a4,ffffffffc020491c <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc02049e4:	00002517          	auipc	a0,0x2
ffffffffc02049e8:	4dc50513          	addi	a0,a0,1244 # ffffffffc0206ec0 <default_pmm_manager+0x1068>
ffffffffc02049ec:	fa2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02049f0:	601c                	ld	a5,0(s0)
ffffffffc02049f2:	b72d                	j	ffffffffc020491c <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc02049f4:	00002617          	auipc	a2,0x2
ffffffffc02049f8:	4b460613          	addi	a2,a2,1204 # ffffffffc0206ea8 <default_pmm_manager+0x1050>
ffffffffc02049fc:	18100593          	li	a1,385
ffffffffc0204a00:	00002517          	auipc	a0,0x2
ffffffffc0204a04:	43850513          	addi	a0,a0,1080 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
ffffffffc0204a08:	a45fb0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204a0c:	00002697          	auipc	a3,0x2
ffffffffc0204a10:	53468693          	addi	a3,a3,1332 # ffffffffc0206f40 <default_pmm_manager+0x10e8>
ffffffffc0204a14:	00001617          	auipc	a2,0x1
ffffffffc0204a18:	0ac60613          	addi	a2,a2,172 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204a1c:	1a800593          	li	a1,424
ffffffffc0204a20:	00002517          	auipc	a0,0x2
ffffffffc0204a24:	41850513          	addi	a0,a0,1048 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
ffffffffc0204a28:	a25fb0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204a2c:	00002697          	auipc	a3,0x2
ffffffffc0204a30:	4ec68693          	addi	a3,a3,1260 # ffffffffc0206f18 <default_pmm_manager+0x10c0>
ffffffffc0204a34:	00001617          	auipc	a2,0x1
ffffffffc0204a38:	08c60613          	addi	a2,a2,140 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204a3c:	1a700593          	li	a1,423
ffffffffc0204a40:	00002517          	auipc	a0,0x2
ffffffffc0204a44:	3f850513          	addi	a0,a0,1016 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
ffffffffc0204a48:	a05fb0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("create init_main failed.\n");
ffffffffc0204a4c:	00002617          	auipc	a2,0x2
ffffffffc0204a50:	4a460613          	addi	a2,a2,1188 # ffffffffc0206ef0 <default_pmm_manager+0x1098>
ffffffffc0204a54:	1a100593          	li	a1,417
ffffffffc0204a58:	00002517          	auipc	a0,0x2
ffffffffc0204a5c:	3e050513          	addi	a0,a0,992 # ffffffffc0206e38 <default_pmm_manager+0xfe0>
ffffffffc0204a60:	9edfb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204a64 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204a64:	1141                	addi	sp,sp,-16
ffffffffc0204a66:	e022                	sd	s0,0(sp)
ffffffffc0204a68:	e406                	sd	ra,8(sp)
ffffffffc0204a6a:	00012417          	auipc	s0,0x12
ffffffffc0204a6e:	a4e40413          	addi	s0,s0,-1458 # ffffffffc02164b8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204a72:	6018                	ld	a4,0(s0)
ffffffffc0204a74:	4f1c                	lw	a5,24(a4)
ffffffffc0204a76:	2781                	sext.w	a5,a5
ffffffffc0204a78:	dff5                	beqz	a5,ffffffffc0204a74 <cpu_idle+0x10>
            schedule();
ffffffffc0204a7a:	0a2000ef          	jal	ra,ffffffffc0204b1c <schedule>
ffffffffc0204a7e:	bfd5                	j	ffffffffc0204a72 <cpu_idle+0xe>

ffffffffc0204a80 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204a80:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204a84:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204a88:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204a8a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204a8c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204a90:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204a94:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204a98:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204a9c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204aa0:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204aa4:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204aa8:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204aac:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204ab0:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204ab4:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204ab8:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204abc:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204abe:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204ac0:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204ac4:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204ac8:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204acc:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204ad0:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204ad4:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204ad8:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204adc:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204ae0:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204ae4:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204ae8:	8082                	ret

ffffffffc0204aea <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204aea:	411c                	lw	a5,0(a0)
ffffffffc0204aec:	4705                	li	a4,1
ffffffffc0204aee:	37f9                	addiw	a5,a5,-2
ffffffffc0204af0:	00f77563          	bgeu	a4,a5,ffffffffc0204afa <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204af4:	4789                	li	a5,2
ffffffffc0204af6:	c11c                	sw	a5,0(a0)
ffffffffc0204af8:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204afa:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204afc:	00002697          	auipc	a3,0x2
ffffffffc0204b00:	46c68693          	addi	a3,a3,1132 # ffffffffc0206f68 <default_pmm_manager+0x1110>
ffffffffc0204b04:	00001617          	auipc	a2,0x1
ffffffffc0204b08:	fbc60613          	addi	a2,a2,-68 # ffffffffc0205ac0 <commands+0x8d8>
ffffffffc0204b0c:	45a5                	li	a1,9
ffffffffc0204b0e:	00002517          	auipc	a0,0x2
ffffffffc0204b12:	49a50513          	addi	a0,a0,1178 # ffffffffc0206fa8 <default_pmm_manager+0x1150>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204b16:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204b18:	935fb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204b1c <schedule>:
}

void
schedule(void) {
ffffffffc0204b1c:	1141                	addi	sp,sp,-16
ffffffffc0204b1e:	e406                	sd	ra,8(sp)
ffffffffc0204b20:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b22:	100027f3          	csrr	a5,sstatus
ffffffffc0204b26:	8b89                	andi	a5,a5,2
ffffffffc0204b28:	4401                	li	s0,0
ffffffffc0204b2a:	e3d1                	bnez	a5,ffffffffc0204bae <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204b2c:	00012797          	auipc	a5,0x12
ffffffffc0204b30:	98c78793          	addi	a5,a5,-1652 # ffffffffc02164b8 <current>
ffffffffc0204b34:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204b38:	00012797          	auipc	a5,0x12
ffffffffc0204b3c:	98878793          	addi	a5,a5,-1656 # ffffffffc02164c0 <idleproc>
ffffffffc0204b40:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0204b42:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204b46:	04a88e63          	beq	a7,a0,ffffffffc0204ba2 <schedule+0x86>
ffffffffc0204b4a:	0c888693          	addi	a3,a7,200
ffffffffc0204b4e:	00012617          	auipc	a2,0x12
ffffffffc0204b52:	aaa60613          	addi	a2,a2,-1366 # ffffffffc02165f8 <proc_list>
        le = last;
ffffffffc0204b56:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204b58:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204b5a:	4809                	li	a6,2
    return listelm->next;
ffffffffc0204b5c:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204b5e:	00c78863          	beq	a5,a2,ffffffffc0204b6e <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204b62:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204b66:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204b6a:	01070463          	beq	a4,a6,ffffffffc0204b72 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204b6e:	fef697e3          	bne	a3,a5,ffffffffc0204b5c <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204b72:	c589                	beqz	a1,ffffffffc0204b7c <schedule+0x60>
ffffffffc0204b74:	4198                	lw	a4,0(a1)
ffffffffc0204b76:	4789                	li	a5,2
ffffffffc0204b78:	00f70e63          	beq	a4,a5,ffffffffc0204b94 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204b7c:	451c                	lw	a5,8(a0)
ffffffffc0204b7e:	2785                	addiw	a5,a5,1
ffffffffc0204b80:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204b82:	00a88463          	beq	a7,a0,ffffffffc0204b8a <schedule+0x6e>
            proc_run(next);
ffffffffc0204b86:	8b5ff0ef          	jal	ra,ffffffffc020443a <proc_run>
    if (flag) {
ffffffffc0204b8a:	e419                	bnez	s0,ffffffffc0204b98 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204b8c:	60a2                	ld	ra,8(sp)
ffffffffc0204b8e:	6402                	ld	s0,0(sp)
ffffffffc0204b90:	0141                	addi	sp,sp,16
ffffffffc0204b92:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204b94:	852e                	mv	a0,a1
ffffffffc0204b96:	b7dd                	j	ffffffffc0204b7c <schedule+0x60>
}
ffffffffc0204b98:	6402                	ld	s0,0(sp)
ffffffffc0204b9a:	60a2                	ld	ra,8(sp)
ffffffffc0204b9c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204b9e:	a2dfb06f          	j	ffffffffc02005ca <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204ba2:	00012617          	auipc	a2,0x12
ffffffffc0204ba6:	a5660613          	addi	a2,a2,-1450 # ffffffffc02165f8 <proc_list>
ffffffffc0204baa:	86b2                	mv	a3,a2
ffffffffc0204bac:	b76d                	j	ffffffffc0204b56 <schedule+0x3a>
        intr_disable();
ffffffffc0204bae:	a23fb0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc0204bb2:	4405                	li	s0,1
ffffffffc0204bb4:	bfa5                	j	ffffffffc0204b2c <schedule+0x10>

ffffffffc0204bb6 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204bb6:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204bba:	2785                	addiw	a5,a5,1
ffffffffc0204bbc:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204bc0:	02000793          	li	a5,32
ffffffffc0204bc4:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204bc8:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204bcc:	8082                	ret

ffffffffc0204bce <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204bce:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204bd2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204bd4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204bd8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204bda:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204bde:	f022                	sd	s0,32(sp)
ffffffffc0204be0:	ec26                	sd	s1,24(sp)
ffffffffc0204be2:	e84a                	sd	s2,16(sp)
ffffffffc0204be4:	f406                	sd	ra,40(sp)
ffffffffc0204be6:	e44e                	sd	s3,8(sp)
ffffffffc0204be8:	84aa                	mv	s1,a0
ffffffffc0204bea:	892e                	mv	s2,a1
ffffffffc0204bec:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204bf0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204bf2:	03067e63          	bgeu	a2,a6,ffffffffc0204c2e <printnum+0x60>
ffffffffc0204bf6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204bf8:	00805763          	blez	s0,ffffffffc0204c06 <printnum+0x38>
ffffffffc0204bfc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204bfe:	85ca                	mv	a1,s2
ffffffffc0204c00:	854e                	mv	a0,s3
ffffffffc0204c02:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204c04:	fc65                	bnez	s0,ffffffffc0204bfc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c06:	1a02                	slli	s4,s4,0x20
ffffffffc0204c08:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204c0c:	00002797          	auipc	a5,0x2
ffffffffc0204c10:	54478793          	addi	a5,a5,1348 # ffffffffc0207150 <error_string+0x38>
ffffffffc0204c14:	9a3e                	add	s4,s4,a5
}
ffffffffc0204c16:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c18:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204c1c:	70a2                	ld	ra,40(sp)
ffffffffc0204c1e:	69a2                	ld	s3,8(sp)
ffffffffc0204c20:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c22:	85ca                	mv	a1,s2
ffffffffc0204c24:	8326                	mv	t1,s1
}
ffffffffc0204c26:	6942                	ld	s2,16(sp)
ffffffffc0204c28:	64e2                	ld	s1,24(sp)
ffffffffc0204c2a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204c2c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204c2e:	03065633          	divu	a2,a2,a6
ffffffffc0204c32:	8722                	mv	a4,s0
ffffffffc0204c34:	f9bff0ef          	jal	ra,ffffffffc0204bce <printnum>
ffffffffc0204c38:	b7f9                	j	ffffffffc0204c06 <printnum+0x38>

ffffffffc0204c3a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204c3a:	7119                	addi	sp,sp,-128
ffffffffc0204c3c:	f4a6                	sd	s1,104(sp)
ffffffffc0204c3e:	f0ca                	sd	s2,96(sp)
ffffffffc0204c40:	e8d2                	sd	s4,80(sp)
ffffffffc0204c42:	e4d6                	sd	s5,72(sp)
ffffffffc0204c44:	e0da                	sd	s6,64(sp)
ffffffffc0204c46:	fc5e                	sd	s7,56(sp)
ffffffffc0204c48:	f862                	sd	s8,48(sp)
ffffffffc0204c4a:	f06a                	sd	s10,32(sp)
ffffffffc0204c4c:	fc86                	sd	ra,120(sp)
ffffffffc0204c4e:	f8a2                	sd	s0,112(sp)
ffffffffc0204c50:	ecce                	sd	s3,88(sp)
ffffffffc0204c52:	f466                	sd	s9,40(sp)
ffffffffc0204c54:	ec6e                	sd	s11,24(sp)
ffffffffc0204c56:	892a                	mv	s2,a0
ffffffffc0204c58:	84ae                	mv	s1,a1
ffffffffc0204c5a:	8d32                	mv	s10,a2
ffffffffc0204c5c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204c5e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c60:	00002a17          	auipc	s4,0x2
ffffffffc0204c64:	360a0a13          	addi	s4,s4,864 # ffffffffc0206fc0 <default_pmm_manager+0x1168>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c68:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204c6c:	00002c17          	auipc	s8,0x2
ffffffffc0204c70:	4acc0c13          	addi	s8,s8,1196 # ffffffffc0207118 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c74:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204c78:	02500793          	li	a5,37
ffffffffc0204c7c:	001d0413          	addi	s0,s10,1
ffffffffc0204c80:	00f50e63          	beq	a0,a5,ffffffffc0204c9c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204c84:	c521                	beqz	a0,ffffffffc0204ccc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c86:	02500993          	li	s3,37
ffffffffc0204c8a:	a011                	j	ffffffffc0204c8e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204c8c:	c121                	beqz	a0,ffffffffc0204ccc <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204c8e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c90:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204c92:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204c94:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204c98:	ff351ae3          	bne	a0,s3,ffffffffc0204c8c <vprintfmt+0x52>
ffffffffc0204c9c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204ca0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204ca4:	4981                	li	s3,0
ffffffffc0204ca6:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204ca8:	5cfd                	li	s9,-1
ffffffffc0204caa:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cac:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204cb0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cb2:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204cb6:	0ff6f693          	andi	a3,a3,255
ffffffffc0204cba:	00140d13          	addi	s10,s0,1
ffffffffc0204cbe:	1ed5ef63          	bltu	a1,a3,ffffffffc0204ebc <vprintfmt+0x282>
ffffffffc0204cc2:	068a                	slli	a3,a3,0x2
ffffffffc0204cc4:	96d2                	add	a3,a3,s4
ffffffffc0204cc6:	4294                	lw	a3,0(a3)
ffffffffc0204cc8:	96d2                	add	a3,a3,s4
ffffffffc0204cca:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204ccc:	70e6                	ld	ra,120(sp)
ffffffffc0204cce:	7446                	ld	s0,112(sp)
ffffffffc0204cd0:	74a6                	ld	s1,104(sp)
ffffffffc0204cd2:	7906                	ld	s2,96(sp)
ffffffffc0204cd4:	69e6                	ld	s3,88(sp)
ffffffffc0204cd6:	6a46                	ld	s4,80(sp)
ffffffffc0204cd8:	6aa6                	ld	s5,72(sp)
ffffffffc0204cda:	6b06                	ld	s6,64(sp)
ffffffffc0204cdc:	7be2                	ld	s7,56(sp)
ffffffffc0204cde:	7c42                	ld	s8,48(sp)
ffffffffc0204ce0:	7ca2                	ld	s9,40(sp)
ffffffffc0204ce2:	7d02                	ld	s10,32(sp)
ffffffffc0204ce4:	6de2                	ld	s11,24(sp)
ffffffffc0204ce6:	6109                	addi	sp,sp,128
ffffffffc0204ce8:	8082                	ret
            padc = '-';
ffffffffc0204cea:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cec:	00144603          	lbu	a2,1(s0)
ffffffffc0204cf0:	846a                	mv	s0,s10
ffffffffc0204cf2:	b7c1                	j	ffffffffc0204cb2 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0204cf4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204cf8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204cfc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cfe:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204d00:	fa0dd9e3          	bgez	s11,ffffffffc0204cb2 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204d04:	8de6                	mv	s11,s9
ffffffffc0204d06:	5cfd                	li	s9,-1
ffffffffc0204d08:	b76d                	j	ffffffffc0204cb2 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0204d0a:	fffdc693          	not	a3,s11
ffffffffc0204d0e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204d10:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204d14:	00144603          	lbu	a2,1(s0)
ffffffffc0204d18:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d1a:	846a                	mv	s0,s10
ffffffffc0204d1c:	bf59                	j	ffffffffc0204cb2 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204d1e:	4705                	li	a4,1
ffffffffc0204d20:	008a8593          	addi	a1,s5,8
ffffffffc0204d24:	01074463          	blt	a4,a6,ffffffffc0204d2c <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0204d28:	22080863          	beqz	a6,ffffffffc0204f58 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0204d2c:	000ab603          	ld	a2,0(s5)
ffffffffc0204d30:	46c1                	li	a3,16
ffffffffc0204d32:	8aae                	mv	s5,a1
ffffffffc0204d34:	a291                	j	ffffffffc0204e78 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0204d36:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204d3a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d3e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204d40:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204d44:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d48:	fad56ce3          	bltu	a0,a3,ffffffffc0204d00 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204d4c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204d4e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204d52:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204d56:	0196873b          	addw	a4,a3,s9
ffffffffc0204d5a:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204d5e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204d62:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204d66:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204d6a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d6e:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204d4c <vprintfmt+0x112>
ffffffffc0204d72:	b779                	j	ffffffffc0204d00 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0204d74:	000aa503          	lw	a0,0(s5)
ffffffffc0204d78:	85a6                	mv	a1,s1
ffffffffc0204d7a:	0aa1                	addi	s5,s5,8
ffffffffc0204d7c:	9902                	jalr	s2
            break;
ffffffffc0204d7e:	bddd                	j	ffffffffc0204c74 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d80:	4705                	li	a4,1
ffffffffc0204d82:	008a8993          	addi	s3,s5,8
ffffffffc0204d86:	01074463          	blt	a4,a6,ffffffffc0204d8e <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0204d8a:	1c080463          	beqz	a6,ffffffffc0204f52 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0204d8e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204d92:	1c044a63          	bltz	s0,ffffffffc0204f66 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0204d96:	8622                	mv	a2,s0
ffffffffc0204d98:	8ace                	mv	s5,s3
ffffffffc0204d9a:	46a9                	li	a3,10
ffffffffc0204d9c:	a8f1                	j	ffffffffc0204e78 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0204d9e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204da2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204da4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204da6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204daa:	8fb5                	xor	a5,a5,a3
ffffffffc0204dac:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204db0:	12d74963          	blt	a4,a3,ffffffffc0204ee2 <vprintfmt+0x2a8>
ffffffffc0204db4:	00369793          	slli	a5,a3,0x3
ffffffffc0204db8:	97e2                	add	a5,a5,s8
ffffffffc0204dba:	639c                	ld	a5,0(a5)
ffffffffc0204dbc:	12078363          	beqz	a5,ffffffffc0204ee2 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204dc0:	86be                	mv	a3,a5
ffffffffc0204dc2:	00000617          	auipc	a2,0x0
ffffffffc0204dc6:	31e60613          	addi	a2,a2,798 # ffffffffc02050e0 <etext+0x2e>
ffffffffc0204dca:	85a6                	mv	a1,s1
ffffffffc0204dcc:	854a                	mv	a0,s2
ffffffffc0204dce:	1cc000ef          	jal	ra,ffffffffc0204f9a <printfmt>
ffffffffc0204dd2:	b54d                	j	ffffffffc0204c74 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204dd4:	000ab603          	ld	a2,0(s5)
ffffffffc0204dd8:	0aa1                	addi	s5,s5,8
ffffffffc0204dda:	1a060163          	beqz	a2,ffffffffc0204f7c <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0204dde:	00160413          	addi	s0,a2,1
ffffffffc0204de2:	15b05763          	blez	s11,ffffffffc0204f30 <vprintfmt+0x2f6>
ffffffffc0204de6:	02d00593          	li	a1,45
ffffffffc0204dea:	10b79d63          	bne	a5,a1,ffffffffc0204f04 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204dee:	00064783          	lbu	a5,0(a2)
ffffffffc0204df2:	0007851b          	sext.w	a0,a5
ffffffffc0204df6:	c905                	beqz	a0,ffffffffc0204e26 <vprintfmt+0x1ec>
ffffffffc0204df8:	000cc563          	bltz	s9,ffffffffc0204e02 <vprintfmt+0x1c8>
ffffffffc0204dfc:	3cfd                	addiw	s9,s9,-1
ffffffffc0204dfe:	036c8263          	beq	s9,s6,ffffffffc0204e22 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204e02:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e04:	14098f63          	beqz	s3,ffffffffc0204f62 <vprintfmt+0x328>
ffffffffc0204e08:	3781                	addiw	a5,a5,-32
ffffffffc0204e0a:	14fbfc63          	bgeu	s7,a5,ffffffffc0204f62 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0204e0e:	03f00513          	li	a0,63
ffffffffc0204e12:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e14:	0405                	addi	s0,s0,1
ffffffffc0204e16:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204e1a:	3dfd                	addiw	s11,s11,-1
ffffffffc0204e1c:	0007851b          	sext.w	a0,a5
ffffffffc0204e20:	fd61                	bnez	a0,ffffffffc0204df8 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204e22:	e5b059e3          	blez	s11,ffffffffc0204c74 <vprintfmt+0x3a>
ffffffffc0204e26:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204e28:	85a6                	mv	a1,s1
ffffffffc0204e2a:	02000513          	li	a0,32
ffffffffc0204e2e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204e30:	e40d82e3          	beqz	s11,ffffffffc0204c74 <vprintfmt+0x3a>
ffffffffc0204e34:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204e36:	85a6                	mv	a1,s1
ffffffffc0204e38:	02000513          	li	a0,32
ffffffffc0204e3c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204e3e:	fe0d94e3          	bnez	s11,ffffffffc0204e26 <vprintfmt+0x1ec>
ffffffffc0204e42:	bd0d                	j	ffffffffc0204c74 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204e44:	4705                	li	a4,1
ffffffffc0204e46:	008a8593          	addi	a1,s5,8
ffffffffc0204e4a:	01074463          	blt	a4,a6,ffffffffc0204e52 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0204e4e:	0e080863          	beqz	a6,ffffffffc0204f3e <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204e52:	000ab603          	ld	a2,0(s5)
ffffffffc0204e56:	46a1                	li	a3,8
ffffffffc0204e58:	8aae                	mv	s5,a1
ffffffffc0204e5a:	a839                	j	ffffffffc0204e78 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0204e5c:	03000513          	li	a0,48
ffffffffc0204e60:	85a6                	mv	a1,s1
ffffffffc0204e62:	e03e                	sd	a5,0(sp)
ffffffffc0204e64:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204e66:	85a6                	mv	a1,s1
ffffffffc0204e68:	07800513          	li	a0,120
ffffffffc0204e6c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204e6e:	0aa1                	addi	s5,s5,8
ffffffffc0204e70:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204e74:	6782                	ld	a5,0(sp)
ffffffffc0204e76:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204e78:	2781                	sext.w	a5,a5
ffffffffc0204e7a:	876e                	mv	a4,s11
ffffffffc0204e7c:	85a6                	mv	a1,s1
ffffffffc0204e7e:	854a                	mv	a0,s2
ffffffffc0204e80:	d4fff0ef          	jal	ra,ffffffffc0204bce <printnum>
            break;
ffffffffc0204e84:	bbc5                	j	ffffffffc0204c74 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204e86:	00144603          	lbu	a2,1(s0)
ffffffffc0204e8a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e8c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204e8e:	b515                	j	ffffffffc0204cb2 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204e90:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204e94:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e96:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204e98:	bd29                	j	ffffffffc0204cb2 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204e9a:	85a6                	mv	a1,s1
ffffffffc0204e9c:	02500513          	li	a0,37
ffffffffc0204ea0:	9902                	jalr	s2
            break;
ffffffffc0204ea2:	bbc9                	j	ffffffffc0204c74 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ea4:	4705                	li	a4,1
ffffffffc0204ea6:	008a8593          	addi	a1,s5,8
ffffffffc0204eaa:	01074463          	blt	a4,a6,ffffffffc0204eb2 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0204eae:	08080d63          	beqz	a6,ffffffffc0204f48 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0204eb2:	000ab603          	ld	a2,0(s5)
ffffffffc0204eb6:	46a9                	li	a3,10
ffffffffc0204eb8:	8aae                	mv	s5,a1
ffffffffc0204eba:	bf7d                	j	ffffffffc0204e78 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204ebc:	85a6                	mv	a1,s1
ffffffffc0204ebe:	02500513          	li	a0,37
ffffffffc0204ec2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204ec4:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204ec8:	02500793          	li	a5,37
ffffffffc0204ecc:	8d22                	mv	s10,s0
ffffffffc0204ece:	daf703e3          	beq	a4,a5,ffffffffc0204c74 <vprintfmt+0x3a>
ffffffffc0204ed2:	02500713          	li	a4,37
ffffffffc0204ed6:	1d7d                	addi	s10,s10,-1
ffffffffc0204ed8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204edc:	fee79de3          	bne	a5,a4,ffffffffc0204ed6 <vprintfmt+0x29c>
ffffffffc0204ee0:	bb51                	j	ffffffffc0204c74 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204ee2:	00002617          	auipc	a2,0x2
ffffffffc0204ee6:	30e60613          	addi	a2,a2,782 # ffffffffc02071f0 <error_string+0xd8>
ffffffffc0204eea:	85a6                	mv	a1,s1
ffffffffc0204eec:	854a                	mv	a0,s2
ffffffffc0204eee:	0ac000ef          	jal	ra,ffffffffc0204f9a <printfmt>
ffffffffc0204ef2:	b349                	j	ffffffffc0204c74 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204ef4:	00002617          	auipc	a2,0x2
ffffffffc0204ef8:	2f460613          	addi	a2,a2,756 # ffffffffc02071e8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204efc:	00002417          	auipc	s0,0x2
ffffffffc0204f00:	2ed40413          	addi	s0,s0,749 # ffffffffc02071e9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f04:	8532                	mv	a0,a2
ffffffffc0204f06:	85e6                	mv	a1,s9
ffffffffc0204f08:	e032                	sd	a2,0(sp)
ffffffffc0204f0a:	e43e                	sd	a5,8(sp)
ffffffffc0204f0c:	0cc000ef          	jal	ra,ffffffffc0204fd8 <strnlen>
ffffffffc0204f10:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204f14:	6602                	ld	a2,0(sp)
ffffffffc0204f16:	01b05d63          	blez	s11,ffffffffc0204f30 <vprintfmt+0x2f6>
ffffffffc0204f1a:	67a2                	ld	a5,8(sp)
ffffffffc0204f1c:	2781                	sext.w	a5,a5
ffffffffc0204f1e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204f20:	6522                	ld	a0,8(sp)
ffffffffc0204f22:	85a6                	mv	a1,s1
ffffffffc0204f24:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f26:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204f28:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204f2a:	6602                	ld	a2,0(sp)
ffffffffc0204f2c:	fe0d9ae3          	bnez	s11,ffffffffc0204f20 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204f30:	00064783          	lbu	a5,0(a2)
ffffffffc0204f34:	0007851b          	sext.w	a0,a5
ffffffffc0204f38:	ec0510e3          	bnez	a0,ffffffffc0204df8 <vprintfmt+0x1be>
ffffffffc0204f3c:	bb25                	j	ffffffffc0204c74 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0204f3e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204f42:	46a1                	li	a3,8
ffffffffc0204f44:	8aae                	mv	s5,a1
ffffffffc0204f46:	bf0d                	j	ffffffffc0204e78 <vprintfmt+0x23e>
ffffffffc0204f48:	000ae603          	lwu	a2,0(s5)
ffffffffc0204f4c:	46a9                	li	a3,10
ffffffffc0204f4e:	8aae                	mv	s5,a1
ffffffffc0204f50:	b725                	j	ffffffffc0204e78 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204f52:	000aa403          	lw	s0,0(s5)
ffffffffc0204f56:	bd35                	j	ffffffffc0204d92 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0204f58:	000ae603          	lwu	a2,0(s5)
ffffffffc0204f5c:	46c1                	li	a3,16
ffffffffc0204f5e:	8aae                	mv	s5,a1
ffffffffc0204f60:	bf21                	j	ffffffffc0204e78 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0204f62:	9902                	jalr	s2
ffffffffc0204f64:	bd45                	j	ffffffffc0204e14 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0204f66:	85a6                	mv	a1,s1
ffffffffc0204f68:	02d00513          	li	a0,45
ffffffffc0204f6c:	e03e                	sd	a5,0(sp)
ffffffffc0204f6e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204f70:	8ace                	mv	s5,s3
ffffffffc0204f72:	40800633          	neg	a2,s0
ffffffffc0204f76:	46a9                	li	a3,10
ffffffffc0204f78:	6782                	ld	a5,0(sp)
ffffffffc0204f7a:	bdfd                	j	ffffffffc0204e78 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0204f7c:	01b05663          	blez	s11,ffffffffc0204f88 <vprintfmt+0x34e>
ffffffffc0204f80:	02d00693          	li	a3,45
ffffffffc0204f84:	f6d798e3          	bne	a5,a3,ffffffffc0204ef4 <vprintfmt+0x2ba>
ffffffffc0204f88:	00002417          	auipc	s0,0x2
ffffffffc0204f8c:	26140413          	addi	s0,s0,609 # ffffffffc02071e9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204f90:	02800513          	li	a0,40
ffffffffc0204f94:	02800793          	li	a5,40
ffffffffc0204f98:	b585                	j	ffffffffc0204df8 <vprintfmt+0x1be>

ffffffffc0204f9a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204f9a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204f9c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204fa0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204fa2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204fa4:	ec06                	sd	ra,24(sp)
ffffffffc0204fa6:	f83a                	sd	a4,48(sp)
ffffffffc0204fa8:	fc3e                	sd	a5,56(sp)
ffffffffc0204faa:	e0c2                	sd	a6,64(sp)
ffffffffc0204fac:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204fae:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204fb0:	c8bff0ef          	jal	ra,ffffffffc0204c3a <vprintfmt>
}
ffffffffc0204fb4:	60e2                	ld	ra,24(sp)
ffffffffc0204fb6:	6161                	addi	sp,sp,80
ffffffffc0204fb8:	8082                	ret

ffffffffc0204fba <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204fba:	00054783          	lbu	a5,0(a0)
ffffffffc0204fbe:	cb91                	beqz	a5,ffffffffc0204fd2 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204fc0:	4781                	li	a5,0
        cnt ++;
ffffffffc0204fc2:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204fc4:	00f50733          	add	a4,a0,a5
ffffffffc0204fc8:	00074703          	lbu	a4,0(a4)
ffffffffc0204fcc:	fb7d                	bnez	a4,ffffffffc0204fc2 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204fce:	853e                	mv	a0,a5
ffffffffc0204fd0:	8082                	ret
    size_t cnt = 0;
ffffffffc0204fd2:	4781                	li	a5,0
}
ffffffffc0204fd4:	853e                	mv	a0,a5
ffffffffc0204fd6:	8082                	ret

ffffffffc0204fd8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204fd8:	c185                	beqz	a1,ffffffffc0204ff8 <strnlen+0x20>
ffffffffc0204fda:	00054783          	lbu	a5,0(a0)
ffffffffc0204fde:	cf89                	beqz	a5,ffffffffc0204ff8 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204fe0:	4781                	li	a5,0
ffffffffc0204fe2:	a021                	j	ffffffffc0204fea <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204fe4:	00074703          	lbu	a4,0(a4)
ffffffffc0204fe8:	c711                	beqz	a4,ffffffffc0204ff4 <strnlen+0x1c>
        cnt ++;
ffffffffc0204fea:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204fec:	00f50733          	add	a4,a0,a5
ffffffffc0204ff0:	fef59ae3          	bne	a1,a5,ffffffffc0204fe4 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204ff4:	853e                	mv	a0,a5
ffffffffc0204ff6:	8082                	ret
    size_t cnt = 0;
ffffffffc0204ff8:	4781                	li	a5,0
}
ffffffffc0204ffa:	853e                	mv	a0,a5
ffffffffc0204ffc:	8082                	ret

ffffffffc0204ffe <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204ffe:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205000:	0585                	addi	a1,a1,1
ffffffffc0205002:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205006:	0785                	addi	a5,a5,1
ffffffffc0205008:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020500c:	fb75                	bnez	a4,ffffffffc0205000 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020500e:	8082                	ret

ffffffffc0205010 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205010:	00054783          	lbu	a5,0(a0)
ffffffffc0205014:	0005c703          	lbu	a4,0(a1)
ffffffffc0205018:	cb91                	beqz	a5,ffffffffc020502c <strcmp+0x1c>
ffffffffc020501a:	00e79c63          	bne	a5,a4,ffffffffc0205032 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020501e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205020:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0205024:	0585                	addi	a1,a1,1
ffffffffc0205026:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020502a:	fbe5                	bnez	a5,ffffffffc020501a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020502c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020502e:	9d19                	subw	a0,a0,a4
ffffffffc0205030:	8082                	ret
ffffffffc0205032:	0007851b          	sext.w	a0,a5
ffffffffc0205036:	9d19                	subw	a0,a0,a4
ffffffffc0205038:	8082                	ret

ffffffffc020503a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020503a:	00054783          	lbu	a5,0(a0)
ffffffffc020503e:	cb91                	beqz	a5,ffffffffc0205052 <strchr+0x18>
        if (*s == c) {
ffffffffc0205040:	00b79563          	bne	a5,a1,ffffffffc020504a <strchr+0x10>
ffffffffc0205044:	a809                	j	ffffffffc0205056 <strchr+0x1c>
ffffffffc0205046:	00b78763          	beq	a5,a1,ffffffffc0205054 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020504a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020504c:	00054783          	lbu	a5,0(a0)
ffffffffc0205050:	fbfd                	bnez	a5,ffffffffc0205046 <strchr+0xc>
    }
    return NULL;
ffffffffc0205052:	4501                	li	a0,0
}
ffffffffc0205054:	8082                	ret
ffffffffc0205056:	8082                	ret

ffffffffc0205058 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205058:	ca01                	beqz	a2,ffffffffc0205068 <memset+0x10>
ffffffffc020505a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020505c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020505e:	0785                	addi	a5,a5,1
ffffffffc0205060:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205064:	fec79de3          	bne	a5,a2,ffffffffc020505e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205068:	8082                	ret

ffffffffc020506a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020506a:	ca19                	beqz	a2,ffffffffc0205080 <memcpy+0x16>
ffffffffc020506c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020506e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205070:	0585                	addi	a1,a1,1
ffffffffc0205072:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205076:	0785                	addi	a5,a5,1
ffffffffc0205078:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020507c:	fec59ae3          	bne	a1,a2,ffffffffc0205070 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205080:	8082                	ret

ffffffffc0205082 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0205082:	c21d                	beqz	a2,ffffffffc02050a8 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0205084:	00054783          	lbu	a5,0(a0)
ffffffffc0205088:	0005c703          	lbu	a4,0(a1)
ffffffffc020508c:	962a                	add	a2,a2,a0
ffffffffc020508e:	00f70963          	beq	a4,a5,ffffffffc02050a0 <memcmp+0x1e>
ffffffffc0205092:	a829                	j	ffffffffc02050ac <memcmp+0x2a>
ffffffffc0205094:	00054783          	lbu	a5,0(a0)
ffffffffc0205098:	0005c703          	lbu	a4,0(a1)
ffffffffc020509c:	00e79863          	bne	a5,a4,ffffffffc02050ac <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc02050a0:	0505                	addi	a0,a0,1
ffffffffc02050a2:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc02050a4:	fea618e3          	bne	a2,a0,ffffffffc0205094 <memcmp+0x12>
    }
    return 0;
ffffffffc02050a8:	4501                	li	a0,0
}
ffffffffc02050aa:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02050ac:	40e7853b          	subw	a0,a5,a4
ffffffffc02050b0:	8082                	ret

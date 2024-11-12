
bin/kernel：     文件格式 elf64-littleriscv


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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	53a60613          	addi	a2,a2,1338 # ffffffffc0206578 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	317010ef          	jal	ra,ffffffffc0201b64 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0201b78 <etext+0x2>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	3c2010ef          	jal	ra,ffffffffc020142c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3f6000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	396000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e2000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3c8000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	59c010ef          	jal	ra,ffffffffc0201646 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	568010ef          	jal	ra,ffffffffc0201646 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	a68d                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ec <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	e822                	sd	s0,16(sp)
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e426                	sd	s1,8(sp)
ffffffffc02000f4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f6:	00054503          	lbu	a0,0(a0)
ffffffffc02000fa:	c51d                	beqz	a0,ffffffffc0200128 <cputs+0x3c>
ffffffffc02000fc:	0405                	addi	s0,s0,1
ffffffffc02000fe:	4485                	li	s1,1
ffffffffc0200100:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200102:	34a000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200106:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010a:	0405                	addi	s0,s0,1
ffffffffc020010c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200110:	f96d                	bnez	a0,ffffffffc0200102 <cputs+0x16>
ffffffffc0200112:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200116:	4529                	li	a0,10
ffffffffc0200118:	334000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	6442                	ld	s0,16(sp)
ffffffffc0200122:	64a2                	ld	s1,8(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200128:	4405                	li	s0,1
ffffffffc020012a:	b7f5                	j	ffffffffc0200116 <cputs+0x2a>

ffffffffc020012c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012c:	1141                	addi	sp,sp,-16
ffffffffc020012e:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200130:	324000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200134:	dd75                	beqz	a0,ffffffffc0200130 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200136:	60a2                	ld	ra,8(sp)
ffffffffc0200138:	0141                	addi	sp,sp,16
ffffffffc020013a:	8082                	ret

ffffffffc020013c <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013e:	00002517          	auipc	a0,0x2
ffffffffc0200142:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201bc8 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00002517          	auipc	a0,0x2
ffffffffc0200158:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201be8 <etext+0x72>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00002597          	auipc	a1,0x2
ffffffffc0200164:	a1658593          	addi	a1,a1,-1514 # ffffffffc0201b76 <etext>
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201c08 <etext+0x92>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	ea458593          	addi	a1,a1,-348 # ffffffffc0206018 <edata>
ffffffffc020017c:	00002517          	auipc	a0,0x2
ffffffffc0200180:	aac50513          	addi	a0,a0,-1364 # ffffffffc0201c28 <etext+0xb2>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	3f058593          	addi	a1,a1,1008 # ffffffffc0206578 <end>
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201c48 <etext+0xd2>
ffffffffc0200198:	f1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019c:	00006597          	auipc	a1,0x6
ffffffffc02001a0:	7db58593          	addi	a1,a1,2011 # ffffffffc0206977 <end+0x3ff>
ffffffffc02001a4:	00000797          	auipc	a5,0x0
ffffffffc02001a8:	e9278793          	addi	a5,a5,-366 # ffffffffc0200036 <kern_init>
ffffffffc02001ac:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b0:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b4:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001ba:	95be                	add	a1,a1,a5
ffffffffc02001bc:	85a9                	srai	a1,a1,0xa
ffffffffc02001be:	00002517          	auipc	a0,0x2
ffffffffc02001c2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201c68 <etext+0xf2>
}
ffffffffc02001c6:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c8:	b5fd                	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ca <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ca:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001cc:	00002617          	auipc	a2,0x2
ffffffffc02001d0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0201b98 <etext+0x22>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	9d850513          	addi	a0,a0,-1576 # ffffffffc0201bb0 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e2:	1c6000ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02001e6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e8:	00002617          	auipc	a2,0x2
ffffffffc02001ec:	b9060613          	addi	a2,a2,-1136 # ffffffffc0201d78 <commands+0xe0>
ffffffffc02001f0:	00002597          	auipc	a1,0x2
ffffffffc02001f4:	ba858593          	addi	a1,a1,-1112 # ffffffffc0201d98 <commands+0x100>
ffffffffc02001f8:	00002517          	auipc	a0,0x2
ffffffffc02001fc:	ba850513          	addi	a0,a0,-1112 # ffffffffc0201da0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00002617          	auipc	a2,0x2
ffffffffc020020a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0201db0 <commands+0x118>
ffffffffc020020e:	00002597          	auipc	a1,0x2
ffffffffc0200212:	bca58593          	addi	a1,a1,-1078 # ffffffffc0201dd8 <commands+0x140>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0201da0 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	bc660613          	addi	a2,a2,-1082 # ffffffffc0201de8 <commands+0x150>
ffffffffc020022a:	00002597          	auipc	a1,0x2
ffffffffc020022e:	bde58593          	addi	a1,a1,-1058 # ffffffffc0201e08 <commands+0x170>
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0201da0 <commands+0x108>
ffffffffc020023a:	e7dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc020023e:	60a2                	ld	ra,8(sp)
ffffffffc0200240:	4501                	li	a0,0
ffffffffc0200242:	0141                	addi	sp,sp,16
ffffffffc0200244:	8082                	ret

ffffffffc0200246 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200246:	1141                	addi	sp,sp,-16
ffffffffc0200248:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024a:	ef3ff0ef          	jal	ra,ffffffffc020013c <print_kerninfo>
    return 0;
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
ffffffffc0200250:	4501                	li	a0,0
ffffffffc0200252:	0141                	addi	sp,sp,16
ffffffffc0200254:	8082                	ret

ffffffffc0200256 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
ffffffffc0200258:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025a:	f71ff0ef          	jal	ra,ffffffffc02001ca <print_stackframe>
    return 0;
}
ffffffffc020025e:	60a2                	ld	ra,8(sp)
ffffffffc0200260:	4501                	li	a0,0
ffffffffc0200262:	0141                	addi	sp,sp,16
ffffffffc0200264:	8082                	ret

ffffffffc0200266 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200266:	7115                	addi	sp,sp,-224
ffffffffc0200268:	e962                	sd	s8,144(sp)
ffffffffc020026a:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	a7450513          	addi	a0,a0,-1420 # ffffffffc0201ce0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200274:	ed86                	sd	ra,216(sp)
ffffffffc0200276:	e9a2                	sd	s0,208(sp)
ffffffffc0200278:	e5a6                	sd	s1,200(sp)
ffffffffc020027a:	e1ca                	sd	s2,192(sp)
ffffffffc020027c:	fd4e                	sd	s3,184(sp)
ffffffffc020027e:	f952                	sd	s4,176(sp)
ffffffffc0200280:	f556                	sd	s5,168(sp)
ffffffffc0200282:	f15a                	sd	s6,160(sp)
ffffffffc0200284:	ed5e                	sd	s7,152(sp)
ffffffffc0200286:	e566                	sd	s9,136(sp)
ffffffffc0200288:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028a:	e2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028e:	00002517          	auipc	a0,0x2
ffffffffc0200292:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201d08 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00002c97          	auipc	s9,0x2
ffffffffc02002a8:	9f4c8c93          	addi	s9,s9,-1548 # ffffffffc0201c98 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00002997          	auipc	s3,0x2
ffffffffc02002b0:	a8498993          	addi	s3,s3,-1404 # ffffffffc0201d30 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	a8490913          	addi	s2,s2,-1404 # ffffffffc0201d38 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00002b17          	auipc	s6,0x2
ffffffffc02002c2:	a82b0b13          	addi	s6,s6,-1406 # ffffffffc0201d40 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	ad2a8a93          	addi	s5,s5,-1326 # ffffffffc0201d98 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	6f4010ef          	jal	ra,ffffffffc02019c6 <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	063010ef          	jal	ra,ffffffffc0201b46 <strchr>
ffffffffc02002e8:	c925                	beqz	a0,ffffffffc0200358 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ea:	00144583          	lbu	a1,1(s0)
ffffffffc02002ee:	00040023          	sb	zero,0(s0)
ffffffffc02002f2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f4:	f5fd                	bnez	a1,ffffffffc02002e2 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002f6:	dce9                	beqz	s1,ffffffffc02002d0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f8:	6582                	ld	a1,0(sp)
ffffffffc02002fa:	00002d17          	auipc	s10,0x2
ffffffffc02002fe:	99ed0d13          	addi	s10,s10,-1634 # ffffffffc0201c98 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	015010ef          	jal	ra,ffffffffc0201b1c <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	001010ef          	jal	ra,ffffffffc0201b1c <strcmp>
ffffffffc0200320:	f57d                	bnez	a0,ffffffffc020030e <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200322:	00141793          	slli	a5,s0,0x1
ffffffffc0200326:	97a2                	add	a5,a5,s0
ffffffffc0200328:	078e                	slli	a5,a5,0x3
ffffffffc020032a:	97e6                	add	a5,a5,s9
ffffffffc020032c:	6b9c                	ld	a5,16(a5)
ffffffffc020032e:	8662                	mv	a2,s8
ffffffffc0200330:	002c                	addi	a1,sp,8
ffffffffc0200332:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200336:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200338:	f8055ce3          	bgez	a0,ffffffffc02002d0 <kmonitor+0x6a>
}
ffffffffc020033c:	60ee                	ld	ra,216(sp)
ffffffffc020033e:	644e                	ld	s0,208(sp)
ffffffffc0200340:	64ae                	ld	s1,200(sp)
ffffffffc0200342:	690e                	ld	s2,192(sp)
ffffffffc0200344:	79ea                	ld	s3,184(sp)
ffffffffc0200346:	7a4a                	ld	s4,176(sp)
ffffffffc0200348:	7aaa                	ld	s5,168(sp)
ffffffffc020034a:	7b0a                	ld	s6,160(sp)
ffffffffc020034c:	6bea                	ld	s7,152(sp)
ffffffffc020034e:	6c4a                	ld	s8,144(sp)
ffffffffc0200350:	6caa                	ld	s9,136(sp)
ffffffffc0200352:	6d0a                	ld	s10,128(sp)
ffffffffc0200354:	612d                	addi	sp,sp,224
ffffffffc0200356:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200358:	00044783          	lbu	a5,0(s0)
ffffffffc020035c:	dfc9                	beqz	a5,ffffffffc02002f6 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020035e:	03448863          	beq	s1,s4,ffffffffc020038e <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200362:	00349793          	slli	a5,s1,0x3
ffffffffc0200366:	0118                	addi	a4,sp,128
ffffffffc0200368:	97ba                	add	a5,a5,a4
ffffffffc020036a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020036e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200372:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200374:	e591                	bnez	a1,ffffffffc0200380 <kmonitor+0x11a>
ffffffffc0200376:	b749                	j	ffffffffc02002f8 <kmonitor+0x92>
            buf ++;
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037a:	00044583          	lbu	a1,0(s0)
ffffffffc020037e:	ddad                	beqz	a1,ffffffffc02002f8 <kmonitor+0x92>
ffffffffc0200380:	854a                	mv	a0,s2
ffffffffc0200382:	7c4010ef          	jal	ra,ffffffffc0201b46 <strchr>
ffffffffc0200386:	d96d                	beqz	a0,ffffffffc0200378 <kmonitor+0x112>
ffffffffc0200388:	00044583          	lbu	a1,0(s0)
ffffffffc020038c:	bf91                	j	ffffffffc02002e0 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038e:	45c1                	li	a1,16
ffffffffc0200390:	855a                	mv	a0,s6
ffffffffc0200392:	d25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200396:	b7f1                	j	ffffffffc0200362 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200398:	6582                	ld	a1,0(sp)
ffffffffc020039a:	00002517          	auipc	a0,0x2
ffffffffc020039e:	9c650513          	addi	a0,a0,-1594 # ffffffffc0201d60 <commands+0xc8>
ffffffffc02003a2:	d15ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003a6:	b72d                	j	ffffffffc02002d0 <kmonitor+0x6a>

ffffffffc02003a8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003a8:	00006317          	auipc	t1,0x6
ffffffffc02003ac:	07030313          	addi	t1,t1,112 # ffffffffc0206418 <is_panic>
ffffffffc02003b0:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b4:	715d                	addi	sp,sp,-80
ffffffffc02003b6:	ec06                	sd	ra,24(sp)
ffffffffc02003b8:	e822                	sd	s0,16(sp)
ffffffffc02003ba:	f436                	sd	a3,40(sp)
ffffffffc02003bc:	f83a                	sd	a4,48(sp)
ffffffffc02003be:	fc3e                	sd	a5,56(sp)
ffffffffc02003c0:	e0c2                	sd	a6,64(sp)
ffffffffc02003c2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c4:	02031c63          	bnez	t1,ffffffffc02003fc <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003c8:	4785                	li	a5,1
ffffffffc02003ca:	8432                	mv	s0,a2
ffffffffc02003cc:	00006717          	auipc	a4,0x6
ffffffffc02003d0:	04f72623          	sw	a5,76(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003d6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201e18 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	cd3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	cabff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0201c90 <etext+0x11a>
ffffffffc02003f8:	cbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e65ff0ef          	jal	ra,ffffffffc0200266 <kmonitor>
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x58>

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
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	680010ef          	jal	ra,ffffffffc0201aa0 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0207b123          	sd	zero,34(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e38 <commands+0x1a0>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9bd                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	65a0106f          	j	ffffffffc0201aa0 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	6340106f          	j	ffffffffc0201a84 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	6680106f          	j	ffffffffc0201abc <sbi_console_getchar>

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
ffffffffc020046c:	3a078793          	addi	a5,a5,928 # ffffffffc0200808 <__alltraps>
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
ffffffffc0200482:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0201fd8 <commands+0x340>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	b6250513          	addi	a0,a0,-1182 # ffffffffc0201ff0 <commands+0x358>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202008 <commands+0x370>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202020 <commands+0x388>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202038 <commands+0x3a0>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202050 <commands+0x3b8>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	b9450513          	addi	a0,a0,-1132 # ffffffffc0202068 <commands+0x3d0>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202080 <commands+0x3e8>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0202098 <commands+0x400>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	bb250513          	addi	a0,a0,-1102 # ffffffffc02020b0 <commands+0x418>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02020c8 <commands+0x430>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	bc650513          	addi	a0,a0,-1082 # ffffffffc02020e0 <commands+0x448>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	bd050513          	addi	a0,a0,-1072 # ffffffffc02020f8 <commands+0x460>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202110 <commands+0x478>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	be450513          	addi	a0,a0,-1052 # ffffffffc0202128 <commands+0x490>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	bee50513          	addi	a0,a0,-1042 # ffffffffc0202140 <commands+0x4a8>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202158 <commands+0x4c0>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	c0250513          	addi	a0,a0,-1022 # ffffffffc0202170 <commands+0x4d8>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202188 <commands+0x4f0>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	c1650513          	addi	a0,a0,-1002 # ffffffffc02021a0 <commands+0x508>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	c2050513          	addi	a0,a0,-992 # ffffffffc02021b8 <commands+0x520>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	c2a50513          	addi	a0,a0,-982 # ffffffffc02021d0 <commands+0x538>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	c3450513          	addi	a0,a0,-972 # ffffffffc02021e8 <commands+0x550>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	c3e50513          	addi	a0,a0,-962 # ffffffffc0202200 <commands+0x568>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	c4850513          	addi	a0,a0,-952 # ffffffffc0202218 <commands+0x580>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	c5250513          	addi	a0,a0,-942 # ffffffffc0202230 <commands+0x598>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	c5c50513          	addi	a0,a0,-932 # ffffffffc0202248 <commands+0x5b0>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	c6650513          	addi	a0,a0,-922 # ffffffffc0202260 <commands+0x5c8>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	c7050513          	addi	a0,a0,-912 # ffffffffc0202278 <commands+0x5e0>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0202290 <commands+0x5f8>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	c8450513          	addi	a0,a0,-892 # ffffffffc02022a8 <commands+0x610>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	c8a50513          	addi	a0,a0,-886 # ffffffffc02022c0 <commands+0x628>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc9d                	j	ffffffffc02000b6 <cprintf>

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
ffffffffc020064e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022d8 <commands+0x640>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022f0 <commands+0x658>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	c9650513          	addi	a0,a0,-874 # ffffffffc0202308 <commands+0x670>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202320 <commands+0x688>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	ca250513          	addi	a0,a0,-862 # ffffffffc0202338 <commands+0x6a0>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc19                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02006a6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02006ac:	08f76963          	bltu	a4,a5,ffffffffc020073e <interrupt_handler+0x9c>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7a470713          	addi	a4,a4,1956 # ffffffffc0201e54 <commands+0x1bc>
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
ffffffffc02006c6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201f70 <commands+0x2d8>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	88450513          	addi	a0,a0,-1916 # ffffffffc0201f50 <commands+0x2b8>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201f10 <commands+0x278>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201f90 <commands+0x2f8>
ffffffffc02006e8:	b2f9                	j	ffffffffc02000b6 <cprintf>
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
ffffffffc02006f4:	00006797          	auipc	a5,0x6
ffffffffc02006f8:	d3478793          	addi	a5,a5,-716 # ffffffffc0206428 <ticks.1331>
ffffffffc02006fc:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d1e40413          	addi	s0,s0,-738 # ffffffffc0206420 <num>
            ticks++;
ffffffffc020070a:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
ffffffffc020070c:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200710:	00006697          	auipc	a3,0x6
ffffffffc0200714:	d0f6ac23          	sw	a5,-744(a3) # ffffffffc0206428 <ticks.1331>
            if (ticks % TICK_NUM == 0){
ffffffffc0200718:	c705                	beqz	a4,ffffffffc0200740 <interrupt_handler+0x9e>
            num++;
            print_ticks();
            }
            
            if (num == 10){
ffffffffc020071a:	6018                	ld	a4,0(s0)
ffffffffc020071c:	47a9                	li	a5,10
ffffffffc020071e:	04f70063          	beq	a4,a5,ffffffffc020075e <interrupt_handler+0xbc>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200722:	60a2                	ld	ra,8(sp)
ffffffffc0200724:	6402                	ld	s0,0(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201fb8 <commands+0x320>
ffffffffc0200732:	b251                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200734:	00001517          	auipc	a0,0x1
ffffffffc0200738:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201f30 <commands+0x298>
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020073e:	b711                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc0200740:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200742:	06400593          	li	a1,100
ffffffffc0200746:	00002517          	auipc	a0,0x2
ffffffffc020074a:	86250513          	addi	a0,a0,-1950 # ffffffffc0201fa8 <commands+0x310>
            num++;
ffffffffc020074e:	0785                	addi	a5,a5,1
ffffffffc0200750:	00006717          	auipc	a4,0x6
ffffffffc0200754:	ccf73823          	sd	a5,-816(a4) # ffffffffc0206420 <num>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200758:	95fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020075c:	bf7d                	j	ffffffffc020071a <interrupt_handler+0x78>
}
ffffffffc020075e:	6402                	ld	s0,0(sp)
ffffffffc0200760:	60a2                	ld	ra,8(sp)
ffffffffc0200762:	0141                	addi	sp,sp,16
            sbi_shutdown();
ffffffffc0200764:	3760106f          	j	ffffffffc0201ada <sbi_shutdown>

ffffffffc0200768 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200768:	11853783          	ld	a5,280(a0)
ffffffffc020076c:	472d                	li	a4,11
ffffffffc020076e:	02f76863          	bltu	a4,a5,ffffffffc020079e <exception_handler+0x36>
ffffffffc0200772:	4705                	li	a4,1
ffffffffc0200774:	00f71733          	sll	a4,a4,a5
ffffffffc0200778:	6785                	lui	a5,0x1
ffffffffc020077a:	f5178793          	addi	a5,a5,-175 # f51 <BASE_ADDRESS-0xffffffffc01ff0af>
ffffffffc020077e:	8ff9                	and	a5,a5,a4
ffffffffc0200780:	ef91                	bnez	a5,ffffffffc020079c <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
ffffffffc0200782:	1141                	addi	sp,sp,-16
ffffffffc0200784:	e022                	sd	s0,0(sp)
ffffffffc0200786:	e406                	sd	ra,8(sp)
ffffffffc0200788:	00877793          	andi	a5,a4,8
ffffffffc020078c:	842a                	mv	s0,a0
ffffffffc020078e:	e3a1                	bnez	a5,ffffffffc02007ce <exception_handler+0x66>
ffffffffc0200790:	8b11                	andi	a4,a4,4
ffffffffc0200792:	e719                	bnez	a4,ffffffffc02007a0 <exception_handler+0x38>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200794:	6402                	ld	s0,0(sp)
ffffffffc0200796:	60a2                	ld	ra,8(sp)
ffffffffc0200798:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc020079a:	b565                	j	ffffffffc0200642 <print_trapframe>
ffffffffc020079c:	8082                	ret
ffffffffc020079e:	b555                	j	ffffffffc0200642 <print_trapframe>
           cprintf("Exception type:Illegal instruction\n");
ffffffffc02007a0:	00001517          	auipc	a0,0x1
ffffffffc02007a4:	6e850513          	addi	a0,a0,1768 # ffffffffc0201e88 <commands+0x1f0>
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc02007ac:	10843583          	ld	a1,264(s0)
ffffffffc02007b0:	00001517          	auipc	a0,0x1
ffffffffc02007b4:	70050513          	addi	a0,a0,1792 # ffffffffc0201eb0 <commands+0x218>
ffffffffc02007b8:	8ffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           tf->epc += 4;
ffffffffc02007bc:	10843783          	ld	a5,264(s0)
}
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
           tf->epc += 4;
ffffffffc02007c2:	0791                	addi	a5,a5,4
ffffffffc02007c4:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007c8:	6402                	ld	s0,0(sp)
ffffffffc02007ca:	0141                	addi	sp,sp,16
ffffffffc02007cc:	8082                	ret
           cprintf("Exception type: breakpoint\n");
ffffffffc02007ce:	00001517          	auipc	a0,0x1
ffffffffc02007d2:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ed8 <commands+0x240>
ffffffffc02007d6:	8e1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007da:	10843583          	ld	a1,264(s0)
ffffffffc02007de:	00001517          	auipc	a0,0x1
ffffffffc02007e2:	71a50513          	addi	a0,a0,1818 # ffffffffc0201ef8 <commands+0x260>
ffffffffc02007e6:	8d1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           tf->epc += 2;
ffffffffc02007ea:	10843783          	ld	a5,264(s0)
}
ffffffffc02007ee:	60a2                	ld	ra,8(sp)
           tf->epc += 2;
ffffffffc02007f0:	0789                	addi	a5,a5,2
ffffffffc02007f2:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007f6:	6402                	ld	s0,0(sp)
ffffffffc02007f8:	0141                	addi	sp,sp,16
ffffffffc02007fa:	8082                	ret

ffffffffc02007fc <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007fc:	11853783          	ld	a5,280(a0)
ffffffffc0200800:	0007c363          	bltz	a5,ffffffffc0200806 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200804:	b795                	j	ffffffffc0200768 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200806:	bd71                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc0200808 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200808:	14011073          	csrw	sscratch,sp
ffffffffc020080c:	712d                	addi	sp,sp,-288
ffffffffc020080e:	e002                	sd	zero,0(sp)
ffffffffc0200810:	e406                	sd	ra,8(sp)
ffffffffc0200812:	ec0e                	sd	gp,24(sp)
ffffffffc0200814:	f012                	sd	tp,32(sp)
ffffffffc0200816:	f416                	sd	t0,40(sp)
ffffffffc0200818:	f81a                	sd	t1,48(sp)
ffffffffc020081a:	fc1e                	sd	t2,56(sp)
ffffffffc020081c:	e0a2                	sd	s0,64(sp)
ffffffffc020081e:	e4a6                	sd	s1,72(sp)
ffffffffc0200820:	e8aa                	sd	a0,80(sp)
ffffffffc0200822:	ecae                	sd	a1,88(sp)
ffffffffc0200824:	f0b2                	sd	a2,96(sp)
ffffffffc0200826:	f4b6                	sd	a3,104(sp)
ffffffffc0200828:	f8ba                	sd	a4,112(sp)
ffffffffc020082a:	fcbe                	sd	a5,120(sp)
ffffffffc020082c:	e142                	sd	a6,128(sp)
ffffffffc020082e:	e546                	sd	a7,136(sp)
ffffffffc0200830:	e94a                	sd	s2,144(sp)
ffffffffc0200832:	ed4e                	sd	s3,152(sp)
ffffffffc0200834:	f152                	sd	s4,160(sp)
ffffffffc0200836:	f556                	sd	s5,168(sp)
ffffffffc0200838:	f95a                	sd	s6,176(sp)
ffffffffc020083a:	fd5e                	sd	s7,184(sp)
ffffffffc020083c:	e1e2                	sd	s8,192(sp)
ffffffffc020083e:	e5e6                	sd	s9,200(sp)
ffffffffc0200840:	e9ea                	sd	s10,208(sp)
ffffffffc0200842:	edee                	sd	s11,216(sp)
ffffffffc0200844:	f1f2                	sd	t3,224(sp)
ffffffffc0200846:	f5f6                	sd	t4,232(sp)
ffffffffc0200848:	f9fa                	sd	t5,240(sp)
ffffffffc020084a:	fdfe                	sd	t6,248(sp)
ffffffffc020084c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200850:	100024f3          	csrr	s1,sstatus
ffffffffc0200854:	14102973          	csrr	s2,sepc
ffffffffc0200858:	143029f3          	csrr	s3,stval
ffffffffc020085c:	14202a73          	csrr	s4,scause
ffffffffc0200860:	e822                	sd	s0,16(sp)
ffffffffc0200862:	e226                	sd	s1,256(sp)
ffffffffc0200864:	e64a                	sd	s2,264(sp)
ffffffffc0200866:	ea4e                	sd	s3,272(sp)
ffffffffc0200868:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020086a:	850a                	mv	a0,sp
    jal trap
ffffffffc020086c:	f91ff0ef          	jal	ra,ffffffffc02007fc <trap>

ffffffffc0200870 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200870:	6492                	ld	s1,256(sp)
ffffffffc0200872:	6932                	ld	s2,264(sp)
ffffffffc0200874:	10049073          	csrw	sstatus,s1
ffffffffc0200878:	14191073          	csrw	sepc,s2
ffffffffc020087c:	60a2                	ld	ra,8(sp)
ffffffffc020087e:	61e2                	ld	gp,24(sp)
ffffffffc0200880:	7202                	ld	tp,32(sp)
ffffffffc0200882:	72a2                	ld	t0,40(sp)
ffffffffc0200884:	7342                	ld	t1,48(sp)
ffffffffc0200886:	73e2                	ld	t2,56(sp)
ffffffffc0200888:	6406                	ld	s0,64(sp)
ffffffffc020088a:	64a6                	ld	s1,72(sp)
ffffffffc020088c:	6546                	ld	a0,80(sp)
ffffffffc020088e:	65e6                	ld	a1,88(sp)
ffffffffc0200890:	7606                	ld	a2,96(sp)
ffffffffc0200892:	76a6                	ld	a3,104(sp)
ffffffffc0200894:	7746                	ld	a4,112(sp)
ffffffffc0200896:	77e6                	ld	a5,120(sp)
ffffffffc0200898:	680a                	ld	a6,128(sp)
ffffffffc020089a:	68aa                	ld	a7,136(sp)
ffffffffc020089c:	694a                	ld	s2,144(sp)
ffffffffc020089e:	69ea                	ld	s3,152(sp)
ffffffffc02008a0:	7a0a                	ld	s4,160(sp)
ffffffffc02008a2:	7aaa                	ld	s5,168(sp)
ffffffffc02008a4:	7b4a                	ld	s6,176(sp)
ffffffffc02008a6:	7bea                	ld	s7,184(sp)
ffffffffc02008a8:	6c0e                	ld	s8,192(sp)
ffffffffc02008aa:	6cae                	ld	s9,200(sp)
ffffffffc02008ac:	6d4e                	ld	s10,208(sp)
ffffffffc02008ae:	6dee                	ld	s11,216(sp)
ffffffffc02008b0:	7e0e                	ld	t3,224(sp)
ffffffffc02008b2:	7eae                	ld	t4,232(sp)
ffffffffc02008b4:	7f4e                	ld	t5,240(sp)
ffffffffc02008b6:	7fee                	ld	t6,248(sp)
ffffffffc02008b8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008ba:	10200073          	sret

ffffffffc02008be <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008be:	00006797          	auipc	a5,0x6
ffffffffc02008c2:	b9278793          	addi	a5,a5,-1134 # ffffffffc0206450 <free_area>
ffffffffc02008c6:	e79c                	sd	a5,8(a5)
ffffffffc02008c8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008ca:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008ce:	8082                	ret

ffffffffc02008d0 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	b9056503          	lwu	a0,-1136(a0) # ffffffffc0206460 <free_area+0x10>
ffffffffc02008d8:	8082                	ret

ffffffffc02008da <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc02008da:	c15d                	beqz	a0,ffffffffc0200980 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc02008dc:	00006617          	auipc	a2,0x6
ffffffffc02008e0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0206450 <free_area>
ffffffffc02008e4:	01062803          	lw	a6,16(a2)
ffffffffc02008e8:	86aa                	mv	a3,a0
ffffffffc02008ea:	02081793          	slli	a5,a6,0x20
ffffffffc02008ee:	9381                	srli	a5,a5,0x20
ffffffffc02008f0:	08a7e663          	bltu	a5,a0,ffffffffc020097c <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc02008f4:	0018059b          	addiw	a1,a6,1
ffffffffc02008f8:	1582                	slli	a1,a1,0x20
ffffffffc02008fa:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc02008fc:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc02008fe:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200900:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0200902:	00c78e63          	beq	a5,a2,ffffffffc020091e <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property < min_size)
ffffffffc0200906:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020090a:	fed76be3          	bltu	a4,a3,ffffffffc0200900 <best_fit_alloc_pages+0x26>
ffffffffc020090e:	feb779e3          	bgeu	a4,a1,ffffffffc0200900 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200912:	fe878513          	addi	a0,a5,-24
ffffffffc0200916:	679c                	ld	a5,8(a5)
ffffffffc0200918:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020091a:	fec796e3          	bne	a5,a2,ffffffffc0200906 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020091e:	c125                	beqz	a0,ffffffffc020097e <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200920:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200922:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200924:	490c                	lw	a1,16(a0)
ffffffffc0200926:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020092a:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020092c:	e310                	sd	a2,0(a4)
ffffffffc020092e:	02059713          	slli	a4,a1,0x20
ffffffffc0200932:	9301                	srli	a4,a4,0x20
ffffffffc0200934:	02e6f863          	bgeu	a3,a4,ffffffffc0200964 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200938:	00269713          	slli	a4,a3,0x2
ffffffffc020093c:	9736                	add	a4,a4,a3
ffffffffc020093e:	070e                	slli	a4,a4,0x3
ffffffffc0200940:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0200942:	411585bb          	subw	a1,a1,a7
ffffffffc0200946:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200948:	4689                	li	a3,2
ffffffffc020094a:	00870593          	addi	a1,a4,8
ffffffffc020094e:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200952:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0200954:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0200958:	0107a803          	lw	a6,16(a5)
ffffffffc020095c:	e28c                	sd	a1,0(a3)
ffffffffc020095e:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc0200960:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0200962:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc0200964:	4118083b          	subw	a6,a6,a7
ffffffffc0200968:	00006797          	auipc	a5,0x6
ffffffffc020096c:	af07ac23          	sw	a6,-1288(a5) # ffffffffc0206460 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200970:	57f5                	li	a5,-3
ffffffffc0200972:	00850713          	addi	a4,a0,8
ffffffffc0200976:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc020097a:	8082                	ret
        return NULL;
ffffffffc020097c:	4501                	li	a0,0
}
ffffffffc020097e:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200980:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200982:	00002697          	auipc	a3,0x2
ffffffffc0200986:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0202350 <commands+0x6b8>
ffffffffc020098a:	00002617          	auipc	a2,0x2
ffffffffc020098e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200992:	06d00593          	li	a1,109
ffffffffc0200996:	00002517          	auipc	a0,0x2
ffffffffc020099a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0202370 <commands+0x6d8>
best_fit_alloc_pages(size_t n) {
ffffffffc020099e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02009a0:	a09ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02009a4 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02009a4:	715d                	addi	sp,sp,-80
ffffffffc02009a6:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02009a8:	00006917          	auipc	s2,0x6
ffffffffc02009ac:	aa890913          	addi	s2,s2,-1368 # ffffffffc0206450 <free_area>
ffffffffc02009b0:	00893783          	ld	a5,8(s2)
ffffffffc02009b4:	e486                	sd	ra,72(sp)
ffffffffc02009b6:	e0a2                	sd	s0,64(sp)
ffffffffc02009b8:	fc26                	sd	s1,56(sp)
ffffffffc02009ba:	f44e                	sd	s3,40(sp)
ffffffffc02009bc:	f052                	sd	s4,32(sp)
ffffffffc02009be:	ec56                	sd	s5,24(sp)
ffffffffc02009c0:	e85a                	sd	s6,16(sp)
ffffffffc02009c2:	e45e                	sd	s7,8(sp)
ffffffffc02009c4:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009c6:	2d278363          	beq	a5,s2,ffffffffc0200c8c <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009ca:	ff07b703          	ld	a4,-16(a5)
ffffffffc02009ce:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009d0:	8b05                	andi	a4,a4,1
ffffffffc02009d2:	2c070163          	beqz	a4,ffffffffc0200c94 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc02009d6:	4401                	li	s0,0
ffffffffc02009d8:	4481                	li	s1,0
ffffffffc02009da:	a031                	j	ffffffffc02009e6 <best_fit_check+0x42>
ffffffffc02009dc:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02009e0:	8b09                	andi	a4,a4,2
ffffffffc02009e2:	2a070963          	beqz	a4,ffffffffc0200c94 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc02009e6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02009ea:	679c                	ld	a5,8(a5)
ffffffffc02009ec:	2485                	addiw	s1,s1,1
ffffffffc02009ee:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009f0:	ff2796e3          	bne	a5,s2,ffffffffc02009dc <best_fit_check+0x38>
ffffffffc02009f4:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc02009f6:	1f7000ef          	jal	ra,ffffffffc02013ec <nr_free_pages>
ffffffffc02009fa:	37351d63          	bne	a0,s3,ffffffffc0200d74 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009fe:	4505                	li	a0,1
ffffffffc0200a00:	163000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200a04:	8a2a                	mv	s4,a0
ffffffffc0200a06:	3a050763          	beqz	a0,ffffffffc0200db4 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a0a:	4505                	li	a0,1
ffffffffc0200a0c:	157000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200a10:	89aa                	mv	s3,a0
ffffffffc0200a12:	38050163          	beqz	a0,ffffffffc0200d94 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a16:	4505                	li	a0,1
ffffffffc0200a18:	14b000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200a1c:	8aaa                	mv	s5,a0
ffffffffc0200a1e:	30050b63          	beqz	a0,ffffffffc0200d34 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a22:	293a0963          	beq	s4,s3,ffffffffc0200cb4 <best_fit_check+0x310>
ffffffffc0200a26:	28aa0763          	beq	s4,a0,ffffffffc0200cb4 <best_fit_check+0x310>
ffffffffc0200a2a:	28a98563          	beq	s3,a0,ffffffffc0200cb4 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a2e:	000a2783          	lw	a5,0(s4)
ffffffffc0200a32:	2a079163          	bnez	a5,ffffffffc0200cd4 <best_fit_check+0x330>
ffffffffc0200a36:	0009a783          	lw	a5,0(s3)
ffffffffc0200a3a:	28079d63          	bnez	a5,ffffffffc0200cd4 <best_fit_check+0x330>
ffffffffc0200a3e:	411c                	lw	a5,0(a0)
ffffffffc0200a40:	28079a63          	bnez	a5,ffffffffc0200cd4 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a44:	00006797          	auipc	a5,0x6
ffffffffc0200a48:	b2c78793          	addi	a5,a5,-1236 # ffffffffc0206570 <pages>
ffffffffc0200a4c:	639c                	ld	a5,0(a5)
ffffffffc0200a4e:	00002717          	auipc	a4,0x2
ffffffffc0200a52:	93a70713          	addi	a4,a4,-1734 # ffffffffc0202388 <commands+0x6f0>
ffffffffc0200a56:	630c                	ld	a1,0(a4)
ffffffffc0200a58:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a5c:	870d                	srai	a4,a4,0x3
ffffffffc0200a5e:	02b70733          	mul	a4,a4,a1
ffffffffc0200a62:	00002697          	auipc	a3,0x2
ffffffffc0200a66:	fe668693          	addi	a3,a3,-26 # ffffffffc0202a48 <nbase>
ffffffffc0200a6a:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a6c:	00006697          	auipc	a3,0x6
ffffffffc0200a70:	9c468693          	addi	a3,a3,-1596 # ffffffffc0206430 <npage>
ffffffffc0200a74:	6294                	ld	a3,0(a3)
ffffffffc0200a76:	06b2                	slli	a3,a3,0xc
ffffffffc0200a78:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a7a:	0732                	slli	a4,a4,0xc
ffffffffc0200a7c:	26d77c63          	bgeu	a4,a3,ffffffffc0200cf4 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a80:	40f98733          	sub	a4,s3,a5
ffffffffc0200a84:	870d                	srai	a4,a4,0x3
ffffffffc0200a86:	02b70733          	mul	a4,a4,a1
ffffffffc0200a8a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a8c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a8e:	42d77363          	bgeu	a4,a3,ffffffffc0200eb4 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a92:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a96:	878d                	srai	a5,a5,0x3
ffffffffc0200a98:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a9c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a9e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200aa0:	3ed7fa63          	bgeu	a5,a3,ffffffffc0200e94 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200aa4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200aa6:	00093c03          	ld	s8,0(s2)
ffffffffc0200aaa:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200aae:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200ab2:	00006797          	auipc	a5,0x6
ffffffffc0200ab6:	9b27b323          	sd	s2,-1626(a5) # ffffffffc0206458 <free_area+0x8>
ffffffffc0200aba:	00006797          	auipc	a5,0x6
ffffffffc0200abe:	9927bb23          	sd	s2,-1642(a5) # ffffffffc0206450 <free_area>
    nr_free = 0;
ffffffffc0200ac2:	00006797          	auipc	a5,0x6
ffffffffc0200ac6:	9807af23          	sw	zero,-1634(a5) # ffffffffc0206460 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200aca:	099000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200ace:	3a051363          	bnez	a0,ffffffffc0200e74 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200ad2:	4585                	li	a1,1
ffffffffc0200ad4:	8552                	mv	a0,s4
ffffffffc0200ad6:	0d1000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    free_page(p1);
ffffffffc0200ada:	4585                	li	a1,1
ffffffffc0200adc:	854e                	mv	a0,s3
ffffffffc0200ade:	0c9000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    free_page(p2);
ffffffffc0200ae2:	4585                	li	a1,1
ffffffffc0200ae4:	8556                	mv	a0,s5
ffffffffc0200ae6:	0c1000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200aea:	01092703          	lw	a4,16(s2)
ffffffffc0200aee:	478d                	li	a5,3
ffffffffc0200af0:	36f71263          	bne	a4,a5,ffffffffc0200e54 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200af4:	4505                	li	a0,1
ffffffffc0200af6:	06d000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200afa:	89aa                	mv	s3,a0
ffffffffc0200afc:	32050c63          	beqz	a0,ffffffffc0200e34 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b00:	4505                	li	a0,1
ffffffffc0200b02:	061000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b06:	8aaa                	mv	s5,a0
ffffffffc0200b08:	30050663          	beqz	a0,ffffffffc0200e14 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b0c:	4505                	li	a0,1
ffffffffc0200b0e:	055000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b12:	8a2a                	mv	s4,a0
ffffffffc0200b14:	2e050063          	beqz	a0,ffffffffc0200df4 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200b18:	4505                	li	a0,1
ffffffffc0200b1a:	049000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b1e:	2a051b63          	bnez	a0,ffffffffc0200dd4 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200b22:	4585                	li	a1,1
ffffffffc0200b24:	854e                	mv	a0,s3
ffffffffc0200b26:	081000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200b2a:	00893783          	ld	a5,8(s2)
ffffffffc0200b2e:	1f278363          	beq	a5,s2,ffffffffc0200d14 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	02f000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b38:	54a99e63          	bne	s3,a0,ffffffffc0201094 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200b3c:	4505                	li	a0,1
ffffffffc0200b3e:	025000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b42:	52051963          	bnez	a0,ffffffffc0201074 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200b46:	01092783          	lw	a5,16(s2)
ffffffffc0200b4a:	50079563          	bnez	a5,ffffffffc0201054 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200b4e:	854e                	mv	a0,s3
ffffffffc0200b50:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200b52:	00006797          	auipc	a5,0x6
ffffffffc0200b56:	8f87bf23          	sd	s8,-1794(a5) # ffffffffc0206450 <free_area>
ffffffffc0200b5a:	00006797          	auipc	a5,0x6
ffffffffc0200b5e:	8f77bf23          	sd	s7,-1794(a5) # ffffffffc0206458 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200b62:	00006797          	auipc	a5,0x6
ffffffffc0200b66:	8f67af23          	sw	s6,-1794(a5) # ffffffffc0206460 <free_area+0x10>
    free_page(p);
ffffffffc0200b6a:	03d000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    free_page(p1);
ffffffffc0200b6e:	4585                	li	a1,1
ffffffffc0200b70:	8556                	mv	a0,s5
ffffffffc0200b72:	035000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    free_page(p2);
ffffffffc0200b76:	4585                	li	a1,1
ffffffffc0200b78:	8552                	mv	a0,s4
ffffffffc0200b7a:	02d000ef          	jal	ra,ffffffffc02013a6 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b7e:	4515                	li	a0,5
ffffffffc0200b80:	7e2000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200b84:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200b86:	4a050763          	beqz	a0,ffffffffc0201034 <best_fit_check+0x690>
ffffffffc0200b8a:	651c                	ld	a5,8(a0)
ffffffffc0200b8c:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b8e:	8b85                	andi	a5,a5,1
ffffffffc0200b90:	48079263          	bnez	a5,ffffffffc0201014 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b94:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b96:	00093b03          	ld	s6,0(s2)
ffffffffc0200b9a:	00893a83          	ld	s5,8(s2)
ffffffffc0200b9e:	00006797          	auipc	a5,0x6
ffffffffc0200ba2:	8b27b923          	sd	s2,-1870(a5) # ffffffffc0206450 <free_area>
ffffffffc0200ba6:	00006797          	auipc	a5,0x6
ffffffffc0200baa:	8b27b923          	sd	s2,-1870(a5) # ffffffffc0206458 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200bae:	7b4000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200bb2:	44051163          	bnez	a0,ffffffffc0200ff4 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200bb6:	4589                	li	a1,2
ffffffffc0200bb8:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200bbc:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200bc0:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200bc4:	00006797          	auipc	a5,0x6
ffffffffc0200bc8:	8807ae23          	sw	zero,-1892(a5) # ffffffffc0206460 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200bcc:	7da000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200bd0:	8562                	mv	a0,s8
ffffffffc0200bd2:	4585                	li	a1,1
ffffffffc0200bd4:	7d2000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200bd8:	4511                	li	a0,4
ffffffffc0200bda:	788000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200bde:	3e051b63          	bnez	a0,ffffffffc0200fd4 <best_fit_check+0x630>
ffffffffc0200be2:	0309b783          	ld	a5,48(s3)
ffffffffc0200be6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200be8:	8b85                	andi	a5,a5,1
ffffffffc0200bea:	3c078563          	beqz	a5,ffffffffc0200fb4 <best_fit_check+0x610>
ffffffffc0200bee:	0389a703          	lw	a4,56(s3)
ffffffffc0200bf2:	4789                	li	a5,2
ffffffffc0200bf4:	3cf71063          	bne	a4,a5,ffffffffc0200fb4 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	768000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200bfe:	8a2a                	mv	s4,a0
ffffffffc0200c00:	38050a63          	beqz	a0,ffffffffc0200f94 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200c04:	4509                	li	a0,2
ffffffffc0200c06:	75c000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200c0a:	36050563          	beqz	a0,ffffffffc0200f74 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200c0e:	354c1363          	bne	s8,s4,ffffffffc0200f54 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200c12:	854e                	mv	a0,s3
ffffffffc0200c14:	4595                	li	a1,5
ffffffffc0200c16:	790000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200c1a:	4515                	li	a0,5
ffffffffc0200c1c:	746000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200c20:	89aa                	mv	s3,a0
ffffffffc0200c22:	30050963          	beqz	a0,ffffffffc0200f34 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200c26:	4505                	li	a0,1
ffffffffc0200c28:	73a000ef          	jal	ra,ffffffffc0201362 <alloc_pages>
ffffffffc0200c2c:	2e051463          	bnez	a0,ffffffffc0200f14 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200c30:	01092783          	lw	a5,16(s2)
ffffffffc0200c34:	2c079063          	bnez	a5,ffffffffc0200ef4 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200c38:	4595                	li	a1,5
ffffffffc0200c3a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200c3c:	00006797          	auipc	a5,0x6
ffffffffc0200c40:	8377a223          	sw	s7,-2012(a5) # ffffffffc0206460 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200c44:	00006797          	auipc	a5,0x6
ffffffffc0200c48:	8167b623          	sd	s6,-2036(a5) # ffffffffc0206450 <free_area>
ffffffffc0200c4c:	00006797          	auipc	a5,0x6
ffffffffc0200c50:	8157b623          	sd	s5,-2036(a5) # ffffffffc0206458 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200c54:	752000ef          	jal	ra,ffffffffc02013a6 <free_pages>
    return listelm->next;
ffffffffc0200c58:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c5c:	01278963          	beq	a5,s2,ffffffffc0200c6e <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200c60:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c64:	679c                	ld	a5,8(a5)
ffffffffc0200c66:	34fd                	addiw	s1,s1,-1
ffffffffc0200c68:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c6a:	ff279be3          	bne	a5,s2,ffffffffc0200c60 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200c6e:	26049363          	bnez	s1,ffffffffc0200ed4 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200c72:	e06d                	bnez	s0,ffffffffc0200d54 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200c74:	60a6                	ld	ra,72(sp)
ffffffffc0200c76:	6406                	ld	s0,64(sp)
ffffffffc0200c78:	74e2                	ld	s1,56(sp)
ffffffffc0200c7a:	7942                	ld	s2,48(sp)
ffffffffc0200c7c:	79a2                	ld	s3,40(sp)
ffffffffc0200c7e:	7a02                	ld	s4,32(sp)
ffffffffc0200c80:	6ae2                	ld	s5,24(sp)
ffffffffc0200c82:	6b42                	ld	s6,16(sp)
ffffffffc0200c84:	6ba2                	ld	s7,8(sp)
ffffffffc0200c86:	6c02                	ld	s8,0(sp)
ffffffffc0200c88:	6161                	addi	sp,sp,80
ffffffffc0200c8a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c8c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c8e:	4401                	li	s0,0
ffffffffc0200c90:	4481                	li	s1,0
ffffffffc0200c92:	b395                	j	ffffffffc02009f6 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	6fc68693          	addi	a3,a3,1788 # ffffffffc0202390 <commands+0x6f8>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	6bc60613          	addi	a2,a2,1724 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200ca4:	10f00593          	li	a1,271
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	6c850513          	addi	a0,a0,1736 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200cb0:	ef8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	76c68693          	addi	a3,a3,1900 # ffffffffc0202420 <commands+0x788>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	69c60613          	addi	a2,a2,1692 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200cc4:	0db00593          	li	a1,219
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	6a850513          	addi	a0,a0,1704 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200cd0:	ed8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	77468693          	addi	a3,a3,1908 # ffffffffc0202448 <commands+0x7b0>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	67c60613          	addi	a2,a2,1660 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200ce4:	0dc00593          	li	a1,220
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	68850513          	addi	a0,a0,1672 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200cf0:	eb8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	79468693          	addi	a3,a3,1940 # ffffffffc0202488 <commands+0x7f0>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	65c60613          	addi	a2,a2,1628 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200d04:	0de00593          	li	a1,222
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	66850513          	addi	a0,a0,1640 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200d10:	e98ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	7fc68693          	addi	a3,a3,2044 # ffffffffc0202510 <commands+0x878>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	63c60613          	addi	a2,a2,1596 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200d24:	0f700593          	li	a1,247
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	64850513          	addi	a0,a0,1608 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200d30:	e78ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202400 <commands+0x768>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	61c60613          	addi	a2,a2,1564 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200d44:	0d900593          	li	a1,217
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	62850513          	addi	a0,a0,1576 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200d50:	e58ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(total == 0);
ffffffffc0200d54:	00002697          	auipc	a3,0x2
ffffffffc0200d58:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0202640 <commands+0x9a8>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	5fc60613          	addi	a2,a2,1532 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200d64:	15100593          	li	a1,337
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	60850513          	addi	a0,a0,1544 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200d70:	e38ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	62c68693          	addi	a3,a3,1580 # ffffffffc02023a0 <commands+0x708>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	5dc60613          	addi	a2,a2,1500 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200d84:	11200593          	li	a1,274
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	5e850513          	addi	a0,a0,1512 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200d90:	e18ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	64c68693          	addi	a3,a3,1612 # ffffffffc02023e0 <commands+0x748>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	5bc60613          	addi	a2,a2,1468 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200da4:	0d800593          	li	a1,216
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	5c850513          	addi	a0,a0,1480 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200db0:	df8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	60c68693          	addi	a3,a3,1548 # ffffffffc02023c0 <commands+0x728>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	59c60613          	addi	a2,a2,1436 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200dc4:	0d700593          	li	a1,215
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	5a850513          	addi	a0,a0,1448 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200dd0:	dd8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	71468693          	addi	a3,a3,1812 # ffffffffc02024e8 <commands+0x850>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	57c60613          	addi	a2,a2,1404 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200de4:	0f400593          	li	a1,244
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	58850513          	addi	a0,a0,1416 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200df0:	db8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	60c68693          	addi	a3,a3,1548 # ffffffffc0202400 <commands+0x768>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	55c60613          	addi	a2,a2,1372 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200e04:	0f200593          	li	a1,242
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	56850513          	addi	a0,a0,1384 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200e10:	d98ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	5cc68693          	addi	a3,a3,1484 # ffffffffc02023e0 <commands+0x748>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	53c60613          	addi	a2,a2,1340 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200e24:	0f100593          	li	a1,241
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	54850513          	addi	a0,a0,1352 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200e30:	d78ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	58c68693          	addi	a3,a3,1420 # ffffffffc02023c0 <commands+0x728>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	51c60613          	addi	a2,a2,1308 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200e44:	0f000593          	li	a1,240
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	52850513          	addi	a0,a0,1320 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200e50:	d58ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 3);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	6ac68693          	addi	a3,a3,1708 # ffffffffc0202500 <commands+0x868>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	4fc60613          	addi	a2,a2,1276 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200e64:	0ee00593          	li	a1,238
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	50850513          	addi	a0,a0,1288 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200e70:	d38ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	67468693          	addi	a3,a3,1652 # ffffffffc02024e8 <commands+0x850>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	4dc60613          	addi	a2,a2,1244 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200e84:	0e900593          	li	a1,233
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	4e850513          	addi	a0,a0,1256 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200e90:	d18ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	63468693          	addi	a3,a3,1588 # ffffffffc02024c8 <commands+0x830>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	4bc60613          	addi	a2,a2,1212 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200ea4:	0e000593          	li	a1,224
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	4c850513          	addi	a0,a0,1224 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200eb0:	cf8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	5f468693          	addi	a3,a3,1524 # ffffffffc02024a8 <commands+0x810>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	49c60613          	addi	a2,a2,1180 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200ec4:	0df00593          	li	a1,223
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	4a850513          	addi	a0,a0,1192 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200ed0:	cd8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(count == 0);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	75c68693          	addi	a3,a3,1884 # ffffffffc0202630 <commands+0x998>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	47c60613          	addi	a2,a2,1148 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200ee4:	15000593          	li	a1,336
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	48850513          	addi	a0,a0,1160 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200ef0:	cb8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	65468693          	addi	a3,a3,1620 # ffffffffc0202548 <commands+0x8b0>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	45c60613          	addi	a2,a2,1116 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200f04:	14500593          	li	a1,325
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	46850513          	addi	a0,a0,1128 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200f10:	c98ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	5d468693          	addi	a3,a3,1492 # ffffffffc02024e8 <commands+0x850>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	43c60613          	addi	a2,a2,1084 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200f24:	13f00593          	li	a1,319
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	44850513          	addi	a0,a0,1096 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200f30:	c78ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	6dc68693          	addi	a3,a3,1756 # ffffffffc0202610 <commands+0x978>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	41c60613          	addi	a2,a2,1052 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200f44:	13e00593          	li	a1,318
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	42850513          	addi	a0,a0,1064 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200f50:	c58ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	6ac68693          	addi	a3,a3,1708 # ffffffffc0202600 <commands+0x968>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	3fc60613          	addi	a2,a2,1020 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200f64:	13600593          	li	a1,310
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	40850513          	addi	a0,a0,1032 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200f70:	c38ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	67468693          	addi	a3,a3,1652 # ffffffffc02025e8 <commands+0x950>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	3dc60613          	addi	a2,a2,988 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200f84:	13500593          	li	a1,309
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	3e850513          	addi	a0,a0,1000 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200f90:	c18ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	63468693          	addi	a3,a3,1588 # ffffffffc02025c8 <commands+0x930>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	3bc60613          	addi	a2,a2,956 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200fa4:	13400593          	li	a1,308
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	3c850513          	addi	a0,a0,968 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200fb0:	bf8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	5e468693          	addi	a3,a3,1508 # ffffffffc0202598 <commands+0x900>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	39c60613          	addi	a2,a2,924 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200fc4:	13200593          	li	a1,306
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	3a850513          	addi	a0,a0,936 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200fd0:	bd8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202580 <commands+0x8e8>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	37c60613          	addi	a2,a2,892 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0200fe4:	13100593          	li	a1,305
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	38850513          	addi	a0,a0,904 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0200ff0:	bb8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	4f468693          	addi	a3,a3,1268 # ffffffffc02024e8 <commands+0x850>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	35c60613          	addi	a2,a2,860 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201004:	12500593          	li	a1,293
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	36850513          	addi	a0,a0,872 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201010:	b98ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	55468693          	addi	a3,a3,1364 # ffffffffc0202568 <commands+0x8d0>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	33c60613          	addi	a2,a2,828 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201024:	11c00593          	li	a1,284
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	34850513          	addi	a0,a0,840 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201030:	b78ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 != NULL);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	52468693          	addi	a3,a3,1316 # ffffffffc0202558 <commands+0x8c0>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	31c60613          	addi	a2,a2,796 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201044:	11b00593          	li	a1,283
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	32850513          	addi	a0,a0,808 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201050:	b58ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc0201054:	00001697          	auipc	a3,0x1
ffffffffc0201058:	4f468693          	addi	a3,a3,1268 # ffffffffc0202548 <commands+0x8b0>
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	2fc60613          	addi	a2,a2,764 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201064:	0fd00593          	li	a1,253
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	30850513          	addi	a0,a0,776 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201070:	b38ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201074:	00001697          	auipc	a3,0x1
ffffffffc0201078:	47468693          	addi	a3,a3,1140 # ffffffffc02024e8 <commands+0x850>
ffffffffc020107c:	00001617          	auipc	a2,0x1
ffffffffc0201080:	2dc60613          	addi	a2,a2,732 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201084:	0fb00593          	li	a1,251
ffffffffc0201088:	00001517          	auipc	a0,0x1
ffffffffc020108c:	2e850513          	addi	a0,a0,744 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201090:	b18ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201094:	00001697          	auipc	a3,0x1
ffffffffc0201098:	49468693          	addi	a3,a3,1172 # ffffffffc0202528 <commands+0x890>
ffffffffc020109c:	00001617          	auipc	a2,0x1
ffffffffc02010a0:	2bc60613          	addi	a2,a2,700 # ffffffffc0202358 <commands+0x6c0>
ffffffffc02010a4:	0fa00593          	li	a1,250
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	2c850513          	addi	a0,a0,712 # ffffffffc0202370 <commands+0x6d8>
ffffffffc02010b0:	af8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02010b4 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02010b4:	1141                	addi	sp,sp,-16
ffffffffc02010b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010b8:	18058063          	beqz	a1,ffffffffc0201238 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02010bc:	00259693          	slli	a3,a1,0x2
ffffffffc02010c0:	96ae                	add	a3,a3,a1
ffffffffc02010c2:	068e                	slli	a3,a3,0x3
ffffffffc02010c4:	96aa                	add	a3,a3,a0
ffffffffc02010c6:	02d50d63          	beq	a0,a3,ffffffffc0201100 <best_fit_free_pages+0x4c>
ffffffffc02010ca:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010cc:	8b85                	andi	a5,a5,1
ffffffffc02010ce:	14079563          	bnez	a5,ffffffffc0201218 <best_fit_free_pages+0x164>
ffffffffc02010d2:	651c                	ld	a5,8(a0)
ffffffffc02010d4:	8385                	srli	a5,a5,0x1
ffffffffc02010d6:	8b85                	andi	a5,a5,1
ffffffffc02010d8:	14079063          	bnez	a5,ffffffffc0201218 <best_fit_free_pages+0x164>
ffffffffc02010dc:	87aa                	mv	a5,a0
ffffffffc02010de:	a809                	j	ffffffffc02010f0 <best_fit_free_pages+0x3c>
ffffffffc02010e0:	6798                	ld	a4,8(a5)
ffffffffc02010e2:	8b05                	andi	a4,a4,1
ffffffffc02010e4:	12071a63          	bnez	a4,ffffffffc0201218 <best_fit_free_pages+0x164>
ffffffffc02010e8:	6798                	ld	a4,8(a5)
ffffffffc02010ea:	8b09                	andi	a4,a4,2
ffffffffc02010ec:	12071663          	bnez	a4,ffffffffc0201218 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc02010f0:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02010f4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02010f8:	02878793          	addi	a5,a5,40
ffffffffc02010fc:	fed792e3          	bne	a5,a3,ffffffffc02010e0 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201100:	2581                	sext.w	a1,a1
ffffffffc0201102:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201104:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201108:	4789                	li	a5,2
ffffffffc020110a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020110e:	00005697          	auipc	a3,0x5
ffffffffc0201112:	34268693          	addi	a3,a3,834 # ffffffffc0206450 <free_area>
ffffffffc0201116:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201118:	669c                	ld	a5,8(a3)
ffffffffc020111a:	9db9                	addw	a1,a1,a4
ffffffffc020111c:	00005717          	auipc	a4,0x5
ffffffffc0201120:	34b72223          	sw	a1,836(a4) # ffffffffc0206460 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201124:	08d78f63          	beq	a5,a3,ffffffffc02011c2 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201128:	fe878713          	addi	a4,a5,-24
ffffffffc020112c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020112e:	4801                	li	a6,0
ffffffffc0201130:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201134:	00e56a63          	bltu	a0,a4,ffffffffc0201148 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201138:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020113a:	02d70563          	beq	a4,a3,ffffffffc0201164 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020113e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201140:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201144:	fee57ae3          	bgeu	a0,a4,ffffffffc0201138 <best_fit_free_pages+0x84>
ffffffffc0201148:	00080663          	beqz	a6,ffffffffc0201154 <best_fit_free_pages+0xa0>
ffffffffc020114c:	00005817          	auipc	a6,0x5
ffffffffc0201150:	30b83223          	sd	a1,772(a6) # ffffffffc0206450 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201154:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201156:	e390                	sd	a2,0(a5)
ffffffffc0201158:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020115a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020115c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020115e:	02d59163          	bne	a1,a3,ffffffffc0201180 <best_fit_free_pages+0xcc>
ffffffffc0201162:	a091                	j	ffffffffc02011a6 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201164:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201166:	f114                	sd	a3,32(a0)
ffffffffc0201168:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020116a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020116c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020116e:	00d70563          	beq	a4,a3,ffffffffc0201178 <best_fit_free_pages+0xc4>
ffffffffc0201172:	4805                	li	a6,1
ffffffffc0201174:	87ba                	mv	a5,a4
ffffffffc0201176:	b7e9                	j	ffffffffc0201140 <best_fit_free_pages+0x8c>
ffffffffc0201178:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020117a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020117c:	02d78163          	beq	a5,a3,ffffffffc020119e <best_fit_free_pages+0xea>
        if (p + p->property == base)
ffffffffc0201180:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201184:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base)
ffffffffc0201188:	02081713          	slli	a4,a6,0x20
ffffffffc020118c:	9301                	srli	a4,a4,0x20
ffffffffc020118e:	00271793          	slli	a5,a4,0x2
ffffffffc0201192:	97ba                	add	a5,a5,a4
ffffffffc0201194:	078e                	slli	a5,a5,0x3
ffffffffc0201196:	97b2                	add	a5,a5,a2
ffffffffc0201198:	02f50e63          	beq	a0,a5,ffffffffc02011d4 <best_fit_free_pages+0x120>
ffffffffc020119c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020119e:	fe878713          	addi	a4,a5,-24
ffffffffc02011a2:	00d78d63          	beq	a5,a3,ffffffffc02011bc <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02011a6:	490c                	lw	a1,16(a0)
ffffffffc02011a8:	02059613          	slli	a2,a1,0x20
ffffffffc02011ac:	9201                	srli	a2,a2,0x20
ffffffffc02011ae:	00261693          	slli	a3,a2,0x2
ffffffffc02011b2:	96b2                	add	a3,a3,a2
ffffffffc02011b4:	068e                	slli	a3,a3,0x3
ffffffffc02011b6:	96aa                	add	a3,a3,a0
ffffffffc02011b8:	04d70063          	beq	a4,a3,ffffffffc02011f8 <best_fit_free_pages+0x144>
}
ffffffffc02011bc:	60a2                	ld	ra,8(sp)
ffffffffc02011be:	0141                	addi	sp,sp,16
ffffffffc02011c0:	8082                	ret
ffffffffc02011c2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02011c4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02011c8:	e398                	sd	a4,0(a5)
ffffffffc02011ca:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02011cc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011ce:	ed1c                	sd	a5,24(a0)
}
ffffffffc02011d0:	0141                	addi	sp,sp,16
ffffffffc02011d2:	8082                	ret
            p->property += base->property;
ffffffffc02011d4:	491c                	lw	a5,16(a0)
ffffffffc02011d6:	0107883b          	addw	a6,a5,a6
ffffffffc02011da:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011de:	57f5                	li	a5,-3
ffffffffc02011e0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011e4:	01853803          	ld	a6,24(a0)
ffffffffc02011e8:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02011ea:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02011ec:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02011f0:	659c                	ld	a5,8(a1)
ffffffffc02011f2:	01073023          	sd	a6,0(a4)
ffffffffc02011f6:	b765                	j	ffffffffc020119e <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc02011f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011fc:	ff078693          	addi	a3,a5,-16
ffffffffc0201200:	9db9                	addw	a1,a1,a4
ffffffffc0201202:	c90c                	sw	a1,16(a0)
ffffffffc0201204:	5775                	li	a4,-3
ffffffffc0201206:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020120a:	6398                	ld	a4,0(a5)
ffffffffc020120c:	679c                	ld	a5,8(a5)
}
ffffffffc020120e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201210:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201212:	e398                	sd	a4,0(a5)
ffffffffc0201214:	0141                	addi	sp,sp,16
ffffffffc0201216:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201218:	00001697          	auipc	a3,0x1
ffffffffc020121c:	43868693          	addi	a3,a3,1080 # ffffffffc0202650 <commands+0x9b8>
ffffffffc0201220:	00001617          	auipc	a2,0x1
ffffffffc0201224:	13860613          	addi	a2,a2,312 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201228:	09600593          	li	a1,150
ffffffffc020122c:	00001517          	auipc	a0,0x1
ffffffffc0201230:	14450513          	addi	a0,a0,324 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201234:	974ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0201238:	00001697          	auipc	a3,0x1
ffffffffc020123c:	11868693          	addi	a3,a3,280 # ffffffffc0202350 <commands+0x6b8>
ffffffffc0201240:	00001617          	auipc	a2,0x1
ffffffffc0201244:	11860613          	addi	a2,a2,280 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201248:	09300593          	li	a1,147
ffffffffc020124c:	00001517          	auipc	a0,0x1
ffffffffc0201250:	12450513          	addi	a0,a0,292 # ffffffffc0202370 <commands+0x6d8>
ffffffffc0201254:	954ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201258 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201258:	1141                	addi	sp,sp,-16
ffffffffc020125a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020125c:	c1fd                	beqz	a1,ffffffffc0201342 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020125e:	00259693          	slli	a3,a1,0x2
ffffffffc0201262:	96ae                	add	a3,a3,a1
ffffffffc0201264:	068e                	slli	a3,a3,0x3
ffffffffc0201266:	96aa                	add	a3,a3,a0
ffffffffc0201268:	02d50463          	beq	a0,a3,ffffffffc0201290 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020126c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020126e:	87aa                	mv	a5,a0
ffffffffc0201270:	8b05                	andi	a4,a4,1
ffffffffc0201272:	e709                	bnez	a4,ffffffffc020127c <best_fit_init_memmap+0x24>
ffffffffc0201274:	a07d                	j	ffffffffc0201322 <best_fit_init_memmap+0xca>
ffffffffc0201276:	6798                	ld	a4,8(a5)
ffffffffc0201278:	8b05                	andi	a4,a4,1
ffffffffc020127a:	c745                	beqz	a4,ffffffffc0201322 <best_fit_init_memmap+0xca>
        p->flags = 0;
ffffffffc020127c:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201280:	0007a823          	sw	zero,16(a5)
ffffffffc0201284:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201288:	02878793          	addi	a5,a5,40
ffffffffc020128c:	fed795e3          	bne	a5,a3,ffffffffc0201276 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201290:	2581                	sext.w	a1,a1
ffffffffc0201292:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201294:	4789                	li	a5,2
ffffffffc0201296:	00850713          	addi	a4,a0,8
ffffffffc020129a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020129e:	00005697          	auipc	a3,0x5
ffffffffc02012a2:	1b268693          	addi	a3,a3,434 # ffffffffc0206450 <free_area>
ffffffffc02012a6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012a8:	669c                	ld	a5,8(a3)
ffffffffc02012aa:	9db9                	addw	a1,a1,a4
ffffffffc02012ac:	00005717          	auipc	a4,0x5
ffffffffc02012b0:	1ab72a23          	sw	a1,436(a4) # ffffffffc0206460 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02012b4:	04d78a63          	beq	a5,a3,ffffffffc0201308 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02012b8:	fe878713          	addi	a4,a5,-24
ffffffffc02012bc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012be:	4801                	li	a6,0
ffffffffc02012c0:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02012c4:	00e56a63          	bltu	a0,a4,ffffffffc02012d8 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc02012c8:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02012ca:	02d70563          	beq	a4,a3,ffffffffc02012f4 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012ce:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012d0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02012d4:	fee57ae3          	bgeu	a0,a4,ffffffffc02012c8 <best_fit_init_memmap+0x70>
ffffffffc02012d8:	00080663          	beqz	a6,ffffffffc02012e4 <best_fit_init_memmap+0x8c>
ffffffffc02012dc:	00005717          	auipc	a4,0x5
ffffffffc02012e0:	16b73a23          	sd	a1,372(a4) # ffffffffc0206450 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e4:	6398                	ld	a4,0(a5)
}
ffffffffc02012e6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02012e8:	e390                	sd	a2,0(a5)
ffffffffc02012ea:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012ec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012ee:	ed18                	sd	a4,24(a0)
ffffffffc02012f0:	0141                	addi	sp,sp,16
ffffffffc02012f2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02012f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02012f6:	f114                	sd	a3,32(a0)
ffffffffc02012f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02012fa:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02012fc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012fe:	00d70e63          	beq	a4,a3,ffffffffc020131a <best_fit_init_memmap+0xc2>
ffffffffc0201302:	4805                	li	a6,1
ffffffffc0201304:	87ba                	mv	a5,a4
ffffffffc0201306:	b7e9                	j	ffffffffc02012d0 <best_fit_init_memmap+0x78>
}
ffffffffc0201308:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020130a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020130e:	e398                	sd	a4,0(a5)
ffffffffc0201310:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201312:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201314:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201316:	0141                	addi	sp,sp,16
ffffffffc0201318:	8082                	ret
ffffffffc020131a:	60a2                	ld	ra,8(sp)
ffffffffc020131c:	e290                	sd	a2,0(a3)
ffffffffc020131e:	0141                	addi	sp,sp,16
ffffffffc0201320:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201322:	00001697          	auipc	a3,0x1
ffffffffc0201326:	35668693          	addi	a3,a3,854 # ffffffffc0202678 <commands+0x9e0>
ffffffffc020132a:	00001617          	auipc	a2,0x1
ffffffffc020132e:	02e60613          	addi	a2,a2,46 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201332:	04a00593          	li	a1,74
ffffffffc0201336:	00001517          	auipc	a0,0x1
ffffffffc020133a:	03a50513          	addi	a0,a0,58 # ffffffffc0202370 <commands+0x6d8>
ffffffffc020133e:	86aff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0201342:	00001697          	auipc	a3,0x1
ffffffffc0201346:	00e68693          	addi	a3,a3,14 # ffffffffc0202350 <commands+0x6b8>
ffffffffc020134a:	00001617          	auipc	a2,0x1
ffffffffc020134e:	00e60613          	addi	a2,a2,14 # ffffffffc0202358 <commands+0x6c0>
ffffffffc0201352:	04700593          	li	a1,71
ffffffffc0201356:	00001517          	auipc	a0,0x1
ffffffffc020135a:	01a50513          	addi	a0,a0,26 # ffffffffc0202370 <commands+0x6d8>
ffffffffc020135e:	84aff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201362 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201362:	100027f3          	csrr	a5,sstatus
ffffffffc0201366:	8b89                	andi	a5,a5,2
ffffffffc0201368:	eb89                	bnez	a5,ffffffffc020137a <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020136a:	00005797          	auipc	a5,0x5
ffffffffc020136e:	1f678793          	addi	a5,a5,502 # ffffffffc0206560 <pmm_manager>
ffffffffc0201372:	639c                	ld	a5,0(a5)
ffffffffc0201374:	0187b303          	ld	t1,24(a5)
ffffffffc0201378:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc020137a:	1141                	addi	sp,sp,-16
ffffffffc020137c:	e406                	sd	ra,8(sp)
ffffffffc020137e:	e022                	sd	s0,0(sp)
ffffffffc0201380:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201382:	8dcff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201386:	00005797          	auipc	a5,0x5
ffffffffc020138a:	1da78793          	addi	a5,a5,474 # ffffffffc0206560 <pmm_manager>
ffffffffc020138e:	639c                	ld	a5,0(a5)
ffffffffc0201390:	8522                	mv	a0,s0
ffffffffc0201392:	6f9c                	ld	a5,24(a5)
ffffffffc0201394:	9782                	jalr	a5
ffffffffc0201396:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201398:	8c0ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020139c:	8522                	mv	a0,s0
ffffffffc020139e:	60a2                	ld	ra,8(sp)
ffffffffc02013a0:	6402                	ld	s0,0(sp)
ffffffffc02013a2:	0141                	addi	sp,sp,16
ffffffffc02013a4:	8082                	ret

ffffffffc02013a6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013a6:	100027f3          	csrr	a5,sstatus
ffffffffc02013aa:	8b89                	andi	a5,a5,2
ffffffffc02013ac:	eb89                	bnez	a5,ffffffffc02013be <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02013ae:	00005797          	auipc	a5,0x5
ffffffffc02013b2:	1b278793          	addi	a5,a5,434 # ffffffffc0206560 <pmm_manager>
ffffffffc02013b6:	639c                	ld	a5,0(a5)
ffffffffc02013b8:	0207b303          	ld	t1,32(a5)
ffffffffc02013bc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02013be:	1101                	addi	sp,sp,-32
ffffffffc02013c0:	ec06                	sd	ra,24(sp)
ffffffffc02013c2:	e822                	sd	s0,16(sp)
ffffffffc02013c4:	e426                	sd	s1,8(sp)
ffffffffc02013c6:	842a                	mv	s0,a0
ffffffffc02013c8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02013ca:	894ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02013ce:	00005797          	auipc	a5,0x5
ffffffffc02013d2:	19278793          	addi	a5,a5,402 # ffffffffc0206560 <pmm_manager>
ffffffffc02013d6:	639c                	ld	a5,0(a5)
ffffffffc02013d8:	85a6                	mv	a1,s1
ffffffffc02013da:	8522                	mv	a0,s0
ffffffffc02013dc:	739c                	ld	a5,32(a5)
ffffffffc02013de:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02013e0:	6442                	ld	s0,16(sp)
ffffffffc02013e2:	60e2                	ld	ra,24(sp)
ffffffffc02013e4:	64a2                	ld	s1,8(sp)
ffffffffc02013e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02013e8:	870ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02013ec <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013ec:	100027f3          	csrr	a5,sstatus
ffffffffc02013f0:	8b89                	andi	a5,a5,2
ffffffffc02013f2:	eb89                	bnez	a5,ffffffffc0201404 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02013f4:	00005797          	auipc	a5,0x5
ffffffffc02013f8:	16c78793          	addi	a5,a5,364 # ffffffffc0206560 <pmm_manager>
ffffffffc02013fc:	639c                	ld	a5,0(a5)
ffffffffc02013fe:	0287b303          	ld	t1,40(a5)
ffffffffc0201402:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201404:	1141                	addi	sp,sp,-16
ffffffffc0201406:	e406                	sd	ra,8(sp)
ffffffffc0201408:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020140a:	854ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020140e:	00005797          	auipc	a5,0x5
ffffffffc0201412:	15278793          	addi	a5,a5,338 # ffffffffc0206560 <pmm_manager>
ffffffffc0201416:	639c                	ld	a5,0(a5)
ffffffffc0201418:	779c                	ld	a5,40(a5)
ffffffffc020141a:	9782                	jalr	a5
ffffffffc020141c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020141e:	83aff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201422:	8522                	mv	a0,s0
ffffffffc0201424:	60a2                	ld	ra,8(sp)
ffffffffc0201426:	6402                	ld	s0,0(sp)
ffffffffc0201428:	0141                	addi	sp,sp,16
ffffffffc020142a:	8082                	ret

ffffffffc020142c <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020142c:	00001797          	auipc	a5,0x1
ffffffffc0201430:	25c78793          	addi	a5,a5,604 # ffffffffc0202688 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201434:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201436:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	2a050513          	addi	a0,a0,672 # ffffffffc02026d8 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201440:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201442:	00005717          	auipc	a4,0x5
ffffffffc0201446:	10f73f23          	sd	a5,286(a4) # ffffffffc0206560 <pmm_manager>
void pmm_init(void) {
ffffffffc020144a:	e822                	sd	s0,16(sp)
ffffffffc020144c:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020144e:	00005417          	auipc	s0,0x5
ffffffffc0201452:	11240413          	addi	s0,s0,274 # ffffffffc0206560 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201456:	c61fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020145a:	601c                	ld	a5,0(s0)
ffffffffc020145c:	679c                	ld	a5,8(a5)
ffffffffc020145e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201460:	57f5                	li	a5,-3
ffffffffc0201462:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201464:	00001517          	auipc	a0,0x1
ffffffffc0201468:	28c50513          	addi	a0,a0,652 # ffffffffc02026f0 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020146c:	00005717          	auipc	a4,0x5
ffffffffc0201470:	0ef73e23          	sd	a5,252(a4) # ffffffffc0206568 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201474:	c43fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201478:	46c5                	li	a3,17
ffffffffc020147a:	06ee                	slli	a3,a3,0x1b
ffffffffc020147c:	40100613          	li	a2,1025
ffffffffc0201480:	16fd                	addi	a3,a3,-1
ffffffffc0201482:	0656                	slli	a2,a2,0x15
ffffffffc0201484:	07e005b7          	lui	a1,0x7e00
ffffffffc0201488:	00001517          	auipc	a0,0x1
ffffffffc020148c:	28050513          	addi	a0,a0,640 # ffffffffc0202708 <best_fit_pmm_manager+0x80>
ffffffffc0201490:	c27fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201494:	777d                	lui	a4,0xfffff
ffffffffc0201496:	00006797          	auipc	a5,0x6
ffffffffc020149a:	0e178793          	addi	a5,a5,225 # ffffffffc0207577 <end+0xfff>
ffffffffc020149e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02014a0:	00088737          	lui	a4,0x88
ffffffffc02014a4:	00005697          	auipc	a3,0x5
ffffffffc02014a8:	f8e6b623          	sd	a4,-116(a3) # ffffffffc0206430 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014ac:	4601                	li	a2,0
ffffffffc02014ae:	00005717          	auipc	a4,0x5
ffffffffc02014b2:	0cf73123          	sd	a5,194(a4) # ffffffffc0206570 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014b6:	4681                	li	a3,0
ffffffffc02014b8:	00005897          	auipc	a7,0x5
ffffffffc02014bc:	f7888893          	addi	a7,a7,-136 # ffffffffc0206430 <npage>
ffffffffc02014c0:	00005597          	auipc	a1,0x5
ffffffffc02014c4:	0b058593          	addi	a1,a1,176 # ffffffffc0206570 <pages>
ffffffffc02014c8:	4805                	li	a6,1
ffffffffc02014ca:	fff80537          	lui	a0,0xfff80
ffffffffc02014ce:	a011                	j	ffffffffc02014d2 <pmm_init+0xa6>
ffffffffc02014d0:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02014d2:	97b2                	add	a5,a5,a2
ffffffffc02014d4:	07a1                	addi	a5,a5,8
ffffffffc02014d6:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014da:	0008b703          	ld	a4,0(a7)
ffffffffc02014de:	0685                	addi	a3,a3,1
ffffffffc02014e0:	02860613          	addi	a2,a2,40
ffffffffc02014e4:	00a707b3          	add	a5,a4,a0
ffffffffc02014e8:	fef6e4e3          	bltu	a3,a5,ffffffffc02014d0 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014ec:	6190                	ld	a2,0(a1)
ffffffffc02014ee:	00271793          	slli	a5,a4,0x2
ffffffffc02014f2:	97ba                	add	a5,a5,a4
ffffffffc02014f4:	fec006b7          	lui	a3,0xfec00
ffffffffc02014f8:	078e                	slli	a5,a5,0x3
ffffffffc02014fa:	96b2                	add	a3,a3,a2
ffffffffc02014fc:	96be                	add	a3,a3,a5
ffffffffc02014fe:	c02007b7          	lui	a5,0xc0200
ffffffffc0201502:	08f6e863          	bltu	a3,a5,ffffffffc0201592 <pmm_init+0x166>
ffffffffc0201506:	00005497          	auipc	s1,0x5
ffffffffc020150a:	06248493          	addi	s1,s1,98 # ffffffffc0206568 <va_pa_offset>
ffffffffc020150e:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201510:	45c5                	li	a1,17
ffffffffc0201512:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201514:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201516:	04b6e963          	bltu	a3,a1,ffffffffc0201568 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020151a:	601c                	ld	a5,0(s0)
ffffffffc020151c:	7b9c                	ld	a5,48(a5)
ffffffffc020151e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201520:	00001517          	auipc	a0,0x1
ffffffffc0201524:	28050513          	addi	a0,a0,640 # ffffffffc02027a0 <best_fit_pmm_manager+0x118>
ffffffffc0201528:	b8ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020152c:	00004697          	auipc	a3,0x4
ffffffffc0201530:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201534:	00005797          	auipc	a5,0x5
ffffffffc0201538:	f0d7b223          	sd	a3,-252(a5) # ffffffffc0206438 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020153c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201540:	06f6e563          	bltu	a3,a5,ffffffffc02015aa <pmm_init+0x17e>
ffffffffc0201544:	609c                	ld	a5,0(s1)
}
ffffffffc0201546:	6442                	ld	s0,16(sp)
ffffffffc0201548:	60e2                	ld	ra,24(sp)
ffffffffc020154a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020154c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020154e:	8e9d                	sub	a3,a3,a5
ffffffffc0201550:	00005797          	auipc	a5,0x5
ffffffffc0201554:	00d7b423          	sd	a3,8(a5) # ffffffffc0206558 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201558:	00001517          	auipc	a0,0x1
ffffffffc020155c:	26850513          	addi	a0,a0,616 # ffffffffc02027c0 <best_fit_pmm_manager+0x138>
ffffffffc0201560:	8636                	mv	a2,a3
}
ffffffffc0201562:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201564:	b53fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201568:	6785                	lui	a5,0x1
ffffffffc020156a:	17fd                	addi	a5,a5,-1
ffffffffc020156c:	96be                	add	a3,a3,a5
ffffffffc020156e:	77fd                	lui	a5,0xfffff
ffffffffc0201570:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201572:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201576:	04e7f663          	bgeu	a5,a4,ffffffffc02015c2 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc020157a:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020157c:	97aa                	add	a5,a5,a0
ffffffffc020157e:	00279513          	slli	a0,a5,0x2
ffffffffc0201582:	953e                	add	a0,a0,a5
ffffffffc0201584:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201586:	8d95                	sub	a1,a1,a3
ffffffffc0201588:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020158a:	81b1                	srli	a1,a1,0xc
ffffffffc020158c:	9532                	add	a0,a0,a2
ffffffffc020158e:	9782                	jalr	a5
ffffffffc0201590:	b769                	j	ffffffffc020151a <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201592:	00001617          	auipc	a2,0x1
ffffffffc0201596:	1a660613          	addi	a2,a2,422 # ffffffffc0202738 <best_fit_pmm_manager+0xb0>
ffffffffc020159a:	07100593          	li	a1,113
ffffffffc020159e:	00001517          	auipc	a0,0x1
ffffffffc02015a2:	1c250513          	addi	a0,a0,450 # ffffffffc0202760 <best_fit_pmm_manager+0xd8>
ffffffffc02015a6:	e03fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015aa:	00001617          	auipc	a2,0x1
ffffffffc02015ae:	18e60613          	addi	a2,a2,398 # ffffffffc0202738 <best_fit_pmm_manager+0xb0>
ffffffffc02015b2:	08c00593          	li	a1,140
ffffffffc02015b6:	00001517          	auipc	a0,0x1
ffffffffc02015ba:	1aa50513          	addi	a0,a0,426 # ffffffffc0202760 <best_fit_pmm_manager+0xd8>
ffffffffc02015be:	debfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02015c2:	00001617          	auipc	a2,0x1
ffffffffc02015c6:	1ae60613          	addi	a2,a2,430 # ffffffffc0202770 <best_fit_pmm_manager+0xe8>
ffffffffc02015ca:	06b00593          	li	a1,107
ffffffffc02015ce:	00001517          	auipc	a0,0x1
ffffffffc02015d2:	1c250513          	addi	a0,a0,450 # ffffffffc0202790 <best_fit_pmm_manager+0x108>
ffffffffc02015d6:	dd3fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02015da <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02015da:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015de:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02015e0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015e4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02015e6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015ea:	f022                	sd	s0,32(sp)
ffffffffc02015ec:	ec26                	sd	s1,24(sp)
ffffffffc02015ee:	e84a                	sd	s2,16(sp)
ffffffffc02015f0:	f406                	sd	ra,40(sp)
ffffffffc02015f2:	e44e                	sd	s3,8(sp)
ffffffffc02015f4:	84aa                	mv	s1,a0
ffffffffc02015f6:	892e                	mv	s2,a1
ffffffffc02015f8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015fc:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02015fe:	03067e63          	bgeu	a2,a6,ffffffffc020163a <printnum+0x60>
ffffffffc0201602:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201604:	00805763          	blez	s0,ffffffffc0201612 <printnum+0x38>
ffffffffc0201608:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020160a:	85ca                	mv	a1,s2
ffffffffc020160c:	854e                	mv	a0,s3
ffffffffc020160e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201610:	fc65                	bnez	s0,ffffffffc0201608 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201612:	1a02                	slli	s4,s4,0x20
ffffffffc0201614:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201618:	00001797          	auipc	a5,0x1
ffffffffc020161c:	37878793          	addi	a5,a5,888 # ffffffffc0202990 <error_string+0x38>
ffffffffc0201620:	9a3e                	add	s4,s4,a5
}
ffffffffc0201622:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201624:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201628:	70a2                	ld	ra,40(sp)
ffffffffc020162a:	69a2                	ld	s3,8(sp)
ffffffffc020162c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020162e:	85ca                	mv	a1,s2
ffffffffc0201630:	8326                	mv	t1,s1
}
ffffffffc0201632:	6942                	ld	s2,16(sp)
ffffffffc0201634:	64e2                	ld	s1,24(sp)
ffffffffc0201636:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201638:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020163a:	03065633          	divu	a2,a2,a6
ffffffffc020163e:	8722                	mv	a4,s0
ffffffffc0201640:	f9bff0ef          	jal	ra,ffffffffc02015da <printnum>
ffffffffc0201644:	b7f9                	j	ffffffffc0201612 <printnum+0x38>

ffffffffc0201646 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201646:	7119                	addi	sp,sp,-128
ffffffffc0201648:	f4a6                	sd	s1,104(sp)
ffffffffc020164a:	f0ca                	sd	s2,96(sp)
ffffffffc020164c:	e8d2                	sd	s4,80(sp)
ffffffffc020164e:	e4d6                	sd	s5,72(sp)
ffffffffc0201650:	e0da                	sd	s6,64(sp)
ffffffffc0201652:	fc5e                	sd	s7,56(sp)
ffffffffc0201654:	f862                	sd	s8,48(sp)
ffffffffc0201656:	f06a                	sd	s10,32(sp)
ffffffffc0201658:	fc86                	sd	ra,120(sp)
ffffffffc020165a:	f8a2                	sd	s0,112(sp)
ffffffffc020165c:	ecce                	sd	s3,88(sp)
ffffffffc020165e:	f466                	sd	s9,40(sp)
ffffffffc0201660:	ec6e                	sd	s11,24(sp)
ffffffffc0201662:	892a                	mv	s2,a0
ffffffffc0201664:	84ae                	mv	s1,a1
ffffffffc0201666:	8d32                	mv	s10,a2
ffffffffc0201668:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020166a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020166c:	00001a17          	auipc	s4,0x1
ffffffffc0201670:	194a0a13          	addi	s4,s4,404 # ffffffffc0202800 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201674:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201678:	00001c17          	auipc	s8,0x1
ffffffffc020167c:	2e0c0c13          	addi	s8,s8,736 # ffffffffc0202958 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201680:	000d4503          	lbu	a0,0(s10)
ffffffffc0201684:	02500793          	li	a5,37
ffffffffc0201688:	001d0413          	addi	s0,s10,1
ffffffffc020168c:	00f50e63          	beq	a0,a5,ffffffffc02016a8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201690:	c521                	beqz	a0,ffffffffc02016d8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201692:	02500993          	li	s3,37
ffffffffc0201696:	a011                	j	ffffffffc020169a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201698:	c121                	beqz	a0,ffffffffc02016d8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020169a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020169c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020169e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016a0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02016a4:	ff351ae3          	bne	a0,s3,ffffffffc0201698 <vprintfmt+0x52>
ffffffffc02016a8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02016ac:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016b0:	4981                	li	s3,0
ffffffffc02016b2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02016b4:	5cfd                	li	s9,-1
ffffffffc02016b6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02016bc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016be:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02016c2:	0ff6f693          	andi	a3,a3,255
ffffffffc02016c6:	00140d13          	addi	s10,s0,1
ffffffffc02016ca:	1ed5ef63          	bltu	a1,a3,ffffffffc02018c8 <vprintfmt+0x282>
ffffffffc02016ce:	068a                	slli	a3,a3,0x2
ffffffffc02016d0:	96d2                	add	a3,a3,s4
ffffffffc02016d2:	4294                	lw	a3,0(a3)
ffffffffc02016d4:	96d2                	add	a3,a3,s4
ffffffffc02016d6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02016d8:	70e6                	ld	ra,120(sp)
ffffffffc02016da:	7446                	ld	s0,112(sp)
ffffffffc02016dc:	74a6                	ld	s1,104(sp)
ffffffffc02016de:	7906                	ld	s2,96(sp)
ffffffffc02016e0:	69e6                	ld	s3,88(sp)
ffffffffc02016e2:	6a46                	ld	s4,80(sp)
ffffffffc02016e4:	6aa6                	ld	s5,72(sp)
ffffffffc02016e6:	6b06                	ld	s6,64(sp)
ffffffffc02016e8:	7be2                	ld	s7,56(sp)
ffffffffc02016ea:	7c42                	ld	s8,48(sp)
ffffffffc02016ec:	7ca2                	ld	s9,40(sp)
ffffffffc02016ee:	7d02                	ld	s10,32(sp)
ffffffffc02016f0:	6de2                	ld	s11,24(sp)
ffffffffc02016f2:	6109                	addi	sp,sp,128
ffffffffc02016f4:	8082                	ret
            padc = '-';
ffffffffc02016f6:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	00144603          	lbu	a2,1(s0)
ffffffffc02016fc:	846a                	mv	s0,s10
ffffffffc02016fe:	b7c1                	j	ffffffffc02016be <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0201700:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201704:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201708:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020170a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020170c:	fa0dd9e3          	bgez	s11,ffffffffc02016be <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201710:	8de6                	mv	s11,s9
ffffffffc0201712:	5cfd                	li	s9,-1
ffffffffc0201714:	b76d                	j	ffffffffc02016be <vprintfmt+0x78>
            if (width < 0)
ffffffffc0201716:	fffdc693          	not	a3,s11
ffffffffc020171a:	96fd                	srai	a3,a3,0x3f
ffffffffc020171c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201720:	00144603          	lbu	a2,1(s0)
ffffffffc0201724:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201726:	846a                	mv	s0,s10
ffffffffc0201728:	bf59                	j	ffffffffc02016be <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020172a:	4705                	li	a4,1
ffffffffc020172c:	008a8593          	addi	a1,s5,8
ffffffffc0201730:	01074463          	blt	a4,a6,ffffffffc0201738 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0201734:	22080863          	beqz	a6,ffffffffc0201964 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0201738:	000ab603          	ld	a2,0(s5)
ffffffffc020173c:	46c1                	li	a3,16
ffffffffc020173e:	8aae                	mv	s5,a1
ffffffffc0201740:	a291                	j	ffffffffc0201884 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0201742:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201746:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020174a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020174c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201750:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201754:	fad56ce3          	bltu	a0,a3,ffffffffc020170c <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201758:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020175a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020175e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201762:	0196873b          	addw	a4,a3,s9
ffffffffc0201766:	0017171b          	slliw	a4,a4,0x1
ffffffffc020176a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020176e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201772:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201776:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020177a:	fcd57fe3          	bgeu	a0,a3,ffffffffc0201758 <vprintfmt+0x112>
ffffffffc020177e:	b779                	j	ffffffffc020170c <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0201780:	000aa503          	lw	a0,0(s5)
ffffffffc0201784:	85a6                	mv	a1,s1
ffffffffc0201786:	0aa1                	addi	s5,s5,8
ffffffffc0201788:	9902                	jalr	s2
            break;
ffffffffc020178a:	bddd                	j	ffffffffc0201680 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020178c:	4705                	li	a4,1
ffffffffc020178e:	008a8993          	addi	s3,s5,8
ffffffffc0201792:	01074463          	blt	a4,a6,ffffffffc020179a <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0201796:	1c080463          	beqz	a6,ffffffffc020195e <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc020179a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020179e:	1c044a63          	bltz	s0,ffffffffc0201972 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02017a2:	8622                	mv	a2,s0
ffffffffc02017a4:	8ace                	mv	s5,s3
ffffffffc02017a6:	46a9                	li	a3,10
ffffffffc02017a8:	a8f1                	j	ffffffffc0201884 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02017aa:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017ae:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017b0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02017b2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017b6:	8fb5                	xor	a5,a5,a3
ffffffffc02017b8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017bc:	12d74963          	blt	a4,a3,ffffffffc02018ee <vprintfmt+0x2a8>
ffffffffc02017c0:	00369793          	slli	a5,a3,0x3
ffffffffc02017c4:	97e2                	add	a5,a5,s8
ffffffffc02017c6:	639c                	ld	a5,0(a5)
ffffffffc02017c8:	12078363          	beqz	a5,ffffffffc02018ee <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017cc:	86be                	mv	a3,a5
ffffffffc02017ce:	00001617          	auipc	a2,0x1
ffffffffc02017d2:	27260613          	addi	a2,a2,626 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc02017d6:	85a6                	mv	a1,s1
ffffffffc02017d8:	854a                	mv	a0,s2
ffffffffc02017da:	1cc000ef          	jal	ra,ffffffffc02019a6 <printfmt>
ffffffffc02017de:	b54d                	j	ffffffffc0201680 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017e0:	000ab603          	ld	a2,0(s5)
ffffffffc02017e4:	0aa1                	addi	s5,s5,8
ffffffffc02017e6:	1a060163          	beqz	a2,ffffffffc0201988 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02017ea:	00160413          	addi	s0,a2,1
ffffffffc02017ee:	15b05763          	blez	s11,ffffffffc020193c <vprintfmt+0x2f6>
ffffffffc02017f2:	02d00593          	li	a1,45
ffffffffc02017f6:	10b79d63          	bne	a5,a1,ffffffffc0201910 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017fa:	00064783          	lbu	a5,0(a2)
ffffffffc02017fe:	0007851b          	sext.w	a0,a5
ffffffffc0201802:	c905                	beqz	a0,ffffffffc0201832 <vprintfmt+0x1ec>
ffffffffc0201804:	000cc563          	bltz	s9,ffffffffc020180e <vprintfmt+0x1c8>
ffffffffc0201808:	3cfd                	addiw	s9,s9,-1
ffffffffc020180a:	036c8263          	beq	s9,s6,ffffffffc020182e <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020180e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201810:	14098f63          	beqz	s3,ffffffffc020196e <vprintfmt+0x328>
ffffffffc0201814:	3781                	addiw	a5,a5,-32
ffffffffc0201816:	14fbfc63          	bgeu	s7,a5,ffffffffc020196e <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc020181a:	03f00513          	li	a0,63
ffffffffc020181e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201820:	0405                	addi	s0,s0,1
ffffffffc0201822:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201826:	3dfd                	addiw	s11,s11,-1
ffffffffc0201828:	0007851b          	sext.w	a0,a5
ffffffffc020182c:	fd61                	bnez	a0,ffffffffc0201804 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020182e:	e5b059e3          	blez	s11,ffffffffc0201680 <vprintfmt+0x3a>
ffffffffc0201832:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201834:	85a6                	mv	a1,s1
ffffffffc0201836:	02000513          	li	a0,32
ffffffffc020183a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020183c:	e40d82e3          	beqz	s11,ffffffffc0201680 <vprintfmt+0x3a>
ffffffffc0201840:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201842:	85a6                	mv	a1,s1
ffffffffc0201844:	02000513          	li	a0,32
ffffffffc0201848:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020184a:	fe0d94e3          	bnez	s11,ffffffffc0201832 <vprintfmt+0x1ec>
ffffffffc020184e:	bd0d                	j	ffffffffc0201680 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201850:	4705                	li	a4,1
ffffffffc0201852:	008a8593          	addi	a1,s5,8
ffffffffc0201856:	01074463          	blt	a4,a6,ffffffffc020185e <vprintfmt+0x218>
    else if (lflag) {
ffffffffc020185a:	0e080863          	beqz	a6,ffffffffc020194a <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc020185e:	000ab603          	ld	a2,0(s5)
ffffffffc0201862:	46a1                	li	a3,8
ffffffffc0201864:	8aae                	mv	s5,a1
ffffffffc0201866:	a839                	j	ffffffffc0201884 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0201868:	03000513          	li	a0,48
ffffffffc020186c:	85a6                	mv	a1,s1
ffffffffc020186e:	e03e                	sd	a5,0(sp)
ffffffffc0201870:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201872:	85a6                	mv	a1,s1
ffffffffc0201874:	07800513          	li	a0,120
ffffffffc0201878:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020187a:	0aa1                	addi	s5,s5,8
ffffffffc020187c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201880:	6782                	ld	a5,0(sp)
ffffffffc0201882:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201884:	2781                	sext.w	a5,a5
ffffffffc0201886:	876e                	mv	a4,s11
ffffffffc0201888:	85a6                	mv	a1,s1
ffffffffc020188a:	854a                	mv	a0,s2
ffffffffc020188c:	d4fff0ef          	jal	ra,ffffffffc02015da <printnum>
            break;
ffffffffc0201890:	bbc5                	j	ffffffffc0201680 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201892:	00144603          	lbu	a2,1(s0)
ffffffffc0201896:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201898:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020189a:	b515                	j	ffffffffc02016be <vprintfmt+0x78>
            goto reswitch;
ffffffffc020189c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02018a0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018a2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018a4:	bd29                	j	ffffffffc02016be <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02018a6:	85a6                	mv	a1,s1
ffffffffc02018a8:	02500513          	li	a0,37
ffffffffc02018ac:	9902                	jalr	s2
            break;
ffffffffc02018ae:	bbc9                	j	ffffffffc0201680 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018b0:	4705                	li	a4,1
ffffffffc02018b2:	008a8593          	addi	a1,s5,8
ffffffffc02018b6:	01074463          	blt	a4,a6,ffffffffc02018be <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02018ba:	08080d63          	beqz	a6,ffffffffc0201954 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02018be:	000ab603          	ld	a2,0(s5)
ffffffffc02018c2:	46a9                	li	a3,10
ffffffffc02018c4:	8aae                	mv	s5,a1
ffffffffc02018c6:	bf7d                	j	ffffffffc0201884 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02018c8:	85a6                	mv	a1,s1
ffffffffc02018ca:	02500513          	li	a0,37
ffffffffc02018ce:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02018d0:	fff44703          	lbu	a4,-1(s0)
ffffffffc02018d4:	02500793          	li	a5,37
ffffffffc02018d8:	8d22                	mv	s10,s0
ffffffffc02018da:	daf703e3          	beq	a4,a5,ffffffffc0201680 <vprintfmt+0x3a>
ffffffffc02018de:	02500713          	li	a4,37
ffffffffc02018e2:	1d7d                	addi	s10,s10,-1
ffffffffc02018e4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02018e8:	fee79de3          	bne	a5,a4,ffffffffc02018e2 <vprintfmt+0x29c>
ffffffffc02018ec:	bb51                	j	ffffffffc0201680 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018ee:	00001617          	auipc	a2,0x1
ffffffffc02018f2:	14260613          	addi	a2,a2,322 # ffffffffc0202a30 <error_string+0xd8>
ffffffffc02018f6:	85a6                	mv	a1,s1
ffffffffc02018f8:	854a                	mv	a0,s2
ffffffffc02018fa:	0ac000ef          	jal	ra,ffffffffc02019a6 <printfmt>
ffffffffc02018fe:	b349                	j	ffffffffc0201680 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201900:	00001617          	auipc	a2,0x1
ffffffffc0201904:	12860613          	addi	a2,a2,296 # ffffffffc0202a28 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201908:	00001417          	auipc	s0,0x1
ffffffffc020190c:	12140413          	addi	s0,s0,289 # ffffffffc0202a29 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201910:	8532                	mv	a0,a2
ffffffffc0201912:	85e6                	mv	a1,s9
ffffffffc0201914:	e032                	sd	a2,0(sp)
ffffffffc0201916:	e43e                	sd	a5,8(sp)
ffffffffc0201918:	1de000ef          	jal	ra,ffffffffc0201af6 <strnlen>
ffffffffc020191c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201920:	6602                	ld	a2,0(sp)
ffffffffc0201922:	01b05d63          	blez	s11,ffffffffc020193c <vprintfmt+0x2f6>
ffffffffc0201926:	67a2                	ld	a5,8(sp)
ffffffffc0201928:	2781                	sext.w	a5,a5
ffffffffc020192a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020192c:	6522                	ld	a0,8(sp)
ffffffffc020192e:	85a6                	mv	a1,s1
ffffffffc0201930:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201932:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201934:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201936:	6602                	ld	a2,0(sp)
ffffffffc0201938:	fe0d9ae3          	bnez	s11,ffffffffc020192c <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020193c:	00064783          	lbu	a5,0(a2)
ffffffffc0201940:	0007851b          	sext.w	a0,a5
ffffffffc0201944:	ec0510e3          	bnez	a0,ffffffffc0201804 <vprintfmt+0x1be>
ffffffffc0201948:	bb25                	j	ffffffffc0201680 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc020194a:	000ae603          	lwu	a2,0(s5)
ffffffffc020194e:	46a1                	li	a3,8
ffffffffc0201950:	8aae                	mv	s5,a1
ffffffffc0201952:	bf0d                	j	ffffffffc0201884 <vprintfmt+0x23e>
ffffffffc0201954:	000ae603          	lwu	a2,0(s5)
ffffffffc0201958:	46a9                	li	a3,10
ffffffffc020195a:	8aae                	mv	s5,a1
ffffffffc020195c:	b725                	j	ffffffffc0201884 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc020195e:	000aa403          	lw	s0,0(s5)
ffffffffc0201962:	bd35                	j	ffffffffc020179e <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0201964:	000ae603          	lwu	a2,0(s5)
ffffffffc0201968:	46c1                	li	a3,16
ffffffffc020196a:	8aae                	mv	s5,a1
ffffffffc020196c:	bf21                	j	ffffffffc0201884 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc020196e:	9902                	jalr	s2
ffffffffc0201970:	bd45                	j	ffffffffc0201820 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201972:	85a6                	mv	a1,s1
ffffffffc0201974:	02d00513          	li	a0,45
ffffffffc0201978:	e03e                	sd	a5,0(sp)
ffffffffc020197a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020197c:	8ace                	mv	s5,s3
ffffffffc020197e:	40800633          	neg	a2,s0
ffffffffc0201982:	46a9                	li	a3,10
ffffffffc0201984:	6782                	ld	a5,0(sp)
ffffffffc0201986:	bdfd                	j	ffffffffc0201884 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0201988:	01b05663          	blez	s11,ffffffffc0201994 <vprintfmt+0x34e>
ffffffffc020198c:	02d00693          	li	a3,45
ffffffffc0201990:	f6d798e3          	bne	a5,a3,ffffffffc0201900 <vprintfmt+0x2ba>
ffffffffc0201994:	00001417          	auipc	s0,0x1
ffffffffc0201998:	09540413          	addi	s0,s0,149 # ffffffffc0202a29 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020199c:	02800513          	li	a0,40
ffffffffc02019a0:	02800793          	li	a5,40
ffffffffc02019a4:	b585                	j	ffffffffc0201804 <vprintfmt+0x1be>

ffffffffc02019a6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019a6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019a8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019ac:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019ae:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019b0:	ec06                	sd	ra,24(sp)
ffffffffc02019b2:	f83a                	sd	a4,48(sp)
ffffffffc02019b4:	fc3e                	sd	a5,56(sp)
ffffffffc02019b6:	e0c2                	sd	a6,64(sp)
ffffffffc02019b8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02019ba:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019bc:	c8bff0ef          	jal	ra,ffffffffc0201646 <vprintfmt>
}
ffffffffc02019c0:	60e2                	ld	ra,24(sp)
ffffffffc02019c2:	6161                	addi	sp,sp,80
ffffffffc02019c4:	8082                	ret

ffffffffc02019c6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02019c6:	715d                	addi	sp,sp,-80
ffffffffc02019c8:	e486                	sd	ra,72(sp)
ffffffffc02019ca:	e0a2                	sd	s0,64(sp)
ffffffffc02019cc:	fc26                	sd	s1,56(sp)
ffffffffc02019ce:	f84a                	sd	s2,48(sp)
ffffffffc02019d0:	f44e                	sd	s3,40(sp)
ffffffffc02019d2:	f052                	sd	s4,32(sp)
ffffffffc02019d4:	ec56                	sd	s5,24(sp)
ffffffffc02019d6:	e85a                	sd	s6,16(sp)
ffffffffc02019d8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02019da:	c901                	beqz	a0,ffffffffc02019ea <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02019dc:	85aa                	mv	a1,a0
ffffffffc02019de:	00001517          	auipc	a0,0x1
ffffffffc02019e2:	06250513          	addi	a0,a0,98 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc02019e6:	ed0fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02019ea:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019ec:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02019ee:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02019f0:	4aa9                	li	s5,10
ffffffffc02019f2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019f4:	00004b97          	auipc	s7,0x4
ffffffffc02019f8:	624b8b93          	addi	s7,s7,1572 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019fc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a00:	f2cfe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a04:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a06:	00054b63          	bltz	a0,ffffffffc0201a1c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a0a:	00a95b63          	bge	s2,a0,ffffffffc0201a20 <readline+0x5a>
ffffffffc0201a0e:	029a5463          	bge	s4,s1,ffffffffc0201a36 <readline+0x70>
        c = getchar();
ffffffffc0201a12:	f1afe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a16:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a18:	fe0559e3          	bgez	a0,ffffffffc0201a0a <readline+0x44>
            return NULL;
ffffffffc0201a1c:	4501                	li	a0,0
ffffffffc0201a1e:	a099                	j	ffffffffc0201a64 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201a20:	03341463          	bne	s0,s3,ffffffffc0201a48 <readline+0x82>
ffffffffc0201a24:	e8b9                	bnez	s1,ffffffffc0201a7a <readline+0xb4>
        c = getchar();
ffffffffc0201a26:	f06fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a2a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a2c:	fe0548e3          	bltz	a0,ffffffffc0201a1c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a30:	fea958e3          	bge	s2,a0,ffffffffc0201a20 <readline+0x5a>
ffffffffc0201a34:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a36:	8522                	mv	a0,s0
ffffffffc0201a38:	eb2fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201a3c:	009b87b3          	add	a5,s7,s1
ffffffffc0201a40:	00878023          	sb	s0,0(a5)
ffffffffc0201a44:	2485                	addiw	s1,s1,1
ffffffffc0201a46:	bf6d                	j	ffffffffc0201a00 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a48:	01540463          	beq	s0,s5,ffffffffc0201a50 <readline+0x8a>
ffffffffc0201a4c:	fb641ae3          	bne	s0,s6,ffffffffc0201a00 <readline+0x3a>
            cputchar(c);
ffffffffc0201a50:	8522                	mv	a0,s0
ffffffffc0201a52:	e98fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a56:	00004517          	auipc	a0,0x4
ffffffffc0201a5a:	5c250513          	addi	a0,a0,1474 # ffffffffc0206018 <edata>
ffffffffc0201a5e:	94aa                	add	s1,s1,a0
ffffffffc0201a60:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a64:	60a6                	ld	ra,72(sp)
ffffffffc0201a66:	6406                	ld	s0,64(sp)
ffffffffc0201a68:	74e2                	ld	s1,56(sp)
ffffffffc0201a6a:	7942                	ld	s2,48(sp)
ffffffffc0201a6c:	79a2                	ld	s3,40(sp)
ffffffffc0201a6e:	7a02                	ld	s4,32(sp)
ffffffffc0201a70:	6ae2                	ld	s5,24(sp)
ffffffffc0201a72:	6b42                	ld	s6,16(sp)
ffffffffc0201a74:	6ba2                	ld	s7,8(sp)
ffffffffc0201a76:	6161                	addi	sp,sp,80
ffffffffc0201a78:	8082                	ret
            cputchar(c);
ffffffffc0201a7a:	4521                	li	a0,8
ffffffffc0201a7c:	e6efe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a80:	34fd                	addiw	s1,s1,-1
ffffffffc0201a82:	bfbd                	j	ffffffffc0201a00 <readline+0x3a>

ffffffffc0201a84 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a84:	00004797          	auipc	a5,0x4
ffffffffc0201a88:	58478793          	addi	a5,a5,1412 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a8c:	6398                	ld	a4,0(a5)
ffffffffc0201a8e:	4781                	li	a5,0
ffffffffc0201a90:	88ba                	mv	a7,a4
ffffffffc0201a92:	852a                	mv	a0,a0
ffffffffc0201a94:	85be                	mv	a1,a5
ffffffffc0201a96:	863e                	mv	a2,a5
ffffffffc0201a98:	00000073          	ecall
ffffffffc0201a9c:	87aa                	mv	a5,a0
}
ffffffffc0201a9e:	8082                	ret

ffffffffc0201aa0 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201aa0:	00005797          	auipc	a5,0x5
ffffffffc0201aa4:	9a078793          	addi	a5,a5,-1632 # ffffffffc0206440 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201aa8:	6398                	ld	a4,0(a5)
ffffffffc0201aaa:	4781                	li	a5,0
ffffffffc0201aac:	88ba                	mv	a7,a4
ffffffffc0201aae:	852a                	mv	a0,a0
ffffffffc0201ab0:	85be                	mv	a1,a5
ffffffffc0201ab2:	863e                	mv	a2,a5
ffffffffc0201ab4:	00000073          	ecall
ffffffffc0201ab8:	87aa                	mv	a5,a0
}
ffffffffc0201aba:	8082                	ret

ffffffffc0201abc <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201abc:	00004797          	auipc	a5,0x4
ffffffffc0201ac0:	54478793          	addi	a5,a5,1348 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201ac4:	639c                	ld	a5,0(a5)
ffffffffc0201ac6:	4501                	li	a0,0
ffffffffc0201ac8:	88be                	mv	a7,a5
ffffffffc0201aca:	852a                	mv	a0,a0
ffffffffc0201acc:	85aa                	mv	a1,a0
ffffffffc0201ace:	862a                	mv	a2,a0
ffffffffc0201ad0:	00000073          	ecall
ffffffffc0201ad4:	852a                	mv	a0,a0
}
ffffffffc0201ad6:	2501                	sext.w	a0,a0
ffffffffc0201ad8:	8082                	ret

ffffffffc0201ada <sbi_shutdown>:

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201ada:	00004797          	auipc	a5,0x4
ffffffffc0201ade:	53678793          	addi	a5,a5,1334 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201ae2:	6398                	ld	a4,0(a5)
ffffffffc0201ae4:	4781                	li	a5,0
ffffffffc0201ae6:	88ba                	mv	a7,a4
ffffffffc0201ae8:	853e                	mv	a0,a5
ffffffffc0201aea:	85be                	mv	a1,a5
ffffffffc0201aec:	863e                	mv	a2,a5
ffffffffc0201aee:	00000073          	ecall
ffffffffc0201af2:	87aa                	mv	a5,a0
ffffffffc0201af4:	8082                	ret

ffffffffc0201af6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201af6:	c185                	beqz	a1,ffffffffc0201b16 <strnlen+0x20>
ffffffffc0201af8:	00054783          	lbu	a5,0(a0)
ffffffffc0201afc:	cf89                	beqz	a5,ffffffffc0201b16 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201afe:	4781                	li	a5,0
ffffffffc0201b00:	a021                	j	ffffffffc0201b08 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b02:	00074703          	lbu	a4,0(a4)
ffffffffc0201b06:	c711                	beqz	a4,ffffffffc0201b12 <strnlen+0x1c>
        cnt ++;
ffffffffc0201b08:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b0a:	00f50733          	add	a4,a0,a5
ffffffffc0201b0e:	fef59ae3          	bne	a1,a5,ffffffffc0201b02 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201b12:	853e                	mv	a0,a5
ffffffffc0201b14:	8082                	ret
    size_t cnt = 0;
ffffffffc0201b16:	4781                	li	a5,0
}
ffffffffc0201b18:	853e                	mv	a0,a5
ffffffffc0201b1a:	8082                	ret

ffffffffc0201b1c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b1c:	00054783          	lbu	a5,0(a0)
ffffffffc0201b20:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b24:	cb91                	beqz	a5,ffffffffc0201b38 <strcmp+0x1c>
ffffffffc0201b26:	00e79c63          	bne	a5,a4,ffffffffc0201b3e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201b2a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b2c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201b30:	0585                	addi	a1,a1,1
ffffffffc0201b32:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b36:	fbe5                	bnez	a5,ffffffffc0201b26 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b38:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b3a:	9d19                	subw	a0,a0,a4
ffffffffc0201b3c:	8082                	ret
ffffffffc0201b3e:	0007851b          	sext.w	a0,a5
ffffffffc0201b42:	9d19                	subw	a0,a0,a4
ffffffffc0201b44:	8082                	ret

ffffffffc0201b46 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201b46:	00054783          	lbu	a5,0(a0)
ffffffffc0201b4a:	cb91                	beqz	a5,ffffffffc0201b5e <strchr+0x18>
        if (*s == c) {
ffffffffc0201b4c:	00b79563          	bne	a5,a1,ffffffffc0201b56 <strchr+0x10>
ffffffffc0201b50:	a809                	j	ffffffffc0201b62 <strchr+0x1c>
ffffffffc0201b52:	00b78763          	beq	a5,a1,ffffffffc0201b60 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201b56:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201b58:	00054783          	lbu	a5,0(a0)
ffffffffc0201b5c:	fbfd                	bnez	a5,ffffffffc0201b52 <strchr+0xc>
    }
    return NULL;
ffffffffc0201b5e:	4501                	li	a0,0
}
ffffffffc0201b60:	8082                	ret
ffffffffc0201b62:	8082                	ret

ffffffffc0201b64 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b64:	ca01                	beqz	a2,ffffffffc0201b74 <memset+0x10>
ffffffffc0201b66:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b68:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b6a:	0785                	addi	a5,a5,1
ffffffffc0201b6c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b70:	fec79de3          	bne	a5,a2,ffffffffc0201b6a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b74:	8082                	ret

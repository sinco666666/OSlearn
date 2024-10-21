
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
ffffffffc0200042:	48260613          	addi	a2,a2,1154 # ffffffffc02064c0 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	525010ef          	jal	ra,ffffffffc0201d72 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	d3250513          	addi	a0,a0,-718 # ffffffffc0201d88 <etext+0x4>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	5d0010ef          	jal	ra,ffffffffc020163a <pmm_init>

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
ffffffffc02000aa:	7aa010ef          	jal	ra,ffffffffc0201854 <vprintfmt>
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
ffffffffc02000de:	776010ef          	jal	ra,ffffffffc0201854 <vprintfmt>
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
ffffffffc0200142:	c9a50513          	addi	a0,a0,-870 # ffffffffc0201dd8 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00002517          	auipc	a0,0x2
ffffffffc0200158:	ca450513          	addi	a0,a0,-860 # ffffffffc0201df8 <etext+0x74>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00002597          	auipc	a1,0x2
ffffffffc0200164:	c2458593          	addi	a1,a1,-988 # ffffffffc0201d84 <etext>
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	cb050513          	addi	a0,a0,-848 # ffffffffc0201e18 <etext+0x94>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	ea458593          	addi	a1,a1,-348 # ffffffffc0206018 <edata>
ffffffffc020017c:	00002517          	auipc	a0,0x2
ffffffffc0200180:	cbc50513          	addi	a0,a0,-836 # ffffffffc0201e38 <etext+0xb4>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	33858593          	addi	a1,a1,824 # ffffffffc02064c0 <end>
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	cc850513          	addi	a0,a0,-824 # ffffffffc0201e58 <etext+0xd4>
ffffffffc0200198:	f1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019c:	00006597          	auipc	a1,0x6
ffffffffc02001a0:	72358593          	addi	a1,a1,1827 # ffffffffc02068bf <end+0x3ff>
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
ffffffffc02001c2:	cba50513          	addi	a0,a0,-838 # ffffffffc0201e78 <etext+0xf4>
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
ffffffffc02001d0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0201da8 <etext+0x24>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	be850513          	addi	a0,a0,-1048 # ffffffffc0201dc0 <etext+0x3c>
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
ffffffffc02001ec:	da060613          	addi	a2,a2,-608 # ffffffffc0201f88 <commands+0xe0>
ffffffffc02001f0:	00002597          	auipc	a1,0x2
ffffffffc02001f4:	db858593          	addi	a1,a1,-584 # ffffffffc0201fa8 <commands+0x100>
ffffffffc02001f8:	00002517          	auipc	a0,0x2
ffffffffc02001fc:	db850513          	addi	a0,a0,-584 # ffffffffc0201fb0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00002617          	auipc	a2,0x2
ffffffffc020020a:	dba60613          	addi	a2,a2,-582 # ffffffffc0201fc0 <commands+0x118>
ffffffffc020020e:	00002597          	auipc	a1,0x2
ffffffffc0200212:	dda58593          	addi	a1,a1,-550 # ffffffffc0201fe8 <commands+0x140>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0201fb0 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	dd660613          	addi	a2,a2,-554 # ffffffffc0201ff8 <commands+0x150>
ffffffffc020022a:	00002597          	auipc	a1,0x2
ffffffffc020022e:	dee58593          	addi	a1,a1,-530 # ffffffffc0202018 <commands+0x170>
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	d7e50513          	addi	a0,a0,-642 # ffffffffc0201fb0 <commands+0x108>
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
ffffffffc0200270:	c8450513          	addi	a0,a0,-892 # ffffffffc0201ef0 <commands+0x48>
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
ffffffffc0200292:	c8a50513          	addi	a0,a0,-886 # ffffffffc0201f18 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00002c97          	auipc	s9,0x2
ffffffffc02002a8:	c04c8c93          	addi	s9,s9,-1020 # ffffffffc0201ea8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00002997          	auipc	s3,0x2
ffffffffc02002b0:	c9498993          	addi	s3,s3,-876 # ffffffffc0201f40 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	c9490913          	addi	s2,s2,-876 # ffffffffc0201f48 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00002b17          	auipc	s6,0x2
ffffffffc02002c2:	c92b0b13          	addi	s6,s6,-878 # ffffffffc0201f50 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	ce2a8a93          	addi	s5,s5,-798 # ffffffffc0201fa8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	103010ef          	jal	ra,ffffffffc0201bd4 <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	271010ef          	jal	ra,ffffffffc0201d54 <strchr>
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
ffffffffc02002fe:	baed0d13          	addi	s10,s10,-1106 # ffffffffc0201ea8 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	223010ef          	jal	ra,ffffffffc0201d2a <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	20f010ef          	jal	ra,ffffffffc0201d2a <strcmp>
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
ffffffffc0200382:	1d3010ef          	jal	ra,ffffffffc0201d54 <strchr>
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
ffffffffc020039e:	bd650513          	addi	a0,a0,-1066 # ffffffffc0201f70 <commands+0xc8>
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
ffffffffc02003de:	c4e50513          	addi	a0,a0,-946 # ffffffffc0202028 <commands+0x180>
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
ffffffffc02003f4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0201ea0 <etext+0x11c>
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
ffffffffc0200420:	08f010ef          	jal	ra,ffffffffc0201cae <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0407bd23          	sd	zero,90(a5) # ffffffffc0206480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	c1a50513          	addi	a0,a0,-998 # ffffffffc0202048 <commands+0x1a0>
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
ffffffffc0200446:	0690106f          	j	ffffffffc0201cae <sbi_set_timer>

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
ffffffffc0200450:	0430106f          	j	ffffffffc0201c92 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0770106f          	j	ffffffffc0201cca <sbi_console_getchar>

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
ffffffffc0200482:	d6a50513          	addi	a0,a0,-662 # ffffffffc02021e8 <commands+0x340>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	d7250513          	addi	a0,a0,-654 # ffffffffc0202200 <commands+0x358>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0202218 <commands+0x370>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	d8650513          	addi	a0,a0,-634 # ffffffffc0202230 <commands+0x388>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	d9050513          	addi	a0,a0,-624 # ffffffffc0202248 <commands+0x3a0>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	d9a50513          	addi	a0,a0,-614 # ffffffffc0202260 <commands+0x3b8>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	da450513          	addi	a0,a0,-604 # ffffffffc0202278 <commands+0x3d0>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	dae50513          	addi	a0,a0,-594 # ffffffffc0202290 <commands+0x3e8>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	db850513          	addi	a0,a0,-584 # ffffffffc02022a8 <commands+0x400>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	dc250513          	addi	a0,a0,-574 # ffffffffc02022c0 <commands+0x418>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	dcc50513          	addi	a0,a0,-564 # ffffffffc02022d8 <commands+0x430>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	dd650513          	addi	a0,a0,-554 # ffffffffc02022f0 <commands+0x448>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	de050513          	addi	a0,a0,-544 # ffffffffc0202308 <commands+0x460>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	dea50513          	addi	a0,a0,-534 # ffffffffc0202320 <commands+0x478>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	df450513          	addi	a0,a0,-524 # ffffffffc0202338 <commands+0x490>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	dfe50513          	addi	a0,a0,-514 # ffffffffc0202350 <commands+0x4a8>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	e0850513          	addi	a0,a0,-504 # ffffffffc0202368 <commands+0x4c0>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	e1250513          	addi	a0,a0,-494 # ffffffffc0202380 <commands+0x4d8>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	e1c50513          	addi	a0,a0,-484 # ffffffffc0202398 <commands+0x4f0>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	e2650513          	addi	a0,a0,-474 # ffffffffc02023b0 <commands+0x508>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	e3050513          	addi	a0,a0,-464 # ffffffffc02023c8 <commands+0x520>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	e3a50513          	addi	a0,a0,-454 # ffffffffc02023e0 <commands+0x538>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	e4450513          	addi	a0,a0,-444 # ffffffffc02023f8 <commands+0x550>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0202410 <commands+0x568>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	e5850513          	addi	a0,a0,-424 # ffffffffc0202428 <commands+0x580>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	e6250513          	addi	a0,a0,-414 # ffffffffc0202440 <commands+0x598>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0202458 <commands+0x5b0>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	e7650513          	addi	a0,a0,-394 # ffffffffc0202470 <commands+0x5c8>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	e8050513          	addi	a0,a0,-384 # ffffffffc0202488 <commands+0x5e0>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	e8a50513          	addi	a0,a0,-374 # ffffffffc02024a0 <commands+0x5f8>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	e9450513          	addi	a0,a0,-364 # ffffffffc02024b8 <commands+0x610>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	e9a50513          	addi	a0,a0,-358 # ffffffffc02024d0 <commands+0x628>
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
ffffffffc020064e:	e9e50513          	addi	a0,a0,-354 # ffffffffc02024e8 <commands+0x640>
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
ffffffffc0200666:	e9e50513          	addi	a0,a0,-354 # ffffffffc0202500 <commands+0x658>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	ea650513          	addi	a0,a0,-346 # ffffffffc0202518 <commands+0x670>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	eae50513          	addi	a0,a0,-338 # ffffffffc0202530 <commands+0x688>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	eb250513          	addi	a0,a0,-334 # ffffffffc0202548 <commands+0x6a0>
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
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	9b470713          	addi	a4,a4,-1612 # ffffffffc0202064 <commands+0x1bc>
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
ffffffffc02006c6:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202180 <commands+0x2d8>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a9450513          	addi	a0,a0,-1388 # ffffffffc0202160 <commands+0x2b8>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0202120 <commands+0x278>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	ac050513          	addi	a0,a0,-1344 # ffffffffc02021a0 <commands+0x2f8>
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
ffffffffc020072e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc02021c8 <commands+0x320>
ffffffffc0200732:	b251                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200734:	00002517          	auipc	a0,0x2
ffffffffc0200738:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0202140 <commands+0x298>
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020073e:	b711                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc0200740:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200742:	06400593          	li	a1,100
ffffffffc0200746:	00002517          	auipc	a0,0x2
ffffffffc020074a:	a7250513          	addi	a0,a0,-1422 # ffffffffc02021b8 <commands+0x310>
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
ffffffffc0200764:	5840106f          	j	ffffffffc0201ce8 <sbi_shutdown>

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
ffffffffc02007a0:	00002517          	auipc	a0,0x2
ffffffffc02007a4:	8f850513          	addi	a0,a0,-1800 # ffffffffc0202098 <commands+0x1f0>
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc02007ac:	10843583          	ld	a1,264(s0)
ffffffffc02007b0:	00002517          	auipc	a0,0x2
ffffffffc02007b4:	91050513          	addi	a0,a0,-1776 # ffffffffc02020c0 <commands+0x218>
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
ffffffffc02007ce:	00002517          	auipc	a0,0x2
ffffffffc02007d2:	91a50513          	addi	a0,a0,-1766 # ffffffffc02020e8 <commands+0x240>
ffffffffc02007d6:	8e1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007da:	10843583          	ld	a1,264(s0)
ffffffffc02007de:	00002517          	auipc	a0,0x2
ffffffffc02007e2:	92a50513          	addi	a0,a0,-1750 # ffffffffc0202108 <commands+0x260>
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

ffffffffc02008be <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008be:	00006797          	auipc	a5,0x6
ffffffffc02008c2:	bca78793          	addi	a5,a5,-1078 # ffffffffc0206488 <free_area>
ffffffffc02008c6:	e79c                	sd	a5,8(a5)
ffffffffc02008c8:	e39c                	sd	a5,0(a5)
#define POWER_ROUND_DOWN(a) (POWER_REMAINDER(a) ? ((a)-POWER_REMAINDER(a)) : (a))

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008ca:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008ce:	8082                	ret

ffffffffc02008d0 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	bc856503          	lwu	a0,-1080(a0) # ffffffffc0206498 <free_area+0x10>
ffffffffc02008d8:	8082                	ret

ffffffffc02008da <buddy_free_pages>:
{
ffffffffc02008da:	1141                	addi	sp,sp,-16
ffffffffc02008dc:	e406                	sd	ra,8(sp)
ffffffffc02008de:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02008e0:	22058b63          	beqz	a1,ffffffffc0200b16 <buddy_free_pages+0x23c>
    size_t length = POWER_ROUND_UP(n);
ffffffffc02008e4:	0015d793          	srli	a5,a1,0x1
ffffffffc02008e8:	8fcd                	or	a5,a5,a1
ffffffffc02008ea:	0027d713          	srli	a4,a5,0x2
ffffffffc02008ee:	8fd9                	or	a5,a5,a4
ffffffffc02008f0:	0047d713          	srli	a4,a5,0x4
ffffffffc02008f4:	8f5d                	or	a4,a4,a5
ffffffffc02008f6:	00875793          	srli	a5,a4,0x8
ffffffffc02008fa:	8f5d                	or	a4,a4,a5
ffffffffc02008fc:	01075793          	srli	a5,a4,0x10
ffffffffc0200900:	8fd9                	or	a5,a5,a4
ffffffffc0200902:	8385                	srli	a5,a5,0x1
ffffffffc0200904:	00b7f733          	and	a4,a5,a1
ffffffffc0200908:	8e2e                	mv	t3,a1
ffffffffc020090a:	1e071063          	bnez	a4,ffffffffc0200aea <buddy_free_pages+0x210>
    size_t begin = (base - allocate_area);
ffffffffc020090e:	00006797          	auipc	a5,0x6
ffffffffc0200912:	b2278793          	addi	a5,a5,-1246 # ffffffffc0206430 <allocate_area>
ffffffffc0200916:	0007b803          	ld	a6,0(a5)
ffffffffc020091a:	00002717          	auipc	a4,0x2
ffffffffc020091e:	e8670713          	addi	a4,a4,-378 # ffffffffc02027a0 <commands+0x8f8>
ffffffffc0200922:	6318                	ld	a4,0(a4)
ffffffffc0200924:	410507b3          	sub	a5,a0,a6
ffffffffc0200928:	878d                	srai	a5,a5,0x3
ffffffffc020092a:	02e787b3          	mul	a5,a5,a4
    size_t block = BUDDY_BLOCK(begin, end);
ffffffffc020092e:	00006717          	auipc	a4,0x6
ffffffffc0200932:	b0a70713          	addi	a4,a4,-1270 # ffffffffc0206438 <full_tree_size>
ffffffffc0200936:	00073883          	ld	a7,0(a4)
    for (; p != base + n; p++)
ffffffffc020093a:	00259713          	slli	a4,a1,0x2
ffffffffc020093e:	00b70633          	add	a2,a4,a1
ffffffffc0200942:	060e                	slli	a2,a2,0x3
ffffffffc0200944:	962a                	add	a2,a2,a0
    size_t block = BUDDY_BLOCK(begin, end);
ffffffffc0200946:	03c7d7b3          	divu	a5,a5,t3
ffffffffc020094a:	03c8d733          	divu	a4,a7,t3
ffffffffc020094e:	973e                	add	a4,a4,a5
    for (; p != base + n; p++)
ffffffffc0200950:	02c50363          	beq	a0,a2,ffffffffc0200976 <buddy_free_pages+0x9c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200954:	6514                	ld	a3,8(a0)
        assert(!PageReserved(p));
ffffffffc0200956:	87aa                	mv	a5,a0
ffffffffc0200958:	8a85                	andi	a3,a3,1
ffffffffc020095a:	c691                	beqz	a3,ffffffffc0200966 <buddy_free_pages+0x8c>
ffffffffc020095c:	aa69                	j	ffffffffc0200af6 <buddy_free_pages+0x21c>
ffffffffc020095e:	6794                	ld	a3,8(a5)
ffffffffc0200960:	8a85                	andi	a3,a3,1
ffffffffc0200962:	18069a63          	bnez	a3,ffffffffc0200af6 <buddy_free_pages+0x21c>
        p->flags = 0;
ffffffffc0200966:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020096a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020096e:	02878793          	addi	a5,a5,40
ffffffffc0200972:	fec796e3          	bne	a5,a2,ffffffffc020095e <buddy_free_pages+0x84>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200976:	00006317          	auipc	t1,0x6
ffffffffc020097a:	b1230313          	addi	t1,t1,-1262 # ffffffffc0206488 <free_area>
ffffffffc020097e:	00833603          	ld	a2,8(t1)
    nr_free += length;
ffffffffc0200982:	01032783          	lw	a5,16(t1)
    record_area[block] = length;
ffffffffc0200986:	00006597          	auipc	a1,0x6
ffffffffc020098a:	aca58593          	addi	a1,a1,-1334 # ffffffffc0206450 <record_area>
    base->property = length;
ffffffffc020098e:	000e069b          	sext.w	a3,t3
    record_area[block] = length;
ffffffffc0200992:	618c                	ld	a1,0(a1)
    base->property = length;
ffffffffc0200994:	c914                	sw	a3,16(a0)
    list_add(&free_list, &(base->page_link));
ffffffffc0200996:	01850e93          	addi	t4,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020099a:	01d63023          	sd	t4,0(a2)
    nr_free += length;
ffffffffc020099e:	9fb5                	addw	a5,a5,a3
    record_area[block] = length;
ffffffffc02009a0:	00371693          	slli	a3,a4,0x3
    elm->next = next;
ffffffffc02009a4:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02009a6:	00653c23          	sd	t1,24(a0)
    nr_free += length;
ffffffffc02009aa:	00006617          	auipc	a2,0x6
ffffffffc02009ae:	aef62723          	sw	a5,-1298(a2) # ffffffffc0206498 <free_area+0x10>
    prev->next = next->prev = elm;
ffffffffc02009b2:	00006417          	auipc	s0,0x6
ffffffffc02009b6:	add43f23          	sd	t4,-1314(s0) # ffffffffc0206490 <free_area+0x8>
    record_area[block] = length;
ffffffffc02009ba:	96ae                	add	a3,a3,a1
ffffffffc02009bc:	01c6b023          	sd	t3,0(a3)
    while (block != TREE_ROOT)
ffffffffc02009c0:	4785                	li	a5,1
ffffffffc02009c2:	4505                	li	a0,1
ffffffffc02009c4:	00f71f63          	bne	a4,a5,ffffffffc02009e2 <buddy_free_pages+0x108>
ffffffffc02009c8:	aa29                	j	ffffffffc0200ae2 <buddy_free_pages+0x208>
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc02009ca:	00479713          	slli	a4,a5,0x4
ffffffffc02009ce:	972e                	add	a4,a4,a1
ffffffffc02009d0:	9616                	add	a2,a2,t0
ffffffffc02009d2:	6718                	ld	a4,8(a4)
ffffffffc02009d4:	6214                	ld	a3,0(a2)
ffffffffc02009d6:	8f55                	or	a4,a4,a3
ffffffffc02009d8:	00e2b023          	sd	a4,0(t0)
ffffffffc02009dc:	873e                	mv	a4,a5
    while (block != TREE_ROOT)
ffffffffc02009de:	10a78263          	beq	a5,a0,ffffffffc0200ae2 <buddy_free_pages+0x208>
        size_t left = LEFT_CHILD(block);
ffffffffc02009e2:	ffe77693          	andi	a3,a4,-2
        block = PARENT(block);
ffffffffc02009e6:	00175793          	srli	a5,a4,0x1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc02009ea:	00d7e733          	or	a4,a5,a3
ffffffffc02009ee:	00275613          	srli	a2,a4,0x2
ffffffffc02009f2:	8f51                	or	a4,a4,a2
ffffffffc02009f4:	00475613          	srli	a2,a4,0x4
ffffffffc02009f8:	8e59                	or	a2,a2,a4
ffffffffc02009fa:	00865713          	srli	a4,a2,0x8
ffffffffc02009fe:	8e59                	or	a2,a2,a4
ffffffffc0200a00:	01065713          	srli	a4,a2,0x10
ffffffffc0200a04:	8f51                	or	a4,a4,a2
ffffffffc0200a06:	00369e93          	slli	t4,a3,0x3
ffffffffc0200a0a:	8305                	srli	a4,a4,0x1
ffffffffc0200a0c:	9eae                	add	t4,t4,a1
ffffffffc0200a0e:	00d77f33          	and	t5,a4,a3
ffffffffc0200a12:	000ebf83          	ld	t6,0(t4)
        size_t left = LEFT_CHILD(block);
ffffffffc0200a16:	8636                	mv	a2,a3
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0200a18:	000f0663          	beqz	t5,ffffffffc0200a24 <buddy_free_pages+0x14a>
ffffffffc0200a1c:	fff74713          	not	a4,a4
ffffffffc0200a20:	00d77633          	and	a2,a4,a3
ffffffffc0200a24:	02c8d733          	divu	a4,a7,a2
ffffffffc0200a28:	00379613          	slli	a2,a5,0x3
ffffffffc0200a2c:	00c582b3          	add	t0,a1,a2
ffffffffc0200a30:	f8ef9de3          	bne	t6,a4,ffffffffc02009ca <buddy_free_pages+0xf0>
        size_t right = RIGHT_CHILD(block);
ffffffffc0200a34:	0685                	addi	a3,a3,1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
ffffffffc0200a36:	0016de13          	srli	t3,a3,0x1
ffffffffc0200a3a:	00de6e33          	or	t3,t3,a3
ffffffffc0200a3e:	002e5393          	srli	t2,t3,0x2
ffffffffc0200a42:	01c3ee33          	or	t3,t2,t3
ffffffffc0200a46:	004e5393          	srli	t2,t3,0x4
ffffffffc0200a4a:	01c3e3b3          	or	t2,t2,t3
ffffffffc0200a4e:	0083de13          	srli	t3,t2,0x8
ffffffffc0200a52:	007e63b3          	or	t2,t3,t2
ffffffffc0200a56:	0103de13          	srli	t3,t2,0x10
ffffffffc0200a5a:	007e6e33          	or	t3,t3,t2
ffffffffc0200a5e:	001e5e13          	srli	t3,t3,0x1
ffffffffc0200a62:	00de73b3          	and	t2,t3,a3
ffffffffc0200a66:	008eb403          	ld	s0,8(t4)
ffffffffc0200a6a:	00038663          	beqz	t2,ffffffffc0200a76 <buddy_free_pages+0x19c>
ffffffffc0200a6e:	fffe4e13          	not	t3,t3
ffffffffc0200a72:	01c6f6b3          	and	a3,a3,t3
ffffffffc0200a76:	02d8d6b3          	divu	a3,a7,a3
ffffffffc0200a7a:	f4d418e3          	bne	s0,a3,ffffffffc02009ca <buddy_free_pages+0xf0>
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc0200a7e:	02ef0733          	mul	a4,t5,a4
            record_area[block] = record_area[left] << 1;
ffffffffc0200a82:	0f86                	slli	t6,t6,0x1
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc0200a84:	028383b3          	mul	t2,t2,s0
            list_del(&(allocate_area[lbegin].page_link));
ffffffffc0200a88:	00271f13          	slli	t5,a4,0x2
ffffffffc0200a8c:	977a                	add	a4,a4,t5
ffffffffc0200a8e:	070e                	slli	a4,a4,0x3
ffffffffc0200a90:	9742                	add	a4,a4,a6
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a92:	7310                	ld	a2,32(a4)
ffffffffc0200a94:	01873f03          	ld	t5,24(a4)
            list_add(&free_list, &(allocate_area[lbegin].page_link));
ffffffffc0200a98:	01870e13          	addi	t3,a4,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200a9c:	00cf3423          	sd	a2,8(t5)
            list_del(&(allocate_area[rbegin].page_link));
ffffffffc0200aa0:	00239693          	slli	a3,t2,0x2
ffffffffc0200aa4:	93b6                	add	t2,t2,a3
ffffffffc0200aa6:	00339693          	slli	a3,t2,0x3
    next->prev = prev;
ffffffffc0200aaa:	01e63023          	sd	t5,0(a2)
ffffffffc0200aae:	96c2                	add	a3,a3,a6
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ab0:	6e90                	ld	a2,24(a3)
ffffffffc0200ab2:	7294                	ld	a3,32(a3)
    prev->next = next;
ffffffffc0200ab4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0200ab6:	e290                	sd	a2,0(a3)
            record_area[block] = record_area[left] << 1;
ffffffffc0200ab8:	01f2b023          	sd	t6,0(t0)
            allocate_area[lbegin].property = record_area[left] << 1;
ffffffffc0200abc:	000eb683          	ld	a3,0(t4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ac0:	00833603          	ld	a2,8(t1)
ffffffffc0200ac4:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200ac8:	cb14                	sw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc0200aca:	01c63023          	sd	t3,0(a2)
    elm->next = next;
ffffffffc0200ace:	f310                	sd	a2,32(a4)
    elm->prev = prev;
ffffffffc0200ad0:	00673c23          	sd	t1,24(a4)
    prev->next = next->prev = elm;
ffffffffc0200ad4:	00006697          	auipc	a3,0x6
ffffffffc0200ad8:	9bc6be23          	sd	t3,-1604(a3) # ffffffffc0206490 <free_area+0x8>
    elm->prev = prev;
ffffffffc0200adc:	873e                	mv	a4,a5
    while (block != TREE_ROOT)
ffffffffc0200ade:	f0a792e3          	bne	a5,a0,ffffffffc02009e2 <buddy_free_pages+0x108>
}
ffffffffc0200ae2:	60a2                	ld	ra,8(sp)
ffffffffc0200ae4:	6402                	ld	s0,0(sp)
ffffffffc0200ae6:	0141                	addi	sp,sp,16
ffffffffc0200ae8:	8082                	ret
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200aea:	fff7c793          	not	a5,a5
ffffffffc0200aee:	8fed                	and	a5,a5,a1
ffffffffc0200af0:	00179e13          	slli	t3,a5,0x1
ffffffffc0200af4:	bd29                	j	ffffffffc020090e <buddy_free_pages+0x34>
        assert(!PageReserved(p));
ffffffffc0200af6:	00002697          	auipc	a3,0x2
ffffffffc0200afa:	ce268693          	addi	a3,a3,-798 # ffffffffc02027d8 <commands+0x930>
ffffffffc0200afe:	00002617          	auipc	a2,0x2
ffffffffc0200b02:	cb260613          	addi	a2,a2,-846 # ffffffffc02027b0 <commands+0x908>
ffffffffc0200b06:	0ab00593          	li	a1,171
ffffffffc0200b0a:	00002517          	auipc	a0,0x2
ffffffffc0200b0e:	cbe50513          	addi	a0,a0,-834 # ffffffffc02027c8 <commands+0x920>
ffffffffc0200b12:	897ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200b16:	00002697          	auipc	a3,0x2
ffffffffc0200b1a:	c9268693          	addi	a3,a3,-878 # ffffffffc02027a8 <commands+0x900>
ffffffffc0200b1e:	00002617          	auipc	a2,0x2
ffffffffc0200b22:	c9260613          	addi	a2,a2,-878 # ffffffffc02027b0 <commands+0x908>
ffffffffc0200b26:	0a200593          	li	a1,162
ffffffffc0200b2a:	00002517          	auipc	a0,0x2
ffffffffc0200b2e:	c9e50513          	addi	a0,a0,-866 # ffffffffc02027c8 <commands+0x920>
ffffffffc0200b32:	877ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200b36 <buddy_allocate_pages>:
    assert(n > 0);
ffffffffc0200b36:	1c050563          	beqz	a0,ffffffffc0200d00 <buddy_allocate_pages+0x1ca>
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200b3a:	00155793          	srli	a5,a0,0x1
ffffffffc0200b3e:	8fc9                	or	a5,a5,a0
ffffffffc0200b40:	0027d713          	srli	a4,a5,0x2
ffffffffc0200b44:	8fd9                	or	a5,a5,a4
ffffffffc0200b46:	0047d713          	srli	a4,a5,0x4
ffffffffc0200b4a:	8f5d                	or	a4,a4,a5
ffffffffc0200b4c:	00875793          	srli	a5,a4,0x8
ffffffffc0200b50:	8f5d                	or	a4,a4,a5
ffffffffc0200b52:	01075793          	srli	a5,a4,0x10
ffffffffc0200b56:	8fd9                	or	a5,a5,a4
ffffffffc0200b58:	8385                	srli	a5,a5,0x1
ffffffffc0200b5a:	00a7f733          	and	a4,a5,a0
ffffffffc0200b5e:	18071c63          	bnez	a4,ffffffffc0200cf6 <buddy_allocate_pages+0x1c0>
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200b62:	00006797          	auipc	a5,0x6
ffffffffc0200b66:	8ee78793          	addi	a5,a5,-1810 # ffffffffc0206450 <record_area>
ffffffffc0200b6a:	0007b803          	ld	a6,0(a5)
ffffffffc0200b6e:	00006797          	auipc	a5,0x6
ffffffffc0200b72:	8ca78793          	addi	a5,a5,-1846 # ffffffffc0206438 <full_tree_size>
ffffffffc0200b76:	0007be83          	ld	t4,0(a5)
ffffffffc0200b7a:	00883583          	ld	a1,8(a6)
            list_del(&(allocate_area[begin].page_link));
ffffffffc0200b7e:	00006797          	auipc	a5,0x6
ffffffffc0200b82:	8b278793          	addi	a5,a5,-1870 # ffffffffc0206430 <allocate_area>
ffffffffc0200b86:	0007be03          	ld	t3,0(a5)
    size_t block = TREE_ROOT;
ffffffffc0200b8a:	4785                	li	a5,1
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200b8c:	00379313          	slli	t1,a5,0x3
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b90:	00006f17          	auipc	t5,0x6
ffffffffc0200b94:	8f8f0f13          	addi	t5,t5,-1800 # ffffffffc0206488 <free_area>
ffffffffc0200b98:	9342                	add	t1,t1,a6
ffffffffc0200b9a:	06a5ec63          	bltu	a1,a0,ffffffffc0200c12 <buddy_allocate_pages+0xdc>
ffffffffc0200b9e:	0017d613          	srli	a2,a5,0x1
ffffffffc0200ba2:	00f66733          	or	a4,a2,a5
ffffffffc0200ba6:	00275693          	srli	a3,a4,0x2
ffffffffc0200baa:	8f55                	or	a4,a4,a3
ffffffffc0200bac:	00475693          	srli	a3,a4,0x4
ffffffffc0200bb0:	8ed9                	or	a3,a3,a4
ffffffffc0200bb2:	0086d713          	srli	a4,a3,0x8
ffffffffc0200bb6:	8ed9                	or	a3,a3,a4
ffffffffc0200bb8:	0106d713          	srli	a4,a3,0x10
ffffffffc0200bbc:	8f55                	or	a4,a4,a3
ffffffffc0200bbe:	8305                	srli	a4,a4,0x1
ffffffffc0200bc0:	00f778b3          	and	a7,a4,a5
ffffffffc0200bc4:	86be                	mv	a3,a5
ffffffffc0200bc6:	00088663          	beqz	a7,ffffffffc0200bd2 <buddy_allocate_pages+0x9c>
ffffffffc0200bca:	fff74713          	not	a4,a4
ffffffffc0200bce:	00f776b3          	and	a3,a4,a5
ffffffffc0200bd2:	02ded733          	divu	a4,t4,a3
ffffffffc0200bd6:	0ce57563          	bgeu	a0,a4,ffffffffc0200ca0 <buddy_allocate_pages+0x16a>
        size_t left = LEFT_CHILD(block);
ffffffffc0200bda:	00179f93          	slli	t6,a5,0x1
        size_t right = RIGHT_CHILD(block);
ffffffffc0200bde:	00479693          	slli	a3,a5,0x4
ffffffffc0200be2:	001f8293          	addi	t0,t6,1
        if (BUDDY_EMPTY(block))
ffffffffc0200be6:	96c2                	add	a3,a3,a6
ffffffffc0200be8:	02b70e63          	beq	a4,a1,ffffffffc0200c24 <buddy_allocate_pages+0xee>
        else if (length & record_area[left])
ffffffffc0200bec:	6298                	ld	a4,0(a3)
ffffffffc0200bee:	00a77633          	and	a2,a4,a0
ffffffffc0200bf2:	e615                	bnez	a2,ffffffffc0200c1e <buddy_allocate_pages+0xe8>
        else if (length & record_area[right])
ffffffffc0200bf4:	6694                	ld	a3,8(a3)
ffffffffc0200bf6:	00a6f633          	and	a2,a3,a0
ffffffffc0200bfa:	ee11                	bnez	a2,ffffffffc0200c16 <buddy_allocate_pages+0xe0>
        else if (length <= record_area[left])
ffffffffc0200bfc:	02a77163          	bgeu	a4,a0,ffffffffc0200c1e <buddy_allocate_pages+0xe8>
        else if (length <= record_area[right])
ffffffffc0200c00:	8fbe                	mv	t6,a5
ffffffffc0200c02:	00a6fa63          	bgeu	a3,a0,ffffffffc0200c16 <buddy_allocate_pages+0xe0>
ffffffffc0200c06:	87fe                	mv	a5,t6
    while (length <= record_area[block] && length < NODE_LENGTH(block))
ffffffffc0200c08:	00379313          	slli	t1,a5,0x3
ffffffffc0200c0c:	9342                	add	t1,t1,a6
ffffffffc0200c0e:	f8a5f8e3          	bgeu	a1,a0,ffffffffc0200b9e <buddy_allocate_pages+0x68>
        return NULL;
ffffffffc0200c12:	4501                	li	a0,0
}
ffffffffc0200c14:	8082                	ret
            block = right;
ffffffffc0200c16:	8f96                	mv	t6,t0
ffffffffc0200c18:	85b6                	mv	a1,a3
        else if (length <= record_area[right])
ffffffffc0200c1a:	87fe                	mv	a5,t6
ffffffffc0200c1c:	b7f5                	j	ffffffffc0200c08 <buddy_allocate_pages+0xd2>
ffffffffc0200c1e:	85ba                	mv	a1,a4
ffffffffc0200c20:	87fe                	mv	a5,t6
ffffffffc0200c22:	b7dd                	j	ffffffffc0200c08 <buddy_allocate_pages+0xd2>
            size_t begin = NODE_BEGINNING(block);
ffffffffc0200c24:	06088b63          	beqz	a7,ffffffffc0200c9a <buddy_allocate_pages+0x164>
ffffffffc0200c28:	02b888b3          	mul	a7,a7,a1
            size_t end = NODE_ENDDING(block);
ffffffffc0200c2c:	00289613          	slli	a2,a7,0x2
ffffffffc0200c30:	9646                	add	a2,a2,a7
ffffffffc0200c32:	011587b3          	add	a5,a1,a7
ffffffffc0200c36:	060e                	slli	a2,a2,0x3
ffffffffc0200c38:	98be                	add	a7,a7,a5
ffffffffc0200c3a:	9672                	add	a2,a2,t3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c3c:	01863383          	ld	t2,24(a2)
ffffffffc0200c40:	02063283          	ld	t0,32(a2)
            allocate_area[begin].property >>= 1;
ffffffffc0200c44:	4a18                	lw	a4,16(a2)
            size_t mid = (begin + end) >> 1;
ffffffffc0200c46:	0018d893          	srli	a7,a7,0x1
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200c4a:	00289793          	slli	a5,a7,0x2
    prev->next = next;
ffffffffc0200c4e:	0053b423          	sd	t0,8(t2)
ffffffffc0200c52:	97c6                	add	a5,a5,a7
    next->prev = prev;
ffffffffc0200c54:	0072b023          	sd	t2,0(t0)
            allocate_area[begin].property >>= 1;
ffffffffc0200c58:	0017571b          	srliw	a4,a4,0x1
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200c5c:	078e                	slli	a5,a5,0x3
            allocate_area[begin].property >>= 1;
ffffffffc0200c5e:	ca18                	sw	a4,16(a2)
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200c60:	97f2                	add	a5,a5,t3
ffffffffc0200c62:	cb98                	sw	a4,16(a5)
            record_area[left] = record_area[block] >> 1;
ffffffffc0200c64:	8185                	srli	a1,a1,0x1
ffffffffc0200c66:	e28c                	sd	a1,0(a3)
            record_area[right] = record_area[block] >> 1;
ffffffffc0200c68:	00033703          	ld	a4,0(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c6c:	008f3883          	ld	a7,8(t5)
            list_add(&free_list, &(allocate_area[begin].page_link));
ffffffffc0200c70:	01860593          	addi	a1,a2,24
            record_area[right] = record_area[block] >> 1;
ffffffffc0200c74:	8305                	srli	a4,a4,0x1
ffffffffc0200c76:	e698                	sd	a4,8(a3)
    prev->next = next->prev = elm;
ffffffffc0200c78:	00b8b023          	sd	a1,0(a7)
            list_add(&free_list, &(allocate_area[mid].page_link));
ffffffffc0200c7c:	01878713          	addi	a4,a5,24
    elm->next = next;
ffffffffc0200c80:	03163023          	sd	a7,32(a2)
    prev->next = next->prev = elm;
ffffffffc0200c84:	ee18                	sd	a4,24(a2)
    elm->next = next;
ffffffffc0200c86:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0200c88:	01e7bc23          	sd	t5,24(a5)
    prev->next = next->prev = elm;
ffffffffc0200c8c:	00006617          	auipc	a2,0x6
ffffffffc0200c90:	80e63223          	sd	a4,-2044(a2) # ffffffffc0206490 <free_area+0x8>
            block = left;
ffffffffc0200c94:	628c                	ld	a1,0(a3)
        else if (length <= record_area[right])
ffffffffc0200c96:	87fe                	mv	a5,t6
ffffffffc0200c98:	bf85                	j	ffffffffc0200c08 <buddy_allocate_pages+0xd2>
ffffffffc0200c9a:	8672                	mv	a2,t3
ffffffffc0200c9c:	88ae                	mv	a7,a1
ffffffffc0200c9e:	bf79                	j	ffffffffc0200c3c <buddy_allocate_pages+0x106>
    page = &(allocate_area[NODE_BEGINNING(block)]);
ffffffffc0200ca0:	02e88733          	mul	a4,a7,a4
    nr_free -= length;
ffffffffc0200ca4:	00005697          	auipc	a3,0x5
ffffffffc0200ca8:	7e468693          	addi	a3,a3,2020 # ffffffffc0206488 <free_area>
ffffffffc0200cac:	4a94                	lw	a3,16(a3)
    while (block != TREE_ROOT)
ffffffffc0200cae:	4885                	li	a7,1
    nr_free -= length;
ffffffffc0200cb0:	9e89                	subw	a3,a3,a0
    page = &(allocate_area[NODE_BEGINNING(block)]);
ffffffffc0200cb2:	00271513          	slli	a0,a4,0x2
ffffffffc0200cb6:	972a                	add	a4,a4,a0
ffffffffc0200cb8:	00371513          	slli	a0,a4,0x3
ffffffffc0200cbc:	9572                	add	a0,a0,t3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200cbe:	7118                	ld	a4,32(a0)
ffffffffc0200cc0:	6d0c                	ld	a1,24(a0)
    prev->next = next;
ffffffffc0200cc2:	e598                	sd	a4,8(a1)
    next->prev = prev;
ffffffffc0200cc4:	e30c                	sd	a1,0(a4)
    record_area[block] = 0;
ffffffffc0200cc6:	00033023          	sd	zero,0(t1)
    nr_free -= length;
ffffffffc0200cca:	00005717          	auipc	a4,0x5
ffffffffc0200cce:	7cd72723          	sw	a3,1998(a4) # ffffffffc0206498 <free_area+0x10>
    while (block != TREE_ROOT)
ffffffffc0200cd2:	f51781e3          	beq	a5,a7,ffffffffc0200c14 <buddy_allocate_pages+0xde>
ffffffffc0200cd6:	4585                	li	a1,1
ffffffffc0200cd8:	a011                	j	ffffffffc0200cdc <buddy_allocate_pages+0x1a6>
ffffffffc0200cda:	8205                	srli	a2,a2,0x1
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc0200cdc:	00461793          	slli	a5,a2,0x4
ffffffffc0200ce0:	97c2                	add	a5,a5,a6
ffffffffc0200ce2:	6394                	ld	a3,0(a5)
ffffffffc0200ce4:	6798                	ld	a4,8(a5)
ffffffffc0200ce6:	00361793          	slli	a5,a2,0x3
ffffffffc0200cea:	97c2                	add	a5,a5,a6
ffffffffc0200cec:	8f55                	or	a4,a4,a3
ffffffffc0200cee:	e398                	sd	a4,0(a5)
    while (block != TREE_ROOT)
ffffffffc0200cf0:	feb615e3          	bne	a2,a1,ffffffffc0200cda <buddy_allocate_pages+0x1a4>
}
ffffffffc0200cf4:	8082                	ret
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200cf6:	fff7c793          	not	a5,a5
ffffffffc0200cfa:	8d7d                	and	a0,a0,a5
ffffffffc0200cfc:	0506                	slli	a0,a0,0x1
ffffffffc0200cfe:	b595                	j	ffffffffc0200b62 <buddy_allocate_pages+0x2c>
{
ffffffffc0200d00:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200d02:	00002697          	auipc	a3,0x2
ffffffffc0200d06:	aa668693          	addi	a3,a3,-1370 # ffffffffc02027a8 <commands+0x900>
ffffffffc0200d0a:	00002617          	auipc	a2,0x2
ffffffffc0200d0e:	aa660613          	addi	a2,a2,-1370 # ffffffffc02027b0 <commands+0x908>
ffffffffc0200d12:	07200593          	li	a1,114
ffffffffc0200d16:	00002517          	auipc	a0,0x2
ffffffffc0200d1a:	ab250513          	addi	a0,a0,-1358 # ffffffffc02027c8 <commands+0x920>
{
ffffffffc0200d1e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d20:	e88ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200d24 <buddy_init_memmap.part.2>:
    for (p = base; p < base + n; p++)
ffffffffc0200d24:	00259693          	slli	a3,a1,0x2
ffffffffc0200d28:	96ae                	add	a3,a3,a1
static void buddy_init_memmap(struct Page *base, size_t n)
ffffffffc0200d2a:	1141                	addi	sp,sp,-16
    for (p = base; p < base + n; p++)
ffffffffc0200d2c:	068e                	slli	a3,a3,0x3
static void buddy_init_memmap(struct Page *base, size_t n)
ffffffffc0200d2e:	e406                	sd	ra,8(sp)
    for (p = base; p < base + n; p++)
ffffffffc0200d30:	96aa                	add	a3,a3,a0
ffffffffc0200d32:	02d57363          	bgeu	a0,a3,ffffffffc0200d58 <buddy_init_memmap.part.2+0x34>
ffffffffc0200d36:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200d38:	87aa                	mv	a5,a0
ffffffffc0200d3a:	8b05                	andi	a4,a4,1
ffffffffc0200d3c:	e711                	bnez	a4,ffffffffc0200d48 <buddy_init_memmap.part.2+0x24>
ffffffffc0200d3e:	a609                	j	ffffffffc0201040 <buddy_init_memmap.part.2+0x31c>
ffffffffc0200d40:	6798                	ld	a4,8(a5)
ffffffffc0200d42:	8b05                	andi	a4,a4,1
ffffffffc0200d44:	2e070e63          	beqz	a4,ffffffffc0201040 <buddy_init_memmap.part.2+0x31c>
        p->flags = p->property = 0;
ffffffffc0200d48:	0007a823          	sw	zero,16(a5)
ffffffffc0200d4c:	0007b423          	sd	zero,8(a5)
    for (p = base; p < base + n; p++)
ffffffffc0200d50:	02878793          	addi	a5,a5,40
ffffffffc0200d54:	fed7e6e3          	bltu	a5,a3,ffffffffc0200d40 <buddy_init_memmap.part.2+0x1c>
    total_size = n;
ffffffffc0200d58:	00005797          	auipc	a5,0x5
ffffffffc0200d5c:	70b7b423          	sd	a1,1800(a5) # ffffffffc0206460 <total_size>
    if (n < 512)
ffffffffc0200d60:	1ff00793          	li	a5,511
ffffffffc0200d64:	06b7f163          	bgeu	a5,a1,ffffffffc0200dc6 <buddy_init_memmap.part.2+0xa2>
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200d68:	0015d793          	srli	a5,a1,0x1
ffffffffc0200d6c:	8fcd                	or	a5,a5,a1
ffffffffc0200d6e:	0027d713          	srli	a4,a5,0x2
ffffffffc0200d72:	8fd9                	or	a5,a5,a4
ffffffffc0200d74:	0047d713          	srli	a4,a5,0x4
ffffffffc0200d78:	8f5d                	or	a4,a4,a5
ffffffffc0200d7a:	00875793          	srli	a5,a4,0x8
ffffffffc0200d7e:	8f5d                	or	a4,a4,a5
ffffffffc0200d80:	01075793          	srli	a5,a4,0x10
ffffffffc0200d84:	8fd9                	or	a5,a5,a4
ffffffffc0200d86:	8385                	srli	a5,a5,0x1
ffffffffc0200d88:	00f5f6b3          	and	a3,a1,a5
ffffffffc0200d8c:	872e                	mv	a4,a1
ffffffffc0200d8e:	c689                	beqz	a3,ffffffffc0200d98 <buddy_init_memmap.part.2+0x74>
ffffffffc0200d90:	fff7c793          	not	a5,a5
ffffffffc0200d94:	00b7f733          	and	a4,a5,a1
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200d98:	00471693          	slli	a3,a4,0x4
ffffffffc0200d9c:	82b1                	srli	a3,a3,0xc
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0200d9e:	00169613          	slli	a2,a3,0x1
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200da2:	00005797          	auipc	a5,0x5
ffffffffc0200da6:	68e7bb23          	sd	a4,1686(a5) # ffffffffc0206438 <full_tree_size>
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200daa:	00005797          	auipc	a5,0x5
ffffffffc0200dae:	6ad7b723          	sd	a3,1710(a5) # ffffffffc0206458 <record_area_size>
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0200db2:	00c707b3          	add	a5,a4,a2
ffffffffc0200db6:	24b7ee63          	bltu	a5,a1,ffffffffc0201012 <buddy_init_memmap.part.2+0x2ee>
ffffffffc0200dba:	40d587b3          	sub	a5,a1,a3
ffffffffc0200dbe:	26f76b63          	bltu	a4,a5,ffffffffc0201034 <buddy_init_memmap.part.2+0x310>
ffffffffc0200dc2:	8636                	mv	a2,a3
ffffffffc0200dc4:	a0a9                	j	ffffffffc0200e0e <buddy_init_memmap.part.2+0xea>
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0200dc6:	15fd                	addi	a1,a1,-1
ffffffffc0200dc8:	0015d793          	srli	a5,a1,0x1
ffffffffc0200dcc:	00b7e733          	or	a4,a5,a1
ffffffffc0200dd0:	00275793          	srli	a5,a4,0x2
ffffffffc0200dd4:	8fd9                	or	a5,a5,a4
ffffffffc0200dd6:	0047d713          	srli	a4,a5,0x4
ffffffffc0200dda:	8fd9                	or	a5,a5,a4
ffffffffc0200ddc:	0087d713          	srli	a4,a5,0x8
ffffffffc0200de0:	8f5d                	or	a4,a4,a5
ffffffffc0200de2:	8305                	srli	a4,a4,0x1
ffffffffc0200de4:	00e5f6b3          	and	a3,a1,a4
ffffffffc0200de8:	87ae                	mv	a5,a1
ffffffffc0200dea:	ca81                	beqz	a3,ffffffffc0200dfa <buddy_init_memmap.part.2+0xd6>
ffffffffc0200dec:	fff74713          	not	a4,a4
ffffffffc0200df0:	8f6d                	and	a4,a4,a1
ffffffffc0200df2:	00171593          	slli	a1,a4,0x1
ffffffffc0200df6:	22f5ed63          	bltu	a1,a5,ffffffffc0201030 <buddy_init_memmap.part.2+0x30c>
ffffffffc0200dfa:	00005717          	auipc	a4,0x5
ffffffffc0200dfe:	62b73f23          	sd	a1,1598(a4) # ffffffffc0206438 <full_tree_size>
        record_area_size = 1;
ffffffffc0200e02:	4705                	li	a4,1
ffffffffc0200e04:	00005697          	auipc	a3,0x5
ffffffffc0200e08:	64e6ba23          	sd	a4,1620(a3) # ffffffffc0206458 <record_area_size>
ffffffffc0200e0c:	4605                	li	a2,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e0e:	00005717          	auipc	a4,0x5
ffffffffc0200e12:	6aa70713          	addi	a4,a4,1706 # ffffffffc02064b8 <pages>
ffffffffc0200e16:	6314                	ld	a3,0(a4)
ffffffffc0200e18:	00002717          	auipc	a4,0x2
ffffffffc0200e1c:	98870713          	addi	a4,a4,-1656 # ffffffffc02027a0 <commands+0x8f8>
ffffffffc0200e20:	6318                	ld	a4,0(a4)
ffffffffc0200e22:	40d506b3          	sub	a3,a0,a3
ffffffffc0200e26:	868d                	srai	a3,a3,0x3
ffffffffc0200e28:	02e686b3          	mul	a3,a3,a4
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200e2c:	00005817          	auipc	a6,0x5
ffffffffc0200e30:	60f83e23          	sd	a5,1564(a6) # ffffffffc0206448 <real_tree_size>
ffffffffc0200e34:	00002597          	auipc	a1,0x2
ffffffffc0200e38:	db458593          	addi	a1,a1,-588 # ffffffffc0202be8 <nbase>
    physical_area = base;
ffffffffc0200e3c:	00005797          	auipc	a5,0x5
ffffffffc0200e40:	60a7b223          	sd	a0,1540(a5) # ffffffffc0206440 <physical_area>
ffffffffc0200e44:	619c                	ld	a5,0(a1)
    record_area = KADDR(page2pa(base));
ffffffffc0200e46:	00005717          	auipc	a4,0x5
ffffffffc0200e4a:	62270713          	addi	a4,a4,1570 # ffffffffc0206468 <npage>
ffffffffc0200e4e:	6318                	ld	a4,0(a4)
ffffffffc0200e50:	96be                	add	a3,a3,a5
ffffffffc0200e52:	00c69793          	slli	a5,a3,0xc
ffffffffc0200e56:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e58:	06b2                	slli	a3,a3,0xc
ffffffffc0200e5a:	20e7f363          	bgeu	a5,a4,ffffffffc0201060 <buddy_init_memmap.part.2+0x33c>
ffffffffc0200e5e:	00005797          	auipc	a5,0x5
ffffffffc0200e62:	65278793          	addi	a5,a5,1618 # ffffffffc02064b0 <va_pa_offset>
ffffffffc0200e66:	6398                	ld	a4,0(a5)
    allocate_area = base + record_area_size;
ffffffffc0200e68:	00261793          	slli	a5,a2,0x2
ffffffffc0200e6c:	97b2                	add	a5,a5,a2
    record_area = KADDR(page2pa(base));
ffffffffc0200e6e:	96ba                	add	a3,a3,a4
    allocate_area = base + record_area_size;
ffffffffc0200e70:	078e                	slli	a5,a5,0x3
ffffffffc0200e72:	97aa                	add	a5,a5,a0
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0200e74:	0632                	slli	a2,a2,0xc
ffffffffc0200e76:	4581                	li	a1,0
ffffffffc0200e78:	8536                	mv	a0,a3
    record_area = KADDR(page2pa(base));
ffffffffc0200e7a:	00005717          	auipc	a4,0x5
ffffffffc0200e7e:	5cd73b23          	sd	a3,1494(a4) # ffffffffc0206450 <record_area>
    allocate_area = base + record_area_size;
ffffffffc0200e82:	00005717          	auipc	a4,0x5
ffffffffc0200e86:	5af73723          	sd	a5,1454(a4) # ffffffffc0206430 <allocate_area>
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0200e8a:	6e9000ef          	jal	ra,ffffffffc0201d72 <memset>
    nr_free += real_tree_size;
ffffffffc0200e8e:	00005797          	auipc	a5,0x5
ffffffffc0200e92:	5ba78793          	addi	a5,a5,1466 # ffffffffc0206448 <real_tree_size>
ffffffffc0200e96:	6394                	ld	a3,0(a5)
ffffffffc0200e98:	00005897          	auipc	a7,0x5
ffffffffc0200e9c:	5f088893          	addi	a7,a7,1520 # ffffffffc0206488 <free_area>
ffffffffc0200ea0:	0108a783          	lw	a5,16(a7)
    record_area = KADDR(page2pa(base));
ffffffffc0200ea4:	00005317          	auipc	t1,0x5
ffffffffc0200ea8:	5ac30313          	addi	t1,t1,1452 # ffffffffc0206450 <record_area>
    record_area[block] = real_subtree_size;
ffffffffc0200eac:	00033703          	ld	a4,0(t1)
    nr_free += real_tree_size;
ffffffffc0200eb0:	0006859b          	sext.w	a1,a3
ffffffffc0200eb4:	9fad                	addw	a5,a5,a1
ffffffffc0200eb6:	00005617          	auipc	a2,0x5
ffffffffc0200eba:	5ef62123          	sw	a5,1506(a2) # ffffffffc0206498 <free_area+0x10>
    size_t full_subtree_size = full_tree_size;
ffffffffc0200ebe:	00005e17          	auipc	t3,0x5
ffffffffc0200ec2:	57ae0e13          	addi	t3,t3,1402 # ffffffffc0206438 <full_tree_size>
    record_area[block] = real_subtree_size;
ffffffffc0200ec6:	e714                	sd	a3,8(a4)
    allocate_area = base + record_area_size;
ffffffffc0200ec8:	00005e97          	auipc	t4,0x5
ffffffffc0200ecc:	568e8e93          	addi	t4,t4,1384 # ffffffffc0206430 <allocate_area>
    size_t full_subtree_size = full_tree_size;
ffffffffc0200ed0:	000e3703          	ld	a4,0(t3)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200ed4:	12068063          	beqz	a3,ffffffffc0200ff4 <buddy_init_memmap.part.2+0x2d0>
ffffffffc0200ed8:	16e6f163          	bgeu	a3,a4,ffffffffc020103a <buddy_init_memmap.part.2+0x316>
    size_t block = TREE_ROOT;
ffffffffc0200edc:	4785                	li	a5,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ede:	4f09                	li	t5,2
        full_subtree_size >>= 1;
ffffffffc0200ee0:	00479613          	slli	a2,a5,0x4
ffffffffc0200ee4:	8305                	srli	a4,a4,0x1
        if (real_subtree_size > full_subtree_size)
ffffffffc0200ee6:	00860293          	addi	t0,a2,8
ffffffffc0200eea:	00179f93          	slli	t6,a5,0x1
ffffffffc0200eee:	10d77663          	bgeu	a4,a3,ffffffffc0200ffa <buddy_init_memmap.part.2+0x2d6>
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200ef2:	0017d513          	srli	a0,a5,0x1
ffffffffc0200ef6:	8d5d                	or	a0,a0,a5
ffffffffc0200ef8:	00255813          	srli	a6,a0,0x2
ffffffffc0200efc:	00a86533          	or	a0,a6,a0
ffffffffc0200f00:	00455813          	srli	a6,a0,0x4
ffffffffc0200f04:	00a86833          	or	a6,a6,a0
ffffffffc0200f08:	00885513          	srli	a0,a6,0x8
ffffffffc0200f0c:	01056833          	or	a6,a0,a6
ffffffffc0200f10:	01085513          	srli	a0,a6,0x10
ffffffffc0200f14:	01056533          	or	a0,a0,a6
ffffffffc0200f18:	8105                	srli	a0,a0,0x1
ffffffffc0200f1a:	00f573b3          	and	t2,a0,a5
ffffffffc0200f1e:	000eb583          	ld	a1,0(t4)
ffffffffc0200f22:	000e3803          	ld	a6,0(t3)
ffffffffc0200f26:	00038563          	beqz	t2,ffffffffc0200f30 <buddy_init_memmap.part.2+0x20c>
ffffffffc0200f2a:	fff54513          	not	a0,a0
ffffffffc0200f2e:	8fe9                	and	a5,a5,a0
ffffffffc0200f30:	02f857b3          	divu	a5,a6,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f34:	0088b803          	ld	a6,8(a7)
ffffffffc0200f38:	027787b3          	mul	a5,a5,t2
ffffffffc0200f3c:	00279513          	slli	a0,a5,0x2
ffffffffc0200f40:	97aa                	add	a5,a5,a0
ffffffffc0200f42:	078e                	slli	a5,a5,0x3
ffffffffc0200f44:	97ae                	add	a5,a5,a1
            list_add(&(free_list), &(page->page_link));
ffffffffc0200f46:	01878593          	addi	a1,a5,24
            page->property = full_subtree_size;
ffffffffc0200f4a:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200f4c:	00b83023          	sd	a1,0(a6)
ffffffffc0200f50:	00005517          	auipc	a0,0x5
ffffffffc0200f54:	54b53023          	sd	a1,1344(a0) # ffffffffc0206490 <free_area+0x8>
    elm->next = next;
ffffffffc0200f58:	0307b023          	sd	a6,32(a5)
    elm->prev = prev;
ffffffffc0200f5c:	0117bc23          	sd	a7,24(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f60:	0007a023          	sw	zero,0(a5)
ffffffffc0200f64:	07a1                	addi	a5,a5,8
ffffffffc0200f66:	41e7b02f          	amoor.d	zero,t5,(a5)
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0200f6a:	00033583          	ld	a1,0(t1)
            real_subtree_size -= full_subtree_size;
ffffffffc0200f6e:	8e99                	sub	a3,a3,a4
            block = RIGHT_CHILD(block);
ffffffffc0200f70:	001f8793          	addi	a5,t6,1
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0200f74:	962e                	add	a2,a2,a1
ffffffffc0200f76:	e218                	sd	a4,0(a2)
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
ffffffffc0200f78:	9596                	add	a1,a1,t0
ffffffffc0200f7a:	e194                	sd	a3,0(a1)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0200f7c:	f6e6e2e3          	bltu	a3,a4,ffffffffc0200ee0 <buddy_init_memmap.part.2+0x1bc>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0200f80:	0017d613          	srli	a2,a5,0x1
ffffffffc0200f84:	8e5d                	or	a2,a2,a5
ffffffffc0200f86:	00265713          	srli	a4,a2,0x2
ffffffffc0200f8a:	8e59                	or	a2,a2,a4
ffffffffc0200f8c:	00465713          	srli	a4,a2,0x4
ffffffffc0200f90:	8f51                	or	a4,a4,a2
ffffffffc0200f92:	00875613          	srli	a2,a4,0x8
ffffffffc0200f96:	8f51                	or	a4,a4,a2
ffffffffc0200f98:	01075613          	srli	a2,a4,0x10
ffffffffc0200f9c:	8e59                	or	a2,a2,a4
ffffffffc0200f9e:	8205                	srli	a2,a2,0x1
ffffffffc0200fa0:	00f67833          	and	a6,a2,a5
ffffffffc0200fa4:	000eb703          	ld	a4,0(t4)
ffffffffc0200fa8:	000e3503          	ld	a0,0(t3)
ffffffffc0200fac:	0006859b          	sext.w	a1,a3
ffffffffc0200fb0:	00080e63          	beqz	a6,ffffffffc0200fcc <buddy_init_memmap.part.2+0x2a8>
ffffffffc0200fb4:	fff64613          	not	a2,a2
ffffffffc0200fb8:	8ff1                	and	a5,a5,a2
ffffffffc0200fba:	02f557b3          	divu	a5,a0,a5
ffffffffc0200fbe:	030787b3          	mul	a5,a5,a6
ffffffffc0200fc2:	00279693          	slli	a3,a5,0x2
ffffffffc0200fc6:	97b6                	add	a5,a5,a3
ffffffffc0200fc8:	078e                	slli	a5,a5,0x3
ffffffffc0200fca:	973e                	add	a4,a4,a5
        page->property = real_subtree_size;
ffffffffc0200fcc:	cb0c                	sw	a1,16(a4)
ffffffffc0200fce:	00072023          	sw	zero,0(a4)
ffffffffc0200fd2:	4789                	li	a5,2
ffffffffc0200fd4:	00870693          	addi	a3,a4,8
ffffffffc0200fd8:	40f6b02f          	amoor.d	zero,a5,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200fdc:	0088b783          	ld	a5,8(a7)
        list_add(&(free_list), &(page->page_link));
ffffffffc0200fe0:	01870693          	addi	a3,a4,24
    prev->next = next->prev = elm;
ffffffffc0200fe4:	e394                	sd	a3,0(a5)
ffffffffc0200fe6:	00005617          	auipc	a2,0x5
ffffffffc0200fea:	4ad63523          	sd	a3,1194(a2) # ffffffffc0206490 <free_area+0x8>
    elm->next = next;
ffffffffc0200fee:	f31c                	sd	a5,32(a4)
    elm->prev = prev;
ffffffffc0200ff0:	01173c23          	sd	a7,24(a4)
}
ffffffffc0200ff4:	60a2                	ld	ra,8(sp)
ffffffffc0200ff6:	0141                	addi	sp,sp,16
ffffffffc0200ff8:	8082                	ret
            record_area[LEFT_CHILD(block)] = real_subtree_size;
ffffffffc0200ffa:	00033783          	ld	a5,0(t1)
ffffffffc0200ffe:	963e                	add	a2,a2,a5
ffffffffc0201000:	e214                	sd	a3,0(a2)
            record_area[RIGHT_CHILD(block)] = 0;
ffffffffc0201002:	9796                	add	a5,a5,t0
ffffffffc0201004:	0007b023          	sd	zero,0(a5)
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc0201008:	d6f5                	beqz	a3,ffffffffc0200ff4 <buddy_init_memmap.part.2+0x2d0>
            block = LEFT_CHILD(block);
ffffffffc020100a:	87fe                	mv	a5,t6
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
ffffffffc020100c:	ece6eae3          	bltu	a3,a4,ffffffffc0200ee0 <buddy_init_memmap.part.2+0x1bc>
ffffffffc0201010:	bf85                	j	ffffffffc0200f80 <buddy_init_memmap.part.2+0x25c>
            full_tree_size <<= 1;
ffffffffc0201012:	0706                	slli	a4,a4,0x1
ffffffffc0201014:	00005797          	auipc	a5,0x5
ffffffffc0201018:	42e7b223          	sd	a4,1060(a5) # ffffffffc0206438 <full_tree_size>
            record_area_size <<= 1;
ffffffffc020101c:	00005797          	auipc	a5,0x5
ffffffffc0201020:	42c7be23          	sd	a2,1084(a5) # ffffffffc0206458 <record_area_size>
ffffffffc0201024:	40c587b3          	sub	a5,a1,a2
ffffffffc0201028:	def773e3          	bgeu	a4,a5,ffffffffc0200e0e <buddy_init_memmap.part.2+0xea>
ffffffffc020102c:	87ba                	mv	a5,a4
ffffffffc020102e:	b3c5                	j	ffffffffc0200e0e <buddy_init_memmap.part.2+0xea>
ffffffffc0201030:	87ae                	mv	a5,a1
ffffffffc0201032:	b3e1                	j	ffffffffc0200dfa <buddy_init_memmap.part.2+0xd6>
ffffffffc0201034:	87ba                	mv	a5,a4
        if (n > full_tree_size + (record_area_size << 1))
ffffffffc0201036:	8636                	mv	a2,a3
ffffffffc0201038:	bbd9                	j	ffffffffc0200e0e <buddy_init_memmap.part.2+0xea>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc020103a:	000eb703          	ld	a4,0(t4)
ffffffffc020103e:	b779                	j	ffffffffc0200fcc <buddy_init_memmap.part.2+0x2a8>
        assert(PageReserved(p));
ffffffffc0201040:	00001697          	auipc	a3,0x1
ffffffffc0201044:	7b068693          	addi	a3,a3,1968 # ffffffffc02027f0 <commands+0x948>
ffffffffc0201048:	00001617          	auipc	a2,0x1
ffffffffc020104c:	76860613          	addi	a2,a2,1896 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201050:	02f00593          	li	a1,47
ffffffffc0201054:	00001517          	auipc	a0,0x1
ffffffffc0201058:	77450513          	addi	a0,a0,1908 # ffffffffc02027c8 <commands+0x920>
ffffffffc020105c:	b4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    record_area = KADDR(page2pa(base));
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	7a060613          	addi	a2,a2,1952 # ffffffffc0202800 <commands+0x958>
ffffffffc0201068:	04500593          	li	a1,69
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	75c50513          	addi	a0,a0,1884 # ffffffffc02027c8 <commands+0x920>
ffffffffc0201074:	b34ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201078 <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0201078:	c191                	beqz	a1,ffffffffc020107c <buddy_init_memmap+0x4>
ffffffffc020107a:	b16d                	j	ffffffffc0200d24 <buddy_init_memmap.part.2>
{
ffffffffc020107c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020107e:	00001697          	auipc	a3,0x1
ffffffffc0201082:	72a68693          	addi	a3,a3,1834 # ffffffffc02027a8 <commands+0x900>
ffffffffc0201086:	00001617          	auipc	a2,0x1
ffffffffc020108a:	72a60613          	addi	a2,a2,1834 # ffffffffc02027b0 <commands+0x908>
ffffffffc020108e:	02b00593          	li	a1,43
ffffffffc0201092:	00001517          	auipc	a0,0x1
ffffffffc0201096:	73650513          	addi	a0,a0,1846 # ffffffffc02027c8 <commands+0x920>
{
ffffffffc020109a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020109c:	b0cff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02010a0 <alloc_check>:

static void alloc_check(void)
{
ffffffffc02010a0:	715d                	addi	sp,sp,-80
    size_t total_size_store = total_size;
ffffffffc02010a2:	00005797          	auipc	a5,0x5
ffffffffc02010a6:	3be78793          	addi	a5,a5,958 # ffffffffc0206460 <total_size>
{
ffffffffc02010aa:	f84a                	sd	s2,48(sp)
    struct Page *p;
    for (p = physical_area; p < physical_area + 1026; p++)
ffffffffc02010ac:	00005917          	auipc	s2,0x5
ffffffffc02010b0:	39490913          	addi	s2,s2,916 # ffffffffc0206440 <physical_area>
{
ffffffffc02010b4:	f44e                	sd	s3,40(sp)
    size_t total_size_store = total_size;
ffffffffc02010b6:	0007b983          	ld	s3,0(a5)
    for (p = physical_area; p < physical_area + 1026; p++)
ffffffffc02010ba:	00093783          	ld	a5,0(s2)
ffffffffc02010be:	66a9                	lui	a3,0xa
{
ffffffffc02010c0:	e486                	sd	ra,72(sp)
ffffffffc02010c2:	e0a2                	sd	s0,64(sp)
ffffffffc02010c4:	fc26                	sd	s1,56(sp)
ffffffffc02010c6:	f052                	sd	s4,32(sp)
ffffffffc02010c8:	ec56                	sd	s5,24(sp)
ffffffffc02010ca:	e85a                	sd	s6,16(sp)
ffffffffc02010cc:	e45e                	sd	s7,8(sp)
ffffffffc02010ce:	4605                	li	a2,1
    for (p = physical_area; p < physical_area + 1026; p++)
ffffffffc02010d0:	05068693          	addi	a3,a3,80 # a050 <BASE_ADDRESS-0xffffffffc01f5fb0>
ffffffffc02010d4:	00878713          	addi	a4,a5,8
ffffffffc02010d8:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc02010dc:	00093503          	ld	a0,0(s2)
ffffffffc02010e0:	02878793          	addi	a5,a5,40
ffffffffc02010e4:	00d50733          	add	a4,a0,a3
ffffffffc02010e8:	fee7e6e3          	bltu	a5,a4,ffffffffc02010d4 <alloc_check+0x34>
    elm->prev = elm->next = elm;
ffffffffc02010ec:	00005497          	auipc	s1,0x5
ffffffffc02010f0:	39c48493          	addi	s1,s1,924 # ffffffffc0206488 <free_area>
ffffffffc02010f4:	40200593          	li	a1,1026
ffffffffc02010f8:	00005797          	auipc	a5,0x5
ffffffffc02010fc:	3897bc23          	sd	s1,920(a5) # ffffffffc0206490 <free_area+0x8>
ffffffffc0201100:	00005797          	auipc	a5,0x5
ffffffffc0201104:	3897b423          	sd	s1,904(a5) # ffffffffc0206488 <free_area>
    nr_free = 0;
ffffffffc0201108:	00005797          	auipc	a5,0x5
ffffffffc020110c:	3807a823          	sw	zero,912(a5) # ffffffffc0206498 <free_area+0x10>
    assert(n > 0);
ffffffffc0201110:	c15ff0ef          	jal	ra,ffffffffc0200d24 <buddy_init_memmap.part.2>
    buddy_init();
    buddy_init_memmap(physical_area, 1026);

    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	49a000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc020111a:	8a2a                	mv	s4,a0
ffffffffc020111c:	38050a63          	beqz	a0,ffffffffc02014b0 <alloc_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201120:	4505                	li	a0,1
ffffffffc0201122:	48e000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201126:	8b2a                	mv	s6,a0
ffffffffc0201128:	26050463          	beqz	a0,ffffffffc0201390 <alloc_check+0x2f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020112c:	4505                	li	a0,1
ffffffffc020112e:	482000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201132:	8aaa                	mv	s5,a0
ffffffffc0201134:	22050e63          	beqz	a0,ffffffffc0201370 <alloc_check+0x2d0>
    assert((p3 = alloc_page()) != NULL);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	476000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc020113e:	8baa                	mv	s7,a0
ffffffffc0201140:	20050863          	beqz	a0,ffffffffc0201350 <alloc_check+0x2b0>

    assert(p0 + 1 == p1);
ffffffffc0201144:	028a0793          	addi	a5,s4,40
ffffffffc0201148:	1efb1463          	bne	s6,a5,ffffffffc0201330 <alloc_check+0x290>
    assert(p1 + 1 == p2);
ffffffffc020114c:	050a0793          	addi	a5,s4,80
ffffffffc0201150:	26fa9063          	bne	s5,a5,ffffffffc02013b0 <alloc_check+0x310>
    assert(p2 + 1 == p3);
ffffffffc0201154:	078a0793          	addi	a5,s4,120
ffffffffc0201158:	40f51c63          	bne	a0,a5,ffffffffc0201570 <alloc_check+0x4d0>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc020115c:	000a2783          	lw	a5,0(s4)
ffffffffc0201160:	1a079863          	bnez	a5,ffffffffc0201310 <alloc_check+0x270>
ffffffffc0201164:	000b2783          	lw	a5,0(s6)
ffffffffc0201168:	1a079463          	bnez	a5,ffffffffc0201310 <alloc_check+0x270>
ffffffffc020116c:	000aa783          	lw	a5,0(s5)
ffffffffc0201170:	1a079063          	bnez	a5,ffffffffc0201310 <alloc_check+0x270>
ffffffffc0201174:	411c                	lw	a5,0(a0)
ffffffffc0201176:	18079d63          	bnez	a5,ffffffffc0201310 <alloc_check+0x270>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020117a:	00005797          	auipc	a5,0x5
ffffffffc020117e:	33e78793          	addi	a5,a5,830 # ffffffffc02064b8 <pages>
ffffffffc0201182:	639c                	ld	a5,0(a5)
ffffffffc0201184:	00001717          	auipc	a4,0x1
ffffffffc0201188:	61c70713          	addi	a4,a4,1564 # ffffffffc02027a0 <commands+0x8f8>
ffffffffc020118c:	630c                	ld	a1,0(a4)
ffffffffc020118e:	40fa0733          	sub	a4,s4,a5
ffffffffc0201192:	870d                	srai	a4,a4,0x3
ffffffffc0201194:	02b70733          	mul	a4,a4,a1
ffffffffc0201198:	00002697          	auipc	a3,0x2
ffffffffc020119c:	a5068693          	addi	a3,a3,-1456 # ffffffffc0202be8 <nbase>
ffffffffc02011a0:	6290                	ld	a2,0(a3)

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011a2:	00005697          	auipc	a3,0x5
ffffffffc02011a6:	2c668693          	addi	a3,a3,710 # ffffffffc0206468 <npage>
ffffffffc02011aa:	6294                	ld	a3,0(a3)
ffffffffc02011ac:	06b2                	slli	a3,a3,0xc
ffffffffc02011ae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011b0:	0732                	slli	a4,a4,0xc
ffffffffc02011b2:	2ad77f63          	bgeu	a4,a3,ffffffffc0201470 <alloc_check+0x3d0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02011b6:	40fb0733          	sub	a4,s6,a5
ffffffffc02011ba:	870d                	srai	a4,a4,0x3
ffffffffc02011bc:	02b70733          	mul	a4,a4,a1
ffffffffc02011c0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011c2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011c4:	28d77663          	bgeu	a4,a3,ffffffffc0201450 <alloc_check+0x3b0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02011c8:	40fa8733          	sub	a4,s5,a5
ffffffffc02011cc:	870d                	srai	a4,a4,0x3
ffffffffc02011ce:	02b70733          	mul	a4,a4,a1
ffffffffc02011d2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011d4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011d6:	1ed77d63          	bgeu	a4,a3,ffffffffc02013d0 <alloc_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02011da:	40f507b3          	sub	a5,a0,a5
ffffffffc02011de:	878d                	srai	a5,a5,0x3
ffffffffc02011e0:	02b787b3          	mul	a5,a5,a1
    assert(page2pa(p3) < npage * PGSIZE);

    list_entry_t *le = &free_list;
ffffffffc02011e4:	00005417          	auipc	s0,0x5
ffffffffc02011e8:	2a440413          	addi	s0,s0,676 # ffffffffc0206488 <free_area>
ffffffffc02011ec:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011ee:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p3) < npage * PGSIZE);
ffffffffc02011f0:	00d7e963          	bltu	a5,a3,ffffffffc0201202 <alloc_check+0x162>
ffffffffc02011f4:	ac31                	j	ffffffffc0201410 <alloc_check+0x370>
    while ((le = list_next(le)) != &free_list)
    {
        p = le2page(le, page_link);
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02011f6:	ff846503          	lwu	a0,-8(s0)
ffffffffc02011fa:	93dff0ef          	jal	ra,ffffffffc0200b36 <buddy_allocate_pages>
ffffffffc02011fe:	0e050963          	beqz	a0,ffffffffc02012f0 <alloc_check+0x250>
    return listelm->next;
ffffffffc0201202:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201204:	fe9419e3          	bne	s0,s1,ffffffffc02011f6 <alloc_check+0x156>
    }

    assert(alloc_page() == NULL);
ffffffffc0201208:	4505                	li	a0,1
ffffffffc020120a:	3a6000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc020120e:	34051163          	bnez	a0,ffffffffc0201550 <alloc_check+0x4b0>

    free_page(p0);
ffffffffc0201212:	4585                	li	a1,1
ffffffffc0201214:	8552                	mv	a0,s4
ffffffffc0201216:	3de000ef          	jal	ra,ffffffffc02015f4 <free_pages>
    free_page(p1);
ffffffffc020121a:	4585                	li	a1,1
ffffffffc020121c:	855a                	mv	a0,s6
ffffffffc020121e:	3d6000ef          	jal	ra,ffffffffc02015f4 <free_pages>
    free_page(p2);
ffffffffc0201222:	4585                	li	a1,1
ffffffffc0201224:	8556                	mv	a0,s5
ffffffffc0201226:	3ce000ef          	jal	ra,ffffffffc02015f4 <free_pages>
    assert(nr_free == 3);
ffffffffc020122a:	4818                	lw	a4,16(s0)
ffffffffc020122c:	478d                	li	a5,3
ffffffffc020122e:	1cf71163          	bne	a4,a5,ffffffffc02013f0 <alloc_check+0x350>

    assert((p1 = alloc_page()) != NULL);
ffffffffc0201232:	4505                	li	a0,1
ffffffffc0201234:	37c000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201238:	8a2a                	mv	s4,a0
ffffffffc020123a:	24050b63          	beqz	a0,ffffffffc0201490 <alloc_check+0x3f0>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc020123e:	4509                	li	a0,2
ffffffffc0201240:	370000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201244:	842a                	mv	s0,a0
ffffffffc0201246:	2e050563          	beqz	a0,ffffffffc0201530 <alloc_check+0x490>
    assert(p0 + 2 == p1);
ffffffffc020124a:	05050793          	addi	a5,a0,80
ffffffffc020124e:	2cfa1163          	bne	s4,a5,ffffffffc0201510 <alloc_check+0x470>

    assert(alloc_page() == NULL);
ffffffffc0201252:	4505                	li	a0,1
ffffffffc0201254:	35c000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201258:	1c051c63          	bnez	a0,ffffffffc0201430 <alloc_check+0x390>

    free_pages(p0, 2);
ffffffffc020125c:	4589                	li	a1,2
ffffffffc020125e:	8522                	mv	a0,s0
ffffffffc0201260:	394000ef          	jal	ra,ffffffffc02015f4 <free_pages>
    free_page(p1);
ffffffffc0201264:	4585                	li	a1,1
ffffffffc0201266:	8552                	mv	a0,s4
ffffffffc0201268:	38c000ef          	jal	ra,ffffffffc02015f4 <free_pages>
    free_page(p3);
ffffffffc020126c:	855e                	mv	a0,s7
ffffffffc020126e:	4585                	li	a1,1
ffffffffc0201270:	384000ef          	jal	ra,ffffffffc02015f4 <free_pages>

    assert((p = alloc_pages(4)) == p0);
ffffffffc0201274:	4511                	li	a0,4
ffffffffc0201276:	33a000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc020127a:	30a41b63          	bne	s0,a0,ffffffffc0201590 <alloc_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc020127e:	4505                	li	a0,1
ffffffffc0201280:	330000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201284:	26051663          	bnez	a0,ffffffffc02014f0 <alloc_check+0x450>

    assert(nr_free == 0);
ffffffffc0201288:	489c                	lw	a5,16(s1)
ffffffffc020128a:	24079363          	bnez	a5,ffffffffc02014d0 <alloc_check+0x430>

    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc020128e:	00093783          	ld	a5,0(s2)
ffffffffc0201292:	00299693          	slli	a3,s3,0x2
ffffffffc0201296:	96ce                	add	a3,a3,s3
ffffffffc0201298:	068e                	slli	a3,a3,0x3
ffffffffc020129a:	00d78733          	add	a4,a5,a3
ffffffffc020129e:	04e7f763          	bgeu	a5,a4,ffffffffc02012ec <alloc_check+0x24c>
ffffffffc02012a2:	4605                	li	a2,1
ffffffffc02012a4:	00878713          	addi	a4,a5,8
ffffffffc02012a8:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc02012ac:	00093503          	ld	a0,0(s2)
ffffffffc02012b0:	02878793          	addi	a5,a5,40
ffffffffc02012b4:	00d50733          	add	a4,a0,a3
ffffffffc02012b8:	fee7e6e3          	bltu	a5,a4,ffffffffc02012a4 <alloc_check+0x204>
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(physical_area, total_size_store);
}
ffffffffc02012bc:	6406                	ld	s0,64(sp)
    elm->prev = elm->next = elm;
ffffffffc02012be:	00005797          	auipc	a5,0x5
ffffffffc02012c2:	1c97b923          	sd	s1,466(a5) # ffffffffc0206490 <free_area+0x8>
ffffffffc02012c6:	00005797          	auipc	a5,0x5
ffffffffc02012ca:	1c97b123          	sd	s1,450(a5) # ffffffffc0206488 <free_area>
ffffffffc02012ce:	60a6                	ld	ra,72(sp)
ffffffffc02012d0:	74e2                	ld	s1,56(sp)
ffffffffc02012d2:	7942                	ld	s2,48(sp)
ffffffffc02012d4:	7a02                	ld	s4,32(sp)
ffffffffc02012d6:	6ae2                	ld	s5,24(sp)
ffffffffc02012d8:	6b42                	ld	s6,16(sp)
ffffffffc02012da:	6ba2                	ld	s7,8(sp)
    buddy_init_memmap(physical_area, total_size_store);
ffffffffc02012dc:	85ce                	mv	a1,s3
}
ffffffffc02012de:	79a2                	ld	s3,40(sp)
    nr_free = 0;
ffffffffc02012e0:	00005797          	auipc	a5,0x5
ffffffffc02012e4:	1a07ac23          	sw	zero,440(a5) # ffffffffc0206498 <free_area+0x10>
}
ffffffffc02012e8:	6161                	addi	sp,sp,80
    buddy_init_memmap(physical_area, total_size_store);
ffffffffc02012ea:	b379                	j	ffffffffc0201078 <buddy_init_memmap>
    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc02012ec:	853e                	mv	a0,a5
ffffffffc02012ee:	b7f9                	j	ffffffffc02012bc <alloc_check+0x21c>
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02012f0:	00001697          	auipc	a3,0x1
ffffffffc02012f4:	3f868693          	addi	a3,a3,1016 # ffffffffc02026e8 <commands+0x840>
ffffffffc02012f8:	00001617          	auipc	a2,0x1
ffffffffc02012fc:	4b860613          	addi	a2,a2,1208 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201300:	0ec00593          	li	a1,236
ffffffffc0201304:	00001517          	auipc	a0,0x1
ffffffffc0201308:	4c450513          	addi	a0,a0,1220 # ffffffffc02027c8 <commands+0x920>
ffffffffc020130c:	89cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc0201310:	00001697          	auipc	a3,0x1
ffffffffc0201314:	30068693          	addi	a3,a3,768 # ffffffffc0202610 <commands+0x768>
ffffffffc0201318:	00001617          	auipc	a2,0x1
ffffffffc020131c:	49860613          	addi	a2,a2,1176 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201320:	0e100593          	li	a1,225
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	4a450513          	addi	a0,a0,1188 # ffffffffc02027c8 <commands+0x920>
ffffffffc020132c:	87cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 1 == p1);
ffffffffc0201330:	00001697          	auipc	a3,0x1
ffffffffc0201334:	2b068693          	addi	a3,a3,688 # ffffffffc02025e0 <commands+0x738>
ffffffffc0201338:	00001617          	auipc	a2,0x1
ffffffffc020133c:	47860613          	addi	a2,a2,1144 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201340:	0de00593          	li	a1,222
ffffffffc0201344:	00001517          	auipc	a0,0x1
ffffffffc0201348:	48450513          	addi	a0,a0,1156 # ffffffffc02027c8 <commands+0x920>
ffffffffc020134c:	85cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p3 = alloc_page()) != NULL);
ffffffffc0201350:	00001697          	auipc	a3,0x1
ffffffffc0201354:	27068693          	addi	a3,a3,624 # ffffffffc02025c0 <commands+0x718>
ffffffffc0201358:	00001617          	auipc	a2,0x1
ffffffffc020135c:	45860613          	addi	a2,a2,1112 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201360:	0dc00593          	li	a1,220
ffffffffc0201364:	00001517          	auipc	a0,0x1
ffffffffc0201368:	46450513          	addi	a0,a0,1124 # ffffffffc02027c8 <commands+0x920>
ffffffffc020136c:	83cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201370:	00001697          	auipc	a3,0x1
ffffffffc0201374:	23068693          	addi	a3,a3,560 # ffffffffc02025a0 <commands+0x6f8>
ffffffffc0201378:	00001617          	auipc	a2,0x1
ffffffffc020137c:	43860613          	addi	a2,a2,1080 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201380:	0db00593          	li	a1,219
ffffffffc0201384:	00001517          	auipc	a0,0x1
ffffffffc0201388:	44450513          	addi	a0,a0,1092 # ffffffffc02027c8 <commands+0x920>
ffffffffc020138c:	81cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201390:	00001697          	auipc	a3,0x1
ffffffffc0201394:	1f068693          	addi	a3,a3,496 # ffffffffc0202580 <commands+0x6d8>
ffffffffc0201398:	00001617          	auipc	a2,0x1
ffffffffc020139c:	41860613          	addi	a2,a2,1048 # ffffffffc02027b0 <commands+0x908>
ffffffffc02013a0:	0da00593          	li	a1,218
ffffffffc02013a4:	00001517          	auipc	a0,0x1
ffffffffc02013a8:	42450513          	addi	a0,a0,1060 # ffffffffc02027c8 <commands+0x920>
ffffffffc02013ac:	ffdfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p1 + 1 == p2);
ffffffffc02013b0:	00001697          	auipc	a3,0x1
ffffffffc02013b4:	24068693          	addi	a3,a3,576 # ffffffffc02025f0 <commands+0x748>
ffffffffc02013b8:	00001617          	auipc	a2,0x1
ffffffffc02013bc:	3f860613          	addi	a2,a2,1016 # ffffffffc02027b0 <commands+0x908>
ffffffffc02013c0:	0df00593          	li	a1,223
ffffffffc02013c4:	00001517          	auipc	a0,0x1
ffffffffc02013c8:	40450513          	addi	a0,a0,1028 # ffffffffc02027c8 <commands+0x920>
ffffffffc02013cc:	fddfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013d0:	00001697          	auipc	a3,0x1
ffffffffc02013d4:	2d868693          	addi	a3,a3,728 # ffffffffc02026a8 <commands+0x800>
ffffffffc02013d8:	00001617          	auipc	a2,0x1
ffffffffc02013dc:	3d860613          	addi	a2,a2,984 # ffffffffc02027b0 <commands+0x908>
ffffffffc02013e0:	0e500593          	li	a1,229
ffffffffc02013e4:	00001517          	auipc	a0,0x1
ffffffffc02013e8:	3e450513          	addi	a0,a0,996 # ffffffffc02027c8 <commands+0x920>
ffffffffc02013ec:	fbdfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 3);
ffffffffc02013f0:	00001697          	auipc	a3,0x1
ffffffffc02013f4:	34068693          	addi	a3,a3,832 # ffffffffc0202730 <commands+0x888>
ffffffffc02013f8:	00001617          	auipc	a2,0x1
ffffffffc02013fc:	3b860613          	addi	a2,a2,952 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201400:	0f400593          	li	a1,244
ffffffffc0201404:	00001517          	auipc	a0,0x1
ffffffffc0201408:	3c450513          	addi	a0,a0,964 # ffffffffc02027c8 <commands+0x920>
ffffffffc020140c:	f9dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p3) < npage * PGSIZE);
ffffffffc0201410:	00001697          	auipc	a3,0x1
ffffffffc0201414:	2b868693          	addi	a3,a3,696 # ffffffffc02026c8 <commands+0x820>
ffffffffc0201418:	00001617          	auipc	a2,0x1
ffffffffc020141c:	39860613          	addi	a2,a2,920 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201420:	0e600593          	li	a1,230
ffffffffc0201424:	00001517          	auipc	a0,0x1
ffffffffc0201428:	3a450513          	addi	a0,a0,932 # ffffffffc02027c8 <commands+0x920>
ffffffffc020142c:	f7dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201430:	00001697          	auipc	a3,0x1
ffffffffc0201434:	2e868693          	addi	a3,a3,744 # ffffffffc0202718 <commands+0x870>
ffffffffc0201438:	00001617          	auipc	a2,0x1
ffffffffc020143c:	37860613          	addi	a2,a2,888 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201440:	0fa00593          	li	a1,250
ffffffffc0201444:	00001517          	auipc	a0,0x1
ffffffffc0201448:	38450513          	addi	a0,a0,900 # ffffffffc02027c8 <commands+0x920>
ffffffffc020144c:	f5dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201450:	00001697          	auipc	a3,0x1
ffffffffc0201454:	23868693          	addi	a3,a3,568 # ffffffffc0202688 <commands+0x7e0>
ffffffffc0201458:	00001617          	auipc	a2,0x1
ffffffffc020145c:	35860613          	addi	a2,a2,856 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201460:	0e400593          	li	a1,228
ffffffffc0201464:	00001517          	auipc	a0,0x1
ffffffffc0201468:	36450513          	addi	a0,a0,868 # ffffffffc02027c8 <commands+0x920>
ffffffffc020146c:	f3dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201470:	00001697          	auipc	a3,0x1
ffffffffc0201474:	1f868693          	addi	a3,a3,504 # ffffffffc0202668 <commands+0x7c0>
ffffffffc0201478:	00001617          	auipc	a2,0x1
ffffffffc020147c:	33860613          	addi	a2,a2,824 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201480:	0e300593          	li	a1,227
ffffffffc0201484:	00001517          	auipc	a0,0x1
ffffffffc0201488:	34450513          	addi	a0,a0,836 # ffffffffc02027c8 <commands+0x920>
ffffffffc020148c:	f1dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201490:	00001697          	auipc	a3,0x1
ffffffffc0201494:	0f068693          	addi	a3,a3,240 # ffffffffc0202580 <commands+0x6d8>
ffffffffc0201498:	00001617          	auipc	a2,0x1
ffffffffc020149c:	31860613          	addi	a2,a2,792 # ffffffffc02027b0 <commands+0x908>
ffffffffc02014a0:	0f600593          	li	a1,246
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	32450513          	addi	a0,a0,804 # ffffffffc02027c8 <commands+0x920>
ffffffffc02014ac:	efdfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014b0:	00001697          	auipc	a3,0x1
ffffffffc02014b4:	0b068693          	addi	a3,a3,176 # ffffffffc0202560 <commands+0x6b8>
ffffffffc02014b8:	00001617          	auipc	a2,0x1
ffffffffc02014bc:	2f860613          	addi	a2,a2,760 # ffffffffc02027b0 <commands+0x908>
ffffffffc02014c0:	0d900593          	li	a1,217
ffffffffc02014c4:	00001517          	auipc	a0,0x1
ffffffffc02014c8:	30450513          	addi	a0,a0,772 # ffffffffc02027c8 <commands+0x920>
ffffffffc02014cc:	eddfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc02014d0:	00001697          	auipc	a3,0x1
ffffffffc02014d4:	2c068693          	addi	a3,a3,704 # ffffffffc0202790 <commands+0x8e8>
ffffffffc02014d8:	00001617          	auipc	a2,0x1
ffffffffc02014dc:	2d860613          	addi	a2,a2,728 # ffffffffc02027b0 <commands+0x908>
ffffffffc02014e0:	10300593          	li	a1,259
ffffffffc02014e4:	00001517          	auipc	a0,0x1
ffffffffc02014e8:	2e450513          	addi	a0,a0,740 # ffffffffc02027c8 <commands+0x920>
ffffffffc02014ec:	ebdfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f0:	00001697          	auipc	a3,0x1
ffffffffc02014f4:	22868693          	addi	a3,a3,552 # ffffffffc0202718 <commands+0x870>
ffffffffc02014f8:	00001617          	auipc	a2,0x1
ffffffffc02014fc:	2b860613          	addi	a2,a2,696 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201500:	10100593          	li	a1,257
ffffffffc0201504:	00001517          	auipc	a0,0x1
ffffffffc0201508:	2c450513          	addi	a0,a0,708 # ffffffffc02027c8 <commands+0x920>
ffffffffc020150c:	e9dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201510:	00001697          	auipc	a3,0x1
ffffffffc0201514:	25068693          	addi	a3,a3,592 # ffffffffc0202760 <commands+0x8b8>
ffffffffc0201518:	00001617          	auipc	a2,0x1
ffffffffc020151c:	29860613          	addi	a2,a2,664 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201520:	0f800593          	li	a1,248
ffffffffc0201524:	00001517          	auipc	a0,0x1
ffffffffc0201528:	2a450513          	addi	a0,a0,676 # ffffffffc02027c8 <commands+0x920>
ffffffffc020152c:	e7dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0201530:	00001697          	auipc	a3,0x1
ffffffffc0201534:	21068693          	addi	a3,a3,528 # ffffffffc0202740 <commands+0x898>
ffffffffc0201538:	00001617          	auipc	a2,0x1
ffffffffc020153c:	27860613          	addi	a2,a2,632 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201540:	0f700593          	li	a1,247
ffffffffc0201544:	00001517          	auipc	a0,0x1
ffffffffc0201548:	28450513          	addi	a0,a0,644 # ffffffffc02027c8 <commands+0x920>
ffffffffc020154c:	e5dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201550:	00001697          	auipc	a3,0x1
ffffffffc0201554:	1c868693          	addi	a3,a3,456 # ffffffffc0202718 <commands+0x870>
ffffffffc0201558:	00001617          	auipc	a2,0x1
ffffffffc020155c:	25860613          	addi	a2,a2,600 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201560:	0ef00593          	li	a1,239
ffffffffc0201564:	00001517          	auipc	a0,0x1
ffffffffc0201568:	26450513          	addi	a0,a0,612 # ffffffffc02027c8 <commands+0x920>
ffffffffc020156c:	e3dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p2 + 1 == p3);
ffffffffc0201570:	00001697          	auipc	a3,0x1
ffffffffc0201574:	09068693          	addi	a3,a3,144 # ffffffffc0202600 <commands+0x758>
ffffffffc0201578:	00001617          	auipc	a2,0x1
ffffffffc020157c:	23860613          	addi	a2,a2,568 # ffffffffc02027b0 <commands+0x908>
ffffffffc0201580:	0e000593          	li	a1,224
ffffffffc0201584:	00001517          	auipc	a0,0x1
ffffffffc0201588:	24450513          	addi	a0,a0,580 # ffffffffc02027c8 <commands+0x920>
ffffffffc020158c:	e1dfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p = alloc_pages(4)) == p0);
ffffffffc0201590:	00001697          	auipc	a3,0x1
ffffffffc0201594:	1e068693          	addi	a3,a3,480 # ffffffffc0202770 <commands+0x8c8>
ffffffffc0201598:	00001617          	auipc	a2,0x1
ffffffffc020159c:	21860613          	addi	a2,a2,536 # ffffffffc02027b0 <commands+0x908>
ffffffffc02015a0:	10000593          	li	a1,256
ffffffffc02015a4:	00001517          	auipc	a0,0x1
ffffffffc02015a8:	22450513          	addi	a0,a0,548 # ffffffffc02027c8 <commands+0x920>
ffffffffc02015ac:	dfdfe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02015b0 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015b0:	100027f3          	csrr	a5,sstatus
ffffffffc02015b4:	8b89                	andi	a5,a5,2
ffffffffc02015b6:	eb89                	bnez	a5,ffffffffc02015c8 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02015b8:	00005797          	auipc	a5,0x5
ffffffffc02015bc:	ef078793          	addi	a5,a5,-272 # ffffffffc02064a8 <pmm_manager>
ffffffffc02015c0:	639c                	ld	a5,0(a5)
ffffffffc02015c2:	0187b303          	ld	t1,24(a5)
ffffffffc02015c6:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02015c8:	1141                	addi	sp,sp,-16
ffffffffc02015ca:	e406                	sd	ra,8(sp)
ffffffffc02015cc:	e022                	sd	s0,0(sp)
ffffffffc02015ce:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02015d0:	e8ffe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02015d4:	00005797          	auipc	a5,0x5
ffffffffc02015d8:	ed478793          	addi	a5,a5,-300 # ffffffffc02064a8 <pmm_manager>
ffffffffc02015dc:	639c                	ld	a5,0(a5)
ffffffffc02015de:	8522                	mv	a0,s0
ffffffffc02015e0:	6f9c                	ld	a5,24(a5)
ffffffffc02015e2:	9782                	jalr	a5
ffffffffc02015e4:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02015e6:	e73fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02015ea:	8522                	mv	a0,s0
ffffffffc02015ec:	60a2                	ld	ra,8(sp)
ffffffffc02015ee:	6402                	ld	s0,0(sp)
ffffffffc02015f0:	0141                	addi	sp,sp,16
ffffffffc02015f2:	8082                	ret

ffffffffc02015f4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015f4:	100027f3          	csrr	a5,sstatus
ffffffffc02015f8:	8b89                	andi	a5,a5,2
ffffffffc02015fa:	eb89                	bnez	a5,ffffffffc020160c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02015fc:	00005797          	auipc	a5,0x5
ffffffffc0201600:	eac78793          	addi	a5,a5,-340 # ffffffffc02064a8 <pmm_manager>
ffffffffc0201604:	639c                	ld	a5,0(a5)
ffffffffc0201606:	0207b303          	ld	t1,32(a5)
ffffffffc020160a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020160c:	1101                	addi	sp,sp,-32
ffffffffc020160e:	ec06                	sd	ra,24(sp)
ffffffffc0201610:	e822                	sd	s0,16(sp)
ffffffffc0201612:	e426                	sd	s1,8(sp)
ffffffffc0201614:	842a                	mv	s0,a0
ffffffffc0201616:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201618:	e47fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020161c:	00005797          	auipc	a5,0x5
ffffffffc0201620:	e8c78793          	addi	a5,a5,-372 # ffffffffc02064a8 <pmm_manager>
ffffffffc0201624:	639c                	ld	a5,0(a5)
ffffffffc0201626:	85a6                	mv	a1,s1
ffffffffc0201628:	8522                	mv	a0,s0
ffffffffc020162a:	739c                	ld	a5,32(a5)
ffffffffc020162c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020162e:	6442                	ld	s0,16(sp)
ffffffffc0201630:	60e2                	ld	ra,24(sp)
ffffffffc0201632:	64a2                	ld	s1,8(sp)
ffffffffc0201634:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201636:	e23fe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020163a <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020163a:	00001797          	auipc	a5,0x1
ffffffffc020163e:	1ee78793          	addi	a5,a5,494 # ffffffffc0202828 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201642:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201644:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201646:	00001517          	auipc	a0,0x1
ffffffffc020164a:	23250513          	addi	a0,a0,562 # ffffffffc0202878 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc020164e:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201650:	00005717          	auipc	a4,0x5
ffffffffc0201654:	e4f73c23          	sd	a5,-424(a4) # ffffffffc02064a8 <pmm_manager>
void pmm_init(void) {
ffffffffc0201658:	e822                	sd	s0,16(sp)
ffffffffc020165a:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020165c:	00005417          	auipc	s0,0x5
ffffffffc0201660:	e4c40413          	addi	s0,s0,-436 # ffffffffc02064a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201664:	a53fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201668:	601c                	ld	a5,0(s0)
ffffffffc020166a:	679c                	ld	a5,8(a5)
ffffffffc020166c:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020166e:	57f5                	li	a5,-3
ffffffffc0201670:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201672:	00001517          	auipc	a0,0x1
ffffffffc0201676:	21e50513          	addi	a0,a0,542 # ffffffffc0202890 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020167a:	00005717          	auipc	a4,0x5
ffffffffc020167e:	e2f73b23          	sd	a5,-458(a4) # ffffffffc02064b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201682:	a35fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201686:	46c5                	li	a3,17
ffffffffc0201688:	06ee                	slli	a3,a3,0x1b
ffffffffc020168a:	40100613          	li	a2,1025
ffffffffc020168e:	16fd                	addi	a3,a3,-1
ffffffffc0201690:	0656                	slli	a2,a2,0x15
ffffffffc0201692:	07e005b7          	lui	a1,0x7e00
ffffffffc0201696:	00001517          	auipc	a0,0x1
ffffffffc020169a:	21250513          	addi	a0,a0,530 # ffffffffc02028a8 <buddy_pmm_manager+0x80>
ffffffffc020169e:	a19fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016a2:	777d                	lui	a4,0xfffff
ffffffffc02016a4:	00006797          	auipc	a5,0x6
ffffffffc02016a8:	e1b78793          	addi	a5,a5,-485 # ffffffffc02074bf <end+0xfff>
ffffffffc02016ac:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016ae:	00088737          	lui	a4,0x88
ffffffffc02016b2:	00005697          	auipc	a3,0x5
ffffffffc02016b6:	dae6bb23          	sd	a4,-586(a3) # ffffffffc0206468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016ba:	4601                	li	a2,0
ffffffffc02016bc:	00005717          	auipc	a4,0x5
ffffffffc02016c0:	def73e23          	sd	a5,-516(a4) # ffffffffc02064b8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016c4:	4681                	li	a3,0
ffffffffc02016c6:	00005897          	auipc	a7,0x5
ffffffffc02016ca:	da288893          	addi	a7,a7,-606 # ffffffffc0206468 <npage>
ffffffffc02016ce:	00005597          	auipc	a1,0x5
ffffffffc02016d2:	dea58593          	addi	a1,a1,-534 # ffffffffc02064b8 <pages>
ffffffffc02016d6:	4805                	li	a6,1
ffffffffc02016d8:	fff80537          	lui	a0,0xfff80
ffffffffc02016dc:	a011                	j	ffffffffc02016e0 <pmm_init+0xa6>
ffffffffc02016de:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02016e0:	97b2                	add	a5,a5,a2
ffffffffc02016e2:	07a1                	addi	a5,a5,8
ffffffffc02016e4:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016e8:	0008b703          	ld	a4,0(a7)
ffffffffc02016ec:	0685                	addi	a3,a3,1
ffffffffc02016ee:	02860613          	addi	a2,a2,40
ffffffffc02016f2:	00a707b3          	add	a5,a4,a0
ffffffffc02016f6:	fef6e4e3          	bltu	a3,a5,ffffffffc02016de <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016fa:	6190                	ld	a2,0(a1)
ffffffffc02016fc:	00271793          	slli	a5,a4,0x2
ffffffffc0201700:	97ba                	add	a5,a5,a4
ffffffffc0201702:	fec006b7          	lui	a3,0xfec00
ffffffffc0201706:	078e                	slli	a5,a5,0x3
ffffffffc0201708:	96b2                	add	a3,a3,a2
ffffffffc020170a:	96be                	add	a3,a3,a5
ffffffffc020170c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201710:	08f6e863          	bltu	a3,a5,ffffffffc02017a0 <pmm_init+0x166>
ffffffffc0201714:	00005497          	auipc	s1,0x5
ffffffffc0201718:	d9c48493          	addi	s1,s1,-612 # ffffffffc02064b0 <va_pa_offset>
ffffffffc020171c:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc020171e:	45c5                	li	a1,17
ffffffffc0201720:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201722:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201724:	04b6e963          	bltu	a3,a1,ffffffffc0201776 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201728:	601c                	ld	a5,0(s0)
ffffffffc020172a:	7b9c                	ld	a5,48(a5)
ffffffffc020172c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020172e:	00001517          	auipc	a0,0x1
ffffffffc0201732:	21250513          	addi	a0,a0,530 # ffffffffc0202940 <buddy_pmm_manager+0x118>
ffffffffc0201736:	981fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020173a:	00004697          	auipc	a3,0x4
ffffffffc020173e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201742:	00005797          	auipc	a5,0x5
ffffffffc0201746:	d2d7b723          	sd	a3,-722(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020174a:	c02007b7          	lui	a5,0xc0200
ffffffffc020174e:	06f6e563          	bltu	a3,a5,ffffffffc02017b8 <pmm_init+0x17e>
ffffffffc0201752:	609c                	ld	a5,0(s1)
}
ffffffffc0201754:	6442                	ld	s0,16(sp)
ffffffffc0201756:	60e2                	ld	ra,24(sp)
ffffffffc0201758:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020175a:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020175c:	8e9d                	sub	a3,a3,a5
ffffffffc020175e:	00005797          	auipc	a5,0x5
ffffffffc0201762:	d4d7b123          	sd	a3,-702(a5) # ffffffffc02064a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201766:	00001517          	auipc	a0,0x1
ffffffffc020176a:	1fa50513          	addi	a0,a0,506 # ffffffffc0202960 <buddy_pmm_manager+0x138>
ffffffffc020176e:	8636                	mv	a2,a3
}
ffffffffc0201770:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201772:	945fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201776:	6785                	lui	a5,0x1
ffffffffc0201778:	17fd                	addi	a5,a5,-1
ffffffffc020177a:	96be                	add	a3,a3,a5
ffffffffc020177c:	77fd                	lui	a5,0xfffff
ffffffffc020177e:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201780:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201784:	04e7f663          	bgeu	a5,a4,ffffffffc02017d0 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201788:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020178a:	97aa                	add	a5,a5,a0
ffffffffc020178c:	00279513          	slli	a0,a5,0x2
ffffffffc0201790:	953e                	add	a0,a0,a5
ffffffffc0201792:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201794:	8d95                	sub	a1,a1,a3
ffffffffc0201796:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201798:	81b1                	srli	a1,a1,0xc
ffffffffc020179a:	9532                	add	a0,a0,a2
ffffffffc020179c:	9782                	jalr	a5
ffffffffc020179e:	b769                	j	ffffffffc0201728 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017a0:	00001617          	auipc	a2,0x1
ffffffffc02017a4:	13860613          	addi	a2,a2,312 # ffffffffc02028d8 <buddy_pmm_manager+0xb0>
ffffffffc02017a8:	07000593          	li	a1,112
ffffffffc02017ac:	00001517          	auipc	a0,0x1
ffffffffc02017b0:	15450513          	addi	a0,a0,340 # ffffffffc0202900 <buddy_pmm_manager+0xd8>
ffffffffc02017b4:	bf5fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02017b8:	00001617          	auipc	a2,0x1
ffffffffc02017bc:	12060613          	addi	a2,a2,288 # ffffffffc02028d8 <buddy_pmm_manager+0xb0>
ffffffffc02017c0:	08b00593          	li	a1,139
ffffffffc02017c4:	00001517          	auipc	a0,0x1
ffffffffc02017c8:	13c50513          	addi	a0,a0,316 # ffffffffc0202900 <buddy_pmm_manager+0xd8>
ffffffffc02017cc:	bddfe0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02017d0:	00001617          	auipc	a2,0x1
ffffffffc02017d4:	14060613          	addi	a2,a2,320 # ffffffffc0202910 <buddy_pmm_manager+0xe8>
ffffffffc02017d8:	06b00593          	li	a1,107
ffffffffc02017dc:	00001517          	auipc	a0,0x1
ffffffffc02017e0:	15450513          	addi	a0,a0,340 # ffffffffc0202930 <buddy_pmm_manager+0x108>
ffffffffc02017e4:	bc5fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02017e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02017e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02017ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02017f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017f8:	f022                	sd	s0,32(sp)
ffffffffc02017fa:	ec26                	sd	s1,24(sp)
ffffffffc02017fc:	e84a                	sd	s2,16(sp)
ffffffffc02017fe:	f406                	sd	ra,40(sp)
ffffffffc0201800:	e44e                	sd	s3,8(sp)
ffffffffc0201802:	84aa                	mv	s1,a0
ffffffffc0201804:	892e                	mv	s2,a1
ffffffffc0201806:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020180a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020180c:	03067e63          	bgeu	a2,a6,ffffffffc0201848 <printnum+0x60>
ffffffffc0201810:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201812:	00805763          	blez	s0,ffffffffc0201820 <printnum+0x38>
ffffffffc0201816:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201818:	85ca                	mv	a1,s2
ffffffffc020181a:	854e                	mv	a0,s3
ffffffffc020181c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020181e:	fc65                	bnez	s0,ffffffffc0201816 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201820:	1a02                	slli	s4,s4,0x20
ffffffffc0201822:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201826:	00001797          	auipc	a5,0x1
ffffffffc020182a:	30a78793          	addi	a5,a5,778 # ffffffffc0202b30 <error_string+0x38>
ffffffffc020182e:	9a3e                	add	s4,s4,a5
}
ffffffffc0201830:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201832:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201836:	70a2                	ld	ra,40(sp)
ffffffffc0201838:	69a2                	ld	s3,8(sp)
ffffffffc020183a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020183c:	85ca                	mv	a1,s2
ffffffffc020183e:	8326                	mv	t1,s1
}
ffffffffc0201840:	6942                	ld	s2,16(sp)
ffffffffc0201842:	64e2                	ld	s1,24(sp)
ffffffffc0201844:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201846:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201848:	03065633          	divu	a2,a2,a6
ffffffffc020184c:	8722                	mv	a4,s0
ffffffffc020184e:	f9bff0ef          	jal	ra,ffffffffc02017e8 <printnum>
ffffffffc0201852:	b7f9                	j	ffffffffc0201820 <printnum+0x38>

ffffffffc0201854 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201854:	7119                	addi	sp,sp,-128
ffffffffc0201856:	f4a6                	sd	s1,104(sp)
ffffffffc0201858:	f0ca                	sd	s2,96(sp)
ffffffffc020185a:	e8d2                	sd	s4,80(sp)
ffffffffc020185c:	e4d6                	sd	s5,72(sp)
ffffffffc020185e:	e0da                	sd	s6,64(sp)
ffffffffc0201860:	fc5e                	sd	s7,56(sp)
ffffffffc0201862:	f862                	sd	s8,48(sp)
ffffffffc0201864:	f06a                	sd	s10,32(sp)
ffffffffc0201866:	fc86                	sd	ra,120(sp)
ffffffffc0201868:	f8a2                	sd	s0,112(sp)
ffffffffc020186a:	ecce                	sd	s3,88(sp)
ffffffffc020186c:	f466                	sd	s9,40(sp)
ffffffffc020186e:	ec6e                	sd	s11,24(sp)
ffffffffc0201870:	892a                	mv	s2,a0
ffffffffc0201872:	84ae                	mv	s1,a1
ffffffffc0201874:	8d32                	mv	s10,a2
ffffffffc0201876:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201878:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020187a:	00001a17          	auipc	s4,0x1
ffffffffc020187e:	126a0a13          	addi	s4,s4,294 # ffffffffc02029a0 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201882:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201886:	00001c17          	auipc	s8,0x1
ffffffffc020188a:	272c0c13          	addi	s8,s8,626 # ffffffffc0202af8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020188e:	000d4503          	lbu	a0,0(s10)
ffffffffc0201892:	02500793          	li	a5,37
ffffffffc0201896:	001d0413          	addi	s0,s10,1
ffffffffc020189a:	00f50e63          	beq	a0,a5,ffffffffc02018b6 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020189e:	c521                	beqz	a0,ffffffffc02018e6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018a0:	02500993          	li	s3,37
ffffffffc02018a4:	a011                	j	ffffffffc02018a8 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02018a6:	c121                	beqz	a0,ffffffffc02018e6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02018a8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018aa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02018ac:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018ae:	fff44503          	lbu	a0,-1(s0)
ffffffffc02018b2:	ff351ae3          	bne	a0,s3,ffffffffc02018a6 <vprintfmt+0x52>
ffffffffc02018b6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02018ba:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02018be:	4981                	li	s3,0
ffffffffc02018c0:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02018c2:	5cfd                	li	s9,-1
ffffffffc02018c4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018c6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02018ca:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018cc:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02018d0:	0ff6f693          	andi	a3,a3,255
ffffffffc02018d4:	00140d13          	addi	s10,s0,1
ffffffffc02018d8:	1ed5ef63          	bltu	a1,a3,ffffffffc0201ad6 <vprintfmt+0x282>
ffffffffc02018dc:	068a                	slli	a3,a3,0x2
ffffffffc02018de:	96d2                	add	a3,a3,s4
ffffffffc02018e0:	4294                	lw	a3,0(a3)
ffffffffc02018e2:	96d2                	add	a3,a3,s4
ffffffffc02018e4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02018e6:	70e6                	ld	ra,120(sp)
ffffffffc02018e8:	7446                	ld	s0,112(sp)
ffffffffc02018ea:	74a6                	ld	s1,104(sp)
ffffffffc02018ec:	7906                	ld	s2,96(sp)
ffffffffc02018ee:	69e6                	ld	s3,88(sp)
ffffffffc02018f0:	6a46                	ld	s4,80(sp)
ffffffffc02018f2:	6aa6                	ld	s5,72(sp)
ffffffffc02018f4:	6b06                	ld	s6,64(sp)
ffffffffc02018f6:	7be2                	ld	s7,56(sp)
ffffffffc02018f8:	7c42                	ld	s8,48(sp)
ffffffffc02018fa:	7ca2                	ld	s9,40(sp)
ffffffffc02018fc:	7d02                	ld	s10,32(sp)
ffffffffc02018fe:	6de2                	ld	s11,24(sp)
ffffffffc0201900:	6109                	addi	sp,sp,128
ffffffffc0201902:	8082                	ret
            padc = '-';
ffffffffc0201904:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201906:	00144603          	lbu	a2,1(s0)
ffffffffc020190a:	846a                	mv	s0,s10
ffffffffc020190c:	b7c1                	j	ffffffffc02018cc <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020190e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201912:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201916:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201918:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020191a:	fa0dd9e3          	bgez	s11,ffffffffc02018cc <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020191e:	8de6                	mv	s11,s9
ffffffffc0201920:	5cfd                	li	s9,-1
ffffffffc0201922:	b76d                	j	ffffffffc02018cc <vprintfmt+0x78>
            if (width < 0)
ffffffffc0201924:	fffdc693          	not	a3,s11
ffffffffc0201928:	96fd                	srai	a3,a3,0x3f
ffffffffc020192a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020192e:	00144603          	lbu	a2,1(s0)
ffffffffc0201932:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201934:	846a                	mv	s0,s10
ffffffffc0201936:	bf59                	j	ffffffffc02018cc <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201938:	4705                	li	a4,1
ffffffffc020193a:	008a8593          	addi	a1,s5,8
ffffffffc020193e:	01074463          	blt	a4,a6,ffffffffc0201946 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0201942:	22080863          	beqz	a6,ffffffffc0201b72 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0201946:	000ab603          	ld	a2,0(s5)
ffffffffc020194a:	46c1                	li	a3,16
ffffffffc020194c:	8aae                	mv	s5,a1
ffffffffc020194e:	a291                	j	ffffffffc0201a92 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0201950:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201954:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201958:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020195a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020195e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201962:	fad56ce3          	bltu	a0,a3,ffffffffc020191a <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201966:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201968:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020196c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201970:	0196873b          	addw	a4,a3,s9
ffffffffc0201974:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201978:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020197c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201980:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201984:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201988:	fcd57fe3          	bgeu	a0,a3,ffffffffc0201966 <vprintfmt+0x112>
ffffffffc020198c:	b779                	j	ffffffffc020191a <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc020198e:	000aa503          	lw	a0,0(s5)
ffffffffc0201992:	85a6                	mv	a1,s1
ffffffffc0201994:	0aa1                	addi	s5,s5,8
ffffffffc0201996:	9902                	jalr	s2
            break;
ffffffffc0201998:	bddd                	j	ffffffffc020188e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020199a:	4705                	li	a4,1
ffffffffc020199c:	008a8993          	addi	s3,s5,8
ffffffffc02019a0:	01074463          	blt	a4,a6,ffffffffc02019a8 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02019a4:	1c080463          	beqz	a6,ffffffffc0201b6c <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02019a8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02019ac:	1c044a63          	bltz	s0,ffffffffc0201b80 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02019b0:	8622                	mv	a2,s0
ffffffffc02019b2:	8ace                	mv	s5,s3
ffffffffc02019b4:	46a9                	li	a3,10
ffffffffc02019b6:	a8f1                	j	ffffffffc0201a92 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02019b8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019bc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02019be:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02019c0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02019c4:	8fb5                	xor	a5,a5,a3
ffffffffc02019c6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019ca:	12d74963          	blt	a4,a3,ffffffffc0201afc <vprintfmt+0x2a8>
ffffffffc02019ce:	00369793          	slli	a5,a3,0x3
ffffffffc02019d2:	97e2                	add	a5,a5,s8
ffffffffc02019d4:	639c                	ld	a5,0(a5)
ffffffffc02019d6:	12078363          	beqz	a5,ffffffffc0201afc <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02019da:	86be                	mv	a3,a5
ffffffffc02019dc:	00001617          	auipc	a2,0x1
ffffffffc02019e0:	20460613          	addi	a2,a2,516 # ffffffffc0202be0 <error_string+0xe8>
ffffffffc02019e4:	85a6                	mv	a1,s1
ffffffffc02019e6:	854a                	mv	a0,s2
ffffffffc02019e8:	1cc000ef          	jal	ra,ffffffffc0201bb4 <printfmt>
ffffffffc02019ec:	b54d                	j	ffffffffc020188e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019ee:	000ab603          	ld	a2,0(s5)
ffffffffc02019f2:	0aa1                	addi	s5,s5,8
ffffffffc02019f4:	1a060163          	beqz	a2,ffffffffc0201b96 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02019f8:	00160413          	addi	s0,a2,1
ffffffffc02019fc:	15b05763          	blez	s11,ffffffffc0201b4a <vprintfmt+0x2f6>
ffffffffc0201a00:	02d00593          	li	a1,45
ffffffffc0201a04:	10b79d63          	bne	a5,a1,ffffffffc0201b1e <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a08:	00064783          	lbu	a5,0(a2)
ffffffffc0201a0c:	0007851b          	sext.w	a0,a5
ffffffffc0201a10:	c905                	beqz	a0,ffffffffc0201a40 <vprintfmt+0x1ec>
ffffffffc0201a12:	000cc563          	bltz	s9,ffffffffc0201a1c <vprintfmt+0x1c8>
ffffffffc0201a16:	3cfd                	addiw	s9,s9,-1
ffffffffc0201a18:	036c8263          	beq	s9,s6,ffffffffc0201a3c <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0201a1c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a1e:	14098f63          	beqz	s3,ffffffffc0201b7c <vprintfmt+0x328>
ffffffffc0201a22:	3781                	addiw	a5,a5,-32
ffffffffc0201a24:	14fbfc63          	bgeu	s7,a5,ffffffffc0201b7c <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0201a28:	03f00513          	li	a0,63
ffffffffc0201a2c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a2e:	0405                	addi	s0,s0,1
ffffffffc0201a30:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a34:	3dfd                	addiw	s11,s11,-1
ffffffffc0201a36:	0007851b          	sext.w	a0,a5
ffffffffc0201a3a:	fd61                	bnez	a0,ffffffffc0201a12 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0201a3c:	e5b059e3          	blez	s11,ffffffffc020188e <vprintfmt+0x3a>
ffffffffc0201a40:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a42:	85a6                	mv	a1,s1
ffffffffc0201a44:	02000513          	li	a0,32
ffffffffc0201a48:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a4a:	e40d82e3          	beqz	s11,ffffffffc020188e <vprintfmt+0x3a>
ffffffffc0201a4e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a50:	85a6                	mv	a1,s1
ffffffffc0201a52:	02000513          	li	a0,32
ffffffffc0201a56:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a58:	fe0d94e3          	bnez	s11,ffffffffc0201a40 <vprintfmt+0x1ec>
ffffffffc0201a5c:	bd0d                	j	ffffffffc020188e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a5e:	4705                	li	a4,1
ffffffffc0201a60:	008a8593          	addi	a1,s5,8
ffffffffc0201a64:	01074463          	blt	a4,a6,ffffffffc0201a6c <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0201a68:	0e080863          	beqz	a6,ffffffffc0201b58 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0201a6c:	000ab603          	ld	a2,0(s5)
ffffffffc0201a70:	46a1                	li	a3,8
ffffffffc0201a72:	8aae                	mv	s5,a1
ffffffffc0201a74:	a839                	j	ffffffffc0201a92 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0201a76:	03000513          	li	a0,48
ffffffffc0201a7a:	85a6                	mv	a1,s1
ffffffffc0201a7c:	e03e                	sd	a5,0(sp)
ffffffffc0201a7e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201a80:	85a6                	mv	a1,s1
ffffffffc0201a82:	07800513          	li	a0,120
ffffffffc0201a86:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201a88:	0aa1                	addi	s5,s5,8
ffffffffc0201a8a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201a8e:	6782                	ld	a5,0(sp)
ffffffffc0201a90:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201a92:	2781                	sext.w	a5,a5
ffffffffc0201a94:	876e                	mv	a4,s11
ffffffffc0201a96:	85a6                	mv	a1,s1
ffffffffc0201a98:	854a                	mv	a0,s2
ffffffffc0201a9a:	d4fff0ef          	jal	ra,ffffffffc02017e8 <printnum>
            break;
ffffffffc0201a9e:	bbc5                	j	ffffffffc020188e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201aa0:	00144603          	lbu	a2,1(s0)
ffffffffc0201aa4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aa6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201aa8:	b515                	j	ffffffffc02018cc <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201aaa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201aae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ab0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201ab2:	bd29                	j	ffffffffc02018cc <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201ab4:	85a6                	mv	a1,s1
ffffffffc0201ab6:	02500513          	li	a0,37
ffffffffc0201aba:	9902                	jalr	s2
            break;
ffffffffc0201abc:	bbc9                	j	ffffffffc020188e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201abe:	4705                	li	a4,1
ffffffffc0201ac0:	008a8593          	addi	a1,s5,8
ffffffffc0201ac4:	01074463          	blt	a4,a6,ffffffffc0201acc <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0201ac8:	08080d63          	beqz	a6,ffffffffc0201b62 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0201acc:	000ab603          	ld	a2,0(s5)
ffffffffc0201ad0:	46a9                	li	a3,10
ffffffffc0201ad2:	8aae                	mv	s5,a1
ffffffffc0201ad4:	bf7d                	j	ffffffffc0201a92 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0201ad6:	85a6                	mv	a1,s1
ffffffffc0201ad8:	02500513          	li	a0,37
ffffffffc0201adc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201ade:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201ae2:	02500793          	li	a5,37
ffffffffc0201ae6:	8d22                	mv	s10,s0
ffffffffc0201ae8:	daf703e3          	beq	a4,a5,ffffffffc020188e <vprintfmt+0x3a>
ffffffffc0201aec:	02500713          	li	a4,37
ffffffffc0201af0:	1d7d                	addi	s10,s10,-1
ffffffffc0201af2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201af6:	fee79de3          	bne	a5,a4,ffffffffc0201af0 <vprintfmt+0x29c>
ffffffffc0201afa:	bb51                	j	ffffffffc020188e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201afc:	00001617          	auipc	a2,0x1
ffffffffc0201b00:	0d460613          	addi	a2,a2,212 # ffffffffc0202bd0 <error_string+0xd8>
ffffffffc0201b04:	85a6                	mv	a1,s1
ffffffffc0201b06:	854a                	mv	a0,s2
ffffffffc0201b08:	0ac000ef          	jal	ra,ffffffffc0201bb4 <printfmt>
ffffffffc0201b0c:	b349                	j	ffffffffc020188e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201b0e:	00001617          	auipc	a2,0x1
ffffffffc0201b12:	0ba60613          	addi	a2,a2,186 # ffffffffc0202bc8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201b16:	00001417          	auipc	s0,0x1
ffffffffc0201b1a:	0b340413          	addi	s0,s0,179 # ffffffffc0202bc9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b1e:	8532                	mv	a0,a2
ffffffffc0201b20:	85e6                	mv	a1,s9
ffffffffc0201b22:	e032                	sd	a2,0(sp)
ffffffffc0201b24:	e43e                	sd	a5,8(sp)
ffffffffc0201b26:	1de000ef          	jal	ra,ffffffffc0201d04 <strnlen>
ffffffffc0201b2a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201b2e:	6602                	ld	a2,0(sp)
ffffffffc0201b30:	01b05d63          	blez	s11,ffffffffc0201b4a <vprintfmt+0x2f6>
ffffffffc0201b34:	67a2                	ld	a5,8(sp)
ffffffffc0201b36:	2781                	sext.w	a5,a5
ffffffffc0201b38:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201b3a:	6522                	ld	a0,8(sp)
ffffffffc0201b3c:	85a6                	mv	a1,s1
ffffffffc0201b3e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b40:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201b42:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b44:	6602                	ld	a2,0(sp)
ffffffffc0201b46:	fe0d9ae3          	bnez	s11,ffffffffc0201b3a <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b4a:	00064783          	lbu	a5,0(a2)
ffffffffc0201b4e:	0007851b          	sext.w	a0,a5
ffffffffc0201b52:	ec0510e3          	bnez	a0,ffffffffc0201a12 <vprintfmt+0x1be>
ffffffffc0201b56:	bb25                	j	ffffffffc020188e <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0201b58:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b5c:	46a1                	li	a3,8
ffffffffc0201b5e:	8aae                	mv	s5,a1
ffffffffc0201b60:	bf0d                	j	ffffffffc0201a92 <vprintfmt+0x23e>
ffffffffc0201b62:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b66:	46a9                	li	a3,10
ffffffffc0201b68:	8aae                	mv	s5,a1
ffffffffc0201b6a:	b725                	j	ffffffffc0201a92 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0201b6c:	000aa403          	lw	s0,0(s5)
ffffffffc0201b70:	bd35                	j	ffffffffc02019ac <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0201b72:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b76:	46c1                	li	a3,16
ffffffffc0201b78:	8aae                	mv	s5,a1
ffffffffc0201b7a:	bf21                	j	ffffffffc0201a92 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0201b7c:	9902                	jalr	s2
ffffffffc0201b7e:	bd45                	j	ffffffffc0201a2e <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201b80:	85a6                	mv	a1,s1
ffffffffc0201b82:	02d00513          	li	a0,45
ffffffffc0201b86:	e03e                	sd	a5,0(sp)
ffffffffc0201b88:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201b8a:	8ace                	mv	s5,s3
ffffffffc0201b8c:	40800633          	neg	a2,s0
ffffffffc0201b90:	46a9                	li	a3,10
ffffffffc0201b92:	6782                	ld	a5,0(sp)
ffffffffc0201b94:	bdfd                	j	ffffffffc0201a92 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0201b96:	01b05663          	blez	s11,ffffffffc0201ba2 <vprintfmt+0x34e>
ffffffffc0201b9a:	02d00693          	li	a3,45
ffffffffc0201b9e:	f6d798e3          	bne	a5,a3,ffffffffc0201b0e <vprintfmt+0x2ba>
ffffffffc0201ba2:	00001417          	auipc	s0,0x1
ffffffffc0201ba6:	02740413          	addi	s0,s0,39 # ffffffffc0202bc9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201baa:	02800513          	li	a0,40
ffffffffc0201bae:	02800793          	li	a5,40
ffffffffc0201bb2:	b585                	j	ffffffffc0201a12 <vprintfmt+0x1be>

ffffffffc0201bb4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bb4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201bb6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bbc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bbe:	ec06                	sd	ra,24(sp)
ffffffffc0201bc0:	f83a                	sd	a4,48(sp)
ffffffffc0201bc2:	fc3e                	sd	a5,56(sp)
ffffffffc0201bc4:	e0c2                	sd	a6,64(sp)
ffffffffc0201bc6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201bc8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bca:	c8bff0ef          	jal	ra,ffffffffc0201854 <vprintfmt>
}
ffffffffc0201bce:	60e2                	ld	ra,24(sp)
ffffffffc0201bd0:	6161                	addi	sp,sp,80
ffffffffc0201bd2:	8082                	ret

ffffffffc0201bd4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201bd4:	715d                	addi	sp,sp,-80
ffffffffc0201bd6:	e486                	sd	ra,72(sp)
ffffffffc0201bd8:	e0a2                	sd	s0,64(sp)
ffffffffc0201bda:	fc26                	sd	s1,56(sp)
ffffffffc0201bdc:	f84a                	sd	s2,48(sp)
ffffffffc0201bde:	f44e                	sd	s3,40(sp)
ffffffffc0201be0:	f052                	sd	s4,32(sp)
ffffffffc0201be2:	ec56                	sd	s5,24(sp)
ffffffffc0201be4:	e85a                	sd	s6,16(sp)
ffffffffc0201be6:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201be8:	c901                	beqz	a0,ffffffffc0201bf8 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201bea:	85aa                	mv	a1,a0
ffffffffc0201bec:	00001517          	auipc	a0,0x1
ffffffffc0201bf0:	ff450513          	addi	a0,a0,-12 # ffffffffc0202be0 <error_string+0xe8>
ffffffffc0201bf4:	cc2fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201bf8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bfa:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201bfc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201bfe:	4aa9                	li	s5,10
ffffffffc0201c00:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201c02:	00004b97          	auipc	s7,0x4
ffffffffc0201c06:	416b8b93          	addi	s7,s7,1046 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c0a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201c0e:	d1efe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c12:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c14:	00054b63          	bltz	a0,ffffffffc0201c2a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c18:	00a95b63          	bge	s2,a0,ffffffffc0201c2e <readline+0x5a>
ffffffffc0201c1c:	029a5463          	bge	s4,s1,ffffffffc0201c44 <readline+0x70>
        c = getchar();
ffffffffc0201c20:	d0cfe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c24:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c26:	fe0559e3          	bgez	a0,ffffffffc0201c18 <readline+0x44>
            return NULL;
ffffffffc0201c2a:	4501                	li	a0,0
ffffffffc0201c2c:	a099                	j	ffffffffc0201c72 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201c2e:	03341463          	bne	s0,s3,ffffffffc0201c56 <readline+0x82>
ffffffffc0201c32:	e8b9                	bnez	s1,ffffffffc0201c88 <readline+0xb4>
        c = getchar();
ffffffffc0201c34:	cf8fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c38:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c3a:	fe0548e3          	bltz	a0,ffffffffc0201c2a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c3e:	fea958e3          	bge	s2,a0,ffffffffc0201c2e <readline+0x5a>
ffffffffc0201c42:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201c44:	8522                	mv	a0,s0
ffffffffc0201c46:	ca4fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201c4a:	009b87b3          	add	a5,s7,s1
ffffffffc0201c4e:	00878023          	sb	s0,0(a5)
ffffffffc0201c52:	2485                	addiw	s1,s1,1
ffffffffc0201c54:	bf6d                	j	ffffffffc0201c0e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201c56:	01540463          	beq	s0,s5,ffffffffc0201c5e <readline+0x8a>
ffffffffc0201c5a:	fb641ae3          	bne	s0,s6,ffffffffc0201c0e <readline+0x3a>
            cputchar(c);
ffffffffc0201c5e:	8522                	mv	a0,s0
ffffffffc0201c60:	c8afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201c64:	00004517          	auipc	a0,0x4
ffffffffc0201c68:	3b450513          	addi	a0,a0,948 # ffffffffc0206018 <edata>
ffffffffc0201c6c:	94aa                	add	s1,s1,a0
ffffffffc0201c6e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201c72:	60a6                	ld	ra,72(sp)
ffffffffc0201c74:	6406                	ld	s0,64(sp)
ffffffffc0201c76:	74e2                	ld	s1,56(sp)
ffffffffc0201c78:	7942                	ld	s2,48(sp)
ffffffffc0201c7a:	79a2                	ld	s3,40(sp)
ffffffffc0201c7c:	7a02                	ld	s4,32(sp)
ffffffffc0201c7e:	6ae2                	ld	s5,24(sp)
ffffffffc0201c80:	6b42                	ld	s6,16(sp)
ffffffffc0201c82:	6ba2                	ld	s7,8(sp)
ffffffffc0201c84:	6161                	addi	sp,sp,80
ffffffffc0201c86:	8082                	ret
            cputchar(c);
ffffffffc0201c88:	4521                	li	a0,8
ffffffffc0201c8a:	c60fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201c8e:	34fd                	addiw	s1,s1,-1
ffffffffc0201c90:	bfbd                	j	ffffffffc0201c0e <readline+0x3a>

ffffffffc0201c92 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201c92:	00004797          	auipc	a5,0x4
ffffffffc0201c96:	37678793          	addi	a5,a5,886 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201c9a:	6398                	ld	a4,0(a5)
ffffffffc0201c9c:	4781                	li	a5,0
ffffffffc0201c9e:	88ba                	mv	a7,a4
ffffffffc0201ca0:	852a                	mv	a0,a0
ffffffffc0201ca2:	85be                	mv	a1,a5
ffffffffc0201ca4:	863e                	mv	a2,a5
ffffffffc0201ca6:	00000073          	ecall
ffffffffc0201caa:	87aa                	mv	a5,a0
}
ffffffffc0201cac:	8082                	ret

ffffffffc0201cae <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201cae:	00004797          	auipc	a5,0x4
ffffffffc0201cb2:	7ca78793          	addi	a5,a5,1994 # ffffffffc0206478 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201cb6:	6398                	ld	a4,0(a5)
ffffffffc0201cb8:	4781                	li	a5,0
ffffffffc0201cba:	88ba                	mv	a7,a4
ffffffffc0201cbc:	852a                	mv	a0,a0
ffffffffc0201cbe:	85be                	mv	a1,a5
ffffffffc0201cc0:	863e                	mv	a2,a5
ffffffffc0201cc2:	00000073          	ecall
ffffffffc0201cc6:	87aa                	mv	a5,a0
}
ffffffffc0201cc8:	8082                	ret

ffffffffc0201cca <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201cca:	00004797          	auipc	a5,0x4
ffffffffc0201cce:	33678793          	addi	a5,a5,822 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201cd2:	639c                	ld	a5,0(a5)
ffffffffc0201cd4:	4501                	li	a0,0
ffffffffc0201cd6:	88be                	mv	a7,a5
ffffffffc0201cd8:	852a                	mv	a0,a0
ffffffffc0201cda:	85aa                	mv	a1,a0
ffffffffc0201cdc:	862a                	mv	a2,a0
ffffffffc0201cde:	00000073          	ecall
ffffffffc0201ce2:	852a                	mv	a0,a0
}
ffffffffc0201ce4:	2501                	sext.w	a0,a0
ffffffffc0201ce6:	8082                	ret

ffffffffc0201ce8 <sbi_shutdown>:

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201ce8:	00004797          	auipc	a5,0x4
ffffffffc0201cec:	32878793          	addi	a5,a5,808 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201cf0:	6398                	ld	a4,0(a5)
ffffffffc0201cf2:	4781                	li	a5,0
ffffffffc0201cf4:	88ba                	mv	a7,a4
ffffffffc0201cf6:	853e                	mv	a0,a5
ffffffffc0201cf8:	85be                	mv	a1,a5
ffffffffc0201cfa:	863e                	mv	a2,a5
ffffffffc0201cfc:	00000073          	ecall
ffffffffc0201d00:	87aa                	mv	a5,a0
ffffffffc0201d02:	8082                	ret

ffffffffc0201d04 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d04:	c185                	beqz	a1,ffffffffc0201d24 <strnlen+0x20>
ffffffffc0201d06:	00054783          	lbu	a5,0(a0)
ffffffffc0201d0a:	cf89                	beqz	a5,ffffffffc0201d24 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201d0c:	4781                	li	a5,0
ffffffffc0201d0e:	a021                	j	ffffffffc0201d16 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d10:	00074703          	lbu	a4,0(a4)
ffffffffc0201d14:	c711                	beqz	a4,ffffffffc0201d20 <strnlen+0x1c>
        cnt ++;
ffffffffc0201d16:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d18:	00f50733          	add	a4,a0,a5
ffffffffc0201d1c:	fef59ae3          	bne	a1,a5,ffffffffc0201d10 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201d20:	853e                	mv	a0,a5
ffffffffc0201d22:	8082                	ret
    size_t cnt = 0;
ffffffffc0201d24:	4781                	li	a5,0
}
ffffffffc0201d26:	853e                	mv	a0,a5
ffffffffc0201d28:	8082                	ret

ffffffffc0201d2a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d2a:	00054783          	lbu	a5,0(a0)
ffffffffc0201d2e:	0005c703          	lbu	a4,0(a1)
ffffffffc0201d32:	cb91                	beqz	a5,ffffffffc0201d46 <strcmp+0x1c>
ffffffffc0201d34:	00e79c63          	bne	a5,a4,ffffffffc0201d4c <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201d38:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d3a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201d3e:	0585                	addi	a1,a1,1
ffffffffc0201d40:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d44:	fbe5                	bnez	a5,ffffffffc0201d34 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d46:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201d48:	9d19                	subw	a0,a0,a4
ffffffffc0201d4a:	8082                	ret
ffffffffc0201d4c:	0007851b          	sext.w	a0,a5
ffffffffc0201d50:	9d19                	subw	a0,a0,a4
ffffffffc0201d52:	8082                	ret

ffffffffc0201d54 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201d54:	00054783          	lbu	a5,0(a0)
ffffffffc0201d58:	cb91                	beqz	a5,ffffffffc0201d6c <strchr+0x18>
        if (*s == c) {
ffffffffc0201d5a:	00b79563          	bne	a5,a1,ffffffffc0201d64 <strchr+0x10>
ffffffffc0201d5e:	a809                	j	ffffffffc0201d70 <strchr+0x1c>
ffffffffc0201d60:	00b78763          	beq	a5,a1,ffffffffc0201d6e <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201d64:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201d66:	00054783          	lbu	a5,0(a0)
ffffffffc0201d6a:	fbfd                	bnez	a5,ffffffffc0201d60 <strchr+0xc>
    }
    return NULL;
ffffffffc0201d6c:	4501                	li	a0,0
}
ffffffffc0201d6e:	8082                	ret
ffffffffc0201d70:	8082                	ret

ffffffffc0201d72 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201d72:	ca01                	beqz	a2,ffffffffc0201d82 <memset+0x10>
ffffffffc0201d74:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201d76:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201d78:	0785                	addi	a5,a5,1
ffffffffc0201d7a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201d7e:	fec79de3          	bne	a5,a2,ffffffffc0201d78 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201d82:	8082                	ret

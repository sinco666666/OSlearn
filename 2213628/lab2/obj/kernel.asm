
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
ffffffffc020004e:	533010ef          	jal	ra,ffffffffc0201d80 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	d4250513          	addi	a0,a0,-702 # ffffffffc0201d98 <etext+0x6>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	5de010ef          	jal	ra,ffffffffc0201648 <pmm_init>

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
ffffffffc02000aa:	7b8010ef          	jal	ra,ffffffffc0201862 <vprintfmt>
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
ffffffffc02000de:	784010ef          	jal	ra,ffffffffc0201862 <vprintfmt>
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
ffffffffc0200142:	caa50513          	addi	a0,a0,-854 # ffffffffc0201de8 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00002517          	auipc	a0,0x2
ffffffffc0200158:	cb450513          	addi	a0,a0,-844 # ffffffffc0201e08 <etext+0x76>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00002597          	auipc	a1,0x2
ffffffffc0200164:	c3258593          	addi	a1,a1,-974 # ffffffffc0201d92 <etext>
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	cc050513          	addi	a0,a0,-832 # ffffffffc0201e28 <etext+0x96>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	ea458593          	addi	a1,a1,-348 # ffffffffc0206018 <edata>
ffffffffc020017c:	00002517          	auipc	a0,0x2
ffffffffc0200180:	ccc50513          	addi	a0,a0,-820 # ffffffffc0201e48 <etext+0xb6>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	33858593          	addi	a1,a1,824 # ffffffffc02064c0 <end>
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	cd850513          	addi	a0,a0,-808 # ffffffffc0201e68 <etext+0xd6>
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
ffffffffc02001c2:	cca50513          	addi	a0,a0,-822 # ffffffffc0201e88 <etext+0xf6>
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
ffffffffc02001d0:	bec60613          	addi	a2,a2,-1044 # ffffffffc0201db8 <etext+0x26>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	bf850513          	addi	a0,a0,-1032 # ffffffffc0201dd0 <etext+0x3e>
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
ffffffffc02001ec:	db060613          	addi	a2,a2,-592 # ffffffffc0201f98 <commands+0xe0>
ffffffffc02001f0:	00002597          	auipc	a1,0x2
ffffffffc02001f4:	dc858593          	addi	a1,a1,-568 # ffffffffc0201fb8 <commands+0x100>
ffffffffc02001f8:	00002517          	auipc	a0,0x2
ffffffffc02001fc:	dc850513          	addi	a0,a0,-568 # ffffffffc0201fc0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00002617          	auipc	a2,0x2
ffffffffc020020a:	dca60613          	addi	a2,a2,-566 # ffffffffc0201fd0 <commands+0x118>
ffffffffc020020e:	00002597          	auipc	a1,0x2
ffffffffc0200212:	dea58593          	addi	a1,a1,-534 # ffffffffc0201ff8 <commands+0x140>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	daa50513          	addi	a0,a0,-598 # ffffffffc0201fc0 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	de660613          	addi	a2,a2,-538 # ffffffffc0202008 <commands+0x150>
ffffffffc020022a:	00002597          	auipc	a1,0x2
ffffffffc020022e:	dfe58593          	addi	a1,a1,-514 # ffffffffc0202028 <commands+0x170>
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	d8e50513          	addi	a0,a0,-626 # ffffffffc0201fc0 <commands+0x108>
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
ffffffffc0200270:	c9450513          	addi	a0,a0,-876 # ffffffffc0201f00 <commands+0x48>
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
ffffffffc0200292:	c9a50513          	addi	a0,a0,-870 # ffffffffc0201f28 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00002c97          	auipc	s9,0x2
ffffffffc02002a8:	c14c8c93          	addi	s9,s9,-1004 # ffffffffc0201eb8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00002997          	auipc	s3,0x2
ffffffffc02002b0:	ca498993          	addi	s3,s3,-860 # ffffffffc0201f50 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	ca490913          	addi	s2,s2,-860 # ffffffffc0201f58 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00002b17          	auipc	s6,0x2
ffffffffc02002c2:	ca2b0b13          	addi	s6,s6,-862 # ffffffffc0201f60 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	cf2a8a93          	addi	s5,s5,-782 # ffffffffc0201fb8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	111010ef          	jal	ra,ffffffffc0201be2 <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	27f010ef          	jal	ra,ffffffffc0201d62 <strchr>
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
ffffffffc02002fe:	bbed0d13          	addi	s10,s10,-1090 # ffffffffc0201eb8 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	231010ef          	jal	ra,ffffffffc0201d38 <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	21d010ef          	jal	ra,ffffffffc0201d38 <strcmp>
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
ffffffffc0200382:	1e1010ef          	jal	ra,ffffffffc0201d62 <strchr>
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
ffffffffc020039e:	be650513          	addi	a0,a0,-1050 # ffffffffc0201f80 <commands+0xc8>
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
ffffffffc02003de:	c5e50513          	addi	a0,a0,-930 # ffffffffc0202038 <commands+0x180>
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
ffffffffc02003f4:	3d050513          	addi	a0,a0,976 # ffffffffc02027c0 <commands+0x908>
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
ffffffffc0200420:	09d010ef          	jal	ra,ffffffffc0201cbc <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0407bd23          	sd	zero,90(a5) # ffffffffc0206480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	c2a50513          	addi	a0,a0,-982 # ffffffffc0202058 <commands+0x1a0>
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
ffffffffc0200446:	0770106f          	j	ffffffffc0201cbc <sbi_set_timer>

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
ffffffffc0200450:	0510106f          	j	ffffffffc0201ca0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0850106f          	j	ffffffffc0201cd8 <sbi_console_getchar>

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
ffffffffc0200482:	d7a50513          	addi	a0,a0,-646 # ffffffffc02021f8 <commands+0x340>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	d8250513          	addi	a0,a0,-638 # ffffffffc0202210 <commands+0x358>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	d8c50513          	addi	a0,a0,-628 # ffffffffc0202228 <commands+0x370>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	d9650513          	addi	a0,a0,-618 # ffffffffc0202240 <commands+0x388>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	da050513          	addi	a0,a0,-608 # ffffffffc0202258 <commands+0x3a0>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	daa50513          	addi	a0,a0,-598 # ffffffffc0202270 <commands+0x3b8>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	db450513          	addi	a0,a0,-588 # ffffffffc0202288 <commands+0x3d0>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	dbe50513          	addi	a0,a0,-578 # ffffffffc02022a0 <commands+0x3e8>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	dc850513          	addi	a0,a0,-568 # ffffffffc02022b8 <commands+0x400>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	dd250513          	addi	a0,a0,-558 # ffffffffc02022d0 <commands+0x418>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	ddc50513          	addi	a0,a0,-548 # ffffffffc02022e8 <commands+0x430>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	de650513          	addi	a0,a0,-538 # ffffffffc0202300 <commands+0x448>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	df050513          	addi	a0,a0,-528 # ffffffffc0202318 <commands+0x460>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0202330 <commands+0x478>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	e0450513          	addi	a0,a0,-508 # ffffffffc0202348 <commands+0x490>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	e0e50513          	addi	a0,a0,-498 # ffffffffc0202360 <commands+0x4a8>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	e1850513          	addi	a0,a0,-488 # ffffffffc0202378 <commands+0x4c0>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	e2250513          	addi	a0,a0,-478 # ffffffffc0202390 <commands+0x4d8>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	e2c50513          	addi	a0,a0,-468 # ffffffffc02023a8 <commands+0x4f0>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	e3650513          	addi	a0,a0,-458 # ffffffffc02023c0 <commands+0x508>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	e4050513          	addi	a0,a0,-448 # ffffffffc02023d8 <commands+0x520>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	e4a50513          	addi	a0,a0,-438 # ffffffffc02023f0 <commands+0x538>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	e5450513          	addi	a0,a0,-428 # ffffffffc0202408 <commands+0x550>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0202420 <commands+0x568>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	e6850513          	addi	a0,a0,-408 # ffffffffc0202438 <commands+0x580>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	e7250513          	addi	a0,a0,-398 # ffffffffc0202450 <commands+0x598>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0202468 <commands+0x5b0>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	e8650513          	addi	a0,a0,-378 # ffffffffc0202480 <commands+0x5c8>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	e9050513          	addi	a0,a0,-368 # ffffffffc0202498 <commands+0x5e0>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	e9a50513          	addi	a0,a0,-358 # ffffffffc02024b0 <commands+0x5f8>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	ea450513          	addi	a0,a0,-348 # ffffffffc02024c8 <commands+0x610>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	eaa50513          	addi	a0,a0,-342 # ffffffffc02024e0 <commands+0x628>
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
ffffffffc020064e:	eae50513          	addi	a0,a0,-338 # ffffffffc02024f8 <commands+0x640>
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
ffffffffc0200666:	eae50513          	addi	a0,a0,-338 # ffffffffc0202510 <commands+0x658>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	eb650513          	addi	a0,a0,-330 # ffffffffc0202528 <commands+0x670>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	ebe50513          	addi	a0,a0,-322 # ffffffffc0202540 <commands+0x688>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	ec250513          	addi	a0,a0,-318 # ffffffffc0202558 <commands+0x6a0>
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
ffffffffc02006b4:	9c470713          	addi	a4,a4,-1596 # ffffffffc0202074 <commands+0x1bc>
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
ffffffffc02006c6:	ace50513          	addi	a0,a0,-1330 # ffffffffc0202190 <commands+0x2d8>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0202170 <commands+0x2b8>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0202130 <commands+0x278>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	ad050513          	addi	a0,a0,-1328 # ffffffffc02021b0 <commands+0x2f8>
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
ffffffffc020072e:	aae50513          	addi	a0,a0,-1362 # ffffffffc02021d8 <commands+0x320>
ffffffffc0200732:	b251                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200734:	00002517          	auipc	a0,0x2
ffffffffc0200738:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0202150 <commands+0x298>
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020073e:	b711                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc0200740:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200742:	06400593          	li	a1,100
ffffffffc0200746:	00002517          	auipc	a0,0x2
ffffffffc020074a:	a8250513          	addi	a0,a0,-1406 # ffffffffc02021c8 <commands+0x310>
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
ffffffffc0200764:	5920106f          	j	ffffffffc0201cf6 <sbi_shutdown>

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
ffffffffc02007a4:	90850513          	addi	a0,a0,-1784 # ffffffffc02020a8 <commands+0x1f0>
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc02007ac:	10843583          	ld	a1,264(s0)
ffffffffc02007b0:	00002517          	auipc	a0,0x2
ffffffffc02007b4:	92050513          	addi	a0,a0,-1760 # ffffffffc02020d0 <commands+0x218>
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
ffffffffc02007d2:	92a50513          	addi	a0,a0,-1750 # ffffffffc02020f8 <commands+0x240>
ffffffffc02007d6:	8e1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007da:	10843583          	ld	a1,264(s0)
ffffffffc02007de:	00002517          	auipc	a0,0x2
ffffffffc02007e2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0202118 <commands+0x260>
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
ffffffffc020091e:	eae70713          	addi	a4,a4,-338 # ffffffffc02027c8 <commands+0x910>
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
ffffffffc0200afa:	d0a68693          	addi	a3,a3,-758 # ffffffffc0202800 <commands+0x948>
ffffffffc0200afe:	00002617          	auipc	a2,0x2
ffffffffc0200b02:	cda60613          	addi	a2,a2,-806 # ffffffffc02027d8 <commands+0x920>
ffffffffc0200b06:	0ad00593          	li	a1,173
ffffffffc0200b0a:	00002517          	auipc	a0,0x2
ffffffffc0200b0e:	ce650513          	addi	a0,a0,-794 # ffffffffc02027f0 <commands+0x938>
ffffffffc0200b12:	897ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200b16:	00002697          	auipc	a3,0x2
ffffffffc0200b1a:	cba68693          	addi	a3,a3,-838 # ffffffffc02027d0 <commands+0x918>
ffffffffc0200b1e:	00002617          	auipc	a2,0x2
ffffffffc0200b22:	cba60613          	addi	a2,a2,-838 # ffffffffc02027d8 <commands+0x920>
ffffffffc0200b26:	0a400593          	li	a1,164
ffffffffc0200b2a:	00002517          	auipc	a0,0x2
ffffffffc0200b2e:	cc650513          	addi	a0,a0,-826 # ffffffffc02027f0 <commands+0x938>
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
ffffffffc0200d06:	ace68693          	addi	a3,a3,-1330 # ffffffffc02027d0 <commands+0x918>
ffffffffc0200d0a:	00002617          	auipc	a2,0x2
ffffffffc0200d0e:	ace60613          	addi	a2,a2,-1330 # ffffffffc02027d8 <commands+0x920>
ffffffffc0200d12:	07400593          	li	a1,116
ffffffffc0200d16:	00002517          	auipc	a0,0x2
ffffffffc0200d1a:	ada50513          	addi	a0,a0,-1318 # ffffffffc02027f0 <commands+0x938>
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
ffffffffc0200e1c:	9b070713          	addi	a4,a4,-1616 # ffffffffc02027c8 <commands+0x910>
ffffffffc0200e20:	6318                	ld	a4,0(a4)
ffffffffc0200e22:	40d506b3          	sub	a3,a0,a3
ffffffffc0200e26:	868d                	srai	a3,a3,0x3
ffffffffc0200e28:	02e686b3          	mul	a3,a3,a4
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200e2c:	00005817          	auipc	a6,0x5
ffffffffc0200e30:	60f83e23          	sd	a5,1564(a6) # ffffffffc0206448 <real_tree_size>
ffffffffc0200e34:	00002597          	auipc	a1,0x2
ffffffffc0200e38:	ddc58593          	addi	a1,a1,-548 # ffffffffc0202c10 <nbase>
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
ffffffffc0200e8a:	6f7000ef          	jal	ra,ffffffffc0201d80 <memset>
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
ffffffffc0201044:	7d868693          	addi	a3,a3,2008 # ffffffffc0202818 <commands+0x960>
ffffffffc0201048:	00001617          	auipc	a2,0x1
ffffffffc020104c:	79060613          	addi	a2,a2,1936 # ffffffffc02027d8 <commands+0x920>
ffffffffc0201050:	03100593          	li	a1,49
ffffffffc0201054:	00001517          	auipc	a0,0x1
ffffffffc0201058:	79c50513          	addi	a0,a0,1948 # ffffffffc02027f0 <commands+0x938>
ffffffffc020105c:	b4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    record_area = KADDR(page2pa(base));
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	7c860613          	addi	a2,a2,1992 # ffffffffc0202828 <commands+0x970>
ffffffffc0201068:	04700593          	li	a1,71
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	78450513          	addi	a0,a0,1924 # ffffffffc02027f0 <commands+0x938>
ffffffffc0201074:	b34ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201078 <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0201078:	c191                	beqz	a1,ffffffffc020107c <buddy_init_memmap+0x4>
ffffffffc020107a:	b16d                	j	ffffffffc0200d24 <buddy_init_memmap.part.2>
{
ffffffffc020107c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020107e:	00001697          	auipc	a3,0x1
ffffffffc0201082:	75268693          	addi	a3,a3,1874 # ffffffffc02027d0 <commands+0x918>
ffffffffc0201086:	00001617          	auipc	a2,0x1
ffffffffc020108a:	75260613          	addi	a2,a2,1874 # ffffffffc02027d8 <commands+0x920>
ffffffffc020108e:	02d00593          	li	a1,45
ffffffffc0201092:	00001517          	auipc	a0,0x1
ffffffffc0201096:	75e50513          	addi	a0,a0,1886 # ffffffffc02027f0 <commands+0x938>
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
ffffffffc0201116:	4a8000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc020111a:	8a2a                	mv	s4,a0
ffffffffc020111c:	3a050163          	beqz	a0,ffffffffc02014be <alloc_check+0x41e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201120:	4505                	li	a0,1
ffffffffc0201122:	49c000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201126:	8b2a                	mv	s6,a0
ffffffffc0201128:	26050b63          	beqz	a0,ffffffffc020139e <alloc_check+0x2fe>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020112c:	4505                	li	a0,1
ffffffffc020112e:	490000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201132:	8aaa                	mv	s5,a0
ffffffffc0201134:	24050563          	beqz	a0,ffffffffc020137e <alloc_check+0x2de>
    assert((p3 = alloc_page()) != NULL);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	484000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc020113e:	8baa                	mv	s7,a0
ffffffffc0201140:	20050f63          	beqz	a0,ffffffffc020135e <alloc_check+0x2be>

    assert(p0 + 1 == p1);
ffffffffc0201144:	028a0793          	addi	a5,s4,40
ffffffffc0201148:	1efb1b63          	bne	s6,a5,ffffffffc020133e <alloc_check+0x29e>
    assert(p1 + 1 == p2);
ffffffffc020114c:	050a0793          	addi	a5,s4,80
ffffffffc0201150:	26fa9763          	bne	s5,a5,ffffffffc02013be <alloc_check+0x31e>
    assert(p2 + 1 == p3);
ffffffffc0201154:	078a0793          	addi	a5,s4,120
ffffffffc0201158:	42f51363          	bne	a0,a5,ffffffffc020157e <alloc_check+0x4de>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc020115c:	000a2783          	lw	a5,0(s4)
ffffffffc0201160:	1a079f63          	bnez	a5,ffffffffc020131e <alloc_check+0x27e>
ffffffffc0201164:	000b2783          	lw	a5,0(s6)
ffffffffc0201168:	1a079b63          	bnez	a5,ffffffffc020131e <alloc_check+0x27e>
ffffffffc020116c:	000aa783          	lw	a5,0(s5)
ffffffffc0201170:	1a079763          	bnez	a5,ffffffffc020131e <alloc_check+0x27e>
ffffffffc0201174:	411c                	lw	a5,0(a0)
ffffffffc0201176:	1a079463          	bnez	a5,ffffffffc020131e <alloc_check+0x27e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020117a:	00005797          	auipc	a5,0x5
ffffffffc020117e:	33e78793          	addi	a5,a5,830 # ffffffffc02064b8 <pages>
ffffffffc0201182:	639c                	ld	a5,0(a5)
ffffffffc0201184:	00001717          	auipc	a4,0x1
ffffffffc0201188:	64470713          	addi	a4,a4,1604 # ffffffffc02027c8 <commands+0x910>
ffffffffc020118c:	630c                	ld	a1,0(a4)
ffffffffc020118e:	40fa0733          	sub	a4,s4,a5
ffffffffc0201192:	870d                	srai	a4,a4,0x3
ffffffffc0201194:	02b70733          	mul	a4,a4,a1
ffffffffc0201198:	00002697          	auipc	a3,0x2
ffffffffc020119c:	a7868693          	addi	a3,a3,-1416 # ffffffffc0202c10 <nbase>
ffffffffc02011a0:	6290                	ld	a2,0(a3)

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011a2:	00005697          	auipc	a3,0x5
ffffffffc02011a6:	2c668693          	addi	a3,a3,710 # ffffffffc0206468 <npage>
ffffffffc02011aa:	6294                	ld	a3,0(a3)
ffffffffc02011ac:	06b2                	slli	a3,a3,0xc
ffffffffc02011ae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011b0:	0732                	slli	a4,a4,0xc
ffffffffc02011b2:	2cd77663          	bgeu	a4,a3,ffffffffc020147e <alloc_check+0x3de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02011b6:	40fb0733          	sub	a4,s6,a5
ffffffffc02011ba:	870d                	srai	a4,a4,0x3
ffffffffc02011bc:	02b70733          	mul	a4,a4,a1
ffffffffc02011c0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011c2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011c4:	28d77d63          	bgeu	a4,a3,ffffffffc020145e <alloc_check+0x3be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02011c8:	40fa8733          	sub	a4,s5,a5
ffffffffc02011cc:	870d                	srai	a4,a4,0x3
ffffffffc02011ce:	02b70733          	mul	a4,a4,a1
ffffffffc02011d2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02011d4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011d6:	20d77463          	bgeu	a4,a3,ffffffffc02013de <alloc_check+0x33e>
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
ffffffffc02011f4:	a42d                	j	ffffffffc020141e <alloc_check+0x37e>
    while ((le = list_next(le)) != &free_list)
    {
        p = le2page(le, page_link);
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02011f6:	ff846503          	lwu	a0,-8(s0)
ffffffffc02011fa:	93dff0ef          	jal	ra,ffffffffc0200b36 <buddy_allocate_pages>
ffffffffc02011fe:	10050063          	beqz	a0,ffffffffc02012fe <alloc_check+0x25e>
    return listelm->next;
ffffffffc0201202:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201204:	fe9419e3          	bne	s0,s1,ffffffffc02011f6 <alloc_check+0x156>
    }

    assert(alloc_page() == NULL);
ffffffffc0201208:	4505                	li	a0,1
ffffffffc020120a:	3b4000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc020120e:	34051863          	bnez	a0,ffffffffc020155e <alloc_check+0x4be>

    free_page(p0);
ffffffffc0201212:	4585                	li	a1,1
ffffffffc0201214:	8552                	mv	a0,s4
ffffffffc0201216:	3ec000ef          	jal	ra,ffffffffc0201602 <free_pages>
    free_page(p1);
ffffffffc020121a:	4585                	li	a1,1
ffffffffc020121c:	855a                	mv	a0,s6
ffffffffc020121e:	3e4000ef          	jal	ra,ffffffffc0201602 <free_pages>
    free_page(p2);
ffffffffc0201222:	4585                	li	a1,1
ffffffffc0201224:	8556                	mv	a0,s5
ffffffffc0201226:	3dc000ef          	jal	ra,ffffffffc0201602 <free_pages>
    assert(nr_free == 3);
ffffffffc020122a:	4818                	lw	a4,16(s0)
ffffffffc020122c:	478d                	li	a5,3
ffffffffc020122e:	1cf71863          	bne	a4,a5,ffffffffc02013fe <alloc_check+0x35e>

    assert((p1 = alloc_page()) != NULL);
ffffffffc0201232:	4505                	li	a0,1
ffffffffc0201234:	38a000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201238:	8a2a                	mv	s4,a0
ffffffffc020123a:	26050263          	beqz	a0,ffffffffc020149e <alloc_check+0x3fe>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc020123e:	4509                	li	a0,2
ffffffffc0201240:	37e000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201244:	842a                	mv	s0,a0
ffffffffc0201246:	2e050c63          	beqz	a0,ffffffffc020153e <alloc_check+0x49e>
    assert(p0 + 2 == p1);
ffffffffc020124a:	05050793          	addi	a5,a0,80
ffffffffc020124e:	2cfa1863          	bne	s4,a5,ffffffffc020151e <alloc_check+0x47e>

    assert(alloc_page() == NULL);
ffffffffc0201252:	4505                	li	a0,1
ffffffffc0201254:	36a000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201258:	1e051363          	bnez	a0,ffffffffc020143e <alloc_check+0x39e>

    free_pages(p0, 2);
ffffffffc020125c:	4589                	li	a1,2
ffffffffc020125e:	8522                	mv	a0,s0
ffffffffc0201260:	3a2000ef          	jal	ra,ffffffffc0201602 <free_pages>
    free_page(p1);
ffffffffc0201264:	4585                	li	a1,1
ffffffffc0201266:	8552                	mv	a0,s4
ffffffffc0201268:	39a000ef          	jal	ra,ffffffffc0201602 <free_pages>
    free_page(p3);
ffffffffc020126c:	855e                	mv	a0,s7
ffffffffc020126e:	4585                	li	a1,1
ffffffffc0201270:	392000ef          	jal	ra,ffffffffc0201602 <free_pages>

    assert((p = alloc_pages(4)) == p0);
ffffffffc0201274:	4511                	li	a0,4
ffffffffc0201276:	348000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc020127a:	32a41263          	bne	s0,a0,ffffffffc020159e <alloc_check+0x4fe>
    assert(alloc_page() == NULL);
ffffffffc020127e:	4505                	li	a0,1
ffffffffc0201280:	33e000ef          	jal	ra,ffffffffc02015be <alloc_pages>
ffffffffc0201284:	26051d63          	bnez	a0,ffffffffc02014fe <alloc_check+0x45e>

    assert(nr_free == 0);
ffffffffc0201288:	489c                	lw	a5,16(s1)
ffffffffc020128a:	24079a63          	bnez	a5,ffffffffc02014de <alloc_check+0x43e>

    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc020128e:	00093783          	ld	a5,0(s2)
ffffffffc0201292:	00299693          	slli	a3,s3,0x2
ffffffffc0201296:	96ce                	add	a3,a3,s3
ffffffffc0201298:	068e                	slli	a3,a3,0x3
ffffffffc020129a:	00d78733          	add	a4,a5,a3
ffffffffc020129e:	04e7fe63          	bgeu	a5,a4,ffffffffc02012fa <alloc_check+0x25a>
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
ffffffffc02012bc:	85ce                	mv	a1,s3
    elm->prev = elm->next = elm;
ffffffffc02012be:	00005797          	auipc	a5,0x5
ffffffffc02012c2:	1c97b923          	sd	s1,466(a5) # ffffffffc0206490 <free_area+0x8>
ffffffffc02012c6:	00005797          	auipc	a5,0x5
ffffffffc02012ca:	1c97b123          	sd	s1,450(a5) # ffffffffc0206488 <free_area>
    nr_free = 0;
ffffffffc02012ce:	00005797          	auipc	a5,0x5
ffffffffc02012d2:	1c07a523          	sw	zero,458(a5) # ffffffffc0206498 <free_area+0x10>
    buddy_init_memmap(physical_area, total_size_store);
ffffffffc02012d6:	da3ff0ef          	jal	ra,ffffffffc0201078 <buddy_init_memmap>
    cprintf("buddy succeeded!\n");
}
ffffffffc02012da:	6406                	ld	s0,64(sp)
ffffffffc02012dc:	60a6                	ld	ra,72(sp)
ffffffffc02012de:	74e2                	ld	s1,56(sp)
ffffffffc02012e0:	7942                	ld	s2,48(sp)
ffffffffc02012e2:	79a2                	ld	s3,40(sp)
ffffffffc02012e4:	7a02                	ld	s4,32(sp)
ffffffffc02012e6:	6ae2                	ld	s5,24(sp)
ffffffffc02012e8:	6b42                	ld	s6,16(sp)
ffffffffc02012ea:	6ba2                	ld	s7,8(sp)
    cprintf("buddy succeeded!\n");
ffffffffc02012ec:	00001517          	auipc	a0,0x1
ffffffffc02012f0:	4c450513          	addi	a0,a0,1220 # ffffffffc02027b0 <commands+0x8f8>
}
ffffffffc02012f4:	6161                	addi	sp,sp,80
    cprintf("buddy succeeded!\n");
ffffffffc02012f6:	dc1fe06f          	j	ffffffffc02000b6 <cprintf>
    for (p = physical_area; p < physical_area + total_size_store; p++)
ffffffffc02012fa:	853e                	mv	a0,a5
ffffffffc02012fc:	b7c1                	j	ffffffffc02012bc <alloc_check+0x21c>
        assert(buddy_allocate_pages(p->property) != NULL);
ffffffffc02012fe:	00001697          	auipc	a3,0x1
ffffffffc0201302:	3fa68693          	addi	a3,a3,1018 # ffffffffc02026f8 <commands+0x840>
ffffffffc0201306:	00001617          	auipc	a2,0x1
ffffffffc020130a:	4d260613          	addi	a2,a2,1234 # ffffffffc02027d8 <commands+0x920>
ffffffffc020130e:	0ee00593          	li	a1,238
ffffffffc0201312:	00001517          	auipc	a0,0x1
ffffffffc0201316:	4de50513          	addi	a0,a0,1246 # ffffffffc02027f0 <commands+0x938>
ffffffffc020131a:	88eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
ffffffffc020131e:	00001697          	auipc	a3,0x1
ffffffffc0201322:	30268693          	addi	a3,a3,770 # ffffffffc0202620 <commands+0x768>
ffffffffc0201326:	00001617          	auipc	a2,0x1
ffffffffc020132a:	4b260613          	addi	a2,a2,1202 # ffffffffc02027d8 <commands+0x920>
ffffffffc020132e:	0e300593          	li	a1,227
ffffffffc0201332:	00001517          	auipc	a0,0x1
ffffffffc0201336:	4be50513          	addi	a0,a0,1214 # ffffffffc02027f0 <commands+0x938>
ffffffffc020133a:	86eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 1 == p1);
ffffffffc020133e:	00001697          	auipc	a3,0x1
ffffffffc0201342:	2b268693          	addi	a3,a3,690 # ffffffffc02025f0 <commands+0x738>
ffffffffc0201346:	00001617          	auipc	a2,0x1
ffffffffc020134a:	49260613          	addi	a2,a2,1170 # ffffffffc02027d8 <commands+0x920>
ffffffffc020134e:	0e000593          	li	a1,224
ffffffffc0201352:	00001517          	auipc	a0,0x1
ffffffffc0201356:	49e50513          	addi	a0,a0,1182 # ffffffffc02027f0 <commands+0x938>
ffffffffc020135a:	84eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p3 = alloc_page()) != NULL);
ffffffffc020135e:	00001697          	auipc	a3,0x1
ffffffffc0201362:	27268693          	addi	a3,a3,626 # ffffffffc02025d0 <commands+0x718>
ffffffffc0201366:	00001617          	auipc	a2,0x1
ffffffffc020136a:	47260613          	addi	a2,a2,1138 # ffffffffc02027d8 <commands+0x920>
ffffffffc020136e:	0de00593          	li	a1,222
ffffffffc0201372:	00001517          	auipc	a0,0x1
ffffffffc0201376:	47e50513          	addi	a0,a0,1150 # ffffffffc02027f0 <commands+0x938>
ffffffffc020137a:	82eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020137e:	00001697          	auipc	a3,0x1
ffffffffc0201382:	23268693          	addi	a3,a3,562 # ffffffffc02025b0 <commands+0x6f8>
ffffffffc0201386:	00001617          	auipc	a2,0x1
ffffffffc020138a:	45260613          	addi	a2,a2,1106 # ffffffffc02027d8 <commands+0x920>
ffffffffc020138e:	0dd00593          	li	a1,221
ffffffffc0201392:	00001517          	auipc	a0,0x1
ffffffffc0201396:	45e50513          	addi	a0,a0,1118 # ffffffffc02027f0 <commands+0x938>
ffffffffc020139a:	80eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020139e:	00001697          	auipc	a3,0x1
ffffffffc02013a2:	1f268693          	addi	a3,a3,498 # ffffffffc0202590 <commands+0x6d8>
ffffffffc02013a6:	00001617          	auipc	a2,0x1
ffffffffc02013aa:	43260613          	addi	a2,a2,1074 # ffffffffc02027d8 <commands+0x920>
ffffffffc02013ae:	0dc00593          	li	a1,220
ffffffffc02013b2:	00001517          	auipc	a0,0x1
ffffffffc02013b6:	43e50513          	addi	a0,a0,1086 # ffffffffc02027f0 <commands+0x938>
ffffffffc02013ba:	feffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p1 + 1 == p2);
ffffffffc02013be:	00001697          	auipc	a3,0x1
ffffffffc02013c2:	24268693          	addi	a3,a3,578 # ffffffffc0202600 <commands+0x748>
ffffffffc02013c6:	00001617          	auipc	a2,0x1
ffffffffc02013ca:	41260613          	addi	a2,a2,1042 # ffffffffc02027d8 <commands+0x920>
ffffffffc02013ce:	0e100593          	li	a1,225
ffffffffc02013d2:	00001517          	auipc	a0,0x1
ffffffffc02013d6:	41e50513          	addi	a0,a0,1054 # ffffffffc02027f0 <commands+0x938>
ffffffffc02013da:	fcffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013de:	00001697          	auipc	a3,0x1
ffffffffc02013e2:	2da68693          	addi	a3,a3,730 # ffffffffc02026b8 <commands+0x800>
ffffffffc02013e6:	00001617          	auipc	a2,0x1
ffffffffc02013ea:	3f260613          	addi	a2,a2,1010 # ffffffffc02027d8 <commands+0x920>
ffffffffc02013ee:	0e700593          	li	a1,231
ffffffffc02013f2:	00001517          	auipc	a0,0x1
ffffffffc02013f6:	3fe50513          	addi	a0,a0,1022 # ffffffffc02027f0 <commands+0x938>
ffffffffc02013fa:	faffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 3);
ffffffffc02013fe:	00001697          	auipc	a3,0x1
ffffffffc0201402:	34268693          	addi	a3,a3,834 # ffffffffc0202740 <commands+0x888>
ffffffffc0201406:	00001617          	auipc	a2,0x1
ffffffffc020140a:	3d260613          	addi	a2,a2,978 # ffffffffc02027d8 <commands+0x920>
ffffffffc020140e:	0f600593          	li	a1,246
ffffffffc0201412:	00001517          	auipc	a0,0x1
ffffffffc0201416:	3de50513          	addi	a0,a0,990 # ffffffffc02027f0 <commands+0x938>
ffffffffc020141a:	f8ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p3) < npage * PGSIZE);
ffffffffc020141e:	00001697          	auipc	a3,0x1
ffffffffc0201422:	2ba68693          	addi	a3,a3,698 # ffffffffc02026d8 <commands+0x820>
ffffffffc0201426:	00001617          	auipc	a2,0x1
ffffffffc020142a:	3b260613          	addi	a2,a2,946 # ffffffffc02027d8 <commands+0x920>
ffffffffc020142e:	0e800593          	li	a1,232
ffffffffc0201432:	00001517          	auipc	a0,0x1
ffffffffc0201436:	3be50513          	addi	a0,a0,958 # ffffffffc02027f0 <commands+0x938>
ffffffffc020143a:	f6ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020143e:	00001697          	auipc	a3,0x1
ffffffffc0201442:	2ea68693          	addi	a3,a3,746 # ffffffffc0202728 <commands+0x870>
ffffffffc0201446:	00001617          	auipc	a2,0x1
ffffffffc020144a:	39260613          	addi	a2,a2,914 # ffffffffc02027d8 <commands+0x920>
ffffffffc020144e:	0fc00593          	li	a1,252
ffffffffc0201452:	00001517          	auipc	a0,0x1
ffffffffc0201456:	39e50513          	addi	a0,a0,926 # ffffffffc02027f0 <commands+0x938>
ffffffffc020145a:	f4ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020145e:	00001697          	auipc	a3,0x1
ffffffffc0201462:	23a68693          	addi	a3,a3,570 # ffffffffc0202698 <commands+0x7e0>
ffffffffc0201466:	00001617          	auipc	a2,0x1
ffffffffc020146a:	37260613          	addi	a2,a2,882 # ffffffffc02027d8 <commands+0x920>
ffffffffc020146e:	0e600593          	li	a1,230
ffffffffc0201472:	00001517          	auipc	a0,0x1
ffffffffc0201476:	37e50513          	addi	a0,a0,894 # ffffffffc02027f0 <commands+0x938>
ffffffffc020147a:	f2ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020147e:	00001697          	auipc	a3,0x1
ffffffffc0201482:	1fa68693          	addi	a3,a3,506 # ffffffffc0202678 <commands+0x7c0>
ffffffffc0201486:	00001617          	auipc	a2,0x1
ffffffffc020148a:	35260613          	addi	a2,a2,850 # ffffffffc02027d8 <commands+0x920>
ffffffffc020148e:	0e500593          	li	a1,229
ffffffffc0201492:	00001517          	auipc	a0,0x1
ffffffffc0201496:	35e50513          	addi	a0,a0,862 # ffffffffc02027f0 <commands+0x938>
ffffffffc020149a:	f0ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020149e:	00001697          	auipc	a3,0x1
ffffffffc02014a2:	0f268693          	addi	a3,a3,242 # ffffffffc0202590 <commands+0x6d8>
ffffffffc02014a6:	00001617          	auipc	a2,0x1
ffffffffc02014aa:	33260613          	addi	a2,a2,818 # ffffffffc02027d8 <commands+0x920>
ffffffffc02014ae:	0f800593          	li	a1,248
ffffffffc02014b2:	00001517          	auipc	a0,0x1
ffffffffc02014b6:	33e50513          	addi	a0,a0,830 # ffffffffc02027f0 <commands+0x938>
ffffffffc02014ba:	eeffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014be:	00001697          	auipc	a3,0x1
ffffffffc02014c2:	0b268693          	addi	a3,a3,178 # ffffffffc0202570 <commands+0x6b8>
ffffffffc02014c6:	00001617          	auipc	a2,0x1
ffffffffc02014ca:	31260613          	addi	a2,a2,786 # ffffffffc02027d8 <commands+0x920>
ffffffffc02014ce:	0db00593          	li	a1,219
ffffffffc02014d2:	00001517          	auipc	a0,0x1
ffffffffc02014d6:	31e50513          	addi	a0,a0,798 # ffffffffc02027f0 <commands+0x938>
ffffffffc02014da:	ecffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc02014de:	00001697          	auipc	a3,0x1
ffffffffc02014e2:	2c268693          	addi	a3,a3,706 # ffffffffc02027a0 <commands+0x8e8>
ffffffffc02014e6:	00001617          	auipc	a2,0x1
ffffffffc02014ea:	2f260613          	addi	a2,a2,754 # ffffffffc02027d8 <commands+0x920>
ffffffffc02014ee:	10500593          	li	a1,261
ffffffffc02014f2:	00001517          	auipc	a0,0x1
ffffffffc02014f6:	2fe50513          	addi	a0,a0,766 # ffffffffc02027f0 <commands+0x938>
ffffffffc02014fa:	eaffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014fe:	00001697          	auipc	a3,0x1
ffffffffc0201502:	22a68693          	addi	a3,a3,554 # ffffffffc0202728 <commands+0x870>
ffffffffc0201506:	00001617          	auipc	a2,0x1
ffffffffc020150a:	2d260613          	addi	a2,a2,722 # ffffffffc02027d8 <commands+0x920>
ffffffffc020150e:	10300593          	li	a1,259
ffffffffc0201512:	00001517          	auipc	a0,0x1
ffffffffc0201516:	2de50513          	addi	a0,a0,734 # ffffffffc02027f0 <commands+0x938>
ffffffffc020151a:	e8ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020151e:	00001697          	auipc	a3,0x1
ffffffffc0201522:	25268693          	addi	a3,a3,594 # ffffffffc0202770 <commands+0x8b8>
ffffffffc0201526:	00001617          	auipc	a2,0x1
ffffffffc020152a:	2b260613          	addi	a2,a2,690 # ffffffffc02027d8 <commands+0x920>
ffffffffc020152e:	0fa00593          	li	a1,250
ffffffffc0201532:	00001517          	auipc	a0,0x1
ffffffffc0201536:	2be50513          	addi	a0,a0,702 # ffffffffc02027f0 <commands+0x938>
ffffffffc020153a:	e6ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc020153e:	00001697          	auipc	a3,0x1
ffffffffc0201542:	21268693          	addi	a3,a3,530 # ffffffffc0202750 <commands+0x898>
ffffffffc0201546:	00001617          	auipc	a2,0x1
ffffffffc020154a:	29260613          	addi	a2,a2,658 # ffffffffc02027d8 <commands+0x920>
ffffffffc020154e:	0f900593          	li	a1,249
ffffffffc0201552:	00001517          	auipc	a0,0x1
ffffffffc0201556:	29e50513          	addi	a0,a0,670 # ffffffffc02027f0 <commands+0x938>
ffffffffc020155a:	e4ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020155e:	00001697          	auipc	a3,0x1
ffffffffc0201562:	1ca68693          	addi	a3,a3,458 # ffffffffc0202728 <commands+0x870>
ffffffffc0201566:	00001617          	auipc	a2,0x1
ffffffffc020156a:	27260613          	addi	a2,a2,626 # ffffffffc02027d8 <commands+0x920>
ffffffffc020156e:	0f100593          	li	a1,241
ffffffffc0201572:	00001517          	auipc	a0,0x1
ffffffffc0201576:	27e50513          	addi	a0,a0,638 # ffffffffc02027f0 <commands+0x938>
ffffffffc020157a:	e2ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p2 + 1 == p3);
ffffffffc020157e:	00001697          	auipc	a3,0x1
ffffffffc0201582:	09268693          	addi	a3,a3,146 # ffffffffc0202610 <commands+0x758>
ffffffffc0201586:	00001617          	auipc	a2,0x1
ffffffffc020158a:	25260613          	addi	a2,a2,594 # ffffffffc02027d8 <commands+0x920>
ffffffffc020158e:	0e200593          	li	a1,226
ffffffffc0201592:	00001517          	auipc	a0,0x1
ffffffffc0201596:	25e50513          	addi	a0,a0,606 # ffffffffc02027f0 <commands+0x938>
ffffffffc020159a:	e0ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p = alloc_pages(4)) == p0);
ffffffffc020159e:	00001697          	auipc	a3,0x1
ffffffffc02015a2:	1e268693          	addi	a3,a3,482 # ffffffffc0202780 <commands+0x8c8>
ffffffffc02015a6:	00001617          	auipc	a2,0x1
ffffffffc02015aa:	23260613          	addi	a2,a2,562 # ffffffffc02027d8 <commands+0x920>
ffffffffc02015ae:	10200593          	li	a1,258
ffffffffc02015b2:	00001517          	auipc	a0,0x1
ffffffffc02015b6:	23e50513          	addi	a0,a0,574 # ffffffffc02027f0 <commands+0x938>
ffffffffc02015ba:	deffe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02015be <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015be:	100027f3          	csrr	a5,sstatus
ffffffffc02015c2:	8b89                	andi	a5,a5,2
ffffffffc02015c4:	eb89                	bnez	a5,ffffffffc02015d6 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02015c6:	00005797          	auipc	a5,0x5
ffffffffc02015ca:	ee278793          	addi	a5,a5,-286 # ffffffffc02064a8 <pmm_manager>
ffffffffc02015ce:	639c                	ld	a5,0(a5)
ffffffffc02015d0:	0187b303          	ld	t1,24(a5)
ffffffffc02015d4:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02015d6:	1141                	addi	sp,sp,-16
ffffffffc02015d8:	e406                	sd	ra,8(sp)
ffffffffc02015da:	e022                	sd	s0,0(sp)
ffffffffc02015dc:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02015de:	e81fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02015e2:	00005797          	auipc	a5,0x5
ffffffffc02015e6:	ec678793          	addi	a5,a5,-314 # ffffffffc02064a8 <pmm_manager>
ffffffffc02015ea:	639c                	ld	a5,0(a5)
ffffffffc02015ec:	8522                	mv	a0,s0
ffffffffc02015ee:	6f9c                	ld	a5,24(a5)
ffffffffc02015f0:	9782                	jalr	a5
ffffffffc02015f2:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02015f4:	e65fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02015f8:	8522                	mv	a0,s0
ffffffffc02015fa:	60a2                	ld	ra,8(sp)
ffffffffc02015fc:	6402                	ld	s0,0(sp)
ffffffffc02015fe:	0141                	addi	sp,sp,16
ffffffffc0201600:	8082                	ret

ffffffffc0201602 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201602:	100027f3          	csrr	a5,sstatus
ffffffffc0201606:	8b89                	andi	a5,a5,2
ffffffffc0201608:	eb89                	bnez	a5,ffffffffc020161a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020160a:	00005797          	auipc	a5,0x5
ffffffffc020160e:	e9e78793          	addi	a5,a5,-354 # ffffffffc02064a8 <pmm_manager>
ffffffffc0201612:	639c                	ld	a5,0(a5)
ffffffffc0201614:	0207b303          	ld	t1,32(a5)
ffffffffc0201618:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020161a:	1101                	addi	sp,sp,-32
ffffffffc020161c:	ec06                	sd	ra,24(sp)
ffffffffc020161e:	e822                	sd	s0,16(sp)
ffffffffc0201620:	e426                	sd	s1,8(sp)
ffffffffc0201622:	842a                	mv	s0,a0
ffffffffc0201624:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201626:	e39fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020162a:	00005797          	auipc	a5,0x5
ffffffffc020162e:	e7e78793          	addi	a5,a5,-386 # ffffffffc02064a8 <pmm_manager>
ffffffffc0201632:	639c                	ld	a5,0(a5)
ffffffffc0201634:	85a6                	mv	a1,s1
ffffffffc0201636:	8522                	mv	a0,s0
ffffffffc0201638:	739c                	ld	a5,32(a5)
ffffffffc020163a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020163c:	6442                	ld	s0,16(sp)
ffffffffc020163e:	60e2                	ld	ra,24(sp)
ffffffffc0201640:	64a2                	ld	s1,8(sp)
ffffffffc0201642:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201644:	e15fe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201648 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201648:	00001797          	auipc	a5,0x1
ffffffffc020164c:	20878793          	addi	a5,a5,520 # ffffffffc0202850 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201650:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201652:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201654:	00001517          	auipc	a0,0x1
ffffffffc0201658:	24c50513          	addi	a0,a0,588 # ffffffffc02028a0 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc020165c:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020165e:	00005717          	auipc	a4,0x5
ffffffffc0201662:	e4f73523          	sd	a5,-438(a4) # ffffffffc02064a8 <pmm_manager>
void pmm_init(void) {
ffffffffc0201666:	e822                	sd	s0,16(sp)
ffffffffc0201668:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020166a:	00005417          	auipc	s0,0x5
ffffffffc020166e:	e3e40413          	addi	s0,s0,-450 # ffffffffc02064a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201672:	a45fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201676:	601c                	ld	a5,0(s0)
ffffffffc0201678:	679c                	ld	a5,8(a5)
ffffffffc020167a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020167c:	57f5                	li	a5,-3
ffffffffc020167e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201680:	00001517          	auipc	a0,0x1
ffffffffc0201684:	23850513          	addi	a0,a0,568 # ffffffffc02028b8 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201688:	00005717          	auipc	a4,0x5
ffffffffc020168c:	e2f73423          	sd	a5,-472(a4) # ffffffffc02064b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201690:	a27fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201694:	46c5                	li	a3,17
ffffffffc0201696:	06ee                	slli	a3,a3,0x1b
ffffffffc0201698:	40100613          	li	a2,1025
ffffffffc020169c:	16fd                	addi	a3,a3,-1
ffffffffc020169e:	0656                	slli	a2,a2,0x15
ffffffffc02016a0:	07e005b7          	lui	a1,0x7e00
ffffffffc02016a4:	00001517          	auipc	a0,0x1
ffffffffc02016a8:	22c50513          	addi	a0,a0,556 # ffffffffc02028d0 <buddy_pmm_manager+0x80>
ffffffffc02016ac:	a0bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016b0:	777d                	lui	a4,0xfffff
ffffffffc02016b2:	00006797          	auipc	a5,0x6
ffffffffc02016b6:	e0d78793          	addi	a5,a5,-499 # ffffffffc02074bf <end+0xfff>
ffffffffc02016ba:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016bc:	00088737          	lui	a4,0x88
ffffffffc02016c0:	00005697          	auipc	a3,0x5
ffffffffc02016c4:	dae6b423          	sd	a4,-600(a3) # ffffffffc0206468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016c8:	4601                	li	a2,0
ffffffffc02016ca:	00005717          	auipc	a4,0x5
ffffffffc02016ce:	def73723          	sd	a5,-530(a4) # ffffffffc02064b8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016d2:	4681                	li	a3,0
ffffffffc02016d4:	00005897          	auipc	a7,0x5
ffffffffc02016d8:	d9488893          	addi	a7,a7,-620 # ffffffffc0206468 <npage>
ffffffffc02016dc:	00005597          	auipc	a1,0x5
ffffffffc02016e0:	ddc58593          	addi	a1,a1,-548 # ffffffffc02064b8 <pages>
ffffffffc02016e4:	4805                	li	a6,1
ffffffffc02016e6:	fff80537          	lui	a0,0xfff80
ffffffffc02016ea:	a011                	j	ffffffffc02016ee <pmm_init+0xa6>
ffffffffc02016ec:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02016ee:	97b2                	add	a5,a5,a2
ffffffffc02016f0:	07a1                	addi	a5,a5,8
ffffffffc02016f2:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016f6:	0008b703          	ld	a4,0(a7)
ffffffffc02016fa:	0685                	addi	a3,a3,1
ffffffffc02016fc:	02860613          	addi	a2,a2,40
ffffffffc0201700:	00a707b3          	add	a5,a4,a0
ffffffffc0201704:	fef6e4e3          	bltu	a3,a5,ffffffffc02016ec <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201708:	6190                	ld	a2,0(a1)
ffffffffc020170a:	00271793          	slli	a5,a4,0x2
ffffffffc020170e:	97ba                	add	a5,a5,a4
ffffffffc0201710:	fec006b7          	lui	a3,0xfec00
ffffffffc0201714:	078e                	slli	a5,a5,0x3
ffffffffc0201716:	96b2                	add	a3,a3,a2
ffffffffc0201718:	96be                	add	a3,a3,a5
ffffffffc020171a:	c02007b7          	lui	a5,0xc0200
ffffffffc020171e:	08f6e863          	bltu	a3,a5,ffffffffc02017ae <pmm_init+0x166>
ffffffffc0201722:	00005497          	auipc	s1,0x5
ffffffffc0201726:	d8e48493          	addi	s1,s1,-626 # ffffffffc02064b0 <va_pa_offset>
ffffffffc020172a:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc020172c:	45c5                	li	a1,17
ffffffffc020172e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201730:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201732:	04b6e963          	bltu	a3,a1,ffffffffc0201784 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201736:	601c                	ld	a5,0(s0)
ffffffffc0201738:	7b9c                	ld	a5,48(a5)
ffffffffc020173a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020173c:	00001517          	auipc	a0,0x1
ffffffffc0201740:	22c50513          	addi	a0,a0,556 # ffffffffc0202968 <buddy_pmm_manager+0x118>
ffffffffc0201744:	973fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201748:	00004697          	auipc	a3,0x4
ffffffffc020174c:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201750:	00005797          	auipc	a5,0x5
ffffffffc0201754:	d2d7b023          	sd	a3,-736(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201758:	c02007b7          	lui	a5,0xc0200
ffffffffc020175c:	06f6e563          	bltu	a3,a5,ffffffffc02017c6 <pmm_init+0x17e>
ffffffffc0201760:	609c                	ld	a5,0(s1)
}
ffffffffc0201762:	6442                	ld	s0,16(sp)
ffffffffc0201764:	60e2                	ld	ra,24(sp)
ffffffffc0201766:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201768:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020176a:	8e9d                	sub	a3,a3,a5
ffffffffc020176c:	00005797          	auipc	a5,0x5
ffffffffc0201770:	d2d7ba23          	sd	a3,-716(a5) # ffffffffc02064a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201774:	00001517          	auipc	a0,0x1
ffffffffc0201778:	21450513          	addi	a0,a0,532 # ffffffffc0202988 <buddy_pmm_manager+0x138>
ffffffffc020177c:	8636                	mv	a2,a3
}
ffffffffc020177e:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201780:	937fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201784:	6785                	lui	a5,0x1
ffffffffc0201786:	17fd                	addi	a5,a5,-1
ffffffffc0201788:	96be                	add	a3,a3,a5
ffffffffc020178a:	77fd                	lui	a5,0xfffff
ffffffffc020178c:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020178e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201792:	04e7f663          	bgeu	a5,a4,ffffffffc02017de <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201796:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201798:	97aa                	add	a5,a5,a0
ffffffffc020179a:	00279513          	slli	a0,a5,0x2
ffffffffc020179e:	953e                	add	a0,a0,a5
ffffffffc02017a0:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02017a2:	8d95                	sub	a1,a1,a3
ffffffffc02017a4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02017a6:	81b1                	srli	a1,a1,0xc
ffffffffc02017a8:	9532                	add	a0,a0,a2
ffffffffc02017aa:	9782                	jalr	a5
ffffffffc02017ac:	b769                	j	ffffffffc0201736 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017ae:	00001617          	auipc	a2,0x1
ffffffffc02017b2:	15260613          	addi	a2,a2,338 # ffffffffc0202900 <buddy_pmm_manager+0xb0>
ffffffffc02017b6:	07000593          	li	a1,112
ffffffffc02017ba:	00001517          	auipc	a0,0x1
ffffffffc02017be:	16e50513          	addi	a0,a0,366 # ffffffffc0202928 <buddy_pmm_manager+0xd8>
ffffffffc02017c2:	be7fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02017c6:	00001617          	auipc	a2,0x1
ffffffffc02017ca:	13a60613          	addi	a2,a2,314 # ffffffffc0202900 <buddy_pmm_manager+0xb0>
ffffffffc02017ce:	08b00593          	li	a1,139
ffffffffc02017d2:	00001517          	auipc	a0,0x1
ffffffffc02017d6:	15650513          	addi	a0,a0,342 # ffffffffc0202928 <buddy_pmm_manager+0xd8>
ffffffffc02017da:	bcffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02017de:	00001617          	auipc	a2,0x1
ffffffffc02017e2:	15a60613          	addi	a2,a2,346 # ffffffffc0202938 <buddy_pmm_manager+0xe8>
ffffffffc02017e6:	06b00593          	li	a1,107
ffffffffc02017ea:	00001517          	auipc	a0,0x1
ffffffffc02017ee:	16e50513          	addi	a0,a0,366 # ffffffffc0202958 <buddy_pmm_manager+0x108>
ffffffffc02017f2:	bb7fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02017f6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02017f6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017fa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02017fc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201800:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201802:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201806:	f022                	sd	s0,32(sp)
ffffffffc0201808:	ec26                	sd	s1,24(sp)
ffffffffc020180a:	e84a                	sd	s2,16(sp)
ffffffffc020180c:	f406                	sd	ra,40(sp)
ffffffffc020180e:	e44e                	sd	s3,8(sp)
ffffffffc0201810:	84aa                	mv	s1,a0
ffffffffc0201812:	892e                	mv	s2,a1
ffffffffc0201814:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201818:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020181a:	03067e63          	bgeu	a2,a6,ffffffffc0201856 <printnum+0x60>
ffffffffc020181e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201820:	00805763          	blez	s0,ffffffffc020182e <printnum+0x38>
ffffffffc0201824:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201826:	85ca                	mv	a1,s2
ffffffffc0201828:	854e                	mv	a0,s3
ffffffffc020182a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020182c:	fc65                	bnez	s0,ffffffffc0201824 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020182e:	1a02                	slli	s4,s4,0x20
ffffffffc0201830:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201834:	00001797          	auipc	a5,0x1
ffffffffc0201838:	32478793          	addi	a5,a5,804 # ffffffffc0202b58 <error_string+0x38>
ffffffffc020183c:	9a3e                	add	s4,s4,a5
}
ffffffffc020183e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201840:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201844:	70a2                	ld	ra,40(sp)
ffffffffc0201846:	69a2                	ld	s3,8(sp)
ffffffffc0201848:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020184a:	85ca                	mv	a1,s2
ffffffffc020184c:	8326                	mv	t1,s1
}
ffffffffc020184e:	6942                	ld	s2,16(sp)
ffffffffc0201850:	64e2                	ld	s1,24(sp)
ffffffffc0201852:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201854:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201856:	03065633          	divu	a2,a2,a6
ffffffffc020185a:	8722                	mv	a4,s0
ffffffffc020185c:	f9bff0ef          	jal	ra,ffffffffc02017f6 <printnum>
ffffffffc0201860:	b7f9                	j	ffffffffc020182e <printnum+0x38>

ffffffffc0201862 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201862:	7119                	addi	sp,sp,-128
ffffffffc0201864:	f4a6                	sd	s1,104(sp)
ffffffffc0201866:	f0ca                	sd	s2,96(sp)
ffffffffc0201868:	e8d2                	sd	s4,80(sp)
ffffffffc020186a:	e4d6                	sd	s5,72(sp)
ffffffffc020186c:	e0da                	sd	s6,64(sp)
ffffffffc020186e:	fc5e                	sd	s7,56(sp)
ffffffffc0201870:	f862                	sd	s8,48(sp)
ffffffffc0201872:	f06a                	sd	s10,32(sp)
ffffffffc0201874:	fc86                	sd	ra,120(sp)
ffffffffc0201876:	f8a2                	sd	s0,112(sp)
ffffffffc0201878:	ecce                	sd	s3,88(sp)
ffffffffc020187a:	f466                	sd	s9,40(sp)
ffffffffc020187c:	ec6e                	sd	s11,24(sp)
ffffffffc020187e:	892a                	mv	s2,a0
ffffffffc0201880:	84ae                	mv	s1,a1
ffffffffc0201882:	8d32                	mv	s10,a2
ffffffffc0201884:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201886:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201888:	00001a17          	auipc	s4,0x1
ffffffffc020188c:	140a0a13          	addi	s4,s4,320 # ffffffffc02029c8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201890:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201894:	00001c17          	auipc	s8,0x1
ffffffffc0201898:	28cc0c13          	addi	s8,s8,652 # ffffffffc0202b20 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020189c:	000d4503          	lbu	a0,0(s10)
ffffffffc02018a0:	02500793          	li	a5,37
ffffffffc02018a4:	001d0413          	addi	s0,s10,1
ffffffffc02018a8:	00f50e63          	beq	a0,a5,ffffffffc02018c4 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02018ac:	c521                	beqz	a0,ffffffffc02018f4 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018ae:	02500993          	li	s3,37
ffffffffc02018b2:	a011                	j	ffffffffc02018b6 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02018b4:	c121                	beqz	a0,ffffffffc02018f4 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02018b6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018b8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02018ba:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018bc:	fff44503          	lbu	a0,-1(s0)
ffffffffc02018c0:	ff351ae3          	bne	a0,s3,ffffffffc02018b4 <vprintfmt+0x52>
ffffffffc02018c4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02018c8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02018cc:	4981                	li	s3,0
ffffffffc02018ce:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02018d0:	5cfd                	li	s9,-1
ffffffffc02018d2:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018d4:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02018d8:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018da:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02018de:	0ff6f693          	andi	a3,a3,255
ffffffffc02018e2:	00140d13          	addi	s10,s0,1
ffffffffc02018e6:	1ed5ef63          	bltu	a1,a3,ffffffffc0201ae4 <vprintfmt+0x282>
ffffffffc02018ea:	068a                	slli	a3,a3,0x2
ffffffffc02018ec:	96d2                	add	a3,a3,s4
ffffffffc02018ee:	4294                	lw	a3,0(a3)
ffffffffc02018f0:	96d2                	add	a3,a3,s4
ffffffffc02018f2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02018f4:	70e6                	ld	ra,120(sp)
ffffffffc02018f6:	7446                	ld	s0,112(sp)
ffffffffc02018f8:	74a6                	ld	s1,104(sp)
ffffffffc02018fa:	7906                	ld	s2,96(sp)
ffffffffc02018fc:	69e6                	ld	s3,88(sp)
ffffffffc02018fe:	6a46                	ld	s4,80(sp)
ffffffffc0201900:	6aa6                	ld	s5,72(sp)
ffffffffc0201902:	6b06                	ld	s6,64(sp)
ffffffffc0201904:	7be2                	ld	s7,56(sp)
ffffffffc0201906:	7c42                	ld	s8,48(sp)
ffffffffc0201908:	7ca2                	ld	s9,40(sp)
ffffffffc020190a:	7d02                	ld	s10,32(sp)
ffffffffc020190c:	6de2                	ld	s11,24(sp)
ffffffffc020190e:	6109                	addi	sp,sp,128
ffffffffc0201910:	8082                	ret
            padc = '-';
ffffffffc0201912:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201914:	00144603          	lbu	a2,1(s0)
ffffffffc0201918:	846a                	mv	s0,s10
ffffffffc020191a:	b7c1                	j	ffffffffc02018da <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020191c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201920:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201924:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201926:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201928:	fa0dd9e3          	bgez	s11,ffffffffc02018da <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020192c:	8de6                	mv	s11,s9
ffffffffc020192e:	5cfd                	li	s9,-1
ffffffffc0201930:	b76d                	j	ffffffffc02018da <vprintfmt+0x78>
            if (width < 0)
ffffffffc0201932:	fffdc693          	not	a3,s11
ffffffffc0201936:	96fd                	srai	a3,a3,0x3f
ffffffffc0201938:	00ddfdb3          	and	s11,s11,a3
ffffffffc020193c:	00144603          	lbu	a2,1(s0)
ffffffffc0201940:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201942:	846a                	mv	s0,s10
ffffffffc0201944:	bf59                	j	ffffffffc02018da <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201946:	4705                	li	a4,1
ffffffffc0201948:	008a8593          	addi	a1,s5,8
ffffffffc020194c:	01074463          	blt	a4,a6,ffffffffc0201954 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0201950:	22080863          	beqz	a6,ffffffffc0201b80 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0201954:	000ab603          	ld	a2,0(s5)
ffffffffc0201958:	46c1                	li	a3,16
ffffffffc020195a:	8aae                	mv	s5,a1
ffffffffc020195c:	a291                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020195e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201962:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201966:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201968:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020196c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201970:	fad56ce3          	bltu	a0,a3,ffffffffc0201928 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201974:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201976:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020197a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020197e:	0196873b          	addw	a4,a3,s9
ffffffffc0201982:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201986:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020198a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020198e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201992:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201996:	fcd57fe3          	bgeu	a0,a3,ffffffffc0201974 <vprintfmt+0x112>
ffffffffc020199a:	b779                	j	ffffffffc0201928 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc020199c:	000aa503          	lw	a0,0(s5)
ffffffffc02019a0:	85a6                	mv	a1,s1
ffffffffc02019a2:	0aa1                	addi	s5,s5,8
ffffffffc02019a4:	9902                	jalr	s2
            break;
ffffffffc02019a6:	bddd                	j	ffffffffc020189c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02019a8:	4705                	li	a4,1
ffffffffc02019aa:	008a8993          	addi	s3,s5,8
ffffffffc02019ae:	01074463          	blt	a4,a6,ffffffffc02019b6 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02019b2:	1c080463          	beqz	a6,ffffffffc0201b7a <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02019b6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02019ba:	1c044a63          	bltz	s0,ffffffffc0201b8e <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02019be:	8622                	mv	a2,s0
ffffffffc02019c0:	8ace                	mv	s5,s3
ffffffffc02019c2:	46a9                	li	a3,10
ffffffffc02019c4:	a8f1                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02019c6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019ca:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02019cc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02019ce:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02019d2:	8fb5                	xor	a5,a5,a3
ffffffffc02019d4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019d8:	12d74963          	blt	a4,a3,ffffffffc0201b0a <vprintfmt+0x2a8>
ffffffffc02019dc:	00369793          	slli	a5,a3,0x3
ffffffffc02019e0:	97e2                	add	a5,a5,s8
ffffffffc02019e2:	639c                	ld	a5,0(a5)
ffffffffc02019e4:	12078363          	beqz	a5,ffffffffc0201b0a <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02019e8:	86be                	mv	a3,a5
ffffffffc02019ea:	00001617          	auipc	a2,0x1
ffffffffc02019ee:	21e60613          	addi	a2,a2,542 # ffffffffc0202c08 <error_string+0xe8>
ffffffffc02019f2:	85a6                	mv	a1,s1
ffffffffc02019f4:	854a                	mv	a0,s2
ffffffffc02019f6:	1cc000ef          	jal	ra,ffffffffc0201bc2 <printfmt>
ffffffffc02019fa:	b54d                	j	ffffffffc020189c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019fc:	000ab603          	ld	a2,0(s5)
ffffffffc0201a00:	0aa1                	addi	s5,s5,8
ffffffffc0201a02:	1a060163          	beqz	a2,ffffffffc0201ba4 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0201a06:	00160413          	addi	s0,a2,1
ffffffffc0201a0a:	15b05763          	blez	s11,ffffffffc0201b58 <vprintfmt+0x2f6>
ffffffffc0201a0e:	02d00593          	li	a1,45
ffffffffc0201a12:	10b79d63          	bne	a5,a1,ffffffffc0201b2c <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a16:	00064783          	lbu	a5,0(a2)
ffffffffc0201a1a:	0007851b          	sext.w	a0,a5
ffffffffc0201a1e:	c905                	beqz	a0,ffffffffc0201a4e <vprintfmt+0x1ec>
ffffffffc0201a20:	000cc563          	bltz	s9,ffffffffc0201a2a <vprintfmt+0x1c8>
ffffffffc0201a24:	3cfd                	addiw	s9,s9,-1
ffffffffc0201a26:	036c8263          	beq	s9,s6,ffffffffc0201a4a <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0201a2a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a2c:	14098f63          	beqz	s3,ffffffffc0201b8a <vprintfmt+0x328>
ffffffffc0201a30:	3781                	addiw	a5,a5,-32
ffffffffc0201a32:	14fbfc63          	bgeu	s7,a5,ffffffffc0201b8a <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0201a36:	03f00513          	li	a0,63
ffffffffc0201a3a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a3c:	0405                	addi	s0,s0,1
ffffffffc0201a3e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a42:	3dfd                	addiw	s11,s11,-1
ffffffffc0201a44:	0007851b          	sext.w	a0,a5
ffffffffc0201a48:	fd61                	bnez	a0,ffffffffc0201a20 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0201a4a:	e5b059e3          	blez	s11,ffffffffc020189c <vprintfmt+0x3a>
ffffffffc0201a4e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a50:	85a6                	mv	a1,s1
ffffffffc0201a52:	02000513          	li	a0,32
ffffffffc0201a56:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a58:	e40d82e3          	beqz	s11,ffffffffc020189c <vprintfmt+0x3a>
ffffffffc0201a5c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a5e:	85a6                	mv	a1,s1
ffffffffc0201a60:	02000513          	li	a0,32
ffffffffc0201a64:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a66:	fe0d94e3          	bnez	s11,ffffffffc0201a4e <vprintfmt+0x1ec>
ffffffffc0201a6a:	bd0d                	j	ffffffffc020189c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a6c:	4705                	li	a4,1
ffffffffc0201a6e:	008a8593          	addi	a1,s5,8
ffffffffc0201a72:	01074463          	blt	a4,a6,ffffffffc0201a7a <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0201a76:	0e080863          	beqz	a6,ffffffffc0201b66 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0201a7a:	000ab603          	ld	a2,0(s5)
ffffffffc0201a7e:	46a1                	li	a3,8
ffffffffc0201a80:	8aae                	mv	s5,a1
ffffffffc0201a82:	a839                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0201a84:	03000513          	li	a0,48
ffffffffc0201a88:	85a6                	mv	a1,s1
ffffffffc0201a8a:	e03e                	sd	a5,0(sp)
ffffffffc0201a8c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201a8e:	85a6                	mv	a1,s1
ffffffffc0201a90:	07800513          	li	a0,120
ffffffffc0201a94:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201a96:	0aa1                	addi	s5,s5,8
ffffffffc0201a98:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201a9c:	6782                	ld	a5,0(sp)
ffffffffc0201a9e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201aa0:	2781                	sext.w	a5,a5
ffffffffc0201aa2:	876e                	mv	a4,s11
ffffffffc0201aa4:	85a6                	mv	a1,s1
ffffffffc0201aa6:	854a                	mv	a0,s2
ffffffffc0201aa8:	d4fff0ef          	jal	ra,ffffffffc02017f6 <printnum>
            break;
ffffffffc0201aac:	bbc5                	j	ffffffffc020189c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201aae:	00144603          	lbu	a2,1(s0)
ffffffffc0201ab2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ab4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201ab6:	b515                	j	ffffffffc02018da <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201ab8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201abc:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201abe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201ac0:	bd29                	j	ffffffffc02018da <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201ac2:	85a6                	mv	a1,s1
ffffffffc0201ac4:	02500513          	li	a0,37
ffffffffc0201ac8:	9902                	jalr	s2
            break;
ffffffffc0201aca:	bbc9                	j	ffffffffc020189c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201acc:	4705                	li	a4,1
ffffffffc0201ace:	008a8593          	addi	a1,s5,8
ffffffffc0201ad2:	01074463          	blt	a4,a6,ffffffffc0201ada <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0201ad6:	08080d63          	beqz	a6,ffffffffc0201b70 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0201ada:	000ab603          	ld	a2,0(s5)
ffffffffc0201ade:	46a9                	li	a3,10
ffffffffc0201ae0:	8aae                	mv	s5,a1
ffffffffc0201ae2:	bf7d                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0201ae4:	85a6                	mv	a1,s1
ffffffffc0201ae6:	02500513          	li	a0,37
ffffffffc0201aea:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201aec:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201af0:	02500793          	li	a5,37
ffffffffc0201af4:	8d22                	mv	s10,s0
ffffffffc0201af6:	daf703e3          	beq	a4,a5,ffffffffc020189c <vprintfmt+0x3a>
ffffffffc0201afa:	02500713          	li	a4,37
ffffffffc0201afe:	1d7d                	addi	s10,s10,-1
ffffffffc0201b00:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201b04:	fee79de3          	bne	a5,a4,ffffffffc0201afe <vprintfmt+0x29c>
ffffffffc0201b08:	bb51                	j	ffffffffc020189c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201b0a:	00001617          	auipc	a2,0x1
ffffffffc0201b0e:	0ee60613          	addi	a2,a2,238 # ffffffffc0202bf8 <error_string+0xd8>
ffffffffc0201b12:	85a6                	mv	a1,s1
ffffffffc0201b14:	854a                	mv	a0,s2
ffffffffc0201b16:	0ac000ef          	jal	ra,ffffffffc0201bc2 <printfmt>
ffffffffc0201b1a:	b349                	j	ffffffffc020189c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201b1c:	00001617          	auipc	a2,0x1
ffffffffc0201b20:	0d460613          	addi	a2,a2,212 # ffffffffc0202bf0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201b24:	00001417          	auipc	s0,0x1
ffffffffc0201b28:	0cd40413          	addi	s0,s0,205 # ffffffffc0202bf1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b2c:	8532                	mv	a0,a2
ffffffffc0201b2e:	85e6                	mv	a1,s9
ffffffffc0201b30:	e032                	sd	a2,0(sp)
ffffffffc0201b32:	e43e                	sd	a5,8(sp)
ffffffffc0201b34:	1de000ef          	jal	ra,ffffffffc0201d12 <strnlen>
ffffffffc0201b38:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201b3c:	6602                	ld	a2,0(sp)
ffffffffc0201b3e:	01b05d63          	blez	s11,ffffffffc0201b58 <vprintfmt+0x2f6>
ffffffffc0201b42:	67a2                	ld	a5,8(sp)
ffffffffc0201b44:	2781                	sext.w	a5,a5
ffffffffc0201b46:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201b48:	6522                	ld	a0,8(sp)
ffffffffc0201b4a:	85a6                	mv	a1,s1
ffffffffc0201b4c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b4e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201b50:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b52:	6602                	ld	a2,0(sp)
ffffffffc0201b54:	fe0d9ae3          	bnez	s11,ffffffffc0201b48 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b58:	00064783          	lbu	a5,0(a2)
ffffffffc0201b5c:	0007851b          	sext.w	a0,a5
ffffffffc0201b60:	ec0510e3          	bnez	a0,ffffffffc0201a20 <vprintfmt+0x1be>
ffffffffc0201b64:	bb25                	j	ffffffffc020189c <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0201b66:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b6a:	46a1                	li	a3,8
ffffffffc0201b6c:	8aae                	mv	s5,a1
ffffffffc0201b6e:	bf0d                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
ffffffffc0201b70:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b74:	46a9                	li	a3,10
ffffffffc0201b76:	8aae                	mv	s5,a1
ffffffffc0201b78:	b725                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0201b7a:	000aa403          	lw	s0,0(s5)
ffffffffc0201b7e:	bd35                	j	ffffffffc02019ba <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0201b80:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b84:	46c1                	li	a3,16
ffffffffc0201b86:	8aae                	mv	s5,a1
ffffffffc0201b88:	bf21                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0201b8a:	9902                	jalr	s2
ffffffffc0201b8c:	bd45                	j	ffffffffc0201a3c <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201b8e:	85a6                	mv	a1,s1
ffffffffc0201b90:	02d00513          	li	a0,45
ffffffffc0201b94:	e03e                	sd	a5,0(sp)
ffffffffc0201b96:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201b98:	8ace                	mv	s5,s3
ffffffffc0201b9a:	40800633          	neg	a2,s0
ffffffffc0201b9e:	46a9                	li	a3,10
ffffffffc0201ba0:	6782                	ld	a5,0(sp)
ffffffffc0201ba2:	bdfd                	j	ffffffffc0201aa0 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0201ba4:	01b05663          	blez	s11,ffffffffc0201bb0 <vprintfmt+0x34e>
ffffffffc0201ba8:	02d00693          	li	a3,45
ffffffffc0201bac:	f6d798e3          	bne	a5,a3,ffffffffc0201b1c <vprintfmt+0x2ba>
ffffffffc0201bb0:	00001417          	auipc	s0,0x1
ffffffffc0201bb4:	04140413          	addi	s0,s0,65 # ffffffffc0202bf1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bb8:	02800513          	li	a0,40
ffffffffc0201bbc:	02800793          	li	a5,40
ffffffffc0201bc0:	b585                	j	ffffffffc0201a20 <vprintfmt+0x1be>

ffffffffc0201bc2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bc2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201bc4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bc8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bca:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bcc:	ec06                	sd	ra,24(sp)
ffffffffc0201bce:	f83a                	sd	a4,48(sp)
ffffffffc0201bd0:	fc3e                	sd	a5,56(sp)
ffffffffc0201bd2:	e0c2                	sd	a6,64(sp)
ffffffffc0201bd4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201bd6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bd8:	c8bff0ef          	jal	ra,ffffffffc0201862 <vprintfmt>
}
ffffffffc0201bdc:	60e2                	ld	ra,24(sp)
ffffffffc0201bde:	6161                	addi	sp,sp,80
ffffffffc0201be0:	8082                	ret

ffffffffc0201be2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201be2:	715d                	addi	sp,sp,-80
ffffffffc0201be4:	e486                	sd	ra,72(sp)
ffffffffc0201be6:	e0a2                	sd	s0,64(sp)
ffffffffc0201be8:	fc26                	sd	s1,56(sp)
ffffffffc0201bea:	f84a                	sd	s2,48(sp)
ffffffffc0201bec:	f44e                	sd	s3,40(sp)
ffffffffc0201bee:	f052                	sd	s4,32(sp)
ffffffffc0201bf0:	ec56                	sd	s5,24(sp)
ffffffffc0201bf2:	e85a                	sd	s6,16(sp)
ffffffffc0201bf4:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201bf6:	c901                	beqz	a0,ffffffffc0201c06 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201bf8:	85aa                	mv	a1,a0
ffffffffc0201bfa:	00001517          	auipc	a0,0x1
ffffffffc0201bfe:	00e50513          	addi	a0,a0,14 # ffffffffc0202c08 <error_string+0xe8>
ffffffffc0201c02:	cb4fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201c06:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c08:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201c0a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201c0c:	4aa9                	li	s5,10
ffffffffc0201c0e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201c10:	00004b97          	auipc	s7,0x4
ffffffffc0201c14:	408b8b93          	addi	s7,s7,1032 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c18:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201c1c:	d10fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c20:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c22:	00054b63          	bltz	a0,ffffffffc0201c38 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c26:	00a95b63          	bge	s2,a0,ffffffffc0201c3c <readline+0x5a>
ffffffffc0201c2a:	029a5463          	bge	s4,s1,ffffffffc0201c52 <readline+0x70>
        c = getchar();
ffffffffc0201c2e:	cfefe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c32:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c34:	fe0559e3          	bgez	a0,ffffffffc0201c26 <readline+0x44>
            return NULL;
ffffffffc0201c38:	4501                	li	a0,0
ffffffffc0201c3a:	a099                	j	ffffffffc0201c80 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201c3c:	03341463          	bne	s0,s3,ffffffffc0201c64 <readline+0x82>
ffffffffc0201c40:	e8b9                	bnez	s1,ffffffffc0201c96 <readline+0xb4>
        c = getchar();
ffffffffc0201c42:	ceafe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201c46:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c48:	fe0548e3          	bltz	a0,ffffffffc0201c38 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c4c:	fea958e3          	bge	s2,a0,ffffffffc0201c3c <readline+0x5a>
ffffffffc0201c50:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201c52:	8522                	mv	a0,s0
ffffffffc0201c54:	c96fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201c58:	009b87b3          	add	a5,s7,s1
ffffffffc0201c5c:	00878023          	sb	s0,0(a5)
ffffffffc0201c60:	2485                	addiw	s1,s1,1
ffffffffc0201c62:	bf6d                	j	ffffffffc0201c1c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201c64:	01540463          	beq	s0,s5,ffffffffc0201c6c <readline+0x8a>
ffffffffc0201c68:	fb641ae3          	bne	s0,s6,ffffffffc0201c1c <readline+0x3a>
            cputchar(c);
ffffffffc0201c6c:	8522                	mv	a0,s0
ffffffffc0201c6e:	c7cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201c72:	00004517          	auipc	a0,0x4
ffffffffc0201c76:	3a650513          	addi	a0,a0,934 # ffffffffc0206018 <edata>
ffffffffc0201c7a:	94aa                	add	s1,s1,a0
ffffffffc0201c7c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201c80:	60a6                	ld	ra,72(sp)
ffffffffc0201c82:	6406                	ld	s0,64(sp)
ffffffffc0201c84:	74e2                	ld	s1,56(sp)
ffffffffc0201c86:	7942                	ld	s2,48(sp)
ffffffffc0201c88:	79a2                	ld	s3,40(sp)
ffffffffc0201c8a:	7a02                	ld	s4,32(sp)
ffffffffc0201c8c:	6ae2                	ld	s5,24(sp)
ffffffffc0201c8e:	6b42                	ld	s6,16(sp)
ffffffffc0201c90:	6ba2                	ld	s7,8(sp)
ffffffffc0201c92:	6161                	addi	sp,sp,80
ffffffffc0201c94:	8082                	ret
            cputchar(c);
ffffffffc0201c96:	4521                	li	a0,8
ffffffffc0201c98:	c52fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201c9c:	34fd                	addiw	s1,s1,-1
ffffffffc0201c9e:	bfbd                	j	ffffffffc0201c1c <readline+0x3a>

ffffffffc0201ca0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201ca0:	00004797          	auipc	a5,0x4
ffffffffc0201ca4:	36878793          	addi	a5,a5,872 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201ca8:	6398                	ld	a4,0(a5)
ffffffffc0201caa:	4781                	li	a5,0
ffffffffc0201cac:	88ba                	mv	a7,a4
ffffffffc0201cae:	852a                	mv	a0,a0
ffffffffc0201cb0:	85be                	mv	a1,a5
ffffffffc0201cb2:	863e                	mv	a2,a5
ffffffffc0201cb4:	00000073          	ecall
ffffffffc0201cb8:	87aa                	mv	a5,a0
}
ffffffffc0201cba:	8082                	ret

ffffffffc0201cbc <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201cbc:	00004797          	auipc	a5,0x4
ffffffffc0201cc0:	7bc78793          	addi	a5,a5,1980 # ffffffffc0206478 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201cc4:	6398                	ld	a4,0(a5)
ffffffffc0201cc6:	4781                	li	a5,0
ffffffffc0201cc8:	88ba                	mv	a7,a4
ffffffffc0201cca:	852a                	mv	a0,a0
ffffffffc0201ccc:	85be                	mv	a1,a5
ffffffffc0201cce:	863e                	mv	a2,a5
ffffffffc0201cd0:	00000073          	ecall
ffffffffc0201cd4:	87aa                	mv	a5,a0
}
ffffffffc0201cd6:	8082                	ret

ffffffffc0201cd8 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201cd8:	00004797          	auipc	a5,0x4
ffffffffc0201cdc:	32878793          	addi	a5,a5,808 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201ce0:	639c                	ld	a5,0(a5)
ffffffffc0201ce2:	4501                	li	a0,0
ffffffffc0201ce4:	88be                	mv	a7,a5
ffffffffc0201ce6:	852a                	mv	a0,a0
ffffffffc0201ce8:	85aa                	mv	a1,a0
ffffffffc0201cea:	862a                	mv	a2,a0
ffffffffc0201cec:	00000073          	ecall
ffffffffc0201cf0:	852a                	mv	a0,a0
}
ffffffffc0201cf2:	2501                	sext.w	a0,a0
ffffffffc0201cf4:	8082                	ret

ffffffffc0201cf6 <sbi_shutdown>:

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201cf6:	00004797          	auipc	a5,0x4
ffffffffc0201cfa:	31a78793          	addi	a5,a5,794 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201cfe:	6398                	ld	a4,0(a5)
ffffffffc0201d00:	4781                	li	a5,0
ffffffffc0201d02:	88ba                	mv	a7,a4
ffffffffc0201d04:	853e                	mv	a0,a5
ffffffffc0201d06:	85be                	mv	a1,a5
ffffffffc0201d08:	863e                	mv	a2,a5
ffffffffc0201d0a:	00000073          	ecall
ffffffffc0201d0e:	87aa                	mv	a5,a0
ffffffffc0201d10:	8082                	ret

ffffffffc0201d12 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d12:	c185                	beqz	a1,ffffffffc0201d32 <strnlen+0x20>
ffffffffc0201d14:	00054783          	lbu	a5,0(a0)
ffffffffc0201d18:	cf89                	beqz	a5,ffffffffc0201d32 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201d1a:	4781                	li	a5,0
ffffffffc0201d1c:	a021                	j	ffffffffc0201d24 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d1e:	00074703          	lbu	a4,0(a4)
ffffffffc0201d22:	c711                	beqz	a4,ffffffffc0201d2e <strnlen+0x1c>
        cnt ++;
ffffffffc0201d24:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d26:	00f50733          	add	a4,a0,a5
ffffffffc0201d2a:	fef59ae3          	bne	a1,a5,ffffffffc0201d1e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201d2e:	853e                	mv	a0,a5
ffffffffc0201d30:	8082                	ret
    size_t cnt = 0;
ffffffffc0201d32:	4781                	li	a5,0
}
ffffffffc0201d34:	853e                	mv	a0,a5
ffffffffc0201d36:	8082                	ret

ffffffffc0201d38 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d38:	00054783          	lbu	a5,0(a0)
ffffffffc0201d3c:	0005c703          	lbu	a4,0(a1)
ffffffffc0201d40:	cb91                	beqz	a5,ffffffffc0201d54 <strcmp+0x1c>
ffffffffc0201d42:	00e79c63          	bne	a5,a4,ffffffffc0201d5a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201d46:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d48:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201d4c:	0585                	addi	a1,a1,1
ffffffffc0201d4e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d52:	fbe5                	bnez	a5,ffffffffc0201d42 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d54:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201d56:	9d19                	subw	a0,a0,a4
ffffffffc0201d58:	8082                	ret
ffffffffc0201d5a:	0007851b          	sext.w	a0,a5
ffffffffc0201d5e:	9d19                	subw	a0,a0,a4
ffffffffc0201d60:	8082                	ret

ffffffffc0201d62 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201d62:	00054783          	lbu	a5,0(a0)
ffffffffc0201d66:	cb91                	beqz	a5,ffffffffc0201d7a <strchr+0x18>
        if (*s == c) {
ffffffffc0201d68:	00b79563          	bne	a5,a1,ffffffffc0201d72 <strchr+0x10>
ffffffffc0201d6c:	a809                	j	ffffffffc0201d7e <strchr+0x1c>
ffffffffc0201d6e:	00b78763          	beq	a5,a1,ffffffffc0201d7c <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201d72:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201d74:	00054783          	lbu	a5,0(a0)
ffffffffc0201d78:	fbfd                	bnez	a5,ffffffffc0201d6e <strchr+0xc>
    }
    return NULL;
ffffffffc0201d7a:	4501                	li	a0,0
}
ffffffffc0201d7c:	8082                	ret
ffffffffc0201d7e:	8082                	ret

ffffffffc0201d80 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201d80:	ca01                	beqz	a2,ffffffffc0201d90 <memset+0x10>
ffffffffc0201d82:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201d84:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201d86:	0785                	addi	a5,a5,1
ffffffffc0201d88:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201d8c:	fec79de3          	bne	a5,a2,ffffffffc0201d86 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201d90:	8082                	ret

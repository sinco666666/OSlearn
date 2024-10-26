
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
ffffffffc020004e:	4cc010ef          	jal	ra,ffffffffc020151a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	4da50513          	addi	a0,a0,1242 # ffffffffc0201530 <etext+0x4>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	579000ef          	jal	ra,ffffffffc0200de2 <pmm_init>

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
ffffffffc02000aa:	753000ef          	jal	ra,ffffffffc0200ffc <vprintfmt>
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
ffffffffc02000de:	71f000ef          	jal	ra,ffffffffc0200ffc <vprintfmt>
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
ffffffffc020013e:	00001517          	auipc	a0,0x1
ffffffffc0200142:	44250513          	addi	a0,a0,1090 # ffffffffc0201580 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00001517          	auipc	a0,0x1
ffffffffc0200158:	44c50513          	addi	a0,a0,1100 # ffffffffc02015a0 <etext+0x74>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00001597          	auipc	a1,0x1
ffffffffc0200164:	3cc58593          	addi	a1,a1,972 # ffffffffc020152c <etext>
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	45850513          	addi	a0,a0,1112 # ffffffffc02015c0 <etext+0x94>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	ea458593          	addi	a1,a1,-348 # ffffffffc0206018 <edata>
ffffffffc020017c:	00001517          	auipc	a0,0x1
ffffffffc0200180:	46450513          	addi	a0,a0,1124 # ffffffffc02015e0 <etext+0xb4>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	3f058593          	addi	a1,a1,1008 # ffffffffc0206578 <end>
ffffffffc0200190:	00001517          	auipc	a0,0x1
ffffffffc0200194:	47050513          	addi	a0,a0,1136 # ffffffffc0201600 <etext+0xd4>
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
ffffffffc02001be:	00001517          	auipc	a0,0x1
ffffffffc02001c2:	46250513          	addi	a0,a0,1122 # ffffffffc0201620 <etext+0xf4>
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
ffffffffc02001cc:	00001617          	auipc	a2,0x1
ffffffffc02001d0:	38460613          	addi	a2,a2,900 # ffffffffc0201550 <etext+0x24>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00001517          	auipc	a0,0x1
ffffffffc02001dc:	39050513          	addi	a0,a0,912 # ffffffffc0201568 <etext+0x3c>
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
ffffffffc02001e8:	00001617          	auipc	a2,0x1
ffffffffc02001ec:	54860613          	addi	a2,a2,1352 # ffffffffc0201730 <commands+0xe0>
ffffffffc02001f0:	00001597          	auipc	a1,0x1
ffffffffc02001f4:	56058593          	addi	a1,a1,1376 # ffffffffc0201750 <commands+0x100>
ffffffffc02001f8:	00001517          	auipc	a0,0x1
ffffffffc02001fc:	56050513          	addi	a0,a0,1376 # ffffffffc0201758 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00001617          	auipc	a2,0x1
ffffffffc020020a:	56260613          	addi	a2,a2,1378 # ffffffffc0201768 <commands+0x118>
ffffffffc020020e:	00001597          	auipc	a1,0x1
ffffffffc0200212:	58258593          	addi	a1,a1,1410 # ffffffffc0201790 <commands+0x140>
ffffffffc0200216:	00001517          	auipc	a0,0x1
ffffffffc020021a:	54250513          	addi	a0,a0,1346 # ffffffffc0201758 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00001617          	auipc	a2,0x1
ffffffffc0200226:	57e60613          	addi	a2,a2,1406 # ffffffffc02017a0 <commands+0x150>
ffffffffc020022a:	00001597          	auipc	a1,0x1
ffffffffc020022e:	59658593          	addi	a1,a1,1430 # ffffffffc02017c0 <commands+0x170>
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	52650513          	addi	a0,a0,1318 # ffffffffc0201758 <commands+0x108>
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
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	42c50513          	addi	a0,a0,1068 # ffffffffc0201698 <commands+0x48>
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
ffffffffc020028e:	00001517          	auipc	a0,0x1
ffffffffc0200292:	43250513          	addi	a0,a0,1074 # ffffffffc02016c0 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00001c97          	auipc	s9,0x1
ffffffffc02002a8:	3acc8c93          	addi	s9,s9,940 # ffffffffc0201650 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00001997          	auipc	s3,0x1
ffffffffc02002b0:	43c98993          	addi	s3,s3,1084 # ffffffffc02016e8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00001917          	auipc	s2,0x1
ffffffffc02002b8:	43c90913          	addi	s2,s2,1084 # ffffffffc02016f0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00001b17          	auipc	s6,0x1
ffffffffc02002c2:	43ab0b13          	addi	s6,s6,1082 # ffffffffc02016f8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00001a97          	auipc	s5,0x1
ffffffffc02002ca:	48aa8a93          	addi	s5,s5,1162 # ffffffffc0201750 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	0aa010ef          	jal	ra,ffffffffc020137c <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	218010ef          	jal	ra,ffffffffc02014fc <strchr>
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
ffffffffc02002fa:	00001d17          	auipc	s10,0x1
ffffffffc02002fe:	356d0d13          	addi	s10,s10,854 # ffffffffc0201650 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	1ca010ef          	jal	ra,ffffffffc02014d2 <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	1b6010ef          	jal	ra,ffffffffc02014d2 <strcmp>
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
ffffffffc0200382:	17a010ef          	jal	ra,ffffffffc02014fc <strchr>
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
ffffffffc020039a:	00001517          	auipc	a0,0x1
ffffffffc020039e:	37e50513          	addi	a0,a0,894 # ffffffffc0201718 <commands+0xc8>
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
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	3f650513          	addi	a0,a0,1014 # ffffffffc02017d0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	cd3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	cabff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	25850513          	addi	a0,a0,600 # ffffffffc0201648 <etext+0x11c>
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
ffffffffc0200420:	036010ef          	jal	ra,ffffffffc0201456 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0207b123          	sd	zero,34(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	3c250513          	addi	a0,a0,962 # ffffffffc02017f0 <commands+0x1a0>
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
ffffffffc0200446:	0100106f          	j	ffffffffc0201456 <sbi_set_timer>

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
ffffffffc0200450:	7eb0006f          	j	ffffffffc020143a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	01e0106f          	j	ffffffffc0201472 <sbi_console_getchar>

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
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	51250513          	addi	a0,a0,1298 # ffffffffc0201990 <commands+0x340>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	51a50513          	addi	a0,a0,1306 # ffffffffc02019a8 <commands+0x358>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	52450513          	addi	a0,a0,1316 # ffffffffc02019c0 <commands+0x370>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	52e50513          	addi	a0,a0,1326 # ffffffffc02019d8 <commands+0x388>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	53850513          	addi	a0,a0,1336 # ffffffffc02019f0 <commands+0x3a0>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	54250513          	addi	a0,a0,1346 # ffffffffc0201a08 <commands+0x3b8>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	54c50513          	addi	a0,a0,1356 # ffffffffc0201a20 <commands+0x3d0>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	55650513          	addi	a0,a0,1366 # ffffffffc0201a38 <commands+0x3e8>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	56050513          	addi	a0,a0,1376 # ffffffffc0201a50 <commands+0x400>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	56a50513          	addi	a0,a0,1386 # ffffffffc0201a68 <commands+0x418>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	57450513          	addi	a0,a0,1396 # ffffffffc0201a80 <commands+0x430>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	57e50513          	addi	a0,a0,1406 # ffffffffc0201a98 <commands+0x448>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	58850513          	addi	a0,a0,1416 # ffffffffc0201ab0 <commands+0x460>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	59250513          	addi	a0,a0,1426 # ffffffffc0201ac8 <commands+0x478>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	59c50513          	addi	a0,a0,1436 # ffffffffc0201ae0 <commands+0x490>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	5a650513          	addi	a0,a0,1446 # ffffffffc0201af8 <commands+0x4a8>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	5b050513          	addi	a0,a0,1456 # ffffffffc0201b10 <commands+0x4c0>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201b28 <commands+0x4d8>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	5c450513          	addi	a0,a0,1476 # ffffffffc0201b40 <commands+0x4f0>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0201b58 <commands+0x508>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5d850513          	addi	a0,a0,1496 # ffffffffc0201b70 <commands+0x520>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5e250513          	addi	a0,a0,1506 # ffffffffc0201b88 <commands+0x538>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201ba0 <commands+0x550>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5f650513          	addi	a0,a0,1526 # ffffffffc0201bb8 <commands+0x568>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	60050513          	addi	a0,a0,1536 # ffffffffc0201bd0 <commands+0x580>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	60a50513          	addi	a0,a0,1546 # ffffffffc0201be8 <commands+0x598>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	61450513          	addi	a0,a0,1556 # ffffffffc0201c00 <commands+0x5b0>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	61e50513          	addi	a0,a0,1566 # ffffffffc0201c18 <commands+0x5c8>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	62850513          	addi	a0,a0,1576 # ffffffffc0201c30 <commands+0x5e0>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	63250513          	addi	a0,a0,1586 # ffffffffc0201c48 <commands+0x5f8>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	63c50513          	addi	a0,a0,1596 # ffffffffc0201c60 <commands+0x610>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	64250513          	addi	a0,a0,1602 # ffffffffc0201c78 <commands+0x628>
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
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	64650513          	addi	a0,a0,1606 # ffffffffc0201c90 <commands+0x640>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	64650513          	addi	a0,a0,1606 # ffffffffc0201ca8 <commands+0x658>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	64e50513          	addi	a0,a0,1614 # ffffffffc0201cc0 <commands+0x670>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	65650513          	addi	a0,a0,1622 # ffffffffc0201cd8 <commands+0x688>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	65a50513          	addi	a0,a0,1626 # ffffffffc0201cf0 <commands+0x6a0>
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
ffffffffc02006b4:	15c70713          	addi	a4,a4,348 # ffffffffc020180c <commands+0x1bc>
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
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	26650513          	addi	a0,a0,614 # ffffffffc0201928 <commands+0x2d8>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	23c50513          	addi	a0,a0,572 # ffffffffc0201908 <commands+0x2b8>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	1f250513          	addi	a0,a0,498 # ffffffffc02018c8 <commands+0x278>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	26850513          	addi	a0,a0,616 # ffffffffc0201948 <commands+0x2f8>
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
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	24650513          	addi	a0,a0,582 # ffffffffc0201970 <commands+0x320>
ffffffffc0200732:	b251                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200734:	00001517          	auipc	a0,0x1
ffffffffc0200738:	1b450513          	addi	a0,a0,436 # ffffffffc02018e8 <commands+0x298>
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020073e:	b711                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc0200740:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200742:	06400593          	li	a1,100
ffffffffc0200746:	00001517          	auipc	a0,0x1
ffffffffc020074a:	21a50513          	addi	a0,a0,538 # ffffffffc0201960 <commands+0x310>
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
ffffffffc0200764:	52d0006f          	j	ffffffffc0201490 <sbi_shutdown>

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
ffffffffc02007a4:	0a050513          	addi	a0,a0,160 # ffffffffc0201840 <commands+0x1f0>
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc02007ac:	10843583          	ld	a1,264(s0)
ffffffffc02007b0:	00001517          	auipc	a0,0x1
ffffffffc02007b4:	0b850513          	addi	a0,a0,184 # ffffffffc0201868 <commands+0x218>
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
ffffffffc02007d2:	0c250513          	addi	a0,a0,194 # ffffffffc0201890 <commands+0x240>
ffffffffc02007d6:	8e1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007da:	10843583          	ld	a1,264(s0)
ffffffffc02007de:	00001517          	auipc	a0,0x1
ffffffffc02007e2:	0d250513          	addi	a0,a0,210 # ffffffffc02018b0 <commands+0x260>
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

ffffffffc02008be <buddy_system_init>:
#define nr_free(i) free_area[(i)].nr_free
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008be:	00006797          	auipc	a5,0x6
ffffffffc02008c2:	b9278793          	addi	a5,a5,-1134 # ffffffffc0206450 <free_area>
ffffffffc02008c6:	00006717          	auipc	a4,0x6
ffffffffc02008ca:	c9270713          	addi	a4,a4,-878 # ffffffffc0206558 <satp_physical>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008ce:	e79c                	sd	a5,8(a5)
ffffffffc02008d0:	e39c                	sd	a5,0(a5)
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc02008d2:	0007a823          	sw	zero,16(a5)
ffffffffc02008d6:	07e1                	addi	a5,a5,24
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008d8:	fee79be3          	bne	a5,a4,ffffffffc02008ce <buddy_system_init+0x10>
    }
    
}
ffffffffc02008dc:	8082                	ret

ffffffffc02008de <split_page>:
        p += order_size;
    }
}

//取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
static void split_page(int order) {
ffffffffc02008de:	7179                	addi	sp,sp,-48
ffffffffc02008e0:	ec26                	sd	s1,24(sp)
ffffffffc02008e2:	00151493          	slli	s1,a0,0x1
ffffffffc02008e6:	e052                	sd	s4,0(sp)
ffffffffc02008e8:	00a48a33          	add	s4,s1,a0
ffffffffc02008ec:	e44e                	sd	s3,8(sp)
ffffffffc02008ee:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02008f0:	00006997          	auipc	s3,0x6
ffffffffc02008f4:	b6098993          	addi	s3,s3,-1184 # ffffffffc0206450 <free_area>
ffffffffc02008f8:	014987b3          	add	a5,s3,s4
ffffffffc02008fc:	f022                	sd	s0,32(sp)
ffffffffc02008fe:	6780                	ld	s0,8(a5)
ffffffffc0200900:	e84a                	sd	s2,16(sp)
ffffffffc0200902:	f406                	sd	ra,40(sp)
ffffffffc0200904:	892a                	mv	s2,a0
    if(list_empty(&(free_list(order)))) {
ffffffffc0200906:	06f40e63          	beq	s0,a5,ffffffffc0200982 <split_page+0xa4>
        split_page(order + 1);
    }
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
ffffffffc020090a:	94ca                	add	s1,s1,s2
    uint32_t n = 1 << (order - 1);
ffffffffc020090c:	4705                	li	a4,1
ffffffffc020090e:	397d                	addiw	s2,s2,-1
ffffffffc0200910:	0127173b          	sllw	a4,a4,s2
    nr_free(order) -= 1;
ffffffffc0200914:	048e                	slli	s1,s1,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200916:	600c                	ld	a1,0(s0)
ffffffffc0200918:	6410                	ld	a2,8(s0)
ffffffffc020091a:	94ce                	add	s1,s1,s3
    struct Page *p = page + n;
ffffffffc020091c:	02071513          	slli	a0,a4,0x20
    nr_free(order) -= 1;
ffffffffc0200920:	4894                	lw	a3,16(s1)
    struct Page *p = page + n;
ffffffffc0200922:	9101                	srli	a0,a0,0x20
ffffffffc0200924:	00251793          	slli	a5,a0,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200928:	e590                	sd	a2,8(a1)
ffffffffc020092a:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc020092c:	e20c                	sd	a1,0(a2)
    nr_free(order) -= 1;
ffffffffc020092e:	36fd                	addiw	a3,a3,-1
    struct Page *p = page + n;
ffffffffc0200930:	078e                	slli	a5,a5,0x3
    nr_free(order) -= 1;
ffffffffc0200932:	c894                	sw	a3,16(s1)
    struct Page *p = page + n;
ffffffffc0200934:	17a1                	addi	a5,a5,-24
ffffffffc0200936:	97a2                	add	a5,a5,s0
    page->property = n;
ffffffffc0200938:	fee42c23          	sw	a4,-8(s0)
    p->property = n;
ffffffffc020093c:	cb98                	sw	a4,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020093e:	00878693          	addi	a3,a5,8
ffffffffc0200942:	4709                	li	a4,2
ffffffffc0200944:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200948:	00191713          	slli	a4,s2,0x1
ffffffffc020094c:	974a                	add	a4,a4,s2
ffffffffc020094e:	070e                	slli	a4,a4,0x3
ffffffffc0200950:	974e                	add	a4,a4,s3
ffffffffc0200952:	6710                	ld	a2,8(a4)
    SetPageProperty(p);
    list_add(&(free_list(order-1)),&(page->page_link));
ffffffffc0200954:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc0200956:	e700                	sd	s0,8(a4)
ffffffffc0200958:	99d2                	add	s3,s3,s4
    elm->prev = prev;
ffffffffc020095a:	01343023          	sd	s3,0(s0)
    list_add(&(page->page_link),&(p->page_link));
ffffffffc020095e:	01878593          	addi	a1,a5,24
    nr_free(order-1) += 2;
ffffffffc0200962:	4b14                	lw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc0200964:	e20c                	sd	a1,0(a2)
ffffffffc0200966:	e40c                	sd	a1,8(s0)
    elm->prev = prev;
ffffffffc0200968:	ef80                	sd	s0,24(a5)
    return;
}
ffffffffc020096a:	70a2                	ld	ra,40(sp)
ffffffffc020096c:	7402                	ld	s0,32(sp)
    elm->next = next;
ffffffffc020096e:	f390                	sd	a2,32(a5)
    nr_free(order-1) += 2;
ffffffffc0200970:	0026879b          	addiw	a5,a3,2
ffffffffc0200974:	cb1c                	sw	a5,16(a4)
}
ffffffffc0200976:	64e2                	ld	s1,24(sp)
ffffffffc0200978:	6942                	ld	s2,16(sp)
ffffffffc020097a:	69a2                	ld	s3,8(sp)
ffffffffc020097c:	6a02                	ld	s4,0(sp)
ffffffffc020097e:	6145                	addi	sp,sp,48
ffffffffc0200980:	8082                	ret
        split_page(order + 1);
ffffffffc0200982:	2505                	addiw	a0,a0,1
ffffffffc0200984:	f5bff0ef          	jal	ra,ffffffffc02008de <split_page>
ffffffffc0200988:	6400                	ld	s0,8(s0)
ffffffffc020098a:	b741                	j	ffffffffc020090a <split_page+0x2c>

ffffffffc020098c <add_page>:
    return page;
}

//先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
ffffffffc020098c:	1502                	slli	a0,a0,0x20
ffffffffc020098e:	9101                	srli	a0,a0,0x20
ffffffffc0200990:	00151713          	slli	a4,a0,0x1
ffffffffc0200994:	972a                	add	a4,a4,a0
ffffffffc0200996:	00006797          	auipc	a5,0x6
ffffffffc020099a:	aba78793          	addi	a5,a5,-1350 # ffffffffc0206450 <free_area>
ffffffffc020099e:	070e                	slli	a4,a4,0x3
ffffffffc02009a0:	973e                	add	a4,a4,a5
    return list->next == list;
ffffffffc02009a2:	671c                	ld	a5,8(a4)
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                list_add(le, &(base->page_link));
ffffffffc02009a4:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order)))) {
ffffffffc02009a8:	04f70063          	beq	a4,a5,ffffffffc02009e8 <add_page+0x5c>
            struct Page* page = le2page(le, page_link);
ffffffffc02009ac:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc02009b0:	00f70c63          	beq	a4,a5,ffffffffc02009c8 <add_page+0x3c>
            if (base < page) {
ffffffffc02009b4:	02d5e263          	bltu	a1,a3,ffffffffc02009d8 <add_page+0x4c>
    return listelm->next;
ffffffffc02009b8:	6794                	ld	a3,8(a5)
            } else if (list_next(le) == &(free_list(order))) {
ffffffffc02009ba:	00d70863          	beq	a4,a3,ffffffffc02009ca <add_page+0x3e>
static void add_page(uint32_t order, struct Page* base) {
ffffffffc02009be:	87b6                	mv	a5,a3
            struct Page* page = le2page(le, page_link);
ffffffffc02009c0:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc02009c4:	fef718e3          	bne	a4,a5,ffffffffc02009b4 <add_page+0x28>
            }
        }
    }
}
ffffffffc02009c8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02009ca:	e310                	sd	a2,0(a4)
ffffffffc02009cc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02009ce:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc02009d0:	6794                	ld	a3,8(a5)
ffffffffc02009d2:	ed9c                	sd	a5,24(a1)
static void add_page(uint32_t order, struct Page* base) {
ffffffffc02009d4:	87b6                	mv	a5,a3
ffffffffc02009d6:	b7ed                	j	ffffffffc02009c0 <add_page+0x34>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02009d8:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc02009da:	01858693          	addi	a3,a1,24
    prev->next = next->prev = elm;
ffffffffc02009de:	e394                	sd	a3,0(a5)
ffffffffc02009e0:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02009e2:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc02009e4:	ed98                	sd	a4,24(a1)
ffffffffc02009e6:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc02009e8:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc02009ec:	e31c                	sd	a5,0(a4)
ffffffffc02009ee:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc02009f0:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc02009f2:	ed98                	sd	a4,24(a1)
ffffffffc02009f4:	8082                	ret

ffffffffc02009f6 <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {//计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009f6:	00006697          	auipc	a3,0x6
ffffffffc02009fa:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0206460 <free_area+0x10>
ffffffffc02009fe:	4701                	li	a4,0
    size_t num = 0;
ffffffffc0200a00:	4501                	li	a0,0
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200a02:	462d                	li	a2,11
        num += nr_free(i) << i;
ffffffffc0200a04:	429c                	lw	a5,0(a3)
ffffffffc0200a06:	06e1                	addi	a3,a3,24
ffffffffc0200a08:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200a0c:	1782                	slli	a5,a5,0x20
ffffffffc0200a0e:	9381                	srli	a5,a5,0x20
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200a10:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc0200a12:	953e                	add	a0,a0,a5
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200a14:	fec718e3          	bne	a4,a2,ffffffffc0200a04 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc0200a18:	8082                	ret

ffffffffc0200a1a <buddy_system_check>:
    free_page(p);
    free_page(p1);
    free_page(p2);
}
static void
buddy_system_check(void) {}
ffffffffc0200a1a:	8082                	ret

ffffffffc0200a1c <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200a1c:	7139                	addi	sp,sp,-64
ffffffffc0200a1e:	fc06                	sd	ra,56(sp)
ffffffffc0200a20:	f822                	sd	s0,48(sp)
ffffffffc0200a22:	f426                	sd	s1,40(sp)
ffffffffc0200a24:	f04a                	sd	s2,32(sp)
ffffffffc0200a26:	ec4e                	sd	s3,24(sp)
ffffffffc0200a28:	e852                	sd	s4,16(sp)
ffffffffc0200a2a:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200a2c:	1a058663          	beqz	a1,ffffffffc0200bd8 <buddy_system_free_pages+0x1bc>
    assert(IS_POWER_OF_2(n));
ffffffffc0200a30:	fff58793          	addi	a5,a1,-1
ffffffffc0200a34:	8fed                	and	a5,a5,a1
ffffffffc0200a36:	18079163          	bnez	a5,ffffffffc0200bb8 <buddy_system_free_pages+0x19c>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200a3a:	3ff00793          	li	a5,1023
ffffffffc0200a3e:	1ab7ed63          	bltu	a5,a1,ffffffffc0200bf8 <buddy_system_free_pages+0x1dc>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a42:	651c                	ld	a5,8(a0)
    for (; p != base + n; p ++) {
ffffffffc0200a44:	00259693          	slli	a3,a1,0x2
ffffffffc0200a48:	96ae                	add	a3,a3,a1
ffffffffc0200a4a:	068e                	slli	a3,a3,0x3
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
ffffffffc0200a4c:	8b85                	andi	a5,a5,1
ffffffffc0200a4e:	892a                	mv	s2,a0
    for (; p != base + n; p ++) {
ffffffffc0200a50:	96aa                	add	a3,a3,a0
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
ffffffffc0200a52:	14079363          	bnez	a5,ffffffffc0200b98 <buddy_system_free_pages+0x17c>
ffffffffc0200a56:	651c                	ld	a5,8(a0)
ffffffffc0200a58:	8385                	srli	a5,a5,0x1
ffffffffc0200a5a:	8b85                	andi	a5,a5,1
ffffffffc0200a5c:	12079e63          	bnez	a5,ffffffffc0200b98 <buddy_system_free_pages+0x17c>
ffffffffc0200a60:	87aa                	mv	a5,a0
ffffffffc0200a62:	a809                	j	ffffffffc0200a74 <buddy_system_free_pages+0x58>
ffffffffc0200a64:	6798                	ld	a4,8(a5)
ffffffffc0200a66:	8b05                	andi	a4,a4,1
ffffffffc0200a68:	12071863          	bnez	a4,ffffffffc0200b98 <buddy_system_free_pages+0x17c>
ffffffffc0200a6c:	6798                	ld	a4,8(a5)
ffffffffc0200a6e:	8b09                	andi	a4,a4,2
ffffffffc0200a70:	12071463          	bnez	a4,ffffffffc0200b98 <buddy_system_free_pages+0x17c>
        p->flags = 0;
ffffffffc0200a74:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a78:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200a7c:	02878793          	addi	a5,a5,40
ffffffffc0200a80:	fed792e3          	bne	a5,a3,ffffffffc0200a64 <buddy_system_free_pages+0x48>
    base->property = n;
ffffffffc0200a84:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a88:	4789                	li	a5,2
ffffffffc0200a8a:	00890713          	addi	a4,s2,8
ffffffffc0200a8e:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc0200a92:	4785                	li	a5,1
ffffffffc0200a94:	0ef58c63          	beq	a1,a5,ffffffffc0200b8c <buddy_system_free_pages+0x170>
    uint32_t order = 0;
ffffffffc0200a98:	4481                	li	s1,0
        temp >>= 1;
ffffffffc0200a9a:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc0200a9c:	2485                	addiw	s1,s1,1
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc0200a9e:	fef59ee3          	bne	a1,a5,ffffffffc0200a9a <buddy_system_free_pages+0x7e>
    add_page(order,base);
ffffffffc0200aa2:	85ca                	mv	a1,s2
ffffffffc0200aa4:	8526                	mv	a0,s1
ffffffffc0200aa6:	ee7ff0ef          	jal	ra,ffffffffc020098c <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200aaa:	47a9                	li	a5,10
ffffffffc0200aac:	06f48763          	beq	s1,a5,ffffffffc0200b1a <buddy_system_free_pages+0xfe>
ffffffffc0200ab0:	00006a97          	auipc	s5,0x6
ffffffffc0200ab4:	9a0a8a93          	addi	s5,s5,-1632 # ffffffffc0206450 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ab8:	59f5                	li	s3,-3
ffffffffc0200aba:	4a29                	li	s4,10
    if (le != &(free_list(order))) {
ffffffffc0200abc:	02049793          	slli	a5,s1,0x20
ffffffffc0200ac0:	9381                	srli	a5,a5,0x20
ffffffffc0200ac2:	00179413          	slli	s0,a5,0x1
ffffffffc0200ac6:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc0200ac8:	01893703          	ld	a4,24(s2)
ffffffffc0200acc:	040e                	slli	s0,s0,0x3
ffffffffc0200ace:	9456                	add	s0,s0,s5
ffffffffc0200ad0:	2485                	addiw	s1,s1,1
ffffffffc0200ad2:	02870063          	beq	a4,s0,ffffffffc0200af2 <buddy_system_free_pages+0xd6>
        if (p + p->property == base) {//若是连续内存
ffffffffc0200ad6:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200ada:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {//若是连续内存
ffffffffc0200ade:	02061693          	slli	a3,a2,0x20
ffffffffc0200ae2:	9281                	srli	a3,a3,0x20
ffffffffc0200ae4:	00269793          	slli	a5,a3,0x2
ffffffffc0200ae8:	97b6                	add	a5,a5,a3
ffffffffc0200aea:	078e                	slli	a5,a5,0x3
ffffffffc0200aec:	97ae                	add	a5,a5,a1
ffffffffc0200aee:	06f90963          	beq	s2,a5,ffffffffc0200b60 <buddy_system_free_pages+0x144>
    return listelm->next;
ffffffffc0200af2:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order))) {
ffffffffc0200af6:	02e40063          	beq	s0,a4,ffffffffc0200b16 <buddy_system_free_pages+0xfa>
        if (base + base->property == p) {
ffffffffc0200afa:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc0200afe:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200b02:	02059613          	slli	a2,a1,0x20
ffffffffc0200b06:	9201                	srli	a2,a2,0x20
ffffffffc0200b08:	00261793          	slli	a5,a2,0x2
ffffffffc0200b0c:	97b2                	add	a5,a5,a2
ffffffffc0200b0e:	078e                	slli	a5,a5,0x3
ffffffffc0200b10:	97ca                	add	a5,a5,s2
ffffffffc0200b12:	00f68d63          	beq	a3,a5,ffffffffc0200b2c <buddy_system_free_pages+0x110>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200b16:	fb4493e3          	bne	s1,s4,ffffffffc0200abc <buddy_system_free_pages+0xa0>
}
ffffffffc0200b1a:	70e2                	ld	ra,56(sp)
ffffffffc0200b1c:	7442                	ld	s0,48(sp)
ffffffffc0200b1e:	74a2                	ld	s1,40(sp)
ffffffffc0200b20:	7902                	ld	s2,32(sp)
ffffffffc0200b22:	69e2                	ld	s3,24(sp)
ffffffffc0200b24:	6a42                	ld	s4,16(sp)
ffffffffc0200b26:	6aa2                	ld	s5,8(sp)
ffffffffc0200b28:	6121                	addi	sp,sp,64
ffffffffc0200b2a:	8082                	ret
            base->property += p->property;
ffffffffc0200b2c:	ff872783          	lw	a5,-8(a4)
ffffffffc0200b30:	9dbd                	addw	a1,a1,a5
ffffffffc0200b32:	00b92823          	sw	a1,16(s2)
ffffffffc0200b36:	ff070793          	addi	a5,a4,-16
ffffffffc0200b3a:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b3e:	671c                	ld	a5,8(a4)
ffffffffc0200b40:	6314                	ld	a3,0(a4)
                add_page(order+1,base);
ffffffffc0200b42:	85ca                	mv	a1,s2
ffffffffc0200b44:	8526                	mv	a0,s1
    prev->next = next;
ffffffffc0200b46:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b48:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b4a:	01893703          	ld	a4,24(s2)
ffffffffc0200b4e:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200b52:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b54:	e398                	sd	a4,0(a5)
ffffffffc0200b56:	e37ff0ef          	jal	ra,ffffffffc020098c <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200b5a:	f74491e3          	bne	s1,s4,ffffffffc0200abc <buddy_system_free_pages+0xa0>
ffffffffc0200b5e:	bf75                	j	ffffffffc0200b1a <buddy_system_free_pages+0xfe>
            p->property += base->property;
ffffffffc0200b60:	01092783          	lw	a5,16(s2)
ffffffffc0200b64:	9e3d                	addw	a2,a2,a5
ffffffffc0200b66:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200b6a:	00890793          	addi	a5,s2,8
ffffffffc0200b6e:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b72:	02093783          	ld	a5,32(s2)
                add_page(order+1,base);
ffffffffc0200b76:	8526                	mv	a0,s1
            base = p;
ffffffffc0200b78:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200b7a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b7c:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b7e:	6314                	ld	a3,0(a4)
ffffffffc0200b80:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200b82:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b84:	e394                	sd	a3,0(a5)
                add_page(order+1,base);
ffffffffc0200b86:	e07ff0ef          	jal	ra,ffffffffc020098c <add_page>
ffffffffc0200b8a:	b7a5                	j	ffffffffc0200af2 <buddy_system_free_pages+0xd6>
    add_page(order,base);
ffffffffc0200b8c:	85ca                	mv	a1,s2
ffffffffc0200b8e:	4501                	li	a0,0
ffffffffc0200b90:	dfdff0ef          	jal	ra,ffffffffc020098c <add_page>
    uint32_t order = 0;
ffffffffc0200b94:	4481                	li	s1,0
ffffffffc0200b96:	bf29                	j	ffffffffc0200ab0 <buddy_system_free_pages+0x94>
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
ffffffffc0200b98:	00001697          	auipc	a3,0x1
ffffffffc0200b9c:	1c868693          	addi	a3,a3,456 # ffffffffc0201d60 <commands+0x710>
ffffffffc0200ba0:	00001617          	auipc	a2,0x1
ffffffffc0200ba4:	17060613          	addi	a2,a2,368 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200ba8:	09e00593          	li	a1,158
ffffffffc0200bac:	00001517          	auipc	a0,0x1
ffffffffc0200bb0:	17c50513          	addi	a0,a0,380 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200bb4:	ff4ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200bb8:	00001697          	auipc	a3,0x1
ffffffffc0200bbc:	19068693          	addi	a3,a3,400 # ffffffffc0201d48 <commands+0x6f8>
ffffffffc0200bc0:	00001617          	auipc	a2,0x1
ffffffffc0200bc4:	15060613          	addi	a2,a2,336 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200bc8:	09a00593          	li	a1,154
ffffffffc0200bcc:	00001517          	auipc	a0,0x1
ffffffffc0200bd0:	15c50513          	addi	a0,a0,348 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200bd4:	fd4ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200bd8:	00001697          	auipc	a3,0x1
ffffffffc0200bdc:	13068693          	addi	a3,a3,304 # ffffffffc0201d08 <commands+0x6b8>
ffffffffc0200be0:	00001617          	auipc	a2,0x1
ffffffffc0200be4:	13060613          	addi	a2,a2,304 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200be8:	09900593          	li	a1,153
ffffffffc0200bec:	00001517          	auipc	a0,0x1
ffffffffc0200bf0:	13c50513          	addi	a0,a0,316 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200bf4:	fb4ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200bf8:	00001697          	auipc	a3,0x1
ffffffffc0200bfc:	19068693          	addi	a3,a3,400 # ffffffffc0201d88 <commands+0x738>
ffffffffc0200c00:	00001617          	auipc	a2,0x1
ffffffffc0200c04:	11060613          	addi	a2,a2,272 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200c08:	09b00593          	li	a1,155
ffffffffc0200c0c:	00001517          	auipc	a0,0x1
ffffffffc0200c10:	11c50513          	addi	a0,a0,284 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200c14:	f94ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200c18 <buddy_system_alloc_pages>:
static struct Page * buddy_system_alloc_pages(size_t n) {
ffffffffc0200c18:	1101                	addi	sp,sp,-32
ffffffffc0200c1a:	ec06                	sd	ra,24(sp)
ffffffffc0200c1c:	e822                	sd	s0,16(sp)
ffffffffc0200c1e:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200c20:	c95d                	beqz	a0,ffffffffc0200cd6 <buddy_system_alloc_pages+0xbe>
    while (n < (1 << order)) {
ffffffffc0200c22:	3ff00793          	li	a5,1023
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200c26:	4729                	li	a4,10
    while (n < (1 << order)) {
ffffffffc0200c28:	4605                	li	a2,1
ffffffffc0200c2a:	00a7f463          	bgeu	a5,a0,ffffffffc0200c32 <buddy_system_alloc_pages+0x1a>
ffffffffc0200c2e:	a871                	j	ffffffffc0200cca <buddy_system_alloc_pages+0xb2>
        order -= 1;
ffffffffc0200c30:	873e                	mv	a4,a5
ffffffffc0200c32:	fff7079b          	addiw	a5,a4,-1
    while (n < (1 << order)) {
ffffffffc0200c36:	00f616bb          	sllw	a3,a2,a5
ffffffffc0200c3a:	fed56be3          	bltu	a0,a3,ffffffffc0200c30 <buddy_system_alloc_pages+0x18>
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200c3e:	0007061b          	sext.w	a2,a4
ffffffffc0200c42:	47a9                	li	a5,10
ffffffffc0200c44:	08c7c363          	blt	a5,a2,ffffffffc0200cca <buddy_system_alloc_pages+0xb2>
ffffffffc0200c48:	45a9                	li	a1,10
ffffffffc0200c4a:	9d99                	subw	a1,a1,a4
ffffffffc0200c4c:	1582                	slli	a1,a1,0x20
ffffffffc0200c4e:	9181                	srli	a1,a1,0x20
ffffffffc0200c50:	00c586b3          	add	a3,a1,a2
ffffffffc0200c54:	00169593          	slli	a1,a3,0x1
ffffffffc0200c58:	00161793          	slli	a5,a2,0x1
ffffffffc0200c5c:	95b6                	add	a1,a1,a3
ffffffffc0200c5e:	97b2                	add	a5,a5,a2
ffffffffc0200c60:	00006697          	auipc	a3,0x6
ffffffffc0200c64:	80868693          	addi	a3,a3,-2040 # ffffffffc0206468 <free_area+0x18>
ffffffffc0200c68:	078e                	slli	a5,a5,0x3
ffffffffc0200c6a:	00005497          	auipc	s1,0x5
ffffffffc0200c6e:	7e648493          	addi	s1,s1,2022 # ffffffffc0206450 <free_area>
ffffffffc0200c72:	058e                	slli	a1,a1,0x3
ffffffffc0200c74:	95b6                	add	a1,a1,a3
ffffffffc0200c76:	97a6                	add	a5,a5,s1
    uint32_t flag = 0;
ffffffffc0200c78:	4681                	li	a3,0
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200c7a:	4b90                	lw	a2,16(a5)
ffffffffc0200c7c:	07e1                	addi	a5,a5,24
ffffffffc0200c7e:	9eb1                	addw	a3,a3,a2
ffffffffc0200c80:	feb79de3          	bne	a5,a1,ffffffffc0200c7a <buddy_system_alloc_pages+0x62>
    if(flag == 0) return NULL;
ffffffffc0200c84:	c2b9                	beqz	a3,ffffffffc0200cca <buddy_system_alloc_pages+0xb2>
    if(list_empty(&(free_list(order)))) {
ffffffffc0200c86:	02071693          	slli	a3,a4,0x20
ffffffffc0200c8a:	9281                	srli	a3,a3,0x20
ffffffffc0200c8c:	00169793          	slli	a5,a3,0x1
ffffffffc0200c90:	97b6                	add	a5,a5,a3
ffffffffc0200c92:	078e                	slli	a5,a5,0x3
ffffffffc0200c94:	94be                	add	s1,s1,a5
    return list->next == list;
ffffffffc0200c96:	6480                	ld	s0,8(s1)
ffffffffc0200c98:	02848263          	beq	s1,s0,ffffffffc0200cbc <buddy_system_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c9c:	6018                	ld	a4,0(s0)
ffffffffc0200c9e:	641c                	ld	a5,8(s0)
    page = le2page(le, page_link);
ffffffffc0200ca0:	fe840513          	addi	a0,s0,-24
    prev->next = next;
ffffffffc0200ca4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200ca6:	e398                	sd	a4,0(a5)
ffffffffc0200ca8:	57f5                	li	a5,-3
ffffffffc0200caa:	ff040713          	addi	a4,s0,-16
ffffffffc0200cae:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200cb2:	60e2                	ld	ra,24(sp)
ffffffffc0200cb4:	6442                	ld	s0,16(sp)
ffffffffc0200cb6:	64a2                	ld	s1,8(sp)
ffffffffc0200cb8:	6105                	addi	sp,sp,32
ffffffffc0200cba:	8082                	ret
        split_page(order + 1);
ffffffffc0200cbc:	0017051b          	addiw	a0,a4,1
ffffffffc0200cc0:	c1fff0ef          	jal	ra,ffffffffc02008de <split_page>
    return list->next == list;
ffffffffc0200cc4:	6400                	ld	s0,8(s0)
    if(list_empty(&(free_list(order)))) return NULL;
ffffffffc0200cc6:	fc849be3          	bne	s1,s0,ffffffffc0200c9c <buddy_system_alloc_pages+0x84>
}
ffffffffc0200cca:	60e2                	ld	ra,24(sp)
ffffffffc0200ccc:	6442                	ld	s0,16(sp)
ffffffffc0200cce:	64a2                	ld	s1,8(sp)
    if(flag == 0) return NULL;
ffffffffc0200cd0:	4501                	li	a0,0
}
ffffffffc0200cd2:	6105                	addi	sp,sp,32
ffffffffc0200cd4:	8082                	ret
    assert(n > 0);
ffffffffc0200cd6:	00001697          	auipc	a3,0x1
ffffffffc0200cda:	03268693          	addi	a3,a3,50 # ffffffffc0201d08 <commands+0x6b8>
ffffffffc0200cde:	00001617          	auipc	a2,0x1
ffffffffc0200ce2:	03260613          	addi	a2,a2,50 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200ce6:	04800593          	li	a1,72
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	03e50513          	addi	a0,a0,62 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200cf2:	eb6ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200cf6 <buddy_system_init_memmap>:
static void buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200cf6:	1141                	addi	sp,sp,-16
ffffffffc0200cf8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cfa:	c5e9                	beqz	a1,ffffffffc0200dc4 <buddy_system_init_memmap+0xce>
    for (; p != base + n; p ++) {
ffffffffc0200cfc:	00259693          	slli	a3,a1,0x2
ffffffffc0200d00:	96ae                	add	a3,a3,a1
ffffffffc0200d02:	068e                	slli	a3,a3,0x3
ffffffffc0200d04:	96aa                	add	a3,a3,a0
ffffffffc0200d06:	02d50463          	beq	a0,a3,ffffffffc0200d2e <buddy_system_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d0a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200d0c:	87aa                	mv	a5,a0
ffffffffc0200d0e:	8b05                	andi	a4,a4,1
ffffffffc0200d10:	e709                	bnez	a4,ffffffffc0200d1a <buddy_system_init_memmap+0x24>
ffffffffc0200d12:	a851                	j	ffffffffc0200da6 <buddy_system_init_memmap+0xb0>
ffffffffc0200d14:	6798                	ld	a4,8(a5)
ffffffffc0200d16:	8b05                	andi	a4,a4,1
ffffffffc0200d18:	c759                	beqz	a4,ffffffffc0200da6 <buddy_system_init_memmap+0xb0>
        p->flags = 0;
ffffffffc0200d1a:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0200d1e:	0007a823          	sw	zero,16(a5)
ffffffffc0200d22:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d26:	02878793          	addi	a5,a5,40
ffffffffc0200d2a:	fed795e3          	bne	a5,a3,ffffffffc0200d14 <buddy_system_init_memmap+0x1e>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200d2e:	4729                	li	a4,10
    uint32_t order_size = 1 << order;
ffffffffc0200d30:	40000693          	li	a3,1024
ffffffffc0200d34:	00005e17          	auipc	t3,0x5
ffffffffc0200d38:	71ce0e13          	addi	t3,t3,1820 # ffffffffc0206450 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d3c:	4309                	li	t1,2
        p->property = order_size;
ffffffffc0200d3e:	c914                	sw	a3,16(a0)
ffffffffc0200d40:	00850793          	addi	a5,a0,8
ffffffffc0200d44:	4067b02f          	amoor.d	zero,t1,(a5)
        nr_free(order) += 1;
ffffffffc0200d48:	02071793          	slli	a5,a4,0x20
ffffffffc0200d4c:	9381                	srli	a5,a5,0x20
ffffffffc0200d4e:	00179613          	slli	a2,a5,0x1
ffffffffc0200d52:	963e                	add	a2,a2,a5
ffffffffc0200d54:	060e                	slli	a2,a2,0x3
ffffffffc0200d56:	9672                	add	a2,a2,t3
ffffffffc0200d58:	01062803          	lw	a6,16(a2)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d5c:	00063883          	ld	a7,0(a2)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200d60:	01850793          	addi	a5,a0,24
        nr_free(order) += 1;
ffffffffc0200d64:	2805                	addiw	a6,a6,1
    prev->next = next->prev = elm;
ffffffffc0200d66:	e21c                	sd	a5,0(a2)
ffffffffc0200d68:	01062823          	sw	a6,16(a2)
ffffffffc0200d6c:	00f8b423          	sd	a5,8(a7)
        curr_size -= order_size;
ffffffffc0200d70:	02069793          	slli	a5,a3,0x20
ffffffffc0200d74:	9381                	srli	a5,a5,0x20
    elm->next = next;
ffffffffc0200d76:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0200d78:	01153c23          	sd	a7,24(a0)
ffffffffc0200d7c:	8d9d                	sub	a1,a1,a5
        while(order > 0 && curr_size < order_size) {
ffffffffc0200d7e:	cb19                	beqz	a4,ffffffffc0200d94 <buddy_system_init_memmap+0x9e>
ffffffffc0200d80:	00f5fa63          	bgeu	a1,a5,ffffffffc0200d94 <buddy_system_init_memmap+0x9e>
            order_size >>= 1;
ffffffffc0200d84:	0016d79b          	srliw	a5,a3,0x1
ffffffffc0200d88:	0007869b          	sext.w	a3,a5
            order -= 1;
ffffffffc0200d8c:	377d                	addiw	a4,a4,-1
ffffffffc0200d8e:	1782                	slli	a5,a5,0x20
ffffffffc0200d90:	9381                	srli	a5,a5,0x20
        while(order > 0 && curr_size < order_size) {
ffffffffc0200d92:	f77d                	bnez	a4,ffffffffc0200d80 <buddy_system_init_memmap+0x8a>
        p += order_size;
ffffffffc0200d94:	00279613          	slli	a2,a5,0x2
ffffffffc0200d98:	97b2                	add	a5,a5,a2
ffffffffc0200d9a:	078e                	slli	a5,a5,0x3
ffffffffc0200d9c:	953e                	add	a0,a0,a5
    while (curr_size != 0) {
ffffffffc0200d9e:	f1c5                	bnez	a1,ffffffffc0200d3e <buddy_system_init_memmap+0x48>
}
ffffffffc0200da0:	60a2                	ld	ra,8(sp)
ffffffffc0200da2:	0141                	addi	sp,sp,16
ffffffffc0200da4:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200da6:	00001697          	auipc	a3,0x1
ffffffffc0200daa:	00268693          	addi	a3,a3,2 # ffffffffc0201da8 <commands+0x758>
ffffffffc0200dae:	00001617          	auipc	a2,0x1
ffffffffc0200db2:	f6260613          	addi	a2,a2,-158 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200db6:	45f1                	li	a1,28
ffffffffc0200db8:	00001517          	auipc	a0,0x1
ffffffffc0200dbc:	f7050513          	addi	a0,a0,-144 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200dc0:	de8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200dc4:	00001697          	auipc	a3,0x1
ffffffffc0200dc8:	f4468693          	addi	a3,a3,-188 # ffffffffc0201d08 <commands+0x6b8>
ffffffffc0200dcc:	00001617          	auipc	a2,0x1
ffffffffc0200dd0:	f4460613          	addi	a2,a2,-188 # ffffffffc0201d10 <commands+0x6c0>
ffffffffc0200dd4:	45e5                	li	a1,25
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	f5250513          	addi	a0,a0,-174 # ffffffffc0201d28 <commands+0x6d8>
ffffffffc0200dde:	dcaff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200de2 <pmm_init>:

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //pmm_manager = &best_fit_pmm_manager;
    //pmm_manager = &buddy_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200de2:	00001797          	auipc	a5,0x1
ffffffffc0200de6:	fd678793          	addi	a5,a5,-42 # ffffffffc0201db8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dea:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200dec:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dee:	00001517          	auipc	a0,0x1
ffffffffc0200df2:	02250513          	addi	a0,a0,34 # ffffffffc0201e10 <buddy_system_pmm_manager+0x58>
void pmm_init(void) {
ffffffffc0200df6:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200df8:	00005717          	auipc	a4,0x5
ffffffffc0200dfc:	76f73423          	sd	a5,1896(a4) # ffffffffc0206560 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e00:	e822                	sd	s0,16(sp)
ffffffffc0200e02:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200e04:	00005417          	auipc	s0,0x5
ffffffffc0200e08:	75c40413          	addi	s0,s0,1884 # ffffffffc0206560 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e0c:	aaaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200e10:	601c                	ld	a5,0(s0)
ffffffffc0200e12:	679c                	ld	a5,8(a5)
ffffffffc0200e14:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e16:	57f5                	li	a5,-3
ffffffffc0200e18:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200e1a:	00001517          	auipc	a0,0x1
ffffffffc0200e1e:	00e50513          	addi	a0,a0,14 # ffffffffc0201e28 <buddy_system_pmm_manager+0x70>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e22:	00005717          	auipc	a4,0x5
ffffffffc0200e26:	74f73323          	sd	a5,1862(a4) # ffffffffc0206568 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200e2a:	a8cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200e2e:	46c5                	li	a3,17
ffffffffc0200e30:	06ee                	slli	a3,a3,0x1b
ffffffffc0200e32:	40100613          	li	a2,1025
ffffffffc0200e36:	16fd                	addi	a3,a3,-1
ffffffffc0200e38:	0656                	slli	a2,a2,0x15
ffffffffc0200e3a:	07e005b7          	lui	a1,0x7e00
ffffffffc0200e3e:	00001517          	auipc	a0,0x1
ffffffffc0200e42:	00250513          	addi	a0,a0,2 # ffffffffc0201e40 <buddy_system_pmm_manager+0x88>
ffffffffc0200e46:	a70ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e4a:	777d                	lui	a4,0xfffff
ffffffffc0200e4c:	00006797          	auipc	a5,0x6
ffffffffc0200e50:	72b78793          	addi	a5,a5,1835 # ffffffffc0207577 <end+0xfff>
ffffffffc0200e54:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200e56:	00088737          	lui	a4,0x88
ffffffffc0200e5a:	00005697          	auipc	a3,0x5
ffffffffc0200e5e:	5ce6bb23          	sd	a4,1494(a3) # ffffffffc0206430 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e62:	4601                	li	a2,0
ffffffffc0200e64:	00005717          	auipc	a4,0x5
ffffffffc0200e68:	70f73623          	sd	a5,1804(a4) # ffffffffc0206570 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e6c:	4681                	li	a3,0
ffffffffc0200e6e:	00005897          	auipc	a7,0x5
ffffffffc0200e72:	5c288893          	addi	a7,a7,1474 # ffffffffc0206430 <npage>
ffffffffc0200e76:	00005597          	auipc	a1,0x5
ffffffffc0200e7a:	6fa58593          	addi	a1,a1,1786 # ffffffffc0206570 <pages>
ffffffffc0200e7e:	4805                	li	a6,1
ffffffffc0200e80:	fff80537          	lui	a0,0xfff80
ffffffffc0200e84:	a011                	j	ffffffffc0200e88 <pmm_init+0xa6>
ffffffffc0200e86:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200e88:	97b2                	add	a5,a5,a2
ffffffffc0200e8a:	07a1                	addi	a5,a5,8
ffffffffc0200e8c:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e90:	0008b703          	ld	a4,0(a7)
ffffffffc0200e94:	0685                	addi	a3,a3,1
ffffffffc0200e96:	02860613          	addi	a2,a2,40
ffffffffc0200e9a:	00a707b3          	add	a5,a4,a0
ffffffffc0200e9e:	fef6e4e3          	bltu	a3,a5,ffffffffc0200e86 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ea2:	6190                	ld	a2,0(a1)
ffffffffc0200ea4:	00271793          	slli	a5,a4,0x2
ffffffffc0200ea8:	97ba                	add	a5,a5,a4
ffffffffc0200eaa:	fec006b7          	lui	a3,0xfec00
ffffffffc0200eae:	078e                	slli	a5,a5,0x3
ffffffffc0200eb0:	96b2                	add	a3,a3,a2
ffffffffc0200eb2:	96be                	add	a3,a3,a5
ffffffffc0200eb4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200eb8:	08f6e863          	bltu	a3,a5,ffffffffc0200f48 <pmm_init+0x166>
ffffffffc0200ebc:	00005497          	auipc	s1,0x5
ffffffffc0200ec0:	6ac48493          	addi	s1,s1,1708 # ffffffffc0206568 <va_pa_offset>
ffffffffc0200ec4:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200ec6:	45c5                	li	a1,17
ffffffffc0200ec8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200eca:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200ecc:	04b6e963          	bltu	a3,a1,ffffffffc0200f1e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ed0:	601c                	ld	a5,0(s0)
ffffffffc0200ed2:	7b9c                	ld	a5,48(a5)
ffffffffc0200ed4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	00250513          	addi	a0,a0,2 # ffffffffc0201ed8 <buddy_system_pmm_manager+0x120>
ffffffffc0200ede:	9d8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	11e68693          	addi	a3,a3,286 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200eea:	00005797          	auipc	a5,0x5
ffffffffc0200eee:	54d7b723          	sd	a3,1358(a5) # ffffffffc0206438 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ef2:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ef6:	06f6e563          	bltu	a3,a5,ffffffffc0200f60 <pmm_init+0x17e>
ffffffffc0200efa:	609c                	ld	a5,0(s1)
}
ffffffffc0200efc:	6442                	ld	s0,16(sp)
ffffffffc0200efe:	60e2                	ld	ra,24(sp)
ffffffffc0200f00:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f02:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f04:	8e9d                	sub	a3,a3,a5
ffffffffc0200f06:	00005797          	auipc	a5,0x5
ffffffffc0200f0a:	64d7b923          	sd	a3,1618(a5) # ffffffffc0206558 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f0e:	00001517          	auipc	a0,0x1
ffffffffc0200f12:	fea50513          	addi	a0,a0,-22 # ffffffffc0201ef8 <buddy_system_pmm_manager+0x140>
ffffffffc0200f16:	8636                	mv	a2,a3
}
ffffffffc0200f18:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f1a:	99cff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f1e:	6785                	lui	a5,0x1
ffffffffc0200f20:	17fd                	addi	a5,a5,-1
ffffffffc0200f22:	96be                	add	a3,a3,a5
ffffffffc0200f24:	77fd                	lui	a5,0xfffff
ffffffffc0200f26:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200f2c:	04e7f663          	bgeu	a5,a4,ffffffffc0200f78 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f30:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f32:	97aa                	add	a5,a5,a0
ffffffffc0200f34:	00279513          	slli	a0,a5,0x2
ffffffffc0200f38:	953e                	add	a0,a0,a5
ffffffffc0200f3a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f3c:	8d95                	sub	a1,a1,a3
ffffffffc0200f3e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f40:	81b1                	srli	a1,a1,0xc
ffffffffc0200f42:	9532                	add	a0,a0,a2
ffffffffc0200f44:	9782                	jalr	a5
ffffffffc0200f46:	b769                	j	ffffffffc0200ed0 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f48:	00001617          	auipc	a2,0x1
ffffffffc0200f4c:	f2860613          	addi	a2,a2,-216 # ffffffffc0201e70 <buddy_system_pmm_manager+0xb8>
ffffffffc0200f50:	07200593          	li	a1,114
ffffffffc0200f54:	00001517          	auipc	a0,0x1
ffffffffc0200f58:	f4450513          	addi	a0,a0,-188 # ffffffffc0201e98 <buddy_system_pmm_manager+0xe0>
ffffffffc0200f5c:	c4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f60:	00001617          	auipc	a2,0x1
ffffffffc0200f64:	f1060613          	addi	a2,a2,-240 # ffffffffc0201e70 <buddy_system_pmm_manager+0xb8>
ffffffffc0200f68:	08d00593          	li	a1,141
ffffffffc0200f6c:	00001517          	auipc	a0,0x1
ffffffffc0200f70:	f2c50513          	addi	a0,a0,-212 # ffffffffc0201e98 <buddy_system_pmm_manager+0xe0>
ffffffffc0200f74:	c34ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f78:	00001617          	auipc	a2,0x1
ffffffffc0200f7c:	f3060613          	addi	a2,a2,-208 # ffffffffc0201ea8 <buddy_system_pmm_manager+0xf0>
ffffffffc0200f80:	06b00593          	li	a1,107
ffffffffc0200f84:	00001517          	auipc	a0,0x1
ffffffffc0200f88:	f4450513          	addi	a0,a0,-188 # ffffffffc0201ec8 <buddy_system_pmm_manager+0x110>
ffffffffc0200f8c:	c1cff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200f90 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200f90:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f94:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200f96:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f9a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200f9c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fa0:	f022                	sd	s0,32(sp)
ffffffffc0200fa2:	ec26                	sd	s1,24(sp)
ffffffffc0200fa4:	e84a                	sd	s2,16(sp)
ffffffffc0200fa6:	f406                	sd	ra,40(sp)
ffffffffc0200fa8:	e44e                	sd	s3,8(sp)
ffffffffc0200faa:	84aa                	mv	s1,a0
ffffffffc0200fac:	892e                	mv	s2,a1
ffffffffc0200fae:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200fb2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0200fb4:	03067e63          	bgeu	a2,a6,ffffffffc0200ff0 <printnum+0x60>
ffffffffc0200fb8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200fba:	00805763          	blez	s0,ffffffffc0200fc8 <printnum+0x38>
ffffffffc0200fbe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200fc0:	85ca                	mv	a1,s2
ffffffffc0200fc2:	854e                	mv	a0,s3
ffffffffc0200fc4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200fc6:	fc65                	bnez	s0,ffffffffc0200fbe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fc8:	1a02                	slli	s4,s4,0x20
ffffffffc0200fca:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200fce:	00001797          	auipc	a5,0x1
ffffffffc0200fd2:	0fa78793          	addi	a5,a5,250 # ffffffffc02020c8 <error_string+0x38>
ffffffffc0200fd6:	9a3e                	add	s4,s4,a5
}
ffffffffc0200fd8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fda:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200fde:	70a2                	ld	ra,40(sp)
ffffffffc0200fe0:	69a2                	ld	s3,8(sp)
ffffffffc0200fe2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fe4:	85ca                	mv	a1,s2
ffffffffc0200fe6:	8326                	mv	t1,s1
}
ffffffffc0200fe8:	6942                	ld	s2,16(sp)
ffffffffc0200fea:	64e2                	ld	s1,24(sp)
ffffffffc0200fec:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fee:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200ff0:	03065633          	divu	a2,a2,a6
ffffffffc0200ff4:	8722                	mv	a4,s0
ffffffffc0200ff6:	f9bff0ef          	jal	ra,ffffffffc0200f90 <printnum>
ffffffffc0200ffa:	b7f9                	j	ffffffffc0200fc8 <printnum+0x38>

ffffffffc0200ffc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200ffc:	7119                	addi	sp,sp,-128
ffffffffc0200ffe:	f4a6                	sd	s1,104(sp)
ffffffffc0201000:	f0ca                	sd	s2,96(sp)
ffffffffc0201002:	e8d2                	sd	s4,80(sp)
ffffffffc0201004:	e4d6                	sd	s5,72(sp)
ffffffffc0201006:	e0da                	sd	s6,64(sp)
ffffffffc0201008:	fc5e                	sd	s7,56(sp)
ffffffffc020100a:	f862                	sd	s8,48(sp)
ffffffffc020100c:	f06a                	sd	s10,32(sp)
ffffffffc020100e:	fc86                	sd	ra,120(sp)
ffffffffc0201010:	f8a2                	sd	s0,112(sp)
ffffffffc0201012:	ecce                	sd	s3,88(sp)
ffffffffc0201014:	f466                	sd	s9,40(sp)
ffffffffc0201016:	ec6e                	sd	s11,24(sp)
ffffffffc0201018:	892a                	mv	s2,a0
ffffffffc020101a:	84ae                	mv	s1,a1
ffffffffc020101c:	8d32                	mv	s10,a2
ffffffffc020101e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201020:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201022:	00001a17          	auipc	s4,0x1
ffffffffc0201026:	f16a0a13          	addi	s4,s4,-234 # ffffffffc0201f38 <buddy_system_pmm_manager+0x180>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020102a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020102e:	00001c17          	auipc	s8,0x1
ffffffffc0201032:	062c0c13          	addi	s8,s8,98 # ffffffffc0202090 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201036:	000d4503          	lbu	a0,0(s10)
ffffffffc020103a:	02500793          	li	a5,37
ffffffffc020103e:	001d0413          	addi	s0,s10,1
ffffffffc0201042:	00f50e63          	beq	a0,a5,ffffffffc020105e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201046:	c521                	beqz	a0,ffffffffc020108e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201048:	02500993          	li	s3,37
ffffffffc020104c:	a011                	j	ffffffffc0201050 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020104e:	c121                	beqz	a0,ffffffffc020108e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201050:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201052:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201054:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201056:	fff44503          	lbu	a0,-1(s0)
ffffffffc020105a:	ff351ae3          	bne	a0,s3,ffffffffc020104e <vprintfmt+0x52>
ffffffffc020105e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201062:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201066:	4981                	li	s3,0
ffffffffc0201068:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020106a:	5cfd                	li	s9,-1
ffffffffc020106c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020106e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201072:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201074:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201078:	0ff6f693          	andi	a3,a3,255
ffffffffc020107c:	00140d13          	addi	s10,s0,1
ffffffffc0201080:	1ed5ef63          	bltu	a1,a3,ffffffffc020127e <vprintfmt+0x282>
ffffffffc0201084:	068a                	slli	a3,a3,0x2
ffffffffc0201086:	96d2                	add	a3,a3,s4
ffffffffc0201088:	4294                	lw	a3,0(a3)
ffffffffc020108a:	96d2                	add	a3,a3,s4
ffffffffc020108c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020108e:	70e6                	ld	ra,120(sp)
ffffffffc0201090:	7446                	ld	s0,112(sp)
ffffffffc0201092:	74a6                	ld	s1,104(sp)
ffffffffc0201094:	7906                	ld	s2,96(sp)
ffffffffc0201096:	69e6                	ld	s3,88(sp)
ffffffffc0201098:	6a46                	ld	s4,80(sp)
ffffffffc020109a:	6aa6                	ld	s5,72(sp)
ffffffffc020109c:	6b06                	ld	s6,64(sp)
ffffffffc020109e:	7be2                	ld	s7,56(sp)
ffffffffc02010a0:	7c42                	ld	s8,48(sp)
ffffffffc02010a2:	7ca2                	ld	s9,40(sp)
ffffffffc02010a4:	7d02                	ld	s10,32(sp)
ffffffffc02010a6:	6de2                	ld	s11,24(sp)
ffffffffc02010a8:	6109                	addi	sp,sp,128
ffffffffc02010aa:	8082                	ret
            padc = '-';
ffffffffc02010ac:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ae:	00144603          	lbu	a2,1(s0)
ffffffffc02010b2:	846a                	mv	s0,s10
ffffffffc02010b4:	b7c1                	j	ffffffffc0201074 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc02010b6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02010ba:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02010be:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010c0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02010c2:	fa0dd9e3          	bgez	s11,ffffffffc0201074 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02010c6:	8de6                	mv	s11,s9
ffffffffc02010c8:	5cfd                	li	s9,-1
ffffffffc02010ca:	b76d                	j	ffffffffc0201074 <vprintfmt+0x78>
            if (width < 0)
ffffffffc02010cc:	fffdc693          	not	a3,s11
ffffffffc02010d0:	96fd                	srai	a3,a3,0x3f
ffffffffc02010d2:	00ddfdb3          	and	s11,s11,a3
ffffffffc02010d6:	00144603          	lbu	a2,1(s0)
ffffffffc02010da:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010dc:	846a                	mv	s0,s10
ffffffffc02010de:	bf59                	j	ffffffffc0201074 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02010e0:	4705                	li	a4,1
ffffffffc02010e2:	008a8593          	addi	a1,s5,8
ffffffffc02010e6:	01074463          	blt	a4,a6,ffffffffc02010ee <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc02010ea:	22080863          	beqz	a6,ffffffffc020131a <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc02010ee:	000ab603          	ld	a2,0(s5)
ffffffffc02010f2:	46c1                	li	a3,16
ffffffffc02010f4:	8aae                	mv	s5,a1
ffffffffc02010f6:	a291                	j	ffffffffc020123a <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc02010f8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02010fc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201100:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201102:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201106:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020110a:	fad56ce3          	bltu	a0,a3,ffffffffc02010c2 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc020110e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201110:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201114:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201118:	0196873b          	addw	a4,a3,s9
ffffffffc020111c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201120:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201124:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201128:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020112c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201130:	fcd57fe3          	bgeu	a0,a3,ffffffffc020110e <vprintfmt+0x112>
ffffffffc0201134:	b779                	j	ffffffffc02010c2 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0201136:	000aa503          	lw	a0,0(s5)
ffffffffc020113a:	85a6                	mv	a1,s1
ffffffffc020113c:	0aa1                	addi	s5,s5,8
ffffffffc020113e:	9902                	jalr	s2
            break;
ffffffffc0201140:	bddd                	j	ffffffffc0201036 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201142:	4705                	li	a4,1
ffffffffc0201144:	008a8993          	addi	s3,s5,8
ffffffffc0201148:	01074463          	blt	a4,a6,ffffffffc0201150 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc020114c:	1c080463          	beqz	a6,ffffffffc0201314 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0201150:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201154:	1c044a63          	bltz	s0,ffffffffc0201328 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0201158:	8622                	mv	a2,s0
ffffffffc020115a:	8ace                	mv	s5,s3
ffffffffc020115c:	46a9                	li	a3,10
ffffffffc020115e:	a8f1                	j	ffffffffc020123a <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0201160:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201164:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201166:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201168:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020116c:	8fb5                	xor	a5,a5,a3
ffffffffc020116e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201172:	12d74963          	blt	a4,a3,ffffffffc02012a4 <vprintfmt+0x2a8>
ffffffffc0201176:	00369793          	slli	a5,a3,0x3
ffffffffc020117a:	97e2                	add	a5,a5,s8
ffffffffc020117c:	639c                	ld	a5,0(a5)
ffffffffc020117e:	12078363          	beqz	a5,ffffffffc02012a4 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201182:	86be                	mv	a3,a5
ffffffffc0201184:	00001617          	auipc	a2,0x1
ffffffffc0201188:	ff460613          	addi	a2,a2,-12 # ffffffffc0202178 <error_string+0xe8>
ffffffffc020118c:	85a6                	mv	a1,s1
ffffffffc020118e:	854a                	mv	a0,s2
ffffffffc0201190:	1cc000ef          	jal	ra,ffffffffc020135c <printfmt>
ffffffffc0201194:	b54d                	j	ffffffffc0201036 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201196:	000ab603          	ld	a2,0(s5)
ffffffffc020119a:	0aa1                	addi	s5,s5,8
ffffffffc020119c:	1a060163          	beqz	a2,ffffffffc020133e <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02011a0:	00160413          	addi	s0,a2,1
ffffffffc02011a4:	15b05763          	blez	s11,ffffffffc02012f2 <vprintfmt+0x2f6>
ffffffffc02011a8:	02d00593          	li	a1,45
ffffffffc02011ac:	10b79d63          	bne	a5,a1,ffffffffc02012c6 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011b0:	00064783          	lbu	a5,0(a2)
ffffffffc02011b4:	0007851b          	sext.w	a0,a5
ffffffffc02011b8:	c905                	beqz	a0,ffffffffc02011e8 <vprintfmt+0x1ec>
ffffffffc02011ba:	000cc563          	bltz	s9,ffffffffc02011c4 <vprintfmt+0x1c8>
ffffffffc02011be:	3cfd                	addiw	s9,s9,-1
ffffffffc02011c0:	036c8263          	beq	s9,s6,ffffffffc02011e4 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc02011c4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011c6:	14098f63          	beqz	s3,ffffffffc0201324 <vprintfmt+0x328>
ffffffffc02011ca:	3781                	addiw	a5,a5,-32
ffffffffc02011cc:	14fbfc63          	bgeu	s7,a5,ffffffffc0201324 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc02011d0:	03f00513          	li	a0,63
ffffffffc02011d4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011d6:	0405                	addi	s0,s0,1
ffffffffc02011d8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02011dc:	3dfd                	addiw	s11,s11,-1
ffffffffc02011de:	0007851b          	sext.w	a0,a5
ffffffffc02011e2:	fd61                	bnez	a0,ffffffffc02011ba <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc02011e4:	e5b059e3          	blez	s11,ffffffffc0201036 <vprintfmt+0x3a>
ffffffffc02011e8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02011ea:	85a6                	mv	a1,s1
ffffffffc02011ec:	02000513          	li	a0,32
ffffffffc02011f0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02011f2:	e40d82e3          	beqz	s11,ffffffffc0201036 <vprintfmt+0x3a>
ffffffffc02011f6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02011f8:	85a6                	mv	a1,s1
ffffffffc02011fa:	02000513          	li	a0,32
ffffffffc02011fe:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201200:	fe0d94e3          	bnez	s11,ffffffffc02011e8 <vprintfmt+0x1ec>
ffffffffc0201204:	bd0d                	j	ffffffffc0201036 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201206:	4705                	li	a4,1
ffffffffc0201208:	008a8593          	addi	a1,s5,8
ffffffffc020120c:	01074463          	blt	a4,a6,ffffffffc0201214 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0201210:	0e080863          	beqz	a6,ffffffffc0201300 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0201214:	000ab603          	ld	a2,0(s5)
ffffffffc0201218:	46a1                	li	a3,8
ffffffffc020121a:	8aae                	mv	s5,a1
ffffffffc020121c:	a839                	j	ffffffffc020123a <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc020121e:	03000513          	li	a0,48
ffffffffc0201222:	85a6                	mv	a1,s1
ffffffffc0201224:	e03e                	sd	a5,0(sp)
ffffffffc0201226:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201228:	85a6                	mv	a1,s1
ffffffffc020122a:	07800513          	li	a0,120
ffffffffc020122e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201230:	0aa1                	addi	s5,s5,8
ffffffffc0201232:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201236:	6782                	ld	a5,0(sp)
ffffffffc0201238:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020123a:	2781                	sext.w	a5,a5
ffffffffc020123c:	876e                	mv	a4,s11
ffffffffc020123e:	85a6                	mv	a1,s1
ffffffffc0201240:	854a                	mv	a0,s2
ffffffffc0201242:	d4fff0ef          	jal	ra,ffffffffc0200f90 <printnum>
            break;
ffffffffc0201246:	bbc5                	j	ffffffffc0201036 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201248:	00144603          	lbu	a2,1(s0)
ffffffffc020124c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020124e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201250:	b515                	j	ffffffffc0201074 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201252:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201256:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201258:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020125a:	bd29                	j	ffffffffc0201074 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020125c:	85a6                	mv	a1,s1
ffffffffc020125e:	02500513          	li	a0,37
ffffffffc0201262:	9902                	jalr	s2
            break;
ffffffffc0201264:	bbc9                	j	ffffffffc0201036 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201266:	4705                	li	a4,1
ffffffffc0201268:	008a8593          	addi	a1,s5,8
ffffffffc020126c:	01074463          	blt	a4,a6,ffffffffc0201274 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0201270:	08080d63          	beqz	a6,ffffffffc020130a <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0201274:	000ab603          	ld	a2,0(s5)
ffffffffc0201278:	46a9                	li	a3,10
ffffffffc020127a:	8aae                	mv	s5,a1
ffffffffc020127c:	bf7d                	j	ffffffffc020123a <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc020127e:	85a6                	mv	a1,s1
ffffffffc0201280:	02500513          	li	a0,37
ffffffffc0201284:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201286:	fff44703          	lbu	a4,-1(s0)
ffffffffc020128a:	02500793          	li	a5,37
ffffffffc020128e:	8d22                	mv	s10,s0
ffffffffc0201290:	daf703e3          	beq	a4,a5,ffffffffc0201036 <vprintfmt+0x3a>
ffffffffc0201294:	02500713          	li	a4,37
ffffffffc0201298:	1d7d                	addi	s10,s10,-1
ffffffffc020129a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020129e:	fee79de3          	bne	a5,a4,ffffffffc0201298 <vprintfmt+0x29c>
ffffffffc02012a2:	bb51                	j	ffffffffc0201036 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02012a4:	00001617          	auipc	a2,0x1
ffffffffc02012a8:	ec460613          	addi	a2,a2,-316 # ffffffffc0202168 <error_string+0xd8>
ffffffffc02012ac:	85a6                	mv	a1,s1
ffffffffc02012ae:	854a                	mv	a0,s2
ffffffffc02012b0:	0ac000ef          	jal	ra,ffffffffc020135c <printfmt>
ffffffffc02012b4:	b349                	j	ffffffffc0201036 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02012b6:	00001617          	auipc	a2,0x1
ffffffffc02012ba:	eaa60613          	addi	a2,a2,-342 # ffffffffc0202160 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02012be:	00001417          	auipc	s0,0x1
ffffffffc02012c2:	ea340413          	addi	s0,s0,-349 # ffffffffc0202161 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012c6:	8532                	mv	a0,a2
ffffffffc02012c8:	85e6                	mv	a1,s9
ffffffffc02012ca:	e032                	sd	a2,0(sp)
ffffffffc02012cc:	e43e                	sd	a5,8(sp)
ffffffffc02012ce:	1de000ef          	jal	ra,ffffffffc02014ac <strnlen>
ffffffffc02012d2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02012d6:	6602                	ld	a2,0(sp)
ffffffffc02012d8:	01b05d63          	blez	s11,ffffffffc02012f2 <vprintfmt+0x2f6>
ffffffffc02012dc:	67a2                	ld	a5,8(sp)
ffffffffc02012de:	2781                	sext.w	a5,a5
ffffffffc02012e0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02012e2:	6522                	ld	a0,8(sp)
ffffffffc02012e4:	85a6                	mv	a1,s1
ffffffffc02012e6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012e8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02012ea:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012ec:	6602                	ld	a2,0(sp)
ffffffffc02012ee:	fe0d9ae3          	bnez	s11,ffffffffc02012e2 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012f2:	00064783          	lbu	a5,0(a2)
ffffffffc02012f6:	0007851b          	sext.w	a0,a5
ffffffffc02012fa:	ec0510e3          	bnez	a0,ffffffffc02011ba <vprintfmt+0x1be>
ffffffffc02012fe:	bb25                	j	ffffffffc0201036 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0201300:	000ae603          	lwu	a2,0(s5)
ffffffffc0201304:	46a1                	li	a3,8
ffffffffc0201306:	8aae                	mv	s5,a1
ffffffffc0201308:	bf0d                	j	ffffffffc020123a <vprintfmt+0x23e>
ffffffffc020130a:	000ae603          	lwu	a2,0(s5)
ffffffffc020130e:	46a9                	li	a3,10
ffffffffc0201310:	8aae                	mv	s5,a1
ffffffffc0201312:	b725                	j	ffffffffc020123a <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0201314:	000aa403          	lw	s0,0(s5)
ffffffffc0201318:	bd35                	j	ffffffffc0201154 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc020131a:	000ae603          	lwu	a2,0(s5)
ffffffffc020131e:	46c1                	li	a3,16
ffffffffc0201320:	8aae                	mv	s5,a1
ffffffffc0201322:	bf21                	j	ffffffffc020123a <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0201324:	9902                	jalr	s2
ffffffffc0201326:	bd45                	j	ffffffffc02011d6 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201328:	85a6                	mv	a1,s1
ffffffffc020132a:	02d00513          	li	a0,45
ffffffffc020132e:	e03e                	sd	a5,0(sp)
ffffffffc0201330:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201332:	8ace                	mv	s5,s3
ffffffffc0201334:	40800633          	neg	a2,s0
ffffffffc0201338:	46a9                	li	a3,10
ffffffffc020133a:	6782                	ld	a5,0(sp)
ffffffffc020133c:	bdfd                	j	ffffffffc020123a <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc020133e:	01b05663          	blez	s11,ffffffffc020134a <vprintfmt+0x34e>
ffffffffc0201342:	02d00693          	li	a3,45
ffffffffc0201346:	f6d798e3          	bne	a5,a3,ffffffffc02012b6 <vprintfmt+0x2ba>
ffffffffc020134a:	00001417          	auipc	s0,0x1
ffffffffc020134e:	e1740413          	addi	s0,s0,-489 # ffffffffc0202161 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201352:	02800513          	li	a0,40
ffffffffc0201356:	02800793          	li	a5,40
ffffffffc020135a:	b585                	j	ffffffffc02011ba <vprintfmt+0x1be>

ffffffffc020135c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020135c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020135e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201362:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201364:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201366:	ec06                	sd	ra,24(sp)
ffffffffc0201368:	f83a                	sd	a4,48(sp)
ffffffffc020136a:	fc3e                	sd	a5,56(sp)
ffffffffc020136c:	e0c2                	sd	a6,64(sp)
ffffffffc020136e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201370:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201372:	c8bff0ef          	jal	ra,ffffffffc0200ffc <vprintfmt>
}
ffffffffc0201376:	60e2                	ld	ra,24(sp)
ffffffffc0201378:	6161                	addi	sp,sp,80
ffffffffc020137a:	8082                	ret

ffffffffc020137c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020137c:	715d                	addi	sp,sp,-80
ffffffffc020137e:	e486                	sd	ra,72(sp)
ffffffffc0201380:	e0a2                	sd	s0,64(sp)
ffffffffc0201382:	fc26                	sd	s1,56(sp)
ffffffffc0201384:	f84a                	sd	s2,48(sp)
ffffffffc0201386:	f44e                	sd	s3,40(sp)
ffffffffc0201388:	f052                	sd	s4,32(sp)
ffffffffc020138a:	ec56                	sd	s5,24(sp)
ffffffffc020138c:	e85a                	sd	s6,16(sp)
ffffffffc020138e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201390:	c901                	beqz	a0,ffffffffc02013a0 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201392:	85aa                	mv	a1,a0
ffffffffc0201394:	00001517          	auipc	a0,0x1
ffffffffc0201398:	de450513          	addi	a0,a0,-540 # ffffffffc0202178 <error_string+0xe8>
ffffffffc020139c:	d1bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02013a0:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013a2:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02013a4:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02013a6:	4aa9                	li	s5,10
ffffffffc02013a8:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02013aa:	00005b97          	auipc	s7,0x5
ffffffffc02013ae:	c6eb8b93          	addi	s7,s7,-914 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013b2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02013b6:	d77fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02013ba:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02013bc:	00054b63          	bltz	a0,ffffffffc02013d2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013c0:	00a95b63          	bge	s2,a0,ffffffffc02013d6 <readline+0x5a>
ffffffffc02013c4:	029a5463          	bge	s4,s1,ffffffffc02013ec <readline+0x70>
        c = getchar();
ffffffffc02013c8:	d65fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02013cc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02013ce:	fe0559e3          	bgez	a0,ffffffffc02013c0 <readline+0x44>
            return NULL;
ffffffffc02013d2:	4501                	li	a0,0
ffffffffc02013d4:	a099                	j	ffffffffc020141a <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02013d6:	03341463          	bne	s0,s3,ffffffffc02013fe <readline+0x82>
ffffffffc02013da:	e8b9                	bnez	s1,ffffffffc0201430 <readline+0xb4>
        c = getchar();
ffffffffc02013dc:	d51fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02013e0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02013e2:	fe0548e3          	bltz	a0,ffffffffc02013d2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013e6:	fea958e3          	bge	s2,a0,ffffffffc02013d6 <readline+0x5a>
ffffffffc02013ea:	4481                	li	s1,0
            cputchar(c);
ffffffffc02013ec:	8522                	mv	a0,s0
ffffffffc02013ee:	cfdfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02013f2:	009b87b3          	add	a5,s7,s1
ffffffffc02013f6:	00878023          	sb	s0,0(a5)
ffffffffc02013fa:	2485                	addiw	s1,s1,1
ffffffffc02013fc:	bf6d                	j	ffffffffc02013b6 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02013fe:	01540463          	beq	s0,s5,ffffffffc0201406 <readline+0x8a>
ffffffffc0201402:	fb641ae3          	bne	s0,s6,ffffffffc02013b6 <readline+0x3a>
            cputchar(c);
ffffffffc0201406:	8522                	mv	a0,s0
ffffffffc0201408:	ce3fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc020140c:	00005517          	auipc	a0,0x5
ffffffffc0201410:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206018 <edata>
ffffffffc0201414:	94aa                	add	s1,s1,a0
ffffffffc0201416:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020141a:	60a6                	ld	ra,72(sp)
ffffffffc020141c:	6406                	ld	s0,64(sp)
ffffffffc020141e:	74e2                	ld	s1,56(sp)
ffffffffc0201420:	7942                	ld	s2,48(sp)
ffffffffc0201422:	79a2                	ld	s3,40(sp)
ffffffffc0201424:	7a02                	ld	s4,32(sp)
ffffffffc0201426:	6ae2                	ld	s5,24(sp)
ffffffffc0201428:	6b42                	ld	s6,16(sp)
ffffffffc020142a:	6ba2                	ld	s7,8(sp)
ffffffffc020142c:	6161                	addi	sp,sp,80
ffffffffc020142e:	8082                	ret
            cputchar(c);
ffffffffc0201430:	4521                	li	a0,8
ffffffffc0201432:	cb9fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201436:	34fd                	addiw	s1,s1,-1
ffffffffc0201438:	bfbd                	j	ffffffffc02013b6 <readline+0x3a>

ffffffffc020143a <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc020143a:	00005797          	auipc	a5,0x5
ffffffffc020143e:	bce78793          	addi	a5,a5,-1074 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201442:	6398                	ld	a4,0(a5)
ffffffffc0201444:	4781                	li	a5,0
ffffffffc0201446:	88ba                	mv	a7,a4
ffffffffc0201448:	852a                	mv	a0,a0
ffffffffc020144a:	85be                	mv	a1,a5
ffffffffc020144c:	863e                	mv	a2,a5
ffffffffc020144e:	00000073          	ecall
ffffffffc0201452:	87aa                	mv	a5,a0
}
ffffffffc0201454:	8082                	ret

ffffffffc0201456 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201456:	00005797          	auipc	a5,0x5
ffffffffc020145a:	fea78793          	addi	a5,a5,-22 # ffffffffc0206440 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc020145e:	6398                	ld	a4,0(a5)
ffffffffc0201460:	4781                	li	a5,0
ffffffffc0201462:	88ba                	mv	a7,a4
ffffffffc0201464:	852a                	mv	a0,a0
ffffffffc0201466:	85be                	mv	a1,a5
ffffffffc0201468:	863e                	mv	a2,a5
ffffffffc020146a:	00000073          	ecall
ffffffffc020146e:	87aa                	mv	a5,a0
}
ffffffffc0201470:	8082                	ret

ffffffffc0201472 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201472:	00005797          	auipc	a5,0x5
ffffffffc0201476:	b8e78793          	addi	a5,a5,-1138 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020147a:	639c                	ld	a5,0(a5)
ffffffffc020147c:	4501                	li	a0,0
ffffffffc020147e:	88be                	mv	a7,a5
ffffffffc0201480:	852a                	mv	a0,a0
ffffffffc0201482:	85aa                	mv	a1,a0
ffffffffc0201484:	862a                	mv	a2,a0
ffffffffc0201486:	00000073          	ecall
ffffffffc020148a:	852a                	mv	a0,a0
}
ffffffffc020148c:	2501                	sext.w	a0,a0
ffffffffc020148e:	8082                	ret

ffffffffc0201490 <sbi_shutdown>:

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201490:	00005797          	auipc	a5,0x5
ffffffffc0201494:	b8078793          	addi	a5,a5,-1152 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201498:	6398                	ld	a4,0(a5)
ffffffffc020149a:	4781                	li	a5,0
ffffffffc020149c:	88ba                	mv	a7,a4
ffffffffc020149e:	853e                	mv	a0,a5
ffffffffc02014a0:	85be                	mv	a1,a5
ffffffffc02014a2:	863e                	mv	a2,a5
ffffffffc02014a4:	00000073          	ecall
ffffffffc02014a8:	87aa                	mv	a5,a0
ffffffffc02014aa:	8082                	ret

ffffffffc02014ac <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014ac:	c185                	beqz	a1,ffffffffc02014cc <strnlen+0x20>
ffffffffc02014ae:	00054783          	lbu	a5,0(a0)
ffffffffc02014b2:	cf89                	beqz	a5,ffffffffc02014cc <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02014b4:	4781                	li	a5,0
ffffffffc02014b6:	a021                	j	ffffffffc02014be <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014b8:	00074703          	lbu	a4,0(a4)
ffffffffc02014bc:	c711                	beqz	a4,ffffffffc02014c8 <strnlen+0x1c>
        cnt ++;
ffffffffc02014be:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014c0:	00f50733          	add	a4,a0,a5
ffffffffc02014c4:	fef59ae3          	bne	a1,a5,ffffffffc02014b8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02014c8:	853e                	mv	a0,a5
ffffffffc02014ca:	8082                	ret
    size_t cnt = 0;
ffffffffc02014cc:	4781                	li	a5,0
}
ffffffffc02014ce:	853e                	mv	a0,a5
ffffffffc02014d0:	8082                	ret

ffffffffc02014d2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014d2:	00054783          	lbu	a5,0(a0)
ffffffffc02014d6:	0005c703          	lbu	a4,0(a1)
ffffffffc02014da:	cb91                	beqz	a5,ffffffffc02014ee <strcmp+0x1c>
ffffffffc02014dc:	00e79c63          	bne	a5,a4,ffffffffc02014f4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02014e0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014e2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02014e6:	0585                	addi	a1,a1,1
ffffffffc02014e8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014ec:	fbe5                	bnez	a5,ffffffffc02014dc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014ee:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02014f0:	9d19                	subw	a0,a0,a4
ffffffffc02014f2:	8082                	ret
ffffffffc02014f4:	0007851b          	sext.w	a0,a5
ffffffffc02014f8:	9d19                	subw	a0,a0,a4
ffffffffc02014fa:	8082                	ret

ffffffffc02014fc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02014fc:	00054783          	lbu	a5,0(a0)
ffffffffc0201500:	cb91                	beqz	a5,ffffffffc0201514 <strchr+0x18>
        if (*s == c) {
ffffffffc0201502:	00b79563          	bne	a5,a1,ffffffffc020150c <strchr+0x10>
ffffffffc0201506:	a809                	j	ffffffffc0201518 <strchr+0x1c>
ffffffffc0201508:	00b78763          	beq	a5,a1,ffffffffc0201516 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020150c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020150e:	00054783          	lbu	a5,0(a0)
ffffffffc0201512:	fbfd                	bnez	a5,ffffffffc0201508 <strchr+0xc>
    }
    return NULL;
ffffffffc0201514:	4501                	li	a0,0
}
ffffffffc0201516:	8082                	ret
ffffffffc0201518:	8082                	ret

ffffffffc020151a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020151a:	ca01                	beqz	a2,ffffffffc020152a <memset+0x10>
ffffffffc020151c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020151e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201520:	0785                	addi	a5,a5,1
ffffffffc0201522:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201526:	fec79de3          	bne	a5,a2,ffffffffc0201520 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020152a:	8082                	ret

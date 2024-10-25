
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
ffffffffc020004a:	747000ef          	jal	ra,ffffffffc0200f90 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	45e50513          	addi	a0,a0,1118 # ffffffffc02014b0 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	547000ef          	jal	ra,ffffffffc0200dac <pmm_init>

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
ffffffffc02000a6:	769000ef          	jal	ra,ffffffffc020100e <vprintfmt>
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
ffffffffc02000dc:	733000ef          	jal	ra,ffffffffc020100e <vprintfmt>
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
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	36850513          	addi	a0,a0,872 # ffffffffc02014d0 <etext+0x22>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	43a50513          	addi	a0,a0,1082 # ffffffffc02015b8 <etext+0x10a>
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
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	35850513          	addi	a0,a0,856 # ffffffffc02014f0 <etext+0x42>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	36250513          	addi	a0,a0,866 # ffffffffc0201510 <etext+0x62>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	2f458593          	addi	a1,a1,756 # ffffffffc02014ae <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	36e50513          	addi	a0,a0,878 # ffffffffc0201530 <etext+0x82>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4a58593          	addi	a1,a1,-438 # ffffffffc0206018 <free_area>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	37a50513          	addi	a0,a0,890 # ffffffffc0201550 <etext+0xa2>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	2a658593          	addi	a1,a1,678 # ffffffffc0206488 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	38650513          	addi	a0,a0,902 # ffffffffc0201570 <etext+0xc2>
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
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	37850513          	addi	a0,a0,888 # ffffffffc0201590 <etext+0xe2>
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
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	39a60613          	addi	a2,a2,922 # ffffffffc02015c0 <etext+0x112>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	3a650513          	addi	a0,a0,934 # ffffffffc02015d8 <etext+0x12a>
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
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	3ae60613          	addi	a2,a2,942 # ffffffffc02015f0 <etext+0x142>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	3c658593          	addi	a1,a1,966 # ffffffffc0201610 <etext+0x162>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	3c650513          	addi	a0,a0,966 # ffffffffc0201618 <etext+0x16a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	3c860613          	addi	a2,a2,968 # ffffffffc0201628 <etext+0x17a>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	3e858593          	addi	a1,a1,1000 # ffffffffc0201650 <etext+0x1a2>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	3a850513          	addi	a0,a0,936 # ffffffffc0201618 <etext+0x16a>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	3e460613          	addi	a2,a2,996 # ffffffffc0201660 <etext+0x1b2>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	3fc58593          	addi	a1,a1,1020 # ffffffffc0201680 <etext+0x1d2>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	38c50513          	addi	a0,a0,908 # ffffffffc0201618 <etext+0x16a>
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
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	3ca50513          	addi	a0,a0,970 # ffffffffc0201690 <etext+0x1e2>
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
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	3d050513          	addi	a0,a0,976 # ffffffffc02016b8 <etext+0x20a>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	42ac0c13          	addi	s8,s8,1066 # ffffffffc0201728 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	3da90913          	addi	s2,s2,986 # ffffffffc02016e0 <etext+0x232>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	3da48493          	addi	s1,s1,986 # ffffffffc02016e8 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	3d8b0b13          	addi	s6,s6,984 # ffffffffc02016f0 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	2f0a0a13          	addi	s4,s4,752 # ffffffffc0201610 <etext+0x162>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	064010ef          	jal	ra,ffffffffc0201390 <readline>
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
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	3e6d0d13          	addi	s10,s10,998 # ffffffffc0201728 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	40d000ef          	jal	ra,ffffffffc0200f5c <strcmp>
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
ffffffffc0200364:	3f9000ef          	jal	ra,ffffffffc0200f5c <strcmp>
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
ffffffffc02003a2:	3d9000ef          	jal	ra,ffffffffc0200f7a <strchr>
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
ffffffffc02003e0:	39b000ef          	jal	ra,ffffffffc0200f7a <strchr>
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
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	31650513          	addi	a0,a0,790 # ffffffffc0201710 <etext+0x262>
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
ffffffffc0200420:	03e010ef          	jal	ra,ffffffffc020145e <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	34250513          	addi	a0,a0,834 # ffffffffc0201770 <commands+0x48>
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
ffffffffc0200446:	0180106f          	j	ffffffffc020145e <sbi_set_timer>

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
ffffffffc0200450:	7f50006f          	j	ffffffffc0201444 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0240106f          	j	ffffffffc0201478 <sbi_console_getchar>

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
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	31250513          	addi	a0,a0,786 # ffffffffc0201790 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	31a50513          	addi	a0,a0,794 # ffffffffc02017a8 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	32450513          	addi	a0,a0,804 # ffffffffc02017c0 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	32e50513          	addi	a0,a0,814 # ffffffffc02017d8 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	33850513          	addi	a0,a0,824 # ffffffffc02017f0 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	34250513          	addi	a0,a0,834 # ffffffffc0201808 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	34c50513          	addi	a0,a0,844 # ffffffffc0201820 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	35650513          	addi	a0,a0,854 # ffffffffc0201838 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	36050513          	addi	a0,a0,864 # ffffffffc0201850 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	36a50513          	addi	a0,a0,874 # ffffffffc0201868 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	37450513          	addi	a0,a0,884 # ffffffffc0201880 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	37e50513          	addi	a0,a0,894 # ffffffffc0201898 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	38850513          	addi	a0,a0,904 # ffffffffc02018b0 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	39250513          	addi	a0,a0,914 # ffffffffc02018c8 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	39c50513          	addi	a0,a0,924 # ffffffffc02018e0 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	3a650513          	addi	a0,a0,934 # ffffffffc02018f8 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	3b050513          	addi	a0,a0,944 # ffffffffc0201910 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	3ba50513          	addi	a0,a0,954 # ffffffffc0201928 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	3c450513          	addi	a0,a0,964 # ffffffffc0201940 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	3ce50513          	addi	a0,a0,974 # ffffffffc0201958 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	3d850513          	addi	a0,a0,984 # ffffffffc0201970 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	3e250513          	addi	a0,a0,994 # ffffffffc0201988 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	3ec50513          	addi	a0,a0,1004 # ffffffffc02019a0 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	3f650513          	addi	a0,a0,1014 # ffffffffc02019b8 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	40050513          	addi	a0,a0,1024 # ffffffffc02019d0 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	40a50513          	addi	a0,a0,1034 # ffffffffc02019e8 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	41450513          	addi	a0,a0,1044 # ffffffffc0201a00 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	41e50513          	addi	a0,a0,1054 # ffffffffc0201a18 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	42850513          	addi	a0,a0,1064 # ffffffffc0201a30 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	43250513          	addi	a0,a0,1074 # ffffffffc0201a48 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	43c50513          	addi	a0,a0,1084 # ffffffffc0201a60 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	44250513          	addi	a0,a0,1090 # ffffffffc0201a78 <commands+0x350>
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
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	44650513          	addi	a0,a0,1094 # ffffffffc0201a90 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	44650513          	addi	a0,a0,1094 # ffffffffc0201aa8 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	44e50513          	addi	a0,a0,1102 # ffffffffc0201ac0 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	45650513          	addi	a0,a0,1110 # ffffffffc0201ad8 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	45a50513          	addi	a0,a0,1114 # ffffffffc0201af0 <commands+0x3c8>
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
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	52070713          	addi	a4,a4,1312 # ffffffffc0201bd0 <commands+0x4a8>
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
ffffffffc02006c6:	4a650513          	addi	a0,a0,1190 # ffffffffc0201b68 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	47c50513          	addi	a0,a0,1148 # ffffffffc0201b48 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	43250513          	addi	a0,a0,1074 # ffffffffc0201b08 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	4a850513          	addi	a0,a0,1192 # ffffffffc0201b88 <commands+0x460>
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
ffffffffc0200724:	00001517          	auipc	a0,0x1
ffffffffc0200728:	48c50513          	addi	a0,a0,1164 # ffffffffc0201bb0 <commands+0x488>
ffffffffc020072c:	b259                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020072e:	00001517          	auipc	a0,0x1
ffffffffc0200732:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201b28 <commands+0x400>
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200738:	b729                	j	ffffffffc0200642 <print_trapframe>
            num++;
ffffffffc020073a:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073c:	06400593          	li	a1,100
ffffffffc0200740:	00001517          	auipc	a0,0x1
ffffffffc0200744:	46050513          	addi	a0,a0,1120 # ffffffffc0201ba0 <commands+0x478>
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
ffffffffc0200758:	53d0006f          	j	ffffffffc0201494 <sbi_shutdown>

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
ffffffffc020076e:	00001717          	auipc	a4,0x1
ffffffffc0200772:	51a70713          	addi	a4,a4,1306 # ffffffffc0201c88 <commands+0x560>
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
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	48050513          	addi	a0,a0,1152 # ffffffffc0201c00 <commands+0x4d8>
ffffffffc0200788:	92bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
ffffffffc020078c:	10843583          	ld	a1,264(s0)
ffffffffc0200790:	00001517          	auipc	a0,0x1
ffffffffc0200794:	49850513          	addi	a0,a0,1176 # ffffffffc0201c28 <commands+0x500>
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
ffffffffc02007b8:	00001517          	auipc	a0,0x1
ffffffffc02007bc:	49850513          	addi	a0,a0,1176 # ffffffffc0201c50 <commands+0x528>
ffffffffc02007c0:	8f3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
ffffffffc02007c4:	10843583          	ld	a1,264(s0)
ffffffffc02007c8:	00001517          	auipc	a0,0x1
ffffffffc02007cc:	4a850513          	addi	a0,a0,1192 # ffffffffc0201c70 <commands+0x548>
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

ffffffffc02008aa <buddy_system_init>:
#define nr_free(i) free_area[(i)].nr_free
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008aa:	00005797          	auipc	a5,0x5
ffffffffc02008ae:	76e78793          	addi	a5,a5,1902 # ffffffffc0206018 <free_area>
ffffffffc02008b2:	00006717          	auipc	a4,0x6
ffffffffc02008b6:	86e70713          	addi	a4,a4,-1938 # ffffffffc0206120 <buf+0xf0>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008ba:	e79c                	sd	a5,8(a5)
ffffffffc02008bc:	e39c                	sd	a5,0(a5)
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc02008be:	0007a823          	sw	zero,16(a5)
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008c2:	07e1                	addi	a5,a5,24
ffffffffc02008c4:	fee79be3          	bne	a5,a4,ffffffffc02008ba <buddy_system_init+0x10>
    }
    
}
ffffffffc02008c8:	8082                	ret

ffffffffc02008ca <split_page>:
        p += order_size;
    }
}

//取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
static void split_page(int order) {
ffffffffc02008ca:	7179                	addi	sp,sp,-48
ffffffffc02008cc:	e84a                	sd	s2,16(sp)
ffffffffc02008ce:	00151913          	slli	s2,a0,0x1
ffffffffc02008d2:	e052                	sd	s4,0(sp)
ffffffffc02008d4:	00a90a33          	add	s4,s2,a0
ffffffffc02008d8:	e44e                	sd	s3,8(sp)
ffffffffc02008da:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02008dc:	00005997          	auipc	s3,0x5
ffffffffc02008e0:	73c98993          	addi	s3,s3,1852 # ffffffffc0206018 <free_area>
ffffffffc02008e4:	014987b3          	add	a5,s3,s4
ffffffffc02008e8:	ec26                	sd	s1,24(sp)
ffffffffc02008ea:	6784                	ld	s1,8(a5)
ffffffffc02008ec:	f022                	sd	s0,32(sp)
ffffffffc02008ee:	f406                	sd	ra,40(sp)
ffffffffc02008f0:	842a                	mv	s0,a0
    if(list_empty(&(free_list(order)))) {
ffffffffc02008f2:	08f48063          	beq	s1,a5,ffffffffc0200972 <split_page+0xa8>
        split_page(order + 1);
    }
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
ffffffffc02008f6:	9922                	add	s2,s2,s0
    uint32_t n = 1 << (order - 1);
ffffffffc02008f8:	4705                	li	a4,1
ffffffffc02008fa:	347d                	addiw	s0,s0,-1
ffffffffc02008fc:	0087173b          	sllw	a4,a4,s0
    nr_free(order) -= 1;
ffffffffc0200900:	090e                	slli	s2,s2,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200902:	608c                	ld	a1,0(s1)
ffffffffc0200904:	6490                	ld	a2,8(s1)
ffffffffc0200906:	994e                	add	s2,s2,s3
    struct Page *p = page + n;
ffffffffc0200908:	02071513          	slli	a0,a4,0x20
    nr_free(order) -= 1;
ffffffffc020090c:	01092683          	lw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200910:	9101                	srli	a0,a0,0x20
ffffffffc0200912:	00251793          	slli	a5,a0,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200916:	e590                	sd	a2,8(a1)
ffffffffc0200918:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc020091a:	e20c                	sd	a1,0(a2)
    nr_free(order) -= 1;
ffffffffc020091c:	36fd                	addiw	a3,a3,-1
    struct Page *p = page + n;
ffffffffc020091e:	078e                	slli	a5,a5,0x3
    nr_free(order) -= 1;
ffffffffc0200920:	00d92823          	sw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200924:	17a1                	addi	a5,a5,-24
ffffffffc0200926:	97a6                	add	a5,a5,s1
    page->property = n;
ffffffffc0200928:	fee4ac23          	sw	a4,-8(s1)
    p->property = n;
ffffffffc020092c:	cb98                	sw	a4,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020092e:	00878693          	addi	a3,a5,8
ffffffffc0200932:	4709                	li	a4,2
ffffffffc0200934:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200938:	00141513          	slli	a0,s0,0x1
ffffffffc020093c:	942a                	add	s0,s0,a0
ffffffffc020093e:	040e                	slli	s0,s0,0x3
ffffffffc0200940:	944e                	add	s0,s0,s3
ffffffffc0200942:	6414                	ld	a3,8(s0)
    SetPageProperty(p);
    list_add(&(free_list(order-1)),&(page->page_link));
ffffffffc0200944:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc0200946:	e404                	sd	s1,8(s0)
ffffffffc0200948:	99d2                	add	s3,s3,s4
    list_add(&(page->page_link),&(p->page_link));
    nr_free(order-1) += 2;
ffffffffc020094a:	4818                	lw	a4,16(s0)
    elm->prev = prev;
ffffffffc020094c:	0134b023          	sd	s3,0(s1)
    list_add(&(page->page_link),&(p->page_link));
ffffffffc0200950:	01878613          	addi	a2,a5,24
    prev->next = next->prev = elm;
ffffffffc0200954:	e290                	sd	a2,0(a3)
ffffffffc0200956:	e490                	sd	a2,8(s1)
    elm->prev = prev;
ffffffffc0200958:	ef84                	sd	s1,24(a5)
    elm->next = next;
ffffffffc020095a:	f394                	sd	a3,32(a5)
    nr_free(order-1) += 2;
ffffffffc020095c:	0027079b          	addiw	a5,a4,2
    return;
}
ffffffffc0200960:	70a2                	ld	ra,40(sp)
    nr_free(order-1) += 2;
ffffffffc0200962:	c81c                	sw	a5,16(s0)
}
ffffffffc0200964:	7402                	ld	s0,32(sp)
ffffffffc0200966:	64e2                	ld	s1,24(sp)
ffffffffc0200968:	6942                	ld	s2,16(sp)
ffffffffc020096a:	69a2                	ld	s3,8(sp)
ffffffffc020096c:	6a02                	ld	s4,0(sp)
ffffffffc020096e:	6145                	addi	sp,sp,48
ffffffffc0200970:	8082                	ret
        split_page(order + 1);
ffffffffc0200972:	2505                	addiw	a0,a0,1
ffffffffc0200974:	f57ff0ef          	jal	ra,ffffffffc02008ca <split_page>
    return listelm->next;
ffffffffc0200978:	6484                	ld	s1,8(s1)
ffffffffc020097a:	bfb5                	j	ffffffffc02008f6 <split_page+0x2c>

ffffffffc020097c <add_page>:
    return page;
}

//先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
ffffffffc020097c:	1502                	slli	a0,a0,0x20
ffffffffc020097e:	9101                	srli	a0,a0,0x20
ffffffffc0200980:	00151713          	slli	a4,a0,0x1
ffffffffc0200984:	972a                	add	a4,a4,a0
ffffffffc0200986:	00005797          	auipc	a5,0x5
ffffffffc020098a:	69278793          	addi	a5,a5,1682 # ffffffffc0206018 <free_area>
ffffffffc020098e:	070e                	slli	a4,a4,0x3
ffffffffc0200990:	973e                	add	a4,a4,a5
    return list->next == list;
ffffffffc0200992:	671c                	ld	a5,8(a4)
    } else {
        list_entry_t* le = &(free_list(order));
        while ((le = list_next(le)) != &(free_list(order))) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
ffffffffc0200994:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order)))) {
ffffffffc0200998:	02f70c63          	beq	a4,a5,ffffffffc02009d0 <add_page+0x54>
            struct Page* page = le2page(le, page_link);
ffffffffc020099c:	fe878693          	addi	a3,a5,-24
            if (base < page) {
ffffffffc02009a0:	00d5ea63          	bltu	a1,a3,ffffffffc02009b4 <add_page+0x38>
    return listelm->next;
ffffffffc02009a4:	6794                	ld	a3,8(a5)
                break;
            } else if (list_next(le) == &(free_list(order))) {
ffffffffc02009a6:	00d70d63          	beq	a4,a3,ffffffffc02009c0 <add_page+0x44>
static void add_page(uint32_t order, struct Page* base) {
ffffffffc02009aa:	87b6                	mv	a5,a3
            struct Page* page = le2page(le, page_link);
ffffffffc02009ac:	fe878693          	addi	a3,a5,-24
            if (base < page) {
ffffffffc02009b0:	fed5fae3          	bgeu	a1,a3,ffffffffc02009a4 <add_page+0x28>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02009b4:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02009b6:	e390                	sd	a2,0(a5)
ffffffffc02009b8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02009ba:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc02009bc:	ed98                	sd	a4,24(a1)
}
ffffffffc02009be:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02009c0:	e310                	sd	a2,0(a4)
ffffffffc02009c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02009c4:	f198                	sd	a4,32(a1)
    return listelm->next;
ffffffffc02009c6:	6794                	ld	a3,8(a5)
    elm->prev = prev;
ffffffffc02009c8:	ed9c                	sd	a5,24(a1)
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc02009ca:	fed710e3          	bne	a4,a3,ffffffffc02009aa <add_page+0x2e>
                list_add(le, &(base->page_link));
            }
        }
    }
}
ffffffffc02009ce:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc02009d0:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc02009d4:	e31c                	sd	a5,0(a4)
ffffffffc02009d6:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc02009d8:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc02009da:	ed98                	sd	a4,24(a1)
}
ffffffffc02009dc:	8082                	ret

ffffffffc02009de <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {//计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009de:	00005697          	auipc	a3,0x5
ffffffffc02009e2:	64a68693          	addi	a3,a3,1610 # ffffffffc0206028 <free_area+0x10>
ffffffffc02009e6:	4701                	li	a4,0
    size_t num = 0;
ffffffffc02009e8:	4501                	li	a0,0
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009ea:	462d                	li	a2,11
        num += nr_free(i) << i;
ffffffffc02009ec:	429c                	lw	a5,0(a3)
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009ee:	06e1                	addi	a3,a3,24
        num += nr_free(i) << i;
ffffffffc02009f0:	00e797bb          	sllw	a5,a5,a4
ffffffffc02009f4:	1782                	slli	a5,a5,0x20
ffffffffc02009f6:	9381                	srli	a5,a5,0x20
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009f8:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc02009fa:	953e                	add	a0,a0,a5
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02009fc:	fec718e3          	bne	a4,a2,ffffffffc02009ec <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc0200a00:	8082                	ret

ffffffffc0200a02 <buddy_system_check>:
    free_page(p);
    free_page(p1);
    free_page(p2);
}
static void
buddy_system_check(void) {}
ffffffffc0200a02:	8082                	ret

ffffffffc0200a04 <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200a04:	7139                	addi	sp,sp,-64
ffffffffc0200a06:	fc06                	sd	ra,56(sp)
ffffffffc0200a08:	f822                	sd	s0,48(sp)
ffffffffc0200a0a:	f426                	sd	s1,40(sp)
ffffffffc0200a0c:	f04a                	sd	s2,32(sp)
ffffffffc0200a0e:	ec4e                	sd	s3,24(sp)
ffffffffc0200a10:	e852                	sd	s4,16(sp)
ffffffffc0200a12:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200a14:	18058c63          	beqz	a1,ffffffffc0200bac <buddy_system_free_pages+0x1a8>
    assert(IS_POWER_OF_2(n));
ffffffffc0200a18:	fff58793          	addi	a5,a1,-1
ffffffffc0200a1c:	8fed                	and	a5,a5,a1
ffffffffc0200a1e:	16079763          	bnez	a5,ffffffffc0200b8c <buddy_system_free_pages+0x188>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200a22:	3ff00793          	li	a5,1023
ffffffffc0200a26:	1ab7e363          	bltu	a5,a1,ffffffffc0200bcc <buddy_system_free_pages+0x1c8>
    for (; p != base + n; p ++) {
ffffffffc0200a2a:	00259693          	slli	a3,a1,0x2
ffffffffc0200a2e:	96ae                	add	a3,a3,a1
ffffffffc0200a30:	068e                	slli	a3,a3,0x3
ffffffffc0200a32:	892a                	mv	s2,a0
ffffffffc0200a34:	96aa                	add	a3,a3,a0
ffffffffc0200a36:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a38:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
ffffffffc0200a3a:	8b05                	andi	a4,a4,1
ffffffffc0200a3c:	12071863          	bnez	a4,ffffffffc0200b6c <buddy_system_free_pages+0x168>
ffffffffc0200a40:	6798                	ld	a4,8(a5)
ffffffffc0200a42:	8b09                	andi	a4,a4,2
ffffffffc0200a44:	12071463          	bnez	a4,ffffffffc0200b6c <buddy_system_free_pages+0x168>
        p->flags = 0;
ffffffffc0200a48:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a4c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200a50:	02878793          	addi	a5,a5,40
ffffffffc0200a54:	fed792e3          	bne	a5,a3,ffffffffc0200a38 <buddy_system_free_pages+0x34>
    base->property = n;
ffffffffc0200a58:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a5c:	4789                	li	a5,2
ffffffffc0200a5e:	00890713          	addi	a4,s2,8
ffffffffc0200a62:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc0200a66:	4785                	li	a5,1
ffffffffc0200a68:	0ef58c63          	beq	a1,a5,ffffffffc0200b60 <buddy_system_free_pages+0x15c>
    uint32_t order = 0;
ffffffffc0200a6c:	4481                	li	s1,0
        temp >>= 1;
ffffffffc0200a6e:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc0200a70:	2485                	addiw	s1,s1,1
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc0200a72:	fef59ee3          	bne	a1,a5,ffffffffc0200a6e <buddy_system_free_pages+0x6a>
    add_page(order,base);
ffffffffc0200a76:	85ca                	mv	a1,s2
ffffffffc0200a78:	8526                	mv	a0,s1
ffffffffc0200a7a:	f03ff0ef          	jal	ra,ffffffffc020097c <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200a7e:	47a9                	li	a5,10
ffffffffc0200a80:	06f48763          	beq	s1,a5,ffffffffc0200aee <buddy_system_free_pages+0xea>
ffffffffc0200a84:	00005a97          	auipc	s5,0x5
ffffffffc0200a88:	594a8a93          	addi	s5,s5,1428 # ffffffffc0206018 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a8c:	59f5                	li	s3,-3
ffffffffc0200a8e:	4a29                	li	s4,10
    if (le != &(free_list(order))) {
ffffffffc0200a90:	02049793          	slli	a5,s1,0x20
ffffffffc0200a94:	9381                	srli	a5,a5,0x20
ffffffffc0200a96:	00179413          	slli	s0,a5,0x1
ffffffffc0200a9a:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc0200a9c:	01893703          	ld	a4,24(s2)
ffffffffc0200aa0:	040e                	slli	s0,s0,0x3
ffffffffc0200aa2:	9456                	add	s0,s0,s5
                add_page(order+1,base);
ffffffffc0200aa4:	2485                	addiw	s1,s1,1
    if (le != &(free_list(order))) {
ffffffffc0200aa6:	02870063          	beq	a4,s0,ffffffffc0200ac6 <buddy_system_free_pages+0xc2>
        if (p + p->property == base) {//若是连续内存
ffffffffc0200aaa:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200aae:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {//若是连续内存
ffffffffc0200ab2:	02061693          	slli	a3,a2,0x20
ffffffffc0200ab6:	9281                	srli	a3,a3,0x20
ffffffffc0200ab8:	00269793          	slli	a5,a3,0x2
ffffffffc0200abc:	97b6                	add	a5,a5,a3
ffffffffc0200abe:	078e                	slli	a5,a5,0x3
ffffffffc0200ac0:	97ae                	add	a5,a5,a1
ffffffffc0200ac2:	06f90963          	beq	s2,a5,ffffffffc0200b34 <buddy_system_free_pages+0x130>
    return listelm->next;
ffffffffc0200ac6:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order))) {
ffffffffc0200aca:	02e40063          	beq	s0,a4,ffffffffc0200aea <buddy_system_free_pages+0xe6>
        if (base + base->property == p) {
ffffffffc0200ace:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc0200ad2:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200ad6:	02059613          	slli	a2,a1,0x20
ffffffffc0200ada:	9201                	srli	a2,a2,0x20
ffffffffc0200adc:	00261793          	slli	a5,a2,0x2
ffffffffc0200ae0:	97b2                	add	a5,a5,a2
ffffffffc0200ae2:	078e                	slli	a5,a5,0x3
ffffffffc0200ae4:	97ca                	add	a5,a5,s2
ffffffffc0200ae6:	00f68d63          	beq	a3,a5,ffffffffc0200b00 <buddy_system_free_pages+0xfc>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200aea:	fb4493e3          	bne	s1,s4,ffffffffc0200a90 <buddy_system_free_pages+0x8c>
}
ffffffffc0200aee:	70e2                	ld	ra,56(sp)
ffffffffc0200af0:	7442                	ld	s0,48(sp)
ffffffffc0200af2:	74a2                	ld	s1,40(sp)
ffffffffc0200af4:	7902                	ld	s2,32(sp)
ffffffffc0200af6:	69e2                	ld	s3,24(sp)
ffffffffc0200af8:	6a42                	ld	s4,16(sp)
ffffffffc0200afa:	6aa2                	ld	s5,8(sp)
ffffffffc0200afc:	6121                	addi	sp,sp,64
ffffffffc0200afe:	8082                	ret
            base->property += p->property;
ffffffffc0200b00:	ff872783          	lw	a5,-8(a4)
ffffffffc0200b04:	9dbd                	addw	a1,a1,a5
ffffffffc0200b06:	00b92823          	sw	a1,16(s2)
ffffffffc0200b0a:	ff070793          	addi	a5,a4,-16
ffffffffc0200b0e:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b12:	671c                	ld	a5,8(a4)
ffffffffc0200b14:	6314                	ld	a3,0(a4)
                add_page(order+1,base);
ffffffffc0200b16:	85ca                	mv	a1,s2
ffffffffc0200b18:	8526                	mv	a0,s1
    prev->next = next;
ffffffffc0200b1a:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b1c:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b1e:	01893703          	ld	a4,24(s2)
ffffffffc0200b22:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200b26:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b28:	e398                	sd	a4,0(a5)
ffffffffc0200b2a:	e53ff0ef          	jal	ra,ffffffffc020097c <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200b2e:	f74491e3          	bne	s1,s4,ffffffffc0200a90 <buddy_system_free_pages+0x8c>
ffffffffc0200b32:	bf75                	j	ffffffffc0200aee <buddy_system_free_pages+0xea>
            p->property += base->property;
ffffffffc0200b34:	01092783          	lw	a5,16(s2)
ffffffffc0200b38:	9e3d                	addw	a2,a2,a5
ffffffffc0200b3a:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200b3e:	00890793          	addi	a5,s2,8
ffffffffc0200b42:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b46:	02093783          	ld	a5,32(s2)
                add_page(order+1,base);
ffffffffc0200b4a:	8526                	mv	a0,s1
            base = p;
ffffffffc0200b4c:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200b4e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b50:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b52:	6314                	ld	a3,0(a4)
ffffffffc0200b54:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200b56:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b58:	e394                	sd	a3,0(a5)
                add_page(order+1,base);
ffffffffc0200b5a:	e23ff0ef          	jal	ra,ffffffffc020097c <add_page>
ffffffffc0200b5e:	b7a5                	j	ffffffffc0200ac6 <buddy_system_free_pages+0xc2>
    add_page(order,base);
ffffffffc0200b60:	85ca                	mv	a1,s2
ffffffffc0200b62:	4501                	li	a0,0
ffffffffc0200b64:	e19ff0ef          	jal	ra,ffffffffc020097c <add_page>
    uint32_t order = 0;
ffffffffc0200b68:	4481                	li	s1,0
ffffffffc0200b6a:	bf29                	j	ffffffffc0200a84 <buddy_system_free_pages+0x80>
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
ffffffffc0200b6c:	00001697          	auipc	a3,0x1
ffffffffc0200b70:	1c468693          	addi	a3,a3,452 # ffffffffc0201d30 <commands+0x608>
ffffffffc0200b74:	00001617          	auipc	a2,0x1
ffffffffc0200b78:	14c60613          	addi	a2,a2,332 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200b7c:	09f00593          	li	a1,159
ffffffffc0200b80:	00001517          	auipc	a0,0x1
ffffffffc0200b84:	15850513          	addi	a0,a0,344 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200b88:	db2ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200b8c:	00001697          	auipc	a3,0x1
ffffffffc0200b90:	16c68693          	addi	a3,a3,364 # ffffffffc0201cf8 <commands+0x5d0>
ffffffffc0200b94:	00001617          	auipc	a2,0x1
ffffffffc0200b98:	12c60613          	addi	a2,a2,300 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200b9c:	09b00593          	li	a1,155
ffffffffc0200ba0:	00001517          	auipc	a0,0x1
ffffffffc0200ba4:	13850513          	addi	a0,a0,312 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200ba8:	d92ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0200bac:	00001697          	auipc	a3,0x1
ffffffffc0200bb0:	10c68693          	addi	a3,a3,268 # ffffffffc0201cb8 <commands+0x590>
ffffffffc0200bb4:	00001617          	auipc	a2,0x1
ffffffffc0200bb8:	10c60613          	addi	a2,a2,268 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200bbc:	09a00593          	li	a1,154
ffffffffc0200bc0:	00001517          	auipc	a0,0x1
ffffffffc0200bc4:	11850513          	addi	a0,a0,280 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200bc8:	d72ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200bcc:	00001697          	auipc	a3,0x1
ffffffffc0200bd0:	14468693          	addi	a3,a3,324 # ffffffffc0201d10 <commands+0x5e8>
ffffffffc0200bd4:	00001617          	auipc	a2,0x1
ffffffffc0200bd8:	0ec60613          	addi	a2,a2,236 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200bdc:	09c00593          	li	a1,156
ffffffffc0200be0:	00001517          	auipc	a0,0x1
ffffffffc0200be4:	0f850513          	addi	a0,a0,248 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200be8:	d52ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200bec <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t n) {
ffffffffc0200bec:	1101                	addi	sp,sp,-32
ffffffffc0200bee:	ec06                	sd	ra,24(sp)
ffffffffc0200bf0:	e822                	sd	s0,16(sp)
ffffffffc0200bf2:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200bf4:	c955                	beqz	a0,ffffffffc0200ca8 <buddy_system_alloc_pages+0xbc>
    while (n < (1 << order)) {
ffffffffc0200bf6:	3ff00793          	li	a5,1023
ffffffffc0200bfa:	0aa7e163          	bltu	a5,a0,ffffffffc0200c9c <buddy_system_alloc_pages+0xb0>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200bfe:	47a9                	li	a5,10
    while (n < (1 << order)) {
ffffffffc0200c00:	4685                	li	a3,1
        order -= 1;
ffffffffc0200c02:	0007859b          	sext.w	a1,a5
ffffffffc0200c06:	37fd                	addiw	a5,a5,-1
    while (n < (1 << order)) {
ffffffffc0200c08:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200c0c:	fee56be3          	bltu	a0,a4,ffffffffc0200c02 <buddy_system_alloc_pages+0x16>
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200c10:	47a9                	li	a5,10
ffffffffc0200c12:	0005869b          	sext.w	a3,a1
ffffffffc0200c16:	08b7c363          	blt	a5,a1,ffffffffc0200c9c <buddy_system_alloc_pages+0xb0>
ffffffffc0200c1a:	4629                	li	a2,10
ffffffffc0200c1c:	9e0d                	subw	a2,a2,a1
ffffffffc0200c1e:	1602                	slli	a2,a2,0x20
ffffffffc0200c20:	9201                	srli	a2,a2,0x20
ffffffffc0200c22:	00d60733          	add	a4,a2,a3
ffffffffc0200c26:	00171613          	slli	a2,a4,0x1
ffffffffc0200c2a:	00169793          	slli	a5,a3,0x1
ffffffffc0200c2e:	963a                	add	a2,a2,a4
ffffffffc0200c30:	97b6                	add	a5,a5,a3
ffffffffc0200c32:	00005717          	auipc	a4,0x5
ffffffffc0200c36:	3fe70713          	addi	a4,a4,1022 # ffffffffc0206030 <buf>
ffffffffc0200c3a:	078e                	slli	a5,a5,0x3
ffffffffc0200c3c:	00005497          	auipc	s1,0x5
ffffffffc0200c40:	3dc48493          	addi	s1,s1,988 # ffffffffc0206018 <free_area>
ffffffffc0200c44:	060e                	slli	a2,a2,0x3
ffffffffc0200c46:	963a                	add	a2,a2,a4
ffffffffc0200c48:	97a6                	add	a5,a5,s1
    uint32_t flag = 0;
ffffffffc0200c4a:	4701                	li	a4,0
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200c4c:	4b94                	lw	a3,16(a5)
ffffffffc0200c4e:	07e1                	addi	a5,a5,24
ffffffffc0200c50:	9f35                	addw	a4,a4,a3
ffffffffc0200c52:	fec79de3          	bne	a5,a2,ffffffffc0200c4c <buddy_system_alloc_pages+0x60>
    if(flag == 0) return NULL;
ffffffffc0200c56:	c339                	beqz	a4,ffffffffc0200c9c <buddy_system_alloc_pages+0xb0>
    if(list_empty(&(free_list(order)))) {
ffffffffc0200c58:	02059713          	slli	a4,a1,0x20
ffffffffc0200c5c:	9301                	srli	a4,a4,0x20
ffffffffc0200c5e:	00171793          	slli	a5,a4,0x1
ffffffffc0200c62:	97ba                	add	a5,a5,a4
ffffffffc0200c64:	078e                	slli	a5,a5,0x3
ffffffffc0200c66:	94be                	add	s1,s1,a5
    return list->next == list;
ffffffffc0200c68:	6480                	ld	s0,8(s1)
ffffffffc0200c6a:	02848263          	beq	s1,s0,ffffffffc0200c8e <buddy_system_alloc_pages+0xa2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c6e:	6018                	ld	a4,0(s0)
ffffffffc0200c70:	641c                	ld	a5,8(s0)
    page = le2page(le, page_link);
ffffffffc0200c72:	fe840513          	addi	a0,s0,-24
    prev->next = next;
ffffffffc0200c76:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c78:	e398                	sd	a4,0(a5)
ffffffffc0200c7a:	57f5                	li	a5,-3
ffffffffc0200c7c:	ff040713          	addi	a4,s0,-16
ffffffffc0200c80:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200c84:	60e2                	ld	ra,24(sp)
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	64a2                	ld	s1,8(sp)
ffffffffc0200c8a:	6105                	addi	sp,sp,32
ffffffffc0200c8c:	8082                	ret
        split_page(order + 1);
ffffffffc0200c8e:	0015851b          	addiw	a0,a1,1
ffffffffc0200c92:	c39ff0ef          	jal	ra,ffffffffc02008ca <split_page>
    return list->next == list;
ffffffffc0200c96:	6400                	ld	s0,8(s0)
    if(list_empty(&(free_list(order)))) return NULL;
ffffffffc0200c98:	fc849be3          	bne	s1,s0,ffffffffc0200c6e <buddy_system_alloc_pages+0x82>
}
ffffffffc0200c9c:	60e2                	ld	ra,24(sp)
ffffffffc0200c9e:	6442                	ld	s0,16(sp)
ffffffffc0200ca0:	64a2                	ld	s1,8(sp)
        return NULL;
ffffffffc0200ca2:	4501                	li	a0,0
}
ffffffffc0200ca4:	6105                	addi	sp,sp,32
ffffffffc0200ca6:	8082                	ret
    assert(n > 0);
ffffffffc0200ca8:	00001697          	auipc	a3,0x1
ffffffffc0200cac:	01068693          	addi	a3,a3,16 # ffffffffc0201cb8 <commands+0x590>
ffffffffc0200cb0:	00001617          	auipc	a2,0x1
ffffffffc0200cb4:	01060613          	addi	a2,a2,16 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200cb8:	04900593          	li	a1,73
ffffffffc0200cbc:	00001517          	auipc	a0,0x1
ffffffffc0200cc0:	01c50513          	addi	a0,a0,28 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200cc4:	c76ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200cc8 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200cc8:	1141                	addi	sp,sp,-16
ffffffffc0200cca:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ccc:	c1e9                	beqz	a1,ffffffffc0200d8e <buddy_system_init_memmap+0xc6>
    for (; p != base + n; p ++) {
ffffffffc0200cce:	00259693          	slli	a3,a1,0x2
ffffffffc0200cd2:	96ae                	add	a3,a3,a1
ffffffffc0200cd4:	068e                	slli	a3,a3,0x3
ffffffffc0200cd6:	96aa                	add	a3,a3,a0
ffffffffc0200cd8:	87aa                	mv	a5,a0
ffffffffc0200cda:	00d50f63          	beq	a0,a3,ffffffffc0200cf8 <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200cde:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200ce0:	8b05                	andi	a4,a4,1
ffffffffc0200ce2:	c759                	beqz	a4,ffffffffc0200d70 <buddy_system_init_memmap+0xa8>
        p->flags = p->property = 0;
ffffffffc0200ce4:	0007a823          	sw	zero,16(a5)
ffffffffc0200ce8:	0007b423          	sd	zero,8(a5)
ffffffffc0200cec:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200cf0:	02878793          	addi	a5,a5,40
ffffffffc0200cf4:	fed795e3          	bne	a5,a3,ffffffffc0200cde <buddy_system_init_memmap+0x16>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200cf8:	4729                	li	a4,10
    uint32_t order_size = 1 << order;
ffffffffc0200cfa:	40000693          	li	a3,1024
ffffffffc0200cfe:	00005e17          	auipc	t3,0x5
ffffffffc0200d02:	31ae0e13          	addi	t3,t3,794 # ffffffffc0206018 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d06:	4309                	li	t1,2
        p->property = order_size;
ffffffffc0200d08:	c914                	sw	a3,16(a0)
ffffffffc0200d0a:	00850793          	addi	a5,a0,8
ffffffffc0200d0e:	4067b02f          	amoor.d	zero,t1,(a5)
        nr_free(order) += 1;
ffffffffc0200d12:	02071613          	slli	a2,a4,0x20
ffffffffc0200d16:	9201                	srli	a2,a2,0x20
ffffffffc0200d18:	00161793          	slli	a5,a2,0x1
ffffffffc0200d1c:	97b2                	add	a5,a5,a2
ffffffffc0200d1e:	078e                	slli	a5,a5,0x3
ffffffffc0200d20:	97f2                	add	a5,a5,t3
ffffffffc0200d22:	0107a803          	lw	a6,16(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d26:	0007b883          	ld	a7,0(a5)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200d2a:	01850613          	addi	a2,a0,24
        nr_free(order) += 1;
ffffffffc0200d2e:	2805                	addiw	a6,a6,1
ffffffffc0200d30:	0107a823          	sw	a6,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200d34:	e390                	sd	a2,0(a5)
ffffffffc0200d36:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0200d3a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200d3c:	01153c23          	sd	a7,24(a0)
        curr_size -= order_size;
ffffffffc0200d40:	02069793          	slli	a5,a3,0x20
ffffffffc0200d44:	9381                	srli	a5,a5,0x20
ffffffffc0200d46:	8d95                	sub	a1,a1,a3
        while(order > 0 && curr_size < order_size) {
ffffffffc0200d48:	cb19                	beqz	a4,ffffffffc0200d5e <buddy_system_init_memmap+0x96>
ffffffffc0200d4a:	00f5fa63          	bgeu	a1,a5,ffffffffc0200d5e <buddy_system_init_memmap+0x96>
            order_size >>= 1;
ffffffffc0200d4e:	0016d79b          	srliw	a5,a3,0x1
ffffffffc0200d52:	0007869b          	sext.w	a3,a5
            order -= 1;
ffffffffc0200d56:	377d                	addiw	a4,a4,-1
        while(order > 0 && curr_size < order_size) {
ffffffffc0200d58:	1782                	slli	a5,a5,0x20
ffffffffc0200d5a:	9381                	srli	a5,a5,0x20
ffffffffc0200d5c:	f77d                	bnez	a4,ffffffffc0200d4a <buddy_system_init_memmap+0x82>
        p += order_size;
ffffffffc0200d5e:	00279613          	slli	a2,a5,0x2
ffffffffc0200d62:	97b2                	add	a5,a5,a2
ffffffffc0200d64:	078e                	slli	a5,a5,0x3
ffffffffc0200d66:	953e                	add	a0,a0,a5
    while (curr_size != 0) {
ffffffffc0200d68:	f1c5                	bnez	a1,ffffffffc0200d08 <buddy_system_init_memmap+0x40>
}
ffffffffc0200d6a:	60a2                	ld	ra,8(sp)
ffffffffc0200d6c:	0141                	addi	sp,sp,16
ffffffffc0200d6e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200d70:	00001697          	auipc	a3,0x1
ffffffffc0200d74:	fe868693          	addi	a3,a3,-24 # ffffffffc0201d58 <commands+0x630>
ffffffffc0200d78:	00001617          	auipc	a2,0x1
ffffffffc0200d7c:	f4860613          	addi	a2,a2,-184 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200d80:	45f5                	li	a1,29
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	f5650513          	addi	a0,a0,-170 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200d8a:	bb0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0200d8e:	00001697          	auipc	a3,0x1
ffffffffc0200d92:	f2a68693          	addi	a3,a3,-214 # ffffffffc0201cb8 <commands+0x590>
ffffffffc0200d96:	00001617          	auipc	a2,0x1
ffffffffc0200d9a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0201cc0 <commands+0x598>
ffffffffc0200d9e:	45e9                	li	a1,26
ffffffffc0200da0:	00001517          	auipc	a0,0x1
ffffffffc0200da4:	f3850513          	addi	a0,a0,-200 # ffffffffc0201cd8 <commands+0x5b0>
ffffffffc0200da8:	b92ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200dac <pmm_init>:

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //pmm_manager = &best_fit_pmm_manager;
    //pmm_manager = &buddy_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200dac:	00001797          	auipc	a5,0x1
ffffffffc0200db0:	fdc78793          	addi	a5,a5,-36 # ffffffffc0201d88 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200db4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200db6:	1101                	addi	sp,sp,-32
ffffffffc0200db8:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dba:	00001517          	auipc	a0,0x1
ffffffffc0200dbe:	00650513          	addi	a0,a0,6 # ffffffffc0201dc0 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200dc2:	00005497          	auipc	s1,0x5
ffffffffc0200dc6:	69e48493          	addi	s1,s1,1694 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc0200dca:	ec06                	sd	ra,24(sp)
ffffffffc0200dcc:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200dce:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dd0:	ae2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200dd4:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dd6:	00005417          	auipc	s0,0x5
ffffffffc0200dda:	6a240413          	addi	s0,s0,1698 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200dde:	679c                	ld	a5,8(a5)
ffffffffc0200de0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200de2:	57f5                	li	a5,-3
ffffffffc0200de4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200de6:	00001517          	auipc	a0,0x1
ffffffffc0200dea:	ff250513          	addi	a0,a0,-14 # ffffffffc0201dd8 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dee:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200df0:	ac2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200df4:	46c5                	li	a3,17
ffffffffc0200df6:	06ee                	slli	a3,a3,0x1b
ffffffffc0200df8:	40100613          	li	a2,1025
ffffffffc0200dfc:	16fd                	addi	a3,a3,-1
ffffffffc0200dfe:	07e005b7          	lui	a1,0x7e00
ffffffffc0200e02:	0656                	slli	a2,a2,0x15
ffffffffc0200e04:	00001517          	auipc	a0,0x1
ffffffffc0200e08:	fec50513          	addi	a0,a0,-20 # ffffffffc0201df0 <buddy_system_pmm_manager+0x68>
ffffffffc0200e0c:	aa6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e10:	777d                	lui	a4,0xfffff
ffffffffc0200e12:	00006797          	auipc	a5,0x6
ffffffffc0200e16:	67578793          	addi	a5,a5,1653 # ffffffffc0207487 <end+0xfff>
ffffffffc0200e1a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200e1c:	00005517          	auipc	a0,0x5
ffffffffc0200e20:	63450513          	addi	a0,a0,1588 # ffffffffc0206450 <npage>
ffffffffc0200e24:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e28:	00005597          	auipc	a1,0x5
ffffffffc0200e2c:	63058593          	addi	a1,a1,1584 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e30:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e32:	e19c                	sd	a5,0(a1)
ffffffffc0200e34:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e36:	4701                	li	a4,0
ffffffffc0200e38:	4885                	li	a7,1
ffffffffc0200e3a:	fff80837          	lui	a6,0xfff80
ffffffffc0200e3e:	a011                	j	ffffffffc0200e42 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200e40:	619c                	ld	a5,0(a1)
ffffffffc0200e42:	97b6                	add	a5,a5,a3
ffffffffc0200e44:	07a1                	addi	a5,a5,8
ffffffffc0200e46:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e4a:	611c                	ld	a5,0(a0)
ffffffffc0200e4c:	0705                	addi	a4,a4,1
ffffffffc0200e4e:	02868693          	addi	a3,a3,40
ffffffffc0200e52:	01078633          	add	a2,a5,a6
ffffffffc0200e56:	fec765e3          	bltu	a4,a2,ffffffffc0200e40 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e5a:	6190                	ld	a2,0(a1)
ffffffffc0200e5c:	00279713          	slli	a4,a5,0x2
ffffffffc0200e60:	973e                	add	a4,a4,a5
ffffffffc0200e62:	fec006b7          	lui	a3,0xfec00
ffffffffc0200e66:	070e                	slli	a4,a4,0x3
ffffffffc0200e68:	96b2                	add	a3,a3,a2
ffffffffc0200e6a:	96ba                	add	a3,a3,a4
ffffffffc0200e6c:	c0200737          	lui	a4,0xc0200
ffffffffc0200e70:	08e6ef63          	bltu	a3,a4,ffffffffc0200f0e <pmm_init+0x162>
ffffffffc0200e74:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200e76:	45c5                	li	a1,17
ffffffffc0200e78:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e7a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200e7c:	04b6e863          	bltu	a3,a1,ffffffffc0200ecc <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200e80:	609c                	ld	a5,0(s1)
ffffffffc0200e82:	7b9c                	ld	a5,48(a5)
ffffffffc0200e84:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200e86:	00001517          	auipc	a0,0x1
ffffffffc0200e8a:	00250513          	addi	a0,a0,2 # ffffffffc0201e88 <buddy_system_pmm_manager+0x100>
ffffffffc0200e8e:	a24ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e92:	00004597          	auipc	a1,0x4
ffffffffc0200e96:	16e58593          	addi	a1,a1,366 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200e9a:	00005797          	auipc	a5,0x5
ffffffffc0200e9e:	5cb7bb23          	sd	a1,1494(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ea2:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ea6:	08f5e063          	bltu	a1,a5,ffffffffc0200f26 <pmm_init+0x17a>
ffffffffc0200eaa:	6010                	ld	a2,0(s0)
}
ffffffffc0200eac:	6442                	ld	s0,16(sp)
ffffffffc0200eae:	60e2                	ld	ra,24(sp)
ffffffffc0200eb0:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200eb2:	40c58633          	sub	a2,a1,a2
ffffffffc0200eb6:	00005797          	auipc	a5,0x5
ffffffffc0200eba:	5ac7b923          	sd	a2,1458(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ebe:	00001517          	auipc	a0,0x1
ffffffffc0200ec2:	fea50513          	addi	a0,a0,-22 # ffffffffc0201ea8 <buddy_system_pmm_manager+0x120>
}
ffffffffc0200ec6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ec8:	9eaff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200ecc:	6705                	lui	a4,0x1
ffffffffc0200ece:	177d                	addi	a4,a4,-1
ffffffffc0200ed0:	96ba                	add	a3,a3,a4
ffffffffc0200ed2:	777d                	lui	a4,0xfffff
ffffffffc0200ed4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200ed6:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200eda:	00f57e63          	bgeu	a0,a5,ffffffffc0200ef6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200ede:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200ee0:	982a                	add	a6,a6,a0
ffffffffc0200ee2:	00281513          	slli	a0,a6,0x2
ffffffffc0200ee6:	9542                	add	a0,a0,a6
ffffffffc0200ee8:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200eea:	8d95                	sub	a1,a1,a3
ffffffffc0200eec:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200eee:	81b1                	srli	a1,a1,0xc
ffffffffc0200ef0:	9532                	add	a0,a0,a2
ffffffffc0200ef2:	9782                	jalr	a5
}
ffffffffc0200ef4:	b771                	j	ffffffffc0200e80 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	f6260613          	addi	a2,a2,-158 # ffffffffc0201e58 <buddy_system_pmm_manager+0xd0>
ffffffffc0200efe:	06b00593          	li	a1,107
ffffffffc0200f02:	00001517          	auipc	a0,0x1
ffffffffc0200f06:	f7650513          	addi	a0,a0,-138 # ffffffffc0201e78 <buddy_system_pmm_manager+0xf0>
ffffffffc0200f0a:	a30ff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f0e:	00001617          	auipc	a2,0x1
ffffffffc0200f12:	f1260613          	addi	a2,a2,-238 # ffffffffc0201e20 <buddy_system_pmm_manager+0x98>
ffffffffc0200f16:	07200593          	li	a1,114
ffffffffc0200f1a:	00001517          	auipc	a0,0x1
ffffffffc0200f1e:	f2e50513          	addi	a0,a0,-210 # ffffffffc0201e48 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f22:	a18ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f26:	86ae                	mv	a3,a1
ffffffffc0200f28:	00001617          	auipc	a2,0x1
ffffffffc0200f2c:	ef860613          	addi	a2,a2,-264 # ffffffffc0201e20 <buddy_system_pmm_manager+0x98>
ffffffffc0200f30:	08d00593          	li	a1,141
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	f1450513          	addi	a0,a0,-236 # ffffffffc0201e48 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f3c:	9feff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200f40 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200f40:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200f42:	e589                	bnez	a1,ffffffffc0200f4c <strnlen+0xc>
ffffffffc0200f44:	a811                	j	ffffffffc0200f58 <strnlen+0x18>
        cnt ++;
ffffffffc0200f46:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200f48:	00f58863          	beq	a1,a5,ffffffffc0200f58 <strnlen+0x18>
ffffffffc0200f4c:	00f50733          	add	a4,a0,a5
ffffffffc0200f50:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0x3fdf8b78>
ffffffffc0200f54:	fb6d                	bnez	a4,ffffffffc0200f46 <strnlen+0x6>
ffffffffc0200f56:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200f58:	852e                	mv	a0,a1
ffffffffc0200f5a:	8082                	ret

ffffffffc0200f5c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200f5c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200f60:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200f64:	cb89                	beqz	a5,ffffffffc0200f76 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200f66:	0505                	addi	a0,a0,1
ffffffffc0200f68:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200f6a:	fee789e3          	beq	a5,a4,ffffffffc0200f5c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200f6e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0200f72:	9d19                	subw	a0,a0,a4
ffffffffc0200f74:	8082                	ret
ffffffffc0200f76:	4501                	li	a0,0
ffffffffc0200f78:	bfed                	j	ffffffffc0200f72 <strcmp+0x16>

ffffffffc0200f7a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0200f7a:	00054783          	lbu	a5,0(a0)
ffffffffc0200f7e:	c799                	beqz	a5,ffffffffc0200f8c <strchr+0x12>
        if (*s == c) {
ffffffffc0200f80:	00f58763          	beq	a1,a5,ffffffffc0200f8e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0200f84:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0200f88:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0200f8a:	fbfd                	bnez	a5,ffffffffc0200f80 <strchr+0x6>
    }
    return NULL;
ffffffffc0200f8c:	4501                	li	a0,0
}
ffffffffc0200f8e:	8082                	ret

ffffffffc0200f90 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0200f90:	ca01                	beqz	a2,ffffffffc0200fa0 <memset+0x10>
ffffffffc0200f92:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0200f94:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0200f96:	0785                	addi	a5,a5,1
ffffffffc0200f98:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0200f9c:	fec79de3          	bne	a5,a2,ffffffffc0200f96 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0200fa0:	8082                	ret

ffffffffc0200fa2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200fa2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fa6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200fa8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fac:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200fae:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fb2:	f022                	sd	s0,32(sp)
ffffffffc0200fb4:	ec26                	sd	s1,24(sp)
ffffffffc0200fb6:	e84a                	sd	s2,16(sp)
ffffffffc0200fb8:	f406                	sd	ra,40(sp)
ffffffffc0200fba:	e44e                	sd	s3,8(sp)
ffffffffc0200fbc:	84aa                	mv	s1,a0
ffffffffc0200fbe:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200fc0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200fc4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200fc6:	03067e63          	bgeu	a2,a6,ffffffffc0201002 <printnum+0x60>
ffffffffc0200fca:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200fcc:	00805763          	blez	s0,ffffffffc0200fda <printnum+0x38>
ffffffffc0200fd0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200fd2:	85ca                	mv	a1,s2
ffffffffc0200fd4:	854e                	mv	a0,s3
ffffffffc0200fd6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200fd8:	fc65                	bnez	s0,ffffffffc0200fd0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fda:	1a02                	slli	s4,s4,0x20
ffffffffc0200fdc:	00001797          	auipc	a5,0x1
ffffffffc0200fe0:	f0c78793          	addi	a5,a5,-244 # ffffffffc0201ee8 <buddy_system_pmm_manager+0x160>
ffffffffc0200fe4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200fe8:	9a3e                	add	s4,s4,a5
}
ffffffffc0200fea:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fec:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200ff0:	70a2                	ld	ra,40(sp)
ffffffffc0200ff2:	69a2                	ld	s3,8(sp)
ffffffffc0200ff4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ff6:	85ca                	mv	a1,s2
ffffffffc0200ff8:	87a6                	mv	a5,s1
}
ffffffffc0200ffa:	6942                	ld	s2,16(sp)
ffffffffc0200ffc:	64e2                	ld	s1,24(sp)
ffffffffc0200ffe:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201000:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201002:	03065633          	divu	a2,a2,a6
ffffffffc0201006:	8722                	mv	a4,s0
ffffffffc0201008:	f9bff0ef          	jal	ra,ffffffffc0200fa2 <printnum>
ffffffffc020100c:	b7f9                	j	ffffffffc0200fda <printnum+0x38>

ffffffffc020100e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020100e:	7119                	addi	sp,sp,-128
ffffffffc0201010:	f4a6                	sd	s1,104(sp)
ffffffffc0201012:	f0ca                	sd	s2,96(sp)
ffffffffc0201014:	ecce                	sd	s3,88(sp)
ffffffffc0201016:	e8d2                	sd	s4,80(sp)
ffffffffc0201018:	e4d6                	sd	s5,72(sp)
ffffffffc020101a:	e0da                	sd	s6,64(sp)
ffffffffc020101c:	fc5e                	sd	s7,56(sp)
ffffffffc020101e:	f06a                	sd	s10,32(sp)
ffffffffc0201020:	fc86                	sd	ra,120(sp)
ffffffffc0201022:	f8a2                	sd	s0,112(sp)
ffffffffc0201024:	f862                	sd	s8,48(sp)
ffffffffc0201026:	f466                	sd	s9,40(sp)
ffffffffc0201028:	ec6e                	sd	s11,24(sp)
ffffffffc020102a:	892a                	mv	s2,a0
ffffffffc020102c:	84ae                	mv	s1,a1
ffffffffc020102e:	8d32                	mv	s10,a2
ffffffffc0201030:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201032:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201036:	5b7d                	li	s6,-1
ffffffffc0201038:	00001a97          	auipc	s5,0x1
ffffffffc020103c:	ee4a8a93          	addi	s5,s5,-284 # ffffffffc0201f1c <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201040:	00001b97          	auipc	s7,0x1
ffffffffc0201044:	0b8b8b93          	addi	s7,s7,184 # ffffffffc02020f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201048:	000d4503          	lbu	a0,0(s10)
ffffffffc020104c:	001d0413          	addi	s0,s10,1
ffffffffc0201050:	01350a63          	beq	a0,s3,ffffffffc0201064 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201054:	c121                	beqz	a0,ffffffffc0201094 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201056:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201058:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020105a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020105c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201060:	ff351ae3          	bne	a0,s3,ffffffffc0201054 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201064:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201068:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020106c:	4c81                	li	s9,0
ffffffffc020106e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201070:	5c7d                	li	s8,-1
ffffffffc0201072:	5dfd                	li	s11,-1
ffffffffc0201074:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201078:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020107a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020107e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201082:	00140d13          	addi	s10,s0,1
ffffffffc0201086:	04b56263          	bltu	a0,a1,ffffffffc02010ca <vprintfmt+0xbc>
ffffffffc020108a:	058a                	slli	a1,a1,0x2
ffffffffc020108c:	95d6                	add	a1,a1,s5
ffffffffc020108e:	4194                	lw	a3,0(a1)
ffffffffc0201090:	96d6                	add	a3,a3,s5
ffffffffc0201092:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201094:	70e6                	ld	ra,120(sp)
ffffffffc0201096:	7446                	ld	s0,112(sp)
ffffffffc0201098:	74a6                	ld	s1,104(sp)
ffffffffc020109a:	7906                	ld	s2,96(sp)
ffffffffc020109c:	69e6                	ld	s3,88(sp)
ffffffffc020109e:	6a46                	ld	s4,80(sp)
ffffffffc02010a0:	6aa6                	ld	s5,72(sp)
ffffffffc02010a2:	6b06                	ld	s6,64(sp)
ffffffffc02010a4:	7be2                	ld	s7,56(sp)
ffffffffc02010a6:	7c42                	ld	s8,48(sp)
ffffffffc02010a8:	7ca2                	ld	s9,40(sp)
ffffffffc02010aa:	7d02                	ld	s10,32(sp)
ffffffffc02010ac:	6de2                	ld	s11,24(sp)
ffffffffc02010ae:	6109                	addi	sp,sp,128
ffffffffc02010b0:	8082                	ret
            padc = '0';
ffffffffc02010b2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02010b4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010b8:	846a                	mv	s0,s10
ffffffffc02010ba:	00140d13          	addi	s10,s0,1
ffffffffc02010be:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010c2:	0ff5f593          	zext.b	a1,a1
ffffffffc02010c6:	fcb572e3          	bgeu	a0,a1,ffffffffc020108a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02010ca:	85a6                	mv	a1,s1
ffffffffc02010cc:	02500513          	li	a0,37
ffffffffc02010d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02010d2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02010d6:	8d22                	mv	s10,s0
ffffffffc02010d8:	f73788e3          	beq	a5,s3,ffffffffc0201048 <vprintfmt+0x3a>
ffffffffc02010dc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02010e0:	1d7d                	addi	s10,s10,-1
ffffffffc02010e2:	ff379de3          	bne	a5,s3,ffffffffc02010dc <vprintfmt+0xce>
ffffffffc02010e6:	b78d                	j	ffffffffc0201048 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02010e8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02010ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02010f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02010f6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010fa:	02d86463          	bltu	a6,a3,ffffffffc0201122 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02010fe:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201102:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201106:	0186873b          	addw	a4,a3,s8
ffffffffc020110a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020110e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201110:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201114:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201116:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020111a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020111e:	fed870e3          	bgeu	a6,a3,ffffffffc02010fe <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201122:	f40ddce3          	bgez	s11,ffffffffc020107a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201126:	8de2                	mv	s11,s8
ffffffffc0201128:	5c7d                	li	s8,-1
ffffffffc020112a:	bf81                	j	ffffffffc020107a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020112c:	fffdc693          	not	a3,s11
ffffffffc0201130:	96fd                	srai	a3,a3,0x3f
ffffffffc0201132:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201136:	00144603          	lbu	a2,1(s0)
ffffffffc020113a:	2d81                	sext.w	s11,s11
ffffffffc020113c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020113e:	bf35                	j	ffffffffc020107a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201140:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201144:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201148:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020114a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020114c:	bfd9                	j	ffffffffc0201122 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020114e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201150:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201154:	01174463          	blt	a4,a7,ffffffffc020115c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201158:	1a088e63          	beqz	a7,ffffffffc0201314 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020115c:	000a3603          	ld	a2,0(s4)
ffffffffc0201160:	46c1                	li	a3,16
ffffffffc0201162:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201164:	2781                	sext.w	a5,a5
ffffffffc0201166:	876e                	mv	a4,s11
ffffffffc0201168:	85a6                	mv	a1,s1
ffffffffc020116a:	854a                	mv	a0,s2
ffffffffc020116c:	e37ff0ef          	jal	ra,ffffffffc0200fa2 <printnum>
            break;
ffffffffc0201170:	bde1                	j	ffffffffc0201048 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201172:	000a2503          	lw	a0,0(s4)
ffffffffc0201176:	85a6                	mv	a1,s1
ffffffffc0201178:	0a21                	addi	s4,s4,8
ffffffffc020117a:	9902                	jalr	s2
            break;
ffffffffc020117c:	b5f1                	j	ffffffffc0201048 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020117e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201180:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201184:	01174463          	blt	a4,a7,ffffffffc020118c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201188:	18088163          	beqz	a7,ffffffffc020130a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020118c:	000a3603          	ld	a2,0(s4)
ffffffffc0201190:	46a9                	li	a3,10
ffffffffc0201192:	8a2e                	mv	s4,a1
ffffffffc0201194:	bfc1                	j	ffffffffc0201164 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201196:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020119a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020119e:	bdf1                	j	ffffffffc020107a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02011a0:	85a6                	mv	a1,s1
ffffffffc02011a2:	02500513          	li	a0,37
ffffffffc02011a6:	9902                	jalr	s2
            break;
ffffffffc02011a8:	b545                	j	ffffffffc0201048 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011aa:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02011ae:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011b2:	b5e1                	j	ffffffffc020107a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02011b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011ba:	01174463          	blt	a4,a7,ffffffffc02011c2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02011be:	14088163          	beqz	a7,ffffffffc0201300 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02011c2:	000a3603          	ld	a2,0(s4)
ffffffffc02011c6:	46a1                	li	a3,8
ffffffffc02011c8:	8a2e                	mv	s4,a1
ffffffffc02011ca:	bf69                	j	ffffffffc0201164 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02011cc:	03000513          	li	a0,48
ffffffffc02011d0:	85a6                	mv	a1,s1
ffffffffc02011d2:	e03e                	sd	a5,0(sp)
ffffffffc02011d4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02011d6:	85a6                	mv	a1,s1
ffffffffc02011d8:	07800513          	li	a0,120
ffffffffc02011dc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011de:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02011e0:	6782                	ld	a5,0(sp)
ffffffffc02011e2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011e4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02011e8:	bfb5                	j	ffffffffc0201164 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02011ea:	000a3403          	ld	s0,0(s4)
ffffffffc02011ee:	008a0713          	addi	a4,s4,8
ffffffffc02011f2:	e03a                	sd	a4,0(sp)
ffffffffc02011f4:	14040263          	beqz	s0,ffffffffc0201338 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02011f8:	0fb05763          	blez	s11,ffffffffc02012e6 <vprintfmt+0x2d8>
ffffffffc02011fc:	02d00693          	li	a3,45
ffffffffc0201200:	0cd79163          	bne	a5,a3,ffffffffc02012c2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201204:	00044783          	lbu	a5,0(s0)
ffffffffc0201208:	0007851b          	sext.w	a0,a5
ffffffffc020120c:	cf85                	beqz	a5,ffffffffc0201244 <vprintfmt+0x236>
ffffffffc020120e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201212:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201216:	000c4563          	bltz	s8,ffffffffc0201220 <vprintfmt+0x212>
ffffffffc020121a:	3c7d                	addiw	s8,s8,-1
ffffffffc020121c:	036c0263          	beq	s8,s6,ffffffffc0201240 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201220:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201222:	0e0c8e63          	beqz	s9,ffffffffc020131e <vprintfmt+0x310>
ffffffffc0201226:	3781                	addiw	a5,a5,-32
ffffffffc0201228:	0ef47b63          	bgeu	s0,a5,ffffffffc020131e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020122c:	03f00513          	li	a0,63
ffffffffc0201230:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201232:	000a4783          	lbu	a5,0(s4)
ffffffffc0201236:	3dfd                	addiw	s11,s11,-1
ffffffffc0201238:	0a05                	addi	s4,s4,1
ffffffffc020123a:	0007851b          	sext.w	a0,a5
ffffffffc020123e:	ffe1                	bnez	a5,ffffffffc0201216 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201240:	01b05963          	blez	s11,ffffffffc0201252 <vprintfmt+0x244>
ffffffffc0201244:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201246:	85a6                	mv	a1,s1
ffffffffc0201248:	02000513          	li	a0,32
ffffffffc020124c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020124e:	fe0d9be3          	bnez	s11,ffffffffc0201244 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201252:	6a02                	ld	s4,0(sp)
ffffffffc0201254:	bbd5                	j	ffffffffc0201048 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201256:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201258:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020125c:	01174463          	blt	a4,a7,ffffffffc0201264 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201260:	08088d63          	beqz	a7,ffffffffc02012fa <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201264:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201268:	0a044d63          	bltz	s0,ffffffffc0201322 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020126c:	8622                	mv	a2,s0
ffffffffc020126e:	8a66                	mv	s4,s9
ffffffffc0201270:	46a9                	li	a3,10
ffffffffc0201272:	bdcd                	j	ffffffffc0201164 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201274:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201278:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020127a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020127c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201280:	8fb5                	xor	a5,a5,a3
ffffffffc0201282:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201286:	02d74163          	blt	a4,a3,ffffffffc02012a8 <vprintfmt+0x29a>
ffffffffc020128a:	00369793          	slli	a5,a3,0x3
ffffffffc020128e:	97de                	add	a5,a5,s7
ffffffffc0201290:	639c                	ld	a5,0(a5)
ffffffffc0201292:	cb99                	beqz	a5,ffffffffc02012a8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201294:	86be                	mv	a3,a5
ffffffffc0201296:	00001617          	auipc	a2,0x1
ffffffffc020129a:	c8260613          	addi	a2,a2,-894 # ffffffffc0201f18 <buddy_system_pmm_manager+0x190>
ffffffffc020129e:	85a6                	mv	a1,s1
ffffffffc02012a0:	854a                	mv	a0,s2
ffffffffc02012a2:	0ce000ef          	jal	ra,ffffffffc0201370 <printfmt>
ffffffffc02012a6:	b34d                	j	ffffffffc0201048 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02012a8:	00001617          	auipc	a2,0x1
ffffffffc02012ac:	c6060613          	addi	a2,a2,-928 # ffffffffc0201f08 <buddy_system_pmm_manager+0x180>
ffffffffc02012b0:	85a6                	mv	a1,s1
ffffffffc02012b2:	854a                	mv	a0,s2
ffffffffc02012b4:	0bc000ef          	jal	ra,ffffffffc0201370 <printfmt>
ffffffffc02012b8:	bb41                	j	ffffffffc0201048 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02012ba:	00001417          	auipc	s0,0x1
ffffffffc02012be:	c4640413          	addi	s0,s0,-954 # ffffffffc0201f00 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012c2:	85e2                	mv	a1,s8
ffffffffc02012c4:	8522                	mv	a0,s0
ffffffffc02012c6:	e43e                	sd	a5,8(sp)
ffffffffc02012c8:	c79ff0ef          	jal	ra,ffffffffc0200f40 <strnlen>
ffffffffc02012cc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02012d0:	01b05b63          	blez	s11,ffffffffc02012e6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02012d4:	67a2                	ld	a5,8(sp)
ffffffffc02012d6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02012dc:	85a6                	mv	a1,s1
ffffffffc02012de:	8552                	mv	a0,s4
ffffffffc02012e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012e2:	fe0d9ce3          	bnez	s11,ffffffffc02012da <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012e6:	00044783          	lbu	a5,0(s0)
ffffffffc02012ea:	00140a13          	addi	s4,s0,1
ffffffffc02012ee:	0007851b          	sext.w	a0,a5
ffffffffc02012f2:	d3a5                	beqz	a5,ffffffffc0201252 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012f4:	05e00413          	li	s0,94
ffffffffc02012f8:	bf39                	j	ffffffffc0201216 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02012fa:	000a2403          	lw	s0,0(s4)
ffffffffc02012fe:	b7ad                	j	ffffffffc0201268 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201300:	000a6603          	lwu	a2,0(s4)
ffffffffc0201304:	46a1                	li	a3,8
ffffffffc0201306:	8a2e                	mv	s4,a1
ffffffffc0201308:	bdb1                	j	ffffffffc0201164 <vprintfmt+0x156>
ffffffffc020130a:	000a6603          	lwu	a2,0(s4)
ffffffffc020130e:	46a9                	li	a3,10
ffffffffc0201310:	8a2e                	mv	s4,a1
ffffffffc0201312:	bd89                	j	ffffffffc0201164 <vprintfmt+0x156>
ffffffffc0201314:	000a6603          	lwu	a2,0(s4)
ffffffffc0201318:	46c1                	li	a3,16
ffffffffc020131a:	8a2e                	mv	s4,a1
ffffffffc020131c:	b5a1                	j	ffffffffc0201164 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020131e:	9902                	jalr	s2
ffffffffc0201320:	bf09                	j	ffffffffc0201232 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201322:	85a6                	mv	a1,s1
ffffffffc0201324:	02d00513          	li	a0,45
ffffffffc0201328:	e03e                	sd	a5,0(sp)
ffffffffc020132a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020132c:	6782                	ld	a5,0(sp)
ffffffffc020132e:	8a66                	mv	s4,s9
ffffffffc0201330:	40800633          	neg	a2,s0
ffffffffc0201334:	46a9                	li	a3,10
ffffffffc0201336:	b53d                	j	ffffffffc0201164 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201338:	03b05163          	blez	s11,ffffffffc020135a <vprintfmt+0x34c>
ffffffffc020133c:	02d00693          	li	a3,45
ffffffffc0201340:	f6d79de3          	bne	a5,a3,ffffffffc02012ba <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201344:	00001417          	auipc	s0,0x1
ffffffffc0201348:	bbc40413          	addi	s0,s0,-1092 # ffffffffc0201f00 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020134c:	02800793          	li	a5,40
ffffffffc0201350:	02800513          	li	a0,40
ffffffffc0201354:	00140a13          	addi	s4,s0,1
ffffffffc0201358:	bd6d                	j	ffffffffc0201212 <vprintfmt+0x204>
ffffffffc020135a:	00001a17          	auipc	s4,0x1
ffffffffc020135e:	ba7a0a13          	addi	s4,s4,-1113 # ffffffffc0201f01 <buddy_system_pmm_manager+0x179>
ffffffffc0201362:	02800513          	li	a0,40
ffffffffc0201366:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020136a:	05e00413          	li	s0,94
ffffffffc020136e:	b565                	j	ffffffffc0201216 <vprintfmt+0x208>

ffffffffc0201370 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201370:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201372:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201376:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201378:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020137a:	ec06                	sd	ra,24(sp)
ffffffffc020137c:	f83a                	sd	a4,48(sp)
ffffffffc020137e:	fc3e                	sd	a5,56(sp)
ffffffffc0201380:	e0c2                	sd	a6,64(sp)
ffffffffc0201382:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201384:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201386:	c89ff0ef          	jal	ra,ffffffffc020100e <vprintfmt>
}
ffffffffc020138a:	60e2                	ld	ra,24(sp)
ffffffffc020138c:	6161                	addi	sp,sp,80
ffffffffc020138e:	8082                	ret

ffffffffc0201390 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201390:	715d                	addi	sp,sp,-80
ffffffffc0201392:	e486                	sd	ra,72(sp)
ffffffffc0201394:	e0a6                	sd	s1,64(sp)
ffffffffc0201396:	fc4a                	sd	s2,56(sp)
ffffffffc0201398:	f84e                	sd	s3,48(sp)
ffffffffc020139a:	f452                	sd	s4,40(sp)
ffffffffc020139c:	f056                	sd	s5,32(sp)
ffffffffc020139e:	ec5a                	sd	s6,24(sp)
ffffffffc02013a0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02013a2:	c901                	beqz	a0,ffffffffc02013b2 <readline+0x22>
ffffffffc02013a4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02013a6:	00001517          	auipc	a0,0x1
ffffffffc02013aa:	b7250513          	addi	a0,a0,-1166 # ffffffffc0201f18 <buddy_system_pmm_manager+0x190>
ffffffffc02013ae:	d05fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02013b2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013b4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02013b6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02013b8:	4aa9                	li	s5,10
ffffffffc02013ba:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02013bc:	00005b97          	auipc	s7,0x5
ffffffffc02013c0:	c74b8b93          	addi	s7,s7,-908 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013c4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02013c8:	d63fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013cc:	00054a63          	bltz	a0,ffffffffc02013e0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013d0:	00a95a63          	bge	s2,a0,ffffffffc02013e4 <readline+0x54>
ffffffffc02013d4:	029a5263          	bge	s4,s1,ffffffffc02013f8 <readline+0x68>
        c = getchar();
ffffffffc02013d8:	d53fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013dc:	fe055ae3          	bgez	a0,ffffffffc02013d0 <readline+0x40>
            return NULL;
ffffffffc02013e0:	4501                	li	a0,0
ffffffffc02013e2:	a091                	j	ffffffffc0201426 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02013e4:	03351463          	bne	a0,s3,ffffffffc020140c <readline+0x7c>
ffffffffc02013e8:	e8a9                	bnez	s1,ffffffffc020143a <readline+0xaa>
        c = getchar();
ffffffffc02013ea:	d41fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013ee:	fe0549e3          	bltz	a0,ffffffffc02013e0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013f2:	fea959e3          	bge	s2,a0,ffffffffc02013e4 <readline+0x54>
ffffffffc02013f6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02013f8:	e42a                	sd	a0,8(sp)
ffffffffc02013fa:	ceffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02013fe:	6522                	ld	a0,8(sp)
ffffffffc0201400:	009b87b3          	add	a5,s7,s1
ffffffffc0201404:	2485                	addiw	s1,s1,1
ffffffffc0201406:	00a78023          	sb	a0,0(a5)
ffffffffc020140a:	bf7d                	j	ffffffffc02013c8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020140c:	01550463          	beq	a0,s5,ffffffffc0201414 <readline+0x84>
ffffffffc0201410:	fb651ce3          	bne	a0,s6,ffffffffc02013c8 <readline+0x38>
            cputchar(c);
ffffffffc0201414:	cd5fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201418:	00005517          	auipc	a0,0x5
ffffffffc020141c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206030 <buf>
ffffffffc0201420:	94aa                	add	s1,s1,a0
ffffffffc0201422:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201426:	60a6                	ld	ra,72(sp)
ffffffffc0201428:	6486                	ld	s1,64(sp)
ffffffffc020142a:	7962                	ld	s2,56(sp)
ffffffffc020142c:	79c2                	ld	s3,48(sp)
ffffffffc020142e:	7a22                	ld	s4,40(sp)
ffffffffc0201430:	7a82                	ld	s5,32(sp)
ffffffffc0201432:	6b62                	ld	s6,24(sp)
ffffffffc0201434:	6bc2                	ld	s7,16(sp)
ffffffffc0201436:	6161                	addi	sp,sp,80
ffffffffc0201438:	8082                	ret
            cputchar(c);
ffffffffc020143a:	4521                	li	a0,8
ffffffffc020143c:	cadfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201440:	34fd                	addiw	s1,s1,-1
ffffffffc0201442:	b759                	j	ffffffffc02013c8 <readline+0x38>

ffffffffc0201444 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201444:	4781                	li	a5,0
ffffffffc0201446:	00005717          	auipc	a4,0x5
ffffffffc020144a:	bc273703          	ld	a4,-1086(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020144e:	88ba                	mv	a7,a4
ffffffffc0201450:	852a                	mv	a0,a0
ffffffffc0201452:	85be                	mv	a1,a5
ffffffffc0201454:	863e                	mv	a2,a5
ffffffffc0201456:	00000073          	ecall
ffffffffc020145a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020145c:	8082                	ret

ffffffffc020145e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc020145e:	4781                	li	a5,0
ffffffffc0201460:	00005717          	auipc	a4,0x5
ffffffffc0201464:	02073703          	ld	a4,32(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc0201468:	88ba                	mv	a7,a4
ffffffffc020146a:	852a                	mv	a0,a0
ffffffffc020146c:	85be                	mv	a1,a5
ffffffffc020146e:	863e                	mv	a2,a5
ffffffffc0201470:	00000073          	ecall
ffffffffc0201474:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201476:	8082                	ret

ffffffffc0201478 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201478:	4501                	li	a0,0
ffffffffc020147a:	00005797          	auipc	a5,0x5
ffffffffc020147e:	b867b783          	ld	a5,-1146(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201482:	88be                	mv	a7,a5
ffffffffc0201484:	852a                	mv	a0,a0
ffffffffc0201486:	85aa                	mv	a1,a0
ffffffffc0201488:	862a                	mv	a2,a0
ffffffffc020148a:	00000073          	ecall
ffffffffc020148e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201490:	2501                	sext.w	a0,a0
ffffffffc0201492:	8082                	ret

ffffffffc0201494 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201494:	4781                	li	a5,0
ffffffffc0201496:	00005717          	auipc	a4,0x5
ffffffffc020149a:	b7a73703          	ld	a4,-1158(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc020149e:	88ba                	mv	a7,a4
ffffffffc02014a0:	853e                	mv	a0,a5
ffffffffc02014a2:	85be                	mv	a1,a5
ffffffffc02014a4:	863e                	mv	a2,a5
ffffffffc02014a6:	00000073          	ecall
ffffffffc02014aa:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc02014ac:	8082                	ret

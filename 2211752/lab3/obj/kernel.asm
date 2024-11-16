
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	52e60613          	addi	a2,a2,1326 # ffffffffc0211568 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	76f030ef          	jal	ra,ffffffffc0203fb8 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	43a58593          	addi	a1,a1,1082 # ffffffffc0204488 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	45250513          	addi	a0,a0,1106 # ffffffffc02044a8 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	707020ef          	jal	ra,ffffffffc0202f6c <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	423000ef          	jal	ra,ffffffffc0200c90 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	2e2010ef          	jal	ra,ffffffffc0201358 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	7a1030ef          	jal	ra,ffffffffc020404e <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	76b030ef          	jal	ra,ffffffffc020404e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	38050513          	addi	a0,a0,896 # ffffffffc02044b0 <etext+0x2c>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00006517          	auipc	a0,0x6
ffffffffc020014a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0205ee0 <default_pmm_manager+0x420>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	37050513          	addi	a0,a0,880 # ffffffffc02044d0 <etext+0x4c>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	37a50513          	addi	a0,a0,890 # ffffffffc02044f0 <etext+0x6c>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	30258593          	addi	a1,a1,770 # ffffffffc0204484 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	38650513          	addi	a0,a0,902 # ffffffffc0204510 <etext+0x8c>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	39250513          	addi	a0,a0,914 # ffffffffc0204530 <etext+0xac>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3be58593          	addi	a1,a1,958 # ffffffffc0211568 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	39e50513          	addi	a0,a0,926 # ffffffffc0204550 <etext+0xcc>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7a958593          	addi	a1,a1,1961 # ffffffffc0211967 <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	39050513          	addi	a0,a0,912 # ffffffffc0204570 <etext+0xec>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3b260613          	addi	a2,a2,946 # ffffffffc02045a0 <etext+0x11c>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	3be50513          	addi	a0,a0,958 # ffffffffc02045b8 <etext+0x134>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	3c660613          	addi	a2,a2,966 # ffffffffc02045d0 <etext+0x14c>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	3de58593          	addi	a1,a1,990 # ffffffffc02045f0 <etext+0x16c>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	3de50513          	addi	a0,a0,990 # ffffffffc02045f8 <etext+0x174>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	3e060613          	addi	a2,a2,992 # ffffffffc0204608 <etext+0x184>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	40058593          	addi	a1,a1,1024 # ffffffffc0204630 <etext+0x1ac>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	3c050513          	addi	a0,a0,960 # ffffffffc02045f8 <etext+0x174>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	3fc60613          	addi	a2,a2,1020 # ffffffffc0204640 <etext+0x1bc>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	41458593          	addi	a1,a1,1044 # ffffffffc0204660 <etext+0x1dc>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	3a450513          	addi	a0,a0,932 # ffffffffc02045f8 <etext+0x174>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	3e250513          	addi	a0,a0,994 # ffffffffc0204670 <etext+0x1ec>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	3e850513          	addi	a0,a0,1000 # ffffffffc0204698 <etext+0x214>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	43ac0c13          	addi	s8,s8,1082 # ffffffffc0204700 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	1c290913          	addi	s2,s2,450 # ffffffffc0205490 <commands+0xd90>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	3ea48493          	addi	s1,s1,1002 # ffffffffc02046c0 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	3e8b0b13          	addi	s6,s6,1000 # ffffffffc02046c8 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	308a0a13          	addi	s4,s4,776 # ffffffffc02045f0 <etext+0x16c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	0dc040ef          	jal	ra,ffffffffc02043d0 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	3f6d0d13          	addi	s10,s10,1014 # ffffffffc0204700 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	46d030ef          	jal	ra,ffffffffc0203f84 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	459030ef          	jal	ra,ffffffffc0203f84 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	439030ef          	jal	ra,ffffffffc0203fa2 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	3fb030ef          	jal	ra,ffffffffc0203fa2 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	32650513          	addi	a0,a0,806 # ffffffffc02046e8 <etext+0x264>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	3d5030ef          	jal	ra,ffffffffc0203fca <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	3b1030ef          	jal	ra,ffffffffc0203fca <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	2fc50513          	addi	a0,a0,764 # ffffffffc0204748 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	24450513          	addi	a0,a0,580 # ffffffffc0204768 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe053503          	ld	a0,-32(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	5210006f          	j	ffffffffc0201268 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	23c60613          	addi	a2,a2,572 # ffffffffc0204788 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	24850513          	addi	a0,a0,584 # ffffffffc02047a0 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	22e50513          	addi	a0,a0,558 # ffffffffc02047b8 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	23650513          	addi	a0,a0,566 # ffffffffc02047d0 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	24050513          	addi	a0,a0,576 # ffffffffc02047e8 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	24a50513          	addi	a0,a0,586 # ffffffffc0204800 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	25450513          	addi	a0,a0,596 # ffffffffc0204818 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	25e50513          	addi	a0,a0,606 # ffffffffc0204830 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	26850513          	addi	a0,a0,616 # ffffffffc0204848 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	27250513          	addi	a0,a0,626 # ffffffffc0204860 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	27c50513          	addi	a0,a0,636 # ffffffffc0204878 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	28650513          	addi	a0,a0,646 # ffffffffc0204890 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	29050513          	addi	a0,a0,656 # ffffffffc02048a8 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	29a50513          	addi	a0,a0,666 # ffffffffc02048c0 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	2a450513          	addi	a0,a0,676 # ffffffffc02048d8 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2ae50513          	addi	a0,a0,686 # ffffffffc02048f0 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2b850513          	addi	a0,a0,696 # ffffffffc0204908 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2c250513          	addi	a0,a0,706 # ffffffffc0204920 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2cc50513          	addi	a0,a0,716 # ffffffffc0204938 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2d650513          	addi	a0,a0,726 # ffffffffc0204950 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	2e050513          	addi	a0,a0,736 # ffffffffc0204968 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	2ea50513          	addi	a0,a0,746 # ffffffffc0204980 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	2f450513          	addi	a0,a0,756 # ffffffffc0204998 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	2fe50513          	addi	a0,a0,766 # ffffffffc02049b0 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	30850513          	addi	a0,a0,776 # ffffffffc02049c8 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	31250513          	addi	a0,a0,786 # ffffffffc02049e0 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	31c50513          	addi	a0,a0,796 # ffffffffc02049f8 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	32650513          	addi	a0,a0,806 # ffffffffc0204a10 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	33050513          	addi	a0,a0,816 # ffffffffc0204a28 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	33a50513          	addi	a0,a0,826 # ffffffffc0204a40 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	34450513          	addi	a0,a0,836 # ffffffffc0204a58 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	34e50513          	addi	a0,a0,846 # ffffffffc0204a70 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	35850513          	addi	a0,a0,856 # ffffffffc0204a88 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	35e50513          	addi	a0,a0,862 # ffffffffc0204aa0 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	36250513          	addi	a0,a0,866 # ffffffffc0204ab8 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	36250513          	addi	a0,a0,866 # ffffffffc0204ad0 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	36a50513          	addi	a0,a0,874 # ffffffffc0204ae8 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	37250513          	addi	a0,a0,882 # ffffffffc0204b00 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	37650513          	addi	a0,a0,886 # ffffffffc0204b18 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	42270713          	addi	a4,a4,1058 # ffffffffc0204be0 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	3c050513          	addi	a0,a0,960 # ffffffffc0204b90 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	39450513          	addi	a0,a0,916 # ffffffffc0204b70 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	34850513          	addi	a0,a0,840 # ffffffffc0204b30 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	35c50513          	addi	a0,a0,860 # ffffffffc0204b50 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c5bff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	39a50513          	addi	a0,a0,922 # ffffffffc0204bc0 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	37650513          	addi	a0,a0,886 # ffffffffc0204bb0 <commands+0x4b0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	56c70713          	addi	a4,a4,1388 # ffffffffc0204dc8 <commands+0x6c8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	54250513          	addi	a0,a0,1346 # ffffffffc0204db0 <commands+0x6b0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	38050513          	addi	a0,a0,896 # ffffffffc0204c10 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	38c50513          	addi	a0,a0,908 # ffffffffc0204c30 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	3a250513          	addi	a0,a0,930 # ffffffffc0204c50 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	3b050513          	addi	a0,a0,944 # ffffffffc0204c68 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	3b650513          	addi	a0,a0,950 # ffffffffc0204c78 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	3cc50513          	addi	a0,a0,972 # ffffffffc0204c98 <commands+0x598>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	3c660613          	addi	a2,a2,966 # ffffffffc0204cb0 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	eaa50513          	addi	a0,a0,-342 # ffffffffc02047a0 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	3ce50513          	addi	a0,a0,974 # ffffffffc0204cd0 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	3dc50513          	addi	a0,a0,988 # ffffffffc0204ce8 <commands+0x5e8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	38660613          	addi	a2,a2,902 # ffffffffc0204cb0 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	e6a50513          	addi	a0,a0,-406 # ffffffffc02047a0 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	3be50513          	addi	a0,a0,958 # ffffffffc0204d00 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	3d450513          	addi	a0,a0,980 # ffffffffc0204d20 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204d40 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	40050513          	addi	a0,a0,1024 # ffffffffc0204d60 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	41650513          	addi	a0,a0,1046 # ffffffffc0204d80 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	42450513          	addi	a0,a0,1060 # ffffffffc0204d98 <commands+0x698>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	31c60613          	addi	a2,a2,796 # ffffffffc0204cb0 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	e0050513          	addi	a0,a0,-512 # ffffffffc02047a0 <commands+0xa0>
ffffffffc02009a8:	f5aff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	2f060613          	addi	a2,a2,752 # ffffffffc0204cb0 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	dd450513          	addi	a0,a0,-556 # ffffffffc02047a0 <commands+0xa0>
ffffffffc02009d4:	f2eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ab2:	00004697          	auipc	a3,0x4
ffffffffc0200ab6:	35668693          	addi	a3,a3,854 # ffffffffc0204e08 <commands+0x708>
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	36e60613          	addi	a2,a2,878 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200ac2:	07d00593          	li	a1,125
ffffffffc0200ac6:	00004517          	auipc	a0,0x4
ffffffffc0200aca:	37a50513          	addi	a0,a0,890 # ffffffffc0204e40 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ace:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad0:	e32ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ad4 <mm_create>:
mm_create(void) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ad6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ada:	e022                	sd	s0,0(sp)
ffffffffc0200adc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ade:	150030ef          	jal	ra,ffffffffc0203c2e <kmalloc>
ffffffffc0200ae2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ae4:	c105                	beqz	a0,ffffffffc0200b04 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae6:	e408                	sd	a0,8(s0)
ffffffffc0200ae8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200aea:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200aee:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200af2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200af6:	00011797          	auipc	a5,0x11
ffffffffc0200afa:	a3a7a783          	lw	a5,-1478(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200afe:	eb81                	bnez	a5,ffffffffc0200b0e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b00:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b04:	60a2                	ld	ra,8(sp)
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	6402                	ld	s0,0(sp)
ffffffffc0200b0a:	0141                	addi	sp,sp,16
ffffffffc0200b0c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b0e:	6b5000ef          	jal	ra,ffffffffc02019c2 <swap_init_mm>
}
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	6402                	ld	s0,0(sp)
ffffffffc0200b18:	0141                	addi	sp,sp,16
ffffffffc0200b1a:	8082                	ret

ffffffffc0200b1c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b1c:	1101                	addi	sp,sp,-32
ffffffffc0200b1e:	e04a                	sd	s2,0(sp)
ffffffffc0200b20:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b22:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e426                	sd	s1,8(sp)
ffffffffc0200b2a:	ec06                	sd	ra,24(sp)
ffffffffc0200b2c:	84ae                	mv	s1,a1
ffffffffc0200b2e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b30:	0fe030ef          	jal	ra,ffffffffc0203c2e <kmalloc>
    if (vma != NULL) {
ffffffffc0200b34:	c509                	beqz	a0,ffffffffc0200b3e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b36:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b3a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b3c:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b3e:	60e2                	ld	ra,24(sp)
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	64a2                	ld	s1,8(sp)
ffffffffc0200b44:	6902                	ld	s2,0(sp)
ffffffffc0200b46:	6105                	addi	sp,sp,32
ffffffffc0200b48:	8082                	ret

ffffffffc0200b4a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200b4a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200b4c:	c505                	beqz	a0,ffffffffc0200b74 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200b4e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b50:	c501                	beqz	a0,ffffffffc0200b58 <find_vma+0xe>
ffffffffc0200b52:	651c                	ld	a5,8(a0)
ffffffffc0200b54:	02f5f263          	bgeu	a1,a5,ffffffffc0200b78 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b58:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200b5a:	00f68d63          	beq	a3,a5,ffffffffc0200b74 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b5e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b62:	00e5e663          	bltu	a1,a4,ffffffffc0200b6e <find_vma+0x24>
ffffffffc0200b66:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b6a:	00e5ec63          	bltu	a1,a4,ffffffffc0200b82 <find_vma+0x38>
ffffffffc0200b6e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b70:	fef697e3          	bne	a3,a5,ffffffffc0200b5e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200b74:	4501                	li	a0,0
}
ffffffffc0200b76:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b78:	691c                	ld	a5,16(a0)
ffffffffc0200b7a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200b58 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200b7e:	ea88                	sd	a0,16(a3)
ffffffffc0200b80:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200b82:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200b86:	ea88                	sd	a0,16(a3)
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b8a:	6590                	ld	a2,8(a1)
ffffffffc0200b8c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200b90:	1141                	addi	sp,sp,-16
ffffffffc0200b92:	e406                	sd	ra,8(sp)
ffffffffc0200b94:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b96:	01066763          	bltu	a2,a6,ffffffffc0200ba4 <insert_vma_struct+0x1a>
ffffffffc0200b9a:	a085                	j	ffffffffc0200bfa <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200b9c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ba0:	04e66863          	bltu	a2,a4,ffffffffc0200bf0 <insert_vma_struct+0x66>
ffffffffc0200ba4:	86be                	mv	a3,a5
ffffffffc0200ba6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200ba8:	fef51ae3          	bne	a0,a5,ffffffffc0200b9c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bac:	02a68463          	beq	a3,a0,ffffffffc0200bd4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bb0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bb4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200bb8:	08e8f163          	bgeu	a7,a4,ffffffffc0200c3a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bbc:	04e66f63          	bltu	a2,a4,ffffffffc0200c1a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200bc0:	00f50a63          	beq	a0,a5,ffffffffc0200bd4 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bc4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bc8:	05076963          	bltu	a4,a6,ffffffffc0200c1a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bcc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bd0:	02c77363          	bgeu	a4,a2,ffffffffc0200bf6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bd4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bd6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bd8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bdc:	e390                	sd	a2,0(a5)
ffffffffc0200bde:	e690                	sd	a2,8(a3)
}
ffffffffc0200be0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200be2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200be4:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200be6:	0017079b          	addiw	a5,a4,1
ffffffffc0200bea:	d11c                	sw	a5,32(a0)
}
ffffffffc0200bec:	0141                	addi	sp,sp,16
ffffffffc0200bee:	8082                	ret
    if (le_prev != list) {
ffffffffc0200bf0:	fca690e3          	bne	a3,a0,ffffffffc0200bb0 <insert_vma_struct+0x26>
ffffffffc0200bf4:	bfd1                	j	ffffffffc0200bc8 <insert_vma_struct+0x3e>
ffffffffc0200bf6:	ebbff0ef          	jal	ra,ffffffffc0200ab0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bfa:	00004697          	auipc	a3,0x4
ffffffffc0200bfe:	25668693          	addi	a3,a3,598 # ffffffffc0204e50 <commands+0x750>
ffffffffc0200c02:	00004617          	auipc	a2,0x4
ffffffffc0200c06:	22660613          	addi	a2,a2,550 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200c0a:	08400593          	li	a1,132
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	23250513          	addi	a0,a0,562 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200c16:	cecff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	27668693          	addi	a3,a3,630 # ffffffffc0204e90 <commands+0x790>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	20660613          	addi	a2,a2,518 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200c2a:	07c00593          	li	a1,124
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	21250513          	addi	a0,a0,530 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	23668693          	addi	a3,a3,566 # ffffffffc0204e70 <commands+0x770>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	1e660613          	addi	a2,a2,486 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200c4a:	07b00593          	li	a1,123
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	1f250513          	addi	a0,a0,498 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200c5a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e022                	sd	s0,0(sp)
ffffffffc0200c5e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c60:	6508                	ld	a0,8(a0)
ffffffffc0200c62:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c64:	00a40e63          	beq	s0,a0,ffffffffc0200c80 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c68:	6118                	ld	a4,0(a0)
ffffffffc0200c6a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c6c:	03000593          	li	a1,48
ffffffffc0200c70:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c72:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c74:	e398                	sd	a4,0(a5)
ffffffffc0200c76:	072030ef          	jal	ra,ffffffffc0203ce8 <kfree>
    return listelm->next;
ffffffffc0200c7a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c7c:	fea416e3          	bne	s0,a0,ffffffffc0200c68 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c80:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200c82:	6402                	ld	s0,0(sp)
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c86:	03000593          	li	a1,48
}
ffffffffc0200c8a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c8c:	05c0306f          	j	ffffffffc0203ce8 <kfree>

ffffffffc0200c90 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200c90:	715d                	addi	sp,sp,-80
ffffffffc0200c92:	e486                	sd	ra,72(sp)
ffffffffc0200c94:	f44e                	sd	s3,40(sp)
ffffffffc0200c96:	f052                	sd	s4,32(sp)
ffffffffc0200c98:	e0a2                	sd	s0,64(sp)
ffffffffc0200c9a:	fc26                	sd	s1,56(sp)
ffffffffc0200c9c:	f84a                	sd	s2,48(sp)
ffffffffc0200c9e:	ec56                	sd	s5,24(sp)
ffffffffc0200ca0:	e85a                	sd	s6,16(sp)
ffffffffc0200ca2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ca4:	6a5010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0200ca8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200caa:	69f010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0200cae:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cb0:	03000513          	li	a0,48
ffffffffc0200cb4:	77b020ef          	jal	ra,ffffffffc0203c2e <kmalloc>
    if (mm != NULL) {
ffffffffc0200cb8:	56050863          	beqz	a0,ffffffffc0201228 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0200cbc:	e508                	sd	a0,8(a0)
ffffffffc0200cbe:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200cc0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200cc4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200cc8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ccc:	00011797          	auipc	a5,0x11
ffffffffc0200cd0:	8647a783          	lw	a5,-1948(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200cd4:	84aa                	mv	s1,a0
ffffffffc0200cd6:	e7b9                	bnez	a5,ffffffffc0200d24 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0200cd8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200cdc:	03200413          	li	s0,50
ffffffffc0200ce0:	a811                	j	ffffffffc0200cf4 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0200ce2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce6:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200cea:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200cec:	8526                	mv	a0,s1
ffffffffc0200cee:	e9dff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cf2:	cc05                	beqz	s0,ffffffffc0200d2a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf4:	03000513          	li	a0,48
ffffffffc0200cf8:	737020ef          	jal	ra,ffffffffc0203c2e <kmalloc>
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d02:	f165                	bnez	a0,ffffffffc0200ce2 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d04:	00004697          	auipc	a3,0x4
ffffffffc0200d08:	3dc68693          	addi	a3,a3,988 # ffffffffc02050e0 <commands+0x9e0>
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	11c60613          	addi	a2,a2,284 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200d14:	0ce00593          	li	a1,206
ffffffffc0200d18:	00004517          	auipc	a0,0x4
ffffffffc0200d1c:	12850513          	addi	a0,a0,296 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200d20:	be2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d24:	49f000ef          	jal	ra,ffffffffc02019c2 <swap_init_mm>
ffffffffc0200d28:	bf55                	j	ffffffffc0200cdc <vmm_init+0x4c>
ffffffffc0200d2a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d2e:	1f900913          	li	s2,505
ffffffffc0200d32:	a819                	j	ffffffffc0200d48 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0200d34:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d36:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d38:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d3e:	8526                	mv	a0,s1
ffffffffc0200d40:	e4bff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d44:	03240a63          	beq	s0,s2,ffffffffc0200d78 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d48:	03000513          	li	a0,48
ffffffffc0200d4c:	6e3020ef          	jal	ra,ffffffffc0203c2e <kmalloc>
ffffffffc0200d50:	85aa                	mv	a1,a0
ffffffffc0200d52:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d56:	fd79                	bnez	a0,ffffffffc0200d34 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	38868693          	addi	a3,a3,904 # ffffffffc02050e0 <commands+0x9e0>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	0c860613          	addi	a2,a2,200 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200d68:	0d400593          	li	a1,212
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	0d450513          	addi	a0,a0,212 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200d74:	b8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0200d78:	649c                	ld	a5,8(s1)
ffffffffc0200d7a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d7c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d80:	2ef48463          	beq	s1,a5,ffffffffc0201068 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d84:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200d88:	ffe70693          	addi	a3,a4,-2
ffffffffc0200d8c:	26d61e63          	bne	a2,a3,ffffffffc0201008 <vmm_init+0x378>
ffffffffc0200d90:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200d94:	26e69a63          	bne	a3,a4,ffffffffc0201008 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d98:	0715                	addi	a4,a4,5
ffffffffc0200d9a:	679c                	ld	a5,8(a5)
ffffffffc0200d9c:	feb712e3          	bne	a4,a1,ffffffffc0200d80 <vmm_init+0xf0>
ffffffffc0200da0:	4b1d                	li	s6,7
ffffffffc0200da2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200da4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200da8:	85a2                	mv	a1,s0
ffffffffc0200daa:	8526                	mv	a0,s1
ffffffffc0200dac:	d9fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200db0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200db2:	2c050b63          	beqz	a0,ffffffffc0201088 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200db6:	00140593          	addi	a1,s0,1
ffffffffc0200dba:	8526                	mv	a0,s1
ffffffffc0200dbc:	d8fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200dc0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200dc2:	2e050363          	beqz	a0,ffffffffc02010a8 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dc6:	85da                	mv	a1,s6
ffffffffc0200dc8:	8526                	mv	a0,s1
ffffffffc0200dca:	d81ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dce:	2e051d63          	bnez	a0,ffffffffc02010c8 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dd2:	00340593          	addi	a1,s0,3
ffffffffc0200dd6:	8526                	mv	a0,s1
ffffffffc0200dd8:	d73ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma4 == NULL);
ffffffffc0200ddc:	30051663          	bnez	a0,ffffffffc02010e8 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200de0:	00440593          	addi	a1,s0,4
ffffffffc0200de4:	8526                	mv	a0,s1
ffffffffc0200de6:	d65ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma5 == NULL);
ffffffffc0200dea:	30051f63          	bnez	a0,ffffffffc0201108 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200dee:	00893783          	ld	a5,8(s2)
ffffffffc0200df2:	24879b63          	bne	a5,s0,ffffffffc0201048 <vmm_init+0x3b8>
ffffffffc0200df6:	01093783          	ld	a5,16(s2)
ffffffffc0200dfa:	25679763          	bne	a5,s6,ffffffffc0201048 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200dfe:	008ab783          	ld	a5,8(s5)
ffffffffc0200e02:	22879363          	bne	a5,s0,ffffffffc0201028 <vmm_init+0x398>
ffffffffc0200e06:	010ab783          	ld	a5,16(s5)
ffffffffc0200e0a:	21679f63          	bne	a5,s6,ffffffffc0201028 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e0e:	0415                	addi	s0,s0,5
ffffffffc0200e10:	0b15                	addi	s6,s6,5
ffffffffc0200e12:	f9741be3          	bne	s0,s7,ffffffffc0200da8 <vmm_init+0x118>
ffffffffc0200e16:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e18:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e1a:	85a2                	mv	a1,s0
ffffffffc0200e1c:	8526                	mv	a0,s1
ffffffffc0200e1e:	d2dff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200e22:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200e26:	c90d                	beqz	a0,ffffffffc0200e58 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e28:	6914                	ld	a3,16(a0)
ffffffffc0200e2a:	6510                	ld	a2,8(a0)
ffffffffc0200e2c:	00004517          	auipc	a0,0x4
ffffffffc0200e30:	18450513          	addi	a0,a0,388 # ffffffffc0204fb0 <commands+0x8b0>
ffffffffc0200e34:	a86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	1a068693          	addi	a3,a3,416 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	fe860613          	addi	a2,a2,-24 # ffffffffc0204e28 <commands+0x728>
ffffffffc0200e48:	0f600593          	li	a1,246
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	ff450513          	addi	a0,a0,-12 # ffffffffc0204e40 <commands+0x740>
ffffffffc0200e54:	aaeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200e58:	147d                	addi	s0,s0,-1
ffffffffc0200e5a:	fd2410e3          	bne	s0,s2,ffffffffc0200e1a <vmm_init+0x18a>
ffffffffc0200e5e:	a811                	j	ffffffffc0200e72 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e60:	6118                	ld	a4,0(a0)
ffffffffc0200e62:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200e64:	03000593          	li	a1,48
ffffffffc0200e68:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200e6a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e6c:	e398                	sd	a4,0(a5)
ffffffffc0200e6e:	67b020ef          	jal	ra,ffffffffc0203ce8 <kfree>
    return listelm->next;
ffffffffc0200e72:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e74:	fea496e3          	bne	s1,a0,ffffffffc0200e60 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e78:	03000593          	li	a1,48
ffffffffc0200e7c:	8526                	mv	a0,s1
ffffffffc0200e7e:	66b020ef          	jal	ra,ffffffffc0203ce8 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e82:	4c7010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0200e86:	3caa1163          	bne	s4,a0,ffffffffc0201248 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e8a:	00004517          	auipc	a0,0x4
ffffffffc0200e8e:	18e50513          	addi	a0,a0,398 # ffffffffc0205018 <commands+0x918>
ffffffffc0200e92:	a28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e96:	4b3010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0200e9a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e9c:	03000513          	li	a0,48
ffffffffc0200ea0:	58f020ef          	jal	ra,ffffffffc0203c2e <kmalloc>
ffffffffc0200ea4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ea6:	2a050163          	beqz	a0,ffffffffc0201148 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eaa:	00010797          	auipc	a5,0x10
ffffffffc0200eae:	6867a783          	lw	a5,1670(a5) # ffffffffc0211530 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200eb2:	e508                	sd	a0,8(a0)
ffffffffc0200eb4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200eb6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200eba:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ebe:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec2:	14079063          	bnez	a5,ffffffffc0201002 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0200ec6:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200eca:	00010917          	auipc	s2,0x10
ffffffffc0200ece:	67693903          	ld	s2,1654(s2) # ffffffffc0211540 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ed2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	62873d23          	sd	s0,1594(a4) # ffffffffc0211510 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200ede:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200ee2:	24079363          	bnez	a5,ffffffffc0201128 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ee6:	03000513          	li	a0,48
ffffffffc0200eea:	545020ef          	jal	ra,ffffffffc0203c2e <kmalloc>
ffffffffc0200eee:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ef0:	28050063          	beqz	a0,ffffffffc0201170 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0200ef4:	002007b7          	lui	a5,0x200
ffffffffc0200ef8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200efc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200efe:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f00:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f04:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f06:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f0a:	c81ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f0e:	10000593          	li	a1,256
ffffffffc0200f12:	8522                	mv	a0,s0
ffffffffc0200f14:	c37ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200f18:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f1c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f20:	26aa1863          	bne	s4,a0,ffffffffc0201190 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0200f24:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f28:	0785                	addi	a5,a5,1
ffffffffc0200f2a:	fee79de3          	bne	a5,a4,ffffffffc0200f24 <vmm_init+0x294>
        sum += i;
ffffffffc0200f2e:	6705                	lui	a4,0x1
ffffffffc0200f30:	10000793          	li	a5,256
ffffffffc0200f34:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f38:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f3c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200f40:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200f42:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f44:	fec79ce3          	bne	a5,a2,ffffffffc0200f3c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0200f48:	26071463          	bnez	a4,ffffffffc02011b0 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200f4c:	4581                	li	a1,0
ffffffffc0200f4e:	854a                	mv	a0,s2
ffffffffc0200f50:	683010ef          	jal	ra,ffffffffc0202dd2 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f54:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f58:	00010717          	auipc	a4,0x10
ffffffffc0200f5c:	5f073703          	ld	a4,1520(a4) # ffffffffc0211548 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f60:	078a                	slli	a5,a5,0x2
ffffffffc0200f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f64:	26e7f663          	bgeu	a5,a4,ffffffffc02011d0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	43073703          	ld	a4,1072(a4) # ffffffffc0206398 <nbase>
ffffffffc0200f70:	8f99                	sub	a5,a5,a4
ffffffffc0200f72:	00379713          	slli	a4,a5,0x3
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f7a:	00010517          	auipc	a0,0x10
ffffffffc0200f7e:	5d653503          	ld	a0,1494(a0) # ffffffffc0211550 <pages>
ffffffffc0200f82:	953e                	add	a0,a0,a5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	383010ef          	jal	ra,ffffffffc0202b08 <free_pages>
    return listelm->next;
ffffffffc0200f8a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0200f8c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0200f90:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200f94:	00a40e63          	beq	s0,a0,ffffffffc0200fb0 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f98:	6118                	ld	a4,0(a0)
ffffffffc0200f9a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200f9c:	03000593          	li	a1,48
ffffffffc0200fa0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fa2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fa4:	e398                	sd	a4,0(a5)
ffffffffc0200fa6:	543020ef          	jal	ra,ffffffffc0203ce8 <kfree>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fac:	fea416e3          	bne	s0,a0,ffffffffc0200f98 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fb0:	03000593          	li	a1,48
ffffffffc0200fb4:	8522                	mv	a0,s0
ffffffffc0200fb6:	533020ef          	jal	ra,ffffffffc0203ce8 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fba:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fbc:	00010797          	auipc	a5,0x10
ffffffffc0200fc0:	5407ba23          	sd	zero,1364(a5) # ffffffffc0211510 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fc4:	385010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0200fc8:	22a49063          	bne	s1,a0,ffffffffc02011e8 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fcc:	00004517          	auipc	a0,0x4
ffffffffc0200fd0:	0dc50513          	addi	a0,a0,220 # ffffffffc02050a8 <commands+0x9a8>
ffffffffc0200fd4:	8e6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fd8:	371010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200fdc:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fde:	22a99563          	bne	s3,a0,ffffffffc0201208 <vmm_init+0x578>
}
ffffffffc0200fe2:	6406                	ld	s0,64(sp)
ffffffffc0200fe4:	60a6                	ld	ra,72(sp)
ffffffffc0200fe6:	74e2                	ld	s1,56(sp)
ffffffffc0200fe8:	7942                	ld	s2,48(sp)
ffffffffc0200fea:	79a2                	ld	s3,40(sp)
ffffffffc0200fec:	7a02                	ld	s4,32(sp)
ffffffffc0200fee:	6ae2                	ld	s5,24(sp)
ffffffffc0200ff0:	6b42                	ld	s6,16(sp)
ffffffffc0200ff2:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ff4:	00004517          	auipc	a0,0x4
ffffffffc0200ff8:	0d450513          	addi	a0,a0,212 # ffffffffc02050c8 <commands+0x9c8>
}
ffffffffc0200ffc:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ffe:	8bcff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201002:	1c1000ef          	jal	ra,ffffffffc02019c2 <swap_init_mm>
ffffffffc0201006:	b5d1                	j	ffffffffc0200eca <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	ec068693          	addi	a3,a3,-320 # ffffffffc0204ec8 <commands+0x7c8>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	e1860613          	addi	a2,a2,-488 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201018:	0dd00593          	li	a1,221
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	e2450513          	addi	a0,a0,-476 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201024:	8deff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	f5868693          	addi	a3,a3,-168 # ffffffffc0204f80 <commands+0x880>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	df860613          	addi	a2,a2,-520 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201038:	0ee00593          	li	a1,238
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	e0450513          	addi	a0,a0,-508 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	f0868693          	addi	a3,a3,-248 # ffffffffc0204f50 <commands+0x850>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	dd860613          	addi	a2,a2,-552 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201058:	0ed00593          	li	a1,237
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	de450513          	addi	a0,a0,-540 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	e4868693          	addi	a3,a3,-440 # ffffffffc0204eb0 <commands+0x7b0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	db860613          	addi	a2,a2,-584 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201078:	0db00593          	li	a1,219
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	dc450513          	addi	a0,a0,-572 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	e7868693          	addi	a3,a3,-392 # ffffffffc0204f00 <commands+0x800>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	d9860613          	addi	a2,a2,-616 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201098:	0e300593          	li	a1,227
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	da450513          	addi	a0,a0,-604 # ffffffffc0204e40 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	e6868693          	addi	a3,a3,-408 # ffffffffc0204f10 <commands+0x810>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	d7860613          	addi	a2,a2,-648 # ffffffffc0204e28 <commands+0x728>
ffffffffc02010b8:	0e500593          	li	a1,229
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	d8450513          	addi	a0,a0,-636 # ffffffffc0204e40 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	e5868693          	addi	a3,a3,-424 # ffffffffc0204f20 <commands+0x820>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	d5860613          	addi	a2,a2,-680 # ffffffffc0204e28 <commands+0x728>
ffffffffc02010d8:	0e700593          	li	a1,231
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	d6450513          	addi	a0,a0,-668 # ffffffffc0204e40 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	e4868693          	addi	a3,a3,-440 # ffffffffc0204f30 <commands+0x830>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	d3860613          	addi	a2,a2,-712 # ffffffffc0204e28 <commands+0x728>
ffffffffc02010f8:	0e900593          	li	a1,233
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	d4450513          	addi	a0,a0,-700 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	e3868693          	addi	a3,a3,-456 # ffffffffc0204f40 <commands+0x840>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	d1860613          	addi	a2,a2,-744 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201118:	0eb00593          	li	a1,235
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	d2450513          	addi	a0,a0,-732 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	f1068693          	addi	a3,a3,-240 # ffffffffc0205038 <commands+0x938>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	cf860613          	addi	a2,a2,-776 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201138:	10d00593          	li	a1,269
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	d0450513          	addi	a0,a0,-764 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	fa868693          	addi	a3,a3,-88 # ffffffffc02050f0 <commands+0x9f0>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	cd860613          	addi	a2,a2,-808 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201158:	10a00593          	li	a1,266
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	ce450513          	addi	a0,a0,-796 # ffffffffc0204e40 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201164:	00010797          	auipc	a5,0x10
ffffffffc0201168:	3a07b623          	sd	zero,940(a5) # ffffffffc0211510 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020116c:	f97fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	f7068693          	addi	a3,a3,-144 # ffffffffc02050e0 <commands+0x9e0>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	cb060613          	addi	a2,a2,-848 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201180:	11100593          	li	a1,273
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	cbc50513          	addi	a0,a0,-836 # ffffffffc0204e40 <commands+0x740>
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	eb868693          	addi	a3,a3,-328 # ffffffffc0205048 <commands+0x948>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	c9060613          	addi	a2,a2,-880 # ffffffffc0204e28 <commands+0x728>
ffffffffc02011a0:	11600593          	li	a1,278
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	c9c50513          	addi	a0,a0,-868 # ffffffffc0204e40 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	eb868693          	addi	a3,a3,-328 # ffffffffc0205068 <commands+0x968>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	c7060613          	addi	a2,a2,-912 # ffffffffc0204e28 <commands+0x728>
ffffffffc02011c0:	12000593          	li	a1,288
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0204e40 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	ea860613          	addi	a2,a2,-344 # ffffffffc0205078 <commands+0x978>
ffffffffc02011d8:	06500593          	li	a1,101
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205098 <commands+0x998>
ffffffffc02011e4:	f1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	e0868693          	addi	a3,a3,-504 # ffffffffc0204ff0 <commands+0x8f0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	c3860613          	addi	a2,a2,-968 # ffffffffc0204e28 <commands+0x728>
ffffffffc02011f8:	12e00593          	li	a1,302
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	c4450513          	addi	a0,a0,-956 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	de868693          	addi	a3,a3,-536 # ffffffffc0204ff0 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	c1860613          	addi	a2,a2,-1000 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201218:	0bd00593          	li	a1,189
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	c2450513          	addi	a0,a0,-988 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	ee068693          	addi	a3,a3,-288 # ffffffffc0205108 <commands+0xa08>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	bf860613          	addi	a2,a2,-1032 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201238:	0c700593          	li	a1,199
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	c0450513          	addi	a0,a0,-1020 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	da868693          	addi	a3,a3,-600 # ffffffffc0204ff0 <commands+0x8f0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	bd860613          	addi	a2,a2,-1064 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201258:	0fb00593          	li	a1,251
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	be450513          	addi	a0,a0,-1052 # ffffffffc0204e40 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201268 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201268:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020126a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020126c:	f822                	sd	s0,48(sp)
ffffffffc020126e:	f426                	sd	s1,40(sp)
ffffffffc0201270:	fc06                	sd	ra,56(sp)
ffffffffc0201272:	f04a                	sd	s2,32(sp)
ffffffffc0201274:	ec4e                	sd	s3,24(sp)
ffffffffc0201276:	8432                	mv	s0,a2
ffffffffc0201278:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020127a:	8d1ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>

    pgfault_num++;
ffffffffc020127e:	00010797          	auipc	a5,0x10
ffffffffc0201282:	29a7a783          	lw	a5,666(a5) # ffffffffc0211518 <pgfault_num>
ffffffffc0201286:	2785                	addiw	a5,a5,1
ffffffffc0201288:	00010717          	auipc	a4,0x10
ffffffffc020128c:	28f72823          	sw	a5,656(a4) # ffffffffc0211518 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201290:	c15d                	beqz	a0,ffffffffc0201336 <do_pgfault+0xce>
ffffffffc0201292:	651c                	ld	a5,8(a0)
ffffffffc0201294:	0af46163          	bltu	s0,a5,ffffffffc0201336 <do_pgfault+0xce>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201298:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020129a:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020129c:	8b89                	andi	a5,a5,2
ffffffffc020129e:	efa9                	bnez	a5,ffffffffc02012f8 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012a0:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012a4:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a6:	85a2                	mv	a1,s0
ffffffffc02012a8:	4605                	li	a2,1
ffffffffc02012aa:	0d9010ef          	jal	ra,ffffffffc0202b82 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012ae:	610c                	ld	a1,0(a0)
ffffffffc02012b0:	c5a5                	beqz	a1,ffffffffc0201318 <do_pgfault+0xb0>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02012b2:	00010797          	auipc	a5,0x10
ffffffffc02012b6:	27e7a783          	lw	a5,638(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02012ba:	c7d9                	beqz	a5,ffffffffc0201348 <do_pgfault+0xe0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02012bc:	0030                	addi	a2,sp,8
ffffffffc02012be:	85a2                	mv	a1,s0
ffffffffc02012c0:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02012c2:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02012c4:	02b000ef          	jal	ra,ffffffffc0201aee <swap_in>
ffffffffc02012c8:	892a                	mv	s2,a0
ffffffffc02012ca:	e90d                	bnez	a0,ffffffffc02012fc <do_pgfault+0x94>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02012cc:	65a2                	ld	a1,8(sp)
ffffffffc02012ce:	6c88                	ld	a0,24(s1)
ffffffffc02012d0:	86ce                	mv	a3,s3
ffffffffc02012d2:	8622                	mv	a2,s0
ffffffffc02012d4:	399010ef          	jal	ra,ffffffffc0202e6c <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc02012d8:	6622                	ld	a2,8(sp)
ffffffffc02012da:	4685                	li	a3,1
ffffffffc02012dc:	85a2                	mv	a1,s0
ffffffffc02012de:	8526                	mv	a0,s1
ffffffffc02012e0:	6ee000ef          	jal	ra,ffffffffc02019ce <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02012e4:	67a2                	ld	a5,8(sp)
ffffffffc02012e6:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc02012e8:	70e2                	ld	ra,56(sp)
ffffffffc02012ea:	7442                	ld	s0,48(sp)
ffffffffc02012ec:	74a2                	ld	s1,40(sp)
ffffffffc02012ee:	69e2                	ld	s3,24(sp)
ffffffffc02012f0:	854a                	mv	a0,s2
ffffffffc02012f2:	7902                	ld	s2,32(sp)
ffffffffc02012f4:	6121                	addi	sp,sp,64
ffffffffc02012f6:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02012f8:	49d9                	li	s3,22
ffffffffc02012fa:	b75d                	j	ffffffffc02012a0 <do_pgfault+0x38>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc02012fc:	00004517          	auipc	a0,0x4
ffffffffc0201300:	e7450513          	addi	a0,a0,-396 # ffffffffc0205170 <commands+0xa70>
ffffffffc0201304:	db7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201308:	70e2                	ld	ra,56(sp)
ffffffffc020130a:	7442                	ld	s0,48(sp)
ffffffffc020130c:	74a2                	ld	s1,40(sp)
ffffffffc020130e:	69e2                	ld	s3,24(sp)
ffffffffc0201310:	854a                	mv	a0,s2
ffffffffc0201312:	7902                	ld	s2,32(sp)
ffffffffc0201314:	6121                	addi	sp,sp,64
ffffffffc0201316:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201318:	6c88                	ld	a0,24(s1)
ffffffffc020131a:	864e                	mv	a2,s3
ffffffffc020131c:	85a2                	mv	a1,s0
ffffffffc020131e:	059020ef          	jal	ra,ffffffffc0203b76 <pgdir_alloc_page>
   ret = 0;
ffffffffc0201322:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201324:	f171                	bnez	a0,ffffffffc02012e8 <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	e2250513          	addi	a0,a0,-478 # ffffffffc0205148 <commands+0xa48>
ffffffffc020132e:	d8dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201332:	5971                	li	s2,-4
            goto failed;
ffffffffc0201334:	bf55                	j	ffffffffc02012e8 <do_pgfault+0x80>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201336:	85a2                	mv	a1,s0
ffffffffc0201338:	00004517          	auipc	a0,0x4
ffffffffc020133c:	de050513          	addi	a0,a0,-544 # ffffffffc0205118 <commands+0xa18>
ffffffffc0201340:	d7bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201344:	5975                	li	s2,-3
        goto failed;
ffffffffc0201346:	b74d                	j	ffffffffc02012e8 <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201348:	00004517          	auipc	a0,0x4
ffffffffc020134c:	e4850513          	addi	a0,a0,-440 # ffffffffc0205190 <commands+0xa90>
ffffffffc0201350:	d6bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201354:	5971                	li	s2,-4
            goto failed;
ffffffffc0201356:	bf49                	j	ffffffffc02012e8 <do_pgfault+0x80>

ffffffffc0201358 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201358:	7135                	addi	sp,sp,-160
ffffffffc020135a:	ed06                	sd	ra,152(sp)
ffffffffc020135c:	e922                	sd	s0,144(sp)
ffffffffc020135e:	e526                	sd	s1,136(sp)
ffffffffc0201360:	e14a                	sd	s2,128(sp)
ffffffffc0201362:	fcce                	sd	s3,120(sp)
ffffffffc0201364:	f8d2                	sd	s4,112(sp)
ffffffffc0201366:	f4d6                	sd	s5,104(sp)
ffffffffc0201368:	f0da                	sd	s6,96(sp)
ffffffffc020136a:	ecde                	sd	s7,88(sp)
ffffffffc020136c:	e8e2                	sd	s8,80(sp)
ffffffffc020136e:	e4e6                	sd	s9,72(sp)
ffffffffc0201370:	e0ea                	sd	s10,64(sp)
ffffffffc0201372:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201374:	25d020ef          	jal	ra,ffffffffc0203dd0 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201378:	00010697          	auipc	a3,0x10
ffffffffc020137c:	1a86b683          	ld	a3,424(a3) # ffffffffc0211520 <max_swap_offset>
ffffffffc0201380:	010007b7          	lui	a5,0x1000
ffffffffc0201384:	ff968713          	addi	a4,a3,-7
ffffffffc0201388:	17e1                	addi	a5,a5,-8
ffffffffc020138a:	3ee7e063          	bltu	a5,a4,ffffffffc020176a <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
ffffffffc020138e:	00009797          	auipc	a5,0x9
ffffffffc0201392:	c7278793          	addi	a5,a5,-910 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201396:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
ffffffffc0201398:	00010b17          	auipc	s6,0x10
ffffffffc020139c:	190b0b13          	addi	s6,s6,400 # ffffffffc0211528 <sm>
ffffffffc02013a0:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02013a4:	9702                	jalr	a4
ffffffffc02013a6:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02013a8:	c10d                	beqz	a0,ffffffffc02013ca <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02013aa:	60ea                	ld	ra,152(sp)
ffffffffc02013ac:	644a                	ld	s0,144(sp)
ffffffffc02013ae:	64aa                	ld	s1,136(sp)
ffffffffc02013b0:	690a                	ld	s2,128(sp)
ffffffffc02013b2:	7a46                	ld	s4,112(sp)
ffffffffc02013b4:	7aa6                	ld	s5,104(sp)
ffffffffc02013b6:	7b06                	ld	s6,96(sp)
ffffffffc02013b8:	6be6                	ld	s7,88(sp)
ffffffffc02013ba:	6c46                	ld	s8,80(sp)
ffffffffc02013bc:	6ca6                	ld	s9,72(sp)
ffffffffc02013be:	6d06                	ld	s10,64(sp)
ffffffffc02013c0:	7de2                	ld	s11,56(sp)
ffffffffc02013c2:	854e                	mv	a0,s3
ffffffffc02013c4:	79e6                	ld	s3,120(sp)
ffffffffc02013c6:	610d                	addi	sp,sp,160
ffffffffc02013c8:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013ca:	000b3783          	ld	a5,0(s6)
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02051e8 <commands+0xae8>
ffffffffc02013d6:	00010497          	auipc	s1,0x10
ffffffffc02013da:	cfa48493          	addi	s1,s1,-774 # ffffffffc02110d0 <free_area>
ffffffffc02013de:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013e0:	4785                	li	a5,1
ffffffffc02013e2:	00010717          	auipc	a4,0x10
ffffffffc02013e6:	14f72723          	sw	a5,334(a4) # ffffffffc0211530 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013ea:	cd1fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013ee:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02013f0:	4401                	li	s0,0
ffffffffc02013f2:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013f4:	2c978163          	beq	a5,s1,ffffffffc02016b6 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013f8:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013fc:	8b09                	andi	a4,a4,2
ffffffffc02013fe:	2a070e63          	beqz	a4,ffffffffc02016ba <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0201402:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201406:	679c                	ld	a5,8(a5)
ffffffffc0201408:	2d05                	addiw	s10,s10,1
ffffffffc020140a:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020140c:	fe9796e3          	bne	a5,s1,ffffffffc02013f8 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201410:	8922                	mv	s2,s0
ffffffffc0201412:	736010ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0201416:	47251663          	bne	a0,s2,ffffffffc0201882 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020141a:	8622                	mv	a2,s0
ffffffffc020141c:	85ea                	mv	a1,s10
ffffffffc020141e:	00004517          	auipc	a0,0x4
ffffffffc0201422:	e1250513          	addi	a0,a0,-494 # ffffffffc0205230 <commands+0xb30>
ffffffffc0201426:	c95fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020142a:	eaaff0ef          	jal	ra,ffffffffc0200ad4 <mm_create>
ffffffffc020142e:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201430:	52050963          	beqz	a0,ffffffffc0201962 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201434:	00010797          	auipc	a5,0x10
ffffffffc0201438:	0dc78793          	addi	a5,a5,220 # ffffffffc0211510 <check_mm_struct>
ffffffffc020143c:	6398                	ld	a4,0(a5)
ffffffffc020143e:	54071263          	bnez	a4,ffffffffc0201982 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201442:	00010b97          	auipc	s7,0x10
ffffffffc0201446:	0febbb83          	ld	s7,254(s7) # ffffffffc0211540 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc020144a:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc020144e:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201450:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201454:	3c071763          	bnez	a4,ffffffffc0201822 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201458:	6599                	lui	a1,0x6
ffffffffc020145a:	460d                	li	a2,3
ffffffffc020145c:	6505                	lui	a0,0x1
ffffffffc020145e:	ebeff0ef          	jal	ra,ffffffffc0200b1c <vma_create>
ffffffffc0201462:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201464:	3c050f63          	beqz	a0,ffffffffc0201842 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201468:	8556                	mv	a0,s5
ffffffffc020146a:	f20ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020146e:	00004517          	auipc	a0,0x4
ffffffffc0201472:	e0250513          	addi	a0,a0,-510 # ffffffffc0205270 <commands+0xb70>
ffffffffc0201476:	c45fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020147a:	018ab503          	ld	a0,24(s5)
ffffffffc020147e:	4605                	li	a2,1
ffffffffc0201480:	6585                	lui	a1,0x1
ffffffffc0201482:	700010ef          	jal	ra,ffffffffc0202b82 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201486:	3c050e63          	beqz	a0,ffffffffc0201862 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020148a:	00004517          	auipc	a0,0x4
ffffffffc020148e:	e3650513          	addi	a0,a0,-458 # ffffffffc02052c0 <commands+0xbc0>
ffffffffc0201492:	00010917          	auipc	s2,0x10
ffffffffc0201496:	bce90913          	addi	s2,s2,-1074 # ffffffffc0211060 <check_rp>
ffffffffc020149a:	c21fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149e:	00010a17          	auipc	s4,0x10
ffffffffc02014a2:	be2a0a13          	addi	s4,s4,-1054 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02014a6:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc02014a8:	4505                	li	a0,1
ffffffffc02014aa:	5cc010ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02014ae:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02014b2:	28050c63          	beqz	a0,ffffffffc020174a <swap_init+0x3f2>
ffffffffc02014b6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02014b8:	8b89                	andi	a5,a5,2
ffffffffc02014ba:	26079863          	bnez	a5,ffffffffc020172a <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014be:	0c21                	addi	s8,s8,8
ffffffffc02014c0:	ff4c14e3          	bne	s8,s4,ffffffffc02014a8 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02014c4:	609c                	ld	a5,0(s1)
ffffffffc02014c6:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02014ca:	e084                	sd	s1,0(s1)
ffffffffc02014cc:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02014ce:	489c                	lw	a5,16(s1)
ffffffffc02014d0:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02014d2:	00010c17          	auipc	s8,0x10
ffffffffc02014d6:	b8ec0c13          	addi	s8,s8,-1138 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02014da:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02014dc:	00010797          	auipc	a5,0x10
ffffffffc02014e0:	c007a223          	sw	zero,-1020(a5) # ffffffffc02110e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02014e4:	000c3503          	ld	a0,0(s8)
ffffffffc02014e8:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014ea:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02014ec:	61c010ef          	jal	ra,ffffffffc0202b08 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014f0:	ff4c1ae3          	bne	s8,s4,ffffffffc02014e4 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014f4:	0104ac03          	lw	s8,16(s1)
ffffffffc02014f8:	4791                	li	a5,4
ffffffffc02014fa:	4afc1463          	bne	s8,a5,ffffffffc02019a2 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014fe:	00004517          	auipc	a0,0x4
ffffffffc0201502:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205348 <commands+0xc48>
ffffffffc0201506:	bb5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020150a:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020150c:	00010797          	auipc	a5,0x10
ffffffffc0201510:	0007a623          	sw	zero,12(a5) # ffffffffc0211518 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201514:	4529                	li	a0,10
ffffffffc0201516:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020151a:	00010597          	auipc	a1,0x10
ffffffffc020151e:	ffe5a583          	lw	a1,-2(a1) # ffffffffc0211518 <pgfault_num>
ffffffffc0201522:	4805                	li	a6,1
ffffffffc0201524:	00010797          	auipc	a5,0x10
ffffffffc0201528:	ff478793          	addi	a5,a5,-12 # ffffffffc0211518 <pgfault_num>
ffffffffc020152c:	3f059b63          	bne	a1,a6,ffffffffc0201922 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201530:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201534:	4390                	lw	a2,0(a5)
ffffffffc0201536:	2601                	sext.w	a2,a2
ffffffffc0201538:	40b61563          	bne	a2,a1,ffffffffc0201942 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020153c:	6589                	lui	a1,0x2
ffffffffc020153e:	452d                	li	a0,11
ffffffffc0201540:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201544:	4390                	lw	a2,0(a5)
ffffffffc0201546:	4809                	li	a6,2
ffffffffc0201548:	2601                	sext.w	a2,a2
ffffffffc020154a:	35061c63          	bne	a2,a6,ffffffffc02018a2 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020154e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201552:	438c                	lw	a1,0(a5)
ffffffffc0201554:	2581                	sext.w	a1,a1
ffffffffc0201556:	36c59663          	bne	a1,a2,ffffffffc02018c2 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020155a:	658d                	lui	a1,0x3
ffffffffc020155c:	4531                	li	a0,12
ffffffffc020155e:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201562:	4390                	lw	a2,0(a5)
ffffffffc0201564:	480d                	li	a6,3
ffffffffc0201566:	2601                	sext.w	a2,a2
ffffffffc0201568:	37061d63          	bne	a2,a6,ffffffffc02018e2 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020156c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0201570:	438c                	lw	a1,0(a5)
ffffffffc0201572:	2581                	sext.w	a1,a1
ffffffffc0201574:	38c59763          	bne	a1,a2,ffffffffc0201902 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201578:	6591                	lui	a1,0x4
ffffffffc020157a:	4535                	li	a0,13
ffffffffc020157c:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201580:	4390                	lw	a2,0(a5)
ffffffffc0201582:	2601                	sext.w	a2,a2
ffffffffc0201584:	21861f63          	bne	a2,s8,ffffffffc02017a2 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201588:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020158c:	439c                	lw	a5,0(a5)
ffffffffc020158e:	2781                	sext.w	a5,a5
ffffffffc0201590:	22c79963          	bne	a5,a2,ffffffffc02017c2 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201594:	489c                	lw	a5,16(s1)
ffffffffc0201596:	24079663          	bnez	a5,ffffffffc02017e2 <swap_init+0x48a>
ffffffffc020159a:	00010797          	auipc	a5,0x10
ffffffffc020159e:	ae678793          	addi	a5,a5,-1306 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc02015a2:	00010617          	auipc	a2,0x10
ffffffffc02015a6:	b0660613          	addi	a2,a2,-1274 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc02015aa:	00010517          	auipc	a0,0x10
ffffffffc02015ae:	afe50513          	addi	a0,a0,-1282 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02015b2:	55fd                	li	a1,-1
ffffffffc02015b4:	c38c                	sw	a1,0(a5)
ffffffffc02015b6:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02015b8:	0791                	addi	a5,a5,4
ffffffffc02015ba:	0611                	addi	a2,a2,4
ffffffffc02015bc:	fef51ce3          	bne	a0,a5,ffffffffc02015b4 <swap_init+0x25c>
ffffffffc02015c0:	00010817          	auipc	a6,0x10
ffffffffc02015c4:	a8080813          	addi	a6,a6,-1408 # ffffffffc0211040 <check_ptep>
ffffffffc02015c8:	00010897          	auipc	a7,0x10
ffffffffc02015cc:	a9888893          	addi	a7,a7,-1384 # ffffffffc0211060 <check_rp>
ffffffffc02015d0:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02015d2:	00010c97          	auipc	s9,0x10
ffffffffc02015d6:	f7ec8c93          	addi	s9,s9,-130 # ffffffffc0211550 <pages>
ffffffffc02015da:	00005c17          	auipc	s8,0x5
ffffffffc02015de:	dbec0c13          	addi	s8,s8,-578 # ffffffffc0206398 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02015e2:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015e6:	4601                	li	a2,0
ffffffffc02015e8:	855e                	mv	a0,s7
ffffffffc02015ea:	ec46                	sd	a7,24(sp)
ffffffffc02015ec:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02015ee:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015f0:	592010ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc02015f4:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015f6:	65c2                	ld	a1,16(sp)
ffffffffc02015f8:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015fa:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015fe:	00010317          	auipc	t1,0x10
ffffffffc0201602:	f4a30313          	addi	t1,t1,-182 # ffffffffc0211548 <npage>
ffffffffc0201606:	16050e63          	beqz	a0,ffffffffc0201782 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020160a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020160c:	0017f613          	andi	a2,a5,1
ffffffffc0201610:	0e060563          	beqz	a2,ffffffffc02016fa <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0201614:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201618:	078a                	slli	a5,a5,0x2
ffffffffc020161a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020161c:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201712 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201620:	000c3603          	ld	a2,0(s8)
ffffffffc0201624:	000cb503          	ld	a0,0(s9)
ffffffffc0201628:	0008bf03          	ld	t5,0(a7)
ffffffffc020162c:	8f91                	sub	a5,a5,a2
ffffffffc020162e:	00379613          	slli	a2,a5,0x3
ffffffffc0201632:	97b2                	add	a5,a5,a2
ffffffffc0201634:	078e                	slli	a5,a5,0x3
ffffffffc0201636:	97aa                	add	a5,a5,a0
ffffffffc0201638:	0aff1163          	bne	t5,a5,ffffffffc02016da <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020163c:	6785                	lui	a5,0x1
ffffffffc020163e:	95be                	add	a1,a1,a5
ffffffffc0201640:	6795                	lui	a5,0x5
ffffffffc0201642:	0821                	addi	a6,a6,8
ffffffffc0201644:	08a1                	addi	a7,a7,8
ffffffffc0201646:	f8f59ee3          	bne	a1,a5,ffffffffc02015e2 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020164a:	00004517          	auipc	a0,0x4
ffffffffc020164e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205428 <commands+0xd28>
ffffffffc0201652:	a69fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201656:	000b3783          	ld	a5,0(s6)
ffffffffc020165a:	7f9c                	ld	a5,56(a5)
ffffffffc020165c:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020165e:	1a051263          	bnez	a0,ffffffffc0201802 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201662:	00093503          	ld	a0,0(s2)
ffffffffc0201666:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201668:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc020166a:	49e010ef          	jal	ra,ffffffffc0202b08 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020166e:	ff491ae3          	bne	s2,s4,ffffffffc0201662 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201672:	8556                	mv	a0,s5
ffffffffc0201674:	de6ff0ef          	jal	ra,ffffffffc0200c5a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201678:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc020167a:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc020167e:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0201680:	7782                	ld	a5,32(sp)
ffffffffc0201682:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201684:	009d8a63          	beq	s11,s1,ffffffffc0201698 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201688:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc020168c:	008dbd83          	ld	s11,8(s11)
ffffffffc0201690:	3d7d                	addiw	s10,s10,-1
ffffffffc0201692:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201694:	fe9d9ae3          	bne	s11,s1,ffffffffc0201688 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201698:	8622                	mv	a2,s0
ffffffffc020169a:	85ea                	mv	a1,s10
ffffffffc020169c:	00004517          	auipc	a0,0x4
ffffffffc02016a0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205458 <commands+0xd58>
ffffffffc02016a4:	a17fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	dd050513          	addi	a0,a0,-560 # ffffffffc0205478 <commands+0xd78>
ffffffffc02016b0:	a0bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02016b4:	b9dd                	j	ffffffffc02013aa <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02016b6:	4901                	li	s2,0
ffffffffc02016b8:	bba9                	j	ffffffffc0201412 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc02016ba:	00004697          	auipc	a3,0x4
ffffffffc02016be:	b4668693          	addi	a3,a3,-1210 # ffffffffc0205200 <commands+0xb00>
ffffffffc02016c2:	00003617          	auipc	a2,0x3
ffffffffc02016c6:	76660613          	addi	a2,a2,1894 # ffffffffc0204e28 <commands+0x728>
ffffffffc02016ca:	0ba00593          	li	a1,186
ffffffffc02016ce:	00004517          	auipc	a0,0x4
ffffffffc02016d2:	b0a50513          	addi	a0,a0,-1270 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02016d6:	a2dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016da:	00004697          	auipc	a3,0x4
ffffffffc02016de:	d2668693          	addi	a3,a3,-730 # ffffffffc0205400 <commands+0xd00>
ffffffffc02016e2:	00003617          	auipc	a2,0x3
ffffffffc02016e6:	74660613          	addi	a2,a2,1862 # ffffffffc0204e28 <commands+0x728>
ffffffffc02016ea:	0fa00593          	li	a1,250
ffffffffc02016ee:	00004517          	auipc	a0,0x4
ffffffffc02016f2:	aea50513          	addi	a0,a0,-1302 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02016f6:	a0dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016fa:	00004617          	auipc	a2,0x4
ffffffffc02016fe:	cde60613          	addi	a2,a2,-802 # ffffffffc02053d8 <commands+0xcd8>
ffffffffc0201702:	07000593          	li	a1,112
ffffffffc0201706:	00004517          	auipc	a0,0x4
ffffffffc020170a:	99250513          	addi	a0,a0,-1646 # ffffffffc0205098 <commands+0x998>
ffffffffc020170e:	9f5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201712:	00004617          	auipc	a2,0x4
ffffffffc0201716:	96660613          	addi	a2,a2,-1690 # ffffffffc0205078 <commands+0x978>
ffffffffc020171a:	06500593          	li	a1,101
ffffffffc020171e:	00004517          	auipc	a0,0x4
ffffffffc0201722:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205098 <commands+0x998>
ffffffffc0201726:	9ddfe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020172a:	00004697          	auipc	a3,0x4
ffffffffc020172e:	bd668693          	addi	a3,a3,-1066 # ffffffffc0205300 <commands+0xc00>
ffffffffc0201732:	00003617          	auipc	a2,0x3
ffffffffc0201736:	6f660613          	addi	a2,a2,1782 # ffffffffc0204e28 <commands+0x728>
ffffffffc020173a:	0db00593          	li	a1,219
ffffffffc020173e:	00004517          	auipc	a0,0x4
ffffffffc0201742:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02051d8 <commands+0xad8>
ffffffffc0201746:	9bdfe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020174a:	00004697          	auipc	a3,0x4
ffffffffc020174e:	b9e68693          	addi	a3,a3,-1122 # ffffffffc02052e8 <commands+0xbe8>
ffffffffc0201752:	00003617          	auipc	a2,0x3
ffffffffc0201756:	6d660613          	addi	a2,a2,1750 # ffffffffc0204e28 <commands+0x728>
ffffffffc020175a:	0da00593          	li	a1,218
ffffffffc020175e:	00004517          	auipc	a0,0x4
ffffffffc0201762:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02051d8 <commands+0xad8>
ffffffffc0201766:	99dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020176a:	00004617          	auipc	a2,0x4
ffffffffc020176e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc02051b8 <commands+0xab8>
ffffffffc0201772:	02700593          	li	a1,39
ffffffffc0201776:	00004517          	auipc	a0,0x4
ffffffffc020177a:	a6250513          	addi	a0,a0,-1438 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020177e:	985fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201782:	00004697          	auipc	a3,0x4
ffffffffc0201786:	c3e68693          	addi	a3,a3,-962 # ffffffffc02053c0 <commands+0xcc0>
ffffffffc020178a:	00003617          	auipc	a2,0x3
ffffffffc020178e:	69e60613          	addi	a2,a2,1694 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201792:	0f900593          	li	a1,249
ffffffffc0201796:	00004517          	auipc	a0,0x4
ffffffffc020179a:	a4250513          	addi	a0,a0,-1470 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020179e:	965fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a2:	00004697          	auipc	a3,0x4
ffffffffc02017a6:	bfe68693          	addi	a3,a3,-1026 # ffffffffc02053a0 <commands+0xca0>
ffffffffc02017aa:	00003617          	auipc	a2,0x3
ffffffffc02017ae:	67e60613          	addi	a2,a2,1662 # ffffffffc0204e28 <commands+0x728>
ffffffffc02017b2:	09d00593          	li	a1,157
ffffffffc02017b6:	00004517          	auipc	a0,0x4
ffffffffc02017ba:	a2250513          	addi	a0,a0,-1502 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02017be:	945fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017c2:	00004697          	auipc	a3,0x4
ffffffffc02017c6:	bde68693          	addi	a3,a3,-1058 # ffffffffc02053a0 <commands+0xca0>
ffffffffc02017ca:	00003617          	auipc	a2,0x3
ffffffffc02017ce:	65e60613          	addi	a2,a2,1630 # ffffffffc0204e28 <commands+0x728>
ffffffffc02017d2:	09f00593          	li	a1,159
ffffffffc02017d6:	00004517          	auipc	a0,0x4
ffffffffc02017da:	a0250513          	addi	a0,a0,-1534 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02017de:	925fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017e2:	00004697          	auipc	a3,0x4
ffffffffc02017e6:	bce68693          	addi	a3,a3,-1074 # ffffffffc02053b0 <commands+0xcb0>
ffffffffc02017ea:	00003617          	auipc	a2,0x3
ffffffffc02017ee:	63e60613          	addi	a2,a2,1598 # ffffffffc0204e28 <commands+0x728>
ffffffffc02017f2:	0f100593          	li	a1,241
ffffffffc02017f6:	00004517          	auipc	a0,0x4
ffffffffc02017fa:	9e250513          	addi	a0,a0,-1566 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02017fe:	905fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201802:	00004697          	auipc	a3,0x4
ffffffffc0201806:	c4e68693          	addi	a3,a3,-946 # ffffffffc0205450 <commands+0xd50>
ffffffffc020180a:	00003617          	auipc	a2,0x3
ffffffffc020180e:	61e60613          	addi	a2,a2,1566 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201812:	10000593          	li	a1,256
ffffffffc0201816:	00004517          	auipc	a0,0x4
ffffffffc020181a:	9c250513          	addi	a0,a0,-1598 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020181e:	8e5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201822:	00004697          	auipc	a3,0x4
ffffffffc0201826:	81668693          	addi	a3,a3,-2026 # ffffffffc0205038 <commands+0x938>
ffffffffc020182a:	00003617          	auipc	a2,0x3
ffffffffc020182e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201832:	0ca00593          	li	a1,202
ffffffffc0201836:	00004517          	auipc	a0,0x4
ffffffffc020183a:	9a250513          	addi	a0,a0,-1630 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020183e:	8c5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201842:	00004697          	auipc	a3,0x4
ffffffffc0201846:	89e68693          	addi	a3,a3,-1890 # ffffffffc02050e0 <commands+0x9e0>
ffffffffc020184a:	00003617          	auipc	a2,0x3
ffffffffc020184e:	5de60613          	addi	a2,a2,1502 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201852:	0cd00593          	li	a1,205
ffffffffc0201856:	00004517          	auipc	a0,0x4
ffffffffc020185a:	98250513          	addi	a0,a0,-1662 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020185e:	8a5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201862:	00004697          	auipc	a3,0x4
ffffffffc0201866:	a4668693          	addi	a3,a3,-1466 # ffffffffc02052a8 <commands+0xba8>
ffffffffc020186a:	00003617          	auipc	a2,0x3
ffffffffc020186e:	5be60613          	addi	a2,a2,1470 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201872:	0d500593          	li	a1,213
ffffffffc0201876:	00004517          	auipc	a0,0x4
ffffffffc020187a:	96250513          	addi	a0,a0,-1694 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020187e:	885fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201882:	00004697          	auipc	a3,0x4
ffffffffc0201886:	98e68693          	addi	a3,a3,-1650 # ffffffffc0205210 <commands+0xb10>
ffffffffc020188a:	00003617          	auipc	a2,0x3
ffffffffc020188e:	59e60613          	addi	a2,a2,1438 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201892:	0bd00593          	li	a1,189
ffffffffc0201896:	00004517          	auipc	a0,0x4
ffffffffc020189a:	94250513          	addi	a0,a0,-1726 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020189e:	865fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a2:	00004697          	auipc	a3,0x4
ffffffffc02018a6:	ade68693          	addi	a3,a3,-1314 # ffffffffc0205380 <commands+0xc80>
ffffffffc02018aa:	00003617          	auipc	a2,0x3
ffffffffc02018ae:	57e60613          	addi	a2,a2,1406 # ffffffffc0204e28 <commands+0x728>
ffffffffc02018b2:	09500593          	li	a1,149
ffffffffc02018b6:	00004517          	auipc	a0,0x4
ffffffffc02018ba:	92250513          	addi	a0,a0,-1758 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02018be:	845fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018c2:	00004697          	auipc	a3,0x4
ffffffffc02018c6:	abe68693          	addi	a3,a3,-1346 # ffffffffc0205380 <commands+0xc80>
ffffffffc02018ca:	00003617          	auipc	a2,0x3
ffffffffc02018ce:	55e60613          	addi	a2,a2,1374 # ffffffffc0204e28 <commands+0x728>
ffffffffc02018d2:	09700593          	li	a1,151
ffffffffc02018d6:	00004517          	auipc	a0,0x4
ffffffffc02018da:	90250513          	addi	a0,a0,-1790 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02018de:	825fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e2:	00004697          	auipc	a3,0x4
ffffffffc02018e6:	aae68693          	addi	a3,a3,-1362 # ffffffffc0205390 <commands+0xc90>
ffffffffc02018ea:	00003617          	auipc	a2,0x3
ffffffffc02018ee:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e28 <commands+0x728>
ffffffffc02018f2:	09900593          	li	a1,153
ffffffffc02018f6:	00004517          	auipc	a0,0x4
ffffffffc02018fa:	8e250513          	addi	a0,a0,-1822 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02018fe:	805fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201902:	00004697          	auipc	a3,0x4
ffffffffc0201906:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0205390 <commands+0xc90>
ffffffffc020190a:	00003617          	auipc	a2,0x3
ffffffffc020190e:	51e60613          	addi	a2,a2,1310 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201912:	09b00593          	li	a1,155
ffffffffc0201916:	00004517          	auipc	a0,0x4
ffffffffc020191a:	8c250513          	addi	a0,a0,-1854 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020191e:	fe4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201922:	00004697          	auipc	a3,0x4
ffffffffc0201926:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0205370 <commands+0xc70>
ffffffffc020192a:	00003617          	auipc	a2,0x3
ffffffffc020192e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201932:	09100593          	li	a1,145
ffffffffc0201936:	00004517          	auipc	a0,0x4
ffffffffc020193a:	8a250513          	addi	a0,a0,-1886 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020193e:	fc4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201942:	00004697          	auipc	a3,0x4
ffffffffc0201946:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0205370 <commands+0xc70>
ffffffffc020194a:	00003617          	auipc	a2,0x3
ffffffffc020194e:	4de60613          	addi	a2,a2,1246 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201952:	09300593          	li	a1,147
ffffffffc0201956:	00004517          	auipc	a0,0x4
ffffffffc020195a:	88250513          	addi	a0,a0,-1918 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020195e:	fa4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201962:	00003697          	auipc	a3,0x3
ffffffffc0201966:	7a668693          	addi	a3,a3,1958 # ffffffffc0205108 <commands+0xa08>
ffffffffc020196a:	00003617          	auipc	a2,0x3
ffffffffc020196e:	4be60613          	addi	a2,a2,1214 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201972:	0c200593          	li	a1,194
ffffffffc0201976:	00004517          	auipc	a0,0x4
ffffffffc020197a:	86250513          	addi	a0,a0,-1950 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020197e:	f84fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201982:	00004697          	auipc	a3,0x4
ffffffffc0201986:	8d668693          	addi	a3,a3,-1834 # ffffffffc0205258 <commands+0xb58>
ffffffffc020198a:	00003617          	auipc	a2,0x3
ffffffffc020198e:	49e60613          	addi	a2,a2,1182 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201992:	0c500593          	li	a1,197
ffffffffc0201996:	00004517          	auipc	a0,0x4
ffffffffc020199a:	84250513          	addi	a0,a0,-1982 # ffffffffc02051d8 <commands+0xad8>
ffffffffc020199e:	f64fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019a2:	00004697          	auipc	a3,0x4
ffffffffc02019a6:	97e68693          	addi	a3,a3,-1666 # ffffffffc0205320 <commands+0xc20>
ffffffffc02019aa:	00003617          	auipc	a2,0x3
ffffffffc02019ae:	47e60613          	addi	a2,a2,1150 # ffffffffc0204e28 <commands+0x728>
ffffffffc02019b2:	0e800593          	li	a1,232
ffffffffc02019b6:	00004517          	auipc	a0,0x4
ffffffffc02019ba:	82250513          	addi	a0,a0,-2014 # ffffffffc02051d8 <commands+0xad8>
ffffffffc02019be:	f44fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019c2 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019c2:	00010797          	auipc	a5,0x10
ffffffffc02019c6:	b667b783          	ld	a5,-1178(a5) # ffffffffc0211528 <sm>
ffffffffc02019ca:	6b9c                	ld	a5,16(a5)
ffffffffc02019cc:	8782                	jr	a5

ffffffffc02019ce <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019ce:	00010797          	auipc	a5,0x10
ffffffffc02019d2:	b5a7b783          	ld	a5,-1190(a5) # ffffffffc0211528 <sm>
ffffffffc02019d6:	739c                	ld	a5,32(a5)
ffffffffc02019d8:	8782                	jr	a5

ffffffffc02019da <swap_out>:
{
ffffffffc02019da:	711d                	addi	sp,sp,-96
ffffffffc02019dc:	ec86                	sd	ra,88(sp)
ffffffffc02019de:	e8a2                	sd	s0,80(sp)
ffffffffc02019e0:	e4a6                	sd	s1,72(sp)
ffffffffc02019e2:	e0ca                	sd	s2,64(sp)
ffffffffc02019e4:	fc4e                	sd	s3,56(sp)
ffffffffc02019e6:	f852                	sd	s4,48(sp)
ffffffffc02019e8:	f456                	sd	s5,40(sp)
ffffffffc02019ea:	f05a                	sd	s6,32(sp)
ffffffffc02019ec:	ec5e                	sd	s7,24(sp)
ffffffffc02019ee:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019f0:	cde9                	beqz	a1,ffffffffc0201aca <swap_out+0xf0>
ffffffffc02019f2:	8a2e                	mv	s4,a1
ffffffffc02019f4:	892a                	mv	s2,a0
ffffffffc02019f6:	8ab2                	mv	s5,a2
ffffffffc02019f8:	4401                	li	s0,0
ffffffffc02019fa:	00010997          	auipc	s3,0x10
ffffffffc02019fe:	b2e98993          	addi	s3,s3,-1234 # ffffffffc0211528 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a02:	00004b17          	auipc	s6,0x4
ffffffffc0201a06:	af6b0b13          	addi	s6,s6,-1290 # ffffffffc02054f8 <commands+0xdf8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a0a:	00004b97          	auipc	s7,0x4
ffffffffc0201a0e:	ad6b8b93          	addi	s7,s7,-1322 # ffffffffc02054e0 <commands+0xde0>
ffffffffc0201a12:	a825                	j	ffffffffc0201a4a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a14:	67a2                	ld	a5,8(sp)
ffffffffc0201a16:	8626                	mv	a2,s1
ffffffffc0201a18:	85a2                	mv	a1,s0
ffffffffc0201a1a:	63b4                	ld	a3,64(a5)
ffffffffc0201a1c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201a1e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a20:	82b1                	srli	a3,a3,0xc
ffffffffc0201a22:	0685                	addi	a3,a3,1
ffffffffc0201a24:	e96fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a28:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201a2a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a2c:	613c                	ld	a5,64(a0)
ffffffffc0201a2e:	83b1                	srli	a5,a5,0xc
ffffffffc0201a30:	0785                	addi	a5,a5,1
ffffffffc0201a32:	07a2                	slli	a5,a5,0x8
ffffffffc0201a34:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201a38:	0d0010ef          	jal	ra,ffffffffc0202b08 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a3c:	01893503          	ld	a0,24(s2)
ffffffffc0201a40:	85a6                	mv	a1,s1
ffffffffc0201a42:	12e020ef          	jal	ra,ffffffffc0203b70 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a46:	048a0d63          	beq	s4,s0,ffffffffc0201aa0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a4a:	0009b783          	ld	a5,0(s3)
ffffffffc0201a4e:	8656                	mv	a2,s5
ffffffffc0201a50:	002c                	addi	a1,sp,8
ffffffffc0201a52:	7b9c                	ld	a5,48(a5)
ffffffffc0201a54:	854a                	mv	a0,s2
ffffffffc0201a56:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a58:	e12d                	bnez	a0,ffffffffc0201aba <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a5a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a5c:	01893503          	ld	a0,24(s2)
ffffffffc0201a60:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a62:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a64:	85a6                	mv	a1,s1
ffffffffc0201a66:	11c010ef          	jal	ra,ffffffffc0202b82 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a6a:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a6c:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a6e:	8b85                	andi	a5,a5,1
ffffffffc0201a70:	cfb9                	beqz	a5,ffffffffc0201ace <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a72:	65a2                	ld	a1,8(sp)
ffffffffc0201a74:	61bc                	ld	a5,64(a1)
ffffffffc0201a76:	83b1                	srli	a5,a5,0xc
ffffffffc0201a78:	0785                	addi	a5,a5,1
ffffffffc0201a7a:	00879513          	slli	a0,a5,0x8
ffffffffc0201a7e:	424020ef          	jal	ra,ffffffffc0203ea2 <swapfs_write>
ffffffffc0201a82:	d949                	beqz	a0,ffffffffc0201a14 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a84:	855e                	mv	a0,s7
ffffffffc0201a86:	e34fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a8a:	0009b783          	ld	a5,0(s3)
ffffffffc0201a8e:	6622                	ld	a2,8(sp)
ffffffffc0201a90:	4681                	li	a3,0
ffffffffc0201a92:	739c                	ld	a5,32(a5)
ffffffffc0201a94:	85a6                	mv	a1,s1
ffffffffc0201a96:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a98:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a9a:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a9c:	fa8a17e3          	bne	s4,s0,ffffffffc0201a4a <swap_out+0x70>
}
ffffffffc0201aa0:	60e6                	ld	ra,88(sp)
ffffffffc0201aa2:	8522                	mv	a0,s0
ffffffffc0201aa4:	6446                	ld	s0,80(sp)
ffffffffc0201aa6:	64a6                	ld	s1,72(sp)
ffffffffc0201aa8:	6906                	ld	s2,64(sp)
ffffffffc0201aaa:	79e2                	ld	s3,56(sp)
ffffffffc0201aac:	7a42                	ld	s4,48(sp)
ffffffffc0201aae:	7aa2                	ld	s5,40(sp)
ffffffffc0201ab0:	7b02                	ld	s6,32(sp)
ffffffffc0201ab2:	6be2                	ld	s7,24(sp)
ffffffffc0201ab4:	6c42                	ld	s8,16(sp)
ffffffffc0201ab6:	6125                	addi	sp,sp,96
ffffffffc0201ab8:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201aba:	85a2                	mv	a1,s0
ffffffffc0201abc:	00004517          	auipc	a0,0x4
ffffffffc0201ac0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0205498 <commands+0xd98>
ffffffffc0201ac4:	df6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201ac8:	bfe1                	j	ffffffffc0201aa0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201aca:	4401                	li	s0,0
ffffffffc0201acc:	bfd1                	j	ffffffffc0201aa0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201ace:	00004697          	auipc	a3,0x4
ffffffffc0201ad2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02054c8 <commands+0xdc8>
ffffffffc0201ad6:	00003617          	auipc	a2,0x3
ffffffffc0201ada:	35260613          	addi	a2,a2,850 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201ade:	06600593          	li	a1,102
ffffffffc0201ae2:	00003517          	auipc	a0,0x3
ffffffffc0201ae6:	6f650513          	addi	a0,a0,1782 # ffffffffc02051d8 <commands+0xad8>
ffffffffc0201aea:	e18fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201aee <swap_in>:
{
ffffffffc0201aee:	7179                	addi	sp,sp,-48
ffffffffc0201af0:	e84a                	sd	s2,16(sp)
ffffffffc0201af2:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201af4:	4505                	li	a0,1
{
ffffffffc0201af6:	ec26                	sd	s1,24(sp)
ffffffffc0201af8:	e44e                	sd	s3,8(sp)
ffffffffc0201afa:	f406                	sd	ra,40(sp)
ffffffffc0201afc:	f022                	sd	s0,32(sp)
ffffffffc0201afe:	84ae                	mv	s1,a1
ffffffffc0201b00:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201b02:	775000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201b06:	c129                	beqz	a0,ffffffffc0201b48 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201b08:	842a                	mv	s0,a0
ffffffffc0201b0a:	01893503          	ld	a0,24(s2)
ffffffffc0201b0e:	4601                	li	a2,0
ffffffffc0201b10:	85a6                	mv	a1,s1
ffffffffc0201b12:	070010ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc0201b16:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201b18:	6108                	ld	a0,0(a0)
ffffffffc0201b1a:	85a2                	mv	a1,s0
ffffffffc0201b1c:	2ec020ef          	jal	ra,ffffffffc0203e08 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201b20:	00093583          	ld	a1,0(s2)
ffffffffc0201b24:	8626                	mv	a2,s1
ffffffffc0201b26:	00004517          	auipc	a0,0x4
ffffffffc0201b2a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0205548 <commands+0xe48>
ffffffffc0201b2e:	81a1                	srli	a1,a1,0x8
ffffffffc0201b30:	d8afe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b34:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201b36:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b3a:	7402                	ld	s0,32(sp)
ffffffffc0201b3c:	64e2                	ld	s1,24(sp)
ffffffffc0201b3e:	6942                	ld	s2,16(sp)
ffffffffc0201b40:	69a2                	ld	s3,8(sp)
ffffffffc0201b42:	4501                	li	a0,0
ffffffffc0201b44:	6145                	addi	sp,sp,48
ffffffffc0201b46:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b48:	00004697          	auipc	a3,0x4
ffffffffc0201b4c:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205538 <commands+0xe38>
ffffffffc0201b50:	00003617          	auipc	a2,0x3
ffffffffc0201b54:	2d860613          	addi	a2,a2,728 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201b58:	07c00593          	li	a1,124
ffffffffc0201b5c:	00003517          	auipc	a0,0x3
ffffffffc0201b60:	67c50513          	addi	a0,a0,1660 # ffffffffc02051d8 <commands+0xad8>
ffffffffc0201b64:	d9efe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b68 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201b68:	0000f797          	auipc	a5,0xf
ffffffffc0201b6c:	58078793          	addi	a5,a5,1408 # ffffffffc02110e8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201b70:	f51c                	sd	a5,40(a0)
ffffffffc0201b72:	e79c                	sd	a5,8(a5)
ffffffffc0201b74:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201b76:	4501                	li	a0,0
ffffffffc0201b78:	8082                	ret

ffffffffc0201b7a <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201b7a:	4501                	li	a0,0
ffffffffc0201b7c:	8082                	ret

ffffffffc0201b7e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201b7e:	4501                	li	a0,0
ffffffffc0201b80:	8082                	ret

ffffffffc0201b82 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201b82:	4501                	li	a0,0
ffffffffc0201b84:	8082                	ret

ffffffffc0201b86 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201b86:	711d                	addi	sp,sp,-96
ffffffffc0201b88:	fc4e                	sd	s3,56(sp)
ffffffffc0201b8a:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b8c:	00004517          	auipc	a0,0x4
ffffffffc0201b90:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205588 <commands+0xe88>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b94:	698d                	lui	s3,0x3
ffffffffc0201b96:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201b98:	e0ca                	sd	s2,64(sp)
ffffffffc0201b9a:	ec86                	sd	ra,88(sp)
ffffffffc0201b9c:	e8a2                	sd	s0,80(sp)
ffffffffc0201b9e:	e4a6                	sd	s1,72(sp)
ffffffffc0201ba0:	f456                	sd	s5,40(sp)
ffffffffc0201ba2:	f05a                	sd	s6,32(sp)
ffffffffc0201ba4:	ec5e                	sd	s7,24(sp)
ffffffffc0201ba6:	e862                	sd	s8,16(sp)
ffffffffc0201ba8:	e466                	sd	s9,8(sp)
ffffffffc0201baa:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201bac:	d0efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201bb0:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201bb4:	00010917          	auipc	s2,0x10
ffffffffc0201bb8:	96492903          	lw	s2,-1692(s2) # ffffffffc0211518 <pgfault_num>
ffffffffc0201bbc:	4791                	li	a5,4
ffffffffc0201bbe:	14f91e63          	bne	s2,a5,ffffffffc0201d1a <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201bc2:	00004517          	auipc	a0,0x4
ffffffffc0201bc6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02055c8 <commands+0xec8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201bca:	6a85                	lui	s5,0x1
ffffffffc0201bcc:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201bce:	cecfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201bd2:	00010417          	auipc	s0,0x10
ffffffffc0201bd6:	94640413          	addi	s0,s0,-1722 # ffffffffc0211518 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201bda:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201bde:	4004                	lw	s1,0(s0)
ffffffffc0201be0:	2481                	sext.w	s1,s1
ffffffffc0201be2:	2b249c63          	bne	s1,s2,ffffffffc0201e9a <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201be6:	00004517          	auipc	a0,0x4
ffffffffc0201bea:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02055f0 <commands+0xef0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201bee:	6b91                	lui	s7,0x4
ffffffffc0201bf0:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201bf2:	cc8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201bf6:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201bfa:	00042903          	lw	s2,0(s0)
ffffffffc0201bfe:	2901                	sext.w	s2,s2
ffffffffc0201c00:	26991d63          	bne	s2,s1,ffffffffc0201e7a <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c04:	00004517          	auipc	a0,0x4
ffffffffc0201c08:	a1450513          	addi	a0,a0,-1516 # ffffffffc0205618 <commands+0xf18>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c0c:	6c89                	lui	s9,0x2
ffffffffc0201c0e:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c10:	caafe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c14:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0201c18:	401c                	lw	a5,0(s0)
ffffffffc0201c1a:	2781                	sext.w	a5,a5
ffffffffc0201c1c:	23279f63          	bne	a5,s2,ffffffffc0201e5a <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201c20:	00004517          	auipc	a0,0x4
ffffffffc0201c24:	a2050513          	addi	a0,a0,-1504 # ffffffffc0205640 <commands+0xf40>
ffffffffc0201c28:	c92fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201c2c:	6795                	lui	a5,0x5
ffffffffc0201c2e:	4739                	li	a4,14
ffffffffc0201c30:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201c34:	4004                	lw	s1,0(s0)
ffffffffc0201c36:	4795                	li	a5,5
ffffffffc0201c38:	2481                	sext.w	s1,s1
ffffffffc0201c3a:	20f49063          	bne	s1,a5,ffffffffc0201e3a <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c3e:	00004517          	auipc	a0,0x4
ffffffffc0201c42:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205618 <commands+0xf18>
ffffffffc0201c46:	c74fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c4a:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201c4e:	401c                	lw	a5,0(s0)
ffffffffc0201c50:	2781                	sext.w	a5,a5
ffffffffc0201c52:	1c979463          	bne	a5,s1,ffffffffc0201e1a <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c56:	00004517          	auipc	a0,0x4
ffffffffc0201c5a:	97250513          	addi	a0,a0,-1678 # ffffffffc02055c8 <commands+0xec8>
ffffffffc0201c5e:	c5cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201c62:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201c66:	401c                	lw	a5,0(s0)
ffffffffc0201c68:	4719                	li	a4,6
ffffffffc0201c6a:	2781                	sext.w	a5,a5
ffffffffc0201c6c:	18e79763          	bne	a5,a4,ffffffffc0201dfa <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c70:	00004517          	auipc	a0,0x4
ffffffffc0201c74:	9a850513          	addi	a0,a0,-1624 # ffffffffc0205618 <commands+0xf18>
ffffffffc0201c78:	c42fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c7c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201c80:	401c                	lw	a5,0(s0)
ffffffffc0201c82:	471d                	li	a4,7
ffffffffc0201c84:	2781                	sext.w	a5,a5
ffffffffc0201c86:	14e79a63          	bne	a5,a4,ffffffffc0201dda <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201c8a:	00004517          	auipc	a0,0x4
ffffffffc0201c8e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205588 <commands+0xe88>
ffffffffc0201c92:	c28fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201c96:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201c9a:	401c                	lw	a5,0(s0)
ffffffffc0201c9c:	4721                	li	a4,8
ffffffffc0201c9e:	2781                	sext.w	a5,a5
ffffffffc0201ca0:	10e79d63          	bne	a5,a4,ffffffffc0201dba <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201ca4:	00004517          	auipc	a0,0x4
ffffffffc0201ca8:	94c50513          	addi	a0,a0,-1716 # ffffffffc02055f0 <commands+0xef0>
ffffffffc0201cac:	c0efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201cb0:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201cb4:	401c                	lw	a5,0(s0)
ffffffffc0201cb6:	4725                	li	a4,9
ffffffffc0201cb8:	2781                	sext.w	a5,a5
ffffffffc0201cba:	0ee79063          	bne	a5,a4,ffffffffc0201d9a <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201cbe:	00004517          	auipc	a0,0x4
ffffffffc0201cc2:	98250513          	addi	a0,a0,-1662 # ffffffffc0205640 <commands+0xf40>
ffffffffc0201cc6:	bf4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201cca:	6795                	lui	a5,0x5
ffffffffc0201ccc:	4739                	li	a4,14
ffffffffc0201cce:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201cd2:	4004                	lw	s1,0(s0)
ffffffffc0201cd4:	47a9                	li	a5,10
ffffffffc0201cd6:	2481                	sext.w	s1,s1
ffffffffc0201cd8:	0af49163          	bne	s1,a5,ffffffffc0201d7a <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201cdc:	00004517          	auipc	a0,0x4
ffffffffc0201ce0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02055c8 <commands+0xec8>
ffffffffc0201ce4:	bd6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201ce8:	6785                	lui	a5,0x1
ffffffffc0201cea:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201cee:	06979663          	bne	a5,s1,ffffffffc0201d5a <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201cf2:	401c                	lw	a5,0(s0)
ffffffffc0201cf4:	472d                	li	a4,11
ffffffffc0201cf6:	2781                	sext.w	a5,a5
ffffffffc0201cf8:	04e79163          	bne	a5,a4,ffffffffc0201d3a <_fifo_check_swap+0x1b4>
}
ffffffffc0201cfc:	60e6                	ld	ra,88(sp)
ffffffffc0201cfe:	6446                	ld	s0,80(sp)
ffffffffc0201d00:	64a6                	ld	s1,72(sp)
ffffffffc0201d02:	6906                	ld	s2,64(sp)
ffffffffc0201d04:	79e2                	ld	s3,56(sp)
ffffffffc0201d06:	7a42                	ld	s4,48(sp)
ffffffffc0201d08:	7aa2                	ld	s5,40(sp)
ffffffffc0201d0a:	7b02                	ld	s6,32(sp)
ffffffffc0201d0c:	6be2                	ld	s7,24(sp)
ffffffffc0201d0e:	6c42                	ld	s8,16(sp)
ffffffffc0201d10:	6ca2                	ld	s9,8(sp)
ffffffffc0201d12:	6d02                	ld	s10,0(sp)
ffffffffc0201d14:	4501                	li	a0,0
ffffffffc0201d16:	6125                	addi	sp,sp,96
ffffffffc0201d18:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201d1a:	00003697          	auipc	a3,0x3
ffffffffc0201d1e:	68668693          	addi	a3,a3,1670 # ffffffffc02053a0 <commands+0xca0>
ffffffffc0201d22:	00003617          	auipc	a2,0x3
ffffffffc0201d26:	10660613          	addi	a2,a2,262 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201d2a:	05400593          	li	a1,84
ffffffffc0201d2e:	00004517          	auipc	a0,0x4
ffffffffc0201d32:	88250513          	addi	a0,a0,-1918 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201d36:	bccfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==11);
ffffffffc0201d3a:	00004697          	auipc	a3,0x4
ffffffffc0201d3e:	9b668693          	addi	a3,a3,-1610 # ffffffffc02056f0 <commands+0xff0>
ffffffffc0201d42:	00003617          	auipc	a2,0x3
ffffffffc0201d46:	0e660613          	addi	a2,a2,230 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201d4a:	07600593          	li	a1,118
ffffffffc0201d4e:	00004517          	auipc	a0,0x4
ffffffffc0201d52:	86250513          	addi	a0,a0,-1950 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201d56:	bacfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201d5a:	00004697          	auipc	a3,0x4
ffffffffc0201d5e:	96e68693          	addi	a3,a3,-1682 # ffffffffc02056c8 <commands+0xfc8>
ffffffffc0201d62:	00003617          	auipc	a2,0x3
ffffffffc0201d66:	0c660613          	addi	a2,a2,198 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201d6a:	07400593          	li	a1,116
ffffffffc0201d6e:	00004517          	auipc	a0,0x4
ffffffffc0201d72:	84250513          	addi	a0,a0,-1982 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201d76:	b8cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==10);
ffffffffc0201d7a:	00004697          	auipc	a3,0x4
ffffffffc0201d7e:	93e68693          	addi	a3,a3,-1730 # ffffffffc02056b8 <commands+0xfb8>
ffffffffc0201d82:	00003617          	auipc	a2,0x3
ffffffffc0201d86:	0a660613          	addi	a2,a2,166 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201d8a:	07200593          	li	a1,114
ffffffffc0201d8e:	00004517          	auipc	a0,0x4
ffffffffc0201d92:	82250513          	addi	a0,a0,-2014 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201d96:	b6cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==9);
ffffffffc0201d9a:	00004697          	auipc	a3,0x4
ffffffffc0201d9e:	90e68693          	addi	a3,a3,-1778 # ffffffffc02056a8 <commands+0xfa8>
ffffffffc0201da2:	00003617          	auipc	a2,0x3
ffffffffc0201da6:	08660613          	addi	a2,a2,134 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201daa:	06f00593          	li	a1,111
ffffffffc0201dae:	00004517          	auipc	a0,0x4
ffffffffc0201db2:	80250513          	addi	a0,a0,-2046 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201db6:	b4cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==8);
ffffffffc0201dba:	00004697          	auipc	a3,0x4
ffffffffc0201dbe:	8de68693          	addi	a3,a3,-1826 # ffffffffc0205698 <commands+0xf98>
ffffffffc0201dc2:	00003617          	auipc	a2,0x3
ffffffffc0201dc6:	06660613          	addi	a2,a2,102 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201dca:	06c00593          	li	a1,108
ffffffffc0201dce:	00003517          	auipc	a0,0x3
ffffffffc0201dd2:	7e250513          	addi	a0,a0,2018 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201dd6:	b2cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==7);
ffffffffc0201dda:	00004697          	auipc	a3,0x4
ffffffffc0201dde:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0205688 <commands+0xf88>
ffffffffc0201de2:	00003617          	auipc	a2,0x3
ffffffffc0201de6:	04660613          	addi	a2,a2,70 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201dea:	06900593          	li	a1,105
ffffffffc0201dee:	00003517          	auipc	a0,0x3
ffffffffc0201df2:	7c250513          	addi	a0,a0,1986 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201df6:	b0cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc0201dfa:	00004697          	auipc	a3,0x4
ffffffffc0201dfe:	87e68693          	addi	a3,a3,-1922 # ffffffffc0205678 <commands+0xf78>
ffffffffc0201e02:	00003617          	auipc	a2,0x3
ffffffffc0201e06:	02660613          	addi	a2,a2,38 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201e0a:	06600593          	li	a1,102
ffffffffc0201e0e:	00003517          	auipc	a0,0x3
ffffffffc0201e12:	7a250513          	addi	a0,a0,1954 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201e16:	aecfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201e1a:	00004697          	auipc	a3,0x4
ffffffffc0201e1e:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205668 <commands+0xf68>
ffffffffc0201e22:	00003617          	auipc	a2,0x3
ffffffffc0201e26:	00660613          	addi	a2,a2,6 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201e2a:	06300593          	li	a1,99
ffffffffc0201e2e:	00003517          	auipc	a0,0x3
ffffffffc0201e32:	78250513          	addi	a0,a0,1922 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201e36:	accfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201e3a:	00004697          	auipc	a3,0x4
ffffffffc0201e3e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0205668 <commands+0xf68>
ffffffffc0201e42:	00003617          	auipc	a2,0x3
ffffffffc0201e46:	fe660613          	addi	a2,a2,-26 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201e4a:	06000593          	li	a1,96
ffffffffc0201e4e:	00003517          	auipc	a0,0x3
ffffffffc0201e52:	76250513          	addi	a0,a0,1890 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201e56:	aacfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e5a:	00003697          	auipc	a3,0x3
ffffffffc0201e5e:	54668693          	addi	a3,a3,1350 # ffffffffc02053a0 <commands+0xca0>
ffffffffc0201e62:	00003617          	auipc	a2,0x3
ffffffffc0201e66:	fc660613          	addi	a2,a2,-58 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201e6a:	05d00593          	li	a1,93
ffffffffc0201e6e:	00003517          	auipc	a0,0x3
ffffffffc0201e72:	74250513          	addi	a0,a0,1858 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201e76:	a8cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e7a:	00003697          	auipc	a3,0x3
ffffffffc0201e7e:	52668693          	addi	a3,a3,1318 # ffffffffc02053a0 <commands+0xca0>
ffffffffc0201e82:	00003617          	auipc	a2,0x3
ffffffffc0201e86:	fa660613          	addi	a2,a2,-90 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201e8a:	05a00593          	li	a1,90
ffffffffc0201e8e:	00003517          	auipc	a0,0x3
ffffffffc0201e92:	72250513          	addi	a0,a0,1826 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201e96:	a6cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e9a:	00003697          	auipc	a3,0x3
ffffffffc0201e9e:	50668693          	addi	a3,a3,1286 # ffffffffc02053a0 <commands+0xca0>
ffffffffc0201ea2:	00003617          	auipc	a2,0x3
ffffffffc0201ea6:	f8660613          	addi	a2,a2,-122 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201eaa:	05700593          	li	a1,87
ffffffffc0201eae:	00003517          	auipc	a0,0x3
ffffffffc0201eb2:	70250513          	addi	a0,a0,1794 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201eb6:	a4cfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201eba <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201eba:	7518                	ld	a4,40(a0)
{
ffffffffc0201ebc:	1141                	addi	sp,sp,-16
ffffffffc0201ebe:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201ec0:	c731                	beqz	a4,ffffffffc0201f0c <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0201ec2:	e60d                	bnez	a2,ffffffffc0201eec <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0201ec4:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0201ec6:	00f70d63          	beq	a4,a5,ffffffffc0201ee0 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201eca:	6394                	ld	a3,0(a5)
ffffffffc0201ecc:	6798                	ld	a4,8(a5)
}
ffffffffc0201ece:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201ed0:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc0201ed4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201ed6:	e314                	sd	a3,0(a4)
ffffffffc0201ed8:	e19c                	sd	a5,0(a1)
}
ffffffffc0201eda:	4501                	li	a0,0
ffffffffc0201edc:	0141                	addi	sp,sp,16
ffffffffc0201ede:	8082                	ret
ffffffffc0201ee0:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0201ee2:	0005b023          	sd	zero,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc0201ee6:	4501                	li	a0,0
ffffffffc0201ee8:	0141                	addi	sp,sp,16
ffffffffc0201eea:	8082                	ret
     assert(in_tick==0);
ffffffffc0201eec:	00004697          	auipc	a3,0x4
ffffffffc0201ef0:	82468693          	addi	a3,a3,-2012 # ffffffffc0205710 <commands+0x1010>
ffffffffc0201ef4:	00003617          	auipc	a2,0x3
ffffffffc0201ef8:	f3460613          	addi	a2,a2,-204 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201efc:	04200593          	li	a1,66
ffffffffc0201f00:	00003517          	auipc	a0,0x3
ffffffffc0201f04:	6b050513          	addi	a0,a0,1712 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201f08:	9fafe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(head != NULL);
ffffffffc0201f0c:	00003697          	auipc	a3,0x3
ffffffffc0201f10:	7f468693          	addi	a3,a3,2036 # ffffffffc0205700 <commands+0x1000>
ffffffffc0201f14:	00003617          	auipc	a2,0x3
ffffffffc0201f18:	f1460613          	addi	a2,a2,-236 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201f1c:	04100593          	li	a1,65
ffffffffc0201f20:	00003517          	auipc	a0,0x3
ffffffffc0201f24:	69050513          	addi	a0,a0,1680 # ffffffffc02055b0 <commands+0xeb0>
ffffffffc0201f28:	9dafe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201f2c <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201f2c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201f2e:	cb91                	beqz	a5,ffffffffc0201f42 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201f30:	6794                	ld	a3,8(a5)
ffffffffc0201f32:	03060713          	addi	a4,a2,48
}
ffffffffc0201f36:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0201f38:	e298                	sd	a4,0(a3)
ffffffffc0201f3a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201f3c:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0201f3e:	fa1c                	sd	a5,48(a2)
ffffffffc0201f40:	8082                	ret
{
ffffffffc0201f42:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201f44:	00003697          	auipc	a3,0x3
ffffffffc0201f48:	7dc68693          	addi	a3,a3,2012 # ffffffffc0205720 <commands+0x1020>
ffffffffc0201f4c:	00003617          	auipc	a2,0x3
ffffffffc0201f50:	edc60613          	addi	a2,a2,-292 # ffffffffc0204e28 <commands+0x728>
ffffffffc0201f54:	03200593          	li	a1,50
ffffffffc0201f58:	00003517          	auipc	a0,0x3
ffffffffc0201f5c:	65850513          	addi	a0,a0,1624 # ffffffffc02055b0 <commands+0xeb0>
{
ffffffffc0201f60:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201f62:	9a0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201f66 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201f66:	0000f797          	auipc	a5,0xf
ffffffffc0201f6a:	16a78793          	addi	a5,a5,362 # ffffffffc02110d0 <free_area>
ffffffffc0201f6e:	e79c                	sd	a5,8(a5)
ffffffffc0201f70:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201f72:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201f76:	8082                	ret

ffffffffc0201f78 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201f78:	0000f517          	auipc	a0,0xf
ffffffffc0201f7c:	16856503          	lwu	a0,360(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0201f80:	8082                	ret

ffffffffc0201f82 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201f82:	715d                	addi	sp,sp,-80
ffffffffc0201f84:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201f86:	0000f417          	auipc	s0,0xf
ffffffffc0201f8a:	14a40413          	addi	s0,s0,330 # ffffffffc02110d0 <free_area>
ffffffffc0201f8e:	641c                	ld	a5,8(s0)
ffffffffc0201f90:	e486                	sd	ra,72(sp)
ffffffffc0201f92:	fc26                	sd	s1,56(sp)
ffffffffc0201f94:	f84a                	sd	s2,48(sp)
ffffffffc0201f96:	f44e                	sd	s3,40(sp)
ffffffffc0201f98:	f052                	sd	s4,32(sp)
ffffffffc0201f9a:	ec56                	sd	s5,24(sp)
ffffffffc0201f9c:	e85a                	sd	s6,16(sp)
ffffffffc0201f9e:	e45e                	sd	s7,8(sp)
ffffffffc0201fa0:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201fa2:	2c878763          	beq	a5,s0,ffffffffc0202270 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201fa6:	4481                	li	s1,0
ffffffffc0201fa8:	4901                	li	s2,0
ffffffffc0201faa:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201fae:	8b09                	andi	a4,a4,2
ffffffffc0201fb0:	2c070463          	beqz	a4,ffffffffc0202278 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201fb4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fb8:	679c                	ld	a5,8(a5)
ffffffffc0201fba:	2905                	addiw	s2,s2,1
ffffffffc0201fbc:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201fbe:	fe8796e3          	bne	a5,s0,ffffffffc0201faa <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201fc2:	89a6                	mv	s3,s1
ffffffffc0201fc4:	385000ef          	jal	ra,ffffffffc0202b48 <nr_free_pages>
ffffffffc0201fc8:	71351863          	bne	a0,s3,ffffffffc02026d8 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201fcc:	4505                	li	a0,1
ffffffffc0201fce:	2a9000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201fd2:	8a2a                	mv	s4,a0
ffffffffc0201fd4:	44050263          	beqz	a0,ffffffffc0202418 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201fd8:	4505                	li	a0,1
ffffffffc0201fda:	29d000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201fde:	89aa                	mv	s3,a0
ffffffffc0201fe0:	70050c63          	beqz	a0,ffffffffc02026f8 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201fe4:	4505                	li	a0,1
ffffffffc0201fe6:	291000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201fea:	8aaa                	mv	s5,a0
ffffffffc0201fec:	4a050663          	beqz	a0,ffffffffc0202498 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201ff0:	2b3a0463          	beq	s4,s3,ffffffffc0202298 <default_check+0x316>
ffffffffc0201ff4:	2aaa0263          	beq	s4,a0,ffffffffc0202298 <default_check+0x316>
ffffffffc0201ff8:	2aa98063          	beq	s3,a0,ffffffffc0202298 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201ffc:	000a2783          	lw	a5,0(s4)
ffffffffc0202000:	2a079c63          	bnez	a5,ffffffffc02022b8 <default_check+0x336>
ffffffffc0202004:	0009a783          	lw	a5,0(s3)
ffffffffc0202008:	2a079863          	bnez	a5,ffffffffc02022b8 <default_check+0x336>
ffffffffc020200c:	411c                	lw	a5,0(a0)
ffffffffc020200e:	2a079563          	bnez	a5,ffffffffc02022b8 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202012:	0000f797          	auipc	a5,0xf
ffffffffc0202016:	53e7b783          	ld	a5,1342(a5) # ffffffffc0211550 <pages>
ffffffffc020201a:	40fa0733          	sub	a4,s4,a5
ffffffffc020201e:	870d                	srai	a4,a4,0x3
ffffffffc0202020:	00004597          	auipc	a1,0x4
ffffffffc0202024:	3705b583          	ld	a1,880(a1) # ffffffffc0206390 <error_string+0x38>
ffffffffc0202028:	02b70733          	mul	a4,a4,a1
ffffffffc020202c:	00004617          	auipc	a2,0x4
ffffffffc0202030:	36c63603          	ld	a2,876(a2) # ffffffffc0206398 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202034:	0000f697          	auipc	a3,0xf
ffffffffc0202038:	5146b683          	ld	a3,1300(a3) # ffffffffc0211548 <npage>
ffffffffc020203c:	06b2                	slli	a3,a3,0xc
ffffffffc020203e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202040:	0732                	slli	a4,a4,0xc
ffffffffc0202042:	28d77b63          	bgeu	a4,a3,ffffffffc02022d8 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202046:	40f98733          	sub	a4,s3,a5
ffffffffc020204a:	870d                	srai	a4,a4,0x3
ffffffffc020204c:	02b70733          	mul	a4,a4,a1
ffffffffc0202050:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202052:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202054:	4cd77263          	bgeu	a4,a3,ffffffffc0202518 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202058:	40f507b3          	sub	a5,a0,a5
ffffffffc020205c:	878d                	srai	a5,a5,0x3
ffffffffc020205e:	02b787b3          	mul	a5,a5,a1
ffffffffc0202062:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202064:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202066:	30d7f963          	bgeu	a5,a3,ffffffffc0202378 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc020206a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020206c:	00043c03          	ld	s8,0(s0)
ffffffffc0202070:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202074:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202078:	e400                	sd	s0,8(s0)
ffffffffc020207a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020207c:	0000f797          	auipc	a5,0xf
ffffffffc0202080:	0607a223          	sw	zero,100(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202084:	1f3000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202088:	2c051863          	bnez	a0,ffffffffc0202358 <default_check+0x3d6>
    free_page(p0);
ffffffffc020208c:	4585                	li	a1,1
ffffffffc020208e:	8552                	mv	a0,s4
ffffffffc0202090:	279000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_page(p1);
ffffffffc0202094:	4585                	li	a1,1
ffffffffc0202096:	854e                	mv	a0,s3
ffffffffc0202098:	271000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_page(p2);
ffffffffc020209c:	4585                	li	a1,1
ffffffffc020209e:	8556                	mv	a0,s5
ffffffffc02020a0:	269000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    assert(nr_free == 3);
ffffffffc02020a4:	4818                	lw	a4,16(s0)
ffffffffc02020a6:	478d                	li	a5,3
ffffffffc02020a8:	28f71863          	bne	a4,a5,ffffffffc0202338 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02020ac:	4505                	li	a0,1
ffffffffc02020ae:	1c9000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020b2:	89aa                	mv	s3,a0
ffffffffc02020b4:	26050263          	beqz	a0,ffffffffc0202318 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02020b8:	4505                	li	a0,1
ffffffffc02020ba:	1bd000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020be:	8aaa                	mv	s5,a0
ffffffffc02020c0:	3a050c63          	beqz	a0,ffffffffc0202478 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020c4:	4505                	li	a0,1
ffffffffc02020c6:	1b1000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020ca:	8a2a                	mv	s4,a0
ffffffffc02020cc:	38050663          	beqz	a0,ffffffffc0202458 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc02020d0:	4505                	li	a0,1
ffffffffc02020d2:	1a5000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020d6:	36051163          	bnez	a0,ffffffffc0202438 <default_check+0x4b6>
    free_page(p0);
ffffffffc02020da:	4585                	li	a1,1
ffffffffc02020dc:	854e                	mv	a0,s3
ffffffffc02020de:	22b000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02020e2:	641c                	ld	a5,8(s0)
ffffffffc02020e4:	20878a63          	beq	a5,s0,ffffffffc02022f8 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc02020e8:	4505                	li	a0,1
ffffffffc02020ea:	18d000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020ee:	30a99563          	bne	s3,a0,ffffffffc02023f8 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc02020f2:	4505                	li	a0,1
ffffffffc02020f4:	183000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02020f8:	2e051063          	bnez	a0,ffffffffc02023d8 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc02020fc:	481c                	lw	a5,16(s0)
ffffffffc02020fe:	2a079d63          	bnez	a5,ffffffffc02023b8 <default_check+0x436>
    free_page(p);
ffffffffc0202102:	854e                	mv	a0,s3
ffffffffc0202104:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202106:	01843023          	sd	s8,0(s0)
ffffffffc020210a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020210e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202112:	1f7000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_page(p1);
ffffffffc0202116:	4585                	li	a1,1
ffffffffc0202118:	8556                	mv	a0,s5
ffffffffc020211a:	1ef000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_page(p2);
ffffffffc020211e:	4585                	li	a1,1
ffffffffc0202120:	8552                	mv	a0,s4
ffffffffc0202122:	1e7000ef          	jal	ra,ffffffffc0202b08 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202126:	4515                	li	a0,5
ffffffffc0202128:	14f000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020212c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020212e:	26050563          	beqz	a0,ffffffffc0202398 <default_check+0x416>
ffffffffc0202132:	651c                	ld	a5,8(a0)
ffffffffc0202134:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202136:	8b85                	andi	a5,a5,1
ffffffffc0202138:	54079063          	bnez	a5,ffffffffc0202678 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020213c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020213e:	00043b03          	ld	s6,0(s0)
ffffffffc0202142:	00843a83          	ld	s5,8(s0)
ffffffffc0202146:	e000                	sd	s0,0(s0)
ffffffffc0202148:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020214a:	12d000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020214e:	50051563          	bnez	a0,ffffffffc0202658 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202152:	09098a13          	addi	s4,s3,144
ffffffffc0202156:	8552                	mv	a0,s4
ffffffffc0202158:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020215a:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020215e:	0000f797          	auipc	a5,0xf
ffffffffc0202162:	f807a123          	sw	zero,-126(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202166:	1a3000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020216a:	4511                	li	a0,4
ffffffffc020216c:	10b000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202170:	4c051463          	bnez	a0,ffffffffc0202638 <default_check+0x6b6>
ffffffffc0202174:	0989b783          	ld	a5,152(s3)
ffffffffc0202178:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020217a:	8b85                	andi	a5,a5,1
ffffffffc020217c:	48078e63          	beqz	a5,ffffffffc0202618 <default_check+0x696>
ffffffffc0202180:	0a89a703          	lw	a4,168(s3)
ffffffffc0202184:	478d                	li	a5,3
ffffffffc0202186:	48f71963          	bne	a4,a5,ffffffffc0202618 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020218a:	450d                	li	a0,3
ffffffffc020218c:	0eb000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202190:	8c2a                	mv	s8,a0
ffffffffc0202192:	46050363          	beqz	a0,ffffffffc02025f8 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0202196:	4505                	li	a0,1
ffffffffc0202198:	0df000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020219c:	42051e63          	bnez	a0,ffffffffc02025d8 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc02021a0:	418a1c63          	bne	s4,s8,ffffffffc02025b8 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02021a4:	4585                	li	a1,1
ffffffffc02021a6:	854e                	mv	a0,s3
ffffffffc02021a8:	161000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_pages(p1, 3);
ffffffffc02021ac:	458d                	li	a1,3
ffffffffc02021ae:	8552                	mv	a0,s4
ffffffffc02021b0:	159000ef          	jal	ra,ffffffffc0202b08 <free_pages>
ffffffffc02021b4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02021b8:	04898c13          	addi	s8,s3,72
ffffffffc02021bc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02021be:	8b85                	andi	a5,a5,1
ffffffffc02021c0:	3c078c63          	beqz	a5,ffffffffc0202598 <default_check+0x616>
ffffffffc02021c4:	0189a703          	lw	a4,24(s3)
ffffffffc02021c8:	4785                	li	a5,1
ffffffffc02021ca:	3cf71763          	bne	a4,a5,ffffffffc0202598 <default_check+0x616>
ffffffffc02021ce:	008a3783          	ld	a5,8(s4)
ffffffffc02021d2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02021d4:	8b85                	andi	a5,a5,1
ffffffffc02021d6:	3a078163          	beqz	a5,ffffffffc0202578 <default_check+0x5f6>
ffffffffc02021da:	018a2703          	lw	a4,24(s4)
ffffffffc02021de:	478d                	li	a5,3
ffffffffc02021e0:	38f71c63          	bne	a4,a5,ffffffffc0202578 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02021e4:	4505                	li	a0,1
ffffffffc02021e6:	091000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02021ea:	36a99763          	bne	s3,a0,ffffffffc0202558 <default_check+0x5d6>
    free_page(p0);
ffffffffc02021ee:	4585                	li	a1,1
ffffffffc02021f0:	119000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02021f4:	4509                	li	a0,2
ffffffffc02021f6:	081000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02021fa:	32aa1f63          	bne	s4,a0,ffffffffc0202538 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02021fe:	4589                	li	a1,2
ffffffffc0202200:	109000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    free_page(p2);
ffffffffc0202204:	4585                	li	a1,1
ffffffffc0202206:	8562                	mv	a0,s8
ffffffffc0202208:	101000ef          	jal	ra,ffffffffc0202b08 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020220c:	4515                	li	a0,5
ffffffffc020220e:	069000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202212:	89aa                	mv	s3,a0
ffffffffc0202214:	48050263          	beqz	a0,ffffffffc0202698 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0202218:	4505                	li	a0,1
ffffffffc020221a:	05d000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020221e:	2c051d63          	bnez	a0,ffffffffc02024f8 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0202222:	481c                	lw	a5,16(s0)
ffffffffc0202224:	2a079a63          	bnez	a5,ffffffffc02024d8 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202228:	4595                	li	a1,5
ffffffffc020222a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020222c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202230:	01643023          	sd	s6,0(s0)
ffffffffc0202234:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202238:	0d1000ef          	jal	ra,ffffffffc0202b08 <free_pages>
    return listelm->next;
ffffffffc020223c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020223e:	00878963          	beq	a5,s0,ffffffffc0202250 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202242:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202246:	679c                	ld	a5,8(a5)
ffffffffc0202248:	397d                	addiw	s2,s2,-1
ffffffffc020224a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020224c:	fe879be3          	bne	a5,s0,ffffffffc0202242 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0202250:	26091463          	bnez	s2,ffffffffc02024b8 <default_check+0x536>
    assert(total == 0);
ffffffffc0202254:	46049263          	bnez	s1,ffffffffc02026b8 <default_check+0x736>
}
ffffffffc0202258:	60a6                	ld	ra,72(sp)
ffffffffc020225a:	6406                	ld	s0,64(sp)
ffffffffc020225c:	74e2                	ld	s1,56(sp)
ffffffffc020225e:	7942                	ld	s2,48(sp)
ffffffffc0202260:	79a2                	ld	s3,40(sp)
ffffffffc0202262:	7a02                	ld	s4,32(sp)
ffffffffc0202264:	6ae2                	ld	s5,24(sp)
ffffffffc0202266:	6b42                	ld	s6,16(sp)
ffffffffc0202268:	6ba2                	ld	s7,8(sp)
ffffffffc020226a:	6c02                	ld	s8,0(sp)
ffffffffc020226c:	6161                	addi	sp,sp,80
ffffffffc020226e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202270:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202272:	4481                	li	s1,0
ffffffffc0202274:	4901                	li	s2,0
ffffffffc0202276:	b3b9                	j	ffffffffc0201fc4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202278:	00003697          	auipc	a3,0x3
ffffffffc020227c:	f8868693          	addi	a3,a3,-120 # ffffffffc0205200 <commands+0xb00>
ffffffffc0202280:	00003617          	auipc	a2,0x3
ffffffffc0202284:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202288:	0f000593          	li	a1,240
ffffffffc020228c:	00003517          	auipc	a0,0x3
ffffffffc0202290:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202294:	e6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	53868693          	addi	a3,a3,1336 # ffffffffc02057d0 <commands+0x10d0>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e28 <commands+0x728>
ffffffffc02022a8:	0bd00593          	li	a1,189
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205758 <commands+0x1058>
ffffffffc02022b4:	e4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	54068693          	addi	a3,a3,1344 # ffffffffc02057f8 <commands+0x10f8>
ffffffffc02022c0:	00003617          	auipc	a2,0x3
ffffffffc02022c4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e28 <commands+0x728>
ffffffffc02022c8:	0be00593          	li	a1,190
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	48c50513          	addi	a0,a0,1164 # ffffffffc0205758 <commands+0x1058>
ffffffffc02022d4:	e2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	56068693          	addi	a3,a3,1376 # ffffffffc0205838 <commands+0x1138>
ffffffffc02022e0:	00003617          	auipc	a2,0x3
ffffffffc02022e4:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e28 <commands+0x728>
ffffffffc02022e8:	0c000593          	li	a1,192
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	46c50513          	addi	a0,a0,1132 # ffffffffc0205758 <commands+0x1058>
ffffffffc02022f4:	e0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02022f8:	00003697          	auipc	a3,0x3
ffffffffc02022fc:	5c868693          	addi	a3,a3,1480 # ffffffffc02058c0 <commands+0x11c0>
ffffffffc0202300:	00003617          	auipc	a2,0x3
ffffffffc0202304:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202308:	0d900593          	li	a1,217
ffffffffc020230c:	00003517          	auipc	a0,0x3
ffffffffc0202310:	44c50513          	addi	a0,a0,1100 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202314:	deffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202318:	00003697          	auipc	a3,0x3
ffffffffc020231c:	45868693          	addi	a3,a3,1112 # ffffffffc0205770 <commands+0x1070>
ffffffffc0202320:	00003617          	auipc	a2,0x3
ffffffffc0202324:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202328:	0d200593          	li	a1,210
ffffffffc020232c:	00003517          	auipc	a0,0x3
ffffffffc0202330:	42c50513          	addi	a0,a0,1068 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202334:	dcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0202338:	00003697          	auipc	a3,0x3
ffffffffc020233c:	57868693          	addi	a3,a3,1400 # ffffffffc02058b0 <commands+0x11b0>
ffffffffc0202340:	00003617          	auipc	a2,0x3
ffffffffc0202344:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202348:	0d000593          	li	a1,208
ffffffffc020234c:	00003517          	auipc	a0,0x3
ffffffffc0202350:	40c50513          	addi	a0,a0,1036 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202354:	daffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202358:	00003697          	auipc	a3,0x3
ffffffffc020235c:	54068693          	addi	a3,a3,1344 # ffffffffc0205898 <commands+0x1198>
ffffffffc0202360:	00003617          	auipc	a2,0x3
ffffffffc0202364:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202368:	0cb00593          	li	a1,203
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202374:	d8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202378:	00003697          	auipc	a3,0x3
ffffffffc020237c:	50068693          	addi	a3,a3,1280 # ffffffffc0205878 <commands+0x1178>
ffffffffc0202380:	00003617          	auipc	a2,0x3
ffffffffc0202384:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202388:	0c200593          	li	a1,194
ffffffffc020238c:	00003517          	auipc	a0,0x3
ffffffffc0202390:	3cc50513          	addi	a0,a0,972 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202394:	d6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	56068693          	addi	a3,a3,1376 # ffffffffc02058f8 <commands+0x11f8>
ffffffffc02023a0:	00003617          	auipc	a2,0x3
ffffffffc02023a4:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204e28 <commands+0x728>
ffffffffc02023a8:	0f800593          	li	a1,248
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	3ac50513          	addi	a0,a0,940 # ffffffffc0205758 <commands+0x1058>
ffffffffc02023b4:	d4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02023b8:	00003697          	auipc	a3,0x3
ffffffffc02023bc:	ff868693          	addi	a3,a3,-8 # ffffffffc02053b0 <commands+0xcb0>
ffffffffc02023c0:	00003617          	auipc	a2,0x3
ffffffffc02023c4:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204e28 <commands+0x728>
ffffffffc02023c8:	0df00593          	li	a1,223
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	38c50513          	addi	a0,a0,908 # ffffffffc0205758 <commands+0x1058>
ffffffffc02023d4:	d2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023d8:	00003697          	auipc	a3,0x3
ffffffffc02023dc:	4c068693          	addi	a3,a3,1216 # ffffffffc0205898 <commands+0x1198>
ffffffffc02023e0:	00003617          	auipc	a2,0x3
ffffffffc02023e4:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204e28 <commands+0x728>
ffffffffc02023e8:	0dd00593          	li	a1,221
ffffffffc02023ec:	00003517          	auipc	a0,0x3
ffffffffc02023f0:	36c50513          	addi	a0,a0,876 # ffffffffc0205758 <commands+0x1058>
ffffffffc02023f4:	d0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02023f8:	00003697          	auipc	a3,0x3
ffffffffc02023fc:	4e068693          	addi	a3,a3,1248 # ffffffffc02058d8 <commands+0x11d8>
ffffffffc0202400:	00003617          	auipc	a2,0x3
ffffffffc0202404:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202408:	0dc00593          	li	a1,220
ffffffffc020240c:	00003517          	auipc	a0,0x3
ffffffffc0202410:	34c50513          	addi	a0,a0,844 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202414:	ceffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202418:	00003697          	auipc	a3,0x3
ffffffffc020241c:	35868693          	addi	a3,a3,856 # ffffffffc0205770 <commands+0x1070>
ffffffffc0202420:	00003617          	auipc	a2,0x3
ffffffffc0202424:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202428:	0b900593          	li	a1,185
ffffffffc020242c:	00003517          	auipc	a0,0x3
ffffffffc0202430:	32c50513          	addi	a0,a0,812 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202434:	ccffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202438:	00003697          	auipc	a3,0x3
ffffffffc020243c:	46068693          	addi	a3,a3,1120 # ffffffffc0205898 <commands+0x1198>
ffffffffc0202440:	00003617          	auipc	a2,0x3
ffffffffc0202444:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202448:	0d600593          	li	a1,214
ffffffffc020244c:	00003517          	auipc	a0,0x3
ffffffffc0202450:	30c50513          	addi	a0,a0,780 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202454:	caffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202458:	00003697          	auipc	a3,0x3
ffffffffc020245c:	35868693          	addi	a3,a3,856 # ffffffffc02057b0 <commands+0x10b0>
ffffffffc0202460:	00003617          	auipc	a2,0x3
ffffffffc0202464:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202468:	0d400593          	li	a1,212
ffffffffc020246c:	00003517          	auipc	a0,0x3
ffffffffc0202470:	2ec50513          	addi	a0,a0,748 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202474:	c8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202478:	00003697          	auipc	a3,0x3
ffffffffc020247c:	31868693          	addi	a3,a3,792 # ffffffffc0205790 <commands+0x1090>
ffffffffc0202480:	00003617          	auipc	a2,0x3
ffffffffc0202484:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202488:	0d300593          	li	a1,211
ffffffffc020248c:	00003517          	auipc	a0,0x3
ffffffffc0202490:	2cc50513          	addi	a0,a0,716 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202494:	c6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202498:	00003697          	auipc	a3,0x3
ffffffffc020249c:	31868693          	addi	a3,a3,792 # ffffffffc02057b0 <commands+0x10b0>
ffffffffc02024a0:	00003617          	auipc	a2,0x3
ffffffffc02024a4:	98860613          	addi	a2,a2,-1656 # ffffffffc0204e28 <commands+0x728>
ffffffffc02024a8:	0bb00593          	li	a1,187
ffffffffc02024ac:	00003517          	auipc	a0,0x3
ffffffffc02024b0:	2ac50513          	addi	a0,a0,684 # ffffffffc0205758 <commands+0x1058>
ffffffffc02024b4:	c4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc02024b8:	00003697          	auipc	a3,0x3
ffffffffc02024bc:	59068693          	addi	a3,a3,1424 # ffffffffc0205a48 <commands+0x1348>
ffffffffc02024c0:	00003617          	auipc	a2,0x3
ffffffffc02024c4:	96860613          	addi	a2,a2,-1688 # ffffffffc0204e28 <commands+0x728>
ffffffffc02024c8:	12500593          	li	a1,293
ffffffffc02024cc:	00003517          	auipc	a0,0x3
ffffffffc02024d0:	28c50513          	addi	a0,a0,652 # ffffffffc0205758 <commands+0x1058>
ffffffffc02024d4:	c2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02024d8:	00003697          	auipc	a3,0x3
ffffffffc02024dc:	ed868693          	addi	a3,a3,-296 # ffffffffc02053b0 <commands+0xcb0>
ffffffffc02024e0:	00003617          	auipc	a2,0x3
ffffffffc02024e4:	94860613          	addi	a2,a2,-1720 # ffffffffc0204e28 <commands+0x728>
ffffffffc02024e8:	11a00593          	li	a1,282
ffffffffc02024ec:	00003517          	auipc	a0,0x3
ffffffffc02024f0:	26c50513          	addi	a0,a0,620 # ffffffffc0205758 <commands+0x1058>
ffffffffc02024f4:	c0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02024f8:	00003697          	auipc	a3,0x3
ffffffffc02024fc:	3a068693          	addi	a3,a3,928 # ffffffffc0205898 <commands+0x1198>
ffffffffc0202500:	00003617          	auipc	a2,0x3
ffffffffc0202504:	92860613          	addi	a2,a2,-1752 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202508:	11800593          	li	a1,280
ffffffffc020250c:	00003517          	auipc	a0,0x3
ffffffffc0202510:	24c50513          	addi	a0,a0,588 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202514:	beffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202518:	00003697          	auipc	a3,0x3
ffffffffc020251c:	34068693          	addi	a3,a3,832 # ffffffffc0205858 <commands+0x1158>
ffffffffc0202520:	00003617          	auipc	a2,0x3
ffffffffc0202524:	90860613          	addi	a2,a2,-1784 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202528:	0c100593          	li	a1,193
ffffffffc020252c:	00003517          	auipc	a0,0x3
ffffffffc0202530:	22c50513          	addi	a0,a0,556 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202534:	bcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202538:	00003697          	auipc	a3,0x3
ffffffffc020253c:	4d068693          	addi	a3,a3,1232 # ffffffffc0205a08 <commands+0x1308>
ffffffffc0202540:	00003617          	auipc	a2,0x3
ffffffffc0202544:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202548:	11200593          	li	a1,274
ffffffffc020254c:	00003517          	auipc	a0,0x3
ffffffffc0202550:	20c50513          	addi	a0,a0,524 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202554:	baffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202558:	00003697          	auipc	a3,0x3
ffffffffc020255c:	49068693          	addi	a3,a3,1168 # ffffffffc02059e8 <commands+0x12e8>
ffffffffc0202560:	00003617          	auipc	a2,0x3
ffffffffc0202564:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202568:	11000593          	li	a1,272
ffffffffc020256c:	00003517          	auipc	a0,0x3
ffffffffc0202570:	1ec50513          	addi	a0,a0,492 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202574:	b8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202578:	00003697          	auipc	a3,0x3
ffffffffc020257c:	44868693          	addi	a3,a3,1096 # ffffffffc02059c0 <commands+0x12c0>
ffffffffc0202580:	00003617          	auipc	a2,0x3
ffffffffc0202584:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202588:	10e00593          	li	a1,270
ffffffffc020258c:	00003517          	auipc	a0,0x3
ffffffffc0202590:	1cc50513          	addi	a0,a0,460 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202594:	b6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202598:	00003697          	auipc	a3,0x3
ffffffffc020259c:	40068693          	addi	a3,a3,1024 # ffffffffc0205998 <commands+0x1298>
ffffffffc02025a0:	00003617          	auipc	a2,0x3
ffffffffc02025a4:	88860613          	addi	a2,a2,-1912 # ffffffffc0204e28 <commands+0x728>
ffffffffc02025a8:	10d00593          	li	a1,269
ffffffffc02025ac:	00003517          	auipc	a0,0x3
ffffffffc02025b0:	1ac50513          	addi	a0,a0,428 # ffffffffc0205758 <commands+0x1058>
ffffffffc02025b4:	b4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02025b8:	00003697          	auipc	a3,0x3
ffffffffc02025bc:	3d068693          	addi	a3,a3,976 # ffffffffc0205988 <commands+0x1288>
ffffffffc02025c0:	00003617          	auipc	a2,0x3
ffffffffc02025c4:	86860613          	addi	a2,a2,-1944 # ffffffffc0204e28 <commands+0x728>
ffffffffc02025c8:	10800593          	li	a1,264
ffffffffc02025cc:	00003517          	auipc	a0,0x3
ffffffffc02025d0:	18c50513          	addi	a0,a0,396 # ffffffffc0205758 <commands+0x1058>
ffffffffc02025d4:	b2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02025d8:	00003697          	auipc	a3,0x3
ffffffffc02025dc:	2c068693          	addi	a3,a3,704 # ffffffffc0205898 <commands+0x1198>
ffffffffc02025e0:	00003617          	auipc	a2,0x3
ffffffffc02025e4:	84860613          	addi	a2,a2,-1976 # ffffffffc0204e28 <commands+0x728>
ffffffffc02025e8:	10700593          	li	a1,263
ffffffffc02025ec:	00003517          	auipc	a0,0x3
ffffffffc02025f0:	16c50513          	addi	a0,a0,364 # ffffffffc0205758 <commands+0x1058>
ffffffffc02025f4:	b0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02025f8:	00003697          	auipc	a3,0x3
ffffffffc02025fc:	37068693          	addi	a3,a3,880 # ffffffffc0205968 <commands+0x1268>
ffffffffc0202600:	00003617          	auipc	a2,0x3
ffffffffc0202604:	82860613          	addi	a2,a2,-2008 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202608:	10600593          	li	a1,262
ffffffffc020260c:	00003517          	auipc	a0,0x3
ffffffffc0202610:	14c50513          	addi	a0,a0,332 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202614:	aeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202618:	00003697          	auipc	a3,0x3
ffffffffc020261c:	32068693          	addi	a3,a3,800 # ffffffffc0205938 <commands+0x1238>
ffffffffc0202620:	00003617          	auipc	a2,0x3
ffffffffc0202624:	80860613          	addi	a2,a2,-2040 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202628:	10500593          	li	a1,261
ffffffffc020262c:	00003517          	auipc	a0,0x3
ffffffffc0202630:	12c50513          	addi	a0,a0,300 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202634:	acffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202638:	00003697          	auipc	a3,0x3
ffffffffc020263c:	2e868693          	addi	a3,a3,744 # ffffffffc0205920 <commands+0x1220>
ffffffffc0202640:	00002617          	auipc	a2,0x2
ffffffffc0202644:	7e860613          	addi	a2,a2,2024 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202648:	10400593          	li	a1,260
ffffffffc020264c:	00003517          	auipc	a0,0x3
ffffffffc0202650:	10c50513          	addi	a0,a0,268 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202654:	aaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202658:	00003697          	auipc	a3,0x3
ffffffffc020265c:	24068693          	addi	a3,a3,576 # ffffffffc0205898 <commands+0x1198>
ffffffffc0202660:	00002617          	auipc	a2,0x2
ffffffffc0202664:	7c860613          	addi	a2,a2,1992 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202668:	0fe00593          	li	a1,254
ffffffffc020266c:	00003517          	auipc	a0,0x3
ffffffffc0202670:	0ec50513          	addi	a0,a0,236 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202674:	a8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202678:	00003697          	auipc	a3,0x3
ffffffffc020267c:	29068693          	addi	a3,a3,656 # ffffffffc0205908 <commands+0x1208>
ffffffffc0202680:	00002617          	auipc	a2,0x2
ffffffffc0202684:	7a860613          	addi	a2,a2,1960 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202688:	0f900593          	li	a1,249
ffffffffc020268c:	00003517          	auipc	a0,0x3
ffffffffc0202690:	0cc50513          	addi	a0,a0,204 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202694:	a6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202698:	00003697          	auipc	a3,0x3
ffffffffc020269c:	39068693          	addi	a3,a3,912 # ffffffffc0205a28 <commands+0x1328>
ffffffffc02026a0:	00002617          	auipc	a2,0x2
ffffffffc02026a4:	78860613          	addi	a2,a2,1928 # ffffffffc0204e28 <commands+0x728>
ffffffffc02026a8:	11700593          	li	a1,279
ffffffffc02026ac:	00003517          	auipc	a0,0x3
ffffffffc02026b0:	0ac50513          	addi	a0,a0,172 # ffffffffc0205758 <commands+0x1058>
ffffffffc02026b4:	a4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc02026b8:	00003697          	auipc	a3,0x3
ffffffffc02026bc:	3a068693          	addi	a3,a3,928 # ffffffffc0205a58 <commands+0x1358>
ffffffffc02026c0:	00002617          	auipc	a2,0x2
ffffffffc02026c4:	76860613          	addi	a2,a2,1896 # ffffffffc0204e28 <commands+0x728>
ffffffffc02026c8:	12600593          	li	a1,294
ffffffffc02026cc:	00003517          	auipc	a0,0x3
ffffffffc02026d0:	08c50513          	addi	a0,a0,140 # ffffffffc0205758 <commands+0x1058>
ffffffffc02026d4:	a2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02026d8:	00003697          	auipc	a3,0x3
ffffffffc02026dc:	b3868693          	addi	a3,a3,-1224 # ffffffffc0205210 <commands+0xb10>
ffffffffc02026e0:	00002617          	auipc	a2,0x2
ffffffffc02026e4:	74860613          	addi	a2,a2,1864 # ffffffffc0204e28 <commands+0x728>
ffffffffc02026e8:	0f300593          	li	a1,243
ffffffffc02026ec:	00003517          	auipc	a0,0x3
ffffffffc02026f0:	06c50513          	addi	a0,a0,108 # ffffffffc0205758 <commands+0x1058>
ffffffffc02026f4:	a0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02026f8:	00003697          	auipc	a3,0x3
ffffffffc02026fc:	09868693          	addi	a3,a3,152 # ffffffffc0205790 <commands+0x1090>
ffffffffc0202700:	00002617          	auipc	a2,0x2
ffffffffc0202704:	72860613          	addi	a2,a2,1832 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202708:	0ba00593          	li	a1,186
ffffffffc020270c:	00003517          	auipc	a0,0x3
ffffffffc0202710:	04c50513          	addi	a0,a0,76 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202714:	9effd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202718 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202718:	1141                	addi	sp,sp,-16
ffffffffc020271a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020271c:	14058a63          	beqz	a1,ffffffffc0202870 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202720:	00359693          	slli	a3,a1,0x3
ffffffffc0202724:	96ae                	add	a3,a3,a1
ffffffffc0202726:	068e                	slli	a3,a3,0x3
ffffffffc0202728:	96aa                	add	a3,a3,a0
ffffffffc020272a:	87aa                	mv	a5,a0
ffffffffc020272c:	02d50263          	beq	a0,a3,ffffffffc0202750 <default_free_pages+0x38>
ffffffffc0202730:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202732:	8b05                	andi	a4,a4,1
ffffffffc0202734:	10071e63          	bnez	a4,ffffffffc0202850 <default_free_pages+0x138>
ffffffffc0202738:	6798                	ld	a4,8(a5)
ffffffffc020273a:	8b09                	andi	a4,a4,2
ffffffffc020273c:	10071a63          	bnez	a4,ffffffffc0202850 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202740:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202744:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202748:	04878793          	addi	a5,a5,72
ffffffffc020274c:	fed792e3          	bne	a5,a3,ffffffffc0202730 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202750:	2581                	sext.w	a1,a1
ffffffffc0202752:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202754:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202758:	4789                	li	a5,2
ffffffffc020275a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020275e:	0000f697          	auipc	a3,0xf
ffffffffc0202762:	97268693          	addi	a3,a3,-1678 # ffffffffc02110d0 <free_area>
ffffffffc0202766:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202768:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020276a:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020276e:	9db9                	addw	a1,a1,a4
ffffffffc0202770:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202772:	0ad78863          	beq	a5,a3,ffffffffc0202822 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202776:	fe078713          	addi	a4,a5,-32
ffffffffc020277a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020277e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202780:	00e56a63          	bltu	a0,a4,ffffffffc0202794 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202784:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202786:	06d70263          	beq	a4,a3,ffffffffc02027ea <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020278a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020278c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202790:	fee57ae3          	bgeu	a0,a4,ffffffffc0202784 <default_free_pages+0x6c>
ffffffffc0202794:	c199                	beqz	a1,ffffffffc020279a <default_free_pages+0x82>
ffffffffc0202796:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020279a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020279c:	e390                	sd	a2,0(a5)
ffffffffc020279e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02027a0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02027a2:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02027a4:	02d70063          	beq	a4,a3,ffffffffc02027c4 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02027a8:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02027ac:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02027b0:	02081613          	slli	a2,a6,0x20
ffffffffc02027b4:	9201                	srli	a2,a2,0x20
ffffffffc02027b6:	00361793          	slli	a5,a2,0x3
ffffffffc02027ba:	97b2                	add	a5,a5,a2
ffffffffc02027bc:	078e                	slli	a5,a5,0x3
ffffffffc02027be:	97ae                	add	a5,a5,a1
ffffffffc02027c0:	02f50f63          	beq	a0,a5,ffffffffc02027fe <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02027c4:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02027c6:	00d70f63          	beq	a4,a3,ffffffffc02027e4 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02027ca:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02027cc:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02027d0:	02059613          	slli	a2,a1,0x20
ffffffffc02027d4:	9201                	srli	a2,a2,0x20
ffffffffc02027d6:	00361793          	slli	a5,a2,0x3
ffffffffc02027da:	97b2                	add	a5,a5,a2
ffffffffc02027dc:	078e                	slli	a5,a5,0x3
ffffffffc02027de:	97aa                	add	a5,a5,a0
ffffffffc02027e0:	04f68863          	beq	a3,a5,ffffffffc0202830 <default_free_pages+0x118>
}
ffffffffc02027e4:	60a2                	ld	ra,8(sp)
ffffffffc02027e6:	0141                	addi	sp,sp,16
ffffffffc02027e8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02027ea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02027ec:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02027ee:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02027f0:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02027f2:	02d70563          	beq	a4,a3,ffffffffc020281c <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02027f6:	8832                	mv	a6,a2
ffffffffc02027f8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02027fa:	87ba                	mv	a5,a4
ffffffffc02027fc:	bf41                	j	ffffffffc020278c <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02027fe:	4d1c                	lw	a5,24(a0)
ffffffffc0202800:	0107883b          	addw	a6,a5,a6
ffffffffc0202804:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202808:	57f5                	li	a5,-3
ffffffffc020280a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020280e:	7110                	ld	a2,32(a0)
ffffffffc0202810:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0202812:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202814:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202816:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202818:	e390                	sd	a2,0(a5)
ffffffffc020281a:	b775                	j	ffffffffc02027c6 <default_free_pages+0xae>
ffffffffc020281c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020281e:	873e                	mv	a4,a5
ffffffffc0202820:	b761                	j	ffffffffc02027a8 <default_free_pages+0x90>
}
ffffffffc0202822:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202824:	e390                	sd	a2,0(a5)
ffffffffc0202826:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202828:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020282a:	f11c                	sd	a5,32(a0)
ffffffffc020282c:	0141                	addi	sp,sp,16
ffffffffc020282e:	8082                	ret
            base->property += p->property;
ffffffffc0202830:	ff872783          	lw	a5,-8(a4)
ffffffffc0202834:	fe870693          	addi	a3,a4,-24
ffffffffc0202838:	9dbd                	addw	a1,a1,a5
ffffffffc020283a:	cd0c                	sw	a1,24(a0)
ffffffffc020283c:	57f5                	li	a5,-3
ffffffffc020283e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202842:	6314                	ld	a3,0(a4)
ffffffffc0202844:	671c                	ld	a5,8(a4)
}
ffffffffc0202846:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202848:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020284a:	e394                	sd	a3,0(a5)
ffffffffc020284c:	0141                	addi	sp,sp,16
ffffffffc020284e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202850:	00003697          	auipc	a3,0x3
ffffffffc0202854:	22068693          	addi	a3,a3,544 # ffffffffc0205a70 <commands+0x1370>
ffffffffc0202858:	00002617          	auipc	a2,0x2
ffffffffc020285c:	5d060613          	addi	a2,a2,1488 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202860:	08300593          	li	a1,131
ffffffffc0202864:	00003517          	auipc	a0,0x3
ffffffffc0202868:	ef450513          	addi	a0,a0,-268 # ffffffffc0205758 <commands+0x1058>
ffffffffc020286c:	897fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202870:	00003697          	auipc	a3,0x3
ffffffffc0202874:	1f868693          	addi	a3,a3,504 # ffffffffc0205a68 <commands+0x1368>
ffffffffc0202878:	00002617          	auipc	a2,0x2
ffffffffc020287c:	5b060613          	addi	a2,a2,1456 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202880:	08000593          	li	a1,128
ffffffffc0202884:	00003517          	auipc	a0,0x3
ffffffffc0202888:	ed450513          	addi	a0,a0,-300 # ffffffffc0205758 <commands+0x1058>
ffffffffc020288c:	877fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202890 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202890:	c959                	beqz	a0,ffffffffc0202926 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202892:	0000f597          	auipc	a1,0xf
ffffffffc0202896:	83e58593          	addi	a1,a1,-1986 # ffffffffc02110d0 <free_area>
ffffffffc020289a:	0105a803          	lw	a6,16(a1)
ffffffffc020289e:	862a                	mv	a2,a0
ffffffffc02028a0:	02081793          	slli	a5,a6,0x20
ffffffffc02028a4:	9381                	srli	a5,a5,0x20
ffffffffc02028a6:	00a7ee63          	bltu	a5,a0,ffffffffc02028c2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02028aa:	87ae                	mv	a5,a1
ffffffffc02028ac:	a801                	j	ffffffffc02028bc <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02028ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028b2:	02071693          	slli	a3,a4,0x20
ffffffffc02028b6:	9281                	srli	a3,a3,0x20
ffffffffc02028b8:	00c6f763          	bgeu	a3,a2,ffffffffc02028c6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02028bc:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02028be:	feb798e3          	bne	a5,a1,ffffffffc02028ae <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02028c2:	4501                	li	a0,0
}
ffffffffc02028c4:	8082                	ret
    return listelm->prev;
ffffffffc02028c6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02028ca:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02028ce:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02028d2:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02028d6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02028da:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02028de:	02d67b63          	bgeu	a2,a3,ffffffffc0202914 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02028e2:	00361693          	slli	a3,a2,0x3
ffffffffc02028e6:	96b2                	add	a3,a3,a2
ffffffffc02028e8:	068e                	slli	a3,a3,0x3
ffffffffc02028ea:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02028ec:	41c7073b          	subw	a4,a4,t3
ffffffffc02028f0:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02028f2:	00868613          	addi	a2,a3,8
ffffffffc02028f6:	4709                	li	a4,2
ffffffffc02028f8:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02028fc:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202900:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202904:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202908:	e310                	sd	a2,0(a4)
ffffffffc020290a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020290e:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202910:	0316b023          	sd	a7,32(a3)
ffffffffc0202914:	41c8083b          	subw	a6,a6,t3
ffffffffc0202918:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020291c:	5775                	li	a4,-3
ffffffffc020291e:	17a1                	addi	a5,a5,-24
ffffffffc0202920:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202924:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202926:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202928:	00003697          	auipc	a3,0x3
ffffffffc020292c:	14068693          	addi	a3,a3,320 # ffffffffc0205a68 <commands+0x1368>
ffffffffc0202930:	00002617          	auipc	a2,0x2
ffffffffc0202934:	4f860613          	addi	a2,a2,1272 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202938:	06200593          	li	a1,98
ffffffffc020293c:	00003517          	auipc	a0,0x3
ffffffffc0202940:	e1c50513          	addi	a0,a0,-484 # ffffffffc0205758 <commands+0x1058>
default_alloc_pages(size_t n) {
ffffffffc0202944:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202946:	fbcfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020294a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020294a:	1141                	addi	sp,sp,-16
ffffffffc020294c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020294e:	c9e1                	beqz	a1,ffffffffc0202a1e <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202950:	00359693          	slli	a3,a1,0x3
ffffffffc0202954:	96ae                	add	a3,a3,a1
ffffffffc0202956:	068e                	slli	a3,a3,0x3
ffffffffc0202958:	96aa                	add	a3,a3,a0
ffffffffc020295a:	87aa                	mv	a5,a0
ffffffffc020295c:	00d50f63          	beq	a0,a3,ffffffffc020297a <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202960:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202962:	8b05                	andi	a4,a4,1
ffffffffc0202964:	cf49                	beqz	a4,ffffffffc02029fe <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202966:	0007ac23          	sw	zero,24(a5)
ffffffffc020296a:	0007b423          	sd	zero,8(a5)
ffffffffc020296e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202972:	04878793          	addi	a5,a5,72
ffffffffc0202976:	fed795e3          	bne	a5,a3,ffffffffc0202960 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020297a:	2581                	sext.w	a1,a1
ffffffffc020297c:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020297e:	4789                	li	a5,2
ffffffffc0202980:	00850713          	addi	a4,a0,8
ffffffffc0202984:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202988:	0000e697          	auipc	a3,0xe
ffffffffc020298c:	74868693          	addi	a3,a3,1864 # ffffffffc02110d0 <free_area>
ffffffffc0202990:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202992:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202994:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202998:	9db9                	addw	a1,a1,a4
ffffffffc020299a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020299c:	04d78a63          	beq	a5,a3,ffffffffc02029f0 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02029a0:	fe078713          	addi	a4,a5,-32
ffffffffc02029a4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02029a8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02029aa:	00e56a63          	bltu	a0,a4,ffffffffc02029be <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02029ae:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02029b0:	02d70263          	beq	a4,a3,ffffffffc02029d4 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02029b4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02029b6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02029ba:	fee57ae3          	bgeu	a0,a4,ffffffffc02029ae <default_init_memmap+0x64>
ffffffffc02029be:	c199                	beqz	a1,ffffffffc02029c4 <default_init_memmap+0x7a>
ffffffffc02029c0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02029c4:	6398                	ld	a4,0(a5)
}
ffffffffc02029c6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02029c8:	e390                	sd	a2,0(a5)
ffffffffc02029ca:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02029cc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02029ce:	f118                	sd	a4,32(a0)
ffffffffc02029d0:	0141                	addi	sp,sp,16
ffffffffc02029d2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02029d4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02029d6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02029d8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02029da:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02029dc:	00d70663          	beq	a4,a3,ffffffffc02029e8 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02029e0:	8832                	mv	a6,a2
ffffffffc02029e2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02029e4:	87ba                	mv	a5,a4
ffffffffc02029e6:	bfc1                	j	ffffffffc02029b6 <default_init_memmap+0x6c>
}
ffffffffc02029e8:	60a2                	ld	ra,8(sp)
ffffffffc02029ea:	e290                	sd	a2,0(a3)
ffffffffc02029ec:	0141                	addi	sp,sp,16
ffffffffc02029ee:	8082                	ret
ffffffffc02029f0:	60a2                	ld	ra,8(sp)
ffffffffc02029f2:	e390                	sd	a2,0(a5)
ffffffffc02029f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02029f6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02029f8:	f11c                	sd	a5,32(a0)
ffffffffc02029fa:	0141                	addi	sp,sp,16
ffffffffc02029fc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02029fe:	00003697          	auipc	a3,0x3
ffffffffc0202a02:	09a68693          	addi	a3,a3,154 # ffffffffc0205a98 <commands+0x1398>
ffffffffc0202a06:	00002617          	auipc	a2,0x2
ffffffffc0202a0a:	42260613          	addi	a2,a2,1058 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202a0e:	04900593          	li	a1,73
ffffffffc0202a12:	00003517          	auipc	a0,0x3
ffffffffc0202a16:	d4650513          	addi	a0,a0,-698 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202a1a:	ee8fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202a1e:	00003697          	auipc	a3,0x3
ffffffffc0202a22:	04a68693          	addi	a3,a3,74 # ffffffffc0205a68 <commands+0x1368>
ffffffffc0202a26:	00002617          	auipc	a2,0x2
ffffffffc0202a2a:	40260613          	addi	a2,a2,1026 # ffffffffc0204e28 <commands+0x728>
ffffffffc0202a2e:	04600593          	li	a1,70
ffffffffc0202a32:	00003517          	auipc	a0,0x3
ffffffffc0202a36:	d2650513          	addi	a0,a0,-730 # ffffffffc0205758 <commands+0x1058>
ffffffffc0202a3a:	ec8fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a3e <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a3e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202a40:	00002617          	auipc	a2,0x2
ffffffffc0202a44:	63860613          	addi	a2,a2,1592 # ffffffffc0205078 <commands+0x978>
ffffffffc0202a48:	06500593          	li	a1,101
ffffffffc0202a4c:	00002517          	auipc	a0,0x2
ffffffffc0202a50:	64c50513          	addi	a0,a0,1612 # ffffffffc0205098 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a54:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202a56:	eacfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a5a <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202a5a:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202a5c:	00003617          	auipc	a2,0x3
ffffffffc0202a60:	97c60613          	addi	a2,a2,-1668 # ffffffffc02053d8 <commands+0xcd8>
ffffffffc0202a64:	07000593          	li	a1,112
ffffffffc0202a68:	00002517          	auipc	a0,0x2
ffffffffc0202a6c:	63050513          	addi	a0,a0,1584 # ffffffffc0205098 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202a70:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202a72:	e90fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a76 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202a76:	7139                	addi	sp,sp,-64
ffffffffc0202a78:	f426                	sd	s1,40(sp)
ffffffffc0202a7a:	f04a                	sd	s2,32(sp)
ffffffffc0202a7c:	ec4e                	sd	s3,24(sp)
ffffffffc0202a7e:	e852                	sd	s4,16(sp)
ffffffffc0202a80:	e456                	sd	s5,8(sp)
ffffffffc0202a82:	e05a                	sd	s6,0(sp)
ffffffffc0202a84:	fc06                	sd	ra,56(sp)
ffffffffc0202a86:	f822                	sd	s0,48(sp)
ffffffffc0202a88:	84aa                	mv	s1,a0
ffffffffc0202a8a:	0000f917          	auipc	s2,0xf
ffffffffc0202a8e:	ace90913          	addi	s2,s2,-1330 # ffffffffc0211558 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a92:	4a05                	li	s4,1
ffffffffc0202a94:	0000fa97          	auipc	s5,0xf
ffffffffc0202a98:	a9ca8a93          	addi	s5,s5,-1380 # ffffffffc0211530 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a9c:	0005099b          	sext.w	s3,a0
ffffffffc0202aa0:	0000fb17          	auipc	s6,0xf
ffffffffc0202aa4:	a70b0b13          	addi	s6,s6,-1424 # ffffffffc0211510 <check_mm_struct>
ffffffffc0202aa8:	a01d                	j	ffffffffc0202ace <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202aaa:	00093783          	ld	a5,0(s2)
ffffffffc0202aae:	6f9c                	ld	a5,24(a5)
ffffffffc0202ab0:	9782                	jalr	a5
ffffffffc0202ab2:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ab4:	4601                	li	a2,0
ffffffffc0202ab6:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202ab8:	ec0d                	bnez	s0,ffffffffc0202af2 <alloc_pages+0x7c>
ffffffffc0202aba:	029a6c63          	bltu	s4,s1,ffffffffc0202af2 <alloc_pages+0x7c>
ffffffffc0202abe:	000aa783          	lw	a5,0(s5)
ffffffffc0202ac2:	2781                	sext.w	a5,a5
ffffffffc0202ac4:	c79d                	beqz	a5,ffffffffc0202af2 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ac6:	000b3503          	ld	a0,0(s6)
ffffffffc0202aca:	f11fe0ef          	jal	ra,ffffffffc02019da <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ace:	100027f3          	csrr	a5,sstatus
ffffffffc0202ad2:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202ad4:	8526                	mv	a0,s1
ffffffffc0202ad6:	dbf1                	beqz	a5,ffffffffc0202aaa <alloc_pages+0x34>
        intr_disable();
ffffffffc0202ad8:	a17fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202adc:	00093783          	ld	a5,0(s2)
ffffffffc0202ae0:	8526                	mv	a0,s1
ffffffffc0202ae2:	6f9c                	ld	a5,24(a5)
ffffffffc0202ae4:	9782                	jalr	a5
ffffffffc0202ae6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ae8:	a01fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202aec:	4601                	li	a2,0
ffffffffc0202aee:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202af0:	d469                	beqz	s0,ffffffffc0202aba <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202af2:	70e2                	ld	ra,56(sp)
ffffffffc0202af4:	8522                	mv	a0,s0
ffffffffc0202af6:	7442                	ld	s0,48(sp)
ffffffffc0202af8:	74a2                	ld	s1,40(sp)
ffffffffc0202afa:	7902                	ld	s2,32(sp)
ffffffffc0202afc:	69e2                	ld	s3,24(sp)
ffffffffc0202afe:	6a42                	ld	s4,16(sp)
ffffffffc0202b00:	6aa2                	ld	s5,8(sp)
ffffffffc0202b02:	6b02                	ld	s6,0(sp)
ffffffffc0202b04:	6121                	addi	sp,sp,64
ffffffffc0202b06:	8082                	ret

ffffffffc0202b08 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b08:	100027f3          	csrr	a5,sstatus
ffffffffc0202b0c:	8b89                	andi	a5,a5,2
ffffffffc0202b0e:	e799                	bnez	a5,ffffffffc0202b1c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b10:	0000f797          	auipc	a5,0xf
ffffffffc0202b14:	a487b783          	ld	a5,-1464(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b18:	739c                	ld	a5,32(a5)
ffffffffc0202b1a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202b1c:	1101                	addi	sp,sp,-32
ffffffffc0202b1e:	ec06                	sd	ra,24(sp)
ffffffffc0202b20:	e822                	sd	s0,16(sp)
ffffffffc0202b22:	e426                	sd	s1,8(sp)
ffffffffc0202b24:	842a                	mv	s0,a0
ffffffffc0202b26:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202b28:	9c7fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b2c:	0000f797          	auipc	a5,0xf
ffffffffc0202b30:	a2c7b783          	ld	a5,-1492(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b34:	739c                	ld	a5,32(a5)
ffffffffc0202b36:	85a6                	mv	a1,s1
ffffffffc0202b38:	8522                	mv	a0,s0
ffffffffc0202b3a:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202b3c:	6442                	ld	s0,16(sp)
ffffffffc0202b3e:	60e2                	ld	ra,24(sp)
ffffffffc0202b40:	64a2                	ld	s1,8(sp)
ffffffffc0202b42:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202b44:	9a5fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202b48 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b48:	100027f3          	csrr	a5,sstatus
ffffffffc0202b4c:	8b89                	andi	a5,a5,2
ffffffffc0202b4e:	e799                	bnez	a5,ffffffffc0202b5c <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b50:	0000f797          	auipc	a5,0xf
ffffffffc0202b54:	a087b783          	ld	a5,-1528(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b58:	779c                	ld	a5,40(a5)
ffffffffc0202b5a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202b5c:	1141                	addi	sp,sp,-16
ffffffffc0202b5e:	e406                	sd	ra,8(sp)
ffffffffc0202b60:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b62:	98dfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b66:	0000f797          	auipc	a5,0xf
ffffffffc0202b6a:	9f27b783          	ld	a5,-1550(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b6e:	779c                	ld	a5,40(a5)
ffffffffc0202b70:	9782                	jalr	a5
ffffffffc0202b72:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b74:	975fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b78:	60a2                	ld	ra,8(sp)
ffffffffc0202b7a:	8522                	mv	a0,s0
ffffffffc0202b7c:	6402                	ld	s0,0(sp)
ffffffffc0202b7e:	0141                	addi	sp,sp,16
ffffffffc0202b80:	8082                	ret

ffffffffc0202b82 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b82:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202b86:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b8a:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b8c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b8e:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b90:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b94:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b96:	f84a                	sd	s2,48(sp)
ffffffffc0202b98:	f44e                	sd	s3,40(sp)
ffffffffc0202b9a:	f052                	sd	s4,32(sp)
ffffffffc0202b9c:	e486                	sd	ra,72(sp)
ffffffffc0202b9e:	e0a2                	sd	s0,64(sp)
ffffffffc0202ba0:	ec56                	sd	s5,24(sp)
ffffffffc0202ba2:	e85a                	sd	s6,16(sp)
ffffffffc0202ba4:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202ba6:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202baa:	892e                	mv	s2,a1
ffffffffc0202bac:	8a32                	mv	s4,a2
ffffffffc0202bae:	0000f997          	auipc	s3,0xf
ffffffffc0202bb2:	99a98993          	addi	s3,s3,-1638 # ffffffffc0211548 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202bb6:	efb5                	bnez	a5,ffffffffc0202c32 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202bb8:	14060c63          	beqz	a2,ffffffffc0202d10 <get_pte+0x18e>
ffffffffc0202bbc:	4505                	li	a0,1
ffffffffc0202bbe:	eb9ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202bc2:	842a                	mv	s0,a0
ffffffffc0202bc4:	14050663          	beqz	a0,ffffffffc0202d10 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bc8:	0000fb97          	auipc	s7,0xf
ffffffffc0202bcc:	988b8b93          	addi	s7,s7,-1656 # ffffffffc0211550 <pages>
ffffffffc0202bd0:	000bb503          	ld	a0,0(s7)
ffffffffc0202bd4:	00003b17          	auipc	s6,0x3
ffffffffc0202bd8:	7bcb3b03          	ld	s6,1980(s6) # ffffffffc0206390 <error_string+0x38>
ffffffffc0202bdc:	00080ab7          	lui	s5,0x80
ffffffffc0202be0:	40a40533          	sub	a0,s0,a0
ffffffffc0202be4:	850d                	srai	a0,a0,0x3
ffffffffc0202be6:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202bea:	0000f997          	auipc	s3,0xf
ffffffffc0202bee:	95e98993          	addi	s3,s3,-1698 # ffffffffc0211548 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202bf2:	4785                	li	a5,1
ffffffffc0202bf4:	0009b703          	ld	a4,0(s3)
ffffffffc0202bf8:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bfa:	9556                	add	a0,a0,s5
ffffffffc0202bfc:	00c51793          	slli	a5,a0,0xc
ffffffffc0202c00:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c02:	0532                	slli	a0,a0,0xc
ffffffffc0202c04:	14e7fd63          	bgeu	a5,a4,ffffffffc0202d5e <get_pte+0x1dc>
ffffffffc0202c08:	0000f797          	auipc	a5,0xf
ffffffffc0202c0c:	9587b783          	ld	a5,-1704(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0202c10:	6605                	lui	a2,0x1
ffffffffc0202c12:	4581                	li	a1,0
ffffffffc0202c14:	953e                	add	a0,a0,a5
ffffffffc0202c16:	3a2010ef          	jal	ra,ffffffffc0203fb8 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c1a:	000bb683          	ld	a3,0(s7)
ffffffffc0202c1e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c22:	868d                	srai	a3,a3,0x3
ffffffffc0202c24:	036686b3          	mul	a3,a3,s6
ffffffffc0202c28:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c2a:	06aa                	slli	a3,a3,0xa
ffffffffc0202c2c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c30:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c32:	77fd                	lui	a5,0xfffff
ffffffffc0202c34:	068a                	slli	a3,a3,0x2
ffffffffc0202c36:	0009b703          	ld	a4,0(s3)
ffffffffc0202c3a:	8efd                	and	a3,a3,a5
ffffffffc0202c3c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c40:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202d14 <get_pte+0x192>
ffffffffc0202c44:	0000fa97          	auipc	s5,0xf
ffffffffc0202c48:	91ca8a93          	addi	s5,s5,-1764 # ffffffffc0211560 <va_pa_offset>
ffffffffc0202c4c:	000ab403          	ld	s0,0(s5)
ffffffffc0202c50:	01595793          	srli	a5,s2,0x15
ffffffffc0202c54:	1ff7f793          	andi	a5,a5,511
ffffffffc0202c58:	96a2                	add	a3,a3,s0
ffffffffc0202c5a:	00379413          	slli	s0,a5,0x3
ffffffffc0202c5e:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202c60:	6014                	ld	a3,0(s0)
ffffffffc0202c62:	0016f793          	andi	a5,a3,1
ffffffffc0202c66:	ebad                	bnez	a5,ffffffffc0202cd8 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c68:	0a0a0463          	beqz	s4,ffffffffc0202d10 <get_pte+0x18e>
ffffffffc0202c6c:	4505                	li	a0,1
ffffffffc0202c6e:	e09ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202c72:	84aa                	mv	s1,a0
ffffffffc0202c74:	cd51                	beqz	a0,ffffffffc0202d10 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c76:	0000fb97          	auipc	s7,0xf
ffffffffc0202c7a:	8dab8b93          	addi	s7,s7,-1830 # ffffffffc0211550 <pages>
ffffffffc0202c7e:	000bb503          	ld	a0,0(s7)
ffffffffc0202c82:	00003b17          	auipc	s6,0x3
ffffffffc0202c86:	70eb3b03          	ld	s6,1806(s6) # ffffffffc0206390 <error_string+0x38>
ffffffffc0202c8a:	00080a37          	lui	s4,0x80
ffffffffc0202c8e:	40a48533          	sub	a0,s1,a0
ffffffffc0202c92:	850d                	srai	a0,a0,0x3
ffffffffc0202c94:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c98:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c9a:	0009b703          	ld	a4,0(s3)
ffffffffc0202c9e:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ca0:	9552                	add	a0,a0,s4
ffffffffc0202ca2:	00c51793          	slli	a5,a0,0xc
ffffffffc0202ca6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ca8:	0532                	slli	a0,a0,0xc
ffffffffc0202caa:	08e7fd63          	bgeu	a5,a4,ffffffffc0202d44 <get_pte+0x1c2>
ffffffffc0202cae:	000ab783          	ld	a5,0(s5)
ffffffffc0202cb2:	6605                	lui	a2,0x1
ffffffffc0202cb4:	4581                	li	a1,0
ffffffffc0202cb6:	953e                	add	a0,a0,a5
ffffffffc0202cb8:	300010ef          	jal	ra,ffffffffc0203fb8 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cbc:	000bb683          	ld	a3,0(s7)
ffffffffc0202cc0:	40d486b3          	sub	a3,s1,a3
ffffffffc0202cc4:	868d                	srai	a3,a3,0x3
ffffffffc0202cc6:	036686b3          	mul	a3,a3,s6
ffffffffc0202cca:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202ccc:	06aa                	slli	a3,a3,0xa
ffffffffc0202cce:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202cd2:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202cd4:	0009b703          	ld	a4,0(s3)
ffffffffc0202cd8:	068a                	slli	a3,a3,0x2
ffffffffc0202cda:	757d                	lui	a0,0xfffff
ffffffffc0202cdc:	8ee9                	and	a3,a3,a0
ffffffffc0202cde:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202ce2:	04e7f563          	bgeu	a5,a4,ffffffffc0202d2c <get_pte+0x1aa>
ffffffffc0202ce6:	000ab503          	ld	a0,0(s5)
ffffffffc0202cea:	00c95913          	srli	s2,s2,0xc
ffffffffc0202cee:	1ff97913          	andi	s2,s2,511
ffffffffc0202cf2:	96aa                	add	a3,a3,a0
ffffffffc0202cf4:	00391513          	slli	a0,s2,0x3
ffffffffc0202cf8:	9536                	add	a0,a0,a3
}
ffffffffc0202cfa:	60a6                	ld	ra,72(sp)
ffffffffc0202cfc:	6406                	ld	s0,64(sp)
ffffffffc0202cfe:	74e2                	ld	s1,56(sp)
ffffffffc0202d00:	7942                	ld	s2,48(sp)
ffffffffc0202d02:	79a2                	ld	s3,40(sp)
ffffffffc0202d04:	7a02                	ld	s4,32(sp)
ffffffffc0202d06:	6ae2                	ld	s5,24(sp)
ffffffffc0202d08:	6b42                	ld	s6,16(sp)
ffffffffc0202d0a:	6ba2                	ld	s7,8(sp)
ffffffffc0202d0c:	6161                	addi	sp,sp,80
ffffffffc0202d0e:	8082                	ret
            return NULL;
ffffffffc0202d10:	4501                	li	a0,0
ffffffffc0202d12:	b7e5                	j	ffffffffc0202cfa <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d14:	00003617          	auipc	a2,0x3
ffffffffc0202d18:	de460613          	addi	a2,a2,-540 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0202d1c:	10200593          	li	a1,258
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	e0050513          	addi	a0,a0,-512 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0202d28:	bdafd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d2c:	00003617          	auipc	a2,0x3
ffffffffc0202d30:	dcc60613          	addi	a2,a2,-564 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0202d34:	10f00593          	li	a1,271
ffffffffc0202d38:	00003517          	auipc	a0,0x3
ffffffffc0202d3c:	de850513          	addi	a0,a0,-536 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0202d40:	bc2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d44:	86aa                	mv	a3,a0
ffffffffc0202d46:	00003617          	auipc	a2,0x3
ffffffffc0202d4a:	db260613          	addi	a2,a2,-590 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0202d4e:	10b00593          	li	a1,267
ffffffffc0202d52:	00003517          	auipc	a0,0x3
ffffffffc0202d56:	dce50513          	addi	a0,a0,-562 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0202d5a:	ba8fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d5e:	86aa                	mv	a3,a0
ffffffffc0202d60:	00003617          	auipc	a2,0x3
ffffffffc0202d64:	d9860613          	addi	a2,a2,-616 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0202d68:	0ff00593          	li	a1,255
ffffffffc0202d6c:	00003517          	auipc	a0,0x3
ffffffffc0202d70:	db450513          	addi	a0,a0,-588 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0202d74:	b8efd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202d78 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d78:	1141                	addi	sp,sp,-16
ffffffffc0202d7a:	e022                	sd	s0,0(sp)
ffffffffc0202d7c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d7e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d80:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d82:	e01ff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d86:	c011                	beqz	s0,ffffffffc0202d8a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d88:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d8a:	c511                	beqz	a0,ffffffffc0202d96 <get_page+0x1e>
ffffffffc0202d8c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d8e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d90:	0017f713          	andi	a4,a5,1
ffffffffc0202d94:	e709                	bnez	a4,ffffffffc0202d9e <get_page+0x26>
}
ffffffffc0202d96:	60a2                	ld	ra,8(sp)
ffffffffc0202d98:	6402                	ld	s0,0(sp)
ffffffffc0202d9a:	0141                	addi	sp,sp,16
ffffffffc0202d9c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d9e:	078a                	slli	a5,a5,0x2
ffffffffc0202da0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202da2:	0000e717          	auipc	a4,0xe
ffffffffc0202da6:	7a673703          	ld	a4,1958(a4) # ffffffffc0211548 <npage>
ffffffffc0202daa:	02e7f263          	bgeu	a5,a4,ffffffffc0202dce <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dae:	fff80537          	lui	a0,0xfff80
ffffffffc0202db2:	97aa                	add	a5,a5,a0
ffffffffc0202db4:	60a2                	ld	ra,8(sp)
ffffffffc0202db6:	6402                	ld	s0,0(sp)
ffffffffc0202db8:	00379513          	slli	a0,a5,0x3
ffffffffc0202dbc:	97aa                	add	a5,a5,a0
ffffffffc0202dbe:	078e                	slli	a5,a5,0x3
ffffffffc0202dc0:	0000e517          	auipc	a0,0xe
ffffffffc0202dc4:	79053503          	ld	a0,1936(a0) # ffffffffc0211550 <pages>
ffffffffc0202dc8:	953e                	add	a0,a0,a5
ffffffffc0202dca:	0141                	addi	sp,sp,16
ffffffffc0202dcc:	8082                	ret
ffffffffc0202dce:	c71ff0ef          	jal	ra,ffffffffc0202a3e <pa2page.part.0>

ffffffffc0202dd2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dd2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202dd4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dd6:	ec06                	sd	ra,24(sp)
ffffffffc0202dd8:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202dda:	da9ff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
    if (ptep != NULL) {
ffffffffc0202dde:	c511                	beqz	a0,ffffffffc0202dea <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202de0:	611c                	ld	a5,0(a0)
ffffffffc0202de2:	842a                	mv	s0,a0
ffffffffc0202de4:	0017f713          	andi	a4,a5,1
ffffffffc0202de8:	e709                	bnez	a4,ffffffffc0202df2 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202dea:	60e2                	ld	ra,24(sp)
ffffffffc0202dec:	6442                	ld	s0,16(sp)
ffffffffc0202dee:	6105                	addi	sp,sp,32
ffffffffc0202df0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202df2:	078a                	slli	a5,a5,0x2
ffffffffc0202df4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202df6:	0000e717          	auipc	a4,0xe
ffffffffc0202dfa:	75273703          	ld	a4,1874(a4) # ffffffffc0211548 <npage>
ffffffffc0202dfe:	06e7f563          	bgeu	a5,a4,ffffffffc0202e68 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e02:	fff80737          	lui	a4,0xfff80
ffffffffc0202e06:	97ba                	add	a5,a5,a4
ffffffffc0202e08:	00379513          	slli	a0,a5,0x3
ffffffffc0202e0c:	97aa                	add	a5,a5,a0
ffffffffc0202e0e:	078e                	slli	a5,a5,0x3
ffffffffc0202e10:	0000e517          	auipc	a0,0xe
ffffffffc0202e14:	74053503          	ld	a0,1856(a0) # ffffffffc0211550 <pages>
ffffffffc0202e18:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202e1a:	411c                	lw	a5,0(a0)
ffffffffc0202e1c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e20:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202e22:	cb09                	beqz	a4,ffffffffc0202e34 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e24:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e28:	12000073          	sfence.vma
}
ffffffffc0202e2c:	60e2                	ld	ra,24(sp)
ffffffffc0202e2e:	6442                	ld	s0,16(sp)
ffffffffc0202e30:	6105                	addi	sp,sp,32
ffffffffc0202e32:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e34:	100027f3          	csrr	a5,sstatus
ffffffffc0202e38:	8b89                	andi	a5,a5,2
ffffffffc0202e3a:	eb89                	bnez	a5,ffffffffc0202e4c <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202e3c:	0000e797          	auipc	a5,0xe
ffffffffc0202e40:	71c7b783          	ld	a5,1820(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202e44:	739c                	ld	a5,32(a5)
ffffffffc0202e46:	4585                	li	a1,1
ffffffffc0202e48:	9782                	jalr	a5
    if (flag) {
ffffffffc0202e4a:	bfe9                	j	ffffffffc0202e24 <page_remove+0x52>
        intr_disable();
ffffffffc0202e4c:	e42a                	sd	a0,8(sp)
ffffffffc0202e4e:	ea0fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202e52:	0000e797          	auipc	a5,0xe
ffffffffc0202e56:	7067b783          	ld	a5,1798(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202e5a:	739c                	ld	a5,32(a5)
ffffffffc0202e5c:	6522                	ld	a0,8(sp)
ffffffffc0202e5e:	4585                	li	a1,1
ffffffffc0202e60:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e62:	e86fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202e66:	bf7d                	j	ffffffffc0202e24 <page_remove+0x52>
ffffffffc0202e68:	bd7ff0ef          	jal	ra,ffffffffc0202a3e <pa2page.part.0>

ffffffffc0202e6c <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e6c:	7179                	addi	sp,sp,-48
ffffffffc0202e6e:	87b2                	mv	a5,a2
ffffffffc0202e70:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e72:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e74:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e76:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e78:	ec26                	sd	s1,24(sp)
ffffffffc0202e7a:	f406                	sd	ra,40(sp)
ffffffffc0202e7c:	e84a                	sd	s2,16(sp)
ffffffffc0202e7e:	e44e                	sd	s3,8(sp)
ffffffffc0202e80:	e052                	sd	s4,0(sp)
ffffffffc0202e82:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e84:	cffff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
    if (ptep == NULL) {
ffffffffc0202e88:	cd71                	beqz	a0,ffffffffc0202f64 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202e8a:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202e8c:	611c                	ld	a5,0(a0)
ffffffffc0202e8e:	89aa                	mv	s3,a0
ffffffffc0202e90:	0016871b          	addiw	a4,a3,1
ffffffffc0202e94:	c018                	sw	a4,0(s0)
ffffffffc0202e96:	0017f713          	andi	a4,a5,1
ffffffffc0202e9a:	e331                	bnez	a4,ffffffffc0202ede <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e9c:	0000e797          	auipc	a5,0xe
ffffffffc0202ea0:	6b47b783          	ld	a5,1716(a5) # ffffffffc0211550 <pages>
ffffffffc0202ea4:	40f407b3          	sub	a5,s0,a5
ffffffffc0202ea8:	878d                	srai	a5,a5,0x3
ffffffffc0202eaa:	00003417          	auipc	s0,0x3
ffffffffc0202eae:	4e643403          	ld	s0,1254(s0) # ffffffffc0206390 <error_string+0x38>
ffffffffc0202eb2:	028787b3          	mul	a5,a5,s0
ffffffffc0202eb6:	00080437          	lui	s0,0x80
ffffffffc0202eba:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202ebc:	07aa                	slli	a5,a5,0xa
ffffffffc0202ebe:	8cdd                	or	s1,s1,a5
ffffffffc0202ec0:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202ec4:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ec8:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202ecc:	4501                	li	a0,0
}
ffffffffc0202ece:	70a2                	ld	ra,40(sp)
ffffffffc0202ed0:	7402                	ld	s0,32(sp)
ffffffffc0202ed2:	64e2                	ld	s1,24(sp)
ffffffffc0202ed4:	6942                	ld	s2,16(sp)
ffffffffc0202ed6:	69a2                	ld	s3,8(sp)
ffffffffc0202ed8:	6a02                	ld	s4,0(sp)
ffffffffc0202eda:	6145                	addi	sp,sp,48
ffffffffc0202edc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ede:	00279713          	slli	a4,a5,0x2
ffffffffc0202ee2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ee4:	0000e797          	auipc	a5,0xe
ffffffffc0202ee8:	6647b783          	ld	a5,1636(a5) # ffffffffc0211548 <npage>
ffffffffc0202eec:	06f77e63          	bgeu	a4,a5,ffffffffc0202f68 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ef0:	fff807b7          	lui	a5,0xfff80
ffffffffc0202ef4:	973e                	add	a4,a4,a5
ffffffffc0202ef6:	0000ea17          	auipc	s4,0xe
ffffffffc0202efa:	65aa0a13          	addi	s4,s4,1626 # ffffffffc0211550 <pages>
ffffffffc0202efe:	000a3783          	ld	a5,0(s4)
ffffffffc0202f02:	00371913          	slli	s2,a4,0x3
ffffffffc0202f06:	993a                	add	s2,s2,a4
ffffffffc0202f08:	090e                	slli	s2,s2,0x3
ffffffffc0202f0a:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202f0c:	03240063          	beq	s0,s2,ffffffffc0202f2c <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202f10:	00092783          	lw	a5,0(s2)
ffffffffc0202f14:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f18:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202f1c:	cb11                	beqz	a4,ffffffffc0202f30 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202f1e:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f22:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f26:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202f2a:	bfad                	j	ffffffffc0202ea4 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202f2c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202f2e:	bf9d                	j	ffffffffc0202ea4 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f30:	100027f3          	csrr	a5,sstatus
ffffffffc0202f34:	8b89                	andi	a5,a5,2
ffffffffc0202f36:	eb91                	bnez	a5,ffffffffc0202f4a <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f38:	0000e797          	auipc	a5,0xe
ffffffffc0202f3c:	6207b783          	ld	a5,1568(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f40:	739c                	ld	a5,32(a5)
ffffffffc0202f42:	4585                	li	a1,1
ffffffffc0202f44:	854a                	mv	a0,s2
ffffffffc0202f46:	9782                	jalr	a5
    if (flag) {
ffffffffc0202f48:	bfd9                	j	ffffffffc0202f1e <page_insert+0xb2>
        intr_disable();
ffffffffc0202f4a:	da4fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202f4e:	0000e797          	auipc	a5,0xe
ffffffffc0202f52:	60a7b783          	ld	a5,1546(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f56:	739c                	ld	a5,32(a5)
ffffffffc0202f58:	4585                	li	a1,1
ffffffffc0202f5a:	854a                	mv	a0,s2
ffffffffc0202f5c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f5e:	d8afd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f62:	bf75                	j	ffffffffc0202f1e <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202f64:	5571                	li	a0,-4
ffffffffc0202f66:	b7a5                	j	ffffffffc0202ece <page_insert+0x62>
ffffffffc0202f68:	ad7ff0ef          	jal	ra,ffffffffc0202a3e <pa2page.part.0>

ffffffffc0202f6c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202f6c:	00003797          	auipc	a5,0x3
ffffffffc0202f70:	b5478793          	addi	a5,a5,-1196 # ffffffffc0205ac0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f74:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202f76:	7159                	addi	sp,sp,-112
ffffffffc0202f78:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f7a:	00003517          	auipc	a0,0x3
ffffffffc0202f7e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0205b30 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc0202f82:	0000eb97          	auipc	s7,0xe
ffffffffc0202f86:	5d6b8b93          	addi	s7,s7,1494 # ffffffffc0211558 <pmm_manager>
void pmm_init(void) {
ffffffffc0202f8a:	f486                	sd	ra,104(sp)
ffffffffc0202f8c:	f0a2                	sd	s0,96(sp)
ffffffffc0202f8e:	eca6                	sd	s1,88(sp)
ffffffffc0202f90:	e8ca                	sd	s2,80(sp)
ffffffffc0202f92:	e4ce                	sd	s3,72(sp)
ffffffffc0202f94:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f96:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202f9a:	e0d2                	sd	s4,64(sp)
ffffffffc0202f9c:	fc56                	sd	s5,56(sp)
ffffffffc0202f9e:	f062                	sd	s8,32(sp)
ffffffffc0202fa0:	ec66                	sd	s9,24(sp)
ffffffffc0202fa2:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202fa4:	916fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202fa8:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fac:	4445                	li	s0,17
ffffffffc0202fae:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202fb2:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fb4:	0000e997          	auipc	s3,0xe
ffffffffc0202fb8:	5ac98993          	addi	s3,s3,1452 # ffffffffc0211560 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202fbc:	0000e497          	auipc	s1,0xe
ffffffffc0202fc0:	58c48493          	addi	s1,s1,1420 # ffffffffc0211548 <npage>
    pmm_manager->init();
ffffffffc0202fc4:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fc6:	57f5                	li	a5,-3
ffffffffc0202fc8:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fca:	07e006b7          	lui	a3,0x7e00
ffffffffc0202fce:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202fd2:	01591593          	slli	a1,s2,0x15
ffffffffc0202fd6:	00003517          	auipc	a0,0x3
ffffffffc0202fda:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205b48 <default_pmm_manager+0x88>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fde:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fe2:	8d8fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202fe6:	00003517          	auipc	a0,0x3
ffffffffc0202fea:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205b78 <default_pmm_manager+0xb8>
ffffffffc0202fee:	8ccfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202ff2:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202ff6:	16fd                	addi	a3,a3,-1
ffffffffc0202ff8:	07e005b7          	lui	a1,0x7e00
ffffffffc0202ffc:	01591613          	slli	a2,s2,0x15
ffffffffc0203000:	00003517          	auipc	a0,0x3
ffffffffc0203004:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205b90 <default_pmm_manager+0xd0>
ffffffffc0203008:	8b2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020300c:	777d                	lui	a4,0xfffff
ffffffffc020300e:	0000f797          	auipc	a5,0xf
ffffffffc0203012:	55978793          	addi	a5,a5,1369 # ffffffffc0212567 <end+0xfff>
ffffffffc0203016:	8ff9                	and	a5,a5,a4
ffffffffc0203018:	0000eb17          	auipc	s6,0xe
ffffffffc020301c:	538b0b13          	addi	s6,s6,1336 # ffffffffc0211550 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203020:	00088737          	lui	a4,0x88
ffffffffc0203024:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203026:	00fb3023          	sd	a5,0(s6)
ffffffffc020302a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020302c:	4701                	li	a4,0
ffffffffc020302e:	4505                	li	a0,1
ffffffffc0203030:	fff805b7          	lui	a1,0xfff80
ffffffffc0203034:	a019                	j	ffffffffc020303a <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0203036:	000b3783          	ld	a5,0(s6)
ffffffffc020303a:	97b6                	add	a5,a5,a3
ffffffffc020303c:	07a1                	addi	a5,a5,8
ffffffffc020303e:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203042:	609c                	ld	a5,0(s1)
ffffffffc0203044:	0705                	addi	a4,a4,1
ffffffffc0203046:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc020304a:	00b78633          	add	a2,a5,a1
ffffffffc020304e:	fec764e3          	bltu	a4,a2,ffffffffc0203036 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203052:	000b3503          	ld	a0,0(s6)
ffffffffc0203056:	00379693          	slli	a3,a5,0x3
ffffffffc020305a:	96be                	add	a3,a3,a5
ffffffffc020305c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203060:	972a                	add	a4,a4,a0
ffffffffc0203062:	068e                	slli	a3,a3,0x3
ffffffffc0203064:	96ba                	add	a3,a3,a4
ffffffffc0203066:	c0200737          	lui	a4,0xc0200
ffffffffc020306a:	64e6e463          	bltu	a3,a4,ffffffffc02036b2 <pmm_init+0x746>
ffffffffc020306e:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0203072:	4645                	li	a2,17
ffffffffc0203074:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203076:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203078:	4ec6e263          	bltu	a3,a2,ffffffffc020355c <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020307c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203080:	0000e917          	auipc	s2,0xe
ffffffffc0203084:	4c090913          	addi	s2,s2,1216 # ffffffffc0211540 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203088:	7b9c                	ld	a5,48(a5)
ffffffffc020308a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020308c:	00003517          	auipc	a0,0x3
ffffffffc0203090:	b5450513          	addi	a0,a0,-1196 # ffffffffc0205be0 <default_pmm_manager+0x120>
ffffffffc0203094:	826fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203098:	00006697          	auipc	a3,0x6
ffffffffc020309c:	f6868693          	addi	a3,a3,-152 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02030a0:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02030a8:	62f6e163          	bltu	a3,a5,ffffffffc02036ca <pmm_init+0x75e>
ffffffffc02030ac:	0009b783          	ld	a5,0(s3)
ffffffffc02030b0:	8e9d                	sub	a3,a3,a5
ffffffffc02030b2:	0000e797          	auipc	a5,0xe
ffffffffc02030b6:	48d7b323          	sd	a3,1158(a5) # ffffffffc0211538 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030ba:	100027f3          	csrr	a5,sstatus
ffffffffc02030be:	8b89                	andi	a5,a5,2
ffffffffc02030c0:	4c079763          	bnez	a5,ffffffffc020358e <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02030c4:	000bb783          	ld	a5,0(s7)
ffffffffc02030c8:	779c                	ld	a5,40(a5)
ffffffffc02030ca:	9782                	jalr	a5
ffffffffc02030cc:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02030ce:	6098                	ld	a4,0(s1)
ffffffffc02030d0:	c80007b7          	lui	a5,0xc8000
ffffffffc02030d4:	83b1                	srli	a5,a5,0xc
ffffffffc02030d6:	62e7e663          	bltu	a5,a4,ffffffffc0203702 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02030da:	00093503          	ld	a0,0(s2)
ffffffffc02030de:	60050263          	beqz	a0,ffffffffc02036e2 <pmm_init+0x776>
ffffffffc02030e2:	03451793          	slli	a5,a0,0x34
ffffffffc02030e6:	5e079e63          	bnez	a5,ffffffffc02036e2 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02030ea:	4601                	li	a2,0
ffffffffc02030ec:	4581                	li	a1,0
ffffffffc02030ee:	c8bff0ef          	jal	ra,ffffffffc0202d78 <get_page>
ffffffffc02030f2:	66051a63          	bnez	a0,ffffffffc0203766 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02030f6:	4505                	li	a0,1
ffffffffc02030f8:	97fff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02030fc:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02030fe:	00093503          	ld	a0,0(s2)
ffffffffc0203102:	4681                	li	a3,0
ffffffffc0203104:	4601                	li	a2,0
ffffffffc0203106:	85d2                	mv	a1,s4
ffffffffc0203108:	d65ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc020310c:	62051d63          	bnez	a0,ffffffffc0203746 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203110:	00093503          	ld	a0,0(s2)
ffffffffc0203114:	4601                	li	a2,0
ffffffffc0203116:	4581                	li	a1,0
ffffffffc0203118:	a6bff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc020311c:	60050563          	beqz	a0,ffffffffc0203726 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0203120:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203122:	0017f713          	andi	a4,a5,1
ffffffffc0203126:	5e070e63          	beqz	a4,ffffffffc0203722 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020312a:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020312c:	078a                	slli	a5,a5,0x2
ffffffffc020312e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203130:	56c7ff63          	bgeu	a5,a2,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203134:	fff80737          	lui	a4,0xfff80
ffffffffc0203138:	97ba                	add	a5,a5,a4
ffffffffc020313a:	000b3683          	ld	a3,0(s6)
ffffffffc020313e:	00379713          	slli	a4,a5,0x3
ffffffffc0203142:	97ba                	add	a5,a5,a4
ffffffffc0203144:	078e                	slli	a5,a5,0x3
ffffffffc0203146:	97b6                	add	a5,a5,a3
ffffffffc0203148:	14fa18e3          	bne	s4,a5,ffffffffc0203a98 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc020314c:	000a2703          	lw	a4,0(s4)
ffffffffc0203150:	4785                	li	a5,1
ffffffffc0203152:	16f71fe3          	bne	a4,a5,ffffffffc0203ad0 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203156:	00093503          	ld	a0,0(s2)
ffffffffc020315a:	77fd                	lui	a5,0xfffff
ffffffffc020315c:	6114                	ld	a3,0(a0)
ffffffffc020315e:	068a                	slli	a3,a3,0x2
ffffffffc0203160:	8efd                	and	a3,a3,a5
ffffffffc0203162:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203166:	14c779e3          	bgeu	a4,a2,ffffffffc0203ab8 <pmm_init+0xb4c>
ffffffffc020316a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020316e:	96e2                	add	a3,a3,s8
ffffffffc0203170:	0006ba83          	ld	s5,0(a3)
ffffffffc0203174:	0a8a                	slli	s5,s5,0x2
ffffffffc0203176:	00fafab3          	and	s5,s5,a5
ffffffffc020317a:	00cad793          	srli	a5,s5,0xc
ffffffffc020317e:	66c7f463          	bgeu	a5,a2,ffffffffc02037e6 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203182:	4601                	li	a2,0
ffffffffc0203184:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203186:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203188:	9fbff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020318c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020318e:	63551c63          	bne	a0,s5,ffffffffc02037c6 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0203192:	4505                	li	a0,1
ffffffffc0203194:	8e3ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0203198:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020319a:	00093503          	ld	a0,0(s2)
ffffffffc020319e:	46d1                	li	a3,20
ffffffffc02031a0:	6605                	lui	a2,0x1
ffffffffc02031a2:	85d6                	mv	a1,s5
ffffffffc02031a4:	cc9ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc02031a8:	5c051f63          	bnez	a0,ffffffffc0203786 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031ac:	00093503          	ld	a0,0(s2)
ffffffffc02031b0:	4601                	li	a2,0
ffffffffc02031b2:	6585                	lui	a1,0x1
ffffffffc02031b4:	9cfff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc02031b8:	12050ce3          	beqz	a0,ffffffffc0203af0 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc02031bc:	611c                	ld	a5,0(a0)
ffffffffc02031be:	0107f713          	andi	a4,a5,16
ffffffffc02031c2:	72070f63          	beqz	a4,ffffffffc0203900 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc02031c6:	8b91                	andi	a5,a5,4
ffffffffc02031c8:	6e078c63          	beqz	a5,ffffffffc02038c0 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02031cc:	00093503          	ld	a0,0(s2)
ffffffffc02031d0:	611c                	ld	a5,0(a0)
ffffffffc02031d2:	8bc1                	andi	a5,a5,16
ffffffffc02031d4:	6c078663          	beqz	a5,ffffffffc02038a0 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02031d8:	000aa703          	lw	a4,0(s5)
ffffffffc02031dc:	4785                	li	a5,1
ffffffffc02031de:	5cf71463          	bne	a4,a5,ffffffffc02037a6 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02031e2:	4681                	li	a3,0
ffffffffc02031e4:	6605                	lui	a2,0x1
ffffffffc02031e6:	85d2                	mv	a1,s4
ffffffffc02031e8:	c85ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc02031ec:	66051a63          	bnez	a0,ffffffffc0203860 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02031f0:	000a2703          	lw	a4,0(s4)
ffffffffc02031f4:	4789                	li	a5,2
ffffffffc02031f6:	64f71563          	bne	a4,a5,ffffffffc0203840 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc02031fa:	000aa783          	lw	a5,0(s5)
ffffffffc02031fe:	62079163          	bnez	a5,ffffffffc0203820 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203202:	00093503          	ld	a0,0(s2)
ffffffffc0203206:	4601                	li	a2,0
ffffffffc0203208:	6585                	lui	a1,0x1
ffffffffc020320a:	979ff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc020320e:	5e050963          	beqz	a0,ffffffffc0203800 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0203212:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203214:	00177793          	andi	a5,a4,1
ffffffffc0203218:	50078563          	beqz	a5,ffffffffc0203722 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020321c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020321e:	00271793          	slli	a5,a4,0x2
ffffffffc0203222:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203224:	48d7f563          	bgeu	a5,a3,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203228:	fff806b7          	lui	a3,0xfff80
ffffffffc020322c:	97b6                	add	a5,a5,a3
ffffffffc020322e:	000b3603          	ld	a2,0(s6)
ffffffffc0203232:	00379693          	slli	a3,a5,0x3
ffffffffc0203236:	97b6                	add	a5,a5,a3
ffffffffc0203238:	078e                	slli	a5,a5,0x3
ffffffffc020323a:	97b2                	add	a5,a5,a2
ffffffffc020323c:	72fa1263          	bne	s4,a5,ffffffffc0203960 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203240:	8b41                	andi	a4,a4,16
ffffffffc0203242:	6e071f63          	bnez	a4,ffffffffc0203940 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203246:	00093503          	ld	a0,0(s2)
ffffffffc020324a:	4581                	li	a1,0
ffffffffc020324c:	b87ff0ef          	jal	ra,ffffffffc0202dd2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203250:	000a2703          	lw	a4,0(s4)
ffffffffc0203254:	4785                	li	a5,1
ffffffffc0203256:	6cf71563          	bne	a4,a5,ffffffffc0203920 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc020325a:	000aa783          	lw	a5,0(s5)
ffffffffc020325e:	78079d63          	bnez	a5,ffffffffc02039f8 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203262:	00093503          	ld	a0,0(s2)
ffffffffc0203266:	6585                	lui	a1,0x1
ffffffffc0203268:	b6bff0ef          	jal	ra,ffffffffc0202dd2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020326c:	000a2783          	lw	a5,0(s4)
ffffffffc0203270:	76079463          	bnez	a5,ffffffffc02039d8 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0203274:	000aa783          	lw	a5,0(s5)
ffffffffc0203278:	74079063          	bnez	a5,ffffffffc02039b8 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020327c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203280:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203282:	000a3783          	ld	a5,0(s4)
ffffffffc0203286:	078a                	slli	a5,a5,0x2
ffffffffc0203288:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020328a:	42c7f263          	bgeu	a5,a2,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020328e:	fff80737          	lui	a4,0xfff80
ffffffffc0203292:	973e                	add	a4,a4,a5
ffffffffc0203294:	00371793          	slli	a5,a4,0x3
ffffffffc0203298:	000b3503          	ld	a0,0(s6)
ffffffffc020329c:	97ba                	add	a5,a5,a4
ffffffffc020329e:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc02032a0:	00f50733          	add	a4,a0,a5
ffffffffc02032a4:	4314                	lw	a3,0(a4)
ffffffffc02032a6:	4705                	li	a4,1
ffffffffc02032a8:	6ee69863          	bne	a3,a4,ffffffffc0203998 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02032ac:	4037d693          	srai	a3,a5,0x3
ffffffffc02032b0:	00003c97          	auipc	s9,0x3
ffffffffc02032b4:	0e0cbc83          	ld	s9,224(s9) # ffffffffc0206390 <error_string+0x38>
ffffffffc02032b8:	039686b3          	mul	a3,a3,s9
ffffffffc02032bc:	000805b7          	lui	a1,0x80
ffffffffc02032c0:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02032c2:	00c69713          	slli	a4,a3,0xc
ffffffffc02032c6:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02032c8:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02032ca:	6ac77b63          	bgeu	a4,a2,ffffffffc0203980 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02032ce:	0009b703          	ld	a4,0(s3)
ffffffffc02032d2:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02032d4:	629c                	ld	a5,0(a3)
ffffffffc02032d6:	078a                	slli	a5,a5,0x2
ffffffffc02032d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032da:	3cc7fa63          	bgeu	a5,a2,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032de:	8f8d                	sub	a5,a5,a1
ffffffffc02032e0:	00379713          	slli	a4,a5,0x3
ffffffffc02032e4:	97ba                	add	a5,a5,a4
ffffffffc02032e6:	078e                	slli	a5,a5,0x3
ffffffffc02032e8:	953e                	add	a0,a0,a5
ffffffffc02032ea:	100027f3          	csrr	a5,sstatus
ffffffffc02032ee:	8b89                	andi	a5,a5,2
ffffffffc02032f0:	2e079963          	bnez	a5,ffffffffc02035e2 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02032f4:	000bb783          	ld	a5,0(s7)
ffffffffc02032f8:	4585                	li	a1,1
ffffffffc02032fa:	739c                	ld	a5,32(a5)
ffffffffc02032fc:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02032fe:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203302:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203304:	078a                	slli	a5,a5,0x2
ffffffffc0203306:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203308:	3ae7f363          	bgeu	a5,a4,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020330c:	fff80737          	lui	a4,0xfff80
ffffffffc0203310:	97ba                	add	a5,a5,a4
ffffffffc0203312:	000b3503          	ld	a0,0(s6)
ffffffffc0203316:	00379713          	slli	a4,a5,0x3
ffffffffc020331a:	97ba                	add	a5,a5,a4
ffffffffc020331c:	078e                	slli	a5,a5,0x3
ffffffffc020331e:	953e                	add	a0,a0,a5
ffffffffc0203320:	100027f3          	csrr	a5,sstatus
ffffffffc0203324:	8b89                	andi	a5,a5,2
ffffffffc0203326:	2a079263          	bnez	a5,ffffffffc02035ca <pmm_init+0x65e>
ffffffffc020332a:	000bb783          	ld	a5,0(s7)
ffffffffc020332e:	4585                	li	a1,1
ffffffffc0203330:	739c                	ld	a5,32(a5)
ffffffffc0203332:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203334:	00093783          	ld	a5,0(s2)
ffffffffc0203338:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc020333c:	100027f3          	csrr	a5,sstatus
ffffffffc0203340:	8b89                	andi	a5,a5,2
ffffffffc0203342:	26079a63          	bnez	a5,ffffffffc02035b6 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203346:	000bb783          	ld	a5,0(s7)
ffffffffc020334a:	779c                	ld	a5,40(a5)
ffffffffc020334c:	9782                	jalr	a5
ffffffffc020334e:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203350:	73441463          	bne	s0,s4,ffffffffc0203a78 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203354:	00003517          	auipc	a0,0x3
ffffffffc0203358:	b7450513          	addi	a0,a0,-1164 # ffffffffc0205ec8 <default_pmm_manager+0x408>
ffffffffc020335c:	d5ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203360:	100027f3          	csrr	a5,sstatus
ffffffffc0203364:	8b89                	andi	a5,a5,2
ffffffffc0203366:	22079e63          	bnez	a5,ffffffffc02035a2 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020336a:	000bb783          	ld	a5,0(s7)
ffffffffc020336e:	779c                	ld	a5,40(a5)
ffffffffc0203370:	9782                	jalr	a5
ffffffffc0203372:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203374:	6098                	ld	a4,0(s1)
ffffffffc0203376:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020337a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020337c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203380:	6a05                	lui	s4,0x1
ffffffffc0203382:	02f47c63          	bgeu	s0,a5,ffffffffc02033ba <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203386:	00c45793          	srli	a5,s0,0xc
ffffffffc020338a:	00093503          	ld	a0,0(s2)
ffffffffc020338e:	30e7f363          	bgeu	a5,a4,ffffffffc0203694 <pmm_init+0x728>
ffffffffc0203392:	0009b583          	ld	a1,0(s3)
ffffffffc0203396:	4601                	li	a2,0
ffffffffc0203398:	95a2                	add	a1,a1,s0
ffffffffc020339a:	fe8ff0ef          	jal	ra,ffffffffc0202b82 <get_pte>
ffffffffc020339e:	2c050b63          	beqz	a0,ffffffffc0203674 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02033a2:	611c                	ld	a5,0(a0)
ffffffffc02033a4:	078a                	slli	a5,a5,0x2
ffffffffc02033a6:	0157f7b3          	and	a5,a5,s5
ffffffffc02033aa:	2a879563          	bne	a5,s0,ffffffffc0203654 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02033ae:	6098                	ld	a4,0(s1)
ffffffffc02033b0:	9452                	add	s0,s0,s4
ffffffffc02033b2:	00c71793          	slli	a5,a4,0xc
ffffffffc02033b6:	fcf468e3          	bltu	s0,a5,ffffffffc0203386 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02033ba:	00093783          	ld	a5,0(s2)
ffffffffc02033be:	639c                	ld	a5,0(a5)
ffffffffc02033c0:	68079c63          	bnez	a5,ffffffffc0203a58 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc02033c4:	4505                	li	a0,1
ffffffffc02033c6:	eb0ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02033ca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02033cc:	00093503          	ld	a0,0(s2)
ffffffffc02033d0:	4699                	li	a3,6
ffffffffc02033d2:	10000613          	li	a2,256
ffffffffc02033d6:	85d6                	mv	a1,s5
ffffffffc02033d8:	a95ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc02033dc:	64051e63          	bnez	a0,ffffffffc0203a38 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02033e0:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc02033e4:	4785                	li	a5,1
ffffffffc02033e6:	62f71963          	bne	a4,a5,ffffffffc0203a18 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033ea:	00093503          	ld	a0,0(s2)
ffffffffc02033ee:	6405                	lui	s0,0x1
ffffffffc02033f0:	4699                	li	a3,6
ffffffffc02033f2:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02033f6:	85d6                	mv	a1,s5
ffffffffc02033f8:	a75ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc02033fc:	48051263          	bnez	a0,ffffffffc0203880 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0203400:	000aa703          	lw	a4,0(s5)
ffffffffc0203404:	4789                	li	a5,2
ffffffffc0203406:	74f71563          	bne	a4,a5,ffffffffc0203b50 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020340a:	00003597          	auipc	a1,0x3
ffffffffc020340e:	bf658593          	addi	a1,a1,-1034 # ffffffffc0206000 <default_pmm_manager+0x540>
ffffffffc0203412:	10000513          	li	a0,256
ffffffffc0203416:	35d000ef          	jal	ra,ffffffffc0203f72 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020341a:	10040593          	addi	a1,s0,256
ffffffffc020341e:	10000513          	li	a0,256
ffffffffc0203422:	363000ef          	jal	ra,ffffffffc0203f84 <strcmp>
ffffffffc0203426:	70051563          	bnez	a0,ffffffffc0203b30 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020342a:	000b3683          	ld	a3,0(s6)
ffffffffc020342e:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203432:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203434:	40da86b3          	sub	a3,s5,a3
ffffffffc0203438:	868d                	srai	a3,a3,0x3
ffffffffc020343a:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020343e:	609c                	ld	a5,0(s1)
ffffffffc0203440:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203442:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203444:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203448:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020344a:	52f77b63          	bgeu	a4,a5,ffffffffc0203980 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020344e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203452:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203456:	96be                	add	a3,a3,a5
ffffffffc0203458:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb98>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020345c:	2e1000ef          	jal	ra,ffffffffc0203f3c <strlen>
ffffffffc0203460:	6a051863          	bnez	a0,ffffffffc0203b10 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203464:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203468:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020346a:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020346e:	078a                	slli	a5,a5,0x2
ffffffffc0203470:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203472:	22e7fe63          	bgeu	a5,a4,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203476:	41a787b3          	sub	a5,a5,s10
ffffffffc020347a:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020347e:	96be                	add	a3,a3,a5
ffffffffc0203480:	03968cb3          	mul	s9,a3,s9
ffffffffc0203484:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203488:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020348a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020348c:	4ee47a63          	bgeu	s0,a4,ffffffffc0203980 <pmm_init+0xa14>
ffffffffc0203490:	0009b403          	ld	s0,0(s3)
ffffffffc0203494:	9436                	add	s0,s0,a3
ffffffffc0203496:	100027f3          	csrr	a5,sstatus
ffffffffc020349a:	8b89                	andi	a5,a5,2
ffffffffc020349c:	1a079163          	bnez	a5,ffffffffc020363e <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc02034a0:	000bb783          	ld	a5,0(s7)
ffffffffc02034a4:	4585                	li	a1,1
ffffffffc02034a6:	8556                	mv	a0,s5
ffffffffc02034a8:	739c                	ld	a5,32(a5)
ffffffffc02034aa:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02034ac:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02034ae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02034b0:	078a                	slli	a5,a5,0x2
ffffffffc02034b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034b4:	1ee7fd63          	bgeu	a5,a4,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02034b8:	fff80737          	lui	a4,0xfff80
ffffffffc02034bc:	97ba                	add	a5,a5,a4
ffffffffc02034be:	000b3503          	ld	a0,0(s6)
ffffffffc02034c2:	00379713          	slli	a4,a5,0x3
ffffffffc02034c6:	97ba                	add	a5,a5,a4
ffffffffc02034c8:	078e                	slli	a5,a5,0x3
ffffffffc02034ca:	953e                	add	a0,a0,a5
ffffffffc02034cc:	100027f3          	csrr	a5,sstatus
ffffffffc02034d0:	8b89                	andi	a5,a5,2
ffffffffc02034d2:	14079a63          	bnez	a5,ffffffffc0203626 <pmm_init+0x6ba>
ffffffffc02034d6:	000bb783          	ld	a5,0(s7)
ffffffffc02034da:	4585                	li	a1,1
ffffffffc02034dc:	739c                	ld	a5,32(a5)
ffffffffc02034de:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02034e0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02034e4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02034e6:	078a                	slli	a5,a5,0x2
ffffffffc02034e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034ea:	1ce7f263          	bgeu	a5,a4,ffffffffc02036ae <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02034ee:	fff80737          	lui	a4,0xfff80
ffffffffc02034f2:	97ba                	add	a5,a5,a4
ffffffffc02034f4:	000b3503          	ld	a0,0(s6)
ffffffffc02034f8:	00379713          	slli	a4,a5,0x3
ffffffffc02034fc:	97ba                	add	a5,a5,a4
ffffffffc02034fe:	078e                	slli	a5,a5,0x3
ffffffffc0203500:	953e                	add	a0,a0,a5
ffffffffc0203502:	100027f3          	csrr	a5,sstatus
ffffffffc0203506:	8b89                	andi	a5,a5,2
ffffffffc0203508:	10079363          	bnez	a5,ffffffffc020360e <pmm_init+0x6a2>
ffffffffc020350c:	000bb783          	ld	a5,0(s7)
ffffffffc0203510:	4585                	li	a1,1
ffffffffc0203512:	739c                	ld	a5,32(a5)
ffffffffc0203514:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203516:	00093783          	ld	a5,0(s2)
ffffffffc020351a:	0007b023          	sd	zero,0(a5)
ffffffffc020351e:	100027f3          	csrr	a5,sstatus
ffffffffc0203522:	8b89                	andi	a5,a5,2
ffffffffc0203524:	0c079b63          	bnez	a5,ffffffffc02035fa <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203528:	000bb783          	ld	a5,0(s7)
ffffffffc020352c:	779c                	ld	a5,40(a5)
ffffffffc020352e:	9782                	jalr	a5
ffffffffc0203530:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203532:	3a8c1763          	bne	s8,s0,ffffffffc02038e0 <pmm_init+0x974>
}
ffffffffc0203536:	7406                	ld	s0,96(sp)
ffffffffc0203538:	70a6                	ld	ra,104(sp)
ffffffffc020353a:	64e6                	ld	s1,88(sp)
ffffffffc020353c:	6946                	ld	s2,80(sp)
ffffffffc020353e:	69a6                	ld	s3,72(sp)
ffffffffc0203540:	6a06                	ld	s4,64(sp)
ffffffffc0203542:	7ae2                	ld	s5,56(sp)
ffffffffc0203544:	7b42                	ld	s6,48(sp)
ffffffffc0203546:	7ba2                	ld	s7,40(sp)
ffffffffc0203548:	7c02                	ld	s8,32(sp)
ffffffffc020354a:	6ce2                	ld	s9,24(sp)
ffffffffc020354c:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020354e:	00003517          	auipc	a0,0x3
ffffffffc0203552:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0206078 <default_pmm_manager+0x5b8>
}
ffffffffc0203556:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203558:	b63fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020355c:	6705                	lui	a4,0x1
ffffffffc020355e:	177d                	addi	a4,a4,-1
ffffffffc0203560:	96ba                	add	a3,a3,a4
ffffffffc0203562:	777d                	lui	a4,0xfffff
ffffffffc0203564:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203566:	00c75693          	srli	a3,a4,0xc
ffffffffc020356a:	14f6f263          	bgeu	a3,a5,ffffffffc02036ae <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc020356e:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203572:	95b6                	add	a1,a1,a3
ffffffffc0203574:	00359793          	slli	a5,a1,0x3
ffffffffc0203578:	97ae                	add	a5,a5,a1
ffffffffc020357a:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020357e:	40e60733          	sub	a4,a2,a4
ffffffffc0203582:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203584:	00c75593          	srli	a1,a4,0xc
ffffffffc0203588:	953e                	add	a0,a0,a5
ffffffffc020358a:	9682                	jalr	a3
}
ffffffffc020358c:	bcc5                	j	ffffffffc020307c <pmm_init+0x110>
        intr_disable();
ffffffffc020358e:	f61fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203592:	000bb783          	ld	a5,0(s7)
ffffffffc0203596:	779c                	ld	a5,40(a5)
ffffffffc0203598:	9782                	jalr	a5
ffffffffc020359a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020359c:	f4dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035a0:	b63d                	j	ffffffffc02030ce <pmm_init+0x162>
        intr_disable();
ffffffffc02035a2:	f4dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035a6:	000bb783          	ld	a5,0(s7)
ffffffffc02035aa:	779c                	ld	a5,40(a5)
ffffffffc02035ac:	9782                	jalr	a5
ffffffffc02035ae:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02035b0:	f39fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035b4:	b3c1                	j	ffffffffc0203374 <pmm_init+0x408>
        intr_disable();
ffffffffc02035b6:	f39fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035ba:	000bb783          	ld	a5,0(s7)
ffffffffc02035be:	779c                	ld	a5,40(a5)
ffffffffc02035c0:	9782                	jalr	a5
ffffffffc02035c2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02035c4:	f25fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035c8:	b361                	j	ffffffffc0203350 <pmm_init+0x3e4>
ffffffffc02035ca:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035cc:	f23fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02035d0:	000bb783          	ld	a5,0(s7)
ffffffffc02035d4:	6522                	ld	a0,8(sp)
ffffffffc02035d6:	4585                	li	a1,1
ffffffffc02035d8:	739c                	ld	a5,32(a5)
ffffffffc02035da:	9782                	jalr	a5
        intr_enable();
ffffffffc02035dc:	f0dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035e0:	bb91                	j	ffffffffc0203334 <pmm_init+0x3c8>
ffffffffc02035e2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035e4:	f0bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035e8:	000bb783          	ld	a5,0(s7)
ffffffffc02035ec:	6522                	ld	a0,8(sp)
ffffffffc02035ee:	4585                	li	a1,1
ffffffffc02035f0:	739c                	ld	a5,32(a5)
ffffffffc02035f2:	9782                	jalr	a5
        intr_enable();
ffffffffc02035f4:	ef5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035f8:	b319                	j	ffffffffc02032fe <pmm_init+0x392>
        intr_disable();
ffffffffc02035fa:	ef5fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02035fe:	000bb783          	ld	a5,0(s7)
ffffffffc0203602:	779c                	ld	a5,40(a5)
ffffffffc0203604:	9782                	jalr	a5
ffffffffc0203606:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203608:	ee1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020360c:	b71d                	j	ffffffffc0203532 <pmm_init+0x5c6>
ffffffffc020360e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203610:	edffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203614:	000bb783          	ld	a5,0(s7)
ffffffffc0203618:	6522                	ld	a0,8(sp)
ffffffffc020361a:	4585                	li	a1,1
ffffffffc020361c:	739c                	ld	a5,32(a5)
ffffffffc020361e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203620:	ec9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203624:	bdcd                	j	ffffffffc0203516 <pmm_init+0x5aa>
ffffffffc0203626:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203628:	ec7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020362c:	000bb783          	ld	a5,0(s7)
ffffffffc0203630:	6522                	ld	a0,8(sp)
ffffffffc0203632:	4585                	li	a1,1
ffffffffc0203634:	739c                	ld	a5,32(a5)
ffffffffc0203636:	9782                	jalr	a5
        intr_enable();
ffffffffc0203638:	eb1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020363c:	b555                	j	ffffffffc02034e0 <pmm_init+0x574>
        intr_disable();
ffffffffc020363e:	eb1fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203642:	000bb783          	ld	a5,0(s7)
ffffffffc0203646:	4585                	li	a1,1
ffffffffc0203648:	8556                	mv	a0,s5
ffffffffc020364a:	739c                	ld	a5,32(a5)
ffffffffc020364c:	9782                	jalr	a5
        intr_enable();
ffffffffc020364e:	e9bfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203652:	bda9                	j	ffffffffc02034ac <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203654:	00003697          	auipc	a3,0x3
ffffffffc0203658:	8d468693          	addi	a3,a3,-1836 # ffffffffc0205f28 <default_pmm_manager+0x468>
ffffffffc020365c:	00001617          	auipc	a2,0x1
ffffffffc0203660:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203664:	1ce00593          	li	a1,462
ffffffffc0203668:	00002517          	auipc	a0,0x2
ffffffffc020366c:	4b850513          	addi	a0,a0,1208 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203670:	a93fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203674:	00003697          	auipc	a3,0x3
ffffffffc0203678:	87468693          	addi	a3,a3,-1932 # ffffffffc0205ee8 <default_pmm_manager+0x428>
ffffffffc020367c:	00001617          	auipc	a2,0x1
ffffffffc0203680:	7ac60613          	addi	a2,a2,1964 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203684:	1cd00593          	li	a1,461
ffffffffc0203688:	00002517          	auipc	a0,0x2
ffffffffc020368c:	49850513          	addi	a0,a0,1176 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203690:	a73fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203694:	86a2                	mv	a3,s0
ffffffffc0203696:	00002617          	auipc	a2,0x2
ffffffffc020369a:	46260613          	addi	a2,a2,1122 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc020369e:	1cd00593          	li	a1,461
ffffffffc02036a2:	00002517          	auipc	a0,0x2
ffffffffc02036a6:	47e50513          	addi	a0,a0,1150 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02036aa:	a59fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02036ae:	b90ff0ef          	jal	ra,ffffffffc0202a3e <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02036b2:	00002617          	auipc	a2,0x2
ffffffffc02036b6:	50660613          	addi	a2,a2,1286 # ffffffffc0205bb8 <default_pmm_manager+0xf8>
ffffffffc02036ba:	07700593          	li	a1,119
ffffffffc02036be:	00002517          	auipc	a0,0x2
ffffffffc02036c2:	46250513          	addi	a0,a0,1122 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02036c6:	a3dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02036ca:	00002617          	auipc	a2,0x2
ffffffffc02036ce:	4ee60613          	addi	a2,a2,1262 # ffffffffc0205bb8 <default_pmm_manager+0xf8>
ffffffffc02036d2:	0bd00593          	li	a1,189
ffffffffc02036d6:	00002517          	auipc	a0,0x2
ffffffffc02036da:	44a50513          	addi	a0,a0,1098 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02036de:	a25fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02036e2:	00002697          	auipc	a3,0x2
ffffffffc02036e6:	53e68693          	addi	a3,a3,1342 # ffffffffc0205c20 <default_pmm_manager+0x160>
ffffffffc02036ea:	00001617          	auipc	a2,0x1
ffffffffc02036ee:	73e60613          	addi	a2,a2,1854 # ffffffffc0204e28 <commands+0x728>
ffffffffc02036f2:	19300593          	li	a1,403
ffffffffc02036f6:	00002517          	auipc	a0,0x2
ffffffffc02036fa:	42a50513          	addi	a0,a0,1066 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02036fe:	a05fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203702:	00002697          	auipc	a3,0x2
ffffffffc0203706:	4fe68693          	addi	a3,a3,1278 # ffffffffc0205c00 <default_pmm_manager+0x140>
ffffffffc020370a:	00001617          	auipc	a2,0x1
ffffffffc020370e:	71e60613          	addi	a2,a2,1822 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203712:	19200593          	li	a1,402
ffffffffc0203716:	00002517          	auipc	a0,0x2
ffffffffc020371a:	40a50513          	addi	a0,a0,1034 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020371e:	9e5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203722:	b38ff0ef          	jal	ra,ffffffffc0202a5a <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203726:	00002697          	auipc	a3,0x2
ffffffffc020372a:	58a68693          	addi	a3,a3,1418 # ffffffffc0205cb0 <default_pmm_manager+0x1f0>
ffffffffc020372e:	00001617          	auipc	a2,0x1
ffffffffc0203732:	6fa60613          	addi	a2,a2,1786 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203736:	19a00593          	li	a1,410
ffffffffc020373a:	00002517          	auipc	a0,0x2
ffffffffc020373e:	3e650513          	addi	a0,a0,998 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203742:	9c1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203746:	00002697          	auipc	a3,0x2
ffffffffc020374a:	53a68693          	addi	a3,a3,1338 # ffffffffc0205c80 <default_pmm_manager+0x1c0>
ffffffffc020374e:	00001617          	auipc	a2,0x1
ffffffffc0203752:	6da60613          	addi	a2,a2,1754 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203756:	19800593          	li	a1,408
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	3c650513          	addi	a0,a0,966 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203762:	9a1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203766:	00002697          	auipc	a3,0x2
ffffffffc020376a:	4f268693          	addi	a3,a3,1266 # ffffffffc0205c58 <default_pmm_manager+0x198>
ffffffffc020376e:	00001617          	auipc	a2,0x1
ffffffffc0203772:	6ba60613          	addi	a2,a2,1722 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203776:	19400593          	li	a1,404
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	3a650513          	addi	a0,a0,934 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203782:	981fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203786:	00002697          	auipc	a3,0x2
ffffffffc020378a:	5b268693          	addi	a3,a3,1458 # ffffffffc0205d38 <default_pmm_manager+0x278>
ffffffffc020378e:	00001617          	auipc	a2,0x1
ffffffffc0203792:	69a60613          	addi	a2,a2,1690 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203796:	1a300593          	li	a1,419
ffffffffc020379a:	00002517          	auipc	a0,0x2
ffffffffc020379e:	38650513          	addi	a0,a0,902 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02037a2:	961fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02037a6:	00002697          	auipc	a3,0x2
ffffffffc02037aa:	63268693          	addi	a3,a3,1586 # ffffffffc0205dd8 <default_pmm_manager+0x318>
ffffffffc02037ae:	00001617          	auipc	a2,0x1
ffffffffc02037b2:	67a60613          	addi	a2,a2,1658 # ffffffffc0204e28 <commands+0x728>
ffffffffc02037b6:	1a800593          	li	a1,424
ffffffffc02037ba:	00002517          	auipc	a0,0x2
ffffffffc02037be:	36650513          	addi	a0,a0,870 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02037c2:	941fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02037c6:	00002697          	auipc	a3,0x2
ffffffffc02037ca:	54a68693          	addi	a3,a3,1354 # ffffffffc0205d10 <default_pmm_manager+0x250>
ffffffffc02037ce:	00001617          	auipc	a2,0x1
ffffffffc02037d2:	65a60613          	addi	a2,a2,1626 # ffffffffc0204e28 <commands+0x728>
ffffffffc02037d6:	1a000593          	li	a1,416
ffffffffc02037da:	00002517          	auipc	a0,0x2
ffffffffc02037de:	34650513          	addi	a0,a0,838 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02037e2:	921fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02037e6:	86d6                	mv	a3,s5
ffffffffc02037e8:	00002617          	auipc	a2,0x2
ffffffffc02037ec:	31060613          	addi	a2,a2,784 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc02037f0:	19f00593          	li	a1,415
ffffffffc02037f4:	00002517          	auipc	a0,0x2
ffffffffc02037f8:	32c50513          	addi	a0,a0,812 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02037fc:	907fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203800:	00002697          	auipc	a3,0x2
ffffffffc0203804:	57068693          	addi	a3,a3,1392 # ffffffffc0205d70 <default_pmm_manager+0x2b0>
ffffffffc0203808:	00001617          	auipc	a2,0x1
ffffffffc020380c:	62060613          	addi	a2,a2,1568 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203810:	1ad00593          	li	a1,429
ffffffffc0203814:	00002517          	auipc	a0,0x2
ffffffffc0203818:	30c50513          	addi	a0,a0,780 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020381c:	8e7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203820:	00002697          	auipc	a3,0x2
ffffffffc0203824:	61868693          	addi	a3,a3,1560 # ffffffffc0205e38 <default_pmm_manager+0x378>
ffffffffc0203828:	00001617          	auipc	a2,0x1
ffffffffc020382c:	60060613          	addi	a2,a2,1536 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203830:	1ac00593          	li	a1,428
ffffffffc0203834:	00002517          	auipc	a0,0x2
ffffffffc0203838:	2ec50513          	addi	a0,a0,748 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020383c:	8c7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203840:	00002697          	auipc	a3,0x2
ffffffffc0203844:	5e068693          	addi	a3,a3,1504 # ffffffffc0205e20 <default_pmm_manager+0x360>
ffffffffc0203848:	00001617          	auipc	a2,0x1
ffffffffc020384c:	5e060613          	addi	a2,a2,1504 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203850:	1ab00593          	li	a1,427
ffffffffc0203854:	00002517          	auipc	a0,0x2
ffffffffc0203858:	2cc50513          	addi	a0,a0,716 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020385c:	8a7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203860:	00002697          	auipc	a3,0x2
ffffffffc0203864:	59068693          	addi	a3,a3,1424 # ffffffffc0205df0 <default_pmm_manager+0x330>
ffffffffc0203868:	00001617          	auipc	a2,0x1
ffffffffc020386c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203870:	1aa00593          	li	a1,426
ffffffffc0203874:	00002517          	auipc	a0,0x2
ffffffffc0203878:	2ac50513          	addi	a0,a0,684 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020387c:	887fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203880:	00002697          	auipc	a3,0x2
ffffffffc0203884:	72868693          	addi	a3,a3,1832 # ffffffffc0205fa8 <default_pmm_manager+0x4e8>
ffffffffc0203888:	00001617          	auipc	a2,0x1
ffffffffc020388c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203890:	1d800593          	li	a1,472
ffffffffc0203894:	00002517          	auipc	a0,0x2
ffffffffc0203898:	28c50513          	addi	a0,a0,652 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020389c:	867fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02038a0:	00002697          	auipc	a3,0x2
ffffffffc02038a4:	52068693          	addi	a3,a3,1312 # ffffffffc0205dc0 <default_pmm_manager+0x300>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	58060613          	addi	a2,a2,1408 # ffffffffc0204e28 <commands+0x728>
ffffffffc02038b0:	1a700593          	li	a1,423
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	26c50513          	addi	a0,a0,620 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02038bc:	847fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	4f068693          	addi	a3,a3,1264 # ffffffffc0205db0 <default_pmm_manager+0x2f0>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	56060613          	addi	a2,a2,1376 # ffffffffc0204e28 <commands+0x728>
ffffffffc02038d0:	1a600593          	li	a1,422
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	24c50513          	addi	a0,a0,588 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02038dc:	827fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02038e0:	00002697          	auipc	a3,0x2
ffffffffc02038e4:	5c868693          	addi	a3,a3,1480 # ffffffffc0205ea8 <default_pmm_manager+0x3e8>
ffffffffc02038e8:	00001617          	auipc	a2,0x1
ffffffffc02038ec:	54060613          	addi	a2,a2,1344 # ffffffffc0204e28 <commands+0x728>
ffffffffc02038f0:	1e800593          	li	a1,488
ffffffffc02038f4:	00002517          	auipc	a0,0x2
ffffffffc02038f8:	22c50513          	addi	a0,a0,556 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02038fc:	807fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203900:	00002697          	auipc	a3,0x2
ffffffffc0203904:	4a068693          	addi	a3,a3,1184 # ffffffffc0205da0 <default_pmm_manager+0x2e0>
ffffffffc0203908:	00001617          	auipc	a2,0x1
ffffffffc020390c:	52060613          	addi	a2,a2,1312 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203910:	1a500593          	li	a1,421
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	20c50513          	addi	a0,a0,524 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020391c:	fe6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203920:	00002697          	auipc	a3,0x2
ffffffffc0203924:	3d868693          	addi	a3,a3,984 # ffffffffc0205cf8 <default_pmm_manager+0x238>
ffffffffc0203928:	00001617          	auipc	a2,0x1
ffffffffc020392c:	50060613          	addi	a2,a2,1280 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203930:	1b200593          	li	a1,434
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	1ec50513          	addi	a0,a0,492 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020393c:	fc6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203940:	00002697          	auipc	a3,0x2
ffffffffc0203944:	51068693          	addi	a3,a3,1296 # ffffffffc0205e50 <default_pmm_manager+0x390>
ffffffffc0203948:	00001617          	auipc	a2,0x1
ffffffffc020394c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203950:	1af00593          	li	a1,431
ffffffffc0203954:	00002517          	auipc	a0,0x2
ffffffffc0203958:	1cc50513          	addi	a0,a0,460 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020395c:	fa6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203960:	00002697          	auipc	a3,0x2
ffffffffc0203964:	38068693          	addi	a3,a3,896 # ffffffffc0205ce0 <default_pmm_manager+0x220>
ffffffffc0203968:	00001617          	auipc	a2,0x1
ffffffffc020396c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203970:	1ae00593          	li	a1,430
ffffffffc0203974:	00002517          	auipc	a0,0x2
ffffffffc0203978:	1ac50513          	addi	a0,a0,428 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc020397c:	f86fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203980:	00002617          	auipc	a2,0x2
ffffffffc0203984:	17860613          	addi	a2,a2,376 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0203988:	06a00593          	li	a1,106
ffffffffc020398c:	00001517          	auipc	a0,0x1
ffffffffc0203990:	70c50513          	addi	a0,a0,1804 # ffffffffc0205098 <commands+0x998>
ffffffffc0203994:	f6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203998:	00002697          	auipc	a3,0x2
ffffffffc020399c:	4e868693          	addi	a3,a3,1256 # ffffffffc0205e80 <default_pmm_manager+0x3c0>
ffffffffc02039a0:	00001617          	auipc	a2,0x1
ffffffffc02039a4:	48860613          	addi	a2,a2,1160 # ffffffffc0204e28 <commands+0x728>
ffffffffc02039a8:	1b900593          	li	a1,441
ffffffffc02039ac:	00002517          	auipc	a0,0x2
ffffffffc02039b0:	17450513          	addi	a0,a0,372 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02039b4:	f4efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039b8:	00002697          	auipc	a3,0x2
ffffffffc02039bc:	48068693          	addi	a3,a3,1152 # ffffffffc0205e38 <default_pmm_manager+0x378>
ffffffffc02039c0:	00001617          	auipc	a2,0x1
ffffffffc02039c4:	46860613          	addi	a2,a2,1128 # ffffffffc0204e28 <commands+0x728>
ffffffffc02039c8:	1b700593          	li	a1,439
ffffffffc02039cc:	00002517          	auipc	a0,0x2
ffffffffc02039d0:	15450513          	addi	a0,a0,340 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02039d4:	f2efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02039d8:	00002697          	auipc	a3,0x2
ffffffffc02039dc:	49068693          	addi	a3,a3,1168 # ffffffffc0205e68 <default_pmm_manager+0x3a8>
ffffffffc02039e0:	00001617          	auipc	a2,0x1
ffffffffc02039e4:	44860613          	addi	a2,a2,1096 # ffffffffc0204e28 <commands+0x728>
ffffffffc02039e8:	1b600593          	li	a1,438
ffffffffc02039ec:	00002517          	auipc	a0,0x2
ffffffffc02039f0:	13450513          	addi	a0,a0,308 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc02039f4:	f0efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039f8:	00002697          	auipc	a3,0x2
ffffffffc02039fc:	44068693          	addi	a3,a3,1088 # ffffffffc0205e38 <default_pmm_manager+0x378>
ffffffffc0203a00:	00001617          	auipc	a2,0x1
ffffffffc0203a04:	42860613          	addi	a2,a2,1064 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203a08:	1b300593          	li	a1,435
ffffffffc0203a0c:	00002517          	auipc	a0,0x2
ffffffffc0203a10:	11450513          	addi	a0,a0,276 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203a14:	eeefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203a18:	00002697          	auipc	a3,0x2
ffffffffc0203a1c:	57868693          	addi	a3,a3,1400 # ffffffffc0205f90 <default_pmm_manager+0x4d0>
ffffffffc0203a20:	00001617          	auipc	a2,0x1
ffffffffc0203a24:	40860613          	addi	a2,a2,1032 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203a28:	1d700593          	li	a1,471
ffffffffc0203a2c:	00002517          	auipc	a0,0x2
ffffffffc0203a30:	0f450513          	addi	a0,a0,244 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203a34:	ecefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203a38:	00002697          	auipc	a3,0x2
ffffffffc0203a3c:	52068693          	addi	a3,a3,1312 # ffffffffc0205f58 <default_pmm_manager+0x498>
ffffffffc0203a40:	00001617          	auipc	a2,0x1
ffffffffc0203a44:	3e860613          	addi	a2,a2,1000 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203a48:	1d600593          	li	a1,470
ffffffffc0203a4c:	00002517          	auipc	a0,0x2
ffffffffc0203a50:	0d450513          	addi	a0,a0,212 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203a54:	eaefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203a58:	00002697          	auipc	a3,0x2
ffffffffc0203a5c:	4e868693          	addi	a3,a3,1256 # ffffffffc0205f40 <default_pmm_manager+0x480>
ffffffffc0203a60:	00001617          	auipc	a2,0x1
ffffffffc0203a64:	3c860613          	addi	a2,a2,968 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203a68:	1d200593          	li	a1,466
ffffffffc0203a6c:	00002517          	auipc	a0,0x2
ffffffffc0203a70:	0b450513          	addi	a0,a0,180 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203a74:	e8efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203a78:	00002697          	auipc	a3,0x2
ffffffffc0203a7c:	43068693          	addi	a3,a3,1072 # ffffffffc0205ea8 <default_pmm_manager+0x3e8>
ffffffffc0203a80:	00001617          	auipc	a2,0x1
ffffffffc0203a84:	3a860613          	addi	a2,a2,936 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203a88:	1c000593          	li	a1,448
ffffffffc0203a8c:	00002517          	auipc	a0,0x2
ffffffffc0203a90:	09450513          	addi	a0,a0,148 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203a94:	e6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a98:	00002697          	auipc	a3,0x2
ffffffffc0203a9c:	24868693          	addi	a3,a3,584 # ffffffffc0205ce0 <default_pmm_manager+0x220>
ffffffffc0203aa0:	00001617          	auipc	a2,0x1
ffffffffc0203aa4:	38860613          	addi	a2,a2,904 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203aa8:	19b00593          	li	a1,411
ffffffffc0203aac:	00002517          	auipc	a0,0x2
ffffffffc0203ab0:	07450513          	addi	a0,a0,116 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203ab4:	e4efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203ab8:	00002617          	auipc	a2,0x2
ffffffffc0203abc:	04060613          	addi	a2,a2,64 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0203ac0:	19e00593          	li	a1,414
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	05c50513          	addi	a0,a0,92 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203acc:	e36fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203ad0:	00002697          	auipc	a3,0x2
ffffffffc0203ad4:	22868693          	addi	a3,a3,552 # ffffffffc0205cf8 <default_pmm_manager+0x238>
ffffffffc0203ad8:	00001617          	auipc	a2,0x1
ffffffffc0203adc:	35060613          	addi	a2,a2,848 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203ae0:	19c00593          	li	a1,412
ffffffffc0203ae4:	00002517          	auipc	a0,0x2
ffffffffc0203ae8:	03c50513          	addi	a0,a0,60 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203aec:	e16fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203af0:	00002697          	auipc	a3,0x2
ffffffffc0203af4:	28068693          	addi	a3,a3,640 # ffffffffc0205d70 <default_pmm_manager+0x2b0>
ffffffffc0203af8:	00001617          	auipc	a2,0x1
ffffffffc0203afc:	33060613          	addi	a2,a2,816 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203b00:	1a400593          	li	a1,420
ffffffffc0203b04:	00002517          	auipc	a0,0x2
ffffffffc0203b08:	01c50513          	addi	a0,a0,28 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203b0c:	df6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203b10:	00002697          	auipc	a3,0x2
ffffffffc0203b14:	54068693          	addi	a3,a3,1344 # ffffffffc0206050 <default_pmm_manager+0x590>
ffffffffc0203b18:	00001617          	auipc	a2,0x1
ffffffffc0203b1c:	31060613          	addi	a2,a2,784 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203b20:	1e000593          	li	a1,480
ffffffffc0203b24:	00002517          	auipc	a0,0x2
ffffffffc0203b28:	ffc50513          	addi	a0,a0,-4 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203b2c:	dd6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203b30:	00002697          	auipc	a3,0x2
ffffffffc0203b34:	4e868693          	addi	a3,a3,1256 # ffffffffc0206018 <default_pmm_manager+0x558>
ffffffffc0203b38:	00001617          	auipc	a2,0x1
ffffffffc0203b3c:	2f060613          	addi	a2,a2,752 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203b40:	1dd00593          	li	a1,477
ffffffffc0203b44:	00002517          	auipc	a0,0x2
ffffffffc0203b48:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203b4c:	db6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203b50:	00002697          	auipc	a3,0x2
ffffffffc0203b54:	49868693          	addi	a3,a3,1176 # ffffffffc0205fe8 <default_pmm_manager+0x528>
ffffffffc0203b58:	00001617          	auipc	a2,0x1
ffffffffc0203b5c:	2d060613          	addi	a2,a2,720 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203b60:	1d900593          	li	a1,473
ffffffffc0203b64:	00002517          	auipc	a0,0x2
ffffffffc0203b68:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203b6c:	d96fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203b70 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203b70:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203b74:	8082                	ret

ffffffffc0203b76 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b76:	7179                	addi	sp,sp,-48
ffffffffc0203b78:	e84a                	sd	s2,16(sp)
ffffffffc0203b7a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203b7c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b7e:	f022                	sd	s0,32(sp)
ffffffffc0203b80:	ec26                	sd	s1,24(sp)
ffffffffc0203b82:	e44e                	sd	s3,8(sp)
ffffffffc0203b84:	f406                	sd	ra,40(sp)
ffffffffc0203b86:	84ae                	mv	s1,a1
ffffffffc0203b88:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203b8a:	eedfe0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0203b8e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203b90:	cd09                	beqz	a0,ffffffffc0203baa <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203b92:	85aa                	mv	a1,a0
ffffffffc0203b94:	86ce                	mv	a3,s3
ffffffffc0203b96:	8626                	mv	a2,s1
ffffffffc0203b98:	854a                	mv	a0,s2
ffffffffc0203b9a:	ad2ff0ef          	jal	ra,ffffffffc0202e6c <page_insert>
ffffffffc0203b9e:	ed21                	bnez	a0,ffffffffc0203bf6 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203ba0:	0000e797          	auipc	a5,0xe
ffffffffc0203ba4:	9907a783          	lw	a5,-1648(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0203ba8:	eb89                	bnez	a5,ffffffffc0203bba <pgdir_alloc_page+0x44>
}
ffffffffc0203baa:	70a2                	ld	ra,40(sp)
ffffffffc0203bac:	8522                	mv	a0,s0
ffffffffc0203bae:	7402                	ld	s0,32(sp)
ffffffffc0203bb0:	64e2                	ld	s1,24(sp)
ffffffffc0203bb2:	6942                	ld	s2,16(sp)
ffffffffc0203bb4:	69a2                	ld	s3,8(sp)
ffffffffc0203bb6:	6145                	addi	sp,sp,48
ffffffffc0203bb8:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203bba:	4681                	li	a3,0
ffffffffc0203bbc:	8622                	mv	a2,s0
ffffffffc0203bbe:	85a6                	mv	a1,s1
ffffffffc0203bc0:	0000e517          	auipc	a0,0xe
ffffffffc0203bc4:	95053503          	ld	a0,-1712(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0203bc8:	e07fd0ef          	jal	ra,ffffffffc02019ce <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203bcc:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203bce:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203bd0:	4785                	li	a5,1
ffffffffc0203bd2:	fcf70ce3          	beq	a4,a5,ffffffffc0203baa <pgdir_alloc_page+0x34>
ffffffffc0203bd6:	00002697          	auipc	a3,0x2
ffffffffc0203bda:	4c268693          	addi	a3,a3,1218 # ffffffffc0206098 <default_pmm_manager+0x5d8>
ffffffffc0203bde:	00001617          	auipc	a2,0x1
ffffffffc0203be2:	24a60613          	addi	a2,a2,586 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203be6:	17a00593          	li	a1,378
ffffffffc0203bea:	00002517          	auipc	a0,0x2
ffffffffc0203bee:	f3650513          	addi	a0,a0,-202 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203bf2:	d10fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203bf6:	100027f3          	csrr	a5,sstatus
ffffffffc0203bfa:	8b89                	andi	a5,a5,2
ffffffffc0203bfc:	eb99                	bnez	a5,ffffffffc0203c12 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203bfe:	0000e797          	auipc	a5,0xe
ffffffffc0203c02:	95a7b783          	ld	a5,-1702(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203c06:	739c                	ld	a5,32(a5)
ffffffffc0203c08:	8522                	mv	a0,s0
ffffffffc0203c0a:	4585                	li	a1,1
ffffffffc0203c0c:	9782                	jalr	a5
            return NULL;
ffffffffc0203c0e:	4401                	li	s0,0
ffffffffc0203c10:	bf69                	j	ffffffffc0203baa <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203c12:	8ddfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c16:	0000e797          	auipc	a5,0xe
ffffffffc0203c1a:	9427b783          	ld	a5,-1726(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203c1e:	739c                	ld	a5,32(a5)
ffffffffc0203c20:	8522                	mv	a0,s0
ffffffffc0203c22:	4585                	li	a1,1
ffffffffc0203c24:	9782                	jalr	a5
            return NULL;
ffffffffc0203c26:	4401                	li	s0,0
        intr_enable();
ffffffffc0203c28:	8c1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203c2c:	bfbd                	j	ffffffffc0203baa <pgdir_alloc_page+0x34>

ffffffffc0203c2e <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203c2e:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c30:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203c32:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c34:	fff50713          	addi	a4,a0,-1
ffffffffc0203c38:	17f9                	addi	a5,a5,-2
ffffffffc0203c3a:	04e7ea63          	bltu	a5,a4,ffffffffc0203c8e <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203c3e:	6785                	lui	a5,0x1
ffffffffc0203c40:	17fd                	addi	a5,a5,-1
ffffffffc0203c42:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203c44:	8131                	srli	a0,a0,0xc
ffffffffc0203c46:	e31fe0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
    assert(base != NULL);
ffffffffc0203c4a:	cd3d                	beqz	a0,ffffffffc0203cc8 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c4c:	0000e797          	auipc	a5,0xe
ffffffffc0203c50:	9047b783          	ld	a5,-1788(a5) # ffffffffc0211550 <pages>
ffffffffc0203c54:	8d1d                	sub	a0,a0,a5
ffffffffc0203c56:	00002697          	auipc	a3,0x2
ffffffffc0203c5a:	73a6b683          	ld	a3,1850(a3) # ffffffffc0206390 <error_string+0x38>
ffffffffc0203c5e:	850d                	srai	a0,a0,0x3
ffffffffc0203c60:	02d50533          	mul	a0,a0,a3
ffffffffc0203c64:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c68:	0000e717          	auipc	a4,0xe
ffffffffc0203c6c:	8e073703          	ld	a4,-1824(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c70:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c72:	00c51793          	slli	a5,a0,0xc
ffffffffc0203c76:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c78:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c7a:	02e7fa63          	bgeu	a5,a4,ffffffffc0203cae <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203c7e:	60a2                	ld	ra,8(sp)
ffffffffc0203c80:	0000e797          	auipc	a5,0xe
ffffffffc0203c84:	8e07b783          	ld	a5,-1824(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203c88:	953e                	add	a0,a0,a5
ffffffffc0203c8a:	0141                	addi	sp,sp,16
ffffffffc0203c8c:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c8e:	00002697          	auipc	a3,0x2
ffffffffc0203c92:	42268693          	addi	a3,a3,1058 # ffffffffc02060b0 <default_pmm_manager+0x5f0>
ffffffffc0203c96:	00001617          	auipc	a2,0x1
ffffffffc0203c9a:	19260613          	addi	a2,a2,402 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203c9e:	1f000593          	li	a1,496
ffffffffc0203ca2:	00002517          	auipc	a0,0x2
ffffffffc0203ca6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203caa:	c58fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203cae:	86aa                	mv	a3,a0
ffffffffc0203cb0:	00002617          	auipc	a2,0x2
ffffffffc0203cb4:	e4860613          	addi	a2,a2,-440 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0203cb8:	06a00593          	li	a1,106
ffffffffc0203cbc:	00001517          	auipc	a0,0x1
ffffffffc0203cc0:	3dc50513          	addi	a0,a0,988 # ffffffffc0205098 <commands+0x998>
ffffffffc0203cc4:	c3efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203cc8:	00002697          	auipc	a3,0x2
ffffffffc0203ccc:	40868693          	addi	a3,a3,1032 # ffffffffc02060d0 <default_pmm_manager+0x610>
ffffffffc0203cd0:	00001617          	auipc	a2,0x1
ffffffffc0203cd4:	15860613          	addi	a2,a2,344 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203cd8:	1f300593          	li	a1,499
ffffffffc0203cdc:	00002517          	auipc	a0,0x2
ffffffffc0203ce0:	e4450513          	addi	a0,a0,-444 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203ce4:	c1efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ce8 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203ce8:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203cea:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203cec:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203cee:	fff58713          	addi	a4,a1,-1
ffffffffc0203cf2:	17f9                	addi	a5,a5,-2
ffffffffc0203cf4:	0ae7ee63          	bltu	a5,a4,ffffffffc0203db0 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203cf8:	cd41                	beqz	a0,ffffffffc0203d90 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203cfa:	6785                	lui	a5,0x1
ffffffffc0203cfc:	17fd                	addi	a5,a5,-1
ffffffffc0203cfe:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203d00:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d04:	81b1                	srli	a1,a1,0xc
ffffffffc0203d06:	06f56863          	bltu	a0,a5,ffffffffc0203d76 <kfree+0x8e>
ffffffffc0203d0a:	0000e697          	auipc	a3,0xe
ffffffffc0203d0e:	8566b683          	ld	a3,-1962(a3) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203d12:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203d14:	8131                	srli	a0,a0,0xc
ffffffffc0203d16:	0000e797          	auipc	a5,0xe
ffffffffc0203d1a:	8327b783          	ld	a5,-1998(a5) # ffffffffc0211548 <npage>
ffffffffc0203d1e:	04f57a63          	bgeu	a0,a5,ffffffffc0203d72 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d22:	fff806b7          	lui	a3,0xfff80
ffffffffc0203d26:	9536                	add	a0,a0,a3
ffffffffc0203d28:	00351793          	slli	a5,a0,0x3
ffffffffc0203d2c:	953e                	add	a0,a0,a5
ffffffffc0203d2e:	050e                	slli	a0,a0,0x3
ffffffffc0203d30:	0000e797          	auipc	a5,0xe
ffffffffc0203d34:	8207b783          	ld	a5,-2016(a5) # ffffffffc0211550 <pages>
ffffffffc0203d38:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d3a:	100027f3          	csrr	a5,sstatus
ffffffffc0203d3e:	8b89                	andi	a5,a5,2
ffffffffc0203d40:	eb89                	bnez	a5,ffffffffc0203d52 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d42:	0000e797          	auipc	a5,0xe
ffffffffc0203d46:	8167b783          	ld	a5,-2026(a5) # ffffffffc0211558 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203d4a:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d4c:	739c                	ld	a5,32(a5)
}
ffffffffc0203d4e:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d50:	8782                	jr	a5
        intr_disable();
ffffffffc0203d52:	e42a                	sd	a0,8(sp)
ffffffffc0203d54:	e02e                	sd	a1,0(sp)
ffffffffc0203d56:	f98fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203d5a:	0000d797          	auipc	a5,0xd
ffffffffc0203d5e:	7fe7b783          	ld	a5,2046(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203d62:	6582                	ld	a1,0(sp)
ffffffffc0203d64:	6522                	ld	a0,8(sp)
ffffffffc0203d66:	739c                	ld	a5,32(a5)
ffffffffc0203d68:	9782                	jalr	a5
}
ffffffffc0203d6a:	60e2                	ld	ra,24(sp)
ffffffffc0203d6c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203d6e:	f7afc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203d72:	ccdfe0ef          	jal	ra,ffffffffc0202a3e <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203d76:	86aa                	mv	a3,a0
ffffffffc0203d78:	00002617          	auipc	a2,0x2
ffffffffc0203d7c:	e4060613          	addi	a2,a2,-448 # ffffffffc0205bb8 <default_pmm_manager+0xf8>
ffffffffc0203d80:	06c00593          	li	a1,108
ffffffffc0203d84:	00001517          	auipc	a0,0x1
ffffffffc0203d88:	31450513          	addi	a0,a0,788 # ffffffffc0205098 <commands+0x998>
ffffffffc0203d8c:	b76fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203d90:	00002697          	auipc	a3,0x2
ffffffffc0203d94:	35068693          	addi	a3,a3,848 # ffffffffc02060e0 <default_pmm_manager+0x620>
ffffffffc0203d98:	00001617          	auipc	a2,0x1
ffffffffc0203d9c:	09060613          	addi	a2,a2,144 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203da0:	1fa00593          	li	a1,506
ffffffffc0203da4:	00002517          	auipc	a0,0x2
ffffffffc0203da8:	d7c50513          	addi	a0,a0,-644 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203dac:	b56fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203db0:	00002697          	auipc	a3,0x2
ffffffffc0203db4:	30068693          	addi	a3,a3,768 # ffffffffc02060b0 <default_pmm_manager+0x5f0>
ffffffffc0203db8:	00001617          	auipc	a2,0x1
ffffffffc0203dbc:	07060613          	addi	a2,a2,112 # ffffffffc0204e28 <commands+0x728>
ffffffffc0203dc0:	1f900593          	li	a1,505
ffffffffc0203dc4:	00002517          	auipc	a0,0x2
ffffffffc0203dc8:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205b20 <default_pmm_manager+0x60>
ffffffffc0203dcc:	b36fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203dd0 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203dd0:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dd2:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203dd4:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dd6:	dfcfc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203dda:	cd01                	beqz	a0,ffffffffc0203df2 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ddc:	4505                	li	a0,1
ffffffffc0203dde:	dfafc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203de2:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203de4:	810d                	srli	a0,a0,0x3
ffffffffc0203de6:	0000d797          	auipc	a5,0xd
ffffffffc0203dea:	72a7bd23          	sd	a0,1850(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203dee:	0141                	addi	sp,sp,16
ffffffffc0203df0:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203df2:	00002617          	auipc	a2,0x2
ffffffffc0203df6:	2fe60613          	addi	a2,a2,766 # ffffffffc02060f0 <default_pmm_manager+0x630>
ffffffffc0203dfa:	45b5                	li	a1,13
ffffffffc0203dfc:	00002517          	auipc	a0,0x2
ffffffffc0203e00:	31450513          	addi	a0,a0,788 # ffffffffc0206110 <default_pmm_manager+0x650>
ffffffffc0203e04:	afefc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e08 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e08:	1141                	addi	sp,sp,-16
ffffffffc0203e0a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e0c:	00855793          	srli	a5,a0,0x8
ffffffffc0203e10:	c3a5                	beqz	a5,ffffffffc0203e70 <swapfs_read+0x68>
ffffffffc0203e12:	0000d717          	auipc	a4,0xd
ffffffffc0203e16:	70e73703          	ld	a4,1806(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203e1a:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e70 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e1e:	0000d617          	auipc	a2,0xd
ffffffffc0203e22:	73263603          	ld	a2,1842(a2) # ffffffffc0211550 <pages>
ffffffffc0203e26:	8d91                	sub	a1,a1,a2
ffffffffc0203e28:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e2c:	00002597          	auipc	a1,0x2
ffffffffc0203e30:	5645b583          	ld	a1,1380(a1) # ffffffffc0206390 <error_string+0x38>
ffffffffc0203e34:	02b60633          	mul	a2,a2,a1
ffffffffc0203e38:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e3c:	00002797          	auipc	a5,0x2
ffffffffc0203e40:	55c7b783          	ld	a5,1372(a5) # ffffffffc0206398 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e44:	0000d717          	auipc	a4,0xd
ffffffffc0203e48:	70473703          	ld	a4,1796(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e4c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e4e:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e52:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e54:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e56:	02e7f963          	bgeu	a5,a4,ffffffffc0203e88 <swapfs_read+0x80>
}
ffffffffc0203e5a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e5c:	0000d797          	auipc	a5,0xd
ffffffffc0203e60:	7047b783          	ld	a5,1796(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203e64:	46a1                	li	a3,8
ffffffffc0203e66:	963e                	add	a2,a2,a5
ffffffffc0203e68:	4505                	li	a0,1
}
ffffffffc0203e6a:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e6c:	d72fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203e70:	86aa                	mv	a3,a0
ffffffffc0203e72:	00002617          	auipc	a2,0x2
ffffffffc0203e76:	2b660613          	addi	a2,a2,694 # ffffffffc0206128 <default_pmm_manager+0x668>
ffffffffc0203e7a:	45d1                	li	a1,20
ffffffffc0203e7c:	00002517          	auipc	a0,0x2
ffffffffc0203e80:	29450513          	addi	a0,a0,660 # ffffffffc0206110 <default_pmm_manager+0x650>
ffffffffc0203e84:	a7efc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e88:	86b2                	mv	a3,a2
ffffffffc0203e8a:	06a00593          	li	a1,106
ffffffffc0203e8e:	00002617          	auipc	a2,0x2
ffffffffc0203e92:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0203e96:	00001517          	auipc	a0,0x1
ffffffffc0203e9a:	20250513          	addi	a0,a0,514 # ffffffffc0205098 <commands+0x998>
ffffffffc0203e9e:	a64fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ea2 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ea2:	1141                	addi	sp,sp,-16
ffffffffc0203ea4:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea6:	00855793          	srli	a5,a0,0x8
ffffffffc0203eaa:	c3a5                	beqz	a5,ffffffffc0203f0a <swapfs_write+0x68>
ffffffffc0203eac:	0000d717          	auipc	a4,0xd
ffffffffc0203eb0:	67473703          	ld	a4,1652(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203eb4:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f0a <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eb8:	0000d617          	auipc	a2,0xd
ffffffffc0203ebc:	69863603          	ld	a2,1688(a2) # ffffffffc0211550 <pages>
ffffffffc0203ec0:	8d91                	sub	a1,a1,a2
ffffffffc0203ec2:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ec6:	00002597          	auipc	a1,0x2
ffffffffc0203eca:	4ca5b583          	ld	a1,1226(a1) # ffffffffc0206390 <error_string+0x38>
ffffffffc0203ece:	02b60633          	mul	a2,a2,a1
ffffffffc0203ed2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ed6:	00002797          	auipc	a5,0x2
ffffffffc0203eda:	4c27b783          	ld	a5,1218(a5) # ffffffffc0206398 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ede:	0000d717          	auipc	a4,0xd
ffffffffc0203ee2:	66a73703          	ld	a4,1642(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ee6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ee8:	00c61793          	slli	a5,a2,0xc
ffffffffc0203eec:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203eee:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ef0:	02e7f963          	bgeu	a5,a4,ffffffffc0203f22 <swapfs_write+0x80>
}
ffffffffc0203ef4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ef6:	0000d797          	auipc	a5,0xd
ffffffffc0203efa:	66a7b783          	ld	a5,1642(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203efe:	46a1                	li	a3,8
ffffffffc0203f00:	963e                	add	a2,a2,a5
ffffffffc0203f02:	4505                	li	a0,1
}
ffffffffc0203f04:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f06:	cfcfc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203f0a:	86aa                	mv	a3,a0
ffffffffc0203f0c:	00002617          	auipc	a2,0x2
ffffffffc0203f10:	21c60613          	addi	a2,a2,540 # ffffffffc0206128 <default_pmm_manager+0x668>
ffffffffc0203f14:	45e5                	li	a1,25
ffffffffc0203f16:	00002517          	auipc	a0,0x2
ffffffffc0203f1a:	1fa50513          	addi	a0,a0,506 # ffffffffc0206110 <default_pmm_manager+0x650>
ffffffffc0203f1e:	9e4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f22:	86b2                	mv	a3,a2
ffffffffc0203f24:	06a00593          	li	a1,106
ffffffffc0203f28:	00002617          	auipc	a2,0x2
ffffffffc0203f2c:	bd060613          	addi	a2,a2,-1072 # ffffffffc0205af8 <default_pmm_manager+0x38>
ffffffffc0203f30:	00001517          	auipc	a0,0x1
ffffffffc0203f34:	16850513          	addi	a0,a0,360 # ffffffffc0205098 <commands+0x998>
ffffffffc0203f38:	9cafc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f3c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203f3c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203f40:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203f42:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203f44:	cb81                	beqz	a5,ffffffffc0203f54 <strlen+0x18>
        cnt ++;
ffffffffc0203f46:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203f48:	00a707b3          	add	a5,a4,a0
ffffffffc0203f4c:	0007c783          	lbu	a5,0(a5)
ffffffffc0203f50:	fbfd                	bnez	a5,ffffffffc0203f46 <strlen+0xa>
ffffffffc0203f52:	8082                	ret
    }
    return cnt;
}
ffffffffc0203f54:	8082                	ret

ffffffffc0203f56 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203f56:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f58:	e589                	bnez	a1,ffffffffc0203f62 <strnlen+0xc>
ffffffffc0203f5a:	a811                	j	ffffffffc0203f6e <strnlen+0x18>
        cnt ++;
ffffffffc0203f5c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f5e:	00f58863          	beq	a1,a5,ffffffffc0203f6e <strnlen+0x18>
ffffffffc0203f62:	00f50733          	add	a4,a0,a5
ffffffffc0203f66:	00074703          	lbu	a4,0(a4)
ffffffffc0203f6a:	fb6d                	bnez	a4,ffffffffc0203f5c <strnlen+0x6>
ffffffffc0203f6c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203f6e:	852e                	mv	a0,a1
ffffffffc0203f70:	8082                	ret

ffffffffc0203f72 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203f72:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203f74:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f78:	0785                	addi	a5,a5,1
ffffffffc0203f7a:	0585                	addi	a1,a1,1
ffffffffc0203f7c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203f80:	fb75                	bnez	a4,ffffffffc0203f74 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203f82:	8082                	ret

ffffffffc0203f84 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f84:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f88:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f8c:	cb89                	beqz	a5,ffffffffc0203f9e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203f8e:	0505                	addi	a0,a0,1
ffffffffc0203f90:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f92:	fee789e3          	beq	a5,a4,ffffffffc0203f84 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f96:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203f9a:	9d19                	subw	a0,a0,a4
ffffffffc0203f9c:	8082                	ret
ffffffffc0203f9e:	4501                	li	a0,0
ffffffffc0203fa0:	bfed                	j	ffffffffc0203f9a <strcmp+0x16>

ffffffffc0203fa2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203fa2:	00054783          	lbu	a5,0(a0)
ffffffffc0203fa6:	c799                	beqz	a5,ffffffffc0203fb4 <strchr+0x12>
        if (*s == c) {
ffffffffc0203fa8:	00f58763          	beq	a1,a5,ffffffffc0203fb6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203fac:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203fb0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203fb2:	fbfd                	bnez	a5,ffffffffc0203fa8 <strchr+0x6>
    }
    return NULL;
ffffffffc0203fb4:	4501                	li	a0,0
}
ffffffffc0203fb6:	8082                	ret

ffffffffc0203fb8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203fb8:	ca01                	beqz	a2,ffffffffc0203fc8 <memset+0x10>
ffffffffc0203fba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203fbc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203fbe:	0785                	addi	a5,a5,1
ffffffffc0203fc0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203fc4:	fec79de3          	bne	a5,a2,ffffffffc0203fbe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203fc8:	8082                	ret

ffffffffc0203fca <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203fca:	ca19                	beqz	a2,ffffffffc0203fe0 <memcpy+0x16>
ffffffffc0203fcc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203fce:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203fd0:	0005c703          	lbu	a4,0(a1)
ffffffffc0203fd4:	0585                	addi	a1,a1,1
ffffffffc0203fd6:	0785                	addi	a5,a5,1
ffffffffc0203fd8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203fdc:	fec59ae3          	bne	a1,a2,ffffffffc0203fd0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203fe0:	8082                	ret

ffffffffc0203fe2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fe2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fe6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fe8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203fee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ff2:	f022                	sd	s0,32(sp)
ffffffffc0203ff4:	ec26                	sd	s1,24(sp)
ffffffffc0203ff6:	e84a                	sd	s2,16(sp)
ffffffffc0203ff8:	f406                	sd	ra,40(sp)
ffffffffc0203ffa:	e44e                	sd	s3,8(sp)
ffffffffc0203ffc:	84aa                	mv	s1,a0
ffffffffc0203ffe:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204000:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204004:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204006:	03067e63          	bgeu	a2,a6,ffffffffc0204042 <printnum+0x60>
ffffffffc020400a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020400c:	00805763          	blez	s0,ffffffffc020401a <printnum+0x38>
ffffffffc0204010:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204012:	85ca                	mv	a1,s2
ffffffffc0204014:	854e                	mv	a0,s3
ffffffffc0204016:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204018:	fc65                	bnez	s0,ffffffffc0204010 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020401a:	1a02                	slli	s4,s4,0x20
ffffffffc020401c:	00002797          	auipc	a5,0x2
ffffffffc0204020:	12c78793          	addi	a5,a5,300 # ffffffffc0206148 <default_pmm_manager+0x688>
ffffffffc0204024:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204028:	9a3e                	add	s4,s4,a5
}
ffffffffc020402a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020402c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204030:	70a2                	ld	ra,40(sp)
ffffffffc0204032:	69a2                	ld	s3,8(sp)
ffffffffc0204034:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204036:	85ca                	mv	a1,s2
ffffffffc0204038:	87a6                	mv	a5,s1
}
ffffffffc020403a:	6942                	ld	s2,16(sp)
ffffffffc020403c:	64e2                	ld	s1,24(sp)
ffffffffc020403e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204040:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204042:	03065633          	divu	a2,a2,a6
ffffffffc0204046:	8722                	mv	a4,s0
ffffffffc0204048:	f9bff0ef          	jal	ra,ffffffffc0203fe2 <printnum>
ffffffffc020404c:	b7f9                	j	ffffffffc020401a <printnum+0x38>

ffffffffc020404e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020404e:	7119                	addi	sp,sp,-128
ffffffffc0204050:	f4a6                	sd	s1,104(sp)
ffffffffc0204052:	f0ca                	sd	s2,96(sp)
ffffffffc0204054:	ecce                	sd	s3,88(sp)
ffffffffc0204056:	e8d2                	sd	s4,80(sp)
ffffffffc0204058:	e4d6                	sd	s5,72(sp)
ffffffffc020405a:	e0da                	sd	s6,64(sp)
ffffffffc020405c:	fc5e                	sd	s7,56(sp)
ffffffffc020405e:	f06a                	sd	s10,32(sp)
ffffffffc0204060:	fc86                	sd	ra,120(sp)
ffffffffc0204062:	f8a2                	sd	s0,112(sp)
ffffffffc0204064:	f862                	sd	s8,48(sp)
ffffffffc0204066:	f466                	sd	s9,40(sp)
ffffffffc0204068:	ec6e                	sd	s11,24(sp)
ffffffffc020406a:	892a                	mv	s2,a0
ffffffffc020406c:	84ae                	mv	s1,a1
ffffffffc020406e:	8d32                	mv	s10,a2
ffffffffc0204070:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204072:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204076:	5b7d                	li	s6,-1
ffffffffc0204078:	00002a97          	auipc	s5,0x2
ffffffffc020407c:	104a8a93          	addi	s5,s5,260 # ffffffffc020617c <default_pmm_manager+0x6bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204080:	00002b97          	auipc	s7,0x2
ffffffffc0204084:	2d8b8b93          	addi	s7,s7,728 # ffffffffc0206358 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204088:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020408c:	001d0413          	addi	s0,s10,1
ffffffffc0204090:	01350a63          	beq	a0,s3,ffffffffc02040a4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204094:	c121                	beqz	a0,ffffffffc02040d4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204096:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204098:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020409a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020409c:	fff44503          	lbu	a0,-1(s0)
ffffffffc02040a0:	ff351ae3          	bne	a0,s3,ffffffffc0204094 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02040a8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02040ac:	4c81                	li	s9,0
ffffffffc02040ae:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02040b0:	5c7d                	li	s8,-1
ffffffffc02040b2:	5dfd                	li	s11,-1
ffffffffc02040b4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02040b8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ba:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040be:	0ff5f593          	zext.b	a1,a1
ffffffffc02040c2:	00140d13          	addi	s10,s0,1
ffffffffc02040c6:	04b56263          	bltu	a0,a1,ffffffffc020410a <vprintfmt+0xbc>
ffffffffc02040ca:	058a                	slli	a1,a1,0x2
ffffffffc02040cc:	95d6                	add	a1,a1,s5
ffffffffc02040ce:	4194                	lw	a3,0(a1)
ffffffffc02040d0:	96d6                	add	a3,a3,s5
ffffffffc02040d2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040d4:	70e6                	ld	ra,120(sp)
ffffffffc02040d6:	7446                	ld	s0,112(sp)
ffffffffc02040d8:	74a6                	ld	s1,104(sp)
ffffffffc02040da:	7906                	ld	s2,96(sp)
ffffffffc02040dc:	69e6                	ld	s3,88(sp)
ffffffffc02040de:	6a46                	ld	s4,80(sp)
ffffffffc02040e0:	6aa6                	ld	s5,72(sp)
ffffffffc02040e2:	6b06                	ld	s6,64(sp)
ffffffffc02040e4:	7be2                	ld	s7,56(sp)
ffffffffc02040e6:	7c42                	ld	s8,48(sp)
ffffffffc02040e8:	7ca2                	ld	s9,40(sp)
ffffffffc02040ea:	7d02                	ld	s10,32(sp)
ffffffffc02040ec:	6de2                	ld	s11,24(sp)
ffffffffc02040ee:	6109                	addi	sp,sp,128
ffffffffc02040f0:	8082                	ret
            padc = '0';
ffffffffc02040f2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02040f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f8:	846a                	mv	s0,s10
ffffffffc02040fa:	00140d13          	addi	s10,s0,1
ffffffffc02040fe:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204102:	0ff5f593          	zext.b	a1,a1
ffffffffc0204106:	fcb572e3          	bgeu	a0,a1,ffffffffc02040ca <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020410a:	85a6                	mv	a1,s1
ffffffffc020410c:	02500513          	li	a0,37
ffffffffc0204110:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204112:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204116:	8d22                	mv	s10,s0
ffffffffc0204118:	f73788e3          	beq	a5,s3,ffffffffc0204088 <vprintfmt+0x3a>
ffffffffc020411c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204120:	1d7d                	addi	s10,s10,-1
ffffffffc0204122:	ff379de3          	bne	a5,s3,ffffffffc020411c <vprintfmt+0xce>
ffffffffc0204126:	b78d                	j	ffffffffc0204088 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204128:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020412c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204130:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204132:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204136:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020413a:	02d86463          	bltu	a6,a3,ffffffffc0204162 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020413e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204142:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204146:	0186873b          	addw	a4,a3,s8
ffffffffc020414a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020414e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204150:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204154:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204156:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020415a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020415e:	fed870e3          	bgeu	a6,a3,ffffffffc020413e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204162:	f40ddce3          	bgez	s11,ffffffffc02040ba <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204166:	8de2                	mv	s11,s8
ffffffffc0204168:	5c7d                	li	s8,-1
ffffffffc020416a:	bf81                	j	ffffffffc02040ba <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020416c:	fffdc693          	not	a3,s11
ffffffffc0204170:	96fd                	srai	a3,a3,0x3f
ffffffffc0204172:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204176:	00144603          	lbu	a2,1(s0)
ffffffffc020417a:	2d81                	sext.w	s11,s11
ffffffffc020417c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020417e:	bf35                	j	ffffffffc02040ba <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204180:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204184:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204188:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020418a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020418c:	bfd9                	j	ffffffffc0204162 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020418e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204190:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204194:	01174463          	blt	a4,a7,ffffffffc020419c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204198:	1a088e63          	beqz	a7,ffffffffc0204354 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020419c:	000a3603          	ld	a2,0(s4)
ffffffffc02041a0:	46c1                	li	a3,16
ffffffffc02041a2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02041a4:	2781                	sext.w	a5,a5
ffffffffc02041a6:	876e                	mv	a4,s11
ffffffffc02041a8:	85a6                	mv	a1,s1
ffffffffc02041aa:	854a                	mv	a0,s2
ffffffffc02041ac:	e37ff0ef          	jal	ra,ffffffffc0203fe2 <printnum>
            break;
ffffffffc02041b0:	bde1                	j	ffffffffc0204088 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02041b2:	000a2503          	lw	a0,0(s4)
ffffffffc02041b6:	85a6                	mv	a1,s1
ffffffffc02041b8:	0a21                	addi	s4,s4,8
ffffffffc02041ba:	9902                	jalr	s2
            break;
ffffffffc02041bc:	b5f1                	j	ffffffffc0204088 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041c4:	01174463          	blt	a4,a7,ffffffffc02041cc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02041c8:	18088163          	beqz	a7,ffffffffc020434a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02041cc:	000a3603          	ld	a2,0(s4)
ffffffffc02041d0:	46a9                	li	a3,10
ffffffffc02041d2:	8a2e                	mv	s4,a1
ffffffffc02041d4:	bfc1                	j	ffffffffc02041a4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02041da:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041de:	bdf1                	j	ffffffffc02040ba <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02041e0:	85a6                	mv	a1,s1
ffffffffc02041e2:	02500513          	li	a0,37
ffffffffc02041e6:	9902                	jalr	s2
            break;
ffffffffc02041e8:	b545                	j	ffffffffc0204088 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ea:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02041ee:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041f2:	b5e1                	j	ffffffffc02040ba <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02041f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041fa:	01174463          	blt	a4,a7,ffffffffc0204202 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02041fe:	14088163          	beqz	a7,ffffffffc0204340 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204202:	000a3603          	ld	a2,0(s4)
ffffffffc0204206:	46a1                	li	a3,8
ffffffffc0204208:	8a2e                	mv	s4,a1
ffffffffc020420a:	bf69                	j	ffffffffc02041a4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020420c:	03000513          	li	a0,48
ffffffffc0204210:	85a6                	mv	a1,s1
ffffffffc0204212:	e03e                	sd	a5,0(sp)
ffffffffc0204214:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204216:	85a6                	mv	a1,s1
ffffffffc0204218:	07800513          	li	a0,120
ffffffffc020421c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020421e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204220:	6782                	ld	a5,0(sp)
ffffffffc0204222:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204224:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204228:	bfb5                	j	ffffffffc02041a4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020422a:	000a3403          	ld	s0,0(s4)
ffffffffc020422e:	008a0713          	addi	a4,s4,8
ffffffffc0204232:	e03a                	sd	a4,0(sp)
ffffffffc0204234:	14040263          	beqz	s0,ffffffffc0204378 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204238:	0fb05763          	blez	s11,ffffffffc0204326 <vprintfmt+0x2d8>
ffffffffc020423c:	02d00693          	li	a3,45
ffffffffc0204240:	0cd79163          	bne	a5,a3,ffffffffc0204302 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204244:	00044783          	lbu	a5,0(s0)
ffffffffc0204248:	0007851b          	sext.w	a0,a5
ffffffffc020424c:	cf85                	beqz	a5,ffffffffc0204284 <vprintfmt+0x236>
ffffffffc020424e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204252:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204256:	000c4563          	bltz	s8,ffffffffc0204260 <vprintfmt+0x212>
ffffffffc020425a:	3c7d                	addiw	s8,s8,-1
ffffffffc020425c:	036c0263          	beq	s8,s6,ffffffffc0204280 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204260:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204262:	0e0c8e63          	beqz	s9,ffffffffc020435e <vprintfmt+0x310>
ffffffffc0204266:	3781                	addiw	a5,a5,-32
ffffffffc0204268:	0ef47b63          	bgeu	s0,a5,ffffffffc020435e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020426c:	03f00513          	li	a0,63
ffffffffc0204270:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204272:	000a4783          	lbu	a5,0(s4)
ffffffffc0204276:	3dfd                	addiw	s11,s11,-1
ffffffffc0204278:	0a05                	addi	s4,s4,1
ffffffffc020427a:	0007851b          	sext.w	a0,a5
ffffffffc020427e:	ffe1                	bnez	a5,ffffffffc0204256 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204280:	01b05963          	blez	s11,ffffffffc0204292 <vprintfmt+0x244>
ffffffffc0204284:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204286:	85a6                	mv	a1,s1
ffffffffc0204288:	02000513          	li	a0,32
ffffffffc020428c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020428e:	fe0d9be3          	bnez	s11,ffffffffc0204284 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204292:	6a02                	ld	s4,0(sp)
ffffffffc0204294:	bbd5                	j	ffffffffc0204088 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204296:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204298:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020429c:	01174463          	blt	a4,a7,ffffffffc02042a4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02042a0:	08088d63          	beqz	a7,ffffffffc020433a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02042a4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02042a8:	0a044d63          	bltz	s0,ffffffffc0204362 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02042ac:	8622                	mv	a2,s0
ffffffffc02042ae:	8a66                	mv	s4,s9
ffffffffc02042b0:	46a9                	li	a3,10
ffffffffc02042b2:	bdcd                	j	ffffffffc02041a4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02042b4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042b8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042ba:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02042bc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042c0:	8fb5                	xor	a5,a5,a3
ffffffffc02042c2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042c6:	02d74163          	blt	a4,a3,ffffffffc02042e8 <vprintfmt+0x29a>
ffffffffc02042ca:	00369793          	slli	a5,a3,0x3
ffffffffc02042ce:	97de                	add	a5,a5,s7
ffffffffc02042d0:	639c                	ld	a5,0(a5)
ffffffffc02042d2:	cb99                	beqz	a5,ffffffffc02042e8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02042d4:	86be                	mv	a3,a5
ffffffffc02042d6:	00002617          	auipc	a2,0x2
ffffffffc02042da:	ea260613          	addi	a2,a2,-350 # ffffffffc0206178 <default_pmm_manager+0x6b8>
ffffffffc02042de:	85a6                	mv	a1,s1
ffffffffc02042e0:	854a                	mv	a0,s2
ffffffffc02042e2:	0ce000ef          	jal	ra,ffffffffc02043b0 <printfmt>
ffffffffc02042e6:	b34d                	j	ffffffffc0204088 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042e8:	00002617          	auipc	a2,0x2
ffffffffc02042ec:	e8060613          	addi	a2,a2,-384 # ffffffffc0206168 <default_pmm_manager+0x6a8>
ffffffffc02042f0:	85a6                	mv	a1,s1
ffffffffc02042f2:	854a                	mv	a0,s2
ffffffffc02042f4:	0bc000ef          	jal	ra,ffffffffc02043b0 <printfmt>
ffffffffc02042f8:	bb41                	j	ffffffffc0204088 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02042fa:	00002417          	auipc	s0,0x2
ffffffffc02042fe:	e6640413          	addi	s0,s0,-410 # ffffffffc0206160 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204302:	85e2                	mv	a1,s8
ffffffffc0204304:	8522                	mv	a0,s0
ffffffffc0204306:	e43e                	sd	a5,8(sp)
ffffffffc0204308:	c4fff0ef          	jal	ra,ffffffffc0203f56 <strnlen>
ffffffffc020430c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204310:	01b05b63          	blez	s11,ffffffffc0204326 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204314:	67a2                	ld	a5,8(sp)
ffffffffc0204316:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020431a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020431c:	85a6                	mv	a1,s1
ffffffffc020431e:	8552                	mv	a0,s4
ffffffffc0204320:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204322:	fe0d9ce3          	bnez	s11,ffffffffc020431a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204326:	00044783          	lbu	a5,0(s0)
ffffffffc020432a:	00140a13          	addi	s4,s0,1
ffffffffc020432e:	0007851b          	sext.w	a0,a5
ffffffffc0204332:	d3a5                	beqz	a5,ffffffffc0204292 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204334:	05e00413          	li	s0,94
ffffffffc0204338:	bf39                	j	ffffffffc0204256 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020433a:	000a2403          	lw	s0,0(s4)
ffffffffc020433e:	b7ad                	j	ffffffffc02042a8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204340:	000a6603          	lwu	a2,0(s4)
ffffffffc0204344:	46a1                	li	a3,8
ffffffffc0204346:	8a2e                	mv	s4,a1
ffffffffc0204348:	bdb1                	j	ffffffffc02041a4 <vprintfmt+0x156>
ffffffffc020434a:	000a6603          	lwu	a2,0(s4)
ffffffffc020434e:	46a9                	li	a3,10
ffffffffc0204350:	8a2e                	mv	s4,a1
ffffffffc0204352:	bd89                	j	ffffffffc02041a4 <vprintfmt+0x156>
ffffffffc0204354:	000a6603          	lwu	a2,0(s4)
ffffffffc0204358:	46c1                	li	a3,16
ffffffffc020435a:	8a2e                	mv	s4,a1
ffffffffc020435c:	b5a1                	j	ffffffffc02041a4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020435e:	9902                	jalr	s2
ffffffffc0204360:	bf09                	j	ffffffffc0204272 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204362:	85a6                	mv	a1,s1
ffffffffc0204364:	02d00513          	li	a0,45
ffffffffc0204368:	e03e                	sd	a5,0(sp)
ffffffffc020436a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020436c:	6782                	ld	a5,0(sp)
ffffffffc020436e:	8a66                	mv	s4,s9
ffffffffc0204370:	40800633          	neg	a2,s0
ffffffffc0204374:	46a9                	li	a3,10
ffffffffc0204376:	b53d                	j	ffffffffc02041a4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204378:	03b05163          	blez	s11,ffffffffc020439a <vprintfmt+0x34c>
ffffffffc020437c:	02d00693          	li	a3,45
ffffffffc0204380:	f6d79de3          	bne	a5,a3,ffffffffc02042fa <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204384:	00002417          	auipc	s0,0x2
ffffffffc0204388:	ddc40413          	addi	s0,s0,-548 # ffffffffc0206160 <default_pmm_manager+0x6a0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020438c:	02800793          	li	a5,40
ffffffffc0204390:	02800513          	li	a0,40
ffffffffc0204394:	00140a13          	addi	s4,s0,1
ffffffffc0204398:	bd6d                	j	ffffffffc0204252 <vprintfmt+0x204>
ffffffffc020439a:	00002a17          	auipc	s4,0x2
ffffffffc020439e:	dc7a0a13          	addi	s4,s4,-569 # ffffffffc0206161 <default_pmm_manager+0x6a1>
ffffffffc02043a2:	02800513          	li	a0,40
ffffffffc02043a6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043aa:	05e00413          	li	s0,94
ffffffffc02043ae:	b565                	j	ffffffffc0204256 <vprintfmt+0x208>

ffffffffc02043b0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02043b2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043b8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043ba:	ec06                	sd	ra,24(sp)
ffffffffc02043bc:	f83a                	sd	a4,48(sp)
ffffffffc02043be:	fc3e                	sd	a5,56(sp)
ffffffffc02043c0:	e0c2                	sd	a6,64(sp)
ffffffffc02043c2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043c4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043c6:	c89ff0ef          	jal	ra,ffffffffc020404e <vprintfmt>
}
ffffffffc02043ca:	60e2                	ld	ra,24(sp)
ffffffffc02043cc:	6161                	addi	sp,sp,80
ffffffffc02043ce:	8082                	ret

ffffffffc02043d0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043d0:	715d                	addi	sp,sp,-80
ffffffffc02043d2:	e486                	sd	ra,72(sp)
ffffffffc02043d4:	e0a6                	sd	s1,64(sp)
ffffffffc02043d6:	fc4a                	sd	s2,56(sp)
ffffffffc02043d8:	f84e                	sd	s3,48(sp)
ffffffffc02043da:	f452                	sd	s4,40(sp)
ffffffffc02043dc:	f056                	sd	s5,32(sp)
ffffffffc02043de:	ec5a                	sd	s6,24(sp)
ffffffffc02043e0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02043e2:	c901                	beqz	a0,ffffffffc02043f2 <readline+0x22>
ffffffffc02043e4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043e6:	00002517          	auipc	a0,0x2
ffffffffc02043ea:	d9250513          	addi	a0,a0,-622 # ffffffffc0206178 <default_pmm_manager+0x6b8>
ffffffffc02043ee:	ccdfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02043f2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043f4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043f6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043f8:	4aa9                	li	s5,10
ffffffffc02043fa:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02043fc:	0000db97          	auipc	s7,0xd
ffffffffc0204400:	cfcb8b93          	addi	s7,s7,-772 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204404:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204408:	cebfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020440c:	00054a63          	bltz	a0,ffffffffc0204420 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204410:	00a95a63          	bge	s2,a0,ffffffffc0204424 <readline+0x54>
ffffffffc0204414:	029a5263          	bge	s4,s1,ffffffffc0204438 <readline+0x68>
        c = getchar();
ffffffffc0204418:	cdbfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020441c:	fe055ae3          	bgez	a0,ffffffffc0204410 <readline+0x40>
            return NULL;
ffffffffc0204420:	4501                	li	a0,0
ffffffffc0204422:	a091                	j	ffffffffc0204466 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204424:	03351463          	bne	a0,s3,ffffffffc020444c <readline+0x7c>
ffffffffc0204428:	e8a9                	bnez	s1,ffffffffc020447a <readline+0xaa>
        c = getchar();
ffffffffc020442a:	cc9fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020442e:	fe0549e3          	bltz	a0,ffffffffc0204420 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204432:	fea959e3          	bge	s2,a0,ffffffffc0204424 <readline+0x54>
ffffffffc0204436:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204438:	e42a                	sd	a0,8(sp)
ffffffffc020443a:	cb7fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020443e:	6522                	ld	a0,8(sp)
ffffffffc0204440:	009b87b3          	add	a5,s7,s1
ffffffffc0204444:	2485                	addiw	s1,s1,1
ffffffffc0204446:	00a78023          	sb	a0,0(a5)
ffffffffc020444a:	bf7d                	j	ffffffffc0204408 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020444c:	01550463          	beq	a0,s5,ffffffffc0204454 <readline+0x84>
ffffffffc0204450:	fb651ce3          	bne	a0,s6,ffffffffc0204408 <readline+0x38>
            cputchar(c);
ffffffffc0204454:	c9dfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204458:	0000d517          	auipc	a0,0xd
ffffffffc020445c:	ca050513          	addi	a0,a0,-864 # ffffffffc02110f8 <buf>
ffffffffc0204460:	94aa                	add	s1,s1,a0
ffffffffc0204462:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204466:	60a6                	ld	ra,72(sp)
ffffffffc0204468:	6486                	ld	s1,64(sp)
ffffffffc020446a:	7962                	ld	s2,56(sp)
ffffffffc020446c:	79c2                	ld	s3,48(sp)
ffffffffc020446e:	7a22                	ld	s4,40(sp)
ffffffffc0204470:	7a82                	ld	s5,32(sp)
ffffffffc0204472:	6b62                	ld	s6,24(sp)
ffffffffc0204474:	6bc2                	ld	s7,16(sp)
ffffffffc0204476:	6161                	addi	sp,sp,80
ffffffffc0204478:	8082                	ret
            cputchar(c);
ffffffffc020447a:	4521                	li	a0,8
ffffffffc020447c:	c75fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204480:	34fd                	addiw	s1,s1,-1
ffffffffc0204482:	b759                	j	ffffffffc0204408 <readline+0x38>

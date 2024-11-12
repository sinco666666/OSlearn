
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
ffffffffc020003e:	52660613          	addi	a2,a2,1318 # ffffffffc0211560 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	65b030ef          	jal	ra,ffffffffc0203ea4 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	32258593          	addi	a1,a1,802 # ffffffffc0204370 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	33a50513          	addi	a0,a0,826 # ffffffffc0204390 <etext+0x20>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	5f3020ef          	jal	ra,ffffffffc0202e58 <pmm_init>

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
ffffffffc02000ae:	68d030ef          	jal	ra,ffffffffc0203f3a <vprintfmt>
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
ffffffffc02000e4:	657030ef          	jal	ra,ffffffffc0203f3a <vprintfmt>
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
ffffffffc0200106:	3e630313          	addi	t1,t1,998 # ffffffffc02114e8 <is_panic>
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
ffffffffc0200134:	26850513          	addi	a0,a0,616 # ffffffffc0204398 <etext+0x28>
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
ffffffffc020014a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205cb8 <default_pmm_manager+0x4e0>
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
ffffffffc0200164:	25850513          	addi	a0,a0,600 # ffffffffc02043b8 <etext+0x48>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	26250513          	addi	a0,a0,610 # ffffffffc02043d8 <etext+0x68>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	1ee58593          	addi	a1,a1,494 # ffffffffc0204370 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	26e50513          	addi	a0,a0,622 # ffffffffc02043f8 <etext+0x88>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	27a50513          	addi	a0,a0,634 # ffffffffc0204418 <etext+0xa8>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3b658593          	addi	a1,a1,950 # ffffffffc0211560 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	28650513          	addi	a0,a0,646 # ffffffffc0204438 <etext+0xc8>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7a158593          	addi	a1,a1,1953 # ffffffffc021195f <end+0x3ff>
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
ffffffffc02001e4:	27850513          	addi	a0,a0,632 # ffffffffc0204458 <etext+0xe8>
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
ffffffffc02001f2:	29a60613          	addi	a2,a2,666 # ffffffffc0204488 <etext+0x118>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	2a650513          	addi	a0,a0,678 # ffffffffc02044a0 <etext+0x130>
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
ffffffffc020020e:	2ae60613          	addi	a2,a2,686 # ffffffffc02044b8 <etext+0x148>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	2c658593          	addi	a1,a1,710 # ffffffffc02044d8 <etext+0x168>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	2c650513          	addi	a0,a0,710 # ffffffffc02044e0 <etext+0x170>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	2c860613          	addi	a2,a2,712 # ffffffffc02044f0 <etext+0x180>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	2e858593          	addi	a1,a1,744 # ffffffffc0204518 <etext+0x1a8>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	2a850513          	addi	a0,a0,680 # ffffffffc02044e0 <etext+0x170>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	2e460613          	addi	a2,a2,740 # ffffffffc0204528 <etext+0x1b8>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	2fc58593          	addi	a1,a1,764 # ffffffffc0204548 <etext+0x1d8>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	28c50513          	addi	a0,a0,652 # ffffffffc02044e0 <etext+0x170>
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
ffffffffc0200292:	2ca50513          	addi	a0,a0,714 # ffffffffc0204558 <etext+0x1e8>
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
ffffffffc02002b4:	2d050513          	addi	a0,a0,720 # ffffffffc0204580 <etext+0x210>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	322c0c13          	addi	s8,s8,802 # ffffffffc02045e8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	0aa90913          	addi	s2,s2,170 # ffffffffc0205378 <commands+0xd90>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	2d248493          	addi	s1,s1,722 # ffffffffc02045a8 <etext+0x238>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	2d0b0b13          	addi	s6,s6,720 # ffffffffc02045b0 <etext+0x240>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	1f0a0a13          	addi	s4,s4,496 # ffffffffc02044d8 <etext+0x168>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	7c9030ef          	jal	ra,ffffffffc02042bc <readline>
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
ffffffffc020030e:	2ded0d13          	addi	s10,s10,734 # ffffffffc02045e8 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	359030ef          	jal	ra,ffffffffc0203e70 <strcmp>
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
ffffffffc020032c:	345030ef          	jal	ra,ffffffffc0203e70 <strcmp>
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
ffffffffc020036a:	325030ef          	jal	ra,ffffffffc0203e8e <strchr>
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
ffffffffc02003a8:	2e7030ef          	jal	ra,ffffffffc0203e8e <strchr>
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
ffffffffc02003c6:	20e50513          	addi	a0,a0,526 # ffffffffc02045d0 <etext+0x260>
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
ffffffffc02003f6:	2c1030ef          	jal	ra,ffffffffc0203eb6 <memcpy>
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
ffffffffc020041a:	29d030ef          	jal	ra,ffffffffc0203eb6 <memcpy>
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
ffffffffc0200430:	0cf73623          	sd	a5,204(a4) # ffffffffc02114f8 <timebase>
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
ffffffffc0200450:	1e450513          	addi	a0,a0,484 # ffffffffc0204630 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0807be23          	sd	zero,156(a5) # ffffffffc02114f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0967b783          	ld	a5,150(a5) # ffffffffc02114f8 <timebase>
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
ffffffffc0200528:	12c50513          	addi	a0,a0,300 # ffffffffc0204650 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fd053503          	ld	a0,-48(a0) # ffffffffc0211500 <check_mm_struct>
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
ffffffffc0200550:	12460613          	addi	a2,a2,292 # ffffffffc0204670 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	13050513          	addi	a0,a0,304 # ffffffffc0204688 <commands+0xa0>
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
ffffffffc020058e:	11650513          	addi	a0,a0,278 # ffffffffc02046a0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	11e50513          	addi	a0,a0,286 # ffffffffc02046b8 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	12850513          	addi	a0,a0,296 # ffffffffc02046d0 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	13250513          	addi	a0,a0,306 # ffffffffc02046e8 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	13c50513          	addi	a0,a0,316 # ffffffffc0204700 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	14650513          	addi	a0,a0,326 # ffffffffc0204718 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	15050513          	addi	a0,a0,336 # ffffffffc0204730 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	15a50513          	addi	a0,a0,346 # ffffffffc0204748 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	16450513          	addi	a0,a0,356 # ffffffffc0204760 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	16e50513          	addi	a0,a0,366 # ffffffffc0204778 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	17850513          	addi	a0,a0,376 # ffffffffc0204790 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	18250513          	addi	a0,a0,386 # ffffffffc02047a8 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	18c50513          	addi	a0,a0,396 # ffffffffc02047c0 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	19650513          	addi	a0,a0,406 # ffffffffc02047d8 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	1a050513          	addi	a0,a0,416 # ffffffffc02047f0 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	1aa50513          	addi	a0,a0,426 # ffffffffc0204808 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	1b450513          	addi	a0,a0,436 # ffffffffc0204820 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	1be50513          	addi	a0,a0,446 # ffffffffc0204838 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	1c850513          	addi	a0,a0,456 # ffffffffc0204850 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	1d250513          	addi	a0,a0,466 # ffffffffc0204868 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	1dc50513          	addi	a0,a0,476 # ffffffffc0204880 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	1e650513          	addi	a0,a0,486 # ffffffffc0204898 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	1f050513          	addi	a0,a0,496 # ffffffffc02048b0 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	1fa50513          	addi	a0,a0,506 # ffffffffc02048c8 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	20450513          	addi	a0,a0,516 # ffffffffc02048e0 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	20e50513          	addi	a0,a0,526 # ffffffffc02048f8 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	21850513          	addi	a0,a0,536 # ffffffffc0204910 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	22250513          	addi	a0,a0,546 # ffffffffc0204928 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	22c50513          	addi	a0,a0,556 # ffffffffc0204940 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	23650513          	addi	a0,a0,566 # ffffffffc0204958 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	24050513          	addi	a0,a0,576 # ffffffffc0204970 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	24650513          	addi	a0,a0,582 # ffffffffc0204988 <commands+0x3a0>
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
ffffffffc020075a:	24a50513          	addi	a0,a0,586 # ffffffffc02049a0 <commands+0x3b8>
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
ffffffffc0200772:	24a50513          	addi	a0,a0,586 # ffffffffc02049b8 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	25250513          	addi	a0,a0,594 # ffffffffc02049d0 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	25a50513          	addi	a0,a0,602 # ffffffffc02049e8 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	25e50513          	addi	a0,a0,606 # ffffffffc0204a00 <commands+0x418>
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
ffffffffc02007c2:	30a70713          	addi	a4,a4,778 # ffffffffc0204ac8 <commands+0x4e0>
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
ffffffffc02007d4:	2a850513          	addi	a0,a0,680 # ffffffffc0204a78 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	27c50513          	addi	a0,a0,636 # ffffffffc0204a58 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	23050513          	addi	a0,a0,560 # ffffffffc0204a18 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	24450513          	addi	a0,a0,580 # ffffffffc0204a38 <commands+0x450>
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
ffffffffc020080c:	ce868693          	addi	a3,a3,-792 # ffffffffc02114f0 <ticks>
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
ffffffffc020082a:	28250513          	addi	a0,a0,642 # ffffffffc0204aa8 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	25e50513          	addi	a0,a0,606 # ffffffffc0204a98 <commands+0x4b0>
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
ffffffffc0200860:	45470713          	addi	a4,a4,1108 # ffffffffc0204cb0 <commands+0x6c8>
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
ffffffffc0200872:	42a50513          	addi	a0,a0,1066 # ffffffffc0204c98 <commands+0x6b0>
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
ffffffffc0200894:	26850513          	addi	a0,a0,616 # ffffffffc0204af8 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	27450513          	addi	a0,a0,628 # ffffffffc0204b18 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	28a50513          	addi	a0,a0,650 # ffffffffc0204b38 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	29850513          	addi	a0,a0,664 # ffffffffc0204b50 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	29e50513          	addi	a0,a0,670 # ffffffffc0204b60 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	2b450513          	addi	a0,a0,692 # ffffffffc0204b80 <commands+0x598>
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
ffffffffc02008ee:	2ae60613          	addi	a2,a2,686 # ffffffffc0204b98 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	d9250513          	addi	a0,a0,-622 # ffffffffc0204688 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	2b650513          	addi	a0,a0,694 # ffffffffc0204bb8 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	2c450513          	addi	a0,a0,708 # ffffffffc0204bd0 <commands+0x5e8>
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
ffffffffc020092e:	26e60613          	addi	a2,a2,622 # ffffffffc0204b98 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	d5250513          	addi	a0,a0,-686 # ffffffffc0204688 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	2a650513          	addi	a0,a0,678 # ffffffffc0204be8 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	2bc50513          	addi	a0,a0,700 # ffffffffc0204c08 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	2d250513          	addi	a0,a0,722 # ffffffffc0204c28 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	2e850513          	addi	a0,a0,744 # ffffffffc0204c48 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204c68 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	30c50513          	addi	a0,a0,780 # ffffffffc0204c80 <commands+0x698>
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
ffffffffc0200998:	20460613          	addi	a2,a2,516 # ffffffffc0204b98 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	ce850513          	addi	a0,a0,-792 # ffffffffc0204688 <commands+0xa0>
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
ffffffffc02009c4:	1d860613          	addi	a2,a2,472 # ffffffffc0204b98 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0204688 <commands+0xa0>
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
ffffffffc0200ab6:	23e68693          	addi	a3,a3,574 # ffffffffc0204cf0 <commands+0x708>
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	25660613          	addi	a2,a2,598 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200ac2:	07d00593          	li	a1,125
ffffffffc0200ac6:	00004517          	auipc	a0,0x4
ffffffffc0200aca:	26250513          	addi	a0,a0,610 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0200ade:	03c030ef          	jal	ra,ffffffffc0203b1a <kmalloc>
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
ffffffffc0200afa:	a2a7a783          	lw	a5,-1494(a5) # ffffffffc0211520 <swap_init_ok>
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
ffffffffc0200b30:	7eb020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
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
ffffffffc0200bfe:	13e68693          	addi	a3,a3,318 # ffffffffc0204d38 <commands+0x750>
ffffffffc0200c02:	00004617          	auipc	a2,0x4
ffffffffc0200c06:	10e60613          	addi	a2,a2,270 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200c0a:	08400593          	li	a1,132
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	11a50513          	addi	a0,a0,282 # ffffffffc0204d28 <commands+0x740>
ffffffffc0200c16:	cecff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	15e68693          	addi	a3,a3,350 # ffffffffc0204d78 <commands+0x790>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	0ee60613          	addi	a2,a2,238 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200c2a:	07c00593          	li	a1,124
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	0fa50513          	addi	a0,a0,250 # ffffffffc0204d28 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	11e68693          	addi	a3,a3,286 # ffffffffc0204d58 <commands+0x770>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	0ce60613          	addi	a2,a2,206 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200c4a:	07b00593          	li	a1,123
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	0da50513          	addi	a0,a0,218 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0200c76:	75f020ef          	jal	ra,ffffffffc0203bd4 <kfree>
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
ffffffffc0200c8c:	7490206f          	j	ffffffffc0203bd4 <kfree>

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
ffffffffc0200ca4:	591010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0200ca8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200caa:	58b010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0200cae:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cb0:	03000513          	li	a0,48
ffffffffc0200cb4:	667020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
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
ffffffffc0200cd0:	8547a783          	lw	a5,-1964(a5) # ffffffffc0211520 <swap_init_ok>
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
ffffffffc0200cf8:	623020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d02:	f165                	bnez	a0,ffffffffc0200ce2 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d04:	00004697          	auipc	a3,0x4
ffffffffc0200d08:	2c468693          	addi	a3,a3,708 # ffffffffc0204fc8 <commands+0x9e0>
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	00460613          	addi	a2,a2,4 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200d14:	0ce00593          	li	a1,206
ffffffffc0200d18:	00004517          	auipc	a0,0x4
ffffffffc0200d1c:	01050513          	addi	a0,a0,16 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0200d4c:	5cf020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
ffffffffc0200d50:	85aa                	mv	a1,a0
ffffffffc0200d52:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d56:	fd79                	bnez	a0,ffffffffc0200d34 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	27068693          	addi	a3,a3,624 # ffffffffc0204fc8 <commands+0x9e0>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	fb060613          	addi	a2,a2,-80 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200d68:	0d400593          	li	a1,212
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	fbc50513          	addi	a0,a0,-68 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0200e30:	06c50513          	addi	a0,a0,108 # ffffffffc0204e98 <commands+0x8b0>
ffffffffc0200e34:	a86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	08868693          	addi	a3,a3,136 # ffffffffc0204ec0 <commands+0x8d8>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	ed060613          	addi	a2,a2,-304 # ffffffffc0204d10 <commands+0x728>
ffffffffc0200e48:	0f600593          	li	a1,246
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	edc50513          	addi	a0,a0,-292 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0200e6e:	567020ef          	jal	ra,ffffffffc0203bd4 <kfree>
    return listelm->next;
ffffffffc0200e72:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e74:	fea496e3          	bne	s1,a0,ffffffffc0200e60 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e78:	03000593          	li	a1,48
ffffffffc0200e7c:	8526                	mv	a0,s1
ffffffffc0200e7e:	557020ef          	jal	ra,ffffffffc0203bd4 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e82:	3b3010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0200e86:	3caa1163          	bne	s4,a0,ffffffffc0201248 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e8a:	00004517          	auipc	a0,0x4
ffffffffc0200e8e:	07650513          	addi	a0,a0,118 # ffffffffc0204f00 <commands+0x918>
ffffffffc0200e92:	a28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e96:	39f010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0200e9a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e9c:	03000513          	li	a0,48
ffffffffc0200ea0:	47b020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
ffffffffc0200ea4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ea6:	2a050163          	beqz	a0,ffffffffc0201148 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eaa:	00010797          	auipc	a5,0x10
ffffffffc0200eae:	6767a783          	lw	a5,1654(a5) # ffffffffc0211520 <swap_init_ok>
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
ffffffffc0200ece:	66e93903          	ld	s2,1646(s2) # ffffffffc0211538 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ed2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	62873523          	sd	s0,1578(a4) # ffffffffc0211500 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200ede:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200ee2:	24079363          	bnez	a5,ffffffffc0201128 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ee6:	03000513          	li	a0,48
ffffffffc0200eea:	431020ef          	jal	ra,ffffffffc0203b1a <kmalloc>
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
ffffffffc0200f50:	56f010ef          	jal	ra,ffffffffc0202cbe <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f54:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f58:	00010717          	auipc	a4,0x10
ffffffffc0200f5c:	5e873703          	ld	a4,1512(a4) # ffffffffc0211540 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f60:	078a                	slli	a5,a5,0x2
ffffffffc0200f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f64:	26e7f663          	bgeu	a5,a4,ffffffffc02011d0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	20873703          	ld	a4,520(a4) # ffffffffc0206170 <nbase>
ffffffffc0200f70:	8f99                	sub	a5,a5,a4
ffffffffc0200f72:	00379713          	slli	a4,a5,0x3
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f7a:	00010517          	auipc	a0,0x10
ffffffffc0200f7e:	5ce53503          	ld	a0,1486(a0) # ffffffffc0211548 <pages>
ffffffffc0200f82:	953e                	add	a0,a0,a5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	26f010ef          	jal	ra,ffffffffc02029f4 <free_pages>
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
ffffffffc0200fa6:	42f020ef          	jal	ra,ffffffffc0203bd4 <kfree>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fac:	fea416e3          	bne	s0,a0,ffffffffc0200f98 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fb0:	03000593          	li	a1,48
ffffffffc0200fb4:	8522                	mv	a0,s0
ffffffffc0200fb6:	41f020ef          	jal	ra,ffffffffc0203bd4 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fba:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fbc:	00010797          	auipc	a5,0x10
ffffffffc0200fc0:	5407b223          	sd	zero,1348(a5) # ffffffffc0211500 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fc4:	271010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0200fc8:	22a49063          	bne	s1,a0,ffffffffc02011e8 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fcc:	00004517          	auipc	a0,0x4
ffffffffc0200fd0:	fc450513          	addi	a0,a0,-60 # ffffffffc0204f90 <commands+0x9a8>
ffffffffc0200fd4:	8e6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fd8:	25d010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
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
ffffffffc0200ff8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0204fb0 <commands+0x9c8>
}
ffffffffc0200ffc:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ffe:	8bcff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201002:	1c1000ef          	jal	ra,ffffffffc02019c2 <swap_init_mm>
ffffffffc0201006:	b5d1                	j	ffffffffc0200eca <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	da868693          	addi	a3,a3,-600 # ffffffffc0204db0 <commands+0x7c8>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	d0060613          	addi	a2,a2,-768 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201018:	0dd00593          	li	a1,221
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	d0c50513          	addi	a0,a0,-756 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201024:	8deff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	e4068693          	addi	a3,a3,-448 # ffffffffc0204e68 <commands+0x880>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	ce060613          	addi	a2,a2,-800 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201038:	0ee00593          	li	a1,238
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	cec50513          	addi	a0,a0,-788 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	df068693          	addi	a3,a3,-528 # ffffffffc0204e38 <commands+0x850>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	cc060613          	addi	a2,a2,-832 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201058:	0ed00593          	li	a1,237
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	ccc50513          	addi	a0,a0,-820 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	d3068693          	addi	a3,a3,-720 # ffffffffc0204d98 <commands+0x7b0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	ca060613          	addi	a2,a2,-864 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201078:	0db00593          	li	a1,219
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	cac50513          	addi	a0,a0,-852 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	d6068693          	addi	a3,a3,-672 # ffffffffc0204de8 <commands+0x800>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	c8060613          	addi	a2,a2,-896 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201098:	0e300593          	li	a1,227
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	c8c50513          	addi	a0,a0,-884 # ffffffffc0204d28 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	d5068693          	addi	a3,a3,-688 # ffffffffc0204df8 <commands+0x810>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	c6060613          	addi	a2,a2,-928 # ffffffffc0204d10 <commands+0x728>
ffffffffc02010b8:	0e500593          	li	a1,229
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	c6c50513          	addi	a0,a0,-916 # ffffffffc0204d28 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	d4068693          	addi	a3,a3,-704 # ffffffffc0204e08 <commands+0x820>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	c4060613          	addi	a2,a2,-960 # ffffffffc0204d10 <commands+0x728>
ffffffffc02010d8:	0e700593          	li	a1,231
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	c4c50513          	addi	a0,a0,-948 # ffffffffc0204d28 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	d3068693          	addi	a3,a3,-720 # ffffffffc0204e18 <commands+0x830>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	c2060613          	addi	a2,a2,-992 # ffffffffc0204d10 <commands+0x728>
ffffffffc02010f8:	0e900593          	li	a1,233
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	c2c50513          	addi	a0,a0,-980 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	d2068693          	addi	a3,a3,-736 # ffffffffc0204e28 <commands+0x840>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	c0060613          	addi	a2,a2,-1024 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201118:	0eb00593          	li	a1,235
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	df868693          	addi	a3,a3,-520 # ffffffffc0204f20 <commands+0x938>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	be060613          	addi	a2,a2,-1056 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201138:	10d00593          	li	a1,269
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	bec50513          	addi	a0,a0,-1044 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	e9068693          	addi	a3,a3,-368 # ffffffffc0204fd8 <commands+0x9f0>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201158:	10a00593          	li	a1,266
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0204d28 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201164:	00010797          	auipc	a5,0x10
ffffffffc0201168:	3807be23          	sd	zero,924(a5) # ffffffffc0211500 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020116c:	f97fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	e5868693          	addi	a3,a3,-424 # ffffffffc0204fc8 <commands+0x9e0>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	b9860613          	addi	a2,a2,-1128 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201180:	11100593          	li	a1,273
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	ba450513          	addi	a0,a0,-1116 # ffffffffc0204d28 <commands+0x740>
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	da068693          	addi	a3,a3,-608 # ffffffffc0204f30 <commands+0x948>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	b7860613          	addi	a2,a2,-1160 # ffffffffc0204d10 <commands+0x728>
ffffffffc02011a0:	11600593          	li	a1,278
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204d28 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	da068693          	addi	a3,a3,-608 # ffffffffc0204f50 <commands+0x968>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	b5860613          	addi	a2,a2,-1192 # ffffffffc0204d10 <commands+0x728>
ffffffffc02011c0:	12000593          	li	a1,288
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	b6450513          	addi	a0,a0,-1180 # ffffffffc0204d28 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	d9060613          	addi	a2,a2,-624 # ffffffffc0204f60 <commands+0x978>
ffffffffc02011d8:	06500593          	li	a1,101
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	da450513          	addi	a0,a0,-604 # ffffffffc0204f80 <commands+0x998>
ffffffffc02011e4:	f1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	cf068693          	addi	a3,a3,-784 # ffffffffc0204ed8 <commands+0x8f0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204d10 <commands+0x728>
ffffffffc02011f8:	12e00593          	li	a1,302
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	cd068693          	addi	a3,a3,-816 # ffffffffc0204ed8 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201218:	0bd00593          	li	a1,189
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	dc868693          	addi	a3,a3,-568 # ffffffffc0204ff0 <commands+0xa08>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201238:	0c700593          	li	a1,199
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	aec50513          	addi	a0,a0,-1300 # ffffffffc0204d28 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	c9068693          	addi	a3,a3,-880 # ffffffffc0204ed8 <commands+0x8f0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	ac060613          	addi	a2,a2,-1344 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201258:	0fb00593          	li	a1,251
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	acc50513          	addi	a0,a0,-1332 # ffffffffc0204d28 <commands+0x740>
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
ffffffffc0201282:	28a7a783          	lw	a5,650(a5) # ffffffffc0211508 <pgfault_num>
ffffffffc0201286:	2785                	addiw	a5,a5,1
ffffffffc0201288:	00010717          	auipc	a4,0x10
ffffffffc020128c:	28f72023          	sw	a5,640(a4) # ffffffffc0211508 <pgfault_num>
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
ffffffffc02012aa:	7c4010ef          	jal	ra,ffffffffc0202a6e <get_pte>
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
ffffffffc02012b6:	26e7a783          	lw	a5,622(a5) # ffffffffc0211520 <swap_init_ok>
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
ffffffffc02012d4:	285010ef          	jal	ra,ffffffffc0202d58 <page_insert>
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
ffffffffc0201300:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205058 <commands+0xa70>
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
ffffffffc020131e:	744020ef          	jal	ra,ffffffffc0203a62 <pgdir_alloc_page>
   ret = 0;
ffffffffc0201322:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201324:	f171                	bnez	a0,ffffffffc02012e8 <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0205030 <commands+0xa48>
ffffffffc020132e:	d8dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201332:	5971                	li	s2,-4
            goto failed;
ffffffffc0201334:	bf55                	j	ffffffffc02012e8 <do_pgfault+0x80>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201336:	85a2                	mv	a1,s0
ffffffffc0201338:	00004517          	auipc	a0,0x4
ffffffffc020133c:	cc850513          	addi	a0,a0,-824 # ffffffffc0205000 <commands+0xa18>
ffffffffc0201340:	d7bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201344:	5975                	li	s2,-3
        goto failed;
ffffffffc0201346:	b74d                	j	ffffffffc02012e8 <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201348:	00004517          	auipc	a0,0x4
ffffffffc020134c:	d3050513          	addi	a0,a0,-720 # ffffffffc0205078 <commands+0xa90>
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
ffffffffc0201374:	149020ef          	jal	ra,ffffffffc0203cbc <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201378:	00010697          	auipc	a3,0x10
ffffffffc020137c:	1986b683          	ld	a3,408(a3) # ffffffffc0211510 <max_swap_offset>
ffffffffc0201380:	010007b7          	lui	a5,0x1000
ffffffffc0201384:	ff968713          	addi	a4,a3,-7
ffffffffc0201388:	17e1                	addi	a5,a5,-8
ffffffffc020138a:	3ee7e063          	bltu	a5,a4,ffffffffc020176a <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020138e:	00009797          	auipc	a5,0x9
ffffffffc0201392:	c7278793          	addi	a5,a5,-910 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0201396:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0201398:	00010b17          	auipc	s6,0x10
ffffffffc020139c:	180b0b13          	addi	s6,s6,384 # ffffffffc0211518 <sm>
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
ffffffffc02013d2:	d0250513          	addi	a0,a0,-766 # ffffffffc02050d0 <commands+0xae8>
ffffffffc02013d6:	00010497          	auipc	s1,0x10
ffffffffc02013da:	cfa48493          	addi	s1,s1,-774 # ffffffffc02110d0 <free_area>
ffffffffc02013de:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013e0:	4785                	li	a5,1
ffffffffc02013e2:	00010717          	auipc	a4,0x10
ffffffffc02013e6:	12f72f23          	sw	a5,318(a4) # ffffffffc0211520 <swap_init_ok>
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
ffffffffc0201412:	622010ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0201416:	47251663          	bne	a0,s2,ffffffffc0201882 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020141a:	8622                	mv	a2,s0
ffffffffc020141c:	85ea                	mv	a1,s10
ffffffffc020141e:	00004517          	auipc	a0,0x4
ffffffffc0201422:	cfa50513          	addi	a0,a0,-774 # ffffffffc0205118 <commands+0xb30>
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
ffffffffc0201438:	0cc78793          	addi	a5,a5,204 # ffffffffc0211500 <check_mm_struct>
ffffffffc020143c:	6398                	ld	a4,0(a5)
ffffffffc020143e:	54071263          	bnez	a4,ffffffffc0201982 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201442:	00010b97          	auipc	s7,0x10
ffffffffc0201446:	0f6bbb83          	ld	s7,246(s7) # ffffffffc0211538 <boot_pgdir>
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
ffffffffc0201472:	cea50513          	addi	a0,a0,-790 # ffffffffc0205158 <commands+0xb70>
ffffffffc0201476:	c45fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020147a:	018ab503          	ld	a0,24(s5)
ffffffffc020147e:	4605                	li	a2,1
ffffffffc0201480:	6585                	lui	a1,0x1
ffffffffc0201482:	5ec010ef          	jal	ra,ffffffffc0202a6e <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201486:	3c050e63          	beqz	a0,ffffffffc0201862 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020148a:	00004517          	auipc	a0,0x4
ffffffffc020148e:	d1e50513          	addi	a0,a0,-738 # ffffffffc02051a8 <commands+0xbc0>
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
ffffffffc02014aa:	4b8010ef          	jal	ra,ffffffffc0202962 <alloc_pages>
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
ffffffffc02014ec:	508010ef          	jal	ra,ffffffffc02029f4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014f0:	ff4c1ae3          	bne	s8,s4,ffffffffc02014e4 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014f4:	0104ac03          	lw	s8,16(s1)
ffffffffc02014f8:	4791                	li	a5,4
ffffffffc02014fa:	4afc1463          	bne	s8,a5,ffffffffc02019a2 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014fe:	00004517          	auipc	a0,0x4
ffffffffc0201502:	d3250513          	addi	a0,a0,-718 # ffffffffc0205230 <commands+0xc48>
ffffffffc0201506:	bb5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020150a:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020150c:	00010797          	auipc	a5,0x10
ffffffffc0201510:	fe07ae23          	sw	zero,-4(a5) # ffffffffc0211508 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201514:	4529                	li	a0,10
ffffffffc0201516:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020151a:	00010597          	auipc	a1,0x10
ffffffffc020151e:	fee5a583          	lw	a1,-18(a1) # ffffffffc0211508 <pgfault_num>
ffffffffc0201522:	4805                	li	a6,1
ffffffffc0201524:	00010797          	auipc	a5,0x10
ffffffffc0201528:	fe478793          	addi	a5,a5,-28 # ffffffffc0211508 <pgfault_num>
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
ffffffffc02015d6:	f76c8c93          	addi	s9,s9,-138 # ffffffffc0211548 <pages>
ffffffffc02015da:	00005c17          	auipc	s8,0x5
ffffffffc02015de:	b96c0c13          	addi	s8,s8,-1130 # ffffffffc0206170 <nbase>
     
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
ffffffffc02015f0:	47e010ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc02015f4:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015f6:	65c2                	ld	a1,16(sp)
ffffffffc02015f8:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015fa:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015fe:	00010317          	auipc	t1,0x10
ffffffffc0201602:	f4230313          	addi	t1,t1,-190 # ffffffffc0211540 <npage>
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
ffffffffc020164e:	cc650513          	addi	a0,a0,-826 # ffffffffc0205310 <commands+0xd28>
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
ffffffffc020166a:	38a010ef          	jal	ra,ffffffffc02029f4 <free_pages>
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
ffffffffc02016a0:	ca450513          	addi	a0,a0,-860 # ffffffffc0205340 <commands+0xd58>
ffffffffc02016a4:	a17fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	cb850513          	addi	a0,a0,-840 # ffffffffc0205360 <commands+0xd78>
ffffffffc02016b0:	a0bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02016b4:	b9dd                	j	ffffffffc02013aa <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02016b6:	4901                	li	s2,0
ffffffffc02016b8:	bba9                	j	ffffffffc0201412 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc02016ba:	00004697          	auipc	a3,0x4
ffffffffc02016be:	a2e68693          	addi	a3,a3,-1490 # ffffffffc02050e8 <commands+0xb00>
ffffffffc02016c2:	00003617          	auipc	a2,0x3
ffffffffc02016c6:	64e60613          	addi	a2,a2,1614 # ffffffffc0204d10 <commands+0x728>
ffffffffc02016ca:	0ba00593          	li	a1,186
ffffffffc02016ce:	00004517          	auipc	a0,0x4
ffffffffc02016d2:	9f250513          	addi	a0,a0,-1550 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02016d6:	a2dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016da:	00004697          	auipc	a3,0x4
ffffffffc02016de:	c0e68693          	addi	a3,a3,-1010 # ffffffffc02052e8 <commands+0xd00>
ffffffffc02016e2:	00003617          	auipc	a2,0x3
ffffffffc02016e6:	62e60613          	addi	a2,a2,1582 # ffffffffc0204d10 <commands+0x728>
ffffffffc02016ea:	0fa00593          	li	a1,250
ffffffffc02016ee:	00004517          	auipc	a0,0x4
ffffffffc02016f2:	9d250513          	addi	a0,a0,-1582 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02016f6:	a0dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016fa:	00004617          	auipc	a2,0x4
ffffffffc02016fe:	bc660613          	addi	a2,a2,-1082 # ffffffffc02052c0 <commands+0xcd8>
ffffffffc0201702:	07000593          	li	a1,112
ffffffffc0201706:	00004517          	auipc	a0,0x4
ffffffffc020170a:	87a50513          	addi	a0,a0,-1926 # ffffffffc0204f80 <commands+0x998>
ffffffffc020170e:	9f5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201712:	00004617          	auipc	a2,0x4
ffffffffc0201716:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204f60 <commands+0x978>
ffffffffc020171a:	06500593          	li	a1,101
ffffffffc020171e:	00004517          	auipc	a0,0x4
ffffffffc0201722:	86250513          	addi	a0,a0,-1950 # ffffffffc0204f80 <commands+0x998>
ffffffffc0201726:	9ddfe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020172a:	00004697          	auipc	a3,0x4
ffffffffc020172e:	abe68693          	addi	a3,a3,-1346 # ffffffffc02051e8 <commands+0xc00>
ffffffffc0201732:	00003617          	auipc	a2,0x3
ffffffffc0201736:	5de60613          	addi	a2,a2,1502 # ffffffffc0204d10 <commands+0x728>
ffffffffc020173a:	0db00593          	li	a1,219
ffffffffc020173e:	00004517          	auipc	a0,0x4
ffffffffc0201742:	98250513          	addi	a0,a0,-1662 # ffffffffc02050c0 <commands+0xad8>
ffffffffc0201746:	9bdfe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020174a:	00004697          	auipc	a3,0x4
ffffffffc020174e:	a8668693          	addi	a3,a3,-1402 # ffffffffc02051d0 <commands+0xbe8>
ffffffffc0201752:	00003617          	auipc	a2,0x3
ffffffffc0201756:	5be60613          	addi	a2,a2,1470 # ffffffffc0204d10 <commands+0x728>
ffffffffc020175a:	0da00593          	li	a1,218
ffffffffc020175e:	00004517          	auipc	a0,0x4
ffffffffc0201762:	96250513          	addi	a0,a0,-1694 # ffffffffc02050c0 <commands+0xad8>
ffffffffc0201766:	99dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020176a:	00004617          	auipc	a2,0x4
ffffffffc020176e:	93660613          	addi	a2,a2,-1738 # ffffffffc02050a0 <commands+0xab8>
ffffffffc0201772:	02700593          	li	a1,39
ffffffffc0201776:	00004517          	auipc	a0,0x4
ffffffffc020177a:	94a50513          	addi	a0,a0,-1718 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020177e:	985fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201782:	00004697          	auipc	a3,0x4
ffffffffc0201786:	b2668693          	addi	a3,a3,-1242 # ffffffffc02052a8 <commands+0xcc0>
ffffffffc020178a:	00003617          	auipc	a2,0x3
ffffffffc020178e:	58660613          	addi	a2,a2,1414 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201792:	0f900593          	li	a1,249
ffffffffc0201796:	00004517          	auipc	a0,0x4
ffffffffc020179a:	92a50513          	addi	a0,a0,-1750 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020179e:	965fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a2:	00004697          	auipc	a3,0x4
ffffffffc02017a6:	ae668693          	addi	a3,a3,-1306 # ffffffffc0205288 <commands+0xca0>
ffffffffc02017aa:	00003617          	auipc	a2,0x3
ffffffffc02017ae:	56660613          	addi	a2,a2,1382 # ffffffffc0204d10 <commands+0x728>
ffffffffc02017b2:	09d00593          	li	a1,157
ffffffffc02017b6:	00004517          	auipc	a0,0x4
ffffffffc02017ba:	90a50513          	addi	a0,a0,-1782 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02017be:	945fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017c2:	00004697          	auipc	a3,0x4
ffffffffc02017c6:	ac668693          	addi	a3,a3,-1338 # ffffffffc0205288 <commands+0xca0>
ffffffffc02017ca:	00003617          	auipc	a2,0x3
ffffffffc02017ce:	54660613          	addi	a2,a2,1350 # ffffffffc0204d10 <commands+0x728>
ffffffffc02017d2:	09f00593          	li	a1,159
ffffffffc02017d6:	00004517          	auipc	a0,0x4
ffffffffc02017da:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02017de:	925fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017e2:	00004697          	auipc	a3,0x4
ffffffffc02017e6:	ab668693          	addi	a3,a3,-1354 # ffffffffc0205298 <commands+0xcb0>
ffffffffc02017ea:	00003617          	auipc	a2,0x3
ffffffffc02017ee:	52660613          	addi	a2,a2,1318 # ffffffffc0204d10 <commands+0x728>
ffffffffc02017f2:	0f100593          	li	a1,241
ffffffffc02017f6:	00004517          	auipc	a0,0x4
ffffffffc02017fa:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02017fe:	905fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201802:	00004697          	auipc	a3,0x4
ffffffffc0201806:	b3668693          	addi	a3,a3,-1226 # ffffffffc0205338 <commands+0xd50>
ffffffffc020180a:	00003617          	auipc	a2,0x3
ffffffffc020180e:	50660613          	addi	a2,a2,1286 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201812:	10000593          	li	a1,256
ffffffffc0201816:	00004517          	auipc	a0,0x4
ffffffffc020181a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020181e:	8e5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201822:	00003697          	auipc	a3,0x3
ffffffffc0201826:	6fe68693          	addi	a3,a3,1790 # ffffffffc0204f20 <commands+0x938>
ffffffffc020182a:	00003617          	auipc	a2,0x3
ffffffffc020182e:	4e660613          	addi	a2,a2,1254 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201832:	0ca00593          	li	a1,202
ffffffffc0201836:	00004517          	auipc	a0,0x4
ffffffffc020183a:	88a50513          	addi	a0,a0,-1910 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020183e:	8c5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201842:	00003697          	auipc	a3,0x3
ffffffffc0201846:	78668693          	addi	a3,a3,1926 # ffffffffc0204fc8 <commands+0x9e0>
ffffffffc020184a:	00003617          	auipc	a2,0x3
ffffffffc020184e:	4c660613          	addi	a2,a2,1222 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201852:	0cd00593          	li	a1,205
ffffffffc0201856:	00004517          	auipc	a0,0x4
ffffffffc020185a:	86a50513          	addi	a0,a0,-1942 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020185e:	8a5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201862:	00004697          	auipc	a3,0x4
ffffffffc0201866:	92e68693          	addi	a3,a3,-1746 # ffffffffc0205190 <commands+0xba8>
ffffffffc020186a:	00003617          	auipc	a2,0x3
ffffffffc020186e:	4a660613          	addi	a2,a2,1190 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201872:	0d500593          	li	a1,213
ffffffffc0201876:	00004517          	auipc	a0,0x4
ffffffffc020187a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020187e:	885fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201882:	00004697          	auipc	a3,0x4
ffffffffc0201886:	87668693          	addi	a3,a3,-1930 # ffffffffc02050f8 <commands+0xb10>
ffffffffc020188a:	00003617          	auipc	a2,0x3
ffffffffc020188e:	48660613          	addi	a2,a2,1158 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201892:	0bd00593          	li	a1,189
ffffffffc0201896:	00004517          	auipc	a0,0x4
ffffffffc020189a:	82a50513          	addi	a0,a0,-2006 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020189e:	865fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a2:	00004697          	auipc	a3,0x4
ffffffffc02018a6:	9c668693          	addi	a3,a3,-1594 # ffffffffc0205268 <commands+0xc80>
ffffffffc02018aa:	00003617          	auipc	a2,0x3
ffffffffc02018ae:	46660613          	addi	a2,a2,1126 # ffffffffc0204d10 <commands+0x728>
ffffffffc02018b2:	09500593          	li	a1,149
ffffffffc02018b6:	00004517          	auipc	a0,0x4
ffffffffc02018ba:	80a50513          	addi	a0,a0,-2038 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02018be:	845fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018c2:	00004697          	auipc	a3,0x4
ffffffffc02018c6:	9a668693          	addi	a3,a3,-1626 # ffffffffc0205268 <commands+0xc80>
ffffffffc02018ca:	00003617          	auipc	a2,0x3
ffffffffc02018ce:	44660613          	addi	a2,a2,1094 # ffffffffc0204d10 <commands+0x728>
ffffffffc02018d2:	09700593          	li	a1,151
ffffffffc02018d6:	00003517          	auipc	a0,0x3
ffffffffc02018da:	7ea50513          	addi	a0,a0,2026 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02018de:	825fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e2:	00004697          	auipc	a3,0x4
ffffffffc02018e6:	99668693          	addi	a3,a3,-1642 # ffffffffc0205278 <commands+0xc90>
ffffffffc02018ea:	00003617          	auipc	a2,0x3
ffffffffc02018ee:	42660613          	addi	a2,a2,1062 # ffffffffc0204d10 <commands+0x728>
ffffffffc02018f2:	09900593          	li	a1,153
ffffffffc02018f6:	00003517          	auipc	a0,0x3
ffffffffc02018fa:	7ca50513          	addi	a0,a0,1994 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02018fe:	805fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201902:	00004697          	auipc	a3,0x4
ffffffffc0201906:	97668693          	addi	a3,a3,-1674 # ffffffffc0205278 <commands+0xc90>
ffffffffc020190a:	00003617          	auipc	a2,0x3
ffffffffc020190e:	40660613          	addi	a2,a2,1030 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201912:	09b00593          	li	a1,155
ffffffffc0201916:	00003517          	auipc	a0,0x3
ffffffffc020191a:	7aa50513          	addi	a0,a0,1962 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020191e:	fe4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201922:	00004697          	auipc	a3,0x4
ffffffffc0201926:	93668693          	addi	a3,a3,-1738 # ffffffffc0205258 <commands+0xc70>
ffffffffc020192a:	00003617          	auipc	a2,0x3
ffffffffc020192e:	3e660613          	addi	a2,a2,998 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201932:	09100593          	li	a1,145
ffffffffc0201936:	00003517          	auipc	a0,0x3
ffffffffc020193a:	78a50513          	addi	a0,a0,1930 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020193e:	fc4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201942:	00004697          	auipc	a3,0x4
ffffffffc0201946:	91668693          	addi	a3,a3,-1770 # ffffffffc0205258 <commands+0xc70>
ffffffffc020194a:	00003617          	auipc	a2,0x3
ffffffffc020194e:	3c660613          	addi	a2,a2,966 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201952:	09300593          	li	a1,147
ffffffffc0201956:	00003517          	auipc	a0,0x3
ffffffffc020195a:	76a50513          	addi	a0,a0,1898 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020195e:	fa4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201962:	00003697          	auipc	a3,0x3
ffffffffc0201966:	68e68693          	addi	a3,a3,1678 # ffffffffc0204ff0 <commands+0xa08>
ffffffffc020196a:	00003617          	auipc	a2,0x3
ffffffffc020196e:	3a660613          	addi	a2,a2,934 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201972:	0c200593          	li	a1,194
ffffffffc0201976:	00003517          	auipc	a0,0x3
ffffffffc020197a:	74a50513          	addi	a0,a0,1866 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020197e:	f84fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201982:	00003697          	auipc	a3,0x3
ffffffffc0201986:	7be68693          	addi	a3,a3,1982 # ffffffffc0205140 <commands+0xb58>
ffffffffc020198a:	00003617          	auipc	a2,0x3
ffffffffc020198e:	38660613          	addi	a2,a2,902 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201992:	0c500593          	li	a1,197
ffffffffc0201996:	00003517          	auipc	a0,0x3
ffffffffc020199a:	72a50513          	addi	a0,a0,1834 # ffffffffc02050c0 <commands+0xad8>
ffffffffc020199e:	f64fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019a2:	00004697          	auipc	a3,0x4
ffffffffc02019a6:	86668693          	addi	a3,a3,-1946 # ffffffffc0205208 <commands+0xc20>
ffffffffc02019aa:	00003617          	auipc	a2,0x3
ffffffffc02019ae:	36660613          	addi	a2,a2,870 # ffffffffc0204d10 <commands+0x728>
ffffffffc02019b2:	0e800593          	li	a1,232
ffffffffc02019b6:	00003517          	auipc	a0,0x3
ffffffffc02019ba:	70a50513          	addi	a0,a0,1802 # ffffffffc02050c0 <commands+0xad8>
ffffffffc02019be:	f44fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019c2 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019c2:	00010797          	auipc	a5,0x10
ffffffffc02019c6:	b567b783          	ld	a5,-1194(a5) # ffffffffc0211518 <sm>
ffffffffc02019ca:	6b9c                	ld	a5,16(a5)
ffffffffc02019cc:	8782                	jr	a5

ffffffffc02019ce <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019ce:	00010797          	auipc	a5,0x10
ffffffffc02019d2:	b4a7b783          	ld	a5,-1206(a5) # ffffffffc0211518 <sm>
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
ffffffffc02019fe:	b1e98993          	addi	s3,s3,-1250 # ffffffffc0211518 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201a02:	00004b17          	auipc	s6,0x4
ffffffffc0201a06:	9deb0b13          	addi	s6,s6,-1570 # ffffffffc02053e0 <commands+0xdf8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a0a:	00004b97          	auipc	s7,0x4
ffffffffc0201a0e:	9beb8b93          	addi	s7,s7,-1602 # ffffffffc02053c8 <commands+0xde0>
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
ffffffffc0201a38:	7bd000ef          	jal	ra,ffffffffc02029f4 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a3c:	01893503          	ld	a0,24(s2)
ffffffffc0201a40:	85a6                	mv	a1,s1
ffffffffc0201a42:	01a020ef          	jal	ra,ffffffffc0203a5c <tlb_invalidate>
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
ffffffffc0201a66:	008010ef          	jal	ra,ffffffffc0202a6e <get_pte>
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
ffffffffc0201a7e:	310020ef          	jal	ra,ffffffffc0203d8e <swapfs_write>
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
ffffffffc0201ac0:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205380 <commands+0xd98>
ffffffffc0201ac4:	df6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201ac8:	bfe1                	j	ffffffffc0201aa0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201aca:	4401                	li	s0,0
ffffffffc0201acc:	bfd1                	j	ffffffffc0201aa0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201ace:	00004697          	auipc	a3,0x4
ffffffffc0201ad2:	8e268693          	addi	a3,a3,-1822 # ffffffffc02053b0 <commands+0xdc8>
ffffffffc0201ad6:	00003617          	auipc	a2,0x3
ffffffffc0201ada:	23a60613          	addi	a2,a2,570 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201ade:	06600593          	li	a1,102
ffffffffc0201ae2:	00003517          	auipc	a0,0x3
ffffffffc0201ae6:	5de50513          	addi	a0,a0,1502 # ffffffffc02050c0 <commands+0xad8>
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
ffffffffc0201b02:	661000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201b06:	c129                	beqz	a0,ffffffffc0201b48 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201b08:	842a                	mv	s0,a0
ffffffffc0201b0a:	01893503          	ld	a0,24(s2)
ffffffffc0201b0e:	4601                	li	a2,0
ffffffffc0201b10:	85a6                	mv	a1,s1
ffffffffc0201b12:	75d000ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc0201b16:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201b18:	6108                	ld	a0,0(a0)
ffffffffc0201b1a:	85a2                	mv	a1,s0
ffffffffc0201b1c:	1d8020ef          	jal	ra,ffffffffc0203cf4 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201b20:	00093583          	ld	a1,0(s2)
ffffffffc0201b24:	8626                	mv	a2,s1
ffffffffc0201b26:	00004517          	auipc	a0,0x4
ffffffffc0201b2a:	90a50513          	addi	a0,a0,-1782 # ffffffffc0205430 <commands+0xe48>
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
ffffffffc0201b4c:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205420 <commands+0xe38>
ffffffffc0201b50:	00003617          	auipc	a2,0x3
ffffffffc0201b54:	1c060613          	addi	a2,a2,448 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201b58:	07c00593          	li	a1,124
ffffffffc0201b5c:	00003517          	auipc	a0,0x3
ffffffffc0201b60:	56450513          	addi	a0,a0,1380 # ffffffffc02050c0 <commands+0xad8>
ffffffffc0201b64:	d9efe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b68 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b68:	0000f797          	auipc	a5,0xf
ffffffffc0201b6c:	56878793          	addi	a5,a5,1384 # ffffffffc02110d0 <free_area>
ffffffffc0201b70:	e79c                	sd	a5,8(a5)
ffffffffc0201b72:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b74:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b78:	8082                	ret

ffffffffc0201b7a <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b7a:	0000f517          	auipc	a0,0xf
ffffffffc0201b7e:	56656503          	lwu	a0,1382(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0201b82:	8082                	ret

ffffffffc0201b84 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b84:	715d                	addi	sp,sp,-80
ffffffffc0201b86:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201b88:	0000f417          	auipc	s0,0xf
ffffffffc0201b8c:	54840413          	addi	s0,s0,1352 # ffffffffc02110d0 <free_area>
ffffffffc0201b90:	641c                	ld	a5,8(s0)
ffffffffc0201b92:	e486                	sd	ra,72(sp)
ffffffffc0201b94:	fc26                	sd	s1,56(sp)
ffffffffc0201b96:	f84a                	sd	s2,48(sp)
ffffffffc0201b98:	f44e                	sd	s3,40(sp)
ffffffffc0201b9a:	f052                	sd	s4,32(sp)
ffffffffc0201b9c:	ec56                	sd	s5,24(sp)
ffffffffc0201b9e:	e85a                	sd	s6,16(sp)
ffffffffc0201ba0:	e45e                	sd	s7,8(sp)
ffffffffc0201ba2:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201ba4:	2c878763          	beq	a5,s0,ffffffffc0201e72 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201ba8:	4481                	li	s1,0
ffffffffc0201baa:	4901                	li	s2,0
ffffffffc0201bac:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201bb0:	8b09                	andi	a4,a4,2
ffffffffc0201bb2:	2c070463          	beqz	a4,ffffffffc0201e7a <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201bb6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201bba:	679c                	ld	a5,8(a5)
ffffffffc0201bbc:	2905                	addiw	s2,s2,1
ffffffffc0201bbe:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201bc0:	fe8796e3          	bne	a5,s0,ffffffffc0201bac <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201bc4:	89a6                	mv	s3,s1
ffffffffc0201bc6:	66f000ef          	jal	ra,ffffffffc0202a34 <nr_free_pages>
ffffffffc0201bca:	71351863          	bne	a0,s3,ffffffffc02022da <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201bce:	4505                	li	a0,1
ffffffffc0201bd0:	593000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201bd4:	8a2a                	mv	s4,a0
ffffffffc0201bd6:	44050263          	beqz	a0,ffffffffc020201a <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201bda:	4505                	li	a0,1
ffffffffc0201bdc:	587000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201be0:	89aa                	mv	s3,a0
ffffffffc0201be2:	70050c63          	beqz	a0,ffffffffc02022fa <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201be6:	4505                	li	a0,1
ffffffffc0201be8:	57b000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201bec:	8aaa                	mv	s5,a0
ffffffffc0201bee:	4a050663          	beqz	a0,ffffffffc020209a <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201bf2:	2b3a0463          	beq	s4,s3,ffffffffc0201e9a <default_check+0x316>
ffffffffc0201bf6:	2aaa0263          	beq	s4,a0,ffffffffc0201e9a <default_check+0x316>
ffffffffc0201bfa:	2aa98063          	beq	s3,a0,ffffffffc0201e9a <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bfe:	000a2783          	lw	a5,0(s4)
ffffffffc0201c02:	2a079c63          	bnez	a5,ffffffffc0201eba <default_check+0x336>
ffffffffc0201c06:	0009a783          	lw	a5,0(s3)
ffffffffc0201c0a:	2a079863          	bnez	a5,ffffffffc0201eba <default_check+0x336>
ffffffffc0201c0e:	411c                	lw	a5,0(a0)
ffffffffc0201c10:	2a079563          	bnez	a5,ffffffffc0201eba <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c14:	00010797          	auipc	a5,0x10
ffffffffc0201c18:	9347b783          	ld	a5,-1740(a5) # ffffffffc0211548 <pages>
ffffffffc0201c1c:	40fa0733          	sub	a4,s4,a5
ffffffffc0201c20:	870d                	srai	a4,a4,0x3
ffffffffc0201c22:	00004597          	auipc	a1,0x4
ffffffffc0201c26:	5465b583          	ld	a1,1350(a1) # ffffffffc0206168 <error_string+0x38>
ffffffffc0201c2a:	02b70733          	mul	a4,a4,a1
ffffffffc0201c2e:	00004617          	auipc	a2,0x4
ffffffffc0201c32:	54263603          	ld	a2,1346(a2) # ffffffffc0206170 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201c36:	00010697          	auipc	a3,0x10
ffffffffc0201c3a:	90a6b683          	ld	a3,-1782(a3) # ffffffffc0211540 <npage>
ffffffffc0201c3e:	06b2                	slli	a3,a3,0xc
ffffffffc0201c40:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c42:	0732                	slli	a4,a4,0xc
ffffffffc0201c44:	28d77b63          	bgeu	a4,a3,ffffffffc0201eda <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c48:	40f98733          	sub	a4,s3,a5
ffffffffc0201c4c:	870d                	srai	a4,a4,0x3
ffffffffc0201c4e:	02b70733          	mul	a4,a4,a1
ffffffffc0201c52:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c54:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c56:	4cd77263          	bgeu	a4,a3,ffffffffc020211a <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c5a:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c5e:	878d                	srai	a5,a5,0x3
ffffffffc0201c60:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c64:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c66:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c68:	30d7f963          	bgeu	a5,a3,ffffffffc0201f7a <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0201c6c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c6e:	00043c03          	ld	s8,0(s0)
ffffffffc0201c72:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c76:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201c7a:	e400                	sd	s0,8(s0)
ffffffffc0201c7c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201c7e:	0000f797          	auipc	a5,0xf
ffffffffc0201c82:	4607a123          	sw	zero,1122(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c86:	4dd000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201c8a:	2c051863          	bnez	a0,ffffffffc0201f5a <default_check+0x3d6>
    free_page(p0);
ffffffffc0201c8e:	4585                	li	a1,1
ffffffffc0201c90:	8552                	mv	a0,s4
ffffffffc0201c92:	563000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_page(p1);
ffffffffc0201c96:	4585                	li	a1,1
ffffffffc0201c98:	854e                	mv	a0,s3
ffffffffc0201c9a:	55b000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_page(p2);
ffffffffc0201c9e:	4585                	li	a1,1
ffffffffc0201ca0:	8556                	mv	a0,s5
ffffffffc0201ca2:	553000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    assert(nr_free == 3);
ffffffffc0201ca6:	4818                	lw	a4,16(s0)
ffffffffc0201ca8:	478d                	li	a5,3
ffffffffc0201caa:	28f71863          	bne	a4,a5,ffffffffc0201f3a <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201cae:	4505                	li	a0,1
ffffffffc0201cb0:	4b3000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201cb4:	89aa                	mv	s3,a0
ffffffffc0201cb6:	26050263          	beqz	a0,ffffffffc0201f1a <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201cba:	4505                	li	a0,1
ffffffffc0201cbc:	4a7000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201cc0:	8aaa                	mv	s5,a0
ffffffffc0201cc2:	3a050c63          	beqz	a0,ffffffffc020207a <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201cc6:	4505                	li	a0,1
ffffffffc0201cc8:	49b000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201ccc:	8a2a                	mv	s4,a0
ffffffffc0201cce:	38050663          	beqz	a0,ffffffffc020205a <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0201cd2:	4505                	li	a0,1
ffffffffc0201cd4:	48f000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201cd8:	36051163          	bnez	a0,ffffffffc020203a <default_check+0x4b6>
    free_page(p0);
ffffffffc0201cdc:	4585                	li	a1,1
ffffffffc0201cde:	854e                	mv	a0,s3
ffffffffc0201ce0:	515000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201ce4:	641c                	ld	a5,8(s0)
ffffffffc0201ce6:	20878a63          	beq	a5,s0,ffffffffc0201efa <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0201cea:	4505                	li	a0,1
ffffffffc0201cec:	477000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201cf0:	30a99563          	bne	s3,a0,ffffffffc0201ffa <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0201cf4:	4505                	li	a0,1
ffffffffc0201cf6:	46d000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201cfa:	2e051063          	bnez	a0,ffffffffc0201fda <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0201cfe:	481c                	lw	a5,16(s0)
ffffffffc0201d00:	2a079d63          	bnez	a5,ffffffffc0201fba <default_check+0x436>
    free_page(p);
ffffffffc0201d04:	854e                	mv	a0,s3
ffffffffc0201d06:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201d08:	01843023          	sd	s8,0(s0)
ffffffffc0201d0c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201d10:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201d14:	4e1000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_page(p1);
ffffffffc0201d18:	4585                	li	a1,1
ffffffffc0201d1a:	8556                	mv	a0,s5
ffffffffc0201d1c:	4d9000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_page(p2);
ffffffffc0201d20:	4585                	li	a1,1
ffffffffc0201d22:	8552                	mv	a0,s4
ffffffffc0201d24:	4d1000ef          	jal	ra,ffffffffc02029f4 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d28:	4515                	li	a0,5
ffffffffc0201d2a:	439000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201d2e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d30:	26050563          	beqz	a0,ffffffffc0201f9a <default_check+0x416>
ffffffffc0201d34:	651c                	ld	a5,8(a0)
ffffffffc0201d36:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d38:	8b85                	andi	a5,a5,1
ffffffffc0201d3a:	54079063          	bnez	a5,ffffffffc020227a <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d3e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d40:	00043b03          	ld	s6,0(s0)
ffffffffc0201d44:	00843a83          	ld	s5,8(s0)
ffffffffc0201d48:	e000                	sd	s0,0(s0)
ffffffffc0201d4a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201d4c:	417000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201d50:	50051563          	bnez	a0,ffffffffc020225a <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d54:	09098a13          	addi	s4,s3,144
ffffffffc0201d58:	8552                	mv	a0,s4
ffffffffc0201d5a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d5c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201d60:	0000f797          	auipc	a5,0xf
ffffffffc0201d64:	3807a023          	sw	zero,896(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d68:	48d000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d6c:	4511                	li	a0,4
ffffffffc0201d6e:	3f5000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201d72:	4c051463          	bnez	a0,ffffffffc020223a <default_check+0x6b6>
ffffffffc0201d76:	0989b783          	ld	a5,152(s3)
ffffffffc0201d7a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d7c:	8b85                	andi	a5,a5,1
ffffffffc0201d7e:	48078e63          	beqz	a5,ffffffffc020221a <default_check+0x696>
ffffffffc0201d82:	0a89a703          	lw	a4,168(s3)
ffffffffc0201d86:	478d                	li	a5,3
ffffffffc0201d88:	48f71963          	bne	a4,a5,ffffffffc020221a <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d8c:	450d                	li	a0,3
ffffffffc0201d8e:	3d5000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201d92:	8c2a                	mv	s8,a0
ffffffffc0201d94:	46050363          	beqz	a0,ffffffffc02021fa <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0201d98:	4505                	li	a0,1
ffffffffc0201d9a:	3c9000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201d9e:	42051e63          	bnez	a0,ffffffffc02021da <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0201da2:	418a1c63          	bne	s4,s8,ffffffffc02021ba <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201da6:	4585                	li	a1,1
ffffffffc0201da8:	854e                	mv	a0,s3
ffffffffc0201daa:	44b000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_pages(p1, 3);
ffffffffc0201dae:	458d                	li	a1,3
ffffffffc0201db0:	8552                	mv	a0,s4
ffffffffc0201db2:	443000ef          	jal	ra,ffffffffc02029f4 <free_pages>
ffffffffc0201db6:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201dba:	04898c13          	addi	s8,s3,72
ffffffffc0201dbe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201dc0:	8b85                	andi	a5,a5,1
ffffffffc0201dc2:	3c078c63          	beqz	a5,ffffffffc020219a <default_check+0x616>
ffffffffc0201dc6:	0189a703          	lw	a4,24(s3)
ffffffffc0201dca:	4785                	li	a5,1
ffffffffc0201dcc:	3cf71763          	bne	a4,a5,ffffffffc020219a <default_check+0x616>
ffffffffc0201dd0:	008a3783          	ld	a5,8(s4)
ffffffffc0201dd4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201dd6:	8b85                	andi	a5,a5,1
ffffffffc0201dd8:	3a078163          	beqz	a5,ffffffffc020217a <default_check+0x5f6>
ffffffffc0201ddc:	018a2703          	lw	a4,24(s4)
ffffffffc0201de0:	478d                	li	a5,3
ffffffffc0201de2:	38f71c63          	bne	a4,a5,ffffffffc020217a <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201de6:	4505                	li	a0,1
ffffffffc0201de8:	37b000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201dec:	36a99763          	bne	s3,a0,ffffffffc020215a <default_check+0x5d6>
    free_page(p0);
ffffffffc0201df0:	4585                	li	a1,1
ffffffffc0201df2:	403000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201df6:	4509                	li	a0,2
ffffffffc0201df8:	36b000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201dfc:	32aa1f63          	bne	s4,a0,ffffffffc020213a <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201e00:	4589                	li	a1,2
ffffffffc0201e02:	3f3000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    free_page(p2);
ffffffffc0201e06:	4585                	li	a1,1
ffffffffc0201e08:	8562                	mv	a0,s8
ffffffffc0201e0a:	3eb000ef          	jal	ra,ffffffffc02029f4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201e0e:	4515                	li	a0,5
ffffffffc0201e10:	353000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201e14:	89aa                	mv	s3,a0
ffffffffc0201e16:	48050263          	beqz	a0,ffffffffc020229a <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0201e1a:	4505                	li	a0,1
ffffffffc0201e1c:	347000ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0201e20:	2c051d63          	bnez	a0,ffffffffc02020fa <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201e24:	481c                	lw	a5,16(s0)
ffffffffc0201e26:	2a079a63          	bnez	a5,ffffffffc02020da <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e2a:	4595                	li	a1,5
ffffffffc0201e2c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e2e:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201e32:	01643023          	sd	s6,0(s0)
ffffffffc0201e36:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201e3a:	3bb000ef          	jal	ra,ffffffffc02029f4 <free_pages>
    return listelm->next;
ffffffffc0201e3e:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e40:	00878963          	beq	a5,s0,ffffffffc0201e52 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e44:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e48:	679c                	ld	a5,8(a5)
ffffffffc0201e4a:	397d                	addiw	s2,s2,-1
ffffffffc0201e4c:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e4e:	fe879be3          	bne	a5,s0,ffffffffc0201e44 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201e52:	26091463          	bnez	s2,ffffffffc02020ba <default_check+0x536>
    assert(total == 0);
ffffffffc0201e56:	46049263          	bnez	s1,ffffffffc02022ba <default_check+0x736>
}
ffffffffc0201e5a:	60a6                	ld	ra,72(sp)
ffffffffc0201e5c:	6406                	ld	s0,64(sp)
ffffffffc0201e5e:	74e2                	ld	s1,56(sp)
ffffffffc0201e60:	7942                	ld	s2,48(sp)
ffffffffc0201e62:	79a2                	ld	s3,40(sp)
ffffffffc0201e64:	7a02                	ld	s4,32(sp)
ffffffffc0201e66:	6ae2                	ld	s5,24(sp)
ffffffffc0201e68:	6b42                	ld	s6,16(sp)
ffffffffc0201e6a:	6ba2                	ld	s7,8(sp)
ffffffffc0201e6c:	6c02                	ld	s8,0(sp)
ffffffffc0201e6e:	6161                	addi	sp,sp,80
ffffffffc0201e70:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e72:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e74:	4481                	li	s1,0
ffffffffc0201e76:	4901                	li	s2,0
ffffffffc0201e78:	b3b9                	j	ffffffffc0201bc6 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201e7a:	00003697          	auipc	a3,0x3
ffffffffc0201e7e:	26e68693          	addi	a3,a3,622 # ffffffffc02050e8 <commands+0xb00>
ffffffffc0201e82:	00003617          	auipc	a2,0x3
ffffffffc0201e86:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201e8a:	0f000593          	li	a1,240
ffffffffc0201e8e:	00003517          	auipc	a0,0x3
ffffffffc0201e92:	5e250513          	addi	a0,a0,1506 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201e96:	a6cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201e9a:	00003697          	auipc	a3,0x3
ffffffffc0201e9e:	64e68693          	addi	a3,a3,1614 # ffffffffc02054e8 <commands+0xf00>
ffffffffc0201ea2:	00003617          	auipc	a2,0x3
ffffffffc0201ea6:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201eaa:	0bd00593          	li	a1,189
ffffffffc0201eae:	00003517          	auipc	a0,0x3
ffffffffc0201eb2:	5c250513          	addi	a0,a0,1474 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201eb6:	a4cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201eba:	00003697          	auipc	a3,0x3
ffffffffc0201ebe:	65668693          	addi	a3,a3,1622 # ffffffffc0205510 <commands+0xf28>
ffffffffc0201ec2:	00003617          	auipc	a2,0x3
ffffffffc0201ec6:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201eca:	0be00593          	li	a1,190
ffffffffc0201ece:	00003517          	auipc	a0,0x3
ffffffffc0201ed2:	5a250513          	addi	a0,a0,1442 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201ed6:	a2cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201eda:	00003697          	auipc	a3,0x3
ffffffffc0201ede:	67668693          	addi	a3,a3,1654 # ffffffffc0205550 <commands+0xf68>
ffffffffc0201ee2:	00003617          	auipc	a2,0x3
ffffffffc0201ee6:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201eea:	0c000593          	li	a1,192
ffffffffc0201eee:	00003517          	auipc	a0,0x3
ffffffffc0201ef2:	58250513          	addi	a0,a0,1410 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201ef6:	a0cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201efa:	00003697          	auipc	a3,0x3
ffffffffc0201efe:	6de68693          	addi	a3,a3,1758 # ffffffffc02055d8 <commands+0xff0>
ffffffffc0201f02:	00003617          	auipc	a2,0x3
ffffffffc0201f06:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201f0a:	0d900593          	li	a1,217
ffffffffc0201f0e:	00003517          	auipc	a0,0x3
ffffffffc0201f12:	56250513          	addi	a0,a0,1378 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201f16:	9ecfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f1a:	00003697          	auipc	a3,0x3
ffffffffc0201f1e:	56e68693          	addi	a3,a3,1390 # ffffffffc0205488 <commands+0xea0>
ffffffffc0201f22:	00003617          	auipc	a2,0x3
ffffffffc0201f26:	dee60613          	addi	a2,a2,-530 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201f2a:	0d200593          	li	a1,210
ffffffffc0201f2e:	00003517          	auipc	a0,0x3
ffffffffc0201f32:	54250513          	addi	a0,a0,1346 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201f36:	9ccfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0201f3a:	00003697          	auipc	a3,0x3
ffffffffc0201f3e:	68e68693          	addi	a3,a3,1678 # ffffffffc02055c8 <commands+0xfe0>
ffffffffc0201f42:	00003617          	auipc	a2,0x3
ffffffffc0201f46:	dce60613          	addi	a2,a2,-562 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201f4a:	0d000593          	li	a1,208
ffffffffc0201f4e:	00003517          	auipc	a0,0x3
ffffffffc0201f52:	52250513          	addi	a0,a0,1314 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201f56:	9acfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f5a:	00003697          	auipc	a3,0x3
ffffffffc0201f5e:	65668693          	addi	a3,a3,1622 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc0201f62:	00003617          	auipc	a2,0x3
ffffffffc0201f66:	dae60613          	addi	a2,a2,-594 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201f6a:	0cb00593          	li	a1,203
ffffffffc0201f6e:	00003517          	auipc	a0,0x3
ffffffffc0201f72:	50250513          	addi	a0,a0,1282 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201f76:	98cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f7a:	00003697          	auipc	a3,0x3
ffffffffc0201f7e:	61668693          	addi	a3,a3,1558 # ffffffffc0205590 <commands+0xfa8>
ffffffffc0201f82:	00003617          	auipc	a2,0x3
ffffffffc0201f86:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201f8a:	0c200593          	li	a1,194
ffffffffc0201f8e:	00003517          	auipc	a0,0x3
ffffffffc0201f92:	4e250513          	addi	a0,a0,1250 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201f96:	96cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0201f9a:	00003697          	auipc	a3,0x3
ffffffffc0201f9e:	67668693          	addi	a3,a3,1654 # ffffffffc0205610 <commands+0x1028>
ffffffffc0201fa2:	00003617          	auipc	a2,0x3
ffffffffc0201fa6:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201faa:	0f800593          	li	a1,248
ffffffffc0201fae:	00003517          	auipc	a0,0x3
ffffffffc0201fb2:	4c250513          	addi	a0,a0,1218 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201fb6:	94cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0201fba:	00003697          	auipc	a3,0x3
ffffffffc0201fbe:	2de68693          	addi	a3,a3,734 # ffffffffc0205298 <commands+0xcb0>
ffffffffc0201fc2:	00003617          	auipc	a2,0x3
ffffffffc0201fc6:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201fca:	0df00593          	li	a1,223
ffffffffc0201fce:	00003517          	auipc	a0,0x3
ffffffffc0201fd2:	4a250513          	addi	a0,a0,1186 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201fd6:	92cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201fda:	00003697          	auipc	a3,0x3
ffffffffc0201fde:	5d668693          	addi	a3,a3,1494 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc0201fe2:	00003617          	auipc	a2,0x3
ffffffffc0201fe6:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204d10 <commands+0x728>
ffffffffc0201fea:	0dd00593          	li	a1,221
ffffffffc0201fee:	00003517          	auipc	a0,0x3
ffffffffc0201ff2:	48250513          	addi	a0,a0,1154 # ffffffffc0205470 <commands+0xe88>
ffffffffc0201ff6:	90cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201ffa:	00003697          	auipc	a3,0x3
ffffffffc0201ffe:	5f668693          	addi	a3,a3,1526 # ffffffffc02055f0 <commands+0x1008>
ffffffffc0202002:	00003617          	auipc	a2,0x3
ffffffffc0202006:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204d10 <commands+0x728>
ffffffffc020200a:	0dc00593          	li	a1,220
ffffffffc020200e:	00003517          	auipc	a0,0x3
ffffffffc0202012:	46250513          	addi	a0,a0,1122 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202016:	8ecfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020201a:	00003697          	auipc	a3,0x3
ffffffffc020201e:	46e68693          	addi	a3,a3,1134 # ffffffffc0205488 <commands+0xea0>
ffffffffc0202022:	00003617          	auipc	a2,0x3
ffffffffc0202026:	cee60613          	addi	a2,a2,-786 # ffffffffc0204d10 <commands+0x728>
ffffffffc020202a:	0b900593          	li	a1,185
ffffffffc020202e:	00003517          	auipc	a0,0x3
ffffffffc0202032:	44250513          	addi	a0,a0,1090 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202036:	8ccfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020203a:	00003697          	auipc	a3,0x3
ffffffffc020203e:	57668693          	addi	a3,a3,1398 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc0202042:	00003617          	auipc	a2,0x3
ffffffffc0202046:	cce60613          	addi	a2,a2,-818 # ffffffffc0204d10 <commands+0x728>
ffffffffc020204a:	0d600593          	li	a1,214
ffffffffc020204e:	00003517          	auipc	a0,0x3
ffffffffc0202052:	42250513          	addi	a0,a0,1058 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202056:	8acfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020205a:	00003697          	auipc	a3,0x3
ffffffffc020205e:	46e68693          	addi	a3,a3,1134 # ffffffffc02054c8 <commands+0xee0>
ffffffffc0202062:	00003617          	auipc	a2,0x3
ffffffffc0202066:	cae60613          	addi	a2,a2,-850 # ffffffffc0204d10 <commands+0x728>
ffffffffc020206a:	0d400593          	li	a1,212
ffffffffc020206e:	00003517          	auipc	a0,0x3
ffffffffc0202072:	40250513          	addi	a0,a0,1026 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202076:	88cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020207a:	00003697          	auipc	a3,0x3
ffffffffc020207e:	42e68693          	addi	a3,a3,1070 # ffffffffc02054a8 <commands+0xec0>
ffffffffc0202082:	00003617          	auipc	a2,0x3
ffffffffc0202086:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204d10 <commands+0x728>
ffffffffc020208a:	0d300593          	li	a1,211
ffffffffc020208e:	00003517          	auipc	a0,0x3
ffffffffc0202092:	3e250513          	addi	a0,a0,994 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202096:	86cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020209a:	00003697          	auipc	a3,0x3
ffffffffc020209e:	42e68693          	addi	a3,a3,1070 # ffffffffc02054c8 <commands+0xee0>
ffffffffc02020a2:	00003617          	auipc	a2,0x3
ffffffffc02020a6:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204d10 <commands+0x728>
ffffffffc02020aa:	0bb00593          	li	a1,187
ffffffffc02020ae:	00003517          	auipc	a0,0x3
ffffffffc02020b2:	3c250513          	addi	a0,a0,962 # ffffffffc0205470 <commands+0xe88>
ffffffffc02020b6:	84cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc02020ba:	00003697          	auipc	a3,0x3
ffffffffc02020be:	6a668693          	addi	a3,a3,1702 # ffffffffc0205760 <commands+0x1178>
ffffffffc02020c2:	00003617          	auipc	a2,0x3
ffffffffc02020c6:	c4e60613          	addi	a2,a2,-946 # ffffffffc0204d10 <commands+0x728>
ffffffffc02020ca:	12500593          	li	a1,293
ffffffffc02020ce:	00003517          	auipc	a0,0x3
ffffffffc02020d2:	3a250513          	addi	a0,a0,930 # ffffffffc0205470 <commands+0xe88>
ffffffffc02020d6:	82cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02020da:	00003697          	auipc	a3,0x3
ffffffffc02020de:	1be68693          	addi	a3,a3,446 # ffffffffc0205298 <commands+0xcb0>
ffffffffc02020e2:	00003617          	auipc	a2,0x3
ffffffffc02020e6:	c2e60613          	addi	a2,a2,-978 # ffffffffc0204d10 <commands+0x728>
ffffffffc02020ea:	11a00593          	li	a1,282
ffffffffc02020ee:	00003517          	auipc	a0,0x3
ffffffffc02020f2:	38250513          	addi	a0,a0,898 # ffffffffc0205470 <commands+0xe88>
ffffffffc02020f6:	80cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020fa:	00003697          	auipc	a3,0x3
ffffffffc02020fe:	4b668693          	addi	a3,a3,1206 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc0202102:	00003617          	auipc	a2,0x3
ffffffffc0202106:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204d10 <commands+0x728>
ffffffffc020210a:	11800593          	li	a1,280
ffffffffc020210e:	00003517          	auipc	a0,0x3
ffffffffc0202112:	36250513          	addi	a0,a0,866 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202116:	fedfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020211a:	00003697          	auipc	a3,0x3
ffffffffc020211e:	45668693          	addi	a3,a3,1110 # ffffffffc0205570 <commands+0xf88>
ffffffffc0202122:	00003617          	auipc	a2,0x3
ffffffffc0202126:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204d10 <commands+0x728>
ffffffffc020212a:	0c100593          	li	a1,193
ffffffffc020212e:	00003517          	auipc	a0,0x3
ffffffffc0202132:	34250513          	addi	a0,a0,834 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202136:	fcdfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020213a:	00003697          	auipc	a3,0x3
ffffffffc020213e:	5e668693          	addi	a3,a3,1510 # ffffffffc0205720 <commands+0x1138>
ffffffffc0202142:	00003617          	auipc	a2,0x3
ffffffffc0202146:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204d10 <commands+0x728>
ffffffffc020214a:	11200593          	li	a1,274
ffffffffc020214e:	00003517          	auipc	a0,0x3
ffffffffc0202152:	32250513          	addi	a0,a0,802 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202156:	fadfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020215a:	00003697          	auipc	a3,0x3
ffffffffc020215e:	5a668693          	addi	a3,a3,1446 # ffffffffc0205700 <commands+0x1118>
ffffffffc0202162:	00003617          	auipc	a2,0x3
ffffffffc0202166:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204d10 <commands+0x728>
ffffffffc020216a:	11000593          	li	a1,272
ffffffffc020216e:	00003517          	auipc	a0,0x3
ffffffffc0202172:	30250513          	addi	a0,a0,770 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202176:	f8dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020217a:	00003697          	auipc	a3,0x3
ffffffffc020217e:	55e68693          	addi	a3,a3,1374 # ffffffffc02056d8 <commands+0x10f0>
ffffffffc0202182:	00003617          	auipc	a2,0x3
ffffffffc0202186:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204d10 <commands+0x728>
ffffffffc020218a:	10e00593          	li	a1,270
ffffffffc020218e:	00003517          	auipc	a0,0x3
ffffffffc0202192:	2e250513          	addi	a0,a0,738 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202196:	f6dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020219a:	00003697          	auipc	a3,0x3
ffffffffc020219e:	51668693          	addi	a3,a3,1302 # ffffffffc02056b0 <commands+0x10c8>
ffffffffc02021a2:	00003617          	auipc	a2,0x3
ffffffffc02021a6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204d10 <commands+0x728>
ffffffffc02021aa:	10d00593          	li	a1,269
ffffffffc02021ae:	00003517          	auipc	a0,0x3
ffffffffc02021b2:	2c250513          	addi	a0,a0,706 # ffffffffc0205470 <commands+0xe88>
ffffffffc02021b6:	f4dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02021ba:	00003697          	auipc	a3,0x3
ffffffffc02021be:	4e668693          	addi	a3,a3,1254 # ffffffffc02056a0 <commands+0x10b8>
ffffffffc02021c2:	00003617          	auipc	a2,0x3
ffffffffc02021c6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204d10 <commands+0x728>
ffffffffc02021ca:	10800593          	li	a1,264
ffffffffc02021ce:	00003517          	auipc	a0,0x3
ffffffffc02021d2:	2a250513          	addi	a0,a0,674 # ffffffffc0205470 <commands+0xe88>
ffffffffc02021d6:	f2dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021da:	00003697          	auipc	a3,0x3
ffffffffc02021de:	3d668693          	addi	a3,a3,982 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc02021e2:	00003617          	auipc	a2,0x3
ffffffffc02021e6:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204d10 <commands+0x728>
ffffffffc02021ea:	10700593          	li	a1,263
ffffffffc02021ee:	00003517          	auipc	a0,0x3
ffffffffc02021f2:	28250513          	addi	a0,a0,642 # ffffffffc0205470 <commands+0xe88>
ffffffffc02021f6:	f0dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021fa:	00003697          	auipc	a3,0x3
ffffffffc02021fe:	48668693          	addi	a3,a3,1158 # ffffffffc0205680 <commands+0x1098>
ffffffffc0202202:	00003617          	auipc	a2,0x3
ffffffffc0202206:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204d10 <commands+0x728>
ffffffffc020220a:	10600593          	li	a1,262
ffffffffc020220e:	00003517          	auipc	a0,0x3
ffffffffc0202212:	26250513          	addi	a0,a0,610 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202216:	eedfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020221a:	00003697          	auipc	a3,0x3
ffffffffc020221e:	43668693          	addi	a3,a3,1078 # ffffffffc0205650 <commands+0x1068>
ffffffffc0202222:	00003617          	auipc	a2,0x3
ffffffffc0202226:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204d10 <commands+0x728>
ffffffffc020222a:	10500593          	li	a1,261
ffffffffc020222e:	00003517          	auipc	a0,0x3
ffffffffc0202232:	24250513          	addi	a0,a0,578 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202236:	ecdfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020223a:	00003697          	auipc	a3,0x3
ffffffffc020223e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0205638 <commands+0x1050>
ffffffffc0202242:	00003617          	auipc	a2,0x3
ffffffffc0202246:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204d10 <commands+0x728>
ffffffffc020224a:	10400593          	li	a1,260
ffffffffc020224e:	00003517          	auipc	a0,0x3
ffffffffc0202252:	22250513          	addi	a0,a0,546 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202256:	eadfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020225a:	00003697          	auipc	a3,0x3
ffffffffc020225e:	35668693          	addi	a3,a3,854 # ffffffffc02055b0 <commands+0xfc8>
ffffffffc0202262:	00003617          	auipc	a2,0x3
ffffffffc0202266:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204d10 <commands+0x728>
ffffffffc020226a:	0fe00593          	li	a1,254
ffffffffc020226e:	00003517          	auipc	a0,0x3
ffffffffc0202272:	20250513          	addi	a0,a0,514 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202276:	e8dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc020227a:	00003697          	auipc	a3,0x3
ffffffffc020227e:	3a668693          	addi	a3,a3,934 # ffffffffc0205620 <commands+0x1038>
ffffffffc0202282:	00003617          	auipc	a2,0x3
ffffffffc0202286:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204d10 <commands+0x728>
ffffffffc020228a:	0f900593          	li	a1,249
ffffffffc020228e:	00003517          	auipc	a0,0x3
ffffffffc0202292:	1e250513          	addi	a0,a0,482 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202296:	e6dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020229a:	00003697          	auipc	a3,0x3
ffffffffc020229e:	4a668693          	addi	a3,a3,1190 # ffffffffc0205740 <commands+0x1158>
ffffffffc02022a2:	00003617          	auipc	a2,0x3
ffffffffc02022a6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204d10 <commands+0x728>
ffffffffc02022aa:	11700593          	li	a1,279
ffffffffc02022ae:	00003517          	auipc	a0,0x3
ffffffffc02022b2:	1c250513          	addi	a0,a0,450 # ffffffffc0205470 <commands+0xe88>
ffffffffc02022b6:	e4dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc02022ba:	00003697          	auipc	a3,0x3
ffffffffc02022be:	4b668693          	addi	a3,a3,1206 # ffffffffc0205770 <commands+0x1188>
ffffffffc02022c2:	00003617          	auipc	a2,0x3
ffffffffc02022c6:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204d10 <commands+0x728>
ffffffffc02022ca:	12600593          	li	a1,294
ffffffffc02022ce:	00003517          	auipc	a0,0x3
ffffffffc02022d2:	1a250513          	addi	a0,a0,418 # ffffffffc0205470 <commands+0xe88>
ffffffffc02022d6:	e2dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022da:	00003697          	auipc	a3,0x3
ffffffffc02022de:	e1e68693          	addi	a3,a3,-482 # ffffffffc02050f8 <commands+0xb10>
ffffffffc02022e2:	00003617          	auipc	a2,0x3
ffffffffc02022e6:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204d10 <commands+0x728>
ffffffffc02022ea:	0f300593          	li	a1,243
ffffffffc02022ee:	00003517          	auipc	a0,0x3
ffffffffc02022f2:	18250513          	addi	a0,a0,386 # ffffffffc0205470 <commands+0xe88>
ffffffffc02022f6:	e0dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02022fa:	00003697          	auipc	a3,0x3
ffffffffc02022fe:	1ae68693          	addi	a3,a3,430 # ffffffffc02054a8 <commands+0xec0>
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204d10 <commands+0x728>
ffffffffc020230a:	0ba00593          	li	a1,186
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	16250513          	addi	a0,a0,354 # ffffffffc0205470 <commands+0xe88>
ffffffffc0202316:	dedfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020231a <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020231a:	1141                	addi	sp,sp,-16
ffffffffc020231c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020231e:	14058a63          	beqz	a1,ffffffffc0202472 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202322:	00359693          	slli	a3,a1,0x3
ffffffffc0202326:	96ae                	add	a3,a3,a1
ffffffffc0202328:	068e                	slli	a3,a3,0x3
ffffffffc020232a:	96aa                	add	a3,a3,a0
ffffffffc020232c:	87aa                	mv	a5,a0
ffffffffc020232e:	02d50263          	beq	a0,a3,ffffffffc0202352 <default_free_pages+0x38>
ffffffffc0202332:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202334:	8b05                	andi	a4,a4,1
ffffffffc0202336:	10071e63          	bnez	a4,ffffffffc0202452 <default_free_pages+0x138>
ffffffffc020233a:	6798                	ld	a4,8(a5)
ffffffffc020233c:	8b09                	andi	a4,a4,2
ffffffffc020233e:	10071a63          	bnez	a4,ffffffffc0202452 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202342:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202346:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020234a:	04878793          	addi	a5,a5,72
ffffffffc020234e:	fed792e3          	bne	a5,a3,ffffffffc0202332 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202352:	2581                	sext.w	a1,a1
ffffffffc0202354:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202356:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020235a:	4789                	li	a5,2
ffffffffc020235c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202360:	0000f697          	auipc	a3,0xf
ffffffffc0202364:	d7068693          	addi	a3,a3,-656 # ffffffffc02110d0 <free_area>
ffffffffc0202368:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020236a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020236c:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202370:	9db9                	addw	a1,a1,a4
ffffffffc0202372:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202374:	0ad78863          	beq	a5,a3,ffffffffc0202424 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202378:	fe078713          	addi	a4,a5,-32
ffffffffc020237c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202380:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202382:	00e56a63          	bltu	a0,a4,ffffffffc0202396 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202386:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202388:	06d70263          	beq	a4,a3,ffffffffc02023ec <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020238c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020238e:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202392:	fee57ae3          	bgeu	a0,a4,ffffffffc0202386 <default_free_pages+0x6c>
ffffffffc0202396:	c199                	beqz	a1,ffffffffc020239c <default_free_pages+0x82>
ffffffffc0202398:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020239c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020239e:	e390                	sd	a2,0(a5)
ffffffffc02023a0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02023a2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02023a4:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02023a6:	02d70063          	beq	a4,a3,ffffffffc02023c6 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02023aa:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02023ae:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02023b2:	02081613          	slli	a2,a6,0x20
ffffffffc02023b6:	9201                	srli	a2,a2,0x20
ffffffffc02023b8:	00361793          	slli	a5,a2,0x3
ffffffffc02023bc:	97b2                	add	a5,a5,a2
ffffffffc02023be:	078e                	slli	a5,a5,0x3
ffffffffc02023c0:	97ae                	add	a5,a5,a1
ffffffffc02023c2:	02f50f63          	beq	a0,a5,ffffffffc0202400 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02023c6:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02023c8:	00d70f63          	beq	a4,a3,ffffffffc02023e6 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02023cc:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02023ce:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02023d2:	02059613          	slli	a2,a1,0x20
ffffffffc02023d6:	9201                	srli	a2,a2,0x20
ffffffffc02023d8:	00361793          	slli	a5,a2,0x3
ffffffffc02023dc:	97b2                	add	a5,a5,a2
ffffffffc02023de:	078e                	slli	a5,a5,0x3
ffffffffc02023e0:	97aa                	add	a5,a5,a0
ffffffffc02023e2:	04f68863          	beq	a3,a5,ffffffffc0202432 <default_free_pages+0x118>
}
ffffffffc02023e6:	60a2                	ld	ra,8(sp)
ffffffffc02023e8:	0141                	addi	sp,sp,16
ffffffffc02023ea:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02023ec:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023ee:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02023f0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023f2:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023f4:	02d70563          	beq	a4,a3,ffffffffc020241e <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02023f8:	8832                	mv	a6,a2
ffffffffc02023fa:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02023fc:	87ba                	mv	a5,a4
ffffffffc02023fe:	bf41                	j	ffffffffc020238e <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0202400:	4d1c                	lw	a5,24(a0)
ffffffffc0202402:	0107883b          	addw	a6,a5,a6
ffffffffc0202406:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020240a:	57f5                	li	a5,-3
ffffffffc020240c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202410:	7110                	ld	a2,32(a0)
ffffffffc0202412:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0202414:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202416:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202418:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020241a:	e390                	sd	a2,0(a5)
ffffffffc020241c:	b775                	j	ffffffffc02023c8 <default_free_pages+0xae>
ffffffffc020241e:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202420:	873e                	mv	a4,a5
ffffffffc0202422:	b761                	j	ffffffffc02023aa <default_free_pages+0x90>
}
ffffffffc0202424:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202426:	e390                	sd	a2,0(a5)
ffffffffc0202428:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020242a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020242c:	f11c                	sd	a5,32(a0)
ffffffffc020242e:	0141                	addi	sp,sp,16
ffffffffc0202430:	8082                	ret
            base->property += p->property;
ffffffffc0202432:	ff872783          	lw	a5,-8(a4)
ffffffffc0202436:	fe870693          	addi	a3,a4,-24
ffffffffc020243a:	9dbd                	addw	a1,a1,a5
ffffffffc020243c:	cd0c                	sw	a1,24(a0)
ffffffffc020243e:	57f5                	li	a5,-3
ffffffffc0202440:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202444:	6314                	ld	a3,0(a4)
ffffffffc0202446:	671c                	ld	a5,8(a4)
}
ffffffffc0202448:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020244a:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020244c:	e394                	sd	a3,0(a5)
ffffffffc020244e:	0141                	addi	sp,sp,16
ffffffffc0202450:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202452:	00003697          	auipc	a3,0x3
ffffffffc0202456:	33668693          	addi	a3,a3,822 # ffffffffc0205788 <commands+0x11a0>
ffffffffc020245a:	00003617          	auipc	a2,0x3
ffffffffc020245e:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202462:	08300593          	li	a1,131
ffffffffc0202466:	00003517          	auipc	a0,0x3
ffffffffc020246a:	00a50513          	addi	a0,a0,10 # ffffffffc0205470 <commands+0xe88>
ffffffffc020246e:	c95fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202472:	00003697          	auipc	a3,0x3
ffffffffc0202476:	30e68693          	addi	a3,a3,782 # ffffffffc0205780 <commands+0x1198>
ffffffffc020247a:	00003617          	auipc	a2,0x3
ffffffffc020247e:	89660613          	addi	a2,a2,-1898 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202482:	08000593          	li	a1,128
ffffffffc0202486:	00003517          	auipc	a0,0x3
ffffffffc020248a:	fea50513          	addi	a0,a0,-22 # ffffffffc0205470 <commands+0xe88>
ffffffffc020248e:	c75fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202492 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202492:	c959                	beqz	a0,ffffffffc0202528 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202494:	0000f597          	auipc	a1,0xf
ffffffffc0202498:	c3c58593          	addi	a1,a1,-964 # ffffffffc02110d0 <free_area>
ffffffffc020249c:	0105a803          	lw	a6,16(a1)
ffffffffc02024a0:	862a                	mv	a2,a0
ffffffffc02024a2:	02081793          	slli	a5,a6,0x20
ffffffffc02024a6:	9381                	srli	a5,a5,0x20
ffffffffc02024a8:	00a7ee63          	bltu	a5,a0,ffffffffc02024c4 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02024ac:	87ae                	mv	a5,a1
ffffffffc02024ae:	a801                	j	ffffffffc02024be <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02024b0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024b4:	02071693          	slli	a3,a4,0x20
ffffffffc02024b8:	9281                	srli	a3,a3,0x20
ffffffffc02024ba:	00c6f763          	bgeu	a3,a2,ffffffffc02024c8 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02024be:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02024c0:	feb798e3          	bne	a5,a1,ffffffffc02024b0 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02024c4:	4501                	li	a0,0
}
ffffffffc02024c6:	8082                	ret
    return listelm->prev;
ffffffffc02024c8:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02024cc:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02024d0:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02024d4:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02024d8:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02024dc:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02024e0:	02d67b63          	bgeu	a2,a3,ffffffffc0202516 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02024e4:	00361693          	slli	a3,a2,0x3
ffffffffc02024e8:	96b2                	add	a3,a3,a2
ffffffffc02024ea:	068e                	slli	a3,a3,0x3
ffffffffc02024ec:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02024ee:	41c7073b          	subw	a4,a4,t3
ffffffffc02024f2:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024f4:	00868613          	addi	a2,a3,8
ffffffffc02024f8:	4709                	li	a4,2
ffffffffc02024fa:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02024fe:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202502:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202506:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020250a:	e310                	sd	a2,0(a4)
ffffffffc020250c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202510:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202512:	0316b023          	sd	a7,32(a3)
ffffffffc0202516:	41c8083b          	subw	a6,a6,t3
ffffffffc020251a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020251e:	5775                	li	a4,-3
ffffffffc0202520:	17a1                	addi	a5,a5,-24
ffffffffc0202522:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202526:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202528:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	25668693          	addi	a3,a3,598 # ffffffffc0205780 <commands+0x1198>
ffffffffc0202532:	00002617          	auipc	a2,0x2
ffffffffc0202536:	7de60613          	addi	a2,a2,2014 # ffffffffc0204d10 <commands+0x728>
ffffffffc020253a:	06200593          	li	a1,98
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	f3250513          	addi	a0,a0,-206 # ffffffffc0205470 <commands+0xe88>
default_alloc_pages(size_t n) {
ffffffffc0202546:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202548:	bbbfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020254c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020254c:	1141                	addi	sp,sp,-16
ffffffffc020254e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202550:	c9e1                	beqz	a1,ffffffffc0202620 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202552:	00359693          	slli	a3,a1,0x3
ffffffffc0202556:	96ae                	add	a3,a3,a1
ffffffffc0202558:	068e                	slli	a3,a3,0x3
ffffffffc020255a:	96aa                	add	a3,a3,a0
ffffffffc020255c:	87aa                	mv	a5,a0
ffffffffc020255e:	00d50f63          	beq	a0,a3,ffffffffc020257c <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202562:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202564:	8b05                	andi	a4,a4,1
ffffffffc0202566:	cf49                	beqz	a4,ffffffffc0202600 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202568:	0007ac23          	sw	zero,24(a5)
ffffffffc020256c:	0007b423          	sd	zero,8(a5)
ffffffffc0202570:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202574:	04878793          	addi	a5,a5,72
ffffffffc0202578:	fed795e3          	bne	a5,a3,ffffffffc0202562 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020257c:	2581                	sext.w	a1,a1
ffffffffc020257e:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202580:	4789                	li	a5,2
ffffffffc0202582:	00850713          	addi	a4,a0,8
ffffffffc0202586:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020258a:	0000f697          	auipc	a3,0xf
ffffffffc020258e:	b4668693          	addi	a3,a3,-1210 # ffffffffc02110d0 <free_area>
ffffffffc0202592:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202594:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202596:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020259a:	9db9                	addw	a1,a1,a4
ffffffffc020259c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020259e:	04d78a63          	beq	a5,a3,ffffffffc02025f2 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02025a2:	fe078713          	addi	a4,a5,-32
ffffffffc02025a6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02025aa:	4581                	li	a1,0
            if (base < page) {
ffffffffc02025ac:	00e56a63          	bltu	a0,a4,ffffffffc02025c0 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02025b0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02025b2:	02d70263          	beq	a4,a3,ffffffffc02025d6 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02025b6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02025b8:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02025bc:	fee57ae3          	bgeu	a0,a4,ffffffffc02025b0 <default_init_memmap+0x64>
ffffffffc02025c0:	c199                	beqz	a1,ffffffffc02025c6 <default_init_memmap+0x7a>
ffffffffc02025c2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02025c6:	6398                	ld	a4,0(a5)
}
ffffffffc02025c8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02025ca:	e390                	sd	a2,0(a5)
ffffffffc02025cc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02025ce:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025d0:	f118                	sd	a4,32(a0)
ffffffffc02025d2:	0141                	addi	sp,sp,16
ffffffffc02025d4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02025d6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025d8:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02025da:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02025dc:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02025de:	00d70663          	beq	a4,a3,ffffffffc02025ea <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02025e2:	8832                	mv	a6,a2
ffffffffc02025e4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02025e6:	87ba                	mv	a5,a4
ffffffffc02025e8:	bfc1                	j	ffffffffc02025b8 <default_init_memmap+0x6c>
}
ffffffffc02025ea:	60a2                	ld	ra,8(sp)
ffffffffc02025ec:	e290                	sd	a2,0(a3)
ffffffffc02025ee:	0141                	addi	sp,sp,16
ffffffffc02025f0:	8082                	ret
ffffffffc02025f2:	60a2                	ld	ra,8(sp)
ffffffffc02025f4:	e390                	sd	a2,0(a5)
ffffffffc02025f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025f8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025fa:	f11c                	sd	a5,32(a0)
ffffffffc02025fc:	0141                	addi	sp,sp,16
ffffffffc02025fe:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202600:	00003697          	auipc	a3,0x3
ffffffffc0202604:	1b068693          	addi	a3,a3,432 # ffffffffc02057b0 <commands+0x11c8>
ffffffffc0202608:	00002617          	auipc	a2,0x2
ffffffffc020260c:	70860613          	addi	a2,a2,1800 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202610:	04900593          	li	a1,73
ffffffffc0202614:	00003517          	auipc	a0,0x3
ffffffffc0202618:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205470 <commands+0xe88>
ffffffffc020261c:	ae7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202620:	00003697          	auipc	a3,0x3
ffffffffc0202624:	16068693          	addi	a3,a3,352 # ffffffffc0205780 <commands+0x1198>
ffffffffc0202628:	00002617          	auipc	a2,0x2
ffffffffc020262c:	6e860613          	addi	a2,a2,1768 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202630:	04600593          	li	a1,70
ffffffffc0202634:	00003517          	auipc	a0,0x3
ffffffffc0202638:	e3c50513          	addi	a0,a0,-452 # ffffffffc0205470 <commands+0xe88>
ffffffffc020263c:	ac7fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202640 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202640:	4501                	li	a0,0
ffffffffc0202642:	8082                	ret

ffffffffc0202644 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202644:	4501                	li	a0,0
ffffffffc0202646:	8082                	ret

ffffffffc0202648 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202648:	4501                	li	a0,0
ffffffffc020264a:	8082                	ret

ffffffffc020264c <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020264c:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020264e:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0202650:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202652:	678d                	lui	a5,0x3
ffffffffc0202654:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202658:	0000f697          	auipc	a3,0xf
ffffffffc020265c:	eb06a683          	lw	a3,-336(a3) # ffffffffc0211508 <pgfault_num>
ffffffffc0202660:	4711                	li	a4,4
ffffffffc0202662:	0ae69363          	bne	a3,a4,ffffffffc0202708 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202666:	6705                	lui	a4,0x1
ffffffffc0202668:	4629                	li	a2,10
ffffffffc020266a:	0000f797          	auipc	a5,0xf
ffffffffc020266e:	e9e78793          	addi	a5,a5,-354 # ffffffffc0211508 <pgfault_num>
ffffffffc0202672:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202676:	4398                	lw	a4,0(a5)
ffffffffc0202678:	2701                	sext.w	a4,a4
ffffffffc020267a:	20d71763          	bne	a4,a3,ffffffffc0202888 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020267e:	6691                	lui	a3,0x4
ffffffffc0202680:	4635                	li	a2,13
ffffffffc0202682:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0202686:	4394                	lw	a3,0(a5)
ffffffffc0202688:	2681                	sext.w	a3,a3
ffffffffc020268a:	1ce69f63          	bne	a3,a4,ffffffffc0202868 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020268e:	6709                	lui	a4,0x2
ffffffffc0202690:	462d                	li	a2,11
ffffffffc0202692:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0202696:	4398                	lw	a4,0(a5)
ffffffffc0202698:	2701                	sext.w	a4,a4
ffffffffc020269a:	1ad71763          	bne	a4,a3,ffffffffc0202848 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020269e:	6715                	lui	a4,0x5
ffffffffc02026a0:	46b9                	li	a3,14
ffffffffc02026a2:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026a6:	4398                	lw	a4,0(a5)
ffffffffc02026a8:	4695                	li	a3,5
ffffffffc02026aa:	2701                	sext.w	a4,a4
ffffffffc02026ac:	16d71e63          	bne	a4,a3,ffffffffc0202828 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02026b0:	4394                	lw	a3,0(a5)
ffffffffc02026b2:	2681                	sext.w	a3,a3
ffffffffc02026b4:	14e69a63          	bne	a3,a4,ffffffffc0202808 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02026b8:	4398                	lw	a4,0(a5)
ffffffffc02026ba:	2701                	sext.w	a4,a4
ffffffffc02026bc:	12d71663          	bne	a4,a3,ffffffffc02027e8 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02026c0:	4394                	lw	a3,0(a5)
ffffffffc02026c2:	2681                	sext.w	a3,a3
ffffffffc02026c4:	10e69263          	bne	a3,a4,ffffffffc02027c8 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02026c8:	4398                	lw	a4,0(a5)
ffffffffc02026ca:	2701                	sext.w	a4,a4
ffffffffc02026cc:	0cd71e63          	bne	a4,a3,ffffffffc02027a8 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02026d0:	4394                	lw	a3,0(a5)
ffffffffc02026d2:	2681                	sext.w	a3,a3
ffffffffc02026d4:	0ae69a63          	bne	a3,a4,ffffffffc0202788 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026d8:	6715                	lui	a4,0x5
ffffffffc02026da:	46b9                	li	a3,14
ffffffffc02026dc:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026e0:	4398                	lw	a4,0(a5)
ffffffffc02026e2:	4695                	li	a3,5
ffffffffc02026e4:	2701                	sext.w	a4,a4
ffffffffc02026e6:	08d71163          	bne	a4,a3,ffffffffc0202768 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026ea:	6705                	lui	a4,0x1
ffffffffc02026ec:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02026f0:	4729                	li	a4,10
ffffffffc02026f2:	04e69b63          	bne	a3,a4,ffffffffc0202748 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc02026f6:	439c                	lw	a5,0(a5)
ffffffffc02026f8:	4719                	li	a4,6
ffffffffc02026fa:	2781                	sext.w	a5,a5
ffffffffc02026fc:	02e79663          	bne	a5,a4,ffffffffc0202728 <_clock_check_swap+0xdc>
}
ffffffffc0202700:	60a2                	ld	ra,8(sp)
ffffffffc0202702:	4501                	li	a0,0
ffffffffc0202704:	0141                	addi	sp,sp,16
ffffffffc0202706:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202708:	00003697          	auipc	a3,0x3
ffffffffc020270c:	b8068693          	addi	a3,a3,-1152 # ffffffffc0205288 <commands+0xca0>
ffffffffc0202710:	00002617          	auipc	a2,0x2
ffffffffc0202714:	60060613          	addi	a2,a2,1536 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202718:	07700593          	li	a1,119
ffffffffc020271c:	00003517          	auipc	a0,0x3
ffffffffc0202720:	0f450513          	addi	a0,a0,244 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202724:	9dffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc0202728:	00003697          	auipc	a3,0x3
ffffffffc020272c:	13868693          	addi	a3,a3,312 # ffffffffc0205860 <default_pmm_manager+0x88>
ffffffffc0202730:	00002617          	auipc	a2,0x2
ffffffffc0202734:	5e060613          	addi	a2,a2,1504 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202738:	08e00593          	li	a1,142
ffffffffc020273c:	00003517          	auipc	a0,0x3
ffffffffc0202740:	0d450513          	addi	a0,a0,212 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202744:	9bffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202748:	00003697          	auipc	a3,0x3
ffffffffc020274c:	0f068693          	addi	a3,a3,240 # ffffffffc0205838 <default_pmm_manager+0x60>
ffffffffc0202750:	00002617          	auipc	a2,0x2
ffffffffc0202754:	5c060613          	addi	a2,a2,1472 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202758:	08c00593          	li	a1,140
ffffffffc020275c:	00003517          	auipc	a0,0x3
ffffffffc0202760:	0b450513          	addi	a0,a0,180 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202764:	99ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202768:	00003697          	auipc	a3,0x3
ffffffffc020276c:	0c068693          	addi	a3,a3,192 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc0202770:	00002617          	auipc	a2,0x2
ffffffffc0202774:	5a060613          	addi	a2,a2,1440 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202778:	08b00593          	li	a1,139
ffffffffc020277c:	00003517          	auipc	a0,0x3
ffffffffc0202780:	09450513          	addi	a0,a0,148 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202784:	97ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202788:	00003697          	auipc	a3,0x3
ffffffffc020278c:	0a068693          	addi	a3,a3,160 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc0202790:	00002617          	auipc	a2,0x2
ffffffffc0202794:	58060613          	addi	a2,a2,1408 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202798:	08900593          	li	a1,137
ffffffffc020279c:	00003517          	auipc	a0,0x3
ffffffffc02027a0:	07450513          	addi	a0,a0,116 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02027a4:	95ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027a8:	00003697          	auipc	a3,0x3
ffffffffc02027ac:	08068693          	addi	a3,a3,128 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc02027b0:	00002617          	auipc	a2,0x2
ffffffffc02027b4:	56060613          	addi	a2,a2,1376 # ffffffffc0204d10 <commands+0x728>
ffffffffc02027b8:	08700593          	li	a1,135
ffffffffc02027bc:	00003517          	auipc	a0,0x3
ffffffffc02027c0:	05450513          	addi	a0,a0,84 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02027c4:	93ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027c8:	00003697          	auipc	a3,0x3
ffffffffc02027cc:	06068693          	addi	a3,a3,96 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc02027d0:	00002617          	auipc	a2,0x2
ffffffffc02027d4:	54060613          	addi	a2,a2,1344 # ffffffffc0204d10 <commands+0x728>
ffffffffc02027d8:	08500593          	li	a1,133
ffffffffc02027dc:	00003517          	auipc	a0,0x3
ffffffffc02027e0:	03450513          	addi	a0,a0,52 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02027e4:	91ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027e8:	00003697          	auipc	a3,0x3
ffffffffc02027ec:	04068693          	addi	a3,a3,64 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc02027f0:	00002617          	auipc	a2,0x2
ffffffffc02027f4:	52060613          	addi	a2,a2,1312 # ffffffffc0204d10 <commands+0x728>
ffffffffc02027f8:	08300593          	li	a1,131
ffffffffc02027fc:	00003517          	auipc	a0,0x3
ffffffffc0202800:	01450513          	addi	a0,a0,20 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202804:	8fffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202808:	00003697          	auipc	a3,0x3
ffffffffc020280c:	02068693          	addi	a3,a3,32 # ffffffffc0205828 <default_pmm_manager+0x50>
ffffffffc0202810:	00002617          	auipc	a2,0x2
ffffffffc0202814:	50060613          	addi	a2,a2,1280 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202818:	08100593          	li	a1,129
ffffffffc020281c:	00003517          	auipc	a0,0x3
ffffffffc0202820:	ff450513          	addi	a0,a0,-12 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202824:	8dffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202828:	00003697          	auipc	a3,0x3
ffffffffc020282c:	00068693          	mv	a3,a3
ffffffffc0202830:	00002617          	auipc	a2,0x2
ffffffffc0202834:	4e060613          	addi	a2,a2,1248 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202838:	07f00593          	li	a1,127
ffffffffc020283c:	00003517          	auipc	a0,0x3
ffffffffc0202840:	fd450513          	addi	a0,a0,-44 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202844:	8bffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202848:	00003697          	auipc	a3,0x3
ffffffffc020284c:	a4068693          	addi	a3,a3,-1472 # ffffffffc0205288 <commands+0xca0>
ffffffffc0202850:	00002617          	auipc	a2,0x2
ffffffffc0202854:	4c060613          	addi	a2,a2,1216 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202858:	07d00593          	li	a1,125
ffffffffc020285c:	00003517          	auipc	a0,0x3
ffffffffc0202860:	fb450513          	addi	a0,a0,-76 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202864:	89ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202868:	00003697          	auipc	a3,0x3
ffffffffc020286c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0205288 <commands+0xca0>
ffffffffc0202870:	00002617          	auipc	a2,0x2
ffffffffc0202874:	4a060613          	addi	a2,a2,1184 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202878:	07b00593          	li	a1,123
ffffffffc020287c:	00003517          	auipc	a0,0x3
ffffffffc0202880:	f9450513          	addi	a0,a0,-108 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc0202884:	87ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202888:	00003697          	auipc	a3,0x3
ffffffffc020288c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205288 <commands+0xca0>
ffffffffc0202890:	00002617          	auipc	a2,0x2
ffffffffc0202894:	48060613          	addi	a2,a2,1152 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202898:	07900593          	li	a1,121
ffffffffc020289c:	00003517          	auipc	a0,0x3
ffffffffc02028a0:	f7450513          	addi	a0,a0,-140 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02028a4:	85ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02028a8 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc02028a8:	751c                	ld	a5,40(a0)
{
ffffffffc02028aa:	1141                	addi	sp,sp,-16
ffffffffc02028ac:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02028ae:	c39d                	beqz	a5,ffffffffc02028d4 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc02028b0:	e211                	bnez	a2,ffffffffc02028b4 <_clock_swap_out_victim+0xc>
    while (1) {
ffffffffc02028b2:	a001                	j	ffffffffc02028b2 <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc02028b4:	00003697          	auipc	a3,0x3
ffffffffc02028b8:	fcc68693          	addi	a3,a3,-52 # ffffffffc0205880 <default_pmm_manager+0xa8>
ffffffffc02028bc:	00002617          	auipc	a2,0x2
ffffffffc02028c0:	45460613          	addi	a2,a2,1108 # ffffffffc0204d10 <commands+0x728>
ffffffffc02028c4:	04400593          	li	a1,68
ffffffffc02028c8:	00003517          	auipc	a0,0x3
ffffffffc02028cc:	f4850513          	addi	a0,a0,-184 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02028d0:	833fd0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(head != NULL);
ffffffffc02028d4:	00003697          	auipc	a3,0x3
ffffffffc02028d8:	f9c68693          	addi	a3,a3,-100 # ffffffffc0205870 <default_pmm_manager+0x98>
ffffffffc02028dc:	00002617          	auipc	a2,0x2
ffffffffc02028e0:	43460613          	addi	a2,a2,1076 # ffffffffc0204d10 <commands+0x728>
ffffffffc02028e4:	04300593          	li	a1,67
ffffffffc02028e8:	00003517          	auipc	a0,0x3
ffffffffc02028ec:	f2850513          	addi	a0,a0,-216 # ffffffffc0205810 <default_pmm_manager+0x38>
ffffffffc02028f0:	813fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02028f4 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02028f4:	0000f797          	auipc	a5,0xf
ffffffffc02028f8:	c347b783          	ld	a5,-972(a5) # ffffffffc0211528 <curr_ptr>
ffffffffc02028fc:	c399                	beqz	a5,ffffffffc0202902 <_clock_map_swappable+0xe>
}
ffffffffc02028fe:	4501                	li	a0,0
ffffffffc0202900:	8082                	ret
{
ffffffffc0202902:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0202904:	00003697          	auipc	a3,0x3
ffffffffc0202908:	f8c68693          	addi	a3,a3,-116 # ffffffffc0205890 <default_pmm_manager+0xb8>
ffffffffc020290c:	00002617          	auipc	a2,0x2
ffffffffc0202910:	40460613          	addi	a2,a2,1028 # ffffffffc0204d10 <commands+0x728>
ffffffffc0202914:	03300593          	li	a1,51
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	ef850513          	addi	a0,a0,-264 # ffffffffc0205810 <default_pmm_manager+0x38>
{
ffffffffc0202920:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0202922:	fe0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202926 <_clock_tick_event>:
ffffffffc0202926:	4501                	li	a0,0
ffffffffc0202928:	8082                	ret

ffffffffc020292a <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020292a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020292c:	00002617          	auipc	a2,0x2
ffffffffc0202930:	63460613          	addi	a2,a2,1588 # ffffffffc0204f60 <commands+0x978>
ffffffffc0202934:	06500593          	li	a1,101
ffffffffc0202938:	00002517          	auipc	a0,0x2
ffffffffc020293c:	64850513          	addi	a0,a0,1608 # ffffffffc0204f80 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202940:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202942:	fc0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202946 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202946:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202948:	00003617          	auipc	a2,0x3
ffffffffc020294c:	97860613          	addi	a2,a2,-1672 # ffffffffc02052c0 <commands+0xcd8>
ffffffffc0202950:	07000593          	li	a1,112
ffffffffc0202954:	00002517          	auipc	a0,0x2
ffffffffc0202958:	62c50513          	addi	a0,a0,1580 # ffffffffc0204f80 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc020295c:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020295e:	fa4fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202962 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202962:	7139                	addi	sp,sp,-64
ffffffffc0202964:	f426                	sd	s1,40(sp)
ffffffffc0202966:	f04a                	sd	s2,32(sp)
ffffffffc0202968:	ec4e                	sd	s3,24(sp)
ffffffffc020296a:	e852                	sd	s4,16(sp)
ffffffffc020296c:	e456                	sd	s5,8(sp)
ffffffffc020296e:	e05a                	sd	s6,0(sp)
ffffffffc0202970:	fc06                	sd	ra,56(sp)
ffffffffc0202972:	f822                	sd	s0,48(sp)
ffffffffc0202974:	84aa                	mv	s1,a0
ffffffffc0202976:	0000f917          	auipc	s2,0xf
ffffffffc020297a:	bda90913          	addi	s2,s2,-1062 # ffffffffc0211550 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020297e:	4a05                	li	s4,1
ffffffffc0202980:	0000fa97          	auipc	s5,0xf
ffffffffc0202984:	ba0a8a93          	addi	s5,s5,-1120 # ffffffffc0211520 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202988:	0005099b          	sext.w	s3,a0
ffffffffc020298c:	0000fb17          	auipc	s6,0xf
ffffffffc0202990:	b74b0b13          	addi	s6,s6,-1164 # ffffffffc0211500 <check_mm_struct>
ffffffffc0202994:	a01d                	j	ffffffffc02029ba <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202996:	00093783          	ld	a5,0(s2)
ffffffffc020299a:	6f9c                	ld	a5,24(a5)
ffffffffc020299c:	9782                	jalr	a5
ffffffffc020299e:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02029a0:	4601                	li	a2,0
ffffffffc02029a2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02029a4:	ec0d                	bnez	s0,ffffffffc02029de <alloc_pages+0x7c>
ffffffffc02029a6:	029a6c63          	bltu	s4,s1,ffffffffc02029de <alloc_pages+0x7c>
ffffffffc02029aa:	000aa783          	lw	a5,0(s5)
ffffffffc02029ae:	2781                	sext.w	a5,a5
ffffffffc02029b0:	c79d                	beqz	a5,ffffffffc02029de <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc02029b2:	000b3503          	ld	a0,0(s6)
ffffffffc02029b6:	824ff0ef          	jal	ra,ffffffffc02019da <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029ba:	100027f3          	csrr	a5,sstatus
ffffffffc02029be:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02029c0:	8526                	mv	a0,s1
ffffffffc02029c2:	dbf1                	beqz	a5,ffffffffc0202996 <alloc_pages+0x34>
        intr_disable();
ffffffffc02029c4:	b2bfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02029c8:	00093783          	ld	a5,0(s2)
ffffffffc02029cc:	8526                	mv	a0,s1
ffffffffc02029ce:	6f9c                	ld	a5,24(a5)
ffffffffc02029d0:	9782                	jalr	a5
ffffffffc02029d2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02029d4:	b15fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc02029d8:	4601                	li	a2,0
ffffffffc02029da:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02029dc:	d469                	beqz	s0,ffffffffc02029a6 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02029de:	70e2                	ld	ra,56(sp)
ffffffffc02029e0:	8522                	mv	a0,s0
ffffffffc02029e2:	7442                	ld	s0,48(sp)
ffffffffc02029e4:	74a2                	ld	s1,40(sp)
ffffffffc02029e6:	7902                	ld	s2,32(sp)
ffffffffc02029e8:	69e2                	ld	s3,24(sp)
ffffffffc02029ea:	6a42                	ld	s4,16(sp)
ffffffffc02029ec:	6aa2                	ld	s5,8(sp)
ffffffffc02029ee:	6b02                	ld	s6,0(sp)
ffffffffc02029f0:	6121                	addi	sp,sp,64
ffffffffc02029f2:	8082                	ret

ffffffffc02029f4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029f4:	100027f3          	csrr	a5,sstatus
ffffffffc02029f8:	8b89                	andi	a5,a5,2
ffffffffc02029fa:	e799                	bnez	a5,ffffffffc0202a08 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02029fc:	0000f797          	auipc	a5,0xf
ffffffffc0202a00:	b547b783          	ld	a5,-1196(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202a04:	739c                	ld	a5,32(a5)
ffffffffc0202a06:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202a08:	1101                	addi	sp,sp,-32
ffffffffc0202a0a:	ec06                	sd	ra,24(sp)
ffffffffc0202a0c:	e822                	sd	s0,16(sp)
ffffffffc0202a0e:	e426                	sd	s1,8(sp)
ffffffffc0202a10:	842a                	mv	s0,a0
ffffffffc0202a12:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202a14:	adbfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a18:	0000f797          	auipc	a5,0xf
ffffffffc0202a1c:	b387b783          	ld	a5,-1224(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202a20:	739c                	ld	a5,32(a5)
ffffffffc0202a22:	85a6                	mv	a1,s1
ffffffffc0202a24:	8522                	mv	a0,s0
ffffffffc0202a26:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202a28:	6442                	ld	s0,16(sp)
ffffffffc0202a2a:	60e2                	ld	ra,24(sp)
ffffffffc0202a2c:	64a2                	ld	s1,8(sp)
ffffffffc0202a2e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202a30:	ab9fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202a34 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a34:	100027f3          	csrr	a5,sstatus
ffffffffc0202a38:	8b89                	andi	a5,a5,2
ffffffffc0202a3a:	e799                	bnez	a5,ffffffffc0202a48 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202a3c:	0000f797          	auipc	a5,0xf
ffffffffc0202a40:	b147b783          	ld	a5,-1260(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202a44:	779c                	ld	a5,40(a5)
ffffffffc0202a46:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202a48:	1141                	addi	sp,sp,-16
ffffffffc0202a4a:	e406                	sd	ra,8(sp)
ffffffffc0202a4c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202a4e:	aa1fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202a52:	0000f797          	auipc	a5,0xf
ffffffffc0202a56:	afe7b783          	ld	a5,-1282(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202a5a:	779c                	ld	a5,40(a5)
ffffffffc0202a5c:	9782                	jalr	a5
ffffffffc0202a5e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a60:	a89fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202a64:	60a2                	ld	ra,8(sp)
ffffffffc0202a66:	8522                	mv	a0,s0
ffffffffc0202a68:	6402                	ld	s0,0(sp)
ffffffffc0202a6a:	0141                	addi	sp,sp,16
ffffffffc0202a6c:	8082                	ret

ffffffffc0202a6e <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202a6e:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202a72:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202a76:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202a78:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202a7a:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202a7c:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202a80:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202a82:	f84a                	sd	s2,48(sp)
ffffffffc0202a84:	f44e                	sd	s3,40(sp)
ffffffffc0202a86:	f052                	sd	s4,32(sp)
ffffffffc0202a88:	e486                	sd	ra,72(sp)
ffffffffc0202a8a:	e0a2                	sd	s0,64(sp)
ffffffffc0202a8c:	ec56                	sd	s5,24(sp)
ffffffffc0202a8e:	e85a                	sd	s6,16(sp)
ffffffffc0202a90:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202a92:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202a96:	892e                	mv	s2,a1
ffffffffc0202a98:	8a32                	mv	s4,a2
ffffffffc0202a9a:	0000f997          	auipc	s3,0xf
ffffffffc0202a9e:	aa698993          	addi	s3,s3,-1370 # ffffffffc0211540 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202aa2:	efb5                	bnez	a5,ffffffffc0202b1e <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202aa4:	14060c63          	beqz	a2,ffffffffc0202bfc <get_pte+0x18e>
ffffffffc0202aa8:	4505                	li	a0,1
ffffffffc0202aaa:	eb9ff0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0202aae:	842a                	mv	s0,a0
ffffffffc0202ab0:	14050663          	beqz	a0,ffffffffc0202bfc <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ab4:	0000fb97          	auipc	s7,0xf
ffffffffc0202ab8:	a94b8b93          	addi	s7,s7,-1388 # ffffffffc0211548 <pages>
ffffffffc0202abc:	000bb503          	ld	a0,0(s7)
ffffffffc0202ac0:	00003b17          	auipc	s6,0x3
ffffffffc0202ac4:	6a8b3b03          	ld	s6,1704(s6) # ffffffffc0206168 <error_string+0x38>
ffffffffc0202ac8:	00080ab7          	lui	s5,0x80
ffffffffc0202acc:	40a40533          	sub	a0,s0,a0
ffffffffc0202ad0:	850d                	srai	a0,a0,0x3
ffffffffc0202ad2:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202ad6:	0000f997          	auipc	s3,0xf
ffffffffc0202ada:	a6a98993          	addi	s3,s3,-1430 # ffffffffc0211540 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202ade:	4785                	li	a5,1
ffffffffc0202ae0:	0009b703          	ld	a4,0(s3)
ffffffffc0202ae4:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ae6:	9556                	add	a0,a0,s5
ffffffffc0202ae8:	00c51793          	slli	a5,a0,0xc
ffffffffc0202aec:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aee:	0532                	slli	a0,a0,0xc
ffffffffc0202af0:	14e7fd63          	bgeu	a5,a4,ffffffffc0202c4a <get_pte+0x1dc>
ffffffffc0202af4:	0000f797          	auipc	a5,0xf
ffffffffc0202af8:	a647b783          	ld	a5,-1436(a5) # ffffffffc0211558 <va_pa_offset>
ffffffffc0202afc:	6605                	lui	a2,0x1
ffffffffc0202afe:	4581                	li	a1,0
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	3a2010ef          	jal	ra,ffffffffc0203ea4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b06:	000bb683          	ld	a3,0(s7)
ffffffffc0202b0a:	40d406b3          	sub	a3,s0,a3
ffffffffc0202b0e:	868d                	srai	a3,a3,0x3
ffffffffc0202b10:	036686b3          	mul	a3,a3,s6
ffffffffc0202b14:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202b16:	06aa                	slli	a3,a3,0xa
ffffffffc0202b18:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202b1c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202b1e:	77fd                	lui	a5,0xfffff
ffffffffc0202b20:	068a                	slli	a3,a3,0x2
ffffffffc0202b22:	0009b703          	ld	a4,0(s3)
ffffffffc0202b26:	8efd                	and	a3,a3,a5
ffffffffc0202b28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202b2c:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202c00 <get_pte+0x192>
ffffffffc0202b30:	0000fa97          	auipc	s5,0xf
ffffffffc0202b34:	a28a8a93          	addi	s5,s5,-1496 # ffffffffc0211558 <va_pa_offset>
ffffffffc0202b38:	000ab403          	ld	s0,0(s5)
ffffffffc0202b3c:	01595793          	srli	a5,s2,0x15
ffffffffc0202b40:	1ff7f793          	andi	a5,a5,511
ffffffffc0202b44:	96a2                	add	a3,a3,s0
ffffffffc0202b46:	00379413          	slli	s0,a5,0x3
ffffffffc0202b4a:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202b4c:	6014                	ld	a3,0(s0)
ffffffffc0202b4e:	0016f793          	andi	a5,a3,1
ffffffffc0202b52:	ebad                	bnez	a5,ffffffffc0202bc4 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b54:	0a0a0463          	beqz	s4,ffffffffc0202bfc <get_pte+0x18e>
ffffffffc0202b58:	4505                	li	a0,1
ffffffffc0202b5a:	e09ff0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0202b5e:	84aa                	mv	s1,a0
ffffffffc0202b60:	cd51                	beqz	a0,ffffffffc0202bfc <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b62:	0000fb97          	auipc	s7,0xf
ffffffffc0202b66:	9e6b8b93          	addi	s7,s7,-1562 # ffffffffc0211548 <pages>
ffffffffc0202b6a:	000bb503          	ld	a0,0(s7)
ffffffffc0202b6e:	00003b17          	auipc	s6,0x3
ffffffffc0202b72:	5fab3b03          	ld	s6,1530(s6) # ffffffffc0206168 <error_string+0x38>
ffffffffc0202b76:	00080a37          	lui	s4,0x80
ffffffffc0202b7a:	40a48533          	sub	a0,s1,a0
ffffffffc0202b7e:	850d                	srai	a0,a0,0x3
ffffffffc0202b80:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b84:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b86:	0009b703          	ld	a4,0(s3)
ffffffffc0202b8a:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b8c:	9552                	add	a0,a0,s4
ffffffffc0202b8e:	00c51793          	slli	a5,a0,0xc
ffffffffc0202b92:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b94:	0532                	slli	a0,a0,0xc
ffffffffc0202b96:	08e7fd63          	bgeu	a5,a4,ffffffffc0202c30 <get_pte+0x1c2>
ffffffffc0202b9a:	000ab783          	ld	a5,0(s5)
ffffffffc0202b9e:	6605                	lui	a2,0x1
ffffffffc0202ba0:	4581                	li	a1,0
ffffffffc0202ba2:	953e                	add	a0,a0,a5
ffffffffc0202ba4:	300010ef          	jal	ra,ffffffffc0203ea4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ba8:	000bb683          	ld	a3,0(s7)
ffffffffc0202bac:	40d486b3          	sub	a3,s1,a3
ffffffffc0202bb0:	868d                	srai	a3,a3,0x3
ffffffffc0202bb2:	036686b3          	mul	a3,a3,s6
ffffffffc0202bb6:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202bb8:	06aa                	slli	a3,a3,0xa
ffffffffc0202bba:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202bbe:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202bc0:	0009b703          	ld	a4,0(s3)
ffffffffc0202bc4:	068a                	slli	a3,a3,0x2
ffffffffc0202bc6:	757d                	lui	a0,0xfffff
ffffffffc0202bc8:	8ee9                	and	a3,a3,a0
ffffffffc0202bca:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202bce:	04e7f563          	bgeu	a5,a4,ffffffffc0202c18 <get_pte+0x1aa>
ffffffffc0202bd2:	000ab503          	ld	a0,0(s5)
ffffffffc0202bd6:	00c95913          	srli	s2,s2,0xc
ffffffffc0202bda:	1ff97913          	andi	s2,s2,511
ffffffffc0202bde:	96aa                	add	a3,a3,a0
ffffffffc0202be0:	00391513          	slli	a0,s2,0x3
ffffffffc0202be4:	9536                	add	a0,a0,a3
}
ffffffffc0202be6:	60a6                	ld	ra,72(sp)
ffffffffc0202be8:	6406                	ld	s0,64(sp)
ffffffffc0202bea:	74e2                	ld	s1,56(sp)
ffffffffc0202bec:	7942                	ld	s2,48(sp)
ffffffffc0202bee:	79a2                	ld	s3,40(sp)
ffffffffc0202bf0:	7a02                	ld	s4,32(sp)
ffffffffc0202bf2:	6ae2                	ld	s5,24(sp)
ffffffffc0202bf4:	6b42                	ld	s6,16(sp)
ffffffffc0202bf6:	6ba2                	ld	s7,8(sp)
ffffffffc0202bf8:	6161                	addi	sp,sp,80
ffffffffc0202bfa:	8082                	ret
            return NULL;
ffffffffc0202bfc:	4501                	li	a0,0
ffffffffc0202bfe:	b7e5                	j	ffffffffc0202be6 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c00:	00003617          	auipc	a2,0x3
ffffffffc0202c04:	cd060613          	addi	a2,a2,-816 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0202c08:	10200593          	li	a1,258
ffffffffc0202c0c:	00003517          	auipc	a0,0x3
ffffffffc0202c10:	cec50513          	addi	a0,a0,-788 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0202c14:	ceefd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c18:	00003617          	auipc	a2,0x3
ffffffffc0202c1c:	cb860613          	addi	a2,a2,-840 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0202c20:	10f00593          	li	a1,271
ffffffffc0202c24:	00003517          	auipc	a0,0x3
ffffffffc0202c28:	cd450513          	addi	a0,a0,-812 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0202c2c:	cd6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c30:	86aa                	mv	a3,a0
ffffffffc0202c32:	00003617          	auipc	a2,0x3
ffffffffc0202c36:	c9e60613          	addi	a2,a2,-866 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0202c3a:	10b00593          	li	a1,267
ffffffffc0202c3e:	00003517          	auipc	a0,0x3
ffffffffc0202c42:	cba50513          	addi	a0,a0,-838 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0202c46:	cbcfd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c4a:	86aa                	mv	a3,a0
ffffffffc0202c4c:	00003617          	auipc	a2,0x3
ffffffffc0202c50:	c8460613          	addi	a2,a2,-892 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0202c54:	0ff00593          	li	a1,255
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	ca050513          	addi	a0,a0,-864 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0202c60:	ca2fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202c64 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202c64:	1141                	addi	sp,sp,-16
ffffffffc0202c66:	e022                	sd	s0,0(sp)
ffffffffc0202c68:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202c6a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202c6c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202c6e:	e01ff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202c72:	c011                	beqz	s0,ffffffffc0202c76 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202c74:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202c76:	c511                	beqz	a0,ffffffffc0202c82 <get_page+0x1e>
ffffffffc0202c78:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202c7a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202c7c:	0017f713          	andi	a4,a5,1
ffffffffc0202c80:	e709                	bnez	a4,ffffffffc0202c8a <get_page+0x26>
}
ffffffffc0202c82:	60a2                	ld	ra,8(sp)
ffffffffc0202c84:	6402                	ld	s0,0(sp)
ffffffffc0202c86:	0141                	addi	sp,sp,16
ffffffffc0202c88:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c8a:	078a                	slli	a5,a5,0x2
ffffffffc0202c8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c8e:	0000f717          	auipc	a4,0xf
ffffffffc0202c92:	8b273703          	ld	a4,-1870(a4) # ffffffffc0211540 <npage>
ffffffffc0202c96:	02e7f263          	bgeu	a5,a4,ffffffffc0202cba <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c9a:	fff80537          	lui	a0,0xfff80
ffffffffc0202c9e:	97aa                	add	a5,a5,a0
ffffffffc0202ca0:	60a2                	ld	ra,8(sp)
ffffffffc0202ca2:	6402                	ld	s0,0(sp)
ffffffffc0202ca4:	00379513          	slli	a0,a5,0x3
ffffffffc0202ca8:	97aa                	add	a5,a5,a0
ffffffffc0202caa:	078e                	slli	a5,a5,0x3
ffffffffc0202cac:	0000f517          	auipc	a0,0xf
ffffffffc0202cb0:	89c53503          	ld	a0,-1892(a0) # ffffffffc0211548 <pages>
ffffffffc0202cb4:	953e                	add	a0,a0,a5
ffffffffc0202cb6:	0141                	addi	sp,sp,16
ffffffffc0202cb8:	8082                	ret
ffffffffc0202cba:	c71ff0ef          	jal	ra,ffffffffc020292a <pa2page.part.0>

ffffffffc0202cbe <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202cbe:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cc0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202cc2:	ec06                	sd	ra,24(sp)
ffffffffc0202cc4:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cc6:	da9ff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
    if (ptep != NULL) {
ffffffffc0202cca:	c511                	beqz	a0,ffffffffc0202cd6 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202ccc:	611c                	ld	a5,0(a0)
ffffffffc0202cce:	842a                	mv	s0,a0
ffffffffc0202cd0:	0017f713          	andi	a4,a5,1
ffffffffc0202cd4:	e709                	bnez	a4,ffffffffc0202cde <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202cd6:	60e2                	ld	ra,24(sp)
ffffffffc0202cd8:	6442                	ld	s0,16(sp)
ffffffffc0202cda:	6105                	addi	sp,sp,32
ffffffffc0202cdc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202cde:	078a                	slli	a5,a5,0x2
ffffffffc0202ce0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ce2:	0000f717          	auipc	a4,0xf
ffffffffc0202ce6:	85e73703          	ld	a4,-1954(a4) # ffffffffc0211540 <npage>
ffffffffc0202cea:	06e7f563          	bgeu	a5,a4,ffffffffc0202d54 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cee:	fff80737          	lui	a4,0xfff80
ffffffffc0202cf2:	97ba                	add	a5,a5,a4
ffffffffc0202cf4:	00379513          	slli	a0,a5,0x3
ffffffffc0202cf8:	97aa                	add	a5,a5,a0
ffffffffc0202cfa:	078e                	slli	a5,a5,0x3
ffffffffc0202cfc:	0000f517          	auipc	a0,0xf
ffffffffc0202d00:	84c53503          	ld	a0,-1972(a0) # ffffffffc0211548 <pages>
ffffffffc0202d04:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202d06:	411c                	lw	a5,0(a0)
ffffffffc0202d08:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202d0c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202d0e:	cb09                	beqz	a4,ffffffffc0202d20 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202d10:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202d14:	12000073          	sfence.vma
}
ffffffffc0202d18:	60e2                	ld	ra,24(sp)
ffffffffc0202d1a:	6442                	ld	s0,16(sp)
ffffffffc0202d1c:	6105                	addi	sp,sp,32
ffffffffc0202d1e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202d20:	100027f3          	csrr	a5,sstatus
ffffffffc0202d24:	8b89                	andi	a5,a5,2
ffffffffc0202d26:	eb89                	bnez	a5,ffffffffc0202d38 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202d28:	0000f797          	auipc	a5,0xf
ffffffffc0202d2c:	8287b783          	ld	a5,-2008(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202d30:	739c                	ld	a5,32(a5)
ffffffffc0202d32:	4585                	li	a1,1
ffffffffc0202d34:	9782                	jalr	a5
    if (flag) {
ffffffffc0202d36:	bfe9                	j	ffffffffc0202d10 <page_remove+0x52>
        intr_disable();
ffffffffc0202d38:	e42a                	sd	a0,8(sp)
ffffffffc0202d3a:	fb4fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202d3e:	0000f797          	auipc	a5,0xf
ffffffffc0202d42:	8127b783          	ld	a5,-2030(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202d46:	739c                	ld	a5,32(a5)
ffffffffc0202d48:	6522                	ld	a0,8(sp)
ffffffffc0202d4a:	4585                	li	a1,1
ffffffffc0202d4c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d4e:	f9afd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202d52:	bf7d                	j	ffffffffc0202d10 <page_remove+0x52>
ffffffffc0202d54:	bd7ff0ef          	jal	ra,ffffffffc020292a <pa2page.part.0>

ffffffffc0202d58 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202d58:	7179                	addi	sp,sp,-48
ffffffffc0202d5a:	87b2                	mv	a5,a2
ffffffffc0202d5c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202d5e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202d60:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202d62:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202d64:	ec26                	sd	s1,24(sp)
ffffffffc0202d66:	f406                	sd	ra,40(sp)
ffffffffc0202d68:	e84a                	sd	s2,16(sp)
ffffffffc0202d6a:	e44e                	sd	s3,8(sp)
ffffffffc0202d6c:	e052                	sd	s4,0(sp)
ffffffffc0202d6e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202d70:	cffff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
    if (ptep == NULL) {
ffffffffc0202d74:	cd71                	beqz	a0,ffffffffc0202e50 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202d76:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202d78:	611c                	ld	a5,0(a0)
ffffffffc0202d7a:	89aa                	mv	s3,a0
ffffffffc0202d7c:	0016871b          	addiw	a4,a3,1
ffffffffc0202d80:	c018                	sw	a4,0(s0)
ffffffffc0202d82:	0017f713          	andi	a4,a5,1
ffffffffc0202d86:	e331                	bnez	a4,ffffffffc0202dca <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d88:	0000e797          	auipc	a5,0xe
ffffffffc0202d8c:	7c07b783          	ld	a5,1984(a5) # ffffffffc0211548 <pages>
ffffffffc0202d90:	40f407b3          	sub	a5,s0,a5
ffffffffc0202d94:	878d                	srai	a5,a5,0x3
ffffffffc0202d96:	00003417          	auipc	s0,0x3
ffffffffc0202d9a:	3d243403          	ld	s0,978(s0) # ffffffffc0206168 <error_string+0x38>
ffffffffc0202d9e:	028787b3          	mul	a5,a5,s0
ffffffffc0202da2:	00080437          	lui	s0,0x80
ffffffffc0202da6:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202da8:	07aa                	slli	a5,a5,0xa
ffffffffc0202daa:	8cdd                	or	s1,s1,a5
ffffffffc0202dac:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202db0:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202db4:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202db8:	4501                	li	a0,0
}
ffffffffc0202dba:	70a2                	ld	ra,40(sp)
ffffffffc0202dbc:	7402                	ld	s0,32(sp)
ffffffffc0202dbe:	64e2                	ld	s1,24(sp)
ffffffffc0202dc0:	6942                	ld	s2,16(sp)
ffffffffc0202dc2:	69a2                	ld	s3,8(sp)
ffffffffc0202dc4:	6a02                	ld	s4,0(sp)
ffffffffc0202dc6:	6145                	addi	sp,sp,48
ffffffffc0202dc8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dca:	00279713          	slli	a4,a5,0x2
ffffffffc0202dce:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dd0:	0000e797          	auipc	a5,0xe
ffffffffc0202dd4:	7707b783          	ld	a5,1904(a5) # ffffffffc0211540 <npage>
ffffffffc0202dd8:	06f77e63          	bgeu	a4,a5,ffffffffc0202e54 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ddc:	fff807b7          	lui	a5,0xfff80
ffffffffc0202de0:	973e                	add	a4,a4,a5
ffffffffc0202de2:	0000ea17          	auipc	s4,0xe
ffffffffc0202de6:	766a0a13          	addi	s4,s4,1894 # ffffffffc0211548 <pages>
ffffffffc0202dea:	000a3783          	ld	a5,0(s4)
ffffffffc0202dee:	00371913          	slli	s2,a4,0x3
ffffffffc0202df2:	993a                	add	s2,s2,a4
ffffffffc0202df4:	090e                	slli	s2,s2,0x3
ffffffffc0202df6:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202df8:	03240063          	beq	s0,s2,ffffffffc0202e18 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202dfc:	00092783          	lw	a5,0(s2)
ffffffffc0202e00:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e04:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202e08:	cb11                	beqz	a4,ffffffffc0202e1c <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e0a:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e0e:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e12:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202e16:	bfad                	j	ffffffffc0202d90 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202e18:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202e1a:	bf9d                	j	ffffffffc0202d90 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202e20:	8b89                	andi	a5,a5,2
ffffffffc0202e22:	eb91                	bnez	a5,ffffffffc0202e36 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202e24:	0000e797          	auipc	a5,0xe
ffffffffc0202e28:	72c7b783          	ld	a5,1836(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202e2c:	739c                	ld	a5,32(a5)
ffffffffc0202e2e:	4585                	li	a1,1
ffffffffc0202e30:	854a                	mv	a0,s2
ffffffffc0202e32:	9782                	jalr	a5
    if (flag) {
ffffffffc0202e34:	bfd9                	j	ffffffffc0202e0a <page_insert+0xb2>
        intr_disable();
ffffffffc0202e36:	eb8fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202e3a:	0000e797          	auipc	a5,0xe
ffffffffc0202e3e:	7167b783          	ld	a5,1814(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0202e42:	739c                	ld	a5,32(a5)
ffffffffc0202e44:	4585                	li	a1,1
ffffffffc0202e46:	854a                	mv	a0,s2
ffffffffc0202e48:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e4a:	e9efd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202e4e:	bf75                	j	ffffffffc0202e0a <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202e50:	5571                	li	a0,-4
ffffffffc0202e52:	b7a5                	j	ffffffffc0202dba <page_insert+0x62>
ffffffffc0202e54:	ad7ff0ef          	jal	ra,ffffffffc020292a <pa2page.part.0>

ffffffffc0202e58 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202e58:	00003797          	auipc	a5,0x3
ffffffffc0202e5c:	98078793          	addi	a5,a5,-1664 # ffffffffc02057d8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202e60:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202e62:	7159                	addi	sp,sp,-112
ffffffffc0202e64:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202e66:	00003517          	auipc	a0,0x3
ffffffffc0202e6a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205908 <default_pmm_manager+0x130>
    pmm_manager = &default_pmm_manager;
ffffffffc0202e6e:	0000eb97          	auipc	s7,0xe
ffffffffc0202e72:	6e2b8b93          	addi	s7,s7,1762 # ffffffffc0211550 <pmm_manager>
void pmm_init(void) {
ffffffffc0202e76:	f486                	sd	ra,104(sp)
ffffffffc0202e78:	f0a2                	sd	s0,96(sp)
ffffffffc0202e7a:	eca6                	sd	s1,88(sp)
ffffffffc0202e7c:	e8ca                	sd	s2,80(sp)
ffffffffc0202e7e:	e4ce                	sd	s3,72(sp)
ffffffffc0202e80:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202e82:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202e86:	e0d2                	sd	s4,64(sp)
ffffffffc0202e88:	fc56                	sd	s5,56(sp)
ffffffffc0202e8a:	f062                	sd	s8,32(sp)
ffffffffc0202e8c:	ec66                	sd	s9,24(sp)
ffffffffc0202e8e:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202e90:	a2afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202e94:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202e98:	4445                	li	s0,17
ffffffffc0202e9a:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202e9e:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202ea0:	0000e997          	auipc	s3,0xe
ffffffffc0202ea4:	6b898993          	addi	s3,s3,1720 # ffffffffc0211558 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202ea8:	0000e497          	auipc	s1,0xe
ffffffffc0202eac:	69848493          	addi	s1,s1,1688 # ffffffffc0211540 <npage>
    pmm_manager->init();
ffffffffc0202eb0:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202eb2:	57f5                	li	a5,-3
ffffffffc0202eb4:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202eb6:	07e006b7          	lui	a3,0x7e00
ffffffffc0202eba:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202ebe:	01591593          	slli	a1,s2,0x15
ffffffffc0202ec2:	00003517          	auipc	a0,0x3
ffffffffc0202ec6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205920 <default_pmm_manager+0x148>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202eca:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202ece:	9ecfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202ed2:	00003517          	auipc	a0,0x3
ffffffffc0202ed6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0205950 <default_pmm_manager+0x178>
ffffffffc0202eda:	9e0fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202ede:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202ee2:	16fd                	addi	a3,a3,-1
ffffffffc0202ee4:	07e005b7          	lui	a1,0x7e00
ffffffffc0202ee8:	01591613          	slli	a2,s2,0x15
ffffffffc0202eec:	00003517          	auipc	a0,0x3
ffffffffc0202ef0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205968 <default_pmm_manager+0x190>
ffffffffc0202ef4:	9c6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202ef8:	777d                	lui	a4,0xfffff
ffffffffc0202efa:	0000f797          	auipc	a5,0xf
ffffffffc0202efe:	66578793          	addi	a5,a5,1637 # ffffffffc021255f <end+0xfff>
ffffffffc0202f02:	8ff9                	and	a5,a5,a4
ffffffffc0202f04:	0000eb17          	auipc	s6,0xe
ffffffffc0202f08:	644b0b13          	addi	s6,s6,1604 # ffffffffc0211548 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202f0c:	00088737          	lui	a4,0x88
ffffffffc0202f10:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f12:	00fb3023          	sd	a5,0(s6)
ffffffffc0202f16:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f18:	4701                	li	a4,0
ffffffffc0202f1a:	4505                	li	a0,1
ffffffffc0202f1c:	fff805b7          	lui	a1,0xfff80
ffffffffc0202f20:	a019                	j	ffffffffc0202f26 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0202f22:	000b3783          	ld	a5,0(s6)
ffffffffc0202f26:	97b6                	add	a5,a5,a3
ffffffffc0202f28:	07a1                	addi	a5,a5,8
ffffffffc0202f2a:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f2e:	609c                	ld	a5,0(s1)
ffffffffc0202f30:	0705                	addi	a4,a4,1
ffffffffc0202f32:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0202f36:	00b78633          	add	a2,a5,a1
ffffffffc0202f3a:	fec764e3          	bltu	a4,a2,ffffffffc0202f22 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202f3e:	000b3503          	ld	a0,0(s6)
ffffffffc0202f42:	00379693          	slli	a3,a5,0x3
ffffffffc0202f46:	96be                	add	a3,a3,a5
ffffffffc0202f48:	fdc00737          	lui	a4,0xfdc00
ffffffffc0202f4c:	972a                	add	a4,a4,a0
ffffffffc0202f4e:	068e                	slli	a3,a3,0x3
ffffffffc0202f50:	96ba                	add	a3,a3,a4
ffffffffc0202f52:	c0200737          	lui	a4,0xc0200
ffffffffc0202f56:	64e6e463          	bltu	a3,a4,ffffffffc020359e <pmm_init+0x746>
ffffffffc0202f5a:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0202f5e:	4645                	li	a2,17
ffffffffc0202f60:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202f62:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0202f64:	4ec6e263          	bltu	a3,a2,ffffffffc0203448 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202f68:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202f6c:	0000e917          	auipc	s2,0xe
ffffffffc0202f70:	5cc90913          	addi	s2,s2,1484 # ffffffffc0211538 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202f74:	7b9c                	ld	a5,48(a5)
ffffffffc0202f76:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	a4050513          	addi	a0,a0,-1472 # ffffffffc02059b8 <default_pmm_manager+0x1e0>
ffffffffc0202f80:	93afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202f84:	00006697          	auipc	a3,0x6
ffffffffc0202f88:	07c68693          	addi	a3,a3,124 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202f8c:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202f90:	c02007b7          	lui	a5,0xc0200
ffffffffc0202f94:	62f6e163          	bltu	a3,a5,ffffffffc02035b6 <pmm_init+0x75e>
ffffffffc0202f98:	0009b783          	ld	a5,0(s3)
ffffffffc0202f9c:	8e9d                	sub	a3,a3,a5
ffffffffc0202f9e:	0000e797          	auipc	a5,0xe
ffffffffc0202fa2:	58d7b923          	sd	a3,1426(a5) # ffffffffc0211530 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fa6:	100027f3          	csrr	a5,sstatus
ffffffffc0202faa:	8b89                	andi	a5,a5,2
ffffffffc0202fac:	4c079763          	bnez	a5,ffffffffc020347a <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202fb0:	000bb783          	ld	a5,0(s7)
ffffffffc0202fb4:	779c                	ld	a5,40(a5)
ffffffffc0202fb6:	9782                	jalr	a5
ffffffffc0202fb8:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fba:	6098                	ld	a4,0(s1)
ffffffffc0202fbc:	c80007b7          	lui	a5,0xc8000
ffffffffc0202fc0:	83b1                	srli	a5,a5,0xc
ffffffffc0202fc2:	62e7e663          	bltu	a5,a4,ffffffffc02035ee <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202fc6:	00093503          	ld	a0,0(s2)
ffffffffc0202fca:	60050263          	beqz	a0,ffffffffc02035ce <pmm_init+0x776>
ffffffffc0202fce:	03451793          	slli	a5,a0,0x34
ffffffffc0202fd2:	5e079e63          	bnez	a5,ffffffffc02035ce <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202fd6:	4601                	li	a2,0
ffffffffc0202fd8:	4581                	li	a1,0
ffffffffc0202fda:	c8bff0ef          	jal	ra,ffffffffc0202c64 <get_page>
ffffffffc0202fde:	66051a63          	bnez	a0,ffffffffc0203652 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202fe2:	4505                	li	a0,1
ffffffffc0202fe4:	97fff0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0202fe8:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fea:	00093503          	ld	a0,0(s2)
ffffffffc0202fee:	4681                	li	a3,0
ffffffffc0202ff0:	4601                	li	a2,0
ffffffffc0202ff2:	85d2                	mv	a1,s4
ffffffffc0202ff4:	d65ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc0202ff8:	62051d63          	bnez	a0,ffffffffc0203632 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ffc:	00093503          	ld	a0,0(s2)
ffffffffc0203000:	4601                	li	a2,0
ffffffffc0203002:	4581                	li	a1,0
ffffffffc0203004:	a6bff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc0203008:	60050563          	beqz	a0,ffffffffc0203612 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc020300c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020300e:	0017f713          	andi	a4,a5,1
ffffffffc0203012:	5e070e63          	beqz	a4,ffffffffc020360e <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203016:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203018:	078a                	slli	a5,a5,0x2
ffffffffc020301a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020301c:	56c7ff63          	bgeu	a5,a2,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203020:	fff80737          	lui	a4,0xfff80
ffffffffc0203024:	97ba                	add	a5,a5,a4
ffffffffc0203026:	000b3683          	ld	a3,0(s6)
ffffffffc020302a:	00379713          	slli	a4,a5,0x3
ffffffffc020302e:	97ba                	add	a5,a5,a4
ffffffffc0203030:	078e                	slli	a5,a5,0x3
ffffffffc0203032:	97b6                	add	a5,a5,a3
ffffffffc0203034:	14fa18e3          	bne	s4,a5,ffffffffc0203984 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0203038:	000a2703          	lw	a4,0(s4)
ffffffffc020303c:	4785                	li	a5,1
ffffffffc020303e:	16f71fe3          	bne	a4,a5,ffffffffc02039bc <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203042:	00093503          	ld	a0,0(s2)
ffffffffc0203046:	77fd                	lui	a5,0xfffff
ffffffffc0203048:	6114                	ld	a3,0(a0)
ffffffffc020304a:	068a                	slli	a3,a3,0x2
ffffffffc020304c:	8efd                	and	a3,a3,a5
ffffffffc020304e:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203052:	14c779e3          	bgeu	a4,a2,ffffffffc02039a4 <pmm_init+0xb4c>
ffffffffc0203056:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020305a:	96e2                	add	a3,a3,s8
ffffffffc020305c:	0006ba83          	ld	s5,0(a3)
ffffffffc0203060:	0a8a                	slli	s5,s5,0x2
ffffffffc0203062:	00fafab3          	and	s5,s5,a5
ffffffffc0203066:	00cad793          	srli	a5,s5,0xc
ffffffffc020306a:	66c7f463          	bgeu	a5,a2,ffffffffc02036d2 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020306e:	4601                	li	a2,0
ffffffffc0203070:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203072:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203074:	9fbff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203078:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020307a:	63551c63          	bne	a0,s5,ffffffffc02036b2 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc020307e:	4505                	li	a0,1
ffffffffc0203080:	8e3ff0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0203084:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203086:	00093503          	ld	a0,0(s2)
ffffffffc020308a:	46d1                	li	a3,20
ffffffffc020308c:	6605                	lui	a2,0x1
ffffffffc020308e:	85d6                	mv	a1,s5
ffffffffc0203090:	cc9ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc0203094:	5c051f63          	bnez	a0,ffffffffc0203672 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203098:	00093503          	ld	a0,0(s2)
ffffffffc020309c:	4601                	li	a2,0
ffffffffc020309e:	6585                	lui	a1,0x1
ffffffffc02030a0:	9cfff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc02030a4:	12050ce3          	beqz	a0,ffffffffc02039dc <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc02030a8:	611c                	ld	a5,0(a0)
ffffffffc02030aa:	0107f713          	andi	a4,a5,16
ffffffffc02030ae:	72070f63          	beqz	a4,ffffffffc02037ec <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc02030b2:	8b91                	andi	a5,a5,4
ffffffffc02030b4:	6e078c63          	beqz	a5,ffffffffc02037ac <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02030b8:	00093503          	ld	a0,0(s2)
ffffffffc02030bc:	611c                	ld	a5,0(a0)
ffffffffc02030be:	8bc1                	andi	a5,a5,16
ffffffffc02030c0:	6c078663          	beqz	a5,ffffffffc020378c <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02030c4:	000aa703          	lw	a4,0(s5)
ffffffffc02030c8:	4785                	li	a5,1
ffffffffc02030ca:	5cf71463          	bne	a4,a5,ffffffffc0203692 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02030ce:	4681                	li	a3,0
ffffffffc02030d0:	6605                	lui	a2,0x1
ffffffffc02030d2:	85d2                	mv	a1,s4
ffffffffc02030d4:	c85ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc02030d8:	66051a63          	bnez	a0,ffffffffc020374c <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02030dc:	000a2703          	lw	a4,0(s4)
ffffffffc02030e0:	4789                	li	a5,2
ffffffffc02030e2:	64f71563          	bne	a4,a5,ffffffffc020372c <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc02030e6:	000aa783          	lw	a5,0(s5)
ffffffffc02030ea:	62079163          	bnez	a5,ffffffffc020370c <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02030ee:	00093503          	ld	a0,0(s2)
ffffffffc02030f2:	4601                	li	a2,0
ffffffffc02030f4:	6585                	lui	a1,0x1
ffffffffc02030f6:	979ff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc02030fa:	5e050963          	beqz	a0,ffffffffc02036ec <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc02030fe:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203100:	00177793          	andi	a5,a4,1
ffffffffc0203104:	50078563          	beqz	a5,ffffffffc020360e <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203108:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020310a:	00271793          	slli	a5,a4,0x2
ffffffffc020310e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203110:	48d7f563          	bgeu	a5,a3,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203114:	fff806b7          	lui	a3,0xfff80
ffffffffc0203118:	97b6                	add	a5,a5,a3
ffffffffc020311a:	000b3603          	ld	a2,0(s6)
ffffffffc020311e:	00379693          	slli	a3,a5,0x3
ffffffffc0203122:	97b6                	add	a5,a5,a3
ffffffffc0203124:	078e                	slli	a5,a5,0x3
ffffffffc0203126:	97b2                	add	a5,a5,a2
ffffffffc0203128:	72fa1263          	bne	s4,a5,ffffffffc020384c <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020312c:	8b41                	andi	a4,a4,16
ffffffffc020312e:	6e071f63          	bnez	a4,ffffffffc020382c <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203132:	00093503          	ld	a0,0(s2)
ffffffffc0203136:	4581                	li	a1,0
ffffffffc0203138:	b87ff0ef          	jal	ra,ffffffffc0202cbe <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020313c:	000a2703          	lw	a4,0(s4)
ffffffffc0203140:	4785                	li	a5,1
ffffffffc0203142:	6cf71563          	bne	a4,a5,ffffffffc020380c <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0203146:	000aa783          	lw	a5,0(s5)
ffffffffc020314a:	78079d63          	bnez	a5,ffffffffc02038e4 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020314e:	00093503          	ld	a0,0(s2)
ffffffffc0203152:	6585                	lui	a1,0x1
ffffffffc0203154:	b6bff0ef          	jal	ra,ffffffffc0202cbe <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203158:	000a2783          	lw	a5,0(s4)
ffffffffc020315c:	76079463          	bnez	a5,ffffffffc02038c4 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0203160:	000aa783          	lw	a5,0(s5)
ffffffffc0203164:	74079063          	bnez	a5,ffffffffc02038a4 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203168:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020316c:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020316e:	000a3783          	ld	a5,0(s4)
ffffffffc0203172:	078a                	slli	a5,a5,0x2
ffffffffc0203174:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203176:	42c7f263          	bgeu	a5,a2,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020317a:	fff80737          	lui	a4,0xfff80
ffffffffc020317e:	973e                	add	a4,a4,a5
ffffffffc0203180:	00371793          	slli	a5,a4,0x3
ffffffffc0203184:	000b3503          	ld	a0,0(s6)
ffffffffc0203188:	97ba                	add	a5,a5,a4
ffffffffc020318a:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc020318c:	00f50733          	add	a4,a0,a5
ffffffffc0203190:	4314                	lw	a3,0(a4)
ffffffffc0203192:	4705                	li	a4,1
ffffffffc0203194:	6ee69863          	bne	a3,a4,ffffffffc0203884 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203198:	4037d693          	srai	a3,a5,0x3
ffffffffc020319c:	00003c97          	auipc	s9,0x3
ffffffffc02031a0:	fcccbc83          	ld	s9,-52(s9) # ffffffffc0206168 <error_string+0x38>
ffffffffc02031a4:	039686b3          	mul	a3,a3,s9
ffffffffc02031a8:	000805b7          	lui	a1,0x80
ffffffffc02031ac:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02031ae:	00c69713          	slli	a4,a3,0xc
ffffffffc02031b2:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02031b6:	6ac77b63          	bgeu	a4,a2,ffffffffc020386c <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02031ba:	0009b703          	ld	a4,0(s3)
ffffffffc02031be:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02031c0:	629c                	ld	a5,0(a3)
ffffffffc02031c2:	078a                	slli	a5,a5,0x2
ffffffffc02031c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031c6:	3cc7fa63          	bgeu	a5,a2,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02031ca:	8f8d                	sub	a5,a5,a1
ffffffffc02031cc:	00379713          	slli	a4,a5,0x3
ffffffffc02031d0:	97ba                	add	a5,a5,a4
ffffffffc02031d2:	078e                	slli	a5,a5,0x3
ffffffffc02031d4:	953e                	add	a0,a0,a5
ffffffffc02031d6:	100027f3          	csrr	a5,sstatus
ffffffffc02031da:	8b89                	andi	a5,a5,2
ffffffffc02031dc:	2e079963          	bnez	a5,ffffffffc02034ce <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02031e0:	000bb783          	ld	a5,0(s7)
ffffffffc02031e4:	4585                	li	a1,1
ffffffffc02031e6:	739c                	ld	a5,32(a5)
ffffffffc02031e8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02031ea:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02031ee:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031f0:	078a                	slli	a5,a5,0x2
ffffffffc02031f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031f4:	3ae7f363          	bgeu	a5,a4,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02031f8:	fff80737          	lui	a4,0xfff80
ffffffffc02031fc:	97ba                	add	a5,a5,a4
ffffffffc02031fe:	000b3503          	ld	a0,0(s6)
ffffffffc0203202:	00379713          	slli	a4,a5,0x3
ffffffffc0203206:	97ba                	add	a5,a5,a4
ffffffffc0203208:	078e                	slli	a5,a5,0x3
ffffffffc020320a:	953e                	add	a0,a0,a5
ffffffffc020320c:	100027f3          	csrr	a5,sstatus
ffffffffc0203210:	8b89                	andi	a5,a5,2
ffffffffc0203212:	2a079263          	bnez	a5,ffffffffc02034b6 <pmm_init+0x65e>
ffffffffc0203216:	000bb783          	ld	a5,0(s7)
ffffffffc020321a:	4585                	li	a1,1
ffffffffc020321c:	739c                	ld	a5,32(a5)
ffffffffc020321e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203220:	00093783          	ld	a5,0(s2)
ffffffffc0203224:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdedaa0>
ffffffffc0203228:	100027f3          	csrr	a5,sstatus
ffffffffc020322c:	8b89                	andi	a5,a5,2
ffffffffc020322e:	26079a63          	bnez	a5,ffffffffc02034a2 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203232:	000bb783          	ld	a5,0(s7)
ffffffffc0203236:	779c                	ld	a5,40(a5)
ffffffffc0203238:	9782                	jalr	a5
ffffffffc020323a:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020323c:	73441463          	bne	s0,s4,ffffffffc0203964 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203240:	00003517          	auipc	a0,0x3
ffffffffc0203244:	a6050513          	addi	a0,a0,-1440 # ffffffffc0205ca0 <default_pmm_manager+0x4c8>
ffffffffc0203248:	e73fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020324c:	100027f3          	csrr	a5,sstatus
ffffffffc0203250:	8b89                	andi	a5,a5,2
ffffffffc0203252:	22079e63          	bnez	a5,ffffffffc020348e <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203256:	000bb783          	ld	a5,0(s7)
ffffffffc020325a:	779c                	ld	a5,40(a5)
ffffffffc020325c:	9782                	jalr	a5
ffffffffc020325e:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203260:	6098                	ld	a4,0(s1)
ffffffffc0203262:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203266:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203268:	00c71793          	slli	a5,a4,0xc
ffffffffc020326c:	6a05                	lui	s4,0x1
ffffffffc020326e:	02f47c63          	bgeu	s0,a5,ffffffffc02032a6 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203272:	00c45793          	srli	a5,s0,0xc
ffffffffc0203276:	00093503          	ld	a0,0(s2)
ffffffffc020327a:	30e7f363          	bgeu	a5,a4,ffffffffc0203580 <pmm_init+0x728>
ffffffffc020327e:	0009b583          	ld	a1,0(s3)
ffffffffc0203282:	4601                	li	a2,0
ffffffffc0203284:	95a2                	add	a1,a1,s0
ffffffffc0203286:	fe8ff0ef          	jal	ra,ffffffffc0202a6e <get_pte>
ffffffffc020328a:	2c050b63          	beqz	a0,ffffffffc0203560 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020328e:	611c                	ld	a5,0(a0)
ffffffffc0203290:	078a                	slli	a5,a5,0x2
ffffffffc0203292:	0157f7b3          	and	a5,a5,s5
ffffffffc0203296:	2a879563          	bne	a5,s0,ffffffffc0203540 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020329a:	6098                	ld	a4,0(s1)
ffffffffc020329c:	9452                	add	s0,s0,s4
ffffffffc020329e:	00c71793          	slli	a5,a4,0xc
ffffffffc02032a2:	fcf468e3          	bltu	s0,a5,ffffffffc0203272 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02032a6:	00093783          	ld	a5,0(s2)
ffffffffc02032aa:	639c                	ld	a5,0(a5)
ffffffffc02032ac:	68079c63          	bnez	a5,ffffffffc0203944 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc02032b0:	4505                	li	a0,1
ffffffffc02032b2:	eb0ff0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc02032b6:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02032b8:	00093503          	ld	a0,0(s2)
ffffffffc02032bc:	4699                	li	a3,6
ffffffffc02032be:	10000613          	li	a2,256
ffffffffc02032c2:	85d6                	mv	a1,s5
ffffffffc02032c4:	a95ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc02032c8:	64051e63          	bnez	a0,ffffffffc0203924 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02032cc:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdedaa0>
ffffffffc02032d0:	4785                	li	a5,1
ffffffffc02032d2:	62f71963          	bne	a4,a5,ffffffffc0203904 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02032d6:	00093503          	ld	a0,0(s2)
ffffffffc02032da:	6405                	lui	s0,0x1
ffffffffc02032dc:	4699                	li	a3,6
ffffffffc02032de:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02032e2:	85d6                	mv	a1,s5
ffffffffc02032e4:	a75ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc02032e8:	48051263          	bnez	a0,ffffffffc020376c <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc02032ec:	000aa703          	lw	a4,0(s5)
ffffffffc02032f0:	4789                	li	a5,2
ffffffffc02032f2:	74f71563          	bne	a4,a5,ffffffffc0203a3c <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02032f6:	00003597          	auipc	a1,0x3
ffffffffc02032fa:	ae258593          	addi	a1,a1,-1310 # ffffffffc0205dd8 <default_pmm_manager+0x600>
ffffffffc02032fe:	10000513          	li	a0,256
ffffffffc0203302:	35d000ef          	jal	ra,ffffffffc0203e5e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203306:	10040593          	addi	a1,s0,256
ffffffffc020330a:	10000513          	li	a0,256
ffffffffc020330e:	363000ef          	jal	ra,ffffffffc0203e70 <strcmp>
ffffffffc0203312:	70051563          	bnez	a0,ffffffffc0203a1c <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203316:	000b3683          	ld	a3,0(s6)
ffffffffc020331a:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020331e:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203320:	40da86b3          	sub	a3,s5,a3
ffffffffc0203324:	868d                	srai	a3,a3,0x3
ffffffffc0203326:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020332a:	609c                	ld	a5,0(s1)
ffffffffc020332c:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020332e:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203330:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203334:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203336:	52f77b63          	bgeu	a4,a5,ffffffffc020386c <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020333a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020333e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203342:	96be                	add	a3,a3,a5
ffffffffc0203344:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eba0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203348:	2e1000ef          	jal	ra,ffffffffc0203e28 <strlen>
ffffffffc020334c:	6a051863          	bnez	a0,ffffffffc02039fc <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203350:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203354:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203356:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020335a:	078a                	slli	a5,a5,0x2
ffffffffc020335c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020335e:	22e7fe63          	bgeu	a5,a4,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203362:	41a787b3          	sub	a5,a5,s10
ffffffffc0203366:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020336a:	96be                	add	a3,a3,a5
ffffffffc020336c:	03968cb3          	mul	s9,a3,s9
ffffffffc0203370:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203374:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203376:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203378:	4ee47a63          	bgeu	s0,a4,ffffffffc020386c <pmm_init+0xa14>
ffffffffc020337c:	0009b403          	ld	s0,0(s3)
ffffffffc0203380:	9436                	add	s0,s0,a3
ffffffffc0203382:	100027f3          	csrr	a5,sstatus
ffffffffc0203386:	8b89                	andi	a5,a5,2
ffffffffc0203388:	1a079163          	bnez	a5,ffffffffc020352a <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020338c:	000bb783          	ld	a5,0(s7)
ffffffffc0203390:	4585                	li	a1,1
ffffffffc0203392:	8556                	mv	a0,s5
ffffffffc0203394:	739c                	ld	a5,32(a5)
ffffffffc0203396:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203398:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020339a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020339c:	078a                	slli	a5,a5,0x2
ffffffffc020339e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033a0:	1ee7fd63          	bgeu	a5,a4,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033a4:	fff80737          	lui	a4,0xfff80
ffffffffc02033a8:	97ba                	add	a5,a5,a4
ffffffffc02033aa:	000b3503          	ld	a0,0(s6)
ffffffffc02033ae:	00379713          	slli	a4,a5,0x3
ffffffffc02033b2:	97ba                	add	a5,a5,a4
ffffffffc02033b4:	078e                	slli	a5,a5,0x3
ffffffffc02033b6:	953e                	add	a0,a0,a5
ffffffffc02033b8:	100027f3          	csrr	a5,sstatus
ffffffffc02033bc:	8b89                	andi	a5,a5,2
ffffffffc02033be:	14079a63          	bnez	a5,ffffffffc0203512 <pmm_init+0x6ba>
ffffffffc02033c2:	000bb783          	ld	a5,0(s7)
ffffffffc02033c6:	4585                	li	a1,1
ffffffffc02033c8:	739c                	ld	a5,32(a5)
ffffffffc02033ca:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033cc:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02033d0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033d2:	078a                	slli	a5,a5,0x2
ffffffffc02033d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033d6:	1ce7f263          	bgeu	a5,a4,ffffffffc020359a <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033da:	fff80737          	lui	a4,0xfff80
ffffffffc02033de:	97ba                	add	a5,a5,a4
ffffffffc02033e0:	000b3503          	ld	a0,0(s6)
ffffffffc02033e4:	00379713          	slli	a4,a5,0x3
ffffffffc02033e8:	97ba                	add	a5,a5,a4
ffffffffc02033ea:	078e                	slli	a5,a5,0x3
ffffffffc02033ec:	953e                	add	a0,a0,a5
ffffffffc02033ee:	100027f3          	csrr	a5,sstatus
ffffffffc02033f2:	8b89                	andi	a5,a5,2
ffffffffc02033f4:	10079363          	bnez	a5,ffffffffc02034fa <pmm_init+0x6a2>
ffffffffc02033f8:	000bb783          	ld	a5,0(s7)
ffffffffc02033fc:	4585                	li	a1,1
ffffffffc02033fe:	739c                	ld	a5,32(a5)
ffffffffc0203400:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203402:	00093783          	ld	a5,0(s2)
ffffffffc0203406:	0007b023          	sd	zero,0(a5)
ffffffffc020340a:	100027f3          	csrr	a5,sstatus
ffffffffc020340e:	8b89                	andi	a5,a5,2
ffffffffc0203410:	0c079b63          	bnez	a5,ffffffffc02034e6 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203414:	000bb783          	ld	a5,0(s7)
ffffffffc0203418:	779c                	ld	a5,40(a5)
ffffffffc020341a:	9782                	jalr	a5
ffffffffc020341c:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020341e:	3a8c1763          	bne	s8,s0,ffffffffc02037cc <pmm_init+0x974>
}
ffffffffc0203422:	7406                	ld	s0,96(sp)
ffffffffc0203424:	70a6                	ld	ra,104(sp)
ffffffffc0203426:	64e6                	ld	s1,88(sp)
ffffffffc0203428:	6946                	ld	s2,80(sp)
ffffffffc020342a:	69a6                	ld	s3,72(sp)
ffffffffc020342c:	6a06                	ld	s4,64(sp)
ffffffffc020342e:	7ae2                	ld	s5,56(sp)
ffffffffc0203430:	7b42                	ld	s6,48(sp)
ffffffffc0203432:	7ba2                	ld	s7,40(sp)
ffffffffc0203434:	7c02                	ld	s8,32(sp)
ffffffffc0203436:	6ce2                	ld	s9,24(sp)
ffffffffc0203438:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020343a:	00003517          	auipc	a0,0x3
ffffffffc020343e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0205e50 <default_pmm_manager+0x678>
}
ffffffffc0203442:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203444:	c77fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203448:	6705                	lui	a4,0x1
ffffffffc020344a:	177d                	addi	a4,a4,-1
ffffffffc020344c:	96ba                	add	a3,a3,a4
ffffffffc020344e:	777d                	lui	a4,0xfffff
ffffffffc0203450:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203452:	00c75693          	srli	a3,a4,0xc
ffffffffc0203456:	14f6f263          	bgeu	a3,a5,ffffffffc020359a <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc020345a:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020345e:	95b6                	add	a1,a1,a3
ffffffffc0203460:	00359793          	slli	a5,a1,0x3
ffffffffc0203464:	97ae                	add	a5,a5,a1
ffffffffc0203466:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020346a:	40e60733          	sub	a4,a2,a4
ffffffffc020346e:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203470:	00c75593          	srli	a1,a4,0xc
ffffffffc0203474:	953e                	add	a0,a0,a5
ffffffffc0203476:	9682                	jalr	a3
}
ffffffffc0203478:	bcc5                	j	ffffffffc0202f68 <pmm_init+0x110>
        intr_disable();
ffffffffc020347a:	874fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020347e:	000bb783          	ld	a5,0(s7)
ffffffffc0203482:	779c                	ld	a5,40(a5)
ffffffffc0203484:	9782                	jalr	a5
ffffffffc0203486:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203488:	860fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020348c:	b63d                	j	ffffffffc0202fba <pmm_init+0x162>
        intr_disable();
ffffffffc020348e:	860fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203492:	000bb783          	ld	a5,0(s7)
ffffffffc0203496:	779c                	ld	a5,40(a5)
ffffffffc0203498:	9782                	jalr	a5
ffffffffc020349a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020349c:	84cfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02034a0:	b3c1                	j	ffffffffc0203260 <pmm_init+0x408>
        intr_disable();
ffffffffc02034a2:	84cfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02034a6:	000bb783          	ld	a5,0(s7)
ffffffffc02034aa:	779c                	ld	a5,40(a5)
ffffffffc02034ac:	9782                	jalr	a5
ffffffffc02034ae:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02034b0:	838fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02034b4:	b361                	j	ffffffffc020323c <pmm_init+0x3e4>
ffffffffc02034b6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034b8:	836fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02034bc:	000bb783          	ld	a5,0(s7)
ffffffffc02034c0:	6522                	ld	a0,8(sp)
ffffffffc02034c2:	4585                	li	a1,1
ffffffffc02034c4:	739c                	ld	a5,32(a5)
ffffffffc02034c6:	9782                	jalr	a5
        intr_enable();
ffffffffc02034c8:	820fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02034cc:	bb91                	j	ffffffffc0203220 <pmm_init+0x3c8>
ffffffffc02034ce:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034d0:	81efd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02034d4:	000bb783          	ld	a5,0(s7)
ffffffffc02034d8:	6522                	ld	a0,8(sp)
ffffffffc02034da:	4585                	li	a1,1
ffffffffc02034dc:	739c                	ld	a5,32(a5)
ffffffffc02034de:	9782                	jalr	a5
        intr_enable();
ffffffffc02034e0:	808fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02034e4:	b319                	j	ffffffffc02031ea <pmm_init+0x392>
        intr_disable();
ffffffffc02034e6:	808fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02034ea:	000bb783          	ld	a5,0(s7)
ffffffffc02034ee:	779c                	ld	a5,40(a5)
ffffffffc02034f0:	9782                	jalr	a5
ffffffffc02034f2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034f4:	ff5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02034f8:	b71d                	j	ffffffffc020341e <pmm_init+0x5c6>
ffffffffc02034fa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034fc:	ff3fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203500:	000bb783          	ld	a5,0(s7)
ffffffffc0203504:	6522                	ld	a0,8(sp)
ffffffffc0203506:	4585                	li	a1,1
ffffffffc0203508:	739c                	ld	a5,32(a5)
ffffffffc020350a:	9782                	jalr	a5
        intr_enable();
ffffffffc020350c:	fddfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203510:	bdcd                	j	ffffffffc0203402 <pmm_init+0x5aa>
ffffffffc0203512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203514:	fdbfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203518:	000bb783          	ld	a5,0(s7)
ffffffffc020351c:	6522                	ld	a0,8(sp)
ffffffffc020351e:	4585                	li	a1,1
ffffffffc0203520:	739c                	ld	a5,32(a5)
ffffffffc0203522:	9782                	jalr	a5
        intr_enable();
ffffffffc0203524:	fc5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203528:	b555                	j	ffffffffc02033cc <pmm_init+0x574>
        intr_disable();
ffffffffc020352a:	fc5fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020352e:	000bb783          	ld	a5,0(s7)
ffffffffc0203532:	4585                	li	a1,1
ffffffffc0203534:	8556                	mv	a0,s5
ffffffffc0203536:	739c                	ld	a5,32(a5)
ffffffffc0203538:	9782                	jalr	a5
        intr_enable();
ffffffffc020353a:	faffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020353e:	bda9                	j	ffffffffc0203398 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203540:	00002697          	auipc	a3,0x2
ffffffffc0203544:	7c068693          	addi	a3,a3,1984 # ffffffffc0205d00 <default_pmm_manager+0x528>
ffffffffc0203548:	00001617          	auipc	a2,0x1
ffffffffc020354c:	7c860613          	addi	a2,a2,1992 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203550:	1ce00593          	li	a1,462
ffffffffc0203554:	00002517          	auipc	a0,0x2
ffffffffc0203558:	3a450513          	addi	a0,a0,932 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020355c:	ba7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203560:	00002697          	auipc	a3,0x2
ffffffffc0203564:	76068693          	addi	a3,a3,1888 # ffffffffc0205cc0 <default_pmm_manager+0x4e8>
ffffffffc0203568:	00001617          	auipc	a2,0x1
ffffffffc020356c:	7a860613          	addi	a2,a2,1960 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203570:	1cd00593          	li	a1,461
ffffffffc0203574:	00002517          	auipc	a0,0x2
ffffffffc0203578:	38450513          	addi	a0,a0,900 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020357c:	b87fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203580:	86a2                	mv	a3,s0
ffffffffc0203582:	00002617          	auipc	a2,0x2
ffffffffc0203586:	34e60613          	addi	a2,a2,846 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc020358a:	1cd00593          	li	a1,461
ffffffffc020358e:	00002517          	auipc	a0,0x2
ffffffffc0203592:	36a50513          	addi	a0,a0,874 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203596:	b6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020359a:	b90ff0ef          	jal	ra,ffffffffc020292a <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020359e:	00002617          	auipc	a2,0x2
ffffffffc02035a2:	3f260613          	addi	a2,a2,1010 # ffffffffc0205990 <default_pmm_manager+0x1b8>
ffffffffc02035a6:	07700593          	li	a1,119
ffffffffc02035aa:	00002517          	auipc	a0,0x2
ffffffffc02035ae:	34e50513          	addi	a0,a0,846 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02035b2:	b51fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02035b6:	00002617          	auipc	a2,0x2
ffffffffc02035ba:	3da60613          	addi	a2,a2,986 # ffffffffc0205990 <default_pmm_manager+0x1b8>
ffffffffc02035be:	0bd00593          	li	a1,189
ffffffffc02035c2:	00002517          	auipc	a0,0x2
ffffffffc02035c6:	33650513          	addi	a0,a0,822 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02035ca:	b39fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02035ce:	00002697          	auipc	a3,0x2
ffffffffc02035d2:	42a68693          	addi	a3,a3,1066 # ffffffffc02059f8 <default_pmm_manager+0x220>
ffffffffc02035d6:	00001617          	auipc	a2,0x1
ffffffffc02035da:	73a60613          	addi	a2,a2,1850 # ffffffffc0204d10 <commands+0x728>
ffffffffc02035de:	19300593          	li	a1,403
ffffffffc02035e2:	00002517          	auipc	a0,0x2
ffffffffc02035e6:	31650513          	addi	a0,a0,790 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02035ea:	b19fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035ee:	00002697          	auipc	a3,0x2
ffffffffc02035f2:	3ea68693          	addi	a3,a3,1002 # ffffffffc02059d8 <default_pmm_manager+0x200>
ffffffffc02035f6:	00001617          	auipc	a2,0x1
ffffffffc02035fa:	71a60613          	addi	a2,a2,1818 # ffffffffc0204d10 <commands+0x728>
ffffffffc02035fe:	19200593          	li	a1,402
ffffffffc0203602:	00002517          	auipc	a0,0x2
ffffffffc0203606:	2f650513          	addi	a0,a0,758 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020360a:	af9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020360e:	b38ff0ef          	jal	ra,ffffffffc0202946 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203612:	00002697          	auipc	a3,0x2
ffffffffc0203616:	47668693          	addi	a3,a3,1142 # ffffffffc0205a88 <default_pmm_manager+0x2b0>
ffffffffc020361a:	00001617          	auipc	a2,0x1
ffffffffc020361e:	6f660613          	addi	a2,a2,1782 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203622:	19a00593          	li	a1,410
ffffffffc0203626:	00002517          	auipc	a0,0x2
ffffffffc020362a:	2d250513          	addi	a0,a0,722 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020362e:	ad5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203632:	00002697          	auipc	a3,0x2
ffffffffc0203636:	42668693          	addi	a3,a3,1062 # ffffffffc0205a58 <default_pmm_manager+0x280>
ffffffffc020363a:	00001617          	auipc	a2,0x1
ffffffffc020363e:	6d660613          	addi	a2,a2,1750 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203642:	19800593          	li	a1,408
ffffffffc0203646:	00002517          	auipc	a0,0x2
ffffffffc020364a:	2b250513          	addi	a0,a0,690 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020364e:	ab5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203652:	00002697          	auipc	a3,0x2
ffffffffc0203656:	3de68693          	addi	a3,a3,990 # ffffffffc0205a30 <default_pmm_manager+0x258>
ffffffffc020365a:	00001617          	auipc	a2,0x1
ffffffffc020365e:	6b660613          	addi	a2,a2,1718 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203662:	19400593          	li	a1,404
ffffffffc0203666:	00002517          	auipc	a0,0x2
ffffffffc020366a:	29250513          	addi	a0,a0,658 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020366e:	a95fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203672:	00002697          	auipc	a3,0x2
ffffffffc0203676:	49e68693          	addi	a3,a3,1182 # ffffffffc0205b10 <default_pmm_manager+0x338>
ffffffffc020367a:	00001617          	auipc	a2,0x1
ffffffffc020367e:	69660613          	addi	a2,a2,1686 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203682:	1a300593          	li	a1,419
ffffffffc0203686:	00002517          	auipc	a0,0x2
ffffffffc020368a:	27250513          	addi	a0,a0,626 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc020368e:	a75fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203692:	00002697          	auipc	a3,0x2
ffffffffc0203696:	51e68693          	addi	a3,a3,1310 # ffffffffc0205bb0 <default_pmm_manager+0x3d8>
ffffffffc020369a:	00001617          	auipc	a2,0x1
ffffffffc020369e:	67660613          	addi	a2,a2,1654 # ffffffffc0204d10 <commands+0x728>
ffffffffc02036a2:	1a800593          	li	a1,424
ffffffffc02036a6:	00002517          	auipc	a0,0x2
ffffffffc02036aa:	25250513          	addi	a0,a0,594 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02036ae:	a55fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02036b2:	00002697          	auipc	a3,0x2
ffffffffc02036b6:	43668693          	addi	a3,a3,1078 # ffffffffc0205ae8 <default_pmm_manager+0x310>
ffffffffc02036ba:	00001617          	auipc	a2,0x1
ffffffffc02036be:	65660613          	addi	a2,a2,1622 # ffffffffc0204d10 <commands+0x728>
ffffffffc02036c2:	1a000593          	li	a1,416
ffffffffc02036c6:	00002517          	auipc	a0,0x2
ffffffffc02036ca:	23250513          	addi	a0,a0,562 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02036ce:	a35fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02036d2:	86d6                	mv	a3,s5
ffffffffc02036d4:	00002617          	auipc	a2,0x2
ffffffffc02036d8:	1fc60613          	addi	a2,a2,508 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc02036dc:	19f00593          	li	a1,415
ffffffffc02036e0:	00002517          	auipc	a0,0x2
ffffffffc02036e4:	21850513          	addi	a0,a0,536 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02036e8:	a1bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036ec:	00002697          	auipc	a3,0x2
ffffffffc02036f0:	45c68693          	addi	a3,a3,1116 # ffffffffc0205b48 <default_pmm_manager+0x370>
ffffffffc02036f4:	00001617          	auipc	a2,0x1
ffffffffc02036f8:	61c60613          	addi	a2,a2,1564 # ffffffffc0204d10 <commands+0x728>
ffffffffc02036fc:	1ad00593          	li	a1,429
ffffffffc0203700:	00002517          	auipc	a0,0x2
ffffffffc0203704:	1f850513          	addi	a0,a0,504 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203708:	9fbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020370c:	00002697          	auipc	a3,0x2
ffffffffc0203710:	50468693          	addi	a3,a3,1284 # ffffffffc0205c10 <default_pmm_manager+0x438>
ffffffffc0203714:	00001617          	auipc	a2,0x1
ffffffffc0203718:	5fc60613          	addi	a2,a2,1532 # ffffffffc0204d10 <commands+0x728>
ffffffffc020371c:	1ac00593          	li	a1,428
ffffffffc0203720:	00002517          	auipc	a0,0x2
ffffffffc0203724:	1d850513          	addi	a0,a0,472 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203728:	9dbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020372c:	00002697          	auipc	a3,0x2
ffffffffc0203730:	4cc68693          	addi	a3,a3,1228 # ffffffffc0205bf8 <default_pmm_manager+0x420>
ffffffffc0203734:	00001617          	auipc	a2,0x1
ffffffffc0203738:	5dc60613          	addi	a2,a2,1500 # ffffffffc0204d10 <commands+0x728>
ffffffffc020373c:	1ab00593          	li	a1,427
ffffffffc0203740:	00002517          	auipc	a0,0x2
ffffffffc0203744:	1b850513          	addi	a0,a0,440 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203748:	9bbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020374c:	00002697          	auipc	a3,0x2
ffffffffc0203750:	47c68693          	addi	a3,a3,1148 # ffffffffc0205bc8 <default_pmm_manager+0x3f0>
ffffffffc0203754:	00001617          	auipc	a2,0x1
ffffffffc0203758:	5bc60613          	addi	a2,a2,1468 # ffffffffc0204d10 <commands+0x728>
ffffffffc020375c:	1aa00593          	li	a1,426
ffffffffc0203760:	00002517          	auipc	a0,0x2
ffffffffc0203764:	19850513          	addi	a0,a0,408 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203768:	99bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020376c:	00002697          	auipc	a3,0x2
ffffffffc0203770:	61468693          	addi	a3,a3,1556 # ffffffffc0205d80 <default_pmm_manager+0x5a8>
ffffffffc0203774:	00001617          	auipc	a2,0x1
ffffffffc0203778:	59c60613          	addi	a2,a2,1436 # ffffffffc0204d10 <commands+0x728>
ffffffffc020377c:	1d800593          	li	a1,472
ffffffffc0203780:	00002517          	auipc	a0,0x2
ffffffffc0203784:	17850513          	addi	a0,a0,376 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203788:	97bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020378c:	00002697          	auipc	a3,0x2
ffffffffc0203790:	40c68693          	addi	a3,a3,1036 # ffffffffc0205b98 <default_pmm_manager+0x3c0>
ffffffffc0203794:	00001617          	auipc	a2,0x1
ffffffffc0203798:	57c60613          	addi	a2,a2,1404 # ffffffffc0204d10 <commands+0x728>
ffffffffc020379c:	1a700593          	li	a1,423
ffffffffc02037a0:	00002517          	auipc	a0,0x2
ffffffffc02037a4:	15850513          	addi	a0,a0,344 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02037a8:	95bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02037ac:	00002697          	auipc	a3,0x2
ffffffffc02037b0:	3dc68693          	addi	a3,a3,988 # ffffffffc0205b88 <default_pmm_manager+0x3b0>
ffffffffc02037b4:	00001617          	auipc	a2,0x1
ffffffffc02037b8:	55c60613          	addi	a2,a2,1372 # ffffffffc0204d10 <commands+0x728>
ffffffffc02037bc:	1a600593          	li	a1,422
ffffffffc02037c0:	00002517          	auipc	a0,0x2
ffffffffc02037c4:	13850513          	addi	a0,a0,312 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02037c8:	93bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02037cc:	00002697          	auipc	a3,0x2
ffffffffc02037d0:	4b468693          	addi	a3,a3,1204 # ffffffffc0205c80 <default_pmm_manager+0x4a8>
ffffffffc02037d4:	00001617          	auipc	a2,0x1
ffffffffc02037d8:	53c60613          	addi	a2,a2,1340 # ffffffffc0204d10 <commands+0x728>
ffffffffc02037dc:	1e800593          	li	a1,488
ffffffffc02037e0:	00002517          	auipc	a0,0x2
ffffffffc02037e4:	11850513          	addi	a0,a0,280 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02037e8:	91bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02037ec:	00002697          	auipc	a3,0x2
ffffffffc02037f0:	38c68693          	addi	a3,a3,908 # ffffffffc0205b78 <default_pmm_manager+0x3a0>
ffffffffc02037f4:	00001617          	auipc	a2,0x1
ffffffffc02037f8:	51c60613          	addi	a2,a2,1308 # ffffffffc0204d10 <commands+0x728>
ffffffffc02037fc:	1a500593          	li	a1,421
ffffffffc0203800:	00002517          	auipc	a0,0x2
ffffffffc0203804:	0f850513          	addi	a0,a0,248 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203808:	8fbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020380c:	00002697          	auipc	a3,0x2
ffffffffc0203810:	2c468693          	addi	a3,a3,708 # ffffffffc0205ad0 <default_pmm_manager+0x2f8>
ffffffffc0203814:	00001617          	auipc	a2,0x1
ffffffffc0203818:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204d10 <commands+0x728>
ffffffffc020381c:	1b200593          	li	a1,434
ffffffffc0203820:	00002517          	auipc	a0,0x2
ffffffffc0203824:	0d850513          	addi	a0,a0,216 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203828:	8dbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020382c:	00002697          	auipc	a3,0x2
ffffffffc0203830:	3fc68693          	addi	a3,a3,1020 # ffffffffc0205c28 <default_pmm_manager+0x450>
ffffffffc0203834:	00001617          	auipc	a2,0x1
ffffffffc0203838:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204d10 <commands+0x728>
ffffffffc020383c:	1af00593          	li	a1,431
ffffffffc0203840:	00002517          	auipc	a0,0x2
ffffffffc0203844:	0b850513          	addi	a0,a0,184 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203848:	8bbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020384c:	00002697          	auipc	a3,0x2
ffffffffc0203850:	26c68693          	addi	a3,a3,620 # ffffffffc0205ab8 <default_pmm_manager+0x2e0>
ffffffffc0203854:	00001617          	auipc	a2,0x1
ffffffffc0203858:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204d10 <commands+0x728>
ffffffffc020385c:	1ae00593          	li	a1,430
ffffffffc0203860:	00002517          	auipc	a0,0x2
ffffffffc0203864:	09850513          	addi	a0,a0,152 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203868:	89bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020386c:	00002617          	auipc	a2,0x2
ffffffffc0203870:	06460613          	addi	a2,a2,100 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0203874:	06a00593          	li	a1,106
ffffffffc0203878:	00001517          	auipc	a0,0x1
ffffffffc020387c:	70850513          	addi	a0,a0,1800 # ffffffffc0204f80 <commands+0x998>
ffffffffc0203880:	883fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203884:	00002697          	auipc	a3,0x2
ffffffffc0203888:	3d468693          	addi	a3,a3,980 # ffffffffc0205c58 <default_pmm_manager+0x480>
ffffffffc020388c:	00001617          	auipc	a2,0x1
ffffffffc0203890:	48460613          	addi	a2,a2,1156 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203894:	1b900593          	li	a1,441
ffffffffc0203898:	00002517          	auipc	a0,0x2
ffffffffc020389c:	06050513          	addi	a0,a0,96 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02038a0:	863fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038a4:	00002697          	auipc	a3,0x2
ffffffffc02038a8:	36c68693          	addi	a3,a3,876 # ffffffffc0205c10 <default_pmm_manager+0x438>
ffffffffc02038ac:	00001617          	auipc	a2,0x1
ffffffffc02038b0:	46460613          	addi	a2,a2,1124 # ffffffffc0204d10 <commands+0x728>
ffffffffc02038b4:	1b700593          	li	a1,439
ffffffffc02038b8:	00002517          	auipc	a0,0x2
ffffffffc02038bc:	04050513          	addi	a0,a0,64 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02038c0:	843fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038c4:	00002697          	auipc	a3,0x2
ffffffffc02038c8:	37c68693          	addi	a3,a3,892 # ffffffffc0205c40 <default_pmm_manager+0x468>
ffffffffc02038cc:	00001617          	auipc	a2,0x1
ffffffffc02038d0:	44460613          	addi	a2,a2,1092 # ffffffffc0204d10 <commands+0x728>
ffffffffc02038d4:	1b600593          	li	a1,438
ffffffffc02038d8:	00002517          	auipc	a0,0x2
ffffffffc02038dc:	02050513          	addi	a0,a0,32 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02038e0:	823fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038e4:	00002697          	auipc	a3,0x2
ffffffffc02038e8:	32c68693          	addi	a3,a3,812 # ffffffffc0205c10 <default_pmm_manager+0x438>
ffffffffc02038ec:	00001617          	auipc	a2,0x1
ffffffffc02038f0:	42460613          	addi	a2,a2,1060 # ffffffffc0204d10 <commands+0x728>
ffffffffc02038f4:	1b300593          	li	a1,435
ffffffffc02038f8:	00002517          	auipc	a0,0x2
ffffffffc02038fc:	00050513          	mv	a0,a0
ffffffffc0203900:	803fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203904:	00002697          	auipc	a3,0x2
ffffffffc0203908:	46468693          	addi	a3,a3,1124 # ffffffffc0205d68 <default_pmm_manager+0x590>
ffffffffc020390c:	00001617          	auipc	a2,0x1
ffffffffc0203910:	40460613          	addi	a2,a2,1028 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203914:	1d700593          	li	a1,471
ffffffffc0203918:	00002517          	auipc	a0,0x2
ffffffffc020391c:	fe050513          	addi	a0,a0,-32 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203920:	fe2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	40c68693          	addi	a3,a3,1036 # ffffffffc0205d30 <default_pmm_manager+0x558>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	3e460613          	addi	a2,a2,996 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203934:	1d600593          	li	a1,470
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	fc050513          	addi	a0,a0,-64 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203940:	fc2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	3d468693          	addi	a3,a3,980 # ffffffffc0205d18 <default_pmm_manager+0x540>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	3c460613          	addi	a2,a2,964 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203954:	1d200593          	li	a1,466
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	fa050513          	addi	a0,a0,-96 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203960:	fa2fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203964:	00002697          	auipc	a3,0x2
ffffffffc0203968:	31c68693          	addi	a3,a3,796 # ffffffffc0205c80 <default_pmm_manager+0x4a8>
ffffffffc020396c:	00001617          	auipc	a2,0x1
ffffffffc0203970:	3a460613          	addi	a2,a2,932 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203974:	1c000593          	li	a1,448
ffffffffc0203978:	00002517          	auipc	a0,0x2
ffffffffc020397c:	f8050513          	addi	a0,a0,-128 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203980:	f82fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203984:	00002697          	auipc	a3,0x2
ffffffffc0203988:	13468693          	addi	a3,a3,308 # ffffffffc0205ab8 <default_pmm_manager+0x2e0>
ffffffffc020398c:	00001617          	auipc	a2,0x1
ffffffffc0203990:	38460613          	addi	a2,a2,900 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203994:	19b00593          	li	a1,411
ffffffffc0203998:	00002517          	auipc	a0,0x2
ffffffffc020399c:	f6050513          	addi	a0,a0,-160 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02039a0:	f62fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02039a4:	00002617          	auipc	a2,0x2
ffffffffc02039a8:	f2c60613          	addi	a2,a2,-212 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc02039ac:	19e00593          	li	a1,414
ffffffffc02039b0:	00002517          	auipc	a0,0x2
ffffffffc02039b4:	f4850513          	addi	a0,a0,-184 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02039b8:	f4afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02039bc:	00002697          	auipc	a3,0x2
ffffffffc02039c0:	11468693          	addi	a3,a3,276 # ffffffffc0205ad0 <default_pmm_manager+0x2f8>
ffffffffc02039c4:	00001617          	auipc	a2,0x1
ffffffffc02039c8:	34c60613          	addi	a2,a2,844 # ffffffffc0204d10 <commands+0x728>
ffffffffc02039cc:	19c00593          	li	a1,412
ffffffffc02039d0:	00002517          	auipc	a0,0x2
ffffffffc02039d4:	f2850513          	addi	a0,a0,-216 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02039d8:	f2afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02039dc:	00002697          	auipc	a3,0x2
ffffffffc02039e0:	16c68693          	addi	a3,a3,364 # ffffffffc0205b48 <default_pmm_manager+0x370>
ffffffffc02039e4:	00001617          	auipc	a2,0x1
ffffffffc02039e8:	32c60613          	addi	a2,a2,812 # ffffffffc0204d10 <commands+0x728>
ffffffffc02039ec:	1a400593          	li	a1,420
ffffffffc02039f0:	00002517          	auipc	a0,0x2
ffffffffc02039f4:	f0850513          	addi	a0,a0,-248 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc02039f8:	f0afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02039fc:	00002697          	auipc	a3,0x2
ffffffffc0203a00:	42c68693          	addi	a3,a3,1068 # ffffffffc0205e28 <default_pmm_manager+0x650>
ffffffffc0203a04:	00001617          	auipc	a2,0x1
ffffffffc0203a08:	30c60613          	addi	a2,a2,780 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203a0c:	1e000593          	li	a1,480
ffffffffc0203a10:	00002517          	auipc	a0,0x2
ffffffffc0203a14:	ee850513          	addi	a0,a0,-280 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203a18:	eeafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203a1c:	00002697          	auipc	a3,0x2
ffffffffc0203a20:	3d468693          	addi	a3,a3,980 # ffffffffc0205df0 <default_pmm_manager+0x618>
ffffffffc0203a24:	00001617          	auipc	a2,0x1
ffffffffc0203a28:	2ec60613          	addi	a2,a2,748 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203a2c:	1dd00593          	li	a1,477
ffffffffc0203a30:	00002517          	auipc	a0,0x2
ffffffffc0203a34:	ec850513          	addi	a0,a0,-312 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203a38:	ecafc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203a3c:	00002697          	auipc	a3,0x2
ffffffffc0203a40:	38468693          	addi	a3,a3,900 # ffffffffc0205dc0 <default_pmm_manager+0x5e8>
ffffffffc0203a44:	00001617          	auipc	a2,0x1
ffffffffc0203a48:	2cc60613          	addi	a2,a2,716 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203a4c:	1d900593          	li	a1,473
ffffffffc0203a50:	00002517          	auipc	a0,0x2
ffffffffc0203a54:	ea850513          	addi	a0,a0,-344 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203a58:	eaafc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203a5c <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203a5c:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203a60:	8082                	ret

ffffffffc0203a62 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a62:	7179                	addi	sp,sp,-48
ffffffffc0203a64:	e84a                	sd	s2,16(sp)
ffffffffc0203a66:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203a68:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a6a:	f022                	sd	s0,32(sp)
ffffffffc0203a6c:	ec26                	sd	s1,24(sp)
ffffffffc0203a6e:	e44e                	sd	s3,8(sp)
ffffffffc0203a70:	f406                	sd	ra,40(sp)
ffffffffc0203a72:	84ae                	mv	s1,a1
ffffffffc0203a74:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203a76:	eedfe0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
ffffffffc0203a7a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203a7c:	cd09                	beqz	a0,ffffffffc0203a96 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203a7e:	85aa                	mv	a1,a0
ffffffffc0203a80:	86ce                	mv	a3,s3
ffffffffc0203a82:	8626                	mv	a2,s1
ffffffffc0203a84:	854a                	mv	a0,s2
ffffffffc0203a86:	ad2ff0ef          	jal	ra,ffffffffc0202d58 <page_insert>
ffffffffc0203a8a:	ed21                	bnez	a0,ffffffffc0203ae2 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203a8c:	0000e797          	auipc	a5,0xe
ffffffffc0203a90:	a947a783          	lw	a5,-1388(a5) # ffffffffc0211520 <swap_init_ok>
ffffffffc0203a94:	eb89                	bnez	a5,ffffffffc0203aa6 <pgdir_alloc_page+0x44>
}
ffffffffc0203a96:	70a2                	ld	ra,40(sp)
ffffffffc0203a98:	8522                	mv	a0,s0
ffffffffc0203a9a:	7402                	ld	s0,32(sp)
ffffffffc0203a9c:	64e2                	ld	s1,24(sp)
ffffffffc0203a9e:	6942                	ld	s2,16(sp)
ffffffffc0203aa0:	69a2                	ld	s3,8(sp)
ffffffffc0203aa2:	6145                	addi	sp,sp,48
ffffffffc0203aa4:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203aa6:	4681                	li	a3,0
ffffffffc0203aa8:	8622                	mv	a2,s0
ffffffffc0203aaa:	85a6                	mv	a1,s1
ffffffffc0203aac:	0000e517          	auipc	a0,0xe
ffffffffc0203ab0:	a5453503          	ld	a0,-1452(a0) # ffffffffc0211500 <check_mm_struct>
ffffffffc0203ab4:	f1bfd0ef          	jal	ra,ffffffffc02019ce <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203ab8:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203aba:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203abc:	4785                	li	a5,1
ffffffffc0203abe:	fcf70ce3          	beq	a4,a5,ffffffffc0203a96 <pgdir_alloc_page+0x34>
ffffffffc0203ac2:	00002697          	auipc	a3,0x2
ffffffffc0203ac6:	3ae68693          	addi	a3,a3,942 # ffffffffc0205e70 <default_pmm_manager+0x698>
ffffffffc0203aca:	00001617          	auipc	a2,0x1
ffffffffc0203ace:	24660613          	addi	a2,a2,582 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203ad2:	17a00593          	li	a1,378
ffffffffc0203ad6:	00002517          	auipc	a0,0x2
ffffffffc0203ada:	e2250513          	addi	a0,a0,-478 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203ade:	e24fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203ae2:	100027f3          	csrr	a5,sstatus
ffffffffc0203ae6:	8b89                	andi	a5,a5,2
ffffffffc0203ae8:	eb99                	bnez	a5,ffffffffc0203afe <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203aea:	0000e797          	auipc	a5,0xe
ffffffffc0203aee:	a667b783          	ld	a5,-1434(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0203af2:	739c                	ld	a5,32(a5)
ffffffffc0203af4:	8522                	mv	a0,s0
ffffffffc0203af6:	4585                	li	a1,1
ffffffffc0203af8:	9782                	jalr	a5
            return NULL;
ffffffffc0203afa:	4401                	li	s0,0
ffffffffc0203afc:	bf69                	j	ffffffffc0203a96 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203afe:	9f1fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b02:	0000e797          	auipc	a5,0xe
ffffffffc0203b06:	a4e7b783          	ld	a5,-1458(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0203b0a:	739c                	ld	a5,32(a5)
ffffffffc0203b0c:	8522                	mv	a0,s0
ffffffffc0203b0e:	4585                	li	a1,1
ffffffffc0203b10:	9782                	jalr	a5
            return NULL;
ffffffffc0203b12:	4401                	li	s0,0
        intr_enable();
ffffffffc0203b14:	9d5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203b18:	bfbd                	j	ffffffffc0203a96 <pgdir_alloc_page+0x34>

ffffffffc0203b1a <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203b1a:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b1c:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203b1e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b20:	fff50713          	addi	a4,a0,-1
ffffffffc0203b24:	17f9                	addi	a5,a5,-2
ffffffffc0203b26:	04e7ea63          	bltu	a5,a4,ffffffffc0203b7a <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203b2a:	6785                	lui	a5,0x1
ffffffffc0203b2c:	17fd                	addi	a5,a5,-1
ffffffffc0203b2e:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203b30:	8131                	srli	a0,a0,0xc
ffffffffc0203b32:	e31fe0ef          	jal	ra,ffffffffc0202962 <alloc_pages>
    assert(base != NULL);
ffffffffc0203b36:	cd3d                	beqz	a0,ffffffffc0203bb4 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b38:	0000e797          	auipc	a5,0xe
ffffffffc0203b3c:	a107b783          	ld	a5,-1520(a5) # ffffffffc0211548 <pages>
ffffffffc0203b40:	8d1d                	sub	a0,a0,a5
ffffffffc0203b42:	00002697          	auipc	a3,0x2
ffffffffc0203b46:	6266b683          	ld	a3,1574(a3) # ffffffffc0206168 <error_string+0x38>
ffffffffc0203b4a:	850d                	srai	a0,a0,0x3
ffffffffc0203b4c:	02d50533          	mul	a0,a0,a3
ffffffffc0203b50:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b54:	0000e717          	auipc	a4,0xe
ffffffffc0203b58:	9ec73703          	ld	a4,-1556(a4) # ffffffffc0211540 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b5c:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b5e:	00c51793          	slli	a5,a0,0xc
ffffffffc0203b62:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b64:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b66:	02e7fa63          	bgeu	a5,a4,ffffffffc0203b9a <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203b6a:	60a2                	ld	ra,8(sp)
ffffffffc0203b6c:	0000e797          	auipc	a5,0xe
ffffffffc0203b70:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0211558 <va_pa_offset>
ffffffffc0203b74:	953e                	add	a0,a0,a5
ffffffffc0203b76:	0141                	addi	sp,sp,16
ffffffffc0203b78:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b7a:	00002697          	auipc	a3,0x2
ffffffffc0203b7e:	30e68693          	addi	a3,a3,782 # ffffffffc0205e88 <default_pmm_manager+0x6b0>
ffffffffc0203b82:	00001617          	auipc	a2,0x1
ffffffffc0203b86:	18e60613          	addi	a2,a2,398 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203b8a:	1f000593          	li	a1,496
ffffffffc0203b8e:	00002517          	auipc	a0,0x2
ffffffffc0203b92:	d6a50513          	addi	a0,a0,-662 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203b96:	d6cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203b9a:	86aa                	mv	a3,a0
ffffffffc0203b9c:	00002617          	auipc	a2,0x2
ffffffffc0203ba0:	d3460613          	addi	a2,a2,-716 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0203ba4:	06a00593          	li	a1,106
ffffffffc0203ba8:	00001517          	auipc	a0,0x1
ffffffffc0203bac:	3d850513          	addi	a0,a0,984 # ffffffffc0204f80 <commands+0x998>
ffffffffc0203bb0:	d52fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203bb4:	00002697          	auipc	a3,0x2
ffffffffc0203bb8:	2f468693          	addi	a3,a3,756 # ffffffffc0205ea8 <default_pmm_manager+0x6d0>
ffffffffc0203bbc:	00001617          	auipc	a2,0x1
ffffffffc0203bc0:	15460613          	addi	a2,a2,340 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203bc4:	1f300593          	li	a1,499
ffffffffc0203bc8:	00002517          	auipc	a0,0x2
ffffffffc0203bcc:	d3050513          	addi	a0,a0,-720 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203bd0:	d32fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203bd4 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203bd4:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bd6:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203bd8:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bda:	fff58713          	addi	a4,a1,-1
ffffffffc0203bde:	17f9                	addi	a5,a5,-2
ffffffffc0203be0:	0ae7ee63          	bltu	a5,a4,ffffffffc0203c9c <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203be4:	cd41                	beqz	a0,ffffffffc0203c7c <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203be6:	6785                	lui	a5,0x1
ffffffffc0203be8:	17fd                	addi	a5,a5,-1
ffffffffc0203bea:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203bec:	c02007b7          	lui	a5,0xc0200
ffffffffc0203bf0:	81b1                	srli	a1,a1,0xc
ffffffffc0203bf2:	06f56863          	bltu	a0,a5,ffffffffc0203c62 <kfree+0x8e>
ffffffffc0203bf6:	0000e697          	auipc	a3,0xe
ffffffffc0203bfa:	9626b683          	ld	a3,-1694(a3) # ffffffffc0211558 <va_pa_offset>
ffffffffc0203bfe:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203c00:	8131                	srli	a0,a0,0xc
ffffffffc0203c02:	0000e797          	auipc	a5,0xe
ffffffffc0203c06:	93e7b783          	ld	a5,-1730(a5) # ffffffffc0211540 <npage>
ffffffffc0203c0a:	04f57a63          	bgeu	a0,a5,ffffffffc0203c5e <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c0e:	fff806b7          	lui	a3,0xfff80
ffffffffc0203c12:	9536                	add	a0,a0,a3
ffffffffc0203c14:	00351793          	slli	a5,a0,0x3
ffffffffc0203c18:	953e                	add	a0,a0,a5
ffffffffc0203c1a:	050e                	slli	a0,a0,0x3
ffffffffc0203c1c:	0000e797          	auipc	a5,0xe
ffffffffc0203c20:	92c7b783          	ld	a5,-1748(a5) # ffffffffc0211548 <pages>
ffffffffc0203c24:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203c26:	100027f3          	csrr	a5,sstatus
ffffffffc0203c2a:	8b89                	andi	a5,a5,2
ffffffffc0203c2c:	eb89                	bnez	a5,ffffffffc0203c3e <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c2e:	0000e797          	auipc	a5,0xe
ffffffffc0203c32:	9227b783          	ld	a5,-1758(a5) # ffffffffc0211550 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203c36:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c38:	739c                	ld	a5,32(a5)
}
ffffffffc0203c3a:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c3c:	8782                	jr	a5
        intr_disable();
ffffffffc0203c3e:	e42a                	sd	a0,8(sp)
ffffffffc0203c40:	e02e                	sd	a1,0(sp)
ffffffffc0203c42:	8adfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203c46:	0000e797          	auipc	a5,0xe
ffffffffc0203c4a:	90a7b783          	ld	a5,-1782(a5) # ffffffffc0211550 <pmm_manager>
ffffffffc0203c4e:	6582                	ld	a1,0(sp)
ffffffffc0203c50:	6522                	ld	a0,8(sp)
ffffffffc0203c52:	739c                	ld	a5,32(a5)
ffffffffc0203c54:	9782                	jalr	a5
}
ffffffffc0203c56:	60e2                	ld	ra,24(sp)
ffffffffc0203c58:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203c5a:	88ffc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203c5e:	ccdfe0ef          	jal	ra,ffffffffc020292a <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203c62:	86aa                	mv	a3,a0
ffffffffc0203c64:	00002617          	auipc	a2,0x2
ffffffffc0203c68:	d2c60613          	addi	a2,a2,-724 # ffffffffc0205990 <default_pmm_manager+0x1b8>
ffffffffc0203c6c:	06c00593          	li	a1,108
ffffffffc0203c70:	00001517          	auipc	a0,0x1
ffffffffc0203c74:	31050513          	addi	a0,a0,784 # ffffffffc0204f80 <commands+0x998>
ffffffffc0203c78:	c8afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203c7c:	00002697          	auipc	a3,0x2
ffffffffc0203c80:	23c68693          	addi	a3,a3,572 # ffffffffc0205eb8 <default_pmm_manager+0x6e0>
ffffffffc0203c84:	00001617          	auipc	a2,0x1
ffffffffc0203c88:	08c60613          	addi	a2,a2,140 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203c8c:	1fa00593          	li	a1,506
ffffffffc0203c90:	00002517          	auipc	a0,0x2
ffffffffc0203c94:	c6850513          	addi	a0,a0,-920 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203c98:	c6afc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c9c:	00002697          	auipc	a3,0x2
ffffffffc0203ca0:	1ec68693          	addi	a3,a3,492 # ffffffffc0205e88 <default_pmm_manager+0x6b0>
ffffffffc0203ca4:	00001617          	auipc	a2,0x1
ffffffffc0203ca8:	06c60613          	addi	a2,a2,108 # ffffffffc0204d10 <commands+0x728>
ffffffffc0203cac:	1f900593          	li	a1,505
ffffffffc0203cb0:	00002517          	auipc	a0,0x2
ffffffffc0203cb4:	c4850513          	addi	a0,a0,-952 # ffffffffc02058f8 <default_pmm_manager+0x120>
ffffffffc0203cb8:	c4afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203cbc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203cbc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203cbe:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203cc0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203cc2:	f10fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203cc6:	cd01                	beqz	a0,ffffffffc0203cde <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203cc8:	4505                	li	a0,1
ffffffffc0203cca:	f0efc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203cce:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203cd0:	810d                	srli	a0,a0,0x3
ffffffffc0203cd2:	0000e797          	auipc	a5,0xe
ffffffffc0203cd6:	82a7bf23          	sd	a0,-1986(a5) # ffffffffc0211510 <max_swap_offset>
}
ffffffffc0203cda:	0141                	addi	sp,sp,16
ffffffffc0203cdc:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203cde:	00002617          	auipc	a2,0x2
ffffffffc0203ce2:	1ea60613          	addi	a2,a2,490 # ffffffffc0205ec8 <default_pmm_manager+0x6f0>
ffffffffc0203ce6:	45b5                	li	a1,13
ffffffffc0203ce8:	00002517          	auipc	a0,0x2
ffffffffc0203cec:	20050513          	addi	a0,a0,512 # ffffffffc0205ee8 <default_pmm_manager+0x710>
ffffffffc0203cf0:	c12fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203cf4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203cf4:	1141                	addi	sp,sp,-16
ffffffffc0203cf6:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cf8:	00855793          	srli	a5,a0,0x8
ffffffffc0203cfc:	c3a5                	beqz	a5,ffffffffc0203d5c <swapfs_read+0x68>
ffffffffc0203cfe:	0000e717          	auipc	a4,0xe
ffffffffc0203d02:	81273703          	ld	a4,-2030(a4) # ffffffffc0211510 <max_swap_offset>
ffffffffc0203d06:	04e7fb63          	bgeu	a5,a4,ffffffffc0203d5c <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d0a:	0000e617          	auipc	a2,0xe
ffffffffc0203d0e:	83e63603          	ld	a2,-1986(a2) # ffffffffc0211548 <pages>
ffffffffc0203d12:	8d91                	sub	a1,a1,a2
ffffffffc0203d14:	4035d613          	srai	a2,a1,0x3
ffffffffc0203d18:	00002597          	auipc	a1,0x2
ffffffffc0203d1c:	4505b583          	ld	a1,1104(a1) # ffffffffc0206168 <error_string+0x38>
ffffffffc0203d20:	02b60633          	mul	a2,a2,a1
ffffffffc0203d24:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d28:	00002797          	auipc	a5,0x2
ffffffffc0203d2c:	4487b783          	ld	a5,1096(a5) # ffffffffc0206170 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d30:	0000e717          	auipc	a4,0xe
ffffffffc0203d34:	81073703          	ld	a4,-2032(a4) # ffffffffc0211540 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d38:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d3a:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d3e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d40:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d42:	02e7f963          	bgeu	a5,a4,ffffffffc0203d74 <swapfs_read+0x80>
}
ffffffffc0203d46:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d48:	0000e797          	auipc	a5,0xe
ffffffffc0203d4c:	8107b783          	ld	a5,-2032(a5) # ffffffffc0211558 <va_pa_offset>
ffffffffc0203d50:	46a1                	li	a3,8
ffffffffc0203d52:	963e                	add	a2,a2,a5
ffffffffc0203d54:	4505                	li	a0,1
}
ffffffffc0203d56:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d58:	e86fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203d5c:	86aa                	mv	a3,a0
ffffffffc0203d5e:	00002617          	auipc	a2,0x2
ffffffffc0203d62:	1a260613          	addi	a2,a2,418 # ffffffffc0205f00 <default_pmm_manager+0x728>
ffffffffc0203d66:	45d1                	li	a1,20
ffffffffc0203d68:	00002517          	auipc	a0,0x2
ffffffffc0203d6c:	18050513          	addi	a0,a0,384 # ffffffffc0205ee8 <default_pmm_manager+0x710>
ffffffffc0203d70:	b92fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203d74:	86b2                	mv	a3,a2
ffffffffc0203d76:	06a00593          	li	a1,106
ffffffffc0203d7a:	00002617          	auipc	a2,0x2
ffffffffc0203d7e:	b5660613          	addi	a2,a2,-1194 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0203d82:	00001517          	auipc	a0,0x1
ffffffffc0203d86:	1fe50513          	addi	a0,a0,510 # ffffffffc0204f80 <commands+0x998>
ffffffffc0203d8a:	b78fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d8e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d8e:	1141                	addi	sp,sp,-16
ffffffffc0203d90:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d92:	00855793          	srli	a5,a0,0x8
ffffffffc0203d96:	c3a5                	beqz	a5,ffffffffc0203df6 <swapfs_write+0x68>
ffffffffc0203d98:	0000d717          	auipc	a4,0xd
ffffffffc0203d9c:	77873703          	ld	a4,1912(a4) # ffffffffc0211510 <max_swap_offset>
ffffffffc0203da0:	04e7fb63          	bgeu	a5,a4,ffffffffc0203df6 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203da4:	0000d617          	auipc	a2,0xd
ffffffffc0203da8:	7a463603          	ld	a2,1956(a2) # ffffffffc0211548 <pages>
ffffffffc0203dac:	8d91                	sub	a1,a1,a2
ffffffffc0203dae:	4035d613          	srai	a2,a1,0x3
ffffffffc0203db2:	00002597          	auipc	a1,0x2
ffffffffc0203db6:	3b65b583          	ld	a1,950(a1) # ffffffffc0206168 <error_string+0x38>
ffffffffc0203dba:	02b60633          	mul	a2,a2,a1
ffffffffc0203dbe:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203dc2:	00002797          	auipc	a5,0x2
ffffffffc0203dc6:	3ae7b783          	ld	a5,942(a5) # ffffffffc0206170 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dca:	0000d717          	auipc	a4,0xd
ffffffffc0203dce:	77673703          	ld	a4,1910(a4) # ffffffffc0211540 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dd2:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dd4:	00c61793          	slli	a5,a2,0xc
ffffffffc0203dd8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203dda:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ddc:	02e7f963          	bgeu	a5,a4,ffffffffc0203e0e <swapfs_write+0x80>
}
ffffffffc0203de0:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203de2:	0000d797          	auipc	a5,0xd
ffffffffc0203de6:	7767b783          	ld	a5,1910(a5) # ffffffffc0211558 <va_pa_offset>
ffffffffc0203dea:	46a1                	li	a3,8
ffffffffc0203dec:	963e                	add	a2,a2,a5
ffffffffc0203dee:	4505                	li	a0,1
}
ffffffffc0203df0:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203df2:	e10fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203df6:	86aa                	mv	a3,a0
ffffffffc0203df8:	00002617          	auipc	a2,0x2
ffffffffc0203dfc:	10860613          	addi	a2,a2,264 # ffffffffc0205f00 <default_pmm_manager+0x728>
ffffffffc0203e00:	45e5                	li	a1,25
ffffffffc0203e02:	00002517          	auipc	a0,0x2
ffffffffc0203e06:	0e650513          	addi	a0,a0,230 # ffffffffc0205ee8 <default_pmm_manager+0x710>
ffffffffc0203e0a:	af8fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e0e:	86b2                	mv	a3,a2
ffffffffc0203e10:	06a00593          	li	a1,106
ffffffffc0203e14:	00002617          	auipc	a2,0x2
ffffffffc0203e18:	abc60613          	addi	a2,a2,-1348 # ffffffffc02058d0 <default_pmm_manager+0xf8>
ffffffffc0203e1c:	00001517          	auipc	a0,0x1
ffffffffc0203e20:	16450513          	addi	a0,a0,356 # ffffffffc0204f80 <commands+0x998>
ffffffffc0203e24:	adefc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e28 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203e28:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203e2c:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203e2e:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203e30:	cb81                	beqz	a5,ffffffffc0203e40 <strlen+0x18>
        cnt ++;
ffffffffc0203e32:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203e34:	00a707b3          	add	a5,a4,a0
ffffffffc0203e38:	0007c783          	lbu	a5,0(a5)
ffffffffc0203e3c:	fbfd                	bnez	a5,ffffffffc0203e32 <strlen+0xa>
ffffffffc0203e3e:	8082                	ret
    }
    return cnt;
}
ffffffffc0203e40:	8082                	ret

ffffffffc0203e42 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203e42:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203e44:	e589                	bnez	a1,ffffffffc0203e4e <strnlen+0xc>
ffffffffc0203e46:	a811                	j	ffffffffc0203e5a <strnlen+0x18>
        cnt ++;
ffffffffc0203e48:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203e4a:	00f58863          	beq	a1,a5,ffffffffc0203e5a <strnlen+0x18>
ffffffffc0203e4e:	00f50733          	add	a4,a0,a5
ffffffffc0203e52:	00074703          	lbu	a4,0(a4)
ffffffffc0203e56:	fb6d                	bnez	a4,ffffffffc0203e48 <strnlen+0x6>
ffffffffc0203e58:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203e5a:	852e                	mv	a0,a1
ffffffffc0203e5c:	8082                	ret

ffffffffc0203e5e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203e5e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203e60:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e64:	0785                	addi	a5,a5,1
ffffffffc0203e66:	0585                	addi	a1,a1,1
ffffffffc0203e68:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e6c:	fb75                	bnez	a4,ffffffffc0203e60 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203e6e:	8082                	ret

ffffffffc0203e70 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e70:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e74:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e78:	cb89                	beqz	a5,ffffffffc0203e8a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203e7a:	0505                	addi	a0,a0,1
ffffffffc0203e7c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e7e:	fee789e3          	beq	a5,a4,ffffffffc0203e70 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e82:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203e86:	9d19                	subw	a0,a0,a4
ffffffffc0203e88:	8082                	ret
ffffffffc0203e8a:	4501                	li	a0,0
ffffffffc0203e8c:	bfed                	j	ffffffffc0203e86 <strcmp+0x16>

ffffffffc0203e8e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203e8e:	00054783          	lbu	a5,0(a0)
ffffffffc0203e92:	c799                	beqz	a5,ffffffffc0203ea0 <strchr+0x12>
        if (*s == c) {
ffffffffc0203e94:	00f58763          	beq	a1,a5,ffffffffc0203ea2 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203e98:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203e9c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203e9e:	fbfd                	bnez	a5,ffffffffc0203e94 <strchr+0x6>
    }
    return NULL;
ffffffffc0203ea0:	4501                	li	a0,0
}
ffffffffc0203ea2:	8082                	ret

ffffffffc0203ea4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203ea4:	ca01                	beqz	a2,ffffffffc0203eb4 <memset+0x10>
ffffffffc0203ea6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203ea8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203eaa:	0785                	addi	a5,a5,1
ffffffffc0203eac:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203eb0:	fec79de3          	bne	a5,a2,ffffffffc0203eaa <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203eb4:	8082                	ret

ffffffffc0203eb6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203eb6:	ca19                	beqz	a2,ffffffffc0203ecc <memcpy+0x16>
ffffffffc0203eb8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203eba:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203ebc:	0005c703          	lbu	a4,0(a1)
ffffffffc0203ec0:	0585                	addi	a1,a1,1
ffffffffc0203ec2:	0785                	addi	a5,a5,1
ffffffffc0203ec4:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203ec8:	fec59ae3          	bne	a1,a2,ffffffffc0203ebc <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203ecc:	8082                	ret

ffffffffc0203ece <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203ece:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ed2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203ed4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ed8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203eda:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ede:	f022                	sd	s0,32(sp)
ffffffffc0203ee0:	ec26                	sd	s1,24(sp)
ffffffffc0203ee2:	e84a                	sd	s2,16(sp)
ffffffffc0203ee4:	f406                	sd	ra,40(sp)
ffffffffc0203ee6:	e44e                	sd	s3,8(sp)
ffffffffc0203ee8:	84aa                	mv	s1,a0
ffffffffc0203eea:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203eec:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203ef0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203ef2:	03067e63          	bgeu	a2,a6,ffffffffc0203f2e <printnum+0x60>
ffffffffc0203ef6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203ef8:	00805763          	blez	s0,ffffffffc0203f06 <printnum+0x38>
ffffffffc0203efc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203efe:	85ca                	mv	a1,s2
ffffffffc0203f00:	854e                	mv	a0,s3
ffffffffc0203f02:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f04:	fc65                	bnez	s0,ffffffffc0203efc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f06:	1a02                	slli	s4,s4,0x20
ffffffffc0203f08:	00002797          	auipc	a5,0x2
ffffffffc0203f0c:	01878793          	addi	a5,a5,24 # ffffffffc0205f20 <default_pmm_manager+0x748>
ffffffffc0203f10:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f14:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f16:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f18:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203f1c:	70a2                	ld	ra,40(sp)
ffffffffc0203f1e:	69a2                	ld	s3,8(sp)
ffffffffc0203f20:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f22:	85ca                	mv	a1,s2
ffffffffc0203f24:	87a6                	mv	a5,s1
}
ffffffffc0203f26:	6942                	ld	s2,16(sp)
ffffffffc0203f28:	64e2                	ld	s1,24(sp)
ffffffffc0203f2a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f2c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203f2e:	03065633          	divu	a2,a2,a6
ffffffffc0203f32:	8722                	mv	a4,s0
ffffffffc0203f34:	f9bff0ef          	jal	ra,ffffffffc0203ece <printnum>
ffffffffc0203f38:	b7f9                	j	ffffffffc0203f06 <printnum+0x38>

ffffffffc0203f3a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203f3a:	7119                	addi	sp,sp,-128
ffffffffc0203f3c:	f4a6                	sd	s1,104(sp)
ffffffffc0203f3e:	f0ca                	sd	s2,96(sp)
ffffffffc0203f40:	ecce                	sd	s3,88(sp)
ffffffffc0203f42:	e8d2                	sd	s4,80(sp)
ffffffffc0203f44:	e4d6                	sd	s5,72(sp)
ffffffffc0203f46:	e0da                	sd	s6,64(sp)
ffffffffc0203f48:	fc5e                	sd	s7,56(sp)
ffffffffc0203f4a:	f06a                	sd	s10,32(sp)
ffffffffc0203f4c:	fc86                	sd	ra,120(sp)
ffffffffc0203f4e:	f8a2                	sd	s0,112(sp)
ffffffffc0203f50:	f862                	sd	s8,48(sp)
ffffffffc0203f52:	f466                	sd	s9,40(sp)
ffffffffc0203f54:	ec6e                	sd	s11,24(sp)
ffffffffc0203f56:	892a                	mv	s2,a0
ffffffffc0203f58:	84ae                	mv	s1,a1
ffffffffc0203f5a:	8d32                	mv	s10,a2
ffffffffc0203f5c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f5e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203f62:	5b7d                	li	s6,-1
ffffffffc0203f64:	00002a97          	auipc	s5,0x2
ffffffffc0203f68:	ff0a8a93          	addi	s5,s5,-16 # ffffffffc0205f54 <default_pmm_manager+0x77c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f6c:	00002b97          	auipc	s7,0x2
ffffffffc0203f70:	1c4b8b93          	addi	s7,s7,452 # ffffffffc0206130 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f74:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203f78:	001d0413          	addi	s0,s10,1
ffffffffc0203f7c:	01350a63          	beq	a0,s3,ffffffffc0203f90 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203f80:	c121                	beqz	a0,ffffffffc0203fc0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203f82:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f84:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f86:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f88:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f8c:	ff351ae3          	bne	a0,s3,ffffffffc0203f80 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f90:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f94:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f98:	4c81                	li	s9,0
ffffffffc0203f9a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203f9c:	5c7d                	li	s8,-1
ffffffffc0203f9e:	5dfd                	li	s11,-1
ffffffffc0203fa0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203fa4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fa6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203faa:	0ff5f593          	zext.b	a1,a1
ffffffffc0203fae:	00140d13          	addi	s10,s0,1
ffffffffc0203fb2:	04b56263          	bltu	a0,a1,ffffffffc0203ff6 <vprintfmt+0xbc>
ffffffffc0203fb6:	058a                	slli	a1,a1,0x2
ffffffffc0203fb8:	95d6                	add	a1,a1,s5
ffffffffc0203fba:	4194                	lw	a3,0(a1)
ffffffffc0203fbc:	96d6                	add	a3,a3,s5
ffffffffc0203fbe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203fc0:	70e6                	ld	ra,120(sp)
ffffffffc0203fc2:	7446                	ld	s0,112(sp)
ffffffffc0203fc4:	74a6                	ld	s1,104(sp)
ffffffffc0203fc6:	7906                	ld	s2,96(sp)
ffffffffc0203fc8:	69e6                	ld	s3,88(sp)
ffffffffc0203fca:	6a46                	ld	s4,80(sp)
ffffffffc0203fcc:	6aa6                	ld	s5,72(sp)
ffffffffc0203fce:	6b06                	ld	s6,64(sp)
ffffffffc0203fd0:	7be2                	ld	s7,56(sp)
ffffffffc0203fd2:	7c42                	ld	s8,48(sp)
ffffffffc0203fd4:	7ca2                	ld	s9,40(sp)
ffffffffc0203fd6:	7d02                	ld	s10,32(sp)
ffffffffc0203fd8:	6de2                	ld	s11,24(sp)
ffffffffc0203fda:	6109                	addi	sp,sp,128
ffffffffc0203fdc:	8082                	ret
            padc = '0';
ffffffffc0203fde:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203fe0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fe4:	846a                	mv	s0,s10
ffffffffc0203fe6:	00140d13          	addi	s10,s0,1
ffffffffc0203fea:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203fee:	0ff5f593          	zext.b	a1,a1
ffffffffc0203ff2:	fcb572e3          	bgeu	a0,a1,ffffffffc0203fb6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203ff6:	85a6                	mv	a1,s1
ffffffffc0203ff8:	02500513          	li	a0,37
ffffffffc0203ffc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203ffe:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204002:	8d22                	mv	s10,s0
ffffffffc0204004:	f73788e3          	beq	a5,s3,ffffffffc0203f74 <vprintfmt+0x3a>
ffffffffc0204008:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020400c:	1d7d                	addi	s10,s10,-1
ffffffffc020400e:	ff379de3          	bne	a5,s3,ffffffffc0204008 <vprintfmt+0xce>
ffffffffc0204012:	b78d                	j	ffffffffc0203f74 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204014:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204018:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020401c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020401e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204022:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204026:	02d86463          	bltu	a6,a3,ffffffffc020404e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020402a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020402e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204032:	0186873b          	addw	a4,a3,s8
ffffffffc0204036:	0017171b          	slliw	a4,a4,0x1
ffffffffc020403a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020403c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204040:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204042:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204046:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020404a:	fed870e3          	bgeu	a6,a3,ffffffffc020402a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020404e:	f40ddce3          	bgez	s11,ffffffffc0203fa6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204052:	8de2                	mv	s11,s8
ffffffffc0204054:	5c7d                	li	s8,-1
ffffffffc0204056:	bf81                	j	ffffffffc0203fa6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204058:	fffdc693          	not	a3,s11
ffffffffc020405c:	96fd                	srai	a3,a3,0x3f
ffffffffc020405e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204062:	00144603          	lbu	a2,1(s0)
ffffffffc0204066:	2d81                	sext.w	s11,s11
ffffffffc0204068:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020406a:	bf35                	j	ffffffffc0203fa6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020406c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204070:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204074:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204076:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204078:	bfd9                	j	ffffffffc020404e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020407a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020407c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204080:	01174463          	blt	a4,a7,ffffffffc0204088 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204084:	1a088e63          	beqz	a7,ffffffffc0204240 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204088:	000a3603          	ld	a2,0(s4)
ffffffffc020408c:	46c1                	li	a3,16
ffffffffc020408e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204090:	2781                	sext.w	a5,a5
ffffffffc0204092:	876e                	mv	a4,s11
ffffffffc0204094:	85a6                	mv	a1,s1
ffffffffc0204096:	854a                	mv	a0,s2
ffffffffc0204098:	e37ff0ef          	jal	ra,ffffffffc0203ece <printnum>
            break;
ffffffffc020409c:	bde1                	j	ffffffffc0203f74 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020409e:	000a2503          	lw	a0,0(s4)
ffffffffc02040a2:	85a6                	mv	a1,s1
ffffffffc02040a4:	0a21                	addi	s4,s4,8
ffffffffc02040a6:	9902                	jalr	s2
            break;
ffffffffc02040a8:	b5f1                	j	ffffffffc0203f74 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040b0:	01174463          	blt	a4,a7,ffffffffc02040b8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02040b4:	18088163          	beqz	a7,ffffffffc0204236 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02040b8:	000a3603          	ld	a2,0(s4)
ffffffffc02040bc:	46a9                	li	a3,10
ffffffffc02040be:	8a2e                	mv	s4,a1
ffffffffc02040c0:	bfc1                	j	ffffffffc0204090 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02040c6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040ca:	bdf1                	j	ffffffffc0203fa6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02040cc:	85a6                	mv	a1,s1
ffffffffc02040ce:	02500513          	li	a0,37
ffffffffc02040d2:	9902                	jalr	s2
            break;
ffffffffc02040d4:	b545                	j	ffffffffc0203f74 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d6:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02040da:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040de:	b5e1                	j	ffffffffc0203fa6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02040e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040e6:	01174463          	blt	a4,a7,ffffffffc02040ee <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02040ea:	14088163          	beqz	a7,ffffffffc020422c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02040ee:	000a3603          	ld	a2,0(s4)
ffffffffc02040f2:	46a1                	li	a3,8
ffffffffc02040f4:	8a2e                	mv	s4,a1
ffffffffc02040f6:	bf69                	j	ffffffffc0204090 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02040f8:	03000513          	li	a0,48
ffffffffc02040fc:	85a6                	mv	a1,s1
ffffffffc02040fe:	e03e                	sd	a5,0(sp)
ffffffffc0204100:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204102:	85a6                	mv	a1,s1
ffffffffc0204104:	07800513          	li	a0,120
ffffffffc0204108:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020410a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020410c:	6782                	ld	a5,0(sp)
ffffffffc020410e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204110:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204114:	bfb5                	j	ffffffffc0204090 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204116:	000a3403          	ld	s0,0(s4)
ffffffffc020411a:	008a0713          	addi	a4,s4,8
ffffffffc020411e:	e03a                	sd	a4,0(sp)
ffffffffc0204120:	14040263          	beqz	s0,ffffffffc0204264 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204124:	0fb05763          	blez	s11,ffffffffc0204212 <vprintfmt+0x2d8>
ffffffffc0204128:	02d00693          	li	a3,45
ffffffffc020412c:	0cd79163          	bne	a5,a3,ffffffffc02041ee <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204130:	00044783          	lbu	a5,0(s0)
ffffffffc0204134:	0007851b          	sext.w	a0,a5
ffffffffc0204138:	cf85                	beqz	a5,ffffffffc0204170 <vprintfmt+0x236>
ffffffffc020413a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020413e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204142:	000c4563          	bltz	s8,ffffffffc020414c <vprintfmt+0x212>
ffffffffc0204146:	3c7d                	addiw	s8,s8,-1
ffffffffc0204148:	036c0263          	beq	s8,s6,ffffffffc020416c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020414c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020414e:	0e0c8e63          	beqz	s9,ffffffffc020424a <vprintfmt+0x310>
ffffffffc0204152:	3781                	addiw	a5,a5,-32
ffffffffc0204154:	0ef47b63          	bgeu	s0,a5,ffffffffc020424a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204158:	03f00513          	li	a0,63
ffffffffc020415c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020415e:	000a4783          	lbu	a5,0(s4)
ffffffffc0204162:	3dfd                	addiw	s11,s11,-1
ffffffffc0204164:	0a05                	addi	s4,s4,1
ffffffffc0204166:	0007851b          	sext.w	a0,a5
ffffffffc020416a:	ffe1                	bnez	a5,ffffffffc0204142 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020416c:	01b05963          	blez	s11,ffffffffc020417e <vprintfmt+0x244>
ffffffffc0204170:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204172:	85a6                	mv	a1,s1
ffffffffc0204174:	02000513          	li	a0,32
ffffffffc0204178:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020417a:	fe0d9be3          	bnez	s11,ffffffffc0204170 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020417e:	6a02                	ld	s4,0(sp)
ffffffffc0204180:	bbd5                	j	ffffffffc0203f74 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204182:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204184:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204188:	01174463          	blt	a4,a7,ffffffffc0204190 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020418c:	08088d63          	beqz	a7,ffffffffc0204226 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204190:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204194:	0a044d63          	bltz	s0,ffffffffc020424e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204198:	8622                	mv	a2,s0
ffffffffc020419a:	8a66                	mv	s4,s9
ffffffffc020419c:	46a9                	li	a3,10
ffffffffc020419e:	bdcd                	j	ffffffffc0204090 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02041a0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02041a4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02041a6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02041a8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02041ac:	8fb5                	xor	a5,a5,a3
ffffffffc02041ae:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02041b2:	02d74163          	blt	a4,a3,ffffffffc02041d4 <vprintfmt+0x29a>
ffffffffc02041b6:	00369793          	slli	a5,a3,0x3
ffffffffc02041ba:	97de                	add	a5,a5,s7
ffffffffc02041bc:	639c                	ld	a5,0(a5)
ffffffffc02041be:	cb99                	beqz	a5,ffffffffc02041d4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02041c0:	86be                	mv	a3,a5
ffffffffc02041c2:	00002617          	auipc	a2,0x2
ffffffffc02041c6:	d8e60613          	addi	a2,a2,-626 # ffffffffc0205f50 <default_pmm_manager+0x778>
ffffffffc02041ca:	85a6                	mv	a1,s1
ffffffffc02041cc:	854a                	mv	a0,s2
ffffffffc02041ce:	0ce000ef          	jal	ra,ffffffffc020429c <printfmt>
ffffffffc02041d2:	b34d                	j	ffffffffc0203f74 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02041d4:	00002617          	auipc	a2,0x2
ffffffffc02041d8:	d6c60613          	addi	a2,a2,-660 # ffffffffc0205f40 <default_pmm_manager+0x768>
ffffffffc02041dc:	85a6                	mv	a1,s1
ffffffffc02041de:	854a                	mv	a0,s2
ffffffffc02041e0:	0bc000ef          	jal	ra,ffffffffc020429c <printfmt>
ffffffffc02041e4:	bb41                	j	ffffffffc0203f74 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02041e6:	00002417          	auipc	s0,0x2
ffffffffc02041ea:	d5240413          	addi	s0,s0,-686 # ffffffffc0205f38 <default_pmm_manager+0x760>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041ee:	85e2                	mv	a1,s8
ffffffffc02041f0:	8522                	mv	a0,s0
ffffffffc02041f2:	e43e                	sd	a5,8(sp)
ffffffffc02041f4:	c4fff0ef          	jal	ra,ffffffffc0203e42 <strnlen>
ffffffffc02041f8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041fc:	01b05b63          	blez	s11,ffffffffc0204212 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204200:	67a2                	ld	a5,8(sp)
ffffffffc0204202:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204206:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204208:	85a6                	mv	a1,s1
ffffffffc020420a:	8552                	mv	a0,s4
ffffffffc020420c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020420e:	fe0d9ce3          	bnez	s11,ffffffffc0204206 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204212:	00044783          	lbu	a5,0(s0)
ffffffffc0204216:	00140a13          	addi	s4,s0,1
ffffffffc020421a:	0007851b          	sext.w	a0,a5
ffffffffc020421e:	d3a5                	beqz	a5,ffffffffc020417e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204220:	05e00413          	li	s0,94
ffffffffc0204224:	bf39                	j	ffffffffc0204142 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204226:	000a2403          	lw	s0,0(s4)
ffffffffc020422a:	b7ad                	j	ffffffffc0204194 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020422c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204230:	46a1                	li	a3,8
ffffffffc0204232:	8a2e                	mv	s4,a1
ffffffffc0204234:	bdb1                	j	ffffffffc0204090 <vprintfmt+0x156>
ffffffffc0204236:	000a6603          	lwu	a2,0(s4)
ffffffffc020423a:	46a9                	li	a3,10
ffffffffc020423c:	8a2e                	mv	s4,a1
ffffffffc020423e:	bd89                	j	ffffffffc0204090 <vprintfmt+0x156>
ffffffffc0204240:	000a6603          	lwu	a2,0(s4)
ffffffffc0204244:	46c1                	li	a3,16
ffffffffc0204246:	8a2e                	mv	s4,a1
ffffffffc0204248:	b5a1                	j	ffffffffc0204090 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020424a:	9902                	jalr	s2
ffffffffc020424c:	bf09                	j	ffffffffc020415e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020424e:	85a6                	mv	a1,s1
ffffffffc0204250:	02d00513          	li	a0,45
ffffffffc0204254:	e03e                	sd	a5,0(sp)
ffffffffc0204256:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204258:	6782                	ld	a5,0(sp)
ffffffffc020425a:	8a66                	mv	s4,s9
ffffffffc020425c:	40800633          	neg	a2,s0
ffffffffc0204260:	46a9                	li	a3,10
ffffffffc0204262:	b53d                	j	ffffffffc0204090 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204264:	03b05163          	blez	s11,ffffffffc0204286 <vprintfmt+0x34c>
ffffffffc0204268:	02d00693          	li	a3,45
ffffffffc020426c:	f6d79de3          	bne	a5,a3,ffffffffc02041e6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204270:	00002417          	auipc	s0,0x2
ffffffffc0204274:	cc840413          	addi	s0,s0,-824 # ffffffffc0205f38 <default_pmm_manager+0x760>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204278:	02800793          	li	a5,40
ffffffffc020427c:	02800513          	li	a0,40
ffffffffc0204280:	00140a13          	addi	s4,s0,1
ffffffffc0204284:	bd6d                	j	ffffffffc020413e <vprintfmt+0x204>
ffffffffc0204286:	00002a17          	auipc	s4,0x2
ffffffffc020428a:	cb3a0a13          	addi	s4,s4,-845 # ffffffffc0205f39 <default_pmm_manager+0x761>
ffffffffc020428e:	02800513          	li	a0,40
ffffffffc0204292:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204296:	05e00413          	li	s0,94
ffffffffc020429a:	b565                	j	ffffffffc0204142 <vprintfmt+0x208>

ffffffffc020429c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020429c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020429e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042a2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02042a4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042a6:	ec06                	sd	ra,24(sp)
ffffffffc02042a8:	f83a                	sd	a4,48(sp)
ffffffffc02042aa:	fc3e                	sd	a5,56(sp)
ffffffffc02042ac:	e0c2                	sd	a6,64(sp)
ffffffffc02042ae:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02042b0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02042b2:	c89ff0ef          	jal	ra,ffffffffc0203f3a <vprintfmt>
}
ffffffffc02042b6:	60e2                	ld	ra,24(sp)
ffffffffc02042b8:	6161                	addi	sp,sp,80
ffffffffc02042ba:	8082                	ret

ffffffffc02042bc <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02042bc:	715d                	addi	sp,sp,-80
ffffffffc02042be:	e486                	sd	ra,72(sp)
ffffffffc02042c0:	e0a6                	sd	s1,64(sp)
ffffffffc02042c2:	fc4a                	sd	s2,56(sp)
ffffffffc02042c4:	f84e                	sd	s3,48(sp)
ffffffffc02042c6:	f452                	sd	s4,40(sp)
ffffffffc02042c8:	f056                	sd	s5,32(sp)
ffffffffc02042ca:	ec5a                	sd	s6,24(sp)
ffffffffc02042cc:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02042ce:	c901                	beqz	a0,ffffffffc02042de <readline+0x22>
ffffffffc02042d0:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02042d2:	00002517          	auipc	a0,0x2
ffffffffc02042d6:	c7e50513          	addi	a0,a0,-898 # ffffffffc0205f50 <default_pmm_manager+0x778>
ffffffffc02042da:	de1fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02042de:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042e0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02042e2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02042e4:	4aa9                	li	s5,10
ffffffffc02042e6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02042e8:	0000db97          	auipc	s7,0xd
ffffffffc02042ec:	e00b8b93          	addi	s7,s7,-512 # ffffffffc02110e8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042f0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02042f4:	dfffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02042f8:	00054a63          	bltz	a0,ffffffffc020430c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042fc:	00a95a63          	bge	s2,a0,ffffffffc0204310 <readline+0x54>
ffffffffc0204300:	029a5263          	bge	s4,s1,ffffffffc0204324 <readline+0x68>
        c = getchar();
ffffffffc0204304:	deffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204308:	fe055ae3          	bgez	a0,ffffffffc02042fc <readline+0x40>
            return NULL;
ffffffffc020430c:	4501                	li	a0,0
ffffffffc020430e:	a091                	j	ffffffffc0204352 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204310:	03351463          	bne	a0,s3,ffffffffc0204338 <readline+0x7c>
ffffffffc0204314:	e8a9                	bnez	s1,ffffffffc0204366 <readline+0xaa>
        c = getchar();
ffffffffc0204316:	dddfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020431a:	fe0549e3          	bltz	a0,ffffffffc020430c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020431e:	fea959e3          	bge	s2,a0,ffffffffc0204310 <readline+0x54>
ffffffffc0204322:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204324:	e42a                	sd	a0,8(sp)
ffffffffc0204326:	dcbfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020432a:	6522                	ld	a0,8(sp)
ffffffffc020432c:	009b87b3          	add	a5,s7,s1
ffffffffc0204330:	2485                	addiw	s1,s1,1
ffffffffc0204332:	00a78023          	sb	a0,0(a5)
ffffffffc0204336:	bf7d                	j	ffffffffc02042f4 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204338:	01550463          	beq	a0,s5,ffffffffc0204340 <readline+0x84>
ffffffffc020433c:	fb651ce3          	bne	a0,s6,ffffffffc02042f4 <readline+0x38>
            cputchar(c);
ffffffffc0204340:	db1fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204344:	0000d517          	auipc	a0,0xd
ffffffffc0204348:	da450513          	addi	a0,a0,-604 # ffffffffc02110e8 <buf>
ffffffffc020434c:	94aa                	add	s1,s1,a0
ffffffffc020434e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204352:	60a6                	ld	ra,72(sp)
ffffffffc0204354:	6486                	ld	s1,64(sp)
ffffffffc0204356:	7962                	ld	s2,56(sp)
ffffffffc0204358:	79c2                	ld	s3,48(sp)
ffffffffc020435a:	7a22                	ld	s4,40(sp)
ffffffffc020435c:	7a82                	ld	s5,32(sp)
ffffffffc020435e:	6b62                	ld	s6,24(sp)
ffffffffc0204360:	6bc2                	ld	s7,16(sp)
ffffffffc0204362:	6161                	addi	sp,sp,80
ffffffffc0204364:	8082                	ret
            cputchar(c);
ffffffffc0204366:	4521                	li	a0,8
ffffffffc0204368:	d89fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020436c:	34fd                	addiw	s1,s1,-1
ffffffffc020436e:	b759                	j	ffffffffc02042f4 <readline+0x38>


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
ffffffffc020004a:	076040ef          	jal	ra,ffffffffc02040c0 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	54258593          	addi	a1,a1,1346 # ffffffffc0204590 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	55a50513          	addi	a0,a0,1370 # ffffffffc02045b0 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	00e030ef          	jal	ra,ffffffffc0203074 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	120010ef          	jal	ra,ffffffffc020118e <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	7e8010ef          	jal	ra,ffffffffc020185e <swap_init>

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
ffffffffc02000ae:	0a8040ef          	jal	ra,ffffffffc0204156 <vprintfmt>
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
ffffffffc02000e4:	072040ef          	jal	ra,ffffffffc0204156 <vprintfmt>
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
ffffffffc0200134:	48850513          	addi	a0,a0,1160 # ffffffffc02045b8 <etext+0x2c>
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
ffffffffc020014a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0205f80 <default_pmm_manager+0x420>
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
ffffffffc0200164:	47850513          	addi	a0,a0,1144 # ffffffffc02045d8 <etext+0x4c>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	48250513          	addi	a0,a0,1154 # ffffffffc02045f8 <etext+0x6c>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	40a58593          	addi	a1,a1,1034 # ffffffffc020458c <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	48e50513          	addi	a0,a0,1166 # ffffffffc0204618 <etext+0x8c>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	49a50513          	addi	a0,a0,1178 # ffffffffc0204638 <etext+0xac>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3be58593          	addi	a1,a1,958 # ffffffffc0211568 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	4a650513          	addi	a0,a0,1190 # ffffffffc0204658 <etext+0xcc>
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
ffffffffc02001e4:	49850513          	addi	a0,a0,1176 # ffffffffc0204678 <etext+0xec>
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
ffffffffc02001f2:	4ba60613          	addi	a2,a2,1210 # ffffffffc02046a8 <etext+0x11c>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	4c650513          	addi	a0,a0,1222 # ffffffffc02046c0 <etext+0x134>
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
ffffffffc020020e:	4ce60613          	addi	a2,a2,1230 # ffffffffc02046d8 <etext+0x14c>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	4e658593          	addi	a1,a1,1254 # ffffffffc02046f8 <etext+0x16c>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	4e650513          	addi	a0,a0,1254 # ffffffffc0204700 <etext+0x174>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	4e860613          	addi	a2,a2,1256 # ffffffffc0204710 <etext+0x184>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	50858593          	addi	a1,a1,1288 # ffffffffc0204738 <etext+0x1ac>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	4c850513          	addi	a0,a0,1224 # ffffffffc0204700 <etext+0x174>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	50460613          	addi	a2,a2,1284 # ffffffffc0204748 <etext+0x1bc>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	51c58593          	addi	a1,a1,1308 # ffffffffc0204768 <etext+0x1dc>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204700 <etext+0x174>
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
ffffffffc0200292:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204778 <etext+0x1ec>
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
ffffffffc02002b4:	4f050513          	addi	a0,a0,1264 # ffffffffc02047a0 <etext+0x214>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	542c0c13          	addi	s8,s8,1346 # ffffffffc0204808 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	43290913          	addi	s2,s2,1074 # ffffffffc0205700 <commands+0xef8>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	4f248493          	addi	s1,s1,1266 # ffffffffc02047c8 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	4f0b0b13          	addi	s6,s6,1264 # ffffffffc02047d0 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	410a0a13          	addi	s4,s4,1040 # ffffffffc02046f8 <etext+0x16c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	1e4040ef          	jal	ra,ffffffffc02044d8 <readline>
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
ffffffffc020030e:	4fed0d13          	addi	s10,s10,1278 # ffffffffc0204808 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	575030ef          	jal	ra,ffffffffc020408c <strcmp>
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
ffffffffc020032c:	561030ef          	jal	ra,ffffffffc020408c <strcmp>
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
ffffffffc020036a:	541030ef          	jal	ra,ffffffffc02040aa <strchr>
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
ffffffffc02003a8:	503030ef          	jal	ra,ffffffffc02040aa <strchr>
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
ffffffffc02003c6:	42e50513          	addi	a0,a0,1070 # ffffffffc02047f0 <etext+0x264>
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
ffffffffc02003f6:	4dd030ef          	jal	ra,ffffffffc02040d2 <memcpy>
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
ffffffffc020041a:	4b9030ef          	jal	ra,ffffffffc02040d2 <memcpy>
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
ffffffffc0200450:	40450513          	addi	a0,a0,1028 # ffffffffc0204850 <commands+0x48>
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
ffffffffc0200528:	34c50513          	addi	a0,a0,844 # ffffffffc0204870 <commands+0x68>
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
ffffffffc0200548:	21e0106f          	j	ffffffffc0201766 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	34460613          	addi	a2,a2,836 # ffffffffc0204890 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	35050513          	addi	a0,a0,848 # ffffffffc02048a8 <commands+0xa0>
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
ffffffffc020058e:	33650513          	addi	a0,a0,822 # ffffffffc02048c0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	33e50513          	addi	a0,a0,830 # ffffffffc02048d8 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	34850513          	addi	a0,a0,840 # ffffffffc02048f0 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	35250513          	addi	a0,a0,850 # ffffffffc0204908 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	35c50513          	addi	a0,a0,860 # ffffffffc0204920 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	36650513          	addi	a0,a0,870 # ffffffffc0204938 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	37050513          	addi	a0,a0,880 # ffffffffc0204950 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	37a50513          	addi	a0,a0,890 # ffffffffc0204968 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	38450513          	addi	a0,a0,900 # ffffffffc0204980 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	38e50513          	addi	a0,a0,910 # ffffffffc0204998 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	39850513          	addi	a0,a0,920 # ffffffffc02049b0 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3a250513          	addi	a0,a0,930 # ffffffffc02049c8 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3ac50513          	addi	a0,a0,940 # ffffffffc02049e0 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	3b650513          	addi	a0,a0,950 # ffffffffc02049f8 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	3c050513          	addi	a0,a0,960 # ffffffffc0204a10 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	3ca50513          	addi	a0,a0,970 # ffffffffc0204a28 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	3d450513          	addi	a0,a0,980 # ffffffffc0204a40 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	3de50513          	addi	a0,a0,990 # ffffffffc0204a58 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3e850513          	addi	a0,a0,1000 # ffffffffc0204a70 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	3f250513          	addi	a0,a0,1010 # ffffffffc0204a88 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204aa0 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	40650513          	addi	a0,a0,1030 # ffffffffc0204ab8 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	41050513          	addi	a0,a0,1040 # ffffffffc0204ad0 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	41a50513          	addi	a0,a0,1050 # ffffffffc0204ae8 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	42450513          	addi	a0,a0,1060 # ffffffffc0204b00 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	42e50513          	addi	a0,a0,1070 # ffffffffc0204b18 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	43850513          	addi	a0,a0,1080 # ffffffffc0204b30 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	44250513          	addi	a0,a0,1090 # ffffffffc0204b48 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	44c50513          	addi	a0,a0,1100 # ffffffffc0204b60 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	45650513          	addi	a0,a0,1110 # ffffffffc0204b78 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	46050513          	addi	a0,a0,1120 # ffffffffc0204b90 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	46650513          	addi	a0,a0,1126 # ffffffffc0204ba8 <commands+0x3a0>
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
ffffffffc020075a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204bc0 <commands+0x3b8>
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
ffffffffc0200772:	46a50513          	addi	a0,a0,1130 # ffffffffc0204bd8 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	47250513          	addi	a0,a0,1138 # ffffffffc0204bf0 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	47a50513          	addi	a0,a0,1146 # ffffffffc0204c08 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	47e50513          	addi	a0,a0,1150 # ffffffffc0204c20 <commands+0x418>
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
ffffffffc02007c2:	52a70713          	addi	a4,a4,1322 # ffffffffc0204ce8 <commands+0x4e0>
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
ffffffffc02007d4:	4c850513          	addi	a0,a0,1224 # ffffffffc0204c98 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	49c50513          	addi	a0,a0,1180 # ffffffffc0204c78 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	45050513          	addi	a0,a0,1104 # ffffffffc0204c38 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	46450513          	addi	a0,a0,1124 # ffffffffc0204c58 <commands+0x450>
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
ffffffffc020082a:	4a250513          	addi	a0,a0,1186 # ffffffffc0204cc8 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	47e50513          	addi	a0,a0,1150 # ffffffffc0204cb8 <commands+0x4b0>
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
ffffffffc0200860:	67470713          	addi	a4,a4,1652 # ffffffffc0204ed0 <commands+0x6c8>
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
ffffffffc0200872:	64a50513          	addi	a0,a0,1610 # ffffffffc0204eb8 <commands+0x6b0>
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
ffffffffc0200894:	48850513          	addi	a0,a0,1160 # ffffffffc0204d18 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	49450513          	addi	a0,a0,1172 # ffffffffc0204d38 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204d58 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	4b850513          	addi	a0,a0,1208 # ffffffffc0204d70 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	4be50513          	addi	a0,a0,1214 # ffffffffc0204d80 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	4d450513          	addi	a0,a0,1236 # ffffffffc0204da0 <commands+0x598>
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
ffffffffc02008ee:	4ce60613          	addi	a2,a2,1230 # ffffffffc0204db8 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	fb250513          	addi	a0,a0,-78 # ffffffffc02048a8 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	4d650513          	addi	a0,a0,1238 # ffffffffc0204dd8 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	4e450513          	addi	a0,a0,1252 # ffffffffc0204df0 <commands+0x5e8>
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
ffffffffc020092e:	48e60613          	addi	a2,a2,1166 # ffffffffc0204db8 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	f7250513          	addi	a0,a0,-142 # ffffffffc02048a8 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	4c650513          	addi	a0,a0,1222 # ffffffffc0204e08 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	4dc50513          	addi	a0,a0,1244 # ffffffffc0204e28 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	4f250513          	addi	a0,a0,1266 # ffffffffc0204e48 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	50850513          	addi	a0,a0,1288 # ffffffffc0204e68 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	51e50513          	addi	a0,a0,1310 # ffffffffc0204e88 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	52c50513          	addi	a0,a0,1324 # ffffffffc0204ea0 <commands+0x698>
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
ffffffffc0200998:	42460613          	addi	a2,a2,1060 # ffffffffc0204db8 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	f0850513          	addi	a0,a0,-248 # ffffffffc02048a8 <commands+0xa0>
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
ffffffffc02009c4:	3f860613          	addi	a2,a2,1016 # ffffffffc0204db8 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	edc50513          	addi	a0,a0,-292 # ffffffffc02048a8 <commands+0xa0>
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

ffffffffc0200ab0 <_lru_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	63878793          	addi	a5,a5,1592 # ffffffffc02110e8 <pra_list_head>
static int
_lru_init_mm(struct mm_struct *mm)
{     

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0200ab8:	f51c                	sd	a5,40(a0)
ffffffffc0200aba:	e79c                	sd	a5,8(a5)
ffffffffc0200abc:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0200abe:	4501                	li	a0,0
ffffffffc0200ac0:	8082                	ret

ffffffffc0200ac2 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc0200ac2:	4501                	li	a0,0
ffffffffc0200ac4:	8082                	ret

ffffffffc0200ac6 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0200ac6:	4501                	li	a0,0
ffffffffc0200ac8:	8082                	ret

ffffffffc0200aca <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0200aca:	4501                	li	a0,0
ffffffffc0200acc:	8082                	ret

ffffffffc0200ace <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0200ace:	715d                	addi	sp,sp,-80
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0200ad0:	00004517          	auipc	a0,0x4
ffffffffc0200ad4:	44050513          	addi	a0,a0,1088 # ffffffffc0204f10 <commands+0x708>
_lru_check_swap(void) {
ffffffffc0200ad8:	f84a                	sd	s2,48(sp)
ffffffffc0200ada:	e486                	sd	ra,72(sp)
ffffffffc0200adc:	e0a2                	sd	s0,64(sp)
ffffffffc0200ade:	fc26                	sd	s1,56(sp)
ffffffffc0200ae0:	f44e                	sd	s3,40(sp)
ffffffffc0200ae2:	f052                	sd	s4,32(sp)
ffffffffc0200ae4:	ec56                	sd	s5,24(sp)
ffffffffc0200ae6:	e85a                	sd	s6,16(sp)
ffffffffc0200ae8:	e45e                	sd	s7,8(sp)
ffffffffc0200aea:	e062                	sd	s8,0(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0200aec:	dceff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0200af0:	678d                	lui	a5,0x3
ffffffffc0200af2:	4731                	li	a4,12
ffffffffc0200af4:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num == 4);
ffffffffc0200af8:	00011917          	auipc	s2,0x11
ffffffffc0200afc:	a2092903          	lw	s2,-1504(s2) # ffffffffc0211518 <pgfault_num>
ffffffffc0200b00:	4791                	li	a5,4
ffffffffc0200b02:	1af91b63          	bne	s2,a5,ffffffffc0200cb8 <_lru_check_swap+0x1ea>
    cprintf("%d\n",pgfault_num);
ffffffffc0200b06:	00011417          	auipc	s0,0x11
ffffffffc0200b0a:	a1240413          	addi	s0,s0,-1518 # ffffffffc0211518 <pgfault_num>
ffffffffc0200b0e:	400c                	lw	a1,0(s0)
ffffffffc0200b10:	00004517          	auipc	a0,0x4
ffffffffc0200b14:	47050513          	addi	a0,a0,1136 # ffffffffc0204f80 <commands+0x778>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200b18:	6985                	lui	s3,0x1
    cprintf("%d\n",pgfault_num);
ffffffffc0200b1a:	2581                	sext.w	a1,a1
ffffffffc0200b1c:	d9eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200b20:	00004517          	auipc	a0,0x4
ffffffffc0200b24:	46850513          	addi	a0,a0,1128 # ffffffffc0204f88 <commands+0x780>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200b28:	4a29                	li	s4,10
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200b2a:	d90ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200b2e:	01498023          	sb	s4,0(s3) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num == 4);
ffffffffc0200b32:	4004                	lw	s1,0(s0)
ffffffffc0200b34:	2481                	sext.w	s1,s1
ffffffffc0200b36:	2b249163          	bne	s1,s2,ffffffffc0200dd8 <_lru_check_swap+0x30a>
    cprintf("%d\n",pgfault_num);
ffffffffc0200b3a:	400c                	lw	a1,0(s0)
ffffffffc0200b3c:	00004517          	auipc	a0,0x4
ffffffffc0200b40:	44450513          	addi	a0,a0,1092 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200b44:	2581                	sext.w	a1,a1
ffffffffc0200b46:	d74ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0200b4a:	00004517          	auipc	a0,0x4
ffffffffc0200b4e:	46650513          	addi	a0,a0,1126 # ffffffffc0204fb0 <commands+0x7a8>
ffffffffc0200b52:	d68ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0200b56:	6791                	lui	a5,0x4
ffffffffc0200b58:	4735                	li	a4,13
ffffffffc0200b5a:	00e78023          	sb	a4,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num == 4);
ffffffffc0200b5e:	00042903          	lw	s2,0(s0)
ffffffffc0200b62:	2901                	sext.w	s2,s2
ffffffffc0200b64:	24991a63          	bne	s2,s1,ffffffffc0200db8 <_lru_check_swap+0x2ea>
    cprintf("%d\n",pgfault_num);
ffffffffc0200b68:	400c                	lw	a1,0(s0)
ffffffffc0200b6a:	00004517          	auipc	a0,0x4
ffffffffc0200b6e:	41650513          	addi	a0,a0,1046 # ffffffffc0204f80 <commands+0x778>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200b72:	6a89                	lui	s5,0x2
    cprintf("%d\n",pgfault_num);
ffffffffc0200b74:	2581                	sext.w	a1,a1
ffffffffc0200b76:	d44ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200b7a:	00004517          	auipc	a0,0x4
ffffffffc0200b7e:	45e50513          	addi	a0,a0,1118 # ffffffffc0204fd8 <commands+0x7d0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200b82:	4b2d                	li	s6,11
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200b84:	d36ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200b88:	016a8023          	sb	s6,0(s5) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num == 4);
ffffffffc0200b8c:	401c                	lw	a5,0(s0)
ffffffffc0200b8e:	2781                	sext.w	a5,a5
ffffffffc0200b90:	21279463          	bne	a5,s2,ffffffffc0200d98 <_lru_check_swap+0x2ca>
    cprintf("%d\n",pgfault_num);
ffffffffc0200b94:	400c                	lw	a1,0(s0)
ffffffffc0200b96:	00004517          	auipc	a0,0x4
ffffffffc0200b9a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204f80 <commands+0x778>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200b9e:	6b95                	lui	s7,0x5
    cprintf("%d\n",pgfault_num);
ffffffffc0200ba0:	2581                	sext.w	a1,a1
ffffffffc0200ba2:	d18ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0200ba6:	00004517          	auipc	a0,0x4
ffffffffc0200baa:	45a50513          	addi	a0,a0,1114 # ffffffffc0205000 <commands+0x7f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200bae:	4c39                	li	s8,14
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0200bb0:	d0aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200bb4:	018b8023          	sb	s8,0(s7) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc0200bb8:	4004                	lw	s1,0(s0)
ffffffffc0200bba:	4795                	li	a5,5
ffffffffc0200bbc:	2481                	sext.w	s1,s1
ffffffffc0200bbe:	1af49d63          	bne	s1,a5,ffffffffc0200d78 <_lru_check_swap+0x2aa>
    cprintf("%d\n",pgfault_num);
ffffffffc0200bc2:	400c                	lw	a1,0(s0)
ffffffffc0200bc4:	00004517          	auipc	a0,0x4
ffffffffc0200bc8:	3bc50513          	addi	a0,a0,956 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200bcc:	2581                	sext.w	a1,a1
ffffffffc0200bce:	cecff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200bd2:	00004517          	auipc	a0,0x4
ffffffffc0200bd6:	40650513          	addi	a0,a0,1030 # ffffffffc0204fd8 <commands+0x7d0>
ffffffffc0200bda:	ce0ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200bde:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 5);
ffffffffc0200be2:	00042903          	lw	s2,0(s0)
ffffffffc0200be6:	2901                	sext.w	s2,s2
ffffffffc0200be8:	16991863          	bne	s2,s1,ffffffffc0200d58 <_lru_check_swap+0x28a>
    cprintf("%d\n",pgfault_num);
ffffffffc0200bec:	400c                	lw	a1,0(s0)
ffffffffc0200bee:	00004517          	auipc	a0,0x4
ffffffffc0200bf2:	39250513          	addi	a0,a0,914 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200bf6:	2581                	sext.w	a1,a1
ffffffffc0200bf8:	cc2ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200bfc:	00004517          	auipc	a0,0x4
ffffffffc0200c00:	38c50513          	addi	a0,a0,908 # ffffffffc0204f88 <commands+0x780>
ffffffffc0200c04:	cb6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200c08:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 5);
ffffffffc0200c0c:	4004                	lw	s1,0(s0)
ffffffffc0200c0e:	2481                	sext.w	s1,s1
ffffffffc0200c10:	13249463          	bne	s1,s2,ffffffffc0200d38 <_lru_check_swap+0x26a>
    cprintf("%d\n",pgfault_num);
ffffffffc0200c14:	400c                	lw	a1,0(s0)
ffffffffc0200c16:	00004517          	auipc	a0,0x4
ffffffffc0200c1a:	36a50513          	addi	a0,a0,874 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200c1e:	2581                	sext.w	a1,a1
ffffffffc0200c20:	c9aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200c24:	00004517          	auipc	a0,0x4
ffffffffc0200c28:	3b450513          	addi	a0,a0,948 # ffffffffc0204fd8 <commands+0x7d0>
ffffffffc0200c2c:	c8eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200c30:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 5);
ffffffffc0200c34:	00042903          	lw	s2,0(s0)
ffffffffc0200c38:	2901                	sext.w	s2,s2
ffffffffc0200c3a:	0c991f63          	bne	s2,s1,ffffffffc0200d18 <_lru_check_swap+0x24a>
    cprintf("%d\n",pgfault_num); 
ffffffffc0200c3e:	400c                	lw	a1,0(s0)
ffffffffc0200c40:	00004517          	auipc	a0,0x4
ffffffffc0200c44:	34050513          	addi	a0,a0,832 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200c48:	2581                	sext.w	a1,a1
ffffffffc0200c4a:	c70ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	3b250513          	addi	a0,a0,946 # ffffffffc0205000 <commands+0x7f8>
ffffffffc0200c56:	c64ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200c5a:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 5);
ffffffffc0200c5e:	4004                	lw	s1,0(s0)
ffffffffc0200c60:	2481                	sext.w	s1,s1
ffffffffc0200c62:	09249b63          	bne	s1,s2,ffffffffc0200cf8 <_lru_check_swap+0x22a>
    cprintf("%d\n",pgfault_num);
ffffffffc0200c66:	400c                	lw	a1,0(s0)
ffffffffc0200c68:	00004517          	auipc	a0,0x4
ffffffffc0200c6c:	31850513          	addi	a0,a0,792 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200c70:	2581                	sext.w	a1,a1
ffffffffc0200c72:	c48ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200c76:	00004517          	auipc	a0,0x4
ffffffffc0200c7a:	31250513          	addi	a0,a0,786 # ffffffffc0204f88 <commands+0x780>
ffffffffc0200c7e:	c3cff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200c82:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 5);
ffffffffc0200c86:	401c                	lw	a5,0(s0)
ffffffffc0200c88:	2781                	sext.w	a5,a5
ffffffffc0200c8a:	04979763          	bne	a5,s1,ffffffffc0200cd8 <_lru_check_swap+0x20a>
    cprintf("%d\n",pgfault_num);
ffffffffc0200c8e:	400c                	lw	a1,0(s0)
ffffffffc0200c90:	00004517          	auipc	a0,0x4
ffffffffc0200c94:	2f050513          	addi	a0,a0,752 # ffffffffc0204f80 <commands+0x778>
ffffffffc0200c98:	2581                	sext.w	a1,a1
ffffffffc0200c9a:	c20ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0200c9e:	60a6                	ld	ra,72(sp)
ffffffffc0200ca0:	6406                	ld	s0,64(sp)
ffffffffc0200ca2:	74e2                	ld	s1,56(sp)
ffffffffc0200ca4:	7942                	ld	s2,48(sp)
ffffffffc0200ca6:	79a2                	ld	s3,40(sp)
ffffffffc0200ca8:	7a02                	ld	s4,32(sp)
ffffffffc0200caa:	6ae2                	ld	s5,24(sp)
ffffffffc0200cac:	6b42                	ld	s6,16(sp)
ffffffffc0200cae:	6ba2                	ld	s7,8(sp)
ffffffffc0200cb0:	6c02                	ld	s8,0(sp)
ffffffffc0200cb2:	4501                	li	a0,0
ffffffffc0200cb4:	6161                	addi	sp,sp,80
ffffffffc0200cb6:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc0200cb8:	00004697          	auipc	a3,0x4
ffffffffc0200cbc:	28068693          	addi	a3,a3,640 # ffffffffc0204f38 <commands+0x730>
ffffffffc0200cc0:	00004617          	auipc	a2,0x4
ffffffffc0200cc4:	29060613          	addi	a2,a2,656 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200cc8:	03400593          	li	a1,52
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	29c50513          	addi	a0,a0,668 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200cd4:	c2eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200cd8:	00004697          	auipc	a3,0x4
ffffffffc0200cdc:	35068693          	addi	a3,a3,848 # ffffffffc0205028 <commands+0x820>
ffffffffc0200ce0:	00004617          	auipc	a2,0x4
ffffffffc0200ce4:	27060613          	addi	a2,a2,624 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200ce8:	06200593          	li	a1,98
ffffffffc0200cec:	00004517          	auipc	a0,0x4
ffffffffc0200cf0:	27c50513          	addi	a0,a0,636 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200cf4:	c0eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200cf8:	00004697          	auipc	a3,0x4
ffffffffc0200cfc:	33068693          	addi	a3,a3,816 # ffffffffc0205028 <commands+0x820>
ffffffffc0200d00:	00004617          	auipc	a2,0x4
ffffffffc0200d04:	25060613          	addi	a2,a2,592 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200d08:	05c00593          	li	a1,92
ffffffffc0200d0c:	00004517          	auipc	a0,0x4
ffffffffc0200d10:	25c50513          	addi	a0,a0,604 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200d14:	beeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200d18:	00004697          	auipc	a3,0x4
ffffffffc0200d1c:	31068693          	addi	a3,a3,784 # ffffffffc0205028 <commands+0x820>
ffffffffc0200d20:	00004617          	auipc	a2,0x4
ffffffffc0200d24:	23060613          	addi	a2,a2,560 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200d28:	05700593          	li	a1,87
ffffffffc0200d2c:	00004517          	auipc	a0,0x4
ffffffffc0200d30:	23c50513          	addi	a0,a0,572 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200d34:	bceff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200d38:	00004697          	auipc	a3,0x4
ffffffffc0200d3c:	2f068693          	addi	a3,a3,752 # ffffffffc0205028 <commands+0x820>
ffffffffc0200d40:	00004617          	auipc	a2,0x4
ffffffffc0200d44:	21060613          	addi	a2,a2,528 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200d48:	05200593          	li	a1,82
ffffffffc0200d4c:	00004517          	auipc	a0,0x4
ffffffffc0200d50:	21c50513          	addi	a0,a0,540 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200d54:	baeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	2d068693          	addi	a3,a3,720 # ffffffffc0205028 <commands+0x820>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	1f060613          	addi	a2,a2,496 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200d68:	04d00593          	li	a1,77
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	1fc50513          	addi	a0,a0,508 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200d74:	b8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200d78:	00004697          	auipc	a3,0x4
ffffffffc0200d7c:	2b068693          	addi	a3,a3,688 # ffffffffc0205028 <commands+0x820>
ffffffffc0200d80:	00004617          	auipc	a2,0x4
ffffffffc0200d84:	1d060613          	addi	a2,a2,464 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200d88:	04800593          	li	a1,72
ffffffffc0200d8c:	00004517          	auipc	a0,0x4
ffffffffc0200d90:	1dc50513          	addi	a0,a0,476 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200d94:	b6eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200d98:	00004697          	auipc	a3,0x4
ffffffffc0200d9c:	1a068693          	addi	a3,a3,416 # ffffffffc0204f38 <commands+0x730>
ffffffffc0200da0:	00004617          	auipc	a2,0x4
ffffffffc0200da4:	1b060613          	addi	a2,a2,432 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200da8:	04300593          	li	a1,67
ffffffffc0200dac:	00004517          	auipc	a0,0x4
ffffffffc0200db0:	1bc50513          	addi	a0,a0,444 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200db4:	b4eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200db8:	00004697          	auipc	a3,0x4
ffffffffc0200dbc:	18068693          	addi	a3,a3,384 # ffffffffc0204f38 <commands+0x730>
ffffffffc0200dc0:	00004617          	auipc	a2,0x4
ffffffffc0200dc4:	19060613          	addi	a2,a2,400 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200dc8:	03e00593          	li	a1,62
ffffffffc0200dcc:	00004517          	auipc	a0,0x4
ffffffffc0200dd0:	19c50513          	addi	a0,a0,412 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200dd4:	b2eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200dd8:	00004697          	auipc	a3,0x4
ffffffffc0200ddc:	16068693          	addi	a3,a3,352 # ffffffffc0204f38 <commands+0x730>
ffffffffc0200de0:	00004617          	auipc	a2,0x4
ffffffffc0200de4:	17060613          	addi	a2,a2,368 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200de8:	03900593          	li	a1,57
ffffffffc0200dec:	00004517          	auipc	a0,0x4
ffffffffc0200df0:	17c50513          	addi	a0,a0,380 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200df4:	b0eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200df8 <_lru_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200df8:	7518                	ld	a4,40(a0)
{
ffffffffc0200dfa:	1141                	addi	sp,sp,-16
ffffffffc0200dfc:	e406                	sd	ra,8(sp)
        assert(head != NULL);
ffffffffc0200dfe:	c731                	beqz	a4,ffffffffc0200e4a <_lru_swap_out_victim+0x52>
    assert(in_tick==0);
ffffffffc0200e00:	e60d                	bnez	a2,ffffffffc0200e2a <_lru_swap_out_victim+0x32>
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200e02:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0200e04:	00f70d63          	beq	a4,a5,ffffffffc0200e1e <_lru_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e08:	6394                	ld	a3,0(a5)
ffffffffc0200e0a:	6798                	ld	a4,8(a5)
}
ffffffffc0200e0c:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0200e0e:	fd078793          	addi	a5,a5,-48
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200e12:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200e14:	e314                	sd	a3,0(a4)
ffffffffc0200e16:	e19c                	sd	a5,0(a1)
}
ffffffffc0200e18:	4501                	li	a0,0
ffffffffc0200e1a:	0141                	addi	sp,sp,16
ffffffffc0200e1c:	8082                	ret
ffffffffc0200e1e:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0200e20:	0005b023          	sd	zero,0(a1)
}
ffffffffc0200e24:	4501                	li	a0,0
ffffffffc0200e26:	0141                	addi	sp,sp,16
ffffffffc0200e28:	8082                	ret
    assert(in_tick==0);
ffffffffc0200e2a:	00004697          	auipc	a3,0x4
ffffffffc0200e2e:	22668693          	addi	a3,a3,550 # ffffffffc0205050 <commands+0x848>
ffffffffc0200e32:	00004617          	auipc	a2,0x4
ffffffffc0200e36:	11e60613          	addi	a2,a2,286 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200e3a:	02500593          	li	a1,37
ffffffffc0200e3e:	00004517          	auipc	a0,0x4
ffffffffc0200e42:	12a50513          	addi	a0,a0,298 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200e46:	abcff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(head != NULL);
ffffffffc0200e4a:	00004697          	auipc	a3,0x4
ffffffffc0200e4e:	1f668693          	addi	a3,a3,502 # ffffffffc0205040 <commands+0x838>
ffffffffc0200e52:	00004617          	auipc	a2,0x4
ffffffffc0200e56:	0fe60613          	addi	a2,a2,254 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200e5a:	02400593          	li	a1,36
ffffffffc0200e5e:	00004517          	auipc	a0,0x4
ffffffffc0200e62:	10a50513          	addi	a0,a0,266 # ffffffffc0204f68 <commands+0x760>
ffffffffc0200e66:	a9cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200e6a <_lru_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200e6a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0200e6c:	cb91                	beqz	a5,ffffffffc0200e80 <_lru_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e6e:	6794                	ld	a3,8(a5)
ffffffffc0200e70:	03060713          	addi	a4,a2,48
}
ffffffffc0200e74:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0200e76:	e298                	sd	a4,0(a3)
ffffffffc0200e78:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200e7a:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0200e7c:	fa1c                	sd	a5,48(a2)
ffffffffc0200e7e:	8082                	ret
{
ffffffffc0200e80:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	1de68693          	addi	a3,a3,478 # ffffffffc0205060 <commands+0x858>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	0c660613          	addi	a2,a2,198 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200e92:	45ed                	li	a1,27
ffffffffc0200e94:	00004517          	auipc	a0,0x4
ffffffffc0200e98:	0d450513          	addi	a0,a0,212 # ffffffffc0204f68 <commands+0x760>
{
ffffffffc0200e9c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0200e9e:	a64ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ea2 <lru_pgfault>:
        *ptep &= ~PTE_R;
    }
    return 0;
}

int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0200ea2:	7179                	addi	sp,sp,-48
ffffffffc0200ea4:	ec26                	sd	s1,24(sp)
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0200ea6:	85b2                	mv	a1,a2
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0200ea8:	84aa                	mv	s1,a0
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0200eaa:	00004517          	auipc	a0,0x4
ffffffffc0200eae:	1d650513          	addi	a0,a0,470 # ffffffffc0205080 <commands+0x878>
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0200eb2:	e84a                	sd	s2,16(sp)
ffffffffc0200eb4:	f406                	sd	ra,40(sp)
ffffffffc0200eb6:	f022                	sd	s0,32(sp)
ffffffffc0200eb8:	e44e                	sd	s3,8(sp)
ffffffffc0200eba:	8932                	mv	s2,a2
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0200ebc:	9feff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    // 设置所有页面不可读
    if(swap_init_ok) 
ffffffffc0200ec0:	00010797          	auipc	a5,0x10
ffffffffc0200ec4:	6707a783          	lw	a5,1648(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200ec8:	ebc9                	bnez	a5,ffffffffc0200f5a <lru_pgfault+0xb8>
        unable_page_read(mm);
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200eca:	6c88                	ld	a0,24(s1)
ffffffffc0200ecc:	4601                	li	a2,0
ffffffffc0200ece:	85ca                	mv	a1,s2
ffffffffc0200ed0:	5bb010ef          	jal	ra,ffffffffc0202c8a <get_pte>
    *ptep |= PTE_R;
ffffffffc0200ed4:	6114                	ld	a3,0(a0)
    if(!swap_init_ok) 
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	65a72703          	lw	a4,1626(a4) # ffffffffc0211530 <swap_init_ok>
    *ptep |= PTE_R;
ffffffffc0200ede:	0026e793          	ori	a5,a3,2
ffffffffc0200ee2:	e11c                	sd	a5,0(a0)
    if(!swap_init_ok) 
ffffffffc0200ee4:	eb09                	bnez	a4,ffffffffc0200ef6 <lru_pgfault+0x54>
            list_add(head, le);
            break;
        }
    }
    return 0;
}
ffffffffc0200ee6:	70a2                	ld	ra,40(sp)
ffffffffc0200ee8:	7402                	ld	s0,32(sp)
ffffffffc0200eea:	64e2                	ld	s1,24(sp)
ffffffffc0200eec:	6942                	ld	s2,16(sp)
ffffffffc0200eee:	69a2                	ld	s3,8(sp)
ffffffffc0200ef0:	4501                	li	a0,0
ffffffffc0200ef2:	6145                	addi	sp,sp,48
ffffffffc0200ef4:	8082                	ret
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

static inline struct Page *pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
ffffffffc0200ef6:	8a85                	andi	a3,a3,1
ffffffffc0200ef8:	c2d9                	beqz	a3,ffffffffc0200f7e <lru_pgfault+0xdc>
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200efa:	078a                	slli	a5,a5,0x2
ffffffffc0200efc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200efe:	00010717          	auipc	a4,0x10
ffffffffc0200f02:	64a73703          	ld	a4,1610(a4) # ffffffffc0211548 <npage>
ffffffffc0200f06:	08e7f863          	bgeu	a5,a4,ffffffffc0200f96 <lru_pgfault+0xf4>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f0a:	00005717          	auipc	a4,0x5
ffffffffc0200f0e:	52e73703          	ld	a4,1326(a4) # ffffffffc0206438 <nbase>
ffffffffc0200f12:	8f99                	sub	a5,a5,a4
ffffffffc0200f14:	00379613          	slli	a2,a5,0x3
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc0200f18:	7494                	ld	a3,40(s1)
ffffffffc0200f1a:	97b2                	add	a5,a5,a2
ffffffffc0200f1c:	078e                	slli	a5,a5,0x3
ffffffffc0200f1e:	00010617          	auipc	a2,0x10
ffffffffc0200f22:	63263603          	ld	a2,1586(a2) # ffffffffc0211550 <pages>
ffffffffc0200f26:	963e                	add	a2,a2,a5
ffffffffc0200f28:	87b6                	mv	a5,a3
    return listelm->prev;
ffffffffc0200f2a:	639c                	ld	a5,0(a5)
    while ((le = list_prev(le)) != head)
ffffffffc0200f2c:	faf68de3          	beq	a3,a5,ffffffffc0200ee6 <lru_pgfault+0x44>
        struct Page* curr = le2page(le, pra_page_link);
ffffffffc0200f30:	fd078713          	addi	a4,a5,-48
        if(page == curr) {
ffffffffc0200f34:	fee61be3          	bne	a2,a4,ffffffffc0200f2a <lru_pgfault+0x88>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f38:	638c                	ld	a1,0(a5)
ffffffffc0200f3a:	6790                	ld	a2,8(a5)
}
ffffffffc0200f3c:	70a2                	ld	ra,40(sp)
ffffffffc0200f3e:	7402                	ld	s0,32(sp)
    prev->next = next;
ffffffffc0200f40:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f42:	6698                	ld	a4,8(a3)
    next->prev = prev;
ffffffffc0200f44:	e20c                	sd	a1,0(a2)
ffffffffc0200f46:	64e2                	ld	s1,24(sp)
    prev->next = next->prev = elm;
ffffffffc0200f48:	e31c                	sd	a5,0(a4)
ffffffffc0200f4a:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0200f4c:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0200f4e:	e394                	sd	a3,0(a5)
ffffffffc0200f50:	6942                	ld	s2,16(sp)
ffffffffc0200f52:	69a2                	ld	s3,8(sp)
ffffffffc0200f54:	4501                	li	a0,0
ffffffffc0200f56:	6145                	addi	sp,sp,48
ffffffffc0200f58:	8082                	ret
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc0200f5a:	0284b983          	ld	s3,40(s1)
    return listelm->prev;
ffffffffc0200f5e:	0009b403          	ld	s0,0(s3)
    while ((le = list_prev(le)) != head)
ffffffffc0200f62:	f68984e3          	beq	s3,s0,ffffffffc0200eca <lru_pgfault+0x28>
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc0200f66:	680c                	ld	a1,16(s0)
ffffffffc0200f68:	6c88                	ld	a0,24(s1)
ffffffffc0200f6a:	4601                	li	a2,0
ffffffffc0200f6c:	51f010ef          	jal	ra,ffffffffc0202c8a <get_pte>
        *ptep &= ~PTE_R;
ffffffffc0200f70:	611c                	ld	a5,0(a0)
ffffffffc0200f72:	6000                	ld	s0,0(s0)
ffffffffc0200f74:	9bf5                	andi	a5,a5,-3
ffffffffc0200f76:	e11c                	sd	a5,0(a0)
    while ((le = list_prev(le)) != head)
ffffffffc0200f78:	fe8997e3          	bne	s3,s0,ffffffffc0200f66 <lru_pgfault+0xc4>
ffffffffc0200f7c:	b7b9                	j	ffffffffc0200eca <lru_pgfault+0x28>
        panic("pte2page called with invalid pte");
ffffffffc0200f7e:	00004617          	auipc	a2,0x4
ffffffffc0200f82:	11a60613          	addi	a2,a2,282 # ffffffffc0205098 <commands+0x890>
ffffffffc0200f86:	07000593          	li	a1,112
ffffffffc0200f8a:	00004517          	auipc	a0,0x4
ffffffffc0200f8e:	13650513          	addi	a0,a0,310 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0200f92:	970ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f96:	00004617          	auipc	a2,0x4
ffffffffc0200f9a:	13a60613          	addi	a2,a2,314 # ffffffffc02050d0 <commands+0x8c8>
ffffffffc0200f9e:	06500593          	li	a1,101
ffffffffc0200fa2:	00004517          	auipc	a0,0x4
ffffffffc0200fa6:	11e50513          	addi	a0,a0,286 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0200faa:	958ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200fae <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200fae:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc0200fb0:	00004697          	auipc	a3,0x4
ffffffffc0200fb4:	15868693          	addi	a3,a3,344 # ffffffffc0205108 <commands+0x900>
ffffffffc0200fb8:	00004617          	auipc	a2,0x4
ffffffffc0200fbc:	f9860613          	addi	a2,a2,-104 # ffffffffc0204f50 <commands+0x748>
ffffffffc0200fc0:	07f00593          	li	a1,127
ffffffffc0200fc4:	00004517          	auipc	a0,0x4
ffffffffc0200fc8:	16450513          	addi	a0,a0,356 # ffffffffc0205128 <commands+0x920>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200fcc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc0200fce:	934ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200fd2 <mm_create>:
mm_create(void) {
ffffffffc0200fd2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200fd4:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200fd8:	e022                	sd	s0,0(sp)
ffffffffc0200fda:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200fdc:	55b020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
ffffffffc0200fe0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200fe2:	c105                	beqz	a0,ffffffffc0201002 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0200fe4:	e408                	sd	a0,8(s0)
ffffffffc0200fe6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200fe8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200fec:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ff0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0200ff4:	00010797          	auipc	a5,0x10
ffffffffc0200ff8:	53c7a783          	lw	a5,1340(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200ffc:	eb81                	bnez	a5,ffffffffc020100c <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200ffe:	02053423          	sd	zero,40(a0)
}
ffffffffc0201002:	60a2                	ld	ra,8(sp)
ffffffffc0201004:	8522                	mv	a0,s0
ffffffffc0201006:	6402                	ld	s0,0(sp)
ffffffffc0201008:	0141                	addi	sp,sp,16
ffffffffc020100a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc020100c:	6bd000ef          	jal	ra,ffffffffc0201ec8 <swap_init_mm>
}
ffffffffc0201010:	60a2                	ld	ra,8(sp)
ffffffffc0201012:	8522                	mv	a0,s0
ffffffffc0201014:	6402                	ld	s0,0(sp)
ffffffffc0201016:	0141                	addi	sp,sp,16
ffffffffc0201018:	8082                	ret

ffffffffc020101a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020101a:	1101                	addi	sp,sp,-32
ffffffffc020101c:	e04a                	sd	s2,0(sp)
ffffffffc020101e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201020:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201024:	e822                	sd	s0,16(sp)
ffffffffc0201026:	e426                	sd	s1,8(sp)
ffffffffc0201028:	ec06                	sd	ra,24(sp)
ffffffffc020102a:	84ae                	mv	s1,a1
ffffffffc020102c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020102e:	509020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
    if (vma != NULL) {
ffffffffc0201032:	c509                	beqz	a0,ffffffffc020103c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201034:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201038:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020103a:	ed00                	sd	s0,24(a0)
}
ffffffffc020103c:	60e2                	ld	ra,24(sp)
ffffffffc020103e:	6442                	ld	s0,16(sp)
ffffffffc0201040:	64a2                	ld	s1,8(sp)
ffffffffc0201042:	6902                	ld	s2,0(sp)
ffffffffc0201044:	6105                	addi	sp,sp,32
ffffffffc0201046:	8082                	ret

ffffffffc0201048 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0201048:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020104a:	c505                	beqz	a0,ffffffffc0201072 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020104c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020104e:	c501                	beqz	a0,ffffffffc0201056 <find_vma+0xe>
ffffffffc0201050:	651c                	ld	a5,8(a0)
ffffffffc0201052:	02f5f263          	bgeu	a1,a5,ffffffffc0201076 <find_vma+0x2e>
    return listelm->next;
ffffffffc0201056:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201058:	00f68d63          	beq	a3,a5,ffffffffc0201072 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020105c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201060:	00e5e663          	bltu	a1,a4,ffffffffc020106c <find_vma+0x24>
ffffffffc0201064:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201068:	00e5ec63          	bltu	a1,a4,ffffffffc0201080 <find_vma+0x38>
ffffffffc020106c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020106e:	fef697e3          	bne	a3,a5,ffffffffc020105c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201072:	4501                	li	a0,0
}
ffffffffc0201074:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201076:	691c                	ld	a5,16(a0)
ffffffffc0201078:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201056 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020107c:	ea88                	sd	a0,16(a3)
ffffffffc020107e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201080:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201084:	ea88                	sd	a0,16(a3)
ffffffffc0201086:	8082                	ret

ffffffffc0201088 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201088:	6590                	ld	a2,8(a1)
ffffffffc020108a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020108e:	1141                	addi	sp,sp,-16
ffffffffc0201090:	e406                	sd	ra,8(sp)
ffffffffc0201092:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201094:	01066763          	bltu	a2,a6,ffffffffc02010a2 <insert_vma_struct+0x1a>
ffffffffc0201098:	a085                	j	ffffffffc02010f8 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020109a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020109e:	04e66863          	bltu	a2,a4,ffffffffc02010ee <insert_vma_struct+0x66>
ffffffffc02010a2:	86be                	mv	a3,a5
ffffffffc02010a4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list) {
ffffffffc02010a6:	fef51ae3          	bne	a0,a5,ffffffffc020109a <insert_vma_struct+0x12>
    }
    //保证插入后所有vma_struct按照区间左端点有序排列
    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02010aa:	02a68463          	beq	a3,a0,ffffffffc02010d2 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02010ae:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02010b2:	fe86b883          	ld	a7,-24(a3)
ffffffffc02010b6:	08e8f163          	bgeu	a7,a4,ffffffffc0201138 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02010ba:	04e66f63          	bltu	a2,a4,ffffffffc0201118 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02010be:	00f50a63          	beq	a0,a5,ffffffffc02010d2 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02010c2:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02010c6:	05076963          	bltu	a4,a6,ffffffffc0201118 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc02010ca:	ff07b603          	ld	a2,-16(a5)
ffffffffc02010ce:	02c77363          	bgeu	a4,a2,ffffffffc02010f4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02010d2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02010d4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02010d6:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02010da:	e390                	sd	a2,0(a5)
ffffffffc02010dc:	e690                	sd	a2,8(a3)
}
ffffffffc02010de:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02010e0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02010e2:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02010e4:	0017079b          	addiw	a5,a4,1
ffffffffc02010e8:	d11c                	sw	a5,32(a0)
}
ffffffffc02010ea:	0141                	addi	sp,sp,16
ffffffffc02010ec:	8082                	ret
    if (le_prev != list) {
ffffffffc02010ee:	fca690e3          	bne	a3,a0,ffffffffc02010ae <insert_vma_struct+0x26>
ffffffffc02010f2:	bfd1                	j	ffffffffc02010c6 <insert_vma_struct+0x3e>
ffffffffc02010f4:	ebbff0ef          	jal	ra,ffffffffc0200fae <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02010f8:	00004697          	auipc	a3,0x4
ffffffffc02010fc:	04068693          	addi	a3,a3,64 # ffffffffc0205138 <commands+0x930>
ffffffffc0201100:	00004617          	auipc	a2,0x4
ffffffffc0201104:	e5060613          	addi	a2,a2,-432 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201108:	08600593          	li	a1,134
ffffffffc020110c:	00004517          	auipc	a0,0x4
ffffffffc0201110:	01c50513          	addi	a0,a0,28 # ffffffffc0205128 <commands+0x920>
ffffffffc0201114:	feffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201118:	00004697          	auipc	a3,0x4
ffffffffc020111c:	06068693          	addi	a3,a3,96 # ffffffffc0205178 <commands+0x970>
ffffffffc0201120:	00004617          	auipc	a2,0x4
ffffffffc0201124:	e3060613          	addi	a2,a2,-464 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201128:	07e00593          	li	a1,126
ffffffffc020112c:	00004517          	auipc	a0,0x4
ffffffffc0201130:	ffc50513          	addi	a0,a0,-4 # ffffffffc0205128 <commands+0x920>
ffffffffc0201134:	fcffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201138:	00004697          	auipc	a3,0x4
ffffffffc020113c:	02068693          	addi	a3,a3,32 # ffffffffc0205158 <commands+0x950>
ffffffffc0201140:	00004617          	auipc	a2,0x4
ffffffffc0201144:	e1060613          	addi	a2,a2,-496 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201148:	07d00593          	li	a1,125
ffffffffc020114c:	00004517          	auipc	a0,0x4
ffffffffc0201150:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205128 <commands+0x920>
ffffffffc0201154:	faffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201158 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201158:	1141                	addi	sp,sp,-16
ffffffffc020115a:	e022                	sd	s0,0(sp)
ffffffffc020115c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020115e:	6508                	ld	a0,8(a0)
ffffffffc0201160:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201162:	00a40e63          	beq	s0,a0,ffffffffc020117e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201166:	6118                	ld	a4,0(a0)
ffffffffc0201168:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020116a:	03000593          	li	a1,48
ffffffffc020116e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201170:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201172:	e398                	sd	a4,0(a5)
ffffffffc0201174:	47d020ef          	jal	ra,ffffffffc0203df0 <kfree>
    return listelm->next;
ffffffffc0201178:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020117a:	fea416e3          	bne	s0,a0,ffffffffc0201166 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020117e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201180:	6402                	ld	s0,0(sp)
ffffffffc0201182:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201184:	03000593          	li	a1,48
}
ffffffffc0201188:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020118a:	4670206f          	j	ffffffffc0203df0 <kfree>

ffffffffc020118e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020118e:	715d                	addi	sp,sp,-80
ffffffffc0201190:	e486                	sd	ra,72(sp)
ffffffffc0201192:	f44e                	sd	s3,40(sp)
ffffffffc0201194:	f052                	sd	s4,32(sp)
ffffffffc0201196:	e0a2                	sd	s0,64(sp)
ffffffffc0201198:	fc26                	sd	s1,56(sp)
ffffffffc020119a:	f84a                	sd	s2,48(sp)
ffffffffc020119c:	ec56                	sd	s5,24(sp)
ffffffffc020119e:	e85a                	sd	s6,16(sp)
ffffffffc02011a0:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02011a2:	2af010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc02011a6:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02011a8:	2a9010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc02011ac:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02011ae:	03000513          	li	a0,48
ffffffffc02011b2:	385020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
    if (mm != NULL) {
ffffffffc02011b6:	56050863          	beqz	a0,ffffffffc0201726 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02011ba:	e508                	sd	a0,8(a0)
ffffffffc02011bc:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02011be:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02011c2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02011c6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc02011ca:	00010797          	auipc	a5,0x10
ffffffffc02011ce:	3667a783          	lw	a5,870(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02011d2:	84aa                	mv	s1,a0
ffffffffc02011d4:	e7b9                	bnez	a5,ffffffffc0201222 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02011d6:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02011da:	03200413          	li	s0,50
ffffffffc02011de:	a811                	j	ffffffffc02011f2 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02011e0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011e2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02011e4:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02011e8:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02011ea:	8526                	mv	a0,s1
ffffffffc02011ec:	e9dff0ef          	jal	ra,ffffffffc0201088 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02011f0:	cc05                	beqz	s0,ffffffffc0201228 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011f2:	03000513          	li	a0,48
ffffffffc02011f6:	341020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
ffffffffc02011fa:	85aa                	mv	a1,a0
ffffffffc02011fc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201200:	f165                	bnez	a0,ffffffffc02011e0 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	19668693          	addi	a3,a3,406 # ffffffffc0205398 <commands+0xb90>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	d4660613          	addi	a2,a2,-698 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201212:	0d000593          	li	a1,208
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	f1250513          	addi	a0,a0,-238 # ffffffffc0205128 <commands+0x920>
ffffffffc020121e:	ee5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0201222:	4a7000ef          	jal	ra,ffffffffc0201ec8 <swap_init_mm>
ffffffffc0201226:	bf55                	j	ffffffffc02011da <vmm_init+0x4c>
ffffffffc0201228:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020122c:	1f900913          	li	s2,505
ffffffffc0201230:	a819                	j	ffffffffc0201246 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0201232:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201234:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201236:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020123a:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020123c:	8526                	mv	a0,s1
ffffffffc020123e:	e4bff0ef          	jal	ra,ffffffffc0201088 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201242:	03240a63          	beq	s0,s2,ffffffffc0201276 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201246:	03000513          	li	a0,48
ffffffffc020124a:	2ed020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
ffffffffc020124e:	85aa                	mv	a1,a0
ffffffffc0201250:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201254:	fd79                	bnez	a0,ffffffffc0201232 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0201256:	00004697          	auipc	a3,0x4
ffffffffc020125a:	14268693          	addi	a3,a3,322 # ffffffffc0205398 <commands+0xb90>
ffffffffc020125e:	00004617          	auipc	a2,0x4
ffffffffc0201262:	cf260613          	addi	a2,a2,-782 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201266:	0d600593          	li	a1,214
ffffffffc020126a:	00004517          	auipc	a0,0x4
ffffffffc020126e:	ebe50513          	addi	a0,a0,-322 # ffffffffc0205128 <commands+0x920>
ffffffffc0201272:	e91fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0201276:	649c                	ld	a5,8(s1)
ffffffffc0201278:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020127a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020127e:	2ef48463          	beq	s1,a5,ffffffffc0201566 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201282:	fe87b603          	ld	a2,-24(a5)
ffffffffc0201286:	ffe70693          	addi	a3,a4,-2
ffffffffc020128a:	26d61e63          	bne	a2,a3,ffffffffc0201506 <vmm_init+0x378>
ffffffffc020128e:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201292:	26e69a63          	bne	a3,a4,ffffffffc0201506 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201296:	0715                	addi	a4,a4,5
ffffffffc0201298:	679c                	ld	a5,8(a5)
ffffffffc020129a:	feb712e3          	bne	a4,a1,ffffffffc020127e <vmm_init+0xf0>
ffffffffc020129e:	4b1d                	li	s6,7
ffffffffc02012a0:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012a2:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012a6:	85a2                	mv	a1,s0
ffffffffc02012a8:	8526                	mv	a0,s1
ffffffffc02012aa:	d9fff0ef          	jal	ra,ffffffffc0201048 <find_vma>
ffffffffc02012ae:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012b0:	2c050b63          	beqz	a0,ffffffffc0201586 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012b4:	00140593          	addi	a1,s0,1
ffffffffc02012b8:	8526                	mv	a0,s1
ffffffffc02012ba:	d8fff0ef          	jal	ra,ffffffffc0201048 <find_vma>
ffffffffc02012be:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02012c0:	2e050363          	beqz	a0,ffffffffc02015a6 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012c4:	85da                	mv	a1,s6
ffffffffc02012c6:	8526                	mv	a0,s1
ffffffffc02012c8:	d81ff0ef          	jal	ra,ffffffffc0201048 <find_vma>
        assert(vma3 == NULL);
ffffffffc02012cc:	2e051d63          	bnez	a0,ffffffffc02015c6 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012d0:	00340593          	addi	a1,s0,3
ffffffffc02012d4:	8526                	mv	a0,s1
ffffffffc02012d6:	d73ff0ef          	jal	ra,ffffffffc0201048 <find_vma>
        assert(vma4 == NULL);
ffffffffc02012da:	30051663          	bnez	a0,ffffffffc02015e6 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012de:	00440593          	addi	a1,s0,4
ffffffffc02012e2:	8526                	mv	a0,s1
ffffffffc02012e4:	d65ff0ef          	jal	ra,ffffffffc0201048 <find_vma>
        assert(vma5 == NULL);
ffffffffc02012e8:	30051f63          	bnez	a0,ffffffffc0201606 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02012ec:	00893783          	ld	a5,8(s2)
ffffffffc02012f0:	24879b63          	bne	a5,s0,ffffffffc0201546 <vmm_init+0x3b8>
ffffffffc02012f4:	01093783          	ld	a5,16(s2)
ffffffffc02012f8:	25679763          	bne	a5,s6,ffffffffc0201546 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02012fc:	008ab783          	ld	a5,8(s5)
ffffffffc0201300:	22879363          	bne	a5,s0,ffffffffc0201526 <vmm_init+0x398>
ffffffffc0201304:	010ab783          	ld	a5,16(s5)
ffffffffc0201308:	21679f63          	bne	a5,s6,ffffffffc0201526 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020130c:	0415                	addi	s0,s0,5
ffffffffc020130e:	0b15                	addi	s6,s6,5
ffffffffc0201310:	f9741be3          	bne	s0,s7,ffffffffc02012a6 <vmm_init+0x118>
ffffffffc0201314:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201316:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201318:	85a2                	mv	a1,s0
ffffffffc020131a:	8526                	mv	a0,s1
ffffffffc020131c:	d2dff0ef          	jal	ra,ffffffffc0201048 <find_vma>
ffffffffc0201320:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201324:	c90d                	beqz	a0,ffffffffc0201356 <vmm_init+0x1c8>
            cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201326:	6914                	ld	a3,16(a0)
ffffffffc0201328:	6510                	ld	a2,8(a0)
ffffffffc020132a:	00004517          	auipc	a0,0x4
ffffffffc020132e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205298 <commands+0xa90>
ffffffffc0201332:	d89fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201336:	00004697          	auipc	a3,0x4
ffffffffc020133a:	f8a68693          	addi	a3,a3,-118 # ffffffffc02052c0 <commands+0xab8>
ffffffffc020133e:	00004617          	auipc	a2,0x4
ffffffffc0201342:	c1260613          	addi	a2,a2,-1006 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201346:	0f800593          	li	a1,248
ffffffffc020134a:	00004517          	auipc	a0,0x4
ffffffffc020134e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205128 <commands+0x920>
ffffffffc0201352:	db1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201356:	147d                	addi	s0,s0,-1
ffffffffc0201358:	fd2410e3          	bne	s0,s2,ffffffffc0201318 <vmm_init+0x18a>
ffffffffc020135c:	a811                	j	ffffffffc0201370 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020135e:	6118                	ld	a4,0(a0)
ffffffffc0201360:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201362:	03000593          	li	a1,48
ffffffffc0201366:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201368:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020136a:	e398                	sd	a4,0(a5)
ffffffffc020136c:	285020ef          	jal	ra,ffffffffc0203df0 <kfree>
    return listelm->next;
ffffffffc0201370:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0201372:	fea496e3          	bne	s1,a0,ffffffffc020135e <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201376:	03000593          	li	a1,48
ffffffffc020137a:	8526                	mv	a0,s1
ffffffffc020137c:	275020ef          	jal	ra,ffffffffc0203df0 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201380:	0d1010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc0201384:	3caa1163          	bne	s4,a0,ffffffffc0201746 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201388:	00004517          	auipc	a0,0x4
ffffffffc020138c:	f7850513          	addi	a0,a0,-136 # ffffffffc0205300 <commands+0xaf8>
ffffffffc0201390:	d2bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201394:	0bd010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc0201398:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020139a:	03000513          	li	a0,48
ffffffffc020139e:	199020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
ffffffffc02013a2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02013a4:	2a050163          	beqz	a0,ffffffffc0201646 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc02013a8:	00010797          	auipc	a5,0x10
ffffffffc02013ac:	1887a783          	lw	a5,392(a5) # ffffffffc0211530 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc02013b0:	e508                	sd	a0,8(a0)
ffffffffc02013b2:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02013b4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02013b8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02013bc:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc02013c0:	14079063          	bnez	a5,ffffffffc0201500 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc02013c4:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013c8:	00010917          	auipc	s2,0x10
ffffffffc02013cc:	17893903          	ld	s2,376(s2) # ffffffffc0211540 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013d0:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02013d4:	00010717          	auipc	a4,0x10
ffffffffc02013d8:	12873e23          	sd	s0,316(a4) # ffffffffc0211510 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013dc:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02013e0:	24079363          	bnez	a5,ffffffffc0201626 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013e4:	03000513          	li	a0,48
ffffffffc02013e8:	14f020ef          	jal	ra,ffffffffc0203d36 <kmalloc>
ffffffffc02013ec:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02013ee:	28050063          	beqz	a0,ffffffffc020166e <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02013f2:	002007b7          	lui	a5,0x200
ffffffffc02013f6:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02013fa:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013fc:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013fe:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0201402:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0201404:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0201408:	c81ff0ef          	jal	ra,ffffffffc0201088 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020140c:	10000593          	li	a1,256
ffffffffc0201410:	8522                	mv	a0,s0
ffffffffc0201412:	c37ff0ef          	jal	ra,ffffffffc0201048 <find_vma>
ffffffffc0201416:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020141a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020141e:	26aa1863          	bne	s4,a0,ffffffffc020168e <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0201422:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0201426:	0785                	addi	a5,a5,1
ffffffffc0201428:	fee79de3          	bne	a5,a4,ffffffffc0201422 <vmm_init+0x294>
        sum += i;
ffffffffc020142c:	6705                	lui	a4,0x1
ffffffffc020142e:	10000793          	li	a5,256
ffffffffc0201432:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201436:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020143a:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020143e:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201440:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201442:	fec79ce3          	bne	a5,a2,ffffffffc020143a <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0201446:	26071463          	bnez	a4,ffffffffc02016ae <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020144a:	4581                	li	a1,0
ffffffffc020144c:	854a                	mv	a0,s2
ffffffffc020144e:	28d010ef          	jal	ra,ffffffffc0202eda <page_remove>
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0201452:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201456:	00010717          	auipc	a4,0x10
ffffffffc020145a:	0f273703          	ld	a4,242(a4) # ffffffffc0211548 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201462:	26e7f663          	bgeu	a5,a4,ffffffffc02016ce <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0201466:	00005717          	auipc	a4,0x5
ffffffffc020146a:	fd273703          	ld	a4,-46(a4) # ffffffffc0206438 <nbase>
ffffffffc020146e:	8f99                	sub	a5,a5,a4
ffffffffc0201470:	00379713          	slli	a4,a5,0x3
ffffffffc0201474:	97ba                	add	a5,a5,a4
ffffffffc0201476:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0201478:	00010517          	auipc	a0,0x10
ffffffffc020147c:	0d853503          	ld	a0,216(a0) # ffffffffc0211550 <pages>
ffffffffc0201480:	953e                	add	a0,a0,a5
ffffffffc0201482:	4585                	li	a1,1
ffffffffc0201484:	78c010ef          	jal	ra,ffffffffc0202c10 <free_pages>
    return listelm->next;
ffffffffc0201488:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc020148a:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc020148e:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201492:	00a40e63          	beq	s0,a0,ffffffffc02014ae <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201496:	6118                	ld	a4,0(a0)
ffffffffc0201498:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020149a:	03000593          	li	a1,48
ffffffffc020149e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02014a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014a2:	e398                	sd	a4,0(a5)
ffffffffc02014a4:	14d020ef          	jal	ra,ffffffffc0203df0 <kfree>
    return listelm->next;
ffffffffc02014a8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02014aa:	fea416e3          	bne	s0,a0,ffffffffc0201496 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02014ae:	03000593          	li	a1,48
ffffffffc02014b2:	8522                	mv	a0,s0
ffffffffc02014b4:	13d020ef          	jal	ra,ffffffffc0203df0 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02014b8:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc02014ba:	00010797          	auipc	a5,0x10
ffffffffc02014be:	0407bb23          	sd	zero,86(a5) # ffffffffc0211510 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014c2:	78e010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc02014c6:	22a49063          	bne	s1,a0,ffffffffc02016e6 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014ca:	00004517          	auipc	a0,0x4
ffffffffc02014ce:	e9650513          	addi	a0,a0,-362 # ffffffffc0205360 <commands+0xb58>
ffffffffc02014d2:	be9fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014d6:	77a010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02014da:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014dc:	22a99563          	bne	s3,a0,ffffffffc0201706 <vmm_init+0x578>
}
ffffffffc02014e0:	6406                	ld	s0,64(sp)
ffffffffc02014e2:	60a6                	ld	ra,72(sp)
ffffffffc02014e4:	74e2                	ld	s1,56(sp)
ffffffffc02014e6:	7942                	ld	s2,48(sp)
ffffffffc02014e8:	79a2                	ld	s3,40(sp)
ffffffffc02014ea:	7a02                	ld	s4,32(sp)
ffffffffc02014ec:	6ae2                	ld	s5,24(sp)
ffffffffc02014ee:	6b42                	ld	s6,16(sp)
ffffffffc02014f0:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014f2:	00004517          	auipc	a0,0x4
ffffffffc02014f6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205380 <commands+0xb78>
}
ffffffffc02014fa:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014fc:	bbffe06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0201500:	1c9000ef          	jal	ra,ffffffffc0201ec8 <swap_init_mm>
ffffffffc0201504:	b5d1                	j	ffffffffc02013c8 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201506:	00004697          	auipc	a3,0x4
ffffffffc020150a:	caa68693          	addi	a3,a3,-854 # ffffffffc02051b0 <commands+0x9a8>
ffffffffc020150e:	00004617          	auipc	a2,0x4
ffffffffc0201512:	a4260613          	addi	a2,a2,-1470 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201516:	0df00593          	li	a1,223
ffffffffc020151a:	00004517          	auipc	a0,0x4
ffffffffc020151e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0205128 <commands+0x920>
ffffffffc0201522:	be1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201526:	00004697          	auipc	a3,0x4
ffffffffc020152a:	d4268693          	addi	a3,a3,-702 # ffffffffc0205268 <commands+0xa60>
ffffffffc020152e:	00004617          	auipc	a2,0x4
ffffffffc0201532:	a2260613          	addi	a2,a2,-1502 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201536:	0f000593          	li	a1,240
ffffffffc020153a:	00004517          	auipc	a0,0x4
ffffffffc020153e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0205128 <commands+0x920>
ffffffffc0201542:	bc1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201546:	00004697          	auipc	a3,0x4
ffffffffc020154a:	cf268693          	addi	a3,a3,-782 # ffffffffc0205238 <commands+0xa30>
ffffffffc020154e:	00004617          	auipc	a2,0x4
ffffffffc0201552:	a0260613          	addi	a2,a2,-1534 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201556:	0ef00593          	li	a1,239
ffffffffc020155a:	00004517          	auipc	a0,0x4
ffffffffc020155e:	bce50513          	addi	a0,a0,-1074 # ffffffffc0205128 <commands+0x920>
ffffffffc0201562:	ba1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201566:	00004697          	auipc	a3,0x4
ffffffffc020156a:	c3268693          	addi	a3,a3,-974 # ffffffffc0205198 <commands+0x990>
ffffffffc020156e:	00004617          	auipc	a2,0x4
ffffffffc0201572:	9e260613          	addi	a2,a2,-1566 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201576:	0dd00593          	li	a1,221
ffffffffc020157a:	00004517          	auipc	a0,0x4
ffffffffc020157e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0205128 <commands+0x920>
ffffffffc0201582:	b81fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201586:	00004697          	auipc	a3,0x4
ffffffffc020158a:	c6268693          	addi	a3,a3,-926 # ffffffffc02051e8 <commands+0x9e0>
ffffffffc020158e:	00004617          	auipc	a2,0x4
ffffffffc0201592:	9c260613          	addi	a2,a2,-1598 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201596:	0e500593          	li	a1,229
ffffffffc020159a:	00004517          	auipc	a0,0x4
ffffffffc020159e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0205128 <commands+0x920>
ffffffffc02015a2:	b61fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02015a6:	00004697          	auipc	a3,0x4
ffffffffc02015aa:	c5268693          	addi	a3,a3,-942 # ffffffffc02051f8 <commands+0x9f0>
ffffffffc02015ae:	00004617          	auipc	a2,0x4
ffffffffc02015b2:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204f50 <commands+0x748>
ffffffffc02015b6:	0e700593          	li	a1,231
ffffffffc02015ba:	00004517          	auipc	a0,0x4
ffffffffc02015be:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205128 <commands+0x920>
ffffffffc02015c2:	b41fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02015c6:	00004697          	auipc	a3,0x4
ffffffffc02015ca:	c4268693          	addi	a3,a3,-958 # ffffffffc0205208 <commands+0xa00>
ffffffffc02015ce:	00004617          	auipc	a2,0x4
ffffffffc02015d2:	98260613          	addi	a2,a2,-1662 # ffffffffc0204f50 <commands+0x748>
ffffffffc02015d6:	0e900593          	li	a1,233
ffffffffc02015da:	00004517          	auipc	a0,0x4
ffffffffc02015de:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0205128 <commands+0x920>
ffffffffc02015e2:	b21fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02015e6:	00004697          	auipc	a3,0x4
ffffffffc02015ea:	c3268693          	addi	a3,a3,-974 # ffffffffc0205218 <commands+0xa10>
ffffffffc02015ee:	00004617          	auipc	a2,0x4
ffffffffc02015f2:	96260613          	addi	a2,a2,-1694 # ffffffffc0204f50 <commands+0x748>
ffffffffc02015f6:	0eb00593          	li	a1,235
ffffffffc02015fa:	00004517          	auipc	a0,0x4
ffffffffc02015fe:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205128 <commands+0x920>
ffffffffc0201602:	b01fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201606:	00004697          	auipc	a3,0x4
ffffffffc020160a:	c2268693          	addi	a3,a3,-990 # ffffffffc0205228 <commands+0xa20>
ffffffffc020160e:	00004617          	auipc	a2,0x4
ffffffffc0201612:	94260613          	addi	a2,a2,-1726 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201616:	0ed00593          	li	a1,237
ffffffffc020161a:	00004517          	auipc	a0,0x4
ffffffffc020161e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0205128 <commands+0x920>
ffffffffc0201622:	ae1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201626:	00004697          	auipc	a3,0x4
ffffffffc020162a:	cfa68693          	addi	a3,a3,-774 # ffffffffc0205320 <commands+0xb18>
ffffffffc020162e:	00004617          	auipc	a2,0x4
ffffffffc0201632:	92260613          	addi	a2,a2,-1758 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201636:	10f00593          	li	a1,271
ffffffffc020163a:	00004517          	auipc	a0,0x4
ffffffffc020163e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0205128 <commands+0x920>
ffffffffc0201642:	ac1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201646:	00004697          	auipc	a3,0x4
ffffffffc020164a:	d6268693          	addi	a3,a3,-670 # ffffffffc02053a8 <commands+0xba0>
ffffffffc020164e:	00004617          	auipc	a2,0x4
ffffffffc0201652:	90260613          	addi	a2,a2,-1790 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201656:	10c00593          	li	a1,268
ffffffffc020165a:	00004517          	auipc	a0,0x4
ffffffffc020165e:	ace50513          	addi	a0,a0,-1330 # ffffffffc0205128 <commands+0x920>
    check_mm_struct = mm_create();
ffffffffc0201662:	00010797          	auipc	a5,0x10
ffffffffc0201666:	ea07b723          	sd	zero,-338(a5) # ffffffffc0211510 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020166a:	a99fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc020166e:	00004697          	auipc	a3,0x4
ffffffffc0201672:	d2a68693          	addi	a3,a3,-726 # ffffffffc0205398 <commands+0xb90>
ffffffffc0201676:	00004617          	auipc	a2,0x4
ffffffffc020167a:	8da60613          	addi	a2,a2,-1830 # ffffffffc0204f50 <commands+0x748>
ffffffffc020167e:	11300593          	li	a1,275
ffffffffc0201682:	00004517          	auipc	a0,0x4
ffffffffc0201686:	aa650513          	addi	a0,a0,-1370 # ffffffffc0205128 <commands+0x920>
ffffffffc020168a:	a79fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020168e:	00004697          	auipc	a3,0x4
ffffffffc0201692:	ca268693          	addi	a3,a3,-862 # ffffffffc0205330 <commands+0xb28>
ffffffffc0201696:	00004617          	auipc	a2,0x4
ffffffffc020169a:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0204f50 <commands+0x748>
ffffffffc020169e:	11800593          	li	a1,280
ffffffffc02016a2:	00004517          	auipc	a0,0x4
ffffffffc02016a6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0205128 <commands+0x920>
ffffffffc02016aa:	a59fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02016ae:	00004697          	auipc	a3,0x4
ffffffffc02016b2:	ca268693          	addi	a3,a3,-862 # ffffffffc0205350 <commands+0xb48>
ffffffffc02016b6:	00004617          	auipc	a2,0x4
ffffffffc02016ba:	89a60613          	addi	a2,a2,-1894 # ffffffffc0204f50 <commands+0x748>
ffffffffc02016be:	12200593          	li	a1,290
ffffffffc02016c2:	00004517          	auipc	a0,0x4
ffffffffc02016c6:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205128 <commands+0x920>
ffffffffc02016ca:	a39fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016ce:	00004617          	auipc	a2,0x4
ffffffffc02016d2:	a0260613          	addi	a2,a2,-1534 # ffffffffc02050d0 <commands+0x8c8>
ffffffffc02016d6:	06500593          	li	a1,101
ffffffffc02016da:	00004517          	auipc	a0,0x4
ffffffffc02016de:	9e650513          	addi	a0,a0,-1562 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc02016e2:	a21fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016e6:	00004697          	auipc	a3,0x4
ffffffffc02016ea:	bf268693          	addi	a3,a3,-1038 # ffffffffc02052d8 <commands+0xad0>
ffffffffc02016ee:	00004617          	auipc	a2,0x4
ffffffffc02016f2:	86260613          	addi	a2,a2,-1950 # ffffffffc0204f50 <commands+0x748>
ffffffffc02016f6:	13000593          	li	a1,304
ffffffffc02016fa:	00004517          	auipc	a0,0x4
ffffffffc02016fe:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0205128 <commands+0x920>
ffffffffc0201702:	a01fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201706:	00004697          	auipc	a3,0x4
ffffffffc020170a:	bd268693          	addi	a3,a3,-1070 # ffffffffc02052d8 <commands+0xad0>
ffffffffc020170e:	00004617          	auipc	a2,0x4
ffffffffc0201712:	84260613          	addi	a2,a2,-1982 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201716:	0bf00593          	li	a1,191
ffffffffc020171a:	00004517          	auipc	a0,0x4
ffffffffc020171e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0205128 <commands+0x920>
ffffffffc0201722:	9e1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201726:	00004697          	auipc	a3,0x4
ffffffffc020172a:	c9a68693          	addi	a3,a3,-870 # ffffffffc02053c0 <commands+0xbb8>
ffffffffc020172e:	00004617          	auipc	a2,0x4
ffffffffc0201732:	82260613          	addi	a2,a2,-2014 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201736:	0c900593          	li	a1,201
ffffffffc020173a:	00004517          	auipc	a0,0x4
ffffffffc020173e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0205128 <commands+0x920>
ffffffffc0201742:	9c1fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201746:	00004697          	auipc	a3,0x4
ffffffffc020174a:	b9268693          	addi	a3,a3,-1134 # ffffffffc02052d8 <commands+0xad0>
ffffffffc020174e:	00004617          	auipc	a2,0x4
ffffffffc0201752:	80260613          	addi	a2,a2,-2046 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201756:	0fd00593          	li	a1,253
ffffffffc020175a:	00004517          	auipc	a0,0x4
ffffffffc020175e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0205128 <commands+0x920>
ffffffffc0201762:	9a1fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201766 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201766:	7179                	addi	sp,sp,-48
ffffffffc0201768:	ec26                	sd	s1,24(sp)
ffffffffc020176a:	84aa                	mv	s1,a0
    
    pte_t* temp = NULL;
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc020176c:	6d08                	ld	a0,24(a0)
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020176e:	f022                	sd	s0,32(sp)
ffffffffc0201770:	8432                	mv	s0,a2
ffffffffc0201772:	e84a                	sd	s2,16(sp)
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0201774:	4601                	li	a2,0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201776:	892e                	mv	s2,a1
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0201778:	85a2                	mv	a1,s0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020177a:	f406                	sd	ra,40(sp)
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc020177c:	50e010ef          	jal	ra,ffffffffc0202c8a <get_pte>
    if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
ffffffffc0201780:	c501                	beqz	a0,ffffffffc0201788 <do_pgfault+0x22>
ffffffffc0201782:	611c                	ld	a5,0(a0)
ffffffffc0201784:	8b8d                	andi	a5,a5,3
ffffffffc0201786:	e3cd                	bnez	a5,ffffffffc0201828 <do_pgfault+0xc2>
    }

    //addr: 访问出错的虚拟地址
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201788:	85a2                	mv	a1,s0
ffffffffc020178a:	8526                	mv	a0,s1
ffffffffc020178c:	8bdff0ef          	jal	ra,ffffffffc0201048 <find_vma>
    //在mm_struct里判断这个虚拟地址是否可用
    pgfault_num++;
ffffffffc0201790:	00010797          	auipc	a5,0x10
ffffffffc0201794:	d887a783          	lw	a5,-632(a5) # ffffffffc0211518 <pgfault_num>
ffffffffc0201798:	2785                	addiw	a5,a5,1
ffffffffc020179a:	00010717          	auipc	a4,0x10
ffffffffc020179e:	d6f72f23          	sw	a5,-642(a4) # ffffffffc0211518 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02017a2:	cd49                	beqz	a0,ffffffffc020183c <do_pgfault+0xd6>
ffffffffc02017a4:	651c                	ld	a5,8(a0)
ffffffffc02017a6:	08f46b63          	bltu	s0,a5,ffffffffc020183c <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02017aa:	6d1c                	ld	a5,24(a0)
ffffffffc02017ac:	4941                	li	s2,16
ffffffffc02017ae:	8b89                	andi	a5,a5,2
ffffffffc02017b0:	ebb1                	bnez	a5,ffffffffc0201804 <do_pgfault+0x9e>
        perm |= (PTE_R | PTE_W);
    }
    perm &= ~PTE_R;

    addr = ROUNDDOWN(addr, PGSIZE);//按照页面大小把地址对齐
ffffffffc02017b2:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02017b4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);//按照页面大小把地址对齐
ffffffffc02017b6:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02017b8:	85a2                	mv	a1,s0
ffffffffc02017ba:	4605                	li	a2,1
ffffffffc02017bc:	4ce010ef          	jal	ra,ffffffffc0202c8a <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02017c0:	610c                	ld	a1,0(a0)
ffffffffc02017c2:	c1b9                	beqz	a1,ffffffffc0201808 <do_pgfault+0xa2>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02017c4:	00010797          	auipc	a5,0x10
ffffffffc02017c8:	d6c7a783          	lw	a5,-660(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02017cc:	c3c9                	beqz	a5,ffffffffc020184e <do_pgfault+0xe8>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            swap_in(mm,addr,&page);
ffffffffc02017ce:	85a2                	mv	a1,s0
ffffffffc02017d0:	0030                	addi	a2,sp,8
ffffffffc02017d2:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02017d4:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02017d6:	01f000ef          	jal	ra,ffffffffc0201ff4 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02017da:	65a2                	ld	a1,8(sp)
ffffffffc02017dc:	6c88                	ld	a0,24(s1)
ffffffffc02017de:	86ca                	mv	a3,s2
ffffffffc02017e0:	8622                	mv	a2,s0
ffffffffc02017e2:	792010ef          	jal	ra,ffffffffc0202f74 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02017e6:	6622                	ld	a2,8(sp)
ffffffffc02017e8:	4685                	li	a3,1
ffffffffc02017ea:	85a2                	mv	a1,s0
ffffffffc02017ec:	8526                	mv	a0,s1
ffffffffc02017ee:	6e6000ef          	jal	ra,ffffffffc0201ed4 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc02017f2:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02017f4:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02017f6:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02017f8:	70a2                	ld	ra,40(sp)
ffffffffc02017fa:	7402                	ld	s0,32(sp)
ffffffffc02017fc:	64e2                	ld	s1,24(sp)
ffffffffc02017fe:	6942                	ld	s2,16(sp)
ffffffffc0201800:	6145                	addi	sp,sp,48
ffffffffc0201802:	8082                	ret
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201804:	4951                	li	s2,20
ffffffffc0201806:	b775                	j	ffffffffc02017b2 <do_pgfault+0x4c>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201808:	6c88                	ld	a0,24(s1)
ffffffffc020180a:	864a                	mv	a2,s2
ffffffffc020180c:	85a2                	mv	a1,s0
ffffffffc020180e:	470020ef          	jal	ra,ffffffffc0203c7e <pgdir_alloc_page>
ffffffffc0201812:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201814:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201816:	f3ed                	bnez	a5,ffffffffc02017f8 <do_pgfault+0x92>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201818:	00004517          	auipc	a0,0x4
ffffffffc020181c:	be850513          	addi	a0,a0,-1048 # ffffffffc0205400 <commands+0xbf8>
ffffffffc0201820:	89bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201824:	5571                	li	a0,-4
            goto failed;
ffffffffc0201826:	bfc9                	j	ffffffffc02017f8 <do_pgfault+0x92>
        return lru_pgfault(mm, error_code, addr);
ffffffffc0201828:	8622                	mv	a2,s0
}
ffffffffc020182a:	7402                	ld	s0,32(sp)
ffffffffc020182c:	70a2                	ld	ra,40(sp)
        return lru_pgfault(mm, error_code, addr);
ffffffffc020182e:	85ca                	mv	a1,s2
ffffffffc0201830:	8526                	mv	a0,s1
}
ffffffffc0201832:	6942                	ld	s2,16(sp)
ffffffffc0201834:	64e2                	ld	s1,24(sp)
ffffffffc0201836:	6145                	addi	sp,sp,48
        return lru_pgfault(mm, error_code, addr);
ffffffffc0201838:	e6aff06f          	j	ffffffffc0200ea2 <lru_pgfault>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020183c:	85a2                	mv	a1,s0
ffffffffc020183e:	00004517          	auipc	a0,0x4
ffffffffc0201842:	b9250513          	addi	a0,a0,-1134 # ffffffffc02053d0 <commands+0xbc8>
ffffffffc0201846:	875fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc020184a:	5575                	li	a0,-3
        goto failed;
ffffffffc020184c:	b775                	j	ffffffffc02017f8 <do_pgfault+0x92>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020184e:	00004517          	auipc	a0,0x4
ffffffffc0201852:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205428 <commands+0xc20>
ffffffffc0201856:	865fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc020185a:	5571                	li	a0,-4
            goto failed;
ffffffffc020185c:	bf71                	j	ffffffffc02017f8 <do_pgfault+0x92>

ffffffffc020185e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020185e:	7135                	addi	sp,sp,-160
ffffffffc0201860:	ed06                	sd	ra,152(sp)
ffffffffc0201862:	e922                	sd	s0,144(sp)
ffffffffc0201864:	e526                	sd	s1,136(sp)
ffffffffc0201866:	e14a                	sd	s2,128(sp)
ffffffffc0201868:	fcce                	sd	s3,120(sp)
ffffffffc020186a:	f8d2                	sd	s4,112(sp)
ffffffffc020186c:	f4d6                	sd	s5,104(sp)
ffffffffc020186e:	f0da                	sd	s6,96(sp)
ffffffffc0201870:	ecde                	sd	s7,88(sp)
ffffffffc0201872:	e8e2                	sd	s8,80(sp)
ffffffffc0201874:	e4e6                	sd	s9,72(sp)
ffffffffc0201876:	e0ea                	sd	s10,64(sp)
ffffffffc0201878:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020187a:	65e020ef          	jal	ra,ffffffffc0203ed8 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020187e:	00010697          	auipc	a3,0x10
ffffffffc0201882:	ca26b683          	ld	a3,-862(a3) # ffffffffc0211520 <max_swap_offset>
ffffffffc0201886:	010007b7          	lui	a5,0x1000
ffffffffc020188a:	ff968713          	addi	a4,a3,-7
ffffffffc020188e:	17e1                	addi	a5,a5,-8
ffffffffc0201890:	3ee7e063          	bltu	a5,a4,ffffffffc0201c70 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc0201894:	00008797          	auipc	a5,0x8
ffffffffc0201898:	76c78793          	addi	a5,a5,1900 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc020189c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc020189e:	00010b17          	auipc	s6,0x10
ffffffffc02018a2:	c8ab0b13          	addi	s6,s6,-886 # ffffffffc0211528 <sm>
ffffffffc02018a6:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02018aa:	9702                	jalr	a4
ffffffffc02018ac:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02018ae:	c10d                	beqz	a0,ffffffffc02018d0 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02018b0:	60ea                	ld	ra,152(sp)
ffffffffc02018b2:	644a                	ld	s0,144(sp)
ffffffffc02018b4:	64aa                	ld	s1,136(sp)
ffffffffc02018b6:	690a                	ld	s2,128(sp)
ffffffffc02018b8:	7a46                	ld	s4,112(sp)
ffffffffc02018ba:	7aa6                	ld	s5,104(sp)
ffffffffc02018bc:	7b06                	ld	s6,96(sp)
ffffffffc02018be:	6be6                	ld	s7,88(sp)
ffffffffc02018c0:	6c46                	ld	s8,80(sp)
ffffffffc02018c2:	6ca6                	ld	s9,72(sp)
ffffffffc02018c4:	6d06                	ld	s10,64(sp)
ffffffffc02018c6:	7de2                	ld	s11,56(sp)
ffffffffc02018c8:	854e                	mv	a0,s3
ffffffffc02018ca:	79e6                	ld	s3,120(sp)
ffffffffc02018cc:	610d                	addi	sp,sp,160
ffffffffc02018ce:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02018d0:	000b3783          	ld	a5,0(s6)
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	bac50513          	addi	a0,a0,-1108 # ffffffffc0205480 <commands+0xc78>
ffffffffc02018dc:	0000f497          	auipc	s1,0xf
ffffffffc02018e0:	7f448493          	addi	s1,s1,2036 # ffffffffc02110d0 <free_area>
ffffffffc02018e4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02018e6:	4785                	li	a5,1
ffffffffc02018e8:	00010717          	auipc	a4,0x10
ffffffffc02018ec:	c4f72423          	sw	a5,-952(a4) # ffffffffc0211530 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02018f0:	fcafe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02018f4:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02018f6:	4401                	li	s0,0
ffffffffc02018f8:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02018fa:	2c978163          	beq	a5,s1,ffffffffc0201bbc <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018fe:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201902:	8b09                	andi	a4,a4,2
ffffffffc0201904:	2a070e63          	beqz	a4,ffffffffc0201bc0 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0201908:	ff87a703          	lw	a4,-8(a5)
ffffffffc020190c:	679c                	ld	a5,8(a5)
ffffffffc020190e:	2d05                	addiw	s10,s10,1
ffffffffc0201910:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201912:	fe9796e3          	bne	a5,s1,ffffffffc02018fe <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201916:	8922                	mv	s2,s0
ffffffffc0201918:	338010ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc020191c:	47251663          	bne	a0,s2,ffffffffc0201d88 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201920:	8622                	mv	a2,s0
ffffffffc0201922:	85ea                	mv	a1,s10
ffffffffc0201924:	00004517          	auipc	a0,0x4
ffffffffc0201928:	ba450513          	addi	a0,a0,-1116 # ffffffffc02054c8 <commands+0xcc0>
ffffffffc020192c:	f8efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201930:	ea2ff0ef          	jal	ra,ffffffffc0200fd2 <mm_create>
ffffffffc0201934:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201936:	52050963          	beqz	a0,ffffffffc0201e68 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020193a:	00010797          	auipc	a5,0x10
ffffffffc020193e:	bd678793          	addi	a5,a5,-1066 # ffffffffc0211510 <check_mm_struct>
ffffffffc0201942:	6398                	ld	a4,0(a5)
ffffffffc0201944:	54071263          	bnez	a4,ffffffffc0201e88 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201948:	00010b97          	auipc	s7,0x10
ffffffffc020194c:	bf8bbb83          	ld	s7,-1032(s7) # ffffffffc0211540 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201950:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0201954:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201956:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020195a:	3c071763          	bnez	a4,ffffffffc0201d28 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020195e:	6599                	lui	a1,0x6
ffffffffc0201960:	460d                	li	a2,3
ffffffffc0201962:	6505                	lui	a0,0x1
ffffffffc0201964:	eb6ff0ef          	jal	ra,ffffffffc020101a <vma_create>
ffffffffc0201968:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020196a:	3c050f63          	beqz	a0,ffffffffc0201d48 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc020196e:	8556                	mv	a0,s5
ffffffffc0201970:	f18ff0ef          	jal	ra,ffffffffc0201088 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201974:	00004517          	auipc	a0,0x4
ffffffffc0201978:	b9450513          	addi	a0,a0,-1132 # ffffffffc0205508 <commands+0xd00>
ffffffffc020197c:	f3efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201980:	018ab503          	ld	a0,24(s5)
ffffffffc0201984:	4605                	li	a2,1
ffffffffc0201986:	6585                	lui	a1,0x1
ffffffffc0201988:	302010ef          	jal	ra,ffffffffc0202c8a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020198c:	3c050e63          	beqz	a0,ffffffffc0201d68 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201990:	00004517          	auipc	a0,0x4
ffffffffc0201994:	bc850513          	addi	a0,a0,-1080 # ffffffffc0205558 <commands+0xd50>
ffffffffc0201998:	0000f917          	auipc	s2,0xf
ffffffffc020199c:	6c890913          	addi	s2,s2,1736 # ffffffffc0211060 <check_rp>
ffffffffc02019a0:	f1afe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019a4:	0000fa17          	auipc	s4,0xf
ffffffffc02019a8:	6dca0a13          	addi	s4,s4,1756 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02019ac:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc02019ae:	4505                	li	a0,1
ffffffffc02019b0:	1ce010ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02019b4:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02019b8:	28050c63          	beqz	a0,ffffffffc0201c50 <swap_init+0x3f2>
ffffffffc02019bc:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02019be:	8b89                	andi	a5,a5,2
ffffffffc02019c0:	26079863          	bnez	a5,ffffffffc0201c30 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019c4:	0c21                	addi	s8,s8,8
ffffffffc02019c6:	ff4c14e3          	bne	s8,s4,ffffffffc02019ae <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02019ca:	609c                	ld	a5,0(s1)
ffffffffc02019cc:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02019d0:	e084                	sd	s1,0(s1)
ffffffffc02019d2:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02019d4:	489c                	lw	a5,16(s1)
ffffffffc02019d6:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02019d8:	0000fc17          	auipc	s8,0xf
ffffffffc02019dc:	688c0c13          	addi	s8,s8,1672 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02019e0:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02019e2:	0000f797          	auipc	a5,0xf
ffffffffc02019e6:	6e07af23          	sw	zero,1790(a5) # ffffffffc02110e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02019ea:	000c3503          	ld	a0,0(s8)
ffffffffc02019ee:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019f0:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02019f2:	21e010ef          	jal	ra,ffffffffc0202c10 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019f6:	ff4c1ae3          	bne	s8,s4,ffffffffc02019ea <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019fa:	0104ac03          	lw	s8,16(s1)
ffffffffc02019fe:	4791                	li	a5,4
ffffffffc0201a00:	4afc1463          	bne	s8,a5,ffffffffc0201ea8 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201a04:	00004517          	auipc	a0,0x4
ffffffffc0201a08:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02055e0 <commands+0xdd8>
ffffffffc0201a0c:	eaefe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a10:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201a12:	00010797          	auipc	a5,0x10
ffffffffc0201a16:	b007a323          	sw	zero,-1274(a5) # ffffffffc0211518 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a1a:	4529                	li	a0,10
ffffffffc0201a1c:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201a20:	00010597          	auipc	a1,0x10
ffffffffc0201a24:	af85a583          	lw	a1,-1288(a1) # ffffffffc0211518 <pgfault_num>
ffffffffc0201a28:	4805                	li	a6,1
ffffffffc0201a2a:	00010797          	auipc	a5,0x10
ffffffffc0201a2e:	aee78793          	addi	a5,a5,-1298 # ffffffffc0211518 <pgfault_num>
ffffffffc0201a32:	3f059b63          	bne	a1,a6,ffffffffc0201e28 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201a36:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201a3a:	4390                	lw	a2,0(a5)
ffffffffc0201a3c:	2601                	sext.w	a2,a2
ffffffffc0201a3e:	40b61563          	bne	a2,a1,ffffffffc0201e48 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a42:	6589                	lui	a1,0x2
ffffffffc0201a44:	452d                	li	a0,11
ffffffffc0201a46:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201a4a:	4390                	lw	a2,0(a5)
ffffffffc0201a4c:	4809                	li	a6,2
ffffffffc0201a4e:	2601                	sext.w	a2,a2
ffffffffc0201a50:	35061c63          	bne	a2,a6,ffffffffc0201da8 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201a54:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201a58:	438c                	lw	a1,0(a5)
ffffffffc0201a5a:	2581                	sext.w	a1,a1
ffffffffc0201a5c:	36c59663          	bne	a1,a2,ffffffffc0201dc8 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201a60:	658d                	lui	a1,0x3
ffffffffc0201a62:	4531                	li	a0,12
ffffffffc0201a64:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201a68:	4390                	lw	a2,0(a5)
ffffffffc0201a6a:	480d                	li	a6,3
ffffffffc0201a6c:	2601                	sext.w	a2,a2
ffffffffc0201a6e:	37061d63          	bne	a2,a6,ffffffffc0201de8 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201a72:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0201a76:	438c                	lw	a1,0(a5)
ffffffffc0201a78:	2581                	sext.w	a1,a1
ffffffffc0201a7a:	38c59763          	bne	a1,a2,ffffffffc0201e08 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a7e:	6591                	lui	a1,0x4
ffffffffc0201a80:	4535                	li	a0,13
ffffffffc0201a82:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201a86:	4390                	lw	a2,0(a5)
ffffffffc0201a88:	2601                	sext.w	a2,a2
ffffffffc0201a8a:	21861f63          	bne	a2,s8,ffffffffc0201ca8 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201a8e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0201a92:	439c                	lw	a5,0(a5)
ffffffffc0201a94:	2781                	sext.w	a5,a5
ffffffffc0201a96:	22c79963          	bne	a5,a2,ffffffffc0201cc8 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201a9a:	489c                	lw	a5,16(s1)
ffffffffc0201a9c:	24079663          	bnez	a5,ffffffffc0201ce8 <swap_init+0x48a>
ffffffffc0201aa0:	0000f797          	auipc	a5,0xf
ffffffffc0201aa4:	5e078793          	addi	a5,a5,1504 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc0201aa8:	0000f617          	auipc	a2,0xf
ffffffffc0201aac:	60060613          	addi	a2,a2,1536 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc0201ab0:	0000f517          	auipc	a0,0xf
ffffffffc0201ab4:	5f850513          	addi	a0,a0,1528 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201ab8:	55fd                	li	a1,-1
ffffffffc0201aba:	c38c                	sw	a1,0(a5)
ffffffffc0201abc:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201abe:	0791                	addi	a5,a5,4
ffffffffc0201ac0:	0611                	addi	a2,a2,4
ffffffffc0201ac2:	fef51ce3          	bne	a0,a5,ffffffffc0201aba <swap_init+0x25c>
ffffffffc0201ac6:	0000f817          	auipc	a6,0xf
ffffffffc0201aca:	57a80813          	addi	a6,a6,1402 # ffffffffc0211040 <check_ptep>
ffffffffc0201ace:	0000f897          	auipc	a7,0xf
ffffffffc0201ad2:	59288893          	addi	a7,a7,1426 # ffffffffc0211060 <check_rp>
ffffffffc0201ad6:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0201ad8:	00010c97          	auipc	s9,0x10
ffffffffc0201adc:	a78c8c93          	addi	s9,s9,-1416 # ffffffffc0211550 <pages>
ffffffffc0201ae0:	00005c17          	auipc	s8,0x5
ffffffffc0201ae4:	958c0c13          	addi	s8,s8,-1704 # ffffffffc0206438 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201ae8:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201aec:	4601                	li	a2,0
ffffffffc0201aee:	855e                	mv	a0,s7
ffffffffc0201af0:	ec46                	sd	a7,24(sp)
ffffffffc0201af2:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0201af4:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201af6:	194010ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc0201afa:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201afc:	65c2                	ld	a1,16(sp)
ffffffffc0201afe:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201b00:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0201b04:	00010317          	auipc	t1,0x10
ffffffffc0201b08:	a4430313          	addi	t1,t1,-1468 # ffffffffc0211548 <npage>
ffffffffc0201b0c:	16050e63          	beqz	a0,ffffffffc0201c88 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201b10:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201b12:	0017f613          	andi	a2,a5,1
ffffffffc0201b16:	0e060563          	beqz	a2,ffffffffc0201c00 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0201b1a:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b1e:	078a                	slli	a5,a5,0x2
ffffffffc0201b20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b22:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201c18 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b26:	000c3603          	ld	a2,0(s8)
ffffffffc0201b2a:	000cb503          	ld	a0,0(s9)
ffffffffc0201b2e:	0008bf03          	ld	t5,0(a7)
ffffffffc0201b32:	8f91                	sub	a5,a5,a2
ffffffffc0201b34:	00379613          	slli	a2,a5,0x3
ffffffffc0201b38:	97b2                	add	a5,a5,a2
ffffffffc0201b3a:	078e                	slli	a5,a5,0x3
ffffffffc0201b3c:	97aa                	add	a5,a5,a0
ffffffffc0201b3e:	0aff1163          	bne	t5,a5,ffffffffc0201be0 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b42:	6785                	lui	a5,0x1
ffffffffc0201b44:	95be                	add	a1,a1,a5
ffffffffc0201b46:	6795                	lui	a5,0x5
ffffffffc0201b48:	0821                	addi	a6,a6,8
ffffffffc0201b4a:	08a1                	addi	a7,a7,8
ffffffffc0201b4c:	f8f59ee3          	bne	a1,a5,ffffffffc0201ae8 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201b50:	00004517          	auipc	a0,0x4
ffffffffc0201b54:	b4850513          	addi	a0,a0,-1208 # ffffffffc0205698 <commands+0xe90>
ffffffffc0201b58:	d62fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201b5c:	000b3783          	ld	a5,0(s6)
ffffffffc0201b60:	7f9c                	ld	a5,56(a5)
ffffffffc0201b62:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201b64:	1a051263          	bnez	a0,ffffffffc0201d08 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201b68:	00093503          	ld	a0,0(s2)
ffffffffc0201b6c:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b6e:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201b70:	0a0010ef          	jal	ra,ffffffffc0202c10 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b74:	ff491ae3          	bne	s2,s4,ffffffffc0201b68 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201b78:	8556                	mv	a0,s5
ffffffffc0201b7a:	ddeff0ef          	jal	ra,ffffffffc0201158 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201b7e:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201b80:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0201b84:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0201b86:	7782                	ld	a5,32(sp)
ffffffffc0201b88:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201b8a:	009d8a63          	beq	s11,s1,ffffffffc0201b9e <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201b8e:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0201b92:	008dbd83          	ld	s11,8(s11)
ffffffffc0201b96:	3d7d                	addiw	s10,s10,-1
ffffffffc0201b98:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201b9a:	fe9d9ae3          	bne	s11,s1,ffffffffc0201b8e <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201b9e:	8622                	mv	a2,s0
ffffffffc0201ba0:	85ea                	mv	a1,s10
ffffffffc0201ba2:	00004517          	auipc	a0,0x4
ffffffffc0201ba6:	b2650513          	addi	a0,a0,-1242 # ffffffffc02056c8 <commands+0xec0>
ffffffffc0201baa:	d10fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201bae:	00004517          	auipc	a0,0x4
ffffffffc0201bb2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02056e8 <commands+0xee0>
ffffffffc0201bb6:	d04fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201bba:	b9dd                	j	ffffffffc02018b0 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201bbc:	4901                	li	s2,0
ffffffffc0201bbe:	bba9                	j	ffffffffc0201918 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201bc0:	00004697          	auipc	a3,0x4
ffffffffc0201bc4:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205498 <commands+0xc90>
ffffffffc0201bc8:	00003617          	auipc	a2,0x3
ffffffffc0201bcc:	38860613          	addi	a2,a2,904 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201bd0:	0bb00593          	li	a1,187
ffffffffc0201bd4:	00004517          	auipc	a0,0x4
ffffffffc0201bd8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201bdc:	d26fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201be0:	00004697          	auipc	a3,0x4
ffffffffc0201be4:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205670 <commands+0xe68>
ffffffffc0201be8:	00003617          	auipc	a2,0x3
ffffffffc0201bec:	36860613          	addi	a2,a2,872 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201bf0:	0fb00593          	li	a1,251
ffffffffc0201bf4:	00004517          	auipc	a0,0x4
ffffffffc0201bf8:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201bfc:	d06fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201c00:	00003617          	auipc	a2,0x3
ffffffffc0201c04:	49860613          	addi	a2,a2,1176 # ffffffffc0205098 <commands+0x890>
ffffffffc0201c08:	07000593          	li	a1,112
ffffffffc0201c0c:	00003517          	auipc	a0,0x3
ffffffffc0201c10:	4b450513          	addi	a0,a0,1204 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0201c14:	ceefe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201c18:	00003617          	auipc	a2,0x3
ffffffffc0201c1c:	4b860613          	addi	a2,a2,1208 # ffffffffc02050d0 <commands+0x8c8>
ffffffffc0201c20:	06500593          	li	a1,101
ffffffffc0201c24:	00003517          	auipc	a0,0x3
ffffffffc0201c28:	49c50513          	addi	a0,a0,1180 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0201c2c:	cd6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201c30:	00004697          	auipc	a3,0x4
ffffffffc0201c34:	96868693          	addi	a3,a3,-1688 # ffffffffc0205598 <commands+0xd90>
ffffffffc0201c38:	00003617          	auipc	a2,0x3
ffffffffc0201c3c:	31860613          	addi	a2,a2,792 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201c40:	0dc00593          	li	a1,220
ffffffffc0201c44:	00004517          	auipc	a0,0x4
ffffffffc0201c48:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201c4c:	cb6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201c50:	00004697          	auipc	a3,0x4
ffffffffc0201c54:	93068693          	addi	a3,a3,-1744 # ffffffffc0205580 <commands+0xd78>
ffffffffc0201c58:	00003617          	auipc	a2,0x3
ffffffffc0201c5c:	2f860613          	addi	a2,a2,760 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201c60:	0db00593          	li	a1,219
ffffffffc0201c64:	00004517          	auipc	a0,0x4
ffffffffc0201c68:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201c6c:	c96fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201c70:	00003617          	auipc	a2,0x3
ffffffffc0201c74:	7e060613          	addi	a2,a2,2016 # ffffffffc0205450 <commands+0xc48>
ffffffffc0201c78:	02800593          	li	a1,40
ffffffffc0201c7c:	00003517          	auipc	a0,0x3
ffffffffc0201c80:	7f450513          	addi	a0,a0,2036 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201c84:	c7efe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201c88:	00004697          	auipc	a3,0x4
ffffffffc0201c8c:	9d068693          	addi	a3,a3,-1584 # ffffffffc0205658 <commands+0xe50>
ffffffffc0201c90:	00003617          	auipc	a2,0x3
ffffffffc0201c94:	2c060613          	addi	a2,a2,704 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201c98:	0fa00593          	li	a1,250
ffffffffc0201c9c:	00003517          	auipc	a0,0x3
ffffffffc0201ca0:	7d450513          	addi	a0,a0,2004 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201ca4:	c5efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201ca8:	00004697          	auipc	a3,0x4
ffffffffc0201cac:	99068693          	addi	a3,a3,-1648 # ffffffffc0205638 <commands+0xe30>
ffffffffc0201cb0:	00003617          	auipc	a2,0x3
ffffffffc0201cb4:	2a060613          	addi	a2,a2,672 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201cb8:	09e00593          	li	a1,158
ffffffffc0201cbc:	00003517          	auipc	a0,0x3
ffffffffc0201cc0:	7b450513          	addi	a0,a0,1972 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201cc4:	c3efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201cc8:	00004697          	auipc	a3,0x4
ffffffffc0201ccc:	97068693          	addi	a3,a3,-1680 # ffffffffc0205638 <commands+0xe30>
ffffffffc0201cd0:	00003617          	auipc	a2,0x3
ffffffffc0201cd4:	28060613          	addi	a2,a2,640 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201cd8:	0a000593          	li	a1,160
ffffffffc0201cdc:	00003517          	auipc	a0,0x3
ffffffffc0201ce0:	79450513          	addi	a0,a0,1940 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201ce4:	c1efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0201ce8:	00004697          	auipc	a3,0x4
ffffffffc0201cec:	96068693          	addi	a3,a3,-1696 # ffffffffc0205648 <commands+0xe40>
ffffffffc0201cf0:	00003617          	auipc	a2,0x3
ffffffffc0201cf4:	26060613          	addi	a2,a2,608 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201cf8:	0f200593          	li	a1,242
ffffffffc0201cfc:	00003517          	auipc	a0,0x3
ffffffffc0201d00:	77450513          	addi	a0,a0,1908 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201d04:	bfefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201d08:	00004697          	auipc	a3,0x4
ffffffffc0201d0c:	9b868693          	addi	a3,a3,-1608 # ffffffffc02056c0 <commands+0xeb8>
ffffffffc0201d10:	00003617          	auipc	a2,0x3
ffffffffc0201d14:	24060613          	addi	a2,a2,576 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201d18:	10100593          	li	a1,257
ffffffffc0201d1c:	00003517          	auipc	a0,0x3
ffffffffc0201d20:	75450513          	addi	a0,a0,1876 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201d24:	bdefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201d28:	00003697          	auipc	a3,0x3
ffffffffc0201d2c:	5f868693          	addi	a3,a3,1528 # ffffffffc0205320 <commands+0xb18>
ffffffffc0201d30:	00003617          	auipc	a2,0x3
ffffffffc0201d34:	22060613          	addi	a2,a2,544 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201d38:	0cb00593          	li	a1,203
ffffffffc0201d3c:	00003517          	auipc	a0,0x3
ffffffffc0201d40:	73450513          	addi	a0,a0,1844 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201d44:	bbefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201d48:	00003697          	auipc	a3,0x3
ffffffffc0201d4c:	65068693          	addi	a3,a3,1616 # ffffffffc0205398 <commands+0xb90>
ffffffffc0201d50:	00003617          	auipc	a2,0x3
ffffffffc0201d54:	20060613          	addi	a2,a2,512 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201d58:	0ce00593          	li	a1,206
ffffffffc0201d5c:	00003517          	auipc	a0,0x3
ffffffffc0201d60:	71450513          	addi	a0,a0,1812 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201d64:	b9efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201d68:	00003697          	auipc	a3,0x3
ffffffffc0201d6c:	7d868693          	addi	a3,a3,2008 # ffffffffc0205540 <commands+0xd38>
ffffffffc0201d70:	00003617          	auipc	a2,0x3
ffffffffc0201d74:	1e060613          	addi	a2,a2,480 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201d78:	0d600593          	li	a1,214
ffffffffc0201d7c:	00003517          	auipc	a0,0x3
ffffffffc0201d80:	6f450513          	addi	a0,a0,1780 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201d84:	b7efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201d88:	00003697          	auipc	a3,0x3
ffffffffc0201d8c:	72068693          	addi	a3,a3,1824 # ffffffffc02054a8 <commands+0xca0>
ffffffffc0201d90:	00003617          	auipc	a2,0x3
ffffffffc0201d94:	1c060613          	addi	a2,a2,448 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201d98:	0be00593          	li	a1,190
ffffffffc0201d9c:	00003517          	auipc	a0,0x3
ffffffffc0201da0:	6d450513          	addi	a0,a0,1748 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201da4:	b5efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201da8:	00004697          	auipc	a3,0x4
ffffffffc0201dac:	87068693          	addi	a3,a3,-1936 # ffffffffc0205618 <commands+0xe10>
ffffffffc0201db0:	00003617          	auipc	a2,0x3
ffffffffc0201db4:	1a060613          	addi	a2,a2,416 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201db8:	09600593          	li	a1,150
ffffffffc0201dbc:	00003517          	auipc	a0,0x3
ffffffffc0201dc0:	6b450513          	addi	a0,a0,1716 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201dc4:	b3efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201dc8:	00004697          	auipc	a3,0x4
ffffffffc0201dcc:	85068693          	addi	a3,a3,-1968 # ffffffffc0205618 <commands+0xe10>
ffffffffc0201dd0:	00003617          	auipc	a2,0x3
ffffffffc0201dd4:	18060613          	addi	a2,a2,384 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201dd8:	09800593          	li	a1,152
ffffffffc0201ddc:	00003517          	auipc	a0,0x3
ffffffffc0201de0:	69450513          	addi	a0,a0,1684 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201de4:	b1efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201de8:	00004697          	auipc	a3,0x4
ffffffffc0201dec:	84068693          	addi	a3,a3,-1984 # ffffffffc0205628 <commands+0xe20>
ffffffffc0201df0:	00003617          	auipc	a2,0x3
ffffffffc0201df4:	16060613          	addi	a2,a2,352 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201df8:	09a00593          	li	a1,154
ffffffffc0201dfc:	00003517          	auipc	a0,0x3
ffffffffc0201e00:	67450513          	addi	a0,a0,1652 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201e04:	afefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201e08:	00004697          	auipc	a3,0x4
ffffffffc0201e0c:	82068693          	addi	a3,a3,-2016 # ffffffffc0205628 <commands+0xe20>
ffffffffc0201e10:	00003617          	auipc	a2,0x3
ffffffffc0201e14:	14060613          	addi	a2,a2,320 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201e18:	09c00593          	li	a1,156
ffffffffc0201e1c:	00003517          	auipc	a0,0x3
ffffffffc0201e20:	65450513          	addi	a0,a0,1620 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201e24:	adefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e28:	00003697          	auipc	a3,0x3
ffffffffc0201e2c:	7e068693          	addi	a3,a3,2016 # ffffffffc0205608 <commands+0xe00>
ffffffffc0201e30:	00003617          	auipc	a2,0x3
ffffffffc0201e34:	12060613          	addi	a2,a2,288 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201e38:	09200593          	li	a1,146
ffffffffc0201e3c:	00003517          	auipc	a0,0x3
ffffffffc0201e40:	63450513          	addi	a0,a0,1588 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201e44:	abefe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e48:	00003697          	auipc	a3,0x3
ffffffffc0201e4c:	7c068693          	addi	a3,a3,1984 # ffffffffc0205608 <commands+0xe00>
ffffffffc0201e50:	00003617          	auipc	a2,0x3
ffffffffc0201e54:	10060613          	addi	a2,a2,256 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201e58:	09400593          	li	a1,148
ffffffffc0201e5c:	00003517          	auipc	a0,0x3
ffffffffc0201e60:	61450513          	addi	a0,a0,1556 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201e64:	a9efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201e68:	00003697          	auipc	a3,0x3
ffffffffc0201e6c:	55868693          	addi	a3,a3,1368 # ffffffffc02053c0 <commands+0xbb8>
ffffffffc0201e70:	00003617          	auipc	a2,0x3
ffffffffc0201e74:	0e060613          	addi	a2,a2,224 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201e78:	0c300593          	li	a1,195
ffffffffc0201e7c:	00003517          	auipc	a0,0x3
ffffffffc0201e80:	5f450513          	addi	a0,a0,1524 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201e84:	a7efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201e88:	00003697          	auipc	a3,0x3
ffffffffc0201e8c:	66868693          	addi	a3,a3,1640 # ffffffffc02054f0 <commands+0xce8>
ffffffffc0201e90:	00003617          	auipc	a2,0x3
ffffffffc0201e94:	0c060613          	addi	a2,a2,192 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201e98:	0c600593          	li	a1,198
ffffffffc0201e9c:	00003517          	auipc	a0,0x3
ffffffffc0201ea0:	5d450513          	addi	a0,a0,1492 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201ea4:	a5efe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201ea8:	00003697          	auipc	a3,0x3
ffffffffc0201eac:	71068693          	addi	a3,a3,1808 # ffffffffc02055b8 <commands+0xdb0>
ffffffffc0201eb0:	00003617          	auipc	a2,0x3
ffffffffc0201eb4:	0a060613          	addi	a2,a2,160 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201eb8:	0e900593          	li	a1,233
ffffffffc0201ebc:	00003517          	auipc	a0,0x3
ffffffffc0201ec0:	5b450513          	addi	a0,a0,1460 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201ec4:	a3efe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201ec8 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201ec8:	0000f797          	auipc	a5,0xf
ffffffffc0201ecc:	6607b783          	ld	a5,1632(a5) # ffffffffc0211528 <sm>
ffffffffc0201ed0:	6b9c                	ld	a5,16(a5)
ffffffffc0201ed2:	8782                	jr	a5

ffffffffc0201ed4 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201ed4:	0000f797          	auipc	a5,0xf
ffffffffc0201ed8:	6547b783          	ld	a5,1620(a5) # ffffffffc0211528 <sm>
ffffffffc0201edc:	739c                	ld	a5,32(a5)
ffffffffc0201ede:	8782                	jr	a5

ffffffffc0201ee0 <swap_out>:
{
ffffffffc0201ee0:	711d                	addi	sp,sp,-96
ffffffffc0201ee2:	ec86                	sd	ra,88(sp)
ffffffffc0201ee4:	e8a2                	sd	s0,80(sp)
ffffffffc0201ee6:	e4a6                	sd	s1,72(sp)
ffffffffc0201ee8:	e0ca                	sd	s2,64(sp)
ffffffffc0201eea:	fc4e                	sd	s3,56(sp)
ffffffffc0201eec:	f852                	sd	s4,48(sp)
ffffffffc0201eee:	f456                	sd	s5,40(sp)
ffffffffc0201ef0:	f05a                	sd	s6,32(sp)
ffffffffc0201ef2:	ec5e                	sd	s7,24(sp)
ffffffffc0201ef4:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201ef6:	cde9                	beqz	a1,ffffffffc0201fd0 <swap_out+0xf0>
ffffffffc0201ef8:	8a2e                	mv	s4,a1
ffffffffc0201efa:	892a                	mv	s2,a0
ffffffffc0201efc:	8ab2                	mv	s5,a2
ffffffffc0201efe:	4401                	li	s0,0
ffffffffc0201f00:	0000f997          	auipc	s3,0xf
ffffffffc0201f04:	62898993          	addi	s3,s3,1576 # ffffffffc0211528 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201f08:	00004b17          	auipc	s6,0x4
ffffffffc0201f0c:	860b0b13          	addi	s6,s6,-1952 # ffffffffc0205768 <commands+0xf60>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201f10:	00004b97          	auipc	s7,0x4
ffffffffc0201f14:	840b8b93          	addi	s7,s7,-1984 # ffffffffc0205750 <commands+0xf48>
ffffffffc0201f18:	a825                	j	ffffffffc0201f50 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201f1a:	67a2                	ld	a5,8(sp)
ffffffffc0201f1c:	8626                	mv	a2,s1
ffffffffc0201f1e:	85a2                	mv	a1,s0
ffffffffc0201f20:	63b4                	ld	a3,64(a5)
ffffffffc0201f22:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201f24:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201f26:	82b1                	srli	a3,a3,0xc
ffffffffc0201f28:	0685                	addi	a3,a3,1
ffffffffc0201f2a:	990fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201f2e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201f30:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201f32:	613c                	ld	a5,64(a0)
ffffffffc0201f34:	83b1                	srli	a5,a5,0xc
ffffffffc0201f36:	0785                	addi	a5,a5,1
ffffffffc0201f38:	07a2                	slli	a5,a5,0x8
ffffffffc0201f3a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201f3e:	4d3000ef          	jal	ra,ffffffffc0202c10 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201f42:	01893503          	ld	a0,24(s2)
ffffffffc0201f46:	85a6                	mv	a1,s1
ffffffffc0201f48:	531010ef          	jal	ra,ffffffffc0203c78 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201f4c:	048a0d63          	beq	s4,s0,ffffffffc0201fa6 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201f50:	0009b783          	ld	a5,0(s3)
ffffffffc0201f54:	8656                	mv	a2,s5
ffffffffc0201f56:	002c                	addi	a1,sp,8
ffffffffc0201f58:	7b9c                	ld	a5,48(a5)
ffffffffc0201f5a:	854a                	mv	a0,s2
ffffffffc0201f5c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201f5e:	e12d                	bnez	a0,ffffffffc0201fc0 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201f60:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f62:	01893503          	ld	a0,24(s2)
ffffffffc0201f66:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201f68:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f6a:	85a6                	mv	a1,s1
ffffffffc0201f6c:	51f000ef          	jal	ra,ffffffffc0202c8a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201f70:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f72:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201f74:	8b85                	andi	a5,a5,1
ffffffffc0201f76:	cfb9                	beqz	a5,ffffffffc0201fd4 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201f78:	65a2                	ld	a1,8(sp)
ffffffffc0201f7a:	61bc                	ld	a5,64(a1)
ffffffffc0201f7c:	83b1                	srli	a5,a5,0xc
ffffffffc0201f7e:	0785                	addi	a5,a5,1
ffffffffc0201f80:	00879513          	slli	a0,a5,0x8
ffffffffc0201f84:	026020ef          	jal	ra,ffffffffc0203faa <swapfs_write>
ffffffffc0201f88:	d949                	beqz	a0,ffffffffc0201f1a <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201f8a:	855e                	mv	a0,s7
ffffffffc0201f8c:	92efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201f90:	0009b783          	ld	a5,0(s3)
ffffffffc0201f94:	6622                	ld	a2,8(sp)
ffffffffc0201f96:	4681                	li	a3,0
ffffffffc0201f98:	739c                	ld	a5,32(a5)
ffffffffc0201f9a:	85a6                	mv	a1,s1
ffffffffc0201f9c:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201f9e:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201fa0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201fa2:	fa8a17e3          	bne	s4,s0,ffffffffc0201f50 <swap_out+0x70>
}
ffffffffc0201fa6:	60e6                	ld	ra,88(sp)
ffffffffc0201fa8:	8522                	mv	a0,s0
ffffffffc0201faa:	6446                	ld	s0,80(sp)
ffffffffc0201fac:	64a6                	ld	s1,72(sp)
ffffffffc0201fae:	6906                	ld	s2,64(sp)
ffffffffc0201fb0:	79e2                	ld	s3,56(sp)
ffffffffc0201fb2:	7a42                	ld	s4,48(sp)
ffffffffc0201fb4:	7aa2                	ld	s5,40(sp)
ffffffffc0201fb6:	7b02                	ld	s6,32(sp)
ffffffffc0201fb8:	6be2                	ld	s7,24(sp)
ffffffffc0201fba:	6c42                	ld	s8,16(sp)
ffffffffc0201fbc:	6125                	addi	sp,sp,96
ffffffffc0201fbe:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201fc0:	85a2                	mv	a1,s0
ffffffffc0201fc2:	00003517          	auipc	a0,0x3
ffffffffc0201fc6:	74650513          	addi	a0,a0,1862 # ffffffffc0205708 <commands+0xf00>
ffffffffc0201fca:	8f0fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201fce:	bfe1                	j	ffffffffc0201fa6 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201fd0:	4401                	li	s0,0
ffffffffc0201fd2:	bfd1                	j	ffffffffc0201fa6 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201fd4:	00003697          	auipc	a3,0x3
ffffffffc0201fd8:	76468693          	addi	a3,a3,1892 # ffffffffc0205738 <commands+0xf30>
ffffffffc0201fdc:	00003617          	auipc	a2,0x3
ffffffffc0201fe0:	f7460613          	addi	a2,a2,-140 # ffffffffc0204f50 <commands+0x748>
ffffffffc0201fe4:	06700593          	li	a1,103
ffffffffc0201fe8:	00003517          	auipc	a0,0x3
ffffffffc0201fec:	48850513          	addi	a0,a0,1160 # ffffffffc0205470 <commands+0xc68>
ffffffffc0201ff0:	912fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201ff4 <swap_in>:
{
ffffffffc0201ff4:	7179                	addi	sp,sp,-48
ffffffffc0201ff6:	e84a                	sd	s2,16(sp)
ffffffffc0201ff8:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201ffa:	4505                	li	a0,1
{
ffffffffc0201ffc:	ec26                	sd	s1,24(sp)
ffffffffc0201ffe:	e44e                	sd	s3,8(sp)
ffffffffc0202000:	f406                	sd	ra,40(sp)
ffffffffc0202002:	f022                	sd	s0,32(sp)
ffffffffc0202004:	84ae                	mv	s1,a1
ffffffffc0202006:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202008:	377000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
     assert(result!=NULL);
ffffffffc020200c:	c129                	beqz	a0,ffffffffc020204e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020200e:	842a                	mv	s0,a0
ffffffffc0202010:	01893503          	ld	a0,24(s2)
ffffffffc0202014:	4601                	li	a2,0
ffffffffc0202016:	85a6                	mv	a1,s1
ffffffffc0202018:	473000ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc020201c:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020201e:	6108                	ld	a0,0(a0)
ffffffffc0202020:	85a2                	mv	a1,s0
ffffffffc0202022:	6ef010ef          	jal	ra,ffffffffc0203f10 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202026:	00093583          	ld	a1,0(s2)
ffffffffc020202a:	8626                	mv	a2,s1
ffffffffc020202c:	00003517          	auipc	a0,0x3
ffffffffc0202030:	78c50513          	addi	a0,a0,1932 # ffffffffc02057b8 <commands+0xfb0>
ffffffffc0202034:	81a1                	srli	a1,a1,0x8
ffffffffc0202036:	884fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc020203a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020203c:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202040:	7402                	ld	s0,32(sp)
ffffffffc0202042:	64e2                	ld	s1,24(sp)
ffffffffc0202044:	6942                	ld	s2,16(sp)
ffffffffc0202046:	69a2                	ld	s3,8(sp)
ffffffffc0202048:	4501                	li	a0,0
ffffffffc020204a:	6145                	addi	sp,sp,48
ffffffffc020204c:	8082                	ret
     assert(result!=NULL);
ffffffffc020204e:	00003697          	auipc	a3,0x3
ffffffffc0202052:	75a68693          	addi	a3,a3,1882 # ffffffffc02057a8 <commands+0xfa0>
ffffffffc0202056:	00003617          	auipc	a2,0x3
ffffffffc020205a:	efa60613          	addi	a2,a2,-262 # ffffffffc0204f50 <commands+0x748>
ffffffffc020205e:	07d00593          	li	a1,125
ffffffffc0202062:	00003517          	auipc	a0,0x3
ffffffffc0202066:	40e50513          	addi	a0,a0,1038 # ffffffffc0205470 <commands+0xc68>
ffffffffc020206a:	898fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020206e <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020206e:	0000f797          	auipc	a5,0xf
ffffffffc0202072:	06278793          	addi	a5,a5,98 # ffffffffc02110d0 <free_area>
ffffffffc0202076:	e79c                	sd	a5,8(a5)
ffffffffc0202078:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020207a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020207e:	8082                	ret

ffffffffc0202080 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202080:	0000f517          	auipc	a0,0xf
ffffffffc0202084:	06056503          	lwu	a0,96(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0202088:	8082                	ret

ffffffffc020208a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020208a:	715d                	addi	sp,sp,-80
ffffffffc020208c:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020208e:	0000f417          	auipc	s0,0xf
ffffffffc0202092:	04240413          	addi	s0,s0,66 # ffffffffc02110d0 <free_area>
ffffffffc0202096:	641c                	ld	a5,8(s0)
ffffffffc0202098:	e486                	sd	ra,72(sp)
ffffffffc020209a:	fc26                	sd	s1,56(sp)
ffffffffc020209c:	f84a                	sd	s2,48(sp)
ffffffffc020209e:	f44e                	sd	s3,40(sp)
ffffffffc02020a0:	f052                	sd	s4,32(sp)
ffffffffc02020a2:	ec56                	sd	s5,24(sp)
ffffffffc02020a4:	e85a                	sd	s6,16(sp)
ffffffffc02020a6:	e45e                	sd	s7,8(sp)
ffffffffc02020a8:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02020aa:	2c878763          	beq	a5,s0,ffffffffc0202378 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc02020ae:	4481                	li	s1,0
ffffffffc02020b0:	4901                	li	s2,0
ffffffffc02020b2:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02020b6:	8b09                	andi	a4,a4,2
ffffffffc02020b8:	2c070463          	beqz	a4,ffffffffc0202380 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc02020bc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02020c0:	679c                	ld	a5,8(a5)
ffffffffc02020c2:	2905                	addiw	s2,s2,1
ffffffffc02020c4:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02020c6:	fe8796e3          	bne	a5,s0,ffffffffc02020b2 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02020ca:	89a6                	mv	s3,s1
ffffffffc02020cc:	385000ef          	jal	ra,ffffffffc0202c50 <nr_free_pages>
ffffffffc02020d0:	71351863          	bne	a0,s3,ffffffffc02027e0 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02020d4:	4505                	li	a0,1
ffffffffc02020d6:	2a9000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02020da:	8a2a                	mv	s4,a0
ffffffffc02020dc:	44050263          	beqz	a0,ffffffffc0202520 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02020e0:	4505                	li	a0,1
ffffffffc02020e2:	29d000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02020e6:	89aa                	mv	s3,a0
ffffffffc02020e8:	70050c63          	beqz	a0,ffffffffc0202800 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020ec:	4505                	li	a0,1
ffffffffc02020ee:	291000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02020f2:	8aaa                	mv	s5,a0
ffffffffc02020f4:	4a050663          	beqz	a0,ffffffffc02025a0 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02020f8:	2b3a0463          	beq	s4,s3,ffffffffc02023a0 <default_check+0x316>
ffffffffc02020fc:	2aaa0263          	beq	s4,a0,ffffffffc02023a0 <default_check+0x316>
ffffffffc0202100:	2aa98063          	beq	s3,a0,ffffffffc02023a0 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202104:	000a2783          	lw	a5,0(s4)
ffffffffc0202108:	2a079c63          	bnez	a5,ffffffffc02023c0 <default_check+0x336>
ffffffffc020210c:	0009a783          	lw	a5,0(s3)
ffffffffc0202110:	2a079863          	bnez	a5,ffffffffc02023c0 <default_check+0x336>
ffffffffc0202114:	411c                	lw	a5,0(a0)
ffffffffc0202116:	2a079563          	bnez	a5,ffffffffc02023c0 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020211a:	0000f797          	auipc	a5,0xf
ffffffffc020211e:	4367b783          	ld	a5,1078(a5) # ffffffffc0211550 <pages>
ffffffffc0202122:	40fa0733          	sub	a4,s4,a5
ffffffffc0202126:	870d                	srai	a4,a4,0x3
ffffffffc0202128:	00004597          	auipc	a1,0x4
ffffffffc020212c:	3085b583          	ld	a1,776(a1) # ffffffffc0206430 <error_string+0x38>
ffffffffc0202130:	02b70733          	mul	a4,a4,a1
ffffffffc0202134:	00004617          	auipc	a2,0x4
ffffffffc0202138:	30463603          	ld	a2,772(a2) # ffffffffc0206438 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020213c:	0000f697          	auipc	a3,0xf
ffffffffc0202140:	40c6b683          	ld	a3,1036(a3) # ffffffffc0211548 <npage>
ffffffffc0202144:	06b2                	slli	a3,a3,0xc
ffffffffc0202146:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202148:	0732                	slli	a4,a4,0xc
ffffffffc020214a:	28d77b63          	bgeu	a4,a3,ffffffffc02023e0 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020214e:	40f98733          	sub	a4,s3,a5
ffffffffc0202152:	870d                	srai	a4,a4,0x3
ffffffffc0202154:	02b70733          	mul	a4,a4,a1
ffffffffc0202158:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020215a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020215c:	4cd77263          	bgeu	a4,a3,ffffffffc0202620 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202160:	40f507b3          	sub	a5,a0,a5
ffffffffc0202164:	878d                	srai	a5,a5,0x3
ffffffffc0202166:	02b787b3          	mul	a5,a5,a1
ffffffffc020216a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020216c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020216e:	30d7f963          	bgeu	a5,a3,ffffffffc0202480 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202172:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202174:	00043c03          	ld	s8,0(s0)
ffffffffc0202178:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020217c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202180:	e400                	sd	s0,8(s0)
ffffffffc0202182:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202184:	0000f797          	auipc	a5,0xf
ffffffffc0202188:	f407ae23          	sw	zero,-164(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020218c:	1f3000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202190:	2c051863          	bnez	a0,ffffffffc0202460 <default_check+0x3d6>
    free_page(p0);
ffffffffc0202194:	4585                	li	a1,1
ffffffffc0202196:	8552                	mv	a0,s4
ffffffffc0202198:	279000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_page(p1);
ffffffffc020219c:	4585                	li	a1,1
ffffffffc020219e:	854e                	mv	a0,s3
ffffffffc02021a0:	271000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_page(p2);
ffffffffc02021a4:	4585                	li	a1,1
ffffffffc02021a6:	8556                	mv	a0,s5
ffffffffc02021a8:	269000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    assert(nr_free == 3);
ffffffffc02021ac:	4818                	lw	a4,16(s0)
ffffffffc02021ae:	478d                	li	a5,3
ffffffffc02021b0:	28f71863          	bne	a4,a5,ffffffffc0202440 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02021b4:	4505                	li	a0,1
ffffffffc02021b6:	1c9000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02021ba:	89aa                	mv	s3,a0
ffffffffc02021bc:	26050263          	beqz	a0,ffffffffc0202420 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02021c0:	4505                	li	a0,1
ffffffffc02021c2:	1bd000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02021c6:	8aaa                	mv	s5,a0
ffffffffc02021c8:	3a050c63          	beqz	a0,ffffffffc0202580 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021cc:	4505                	li	a0,1
ffffffffc02021ce:	1b1000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02021d2:	8a2a                	mv	s4,a0
ffffffffc02021d4:	38050663          	beqz	a0,ffffffffc0202560 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc02021d8:	4505                	li	a0,1
ffffffffc02021da:	1a5000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02021de:	36051163          	bnez	a0,ffffffffc0202540 <default_check+0x4b6>
    free_page(p0);
ffffffffc02021e2:	4585                	li	a1,1
ffffffffc02021e4:	854e                	mv	a0,s3
ffffffffc02021e6:	22b000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02021ea:	641c                	ld	a5,8(s0)
ffffffffc02021ec:	20878a63          	beq	a5,s0,ffffffffc0202400 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc02021f0:	4505                	li	a0,1
ffffffffc02021f2:	18d000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02021f6:	30a99563          	bne	s3,a0,ffffffffc0202500 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc02021fa:	4505                	li	a0,1
ffffffffc02021fc:	183000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202200:	2e051063          	bnez	a0,ffffffffc02024e0 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0202204:	481c                	lw	a5,16(s0)
ffffffffc0202206:	2a079d63          	bnez	a5,ffffffffc02024c0 <default_check+0x436>
    free_page(p);
ffffffffc020220a:	854e                	mv	a0,s3
ffffffffc020220c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020220e:	01843023          	sd	s8,0(s0)
ffffffffc0202212:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202216:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020221a:	1f7000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_page(p1);
ffffffffc020221e:	4585                	li	a1,1
ffffffffc0202220:	8556                	mv	a0,s5
ffffffffc0202222:	1ef000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_page(p2);
ffffffffc0202226:	4585                	li	a1,1
ffffffffc0202228:	8552                	mv	a0,s4
ffffffffc020222a:	1e7000ef          	jal	ra,ffffffffc0202c10 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020222e:	4515                	li	a0,5
ffffffffc0202230:	14f000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202234:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202236:	26050563          	beqz	a0,ffffffffc02024a0 <default_check+0x416>
ffffffffc020223a:	651c                	ld	a5,8(a0)
ffffffffc020223c:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020223e:	8b85                	andi	a5,a5,1
ffffffffc0202240:	54079063          	bnez	a5,ffffffffc0202780 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202244:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202246:	00043b03          	ld	s6,0(s0)
ffffffffc020224a:	00843a83          	ld	s5,8(s0)
ffffffffc020224e:	e000                	sd	s0,0(s0)
ffffffffc0202250:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202252:	12d000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202256:	50051563          	bnez	a0,ffffffffc0202760 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020225a:	09098a13          	addi	s4,s3,144
ffffffffc020225e:	8552                	mv	a0,s4
ffffffffc0202260:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202262:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202266:	0000f797          	auipc	a5,0xf
ffffffffc020226a:	e607ad23          	sw	zero,-390(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020226e:	1a3000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202272:	4511                	li	a0,4
ffffffffc0202274:	10b000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202278:	4c051463          	bnez	a0,ffffffffc0202740 <default_check+0x6b6>
ffffffffc020227c:	0989b783          	ld	a5,152(s3)
ffffffffc0202280:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202282:	8b85                	andi	a5,a5,1
ffffffffc0202284:	48078e63          	beqz	a5,ffffffffc0202720 <default_check+0x696>
ffffffffc0202288:	0a89a703          	lw	a4,168(s3)
ffffffffc020228c:	478d                	li	a5,3
ffffffffc020228e:	48f71963          	bne	a4,a5,ffffffffc0202720 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202292:	450d                	li	a0,3
ffffffffc0202294:	0eb000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202298:	8c2a                	mv	s8,a0
ffffffffc020229a:	46050363          	beqz	a0,ffffffffc0202700 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc020229e:	4505                	li	a0,1
ffffffffc02022a0:	0df000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02022a4:	42051e63          	bnez	a0,ffffffffc02026e0 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc02022a8:	418a1c63          	bne	s4,s8,ffffffffc02026c0 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02022ac:	4585                	li	a1,1
ffffffffc02022ae:	854e                	mv	a0,s3
ffffffffc02022b0:	161000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_pages(p1, 3);
ffffffffc02022b4:	458d                	li	a1,3
ffffffffc02022b6:	8552                	mv	a0,s4
ffffffffc02022b8:	159000ef          	jal	ra,ffffffffc0202c10 <free_pages>
ffffffffc02022bc:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02022c0:	04898c13          	addi	s8,s3,72
ffffffffc02022c4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02022c6:	8b85                	andi	a5,a5,1
ffffffffc02022c8:	3c078c63          	beqz	a5,ffffffffc02026a0 <default_check+0x616>
ffffffffc02022cc:	0189a703          	lw	a4,24(s3)
ffffffffc02022d0:	4785                	li	a5,1
ffffffffc02022d2:	3cf71763          	bne	a4,a5,ffffffffc02026a0 <default_check+0x616>
ffffffffc02022d6:	008a3783          	ld	a5,8(s4)
ffffffffc02022da:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02022dc:	8b85                	andi	a5,a5,1
ffffffffc02022de:	3a078163          	beqz	a5,ffffffffc0202680 <default_check+0x5f6>
ffffffffc02022e2:	018a2703          	lw	a4,24(s4)
ffffffffc02022e6:	478d                	li	a5,3
ffffffffc02022e8:	38f71c63          	bne	a4,a5,ffffffffc0202680 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022ec:	4505                	li	a0,1
ffffffffc02022ee:	091000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02022f2:	36a99763          	bne	s3,a0,ffffffffc0202660 <default_check+0x5d6>
    free_page(p0);
ffffffffc02022f6:	4585                	li	a1,1
ffffffffc02022f8:	119000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02022fc:	4509                	li	a0,2
ffffffffc02022fe:	081000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202302:	32aa1f63          	bne	s4,a0,ffffffffc0202640 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0202306:	4589                	li	a1,2
ffffffffc0202308:	109000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    free_page(p2);
ffffffffc020230c:	4585                	li	a1,1
ffffffffc020230e:	8562                	mv	a0,s8
ffffffffc0202310:	101000ef          	jal	ra,ffffffffc0202c10 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202314:	4515                	li	a0,5
ffffffffc0202316:	069000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc020231a:	89aa                	mv	s3,a0
ffffffffc020231c:	48050263          	beqz	a0,ffffffffc02027a0 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0202320:	4505                	li	a0,1
ffffffffc0202322:	05d000ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202326:	2c051d63          	bnez	a0,ffffffffc0202600 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc020232a:	481c                	lw	a5,16(s0)
ffffffffc020232c:	2a079a63          	bnez	a5,ffffffffc02025e0 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202330:	4595                	li	a1,5
ffffffffc0202332:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202334:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202338:	01643023          	sd	s6,0(s0)
ffffffffc020233c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202340:	0d1000ef          	jal	ra,ffffffffc0202c10 <free_pages>
    return listelm->next;
ffffffffc0202344:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202346:	00878963          	beq	a5,s0,ffffffffc0202358 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020234a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020234e:	679c                	ld	a5,8(a5)
ffffffffc0202350:	397d                	addiw	s2,s2,-1
ffffffffc0202352:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202354:	fe879be3          	bne	a5,s0,ffffffffc020234a <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0202358:	26091463          	bnez	s2,ffffffffc02025c0 <default_check+0x536>
    assert(total == 0);
ffffffffc020235c:	46049263          	bnez	s1,ffffffffc02027c0 <default_check+0x736>
}
ffffffffc0202360:	60a6                	ld	ra,72(sp)
ffffffffc0202362:	6406                	ld	s0,64(sp)
ffffffffc0202364:	74e2                	ld	s1,56(sp)
ffffffffc0202366:	7942                	ld	s2,48(sp)
ffffffffc0202368:	79a2                	ld	s3,40(sp)
ffffffffc020236a:	7a02                	ld	s4,32(sp)
ffffffffc020236c:	6ae2                	ld	s5,24(sp)
ffffffffc020236e:	6b42                	ld	s6,16(sp)
ffffffffc0202370:	6ba2                	ld	s7,8(sp)
ffffffffc0202372:	6c02                	ld	s8,0(sp)
ffffffffc0202374:	6161                	addi	sp,sp,80
ffffffffc0202376:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202378:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020237a:	4481                	li	s1,0
ffffffffc020237c:	4901                	li	s2,0
ffffffffc020237e:	b3b9                	j	ffffffffc02020cc <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202380:	00003697          	auipc	a3,0x3
ffffffffc0202384:	11868693          	addi	a3,a3,280 # ffffffffc0205498 <commands+0xc90>
ffffffffc0202388:	00003617          	auipc	a2,0x3
ffffffffc020238c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202390:	0f000593          	li	a1,240
ffffffffc0202394:	00003517          	auipc	a0,0x3
ffffffffc0202398:	46450513          	addi	a0,a0,1124 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020239c:	d67fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02023a0:	00003697          	auipc	a3,0x3
ffffffffc02023a4:	4d068693          	addi	a3,a3,1232 # ffffffffc0205870 <commands+0x1068>
ffffffffc02023a8:	00003617          	auipc	a2,0x3
ffffffffc02023ac:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204f50 <commands+0x748>
ffffffffc02023b0:	0bd00593          	li	a1,189
ffffffffc02023b4:	00003517          	auipc	a0,0x3
ffffffffc02023b8:	44450513          	addi	a0,a0,1092 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02023bc:	d47fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02023c0:	00003697          	auipc	a3,0x3
ffffffffc02023c4:	4d868693          	addi	a3,a3,1240 # ffffffffc0205898 <commands+0x1090>
ffffffffc02023c8:	00003617          	auipc	a2,0x3
ffffffffc02023cc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204f50 <commands+0x748>
ffffffffc02023d0:	0be00593          	li	a1,190
ffffffffc02023d4:	00003517          	auipc	a0,0x3
ffffffffc02023d8:	42450513          	addi	a0,a0,1060 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02023dc:	d27fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02023e0:	00003697          	auipc	a3,0x3
ffffffffc02023e4:	4f868693          	addi	a3,a3,1272 # ffffffffc02058d8 <commands+0x10d0>
ffffffffc02023e8:	00003617          	auipc	a2,0x3
ffffffffc02023ec:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204f50 <commands+0x748>
ffffffffc02023f0:	0c000593          	li	a1,192
ffffffffc02023f4:	00003517          	auipc	a0,0x3
ffffffffc02023f8:	40450513          	addi	a0,a0,1028 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02023fc:	d07fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202400:	00003697          	auipc	a3,0x3
ffffffffc0202404:	56068693          	addi	a3,a3,1376 # ffffffffc0205960 <commands+0x1158>
ffffffffc0202408:	00003617          	auipc	a2,0x3
ffffffffc020240c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202410:	0d900593          	li	a1,217
ffffffffc0202414:	00003517          	auipc	a0,0x3
ffffffffc0202418:	3e450513          	addi	a0,a0,996 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020241c:	ce7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202420:	00003697          	auipc	a3,0x3
ffffffffc0202424:	3f068693          	addi	a3,a3,1008 # ffffffffc0205810 <commands+0x1008>
ffffffffc0202428:	00003617          	auipc	a2,0x3
ffffffffc020242c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202430:	0d200593          	li	a1,210
ffffffffc0202434:	00003517          	auipc	a0,0x3
ffffffffc0202438:	3c450513          	addi	a0,a0,964 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020243c:	cc7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0202440:	00003697          	auipc	a3,0x3
ffffffffc0202444:	51068693          	addi	a3,a3,1296 # ffffffffc0205950 <commands+0x1148>
ffffffffc0202448:	00003617          	auipc	a2,0x3
ffffffffc020244c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202450:	0d000593          	li	a1,208
ffffffffc0202454:	00003517          	auipc	a0,0x3
ffffffffc0202458:	3a450513          	addi	a0,a0,932 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020245c:	ca7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202460:	00003697          	auipc	a3,0x3
ffffffffc0202464:	4d868693          	addi	a3,a3,1240 # ffffffffc0205938 <commands+0x1130>
ffffffffc0202468:	00003617          	auipc	a2,0x3
ffffffffc020246c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202470:	0cb00593          	li	a1,203
ffffffffc0202474:	00003517          	auipc	a0,0x3
ffffffffc0202478:	38450513          	addi	a0,a0,900 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020247c:	c87fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202480:	00003697          	auipc	a3,0x3
ffffffffc0202484:	49868693          	addi	a3,a3,1176 # ffffffffc0205918 <commands+0x1110>
ffffffffc0202488:	00003617          	auipc	a2,0x3
ffffffffc020248c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202490:	0c200593          	li	a1,194
ffffffffc0202494:	00003517          	auipc	a0,0x3
ffffffffc0202498:	36450513          	addi	a0,a0,868 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020249c:	c67fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc02024a0:	00003697          	auipc	a3,0x3
ffffffffc02024a4:	4f868693          	addi	a3,a3,1272 # ffffffffc0205998 <commands+0x1190>
ffffffffc02024a8:	00003617          	auipc	a2,0x3
ffffffffc02024ac:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204f50 <commands+0x748>
ffffffffc02024b0:	0f800593          	li	a1,248
ffffffffc02024b4:	00003517          	auipc	a0,0x3
ffffffffc02024b8:	34450513          	addi	a0,a0,836 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02024bc:	c47fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02024c0:	00003697          	auipc	a3,0x3
ffffffffc02024c4:	18868693          	addi	a3,a3,392 # ffffffffc0205648 <commands+0xe40>
ffffffffc02024c8:	00003617          	auipc	a2,0x3
ffffffffc02024cc:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204f50 <commands+0x748>
ffffffffc02024d0:	0df00593          	li	a1,223
ffffffffc02024d4:	00003517          	auipc	a0,0x3
ffffffffc02024d8:	32450513          	addi	a0,a0,804 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02024dc:	c27fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02024e0:	00003697          	auipc	a3,0x3
ffffffffc02024e4:	45868693          	addi	a3,a3,1112 # ffffffffc0205938 <commands+0x1130>
ffffffffc02024e8:	00003617          	auipc	a2,0x3
ffffffffc02024ec:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204f50 <commands+0x748>
ffffffffc02024f0:	0dd00593          	li	a1,221
ffffffffc02024f4:	00003517          	auipc	a0,0x3
ffffffffc02024f8:	30450513          	addi	a0,a0,772 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02024fc:	c07fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202500:	00003697          	auipc	a3,0x3
ffffffffc0202504:	47868693          	addi	a3,a3,1144 # ffffffffc0205978 <commands+0x1170>
ffffffffc0202508:	00003617          	auipc	a2,0x3
ffffffffc020250c:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202510:	0dc00593          	li	a1,220
ffffffffc0202514:	00003517          	auipc	a0,0x3
ffffffffc0202518:	2e450513          	addi	a0,a0,740 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020251c:	be7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202520:	00003697          	auipc	a3,0x3
ffffffffc0202524:	2f068693          	addi	a3,a3,752 # ffffffffc0205810 <commands+0x1008>
ffffffffc0202528:	00003617          	auipc	a2,0x3
ffffffffc020252c:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202530:	0b900593          	li	a1,185
ffffffffc0202534:	00003517          	auipc	a0,0x3
ffffffffc0202538:	2c450513          	addi	a0,a0,708 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020253c:	bc7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202540:	00003697          	auipc	a3,0x3
ffffffffc0202544:	3f868693          	addi	a3,a3,1016 # ffffffffc0205938 <commands+0x1130>
ffffffffc0202548:	00003617          	auipc	a2,0x3
ffffffffc020254c:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202550:	0d600593          	li	a1,214
ffffffffc0202554:	00003517          	auipc	a0,0x3
ffffffffc0202558:	2a450513          	addi	a0,a0,676 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020255c:	ba7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202560:	00003697          	auipc	a3,0x3
ffffffffc0202564:	2f068693          	addi	a3,a3,752 # ffffffffc0205850 <commands+0x1048>
ffffffffc0202568:	00003617          	auipc	a2,0x3
ffffffffc020256c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202570:	0d400593          	li	a1,212
ffffffffc0202574:	00003517          	auipc	a0,0x3
ffffffffc0202578:	28450513          	addi	a0,a0,644 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020257c:	b87fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202580:	00003697          	auipc	a3,0x3
ffffffffc0202584:	2b068693          	addi	a3,a3,688 # ffffffffc0205830 <commands+0x1028>
ffffffffc0202588:	00003617          	auipc	a2,0x3
ffffffffc020258c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202590:	0d300593          	li	a1,211
ffffffffc0202594:	00003517          	auipc	a0,0x3
ffffffffc0202598:	26450513          	addi	a0,a0,612 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020259c:	b67fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02025a0:	00003697          	auipc	a3,0x3
ffffffffc02025a4:	2b068693          	addi	a3,a3,688 # ffffffffc0205850 <commands+0x1048>
ffffffffc02025a8:	00003617          	auipc	a2,0x3
ffffffffc02025ac:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204f50 <commands+0x748>
ffffffffc02025b0:	0bb00593          	li	a1,187
ffffffffc02025b4:	00003517          	auipc	a0,0x3
ffffffffc02025b8:	24450513          	addi	a0,a0,580 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02025bc:	b47fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc02025c0:	00003697          	auipc	a3,0x3
ffffffffc02025c4:	52868693          	addi	a3,a3,1320 # ffffffffc0205ae8 <commands+0x12e0>
ffffffffc02025c8:	00003617          	auipc	a2,0x3
ffffffffc02025cc:	98860613          	addi	a2,a2,-1656 # ffffffffc0204f50 <commands+0x748>
ffffffffc02025d0:	12500593          	li	a1,293
ffffffffc02025d4:	00003517          	auipc	a0,0x3
ffffffffc02025d8:	22450513          	addi	a0,a0,548 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02025dc:	b27fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02025e0:	00003697          	auipc	a3,0x3
ffffffffc02025e4:	06868693          	addi	a3,a3,104 # ffffffffc0205648 <commands+0xe40>
ffffffffc02025e8:	00003617          	auipc	a2,0x3
ffffffffc02025ec:	96860613          	addi	a2,a2,-1688 # ffffffffc0204f50 <commands+0x748>
ffffffffc02025f0:	11a00593          	li	a1,282
ffffffffc02025f4:	00003517          	auipc	a0,0x3
ffffffffc02025f8:	20450513          	addi	a0,a0,516 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02025fc:	b07fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202600:	00003697          	auipc	a3,0x3
ffffffffc0202604:	33868693          	addi	a3,a3,824 # ffffffffc0205938 <commands+0x1130>
ffffffffc0202608:	00003617          	auipc	a2,0x3
ffffffffc020260c:	94860613          	addi	a2,a2,-1720 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202610:	11800593          	li	a1,280
ffffffffc0202614:	00003517          	auipc	a0,0x3
ffffffffc0202618:	1e450513          	addi	a0,a0,484 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020261c:	ae7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202620:	00003697          	auipc	a3,0x3
ffffffffc0202624:	2d868693          	addi	a3,a3,728 # ffffffffc02058f8 <commands+0x10f0>
ffffffffc0202628:	00003617          	auipc	a2,0x3
ffffffffc020262c:	92860613          	addi	a2,a2,-1752 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202630:	0c100593          	li	a1,193
ffffffffc0202634:	00003517          	auipc	a0,0x3
ffffffffc0202638:	1c450513          	addi	a0,a0,452 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020263c:	ac7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202640:	00003697          	auipc	a3,0x3
ffffffffc0202644:	46868693          	addi	a3,a3,1128 # ffffffffc0205aa8 <commands+0x12a0>
ffffffffc0202648:	00003617          	auipc	a2,0x3
ffffffffc020264c:	90860613          	addi	a2,a2,-1784 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202650:	11200593          	li	a1,274
ffffffffc0202654:	00003517          	auipc	a0,0x3
ffffffffc0202658:	1a450513          	addi	a0,a0,420 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020265c:	aa7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202660:	00003697          	auipc	a3,0x3
ffffffffc0202664:	42868693          	addi	a3,a3,1064 # ffffffffc0205a88 <commands+0x1280>
ffffffffc0202668:	00003617          	auipc	a2,0x3
ffffffffc020266c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202670:	11000593          	li	a1,272
ffffffffc0202674:	00003517          	auipc	a0,0x3
ffffffffc0202678:	18450513          	addi	a0,a0,388 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020267c:	a87fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202680:	00003697          	auipc	a3,0x3
ffffffffc0202684:	3e068693          	addi	a3,a3,992 # ffffffffc0205a60 <commands+0x1258>
ffffffffc0202688:	00003617          	auipc	a2,0x3
ffffffffc020268c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202690:	10e00593          	li	a1,270
ffffffffc0202694:	00003517          	auipc	a0,0x3
ffffffffc0202698:	16450513          	addi	a0,a0,356 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020269c:	a67fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02026a0:	00003697          	auipc	a3,0x3
ffffffffc02026a4:	39868693          	addi	a3,a3,920 # ffffffffc0205a38 <commands+0x1230>
ffffffffc02026a8:	00003617          	auipc	a2,0x3
ffffffffc02026ac:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204f50 <commands+0x748>
ffffffffc02026b0:	10d00593          	li	a1,269
ffffffffc02026b4:	00003517          	auipc	a0,0x3
ffffffffc02026b8:	14450513          	addi	a0,a0,324 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02026bc:	a47fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02026c0:	00003697          	auipc	a3,0x3
ffffffffc02026c4:	36868693          	addi	a3,a3,872 # ffffffffc0205a28 <commands+0x1220>
ffffffffc02026c8:	00003617          	auipc	a2,0x3
ffffffffc02026cc:	88860613          	addi	a2,a2,-1912 # ffffffffc0204f50 <commands+0x748>
ffffffffc02026d0:	10800593          	li	a1,264
ffffffffc02026d4:	00003517          	auipc	a0,0x3
ffffffffc02026d8:	12450513          	addi	a0,a0,292 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02026dc:	a27fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02026e0:	00003697          	auipc	a3,0x3
ffffffffc02026e4:	25868693          	addi	a3,a3,600 # ffffffffc0205938 <commands+0x1130>
ffffffffc02026e8:	00003617          	auipc	a2,0x3
ffffffffc02026ec:	86860613          	addi	a2,a2,-1944 # ffffffffc0204f50 <commands+0x748>
ffffffffc02026f0:	10700593          	li	a1,263
ffffffffc02026f4:	00003517          	auipc	a0,0x3
ffffffffc02026f8:	10450513          	addi	a0,a0,260 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02026fc:	a07fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202700:	00003697          	auipc	a3,0x3
ffffffffc0202704:	30868693          	addi	a3,a3,776 # ffffffffc0205a08 <commands+0x1200>
ffffffffc0202708:	00003617          	auipc	a2,0x3
ffffffffc020270c:	84860613          	addi	a2,a2,-1976 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202710:	10600593          	li	a1,262
ffffffffc0202714:	00003517          	auipc	a0,0x3
ffffffffc0202718:	0e450513          	addi	a0,a0,228 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020271c:	9e7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202720:	00003697          	auipc	a3,0x3
ffffffffc0202724:	2b868693          	addi	a3,a3,696 # ffffffffc02059d8 <commands+0x11d0>
ffffffffc0202728:	00003617          	auipc	a2,0x3
ffffffffc020272c:	82860613          	addi	a2,a2,-2008 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202730:	10500593          	li	a1,261
ffffffffc0202734:	00003517          	auipc	a0,0x3
ffffffffc0202738:	0c450513          	addi	a0,a0,196 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020273c:	9c7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202740:	00003697          	auipc	a3,0x3
ffffffffc0202744:	28068693          	addi	a3,a3,640 # ffffffffc02059c0 <commands+0x11b8>
ffffffffc0202748:	00003617          	auipc	a2,0x3
ffffffffc020274c:	80860613          	addi	a2,a2,-2040 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202750:	10400593          	li	a1,260
ffffffffc0202754:	00003517          	auipc	a0,0x3
ffffffffc0202758:	0a450513          	addi	a0,a0,164 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020275c:	9a7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202760:	00003697          	auipc	a3,0x3
ffffffffc0202764:	1d868693          	addi	a3,a3,472 # ffffffffc0205938 <commands+0x1130>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	7e860613          	addi	a2,a2,2024 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202770:	0fe00593          	li	a1,254
ffffffffc0202774:	00003517          	auipc	a0,0x3
ffffffffc0202778:	08450513          	addi	a0,a0,132 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020277c:	987fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	22868693          	addi	a3,a3,552 # ffffffffc02059a8 <commands+0x11a0>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	7c860613          	addi	a2,a2,1992 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202790:	0f900593          	li	a1,249
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	06450513          	addi	a0,a0,100 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020279c:	967fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02027a0:	00003697          	auipc	a3,0x3
ffffffffc02027a4:	32868693          	addi	a3,a3,808 # ffffffffc0205ac8 <commands+0x12c0>
ffffffffc02027a8:	00002617          	auipc	a2,0x2
ffffffffc02027ac:	7a860613          	addi	a2,a2,1960 # ffffffffc0204f50 <commands+0x748>
ffffffffc02027b0:	11700593          	li	a1,279
ffffffffc02027b4:	00003517          	auipc	a0,0x3
ffffffffc02027b8:	04450513          	addi	a0,a0,68 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02027bc:	947fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc02027c0:	00003697          	auipc	a3,0x3
ffffffffc02027c4:	33868693          	addi	a3,a3,824 # ffffffffc0205af8 <commands+0x12f0>
ffffffffc02027c8:	00002617          	auipc	a2,0x2
ffffffffc02027cc:	78860613          	addi	a2,a2,1928 # ffffffffc0204f50 <commands+0x748>
ffffffffc02027d0:	12600593          	li	a1,294
ffffffffc02027d4:	00003517          	auipc	a0,0x3
ffffffffc02027d8:	02450513          	addi	a0,a0,36 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02027dc:	927fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02027e0:	00003697          	auipc	a3,0x3
ffffffffc02027e4:	cc868693          	addi	a3,a3,-824 # ffffffffc02054a8 <commands+0xca0>
ffffffffc02027e8:	00002617          	auipc	a2,0x2
ffffffffc02027ec:	76860613          	addi	a2,a2,1896 # ffffffffc0204f50 <commands+0x748>
ffffffffc02027f0:	0f300593          	li	a1,243
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	00450513          	addi	a0,a0,4 # ffffffffc02057f8 <commands+0xff0>
ffffffffc02027fc:	907fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202800:	00003697          	auipc	a3,0x3
ffffffffc0202804:	03068693          	addi	a3,a3,48 # ffffffffc0205830 <commands+0x1028>
ffffffffc0202808:	00002617          	auipc	a2,0x2
ffffffffc020280c:	74860613          	addi	a2,a2,1864 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202810:	0ba00593          	li	a1,186
ffffffffc0202814:	00003517          	auipc	a0,0x3
ffffffffc0202818:	fe450513          	addi	a0,a0,-28 # ffffffffc02057f8 <commands+0xff0>
ffffffffc020281c:	8e7fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202820 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202820:	1141                	addi	sp,sp,-16
ffffffffc0202822:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202824:	14058a63          	beqz	a1,ffffffffc0202978 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202828:	00359693          	slli	a3,a1,0x3
ffffffffc020282c:	96ae                	add	a3,a3,a1
ffffffffc020282e:	068e                	slli	a3,a3,0x3
ffffffffc0202830:	96aa                	add	a3,a3,a0
ffffffffc0202832:	87aa                	mv	a5,a0
ffffffffc0202834:	02d50263          	beq	a0,a3,ffffffffc0202858 <default_free_pages+0x38>
ffffffffc0202838:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020283a:	8b05                	andi	a4,a4,1
ffffffffc020283c:	10071e63          	bnez	a4,ffffffffc0202958 <default_free_pages+0x138>
ffffffffc0202840:	6798                	ld	a4,8(a5)
ffffffffc0202842:	8b09                	andi	a4,a4,2
ffffffffc0202844:	10071a63          	bnez	a4,ffffffffc0202958 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202848:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020284c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202850:	04878793          	addi	a5,a5,72
ffffffffc0202854:	fed792e3          	bne	a5,a3,ffffffffc0202838 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202858:	2581                	sext.w	a1,a1
ffffffffc020285a:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020285c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202860:	4789                	li	a5,2
ffffffffc0202862:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202866:	0000f697          	auipc	a3,0xf
ffffffffc020286a:	86a68693          	addi	a3,a3,-1942 # ffffffffc02110d0 <free_area>
ffffffffc020286e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202870:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202872:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202876:	9db9                	addw	a1,a1,a4
ffffffffc0202878:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020287a:	0ad78863          	beq	a5,a3,ffffffffc020292a <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020287e:	fe078713          	addi	a4,a5,-32
ffffffffc0202882:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202886:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202888:	00e56a63          	bltu	a0,a4,ffffffffc020289c <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020288c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020288e:	06d70263          	beq	a4,a3,ffffffffc02028f2 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0202892:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202894:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202898:	fee57ae3          	bgeu	a0,a4,ffffffffc020288c <default_free_pages+0x6c>
ffffffffc020289c:	c199                	beqz	a1,ffffffffc02028a2 <default_free_pages+0x82>
ffffffffc020289e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02028a2:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02028a4:	e390                	sd	a2,0(a5)
ffffffffc02028a6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02028a8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02028aa:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02028ac:	02d70063          	beq	a4,a3,ffffffffc02028cc <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02028b0:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02028b4:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02028b8:	02081613          	slli	a2,a6,0x20
ffffffffc02028bc:	9201                	srli	a2,a2,0x20
ffffffffc02028be:	00361793          	slli	a5,a2,0x3
ffffffffc02028c2:	97b2                	add	a5,a5,a2
ffffffffc02028c4:	078e                	slli	a5,a5,0x3
ffffffffc02028c6:	97ae                	add	a5,a5,a1
ffffffffc02028c8:	02f50f63          	beq	a0,a5,ffffffffc0202906 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02028cc:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02028ce:	00d70f63          	beq	a4,a3,ffffffffc02028ec <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02028d2:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02028d4:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02028d8:	02059613          	slli	a2,a1,0x20
ffffffffc02028dc:	9201                	srli	a2,a2,0x20
ffffffffc02028de:	00361793          	slli	a5,a2,0x3
ffffffffc02028e2:	97b2                	add	a5,a5,a2
ffffffffc02028e4:	078e                	slli	a5,a5,0x3
ffffffffc02028e6:	97aa                	add	a5,a5,a0
ffffffffc02028e8:	04f68863          	beq	a3,a5,ffffffffc0202938 <default_free_pages+0x118>
}
ffffffffc02028ec:	60a2                	ld	ra,8(sp)
ffffffffc02028ee:	0141                	addi	sp,sp,16
ffffffffc02028f0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02028f2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02028f4:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02028f6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02028f8:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02028fa:	02d70563          	beq	a4,a3,ffffffffc0202924 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02028fe:	8832                	mv	a6,a2
ffffffffc0202900:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202902:	87ba                	mv	a5,a4
ffffffffc0202904:	bf41                	j	ffffffffc0202894 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0202906:	4d1c                	lw	a5,24(a0)
ffffffffc0202908:	0107883b          	addw	a6,a5,a6
ffffffffc020290c:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202910:	57f5                	li	a5,-3
ffffffffc0202912:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202916:	7110                	ld	a2,32(a0)
ffffffffc0202918:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020291a:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020291c:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020291e:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202920:	e390                	sd	a2,0(a5)
ffffffffc0202922:	b775                	j	ffffffffc02028ce <default_free_pages+0xae>
ffffffffc0202924:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202926:	873e                	mv	a4,a5
ffffffffc0202928:	b761                	j	ffffffffc02028b0 <default_free_pages+0x90>
}
ffffffffc020292a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020292c:	e390                	sd	a2,0(a5)
ffffffffc020292e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202930:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202932:	f11c                	sd	a5,32(a0)
ffffffffc0202934:	0141                	addi	sp,sp,16
ffffffffc0202936:	8082                	ret
            base->property += p->property;
ffffffffc0202938:	ff872783          	lw	a5,-8(a4)
ffffffffc020293c:	fe870693          	addi	a3,a4,-24
ffffffffc0202940:	9dbd                	addw	a1,a1,a5
ffffffffc0202942:	cd0c                	sw	a1,24(a0)
ffffffffc0202944:	57f5                	li	a5,-3
ffffffffc0202946:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020294a:	6314                	ld	a3,0(a4)
ffffffffc020294c:	671c                	ld	a5,8(a4)
}
ffffffffc020294e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202950:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0202952:	e394                	sd	a3,0(a5)
ffffffffc0202954:	0141                	addi	sp,sp,16
ffffffffc0202956:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202958:	00003697          	auipc	a3,0x3
ffffffffc020295c:	1b868693          	addi	a3,a3,440 # ffffffffc0205b10 <commands+0x1308>
ffffffffc0202960:	00002617          	auipc	a2,0x2
ffffffffc0202964:	5f060613          	addi	a2,a2,1520 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202968:	08300593          	li	a1,131
ffffffffc020296c:	00003517          	auipc	a0,0x3
ffffffffc0202970:	e8c50513          	addi	a0,a0,-372 # ffffffffc02057f8 <commands+0xff0>
ffffffffc0202974:	f8efd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202978:	00003697          	auipc	a3,0x3
ffffffffc020297c:	19068693          	addi	a3,a3,400 # ffffffffc0205b08 <commands+0x1300>
ffffffffc0202980:	00002617          	auipc	a2,0x2
ffffffffc0202984:	5d060613          	addi	a2,a2,1488 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202988:	08000593          	li	a1,128
ffffffffc020298c:	00003517          	auipc	a0,0x3
ffffffffc0202990:	e6c50513          	addi	a0,a0,-404 # ffffffffc02057f8 <commands+0xff0>
ffffffffc0202994:	f6efd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202998 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202998:	c959                	beqz	a0,ffffffffc0202a2e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020299a:	0000e597          	auipc	a1,0xe
ffffffffc020299e:	73658593          	addi	a1,a1,1846 # ffffffffc02110d0 <free_area>
ffffffffc02029a2:	0105a803          	lw	a6,16(a1)
ffffffffc02029a6:	862a                	mv	a2,a0
ffffffffc02029a8:	02081793          	slli	a5,a6,0x20
ffffffffc02029ac:	9381                	srli	a5,a5,0x20
ffffffffc02029ae:	00a7ee63          	bltu	a5,a0,ffffffffc02029ca <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02029b2:	87ae                	mv	a5,a1
ffffffffc02029b4:	a801                	j	ffffffffc02029c4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02029b6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029ba:	02071693          	slli	a3,a4,0x20
ffffffffc02029be:	9281                	srli	a3,a3,0x20
ffffffffc02029c0:	00c6f763          	bgeu	a3,a2,ffffffffc02029ce <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02029c4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02029c6:	feb798e3          	bne	a5,a1,ffffffffc02029b6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02029ca:	4501                	li	a0,0
}
ffffffffc02029cc:	8082                	ret
    return listelm->prev;
ffffffffc02029ce:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02029d2:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02029d6:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02029da:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02029de:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02029e2:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02029e6:	02d67b63          	bgeu	a2,a3,ffffffffc0202a1c <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02029ea:	00361693          	slli	a3,a2,0x3
ffffffffc02029ee:	96b2                	add	a3,a3,a2
ffffffffc02029f0:	068e                	slli	a3,a3,0x3
ffffffffc02029f2:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02029f4:	41c7073b          	subw	a4,a4,t3
ffffffffc02029f8:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02029fa:	00868613          	addi	a2,a3,8
ffffffffc02029fe:	4709                	li	a4,2
ffffffffc0202a00:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202a04:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202a08:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202a0c:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202a10:	e310                	sd	a2,0(a4)
ffffffffc0202a12:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202a16:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202a18:	0316b023          	sd	a7,32(a3)
ffffffffc0202a1c:	41c8083b          	subw	a6,a6,t3
ffffffffc0202a20:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202a24:	5775                	li	a4,-3
ffffffffc0202a26:	17a1                	addi	a5,a5,-24
ffffffffc0202a28:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202a2c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202a2e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202a30:	00003697          	auipc	a3,0x3
ffffffffc0202a34:	0d868693          	addi	a3,a3,216 # ffffffffc0205b08 <commands+0x1300>
ffffffffc0202a38:	00002617          	auipc	a2,0x2
ffffffffc0202a3c:	51860613          	addi	a2,a2,1304 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202a40:	06200593          	li	a1,98
ffffffffc0202a44:	00003517          	auipc	a0,0x3
ffffffffc0202a48:	db450513          	addi	a0,a0,-588 # ffffffffc02057f8 <commands+0xff0>
default_alloc_pages(size_t n) {
ffffffffc0202a4c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202a4e:	eb4fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a52 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202a52:	1141                	addi	sp,sp,-16
ffffffffc0202a54:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202a56:	c9e1                	beqz	a1,ffffffffc0202b26 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202a58:	00359693          	slli	a3,a1,0x3
ffffffffc0202a5c:	96ae                	add	a3,a3,a1
ffffffffc0202a5e:	068e                	slli	a3,a3,0x3
ffffffffc0202a60:	96aa                	add	a3,a3,a0
ffffffffc0202a62:	87aa                	mv	a5,a0
ffffffffc0202a64:	00d50f63          	beq	a0,a3,ffffffffc0202a82 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a68:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202a6a:	8b05                	andi	a4,a4,1
ffffffffc0202a6c:	cf49                	beqz	a4,ffffffffc0202b06 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202a6e:	0007ac23          	sw	zero,24(a5)
ffffffffc0202a72:	0007b423          	sd	zero,8(a5)
ffffffffc0202a76:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202a7a:	04878793          	addi	a5,a5,72
ffffffffc0202a7e:	fed795e3          	bne	a5,a3,ffffffffc0202a68 <default_init_memmap+0x16>
    base->property = n;
ffffffffc0202a82:	2581                	sext.w	a1,a1
ffffffffc0202a84:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202a86:	4789                	li	a5,2
ffffffffc0202a88:	00850713          	addi	a4,a0,8
ffffffffc0202a8c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202a90:	0000e697          	auipc	a3,0xe
ffffffffc0202a94:	64068693          	addi	a3,a3,1600 # ffffffffc02110d0 <free_area>
ffffffffc0202a98:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202a9a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202a9c:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202aa0:	9db9                	addw	a1,a1,a4
ffffffffc0202aa2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202aa4:	04d78a63          	beq	a5,a3,ffffffffc0202af8 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202aa8:	fe078713          	addi	a4,a5,-32
ffffffffc0202aac:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ab0:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202ab2:	00e56a63          	bltu	a0,a4,ffffffffc0202ac6 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0202ab6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202ab8:	02d70263          	beq	a4,a3,ffffffffc0202adc <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202abc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202abe:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202ac2:	fee57ae3          	bgeu	a0,a4,ffffffffc0202ab6 <default_init_memmap+0x64>
ffffffffc0202ac6:	c199                	beqz	a1,ffffffffc0202acc <default_init_memmap+0x7a>
ffffffffc0202ac8:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202acc:	6398                	ld	a4,0(a5)
}
ffffffffc0202ace:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202ad0:	e390                	sd	a2,0(a5)
ffffffffc0202ad2:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202ad4:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202ad6:	f118                	sd	a4,32(a0)
ffffffffc0202ad8:	0141                	addi	sp,sp,16
ffffffffc0202ada:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202adc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202ade:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0202ae0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202ae2:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202ae4:	00d70663          	beq	a4,a3,ffffffffc0202af0 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0202ae8:	8832                	mv	a6,a2
ffffffffc0202aea:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202aec:	87ba                	mv	a5,a4
ffffffffc0202aee:	bfc1                	j	ffffffffc0202abe <default_init_memmap+0x6c>
}
ffffffffc0202af0:	60a2                	ld	ra,8(sp)
ffffffffc0202af2:	e290                	sd	a2,0(a3)
ffffffffc0202af4:	0141                	addi	sp,sp,16
ffffffffc0202af6:	8082                	ret
ffffffffc0202af8:	60a2                	ld	ra,8(sp)
ffffffffc0202afa:	e390                	sd	a2,0(a5)
ffffffffc0202afc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202afe:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202b00:	f11c                	sd	a5,32(a0)
ffffffffc0202b02:	0141                	addi	sp,sp,16
ffffffffc0202b04:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202b06:	00003697          	auipc	a3,0x3
ffffffffc0202b0a:	03268693          	addi	a3,a3,50 # ffffffffc0205b38 <commands+0x1330>
ffffffffc0202b0e:	00002617          	auipc	a2,0x2
ffffffffc0202b12:	44260613          	addi	a2,a2,1090 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202b16:	04900593          	li	a1,73
ffffffffc0202b1a:	00003517          	auipc	a0,0x3
ffffffffc0202b1e:	cde50513          	addi	a0,a0,-802 # ffffffffc02057f8 <commands+0xff0>
ffffffffc0202b22:	de0fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202b26:	00003697          	auipc	a3,0x3
ffffffffc0202b2a:	fe268693          	addi	a3,a3,-30 # ffffffffc0205b08 <commands+0x1300>
ffffffffc0202b2e:	00002617          	auipc	a2,0x2
ffffffffc0202b32:	42260613          	addi	a2,a2,1058 # ffffffffc0204f50 <commands+0x748>
ffffffffc0202b36:	04600593          	li	a1,70
ffffffffc0202b3a:	00003517          	auipc	a0,0x3
ffffffffc0202b3e:	cbe50513          	addi	a0,a0,-834 # ffffffffc02057f8 <commands+0xff0>
ffffffffc0202b42:	dc0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b46 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b46:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202b48:	00002617          	auipc	a2,0x2
ffffffffc0202b4c:	58860613          	addi	a2,a2,1416 # ffffffffc02050d0 <commands+0x8c8>
ffffffffc0202b50:	06500593          	li	a1,101
ffffffffc0202b54:	00002517          	auipc	a0,0x2
ffffffffc0202b58:	56c50513          	addi	a0,a0,1388 # ffffffffc02050c0 <commands+0x8b8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b5c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202b5e:	da4fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b62 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b62:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202b64:	00002617          	auipc	a2,0x2
ffffffffc0202b68:	53460613          	addi	a2,a2,1332 # ffffffffc0205098 <commands+0x890>
ffffffffc0202b6c:	07000593          	li	a1,112
ffffffffc0202b70:	00002517          	auipc	a0,0x2
ffffffffc0202b74:	55050513          	addi	a0,a0,1360 # ffffffffc02050c0 <commands+0x8b8>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b78:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202b7a:	d88fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b7e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202b7e:	7139                	addi	sp,sp,-64
ffffffffc0202b80:	f426                	sd	s1,40(sp)
ffffffffc0202b82:	f04a                	sd	s2,32(sp)
ffffffffc0202b84:	ec4e                	sd	s3,24(sp)
ffffffffc0202b86:	e852                	sd	s4,16(sp)
ffffffffc0202b88:	e456                	sd	s5,8(sp)
ffffffffc0202b8a:	e05a                	sd	s6,0(sp)
ffffffffc0202b8c:	fc06                	sd	ra,56(sp)
ffffffffc0202b8e:	f822                	sd	s0,48(sp)
ffffffffc0202b90:	84aa                	mv	s1,a0
ffffffffc0202b92:	0000f917          	auipc	s2,0xf
ffffffffc0202b96:	9c690913          	addi	s2,s2,-1594 # ffffffffc0211558 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b9a:	4a05                	li	s4,1
ffffffffc0202b9c:	0000fa97          	auipc	s5,0xf
ffffffffc0202ba0:	994a8a93          	addi	s5,s5,-1644 # ffffffffc0211530 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ba4:	0005099b          	sext.w	s3,a0
ffffffffc0202ba8:	0000fb17          	auipc	s6,0xf
ffffffffc0202bac:	968b0b13          	addi	s6,s6,-1688 # ffffffffc0211510 <check_mm_struct>
ffffffffc0202bb0:	a01d                	j	ffffffffc0202bd6 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202bb2:	00093783          	ld	a5,0(s2)
ffffffffc0202bb6:	6f9c                	ld	a5,24(a5)
ffffffffc0202bb8:	9782                	jalr	a5
ffffffffc0202bba:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202bbc:	4601                	li	a2,0
ffffffffc0202bbe:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202bc0:	ec0d                	bnez	s0,ffffffffc0202bfa <alloc_pages+0x7c>
ffffffffc0202bc2:	029a6c63          	bltu	s4,s1,ffffffffc0202bfa <alloc_pages+0x7c>
ffffffffc0202bc6:	000aa783          	lw	a5,0(s5)
ffffffffc0202bca:	2781                	sext.w	a5,a5
ffffffffc0202bcc:	c79d                	beqz	a5,ffffffffc0202bfa <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202bce:	000b3503          	ld	a0,0(s6)
ffffffffc0202bd2:	b0eff0ef          	jal	ra,ffffffffc0201ee0 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bd6:	100027f3          	csrr	a5,sstatus
ffffffffc0202bda:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202bdc:	8526                	mv	a0,s1
ffffffffc0202bde:	dbf1                	beqz	a5,ffffffffc0202bb2 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202be0:	90ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202be4:	00093783          	ld	a5,0(s2)
ffffffffc0202be8:	8526                	mv	a0,s1
ffffffffc0202bea:	6f9c                	ld	a5,24(a5)
ffffffffc0202bec:	9782                	jalr	a5
ffffffffc0202bee:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bf0:	8f9fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202bf4:	4601                	li	a2,0
ffffffffc0202bf6:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202bf8:	d469                	beqz	s0,ffffffffc0202bc2 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202bfa:	70e2                	ld	ra,56(sp)
ffffffffc0202bfc:	8522                	mv	a0,s0
ffffffffc0202bfe:	7442                	ld	s0,48(sp)
ffffffffc0202c00:	74a2                	ld	s1,40(sp)
ffffffffc0202c02:	7902                	ld	s2,32(sp)
ffffffffc0202c04:	69e2                	ld	s3,24(sp)
ffffffffc0202c06:	6a42                	ld	s4,16(sp)
ffffffffc0202c08:	6aa2                	ld	s5,8(sp)
ffffffffc0202c0a:	6b02                	ld	s6,0(sp)
ffffffffc0202c0c:	6121                	addi	sp,sp,64
ffffffffc0202c0e:	8082                	ret

ffffffffc0202c10 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c10:	100027f3          	csrr	a5,sstatus
ffffffffc0202c14:	8b89                	andi	a5,a5,2
ffffffffc0202c16:	e799                	bnez	a5,ffffffffc0202c24 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202c18:	0000f797          	auipc	a5,0xf
ffffffffc0202c1c:	9407b783          	ld	a5,-1728(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202c20:	739c                	ld	a5,32(a5)
ffffffffc0202c22:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202c24:	1101                	addi	sp,sp,-32
ffffffffc0202c26:	ec06                	sd	ra,24(sp)
ffffffffc0202c28:	e822                	sd	s0,16(sp)
ffffffffc0202c2a:	e426                	sd	s1,8(sp)
ffffffffc0202c2c:	842a                	mv	s0,a0
ffffffffc0202c2e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202c30:	8bffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202c34:	0000f797          	auipc	a5,0xf
ffffffffc0202c38:	9247b783          	ld	a5,-1756(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202c3c:	739c                	ld	a5,32(a5)
ffffffffc0202c3e:	85a6                	mv	a1,s1
ffffffffc0202c40:	8522                	mv	a0,s0
ffffffffc0202c42:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202c44:	6442                	ld	s0,16(sp)
ffffffffc0202c46:	60e2                	ld	ra,24(sp)
ffffffffc0202c48:	64a2                	ld	s1,8(sp)
ffffffffc0202c4a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202c4c:	89dfd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202c50 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c50:	100027f3          	csrr	a5,sstatus
ffffffffc0202c54:	8b89                	andi	a5,a5,2
ffffffffc0202c56:	e799                	bnez	a5,ffffffffc0202c64 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c58:	0000f797          	auipc	a5,0xf
ffffffffc0202c5c:	9007b783          	ld	a5,-1792(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202c60:	779c                	ld	a5,40(a5)
ffffffffc0202c62:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202c64:	1141                	addi	sp,sp,-16
ffffffffc0202c66:	e406                	sd	ra,8(sp)
ffffffffc0202c68:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202c6a:	885fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c6e:	0000f797          	auipc	a5,0xf
ffffffffc0202c72:	8ea7b783          	ld	a5,-1814(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202c76:	779c                	ld	a5,40(a5)
ffffffffc0202c78:	9782                	jalr	a5
ffffffffc0202c7a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c7c:	86dfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202c80:	60a2                	ld	ra,8(sp)
ffffffffc0202c82:	8522                	mv	a0,s0
ffffffffc0202c84:	6402                	ld	s0,0(sp)
ffffffffc0202c86:	0141                	addi	sp,sp,16
ffffffffc0202c88:	8082                	ret

ffffffffc0202c8a <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c8a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202c8e:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c92:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c94:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c96:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c98:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c9c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c9e:	f84a                	sd	s2,48(sp)
ffffffffc0202ca0:	f44e                	sd	s3,40(sp)
ffffffffc0202ca2:	f052                	sd	s4,32(sp)
ffffffffc0202ca4:	e486                	sd	ra,72(sp)
ffffffffc0202ca6:	e0a2                	sd	s0,64(sp)
ffffffffc0202ca8:	ec56                	sd	s5,24(sp)
ffffffffc0202caa:	e85a                	sd	s6,16(sp)
ffffffffc0202cac:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202cae:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202cb2:	892e                	mv	s2,a1
ffffffffc0202cb4:	8a32                	mv	s4,a2
ffffffffc0202cb6:	0000f997          	auipc	s3,0xf
ffffffffc0202cba:	89298993          	addi	s3,s3,-1902 # ffffffffc0211548 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202cbe:	efb5                	bnez	a5,ffffffffc0202d3a <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202cc0:	14060c63          	beqz	a2,ffffffffc0202e18 <get_pte+0x18e>
ffffffffc0202cc4:	4505                	li	a0,1
ffffffffc0202cc6:	eb9ff0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202cca:	842a                	mv	s0,a0
ffffffffc0202ccc:	14050663          	beqz	a0,ffffffffc0202e18 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cd0:	0000fb97          	auipc	s7,0xf
ffffffffc0202cd4:	880b8b93          	addi	s7,s7,-1920 # ffffffffc0211550 <pages>
ffffffffc0202cd8:	000bb503          	ld	a0,0(s7)
ffffffffc0202cdc:	00003b17          	auipc	s6,0x3
ffffffffc0202ce0:	754b3b03          	ld	s6,1876(s6) # ffffffffc0206430 <error_string+0x38>
ffffffffc0202ce4:	00080ab7          	lui	s5,0x80
ffffffffc0202ce8:	40a40533          	sub	a0,s0,a0
ffffffffc0202cec:	850d                	srai	a0,a0,0x3
ffffffffc0202cee:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cf2:	0000f997          	auipc	s3,0xf
ffffffffc0202cf6:	85698993          	addi	s3,s3,-1962 # ffffffffc0211548 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202cfa:	4785                	li	a5,1
ffffffffc0202cfc:	0009b703          	ld	a4,0(s3)
ffffffffc0202d00:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d02:	9556                	add	a0,a0,s5
ffffffffc0202d04:	00c51793          	slli	a5,a0,0xc
ffffffffc0202d08:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d0a:	0532                	slli	a0,a0,0xc
ffffffffc0202d0c:	14e7fd63          	bgeu	a5,a4,ffffffffc0202e66 <get_pte+0x1dc>
ffffffffc0202d10:	0000f797          	auipc	a5,0xf
ffffffffc0202d14:	8507b783          	ld	a5,-1968(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0202d18:	6605                	lui	a2,0x1
ffffffffc0202d1a:	4581                	li	a1,0
ffffffffc0202d1c:	953e                	add	a0,a0,a5
ffffffffc0202d1e:	3a2010ef          	jal	ra,ffffffffc02040c0 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d22:	000bb683          	ld	a3,0(s7)
ffffffffc0202d26:	40d406b3          	sub	a3,s0,a3
ffffffffc0202d2a:	868d                	srai	a3,a3,0x3
ffffffffc0202d2c:	036686b3          	mul	a3,a3,s6
ffffffffc0202d30:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202d32:	06aa                	slli	a3,a3,0xa
ffffffffc0202d34:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202d38:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d3a:	77fd                	lui	a5,0xfffff
ffffffffc0202d3c:	068a                	slli	a3,a3,0x2
ffffffffc0202d3e:	0009b703          	ld	a4,0(s3)
ffffffffc0202d42:	8efd                	and	a3,a3,a5
ffffffffc0202d44:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202d48:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202e1c <get_pte+0x192>
ffffffffc0202d4c:	0000fa97          	auipc	s5,0xf
ffffffffc0202d50:	814a8a93          	addi	s5,s5,-2028 # ffffffffc0211560 <va_pa_offset>
ffffffffc0202d54:	000ab403          	ld	s0,0(s5)
ffffffffc0202d58:	01595793          	srli	a5,s2,0x15
ffffffffc0202d5c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202d60:	96a2                	add	a3,a3,s0
ffffffffc0202d62:	00379413          	slli	s0,a5,0x3
ffffffffc0202d66:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202d68:	6014                	ld	a3,0(s0)
ffffffffc0202d6a:	0016f793          	andi	a5,a3,1
ffffffffc0202d6e:	ebad                	bnez	a5,ffffffffc0202de0 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202d70:	0a0a0463          	beqz	s4,ffffffffc0202e18 <get_pte+0x18e>
ffffffffc0202d74:	4505                	li	a0,1
ffffffffc0202d76:	e09ff0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0202d7a:	84aa                	mv	s1,a0
ffffffffc0202d7c:	cd51                	beqz	a0,ffffffffc0202e18 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d7e:	0000eb97          	auipc	s7,0xe
ffffffffc0202d82:	7d2b8b93          	addi	s7,s7,2002 # ffffffffc0211550 <pages>
ffffffffc0202d86:	000bb503          	ld	a0,0(s7)
ffffffffc0202d8a:	00003b17          	auipc	s6,0x3
ffffffffc0202d8e:	6a6b3b03          	ld	s6,1702(s6) # ffffffffc0206430 <error_string+0x38>
ffffffffc0202d92:	00080a37          	lui	s4,0x80
ffffffffc0202d96:	40a48533          	sub	a0,s1,a0
ffffffffc0202d9a:	850d                	srai	a0,a0,0x3
ffffffffc0202d9c:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202da0:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202da2:	0009b703          	ld	a4,0(s3)
ffffffffc0202da6:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202da8:	9552                	add	a0,a0,s4
ffffffffc0202daa:	00c51793          	slli	a5,a0,0xc
ffffffffc0202dae:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202db0:	0532                	slli	a0,a0,0xc
ffffffffc0202db2:	08e7fd63          	bgeu	a5,a4,ffffffffc0202e4c <get_pte+0x1c2>
ffffffffc0202db6:	000ab783          	ld	a5,0(s5)
ffffffffc0202dba:	6605                	lui	a2,0x1
ffffffffc0202dbc:	4581                	li	a1,0
ffffffffc0202dbe:	953e                	add	a0,a0,a5
ffffffffc0202dc0:	300010ef          	jal	ra,ffffffffc02040c0 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202dc4:	000bb683          	ld	a3,0(s7)
ffffffffc0202dc8:	40d486b3          	sub	a3,s1,a3
ffffffffc0202dcc:	868d                	srai	a3,a3,0x3
ffffffffc0202dce:	036686b3          	mul	a3,a3,s6
ffffffffc0202dd2:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202dd4:	06aa                	slli	a3,a3,0xa
ffffffffc0202dd6:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202dda:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202ddc:	0009b703          	ld	a4,0(s3)
ffffffffc0202de0:	068a                	slli	a3,a3,0x2
ffffffffc0202de2:	757d                	lui	a0,0xfffff
ffffffffc0202de4:	8ee9                	and	a3,a3,a0
ffffffffc0202de6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202dea:	04e7f563          	bgeu	a5,a4,ffffffffc0202e34 <get_pte+0x1aa>
ffffffffc0202dee:	000ab503          	ld	a0,0(s5)
ffffffffc0202df2:	00c95913          	srli	s2,s2,0xc
ffffffffc0202df6:	1ff97913          	andi	s2,s2,511
ffffffffc0202dfa:	96aa                	add	a3,a3,a0
ffffffffc0202dfc:	00391513          	slli	a0,s2,0x3
ffffffffc0202e00:	9536                	add	a0,a0,a3
}
ffffffffc0202e02:	60a6                	ld	ra,72(sp)
ffffffffc0202e04:	6406                	ld	s0,64(sp)
ffffffffc0202e06:	74e2                	ld	s1,56(sp)
ffffffffc0202e08:	7942                	ld	s2,48(sp)
ffffffffc0202e0a:	79a2                	ld	s3,40(sp)
ffffffffc0202e0c:	7a02                	ld	s4,32(sp)
ffffffffc0202e0e:	6ae2                	ld	s5,24(sp)
ffffffffc0202e10:	6b42                	ld	s6,16(sp)
ffffffffc0202e12:	6ba2                	ld	s7,8(sp)
ffffffffc0202e14:	6161                	addi	sp,sp,80
ffffffffc0202e16:	8082                	ret
            return NULL;
ffffffffc0202e18:	4501                	li	a0,0
ffffffffc0202e1a:	b7e5                	j	ffffffffc0202e02 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202e1c:	00003617          	auipc	a2,0x3
ffffffffc0202e20:	d7c60613          	addi	a2,a2,-644 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0202e24:	10200593          	li	a1,258
ffffffffc0202e28:	00003517          	auipc	a0,0x3
ffffffffc0202e2c:	d9850513          	addi	a0,a0,-616 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0202e30:	ad2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202e34:	00003617          	auipc	a2,0x3
ffffffffc0202e38:	d6460613          	addi	a2,a2,-668 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0202e3c:	10f00593          	li	a1,271
ffffffffc0202e40:	00003517          	auipc	a0,0x3
ffffffffc0202e44:	d8050513          	addi	a0,a0,-640 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0202e48:	abafd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e4c:	86aa                	mv	a3,a0
ffffffffc0202e4e:	00003617          	auipc	a2,0x3
ffffffffc0202e52:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0202e56:	10b00593          	li	a1,267
ffffffffc0202e5a:	00003517          	auipc	a0,0x3
ffffffffc0202e5e:	d6650513          	addi	a0,a0,-666 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0202e62:	aa0fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e66:	86aa                	mv	a3,a0
ffffffffc0202e68:	00003617          	auipc	a2,0x3
ffffffffc0202e6c:	d3060613          	addi	a2,a2,-720 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0202e70:	0ff00593          	li	a1,255
ffffffffc0202e74:	00003517          	auipc	a0,0x3
ffffffffc0202e78:	d4c50513          	addi	a0,a0,-692 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0202e7c:	a86fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202e80 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e80:	1141                	addi	sp,sp,-16
ffffffffc0202e82:	e022                	sd	s0,0(sp)
ffffffffc0202e84:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e86:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e88:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e8a:	e01ff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202e8e:	c011                	beqz	s0,ffffffffc0202e92 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202e90:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e92:	c511                	beqz	a0,ffffffffc0202e9e <get_page+0x1e>
ffffffffc0202e94:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202e96:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e98:	0017f713          	andi	a4,a5,1
ffffffffc0202e9c:	e709                	bnez	a4,ffffffffc0202ea6 <get_page+0x26>
}
ffffffffc0202e9e:	60a2                	ld	ra,8(sp)
ffffffffc0202ea0:	6402                	ld	s0,0(sp)
ffffffffc0202ea2:	0141                	addi	sp,sp,16
ffffffffc0202ea4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ea6:	078a                	slli	a5,a5,0x2
ffffffffc0202ea8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eaa:	0000e717          	auipc	a4,0xe
ffffffffc0202eae:	69e73703          	ld	a4,1694(a4) # ffffffffc0211548 <npage>
ffffffffc0202eb2:	02e7f263          	bgeu	a5,a4,ffffffffc0202ed6 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eb6:	fff80537          	lui	a0,0xfff80
ffffffffc0202eba:	97aa                	add	a5,a5,a0
ffffffffc0202ebc:	60a2                	ld	ra,8(sp)
ffffffffc0202ebe:	6402                	ld	s0,0(sp)
ffffffffc0202ec0:	00379513          	slli	a0,a5,0x3
ffffffffc0202ec4:	97aa                	add	a5,a5,a0
ffffffffc0202ec6:	078e                	slli	a5,a5,0x3
ffffffffc0202ec8:	0000e517          	auipc	a0,0xe
ffffffffc0202ecc:	68853503          	ld	a0,1672(a0) # ffffffffc0211550 <pages>
ffffffffc0202ed0:	953e                	add	a0,a0,a5
ffffffffc0202ed2:	0141                	addi	sp,sp,16
ffffffffc0202ed4:	8082                	ret
ffffffffc0202ed6:	c71ff0ef          	jal	ra,ffffffffc0202b46 <pa2page.part.0>

ffffffffc0202eda <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202eda:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202edc:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202ede:	ec06                	sd	ra,24(sp)
ffffffffc0202ee0:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ee2:	da9ff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
    if (ptep != NULL) {
ffffffffc0202ee6:	c511                	beqz	a0,ffffffffc0202ef2 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202ee8:	611c                	ld	a5,0(a0)
ffffffffc0202eea:	842a                	mv	s0,a0
ffffffffc0202eec:	0017f713          	andi	a4,a5,1
ffffffffc0202ef0:	e709                	bnez	a4,ffffffffc0202efa <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202ef2:	60e2                	ld	ra,24(sp)
ffffffffc0202ef4:	6442                	ld	s0,16(sp)
ffffffffc0202ef6:	6105                	addi	sp,sp,32
ffffffffc0202ef8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202efa:	078a                	slli	a5,a5,0x2
ffffffffc0202efc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202efe:	0000e717          	auipc	a4,0xe
ffffffffc0202f02:	64a73703          	ld	a4,1610(a4) # ffffffffc0211548 <npage>
ffffffffc0202f06:	06e7f563          	bgeu	a5,a4,ffffffffc0202f70 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f0a:	fff80737          	lui	a4,0xfff80
ffffffffc0202f0e:	97ba                	add	a5,a5,a4
ffffffffc0202f10:	00379513          	slli	a0,a5,0x3
ffffffffc0202f14:	97aa                	add	a5,a5,a0
ffffffffc0202f16:	078e                	slli	a5,a5,0x3
ffffffffc0202f18:	0000e517          	auipc	a0,0xe
ffffffffc0202f1c:	63853503          	ld	a0,1592(a0) # ffffffffc0211550 <pages>
ffffffffc0202f20:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202f22:	411c                	lw	a5,0(a0)
ffffffffc0202f24:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f28:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202f2a:	cb09                	beqz	a4,ffffffffc0202f3c <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202f2c:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f30:	12000073          	sfence.vma
}
ffffffffc0202f34:	60e2                	ld	ra,24(sp)
ffffffffc0202f36:	6442                	ld	s0,16(sp)
ffffffffc0202f38:	6105                	addi	sp,sp,32
ffffffffc0202f3a:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f3c:	100027f3          	csrr	a5,sstatus
ffffffffc0202f40:	8b89                	andi	a5,a5,2
ffffffffc0202f42:	eb89                	bnez	a5,ffffffffc0202f54 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f44:	0000e797          	auipc	a5,0xe
ffffffffc0202f48:	6147b783          	ld	a5,1556(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f4c:	739c                	ld	a5,32(a5)
ffffffffc0202f4e:	4585                	li	a1,1
ffffffffc0202f50:	9782                	jalr	a5
    if (flag) {
ffffffffc0202f52:	bfe9                	j	ffffffffc0202f2c <page_remove+0x52>
        intr_disable();
ffffffffc0202f54:	e42a                	sd	a0,8(sp)
ffffffffc0202f56:	d98fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202f5a:	0000e797          	auipc	a5,0xe
ffffffffc0202f5e:	5fe7b783          	ld	a5,1534(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f62:	739c                	ld	a5,32(a5)
ffffffffc0202f64:	6522                	ld	a0,8(sp)
ffffffffc0202f66:	4585                	li	a1,1
ffffffffc0202f68:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f6a:	d7efd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f6e:	bf7d                	j	ffffffffc0202f2c <page_remove+0x52>
ffffffffc0202f70:	bd7ff0ef          	jal	ra,ffffffffc0202b46 <pa2page.part.0>

ffffffffc0202f74 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f74:	7179                	addi	sp,sp,-48
ffffffffc0202f76:	87b2                	mv	a5,a2
ffffffffc0202f78:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f7a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f7c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f7e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f80:	ec26                	sd	s1,24(sp)
ffffffffc0202f82:	f406                	sd	ra,40(sp)
ffffffffc0202f84:	e84a                	sd	s2,16(sp)
ffffffffc0202f86:	e44e                	sd	s3,8(sp)
ffffffffc0202f88:	e052                	sd	s4,0(sp)
ffffffffc0202f8a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f8c:	cffff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
    if (ptep == NULL) {
ffffffffc0202f90:	cd71                	beqz	a0,ffffffffc020306c <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202f92:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202f94:	611c                	ld	a5,0(a0)
ffffffffc0202f96:	89aa                	mv	s3,a0
ffffffffc0202f98:	0016871b          	addiw	a4,a3,1
ffffffffc0202f9c:	c018                	sw	a4,0(s0)
ffffffffc0202f9e:	0017f713          	andi	a4,a5,1
ffffffffc0202fa2:	e331                	bnez	a4,ffffffffc0202fe6 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202fa4:	0000e797          	auipc	a5,0xe
ffffffffc0202fa8:	5ac7b783          	ld	a5,1452(a5) # ffffffffc0211550 <pages>
ffffffffc0202fac:	40f407b3          	sub	a5,s0,a5
ffffffffc0202fb0:	878d                	srai	a5,a5,0x3
ffffffffc0202fb2:	00003417          	auipc	s0,0x3
ffffffffc0202fb6:	47e43403          	ld	s0,1150(s0) # ffffffffc0206430 <error_string+0x38>
ffffffffc0202fba:	028787b3          	mul	a5,a5,s0
ffffffffc0202fbe:	00080437          	lui	s0,0x80
ffffffffc0202fc2:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202fc4:	07aa                	slli	a5,a5,0xa
ffffffffc0202fc6:	8cdd                	or	s1,s1,a5
ffffffffc0202fc8:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202fcc:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202fd0:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202fd4:	4501                	li	a0,0
}
ffffffffc0202fd6:	70a2                	ld	ra,40(sp)
ffffffffc0202fd8:	7402                	ld	s0,32(sp)
ffffffffc0202fda:	64e2                	ld	s1,24(sp)
ffffffffc0202fdc:	6942                	ld	s2,16(sp)
ffffffffc0202fde:	69a2                	ld	s3,8(sp)
ffffffffc0202fe0:	6a02                	ld	s4,0(sp)
ffffffffc0202fe2:	6145                	addi	sp,sp,48
ffffffffc0202fe4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202fe6:	00279713          	slli	a4,a5,0x2
ffffffffc0202fea:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fec:	0000e797          	auipc	a5,0xe
ffffffffc0202ff0:	55c7b783          	ld	a5,1372(a5) # ffffffffc0211548 <npage>
ffffffffc0202ff4:	06f77e63          	bgeu	a4,a5,ffffffffc0203070 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ff8:	fff807b7          	lui	a5,0xfff80
ffffffffc0202ffc:	973e                	add	a4,a4,a5
ffffffffc0202ffe:	0000ea17          	auipc	s4,0xe
ffffffffc0203002:	552a0a13          	addi	s4,s4,1362 # ffffffffc0211550 <pages>
ffffffffc0203006:	000a3783          	ld	a5,0(s4)
ffffffffc020300a:	00371913          	slli	s2,a4,0x3
ffffffffc020300e:	993a                	add	s2,s2,a4
ffffffffc0203010:	090e                	slli	s2,s2,0x3
ffffffffc0203012:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0203014:	03240063          	beq	s0,s2,ffffffffc0203034 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0203018:	00092783          	lw	a5,0(s2)
ffffffffc020301c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203020:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0203024:	cb11                	beqz	a4,ffffffffc0203038 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203026:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020302a:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020302e:	000a3783          	ld	a5,0(s4)
}
ffffffffc0203032:	bfad                	j	ffffffffc0202fac <page_insert+0x38>
    page->ref -= 1;
ffffffffc0203034:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203036:	bf9d                	j	ffffffffc0202fac <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203038:	100027f3          	csrr	a5,sstatus
ffffffffc020303c:	8b89                	andi	a5,a5,2
ffffffffc020303e:	eb91                	bnez	a5,ffffffffc0203052 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203040:	0000e797          	auipc	a5,0xe
ffffffffc0203044:	5187b783          	ld	a5,1304(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203048:	739c                	ld	a5,32(a5)
ffffffffc020304a:	4585                	li	a1,1
ffffffffc020304c:	854a                	mv	a0,s2
ffffffffc020304e:	9782                	jalr	a5
    if (flag) {
ffffffffc0203050:	bfd9                	j	ffffffffc0203026 <page_insert+0xb2>
        intr_disable();
ffffffffc0203052:	c9cfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203056:	0000e797          	auipc	a5,0xe
ffffffffc020305a:	5027b783          	ld	a5,1282(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc020305e:	739c                	ld	a5,32(a5)
ffffffffc0203060:	4585                	li	a1,1
ffffffffc0203062:	854a                	mv	a0,s2
ffffffffc0203064:	9782                	jalr	a5
        intr_enable();
ffffffffc0203066:	c82fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020306a:	bf75                	j	ffffffffc0203026 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc020306c:	5571                	li	a0,-4
ffffffffc020306e:	b7a5                	j	ffffffffc0202fd6 <page_insert+0x62>
ffffffffc0203070:	ad7ff0ef          	jal	ra,ffffffffc0202b46 <pa2page.part.0>

ffffffffc0203074 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203074:	00003797          	auipc	a5,0x3
ffffffffc0203078:	aec78793          	addi	a5,a5,-1300 # ffffffffc0205b60 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020307c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020307e:	7159                	addi	sp,sp,-112
ffffffffc0203080:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203082:	00003517          	auipc	a0,0x3
ffffffffc0203086:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0205bd0 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc020308a:	0000eb97          	auipc	s7,0xe
ffffffffc020308e:	4ceb8b93          	addi	s7,s7,1230 # ffffffffc0211558 <pmm_manager>
void pmm_init(void) {
ffffffffc0203092:	f486                	sd	ra,104(sp)
ffffffffc0203094:	f0a2                	sd	s0,96(sp)
ffffffffc0203096:	eca6                	sd	s1,88(sp)
ffffffffc0203098:	e8ca                	sd	s2,80(sp)
ffffffffc020309a:	e4ce                	sd	s3,72(sp)
ffffffffc020309c:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020309e:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02030a2:	e0d2                	sd	s4,64(sp)
ffffffffc02030a4:	fc56                	sd	s5,56(sp)
ffffffffc02030a6:	f062                	sd	s8,32(sp)
ffffffffc02030a8:	ec66                	sd	s9,24(sp)
ffffffffc02030aa:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030ac:	80efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc02030b0:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc02030b4:	4445                	li	s0,17
ffffffffc02030b6:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc02030ba:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02030bc:	0000e997          	auipc	s3,0xe
ffffffffc02030c0:	4a498993          	addi	s3,s3,1188 # ffffffffc0211560 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02030c4:	0000e497          	auipc	s1,0xe
ffffffffc02030c8:	48448493          	addi	s1,s1,1156 # ffffffffc0211548 <npage>
    pmm_manager->init();
ffffffffc02030cc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02030ce:	57f5                	li	a5,-3
ffffffffc02030d0:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc02030d2:	07e006b7          	lui	a3,0x7e00
ffffffffc02030d6:	01b41613          	slli	a2,s0,0x1b
ffffffffc02030da:	01591593          	slli	a1,s2,0x15
ffffffffc02030de:	00003517          	auipc	a0,0x3
ffffffffc02030e2:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0205be8 <default_pmm_manager+0x88>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02030e6:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc02030ea:	fd1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc02030ee:	00003517          	auipc	a0,0x3
ffffffffc02030f2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0205c18 <default_pmm_manager+0xb8>
ffffffffc02030f6:	fc5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030fa:	01b41693          	slli	a3,s0,0x1b
ffffffffc02030fe:	16fd                	addi	a3,a3,-1
ffffffffc0203100:	07e005b7          	lui	a1,0x7e00
ffffffffc0203104:	01591613          	slli	a2,s2,0x15
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205c30 <default_pmm_manager+0xd0>
ffffffffc0203110:	fabfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203114:	777d                	lui	a4,0xfffff
ffffffffc0203116:	0000f797          	auipc	a5,0xf
ffffffffc020311a:	45178793          	addi	a5,a5,1105 # ffffffffc0212567 <end+0xfff>
ffffffffc020311e:	8ff9                	and	a5,a5,a4
ffffffffc0203120:	0000eb17          	auipc	s6,0xe
ffffffffc0203124:	430b0b13          	addi	s6,s6,1072 # ffffffffc0211550 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203128:	00088737          	lui	a4,0x88
ffffffffc020312c:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020312e:	00fb3023          	sd	a5,0(s6)
ffffffffc0203132:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203134:	4701                	li	a4,0
ffffffffc0203136:	4505                	li	a0,1
ffffffffc0203138:	fff805b7          	lui	a1,0xfff80
ffffffffc020313c:	a019                	j	ffffffffc0203142 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc020313e:	000b3783          	ld	a5,0(s6)
ffffffffc0203142:	97b6                	add	a5,a5,a3
ffffffffc0203144:	07a1                	addi	a5,a5,8
ffffffffc0203146:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020314a:	609c                	ld	a5,0(s1)
ffffffffc020314c:	0705                	addi	a4,a4,1
ffffffffc020314e:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0203152:	00b78633          	add	a2,a5,a1
ffffffffc0203156:	fec764e3          	bltu	a4,a2,ffffffffc020313e <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020315a:	000b3503          	ld	a0,0(s6)
ffffffffc020315e:	00379693          	slli	a3,a5,0x3
ffffffffc0203162:	96be                	add	a3,a3,a5
ffffffffc0203164:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203168:	972a                	add	a4,a4,a0
ffffffffc020316a:	068e                	slli	a3,a3,0x3
ffffffffc020316c:	96ba                	add	a3,a3,a4
ffffffffc020316e:	c0200737          	lui	a4,0xc0200
ffffffffc0203172:	64e6e463          	bltu	a3,a4,ffffffffc02037ba <pmm_init+0x746>
ffffffffc0203176:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc020317a:	4645                	li	a2,17
ffffffffc020317c:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020317e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203180:	4ec6e263          	bltu	a3,a2,ffffffffc0203664 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203184:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203188:	0000e917          	auipc	s2,0xe
ffffffffc020318c:	3b890913          	addi	s2,s2,952 # ffffffffc0211540 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203190:	7b9c                	ld	a5,48(a5)
ffffffffc0203192:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203194:	00003517          	auipc	a0,0x3
ffffffffc0203198:	aec50513          	addi	a0,a0,-1300 # ffffffffc0205c80 <default_pmm_manager+0x120>
ffffffffc020319c:	f1ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02031a0:	00006697          	auipc	a3,0x6
ffffffffc02031a4:	e6068693          	addi	a3,a3,-416 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02031a8:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02031ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02031b0:	62f6e163          	bltu	a3,a5,ffffffffc02037d2 <pmm_init+0x75e>
ffffffffc02031b4:	0009b783          	ld	a5,0(s3)
ffffffffc02031b8:	8e9d                	sub	a3,a3,a5
ffffffffc02031ba:	0000e797          	auipc	a5,0xe
ffffffffc02031be:	36d7bf23          	sd	a3,894(a5) # ffffffffc0211538 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02031c2:	100027f3          	csrr	a5,sstatus
ffffffffc02031c6:	8b89                	andi	a5,a5,2
ffffffffc02031c8:	4c079763          	bnez	a5,ffffffffc0203696 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02031cc:	000bb783          	ld	a5,0(s7)
ffffffffc02031d0:	779c                	ld	a5,40(a5)
ffffffffc02031d2:	9782                	jalr	a5
ffffffffc02031d4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031d6:	6098                	ld	a4,0(s1)
ffffffffc02031d8:	c80007b7          	lui	a5,0xc8000
ffffffffc02031dc:	83b1                	srli	a5,a5,0xc
ffffffffc02031de:	62e7e663          	bltu	a5,a4,ffffffffc020380a <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02031e2:	00093503          	ld	a0,0(s2)
ffffffffc02031e6:	60050263          	beqz	a0,ffffffffc02037ea <pmm_init+0x776>
ffffffffc02031ea:	03451793          	slli	a5,a0,0x34
ffffffffc02031ee:	5e079e63          	bnez	a5,ffffffffc02037ea <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02031f2:	4601                	li	a2,0
ffffffffc02031f4:	4581                	li	a1,0
ffffffffc02031f6:	c8bff0ef          	jal	ra,ffffffffc0202e80 <get_page>
ffffffffc02031fa:	66051a63          	bnez	a0,ffffffffc020386e <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02031fe:	4505                	li	a0,1
ffffffffc0203200:	97fff0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0203204:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203206:	00093503          	ld	a0,0(s2)
ffffffffc020320a:	4681                	li	a3,0
ffffffffc020320c:	4601                	li	a2,0
ffffffffc020320e:	85d2                	mv	a1,s4
ffffffffc0203210:	d65ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc0203214:	62051d63          	bnez	a0,ffffffffc020384e <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203218:	00093503          	ld	a0,0(s2)
ffffffffc020321c:	4601                	li	a2,0
ffffffffc020321e:	4581                	li	a1,0
ffffffffc0203220:	a6bff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc0203224:	60050563          	beqz	a0,ffffffffc020382e <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0203228:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020322a:	0017f713          	andi	a4,a5,1
ffffffffc020322e:	5e070e63          	beqz	a4,ffffffffc020382a <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203232:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203234:	078a                	slli	a5,a5,0x2
ffffffffc0203236:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203238:	56c7ff63          	bgeu	a5,a2,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020323c:	fff80737          	lui	a4,0xfff80
ffffffffc0203240:	97ba                	add	a5,a5,a4
ffffffffc0203242:	000b3683          	ld	a3,0(s6)
ffffffffc0203246:	00379713          	slli	a4,a5,0x3
ffffffffc020324a:	97ba                	add	a5,a5,a4
ffffffffc020324c:	078e                	slli	a5,a5,0x3
ffffffffc020324e:	97b6                	add	a5,a5,a3
ffffffffc0203250:	14fa18e3          	bne	s4,a5,ffffffffc0203ba0 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0203254:	000a2703          	lw	a4,0(s4)
ffffffffc0203258:	4785                	li	a5,1
ffffffffc020325a:	16f71fe3          	bne	a4,a5,ffffffffc0203bd8 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020325e:	00093503          	ld	a0,0(s2)
ffffffffc0203262:	77fd                	lui	a5,0xfffff
ffffffffc0203264:	6114                	ld	a3,0(a0)
ffffffffc0203266:	068a                	slli	a3,a3,0x2
ffffffffc0203268:	8efd                	and	a3,a3,a5
ffffffffc020326a:	00c6d713          	srli	a4,a3,0xc
ffffffffc020326e:	14c779e3          	bgeu	a4,a2,ffffffffc0203bc0 <pmm_init+0xb4c>
ffffffffc0203272:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203276:	96e2                	add	a3,a3,s8
ffffffffc0203278:	0006ba83          	ld	s5,0(a3)
ffffffffc020327c:	0a8a                	slli	s5,s5,0x2
ffffffffc020327e:	00fafab3          	and	s5,s5,a5
ffffffffc0203282:	00cad793          	srli	a5,s5,0xc
ffffffffc0203286:	66c7f463          	bgeu	a5,a2,ffffffffc02038ee <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020328a:	4601                	li	a2,0
ffffffffc020328c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020328e:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203290:	9fbff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203294:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203296:	63551c63          	bne	a0,s5,ffffffffc02038ce <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc020329a:	4505                	li	a0,1
ffffffffc020329c:	8e3ff0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02032a0:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032a2:	00093503          	ld	a0,0(s2)
ffffffffc02032a6:	46d1                	li	a3,20
ffffffffc02032a8:	6605                	lui	a2,0x1
ffffffffc02032aa:	85d6                	mv	a1,s5
ffffffffc02032ac:	cc9ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc02032b0:	5c051f63          	bnez	a0,ffffffffc020388e <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02032b4:	00093503          	ld	a0,0(s2)
ffffffffc02032b8:	4601                	li	a2,0
ffffffffc02032ba:	6585                	lui	a1,0x1
ffffffffc02032bc:	9cfff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc02032c0:	12050ce3          	beqz	a0,ffffffffc0203bf8 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc02032c4:	611c                	ld	a5,0(a0)
ffffffffc02032c6:	0107f713          	andi	a4,a5,16
ffffffffc02032ca:	72070f63          	beqz	a4,ffffffffc0203a08 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc02032ce:	8b91                	andi	a5,a5,4
ffffffffc02032d0:	6e078c63          	beqz	a5,ffffffffc02039c8 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02032d4:	00093503          	ld	a0,0(s2)
ffffffffc02032d8:	611c                	ld	a5,0(a0)
ffffffffc02032da:	8bc1                	andi	a5,a5,16
ffffffffc02032dc:	6c078663          	beqz	a5,ffffffffc02039a8 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02032e0:	000aa703          	lw	a4,0(s5)
ffffffffc02032e4:	4785                	li	a5,1
ffffffffc02032e6:	5cf71463          	bne	a4,a5,ffffffffc02038ae <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02032ea:	4681                	li	a3,0
ffffffffc02032ec:	6605                	lui	a2,0x1
ffffffffc02032ee:	85d2                	mv	a1,s4
ffffffffc02032f0:	c85ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc02032f4:	66051a63          	bnez	a0,ffffffffc0203968 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02032f8:	000a2703          	lw	a4,0(s4)
ffffffffc02032fc:	4789                	li	a5,2
ffffffffc02032fe:	64f71563          	bne	a4,a5,ffffffffc0203948 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0203302:	000aa783          	lw	a5,0(s5)
ffffffffc0203306:	62079163          	bnez	a5,ffffffffc0203928 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020330a:	00093503          	ld	a0,0(s2)
ffffffffc020330e:	4601                	li	a2,0
ffffffffc0203310:	6585                	lui	a1,0x1
ffffffffc0203312:	979ff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc0203316:	5e050963          	beqz	a0,ffffffffc0203908 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc020331a:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020331c:	00177793          	andi	a5,a4,1
ffffffffc0203320:	50078563          	beqz	a5,ffffffffc020382a <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203324:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203326:	00271793          	slli	a5,a4,0x2
ffffffffc020332a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020332c:	48d7f563          	bgeu	a5,a3,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203330:	fff806b7          	lui	a3,0xfff80
ffffffffc0203334:	97b6                	add	a5,a5,a3
ffffffffc0203336:	000b3603          	ld	a2,0(s6)
ffffffffc020333a:	00379693          	slli	a3,a5,0x3
ffffffffc020333e:	97b6                	add	a5,a5,a3
ffffffffc0203340:	078e                	slli	a5,a5,0x3
ffffffffc0203342:	97b2                	add	a5,a5,a2
ffffffffc0203344:	72fa1263          	bne	s4,a5,ffffffffc0203a68 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203348:	8b41                	andi	a4,a4,16
ffffffffc020334a:	6e071f63          	bnez	a4,ffffffffc0203a48 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc020334e:	00093503          	ld	a0,0(s2)
ffffffffc0203352:	4581                	li	a1,0
ffffffffc0203354:	b87ff0ef          	jal	ra,ffffffffc0202eda <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203358:	000a2703          	lw	a4,0(s4)
ffffffffc020335c:	4785                	li	a5,1
ffffffffc020335e:	6cf71563          	bne	a4,a5,ffffffffc0203a28 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0203362:	000aa783          	lw	a5,0(s5)
ffffffffc0203366:	78079d63          	bnez	a5,ffffffffc0203b00 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020336a:	00093503          	ld	a0,0(s2)
ffffffffc020336e:	6585                	lui	a1,0x1
ffffffffc0203370:	b6bff0ef          	jal	ra,ffffffffc0202eda <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203374:	000a2783          	lw	a5,0(s4)
ffffffffc0203378:	76079463          	bnez	a5,ffffffffc0203ae0 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc020337c:	000aa783          	lw	a5,0(s5)
ffffffffc0203380:	74079063          	bnez	a5,ffffffffc0203ac0 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203384:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203388:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020338a:	000a3783          	ld	a5,0(s4)
ffffffffc020338e:	078a                	slli	a5,a5,0x2
ffffffffc0203390:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203392:	42c7f263          	bgeu	a5,a2,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203396:	fff80737          	lui	a4,0xfff80
ffffffffc020339a:	973e                	add	a4,a4,a5
ffffffffc020339c:	00371793          	slli	a5,a4,0x3
ffffffffc02033a0:	000b3503          	ld	a0,0(s6)
ffffffffc02033a4:	97ba                	add	a5,a5,a4
ffffffffc02033a6:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc02033a8:	00f50733          	add	a4,a0,a5
ffffffffc02033ac:	4314                	lw	a3,0(a4)
ffffffffc02033ae:	4705                	li	a4,1
ffffffffc02033b0:	6ee69863          	bne	a3,a4,ffffffffc0203aa0 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033b4:	4037d693          	srai	a3,a5,0x3
ffffffffc02033b8:	00003c97          	auipc	s9,0x3
ffffffffc02033bc:	078cbc83          	ld	s9,120(s9) # ffffffffc0206430 <error_string+0x38>
ffffffffc02033c0:	039686b3          	mul	a3,a3,s9
ffffffffc02033c4:	000805b7          	lui	a1,0x80
ffffffffc02033c8:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033ca:	00c69713          	slli	a4,a3,0xc
ffffffffc02033ce:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02033d0:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033d2:	6ac77b63          	bgeu	a4,a2,ffffffffc0203a88 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02033d6:	0009b703          	ld	a4,0(s3)
ffffffffc02033da:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02033dc:	629c                	ld	a5,0(a3)
ffffffffc02033de:	078a                	slli	a5,a5,0x2
ffffffffc02033e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033e2:	3cc7fa63          	bgeu	a5,a2,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033e6:	8f8d                	sub	a5,a5,a1
ffffffffc02033e8:	00379713          	slli	a4,a5,0x3
ffffffffc02033ec:	97ba                	add	a5,a5,a4
ffffffffc02033ee:	078e                	slli	a5,a5,0x3
ffffffffc02033f0:	953e                	add	a0,a0,a5
ffffffffc02033f2:	100027f3          	csrr	a5,sstatus
ffffffffc02033f6:	8b89                	andi	a5,a5,2
ffffffffc02033f8:	2e079963          	bnez	a5,ffffffffc02036ea <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02033fc:	000bb783          	ld	a5,0(s7)
ffffffffc0203400:	4585                	li	a1,1
ffffffffc0203402:	739c                	ld	a5,32(a5)
ffffffffc0203404:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203406:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020340a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020340c:	078a                	slli	a5,a5,0x2
ffffffffc020340e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203410:	3ae7f363          	bgeu	a5,a4,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203414:	fff80737          	lui	a4,0xfff80
ffffffffc0203418:	97ba                	add	a5,a5,a4
ffffffffc020341a:	000b3503          	ld	a0,0(s6)
ffffffffc020341e:	00379713          	slli	a4,a5,0x3
ffffffffc0203422:	97ba                	add	a5,a5,a4
ffffffffc0203424:	078e                	slli	a5,a5,0x3
ffffffffc0203426:	953e                	add	a0,a0,a5
ffffffffc0203428:	100027f3          	csrr	a5,sstatus
ffffffffc020342c:	8b89                	andi	a5,a5,2
ffffffffc020342e:	2a079263          	bnez	a5,ffffffffc02036d2 <pmm_init+0x65e>
ffffffffc0203432:	000bb783          	ld	a5,0(s7)
ffffffffc0203436:	4585                	li	a1,1
ffffffffc0203438:	739c                	ld	a5,32(a5)
ffffffffc020343a:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020343c:	00093783          	ld	a5,0(s2)
ffffffffc0203440:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc0203444:	100027f3          	csrr	a5,sstatus
ffffffffc0203448:	8b89                	andi	a5,a5,2
ffffffffc020344a:	26079a63          	bnez	a5,ffffffffc02036be <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020344e:	000bb783          	ld	a5,0(s7)
ffffffffc0203452:	779c                	ld	a5,40(a5)
ffffffffc0203454:	9782                	jalr	a5
ffffffffc0203456:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203458:	73441463          	bne	s0,s4,ffffffffc0203b80 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020345c:	00003517          	auipc	a0,0x3
ffffffffc0203460:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0205f68 <default_pmm_manager+0x408>
ffffffffc0203464:	c57fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203468:	100027f3          	csrr	a5,sstatus
ffffffffc020346c:	8b89                	andi	a5,a5,2
ffffffffc020346e:	22079e63          	bnez	a5,ffffffffc02036aa <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203472:	000bb783          	ld	a5,0(s7)
ffffffffc0203476:	779c                	ld	a5,40(a5)
ffffffffc0203478:	9782                	jalr	a5
ffffffffc020347a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020347c:	6098                	ld	a4,0(s1)
ffffffffc020347e:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203482:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203484:	00c71793          	slli	a5,a4,0xc
ffffffffc0203488:	6a05                	lui	s4,0x1
ffffffffc020348a:	02f47c63          	bgeu	s0,a5,ffffffffc02034c2 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020348e:	00c45793          	srli	a5,s0,0xc
ffffffffc0203492:	00093503          	ld	a0,0(s2)
ffffffffc0203496:	30e7f363          	bgeu	a5,a4,ffffffffc020379c <pmm_init+0x728>
ffffffffc020349a:	0009b583          	ld	a1,0(s3)
ffffffffc020349e:	4601                	li	a2,0
ffffffffc02034a0:	95a2                	add	a1,a1,s0
ffffffffc02034a2:	fe8ff0ef          	jal	ra,ffffffffc0202c8a <get_pte>
ffffffffc02034a6:	2c050b63          	beqz	a0,ffffffffc020377c <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02034aa:	611c                	ld	a5,0(a0)
ffffffffc02034ac:	078a                	slli	a5,a5,0x2
ffffffffc02034ae:	0157f7b3          	and	a5,a5,s5
ffffffffc02034b2:	2a879563          	bne	a5,s0,ffffffffc020375c <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02034b6:	6098                	ld	a4,0(s1)
ffffffffc02034b8:	9452                	add	s0,s0,s4
ffffffffc02034ba:	00c71793          	slli	a5,a4,0xc
ffffffffc02034be:	fcf468e3          	bltu	s0,a5,ffffffffc020348e <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02034c2:	00093783          	ld	a5,0(s2)
ffffffffc02034c6:	639c                	ld	a5,0(a5)
ffffffffc02034c8:	68079c63          	bnez	a5,ffffffffc0203b60 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc02034cc:	4505                	li	a0,1
ffffffffc02034ce:	eb0ff0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc02034d2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02034d4:	00093503          	ld	a0,0(s2)
ffffffffc02034d8:	4699                	li	a3,6
ffffffffc02034da:	10000613          	li	a2,256
ffffffffc02034de:	85d6                	mv	a1,s5
ffffffffc02034e0:	a95ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc02034e4:	64051e63          	bnez	a0,ffffffffc0203b40 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02034e8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc02034ec:	4785                	li	a5,1
ffffffffc02034ee:	62f71963          	bne	a4,a5,ffffffffc0203b20 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034f2:	00093503          	ld	a0,0(s2)
ffffffffc02034f6:	6405                	lui	s0,0x1
ffffffffc02034f8:	4699                	li	a3,6
ffffffffc02034fa:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02034fe:	85d6                	mv	a1,s5
ffffffffc0203500:	a75ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc0203504:	48051263          	bnez	a0,ffffffffc0203988 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0203508:	000aa703          	lw	a4,0(s5)
ffffffffc020350c:	4789                	li	a5,2
ffffffffc020350e:	74f71563          	bne	a4,a5,ffffffffc0203c58 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0203512:	00003597          	auipc	a1,0x3
ffffffffc0203516:	b8e58593          	addi	a1,a1,-1138 # ffffffffc02060a0 <default_pmm_manager+0x540>
ffffffffc020351a:	10000513          	li	a0,256
ffffffffc020351e:	35d000ef          	jal	ra,ffffffffc020407a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203522:	10040593          	addi	a1,s0,256
ffffffffc0203526:	10000513          	li	a0,256
ffffffffc020352a:	363000ef          	jal	ra,ffffffffc020408c <strcmp>
ffffffffc020352e:	70051563          	bnez	a0,ffffffffc0203c38 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203532:	000b3683          	ld	a3,0(s6)
ffffffffc0203536:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020353a:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020353c:	40da86b3          	sub	a3,s5,a3
ffffffffc0203540:	868d                	srai	a3,a3,0x3
ffffffffc0203542:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203546:	609c                	ld	a5,0(s1)
ffffffffc0203548:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020354a:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020354c:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203550:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203552:	52f77b63          	bgeu	a4,a5,ffffffffc0203a88 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203556:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020355a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020355e:	96be                	add	a3,a3,a5
ffffffffc0203560:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb98>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203564:	2e1000ef          	jal	ra,ffffffffc0204044 <strlen>
ffffffffc0203568:	6a051863          	bnez	a0,ffffffffc0203c18 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020356c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203570:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203572:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203576:	078a                	slli	a5,a5,0x2
ffffffffc0203578:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020357a:	22e7fe63          	bgeu	a5,a4,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020357e:	41a787b3          	sub	a5,a5,s10
ffffffffc0203582:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203586:	96be                	add	a3,a3,a5
ffffffffc0203588:	03968cb3          	mul	s9,a3,s9
ffffffffc020358c:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203590:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203592:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203594:	4ee47a63          	bgeu	s0,a4,ffffffffc0203a88 <pmm_init+0xa14>
ffffffffc0203598:	0009b403          	ld	s0,0(s3)
ffffffffc020359c:	9436                	add	s0,s0,a3
ffffffffc020359e:	100027f3          	csrr	a5,sstatus
ffffffffc02035a2:	8b89                	andi	a5,a5,2
ffffffffc02035a4:	1a079163          	bnez	a5,ffffffffc0203746 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc02035a8:	000bb783          	ld	a5,0(s7)
ffffffffc02035ac:	4585                	li	a1,1
ffffffffc02035ae:	8556                	mv	a0,s5
ffffffffc02035b0:	739c                	ld	a5,32(a5)
ffffffffc02035b2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b4:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02035b6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b8:	078a                	slli	a5,a5,0x2
ffffffffc02035ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02035bc:	1ee7fd63          	bgeu	a5,a4,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02035c0:	fff80737          	lui	a4,0xfff80
ffffffffc02035c4:	97ba                	add	a5,a5,a4
ffffffffc02035c6:	000b3503          	ld	a0,0(s6)
ffffffffc02035ca:	00379713          	slli	a4,a5,0x3
ffffffffc02035ce:	97ba                	add	a5,a5,a4
ffffffffc02035d0:	078e                	slli	a5,a5,0x3
ffffffffc02035d2:	953e                	add	a0,a0,a5
ffffffffc02035d4:	100027f3          	csrr	a5,sstatus
ffffffffc02035d8:	8b89                	andi	a5,a5,2
ffffffffc02035da:	14079a63          	bnez	a5,ffffffffc020372e <pmm_init+0x6ba>
ffffffffc02035de:	000bb783          	ld	a5,0(s7)
ffffffffc02035e2:	4585                	li	a1,1
ffffffffc02035e4:	739c                	ld	a5,32(a5)
ffffffffc02035e6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035e8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02035ec:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035ee:	078a                	slli	a5,a5,0x2
ffffffffc02035f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02035f2:	1ce7f263          	bgeu	a5,a4,ffffffffc02037b6 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02035f6:	fff80737          	lui	a4,0xfff80
ffffffffc02035fa:	97ba                	add	a5,a5,a4
ffffffffc02035fc:	000b3503          	ld	a0,0(s6)
ffffffffc0203600:	00379713          	slli	a4,a5,0x3
ffffffffc0203604:	97ba                	add	a5,a5,a4
ffffffffc0203606:	078e                	slli	a5,a5,0x3
ffffffffc0203608:	953e                	add	a0,a0,a5
ffffffffc020360a:	100027f3          	csrr	a5,sstatus
ffffffffc020360e:	8b89                	andi	a5,a5,2
ffffffffc0203610:	10079363          	bnez	a5,ffffffffc0203716 <pmm_init+0x6a2>
ffffffffc0203614:	000bb783          	ld	a5,0(s7)
ffffffffc0203618:	4585                	li	a1,1
ffffffffc020361a:	739c                	ld	a5,32(a5)
ffffffffc020361c:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020361e:	00093783          	ld	a5,0(s2)
ffffffffc0203622:	0007b023          	sd	zero,0(a5)
ffffffffc0203626:	100027f3          	csrr	a5,sstatus
ffffffffc020362a:	8b89                	andi	a5,a5,2
ffffffffc020362c:	0c079b63          	bnez	a5,ffffffffc0203702 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203630:	000bb783          	ld	a5,0(s7)
ffffffffc0203634:	779c                	ld	a5,40(a5)
ffffffffc0203636:	9782                	jalr	a5
ffffffffc0203638:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020363a:	3a8c1763          	bne	s8,s0,ffffffffc02039e8 <pmm_init+0x974>
}
ffffffffc020363e:	7406                	ld	s0,96(sp)
ffffffffc0203640:	70a6                	ld	ra,104(sp)
ffffffffc0203642:	64e6                	ld	s1,88(sp)
ffffffffc0203644:	6946                	ld	s2,80(sp)
ffffffffc0203646:	69a6                	ld	s3,72(sp)
ffffffffc0203648:	6a06                	ld	s4,64(sp)
ffffffffc020364a:	7ae2                	ld	s5,56(sp)
ffffffffc020364c:	7b42                	ld	s6,48(sp)
ffffffffc020364e:	7ba2                	ld	s7,40(sp)
ffffffffc0203650:	7c02                	ld	s8,32(sp)
ffffffffc0203652:	6ce2                	ld	s9,24(sp)
ffffffffc0203654:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203656:	00003517          	auipc	a0,0x3
ffffffffc020365a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0206118 <default_pmm_manager+0x5b8>
}
ffffffffc020365e:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203660:	a5bfc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203664:	6705                	lui	a4,0x1
ffffffffc0203666:	177d                	addi	a4,a4,-1
ffffffffc0203668:	96ba                	add	a3,a3,a4
ffffffffc020366a:	777d                	lui	a4,0xfffff
ffffffffc020366c:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc020366e:	00c75693          	srli	a3,a4,0xc
ffffffffc0203672:	14f6f263          	bgeu	a3,a5,ffffffffc02037b6 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0203676:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020367a:	95b6                	add	a1,a1,a3
ffffffffc020367c:	00359793          	slli	a5,a1,0x3
ffffffffc0203680:	97ae                	add	a5,a5,a1
ffffffffc0203682:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203686:	40e60733          	sub	a4,a2,a4
ffffffffc020368a:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020368c:	00c75593          	srli	a1,a4,0xc
ffffffffc0203690:	953e                	add	a0,a0,a5
ffffffffc0203692:	9682                	jalr	a3
}
ffffffffc0203694:	bcc5                	j	ffffffffc0203184 <pmm_init+0x110>
        intr_disable();
ffffffffc0203696:	e59fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020369a:	000bb783          	ld	a5,0(s7)
ffffffffc020369e:	779c                	ld	a5,40(a5)
ffffffffc02036a0:	9782                	jalr	a5
ffffffffc02036a2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036a4:	e45fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036a8:	b63d                	j	ffffffffc02031d6 <pmm_init+0x162>
        intr_disable();
ffffffffc02036aa:	e45fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036ae:	000bb783          	ld	a5,0(s7)
ffffffffc02036b2:	779c                	ld	a5,40(a5)
ffffffffc02036b4:	9782                	jalr	a5
ffffffffc02036b6:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02036b8:	e31fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036bc:	b3c1                	j	ffffffffc020347c <pmm_init+0x408>
        intr_disable();
ffffffffc02036be:	e31fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036c2:	000bb783          	ld	a5,0(s7)
ffffffffc02036c6:	779c                	ld	a5,40(a5)
ffffffffc02036c8:	9782                	jalr	a5
ffffffffc02036ca:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02036cc:	e1dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036d0:	b361                	j	ffffffffc0203458 <pmm_init+0x3e4>
ffffffffc02036d2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036d4:	e1bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02036d8:	000bb783          	ld	a5,0(s7)
ffffffffc02036dc:	6522                	ld	a0,8(sp)
ffffffffc02036de:	4585                	li	a1,1
ffffffffc02036e0:	739c                	ld	a5,32(a5)
ffffffffc02036e2:	9782                	jalr	a5
        intr_enable();
ffffffffc02036e4:	e05fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036e8:	bb91                	j	ffffffffc020343c <pmm_init+0x3c8>
ffffffffc02036ea:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036ec:	e03fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036f0:	000bb783          	ld	a5,0(s7)
ffffffffc02036f4:	6522                	ld	a0,8(sp)
ffffffffc02036f6:	4585                	li	a1,1
ffffffffc02036f8:	739c                	ld	a5,32(a5)
ffffffffc02036fa:	9782                	jalr	a5
        intr_enable();
ffffffffc02036fc:	dedfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203700:	b319                	j	ffffffffc0203406 <pmm_init+0x392>
        intr_disable();
ffffffffc0203702:	dedfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203706:	000bb783          	ld	a5,0(s7)
ffffffffc020370a:	779c                	ld	a5,40(a5)
ffffffffc020370c:	9782                	jalr	a5
ffffffffc020370e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203710:	dd9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203714:	b71d                	j	ffffffffc020363a <pmm_init+0x5c6>
ffffffffc0203716:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203718:	dd7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020371c:	000bb783          	ld	a5,0(s7)
ffffffffc0203720:	6522                	ld	a0,8(sp)
ffffffffc0203722:	4585                	li	a1,1
ffffffffc0203724:	739c                	ld	a5,32(a5)
ffffffffc0203726:	9782                	jalr	a5
        intr_enable();
ffffffffc0203728:	dc1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020372c:	bdcd                	j	ffffffffc020361e <pmm_init+0x5aa>
ffffffffc020372e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203730:	dbffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203734:	000bb783          	ld	a5,0(s7)
ffffffffc0203738:	6522                	ld	a0,8(sp)
ffffffffc020373a:	4585                	li	a1,1
ffffffffc020373c:	739c                	ld	a5,32(a5)
ffffffffc020373e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203740:	da9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203744:	b555                	j	ffffffffc02035e8 <pmm_init+0x574>
        intr_disable();
ffffffffc0203746:	da9fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020374a:	000bb783          	ld	a5,0(s7)
ffffffffc020374e:	4585                	li	a1,1
ffffffffc0203750:	8556                	mv	a0,s5
ffffffffc0203752:	739c                	ld	a5,32(a5)
ffffffffc0203754:	9782                	jalr	a5
        intr_enable();
ffffffffc0203756:	d93fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020375a:	bda9                	j	ffffffffc02035b4 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020375c:	00003697          	auipc	a3,0x3
ffffffffc0203760:	86c68693          	addi	a3,a3,-1940 # ffffffffc0205fc8 <default_pmm_manager+0x468>
ffffffffc0203764:	00001617          	auipc	a2,0x1
ffffffffc0203768:	7ec60613          	addi	a2,a2,2028 # ffffffffc0204f50 <commands+0x748>
ffffffffc020376c:	1ce00593          	li	a1,462
ffffffffc0203770:	00002517          	auipc	a0,0x2
ffffffffc0203774:	45050513          	addi	a0,a0,1104 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203778:	98bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020377c:	00003697          	auipc	a3,0x3
ffffffffc0203780:	80c68693          	addi	a3,a3,-2036 # ffffffffc0205f88 <default_pmm_manager+0x428>
ffffffffc0203784:	00001617          	auipc	a2,0x1
ffffffffc0203788:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204f50 <commands+0x748>
ffffffffc020378c:	1cd00593          	li	a1,461
ffffffffc0203790:	00002517          	auipc	a0,0x2
ffffffffc0203794:	43050513          	addi	a0,a0,1072 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203798:	96bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020379c:	86a2                	mv	a3,s0
ffffffffc020379e:	00002617          	auipc	a2,0x2
ffffffffc02037a2:	3fa60613          	addi	a2,a2,1018 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc02037a6:	1cd00593          	li	a1,461
ffffffffc02037aa:	00002517          	auipc	a0,0x2
ffffffffc02037ae:	41650513          	addi	a0,a0,1046 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02037b2:	951fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02037b6:	b90ff0ef          	jal	ra,ffffffffc0202b46 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02037ba:	00002617          	auipc	a2,0x2
ffffffffc02037be:	49e60613          	addi	a2,a2,1182 # ffffffffc0205c58 <default_pmm_manager+0xf8>
ffffffffc02037c2:	07700593          	li	a1,119
ffffffffc02037c6:	00002517          	auipc	a0,0x2
ffffffffc02037ca:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02037ce:	935fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02037d2:	00002617          	auipc	a2,0x2
ffffffffc02037d6:	48660613          	addi	a2,a2,1158 # ffffffffc0205c58 <default_pmm_manager+0xf8>
ffffffffc02037da:	0bd00593          	li	a1,189
ffffffffc02037de:	00002517          	auipc	a0,0x2
ffffffffc02037e2:	3e250513          	addi	a0,a0,994 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02037e6:	91dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02037ea:	00002697          	auipc	a3,0x2
ffffffffc02037ee:	4d668693          	addi	a3,a3,1238 # ffffffffc0205cc0 <default_pmm_manager+0x160>
ffffffffc02037f2:	00001617          	auipc	a2,0x1
ffffffffc02037f6:	75e60613          	addi	a2,a2,1886 # ffffffffc0204f50 <commands+0x748>
ffffffffc02037fa:	19300593          	li	a1,403
ffffffffc02037fe:	00002517          	auipc	a0,0x2
ffffffffc0203802:	3c250513          	addi	a0,a0,962 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203806:	8fdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020380a:	00002697          	auipc	a3,0x2
ffffffffc020380e:	49668693          	addi	a3,a3,1174 # ffffffffc0205ca0 <default_pmm_manager+0x140>
ffffffffc0203812:	00001617          	auipc	a2,0x1
ffffffffc0203816:	73e60613          	addi	a2,a2,1854 # ffffffffc0204f50 <commands+0x748>
ffffffffc020381a:	19200593          	li	a1,402
ffffffffc020381e:	00002517          	auipc	a0,0x2
ffffffffc0203822:	3a250513          	addi	a0,a0,930 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203826:	8ddfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020382a:	b38ff0ef          	jal	ra,ffffffffc0202b62 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020382e:	00002697          	auipc	a3,0x2
ffffffffc0203832:	52268693          	addi	a3,a3,1314 # ffffffffc0205d50 <default_pmm_manager+0x1f0>
ffffffffc0203836:	00001617          	auipc	a2,0x1
ffffffffc020383a:	71a60613          	addi	a2,a2,1818 # ffffffffc0204f50 <commands+0x748>
ffffffffc020383e:	19a00593          	li	a1,410
ffffffffc0203842:	00002517          	auipc	a0,0x2
ffffffffc0203846:	37e50513          	addi	a0,a0,894 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc020384a:	8b9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020384e:	00002697          	auipc	a3,0x2
ffffffffc0203852:	4d268693          	addi	a3,a3,1234 # ffffffffc0205d20 <default_pmm_manager+0x1c0>
ffffffffc0203856:	00001617          	auipc	a2,0x1
ffffffffc020385a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0204f50 <commands+0x748>
ffffffffc020385e:	19800593          	li	a1,408
ffffffffc0203862:	00002517          	auipc	a0,0x2
ffffffffc0203866:	35e50513          	addi	a0,a0,862 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc020386a:	899fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020386e:	00002697          	auipc	a3,0x2
ffffffffc0203872:	48a68693          	addi	a3,a3,1162 # ffffffffc0205cf8 <default_pmm_manager+0x198>
ffffffffc0203876:	00001617          	auipc	a2,0x1
ffffffffc020387a:	6da60613          	addi	a2,a2,1754 # ffffffffc0204f50 <commands+0x748>
ffffffffc020387e:	19400593          	li	a1,404
ffffffffc0203882:	00002517          	auipc	a0,0x2
ffffffffc0203886:	33e50513          	addi	a0,a0,830 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc020388a:	879fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020388e:	00002697          	auipc	a3,0x2
ffffffffc0203892:	54a68693          	addi	a3,a3,1354 # ffffffffc0205dd8 <default_pmm_manager+0x278>
ffffffffc0203896:	00001617          	auipc	a2,0x1
ffffffffc020389a:	6ba60613          	addi	a2,a2,1722 # ffffffffc0204f50 <commands+0x748>
ffffffffc020389e:	1a300593          	li	a1,419
ffffffffc02038a2:	00002517          	auipc	a0,0x2
ffffffffc02038a6:	31e50513          	addi	a0,a0,798 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02038aa:	859fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02038ae:	00002697          	auipc	a3,0x2
ffffffffc02038b2:	5ca68693          	addi	a3,a3,1482 # ffffffffc0205e78 <default_pmm_manager+0x318>
ffffffffc02038b6:	00001617          	auipc	a2,0x1
ffffffffc02038ba:	69a60613          	addi	a2,a2,1690 # ffffffffc0204f50 <commands+0x748>
ffffffffc02038be:	1a800593          	li	a1,424
ffffffffc02038c2:	00002517          	auipc	a0,0x2
ffffffffc02038c6:	2fe50513          	addi	a0,a0,766 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02038ca:	839fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02038ce:	00002697          	auipc	a3,0x2
ffffffffc02038d2:	4e268693          	addi	a3,a3,1250 # ffffffffc0205db0 <default_pmm_manager+0x250>
ffffffffc02038d6:	00001617          	auipc	a2,0x1
ffffffffc02038da:	67a60613          	addi	a2,a2,1658 # ffffffffc0204f50 <commands+0x748>
ffffffffc02038de:	1a000593          	li	a1,416
ffffffffc02038e2:	00002517          	auipc	a0,0x2
ffffffffc02038e6:	2de50513          	addi	a0,a0,734 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02038ea:	819fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02038ee:	86d6                	mv	a3,s5
ffffffffc02038f0:	00002617          	auipc	a2,0x2
ffffffffc02038f4:	2a860613          	addi	a2,a2,680 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc02038f8:	19f00593          	li	a1,415
ffffffffc02038fc:	00002517          	auipc	a0,0x2
ffffffffc0203900:	2c450513          	addi	a0,a0,708 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203904:	ffefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203908:	00002697          	auipc	a3,0x2
ffffffffc020390c:	50868693          	addi	a3,a3,1288 # ffffffffc0205e10 <default_pmm_manager+0x2b0>
ffffffffc0203910:	00001617          	auipc	a2,0x1
ffffffffc0203914:	64060613          	addi	a2,a2,1600 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203918:	1ad00593          	li	a1,429
ffffffffc020391c:	00002517          	auipc	a0,0x2
ffffffffc0203920:	2a450513          	addi	a0,a0,676 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203924:	fdefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203928:	00002697          	auipc	a3,0x2
ffffffffc020392c:	5b068693          	addi	a3,a3,1456 # ffffffffc0205ed8 <default_pmm_manager+0x378>
ffffffffc0203930:	00001617          	auipc	a2,0x1
ffffffffc0203934:	62060613          	addi	a2,a2,1568 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203938:	1ac00593          	li	a1,428
ffffffffc020393c:	00002517          	auipc	a0,0x2
ffffffffc0203940:	28450513          	addi	a0,a0,644 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203944:	fbefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203948:	00002697          	auipc	a3,0x2
ffffffffc020394c:	57868693          	addi	a3,a3,1400 # ffffffffc0205ec0 <default_pmm_manager+0x360>
ffffffffc0203950:	00001617          	auipc	a2,0x1
ffffffffc0203954:	60060613          	addi	a2,a2,1536 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203958:	1ab00593          	li	a1,427
ffffffffc020395c:	00002517          	auipc	a0,0x2
ffffffffc0203960:	26450513          	addi	a0,a0,612 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203964:	f9efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203968:	00002697          	auipc	a3,0x2
ffffffffc020396c:	52868693          	addi	a3,a3,1320 # ffffffffc0205e90 <default_pmm_manager+0x330>
ffffffffc0203970:	00001617          	auipc	a2,0x1
ffffffffc0203974:	5e060613          	addi	a2,a2,1504 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203978:	1aa00593          	li	a1,426
ffffffffc020397c:	00002517          	auipc	a0,0x2
ffffffffc0203980:	24450513          	addi	a0,a0,580 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203984:	f7efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203988:	00002697          	auipc	a3,0x2
ffffffffc020398c:	6c068693          	addi	a3,a3,1728 # ffffffffc0206048 <default_pmm_manager+0x4e8>
ffffffffc0203990:	00001617          	auipc	a2,0x1
ffffffffc0203994:	5c060613          	addi	a2,a2,1472 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203998:	1d800593          	li	a1,472
ffffffffc020399c:	00002517          	auipc	a0,0x2
ffffffffc02039a0:	22450513          	addi	a0,a0,548 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02039a4:	f5efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02039a8:	00002697          	auipc	a3,0x2
ffffffffc02039ac:	4b868693          	addi	a3,a3,1208 # ffffffffc0205e60 <default_pmm_manager+0x300>
ffffffffc02039b0:	00001617          	auipc	a2,0x1
ffffffffc02039b4:	5a060613          	addi	a2,a2,1440 # ffffffffc0204f50 <commands+0x748>
ffffffffc02039b8:	1a700593          	li	a1,423
ffffffffc02039bc:	00002517          	auipc	a0,0x2
ffffffffc02039c0:	20450513          	addi	a0,a0,516 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02039c4:	f3efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02039c8:	00002697          	auipc	a3,0x2
ffffffffc02039cc:	48868693          	addi	a3,a3,1160 # ffffffffc0205e50 <default_pmm_manager+0x2f0>
ffffffffc02039d0:	00001617          	auipc	a2,0x1
ffffffffc02039d4:	58060613          	addi	a2,a2,1408 # ffffffffc0204f50 <commands+0x748>
ffffffffc02039d8:	1a600593          	li	a1,422
ffffffffc02039dc:	00002517          	auipc	a0,0x2
ffffffffc02039e0:	1e450513          	addi	a0,a0,484 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc02039e4:	f1efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02039e8:	00002697          	auipc	a3,0x2
ffffffffc02039ec:	56068693          	addi	a3,a3,1376 # ffffffffc0205f48 <default_pmm_manager+0x3e8>
ffffffffc02039f0:	00001617          	auipc	a2,0x1
ffffffffc02039f4:	56060613          	addi	a2,a2,1376 # ffffffffc0204f50 <commands+0x748>
ffffffffc02039f8:	1e800593          	li	a1,488
ffffffffc02039fc:	00002517          	auipc	a0,0x2
ffffffffc0203a00:	1c450513          	addi	a0,a0,452 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203a04:	efefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203a08:	00002697          	auipc	a3,0x2
ffffffffc0203a0c:	43868693          	addi	a3,a3,1080 # ffffffffc0205e40 <default_pmm_manager+0x2e0>
ffffffffc0203a10:	00001617          	auipc	a2,0x1
ffffffffc0203a14:	54060613          	addi	a2,a2,1344 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203a18:	1a500593          	li	a1,421
ffffffffc0203a1c:	00002517          	auipc	a0,0x2
ffffffffc0203a20:	1a450513          	addi	a0,a0,420 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203a24:	edefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203a28:	00002697          	auipc	a3,0x2
ffffffffc0203a2c:	37068693          	addi	a3,a3,880 # ffffffffc0205d98 <default_pmm_manager+0x238>
ffffffffc0203a30:	00001617          	auipc	a2,0x1
ffffffffc0203a34:	52060613          	addi	a2,a2,1312 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203a38:	1b200593          	li	a1,434
ffffffffc0203a3c:	00002517          	auipc	a0,0x2
ffffffffc0203a40:	18450513          	addi	a0,a0,388 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203a44:	ebefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203a48:	00002697          	auipc	a3,0x2
ffffffffc0203a4c:	4a868693          	addi	a3,a3,1192 # ffffffffc0205ef0 <default_pmm_manager+0x390>
ffffffffc0203a50:	00001617          	auipc	a2,0x1
ffffffffc0203a54:	50060613          	addi	a2,a2,1280 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203a58:	1af00593          	li	a1,431
ffffffffc0203a5c:	00002517          	auipc	a0,0x2
ffffffffc0203a60:	16450513          	addi	a0,a0,356 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203a64:	e9efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a68:	00002697          	auipc	a3,0x2
ffffffffc0203a6c:	31868693          	addi	a3,a3,792 # ffffffffc0205d80 <default_pmm_manager+0x220>
ffffffffc0203a70:	00001617          	auipc	a2,0x1
ffffffffc0203a74:	4e060613          	addi	a2,a2,1248 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203a78:	1ae00593          	li	a1,430
ffffffffc0203a7c:	00002517          	auipc	a0,0x2
ffffffffc0203a80:	14450513          	addi	a0,a0,324 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203a84:	e7efc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a88:	00002617          	auipc	a2,0x2
ffffffffc0203a8c:	11060613          	addi	a2,a2,272 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0203a90:	06a00593          	li	a1,106
ffffffffc0203a94:	00001517          	auipc	a0,0x1
ffffffffc0203a98:	62c50513          	addi	a0,a0,1580 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0203a9c:	e66fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203aa0:	00002697          	auipc	a3,0x2
ffffffffc0203aa4:	48068693          	addi	a3,a3,1152 # ffffffffc0205f20 <default_pmm_manager+0x3c0>
ffffffffc0203aa8:	00001617          	auipc	a2,0x1
ffffffffc0203aac:	4a860613          	addi	a2,a2,1192 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203ab0:	1b900593          	li	a1,441
ffffffffc0203ab4:	00002517          	auipc	a0,0x2
ffffffffc0203ab8:	10c50513          	addi	a0,a0,268 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203abc:	e46fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203ac0:	00002697          	auipc	a3,0x2
ffffffffc0203ac4:	41868693          	addi	a3,a3,1048 # ffffffffc0205ed8 <default_pmm_manager+0x378>
ffffffffc0203ac8:	00001617          	auipc	a2,0x1
ffffffffc0203acc:	48860613          	addi	a2,a2,1160 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203ad0:	1b700593          	li	a1,439
ffffffffc0203ad4:	00002517          	auipc	a0,0x2
ffffffffc0203ad8:	0ec50513          	addi	a0,a0,236 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203adc:	e26fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203ae0:	00002697          	auipc	a3,0x2
ffffffffc0203ae4:	42868693          	addi	a3,a3,1064 # ffffffffc0205f08 <default_pmm_manager+0x3a8>
ffffffffc0203ae8:	00001617          	auipc	a2,0x1
ffffffffc0203aec:	46860613          	addi	a2,a2,1128 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203af0:	1b600593          	li	a1,438
ffffffffc0203af4:	00002517          	auipc	a0,0x2
ffffffffc0203af8:	0cc50513          	addi	a0,a0,204 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203afc:	e06fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203b00:	00002697          	auipc	a3,0x2
ffffffffc0203b04:	3d868693          	addi	a3,a3,984 # ffffffffc0205ed8 <default_pmm_manager+0x378>
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	44860613          	addi	a2,a2,1096 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203b10:	1b300593          	li	a1,435
ffffffffc0203b14:	00002517          	auipc	a0,0x2
ffffffffc0203b18:	0ac50513          	addi	a0,a0,172 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203b1c:	de6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	51068693          	addi	a3,a3,1296 # ffffffffc0206030 <default_pmm_manager+0x4d0>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	42860613          	addi	a2,a2,1064 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203b30:	1d700593          	li	a1,471
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	08c50513          	addi	a0,a0,140 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203b3c:	dc6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	4b868693          	addi	a3,a3,1208 # ffffffffc0205ff8 <default_pmm_manager+0x498>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	40860613          	addi	a2,a2,1032 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203b50:	1d600593          	li	a1,470
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	06c50513          	addi	a0,a0,108 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203b5c:	da6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203b60:	00002697          	auipc	a3,0x2
ffffffffc0203b64:	48068693          	addi	a3,a3,1152 # ffffffffc0205fe0 <default_pmm_manager+0x480>
ffffffffc0203b68:	00001617          	auipc	a2,0x1
ffffffffc0203b6c:	3e860613          	addi	a2,a2,1000 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203b70:	1d200593          	li	a1,466
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	04c50513          	addi	a0,a0,76 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203b7c:	d86fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203b80:	00002697          	auipc	a3,0x2
ffffffffc0203b84:	3c868693          	addi	a3,a3,968 # ffffffffc0205f48 <default_pmm_manager+0x3e8>
ffffffffc0203b88:	00001617          	auipc	a2,0x1
ffffffffc0203b8c:	3c860613          	addi	a2,a2,968 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203b90:	1c000593          	li	a1,448
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	02c50513          	addi	a0,a0,44 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203b9c:	d66fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	1e068693          	addi	a3,a3,480 # ffffffffc0205d80 <default_pmm_manager+0x220>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	3a860613          	addi	a2,a2,936 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203bb0:	19b00593          	li	a1,411
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	00c50513          	addi	a0,a0,12 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203bbc:	d46fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203bc0:	00002617          	auipc	a2,0x2
ffffffffc0203bc4:	fd860613          	addi	a2,a2,-40 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0203bc8:	19e00593          	li	a1,414
ffffffffc0203bcc:	00002517          	auipc	a0,0x2
ffffffffc0203bd0:	ff450513          	addi	a0,a0,-12 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203bd4:	d2efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203bd8:	00002697          	auipc	a3,0x2
ffffffffc0203bdc:	1c068693          	addi	a3,a3,448 # ffffffffc0205d98 <default_pmm_manager+0x238>
ffffffffc0203be0:	00001617          	auipc	a2,0x1
ffffffffc0203be4:	37060613          	addi	a2,a2,880 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203be8:	19c00593          	li	a1,412
ffffffffc0203bec:	00002517          	auipc	a0,0x2
ffffffffc0203bf0:	fd450513          	addi	a0,a0,-44 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203bf4:	d0efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203bf8:	00002697          	auipc	a3,0x2
ffffffffc0203bfc:	21868693          	addi	a3,a3,536 # ffffffffc0205e10 <default_pmm_manager+0x2b0>
ffffffffc0203c00:	00001617          	auipc	a2,0x1
ffffffffc0203c04:	35060613          	addi	a2,a2,848 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203c08:	1a400593          	li	a1,420
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	fb450513          	addi	a0,a0,-76 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203c14:	ceefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203c18:	00002697          	auipc	a3,0x2
ffffffffc0203c1c:	4d868693          	addi	a3,a3,1240 # ffffffffc02060f0 <default_pmm_manager+0x590>
ffffffffc0203c20:	00001617          	auipc	a2,0x1
ffffffffc0203c24:	33060613          	addi	a2,a2,816 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203c28:	1e000593          	li	a1,480
ffffffffc0203c2c:	00002517          	auipc	a0,0x2
ffffffffc0203c30:	f9450513          	addi	a0,a0,-108 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203c34:	ccefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203c38:	00002697          	auipc	a3,0x2
ffffffffc0203c3c:	48068693          	addi	a3,a3,1152 # ffffffffc02060b8 <default_pmm_manager+0x558>
ffffffffc0203c40:	00001617          	auipc	a2,0x1
ffffffffc0203c44:	31060613          	addi	a2,a2,784 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203c48:	1dd00593          	li	a1,477
ffffffffc0203c4c:	00002517          	auipc	a0,0x2
ffffffffc0203c50:	f7450513          	addi	a0,a0,-140 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203c54:	caefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c58:	00002697          	auipc	a3,0x2
ffffffffc0203c5c:	43068693          	addi	a3,a3,1072 # ffffffffc0206088 <default_pmm_manager+0x528>
ffffffffc0203c60:	00001617          	auipc	a2,0x1
ffffffffc0203c64:	2f060613          	addi	a2,a2,752 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203c68:	1d900593          	li	a1,473
ffffffffc0203c6c:	00002517          	auipc	a0,0x2
ffffffffc0203c70:	f5450513          	addi	a0,a0,-172 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203c74:	c8efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c78 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203c78:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203c7c:	8082                	ret

ffffffffc0203c7e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c7e:	7179                	addi	sp,sp,-48
ffffffffc0203c80:	e84a                	sd	s2,16(sp)
ffffffffc0203c82:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203c84:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c86:	f022                	sd	s0,32(sp)
ffffffffc0203c88:	ec26                	sd	s1,24(sp)
ffffffffc0203c8a:	e44e                	sd	s3,8(sp)
ffffffffc0203c8c:	f406                	sd	ra,40(sp)
ffffffffc0203c8e:	84ae                	mv	s1,a1
ffffffffc0203c90:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203c92:	eedfe0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
ffffffffc0203c96:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203c98:	cd09                	beqz	a0,ffffffffc0203cb2 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203c9a:	85aa                	mv	a1,a0
ffffffffc0203c9c:	86ce                	mv	a3,s3
ffffffffc0203c9e:	8626                	mv	a2,s1
ffffffffc0203ca0:	854a                	mv	a0,s2
ffffffffc0203ca2:	ad2ff0ef          	jal	ra,ffffffffc0202f74 <page_insert>
ffffffffc0203ca6:	ed21                	bnez	a0,ffffffffc0203cfe <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203ca8:	0000e797          	auipc	a5,0xe
ffffffffc0203cac:	8887a783          	lw	a5,-1912(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0203cb0:	eb89                	bnez	a5,ffffffffc0203cc2 <pgdir_alloc_page+0x44>
}
ffffffffc0203cb2:	70a2                	ld	ra,40(sp)
ffffffffc0203cb4:	8522                	mv	a0,s0
ffffffffc0203cb6:	7402                	ld	s0,32(sp)
ffffffffc0203cb8:	64e2                	ld	s1,24(sp)
ffffffffc0203cba:	6942                	ld	s2,16(sp)
ffffffffc0203cbc:	69a2                	ld	s3,8(sp)
ffffffffc0203cbe:	6145                	addi	sp,sp,48
ffffffffc0203cc0:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203cc2:	4681                	li	a3,0
ffffffffc0203cc4:	8622                	mv	a2,s0
ffffffffc0203cc6:	85a6                	mv	a1,s1
ffffffffc0203cc8:	0000e517          	auipc	a0,0xe
ffffffffc0203ccc:	84853503          	ld	a0,-1976(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0203cd0:	a04fe0ef          	jal	ra,ffffffffc0201ed4 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203cd4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203cd6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203cd8:	4785                	li	a5,1
ffffffffc0203cda:	fcf70ce3          	beq	a4,a5,ffffffffc0203cb2 <pgdir_alloc_page+0x34>
ffffffffc0203cde:	00002697          	auipc	a3,0x2
ffffffffc0203ce2:	45a68693          	addi	a3,a3,1114 # ffffffffc0206138 <default_pmm_manager+0x5d8>
ffffffffc0203ce6:	00001617          	auipc	a2,0x1
ffffffffc0203cea:	26a60613          	addi	a2,a2,618 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203cee:	17a00593          	li	a1,378
ffffffffc0203cf2:	00002517          	auipc	a0,0x2
ffffffffc0203cf6:	ece50513          	addi	a0,a0,-306 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203cfa:	c08fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cfe:	100027f3          	csrr	a5,sstatus
ffffffffc0203d02:	8b89                	andi	a5,a5,2
ffffffffc0203d04:	eb99                	bnez	a5,ffffffffc0203d1a <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d06:	0000e797          	auipc	a5,0xe
ffffffffc0203d0a:	8527b783          	ld	a5,-1966(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203d0e:	739c                	ld	a5,32(a5)
ffffffffc0203d10:	8522                	mv	a0,s0
ffffffffc0203d12:	4585                	li	a1,1
ffffffffc0203d14:	9782                	jalr	a5
            return NULL;
ffffffffc0203d16:	4401                	li	s0,0
ffffffffc0203d18:	bf69                	j	ffffffffc0203cb2 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203d1a:	fd4fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d1e:	0000e797          	auipc	a5,0xe
ffffffffc0203d22:	83a7b783          	ld	a5,-1990(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203d26:	739c                	ld	a5,32(a5)
ffffffffc0203d28:	8522                	mv	a0,s0
ffffffffc0203d2a:	4585                	li	a1,1
ffffffffc0203d2c:	9782                	jalr	a5
            return NULL;
ffffffffc0203d2e:	4401                	li	s0,0
        intr_enable();
ffffffffc0203d30:	fb8fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203d34:	bfbd                	j	ffffffffc0203cb2 <pgdir_alloc_page+0x34>

ffffffffc0203d36 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203d36:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d38:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203d3a:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d3c:	fff50713          	addi	a4,a0,-1
ffffffffc0203d40:	17f9                	addi	a5,a5,-2
ffffffffc0203d42:	04e7ea63          	bltu	a5,a4,ffffffffc0203d96 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203d46:	6785                	lui	a5,0x1
ffffffffc0203d48:	17fd                	addi	a5,a5,-1
ffffffffc0203d4a:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203d4c:	8131                	srli	a0,a0,0xc
ffffffffc0203d4e:	e31fe0ef          	jal	ra,ffffffffc0202b7e <alloc_pages>
    assert(base != NULL);
ffffffffc0203d52:	cd3d                	beqz	a0,ffffffffc0203dd0 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d54:	0000d797          	auipc	a5,0xd
ffffffffc0203d58:	7fc7b783          	ld	a5,2044(a5) # ffffffffc0211550 <pages>
ffffffffc0203d5c:	8d1d                	sub	a0,a0,a5
ffffffffc0203d5e:	00002697          	auipc	a3,0x2
ffffffffc0203d62:	6d26b683          	ld	a3,1746(a3) # ffffffffc0206430 <error_string+0x38>
ffffffffc0203d66:	850d                	srai	a0,a0,0x3
ffffffffc0203d68:	02d50533          	mul	a0,a0,a3
ffffffffc0203d6c:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d70:	0000d717          	auipc	a4,0xd
ffffffffc0203d74:	7d873703          	ld	a4,2008(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d78:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d7a:	00c51793          	slli	a5,a0,0xc
ffffffffc0203d7e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d80:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d82:	02e7fa63          	bgeu	a5,a4,ffffffffc0203db6 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203d86:	60a2                	ld	ra,8(sp)
ffffffffc0203d88:	0000d797          	auipc	a5,0xd
ffffffffc0203d8c:	7d87b783          	ld	a5,2008(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203d90:	953e                	add	a0,a0,a5
ffffffffc0203d92:	0141                	addi	sp,sp,16
ffffffffc0203d94:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d96:	00002697          	auipc	a3,0x2
ffffffffc0203d9a:	3ba68693          	addi	a3,a3,954 # ffffffffc0206150 <default_pmm_manager+0x5f0>
ffffffffc0203d9e:	00001617          	auipc	a2,0x1
ffffffffc0203da2:	1b260613          	addi	a2,a2,434 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203da6:	1f000593          	li	a1,496
ffffffffc0203daa:	00002517          	auipc	a0,0x2
ffffffffc0203dae:	e1650513          	addi	a0,a0,-490 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203db2:	b50fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203db6:	86aa                	mv	a3,a0
ffffffffc0203db8:	00002617          	auipc	a2,0x2
ffffffffc0203dbc:	de060613          	addi	a2,a2,-544 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0203dc0:	06a00593          	li	a1,106
ffffffffc0203dc4:	00001517          	auipc	a0,0x1
ffffffffc0203dc8:	2fc50513          	addi	a0,a0,764 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0203dcc:	b36fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203dd0:	00002697          	auipc	a3,0x2
ffffffffc0203dd4:	3a068693          	addi	a3,a3,928 # ffffffffc0206170 <default_pmm_manager+0x610>
ffffffffc0203dd8:	00001617          	auipc	a2,0x1
ffffffffc0203ddc:	17860613          	addi	a2,a2,376 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203de0:	1f300593          	li	a1,499
ffffffffc0203de4:	00002517          	auipc	a0,0x2
ffffffffc0203de8:	ddc50513          	addi	a0,a0,-548 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203dec:	b16fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203df0 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203df0:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203df2:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203df4:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203df6:	fff58713          	addi	a4,a1,-1
ffffffffc0203dfa:	17f9                	addi	a5,a5,-2
ffffffffc0203dfc:	0ae7ee63          	bltu	a5,a4,ffffffffc0203eb8 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203e00:	cd41                	beqz	a0,ffffffffc0203e98 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203e02:	6785                	lui	a5,0x1
ffffffffc0203e04:	17fd                	addi	a5,a5,-1
ffffffffc0203e06:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203e08:	c02007b7          	lui	a5,0xc0200
ffffffffc0203e0c:	81b1                	srli	a1,a1,0xc
ffffffffc0203e0e:	06f56863          	bltu	a0,a5,ffffffffc0203e7e <kfree+0x8e>
ffffffffc0203e12:	0000d697          	auipc	a3,0xd
ffffffffc0203e16:	74e6b683          	ld	a3,1870(a3) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203e1a:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203e1c:	8131                	srli	a0,a0,0xc
ffffffffc0203e1e:	0000d797          	auipc	a5,0xd
ffffffffc0203e22:	72a7b783          	ld	a5,1834(a5) # ffffffffc0211548 <npage>
ffffffffc0203e26:	04f57a63          	bgeu	a0,a5,ffffffffc0203e7a <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e2a:	fff806b7          	lui	a3,0xfff80
ffffffffc0203e2e:	9536                	add	a0,a0,a3
ffffffffc0203e30:	00351793          	slli	a5,a0,0x3
ffffffffc0203e34:	953e                	add	a0,a0,a5
ffffffffc0203e36:	050e                	slli	a0,a0,0x3
ffffffffc0203e38:	0000d797          	auipc	a5,0xd
ffffffffc0203e3c:	7187b783          	ld	a5,1816(a5) # ffffffffc0211550 <pages>
ffffffffc0203e40:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e42:	100027f3          	csrr	a5,sstatus
ffffffffc0203e46:	8b89                	andi	a5,a5,2
ffffffffc0203e48:	eb89                	bnez	a5,ffffffffc0203e5a <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e4a:	0000d797          	auipc	a5,0xd
ffffffffc0203e4e:	70e7b783          	ld	a5,1806(a5) # ffffffffc0211558 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203e52:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e54:	739c                	ld	a5,32(a5)
}
ffffffffc0203e56:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e58:	8782                	jr	a5
        intr_disable();
ffffffffc0203e5a:	e42a                	sd	a0,8(sp)
ffffffffc0203e5c:	e02e                	sd	a1,0(sp)
ffffffffc0203e5e:	e90fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203e62:	0000d797          	auipc	a5,0xd
ffffffffc0203e66:	6f67b783          	ld	a5,1782(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203e6a:	6582                	ld	a1,0(sp)
ffffffffc0203e6c:	6522                	ld	a0,8(sp)
ffffffffc0203e6e:	739c                	ld	a5,32(a5)
ffffffffc0203e70:	9782                	jalr	a5
}
ffffffffc0203e72:	60e2                	ld	ra,24(sp)
ffffffffc0203e74:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203e76:	e72fc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203e7a:	ccdfe0ef          	jal	ra,ffffffffc0202b46 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203e7e:	86aa                	mv	a3,a0
ffffffffc0203e80:	00002617          	auipc	a2,0x2
ffffffffc0203e84:	dd860613          	addi	a2,a2,-552 # ffffffffc0205c58 <default_pmm_manager+0xf8>
ffffffffc0203e88:	06c00593          	li	a1,108
ffffffffc0203e8c:	00001517          	auipc	a0,0x1
ffffffffc0203e90:	23450513          	addi	a0,a0,564 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0203e94:	a6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203e98:	00002697          	auipc	a3,0x2
ffffffffc0203e9c:	2e868693          	addi	a3,a3,744 # ffffffffc0206180 <default_pmm_manager+0x620>
ffffffffc0203ea0:	00001617          	auipc	a2,0x1
ffffffffc0203ea4:	0b060613          	addi	a2,a2,176 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203ea8:	1fa00593          	li	a1,506
ffffffffc0203eac:	00002517          	auipc	a0,0x2
ffffffffc0203eb0:	d1450513          	addi	a0,a0,-748 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203eb4:	a4efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203eb8:	00002697          	auipc	a3,0x2
ffffffffc0203ebc:	29868693          	addi	a3,a3,664 # ffffffffc0206150 <default_pmm_manager+0x5f0>
ffffffffc0203ec0:	00001617          	auipc	a2,0x1
ffffffffc0203ec4:	09060613          	addi	a2,a2,144 # ffffffffc0204f50 <commands+0x748>
ffffffffc0203ec8:	1f900593          	li	a1,505
ffffffffc0203ecc:	00002517          	auipc	a0,0x2
ffffffffc0203ed0:	cf450513          	addi	a0,a0,-780 # ffffffffc0205bc0 <default_pmm_manager+0x60>
ffffffffc0203ed4:	a2efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ed8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203ed8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203eda:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203edc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ede:	cf4fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203ee2:	cd01                	beqz	a0,ffffffffc0203efa <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ee4:	4505                	li	a0,1
ffffffffc0203ee6:	cf2fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203eea:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203eec:	810d                	srli	a0,a0,0x3
ffffffffc0203eee:	0000d797          	auipc	a5,0xd
ffffffffc0203ef2:	62a7b923          	sd	a0,1586(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203ef6:	0141                	addi	sp,sp,16
ffffffffc0203ef8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203efa:	00002617          	auipc	a2,0x2
ffffffffc0203efe:	29660613          	addi	a2,a2,662 # ffffffffc0206190 <default_pmm_manager+0x630>
ffffffffc0203f02:	45b5                	li	a1,13
ffffffffc0203f04:	00002517          	auipc	a0,0x2
ffffffffc0203f08:	2ac50513          	addi	a0,a0,684 # ffffffffc02061b0 <default_pmm_manager+0x650>
ffffffffc0203f0c:	9f6fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f10 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203f10:	1141                	addi	sp,sp,-16
ffffffffc0203f12:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f14:	00855793          	srli	a5,a0,0x8
ffffffffc0203f18:	c3a5                	beqz	a5,ffffffffc0203f78 <swapfs_read+0x68>
ffffffffc0203f1a:	0000d717          	auipc	a4,0xd
ffffffffc0203f1e:	60673703          	ld	a4,1542(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203f22:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f78 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f26:	0000d617          	auipc	a2,0xd
ffffffffc0203f2a:	62a63603          	ld	a2,1578(a2) # ffffffffc0211550 <pages>
ffffffffc0203f2e:	8d91                	sub	a1,a1,a2
ffffffffc0203f30:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f34:	00002597          	auipc	a1,0x2
ffffffffc0203f38:	4fc5b583          	ld	a1,1276(a1) # ffffffffc0206430 <error_string+0x38>
ffffffffc0203f3c:	02b60633          	mul	a2,a2,a1
ffffffffc0203f40:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f44:	00002797          	auipc	a5,0x2
ffffffffc0203f48:	4f47b783          	ld	a5,1268(a5) # ffffffffc0206438 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f4c:	0000d717          	auipc	a4,0xd
ffffffffc0203f50:	5fc73703          	ld	a4,1532(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f54:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f56:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f5a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f5c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f5e:	02e7f963          	bgeu	a5,a4,ffffffffc0203f90 <swapfs_read+0x80>
}
ffffffffc0203f62:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f64:	0000d797          	auipc	a5,0xd
ffffffffc0203f68:	5fc7b783          	ld	a5,1532(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203f6c:	46a1                	li	a3,8
ffffffffc0203f6e:	963e                	add	a2,a2,a5
ffffffffc0203f70:	4505                	li	a0,1
}
ffffffffc0203f72:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f74:	c6afc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203f78:	86aa                	mv	a3,a0
ffffffffc0203f7a:	00002617          	auipc	a2,0x2
ffffffffc0203f7e:	24e60613          	addi	a2,a2,590 # ffffffffc02061c8 <default_pmm_manager+0x668>
ffffffffc0203f82:	45d1                	li	a1,20
ffffffffc0203f84:	00002517          	auipc	a0,0x2
ffffffffc0203f88:	22c50513          	addi	a0,a0,556 # ffffffffc02061b0 <default_pmm_manager+0x650>
ffffffffc0203f8c:	976fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f90:	86b2                	mv	a3,a2
ffffffffc0203f92:	06a00593          	li	a1,106
ffffffffc0203f96:	00002617          	auipc	a2,0x2
ffffffffc0203f9a:	c0260613          	addi	a2,a2,-1022 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0203f9e:	00001517          	auipc	a0,0x1
ffffffffc0203fa2:	12250513          	addi	a0,a0,290 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0203fa6:	95cfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203faa <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203faa:	1141                	addi	sp,sp,-16
ffffffffc0203fac:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fae:	00855793          	srli	a5,a0,0x8
ffffffffc0203fb2:	c3a5                	beqz	a5,ffffffffc0204012 <swapfs_write+0x68>
ffffffffc0203fb4:	0000d717          	auipc	a4,0xd
ffffffffc0203fb8:	56c73703          	ld	a4,1388(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203fbc:	04e7fb63          	bgeu	a5,a4,ffffffffc0204012 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fc0:	0000d617          	auipc	a2,0xd
ffffffffc0203fc4:	59063603          	ld	a2,1424(a2) # ffffffffc0211550 <pages>
ffffffffc0203fc8:	8d91                	sub	a1,a1,a2
ffffffffc0203fca:	4035d613          	srai	a2,a1,0x3
ffffffffc0203fce:	00002597          	auipc	a1,0x2
ffffffffc0203fd2:	4625b583          	ld	a1,1122(a1) # ffffffffc0206430 <error_string+0x38>
ffffffffc0203fd6:	02b60633          	mul	a2,a2,a1
ffffffffc0203fda:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203fde:	00002797          	auipc	a5,0x2
ffffffffc0203fe2:	45a7b783          	ld	a5,1114(a5) # ffffffffc0206438 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fe6:	0000d717          	auipc	a4,0xd
ffffffffc0203fea:	56273703          	ld	a4,1378(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fee:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ff0:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ff4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ff6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ff8:	02e7f963          	bgeu	a5,a4,ffffffffc020402a <swapfs_write+0x80>
}
ffffffffc0203ffc:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ffe:	0000d797          	auipc	a5,0xd
ffffffffc0204002:	5627b783          	ld	a5,1378(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0204006:	46a1                	li	a3,8
ffffffffc0204008:	963e                	add	a2,a2,a5
ffffffffc020400a:	4505                	li	a0,1
}
ffffffffc020400c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020400e:	bf4fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0204012:	86aa                	mv	a3,a0
ffffffffc0204014:	00002617          	auipc	a2,0x2
ffffffffc0204018:	1b460613          	addi	a2,a2,436 # ffffffffc02061c8 <default_pmm_manager+0x668>
ffffffffc020401c:	45e5                	li	a1,25
ffffffffc020401e:	00002517          	auipc	a0,0x2
ffffffffc0204022:	19250513          	addi	a0,a0,402 # ffffffffc02061b0 <default_pmm_manager+0x650>
ffffffffc0204026:	8dcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020402a:	86b2                	mv	a3,a2
ffffffffc020402c:	06a00593          	li	a1,106
ffffffffc0204030:	00002617          	auipc	a2,0x2
ffffffffc0204034:	b6860613          	addi	a2,a2,-1176 # ffffffffc0205b98 <default_pmm_manager+0x38>
ffffffffc0204038:	00001517          	auipc	a0,0x1
ffffffffc020403c:	08850513          	addi	a0,a0,136 # ffffffffc02050c0 <commands+0x8b8>
ffffffffc0204040:	8c2fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0204044 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204044:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204048:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020404a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020404c:	cb81                	beqz	a5,ffffffffc020405c <strlen+0x18>
        cnt ++;
ffffffffc020404e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204050:	00a707b3          	add	a5,a4,a0
ffffffffc0204054:	0007c783          	lbu	a5,0(a5)
ffffffffc0204058:	fbfd                	bnez	a5,ffffffffc020404e <strlen+0xa>
ffffffffc020405a:	8082                	ret
    }
    return cnt;
}
ffffffffc020405c:	8082                	ret

ffffffffc020405e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020405e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204060:	e589                	bnez	a1,ffffffffc020406a <strnlen+0xc>
ffffffffc0204062:	a811                	j	ffffffffc0204076 <strnlen+0x18>
        cnt ++;
ffffffffc0204064:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204066:	00f58863          	beq	a1,a5,ffffffffc0204076 <strnlen+0x18>
ffffffffc020406a:	00f50733          	add	a4,a0,a5
ffffffffc020406e:	00074703          	lbu	a4,0(a4)
ffffffffc0204072:	fb6d                	bnez	a4,ffffffffc0204064 <strnlen+0x6>
ffffffffc0204074:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204076:	852e                	mv	a0,a1
ffffffffc0204078:	8082                	ret

ffffffffc020407a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020407a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020407c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204080:	0785                	addi	a5,a5,1
ffffffffc0204082:	0585                	addi	a1,a1,1
ffffffffc0204084:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204088:	fb75                	bnez	a4,ffffffffc020407c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020408a:	8082                	ret

ffffffffc020408c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020408c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204090:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204094:	cb89                	beqz	a5,ffffffffc02040a6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204096:	0505                	addi	a0,a0,1
ffffffffc0204098:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020409a:	fee789e3          	beq	a5,a4,ffffffffc020408c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020409e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02040a2:	9d19                	subw	a0,a0,a4
ffffffffc02040a4:	8082                	ret
ffffffffc02040a6:	4501                	li	a0,0
ffffffffc02040a8:	bfed                	j	ffffffffc02040a2 <strcmp+0x16>

ffffffffc02040aa <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02040aa:	00054783          	lbu	a5,0(a0)
ffffffffc02040ae:	c799                	beqz	a5,ffffffffc02040bc <strchr+0x12>
        if (*s == c) {
ffffffffc02040b0:	00f58763          	beq	a1,a5,ffffffffc02040be <strchr+0x14>
    while (*s != '\0') {
ffffffffc02040b4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02040b8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02040ba:	fbfd                	bnez	a5,ffffffffc02040b0 <strchr+0x6>
    }
    return NULL;
ffffffffc02040bc:	4501                	li	a0,0
}
ffffffffc02040be:	8082                	ret

ffffffffc02040c0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02040c0:	ca01                	beqz	a2,ffffffffc02040d0 <memset+0x10>
ffffffffc02040c2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02040c4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02040c6:	0785                	addi	a5,a5,1
ffffffffc02040c8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02040cc:	fec79de3          	bne	a5,a2,ffffffffc02040c6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02040d0:	8082                	ret

ffffffffc02040d2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02040d2:	ca19                	beqz	a2,ffffffffc02040e8 <memcpy+0x16>
ffffffffc02040d4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02040d6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02040d8:	0005c703          	lbu	a4,0(a1)
ffffffffc02040dc:	0585                	addi	a1,a1,1
ffffffffc02040de:	0785                	addi	a5,a5,1
ffffffffc02040e0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02040e4:	fec59ae3          	bne	a1,a2,ffffffffc02040d8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02040e8:	8082                	ret

ffffffffc02040ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02040ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02040f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02040f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040fa:	f022                	sd	s0,32(sp)
ffffffffc02040fc:	ec26                	sd	s1,24(sp)
ffffffffc02040fe:	e84a                	sd	s2,16(sp)
ffffffffc0204100:	f406                	sd	ra,40(sp)
ffffffffc0204102:	e44e                	sd	s3,8(sp)
ffffffffc0204104:	84aa                	mv	s1,a0
ffffffffc0204106:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204108:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020410c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020410e:	03067e63          	bgeu	a2,a6,ffffffffc020414a <printnum+0x60>
ffffffffc0204112:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204114:	00805763          	blez	s0,ffffffffc0204122 <printnum+0x38>
ffffffffc0204118:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020411a:	85ca                	mv	a1,s2
ffffffffc020411c:	854e                	mv	a0,s3
ffffffffc020411e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204120:	fc65                	bnez	s0,ffffffffc0204118 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204122:	1a02                	slli	s4,s4,0x20
ffffffffc0204124:	00002797          	auipc	a5,0x2
ffffffffc0204128:	0c478793          	addi	a5,a5,196 # ffffffffc02061e8 <default_pmm_manager+0x688>
ffffffffc020412c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204130:	9a3e                	add	s4,s4,a5
}
ffffffffc0204132:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204134:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204138:	70a2                	ld	ra,40(sp)
ffffffffc020413a:	69a2                	ld	s3,8(sp)
ffffffffc020413c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020413e:	85ca                	mv	a1,s2
ffffffffc0204140:	87a6                	mv	a5,s1
}
ffffffffc0204142:	6942                	ld	s2,16(sp)
ffffffffc0204144:	64e2                	ld	s1,24(sp)
ffffffffc0204146:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204148:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020414a:	03065633          	divu	a2,a2,a6
ffffffffc020414e:	8722                	mv	a4,s0
ffffffffc0204150:	f9bff0ef          	jal	ra,ffffffffc02040ea <printnum>
ffffffffc0204154:	b7f9                	j	ffffffffc0204122 <printnum+0x38>

ffffffffc0204156 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204156:	7119                	addi	sp,sp,-128
ffffffffc0204158:	f4a6                	sd	s1,104(sp)
ffffffffc020415a:	f0ca                	sd	s2,96(sp)
ffffffffc020415c:	ecce                	sd	s3,88(sp)
ffffffffc020415e:	e8d2                	sd	s4,80(sp)
ffffffffc0204160:	e4d6                	sd	s5,72(sp)
ffffffffc0204162:	e0da                	sd	s6,64(sp)
ffffffffc0204164:	fc5e                	sd	s7,56(sp)
ffffffffc0204166:	f06a                	sd	s10,32(sp)
ffffffffc0204168:	fc86                	sd	ra,120(sp)
ffffffffc020416a:	f8a2                	sd	s0,112(sp)
ffffffffc020416c:	f862                	sd	s8,48(sp)
ffffffffc020416e:	f466                	sd	s9,40(sp)
ffffffffc0204170:	ec6e                	sd	s11,24(sp)
ffffffffc0204172:	892a                	mv	s2,a0
ffffffffc0204174:	84ae                	mv	s1,a1
ffffffffc0204176:	8d32                	mv	s10,a2
ffffffffc0204178:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020417a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020417e:	5b7d                	li	s6,-1
ffffffffc0204180:	00002a97          	auipc	s5,0x2
ffffffffc0204184:	09ca8a93          	addi	s5,s5,156 # ffffffffc020621c <default_pmm_manager+0x6bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204188:	00002b97          	auipc	s7,0x2
ffffffffc020418c:	270b8b93          	addi	s7,s7,624 # ffffffffc02063f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204190:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204194:	001d0413          	addi	s0,s10,1
ffffffffc0204198:	01350a63          	beq	a0,s3,ffffffffc02041ac <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020419c:	c121                	beqz	a0,ffffffffc02041dc <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020419e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02041a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02041a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02041a4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02041a8:	ff351ae3          	bne	a0,s3,ffffffffc020419c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02041b0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02041b4:	4c81                	li	s9,0
ffffffffc02041b6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02041b8:	5c7d                	li	s8,-1
ffffffffc02041ba:	5dfd                	li	s11,-1
ffffffffc02041bc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02041c0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041c2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02041c6:	0ff5f593          	zext.b	a1,a1
ffffffffc02041ca:	00140d13          	addi	s10,s0,1
ffffffffc02041ce:	04b56263          	bltu	a0,a1,ffffffffc0204212 <vprintfmt+0xbc>
ffffffffc02041d2:	058a                	slli	a1,a1,0x2
ffffffffc02041d4:	95d6                	add	a1,a1,s5
ffffffffc02041d6:	4194                	lw	a3,0(a1)
ffffffffc02041d8:	96d6                	add	a3,a3,s5
ffffffffc02041da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02041dc:	70e6                	ld	ra,120(sp)
ffffffffc02041de:	7446                	ld	s0,112(sp)
ffffffffc02041e0:	74a6                	ld	s1,104(sp)
ffffffffc02041e2:	7906                	ld	s2,96(sp)
ffffffffc02041e4:	69e6                	ld	s3,88(sp)
ffffffffc02041e6:	6a46                	ld	s4,80(sp)
ffffffffc02041e8:	6aa6                	ld	s5,72(sp)
ffffffffc02041ea:	6b06                	ld	s6,64(sp)
ffffffffc02041ec:	7be2                	ld	s7,56(sp)
ffffffffc02041ee:	7c42                	ld	s8,48(sp)
ffffffffc02041f0:	7ca2                	ld	s9,40(sp)
ffffffffc02041f2:	7d02                	ld	s10,32(sp)
ffffffffc02041f4:	6de2                	ld	s11,24(sp)
ffffffffc02041f6:	6109                	addi	sp,sp,128
ffffffffc02041f8:	8082                	ret
            padc = '0';
ffffffffc02041fa:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02041fc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204200:	846a                	mv	s0,s10
ffffffffc0204202:	00140d13          	addi	s10,s0,1
ffffffffc0204206:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020420a:	0ff5f593          	zext.b	a1,a1
ffffffffc020420e:	fcb572e3          	bgeu	a0,a1,ffffffffc02041d2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204212:	85a6                	mv	a1,s1
ffffffffc0204214:	02500513          	li	a0,37
ffffffffc0204218:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020421a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020421e:	8d22                	mv	s10,s0
ffffffffc0204220:	f73788e3          	beq	a5,s3,ffffffffc0204190 <vprintfmt+0x3a>
ffffffffc0204224:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204228:	1d7d                	addi	s10,s10,-1
ffffffffc020422a:	ff379de3          	bne	a5,s3,ffffffffc0204224 <vprintfmt+0xce>
ffffffffc020422e:	b78d                	j	ffffffffc0204190 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204230:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204234:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204238:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020423a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020423e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204242:	02d86463          	bltu	a6,a3,ffffffffc020426a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204246:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020424a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020424e:	0186873b          	addw	a4,a3,s8
ffffffffc0204252:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204256:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204258:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020425c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020425e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204262:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204266:	fed870e3          	bgeu	a6,a3,ffffffffc0204246 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020426a:	f40ddce3          	bgez	s11,ffffffffc02041c2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020426e:	8de2                	mv	s11,s8
ffffffffc0204270:	5c7d                	li	s8,-1
ffffffffc0204272:	bf81                	j	ffffffffc02041c2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204274:	fffdc693          	not	a3,s11
ffffffffc0204278:	96fd                	srai	a3,a3,0x3f
ffffffffc020427a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020427e:	00144603          	lbu	a2,1(s0)
ffffffffc0204282:	2d81                	sext.w	s11,s11
ffffffffc0204284:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204286:	bf35                	j	ffffffffc02041c2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204288:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020428c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204290:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204292:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204294:	bfd9                	j	ffffffffc020426a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204296:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204298:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020429c:	01174463          	blt	a4,a7,ffffffffc02042a4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02042a0:	1a088e63          	beqz	a7,ffffffffc020445c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02042a4:	000a3603          	ld	a2,0(s4)
ffffffffc02042a8:	46c1                	li	a3,16
ffffffffc02042aa:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02042ac:	2781                	sext.w	a5,a5
ffffffffc02042ae:	876e                	mv	a4,s11
ffffffffc02042b0:	85a6                	mv	a1,s1
ffffffffc02042b2:	854a                	mv	a0,s2
ffffffffc02042b4:	e37ff0ef          	jal	ra,ffffffffc02040ea <printnum>
            break;
ffffffffc02042b8:	bde1                	j	ffffffffc0204190 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02042ba:	000a2503          	lw	a0,0(s4)
ffffffffc02042be:	85a6                	mv	a1,s1
ffffffffc02042c0:	0a21                	addi	s4,s4,8
ffffffffc02042c2:	9902                	jalr	s2
            break;
ffffffffc02042c4:	b5f1                	j	ffffffffc0204190 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02042c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042c8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02042cc:	01174463          	blt	a4,a7,ffffffffc02042d4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02042d0:	18088163          	beqz	a7,ffffffffc0204452 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02042d4:	000a3603          	ld	a2,0(s4)
ffffffffc02042d8:	46a9                	li	a3,10
ffffffffc02042da:	8a2e                	mv	s4,a1
ffffffffc02042dc:	bfc1                	j	ffffffffc02042ac <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042de:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02042e2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042e6:	bdf1                	j	ffffffffc02041c2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02042e8:	85a6                	mv	a1,s1
ffffffffc02042ea:	02500513          	li	a0,37
ffffffffc02042ee:	9902                	jalr	s2
            break;
ffffffffc02042f0:	b545                	j	ffffffffc0204190 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042f2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02042f6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042fa:	b5e1                	j	ffffffffc02041c2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02042fc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042fe:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204302:	01174463          	blt	a4,a7,ffffffffc020430a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204306:	14088163          	beqz	a7,ffffffffc0204448 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020430a:	000a3603          	ld	a2,0(s4)
ffffffffc020430e:	46a1                	li	a3,8
ffffffffc0204310:	8a2e                	mv	s4,a1
ffffffffc0204312:	bf69                	j	ffffffffc02042ac <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204314:	03000513          	li	a0,48
ffffffffc0204318:	85a6                	mv	a1,s1
ffffffffc020431a:	e03e                	sd	a5,0(sp)
ffffffffc020431c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020431e:	85a6                	mv	a1,s1
ffffffffc0204320:	07800513          	li	a0,120
ffffffffc0204324:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204326:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204328:	6782                	ld	a5,0(sp)
ffffffffc020432a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020432c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204330:	bfb5                	j	ffffffffc02042ac <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204332:	000a3403          	ld	s0,0(s4)
ffffffffc0204336:	008a0713          	addi	a4,s4,8
ffffffffc020433a:	e03a                	sd	a4,0(sp)
ffffffffc020433c:	14040263          	beqz	s0,ffffffffc0204480 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204340:	0fb05763          	blez	s11,ffffffffc020442e <vprintfmt+0x2d8>
ffffffffc0204344:	02d00693          	li	a3,45
ffffffffc0204348:	0cd79163          	bne	a5,a3,ffffffffc020440a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020434c:	00044783          	lbu	a5,0(s0)
ffffffffc0204350:	0007851b          	sext.w	a0,a5
ffffffffc0204354:	cf85                	beqz	a5,ffffffffc020438c <vprintfmt+0x236>
ffffffffc0204356:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020435a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020435e:	000c4563          	bltz	s8,ffffffffc0204368 <vprintfmt+0x212>
ffffffffc0204362:	3c7d                	addiw	s8,s8,-1
ffffffffc0204364:	036c0263          	beq	s8,s6,ffffffffc0204388 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204368:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020436a:	0e0c8e63          	beqz	s9,ffffffffc0204466 <vprintfmt+0x310>
ffffffffc020436e:	3781                	addiw	a5,a5,-32
ffffffffc0204370:	0ef47b63          	bgeu	s0,a5,ffffffffc0204466 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204374:	03f00513          	li	a0,63
ffffffffc0204378:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020437a:	000a4783          	lbu	a5,0(s4)
ffffffffc020437e:	3dfd                	addiw	s11,s11,-1
ffffffffc0204380:	0a05                	addi	s4,s4,1
ffffffffc0204382:	0007851b          	sext.w	a0,a5
ffffffffc0204386:	ffe1                	bnez	a5,ffffffffc020435e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204388:	01b05963          	blez	s11,ffffffffc020439a <vprintfmt+0x244>
ffffffffc020438c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020438e:	85a6                	mv	a1,s1
ffffffffc0204390:	02000513          	li	a0,32
ffffffffc0204394:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204396:	fe0d9be3          	bnez	s11,ffffffffc020438c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020439a:	6a02                	ld	s4,0(sp)
ffffffffc020439c:	bbd5                	j	ffffffffc0204190 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020439e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02043a0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02043a4:	01174463          	blt	a4,a7,ffffffffc02043ac <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02043a8:	08088d63          	beqz	a7,ffffffffc0204442 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02043ac:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02043b0:	0a044d63          	bltz	s0,ffffffffc020446a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02043b4:	8622                	mv	a2,s0
ffffffffc02043b6:	8a66                	mv	s4,s9
ffffffffc02043b8:	46a9                	li	a3,10
ffffffffc02043ba:	bdcd                	j	ffffffffc02042ac <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02043bc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02043c0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02043c2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02043c4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02043c8:	8fb5                	xor	a5,a5,a3
ffffffffc02043ca:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02043ce:	02d74163          	blt	a4,a3,ffffffffc02043f0 <vprintfmt+0x29a>
ffffffffc02043d2:	00369793          	slli	a5,a3,0x3
ffffffffc02043d6:	97de                	add	a5,a5,s7
ffffffffc02043d8:	639c                	ld	a5,0(a5)
ffffffffc02043da:	cb99                	beqz	a5,ffffffffc02043f0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02043dc:	86be                	mv	a3,a5
ffffffffc02043de:	00002617          	auipc	a2,0x2
ffffffffc02043e2:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206218 <default_pmm_manager+0x6b8>
ffffffffc02043e6:	85a6                	mv	a1,s1
ffffffffc02043e8:	854a                	mv	a0,s2
ffffffffc02043ea:	0ce000ef          	jal	ra,ffffffffc02044b8 <printfmt>
ffffffffc02043ee:	b34d                	j	ffffffffc0204190 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02043f0:	00002617          	auipc	a2,0x2
ffffffffc02043f4:	e1860613          	addi	a2,a2,-488 # ffffffffc0206208 <default_pmm_manager+0x6a8>
ffffffffc02043f8:	85a6                	mv	a1,s1
ffffffffc02043fa:	854a                	mv	a0,s2
ffffffffc02043fc:	0bc000ef          	jal	ra,ffffffffc02044b8 <printfmt>
ffffffffc0204400:	bb41                	j	ffffffffc0204190 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204402:	00002417          	auipc	s0,0x2
ffffffffc0204406:	dfe40413          	addi	s0,s0,-514 # ffffffffc0206200 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020440a:	85e2                	mv	a1,s8
ffffffffc020440c:	8522                	mv	a0,s0
ffffffffc020440e:	e43e                	sd	a5,8(sp)
ffffffffc0204410:	c4fff0ef          	jal	ra,ffffffffc020405e <strnlen>
ffffffffc0204414:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204418:	01b05b63          	blez	s11,ffffffffc020442e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020441c:	67a2                	ld	a5,8(sp)
ffffffffc020441e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204422:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204424:	85a6                	mv	a1,s1
ffffffffc0204426:	8552                	mv	a0,s4
ffffffffc0204428:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020442a:	fe0d9ce3          	bnez	s11,ffffffffc0204422 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020442e:	00044783          	lbu	a5,0(s0)
ffffffffc0204432:	00140a13          	addi	s4,s0,1
ffffffffc0204436:	0007851b          	sext.w	a0,a5
ffffffffc020443a:	d3a5                	beqz	a5,ffffffffc020439a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020443c:	05e00413          	li	s0,94
ffffffffc0204440:	bf39                	j	ffffffffc020435e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204442:	000a2403          	lw	s0,0(s4)
ffffffffc0204446:	b7ad                	j	ffffffffc02043b0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204448:	000a6603          	lwu	a2,0(s4)
ffffffffc020444c:	46a1                	li	a3,8
ffffffffc020444e:	8a2e                	mv	s4,a1
ffffffffc0204450:	bdb1                	j	ffffffffc02042ac <vprintfmt+0x156>
ffffffffc0204452:	000a6603          	lwu	a2,0(s4)
ffffffffc0204456:	46a9                	li	a3,10
ffffffffc0204458:	8a2e                	mv	s4,a1
ffffffffc020445a:	bd89                	j	ffffffffc02042ac <vprintfmt+0x156>
ffffffffc020445c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204460:	46c1                	li	a3,16
ffffffffc0204462:	8a2e                	mv	s4,a1
ffffffffc0204464:	b5a1                	j	ffffffffc02042ac <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204466:	9902                	jalr	s2
ffffffffc0204468:	bf09                	j	ffffffffc020437a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020446a:	85a6                	mv	a1,s1
ffffffffc020446c:	02d00513          	li	a0,45
ffffffffc0204470:	e03e                	sd	a5,0(sp)
ffffffffc0204472:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204474:	6782                	ld	a5,0(sp)
ffffffffc0204476:	8a66                	mv	s4,s9
ffffffffc0204478:	40800633          	neg	a2,s0
ffffffffc020447c:	46a9                	li	a3,10
ffffffffc020447e:	b53d                	j	ffffffffc02042ac <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204480:	03b05163          	blez	s11,ffffffffc02044a2 <vprintfmt+0x34c>
ffffffffc0204484:	02d00693          	li	a3,45
ffffffffc0204488:	f6d79de3          	bne	a5,a3,ffffffffc0204402 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020448c:	00002417          	auipc	s0,0x2
ffffffffc0204490:	d7440413          	addi	s0,s0,-652 # ffffffffc0206200 <default_pmm_manager+0x6a0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204494:	02800793          	li	a5,40
ffffffffc0204498:	02800513          	li	a0,40
ffffffffc020449c:	00140a13          	addi	s4,s0,1
ffffffffc02044a0:	bd6d                	j	ffffffffc020435a <vprintfmt+0x204>
ffffffffc02044a2:	00002a17          	auipc	s4,0x2
ffffffffc02044a6:	d5fa0a13          	addi	s4,s4,-673 # ffffffffc0206201 <default_pmm_manager+0x6a1>
ffffffffc02044aa:	02800513          	li	a0,40
ffffffffc02044ae:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02044b2:	05e00413          	li	s0,94
ffffffffc02044b6:	b565                	j	ffffffffc020435e <vprintfmt+0x208>

ffffffffc02044b8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02044b8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02044ba:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02044be:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02044c0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02044c2:	ec06                	sd	ra,24(sp)
ffffffffc02044c4:	f83a                	sd	a4,48(sp)
ffffffffc02044c6:	fc3e                	sd	a5,56(sp)
ffffffffc02044c8:	e0c2                	sd	a6,64(sp)
ffffffffc02044ca:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02044cc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02044ce:	c89ff0ef          	jal	ra,ffffffffc0204156 <vprintfmt>
}
ffffffffc02044d2:	60e2                	ld	ra,24(sp)
ffffffffc02044d4:	6161                	addi	sp,sp,80
ffffffffc02044d6:	8082                	ret

ffffffffc02044d8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02044d8:	715d                	addi	sp,sp,-80
ffffffffc02044da:	e486                	sd	ra,72(sp)
ffffffffc02044dc:	e0a6                	sd	s1,64(sp)
ffffffffc02044de:	fc4a                	sd	s2,56(sp)
ffffffffc02044e0:	f84e                	sd	s3,48(sp)
ffffffffc02044e2:	f452                	sd	s4,40(sp)
ffffffffc02044e4:	f056                	sd	s5,32(sp)
ffffffffc02044e6:	ec5a                	sd	s6,24(sp)
ffffffffc02044e8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02044ea:	c901                	beqz	a0,ffffffffc02044fa <readline+0x22>
ffffffffc02044ec:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02044ee:	00002517          	auipc	a0,0x2
ffffffffc02044f2:	d2a50513          	addi	a0,a0,-726 # ffffffffc0206218 <default_pmm_manager+0x6b8>
ffffffffc02044f6:	bc5fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02044fa:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044fc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02044fe:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204500:	4aa9                	li	s5,10
ffffffffc0204502:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204504:	0000db97          	auipc	s7,0xd
ffffffffc0204508:	bf4b8b93          	addi	s7,s7,-1036 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020450c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204510:	be3fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204514:	00054a63          	bltz	a0,ffffffffc0204528 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204518:	00a95a63          	bge	s2,a0,ffffffffc020452c <readline+0x54>
ffffffffc020451c:	029a5263          	bge	s4,s1,ffffffffc0204540 <readline+0x68>
        c = getchar();
ffffffffc0204520:	bd3fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204524:	fe055ae3          	bgez	a0,ffffffffc0204518 <readline+0x40>
            return NULL;
ffffffffc0204528:	4501                	li	a0,0
ffffffffc020452a:	a091                	j	ffffffffc020456e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020452c:	03351463          	bne	a0,s3,ffffffffc0204554 <readline+0x7c>
ffffffffc0204530:	e8a9                	bnez	s1,ffffffffc0204582 <readline+0xaa>
        c = getchar();
ffffffffc0204532:	bc1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204536:	fe0549e3          	bltz	a0,ffffffffc0204528 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020453a:	fea959e3          	bge	s2,a0,ffffffffc020452c <readline+0x54>
ffffffffc020453e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204540:	e42a                	sd	a0,8(sp)
ffffffffc0204542:	baffb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204546:	6522                	ld	a0,8(sp)
ffffffffc0204548:	009b87b3          	add	a5,s7,s1
ffffffffc020454c:	2485                	addiw	s1,s1,1
ffffffffc020454e:	00a78023          	sb	a0,0(a5)
ffffffffc0204552:	bf7d                	j	ffffffffc0204510 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204554:	01550463          	beq	a0,s5,ffffffffc020455c <readline+0x84>
ffffffffc0204558:	fb651ce3          	bne	a0,s6,ffffffffc0204510 <readline+0x38>
            cputchar(c);
ffffffffc020455c:	b95fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204560:	0000d517          	auipc	a0,0xd
ffffffffc0204564:	b9850513          	addi	a0,a0,-1128 # ffffffffc02110f8 <buf>
ffffffffc0204568:	94aa                	add	s1,s1,a0
ffffffffc020456a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020456e:	60a6                	ld	ra,72(sp)
ffffffffc0204570:	6486                	ld	s1,64(sp)
ffffffffc0204572:	7962                	ld	s2,56(sp)
ffffffffc0204574:	79c2                	ld	s3,48(sp)
ffffffffc0204576:	7a22                	ld	s4,40(sp)
ffffffffc0204578:	7a82                	ld	s5,32(sp)
ffffffffc020457a:	6b62                	ld	s6,24(sp)
ffffffffc020457c:	6bc2                	ld	s7,16(sp)
ffffffffc020457e:	6161                	addi	sp,sp,80
ffffffffc0204580:	8082                	ret
            cputchar(c);
ffffffffc0204582:	4521                	li	a0,8
ffffffffc0204584:	b6dfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204588:	34fd                	addiw	s1,s1,-1
ffffffffc020458a:	b759                	j	ffffffffc0204510 <readline+0x38>

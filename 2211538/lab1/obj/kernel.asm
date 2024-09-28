
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <edata>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	213000ef          	jal	ra,80200a34 <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a1e58593          	addi	a1,a1,-1506 # 80200a48 <etext+0x2>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a3650513          	addi	a0,a0,-1482 # 80200a68 <etext+0x22>
    8020003a:	032000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	138000ef          	jal	ra,8020017a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    //intr_enable();  // enable irq interrupt
    
    asm volatile("ebreak");
    8020004a:	9002                	ebreak
    8020004c:	0000                	unimp
    8020004e:	0000                	unimp
    asm volatile(".word 0x00000000");
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x46>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	118000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5a6000ef          	jal	ra,8020063a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9ce50513          	addi	a0,a0,-1586 # 80200a70 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9d850513          	addi	a0,a0,-1576 # 80200a90 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	98258593          	addi	a1,a1,-1662 # 80200a46 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9e450513          	addi	a0,a0,-1564 # 80200ab0 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9f050513          	addi	a0,a0,-1552 # 80200ad0 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9fc50513          	addi	a0,a0,-1540 # 80200af0 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9ee50513          	addi	a0,a0,-1554 # 80200b10 <etext+0xca>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	b781                	j	8020006c <cprintf>

000000008020012e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	091000ef          	jal	ra,802009d6 <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07ba23          	sd	zero,-300(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	9ec50513          	addi	a0,a0,-1556 # 80200b40 <etext+0xfa>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b739                	j	8020006c <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	06b0006f          	j	802009d6 <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	andi	a0,a0,255
    80200176:	0450006f          	j	802009ba <sbi_console_putchar>

000000008020017a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020017e:	00000797          	auipc	a5,0x0
    80200182:	39a78793          	addi	a5,a5,922 # 80200518 <__alltraps>
    80200186:	10579073          	csrw	stvec,a5
}
    8020018a:	8082                	ret

000000008020018c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020018e:	1141                	addi	sp,sp,-16
    80200190:	e022                	sd	s0,0(sp)
    80200192:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200194:	00001517          	auipc	a0,0x1
    80200198:	b3c50513          	addi	a0,a0,-1220 # 80200cd0 <etext+0x28a>
void print_regs(struct pushregs *gpr) {
    8020019c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	ecfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a2:	640c                	ld	a1,8(s0)
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	b4450513          	addi	a0,a0,-1212 # 80200ce8 <etext+0x2a2>
    802001ac:	ec1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b0:	680c                	ld	a1,16(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	b4e50513          	addi	a0,a0,-1202 # 80200d00 <etext+0x2ba>
    802001ba:	eb3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001be:	6c0c                	ld	a1,24(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b5850513          	addi	a0,a0,-1192 # 80200d18 <etext+0x2d2>
    802001c8:	ea5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001cc:	700c                	ld	a1,32(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b6250513          	addi	a0,a0,-1182 # 80200d30 <etext+0x2ea>
    802001d6:	e97ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001da:	740c                	ld	a1,40(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b6c50513          	addi	a0,a0,-1172 # 80200d48 <etext+0x302>
    802001e4:	e89ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001e8:	780c                	ld	a1,48(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b7650513          	addi	a0,a0,-1162 # 80200d60 <etext+0x31a>
    802001f2:	e7bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f6:	7c0c                	ld	a1,56(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	b8050513          	addi	a0,a0,-1152 # 80200d78 <etext+0x332>
    80200200:	e6dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200204:	602c                	ld	a1,64(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	b8a50513          	addi	a0,a0,-1142 # 80200d90 <etext+0x34a>
    8020020e:	e5fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200212:	642c                	ld	a1,72(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	b9450513          	addi	a0,a0,-1132 # 80200da8 <etext+0x362>
    8020021c:	e51ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200220:	682c                	ld	a1,80(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	b9e50513          	addi	a0,a0,-1122 # 80200dc0 <etext+0x37a>
    8020022a:	e43ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020022e:	6c2c                	ld	a1,88(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	ba850513          	addi	a0,a0,-1112 # 80200dd8 <etext+0x392>
    80200238:	e35ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020023c:	702c                	ld	a1,96(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	bb250513          	addi	a0,a0,-1102 # 80200df0 <etext+0x3aa>
    80200246:	e27ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024a:	742c                	ld	a1,104(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	bbc50513          	addi	a0,a0,-1092 # 80200e08 <etext+0x3c2>
    80200254:	e19ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200258:	782c                	ld	a1,112(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	bc650513          	addi	a0,a0,-1082 # 80200e20 <etext+0x3da>
    80200262:	e0bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200266:	7c2c                	ld	a1,120(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	bd050513          	addi	a0,a0,-1072 # 80200e38 <etext+0x3f2>
    80200270:	dfdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200274:	604c                	ld	a1,128(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	bda50513          	addi	a0,a0,-1062 # 80200e50 <etext+0x40a>
    8020027e:	defff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200282:	644c                	ld	a1,136(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	be450513          	addi	a0,a0,-1052 # 80200e68 <etext+0x422>
    8020028c:	de1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200290:	684c                	ld	a1,144(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	bee50513          	addi	a0,a0,-1042 # 80200e80 <etext+0x43a>
    8020029a:	dd3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    8020029e:	6c4c                	ld	a1,152(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	bf850513          	addi	a0,a0,-1032 # 80200e98 <etext+0x452>
    802002a8:	dc5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ac:	704c                	ld	a1,160(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	c0250513          	addi	a0,a0,-1022 # 80200eb0 <etext+0x46a>
    802002b6:	db7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ba:	744c                	ld	a1,168(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	c0c50513          	addi	a0,a0,-1012 # 80200ec8 <etext+0x482>
    802002c4:	da9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002c8:	784c                	ld	a1,176(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	c1650513          	addi	a0,a0,-1002 # 80200ee0 <etext+0x49a>
    802002d2:	d9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d6:	7c4c                	ld	a1,184(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	c2050513          	addi	a0,a0,-992 # 80200ef8 <etext+0x4b2>
    802002e0:	d8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e4:	606c                	ld	a1,192(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	c2a50513          	addi	a0,a0,-982 # 80200f10 <etext+0x4ca>
    802002ee:	d7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f2:	646c                	ld	a1,200(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	c3450513          	addi	a0,a0,-972 # 80200f28 <etext+0x4e2>
    802002fc:	d71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200300:	686c                	ld	a1,208(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	c3e50513          	addi	a0,a0,-962 # 80200f40 <etext+0x4fa>
    8020030a:	d63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020030e:	6c6c                	ld	a1,216(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c4850513          	addi	a0,a0,-952 # 80200f58 <etext+0x512>
    80200318:	d55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020031c:	706c                	ld	a1,224(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c5250513          	addi	a0,a0,-942 # 80200f70 <etext+0x52a>
    80200326:	d47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032a:	746c                	ld	a1,232(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	c5c50513          	addi	a0,a0,-932 # 80200f88 <etext+0x542>
    80200334:	d39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200338:	786c                	ld	a1,240(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	c6650513          	addi	a0,a0,-922 # 80200fa0 <etext+0x55a>
    80200342:	d2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200346:	7c6c                	ld	a1,248(s0)
}
    80200348:	6402                	ld	s0,0(sp)
    8020034a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	00001517          	auipc	a0,0x1
    80200350:	c6c50513          	addi	a0,a0,-916 # 80200fb8 <etext+0x572>
}
    80200354:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	bb19                	j	8020006c <cprintf>

0000000080200358 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200358:	1141                	addi	sp,sp,-16
    8020035a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020035c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020035e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200360:	00001517          	auipc	a0,0x1
    80200364:	c7050513          	addi	a0,a0,-912 # 80200fd0 <etext+0x58a>
void print_trapframe(struct trapframe *tf) {
    80200368:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036a:	d03ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020036e:	8522                	mv	a0,s0
    80200370:	e1dff0ef          	jal	ra,8020018c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200374:	10043583          	ld	a1,256(s0)
    80200378:	00001517          	auipc	a0,0x1
    8020037c:	c7050513          	addi	a0,a0,-912 # 80200fe8 <etext+0x5a2>
    80200380:	cedff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200384:	10843583          	ld	a1,264(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	c7850513          	addi	a0,a0,-904 # 80201000 <etext+0x5ba>
    80200390:	cddff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200394:	11043583          	ld	a1,272(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	c8050513          	addi	a0,a0,-896 # 80201018 <etext+0x5d2>
    802003a0:	ccdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a4:	11843583          	ld	a1,280(s0)
}
    802003a8:	6402                	ld	s0,0(sp)
    802003aa:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ac:	00001517          	auipc	a0,0x1
    802003b0:	c8450513          	addi	a0,a0,-892 # 80201030 <etext+0x5ea>
}
    802003b4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	b95d                	j	8020006c <cprintf>

00000000802003b8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003b8:	11853783          	ld	a5,280(a0)
    switch (cause) {
    802003bc:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	0786                	slli	a5,a5,0x1
    802003c0:	8385                	srli	a5,a5,0x1
    switch (cause) {
    802003c2:	06f76c63          	bltu	a4,a5,8020043a <interrupt_handler+0x82>
    802003c6:	00000717          	auipc	a4,0x0
    802003ca:	79670713          	addi	a4,a4,1942 # 80200b5c <etext+0x116>
    802003ce:	078a                	slli	a5,a5,0x2
    802003d0:	97ba                	add	a5,a5,a4
    802003d2:	439c                	lw	a5,0(a5)
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003d8:	00001517          	auipc	a0,0x1
    802003dc:	8a850513          	addi	a0,a0,-1880 # 80200c80 <etext+0x23a>
    802003e0:	b171                	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e2:	00001517          	auipc	a0,0x1
    802003e6:	87e50513          	addi	a0,a0,-1922 # 80200c60 <etext+0x21a>
    802003ea:	b149                	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	83450513          	addi	a0,a0,-1996 # 80200c20 <etext+0x1da>
    802003f4:	b9a5                	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003f6:	00001517          	auipc	a0,0x1
    802003fa:	84a50513          	addi	a0,a0,-1974 # 80200c40 <etext+0x1fa>
    802003fe:	b1bd                	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200400:	00001517          	auipc	a0,0x1
    80200404:	8b050513          	addi	a0,a0,-1872 # 80200cb0 <etext+0x26a>
    80200408:	b195                	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040a:	1141                	addi	sp,sp,-16
    8020040c:	e406                	sd	ra,8(sp)
    8020040e:	e022                	sd	s0,0(sp)
	    clock_set_next_event();
    80200410:	d51ff0ef          	jal	ra,80200160 <clock_set_next_event>
            ticks++;
    80200414:	00004717          	auipc	a4,0x4
    80200418:	c0c70713          	addi	a4,a4,-1012 # 80204020 <ticks>
    8020041c:	631c                	ld	a5,0(a4)
            if(ticks==100){
    8020041e:	06400693          	li	a3,100
            ticks++;
    80200422:	0785                	addi	a5,a5,1
    80200424:	00004617          	auipc	a2,0x4
    80200428:	bef63e23          	sd	a5,-1028(a2) # 80204020 <ticks>
            if(ticks==100){
    8020042c:	631c                	ld	a5,0(a4)
    8020042e:	00d78763          	beq	a5,a3,8020043c <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200432:	60a2                	ld	ra,8(sp)
    80200434:	6402                	ld	s0,0(sp)
    80200436:	0141                	addi	sp,sp,16
    80200438:	8082                	ret
            print_trapframe(tf);
    8020043a:	bf39                	j	80200358 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020043c:	06400593          	li	a1,100
    80200440:	00001517          	auipc	a0,0x1
    80200444:	86050513          	addi	a0,a0,-1952 # 80200ca0 <etext+0x25a>
              ticks=0;
    80200448:	00004797          	auipc	a5,0x4
    8020044c:	bc07bc23          	sd	zero,-1064(a5) # 80204020 <ticks>
              if(num==10){
    80200450:	00004417          	auipc	s0,0x4
    80200454:	bc040413          	addi	s0,s0,-1088 # 80204010 <edata>
    cprintf("%d ticks\n", TICK_NUM);
    80200458:	c15ff0ef          	jal	ra,8020006c <cprintf>
              if(num==10){
    8020045c:	6018                	ld	a4,0(s0)
    8020045e:	47a9                	li	a5,10
    80200460:	00f70963          	beq	a4,a5,80200472 <interrupt_handler+0xba>
             num++;
    80200464:	601c                	ld	a5,0(s0)
    80200466:	0785                	addi	a5,a5,1
    80200468:	00004717          	auipc	a4,0x4
    8020046c:	baf73423          	sd	a5,-1112(a4) # 80204010 <edata>
    80200470:	b7c9                	j	80200432 <interrupt_handler+0x7a>
                sbi_shutdown();
    80200472:	580000ef          	jal	ra,802009f2 <sbi_shutdown>
    80200476:	b7fd                	j	80200464 <interrupt_handler+0xac>

0000000080200478 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200478:	11853783          	ld	a5,280(a0)
    8020047c:	472d                	li	a4,11
    8020047e:	02f76763          	bltu	a4,a5,802004ac <exception_handler+0x34>
    80200482:	4705                	li	a4,1
    80200484:	00f71733          	sll	a4,a4,a5
    80200488:	6785                	lui	a5,0x1
    8020048a:	17cd                	addi	a5,a5,-13
    8020048c:	8ff9                	and	a5,a5,a4
    8020048e:	ef91                	bnez	a5,802004aa <exception_handler+0x32>
void exception_handler(struct trapframe *tf) {
    80200490:	1141                	addi	sp,sp,-16
    80200492:	e022                	sd	s0,0(sp)
    80200494:	e406                	sd	ra,8(sp)
    80200496:	00877793          	andi	a5,a4,8
    8020049a:	842a                	mv	s0,a0
    8020049c:	e3a1                	bnez	a5,802004dc <exception_handler+0x64>
    8020049e:	8b11                	andi	a4,a4,4
    802004a0:	e719                	bnez	a4,802004ae <exception_handler+0x36>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a2:	6402                	ld	s0,0(sp)
    802004a4:	60a2                	ld	ra,8(sp)
    802004a6:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004a8:	bd45                	j	80200358 <print_trapframe>
    802004aa:	8082                	ret
    802004ac:	b575                	j	80200358 <print_trapframe>
	cprintf("Exception type:Illegal instruction\n");
    802004ae:	00000517          	auipc	a0,0x0
    802004b2:	6e250513          	addi	a0,a0,1762 # 80200b90 <etext+0x14a>
    802004b6:	bb7ff0ef          	jal	ra,8020006c <cprintf>
        cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004ba:	10843583          	ld	a1,264(s0)
    802004be:	00000517          	auipc	a0,0x0
    802004c2:	6fa50513          	addi	a0,a0,1786 # 80200bb8 <etext+0x172>
    802004c6:	ba7ff0ef          	jal	ra,8020006c <cprintf>
        tf->epc += 4;
    802004ca:	10843783          	ld	a5,264(s0)
}
    802004ce:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
    802004d0:	0791                	addi	a5,a5,4
    802004d2:	10f43423          	sd	a5,264(s0)
}
    802004d6:	6402                	ld	s0,0(sp)
    802004d8:	0141                	addi	sp,sp,16
    802004da:	8082                	ret
	cprintf("Exception type: breakpoint\n");
    802004dc:	00000517          	auipc	a0,0x0
    802004e0:	70450513          	addi	a0,a0,1796 # 80200be0 <etext+0x19a>
    802004e4:	b89ff0ef          	jal	ra,8020006c <cprintf>
        cprintf("Iebreak caught at 0x%08x\n", tf->epc);
    802004e8:	10843583          	ld	a1,264(s0)
    802004ec:	00000517          	auipc	a0,0x0
    802004f0:	71450513          	addi	a0,a0,1812 # 80200c00 <etext+0x1ba>
    802004f4:	b79ff0ef          	jal	ra,8020006c <cprintf>
        tf->epc += 4;
    802004f8:	10843783          	ld	a5,264(s0)
}
    802004fc:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
    802004fe:	0791                	addi	a5,a5,4
    80200500:	10f43423          	sd	a5,264(s0)
}
    80200504:	6402                	ld	s0,0(sp)
    80200506:	0141                	addi	sp,sp,16
    80200508:	8082                	ret

000000008020050a <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020050a:	11853783          	ld	a5,280(a0)
    8020050e:	0007c363          	bltz	a5,80200514 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200512:	b79d                	j	80200478 <exception_handler>
        interrupt_handler(tf);
    80200514:	b555                	j	802003b8 <interrupt_handler>
	...

0000000080200518 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200518:	14011073          	csrw	sscratch,sp
    8020051c:	712d                	addi	sp,sp,-288
    8020051e:	e002                	sd	zero,0(sp)
    80200520:	e406                	sd	ra,8(sp)
    80200522:	ec0e                	sd	gp,24(sp)
    80200524:	f012                	sd	tp,32(sp)
    80200526:	f416                	sd	t0,40(sp)
    80200528:	f81a                	sd	t1,48(sp)
    8020052a:	fc1e                	sd	t2,56(sp)
    8020052c:	e0a2                	sd	s0,64(sp)
    8020052e:	e4a6                	sd	s1,72(sp)
    80200530:	e8aa                	sd	a0,80(sp)
    80200532:	ecae                	sd	a1,88(sp)
    80200534:	f0b2                	sd	a2,96(sp)
    80200536:	f4b6                	sd	a3,104(sp)
    80200538:	f8ba                	sd	a4,112(sp)
    8020053a:	fcbe                	sd	a5,120(sp)
    8020053c:	e142                	sd	a6,128(sp)
    8020053e:	e546                	sd	a7,136(sp)
    80200540:	e94a                	sd	s2,144(sp)
    80200542:	ed4e                	sd	s3,152(sp)
    80200544:	f152                	sd	s4,160(sp)
    80200546:	f556                	sd	s5,168(sp)
    80200548:	f95a                	sd	s6,176(sp)
    8020054a:	fd5e                	sd	s7,184(sp)
    8020054c:	e1e2                	sd	s8,192(sp)
    8020054e:	e5e6                	sd	s9,200(sp)
    80200550:	e9ea                	sd	s10,208(sp)
    80200552:	edee                	sd	s11,216(sp)
    80200554:	f1f2                	sd	t3,224(sp)
    80200556:	f5f6                	sd	t4,232(sp)
    80200558:	f9fa                	sd	t5,240(sp)
    8020055a:	fdfe                	sd	t6,248(sp)
    8020055c:	14001473          	csrrw	s0,sscratch,zero
    80200560:	100024f3          	csrr	s1,sstatus
    80200564:	14102973          	csrr	s2,sepc
    80200568:	143029f3          	csrr	s3,stval
    8020056c:	14202a73          	csrr	s4,scause
    80200570:	e822                	sd	s0,16(sp)
    80200572:	e226                	sd	s1,256(sp)
    80200574:	e64a                	sd	s2,264(sp)
    80200576:	ea4e                	sd	s3,272(sp)
    80200578:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020057a:	850a                	mv	a0,sp
    jal trap
    8020057c:	f8fff0ef          	jal	ra,8020050a <trap>

0000000080200580 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200580:	6492                	ld	s1,256(sp)
    80200582:	6932                	ld	s2,264(sp)
    80200584:	10049073          	csrw	sstatus,s1
    80200588:	14191073          	csrw	sepc,s2
    8020058c:	60a2                	ld	ra,8(sp)
    8020058e:	61e2                	ld	gp,24(sp)
    80200590:	7202                	ld	tp,32(sp)
    80200592:	72a2                	ld	t0,40(sp)
    80200594:	7342                	ld	t1,48(sp)
    80200596:	73e2                	ld	t2,56(sp)
    80200598:	6406                	ld	s0,64(sp)
    8020059a:	64a6                	ld	s1,72(sp)
    8020059c:	6546                	ld	a0,80(sp)
    8020059e:	65e6                	ld	a1,88(sp)
    802005a0:	7606                	ld	a2,96(sp)
    802005a2:	76a6                	ld	a3,104(sp)
    802005a4:	7746                	ld	a4,112(sp)
    802005a6:	77e6                	ld	a5,120(sp)
    802005a8:	680a                	ld	a6,128(sp)
    802005aa:	68aa                	ld	a7,136(sp)
    802005ac:	694a                	ld	s2,144(sp)
    802005ae:	69ea                	ld	s3,152(sp)
    802005b0:	7a0a                	ld	s4,160(sp)
    802005b2:	7aaa                	ld	s5,168(sp)
    802005b4:	7b4a                	ld	s6,176(sp)
    802005b6:	7bea                	ld	s7,184(sp)
    802005b8:	6c0e                	ld	s8,192(sp)
    802005ba:	6cae                	ld	s9,200(sp)
    802005bc:	6d4e                	ld	s10,208(sp)
    802005be:	6dee                	ld	s11,216(sp)
    802005c0:	7e0e                	ld	t3,224(sp)
    802005c2:	7eae                	ld	t4,232(sp)
    802005c4:	7f4e                	ld	t5,240(sp)
    802005c6:	7fee                	ld	t6,248(sp)
    802005c8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ca:	10200073          	sret

00000000802005ce <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ce:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005d2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005d4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005d8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005da:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005de:	f022                	sd	s0,32(sp)
    802005e0:	ec26                	sd	s1,24(sp)
    802005e2:	e84a                	sd	s2,16(sp)
    802005e4:	f406                	sd	ra,40(sp)
    802005e6:	e44e                	sd	s3,8(sp)
    802005e8:	84aa                	mv	s1,a0
    802005ea:	892e                	mv	s2,a1
    802005ec:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005f0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005f2:	03067e63          	bgeu	a2,a6,8020062e <printnum+0x60>
    802005f6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005f8:	00805763          	blez	s0,80200606 <printnum+0x38>
    802005fc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005fe:	85ca                	mv	a1,s2
    80200600:	854e                	mv	a0,s3
    80200602:	9482                	jalr	s1
        while (-- width > 0)
    80200604:	fc65                	bnez	s0,802005fc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200606:	1a02                	slli	s4,s4,0x20
    80200608:	020a5a13          	srli	s4,s4,0x20
    8020060c:	00001797          	auipc	a5,0x1
    80200610:	bcc78793          	addi	a5,a5,-1076 # 802011d8 <error_string+0x38>
    80200614:	9a3e                	add	s4,s4,a5
}
    80200616:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200618:	000a4503          	lbu	a0,0(s4)
}
    8020061c:	70a2                	ld	ra,40(sp)
    8020061e:	69a2                	ld	s3,8(sp)
    80200620:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200622:	85ca                	mv	a1,s2
    80200624:	8326                	mv	t1,s1
}
    80200626:	6942                	ld	s2,16(sp)
    80200628:	64e2                	ld	s1,24(sp)
    8020062a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020062c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020062e:	03065633          	divu	a2,a2,a6
    80200632:	8722                	mv	a4,s0
    80200634:	f9bff0ef          	jal	ra,802005ce <printnum>
    80200638:	b7f9                	j	80200606 <printnum+0x38>

000000008020063a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020063a:	7119                	addi	sp,sp,-128
    8020063c:	f4a6                	sd	s1,104(sp)
    8020063e:	f0ca                	sd	s2,96(sp)
    80200640:	e8d2                	sd	s4,80(sp)
    80200642:	e4d6                	sd	s5,72(sp)
    80200644:	e0da                	sd	s6,64(sp)
    80200646:	fc5e                	sd	s7,56(sp)
    80200648:	f862                	sd	s8,48(sp)
    8020064a:	f06a                	sd	s10,32(sp)
    8020064c:	fc86                	sd	ra,120(sp)
    8020064e:	f8a2                	sd	s0,112(sp)
    80200650:	ecce                	sd	s3,88(sp)
    80200652:	f466                	sd	s9,40(sp)
    80200654:	ec6e                	sd	s11,24(sp)
    80200656:	892a                	mv	s2,a0
    80200658:	84ae                	mv	s1,a1
    8020065a:	8d32                	mv	s10,a2
    8020065c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020065e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200660:	00001a17          	auipc	s4,0x1
    80200664:	9e4a0a13          	addi	s4,s4,-1564 # 80201044 <etext+0x5fe>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200668:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020066c:	00001c17          	auipc	s8,0x1
    80200670:	b34c0c13          	addi	s8,s8,-1228 # 802011a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200674:	000d4503          	lbu	a0,0(s10)
    80200678:	02500793          	li	a5,37
    8020067c:	001d0413          	addi	s0,s10,1
    80200680:	00f50e63          	beq	a0,a5,8020069c <vprintfmt+0x62>
            if (ch == '\0') {
    80200684:	c521                	beqz	a0,802006cc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200686:	02500993          	li	s3,37
    8020068a:	a011                	j	8020068e <vprintfmt+0x54>
            if (ch == '\0') {
    8020068c:	c121                	beqz	a0,802006cc <vprintfmt+0x92>
            putch(ch, putdat);
    8020068e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200690:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200692:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200694:	fff44503          	lbu	a0,-1(s0)
    80200698:	ff351ae3          	bne	a0,s3,8020068c <vprintfmt+0x52>
    8020069c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006a0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006a4:	4981                	li	s3,0
    802006a6:	4801                	li	a6,0
        width = precision = -1;
    802006a8:	5cfd                	li	s9,-1
    802006aa:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006ac:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006b0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006b2:	fdd6069b          	addiw	a3,a2,-35
    802006b6:	0ff6f693          	andi	a3,a3,255
    802006ba:	00140d13          	addi	s10,s0,1
    802006be:	1ed5ef63          	bltu	a1,a3,802008bc <vprintfmt+0x282>
    802006c2:	068a                	slli	a3,a3,0x2
    802006c4:	96d2                	add	a3,a3,s4
    802006c6:	4294                	lw	a3,0(a3)
    802006c8:	96d2                	add	a3,a3,s4
    802006ca:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006cc:	70e6                	ld	ra,120(sp)
    802006ce:	7446                	ld	s0,112(sp)
    802006d0:	74a6                	ld	s1,104(sp)
    802006d2:	7906                	ld	s2,96(sp)
    802006d4:	69e6                	ld	s3,88(sp)
    802006d6:	6a46                	ld	s4,80(sp)
    802006d8:	6aa6                	ld	s5,72(sp)
    802006da:	6b06                	ld	s6,64(sp)
    802006dc:	7be2                	ld	s7,56(sp)
    802006de:	7c42                	ld	s8,48(sp)
    802006e0:	7ca2                	ld	s9,40(sp)
    802006e2:	7d02                	ld	s10,32(sp)
    802006e4:	6de2                	ld	s11,24(sp)
    802006e6:	6109                	addi	sp,sp,128
    802006e8:	8082                	ret
            padc = '-';
    802006ea:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
    802006ec:	00144603          	lbu	a2,1(s0)
    802006f0:	846a                	mv	s0,s10
    802006f2:	b7c1                	j	802006b2 <vprintfmt+0x78>
            precision = va_arg(ap, int);
    802006f4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802006f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802006fc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802006fe:	846a                	mv	s0,s10
            if (width < 0)
    80200700:	fa0dd9e3          	bgez	s11,802006b2 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200704:	8de6                	mv	s11,s9
    80200706:	5cfd                	li	s9,-1
    80200708:	b76d                	j	802006b2 <vprintfmt+0x78>
            if (width < 0)
    8020070a:	fffdc693          	not	a3,s11
    8020070e:	96fd                	srai	a3,a3,0x3f
    80200710:	00ddfdb3          	and	s11,s11,a3
    80200714:	00144603          	lbu	a2,1(s0)
    80200718:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020071a:	846a                	mv	s0,s10
    8020071c:	bf59                	j	802006b2 <vprintfmt+0x78>
    if (lflag >= 2) {
    8020071e:	4705                	li	a4,1
    80200720:	008a8593          	addi	a1,s5,8
    80200724:	01074463          	blt	a4,a6,8020072c <vprintfmt+0xf2>
    else if (lflag) {
    80200728:	22080863          	beqz	a6,80200958 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
    8020072c:	000ab603          	ld	a2,0(s5)
    80200730:	46c1                	li	a3,16
    80200732:	8aae                	mv	s5,a1
    80200734:	a291                	j	80200878 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
    80200736:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020073a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020073e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200740:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200744:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200748:	fad56ce3          	bltu	a0,a3,80200700 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
    8020074c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020074e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200752:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200756:	0196873b          	addw	a4,a3,s9
    8020075a:	0017171b          	slliw	a4,a4,0x1
    8020075e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200762:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200766:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020076a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020076e:	fcd57fe3          	bgeu	a0,a3,8020074c <vprintfmt+0x112>
    80200772:	b779                	j	80200700 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
    80200774:	000aa503          	lw	a0,0(s5)
    80200778:	85a6                	mv	a1,s1
    8020077a:	0aa1                	addi	s5,s5,8
    8020077c:	9902                	jalr	s2
            break;
    8020077e:	bddd                	j	80200674 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200780:	4705                	li	a4,1
    80200782:	008a8993          	addi	s3,s5,8
    80200786:	01074463          	blt	a4,a6,8020078e <vprintfmt+0x154>
    else if (lflag) {
    8020078a:	1c080463          	beqz	a6,80200952 <vprintfmt+0x318>
        return va_arg(*ap, long);
    8020078e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200792:	1c044a63          	bltz	s0,80200966 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
    80200796:	8622                	mv	a2,s0
    80200798:	8ace                	mv	s5,s3
    8020079a:	46a9                	li	a3,10
    8020079c:	a8f1                	j	80200878 <vprintfmt+0x23e>
            err = va_arg(ap, int);
    8020079e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007a2:	4719                	li	a4,6
            err = va_arg(ap, int);
    802007a4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802007a6:	41f7d69b          	sraiw	a3,a5,0x1f
    802007aa:	8fb5                	xor	a5,a5,a3
    802007ac:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007b0:	12d74963          	blt	a4,a3,802008e2 <vprintfmt+0x2a8>
    802007b4:	00369793          	slli	a5,a3,0x3
    802007b8:	97e2                	add	a5,a5,s8
    802007ba:	639c                	ld	a5,0(a5)
    802007bc:	12078363          	beqz	a5,802008e2 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
    802007c0:	86be                	mv	a3,a5
    802007c2:	00001617          	auipc	a2,0x1
    802007c6:	ac660613          	addi	a2,a2,-1338 # 80201288 <error_string+0xe8>
    802007ca:	85a6                	mv	a1,s1
    802007cc:	854a                	mv	a0,s2
    802007ce:	1cc000ef          	jal	ra,8020099a <printfmt>
    802007d2:	b54d                	j	80200674 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007d4:	000ab603          	ld	a2,0(s5)
    802007d8:	0aa1                	addi	s5,s5,8
    802007da:	1a060163          	beqz	a2,8020097c <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
    802007de:	00160413          	addi	s0,a2,1
    802007e2:	15b05763          	blez	s11,80200930 <vprintfmt+0x2f6>
    802007e6:	02d00593          	li	a1,45
    802007ea:	10b79d63          	bne	a5,a1,80200904 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007ee:	00064783          	lbu	a5,0(a2)
    802007f2:	0007851b          	sext.w	a0,a5
    802007f6:	c905                	beqz	a0,80200826 <vprintfmt+0x1ec>
    802007f8:	000cc563          	bltz	s9,80200802 <vprintfmt+0x1c8>
    802007fc:	3cfd                	addiw	s9,s9,-1
    802007fe:	036c8263          	beq	s9,s6,80200822 <vprintfmt+0x1e8>
                    putch('?', putdat);
    80200802:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200804:	14098f63          	beqz	s3,80200962 <vprintfmt+0x328>
    80200808:	3781                	addiw	a5,a5,-32
    8020080a:	14fbfc63          	bgeu	s7,a5,80200962 <vprintfmt+0x328>
                    putch('?', putdat);
    8020080e:	03f00513          	li	a0,63
    80200812:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200814:	0405                	addi	s0,s0,1
    80200816:	fff44783          	lbu	a5,-1(s0)
    8020081a:	3dfd                	addiw	s11,s11,-1
    8020081c:	0007851b          	sext.w	a0,a5
    80200820:	fd61                	bnez	a0,802007f8 <vprintfmt+0x1be>
            for (; width > 0; width --) {
    80200822:	e5b059e3          	blez	s11,80200674 <vprintfmt+0x3a>
    80200826:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200828:	85a6                	mv	a1,s1
    8020082a:	02000513          	li	a0,32
    8020082e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200830:	e40d82e3          	beqz	s11,80200674 <vprintfmt+0x3a>
    80200834:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200836:	85a6                	mv	a1,s1
    80200838:	02000513          	li	a0,32
    8020083c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020083e:	fe0d94e3          	bnez	s11,80200826 <vprintfmt+0x1ec>
    80200842:	bd0d                	j	80200674 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200844:	4705                	li	a4,1
    80200846:	008a8593          	addi	a1,s5,8
    8020084a:	01074463          	blt	a4,a6,80200852 <vprintfmt+0x218>
    else if (lflag) {
    8020084e:	0e080863          	beqz	a6,8020093e <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
    80200852:	000ab603          	ld	a2,0(s5)
    80200856:	46a1                	li	a3,8
    80200858:	8aae                	mv	s5,a1
    8020085a:	a839                	j	80200878 <vprintfmt+0x23e>
            putch('0', putdat);
    8020085c:	03000513          	li	a0,48
    80200860:	85a6                	mv	a1,s1
    80200862:	e03e                	sd	a5,0(sp)
    80200864:	9902                	jalr	s2
            putch('x', putdat);
    80200866:	85a6                	mv	a1,s1
    80200868:	07800513          	li	a0,120
    8020086c:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020086e:	0aa1                	addi	s5,s5,8
    80200870:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200874:	6782                	ld	a5,0(sp)
    80200876:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200878:	2781                	sext.w	a5,a5
    8020087a:	876e                	mv	a4,s11
    8020087c:	85a6                	mv	a1,s1
    8020087e:	854a                	mv	a0,s2
    80200880:	d4fff0ef          	jal	ra,802005ce <printnum>
            break;
    80200884:	bbc5                	j	80200674 <vprintfmt+0x3a>
            lflag ++;
    80200886:	00144603          	lbu	a2,1(s0)
    8020088a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020088c:	846a                	mv	s0,s10
            goto reswitch;
    8020088e:	b515                	j	802006b2 <vprintfmt+0x78>
            goto reswitch;
    80200890:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200894:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200896:	846a                	mv	s0,s10
            goto reswitch;
    80200898:	bd29                	j	802006b2 <vprintfmt+0x78>
            putch(ch, putdat);
    8020089a:	85a6                	mv	a1,s1
    8020089c:	02500513          	li	a0,37
    802008a0:	9902                	jalr	s2
            break;
    802008a2:	bbc9                	j	80200674 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008a4:	4705                	li	a4,1
    802008a6:	008a8593          	addi	a1,s5,8
    802008aa:	01074463          	blt	a4,a6,802008b2 <vprintfmt+0x278>
    else if (lflag) {
    802008ae:	08080d63          	beqz	a6,80200948 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
    802008b2:	000ab603          	ld	a2,0(s5)
    802008b6:	46a9                	li	a3,10
    802008b8:	8aae                	mv	s5,a1
    802008ba:	bf7d                	j	80200878 <vprintfmt+0x23e>
            putch('%', putdat);
    802008bc:	85a6                	mv	a1,s1
    802008be:	02500513          	li	a0,37
    802008c2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008c4:	fff44703          	lbu	a4,-1(s0)
    802008c8:	02500793          	li	a5,37
    802008cc:	8d22                	mv	s10,s0
    802008ce:	daf703e3          	beq	a4,a5,80200674 <vprintfmt+0x3a>
    802008d2:	02500713          	li	a4,37
    802008d6:	1d7d                	addi	s10,s10,-1
    802008d8:	fffd4783          	lbu	a5,-1(s10)
    802008dc:	fee79de3          	bne	a5,a4,802008d6 <vprintfmt+0x29c>
    802008e0:	bb51                	j	80200674 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008e2:	00001617          	auipc	a2,0x1
    802008e6:	99660613          	addi	a2,a2,-1642 # 80201278 <error_string+0xd8>
    802008ea:	85a6                	mv	a1,s1
    802008ec:	854a                	mv	a0,s2
    802008ee:	0ac000ef          	jal	ra,8020099a <printfmt>
    802008f2:	b349                	j	80200674 <vprintfmt+0x3a>
                p = "(null)";
    802008f4:	00001617          	auipc	a2,0x1
    802008f8:	97c60613          	addi	a2,a2,-1668 # 80201270 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008fc:	00001417          	auipc	s0,0x1
    80200900:	97540413          	addi	s0,s0,-1675 # 80201271 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200904:	8532                	mv	a0,a2
    80200906:	85e6                	mv	a1,s9
    80200908:	e032                	sd	a2,0(sp)
    8020090a:	e43e                	sd	a5,8(sp)
    8020090c:	102000ef          	jal	ra,80200a0e <strnlen>
    80200910:	40ad8dbb          	subw	s11,s11,a0
    80200914:	6602                	ld	a2,0(sp)
    80200916:	01b05d63          	blez	s11,80200930 <vprintfmt+0x2f6>
    8020091a:	67a2                	ld	a5,8(sp)
    8020091c:	2781                	sext.w	a5,a5
    8020091e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200920:	6522                	ld	a0,8(sp)
    80200922:	85a6                	mv	a1,s1
    80200924:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200926:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200928:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020092a:	6602                	ld	a2,0(sp)
    8020092c:	fe0d9ae3          	bnez	s11,80200920 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200930:	00064783          	lbu	a5,0(a2)
    80200934:	0007851b          	sext.w	a0,a5
    80200938:	ec0510e3          	bnez	a0,802007f8 <vprintfmt+0x1be>
    8020093c:	bb25                	j	80200674 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
    8020093e:	000ae603          	lwu	a2,0(s5)
    80200942:	46a1                	li	a3,8
    80200944:	8aae                	mv	s5,a1
    80200946:	bf0d                	j	80200878 <vprintfmt+0x23e>
    80200948:	000ae603          	lwu	a2,0(s5)
    8020094c:	46a9                	li	a3,10
    8020094e:	8aae                	mv	s5,a1
    80200950:	b725                	j	80200878 <vprintfmt+0x23e>
        return va_arg(*ap, int);
    80200952:	000aa403          	lw	s0,0(s5)
    80200956:	bd35                	j	80200792 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
    80200958:	000ae603          	lwu	a2,0(s5)
    8020095c:	46c1                	li	a3,16
    8020095e:	8aae                	mv	s5,a1
    80200960:	bf21                	j	80200878 <vprintfmt+0x23e>
                    putch(ch, putdat);
    80200962:	9902                	jalr	s2
    80200964:	bd45                	j	80200814 <vprintfmt+0x1da>
                putch('-', putdat);
    80200966:	85a6                	mv	a1,s1
    80200968:	02d00513          	li	a0,45
    8020096c:	e03e                	sd	a5,0(sp)
    8020096e:	9902                	jalr	s2
                num = -(long long)num;
    80200970:	8ace                	mv	s5,s3
    80200972:	40800633          	neg	a2,s0
    80200976:	46a9                	li	a3,10
    80200978:	6782                	ld	a5,0(sp)
    8020097a:	bdfd                	j	80200878 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
    8020097c:	01b05663          	blez	s11,80200988 <vprintfmt+0x34e>
    80200980:	02d00693          	li	a3,45
    80200984:	f6d798e3          	bne	a5,a3,802008f4 <vprintfmt+0x2ba>
    80200988:	00001417          	auipc	s0,0x1
    8020098c:	8e940413          	addi	s0,s0,-1815 # 80201271 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200990:	02800513          	li	a0,40
    80200994:	02800793          	li	a5,40
    80200998:	b585                	j	802007f8 <vprintfmt+0x1be>

000000008020099a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020099a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    8020099c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a4:	ec06                	sd	ra,24(sp)
    802009a6:	f83a                	sd	a4,48(sp)
    802009a8:	fc3e                	sd	a5,56(sp)
    802009aa:	e0c2                	sd	a6,64(sp)
    802009ac:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ae:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009b0:	c8bff0ef          	jal	ra,8020063a <vprintfmt>
}
    802009b4:	60e2                	ld	ra,24(sp)
    802009b6:	6161                	addi	sp,sp,80
    802009b8:	8082                	ret

00000000802009ba <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009ba:	00003797          	auipc	a5,0x3
    802009be:	64678793          	addi	a5,a5,1606 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009c2:	6398                	ld	a4,0(a5)
    802009c4:	4781                	li	a5,0
    802009c6:	88ba                	mv	a7,a4
    802009c8:	852a                	mv	a0,a0
    802009ca:	85be                	mv	a1,a5
    802009cc:	863e                	mv	a2,a5
    802009ce:	00000073          	ecall
    802009d2:	87aa                	mv	a5,a0
}
    802009d4:	8082                	ret

00000000802009d6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009d6:	00003797          	auipc	a5,0x3
    802009da:	64278793          	addi	a5,a5,1602 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009de:	6398                	ld	a4,0(a5)
    802009e0:	4781                	li	a5,0
    802009e2:	88ba                	mv	a7,a4
    802009e4:	852a                	mv	a0,a0
    802009e6:	85be                	mv	a1,a5
    802009e8:	863e                	mv	a2,a5
    802009ea:	00000073          	ecall
    802009ee:	87aa                	mv	a5,a0
}
    802009f0:	8082                	ret

00000000802009f2 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009f2:	00003797          	auipc	a5,0x3
    802009f6:	61678793          	addi	a5,a5,1558 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009fa:	6398                	ld	a4,0(a5)
    802009fc:	4781                	li	a5,0
    802009fe:	88ba                	mv	a7,a4
    80200a00:	853e                	mv	a0,a5
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0
    80200a0c:	8082                	ret

0000000080200a0e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a0e:	c185                	beqz	a1,80200a2e <strnlen+0x20>
    80200a10:	00054783          	lbu	a5,0(a0)
    80200a14:	cf89                	beqz	a5,80200a2e <strnlen+0x20>
    size_t cnt = 0;
    80200a16:	4781                	li	a5,0
    80200a18:	a021                	j	80200a20 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a1a:	00074703          	lbu	a4,0(a4)
    80200a1e:	c711                	beqz	a4,80200a2a <strnlen+0x1c>
        cnt ++;
    80200a20:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a22:	00f50733          	add	a4,a0,a5
    80200a26:	fef59ae3          	bne	a1,a5,80200a1a <strnlen+0xc>
    }
    return cnt;
}
    80200a2a:	853e                	mv	a0,a5
    80200a2c:	8082                	ret
    size_t cnt = 0;
    80200a2e:	4781                	li	a5,0
}
    80200a30:	853e                	mv	a0,a5
    80200a32:	8082                	ret

0000000080200a34 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a34:	ca01                	beqz	a2,80200a44 <memset+0x10>
    80200a36:	962a                	add	a2,a2,a0
    char *p = s;
    80200a38:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a3a:	0785                	addi	a5,a5,1
    80200a3c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a40:	fec79de3          	bne	a5,a2,80200a3a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a44:	8082                	ret

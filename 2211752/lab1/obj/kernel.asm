
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
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01e60613          	addi	a2,a2,30 # 80204030 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	59c000ef          	jal	ra,802005be <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9e658593          	addi	a1,a1,-1562 # 80200a10 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9fe50513          	addi	a0,a0,-1538 # 80200a30 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <SBI_SET_TIMER>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
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
    80200094:	5a8000ef          	jal	ra,8020063c <vprintfmt>
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
    802000a6:	99650513          	addi	a0,a0,-1642 # 80200a38 <etext+0x2c>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9a050513          	addi	a0,a0,-1632 # 80200a58 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	94858593          	addi	a1,a1,-1720 # 80200a0c <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9ac50513          	addi	a0,a0,-1620 # 80200a78 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9b850513          	addi	a0,a0,-1608 # 80200a98 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f4458593          	addi	a1,a1,-188 # 80204030 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9c450513          	addi	a0,a0,-1596 # 80200ab8 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32f58593          	addi	a1,a1,815 # 8020442f <end+0x3ff>
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
    80200126:	9b650513          	addi	a0,a0,-1610 # 80200ad8 <etext+0xcc>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

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
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	093000ef          	jal	ra,802009d8 <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	9b450513          	addi	a0,a0,-1612 # 80200b08 <etext+0xfc>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	06d0006f          	j	802009d8 <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	zext.b	a0,a0
    80200176:	0490006f          	j	802009be <sbi_console_putchar>

000000008020017a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	36878793          	addi	a5,a5,872 # 802004ec <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	98e50513          	addi	a0,a0,-1650 # 80200b28 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	99650513          	addi	a0,a0,-1642 # 80200b40 <etext+0x134>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	9a050513          	addi	a0,a0,-1632 # 80200b58 <etext+0x14c>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	9aa50513          	addi	a0,a0,-1622 # 80200b70 <etext+0x164>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	9b450513          	addi	a0,a0,-1612 # 80200b88 <etext+0x17c>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9be50513          	addi	a0,a0,-1602 # 80200ba0 <etext+0x194>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9c850513          	addi	a0,a0,-1592 # 80200bb8 <etext+0x1ac>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9d250513          	addi	a0,a0,-1582 # 80200bd0 <etext+0x1c4>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9dc50513          	addi	a0,a0,-1572 # 80200be8 <etext+0x1dc>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9e650513          	addi	a0,a0,-1562 # 80200c00 <etext+0x1f4>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9f050513          	addi	a0,a0,-1552 # 80200c18 <etext+0x20c>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	9fa50513          	addi	a0,a0,-1542 # 80200c30 <etext+0x224>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	a0450513          	addi	a0,a0,-1532 # 80200c48 <etext+0x23c>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	a0e50513          	addi	a0,a0,-1522 # 80200c60 <etext+0x254>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a1850513          	addi	a0,a0,-1512 # 80200c78 <etext+0x26c>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a2250513          	addi	a0,a0,-1502 # 80200c90 <etext+0x284>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a2c50513          	addi	a0,a0,-1492 # 80200ca8 <etext+0x29c>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a3650513          	addi	a0,a0,-1482 # 80200cc0 <etext+0x2b4>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a4050513          	addi	a0,a0,-1472 # 80200cd8 <etext+0x2cc>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a4a50513          	addi	a0,a0,-1462 # 80200cf0 <etext+0x2e4>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a5450513          	addi	a0,a0,-1452 # 80200d08 <etext+0x2fc>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a5e50513          	addi	a0,a0,-1442 # 80200d20 <etext+0x314>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a6850513          	addi	a0,a0,-1432 # 80200d38 <etext+0x32c>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a7250513          	addi	a0,a0,-1422 # 80200d50 <etext+0x344>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a7c50513          	addi	a0,a0,-1412 # 80200d68 <etext+0x35c>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a8650513          	addi	a0,a0,-1402 # 80200d80 <etext+0x374>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a9050513          	addi	a0,a0,-1392 # 80200d98 <etext+0x38c>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a9a50513          	addi	a0,a0,-1382 # 80200db0 <etext+0x3a4>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	aa450513          	addi	a0,a0,-1372 # 80200dc8 <etext+0x3bc>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	aae50513          	addi	a0,a0,-1362 # 80200de0 <etext+0x3d4>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	ab850513          	addi	a0,a0,-1352 # 80200df8 <etext+0x3ec>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	abe50513          	addi	a0,a0,-1346 # 80200e10 <etext+0x404>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	ac250513          	addi	a0,a0,-1342 # 80200e28 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	ac250513          	addi	a0,a0,-1342 # 80200e40 <etext+0x434>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	aca50513          	addi	a0,a0,-1334 # 80200e58 <etext+0x44c>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	ad250513          	addi	a0,a0,-1326 # 80200e70 <etext+0x464>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	ad650513          	addi	a0,a0,-1322 # 80200e88 <etext+0x47c>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76763          	bltu	a4,a5,80200436 <interrupt_handler+0x78>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b8470713          	addi	a4,a4,-1148 # 80200f50 <etext+0x544>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	b2250513          	addi	a0,a0,-1246 # 80200f00 <etext+0x4f4>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	af850513          	addi	a0,a0,-1288 # 80200ee0 <etext+0x4d4>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	aae50513          	addi	a0,a0,-1362 # 80200ea0 <etext+0x494>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	ac450513          	addi	a0,a0,-1340 # 80200ec0 <etext+0x4b4>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */

            clock_set_next_event();
    8020040a:	d57ff0ef          	jal	ra,80200160 <clock_set_next_event>
            tick_count++;
    8020040e:	00004797          	auipc	a5,0x4
    80200412:	c1278793          	addi	a5,a5,-1006 # 80204020 <tick_count>
    80200416:	6398                	ld	a4,0(a5)
            
            
            if (tick_count == TICK_NUM) {
    80200418:	06400693          	li	a3,100
            tick_count++;
    8020041c:	0705                	addi	a4,a4,1
    8020041e:	e398                	sd	a4,0(a5)
            if (tick_count == TICK_NUM) {
    80200420:	639c                	ld	a5,0(a5)
    80200422:	00d78b63          	beq	a5,a3,80200438 <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200426:	60a2                	ld	ra,8(sp)
    80200428:	0141                	addi	sp,sp,16
    8020042a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020042c:	00001517          	auipc	a0,0x1
    80200430:	b0450513          	addi	a0,a0,-1276 # 80200f30 <etext+0x524>
    80200434:	b91d                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200436:	b725                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200438:	06400593          	li	a1,100
    8020043c:	00001517          	auipc	a0,0x1
    80200440:	ae450513          	addi	a0,a0,-1308 # 80200f20 <etext+0x514>
    80200444:	c27ff0ef          	jal	ra,8020006a <cprintf>
                tick_count = 0;
    80200448:	00004797          	auipc	a5,0x4
    8020044c:	bc07bc23          	sd	zero,-1064(a5) # 80204020 <tick_count>
                num++;
    80200450:	00004797          	auipc	a5,0x4
    80200454:	bc878793          	addi	a5,a5,-1080 # 80204018 <num>
    80200458:	6398                	ld	a4,0(a5)
                if (num == 10) {
    8020045a:	46a9                	li	a3,10
                num++;
    8020045c:	0705                	addi	a4,a4,1
    8020045e:	e398                	sd	a4,0(a5)
                if (num == 10) {
    80200460:	639c                	ld	a5,0(a5)
    80200462:	fcd792e3          	bne	a5,a3,80200426 <interrupt_handler+0x68>
}
    80200466:	60a2                	ld	ra,8(sp)
    80200468:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    8020046a:	a361                	j	802009f2 <sbi_shutdown>

000000008020046c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200470:	1141                	addi	sp,sp,-16
    80200472:	e022                	sd	s0,0(sp)
    80200474:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200476:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200478:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020047a:	02e78f63          	beq	a5,a4,802004b8 <exception_handler+0x4c>
    8020047e:	02f76563          	bltu	a4,a5,802004a8 <exception_handler+0x3c>
    80200482:	4709                	li	a4,2
    80200484:	02e79663          	bne	a5,a4,802004b0 <exception_handler+0x44>
             /* LAB1 CHALLENGE3   YOUR CODE :  2211752*/
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type: Illegal instruction\n");
    80200488:	00001517          	auipc	a0,0x1
    8020048c:	af850513          	addi	a0,a0,-1288 # 80200f80 <etext+0x574>
    80200490:	bdbff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    80200494:	10843583          	ld	a1,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200498:	6402                	ld	s0,0(sp)
    8020049a:	60a2                	ld	ra,8(sp)
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    8020049c:	00001517          	auipc	a0,0x1
    802004a0:	b0c50513          	addi	a0,a0,-1268 # 80200fa8 <etext+0x59c>
}
    802004a4:	0141                	addi	sp,sp,16
            cprintf("Breakpoint caught at 0x%08x\n", tf->epc);
    802004a6:	b6d1                	j	8020006a <cprintf>
    switch (tf->cause) {
    802004a8:	17f1                	addi	a5,a5,-4
    802004aa:	471d                	li	a4,7
    802004ac:	02f76663          	bltu	a4,a5,802004d8 <exception_handler+0x6c>
}
    802004b0:	60a2                	ld	ra,8(sp)
    802004b2:	6402                	ld	s0,0(sp)
    802004b4:	0141                	addi	sp,sp,16
    802004b6:	8082                	ret
            cprintf("Exception type: Breakpoint\n");
    802004b8:	00001517          	auipc	a0,0x1
    802004bc:	b1850513          	addi	a0,a0,-1256 # 80200fd0 <etext+0x5c4>
    802004c0:	babff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Breakpoint caught at 0x%08x\n", tf->epc);
    802004c4:	10843583          	ld	a1,264(s0)
}
    802004c8:	6402                	ld	s0,0(sp)
    802004ca:	60a2                	ld	ra,8(sp)
            cprintf("Breakpoint caught at 0x%08x\n", tf->epc);
    802004cc:	00001517          	auipc	a0,0x1
    802004d0:	b2450513          	addi	a0,a0,-1244 # 80200ff0 <etext+0x5e4>
}
    802004d4:	0141                	addi	sp,sp,16
            cprintf("Breakpoint caught at 0x%08x\n", tf->epc);
    802004d6:	be51                	j	8020006a <cprintf>
}
    802004d8:	6402                	ld	s0,0(sp)
    802004da:	60a2                	ld	ra,8(sp)
    802004dc:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004de:	b541                	j	8020035e <print_trapframe>

00000000802004e0 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004e0:	11853783          	ld	a5,280(a0)
    802004e4:	0007c363          	bltz	a5,802004ea <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004e8:	b751                	j	8020046c <exception_handler>
        interrupt_handler(tf);
    802004ea:	bdd1                	j	802003be <interrupt_handler>

00000000802004ec <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004ec:	14011073          	csrw	sscratch,sp
    802004f0:	712d                	addi	sp,sp,-288
    802004f2:	e002                	sd	zero,0(sp)
    802004f4:	e406                	sd	ra,8(sp)
    802004f6:	ec0e                	sd	gp,24(sp)
    802004f8:	f012                	sd	tp,32(sp)
    802004fa:	f416                	sd	t0,40(sp)
    802004fc:	f81a                	sd	t1,48(sp)
    802004fe:	fc1e                	sd	t2,56(sp)
    80200500:	e0a2                	sd	s0,64(sp)
    80200502:	e4a6                	sd	s1,72(sp)
    80200504:	e8aa                	sd	a0,80(sp)
    80200506:	ecae                	sd	a1,88(sp)
    80200508:	f0b2                	sd	a2,96(sp)
    8020050a:	f4b6                	sd	a3,104(sp)
    8020050c:	f8ba                	sd	a4,112(sp)
    8020050e:	fcbe                	sd	a5,120(sp)
    80200510:	e142                	sd	a6,128(sp)
    80200512:	e546                	sd	a7,136(sp)
    80200514:	e94a                	sd	s2,144(sp)
    80200516:	ed4e                	sd	s3,152(sp)
    80200518:	f152                	sd	s4,160(sp)
    8020051a:	f556                	sd	s5,168(sp)
    8020051c:	f95a                	sd	s6,176(sp)
    8020051e:	fd5e                	sd	s7,184(sp)
    80200520:	e1e2                	sd	s8,192(sp)
    80200522:	e5e6                	sd	s9,200(sp)
    80200524:	e9ea                	sd	s10,208(sp)
    80200526:	edee                	sd	s11,216(sp)
    80200528:	f1f2                	sd	t3,224(sp)
    8020052a:	f5f6                	sd	t4,232(sp)
    8020052c:	f9fa                	sd	t5,240(sp)
    8020052e:	fdfe                	sd	t6,248(sp)
    80200530:	14001473          	csrrw	s0,sscratch,zero
    80200534:	100024f3          	csrr	s1,sstatus
    80200538:	14102973          	csrr	s2,sepc
    8020053c:	143029f3          	csrr	s3,stval
    80200540:	14202a73          	csrr	s4,scause
    80200544:	e822                	sd	s0,16(sp)
    80200546:	e226                	sd	s1,256(sp)
    80200548:	e64a                	sd	s2,264(sp)
    8020054a:	ea4e                	sd	s3,272(sp)
    8020054c:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020054e:	850a                	mv	a0,sp
    jal trap
    80200550:	f91ff0ef          	jal	ra,802004e0 <trap>

0000000080200554 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200554:	6492                	ld	s1,256(sp)
    80200556:	6932                	ld	s2,264(sp)
    80200558:	10049073          	csrw	sstatus,s1
    8020055c:	14191073          	csrw	sepc,s2
    80200560:	60a2                	ld	ra,8(sp)
    80200562:	61e2                	ld	gp,24(sp)
    80200564:	7202                	ld	tp,32(sp)
    80200566:	72a2                	ld	t0,40(sp)
    80200568:	7342                	ld	t1,48(sp)
    8020056a:	73e2                	ld	t2,56(sp)
    8020056c:	6406                	ld	s0,64(sp)
    8020056e:	64a6                	ld	s1,72(sp)
    80200570:	6546                	ld	a0,80(sp)
    80200572:	65e6                	ld	a1,88(sp)
    80200574:	7606                	ld	a2,96(sp)
    80200576:	76a6                	ld	a3,104(sp)
    80200578:	7746                	ld	a4,112(sp)
    8020057a:	77e6                	ld	a5,120(sp)
    8020057c:	680a                	ld	a6,128(sp)
    8020057e:	68aa                	ld	a7,136(sp)
    80200580:	694a                	ld	s2,144(sp)
    80200582:	69ea                	ld	s3,152(sp)
    80200584:	7a0a                	ld	s4,160(sp)
    80200586:	7aaa                	ld	s5,168(sp)
    80200588:	7b4a                	ld	s6,176(sp)
    8020058a:	7bea                	ld	s7,184(sp)
    8020058c:	6c0e                	ld	s8,192(sp)
    8020058e:	6cae                	ld	s9,200(sp)
    80200590:	6d4e                	ld	s10,208(sp)
    80200592:	6dee                	ld	s11,216(sp)
    80200594:	7e0e                	ld	t3,224(sp)
    80200596:	7eae                	ld	t4,232(sp)
    80200598:	7f4e                	ld	t5,240(sp)
    8020059a:	7fee                	ld	t6,248(sp)
    8020059c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020059e:	10200073          	sret

00000000802005a2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802005a2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802005a4:	e589                	bnez	a1,802005ae <strnlen+0xc>
    802005a6:	a811                	j	802005ba <strnlen+0x18>
        cnt ++;
    802005a8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802005aa:	00f58863          	beq	a1,a5,802005ba <strnlen+0x18>
    802005ae:	00f50733          	add	a4,a0,a5
    802005b2:	00074703          	lbu	a4,0(a4)
    802005b6:	fb6d                	bnez	a4,802005a8 <strnlen+0x6>
    802005b8:	85be                	mv	a1,a5
    }
    return cnt;
}
    802005ba:	852e                	mv	a0,a1
    802005bc:	8082                	ret

00000000802005be <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802005be:	ca01                	beqz	a2,802005ce <memset+0x10>
    802005c0:	962a                	add	a2,a2,a0
    char *p = s;
    802005c2:	87aa                	mv	a5,a0
        *p ++ = c;
    802005c4:	0785                	addi	a5,a5,1
    802005c6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802005ca:	fec79de3          	bne	a5,a2,802005c4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802005ce:	8082                	ret

00000000802005d0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005d4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005d6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005dc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005e0:	f022                	sd	s0,32(sp)
    802005e2:	ec26                	sd	s1,24(sp)
    802005e4:	e84a                	sd	s2,16(sp)
    802005e6:	f406                	sd	ra,40(sp)
    802005e8:	e44e                	sd	s3,8(sp)
    802005ea:	84aa                	mv	s1,a0
    802005ec:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005ee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005f2:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005f4:	03067e63          	bgeu	a2,a6,80200630 <printnum+0x60>
    802005f8:	89be                	mv	s3,a5
        while (-- width > 0)
    802005fa:	00805763          	blez	s0,80200608 <printnum+0x38>
    802005fe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200600:	85ca                	mv	a1,s2
    80200602:	854e                	mv	a0,s3
    80200604:	9482                	jalr	s1
        while (-- width > 0)
    80200606:	fc65                	bnez	s0,802005fe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200608:	1a02                	slli	s4,s4,0x20
    8020060a:	00001797          	auipc	a5,0x1
    8020060e:	a0678793          	addi	a5,a5,-1530 # 80201010 <etext+0x604>
    80200612:	020a5a13          	srli	s4,s4,0x20
    80200616:	9a3e                	add	s4,s4,a5
}
    80200618:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020061a:	000a4503          	lbu	a0,0(s4)
}
    8020061e:	70a2                	ld	ra,40(sp)
    80200620:	69a2                	ld	s3,8(sp)
    80200622:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200624:	85ca                	mv	a1,s2
    80200626:	87a6                	mv	a5,s1
}
    80200628:	6942                	ld	s2,16(sp)
    8020062a:	64e2                	ld	s1,24(sp)
    8020062c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020062e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200630:	03065633          	divu	a2,a2,a6
    80200634:	8722                	mv	a4,s0
    80200636:	f9bff0ef          	jal	ra,802005d0 <printnum>
    8020063a:	b7f9                	j	80200608 <printnum+0x38>

000000008020063c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020063c:	7119                	addi	sp,sp,-128
    8020063e:	f4a6                	sd	s1,104(sp)
    80200640:	f0ca                	sd	s2,96(sp)
    80200642:	ecce                	sd	s3,88(sp)
    80200644:	e8d2                	sd	s4,80(sp)
    80200646:	e4d6                	sd	s5,72(sp)
    80200648:	e0da                	sd	s6,64(sp)
    8020064a:	fc5e                	sd	s7,56(sp)
    8020064c:	f06a                	sd	s10,32(sp)
    8020064e:	fc86                	sd	ra,120(sp)
    80200650:	f8a2                	sd	s0,112(sp)
    80200652:	f862                	sd	s8,48(sp)
    80200654:	f466                	sd	s9,40(sp)
    80200656:	ec6e                	sd	s11,24(sp)
    80200658:	892a                	mv	s2,a0
    8020065a:	84ae                	mv	s1,a1
    8020065c:	8d32                	mv	s10,a2
    8020065e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200660:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200664:	5b7d                	li	s6,-1
    80200666:	00001a97          	auipc	s5,0x1
    8020066a:	9dea8a93          	addi	s5,s5,-1570 # 80201044 <etext+0x638>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020066e:	00001b97          	auipc	s7,0x1
    80200672:	bb2b8b93          	addi	s7,s7,-1102 # 80201220 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200676:	000d4503          	lbu	a0,0(s10)
    8020067a:	001d0413          	addi	s0,s10,1
    8020067e:	01350a63          	beq	a0,s3,80200692 <vprintfmt+0x56>
            if (ch == '\0') {
    80200682:	c121                	beqz	a0,802006c2 <vprintfmt+0x86>
            putch(ch, putdat);
    80200684:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200686:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200688:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020068a:	fff44503          	lbu	a0,-1(s0)
    8020068e:	ff351ae3          	bne	a0,s3,80200682 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200692:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200696:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020069a:	4c81                	li	s9,0
    8020069c:	4881                	li	a7,0
        width = precision = -1;
    8020069e:	5c7d                	li	s8,-1
    802006a0:	5dfd                	li	s11,-1
    802006a2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006a6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006a8:	fdd6059b          	addiw	a1,a2,-35
    802006ac:	0ff5f593          	zext.b	a1,a1
    802006b0:	00140d13          	addi	s10,s0,1
    802006b4:	04b56263          	bltu	a0,a1,802006f8 <vprintfmt+0xbc>
    802006b8:	058a                	slli	a1,a1,0x2
    802006ba:	95d6                	add	a1,a1,s5
    802006bc:	4194                	lw	a3,0(a1)
    802006be:	96d6                	add	a3,a3,s5
    802006c0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006c2:	70e6                	ld	ra,120(sp)
    802006c4:	7446                	ld	s0,112(sp)
    802006c6:	74a6                	ld	s1,104(sp)
    802006c8:	7906                	ld	s2,96(sp)
    802006ca:	69e6                	ld	s3,88(sp)
    802006cc:	6a46                	ld	s4,80(sp)
    802006ce:	6aa6                	ld	s5,72(sp)
    802006d0:	6b06                	ld	s6,64(sp)
    802006d2:	7be2                	ld	s7,56(sp)
    802006d4:	7c42                	ld	s8,48(sp)
    802006d6:	7ca2                	ld	s9,40(sp)
    802006d8:	7d02                	ld	s10,32(sp)
    802006da:	6de2                	ld	s11,24(sp)
    802006dc:	6109                	addi	sp,sp,128
    802006de:	8082                	ret
            padc = '0';
    802006e0:	87b2                	mv	a5,a2
            goto reswitch;
    802006e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006e6:	846a                	mv	s0,s10
    802006e8:	00140d13          	addi	s10,s0,1
    802006ec:	fdd6059b          	addiw	a1,a2,-35
    802006f0:	0ff5f593          	zext.b	a1,a1
    802006f4:	fcb572e3          	bgeu	a0,a1,802006b8 <vprintfmt+0x7c>
            putch('%', putdat);
    802006f8:	85a6                	mv	a1,s1
    802006fa:	02500513          	li	a0,37
    802006fe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200700:	fff44783          	lbu	a5,-1(s0)
    80200704:	8d22                	mv	s10,s0
    80200706:	f73788e3          	beq	a5,s3,80200676 <vprintfmt+0x3a>
    8020070a:	ffed4783          	lbu	a5,-2(s10)
    8020070e:	1d7d                	addi	s10,s10,-1
    80200710:	ff379de3          	bne	a5,s3,8020070a <vprintfmt+0xce>
    80200714:	b78d                	j	80200676 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200716:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    8020071a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020071e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200720:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200724:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200728:	02d86463          	bltu	a6,a3,80200750 <vprintfmt+0x114>
                ch = *fmt;
    8020072c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200730:	002c169b          	slliw	a3,s8,0x2
    80200734:	0186873b          	addw	a4,a3,s8
    80200738:	0017171b          	slliw	a4,a4,0x1
    8020073c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    8020073e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200742:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200744:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200748:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020074c:	fed870e3          	bgeu	a6,a3,8020072c <vprintfmt+0xf0>
            if (width < 0)
    80200750:	f40ddce3          	bgez	s11,802006a8 <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200754:	8de2                	mv	s11,s8
    80200756:	5c7d                	li	s8,-1
    80200758:	bf81                	j	802006a8 <vprintfmt+0x6c>
            if (width < 0)
    8020075a:	fffdc693          	not	a3,s11
    8020075e:	96fd                	srai	a3,a3,0x3f
    80200760:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200764:	00144603          	lbu	a2,1(s0)
    80200768:	2d81                	sext.w	s11,s11
    8020076a:	846a                	mv	s0,s10
            goto reswitch;
    8020076c:	bf35                	j	802006a8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    8020076e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200772:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200776:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200778:	846a                	mv	s0,s10
            goto process_precision;
    8020077a:	bfd9                	j	80200750 <vprintfmt+0x114>
    if (lflag >= 2) {
    8020077c:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020077e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200782:	01174463          	blt	a4,a7,8020078a <vprintfmt+0x14e>
    else if (lflag) {
    80200786:	1a088e63          	beqz	a7,80200942 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8020078a:	000a3603          	ld	a2,0(s4)
    8020078e:	46c1                	li	a3,16
    80200790:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200792:	2781                	sext.w	a5,a5
    80200794:	876e                	mv	a4,s11
    80200796:	85a6                	mv	a1,s1
    80200798:	854a                	mv	a0,s2
    8020079a:	e37ff0ef          	jal	ra,802005d0 <printnum>
            break;
    8020079e:	bde1                	j	80200676 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007a0:	000a2503          	lw	a0,0(s4)
    802007a4:	85a6                	mv	a1,s1
    802007a6:	0a21                	addi	s4,s4,8
    802007a8:	9902                	jalr	s2
            break;
    802007aa:	b5f1                	j	80200676 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007b2:	01174463          	blt	a4,a7,802007ba <vprintfmt+0x17e>
    else if (lflag) {
    802007b6:	18088163          	beqz	a7,80200938 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007ba:	000a3603          	ld	a2,0(s4)
    802007be:	46a9                	li	a3,10
    802007c0:	8a2e                	mv	s4,a1
    802007c2:	bfc1                	j	80200792 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007c8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007ca:	846a                	mv	s0,s10
            goto reswitch;
    802007cc:	bdf1                	j	802006a8 <vprintfmt+0x6c>
            putch(ch, putdat);
    802007ce:	85a6                	mv	a1,s1
    802007d0:	02500513          	li	a0,37
    802007d4:	9902                	jalr	s2
            break;
    802007d6:	b545                	j	80200676 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007d8:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007dc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007de:	846a                	mv	s0,s10
            goto reswitch;
    802007e0:	b5e1                	j	802006a8 <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007e8:	01174463          	blt	a4,a7,802007f0 <vprintfmt+0x1b4>
    else if (lflag) {
    802007ec:	14088163          	beqz	a7,8020092e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007f0:	000a3603          	ld	a2,0(s4)
    802007f4:	46a1                	li	a3,8
    802007f6:	8a2e                	mv	s4,a1
    802007f8:	bf69                	j	80200792 <vprintfmt+0x156>
            putch('0', putdat);
    802007fa:	03000513          	li	a0,48
    802007fe:	85a6                	mv	a1,s1
    80200800:	e03e                	sd	a5,0(sp)
    80200802:	9902                	jalr	s2
            putch('x', putdat);
    80200804:	85a6                	mv	a1,s1
    80200806:	07800513          	li	a0,120
    8020080a:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020080c:	0a21                	addi	s4,s4,8
            goto number;
    8020080e:	6782                	ld	a5,0(sp)
    80200810:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200812:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200816:	bfb5                	j	80200792 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200818:	000a3403          	ld	s0,0(s4)
    8020081c:	008a0713          	addi	a4,s4,8
    80200820:	e03a                	sd	a4,0(sp)
    80200822:	14040263          	beqz	s0,80200966 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200826:	0fb05763          	blez	s11,80200914 <vprintfmt+0x2d8>
    8020082a:	02d00693          	li	a3,45
    8020082e:	0cd79163          	bne	a5,a3,802008f0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200832:	00044783          	lbu	a5,0(s0)
    80200836:	0007851b          	sext.w	a0,a5
    8020083a:	cf85                	beqz	a5,80200872 <vprintfmt+0x236>
    8020083c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200840:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200844:	000c4563          	bltz	s8,8020084e <vprintfmt+0x212>
    80200848:	3c7d                	addiw	s8,s8,-1
    8020084a:	036c0263          	beq	s8,s6,8020086e <vprintfmt+0x232>
                    putch('?', putdat);
    8020084e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200850:	0e0c8e63          	beqz	s9,8020094c <vprintfmt+0x310>
    80200854:	3781                	addiw	a5,a5,-32
    80200856:	0ef47b63          	bgeu	s0,a5,8020094c <vprintfmt+0x310>
                    putch('?', putdat);
    8020085a:	03f00513          	li	a0,63
    8020085e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200860:	000a4783          	lbu	a5,0(s4)
    80200864:	3dfd                	addiw	s11,s11,-1
    80200866:	0a05                	addi	s4,s4,1
    80200868:	0007851b          	sext.w	a0,a5
    8020086c:	ffe1                	bnez	a5,80200844 <vprintfmt+0x208>
            for (; width > 0; width --) {
    8020086e:	01b05963          	blez	s11,80200880 <vprintfmt+0x244>
    80200872:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200874:	85a6                	mv	a1,s1
    80200876:	02000513          	li	a0,32
    8020087a:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020087c:	fe0d9be3          	bnez	s11,80200872 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200880:	6a02                	ld	s4,0(sp)
    80200882:	bbd5                	j	80200676 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200884:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200886:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    8020088a:	01174463          	blt	a4,a7,80200892 <vprintfmt+0x256>
    else if (lflag) {
    8020088e:	08088d63          	beqz	a7,80200928 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200892:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200896:	0a044d63          	bltz	s0,80200950 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020089a:	8622                	mv	a2,s0
    8020089c:	8a66                	mv	s4,s9
    8020089e:	46a9                	li	a3,10
    802008a0:	bdcd                	j	80200792 <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008a2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008a6:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008a8:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008aa:	41f7d69b          	sraiw	a3,a5,0x1f
    802008ae:	8fb5                	xor	a5,a5,a3
    802008b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008b4:	02d74163          	blt	a4,a3,802008d6 <vprintfmt+0x29a>
    802008b8:	00369793          	slli	a5,a3,0x3
    802008bc:	97de                	add	a5,a5,s7
    802008be:	639c                	ld	a5,0(a5)
    802008c0:	cb99                	beqz	a5,802008d6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008c2:	86be                	mv	a3,a5
    802008c4:	00000617          	auipc	a2,0x0
    802008c8:	77c60613          	addi	a2,a2,1916 # 80201040 <etext+0x634>
    802008cc:	85a6                	mv	a1,s1
    802008ce:	854a                	mv	a0,s2
    802008d0:	0ce000ef          	jal	ra,8020099e <printfmt>
    802008d4:	b34d                	j	80200676 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008d6:	00000617          	auipc	a2,0x0
    802008da:	75a60613          	addi	a2,a2,1882 # 80201030 <etext+0x624>
    802008de:	85a6                	mv	a1,s1
    802008e0:	854a                	mv	a0,s2
    802008e2:	0bc000ef          	jal	ra,8020099e <printfmt>
    802008e6:	bb41                	j	80200676 <vprintfmt+0x3a>
                p = "(null)";
    802008e8:	00000417          	auipc	s0,0x0
    802008ec:	74040413          	addi	s0,s0,1856 # 80201028 <etext+0x61c>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f0:	85e2                	mv	a1,s8
    802008f2:	8522                	mv	a0,s0
    802008f4:	e43e                	sd	a5,8(sp)
    802008f6:	cadff0ef          	jal	ra,802005a2 <strnlen>
    802008fa:	40ad8dbb          	subw	s11,s11,a0
    802008fe:	01b05b63          	blez	s11,80200914 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    80200902:	67a2                	ld	a5,8(sp)
    80200904:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200908:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020090a:	85a6                	mv	a1,s1
    8020090c:	8552                	mv	a0,s4
    8020090e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200910:	fe0d9ce3          	bnez	s11,80200908 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200914:	00044783          	lbu	a5,0(s0)
    80200918:	00140a13          	addi	s4,s0,1
    8020091c:	0007851b          	sext.w	a0,a5
    80200920:	d3a5                	beqz	a5,80200880 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    80200922:	05e00413          	li	s0,94
    80200926:	bf39                	j	80200844 <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200928:	000a2403          	lw	s0,0(s4)
    8020092c:	b7ad                	j	80200896 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    8020092e:	000a6603          	lwu	a2,0(s4)
    80200932:	46a1                	li	a3,8
    80200934:	8a2e                	mv	s4,a1
    80200936:	bdb1                	j	80200792 <vprintfmt+0x156>
    80200938:	000a6603          	lwu	a2,0(s4)
    8020093c:	46a9                	li	a3,10
    8020093e:	8a2e                	mv	s4,a1
    80200940:	bd89                	j	80200792 <vprintfmt+0x156>
    80200942:	000a6603          	lwu	a2,0(s4)
    80200946:	46c1                	li	a3,16
    80200948:	8a2e                	mv	s4,a1
    8020094a:	b5a1                	j	80200792 <vprintfmt+0x156>
                    putch(ch, putdat);
    8020094c:	9902                	jalr	s2
    8020094e:	bf09                	j	80200860 <vprintfmt+0x224>
                putch('-', putdat);
    80200950:	85a6                	mv	a1,s1
    80200952:	02d00513          	li	a0,45
    80200956:	e03e                	sd	a5,0(sp)
    80200958:	9902                	jalr	s2
                num = -(long long)num;
    8020095a:	6782                	ld	a5,0(sp)
    8020095c:	8a66                	mv	s4,s9
    8020095e:	40800633          	neg	a2,s0
    80200962:	46a9                	li	a3,10
    80200964:	b53d                	j	80200792 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200966:	03b05163          	blez	s11,80200988 <vprintfmt+0x34c>
    8020096a:	02d00693          	li	a3,45
    8020096e:	f6d79de3          	bne	a5,a3,802008e8 <vprintfmt+0x2ac>
                p = "(null)";
    80200972:	00000417          	auipc	s0,0x0
    80200976:	6b640413          	addi	s0,s0,1718 # 80201028 <etext+0x61c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020097a:	02800793          	li	a5,40
    8020097e:	02800513          	li	a0,40
    80200982:	00140a13          	addi	s4,s0,1
    80200986:	bd6d                	j	80200840 <vprintfmt+0x204>
    80200988:	00000a17          	auipc	s4,0x0
    8020098c:	6a1a0a13          	addi	s4,s4,1697 # 80201029 <etext+0x61d>
    80200990:	02800513          	li	a0,40
    80200994:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200998:	05e00413          	li	s0,94
    8020099c:	b565                	j	80200844 <vprintfmt+0x208>

000000008020099e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020099e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009a0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a8:	ec06                	sd	ra,24(sp)
    802009aa:	f83a                	sd	a4,48(sp)
    802009ac:	fc3e                	sd	a5,56(sp)
    802009ae:	e0c2                	sd	a6,64(sp)
    802009b0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009b2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009b4:	c89ff0ef          	jal	ra,8020063c <vprintfmt>
}
    802009b8:	60e2                	ld	ra,24(sp)
    802009ba:	6161                	addi	sp,sp,80
    802009bc:	8082                	ret

00000000802009be <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009be:	4781                	li	a5,0
    802009c0:	00003717          	auipc	a4,0x3
    802009c4:	64073703          	ld	a4,1600(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009c8:	88ba                	mv	a7,a4
    802009ca:	852a                	mv	a0,a0
    802009cc:	85be                	mv	a1,a5
    802009ce:	863e                	mv	a2,a5
    802009d0:	00000073          	ecall
    802009d4:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009d6:	8082                	ret

00000000802009d8 <sbi_set_timer>:
    __asm__ volatile (
    802009d8:	4781                	li	a5,0
    802009da:	00003717          	auipc	a4,0x3
    802009de:	64e73703          	ld	a4,1614(a4) # 80204028 <SBI_SET_TIMER>
    802009e2:	88ba                	mv	a7,a4
    802009e4:	852a                	mv	a0,a0
    802009e6:	85be                	mv	a1,a5
    802009e8:	863e                	mv	a2,a5
    802009ea:	00000073          	ecall
    802009ee:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009f0:	8082                	ret

00000000802009f2 <sbi_shutdown>:
    __asm__ volatile (
    802009f2:	4781                	li	a5,0
    802009f4:	00003717          	auipc	a4,0x3
    802009f8:	61473703          	ld	a4,1556(a4) # 80204008 <SBI_SHUTDOWN>
    802009fc:	88ba                	mv	a7,a4
    802009fe:	853e                	mv	a0,a5
    80200a00:	85be                	mv	a1,a5
    80200a02:	863e                	mv	a2,a5
    80200a04:	00000073          	ecall
    80200a08:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a0a:	8082                	ret

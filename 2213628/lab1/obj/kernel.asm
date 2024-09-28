
bin/kernel：     文件格式 elf64-littleriscv


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
    80200016:	01e60613          	addi	a2,a2,30 # 80204030 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	187000ef          	jal	ra,802009a8 <memset>

    cons_init();  // init the console
    80200026:	148000ef          	jal	ra,8020016e <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	99658593          	addi	a1,a1,-1642 # 802009c0 <etext+0x6>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9ae50513          	addi	a0,a0,-1618 # 802009e0 <etext+0x26>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	ra,8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13c000ef          	jal	ra,8020017e <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e6000ef          	jal	ra,8020012c <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12e000ef          	jal	ra,80200178 <intr_enable>
    
    while (1)
        ;
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
    80200058:	118000ef          	jal	ra,80200170 <cons_putc>
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
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <ticks>
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	51c000ef          	jal	ra,802005ae <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	94850513          	addi	a0,a0,-1720 # 802009e8 <etext+0x2e>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	95250513          	addi	a0,a0,-1710 # 80200a08 <etext+0x4e>
    802000be:	fadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	8f858593          	addi	a1,a1,-1800 # 802009ba <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	95e50513          	addi	a0,a0,-1698 # 80200a28 <etext+0x6e>
    802000d2:	f99ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <edata>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	96a50513          	addi	a0,a0,-1686 # 80200a48 <etext+0x8e>
    802000e6:	f85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f4658593          	addi	a1,a1,-186 # 80204030 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	97650513          	addi	a0,a0,-1674 # 80200a68 <etext+0xae>
    802000fa:	f71ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004597          	auipc	a1,0x4
    80200102:	33158593          	addi	a1,a1,817 # 8020442f <end+0x3ff>
    80200106:	00000797          	auipc	a5,0x0
    8020010a:	f0478793          	addi	a5,a5,-252 # 8020000a <kern_init>
    8020010e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200112:	43f7d593          	srai	a1,a5,0x3f
}
    80200116:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200118:	3ff5f593          	andi	a1,a1,1023
    8020011c:	95be                	add	a1,a1,a5
    8020011e:	85a9                	srai	a1,a1,0xa
    80200120:	00001517          	auipc	a0,0x1
    80200124:	96850513          	addi	a0,a0,-1688 # 80200a88 <etext+0xce>
}
    80200128:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012a:	b781                	j	8020006a <cprintf>

000000008020012c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012c:	1141                	addi	sp,sp,-16
    8020012e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200130:	02000793          	li	a5,32
    80200134:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200138:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013c:	67e1                	lui	a5,0x18
    8020013e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200142:	953e                	add	a0,a0,a5
    80200144:	007000ef          	jal	ra,8020094a <sbi_set_timer>
}
    80200148:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014a:	00004797          	auipc	a5,0x4
    8020014e:	ec07bf23          	sd	zero,-290(a5) # 80204028 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200152:	00001517          	auipc	a0,0x1
    80200156:	96650513          	addi	a0,a0,-1690 # 80200ab8 <etext+0xfe>
}
    8020015a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015c:	b739                	j	8020006a <cprintf>

000000008020015e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200162:	67e1                	lui	a5,0x18
    80200164:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200168:	953e                	add	a0,a0,a5
    8020016a:	7e00006f          	j	8020094a <sbi_set_timer>

000000008020016e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016e:	8082                	ret

0000000080200170 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200170:	0ff57513          	andi	a0,a0,255
    80200174:	7ba0006f          	j	8020092e <sbi_console_putchar>

0000000080200178 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200178:	100167f3          	csrrsi	a5,sstatus,2
    8020017c:	8082                	ret

000000008020017e <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200182:	00000797          	auipc	a5,0x0
    80200186:	30a78793          	addi	a5,a5,778 # 8020048c <__alltraps>
    8020018a:	10579073          	csrw	stvec,a5
}
    8020018e:	8082                	ret

0000000080200190 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200190:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200192:	1141                	addi	sp,sp,-16
    80200194:	e022                	sd	s0,0(sp)
    80200196:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	00001517          	auipc	a0,0x1
    8020019c:	a2050513          	addi	a0,a0,-1504 # 80200bb8 <etext+0x1fe>
void print_regs(struct pushregs *gpr) {
    802001a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	ec9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a6:	640c                	ld	a1,8(s0)
    802001a8:	00001517          	auipc	a0,0x1
    802001ac:	a2850513          	addi	a0,a0,-1496 # 80200bd0 <etext+0x216>
    802001b0:	ebbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b4:	680c                	ld	a1,16(s0)
    802001b6:	00001517          	auipc	a0,0x1
    802001ba:	a3250513          	addi	a0,a0,-1486 # 80200be8 <etext+0x22e>
    802001be:	eadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c2:	6c0c                	ld	a1,24(s0)
    802001c4:	00001517          	auipc	a0,0x1
    802001c8:	a3c50513          	addi	a0,a0,-1476 # 80200c00 <etext+0x246>
    802001cc:	e9fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d0:	700c                	ld	a1,32(s0)
    802001d2:	00001517          	auipc	a0,0x1
    802001d6:	a4650513          	addi	a0,a0,-1466 # 80200c18 <etext+0x25e>
    802001da:	e91ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001de:	740c                	ld	a1,40(s0)
    802001e0:	00001517          	auipc	a0,0x1
    802001e4:	a5050513          	addi	a0,a0,-1456 # 80200c30 <etext+0x276>
    802001e8:	e83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ec:	780c                	ld	a1,48(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	a5a50513          	addi	a0,a0,-1446 # 80200c48 <etext+0x28e>
    802001f6:	e75ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fa:	7c0c                	ld	a1,56(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	a6450513          	addi	a0,a0,-1436 # 80200c60 <etext+0x2a6>
    80200204:	e67ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200208:	602c                	ld	a1,64(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	a6e50513          	addi	a0,a0,-1426 # 80200c78 <etext+0x2be>
    80200212:	e59ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200216:	642c                	ld	a1,72(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	a7850513          	addi	a0,a0,-1416 # 80200c90 <etext+0x2d6>
    80200220:	e4bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200224:	682c                	ld	a1,80(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	a8250513          	addi	a0,a0,-1406 # 80200ca8 <etext+0x2ee>
    8020022e:	e3dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200232:	6c2c                	ld	a1,88(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	a8c50513          	addi	a0,a0,-1396 # 80200cc0 <etext+0x306>
    8020023c:	e2fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200240:	702c                	ld	a1,96(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	a9650513          	addi	a0,a0,-1386 # 80200cd8 <etext+0x31e>
    8020024a:	e21ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024e:	742c                	ld	a1,104(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	aa050513          	addi	a0,a0,-1376 # 80200cf0 <etext+0x336>
    80200258:	e13ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025c:	782c                	ld	a1,112(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	aaa50513          	addi	a0,a0,-1366 # 80200d08 <etext+0x34e>
    80200266:	e05ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026a:	7c2c                	ld	a1,120(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	ab450513          	addi	a0,a0,-1356 # 80200d20 <etext+0x366>
    80200274:	df7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200278:	604c                	ld	a1,128(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	abe50513          	addi	a0,a0,-1346 # 80200d38 <etext+0x37e>
    80200282:	de9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200286:	644c                	ld	a1,136(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	ac850513          	addi	a0,a0,-1336 # 80200d50 <etext+0x396>
    80200290:	ddbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200294:	684c                	ld	a1,144(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	ad250513          	addi	a0,a0,-1326 # 80200d68 <etext+0x3ae>
    8020029e:	dcdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a2:	6c4c                	ld	a1,152(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	adc50513          	addi	a0,a0,-1316 # 80200d80 <etext+0x3c6>
    802002ac:	dbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b0:	704c                	ld	a1,160(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	ae650513          	addi	a0,a0,-1306 # 80200d98 <etext+0x3de>
    802002ba:	db1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002be:	744c                	ld	a1,168(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	af050513          	addi	a0,a0,-1296 # 80200db0 <etext+0x3f6>
    802002c8:	da3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002cc:	784c                	ld	a1,176(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	afa50513          	addi	a0,a0,-1286 # 80200dc8 <etext+0x40e>
    802002d6:	d95ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002da:	7c4c                	ld	a1,184(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	b0450513          	addi	a0,a0,-1276 # 80200de0 <etext+0x426>
    802002e4:	d87ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e8:	606c                	ld	a1,192(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	b0e50513          	addi	a0,a0,-1266 # 80200df8 <etext+0x43e>
    802002f2:	d79ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f6:	646c                	ld	a1,200(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	b1850513          	addi	a0,a0,-1256 # 80200e10 <etext+0x456>
    80200300:	d6bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200304:	686c                	ld	a1,208(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	b2250513          	addi	a0,a0,-1246 # 80200e28 <etext+0x46e>
    8020030e:	d5dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200312:	6c6c                	ld	a1,216(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	b2c50513          	addi	a0,a0,-1236 # 80200e40 <etext+0x486>
    8020031c:	d4fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200320:	706c                	ld	a1,224(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	b3650513          	addi	a0,a0,-1226 # 80200e58 <etext+0x49e>
    8020032a:	d41ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032e:	746c                	ld	a1,232(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	b4050513          	addi	a0,a0,-1216 # 80200e70 <etext+0x4b6>
    80200338:	d33ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033c:	786c                	ld	a1,240(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	b4a50513          	addi	a0,a0,-1206 # 80200e88 <etext+0x4ce>
    80200346:	d25ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034a:	7c6c                	ld	a1,248(s0)
}
    8020034c:	6402                	ld	s0,0(sp)
    8020034e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	00001517          	auipc	a0,0x1
    80200354:	b5050513          	addi	a0,a0,-1200 # 80200ea0 <etext+0x4e6>
}
    80200358:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	bb01                	j	8020006a <cprintf>

000000008020035c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035c:	1141                	addi	sp,sp,-16
    8020035e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200360:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200362:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200364:	00001517          	auipc	a0,0x1
    80200368:	b5450513          	addi	a0,a0,-1196 # 80200eb8 <etext+0x4fe>
void print_trapframe(struct trapframe *tf) {
    8020036c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	cfdff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200372:	8522                	mv	a0,s0
    80200374:	e1dff0ef          	jal	ra,80200190 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200378:	10043583          	ld	a1,256(s0)
    8020037c:	00001517          	auipc	a0,0x1
    80200380:	b5450513          	addi	a0,a0,-1196 # 80200ed0 <etext+0x516>
    80200384:	ce7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200388:	10843583          	ld	a1,264(s0)
    8020038c:	00001517          	auipc	a0,0x1
    80200390:	b5c50513          	addi	a0,a0,-1188 # 80200ee8 <etext+0x52e>
    80200394:	cd7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200398:	11043583          	ld	a1,272(s0)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	b6450513          	addi	a0,a0,-1180 # 80200f00 <etext+0x546>
    802003a4:	cc7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	11843583          	ld	a1,280(s0)
}
    802003ac:	6402                	ld	s0,0(sp)
    802003ae:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	00001517          	auipc	a0,0x1
    802003b4:	b6850513          	addi	a0,a0,-1176 # 80200f18 <etext+0x55e>
}
    802003b8:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	b945                	j	8020006a <cprintf>

00000000802003bc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003bc:	11853783          	ld	a5,280(a0)
    switch (cause) {
    802003c0:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c2:	0786                	slli	a5,a5,0x1
    802003c4:	8385                	srli	a5,a5,0x1
    switch (cause) {
    802003c6:	08f76463          	bltu	a4,a5,8020044e <interrupt_handler+0x92>
    802003ca:	00000717          	auipc	a4,0x0
    802003ce:	70a70713          	addi	a4,a4,1802 # 80200ad4 <etext+0x11a>
    802003d2:	078a                	slli	a5,a5,0x2
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	439c                	lw	a5,0(a5)
    802003d8:	97ba                	add	a5,a5,a4
    802003da:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003dc:	00000517          	auipc	a0,0x0
    802003e0:	78c50513          	addi	a0,a0,1932 # 80200b68 <etext+0x1ae>
    802003e4:	b159                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e6:	00000517          	auipc	a0,0x0
    802003ea:	76250513          	addi	a0,a0,1890 # 80200b48 <etext+0x18e>
    802003ee:	b9b5                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	71850513          	addi	a0,a0,1816 # 80200b08 <etext+0x14e>
    802003f8:	b98d                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fa:	00000517          	auipc	a0,0x0
    802003fe:	72e50513          	addi	a0,a0,1838 # 80200b28 <etext+0x16e>
    80200402:	b1a5                	j	8020006a <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200404:	00000517          	auipc	a0,0x0
    80200408:	79450513          	addi	a0,a0,1940 # 80200b98 <etext+0x1de>
    8020040c:	b9b9                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040e:	1141                	addi	sp,sp,-16
    80200410:	e022                	sd	s0,0(sp)
    80200412:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    80200414:	d4bff0ef          	jal	ra,8020015e <clock_set_next_event>
            ticks++;
    80200418:	00004797          	auipc	a5,0x4
    8020041c:	c0078793          	addi	a5,a5,-1024 # 80204018 <ticks.1201>
    80200420:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
    80200422:	06400713          	li	a4,100
    80200426:	00004417          	auipc	s0,0x4
    8020042a:	bea40413          	addi	s0,s0,-1046 # 80204010 <edata>
            ticks++;
    8020042e:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
    80200430:	02e7e73b          	remw	a4,a5,a4
            ticks++;
    80200434:	00004697          	auipc	a3,0x4
    80200438:	bef6a223          	sw	a5,-1052(a3) # 80204018 <ticks.1201>
            if (ticks % TICK_NUM == 0){
    8020043c:	cb11                	beqz	a4,80200450 <interrupt_handler+0x94>
            if (num == 10){
    8020043e:	6018                	ld	a4,0(s0)
    80200440:	47a9                	li	a5,10
    80200442:	02f70663          	beq	a4,a5,8020046e <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200446:	60a2                	ld	ra,8(sp)
    80200448:	6402                	ld	s0,0(sp)
    8020044a:	0141                	addi	sp,sp,16
    8020044c:	8082                	ret
            print_trapframe(tf);
    8020044e:	b739                	j	8020035c <print_trapframe>
            num++;
    80200450:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200452:	06400593          	li	a1,100
    80200456:	00000517          	auipc	a0,0x0
    8020045a:	73250513          	addi	a0,a0,1842 # 80200b88 <etext+0x1ce>
            num++;
    8020045e:	0785                	addi	a5,a5,1
    80200460:	00004717          	auipc	a4,0x4
    80200464:	baf73823          	sd	a5,-1104(a4) # 80204010 <edata>
    cprintf("%d ticks\n", TICK_NUM);
    80200468:	c03ff0ef          	jal	ra,8020006a <cprintf>
    8020046c:	bfc9                	j	8020043e <interrupt_handler+0x82>
}
    8020046e:	6402                	ld	s0,0(sp)
    80200470:	60a2                	ld	ra,8(sp)
    80200472:	0141                	addi	sp,sp,16
            sbi_shutdown();
    80200474:	a9cd                	j	80200966 <sbi_shutdown>

0000000080200476 <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200476:	11853783          	ld	a5,280(a0)
    8020047a:	0007c763          	bltz	a5,80200488 <trap+0x12>
    switch (tf->cause) {
    8020047e:	472d                	li	a4,11
    80200480:	00f76363          	bltu	a4,a5,80200486 <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200484:	8082                	ret
            print_trapframe(tf);
    80200486:	bdd9                	j	8020035c <print_trapframe>
        interrupt_handler(tf);
    80200488:	bf15                	j	802003bc <interrupt_handler>
	...

000000008020048c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020048c:	14011073          	csrw	sscratch,sp
    80200490:	712d                	addi	sp,sp,-288
    80200492:	e002                	sd	zero,0(sp)
    80200494:	e406                	sd	ra,8(sp)
    80200496:	ec0e                	sd	gp,24(sp)
    80200498:	f012                	sd	tp,32(sp)
    8020049a:	f416                	sd	t0,40(sp)
    8020049c:	f81a                	sd	t1,48(sp)
    8020049e:	fc1e                	sd	t2,56(sp)
    802004a0:	e0a2                	sd	s0,64(sp)
    802004a2:	e4a6                	sd	s1,72(sp)
    802004a4:	e8aa                	sd	a0,80(sp)
    802004a6:	ecae                	sd	a1,88(sp)
    802004a8:	f0b2                	sd	a2,96(sp)
    802004aa:	f4b6                	sd	a3,104(sp)
    802004ac:	f8ba                	sd	a4,112(sp)
    802004ae:	fcbe                	sd	a5,120(sp)
    802004b0:	e142                	sd	a6,128(sp)
    802004b2:	e546                	sd	a7,136(sp)
    802004b4:	e94a                	sd	s2,144(sp)
    802004b6:	ed4e                	sd	s3,152(sp)
    802004b8:	f152                	sd	s4,160(sp)
    802004ba:	f556                	sd	s5,168(sp)
    802004bc:	f95a                	sd	s6,176(sp)
    802004be:	fd5e                	sd	s7,184(sp)
    802004c0:	e1e2                	sd	s8,192(sp)
    802004c2:	e5e6                	sd	s9,200(sp)
    802004c4:	e9ea                	sd	s10,208(sp)
    802004c6:	edee                	sd	s11,216(sp)
    802004c8:	f1f2                	sd	t3,224(sp)
    802004ca:	f5f6                	sd	t4,232(sp)
    802004cc:	f9fa                	sd	t5,240(sp)
    802004ce:	fdfe                	sd	t6,248(sp)
    802004d0:	14001473          	csrrw	s0,sscratch,zero
    802004d4:	100024f3          	csrr	s1,sstatus
    802004d8:	14102973          	csrr	s2,sepc
    802004dc:	143029f3          	csrr	s3,stval
    802004e0:	14202a73          	csrr	s4,scause
    802004e4:	e822                	sd	s0,16(sp)
    802004e6:	e226                	sd	s1,256(sp)
    802004e8:	e64a                	sd	s2,264(sp)
    802004ea:	ea4e                	sd	s3,272(sp)
    802004ec:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004ee:	850a                	mv	a0,sp
    jal trap
    802004f0:	f87ff0ef          	jal	ra,80200476 <trap>

00000000802004f4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004f4:	6492                	ld	s1,256(sp)
    802004f6:	6932                	ld	s2,264(sp)
    802004f8:	10049073          	csrw	sstatus,s1
    802004fc:	14191073          	csrw	sepc,s2
    80200500:	60a2                	ld	ra,8(sp)
    80200502:	61e2                	ld	gp,24(sp)
    80200504:	7202                	ld	tp,32(sp)
    80200506:	72a2                	ld	t0,40(sp)
    80200508:	7342                	ld	t1,48(sp)
    8020050a:	73e2                	ld	t2,56(sp)
    8020050c:	6406                	ld	s0,64(sp)
    8020050e:	64a6                	ld	s1,72(sp)
    80200510:	6546                	ld	a0,80(sp)
    80200512:	65e6                	ld	a1,88(sp)
    80200514:	7606                	ld	a2,96(sp)
    80200516:	76a6                	ld	a3,104(sp)
    80200518:	7746                	ld	a4,112(sp)
    8020051a:	77e6                	ld	a5,120(sp)
    8020051c:	680a                	ld	a6,128(sp)
    8020051e:	68aa                	ld	a7,136(sp)
    80200520:	694a                	ld	s2,144(sp)
    80200522:	69ea                	ld	s3,152(sp)
    80200524:	7a0a                	ld	s4,160(sp)
    80200526:	7aaa                	ld	s5,168(sp)
    80200528:	7b4a                	ld	s6,176(sp)
    8020052a:	7bea                	ld	s7,184(sp)
    8020052c:	6c0e                	ld	s8,192(sp)
    8020052e:	6cae                	ld	s9,200(sp)
    80200530:	6d4e                	ld	s10,208(sp)
    80200532:	6dee                	ld	s11,216(sp)
    80200534:	7e0e                	ld	t3,224(sp)
    80200536:	7eae                	ld	t4,232(sp)
    80200538:	7f4e                	ld	t5,240(sp)
    8020053a:	7fee                	ld	t6,248(sp)
    8020053c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020053e:	10200073          	sret

0000000080200542 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200542:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200546:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200548:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020054c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020054e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200552:	f022                	sd	s0,32(sp)
    80200554:	ec26                	sd	s1,24(sp)
    80200556:	e84a                	sd	s2,16(sp)
    80200558:	f406                	sd	ra,40(sp)
    8020055a:	e44e                	sd	s3,8(sp)
    8020055c:	84aa                	mv	s1,a0
    8020055e:	892e                	mv	s2,a1
    80200560:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200564:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200566:	03067e63          	bgeu	a2,a6,802005a2 <printnum+0x60>
    8020056a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    8020056c:	00805763          	blez	s0,8020057a <printnum+0x38>
    80200570:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200572:	85ca                	mv	a1,s2
    80200574:	854e                	mv	a0,s3
    80200576:	9482                	jalr	s1
        while (-- width > 0)
    80200578:	fc65                	bnez	s0,80200570 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020057a:	1a02                	slli	s4,s4,0x20
    8020057c:	020a5a13          	srli	s4,s4,0x20
    80200580:	00001797          	auipc	a5,0x1
    80200584:	b4078793          	addi	a5,a5,-1216 # 802010c0 <error_string+0x38>
    80200588:	9a3e                	add	s4,s4,a5
}
    8020058a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020058c:	000a4503          	lbu	a0,0(s4)
}
    80200590:	70a2                	ld	ra,40(sp)
    80200592:	69a2                	ld	s3,8(sp)
    80200594:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200596:	85ca                	mv	a1,s2
    80200598:	8326                	mv	t1,s1
}
    8020059a:	6942                	ld	s2,16(sp)
    8020059c:	64e2                	ld	s1,24(sp)
    8020059e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005a0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005a2:	03065633          	divu	a2,a2,a6
    802005a6:	8722                	mv	a4,s0
    802005a8:	f9bff0ef          	jal	ra,80200542 <printnum>
    802005ac:	b7f9                	j	8020057a <printnum+0x38>

00000000802005ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005ae:	7119                	addi	sp,sp,-128
    802005b0:	f4a6                	sd	s1,104(sp)
    802005b2:	f0ca                	sd	s2,96(sp)
    802005b4:	e8d2                	sd	s4,80(sp)
    802005b6:	e4d6                	sd	s5,72(sp)
    802005b8:	e0da                	sd	s6,64(sp)
    802005ba:	fc5e                	sd	s7,56(sp)
    802005bc:	f862                	sd	s8,48(sp)
    802005be:	f06a                	sd	s10,32(sp)
    802005c0:	fc86                	sd	ra,120(sp)
    802005c2:	f8a2                	sd	s0,112(sp)
    802005c4:	ecce                	sd	s3,88(sp)
    802005c6:	f466                	sd	s9,40(sp)
    802005c8:	ec6e                	sd	s11,24(sp)
    802005ca:	892a                	mv	s2,a0
    802005cc:	84ae                	mv	s1,a1
    802005ce:	8d32                	mv	s10,a2
    802005d0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005d2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802005d4:	00001a17          	auipc	s4,0x1
    802005d8:	958a0a13          	addi	s4,s4,-1704 # 80200f2c <etext+0x572>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802005dc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005e0:	00001c17          	auipc	s8,0x1
    802005e4:	aa8c0c13          	addi	s8,s8,-1368 # 80201088 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005e8:	000d4503          	lbu	a0,0(s10)
    802005ec:	02500793          	li	a5,37
    802005f0:	001d0413          	addi	s0,s10,1
    802005f4:	00f50e63          	beq	a0,a5,80200610 <vprintfmt+0x62>
            if (ch == '\0') {
    802005f8:	c521                	beqz	a0,80200640 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005fa:	02500993          	li	s3,37
    802005fe:	a011                	j	80200602 <vprintfmt+0x54>
            if (ch == '\0') {
    80200600:	c121                	beqz	a0,80200640 <vprintfmt+0x92>
            putch(ch, putdat);
    80200602:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200604:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200606:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200608:	fff44503          	lbu	a0,-1(s0)
    8020060c:	ff351ae3          	bne	a0,s3,80200600 <vprintfmt+0x52>
    80200610:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200614:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200618:	4981                	li	s3,0
    8020061a:	4801                	li	a6,0
        width = precision = -1;
    8020061c:	5cfd                	li	s9,-1
    8020061e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200620:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200624:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200626:	fdd6069b          	addiw	a3,a2,-35
    8020062a:	0ff6f693          	andi	a3,a3,255
    8020062e:	00140d13          	addi	s10,s0,1
    80200632:	1ed5ef63          	bltu	a1,a3,80200830 <vprintfmt+0x282>
    80200636:	068a                	slli	a3,a3,0x2
    80200638:	96d2                	add	a3,a3,s4
    8020063a:	4294                	lw	a3,0(a3)
    8020063c:	96d2                	add	a3,a3,s4
    8020063e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200640:	70e6                	ld	ra,120(sp)
    80200642:	7446                	ld	s0,112(sp)
    80200644:	74a6                	ld	s1,104(sp)
    80200646:	7906                	ld	s2,96(sp)
    80200648:	69e6                	ld	s3,88(sp)
    8020064a:	6a46                	ld	s4,80(sp)
    8020064c:	6aa6                	ld	s5,72(sp)
    8020064e:	6b06                	ld	s6,64(sp)
    80200650:	7be2                	ld	s7,56(sp)
    80200652:	7c42                	ld	s8,48(sp)
    80200654:	7ca2                	ld	s9,40(sp)
    80200656:	7d02                	ld	s10,32(sp)
    80200658:	6de2                	ld	s11,24(sp)
    8020065a:	6109                	addi	sp,sp,128
    8020065c:	8082                	ret
            padc = '-';
    8020065e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
    80200660:	00144603          	lbu	a2,1(s0)
    80200664:	846a                	mv	s0,s10
    80200666:	b7c1                	j	80200626 <vprintfmt+0x78>
            precision = va_arg(ap, int);
    80200668:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    8020066c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200670:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200672:	846a                	mv	s0,s10
            if (width < 0)
    80200674:	fa0dd9e3          	bgez	s11,80200626 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200678:	8de6                	mv	s11,s9
    8020067a:	5cfd                	li	s9,-1
    8020067c:	b76d                	j	80200626 <vprintfmt+0x78>
            if (width < 0)
    8020067e:	fffdc693          	not	a3,s11
    80200682:	96fd                	srai	a3,a3,0x3f
    80200684:	00ddfdb3          	and	s11,s11,a3
    80200688:	00144603          	lbu	a2,1(s0)
    8020068c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020068e:	846a                	mv	s0,s10
    80200690:	bf59                	j	80200626 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200692:	4705                	li	a4,1
    80200694:	008a8593          	addi	a1,s5,8
    80200698:	01074463          	blt	a4,a6,802006a0 <vprintfmt+0xf2>
    else if (lflag) {
    8020069c:	22080863          	beqz	a6,802008cc <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
    802006a0:	000ab603          	ld	a2,0(s5)
    802006a4:	46c1                	li	a3,16
    802006a6:	8aae                	mv	s5,a1
    802006a8:	a291                	j	802007ec <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
    802006aa:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802006ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006b2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006b4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006b8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802006bc:	fad56ce3          	bltu	a0,a3,80200674 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
    802006c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802006c2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802006c6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802006ca:	0196873b          	addw	a4,a3,s9
    802006ce:	0017171b          	slliw	a4,a4,0x1
    802006d2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802006d6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802006da:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802006de:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802006e2:	fcd57fe3          	bgeu	a0,a3,802006c0 <vprintfmt+0x112>
    802006e6:	b779                	j	80200674 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
    802006e8:	000aa503          	lw	a0,0(s5)
    802006ec:	85a6                	mv	a1,s1
    802006ee:	0aa1                	addi	s5,s5,8
    802006f0:	9902                	jalr	s2
            break;
    802006f2:	bddd                	j	802005e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006f4:	4705                	li	a4,1
    802006f6:	008a8993          	addi	s3,s5,8
    802006fa:	01074463          	blt	a4,a6,80200702 <vprintfmt+0x154>
    else if (lflag) {
    802006fe:	1c080463          	beqz	a6,802008c6 <vprintfmt+0x318>
        return va_arg(*ap, long);
    80200702:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200706:	1c044a63          	bltz	s0,802008da <vprintfmt+0x32c>
            num = getint(&ap, lflag);
    8020070a:	8622                	mv	a2,s0
    8020070c:	8ace                	mv	s5,s3
    8020070e:	46a9                	li	a3,10
    80200710:	a8f1                	j	802007ec <vprintfmt+0x23e>
            err = va_arg(ap, int);
    80200712:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200716:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200718:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020071a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020071e:	8fb5                	xor	a5,a5,a3
    80200720:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200724:	12d74963          	blt	a4,a3,80200856 <vprintfmt+0x2a8>
    80200728:	00369793          	slli	a5,a3,0x3
    8020072c:	97e2                	add	a5,a5,s8
    8020072e:	639c                	ld	a5,0(a5)
    80200730:	12078363          	beqz	a5,80200856 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
    80200734:	86be                	mv	a3,a5
    80200736:	00001617          	auipc	a2,0x1
    8020073a:	a3a60613          	addi	a2,a2,-1478 # 80201170 <error_string+0xe8>
    8020073e:	85a6                	mv	a1,s1
    80200740:	854a                	mv	a0,s2
    80200742:	1cc000ef          	jal	ra,8020090e <printfmt>
    80200746:	b54d                	j	802005e8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200748:	000ab603          	ld	a2,0(s5)
    8020074c:	0aa1                	addi	s5,s5,8
    8020074e:	1a060163          	beqz	a2,802008f0 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
    80200752:	00160413          	addi	s0,a2,1
    80200756:	15b05763          	blez	s11,802008a4 <vprintfmt+0x2f6>
    8020075a:	02d00593          	li	a1,45
    8020075e:	10b79d63          	bne	a5,a1,80200878 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200762:	00064783          	lbu	a5,0(a2)
    80200766:	0007851b          	sext.w	a0,a5
    8020076a:	c905                	beqz	a0,8020079a <vprintfmt+0x1ec>
    8020076c:	000cc563          	bltz	s9,80200776 <vprintfmt+0x1c8>
    80200770:	3cfd                	addiw	s9,s9,-1
    80200772:	036c8263          	beq	s9,s6,80200796 <vprintfmt+0x1e8>
                    putch('?', putdat);
    80200776:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200778:	14098f63          	beqz	s3,802008d6 <vprintfmt+0x328>
    8020077c:	3781                	addiw	a5,a5,-32
    8020077e:	14fbfc63          	bgeu	s7,a5,802008d6 <vprintfmt+0x328>
                    putch('?', putdat);
    80200782:	03f00513          	li	a0,63
    80200786:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200788:	0405                	addi	s0,s0,1
    8020078a:	fff44783          	lbu	a5,-1(s0)
    8020078e:	3dfd                	addiw	s11,s11,-1
    80200790:	0007851b          	sext.w	a0,a5
    80200794:	fd61                	bnez	a0,8020076c <vprintfmt+0x1be>
            for (; width > 0; width --) {
    80200796:	e5b059e3          	blez	s11,802005e8 <vprintfmt+0x3a>
    8020079a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020079c:	85a6                	mv	a1,s1
    8020079e:	02000513          	li	a0,32
    802007a2:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007a4:	e40d82e3          	beqz	s11,802005e8 <vprintfmt+0x3a>
    802007a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007aa:	85a6                	mv	a1,s1
    802007ac:	02000513          	li	a0,32
    802007b0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007b2:	fe0d94e3          	bnez	s11,8020079a <vprintfmt+0x1ec>
    802007b6:	bd0d                	j	802005e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007b8:	4705                	li	a4,1
    802007ba:	008a8593          	addi	a1,s5,8
    802007be:	01074463          	blt	a4,a6,802007c6 <vprintfmt+0x218>
    else if (lflag) {
    802007c2:	0e080863          	beqz	a6,802008b2 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
    802007c6:	000ab603          	ld	a2,0(s5)
    802007ca:	46a1                	li	a3,8
    802007cc:	8aae                	mv	s5,a1
    802007ce:	a839                	j	802007ec <vprintfmt+0x23e>
            putch('0', putdat);
    802007d0:	03000513          	li	a0,48
    802007d4:	85a6                	mv	a1,s1
    802007d6:	e03e                	sd	a5,0(sp)
    802007d8:	9902                	jalr	s2
            putch('x', putdat);
    802007da:	85a6                	mv	a1,s1
    802007dc:	07800513          	li	a0,120
    802007e0:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007e2:	0aa1                	addi	s5,s5,8
    802007e4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007e8:	6782                	ld	a5,0(sp)
    802007ea:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007ec:	2781                	sext.w	a5,a5
    802007ee:	876e                	mv	a4,s11
    802007f0:	85a6                	mv	a1,s1
    802007f2:	854a                	mv	a0,s2
    802007f4:	d4fff0ef          	jal	ra,80200542 <printnum>
            break;
    802007f8:	bbc5                	j	802005e8 <vprintfmt+0x3a>
            lflag ++;
    802007fa:	00144603          	lbu	a2,1(s0)
    802007fe:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200800:	846a                	mv	s0,s10
            goto reswitch;
    80200802:	b515                	j	80200626 <vprintfmt+0x78>
            goto reswitch;
    80200804:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200808:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020080a:	846a                	mv	s0,s10
            goto reswitch;
    8020080c:	bd29                	j	80200626 <vprintfmt+0x78>
            putch(ch, putdat);
    8020080e:	85a6                	mv	a1,s1
    80200810:	02500513          	li	a0,37
    80200814:	9902                	jalr	s2
            break;
    80200816:	bbc9                	j	802005e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200818:	4705                	li	a4,1
    8020081a:	008a8593          	addi	a1,s5,8
    8020081e:	01074463          	blt	a4,a6,80200826 <vprintfmt+0x278>
    else if (lflag) {
    80200822:	08080d63          	beqz	a6,802008bc <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
    80200826:	000ab603          	ld	a2,0(s5)
    8020082a:	46a9                	li	a3,10
    8020082c:	8aae                	mv	s5,a1
    8020082e:	bf7d                	j	802007ec <vprintfmt+0x23e>
            putch('%', putdat);
    80200830:	85a6                	mv	a1,s1
    80200832:	02500513          	li	a0,37
    80200836:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200838:	fff44703          	lbu	a4,-1(s0)
    8020083c:	02500793          	li	a5,37
    80200840:	8d22                	mv	s10,s0
    80200842:	daf703e3          	beq	a4,a5,802005e8 <vprintfmt+0x3a>
    80200846:	02500713          	li	a4,37
    8020084a:	1d7d                	addi	s10,s10,-1
    8020084c:	fffd4783          	lbu	a5,-1(s10)
    80200850:	fee79de3          	bne	a5,a4,8020084a <vprintfmt+0x29c>
    80200854:	bb51                	j	802005e8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200856:	00001617          	auipc	a2,0x1
    8020085a:	90a60613          	addi	a2,a2,-1782 # 80201160 <error_string+0xd8>
    8020085e:	85a6                	mv	a1,s1
    80200860:	854a                	mv	a0,s2
    80200862:	0ac000ef          	jal	ra,8020090e <printfmt>
    80200866:	b349                	j	802005e8 <vprintfmt+0x3a>
                p = "(null)";
    80200868:	00001617          	auipc	a2,0x1
    8020086c:	8f060613          	addi	a2,a2,-1808 # 80201158 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200870:	00001417          	auipc	s0,0x1
    80200874:	8e940413          	addi	s0,s0,-1815 # 80201159 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200878:	8532                	mv	a0,a2
    8020087a:	85e6                	mv	a1,s9
    8020087c:	e032                	sd	a2,0(sp)
    8020087e:	e43e                	sd	a5,8(sp)
    80200880:	102000ef          	jal	ra,80200982 <strnlen>
    80200884:	40ad8dbb          	subw	s11,s11,a0
    80200888:	6602                	ld	a2,0(sp)
    8020088a:	01b05d63          	blez	s11,802008a4 <vprintfmt+0x2f6>
    8020088e:	67a2                	ld	a5,8(sp)
    80200890:	2781                	sext.w	a5,a5
    80200892:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200894:	6522                	ld	a0,8(sp)
    80200896:	85a6                	mv	a1,s1
    80200898:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020089a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020089c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020089e:	6602                	ld	a2,0(sp)
    802008a0:	fe0d9ae3          	bnez	s11,80200894 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008a4:	00064783          	lbu	a5,0(a2)
    802008a8:	0007851b          	sext.w	a0,a5
    802008ac:	ec0510e3          	bnez	a0,8020076c <vprintfmt+0x1be>
    802008b0:	bb25                	j	802005e8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
    802008b2:	000ae603          	lwu	a2,0(s5)
    802008b6:	46a1                	li	a3,8
    802008b8:	8aae                	mv	s5,a1
    802008ba:	bf0d                	j	802007ec <vprintfmt+0x23e>
    802008bc:	000ae603          	lwu	a2,0(s5)
    802008c0:	46a9                	li	a3,10
    802008c2:	8aae                	mv	s5,a1
    802008c4:	b725                	j	802007ec <vprintfmt+0x23e>
        return va_arg(*ap, int);
    802008c6:	000aa403          	lw	s0,0(s5)
    802008ca:	bd35                	j	80200706 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
    802008cc:	000ae603          	lwu	a2,0(s5)
    802008d0:	46c1                	li	a3,16
    802008d2:	8aae                	mv	s5,a1
    802008d4:	bf21                	j	802007ec <vprintfmt+0x23e>
                    putch(ch, putdat);
    802008d6:	9902                	jalr	s2
    802008d8:	bd45                	j	80200788 <vprintfmt+0x1da>
                putch('-', putdat);
    802008da:	85a6                	mv	a1,s1
    802008dc:	02d00513          	li	a0,45
    802008e0:	e03e                	sd	a5,0(sp)
    802008e2:	9902                	jalr	s2
                num = -(long long)num;
    802008e4:	8ace                	mv	s5,s3
    802008e6:	40800633          	neg	a2,s0
    802008ea:	46a9                	li	a3,10
    802008ec:	6782                	ld	a5,0(sp)
    802008ee:	bdfd                	j	802007ec <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
    802008f0:	01b05663          	blez	s11,802008fc <vprintfmt+0x34e>
    802008f4:	02d00693          	li	a3,45
    802008f8:	f6d798e3          	bne	a5,a3,80200868 <vprintfmt+0x2ba>
    802008fc:	00001417          	auipc	s0,0x1
    80200900:	85d40413          	addi	s0,s0,-1955 # 80201159 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200904:	02800513          	li	a0,40
    80200908:	02800793          	li	a5,40
    8020090c:	b585                	j	8020076c <vprintfmt+0x1be>

000000008020090e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020090e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200910:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200914:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200916:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200918:	ec06                	sd	ra,24(sp)
    8020091a:	f83a                	sd	a4,48(sp)
    8020091c:	fc3e                	sd	a5,56(sp)
    8020091e:	e0c2                	sd	a6,64(sp)
    80200920:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200922:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200924:	c8bff0ef          	jal	ra,802005ae <vprintfmt>
}
    80200928:	60e2                	ld	ra,24(sp)
    8020092a:	6161                	addi	sp,sp,80
    8020092c:	8082                	ret

000000008020092e <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    8020092e:	00003797          	auipc	a5,0x3
    80200932:	6d278793          	addi	a5,a5,1746 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200936:	6398                	ld	a4,0(a5)
    80200938:	4781                	li	a5,0
    8020093a:	88ba                	mv	a7,a4
    8020093c:	852a                	mv	a0,a0
    8020093e:	85be                	mv	a1,a5
    80200940:	863e                	mv	a2,a5
    80200942:	00000073          	ecall
    80200946:	87aa                	mv	a5,a0
}
    80200948:	8082                	ret

000000008020094a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    8020094a:	00003797          	auipc	a5,0x3
    8020094e:	6d678793          	addi	a5,a5,1750 # 80204020 <SBI_SET_TIMER>
    __asm__ volatile (
    80200952:	6398                	ld	a4,0(a5)
    80200954:	4781                	li	a5,0
    80200956:	88ba                	mv	a7,a4
    80200958:	852a                	mv	a0,a0
    8020095a:	85be                	mv	a1,a5
    8020095c:	863e                	mv	a2,a5
    8020095e:	00000073          	ecall
    80200962:	87aa                	mv	a5,a0
}
    80200964:	8082                	ret

0000000080200966 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200966:	00003797          	auipc	a5,0x3
    8020096a:	6a278793          	addi	a5,a5,1698 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    8020096e:	6398                	ld	a4,0(a5)
    80200970:	4781                	li	a5,0
    80200972:	88ba                	mv	a7,a4
    80200974:	853e                	mv	a0,a5
    80200976:	85be                	mv	a1,a5
    80200978:	863e                	mv	a2,a5
    8020097a:	00000073          	ecall
    8020097e:	87aa                	mv	a5,a0
    80200980:	8082                	ret

0000000080200982 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200982:	c185                	beqz	a1,802009a2 <strnlen+0x20>
    80200984:	00054783          	lbu	a5,0(a0)
    80200988:	cf89                	beqz	a5,802009a2 <strnlen+0x20>
    size_t cnt = 0;
    8020098a:	4781                	li	a5,0
    8020098c:	a021                	j	80200994 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    8020098e:	00074703          	lbu	a4,0(a4)
    80200992:	c711                	beqz	a4,8020099e <strnlen+0x1c>
        cnt ++;
    80200994:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200996:	00f50733          	add	a4,a0,a5
    8020099a:	fef59ae3          	bne	a1,a5,8020098e <strnlen+0xc>
    }
    return cnt;
}
    8020099e:	853e                	mv	a0,a5
    802009a0:	8082                	ret
    size_t cnt = 0;
    802009a2:	4781                	li	a5,0
}
    802009a4:	853e                	mv	a0,a5
    802009a6:	8082                	ret

00000000802009a8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009a8:	ca01                	beqz	a2,802009b8 <memset+0x10>
    802009aa:	962a                	add	a2,a2,a0
    char *p = s;
    802009ac:	87aa                	mv	a5,a0
        *p ++ = c;
    802009ae:	0785                	addi	a5,a5,1
    802009b0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009b4:	fec79de3          	bne	a5,a2,802009ae <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009b8:	8082                	ret

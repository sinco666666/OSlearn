
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
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
    80200022:	217000ef          	jal	ra,80200a38 <memset>

    cons_init();  // init the console
    80200026:	14e000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a2658593          	addi	a1,a1,-1498 # 80200a50 <etext+0x6>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a3e50513          	addi	a0,a0,-1474 # 80200a70 <etext+0x26>
    8020003a:	036000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    8020003e:	066000ef          	jal	ra,802000a4 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	142000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0ec000ef          	jal	ra,80200132 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	134000ef          	jal	ra,8020017e <intr_enable>
    __asm__ __volatile__("mret");
    8020004e:	30200073          	mret
    __asm__ __volatile__("ebreak");
    80200052:	9002                	ebreak
    while (1)
        ;
    80200054:	a001                	j	80200054 <kern_init+0x4a>

0000000080200056 <cputch>:
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    8020005e:	118000ef          	jal	ra,80200176 <cons_putc>
    80200062:	401c                	lw	a5,0(s0)
    80200064:	60a2                	ld	ra,8(sp)
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
    80200070:	711d                	addi	sp,sp,-96
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <ticks>
    80200076:	f42e                	sd	a1,40(sp)
    80200078:	f832                	sd	a2,48(sp)
    8020007a:	fc36                	sd	a3,56(sp)
    8020007c:	862a                	mv	a2,a0
    8020007e:	004c                	addi	a1,sp,4
    80200080:	00000517          	auipc	a0,0x0
    80200084:	fd650513          	addi	a0,a0,-42 # 80200056 <cputch>
    80200088:	869a                	mv	a3,t1
    8020008a:	ec06                	sd	ra,24(sp)
    8020008c:	e0ba                	sd	a4,64(sp)
    8020008e:	e4be                	sd	a5,72(sp)
    80200090:	e8c2                	sd	a6,80(sp)
    80200092:	ecc6                	sd	a7,88(sp)
    80200094:	e41a                	sd	t1,8(sp)
    80200096:	c202                	sw	zero,4(sp)
    80200098:	5a6000ef          	jal	ra,8020063e <vprintfmt>
    8020009c:	60e2                	ld	ra,24(sp)
    8020009e:	4512                	lw	a0,4(sp)
    802000a0:	6125                	addi	sp,sp,96
    802000a2:	8082                	ret

00000000802000a4 <print_kerninfo>:
    802000a4:	1141                	addi	sp,sp,-16
    802000a6:	00001517          	auipc	a0,0x1
    802000aa:	9d250513          	addi	a0,a0,-1582 # 80200a78 <etext+0x2e>
    802000ae:	e406                	sd	ra,8(sp)
    802000b0:	fc1ff0ef          	jal	ra,80200070 <cprintf>
    802000b4:	00000597          	auipc	a1,0x0
    802000b8:	f5658593          	addi	a1,a1,-170 # 8020000a <kern_init>
    802000bc:	00001517          	auipc	a0,0x1
    802000c0:	9dc50513          	addi	a0,a0,-1572 # 80200a98 <etext+0x4e>
    802000c4:	fadff0ef          	jal	ra,80200070 <cprintf>
    802000c8:	00001597          	auipc	a1,0x1
    802000cc:	98258593          	addi	a1,a1,-1662 # 80200a4a <etext>
    802000d0:	00001517          	auipc	a0,0x1
    802000d4:	9e850513          	addi	a0,a0,-1560 # 80200ab8 <etext+0x6e>
    802000d8:	f99ff0ef          	jal	ra,80200070 <cprintf>
    802000dc:	00004597          	auipc	a1,0x4
    802000e0:	f3458593          	addi	a1,a1,-204 # 80204010 <edata>
    802000e4:	00001517          	auipc	a0,0x1
    802000e8:	9f450513          	addi	a0,a0,-1548 # 80200ad8 <etext+0x8e>
    802000ec:	f85ff0ef          	jal	ra,80200070 <cprintf>
    802000f0:	00004597          	auipc	a1,0x4
    802000f4:	f4058593          	addi	a1,a1,-192 # 80204030 <end>
    802000f8:	00001517          	auipc	a0,0x1
    802000fc:	a0050513          	addi	a0,a0,-1536 # 80200af8 <etext+0xae>
    80200100:	f71ff0ef          	jal	ra,80200070 <cprintf>
    80200104:	00004597          	auipc	a1,0x4
    80200108:	32b58593          	addi	a1,a1,811 # 8020442f <end+0x3ff>
    8020010c:	00000797          	auipc	a5,0x0
    80200110:	efe78793          	addi	a5,a5,-258 # 8020000a <kern_init>
    80200114:	40f587b3          	sub	a5,a1,a5
    80200118:	43f7d593          	srai	a1,a5,0x3f
    8020011c:	60a2                	ld	ra,8(sp)
    8020011e:	3ff5f593          	andi	a1,a1,1023
    80200122:	95be                	add	a1,a1,a5
    80200124:	85a9                	srai	a1,a1,0xa
    80200126:	00001517          	auipc	a0,0x1
    8020012a:	9f250513          	addi	a0,a0,-1550 # 80200b18 <etext+0xce>
    8020012e:	0141                	addi	sp,sp,16
    80200130:	b781                	j	80200070 <cprintf>

0000000080200132 <clock_init>:
    80200132:	1141                	addi	sp,sp,-16
    80200134:	e406                	sd	ra,8(sp)
    80200136:	02000793          	li	a5,32
    8020013a:	1047a7f3          	csrrs	a5,sie,a5
    8020013e:	c0102573          	rdtime	a0
    80200142:	67e1                	lui	a5,0x18
    80200144:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200148:	953e                	add	a0,a0,a5
    8020014a:	091000ef          	jal	ra,802009da <sbi_set_timer>
    8020014e:	60a2                	ld	ra,8(sp)
    80200150:	00004797          	auipc	a5,0x4
    80200154:	ec07bc23          	sd	zero,-296(a5) # 80204028 <ticks>
    80200158:	00001517          	auipc	a0,0x1
    8020015c:	9f050513          	addi	a0,a0,-1552 # 80200b48 <etext+0xfe>
    80200160:	0141                	addi	sp,sp,16
    80200162:	b739                	j	80200070 <cprintf>

0000000080200164 <clock_set_next_event>:
    80200164:	c0102573          	rdtime	a0
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	06b0006f          	j	802009da <sbi_set_timer>

0000000080200174 <cons_init>:
    80200174:	8082                	ret

0000000080200176 <cons_putc>:
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	0450006f          	j	802009be <sbi_console_putchar>

000000008020017e <intr_enable>:
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	39478793          	addi	a5,a5,916 # 8020051c <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	b3250513          	addi	a0,a0,-1230 # 80200cd0 <etext+0x286>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	b3a50513          	addi	a0,a0,-1222 # 80200ce8 <etext+0x29e>
    802001b6:	ebbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	b4450513          	addi	a0,a0,-1212 # 80200d00 <etext+0x2b6>
    802001c4:	eadff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	b4e50513          	addi	a0,a0,-1202 # 80200d18 <etext+0x2ce>
    802001d2:	e9fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	b5850513          	addi	a0,a0,-1192 # 80200d30 <etext+0x2e6>
    802001e0:	e91ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	b6250513          	addi	a0,a0,-1182 # 80200d48 <etext+0x2fe>
    802001ee:	e83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	b6c50513          	addi	a0,a0,-1172 # 80200d60 <etext+0x316>
    802001fc:	e75ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	b7650513          	addi	a0,a0,-1162 # 80200d78 <etext+0x32e>
    8020020a:	e67ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	b8050513          	addi	a0,a0,-1152 # 80200d90 <etext+0x346>
    80200218:	e59ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	b8a50513          	addi	a0,a0,-1142 # 80200da8 <etext+0x35e>
    80200226:	e4bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	b9450513          	addi	a0,a0,-1132 # 80200dc0 <etext+0x376>
    80200234:	e3dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	b9e50513          	addi	a0,a0,-1122 # 80200dd8 <etext+0x38e>
    80200242:	e2fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	ba850513          	addi	a0,a0,-1112 # 80200df0 <etext+0x3a6>
    80200250:	e21ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	bb250513          	addi	a0,a0,-1102 # 80200e08 <etext+0x3be>
    8020025e:	e13ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	bbc50513          	addi	a0,a0,-1092 # 80200e20 <etext+0x3d6>
    8020026c:	e05ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	bc650513          	addi	a0,a0,-1082 # 80200e38 <etext+0x3ee>
    8020027a:	df7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	bd050513          	addi	a0,a0,-1072 # 80200e50 <etext+0x406>
    80200288:	de9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	bda50513          	addi	a0,a0,-1062 # 80200e68 <etext+0x41e>
    80200296:	ddbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	be450513          	addi	a0,a0,-1052 # 80200e80 <etext+0x436>
    802002a4:	dcdff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	bee50513          	addi	a0,a0,-1042 # 80200e98 <etext+0x44e>
    802002b2:	dbfff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	bf850513          	addi	a0,a0,-1032 # 80200eb0 <etext+0x466>
    802002c0:	db1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	c0250513          	addi	a0,a0,-1022 # 80200ec8 <etext+0x47e>
    802002ce:	da3ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	c0c50513          	addi	a0,a0,-1012 # 80200ee0 <etext+0x496>
    802002dc:	d95ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	c1650513          	addi	a0,a0,-1002 # 80200ef8 <etext+0x4ae>
    802002ea:	d87ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	c2050513          	addi	a0,a0,-992 # 80200f10 <etext+0x4c6>
    802002f8:	d79ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	c2a50513          	addi	a0,a0,-982 # 80200f28 <etext+0x4de>
    80200306:	d6bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	c3450513          	addi	a0,a0,-972 # 80200f40 <etext+0x4f6>
    80200314:	d5dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	c3e50513          	addi	a0,a0,-962 # 80200f58 <etext+0x50e>
    80200322:	d4fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	c4850513          	addi	a0,a0,-952 # 80200f70 <etext+0x526>
    80200330:	d41ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	c5250513          	addi	a0,a0,-942 # 80200f88 <etext+0x53e>
    8020033e:	d33ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	c5c50513          	addi	a0,a0,-932 # 80200fa0 <etext+0x556>
    8020034c:	d25ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c6250513          	addi	a0,a0,-926 # 80200fb8 <etext+0x56e>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	bb01                	j	80200070 <cprintf>

0000000080200362 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200362:	1141                	addi	sp,sp,-16
    80200364:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200366:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200368:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036a:	00001517          	auipc	a0,0x1
    8020036e:	c6650513          	addi	a0,a0,-922 # 80200fd0 <etext+0x586>
void print_trapframe(struct trapframe *tf) {
    80200372:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200374:	cfdff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    80200378:	8522                	mv	a0,s0
    8020037a:	e1dff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037e:	10043583          	ld	a1,256(s0)
    80200382:	00001517          	auipc	a0,0x1
    80200386:	c6650513          	addi	a0,a0,-922 # 80200fe8 <etext+0x59e>
    8020038a:	ce7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038e:	10843583          	ld	a1,264(s0)
    80200392:	00001517          	auipc	a0,0x1
    80200396:	c6e50513          	addi	a0,a0,-914 # 80201000 <etext+0x5b6>
    8020039a:	cd7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039e:	11043583          	ld	a1,272(s0)
    802003a2:	00001517          	auipc	a0,0x1
    802003a6:	c7650513          	addi	a0,a0,-906 # 80201018 <etext+0x5ce>
    802003aa:	cc7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ae:	11843583          	ld	a1,280(s0)
}
    802003b2:	6402                	ld	s0,0(sp)
    802003b4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	00001517          	auipc	a0,0x1
    802003ba:	c7a50513          	addi	a0,a0,-902 # 80201030 <etext+0x5e6>
}
    802003be:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c0:	b945                	j	80200070 <cprintf>

00000000802003c2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c2:	11853783          	ld	a5,280(a0)
    switch (cause) {
    802003c6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	0786                	slli	a5,a5,0x1
    802003ca:	8385                	srli	a5,a5,0x1
    switch (cause) {
    802003cc:	08f76463          	bltu	a4,a5,80200454 <interrupt_handler+0x92>
    802003d0:	00000717          	auipc	a4,0x0
    802003d4:	79470713          	addi	a4,a4,1940 # 80200b64 <etext+0x11a>
    802003d8:	078a                	slli	a5,a5,0x2
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	439c                	lw	a5,0(a5)
    802003de:	97ba                	add	a5,a5,a4
    802003e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e2:	00001517          	auipc	a0,0x1
    802003e6:	89e50513          	addi	a0,a0,-1890 # 80200c80 <etext+0x236>
    802003ea:	b159                	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	87450513          	addi	a0,a0,-1932 # 80200c60 <etext+0x216>
    802003f4:	b9b5                	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    802003f6:	00001517          	auipc	a0,0x1
    802003fa:	82a50513          	addi	a0,a0,-2006 # 80200c20 <etext+0x1d6>
    802003fe:	b98d                	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200400:	00001517          	auipc	a0,0x1
    80200404:	84050513          	addi	a0,a0,-1984 # 80200c40 <etext+0x1f6>
    80200408:	b1a5                	j	80200070 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020040a:	00001517          	auipc	a0,0x1
    8020040e:	8a650513          	addi	a0,a0,-1882 # 80200cb0 <etext+0x266>
    80200412:	b9b9                	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200414:	1141                	addi	sp,sp,-16
    80200416:	e022                	sd	s0,0(sp)
    80200418:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020041a:	d4bff0ef          	jal	ra,80200164 <clock_set_next_event>
            ticks++;
    8020041e:	00004797          	auipc	a5,0x4
    80200422:	bfa78793          	addi	a5,a5,-1030 # 80204018 <ticks.1201>
    80200426:	439c                	lw	a5,0(a5)
            if (ticks % TICK_NUM == 0){
    80200428:	06400713          	li	a4,100
    8020042c:	00004417          	auipc	s0,0x4
    80200430:	be440413          	addi	s0,s0,-1052 # 80204010 <edata>
            ticks++;
    80200434:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0){
    80200436:	02e7e73b          	remw	a4,a5,a4
            ticks++;
    8020043a:	00004697          	auipc	a3,0x4
    8020043e:	bcf6af23          	sw	a5,-1058(a3) # 80204018 <ticks.1201>
            if (ticks % TICK_NUM == 0){
    80200442:	cb11                	beqz	a4,80200456 <interrupt_handler+0x94>
            if (num == 10){
    80200444:	6018                	ld	a4,0(s0)
    80200446:	47a9                	li	a5,10
    80200448:	02f70663          	beq	a4,a5,80200474 <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020044c:	60a2                	ld	ra,8(sp)
    8020044e:	6402                	ld	s0,0(sp)
    80200450:	0141                	addi	sp,sp,16
    80200452:	8082                	ret
            print_trapframe(tf);
    80200454:	b739                	j	80200362 <print_trapframe>
            num++;
    80200456:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200458:	06400593          	li	a1,100
    8020045c:	00001517          	auipc	a0,0x1
    80200460:	84450513          	addi	a0,a0,-1980 # 80200ca0 <etext+0x256>
            num++;
    80200464:	0785                	addi	a5,a5,1
    80200466:	00004717          	auipc	a4,0x4
    8020046a:	baf73523          	sd	a5,-1110(a4) # 80204010 <edata>
    cprintf("%d ticks\n", TICK_NUM);
    8020046e:	c03ff0ef          	jal	ra,80200070 <cprintf>
    80200472:	bfc9                	j	80200444 <interrupt_handler+0x82>
}
    80200474:	6402                	ld	s0,0(sp)
    80200476:	60a2                	ld	ra,8(sp)
    80200478:	0141                	addi	sp,sp,16
            sbi_shutdown();
    8020047a:	abb5                	j	802009f6 <sbi_shutdown>

000000008020047c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020047c:	11853783          	ld	a5,280(a0)
    80200480:	472d                	li	a4,11
    80200482:	02f76863          	bltu	a4,a5,802004b2 <exception_handler+0x36>
    80200486:	4705                	li	a4,1
    80200488:	00f71733          	sll	a4,a4,a5
    8020048c:	6785                	lui	a5,0x1
    8020048e:	f5178793          	addi	a5,a5,-175 # f51 <BASE_ADDRESS-0x801ff0af>
    80200492:	8ff9                	and	a5,a5,a4
    80200494:	ef91                	bnez	a5,802004b0 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    80200496:	1141                	addi	sp,sp,-16
    80200498:	e022                	sd	s0,0(sp)
    8020049a:	e406                	sd	ra,8(sp)
    8020049c:	00877793          	andi	a5,a4,8
    802004a0:	842a                	mv	s0,a0
    802004a2:	e3a1                	bnez	a5,802004e2 <exception_handler+0x66>
    802004a4:	8b11                	andi	a4,a4,4
    802004a6:	e719                	bnez	a4,802004b4 <exception_handler+0x38>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a8:	6402                	ld	s0,0(sp)
    802004aa:	60a2                	ld	ra,8(sp)
    802004ac:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ae:	bd55                	j	80200362 <print_trapframe>
    802004b0:	8082                	ret
    802004b2:	bd45                	j	80200362 <print_trapframe>
           cprintf("Exception type:Illegal instruction\n");
    802004b4:	00000517          	auipc	a0,0x0
    802004b8:	6e450513          	addi	a0,a0,1764 # 80200b98 <etext+0x14e>
    802004bc:	bb5ff0ef          	jal	ra,80200070 <cprintf>
           cprintf("Illegal instruction caught at %p\n", tf->epc);
    802004c0:	10843583          	ld	a1,264(s0)
    802004c4:	00000517          	auipc	a0,0x0
    802004c8:	6fc50513          	addi	a0,a0,1788 # 80200bc0 <etext+0x176>
    802004cc:	ba5ff0ef          	jal	ra,80200070 <cprintf>
           tf->epc += 4;
    802004d0:	10843783          	ld	a5,264(s0)
}
    802004d4:	60a2                	ld	ra,8(sp)
           tf->epc += 4;
    802004d6:	0791                	addi	a5,a5,4
    802004d8:	10f43423          	sd	a5,264(s0)
}
    802004dc:	6402                	ld	s0,0(sp)
    802004de:	0141                	addi	sp,sp,16
    802004e0:	8082                	ret
           cprintf("Exception type: breakpoint\n");
    802004e2:	00000517          	auipc	a0,0x0
    802004e6:	70650513          	addi	a0,a0,1798 # 80200be8 <etext+0x19e>
    802004ea:	b87ff0ef          	jal	ra,80200070 <cprintf>
           cprintf("ebreak caught at %p\n", tf->epc);
    802004ee:	10843583          	ld	a1,264(s0)
    802004f2:	00000517          	auipc	a0,0x0
    802004f6:	71650513          	addi	a0,a0,1814 # 80200c08 <etext+0x1be>
    802004fa:	b77ff0ef          	jal	ra,80200070 <cprintf>
           tf->epc += 2;
    802004fe:	10843783          	ld	a5,264(s0)
}
    80200502:	60a2                	ld	ra,8(sp)
           tf->epc += 2;
    80200504:	0789                	addi	a5,a5,2
    80200506:	10f43423          	sd	a5,264(s0)
}
    8020050a:	6402                	ld	s0,0(sp)
    8020050c:	0141                	addi	sp,sp,16
    8020050e:	8082                	ret

0000000080200510 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200510:	11853783          	ld	a5,280(a0)
    80200514:	0007c363          	bltz	a5,8020051a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200518:	b795                	j	8020047c <exception_handler>
        interrupt_handler(tf);
    8020051a:	b565                	j	802003c2 <interrupt_handler>

000000008020051c <__alltraps>:
    8020051c:	14011073          	csrw	sscratch,sp
    80200520:	712d                	addi	sp,sp,-288
    80200522:	e002                	sd	zero,0(sp)
    80200524:	e406                	sd	ra,8(sp)
    80200526:	ec0e                	sd	gp,24(sp)
    80200528:	f012                	sd	tp,32(sp)
    8020052a:	f416                	sd	t0,40(sp)
    8020052c:	f81a                	sd	t1,48(sp)
    8020052e:	fc1e                	sd	t2,56(sp)
    80200530:	e0a2                	sd	s0,64(sp)
    80200532:	e4a6                	sd	s1,72(sp)
    80200534:	e8aa                	sd	a0,80(sp)
    80200536:	ecae                	sd	a1,88(sp)
    80200538:	f0b2                	sd	a2,96(sp)
    8020053a:	f4b6                	sd	a3,104(sp)
    8020053c:	f8ba                	sd	a4,112(sp)
    8020053e:	fcbe                	sd	a5,120(sp)
    80200540:	e142                	sd	a6,128(sp)
    80200542:	e546                	sd	a7,136(sp)
    80200544:	e94a                	sd	s2,144(sp)
    80200546:	ed4e                	sd	s3,152(sp)
    80200548:	f152                	sd	s4,160(sp)
    8020054a:	f556                	sd	s5,168(sp)
    8020054c:	f95a                	sd	s6,176(sp)
    8020054e:	fd5e                	sd	s7,184(sp)
    80200550:	e1e2                	sd	s8,192(sp)
    80200552:	e5e6                	sd	s9,200(sp)
    80200554:	e9ea                	sd	s10,208(sp)
    80200556:	edee                	sd	s11,216(sp)
    80200558:	f1f2                	sd	t3,224(sp)
    8020055a:	f5f6                	sd	t4,232(sp)
    8020055c:	f9fa                	sd	t5,240(sp)
    8020055e:	fdfe                	sd	t6,248(sp)
    80200560:	14001473          	csrrw	s0,sscratch,zero
    80200564:	100024f3          	csrr	s1,sstatus
    80200568:	14102973          	csrr	s2,sepc
    8020056c:	143029f3          	csrr	s3,stval
    80200570:	14202a73          	csrr	s4,scause
    80200574:	e822                	sd	s0,16(sp)
    80200576:	e226                	sd	s1,256(sp)
    80200578:	e64a                	sd	s2,264(sp)
    8020057a:	ea4e                	sd	s3,272(sp)
    8020057c:	ee52                	sd	s4,280(sp)
    8020057e:	850a                	mv	a0,sp
    80200580:	f91ff0ef          	jal	ra,80200510 <trap>

0000000080200584 <__trapret>:
    80200584:	6492                	ld	s1,256(sp)
    80200586:	6932                	ld	s2,264(sp)
    80200588:	10049073          	csrw	sstatus,s1
    8020058c:	14191073          	csrw	sepc,s2
    80200590:	60a2                	ld	ra,8(sp)
    80200592:	61e2                	ld	gp,24(sp)
    80200594:	7202                	ld	tp,32(sp)
    80200596:	72a2                	ld	t0,40(sp)
    80200598:	7342                	ld	t1,48(sp)
    8020059a:	73e2                	ld	t2,56(sp)
    8020059c:	6406                	ld	s0,64(sp)
    8020059e:	64a6                	ld	s1,72(sp)
    802005a0:	6546                	ld	a0,80(sp)
    802005a2:	65e6                	ld	a1,88(sp)
    802005a4:	7606                	ld	a2,96(sp)
    802005a6:	76a6                	ld	a3,104(sp)
    802005a8:	7746                	ld	a4,112(sp)
    802005aa:	77e6                	ld	a5,120(sp)
    802005ac:	680a                	ld	a6,128(sp)
    802005ae:	68aa                	ld	a7,136(sp)
    802005b0:	694a                	ld	s2,144(sp)
    802005b2:	69ea                	ld	s3,152(sp)
    802005b4:	7a0a                	ld	s4,160(sp)
    802005b6:	7aaa                	ld	s5,168(sp)
    802005b8:	7b4a                	ld	s6,176(sp)
    802005ba:	7bea                	ld	s7,184(sp)
    802005bc:	6c0e                	ld	s8,192(sp)
    802005be:	6cae                	ld	s9,200(sp)
    802005c0:	6d4e                	ld	s10,208(sp)
    802005c2:	6dee                	ld	s11,216(sp)
    802005c4:	7e0e                	ld	t3,224(sp)
    802005c6:	7eae                	ld	t4,232(sp)
    802005c8:	7f4e                	ld	t5,240(sp)
    802005ca:	7fee                	ld	t6,248(sp)
    802005cc:	6142                	ld	sp,16(sp)
    802005ce:	10200073          	sret

00000000802005d2 <printnum>:
    802005d2:	02069813          	slli	a6,a3,0x20
    802005d6:	7179                	addi	sp,sp,-48
    802005d8:	02085813          	srli	a6,a6,0x20
    802005dc:	e052                	sd	s4,0(sp)
    802005de:	03067a33          	remu	s4,a2,a6
    802005e2:	f022                	sd	s0,32(sp)
    802005e4:	ec26                	sd	s1,24(sp)
    802005e6:	e84a                	sd	s2,16(sp)
    802005e8:	f406                	sd	ra,40(sp)
    802005ea:	e44e                	sd	s3,8(sp)
    802005ec:	84aa                	mv	s1,a0
    802005ee:	892e                	mv	s2,a1
    802005f0:	fff7041b          	addiw	s0,a4,-1
    802005f4:	2a01                	sext.w	s4,s4
    802005f6:	03067e63          	bgeu	a2,a6,80200632 <printnum+0x60>
    802005fa:	89be                	mv	s3,a5
    802005fc:	00805763          	blez	s0,8020060a <printnum+0x38>
    80200600:	347d                	addiw	s0,s0,-1
    80200602:	85ca                	mv	a1,s2
    80200604:	854e                	mv	a0,s3
    80200606:	9482                	jalr	s1
    80200608:	fc65                	bnez	s0,80200600 <printnum+0x2e>
    8020060a:	1a02                	slli	s4,s4,0x20
    8020060c:	020a5a13          	srli	s4,s4,0x20
    80200610:	00001797          	auipc	a5,0x1
    80200614:	bc878793          	addi	a5,a5,-1080 # 802011d8 <error_string+0x38>
    80200618:	9a3e                	add	s4,s4,a5
    8020061a:	7402                	ld	s0,32(sp)
    8020061c:	000a4503          	lbu	a0,0(s4)
    80200620:	70a2                	ld	ra,40(sp)
    80200622:	69a2                	ld	s3,8(sp)
    80200624:	6a02                	ld	s4,0(sp)
    80200626:	85ca                	mv	a1,s2
    80200628:	8326                	mv	t1,s1
    8020062a:	6942                	ld	s2,16(sp)
    8020062c:	64e2                	ld	s1,24(sp)
    8020062e:	6145                	addi	sp,sp,48
    80200630:	8302                	jr	t1
    80200632:	03065633          	divu	a2,a2,a6
    80200636:	8722                	mv	a4,s0
    80200638:	f9bff0ef          	jal	ra,802005d2 <printnum>
    8020063c:	b7f9                	j	8020060a <printnum+0x38>

000000008020063e <vprintfmt>:
    8020063e:	7119                	addi	sp,sp,-128
    80200640:	f4a6                	sd	s1,104(sp)
    80200642:	f0ca                	sd	s2,96(sp)
    80200644:	e8d2                	sd	s4,80(sp)
    80200646:	e4d6                	sd	s5,72(sp)
    80200648:	e0da                	sd	s6,64(sp)
    8020064a:	fc5e                	sd	s7,56(sp)
    8020064c:	f862                	sd	s8,48(sp)
    8020064e:	f06a                	sd	s10,32(sp)
    80200650:	fc86                	sd	ra,120(sp)
    80200652:	f8a2                	sd	s0,112(sp)
    80200654:	ecce                	sd	s3,88(sp)
    80200656:	f466                	sd	s9,40(sp)
    80200658:	ec6e                	sd	s11,24(sp)
    8020065a:	892a                	mv	s2,a0
    8020065c:	84ae                	mv	s1,a1
    8020065e:	8d32                	mv	s10,a2
    80200660:	8ab6                	mv	s5,a3
    80200662:	5b7d                	li	s6,-1
    80200664:	00001a17          	auipc	s4,0x1
    80200668:	9e0a0a13          	addi	s4,s4,-1568 # 80201044 <etext+0x5fa>
    8020066c:	05e00b93          	li	s7,94
    80200670:	00001c17          	auipc	s8,0x1
    80200674:	b30c0c13          	addi	s8,s8,-1232 # 802011a0 <error_string>
    80200678:	000d4503          	lbu	a0,0(s10)
    8020067c:	02500793          	li	a5,37
    80200680:	001d0413          	addi	s0,s10,1
    80200684:	00f50e63          	beq	a0,a5,802006a0 <vprintfmt+0x62>
    80200688:	c521                	beqz	a0,802006d0 <vprintfmt+0x92>
    8020068a:	02500993          	li	s3,37
    8020068e:	a011                	j	80200692 <vprintfmt+0x54>
    80200690:	c121                	beqz	a0,802006d0 <vprintfmt+0x92>
    80200692:	85a6                	mv	a1,s1
    80200694:	0405                	addi	s0,s0,1
    80200696:	9902                	jalr	s2
    80200698:	fff44503          	lbu	a0,-1(s0)
    8020069c:	ff351ae3          	bne	a0,s3,80200690 <vprintfmt+0x52>
    802006a0:	00044603          	lbu	a2,0(s0)
    802006a4:	02000793          	li	a5,32
    802006a8:	4981                	li	s3,0
    802006aa:	4801                	li	a6,0
    802006ac:	5cfd                	li	s9,-1
    802006ae:	5dfd                	li	s11,-1
    802006b0:	05500593          	li	a1,85
    802006b4:	4525                	li	a0,9
    802006b6:	fdd6069b          	addiw	a3,a2,-35
    802006ba:	0ff6f693          	andi	a3,a3,255
    802006be:	00140d13          	addi	s10,s0,1
    802006c2:	1ed5ef63          	bltu	a1,a3,802008c0 <vprintfmt+0x282>
    802006c6:	068a                	slli	a3,a3,0x2
    802006c8:	96d2                	add	a3,a3,s4
    802006ca:	4294                	lw	a3,0(a3)
    802006cc:	96d2                	add	a3,a3,s4
    802006ce:	8682                	jr	a3
    802006d0:	70e6                	ld	ra,120(sp)
    802006d2:	7446                	ld	s0,112(sp)
    802006d4:	74a6                	ld	s1,104(sp)
    802006d6:	7906                	ld	s2,96(sp)
    802006d8:	69e6                	ld	s3,88(sp)
    802006da:	6a46                	ld	s4,80(sp)
    802006dc:	6aa6                	ld	s5,72(sp)
    802006de:	6b06                	ld	s6,64(sp)
    802006e0:	7be2                	ld	s7,56(sp)
    802006e2:	7c42                	ld	s8,48(sp)
    802006e4:	7ca2                	ld	s9,40(sp)
    802006e6:	7d02                	ld	s10,32(sp)
    802006e8:	6de2                	ld	s11,24(sp)
    802006ea:	6109                	addi	sp,sp,128
    802006ec:	8082                	ret
    802006ee:	87b2                	mv	a5,a2
    802006f0:	00144603          	lbu	a2,1(s0)
    802006f4:	846a                	mv	s0,s10
    802006f6:	b7c1                	j	802006b6 <vprintfmt+0x78>
    802006f8:	000aac83          	lw	s9,0(s5)
    802006fc:	00144603          	lbu	a2,1(s0)
    80200700:	0aa1                	addi	s5,s5,8
    80200702:	846a                	mv	s0,s10
    80200704:	fa0dd9e3          	bgez	s11,802006b6 <vprintfmt+0x78>
    80200708:	8de6                	mv	s11,s9
    8020070a:	5cfd                	li	s9,-1
    8020070c:	b76d                	j	802006b6 <vprintfmt+0x78>
    8020070e:	fffdc693          	not	a3,s11
    80200712:	96fd                	srai	a3,a3,0x3f
    80200714:	00ddfdb3          	and	s11,s11,a3
    80200718:	00144603          	lbu	a2,1(s0)
    8020071c:	2d81                	sext.w	s11,s11
    8020071e:	846a                	mv	s0,s10
    80200720:	bf59                	j	802006b6 <vprintfmt+0x78>
    80200722:	4705                	li	a4,1
    80200724:	008a8593          	addi	a1,s5,8
    80200728:	01074463          	blt	a4,a6,80200730 <vprintfmt+0xf2>
    8020072c:	22080863          	beqz	a6,8020095c <vprintfmt+0x31e>
    80200730:	000ab603          	ld	a2,0(s5)
    80200734:	46c1                	li	a3,16
    80200736:	8aae                	mv	s5,a1
    80200738:	a291                	j	8020087c <vprintfmt+0x23e>
    8020073a:	fd060c9b          	addiw	s9,a2,-48
    8020073e:	00144603          	lbu	a2,1(s0)
    80200742:	846a                	mv	s0,s10
    80200744:	fd06069b          	addiw	a3,a2,-48
    80200748:	0006089b          	sext.w	a7,a2
    8020074c:	fad56ce3          	bltu	a0,a3,80200704 <vprintfmt+0xc6>
    80200750:	0405                	addi	s0,s0,1
    80200752:	002c969b          	slliw	a3,s9,0x2
    80200756:	00044603          	lbu	a2,0(s0)
    8020075a:	0196873b          	addw	a4,a3,s9
    8020075e:	0017171b          	slliw	a4,a4,0x1
    80200762:	0117073b          	addw	a4,a4,a7
    80200766:	fd06069b          	addiw	a3,a2,-48
    8020076a:	fd070c9b          	addiw	s9,a4,-48
    8020076e:	0006089b          	sext.w	a7,a2
    80200772:	fcd57fe3          	bgeu	a0,a3,80200750 <vprintfmt+0x112>
    80200776:	b779                	j	80200704 <vprintfmt+0xc6>
    80200778:	000aa503          	lw	a0,0(s5)
    8020077c:	85a6                	mv	a1,s1
    8020077e:	0aa1                	addi	s5,s5,8
    80200780:	9902                	jalr	s2
    80200782:	bddd                	j	80200678 <vprintfmt+0x3a>
    80200784:	4705                	li	a4,1
    80200786:	008a8993          	addi	s3,s5,8
    8020078a:	01074463          	blt	a4,a6,80200792 <vprintfmt+0x154>
    8020078e:	1c080463          	beqz	a6,80200956 <vprintfmt+0x318>
    80200792:	000ab403          	ld	s0,0(s5)
    80200796:	1c044a63          	bltz	s0,8020096a <vprintfmt+0x32c>
    8020079a:	8622                	mv	a2,s0
    8020079c:	8ace                	mv	s5,s3
    8020079e:	46a9                	li	a3,10
    802007a0:	a8f1                	j	8020087c <vprintfmt+0x23e>
    802007a2:	000aa783          	lw	a5,0(s5)
    802007a6:	4719                	li	a4,6
    802007a8:	0aa1                	addi	s5,s5,8
    802007aa:	41f7d69b          	sraiw	a3,a5,0x1f
    802007ae:	8fb5                	xor	a5,a5,a3
    802007b0:	40d786bb          	subw	a3,a5,a3
    802007b4:	12d74963          	blt	a4,a3,802008e6 <vprintfmt+0x2a8>
    802007b8:	00369793          	slli	a5,a3,0x3
    802007bc:	97e2                	add	a5,a5,s8
    802007be:	639c                	ld	a5,0(a5)
    802007c0:	12078363          	beqz	a5,802008e6 <vprintfmt+0x2a8>
    802007c4:	86be                	mv	a3,a5
    802007c6:	00001617          	auipc	a2,0x1
    802007ca:	ac260613          	addi	a2,a2,-1342 # 80201288 <error_string+0xe8>
    802007ce:	85a6                	mv	a1,s1
    802007d0:	854a                	mv	a0,s2
    802007d2:	1cc000ef          	jal	ra,8020099e <printfmt>
    802007d6:	b54d                	j	80200678 <vprintfmt+0x3a>
    802007d8:	000ab603          	ld	a2,0(s5)
    802007dc:	0aa1                	addi	s5,s5,8
    802007de:	1a060163          	beqz	a2,80200980 <vprintfmt+0x342>
    802007e2:	00160413          	addi	s0,a2,1
    802007e6:	15b05763          	blez	s11,80200934 <vprintfmt+0x2f6>
    802007ea:	02d00593          	li	a1,45
    802007ee:	10b79d63          	bne	a5,a1,80200908 <vprintfmt+0x2ca>
    802007f2:	00064783          	lbu	a5,0(a2)
    802007f6:	0007851b          	sext.w	a0,a5
    802007fa:	c905                	beqz	a0,8020082a <vprintfmt+0x1ec>
    802007fc:	000cc563          	bltz	s9,80200806 <vprintfmt+0x1c8>
    80200800:	3cfd                	addiw	s9,s9,-1
    80200802:	036c8263          	beq	s9,s6,80200826 <vprintfmt+0x1e8>
    80200806:	85a6                	mv	a1,s1
    80200808:	14098f63          	beqz	s3,80200966 <vprintfmt+0x328>
    8020080c:	3781                	addiw	a5,a5,-32
    8020080e:	14fbfc63          	bgeu	s7,a5,80200966 <vprintfmt+0x328>
    80200812:	03f00513          	li	a0,63
    80200816:	9902                	jalr	s2
    80200818:	0405                	addi	s0,s0,1
    8020081a:	fff44783          	lbu	a5,-1(s0)
    8020081e:	3dfd                	addiw	s11,s11,-1
    80200820:	0007851b          	sext.w	a0,a5
    80200824:	fd61                	bnez	a0,802007fc <vprintfmt+0x1be>
    80200826:	e5b059e3          	blez	s11,80200678 <vprintfmt+0x3a>
    8020082a:	3dfd                	addiw	s11,s11,-1
    8020082c:	85a6                	mv	a1,s1
    8020082e:	02000513          	li	a0,32
    80200832:	9902                	jalr	s2
    80200834:	e40d82e3          	beqz	s11,80200678 <vprintfmt+0x3a>
    80200838:	3dfd                	addiw	s11,s11,-1
    8020083a:	85a6                	mv	a1,s1
    8020083c:	02000513          	li	a0,32
    80200840:	9902                	jalr	s2
    80200842:	fe0d94e3          	bnez	s11,8020082a <vprintfmt+0x1ec>
    80200846:	bd0d                	j	80200678 <vprintfmt+0x3a>
    80200848:	4705                	li	a4,1
    8020084a:	008a8593          	addi	a1,s5,8
    8020084e:	01074463          	blt	a4,a6,80200856 <vprintfmt+0x218>
    80200852:	0e080863          	beqz	a6,80200942 <vprintfmt+0x304>
    80200856:	000ab603          	ld	a2,0(s5)
    8020085a:	46a1                	li	a3,8
    8020085c:	8aae                	mv	s5,a1
    8020085e:	a839                	j	8020087c <vprintfmt+0x23e>
    80200860:	03000513          	li	a0,48
    80200864:	85a6                	mv	a1,s1
    80200866:	e03e                	sd	a5,0(sp)
    80200868:	9902                	jalr	s2
    8020086a:	85a6                	mv	a1,s1
    8020086c:	07800513          	li	a0,120
    80200870:	9902                	jalr	s2
    80200872:	0aa1                	addi	s5,s5,8
    80200874:	ff8ab603          	ld	a2,-8(s5)
    80200878:	6782                	ld	a5,0(sp)
    8020087a:	46c1                	li	a3,16
    8020087c:	2781                	sext.w	a5,a5
    8020087e:	876e                	mv	a4,s11
    80200880:	85a6                	mv	a1,s1
    80200882:	854a                	mv	a0,s2
    80200884:	d4fff0ef          	jal	ra,802005d2 <printnum>
    80200888:	bbc5                	j	80200678 <vprintfmt+0x3a>
    8020088a:	00144603          	lbu	a2,1(s0)
    8020088e:	2805                	addiw	a6,a6,1
    80200890:	846a                	mv	s0,s10
    80200892:	b515                	j	802006b6 <vprintfmt+0x78>
    80200894:	00144603          	lbu	a2,1(s0)
    80200898:	4985                	li	s3,1
    8020089a:	846a                	mv	s0,s10
    8020089c:	bd29                	j	802006b6 <vprintfmt+0x78>
    8020089e:	85a6                	mv	a1,s1
    802008a0:	02500513          	li	a0,37
    802008a4:	9902                	jalr	s2
    802008a6:	bbc9                	j	80200678 <vprintfmt+0x3a>
    802008a8:	4705                	li	a4,1
    802008aa:	008a8593          	addi	a1,s5,8
    802008ae:	01074463          	blt	a4,a6,802008b6 <vprintfmt+0x278>
    802008b2:	08080d63          	beqz	a6,8020094c <vprintfmt+0x30e>
    802008b6:	000ab603          	ld	a2,0(s5)
    802008ba:	46a9                	li	a3,10
    802008bc:	8aae                	mv	s5,a1
    802008be:	bf7d                	j	8020087c <vprintfmt+0x23e>
    802008c0:	85a6                	mv	a1,s1
    802008c2:	02500513          	li	a0,37
    802008c6:	9902                	jalr	s2
    802008c8:	fff44703          	lbu	a4,-1(s0)
    802008cc:	02500793          	li	a5,37
    802008d0:	8d22                	mv	s10,s0
    802008d2:	daf703e3          	beq	a4,a5,80200678 <vprintfmt+0x3a>
    802008d6:	02500713          	li	a4,37
    802008da:	1d7d                	addi	s10,s10,-1
    802008dc:	fffd4783          	lbu	a5,-1(s10)
    802008e0:	fee79de3          	bne	a5,a4,802008da <vprintfmt+0x29c>
    802008e4:	bb51                	j	80200678 <vprintfmt+0x3a>
    802008e6:	00001617          	auipc	a2,0x1
    802008ea:	99260613          	addi	a2,a2,-1646 # 80201278 <error_string+0xd8>
    802008ee:	85a6                	mv	a1,s1
    802008f0:	854a                	mv	a0,s2
    802008f2:	0ac000ef          	jal	ra,8020099e <printfmt>
    802008f6:	b349                	j	80200678 <vprintfmt+0x3a>
    802008f8:	00001617          	auipc	a2,0x1
    802008fc:	97860613          	addi	a2,a2,-1672 # 80201270 <error_string+0xd0>
    80200900:	00001417          	auipc	s0,0x1
    80200904:	97140413          	addi	s0,s0,-1679 # 80201271 <error_string+0xd1>
    80200908:	8532                	mv	a0,a2
    8020090a:	85e6                	mv	a1,s9
    8020090c:	e032                	sd	a2,0(sp)
    8020090e:	e43e                	sd	a5,8(sp)
    80200910:	102000ef          	jal	ra,80200a12 <strnlen>
    80200914:	40ad8dbb          	subw	s11,s11,a0
    80200918:	6602                	ld	a2,0(sp)
    8020091a:	01b05d63          	blez	s11,80200934 <vprintfmt+0x2f6>
    8020091e:	67a2                	ld	a5,8(sp)
    80200920:	2781                	sext.w	a5,a5
    80200922:	e43e                	sd	a5,8(sp)
    80200924:	6522                	ld	a0,8(sp)
    80200926:	85a6                	mv	a1,s1
    80200928:	e032                	sd	a2,0(sp)
    8020092a:	3dfd                	addiw	s11,s11,-1
    8020092c:	9902                	jalr	s2
    8020092e:	6602                	ld	a2,0(sp)
    80200930:	fe0d9ae3          	bnez	s11,80200924 <vprintfmt+0x2e6>
    80200934:	00064783          	lbu	a5,0(a2)
    80200938:	0007851b          	sext.w	a0,a5
    8020093c:	ec0510e3          	bnez	a0,802007fc <vprintfmt+0x1be>
    80200940:	bb25                	j	80200678 <vprintfmt+0x3a>
    80200942:	000ae603          	lwu	a2,0(s5)
    80200946:	46a1                	li	a3,8
    80200948:	8aae                	mv	s5,a1
    8020094a:	bf0d                	j	8020087c <vprintfmt+0x23e>
    8020094c:	000ae603          	lwu	a2,0(s5)
    80200950:	46a9                	li	a3,10
    80200952:	8aae                	mv	s5,a1
    80200954:	b725                	j	8020087c <vprintfmt+0x23e>
    80200956:	000aa403          	lw	s0,0(s5)
    8020095a:	bd35                	j	80200796 <vprintfmt+0x158>
    8020095c:	000ae603          	lwu	a2,0(s5)
    80200960:	46c1                	li	a3,16
    80200962:	8aae                	mv	s5,a1
    80200964:	bf21                	j	8020087c <vprintfmt+0x23e>
    80200966:	9902                	jalr	s2
    80200968:	bd45                	j	80200818 <vprintfmt+0x1da>
    8020096a:	85a6                	mv	a1,s1
    8020096c:	02d00513          	li	a0,45
    80200970:	e03e                	sd	a5,0(sp)
    80200972:	9902                	jalr	s2
    80200974:	8ace                	mv	s5,s3
    80200976:	40800633          	neg	a2,s0
    8020097a:	46a9                	li	a3,10
    8020097c:	6782                	ld	a5,0(sp)
    8020097e:	bdfd                	j	8020087c <vprintfmt+0x23e>
    80200980:	01b05663          	blez	s11,8020098c <vprintfmt+0x34e>
    80200984:	02d00693          	li	a3,45
    80200988:	f6d798e3          	bne	a5,a3,802008f8 <vprintfmt+0x2ba>
    8020098c:	00001417          	auipc	s0,0x1
    80200990:	8e540413          	addi	s0,s0,-1819 # 80201271 <error_string+0xd1>
    80200994:	02800513          	li	a0,40
    80200998:	02800793          	li	a5,40
    8020099c:	b585                	j	802007fc <vprintfmt+0x1be>

000000008020099e <printfmt>:
    8020099e:	715d                	addi	sp,sp,-80
    802009a0:	02810313          	addi	t1,sp,40
    802009a4:	f436                	sd	a3,40(sp)
    802009a6:	869a                	mv	a3,t1
    802009a8:	ec06                	sd	ra,24(sp)
    802009aa:	f83a                	sd	a4,48(sp)
    802009ac:	fc3e                	sd	a5,56(sp)
    802009ae:	e0c2                	sd	a6,64(sp)
    802009b0:	e4c6                	sd	a7,72(sp)
    802009b2:	e41a                	sd	t1,8(sp)
    802009b4:	c8bff0ef          	jal	ra,8020063e <vprintfmt>
    802009b8:	60e2                	ld	ra,24(sp)
    802009ba:	6161                	addi	sp,sp,80
    802009bc:	8082                	ret

00000000802009be <sbi_console_putchar>:
    802009be:	00003797          	auipc	a5,0x3
    802009c2:	64278793          	addi	a5,a5,1602 # 80204000 <bootstacktop>
    802009c6:	6398                	ld	a4,0(a5)
    802009c8:	4781                	li	a5,0
    802009ca:	88ba                	mv	a7,a4
    802009cc:	852a                	mv	a0,a0
    802009ce:	85be                	mv	a1,a5
    802009d0:	863e                	mv	a2,a5
    802009d2:	00000073          	ecall
    802009d6:	87aa                	mv	a5,a0
    802009d8:	8082                	ret

00000000802009da <sbi_set_timer>:
    802009da:	00003797          	auipc	a5,0x3
    802009de:	64678793          	addi	a5,a5,1606 # 80204020 <SBI_SET_TIMER>
    802009e2:	6398                	ld	a4,0(a5)
    802009e4:	4781                	li	a5,0
    802009e6:	88ba                	mv	a7,a4
    802009e8:	852a                	mv	a0,a0
    802009ea:	85be                	mv	a1,a5
    802009ec:	863e                	mv	a2,a5
    802009ee:	00000073          	ecall
    802009f2:	87aa                	mv	a5,a0
    802009f4:	8082                	ret

00000000802009f6 <sbi_shutdown>:
    802009f6:	00003797          	auipc	a5,0x3
    802009fa:	61278793          	addi	a5,a5,1554 # 80204008 <SBI_SHUTDOWN>
    802009fe:	6398                	ld	a4,0(a5)
    80200a00:	4781                	li	a5,0
    80200a02:	88ba                	mv	a7,a4
    80200a04:	853e                	mv	a0,a5
    80200a06:	85be                	mv	a1,a5
    80200a08:	863e                	mv	a2,a5
    80200a0a:	00000073          	ecall
    80200a0e:	87aa                	mv	a5,a0
    80200a10:	8082                	ret

0000000080200a12 <strnlen>:
    80200a12:	c185                	beqz	a1,80200a32 <strnlen+0x20>
    80200a14:	00054783          	lbu	a5,0(a0)
    80200a18:	cf89                	beqz	a5,80200a32 <strnlen+0x20>
    80200a1a:	4781                	li	a5,0
    80200a1c:	a021                	j	80200a24 <strnlen+0x12>
    80200a1e:	00074703          	lbu	a4,0(a4)
    80200a22:	c711                	beqz	a4,80200a2e <strnlen+0x1c>
    80200a24:	0785                	addi	a5,a5,1
    80200a26:	00f50733          	add	a4,a0,a5
    80200a2a:	fef59ae3          	bne	a1,a5,80200a1e <strnlen+0xc>
    80200a2e:	853e                	mv	a0,a5
    80200a30:	8082                	ret
    80200a32:	4781                	li	a5,0
    80200a34:	853e                	mv	a0,a5
    80200a36:	8082                	ret

0000000080200a38 <memset>:
    80200a38:	ca01                	beqz	a2,80200a48 <memset+0x10>
    80200a3a:	962a                	add	a2,a2,a0
    80200a3c:	87aa                	mv	a5,a0
    80200a3e:	0785                	addi	a5,a5,1
    80200a40:	feb78fa3          	sb	a1,-1(a5)
    80200a44:	fec79de3          	bne	a5,a2,80200a3e <memset+0x6>
    80200a48:	8082                	ret

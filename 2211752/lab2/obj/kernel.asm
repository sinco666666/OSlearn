
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
ffffffffc0200020:	18029073          	csrw	satp,t0
ffffffffc0200024:	12000073          	sfence.vma
ffffffffc0200028:	c0205137          	lui	sp,0xc0205
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <buf>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	53a60613          	addi	a2,a2,1338 # ffffffffc0206578 <end>
ffffffffc0200046:	1141                	addi	sp,sp,-16
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
ffffffffc020004c:	e406                	sd	ra,8(sp)
ffffffffc020004e:	5f8010ef          	jal	ra,ffffffffc0201646 <memset>
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0201b78 <etext+0x4>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>
ffffffffc0200062:	13a000ef          	jal	ra,ffffffffc020019c <print_kerninfo>
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc020006a:	11d000ef          	jal	ra,ffffffffc0200986 <pmm_init>
ffffffffc020006e:	3f6000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc0200072:	396000ef          	jal	ra,ffffffffc0200408 <clock_init>
ffffffffc0200076:	3e2000ef          	jal	ra,ffffffffc0200458 <intr_enable>
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
ffffffffc0200084:	3c8000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200088:	401c                	lw	a5,0(s0)
ffffffffc020008a:	60a2                	ld	ra,8(sp)
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
ffffffffc0200096:	1101                	addi	sp,sp,-32
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
ffffffffc02000a8:	c602                	sw	zero,12(sp)
ffffffffc02000aa:	61a010ef          	jal	ra,ffffffffc02016c4 <vprintfmt>
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
ffffffffc02000b6:	711d                	addi	sp,sp,-96
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
ffffffffc02000da:	e41a                	sd	t1,8(sp)
ffffffffc02000dc:	c202                	sw	zero,4(sp)
ffffffffc02000de:	5e6010ef          	jal	ra,ffffffffc02016c4 <vprintfmt>
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:
ffffffffc02000ea:	a68d                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ec <cputs>:
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	e822                	sd	s0,16(sp)
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e426                	sd	s1,8(sp)
ffffffffc02000f4:	842a                	mv	s0,a0
ffffffffc02000f6:	00054503          	lbu	a0,0(a0)
ffffffffc02000fa:	c51d                	beqz	a0,ffffffffc0200128 <cputs+0x3c>
ffffffffc02000fc:	0405                	addi	s0,s0,1
ffffffffc02000fe:	4485                	li	s1,1
ffffffffc0200100:	9c81                	subw	s1,s1,s0
ffffffffc0200102:	34a000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200106:	008487bb          	addw	a5,s1,s0
ffffffffc020010a:	0405                	addi	s0,s0,1
ffffffffc020010c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200110:	f96d                	bnez	a0,ffffffffc0200102 <cputs+0x16>
ffffffffc0200112:	0017841b          	addiw	s0,a5,1
ffffffffc0200116:	4529                	li	a0,10
ffffffffc0200118:	334000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	6442                	ld	s0,16(sp)
ffffffffc0200122:	64a2                	ld	s1,8(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret
ffffffffc0200128:	4405                	li	s0,1
ffffffffc020012a:	b7f5                	j	ffffffffc0200116 <cputs+0x2a>

ffffffffc020012c <getchar>:
ffffffffc020012c:	1141                	addi	sp,sp,-16
ffffffffc020012e:	e406                	sd	ra,8(sp)
ffffffffc0200130:	324000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200134:	dd75                	beqz	a0,ffffffffc0200130 <getchar+0x4>
ffffffffc0200136:	60a2                	ld	ra,8(sp)
ffffffffc0200138:	0141                	addi	sp,sp,16
ffffffffc020013a:	8082                	ret

ffffffffc020013c <__panic>:
ffffffffc020013c:	00006317          	auipc	t1,0x6
ffffffffc0200140:	2dc30313          	addi	t1,t1,732 # ffffffffc0206418 <is_panic>
ffffffffc0200144:	00032303          	lw	t1,0(t1)
ffffffffc0200148:	715d                	addi	sp,sp,-80
ffffffffc020014a:	ec06                	sd	ra,24(sp)
ffffffffc020014c:	e822                	sd	s0,16(sp)
ffffffffc020014e:	f436                	sd	a3,40(sp)
ffffffffc0200150:	f83a                	sd	a4,48(sp)
ffffffffc0200152:	fc3e                	sd	a5,56(sp)
ffffffffc0200154:	e0c2                	sd	a6,64(sp)
ffffffffc0200156:	e4c6                	sd	a7,72(sp)
ffffffffc0200158:	02031c63          	bnez	t1,ffffffffc0200190 <__panic+0x54>
ffffffffc020015c:	4785                	li	a5,1
ffffffffc020015e:	8432                	mv	s0,a2
ffffffffc0200160:	00006717          	auipc	a4,0x6
ffffffffc0200164:	2af72c23          	sw	a5,696(a4) # ffffffffc0206418 <is_panic>
ffffffffc0200168:	862e                	mv	a2,a1
ffffffffc020016a:	103c                	addi	a5,sp,40
ffffffffc020016c:	85aa                	mv	a1,a0
ffffffffc020016e:	00002517          	auipc	a0,0x2
ffffffffc0200172:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0201b98 <etext+0x24>
ffffffffc0200176:	e43e                	sd	a5,8(sp)
ffffffffc0200178:	f3fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020017c:	65a2                	ld	a1,8(sp)
ffffffffc020017e:	8522                	mv	a0,s0
ffffffffc0200180:	f17ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
ffffffffc0200184:	00002517          	auipc	a0,0x2
ffffffffc0200188:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0201cb0 <etext+0x13c>
ffffffffc020018c:	f2bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200190:	2ce000ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc0200194:	4501                	li	a0,0
ffffffffc0200196:	130000ef          	jal	ra,ffffffffc02002c6 <kmonitor>
ffffffffc020019a:	bfed                	j	ffffffffc0200194 <__panic+0x58>

ffffffffc020019c <print_kerninfo>:
ffffffffc020019c:	1141                	addi	sp,sp,-16
ffffffffc020019e:	00002517          	auipc	a0,0x2
ffffffffc02001a2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0201be8 <etext+0x74>
ffffffffc02001a6:	e406                	sd	ra,8(sp)
ffffffffc02001a8:	f0fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02001ac:	00000597          	auipc	a1,0x0
ffffffffc02001b0:	e8a58593          	addi	a1,a1,-374 # ffffffffc0200036 <kern_init>
ffffffffc02001b4:	00002517          	auipc	a0,0x2
ffffffffc02001b8:	a5450513          	addi	a0,a0,-1452 # ffffffffc0201c08 <etext+0x94>
ffffffffc02001bc:	efbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02001c0:	00002597          	auipc	a1,0x2
ffffffffc02001c4:	9b458593          	addi	a1,a1,-1612 # ffffffffc0201b74 <etext>
ffffffffc02001c8:	00002517          	auipc	a0,0x2
ffffffffc02001cc:	a6050513          	addi	a0,a0,-1440 # ffffffffc0201c28 <etext+0xb4>
ffffffffc02001d0:	ee7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02001d4:	00006597          	auipc	a1,0x6
ffffffffc02001d8:	e4458593          	addi	a1,a1,-444 # ffffffffc0206018 <buf>
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201c48 <etext+0xd4>
ffffffffc02001e4:	ed3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02001e8:	00006597          	auipc	a1,0x6
ffffffffc02001ec:	39058593          	addi	a1,a1,912 # ffffffffc0206578 <end>
ffffffffc02001f0:	00002517          	auipc	a0,0x2
ffffffffc02001f4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201c68 <etext+0xf4>
ffffffffc02001f8:	ebfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02001fc:	00006597          	auipc	a1,0x6
ffffffffc0200200:	77b58593          	addi	a1,a1,1915 # ffffffffc0206977 <end+0x3ff>
ffffffffc0200204:	00000797          	auipc	a5,0x0
ffffffffc0200208:	e3278793          	addi	a5,a5,-462 # ffffffffc0200036 <kern_init>
ffffffffc020020c:	40f587b3          	sub	a5,a1,a5
ffffffffc0200210:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021a:	95be                	add	a1,a1,a5
ffffffffc020021c:	85a9                	srai	a1,a1,0xa
ffffffffc020021e:	00002517          	auipc	a0,0x2
ffffffffc0200222:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0201c88 <etext+0x114>
ffffffffc0200226:	0141                	addi	sp,sp,16
ffffffffc0200228:	b579                	j	ffffffffc02000b6 <cprintf>

ffffffffc020022a <print_stackframe>:
ffffffffc020022a:	1141                	addi	sp,sp,-16
ffffffffc020022c:	00002617          	auipc	a2,0x2
ffffffffc0200230:	98c60613          	addi	a2,a2,-1652 # ffffffffc0201bb8 <etext+0x44>
ffffffffc0200234:	04e00593          	li	a1,78
ffffffffc0200238:	00002517          	auipc	a0,0x2
ffffffffc020023c:	99850513          	addi	a0,a0,-1640 # ffffffffc0201bd0 <etext+0x5c>
ffffffffc0200240:	e406                	sd	ra,8(sp)
ffffffffc0200242:	efbff0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0200246 <mon_help>:
ffffffffc0200246:	1141                	addi	sp,sp,-16
ffffffffc0200248:	00002617          	auipc	a2,0x2
ffffffffc020024c:	b5060613          	addi	a2,a2,-1200 # ffffffffc0201d98 <commands+0xe0>
ffffffffc0200250:	00002597          	auipc	a1,0x2
ffffffffc0200254:	b6858593          	addi	a1,a1,-1176 # ffffffffc0201db8 <commands+0x100>
ffffffffc0200258:	00002517          	auipc	a0,0x2
ffffffffc020025c:	b6850513          	addi	a0,a0,-1176 # ffffffffc0201dc0 <commands+0x108>
ffffffffc0200260:	e406                	sd	ra,8(sp)
ffffffffc0200262:	e55ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200266:	00002617          	auipc	a2,0x2
ffffffffc020026a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0201dd0 <commands+0x118>
ffffffffc020026e:	00002597          	auipc	a1,0x2
ffffffffc0200272:	b8a58593          	addi	a1,a1,-1142 # ffffffffc0201df8 <commands+0x140>
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0201dc0 <commands+0x108>
ffffffffc020027e:	e39ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200282:	00002617          	auipc	a2,0x2
ffffffffc0200286:	b8660613          	addi	a2,a2,-1146 # ffffffffc0201e08 <commands+0x150>
ffffffffc020028a:	00002597          	auipc	a1,0x2
ffffffffc020028e:	b9e58593          	addi	a1,a1,-1122 # ffffffffc0201e28 <commands+0x170>
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0201dc0 <commands+0x108>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020029e:	60a2                	ld	ra,8(sp)
ffffffffc02002a0:	4501                	li	a0,0
ffffffffc02002a2:	0141                	addi	sp,sp,16
ffffffffc02002a4:	8082                	ret

ffffffffc02002a6 <mon_kerninfo>:
ffffffffc02002a6:	1141                	addi	sp,sp,-16
ffffffffc02002a8:	e406                	sd	ra,8(sp)
ffffffffc02002aa:	ef3ff0ef          	jal	ra,ffffffffc020019c <print_kerninfo>
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
ffffffffc02002b0:	4501                	li	a0,0
ffffffffc02002b2:	0141                	addi	sp,sp,16
ffffffffc02002b4:	8082                	ret

ffffffffc02002b6 <mon_backtrace>:
ffffffffc02002b6:	1141                	addi	sp,sp,-16
ffffffffc02002b8:	e406                	sd	ra,8(sp)
ffffffffc02002ba:	f71ff0ef          	jal	ra,ffffffffc020022a <print_stackframe>
ffffffffc02002be:	60a2                	ld	ra,8(sp)
ffffffffc02002c0:	4501                	li	a0,0
ffffffffc02002c2:	0141                	addi	sp,sp,16
ffffffffc02002c4:	8082                	ret

ffffffffc02002c6 <kmonitor>:
ffffffffc02002c6:	7115                	addi	sp,sp,-224
ffffffffc02002c8:	e962                	sd	s8,144(sp)
ffffffffc02002ca:	8c2a                	mv	s8,a0
ffffffffc02002cc:	00002517          	auipc	a0,0x2
ffffffffc02002d0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0201d00 <commands+0x48>
ffffffffc02002d4:	ed86                	sd	ra,216(sp)
ffffffffc02002d6:	e9a2                	sd	s0,208(sp)
ffffffffc02002d8:	e5a6                	sd	s1,200(sp)
ffffffffc02002da:	e1ca                	sd	s2,192(sp)
ffffffffc02002dc:	fd4e                	sd	s3,184(sp)
ffffffffc02002de:	f952                	sd	s4,176(sp)
ffffffffc02002e0:	f556                	sd	s5,168(sp)
ffffffffc02002e2:	f15a                	sd	s6,160(sp)
ffffffffc02002e4:	ed5e                	sd	s7,152(sp)
ffffffffc02002e6:	e566                	sd	s9,136(sp)
ffffffffc02002e8:	e16a                	sd	s10,128(sp)
ffffffffc02002ea:	dcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02002ee:	00002517          	auipc	a0,0x2
ffffffffc02002f2:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201d28 <commands+0x70>
ffffffffc02002f6:	dc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02002fa:	000c0563          	beqz	s8,ffffffffc0200304 <kmonitor+0x3e>
ffffffffc02002fe:	8562                	mv	a0,s8
ffffffffc0200300:	342000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc0200304:	00002c97          	auipc	s9,0x2
ffffffffc0200308:	9b4c8c93          	addi	s9,s9,-1612 # ffffffffc0201cb8 <commands>
ffffffffc020030c:	00002997          	auipc	s3,0x2
ffffffffc0200310:	a4498993          	addi	s3,s3,-1468 # ffffffffc0201d50 <commands+0x98>
ffffffffc0200314:	00002917          	auipc	s2,0x2
ffffffffc0200318:	a4490913          	addi	s2,s2,-1468 # ffffffffc0201d58 <commands+0xa0>
ffffffffc020031c:	4a3d                	li	s4,15
ffffffffc020031e:	00002b17          	auipc	s6,0x2
ffffffffc0200322:	a42b0b13          	addi	s6,s6,-1470 # ffffffffc0201d60 <commands+0xa8>
ffffffffc0200326:	00002a97          	auipc	s5,0x2
ffffffffc020032a:	a92a8a93          	addi	s5,s5,-1390 # ffffffffc0201db8 <commands+0x100>
ffffffffc020032e:	4b8d                	li	s7,3
ffffffffc0200330:	854e                	mv	a0,s3
ffffffffc0200332:	712010ef          	jal	ra,ffffffffc0201a44 <readline>
ffffffffc0200336:	842a                	mv	s0,a0
ffffffffc0200338:	dd65                	beqz	a0,ffffffffc0200330 <kmonitor+0x6a>
ffffffffc020033a:	00054583          	lbu	a1,0(a0)
ffffffffc020033e:	4481                	li	s1,0
ffffffffc0200340:	c999                	beqz	a1,ffffffffc0200356 <kmonitor+0x90>
ffffffffc0200342:	854a                	mv	a0,s2
ffffffffc0200344:	2e4010ef          	jal	ra,ffffffffc0201628 <strchr>
ffffffffc0200348:	c925                	beqz	a0,ffffffffc02003b8 <kmonitor+0xf2>
ffffffffc020034a:	00144583          	lbu	a1,1(s0)
ffffffffc020034e:	00040023          	sb	zero,0(s0)
ffffffffc0200352:	0405                	addi	s0,s0,1
ffffffffc0200354:	f5fd                	bnez	a1,ffffffffc0200342 <kmonitor+0x7c>
ffffffffc0200356:	dce9                	beqz	s1,ffffffffc0200330 <kmonitor+0x6a>
ffffffffc0200358:	6582                	ld	a1,0(sp)
ffffffffc020035a:	00002d17          	auipc	s10,0x2
ffffffffc020035e:	95ed0d13          	addi	s10,s10,-1698 # ffffffffc0201cb8 <commands>
ffffffffc0200362:	8556                	mv	a0,s5
ffffffffc0200364:	4401                	li	s0,0
ffffffffc0200366:	0d61                	addi	s10,s10,24
ffffffffc0200368:	296010ef          	jal	ra,ffffffffc02015fe <strcmp>
ffffffffc020036c:	c919                	beqz	a0,ffffffffc0200382 <kmonitor+0xbc>
ffffffffc020036e:	2405                	addiw	s0,s0,1
ffffffffc0200370:	09740463          	beq	s0,s7,ffffffffc02003f8 <kmonitor+0x132>
ffffffffc0200374:	000d3503          	ld	a0,0(s10)
ffffffffc0200378:	6582                	ld	a1,0(sp)
ffffffffc020037a:	0d61                	addi	s10,s10,24
ffffffffc020037c:	282010ef          	jal	ra,ffffffffc02015fe <strcmp>
ffffffffc0200380:	f57d                	bnez	a0,ffffffffc020036e <kmonitor+0xa8>
ffffffffc0200382:	00141793          	slli	a5,s0,0x1
ffffffffc0200386:	97a2                	add	a5,a5,s0
ffffffffc0200388:	078e                	slli	a5,a5,0x3
ffffffffc020038a:	97e6                	add	a5,a5,s9
ffffffffc020038c:	6b9c                	ld	a5,16(a5)
ffffffffc020038e:	8662                	mv	a2,s8
ffffffffc0200390:	002c                	addi	a1,sp,8
ffffffffc0200392:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200396:	9782                	jalr	a5
ffffffffc0200398:	f8055ce3          	bgez	a0,ffffffffc0200330 <kmonitor+0x6a>
ffffffffc020039c:	60ee                	ld	ra,216(sp)
ffffffffc020039e:	644e                	ld	s0,208(sp)
ffffffffc02003a0:	64ae                	ld	s1,200(sp)
ffffffffc02003a2:	690e                	ld	s2,192(sp)
ffffffffc02003a4:	79ea                	ld	s3,184(sp)
ffffffffc02003a6:	7a4a                	ld	s4,176(sp)
ffffffffc02003a8:	7aaa                	ld	s5,168(sp)
ffffffffc02003aa:	7b0a                	ld	s6,160(sp)
ffffffffc02003ac:	6bea                	ld	s7,152(sp)
ffffffffc02003ae:	6c4a                	ld	s8,144(sp)
ffffffffc02003b0:	6caa                	ld	s9,136(sp)
ffffffffc02003b2:	6d0a                	ld	s10,128(sp)
ffffffffc02003b4:	612d                	addi	sp,sp,224
ffffffffc02003b6:	8082                	ret
ffffffffc02003b8:	00044783          	lbu	a5,0(s0)
ffffffffc02003bc:	dfc9                	beqz	a5,ffffffffc0200356 <kmonitor+0x90>
ffffffffc02003be:	03448863          	beq	s1,s4,ffffffffc02003ee <kmonitor+0x128>
ffffffffc02003c2:	00349793          	slli	a5,s1,0x3
ffffffffc02003c6:	0118                	addi	a4,sp,128
ffffffffc02003c8:	97ba                	add	a5,a5,a4
ffffffffc02003ca:	f887b023          	sd	s0,-128(a5)
ffffffffc02003ce:	00044583          	lbu	a1,0(s0)
ffffffffc02003d2:	2485                	addiw	s1,s1,1
ffffffffc02003d4:	e591                	bnez	a1,ffffffffc02003e0 <kmonitor+0x11a>
ffffffffc02003d6:	b749                	j	ffffffffc0200358 <kmonitor+0x92>
ffffffffc02003d8:	0405                	addi	s0,s0,1
ffffffffc02003da:	00044583          	lbu	a1,0(s0)
ffffffffc02003de:	ddad                	beqz	a1,ffffffffc0200358 <kmonitor+0x92>
ffffffffc02003e0:	854a                	mv	a0,s2
ffffffffc02003e2:	246010ef          	jal	ra,ffffffffc0201628 <strchr>
ffffffffc02003e6:	d96d                	beqz	a0,ffffffffc02003d8 <kmonitor+0x112>
ffffffffc02003e8:	00044583          	lbu	a1,0(s0)
ffffffffc02003ec:	bf91                	j	ffffffffc0200340 <kmonitor+0x7a>
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003f6:	b7f1                	j	ffffffffc02003c2 <kmonitor+0xfc>
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	98650513          	addi	a0,a0,-1658 # ffffffffc0201d80 <commands+0xc8>
ffffffffc0200402:	cb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200406:	b72d                	j	ffffffffc0200330 <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200414:	c0102573          	rdtime	a0
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	6fe010ef          	jal	ra,ffffffffc0201b1e <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0207b123          	sd	zero,34(a5) # ffffffffc0206448 <ticks>
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e38 <commands+0x180>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9bd                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	6d80106f          	j	ffffffffc0201b1e <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	6b20106f          	j	ffffffffc0201b02 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	6e60106f          	j	ffffffffc0201b3a <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
ffffffffc0200464:	14005073          	csrwi	sscratch,0
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	3a078793          	addi	a5,a5,928 # ffffffffc0200808 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
ffffffffc0200476:	610c                	ld	a1,0(a0)
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0201fd8 <commands+0x320>
ffffffffc0200486:	e406                	sd	ra,8(sp)
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	b6250513          	addi	a0,a0,-1182 # ffffffffc0201ff0 <commands+0x338>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202008 <commands+0x350>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202020 <commands+0x368>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202038 <commands+0x380>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202050 <commands+0x398>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	b9450513          	addi	a0,a0,-1132 # ffffffffc0202068 <commands+0x3b0>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202080 <commands+0x3c8>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0202098 <commands+0x3e0>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	bb250513          	addi	a0,a0,-1102 # ffffffffc02020b0 <commands+0x3f8>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02020c8 <commands+0x410>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	bc650513          	addi	a0,a0,-1082 # ffffffffc02020e0 <commands+0x428>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	bd050513          	addi	a0,a0,-1072 # ffffffffc02020f8 <commands+0x440>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202110 <commands+0x458>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	be450513          	addi	a0,a0,-1052 # ffffffffc0202128 <commands+0x470>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	bee50513          	addi	a0,a0,-1042 # ffffffffc0202140 <commands+0x488>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202158 <commands+0x4a0>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	c0250513          	addi	a0,a0,-1022 # ffffffffc0202170 <commands+0x4b8>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202188 <commands+0x4d0>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	c1650513          	addi	a0,a0,-1002 # ffffffffc02021a0 <commands+0x4e8>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	c2050513          	addi	a0,a0,-992 # ffffffffc02021b8 <commands+0x500>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	c2a50513          	addi	a0,a0,-982 # ffffffffc02021d0 <commands+0x518>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	c3450513          	addi	a0,a0,-972 # ffffffffc02021e8 <commands+0x530>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	c3e50513          	addi	a0,a0,-962 # ffffffffc0202200 <commands+0x548>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	c4850513          	addi	a0,a0,-952 # ffffffffc0202218 <commands+0x560>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	c5250513          	addi	a0,a0,-942 # ffffffffc0202230 <commands+0x578>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	c5c50513          	addi	a0,a0,-932 # ffffffffc0202248 <commands+0x590>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	c6650513          	addi	a0,a0,-922 # ffffffffc0202260 <commands+0x5a8>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	c7050513          	addi	a0,a0,-912 # ffffffffc0202278 <commands+0x5c0>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0202290 <commands+0x5d8>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	c8450513          	addi	a0,a0,-892 # ffffffffc02022a8 <commands+0x5f0>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	c8a50513          	addi	a0,a0,-886 # ffffffffc02022c0 <commands+0x608>
ffffffffc020063e:	0141                	addi	sp,sp,16
ffffffffc0200640:	bc9d                	j	ffffffffc02000b6 <cprintf>

ffffffffc0200642 <print_trapframe>:
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
ffffffffc0200646:	85aa                	mv	a1,a0
ffffffffc0200648:	842a                	mv	s0,a0
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022d8 <commands+0x620>
ffffffffc0200652:	e406                	sd	ra,8(sp)
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	c8e50513          	addi	a0,a0,-882 # ffffffffc02022f0 <commands+0x638>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	c9650513          	addi	a0,a0,-874 # ffffffffc0202308 <commands+0x650>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	c9e50513          	addi	a0,a0,-866 # ffffffffc0202320 <commands+0x668>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020068e:	11843583          	ld	a1,280(s0)
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	ca250513          	addi	a0,a0,-862 # ffffffffc0202338 <commands+0x680>
ffffffffc020069e:	0141                	addi	sp,sp,16
ffffffffc02006a0:	bc19                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a2 <interrupt_handler>:
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	08f76963          	bltu	a4,a5,ffffffffc020073e <interrupt_handler+0x9c>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7a470713          	addi	a4,a4,1956 # ffffffffc0201e54 <commands+0x19c>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201f70 <commands+0x2b8>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	88450513          	addi	a0,a0,-1916 # ffffffffc0201f50 <commands+0x298>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201f10 <commands+0x258>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201f90 <commands+0x2d8>
ffffffffc02006e8:	b2f9                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e022                	sd	s0,0(sp)
ffffffffc02006ee:	e406                	sd	ra,8(sp)
ffffffffc02006f0:	d4bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
ffffffffc02006f4:	00006797          	auipc	a5,0x6
ffffffffc02006f8:	d3478793          	addi	a5,a5,-716 # ffffffffc0206428 <ticks.1331>
ffffffffc02006fc:	439c                	lw	a5,0(a5)
ffffffffc02006fe:	06400713          	li	a4,100
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d1e40413          	addi	s0,s0,-738 # ffffffffc0206420 <num>
ffffffffc020070a:	2785                	addiw	a5,a5,1
ffffffffc020070c:	02e7e73b          	remw	a4,a5,a4
ffffffffc0200710:	00006697          	auipc	a3,0x6
ffffffffc0200714:	d0f6ac23          	sw	a5,-744(a3) # ffffffffc0206428 <ticks.1331>
ffffffffc0200718:	c705                	beqz	a4,ffffffffc0200740 <interrupt_handler+0x9e>
ffffffffc020071a:	6018                	ld	a4,0(s0)
ffffffffc020071c:	47a9                	li	a5,10
ffffffffc020071e:	04f70063          	beq	a4,a5,ffffffffc020075e <interrupt_handler+0xbc>
ffffffffc0200722:	60a2                	ld	ra,8(sp)
ffffffffc0200724:	6402                	ld	s0,0(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201fb8 <commands+0x300>
ffffffffc0200732:	b251                	j	ffffffffc02000b6 <cprintf>
ffffffffc0200734:	00001517          	auipc	a0,0x1
ffffffffc0200738:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201f30 <commands+0x278>
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>
ffffffffc020073e:	b711                	j	ffffffffc0200642 <print_trapframe>
ffffffffc0200740:	601c                	ld	a5,0(s0)
ffffffffc0200742:	06400593          	li	a1,100
ffffffffc0200746:	00002517          	auipc	a0,0x2
ffffffffc020074a:	86250513          	addi	a0,a0,-1950 # ffffffffc0201fa8 <commands+0x2f0>
ffffffffc020074e:	0785                	addi	a5,a5,1
ffffffffc0200750:	00006717          	auipc	a4,0x6
ffffffffc0200754:	ccf73823          	sd	a5,-816(a4) # ffffffffc0206420 <num>
ffffffffc0200758:	95fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020075c:	bf7d                	j	ffffffffc020071a <interrupt_handler+0x78>
ffffffffc020075e:	6402                	ld	s0,0(sp)
ffffffffc0200760:	60a2                	ld	ra,8(sp)
ffffffffc0200762:	0141                	addi	sp,sp,16
ffffffffc0200764:	3f40106f          	j	ffffffffc0201b58 <sbi_shutdown>

ffffffffc0200768 <exception_handler>:
ffffffffc0200768:	11853783          	ld	a5,280(a0)
ffffffffc020076c:	472d                	li	a4,11
ffffffffc020076e:	02f76863          	bltu	a4,a5,ffffffffc020079e <exception_handler+0x36>
ffffffffc0200772:	4705                	li	a4,1
ffffffffc0200774:	00f71733          	sll	a4,a4,a5
ffffffffc0200778:	6785                	lui	a5,0x1
ffffffffc020077a:	f5178793          	addi	a5,a5,-175 # f51 <kern_entry-0xffffffffc01ff0af>
ffffffffc020077e:	8ff9                	and	a5,a5,a4
ffffffffc0200780:	ef91                	bnez	a5,ffffffffc020079c <exception_handler+0x34>
ffffffffc0200782:	1141                	addi	sp,sp,-16
ffffffffc0200784:	e022                	sd	s0,0(sp)
ffffffffc0200786:	e406                	sd	ra,8(sp)
ffffffffc0200788:	00877793          	andi	a5,a4,8
ffffffffc020078c:	842a                	mv	s0,a0
ffffffffc020078e:	e3a1                	bnez	a5,ffffffffc02007ce <exception_handler+0x66>
ffffffffc0200790:	8b11                	andi	a4,a4,4
ffffffffc0200792:	e719                	bnez	a4,ffffffffc02007a0 <exception_handler+0x38>
ffffffffc0200794:	6402                	ld	s0,0(sp)
ffffffffc0200796:	60a2                	ld	ra,8(sp)
ffffffffc0200798:	0141                	addi	sp,sp,16
ffffffffc020079a:	b565                	j	ffffffffc0200642 <print_trapframe>
ffffffffc020079c:	8082                	ret
ffffffffc020079e:	b555                	j	ffffffffc0200642 <print_trapframe>
ffffffffc02007a0:	00001517          	auipc	a0,0x1
ffffffffc02007a4:	6e850513          	addi	a0,a0,1768 # ffffffffc0201e88 <commands+0x1d0>
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02007ac:	10843583          	ld	a1,264(s0)
ffffffffc02007b0:	00001517          	auipc	a0,0x1
ffffffffc02007b4:	70050513          	addi	a0,a0,1792 # ffffffffc0201eb0 <commands+0x1f8>
ffffffffc02007b8:	8ffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02007bc:	10843783          	ld	a5,264(s0)
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	0791                	addi	a5,a5,4
ffffffffc02007c4:	10f43423          	sd	a5,264(s0)
ffffffffc02007c8:	6402                	ld	s0,0(sp)
ffffffffc02007ca:	0141                	addi	sp,sp,16
ffffffffc02007cc:	8082                	ret
ffffffffc02007ce:	00001517          	auipc	a0,0x1
ffffffffc02007d2:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ed8 <commands+0x220>
ffffffffc02007d6:	8e1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02007da:	10843583          	ld	a1,264(s0)
ffffffffc02007de:	00001517          	auipc	a0,0x1
ffffffffc02007e2:	71a50513          	addi	a0,a0,1818 # ffffffffc0201ef8 <commands+0x240>
ffffffffc02007e6:	8d1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02007ea:	10843783          	ld	a5,264(s0)
ffffffffc02007ee:	60a2                	ld	ra,8(sp)
ffffffffc02007f0:	0789                	addi	a5,a5,2
ffffffffc02007f2:	10f43423          	sd	a5,264(s0)
ffffffffc02007f6:	6402                	ld	s0,0(sp)
ffffffffc02007f8:	0141                	addi	sp,sp,16
ffffffffc02007fa:	8082                	ret

ffffffffc02007fc <trap>:
ffffffffc02007fc:	11853783          	ld	a5,280(a0)
ffffffffc0200800:	0007c363          	bltz	a5,ffffffffc0200806 <trap+0xa>
ffffffffc0200804:	b795                	j	ffffffffc0200768 <exception_handler>
ffffffffc0200806:	bd71                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc0200808 <__alltraps>:
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
ffffffffc020086a:	850a                	mv	a0,sp
ffffffffc020086c:	f91ff0ef          	jal	ra,ffffffffc02007fc <trap>

ffffffffc0200870 <__trapret>:
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
ffffffffc02008ba:	10200073          	sret

ffffffffc02008be <alloc_pages>:
ffffffffc02008be:	100027f3          	csrr	a5,sstatus
ffffffffc02008c2:	8b89                	andi	a5,a5,2
ffffffffc02008c4:	eb89                	bnez	a5,ffffffffc02008d6 <alloc_pages+0x18>
ffffffffc02008c6:	00006797          	auipc	a5,0x6
ffffffffc02008ca:	c9a78793          	addi	a5,a5,-870 # ffffffffc0206560 <pmm_manager>
ffffffffc02008ce:	639c                	ld	a5,0(a5)
ffffffffc02008d0:	0187b303          	ld	t1,24(a5)
ffffffffc02008d4:	8302                	jr	t1
ffffffffc02008d6:	1141                	addi	sp,sp,-16
ffffffffc02008d8:	e406                	sd	ra,8(sp)
ffffffffc02008da:	e022                	sd	s0,0(sp)
ffffffffc02008dc:	842a                	mv	s0,a0
ffffffffc02008de:	b81ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc02008e2:	00006797          	auipc	a5,0x6
ffffffffc02008e6:	c7e78793          	addi	a5,a5,-898 # ffffffffc0206560 <pmm_manager>
ffffffffc02008ea:	639c                	ld	a5,0(a5)
ffffffffc02008ec:	8522                	mv	a0,s0
ffffffffc02008ee:	6f9c                	ld	a5,24(a5)
ffffffffc02008f0:	9782                	jalr	a5
ffffffffc02008f2:	842a                	mv	s0,a0
ffffffffc02008f4:	b65ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
ffffffffc02008f8:	8522                	mv	a0,s0
ffffffffc02008fa:	60a2                	ld	ra,8(sp)
ffffffffc02008fc:	6402                	ld	s0,0(sp)
ffffffffc02008fe:	0141                	addi	sp,sp,16
ffffffffc0200900:	8082                	ret

ffffffffc0200902 <free_pages>:
ffffffffc0200902:	100027f3          	csrr	a5,sstatus
ffffffffc0200906:	8b89                	andi	a5,a5,2
ffffffffc0200908:	eb89                	bnez	a5,ffffffffc020091a <free_pages+0x18>
ffffffffc020090a:	00006797          	auipc	a5,0x6
ffffffffc020090e:	c5678793          	addi	a5,a5,-938 # ffffffffc0206560 <pmm_manager>
ffffffffc0200912:	639c                	ld	a5,0(a5)
ffffffffc0200914:	0207b303          	ld	t1,32(a5)
ffffffffc0200918:	8302                	jr	t1
ffffffffc020091a:	1101                	addi	sp,sp,-32
ffffffffc020091c:	ec06                	sd	ra,24(sp)
ffffffffc020091e:	e822                	sd	s0,16(sp)
ffffffffc0200920:	e426                	sd	s1,8(sp)
ffffffffc0200922:	842a                	mv	s0,a0
ffffffffc0200924:	84ae                	mv	s1,a1
ffffffffc0200926:	b39ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc020092a:	00006797          	auipc	a5,0x6
ffffffffc020092e:	c3678793          	addi	a5,a5,-970 # ffffffffc0206560 <pmm_manager>
ffffffffc0200932:	639c                	ld	a5,0(a5)
ffffffffc0200934:	85a6                	mv	a1,s1
ffffffffc0200936:	8522                	mv	a0,s0
ffffffffc0200938:	739c                	ld	a5,32(a5)
ffffffffc020093a:	9782                	jalr	a5
ffffffffc020093c:	6442                	ld	s0,16(sp)
ffffffffc020093e:	60e2                	ld	ra,24(sp)
ffffffffc0200940:	64a2                	ld	s1,8(sp)
ffffffffc0200942:	6105                	addi	sp,sp,32
ffffffffc0200944:	be11                	j	ffffffffc0200458 <intr_enable>

ffffffffc0200946 <nr_free_pages>:
ffffffffc0200946:	100027f3          	csrr	a5,sstatus
ffffffffc020094a:	8b89                	andi	a5,a5,2
ffffffffc020094c:	eb89                	bnez	a5,ffffffffc020095e <nr_free_pages+0x18>
ffffffffc020094e:	00006797          	auipc	a5,0x6
ffffffffc0200952:	c1278793          	addi	a5,a5,-1006 # ffffffffc0206560 <pmm_manager>
ffffffffc0200956:	639c                	ld	a5,0(a5)
ffffffffc0200958:	0287b303          	ld	t1,40(a5)
ffffffffc020095c:	8302                	jr	t1
ffffffffc020095e:	1141                	addi	sp,sp,-16
ffffffffc0200960:	e406                	sd	ra,8(sp)
ffffffffc0200962:	e022                	sd	s0,0(sp)
ffffffffc0200964:	afbff0ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc0200968:	00006797          	auipc	a5,0x6
ffffffffc020096c:	bf878793          	addi	a5,a5,-1032 # ffffffffc0206560 <pmm_manager>
ffffffffc0200970:	639c                	ld	a5,0(a5)
ffffffffc0200972:	779c                	ld	a5,40(a5)
ffffffffc0200974:	9782                	jalr	a5
ffffffffc0200976:	842a                	mv	s0,a0
ffffffffc0200978:	ae1ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
ffffffffc020097c:	8522                	mv	a0,s0
ffffffffc020097e:	60a2                	ld	ra,8(sp)
ffffffffc0200980:	6402                	ld	s0,0(sp)
ffffffffc0200982:	0141                	addi	sp,sp,16
ffffffffc0200984:	8082                	ret

ffffffffc0200986 <pmm_init>:
ffffffffc0200986:	00002797          	auipc	a5,0x2
ffffffffc020098a:	e2a78793          	addi	a5,a5,-470 # ffffffffc02027b0 <best_fit_pmm_manager>
ffffffffc020098e:	638c                	ld	a1,0(a5)
ffffffffc0200990:	1101                	addi	sp,sp,-32
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	9be50513          	addi	a0,a0,-1602 # ffffffffc0202350 <commands+0x698>
ffffffffc020099a:	ec06                	sd	ra,24(sp)
ffffffffc020099c:	00006717          	auipc	a4,0x6
ffffffffc02009a0:	bcf73223          	sd	a5,-1084(a4) # ffffffffc0206560 <pmm_manager>
ffffffffc02009a4:	e822                	sd	s0,16(sp)
ffffffffc02009a6:	e426                	sd	s1,8(sp)
ffffffffc02009a8:	00006417          	auipc	s0,0x6
ffffffffc02009ac:	bb840413          	addi	s0,s0,-1096 # ffffffffc0206560 <pmm_manager>
ffffffffc02009b0:	f06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009b4:	601c                	ld	a5,0(s0)
ffffffffc02009b6:	679c                	ld	a5,8(a5)
ffffffffc02009b8:	9782                	jalr	a5
ffffffffc02009ba:	57f5                	li	a5,-3
ffffffffc02009bc:	07fa                	slli	a5,a5,0x1e
ffffffffc02009be:	00002517          	auipc	a0,0x2
ffffffffc02009c2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0202368 <commands+0x6b0>
ffffffffc02009c6:	00006717          	auipc	a4,0x6
ffffffffc02009ca:	baf73123          	sd	a5,-1118(a4) # ffffffffc0206568 <va_pa_offset>
ffffffffc02009ce:	ee8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009d2:	46c5                	li	a3,17
ffffffffc02009d4:	06ee                	slli	a3,a3,0x1b
ffffffffc02009d6:	40100613          	li	a2,1025
ffffffffc02009da:	16fd                	addi	a3,a3,-1
ffffffffc02009dc:	0656                	slli	a2,a2,0x15
ffffffffc02009de:	07e005b7          	lui	a1,0x7e00
ffffffffc02009e2:	00002517          	auipc	a0,0x2
ffffffffc02009e6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202380 <commands+0x6c8>
ffffffffc02009ea:	eccff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009ee:	777d                	lui	a4,0xfffff
ffffffffc02009f0:	00007797          	auipc	a5,0x7
ffffffffc02009f4:	b8778793          	addi	a5,a5,-1145 # ffffffffc0207577 <end+0xfff>
ffffffffc02009f8:	8ff9                	and	a5,a5,a4
ffffffffc02009fa:	00088737          	lui	a4,0x88
ffffffffc02009fe:	00006697          	auipc	a3,0x6
ffffffffc0200a02:	a2e6b923          	sd	a4,-1486(a3) # ffffffffc0206430 <npage>
ffffffffc0200a06:	4601                	li	a2,0
ffffffffc0200a08:	00006717          	auipc	a4,0x6
ffffffffc0200a0c:	b6f73423          	sd	a5,-1176(a4) # ffffffffc0206570 <pages>
ffffffffc0200a10:	4681                	li	a3,0
ffffffffc0200a12:	00006897          	auipc	a7,0x6
ffffffffc0200a16:	a1e88893          	addi	a7,a7,-1506 # ffffffffc0206430 <npage>
ffffffffc0200a1a:	00006597          	auipc	a1,0x6
ffffffffc0200a1e:	b5658593          	addi	a1,a1,-1194 # ffffffffc0206570 <pages>
ffffffffc0200a22:	4805                	li	a6,1
ffffffffc0200a24:	fff80537          	lui	a0,0xfff80
ffffffffc0200a28:	a011                	j	ffffffffc0200a2c <pmm_init+0xa6>
ffffffffc0200a2a:	619c                	ld	a5,0(a1)
ffffffffc0200a2c:	97b2                	add	a5,a5,a2
ffffffffc0200a2e:	07a1                	addi	a5,a5,8
ffffffffc0200a30:	4107b02f          	amoor.d	zero,a6,(a5)
ffffffffc0200a34:	0008b703          	ld	a4,0(a7)
ffffffffc0200a38:	0685                	addi	a3,a3,1
ffffffffc0200a3a:	02860613          	addi	a2,a2,40
ffffffffc0200a3e:	00a707b3          	add	a5,a4,a0
ffffffffc0200a42:	fef6e4e3          	bltu	a3,a5,ffffffffc0200a2a <pmm_init+0xa4>
ffffffffc0200a46:	6190                	ld	a2,0(a1)
ffffffffc0200a48:	00271793          	slli	a5,a4,0x2
ffffffffc0200a4c:	97ba                	add	a5,a5,a4
ffffffffc0200a4e:	fec006b7          	lui	a3,0xfec00
ffffffffc0200a52:	078e                	slli	a5,a5,0x3
ffffffffc0200a54:	96b2                	add	a3,a3,a2
ffffffffc0200a56:	96be                	add	a3,a3,a5
ffffffffc0200a58:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a5c:	08f6e863          	bltu	a3,a5,ffffffffc0200aec <pmm_init+0x166>
ffffffffc0200a60:	00006497          	auipc	s1,0x6
ffffffffc0200a64:	b0848493          	addi	s1,s1,-1272 # ffffffffc0206568 <va_pa_offset>
ffffffffc0200a68:	609c                	ld	a5,0(s1)
ffffffffc0200a6a:	45c5                	li	a1,17
ffffffffc0200a6c:	05ee                	slli	a1,a1,0x1b
ffffffffc0200a6e:	8e9d                	sub	a3,a3,a5
ffffffffc0200a70:	04b6e963          	bltu	a3,a1,ffffffffc0200ac2 <pmm_init+0x13c>
ffffffffc0200a74:	601c                	ld	a5,0(s0)
ffffffffc0200a76:	7b9c                	ld	a5,48(a5)
ffffffffc0200a78:	9782                	jalr	a5
ffffffffc0200a7a:	00002517          	auipc	a0,0x2
ffffffffc0200a7e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202418 <commands+0x760>
ffffffffc0200a82:	e34ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200a86:	00004697          	auipc	a3,0x4
ffffffffc0200a8a:	57a68693          	addi	a3,a3,1402 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200a8e:	00006797          	auipc	a5,0x6
ffffffffc0200a92:	9ad7b523          	sd	a3,-1622(a5) # ffffffffc0206438 <satp_virtual>
ffffffffc0200a96:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a9a:	06f6e563          	bltu	a3,a5,ffffffffc0200b04 <pmm_init+0x17e>
ffffffffc0200a9e:	609c                	ld	a5,0(s1)
ffffffffc0200aa0:	6442                	ld	s0,16(sp)
ffffffffc0200aa2:	60e2                	ld	ra,24(sp)
ffffffffc0200aa4:	64a2                	ld	s1,8(sp)
ffffffffc0200aa6:	85b6                	mv	a1,a3
ffffffffc0200aa8:	8e9d                	sub	a3,a3,a5
ffffffffc0200aaa:	00006797          	auipc	a5,0x6
ffffffffc0200aae:	aad7b723          	sd	a3,-1362(a5) # ffffffffc0206558 <satp_physical>
ffffffffc0200ab2:	00002517          	auipc	a0,0x2
ffffffffc0200ab6:	98650513          	addi	a0,a0,-1658 # ffffffffc0202438 <commands+0x780>
ffffffffc0200aba:	8636                	mv	a2,a3
ffffffffc0200abc:	6105                	addi	sp,sp,32
ffffffffc0200abe:	df8ff06f          	j	ffffffffc02000b6 <cprintf>
ffffffffc0200ac2:	6785                	lui	a5,0x1
ffffffffc0200ac4:	17fd                	addi	a5,a5,-1
ffffffffc0200ac6:	96be                	add	a3,a3,a5
ffffffffc0200ac8:	77fd                	lui	a5,0xfffff
ffffffffc0200aca:	8efd                	and	a3,a3,a5
ffffffffc0200acc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200ad0:	04e7f663          	bgeu	a5,a4,ffffffffc0200b1c <pmm_init+0x196>
ffffffffc0200ad4:	6018                	ld	a4,0(s0)
ffffffffc0200ad6:	97aa                	add	a5,a5,a0
ffffffffc0200ad8:	00279513          	slli	a0,a5,0x2
ffffffffc0200adc:	953e                	add	a0,a0,a5
ffffffffc0200ade:	6b1c                	ld	a5,16(a4)
ffffffffc0200ae0:	8d95                	sub	a1,a1,a3
ffffffffc0200ae2:	050e                	slli	a0,a0,0x3
ffffffffc0200ae4:	81b1                	srli	a1,a1,0xc
ffffffffc0200ae6:	9532                	add	a0,a0,a2
ffffffffc0200ae8:	9782                	jalr	a5
ffffffffc0200aea:	b769                	j	ffffffffc0200a74 <pmm_init+0xee>
ffffffffc0200aec:	00002617          	auipc	a2,0x2
ffffffffc0200af0:	8c460613          	addi	a2,a2,-1852 # ffffffffc02023b0 <commands+0x6f8>
ffffffffc0200af4:	07100593          	li	a1,113
ffffffffc0200af8:	00002517          	auipc	a0,0x2
ffffffffc0200afc:	8e050513          	addi	a0,a0,-1824 # ffffffffc02023d8 <commands+0x720>
ffffffffc0200b00:	e3cff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200b04:	00002617          	auipc	a2,0x2
ffffffffc0200b08:	8ac60613          	addi	a2,a2,-1876 # ffffffffc02023b0 <commands+0x6f8>
ffffffffc0200b0c:	08c00593          	li	a1,140
ffffffffc0200b10:	00002517          	auipc	a0,0x2
ffffffffc0200b14:	8c850513          	addi	a0,a0,-1848 # ffffffffc02023d8 <commands+0x720>
ffffffffc0200b18:	e24ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200b1c:	00002617          	auipc	a2,0x2
ffffffffc0200b20:	8cc60613          	addi	a2,a2,-1844 # ffffffffc02023e8 <commands+0x730>
ffffffffc0200b24:	06b00593          	li	a1,107
ffffffffc0200b28:	00002517          	auipc	a0,0x2
ffffffffc0200b2c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0202408 <commands+0x750>
ffffffffc0200b30:	e0cff0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0200b34 <best_fit_init>:
ffffffffc0200b34:	00006797          	auipc	a5,0x6
ffffffffc0200b38:	91c78793          	addi	a5,a5,-1764 # ffffffffc0206450 <free_area>
ffffffffc0200b3c:	e79c                	sd	a5,8(a5)
ffffffffc0200b3e:	e39c                	sd	a5,0(a5)
ffffffffc0200b40:	0007a823          	sw	zero,16(a5)
ffffffffc0200b44:	8082                	ret

ffffffffc0200b46 <best_fit_nr_free_pages>:
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	91a56503          	lwu	a0,-1766(a0) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200b4e:	8082                	ret

ffffffffc0200b50 <best_fit_alloc_pages>:
ffffffffc0200b50:	c15d                	beqz	a0,ffffffffc0200bf6 <best_fit_alloc_pages+0xa6>
ffffffffc0200b52:	00006617          	auipc	a2,0x6
ffffffffc0200b56:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0206450 <free_area>
ffffffffc0200b5a:	01062803          	lw	a6,16(a2)
ffffffffc0200b5e:	86aa                	mv	a3,a0
ffffffffc0200b60:	02081793          	slli	a5,a6,0x20
ffffffffc0200b64:	9381                	srli	a5,a5,0x20
ffffffffc0200b66:	08a7e663          	bltu	a5,a0,ffffffffc0200bf2 <best_fit_alloc_pages+0xa2>
ffffffffc0200b6a:	0018059b          	addiw	a1,a6,1
ffffffffc0200b6e:	1582                	slli	a1,a1,0x20
ffffffffc0200b70:	9181                	srli	a1,a1,0x20
ffffffffc0200b72:	87b2                	mv	a5,a2
ffffffffc0200b74:	4501                	li	a0,0
ffffffffc0200b76:	679c                	ld	a5,8(a5)
ffffffffc0200b78:	00c78e63          	beq	a5,a2,ffffffffc0200b94 <best_fit_alloc_pages+0x44>
ffffffffc0200b7c:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200b80:	fed76be3          	bltu	a4,a3,ffffffffc0200b76 <best_fit_alloc_pages+0x26>
ffffffffc0200b84:	feb779e3          	bgeu	a4,a1,ffffffffc0200b76 <best_fit_alloc_pages+0x26>
ffffffffc0200b88:	fe878513          	addi	a0,a5,-24
ffffffffc0200b8c:	679c                	ld	a5,8(a5)
ffffffffc0200b8e:	85ba                	mv	a1,a4
ffffffffc0200b90:	fec796e3          	bne	a5,a2,ffffffffc0200b7c <best_fit_alloc_pages+0x2c>
ffffffffc0200b94:	c125                	beqz	a0,ffffffffc0200bf4 <best_fit_alloc_pages+0xa4>
ffffffffc0200b96:	7118                	ld	a4,32(a0)
ffffffffc0200b98:	6d10                	ld	a2,24(a0)
ffffffffc0200b9a:	490c                	lw	a1,16(a0)
ffffffffc0200b9c:	0006889b          	sext.w	a7,a3
ffffffffc0200ba0:	e618                	sd	a4,8(a2)
ffffffffc0200ba2:	e310                	sd	a2,0(a4)
ffffffffc0200ba4:	02059713          	slli	a4,a1,0x20
ffffffffc0200ba8:	9301                	srli	a4,a4,0x20
ffffffffc0200baa:	02e6f863          	bgeu	a3,a4,ffffffffc0200bda <best_fit_alloc_pages+0x8a>
ffffffffc0200bae:	00269713          	slli	a4,a3,0x2
ffffffffc0200bb2:	9736                	add	a4,a4,a3
ffffffffc0200bb4:	070e                	slli	a4,a4,0x3
ffffffffc0200bb6:	972a                	add	a4,a4,a0
ffffffffc0200bb8:	411585bb          	subw	a1,a1,a7
ffffffffc0200bbc:	cb0c                	sw	a1,16(a4)
ffffffffc0200bbe:	4689                	li	a3,2
ffffffffc0200bc0:	00870593          	addi	a1,a4,8
ffffffffc0200bc4:	40d5b02f          	amoor.d	zero,a3,(a1)
ffffffffc0200bc8:	6614                	ld	a3,8(a2)
ffffffffc0200bca:	01870593          	addi	a1,a4,24
ffffffffc0200bce:	0107a803          	lw	a6,16(a5)
ffffffffc0200bd2:	e28c                	sd	a1,0(a3)
ffffffffc0200bd4:	e60c                	sd	a1,8(a2)
ffffffffc0200bd6:	f314                	sd	a3,32(a4)
ffffffffc0200bd8:	ef10                	sd	a2,24(a4)
ffffffffc0200bda:	4118083b          	subw	a6,a6,a7
ffffffffc0200bde:	00006797          	auipc	a5,0x6
ffffffffc0200be2:	8907a123          	sw	a6,-1918(a5) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200be6:	57f5                	li	a5,-3
ffffffffc0200be8:	00850713          	addi	a4,a0,8
ffffffffc0200bec:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200bf0:	8082                	ret
ffffffffc0200bf2:	4501                	li	a0,0
ffffffffc0200bf4:	8082                	ret
ffffffffc0200bf6:	1141                	addi	sp,sp,-16
ffffffffc0200bf8:	00002697          	auipc	a3,0x2
ffffffffc0200bfc:	88068693          	addi	a3,a3,-1920 # ffffffffc0202478 <commands+0x7c0>
ffffffffc0200c00:	00002617          	auipc	a2,0x2
ffffffffc0200c04:	88060613          	addi	a2,a2,-1920 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200c08:	06d00593          	li	a1,109
ffffffffc0200c0c:	00002517          	auipc	a0,0x2
ffffffffc0200c10:	88c50513          	addi	a0,a0,-1908 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200c14:	e406                	sd	ra,8(sp)
ffffffffc0200c16:	d26ff0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0200c1a <best_fit_check>:
ffffffffc0200c1a:	715d                	addi	sp,sp,-80
ffffffffc0200c1c:	f84a                	sd	s2,48(sp)
ffffffffc0200c1e:	00006917          	auipc	s2,0x6
ffffffffc0200c22:	83290913          	addi	s2,s2,-1998 # ffffffffc0206450 <free_area>
ffffffffc0200c26:	00893783          	ld	a5,8(s2)
ffffffffc0200c2a:	e486                	sd	ra,72(sp)
ffffffffc0200c2c:	e0a2                	sd	s0,64(sp)
ffffffffc0200c2e:	fc26                	sd	s1,56(sp)
ffffffffc0200c30:	f44e                	sd	s3,40(sp)
ffffffffc0200c32:	f052                	sd	s4,32(sp)
ffffffffc0200c34:	ec56                	sd	s5,24(sp)
ffffffffc0200c36:	e85a                	sd	s6,16(sp)
ffffffffc0200c38:	e45e                	sd	s7,8(sp)
ffffffffc0200c3a:	e062                	sd	s8,0(sp)
ffffffffc0200c3c:	2d278363          	beq	a5,s2,ffffffffc0200f02 <best_fit_check+0x2e8>
ffffffffc0200c40:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c44:	8305                	srli	a4,a4,0x1
ffffffffc0200c46:	8b05                	andi	a4,a4,1
ffffffffc0200c48:	2c070163          	beqz	a4,ffffffffc0200f0a <best_fit_check+0x2f0>
ffffffffc0200c4c:	4401                	li	s0,0
ffffffffc0200c4e:	4481                	li	s1,0
ffffffffc0200c50:	a031                	j	ffffffffc0200c5c <best_fit_check+0x42>
ffffffffc0200c52:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c56:	8b09                	andi	a4,a4,2
ffffffffc0200c58:	2a070963          	beqz	a4,ffffffffc0200f0a <best_fit_check+0x2f0>
ffffffffc0200c5c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c60:	679c                	ld	a5,8(a5)
ffffffffc0200c62:	2485                	addiw	s1,s1,1
ffffffffc0200c64:	9c39                	addw	s0,s0,a4
ffffffffc0200c66:	ff2796e3          	bne	a5,s2,ffffffffc0200c52 <best_fit_check+0x38>
ffffffffc0200c6a:	89a2                	mv	s3,s0
ffffffffc0200c6c:	cdbff0ef          	jal	ra,ffffffffc0200946 <nr_free_pages>
ffffffffc0200c70:	37351d63          	bne	a0,s3,ffffffffc0200fea <best_fit_check+0x3d0>
ffffffffc0200c74:	4505                	li	a0,1
ffffffffc0200c76:	c49ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200c7a:	8a2a                	mv	s4,a0
ffffffffc0200c7c:	3a050763          	beqz	a0,ffffffffc020102a <best_fit_check+0x410>
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	c3dff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200c86:	89aa                	mv	s3,a0
ffffffffc0200c88:	38050163          	beqz	a0,ffffffffc020100a <best_fit_check+0x3f0>
ffffffffc0200c8c:	4505                	li	a0,1
ffffffffc0200c8e:	c31ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200c92:	8aaa                	mv	s5,a0
ffffffffc0200c94:	30050b63          	beqz	a0,ffffffffc0200faa <best_fit_check+0x390>
ffffffffc0200c98:	293a0963          	beq	s4,s3,ffffffffc0200f2a <best_fit_check+0x310>
ffffffffc0200c9c:	28aa0763          	beq	s4,a0,ffffffffc0200f2a <best_fit_check+0x310>
ffffffffc0200ca0:	28a98563          	beq	s3,a0,ffffffffc0200f2a <best_fit_check+0x310>
ffffffffc0200ca4:	000a2783          	lw	a5,0(s4)
ffffffffc0200ca8:	2a079163          	bnez	a5,ffffffffc0200f4a <best_fit_check+0x330>
ffffffffc0200cac:	0009a783          	lw	a5,0(s3)
ffffffffc0200cb0:	28079d63          	bnez	a5,ffffffffc0200f4a <best_fit_check+0x330>
ffffffffc0200cb4:	411c                	lw	a5,0(a0)
ffffffffc0200cb6:	28079a63          	bnez	a5,ffffffffc0200f4a <best_fit_check+0x330>
ffffffffc0200cba:	00006797          	auipc	a5,0x6
ffffffffc0200cbe:	8b678793          	addi	a5,a5,-1866 # ffffffffc0206570 <pages>
ffffffffc0200cc2:	639c                	ld	a5,0(a5)
ffffffffc0200cc4:	00001717          	auipc	a4,0x1
ffffffffc0200cc8:	7ec70713          	addi	a4,a4,2028 # ffffffffc02024b0 <commands+0x7f8>
ffffffffc0200ccc:	630c                	ld	a1,0(a4)
ffffffffc0200cce:	40fa0733          	sub	a4,s4,a5
ffffffffc0200cd2:	870d                	srai	a4,a4,0x3
ffffffffc0200cd4:	02b70733          	mul	a4,a4,a1
ffffffffc0200cd8:	00002697          	auipc	a3,0x2
ffffffffc0200cdc:	d7068693          	addi	a3,a3,-656 # ffffffffc0202a48 <nbase>
ffffffffc0200ce0:	6290                	ld	a2,0(a3)
ffffffffc0200ce2:	00005697          	auipc	a3,0x5
ffffffffc0200ce6:	74e68693          	addi	a3,a3,1870 # ffffffffc0206430 <npage>
ffffffffc0200cea:	6294                	ld	a3,0(a3)
ffffffffc0200cec:	06b2                	slli	a3,a3,0xc
ffffffffc0200cee:	9732                	add	a4,a4,a2
ffffffffc0200cf0:	0732                	slli	a4,a4,0xc
ffffffffc0200cf2:	26d77c63          	bgeu	a4,a3,ffffffffc0200f6a <best_fit_check+0x350>
ffffffffc0200cf6:	40f98733          	sub	a4,s3,a5
ffffffffc0200cfa:	870d                	srai	a4,a4,0x3
ffffffffc0200cfc:	02b70733          	mul	a4,a4,a1
ffffffffc0200d00:	9732                	add	a4,a4,a2
ffffffffc0200d02:	0732                	slli	a4,a4,0xc
ffffffffc0200d04:	42d77363          	bgeu	a4,a3,ffffffffc020112a <best_fit_check+0x510>
ffffffffc0200d08:	40f507b3          	sub	a5,a0,a5
ffffffffc0200d0c:	878d                	srai	a5,a5,0x3
ffffffffc0200d0e:	02b787b3          	mul	a5,a5,a1
ffffffffc0200d12:	97b2                	add	a5,a5,a2
ffffffffc0200d14:	07b2                	slli	a5,a5,0xc
ffffffffc0200d16:	3ed7fa63          	bgeu	a5,a3,ffffffffc020110a <best_fit_check+0x4f0>
ffffffffc0200d1a:	4505                	li	a0,1
ffffffffc0200d1c:	00093c03          	ld	s8,0(s2)
ffffffffc0200d20:	00893b83          	ld	s7,8(s2)
ffffffffc0200d24:	01092b03          	lw	s6,16(s2)
ffffffffc0200d28:	00005797          	auipc	a5,0x5
ffffffffc0200d2c:	7327b823          	sd	s2,1840(a5) # ffffffffc0206458 <free_area+0x8>
ffffffffc0200d30:	00005797          	auipc	a5,0x5
ffffffffc0200d34:	7327b023          	sd	s2,1824(a5) # ffffffffc0206450 <free_area>
ffffffffc0200d38:	00005797          	auipc	a5,0x5
ffffffffc0200d3c:	7207a423          	sw	zero,1832(a5) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200d40:	b7fff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200d44:	3a051363          	bnez	a0,ffffffffc02010ea <best_fit_check+0x4d0>
ffffffffc0200d48:	4585                	li	a1,1
ffffffffc0200d4a:	8552                	mv	a0,s4
ffffffffc0200d4c:	bb7ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200d50:	4585                	li	a1,1
ffffffffc0200d52:	854e                	mv	a0,s3
ffffffffc0200d54:	bafff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200d58:	4585                	li	a1,1
ffffffffc0200d5a:	8556                	mv	a0,s5
ffffffffc0200d5c:	ba7ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200d60:	01092703          	lw	a4,16(s2)
ffffffffc0200d64:	478d                	li	a5,3
ffffffffc0200d66:	36f71263          	bne	a4,a5,ffffffffc02010ca <best_fit_check+0x4b0>
ffffffffc0200d6a:	4505                	li	a0,1
ffffffffc0200d6c:	b53ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200d70:	89aa                	mv	s3,a0
ffffffffc0200d72:	32050c63          	beqz	a0,ffffffffc02010aa <best_fit_check+0x490>
ffffffffc0200d76:	4505                	li	a0,1
ffffffffc0200d78:	b47ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200d7c:	8aaa                	mv	s5,a0
ffffffffc0200d7e:	30050663          	beqz	a0,ffffffffc020108a <best_fit_check+0x470>
ffffffffc0200d82:	4505                	li	a0,1
ffffffffc0200d84:	b3bff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200d88:	8a2a                	mv	s4,a0
ffffffffc0200d8a:	2e050063          	beqz	a0,ffffffffc020106a <best_fit_check+0x450>
ffffffffc0200d8e:	4505                	li	a0,1
ffffffffc0200d90:	b2fff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200d94:	2a051b63          	bnez	a0,ffffffffc020104a <best_fit_check+0x430>
ffffffffc0200d98:	4585                	li	a1,1
ffffffffc0200d9a:	854e                	mv	a0,s3
ffffffffc0200d9c:	b67ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200da0:	00893783          	ld	a5,8(s2)
ffffffffc0200da4:	1f278363          	beq	a5,s2,ffffffffc0200f8a <best_fit_check+0x370>
ffffffffc0200da8:	4505                	li	a0,1
ffffffffc0200daa:	b15ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200dae:	54a99e63          	bne	s3,a0,ffffffffc020130a <best_fit_check+0x6f0>
ffffffffc0200db2:	4505                	li	a0,1
ffffffffc0200db4:	b0bff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200db8:	52051963          	bnez	a0,ffffffffc02012ea <best_fit_check+0x6d0>
ffffffffc0200dbc:	01092783          	lw	a5,16(s2)
ffffffffc0200dc0:	50079563          	bnez	a5,ffffffffc02012ca <best_fit_check+0x6b0>
ffffffffc0200dc4:	854e                	mv	a0,s3
ffffffffc0200dc6:	4585                	li	a1,1
ffffffffc0200dc8:	00005797          	auipc	a5,0x5
ffffffffc0200dcc:	6987b423          	sd	s8,1672(a5) # ffffffffc0206450 <free_area>
ffffffffc0200dd0:	00005797          	auipc	a5,0x5
ffffffffc0200dd4:	6977b423          	sd	s7,1672(a5) # ffffffffc0206458 <free_area+0x8>
ffffffffc0200dd8:	00005797          	auipc	a5,0x5
ffffffffc0200ddc:	6967a423          	sw	s6,1672(a5) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200de0:	b23ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200de4:	4585                	li	a1,1
ffffffffc0200de6:	8556                	mv	a0,s5
ffffffffc0200de8:	b1bff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200dec:	4585                	li	a1,1
ffffffffc0200dee:	8552                	mv	a0,s4
ffffffffc0200df0:	b13ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200df4:	4515                	li	a0,5
ffffffffc0200df6:	ac9ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200dfa:	89aa                	mv	s3,a0
ffffffffc0200dfc:	4a050763          	beqz	a0,ffffffffc02012aa <best_fit_check+0x690>
ffffffffc0200e00:	651c                	ld	a5,8(a0)
ffffffffc0200e02:	8385                	srli	a5,a5,0x1
ffffffffc0200e04:	8b85                	andi	a5,a5,1
ffffffffc0200e06:	48079263          	bnez	a5,ffffffffc020128a <best_fit_check+0x670>
ffffffffc0200e0a:	4505                	li	a0,1
ffffffffc0200e0c:	00093b03          	ld	s6,0(s2)
ffffffffc0200e10:	00893a83          	ld	s5,8(s2)
ffffffffc0200e14:	00005797          	auipc	a5,0x5
ffffffffc0200e18:	6327be23          	sd	s2,1596(a5) # ffffffffc0206450 <free_area>
ffffffffc0200e1c:	00005797          	auipc	a5,0x5
ffffffffc0200e20:	6327be23          	sd	s2,1596(a5) # ffffffffc0206458 <free_area+0x8>
ffffffffc0200e24:	a9bff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200e28:	44051163          	bnez	a0,ffffffffc020126a <best_fit_check+0x650>
ffffffffc0200e2c:	4589                	li	a1,2
ffffffffc0200e2e:	02898513          	addi	a0,s3,40
ffffffffc0200e32:	01092b83          	lw	s7,16(s2)
ffffffffc0200e36:	0a098c13          	addi	s8,s3,160
ffffffffc0200e3a:	00005797          	auipc	a5,0x5
ffffffffc0200e3e:	6207a323          	sw	zero,1574(a5) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200e42:	ac1ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200e46:	8562                	mv	a0,s8
ffffffffc0200e48:	4585                	li	a1,1
ffffffffc0200e4a:	ab9ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200e4e:	4511                	li	a0,4
ffffffffc0200e50:	a6fff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200e54:	3e051b63          	bnez	a0,ffffffffc020124a <best_fit_check+0x630>
ffffffffc0200e58:	0309b783          	ld	a5,48(s3)
ffffffffc0200e5c:	8385                	srli	a5,a5,0x1
ffffffffc0200e5e:	8b85                	andi	a5,a5,1
ffffffffc0200e60:	3c078563          	beqz	a5,ffffffffc020122a <best_fit_check+0x610>
ffffffffc0200e64:	0389a703          	lw	a4,56(s3)
ffffffffc0200e68:	4789                	li	a5,2
ffffffffc0200e6a:	3cf71063          	bne	a4,a5,ffffffffc020122a <best_fit_check+0x610>
ffffffffc0200e6e:	4505                	li	a0,1
ffffffffc0200e70:	a4fff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200e74:	8a2a                	mv	s4,a0
ffffffffc0200e76:	38050a63          	beqz	a0,ffffffffc020120a <best_fit_check+0x5f0>
ffffffffc0200e7a:	4509                	li	a0,2
ffffffffc0200e7c:	a43ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200e80:	36050563          	beqz	a0,ffffffffc02011ea <best_fit_check+0x5d0>
ffffffffc0200e84:	354c1363          	bne	s8,s4,ffffffffc02011ca <best_fit_check+0x5b0>
ffffffffc0200e88:	854e                	mv	a0,s3
ffffffffc0200e8a:	4595                	li	a1,5
ffffffffc0200e8c:	a77ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200e90:	4515                	li	a0,5
ffffffffc0200e92:	a2dff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200e96:	89aa                	mv	s3,a0
ffffffffc0200e98:	30050963          	beqz	a0,ffffffffc02011aa <best_fit_check+0x590>
ffffffffc0200e9c:	4505                	li	a0,1
ffffffffc0200e9e:	a21ff0ef          	jal	ra,ffffffffc02008be <alloc_pages>
ffffffffc0200ea2:	2e051463          	bnez	a0,ffffffffc020118a <best_fit_check+0x570>
ffffffffc0200ea6:	01092783          	lw	a5,16(s2)
ffffffffc0200eaa:	2c079063          	bnez	a5,ffffffffc020116a <best_fit_check+0x550>
ffffffffc0200eae:	4595                	li	a1,5
ffffffffc0200eb0:	854e                	mv	a0,s3
ffffffffc0200eb2:	00005797          	auipc	a5,0x5
ffffffffc0200eb6:	5b77a723          	sw	s7,1454(a5) # ffffffffc0206460 <free_area+0x10>
ffffffffc0200eba:	00005797          	auipc	a5,0x5
ffffffffc0200ebe:	5967bb23          	sd	s6,1430(a5) # ffffffffc0206450 <free_area>
ffffffffc0200ec2:	00005797          	auipc	a5,0x5
ffffffffc0200ec6:	5957bb23          	sd	s5,1430(a5) # ffffffffc0206458 <free_area+0x8>
ffffffffc0200eca:	a39ff0ef          	jal	ra,ffffffffc0200902 <free_pages>
ffffffffc0200ece:	00893783          	ld	a5,8(s2)
ffffffffc0200ed2:	01278963          	beq	a5,s2,ffffffffc0200ee4 <best_fit_check+0x2ca>
ffffffffc0200ed6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200eda:	679c                	ld	a5,8(a5)
ffffffffc0200edc:	34fd                	addiw	s1,s1,-1
ffffffffc0200ede:	9c19                	subw	s0,s0,a4
ffffffffc0200ee0:	ff279be3          	bne	a5,s2,ffffffffc0200ed6 <best_fit_check+0x2bc>
ffffffffc0200ee4:	26049363          	bnez	s1,ffffffffc020114a <best_fit_check+0x530>
ffffffffc0200ee8:	e06d                	bnez	s0,ffffffffc0200fca <best_fit_check+0x3b0>
ffffffffc0200eea:	60a6                	ld	ra,72(sp)
ffffffffc0200eec:	6406                	ld	s0,64(sp)
ffffffffc0200eee:	74e2                	ld	s1,56(sp)
ffffffffc0200ef0:	7942                	ld	s2,48(sp)
ffffffffc0200ef2:	79a2                	ld	s3,40(sp)
ffffffffc0200ef4:	7a02                	ld	s4,32(sp)
ffffffffc0200ef6:	6ae2                	ld	s5,24(sp)
ffffffffc0200ef8:	6b42                	ld	s6,16(sp)
ffffffffc0200efa:	6ba2                	ld	s7,8(sp)
ffffffffc0200efc:	6c02                	ld	s8,0(sp)
ffffffffc0200efe:	6161                	addi	sp,sp,80
ffffffffc0200f00:	8082                	ret
ffffffffc0200f02:	4981                	li	s3,0
ffffffffc0200f04:	4401                	li	s0,0
ffffffffc0200f06:	4481                	li	s1,0
ffffffffc0200f08:	b395                	j	ffffffffc0200c6c <best_fit_check+0x52>
ffffffffc0200f0a:	00001697          	auipc	a3,0x1
ffffffffc0200f0e:	5ae68693          	addi	a3,a3,1454 # ffffffffc02024b8 <commands+0x800>
ffffffffc0200f12:	00001617          	auipc	a2,0x1
ffffffffc0200f16:	56e60613          	addi	a2,a2,1390 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200f1a:	10f00593          	li	a1,271
ffffffffc0200f1e:	00001517          	auipc	a0,0x1
ffffffffc0200f22:	57a50513          	addi	a0,a0,1402 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200f26:	a16ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200f2a:	00001697          	auipc	a3,0x1
ffffffffc0200f2e:	61e68693          	addi	a3,a3,1566 # ffffffffc0202548 <commands+0x890>
ffffffffc0200f32:	00001617          	auipc	a2,0x1
ffffffffc0200f36:	54e60613          	addi	a2,a2,1358 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200f3a:	0db00593          	li	a1,219
ffffffffc0200f3e:	00001517          	auipc	a0,0x1
ffffffffc0200f42:	55a50513          	addi	a0,a0,1370 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200f46:	9f6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200f4a:	00001697          	auipc	a3,0x1
ffffffffc0200f4e:	62668693          	addi	a3,a3,1574 # ffffffffc0202570 <commands+0x8b8>
ffffffffc0200f52:	00001617          	auipc	a2,0x1
ffffffffc0200f56:	52e60613          	addi	a2,a2,1326 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200f5a:	0dc00593          	li	a1,220
ffffffffc0200f5e:	00001517          	auipc	a0,0x1
ffffffffc0200f62:	53a50513          	addi	a0,a0,1338 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200f66:	9d6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200f6a:	00001697          	auipc	a3,0x1
ffffffffc0200f6e:	64668693          	addi	a3,a3,1606 # ffffffffc02025b0 <commands+0x8f8>
ffffffffc0200f72:	00001617          	auipc	a2,0x1
ffffffffc0200f76:	50e60613          	addi	a2,a2,1294 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200f7a:	0de00593          	li	a1,222
ffffffffc0200f7e:	00001517          	auipc	a0,0x1
ffffffffc0200f82:	51a50513          	addi	a0,a0,1306 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200f86:	9b6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200f8a:	00001697          	auipc	a3,0x1
ffffffffc0200f8e:	6ae68693          	addi	a3,a3,1710 # ffffffffc0202638 <commands+0x980>
ffffffffc0200f92:	00001617          	auipc	a2,0x1
ffffffffc0200f96:	4ee60613          	addi	a2,a2,1262 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200f9a:	0f700593          	li	a1,247
ffffffffc0200f9e:	00001517          	auipc	a0,0x1
ffffffffc0200fa2:	4fa50513          	addi	a0,a0,1274 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200fa6:	996ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200faa:	00001697          	auipc	a3,0x1
ffffffffc0200fae:	57e68693          	addi	a3,a3,1406 # ffffffffc0202528 <commands+0x870>
ffffffffc0200fb2:	00001617          	auipc	a2,0x1
ffffffffc0200fb6:	4ce60613          	addi	a2,a2,1230 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200fba:	0d900593          	li	a1,217
ffffffffc0200fbe:	00001517          	auipc	a0,0x1
ffffffffc0200fc2:	4da50513          	addi	a0,a0,1242 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200fc6:	976ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200fca:	00001697          	auipc	a3,0x1
ffffffffc0200fce:	79e68693          	addi	a3,a3,1950 # ffffffffc0202768 <commands+0xab0>
ffffffffc0200fd2:	00001617          	auipc	a2,0x1
ffffffffc0200fd6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200fda:	15100593          	li	a1,337
ffffffffc0200fde:	00001517          	auipc	a0,0x1
ffffffffc0200fe2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0200fe6:	956ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc0200fea:	00001697          	auipc	a3,0x1
ffffffffc0200fee:	4de68693          	addi	a3,a3,1246 # ffffffffc02024c8 <commands+0x810>
ffffffffc0200ff2:	00001617          	auipc	a2,0x1
ffffffffc0200ff6:	48e60613          	addi	a2,a2,1166 # ffffffffc0202480 <commands+0x7c8>
ffffffffc0200ffa:	11200593          	li	a1,274
ffffffffc0200ffe:	00001517          	auipc	a0,0x1
ffffffffc0201002:	49a50513          	addi	a0,a0,1178 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201006:	936ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020100a:	00001697          	auipc	a3,0x1
ffffffffc020100e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0202508 <commands+0x850>
ffffffffc0201012:	00001617          	auipc	a2,0x1
ffffffffc0201016:	46e60613          	addi	a2,a2,1134 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020101a:	0d800593          	li	a1,216
ffffffffc020101e:	00001517          	auipc	a0,0x1
ffffffffc0201022:	47a50513          	addi	a0,a0,1146 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201026:	916ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020102a:	00001697          	auipc	a3,0x1
ffffffffc020102e:	4be68693          	addi	a3,a3,1214 # ffffffffc02024e8 <commands+0x830>
ffffffffc0201032:	00001617          	auipc	a2,0x1
ffffffffc0201036:	44e60613          	addi	a2,a2,1102 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020103a:	0d700593          	li	a1,215
ffffffffc020103e:	00001517          	auipc	a0,0x1
ffffffffc0201042:	45a50513          	addi	a0,a0,1114 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201046:	8f6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020104a:	00001697          	auipc	a3,0x1
ffffffffc020104e:	5c668693          	addi	a3,a3,1478 # ffffffffc0202610 <commands+0x958>
ffffffffc0201052:	00001617          	auipc	a2,0x1
ffffffffc0201056:	42e60613          	addi	a2,a2,1070 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020105a:	0f400593          	li	a1,244
ffffffffc020105e:	00001517          	auipc	a0,0x1
ffffffffc0201062:	43a50513          	addi	a0,a0,1082 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201066:	8d6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020106a:	00001697          	auipc	a3,0x1
ffffffffc020106e:	4be68693          	addi	a3,a3,1214 # ffffffffc0202528 <commands+0x870>
ffffffffc0201072:	00001617          	auipc	a2,0x1
ffffffffc0201076:	40e60613          	addi	a2,a2,1038 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020107a:	0f200593          	li	a1,242
ffffffffc020107e:	00001517          	auipc	a0,0x1
ffffffffc0201082:	41a50513          	addi	a0,a0,1050 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201086:	8b6ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020108a:	00001697          	auipc	a3,0x1
ffffffffc020108e:	47e68693          	addi	a3,a3,1150 # ffffffffc0202508 <commands+0x850>
ffffffffc0201092:	00001617          	auipc	a2,0x1
ffffffffc0201096:	3ee60613          	addi	a2,a2,1006 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020109a:	0f100593          	li	a1,241
ffffffffc020109e:	00001517          	auipc	a0,0x1
ffffffffc02010a2:	3fa50513          	addi	a0,a0,1018 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02010a6:	896ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02010aa:	00001697          	auipc	a3,0x1
ffffffffc02010ae:	43e68693          	addi	a3,a3,1086 # ffffffffc02024e8 <commands+0x830>
ffffffffc02010b2:	00001617          	auipc	a2,0x1
ffffffffc02010b6:	3ce60613          	addi	a2,a2,974 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02010ba:	0f000593          	li	a1,240
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	3da50513          	addi	a0,a0,986 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02010c6:	876ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02010ca:	00001697          	auipc	a3,0x1
ffffffffc02010ce:	55e68693          	addi	a3,a3,1374 # ffffffffc0202628 <commands+0x970>
ffffffffc02010d2:	00001617          	auipc	a2,0x1
ffffffffc02010d6:	3ae60613          	addi	a2,a2,942 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02010da:	0ee00593          	li	a1,238
ffffffffc02010de:	00001517          	auipc	a0,0x1
ffffffffc02010e2:	3ba50513          	addi	a0,a0,954 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02010e6:	856ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02010ea:	00001697          	auipc	a3,0x1
ffffffffc02010ee:	52668693          	addi	a3,a3,1318 # ffffffffc0202610 <commands+0x958>
ffffffffc02010f2:	00001617          	auipc	a2,0x1
ffffffffc02010f6:	38e60613          	addi	a2,a2,910 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02010fa:	0e900593          	li	a1,233
ffffffffc02010fe:	00001517          	auipc	a0,0x1
ffffffffc0201102:	39a50513          	addi	a0,a0,922 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201106:	836ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020110a:	00001697          	auipc	a3,0x1
ffffffffc020110e:	4e668693          	addi	a3,a3,1254 # ffffffffc02025f0 <commands+0x938>
ffffffffc0201112:	00001617          	auipc	a2,0x1
ffffffffc0201116:	36e60613          	addi	a2,a2,878 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020111a:	0e000593          	li	a1,224
ffffffffc020111e:	00001517          	auipc	a0,0x1
ffffffffc0201122:	37a50513          	addi	a0,a0,890 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201126:	816ff0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020112a:	00001697          	auipc	a3,0x1
ffffffffc020112e:	4a668693          	addi	a3,a3,1190 # ffffffffc02025d0 <commands+0x918>
ffffffffc0201132:	00001617          	auipc	a2,0x1
ffffffffc0201136:	34e60613          	addi	a2,a2,846 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020113a:	0df00593          	li	a1,223
ffffffffc020113e:	00001517          	auipc	a0,0x1
ffffffffc0201142:	35a50513          	addi	a0,a0,858 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201146:	ff7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020114a:	00001697          	auipc	a3,0x1
ffffffffc020114e:	60e68693          	addi	a3,a3,1550 # ffffffffc0202758 <commands+0xaa0>
ffffffffc0201152:	00001617          	auipc	a2,0x1
ffffffffc0201156:	32e60613          	addi	a2,a2,814 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020115a:	15000593          	li	a1,336
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	33a50513          	addi	a0,a0,826 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201166:	fd7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020116a:	00001697          	auipc	a3,0x1
ffffffffc020116e:	50668693          	addi	a3,a3,1286 # ffffffffc0202670 <commands+0x9b8>
ffffffffc0201172:	00001617          	auipc	a2,0x1
ffffffffc0201176:	30e60613          	addi	a2,a2,782 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020117a:	14500593          	li	a1,325
ffffffffc020117e:	00001517          	auipc	a0,0x1
ffffffffc0201182:	31a50513          	addi	a0,a0,794 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201186:	fb7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020118a:	00001697          	auipc	a3,0x1
ffffffffc020118e:	48668693          	addi	a3,a3,1158 # ffffffffc0202610 <commands+0x958>
ffffffffc0201192:	00001617          	auipc	a2,0x1
ffffffffc0201196:	2ee60613          	addi	a2,a2,750 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020119a:	13f00593          	li	a1,319
ffffffffc020119e:	00001517          	auipc	a0,0x1
ffffffffc02011a2:	2fa50513          	addi	a0,a0,762 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02011a6:	f97fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02011aa:	00001697          	auipc	a3,0x1
ffffffffc02011ae:	58e68693          	addi	a3,a3,1422 # ffffffffc0202738 <commands+0xa80>
ffffffffc02011b2:	00001617          	auipc	a2,0x1
ffffffffc02011b6:	2ce60613          	addi	a2,a2,718 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02011ba:	13e00593          	li	a1,318
ffffffffc02011be:	00001517          	auipc	a0,0x1
ffffffffc02011c2:	2da50513          	addi	a0,a0,730 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02011c6:	f77fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02011ca:	00001697          	auipc	a3,0x1
ffffffffc02011ce:	55e68693          	addi	a3,a3,1374 # ffffffffc0202728 <commands+0xa70>
ffffffffc02011d2:	00001617          	auipc	a2,0x1
ffffffffc02011d6:	2ae60613          	addi	a2,a2,686 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02011da:	13600593          	li	a1,310
ffffffffc02011de:	00001517          	auipc	a0,0x1
ffffffffc02011e2:	2ba50513          	addi	a0,a0,698 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02011e6:	f57fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02011ea:	00001697          	auipc	a3,0x1
ffffffffc02011ee:	52668693          	addi	a3,a3,1318 # ffffffffc0202710 <commands+0xa58>
ffffffffc02011f2:	00001617          	auipc	a2,0x1
ffffffffc02011f6:	28e60613          	addi	a2,a2,654 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02011fa:	13500593          	li	a1,309
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	29a50513          	addi	a0,a0,666 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201206:	f37fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020120a:	00001697          	auipc	a3,0x1
ffffffffc020120e:	4e668693          	addi	a3,a3,1254 # ffffffffc02026f0 <commands+0xa38>
ffffffffc0201212:	00001617          	auipc	a2,0x1
ffffffffc0201216:	26e60613          	addi	a2,a2,622 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020121a:	13400593          	li	a1,308
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	27a50513          	addi	a0,a0,634 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201226:	f17fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020122a:	00001697          	auipc	a3,0x1
ffffffffc020122e:	49668693          	addi	a3,a3,1174 # ffffffffc02026c0 <commands+0xa08>
ffffffffc0201232:	00001617          	auipc	a2,0x1
ffffffffc0201236:	24e60613          	addi	a2,a2,590 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020123a:	13200593          	li	a1,306
ffffffffc020123e:	00001517          	auipc	a0,0x1
ffffffffc0201242:	25a50513          	addi	a0,a0,602 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201246:	ef7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020124a:	00001697          	auipc	a3,0x1
ffffffffc020124e:	45e68693          	addi	a3,a3,1118 # ffffffffc02026a8 <commands+0x9f0>
ffffffffc0201252:	00001617          	auipc	a2,0x1
ffffffffc0201256:	22e60613          	addi	a2,a2,558 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020125a:	13100593          	li	a1,305
ffffffffc020125e:	00001517          	auipc	a0,0x1
ffffffffc0201262:	23a50513          	addi	a0,a0,570 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201266:	ed7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020126a:	00001697          	auipc	a3,0x1
ffffffffc020126e:	3a668693          	addi	a3,a3,934 # ffffffffc0202610 <commands+0x958>
ffffffffc0201272:	00001617          	auipc	a2,0x1
ffffffffc0201276:	20e60613          	addi	a2,a2,526 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020127a:	12500593          	li	a1,293
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	21a50513          	addi	a0,a0,538 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201286:	eb7fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020128a:	00001697          	auipc	a3,0x1
ffffffffc020128e:	40668693          	addi	a3,a3,1030 # ffffffffc0202690 <commands+0x9d8>
ffffffffc0201292:	00001617          	auipc	a2,0x1
ffffffffc0201296:	1ee60613          	addi	a2,a2,494 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020129a:	11c00593          	li	a1,284
ffffffffc020129e:	00001517          	auipc	a0,0x1
ffffffffc02012a2:	1fa50513          	addi	a0,a0,506 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02012a6:	e97fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02012aa:	00001697          	auipc	a3,0x1
ffffffffc02012ae:	3d668693          	addi	a3,a3,982 # ffffffffc0202680 <commands+0x9c8>
ffffffffc02012b2:	00001617          	auipc	a2,0x1
ffffffffc02012b6:	1ce60613          	addi	a2,a2,462 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02012ba:	11b00593          	li	a1,283
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	1da50513          	addi	a0,a0,474 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02012c6:	e77fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02012ca:	00001697          	auipc	a3,0x1
ffffffffc02012ce:	3a668693          	addi	a3,a3,934 # ffffffffc0202670 <commands+0x9b8>
ffffffffc02012d2:	00001617          	auipc	a2,0x1
ffffffffc02012d6:	1ae60613          	addi	a2,a2,430 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02012da:	0fd00593          	li	a1,253
ffffffffc02012de:	00001517          	auipc	a0,0x1
ffffffffc02012e2:	1ba50513          	addi	a0,a0,442 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02012e6:	e57fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02012ea:	00001697          	auipc	a3,0x1
ffffffffc02012ee:	32668693          	addi	a3,a3,806 # ffffffffc0202610 <commands+0x958>
ffffffffc02012f2:	00001617          	auipc	a2,0x1
ffffffffc02012f6:	18e60613          	addi	a2,a2,398 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02012fa:	0fb00593          	li	a1,251
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	19a50513          	addi	a0,a0,410 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201306:	e37fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc020130a:	00001697          	auipc	a3,0x1
ffffffffc020130e:	34668693          	addi	a3,a3,838 # ffffffffc0202650 <commands+0x998>
ffffffffc0201312:	00001617          	auipc	a2,0x1
ffffffffc0201316:	16e60613          	addi	a2,a2,366 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020131a:	0fa00593          	li	a1,250
ffffffffc020131e:	00001517          	auipc	a0,0x1
ffffffffc0201322:	17a50513          	addi	a0,a0,378 # ffffffffc0202498 <commands+0x7e0>
ffffffffc0201326:	e17fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc020132a <best_fit_free_pages>:
ffffffffc020132a:	1141                	addi	sp,sp,-16
ffffffffc020132c:	e406                	sd	ra,8(sp)
ffffffffc020132e:	18058063          	beqz	a1,ffffffffc02014ae <best_fit_free_pages+0x184>
ffffffffc0201332:	00259693          	slli	a3,a1,0x2
ffffffffc0201336:	96ae                	add	a3,a3,a1
ffffffffc0201338:	068e                	slli	a3,a3,0x3
ffffffffc020133a:	96aa                	add	a3,a3,a0
ffffffffc020133c:	02d50d63          	beq	a0,a3,ffffffffc0201376 <best_fit_free_pages+0x4c>
ffffffffc0201340:	651c                	ld	a5,8(a0)
ffffffffc0201342:	8b85                	andi	a5,a5,1
ffffffffc0201344:	14079563          	bnez	a5,ffffffffc020148e <best_fit_free_pages+0x164>
ffffffffc0201348:	651c                	ld	a5,8(a0)
ffffffffc020134a:	8385                	srli	a5,a5,0x1
ffffffffc020134c:	8b85                	andi	a5,a5,1
ffffffffc020134e:	14079063          	bnez	a5,ffffffffc020148e <best_fit_free_pages+0x164>
ffffffffc0201352:	87aa                	mv	a5,a0
ffffffffc0201354:	a809                	j	ffffffffc0201366 <best_fit_free_pages+0x3c>
ffffffffc0201356:	6798                	ld	a4,8(a5)
ffffffffc0201358:	8b05                	andi	a4,a4,1
ffffffffc020135a:	12071a63          	bnez	a4,ffffffffc020148e <best_fit_free_pages+0x164>
ffffffffc020135e:	6798                	ld	a4,8(a5)
ffffffffc0201360:	8b09                	andi	a4,a4,2
ffffffffc0201362:	12071663          	bnez	a4,ffffffffc020148e <best_fit_free_pages+0x164>
ffffffffc0201366:	0007b423          	sd	zero,8(a5)
ffffffffc020136a:	0007a023          	sw	zero,0(a5)
ffffffffc020136e:	02878793          	addi	a5,a5,40
ffffffffc0201372:	fed792e3          	bne	a5,a3,ffffffffc0201356 <best_fit_free_pages+0x2c>
ffffffffc0201376:	2581                	sext.w	a1,a1
ffffffffc0201378:	c90c                	sw	a1,16(a0)
ffffffffc020137a:	00850893          	addi	a7,a0,8
ffffffffc020137e:	4789                	li	a5,2
ffffffffc0201380:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc0201384:	00005697          	auipc	a3,0x5
ffffffffc0201388:	0cc68693          	addi	a3,a3,204 # ffffffffc0206450 <free_area>
ffffffffc020138c:	4a98                	lw	a4,16(a3)
ffffffffc020138e:	669c                	ld	a5,8(a3)
ffffffffc0201390:	9db9                	addw	a1,a1,a4
ffffffffc0201392:	00005717          	auipc	a4,0x5
ffffffffc0201396:	0cb72723          	sw	a1,206(a4) # ffffffffc0206460 <free_area+0x10>
ffffffffc020139a:	08d78f63          	beq	a5,a3,ffffffffc0201438 <best_fit_free_pages+0x10e>
ffffffffc020139e:	fe878713          	addi	a4,a5,-24
ffffffffc02013a2:	628c                	ld	a1,0(a3)
ffffffffc02013a4:	4801                	li	a6,0
ffffffffc02013a6:	01850613          	addi	a2,a0,24
ffffffffc02013aa:	00e56a63          	bltu	a0,a4,ffffffffc02013be <best_fit_free_pages+0x94>
ffffffffc02013ae:	6798                	ld	a4,8(a5)
ffffffffc02013b0:	02d70563          	beq	a4,a3,ffffffffc02013da <best_fit_free_pages+0xb0>
ffffffffc02013b4:	87ba                	mv	a5,a4
ffffffffc02013b6:	fe878713          	addi	a4,a5,-24
ffffffffc02013ba:	fee57ae3          	bgeu	a0,a4,ffffffffc02013ae <best_fit_free_pages+0x84>
ffffffffc02013be:	00080663          	beqz	a6,ffffffffc02013ca <best_fit_free_pages+0xa0>
ffffffffc02013c2:	00005817          	auipc	a6,0x5
ffffffffc02013c6:	08b83723          	sd	a1,142(a6) # ffffffffc0206450 <free_area>
ffffffffc02013ca:	638c                	ld	a1,0(a5)
ffffffffc02013cc:	e390                	sd	a2,0(a5)
ffffffffc02013ce:	e590                	sd	a2,8(a1)
ffffffffc02013d0:	f11c                	sd	a5,32(a0)
ffffffffc02013d2:	ed0c                	sd	a1,24(a0)
ffffffffc02013d4:	02d59163          	bne	a1,a3,ffffffffc02013f6 <best_fit_free_pages+0xcc>
ffffffffc02013d8:	a091                	j	ffffffffc020141c <best_fit_free_pages+0xf2>
ffffffffc02013da:	e790                	sd	a2,8(a5)
ffffffffc02013dc:	f114                	sd	a3,32(a0)
ffffffffc02013de:	6798                	ld	a4,8(a5)
ffffffffc02013e0:	ed1c                	sd	a5,24(a0)
ffffffffc02013e2:	85b2                	mv	a1,a2
ffffffffc02013e4:	00d70563          	beq	a4,a3,ffffffffc02013ee <best_fit_free_pages+0xc4>
ffffffffc02013e8:	4805                	li	a6,1
ffffffffc02013ea:	87ba                	mv	a5,a4
ffffffffc02013ec:	b7e9                	j	ffffffffc02013b6 <best_fit_free_pages+0x8c>
ffffffffc02013ee:	e290                	sd	a2,0(a3)
ffffffffc02013f0:	85be                	mv	a1,a5
ffffffffc02013f2:	02d78163          	beq	a5,a3,ffffffffc0201414 <best_fit_free_pages+0xea>
ffffffffc02013f6:	ff85a803          	lw	a6,-8(a1)
ffffffffc02013fa:	fe858613          	addi	a2,a1,-24
ffffffffc02013fe:	02081713          	slli	a4,a6,0x20
ffffffffc0201402:	9301                	srli	a4,a4,0x20
ffffffffc0201404:	00271793          	slli	a5,a4,0x2
ffffffffc0201408:	97ba                	add	a5,a5,a4
ffffffffc020140a:	078e                	slli	a5,a5,0x3
ffffffffc020140c:	97b2                	add	a5,a5,a2
ffffffffc020140e:	02f50e63          	beq	a0,a5,ffffffffc020144a <best_fit_free_pages+0x120>
ffffffffc0201412:	711c                	ld	a5,32(a0)
ffffffffc0201414:	fe878713          	addi	a4,a5,-24
ffffffffc0201418:	00d78d63          	beq	a5,a3,ffffffffc0201432 <best_fit_free_pages+0x108>
ffffffffc020141c:	490c                	lw	a1,16(a0)
ffffffffc020141e:	02059613          	slli	a2,a1,0x20
ffffffffc0201422:	9201                	srli	a2,a2,0x20
ffffffffc0201424:	00261693          	slli	a3,a2,0x2
ffffffffc0201428:	96b2                	add	a3,a3,a2
ffffffffc020142a:	068e                	slli	a3,a3,0x3
ffffffffc020142c:	96aa                	add	a3,a3,a0
ffffffffc020142e:	04d70063          	beq	a4,a3,ffffffffc020146e <best_fit_free_pages+0x144>
ffffffffc0201432:	60a2                	ld	ra,8(sp)
ffffffffc0201434:	0141                	addi	sp,sp,16
ffffffffc0201436:	8082                	ret
ffffffffc0201438:	60a2                	ld	ra,8(sp)
ffffffffc020143a:	01850713          	addi	a4,a0,24
ffffffffc020143e:	e398                	sd	a4,0(a5)
ffffffffc0201440:	e798                	sd	a4,8(a5)
ffffffffc0201442:	f11c                	sd	a5,32(a0)
ffffffffc0201444:	ed1c                	sd	a5,24(a0)
ffffffffc0201446:	0141                	addi	sp,sp,16
ffffffffc0201448:	8082                	ret
ffffffffc020144a:	491c                	lw	a5,16(a0)
ffffffffc020144c:	0107883b          	addw	a6,a5,a6
ffffffffc0201450:	ff05ac23          	sw	a6,-8(a1)
ffffffffc0201454:	57f5                	li	a5,-3
ffffffffc0201456:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc020145a:	01853803          	ld	a6,24(a0)
ffffffffc020145e:	7118                	ld	a4,32(a0)
ffffffffc0201460:	8532                	mv	a0,a2
ffffffffc0201462:	00e83423          	sd	a4,8(a6)
ffffffffc0201466:	659c                	ld	a5,8(a1)
ffffffffc0201468:	01073023          	sd	a6,0(a4)
ffffffffc020146c:	b765                	j	ffffffffc0201414 <best_fit_free_pages+0xea>
ffffffffc020146e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201472:	ff078693          	addi	a3,a5,-16
ffffffffc0201476:	9db9                	addw	a1,a1,a4
ffffffffc0201478:	c90c                	sw	a1,16(a0)
ffffffffc020147a:	5775                	li	a4,-3
ffffffffc020147c:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0201480:	6398                	ld	a4,0(a5)
ffffffffc0201482:	679c                	ld	a5,8(a5)
ffffffffc0201484:	60a2                	ld	ra,8(sp)
ffffffffc0201486:	e71c                	sd	a5,8(a4)
ffffffffc0201488:	e398                	sd	a4,0(a5)
ffffffffc020148a:	0141                	addi	sp,sp,16
ffffffffc020148c:	8082                	ret
ffffffffc020148e:	00001697          	auipc	a3,0x1
ffffffffc0201492:	2ea68693          	addi	a3,a3,746 # ffffffffc0202778 <commands+0xac0>
ffffffffc0201496:	00001617          	auipc	a2,0x1
ffffffffc020149a:	fea60613          	addi	a2,a2,-22 # ffffffffc0202480 <commands+0x7c8>
ffffffffc020149e:	09600593          	li	a1,150
ffffffffc02014a2:	00001517          	auipc	a0,0x1
ffffffffc02014a6:	ff650513          	addi	a0,a0,-10 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02014aa:	c93fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02014ae:	00001697          	auipc	a3,0x1
ffffffffc02014b2:	fca68693          	addi	a3,a3,-54 # ffffffffc0202478 <commands+0x7c0>
ffffffffc02014b6:	00001617          	auipc	a2,0x1
ffffffffc02014ba:	fca60613          	addi	a2,a2,-54 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02014be:	09300593          	li	a1,147
ffffffffc02014c2:	00001517          	auipc	a0,0x1
ffffffffc02014c6:	fd650513          	addi	a0,a0,-42 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02014ca:	c73fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc02014ce <best_fit_init_memmap>:
ffffffffc02014ce:	1141                	addi	sp,sp,-16
ffffffffc02014d0:	e406                	sd	ra,8(sp)
ffffffffc02014d2:	c1fd                	beqz	a1,ffffffffc02015b8 <best_fit_init_memmap+0xea>
ffffffffc02014d4:	00259693          	slli	a3,a1,0x2
ffffffffc02014d8:	96ae                	add	a3,a3,a1
ffffffffc02014da:	068e                	slli	a3,a3,0x3
ffffffffc02014dc:	96aa                	add	a3,a3,a0
ffffffffc02014de:	02d50463          	beq	a0,a3,ffffffffc0201506 <best_fit_init_memmap+0x38>
ffffffffc02014e2:	6518                	ld	a4,8(a0)
ffffffffc02014e4:	87aa                	mv	a5,a0
ffffffffc02014e6:	8b05                	andi	a4,a4,1
ffffffffc02014e8:	e709                	bnez	a4,ffffffffc02014f2 <best_fit_init_memmap+0x24>
ffffffffc02014ea:	a07d                	j	ffffffffc0201598 <best_fit_init_memmap+0xca>
ffffffffc02014ec:	6798                	ld	a4,8(a5)
ffffffffc02014ee:	8b05                	andi	a4,a4,1
ffffffffc02014f0:	c745                	beqz	a4,ffffffffc0201598 <best_fit_init_memmap+0xca>
ffffffffc02014f2:	0007b423          	sd	zero,8(a5)
ffffffffc02014f6:	0007a823          	sw	zero,16(a5)
ffffffffc02014fa:	0007a023          	sw	zero,0(a5)
ffffffffc02014fe:	02878793          	addi	a5,a5,40
ffffffffc0201502:	fed795e3          	bne	a5,a3,ffffffffc02014ec <best_fit_init_memmap+0x1e>
ffffffffc0201506:	2581                	sext.w	a1,a1
ffffffffc0201508:	c90c                	sw	a1,16(a0)
ffffffffc020150a:	4789                	li	a5,2
ffffffffc020150c:	00850713          	addi	a4,a0,8
ffffffffc0201510:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201514:	00005697          	auipc	a3,0x5
ffffffffc0201518:	f3c68693          	addi	a3,a3,-196 # ffffffffc0206450 <free_area>
ffffffffc020151c:	4a98                	lw	a4,16(a3)
ffffffffc020151e:	669c                	ld	a5,8(a3)
ffffffffc0201520:	9db9                	addw	a1,a1,a4
ffffffffc0201522:	00005717          	auipc	a4,0x5
ffffffffc0201526:	f2b72f23          	sw	a1,-194(a4) # ffffffffc0206460 <free_area+0x10>
ffffffffc020152a:	04d78a63          	beq	a5,a3,ffffffffc020157e <best_fit_init_memmap+0xb0>
ffffffffc020152e:	fe878713          	addi	a4,a5,-24
ffffffffc0201532:	628c                	ld	a1,0(a3)
ffffffffc0201534:	4801                	li	a6,0
ffffffffc0201536:	01850613          	addi	a2,a0,24
ffffffffc020153a:	00e56a63          	bltu	a0,a4,ffffffffc020154e <best_fit_init_memmap+0x80>
ffffffffc020153e:	6798                	ld	a4,8(a5)
ffffffffc0201540:	02d70563          	beq	a4,a3,ffffffffc020156a <best_fit_init_memmap+0x9c>
ffffffffc0201544:	87ba                	mv	a5,a4
ffffffffc0201546:	fe878713          	addi	a4,a5,-24
ffffffffc020154a:	fee57ae3          	bgeu	a0,a4,ffffffffc020153e <best_fit_init_memmap+0x70>
ffffffffc020154e:	00080663          	beqz	a6,ffffffffc020155a <best_fit_init_memmap+0x8c>
ffffffffc0201552:	00005717          	auipc	a4,0x5
ffffffffc0201556:	eeb73f23          	sd	a1,-258(a4) # ffffffffc0206450 <free_area>
ffffffffc020155a:	6398                	ld	a4,0(a5)
ffffffffc020155c:	60a2                	ld	ra,8(sp)
ffffffffc020155e:	e390                	sd	a2,0(a5)
ffffffffc0201560:	e710                	sd	a2,8(a4)
ffffffffc0201562:	f11c                	sd	a5,32(a0)
ffffffffc0201564:	ed18                	sd	a4,24(a0)
ffffffffc0201566:	0141                	addi	sp,sp,16
ffffffffc0201568:	8082                	ret
ffffffffc020156a:	e790                	sd	a2,8(a5)
ffffffffc020156c:	f114                	sd	a3,32(a0)
ffffffffc020156e:	6798                	ld	a4,8(a5)
ffffffffc0201570:	ed1c                	sd	a5,24(a0)
ffffffffc0201572:	85b2                	mv	a1,a2
ffffffffc0201574:	00d70e63          	beq	a4,a3,ffffffffc0201590 <best_fit_init_memmap+0xc2>
ffffffffc0201578:	4805                	li	a6,1
ffffffffc020157a:	87ba                	mv	a5,a4
ffffffffc020157c:	b7e9                	j	ffffffffc0201546 <best_fit_init_memmap+0x78>
ffffffffc020157e:	60a2                	ld	ra,8(sp)
ffffffffc0201580:	01850713          	addi	a4,a0,24
ffffffffc0201584:	e398                	sd	a4,0(a5)
ffffffffc0201586:	e798                	sd	a4,8(a5)
ffffffffc0201588:	f11c                	sd	a5,32(a0)
ffffffffc020158a:	ed1c                	sd	a5,24(a0)
ffffffffc020158c:	0141                	addi	sp,sp,16
ffffffffc020158e:	8082                	ret
ffffffffc0201590:	60a2                	ld	ra,8(sp)
ffffffffc0201592:	e290                	sd	a2,0(a3)
ffffffffc0201594:	0141                	addi	sp,sp,16
ffffffffc0201596:	8082                	ret
ffffffffc0201598:	00001697          	auipc	a3,0x1
ffffffffc020159c:	20868693          	addi	a3,a3,520 # ffffffffc02027a0 <commands+0xae8>
ffffffffc02015a0:	00001617          	auipc	a2,0x1
ffffffffc02015a4:	ee060613          	addi	a2,a2,-288 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02015a8:	04a00593          	li	a1,74
ffffffffc02015ac:	00001517          	auipc	a0,0x1
ffffffffc02015b0:	eec50513          	addi	a0,a0,-276 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02015b4:	b89fe0ef          	jal	ra,ffffffffc020013c <__panic>
ffffffffc02015b8:	00001697          	auipc	a3,0x1
ffffffffc02015bc:	ec068693          	addi	a3,a3,-320 # ffffffffc0202478 <commands+0x7c0>
ffffffffc02015c0:	00001617          	auipc	a2,0x1
ffffffffc02015c4:	ec060613          	addi	a2,a2,-320 # ffffffffc0202480 <commands+0x7c8>
ffffffffc02015c8:	04700593          	li	a1,71
ffffffffc02015cc:	00001517          	auipc	a0,0x1
ffffffffc02015d0:	ecc50513          	addi	a0,a0,-308 # ffffffffc0202498 <commands+0x7e0>
ffffffffc02015d4:	b69fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc02015d8 <strnlen>:
ffffffffc02015d8:	c185                	beqz	a1,ffffffffc02015f8 <strnlen+0x20>
ffffffffc02015da:	00054783          	lbu	a5,0(a0)
ffffffffc02015de:	cf89                	beqz	a5,ffffffffc02015f8 <strnlen+0x20>
ffffffffc02015e0:	4781                	li	a5,0
ffffffffc02015e2:	a021                	j	ffffffffc02015ea <strnlen+0x12>
ffffffffc02015e4:	00074703          	lbu	a4,0(a4)
ffffffffc02015e8:	c711                	beqz	a4,ffffffffc02015f4 <strnlen+0x1c>
ffffffffc02015ea:	0785                	addi	a5,a5,1
ffffffffc02015ec:	00f50733          	add	a4,a0,a5
ffffffffc02015f0:	fef59ae3          	bne	a1,a5,ffffffffc02015e4 <strnlen+0xc>
ffffffffc02015f4:	853e                	mv	a0,a5
ffffffffc02015f6:	8082                	ret
ffffffffc02015f8:	4781                	li	a5,0
ffffffffc02015fa:	853e                	mv	a0,a5
ffffffffc02015fc:	8082                	ret

ffffffffc02015fe <strcmp>:
ffffffffc02015fe:	00054783          	lbu	a5,0(a0)
ffffffffc0201602:	0005c703          	lbu	a4,0(a1)
ffffffffc0201606:	cb91                	beqz	a5,ffffffffc020161a <strcmp+0x1c>
ffffffffc0201608:	00e79c63          	bne	a5,a4,ffffffffc0201620 <strcmp+0x22>
ffffffffc020160c:	0505                	addi	a0,a0,1
ffffffffc020160e:	00054783          	lbu	a5,0(a0)
ffffffffc0201612:	0585                	addi	a1,a1,1
ffffffffc0201614:	0005c703          	lbu	a4,0(a1)
ffffffffc0201618:	fbe5                	bnez	a5,ffffffffc0201608 <strcmp+0xa>
ffffffffc020161a:	4501                	li	a0,0
ffffffffc020161c:	9d19                	subw	a0,a0,a4
ffffffffc020161e:	8082                	ret
ffffffffc0201620:	0007851b          	sext.w	a0,a5
ffffffffc0201624:	9d19                	subw	a0,a0,a4
ffffffffc0201626:	8082                	ret

ffffffffc0201628 <strchr>:
ffffffffc0201628:	00054783          	lbu	a5,0(a0)
ffffffffc020162c:	cb91                	beqz	a5,ffffffffc0201640 <strchr+0x18>
ffffffffc020162e:	00b79563          	bne	a5,a1,ffffffffc0201638 <strchr+0x10>
ffffffffc0201632:	a809                	j	ffffffffc0201644 <strchr+0x1c>
ffffffffc0201634:	00b78763          	beq	a5,a1,ffffffffc0201642 <strchr+0x1a>
ffffffffc0201638:	0505                	addi	a0,a0,1
ffffffffc020163a:	00054783          	lbu	a5,0(a0)
ffffffffc020163e:	fbfd                	bnez	a5,ffffffffc0201634 <strchr+0xc>
ffffffffc0201640:	4501                	li	a0,0
ffffffffc0201642:	8082                	ret
ffffffffc0201644:	8082                	ret

ffffffffc0201646 <memset>:
ffffffffc0201646:	ca01                	beqz	a2,ffffffffc0201656 <memset+0x10>
ffffffffc0201648:	962a                	add	a2,a2,a0
ffffffffc020164a:	87aa                	mv	a5,a0
ffffffffc020164c:	0785                	addi	a5,a5,1
ffffffffc020164e:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0201652:	fec79de3          	bne	a5,a2,ffffffffc020164c <memset+0x6>
ffffffffc0201656:	8082                	ret

ffffffffc0201658 <printnum>:
ffffffffc0201658:	02069813          	slli	a6,a3,0x20
ffffffffc020165c:	7179                	addi	sp,sp,-48
ffffffffc020165e:	02085813          	srli	a6,a6,0x20
ffffffffc0201662:	e052                	sd	s4,0(sp)
ffffffffc0201664:	03067a33          	remu	s4,a2,a6
ffffffffc0201668:	f022                	sd	s0,32(sp)
ffffffffc020166a:	ec26                	sd	s1,24(sp)
ffffffffc020166c:	e84a                	sd	s2,16(sp)
ffffffffc020166e:	f406                	sd	ra,40(sp)
ffffffffc0201670:	e44e                	sd	s3,8(sp)
ffffffffc0201672:	84aa                	mv	s1,a0
ffffffffc0201674:	892e                	mv	s2,a1
ffffffffc0201676:	fff7041b          	addiw	s0,a4,-1
ffffffffc020167a:	2a01                	sext.w	s4,s4
ffffffffc020167c:	03067e63          	bgeu	a2,a6,ffffffffc02016b8 <printnum+0x60>
ffffffffc0201680:	89be                	mv	s3,a5
ffffffffc0201682:	00805763          	blez	s0,ffffffffc0201690 <printnum+0x38>
ffffffffc0201686:	347d                	addiw	s0,s0,-1
ffffffffc0201688:	85ca                	mv	a1,s2
ffffffffc020168a:	854e                	mv	a0,s3
ffffffffc020168c:	9482                	jalr	s1
ffffffffc020168e:	fc65                	bnez	s0,ffffffffc0201686 <printnum+0x2e>
ffffffffc0201690:	1a02                	slli	s4,s4,0x20
ffffffffc0201692:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201696:	00001797          	auipc	a5,0x1
ffffffffc020169a:	2fa78793          	addi	a5,a5,762 # ffffffffc0202990 <error_string+0x38>
ffffffffc020169e:	9a3e                	add	s4,s4,a5
ffffffffc02016a0:	7402                	ld	s0,32(sp)
ffffffffc02016a2:	000a4503          	lbu	a0,0(s4)
ffffffffc02016a6:	70a2                	ld	ra,40(sp)
ffffffffc02016a8:	69a2                	ld	s3,8(sp)
ffffffffc02016aa:	6a02                	ld	s4,0(sp)
ffffffffc02016ac:	85ca                	mv	a1,s2
ffffffffc02016ae:	8326                	mv	t1,s1
ffffffffc02016b0:	6942                	ld	s2,16(sp)
ffffffffc02016b2:	64e2                	ld	s1,24(sp)
ffffffffc02016b4:	6145                	addi	sp,sp,48
ffffffffc02016b6:	8302                	jr	t1
ffffffffc02016b8:	03065633          	divu	a2,a2,a6
ffffffffc02016bc:	8722                	mv	a4,s0
ffffffffc02016be:	f9bff0ef          	jal	ra,ffffffffc0201658 <printnum>
ffffffffc02016c2:	b7f9                	j	ffffffffc0201690 <printnum+0x38>

ffffffffc02016c4 <vprintfmt>:
ffffffffc02016c4:	7119                	addi	sp,sp,-128
ffffffffc02016c6:	f4a6                	sd	s1,104(sp)
ffffffffc02016c8:	f0ca                	sd	s2,96(sp)
ffffffffc02016ca:	e8d2                	sd	s4,80(sp)
ffffffffc02016cc:	e4d6                	sd	s5,72(sp)
ffffffffc02016ce:	e0da                	sd	s6,64(sp)
ffffffffc02016d0:	fc5e                	sd	s7,56(sp)
ffffffffc02016d2:	f862                	sd	s8,48(sp)
ffffffffc02016d4:	f06a                	sd	s10,32(sp)
ffffffffc02016d6:	fc86                	sd	ra,120(sp)
ffffffffc02016d8:	f8a2                	sd	s0,112(sp)
ffffffffc02016da:	ecce                	sd	s3,88(sp)
ffffffffc02016dc:	f466                	sd	s9,40(sp)
ffffffffc02016de:	ec6e                	sd	s11,24(sp)
ffffffffc02016e0:	892a                	mv	s2,a0
ffffffffc02016e2:	84ae                	mv	s1,a1
ffffffffc02016e4:	8d32                	mv	s10,a2
ffffffffc02016e6:	8ab6                	mv	s5,a3
ffffffffc02016e8:	5b7d                	li	s6,-1
ffffffffc02016ea:	00001a17          	auipc	s4,0x1
ffffffffc02016ee:	116a0a13          	addi	s4,s4,278 # ffffffffc0202800 <best_fit_pmm_manager+0x50>
ffffffffc02016f2:	05e00b93          	li	s7,94
ffffffffc02016f6:	00001c17          	auipc	s8,0x1
ffffffffc02016fa:	262c0c13          	addi	s8,s8,610 # ffffffffc0202958 <error_string>
ffffffffc02016fe:	000d4503          	lbu	a0,0(s10)
ffffffffc0201702:	02500793          	li	a5,37
ffffffffc0201706:	001d0413          	addi	s0,s10,1
ffffffffc020170a:	00f50e63          	beq	a0,a5,ffffffffc0201726 <vprintfmt+0x62>
ffffffffc020170e:	c521                	beqz	a0,ffffffffc0201756 <vprintfmt+0x92>
ffffffffc0201710:	02500993          	li	s3,37
ffffffffc0201714:	a011                	j	ffffffffc0201718 <vprintfmt+0x54>
ffffffffc0201716:	c121                	beqz	a0,ffffffffc0201756 <vprintfmt+0x92>
ffffffffc0201718:	85a6                	mv	a1,s1
ffffffffc020171a:	0405                	addi	s0,s0,1
ffffffffc020171c:	9902                	jalr	s2
ffffffffc020171e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201722:	ff351ae3          	bne	a0,s3,ffffffffc0201716 <vprintfmt+0x52>
ffffffffc0201726:	00044603          	lbu	a2,0(s0)
ffffffffc020172a:	02000793          	li	a5,32
ffffffffc020172e:	4981                	li	s3,0
ffffffffc0201730:	4801                	li	a6,0
ffffffffc0201732:	5cfd                	li	s9,-1
ffffffffc0201734:	5dfd                	li	s11,-1
ffffffffc0201736:	05500593          	li	a1,85
ffffffffc020173a:	4525                	li	a0,9
ffffffffc020173c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201740:	0ff6f693          	zext.b	a3,a3
ffffffffc0201744:	00140d13          	addi	s10,s0,1
ffffffffc0201748:	1ed5ef63          	bltu	a1,a3,ffffffffc0201946 <vprintfmt+0x282>
ffffffffc020174c:	068a                	slli	a3,a3,0x2
ffffffffc020174e:	96d2                	add	a3,a3,s4
ffffffffc0201750:	4294                	lw	a3,0(a3)
ffffffffc0201752:	96d2                	add	a3,a3,s4
ffffffffc0201754:	8682                	jr	a3
ffffffffc0201756:	70e6                	ld	ra,120(sp)
ffffffffc0201758:	7446                	ld	s0,112(sp)
ffffffffc020175a:	74a6                	ld	s1,104(sp)
ffffffffc020175c:	7906                	ld	s2,96(sp)
ffffffffc020175e:	69e6                	ld	s3,88(sp)
ffffffffc0201760:	6a46                	ld	s4,80(sp)
ffffffffc0201762:	6aa6                	ld	s5,72(sp)
ffffffffc0201764:	6b06                	ld	s6,64(sp)
ffffffffc0201766:	7be2                	ld	s7,56(sp)
ffffffffc0201768:	7c42                	ld	s8,48(sp)
ffffffffc020176a:	7ca2                	ld	s9,40(sp)
ffffffffc020176c:	7d02                	ld	s10,32(sp)
ffffffffc020176e:	6de2                	ld	s11,24(sp)
ffffffffc0201770:	6109                	addi	sp,sp,128
ffffffffc0201772:	8082                	ret
ffffffffc0201774:	87b2                	mv	a5,a2
ffffffffc0201776:	00144603          	lbu	a2,1(s0)
ffffffffc020177a:	846a                	mv	s0,s10
ffffffffc020177c:	b7c1                	j	ffffffffc020173c <vprintfmt+0x78>
ffffffffc020177e:	000aac83          	lw	s9,0(s5)
ffffffffc0201782:	00144603          	lbu	a2,1(s0)
ffffffffc0201786:	0aa1                	addi	s5,s5,8
ffffffffc0201788:	846a                	mv	s0,s10
ffffffffc020178a:	fa0dd9e3          	bgez	s11,ffffffffc020173c <vprintfmt+0x78>
ffffffffc020178e:	8de6                	mv	s11,s9
ffffffffc0201790:	5cfd                	li	s9,-1
ffffffffc0201792:	b76d                	j	ffffffffc020173c <vprintfmt+0x78>
ffffffffc0201794:	fffdc693          	not	a3,s11
ffffffffc0201798:	96fd                	srai	a3,a3,0x3f
ffffffffc020179a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020179e:	00144603          	lbu	a2,1(s0)
ffffffffc02017a2:	2d81                	sext.w	s11,s11
ffffffffc02017a4:	846a                	mv	s0,s10
ffffffffc02017a6:	bf59                	j	ffffffffc020173c <vprintfmt+0x78>
ffffffffc02017a8:	4705                	li	a4,1
ffffffffc02017aa:	008a8593          	addi	a1,s5,8
ffffffffc02017ae:	01074463          	blt	a4,a6,ffffffffc02017b6 <vprintfmt+0xf2>
ffffffffc02017b2:	22080863          	beqz	a6,ffffffffc02019e2 <vprintfmt+0x31e>
ffffffffc02017b6:	000ab603          	ld	a2,0(s5)
ffffffffc02017ba:	46c1                	li	a3,16
ffffffffc02017bc:	8aae                	mv	s5,a1
ffffffffc02017be:	a291                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc02017c0:	fd060c9b          	addiw	s9,a2,-48
ffffffffc02017c4:	00144603          	lbu	a2,1(s0)
ffffffffc02017c8:	846a                	mv	s0,s10
ffffffffc02017ca:	fd06069b          	addiw	a3,a2,-48
ffffffffc02017ce:	0006089b          	sext.w	a7,a2
ffffffffc02017d2:	fad56ce3          	bltu	a0,a3,ffffffffc020178a <vprintfmt+0xc6>
ffffffffc02017d6:	0405                	addi	s0,s0,1
ffffffffc02017d8:	002c969b          	slliw	a3,s9,0x2
ffffffffc02017dc:	00044603          	lbu	a2,0(s0)
ffffffffc02017e0:	0196873b          	addw	a4,a3,s9
ffffffffc02017e4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02017e8:	0117073b          	addw	a4,a4,a7
ffffffffc02017ec:	fd06069b          	addiw	a3,a2,-48
ffffffffc02017f0:	fd070c9b          	addiw	s9,a4,-48
ffffffffc02017f4:	0006089b          	sext.w	a7,a2
ffffffffc02017f8:	fcd57fe3          	bgeu	a0,a3,ffffffffc02017d6 <vprintfmt+0x112>
ffffffffc02017fc:	b779                	j	ffffffffc020178a <vprintfmt+0xc6>
ffffffffc02017fe:	000aa503          	lw	a0,0(s5)
ffffffffc0201802:	85a6                	mv	a1,s1
ffffffffc0201804:	0aa1                	addi	s5,s5,8
ffffffffc0201806:	9902                	jalr	s2
ffffffffc0201808:	bddd                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020180a:	4705                	li	a4,1
ffffffffc020180c:	008a8993          	addi	s3,s5,8
ffffffffc0201810:	01074463          	blt	a4,a6,ffffffffc0201818 <vprintfmt+0x154>
ffffffffc0201814:	1c080463          	beqz	a6,ffffffffc02019dc <vprintfmt+0x318>
ffffffffc0201818:	000ab403          	ld	s0,0(s5)
ffffffffc020181c:	1c044a63          	bltz	s0,ffffffffc02019f0 <vprintfmt+0x32c>
ffffffffc0201820:	8622                	mv	a2,s0
ffffffffc0201822:	8ace                	mv	s5,s3
ffffffffc0201824:	46a9                	li	a3,10
ffffffffc0201826:	a8f1                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc0201828:	000aa783          	lw	a5,0(s5)
ffffffffc020182c:	4719                	li	a4,6
ffffffffc020182e:	0aa1                	addi	s5,s5,8
ffffffffc0201830:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201834:	8fb5                	xor	a5,a5,a3
ffffffffc0201836:	40d786bb          	subw	a3,a5,a3
ffffffffc020183a:	12d74963          	blt	a4,a3,ffffffffc020196c <vprintfmt+0x2a8>
ffffffffc020183e:	00369793          	slli	a5,a3,0x3
ffffffffc0201842:	97e2                	add	a5,a5,s8
ffffffffc0201844:	639c                	ld	a5,0(a5)
ffffffffc0201846:	12078363          	beqz	a5,ffffffffc020196c <vprintfmt+0x2a8>
ffffffffc020184a:	86be                	mv	a3,a5
ffffffffc020184c:	00001617          	auipc	a2,0x1
ffffffffc0201850:	1f460613          	addi	a2,a2,500 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc0201854:	85a6                	mv	a1,s1
ffffffffc0201856:	854a                	mv	a0,s2
ffffffffc0201858:	1cc000ef          	jal	ra,ffffffffc0201a24 <printfmt>
ffffffffc020185c:	b54d                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020185e:	000ab603          	ld	a2,0(s5)
ffffffffc0201862:	0aa1                	addi	s5,s5,8
ffffffffc0201864:	1a060163          	beqz	a2,ffffffffc0201a06 <vprintfmt+0x342>
ffffffffc0201868:	00160413          	addi	s0,a2,1
ffffffffc020186c:	15b05763          	blez	s11,ffffffffc02019ba <vprintfmt+0x2f6>
ffffffffc0201870:	02d00593          	li	a1,45
ffffffffc0201874:	10b79d63          	bne	a5,a1,ffffffffc020198e <vprintfmt+0x2ca>
ffffffffc0201878:	00064783          	lbu	a5,0(a2)
ffffffffc020187c:	0007851b          	sext.w	a0,a5
ffffffffc0201880:	c905                	beqz	a0,ffffffffc02018b0 <vprintfmt+0x1ec>
ffffffffc0201882:	000cc563          	bltz	s9,ffffffffc020188c <vprintfmt+0x1c8>
ffffffffc0201886:	3cfd                	addiw	s9,s9,-1
ffffffffc0201888:	036c8263          	beq	s9,s6,ffffffffc02018ac <vprintfmt+0x1e8>
ffffffffc020188c:	85a6                	mv	a1,s1
ffffffffc020188e:	14098f63          	beqz	s3,ffffffffc02019ec <vprintfmt+0x328>
ffffffffc0201892:	3781                	addiw	a5,a5,-32
ffffffffc0201894:	14fbfc63          	bgeu	s7,a5,ffffffffc02019ec <vprintfmt+0x328>
ffffffffc0201898:	03f00513          	li	a0,63
ffffffffc020189c:	9902                	jalr	s2
ffffffffc020189e:	0405                	addi	s0,s0,1
ffffffffc02018a0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02018a4:	3dfd                	addiw	s11,s11,-1
ffffffffc02018a6:	0007851b          	sext.w	a0,a5
ffffffffc02018aa:	fd61                	bnez	a0,ffffffffc0201882 <vprintfmt+0x1be>
ffffffffc02018ac:	e5b059e3          	blez	s11,ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc02018b0:	3dfd                	addiw	s11,s11,-1
ffffffffc02018b2:	85a6                	mv	a1,s1
ffffffffc02018b4:	02000513          	li	a0,32
ffffffffc02018b8:	9902                	jalr	s2
ffffffffc02018ba:	e40d82e3          	beqz	s11,ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc02018be:	3dfd                	addiw	s11,s11,-1
ffffffffc02018c0:	85a6                	mv	a1,s1
ffffffffc02018c2:	02000513          	li	a0,32
ffffffffc02018c6:	9902                	jalr	s2
ffffffffc02018c8:	fe0d94e3          	bnez	s11,ffffffffc02018b0 <vprintfmt+0x1ec>
ffffffffc02018cc:	bd0d                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc02018ce:	4705                	li	a4,1
ffffffffc02018d0:	008a8593          	addi	a1,s5,8
ffffffffc02018d4:	01074463          	blt	a4,a6,ffffffffc02018dc <vprintfmt+0x218>
ffffffffc02018d8:	0e080863          	beqz	a6,ffffffffc02019c8 <vprintfmt+0x304>
ffffffffc02018dc:	000ab603          	ld	a2,0(s5)
ffffffffc02018e0:	46a1                	li	a3,8
ffffffffc02018e2:	8aae                	mv	s5,a1
ffffffffc02018e4:	a839                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc02018e6:	03000513          	li	a0,48
ffffffffc02018ea:	85a6                	mv	a1,s1
ffffffffc02018ec:	e03e                	sd	a5,0(sp)
ffffffffc02018ee:	9902                	jalr	s2
ffffffffc02018f0:	85a6                	mv	a1,s1
ffffffffc02018f2:	07800513          	li	a0,120
ffffffffc02018f6:	9902                	jalr	s2
ffffffffc02018f8:	0aa1                	addi	s5,s5,8
ffffffffc02018fa:	ff8ab603          	ld	a2,-8(s5)
ffffffffc02018fe:	6782                	ld	a5,0(sp)
ffffffffc0201900:	46c1                	li	a3,16
ffffffffc0201902:	2781                	sext.w	a5,a5
ffffffffc0201904:	876e                	mv	a4,s11
ffffffffc0201906:	85a6                	mv	a1,s1
ffffffffc0201908:	854a                	mv	a0,s2
ffffffffc020190a:	d4fff0ef          	jal	ra,ffffffffc0201658 <printnum>
ffffffffc020190e:	bbc5                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc0201910:	00144603          	lbu	a2,1(s0)
ffffffffc0201914:	2805                	addiw	a6,a6,1
ffffffffc0201916:	846a                	mv	s0,s10
ffffffffc0201918:	b515                	j	ffffffffc020173c <vprintfmt+0x78>
ffffffffc020191a:	00144603          	lbu	a2,1(s0)
ffffffffc020191e:	4985                	li	s3,1
ffffffffc0201920:	846a                	mv	s0,s10
ffffffffc0201922:	bd29                	j	ffffffffc020173c <vprintfmt+0x78>
ffffffffc0201924:	85a6                	mv	a1,s1
ffffffffc0201926:	02500513          	li	a0,37
ffffffffc020192a:	9902                	jalr	s2
ffffffffc020192c:	bbc9                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020192e:	4705                	li	a4,1
ffffffffc0201930:	008a8593          	addi	a1,s5,8
ffffffffc0201934:	01074463          	blt	a4,a6,ffffffffc020193c <vprintfmt+0x278>
ffffffffc0201938:	08080d63          	beqz	a6,ffffffffc02019d2 <vprintfmt+0x30e>
ffffffffc020193c:	000ab603          	ld	a2,0(s5)
ffffffffc0201940:	46a9                	li	a3,10
ffffffffc0201942:	8aae                	mv	s5,a1
ffffffffc0201944:	bf7d                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc0201946:	85a6                	mv	a1,s1
ffffffffc0201948:	02500513          	li	a0,37
ffffffffc020194c:	9902                	jalr	s2
ffffffffc020194e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201952:	02500793          	li	a5,37
ffffffffc0201956:	8d22                	mv	s10,s0
ffffffffc0201958:	daf703e3          	beq	a4,a5,ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020195c:	02500713          	li	a4,37
ffffffffc0201960:	1d7d                	addi	s10,s10,-1
ffffffffc0201962:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201966:	fee79de3          	bne	a5,a4,ffffffffc0201960 <vprintfmt+0x29c>
ffffffffc020196a:	bb51                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020196c:	00001617          	auipc	a2,0x1
ffffffffc0201970:	0c460613          	addi	a2,a2,196 # ffffffffc0202a30 <error_string+0xd8>
ffffffffc0201974:	85a6                	mv	a1,s1
ffffffffc0201976:	854a                	mv	a0,s2
ffffffffc0201978:	0ac000ef          	jal	ra,ffffffffc0201a24 <printfmt>
ffffffffc020197c:	b349                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc020197e:	00001617          	auipc	a2,0x1
ffffffffc0201982:	0aa60613          	addi	a2,a2,170 # ffffffffc0202a28 <error_string+0xd0>
ffffffffc0201986:	00001417          	auipc	s0,0x1
ffffffffc020198a:	0a340413          	addi	s0,s0,163 # ffffffffc0202a29 <error_string+0xd1>
ffffffffc020198e:	8532                	mv	a0,a2
ffffffffc0201990:	85e6                	mv	a1,s9
ffffffffc0201992:	e032                	sd	a2,0(sp)
ffffffffc0201994:	e43e                	sd	a5,8(sp)
ffffffffc0201996:	c43ff0ef          	jal	ra,ffffffffc02015d8 <strnlen>
ffffffffc020199a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020199e:	6602                	ld	a2,0(sp)
ffffffffc02019a0:	01b05d63          	blez	s11,ffffffffc02019ba <vprintfmt+0x2f6>
ffffffffc02019a4:	67a2                	ld	a5,8(sp)
ffffffffc02019a6:	2781                	sext.w	a5,a5
ffffffffc02019a8:	e43e                	sd	a5,8(sp)
ffffffffc02019aa:	6522                	ld	a0,8(sp)
ffffffffc02019ac:	85a6                	mv	a1,s1
ffffffffc02019ae:	e032                	sd	a2,0(sp)
ffffffffc02019b0:	3dfd                	addiw	s11,s11,-1
ffffffffc02019b2:	9902                	jalr	s2
ffffffffc02019b4:	6602                	ld	a2,0(sp)
ffffffffc02019b6:	fe0d9ae3          	bnez	s11,ffffffffc02019aa <vprintfmt+0x2e6>
ffffffffc02019ba:	00064783          	lbu	a5,0(a2)
ffffffffc02019be:	0007851b          	sext.w	a0,a5
ffffffffc02019c2:	ec0510e3          	bnez	a0,ffffffffc0201882 <vprintfmt+0x1be>
ffffffffc02019c6:	bb25                	j	ffffffffc02016fe <vprintfmt+0x3a>
ffffffffc02019c8:	000ae603          	lwu	a2,0(s5)
ffffffffc02019cc:	46a1                	li	a3,8
ffffffffc02019ce:	8aae                	mv	s5,a1
ffffffffc02019d0:	bf0d                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc02019d2:	000ae603          	lwu	a2,0(s5)
ffffffffc02019d6:	46a9                	li	a3,10
ffffffffc02019d8:	8aae                	mv	s5,a1
ffffffffc02019da:	b725                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc02019dc:	000aa403          	lw	s0,0(s5)
ffffffffc02019e0:	bd35                	j	ffffffffc020181c <vprintfmt+0x158>
ffffffffc02019e2:	000ae603          	lwu	a2,0(s5)
ffffffffc02019e6:	46c1                	li	a3,16
ffffffffc02019e8:	8aae                	mv	s5,a1
ffffffffc02019ea:	bf21                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc02019ec:	9902                	jalr	s2
ffffffffc02019ee:	bd45                	j	ffffffffc020189e <vprintfmt+0x1da>
ffffffffc02019f0:	85a6                	mv	a1,s1
ffffffffc02019f2:	02d00513          	li	a0,45
ffffffffc02019f6:	e03e                	sd	a5,0(sp)
ffffffffc02019f8:	9902                	jalr	s2
ffffffffc02019fa:	8ace                	mv	s5,s3
ffffffffc02019fc:	40800633          	neg	a2,s0
ffffffffc0201a00:	46a9                	li	a3,10
ffffffffc0201a02:	6782                	ld	a5,0(sp)
ffffffffc0201a04:	bdfd                	j	ffffffffc0201902 <vprintfmt+0x23e>
ffffffffc0201a06:	01b05663          	blez	s11,ffffffffc0201a12 <vprintfmt+0x34e>
ffffffffc0201a0a:	02d00693          	li	a3,45
ffffffffc0201a0e:	f6d798e3          	bne	a5,a3,ffffffffc020197e <vprintfmt+0x2ba>
ffffffffc0201a12:	00001417          	auipc	s0,0x1
ffffffffc0201a16:	01740413          	addi	s0,s0,23 # ffffffffc0202a29 <error_string+0xd1>
ffffffffc0201a1a:	02800513          	li	a0,40
ffffffffc0201a1e:	02800793          	li	a5,40
ffffffffc0201a22:	b585                	j	ffffffffc0201882 <vprintfmt+0x1be>

ffffffffc0201a24 <printfmt>:
ffffffffc0201a24:	715d                	addi	sp,sp,-80
ffffffffc0201a26:	02810313          	addi	t1,sp,40
ffffffffc0201a2a:	f436                	sd	a3,40(sp)
ffffffffc0201a2c:	869a                	mv	a3,t1
ffffffffc0201a2e:	ec06                	sd	ra,24(sp)
ffffffffc0201a30:	f83a                	sd	a4,48(sp)
ffffffffc0201a32:	fc3e                	sd	a5,56(sp)
ffffffffc0201a34:	e0c2                	sd	a6,64(sp)
ffffffffc0201a36:	e4c6                	sd	a7,72(sp)
ffffffffc0201a38:	e41a                	sd	t1,8(sp)
ffffffffc0201a3a:	c8bff0ef          	jal	ra,ffffffffc02016c4 <vprintfmt>
ffffffffc0201a3e:	60e2                	ld	ra,24(sp)
ffffffffc0201a40:	6161                	addi	sp,sp,80
ffffffffc0201a42:	8082                	ret

ffffffffc0201a44 <readline>:
ffffffffc0201a44:	715d                	addi	sp,sp,-80
ffffffffc0201a46:	e486                	sd	ra,72(sp)
ffffffffc0201a48:	e0a2                	sd	s0,64(sp)
ffffffffc0201a4a:	fc26                	sd	s1,56(sp)
ffffffffc0201a4c:	f84a                	sd	s2,48(sp)
ffffffffc0201a4e:	f44e                	sd	s3,40(sp)
ffffffffc0201a50:	f052                	sd	s4,32(sp)
ffffffffc0201a52:	ec56                	sd	s5,24(sp)
ffffffffc0201a54:	e85a                	sd	s6,16(sp)
ffffffffc0201a56:	e45e                	sd	s7,8(sp)
ffffffffc0201a58:	c901                	beqz	a0,ffffffffc0201a68 <readline+0x24>
ffffffffc0201a5a:	85aa                	mv	a1,a0
ffffffffc0201a5c:	00001517          	auipc	a0,0x1
ffffffffc0201a60:	fe450513          	addi	a0,a0,-28 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc0201a64:	e52fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0201a68:	4481                	li	s1,0
ffffffffc0201a6a:	497d                	li	s2,31
ffffffffc0201a6c:	49a1                	li	s3,8
ffffffffc0201a6e:	4aa9                	li	s5,10
ffffffffc0201a70:	4b35                	li	s6,13
ffffffffc0201a72:	00004b97          	auipc	s7,0x4
ffffffffc0201a76:	5a6b8b93          	addi	s7,s7,1446 # ffffffffc0206018 <buf>
ffffffffc0201a7a:	3fe00a13          	li	s4,1022
ffffffffc0201a7e:	eaefe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a82:	842a                	mv	s0,a0
ffffffffc0201a84:	00054b63          	bltz	a0,ffffffffc0201a9a <readline+0x56>
ffffffffc0201a88:	00a95b63          	bge	s2,a0,ffffffffc0201a9e <readline+0x5a>
ffffffffc0201a8c:	029a5463          	bge	s4,s1,ffffffffc0201ab4 <readline+0x70>
ffffffffc0201a90:	e9cfe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a94:	842a                	mv	s0,a0
ffffffffc0201a96:	fe0559e3          	bgez	a0,ffffffffc0201a88 <readline+0x44>
ffffffffc0201a9a:	4501                	li	a0,0
ffffffffc0201a9c:	a099                	j	ffffffffc0201ae2 <readline+0x9e>
ffffffffc0201a9e:	03341463          	bne	s0,s3,ffffffffc0201ac6 <readline+0x82>
ffffffffc0201aa2:	e8b9                	bnez	s1,ffffffffc0201af8 <readline+0xb4>
ffffffffc0201aa4:	e88fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201aa8:	842a                	mv	s0,a0
ffffffffc0201aaa:	fe0548e3          	bltz	a0,ffffffffc0201a9a <readline+0x56>
ffffffffc0201aae:	fea958e3          	bge	s2,a0,ffffffffc0201a9e <readline+0x5a>
ffffffffc0201ab2:	4481                	li	s1,0
ffffffffc0201ab4:	8522                	mv	a0,s0
ffffffffc0201ab6:	e34fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201aba:	009b87b3          	add	a5,s7,s1
ffffffffc0201abe:	00878023          	sb	s0,0(a5)
ffffffffc0201ac2:	2485                	addiw	s1,s1,1
ffffffffc0201ac4:	bf6d                	j	ffffffffc0201a7e <readline+0x3a>
ffffffffc0201ac6:	01540463          	beq	s0,s5,ffffffffc0201ace <readline+0x8a>
ffffffffc0201aca:	fb641ae3          	bne	s0,s6,ffffffffc0201a7e <readline+0x3a>
ffffffffc0201ace:	8522                	mv	a0,s0
ffffffffc0201ad0:	e1afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201ad4:	00004517          	auipc	a0,0x4
ffffffffc0201ad8:	54450513          	addi	a0,a0,1348 # ffffffffc0206018 <buf>
ffffffffc0201adc:	94aa                	add	s1,s1,a0
ffffffffc0201ade:	00048023          	sb	zero,0(s1)
ffffffffc0201ae2:	60a6                	ld	ra,72(sp)
ffffffffc0201ae4:	6406                	ld	s0,64(sp)
ffffffffc0201ae6:	74e2                	ld	s1,56(sp)
ffffffffc0201ae8:	7942                	ld	s2,48(sp)
ffffffffc0201aea:	79a2                	ld	s3,40(sp)
ffffffffc0201aec:	7a02                	ld	s4,32(sp)
ffffffffc0201aee:	6ae2                	ld	s5,24(sp)
ffffffffc0201af0:	6b42                	ld	s6,16(sp)
ffffffffc0201af2:	6ba2                	ld	s7,8(sp)
ffffffffc0201af4:	6161                	addi	sp,sp,80
ffffffffc0201af6:	8082                	ret
ffffffffc0201af8:	4521                	li	a0,8
ffffffffc0201afa:	df0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201afe:	34fd                	addiw	s1,s1,-1
ffffffffc0201b00:	bfbd                	j	ffffffffc0201a7e <readline+0x3a>

ffffffffc0201b02 <sbi_console_putchar>:
ffffffffc0201b02:	00004797          	auipc	a5,0x4
ffffffffc0201b06:	50678793          	addi	a5,a5,1286 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201b0a:	6398                	ld	a4,0(a5)
ffffffffc0201b0c:	4781                	li	a5,0
ffffffffc0201b0e:	88ba                	mv	a7,a4
ffffffffc0201b10:	852a                	mv	a0,a0
ffffffffc0201b12:	85be                	mv	a1,a5
ffffffffc0201b14:	863e                	mv	a2,a5
ffffffffc0201b16:	00000073          	ecall
ffffffffc0201b1a:	87aa                	mv	a5,a0
ffffffffc0201b1c:	8082                	ret

ffffffffc0201b1e <sbi_set_timer>:
ffffffffc0201b1e:	00005797          	auipc	a5,0x5
ffffffffc0201b22:	92278793          	addi	a5,a5,-1758 # ffffffffc0206440 <SBI_SET_TIMER>
ffffffffc0201b26:	6398                	ld	a4,0(a5)
ffffffffc0201b28:	4781                	li	a5,0
ffffffffc0201b2a:	88ba                	mv	a7,a4
ffffffffc0201b2c:	852a                	mv	a0,a0
ffffffffc0201b2e:	85be                	mv	a1,a5
ffffffffc0201b30:	863e                	mv	a2,a5
ffffffffc0201b32:	00000073          	ecall
ffffffffc0201b36:	87aa                	mv	a5,a0
ffffffffc0201b38:	8082                	ret

ffffffffc0201b3a <sbi_console_getchar>:
ffffffffc0201b3a:	00004797          	auipc	a5,0x4
ffffffffc0201b3e:	4c678793          	addi	a5,a5,1222 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b42:	639c                	ld	a5,0(a5)
ffffffffc0201b44:	4501                	li	a0,0
ffffffffc0201b46:	88be                	mv	a7,a5
ffffffffc0201b48:	852a                	mv	a0,a0
ffffffffc0201b4a:	85aa                	mv	a1,a0
ffffffffc0201b4c:	862a                	mv	a2,a0
ffffffffc0201b4e:	00000073          	ecall
ffffffffc0201b52:	852a                	mv	a0,a0
ffffffffc0201b54:	2501                	sext.w	a0,a0
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <sbi_shutdown>:
ffffffffc0201b58:	00004797          	auipc	a5,0x4
ffffffffc0201b5c:	4b878793          	addi	a5,a5,1208 # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201b60:	6398                	ld	a4,0(a5)
ffffffffc0201b62:	4781                	li	a5,0
ffffffffc0201b64:	88ba                	mv	a7,a4
ffffffffc0201b66:	853e                	mv	a0,a5
ffffffffc0201b68:	85be                	mv	a1,a5
ffffffffc0201b6a:	863e                	mv	a2,a5
ffffffffc0201b6c:	00000073          	ecall
ffffffffc0201b70:	87aa                	mv	a5,a0
ffffffffc0201b72:	8082                	ret

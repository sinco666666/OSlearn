### Lab0.5

启动qemu和gdb进行调试工作

```make dubge```

```make gdb```

```x/10i $pc``` : 显示即将执行的10条汇编指令。

```x/10i 0x80000000`` : 显示 0x80000000 处的10条汇编指令。

`x/10xw 0x80000000 `: 显示 0x80000000 处的10条数据，格式为16进制32bit。

`info register`: 显示当前所有寄存器信息。

`info r t0`: 显示 t0 寄存器的值。

`break funcname`: 在目标函数第一条指令处设置断点。

`break *0x80200000`: 在 0x80200000 处设置断点。

```
0x1000:	auipc	t0,0x0
0x1004:	addi	a1,t0,32
0x1008:	csrr	a0,mhartid
0x100c:	ld	t0,24(t0)
0x1010:	jr	t0
0x1014:	unimp
0x1016:	unimp
0x1018:	unimp
0x101a:	0x8000
```

1. 将当前指令地址上半部分保存到 `t0` 中。
2. 将 `t0 + 32` 的值存储到 `a1`( **0x1000 + 32 = 0x1020**) 中。
3. 读取硬件线程 ID 到 `a0` 中。
4. 从内存地址 `t0+24`加载数据到 `t0`(**0x8000**)。
5. 跳转到 `t0` 指向的地址。

在QEMU模拟的这款riscv处理器中，将复位向量地址初始化为`0x1000`，再将PC初始化为该复位地址，因此处理器将从此处开始执行复位代码，复位代码主要是将计算机系统的各个组件（包括处理器、内存、设备等）置于初始状态，并且会启动Bootloader，在这里QEMU的复位代码指定加载Bootloader的位置为`0x80000000`，Bootloader将加载操作系统内核并启动操作系统的执行。

目前已跳转到`0x80000000`位置后，在`0x80200000`处设置断点，继续使用`continue`指令继续执行，发现出现下面的页面

![image-20240928161159031](C:\Users\ASUS\AppData\Roaming\Typora\typora-user-images\image-20240928161159031.png)

并显示`0x80200000`处会执行的指令`la sp, bootstacktop`即为entry.S文件中的入口标签的第一条指令。

### Lab1

#### 练习1：理解内核启动中的程序入口操作

阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

`la sp, bootstacktop`：`la` 是 “Load Address” 指令，它将符号 `bootstacktop` 的地址加载到寄存器 `sp` 中。`sp` 是栈指针寄存器，通常用于指向当前栈顶。`bootstacktop` 是预定义的符号，表示内核栈的栈顶地址。

`tail kern_init`：跳转到`kern_init` 函数启动内核初始化过程，`kern_init` 是内核初始化的主函数，负责初始化内核。 `tail` 是 RISC-V 架构中的一种跳转指令，它与 `jal`（跳转并链接）类似，但 `tail` 旨在执行尾调用优化（tail call optimization）。即，它在跳转到 `kern_init` 函数时，不保存返回地址，而是将跳转视为最终的操作。因此，当前函数不会返回，直接让 `kern_init` 开始执行。

#### 练习2：完善中断处理 （需要编程）

请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

```c
clock_set_next_event();
static int ticks = 0;
ticks++;
if (ticks % TICK_NUM == 0){
num++;
print_ticks();
}
            
if (num == 10){
sbi_shutdown();
}
```

其中的print_ticks()函数如下所示：

```
static void print_ticks() {
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
```

`TICK_NUM` 是一个宏定义，通常值为 100，也就是说，这行代码会输出```100 ticks``

#### 扩展练习 Challenge1：描述与理解中断流程

描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由

当 CPU 运行时，可能会因为多种原因产生异常或中断，一旦发生异常或中断，CPU 会切换到内核模式，并跳转到一个预定义的异常处理入口。这时，CPU 自动执行以下操作：

保存当前程序的上下文，比如程序计数器（`sepc`）、中断/异常原因（`scause`）、以及异常引发的地址（`stval`）。

跳转到内核的异常处理向量，在 uCore 中就是 `__alltraps`。

在 `trapentry.S` 中，`__alltraps` 是异常处理的起点，它的主要任务是保存当前的 CPU 寄存器和状态，以便后续处理异常时不会丢失任何上下文。

`SAVE_ALL` 宏负责保存所有通用寄存器（x0 到 x31），以及一些重要的 CSR（如 `sstatus`、`sepc`、`scause` 和 `stval`）。寄存器保存在当前的栈上。

在这之后，CPU 将栈指针 `sp` 传递给 C 函数 `trap`，以便进行更高层次的异常处理。

`mov a0, sp` 这个指令将当前栈指针 `sp` 的值存入 `a0` 寄存器中。随后，`a0` 会作为参数传递给 C 语言编写的 `trap` 函数。其作用是将当前的栈帧传递给 C 语言处理函数，以便在异常处理中可以访问保存的寄存器和其他状态信息。

当 `trap` 函数被调用时，它接收到的参数是当前的栈指针（通过 `mov a0, sp` 传递）。`trap` 函数的任务是根据异常的类型（由 `scause` 寄存器指示）来执行不同的处理逻辑：

如果 `scause` 表示是中断，则进入中断处理流程，比如处理时钟中断或设备中断。

如果 `scause` 表示是异常（如非法指令），则执行异常处理流程，比如恢复指令、终止进程等。

`__trapret` 通过 `RESTORE_ALL` 恢复之前保存的寄存器状态。然后，执行 `sret` 指令，这将 CPU 的执行恢复到用户态或原来的执行上下文，继续执行异常发生时的代码。

在处理完中断或异常后，`trap` 函数会返回到汇编层，继续执行 `__trapret`。

在 `SAVE_ALL` 宏中，寄存器保存在栈上的具体位置是通过一个固定的偏移量计算的，偏移量由每个寄存器的编号和寄存器大小（REGBYTES）决定：

- 每个寄存器保存的顺序是固定的，从 `x0` 到 `x31`，按寄存器编号排列。
- 栈空间通过 `addi sp, sp, -36 * REGBYTES` 分配，其中 `36 * REGBYTES` 是为 32 个通用寄存器加上 4 个 CSR（`sstatus`、`sepc`、`scause`、`stval`）留出的空间。
- 每个寄存器被保存到栈的相对偏移位置。例如，`x1` 寄存器保存在 `1 * REGBYTES(sp)`，`x31` 寄存器保存在 `31 * REGBYTES(sp)`，依次类推。

这种顺序是为了确保在异常处理时，所有寄存器的值都可以按固定的顺序被保存和恢复，保证上下文的完整性。

#### 扩增练习 Challenge2：理解上下文切换机制

在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

`csrw sscratch, sp` 是将当前栈指针保存到 `sscratch` 寄存器，以备后续处理中使用。

`csrrw s0, sscratch, x0` 是将 `sscratch` 的值保存到寄存器 `s0`，并将 `sscratch` 置为 0，确保在异常处理时区分内核态和用户态的栈指针。

`SAVE_ALL` 宏保存了多个寄存器，包括一些重要的 CSR（如 `scause` 和 `stval`）。这些信息在处理异常时有用，但在处理结束后不需要恢复，因为恢复这些寄存器并不会对后续的执行有任何实际影响。

 `scause`，它记录了异常或中断的原因，但在处理完这个异常之后，处理程序已经知道原因了，恢复这个值没有意义。

`stval` 记录了与异常相关的虚拟地址，处理完这个地址的异常后，处理程序已经对地址进行了处理，恢复它也没有实际用途

`RESTORE_ALL` 只恢复那些对程序继续执行至关重要的寄存器，例如 `sstatus`（恢复特权级状态）和 `sepc`（确保返回到正确的指令地址）。

#### 扩展练习Challenge3：完善异常中断

编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

```c
void exception_handler(struct trapframe *tf)
{
    switch (tf->cause)
    {
    case CAUSE_ILLEGAL_INSTRUCTION:
        // 非法指令异常处理
        /* LAB1 CHALLENGE3   YOUR CODE :  */
        /*(1)输出指令异常类型（ Illegal instruction）
         *(2)输出异常指令地址
         *(3)更新 tf->epc寄存器
         */
        cprintf("Exception type:Illegal instruction\n");
        cprintf("Illegal instruction caught at %p\n", tf->epc);
        tf->epc += 4;
        break;
    case CAUSE_BREAKPOINT:
        // 断点异常处理
        /* LAB1 CHALLLENGE3   YOUR CODE :  */
        /*(1)输出指令异常类型（ breakpoint）
         *(2)输出异常指令地址
         *(3)更新 tf->epc寄存器
         */
        cprintf("Exception type: breakpoint\n");
        cprintf("ebreak caught at %p\n", tf->epc);
        tf->epc += 2;
        break;
    // ...其他异常处理
    }
}
```

```c
__asm__ __volatile__("mret");
__asm__ __volatile__("ebreak"); 
int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init(); // init the console

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);

    print_kerninfo();

    // grade_backtrace();

    idt_init(); // init interrupt descriptor table

    // rdtime in mbare mode crashes
    clock_init(); // init clock interrupt

    intr_enable(); // enable irq interrupt

    __asm__ __volatile__("mret");   // 非法指令
    __asm__ __volatile__("ebreak"); // 断点异常

    while (1)
        ;
}
```


#### 练习0：填写已有实验

本实验依赖实验2。请把你做的实验2的代码填入本实验中代码中有“LAB2”的注释相应部分。（建议手动补充，不要直接使用merge）

#### 练习1：理解基于FIFO的页面替换算法（思考题）

描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）

- 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

##### 过程描述

当发生缺页异常时，`trapFrame`传递了`badvaddr`给`do_pgfault()`函数，而这实际上是`stval`这个寄存器的数值，这个寄存器存储一些关于异常的数据，对于`PageFault`它存储的是访问出错的虚拟地址。

- `do_pgfault()`：整个缺页处理流程的开始，根据 `get_pte` 得到的页表项的内容确定页面是需要创建还是需要换入。
- `find_vma `：尝试找到包含给定地址 `addr` 的虚拟内存区域` vma`。
- `get_pte`：根据触发缺页异常的虚拟地址查找其对应的多集页表叶节的页表项。如果其中某⼀级页表不存在则为其分配⼀个新的页（4KiB）用于存储映射关系。
- `swap_in`：根据内存管理结构 `mm` 和地址 `addr`，尝试将正确的磁盘页面内容加载到由 `page` 管理的内存中，并重新写入页面的内存区域。
- `swapfs_write`：用于将页面写入磁盘。在这里由于需要换出页面，而页面内容如果被修改过那么就与磁盘中的不一致，所以需要将其重新写回磁盘。
- `swapfs_read`：用于从磁盘读入数据。
- `swap_out` ：根据需要换出的页面数量换出页面到硬盘中。
- `swap_map_swappable` ：在使用 FIFO 页面替换算法时会直接调用`_fifo_map_swappable` ，这会将新加入的页面存入FIFO 算法所需要维护的队列（使用链表实现）的开头从而保证先进先出的实现。
- `_fifo_swap_out_victim`：用于获得需要换出的页面。查找队尾的页面，作为需要释放的页面。
- `alloc_page`：用于申请页面。通过调用`pmm_manager->alloc_pages`申请一块连继续的内存空间，在这个过程中，如果申请页面失败，那么说明需要换出页面，则调用`swap_out`换出页面，之后再次进行申请。

#### 练习2：深入理解不同分页模式的工作原理（思考题）

get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

- get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
- 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

##### 相像原因

- **分页层次结构的相似性**：尽管 sv32、sv39、sv48 等不同的分页模式在虚拟地址的位数和分页层次上有所不同，但它们都遵循多级页表的基本结构。在每种模式下，都需要通过多个层次的页表索引来找到最终的物理页面。因此，在 `get_pte` 函数中，对于每一级页表的处理逻辑具有相似性，都需要检查页表项的有效性，在不存在时进行创建和初始化操作。
- **功能一致性**：无论采用哪种分页模式，函数的核心功能都是建立虚拟地址到物理地址的映射。为了实现这一功能，都需要执行类似的步骤，如分配物理页面、设置页面属性、更新页表项等。这些共同的操作导致了代码在不同层次的处理上呈现出相似的结构。
- **代码复用与可维护性**：通过使用相似的代码结构来处理不同层次的页表，可以提高代码的复用性和可维护性。这样，在修改或扩展分页机制相关的功能时，只需要在相似的代码框架内进行相应的调整，而不需要对每种分页模式编写完全不同的处理逻辑，降低了代码的复杂性和出错的可能性。

##### 合并写法的优点

这种写法好，将查找和分配页表项的功能放在一个函数中，使得与页表项操作相关的所有逻辑都集中在一起。这样对于理解和维护页表管理的相关代码更加方便，开发人员可以在一个函数中清晰地看到完整的页表项处理流程，无需在多个函数之间切换查找相关逻辑。并且，避免了因频繁调用不同函数来分别进行查找和分配操作而带来的额外开销，如函数调用栈的压入和弹出、参数传递等。特别是在一些对性能要求较高的场景下，减少这些开销有助于提高系统的整体性能。

#### 练习3：给未被映射的地址映射上物理页（需要编程）

补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
  - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

```c
if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        if (swap_init_ok) {
            struct Page *page = NULL;
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,0);
            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
```



#### 练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。

首先修改`kern/mm/memlayout.h`中Page结构体的定义，添加`visited`

```c
struct Page {
    int ref;                        
    uint64_t flags;                 
    uint64_t visited;
    unsigned int property;          
    list_entry_t page_link;        
    list_entry_t pra_page_link;     
    uintptr_t pra_vaddr;            
};
```

修改`kern/mm/swap_clock.c`文件

```c
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     return 0;
}
```

```c
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    list_add_before((list_entry_t*) mm->sm_priv,entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited = 1;
    return 0;
}
```

```c
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: YOUR CODE*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        curr_ptr = list_next(curr_ptr);
        if(curr_ptr == head) {
            curr_ptr = list_next(curr_ptr);
            if(curr_ptr == head) {
                *ptr_page = NULL;
                break;
            }
        }
        // 获取当前页面对应的Page结构指针
        struct Page* page = le2page(curr_ptr, pra_page_link);
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        if(!page->visited) {
            *ptr_page = page;
            list_del(curr_ptr);
            cprintf("curr_ptr %p\n",curr_ptr);
            break;
        } else {
            page->visited = 0;
        }
    }       
    return 0;
}
```



#### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

#### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）

challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。
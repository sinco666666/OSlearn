#include <stdio.h>
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>

#define PAGE_SIZE 4096         // 假设一页大小为4096字节
#define MAX_OBJECT_SIZE 256    // 第二层分配的最大对象大小
#define MAX_SLABS 1024         // 最大的 slab 数量

// 定义每个 slab 的数据结构
struct slab {
    void *page;                    // slab 页的起始地址
    void *free_list;               // slab 中空闲对象的链表
    size_t object_size;            // 每个对象的大小
    int free_objects;              // 当前 slab 中的空闲对象数
};

// SLUB 分配器的结构体
struct slub_allocator {
    struct slab slabs[MAX_SLABS];  // slab 列表
    int slab_count;                // slab 数量
};

// 全局分配器
struct slub_allocator allocator;

// 从物理内存管理器分配页
struct Page *alloc_pages(size_t n);

void *alloc_pags() {
    struct Page *page_struct = alloc_pages(1);
    void *page = page_struct;  // 假设结构体可以转换为 void *，若不行则修改此行

    if (page != NULL) {
        memset(page, 0, PAGE_SIZE); // 初始化为 0
    }
    return page;
}

// 其他函数保持不变

// 修正 slub_free 中的指针类型不匹配
void slub_free(void *obj, size_t size) {
    struct slab *slab = NULL;
    for (int i = 0; i < allocator.slab_count; i++) {
        if (allocator.slabs[i].object_size == size &&
            (char *)obj >= (char *)allocator.slabs[i].page &&  // 添加 (char *)
            (char *)obj < (char *)allocator.slabs[i].page + PAGE_SIZE) {  // 添加 (char *)
            slab = &allocator.slabs[i];
            break;
        }
    }

    if (slab != NULL) {
        *(void **)obj = slab->free_list;
        slab->free_list = obj;
        slab->free_objects++;
    }
}

// 初始化分配器
void slub_allocator_init() {
    allocator.slab_count = 0;
    memset(allocator.slabs, 0, sizeof(allocator.slabs));
}

// 调试检查函数
void slub_check(void) {
    for (int i = 0; i < allocator.slab_count; i++) {
        struct slab *slab = &allocator.slabs[i];
        printf("Slab %d: object size = %zu, free objects = %d\n", 
               i, slab->object_size, slab->free_objects);
    }
}

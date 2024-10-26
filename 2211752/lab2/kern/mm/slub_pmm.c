#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>

#define PAGESIZE 4096 // 假设页大小为4KB
extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
// 内存页结构体
typedef struct Page {
    struct Page *next; // 指向下一个空闲页
    int free; // 标记页是否空闲
} Page;

// SLUB分配器结构体
typedef struct {
    Page *freelist; // 空闲页链表
    int nr_free_pages; // 空闲页数量
} SlubAllocator;

// 初始化SLUB分配器
void slub_init(SlubAllocator *slab) {
    slab->freelist = NULL;
}
// 初始化内存映射
void slub_init_memmap(SlubAllocator *slab, Page *base, size_t n) {
    assert(n > 0); // 确保n大于0，即至少有一个页需要初始化

    Page *p = base;
    for (size_t i = 0; i < n; i++) {
        p->free = 1; // 标记页为空闲
        p->next = slab->freelist; // 将页添加到空闲链表头部
        slab->freelist = p;
        slab->nr_free_pages++; // 增加空闲页数量
        p++; // 移动到下一个页
    }
}

// 分配内存
void *slub_alloc(SlubAllocator *slab, size_t size) {
    assert(size <= PAGESIZE); // 确保请求的大小不超过页大小

    Page *page = slab->freelist;
    if (page) {
        slab->freelist = page->next; // 从空闲链表中移除页
        page->next = NULL;
        page->free = 0; // 标记页为已分配
        return (void *)page;
    }

    // 如果没有空闲页，则分配一个新的页
    page = malloc(PAGESIZE);
    if (!page) {
        return NULL; // 内存不足
    }
    page->next = NULL;
    page->free = 0;
    return (void *)page;
}

// 释放内存
void slub_free(SlubAllocator *slab, void *ptr) {
    Page *page = (Page *)ptr;
    page->free = 1; // 标记页为空闲
    page->next = slab->freelist; // 将页添加到空闲链表头部
    slab->freelist = page;
}
// 获取空闲页数量
static size_t
slub_nr_free_pages(SlubAllocator *slab) {
    return slab->nr_free_pages;
}

// 测试SLUB算法
void slub_check() {
    SlubAllocator slab;
    slub_init(&slab);

    void *p1 = slub_alloc(&slab, 100);
    void *p2 = slub_alloc(&slab, 200);
    void *p3 = slub_alloc(&slab, 3000);

    slub_free(&slab, p1);
    slub_free(&slab, p2);
    slub_free(&slab, p3);

    cprintf("SLUB test completed.\n");
}
const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc,
    .free_pages = slub_free,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};
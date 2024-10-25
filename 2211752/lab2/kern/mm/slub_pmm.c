// #include <pmm.h>
// #include <list.h>
// #include <string.h>
// #include <slub_pmm.h>

// #define PAGE_SIZE 4096         // 假设一页大小为4096字节
// #define MAX_OBJECT_SIZE 256    // 第二层分配的最大对象大小
// #define MAX_SLABS 1024         // 最大的 slab 数量

// // 定义每个 slab 的数据结构
// struct slab {
//     void *page;                    // slab 页的起始地址
//     void *free_list;               // slab 中空闲对象的链表
//     size_t object_size;            // 每个对象的大小
//     int free_objects;              // 当前 slab 中的空闲对象数
// };

// // SLUB 分配器的结构体
// struct slub_allocator {
//     struct slab slabs[MAX_SLABS];  // slab 列表
//     int slab_count;                // slab 数量
// };

// // 全局分配器
// struct slub_allocator allocator;

// // 第一层：分配页
// /*void *alloc_page() {
//     void *page = malloc(PAGE_SIZE);
//     if (page != NULL) {
//         memset(page, 0, PAGE_SIZE); // 初始化为 0
//     }
//     return page;
// }*/

// // 第二层：分配任意大小的小内存单元
// void *slub_alloc(size_t size) {
//     if (size > MAX_OBJECT_SIZE) {
//         return NULL;  // 超出最大对象大小限制
//     }

//     // 查找合适大小的 slab
//     struct slab *slab = NULL;
//     for (int i = 0; i < allocator.slab_count; i++) {
//         if (allocator.slabs[i].object_size == size &&
//             allocator.slabs[i].free_objects > 0) {
//             slab = &allocator.slabs[i];
//             break;
//         }
//     }

//     // 如果没有合适的 slab，创建一个新的
//     if (slab == NULL) {
//         if (allocator.slab_count >= MAX_SLABS) {
//             return NULL;  // 超出 slab 数量限制
//         }
//         slab = &allocator.slabs[allocator.slab_count++];
//         slab->page = alloc_page();
//         slab->object_size = size;
//         slab->free_list = slab->page;
//         slab->free_objects = PAGE_SIZE / size;

//         // 初始化 free_list
//         for (int i = 0; i < slab->free_objects - 1; i++) {
//             void *obj = (char *)slab->page + i * size;
//             *(void **)obj = (char *)obj + size;
//         }
//         *(void **)((char *)slab->page + (slab->free_objects - 1) * size) = NULL;
//     }

//     // 从 free_list 中分配一个对象
//     void *obj = slab->free_list;
//     slab->free_list = *(void **)obj;
//     slab->free_objects--;
//     return obj;
// }

// // 释放对象，将其归还到 slab 的 free_list 中
// void slub_free(void *obj, size_t size) {
//     struct slab *slab = NULL;
//     for (int i = 0; i < allocator.slab_count; i++) {
//         if (allocator.slabs[i].object_size == size &&
//             obj >= allocator.slabs[i].page &&
//             obj < (char *)allocator.slabs[i].page + PAGE_SIZE) {
//             slab = &allocator.slabs[i];
//             break;
//         }
//     }

//     if (slab != NULL) {
//         *(void **)obj = slab->free_list;
//         slab->free_list = obj;
//         slab->free_objects++;
//     }
// }

// // 初始化分配器
// void slub_allocator_init() {
//     allocator.slab_count = 0;
//     memset(allocator.slabs, 0, sizeof(allocator.slabs));
// }

// slub_check(void) {
    
// }







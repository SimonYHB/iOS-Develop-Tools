//
//  AppCallCollecter.m
//  AppCallCollecter
//
//  Created by 叶煌斌 on 2020/4/10.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "AppCallCollecter.h"
#import <dlfcn.h>
#import <libkern/OSAtomicQueue.h>
#import <pthread.h>




static OSQueueHead qHead = OS_ATOMIC_QUEUE_INIT;
static BOOL stopCollecting = NO;

typedef struct {
    void *pointer;
    void *next;
} PointerNode;

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                         uint32_t *stop) {
    static uint32_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
        *x = ++N;  // Guards should start from 1.
}

// This callback is inserted by the compiler on every edge in the
// control flow (some optimizations apply).
// Typically, the compiler will emit the code like this:
//    if(*guard)
//      __sanitizer_cov_trace_pc_guard(guard);
// But for large functions it will emit a simple call:
//    __sanitizer_cov_trace_pc_guard(guard);
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    // If initialization has not occurred yet (meaning that guard is uninitialized), that means that initial functions like +load are being run. These functions will only be run once anyways, so we should always allow them to be recorded and ignore guard
    if (stopCollecting) {
        return;
    }
    // If you set *guard to 0 this code will not be called again for this edge.
    // Now you can get the PC and do whatever you want:
    //   store it somewhere or symbolize it and print right away.
    // The values of `*guard` are as you set them in
    // __sanitizer_cov_trace_pc_guard_init and so you can make them consecutive
    // and use them to dereference an array or a bit vector.
    *guard = 0;
    // __builtin_return_address 获取当前调用栈信息，取第一帧地址
    void *PC = __builtin_return_address(0);
    PointerNode *node = malloc(sizeof(PointerNode));
    *node = (PointerNode){PC, NULL};
    OSAtomicEnqueue(&qHead, node, offsetof(PointerNode, next));

    
}

extern NSArray <NSString *> *getAllFunctions(NSString *currentFuncName) {
    NSMutableSet<NSString *> *unqSet = [NSMutableSet setWithObject:currentFuncName];
    NSMutableArray <NSString *> *functions = [NSMutableArray array];
    while (YES) {
        PointerNode *front = OSAtomicDequeue(&qHead, offsetof(PointerNode, next));
        if(front == NULL) {
            break;
        }
        Dl_info info = {0};
        // dladdr获取地址符号信息
        dladdr(front->pointer, &info);
        NSString *name = @(info.dli_sname);
        if([unqSet containsObject:name]) {
            continue;
        }
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString *symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        [unqSet addObject:name];
        [functions addObject:symbolName];
    }
    return [[functions reverseObjectEnumerator] allObjects];;

}

#pragma mark - public

extern NSArray <NSString *> *getAppCalls(void) {
    
    stopCollecting = YES;
    // 内存屏障，防止cpu的乱序执行调度内存（原子锁）
    __sync_synchronize();
    NSString* curFuncationName = [NSString stringWithUTF8String:__FUNCTION__];
    return getAllFunctions(curFuncationName);
}




extern void appOrderFile(void(^completion)(NSString* orderFilePath)) {
    
    stopCollecting = YES;
    __sync_synchronize();
   NSString* curFuncationName = [NSString stringWithUTF8String:__FUNCTION__];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *functions = getAllFunctions(curFuncationName);
        NSString *orderFileContent = [functions.reverseObjectEnumerator.allObjects componentsJoinedByString:@"\n"];
        NSLog(@"[orderFile]: %@",orderFileContent);
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"orderFile.order"];
        [orderFileContent writeToFile:filePath
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];
        if(completion){
            completion(filePath);
        }
    });
}



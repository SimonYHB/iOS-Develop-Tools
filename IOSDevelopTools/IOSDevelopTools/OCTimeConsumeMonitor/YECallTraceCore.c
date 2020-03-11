//
//  YECallTraceCore.c
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/10.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#include "YECallTraceCore.h"
#include <stdlib.h>
#include <dispatch/dispatch.h>
#include <pthread.h>
#include "fishhook.h"
#include <objc/runtime.h>
#include <sys/time.h>

#ifndef __arm64__
void startMonitor(void) {};
void stopMonitor(void) {};
YEThreadCallRecord *getThreadCallRecord(int *count){
    return NULL;
}
void setMaxDepth(int depth) {};
void setMinConsumeTime(uint64_t time) {};
bool callTraceEnable() { return false };
#else
//用于记录方法
typedef struct {
    Class cls;
    SEL sel;
    uint64_t time;
    uintptr_t lr; // lr寄存器内的地址值
} MethodRecord;

//主线程方法调用栈
typedef struct {
    MethodRecord *stack;
    int allocCount; //栈内最大可放元素个数
    int index; //当前方法的层级
    bool isMainThread;
} ThreadMethodStack;


static id (*orgin_objc_msgSend)(id, SEL, ...);
static pthread_key_t threadStackKey;
static bool monitorEnabled = false;

static YEThreadCallRecord *threadCallRecords = NULL;
static int recordsCurrentCount;
static int recordsAllocCount;

static int maxDepth = 3; // 设置记录的最大层级
static uint64_t minConsumeTime = 1000; // 设置记录的最小耗时



#pragma mark - private
// 获取当前线程的调用栈
ThreadMethodStack* getThreadMethodStack() {
    
    ThreadMethodStack *tms = (ThreadMethodStack *)pthread_getspecific(threadStackKey);
    if (tms == NULL) {
        tms = (ThreadMethodStack *)malloc(sizeof(ThreadMethodStack));
        tms->stack = (MethodRecord *)calloc(128, sizeof(MethodRecord));
        tms->allocCount = 64;
        tms->index = -1;
        tms->isMainThread = pthread_main_np();
        pthread_setspecific(threadStackKey, tms);
    }
    return tms;
}

// 线程私有数据的清除函数
void cleanThreadStack(void *ptr) {
    if (ptr != NULL) {
        ThreadMethodStack *threadStack = (ThreadMethodStack *)ptr;
        if (threadStack->stack) {
            free(threadStack->stack);
        }
        free(threadStack);
    }
}

void before_objc_msgSend(id self, SEL _cmd, uintptr_t lr) {
    ThreadMethodStack *tms = getThreadMethodStack();
    if (tms) {
        int nextIndex = (++tms->index);
        if (nextIndex >= tms->allocCount) {
            tms->allocCount += 64;
            tms->stack = (MethodRecord *)realloc(tms->stack, tms->allocCount * sizeof(MethodRecord));
        }
        MethodRecord *newRecord = &tms->stack[nextIndex];
        newRecord->cls = object_getClass(self);
        newRecord->sel = _cmd;
        newRecord->lr = lr;
        if (tms->isMainThread & monitorEnabled) {
            struct timeval now;
            gettimeofday(&now, NULL);
            newRecord->time = (now.tv_sec % 100) * 1000000 + now.tv_usec;
        }
    }
}

uintptr_t after_objc_msgSend() {
    ThreadMethodStack *tms = getThreadMethodStack();
    int curIndex = tms->index;
    int nextIndex = tms->index--;
    MethodRecord *record = &tms->stack[nextIndex];
    
    if (tms->isMainThread & monitorEnabled) {
        struct timeval now;
        gettimeofday(&now, NULL);
        uint64_t time = (now.tv_sec % 100) * 1000000 + now.tv_usec;
//        if (time < record->time) {
//            time += 100 * 1000000;
//        }
        uint64_t cost = time - record->time;
        if (cost > minConsumeTime * 1000 && curIndex < maxDepth) {
            // 为记录栈分配内存
            if (!threadCallRecords) {
                recordsAllocCount = 1024;
                threadCallRecords = malloc(sizeof(threadCallRecords) * recordsAllocCount);
            }
            recordsCurrentCount++;
            if (recordsCurrentCount >= recordsAllocCount) {
                recordsAllocCount += 1024;
                threadCallRecords = realloc(threadCallRecords, sizeof(threadCallRecords) * recordsAllocCount);
            }
            // 添加记录元素
            YEThreadCallRecord *yeRecord = &threadCallRecords[recordsCurrentCount - 1];
            yeRecord->cls = record->cls;
            yeRecord->depth = curIndex;
            yeRecord->sel = record->sel;
            yeRecord->time = cost;
        }
    }
    // 恢复下条指令
    return record->lr;
}

 //arm64标准：sp % 16 必须等于0
#define saveParameters() \
__asm volatile ( \
"str x8,  [sp, #-16]!\n" \
"stp x6, x7, [sp, #-16]!\n" \
"stp x4, x5, [sp, #-16]!\n" \
"stp x2, x3, [sp, #-16]!\n" \
"stp x0, x1, [sp, #-16]!\n");

#define loadParameters() \
__asm volatile ( \
"ldp x0, x1, [sp], #16\n" \
"ldp x2, x3, [sp], #16\n" \
"ldp x4, x5, [sp], #16\n" \
"ldp x6, x7, [sp], #16\n" \
"ldr x8,  [sp], #16\n" );

// 前置方法的返回值会储存在x8上，所以调用我们自己的方法前先保存下x8，接着将方法加载到x12中去执行指令
#define call(b, value) \
__asm volatile ("str x8, [sp, #-16]!\n"); \
__asm volatile ("mov x12, %0\n" :: "r"(value)); \
__asm volatile ("ldr x8, [sp], #16\n"); \
__asm volatile (#b " x12\n");

__attribute__((__naked__))
static void hook_objc_msgSend() {
    // 存原调用参数
    saveParameters()
    
    // 将lr存放的指令放在x2，作为before_objc_msgSend参数
    __asm volatile ("mov x2, lr\n");

    // Call our before_objc_msgSend.
    call(blr, &before_objc_msgSend)
    
    // 恢复参数
    loadParameters()
    
    // 调用objc_msgSend
    call(blr, orgin_objc_msgSend)
    

    saveParameters()
    
    // Call our after_objc_msgSend.
    call(blr, &after_objc_msgSend)
    
    // x0存的是after_objc_msgSend返回的下条指令，返回给lr指针
    __asm volatile ("mov lr, x0\n");
    
    // Load original objc_msgSend return value.
    loadParameters()
    
    // 返回
    __asm volatile ( "ret");
}


#pragma mark - public
void startMonitor(void) {
    monitorEnabled = true;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_key_create(&threadStackKey, cleanThreadStack);
        struct rebinding rebindObjc_msgSend;
        rebindObjc_msgSend.name = "objc_msgSend";
        rebindObjc_msgSend.replacement = hook_objc_msgSend;
        rebindObjc_msgSend.replaced = (void *)&orgin_objc_msgSend;
        struct rebinding rebs[1] = {rebindObjc_msgSend};
        rebind_symbols(rebs, 1);
    });
}
void stopMonitor(void) {
    monitorEnabled = false;
}
YEThreadCallRecord *getThreadCallRecord(int *count) {
    if (count) {
        *count = recordsCurrentCount;
    }
    return threadCallRecords;
}


void setMaxDepth(int depth)
{
    maxDepth = depth;
}

void setMinConsumeTime(uint64_t time)
{
    minConsumeTime = time;
}

bool callTraceEnable() {
    return monitorEnabled;
}


#endif

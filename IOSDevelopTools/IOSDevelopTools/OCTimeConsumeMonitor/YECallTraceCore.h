//
//  YECallTraceCore.h
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/10.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#ifndef YECallTraceCore_h
#define YECallTraceCore_h

#include <stdio.h>
#include <objc/objc.h>

typedef struct {
    __unsafe_unretained Class cls;
    SEL sel;
    uint64_t time; // us (1/1000 ms)
    int depth;
} YEThreadCallRecord;


/**
 开启OC耗时监控
 */
void startMonitor(void);

/**
 停止OC耗时监控
 */
void stopMonitor(void);

/**
 获取调用记录堆栈
 
 @param count 返回栈元素个数
 */
YEThreadCallRecord *getThreadCallRecord(int *count);

/**
 设置最大记录层级 (默认3层)
 */
void setMaxDepth(int depth); // 默认3层

/**
 设置最小记录耗时 (默认1000ms)
 */
void setMinConsumeTime(uint64_t time); // 默认1000ms

/**
 清空调用栈
 */
void clearCallRecords(void);
bool callTraceEnable(void);


#endif /* YECallTraceCore_h */

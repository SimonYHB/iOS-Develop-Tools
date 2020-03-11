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

void startMonitor(void);
void stopMonitor(void);
YEThreadCallRecord *getThreadCallRecord(int *count);
void setMaxDepth(int depth); // 默认3层
void setMinConsumeTime(uint64_t time); // 默认1000ms

/**
 清空调用栈
 */
void clearCallRecords(void);
bool callTraceEnable(void);


#endif /* YECallTraceCore_h */

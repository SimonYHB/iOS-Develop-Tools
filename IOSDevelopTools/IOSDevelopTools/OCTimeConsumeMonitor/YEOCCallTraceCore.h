//
//  YEOCCallTraceCore.h
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/10.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#ifndef YEOCCallTraceCore_h
#define YEOCCallTraceCore_h

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
YEThreadCallRecord *getThreadCallRecord(void);

//void setMaxDepth(int depth);
//void setCostMinTime(uint64_t time);

#endif /* YEOCCallTraceCore_h */

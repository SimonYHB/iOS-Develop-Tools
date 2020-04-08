//
//  YECallMonitor.h
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/4/8.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YECallMonitor : NSObject

+ (instancetype)shareInstance;
/**
 开启OC耗时监控
 */
- (void)start;

/**
 停止OC耗时监控
 */
- (void)stop;

/**
 获取调用记录堆栈
 */
- (NSArray *)getThreadCallRecord;
//YEThreadCallRecord *getThreadCallRecord(int *count);

/**
 设置最大记录层级 (默认3层)
 */
- (void)setDepth:(int) depth;

/**
 设置最小记录耗时 (默认1000ms)
 */
- (void)setMinTime:(uint64_t) time; // 默认1000ms

/**
 清空调用栈
 */
- (void)clear;

- (bool)enable;

- (void)setFilterClassNames: (NSArray<NSString *> *)names;



@end

NS_ASSUME_NONNULL_END

//
//  YECallMonitor.m
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/4/8.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YECallMonitor.h"
#import "YECallTraceCore.h"
#import "YECallRecordModel.h"
#import "YECallRecordLevelModel.h"

@interface YECallMonitor()

@property (nonatomic, copy)NSMutableArray *ignoreClassArr;

@end
@implementation YECallMonitor

+ (instancetype)shareInstance {
    static YECallMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YECallMonitor alloc] init];
    });
    return instance;
}

- (void)start {
    startMonitor();
}


- (void)stop {
    stopMonitor();
}


- (NSArray *)getThreadCallRecord {
    int count = 0;
    YEThreadCallRecord *mainThreadCallRecord = getThreadCallRecord(&count);
    if (mainThreadCallRecord==NULL) {
        NSLog(@"=====================================");
        NSLog(@"没有捕抓到符号耗时要求的方法");
        NSLog(@"=====================================");
        return @[];
    }
    NSMutableString *textM = [[NSMutableString alloc] init];
    NSMutableArray *allMethodRecord = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int i = 0, j;
        while (i < count) {
            NSMutableArray *methodRecord = [NSMutableArray array];
            for (j = i; j <= count;j++)
            {
                YEThreadCallRecord *callRecord = &mainThreadCallRecord[j];
                NSString *str = [self debug_getMethodCallStr:callRecord];
                [textM appendString:str];
                [textM appendString:@"\r"];
                [self setRecordDic:methodRecord record:callRecord];
                if (callRecord->depth==0 || j==count-1)
                {
                    NSArray *recordModelArr = [self recursive_getRecord:methodRecord];
                    recordModelArr = [self filterClass:recordModelArr];
                    if (recordModelArr.count > 0) {
                        YECallRecordLevelModel *model = [[YECallRecordLevelModel alloc] initWithRecordModelArr:recordModelArr];
                        [allMethodRecord addObject:model];
                    }
                    //退出循环
                    break;
                }
            }
            
            i = j+1;
        }
        
        [self debug_printMethodRecord:textM];
    });
    return allMethodRecord;
}
//YEThreadCallRecord *getThreadCallRecord(int *count);


- (void)setDepth:(int) depth {
    setMaxDepth(depth);
}
- (void)setMinTime:(uint64_t) time {
    setMinConsumeTime(time);
}


- (void)clear {
    clearCallRecords();
}

- (bool)enable {
    return callTraceEnable();
}


- (void)setFilterClassNames: (NSArray<NSString *> *)names {
    
    for (NSString *name in names) {
        Class cls = NSClassFromString(name);
        if (![self.ignoreClassArr containsObject:cls]) {
            [self.ignoreClassArr addObject:cls];
        }
    }
}
#pragma private
- (NSUInteger)findStartDepthIndex:(NSUInteger)start arr:(NSArray *)arr
{
    NSUInteger index = start;
    if (arr.count > index) {
        YECallRecordModel *model = arr[index];
        int minDepth = model.depth;
        int minTotal = model.total;
        for (NSUInteger i = index+1; i < arr.count; i++) {
            YECallRecordModel *tmp = arr[i];
            if (tmp.depth < minDepth || (tmp.depth == minDepth && tmp.total < minTotal)) {
                minDepth = tmp.depth;
                minTotal = tmp.total;
                index = i;
            }
        }
    }
    return index;
}
                   
- (NSArray *)recursive_getRecord:(NSMutableArray *)arr
    {
    if ([arr isKindOfClass:NSArray.class] && arr.count > 0) {
        BOOL isValid = YES;
        NSMutableArray *recordArr = [NSMutableArray array];
        NSMutableArray *splitArr = [NSMutableArray array];
        NSUInteger index = [self findStartDepthIndex:0 arr:arr];
        if (index > 0) {
            [splitArr addObject:[NSMutableArray array]];
            for (int i = 0; i < index; i++) {
                [[splitArr lastObject] addObject:arr[i]];
            }
        }
        YECallRecordModel *model = arr[index];
        [recordArr addObject:model];
        [arr removeObjectAtIndex:index];
        int startDepth = model.depth;
        int startTotal = model.total;
        for (NSUInteger i = index; i < arr.count; ) {
            model = arr[i];
            if (model.total == startTotal && model.depth-1==startDepth) {
                [recordArr addObject:model];
                [arr removeObjectAtIndex:i];
                startDepth++;
                isValid = YES;
            }
            else
            {
                if (isValid) {
                    isValid = NO;
                    [splitArr addObject:[NSMutableArray array]];
                }
                [[splitArr lastObject] addObject:model];
                i++;
            }
            
        }
        
        for (NSUInteger i = splitArr.count; i > 0; i--) {
            NSMutableArray *sArr = splitArr[i-1];
            [recordArr addObjectsFromArray:[self recursive_getRecord:sArr]];
        }
        return recordArr;
    }
    return @[];
}
         
- (void)setRecordDic:(NSMutableArray *)arr record:(YEThreadCallRecord *)record
{
    if ([arr isKindOfClass:NSMutableArray.class] && record) {
        int total=1;
        for (NSUInteger i = 0; i < arr.count; i++)
        {
            YECallRecordModel *model = arr[i];
            if (model.depth == record->depth) {
                total = model.total+1;
                break;
            }
        }
        
        YECallRecordModel *model = [[YECallRecordModel alloc] initWithCls:record->cls sel:record->sel time:record->time depth:record->depth total:total];
        [arr insertObject:model atIndex:0];
    }
}
                   
- (NSMutableArray *)ignoreClassArr {
    if (_ignoreClassArr == nil || _ignoreClassArr.count == 0) {
        NSArray *initArr = @[
                             NSClassFromString(@"YECallTraceShowViewController"),
                             NSClassFromString(@"YECallRecordModel"),
                             NSClassFromString(@"YECallRecordLevelModel"),
                             NSClassFromString(@"YECallRecordCell"),
                             NSClassFromString(@"YECallMonitor")
                             ];

        _ignoreClassArr = [NSMutableArray arrayWithArray:initArr];
    }
    return _ignoreClassArr;
}

- (void)debug_printMethodRecord:(NSString *)text
{
    //记录的顺序是方法完成时间
    NSLog(@"=========printMethodRecord==Start================");
    NSLog(@"%@", text);
    NSLog(@"=========printMethodRecord==End================");
}

- (NSString *)debug_getMethodCallStr:(YEThreadCallRecord *)callRecord
{
    NSMutableString *str = [[NSMutableString alloc] init];
    double ms = callRecord->time/1000.0;
    [str appendString:[NSString stringWithFormat:@"　%d　|　%lgms　|　", callRecord->depth, ms]];
    if (callRecord->depth>0) {
        [str appendString:[[NSString string] stringByPaddingToLength:callRecord->depth withString:@"　" startingAtIndex:0]];
    }
    if (class_isMetaClass(callRecord->cls))
    {
        [str appendString:@"+"];
    }
    else
    {
        [str appendString:@"-"];
    }
    [str appendString:[NSString stringWithFormat:@"[%@　　%@]", NSStringFromClass(callRecord->cls), NSStringFromSelector(callRecord->sel)]];
    return str.copy;
}

- (NSArray *)filterClass:(NSArray *)orginalArr {
    NSArray *ignoreClassArr = self.ignoreClassArr;
    NSMutableArray *result = [NSMutableArray array];
    if ([orginalArr isKindOfClass:NSArray.class]) {
        int depth = 0;
        BOOL isIgnore = FALSE;
        for (YECallRecordModel *model in orginalArr) {
            if (isIgnore) {
                if (depth >= model.depth) {
                    isIgnore = [ignoreClassArr containsObject:model.cls];
                    depth = model.depth;
                }
            }
            else
            {
                isIgnore = [ignoreClassArr containsObject:model.cls];
                depth = model.depth;
            }
            if (!isIgnore) {
                [result addObject:model];
            }
        }
    }
    return result;
}
@end

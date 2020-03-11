//
//  YECallRecordLevelModel.m
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/11.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YECallRecordLevelModel.h"


@implementation YECallRecordLevelModel

- (instancetype)initWithRecordModelArr:(NSArray *)recordModelArr
{
    self = [super init];
    if (self) {
        if ([recordModelArr isKindOfClass:NSArray.class] && recordModelArr.count > 0) {
            self.rootMethod = recordModelArr[0];
            self.isExpand = YES;
            if (recordModelArr.count > 1) {
                self.subMethods = [recordModelArr subarrayWithRange:NSMakeRange(1, recordModelArr.count-1)];
            }
        }
    }
    return self;
}

- (YECallRecordModel *)getRecordModel:(NSInteger)index
{
    if (index==0) {
        return self.rootMethod;
    }
    return self.subMethods[index-1];
}

- (id)copyWithZone:(NSZone *)zone
{
    YECallRecordLevelModel *model = [[[self class] allocWithZone:zone] init];
    model.rootMethod = self.rootMethod;
    model.subMethods = self.subMethods;
    model.isExpand = self.isExpand;
    return model;
}

@end

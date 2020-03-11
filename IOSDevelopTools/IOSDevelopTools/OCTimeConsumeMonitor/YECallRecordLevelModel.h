//
//  YECallRecordLevelModel.h
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/11.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YECallRecordModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface YECallRecordLevelModel : NSObject <NSCopying>

@property (nonatomic, strong)YECallRecordModel *rootMethod;
@property (nonatomic, copy)NSArray *subMethods;
@property (nonatomic, assign)BOOL isExpand;   //是否展开所有的子函数

- (instancetype)initWithRecordModelArr:(NSArray *)recordModelArr;
- (YECallRecordModel *)getRecordModel:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

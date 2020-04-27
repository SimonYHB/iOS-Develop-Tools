//
//  NSString+YEUtil.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "NSString+YEUtil.h"

@implementation NSString (YEUtil)
//替换从开始位置第一个匹配的目标字符串
- (NSString *)stringByReplacingFirstOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
    //容错
    if (target == nil || [target isKindOfClass:[NSString class]] == NO || target.length == 0 ||
        replacement == nil || [replacement isKindOfClass:[NSString class]] == NO)
    {
        return self;
    }
    
    //获取从开始第一个匹配的Range（默认区分大小写）
    NSRange firstRange = [self rangeOfString:target];
    if (firstRange.length == 0)
    {
        return self;
    }
    
    //替换第一个匹配的目标字符串
    return [self stringByReplacingCharactersInRange:firstRange withString:replacement];
}
@end

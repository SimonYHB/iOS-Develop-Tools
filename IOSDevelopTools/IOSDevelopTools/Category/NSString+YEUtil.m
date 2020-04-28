//
//  NSString+YEUtil.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "NSString+YEUtil.h"
#import <arpa/inet.h>
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


- (BOOL)isIPAddressString
{
    //容错
    if (self == nil || self.length == 0)
    {
        return NO;
    }
    //执行判断
    int success;
    struct in_addr dst;
    struct in6_addr dst6;
    const char *utf8 = [self UTF8String];
    success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    if (success == NO)
    {
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    return success;
}
@end

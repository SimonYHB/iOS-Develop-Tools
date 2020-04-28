//
//  NSData+YEUtil.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/28.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "NSData+YEUtil.h"

@implementation NSData (YEUtil)
//JSON数据转对象
- (id)objectFromJSONData
{
    return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:nil];
}
@end

//
//  YEDNSEntity.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YEDNSEntity.h"

@implementation YEDNSEntity
- (instancetype)init
{
    if ((self = [super init]))
    {
        self.domain = @"";
    }
    return self;
}

//当字典转实体时，如果字典中的字段和实体属性名称不一致或者结构不一致，可以在此方法做特殊化处理
- (void)customTransformEntityFromDictionary:(NSDictionary*)sourceDict
{
    //容错处理
    if (sourceDict == nil || [sourceDict isKindOfClass:[NSDictionary class]] == NO)
    {
        return;
    }
    
    //处理ips字段
    if (sourceDict[@"ips"] && [sourceDict[@"ips"] isKindOfClass:[NSArray class]]) {
        self.ipArray = [[NSMutableArray alloc] initWithArray:sourceDict[@"ips"]];
    }

}
@end

//
//  YEDNSEntity.h
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YEDNSEntity : NSObject

@property (nonatomic, strong) NSString *domain;       //原始域名
//@property (nonatomic, strong) NSString *cdn;          //是否是CDN域名
//@property (nonatomic, strong) NSString *sourceDomain; //收敛域名，CDN使用
@property (nonatomic, strong) NSMutableArray *ips;          //IP列表

@end

NS_ASSUME_NONNULL_END

//
//  NSString+YEUtil.h
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (YEUtil)

/**
 替换目标字符串

 @param target 被替换的字符
 @param replacement 替换成的字符
 @return 替换后完整的字符串
 */
- (NSString *)stringByReplacingFirstOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

@end

NS_ASSUME_NONNULL_END

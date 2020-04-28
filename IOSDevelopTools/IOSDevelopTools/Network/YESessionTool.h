//
//  YESessionTool.h
//  IOSDevelopTools
//
//  Created by SimonYHB on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YESessionManager.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^YESessionToolCallBack)(YESessionManager *sessionManager);

@interface YESessionTool : NSObject
+ (nonnull instancetype)shareInstance;

- (void)getSessionManagerWithRequest:(NSURLRequest *)request
                            callBack:(YESessionToolCallBack)callBack;

@end

NS_ASSUME_NONNULL_END

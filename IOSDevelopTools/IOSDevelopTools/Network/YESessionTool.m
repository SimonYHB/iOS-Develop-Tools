//
//  YESessionTool.m
//  IOSDevelopTools
//
//  Created by SimonYHB on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YESessionTool.h"

@interface YESessionTool ()
@property (nonatomic, strong)NSMutableDictionary *sessionDict;

@end


@implementation YESessionTool
+ (nonnull instancetype)shareInstance {
    static YESessionTool *instance = nil;
    static dispatch_once_t onceToken;
    if (!instance) {
        dispatch_once(&onceToken, ^{
            instance = [[YESessionTool alloc] init];
        });
    }
    
    return instance;
}

- (void)getSessionManagerWithRequest:(NSURLRequest *)request
                            callBack:(YESessionToolCallBack)callBack {
    // 本地资源单独处理
    if (![request.URL.absoluteString hasPrefix:@"http"]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        YESessionManager *manager = [[YESessionManager alloc] initWithSessionConfiguration:config];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        if (manager) {
            callBack(manager);
        }
        return;
    }
    // 网络请求
    YESessionManager *cacheManager = [self.sessionDict objectForKey:request.URL.host];
    if (cacheManager == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        cacheManager = [[YESessionManager alloc] initWithSessionConfiguration:config];
        cacheManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // TODO: 设置网络安全策略
    //    self setPolicy...
        
        [self.sessionDict setObject:cacheManager forKey:request.URL.host];
    }
    
    if (callBack) {
        callBack(cacheManager);
    }
    return;
    
    
    
    

}

@end

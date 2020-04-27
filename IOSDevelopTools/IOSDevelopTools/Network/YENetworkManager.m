//
//  YENetworkManager.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/26.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YENetworkManager.h"
#import "AFNetworking.h"
@implementation YENetworkManager
#pragma mark - Public
+ (nonnull instancetype)shareInstance {
    static YENetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    if (!instance) {
        dispatch_once(&onceToken, ^{
            instance = [[YENetworkManager alloc] init];
        });
    }
    
    return instance;
}


- (void)requestWithUrl:(NSString *)url
                  body:(NSDictionary *)paraDic
                method:(NSString *)method
               timeOut:(NSTimeInterval)timeoutInterval
               headers:(NSDictionary *)headersDic
              callBack:(YENetworkManagerResponseCallBack)callBack {
    // 参数异常处理
    if (url == nil || url.length == 0)
    {
        if (callBack)
        {
            NSDictionary *errorDic = [NSDictionary dictionaryWithObject:@"URL为空" forKey:@"message"];
            callBack(@{}, errorDic);
        }
        return;
    }
    if (method == nil || method.length == 0)
    {
        method = @"GET";
    }
    
    
}

#pragma mark - Private

- (AFHTTPSessionManager *)getHttpSessionManager:(NSDictionary *)configuration {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",@"text/plain", nil];
    // 设置configuration
    return manager;
}






//处理HTTP响应携带的Cookie并存储
+ (void)storageHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)url
{
    NSArray *cookieArray = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:url];
    if (cookieArray)
    {
        for (NSHTTPCookie *cookie in cookieArray)
        {
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            
            //删除httponly的cookie，防止写入失败
            for (NSHTTPCookie *storagedCookie in cookieStorage.cookies)
            {
                if (storagedCookie.isHTTPOnly && [cookie.name isEqualToString:storagedCookie.name] && [cookie.domain isEqualToString:storagedCookie.domain] && [cookie.path isEqualToString:storagedCookie.path])
                {
                    [cookieStorage deleteCookie:storagedCookie];
                    break;
                }
            }
            
            [cookieStorage setCookie:cookie];
        }
    }
}

//匹配本地Cookie存储，获取对应URL的请求cookie字符串
+ (NSString*)getCookieHeaderForRequestURL:(NSURL*)requestURL
{
    NSArray *availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:requestURL];
    if (availableCookies.count > 0)
    {
        NSDictionary *requestHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
        return [requestHeader objectForKey:@"Cookie"];
    }
    return nil;
}
@end

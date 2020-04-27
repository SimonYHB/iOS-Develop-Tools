//
//  YENetworkManager.m
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/26.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YENetworkManager.h"
#import "AFNetworking.h"
#import "YEDNSEntity.h"
#import <arpa/inet.h>
#import "NSString+YEUtil.h"
@interface YENetworkManager()

//CDNS数据请求使用的IP和Domain列表
//@property (nonatomic, strong) NSMutableArray *cdnsInterfaceIpList;
//@property (nonatomic, strong) NSMutableArray *cdnsInterfaceDomainList;


// dns实体缓存
@property (nonatomic, strong) NSMutableArray *dnsEntityListCache;

// DNS实体列表缓存同步锁
@property (nonatomic, strong) NSLock *dnsEntityListCacheLock;

@end
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
    
    // 序列化工具
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置超时时间
    requestSerializer.timeoutInterval = timeoutInterval < 0 ? 10 :timeoutInterval;
    // 设置请求头
    for (NSString *headerName in headersDic.allKeys)
    {
        NSString *headerValue = [headersDic objectForKey:headerName];
        [requestSerializer setValue:headerValue forHTTPHeaderField:headerName];
    }
    
    // 构建原始request
    NSURLRequest *originalRequest =  [requestSerializer requestWithMethod:method
                                                                 URLString:url
                                                                parameters:[paraDic count] == 0 ? nil : paraDic
                                                                     error:nil];
    if (originalRequest == nil) {
        NSDictionary *errorDic = [NSDictionary dictionaryWithObject:@"request异常" forKey:@"message"];
        callBack(@{}, errorDic);
        return;
    }
    // HTTPDNS处理
    NSURLRequest *ipRequest = [self transfromHTTPDNSRequest:originalRequest];
    
    // SessionManager
    
}

#pragma mark - Private


// HTTPDNS转换
- (NSURLRequest *)transfromHTTPDNSRequest:(NSURLRequest *)request {
    if ([self supportHTTPDNS:request]) {
        YEDNSEntity *entity = [self queryDNSEntityWithDomain:request.URL.host];
        if (entity == nil) {
            return request;
        }
        // 创建ip请求
        NSMutableURLRequest *newURLRequest = request.mutableCopy;
        NSString *ipAddress = nil;
        if (entity.ipArray && entity.ipArray.count > 0 && (ipAddress = entity.ipArray.firstObject))
        {
            //原始host替换为IP
            NSString *originalHost = request.URL.host;
            NSString *newUrlString = [newURLRequest.URL.absoluteString stringByReplacingFirstOccurrencesOfString:originalHost withString:ipAddress];
            newURLRequest.URL = [NSURL URLWithString:newUrlString];
            
            //添加host头部
            NSString *realHost = originalHost;
            [newURLRequest setValue:realHost forHTTPHeaderField:@"host"];
            
            //添加原始域名对应的Cookie
            NSString *cookie = [self getCookieHeaderForRequestURL:request.URL];
            if (cookie)
            {
                [newURLRequest setValue:cookie forHTTPHeaderField:@"Cookie"];
            }
        }
        return newURLRequest;
        
    }
    return request;
}

// 判断是否支持
- (BOOL)supportHTTPDNS:(NSURLRequest*)request {

    //无DNS数据不处理
    if (self.dnsEntityListCache.count == 0) {
        return NO;
    }

    //本地请求不处理
    if ([request.URL.scheme rangeOfString:@"http"].location == NSNotFound)
    {
        return NO;
    }


    //IP不处理
    if ([self isIPAddressString:request.URL.host])
    {
        return NO;
    }
    return YES;
}

//获取原始域名对应的DNS实体
- (YEDNSEntity*)queryDNSEntityWithDomain:(NSString*)originalDomain
{
    //加锁
    [self.dnsEntityListCacheLock lock];
    
    //查询缓存
    YEDNSEntity *resultEntity = nil;
    //yhb: 考虑用hash来缓存，减少遍历操作？
    for (YEDNSEntity *entity in self.dnsEntityListCache)
    {
        if ([entity.domain isEqualToString:originalDomain] && (entity.ipArray && entity.ipArray.count > 0)) {
            resultEntity = entity;
            break;
        }
    }
    
    //解锁
    [self.dnsEntityListCacheLock unlock];
    return resultEntity;
}



#pragma mark - Support
// 判断字符串是否为IP地址
- (BOOL)isIPAddressString:(NSString *)string
{
    //容错
    if (string == nil || [string isKindOfClass:[NSString class]] == NO || string.length == 0)
    {
        return NO;
    }
    //执行判断
    int success;
    struct in_addr dst;
    struct in6_addr dst6;
    const char *utf8 = [string UTF8String];
    success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    if (success == NO)
    {
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    return success;
}


- (AFHTTPSessionManager *)getHttpSessionManager:(NSDictionary *)configuration {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",@"text/plain", nil];
    // 设置configuration
    return manager;
}






//处理HTTP响应携带的Cookie并存储
- (void)storageHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)url
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
- (NSString*)getCookieHeaderForRequestURL:(NSURL*)requestURL
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

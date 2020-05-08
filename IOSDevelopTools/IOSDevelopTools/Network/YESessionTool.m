//
//  YESessionTool.m
//  IOSDevelopTools
//
//  Created by SimonYHB on 2020/4/27.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "YESessionTool.h"
#import "NSString+YEUtil.h"

#define CerFile  @"xxx"

@interface YESessionTool ()
@property (nonatomic, strong)NSMutableDictionary *sessionDict;

@end


@implementation YESessionTool

#pragma mark - Public
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
        
        // 设置网络安全策略
        [self setSSLPolicy:cacheManager request:request];
        
        [self.sessionDict setObject:cacheManager forKey:request.URL.host];
    }
    
    if (callBack) {
        callBack(cacheManager);
    }
    return;
    
    
    
    

}

#pragma mark - Private
- (void)setSSLPolicy: (YESessionManager *)manager request:(NSURLRequest *)request {
    // 区分域名和ip请求
    if ([request.URL.host isIPAddressString]) {
        [self setIPNetPolicy:manager request:request];

    } else {
        [self setDomainNetPolicy:manager request:request];
    }
}

// 域名请求的证书校验设置
- (void)setDomainNetPolicy: (YESessionManager *)manager request:(NSURLRequest *)request {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.validatesDomainName = YES;
    securityPolicy.allowInvalidCertificates = YES;
    // 从本地获取cer证书，仅作参考
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:CerFile ofType:@"cer"];
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    securityPolicy.pinnedCertificates = [NSSet setWithObject:cerData];
    manager.securityPolicy = securityPolicy;
    
}

// IP请求的证书校验设置
- (void)setIPNetPolicy: (YESessionManager *)manager request:(NSURLRequest *)request {
    // 判断是否存在域名
    NSString *realDomain = [request.allHTTPHeaderFields objectForKey:@"host"];
    if (realDomain == nil || realDomain.length == 0) {
        //无域名不验证
        return;
    }
    // 通过客户端验证服务器信任凭证
    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        return [self handleReceiveAuthenticationChallenge:challenge credential:credential host:realDomain];
    }];
    [manager setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        return [self handleReceiveAuthenticationChallenge:challenge credential:credential host:realDomain];
    }];
}


// 处理认证请求发生的回调
- (NSURLSessionAuthChallengeDisposition)handleReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
                                                       credential:(NSURLCredential**)credential
                                                             host:(NSString*)host
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        //验证域名是否被信任
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host])
        {
            *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (*credential)
            {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else
            {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }
        else
        {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    else
    {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    return disposition;
}

//验证域名
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.validatesDomainName = YES;
    securityPolicy.allowInvalidCertificates = YES;
    // 从本地获取cer证书,仅作参考
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:CerFile ofType:@"cer"];
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    securityPolicy.pinnedCertificates = [NSSet setWithObject:cerData];
    
    return [securityPolicy evaluateServerTrust:serverTrust forDomain:domain];
}
@end

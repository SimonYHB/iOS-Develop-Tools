//
//  YENetworkManager.h
//  IOSDevelopTools
//
//  Created by HuangBin Ye on 2020/4/26.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 请求后返回的block
 */
typedef void(^YENetworkManagerResponseCallBack)(NSDictionary *response, NSDictionary *error);



@interface YENetworkManager : NSObject

+ (nonnull instancetype)shareInstance;

/**
 *  网络请求
 *  @param url             请求地址
 *  @param paraDic         请求入参 {key: value}
 *  @param method          请求类型 GET|POST
 *  @param timeoutInterval 请求超时时间
 *  @param headersDic      请求头 {key: value}
 *  @param callBack        请求结果回调
 */
- (void)requestWithUrl:(NSString *)url
                  body:(NSDictionary *)paraDic
                method:(NSString *)method
               timeOut:(NSTimeInterval)timeoutInterval
               headers:(NSDictionary *)headersDic
              callBack:(YENetworkManagerResponseCallBack)callBack;

@end

NS_ASSUME_NONNULL_END

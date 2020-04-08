//
//  UIWindow+YECallTraceShake.m
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/11.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import "UIWindow+YECallTraceShake.h"
#import "YECallMonitor.h"
#import "YECallTraceShowViewController.h"
@implementation UIWindow (YECallTraceShake)
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    YECallMonitor *monitor = [YECallMonitor shareInstance];
    if ([monitor enable]){
        if ([monitor getThreadCallRecord]) {
            YECallTraceShowViewController *vc = [[YECallTraceShowViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.rootViewController presentViewController:vc animated:YES completion:nil];
        } else {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"未发现超过设置最大耗时的调用方法" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * cancleBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:cancleBtn];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        }
    }
}
@end

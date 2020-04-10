//
//  AppCallCollecter.h
//  AppCallCollecter
//
//  Created by 叶煌斌 on 2020/4/10.
//  Copyright © 2020 SimonYe. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AppCallCollecter.
FOUNDATION_EXPORT double AppCallCollecterVersionNumber;

//! Project version string for AppCallCollecter.
FOUNDATION_EXPORT const unsigned char AppCallCollecterVersionString[];


/// 与CLRAppOrderFile只能二者用其一
extern NSArray <NSString *> *getAppCalls(void);


/// 与getAppCalls只能二者用其一
extern void appOrderFile(void(^completion)(NSString* orderFilePath));

// In this header, you should import all the public headers of your framework using statements like #import <AppCallCollecter/PublicHeader.h>



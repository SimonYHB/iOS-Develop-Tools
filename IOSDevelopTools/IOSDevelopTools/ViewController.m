//
//  ViewController.m
//  IOSDevelopTools
//
//  Created by 叶煌斌 on 2020/3/10.
//  Copyright © 2020 叶煌斌. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(test)];
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
//    [self test];
}
- (void) test2 {
    for (int i = 0; i<= 10000; i++) {
        NSLog(@"test2--> call");
    }
}

- (void)test1 {
    for (int i = 0; i<= 10000; i++) {
        NSLog(@"test1--> call");
    }
    [self test2];
}

- (void)test {
    for (int i = 0; i<= 10000; i++) {
        NSLog(@"test--> call");
    }
    [NSThread sleepForTimeInterval:2];
    [self test1];
}


@end

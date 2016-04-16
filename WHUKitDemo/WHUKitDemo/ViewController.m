//
//  ViewController.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "ViewController.h"
#import "WHULiveKeeper.h"

@interface MyClass : NSObject

@end

@implementation MyClass

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_apply(1000000, dispatch_get_global_queue(0, 0), ^(size_t index) {
        MyClass *instance = [WHULiveKeeper sharedInstanceWithClass:[MyClass class]];
        if (index == 1 || index >=999999)
        NSLog(@"%zu -- %@\n", index, instance);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "ViewController.h"
#import "WHUKit.h"

@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    void (^buryBlock1)() = ^{
        NSLog(@"this is bury task");
    };
    void (^buryBlock2)() = ^{
        NSLog(@"this is bury task");
    };
    void (^buryBlock3)() = ^{
        NSLog(@"this is bury task");
    };

    
    [WHUBuryCenter addBuryTask:buryBlock1 target:self];
    [WHUBuryCenter addBuryTask:buryBlock2 target:self];
    [WHUBuryCenter addBuryTask:buryBlock3 target:self];

}


- (void)dealloc
{
    HSLogTrace();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

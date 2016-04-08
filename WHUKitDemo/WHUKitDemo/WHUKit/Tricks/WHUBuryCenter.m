//
//  WHUBuryExecuter.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "WHUBuryCenter.h"
#import "WHUMacro.h"
#import <objc/runtime.h>

/**
 *  葬送师
 *  协助BuryCenter完成对象dealloc时的操作
 *  葬送师与濒死者为0..1 - 1关系
 */
@interface WHUBuryMan : NSObject


/**
 *  存放本葬送师要执行的任务清单
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, void (^)()>  *tasks;

@end

@implementation WHUBuryMan

- (instancetype) init {
    if (self = [super init]) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) dealloc {
    [_tasks enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, void (^ _Nonnull task)() , BOOL * _Nonnull stop) {
        task();
    }];
}

@end


static void * kBuryManKey;

@implementation WHUBuryCenter

+ (void) addBuryTask:(void (^)()) buryTask  target:(id) suspect {
    WHUBuryMan *buryMan = objc_getAssociatedObject(suspect, kBuryManKey);
    if (!buryMan) {
        buryMan = [[WHUBuryMan alloc] init];
        objc_setAssociatedObject(suspect, kBuryManKey, buryMan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSString *taskKey = [NSString stringWithFormat:@"%@", buryTask];
    if ([buryMan.tasks valueForKey:taskKey]) {
        HSLog(@"请勿重复添加相同的任务");
    } else {
        [buryMan.tasks setValue:[buryTask copy] forKey:taskKey];
    }
    
}



@end

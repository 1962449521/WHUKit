//
//  WHULiveKeeper.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "WHULiveKeeper.h"
#import <libkern/OSAtomic.h>  

@implementation WHULiveKeeper {
    NSMutableDictionary *singleton_list;
}

WHU_SYNTHESIZE_SINGLETON_FOR_CLASS(WHULiveKeeper)

+ (id) sharedInstanceWithClass:(Class) clazz {
    WHULiveKeeper *keeper = [WHULiveKeeper sharedInstance];
    return [keeper sharedInstanceWithClass:clazz];
}

- (id) sharedInstanceWithClass:(Class) clazz {
    if (!singleton_list) {
        singleton_list = [NSMutableDictionary dictionary];
    }
    static dispatch_semaphore_t semaphore;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    
    NSString *className = NSStringFromClass(clazz);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    __block id instance = [singleton_list objectForKey:className];
    if(!instance) {
        instance = [clazz new];
        if (instance) {
            [singleton_list setObject:instance forKey:className];
        }
    }
    dispatch_semaphore_signal(semaphore);
    return instance;
}

@end

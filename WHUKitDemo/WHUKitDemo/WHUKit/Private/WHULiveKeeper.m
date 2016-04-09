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
    NSMutableDictionary *_singleton_list;
    dispatch_semaphore_t _semaphore;
}

WHU_SYNTHESIZE_SINGLETON_FOR_CLASS(WHULiveKeeper)

- (instancetype)init {
    if (self = [super init]) {
        _singleton_list = [NSMutableDictionary dictionary];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

+ (id) sharedInstanceWithClass:(Class) clazz {
    WHULiveKeeper *keeper = [WHULiveKeeper sharedInstance];
    return [keeper sharedInstanceWithClass:clazz];
}

- (id) sharedInstanceWithClass:(Class) clazz {
    NSString *className = NSStringFromClass(clazz);
    id instance_check = [_singleton_list objectForKey:className];
    if(!instance_check) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        id instance_recheck = [_singleton_list objectForKey:className];
        if (!instance_recheck) {
            id newInstance = [clazz new];
            if (newInstance) {
                [_singleton_list setObject:newInstance forKey:className];
                dispatch_semaphore_signal(_semaphore);
                return newInstance;
            } else {
                dispatch_semaphore_signal(_semaphore);
                return nil;
            }
        } else {
            dispatch_semaphore_signal(_semaphore);
            return instance_recheck;
        }
    } else {
        return instance_check;
    }

}

@end

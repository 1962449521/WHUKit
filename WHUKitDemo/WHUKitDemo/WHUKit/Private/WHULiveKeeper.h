//
//  WHULiveKeeper.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHUMacro.h"

@interface WHULiveKeeper : NSObject

WHU_DECLARE_SINGLETON_FOR_CLASS(WHULiveKeeper)

+ (id) sharedInstanceWithClass:(Class) clazz;

@end

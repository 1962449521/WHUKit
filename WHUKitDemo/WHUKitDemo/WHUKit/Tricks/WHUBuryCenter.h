//
//  WHUBuryExecuter.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  善后所，下属多个葬送师
 *  提供一种非侵入机制，为任何实例不限次、不覆盖添加dealloc时的 【操作块】
 */
@interface WHUBuryCenter : NSObject

/**
 *  在suspect对象销毁时执行block任务
 *
 *  @param buryBlock 提供销毁 id suspect 时的操作
 */
+ (void) addBuryTask:(void (^)()) buryTask  target:(id) suspect;

@end

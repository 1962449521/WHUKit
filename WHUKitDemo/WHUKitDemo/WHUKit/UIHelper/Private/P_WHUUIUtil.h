//
//  P_WHUUIUtil.h
//  CornerViewDemo
//
//  Created by 胡 帅 on 16/4/7.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P_WHUUIUtil : NSObject

+ (UIViewController *) currentTopVC;

+ (UIWindow *) windowWithLabel:(NSString *)windowLabel;

+ (void) hideWindow:(UIWindow *)window;


@end

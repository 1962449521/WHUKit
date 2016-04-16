//
//  P_WHUUIUtil.m
//  CornerViewDemo
//
//  Created by 胡 帅 on 16/4/7.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "P_WHUUIUtil.h"

@interface P_WHUUIUtil()

+ (UIViewController *) p_findBestViewController:(UIViewController*)vc;

@end

@implementation P_WHUUIUtil

+ (UIViewController *) currentTopVC {
    return [self p_findBestViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *) p_findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [self p_findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0) {
            return [self p_findBestViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0) {
            return [self p_findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0) {
            return [self p_findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

+ (UIWindow *) windowWithLabel:(NSString *)windowLabel {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor clearColor];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.accessibilityLabel = windowLabel;
    return window;
}

+ (void) hideWindow:(UIWindow *)window {
    if (!window) {
        return;
    } else {
        [window endEditing:YES];
        window.rootViewController = nil;
        window.hidden = YES;
    }
}

@end

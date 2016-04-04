//
//  WHUFunctions.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <objc/runtime.h>
#import "WHUMethodSwizzling.h"
#import "WHUMacro.h"

void WHUSwizzleMethods(SEL oriSelector, SEL fakeSelector, Class oriClazz,...) {
    
    Class fakeClazz = oriClazz;
    if ( ![fakeClazz instancesRespondToSelector:fakeSelector]) {
        va_list argp;
        va_start(argp, oriClazz);
        fakeClazz = (Class)va_arg( argp, Class);
        va_end( argp );
    }

    Method oriMethod = class_getInstanceMethod(oriClazz, oriSelector);
    Method newMethod = class_getInstanceMethod(fakeClazz, fakeSelector);

    // MARK: 本级以及下行继承线 “之外” 的继承线均不受影响
    if (class_addMethod(oriClazz, oriSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        // branch reason: 如果只做简单替换，父类及其它兄弟继承线全部受影响
        class_replaceMethod(oriClazz, fakeSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        // branch reason: 如果oriSelector实现来自本级，上个branch将不被执行
        method_exchangeImplementations(oriMethod, newMethod);
    }
}


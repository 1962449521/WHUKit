//
//  WHUFunctions.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <objc/runtime.h>
#import "WHUMethodSwizzling.h"

void WHUSwizzleMethods(Class clazz, SEL oriSelector, SEL newSelector) {
    Method oriMethod = class_getClassMethod(clazz, oriSelector);
    Method newMethod = class_getClassMethod(clazz, newSelector);
    
    // MARK: 本级以及下行继承线 “之外” 的继承线均不受影响
    if (class_addMethod(clazz, oriSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        // branch reason: 如果只做简单替换，父类及其它兄弟继承线全部受影响
        class_replaceMethod(clazz, newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        // branch reason: 如果oriSelector实现来自本级，上个branch将不被执行
        method_exchangeImplementations(oriMethod, newMethod);
    }
}


//
//  WHUFunctions.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  替换某方法，可以是实例方法，类方法，也可以是两个类之间的方法调换
 *  @IMPORTANT 使用者需自我保证传入的两个SEL都是可以查找到的，本方法不提供容错
 *  @IMPORTANT 当用于替换的fakeSelector不在oriClazz的method list里时，默认由可变参数fakeClazz提供
 *
 *  @param oriSelector  原始选择子
 *  @param fakeSelector 将替换的选择子
 *  @param oriClazz     原始类
 *  @param ...          用于不同类之间方法替换时的第二个类
 */
void WHUSwizzleMethods(SEL oriSelector, SEL fakeSelector, Class oriClazz, ...);

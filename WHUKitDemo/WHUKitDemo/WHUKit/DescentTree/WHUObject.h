//
//  WHUObject.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/2.
//  Description: 1. 提供了由服务器参数字典（本地参数字典）运行时 实例化本地对象的通用方法
//               2. 提供了可继承的NSSecureCoding
//               3. 提供了可继承的深复制
//               4. 提供了可继承的isEqual和hash方法
//  NOTE: 1. 请注意适时重写local_serverKeyMapping | dicKey_ClassNameMapping | arrayName_ClassNameMapping | propertyName_structEncodingMapping | parsedServerDic 五个方法的实现， References NEPObject.m文件
//        2. 尽量不使用instanceWithLocalAttributes方法实例化对象
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHUObject:  NSObject<NSSecureCoding, NSCopying>

#pragma mark - 创建实例，本类主要功能

// 服务器属性字典实例化本地对象
+ (instancetype)instanceWithServerAttributes:(NSDictionary *)attributesDic;

// 本地属性字典实例化本地对象 不建议使用
+ (instancetype)instanceWithLocalAttributes:(NSDictionary *)attributesDic;

#pragma mark - 其它便捷方法

// 对象对应的字典
- (NSDictionary *)dictionary;

// 将字典映射为已有对象的属性更改
- (void) assignValueWithDictionary:(NSDictionary *) dictionary;

// 置nil或0所有属性
- (void) cleanSelf;


#pragma mark - 服务器返回预干预，例如修正类型， 需被子类重写

+ (NSDictionary *) parsedServerDic:(NSDictionary *) attributesDic;

#pragma mark - HTTPRespond字段名与属性名映射关系， 需被子类重写

// 如本地属性名与服务器参数名不同，子类应重写该方法
+ (NSDictionary *)local_serverKeyMapping;

// 如有自定义类对象作为字典属性的value, 子类应重写该方法
+ (NSDictionary*)dicKey_ClassNameMapping;

// 如有自定义对象数组，子类应重写该方法
+ (NSDictionary*)arrayName_ClassNameMapping;

// 如有结构体作为属性，子类应重写该方法
+ (NSDictionary *)propertyName_structEncodingMapping;


#pragma mark - 运行时转换干预， 需被子类重写
// 在字典转对象 或对象转字典时 对该字典中的属性名 均不做映射
+ (NSArray *) blacklist;



@end

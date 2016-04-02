//
//  WHUObject.m
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/2.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import "WHUObject.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark  - 私有方法声明
#pragma mark  -

@interface WHUObject()


#pragma mark  映射表与转换干预

// 整合继承线所有同名方法字典
+ (NSDictionary *) p_dictionaryToAllSuperLevel:(SEL)dicGenerator;
// 继承线的服务器字段与本地属性名映射字典
+ (NSDictionary *) p_local_serverKeyMapping;
// 本地的容器与元素的对应关系字典
+ (NSDictionary *) p_dicKeyOrArrayName_ClassNameMapping;
// 本地的属性名与结构体对应关系字典
+ (NSDictionary *) p_propertyName_structEncodingMapping;
// 判断propertyName是否在黑名单中以不做运行时转换
+ (BOOL) p_isInBlackList: (NSString *)propertyName;


#pragma mark  核心功能方法

// 新申请内存并创建实例对像
+ (instancetype) p_objectFromAttributes:(NSDictionary *)serverAttributesDic fakeServer:(BOOL)isLocalFake;

// 与上个方法功能相近，区别在于不主动申请内存，入参包含已申请内存的对象
+ (instancetype) p_objectFromAttributes:(NSDictionary *)serverAttributesDic fakeServer:(BOOL)isLocalFake allocatedObject:(id)resultObject;

// 将服务器键值的某个结点子树转换成 本地对象属性的结点子树
+ (id) p_localValueWithServerKey:(NSString *)toBeCheckedServerKey andServerValue:(id)toBeCheckedServerValue  fakeServer:(BOOL)isLocalFake;

// 将服务器返回的非对象映射字典转换成本地字典的结点子树
+ (NSDictionary *) p_localDictionaryWithServerDictionary:(NSDictionary *)serverDictionary fakeServer:(BOOL)isLocalFake;

// 将服务器返回的数组转换成本地数组的结点子树
+ (NSArray *) p_localArrayWithServerArray:(NSArray *)serverArray withServerKey:(NSString *)serverKey fakeServer:(BOOL)isLocalFake;

// 根据本地属性名获取服务器字段名, 当isLocalFake为true时，表示此时服务器字典输入源由本地伪造，并不需检查映射
+ (NSString *) p_serverKeyWithLocalKey:(NSString *) localKey fakeServer:(BOOL)isLocalFake;

// 根据服务器字段名获取本地属性名
+ (NSString *) p_localKeyWithServerKey:(NSString *) serverKey;

// 获取本地对象的属性数组
+ (NSArray *) p_properties:(objc_property_t **)properties_p  propertyCount:(unsigned int *)propertyCount_p;

// 获取属性对应的类
+ (Class) p_classWithProperty:(objc_property_t)property;

#pragma  mark 调试信息支持

// 字典转字符串
- (NSString *) p_stringFromDictionary:(NSDictionary *) dic;

// 数组转字符串
- (NSString *) p_stringFromArray:(NSArray *) arr;

#pragma mark 协议实现支持
// 散列值
- (NSString *) p_hashStr;
@end






#pragma mark -  编码实现
#pragma mark -

@implementation WHUObject

#pragma mark -  主功能：服务器接口返回字典转换成本地对象

+ (instancetype) instanceWithServerAttributes:(NSDictionary *)attributesDic {
    return [self p_objectFromAttributes:attributesDic  fakeServer:NO];
}

+ (instancetype) instanceWithLocalAttributes:(NSDictionary *)attributesDic {
    return [self p_objectFromAttributes:attributesDic  fakeServer:YES];
}

#pragma mark - 其它便捷方法
#pragma mark  清理所有持有对象或被赋值

- (void) cleanSelf {
    @try {
        NSArray *properties = [[self class] p_properties:NULL propertyCount:NULL];
        for (NSString *value in properties) {
            NSString *strSetMethod = [NSString stringWithFormat:@"set%@%@:",[[value substringToIndex:1]capitalizedString], [value substringFromIndex:1]];
            SEL setMethod = NSSelectorFromString(strSetMethod);
            if ([self respondsToSelector:setMethod])
            {
                int (*actionB)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
                int (*actionN)(id, SEL, id) = (int (*)(id, SEL, id)) objc_msgSend;
                
                actionB(self, setMethod, 0);
                actionN(self, setMethod, nil);
            }
        }
        
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
}


#pragma mark  对象与字典转化

- (NSDictionary *)dictionary {
    NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
    NSArray *properties = [[self class] p_properties:NULL propertyCount:NULL];
    [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![[self class] p_isInBlackList:obj]) {
            id value = [self valueForKey:obj];
            [myDic setValue:value forKey:obj];
        }
    }];
    return myDic;
}

- (void) assignValueWithDictionary:(NSDictionary *) dictionary {
    [[self class] p_objectFromAttributes:dictionary fakeServer:NO allocatedObject:self];
}

#pragma mark - 由子类重写以支持特例
#pragma mark  服务器返回预干预，例如修正类型， 需被子类重写

+ (NSDictionary *) parsedServerDic:(NSDictionary *) attributesDic {
    return attributesDic;
}

#pragma mark  服务器字段与OC类名或属性名映射关系字典， 需被子类重写

+ (NSDictionary *) local_serverKeyMapping {
    // 如本地属性名与Response字段名不同，需重写该方法
    // server - "hongbaoId": 56
    // local  - OrderObject -> @property (nonatomic, copy) NSString bonusID;
    // -ict   - @{@"bonusID" : @"hongbaoId"}
    NSString *exampleServerKey = @"";
    return @{@"examplePropertyName" : exampleServerKey
             };
}

+ (NSDictionary *) dicKey_ClassNameMapping {
    //如有自定义类对象作为字典属性的Value, 子类应重写该方法
    // local  - @property (nonatomic, copy) NSDictionary * OrderDetail -> @{@"localAdressKey" : AddressClassName, ...}
    // dict   - @{@"localAdressKey" : @"AddressClassName"}
    
    NSString *exampleClassName = @"";
    return @{@"exampleDicKey" : exampleClassName,
             };
}

+ (NSDictionary *) arrayName_ClassNameMapping {
    // 如有自定义对象数组，子类应重写该方法
    // local  - @property (nonatomic, copy) NSArray * users -> @[UserClassName ...]
    // dict   - @{@"users" : @"UserClassName"}
    
    NSString *exampleClassName = @"";
    return @{@"exampleArrayName" : exampleClassName
             };
}

+ (NSDictionary *) propertyName_structEncodingMapping {
    // 如有结构体作为属性，子类应重写该方法
    // 一般不用，在此不做描述
    
    typedef struct exampleStruct{} exampleStruct;
    return @{@"examplePropertyName" : [NSString stringWithUTF8String:@encode(exampleStruct)]
             };
}

#pragma mark  属性过滤， 需被子类重写

+ (NSArray *) blacklist {
    return [NSArray array];
}



#pragma mark -  NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        objc_property_t * properties;
        unsigned int  propertyCount;
        NSArray *propertyNames = [[self class]p_properties:&properties propertyCount:&propertyCount];
        for (CFIndex curIndex = 0; curIndex < propertyCount; curIndex++) {
            objc_property_t property = properties[curIndex];
            Class class = [[self class] p_classWithProperty:property];
            NSString *key = propertyNames[curIndex];
            id object = [coder decodeObjectOfClass:class forKey:key];
            if (object) [self setValue:object forKey:key];
        }
        free(properties);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    objc_property_t * properties;
    unsigned int  propertyCount;
    NSArray *propertyNames = [[self class]p_properties:&properties propertyCount:&propertyCount];
    for (CFIndex curIndex = 0; curIndex < propertyCount; curIndex++) {
        objc_property_t property = properties[curIndex];
        NSString *key = propertyNames[curIndex];
        
        char *ivar = property_copyAttributeValue(property, "V");
        if (!ivar){
            free(ivar);
            continue;
        }
        free(ivar);
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
    free(properties);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone; {
    NSData *originData = [NSKeyedArchiver archivedDataWithRootObject:self];
    id copy = [NSKeyedUnarchiver unarchiveObjectWithData:originData];
    return copy;
}


#pragma mark - Description

#if DEBUG
- (NSString *) description {
    return [self debugDescription];
}

- (NSString *) debugDescription {
    return [NSString stringWithFormat:@"%@<%p>:%@", NSStringFromClass([self class]),self,
            [self p_stringFromDictionary:[self dictionary]]];
}
#endif


#pragma mark - isEqual

- (BOOL)isEqual:(id)object {
    return [[self dictionary] isEqual:[object dictionary]];
}

- (NSUInteger)hash {
    return [[self performSelector:@selector(p_hashStr)] hash];
}



#pragma mark - 私有方法
#pragma mark  映射字典及转换干预

// 整合继承线所有同名方法字典
+ (NSDictionary *) p_dictionaryToAllSuperLevel:(SEL)dicGenerator {
    id (*action)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
    id result = action([self class], dicGenerator);
    NSMutableDictionary *mappingDic = [NSMutableDictionary dictionaryWithDictionary:result];
    
    Class superClass = [self superclass];
    while (superClass != [WHUObject class]) {
        NSMutableDictionary *oldMappingDic = mappingDic;
        NSDictionary *superMappingDic = action(superClass, dicGenerator);
        mappingDic = [NSMutableDictionary dictionaryWithDictionary:superMappingDic];
        [mappingDic addEntriesFromDictionary:oldMappingDic];
        superClass = [superClass superclass];
    }
    return mappingDic;
}

// 继承线的服务器字段与本地属性名映射字典
+ (NSDictionary *) p_local_serverKeyMapping {
    return [self p_dictionaryToAllSuperLevel:@selector(local_serverKeyMapping)];
}

// 本地的容器与元素的对应关系字典
+ (NSDictionary *) p_dicKeyOrArrayName_ClassNameMapping {
    NSDictionary *propertyName_ClassNameMapping = [self p_dictionaryToAllSuperLevel:@selector(dicKey_ClassNameMapping)];
    NSDictionary *arrayName_ClassNameMapping = [self p_dictionaryToAllSuperLevel:@selector(arrayName_ClassNameMapping)];
    NSMutableDictionary *mergedDic = [NSMutableDictionary dictionaryWithDictionary:propertyName_ClassNameMapping];
    [mergedDic addEntriesFromDictionary:arrayName_ClassNameMapping];
    return [NSDictionary dictionaryWithDictionary:mergedDic];
}

// 本地的属性名与结构体对应关系字典
+ (NSDictionary *) p_propertyName_structEncodingMapping {
    return [self p_dictionaryToAllSuperLevel:@selector(propertyName_structEncodingMapping)];
}

// 判断propertyName是否在黑名单中以不做运行时转换
+ (BOOL) p_isInBlackList: (NSString *)propertyName {
    NSArray *list = [self blacklist];
    __block NSInteger found = -1;
    [list enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isEqualToString:propertyName]) {
            found = idx;
            *stop = YES;
        }
    }];
    return found != -1;
}

#pragma mark 核心方法

// 新申请内存并创建实例对像
+ (instancetype) p_objectFromAttributes:(NSDictionary *)serverAttributesDic fakeServer:(BOOL)isLocalFake {
    return [self p_objectFromAttributes:serverAttributesDic fakeServer:isLocalFake allocatedObject:nil];
}

// 从已分配内存的对象赋值得到新对象
+ (instancetype) p_objectFromAttributes:(NSDictionary *)serverAttributesDic fakeServer:(BOOL)isLocalFake allocatedObject:(id)resultObject {
    if (serverAttributesDic == nil
        || ![serverAttributesDic isKindOfClass:[NSDictionary class]]
        || [serverAttributesDic count] == 0) {
        return nil;
    }
    if (!isLocalFake) {
        serverAttributesDic = [self parsedServerDic:serverAttributesDic];
    }
    Class localClazz = [self class];
    // 准备要被赋值的本地属性数组、属性数目、属性名数组
    unsigned int propertyCount;
    objc_property_t *properties;
    NSArray * localPropertyNames = [localClazz p_properties:&properties propertyCount:&propertyCount];
    
    // 遍历属性数组
    for (CFIndex i=0; i<propertyCount; i++) {
        // 获取当前属性对应的 服务器 返回值
        id serverValue =  [serverAttributesDic valueForKey:[self p_serverKeyWithLocalKey:localPropertyNames[i] fakeServer:isLocalFake]];
        if (!serverValue) {
            continue;
        }
        
        // 获取当前属性细节
        objc_property_t property = properties[i];
        NSString *propertyName = localPropertyNames[i];
        // 检查是否在黑名单
        if ([self p_isInBlackList:propertyName]) {
            continue;
        }
        // 检查是否支持KVC
        char *ivar = property_copyAttributeValue(property, "V");
        if (!ivar) {
            free(ivar);
            continue;
        }
        free(ivar);
        
        id       propertyValue = nil;
        Class    propertyClass = [self p_classWithProperty:property];
        if (!propertyClass) {
            continue;
        }
        // 获取当前属性对应的 服务器返回值转换结果
        if ([propertyClass isSubclassOfClass:[WHUObject class]]
            && [serverValue isKindOfClass:[NSDictionary class]]) {// kindOf WHUObject
            propertyValue = [propertyClass p_objectFromAttributes:serverValue fakeServer:isLocalFake allocatedObject:[resultObject valueForKey:propertyName]];
        } else if ([propertyClass isSubclassOfClass:[NSDictionary class]]
                   && [serverValue isKindOfClass:[NSDictionary class]]){// NSDictionary
            propertyValue = [self p_localDictionaryWithServerDictionary:serverValue fakeServer:isLocalFake];
            if ([propertyClass isSubclassOfClass:[NSMutableDictionary class]]) {
                propertyValue = [propertyValue mutableCopy];
            }
        } else if ([propertyClass isSubclassOfClass:[NSArray class]]
                   && [serverValue isKindOfClass:[NSArray class]]){// NSArray
            propertyValue = [self p_localArrayWithServerArray:serverValue withServerKey: [self p_serverKeyWithLocalKey:localPropertyNames[i] fakeServer:isLocalFake]  fakeServer:isLocalFake];
            if ([propertyClass isSubclassOfClass:[NSMutableArray class]]) {// NSMutalbleArray
                propertyValue = [propertyValue mutableCopy];
            }
        } else if ([propertyClass isSubclassOfClass:[NSString class]]){// NSString
            propertyValue = [NSString stringWithFormat:@"%@", serverValue];
            if ([propertyClass isSubclassOfClass:[NSMutableString class]]) {// NSMutableString
                propertyValue = [propertyValue mutableCopy];
            }
        } else if ([propertyClass isSubclassOfClass:[NSNumber class]]){// NSNumber
            propertyValue = [[[NSNumberFormatter alloc] init] numberFromString:[NSString stringWithFormat:@"%@", serverValue]];
        } else if ([propertyClass isSubclassOfClass:[NSValue class]]){//  Struct
            const char *structEncoding = [[[self p_propertyName_structEncodingMapping] valueForKey:propertyName] UTF8String];
            if (structEncoding != NULL && strlen(structEncoding) > 0) {
                propertyValue = [NSValue valueWithBytes:&serverValue objCType:structEncoding];
            }
        }
        if (propertyValue) {
            // 将属性名与属性值关联
            if (resultObject == nil) {
                resultObject = [[localClazz alloc] init];
            }
            [resultObject setValue:propertyValue forKey:propertyName];
        }
    }
    
    free(properties);
    return  resultObject;
}


// 将服务器键值的某个结点子树转换成 本地对象属性的结点子树
+ (id) p_localValueWithServerKey:(NSString *)toBeCheckedServerKey andServerValue:(id)toBeCheckedServerValue  fakeServer:(BOOL)isLocalFake {
    id willSetLocalVale;
    NSString *className = nil;
    NSString *willSetLocalKey = toBeCheckedServerKey;
    if (toBeCheckedServerKey != nil) {
        willSetLocalKey  = [self p_localKeyWithServerKey:toBeCheckedServerKey];
        //!!!: 对应key值未明确给出类名时 程序运算？
        className = [[self p_dicKeyOrArrayName_ClassNameMapping] valueForKey:willSetLocalKey];
    }
    // 判断当前值是否需要转换成对象 或层次检查
    if ([toBeCheckedServerValue isKindOfClass:[NSDictionary class]]
        && className
        && [NSClassFromString(className) isSubclassOfClass:[WHUObject class]]) {//WHUObject
        willSetLocalVale = [NSClassFromString(className) p_objectFromAttributes:(NSDictionary *)toBeCheckedServerValue fakeServer:isLocalFake];
    } else if ([toBeCheckedServerValue isKindOfClass:[NSDictionary class]]) {//NSDictionary
        willSetLocalVale = [self p_localDictionaryWithServerDictionary:(NSDictionary *)toBeCheckedServerValue fakeServer:isLocalFake];
    } else if ([toBeCheckedServerValue isKindOfClass:[NSArray class]]) {//NSArray
        willSetLocalVale = [self p_localArrayWithServerArray:(NSArray *)toBeCheckedServerValue  withServerKey:toBeCheckedServerKey  fakeServer:isLocalFake];
    } else {
        willSetLocalVale = toBeCheckedServerValue;
    }
    return willSetLocalVale;
}

// 将服务器返回的非对象映射字典转换成本地字典的结点子树
+ (NSDictionary *) p_localDictionaryWithServerDictionary:(NSDictionary *)serverDictionary fakeServer:(BOOL)isLocalFake {
    NSMutableDictionary *localDictionary = [NSMutableDictionary dictionary];
    NSArray *allServerValues = [serverDictionary allValues];
    NSArray *allServerKeys   = [serverDictionary allKeys];
    
    for (CFIndex curIndex = 0; curIndex < [serverDictionary count]; curIndex ++) {
        id      toBeCheckedServerValue = allServerValues[curIndex];
        NSString *toBeCheckedServerKey = allServerKeys[curIndex];
        id            willSetLocalVale = [self p_localValueWithServerKey:toBeCheckedServerKey andServerValue:toBeCheckedServerValue fakeServer:isLocalFake];
        
        NSString *willSetLocalKey      = [self p_localKeyWithServerKey:toBeCheckedServerKey];
        [localDictionary setValue:willSetLocalVale forKey:willSetLocalKey];
    }
    return [NSDictionary dictionaryWithDictionary:localDictionary];
}

// 将服务器返回的数组转换成本地数组的结点子树
+ (NSArray *) p_localArrayWithServerArray:(NSArray *)serverArray withServerKey:(NSString *)serverKey fakeServer:(BOOL)isLocalFake {
    NSMutableArray *localArray = [NSMutableArray array];
    for (CFIndex curIndex = 0; curIndex < [serverArray count]; curIndex ++) {
        id      toBeCheckedServerValue = serverArray[curIndex];
        id            willSetLocalVale = [self p_localValueWithServerKey:serverKey andServerValue:toBeCheckedServerValue fakeServer:isLocalFake];
        if (willSetLocalVale) {
            [localArray addObject:willSetLocalVale];
        }
    }
    return [NSArray arrayWithArray:localArray];
}

// 根据本地属性名获取服务器字段名, 当isLocalFake为true时，表示此时服务器字典输入源由本地伪造，并不需检查映射
+ (NSString *) p_serverKeyWithLocalKey:(NSString *) localKey fakeServer:(BOOL)isLocalFake {
    if (isLocalFake) {
        return localKey;
    }
    NSString *serverKey = [[self p_local_serverKeyMapping] valueForKey:localKey];
    if (serverKey == nil) {
        serverKey = localKey;
    }
    return serverKey;
}

// 根据服务器字段名获取本地属性名
+ (NSString *) p_localKeyWithServerKey:(NSString *) serverKey {
    NSDictionary *serverKeyMapping = [self p_local_serverKeyMapping];
    __block NSString *localKey;
    [serverKeyMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:serverKey]) {
            localKey = (NSString *)key;
            *stop = YES;
        }
    }];
    if (localKey == nil) {
        localKey = serverKey;
    }
    return localKey;
}

// 获取本地对象的属性数组
+ (NSArray *) p_properties:(objc_property_t **)properties_p  propertyCount:(unsigned int *)propertyCount_p {
    objc_property_t * properties_t;
    unsigned int  propertyCount_t;
    BOOL isNeddFreePointer = NO;
    if (properties_p == NULL) {
        isNeddFreePointer = YES;
        properties_p = &properties_t;
    }
    if (propertyCount_p == NULL) {
        propertyCount_p = &propertyCount_t;
    }
    NSMutableArray *propertyNames = [@[] mutableCopy];
    // 本类特有属性集
    *properties_p = class_copyPropertyList([self class], propertyCount_p);
    for (CFIndex curIndex = 0; curIndex < *propertyCount_p; curIndex++) {
        objc_property_t property = (*properties_p)[curIndex];
        // 删除没有ivar或readOnly, 不支持kvc的属性
        char *ivar = property_copyAttributeValue(property, "V");
        if (ivar == NULL){
            objc_property_t * properties_t1;
            while (!(properties_t1 = malloc((*propertyCount_p - 1)*sizeof(objc_property_t)))) {
            };
            if (curIndex!=0) {
                memcpy(properties_t1, *properties_p, curIndex*sizeof(objc_property_t));
            }
            memcpy(properties_t1+curIndex, *properties_p+curIndex+1,  (*propertyCount_p-curIndex-1)*sizeof(objc_property_t));
            *propertyCount_p -= 1;
            curIndex -= 1;
            free(*properties_p);
            *properties_p = properties_t1;
            free(ivar);
            continue;
        }
        free(ivar);
        
        const char *propertyName = property_getName(property);
        NSString *curPropertyName = @(propertyName);
        [propertyNames addObject:curPropertyName];
    }
    // 循环获取父类属性集 弃除重复属性
    Class superClass = class_getSuperclass([self class]);
    while (superClass != [NSObject class]) {
        unsigned int superPropertyCount;
        objc_property_t *superProperties = class_copyPropertyList(superClass, &superPropertyCount);
        
        for (CFIndex curIndex = 0; curIndex < superPropertyCount; curIndex++) {
            NSString *curPropertyName = [NSString stringWithUTF8String:property_getName(superProperties[curIndex])];
            // 查重
            __block NSUInteger existedIndex = NSNotFound;
            [propertyNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]]
                    && [obj isEqualToString:curPropertyName]) {
                    existedIndex = idx;
                    *stop = YES;
                }
            }];
            // 添加非重复项
            if (existedIndex == NSNotFound) {
                objc_property_t curProperty = superProperties[curIndex];
                
                char *ivar = property_copyAttributeValue(curProperty, "V");
                if (ivar == NULL){
                    free(ivar);
                    continue;
                }
                free(ivar);
                
                NSString *curPropertyName = [NSString stringWithUTF8String:property_getName(curProperty)];
                
                objc_property_t * properties_t2;
                while (!(properties_t2 = malloc((*propertyCount_p + 1)*sizeof(objc_property_t)))) {
                }
                memcpy(properties_t2, *properties_p, (*propertyCount_p)*sizeof(objc_property_t));
                memcpy(properties_t2 + *propertyCount_p, superProperties + curIndex, 1*sizeof(objc_property_t));
                free(*properties_p);
                *properties_p = properties_t2;
                
                [propertyNames addObject:curPropertyName];
                *propertyCount_p = (unsigned int)propertyNames.count;
            }
        }
        *propertyCount_p = (unsigned int)propertyNames.count;
        
        superClass = class_getSuperclass([superClass class]);
        free(superProperties);
    }
    if (isNeddFreePointer) {
        free(*properties_p);
    }
    return [NSArray arrayWithArray:propertyNames];
}

// 获取属性对应的类
+ (Class) p_classWithProperty:(objc_property_t)property {
    Class propertyClass = nil;
    char *typeEncoding = property_copyAttributeValue(property, "T");
    switch (typeEncoding[0]){
        case 'c'://char
        case 'i'://int
        case 's'://short
        case 'l'://long
        case 'q'://long long
        case 'C'://unsigned char
        case 'I'://unsigned int
        case 'S'://unsigned short
        case 'L'://unsigned long
        case 'Q'://unsigned long long
        case 'f'://float
        case 'd'://double
        case 'B':{//C++bool or c99 _Bool
            propertyClass = [NSNumber class];
            break;
        }
        case '*':{
            // C-String
            propertyClass = [NSString class];
            break;
        }
        case '@':{
            // Object
            if (strlen(typeEncoding) >= 3){
                char *cName = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                NSString *name = @(cName);
                NSRange range = [name rangeOfString:@"<"];
                if (range.location != NSNotFound){
                    name = [name substringToIndex:range.location];
                }
                propertyClass = NSClassFromString(name) ?: [NSObject class];
                free(cName);
            }
            break;
        }
        case '{':{// Struct
            propertyClass = [NSValue class];
            break;
        }
        case '[':// C-Array
        case '(':// Union
        case '#':// Class
        case ':':// Selector
        case '^':// Pointer
        case 'b':// Bitfield
        case '?':// Unknown type
        default:{
            // Not supported by KVC
            propertyClass = nil;
            break;
        }
    }
    
    free(typeEncoding);
    
    return propertyClass;
}

#pragma 调试信息支持

// 字典转字符串
- (NSString *) p_stringFromDictionary:(NSDictionary *) dic {
    NSArray *allKeys = [dic allKeys];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\n "];
    for (NSString *key in allKeys) {
        id value= dic[key];
        if ([value isKindOfClass:[NSArray class]]) {
            [str appendFormat:@"\t \"%@\" = %@,\n",key,[self p_stringFromArray:value]];
        } else if ([value isKindOfClass:[NSDictionary class]]){
            [str appendFormat:@"\t \"%@\" = %@,\n",key,[self p_stringFromDictionary:value]];
        } else {
            [str appendFormat:@"\t \"%@\" = %@,\n",key, value];
        }
    }
    [str appendString:@"\t }"];
    return [NSString stringWithFormat:@"%@",str];
}

// 数组转字符串
- (NSString *) p_stringFromArray:(NSArray *) arr {
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"[\n "];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [str appendFormat:@"\n\t %@,\n",[self p_stringFromArray:obj]];
        } else if ([obj isKindOfClass:[NSDictionary class]]){
            [str appendFormat:@"\n\t %@,\n",[self p_stringFromDictionary:obj]];
        } else {
            [str appendFormat:@"\t %@,\n",obj];
        }    }];
    [str appendString:@"\t ]"];
    return [NSString stringWithFormat:@"%@", str];
}

#pragma mark 协议实现支持
// 散列值
- (NSString *) p_hashStr {
    NSString *hashStr = [self p_stringFromDictionary:[self dictionary]];
    
    NSScanner * scanner = [NSScanner scannerWithString:hashStr];
    while([scanner isAtEnd]==NO){
        NSString * text = nil;
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        hashStr = [hashStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return hashStr;
}





@end

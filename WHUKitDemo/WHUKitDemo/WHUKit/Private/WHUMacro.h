//
//  WHUMacro.h
//  WHUKitDemo
//
//  Created by 胡 帅 on 16/4/1.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <objc/runtime.h>


#ifndef WHUMacro_h
#define WHUMacro_h

/***************************************************/
/*                                                 */
/*                     真单例                       */
/*                                                 */
/***************************************************/

// -------------------- 单例 -------------------声明
#define WHU_DECLARE_SINGLETON_FOR_CLASS(classname) \
+ (classname *)sharedInstance;

// -------------------- 单例 --------------------实现
#define WHU_SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *_sharedInstance = nil; \
\
+ (classname *)sharedInstance { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{      \
        if(_sharedInstance == nil) { \
            _sharedInstance = [super allocWithZone:NULL];\
            _sharedInstance = [_sharedInstance init];\
            method_exchangeImplementations(\
                class_getClassMethod([_sharedInstance class], @selector(sharedInstance)),\
                class_getClassMethod([_sharedInstance class], @selector(WHU_lockless_sharedInstance)));\
            method_exchangeImplementations(\
                class_getInstanceMethod([_sharedInstance class], @selector(init)),\
                class_getInstanceMethod([_sharedInstance class], @selector(WHU_onlyInitOnce)));\
        }  \
    }); \
    \
    return _sharedInstance; \
} \
\
+ (classname *)WHU_lockless_sharedInstance {\
    return _sharedInstance; \
} \
\
+ (id)allocWithZone:(NSZone *)zone {\
    return [self sharedInstance]; \
} \
\
- (id)copyWithZone:(NSZone *)zone {\
    return self; \
} \
- (id)WHU_onlyInitOnce {\
    return self;\
} 


// -------------------- 单例 --------------------end







/* ---------   主线程执行 --------- */
#define excecuteOnMain(a) if ([NSThread isMainThread]) {\
a\
}\
else {\
dispatch_async(dispatch_get_main_queue(), ^{\
a\
});\
}


/*-----------调试类--------------------------------*/

#define THIS_FILE [[NSString stringWithUTF8String:__FILE__] lastPathComponent]
#define THIS_METHOD NSStringFromSelector(_cmd)

#define HSDescriptionForCurrentTime()\
({ NSDateFormatter* formatter = [[NSDateFormatter alloc] init];\
[formatter setDateFormat:@"HH:mm:ss"];\
NSDate *date = [NSDate date];\
NSString *str = [formatter stringFromDate:date];\
const char * a =[str UTF8String];\
a;\
})
#if DEBUG
#define HSLog(FORMAT, ...) \
printf("[%s] %s\n", HSDescriptionForCurrentTime(), [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#define HSLogTrace() HSLog(@"[TRACING] FILE: %@ >> METHOD: %@ >> LINE: %d", THIS_FILE, THIS_METHOD, __LINE__)
#define HSLogError(FORMAT, ...)

#else

#define HSLog(...)
#define HSLogTrace()
#define HSLogError(FORMAT, ...)

#endif


/* ---   weak strong Dance ------ */
#ifdef DEBUG
#define ext_keywordify autoreleasepool {}
#else
#define ext_keywordify try {} @catch (...) {}
#endif

#define weakify(self) \
ext_keywordify \
__attribute__((objc_ownership(weak))) __typeof__(self) self_weak_ = (self)

#define strongify(self) \
ext_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__attribute__((objc_ownership(strong))) __typeof__(self) self = (self_weak_)\
_Pragma("clang diagnostic pop")

/* --------   空语句挂载断点 ------ */
#ifdef DEBUG
#define __NOP__ assert(1)
#else
#define __NOP__
#endif




#endif /* WHUMacro_h */

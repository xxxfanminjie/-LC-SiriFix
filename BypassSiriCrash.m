#import <Foundation/Foundation.h>
#import <objc/runtime.h>

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface NSObject (BypassSiriCrash)
+ (id)fake_sharedVocabulary;
+ (id)fake_alloc;
@end

@implementation NSObject (BypassSiriCrash)
+ (id)fake_sharedVocabulary {
    NSLog(@"[BypassSiri] hooked sharedVocabulary, return nil");
    return nil;
}
+ (id)fake_alloc {
    NSLog(@"[BypassSiri] hooked INVocabulary alloc, return nil");
    return nil;
}
@end

__attribute__((constructor)) static void init() {
    @autoreleasepool {
        Class invClass = NSClassFromString(@"INVocabulary");
        if (!invClass) {
            NSLog(@"[BypassSiri] INVocabulary class not found");
            return;
        }
        NSLog(@"[BypassSiri] find INVocabulary, start swizzle");
        swizzleMethod(invClass, @selector(sharedVocabulary), @selector(fake_sharedVocabulary));
        swizzleMethod(invClass, @selector(alloc), @selector(fake_alloc));
    }
}

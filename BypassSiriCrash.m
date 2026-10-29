#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static void swizzleClassMethod(Class cls, SEL origSel, SEL newSel) {
    if (!cls || !origSel || !newSel) return;
    Method origM = class_getClassMethod(cls, origSel);
    Method newM = class_getClassMethod(cls, newSel);
    if (origM && newM) {
        method_exchangeImplementations(origM, newM);
    }
}

static void swizzleInstanceMethod(Class cls, SEL origSel, SEL newSel) {
    if (!cls || !origSel || !newSel) return;
    Method origM = class_getInstanceMethod(cls, origSel);
    Method newM = class_getInstanceMethod(cls, newSel);
    if (origM && newM) {
        method_exchangeImplementations(origM, newM);
    }
}

// 专门给 INVocabulary 使用的分类
@interface INVocabulary (SiriFix)
+ (id)bypass_sharedVocabulary;
+ (id)bypass_alloc;
@end

@implementation INVocabulary (SiriFix)
+ (id)bypass_sharedVocabulary {
    NSLog(@"[BypassSiriFix] Hooked INVocabulary sharedVocabulary, return nil");
    return nil;
}
+ (id)bypass_alloc {
    NSLog(@"[BypassSiriFix] Hooked INVocabulary alloc, return nil");
    return nil;
}
@end

// 专门给 INPreferences 使用的分类
@interface INPreferences (SiriFix)
+ (id)bypass_alloc;
- (id)bypass_init;
@end

@implementation INPreferences (SiriFix)
+ (id)bypass_alloc {
    NSLog(@"[BypassSiriFix] Hooked INPreferences alloc, return nil");
    return nil;
}
- (id)bypass_init {
    NSLog(@"[BypassSiriFix] Hooked INPreferences init, return nil");
    return nil;
}
@end

__attribute__((constructor)) static void BypassSiriCrashInit() {
    @autoreleasepool {
        Class clsVoc = NSClassFromString(@"INVocabulary");
        if (clsVoc) {
            NSLog(@"[BypassSiriFix] Found INVocabulary, swizzle start");
            swizzleClassMethod(clsVoc, @selector(sharedVocabulary), @selector(bypass_sharedVocabulary));
            swizzleClassMethod(clsVoc, @selector(alloc), @selector(bypass_alloc));
        } else {
            NSLog(@"[BypassSiriFix] INVocabulary NOT found");
        }

        Class clsPref = NSClassFromString(@"INPreferences");
        if (clsPref) {
            NSLog(@"[BypassSiriFix] Found INPreferences, swizzle start");
            swizzleClassMethod(clsPref, @selector(alloc), @selector(bypass_alloc));
            swizzleInstanceMethod(clsPref, @selector(init), @selector(bypass_init));
        } else {
            NSLog(@"[BypassSiriFix] INPreferences NOT found");
        }
    }
}

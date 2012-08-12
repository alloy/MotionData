#import "define_method.h"
#import <objc/runtime.h>

@implementation ClassExt

+ (void)defineRubyClassMethod:(rubyMethodBlock)block withSelector:(SEL)selector onClass:(Class)klass;
{
  [ClassExt defineRubyInstanceMethod:block withSelector:selector onClass:object_getClass(klass)];
}

+ (void)defineRubyInstanceMethod:(rubyMethodBlock)block withSelector:(SEL)selector onClass:(Class)klass;
{
  IMP imp = imp_implementationWithBlock(block);
  class_addMethod(klass, selector, (IMP)imp, "@@:");
}

@end

#import <Foundation/Foundation.h>

typedef id(^rubyMethodBlock)(id);

@interface ClassExt : NSObject

+ (void)defineRubyClassMethod:(rubyMethodBlock)block withSelector:(SEL)selector onClass:(Class)klass;
+ (void)defineRubyInstanceMethod:(rubyMethodBlock)block withSelector:(SEL)selector onClass:(Class)klass;

@end

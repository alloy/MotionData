#import "MotionDataManagedObjectBase.h"
#import <objc/runtime.h>

@implementation MotionDataManagedObjectBase

+ (id)scopeByName:(NSString *)name;
{
  // should be overriden by the subclass
  printf("Unimplemented\n");
  abort();
  return nil;
}

+ (void)defineNamedScopeMethod:(NSString *)name;
{
  IMP imp = imp_implementationWithBlock(^id(Class modelClass) {
    return [modelClass scopeByName:name];
  });
  class_addMethod(object_getClass([self class]), NSSelectorFromString(name), imp, "@@:");
}

- (id)relationshipByName:(NSString *)name;
{
  // should be overriden by the subclass
  printf("Unimplemented\n");
  abort();
  return nil;
}

+ (void)defineRelationshipMethod:(NSString *)name;
{
  IMP imp = imp_implementationWithBlock(^id(MotionDataManagedObjectBase *entity) {
    return [entity relationshipByName:name];
  });
  class_addMethod([self class], NSSelectorFromString(name), imp, "@@:");
}

- (id)rubyBooleanValueForKey:(NSString *)name;
{
  // should be overriden by the subclass
  printf("Unimplemented\n");
  abort();
  return nil;
}

+ (void)definePropertyPredicateAccessor:(NSString *)name;
{
  SEL selector = NSSelectorFromString([name stringByAppendingString:@"?"]);
  IMP imp = imp_implementationWithBlock(^id(MotionDataManagedObjectBase *entity) {
    return [entity rubyBooleanValueForKey:name];
  });
  class_addMethod([self class], selector, imp, "@@:");
}

@end

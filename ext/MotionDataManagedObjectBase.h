#import <CoreData/CoreData.h>

@interface MotionDataManagedObjectBase : NSManagedObject

+ (id)scopeByName:(NSString *)name;
+ (void)defineNamedScopeMethod:(NSString *)name;

- (id)relationshipByName:(NSString *)name;
+ (void)defineRelationshipMethod:(NSString *)name;

@end

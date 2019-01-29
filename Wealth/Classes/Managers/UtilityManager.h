#import "cocos2d.h"

@interface UtilityManager : NSObject {
}

//+ (id) convertBooleanToIdBool:(BOOL)boolean;
//+ (id) convertCGPointToIdCGPoint:(CGPoint)cgPoint;
//+ (id) convertCGSizeToIdCGSize:(CGSize)cgSize;
//+ (id) convertIntegerToIdInteger:(NSInteger)integer;
//+ (id) convertFloatToIdFloat:(CGFloat)number;
//+ (id) convertPointerToIdPointer:(void *)pointer;

//+ (BOOL) convertIdBoolToBoolean:(id)idBool;
//+ (CGSize) convertIdCGSizeToCGSize:(id)idCGSize;
//+ (CGFloat) convertIdFloatToFloat:(id)idFloat;
//+ (NSInteger) convertIdIntegerToInteger:(id)idInteger;
//+ (void *) convertIdPointerToPointer:(id)idPointer;
//+ (CGPoint) convertIdCGPointToCGPoint:(id)idPosition;

+ (NSInteger) randomIntegerFrom:(NSInteger)low to:(NSInteger)high;
+ (CGFloat) randomFloatFrom:(CGFloat)low to:(CGFloat)high;
//+ (NSString *)formatValue:(NSInteger)value forDigits:(NSInteger)zeros;

//+ (CGPoint) convertToNode:(CCNode *)node position:(CGPoint)position;

@end

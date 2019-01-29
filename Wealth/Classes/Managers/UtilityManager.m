#import "UtilityManager.h"

@implementation UtilityManager


//+ (id) convertBooleanToIdBool:(BOOL)boolean {
//    return [NSNumber numberWithBool:boolean];
//}

//+ (id) convertCGPointToIdCGPoint:(CGPoint)cgPoint {
//    return [NSValue valueWithCGPoint:cgPoint];
//}
//
//+ (id) convertCGSizeToIdCGSize:(CGSize)cgSize {
//    return [NSValue valueWithCGSize:cgSize];
//}
//
//+ (id) convertIntegerToIdInteger:(NSInteger)integer {
//    return [NSNumber numberWithInt:integer];
//}
//
//+ (id) convertFloatToIdFloat:(CGFloat)number {
//    return [NSNumber numberWithFloat:number];
//}
//
//+ (id) convertPointerToIdPointer:(void *)pointer {
//    return [NSValue valueWithPointer:pointer];
//}

//+ (BOOL) convertIdBoolToBoolean:(id)idBool {
//    return [idBool boolValue];
//}
//

//+ (CGSize) convertIdCGSizeToCGSize:(id)idCGSize {
//    return [(NSValue *) idCGSize CGSizeValue];
//}
//
//+ (CGFloat) convertIdFloatToFloat:(id)idFloat {
//    return [(NSNumber *)idFloat floatValue];
//}
//
//+ (NSInteger) convertIdIntegerToInteger:(id)idInteger {
//    return [(NSNumber *)idInteger integerValue];
//}
//
//+ (void *) convertIdPointerToPointer:(id)idPointer {
//    return [idPointer pointerValue];
//}
//
//+ (CGPoint) convertIdCGPointToCGPoint:(id)idPosition {
//    return [(NSValue *)idPosition CGPointValue];
//}

+ (NSInteger) randomIntegerFrom:(NSInteger)low to:(NSInteger)high {
    return arc4random() % (high - low + 1) + low;
}

+ (CGFloat) randomFloatFrom:(CGFloat)low to:(CGFloat)high {
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (high - low)) + low;
}

//+ (NSString *)formatValue:(NSInteger)value forDigits:(NSInteger)zeros {
//    NSString *format = [NSString stringWithFormat:@"%%0%dd", zeros];
//    return [NSString stringWithFormat:format,value];
//}


//+ (CGPoint) convertToNode:(CCNode *)node position:(CGPoint)position {
//    return [node convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:position]];
//}

@end

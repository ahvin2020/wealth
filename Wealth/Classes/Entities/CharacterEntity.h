//
//  CharacterEntity.h
//  Wealth
//
//  Created by Tan Kel Vin on 3/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "cocos2d.h"

@interface CharacterEntity : CCNode {
    @private
    NSInteger _scaleFactor;
    
    // head dizzy constant
    CGFloat _headDizzyDuration;
    
    // head position constants
    CGPoint _headRestPosition;
    CGPoint _minBobbleSpeed;
    CGPoint _maxBobbleSpeed;
    CGFloat _bobbleElasticity;
    CGFloat _bobbleFriction;
    CGFloat _headMaxDistance;
    CGFloat _headMaxDistance2;
    CGFloat _shakeFactor;
    
    // head rotation constants
    CGFloat _rotationElasticity;
    CGFloat _rotationFriction;
    CGFloat _maxRotationSpeed;
    
    // bobble variables
    CGPoint _bobbleAcceleration;
    CGPoint _bobbleSpeed;
    CGFloat _rotationAcceleration;
    CGFloat _rotationSpeed;
    
    // character dizzy variable
    BOOL _isCharacterDizzy;
    
    // sprites
    CCSprite *_normalEye;
    CCSprite *_dizzyEye;
    
    CCSprite *_closeMouth;
    CCSprite *_openMouth;
    
    CCSprite *_head;
    CCSprite *_body;
    CCNode *_characterNode;
}

- (CCNode *) characterNode;
- (void) isCharacterDizzy:(BOOL)isCharacterDizzy;
- (void) isCharacterTalking:(BOOL)isCharacterTalking;
- (BOOL) isSelectedHeadWithTouchAt:(CGPoint)position;
- (void) moveHeadBy:(CGPoint)translation;
- (void) onReleaseHead;
- (void) shakeWithAcceleration:(CGPoint)acceleration;
- (void) update:(CGFloat)deltaTime;

@end

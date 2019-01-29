//
//  CharacterEntity.m
//  Wealth
//
//  Created by Tan Kel Vin on 3/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "CharacterEntity.h"
#import "AppManager.h"
#import "DataManager.h"
#import "SimpleAudioEngine.h"
#import "UtilityManager.h"

@interface CharacterEntity ()

- (void) _stopCharacterDizzy:(ccTime)dt;

@end

@implementation CharacterEntity

#pragma mark - init and dealloc

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        DataManager *dataManager = [AppManager sharedManager].dataManager;

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _scaleFactor = CC_CONTENT_SCALE_FACTOR();
        
        // head constants
        _headDizzyDuration = [[dataManager constantForKeyPath:@"BobbleHead.HeadDizzyDuration"] floatValue];
        _shakeFactor = [[dataManager constantForKeyPath:@"BobbleHead.ShakeFactor"] floatValue];
        
        _bobbleElasticity = [[dataManager constantForKeyPath:@"BobbleHead.BobbleElasticity"] floatValue];
        _bobbleFriction = [[dataManager constantForKeyPath:@"BobbleHead.BobbleFriction"] floatValue];
        
        // rotation constants
        _rotationElasticity = [[dataManager constantForKeyPath:@"BobbleHead.RotationElasticity"] floatValue];
        _rotationFriction = [[dataManager constantForKeyPath:@"BobbleHead.RotationFriction"] floatValue];
        
        CGFloat maxRotationSpeed = [[dataManager constantForKeyPath:@"BobbleHead.MaxRotationSpeed"] floatValue];
        _maxRotationSpeed = maxRotationSpeed;
        
        // head variables
        _bobbleAcceleration = CGPointZero;
        _bobbleSpeed = CGPointZero;
        
        // rotation variables
        _rotationAcceleration = 0;
        _rotationSpeed = 0;
        
//        CGFloat bodyDistanceFromCenterY = [[dataManager constantForKeyPath:@"BobbleHead.BodyDistFromCenterY"] floatValue];
        _body = [CCSprite spriteWithSpriteFrameName:@"character_body.png"];
        _body.position = ccp(winSize.width/2, winSize.height/4.3);
//        _body.position = ccp(size.width/2, 120);
        
        _head = [CCSprite spriteWithSpriteFrameName:@"character_face.png"];
        
//        CGFloat headDistanceFromCenterY = [[dataManager constantForKeyPath:@"BobbleHead.HeadDistFromCenterY"] floatValue];
        _headRestPosition = ccp(winSize.width/2, _body.position.y + _head.contentSize.height/5.5);
        _head.position = _headRestPosition;
        _head.anchorPoint = ccp(0.5, 0.1);
        
        _characterNode = [[CCNode alloc] init];
        [_characterNode addChild:_body];
        [_characterNode addChild:_head];
        
        // eye
        CGPoint eyePosition = ccp(_head.contentSize.width/2, _head.contentSize.height/2.7);
        _normalEye = [CCSprite spriteWithSpriteFrameName:@"eye_normal.png"];
        _normalEye.position = eyePosition;
        
        _dizzyEye = [CCSprite spriteWithSpriteFrameName:@"eye_faint.png"];
        _dizzyEye.position = eyePosition;
        
        [_head addChild:_normalEye];
        [_head addChild:_dizzyEye];

        [self isCharacterDizzy:NO];
        
        // mouth
        CGPoint openMouthPosition = ccp(_head.contentSize.width/2, _head.contentSize.height/12);
        _openMouth = [CCSprite spriteWithSpriteFrameName:@"mouth_open.png"];
        _openMouth.position = openMouthPosition;
        
        CGPoint closeMouthPosition = ccp(_head.contentSize.width/2, _head.contentSize.height/11);
        _closeMouth = [CCSprite spriteWithSpriteFrameName:@"mouth_close.png"];
        _closeMouth.position = closeMouthPosition;
        
        [_head addChild:_openMouth];
        [_head addChild:_closeMouth];
        
        _openMouth.visible = NO;
        
        // moustache
        CCSprite *_moustache = [CCSprite spriteWithSpriteFrameName:@"moustache.png"];
        _moustache.position = ccp(_head.contentSize.width/2, _head.contentSize.height/6);
        [_head addChild:_moustache];
        
        CGFloat maxBobbleSpeedRatio = [[dataManager constantForKeyPath:@"BobbleHead.MaxBobbleSpeedRatio"] floatValue];
        _maxBobbleSpeed = ccp(_head.contentSize.width * maxBobbleSpeedRatio, _head.contentSize.height * maxBobbleSpeedRatio);
        _minBobbleSpeed = ccpMult(_maxBobbleSpeed, -1);
        
        _headMaxDistance = _head.contentSize.height * [[dataManager constantForKeyPath:@"BobbleHead.DragDistanceRatio"] floatValue];
        _headMaxDistance2 = _headMaxDistance * _headMaxDistance;
	}
    
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {
    [_body release];
    _body = nil;
    
    [_head release];
    _head = nil;
    
    [_characterNode release];
    _characterNode = nil;
    
	[super dealloc];
}

#pragma mark - public methods

- (CCNode *) characterNode {
    return _characterNode;
}

- (void) isCharacterTalking:(BOOL)isCharacterTalking {
    _closeMouth.visible = !isCharacterTalking;
    _openMouth.visible = isCharacterTalking;
}

- (void) isCharacterDizzy:(BOOL)isCharacterDizzy {
    _isCharacterDizzy = isCharacterDizzy;
    
    // show eye dizzy for an interval
    _dizzyEye.visible = isCharacterDizzy;
    _normalEye.visible = !isCharacterDizzy;
    
    if (isCharacterDizzy) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"dizzy sound effect 2.m4a"];
        
        [self.scheduler unscheduleSelector:@selector(_stopCharacterDizzy:) forTarget:self];
        [self.scheduler scheduleSelector:@selector(_stopCharacterDizzy:) forTarget:self interval:_headDizzyDuration repeat:0 delay:0 paused:NO];
    }
}

- (BOOL) isSelectedHeadWithTouchAt:(CGPoint)position {
    if (CGRectContainsPoint(_head.boundingBox, position)) {

        //Convert the location to the node space
        CGPoint location = [_head convertToNodeSpace:position];
        location = ccpMult(location, _scaleFactor);
        
        //This is the pixel we will read and test
        Byte pixel[4];
        
        CCRenderTexture* renderTexture = [[CCRenderTexture alloc] initWithWidth:_head.boundingBox.size.width * _scaleFactor
                                                                         height:_head.boundingBox.size.height * _scaleFactor
                                                                    pixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        [renderTexture begin];
        
        //Draw the layer
        [_head draw];
        
        //Read the pixel
        glReadPixels((GLint)location.x,(GLint)location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
        
        //Cleanup
        [renderTexture end];
        [renderTexture release];

        return (pixel[3] != 0);
    } else {
        return NO;
    }
}

- (void) moveHeadBy:(CGPoint)translation {
    CGPoint headPosition = ccpAdd(_head.position, translation);
    CGPoint headDistance = ccpSub(headPosition, _headRestPosition);
    
    if (headDistance.x * headDistance.x + headDistance.y * headDistance.y > _headMaxDistance2) {
        CGFloat maxLength = _headMaxDistance / ccpLength(headDistance);
        headPosition = ccpAdd(_headRestPosition, ccpMult(headDistance, maxLength));
    }
    
    _head.position = headPosition;
}

- (void) onReleaseHead {
    _rotationSpeed = ccpLength(ccpSub(_head.position, _headRestPosition));
    
    if (_head.position.x < _headRestPosition.x) {
        _rotationSpeed = max(-_rotationSpeed, -_maxRotationSpeed);
    } else {
        _rotationSpeed = min(_rotationSpeed, _maxRotationSpeed);
    }
}

- (void) shakeWithAcceleration:(CGPoint)acceleration {
    _bobbleSpeed = ccpAdd(ccpMult(acceleration, _shakeFactor), _bobbleSpeed);
    _bobbleSpeed = ccpClamp(_bobbleSpeed, _minBobbleSpeed, _maxBobbleSpeed);
    
    _rotationSpeed = ccpLength(acceleration) * _shakeFactor + _rotationSpeed;
    _rotationSpeed = clampf(_rotationSpeed, -_maxRotationSpeed, _maxRotationSpeed);
}

// flash.tutorialsstock.com/Actionscript/How-to-make-own-Bobble-Head/Flash-tutorials-1122.html
- (void) update:(CGFloat)deltaTime {
    CGFloat dt = deltaTime * 50;
    
    // head position
    CGPoint distance = ccpSub(_head.position, _headRestPosition);

    CGFloat randDisplacement = powf(distance.x * distance.x + distance.y * distance.y, 0.3f);
    randDisplacement = [UtilityManager randomFloatFrom:-randDisplacement to:randDisplacement];
    if (abs(randDisplacement) < 0.05) {
        randDisplacement = 0;
    }
    distance.x += randDisplacement;
    
    _bobbleAcceleration = ccpMult(distance, _bobbleElasticity * dt);
    _bobbleSpeed = ccpMult(ccpAdd(_bobbleAcceleration, _bobbleSpeed), _bobbleFriction);
    _head.position = ccpSub(_head.position, _bobbleSpeed);
    
    // head rotation
    CGFloat randDisplacementRotation = powf(abs(_head.rotation), 0.4f);
    randDisplacementRotation = [UtilityManager randomFloatFrom:-randDisplacementRotation to:randDisplacementRotation];
    if (abs(randDisplacementRotation) < 0.05) {
        randDisplacementRotation = 0;
    }
   
    _rotationAcceleration = (_head.rotation + randDisplacementRotation) * _rotationElasticity * dt;
    _rotationSpeed = (_rotationAcceleration + _rotationSpeed) * _rotationFriction;

    _head.rotation -= _rotationSpeed;
}

#pragma mark - private methods

- (void) _stopCharacterDizzy:(ccTime)dt {
    [self isCharacterDizzy:NO];
}

@end

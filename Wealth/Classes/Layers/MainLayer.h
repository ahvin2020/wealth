//
//  HelloWorldLayer.h
//  Wealth
//
//  Created by Tan Kel Vin on 29/12/12.
//  Copyright Tan Kel Vin 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "AppDelegate.h"
#import "cocos2d.h"

@class CharacterEntity;

// MainLayer
@interface MainLayer : CCLayer <UIAccelerometerDelegate, AdWhirlDelegate> {
    @private
    // head constant
    BOOL _isSelectedHead;
    CGFloat _totalAccelerationToDizzy;
    
    // shake constants
    CGFloat _minShakeX;
    CGFloat _minShakeY;
    CGFloat _accumulateAccelerationInterval;
    CGFloat _shakeResultTime;
    
    // timestep constants
    CGFloat _fixedTimestep;
    CGFloat _minTimestep;
    NSInteger _maxStepCount;
    
	ccTime _totalTime;
	ccTime _previousShakeTime;
	CGFloat _totalAcceleration;
	
    // spawn coin
    CGFloat _minSpawnCoinTime;
    CGFloat _maxSpawnCoinTime;
    ccTime _nextSpawnCoinTime;
    
	BOOL _characterDizzyOnStopShake;
	BOOL _sayQuoteOnStopShake;
	
    CCParallaxNode *_parallaxNode;
    CharacterEntity *_characterEntity;
    CCSprite *_leftDoor;
    CCSprite *_rightDoor;
    
    AdWhirlView *adWhirlView;
    UINavigationController *viewController;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property(nonatomic,retain) AdWhirlView *adWhirlView;

@end

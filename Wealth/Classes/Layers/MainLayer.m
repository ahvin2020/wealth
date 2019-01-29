//
//  MainLayer.m
//  Wealth
//
//  Created by Tan Kel Vin on 29/12/12.
//  Copyright Tan Kel Vin 2012. All rights reserved.
//


// Import the interfaces
#import "MainLayer.h"
#import "AppManager.h"
#import "CharacterEntity.h"
#import "CoinManager.h"
#import "DataManager.h"
#import "Flurry.h"
#import "LotteryManager.h"
#import "MusicManager.h"
#import "QuoteManager.h"
#import "UtilityManager.h"

@interface MainLayer ()

- (ccTime) _generateNextSpawnCoinTime;
- (void) _initHudLayer;
- (void) _initDoors;
- (void) _initParallaxLayers;
- (void) _onFinishMoveNode:(CCNode *)node;
- (void) _tick:(ccTime)dt;

@end

// MainLayer implementation
@implementation MainLayer

@synthesize adWhirlView;

#pragma mark - init and dealloc

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainLayer *layer = [MainLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        // enable shake detection
		self.accelerometerEnabled = YES;
	
		_totalTime = 0;
		_previousShakeTime = 0;
		_totalAcceleration = 0;
		
        
		_characterDizzyOnStopShake = NO;
		_sayQuoteOnStopShake = NO;
		
//        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.2];
        [[UIAccelerometer sharedAccelerometer]setDelegate:self];
        
        // enable touch
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        
        _isSelectedHead = NO;
        
        DataManager *dataManager = [AppManager sharedManager].dataManager;
        
        // timestep constants
        _fixedTimestep = [[dataManager constantForKeyPath:@"Timestep.FixedTimestep"] floatValue];
        _minTimestep = [[dataManager constantForKeyPath:@"Timestep.MinTimestep"] floatValue];
        _maxStepCount = [[dataManager constantForKeyPath:@"Timestep.MaxStepCount"] integerValue];
        
        // shake constants
        _minShakeX = [[dataManager constantForKeyPath:@"Accelerometer.MinShakeX"] floatValue];
        _minShakeY = [[dataManager constantForKeyPath:@"Accelerometer.MinShakeY"] floatValue];
        _accumulateAccelerationInterval = [[dataManager constantForKeyPath:@"Accelerometer.AccumulateAccelerationInterval"] floatValue];
        _shakeResultTime = [[dataManager constantForKeyPath:@"Accelerometer.ShakeResultTime"] floatValue];
        
        _totalAccelerationToDizzy = [[dataManager constantForKeyPath:@"BobbleHead.TotalAccelerationToDizzy"] floatValue];
        
        // coin drop
        _minSpawnCoinTime = [[dataManager constantForKeyPath:@"Coins.MinSpawnTime"] floatValue];
        _maxSpawnCoinTime = [[dataManager constantForKeyPath:@"Coins.MaxSpawnTime"] floatValue];
        _nextSpawnCoinTime = [self _generateNextSpawnCoinTime];
        
        [self _initParallaxLayers];
        [self _initHudLayer];
        [self _initDoors];
        
        // start loop
        [[CCDirector sharedDirector].scheduler scheduleSelector:@selector(_tick:) forTarget:self interval:0 paused:NO];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    
	// don't forget to call "super dealloc"
    [_characterEntity release];
    _characterEntity = nil;
    
	[super dealloc];
}

#pragma mark - delegates methods

-(void)adjustAdSize {
	//1
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.2];
	//2
	CGSize adSize = [adWhirlView actualAdSize];
	//3
	CGRect newFrame = adWhirlView.frame;
	//4
	newFrame.size.height = adSize.height;
    
   	//5
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //6
	newFrame.size.width = winSize.width;
	//7
	newFrame.origin.x = (self.adWhirlView.bounds.size.width - adSize.width)/2;
    
    //8
	newFrame.origin.y = (winSize.height - adSize.height);
	//9
	adWhirlView.frame = newFrame;
	//10
	[UIView commitAnimations];
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlVieww {
    //1
    [adWhirlView rotateToOrientation:UIInterfaceOrientationLandscapeRight];
	//2
    [self adjustAdSize];
    
}

- (NSString *)adWhirlApplicationKey {
    return @"8216d8afbff24ec185243ba89019e025";
}

- (UINavigationController *)viewControllerForPresentingModalView {
//    return viewController;
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    viewController = [app navController];
    return viewController;
}

// handle shake event
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    CGFloat absAccelerationX = abs(acceleration.x);
    CGFloat absAccelerationY = abs(acceleration.y);
    
    // very hard shake
	if (absAccelerationX > _minShakeX || absAccelerationY > _minShakeY) {
        [_characterEntity shakeWithAcceleration:ccp(acceleration.x, acceleration.y)];
		
		// play quote or dizzy
//		if (acceleration.x > 0.8 || acceleration.y > 0.8) {
			// check whether show dizzy look
			if (_totalTime - _previousShakeTime < _accumulateAccelerationInterval) {
				_totalAcceleration += absAccelerationX + absAccelerationY;
				
				if (_totalAcceleration > _totalAccelerationToDizzy) {
					_characterDizzyOnStopShake = YES;
				}
			} 
			// reset total acceleration
			else {
				_totalAcceleration = absAccelerationX + absAccelerationY;
			}
			
			_previousShakeTime = _totalTime;
			
			// play random quote
			_sayQuoteOnStopShake = YES;
//		}
	}
	// shake stops
	else if (_totalTime - _previousShakeTime > _shakeResultTime) {
		if (_characterDizzyOnStopShake) {
			_characterDizzyOnStopShake = NO;
			_sayQuoteOnStopShake = NO;
			[_characterEntity isCharacterDizzy:YES];
		}
		else if (_sayQuoteOnStopShake) {
			_sayQuoteOnStopShake = NO;
			[[AppManager sharedManager].quoteManager playRandomQuote];
		}
	}
    
    // parallax movement
    CGPoint newPosition = ccp(acceleration.x, acceleration.y);
    newPosition = ccpClamp(newPosition, ccp(-1, -1), ccp(1, 1));
    [_parallaxNode runAction:[CCMoveTo actionWithDuration:0.05 position:newPosition]];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    _isSelectedHead = [_characterEntity isSelectedHeadWithTouchAt:touchLocation];

    return TRUE;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_isSelectedHead) {
        [[AppManager sharedManager].quoteManager playRandomQuote];
    }
    
    _isSelectedHead = NO;
    [_characterEntity onReleaseHead];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
    if (_isSelectedHead) {
        [_characterEntity moveHeadBy:translation];
    }
}

#pragma mark - public methods

-(void)onExit {
    if (adWhirlView) {
        [adWhirlView removeFromSuperview];
        [adWhirlView replaceBannerViewWith:nil];
        [adWhirlView ignoreNewAdRequests];
        [adWhirlView setDelegate:nil];
        self.adWhirlView = nil;
    }
    [super onExit];
}

-(void) onEnter
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    viewController = [app navController];
    
    self.adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];

    self.adWhirlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    [adWhirlView updateAdWhirlConfig];
    
	CGSize adSize = [adWhirlView actualAdSize];
    CGSize winSize = [CCDirector sharedDirector].winSize;

    self.adWhirlView.frame = CGRectMake((winSize.width/2)-(adSize.width/2),winSize.height-adSize.height,adSize.width,adSize.height);
    
	self.adWhirlView.clipsToBounds = YES;

//    [viewController.view addSubview:adWhirlView];
//    [viewController.view bringSubviewToFront:adWhirlView];
    
	[super onEnter];

    CGFloat doorMoveTime = [[[AppManager sharedManager].dataManager constantForKeyPath:@"DoorMoveTime"] floatValue];
    
    // left door
    id leftMoveAction = [CCMoveTo actionWithDuration:doorMoveTime position:ccp(-_leftDoor.contentSize.width/2, _leftDoor.position.y)];
    id leftHideComplete = [CCCallFuncN actionWithTarget:self selector:@selector(_onFinishMoveNode:)];
    id leftHideSequence = [CCSequence actions:leftMoveAction, leftHideComplete, nil];    
    [_leftDoor runAction:leftHideSequence];

    // right door
    id rightMoveAction = [CCMoveTo actionWithDuration:doorMoveTime position:ccp(winSize.width + _rightDoor.contentSize.width/2, _rightDoor.position.y)];
    id rightHideComplete = [CCCallFuncN actionWithTarget:self selector:@selector(_onFinishMoveNode:)];
    id rightHideSequence = [CCSequence actions:rightMoveAction, rightHideComplete, nil];
    [_rightDoor runAction:rightHideSequence];
    
    [[AppManager sharedManager].musicManager playRandomMusic];
}

#pragma mark - private methods

- (ccTime) _generateNextSpawnCoinTime {
    return [UtilityManager randomFloatFrom:_minSpawnCoinTime to:_maxSpawnCoinTime];
}

- (void) _initDoors {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    _leftDoor = [CCSprite spriteWithSpriteFrameName:@"left_door.jpg"];
    _leftDoor.position = ccp((size.width - _leftDoor.contentSize.width)/2, size.height/2);
    [self addChild:_leftDoor];
    
    _rightDoor = [CCSprite spriteWithSpriteFrameName:@"right_door.jpg"];
    _rightDoor.position = ccp((size.width + _leftDoor.contentSize.width)/2, size.height/2);
    [self addChild:_rightDoor];
}

- (void) _initHudLayer {
    // music layer
    [self addChild:[[AppManager sharedManager].musicManager musicControlMenu]];
//    [self addChild:[[AppManager sharedManager].musicManager playListLayer]];
    
    // lottery button
    [self addChild:[[AppManager sharedManager].lotteryManager lotteryLayer]];
    
    
}

- (void) _initParallaxLayers {
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGPoint midPoint = ccp(size.width/2, size.height/2);
    
    DataManager *dataManager = [AppManager sharedManager].dataManager;
    
    // parallax node
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    // background 1 layer
    CGPoint background1Ratio = CGPointFromString([dataManager constantForKeyPath:@"Parallax.Background1Ratio"]);
    CCSprite *bg1Layer = [CCSprite spriteWithSpriteFrameName:@"background_1.jpg"];
    [_parallaxNode addChild:bg1Layer z:0 parallaxRatio:background1Ratio positionOffset:midPoint];
    
    // coin layer
    CGPoint coinLayerRatio = CGPointFromString([dataManager constantForKeyPath:@"Parallax.CoinLayerRatio"]);
    CCSpriteBatchNode *coinLayer = [[AppManager sharedManager].coinManager coinLayer];
    [coinLayer setPosition:midPoint];
    [_parallaxNode addChild:coinLayer z:1 parallaxRatio:coinLayerRatio positionOffset:midPoint];
    
    // background 2 layer
    CGPoint background2Ratio = CGPointFromString([dataManager constantForKeyPath:@"Parallax.Background2Ratio"]);
    CGPoint background2Position = ccp(midPoint.x, size.height/5);
    CCSprite *bg2Layer = [CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    [_parallaxNode addChild:bg2Layer z:2 parallaxRatio:background2Ratio positionOffset:background2Position];
    
    // character entity
    CGPoint characterRatio = CGPointFromString([dataManager constantForKeyPath:@"Parallax.CharacterRatio"]);
    _characterEntity = [AppManager sharedManager].characterEntity;
    [_parallaxNode addChild:[_characterEntity characterNode] z:2 parallaxRatio:characterRatio positionOffset:CGPointZero];
    
    // foreground layer
    CGPoint foregroundRatio = CGPointFromString([dataManager constantForKeyPath:@"Parallax.ForegroundRatio"]);
    CGPoint foregroundPosition = ccp(midPoint.x, size.height/8);
    CCSprite *foregroundLayer = [CCSprite spriteWithSpriteFrameName:@"foreground.png"];
    [_parallaxNode addChild:foregroundLayer z:3 parallaxRatio:foregroundRatio positionOffset:foregroundPosition];
}

- (void) _onFinishMoveNode:(CCNode *)node {
    [self removeChild:node];
    node = nil;
}

-(void) _tick:(ccTime)dt {
    CGFloat frameTime = dt;
    NSInteger stepsPerformed = 0;
    
	_totalTime += dt;
	
    while ((frameTime > 0.0f) && (stepsPerformed < _maxStepCount)) {
        CGFloat deltaTime = MIN(frameTime, _fixedTimestep);
        frameTime -= deltaTime;
        
        if (frameTime < _minTimestep) {
            deltaTime += frameTime;
            frameTime = 0.0f;
        }
        
        if (!_isSelectedHead) {
            [_characterEntity update:deltaTime];
        }
        
        stepsPerformed++;
    }
    
    if (_totalTime > _nextSpawnCoinTime) {
        [[AppManager sharedManager].coinManager spawnCoin];
        _nextSpawnCoinTime = _totalTime + [self _generateNextSpawnCoinTime];
    }
}

@end

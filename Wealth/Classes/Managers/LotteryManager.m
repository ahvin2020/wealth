//
//  BgMusicManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "LotteryManager.h"
#import "AppManager.h"
#import "DataManager.h"
#import "UtilityManager.h"

typedef enum {
   kLotteryStateHide = 1,
   kLotteryStateShow = 2,
   kLotteryStateTweening = 3,
   kLotteryStateLabelsAppearing = 4,
} lotteryStateId;

@interface LotteryManager ()

- (void) _initLotteryMenu;
- (void) _initLotteryLabelAndParticleWithPosition:(CGPoint)position fontSize:(NSInteger)fontSize;
- (void) _onLotteryBtnSelected;
- (void) _onLotteryScrollSelected;
- (void) _startShowLotteryLabels;
- (void) _onFinishHideScroll;
- (void) _showLotteryLabel:(ccTime)dt;

@end

@implementation LotteryManager

#pragma mark - init and dealloc

- (id) init {
    if (self = [super init]) {
       _lotteryLabelAppearTime = 0.4f;
       
       _nextVisibleLabel = 0;
       _currentLotteryState = kLotteryStateHide;
       
       _lotteryLayer = [[CCLayer alloc] init];
       
       [self _initLotteryMenu];
    }
    
    return self;
}

- (void) dealloc {
//    [_lotteryScroll release];
//    _lotteryScroll = nil;
   
    [super dealloc];
}

#pragma mark - public methods

- (CCLayer *) lotteryLayer {
	return _lotteryLayer;
}

#pragma mark - private methods

// init lottery menu
- (void) _initLotteryMenu {
   CGSize winSize = [CCDirector sharedDirector].winSize;
   CGFloat halfWidth = winSize.width/2;
   
   // constants
   CGFloat lotteryScrollShowPosY = winSize.height * 0.18;
   CGFloat lotteryScrollTweenTime = 0.8f;
   
   CGFloat musicBtnYPos = [[[AppManager sharedManager].dataManager constantForKeyPath:@"MusicControls.MusicBtnYPos"] floatValue];
   CCSprite *toggleMenuBtn = [CCSprite spriteWithSpriteFrameName:@"music_btn_up.png"];
                     
   // lottery btn
   CCSprite *normalBtn = [CCSprite spriteWithSpriteFrameName:@"lottery_btn_up.png"];
   CCSprite *selectedBtn = [CCSprite spriteWithSpriteFrameName:@"lottery_btn_down.png"];
   CCMenuItemImage *lotteryBtn = [CCMenuItemImage itemWithNormalSprite:normalBtn selectedSprite:selectedBtn target:self selector:@selector(_onLotteryBtnSelected)];
   lotteryBtn.position = ccp(winSize.width - normalBtn.contentSize.width/2, winSize.height - musicBtnYPos - toggleMenuBtn.contentSize.height/2);
   
   // lottery scroll
   CCSprite *normalScroll = [CCSprite spriteWithSpriteFrameName:@"lottery_scroll_bg.png"];
   CCSprite *selectedScroll = [CCSprite spriteWithSpriteFrameName:@"lottery_scroll_bg.png"];
   _lotteryScroll = [CCMenuItemImage itemWithNormalSprite:normalScroll selectedSprite:selectedScroll target:self selector:@selector(_onLotteryScrollSelected)];
   
   CGFloat lotteryScrollHalfWidth = _lotteryScroll.contentSize.width/2;
   CGFloat lotteryScrollHalfHeight = _lotteryScroll.contentSize.height/2;
   
   _lotteryScroll.position = ccp(halfWidth, -lotteryScrollHalfHeight);
   _lotteryScroll.visible = NO;
   
   // hide scroll
   CCMoveTo *hideMoveTo = [CCMoveTo actionWithDuration:lotteryScrollTweenTime position:ccp(halfWidth, -lotteryScrollHalfHeight)];
   CCEaseBackIn *hideScrollTween = [CCEaseBackIn actionWithAction:hideMoveTo];
   id hideScrollComplete = [CCCallFunc actionWithTarget:self selector:@selector(_onFinishHideScroll)];
   _hideLotteryScroll = [[CCSequence actions:hideScrollTween, hideScrollComplete, nil] retain];
   
   // show scroll
   CCMoveTo *showMoveTo = [CCMoveTo actionWithDuration:lotteryScrollTweenTime position:ccp(halfWidth, lotteryScrollShowPosY)];
   CCEaseBackOut *showScrollTween = [CCEaseBackOut actionWithAction:showMoveTo];
   id startShowLabels = [CCCallFunc actionWithTarget:self selector:@selector(_startShowLotteryLabels)];
   _showLotteryScroll = [[CCSequence actions:showScrollTween, startShowLabels, nil] retain];
   
   // lottery menu
   _lotteryMenu = [[CCMenu menuWithItems:lotteryBtn, _lotteryScroll, nil] retain];
   [_lotteryMenu setPosition:CGPointZero];
   [_lotteryLayer addChild:_lotteryMenu];
   
   // lottery labels and particle node
   _lotteryLabels = [[CCArray arrayWithCapacity:4] retain];
   _particleSystems = [[CCArray arrayWithCapacity:4] retain];
   _particleBatchNode = [CCParticleBatchNode batchNodeWithFile:@"particle_image.png" capacity:1200];
   
   [_lotteryScroll addChild:_particleBatchNode];
   
   CGFloat lotteryLabelXDistance = _lotteryScroll.contentSize.width * (1 - 0.35) * 1/4;
   NSInteger fontSize = lotteryLabelXDistance * 1.4;
   [self _initLotteryLabelAndParticleWithPosition:ccp(lotteryScrollHalfWidth - lotteryLabelXDistance * 1.5, lotteryScrollHalfHeight) fontSize:fontSize];
   [self _initLotteryLabelAndParticleWithPosition:ccp(lotteryScrollHalfWidth - lotteryLabelXDistance * 0.5, lotteryScrollHalfHeight) fontSize:fontSize];
   [self _initLotteryLabelAndParticleWithPosition:ccp(lotteryScrollHalfWidth + lotteryLabelXDistance * 0.5, lotteryScrollHalfHeight) fontSize:fontSize];
   [self _initLotteryLabelAndParticleWithPosition:ccp(lotteryScrollHalfWidth + lotteryLabelXDistance * 1.5, lotteryScrollHalfHeight) fontSize:fontSize];
}

- (void) _initLotteryLabelAndParticleWithPosition:(CGPoint)position fontSize:(NSInteger)fontSize {
   // init label
   CCLabelTTF *label = [CCLabelTTF labelWithString:@"9" fontName:@"Marker Felt" fontSize:fontSize];
   label.position = position;
   label.visible = NO;
   
   [_lotteryScroll addChild:label];
   [_lotteryLabels addObject:label];
   
   // init particle
   CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
   ps.position = position;
   [ps stopSystem];
   
   [_particleBatchNode addChild:ps];
   [_particleSystems addObject:ps];
}

- (void) _onLotteryBtnSelected {
   // lottery scroll hidden?
   if (_currentLotteryState == kLotteryStateHide) {
      // show
      _lotteryScroll.visible = YES;
      _currentLotteryState = kLotteryStateTweening;
      [_lotteryScroll runAction:_showLotteryScroll];
   }
   // lottery scroll shown?
   else if (_currentLotteryState == kLotteryStateShow) {
      // hide
      _currentLotteryState = kLotteryStateTweening;
      [_lotteryScroll runAction:_hideLotteryScroll];
   }
}

- (void) _onLotteryScrollSelected {
   [self _startShowLotteryLabels];
}

- (void) _onFinishHideScroll {
   _lotteryScroll.visible = NO;
   _currentLotteryState = kLotteryStateHide;
   
   CCLabelTTF *label;
   CCARRAY_FOREACH(_lotteryLabels, label) {
      label.visible = NO;
   }
}

- (void) _startShowLotteryLabels {
   if (_currentLotteryState == kLotteryStateLabelsAppearing) {
      [self.scheduler unscheduleSelector:@selector(_showLotteryLabel:) forTarget:self];
   }
   
   _currentLotteryState = kLotteryStateLabelsAppearing;
   
   _nextVisibleLabel = 0;
   
   [self.scheduler scheduleSelector:@selector(_showLotteryLabel:) forTarget:self interval:_lotteryLabelAppearTime repeat:3 delay:0 paused:NO];
}

- (void) _showLotteryLabel:(ccTime)dt {
   // label
   CCLabelTTF *label = [_lotteryLabels objectAtIndex:_nextVisibleLabel];
   
   NSInteger number = [UtilityManager randomIntegerFrom:0 to:9];
   [label setString:[NSString stringWithFormat:@"%i", number]];
   label.visible = YES;
   
   // particle system
   CCParticleSystemQuad *ps = [_particleSystems objectAtIndex:_nextVisibleLabel];
   [ps resetSystem];
   
   _nextVisibleLabel++;
   
   if (_nextVisibleLabel == 4) {
      _currentLotteryState = kLotteryStateShow;
   }
}

@end
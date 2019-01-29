//
//  QuoteManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "cocos2d.h"

@interface LotteryManager : CCNode {
    @private
    // constants
    CGFloat _lotteryLabelAppearTime;
    
    // variables
    NSInteger _nextVisibleLabel;
    NSInteger _currentLotteryState;
    CCSequence *_showLotteryScroll;
    CCSequence *_hideLotteryScroll;
    
    // sprites
    CCMenu *_lotteryMenu;
    CCLayer *_lotteryLayer;
    CCMenuItemImage *_lotteryScroll;
    CCArray *_lotteryLabels;
    CCArray *_particleSystems;
    CCParticleBatchNode *_particleBatchNode;
}

- (CCLayer *) lotteryLayer;

@end

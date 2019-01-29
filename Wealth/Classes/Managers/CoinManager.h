//
//  CoinManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 22/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CoinManager : NSObject {
    @private
    CGFloat _minDropDuration;
    CGFloat _maxDropDuration;
    
    NSInteger _nextCoinIndex;
    NSInteger _poolSize;
    CCArray *_coinArray;
    CCSpriteBatchNode *_coinLayer;
}

- (CCSpriteBatchNode *) coinLayer;
- (void) spawnCoin;

@end

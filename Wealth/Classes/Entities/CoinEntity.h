//
//  CoinEntity.h
//  Wealth
//
//  Created by Tan Kel Vin on 22/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CoinEntity : CCSprite {
    @private
    BOOL _isActive;
    CGSize _halfWinSize;
}

- (void) setup;
- (void) spawnWithRotation:(CGFloat)rotation withDuration:(CGFloat)dropDuration;

@end

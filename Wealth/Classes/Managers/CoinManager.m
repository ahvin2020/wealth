//
//  CoinManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 22/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "CoinManager.h"
#import "AppManager.h"
#import "CoinEntity.h"
#import "DataManager.h"
#import "UtilityManager.h"

@implementation CoinManager

#pragma mark - init and dealloc

- (id) init {
    if (self = [super init]) {
        DataManager *dataManager = [AppManager sharedManager].dataManager;
        _minDropDuration = [[dataManager constantForKeyPath:@"Coins.MinDropDuration"] floatValue];
        _maxDropDuration = [[dataManager constantForKeyPath:@"Coins.MaxDropDuration"] floatValue];
        _poolSize = [[[AppManager sharedManager].dataManager constantForKeyPath:@"Coins.PoolSize"] floatValue];
        _nextCoinIndex = 0;
        
        _coinLayer = [[CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr.ccz"] retain];
        _coinArray = [[CCArray arrayWithCapacity:_poolSize] retain];
        
        for (NSInteger i=0; i<_poolSize; i++) {
            CoinEntity *coinEntity = [CoinEntity spriteWithSpriteFrameName:@"coin_1.png"];
            [coinEntity setup];
            
            [_coinArray addObject:coinEntity];
            [_coinLayer addChild:coinEntity];
        }
    }
    
    return self;
}

- (void) dealloc {

    [super dealloc];
}

#pragma mark - public methods

- (CCSpriteBatchNode *) coinLayer {
    return _coinLayer;
}

- (void) spawnCoin {
    CoinEntity *coinEntity = [_coinArray objectAtIndex:_nextCoinIndex];
    CGFloat rotation = [UtilityManager randomFloatFrom:0 to:359];
    CGFloat dropDuration = [UtilityManager randomFloatFrom:_minDropDuration to:_maxDropDuration];

    [coinEntity spawnWithRotation:rotation withDuration:dropDuration];

    _nextCoinIndex = (_nextCoinIndex + 1) % _poolSize;
}

#pragma mark - private methods

@end

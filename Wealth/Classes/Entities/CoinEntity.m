//
//  CoinEntity.m
//  Wealth
//
//  Created by Tan Kel Vin on 22/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "CoinEntity.h"
#import "UtilityManager.h"

@interface CoinEntity ()

- (void) _onFinishDrop;

@end

@implementation CoinEntity

#pragma mark - init and dealloc

- (void) dealloc {

	[super dealloc];
}

#pragma mark - public methods

- (void) setup {
    _isActive = NO;
    _halfWinSize = [CCDirector sharedDirector].winSize;
    _halfWinSize.width /= 2;
    _halfWinSize.height /= 2;

    self.visible = NO;
}

- (void) spawnWithRotation:(CGFloat)rotation withDuration:(CGFloat)dropDuration {
    _isActive = YES;
    
    self.rotation = rotation;
    
    CGSize spriteSize = self.boundingBox.size;
    
    CGFloat maxX = _halfWinSize.width - spriteSize.width/2;
    CGFloat xPosition = [UtilityManager randomFloatFrom:-maxX to:maxX];
    CGFloat yPosition = _halfWinSize.height + spriteSize.height/2;
    
    self.position = ccp(xPosition, yPosition);
    self.visible = YES;

    id moveAction = [CCMoveTo actionWithDuration:dropDuration position:ccp(xPosition, -yPosition)];
    id dropComplete = [CCCallFunc actionWithTarget:self selector:@selector(_onFinishDrop)];
    [self runAction:[CCSequence actions:moveAction, dropComplete, nil]];
}

#pragma mark - public methods

- (void) _onFinishDrop {
    _isActive = NO;
    self.visible = NO;
}

@end

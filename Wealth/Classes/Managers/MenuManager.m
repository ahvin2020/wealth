//
//  MenuManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 30/12/12.
//  Copyright (c) 2012 Tan Kel Vin. All rights reserved.
//

#import "MenuManager.h"
#import "MainLayer.h"

@implementation MenuManager

#pragma mark - init and dealloc

- (id) init {
	if( (self=[super init])) {

	}
    
	return self;
}

// deallocate
- (void) dealloc {
    [_mainScene release];
    _mainScene = nil;
    
    [super dealloc];
}

#pragma mark - public methods

- (void) startup {
    if (_mainScene == nil) {
        _mainScene = [[MainLayer scene] retain];
    }
    
    [[CCDirector sharedDirector] runWithScene: _mainScene];
    
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:_mainScene]];
}


#pragma mark - delegate methods

#pragma mark - private methods

@end

//
//  DataManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 30/12/12.
//  Copyright (c) 2012 Tan Kel Vin. All rights reserved.
//

#import "DataManager.h"

#import "cocos2d.h"

@implementation DataManager

#pragma mark - init and dealloc

- (id) init {
    if (self = [super init]) {
        // load constants
		_constantDictionary = [self loadDictionaryFromPlist:CONSTANTS_PLIST];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SPRITES_PLIST];
    }
	
    return self;
}

- (void)dealloc {
//    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
//    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
//    [_animationsDictionary release];
//    _animationsDictionary = nil;
    
    [_constantDictionary release];
    _constantDictionary = nil;
    
    [super dealloc];
}

#pragma mark - public methods

- (id) constantForKeyPath:(NSString *)keyPath {
    CCArray *keyArray = [CCArray arrayWithNSArray:[keyPath componentsSeparatedByString:@"."]];
    NSAssert(keyArray != nil, @"Invalid keypath %@", keyPath);
    
    id object = _constantDictionary;
    
    id key;
    CCARRAY_FOREACH(keyArray, key) {
        object = [[object objectForKey:key] copy];
        NSAssert(object != nil, @"Object for %@ key is nil", key);
    }
	
    return object;
}

- (NSDictionary *) loadDictionaryFromPlist:(NSString *)name {
    NSString *plist = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    return [[NSDictionary alloc] initWithContentsOfFile:plist];
}

#pragma mark - private methods

@end

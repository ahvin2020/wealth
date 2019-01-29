//
//  AppManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 30/12/12.
//  Copyright (c) 2012 Tan Kel Vin. All rights reserved.
//

#import "AppManager.h"

#import "CharacterEntity.h"
#import "CoinManager.h"
#import "DataManager.h"
#import "LotteryManager.h"
#import "MusicManager.h"
#import "MenuManager.h"
#import "QuoteManager.h"

@interface AppManager ()

@property (nonatomic, retain, readwrite) CharacterEntity *characterEntity;
@property (nonatomic, retain, readwrite) CoinManager *coinManager;
@property (nonatomic, retain, readwrite) DataManager *dataManager;
@property (nonatomic, retain, readwrite) LotteryManager *lotteryManager;
@property (nonatomic, retain, readwrite) MenuManager *menuManager;
@property (nonatomic, retain, readwrite) MusicManager *musicManager;
@property (nonatomic, retain, readwrite) QuoteManager *quoteManager;

@end

@implementation AppManager

@synthesize characterEntity = _characterEntity;
@synthesize coinManager = _coinManager;
@synthesize dataManager = _dataManager;
@synthesize lotteryManager = _lotteryManager;
@synthesize menuManager = _menuManager;
@synthesize musicManager = _musicManager;
@synthesize quoteManager = _quoteManager;

static AppManager *_sharedManager = nil; // singleton variable

#pragma mark - init and dealloc

// deallocate
- (void) dealloc {
    self.dataManager = nil;
    self.menuManager = nil;
    
    [_sharedManager release];
    _sharedManager = nil;
    
    [super dealloc];
}

#pragma mark - public methods

+ (AppManager *) startup {
    if (!_sharedManager && self == [AppManager class]) {
        _sharedManager = [[AppManager alloc] init];
        
        // init data manager
        _sharedManager.dataManager = [[DataManager alloc] init];
        
        // init entity
        _sharedManager.characterEntity= [[CharacterEntity alloc] init];
        
        // init core managers
        _sharedManager.coinManager = [[CoinManager alloc] init];
        _sharedManager.lotteryManager = [[LotteryManager alloc] init];
        _sharedManager.menuManager = [[MenuManager alloc] init];
        _sharedManager.musicManager = [[MusicManager alloc] init];
		_sharedManager.quoteManager = [[QuoteManager alloc] init];
    }
    
    return _sharedManager;
}

// get singleton variable
+ (AppManager *) sharedManager {
    return _sharedManager;
}

#pragma mark - private methods

@end

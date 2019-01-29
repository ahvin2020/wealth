//
//  AppManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 30/12/12.
//  Copyright (c) 2012 Tan Kel Vin. All rights reserved.
//

@class CharacterEntity;
@class CoinManager;
@class DataManager;
@class LotteryManager;
@class MenuManager;
@class MusicManager;
@class QuoteManager;

@interface AppManager : NSObject {
    @private
    CharacterEntity *_characterEntity;
    CoinManager *_coinManager;
    DataManager *_dataManager;
    LotteryManager *_lotteryManager;
    MenuManager *_menuManager;
    MusicManager *_musicManager;
	QuoteManager *_quoteManager;
}

@property (nonatomic, retain, readonly) CharacterEntity *characterEntity;
@property (nonatomic, retain, readonly) CoinManager *coinManager;
@property (nonatomic, retain, readonly) DataManager *dataManager;
@property (nonatomic, retain, readonly) LotteryManager *lotteryManager;
@property (nonatomic, retain, readonly) MenuManager *menuManager;
@property (nonatomic, retain, readonly) MusicManager *musicManager;
@property (nonatomic, retain, readonly) QuoteManager *quoteManager;

+ (AppManager *) startup;
+ (AppManager *) sharedManager;

@end

//
//  QuoteManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "cocos2d.h"
#import "CDAudioManager.h"

@interface QuoteManager : NSObject <CDLongAudioSourceDelegate> {
    @private
    CCArray *_quotes;
	CDLongAudioSource *_currentSound;
	
	BOOL _isQuotePlaying;
	NSInteger _previousQuote;
	NSInteger _quoteCount;
}

- (void) playRandomQuote;

@property (nonatomic, assign, readonly) BOOL isQuotePlaying;

@end

//
//  BgMusicManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "QuoteManager.h"
#import "AppManager.h"
#import "CharacterEntity.h"
#import "DataManager.h"
#import "UtilityManager.h"

@interface QuoteManager ()

@end

@implementation QuoteManager

@synthesize isQuotePlaying = _isQuotePlaying;

#pragma mark - init and dealloc

- (id) init {
    if (self = [super init]) {
		_isQuotePlaying = NO;
		_previousQuote = -1;
		
		// init quotes
        _quotes = [[CCArray arrayWithNSArray:[[AppManager sharedManager].dataManager constantForKeyPath:@"QuoteList"]] retain];
		_quoteCount = [_quotes count];
		
		_currentSound = [[CDAudioManager sharedManager] audioSourceForChannel:kASC_Right];
		_currentSound.delegate = self;
		_currentSound.backgroundMusic = NO;
    }
    
    return self;
}

- (void) dealloc {
    [_quotes release];
    _quotes = nil;
    
    [super dealloc];
}

#pragma mark - delegate methods

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource {
	_isQuotePlaying = NO;
    
    [[AppManager sharedManager].characterEntity isCharacterTalking:NO];
}

#pragma mark - public methods

- (void) playRandomQuote {
	NSInteger newQuoteIndex = -1;
	
	// select qoute which is not previous qoute
	newQuoteIndex = [UtilityManager randomIntegerFrom:0 to:(_quoteCount - 1)];
	if (newQuoteIndex == _previousQuote) {
		newQuoteIndex = (newQuoteIndex + 1) % _quoteCount;
	}
	
	_isQuotePlaying = YES;
	_previousQuote = newQuoteIndex;
	
	[_currentSound stop];
	[_currentSound load:[_quotes objectAtIndex:newQuoteIndex]];
	[_currentSound play];
    
    [[AppManager sharedManager].characterEntity isCharacterTalking:YES];
}

#pragma mark - private methods

@end
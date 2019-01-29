//
//  BgMusicManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "cocos2d.h"
//#import "CCItemsScroller.h"

@interface MusicManager : NSObject /*<CCItemsScrollerDelegate>*/ {
    @private
    id _hidePreviousBtnSequence;
    id _hidePlayBtnSequence;
    id _hidePauseBtnSequence;
    id _hideNextBtnSequence;
    id _hideToggleListBtnSequence;
    
    id _showPreviousBtnSequence;
    id _showPlayBtnSequence;
    id _showPauseBtnSequence;
    id _showNextBtnSequence;
//    id _showToggleListBtnSequence;
    
    CGPoint _playListHidePos;
    
    // tween time
//    CGFloat _tweenTime;
    
    NSInteger _currentSongIndex;
    NSInteger _songCount;
    
    // music controls
    CCMenuItemImage *_toggleMenuBtn;
    CCMenuItemImage *_previousBtn;
    CCMenuItemImage *_playBtn;
    CCMenuItemImage *_pauseBtn;
    CCMenuItemImage *_nextBtn;
//    CCMenuItemImage *_toggleListBtn;
    
    CCMenu *_musicControlMenu;
    CCLayer *_playListLayer;
    
//    CCItemsScroller *_playList;
    
    NSArray *_musicList;

    NSInteger _currentMusicMenuState;
//    BOOL _isShowingMusicMenu;
//    BOOL _isShowingPlayList;
}

- (void) playRandomMusic;
- (void) playMusic:(NSInteger)songIndex;
- (CCMenu *) musicControlMenu;
//- (CCLayer *) playListLayer;

@end

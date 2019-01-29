//
//  BgMusicManager.m
//  Wealth
//
//  Created by Tan Kel Vin on 5/1/13.
//  Copyright 2013 Tan Kel Vin. All rights reserved.
//

#import "MusicManager.h"
#import "AppManager.h"
//#import "CCSelectableItem.h"
#import "CDAudioManager.h"
#import "DataManager.h"
#import "UtilityManager.h"

typedef enum {
    kMusicMenuStateHide = 1,
    kMusicMenuStateShow = 2,
    kMusicMenuStateTweening = 3,
} musicMenuStateId;

@interface MusicManager ()

- (void) _backgroundMusicFinished;
- (CCMenuItemImage *) _initButtonWithNormalSpriteName:(NSString *)normalSpriteName selectedSpriteName:(NSString *)selectedSpriteName selector:(SEL)selector;
- (id) _initHideBtnSequenceTo:(CGPoint)position withDuration:(CGFloat)duration;
- (id) _initShowBtnSequenceTo:(CGPoint)position withDuration:(CGFloat)duration;
- (void) _initMusicControls;
- (void) _initPlaylist;
- (void) _nextMusic;
- (void) _onFinishHideMusicMenu:(CCMenuItemImage *)node;
- (void) _onFinishShowMusicMenu:(CCMenuItemImage *)node;
//- (void) _onFinishHidePlaylist:(CCNode *)node;
- (void) _previousMusic;
- (void) _toggleMusic;
- (void) _toggleMusicMenu;
//- (void) _togglePlaylist;
//- (void) _tweenHideNode:(CCNode *)node to:(CGPoint)toPos;
@end


@implementation MusicManager

#pragma mark - init and dealloc

- (id) init {
    if (self = [super init]) {
        [self _initMusicControls];
        [self _initPlaylist];
        
        [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(_backgroundMusicFinished)];
        
//        [_playList setSelectedItemIndex:[UtilityManager randomIntegerFrom:0 to:(_songCount - 1)]];
    }
    
    return self;
}

- (void) dealloc {
//    [_playList release];
//    _playList = nil;
    
    [_musicControlMenu release];
    _musicControlMenu = nil;
    
    [_playListLayer release];
    _playListLayer = nil;
    
    [super dealloc];
}

/*
#pragma mark - delegate methods

-(void)itemsScroller:(CCItemsScroller *)sender didSelectItemIndex:(int)index {
//    if (_playListLayer.visible) {
        NSString *songName = ((CCSelectableItem *)[_playList getSelectedItem]).itemId;
        [[CDAudioManager sharedManager] playBackgroundMusic:songName loop:NO];
//    }

    if (_currentMusicMenuState == kMusicMenuStateShow) {
        _playBtn.visible = NO;
        _pauseBtn.visible = YES;
    }
}

- (void)itemsScroller:(CCItemsScroller *)sender didUnSelectItemIndex:(int)index {
}
*/

#pragma mark - public methods

- (CCMenu *) musicControlMenu {
    return _musicControlMenu;
}

//- (CCLayer *) playListLayer {
//    return _playListLayer;
//}

- (void) playMusic:(NSInteger)songIndex {
    _currentSongIndex = songIndex;
    
    NSString *songName = [_musicList objectAtIndex:_currentSongIndex];
    [[CDAudioManager sharedManager] playBackgroundMusic:songName loop:NO];
        
    if (_currentMusicMenuState == kMusicMenuStateShow) {
        _playBtn.visible = NO;
        [_playBtn setIsEnabled:NO];
        
        _pauseBtn.visible = YES;
        [_pauseBtn setIsEnabled:YES];
    }
}

- (void) playRandomMusic {
    _currentSongIndex = [UtilityManager randomIntegerFrom:0 to:_songCount - 1];
    [self playMusic:_currentSongIndex];
}

#pragma mark - private methods

- (void) _backgroundMusicFinished {
    [self _nextMusic];
}

- (CCMenuItemImage *) _initButtonWithNormalSpriteName:(NSString *)normalSpriteName selectedSpriteName:(NSString *)selectedSpriteName selector:(SEL)selector {
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:normalSpriteName];
    CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:selectedSpriteName];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:selector];

    return button;
}

// init bg music controls
- (void) _initMusicControls {
    _currentMusicMenuState = kMusicMenuStateHide;

    DataManager *dataManager = [AppManager sharedManager].dataManager;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGFloat musicBtnYPos = [[dataManager constantForKeyPath:@"MusicControls.MusicBtnYPos"] floatValue];

    // button speed
    CGFloat tweenTime = [[dataManager constantForKeyPath:@"MusicControls.TweenTime"] floatValue];

    // toggle music menu button
    _toggleMenuBtn = [self _initButtonWithNormalSpriteName:@"music_btn_up.png" selectedSpriteName:@"music_btn_down.png" selector:@selector(_toggleMusicMenu)];
    _toggleMenuBtn.position = ccp(_toggleMenuBtn.contentSize.width/2, winSize.height - musicBtnYPos - _toggleMenuBtn.contentSize.height/2);
    CGPoint toggleMenuBtnPos = _toggleMenuBtn.position;
    
    // previous button
    _previousBtn = [self _initButtonWithNormalSpriteName:@"prev_btn_up.png" selectedSpriteName:@"prev_btn_down.png" selector:@selector(_previousMusic)];
    _previousBtn.position = toggleMenuBtnPos;
    _previousBtn.visible = NO;
    [_previousBtn setIsEnabled:NO];
    
    // play music button
    _playBtn = [self _initButtonWithNormalSpriteName:@"play_btn_up.png" selectedSpriteName:@"play_btn_down.png" selector:@selector(_toggleMusic)];
    _playBtn.position = toggleMenuBtnPos;
    _playBtn.visible = NO;
    [_playBtn setIsEnabled:NO];
    
    // pause button
    _pauseBtn = [self _initButtonWithNormalSpriteName:@"pause_btn_up.png" selectedSpriteName:@"pause_btn_down.png" selector:@selector(_toggleMusic)];
    _pauseBtn.position = toggleMenuBtnPos;
    _pauseBtn.visible = NO;
    [_pauseBtn setIsEnabled:NO];
    
    // next button
    _nextBtn = [self _initButtonWithNormalSpriteName:@"next_btn_up.png" selectedSpriteName:@"next_btn_down.png" selector:@selector(_nextMusic)];
    _nextBtn.position = toggleMenuBtnPos;
    _nextBtn.visible = NO;
    [_nextBtn setIsEnabled:NO];
    
    // toggle music list button
//    _toggleListBtn = [self _initButtonWithNormalSpriteName:@"playlist_btn_up.png" selectedSpriteName:@"playlist_btn_down.png" selector:@selector(_togglePlaylist)];
//    _toggleListBtn.position = toggleMenuBtnPos;
//    _toggleListBtn.visible = NO;
//    [_toggleListBtn setIsEnabled:NO];
    
    _musicControlMenu = [[CCMenu menuWithItems:_nextBtn, _pauseBtn, _playBtn, _previousBtn, _toggleMenuBtn,nil] retain];
    [_musicControlMenu setPosition:CGPointZero];
    
    CGFloat musicBtnXDist = ((_toggleMenuBtn.contentSize.width + _previousBtn.contentSize.width * 4) - winSize.width) / 4;
    CGFloat currentX = _toggleMenuBtn.position.x + _toggleMenuBtn.contentSize.width/2;

    CGPoint previousBtnPos = ccp(currentX + _previousBtn.contentSize.width/2 - musicBtnXDist, toggleMenuBtnPos.y);
    currentX = previousBtnPos.x + _previousBtn.contentSize.width/2;
    
    CGPoint playPauseBtnPos = ccp(currentX + _playBtn.contentSize.width/2 - musicBtnXDist, toggleMenuBtnPos.y);
    currentX = playPauseBtnPos.x + _playBtn.contentSize.width/2;
    
    CGPoint nextBtnPos = ccp(currentX + _nextBtn.contentSize.width/2 - musicBtnXDist, toggleMenuBtnPos.y);
//    currentX = nextBtnPos.x + _nextBtn.contentSize.width/2;
    
//    CGPoint toggleListBtnPos = ccp(currentX + _toggleListBtn.contentSize.width/2 - musicBtnXDist, toggleMenuBtnPos.y);
    
    _hidePreviousBtnSequence = [[self _initHideBtnSequenceTo:toggleMenuBtnPos withDuration:tweenTime] retain];
    _hidePlayBtnSequence = [[self _initHideBtnSequenceTo:toggleMenuBtnPos withDuration:tweenTime] retain];
    _hidePauseBtnSequence = [[self _initHideBtnSequenceTo:toggleMenuBtnPos withDuration:tweenTime] retain];
    _hideNextBtnSequence = [[self _initHideBtnSequenceTo:toggleMenuBtnPos withDuration:tweenTime] retain];
    _hideToggleListBtnSequence = [[self _initHideBtnSequenceTo:toggleMenuBtnPos withDuration:tweenTime] retain];
    
    _showPreviousBtnSequence = [[self _initShowBtnSequenceTo:previousBtnPos withDuration:tweenTime] retain];
    _showPlayBtnSequence = [[self _initShowBtnSequenceTo:playPauseBtnPos withDuration:tweenTime] retain];
    _showPauseBtnSequence = [[self _initShowBtnSequenceTo:playPauseBtnPos withDuration:tweenTime] retain];
    _showNextBtnSequence = [[self _initShowBtnSequenceTo:nextBtnPos withDuration:tweenTime] retain];
//    _showToggleListBtnSequence = [[self _initShowBtnSequenceTo:toggleListBtnPos withDuration:_tweenTime] retain];
}

- (id) _initHideBtnSequenceTo:(CGPoint)position withDuration:(CGFloat)duration {
    id moveAction = [CCMoveTo actionWithDuration:duration position:position];
    id hideComplete = [CCCallFuncN actionWithTarget:self selector:@selector(_onFinishHideMusicMenu:)];
    return [CCSequence actions:moveAction, hideComplete, nil];
}

- (id) _initShowBtnSequenceTo:(CGPoint)position withDuration:(CGFloat)duration {
    id moveAction = [CCMoveTo actionWithDuration:duration position:position];
    id showComplete = [CCCallFuncN actionWithTarget:self selector:@selector(_onFinishShowMusicMenu:)];
    return [CCSequence actions:moveAction, showComplete, nil];
}

// init playlist
- (void) _initPlaylist {
    _musicList = [[[AppManager sharedManager].dataManager constantForKeyPath:@"MusicList"] retain];
    _songCount = [_musicList count];
}

/*
- (void) _initPlaylist {
    NSArray *musicList = [[AppManager sharedManager].dataManager constantForKeyPath:@"MusicList"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _songCount = [musicList count];
    _playListLayer = [[CCLayer alloc] init];
    _isShowingPlayList = NO;
    _playListHidePos = ccp(0, -150);
    
    // create scroll items
    CCArray *scrollItems = [CCArray arrayWithCapacity:_songCount];
    for (NSString *musicName in musicList) {
        CCLabelTTF *itemLabel = [CCLabelTTF labelWithString:musicName fontName:@"Marker Felt" fontSize:15];
        CCSelectableItem *scrollItem = [[CCSelectableItem alloc] initWithItemId:musicName normalColor:ccc4(150, 150, 150, 125) selectectedColor:ccc4(190, 150, 150, 255) width:winSize.width height:50];
        itemLabel.position = ccp(scrollItem.contentSize.width/2, scrollItem.contentSize.height/2);
        [scrollItem addChild:itemLabel];
        
        [scrollItems addObject:scrollItem];
    }
    
    // create scroll menu
    _playList = [CCItemsScroller itemsScrollerWithItems:[scrollItems getNSArray] andOrientation:CCItemsScrollerVertical andRect:CGRectMake(0, 0, winSize.width, 150)];
    _playListLayer.position = _playListHidePos;
    _playListLayer.visible = NO;
    [_playListLayer setPosition:_playListHidePos];
    _playList.delegate = self;

    [_playListLayer addChild:_playList];
}
*/

- (void) _nextMusic {
    NSInteger nextIndex = (_currentSongIndex + 1) % _songCount;
    [self playMusic:nextIndex];
}

- (void) _onFinishHideMusicMenu:(CCMenuItemImage *)node {
    node.visible = NO;
    _currentMusicMenuState = kMusicMenuStateHide;
}

- (void) _onFinishShowMusicMenu:(CCMenuItemImage *)node {
    [node setIsEnabled:YES];
    _currentMusicMenuState = kMusicMenuStateShow;
}

- (void) _onFinishHidePlaylist:(CCNode *)node {
    node.visible = NO;
}

- (void) _previousMusic {
    NSInteger previousIndex = (_currentSongIndex - 1 + _songCount) % _songCount;
   [self playMusic:previousIndex];
}

// turn music on/off
- (void) _toggleMusic {
    if ([CDAudioManager sharedManager].isBackgroundMusicPlaying) {
        [[CDAudioManager sharedManager] pauseBackgroundMusic];
        _playBtn.visible = YES;
        [_playBtn setIsEnabled:YES];
        
        _pauseBtn.visible = NO;
        [_pauseBtn setIsEnabled:NO];
    } else {
        [self playMusic:_currentSongIndex];
        
        _playBtn.visible = NO;
        [_playBtn setIsEnabled:NO];
        
        _pauseBtn.visible = YES;
        [_pauseBtn setIsEnabled:YES];
    }
    
}

// show/hide music menu
- (void) _toggleMusicMenu {
    [_playBtn stopAllActions];
//    [_toggleListBtn stopAllActions];
    
    // is showing music menu?
    if (_currentMusicMenuState == kMusicMenuStateShow) {
        _currentMusicMenuState = kMusicMenuStateTweening;
        
        [_previousBtn setIsEnabled:NO];
        [_playBtn setIsEnabled:NO];
        [_pauseBtn setIsEnabled:NO];
        [_nextBtn setIsEnabled:NO];
//        [_toggleListBtn setIsEnabled:NO];
        
        // hide buttons
        [_previousBtn runAction:_hidePreviousBtnSequence];
        [_playBtn runAction:_hidePlayBtnSequence];
        [_pauseBtn runAction:_hidePauseBtnSequence];
        [_nextBtn runAction:_hideNextBtnSequence];
//        [_toggleListBtn runAction:_hideToggleListBtnSequence];
    }
    // is hiding
    else if (_currentMusicMenuState == kMusicMenuStateHide) {
        _currentMusicMenuState = kMusicMenuStateTweening;
        
        BOOL showPauseButton = [CDAudioManager sharedManager].isBackgroundMusicPlaying;
        
        _previousBtn.visible = YES;
        _playBtn.visible = !showPauseButton;
        _pauseBtn.visible = showPauseButton;
        _nextBtn.visible = YES;
//        _toggleListBtn.visible = YES;
        
        [_previousBtn runAction:_showPreviousBtnSequence];
        [_playBtn runAction:_showPlayBtnSequence];
        [_pauseBtn runAction:_showPauseBtnSequence];
        [_nextBtn runAction:_showNextBtnSequence];
//        [_toggleListBtn runAction:_showToggleListBtnSequence];
    }
}

// show/hide playlist
/*
- (void) _togglePlaylist {
    [_playListLayer stopAllActions];
    
    // is showing playlist?
    if (_isShowingPlayList) {
        // hide playlist
        [self _tweenHideNode:_playListLayer to:_playListHidePos];
        _isShowingPlayList = NO;
    } else {
        // show play list
        [self _tweenShowNode:_playListLayer to:CGPointZero isShow:YES];
        _isShowingPlayList = YES;
    }
}

- (void) _tweenHideNode:(CCNode *)node to:(CGPoint)toPos {
    id moveAction = [CCMoveTo actionWithDuration:_tweenTime position:toPos];
    id hideComplete = [CCCallFuncN actionWithTarget:self selector:@selector(_onFinishHidePlaylist:)];
    id hideSequence = [CCSequence actions:moveAction, hideComplete, nil];
    
    [node runAction:hideSequence];
}

- (void) _tweenShowNode:(CCNode *)node to:(CGPoint)toPos isShow:(BOOL)isShow {
    node.visible = isShow;
    [node runAction:[CCMoveTo actionWithDuration:_tweenTime position:toPos]];
}
*/
@end
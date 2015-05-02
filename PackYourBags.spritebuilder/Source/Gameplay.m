//
//  Gameplay.m
//  PackYourBags
//
//  Created by CMU on 2/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Level.h"
#import "Tile.h"
#import "Item.h"
#import "Bag.h"
#import "Gameplay.h"

@implementation Gameplay{
    int _numLevels, _currentLevel;
    
    
    CCTimer *_levelTimer;
    CCColor *originalTimerColor;
    CCLabelTTF *_timerLabel;
    CCNode *_clock;
    
    CCTime _timeLimit;
    CCTime _timeTaken;
    CCTime _timeLeft;
    
    CCNode *_menu;
    
    Bag *_bag;
    Level *_levelNode;
    CCNode *_lid;
    
    CGFloat _itemsInBag;
    CGFloat _itemsInLevel;
    
}

- (void)didLoadFromCCB {
    
    self.userInteractionEnabled = TRUE;
    
    _numLevels = 4;

    originalTimerColor = _timerLabel.color;
    
    // Set the selector of the Next Trip and Retry buttons on the lid. Can't do it from SB
    CCButton *nextButton = (CCButton *)[_lid getChildByName:@"nextButton" recursively:true];
    [nextButton setTarget:self selector: @selector(next)];
    
    CCButton *retryButton = (CCButton *)[_lid getChildByName:@"retryButton" recursively:true];
    [retryButton setTarget:self selector: @selector(retry)];

}


-(void) onEnter{
    [super onEnter];
    _currentLevel = self.level;
    [self loadLevel:(_currentLevel)];
    
   
    
    //NSNumber *firsttime = [[NSUserDefaults standardUserDefaults]valueForKey: @"firsttime"];
    //if([firsttime boolValue] && self.level == 0){
    
    CCNode *arrow = nil;
    CGPoint arrowPos;
    if(self.level == 0){
        arrow = [CCBReader load:@"TutArrowDrag"];
        arrowPos = [self centerPoint:_levelNode];
        _timerLabel.visible = NO;
    } else if (self.level == 1){
        arrow = [CCBReader load:@"TutArrowTime"];
        arrowPos = ccp(_clock.positionInPoints.x,
                       _levelNode.positionInPoints.y+_levelNode.contentSizeInPoints.height/2);
    }

    if(arrow){
         self.paused = YES;
        [self addChild: arrow];
        arrow.positionInPoints = arrowPos;
        
        CCAnimationManager* arrowAnimationManager = [arrow animationManager];
        [arrowAnimationManager runAnimationsForSequenceNamed:@"appear"];
        [arrowAnimationManager setCompletedAnimationCallbackBlock:^(id sender) {
            [self removeChild: arrow];
            self.paused = NO;
        }];
    }
    
}

- (CGPoint) centerPoint: (CCNode*) node{
    return ccp(node.positionInPoints.x + node.contentSizeInPoints.width/2,
               node.positionInPoints.y + node.contentSizeInPoints.height/2);
}

- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{

    if([self getChildByName:@"menu" recursively:YES]){
        [self removeChild:_menu];
    }
    
    if(![self touchingClock:[touch locationInNode: self]]){
        // Pass the touch down to the next layer, it's not in any of the tiles
        [super touchBegan:touch withEvent:event];
    }else{
        self.paused = YES;
        _menu = [CCBReader load:@"Menu"];
        _menu.positionInPoints = [self centerPoint: self];
        CCButton *quit = (CCButton*)[_menu getChildByName:@"quit" recursively:YES];
        CCButton *retry = (CCButton*)[_menu getChildByName:@"retry" recursively:YES];
        [quit setTarget:self selector:@selector(next)];
        [retry setTarget:self selector:@selector(retry)];
        [self addChild: _menu];
    }
}

-(BOOL) touchingClock: (CGPoint) touchLocation{
    return CGRectContainsPoint([_clock boundingBox], touchLocation);
}

#pragma mark - Update loop callback

- (void)update:(CCTime)delta
{
    if([self checkForWin]){
        [self gameOverWithStatus: YES];
    }
    
}

#pragma mark - Display level results

- (void) displayLevelResults{
    self.paused = YES;
    // Close the lid, displaying the results for the level
    _lid.visible = YES;
    CCAnimationManager* lidAnimationManager = [_lid animationManager];
    [lidAnimationManager runAnimationsForSequenceNamed:@"appear"];
    [lidAnimationManager setCompletedAnimationCallbackBlock:^(id sender) {
        CCParticleSystem* leftPuff = (CCParticleSystem*)[CCBReader load:@"LidSmoke"];
        CCParticleSystem* rightPuff = (CCParticleSystem*)[CCBReader load:@"LidSmoke"];
        leftPuff.positionInPoints = _lid.position;
        rightPuff.positionInPoints = ccp(_lid.position.x+_lid.contentSize.width, _lid.position.y);
        [self addChild:leftPuff];
        [self addChild:rightPuff];
    }];
    
    CCLabelTTF *_percentPackedValue =   (CCLabelTTF *)[_lid getChildByName:@"percentPackedValue" recursively:YES];
    CCLabelTTF *_timeTakenValue =       (CCLabelTTF *)[_lid getChildByName:@"timeTakenValue" recursively:YES];
    CCLabelTTF *_scoreValue =           (CCLabelTTF *)[_lid getChildByName:@"scoreValue" recursively:YES];
    
    CGFloat percentPacked = _bag.itemsPacked / _itemsInLevel;
    //CCTime timeLeft = _timeLimit - _timeTaken;
    CGFloat thisScore = _timeLeft * percentPacked;
    
    _percentPackedValue.string =    [NSString stringWithFormat:@"%.2f", percentPacked*100.0];
    _timeTakenValue.string =        [NSString stringWithFormat:@"%.2f", _timeTaken];
    _scoreValue.string =            [NSString stringWithFormat:@"%.0f", thisScore];
    
    [self updateUserDefaults:thisScore];
    
}

#pragma mark - Returns whether the player has won the level

-(BOOL)checkForWin{

    // Leaving this wrapper in case I want to add more win conditions
    
    return [_bag packed];

}

-(void) updateUserDefaults: (CGFloat)thisScore{
    // Fetch the level dict
    NSMutableDictionary *levelData = [[[NSUserDefaults standardUserDefaults]objectForKey:
                                       [NSString stringWithFormat:@"level%d",self.level]]
                                      mutableCopy];
    if(levelData == nil){
        levelData = [NSMutableDictionary new];
    }
    // If this score beats your old score, overwrite the old score.
    NSNumber *levelScore = [levelData valueForKey:@"score"];
    if(thisScore > [levelScore floatValue]){
        levelScore = [NSNumber numberWithFloat:thisScore];
        [levelData setValue:levelScore forKey:@"score"];
        [[NSUserDefaults standardUserDefaults]setObject: levelData forKey:[NSString stringWithFormat:@"level%d",self.level]];
    }
    // Completing a level means that you've played the game before.
    NSNumber *firsttime = [[NSUserDefaults standardUserDefaults]valueForKey: @"firsttime"];
    if([firsttime boolValue]){
        firsttime = [NSNumber numberWithBool:NO];
        [[NSUserDefaults standardUserDefaults]setObject: firsttime forKey:@"firsttime"];
    }
    // Completing a level means that you unlock the next one.
    NSMutableDictionary *nextLevelData = [[[NSUserDefaults standardUserDefaults]objectForKey:
                                          [NSString stringWithFormat:@"level%d",self.level+1]]
                                          mutableCopy];
    if(nextLevelData){
        [nextLevelData setValue:[NSNumber numberWithBool:NO] forKey:@"locked"];
        [[NSUserDefaults standardUserDefaults]setObject: nextLevelData forKey:[NSString stringWithFormat:@"level%d",self.level+1]];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark - Next selector that removes all children and redirects to trip select

- (void) next{
    //[self loadNextLevel];
    [self resetWorld];
    CCScene *tripSelectScene = [CCBReader loadAsScene:@"TripSelect"];
    [[CCDirector sharedDirector] replaceScene:tripSelectScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:.5]];
    
}

- (void) retry{
    if([self getChildByName:@"menu" recursively:YES]){
        [self removeChild:_menu];
    }
    
    if(self.paused){
        self.paused = NO;
    }
    
    [self loadLevel:self.level];
}

#pragma mark - Convenience method for loading the next level (loops)

-(void)loadNextLevel{
    [self loadLevel:(++_currentLevel%_numLevels)];
}

#pragma mark - Loads level using CCBReader based on supplied numeric index

-(void)loadLevel:(int)index{
    
    [self resetWorld];
    
    //Hide the end of level lid
    _lid.visible = NO;
    
    // Load level from storage
    CCLOG(@"Load level %i", index);
    Level *level = (Level*)[CCBReader load:[NSString stringWithFormat:@"Levels/LevelNew%i", index]];
    
    _timeLimit = level.timeLimit;
    
    // Make a copy of the level children so that we don't have mutation during iteration problems
    NSArray *items = [level.children copy];
    
    CCLOG(@"Adding items to _levelNode");
    
    // Each child in the level should be added as a child to the levelNode
    for( int i = 0; i < items.count; i++){
        
        CCNode *node = items[i];
        
        if ([node isKindOfClass:[Item class]]){
            
            Item *item = (Item*)node;               // Make local reference (to make ARC happy) and cast
            [level removeChild:item cleanup:NO];    //remove item from loaded level node
            [_levelNode addChild:item];             // add item to levelNode
            [item setRefs: self lnode: _levelNode bag: _bag]; //set the references
            
        }
    }
    
    _itemsInLevel = _levelNode.children.count;
    CCLOG(@"%li items in this level", (long)_itemsInLevel);
    
    // Schedule the timer
//    if(_timeLimit > 0){
//        [self schedule:@selector(updateTimer:) interval: 1.0];
//    }else{
//        _timerLabel.string = @"";
//    }
    [self schedule:@selector(updateTimer:) interval: 1.0];
    _timeTaken = 0;
}

#pragma mark - Timer update method

//-(void)updateTimer:(CCTime)delta{
//    //this is called every second
//    if((_timeLimit - _timeTaken) > 0){
//        if((_timeLimit - _timeTaken) <= 3.0){
//            _timerLabel.color = CCColor.redColor;
//        }
//        _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - (_timeTaken++)];
//    }else{
//        //ran out of time
//        _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - _timeTaken];
//        [self gameOverWithStatus: [self checkForWin]];
//    }
//    
//}

-(void)updateTimer:(CCTime)delta{
    //Update timeLeft and timeTaken
    _timeTaken++;
    
    _timeLeft = _timeLimit > 0 ? (_timeLimit - _timeTaken) : 1;
    
     _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - _timeTaken];
    
    if((_timeLeft) == 0){
        [self gameOverWithStatus: [self checkForWin]];
    }else if((_timeLeft) <= 3.0){
        _timerLabel.color = CCColor.redColor;
    }
}

#pragma mark - Reset the tile counters, throw out old level, unschedule timer, remove lid

-(void)resetWorld{
    _itemsInBag = _itemsInLevel = 0;
    
    [_levelNode removeAllChildren];
    [_bag removeAllChildren];
    [_bag clearGrid];
    
    _timerLabel.color = originalTimerColor;
    
}

-(void)gameOverWithStatus: (BOOL) won {
    [self unschedule:@selector(updateTimer:)];
    [self displayLevelResults];
    [_bag clearGrid];
}
@end

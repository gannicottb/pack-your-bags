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
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay{
    
    int _numLevels, _currentLevel;
    
    CCTimer *_levelTimer;
    CCColor *originalTimerColor;
    CCTime _timeLimit;
    CCTime _timeTaken;
    CCLabelTTF *_timerLabel;
    
    Bag *_bag;
    Level *_levelNode;
    CCNode *_lid;
    
    CGFloat _itemsInBag;
    CGFloat _itemsInLevel;
    
    //bool touchedYet;
    
    
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
    CCTime timeLeft = _timeLimit - _timeTaken;
    CGFloat thisScore = timeLeft * percentPacked;
    
    _percentPackedValue.string =    [NSString stringWithFormat:@"%.2f", percentPacked*100.0];
    _timeTakenValue.string =        [NSString stringWithFormat:@"%.2f", _timeTaken];
    _scoreValue.string =            [NSString stringWithFormat:@"%.0f", thisScore];
    
    //----
    
    NSNumber *levelScore = [[NSUserDefaults standardUserDefaults]objectForKey: [NSString stringWithFormat:@"level%dscore",self.level]];
    if(thisScore > [levelScore floatValue]){
        levelScore = [NSNumber numberWithFloat:thisScore];
        [[NSUserDefaults standardUserDefaults]setObject:levelScore forKey:[NSString stringWithFormat:@"level%dscore",self.level]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

#pragma mark - Returns whether the player has won the level

-(BOOL)checkForWin{

    // Leaving this wrapper in case I want to add more win conditions
    
    return [_bag packed];

}


#pragma mark - Next selector that removes all children and loads next level

- (void) next{
    [self loadNextLevel];
}

- (void) retry{
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
    [self schedule:@selector(updateTimer:) interval: 1.0];
    _timeTaken = 0;
}

#pragma mark - Timer update method

-(void)updateTimer:(CCTime)delta{
    //this is called every second
    
    if((_timeLimit - _timeTaken) > 0){
        if((_timeLimit - _timeTaken) <= 3.0){
            _timerLabel.color = CCColor.redColor;
        }
        _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - (_timeTaken++)];
    }else{
        //ran out of time
        _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - _timeTaken];
        [self gameOverWithStatus: [self checkForWin]];
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

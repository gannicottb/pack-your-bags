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
    _currentLevel = 0;
    
    //touchedYet = NO; //User hasn't touched the screen yet
    
    //Load end of level screen on top of bag and set the selector of the button
    //_lid = [CCBReader load:@"Modal"];
    //[self addChild:_lid];
    //_lid.positionInPoints = _bag.positionInPoints;
    //_lid.visible = NO;
    
    //CCNode *_cell = [CCBReader load: @"Assets/GridOverlay"];
    
    
    
    CCButton *nextButton = (CCButton *)[_lid getChildByName:@"Button" recursively:true];
    [nextButton setTarget:self selector: @selector(next)];
    
    //Load the first level - eventually redirect from a level select menu
    [self loadLevel:(_currentLevel)];
    
}



#pragma mark - Update loop callback

- (void)update:(CCTime)delta
{
    if([self checkForWin]){
        [self gameOverWithStatus: YES];
    }
    
}

- (void) displayLevelResults{
    // Close the lid, displaying the results for the level
    _lid.visible = YES;
    
    CCLabelTTF *_percentPackedValue = (CCLabelTTF *)[_lid getChildByName:@"percentPackedValue" recursively:YES];
    CCLabelTTF *_timeTakenValue = (CCLabelTTF *)[_lid getChildByName:@"timeTakenValue" recursively:YES];
    CCLabelTTF *_scoreValue = (CCLabelTTF *)[_lid getChildByName:@"scoreValue" recursively:YES];
    CGFloat percentPacked = _bag.children.count / _itemsInLevel;
    _percentPackedValue.string = [NSString stringWithFormat:@"%.2f", percentPacked*100.0];
    _timeTakenValue.string = [NSString stringWithFormat:@"%.2f", _timeTaken];
    _scoreValue.string = [NSString stringWithFormat:@"%.0f",_timeTaken + percentPacked];
}

#pragma mark - Returns whether the player has won the level

-(BOOL)checkForWin{

    // Leaving this wrapper in case I want to add more win conditions
    
    return [_bag packed];

}


#pragma mark - Next selector that removes all children and loads next level

- (void) next {
    [self loadNextLevel];
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
                        
    if(_timeTaken >= 0){
        CCLOG(@"updateTimer: %f", _timeTaken);
        if((_timeLimit - _timeTaken) <= 3.0){
            _timerLabel.color = CCColor.redColor;
        }
        _timerLabel.string = [NSString stringWithFormat:@"0:%.0f", _timeLimit - (_timeTaken++)];
    }else{
        //ran out of time
        [self gameOverWithStatus: [self checkForWin]];
        //reload the level?
        
        //[self loadLevel:_currentLevel%_numLevels ];
    }
    
}

#pragma mark - Reset the tile counters, throw out old level, unschedule timer, remove lid

-(void)resetWorld{
    _itemsInBag = _itemsInLevel = 0;
    
    [_levelNode removeAllChildren];
    [_bag removeAllChildren];
    [_bag clearGrid];
    
    _timerLabel.color = CCColor.whiteColor;
    
}

-(void)gameOverWithStatus: (BOOL) won {
    [self unschedule:@selector(updateTimer:)];
    [self displayLevelResults];
    [_bag clearGrid];
}
@end

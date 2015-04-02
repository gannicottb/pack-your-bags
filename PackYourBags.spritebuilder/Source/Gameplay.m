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
    
    _numLevels = 3;
    _currentLevel = 2;
    
    //touchedYet = NO; //User hasn't touched the screen yet
    
    //Load end of level screen on top of bag and set the selector of the button
    _lid = [CCBReader load:@"Modal"];
    [self addChild:_lid];
    _lid.positionInPoints = _bag.positionInPoints;
    _lid.visible = NO;
    CCButton *nextButton = (CCButton *)[_lid getChildByName:@"Button" recursively:true];
    [nextButton setTarget:self selector: @selector(next)];
    
    //Load the first level - eventually redirect from a level select menu
    [self loadLevel:(_currentLevel)];
    
}



#pragma mark - Update loop callback

- (void)update:(CCTime)delta
{
    
    if([self checkForWin]){
        CCLOG(@"You win!");
        // Close the lid, displaying the results for the level
        _lid.visible = YES;
        //[self next];
        [_bag clearGrid];
    }
    
}

#pragma mark - Returns whether all tiles are in the bag

-(BOOL)checkForWin{

    bool win = [_bag packed];

    
    return win;

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
}

#pragma mark - Timer update method

-(void)updateTimer:(CCTime)delta{
    //this is called every second
                        
    if(_timeLimit >= 0){
        //CCLOG(@"updateTimer: %f", _timeLimit);
        if(_timeLimit <= 3.0){
            _timerLabel.color = CCColor.redColor;
        }
        _timerLabel.string = [NSString stringWithFormat:@"%.0f", _timeLimit--];

    }else if([self checkForWin]){
        //won at the last second
        CCLOG(@"You win!");
        [self next];
    }else{
        //ran out of time
        CCLOG(@"You lose! %.1f of tiles placed  of level", (_itemsInBag/_itemsInLevel)*100.0);
        //reload the level?
        
        [self loadLevel:_currentLevel%_numLevels ];
    }
    
}

#pragma mark - Reset the tile counters, throw out old level, unschedule timer, remove lid

-(void)resetWorld{
    _itemsInBag = _itemsInLevel = 0;
    
    [_levelNode removeAllChildren];
    [_bag removeAllChildren];
    [_bag clearGrid];
    
    
    [self unschedule:@selector(updateTimer:)];
    _timerLabel.color = CCColor.whiteColor;
    
    //touchedYet = NO;
    _timerLabel.visible = NO;
    
}
@end

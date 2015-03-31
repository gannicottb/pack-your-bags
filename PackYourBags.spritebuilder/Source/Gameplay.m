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
    
    CGFloat _itemsInBag;
    CGFloat _itemsInLevel;
    
    //bool touchedYet;
    
    
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _bag = (Bag*)[self getChildByName:@"_bag" recursively:NO];
    
    _numLevels = 2;
    _currentLevel = 0;
    
    //touchedYet = NO; //User hasn't touched the screen yet
    //_timerLabel.visible = NO; //Can't see timer yet
    
    
    //Load the first level - eventually redirect from a level select menu
    [self loadLevel:(_currentLevel)];
    

}



#pragma mark - Update loop callback

- (void)update:(CCTime)delta
{
    
    if([self checkForWin]){
        CCLOG(@"You win!");
        [self next];
    }
    
}

#pragma mark - Returns whether all tiles are in the bag

-(BOOL)checkForWin{

    bool win = [_bag packed];

    
    return win;

}

#pragma mark - Detect first touch
//- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
//{
//    NSLog(@"Touched gameplay");
////    if(!touchedYet){
////        touchedYet = YES;
////        //Schedule timer only after first click
////        _levelTimer = [self schedule:@selector(updateTimer:) interval: 1.0];
////        _timerLabel.visible = YES;
////        
////    }
//    //[super touchBegan:touch withEvent:event];
//}


#pragma mark - Next selector that removes all children and loads next level

- (void) next {
    #pragma mark - TODO: why do I need this call? removeAllchildren gets called in resetWorld
    [_levelNode removeAllChildren];
    [self loadNextLevel];
}

#pragma mark - Convenience method for loading the next level (loops)

-(void)loadNextLevel{
    [self loadLevel:(++_currentLevel%_numLevels)];
}

#pragma mark - Loads level using CCBReader based on supplied numeric index

-(void)loadLevel:(int)index{
    //Reset values and counters to defaults, get rid of the lid
    [self resetWorld];
    
    // Load level from storage
    CCLOG(@"Load level %i", index);
    //CGPoint lnpos = _levelNode.positionInPoints;
    
    //CCLOG(@"Level node is at (%f, %f)", _levelNode.positionInPoints.x, _levelNode.positionInPoints.y);
    Level *level = (Level*)[CCBReader load:[NSString stringWithFormat:@"Levels/LevelNew%i", index]];
    
    //_levelNode = (Level*)[CCBReader load:[NSString stringWithFormat:@"Levels/LevelNew%i", index]];
    
    

    // Fetch the time limit for this level
    //_timeLimit = _levelNode.timeLimit;
    _timeLimit = level.timeLimit;
    
    //_levelNode.positionInPoints = lnpos;
    //[self addChild:_levelNode];
    
    
    
    //CCLOG(@"_levelNode position (%f, %f)", _levelNode.positionInPoints.x, _levelNode.positionInPoints.y);
    
    //Add the level to the scene
    //[_levelNode addChild:level];
    
    NSArray *items = level.children;
    
    CCLOG(@"Adding items to _levelNode");
    
    // Each child in the level should be added as a child to the levelNode
    for (CCNode *node in items){
        if ([node isKindOfClass:[Item class]]){
            
            Item *item = (Item*)node; // Make local copy (to make ARC happy) and cast
            [level removeChild:item cleanup:NO]; //remove item from loaded level node
            [_levelNode addChild:item]; // add item to levelNode
            [item setRefs: self lnode: _levelNode bag: _bag]; //set the references
            
        }
    }
    
    _itemsInLevel = [_levelNode.children count];
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
    
    [self unschedule:@selector(updateTimer:)];
    _timerLabel.color = CCColor.whiteColor;
    
    //touchedYet = NO;
    _timerLabel.visible = NO;
    
}
@end

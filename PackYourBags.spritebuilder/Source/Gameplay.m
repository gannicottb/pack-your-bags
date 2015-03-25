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
    

    CCNode *_levelNode;
    //CCPhysicsNode *_physicsNode;
    //CCNode *_mouseJointNode;
    
//    CCNode *_closeSensorL;
//    CCNode *_closeSensorR;
    
    //CCNode *_lid; //a sprite at best
    
    //CCNode *_inBagSensor;
    //CGFloat _bagSensorY;
    
    //CGFloat _tilesInBag;
    //CGFloat _tilesInLevel;
    
    CGFloat _itemsInBag;
    CGFloat _itemsInLevel;
    
    //bool touchedYet;
    
    
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Physics settings
//    _physicsNode.debugDraw = YES;
//    _physicsNode.collisionDelegate = self;
    
    //Set our sensors
    //_closeSensorL.physicsBody.sensor = true;
    //_closeSensorR.physicsBody.sensor = true;
//    _inBagSensor.physicsBody.sensor = true;
//    _bagSensorY = _inBagSensor.positionInPoints.y + _inBagSensor.contentSizeInPoints.height;
    
    _numLevels = 2;
    _currentLevel = 0;
    
    //touchedYet = NO; //User hasn't touched the screen yet
    _timerLabel.visible = NO; //Can't see timer yet
   //[self setZOrder:1];
    
    
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
//bool checkForWin(){
    //iterate over all Tiles
    //If no tile's topmost y coord is above bagsensor's topmost y coord
    //and _tilesInBag == _tilesInLevel
    //then we win
    bool win = NO;
//    bool allBelowLine = YES;
//    NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
//    for (CCNode* node in tiles){
//        CGFloat nodeTopY = node.positionInPoints.y + node.contentSizeInPoints.height/2;
//        CGFloat fudge = 1.0;
//        if ([node isKindOfClass:[Tile class]] && (nodeTopY > (_bagSensorY + fudge))){
//            allBelowLine = NO; // at least this node is sticking over the edge
//        }
//    }
//    //Hey, check for win why don't we
//    if(allBelowLine && _tilesInBag == _tilesInLevel){
//        win = YES;
//    }
    
    return win;

}

#pragma mark - Detect first touch
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    NSLog(@"Touched gameplay");
//    if(!touchedYet){
//        touchedYet = YES;
//        //Schedule timer only after first click
//        _levelTimer = [self schedule:@selector(updateTimer:) interval: 1.0];
//        _timerLabel.visible = YES;
//        
//    }
    //[super touchBegan:touch withEvent:event];
}

#pragma mark - Handle when tile enters the bag

//-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
//    t.inBag = true;
//    _tilesInBag++;
//    CCLOG(@"tile in bag %i", t.inBag);
//    return YES;
//}

#pragma mark - Handle when tile leaves the bag

//-(BOOL) ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
//    t.inBag = false;
//    _tilesInBag--;
//    CCLOG(@"tile in bag? %i", t.inBag);
//    return YES;
//}

#pragma mark - Next selector that removes all children and loads next level

- (void) next {
    #pragma mark - TODO: why do I need this call?
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
    
    //Load the level as a scene
    CCScene *level = [CCBReader loadAsScene:
                      [NSString stringWithFormat:@"Levels/LevelNew%i", index]];
    
    _timeLimit = ((Level*)[level getChildByName:(@"tiles") recursively:false]).timeLimit;
    //Add the level to the scene
    [_levelNode addChild:level];
    //Count the items in the level
    NSArray *items = [_levelNode getChildByName:@"items" recursively:true].children;
    for (CCNode* node in items){
        if ([node isKindOfClass:[Item class]]){
            _itemsInLevel++;
        }
    }
    CCLOG(@"%li tiles in this level", (long)_itemsInLevel);
    
    

    
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

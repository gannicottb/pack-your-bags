//
//  Gameplay.m
//  PackYourBags
//
//  Created by CMU on 2/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Tile.h"
#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay{
    
    int _numLevels, _currentLevel;
    
    CCTimer *_levelTimer;
    CCTime _timeLimit;
    CCLabelTTF *_timerLabel;
    

    CCNode *_levelNode;
    CCPhysicsNode *_physicsNode;
    CCNode *_mouseJointNode;
    
    CCNode *_closeSensorL;
    CCNode *_closeSensorR;
    
    CCNode *_lid; //a sprite at best
    
    CCNode *_inBagSensor;
    CGFloat _bagSensorY;
    bool _levelLoaded;
    
    NSInteger _tilesInBag;
    NSInteger _tilesInLevel;
    
    
}

- (void)didLoadFromCCB {
    _levelLoaded = NO;
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Physics settings
    _physicsNode.debugDraw = NO;
    _physicsNode.collisionDelegate = self;
    
    //Set our sensors
    _closeSensorL.physicsBody.sensor = true;
    _closeSensorR.physicsBody.sensor = true;
    _inBagSensor.physicsBody.sensor = true;
    _bagSensorY = _inBagSensor.positionInPoints.y + _inBagSensor.contentSizeInPoints.height;
    
    _numLevels = 3;
    _currentLevel = 0;

    
    //Load the first level - eventually redirect from a level select menu
    [self loadNextLevel];
    
}

- (void)update:(CCTime)delta
{
    
    
    if(_levelLoaded){
//        bool allBelowLine = YES;
//        CGFloat bagSensorY = _inBagSensor.positionInPoints.y + _inBagSensor.contentSizeInPoints.height;
//        NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
//        for (CCNode* node in tiles){
//            CGFloat nodeTopY = node.positionInPoints.y + node.contentSizeInPoints.height/2;
//            CGFloat fudge = 1.0;
//            //CCLOG(@"tileY %f vs bagY %f", nodeTopY, bagSensorY);
//            if ([node isKindOfClass:[Tile class]] && (nodeTopY > (bagSensorY + fudge))){
//                allBelowLine = NO; // at least this node is sticking over the edge
//            }
//        }
//        //Hey, check for win why don't we
//        if(allBelowLine && _tilesInBag == _tilesInLevel){
//            CCLOG(@"You win!");
//            [self next];
//        }
        if([self checkForWin]){
            CCLOG(@"You win!");
            [self next];
        }
    }
}

-(BOOL)checkForWin{
    //iterate over all Tiles
    //If no tile's topmost y coord is above bagsensor's topmost y coord
    //and _tilesInBag == _tilesInLevel
    //then we win
    bool win = NO;
    bool allBelowLine = YES;
    //CGFloat bagSensorY = _inBagSensor.positionInPoints.y + _inBagSensor.contentSizeInPoints.height;
    NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
    for (CCNode* node in tiles){
        CGFloat nodeTopY = node.positionInPoints.y + node.contentSizeInPoints.height/2;
        CGFloat fudge = 1.0;
        if ([node isKindOfClass:[Tile class]] && (nodeTopY > (_bagSensorY + fudge))){
            allBelowLine = NO; // at least this node is sticking over the edge
        }
    }
    //Hey, check for win why don't we
    if(allBelowLine && _tilesInBag == _tilesInLevel){
        win = YES;
    }
    
    return win;

}



// implement collision callback methods here, for example:

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = true;
    _tilesInBag++;
    CCLOG(@"tile in bag %i", t.inBag);
    return YES;
}

-(BOOL) ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = false;
    _tilesInBag--;
    CCLOG(@"tile in bag? %i", t.inBag);
    return YES;
}

- (void) next {
    [_levelNode removeAllChildren];
    _levelLoaded = NO;
    [self loadNextLevel];
}


-(void)loadNextLevel{
    //Reset values and counters to defaults, get rid of the lid
    [self resetWorld];
    
    //Load the level as a scene
    CCScene *level = [CCBReader loadAsScene:
                      [NSString stringWithFormat:@"Levels/Level%i", _currentLevel++%_numLevels]];
    _timeLimit = 20.0; //TODO: load this from the level instead
    //Add the level to the scene
    [_levelNode addChild:level];
    //Count the tiles in the level
    NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
    for (CCNode* node in tiles){
        if ([node isKindOfClass:[Tile class]]){
            _tilesInLevel++;
        }
    }
    CCLOG(@"%li tiles in this level", (long)_tilesInLevel);
    
    _levelTimer = [self schedule:@selector(updateTimer:) interval: 1.0];
    
    _levelLoaded = YES;
}
-(void)updateTimer:(CCTime)delta{
    //this is called every second
                        
    if(_timeLimit >= 0){
        //CCLOG(@"updateTimer: %f", _timeLimit);
        if(_timeLimit <= 5.0){
            _timerLabel.color = CCColor.redColor;
        }
        _timerLabel.string = [NSString stringWithFormat:@"%.0f", _timeLimit--];

    }else if([self checkForWin]){
        //won at the last second
        CCLOG(@"You win!");
        [self next];
    }else{
        //ran out of time
        CCLOG(@"You lose!");
        //reload the level?
    }
    
}

-(void)resetWorld{
    _tilesInBag = 0;
    _tilesInLevel = 0;
    _levelLoaded = NO;
    
    [self unschedule:@selector(updateTimer:)];
    
    if (_lid != nil){
        [_lid removeFromParent];
        _lid = nil;
    }
    
}
@end

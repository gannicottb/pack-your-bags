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
    

    CCNode *_levelNode;
    CCPhysicsNode *_physicsNode;
    CCNode *_mouseJointNode;
    
    CCNode *_closeSensorL;
    CCNode *_closeSensorR;
    
    CCNode *_lid;
    
    CCNode *_inBagSensor;
    
    bool _closedOnLeft, _closedOnRight;
    
    bool _win; //This likely does not need to be an instance variable
    NSInteger _tilesInBag;
    NSInteger _tilesInLevel;
    
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Physics settings
    _physicsNode.debugDraw = NO;
    _physicsNode.collisionDelegate = self;
    
    //Set our sensors
    _closeSensorL.physicsBody.sensor = true;
    _closeSensorR.physicsBody.sensor = true;
    _inBagSensor.physicsBody.sensor = true;
    
    _numLevels = 3;
    _currentLevel = 0;
    
    
    //Load the first level - eventually redirect from a level select menu
    CCScene *level = [CCBReader loadAsScene:
                      [NSString stringWithFormat:@"Levels/Level%i", _currentLevel++%_numLevels]];
    
    [_levelNode addChild:level];
    
    //Count the tiles in the level
    NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
    for (CCNode* node in tiles){
        if ([node isKindOfClass:[Tile class]]){
            _tilesInLevel++;
        }
    }
    
    [self resetLevel];
    
}

- (void)update:(CCTime)delta
{
}

// implement collision callback methods here, for example:
-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeL:(CCNode*)close {
    CCLOG(@"lid closed on left");
    _closedOnLeft = YES;
    
    if(_closedOnRight){
        //check to see if the user has won
        [self checkForWin];
    }
    
    return YES;
}

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeR:(CCNode*)close {
    CCLOG(@"lid closed on right");
    _closedOnRight = YES;
    
    if(_closedOnLeft){
        //check to see if the user has won
        [self checkForWin];
    }
    
    return YES;
}

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = true;
    _tilesInBag++;
    CCLOG(@"tile in bag %i", t.inBag);
    if(_tilesInBag == _tilesInLevel){
        [self close];
    }
    return YES;
}

-(BOOL) ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = false;
    _tilesInBag--;
    CCLOG(@"tile in bag? %i", t.inBag);
    if(_tilesInBag == _tilesInLevel){
        [self close];
    }
    return YES;
}

- (void)next {
    //This should cycle through an array of levels but eh
    CCScene *level = [CCBReader loadAsScene:
                      [NSString stringWithFormat:@"Levels/Level%i", _currentLevel++%_numLevels]];
    [_levelNode removeAllChildren];
    [_levelNode addChild:level];
    
}

-(void)close{
    //Attempt to close the lid
    
    //Release the currently held tile
    //stub
    
    //Get a handle to the tile and call releaseTile
    
    //Get a handle to the holdJoint and invalidate it
//    CCPhysicsJoint *_holdJoint = (CCPhysicsJoint*)_mouseJointNode.physicsBody.joints[0];
//    [_holdJoint invalidate];
    
    
    //wait for the tile to drop?
    
    
    _lid = [CCBReader load:@"Lid"];
    
    CGPoint lidPosition = [_inBagSensor convertToWorldSpace:ccp(-24, 210)];
    // transform the world position to the node space to which the lid will be added (_physicsNode)
    _lid.positionInPoints = [_physicsNode convertToNodeSpace:lidPosition];
    
    [_physicsNode addChild: _lid];
    
    
}

-(void)resetLevel{
    _closedOnRight = _closedOnLeft = NO;
    _win = NO;
    _tilesInBag = 0;
    if (_lid != nil){
        [_lid removeFromParent];
    }
    
}
-(void)checkForWin{
//    bool allTilesInBag = true;
//    NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
//    for (CCNode* node in tiles)
//    {
//        if ([node isKindOfClass:[Tile class]])
//        {
//            Tile *tile = (Tile*)node;
//            allTilesInBag &= tile.inBag; //just one false will poison the value permanently
//            CCLOG(@"%@ tile is in the bag? %i",tile, tile.inBag);
//        }
//    }
//    _win = allTilesInBag;
    
    _win = (_tilesInBag == _tilesInLevel);
    
    if(_win){
        CCLOG(@"You win!");
        
    }else{
        CCLOG(@"You lose!");
    }
    [self resetLevel];
    [self next];

}


@end

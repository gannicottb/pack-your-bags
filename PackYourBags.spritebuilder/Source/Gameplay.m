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
    
    //bool _closedOnLeft, _closedOnRight;
    
    bool _levelLoaded;
    
    //bool _win; //This likely does not need to be an instance variable
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
    
    _numLevels = 3;
    _currentLevel = 0;
    
    
    //Load the first level - eventually redirect from a level select menu
    [self loadLevel];
    
    
    
    
    
    
    //[self resetWorld];
    
}

- (void)update:(CCTime)delta
{
    
    //iterate over all Tiles
    //If no tile's topmost y coord is above bagsensor's topmost y coord
    //and _tilesInBag == _tilesInLevel
    //then guess what
    //we win
    //lols
    
    if(_levelLoaded){
        bool allBelowLine = YES;
        CGFloat bagSensorY = _inBagSensor.positionInPoints.y + _inBagSensor.contentSizeInPoints.height;
        NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
        for (CCNode* node in tiles){
            CCLOG(@"tileY %f vs bagY %f", node.positionInPoints.y+node.contentSizeInPoints.height/2, bagSensorY);
            if ([node isKindOfClass:[Tile class]] &&
                node.positionInPoints.y + node.contentSizeInPoints.height/2 > bagSensorY + 1.0){
                
                allBelowLine = NO; // at least this node is sticking over the edge
                
            }
        }
        //Hey, check for win why don't we
        if(allBelowLine && _tilesInBag == _tilesInLevel){
            //we win
            //lols
            CCLOG(@"You win!");
            
        }


    }
    
}





// implement collision callback methods here, for example:
//-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeL:(CCNode*)close {
//    CCLOG(@"lid closed on left");
//    _closedOnLeft = YES;
//    
//    if(_closedOnRight){
//        //check to see if the user has won
//        [self checkForWin];
//    }
//    
//    return YES;
//}

//-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeR:(CCNode*)close {
//    CCLOG(@"lid closed on right");
//    _closedOnRight = YES;
//    
//    if(_closedOnLeft){
//        //check to see if the user has won
//        [self checkForWin];
//    }
//    
//    return YES;
//}

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = true;
    _tilesInBag++;
    CCLOG(@"tile in bag %i", t.inBag);
//    if(_tilesInBag == _tilesInLevel){
//        [self close];
//    }
    return YES;
}

-(BOOL) ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = false;
    _tilesInBag--;
    CCLOG(@"tile in bag? %i", t.inBag);
//    if(_tilesInBag == _tilesInLevel){
//        [self close];
//    }
    return YES;
}

- (void)next {
    [_levelNode removeAllChildren];
    //[self resetWorld];
    
    [self loadLevel];
}

-(void)close{
    //Attempt to close the lid
    
    //Release the currently held tile
    //stub
    
    //Get a handle to the tile and call releaseTile
   // Tile *currentlyHeld = _mouseJointNode.physicsBody.joints
    
    //Get a handle to the holdJoint and invalidate it
//    CCPhysicsJoint *_holdJoint = (CCPhysicsJoint*)_mouseJointNode.physicsBody.joints[0];
//    [_holdJoint invalidate];
    
    
    //wait for the tile to drop?
    
    
    
//    if(_lid == nil){
//        _lid = [CCBReader load:@"Lid"];
//        
//        CGPoint lidPosition = [_inBagSensor convertToWorldSpace:ccp(-24, 210)];
//        // transform the world position to the node space to which the lid will be added (_physicsNode)
//        _lid.positionInPoints = [_physicsNode convertToNodeSpace:lidPosition];
//        
//        [_physicsNode addChild: _lid];
//    }
    
    
}

-(void)loadLevel{
    //Reset values and counters to defaults, get rid of the lid
    [self resetWorld];
    
    //Load the level as a scene
    CCScene *level = [CCBReader loadAsScene:
                      [NSString stringWithFormat:@"Levels/Level%i", _currentLevel++%_numLevels]];
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
    
    _levelLoaded = YES;
}

-(void)resetWorld{
    //_closedOnRight = _closedOnLeft = NO;
    //_win = NO;
    _tilesInBag = 0;
    _tilesInLevel = 0;
    _levelLoaded = NO;
    
    if (_lid != nil){
        [_lid removeFromParent];
        _lid = nil;
    }
    
}
//-(void)checkForWin{
//    
//    _win = (_tilesInBag == _tilesInLevel);
//    
//    if(_win){
//        CCLOG(@"You win!");
//        
//    }else{
//        CCLOG(@"You lose!");
//    }
//    
//    [self next];
//
//}


@end

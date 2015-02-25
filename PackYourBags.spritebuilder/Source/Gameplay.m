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

    CCNode *_levelNode;
    CCPhysicsNode *_physicsNode;
    CCNode *_mouseJointNode;
    
    CCNode *_lid;
    
    CCNode *_closeSensorL;
    CCNode *_closeSensorR;
    
    CCNode *_inBagSensor;
    
    bool _closedOnLeft, _closedOnRight;
    
    bool win;
    
}

// implement collision callback methods here, for example:
-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeL:(CCNode*)close {
    CCLOG(@"lid closed on left");
    _closedOnLeft = YES;
    
    return YES;
}

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair lid:(CCNode*)lid closeR:(CCNode*)close {
    CCLOG(@"lid closed on right");
    _closedOnRight = YES;
    
    return YES;
}

-(BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    t.inBag = true;
    CCLOG(@"tile in bag> %i", t.inBag);
    
    
    return YES;
}

-(BOOL) ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair*)pair tile:(Tile*)t bag:(CCNode*)b {
    
    t.inBag = false;
    CCLOG(@"tile in bag? %i", t.inBag);
    return YES;
}


- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Physics settings
    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    
    //Set our sensors
    _closeSensorL.physicsBody.sensor = true;
    _closeSensorR.physicsBody.sensor = true;
    _inBagSensor.physicsBody.sensor = true;
    
    //Initial lid status
    _closedOnLeft = NO;
    _closedOnRight = NO;
    
    //Load the first level - eventually redirect from a level select menu
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
}

- (void)update:(CCTime)delta
{
    if(_closedOnRight && _closedOnLeft){
        bool allTilesInBag = true;
        
        NSArray *tiles = [_levelNode getChildByName:@"tiles" recursively:true].children;
        for (CCNode* tile in tiles)
        {
            if ([tile isKindOfClass:[Tile class]])
            {
                allTilesInBag = ((Tile*)tile).inBag;
            }
        }
        win = allTilesInBag;
        if(win)CCLOG(@"You win!");
    }
    
    
}

- (void)next {
    //This should cycle through an array of levels but eh
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode removeAllChildren];
    [_levelNode addChild:level];
    
}

-(void)close{
    //Attempt to close the lid
    CCNode *lid = [CCBReader load:@"Lid"];
    [_physicsNode addChild: lid];
    lid.position = CGPointMake(_inBagSensor.positionInPoints.x, _inBagSensor.positionInPoints.y+256.0f);
    
    CCLOG(@"Close!");
}


@end

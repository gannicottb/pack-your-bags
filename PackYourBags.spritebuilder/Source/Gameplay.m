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
    _physicsNode.debugDraw = NO;
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
        for (CCNode* node in tiles)
        {
            if ([node isKindOfClass:[Tile class]])
            {
                Tile *tile = (Tile*)node;
                allTilesInBag &= tile.inBag; //just one false will poison the value permanently
                CCLOG(@"%@ tile is in the bag? %i",tile, tile.inBag);
            }
        }
        win = allTilesInBag;
        if(win){
            CCLOG(@"You win!");
        }else{
            CCLOG(@"You lose!");
        }
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
    CCNode *_lid = [CCBReader load:@"Lid"];
    
    CGPoint lidPosition = [_inBagSensor convertToWorldSpace:ccp(-24, 210)];
    // transform the world position to the node space to which the penguin will be added (_physicsNode)
    _lid.positionInPoints = [_physicsNode convertToNodeSpace:lidPosition];
    
    [_physicsNode addChild: _lid];
    
    
}


@end

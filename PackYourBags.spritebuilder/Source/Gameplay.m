//
//  Gameplay.m
//  PackYourBags
//
//  Created by CMU on 2/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Gameplay.h"

@implementation Gameplay{

    CCNode *_levelNode;
    Grid *_grid;
}


- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Load the first level - eventually redirect from a level select menu
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
}

// called on every touch in this scene
//-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
//{
//    CGPoint touchLocation = [touch locationInNode:self];
//}



@end

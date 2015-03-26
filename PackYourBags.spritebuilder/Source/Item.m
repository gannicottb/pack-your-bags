//
//  Item.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Item.h"

@implementation Item{
    Bag* _bag;
    CCNode* _levelNode;
    CCNode* _gameplay;
    CGPoint _originalPos;
}

- (void)didLoadFromCCB {
    CCLOG(@"DID_LOAD_FROM_CCB");
    self.userInteractionEnabled = YES;
    _levelNode = self.parent;
    _gameplay = _levelNode.parent;
    _originalPos = self.positionInPoints;
    _bag = (Bag*)[_gameplay getChildByName:@"_bag" recursively:false];
    
}

- (void) onEnter{
    [super onEnter];
    
    CCLOG(@"ON_ENTER");
    CCLOG(@"_parent set to %@", self.parent.name);
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    CCLOG(@"TOUCH_BEGAN");
    
    //_parent = self.parent;
    //CCLOG(@"_parent set to %@", self.parent.name);
    
    CCLOG(@"Removing from %@", self.parent.name);
    CGPoint pos = [self positionInPoints];
    CGPoint posInGameplay = [_gameplay convertToNodeSpace:[self.parent convertToWorldSpace:self.positionInPoints]];
    [self removeFromParentAndCleanup:NO];
    
    [_gameplay addChild :self];
    [self setPositionInPoints:posInGameplay];
    CCLOG(@"Added to %@", self.parent);
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    // we want to know the location of our touch in this scene
    CGPoint touchLocation = [touch locationInNode:self.parent];
    // make the tile follow the touch
    self.positionInPoints = touchLocation;
    //CCLOG(@"node  item pos: %f, %f", self.positionInPoints.x, self.positionInPoints.y);
    //CCLOG(@"world item pos: %f, %f", [self.parent.parent convertToWorldSpace:self.positionInPoints].x,
                                //[self.parent.parent convertToWorldSpace:self.positionInPoints].y);
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    CCLOG(@"TOUCH_ENDED");
    [self drop];
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    CCLOG(@"TOUCH_CANCELLED");
    [self drop];
}

- (void)drop{
    //Do the whole drop algorithm here
    CCLOG(@"Item dropped. Checking to see if the position is valid..");
   
    
    if (![_bag dropItem: self]){
        //Do something to handle illegal placement
        CCLOG(@"Item could not be placed.");
        [self removeFromParentAndCleanup:false];
        [_levelNode addChild:self];
        [self setPositionInPoints:_originalPos];
        CCLOG(@"Added self back to %@", self.parent.name);
    }
    
}
//Item anchor point is in the center, but we need to get the coordinates of its bottom left corner
- (CGPoint)snapCornerPositionInPoints{
    
    return [self.parent convertToWorldSpace:CGPointMake(self.positionInPoints.x - self.contentSizeInPoints.width/2,
                       self.positionInPoints.y - self.contentSizeInPoints.height/2)];
    
}

@end

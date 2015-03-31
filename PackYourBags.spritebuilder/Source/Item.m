//
//  Item.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Item.h"
#import "Bag.h"

@implementation Item{
    Bag* _bag;
    CCNode* _levelNode;
    CCNode* _level;
    CCNode* _gameplay;
    CGPoint _originalPos;
}

- (void)didLoadFromCCB {
    CCLOG(@"Item DID_LOAD_FROM_CCB");
    self.userInteractionEnabled = YES;
    //_level = self.parent;
    //_levelNode = _level.parent;
    
    //_levelNode = self.parent;
    //_gameplay = _levelNode.parent;
    _originalPos = self.positionInPoints;
    //_bag = (Bag*)[_gameplay getChildByName:@"_bag" recursively:false];
    CCLOG(@"Item FINISHED LOADING");
}

-(void)setRefs:(CCNode *)gameplay lnode:(CCNode *)lnode bag:(CCNode *)bag{
    _gameplay = gameplay;
    _levelNode = lnode;
    _bag = (Bag*) bag;
}

- (void) onEnter{
    [super onEnter];
    
    CCLOG(@"ON_ENTER");
    CCLOG(@"_parent set to %@", self.parent.name);
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    CCLOG(@"TOUCH_BEGAN");
    
    // If currently in the bag, needs to unoccupy all of the cells it's sitting on
#pragma mark - TODO: unoccupy the bag cells on touch began
    if([self.parent isKindOfClass: [Bag class]]){
        [(Bag*)self.parent liftItem: self];
    }
    
    
    // Remove from current parent (either level or bag)
    CCLOG(@"Removing from %@", self.parent.name);
    CGPoint posInGameplay = [_gameplay convertToNodeSpace:[self.parent convertToWorldSpace:self.positionInPoints]];
    [self removeFromParentAndCleanup:NO];
    
    // Add to Gameplay and preserve previous position
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
    
//    return [self.parent convertToWorldSpace:CGPointMake(self.positionInPoints.x - self.contentSizeInPoints.width/2,
//                       self.positionInPoints.y - self.contentSizeInPoints.height/2)];
    return [self.parent convertToWorldSpace: [self bottomLeftCorner]];
    
    // Assuming the anchor point lives in the corner.
    //return [self.parent convertToWorldSpace:self.positionInPoints];
    
}

- (CGPoint)bottomLeftCorner{
    //assume position is based on centered anchor
    return ccp(self.positionInPoints.x - self.contentSizeInPoints.width/2,
               self.positionInPoints.y - self.contentSizeInPoints.height/2);
}

//- (void) rotate: (CGFloat) angle{
//    
//    //[self centerAndReposition];
//    
//    // Now rotate
//    self.rotation = angle;
//    CCLOG(@"Item rotated by %f", self.rotation);
//}

//- (void) centerAndReposition{
//    // Move anchor to center and reposition
//    self.anchorPoint = ccp(0.5,0.5);
//    self.positionInPoints = [self bottomLeftCorner];
//}

@end

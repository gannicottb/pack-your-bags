//
//  Item.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Item.h"
#import "Bag.h"
#import "Tile.h"
#import "Level.h"

@implementation Item{
    Bag* _bag;
    Level* _levelNode;
    CCNode* _gameplay;
    CGPoint _originalPos;
}

- (void)didLoadFromCCB {
    CCLOG(@"Item DID_LOAD_FROM_CCB");
    
    self.userInteractionEnabled = YES;
    _originalPos = self.positionInPoints;
    
    CCLOG(@"Item FINISHED LOADING");
}

-(void)setRefs:(CCNode *)gameplay lnode:(CCNode *)lnode bag:(CCNode *)bag{
    _gameplay = gameplay;
    _levelNode = (Level*)lnode;
    _bag = (Bag*) bag;
}

- (void) onEnter{
    [super onEnter];
    
    CCLOG(@"ON_ENTER");
    CCLOG(@"_parent set to %@", self.parent.name);
    
    if([self.parent isKindOfClass: [Level class]]){
        self.scale = 0.5;
    }else{
        self.scale = 1.0;
    }
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    CCLOG(@"TOUCH_BEGAN");
    
    // First check to see if the touch hits one of my tiles
    //CGPoint touchLocation = [touch locationInNode:self.parent];
    //CCLOG(@"Touch location in parent: %f, %f", touchLocation.x, touchLocation.y);
    
    CGPoint touchLocationInSelf = [touch locationInNode:self];
    CCLOG(@"Touch location in self: %f, %f", touchLocationInSelf.x, touchLocationInSelf.y);
    
    bool inChild;
    
    for(CCNode* child in self.children){
        if([child isKindOfClass:[Tile class]]){
            //bool inChild = [[child boundingBox] containsPoint: touchLocationInSelf];
            inChild = CGRectContainsPoint([child boundingBox], touchLocationInSelf);
            CCLOG(@"inChild? %i", inChild);
            if(inChild){
                break;
            }
        }
    }
    
    if(!inChild){
        [super touchBegan:touch withEvent:event];
    }
    
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

    return [self.parent convertToWorldSpace: [self bottomLeftCorner]];
    
}

- (CGPoint)bottomLeftCorner{
    //assume position is based on centered anchor
    return ccp(self.positionInPoints.x - self.contentSizeInPoints.width/2,
               self.positionInPoints.y - self.contentSizeInPoints.height/2);
}

@end

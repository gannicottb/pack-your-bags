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
    CGPoint touchLocationInSelf = [touch locationInNode:self];
    CCLOG(@"Touch location in self: %f, %f", touchLocationInSelf.x, touchLocationInSelf.y);

    if(![self pointInChild:touchLocationInSelf]){
        // Pass the touch down to the next layer, it's not in any of the tiles
        [super touchBegan:touch withEvent:event];
    }
    
    // If currently in the bag, needs to unoccupy all of the cells it's sitting on
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
    CCLOG(@"Position before rotate: %f, %f", self.positionInPoints.x, self.positionInPoints.y);
    CCLOG(@"bottomLeftCorner before rotate: %f, %f", [self bottomLeftCorner].x, [self bottomLeftCorner].y);
    
    //self.rotation = 90.0;
    
    
//    for(CCNode* child in self.children){
//        if([child isKindOfClass:[Tile class]]){
//            Tile *tile = (Tile*) child;
//            tile.rotation = 90.0;
//        }
//    }
    
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    // we want to know the location of our touch in this scene
    CGPoint touchLocation = [touch locationInNode:self.parent];
    // make the tile follow the touch
    self.positionInPoints = touchLocation;
    //CCLOG(@"Position after  rotate: %f, %f", self.positionInPoints.x, self.positionInPoints.y);
    CCLOG(@"bottomLeftCorner after  rotate: %f, %f", [self bottomLeftCorner].x, [self bottomLeftCorner].y);

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
    //assume position is based on centered anchor and no rotation
    return ccp(self.positionInPoints.x - self.contentSizeInPoints.width/2,
               self.positionInPoints.y - self.contentSizeInPoints.height/2);
    
    /*
    // Find child with minimum x and y position
    // return its bottom left corner
    // Should cache the bottom left child and only update it when item gets rotated
    Tile *bl_tile;
    CGFloat min_pos;
    BOOL first = YES;
    for(CCNode* child in self.children){
        if([child isKindOfClass:[Tile class]]){
            Tile *tile = (Tile*) child;
            CGPoint worldCoord = [child convertToWorldSpace: child.positionInPoints];
            //CGPoint rotatedPos = [child convertToNodeSpace:(worldCoord)];
            //CGFloat pos_sum = rotatedPos.x + rotatedPos.y;
            CGFloat pos_sum = worldCoord.x + worldCoord.y;
            if(first){
                first = NO;
                //min_pos = tile.positionInPoints.x + tile.positionInPoints.y;
                min_pos = pos_sum;
            //}else if(tile.positionInPoints.x + tile.positionInPoints.y < min_pos){
            }else if(pos_sum < min_pos){
                bl_tile = tile;
            }
        }
    }
    
    
    CGPoint worldCoord = [bl_tile convertToWorldSpace: bl_tile.positionInPoints];
    //CGPoint rotatedPos = [self convertToNodeSpace:(worldCoord)];
    CGPoint rotatedPos = worldCoord;
   
    
//    return ccp(
//               (bl_tile.positionInPoints.x - bl_tile.contentSizeInPoints.width/2) +
//               (self.positionInPoints.x - self.contentSizeInPoints.width/2),
//               (bl_tile.positionInPoints.y - bl_tile.contentSizeInPoints.height/2) +
//               (self.positionInPoints.y - self.contentSizeInPoints.height/2)
//               );
    return ccp(
               (rotatedPos.x - bl_tile.contentSizeInPoints.width/2) +
               (self.positionInPoints.x - self.contentSizeInPoints.width/2),
               (rotatedPos.y - bl_tile.contentSizeInPoints.height/2) +
               (self.positionInPoints.y - self.contentSizeInPoints.height/2)
               );
     */
    
}

- (BOOL) pointInChild: (CGPoint) point{
    for(CCNode* child in self.children){
        if([child isKindOfClass:[Tile class]] &&
            CGRectContainsPoint([child boundingBox], point)){
            return YES;
        }
    }
    return NO;
}
@end

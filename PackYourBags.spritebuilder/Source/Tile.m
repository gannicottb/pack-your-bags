//
//  Tile.m
//  2048Tutorial
//
//  Created by Benjamin Encz on 07/04/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Tile.h"

@implementation Tile{
    
    CGSize winSize;
   
    CGPoint originalPos;
   
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_holdJoint;
}

//{
//  CCLabelTTF *_valueLabel;
//  CCNodeColor *_backgroundNode;
//}
//
//- (id)init {
//  self = [super init];
//
//  if (self) {
//    self.value = (arc4random()%2+1)*2;
//  }
//
//  return self;
//}
//
- (void)update:(CCTime)delta{
    
}

- (void)onEnter{
    [super onEnter];
    self.userInteractionEnabled = true;
    
    

    _mouseJointNode = [self.parent.parent.parent.parent getChildByName:@"_mouseJointNode" recursively:true];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    winSize = [CCDirector sharedDirector].viewSize;
    //CCLOG(@"Win size is %fx%f", winSize.width , winSize.height);
    
    originalPos = self.position;
    CCLOG(@"Tile loaded at %f,%f", originalPos.x, originalPos.y);
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    
    CCLOG(@"_mouseJointNode is a %@", _mouseJointNode.name);
   // held = true;
    CGPoint touchLocation = [touch locationInNode:self.parent];
    // move the mouseJointNode to the touch position
    _mouseJointNode.position = touchLocation;
    CCLOG(@"Touch began! MJN is at %f,%f", _mouseJointNode.position.x, _mouseJointNode.position.y);
    
    // create a joint to hold the tile until the user releases the touch
    //BUG: Very strong impulse when the join is created, disruptive.
    _holdJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:self.physicsBody bodyB:_mouseJointNode.physicsBody anchorA:self.anchorPointInPoints];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    
    CGPoint touchLocation = [touch locationInNode: self.parent];
    _mouseJointNode.position = touchLocation;
    
    CCLOG(@"Touch moved! MJN is at %f,%f", _mouseJointNode.position.x, _mouseJointNode.position.y);
    
    
//    // we want to know the location of our touch in this scene
//    CGPoint touchLocation = [touch locationInNode:self.parent];
//    // make the tile follow the touch
//    self.position = touchLocation;
    
    
    //CGPoint worldCoord = [self.parent.parent.parent.parent convertToWorldSpace: self.position];
    
//    CGFloat minX = self.contentSize.width/2;
//    CGFloat minY = self.contentSize.height/2;
//    CGFloat maxX = winSize.width - minX;
//    CGFloat maxY = winSize.height - minY;
//    CGPoint worldPos = [self.parent convertToWorldSpace: self.position];
//    CGFloat x = worldPos.x;
//    CGFloat y = worldPos.y;
//    
//    if (x < minX){
//        self.position = [self.parent convertToNodeSpace:CGPointMake(minX, y)];
//    }
//    if (x > maxX){
//        self.position = [self.parent convertToNodeSpace:CGPointMake(maxX, y)];
//    }
//    if(y < minY){
//        self.position = [self.parent convertToNodeSpace:CGPointMake(x, minY) ];
//    }
//    if(y > maxY){
//        self.position = [self.parent convertToNodeSpace:CGPointMake(x,maxY) ];
//    }
    
    
    
}

-(void)resetPos
{
    self.position = originalPos;
}

-(void) releaseTile
{
    if (_holdJoint != nil)
    {
        // releases the joint and lets the catapult snap back
        [_holdJoint invalidate];
        _holdJoint = nil;
    }
    
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseTile];
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self releaseTile];
    
}
@end

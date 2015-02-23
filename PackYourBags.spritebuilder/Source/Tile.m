//
//  Tile.m
//  2048Tutorial
//
//  Created by Benjamin Encz on 07/04/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Tile.h"

@implementation Tile{
    CCNode *_grid;
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
- (void)onEnter{
    [super onEnter];
    self.userInteractionEnabled = true;
    
    _grid = [self.parent.parent.parent.parent getChildByName:@"Grid" recursively:true];
    CCLOG(@"grid find? %@", _grid.name);
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // we want to know the location of our touch in this scene
    CGPoint touchLocation = [touch locationInNode:self.parent];
    // make the tile follow the touch
    self.position = touchLocation;
    //UNLESS touchLocation is within the bag, in which case we want to snap to the nearest grid cell
    //and then use tiled movement
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //Check to see where we are relative to the Grid
    
    CGPoint worldPos = [self.parent convertToWorldSpace: self.position];
    CCLOG(@"Tile WorldPos %f,%f", worldPos.x, worldPos.y);
    
    CGSize s = [CCDirector sharedDirector].viewSize;
    CGPoint gridPos = CGPointMake(s.width*_grid.position.x, s.height*_grid.position.y);
    
    //Are we inside the grid?
    float diff = fabsf(worldPos.x - gridPos.x) + fabsf(worldPos.y - gridPos.y);
    
    //Calculate distance between grid center and tile center
    CGFloat xDist = (worldPos.x - gridPos.x);
    CGFloat yDist = (worldPos.y - gridPos.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    if(distance < _grid.contentSize.width/2.0){
        CCLOG(@"Close enough! diff=%f", diff);
        self.position = [self.parent convertToNodeSpace:gridPos];
    }
    
    
    
    CCLOG(@"tile bounding box %f x %f", self.boundingBox.size.width, self.boundingBox.size.height);
    CCLOG(@"grid bounding box %f x %f", _grid.boundingBox.size.width, _grid.boundingBox.size.height);
    if( CGRectIntersectsRect( [self boundingBox], [_grid boundingBox] ) ) {
        
        // Handle overlap
        //CCLOG(@"OVERLAP WITH GRIIIIIDDDDDD"); // this doesn't always work?
        
    }
    
}
@end

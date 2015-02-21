//
//  Tile.m
//  2048Tutorial
//
//  Created by Benjamin Encz on 07/04/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Tile.h"

@implementation Tile
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
    CCLOG(@"Tile onEnter");
    self.userInteractionEnabled = true;
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
    //Are we inside the grid?
    
    
}
@end

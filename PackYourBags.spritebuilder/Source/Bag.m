//
//  Bag.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bag.h"
//#import "Item.h"
#import <Math.h>

@implementation Bag{

    NSMutableArray *_agrid;
    
    int numTilesHigh, numTilesWide;
    CGFloat tileWidth, tileHeight;
}

-(void)onEnter{
    [super onEnter];
   
    numTilesHigh = 4;
    numTilesWide = 5;
    tileWidth = tileHeight = 64; //in pixels
    
    [self initGrid];
    
   
}

-(void)initGrid{
    
    //Init grid as described in planning
    CCLOG(@"InitGrid");
    
    CGPoint bottomLeft = self.positionInPoints;
    
    //The grid is an array of bottom left points to enable snapping
    
    _agrid = [NSMutableArray array];
    for(int r = 0; r < numTilesHigh; r++){
        _agrid[r] = [NSMutableArray array];
        for(int c = 0; c < numTilesWide; c++){
            
            _agrid[r][c] = [NSMutableDictionary
                            dictionaryWithDictionary:@{
//                           @"position":[NSValue valueWithCGPoint:CGPointMake(bottomLeft.x + tileWidth * c, bottomLeft.y + tileHeight * r)],
                           @"position":[NSValue valueWithCGPoint:CGPointMake(tileWidth * c, tileHeight * r)],
//                            [NSNumber numberWithFloat:(bottomLeft.x + tileWidth * c)]: @"x",
//                            [NSNumber numberWithFloat:(bottomLeft.y + tileHeight * r)]: @"y",
                            @"occupied":@NO
                            }];
        }
    }
    
    //Grid can now be used like this:
    //_agrid[0][0][@"occupied"]
    //_agrid[0][0][@"pos"]
    //[_agrid[0][0][@"pos"] CGPointValue].x
    //[_agrid[0][0][@"pos"] CGPointValue].y
   
    
    
}

-(BOOL)packed{
    
    //Return whether every cell in the grid is occupied
    
    for(int r = 0; r < numTilesHigh; r++){
        for(int c = 0; c < numTilesWide; c++){
            if([_agrid[0][0][@"occupied"]  isEqual: @NO]){
                return NO;
            }
        }
    }
    
    return YES;
}

/*
 dropItem
 
 Attempts to place the item at its nearest valid snap point
 Returns false if the item could not be dropped
 */
-(BOOL)dropItem: (CCNode *) item{
    
    CGPoint dropPosition = CGPointMake(-1, -1);
    CGPoint itemPosition = [self convertToNodeSpace:[(Item*)item snapCornerPositionInPoints]];
    
    CGRect itembox = [item boundingBox];
    itembox.origin = itemPosition;
    CGRect bagbox = [self boundingBox];
    
    if(!CGRectIntersectsRect( [self boundingBox], itembox )){
        return NO; //don't snap unless we're at least touching the bag
    }
    
    int lowRow = floor(itemPosition.y/tileHeight);
    int lowCol = floor(itemPosition.x/tileWidth);
    CGFloat minDistance = 10000;
    for(int r = lowRow; r <= lowRow+1; r++){
        for(int c = lowCol; c <= lowCol+1; c++){
            if([self inBounds:r col:c] && [_agrid[r][c][@"occupied"] isEqual: @NO]){
                CGPoint candidate = [_agrid[r][c][@"position"] CGPointValue];
                CGFloat candidate_dist;
                if((candidate_dist = ccpDistance(itemPosition, candidate)) < minDistance){
                    //candidate snap point is in bounds and unoccupied, and distance away is shorter than current minimum
                    minDistance = candidate_dist;
                    dropPosition = candidate;
                }
            }
        }
    }
    
    // All candidates checked
    
    if(dropPosition.x >= 0 && dropPosition.y >= 0){
        //Bombs away!
        
        //remove item from level node
        [item removeFromParentAndCleanup:NO];
        
        // add the removed node to its new parent node
        [self addChild:item];
        
        dropPosition.x += item.contentSizeInPoints.width/2;
        dropPosition.y += item.contentSizeInPoints.height/2;
        [item setPosition: dropPosition];
        
        return YES;
    }
    
    // No suitable candidate found
    
    return NO;
}
-(BOOL)inBounds:(int)row col:(int)col{
    return ((col >= 0 && col < numTilesWide)&&
            (row >=0 && row < numTilesHigh));
}
@end

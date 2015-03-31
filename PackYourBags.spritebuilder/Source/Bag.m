//
//  Bag.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bag.h"
#import "Tile.h"
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
    
    //CGPoint bottomLeft = self.positionInPoints;
    
    //The grid is an array of bottom left points to enable snapping
    
    _agrid = [NSMutableArray arrayWithCapacity:numTilesHigh];
    for(int r = 0; r < numTilesHigh; r++){
        _agrid[r] = [NSMutableArray arrayWithCapacity:numTilesWide];
        for(int c = 0; c < numTilesWide; c++){
            
            CGFloat cache_x = tileWidth * c;
            CGFloat cache_y = tileHeight * (numTilesHigh - 1 - r);//do the rows(y axis) inverted
            _agrid[r][c] = [NSMutableDictionary
                            dictionaryWithDictionary:@{
                           @"position":[NSValue valueWithCGPoint:CGPointMake(cache_x, cache_y)],
                            @"occupied":@NO
                            }];
            CCLOG(@"[%d][%d] = (%f, %f)", r, c, cache_x, cache_y);
        }
    }
}

-(void) clearGrid{
    for(int r = 0; r < numTilesHigh; r++){
        for(int c = 0; c < numTilesWide; c++){
            _agrid[r][c][@"occupied"] = @NO;
        }
    }
    
}

-(BOOL)packed{
    
    //Return whether every cell in the grid is occupied
    
    for(int r = 0; r < numTilesHigh; r++){
        for(int c = 0; c < numTilesWide; c++){
            if([_agrid[r][c][@"occupied"]  isEqual: @NO]){
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
    Item *_item = (Item*) item;
    BOOL result = NO;
    
    //Calculate the item's position in the bag
    CGPoint itemPosition = [self convertToNodeSpace:[_item snapCornerPositionInPoints]];
    
    // Remove item from its parent node and add the item to the bag
    [_item removeFromParentAndCleanup:NO];
    [self addChild:_item];
    
    // Preserve item position
    [_item setPosition:itemPosition];
    
    // Default dropPosition is an error state
    CGPoint dropPosition = CGPointMake(-1, -1);
    
    // Have to modify the boundingBox origin for some reason
    CGRect itembox = [_item boundingBox];
    itembox.origin = itemPosition;
    
    // Don't snap unless we're at least touching the bag
    if(!CGRectIntersectsRect( [self boundingBox], itembox ) ){
        return NO;
    }
    
    // Iterate over the four closest snap points to find the correct snap position for the item
    int lowRow = numTilesHigh - 1 - floor(itemPosition.y/tileHeight);
    int leftmostCol = floor(itemPosition.x/tileWidth);
    CGFloat minDistance = 10000;
    for(int r = lowRow - 1; r <= lowRow; r++){ //invert y axis
        for(int c = leftmostCol; c <= leftmostCol+1; c++){
            if([self inBounds:r col:c] && [_agrid[r][c][@"occupied"] isEqual: @NO]){
                // Candidate snap point is unoccupied and in bounds
                CGPoint candidate = [_agrid[r][c][@"position"] CGPointValue];
                CGFloat candidate_dist;
                
                if((candidate_dist = ccpDistance(itemPosition, candidate)) < minDistance &&
                   [self eachTileInItemCanOccupy:_item forRow:r  andCol:c]){
                    // Candidate snap point is currently the closest and the point would yield a valid placement
                    minDistance = candidate_dist;
                    dropPosition = candidate;
                }
            }
        }
    }
    
    // All candidates checked
    
    // Next, if a point was found, snap the position of the item to the chosen snap point and occupy the cells beneath it
    
    if(dropPosition.x >= 0 && dropPosition.y >= 0){
        [_item setPosition: ccp(dropPosition.x + _item.contentSizeInPoints.width/2,
                                dropPosition.y + _item.contentSizeInPoints.height/2)];
        
        result = [self forEachTileIn:_item occupy:YES];
    }
    
    // Result will be an error state (-1,-1) if no suitable point was found
    
    return result;
}
- (BOOL) liftItem:(CCNode*)item{
    
    Item *_item = (Item*) item;
    BOOL result = NO;
    
    if([_item isKindOfClass: [Item class]]){// && item is in the bag){
        
        result = [self forEachTileIn: _item occupy: NO];
        
    }
    
    return result;
}

/*
 forEachTileIn: item occupy/unoccupy from the grid
 Returns NO as soon as an invalid tile is found
 
 */

- (BOOL) forEachTileIn:(Item*) item occupy:(BOOL) occupy{
    
    CGPoint item_bottom_left_corner = [item bottomLeftCorner];
    
    // Iterate over the tiles in the item
    for(CCNode* child in item.children){
        if([child isKindOfClass:[Tile class]]){
            Tile *tile = (Tile*) child;
            CGPoint tile_bottom_left_corner = [tile bottomLeftCorner];
            CCLOG(@"tile_bottom_left_corner: %f, %f", tile_bottom_left_corner.x , tile_bottom_left_corner.y);
            
            int col_index = (item_bottom_left_corner.x + tile_bottom_left_corner.x)/tileWidth;
            int row_index = numTilesHigh - 1 - (item_bottom_left_corner.y + tile_bottom_left_corner.y)/tileHeight;
            
            //If you want to occupy the cells, they should be unoccupied to begin with, and vice versa.
            if([self inBounds:row_index col: col_index] && [_agrid[row_index][col_index][@"occupied"] isEqual: @(!occupy)]){
                _agrid[row_index][col_index][@"occupied"] = @(occupy);
                CCLOG(@"grid[%d][%d] %s", row_index, col_index, occupy ? "occupied" : "unoccupied");
            }else{
                return NO; // Not all tiles occupied/unoccupied
            }
        }
    }
    
    return YES; //All tiles occupied/unoccupied

}

/*
 Tests each tile in an item if placed at row, col in _agrid for validity
 Returns NO as soon as an invalid tile is found (a tile that is out of bounds or wants to occupy an occupied cell)
 */

- (BOOL) eachTileInItemCanOccupy:(Item*) item forRow:(int)row andCol:(int)col{
    
    BOOL result = YES;
    
    CGPoint item_bottom_left_corner = [_agrid[row][col][@"position"] CGPointValue];//[item position];//[item bottomLeftCorner];
    
    // Iterate over the tiles in the item
    for(CCNode* child in item.children){
        if([child isKindOfClass:[Tile class]]){
            Tile *tile = (Tile*) child;
        
            CGPoint tile_bottom_left_corner = [tile bottomLeftCorner];
            
            CCLOG(@"tile_bottom_left_corner: %f, %f", tile_bottom_left_corner.x , tile_bottom_left_corner.y);
            
            int col_index = (item_bottom_left_corner.x + tile_bottom_left_corner.x)/tileWidth;
            int row_index = numTilesHigh - 1 - (item_bottom_left_corner.y + tile_bottom_left_corner.y)/tileHeight;
            
            //If you want to occupy the cells, they should be in bounds and unoccupied
            if(![self inBounds:row_index col: col_index] || [_agrid[row_index][col_index][@"occupied"] isEqual: @YES]){
                result = NO; //Can't occupy
                break;
            }
        }
    }
    
    return result; //All tiles occupied/unoccupied
    
}

-(BOOL)inBounds:(int)row col:(int)col{
    return ((col >= 0 && col < numTilesWide)&&
            (row >=0 && row < numTilesHigh));
}
@end

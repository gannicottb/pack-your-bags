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
    
    CGPoint bottomLeft = self.positionInPoints;
    
    //The grid is an array of bottom left points to enable snapping
    
    _agrid = [NSMutableArray arrayWithCapacity:numTilesHigh];
    for(int r = 0; r < numTilesHigh; r++){
        _agrid[r] = [NSMutableArray arrayWithCapacity:numTilesWide];
        for(int c = 0; c < numTilesWide; c++){
            
            CGFloat cache_x = tileWidth * c;
            CGFloat cache_y = tileHeight * (numTilesHigh - 1 - r);//do the rows(y axis) inverted
            _agrid[r][c] = [NSMutableDictionary
                            dictionaryWithDictionary:@{
//                           @"position":[NSValue valueWithCGPoint:CGPointMake(bottomLeft.x + tileWidth * c, bottomLeft.y + tileHeight * r)],
                           @"position":[NSValue valueWithCGPoint:CGPointMake(cache_x, cache_y)],
                            @"occupied":@NO
                            }];
            CCLOG(@"[%d][%d] = (%f, %f)", r, c, cache_x, cache_y);
        }
    }
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
    Item *_item = (Item*) item;
    
    BOOL result = NO;
    
    //Calculate the item's position in the bag
    CGPoint itemPosition = [self convertToNodeSpace:[_item snapCornerPositionInPoints]];
    
    //remove item from its parent node
    [_item removeFromParentAndCleanup:NO];
    
    // add the item to the bag
    [self addChild:_item];
    
    //preserve item position
    [_item setPosition:itemPosition];
    
    CGPoint dropPosition = CGPointMake(-1, -1);
    
    CGRect itembox = [_item boundingBox];
    itembox.origin = itemPosition;
    
    if(!CGRectIntersectsRect( [self boundingBox], itembox )){
        return NO; //don't snap unless we're at least touching the bag
    }
    
    int lowRow = numTilesHigh - 1 - floor(itemPosition.y/tileHeight);
    int leftmostCol = floor(itemPosition.x/tileWidth);
    CGFloat minDistance = 10000;
    for(int r = lowRow - 1; r <= lowRow; r++){ //invert y axis
        for(int c = leftmostCol; c <= leftmostCol+1; c++){
            if([self inBounds:r col:c] && [_agrid[r][c][@"occupied"] isEqual: @NO]&&
               [self eachTileInItemCanOccupy:_item]){
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
    
    // Next, try to occupy the space
    
    if(dropPosition.x >= 0 && dropPosition.y >= 0){
        //Bombs away!
        
//        //remove item from its parent node
//        [item removeFromParentAndCleanup:NO];
//        
//        // add the item to the bag
//        [self addChild:item];
        
        //Set the position of the item (the actual snapping)
        dropPosition.x += _item.contentSizeInPoints.width/2;
        dropPosition.y += _item.contentSizeInPoints.height/2;
        [_item setPosition: dropPosition];
        
//        // Decide which cells in _agrid are occupied.
//        NSArray *tiles = _item.children;
////        CGPoint item_bottom_left_corner = CGPointMake(item.positionInPoints.x - item.contentSizeInPoints.width/2,
////                                                      item.positionInPoints.y - item.contentSizeInPoints.height/2);
//        //CGPoint item_bottom_left_corner = item.positionInPoints;
//        CGPoint item_bottom_left_corner = [_item bottomLeftCorner];
//        
//        for(CCNode* tile in tiles){
//            
//            // Iterate over the tiles in the item
//            // Each one that is in the bag should mark the cell beneath it occupied
//            
//            CGPoint tile_pos = tile.positionInPoints;
//            CGPoint tile_bottom_left_corner = CGPointMake(tile_pos.x - tile.contentSizeInPoints.width/2,
//                                                          tile_pos.y - tile.contentSizeInPoints.height/2);
//            CCLOG(@"tile_bottom_left_corner: %f, %f", tile_bottom_left_corner.x , tile_bottom_left_corner.y);
//            
//            int col_index = (item_bottom_left_corner.x + tile_bottom_left_corner.x)/tileWidth;
//            int row_index = numTilesHigh - 1 - (item_bottom_left_corner.y + tile_bottom_left_corner.y)/tileHeight;
//            
//            if([self inBounds:row_index col: col_index] && [_agrid[row_index][col_index][@"occupied"] isEqual: @NO]){
//               //_agrid[row_index][col_index][@"occupied"] = @YES;
//                CCLOG(@"grid[%d][%d] occupied", row_index, col_index);
//            }else{
//               return NO;
//            }
//        }
//        return YES;
        
        result = [self forEachTileIn:_item occupy:YES];
    }
    
    // No suitable candidate found
    
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
    
    NSArray *tiles = item.children;
    CGPoint item_bottom_left_corner = [item bottomLeftCorner];
    
    // Iterate over the tiles in the item
    for(CCNode* tile in tiles){
        CGPoint tile_pos = tile.positionInPoints;
        CGPoint tile_bottom_left_corner = CGPointMake(tile_pos.x - tile.contentSizeInPoints.width/2,
                                                      tile_pos.y - tile.contentSizeInPoints.height/2);
        CCLOG(@"tile_bottom_left_corner: %f, %f", tile_bottom_left_corner.x , tile_bottom_left_corner.y);
        
        int col_index = (item_bottom_left_corner.x + tile_bottom_left_corner.x)/tileWidth;
        int row_index = numTilesHigh - 1 - (item_bottom_left_corner.y + tile_bottom_left_corner.y)/tileHeight;
        
        //If you want to occupy the cells, they should be unoccupied to begin with, and vice versa.
        if([self inBounds:row_index col: col_index] && [_agrid[row_index][col_index][@"occupied"] isEqual: @(!occupy)]){
            _agrid[row_index][col_index][@"occupied"] = @(occupy);
            CCLOG(@"grid[%d][%d] %s", row_index, col_index, occupy ? "occupied" : "unoccupied");
        }else{
            return NO; //Not all tiles occupied/unoccupied
        }
        
    }
    
    return YES; //All tiles occupied/unoccupied

}

- (BOOL) eachTileInItemCanOccupy:(Item*) item{
    
    BOOL result = YES;
    
    NSArray *tiles = item.children;
    CGPoint item_bottom_left_corner = [item position];//[item bottomLeftCorner];
    
    // Iterate over the tiles in the item
    for(CCNode* tile in tiles){
        CGPoint tile_pos = tile.positionInPoints;
        CGPoint tile_bottom_left_corner = CGPointMake(tile_pos.x - tile.contentSizeInPoints.width/2,
                                                      tile_pos.y - tile.contentSizeInPoints.height/2);
        CCLOG(@"tile_bottom_left_corner: %f, %f", tile_bottom_left_corner.x , tile_bottom_left_corner.y);
        
        int col_index = (item_bottom_left_corner.x + tile_bottom_left_corner.x)/tileWidth;
        int row_index = numTilesHigh - 1 - (item_bottom_left_corner.y + tile_bottom_left_corner.y)/tileHeight;
        
        //If you want to occupy the cells, they should be unoccupied to begin with, and vice versa.
        if(![self inBounds:row_index col: col_index] || [_agrid[row_index][col_index][@"occupied"] isEqual: @YES]){
            result = NO; //Can't occupy
            break;
        }
        
    }
    
    return result; //All tiles occupied/unoccupied
    
}

-(BOOL)inBounds:(int)row col:(int)col{
    return ((col >= 0 && col < numTilesWide)&&
            (row >=0 && row < numTilesHigh));
}
@end

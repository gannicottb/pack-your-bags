//
//  Tile.m
//  2048Tutorial
//
//  Created by Benjamin Encz on 07/04/14.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "Tile.h"

@implementation Tile

- (CGPoint)bottomLeftCorner{
    //assume position is based on centered anchor
    return ccp(self.positionInPoints.x - self.contentSizeInPoints.width/2,
               self.positionInPoints.y - self.contentSizeInPoints.height/2);
}


@end

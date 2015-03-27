//
//  Item.h
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Bag.h"

@interface Item : CCNode
- (CGPoint)snapCornerPositionInPoints;
- (CGPoint)bottomLeftCorner;
@end

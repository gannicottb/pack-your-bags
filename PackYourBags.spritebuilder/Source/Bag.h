//
//  Bag.h
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Item.h"

@interface Bag : CCSprite

// The bag holds the alignment grid.
// It also knows if all of the cells are occupied.

- (BOOL)packed;
- (BOOL)dropItem:(CCNode*)item;
- (BOOL)liftItem:(CCNode*)item;
- (void)clearGrid;
- (CGFloat)itemsPacked;

@end

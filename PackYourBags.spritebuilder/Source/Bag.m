//
//  Bag.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bag.h"

@implementation Bag{

    NSMutableArray *_agrid;
}

-(void)onEnter{
    [super onEnter];
    [self initGrid];
}

-(void)initGrid{
    
    //Init grid as described in planning
    
}


-(BOOL)packed{
    
    //Return whether every cell in the grid is occupied
    return NO;
}





@end

//
//  Tutorial.m
//  PackYourBags
//
//  Created by CMU on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial.h"

@implementation Tutorial

- (void)start {
    CCScene *tripSelectScene = [CCBReader loadAsScene:@"TripSelect"];
    [[CCDirector sharedDirector] replaceScene:tripSelectScene];
}

@end

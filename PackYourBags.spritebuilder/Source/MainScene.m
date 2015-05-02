//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Gameplay.h"


@implementation MainScene

- (void)play {
    
    CCScene *tripSelectScene = [CCBReader loadAsScene:@"TripSelect"];
    [[CCDirector sharedDirector] replaceScene:tripSelectScene];
}

- (void)didLoadFromCCB {
    
    NSNumber *firsttime = [[NSUserDefaults standardUserDefaults]valueForKey: @"firsttime"];
    if(firsttime == nil){
        firsttime = [NSNumber numberWithBool: YES];
        [[NSUserDefaults standardUserDefaults]setValue:firsttime forKey:@"firsttime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


@end
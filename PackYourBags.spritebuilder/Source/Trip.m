//
//  Trip.m
//  PackYourBags
//
//  Created by CMU on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Trip.h"
#import "Gameplay.h"
#import "Level.h"

@implementation Trip{
    CCLabelTTF *_title;
    CCLabelTTF *_highScore;
    
}
- (void)didLoadFromCCB {
    self.userInteractionEnabled = YES;
    Level *level = (Level*)[CCBReader load:[NSString stringWithFormat:@"Levels/LevelNew%i", self.level]];
    
    //set title
    
    _title.string = [NSString stringWithString:level.title];
    CCLOG(@"title: %@", level.title);
    
    //set score
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    // Load the level
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    // Set the level by getting the gameplay from scene and setting level property
    ((Gameplay *)[gameplayScene children][0]).level = self.level;
    [[CCDirector sharedDirector] replaceScene:gameplayScene];

}


@end

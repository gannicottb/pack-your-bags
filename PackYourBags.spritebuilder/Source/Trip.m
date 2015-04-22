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
#import "CCTransition.h"

@implementation Trip{
    CCLabelTTF *_title;
    CCLabelTTF *_highScore;
    
}
- (void)didLoadFromCCB {
    self.userInteractionEnabled = YES;
}

-(void)setLabels {
    Level *level = (Level*)[CCBReader load:[NSString stringWithFormat:@"Levels/LevelNew%i", self.level]];
    
    //set title
    
    _title.string = [NSString stringWithString:level.title];
    CCLOG(@"level %d title: %@", self.level, level.title);
    
    //set score

}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    CCAnimationManager* tripAnimationManager = [self animationManager];
    [tripAnimationManager runAnimationsForSequenceNamed:@"tap"];
    [tripAnimationManager setCompletedAnimationCallbackBlock:^(id sender) {
        // Load the level
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        // Set the level by getting the gameplay from scene and setting level property
        ((Gameplay *)[gameplayScene children][0]).level = self.level;
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
        [[CCDirector sharedDirector]replaceScene:gameplayScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
    }];

}


@end

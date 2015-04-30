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
    
    //set score
    NSMutableDictionary *levelData = [[[NSUserDefaults standardUserDefaults]objectForKey:
                                      [NSString stringWithFormat:@"level%d",self.level]]
                                      mutableCopy];
    if(levelData == nil){
        // If there is no level data, assume we're starting fresh
        levelData = [NSMutableDictionary new];
        // Set the locked value to the value set in Spritebuilder
        [levelData setValue:[NSNumber numberWithBool:level.locked] forKey:@"locked"];
        // Synchronize
        [[NSUserDefaults standardUserDefaults]setObject:levelData forKey:[NSString stringWithFormat:@"level%d",self.level]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    NSNumber *levelScore = [levelData valueForKey: @"score"];
    _highScore.string = [NSString stringWithFormat:@"%.0f", [levelScore floatValue]];
    
    //Locked?
    
    BOOL locked = [[levelData valueForKey:@"locked"] boolValue];
    if(locked){
        self.userInteractionEnabled = NO;
        CCSprite *bg = (CCSprite *)[self getChildByName:@"background" recursively:NO];
        bg.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Assets/trip_icon_disabled.png"];
        _title.color = CCColor.whiteColor;
    }
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    
    CCAnimationManager* tripAnimationManager = [self animationManager];
    [tripAnimationManager runAnimationsForSequenceNamed:@"tap"];
    [tripAnimationManager setCompletedAnimationCallbackBlock:^(id sender) {
//        if([firsttime boolValue]){
//            CCScene *tutorialScene = [CCBReader loadAsScene:@"Tutorial"];
//            [[CCDirector sharedDirector] replaceScene:tutorialScene];
//        }else{
            // Load the level
            CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
            // Set the level by getting the gameplay from scene and setting level property
            ((Gameplay *)[gameplayScene children][0]).level = self.level;
            [[CCDirector sharedDirector]replaceScene:gameplayScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:.5]];
       // }
    }];

}


@end

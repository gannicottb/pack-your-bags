//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Gameplay.h"


@implementation MainScene {
    //Grid *_grid;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
}

- (void)play {
    
    CCScene *tripSelectScene = [CCBReader loadAsScene:@"TripSelect"];
    [[CCDirector sharedDirector] replaceScene:tripSelectScene];
}

- (void)dealloc {
//    [_grid removeObserver:self forKeyPath:@"score"];
}

- (void)didLoadFromCCB {
//    [_grid addObserver:self forKeyPath:@"score" options:0 context:NULL];
//    
//    [[NSUserDefaults standardUserDefaults]addObserver:self
//                                           forKeyPath:@"highscore"
//                                              options:0
//                                              context:NULL];
//    
//    // load highscore
//    [self updateHighscore];
    
    NSNumber *firsttime = [[NSUserDefaults standardUserDefaults]valueForKey: @"firsttime"];
    if(firsttime == nil){
        firsttime = [NSNumber numberWithBool: YES];
        [[NSUserDefaults standardUserDefaults]setValue:firsttime forKey:@"firsttime"];
    }
    
}

- (void)updateHighscore {
//    NSNumber *newHighscore = [[NSUserDefaults standardUserDefaults]objectForKey:@"highscore"];
//    if (newHighscore) {
//        _highscoreLabel.string = [NSString stringWithFormat:@"%d", [newHighscore intValue]];
//    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context {
////    if ([keyPath isEqualToString:@"score"]) {
////        _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_grid.score];
////    } else if ([keyPath isEqualToString:@"highscore"]) {
////        [self updateHighscore];
////    }
//}

@end
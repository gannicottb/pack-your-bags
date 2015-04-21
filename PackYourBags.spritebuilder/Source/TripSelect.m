//
//  TripSelect.m
//  PackYourBags
//
//  Created by CMU on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TripSelect.h"
#import "Trip.h"

@implementation TripSelect{
    CCLayoutBox *_topRow;
    CCLayoutBox *_bottomRow;
}

- (void)didLoadFromCCB {
    
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * publishedPath = [resourcePath stringByAppendingPathComponent:@"Published-iOS"];
    NSString * levelsPath = [publishedPath stringByAppendingPathComponent:@"Levels"];
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:levelsPath error:&error];
    
    for(NSString *levelName in directoryContents){
        //_topRow addChild:
        Trip *trip = (Trip *)[CCBReader load:@"Trip"];
        int levelindex = [[levelName stringByReplacingOccurrencesOfString:@"LevelNew" withString:@""] intValue];
        trip.level = levelindex;
        [trip setLabels];
        if(_topRow.children.count < 4){
           [_topRow addChild:trip];
        }else{
            [_bottomRow addChild:trip];
        }
    }
}

@end
